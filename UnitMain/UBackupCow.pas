unit UBackupCow;

interface

uses Forms, Windows, SysUtils, Classes, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, uDebug, IniFiles;

type

    // 读取 Xml 文件
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

    // BackupCow 创建
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

    // BackupCow 销毁
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

    // BackupCow 核心程序
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
    // 备份 路径/目录/文件 信息 数据结构
  MyBackupFileInfo := TMyBackupFileInfo.Create;

    // 新增备份文件 扫描信息
  MyBackupFileScanInfo := TMyBackupFileScanInfo.Create;

    // 删除文件 通知
  MyBackupRemoveNotifyInfo := TMyBackupRemoveNotifyInfo.Create;

    // 定时检测 过期 Pc
  MyBackupFileLostConnInfo := TMyBackupFileLostConnInfo.Create;

    // 备份信息 公告栏
  MyBackupBoardInfo := TMyBackupBoardInfo.Create;

    // 定时自动备份
  MyBackupAutoSyncInfo := TMyBackupAutoSyncInfo.Create;
end;

procedure TBackupCowCreate.CreateBackupNew;
begin
  MyBackupInfo := TMyBackupInfo.Create;

  MyBackupHandler := TMyBackupHandler.Create;
end;

procedure TBackupCowCreate.CreateCloud;
begin
    // 云 路径/目录/文件 信息 数据结构
  MyCloudFileInfo := TMyCloudFileInfo.Create;

    // 云注册信息
  MyBatRegisterInfo := TMyBatRegisterInfo.Create;

    // 云文件 扫描
  MyCloudFileScanner := TMyCloudFileScanner.Create;
end;

procedure TBackupCowCreate.CreateCloudNew;
begin
  MyCloudInfo := TMyCloudInfo.Create;
  MyCloudBackupHandler := TMyCloudBackupHandler.Create;
end;

procedure TBackupCowCreate.CreateControl;
begin
    // 备份信息
  MyBackupFileControl := TMyBackupFileControl.Create;

    // Job/传输 信息
  MyJobControl := TMyJobControl.Create;

    // 搜索信息
  MyFileSearchControl := TMyFileSearchControl.Create;

    // 网络信息
  MyNetworkControl := TMyNetworkControl.Create;

    // 云文件信息
  MyCloudFileControl := TMyCloudFileControl.Create;

    // 文件传输
  MyFileTransferControl := TMyFileTransferControl.Create;

    // 文件共享
  MyFileShareControl := TMyFileShareControl.Create;

    // 本机备份
  MyLocalBackupSourceControl := TMyLocalBackupSourceControl.Create;
  MyLocalBackupDesControl := TMyLocalBackupDesControl.Create;

    // 注册
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
    // Job 信息
  MyJobInfo := TMyJobInfo.Create;

    // 文件上传 控制器
  MyFileUpload := TMyFileUpload.Create;

    // 文件下载 控制器
  MyFileDownload := TMyFileDownload.Create;

    // job 扫描
  MyBackupJobScanInfo := TMyBackupJobScanInfo.Create;
end;

procedure TBackupCowCreate.CreateLocalBackup;
begin
    // 本地备份 源信息
  MyLocalBackupSourceInfo := TMyLocalBackupSourceInfo.Create;

    // 本地备份 目标信息
  MyLocalBackupDesInfo := TMyLocalBackupDesInfo.Create;

    // 本地备份 扫描线程
  MyLocalBackupHandler := TMyLocalBackupHandler.Create;

    // 自动 同步器
  MyLocalAutoSyncHandler := TMyLocalAutoSyncHandler.Create;
  
    // 状态显示线程
  MyLocalBackupStatusShow := TMyLocalBackupStatusShow.Create;
end;

procedure TBackupCowCreate.CreateNetwork;
begin
    // 本机的 Pc 信息
  PcInfo := TPcInfo.Create;
  Randomize;
  PcInfo.SetSortInfo( Now, Random( 1000000 ) );
  PcInfo.SetPcHardCode( MyMacAddress.getStr );

    // 网络模式
  NetworkModeInfo := TLanNetworkMode.Create;

    // Master 信息
  MasterInfo := TMasterInfo.Create;

    // 搜索网络 数据结构
  MyNetPcInfo := TMyNetPcInfo.Create;

      // C/S 网络
  MyServer := TMyServer.Create;
  MyClient := TMyClient.Create;

    // 搜索网络 命令控制器
  frmBroadcast := TfrmBroadcast.Create;
  MyMasterConn := TMyMasterConn.Create;
  MyMasterAccept := TMyMasterAccept.Create;

    // 监听网络
  MyListener := TMyListener.Create;

    // 搜索 Master
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
    // 搜索请求 信息
  MyFileSearchReq := TMyFileSearchReq.Create;

    // 搜索扫描 信息
  MyFileSearchScan := TMyFileSearchScan.Create;

    // 恢复请求 信息
  MyFileRestoreReq := TMyFileRestoreReq.Create;

    // 恢复扫描 信息
  MyFileRestoreScan := TMyFileRestoreScan.Create;

    // 搜索下载 信息
  MySearchDownInfo := TMySearchDownInfo.Create;

    // 恢复文件 信息
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
    // 界面 更新 总控制器
  MyFaceChange := TMyFaceChange.Create;

    // 主窗口 界面更新
  MyMainFormFace := TMyChildFaceChange.Create;

    // 备份信息
  MyBackupFileFace := TMyChildFaceChange.Create;
  BackupBoardInvisibleThread := TBackupBoardInvisibleThread.Create;
  BackupProgressHideThread := TBackupProgressHideThread.Create;

    // 传输/Job 信息
  MyJobFace := TMyJobFace.Create;

    // 初始化 传输 界面
  for i := 0 to Ary_TransferCount - 1 do
  begin
    RootID := Ary_TransferRoot[i][ Ary_RootID ];
    RootName := Ary_TransferRoot[i][ Ary_RootName ];
    RootName := frmMainForm.siLang_frmMainForm.GetText( RootID );
    VirTransferRootAddInfo := TVirTransferRootAddInfo.Create( RootID );
    VirTransferRootAddInfo.SetRootName( RootName );
    MyJobFace.AddChange( VirTransferRootAddInfo );
  end;

    // 搜索信息
  MySearchFileFace := TMyChildFaceChange.Create;

    // 网络信息
  Network_LocalPcID := MyComputerID.get;
  MyNetworkFace := TMyChildFaceChange.Create;
  NetworkLvItemHideThread := TNetworkLvItemHideThread.Create;
  MyCloudPcChartRefreshThread := TMyCloudPcChartRefreshThread.Create;

    // 恢复文件信息
  MyRestoreFileFace := TMyRestoreFileFace.Create;

    // 文件传输信息
  VstFileSendDesHideThread := TVstFileSendDesHideThread.Create;

    // 文件共享
  VstShareFilePcHideThread := TVstShareFilePcHideThread.Create;

    // 主窗口 传输速度
  TransferSpeedFaceThread := TTransferSpeedFaceThread.Create;
  TransferSpeedFaceThread.Resume;
end;

procedure TBackupCowCreate.CreateWriteManual;
begin
  MyManualChange := TMyChangeInfo.Create;
end;

procedure TBackupCowCreate.CreateWriteXml;
begin
    // Xml 根文档 初始化
  MyXmlDoc := frmMainForm.XmlDoc;
  MyXmlDoc.Active := True;
  if FileExists( MyXmlUtil.getXmlPath ) then
    MyXmlDoc.LoadFromFile( MyXmlUtil.getXmlPath );
  MyXmlUtil.IniXml;

    // Xml 初始化
  MyXmlChange := TMyXmlChange.Create;
  MyXmlSave := TMyXmlSave.Create;

    // 备份信息
  MyBackupXmlWrite := TMyChildXmlChange.Create;
  MyBackupFileRemoveWriteXml := TMyBackupFileRemoveWriteXml.Create;

    // 云信息
  MyCloudPathXmlWrite := TMyChildXmlChange.Create;

    // 网络 Pc 信息
  MyNetPcXmlWrite := TMyChildXmlChange.Create;

    // 批量注册 信息
  MyBatRegisteWriterXml := TMyBatRegisteWriterXml.Create;

    // 搜索下载文件 信息
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
  CreateSettingInfo;  // Setting 信息
  CreateWriteManual; // 写 人工 信息
  CreateWriteXml;  // 写 Xml 信息
  CreateWriteFace; // 写 程序界面

  CreateBackup; // 备份信息
  CreateLocalBackup;  // 本地备份信息
  CreateBackupNew;
  CreateCloudNew;
  CreateRestoreNew;
  CreateCloud;  // 云信息
  CreateJob;     // Job 信息
  CreateFileConfirm; // 文件确认
  CreateSearch; // 搜索信息
  CreateFileTransfer; // 文件发送信息
  CreateFileShare; // 文件共享信息
  CreateNetwork; // 网络信息

  LoadSetting;  // 加载 Setting 设置
  CreateControl;  // 用户控制器
  CreateReadXml;  // 读 Xml 信息
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

    // 停止 搜索 Mster 线程
  MasterThread.Free;

  DebugLog('6');

    // 关闭 监听端口
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
    // 保存 所有的 Xml 信息
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

    // 停止 接收广播
  frmBroadcast.OnRevMsgEvent := nil;

  MyFileUpload.CancelTransfer;  // 取消上传
  MyFileDownload.CancelTransfer; // 取消下载
  DebugLog('1');
  MyFileUpload.StopTransfer;   // 停止上传文件
  DebugLog('2');
  MyFileDownload.StopTransfer; // 停止下载文件
  DebugLog('3');

  MyListener.StopHandle; // 停止处理连接

  MyMasterConn.StopThread;  // 停止底层连接
  MyMasterAccept.StopThread; // 停止底层 Accept

  MyClient.StopThread;  // 停止客户端处理接收
  MyServer.StopThread;  // 停止服务器处理接收

  DebugLog('4');

  MyFaceChange.StopThread; // 停止界面更新
  MyManualChange.StopThread; // 停止人工添加处理

    // 停止扫描
  MyBackupHandler.StopScan;
  MyCloudBackupHandler.StopRun;

    // Network Backup
  MyBackupFileScanInfo.StopFileScan;  // 停止备份文件扫描
  MyBackupFileInfo.StopThread;  // 停止备份文件信息更新
  MyBackupRemoveNotifyInfo.StopThread; // 停止
  MyBackupFileLostConnInfo.StopLostConnScan; // 停止过期检测
  MyBackupBoardInfo.StopThread;
  MyBackupBoardInfo.StopBackupBoardShow;
  MyBackupAutoSyncInfo.StopSync;

  DebugLog('4.1');

    // Local Backup
  MyLocalAutoSyncHandler.StopThread;
  MyLocalBackupStatusShow.StopShow;
  MyLocalBackupHandler.StopScan;
  
  DebugLog('4.2.1');

  MyCloudFileScanner.StopScan; // 停止扫描
  MyCloudFileInfo.StopThread;  // 停止云文件信息更新

  DebugLog('4.2.2');

  MyFileConfirm.StopConfirm; // 停止文件确认

  DebugLog( '4.2.2.1' );

  MyFileAcceptConfirm.StopConfirm; // 停止文件确认

  DebugLog('4.2.3');

  MyBackupJobScanInfo.StopJobScan; // 停止 备份Job扫描
  MyJobInfo.StopThread;     // 停止 Job 信息更新

  DebugLog('4.3');

  MyTransferJobScanInfo.StopScan; // 停止文件发送扫描

  DebugLog('4.4');

  MyFileShareScanInfo.StopScan; // 停止文件共享扫描
  VstShareFilePcHideThread.Free;

  MyFileSearchReq.StopThread;  // 停止搜索请求
  MyFileSearchScan.IsRun := False;
  MyFileSearchScan.StopThread; // 停止搜索扫描

  MyFileRestoreReq.StopThread;  // 停止 恢复请求
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

    // 添加 默认的 本地 备份目标路径
  LocalBackupDesAddHandle := TLocalBackupDesAddHandle.Create( DesPath );
  LocalBackupDesAddHandle.Update;
  LocalBackupDesAddHandle.Free;

    // 禁止下一次添加
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

    // Xml 文件存在， 则读取 Xml 文件信息
  if FileExists( MyXmlUtil.getXmlPath ) then
    ReadXmlFileHandle
  else
    SetXmlDefaulHandle;  // 设置默认值

    // 加载文件完成
  LoadingCompleted;

    // 开始运行 Xml 定时保存
  MyXmlSave.StartThread;

    // 开始 定时检测 过期文件
  StartBackupFileLostConn;

    // 启动网络
  StartNetwork;

    // 在服务器记录
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
    // 本机信息
  HardCode := MyMacAddress.getStr;
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  NetworkMode := IniFile.ReadString( Ini_NetworkMode, Ini_SelectedMode, NetworkModeShow_LAN );
  IniFile.Free;
  LocalBackupItem := MyLocalBackupSourceInfo.LocalBackupSourceList.Count;
  NetworkBackupItem := MyBackupFileInfo.BackupPathList.Count;

    // 登录并获取在线 Pc 信息
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

    // 初始化 本地恢复信息
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
    // 读 网络Pc信息
  ReacNetPcXml;

    // 读 云信息
  ReadCloudXml;

    // 读 发送文件信息
  ReadFileSendXml;

    // 读 接收文件信息
  ReadFileReceiveXml;

    // 读 我的共享路径信息
  ReadSharePathXml;

    // 读 共享历史信息
  ReadShareHistoryXml;

    // 读 共享收藏夹信息
  ReadShareFavoriteXml;

    // 读取 下载共享路径信息
  ReadShareDownXml;

    // 读 本地备份 目标信息
  ReadLocalBackupDesXml;

    // 读 本机备份 源信息
  ReadLocalBackupSourceXml;

    // 读 批注册信息
  ReadBatRegisterXml;

    // 读 搜索下载信息
  ReadSearchDownXml;

    // 读 恢复文件信息
  ReadRestoreFileXml;

    // 读 备份文件删除信息
  ReadBackupNotifyXml;

    // 读 备份信息
  ReadBackupNewXml;

    // 读 云信息
  ReadCloudNewXml;

    // 读 备份信息
  ReadBackupXml;

    // 等待加载结束
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

    // 搜索 Master
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
    // 等待 Net Pc 加载
  while IsRun and not ReadBackupXml_IsCompleted do
    Sleep(100);
end;

end.
