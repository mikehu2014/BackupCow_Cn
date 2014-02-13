unit UJobControl;

interface

uses UMyJobInfo, uDebug, SysUtils;

type

    // �޸� Job ����
  TTransferJobChangeHandle = class
  protected
    FilePath : string;
    DesPcID : string;
  public
    constructor Create( _FilePath, _DesPcID : string );
  end;

{$Region ' ��� Job ' }

    // ��� Job ����
  TTransferJobAddHandle = class( TTransferJobChangeHandle )
  private
    FileSize, Position : Int64;
    FileTime : TDateTime;
  private
    DesPcName : string;
    DesPcIsOnline : Boolean;
  private
    RootID, FileType : string;
    PendFilePath : string;
    PendingJobInfo : TPendingJobInfo;
    TransferJobChangeInfo : TTransferJobChangeInfo;
  public
    procedure SetFileInfo( _FileSize, _Position : Int64; _FileTime : TDateTime );
    procedure Update;
  protected
    procedure FindDesPcInfo;
    procedure FindTransferFaceInfo; virtual;abstract;
    procedure FindMyJobInfo; virtual;abstract;
    procedure OfflineJobHandle; virtual;
  private
    procedure AddTransferFace;
    procedure AddMyJobInfo;
  end;

    // ��� �ϴ� Job ����
  TTransferUploadJobAddHandle = class( TTransferJobAddHandle )
  protected
    procedure FindTransferFaceInfo;override;
    procedure FindMyJobInfo; override;
  protected
    function getPendingJobInfo : TPendingJobInfo; virtual;abstract;
  end;

    // ��� �����ļ� Job
  TTransferFileSendJobAddHandle = class( TTransferUploadJobAddHandle )
  protected
    procedure FindTransferFaceInfo;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

    // ��� ���� Job
  TTransferBackupJobAddHandle = class( TTransferUploadJobAddHandle )
  protected
    procedure FindTransferFaceInfo;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

    // ��� ���� Job ����
  TTransferDownloadJobAddHandle = class( TTransferJobAddHandle )
  protected
    DownFilePath : string;
  public
    procedure SetDownFilePath( _DownFilePath : string );
  protected
    procedure FindTransferFaceInfo;override;
    procedure FindMyJobInfo; override;
  protected
    function getPendingJobInfo : TPendingJobInfo; virtual;abstract;
  end;

    // ��� ���� Job
  TTransferShareJobAddHandle = class( TTransferDownloadJobAddHandle )
  protected
    procedure FindTransferFaceInfo;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

    // ��� ���� Job
  TTransferSearchJobAddHandle = class( TTransferDownloadJobAddHandle )
  protected
    procedure FindTransferFaceInfo;override;
  end;

    // ��� ����Դ�ļ� Job
  TTransferSourceSearchJobAddHandle = class( TTransferSearchJobAddHandle )
  protected
    procedure OfflineJobHandle;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

    // ��� �������ݸ��� Job
  TTransferBackupSearchJobAddHandle = class( TTransferSearchJobAddHandle )
  protected
    SourcePcID : string;
  public
    procedure SetSourcePcID( _SourcePcID : string );
  protected
    procedure OfflineJobHandle;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

    // ��� �ָ� Job
  TTransferRestoreJobAddHandle = class( TTransferDownloadJobAddHandle )
  private
    RestorePcID : string;
  public
    procedure SetRestorePcID( _RestorePcID : string );
  protected
    procedure FindTransferFaceInfo;override;
    procedure OfflineJobHandle;override;
  protected
    function getPendingJobInfo : TPendingJobInfo;override;
  end;

{$EndRegion}

{$Region ' ɾ�� Job ' }

    // ɾ�� Job ����
  TTransferJobRemoveHandle = class( TTransferJobChangeHandle )
  protected
    RootID : string;
  protected
    JobType : string;
    TransferJobChangeInfo : TTransferJobChangeInfo;
  public
    procedure Update;
  private
    procedure RemoveTransferFace;
    procedure RemoveMyJobInfo;
  protected
    procedure FindTransferFaceInfo; virtual;abstract;
    procedure FindMyJobInfo; virtual;abstract;
  end;

    // ɾ�� �ϴ� Job
  TTransferUpJobRemoveHandle = class( TTransferJobRemoveHandle )
  protected
    procedure FindTransferFaceInfo;override;
    procedure FindMyJobInfo; override;
  end;

    // ɾ�� �ļ����� Job
  TTransferFileSendJobRemoveHandle = class( TTransferUpJobRemoveHandle )
  protected
    procedure FindMyJobInfo; override;
  end;

    // ɾ�� ���� Job
  TTransferDownJobRemoveHandle = class( TTransferJobRemoveHandle )
  protected
    procedure FindTransferFaceInfo;override;
    procedure FindMyJobInfo; override;
  end;

    // ɾ�� ���ع��� Job
  TTransferFileShareJobRemoveHandle = class( TTransferDownJobRemoveHandle )
  protected
    procedure FindMyJobInfo; override;
  end;

{$EndRegion}

{$Region ' ���� Job ' }

    // Pc����, �������� Job
  TTransferJobOnlineChangeHandle = class
  protected
    PcID : string;
    JobInfo : TPendingJobInfo;
  protected
    RootID : string;
    TransferJobChangeInfo : TTransferJobChangeInfo;
  public
    constructor Create( _PcID : string );
    procedure SetJobInfo( _JobInfo : TPendingJobInfo );
    procedure Update;
  protected
    procedure ResetTransferFace;
    procedure AddToJobInfo;
  protected
    procedure FindTransferFaceInfo; virtual;abstract;
    procedure FindMyJobInfo; virtual;abstract;
    procedure ResetJobInfo; virtual;
  end;

    // ���� ���� Job
  TTransferDownJobOnlineHandle = class( TTransferJobOnlineChangeHandle )
  protected
    procedure FindTransferFaceInfo; override;
    procedure FindMyJobInfo; override;
  end;

    // ���� �ϴ� Job
  TTransferUpJobOnlineHandle = class( TTransferJobOnlineChangeHandle )
  protected
    procedure FindTransferFaceInfo; override;
    procedure FindMyJobInfo; override;
    procedure ResetJobInfo;override;
  private
    procedure ResetBackupJobInfo;
  end;

{$EndRegion}

  TMyJobControl = class
  end;

var
  MyJobControl : TMyJobControl;

implementation

uses UMyNetPcInfo, UJobFace, UMyUtil, UBackupInfoControl, URestoreFileFace, USearchFileFace,
     UMyClient, UMyFileTransfer;

{ TTransferJobAddHandle }

procedure TTransferJobAddHandle.AddMyJobInfo;
var
  OfflineJobInfo : TOfflineJobInfo;
  NewJobInfo : TJobInfo;
  JobAddInfo : TJobAddInfo;
begin
    // ��ȡ Job ��Ϣ
  PendingJobInfo.SetPcID( DesPcID );
  PendingJobInfo.SetPosition( Position );
  PendingJobInfo.SetFileInfo( FileSize, FileTime );

    // Pc �Ƿ� ����
  if DesPcIsOnline then
    NewJobInfo := PendingJobInfo
  else
  begin
    OfflineJobInfo := TOfflineJobInfo.Create;
    OfflineJobInfo.SetPengingJob( PendingJobInfo );
    NewJobInfo := OfflineJobInfo;
  end;

    // ��� Job
  JobAddInfo := TJobAddInfo.Create;
  JobAddInfo.SetJobInfo( NewJobInfo );

    // ��� �� �������
  TransferJobChangeInfo.SetJobWriteInfo( JobAddInfo );

  MyJobInfo.AddChange( TransferJobChangeInfo );
end;

procedure TTransferJobAddHandle.AddTransferFace;
var
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  FileStatus : string;
  Percentage : Integer;
begin
    // Job ״̬
  if DesPcIsOnline then
    FileStatus := FileStatus_Waiting
  else
    FileStatus := FileStatus_Offline;

    // ���״��
  Percentage := MyPercentage.getPercent( Position, FileSize );

    // ��ӵ�����
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( DesPcID, PendFilePath );
  VirTransferChildAddInfo.SetFileBase( PendFilePath, DesPcID );
  VirTransferChildAddInfo.SetFileInfo( DesPcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( FileType, FileStatus );

  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

procedure TTransferJobAddHandle.FindDesPcInfo;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );
end;

procedure TTransferJobAddHandle.OfflineJobHandle;
begin

end;

procedure TTransferJobAddHandle.SetFileInfo(_FileSize, _Position: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  Position := _Position;
  FileTime := _FileTime;
end;

procedure TTransferJobAddHandle.Update;
begin
    // ��ȡ ��Ϣ
  FindDesPcInfo;
  FindTransferFaceInfo;
  FindMyJobInfo;

    // ��� �������
  AddTransferFace;

    // ��� Job��Ϣ
  AddMyJobInfo;

    // ���� Job ����
  if not DesPcIsOnline then
    OfflineJobHandle;
end;

{ TTransferUploadJobAddHandle }

procedure TTransferUploadJobAddHandle.FindMyJobInfo;
begin
  PendingJobInfo := getPendingJobInfo;
  ( PendingJobInfo as TUpJobInfo ).SetUploadPath( FilePath );
  TransferJobChangeInfo := TUploadJobChangeInfo.Create;
end;

procedure TTransferUploadJobAddHandle.FindTransferFaceInfo;
begin
  RootID := RootID_UpPend;
  PendFilePath := FilePath;
end;

{ TTransferFileSendJobAddHandle }

procedure TTransferFileSendJobAddHandle.FindTransferFaceInfo;
begin
  inherited;

  FileType := FileType_Transfer;
end;

function TTransferFileSendJobAddHandle.getPendingJobInfo: TPendingJobInfo;
begin
  Result := TFileSendJobInfo.Create;
end;

{ TTransferBackupJobAddHandle }

procedure TTransferBackupJobAddHandle.FindTransferFaceInfo;
begin
  inherited;

  FileType := FileType_Backup;
end;

function TTransferBackupJobAddHandle.getPendingJobInfo: TPendingJobInfo;
begin
  Result := TBackupJobInfo.Create;
end;

{ TTransferJobChangeHandle }

constructor TTransferJobChangeHandle.Create(_FilePath, _DesPcID: string);
begin
  FilePath := _FilePath;
  DesPcID := _DesPcID;
end;

{ TTransferJobRemoveHandle }

procedure TTransferJobRemoveHandle.RemoveMyJobInfo;
var
  JobRemoveInfo : TJobRemoveInfo;
begin
    // Pc���� ��ɾ������ Job
  if not MyNetPcInfoReadUtil.ReadIsOnline( DesPcID ) then
    JobType := JobType_Offline;

    // ɾ�� Job
  JobRemoveInfo := TJobRemoveInfo.Create;
  JobRemoveInfo.SetJobType( JobType );
  JobRemoveInfo.SetPcID( DesPcID );
  JobRemoveInfo.SetTransferPath( FilePath );

    // ɾ�� Pending Job
  TransferJobChangeInfo.SetJobWriteInfo( JobRemoveInfo );

  MyJobInfo.AddChange( TransferJobChangeInfo );
end;

procedure TTransferJobRemoveHandle.RemoveTransferFace;
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // ɾ�� ����
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID );
  VirTransferChildRemoveInfo.SetChildID( DesPcID, FilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TTransferJobRemoveHandle.Update;
begin
    // Ѱ�� ɾ�� ��Ϣ
  FindTransferFaceInfo;
  FindMyJobInfo;

    // ɾ�� ���� ����
  RemoveTransferFace;

    // ɾ�� Job ��Ϣ
  RemoveMyJobInfo;
end;

{ TTransferUpJobRemoveHandle }

procedure TTransferUpJobRemoveHandle.FindMyJobInfo;
begin
  TransferJobChangeInfo := TUploadJobChangeInfo.Create;
end;

procedure TTransferUpJobRemoveHandle.FindTransferFaceInfo;
begin
  RootID := RootID_UpPend;
end;

{ TTransferFileSendJobRemoveHandle }

procedure TTransferFileSendJobRemoveHandle.FindMyJobInfo;
begin
  inherited;
  JobType := JobType_FileSend;
end;

{ TTransferDownloadJobAddHandle }

procedure TTransferDownloadJobAddHandle.FindMyJobInfo;
begin
  PendingJobInfo := getPendingJobInfo;
  ( PendingJobInfo as TDownJobInfo ).SetDownInfo( FilePath, DownFilePath );
  TransferJobChangeInfo := TDownloadJobChangeInfo.Create;
end;

procedure TTransferDownloadJobAddHandle.FindTransferFaceInfo;
begin
  RootID := RootID_DownPend;
  PendFilePath := DownFilePath;
end;

procedure TTransferDownloadJobAddHandle.SetDownFilePath(_DownFilePath: string);
begin
  DownFilePath := _DownFilePath;
end;

{ TTransferShareJobAddHandle }

procedure TTransferShareJobAddHandle.FindTransferFaceInfo;
begin
  inherited;

  FileType := FileType_Share;
end;

function TTransferShareJobAddHandle.getPendingJobInfo: TPendingJobInfo;
begin
  Result := TShareJobInfo.Create;
end;

{ TTransferDownJobRemoveHandle }

procedure TTransferDownJobRemoveHandle.FindMyJobInfo;
begin
  TransferJobChangeInfo := TDownloadJobChangeInfo.Create;
end;

procedure TTransferDownJobRemoveHandle.FindTransferFaceInfo;
begin
  RootID := RootID_DownPend;
end;

{ TTransferFileShareJobRemoveHandle }

procedure TTransferFileShareJobRemoveHandle.FindMyJobInfo;
begin
  inherited;
  JobType := JobType_FileShare;
end;

{ TTransferJobOnlineChangeHandle }

procedure TTransferJobOnlineChangeHandle.AddToJobInfo;
var
  JobAddInfo : TJobAddInfo;
begin
  JobAddInfo := TJobAddInfo.Create;
  JobAddInfo.SetJobInfo( JobInfo );
  JobAddInfo.SetIsInsert( True );

  TransferJobChangeInfo.SetJobWriteInfo( JobAddInfo );

  MyJobInfo.AddChange( TransferJobChangeInfo );
end;

constructor TTransferJobOnlineChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TTransferJobOnlineChangeHandle.ResetJobInfo;
begin

end;

procedure TTransferJobOnlineChangeHandle.ResetTransferFace;
var
  FilePath, PcName, JobType : string;
  Percentage : Integer;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  FilePath := JobInfo.getLoadPath;
  JobType := JobInfo.getJobType;

    // ɾ�� Offline ����
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID );
  VirTransferChildRemoveInfo.SetChildID( PcID, FilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );

    // ��� Waiting ����
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Percentage := MyPercentage.getPercent( JobInfo.Position, JobInfo.FileSize );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, FilePath );
  VirTransferChildAddInfo.SetFileBase( FilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, JobInfo.FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( JobType, FileStatus_Waiting );
  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

procedure TTransferJobOnlineChangeHandle.SetJobInfo(_JobInfo: TPendingJobInfo);
begin
  JobInfo := _JobInfo;
end;

procedure TTransferJobOnlineChangeHandle.Update;
begin
    // ���� Job ��Ϣ
  FindTransferFaceInfo;
  FindMyJobInfo;

    // ��� Job
  ResetTransferFace;
  AddToJobInfo;

    // ���� Job �������¼�
  ResetJobInfo;
end;

{ TTransferDownJobOnlineHandle }

procedure TTransferDownJobOnlineHandle.FindMyJobInfo;
begin
  TransferJobChangeInfo := TDownloadJobChangeInfo.Create;
end;

procedure TTransferDownJobOnlineHandle.FindTransferFaceInfo;
begin
  RootID := RootID_DownPend;
end;

{ TTransferUpJobOnlineHandle }

procedure TTransferUpJobOnlineHandle.FindMyJobInfo;
begin
  TransferJobChangeInfo := TUploadJobChangeInfo.Create;
end;

procedure TTransferUpJobOnlineHandle.FindTransferFaceInfo;
begin
  RootID := RootID_UpPend;
end;

procedure TTransferUpJobOnlineHandle.ResetBackupJobInfo;
var
  BackupCopyAddPendHandle : TBackupCopyAddPendHandle;
begin
    // ��� Pending
  BackupCopyAddPendHandle := TBackupCopyAddPendHandle.Create( JobInfo.getLoadPath );
  BackupCopyAddPendHandle.SetCopyOwner( PcID );
  BackupCopyAddPendHandle.Update;
  BackupCopyAddPendHandle.Free;
end;

procedure TTransferUpJobOnlineHandle.ResetJobInfo;
begin
    // ���� ���� Job
  if JobInfo.getJobType = JobType_Backup then
    ResetBackupJobInfo;
end;

{ TTransferRestoreJobAddHandle }

procedure TTransferRestoreJobAddHandle.FindTransferFaceInfo;
begin
  inherited;

  FileType := FileType_Restore;
end;

function TTransferRestoreJobAddHandle.getPendingJobInfo: TPendingJobInfo;
var
  RestoreJobInfo : TRestoreJobInfo;
begin
  RestoreJobInfo := TRestoreJobInfo.Create;
  RestoreJobInfo.SetBackupFileInfo( RestorePcID );
  Result := RestoreJobInfo;
end;

procedure TTransferRestoreJobAddHandle.OfflineJobHandle;
var
  VstRestoreDownChildOffline : TVstRestoreDownChildOffline;
begin
  VstRestoreDownChildOffline := TVstRestoreDownChildOffline.Create( FilePath, RestorePcID );
  MyRestoreFileFace.AddChange( VstRestoreDownChildOffline );
end;

procedure TTransferRestoreJobAddHandle.SetRestorePcID(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

{ TTransferSearchDownJobAddHandle }

function TTransferBackupSearchJobAddHandle.getPendingJobInfo: TPendingJobInfo;
var
  BackupSearchJobInfo : TBackupSearchJobInfo;
begin
  BackupSearchJobInfo := TBackupSearchJobInfo.Create;
  BackupSearchJobInfo.SetBackupFileInfo( SourcePcID );
  Result := BackupSearchJobInfo;
end;

procedure TTransferBackupSearchJobAddHandle.OfflineJobHandle;
var
  VstSearchDownOffline : TVstSearchDownOffline;
begin
  VstSearchDownOffline := TVstSearchDownOffline.Create( SourcePcID, FilePath );
  MySearchFileFace.AddChange( VstSearchDownOffline );
end;

procedure TTransferBackupSearchJobAddHandle.SetSourcePcID(_SourcePcID: string);
begin
  SourcePcID := _SourcePcID;
end;

{ TTransferSourceSearchJobAddHandle }

function TTransferSourceSearchJobAddHandle.getPendingJobInfo: TPendingJobInfo;
begin
  Result := TSourceSearchJobInfo.Create;
end;

procedure TTransferSourceSearchJobAddHandle.OfflineJobHandle;
var
  VstSearchDownOffline : TVstSearchDownOffline;
begin
  VstSearchDownOffline := TVstSearchDownOffline.Create( DesPcID, FilePath );
  MySearchFileFace.AddChange( VstSearchDownOffline );
end;

{ TTransferSearchJobAddHandle }

procedure TTransferSearchJobAddHandle.FindTransferFaceInfo;
begin
  inherited;
  FileType := FileType_Search;
end;

end.
