unit UMyFileTransfer;

interface

uses UChangeInfo, Classes, SysUtils, Generics.Collections, Sockets, UMyJobInfo,
     UMyUtil, SyncObjs, Windows, uDebug, LbCipher,LbProc, Math, CnMD5;

type

{$Region ' 文件信息 请求 ' }

  TFileInfoMsg = class( TMsgBase )
  public
    iFileSize : Int64;
    iFileTime : TDateTime;
  published
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileTime : TDateTime Read iFileTime Write iFileTime;
  public
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;

{$EndRegion}

{$Region ' 传输文件 请求 ' }

    // 父类
  TTransferReqMsg = class( TMsgBase )
  public
    iPcID : string;
    iPosition, iFileSize : Int64;
    iFileTime : TDateTime;
  published
    property PcID : string Read iPcID Write iPcID;
    property Position : Int64 Read iPosition Write iPosition;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileTime : TDateTime Read iFileTime Write iFileTime;
  public
    procedure SetPcID( _PcID : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;

    // 上传
  TTransferUpReqMsg = class( TTransferReqMsg )
  public
    iUpFilePath : string;
  published
    property UpFilePath : string Read iUpFilePath Write iUpFilePath;
  public
    procedure SetUpFilePath( _UpFilePath : string );
  end;

    // 上传 备份
  TTransferBackupReqMsg = class( TTransferUpReqMsg )
  public
     function getMsgType : string;override;
  end;

    // 上传 发送文件
  TTransferFileSendReqMsg = class( TTransferUpReqMsg )
  public
     function getMsgType : string;override;
  end;

    // 下载
  TTransferDownReqMsg = class( TTransferReqMsg )
  public
    iFilePath : string;
    iDownFilePath : string;
  published
    property FilePath : string Read iFilePath Write iFilePath;
    property DownFilePath : string Read iDownFilePath Write iDownFilePath;
  public
    procedure SetDownInfo( _FilePath, _DownFilePath : string );
  end;

    // 下载 备份
  TTransferDownBackupReqMsg = class( TTransferDownReqMsg )
  public
    iBackupFilePcID : string;
  published
    property BackupFilePcID : string Read iBackupFilePcID Write iBackupFilePcID;
  public
    procedure SetBackupFilePcID( _BackupFilePcID : string );
  end;

    // 下载 搜索 源文件
  TTransferSourceSearchReqMsg = class( TTransferDownReqMsg )
  public
    function getMsgType : string;override;
  end;

    // 下载 搜索 备份文件
  TTransferBackupSearchReqMsg = class( TTransferDownBackupReqMsg )
  public
    function getMsgType : string;override;
  end;

    // 下载 恢复
  TTransferRestoreReqMsg = class( TTransferDownBackupReqMsg )
  public
    function getMsgType : string;override;
  end;

    // 下载 共享文件
  TTransferShareReqMsg = class( TTransferDownReqMsg )
  public
    function getMsgType : string;override;
  end;

    // 请求命令
  TFindReqMsg = class
  private
    JobInfo : TPendingJobInfo;
    ReqMsg : TTransferReqMsg;
  public
    constructor Create( _JobInfo : TPendingJobInfo );
    function get : TTransferReqMsg;
  private
    procedure SetBackupJob;
    procedure SetFileSendJob;
    procedure SetSourceSearchJob;
    procedure SetBackupSearchJob;
    procedure SetRestoreJob;
    procedure SetFileShareJob;
  private
    procedure SetUploadJob;
  private
    procedure SetDownJob;
    procedure SetDownBackupJob;
  end;

    // Job 信息
  TFindJobInfo = class
  private
    ReqMsg : TTransferReqMsg;
    JobInfo : TPendingJobInfo;
  public
    constructor Create( _ReqMsg : TTransferReqMsg );
    function get : TPendingJobInfo;
  private
    procedure SetBackupJob;
    procedure SetFileSendJob;
    procedure SetSourceSearchJob;
    procedure SetBackupSearchJob;
    procedure SetRestoreJob;
    procedure SetFileShareJob;
  private
    procedure SetUploadJob;
  private
    procedure SetDownJob;
    procedure SetDownBackupJob;
  end;

    // 转换工厂
  TransferJobMsgFactory = class
  public
    class function getReqMsg( Msg : string ): TTransferReqMsg;overload;
    class function getReqMsg( JobInfo : TPendingJobInfo ) : TTransferReqMsg;overload;
    class function getJobInfo( ReqMsg : TTransferReqMsg ): TPendingJobInfo;
  end;

{$EndRegion}

{$Region ' 传输文件 ' }

  {$Region ' 传输的文件信息 ' }

  TTransferFileInfo = class
  public
    PcID : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
    FileType : string;
  public
    PendPath : string;
    LoadPath : string;
  public
    procedure SetPcID( _PcID : string );
    procedure SetPosition( _Position : Int64 );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetFileType( _FileType : string );
    procedure SetPathInfo( _PendPath, _LoadPath : string );
  end;

  {$EndRegion}

  {$Region ' 获取 传输文件信息 ' }

  TFindTransferFileInfo = class
  protected
    PendingJobInfo : TPendingJobInfo;
    TransferFileInfo : TTransferFileInfo;
  public
    procedure SetPendingJobInfo( _PendingJobInfo : TPendingJobInfo );
    function get : TTransferFileInfo;
  protected
    procedure FindUp;virtual;
    procedure FindFileSend;virtual;
    procedure FindBackup;virtual;
  protected
    procedure FindDown; virtual;
    procedure FindSourceSearch;virtual;
    procedure FindBackupSearch;virtual;
    procedure FindRestore;virtual;
    procedure FindShare;virtual;
  end;

  TFindUpFileInfo = class( TFindTransferFileInfo )
  protected
    procedure FindUp;override;
  protected
    procedure FindSourceSearch;override;
    procedure FindBackupSearch;override;
    procedure FindRestore;override;
    procedure FindShare;override;
  end;

  TFindDownFileInfo = class( TFindTransferFileInfo )
  protected
    procedure FindBackup;override;
    procedure FindFileSend;override;
  protected
    procedure FindDown;override;
  end;

  {$EndRegion}

  {$Region ' 传输文件 处理 ' }

    // 传输
  TTransferFile = class
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );virtual;abstract;
    procedure SetTransferFileInfo( TransferFileInfo : TTransferFileInfo );virtual;abstract;
    procedure SetPendingJobInfo( _PendingJobInfo : TPendingJobInfo );virtual;abstract;
    procedure Update;virtual;abstract;
  end;

  TTransferFileHandle = class
  protected
    PendingJobInfo : TPendingJobInfo;
    TcpSocket : TCustomIpClient;
    TransferFileInfo : TTransferFileInfo;
  public
    procedure Update;virtual;abstract;
  protected      // 删 Pending
    procedure DeletePendFace;
    procedure CreateTransferFileInfo;
  protected
    procedure TransferFile;
    function getTransferType : string;virtual;abstract;
  end;

    // 主动 传输文件
  TTransferFileConnHandle = class( TTransferFileHandle )
  public
    procedure SetJobInfo( _PendJobInfo : TPendingJobInfo );
    procedure Update;override;
  private       // 连接
    procedure ConnAndSendFile;
    function ConnPc : Boolean;
    function getIsPcBusy : Boolean;
    procedure SendTransferReqMsg;
    function RevAcceptContinues : Boolean;
  private       // 繁忙处理
    procedure AddBusyJobInfo;
    procedure AddBusyPendFace;
  private       // Job 重定向
    procedure AddPendingFace;
    function SendRemoteJobInfo: Boolean;
  protected
    function getJobIsContinues : Boolean;virtual; // Job是否取消
    procedure ConnErrorHandle;virtual;
    procedure AcceptCancelHandle;virtual;
  end;

    // 被动传输文件
  TTransferFileAcceptHandle = class( TTransferFileHandle )
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;override;
  protected
    function CheckBusy : Boolean;
    function RevTransferReqMsg: Boolean;
    function SendAcceptContinues: Boolean;
  protected
    function getAcceptIsContinues : Boolean; virtual; // 是否继续传输
  private
    procedure RemoveRedirectJob;
  end;

  {$EndRegion}

  {$Region ' 连接 处理 ' }

    // 主动 和 被动 Job 处理
  TTransferJobHandle = class
  protected
    JobInfo : TJobInfo;
    TransferFileHandle : TTransferFileHandle;
  public
    procedure SetJobInfo( _JobInfo : TJobInfo );
    procedure Update;
  protected
    procedure CreateConnJob;virtual;abstract;
    procedure CreateAcceptJob;virtual;abstract;
  private
    procedure ConnJob;
    procedure AcceptJob;
  end;

  TDownloadJobHandle = class( TTransferJobHandle )
  protected
    procedure CreateConnJob;override;
    procedure CreateAcceptJob;override;
  end;

  TUploadJobHandle = class( TTransferJobHandle )
  protected
    procedure CreateConnJob;override;
    procedure CreateAcceptJob;override;
  end;

  {$EndRegion}

  {$Region ' 线程 ' }

    // 做 Job 线程
  TTransferHandleThread = class( TThread )
  public
    ThreadStatus : string;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  protected
    function getJobInfo : TJobInfo;virtual;abstract;
    function getJobHandle : TTransferJobHandle;virtual;abstract;
  private
    procedure HandleJobInfo( JobInfo : TJobInfo );
  end;

    // 下载
  TDownloadHandleThread = class( TTransferHandleThread )
  protected
    function getJobInfo : TJobInfo;override;
    function getJobHandle : TTransferJobHandle;override;
  end;

    // 上传
  TUploadHandleThread = class( TTransferHandleThread )
  protected
    function getJobInfo : TJobInfo;override;
    function getJobHandle : TTransferJobHandle;override;
  end;

    // 线程集合
  TTransferFileThreadList = class( TObjectList<TTransferHandleThread> )
  end;

  {$EndRegion}

  TMyFileTransfer = class
  public
    IsRun : Boolean;
    RunThreadCount : Integer;
    TransferFileThreadList : TTransferFileThreadList;
  public
    constructor Create;
    procedure CancelTransfer;
    procedure StopTransfer;
    destructor Destroy; override;
  public
    procedure ResetRunThreadCount( NewRunCount : Integer );
    procedure RunAllThread;
    function getThreadStatus : string;
  protected
    function CreateThread : TTransferHandleThread;virtual;abstract;
  end;

{$EndRegion}

{$Region ' 数据缓冲 ' }

  TTransferBuf = array[0..1023] of Byte; // 1K, 传输缓冲区
  THardBuf = array[0..524287] of Byte;  // 512 K, 读写缓冲区

    // 发送数据 缓冲区
  TSendDataBuf = class
  public
    HardBuf : THardBuf;
    SendPosition, BufSize : Integer;
  public
    procedure SetBufInfo( _BufSize : Integer );
  public
    function getSendBuf( var SendBuf : TTransferBuf ) : Integer;
  end;

    // 接收数据 缓冲区
  TRevDataBuf = class
  public
    HardBuf : THardBuf;
    BufSize : Integer;
  public
    procedure ClearWriteData;
  public
    function AddRevBuf( RevBuf : TTransferBuf; RevSize : Integer ): Boolean;
  end;

  TDesHardBufHandle = class
  public
    HardBuf : THardBuf;
    BufSize : Integer;
  public
    IsEncrypt : Boolean;
    Key : string;
  public
    constructor Create( _HardBuf : THardBuf; _BufSize : Integer );
    procedure SetEncrypt( _IsEncrypt : Boolean; _Key : string );
    function get : THardBuf;
  end;

  DataBufUtil = class
  public
    class procedure EncryptSendBuf( SendBuf : TSendDataBuf; Key : string ); // Buf 加密
    class procedure DecryptRevBuf( RevBuf : TRevDataBuf; Key : string ); // Buf 解密
  end;

{$EndRegion}

{$Region ' 辅助类 ' }

  TransferUtil = class
  public
    class function getIsSendMD5Activate( FileType : string ): Boolean;
    class function getMD5Buffer( var Buf : THardBuf; BufSize : Int64 ): string;
  end;

{$EndRegion}

const
  Size_TransferBuf = 1024;
  Size_DataBuf = 524288;
  Count_MaxThread = 20;

const
  ReadFile_OK : string = 'OK';
  ReadFile_FileNotExist : string = 'Upload file dose not exist';
  ReadFile_FileChange : string = 'Upload file has changed';
  ReadFile_ReadError : string = 'Upload file read error';
  ReadFile_UploadCancel : string = 'Upload Cancel';

  WriteFile_OK : string = 'OK';
  WriteFile_Exist : string = 'Download file exists';
  WriteFile_FileNotExit : string = 'Download file dose not exist';
  WriteFile_FileChange : string = 'Download file has changed';
  WriteFile_WriteError : string = 'Download file write error';
  WriteFile_CreateFolderError : string = 'Download file create folder error';
  WriteFile_SpaceLack : string = 'Download file space insufficient';
  WriteFile_DownloadCancel : string = 'Download Cancel';

  TransFile_OK : string = 'OK';
  TransFile_LostCon : string = 'Lost Connection';

    // Upload Backup File
  TransFile_RemoteForbid : string = 'Remote backup forbidden';
  TransFile_BackupItemNotExist : string = 'Backup Item Not Exist';
  TransFile_TransferCancel : string = 'Cancel';

    // Download Search/Restore File
  TransFile_DownloadItemNotExist : string = 'Download Item not Exist';

  TransferReqMsg_Backup = 'Backup';
  TransferReqMsg_FileSend = 'FileSend';
  TransferReqMsg_Search = 'Search';
  TransferReqMsg_SourceSearch = 'SourceSearch';
  TransferReqMsg_BackupSearch = 'BackupSearch';
  TransferReqMsg_Restore = 'Restore';
  TransferReqMsg_FileShare = 'FileShare';

  TransferType_Upload = 'Upload';
  TransferType_Download = 'Download';

  DownloadReqMsg_Backup = 'Backup';
  DownloadReqMsg_Search = 'Search';
  DownloadReqMsg_Restore = 'Restore';

  UploadReqMsg_Backup = 'Backup';
  UploadReqMsg_Search = 'Search';
  UploadReqMsg_Restore = 'Restore';

  Count_DataBuf : Integer = 512; // 1024 * 512 = 512 KB 缓冲区 ( 一个扇区 )
  Count_HandleSleep : Integer = 128;

  ThreadStatus_Run = 'Run';
  ThreadStatus_Pause = 'Pause';
  ThreadStatus_Stop = 'Stop';
//  ThreadStatus_Exit = 'Exit';
//  ThreadStatus_Delete = 'Delete';

implementation

uses UMyTcp, UMyNetPcInfo, UMyCloudPathInfo, UJobFace, UMyFileUpload, UMyFileDownload, USettingInfo,
     UMyFileTransferInfo, UMyClient;

{ TTransferReqMsg }

procedure TTransferReqMsg.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TTransferReqMsg.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TTransferReqMsg.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

{ TFileInfoReqMsg }

procedure TFileInfoMsg.SetFileInfo(_FileSize : Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TTransferFileHandle }

procedure TTransferFileConnHandle.AcceptCancelHandle;
begin

end;

procedure TTransferFileConnHandle.AddBusyJobInfo;
var
  TransferType : string;
  ClonePendJobInfo : TPendingJobInfo;
  JobAddInfo : TJobAddInfo;
  TransferJobChangeInfo : TTransferJobChangeInfo;
begin
    // 复制 Job 信息
  ClonePendJobInfo := JobInfoUtil.getCloneJob( PendingJobInfo );

  JobAddInfo := TJobAddInfo.Create;
  JobAddInfo.SetJobInfo( ClonePendJobInfo );

    // 添加到传输队列
  TransferType := getTransferType;
  if TransferType = TransferType_Upload then
    TransferJobChangeInfo := TUploadJobChangeInfo.Create
  else
  if TransferType = TransferType_Download then
    TransferJobChangeInfo := TDownloadJobChangeInfo.Create;
  TransferJobChangeInfo.SetJobWriteInfo( JobAddInfo );

  MyJobInfo.AddChange( TransferJobChangeInfo );
end;


procedure TTransferFileConnHandle.AddBusyPendFace;
var
  PcID, PcName, RootID, TransferType : string;
  FileSize : Int64;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  TransferType := getTransferType;
  if TransferType = TransferType_Upload then
    RootID := RootID_UpPend
  else
  if TransferType = TransferType_Download then
    RootID := RootID_DownPend;

  PcID := PendingJobInfo.PcID;
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  FileSize := MyFileInfo.getFileSize( TransferFileInfo.LoadPath );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, TransferFileInfo.PendPath );
  VirTransferChildAddInfo.SetFileBase( TransferFileInfo.LoadPath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( PendingJobInfo.Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( TransferFileInfo.FileType, FileStatus_Busy );

  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

procedure TTransferFileConnHandle.AddPendingFace;
var
  PcID, PcName, RootID, TransferType : string;
  FileSize : Int64;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  TransferType := getTransferType;
  if TransferType = TransferType_Upload then
    RootID := RootID_UpPend
  else
  if TransferType = TransferType_Download then
    RootID := RootID_DownPend;

  PcID := PendingJobInfo.PcID;
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  FileSize := MyFileInfo.getFileSize( TransferFileInfo.LoadPath );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, TransferFileInfo.PendPath );
  VirTransferChildAddInfo.SetFileBase( TransferFileInfo.LoadPath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( PendingJobInfo.Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( TransferFileInfo.FileType, FileStatus_Waiting );

  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

function TTransferFileConnHandle.getIsPcBusy: Boolean;
begin
    // 超时没有相应，对方 繁忙
  if MySocketUtil.RevBusyData( TcpSocket ) <> '' then
    Result := False
  else
  begin
    TcpSocket.Disconnect;
    Result := True;
  end;
end;

procedure TTransferFileConnHandle.ConnAndSendFile;
begin
    // 连接目标
  if not ConnPc then
  begin
      // 通知对方连接本机
    if not SendRemoteJobInfo then
      ConnErrorHandle; // 连接失败处理
    Exit;
  end;

    // 检测 对方是否繁忙
  if getIsPcBusy then
  begin
    AddBusyPendFace; // 添加 繁忙 Pend 界面
    AddBusyJobInfo;  // 添加 Busy Job
    Exit;
  end;

  SendTransferReqMsg;  // 发送 传输请求

    // 接收方检测 Job 有效性
  if not RevAcceptContinues then
  begin
    AcceptCancelHandle; // 接收方取消发送
    Exit;
  end;

  TransferFile;    // 传输文件
end;

procedure TTransferFileConnHandle.ConnErrorHandle;
begin

end;

function TTransferFileConnHandle.ConnPc: Boolean;
var
  PcID, Ip, Port : string;
  MyTcpConn : TMyTcpConn;
  TransferType, ConnType : string;
begin
  Result := False;
  PcID := PendingJobInfo.PcID;
  if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) or
     not MyNetPcInfoReadUtil.ReadIsReach( PcID )
  then
    Exit;

    // 读取 网络位置信息
  Ip := MyNetPcInfoReadUtil.ReadIp( PcID );
  Port := MyNetPcInfoReadUtil.ReadPort( PcID );
  if ( Ip = '' ) or ( Port = '' ) then
    Exit;

  TransferType := getTransferType;
  if TransferType = TransferType_Download then
    ConnType := ConnType_DownloadFile
  else
  if TransferType = TransferType_Upload then
    ConnType := ConnType_UploadFile;

    // 尝试连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( Ip, Port );
  MyTcpConn.SetConnType( ConnType );
  if MyTcpConn.Conn then
    Result := True;
  MyTcpConn.Free;
end;

function TTransferFileConnHandle.getJobIsContinues: Boolean;
begin
  Result := True;
end;

function TTransferFileConnHandle.RevAcceptContinues: Boolean;
begin
  Result := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), False );
end;

function TTransferFileConnHandle.SendRemoteJobInfo: Boolean;
var
  CloneJobInfo : TPendingJobInfo;
  RedirectJobAddInfo : TRedirectJobAddInfo;
  DesPcID : string;
  ReqMsg : TTransferReqMsg;
  PcRedirectJobAddMsg : TPcRedirectJobAddMsg;
  JobMsgStr : string;
begin
  Result := False;
  if not MyNetPcInfoReadUtil.ReadIsOnline( PendingJobInfo.PcID ) then
    Exit;

    // 重新 Pending
  AddPendingFace;

    // 记录 克隆 Job
  CloneJobInfo := JobInfoUtil.getCloneJob( PendingJobInfo );
  RedirectJobAddInfo := TRedirectJobAddInfo.Create( CloneJobInfo );
  MyJobInfo.AddChange( RedirectJobAddInfo );

  DesPcID := PendingJobInfo.PcID;
  PendingJobInfo.SetPcID( PcInfo.PcID );

    // 把 Job 转换为 MsgStr
  ReqMsg := TransferJobMsgFactory.getReqMsg( PendingJobInfo );
  JobMsgStr := ReqMsg.getMsg;
  ReqMsg.Free;

  PendingJobInfo.SetPcID( DesPcID );

    // 发给对方
  PcRedirectJobAddMsg := TPcRedirectJobAddMsg.Create;
  PcRedirectJobAddMsg.SetPcID( PcInfo.PcID );
  PcRedirectJobAddMsg.SetJobMsg( JobMsgStr );
  MyClient.SendMsgToPc( DesPcID, PcRedirectJobAddMsg );

  Result := True;
end;

procedure TTransferFileConnHandle.SendTransferReqMsg;
var
  ReqMsg : TTransferReqMsg;
  Msg : string;
begin
  ReqMsg := TransferJobMsgFactory.getReqMsg( PendingJobInfo );
  Msg := ReqMsg.getMsg;
  ReqMsg.Free;

  MySocketUtil.SendString( TcpSocket, Msg );
end;

procedure TTransferFileConnHandle.SetJobInfo(_PendJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendJobInfo;
end;

procedure TTransferFileConnHandle.Update;
begin
  TcpSocket := TCustomIpClient.Create(nil);

    // 初始化 传输信息
  CreateTransferFileInfo;

    // 删除 Pend 界面
  DeletePendFace;

    // Job 是否已经取消
  if getJobIsContinues then
    ConnAndSendFile;  // 连接 和 发送文件

  TransferFileInfo.Free;

  TcpSocket.Free;

  PendingJobInfo.Free;
end;

{ TTransferFileHandle }

procedure TTransferFileHandle.DeletePendFace;
var
  PcID, TransferType, RootID : string;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
  PcID := PendingJobInfo.PcID;
  TransferType := getTransferType;
  if TransferType = TransferType_Upload then
    RootID := RootID_UpPend
  else
  if TransferType = TransferType_Download then
    RootID := RootID_DownPend;

    // 删除 UpPend 界面
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID );
  VirTransferChildRemoveInfo.SetChildID( PcID, TransferFileInfo.PendPath );

  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TTransferFileHandle.CreateTransferFileInfo;
var
  TransferType : string;
  FindTransferFile : TFindTransferFileInfo;
begin
  TransferType := getTransferType;

  if TransferType = TransferType_Upload then
    FindTransferFile := TFindUpFileInfo.Create
  else
  if TransferType = TransferType_Download then
    FindTransferFile := TFindDownFileInfo.Create;

  FindTransferFile.SetPendingJobInfo( PendingJobInfo );
  TransferFileInfo := FindTransferFile.get;
  FindTransferFile.Free;
end;

procedure TTransferFileHandle.TransferFile;
var
  TransferType, FileType : string;
  TransferFileHandler : TTransferFile;
begin
  TransferType := getTransferType;
  FileType := TransferFileInfo.FileType;
  if TransferType = TransferType_Upload then
  begin
    if FileType = FileType_Backup then
      TransferFileHandler := TSendBackupFileHandle.Create
    else
    if FileType = FileType_Transfer then
      TransferFileHandler := TSendTransferFileHandle.Create
    else
    if FileType = FileType_Share then
      TransferFileHandler := TSendShareFileHandle.Create
    else
      TransferFileHandler := TSendFileHandle.Create
  end
  else
  if TransferType = TransferType_Download then
  begin
    if FileType = FileType_Backup then
      TransferFileHandler := TRevBackupFileHandle.Create
    else
    if FileType = FileType_Search then
    begin
      if PendingJobInfo is TSourceSearchJobInfo then
        TransferFileHandler := TRevSearchDownSourceFileHandle.Create
      else
        TransferFileHandler := TRevSearchDownBackupFileHandle.Create;
    end
    else
    if FileType = FileType_Restore then
      TransferFileHandler := TRevRestoreFileHandle.Create
    else
    if FileType = FileType_Transfer then
      TransferFileHandler := TRevTransferFileHandle.Create
    else
    if FileType = FileType_Share then
      TransferFileHandler := TRevShareFileHandle.Create
    else
      TransferFileHandler := TRevFileHandle.Create;
  end;

  TransferFileHandler.SetTcpSocket( TcpSocket );
  TransferFileHandler.SetTransferFileInfo( TransferFileInfo );
  TransferFileHandler.SetPendingJobInfo( PendingJobInfo );
  TransferFileHandler.Update;
  TransferFileHandler.Free;
end;

{ TTransferBackupReqMsg }

function TTransferBackupReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_Backup;
end;

{ TTransferDownReqMsg }

procedure TTransferDownReqMsg.SetDownInfo(_FilePath, _DownFilePath: string);
begin
  FilePath := _FilePath;
  DownFilePath := _DownFilePath;
end;

{ TransferJobMsgFactory }

class function TransferJobMsgFactory.getJobInfo(
  ReqMsg: TTransferReqMsg): TPendingJobInfo;
var
  FindJobInfo : TFindJobInfo;
begin
  FindJobInfo := TFindJobInfo.Create( ReqMsg );
  Result := FindJobInfo.get;
  FindJobInfo.Free;
end;

class function TransferJobMsgFactory.getReqMsg(
  JobInfo: TPendingJobInfo): TTransferReqMsg;
var
  FindReqMsg : TFindReqMsg;
begin
  FindReqMsg := TFindReqMsg.Create( JobInfo );
  Result := FindReqMsg.get;
  FindReqMsg.Free;
end;

class function TransferJobMsgFactory.getReqMsg(Msg: string): TTransferReqMsg;
var
  MsgType, MsgStr : string;
  MsgInfo : TMsgInfo;
  ReqMsg : TTransferReqMsg;
begin
    // 解释 请求命令
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( Msg );
  MsgType := MsgInfo.MsgType;
  MsgStr := MsgInfo.MsgStr;
  MsgInfo.Free;

    // 多态
  if MsgType = TransferReqMsg_Backup then
    Result := TTransferBackupReqMsg.Create
  else
  if MsgType = TransferReqMsg_SourceSearch then
    Result := TTransferSourceSearchReqMsg.Create
  else
  if MsgType = TransferReqMsg_BackupSearch then
    Result := TTransferBackupSearchReqMsg.Create
  else
  if MsgType = TransferReqMsg_Restore then
    Result := TTransferRestoreReqMsg.Create
  else
  if MsgType = TransferReqMsg_FileSend then
    Result := TTransferFileSendReqMsg.Create
  else
  if MsgType = TransferReqMsg_FileShare then
    Result := TTransferShareReqMsg.Create;

  Result.SetMsgStr( MsgStr );
end;

{ TFindReqMsg }

constructor TFindReqMsg.Create(_JobInfo: TPendingJobInfo);
begin
  JobInfo := _JobInfo;
end;

function TFindReqMsg.get: TTransferReqMsg;
begin
  if JobInfo is TUpJobInfo then
  begin
    if JobInfo is TBackupJobInfo then
      SetBackupJob
    else
    if JobInfo is TFileSendJobInfo then
      SetFileSendJob;
    SetUploadJob;
  end
  else
  if JobInfo is TDownJobInfo then
  begin
    if JobInfo is TSourceSearchJobInfo then
      SetSourceSearchJob
    else
    if JobInfo is TShareJobInfo then
      SetFileShareJob
    else
    if JobInfo is TDownBackupJobInfo then
    begin
      if JobInfo is TBackupSearchJobInfo then
        SetBackupSearchJob
      else
      if JobInfo is TRestoreJobInfo then
        SetRestoreJob;
      SetDownBackupJob;
    end;
    SetDownJob;
  end;

  ReqMsg.SetPcID( PcInfo.PcID );
  ReqMsg.SetPosition( JobInfo.Position );
  ReqMsg.SetFileInfo( JobInfo.FileSize, JobInfo.FileTime );

  Result := ReqMsg;
end;

procedure TFindReqMsg.SetBackupJob;
begin
  ReqMsg := TTransferBackupReqMsg.Create;
end;

procedure TFindReqMsg.SetBackupSearchJob;
begin
  ReqMsg := TTransferBackupSearchReqMsg.Create;
end;

procedure TFindReqMsg.SetDownBackupJob;
var
  DownBackupJobInfo : TDownBackupJobInfo;
  DownBackupReqMsg : TTransferDownBackupReqMsg;
begin
  DownBackupJobInfo := JobInfo as TDownBackupJobInfo;
  DownBackupReqMsg := ReqMsg as TTransferDownBackupReqMsg;

  DownBackupReqMsg.SetBackupFilePcID( DownBackupJobInfo.BackupFilePcID );
end;

procedure TFindReqMsg.SetDownJob;
var
  DownJobInfo : TDownJobInfo;
  DownReqMsg : TTransferDownReqMsg;
begin
  DownJobInfo := JobInfo as TDownJobInfo;
  DownReqMsg := ReqMsg as TTransferDownReqMsg;

  DownReqMsg.SetDownInfo( DownJobInfo.FilePath, DownJobInfo.DownloadPath );
end;

procedure TFindReqMsg.SetFileSendJob;
begin
  ReqMsg := TTransferFileSendReqMsg.Create;
end;

procedure TFindReqMsg.SetFileShareJob;
begin
  ReqMsg := TTransferShareReqMsg.Create;
end;

procedure TFindReqMsg.SetRestoreJob;
begin
  ReqMsg := TTransferRestoreReqMsg.Create;
end;

procedure TFindReqMsg.SetSourceSearchJob;
begin
  ReqMsg := TTransferSourceSearchReqMsg.Create;
end;

procedure TFindReqMsg.SetUploadJob;
var
  UpJobInfo : TUpJobInfo;
  TransferUpReqMsg : TTransferUpReqMsg;
begin
  UpJobInfo := JobInfo as TUpJobInfo;
  TransferUpReqMsg := ReqMsg as TTransferUpReqMsg;

  TransferUpReqMsg.SetUpFilePath( UpJobInfo.UploadPath );
end;

{ TFindJobInfo }

constructor TFindJobInfo.Create(_ReqMsg: TTransferReqMsg);
begin
  ReqMsg := _ReqMsg;
end;

function TFindJobInfo.get: TPendingJobInfo;
begin
  if ReqMsg is TTransferUpReqMsg then
  begin
    if ReqMsg is TTransferBackupReqMsg then
      SetBackupJob
    else
    if ReqMsg is TTransferFileSendReqMsg then
      SetFileSendJob;
    SetUploadJob;
  end
  else
  if ReqMsg is TTransferDownReqMsg then
  begin
    if ReqMsg is TTransferSourceSearchReqMsg then
      SetSourceSearchJob
    else
    if ReqMsg is TTransferShareReqMsg then
      SetFileShareJob
    else
    if ReqMsg is TTransferDownBackupReqMsg then
    begin
      if ReqMsg is TTransferBackupSearchReqMsg then
        SetBackupSearchJob
      else
      if ReqMsg is TTransferRestoreReqMsg then
        SetRestoreJob;
      SetDownBackupJob;
    end;
    SetDownJob;
  end;

  JobInfo.SetPcID( ReqMsg.PcID );
  JobInfo.SetPosition( ReqMsg.Position );
  JobInfo.SetFileInfo( ReqMsg.FileSize, ReqMsg.FileTime );

  Result := JobInfo;
end;

procedure TFindJobInfo.SetBackupJob;
begin
  JobInfo := TBackupJobInfo.Create;
end;

procedure TFindJobInfo.SetBackupSearchJob;
begin
  JobInfo := TBackupSearchJobInfo.Create;
end;

procedure TFindJobInfo.SetDownBackupJob;
var
  DownBackupJobInfo : TDownBackupJobInfo;
  DownBackupReqMsg : TTransferDownBackupReqMsg;
begin
  DownBackupReqMsg := ReqMsg as TTransferDownBackupReqMsg;
  DownBackupJobInfo := JobInfo as TDownBackupJobInfo;

  DownBackupJobInfo.SetBackupFileInfo( DownBackupReqMsg.BackupFilePcID );
end;

procedure TFindJobInfo.SetDownJob;
var
  DownJobInfo : TDownJobInfo;
  DownReqMsg : TTransferDownReqMsg;
begin
  DownReqMsg := ReqMsg as TTransferDownReqMsg;
  DownJobInfo := JobInfo as TDownJobInfo;

  DownJobInfo.SetDownInfo( DownReqMsg.FilePath, DownReqMsg.DownFilePath );
end;

procedure TFindJobInfo.SetFileSendJob;
begin
  JobInfo := TFileSendJobInfo.Create;
end;

procedure TFindJobInfo.SetRestoreJob;
begin
  JobInfo := TRestoreJobInfo.Create
end;

procedure TFindJobInfo.SetFileShareJob;
begin
  JobInfo := TShareJobInfo.Create;
end;

procedure TFindJobInfo.SetSourceSearchJob;
begin
  JobInfo := TSourceSearchJobInfo.Create;
end;

procedure TFindJobInfo.SetUploadJob;
var
  UpJobInfo : TUpJobInfo;
  TransferUpReqMsg : TTransferUpReqMsg;
begin
  UpJobInfo := JobInfo as TUpJobInfo;
  TransferUpReqMsg := ReqMsg as TTransferUpReqMsg;

  UpJobInfo.SetUploadPath( TransferUpReqMsg.UpFilePath );
end;

{ TTransferFileAcceptHandle }

function TTransferFileAcceptHandle.CheckBusy: Boolean;
begin
  if TcpSocket.Connected then
  begin
    MySocketUtil.SendString( TcpSocket, ConnResult_OK );
    Result := True;
  end
  else
    Result := False;  // Busy and lost conn
end;

function TTransferFileAcceptHandle.getAcceptIsContinues: Boolean;
begin
  Result := True;
end;

procedure TTransferFileAcceptHandle.RemoveRedirectJob;
var
  RedirectJobRemoveInfo : TRedirectJobRemoveInfo;
begin
  RedirectJobRemoveInfo := TRedirectJobRemoveInfo.Create( PendingJobInfo.PcID );
  RedirectJobRemoveInfo.SetJobInfo( PendingJobInfo.getJobType, PendingJobInfo.getLoadPath );
  MyJobInfo.AddChange( RedirectJobRemoveInfo );
end;

function TTransferFileAcceptHandle.RevTransferReqMsg: Boolean;
var
  Msg, MsgType, MsgStr : string;
  MsgInfo : TMsgInfo;
  ReqMsg : TTransferReqMsg;
begin
  Result := False;

    // 接收 请求命令
  Msg := MySocketUtil.RevData( TcpSocket );
  if Msg = '' then
    Exit;

  ReqMsg := TransferJobMsgFactory.getReqMsg( Msg );
  PendingJobInfo := TransferJobMsgFactory.getJobInfo( ReqMsg );
  ReqMsg.Free;

  Result := True;
end;

function TTransferFileAcceptHandle.SendAcceptContinues: Boolean;
begin
  Result := getAcceptIsContinues;
  MySocketUtil.SendString( TcpSocket, BoolToStr( Result ) );
end;

procedure TTransferFileAcceptHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TTransferFileAcceptHandle.Update;
begin
  if CheckBusy and RevTransferReqMsg then
  begin
    RemoveRedirectJob;
    CreateTransferFileInfo;
    DeletePendFace;
    if SendAcceptContinues then // 判断 接收 Job 是否过期
      TransferFile;
    TransferFileInfo.Free;
    PendingJobInfo.Free;
  end;
end;

{ TTransferRestoreReqMsg }

function TTransferRestoreReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_Restore;
end;

{ TransferFileInfo }

procedure TTransferFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TTransferFileInfo.SetFileType(_FileType: string);
begin
  FileType := _FileType;
end;

procedure TTransferFileInfo.SetPathInfo(_PendPath, _LoadPath: string);
begin
  PendPath := _PendPath;
  LoadPath := _LoadPath;
end;

procedure TTransferFileInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TTransferFileInfo.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

{ TFindTransferFileInfo }


procedure TFindTransferFileInfo.FindBackup;
begin
  TransferFileInfo.SetFileType( FileType_Backup );
end;

procedure TFindTransferFileInfo.FindBackupSearch;
begin
  TransferFileInfo.SetFileType( FileType_Search );
end;

procedure TFindTransferFileInfo.FindDown;
begin

end;

procedure TFindTransferFileInfo.FindFileSend;
begin
  TransferFileInfo.SetFileType( FileType_Transfer );
end;

procedure TFindTransferFileInfo.FindRestore;
begin
  TransferFileInfo.SetFileType( FileType_Restore );
end;

procedure TFindTransferFileInfo.FindShare;
begin
  TransferFileInfo.SetFileType( FileType_Share );
end;

procedure TFindTransferFileInfo.FindSourceSearch;
begin
  TransferFileInfo.SetFileType( FileType_Search );
end;

procedure TFindTransferFileInfo.FindUp;
begin

end;

function TFindTransferFileInfo.get: TTransferFileInfo;
begin
  TransferFileInfo := TTransferFileInfo.Create;

  if PendingJobInfo is TUpJobInfo then
  begin
    FindUp;
    if PendingJobInfo is TBackupJobInfo then
      FindBackup
    else
    if PendingJobInfo is TFileSendJobInfo then
      FindFileSend;
  end
  else
  if PendingJobInfo is TDownJobInfo then
  begin
    FindDown;
    if PendingJobInfo is TSourceSearchJobInfo then
      FindSourceSearch
    else
    if PendingJobInfo is TBackupSearchJobInfo then
      FindBackupSearch
    else
    if PendingJobInfo is TRestoreJobInfo then
      FindRestore
    else
    if PendingJobInfo is TShareJobInfo then
      FindShare;
  end;

  TransferFileInfo.SetPcID( PendingJobInfo.PcID );
  TransferFileInfo.SetPosition( PendingJobInfo.Position );
  TransferFileInfo.SetFileInfo( PendingJobInfo.FileSize, PendingJobInfo.FileTime );

  Result := TransferFileInfo;
end;

procedure TFindTransferFileInfo.SetPendingJobInfo(
  _PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

{ TFindUpFileInfo }

procedure TFindUpFileInfo.FindBackupSearch;
var
  BackupSearchJobInfo : TBackupSearchJobInfo;
  UpPendPath, UploadPath : string;
  CloudPath, FilePath : string;
begin
  inherited;

  BackupSearchJobInfo := PendingJobInfo as TBackupSearchJobInfo;
  FilePath := BackupSearchJobInfo.FilePath;
  UpPendPath := FilePath;

  FilePath := MyFilePath.getDownloadPath( FilePath );
  CloudPath := MyCloudFileInfo.ReadBackupCloudPath;
  UploadPath := MyFilePath.getPath( CloudPath ) + BackupSearchJobInfo.BackupFilePcID;
  UploadPath := MyFilePath.getPath( UploadPath ) + FilePath;

  TransferFileInfo.SetPathInfo( UpPendPath, UploadPath );
end;

procedure TFindUpFileInfo.FindRestore;
var
  RestoreJobInfo : TRestoreJobInfo;
  UpPendPath, UploadPath : string;
  CloudPath, FilePath : string;
begin
  inherited;

  RestoreJobInfo := PendingJobInfo as TRestoreJobInfo;
  FilePath := RestoreJobInfo.FilePath;
  UpPendPath := FilePath;

  FilePath := MyFilePath.getDownloadPath( FilePath );
  CloudPath := MyCloudFileInfo.ReadBackupCloudPath;
  UploadPath := MyFilePath.getPath( CloudPath ) + RestoreJobInfo.BackupFilePcID;
  UploadPath := MyFilePath.getPath( UploadPath ) + FilePath;

  TransferFileInfo.SetPathInfo( UpPendPath, UploadPath );
end;

procedure TFindUpFileInfo.FindShare;
var
  ShareJobInfo : TShareJobInfo;
  FilePath, UpPendPath, UploadPath : string;
begin
  inherited;

  ShareJobInfo := PendingJobInfo as TShareJobInfo;
  FilePath := ShareJobInfo.FilePath;
  UpPendPath := FilePath;
  UploadPath := FilePath;

  TransferFileInfo.SetPathInfo( UpPendPath, UploadPath );
end;

procedure TFindUpFileInfo.FindSourceSearch;
var
  SourceSearchJobInfo : TSourceSearchJobInfo;
  FilePath, UpPendPath, UploadPath : string;
begin
  inherited;

  SourceSearchJobInfo := PendingJobInfo as TSourceSearchJobInfo;
  FilePath := SourceSearchJobInfo.FilePath;
  UpPendPath := FilePath;
  UploadPath := FilePath;

  TransferFileInfo.SetPathInfo( UpPendPath, UploadPath );
end;


procedure TFindUpFileInfo.FindUp;
var
  UpJobInfo : TUpJobInfo;
  UploadPath : string;
begin
  inherited;

  UpJobInfo := PendingJobInfo as TUpJobInfo;
  UploadPath := UpJobInfo.UploadPath;

  TransferFileInfo.SetPathInfo( UploadPath, UploadPath );
end;

{ TFindDownFileInfo }

procedure TFindDownFileInfo.FindBackup;
var
  BackupJobInfo : TBackupJobInfo;
  UploadPath, CloudPath : string;
  DownPendPath, DownloadPath : string;
begin
  inherited;

  BackupJobInfo := PendingJobInfo as TBackupJobInfo;
  UploadPath := BackupJobInfo.UploadPath;

    // Pending 路径
  DownPendPath := BackupJobInfo.UploadPath;

    // 下载路径
  CloudPath := MyCloudFileInfo.ReadBackupCloudPath;
  DownloadPath := MyFilePath.getPath( CloudPath );
  DownloadPath := DownloadPath + MyFilePath.getPath( BackupJobInfo.PcID );
  DownloadPath := DownloadPath + MyFilePath.getDownloadPath( UploadPath );

    // 传输信息
  TransferFileInfo.SetPathInfo( DownPendPath, DownloadPath );
end;

procedure TFindDownFileInfo.FindDown;
var
  DownJobInfo : TDownJobInfo;
  DownloadPath : string;
begin
  DownJobInfo := PendingJobInfo as TDownJobInfo;
  DownloadPath := DownJobInfo.DownloadPath;

  TransferFileInfo.SetPathInfo( DownloadPath, DownloadPath );
end;

procedure TFindDownFileInfo.FindFileSend;
var
  FileSendJobInfo : TFileSendJobInfo;
  UploadPath : string;
  DownPendPath, DownloadPath : string;
  SendRootPath, ReceivePath, ExtractPath : string;
begin
  inherited;

  FileSendJobInfo := PendingJobInfo as TFileSendJobInfo;
  UploadPath := FileSendJobInfo.UploadPath;

    // Pending 路径
  DownPendPath := FileSendJobInfo.UploadPath;

    // 下载路径
  SendRootPath := MyFileReceiveInfoReadUtil.ReadRootSendPath( UploadPath, FileSendJobInfo.PcID );
  ReceivePath := MyFileReceiveInfoReadUtil.ReadReceivePath( SendRootPath, FileSendJobInfo.PcID );
  if ReceivePath = '' then
    ReceivePath := FileReceiveSettingInfo.ReceivePath;
  if SendRootPath <> UploadPath then
  begin
    SendRootPath := MyFilePath.getPath( SendRootPath );
    ExtractPath := MyString.CutStartStr( SendRootPath, UploadPath );
    if ExtractPath = '' then
      ExtractPath := ExtractFileName( UploadPath );
    ReceivePath := MyFilePath.getPath( ReceivePath ) + ExtractPath;
  end;
  DownloadPath := ReceivePath;


    // 传输信息
  TransferFileInfo.SetPathInfo( DownPendPath, DownloadPath );
end;

{ TTransferHandleThread }

constructor TTransferHandleThread.Create;
begin
  inherited Create( True );
end;

destructor TTransferHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TTransferHandleThread.Execute;
var
  JobInfo : TJobInfo;
begin
  while not Terminated do
  begin
      // 线程未处于运行状态
    if ThreadStatus <> ThreadStatus_Run then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 获取 Job
    JobInfo := getJobInfo;

      // 没有 可做的 Job
    if JobInfo = nil then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 做 Job
    HandleJobInfo( JobInfo );

    Sleep(100);
  end;

  inherited;
end;

procedure TTransferHandleThread.HandleJobInfo(JobInfo: TJobInfo);
var
  TransferJobHandle : TTransferJobHandle;
begin
  TransferJobHandle := getJobHandle;
  TransferJobHandle.SetJobInfo( JobInfo );
  TransferJobHandle.Update;
  TransferJobHandle.Free;
end;

{ TTransferJobHandle }

procedure TTransferJobHandle.AcceptJob;
var
  TcpSocket : TCustomIpClient;
  TransferFileAcceptHandle : TTransferFileAcceptHandle;
begin
  CreateAcceptJob;

  TcpSocket := (JobInfo as TAcceptJobInfo).TcpSocket;

  TransferFileAcceptHandle := TransferFileHandle as TTransferFileAcceptHandle;
  TransferFileAcceptHandle.SetTcpSocket( TcpSocket );
end;

procedure TTransferJobHandle.ConnJob;
var
  TransferConnFileHandle : TTransferFileConnHandle;
begin
  CreateConnJob;

  TransferConnFileHandle := TransferFileHandle as TTransferFileConnHandle;
  TransferConnFileHandle.SetJobInfo( JobInfo as TPendingJobInfo );
end;

procedure TTransferJobHandle.SetJobInfo(_JobInfo: TJobInfo);
begin
  JobInfo := _JobInfo;
end;

procedure TTransferJobHandle.Update;
var
  IsAcceptJob : Boolean;
begin
  IsAcceptJob := False;
  if JobInfo is TPendingJobInfo then
    ConnJob
  else
  if JobInfo is TAcceptJobInfo then
  begin
    AcceptJob;
    IsAcceptJob := True;
  end;

  TransferFileHandle.Update;
  TransferFileHandle.Free;

  if IsAcceptJob then
    JobInfo.Free;
end;

{ TMyFileTransfer }

procedure TMyFileTransfer.StopTransfer;
begin
  TransferFileThreadList.Clear;
end;

procedure TMyFileTransfer.CancelTransfer;
var
  i : Integer;
begin
  IsRun := False;
  for i := 0 to TransferFileThreadList.Count - 1 do
    TransferFileThreadList[i].ThreadStatus := ThreadStatus_Stop;
end;

constructor TMyFileTransfer.Create;
var
  i : Integer;
  t : TTransferHandleThread;
begin
  TransferFileThreadList := TTransferFileThreadList.Create;
  for i := 1 to Count_MaxThread do
  begin
    t := CreateThread;
    t.ThreadStatus := ThreadStatus_Stop;
    TransferFileThreadList.Add( t );
  end;
  RunThreadCount := 0;
  IsRun := True;
end;

destructor TMyFileTransfer.Destroy;
begin
  TransferFileThreadList.Free;
  inherited;
end;

function TMyFileTransfer.getThreadStatus: string;
var
  NowThreadID : Cardinal;
  i : Integer;
begin
  Result := ThreadStatus_Stop;
  if not IsRun then
    Exit;

  try
    NowThreadID := GetCurrentThreadId;
    for i := 0 to TransferFileThreadList.Count - 1 do
      if TransferFileThreadList[i].ThreadID = NowThreadID then
      begin
        Result := TransferFileThreadList[i].ThreadStatus;
        Break;
      end;
  except
    Result := ThreadStatus_Stop;
  end;
end;

procedure TMyFileTransfer.ResetRunThreadCount(NewRunCount: Integer);
var
  DelCount, i : Integer;
  IsAdd : Boolean;
begin
  if not IsRun then
    Exit;

  DelCount := NewRunCount - RunThreadCount;
  if DelCount = 0 then
    Exit;
  IsAdd := DelCount > 0;
  DelCount := Abs( DelCount );
  for i := 0 to TransferFileThreadList.Count - 1 do
  begin
    if IsAdd and ( TransferFileThreadList[i].ThreadStatus = ThreadStatus_Stop ) then
    begin
      TransferFileThreadList[i].ThreadStatus := ThreadStatus_Run;
      TransferFileThreadList[i].Resume;
      Dec( DelCount );
    end;
    if not IsAdd and ( TransferFileThreadList[i].ThreadStatus = ThreadStatus_Run ) then
    begin
      TransferFileThreadList[i].ThreadStatus := ThreadStatus_Stop;
      Dec( DelCount );
    end;
    if DelCount <= 0 then
      Break;
  end;
  RunThreadCount := NewRunCount;
end;

procedure TMyFileTransfer.RunAllThread;
var
  i : Integer;
begin
  if not IsRun then
    Exit;

  for i := 0 to TransferFileThreadList.Count - 1 do
    if TransferFileThreadList[i].ThreadStatus = ThreadStatus_Run then
      TransferFileThreadList[i].Resume;
end;

{ TDownloadHandleThread }

function TDownloadHandleThread.getJobHandle: TTransferJobHandle;
begin
  Result := TDownloadJobHandle.Create;
end;

function TDownloadHandleThread.getJobInfo: TJobInfo;
begin
  MyJobInfo.EnterData;
  Result := MyJobInfo.DownloadJobInfo.getNextJobInfo;
  MyJobInfo.LeaveData;
end;

{ TUploadHandleThread }

function TUploadHandleThread.getJobHandle: TTransferJobHandle;
begin
  Result := TUploadJobHandle.Create;
end;

function TUploadHandleThread.getJobInfo: TJobInfo;
begin
  MyJobInfo.EnterData;
  Result := MyJobInfo.UploadJobInfo.getNextJobInfo;
  MyJobInfo.LeaveData;
end;

{ TDownloadJobHandle }

procedure TDownloadJobHandle.CreateAcceptJob;
begin
  TransferFileHandle := TAcceptDownFileHandle.Create;
end;

procedure TDownloadJobHandle.CreateConnJob;
begin
  if JobInfo is TShareJobInfo then
    TransferFileHandle := TDownShareFileHandle.Create
  else
  if JobInfo is TRestoreJobInfo then
    TransferFileHandle := TDownRestoreFileHandle.Create
  else
  if JobInfo is TSourceSearchJobInfo then
    TransferFileHandle := TDownSerachSourceFileHandle.Create
  else
  if JobInfo is TBackupSearchJobInfo then
    TransferFileHandle := TDownSerachBackupFileHandle.Create
  else
    TransferFileHandle := TDownFileHandle.Create;
end;

{ TUploadJobHandle }

procedure TUploadJobHandle.CreateAcceptJob;
begin
  TransferFileHandle := TAcceptUploadFileHandle.Create;
end;

procedure TUploadJobHandle.CreateConnJob;
begin
  if JobInfo is TBackupJobInfo then
    TransferFileHandle := TUploadBackupFileHandle.Create
  else
  if JobInfo is TFileSendJobInfo then
    TransferFileHandle := TUploadTransferFileHandle.Create
  else
    TransferFileHandle := TUploadFileHandle.Create;
end;

{ TTransferDownBackupReqMsg }

procedure TTransferDownBackupReqMsg.SetBackupFilePcID(_BackupFilePcID: string);
begin
  BackupFilePcID := _BackupFilePcID;
end;

{ TTransferSourceSearchReqMsg }

function TTransferSourceSearchReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_SourceSearch;
end;

{ TTransferBackupSearchReqMsg }

function TTransferBackupSearchReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_BackupSearch;
end;

{ DataBufUtil }

class procedure DataBufUtil.DecryptRevBuf(RevBuf: TRevDataBuf; Key: string);
var
  DesHardBufHandle : TDesHardBufHandle;
begin
  DesHardBufHandle := TDesHardBufHandle.Create( RevBuf.HardBuf, RevBuf.BufSize );
  DesHardBufHandle.SetEncrypt( False, Key );
  RevBuf.HardBuf := DesHardBufHandle.get;
  DesHardBufHandle.Free;
end;

class procedure DataBufUtil.EncryptSendBuf(SendBuf: TSendDataBuf; Key: string);
var
  DesHardBufHandle : TDesHardBufHandle;
begin
  DesHardBufHandle := TDesHardBufHandle.Create( SendBuf.HardBuf, SendBuf.BufSize );
  DesHardBufHandle.SetEncrypt( True, Key );
  SendBuf.HardBuf := DesHardBufHandle.get;
  DesHardBufHandle.Free;
end;

{ TTransferUpReqMsg }

procedure TTransferUpReqMsg.SetUpFilePath(_UpFilePath: string);
begin
  UpFilePath := _UpFilePath;
end;

{ TTransferFileSendReqMsg }

function TTransferFileSendReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_FileSend;
end;

{ TSendDataBuf }

function TSendDataBuf.getSendBuf( var SendBuf: TTransferBuf ): Integer;
var
  i, SendSize : Integer;
begin
    // 全部读完
  if SendPosition = BufSize then
  begin
    Result := -1;
    Exit;
  end;

    // 读取发送 Buf
  SendSize := Min( Size_TransferBuf, BufSize - SendPosition );
  for i := 0 to SendSize - 1 do
  begin
    SendBuf[i] := HardBuf[SendPosition];
    Inc( SendPosition );
  end;
  Result := SendSize;
end;

procedure TSendDataBuf.SetBufInfo(_BufSize: Integer);
begin
  BufSize := _BufSize;
  SendPosition := 0;
end;

{ TRevDataBuf }

function TRevDataBuf.AddRevBuf(RevBuf: TTransferBuf; RevSize: Integer): Boolean;
var
  i : Integer;
begin
  for i := 0 to RevSize - 1 do
  begin
    HardBuf[ BufSize ] := RevBuf[i];
    Inc( BufSize );
  end;

  Result := BufSize < Size_DataBuf;
end;

procedure TRevDataBuf.ClearWriteData;
begin
  BufSize := 0;
end;

{ TDesHardBufHandle }

constructor TDesHardBufHandle.Create(_HardBuf: THardBuf; _BufSize: Integer);
begin
  HardBuf := _HardBuf;
  BufSize := _BufSize;
end;

function TDesHardBufHandle.get: THardBuf;
var
  Key64 : TKey64;
  Context    : TDESContext;
  EncryptChar : Char;
  BlockCount, BlockSize, RemainSize : Integer;
  i, j, StartPos : Integer;
  Block : TDESBlock;
begin
  GenerateLMDKey( Key64, SizeOf(Key64), Key );
  InitEncryptDES( Key64, Context, IsEncrypt );

    // 加密块
  BlockSize := SizeOf( Block );
  BlockCount := ( BufSize div BlockSize );
  for i := 0 to BlockCount - 1 do
  begin
    StartPos := i * BlockSize;
    for j := 0 to BlockSize - 1 do
      Block[j] := HardBuf[ StartPos + j ];
    EncryptDES(Context, Block);
    for j := 0 to BlockSize - 1 do
      Result[ StartPos + j ] := Block[j];
  end;

    // 加密不足块的部分
  StartPos := BlockCount * BlockSize;
  RemainSize := BufSize mod BlockSize;
  for i := 0 to RemainSize - 1 do
  begin
    j := ( i mod Length( Key ) ) + 1;
    EncryptChar := Key[j];
    if IsEncrypt then
      Result[ StartPos + i ] := ( HardBuf[ StartPos + i ] + Integer( EncryptChar ) ) mod 256
    else
      Result[ StartPos + i ] := ( HardBuf[ StartPos + i ] - Integer( EncryptChar ) ) mod 256
  end;
end;

procedure TDesHardBufHandle.SetEncrypt(_IsEncrypt: Boolean; _Key: string);
begin
  IsEncrypt := _IsEncrypt;
  Key := _Key;
end;

{ TransferUtil }

class function TransferUtil.getIsSendMD5Activate(FileType: string): Boolean;
begin
  Result := ( FileType = FileType_Backup ) or ( FileType = FileType_Transfer );
end;

class function TransferUtil.getMD5Buffer(var Buf: THardBuf; BufSize: Int64): string;
var
  Context: TMD5Context;
  MD5Digest : TMD5Digest;
begin
  MD5Init(Context);
  MD5Update(Context, @Buf, SizeOf(Buf));
  MD5Final(Context, MD5Digest);

  Result := MD5Print( MD5Digest );
end;

{ TTransferShareReqMsg }

function TTransferShareReqMsg.getMsgType: string;
begin
  Result := TransferReqMsg_FileShare;
end;

end.



