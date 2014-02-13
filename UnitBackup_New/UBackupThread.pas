unit UBackupThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, URegisterInfo, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp;

type

{$Region ' ���� ɨ�� ' }

  TRefreshSpeedInfo = class
  public
    SpeedTime : TDateTime;
    Speed : Int64;
  public
    constructor Create;
    function AddCompleted( CompletedSpace : Int64 ): Boolean;
    procedure ResetSpeed;
  end;

    // ɨ����Ϣ
  TScanPathInfo = class
  public
    SourcePath : string; // Դ·��
  public
    constructor Create( _SourcePath : string );
  end;
  TScanPathList = class( TObjectList<TScanPathInfo> )end;


    // �������ļ���Ϣ
  TScanFileInfo = class
  public
    FileName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getEquals( ScanFileInfo : TScanFileInfo ): Boolean;
  end;
  TScanFilePair = TPair< string , TScanFileInfo >;
  TScanFileHash = class( TStringDictionary< TScanFileInfo > );

  {$Region ' ɨ������Ϣ ' }

    // �ļ��ȽϽ��
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // ��� �ļ�
  TScanResultAddFileInfo = class( TScanResultInfo )
  end;

    // ��� Ŀ¼
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // ɾ�� �ļ�
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // ɾ�� Ŀ¼
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

  {$EndRegion}


    // Ŀ¼�Ƚ��㷨
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public
    IncludeFilterList : TFileFilterList;  // ����������
    ExcludeFilterList : TFileFilterList;  // �ų�������
  public   // �ļ���Ϣ
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // Ŀ¼��Ϣ
    SourceFolderHash : TStringHash;
    DesFolderHash : TStringHash;
  public   // �ռ���
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public
    constructor Create;
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
    destructor Destroy; override;
  protected
    procedure FindSourceFileInfo;
    procedure FindDesFileInfo;virtual;abstract;
    procedure FileCompare;
    procedure FolderCompare;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;virtual;
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;
    function IsFolderFilter( FolderPath : string ): Boolean;
  private        // �ȽϽ��
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // �Ƚ���Ŀ¼
    function getScanHandle : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // �ļ��Ƚ��㷨
  TFileScanHandle = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // �ռ���
    CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public
    constructor Create( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected
    procedure FindSourceFileInfo;
    function FindDesFileInfo: Boolean;virtual;abstract;
  private        // �ȽϽ��
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

{$EndRegion}


{$Region ' ���ر��� ɨ�� ' }

    // ����Ŀ¼
  TLocalFolderScanHandle = class( TFolderScanHandle )
  public
    DesRootPath, SourceRootPath : string;
  public
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle : TFolderScanHandle;override;
  end;

    // �����ļ�
  TLocalFileScanHandle = class( TFileScanHandle )
  public
    DesRootPath : string;
  public
    procedure SetRootPath( _DesRootPath : string );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���ر��� ����/ɾ�� ' }

    // ������
  FileRecycledUtil = class
  public
    class function getEditionPath( FilePath : string; EditionNum : Integer ): string;
  end;

    // Դ�ļ� ���ݸ���
  TLocalFileCopyHandle = class
  protected
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  protected
    RefreshSpeedInfo : TRefreshSpeedInfo;
  protected
    AddCompletedSpace : Int64;
    CopyTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;
  private
    function CheckNextCopy : Boolean; // ����Ƿ��������
    function getDesIsEnoughSpace : Boolean;  // ����Ƿ����㹻�Ŀռ�
  protected
    procedure RefreshCompletedSpace;virtual;
  end;

    // Ŀ���ļ� ���ո���
  TDesFileRecycleCopyHandle = class( TLocalFileCopyHandle )
  protected
    procedure RefreshCompletedSpace;override;
  end;

    // Ŀ���ļ� ����
  TDesFileRecycleHandle = class
  public
    DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    RecycledPath : string;
  public
    constructor Create( _DesFilePath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  private
    procedure CheckKeedEditionCount;
    procedure FileCopy;
    procedure FileRemove;
  private
    function getExistEditionCount : Integer;
  end;

    // Ŀ��Ŀ¼ ����
  TDesFolderRecycleHandle = class
  public
    DesFolderPath : string;
    DesRootPath, SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesFolderPath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRecycled : Boolean;
  end;

{$Endregion}

{$Region ' ���ر��� ���� ' }

    // ɨ����Ϣ
  TLocalScanPathInfo = class( TScanPathInfo )
  public
    DesPath : string;
  public
    procedure SetDesPath( _DesPath : string );
  end;

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

    // �������
  TLocalBackupResultHandle = class
  public
    SourcePath, DesPath : string;
    ScanResultInfo : TScanResultInfo;
    SourceFilePath, DesFilePath : string;
    IsRecycled : Boolean;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    constructor Create( _ScanResultInfo : TScanResultInfo );
    procedure SetRootPath( _DesPath, _SourcePath : string );
    procedure SetIsRecycled( _IsRecycled : Boolean );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;
  private         // ���
    procedure SourceFileAdd;
    procedure SourceFolderAdd;
  private         // ɾ��
    procedure DesFileRemove;
    procedure DesFolderRemove;
  private         // ����
    procedure DesFileRecycle;
    procedure DesFolderRecycle;
  end;

    // ����·������
  TLocalBackupHandle = class
  public
    LocalScanPathInfo : TLocalScanPathInfo;
    SourcePath, DesPath : string;
  public   // �ļ�ɨ����
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // �ļ��仯��Ϣ
    ScanResultList : TScanResultList;
  public
    constructor Create( _LocalScanPathInfo : TLocalScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private       // ����ǰ���
    function getSourcePathIsExist : Boolean;
    function getDesPathIsBackup: Boolean;
  private       // ɨ��
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace;
  private       // ����
    function getIsFreeLimit : Boolean;
    procedure ResetStartBackupFile;
    procedure BackupFileHandle;
  private       // �������
    procedure ResetBackupCompleted;
  end;

{$EndRegion}


{$Region ' ���籸�� ɨ�� ' }

    // ����Ŀ¼
  TNetworkFolderScanHandle = class( TFolderScanHandle )
  public
    SourceRootPath : string;
  public
    PcID : string;
    TcpSocket : TCustomIpClient;
  public
    procedure SetRootPath( _SourceRootPath : string );
    procedure SetPcInfo( _PcID : string; _TcpSocket : TCustomIpClient );
  protected       // Ŀ���ļ���Ϣ
    procedure FindDesFileInfo;override;
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;override;
  protected        // �Ƚ���Ŀ¼
    function getScanHandle : TFolderScanHandle;override;
  end;

    // �����ļ�
  TNetworkFileScanHandle = class( TFileScanHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' ���籸�� ����/ɾ�� ' }

    // Դ�ļ� ���ݸ���
  TNetworkFileCopyHandle = class
  protected
    SourFilePath : string;
    PcID, SourceRootPath : string;
    TcpSocket : TCustomIpClient;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  protected
    AddCompletedSpace : Int64;
    StartTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath : string );
    procedure SetRootPath( _SourceRootPath : string );
    procedure SetDesPcInfo( _PcID : string; _TcpSocket : TCustomIpClient );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
    procedure Update;
  private
    function CheckNextCopy : Boolean; // ����Ƿ��������
    procedure FileSend;
  protected
    procedure RefreshCompletedSpace;
  end;

{$EndRegion}

{$Region ' ���籸�� ���� ' }

    // ɨ����Ϣ
  TNetworkScanPathInfo = class( TScanPathInfo )
  public
    DesPcID : string;
  public
    procedure SetDesPcID( _DesPcID : string );
  end;

    // ����·������
  TNetworkBackupHandle = class
  public
    NetworkScanPathInfo : TNetworkScanPathInfo;
    SourcePath, DesPcID : string;
  public
    TcpSocket : TCustomIpClient;
  public   // �ļ�ɨ����
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // �ļ��仯��Ϣ
    ScanResultList : TScanResultList;
  public
    constructor Create( _NetworkScanPathInfo : TNetworkScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private       // ����ǰ���
    function getSourcePathIsExist : Boolean;
    function getDesPcIsBackup: Boolean;
  private       // ɨ��
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace;
  private       // ����
    function getIsFreeLimit : Boolean;
    procedure ResetStartBackupFile;
    procedure BackupFileHandle;
    procedure BackupFileAddHandle( FilePath : string );
  private       // �������
    procedure ResetBackupCompleted;
  end;


{$EndRegion}


    // ԴĿ¼ ɨ��
    // Ŀ��Ŀ¼ ����/ɾ��
  TBackupHandleThread = class( TThread )
  private
    PathLock : TCriticalSection;
    ScanPathList : TScanPathList;
  private
    IsShowFreeLimitError : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // ɨ��
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    function getScanPathInfo : TScanPathInfo;
    procedure BackupHandle( ScanPathInfo : TScanPathInfo );
  private
    procedure CheckFreeLimit;
    procedure ShowFreeLimitWarnning;
  private
    procedure BackupCompleted;
  end;

    // ���ر��� Դ·�� ɨ��͸���
  TMyBackupHandler = class
  private
    LocalBackupThread : TBackupHandleThread;
  public
    IsRun : Boolean;
  public
    constructor Create;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    procedure ShowFreeLimitError;
    procedure StopScan;
  end;

const
  ScanCount_Sleep = 30;
  CopyCount_Sleep = 10;
  LocalBackup_RecycledFolder = 'Recycled';

  FileReq_End = '-1';
  FileReq_File = '0';
  FileReq_Folder = '1';

  FileBackup_End = '-1';
  FileBackup_AddFile = '0';
  FileBackup_AddFolder = '1';
  FileBackup_RemoveFile = '2';
  FileBackup_RemoveFolder = '3';

var
  ScanSource_IsCompleted : Boolean = False;

var
    // Դ·�� ɨ���߳�
  MyBackupHandler : TMyBackupHandler;

implementation

uses UMyBackupApiInfo, UMyBackupDataInfo, UMyNetPcInfo, UMyBackupEventInfo;

{ TFileCopyHandle }

function TLocalFileCopyHandle.getDesIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  Result := True;
  FreeSize := MyHardDisk.getHardDiskFreeSize( DesRootPath );

    // �Ƿ����㹻�Ŀռ�
  if FreeSize >= MyFileInfo.getFileSize( SourFilePath ) then
    Exit;

    // ȱ�ٿռ�
  DesItemAppApi.setIsLackSpace( DesRootPath, True );

  Result := False;
end;

function TLocalFileCopyHandle.CheckNextCopy: Boolean;
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
  if SecondsBetween( Now, CopyTime ) >= 1 then
  begin
      // ˢ�½���
    RefreshCompletedSpace;

      // ��� �Ƿ񱸷��ж�
    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
    CopyTime := Now;
  end;

    // �����Ѿ� Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TLocalFileCopyHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
  SleepCount := 0;
  AddCompletedSpace := 0;
  CopyTime := Now;
end;

procedure TLocalFileCopyHandle.RefreshCompletedSpace;
begin
    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // ���� ˢ�±����ٶ�
    BackupItemAppApi.SetSpeed( DesRootPath, SourceRootPath, RefreshSpeedInfo.Speed );
    RefreshSpeedInfo.ResetSpeed;
  end;

    // ���� ����ɿռ�
  BackupItemAppApi.AddBackupCompletedSpace( DesRootPath, SourceRootPath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TLocalFileCopyHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TLocalFileCopyHandle.SetSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TLocalFileCopyHandle.Update;
var
  SourFileStream, DesFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SourceFileTime : TDateTime;
begin
    // Դ�ļ�������
  if not FileExists( SourFilePath ) then
    Exit;

    // Ŀ��·��û���㹻�Ŀռ�
  if not getDesIsEnoughSpace then
    Exit;

    // �ļ���
  try
    SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );
    ForceDirectories( ExtractFileDir( DesFilePath ) );
    DesFileStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );

    FullBufSize := SizeOf( Buf );
    RemainSize := SourFileStream.Size;
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
      AddCompletedSpace := AddCompletedSpace + BufSize;
    end;

      // �������ɿռ�
    RefreshCompletedSpace;

    DesFileStream.Free;
    SourFileStream.Free;

      // �����޸�ʱ��
    SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
    MyFileSetTime.SetTime( DesFilePath, SourceFileTime );
  except
  end;
end;

{ TLocalBackupSourceScanThread }

procedure TBackupHandleThread.AddScanPathInfo(
  ScanPathInfo : TScanPathInfo);
begin
  PathLock.Enter;
  ScanPathList.Add( ScanPathInfo );
  PathLock.Leave;

  Resume;
end;

procedure TBackupHandleThread.CheckFreeLimit;
begin
    // �����ð�, ����
  if not RegisterInfo.getIsFreeEdition then
    Exit;

    // �����������
  if IsShowFreeLimitError and
     ( DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace )
  then
    ShowFreeLimitWarnning; // ��ʾ��������

  IsShowFreeLimitError := False;
end;

constructor TBackupHandleThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  ScanPathList := TScanPathList.Create;
  ScanPathList.OwnsObjects := False;
  IsShowFreeLimitError := False;
end;

destructor TBackupHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  ScanPathList.OwnsObjects := True;
  ScanPathList.Free;
  PathLock.Free;

  inherited;
end;

procedure TBackupHandleThread.Execute;
var
  ScanPathInfo : TScanPathInfo;
begin
  while not Terminated do
  begin
    ScanPathInfo := getScanPathInfo;
    if ScanPathInfo = nil then
    begin
      CheckFreeLimit; // ����Ƿ񳬹���������
      if not Terminated then
      begin
        Suspend;
        Continue;
      end;
    end;

    BackupHandle( ScanPathInfo );  // ɨ��·��

    ScanPathInfo.Free;
  end;
  inherited;
end;

function TBackupHandleThread.getScanPathInfo: TScanPathInfo;
begin
  PathLock.Enter;
  if ScanPathList.Count > 0 then
  begin
    Result := ScanPathList[0];
    ScanPathList.Delete(0);
  end
  else
    Result := nil;
  PathLock.Leave;
end;

procedure TBackupHandleThread.BackupHandle(ScanPathInfo: TScanPathInfo);
var
  LocalScanPathHandle : TLocalBackupHandle;
  NetworkBackupHandle : TNetworkBackupHandle;
begin
  if ScanPathInfo is TLocalScanPathInfo then
  begin
    LocalScanPathHandle := TLocalBackupHandle.Create( ScanPathInfo as TLocalScanPathInfo );
    LocalScanPathHandle.Update;
    LocalScanPathHandle.Free;
  end
  else
  if ScanPathInfo is TNetworkScanPathInfo then
  begin
    NetworkBackupHandle := TNetworkBackupHandle.Create( ScanPathInfo as TNetworkScanPathInfo );
    NetworkBackupHandle.Update;
    NetworkBackupHandle.Free;
  end;
end;

procedure TBackupHandleThread.ShowFreeLimitWarnning;
var
  ShowFreeEditionWarnning : TShowFreeEditionWarnning;
begin
  ShowFreeEditionWarnning := TShowFreeEditionWarnning.Create( FreeEditionError_BackupSpace );
  MyMainFormFace.AddChange( ShowFreeEditionWarnning );
end;

procedure TBackupHandleThread.BackupCompleted;
begin

end;


{ TScanPathInfo }

constructor TScanPathInfo.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

{ TMyLocalBackupSourceScanner }

procedure TMyBackupHandler.AddScanPathInfo(
  ScanPathInfo: TScanPathInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddScanPathInfo( ScanPathInfo );
end;

constructor TMyBackupHandler.Create;
begin
  LocalBackupThread := TBackupHandleThread.Create;
  IsRun := True;
end;

procedure TMyBackupHandler.ShowFreeLimitError;
begin
  LocalBackupThread.IsShowFreeLimitError := True;
end;

procedure TMyBackupHandler.StopScan;
begin
  IsRun := False;
  LocalBackupThread.Free;
end;


{ TScanPathHandle }

destructor TLocalBackupHandle.Destroy;
begin
  ScanResultList.Free;
  inherited;
end;

function TLocalBackupHandle.getDesPathIsBackup: Boolean;
var
  DesPathScanCheckHandle : TDesPathScanCheckHandle;
begin
  DesPathScanCheckHandle := TDesPathScanCheckHandle.Create( DesPath );
  Result := DesPathScanCheckHandle.get;
  DesPathScanCheckHandle.Free;
end;

function TLocalBackupHandle.getIsFreeLimit: Boolean;
begin
  Result := DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace;
end;

function TLocalBackupHandle.getSourcePathIsExist: Boolean;
begin
  Result := MyFilePath.getIsExist( SourcePath );

    // ���� �Ƿ���ڱ���·��
  BackupItemAppApi.SetIsExist( DesPath, SourcePath, Result );
end;

procedure TLocalBackupHandle.BackupFileHandle;
var
  IsRecycled : Boolean;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  i : Integer;
  ScanResultInfo : TScanResultInfo;
  LocalBackupResultHandle : TLocalBackupResultHandle;
begin
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  IsRecycled := BackupItemInfoReadUtil.ReadIsKeepDeleted( DesPath, SourcePath );
  for i := 0 to ScanResultList.Count - 1 do
  begin
    ScanResultInfo := ScanResultList[i];
    LocalBackupResultHandle := TLocalBackupResultHandle.Create( ScanResultInfo );
    LocalBackupResultHandle.SetRootPath( DesPath, SourcePath );
    LocalBackupResultHandle.SetIsRecycled( IsRecycled );
    LocalBackupResultHandle.SetSpeedInfo( RefreshSpeedInfo );
    LocalBackupResultHandle.Update;
    LocalBackupResultHandle.Free;
  end;
  RefreshSpeedInfo.Free;
end;

constructor TLocalBackupHandle.Create(_LocalScanPathInfo: TLocalScanPathInfo);
begin
  LocalScanPathInfo := _LocalScanPathInfo;
  SourcePath := LocalScanPathInfo.SourcePath;
  DesPath := LocalScanPathInfo.DesPath;
  ScanResultList := TScanResultList.Create;
end;

procedure TLocalBackupHandle.ResetBackupCompleted;
var
  Params : TLocalBackupEventParam;
begin
    // ɨ�����
  BackupItemAppApi.SetBackupCompleted( DesPath, SourcePath );

    // �����¼�
  Params.DesPath := DesPath;
  Params.SourcePath := SourcePath;
  Params.IsFile := FileExists( SourcePath );
  Params.FileCount := TotalCount;
  Params.FileSpce := TotalSize;
  LocalBackupEvent.BackupCompleted( Params );
end;

procedure TLocalBackupHandle.ResetSourcePathSpace;
begin
    // ���һ�� ��ʾɨ���ļ���
  BackupItemAppApi.SetScaningCount( DesPath, SourcePath, TotalCount );

    // ���� Դ·���ռ�
  BackupItemAppApi.SetSpaceInfo( DesPath, SourcePath, TotalCount, TotalSize, TotalCompleted );
end;

procedure TLocalBackupHandle.ResetStartBackupFile;
begin
  BackupItemAppApi.SetStartBackup( DesPath, SourcePath );
end;

procedure TLocalBackupHandle.ScanFileHandle;
var
  LocalFileScanHandle : TLocalFileScanHandle;
begin
  LocalFileScanHandle := TLocalFileScanHandle.Create( SourcePath );
  LocalFileScanHandle.SetRootPath( DesPath );
  LocalFileScanHandle.SetResultList( ScanResultList );
  LocalFileScanHandle.Update;
  TotalSize := LocalFileScanHandle.SourceFileSize;
  TotalCount := 1;
  TotalCompleted := LocalFileScanHandle.CompletedSize;
  LocalFileScanHandle.Free;
end;

procedure TLocalBackupHandle.ScanFolderHandle;
var
  IncludeFilterList : TFileFilterList;  // ����������
  ExcludeFilterList : TFileFilterList;  // �ų�������
  LocalFolderScanHandle : TLocalFolderScanHandle;
begin
  IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesPath, SourcePath );
  ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesPath, SourcePath );

  LocalFolderScanHandle := TLocalFolderScanHandle.Create;
  LocalFolderScanHandle.SetSourceFolderPath( SourcePath );
  LocalFolderScanHandle.SetRootPath( DesPath, SourcePath );
  LocalFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalFolderScanHandle.SetResultList( ScanResultList );
  LocalFolderScanHandle.Update;
  TotalSize := LocalFolderScanHandle.FileSize;
  TotalCount := LocalFolderScanHandle.FileCount;
  TotalCompleted := LocalFolderScanHandle.CompletedSize;
  LocalFolderScanHandle.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

procedure TLocalBackupHandle.ScanPathHandle;
begin
    // ɨ�� �����ļ�
  if FileExists( SourcePath ) then
    ScanFileHandle
  else   // ɨ�� ����Ŀ¼
    ScanFolderHandle;
end;

procedure TLocalBackupHandle.Update;
begin
    // Դ·��������, ��ɨ��
  if not getSourcePathIsExist then
    Exit;

    // Ŀ��·���޷����ݣ���ɨ��
  if not getDesPathIsBackup then
    Exit;

    // ɨ��·��
  ScanPathHandle;
  ResetSourcePathSpace; // ����·���ռ���Ϣ

    // ����·��
  if not getIsFreeLimit then  // �Ƿ��ܵ����ð�����
  begin
    ResetStartBackupFile;
    BackupFileHandle;
  end;

    // ���� �ϴ�ͬ��ʱ��
  ResetBackupCompleted;
end;


{ TFileRecycledHandle }

procedure TDesFileRecycleHandle.CheckKeedEditionCount;
var
  KeepEditionCount : Integer;
  ExistEditionCount : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
  KeepEditionCount := BackupItemInfoReadUtil.ReadIsKeepEditionCount( DesRootPath, SourceRootPath );
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

constructor TDesFileRecycleHandle.Create(_DesFilePath: string);
begin
  DesFilePath := _DesFilePath;
end;

procedure TDesFileRecycleHandle.FileCopy;
var
  CopySourcePath, CopyDesPath : string;
  FileRecycledHandle : TDesFileRecycleCopyHandle;
begin
  CopySourcePath := DesFilePath;
  CopyDesPath := RecycledPath;

  FileRecycledHandle := TDesFileRecycleCopyHandle.Create( CopySourcePath, CopyDesPath );
  FileRecycledHandle.SetRootPath( DesRootPath, SourceRootPath );
  FileRecycledHandle.Update;
  FileRecycledHandle.Free;
end;

procedure TDesFileRecycleHandle.FileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

function TDesFileRecycleHandle.getExistEditionCount: Integer;
begin
  Result := 0;
  if not FileExists( RecycledPath ) then
    Exit;
  Inc( Result );

  while FileExists( FileRecycledUtil.getEditionPath( RecycledPath, Result ) ) do
    Inc( Result );
end;

procedure TDesFileRecycleHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TDesFileRecycleHandle.Update;
begin
    // ���� �����ļ������·��
  RecycledPath := MyString.CutStartStr( DesRootPath, DesFilePath );
  RecycledPath := MyFilePath.getPath( DesRootPath ) + LocalBackup_RecycledFolder + RecycledPath;

    // ��鱣��İ汾��
  CheckKeedEditionCount;

    // �ļ�����
  FileCopy;

    // �ļ�ɾ��
  FileRemove;
end;

{ TFileRecycledHandle }

procedure TDesFileRecycleCopyHandle.RefreshCompletedSpace;
begin
end;

{ TFolderRecycleHandle }

function TDesFolderRecycleHandle.CheckNextRecycled: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
  end;

    // �����Ѿ� Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TDesFolderRecycleHandle.Create(_DesFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
  SleepCount := 0;
end;

procedure TDesFolderRecycleHandle.FolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TDesFolderRecycleHandle.SearchFile(FilePath: string);
var
  FileRecycledAddHandle : TDesFileRecycleHandle;
begin
  FileRecycledAddHandle := TDesFileRecycleHandle.Create( FilePath );
  FileRecycledAddHandle.SetRootPath( DesRootPath, SourceRootPath );
  FileRecycledAddHandle.Update;
  FileRecycledAddHandle.Free;
end;

procedure TDesFolderRecycleHandle.SearchFolder(FolderPath: string);
var
  FolderRecycleHandle : TDesFolderRecycleHandle;
begin
  FolderRecycleHandle := TDesFolderRecycleHandle.Create( FolderPath );
  FolderRecycleHandle.SetRootPath( DesRootPath, SourceRootPath );
  FolderRecycleHandle.SetSleepCount( SleepCount );
  FolderRecycleHandle.Update;
  SleepCount := FolderRecycleHandle.SleepCount;
  FolderRecycleHandle.Free;
end;

procedure TDesFolderRecycleHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TDesFolderRecycleHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TDesFolderRecycleHandle.Update;
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
begin
  Result := MyFilePath.getIsModify( DesPath );

    // ���� �Ƿ��д Ŀ��·��
  DesItemAppApi.SetIsWrite( DesPath, Result );
end;

function TDesPathScanCheckHandle.CheckDriverExist: Boolean;
var
  DriverPath : string;
begin
  DriverPath := ExtractFileDrive( DesPath );
  Result := DirectoryExists( DriverPath );

    // ���� �Ƿ���� Ŀ��·��
  DesItemAppApi.SetIsExist( DesPath, Result );

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
begin
  DesItemAppApi.SetIsLackSpace( DesPath, False );
end;

{ TScanFileInfo }

constructor TScanFileInfo.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TScanFileInfo.getEquals(ScanFileInfo: TScanFileInfo): Boolean;
begin
  Result := ( ScanFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( FileTime, ScanFileInfo.FileTime ) );
end;

procedure TScanFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TFolderCompareHandle }

procedure TFolderScanHandle.AddFileResult(FileName : string);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

procedure TFolderScanHandle.AddFolderResult(FolderName: string);
var
  ScanResultAddFolderInfo : TScanResultAddFolderInfo;
begin
  ScanResultAddFolderInfo := TScanResultAddFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultAddFolderInfo );
end;

function TFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := True;

    // N ���ļ�Сͣһ��
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TFolderScanHandle.CompareChildFolder(SourceFolderName: string);
var
  ChildFolderPath : string;
  FolderScanHandle : TFolderScanHandle;
begin
  ChildFolderPath := MyFilePath.getPath( SourceFolderPath ) + SourceFolderName;
  FolderScanHandle := getScanHandle;
  FolderScanHandle.SetSourceFolderPath( ChildFolderPath );
  FolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  FolderScanHandle.SetResultList( ScanResultList );
  FolderScanHandle.FileCount := FileCount;
  FolderScanHandle.FileSize := FileSize;
  FolderScanHandle.CompletedSize := CompletedSize;
  FolderScanHandle.SleepCount := SleepCount;
  FolderScanHandle.ScanTime := ScanTime;
  FolderScanHandle.Update;
  FileCount := FolderScanHandle.FileCount;
  FileSize := FolderScanHandle.FileSize;
  CompletedSize := FolderScanHandle.CompletedSize;
  SleepCount := FolderScanHandle.SleepCount;
  ScanTime := FolderScanHandle.ScanTime;
  FolderScanHandle.Free;
end;

constructor TFolderScanHandle.Create;
begin
  SourceFileHash := TScanFileHash.Create;
  DesFileHash := TScanFileHash.Create;
  SourceFolderHash := TStringHash.Create;
  DesFolderHash := TStringHash.Create;
  FileCount := 0;
  FileSize := 0;
  CompletedSize := 0;
  SleepCount := 0;
  ScanTime := Now;
end;

destructor TFolderScanHandle.Destroy;
begin
  SourceFileHash.Free;
  DesFileHash.Free;
  SourceFolderHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TFolderScanHandle.FileCompare;
var
  p : TScanFilePair;
  FileName : string;
begin
    // ���� Դ�ļ�
  for p in SourceFileHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextScan then
      Break;

      // ��ӵ�ͳ����Ϣ
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

    FileName := p.Value.FileName;

      // Ŀ���ļ�������
    if not DesFileHash.ContainsKey( FileName ) then
    begin
      AddFileResult( FileName );
      Continue;
    end;

      // Ŀ���ļ���Դ�ļ���һ��
    if not p.Value.getEquals( DesFileHash[ FileName ] ) then
    begin
      RemoveFileResult( FileName ); // ��ɾ��
      AddFileResult( FileName );  // �����
    end
    else  // Ŀ���ļ���Դ�ļ�һ��
      CompletedSize := CompletedSize + p.Value.FileSize;

      // ɾ��Ŀ���ļ�
    DesFileHash.Remove( FileName );
  end;

    // ����Ŀ���ļ�
  for p in DesFileHash do
    RemoveFileResult( p.Value.FileName );  // ɾ��Ŀ���ļ�
end;

procedure TFolderScanHandle.FindSourceFileInfo;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  SourceScanFileInfo : TScanFileInfo;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( SourceFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // �ļ�������
        Continue;

        // ��ӵ�Ŀ¼���
      if IsFolder then
        SourceFolderHash.AddString( FileName )
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��ӵ��ļ����������
        SourceScanFileInfo := TScanFileInfo.Create( FileName );
        SourceScanFileInfo.SetFileInfo( FileSize, FileTime );
        SourceFileHash.AddOrSetValue( FileName, SourceScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TStringPart;
  FolderName : string;
begin
    // ����ԴĿ¼
  for p in SourceFolderHash do
  begin
    FolderName := p.Value;

      // ������Ŀ��Ŀ¼���򴴽�
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName )
    else
      DesFolderHash.Remove( FolderName );

      // �Ƚ���Ŀ¼
    CompareChildFolder( FolderName );
  end;

    // ����Ŀ��Ŀ¼
  for p in DesFolderHash do
    RemoveFolderResult( p.Value );
end;

function TFolderScanHandle.getChildPath(ChildName: string): string;
begin
  Result := MyFilePath.getPath( SourceFolderPath ) + ChildName;
end;

function TFolderScanHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := True;

    // ���ڰ����б���
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TFolderScanHandle.IsFolderFilter(FolderPath: string): Boolean;
begin
  Result := True;

    // ���ڰ����б���
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // ���ų��б���
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

procedure TFolderScanHandle.RemoveFileResult(FileName : string);
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFolderScanHandle.RemoveFolderResult(FolderName: string);
var
  ScanResultRemoveFolderInfo : TScanResultRemoveFolderInfo;
begin
  ScanResultRemoveFolderInfo := TScanResultRemoveFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultRemoveFolderInfo );
end;

procedure TFolderScanHandle.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TFolderScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFolderScanHandle.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TFolderScanHandle.Update;
begin
    // ��Դ�ļ���Ϣ
  FindSourceFileInfo;

    // ��Ŀ���ļ���Ϣ
  FindDesFileInfo;

    // �ļ��Ƚ�
  FileCompare;

    // Ŀ¼�Ƚ�
  FolderCompare;
end;

{ TScanResultInfo }

constructor TScanResultInfo.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TFileScanHandle }

procedure TFileScanHandle.AddFileResult;
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

constructor TFileScanHandle.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
  CompletedSize := 0;
end;

procedure TFileScanHandle.FindSourceFileInfo;
begin
  SourceFileSize := MyFileInfo.getFileSize( SourceFilePath );
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );
end;

function TFileScanHandle.IsEqualsDes: Boolean;
begin
  Result := ( SourceFileSize = DesFileSize ) and
            ( MyDatetime.Equals( SourceFileTime, DesFileTime ) );
end;

procedure TFileScanHandle.RemoveFileResult;
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFileScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFileScanHandle.Update;
begin
    // Դ�ļ���Ϣ
  FindSourceFileInfo;

    // Ŀ���ļ�������
  if not FindDesFileInfo then
  begin
    AddFileResult;
    Exit;
  end;

    // Ŀ���ļ���Դ�ļ���һ��
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
    CompletedSize := SourceFileSize;
end;

{ TLocalFolderScanHandle }

function TLocalFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited;

    // 1 ���� ���һ��
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // ��ʾɨ���ļ���
    BackupItemAppApi.SetScaningCount( DesRootPath, SourceRootPath, FileCount );

      // ����Ƿ��жϱ���
    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
    ScanTime := Now;
  end;

    // ���� �Ƿ����ɨ��
  Result := Result and MyBackupHandler.IsRun;
end;

procedure TLocalFolderScanHandle.FindDesFileInfo;
var
  DesFolderPath : string;
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  DesScanFileInfo : TScanFileInfo;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  DesFolderPath := MyFilePath.getPath( DesRootPath ) + MyFilePath.getDownloadPath( SourceFolderPath );
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // ����ļ�����
      ChildPath := SearcFullPath + FileName;

        // ��ӵ�Ŀ¼���
      if DirectoryExists( ChildPath ) then
        DesFolderHash.AddString( FileName )
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��ӵ��ļ����������
        DesScanFileInfo := TScanFileInfo.Create( FileName );
        DesScanFileInfo.SetFileInfo( FileSize, FileTime );
        DesFileHash.Add( FileName, DesScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

function TLocalFolderScanHandle.getScanHandle: TFolderScanHandle;
var
  LocalFolderScanHandle : TLocalFolderScanHandle;
begin
  LocalFolderScanHandle := TLocalFolderScanHandle.Create;
  LocalFolderScanHandle.SetRootPath( DesRootPath, SourceRootPath );
  Result := LocalFolderScanHandle;
end;

procedure TLocalFolderScanHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

{ TLocalFileScanHandle }

function TLocalFileScanHandle.FindDesFileInfo: Boolean;
var
  DesFilePath : string;
begin
  DesFilePath := MyFilePath.getPath( DesRootPath ) + MyFilePath.getDownloadPath( SourceFilePath );
  Result := FileExists( DesFilePath );
  if not Result then
    Exit;
  DesFileSize := MyFileInfo.getFileSize( DesFilePath );
  DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );
end;

procedure TLocalFileScanHandle.SetRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

{ TLocalBackupResultHandle }

constructor TLocalBackupResultHandle.Create(_ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
end;

procedure TLocalBackupResultHandle.DesFileRecycle;
var
  DesFileRecycleHandle : TDesFileRecycleHandle;
begin
  DesFileRecycleHandle := TDesFileRecycleHandle.Create( DesFilePath );
  DesFileRecycleHandle.SetRootPath( DesPath, SourcePath );
  DesFileRecycleHandle.Update;
  DesFileRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

procedure TLocalBackupResultHandle.DesFolderRecycle;
var
  DesFolderRecycleHandle : TDesFolderRecycleHandle;
begin
  DesFolderRecycleHandle := TDesFolderRecycleHandle.Create( DesFilePath );
  DesFolderRecycleHandle.SetRootPath( DesPath, SourcePath );
  DesFolderRecycleHandle.Update;
  DesFolderRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFilePath );
end;

procedure TLocalBackupResultHandle.SetIsRecycled(_IsRecycled: Boolean);
begin
  IsRecycled := _IsRecycled;
end;

procedure TLocalBackupResultHandle.SetRootPath(_DesPath, _SourcePath : string);
begin
  DesPath := _DesPath;
  SourcePath := _SourcePath;
end;

procedure TLocalBackupResultHandle.SetSpeedInfo(_RefreshSpeedInfo : TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TLocalBackupResultHandle.SourceFileAdd;
var
  FileCopyHandle : TLocalFileCopyHandle;
begin
  FileCopyHandle := TLocalFileCopyHandle.Create( SourceFilePath, DesFilePath );
  FileCopyHandle.SetRootPath( DesPath, SourcePath );
  FileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

procedure TLocalBackupResultHandle.SourceFolderAdd;
begin
  ForceDirectories( DesFilePath );
end;

procedure TLocalBackupResultHandle.Update;
begin
  SourceFilePath := ScanResultInfo.SourceFilePath;
  DesFilePath := MyFilePath.getPath( DesPath ) + MyFilePath.getDownloadPath( SourceFilePath );
  if ScanResultInfo is TScanResultAddFileInfo then
    SourceFileAdd
  else
  if ScanResultInfo is TScanResultAddFolderInfo then
    SourceFolderAdd
  else
  if ScanResultInfo is TScanResultRemoveFileInfo then
  begin
    if IsRecycled then
      DesFileRecycle
    else
      DesFileRemove
  end
  else
  if ScanResultInfo is TScanResultRemoveFolderInfo then
  begin
    if IsRecycled then
      DesFolderRecycle
    else
      DesFolderRemove;
  end;
end;

{ TNetworkFolderScanHandle }

function TNetworkFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited;
end;

procedure TNetworkFolderScanHandle.FindDesFileInfo;
var
  FileReq : string;
  FileName : string;
  FileSize : Int64;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
begin
  MySocketUtil.SendString( TcpSocket, SourceFolderPath );
  while True do
  begin
    FileReq := MySocketUtil.RevString( TcpSocket );
    if ( FileReq = FileReq_End ) or ( FileReq = '' ) then // ����
      Break;
    FileName := MySocketUtil.RevString( TcpSocket );
    if FileReq = FileReq_File then  // �ļ�
    begin
      FileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), 0 );
      FileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), Now );
      ScanFileInfo := TScanFileInfo.Create( FileName );
      ScanFileInfo.SetFileInfo( FileSize, FileTime );
      DesFileHash.AddOrSetValue( FileName, ScanFileInfo );
    end
    else  // Ŀ¼
    if FileReq = FileReq_Folder then
      DesFolderHash.AddString( FileName );
  end;
end;

function TNetworkFolderScanHandle.getScanHandle: TFolderScanHandle;
var
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
begin
  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetRootPath( SourceRootPath );
  NetworkFolderScanHandle.SetPcInfo( PcID, TcpSocket );
  Result := NetworkFolderScanHandle;
end;

procedure TNetworkFolderScanHandle.SetPcInfo(_PcID: string;
  _TcpSocket: TCustomIpClient);
begin
  PcID := _PcID;
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderScanHandle.SetRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;



{ TLocalScanPathInfo }

procedure TLocalScanPathInfo.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TNetworkScanPathInfo }

procedure TNetworkScanPathInfo.SetDesPcID(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

{ TNetworkBackupHandle }

procedure TNetworkBackupHandle.BackupFileAddHandle( FilePath : string );
var
  NetworkFileCopyHandle : TNetworkFileCopyHandle;
begin
  NetworkFileCopyHandle := TNetworkFileCopyHandle.Create( FilePath );
  NetworkFileCopyHandle.SetRootPath( SourcePath );
  NetworkFileCopyHandle.SetDesPcInfo( DesPcID, TcpSocket );
  NetworkFileCopyHandle.Update;
  NetworkFileCopyHandle.Free;
end;

procedure TNetworkBackupHandle.BackupFileHandle;
var
  i: Integer;
  ScanResultInfo : TScanResultInfo;
  FileBackupType : string;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  NetworkFileCopyHandle : TNetworkFileCopyHandle;
begin
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    ScanResultInfo := ScanResultList[i];
    if ScanResultInfo is TScanResultAddFileInfo then
      FileBackupType := FileBackup_AddFile
    else
    if ScanResultInfo is TScanResultAddFolderInfo then
      FileBackupType := FileBackup_AddFolder
    else
    if ScanResultInfo is TScanResultRemoveFileInfo then
      FileBackupType := FileBackup_RemoveFile
    else
    if ScanResultInfo is TScanResultRemoveFolderInfo then
      FileBackupType := FileBackup_RemoveFolder;

      // ���͸� Ŀ��Pc ����
    MySocketUtil.SendString( TcpSocket, FileBackupType );
    MySocketUtil.SendString( TcpSocket, ScanResultInfo.SourceFilePath );
    if FileBackupType = FileBackup_AddFile then
    begin
      NetworkFileCopyHandle := TNetworkFileCopyHandle.Create( ScanResultInfo.SourceFilePath );
      NetworkFileCopyHandle.SetRootPath( SourcePath );
      NetworkFileCopyHandle.SetDesPcInfo( DesPcID, TcpSocket );
      NetworkFileCopyHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
      NetworkFileCopyHandle.Update;
      NetworkFileCopyHandle.Free;
    end;
  end;
  MySocketUtil.SendString( TcpSocket, FileBackup_End );
  RefreshSpeedInfo.Free;
end;

constructor TNetworkBackupHandle.Create(
  _NetworkScanPathInfo: TNetworkScanPathInfo);
begin
  NetworkScanPathInfo := _NetworkScanPathInfo;
  SourcePath := NetworkScanPathInfo.SourcePath;
  DesPcID := NetworkScanPathInfo.DesPcID;
  ScanResultList := TScanResultList.Create;
  TcpSocket := TCustomIpClient.Create( nil );
end;


destructor TNetworkBackupHandle.Destroy;
begin
  TcpSocket.Free;
  ScanResultList.Free;
  inherited;
end;

function TNetworkBackupHandle.getDesPcIsBackup: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
begin
  Result := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );
  if not Result then
    Exit;

    // ��ȡ Ŀ�� Pc �˿�
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // ���� Ŀ�� Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_NetworkBackup );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;
end;

function TNetworkBackupHandle.getIsFreeLimit: Boolean;
begin
  Result := DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace;
end;

function TNetworkBackupHandle.getSourcePathIsExist: Boolean;
begin
  Result := MyFilePath.getIsExist( SourcePath );
  BackupItemAppApi.SetIsExist( DesPcID, SourcePath, Result );
end;

procedure TNetworkBackupHandle.ResetBackupCompleted;
var
  Params : TBackupCompletedEventParam;
begin
  BackupItemAppApi.SetBackupCompleted( DesPcID, SourcePath );

  Params.PcID := DesPcID;
  Params.SourcePath := SourcePath;
  Params.IsFile := FileExists( SourcePath );
  Params.FileCount := TotalCount;
  Params.FileSpce := TotalSize;

  NetworkBackupEvent.BackupCompleted( Params );
end;

procedure TNetworkBackupHandle.ResetSourcePathSpace;
begin
  BackupItemAppApi.SetSpaceInfo( DesPcID, SourcePath, TotalCount, TotalSize, TotalCompleted );
end;

procedure TNetworkBackupHandle.ResetStartBackupFile;
begin
  BackupItemAppApi.SetStartBackup( DesPcID, SourcePath );
end;

procedure TNetworkBackupHandle.ScanFileHandle;
var
  NetworkFileScanHandle : TNetworkFileScanHandle;
begin
  NetworkFileScanHandle := TNetworkFileScanHandle.Create( SourcePath );
  NetworkFileScanHandle.SetTcpSocket( TcpSocket );
  NetworkFileScanHandle.SetResultList( ScanResultList );
  NetworkFileScanHandle.Update;
  TotalCount := 1;
  TotalSize := NetworkFileScanHandle.SourceFileSize;
  TotalCompleted := NetworkFileScanHandle.CompletedSize;
  NetworkFileScanHandle.Free;
end;

procedure TNetworkBackupHandle.ScanFolderHandle;
var
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
  IncludeFilterList : TFileFilterList;  // ����������
  ExcludeFilterList : TFileFilterList;  // �ų�������
begin
  IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesPcID, SourcePath );
  ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesPcID, SourcePath );

  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetRootPath( SourcePath );
  NetworkFolderScanHandle.SetPcInfo( DesPcID, TcpSocket );
  NetworkFolderScanHandle.SetSourceFolderPath( SourcePath );
  NetworkFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  NetworkFolderScanHandle.SetResultList( ScanResultList );
  NetworkFolderScanHandle.Update;
  TotalCount := NetworkFolderScanHandle.FileCount;
  TotalSize := NetworkFolderScanHandle.FileSize;
  TotalCompleted := NetworkFolderScanHandle.CompletedSize;
  NetworkFolderScanHandle.Free;

  ExcludeFilterList.Free;
  IncludeFilterList.Free;

  TcpSocket.Sendln( FileReq_End );
end;

procedure TNetworkBackupHandle.ScanPathHandle;
var
  IsFile : Boolean;
begin
  IsFile := FileExists( SourcePath );

    // ���ͱ��� PcID
  TcpSocket.Sendln( PcInfo.PcID );
  TcpSocket.Sendln( BoolToStr( IsFile ) );

    // ɨ��Ŀ¼
  if IsFile then
    ScanFileHandle
  else
    ScanFolderHandle;
end;

procedure TNetworkBackupHandle.Update;
begin
    // Դ·��������, ��ɨ��
  if not getSourcePathIsExist then
    Exit;

    // Ŀ��Pc���ߣ���ɨ��
  if not getDesPcIsBackup then
    Exit;

    // ɨ��·��
  ScanPathHandle;
  ResetSourcePathSpace; // ����·���ռ���Ϣ

    // ����·��
  if not getIsFreeLimit then  // �Ƿ��ܵ����ð�����
  begin
    ResetStartBackupFile;
    BackupFileHandle;
  end;

    // ���� �ϴ�ͬ��ʱ��
  ResetBackupCompleted;
end;

{ TNetworkFileScanHandle }

function TNetworkFileScanHandle.FindDesFileInfo: Boolean;
begin
  TcpSocket.Sendln( SourceFilePath );
  Result := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False );
  if not Result then // Ŀ���ļ�������
    Exit;
  DesFileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), 0 );
  DesFileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), Now );
end;

procedure TNetworkFileScanHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TNetworkFileCopyHandle }

function TNetworkFileCopyHandle.CheckNextCopy: Boolean;
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
      // ˢ�½���
    RefreshCompletedSpace;

      // ��� �Ƿ񱸷��ж�
//    Result := Result and NetworkBackupInfoReadUtil.( DesRootPath, SourceRootPath );
    StartTime := Now;
  end;

    // �����Ѿ� Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TNetworkFileCopyHandle.Create(_SourFilePath: string);
begin
  SourFilePath := _SourFilePath;
end;

procedure TNetworkFileCopyHandle.FileSend;
var
  SourFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SourceFileTime : TDateTime;
begin
    // �ļ���
  SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );

  FullBufSize := SizeOf( Buf );
  RemainSize := SourFileStream.Size;
  while RemainSize > 0 do
  begin
      // ȡ������ �� �������
    if not CheckNextCopy then
      Break;

       // ��ȡ
    BufSize := Min( FullBufSize, RemainSize );
    ReadSize := SourFileStream.Read( Buf, BufSize );

      // ����
    TcpSocket.SendBuf( Buf, ReadSize );

    RemainSize := RemainSize - ReadSize;
    AddCompletedSpace := AddCompletedSpace + ReadSize;
  end;

    // �������ɿռ�
  RefreshCompletedSpace;

  SourFileStream.Free;
end;

procedure TNetworkFileCopyHandle.RefreshCompletedSpace;
begin
    // ˢ���ٶ�
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // ���� ˢ�±����ٶ�
    BackupItemAppApi.SetSpeed( PcID, SourceRootPath, RefreshSpeedInfo.Speed );
    RefreshSpeedInfo.ResetSpeed;
  end;


  BackupItemAppApi.AddBackupCompletedSpace( PcID, SourceRootPath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TNetworkFileCopyHandle.SetDesPcInfo(_PcID: string;
  _TcpSocket: TCustomIpClient);
begin
  PcID := _PcID;
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileCopyHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

procedure TNetworkFileCopyHandle.SetRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TNetworkFileCopyHandle.Update;
var
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
  IsEnoughSpace : Boolean;
begin
    // Դ�ļ�������
  if not FileExists( SourFilePath ) then
    Exit;

    // ���� �ռ�
  SourceFileSize := MyFileInfo.getFileSize( SourFilePath );
  MySocketUtil.SendString( TcpSocket, IntToStr( SourceFileSize ) );

    // �Ƿ����㹻�Ŀռ�
  IsEnoughSpace := StrToBool( MySocketUtil.RevString( TcpSocket ) );
  if not IsEnoughSpace then
    Exit;

    // �ļ�����
  FileSend;

    // �����޸�ʱ��
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
  TcpSocket.Sendln( FloatToStr( SourceFileTime ) );
end;
{ TRefreshSpeedInfo }

function TRefreshSpeedInfo.AddCompleted(CompletedSpace: Int64): Boolean;
begin
  Speed := Speed + CompletedSpace;
  Result := SecondsBetween( Now, SpeedTime ) >= 1;
end;

constructor TRefreshSpeedInfo.Create;
begin
  ResetSpeed;
end;

procedure TRefreshSpeedInfo.ResetSpeed;
begin
  SpeedTime := Now;
  Speed := 0;
end;

end.

