unit UBackupFileScan;

interface

uses Generics.Collections, UChangeInfo, SyncObjs, SysUtils, StrUtils, Windows, Classes,
     UFileBaseInfo, UMyUtil, UModelUtil, uDebug, DateUtils;

type

{$Region ' ɨ���ļ��к����㷨 '}

    // ɨ�账�� ����
  TFileScannerBase = class
  protected
    ScanPath : string;  // ɨ��·��
    ScanRootPath : string; // ɨ��ĸ�·��
  protected
    FileCount : Integer;  // �ļ���
    FolderSpace : Int64; // ·���ռ��С
  public
    constructor Create( _ScanPath : string );
    procedure SetScanRootPath( _ScanRootPath : string );
  protected    // ɨ��ʱ �ļ��仯
    procedure FileAddHandle( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure FileModifyHandle( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure FileRemoveHandle( FilePath : string );
  protected    // ɨ��ʱ Ŀ¼�仯
    procedure FolderAddHandle( FolderPath : string; FileTime : TDateTime );
    procedure FolderRemoveHandle( FolderPath : string );
  protected    // ����·���ռ���Ϣ
    procedure ResetFolderSpaceInfo;
  protected    // ״̬�仯
    procedure AddFolderRefreshing;
    procedure RemoveFolderRefreshing;
  end;

    // �ļ��бȽ�ɨ��
  TFolderScanner = class( TFileScannerBase )
  private
    SleepCount, TotalFileCount : Integer;   // ����ɨ��Ŀ¼��ÿ 10 �� sleep 1 ��
  private
    IncludeFilterList : TFileFilterList; // ����������
    ExcludeFilterList : TFileFilterList; // �ų�������
  private
    LastFolderInfo : TTempFolderInfo;
    LastChildFileHash : TTempFileHash;
    LastChildFolderHash : TTempFolderHash;
  public
    procedure SetFilterList( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure SetCountInfo( _SleepCount, _TotalFileCount : Integer );
    procedure Update;
  private
    procedure FindLastFolderInfo;
    procedure DeeteLastFolderInfo;
  private
    procedure CheckNewFiles;
    procedure CheckFileAdd( FileName : string; FileSize : Int64; FileTime : TDateTime );
    procedure CheckFolderAdd( FolderName : string; FolderTime : TDateTime );
  private
    procedure CheckOldFiles;
  private
    function CheckNextSearch : Boolean;
    procedure ResetBackupBoardFileCount;
  private
    function IsSearchFile( FilePath : string; sch : TSearchRec ): Boolean;
    function IsSearchFolder( FolderPath : string ): Boolean;
  end;

    // �ļ� ɨ��
  TFileScanner = class( TFileScannerBase )
  private
    OldFileSize : Int64;
    OldFileTime : TDateTime;
  protected
    NewFileSize : Int64;
  public
    procedure Update;
  private
    function FindOldFileInfo : Boolean;
    procedure ResetBackupBoardFileCount;
  end;

{$EndRegion}

    // ɨ��·�� ��Ϣ
  TBackupScanPathInfo = class
  public
    FullPath : string;
    IsShowFreeLimt : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
  end;
  TBackupScanPathList = class( TObjectList<TBackupScanPathInfo> );

    // ɨ��·�� ����
  TBackupPathScanHandle = class
  private
    BackupScanPathInfo : TBackupScanPathInfo;
    ScanPath : string;
  private
    PathSpace : Int64;
    PathFileCount : Integer;
  public
    constructor Create( _BackupScanPathInfo : TBackupScanPathInfo );
    procedure Update;
  private
    procedure AddBackupBoard;
    procedure FileScanner;   // ɨ���·���� �ļ�
    procedure FolderScanner; // ɨ���·���� Ŀ¼
    procedure RemoveBackupBoard;
  private
    function IsStartScan : Boolean;
    procedure ResetBackupPathSpace; // ���ñ���·���ռ���Ϣ
    procedure BackupSelectRefresh; // ˢ�� Listview
    procedure ResetLastSyncTime; // ������һ�α���ʱ��
    procedure BackupNow;
  end;

    // ɨ��·�� �߳�
  TBackupFileScanThread = class( TThread )
  private
    Lock : TCriticalSection;
    BackupScanPathList : TBackupScanPathList;
  public
    constructor Create;
    procedure AddScanPathInfo( BackupScanPathInfo : TBackupScanPathInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextScanPathInfo : TBackupScanPathInfo;
    procedure HandleScanPath( BackupScanPathInfo : TBackupScanPathInfo );
  end;

    // �����ļ� ɨ�����Ϣ
  TMyBackupFileScanInfo = class
  private
    IsRun : Boolean;
    BackupFileScanThread : TBackupFileScanThread;
  public
    constructor Create;
    procedure AddScanPathInfo( BackupScanPathInfo : TBackupScanPathInfo );
    procedure StopFileScan;
  end;


const
  SearchCount_Sleep : Integer = 10;  // ���� 10 ���ļ� Sleep 1 ����


var
  MyBackupFileScanInfo : TMyBackupFileScanInfo;  // ɨ���·����Ϣ

implementation

uses UBackupInfoFace, UBackupInfoXml, UMyBackupInfo,UBackupUtil, UBackupBoardInfo, UBackupJobScan,
     UBackupInfoControl;


{ TFolderScanner }

function TFolderScanner.CheckNextSearch: Boolean;
begin
    // ���� CPU
  Inc( SleepCount );
  if SleepCount >= SearchCount_Sleep then
  begin
    Sleep( 1 );
    SleepCount := 0;
  end;
  ResetBackupBoardFileCount;

    // ɨ��·���Ƿ����
  Result := MyBackupFileScanInfo.IsRun;
  Result := Result and MyBackupPathInfoUtil.ReadIsEnable( ScanPath );
end;

procedure TFolderScanner.ResetBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusFileCountInfo.SetFileCount( TotalFileCount );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

procedure TFolderScanner.CheckFileAdd(FileName: string; FileSize: Int64;
  FileTime: TDateTime);
var
  FilePath : string;
begin
  FilePath := MyFilePath.getPath( ScanPath ) + FileName;

    // ����һ���ļ�
  if not LastChildFileHash.ContainsKey( FileName ) then
    FileAddHandle( FilePath, FileSize, FileTime )
  else
  begin
      // �޸���һ���ļ�
    if ( LastChildFileHash[ FileName ].FileSize <> FileSize ) or
        not MyDatetime.Equals( LastChildFileHash[ FileName ].LastWriteTime, FileTime )
    then
      FileModifyHandle( FilePath, FileSize, FileTime );

      // �Ƴ��Ѵ����ļ�
    LastChildFileHash.Remove( FileName );
  end;
end;

procedure TFolderScanner.CheckFolderAdd(FolderName: string; FolderTime : TDateTime);
var
  IsFolder : Boolean;
  FolderSize : Int64;
  FolderPath : string;
  FolderScanner : TFolderScanner;
begin
  FolderSize := 0;
  FolderPath := MyFilePath.getPath( ScanPath ) + FolderName;

    // ����һ��Ŀ¼
  if not LastChildFolderHash.ContainsKey( FolderName ) then
    FolderAddHandle( FolderPath, FolderTime )
  else  // �Ƴ��Ѵ����Ŀ¼
    LastChildFolderHash.Remove( FolderName );

    // ɨ����һ���ļ���
  FolderScanner := TFolderScanner.Create( FolderPath );
  FolderScanner.SetScanRootPath( ScanRootPath );
  FolderScanner.SetFilterList( IncludeFilterList, ExcludeFilterList );
  FolderScanner.SetCountInfo( SleepCount, TotalFileCount );
  FolderScanner.Update;
  SleepCount := FolderScanner.SleepCount;  // ˢ�� Scan Count
  FolderSpace := FolderSpace + FolderScanner.FolderSpace;
  FileCount := FileCount + FolderScanner.FileCount;
  TotalFileCount := FolderScanner.TotalFileCount;
  FolderScanner.Free;
end;

procedure TFolderScanner.CheckNewFiles;
var
  sch : TSearchRec;
  SearcFullPath, FileName, FilePath : string;
  IsFolder, IsSearch : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile , sch ) = 0 then
  begin
    repeat
        // ����Ƿ����ɨ��
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // �ļ�·��
      FilePath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( FilePath );
      if IsFolder then
        IsSearch := IsSearchFolder( FilePath )
      else
        IsSearch := IsSearchFile( FilePath, sch );
      if not IsSearch then // �Ѿ�������
        Continue;

        // ��ȡ�޸�ʱ��
      FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

        // �����һ��Ŀ¼
      if IsFolder then
        CheckFolderAdd( FileName, FileTime )
      else
      begin
        FileSize := sch.Size;
        FolderSpace := FolderSpace + FileSize;
        Inc( FileCount );
        Inc( TotalFileCount );

          // ����ļ���Ϣ
        CheckFileAdd( FileName, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TFolderScanner.CheckOldFiles;
var
  pf : TTempFilePart;
  pfd : TTempFolderPart;
  FileName, FolderName : string;
  FilePath, FolderPath : string;
begin
    // ɨ�� ��ɾ���� ���ļ���Ϣ
  for pf in LastChildFileHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextSearch then
      Break;

      // �Ƴ� ���ļ�
    FilePath := MyFilePath.getPath( ScanPath ) + pf.Value.FileName;
    FileRemoveHandle( FilePath );
  end;

    // ɨ�� ��ɾ���� ��Ŀ¼��Ϣ
  for pfd in LastChildFolderHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextSearch then
      Break;

      // �Ƴ� ��Ŀ¼
    FolderPath := MyFilePath.getPath( ScanPath ) + pfd.Value.FileName;
    FolderRemoveHandle( FolderPath );
  end;
end;

procedure TFolderScanner.DeeteLastFolderInfo;
begin
  LastFolderInfo.Free;
end;

procedure TFolderScanner.FindLastFolderInfo;
begin
    // ��ȡ ����
  LastFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderBaseInfo( ScanPath );
  LastChildFileHash := LastFolderInfo.TempFileHash;
  LastChildFolderHash := LastFolderInfo.TempFolderHash;
end;

function TFolderScanner.IsSearchFile(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := False;

    // ���ڰ����б���
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := True;
end;

function TFolderScanner.IsSearchFolder(FolderPath: string): Boolean;
begin
  Result := False;

    // ���ڰ����б���
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := True;
end;

procedure TFolderScanner.SetCountInfo(_SleepCount, _TotalFileCount : Integer);
begin
  SleepCount := _SleepCount;
  TotalFileCount := _TotalFileCount;
end;

procedure TFolderScanner.SetFilterList(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TFolderScanner.Update;
begin
    // ������ʾ����ˢ��
  AddFolderRefreshing;

    // ������ʷ��������
  FindLastFolderInfo;

    // ����µ��ļ��ṹ
  CheckNewFiles;

    // ���ɵ��ļ��ṹ
  CheckOldFiles;

    // ���� Ŀ¼ �ռ�����
  ResetFolderSpaceInfo;

    // ɾ�� ��������
  DeeteLastFolderInfo;

    // �Ƴ�����ˢ����ʾ
  RemoveFolderRefreshing;
end;

{ TMyBackupScanInfo }

procedure TMyBackupFileScanInfo.AddScanPathInfo(
  BackupScanPathInfo: TBackupScanPathInfo);
begin
  if not IsRun then
    Exit;

  BackupFileScanThread.AddScanPathInfo( BackupScanPathInfo );
end;

constructor TMyBackupFileScanInfo.Create;
begin
  IsRun := True;
  BackupFileScanThread := TBackupFileScanThread.Create;
end;

procedure TMyBackupFileScanInfo.StopFileScan;
begin
  IsRun := False;
  BackupFileScanThread.Free;
end;

{ TRootFolderScanner }

procedure TBackupPathScanHandle.AddBackupBoard;
var
  BackupItemStatusAddInfo : TBackupItemStatusAddInfo;
begin
  BackupItemStatusAddInfo := TBackupItemStatusAddInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusAddInfo.SetFullPath( ScanPath );
  MyBackupBoardInfo.AddChange( BackupItemStatusAddInfo );
end;

procedure TBackupPathScanHandle.BackupNow;
var
  BackupPathSyncHandle : TBackupPathSyncHandle;
begin
  BackupPathSyncHandle := TBackupPathSyncHandle.Create( ScanPath );
  BackupPathSyncHandle.SetIsShowFreeLimt( BackupScanPathInfo.IsShowFreeLimt );
  BackupPathSyncHandle.Update;
  BackupPathSyncHandle.Free;
end;

procedure TBackupPathScanHandle.BackupSelectRefresh;
var
  BackupSelectRefreshHandle : TBackupSelectRefreshHandle;
begin
  BackupSelectRefreshHandle := TBackupSelectRefreshHandle.Create( ScanPath );
  BackupSelectRefreshHandle.Update;
  BackupSelectRefreshHandle.Free;
end;

constructor TBackupPathScanHandle.Create(
  _BackupScanPathInfo: TBackupScanPathInfo);
begin
  BackupScanPathInfo := _BackupScanPathInfo;
  ScanPath := BackupScanPathInfo.FullPath;
end;

procedure TBackupPathScanHandle.FileScanner;
var
  FileScanner : TFileScanner;
begin
    // ɨ���ļ�
  FileScanner := TFileScanner.Create( ScanPath );
  FileScanner.SetScanRootPath( ScanPath );
  FileScanner.Update;
  PathSpace := FileScanner.FolderSpace;
  PathFileCount := 1;
  FileScanner.Free;
end;


procedure TBackupPathScanHandle.FolderScanner;
var
  IncludeFilterList : TFileFilterList;
  ExcludeFilterList : TFileFilterList;
  FolderScanner : TFolderScanner;
begin
    // ��ȡ������ ����
  IncludeFilterList := MyBackupPathInfoUtil.ReadIncludeFilter( ScanPath );
  ExcludeFilterList := MyBackupPathInfoUtil.ReadExcludeFilter( ScanPath );

    // ɨ��Ŀ¼
  FolderScanner := TFolderScanner.Create( ScanPath );
  FolderScanner.SetScanRootPath( ScanPath );
  FolderScanner.SetFilterList( IncludeFilterList, ExcludeFilterList );
  FolderScanner.SetCountInfo( 0, 0 );
  FolderScanner.Update;
  PathSpace := FolderScanner.FolderSpace;
  PathFileCount := FolderScanner.FileCount;
  FolderScanner.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

function TBackupPathScanHandle.IsStartScan: Boolean;
var
  BackupPathSetExistHandle : TBackupPathSetExistHandle;
begin
  Result := False;

    // �ļ�ȷ��
  if ScanPath = BackupFileScanType_FileConfirm then
  begin
    BackupNow;
    Exit;
  end;

    // ��ɾ�� �� �ѽ�ֹ ����
  if not MyBackupPathInfoUtil.ReadIsEnable( ScanPath ) then
    Exit;

  // ɨ��·�� �Ƿ����
  Result := MyFilePath.getIsExist( ScanPath );

    // ��ʾ·���Ƿ����
  BackupPathSetExistHandle := TBackupPathSetExistHandle.Create( ScanPath );
  BackupPathSetExistHandle.SetIsExist( Result );
  BackupPathSetExistHandle.Update;
  BackupPathSetExistHandle.Free;
end;

procedure TBackupPathScanHandle.RemoveBackupBoard;
var
  BackupItemStatusRemoveInfo : TBackupItemStatusRemoveInfo;
begin
  BackupItemStatusRemoveInfo := TBackupItemStatusRemoveInfo.Create( BackupItemStatusType_Refreshing );
  MyBackupBoardInfo.AddChange( BackupItemStatusRemoveInfo );
end;

procedure TBackupPathScanHandle.ResetBackupPathSpace;
var
  BackupPathSetSpaceHandle : TBackupPathSetSpaceHandle;
begin
    // �Ǹ�·��
  if not MyBackupPathInfoUtil.ReadIsRootPath( ScanPath ) then
    Exit;

  BackupPathSetSpaceHandle := TBackupPathSetSpaceHandle.Create( ScanPath );
  BackupPathSetSpaceHandle.SetSpaceInfo( PathSpace, PathFileCount );
  BackupPathSetSpaceHandle.Update;
  BackupPathSetSpaceHandle.Free;
end;

procedure TBackupPathScanHandle.ResetLastSyncTime;
var
  BackupPathSetLastSyncTimeHandle : TBackupPathSetLastSyncTimeHandle;
begin
  BackupPathSetLastSyncTimeHandle := TBackupPathSetLastSyncTimeHandle.Create( ScanPath );
  BackupPathSetLastSyncTimeHandle.SetLastSyncTime( Now );
  BackupPathSetLastSyncTimeHandle.Update;
  BackupPathSetLastSyncTimeHandle.Free;
end;

procedure TBackupPathScanHandle.Update;
begin
    // ����ɨ��
  if not IsStartScan then
    Exit;

    // ��ʾ ����ɨ��
  AddBackupBoard;

    // ɨ��·��
  if FileExists( ScanPath ) then
    FileScanner
  else
  if DirectoryExists( ScanPath ) then
    FolderScanner;

    // �Ƴ���ʾ
  RemoveBackupBoard;

    // ���� ·���ռ���Ϣ
  ResetBackupPathSpace;

    // ˢ�� Listview
  BackupSelectRefresh;

    // ������һ�α���ʱ��
  ResetLastSyncTime;

    // ���̱���
  BackupNow;
end;

{ TFileScanner }

procedure TFileScanner.ResetBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusFileCountInfo.SetFileCount( 1 );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

function TFileScanner.FindOldFileInfo: Boolean;
var
  TempFileInfo : TTempFileInfo;
begin
  Result := False;

    // ���ʻ�������
  TempFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileBaseInfo( ScanPath );
  if TempFileInfo = nil then
    Exit;

  OldFileSize := TempFileInfo.FileSize;
  OldFileTime := TempFileInfo.LastWriteTime;

  TempFileInfo.Free;

  Result := True;
end;

procedure TFileScanner.Update;
var
  IsExistOld : Boolean;
  NewFileTime : TDateTime;
begin
    // ������ʾ����ˢ��
  AddFolderRefreshing;

    // ��һ�� ɨ����ļ���Ϣ
  IsExistOld := FindOldFileInfo;

    // ��ǰɨ����ļ���Ϣ
  NewFileSize := MyFileInfo.getFileSize( ScanPath );
  NewFileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // �����ļ�
  if not IsExistOld then
    FileAddHandle( ScanPath, NewFileSize, NewFileTime )
  else     // �ļ������仯
  if ( NewFileSize <> OldFileSize ) or
     not MyDatetime.Equals( NewFileTime, OldFileTime )
  then
    FileModifyHandle( ScanPath, NewFileSize, NewFileTime );

    // ���� ��Ŀ¼�ռ���Ϣ
  FolderSpace := NewFileSize;
  FileCount := 1;
  ResetFolderSpaceInfo;

    // ��ʾ ������
  ResetBackupBoardFileCount;

    // �Ƴ�����ˢ����ʾ
  RemoveFolderRefreshing;
end;

{ TFileScannerBase }

constructor TFileScannerBase.Create(_ScanPath: string);
begin
  ScanPath := _ScanPath;
  FolderSpace := 0;
  FileCount := 0;
end;

procedure TFileScannerBase.FileAddHandle(FilePath: string;
  FileSize: Int64; FileTime: TDateTime);
var
  BackupFileAddHandle : TBackupFileAddHandle;
begin
  BackupFileAddHandle := TBackupFileAddHandle.Create( FilePath );
  BackupFileAddHandle.SetFileInfo( FileSize, FileTime );
  BackupFileAddHandle.Update;
  BackupFileAddHandle.Free;
end;

procedure TFileScannerBase.FileModifyHandle(FilePath: string; FileSize: Int64;
  FileTime: TDateTime);
begin
  FileRemoveHandle( FilePath );
  FileAddHandle( FilePath, FileSize, FileTime );
end;


procedure TFileScannerBase.FileRemoveHandle(FilePath: string);
var
  BackupFileRemoveHandle : TBackupFileRemoveHandle;
begin
    // ɾ������
  if not MyFilePath.getIsExist( ScanRootPath ) then
    Exit;

  BackupFileRemoveHandle := TBackupFileRemoveHandle.Create( FilePath );
  BackupFileRemoveHandle.Update;
  BackupFileRemoveHandle.Free;
end;

procedure TFileScannerBase.FolderAddHandle(FolderPath: string;
  FileTime: TDateTime);
var
  BackupFolderAddHandle : TBackupFolderAddHandle;
begin
  BackupFolderAddHandle := TBackupFolderAddHandle.Create( FolderPath );
  BackupFolderAddHandle.SetFolderInfo( FileTime, 0 );
  BackupFolderAddHandle.SetSpaceInfo( 0, 0 );
  BackupFolderAddHandle.Update;
  BackupFolderAddHandle.Free;
end;

procedure TFileScannerBase.FolderRemoveHandle(FolderPath: string);
var
  BackupFolderRemoveHandle : TBackupFolderRemoveHandle;
begin
    // ɾ������
  if not MyFilePath.getIsExist( ScanRootPath ) then
    Exit;

  BackupFolderRemoveHandle := TBackupFolderRemoveHandle.Create( FolderPath );
  BackupFolderRemoveHandle.Update;
  BackupFolderRemoveHandle.Free;
end;

procedure TFileScannerBase.ResetFolderSpaceInfo;
var
  BackupFolderSetSpaceHandle : TBackupFolderSetSpaceHandle;
begin
  BackupFolderSetSpaceHandle := TBackupFolderSetSpaceHandle.Create( ScanPath );
  BackupFolderSetSpaceHandle.SetSpaceInfo( FolderSpace, FileCount );
  BackupFolderSetSpaceHandle.Update;
  BackupFolderSetSpaceHandle.Free;
end;

procedure TFileScannerBase.SetScanRootPath(_ScanRootPath: string);
begin
  ScanRootPath := _ScanRootPath;
end;

procedure TFileScannerBase.AddFolderRefreshing;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Refreshing );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TFileScannerBase.RemoveFolderRefreshing;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

{ TBackupFileScanThread }

procedure TBackupFileScanThread.AddScanPathInfo(
  BackupScanPathInfo: TBackupScanPathInfo);
begin
  Lock.Enter;
  BackupScanPathList.Add( BackupScanPathInfo );
  Lock.Leave;

  Resume;
end;

constructor TBackupFileScanThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  BackupScanPathList := TBackupScanPathList.Create;
  BackupScanPathList.OwnsObjects := False;
end;

destructor TBackupFileScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  BackupScanPathList.OwnsObjects := True;
  BackupScanPathList.Free;
  Lock.Free;

  inherited;
end;

procedure TBackupFileScanThread.Execute;
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  while not Terminated do
  begin
      // ��ȡ��һ����Ҫɨ���·��
    BackupScanPathInfo := getNextScanPathInfo;

      // û�� ��Ҫɨ���·��, �����߳�
    if BackupScanPathInfo = nil then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // ɨ��·��
    HandleScanPath( BackupScanPathInfo );

      // ɨ�����
    BackupScanPathInfo.Free;
  end;

  inherited;
end;

function TBackupFileScanThread.getNextScanPathInfo: TBackupScanPathInfo;
begin
  Lock.Enter;
  if BackupScanPathList.Count > 0 then
  begin
    Result := BackupScanPathList[0];
    BackupScanPathList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TBackupFileScanThread.HandleScanPath(
  BackupScanPathInfo: TBackupScanPathInfo);
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
  BackupPathScanHandle := TBackupPathScanHandle.Create( BackupScanPathInfo );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

{ TBackupScanPathInfo }

constructor TBackupScanPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  IsShowFreeLimt := False;
end;

procedure TBackupScanPathInfo.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

end.

