unit UBackupCow;

interface

uses Forms, Windows, SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, uDebug, IniFiles;

type

    // ��ȡ Xml �ļ�
  TMyXmlReadThread = class( TThread )
  public
    IsRun : Boolean;
  private
    SendFileCount : Integer;
    ShareDownCount : Integer;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure ReadXmlFileHandle;
    procedure SetXmlDefaulHandle;
  private
    procedure ReacNetPcXml;
    procedure ReadCloudXml;
    procedure ReadFileSendXml;
    procedure ReadFileReceiveXml;
    procedure ReadSharePathXml;
    procedure ReadShareDownXml;
    procedure ReadShareHistoryXml;
    procedure ReadShareFavoriteXml;
    procedure ReadLocalBackupDesXml;
    procedure ReadLocalBackupSourceXml;
    procedure ReadBackupNotifyXml;
    procedure ReadBatRegisterXml;
    procedure ReadSearchDownXml;
    procedure ReadRestoreFileXml;
    procedure ReadBackupXml;
    procedure ReadBackupNewXml;
    procedure ReadCloudNewXml;
    procedure ReadRestoreNewXml;
  private
    procedure WaitXmlReadCompleted;
    procedure LoadingCompleted;
    procedure StartBackupFileLostConn;
    procedure StartNetwork;
    procedure MarkAppRunTime;
  private
    procedure AddDefaultCloudPath;
    procedure AddDefaultLocalBackupDesPath;
    procedure StartRevFace;
  end;

    // BackupCow ����
  TBackupCowCreate = class
  public
    procedure Update;
  private
    procedure CreateSettingInfo;
    procedure CreateWriteManual;
    procedure CreateWriteXml;
    procedure CreateWriteFace;
  private
    procedure CreateLocalBackup;
    procedure CreateBackup;
    procedure CreateBackupNew;
    procedure CreateCloudNew;
    procedure CreateRestoreNew;
    procedure CreateCloud;
    procedure CreateJob;
    procedure CreateFileConfirm;
    procedure CreateSearch;
    procedure CreateFileTransfer;
    procedure CreateFileShare;
    procedure CreateNetwork;
  private
    procedure CreateControl;
    procedure LoadSetting;
    procedure CreateReadXml;
  end;

    // BackupCow ����
  TBackupCowDestory = class
  public
    procedure Update;
  private
    procedure DestoryReadXml;
    procedure DestoryControl;
    procedure StopWriteThread;
  private
    procedure DestoryNetwork;
    procedure DestoryFileShare;
    procedure DestoryFileTransfer;
    procedure DestorySearch;
    procedure DestoryFileConfirm;
    procedure DestoryJob;
    procedure DestoryCloud;
    procedure DestoryResotreNew;
    procedure DestoryCloudNew;
    procedure DestoryBackupNew;
    procedure DestoryLocalBackup;
    procedure DestoryBackup;
  private
    procedure DestoryWriteFace;
    procedure DestoryWriteXml;
    procedure DestoryWriteManual;
    procedure DestorySettingInfo;
  end;

    // BackupCow ���ĳ���
  TBackupCow = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  HttpMarkApp_HardCode = 'HardCode';
  HttpMarkApp_PcID = 'PcID';
  HttpMarkApp_PcName = 'PcName';
  HttpMarkApp_LocalBackup = 'LocalBackup';
  HttpMarkApp_NetworkBackup = 'NetworkBackup';
  HttpMarkApp_NetworkMode = 'NetworkMode';
  HttpMarkApp_SendFile = 'SendFile';
  HttpMarkApp_ShareDown = 'ShareDown';

var
  BackupCow : TBackupCow;
  MyXmlReadThread : TMyXmlReadThread;

implementation

uses UMyBackupInfo, UBackupInfoControl, UBackupInfoFace, UBackupFileScan, UBackupInfoXml, UMyBackupRemoveInfo,
    UBackupFileLostConn, UBackupBoardInfo, UMyBackupRemoveXml, UBackupAutoSyncInfo,
     ULocalBackupInfo, ULocalBackupXml, ULocalBackupFace, ULocalBackupControl, ULocalBackupScan, ULocalBackupAutoSync,
     UMyBackupDataInfo, UMyBackupApiInfo, UMyBackupXmlInfo, UBackupThread,
     UMyCloudDataInfo, UMyCloudXmlInfo, UCloudBackupThread,
     UMyRestoreDataInfo, UMyRestoreXmlInfo,
     UMyNetPcInfo, UNetworkControl, USearchServer, UFormBroadcast,UNetworkFace, UNetPcInfoXml,
     UMyMaster, UMyServer, UMyClient, UMyTcp,
     UCloudPathInfoXml, UMyCloudPathInfo, URegisterInfo, UCloudFileScan,
     UBackupJobScan, UJobFace, UJobControl, UMyFileDownload, UMyFileUpload, UMyFileTransfer, UMyJobInfo,
     UMyFileSearch, USearchFileFace, UFileSearchControl, UMySearchDownInfo, UMySearchDownXml,
     UMyCloudFileControl, UBackupFileConfirm,
     UFormRestorePath, URestoreFileFace, UMyRestoreFileInfo, UMyRestoreFileXml, UPortMap,
     UFileTransferFace, UMyFileTransferControl, UTransferJobScan, UMyFileTransferInfo, UMyFileTransferXml,
     UMyShareScan, UMyShareControl, UMyShareXml, UMyShareFace, UMyShareInfo,
     UXmlUtil, UMainForm, uLkJSON, UMyUtil, UChangeInfo, UMyUrl,
     USettingInfo, UFormSetting, UMainFormFace, UFormRegisterNew, IdHTTP;

{ TBackupCowCreate }

procedure TBackupCowCreate.CreateRestoreNew;
begin
  MyRestoreDownInfo := TMyRestoreDownInfo.Create;
end;

procedure TBackupCowCreate.CreateBackup;
begin
    // ���� ·��/Ŀ¼/�ļ� ��Ϣ ���ݽṹ
  MyBackupFileInfo := TMyBackupFileInfo.Create;

    // ���������ļ� ɨ����Ϣ
  MyBackupFileScanInfo := TMyBackupFileScanInfo.Create;

    // ɾ���ļ� ֪ͨ
  MyBackupRemoveNotifyInfo := TMyBackupRemoveNotifyInfo.Create;

    // ��ʱ��� ���� Pc
  MyBackupFileLostConnInfo := TMyBackupFileLostConnInfo.Create;

    // ������Ϣ ������
  MyBackupBoardInfo := TMyBackupBoardInfo.Create;

    // ��ʱ�Զ�����
  MyBackupAutoSyncInfo := TMyBackupAutoSyncInfo.Create;
end;

procedure TBackupCowCreate.CreateBackupNew;
begin
  MyBackupInfo := TMyBackupInfo.Create;

  MyBackupHandler := TMyBackupHandler.Create;
end;

procedure TBackupCowCreate.CreateCloud;
begin
    // �� ·��/Ŀ¼/�ļ� ��Ϣ ���ݽṹ
  MyCloudFileInfo := TMyCloudFileInfo.Create;

    // ��ע����Ϣ
  MyBatRegisterInfo := TMyBatRegisterInfo.Create;

    // ���ļ� ɨ��
  MyCloudFileScanner := TMyCloudFileScanner.Create;
end;

procedure TBackupCowCreate.CreateCloudNew;
begin
  MyCloudInfo := TMyCloudInfo.Create;
  MyCloudBackupHandler := TMyCloudBackupHandler.Create;
end;

procedure TBackupCowCreate.CreateControl;
begin
    // ������Ϣ
  MyBackupFileControl := TMyBackupFileControl.Create;

    // Job/���� ��Ϣ
  MyJobControl := TMyJobControl.Create;

    // ������Ϣ
  MyFileSearchControl := TMyFileSearchControl.Create;

    // ������Ϣ
  MyNetworkControl := TMyNetworkControl.Create;

    // ���ļ���Ϣ
  MyCloudFileControl := TMyCloudFileControl.Create;

    // �ļ�����
  MyFileTransferControl := TMyFileTransferControl.Create;

    // �ļ�����
  MyFileShareControl := TMyFileShareControl.Create;

    // ��������
  MyLocalBackupSourceControl := TMyLocalBackupSourceControl.Create;
  MyLocalBackupDesControl := TMyLocalBackupDesControl.Create;

    // ע��
  MyRegisterControl := TMyRegisterControl.Create;
end;

procedure TBackupCowCreate.CreateFileConfirm;
begin
  MyFileConfirm := TMyFileConfirm.Create;
  MyFileAcceptConfirm := TMyFileAcceptConfirm.Create;
end;

procedure TBackupCowCreate.CreateFileShare;
begin
  MyFileShareScanInfo := TMyFileShareScanInfo.Create;
  MySharePathInfo := TMySharePathInfo.Create;
  MyShareDownInfo := TMyShareDownInfo.Create;
end;

procedure TBackupCowCreate.CreateFileTransfer;
begin
  MyTransferJobScanInfo := TMyTransferJobScanInfo.Create;
  MyFileReceiveInfo := TMyFileReceiveInfo.Create;
  MyFileSendInfo := TMyFileSendInfo.Create;
end;

procedure TBackupCowCreate.CreateJob;
begin
    // Job ��Ϣ
  MyJobInfo := TMyJobInfo.Create;

    // �ļ��ϴ� ������
  MyFileUpload := TMyFileUpload.Create;

    // �ļ����� ������
  MyFileDownload := TMyFileDownload.Create;

    // job ɨ��
  MyBackupJobScanInfo := TMyBackupJobScanInfo.Create;
end;

procedure TBackupCowCreate.CreateLocalBackup;
begin
    // ���ر��� Դ��Ϣ
  MyLocalBackupSourceInfo := TMyLocalBackupSourceInfo.Create;

    // ���ر��� Ŀ����Ϣ
  MyLocalBackupDesInfo := TMyLocalBackupDesInfo.Create;

    // ���ر��� ɨ���߳�
  MyLocalBackupHandler := TMyLocalBackupHandler.Create;

    // �Զ� ͬ����
  MyLocalAutoSyncHandler := TMyLocalAutoSyncHandler.Create;
  
    // ״̬��ʾ�߳�
  MyLocalBackupStatusShow := TMyLocalBackupStatusShow.Create;
end;

procedure TBackupCowCreate.CreateNetwork;
begin
    // ������ Pc ��Ϣ
  PcInfo := TPcInfo.Create;
  Randomize;
  PcInfo.SetSortInfo( Now, Random( 1000000 ) );
  PcInfo.SetPcHardCode( MyMacAddress.getStr );

    // ����ģʽ
  NetworkModeInfo := TLanNetworkMode.Create;

    // Master ��Ϣ
  MasterInfo := TMasterInfo.Create;

    // �������� ���ݽṹ
  MyNetPcInfo := TMyNetPcInfo.Create;

      // C/S ����
  MyServer := TMyServer.Create;
  MyClient := TMyClient.Create;

    // �������� ���������
  frmBroadcast := TfrmBroadcast.Create;
  MyMasterConn := TMyMasterConn.Create;
  MyMasterAccept := TMyMasterAccept.Create;

    // ��������
  MyListener := TMyListener.Create;

    // ���� Master
  MasterThread := TMasterThread.Create;
  MyClient.OnResetMaster :=MasterThread.RestartNetwork;
end;

procedure TBackupCowCreate.CreateReadXml;
begin
  MyXmlReadThread := TMyXmlReadThread.Create;
  MyXmlReadThread.Resume;
end;

procedure TBackupCowCreate.CreateSearch;
begin
    // �������� ��Ϣ
  MyFileSearchReq := TMyFileSearchReq.Create;

    // ����ɨ�� ��Ϣ
  MyFileSearchScan := TMyFileSearchScan.Create;

    // �ָ����� ��Ϣ
  MyFileRestoreReq := TMyFileRestoreReq.Create;

    // �ָ�ɨ�� ��Ϣ
  MyFileRestoreScan := TMyFileRestoreScan.Create;

    // �������� ��Ϣ
  MySearchDownInfo := TMySearchDownInfo.Create;

    // �ָ��ļ� ��Ϣ
  MyRestoreFileInfo := TMyRestoreFileInfo.Create;
end;

procedure TBackupCowCreate.CreateSettingInfo;
begin
  PcSettingInfo := TPcSettingInfo.Create;

  TransferSettingInfo := TTransferSettingInfo.Create;
  TransferSafeSettingInfo := TTransferSafeSettingInfo.Create;

  BackupFileSafeSettingInfo := TBackupFileSafeSettingInfo.Create;
  SyncTimeSettingInfo := TSyncTimeSettingInfo.Create;
  BackupFileEncryptSettingInfo := TBackupFileEncryptSettingInfo.Create;

  ShareSettingInfo := TShareSettingInfo.Create;
  CloudSafeSettingInfo := TCloudSafeSettingInfo.Create;
  CloudFileSafeSettingInfo := TCloudFileSafeSettingInfo.Create;

  FileVisibleSettingInfo := TFileVisibleSettingInfo.Create;

  ApplicationSettingInfo := TApplicationSettingInfo.Create;

  FileReceiveSettingInfo := TFileReceiveSettingInfo.Create;

  FileSearchDownSettingInfo := TFileSearchDownSettingInfo.Create;

  StandardNetworkSettingInfo :=  TStandardNetworkSettingInfo.Create;
  AdvanceNetworkSettingInfo := TAdvanceNetworkSettingInfo.Create;
end;

procedure TBackupCowCreate.CreateWriteFace;
var
  i : Integer;
  RootID, RootName : string;
  VirTransferRootAddInfo : TVirTransferRootAddInfo;
begin
    // ���� ���� �ܿ�����
  MyFaceChange := TMyFaceChange.Create;

    // ������ �������
  MyMainFormFace := TMyChildFaceChange.Create;

    // ������Ϣ
  MyBackupFileFace := TMyChildFaceChange.Create;
  BackupBoardInvisibleThread := TBackupBoardInvisibleThread.Create;
  BackupProgressHideThread := TBackupProgressHideThread.Create;

    // ����/Job ��Ϣ
  MyJobFace := TMyJobFace.Create;

    // ��ʼ�� ���� ����
  for i := 0 to Ary_TransferCount - 1 do
  begin
    RootID := Ary_TransferRoot[i][ Ary_RootID ];
    RootName := Ary_TransferRoot[i][ Ary_RootName ];
    RootName := frmMainForm.siLang_frmMainForm.GetText( RootID );
    VirTransferRootAddInfo := TVirTransferRootAddInfo.Create( RootID );
    VirTransferRootAddInfo.SetRootName( RootName );
    MyJobFace.AddChange( VirTransferRootAddInfo );
  end;

    // ������Ϣ
  MySearchFileFace := TMyChildFaceChange.Create;

    // ������Ϣ
  Network_LocalPcID := MyComputerID.get;
  MyNetworkFace := TMyChildFaceChange.Create;
  NetworkLvItemHideThread := TNetworkLvItemHideThread.Create;
  MyCloudPcChartRefreshThread := TMyCloudPcChartRefreshThread.Create;

    // �ָ��ļ���Ϣ
  MyRestoreFileFace := TMyRestoreFileFace.Create;

    // �ļ�������Ϣ
  VstFileSendDesHideThread := TVstFileSendDesHideThread.Create;

    // �ļ�����
  VstShareFilePcHideThread := TVstShareFilePcHideThread.Create;

    // ������ �����ٶ�
  TransferSpeedFaceThread := TTransferSpeedFaceThread.Create;
  TransferSpeedFaceThread.Resume;
end;

procedure TBackupCowCreate.CreateWriteManual;
begin
  MyManualChange := TMyChangeInfo.Create;
end;

procedure TBackupCowCreate.CreateWriteXml;
begin
    // Xml ���ĵ� ��ʼ��
  MyXmlDoc := frmMainForm.XmlDoc;
  MyXmlDoc.Active := True;
  if FileExists( MyXmlUtil.getXmlPath ) then
    MyXmlDoc.LoadFromFile( MyXmlUtil.getXmlPath );
  MyXmlUtil.IniXml;

    // Xml ��ʼ��
  MyXmlChange := TMyXmlChange.Create;
  MyXmlSave := TMyXmlSave.Create;

    // ������Ϣ
  MyBackupXmlWrite := TMyChildXmlChange.Create;
  MyBackupFileRemoveWriteXml := TMyBackupFileRemoveWriteXml.Create;

    // ����Ϣ
  MyCloudPathXmlWrite := TMyChildXmlChange.Create;

    // ���� Pc ��Ϣ
  MyNetPcXmlWrite := TMyChildXmlChange.Create;

    // ����ע�� ��Ϣ
  MyBatRegisteWriterXml := TMyBatRegisteWriterXml.Create;

    // ���������ļ� ��Ϣ
  MySearchDownWriteXml := TMyChildXmlChange.Create;
end;

procedure TBackupCowCreate.LoadSetting;
begin
  frmSetting.LoadIni;
  frmSetting.SetFirstApplySettings;
  frmSetting.LoadNetworkMode;
end;

procedure TBackupCowCreate.Update;
begin
  CreateSettingInfo;  // Setting ��Ϣ
  CreateWriteManual; // д �˹� ��Ϣ
  CreateWriteXml;  // д Xml ��Ϣ
  CreateWriteFace; // д �������

  CreateBackup; // ������Ϣ
  CreateLocalBackup;  // ���ر�����Ϣ
  CreateBackupNew;
  CreateCloudNew;
  CreateRestoreNew;
  CreateCloud;  // ����Ϣ
  CreateJob;     // Job ��Ϣ
  CreateFileConfirm; // �ļ�ȷ��
  CreateSearch; // ������Ϣ
  CreateFileTransfer; // �ļ�������Ϣ
  CreateFileShare; // �ļ�������Ϣ
  CreateNetwork; // ������Ϣ

  LoadSetting;  // ���� Setting ����
  CreateControl;  // �û�������
  CreateReadXml;  // �� Xml ��Ϣ
end;

{ TBackupCowDestory }

procedure TBackupCowDestory.DestoryBackup;
begin
  MyBackupAutoSyncInfo.Free;
  MyBackupBoardInfo.Free;
  MyBackupFileLostConnInfo.Free;
  MyBackupRemoveNotifyInfo.Free;
  MyBackupFileScanInfo.Free;
  MyBackupFileInfo.Free;
end;


procedure TBackupCowDestory.DestoryBackupNew;
begin
  MyBackupHandler.Free;
  MyBackupInfo.Free;
end;

procedure TBackupCowDestory.DestoryCloud;
begin
  MyCloudFileScanner.Free;
  MyBatRegisterInfo.Free;
  MyCloudFileInfo.Free;
end;

procedure TBackupCowDestory.DestoryCloudNew;
begin
  MyCloudBackupHandler.Free;
  MyCloudInfo.Free;
end;

procedure TBackupCowDestory.DestoryControl;
begin
  MyRegisterControl.Free;
  MyLocalBackupDesControl.Free;
  MyLocalBackupSourceControl.Free;
  MyFileShareControl.Free;
  MyFileTransferControl.Free;
  MyCloudFileControl.Free;
  MyBackupFileControl.Free;
  MyNetworkControl.Free;
  MyJobControl.Free;
  MyFileSearchControl.Free;
end;

procedure TBackupCowDestory.DestoryFileConfirm;
begin
  MyFileConfirm.Free;
  MyFileAcceptConfirm.Free;
end;

procedure TBackupCowDestory.DestoryFileShare;
begin
  MyShareDownInfo.Free;
  MySharePathInfo.Free;
  MyFileShareScanInfo.Free;
end;

procedure TBackupCowDestory.DestoryFileTransfer;
begin
  MyTransferJobScanInfo.Free;
  MyFileReceiveInfo.Free;
  MyFileSendInfo.Free;
end;

procedure TBackupCowDestory.DestoryJob;
begin
  MyBackupJobScanInfo.Free;
  MyJobInfo.IsTransfer := False;
  MyFileUpload.Free;
  MyFileDownload.Free;
  MyJobInfo.Free;
end;

procedure TBackupCowDestory.DestoryLocalBackup;
begin
  MyLocalBackupStatusShow.Free;
  MyLocalAutoSyncHandler.Free;
  MyLocalBackupHandler.Free;
  MyLocalBackupDesInfo.Free;
  MyLocalBackupSourceInfo.Free;
end;

procedure TBackupCowDestory.DestoryNetwork;
begin
  DebugLog('5');

    // ֹͣ ���� Mster �߳�
  MasterThread.Free;

  DebugLog('6');

    // �ر� �����˿�
  MyListener.Free;

  DebugLog('7');

  MyMasterAccept.Free;
  MyMasterConn.Free;
  frmBroadcast.Free;

  DebugLog('8');

  MyClient.Free;

  DebugLog('9');

  MyServer.Free;

  DebugLog('10');

  MyNetPcInfo.Free;
  MasterInfo.Free;
  NetworkModeInfo.Free;
  PcInfo.Free;
end;

procedure TBackupCowDestory.DestoryReadXml;
begin
  MyXmlReadThread.Free;
end;

procedure TBackupCowDestory.DestoryResotreNew;
begin
  MyRestoreDownInfo.Free;
end;

procedure TBackupCowDestory.DestorySearch;
begin
  MyRestoreFileInfo.Free;
  MySearchDownInfo.Free;
  MyFileRestoreScan.Free;
  MyFileRestoreReq.Free;
  MyFileSearchReq.Free;
  MyFileSearchScan.Free;
end;

procedure TBackupCowDestory.DestorySettingInfo;
begin
  PcSettingInfo.Free;

  TransferSettingInfo.Free;
  TransferSafeSettingInfo.Free;

  BackupFileSafeSettingInfo.Free;
  SyncTimeSettingInfo.Free;
  BackupFileEncryptSettingInfo.Free;

  CloudFileSafeSettingInfo.Free;
  ShareSettingInfo.Free;
  CloudSafeSettingInfo.Free;

  FileVisibleSettingInfo.Free;

  ApplicationSettingInfo.Free;

  FileReceiveSettingInfo.Free;

  FileSearchDownSettingInfo.Free;

  StandardNetworkSettingInfo.Free;
  AdvanceNetworkSettingInfo.Free;
end;

procedure TBackupCowDestory.DestoryWriteFace;
begin
  TransferSpeedFaceThread.Free;
  VstFileSendDesHideThread.Free;
  MyRestoreFileFace.Free;
  MySearchFileFace.Free;
  MyJobFace.Free;
  MyCloudPcChartRefreshThread.Free;
  NetworkLvItemHideThread.Free;
  MyNetworkFace.Free;
  BackupProgressHideThread.Free;
  BackupBoardInvisibleThread.Free;
  MyBackupFileFace.Free;
  MyMainFormFace.Free;
  MyFaceChange.Free;
end;

procedure TBackupCowDestory.DestoryWriteManual;
begin
  MyManualChange.Free;
end;

procedure TBackupCowDestory.DestoryWriteXml;
begin
    // ���� ���е� Xml ��Ϣ
  MyXmlChange.StopThread;

  MySearchDownWriteXml.Free;
  MyBackupFileRemoveWriteXml.Free;
  MyBatRegisteWriterXml.Free;
  MyNetPcXmlWrite.Free;
  MyCloudPathXmlWrite.Free;
  MyBackupXmlWrite.Free;
  MyXmlSave.Free;
  MyXmlChange.Free;
end;

procedure TBackupCowDestory.StopWriteThread;
begin
  DebugLog('--------------End------------');

    // ֹͣ ���չ㲥
  frmBroadcast.OnRevMsgEvent := nil;

  MyFileUpload.CancelTransfer;  // ȡ���ϴ�
  MyFileDownload.CancelTransfer; // ȡ������
  DebugLog('1');
  MyFileUpload.StopTransfer;   // ֹͣ�ϴ��ļ�
  DebugLog('2');
  MyFileDownload.StopTransfer; // ֹͣ�����ļ�
  DebugLog('3');

  MyListener.StopHandle; // ֹͣ��������

  MyMasterConn.StopThread;  // ֹͣ�ײ�����
  MyMasterAccept.StopThread; // ֹͣ�ײ� Accept

  MyClient.StopThread;  // ֹͣ�ͻ��˴������
  MyServer.StopThread;  // ֹͣ�������������

  DebugLog('4');

  MyFaceChange.StopThread; // ֹͣ�������
  MyManualChange.StopThread; // ֹͣ�˹���Ӵ���

    // ֹͣɨ��
  MyBackupHandler.StopScan;
  MyCloudBackupHandler.StopRun;

    // Network Backup
  MyBackupFileScanInfo.StopFileScan;  // ֹͣ�����ļ�ɨ��
  MyBackupFileInfo.StopThread;  // ֹͣ�����ļ���Ϣ����
  MyBackupRemoveNotifyInfo.StopThread; // ֹͣ
  MyBackupFileLostConnInfo.StopLostConnScan; // ֹͣ���ڼ��
  MyBackupBoardInfo.StopThread;
  MyBackupBoardInfo.StopBackupBoardShow;
  MyBackupAutoSyncInfo.StopSync;

  DebugLog('4.1');

    // Local Backup
  MyLocalAutoSyncHandler.StopThread;
  MyLocalBackupStatusShow.StopShow;
  MyLocalBackupHandler.StopScan;
  
  DebugLog('4.2.1');

  MyCloudFileScanner.StopScan; // ֹͣɨ��
  MyCloudFileInfo.StopThread;  // ֹͣ���ļ���Ϣ����

  DebugLog('4.2.2');

  MyFileConfirm.StopConfirm; // ֹͣ�ļ�ȷ��

  DebugLog( '4.2.2.1' );

  MyFileAcceptConfirm.StopConfirm; // ֹͣ�ļ�ȷ��

  DebugLog('4.2.3');

  MyBackupJobScanInfo.StopJobScan; // ֹͣ ����Jobɨ��
  MyJobInfo.StopThread;     // ֹͣ Job ��Ϣ����

  DebugLog('4.3');

  MyTransferJobScanInfo.StopScan; // ֹͣ�ļ�����ɨ��

  DebugLog('4.4');

  MyFileShareScanInfo.StopScan; // ֹͣ�ļ�����ɨ��
  VstShareFilePcHideThread.Free;

  MyFileSearchReq.StopThread;  // ֹͣ��������
  MyFileSearchScan.IsRun := False;
  MyFileSearchScan.StopThread; // ֹͣ����ɨ��

  MyFileRestoreReq.StopThread;  // ֹͣ �ָ�����
  MyFileRestoreScan.IsRun := False;
  MyFileRestoreScan.StopThread;
  MySearchDownInfo.StopThread;

  DebugLog('4.5');
end;

procedure TBackupCowDestory.Update;
begin
  try
    DestoryReadXml;
    DestoryControl;
    StopWriteThread;

    DestoryNetwork;
    DestoryFileShare;
    DestoryFileTransfer;
    DestorySearch;
    DestoryFileConfirm;
    DestoryJob;
    DestoryCloud;
    DestoryResotreNew;
    DestoryCloudNew;
    DestoryBackupNew;
    DestoryLocalBackup;
    DestoryBackup;

    DestoryWriteFace;
    DestoryWriteXml;
    DestoryWriteManual;
    DestorySettingInfo;
  Except
  end;
end;

{ TBackupCow }

constructor TBackupCow.Create;
var
  BackupCowCreate : TBackupCowCreate;
begin
  BackupCowCreate := TBackupCowCreate.Create;
  BackupCowCreate.Update;
  BackupCowCreate.Free;
end;

destructor TBackupCow.Destroy;
var
  BackupCowDestory : TBackupCowDestory;
begin
  BackupCowDestory := TBackupCowDestory.Create;
  BackupCowDestory.Update;
  BackupCowDestory.Free;

  inherited;
end;

{ TMyXmlReadThread }

procedure TMyXmlReadThread.AddDefaultCloudPath;
var
  DefaultCloudPathHandle : TDefaultCloudPathAddHandle;
begin
  DefaultCloudPathHandle := TDefaultCloudPathAddHandle.Create;
  DefaultCloudPathHandle.Update;
  DefaultCloudPathHandle.Free;
end;

procedure TMyXmlReadThread.AddDefaultLocalBackupDesPath;
var
  IsAddDefault : Boolean;
  DesPath : string;
  LocalBackupDesAddHandle : TLocalBackupDesAddHandle;
  MyDesDisableDefaultPathXml : TLocalBackupDesDisableDefaultPathXml;
begin
  DesPath := MyHardDisk.getBiggestHardDIsk + DefaultPath_Des;
  ForceDirectories( DesPath );

    // ��� Ĭ�ϵ� ���� ����Ŀ��·��
  LocalBackupDesAddHandle := TLocalBackupDesAddHandle.Create( DesPath );
  LocalBackupDesAddHandle.Update;
  LocalBackupDesAddHandle.Free;

    // ��ֹ��һ�����
  MyDesDisableDefaultPathXml := TLocalBackupDesDisableDefaultPathXml.Create;
  MyXmlChange.AddChange( MyDesDisableDefaultPathXml );
end;

constructor TMyXmlReadThread.Create;
begin
  inherited Create( True );
  IsRun := True;
end;

destructor TMyXmlReadThread.Destroy;
begin
  IsRun := False;
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TMyXmlReadThread.Execute;
begin
  Sleep( 1000 );

    // Xml �ļ����ڣ� ���ȡ Xml �ļ���Ϣ
  if FileExists( MyXmlUtil.getXmlPath ) then
    ReadXmlFileHandle
  else
    SetXmlDefaulHandle;  // ����Ĭ��ֵ

    // �����ļ����
  LoadingCompleted;

    // ��ʼ���� Xml ��ʱ����
  MyXmlSave.StartThread;

    // ��ʼ ��ʱ��� �����ļ�
  StartBackupFileLostConn;

    // ��������
  StartNetwork;

    // �ڷ�������¼
  MarkAppRunTime;

  inherited;
end;

procedure TMyXmlReadThread.LoadingCompleted;
begin
  if not IsRun then
    Exit;

  frmMainForm.tmrDragBackground.Enabled := True;
end;

procedure TMyXmlReadThread.MarkAppRunTime;
var
  IniFile : TIniFile;
  HardCode, PcID, PcName, NetworkMode : string;
  LocalBackupItem, NetworkBackupItem : Integer;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
    // ������Ϣ
  HardCode := MyMacAddress.getStr;
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  NetworkMode := IniFile.ReadString( Ini_NetworkMode, Ini_SelectedMode, NetworkModeShow_LAN );
  IniFile.Free;
  LocalBackupItem := MyLocalBackupSourceInfo.LocalBackupSourceList.Count;
  NetworkBackupItem := MyBackupFileInfo.BackupPathList.Count;

    // ��¼����ȡ���� Pc ��Ϣ
  params := TStringList.Create;
  params.Add( HttpMarkApp_HardCode + '=' + HardCode );
  params.Add( HttpMarkApp_PcID + '=' + PcID );
  params.Add( HttpMarkApp_PcName + '=' + PcName );
  params.Add( HttpMarkApp_NetworkMode + '=' + NetworkMode );
  params.Add( HttpMarkApp_LocalBackup + '=' + IntToStr( LocalBackupItem ) );
  params.Add( HttpMarkApp_NetworkBackup + '=' + IntToStr( NetworkBackupItem ) );
  params.Add( HttpMarkApp_SendFile + '=' + IntToStr( SendFileCount ) );
  params.Add( HttpMarkApp_ShareDown + '=' + IntToStr( ShareDownCount ) );

  idhttp := TIdHTTP.Create(nil);
  try
    idhttp.Post( MyUrl.getAppRunMark , params );
  except
  end;
  idhttp.Free;

  params.free;
end;

procedure TMyXmlReadThread.ReacNetPcXml;
var
  NetPcXmlRead : TNetPcXmlRead;
begin
  if not IsRun then
    Exit;

  NetPcXmlRead := TNetPcXmlRead.Create;
  NetPcXmlRead.Update;
  NetPcXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadBackupNewXml;
var
  LocalBackupReadXmlHandle : TBackupReadXmlHandle;
begin
  LocalBackupReadXmlHandle := TBackupReadXmlHandle.Create;
  LocalBackupReadXmlHandle.Update;
  LocalBackupReadXmlHandle.Free;

    // ��ʼ�� ���ػָ���Ϣ
  BackupItemAppApi.RefreshLocalRestoreItem;
end;

procedure TMyXmlReadThread.ReadBackupNotifyXml;
var
  BackupRemoveNotifyRead : TBackupRemoveNotifyRead;
begin
  if not IsRun then
    Exit;

  BackupRemoveNotifyRead := TBackupRemoveNotifyRead.Create;
  BackupRemoveNotifyRead.Update;
  BackupRemoveNotifyRead.Free;
end;

procedure TMyXmlReadThread.ReadBackupXml;
var
  MyBackupXmlRead : TMyBackupXmlRead;
begin
  if not IsRun then
    Exit;

  MyBackupXmlRead := TMyBackupXmlRead.Create;
  MyBackupXmlRead.Update;
  MyBackupXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadBatRegisterXml;
var
  BatRegisterXmlRead : TBatRegisterXmlRead;
begin
  if not IsRun then
    Exit;

  BatRegisterXmlRead := TBatRegisterXmlRead.Create;
  BatRegisterXmlRead.Update;
  BatRegisterXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadCloudNewXml;
var
  MyCloudInfoReadXml : TMyCloudInfoReadXml;
begin
  if not IsRun then
    Exit;

  MyCloudInfoReadXml := TMyCloudInfoReadXml.Create;
  MyCloudInfoReadXml.Update;
  MyCloudInfoReadXml.Free;
end;

procedure TMyXmlReadThread.ReadCloudXml;
var
  MyCloudFileXmlRead : TMyCloudFileXmlRead;
begin
  if not IsRun then
    Exit;

  MyCloudFileXmlRead := TMyCloudFileXmlRead.Create;
  MyCloudFileXmlRead.Update;
  MyCloudFileXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadFileReceiveXml;
var
  FileReceiveReadXml : TFileReceiveReadXml;
begin
  FileReceiveReadXml := TFileReceiveReadXml.Create;
  FileReceiveReadXml.Update;
  FileReceiveReadXml.Free;
end;

procedure TMyXmlReadThread.ReadFileSendXml;
var
  FileSendReadXml : TFileSendReadXml;
begin
  if not IsRun then
    Exit;

  FileSendReadXml := TFileSendReadXml.Create;
  FileSendReadXml.Update;
  FileSendReadXml.Free;

  SendFileCount := MyFileSendXmlUtil.getTotalCount;
end;

procedure TMyXmlReadThread.ReadShareDownXml;
var
  ShareDownXmlRead : TShareDownXmlRead;
begin
  if not IsRun then
    Exit;

  ShareDownXmlRead := TShareDownXmlRead.Create;
  ShareDownXmlRead.Update;
  ShareDownXmlRead.Free;

  ShareDownCount := MyShareDownXmlUtil.getTotalCount;
end;

procedure TMyXmlReadThread.ReadShareFavoriteXml;
var
  ShareFavoriteXmlRead : TShareFavoriteXmlRead;
begin
  if not IsRun then
    Exit;

  ShareFavoriteXmlRead := TShareFavoriteXmlRead.Create;
  ShareFavoriteXmlRead.Update;
  ShareFavoriteXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadShareHistoryXml;
var
  ShareHistoryXmlRead : TShareHistoryXmlRead;
begin
  if not IsRun then
    Exit;

  ShareHistoryXmlRead := TShareHistoryXmlRead.Create;
  ShareHistoryXmlRead.Update;
  ShareHistoryXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadSharePathXml;
var
  SharePathXmlRead : TSharePathXmlRead;
begin
  if not IsRun then
    Exit;

  SharePathXmlRead := TSharePathXmlRead.Create;
  SharePathXmlRead.Update;
  SharePathXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadXmlFileHandle;
begin
    // �� ����Pc��Ϣ
  ReacNetPcXml;

    // �� ����Ϣ
  ReadCloudXml;

    // �� �����ļ���Ϣ
  ReadFileSendXml;

    // �� �����ļ���Ϣ
  ReadFileReceiveXml;

    // �� �ҵĹ���·����Ϣ
  ReadSharePathXml;

    // �� ������ʷ��Ϣ
  ReadShareHistoryXml;

    // �� �����ղؼ���Ϣ
  ReadShareFavoriteXml;

    // ��ȡ ���ع���·����Ϣ
  ReadShareDownXml;

    // �� ���ر��� Ŀ����Ϣ
  ReadLocalBackupDesXml;

    // �� �������� Դ��Ϣ
  ReadLocalBackupSourceXml;

    // �� ��ע����Ϣ
  ReadBatRegisterXml;

    // �� ����������Ϣ
  ReadSearchDownXml;

    // �� �ָ��ļ���Ϣ
  ReadRestoreFileXml;

    // �� �����ļ�ɾ����Ϣ
  ReadBackupNotifyXml;

    // �� ������Ϣ
  ReadBackupNewXml;

    // �� ����Ϣ
  ReadCloudNewXml;

    // �� ������Ϣ
  ReadBackupXml;

    // �ȴ����ؽ���
  WaitXmlReadCompleted;
end;

procedure TMyXmlReadThread.ReadLocalBackupDesXml;
var
  MyDestinationXmlRead : TLocalBackupDesXmlRead;
begin
  MyDestinationXmlRead := TLocalBackupDesXmlRead.Create;
  MyDestinationXmlRead.Update;
  MyDestinationXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadLocalBackupSourceXml;
var
  LocalBackupSourceXmlRead : TLocalBackupSourceXmlRead;
begin
  LocalBackupSourceXmlRead := TLocalBackupSourceXmlRead.Create;
  LocalBackupSourceXmlRead.Update;
  LocalBackupSourceXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadRestoreFileXml;
var
  RestoreFileXmlRead : TRestoreFileXmlRead;
begin
  RestoreFileXmlRead := TRestoreFileXmlRead.Create;
  RestoreFileXmlRead.Update;
  RestoreFileXmlRead.Free;
end;

procedure TMyXmlReadThread.ReadRestoreNewXml;
var
  MyRestoreDownReadXml : TMyRestoreDownReadXml;
begin
  MyRestoreDownReadXml := TMyRestoreDownReadXml.Create;
  MyRestoreDownReadXml.Update;
  MyRestoreDownReadXml.Free;
end;

procedure TMyXmlReadThread.ReadSearchDownXml;
var
  SearchDownXmlRead : TSearchDownXmlRead;
begin
  SearchDownXmlRead := TSearchDownXmlRead.Create;
  SearchDownXmlRead.Update;
  SearchDownXmlRead.Free;
end;

procedure TMyXmlReadThread.SetXmlDefaulHandle;
begin
  AddDefaultCloudPath;
  AddDefaultLocalBackupDesPath;
  StartRevFace;
end;

procedure TMyXmlReadThread.StartBackupFileLostConn;
begin
  if not IsRun then
    Exit;

  MyBackupFileLostConnInfo.StartLostConnScan;
end;

procedure TMyXmlReadThread.StartNetwork;
begin
  if not IsRun then
    Exit;

    // ���� Master
  MasterThread.Resume;
end;

procedure TMyXmlReadThread.StartRevFace;
var
  LvFileReceiveStartInfo : TLvFileReceiveStartInfo;
begin
  LvFileReceiveStartInfo := TLvFileReceiveStartInfo.Create;
  MyFaceChange.AddChange( LvFileReceiveStartInfo );
end;

procedure TMyXmlReadThread.WaitXmlReadCompleted;
begin
    // �ȴ� Net Pc ����
  while IsRun and not ReadBackupXml_IsCompleted do
    Sleep(100);
end;

end.
