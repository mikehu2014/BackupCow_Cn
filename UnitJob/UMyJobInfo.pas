unit UMyJobInfo;

interface

uses Generics.Collections, UChangeInfo, SyncObjs, Sockets, UMyUtil;

type

{$Region ' Job 数据结构 ' }

  {$Region ' Job 信息 ' }

    // Job 信息
  TJobInfo = class
  public
    function getJobType : string;virtual;abstract;
  end;

    // Accept Job
  TAcceptJobInfo = class( TJobInfo )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function getJobType : string;override;
    destructor Destroy; override;
  end;

    // Pending Job
  TPendingJobInfo = class( TJobInfo )
  public
    PcID : string;
    Position, FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetPcID( _PcID : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getLoadPath : string;virtual;abstract;
  end;

    // 上传 文件
  TUpJobInfo = class( TPendingJobInfo )
  public
    UploadPath : string;
  public
    procedure SetUploadPath( _UploadPath : string );
    function getLoadPath : string;override;
  end;

    // 上传 备份文件
  TBackupJobInfo = class( TUpJobInfo )
  public
    function getJobType : string;override;
  end;

    // 上传 发送文件
  TFileSendJobInfo = class( TUpJobInfo )
  public
    function getJobType : string;override;
  end;

    // 下载  源文件
  TDownJobInfo = class( TPendingJobInfo )
  public
    FilePath : string;
    DownloadPath : string;
  public
    procedure SetDownInfo( _FilePath, _DownloadPath : string );
    function getLoadPath : string;override;
  end;

    // 下载 备份文件
  TDownBackupJobInfo = class( TDownJobInfo )
  public
    BackupFilePcID : string;
  public
    procedure SetBackupFileInfo( _BackupFilePcID : string );
  end;

    // 下载 搜索 源文件
  TSourceSearchJobInfo = class( TDownJobInfo )
  public
    function getJobType : string;override;
  end;

    // 下载 搜索 备份文件
  TBackupSearchJobInfo = class( TDownBackupJobInfo )
  public
    function getJobType : string;override;
  end;

    // 下载 恢复 备份文件
  TRestoreJobInfo = class( TDownBackupJobInfo )
  public
    function getJobType : string;override;
  end;

    // 下载 共享文件
  TShareJobInfo = class( TDownJobInfo )
  public
    function getJobType : string;override;
  end;

    // Offline Job
  TOfflineJobInfo = class( TJobInfo )
  public
    PendingJobInfo : TPendingJobInfo;
  public
    procedure SetPengingJob( _PendingJobInfo : TPendingJobInfo );
    function getJobType : string;override;
    destructor Destroy; override;
  end;

  TJobList = class( TObjectList<TJobInfo> )end;

  {$EndRegion}

  {$Region ' Job 集合 ' }

    // 需要传输的 Job
  TTransferJobInfo = class
  public
    BackupJobList : TJobList;
    SourceSearchJobList : TJobList;
    BackupSearchJobList : TJobList;
    RestoreJobList : TJobList;
    SendJobList : TJobList;
    ShareJobList : TJobList;
  public
    AcceptJobList : TJobList;
    OfflineJobList : TJobList;
  public
    constructor Create;
    destructor Destroy; override;
  private
    function CreateJobList : TJobList;
    procedure DestoryJobList( JobList : TJobList );
  public
    function getNextJobInfo : TJobInfo;
    function CheckAcceptJob : Boolean;
  end;

  {$EndRegion}

  {$Region ' Job 辅助类 ' }

    // 克隆 Job
  TFindCloneJob = class
  private
    JobInfo : TPendingJobInfo;
  private
    CloneJobInfo : TPendingJobInfo;
  public
    constructor Create( _JobInfo : TPendingJobInfo );
    function get : TPendingJobInfo;
  private
    procedure SetBackup;
    procedure SetFileSend;
    procedure SetSourceSearch;
    procedure SetBackupSearch;
    procedure SetRestore;
    procedure SetFileShare;
  private
    procedure SetUpLoad;
  private
    procedure SetDownLoad;
    procedure SetDownBackup;
  end;

    // 辅助列
  JobInfoUtil = class
  public
    class function getCloneJob( JobInfo : TPendingJobInfo ): TPendingJobInfo;
    class function getIsUpload( JobType : string ): Boolean;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Job信息 修改 ' }

    // 修改 父类
  TJobWriteInfo = class
  protected
    JobList : TJobList;
    TransferJobInfo : TTransferJobInfo;
  public
    procedure SetTransferJobinfo( _TransferJobInfo : TTransferJobInfo );
    procedure Update;virtual;abstract;
  protected
    procedure FindJobList;
    function getJobType : string;virtual;abstract;
  end;

    // 添加
  TJobAddInfo = class( TJobWriteInfo )
  public
    JobInfo : TJobInfo;
    IsInsert : Boolean;
  public
    constructor Create;
    procedure SetJobInfo( _JobInfo : TJobInfo );
    procedure SetIsInsert( _IsInsert : Boolean );
    procedure Update;override;
  protected
    function getJobType : string;override;
  end;

    // 传输 修改 父类
  TJobChangeInfo = class( TJobWriteInfo )
  public
    JobType : string;
    PcID : string;
    TransferPath : string;
  protected
    JobIndex : Integer;
    JobInfo : TJobInfo;
  public
    procedure SetJobType( _JobType : string );
    procedure SetPcID( _PcID : string );
    procedure SetTransferPath( _TransferPath : string );
  protected
    function getJobType : string;override;
    procedure FindJobInfo;
  end;

    // 删除
  TJobRemoveInfo = class( TJobChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 传输Job信息 修改  ' }

  TTransferJobChangeInfo = class( TChangeInfo )
  protected
    JobWriteInfo : TJobWriteInfo;
    TransferJobInfo : TTransferJobInfo;
  public
    procedure SetJobWriteInfo( _JobWriteInfo : TJobWriteInfo );
    procedure Update;override;
    destructor Destroy; override;
  protected
    procedure FindTransferJobInfo;virtual;abstract;
    procedure RunTransfer;virtual;abstract;
  end;

    // 下载
  TDownloadJobChangeInfo = class( TTransferJobChangeInfo )
  protected
    procedure FindTransferJobInfo;override;
    procedure RunTransfer;override;
  end;

    // 上传
  TUploadJobChangeInfo = class( TTransferJobChangeInfo )
  protected
    procedure FindTransferJobInfo;override;
    procedure RunTransfer;override;
  end;

{$EndRegion}

{$Region ' 启动 Offline Job ' }

  TOnlineJobHandle = class
  private
    OnlinePcID : string;
    JobType : string;
    JobList : TJobList;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure SetJobList( _JobList : TJobList );
    procedure SetJobType( _JobType : string );
    procedure Update;
  private
    procedure AddOnlineJob( JobInfo : TPendingJobInfo );virtual;abstract;
  end;

    // 启动下载 Offline Job
  TDownloadOnlineJobHandle = class( TOnlineJobHandle )
  private
    procedure AddOnlineJob( JobInfo : TPendingJobInfo );override;
  end;

    // 启动 上传 Offline Job
  TUploadOnlineJobHandle = class( TOnlineJobHandle )
  private
    procedure AddOnlineJob( JobInfo : TPendingJobInfo );override;
  end;

    // Pc 上线 ， 启动 Offline Job
  TTransferJobOnlineInfo = class( TChangeInfo )
  public
    OnlinePcID : string;
    JobType : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure SetJobType( _JobType : string );
    procedure Update;override;
  private
    procedure OnlineJobHandle( IsUpload : Boolean );
  end;

{$EndRegion}

{$Region ' 删除 Child Offline Job ' }

  TJobRemoveChildOfflineInfo = class( TJobWriteInfo )
  public
    JobType : string;
    PcID : string;
    ParentPath : string;
  protected
    JobIndex : Integer;
    JobInfo : TJobInfo;
  public
    procedure SetJobType( _JobType : string );
    procedure SetPcID( _PcID : string );
    procedure SetParentPath( _ParentPath : string );
    procedure Update;override;
  protected
    function getJobType : string;override;
  end;

{$EndRegion}

{$Region ' Redirect Job 修改 ' }

    // 父类
  TRedirectJobChangeInfo = class( TChangeInfo )
  public
    RedirectJobList : TJobList;
  public
    procedure Update;override;
  end;

    // 添加
  TRedirectJobAddInfo = class( TRedirectJobChangeInfo )
  public
    PendingJobInfo : TPendingJobInfo;
  public
    constructor Create( _PendingJobInfo : TPendingJobInfo );
    procedure Update;override;
  end;

    // 删除
  TRedirectJobRemoveInfo = class( TRedirectJobChangeInfo )
  public
    PcID : string;
    JobType, LoadPath : string;
  public
    constructor Create( _PcID : string );
    procedure SetJobInfo( _JobType, _LoadPath : string );
    procedure Update;override;
  end;

    // Pc 离线
  TRedirectJobPcOfflineInfo = class( TRedirectJobChangeInfo )
  public
    OfflinePcID : string;
  public
    constructor Create( _OfflinePcID : string );
    procedure Update;override;
  private
    procedure RemoveBackupPending( FilePath : string );
  end;

{$EndRegion}

    // 续传 Job 信息
  TMyJobInfo = class( TMyDataChange )
  public
    IsTransfer : Boolean;
    UploadJobInfo : TTransferJobInfo;  // 上传 Job
    DownloadJobInfo : TTransferJobInfo; // 下载 Job
    RedirectJobList : TJobList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  JobType_Backup = 'Backup';
  JobType_SourceSearch = 'SourceSearch';
  JobType_BackupSearch = 'BackupSearch';
  JobType_Restore = 'Restore';
  JobType_FileSend = 'FileSend';
  JobType_FileShare = 'FileShare';
  JobType_Offline = 'Offline';
  JobType_Accept = 'Accept';

  JobType_All = 'All';

var
  MyJobInfo : TMyJobInfo;

implementation

uses UMyFileUpload, UMyFileDownload, UMyFileTransfer, UJobControl, UJobFace, UMyBackupInfo;


{ TMyJobInfo }

constructor TMyJobInfo.Create;
begin
  inherited;
  UploadJobInfo := TTransferJobInfo.Create;
  DownloadJobInfo := TTransferJobInfo.Create;
  RedirectJobList := TJobList.Create;
  IsTransfer := True;
  AddThread(1);
end;

destructor TMyJobInfo.Destroy;
begin
  RedirectJobList.Free;
  DownloadJobInfo.Free;
  UploadJobInfo.Free;
  inherited;
end;

{ TBackupJobInfo }

function TBackupJobInfo.getJobType: string;
begin
  Result := JobType_Backup;
end;

{ TDownJobInfo }

function TDownJobInfo.getLoadPath: string;
begin
  Result := DownloadPath;
end;

procedure TDownJobInfo.SetDownInfo(_FilePath, _DownloadPath: string);
begin
  FilePath := _FilePath;
  DownloadPath := _DownloadPath;
end;

{ TTransferJobInfo }

function TTransferJobInfo.CheckAcceptJob: Boolean;
begin
  Result := AcceptJobList.Count < 10;
end;

constructor TTransferJobInfo.Create;
begin
  BackupJobList := CreateJobList;
  SourceSearchJobList := CreateJobList;
  BackupSearchJobList := CreateJobList;
  RestoreJobList := CreateJobList;
  OfflineJobList := CreateJobList;
  AcceptJobList := CreateJobList;
  SendJobList := CreateJobList;
  ShareJobList := CreateJobList;
end;

function TTransferJobInfo.CreateJobList: TJobList;
begin
  Result := TJobList.Create;
  Result.OwnsObjects := False;
end;

procedure TTransferJobInfo.DestoryJobList(JobList: TJobList);
begin
  JobList.OwnsObjects := True;
  JobList.Free;
end;

destructor TTransferJobInfo.Destroy;
begin
  DestoryJobList( ShareJobList );
  DestoryJobList( SendJobList );
  DestoryJobList( AcceptJobList );
  DestoryJobList( OfflineJobList );
  DestoryJobList( RestoreJobList );
  DestoryJobList( SourceSearchJobList );
  DestoryJobList( BackupSearchJobList );
  DestoryJobList( BackupJobList );
  inherited;
end;

function TTransferJobInfo.getNextJobInfo: TJobInfo;
var
  JobList : TJobList;
begin
  if AcceptJobList.Count > 0 then
    JobList := AcceptJobList
  else
  if SendJobList.Count > 0 then
    JobList := SendJobList
  else
  if ShareJobList.Count > 0 then
    JobList := ShareJobList
  else
  if RestoreJobList.Count > 0 then
    JobList := RestoreJobList
  else
  if SourceSearchJobList.Count > 0 then
    JobList := SourceSearchJobList
  else
  if BackupSearchJobList.Count > 0 then
    JobList := BackupSearchJobList
  else
  if BackupJobList.Count > 0 then
    JobList := BackupJobList
  else
  begin
    Result := nil;
    Exit;
  end;

  Result := JobList[0];
  JobList.Delete(0);
end;


{ TTransferJobAddInfo }

constructor TJobAddInfo.Create;
begin
  inherited;
  IsInsert := False;
end;

function TJobAddInfo.getJobType: string;
begin
  Result := JobInfo.getJobType;
end;

procedure TJobAddInfo.SetIsInsert(_IsInsert: Boolean);
begin
  IsInsert := _IsInsert;
end;

procedure TJobAddInfo.SetJobInfo(_JobInfo: TJobInfo);
begin
  JobInfo := _JobInfo;
end;


procedure TJobAddInfo.Update;
begin
  FindJobList;

  if IsInsert then
    JobList.Insert( 0, JobInfo )
  else
    JobList.Add( JobInfo );
end;

{ TPendingJobInfo }

procedure TPendingJobInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TPendingJobInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPendingJobInfo.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

{ TAcceptJobInfo }

destructor TAcceptJobInfo.Destroy;
begin
  TcpSocket.Free;
  inherited;
end;

function TAcceptJobInfo.getJobType: string;
begin
  Result := JobType_Accept;
end;

procedure TAcceptJobInfo.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TOfflineJobInfo }

destructor TOfflineJobInfo.Destroy;
begin
  PendingJobInfo.Free;
  inherited;
end;

function TOfflineJobInfo.getJobType: string;
begin
  Result := JobType_Offline;
end;

procedure TOfflineJobInfo.SetPengingJob(_PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

{ TRestoreJobInfo }

function TRestoreJobInfo.getJobType: string;
begin
  Result := JobType_Restore;
end;

{ TTransferJobOnlineInfo }

procedure TTransferJobOnlineInfo.OnlineJobHandle(IsUpload: Boolean);
var
  JobList : TJobList;
  OnlineJobHandle : TOnlineJobHandle;
begin
  if IsUpload then
  begin
    JobList := MyJobInfo.UploadJobInfo.OfflineJobList;
    OnlineJobHandle := TUploadOnlineJobHandle.Create;
  end
  else
  begin
    JobList := MyJobInfo.DownloadJobInfo.OfflineJobList;
    OnlineJobHandle := TDownloadOnlineJobHandle.Create;
  end;

  OnlineJobHandle.SetOnlinePcID( OnlinePcID );
  OnlineJobHandle.SetJobList( JobList );
  OnlineJobHandle.SetJobType( JobType );
  OnlineJobHandle.Update;
  OnlineJobHandle.Free;
end;

procedure TTransferJobOnlineInfo.SetJobType(_JobType: string);
begin
  JobType := _JobType;
end;

procedure TTransferJobOnlineInfo.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TTransferJobOnlineInfo.Update;
begin
  OnlineJobHandle( True );

  OnlineJobHandle( False );
end;


{ TOnlineJobHandle }

procedure TOnlineJobHandle.SetJobList(_JobList: TJobList);
begin
  JobList := _JobList;
end;

procedure TOnlineJobHandle.SetJobType(_JobType: string);
begin
  JobType := _JobType;
end;

procedure TOnlineJobHandle.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TOnlineJobHandle.Update;
var
  i : Integer;
  OfflineJobInfo : TOfflineJobInfo;
  PendingJobInfo : TPendingJobInfo;
  ClonePendJobInfo : TPendingJobInfo;
begin
  for i := JobList.Count - 1 downto 0 do
  begin
    OfflineJobInfo := JobList[i] as TOfflineJobInfo;

    PendingJobInfo := OfflineJobInfo.PendingJobInfo;
    if ( PendingJobInfo.PcID <> OnlinePcID ) and ( OnlinePcID <> '' ) then
      Continue;
    if ( JobType <> JobType_All ) and ( PendingJobInfo.getJobType <> JobType ) then
      Continue;

    ClonePendJobInfo := JobInfoUtil.getCloneJob( PendingJobInfo );
    AddOnlineJob( ClonePendJobInfo );

    OfflineJobInfo.Free;
    JobList.Delete( i );
  end;
end;

{ TDownloadOnlineJobHandle }

procedure TDownloadOnlineJobHandle.AddOnlineJob(JobInfo: TPendingJobInfo);
var
  TransferDownJobOnlineHandle : TTransferDownJobOnlineHandle;
begin
  TransferDownJobOnlineHandle := TTransferDownJobOnlineHandle.Create( OnlinePcID );
  TransferDownJobOnlineHandle.SetJobInfo( JobInfo );
  TransferDownJobOnlineHandle.Update;
  TransferDownJobOnlineHandle.Free;
end;

{ TUploadOnlineJobHandle }

procedure TUploadOnlineJobHandle.AddOnlineJob(JobInfo: TPendingJobInfo);
var
  TransferUpJobOnlineHandle : TTransferUpJobOnlineHandle;
begin
  TransferUpJobOnlineHandle := TTransferUpJobOnlineHandle.Create( OnlinePcID );
  TransferUpJobOnlineHandle.SetJobInfo( JobInfo );
  TransferUpJobOnlineHandle.Update;
  TransferUpJobOnlineHandle.Free;
end;


{ JobInfoUtil }

class function JobInfoUtil.getCloneJob(
  JobInfo: TPendingJobInfo): TPendingJobInfo;
var
  FindCloneJob : TFindCloneJob;
begin
  FindCloneJob := TFindCloneJob.Create( JobInfo );
  Result := FindCloneJob.get;
  FindCloneJob.Free;
end;

class function JobInfoUtil.getIsUpload(JobType: string): Boolean;
begin
  Result := ( JobType = JobType_Backup ) and ( JobType = JobType_FileSend );
end;

{ TFindCloneJob }

constructor TFindCloneJob.Create(_JobInfo: TPendingJobInfo);
begin
  JobInfo := _JobInfo;
end;

function TFindCloneJob.get: TPendingJobInfo;
begin
  if JobInfo is TUpJobInfo then
  begin
    if JobInfo is TBackupJobInfo then
      SetBackup
    else
    if JobInfo is TFileSendJobInfo then
      SetFileSend;
    SetUpLoad;
  end
  else
  if JobInfo is TDownJobInfo then
  begin
    if JobInfo is TSourceSearchJobInfo then
      SetSourceSearch
    else
    if JobInfo is TShareJobInfo then
      SetFileShare
    else
    if JobInfo is TDownBackupJobInfo then
    begin
      if JobInfo is TBackupSearchJobInfo then
        SetBackupSearch
      else
      if JobInfo is TRestoreJobInfo then
        SetRestore;
      SetDownBackup;
    end;
    SetDownLoad;
  end;

  CloneJobInfo.SetPcID( JobInfo.PcID );
  CloneJobInfo.SetPosition( JobInfo.Position );
  CloneJobInfo.SetFileInfo( JobInfo.FileSize, JobInfo.FileTime );

  Result := CloneJobInfo;
end;

procedure TFindCloneJob.SetBackup;
begin
  CloneJobInfo := TBackupJobInfo.Create;
end;

procedure TFindCloneJob.SetBackupSearch;
begin
  CloneJobInfo := TBackupSearchJobInfo.Create;
end;

procedure TFindCloneJob.SetDownLoad;
var
  DownJobInfo : TDownJobInfo;
  CloneDownJobInfo : TDownJobInfo;
begin
  DownJobInfo := JobInfo as TDownJobInfo;
  CloneDownJobInfo := CloneJobInfo as TDownJobInfo;

  CloneDownJobInfo.SetDownInfo( DownJobInfo.FilePath, DownJobInfo.DownloadPath );
end;

procedure TFindCloneJob.SetDownBackup;
var
  DownBackupJobInfo : TDownBackupJobInfo;
  CloneDownBackupJobInfo : TDownBackupJobInfo;
begin
  DownBackupJobInfo := JobInfo as TDownBackupJobInfo;
  CloneDownBackupJobInfo := CloneJobInfo as TDownBackupJobInfo;

  CloneDownBackupJobInfo.SetBackupFileInfo( DownBackupJobInfo.BackupFilePcID );
end;

procedure TFindCloneJob.SetRestore;
begin
  CloneJobInfo := TRestoreJobInfo.Create;
end;

procedure TFindCloneJob.SetFileSend;
begin
  CloneJobInfo := TFileSendJobInfo.Create;
end;

procedure TFindCloneJob.SetFileShare;
begin
  CloneJobInfo := TShareJobInfo.Create;
end;

procedure TFindCloneJob.SetSourceSearch;
begin
  CloneJobInfo := TSourceSearchJobInfo.Create;
end;

procedure TFindCloneJob.SetUpLoad;
var
  UpJobInfo : TUpJobInfo;
  CloneUpJobInfo : TUpJobInfo;
begin
  UpJobInfo := JobInfo as TUpJobInfo;
  CloneUpJobInfo := CloneJobInfo as TUpJobInfo;
  CloneUpJobInfo.SetUploadPath( UpJobInfo.UploadPath );
end;

{ TJobChangeInfo }

procedure TJobChangeInfo.FindJobInfo;
var
  i : Integer;
  PendingJobInfo : TPendingJobInfo;
begin
  FindJobList;

    // 遍历 寻找删除的Job
  JobIndex := -1;
  JobInfo := nil;
  for i := 0 to JobList.Count - 1 do
  begin
    if JobType = JobType_Offline then
      PendingJobInfo := ( JobList[i] as TOfflineJobInfo ).PendingJobInfo
    else
      PendingJobInfo := JobList[i] as TPendingJobInfo;

    if not ( PendingJobInfo.PcID = PcID ) then
      Continue;

    if TransferPath = PendingJobInfo.getLoadPath then
    begin
      JobIndex := i;
      JobInfo := JobList[i];
      Break;
    end;
  end;
end;

function TJobChangeInfo.getJobType: string;
begin
  Result := JobType;
end;

procedure TJobChangeInfo.SetJobType(_JobType: string);
begin
  JobType := _JobType;
end;

procedure TJobChangeInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TJobChangeInfo.SetTransferPath(_TransferPath: string);
begin
  TransferPath := _TransferPath;
end;

{ TJobChangeInfo }

procedure TJobWriteInfo.FindJobList;
var
  JobType : string;
begin
  JobType := getJobType;

  if JobType = JobType_Backup then
    JobList := TransferJobInfo.BackupJobList
  else
  if JobType = JobType_SourceSearch then
    JobList := TransferJobInfo.SourceSearchJobList
  else
  if JobType = JobType_BackupSearch then
    JobList := TransferJobInfo.BackupSearchJobList
  else
  if JobType = JobType_Restore then
    JobList := TransferJobInfo.RestoreJobList
  else
  if JobType = JobType_Offline then
    JobList := TransferJobInfo.OfflineJobList
  else
  if JobType = JobType_Accept then
    JobList := TransferJobInfo.AcceptJobList
  else
  if JobType = JobType_FileSend then
    JobList := TransferJobInfo.SendJobList
  else
  if JobType = JobType_FileShare then
    JobList := TransferJobInfo.ShareJobList;
end;

procedure TJobWriteInfo.SetTransferJobinfo(_TransferJobInfo: TTransferJobInfo);
begin
  TransferJobInfo := _TransferJobInfo;
end;

{ TTransferJobRemoveInfo }

procedure TJobRemoveInfo.Update;
begin
  FindJobInfo;

  if JobIndex >= 0 then
  begin
    JobList.Delete( JobIndex );
    JobInfo.Free;
  end;

end;

{ TTransferJobChangeInfo }

destructor TTransferJobChangeInfo.Destroy;
begin
  JobWriteInfo.Free;
  inherited;
end;

procedure TTransferJobChangeInfo.SetJobWriteInfo(_JobWriteInfo: TJobWriteInfo);
begin
  JobWriteInfo := _JobWriteInfo;
end;

procedure TTransferJobChangeInfo.Update;
begin
  FindTransferJobInfo;

  JobWriteInfo.SetTransferJobinfo( TransferJobInfo );
  JobWriteInfo.Update;

    // 做 Job
  if JobWriteInfo is TJobAddInfo then
    if MyJobInfo.IsTransfer then
      RunTransfer;
end;

{ TDownloadJobChangeInfo }

procedure TDownloadJobChangeInfo.FindTransferJobInfo;
begin
  TransferJobInfo := MyJobInfo.DownloadJobInfo;
end;

procedure TDownloadJobChangeInfo.RunTransfer;
begin
  MyFileDownload.RunAllThread;
end;

{ TUploadJobChangeInfo }

procedure TUploadJobChangeInfo.FindTransferJobInfo;
begin
  TransferJobInfo := MyJobInfo.UploadJobInfo;
end;

procedure TUploadJobChangeInfo.RunTransfer;
begin
  MyFileUpload.RunAllThread;
end;

{ TDownBackupJob }

procedure TDownBackupJobInfo.SetBackupFileInfo(_BackupFilePcID: string);
begin
  BackupFilePcID := _BackupFilePcID;
end;

{ TSearchSourceJobInfo }

function TSourceSearchJobInfo.getJobType: string;
begin
  Result := JobType_SourceSearch;
end;

{ TSearchBackupJobInfo }

function TBackupSearchJobInfo.getJobType: string;
begin
  Result := JobType_BackupSearch;
end;

{ TFileSendJobInfo }

function TFileSendJobInfo.getJobType: string;
begin
  Result := JobType_FileSend;
end;

{ TUpJobInfo }

function TUpJobInfo.getLoadPath: string;
begin
  Result := UploadPath;
end;

procedure TUpJobInfo.SetUploadPath(_UploadPath: string);
begin
  UploadPath := _UploadPath;
end;

{ TShareJobInfo }

function TShareJobInfo.getJobType: string;
begin
  Result := JobType_FileShare;
end;

{ TJobRemoveChildOfflineInfo }

function TJobRemoveChildOfflineInfo.getJobType: string;
begin
  Result := JobType_Offline;
end;

procedure TJobRemoveChildOfflineInfo.SetJobType(_JobType: string);
begin
  JobType := _JobType;
end;

procedure TJobRemoveChildOfflineInfo.SetParentPath(_ParentPath: string);
begin
  ParentPath := _ParentPath;
end;

procedure TJobRemoveChildOfflineInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TJobRemoveChildOfflineInfo.Update;
var
  i : Integer;
  PendingJobInfo : TPendingJobInfo;
  ChildPath : string;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
  FindJobList;

    // 遍历 寻找删除的Job
  for i := JobList.Count - 1 downto 0 do
  begin
    PendingJobInfo := ( JobList[i] as TOfflineJobInfo ).PendingJobInfo;
    if PendingJobInfo.getJobType <> JobType then
      Continue;
    if PendingJobInfo.PcID <> PcID then
      Continue;
    if PendingJobInfo is TUpJobInfo then
      ChildPath := ( PendingJobInfo as TUpJobInfo ).UploadPath
    else
    if PendingJobInfo is TDownJobInfo then
      ChildPath := ( PendingJobInfo as TDownJobInfo ).FilePath
    else
      Continue;
    if not MyMatchMask.CheckEqualsOrChild( ChildPath, ParentPath ) then
      Continue;
  end;
end;


{ TRedirectJobChangeInfo }

procedure TRedirectJobChangeInfo.Update;
begin
  RedirectJobList := MyJobInfo.RedirectJobList;
end;

{ TRedirectJobAddInfo }

constructor TRedirectJobAddInfo.Create(_PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

procedure TRedirectJobAddInfo.Update;
begin
  inherited;
  RedirectJobList.Add( PendingJobInfo );
end;

{ TRedirectJobRemoveInfo }

constructor TRedirectJobRemoveInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRedirectJobRemoveInfo.SetJobInfo(_JobType, _LoadPath: string);
begin
  JobType := _JobType;
  LoadPath := _LoadPath;
end;

procedure TRedirectJobRemoveInfo.Update;
var
  i : Integer;
  SelectJobInfo : TPendingJobInfo;
begin
  inherited;

  for i := 0 to RedirectJobList.Count - 1 do
  begin
    SelectJobInfo := RedirectJobList[i] as TPendingJobInfo;
    if ( SelectJobInfo.PcID = PcID ) and
       ( SelectJobInfo.getJobType = JobType ) and
       ( SelectJobInfo.getLoadPath = LoadPath )
    then
    begin
      RedirectJobList.Delete(i);
      Break;
    end;
  end;
end;

{ TRedirectJobPcOfflineInfo }

constructor TRedirectJobPcOfflineInfo.Create(_OfflinePcID: string);
begin
  OfflinePcID := _OfflinePcID;
end;

procedure TRedirectJobPcOfflineInfo.RemoveBackupPending(FilePath: string);
var
  BackupFileCopyRemoveInfo : TBackupFileCopyRemoveInfo;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // 删除 备份文件副本 内存
  BackupFileCopyRemoveInfo := TBackupFileCopyRemoveInfo.Create( FilePath );
  BackupFileCopyRemoveInfo.SetCopyOwner( OfflinePcID );
  MyBackupFileInfo.AddChange( BackupFileCopyRemoveInfo );

    // 删除 界面
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_UpPend );
  VirTransferChildRemoveInfo.SetChildID( OfflinePcID, FilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;


procedure TRedirectJobPcOfflineInfo.Update;
var
  i : Integer;
  SelectJobInfo : TPendingJobInfo;
  CloneJobInfo : TPendingJobInfo;
  OfflineJobInfo : TOfflineJobInfo;
  JobAddInfo : TJobAddInfo;
  TransferJobChangeInfo : TTransferJobChangeInfo;
begin
  inherited;

  for i := RedirectJobList.Count - 1 downto 0 do
  begin
    SelectJobInfo := RedirectJobList[i] as TPendingJobInfo;
    if ( SelectJobInfo.PcID <> OfflinePcID ) and ( OfflinePcID <> '' ) then
      Continue;
      // 备份文件 Pending
    if ( SelectJobInfo.getJobType = JobType_Backup ) and ( SelectJobInfo.Position = 0 ) then
    begin
      RemoveBackupPending( SelectJobInfo.getLoadPath );
      RedirectJobList.Delete(i);
      Continue;
    end;
      // 添加 Job
    CloneJobInfo := JobInfoUtil.getCloneJob( SelectJobInfo );
    OfflineJobInfo := TOfflineJobInfo.Create;
    OfflineJobInfo.SetPengingJob( CloneJobInfo );
    JobAddInfo := TJobAddInfo.Create;
    JobAddInfo.SetJobInfo( OfflineJobInfo );
      // 添加 到 传输队列
    if JobInfoUtil.getIsUpload( SelectJobInfo.getJobType ) then
      TransferJobChangeInfo := TUploadJobChangeInfo.Create
    else
      TransferJobChangeInfo := TDownloadJobChangeInfo.Create;
    TransferJobChangeInfo.SetJobWriteInfo( JobAddInfo );
      // 添加 到 Job
    MyJobInfo.AddChange( TransferJobChangeInfo );
    RedirectJobList.Delete(i);
  end;
end;

end.
