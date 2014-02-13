unit ULocalBackupScan;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, URegisterInfo, UMainFormFace, Windows, UFileBaseInfo;

type

{$Region ' ɨ�� �㷨 ' }

  TScanDesPathInfo = class;
  TScanDesPathList = class;

    // ���ر��� ɨ��  ����
  TLocalBackupSourceScanner = class
  protected
    SourcePath, SourceRootPath : string;  // Դ·��
    DesPathList : TScanDesPathList;
  protected
    TotalFileCount : Integer;
    TotalFileSize : Int64;
  public
    constructor Create;
    procedure SetSourcePath( _SourcePath, _SourceRootPath : string );
    procedure SetDesPathList( _DesPathList : TScanDesPathList );
    procedure SetTotalSpaceInfo( _TotalFileCount : Integer; _TotalFileSize : Int64 );
    procedure Update;virtual;abstract;
  protected
    procedure CheckSourceFileAdd( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure ShowRefreshFace;
  protected
    procedure AddDesFile( SourceFile, DesRootPath : string );
    procedure RemoveDesFile( DesFile, DesRootPath : string );
    procedure ModifyDesFile( SourceFile, DesRootPath : string );
  end;

    // ���ر��� ɨ�� Դ�ļ�
  TLocalBackupSourceFileScanner = class( TLocalBackupSourceScanner )
  public
    procedure Update;override;
  end;

    // ���ر��� ɨ�� ԴĿ¼
  TLocalBackupSourceFolderScanner = class( TLocalBackupSourceScanner )
  private
    SourceFileNameHash : TStringHash; // Դ�ļ��б�
    ScanCount : Integer;   // ����ɨ��Ŀ¼��ÿ 30 �� sleep 1 ��
    ScanTime : TDateTime; // ��ʱ����ж�, ÿ 1 ��
  private
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public
    constructor Create;
    procedure SetScanInfo( _ScanCount : Integer; _ScanTime : TDateTime );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure Update;override;
    destructor Destroy; override;
  private        // ��� Դ·��
    procedure CheckSourceFiles;
    procedure CheckSourceFolderAdd( FolderPath : string );
  private        // ��� ����·��
    procedure CheckDesFiles;
    procedure CheckDesFile( DesPath : string; DesPathInfo : TScanDesPathInfo );
  private
    function CheckNextSearch : Boolean;
  private        // ������
    function IsSearchFile( FilePath : string; sch : TSearchRec ): Boolean;
    function IsSearchFolder( FolderPath : string ): Boolean;
  end;

{$EndRegion}

{$Region ' ɨ�� ��Ϣ ' }

      // Ŀ��·����Ϣ
  TScanDesPathInfo = class
  public
    FullPath : string;
    TotalSpace : Int64;
  public
    constructor Create( _FullPath : string );
    procedure AddSpace( Space : Int64 );
  end;
  TScanDesPathList = class( TObjectList< TScanDesPathInfo > )end;

      // ɨ����Ϣ
  TScanPathInfo = class
  public
    SourcePath : string;
    DesPathList : TStringList;
  public
    IsShowFreeLimit : Boolean;
  public
    constructor Create( _SourcePath : string );
    procedure AddDesPath( DesPath : string );
    procedure SetIsShowFreeLimit( _IsShowFreeLimit : Boolean );
    destructor Destroy; override;
  end;
  TScanPathList = class( TObjectList<TScanPathInfo> )end;

    // ɨ��ǰ, ���Ŀ��·��
  TDesPathScanCheckHandle = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
    function get : Boolean;
  private
    function CheckDriverExist: Boolean;
    function CheckDesModify : Boolean;
    procedure ResetLackSpace;
  end;

    // ɨ��Դ·��
  TScanPathHandle = class
  public
    ScanPathInfo : TScanPathInfo;
  public
    SourcePath : string;
    DesPathList : TScanDesPathList;
    TotalSize : Int64;
    TotalCount : Integer;
  public
    constructor Create( _ScanPathInfo : TScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private
    function CheckScanPathExist : Boolean;
    procedure FindDesPathList;
    procedure ScanSourcePath;
    procedure ResetScanPathSpace;
    procedure ResetLastSyncTime;
  private
    function CheckDesPath( DesPath : string ): Boolean;
  end;

{$EndRegion}

{$Region ' ����/ɾ�� �㷨 ' }

      // �ļ�����
  TFileCopyHandle = class
  protected
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  protected
    SourFileSize, DesFileSize : Int64;
    IsFirstShow, IsShowPercentage : Boolean;
    StartTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  protected
    function CheckNextCopy : Boolean; // ����Ƿ��������
    procedure RefreshFace;virtual; // ˢ�½���
    procedure SetPercentageVisible( IsVisible : Boolean );
    procedure ShowPercentage;
    procedure AddCompletedSpace;virtual;
  private
    function CheckIsEnoughSpace : Boolean;  // ����Ƿ����㹻�Ŀռ�
    procedure CheckDesRootModify; // ���Ŀ¼�Ƿ���޸�
  end;

    // ���� �����ļ�
  TFileCopyAddHandle = class
  private
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  private
    function CheckDesFileExist : Boolean;
    procedure FileCopy;
    procedure ShowBackupDesBoard;
  end;

    // ���� �ļ�
  TFileRecycledHandle = class( TFileCopyHandle )
  protected
    procedure RefreshFace;override; // ˢ�½���
    procedure AddCompletedSpace;override; // ˢ������ɿռ�
  end;

  FileRecycledUtil = class
  public
    class function getEditionPath( FilePath : string; EditionNum : Integer ): string;
  end;

    // ���� �����ļ�
  TFileRecycledAddHandle = class
  public
    DesRootPath, DesFilePath : string;
    SourceRootPath : string;
  public
    RecycledPath : string;
  public
    constructor Create( _DesRootPath, _DesFilePath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure Update;
  private
    procedure CheckKeedEditionCount;
    procedure FileCopy;
    procedure FileRemove;
    procedure ShowBackupDesBoard;
  private
    function getExistEditionCount : Integer;
  end;

    // ���� ����Ŀ¼
  TFolderRecycleHandle = class
  public
    DesRootPath, DesFolderPath : string;
    SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesRootPath, _DesFolderPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRecycled : Boolean;
  end;

    // ɾ�� �����ļ�
  TFileCopyRemoveHandle = class
  private
    DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    constructor Create( _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure Update;
  private
    procedure ShowBackupDesBoard;
    procedure RemoveCompletedSpace;
  private
    procedure CheckDesRootModify;
  end;

    // ɾ�� ����Ŀ¼
  TFolderRemoveHandle = class
  private
    DesFolderPath : string;
    DesRootPath, SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesFolderPath : string );
    procedure SetDesRootPath( _DesRootPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRemove : Boolean;
  end;

{$Endregion}

{$Region ' ����/ɾ�� ��Ϣ ' }

    // �����ļ� �仯��Ϣ
  TDesFileChangeInfo = class
  public
    SourcePath, DesPath : string;
    DesChangeType : string;
    SourceRootPath, DesRootPath : string;
  public
    constructor Create( _DesPath, _DesRootPath : string );
    procedure SetSourcePath( _SourcePath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetDesChangeType( _DesChangeType : string );
  end;
  TDesFileChangeList = class( TObjectList<TDesFileChangeInfo> )end;

    // ����仯
  TDesFileChangeHandle = class
  public
    DesFileChangeInfo : TDesFileChangeInfo;
  private
    DesChangeType, DesRootPath : string;
    SourcePath, DesPath, SourceRootPath : string;
  public
    constructor Create( _DesFileChangeInfo : TDesFileChangeInfo );
    procedure Update;
  private
    procedure CopyFileHandle;
    procedure RecycleFileHandle;
    procedure RemoveFileHandle;
  private
    procedure AddStatusFace;
  end;

{$EndRegion}


    // ԴĿ¼ ɨ��
    // Ŀ��Ŀ¼ ����/ɾ��
  TLocalBackupThread = class( TThread )
  private
    PathLock : TCriticalSection;
    ScanPathList : TScanPathList;
    LastScanHash : TStringHash;
  private
    IsNewScan : Boolean;
    DesFileChangeList : TDesFileChangeList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // ɨ��
    function ExistScanPath : Boolean;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    function getScanPathInfo : TScanPathInfo;
    procedure ScanPathHandle( ScanPathInfo : TScanPathInfo );
  public          // ���� �� ɾ��
    procedure AddChange( DesFileChangeInfo : TDesFileChangeInfo );
    function getChange : TDesFileChangeInfo;
    procedure HandleChange( DesFileChangeInfo : TDesFileChangeInfo );
    procedure HandleFileChange;
  private
    procedure CheckFreeLimit( IsShowError : Boolean );
    procedure StopScanLocalBackupSource;
  private
    procedure ClearFileChange;
    procedure ShowFreeLimitWarnning;
  end;

    // ���ر��� Դ·�� ɨ��͸���
  TMyLocalBackupHandler = class
  private
    LocalBackupThread : TLocalBackupThread;
  public
    IsRun : Boolean;
  public
    constructor Create;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    procedure AddDesFileChangeInfo( DesFileChangeInfo : TDesFileChangeInfo );
    procedure StopScan;
  end;

const
  ScanCount_Sleep = 30;
  CopyCount_Sleep = 10;

var
  ScanSource_IsCompleted : Boolean = False;

var
    // Դ·�� ɨ���߳�
  MyLocalBackupHandler : TMyLocalBackupHandler;

implementation

uses ULocalBackupControl, ULocalBackupFace, UBackupInfoFace, ULocalBackupInfo;

{ TMyDesChangeInfo }

constructor TDesFileChangeInfo.Create(_DesPath, _DesRootPath: string);
begin
  DesPath := _DesPath;
  DesRootPath := _DesRootPath;
end;

procedure TDesFileChangeInfo.SetDesChangeType(_DesChangeType: string);
begin
  DesChangeType := _DesChangeType;
end;

procedure TDesFileChangeInfo.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

procedure TDesFileChangeInfo.SetSourceRootPath(_SourceRootPath : string);
begin
  SourceRootPath := _SourceRootPath;
end;

{ TLocalCopyAddHandle }

function TFileCopyAddHandle.CheckDesFileExist: Boolean;
var
  SourceFileSize, DesFileSize : Int64;
  SourceFileTime, DesFileTime : TDateTime;
begin
  Result := False;

  if not FileExists( DesFilePath ) then
    Exit;

  SourceFileSize := MyFileInfo.getFileSize( SourFilePath );
  DesFileSize := MyFileInfo.getFileSize( DesFilePath );
  if SourceFileSize <> DesFileSize then
    Exit;

  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
  DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );
  if not MyDatetime.Equals( SourceFileTime, DesFileTime ) then
    Exit;

  Result := True;
end;

constructor TFileCopyAddHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
end;

procedure TFileCopyAddHandle.FileCopy;
var
  FileCopyHandle : TFileCopyHandle;
begin
  FileCopyHandle := TFileCopyHandle.Create( SourFilePath, DesFilePath );
  FileCopyHandle.SetDesRootPath( DesRootPath, SourceRootPath );
  FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

procedure TFileCopyAddHandle.SetDesRootPath(_DesRootPath, _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyAddHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( SourFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Copy );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileCopyAddHandle.Update;
var
  ParentFolder : string;
begin
    // ��ʾ���ظ��� ����
  ShowBackupDesBoard;

    // Ŀ¼ �� ����Ŀ¼
  if DirectoryExists( SourFilePath ) then
  begin
      // ����Ŀ¼
    ForceDirectories( DesFilePath );
  end
  else  // �ļ� �� �����ļ�
  if FileExists( SourFilePath ) and not CheckDesFileExist then
  begin
    ParentFolder := ExtractFileDir( DesFilePath );
    ForceDirectories( ParentFolder );
    FileCopy;
  end;
end;

{ TLocalCopyRemoveHandle }

constructor TFileCopyRemoveHandle.Create(_DesFilePath: string);
begin
  DesFilePath := _DesFilePath;
end;

procedure TFileCopyRemoveHandle.RemoveCompletedSpace;
var
  FileSize : Int64;
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  FileSize := MyFileInfo.getFileSize( DesFilePath );
  if FileSize > 0 then
    FileSize := -FileSize;

  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( FileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;
end;

procedure TFileCopyRemoveHandle.SetDesRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

procedure TFileCopyRemoveHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyRemoveHandle.CheckDesRootModify;
var
  BackupDesIsModifyHandle : TLocalBackupDesModifyHandle;
begin
    // �ж� Ŀ���·�� �Ƿ���޸�
  if MyDesPathUtil.getIsModify( DesRootPath ) then
    Exit;

  BackupDesIsModifyHandle := TLocalBackupDesModifyHandle.Create( DesRootPath );
  BackupDesIsModifyHandle.SetIsModify( False );
  BackupDesIsModifyHandle.Update;
  BackupDesIsModifyHandle.Free;
end;

procedure TFileCopyRemoveHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( DesFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Removing );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileCopyRemoveHandle.Update;
begin
    // ��ʾ ����ɾ������
  ShowBackupDesBoard;

    // ����Ŀ��·������ɿռ�
  RemoveCompletedSpace;

    // ɾ���ļ�
  if not MyFolderDelete.FileDelete( DesFilePath ) then
    CheckDesRootModify;
end;

{ TFileCopyHandle }

procedure TFileCopyHandle.CheckDesRootModify;
var
  BackupDesIsModifyHandle : TLocalBackupDesModifyHandle;
begin
    // �ж� Ŀ���·�� �Ƿ���޸�
  if MyFilePath.getIsModify( DesRootPath ) then
    Exit;

    // �����޸�
  BackupDesIsModifyHandle := TLocalBackupDesModifyHandle.Create( DesRootPath );
  BackupDesIsModifyHandle.SetIsModify( False );
  BackupDesIsModifyHandle.Update;
  BackupDesIsModifyHandle.Free;
end;

function TFileCopyHandle.CheckIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
  LocalBackupDesLackSpaceHandle : TLocalBackupDesLackSpaceHandle;
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  Result := True;
  FreeSize := MyHardDisk.getHardDiskFreeSize( DesRootPath );

    // �Ƿ����㹻�Ŀռ�
  if FreeSize >= MyFileInfo.getFileSize( SourFilePath ) then
    Exit;

    // ȱ�ٿռ�
  LocalBackupDesLackSpaceHandle := TLocalBackupDesLackSpaceHandle.Create( DesRootPath );
  LocalBackupDesLackSpaceHandle.SetIsLackSpace( True );
  LocalBackupDesLackSpaceHandle.Update;
  LocalBackupDesLackSpaceHandle.Free;

    // ���ټ���Ŀռ�
  SourFileSize := MyFileInfo.getFileSize( SourFilePath );
  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( -SourFileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;

  Result := False;
end;

function TFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= CopyCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;

    // 1 ���� ˢ��һ�ν���
  if SecondsBetween( Now, StartTime ) >= 1 then
  begin
      // ��� ��һ�� ����С�� 30%, ��ʾ������
    if IsFirstShow then
    begin
      IsFirstShow := False;
      IsShowPercentage := MyPercentage.getPercent( DesFileSize, SourFileSize ) < 30;
      if IsShowPercentage then
        SetPercentageVisible( True );
    end;
    if IsShowPercentage then
      ShowPercentage;
    StartTime := Now;

      // ˢ�½���
    RefreshFace;

      // ��� �Ƿ����ж�
    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    Result := Result and MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath );
  end;

    // �����Ѿ� Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFileCopyHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
  SleepCount := 0;
  IsShowPercentage := False;
  IsFirstShow := True;
  StartTime := Now;
end;

procedure TFileCopyHandle.RefreshFace;
begin
    // ���� ����
  MyLocalBackupStatusShow.AddSourceCopy( SourceRootPath );
  MyLocalBackupStatusShow.AddDesChange( DesRootPath, DesChangeType_Add );
end;

procedure TFileCopyHandle.AddCompletedSpace;
var
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( SourFileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;
end;

procedure TFileCopyHandle.SetDesRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyHandle.SetPercentageVisible(IsVisible: Boolean);
var
  PlBackupDesPercentVisibleInfo : TPlBackupDesPercentVisibleInfo;
begin
  PlBackupDesPercentVisibleInfo := TPlBackupDesPercentVisibleInfo.Create( IsVisible );
  PlBackupDesPercentVisibleInfo.SetExplorerPath( SourFilePath );
  MyBackupFileFace.AddChange( PlBackupDesPercentVisibleInfo );
end;

procedure TFileCopyHandle.ShowPercentage;
var
  Percentage : Integer;
  PercentageCompareStr : string;
  PlBackupDesBoardPercentInfo : TPlBackupDesBoardPercentInfo;
begin
  Percentage := MyPercentage.getPercent( DesFileSize, SourFileSize );
  PercentageCompareStr := MyPercentage.getCompareStr( DesFileSize, SourFileSize );

  PlBackupDesBoardPercentInfo := TPlBackupDesBoardPercentInfo.Create( Percentage );
  PlBackupDesBoardPercentInfo.SetPercentCompareStr( PercentageCompareStr );
  MyBackupFileFace.AddChange( PlBackupDesBoardPercentInfo );
end;

procedure TFileCopyHandle.Update;
var
  SourFileStream, DesFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SleepCount, PercentCount : Integer;
  SourceFileTime : TDateTime;
begin
    // Դ�ļ�������
  if not FileExists( SourFilePath ) then
    Exit;

    // Ŀ��·��û���㹻�Ŀռ�
  if not CheckIsEnoughSpace then
    Exit;

    // �ļ���
  SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );
  try
    ForceDirectories( ExtractFileDir( DesFilePath ) );
    DesFileStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );
    SourFileSize := SourFileStream.Size;
    DesFileSize := 0;

    FullBufSize := SizeOf( Buf );
    RemainSize := SourFileSize;
    while RemainSize > 0 do
    begin
        // ȡ������ �� �������
      if not CheckNextCopy then
        Break;

      BufSize := Min( FullBufSize, RemainSize );
      if SourFileStream.Read( Buf, BufSize ) <> BufSize then
        Break;
      if DesFileStream.Write( Buf, BufSize ) <> BufSize then
        Break;
      RemainSize := RemainSize - BufSize;
      DesFileSize := DesFileSize + BufSize;
    end;
    DesFileStream.Free;

      // ͳ���������Ϣ
    AddCompletedSpace;

      // �����޸�ʱ��
    SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
    MyFileSetTime.SetTime( DesFilePath, SourceFileTime );
  except
    CheckDesRootModify; // ���Ŀ¼�Ƿ���޸�
  end;
  SourFileStream.Free;

    // ���ؽ���
  if IsShowPercentage then
    SetPercentageVisible( False );
end;

{ TLocalBackupSourceScanThread }

procedure TLocalBackupThread.AddChange(
  DesFileChangeInfo: TDesFileChangeInfo);
begin
  PathLock.Enter;
  DesFileChangeList.Add( DesFileChangeInfo );
  PathLock.Leave;

  Resume;
end;

procedure TLocalBackupThread.AddScanPathInfo(
  ScanPathInfo : TScanPathInfo);
begin
  PathLock.Enter;
  ScanPathList.Add( ScanPathInfo );
  IsNewScan := not LastScanHash.ContainsKey( ScanPathInfo.SourcePath );
  PathLock.Leave;

  Resume;
end;

procedure TLocalBackupThread.CheckFreeLimit( IsShowError : Boolean );
begin
    // �����ð�, ����
  if not RegisterInfo.getIsFreeEdition then
    Exit;

    // ������������
  if MyLocalBackupSourceReadUtil.getTotalSapce > EditionUtil.getFreeMaxBackupSpace then
  begin
    ClearFileChange; // ����ļ��仯
    if IsShowError then  // ��ʾ���ƴ���
      ShowFreeLimitWarnning;
  end;
end;

procedure TLocalBackupThread.ClearFileChange;
begin
  PathLock.Enter;
  DesFileChangeList.OwnsObjects := True;
  DesFileChangeList.Clear;
  DesFileChangeList.OwnsObjects := False;
  PathLock.Leave;
end;

constructor TLocalBackupThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  ScanPathList := TScanPathList.Create;
  ScanPathList.OwnsObjects := False;
  LastScanHash := TStringHash.Create;
  DesFileChangeList := TDesFileChangeList.Create;
  DesFileChangeList.OwnsObjects := False;
end;

destructor TLocalBackupThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  DesFileChangeList.OwnsObjects := True;
  DesFileChangeList.Free;
  LastScanHash.Free;
  ScanPathList.OwnsObjects := True;
  ScanPathList.Free;
  PathLock.Free;

  inherited;
end;

procedure TLocalBackupThread.Execute;
var
  ScanPathInfo : TScanPathInfo;
  IsShowError : Boolean;
begin
  while not Terminated do
  begin
      // ɨ��
    ScanPathInfo := getScanPathInfo;
    if ScanPathInfo <> nil then
    begin
      IsShowError := ScanPathInfo.IsShowFreeLimit;
      ScanPathHandle( ScanPathInfo );  // ɨ��·��
      ScanPathInfo.Free;
      Continue;
    end;

      // ���� / ɾ��
    CheckFreeLimit( IsShowError ); // ����Ƿ񳬹���������
    IsNewScan := False;
    HandleFileChange;  // ���� ����/ɾ���ļ�
    if not ExistScanPath then  // û�� Ҫɨ����ļ�, �����߳�
    begin
      StopScanLocalBackupSource;
      if not Terminated then
        Suspend;
    end;
  end;
  inherited;
end;


function TLocalBackupThread.ExistScanPath: Boolean;
begin
  PathLock.Enter;
  Result := ScanPathList.Count > 0;
  PathLock.Leave;
end;

function TLocalBackupThread.getChange: TDesFileChangeInfo;
begin
  PathLock.Enter;
  if DesFileChangeList.Count > 0 then
  begin
    Result := DesFileChangeList[0];
    DesFileChangeList.Delete(0);
  end
  else
    Result := nil;
  PathLock.Leave;
end;

function TLocalBackupThread.getScanPathInfo: TScanPathInfo;
var
  i : Integer;
  SourcePath : string;
begin
  PathLock.Enter;
  Result := nil;
  for i := 0 to ScanPathList.Count - 1 do
  begin
    SourcePath := ScanPathList[i].SourcePath;
    if LastScanHash.ContainsKey( SourcePath ) then
      Continue;
    Result := ScanPathList[i];
    ScanPathList.Delete(0);
    LastScanHash.AddString( Result.SourcePath );
    Break;
  end;
  PathLock.Leave;
end;

procedure TLocalBackupThread.HandleChange(
  DesFileChangeInfo: TDesFileChangeInfo);
var
  DesFileChangeHandle : TDesFileChangeHandle;
begin
  try
    // �����ļ��仯
    DesFileChangeHandle := TDesFileChangeHandle.Create( DesFileChangeInfo );
    DesFileChangeHandle.Update;
    DesFileChangeHandle.Free;
  except
  end;
end;

procedure TLocalBackupThread.HandleFileChange;
var
  DesFileChangeInfo : TDesFileChangeInfo;
begin
  while not Terminated do
  begin
      // �����µ�ɨ��·��
    if IsNewScan then
      Break;

    DesFileChangeInfo := getChange;
    if DesFileChangeInfo = nil then
    begin
      PathLock.Enter;
      LastScanHash.Clear;
      PathLock.Leave;
      Break;
    end;
    HandleChange( DesFileChangeInfo );
    DesFileChangeInfo.Free;

    Sleep(1);
  end;
end;

procedure TLocalBackupThread.ScanPathHandle(ScanPathInfo: TScanPathInfo);
var
  ScanPathHandle : TScanPathHandle;
begin
  try
    ScanPathHandle := TScanPathHandle.Create( ScanPathInfo );
    ScanPathHandle.Update;
    ScanPathHandle.Free;
  except
  end;
end;

procedure TLocalBackupThread.ShowFreeLimitWarnning;
var
  ShowFreeEditionWarnning : TShowFreeEditionWarnning;
begin
  ShowFreeEditionWarnning := TShowFreeEditionWarnning.Create( FreeEditionError_BackupSpace );
  MyMainFormFace.AddChange( ShowFreeEditionWarnning );
end;

procedure TLocalBackupThread.StopScanLocalBackupSource;
var
  LocalBackupSourceAllScanCompletedHandle : TLocalBackupSourceAllScanCompletedHandle;
begin
  LocalBackupSourceAllScanCompletedHandle := TLocalBackupSourceAllScanCompletedHandle.Create;
  LocalBackupSourceAllScanCompletedHandle.Update;
  LocalBackupSourceAllScanCompletedHandle.Free;
end;

{ TScanPathInfo }

procedure TScanPathInfo.AddDesPath(DesPath: string);
begin
  DesPathList.Add( DesPath );
end;

constructor TScanPathInfo.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
  DesPathList := TStringList.Create;
  IsShowFreeLimit := False;
end;

destructor TScanPathInfo.Destroy;
begin
  DesPathList.Free;
  inherited;
end;

procedure TScanPathInfo.SetIsShowFreeLimit(_IsShowFreeLimit: Boolean);
begin
  IsShowFreeLimit := _IsShowFreeLimit;
end;

{ TLocalBackupSourceFolderScanner }

procedure TLocalBackupSourceFolderScanner.CheckSourceFolderAdd(
  FolderPath: string);
var
  i : Integer;
  DesChildPath : string;
  DesPath, DesFolderPath : string;
  LocalBackupSourceFolderScanner : TLocalBackupSourceFolderScanner;
begin
  DesChildPath := MyFilePath.getDownloadPath( FolderPath );

    // ����Ŀ��·��
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesFolderPath := MyFilePath.getPath( DesPath ) + DesChildPath;

      // ����Ŀ¼
    if not DirectoryExists( DesFolderPath ) then
      AddDesFile( FolderPath, DesPath );
  end;

    // ɨ����һ��
  LocalBackupSourceFolderScanner := TLocalBackupSourceFolderScanner.Create;
  LocalBackupSourceFolderScanner.SetSourcePath( FolderPath, SourceRootPath );
  LocalBackupSourceFolderScanner.SetDesPathList( DesPathList );
  LocalBackupSourceFolderScanner.SetScanInfo( ScanCount, ScanTime );
  LocalBackupSourceFolderScanner.SetTotalSpaceInfo( TotalFileCount, TotalFileSize );
  LocalBackupSourceFolderScanner.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalBackupSourceFolderScanner.Update;
  ScanCount := LocalBackupSourceFolderScanner.ScanCount;
  ScanTime := LocalBackupSourceFolderScanner.ScanTime;
  TotalFileCount := LocalBackupSourceFolderScanner.TotalFileCount;
  TotalFileSize := LocalBackupSourceFolderScanner.TotalFileSize;
  LocalBackupSourceFolderScanner.Free;
end;


procedure TLocalBackupSourceFolderScanner.CheckDesFile(
  DesPath: string; DesPathInfo : TScanDesPathInfo);
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( DesPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      if SourceFileNameHash.ContainsKey( FileName ) then
        Continue;

      ChildPath := SearcFullPath + FileName ;

          // ���Ŀ��Ŀ¼ �ļ��ռ�
      if not DirectoryExists( ChildPath ) then
        DesPathInfo.AddSpace( sch.Size );

      RemoveDesFile( ChildPath, DesPathInfo.FullPath );

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TLocalBackupSourceFolderScanner.CheckDesFiles;
var
  i : Integer;
  DesPath, DesScanPath : string;
begin
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesScanPath := MyFilePath.getPath( DesPath );
    DesScanPath := DesScanPath + MyFilePath.getDownloadPath( SourcePath );

    CheckDesFile( DesScanPath, DesPathList[i] );
  end;
end;

function TLocalBackupSourceFolderScanner.CheckNextSearch: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( ScanCount );
  if ScanCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    ScanCount := 0;
  end;

    // 1 ���� ���һ��
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // ˢ�½���
    ShowRefreshFace;

      // ����Ƿ��ж�
    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    ScanTime := Now;
  end;

    // ���� �Ƿ����ɨ��
  Result := Result and MyLocalBackupHandler.IsRun;
end;

procedure TLocalBackupSourceFolderScanner.CheckSourceFiles;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsSearchResult : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( SourcePath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsSearchResult := IsSearchFolder( ChildPath )
      else
        IsSearchResult := IsSearchFile( ChildPath, sch );
      if not IsSearchResult then  // �ļ�������
        Continue;

      SourceFileNameHash.AddString( FileName );

        // �����һ��Ŀ¼
      if IsFolder then
        CheckSourceFolderAdd( ChildPath )
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

        TotalFileSize := TotalFileSize + FileSize;
        TotalFileCount := TotalFileCount + 1;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��� �ļ���Ϣ
        CheckSourceFileAdd( ChildPath, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

constructor TLocalBackupSourceFolderScanner.Create;
begin
  inherited;
  SourceFileNameHash := TStringHash.Create;
  ScanCount := 0;
  ScanTime := Now;
end;

destructor TLocalBackupSourceFolderScanner.Destroy;
begin
  SourceFileNameHash.Free;
  inherited;
end;

function TLocalBackupSourceFolderScanner.IsSearchFile(FilePath: string;
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

function TLocalBackupSourceFolderScanner.IsSearchFolder(
  FolderPath: string): Boolean;
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

procedure TLocalBackupSourceFolderScanner.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TLocalBackupSourceFolderScanner.SetScanInfo(_ScanCount: Integer;
  _ScanTime : TDateTime);
begin
  ScanCount := _ScanCount;
  ScanTime := _ScanTime;
end;

procedure TLocalBackupSourceFolderScanner.Update;
begin
    // ��� Դ·��
  CheckSourceFiles;

    // ��� Ŀ��·��
  CheckDesFiles;

    // ˢ�½���
  ShowRefreshFace;
end;

{ TLocalBackupSourceScanner }

procedure TLocalBackupSourceScanner.AddDesFile(SourceFile, DesRootPath: string);
var
  DesChildPath : string;
  DesFileChangeInfo : TDesFileChangeInfo;
begin
    // �ļ�����ʹ��
  if MyFileInfo.getFileIsInUse( SourceFile ) then
    Exit;

  DesChildPath := MyFilePath.getPath( DesRootPath );
  DesChildPath := DesChildPath + MyFilePath.getDownloadPath( SourceFile );

  DesFileChangeInfo := TDesFileChangeInfo.Create( DesChildPath, DesRootPath );
  DesFileChangeInfo.SetSourcePath( SourceFile );
  DesFileChangeInfo.SetDesChangeType( DesChangeType_Add );
  DesFileChangeInfo.SetSourceRootPath( SourceRootPath );

  MyLocalBackupHandler.AddDesFileChangeInfo( DesFileChangeInfo );
end;

procedure TLocalBackupSourceScanner.CheckSourceFileAdd(FilePath: string;
  FileSize: Int64; FileTime: TDateTime);
var
  i : Integer;
  DesChildPath : string;
  DesPath, DesFilePath : string;
  DesFileSize : Int64;
  DesFileTime : TDateTime;
begin
  DesChildPath := MyFilePath.getDownloadPath( FilePath );

  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesFilePath := MyFilePath.getPath( DesPath ) + DesChildPath;

      // ���
    if not FileExists( DesFilePath ) then
      AddDesFile( FilePath, DesPath )
    else
    begin
      DesFileSize := MyFileInfo.getFileSize( DesFilePath );
      DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );

        // Ŀ��·�� �ռ�ͳ��
      DesPathList[i].AddSpace( DesFileSize );

        // ����
      if ( DesFileSize <> FileSize ) or
         not MyDatetime.Equals( DesFileTime, FileTime )
      then
        ModifyDesFile( FilePath, DesPath );
    end;
  end;
end;

constructor TLocalBackupSourceScanner.Create;
begin
  TotalFileCount := 0;
  TotalFileSize := 0;
end;

procedure TLocalBackupSourceScanner.ModifyDesFile(SourceFile,
  DesRootPath: string);
var
  DesChildPath : string;
  DesFileChangeInfo : TDesFileChangeInfo;
begin
  DesChildPath := MyFilePath.getPath( DesRootPath );
  DesChildPath := DesChildPath + MyFilePath.getDownloadPath( SourceFile );

    // ��ɾ��
  RemoveDesFile( DesChildPath, DesRootPath );

    // �����
  AddDesFile( SourceFile, DesRootPath );
end;

procedure TLocalBackupSourceScanner.ShowRefreshFace;
begin
  MyLocalBackupStatusShow.AddSourceRefresh( SourceRootPath, TotalFileCount );
end;

procedure TLocalBackupSourceScanner.RemoveDesFile(DesFile,
  DesRootPath: string);
var
  DesFileChangeInfo : TDesFileChangeInfo;
begin
    // ���ڵ㲻���� ɾ������
  if not MyFilePath.getIsExist( SourceRootPath ) then
    Exit;

  DesFileChangeInfo := TDesFileChangeInfo.Create( DesFile, DesRootPath );
  DesFileChangeInfo.SetDesChangeType( DesChangeType_Remove );
  DesFileChangeInfo.SetSourceRootPath( SourceRootPath );

  MyLocalBackupHandler.AddDesFileChangeInfo( DesFileChangeInfo );
end;

procedure TLocalBackupSourceScanner.SetDesPathList(_DesPathList: TScanDesPathList);
begin
  DesPathList := _DesPathList;
end;

procedure TLocalBackupSourceScanner.SetSourcePath(
  _SourcePath, _SourceRootPath: string);
begin
  SourcePath := _SourcePath;
  SourceRootPath := _SourceRootPath;
end;

procedure TLocalBackupSourceScanner.SetTotalSpaceInfo(_TotalFileCount: Integer;
  _TotalFileSize: Int64);
begin
  TotalFileCount := _TotalFileCount;
  TotalFileSize := _TotalFileSize;
end;

{ TLocalBackupSourceFileScanner }

procedure TLocalBackupSourceFileScanner.Update;
var
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
begin
  SourceFileSize := MyFileInfo.getFileSize( SourcePath );
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourcePath );

  TotalFileCount := 1;
  TotalFileSize := SourceFileSize;

    // ���
  CheckSourceFileAdd( SourcePath, SourceFileSize, SourceFileTime );

    // ��ʾ ˢ�½���
  ShowRefreshFace;
end;

{ TMyLocalBackupSourceScanner }

procedure TMyLocalBackupHandler.AddDesFileChangeInfo(
  DesFileChangeInfo: TDesFileChangeInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddChange( DesFileChangeInfo );
end;

procedure TMyLocalBackupHandler.AddScanPathInfo(
  ScanPathInfo: TScanPathInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddScanPathInfo( ScanPathInfo );
end;

constructor TMyLocalBackupHandler.Create;
begin
  LocalBackupThread := TLocalBackupThread.Create;
  IsRun := True;
end;

procedure TMyLocalBackupHandler.StopScan;
begin
  IsRun := False;
  LocalBackupThread.Free;
end;



{ TScanDesPathInfo }

procedure TScanDesPathInfo.AddSpace(Space: Int64);
begin
  TotalSpace := TotalSpace + Space;
end;

constructor TScanDesPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  TotalSpace := 0;
end;

{ TScanPathHandle }

function TScanPathHandle.CheckDesPath(DesPath: string): Boolean;
var
  DesPathScanCheckHandle : TDesPathScanCheckHandle;
begin
  DesPathScanCheckHandle := TDesPathScanCheckHandle.Create( DesPath );
  Result := DesPathScanCheckHandle.get;
  DesPathScanCheckHandle.Free;
end;

function TScanPathHandle.CheckScanPathExist: Boolean;
var
  LocalBackupSourceSetExistHandle : TLocalBackupSourceSetExistHandle;
begin
  Result := MyFilePath.getIsExist( SourcePath );

    // ����Դ·�� �Ƿ����
  LocalBackupSourceSetExistHandle := TLocalBackupSourceSetExistHandle.Create( SourcePath );
  LocalBackupSourceSetExistHandle.SetIsExist( Result );
  LocalBackupSourceSetExistHandle.Update;
  LocalBackupSourceSetExistHandle.Free;
end;

constructor TScanPathHandle.Create(_ScanPathInfo: TScanPathInfo);
begin
  ScanPathInfo := _ScanPathInfo;
  SourcePath := ScanPathInfo.SourcePath;
  DesPathList := TScanDesPathList.Create;
end;

destructor TScanPathHandle.Destroy;
begin
  DesPathList.Free;
  inherited;
end;

procedure TScanPathHandle.FindDesPathList;
var
  i : Integer;
  DesPath : string;
  ScanDesPathInfo : TScanDesPathInfo;
begin
  for i := 0 to ScanPathInfo.DesPathList.Count - 1 do
  begin
    DesPath := ScanPathInfo.DesPathList[i];
    if not CheckDesPath( DesPath ) then // Ŀ¼������/Ŀ¼�����޸�
      Continue;
    ScanDesPathInfo := TScanDesPathInfo.Create( DesPath );
    DesPathList.Add( ScanDesPathInfo );
  end;
end;

procedure TScanPathHandle.ResetLastSyncTime;
var
  LocalBackupSourceSetLastSyncTimeHandle : TLocalBackupSourceSetLastSyncTimeHandle;
begin
  LocalBackupSourceSetLastSyncTimeHandle := TLocalBackupSourceSetLastSyncTimeHandle.Create( SourcePath );
  LocalBackupSourceSetLastSyncTimeHandle.SetLastSyncTime( Now );
  LocalBackupSourceSetLastSyncTimeHandle.Update;
  LocalBackupSourceSetLastSyncTimeHandle.Free;
end;

procedure TScanPathHandle.ResetScanPathSpace;
var
  LocalBackupSourceSpaceHandle : TLocalBackupSourceSpaceHandle;
  i : Integer;
  DesPath : string;
  LocalBackupSourceSetDesSpaceHandle : TLocalBackupSourceSetDesSpaceHandle;
begin
    // ���ÿռ���Ϣ
  LocalBackupSourceSpaceHandle := TLocalBackupSourceSpaceHandle.Create( SourcePath );
  LocalBackupSourceSpaceHandle.SetSpaceInfo( TotalCount, TotalSize );
  LocalBackupSourceSpaceHandle.Update;
  LocalBackupSourceSpaceHandle.Free;

  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;

    LocalBackupSourceSetDesSpaceHandle := TLocalBackupSourceSetDesSpaceHandle.Create( SourcePath );
    LocalBackupSourceSetDesSpaceHandle.SetDesPath( DesPath );
    LocalBackupSourceSetDesSpaceHandle.SetSpaceInfo( TotalSize, DesPathList[i].TotalSpace );
    LocalBackupSourceSetDesSpaceHandle.Update;
    LocalBackupSourceSetDesSpaceHandle.Free;
  end;
end;

procedure TScanPathHandle.ScanSourcePath;
var
  IncludeFilterList : TFileFilterList;  // ����������
  ExcludeFilterList : TFileFilterList;  // �ų�������
  LocalBackupSourceScanner : TLocalBackupSourceScanner;
  LocalBackupSourceFolderScanner : TLocalBackupSourceFolderScanner;
begin
  IncludeFilterList := MyLocalBackupSourceReadUtil.ReadIncludeFilter( SourcePath );
  ExcludeFilterList := MyLocalBackupSourceReadUtil.ReadExcludeFilter( SourcePath );

    // ɨ��
  if FileExists( SourcePath ) then
    LocalBackupSourceScanner := TLocalBackupSourceFileScanner.Create
  else
  begin
    LocalBackupSourceFolderScanner := TLocalBackupSourceFolderScanner.Create;
    LocalBackupSourceFolderScanner.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
    LocalBackupSourceScanner := LocalBackupSourceFolderScanner;
  end;
  LocalBackupSourceScanner.SetSourcePath( SourcePath, SourcePath );
  LocalBackupSourceScanner.SetDesPathList( DesPathList );
  LocalBackupSourceScanner.Update;
  TotalSize := LocalBackupSourceScanner.TotalFileSize;
  TotalCount := LocalBackupSourceScanner.TotalFileCount;
  LocalBackupSourceScanner.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

procedure TScanPathHandle.Update;
begin
    // Դ·��������, ��ɨ��
  if not CheckScanPathExist then
    Exit;

    // Ŀ��·��
  FindDesPathList;

    // ɨ��Դ·��
  ScanSourcePath;

    // ����·���ռ���Ϣ
  ResetScanPathSpace;;

    // ���� �ϴ�ͬ��ʱ��
  ResetLastSyncTime;
end;

{ TDesFileChangeHandle }

procedure TDesFileChangeHandle.CopyFileHandle;
var
  FileCopyAddHandle : TFileCopyAddHandle;
begin
  AddStatusFace;

  FileCopyAddHandle := TFileCopyAddHandle.Create( SourcePath, DesPath );
  FileCopyAddHandle.SetDesRootPath( DesRootPath, SourceRootPath );
  FileCopyAddHandle.Update;
  FileCopyAddHandle.Free;
end;

constructor TDesFileChangeHandle.Create(_DesFileChangeInfo: TDesFileChangeInfo);
begin
  DesFileChangeInfo := _DesFileChangeInfo;
  DesChangeType := DesFileChangeInfo.DesChangeType;
  DesRootPath := DesFileChangeInfo.DesRootPath;
  SourcePath := DesFileChangeInfo.SourcePath;
  DesPath := DesFileChangeInfo.DesPath;
  SourceRootPath := DesFileChangeInfo.SourceRootPath;
end;

procedure TDesFileChangeHandle.RecycleFileHandle;
var
  FileRecycledAddHandle : TFileRecycledAddHandle;
  FolderRecycleHandle : TFolderRecycleHandle;
begin
  if FileExists( DesPath ) then
  begin
    FileRecycledAddHandle := TFileRecycledAddHandle.Create( DesRootPath, DesPath );
    FileRecycledAddHandle.SetSourceRootPath( SourceRootPath );
    FileRecycledAddHandle.Update;
    FileRecycledAddHandle.Free;
  end
  else
  begin
    FolderRecycleHandle := TFolderRecycleHandle.Create( DesRootPath, DesPath );
    FolderRecycleHandle.SetSourceRootPath( SourceRootPath );
    FolderRecycleHandle.Update;
    FolderRecycleHandle.Free;
  end;
end;

procedure TDesFileChangeHandle.AddStatusFace;
begin
    // Դ·�� ״̬
  if DesChangeType = DesChangeType_Add then
    MyLocalBackupStatusShow.AddSourceCopy( SourceRootPath );

    // Ŀ��·�� ״̬
  MyLocalBackupStatusShow.AddDesChange( DesRootPath, DesChangeType );
end;

procedure TDesFileChangeHandle.RemoveFileHandle;
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
  FolderRemoveHandle : TFolderRemoveHandle;
begin
    // ɾ��
  AddStatusFace;

  if FileExists( DesPath ) then
  begin
    FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( DesPath );
    FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
    FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
    FileCopyRemoveHandle.Update;
    FileCopyRemoveHandle.Free;
  end
  else
  begin
    FolderRemoveHandle := TFolderRemoveHandle.Create( DesPath );
    FolderRemoveHandle.SetDesRootPath( DesRootPath );
    FolderRemoveHandle.SetSourceRootPath( SourceRootPath );
    FolderRemoveHandle.Update;
    FolderRemoveHandle.Free;
  end;
end;

procedure TDesFileChangeHandle.Update;
begin
    // Des Disable, ������
  if not MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath ) then
    Exit;

    // BackupSource ��ɾ��
  if ( DesChangeType =  DesChangeType_Add ) and
      not MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath )
  then
    Exit;

    // ����仯
  if DesChangeType = DesChangeType_Add then
    CopyFileHandle
  else
  if DesChangeType = DesChangeType_Remove then
  begin
      // ���� �� ɾ��
    if MyLocalBackupSourceReadUtil.getIsKeepDeleted( SourceRootPath ) then
      RecycleFileHandle
    else
      RemoveFileHandle;
  end;
end;

{ TFileRecycledHandle }

procedure TFileRecycledAddHandle.CheckKeedEditionCount;
var
  KeepEditionCount : Integer;
  ExistEditionCount : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
  KeepEditionCount := MyLocalBackupSourceReadUtil.getKeedEditionCount( SourceRootPath );
  ExistEditionCount := getExistEditionCount;
  if ( ExistEditionCount = 0 ) or ( KeepEditionCount = 0 ) then
    Exit;

    // �汾 ������
    // ɾ�� ��Ͱ汾
  if ExistEditionCount >= KeepEditionCount then
  begin
    FilePath1 := FileRecycledUtil.getEditionPath( RecycledPath, KeepEditionCount - 1 );
    MyFolderDelete.FileDelete( FilePath1 );
  end;

    // �����汾��
  ExistEditionCount := Min( ExistEditionCount, KeepEditionCount  );

    // �汾����
  for i := ExistEditionCount downto 2 do
  begin
    FilePath1 := FileRecycledUtil.getEditionPath( RecycledPath, i - 1 );
    FilePath2 := FileRecycledUtil.getEditionPath( RecycledPath, i );
    RenameFile( FilePath1, FilePath2 );
  end;

    // ��ǰ�汾��Ϊ���һ���汾
  RenameFile( RecycledPath, FileRecycledUtil.getEditionPath( RecycledPath, 1 ) )
end;

constructor TFileRecycledAddHandle.Create(_DesRootPath, _DesFilePath: string);
begin
  DesRootPath := _DesRootPath;
  DesFilePath := _DesFilePath;
end;

procedure TFileRecycledAddHandle.FileCopy;
var
  CopySourcePath, CopySourceRootPath : string;
  CopyDesRootPath, CopyDesPath : string;
  FileRecycledHandle : TFileRecycledHandle;
begin
  CopySourceRootPath := SourceRootPath;
  CopyDesRootPath := DesRootPath;
  CopySourcePath := DesFilePath;
  CopyDesPath := RecycledPath;

  FileRecycledHandle := TFileRecycledHandle.Create( CopySourcePath, CopyDesPath );
  FileRecycledHandle.SetDesRootPath( CopyDesRootPath, CopySourceRootPath );
  FileRecycledHandle.Update;
  FileRecycledHandle.Free;
end;

procedure TFileRecycledAddHandle.FileRemove;
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
begin
  FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( DesFilePath );
  FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
  FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
  FileCopyRemoveHandle.Update;
  FileCopyRemoveHandle.Free;
end;

function TFileRecycledAddHandle.getExistEditionCount: Integer;
begin
  Result := 0;
  if not FileExists( RecycledPath ) then
    Exit;
  Inc( Result );

  while FileExists( FileRecycledUtil.getEditionPath( RecycledPath, Result ) ) do
    Inc( Result );
end;

procedure TFileRecycledAddHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFileRecycledAddHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( DesFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Recycling );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileRecycledAddHandle.Update;
begin
    // ���� �����ļ������·��
  RecycledPath := MyString.CutStartStr( DesRootPath, DesFilePath );
  RecycledPath := MyFilePath.getPath( DesRootPath ) + LocalBackup_RecycledFolder + RecycledPath;

    // ��ʾ���ڻ���
  MyLocalBackupStatusShow.AddDesRecycled( DesRootPath, SourceRootPath );

    // ��ʾ���ڻ���
  ShowBackupDesBoard;

    // ��鱣��İ汾��
  CheckKeedEditionCount;

    // �ļ�����
  FileCopy;

    // �ļ�ɾ��
  FileRemove;
end;

{ TFileRecycledHandle }

procedure TFileRecycledHandle.RefreshFace;
begin
  MyLocalBackupStatusShow.AddDesRecycled( DesRootPath, SourceRootPath );
end;

procedure TFileRecycledHandle.AddCompletedSpace;
var
  LocalBackupSourceAddDesDeletedSpaceHandle : TLocalBackupSourceAddDesDeletedSpaceHandle;
begin
  LocalBackupSourceAddDesDeletedSpaceHandle := TLocalBackupSourceAddDesDeletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesDeletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesDeletedSpaceHandle.SetAddRecycledSpace( SourFileSize );
  LocalBackupSourceAddDesDeletedSpaceHandle.Update;
  LocalBackupSourceAddDesDeletedSpaceHandle.Free;
end;

{ TFolderRecycleHandle }

function TFolderRecycleHandle.CheckNextRecycled: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    Result := Result and MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath );
  end;

    // �����Ѿ� Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFolderRecycleHandle.Create(_DesRootPath, _DesFolderPath: string);
begin
  DesRootPath := _DesRootPath;
  DesFolderPath := _DesFolderPath;
  SleepCount := 0;
end;

procedure TFolderRecycleHandle.FolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TFolderRecycleHandle.SearchFile(FilePath: string);
var
  FileRecycledAddHandle : TFileRecycledAddHandle;
begin
  FileRecycledAddHandle := TFileRecycledAddHandle.Create( DesRootPath, FilePath );
  FileRecycledAddHandle.SetSourceRootPath( SourceRootPath );
  FileRecycledAddHandle.Update;
  FileRecycledAddHandle.Free;
end;

procedure TFolderRecycleHandle.SearchFolder(FolderPath: string);
var
  FolderRecycleHandle : TFolderRecycleHandle;
begin
  FolderRecycleHandle := TFolderRecycleHandle.Create( DesRootPath, FolderPath );
  FolderRecycleHandle.SetSourceRootPath( SourceRootPath );
  FolderRecycleHandle.SetSleepCount( SleepCount );
  FolderRecycleHandle.Update;
  SleepCount := FolderRecycleHandle.SleepCount;
  FolderRecycleHandle.Free;
end;

procedure TFolderRecycleHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TFolderRecycleHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFolderRecycleHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextRecycled then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( ChildPath )
      else
        SearchFile( ChildPath );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // Ŀ¼ɾ��
  FolderRemove;
end;

{ FileRecycledUtil }

class function FileRecycledUtil.getEditionPath(FilePath: string;
  EditionNum: Integer): string;
var
  AfterStr : string;
  BeforeStr : string;
begin
  AfterStr := ExtractFileExt( FilePath );
  BeforeStr := MyString.CutStopStr( AfterStr, FilePath );
  Result := BeforeStr + '.(' + IntToStr(EditionNum) + ')' + AfterStr;
end;

{ TDesPathScanCheckHandle }

function TDesPathScanCheckHandle.CheckDesModify: Boolean;
var
  LocalBackupDesModifyHandle : TLocalBackupDesModifyHandle;
begin
  Result := MyFilePath.getIsModify( DesPath );

  LocalBackupDesModifyHandle := TLocalBackupDesModifyHandle.Create( DesPath );
  LocalBackupDesModifyHandle.SetIsModify( Result );
  LocalBackupDesModifyHandle.Update;
  LocalBackupDesModifyHandle.Free;
end;

function TDesPathScanCheckHandle.CheckDriverExist: Boolean;
var
  DriverPath : string;
  LocalBackupDesExistHandle : TLocalBackupDesExistHandle;
begin
  DriverPath := ExtractFileDrive( DesPath );
  Result := DirectoryExists( DriverPath );

    // ����
  LocalBackupDesExistHandle := TLocalBackupDesExistHandle.Create( DesPath );
  LocalBackupDesExistHandle.SetIsExist( Result );
  LocalBackupDesExistHandle.Update;
  LocalBackupDesExistHandle.Free;

    // ����Ŀ¼
  if Result then
    ForceDirectories( DesPath );
end;

constructor TDesPathScanCheckHandle.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TDesPathScanCheckHandle.get: Boolean;
begin
  Result := False;

    // ������ ������
  if not CheckDriverExist then
    Exit;

    // Ŀ��·�� ����д��
  if not CheckDesModify then
    Exit;

    // ���� ȱС�ռ�
  ResetLackSpace;

    // ͨ�����
  Result := True;
end;

procedure TDesPathScanCheckHandle.ResetLackSpace;
var
  LocalBackupDesLackSpaceHandle : TLocalBackupDesLackSpaceHandle;
begin
  LocalBackupDesLackSpaceHandle := TLocalBackupDesLackSpaceHandle.Create( DesPath );
  LocalBackupDesLackSpaceHandle.SetIsLackSpace( False );
  LocalBackupDesLackSpaceHandle.Update;
  LocalBackupDesLackSpaceHandle.Free;
end;

{ TFolderRemoveHandle }

function TFolderRemoveHandle.CheckNextRemove: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // ����Ƿ��ж�
    Result := Result and MyLocalBackupDesReadUtil.getIsEnable( DesRootPath );
  end;

    // �����Ѿ� Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFolderRemoveHandle.Create(_DesFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
end;

procedure TFolderRemoveHandle.FolderRemove;
begin

end;

procedure TFolderRemoveHandle.SearchFile(FilePath: string);
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
begin
  FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( FilePath );
  FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
  FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
  FileCopyRemoveHandle.Update;
  FileCopyRemoveHandle.Free;
end;

procedure TFolderRemoveHandle.SearchFolder(FolderPath: string);
var
  FolderRemoveHandle : TFolderRemoveHandle;
begin
  FolderRemoveHandle := TFolderRemoveHandle.Create( FolderPath );
  FolderRemoveHandle.SetDesRootPath( DesRootPath );
  FolderRemoveHandle.SetSourceRootPath( SourceRootPath );
  FolderRemoveHandle.SetSleepCount( SleepCount );
  FolderRemoveHandle.Update;
  SleepCount := FolderRemoveHandle.SleepCount;
  FolderRemoveHandle.Free;
end;

procedure TFolderRemoveHandle.SetDesRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

procedure TFolderRemoveHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TFolderRemoveHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFolderRemoveHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextRemove then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( ChildPath )
      else
        SearchFile( ChildPath );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // Ŀ¼ɾ��
  FolderRemove;
end;

end.

