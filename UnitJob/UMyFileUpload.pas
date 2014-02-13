unit UMyFileUpload;

interface

uses UModelUtil, Sockets, UMyFileTransfer, UMyUtil, Classes, SysUtils, Math, WinSock, DateUtils,
     SyncObjs, Generics.Collections, UMyJobInfo, UChangeInfo, uDebug;

type

{$Region ' 上传文件 ' }

    // 主动上传
  TUploadFileHandle = class( TTransferFileConnHandle )
  protected
    function getTransferType : string;override;
  end;

    // 主动上传 备份
  TUploadBackupFileHandle = class( TUploadFileHandle )
  protected
    function getJobIsContinues : Boolean;override;
    procedure ConnErrorHandle;override;
    procedure AcceptCancelHandle;override;
  private       // 删除 备份信息 和 重新分配 Job
    procedure RemovePendingInfo;
    procedure RefreshBackupJob;
  private        // Offline
    procedure AddOfflineInfo;
    procedure AddOfflineJobInfo;
  private       // 删除远程Pc DownPend
    procedure RemoveRemoteDownPend;
  end;

    // 主动上传 传输文件
  TUploadTransferFileHandle = class( TUploadFileHandle )
  protected
    function getJobIsContinues : Boolean;override;
    procedure ConnErrorHandle;override;
  private        // 添加 Job
    procedure AddFileSendOffline;
  private       // 删除远程Pc DownPend
    procedure RemoveRemoteDownPend;
  end;

    // 被动上传
  TAcceptUploadFileHandle = class( TTransferFileAcceptHandle )
  protected
    function getTransferType : string;override;
  protected
    function getAcceptIsContinues : Boolean;override;
    function getFileShareContinues : Boolean;
  end;

{$EndRegion}

{$Region ' 发送文件 ' }

    // 更新 Loading 界面
  TUploadingFaceThread = class( TThread )
  private
    PcID, UpFilePath : string;
    FileSize, Position : Int64;
  private
    Lock : TCriticalSection;
    LastFaceTime : TDateTime;
    SecondSendSize : Int64;
  public
    constructor Create( _FileSize, _Position : Int64 );
    procedure SetFileInfo( _PcID, _UpFilePath : string );
    procedure AddSendSize( SendSize : Integer );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure UpdateFace;
  end;

    // 发送文件处理
  TSendFileHandle = class(TTransferFile)
  private
    PcID, UpFilePath : string;
    Position, FileSize : Int64;
    FileTime : TDateTime;
    IsContinusFile : Boolean;
    FileType : string;
  private
    TcpSocket : TCustomIpClient;
    PendingJobInfo : TPendingJobInfo;
    DataBuf : TSendDataBuf;
    TransResult : string;
  private
    UploadingFaceThread : TUploadingFaceThread;
    StartSendTime : TDateTime;
    AllSendSize : Int64;
  private
    IsMD5Check : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );override;
    procedure SetTransferFileInfo( TransferFileInfo : TTransferFileInfo );override;
    procedure SetPendingJobInfo( _PendingJobInfo : TPendingJobInfo );override;
    procedure Update;override;
    destructor Destroy; override;
  private       // 可能 已存在 需要下载的文件
    procedure IniFileSend;virtual;
    function DownFileCheck : string;
    procedure SendFileMD5Confirm;  // 发送文件 是否需要 MD5 验证
    procedure SendFile;
  private       // 读文件 和 发送文件
    function ReadDataBuf : string;virtual;
    function SendDataBuf : Boolean;
    function CheckMD5DataBuf : Boolean;
  protected     // 界面更新
    procedure AddUploadingFace;
    procedure UpdateloadingFace( SendSize : Integer );virtual;
    procedure DeleteUploadingFace;
    procedure AddUploadedFace( IsDownExist : Boolean );
  protected
    procedure DownFileExistHandle;virtual;
    function CheckUploadContinues : Boolean;virtual;
    procedure SendFileBefore;virtual;
    procedure HandleDataBuf;virtual;
    procedure SendFileAfter;virtual;
  protected       // 检测是否继续传输
    function CheckNextSend : Boolean;virtual;
    procedure SendFileSleep( var StartTime : TDateTime; var SendCount : Integer );
    procedure AddPcUploadingFace;virtual;
    procedure RemovePcUploadingFace;virtual;
  end;

    // 主动 发送文件 处理
  TSendFileActivateHandle = class( TSendFileHandle )
  protected
    function CheckNextSend : Boolean;override;
  end;

    // 发送 备份文件
  TSendBackupFileHandle = class( TSendFileActivateHandle )
  private
    IsEncrypted : Boolean;
    Password : string;
  private
    IsRemoteConn : Boolean;
  private
    LastUploadFaceTime : TDateTime;
  protected
    function CheckUploadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure HandleDataBuf;override;
    procedure SendFileBefore;override;
    procedure SendFileAfter;override;
  protected    // 发送检测
    procedure IniFileSend;override;
    function CheckNextSend : Boolean;override;
    procedure UpdateloadingFace( SendSize : Integer );override;
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  private       // Normal
    procedure AddUploadingInfo;
    procedure AddUploadedInfo;
  private       // Offline
    procedure AddOfflineInfo;  // 断线时使用
    procedure AddOfflineJob;
  private       // Transfer Error
    procedure DeleteUploadingInfo; // 传输失败时使用
    procedure RefreshBackupJob; // 重新分配 Job
  end;

    // 发送 传输文件
  TSendTransferFileHandle = class( TSendFileActivateHandle )
  private
    RootSendPath : string;
    StartTimeLoading : TDateTime;
    LoadingSize : Integer;
  protected
    procedure IniFileSend;override;
    function CheckUploadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure SendFileBefore;override;
    procedure SendFileAfter;override;
  protected    // 发送检测
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  private
    procedure UpdateloadingFace( SendSize : Integer );override; // 发送完一小部分文件
    procedure RefreshLastLoadingFace; // 刷新最后的 Loading 空间信息
    procedure SetFileSendStatusFace( SendStatus : string ); // 修改 界面状态显示
  private
    procedure AddFileSendOffline;   // 添加 续传 Job
    procedure CompletedFileSend; // 传输文件 完成
  end;

    // 被动 发送 共享文件
  TSendShareFileHandle = class( TSendFileHandle )
  protected
    function CheckUploadContinues : Boolean;override;
  protected
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  end;

{$EndRegion}

  TMyFileUpload = class( TMyFileTransfer )
  public
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
  protected
    function CreateThread : TTransferHandleThread;override;
  end;

var
  MyFileUpload : TMyFileUpload;

implementation

uses UMyNetPcInfo, UMyTcp, UJobFace, UMyBackupInfo, UBackupInfoXml, UNetworkFace, USettingInfo,
     UBackupInfoFace, UNetPcInfoXml, UBackupFileScan, UBackupInfoControl, UMyFileTransferControl,
     UMyFileTransferInfo, UFileTransferFace, UJobControl, UMyShareInfo, UMyShareFace, UMyClient;

{ TSendFile }

procedure TSendFileHandle.AddPcUploadingFace;
begin
end;

procedure TSendFileHandle.AddUploadedFace( IsDownExist : Boolean );
var
  PcName, RootID : string;
  TotalSpeed : Int64;
  UsedTime : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  VirTransferChildLoadedInfo : TVirTransferChildLoadedInfo;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // 不显示 Lost Conn
  if TransResult = TransFile_LostCon then
    Exit;

  if IsDownExist or ( TransResult = TransFile_OK ) then
    RootID := RootID_UpLoaded
  else
    RootID := RootID_UpError;

    // 添加 Loaded
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, TransResult );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );
  MyJobFace.AddChange( VirTransferChildAddInfo );

    // 刷新 Loaded 信息
  if IsDownExist then
  begin
    UsedTime := 0;
    TotalSpeed := 0;
  end
  else
  begin
    UsedTime := Max( SecondsBetween( Now, StartSendTime ), 1 );
    TotalSpeed := AllSendSize div UsedTime;
  end;

    // 修改 Loaded 信息
  VirTransferChildLoadedInfo := TVirTransferChildLoadedInfo.Create( RootID );
  VirTransferChildLoadedInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildLoadedInfo.SetTimeInfo( UsedTime, TotalSpeed );
  MyJobFace.AddChange( VirTransferChildLoadedInfo );

    // 错误 跳过
  if RootID = RootID_UpError then
    Exit;

    // 删除存在的 Error
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_UpError );
  VirTransferChildRemoveInfo.SetChildID( PcID, UpFilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TSendFileHandle.AddUploadingFace;
var
  PcName : string;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
    // 添加 Loading
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_UpLoading );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, FileStatus_Loading );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );

  MyJobFace.AddChange( VirTransferChildAddInfo );

    // 更新 Loading
  UploadingFaceThread := TUploadingFaceThread.Create( FileSize, Position );
  UploadingFaceThread.SetFileInfo( PcID, UpFilePath );
  UploadingFaceThread.Resume;

    // 更新 Loaded
  AllSendSize := 0;
  StartSendTime := Now;

    // Pc 位置显示正在上传
  AddPcUploadingFace;
end;

function TSendFileHandle.CheckMD5DataBuf: Boolean;
var
  SendMD5Str : string;
  MD5ResultStr : string;
begin
  Result := True;
  if not IsMD5Check then
    Exit;

  SendMD5Str := TransferUtil.getMD5Buffer( DataBuf.HardBuf, DataBuf.BufSize );
  MySocketUtil.SendString( TcpSocket, SendMD5Str );
  MD5ResultStr := MySocketUtil.RevData( TcpSocket );
  Result := StrToBoolDef( MD5ResultStr, False );
end;

function TSendFileHandle.CheckNextSend : Boolean;
var
  ThreadStatus : string;
begin
    // 获取 当前线程 状态
  ThreadStatus := MyFileUpload.getThreadStatus;

  Result := False;

    // 传输线程 发生变化
  if ThreadStatus = ThreadStatus_Stop then
    TransResult := TransFile_LostCon
  else
    Result := True;
end;

function TSendFileHandle.CheckUploadContinues: Boolean;
begin
  Result := True;
end;

constructor TSendFileHandle.Create;
begin
  DataBuf := TSendDataBuf.Create;
  IsContinusFile := False;
  IsMD5Check := False;
end;

procedure TSendFileHandle.DeleteUploadingFace;
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // 停止 Loading 界面更新
  UploadingFaceThread.Free;

    // 删除 Loading
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_UpLoading );
  VirTransferChildRemoveInfo.SetChildID( PcID, UpFilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );

    // Pc 位置显示上传
  RemovePcUploadingFace;
end;


destructor TSendFileHandle.Destroy;
begin
  DataBuf.Free;
  inherited;
end;

procedure TSendFileHandle.DownFileExistHandle;
begin
end;

procedure TSendFileHandle.SendFileSleep(var StartTime: TDateTime;
  var SendCount : Integer);
var
  SendMiSeconds, SleepTime : Int64;
  UploadSpeed : Integer;
begin
  UploadSpeed := TransferSettingInfo.UploadSpeed;

     // 最快速度
  if UploadSpeed = TransferSpeed_Fast then
  begin
    if SendCount = Count_HandleSleep then
    begin
      SendCount := 0;
      SleepTime := 1;
    end
    else
      SleepTime := 0;
  end
  else
  begin
    SendMiSeconds := MilliSecondsBetween( Now, StartTime );
    if SendMiSeconds = 0 then // 未够 1 毫秒
      Exit;

         // 中等速度
    if UploadSpeed = TransferSpeed_Normal then
      SleepTime := SendMiSeconds
    else  // 最慢速度
      SleepTime := SendMiSeconds * 9;
  end;

    // 最多 1 秒
  SleepTime := Min( SleepTime, 1000 );

    // Sleep
  while ( SleepTime > 0 ) and CheckNextSend do
  begin
    if SleepTime <= 100 then
    begin
      Sleep( SleepTime );
      Break;
    end;
    Sleep(100);
    SleepTime := SleepTime - 100;
  end;
  StartTime := Now;
end;

function TSendFileHandle.DownFileCheck: string;
var
  DownFileCheckMsg : string;
begin
  DownFileCheckMsg := MySocketUtil.RevData( TcpSocket );
  if IsContinusFile then
    Position := StrToInt64Def( MySocketUtil.RevData( TcpSocket ), 0 );
  Result := DownFileCheckMsg;
end;

procedure TSendFileHandle.HandleDataBuf;
begin

end;

procedure TSendFileHandle.IniFileSend;
begin

end;

function TSendFileHandle.ReadDataBuf: string;
var
  FileStream : TFileStream;
  RemainSize : Int64;
  BufSize, ReadSize : Integer;
begin
    // 取消上传
  if not CheckUploadContinues then
  begin
    Result := ReadFile_UploadCancel;
    Exit;
  end;

    // 上传文件不存在
  if not FileExists( UpFilePath ) then
  begin
    Result := ReadFile_FileNotExist;
    Exit;
  end;

    // 上传文件发生了变化
  if ( MyFileInfo.getFileSize( UpFilePath ) <> FileSize ) or
     ( not MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( UpFilePath ), FileTime )  )
  then
  begin
    Result := ReadFile_FileChange;
    Exit;
  end;

    // 读取磁盘文件
  try
    FileStream := TFileStream.Create( UpFilePath, fmOpenRead or fmShareDenyNone );
    FileStream.Position := Position; // 设置读文件开始位置
    RemainSize := FileSize - Position;  // 文件剩余大小
    BufSize := Min( RemainSize, Size_DataBuf ); // 读取文件的大小
    ReadSize := FileStream.Read( DataBuf.HardBuf, BufSize ); // 读取文件
    FileStream.Free;
  except
    Result := ReadFile_ReadError;
    Exit;
  end;

    // 读取 错误
  if ReadSize <> BufSize then
  begin
    Result := ReadFile_ReadError;
    Exit;
  end;

    // 读取成功
  DataBuf.SetBufInfo( ReadSize );
  Result := ReadFile_OK;
end;


procedure TSendFileHandle.RemovePcUploadingFace;
begin
end;

function TSendFileHandle.SendDataBuf: Boolean;
var
  Buf : TTransferBuf;
  BufSize, SendSize, TotalSendSize : Integer;
  SendCount : Integer;
  SendStartTime : TDateTime;
begin
  Result := True;

  TotalSendSize := 0;
  SendCount := 0;
  SendStartTime := Now;
  while True do
  begin
      // 检查是否 继续发送
    if not CheckNextSend then  // 本机主动结束
    begin
      TcpSocket.Disconnect; // 断开连接
      Result := False;
      Break;
    end;

      // 发送 NK 数据
    BufSize := DataBuf.getSendBuf( Buf );
    if BufSize <= 0 then // 发送完成
      Break;
    SendSize := TcpSocket.SendBuf( Buf, BufSize );
    if SendSize = SOCKET_ERROR then  // 对方主动结束
    begin
      TransResult := TransFile_LostCon;
      Result := False;
      Break;
    end;

      // 发送位置
    TotalSendSize := TotalSendSize + SendSize;

      // 界面
    UpdateloadingFace( SendSize );

      // sleep CPU
    SendFileSleep( SendStartTime, SendCount );
    Inc( SendCount );
  end;



    // MD5 错误, 重新发送
  if Result and not CheckMD5DataBuf then
  begin
    UpdateloadingFace( -DataBuf.BufSize );
    DataBuf.SendPosition := 0;
    Result := SendDataBuf;
    Exit;
  end;

    // 发送成功
  if Result then
    Position := Position + TotalSendSize;
end;

procedure TSendFileHandle.SendFile;
var
  ReadFileResult, WriteFileResult : string;
begin
  TransResult := TransFile_OK;
  while FileSize > Position do
  begin
      // 读取磁盘文件
    ReadFileResult := ReadDataBuf;

      // 发送 读取文件结果 , 对方可能断开连接
    if MySocketUtil.SendString( TcpSocket, ReadFileResult ) = SOCKET_ERROR then
    begin
      TransResult := TransFile_LostCon;
      Break;
    end;

      // 读取文件 失败
    if ReadFileResult <> ReadFile_OK then
    begin
      TransResult := ReadFileResult;
      Break;
    end;

      // 发送文件前处理
      // 加密 MD5 等
    HandleDataBuf;

      // 发送磁盘文件, 可能出现对方断开连接
    if not SendDataBuf then
      Break;

      // 接收 写入文件结果
    WriteFileResult := MySocketUtil.RevData( TcpSocket );

      // 写入文件失败
    if WriteFileResult <> WriteFile_OK then
    begin
      if WriteFileResult = '' then   // 对方断开连接
        TransResult := TransFile_LostCon
      else
        TransResult := WriteFileResult;
      Break;
    end;
  end;
end;

procedure TSendFileHandle.SendFileAfter;
begin
end;

procedure TSendFileHandle.SendFileBefore;
begin
end;

procedure TSendFileHandle.SendFileMD5Confirm;
var
  IsMD5Activate : Boolean;
begin
    // 是否 MD5 主动方
  IsMD5Activate := TransferUtil.getIsSendMD5Activate( FileType );

    // MD5 主动方 则发送
    // MD5 被动方 则接收
  if IsMD5Activate then
  begin
    IsMD5Check := TransferSafeSettingInfo.IsMD5Check;
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsMD5Check ) );
  end
  else
    IsMD5Check := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), False );
end;

procedure TSendFileHandle.SetPendingJobInfo(_PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

procedure TSendFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TSendFileHandle.SetTransferFileInfo(
  TransferFileInfo: TTransferFileInfo);
begin
  PcID := TransferFileInfo.PcID;
  UpFilePath := TransferFileInfo.LoadPath;
  Position := TransferFileInfo.Position;
  FileSize := TransferFileInfo.FileSize;
  FileTime := TransferFileInfo.FileTime;
  FileType := TransferFileInfo.FileType;
  IsContinusFile := Position > 0;
end;

procedure TSendFileHandle.Update;
var
  DownFileCheckResult : string;
begin
  IniFileSend; // 初始化 文件发送

  DownFileCheckResult := DownFileCheck;

    // 下载方 文件存在 则 发送结束
  if DownFileCheckResult = WriteFile_Exist then
  begin
    TransResult := WriteFile_Exist;
    Position := FileSize;
    AddUploadedFace( True );

    DownFileExistHandle;
  end
  else    // 发送文件
  begin
    SendFileMD5Confirm; // 是否 MD5 检测

    SendFileBefore;  // 发送文件前 处理

    AddUploadingFace;
    if DownFileCheckResult = WriteFile_OK then
      SendFile
    else
      TransResult := DownFileCheckResult;
    DeleteUploadingFace;
    AddUploadedFace( False );

    SendFileAfter;  // 发送文件后 处理
  end;
end;

procedure TSendFileHandle.UpdateloadingFace(SendSize: Integer);
begin
    // Loading
  UploadingFaceThread.AddSendSize( SendSize );

    // Loaded
  AllSendSize := AllSendSize + SendSize;

    // 主窗口界面
  TransferSpeedFaceThread.AddUploadSpeed( SendSize );
end;

{ TUploadingFaceThread }

procedure TUploadingFaceThread.AddSendSize(SendSize: Integer);
begin
  Lock.Enter;
  SecondSendSize := SecondSendSize + SendSize;
  Lock.Leave;
end;

constructor TUploadingFaceThread.Create(_FileSize, _Position: Int64);
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  FileSize := _FileSize;
  Position := _Position;
  SecondSendSize := 0;
  LastFaceTime := Now;
end;

destructor TUploadingFaceThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  Lock.Free;
  inherited;
end;

procedure TUploadingFaceThread.Execute;
begin
  while not Terminated do
  begin
    while ( SecondsBetween( Now, LastFaceTime ) < 1 ) and not Terminated do
      Sleep( 100 );

    if Terminated then
      Break;

    UpdateFace;
  end;

  inherited;
end;

procedure TUploadingFaceThread.SetFileInfo(_PcID, _UpFilePath: string);
begin
  PcID := _PcID;
  UpFilePath := _UpFilePath;
end;

procedure TUploadingFaceThread.UpdateFace;
var
  TempSecondSendSize : Int64;
  RemainTime : Integer;
  VirTransferChildLoadingInfo : TVirTransferChildLoadingInfo;
begin
  Lock.Enter;
  TempSecondSendSize := SecondSendSize;
  SecondSendSize := 0;
  LastFaceTime := Now;
  Lock.Leave;

  Position := Position + TempSecondSendSize;
  if TempSecondSendSize < 1 then
    RemainTime := MyTime.getMaxTime
  else
    RemainTime := ( FileSize - Position ) div TempSecondSendSize;

  VirTransferChildLoadingInfo := TVirTransferChildLoadingInfo.Create( RootID_UpLoading );
  VirTransferChildLoadingInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildLoadingInfo.SetPercentage( Position, FileSize );
  VirTransferChildLoadingInfo.SetTimeInfo( TempSecondSendSize, RemainTime );

  MyJobFace.AddChange( VirTransferChildLoadingInfo );
end;


{ TUploadBackupFileHandle1 }

procedure TUploadBackupFileHandle.AcceptCancelHandle;
begin
  RemovePendingInfo;
  RefreshBackupJob;
end;

procedure TUploadBackupFileHandle.AddOfflineInfo;
var
  PcID, FilePath : string;
  Position : Int64;
  BackupCopyAddOfflineHandle : TBackupCopyAddOfflineHandle;
begin
    // 提取信息
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  Position := TransferFileInfo.Position;

    // 添加 Offline Backup Copy
  BackupCopyAddOfflineHandle := TBackupCopyAddOfflineHandle.Create( FilePath );
  BackupCopyAddOfflineHandle.SetCopyOwner( PcID );
  BackupCopyAddOfflineHandle.SetPosition( Position );
  BackupCopyAddOfflineHandle.Update;
  BackupCopyAddOfflineHandle.Free;
end;

procedure TUploadBackupFileHandle.AddOfflineJobInfo;
var
  PcID, FilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
    // 提取信息
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;

    // 添加到 Offline
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( FilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TUploadBackupFileHandle.ConnErrorHandle;
begin
    // 续传 或 取消备份
  if TransferFileInfo.Position > 0 then
  begin
    AddOfflineInfo;
    AddOfflineJobInfo;
  end
  else
  begin
    RemovePendingInfo;  // 删除 Pending
    RefreshBackupJob;   // 重新分配 Job
  end;
end;

function TUploadBackupFileHandle.getJobIsContinues: Boolean;
begin
  Result := MyBackupPathInfoUtil.ReadIsEnable( TransferFileInfo.LoadPath );
  if not Result then  // 删除 备份目标 DownPend
    RemoveRemoteDownPend;
end;

{ TAcceptUploadFile }

function TAcceptUploadFileHandle.getAcceptIsContinues: Boolean;
var
  FileType : string;
begin
  FileType := TransferFileInfo.FileType;
  if FileType = FileType_Share then
    Result := getFileShareContinues
  else
    Result := True;
end;

function TAcceptUploadFileHandle.getFileShareContinues: Boolean;
begin
  Result := MySharePathInfoReadUtil.ReadFileIsEnable( TransferFileInfo.LoadPath );
end;

function TAcceptUploadFileHandle.getTransferType: string;
begin
  Result := TransferType_Upload;
end;

{ TUploadFileHandle }

function TUploadFileHandle.getTransferType: string;
begin
  Result := TransferType_Upload;
end;

{ TSendBackupFileHandle }

procedure TSendBackupFileHandle.AddOfflineInfo;
var
  BackupCopyAddOfflineHandle : TBackupCopyAddOfflineHandle;
begin
  BackupCopyAddOfflineHandle := TBackupCopyAddOfflineHandle.Create( UpFilePath );
  BackupCopyAddOfflineHandle.SetCopyOwner( PcID );
  BackupCopyAddOfflineHandle.SetPosition( Position );
  BackupCopyAddOfflineHandle.Update;
  BackupCopyAddOfflineHandle.Free;
end;

function TSendBackupFileHandle.CheckNextSend: Boolean;
begin
  Result := False;

    // 已经 发送失败
  if not inherited then
    Exit;

    // 禁止 远程传输
  if IsRemoteConn and TransferSafeSettingInfo.IsRemoveForbid then
    TransResult := TransFile_RemoteForbid
  else
    Result := True;
end;

function TSendBackupFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MyBackupPathInfoUtil.ReadIsEnable( UpFilePath );
end;

procedure TSendBackupFileHandle.AddOfflineJob;
var
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( UpFilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TSendBackupFileHandle.AddPcUploadingFace;
var
  NetworkLvAddUpload : TLvNetworkAddUpload;
begin
    // 更新 Network Listview
  NetworkLvAddUpload := TLvNetworkAddUpload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvAddUpload );
end;

procedure TSendBackupFileHandle.AddUploadedInfo;
var
  BackupCopyAddControl : TBackupCopyAddControl;
begin
    // 添加 副本
  BackupCopyAddControl := TBackupCopyAddControl.Create( UpFilePath, PcID );
  BackupCopyAddControl.SetFileSize( FileSize );
  BackupCopyAddControl.Update;
  BackupCopyAddControl.Free;
end;

procedure TSendBackupFileHandle.AddUploadingInfo;
var
  BackupCopyAddLoadingHandle : TBackupCopyAddLoadingHandle;
begin
  BackupCopyAddLoadingHandle := TBackupCopyAddLoadingHandle.Create( UpFilePath );
  BackupCopyAddLoadingHandle.SetCopyOwner( PcID );
  BackupCopyAddLoadingHandle.Update;
  BackupCopyAddLoadingHandle.Free;
end;

procedure TSendBackupFileHandle.DeleteUploadingInfo;
var
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( UpFilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TSendBackupFileHandle.DownFileExistHandle;
begin
  AddUploadedInfo;
end;

procedure TSendBackupFileHandle.HandleDataBuf;
begin
  if IsEncrypted then
    DataBufUtil.EncryptSendBuf( DataBuf, Password );
end;

procedure TSendBackupFileHandle.IniFileSend;
var
  RemoteIp : string;
begin
    // 读取 加密信息
  Password := MyBackupPathInfoUtil.ReadPassword( UpFilePath );
  IsEncrypted := Password <> '';

    // 读取 是否远程连接
  RemoteIp := MyNetPcInfoReadUtil.ReadIp( PcID );
  IsRemoteConn := not MyParseHost.CheckIpLan( PcInfo.LanIp, RemoteIp );
end;

procedure TSendBackupFileHandle.RefreshBackupJob;
var
  BackupFileRefreshJobHandle : TBackupFileSyncHandle;
begin
    // 读文件出错, 不重新分配 Job
  if ( TransResult = ReadFile_FileNotExist ) or
     ( TransResult = ReadFile_FileChange ) or
     ( TransResult = ReadFile_ReadError )
  then
    Exit;

    // 重新分配 Job
  BackupFileRefreshJobHandle := TBackupFileSyncHandle.Create( UpFilePath );
  BackupFileRefreshJobHandle.Update;
  BackupFileRefreshJobHandle.Free;
end;

procedure TSendBackupFileHandle.RemovePcUploadingFace;
var
  NetworkLvRemoveUpload : TLvNetworkRemoveUpload;
begin
    // 更新 Network ListView
  NetworkLvRemoveUpload := TLvNetworkRemoveUpload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvRemoveUpload );
end;

procedure TSendBackupFileHandle.SendFileAfter;
begin
    // 发送 成功
  if TransResult = TransFile_OK then
    AddUploadedInfo
  else    // 离线
  if ( TransResult = TransFile_LostCon ) and ( Position > 0 ) then
  begin
    Sleep(500);
    AddOfflineInfo;
    AddOfflineJob;
  end
  else   // 发送失败
  begin
    DeleteUploadingInfo;
    RefreshBackupJob;
  end;
end;

procedure TSendBackupFileHandle.SendFileBefore;
begin
    // 添加 Loading 信息
  AddUploadingInfo;
end;

procedure TSendBackupFileHandle.UpdateloadingFace(SendSize: Integer);
var
  BackupPgShowInfo : TBackupPgShowInfo;
begin
  inherited;

    // 1 秒钟响应一次
  if SecondsBetween( Now, LastUploadFaceTime ) < 1 then
    Exit;

    // 显示进度条
  BackupPgShowInfo := TBackupPgShowInfo.Create;
  MyBackupFileFace.AddChange( BackupPgShowInfo );

  LastUploadFaceTime := Now;
end;

{ TMyFileUpload }

procedure TMyFileUpload.AcceptSocket(TcpSocket: TCustomIpClient);
var
  IsAcceptJob : Boolean;
  AcceptJobInfo : TAcceptJobInfo;
  JobAddInfo : TJobAddInfo;
  UploadJobChangeInfo : TUploadJobChangeInfo;
begin
    // 是否繁忙
  MyJobInfo.EnterData;
  IsAcceptJob := MyJobInfo.UploadJobInfo.CheckAcceptJob;
  MyJobInfo.LeaveData;

    // 不繁忙则 接 Job
  if IsAcceptJob then
  begin
    AcceptJobInfo := TAcceptJobInfo.Create;
    AcceptJobInfo.SetTcpSocket( TcpSocket );

    JobAddInfo := TJobAddInfo.Create;
    JobAddInfo.SetJobInfo( AcceptJobInfo );

    UploadJobChangeInfo := TUploadJobChangeInfo.Create;
    UploadJobChangeInfo.SetJobWriteInfo( JobAddInfo );

    MyJobInfo.AddChange( UploadJobChangeInfo );
  end
  else
    TcpSocket.Free;
end;

procedure TUploadBackupFileHandle.RefreshBackupJob;
var
  FilePath : string;
  BackupFileRefreshJobHandle : TBackupFileSyncHandle;
begin
  FilePath := TransferFileInfo.LoadPath;

    // 重新分配 Job
  BackupFileRefreshJobHandle := TBackupFileSyncHandle.Create( FilePath );
  BackupFileRefreshJobHandle.Update;
  BackupFileRefreshJobHandle.Free;
end;

procedure TUploadBackupFileHandle.RemovePendingInfo;
var
  FilePath, PcID : string;
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
    // 提取信息
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;

    // 删除 Pending 副本信息
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TUploadBackupFileHandle.RemoveRemoteDownPend;
var
  PcRemoveDownPendFileMsg : TPcRemoveDownPendFileMsg;
begin
  PcRemoveDownPendFileMsg := TPcRemoveDownPendFileMsg.Create;
  PcRemoveDownPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveDownPendFileMsg.SetRemovePath( TransferFileInfo.LoadPath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveDownPendFileMsg );
end;

function TMyFileUpload.CreateThread: TTransferHandleThread;
begin
  Result := TUploadHandleThread.Create;
end;

{ TSendTransferFileHandle }

procedure TSendTransferFileHandle.DownFileExistHandle;
var
  SendFileAddCompletedSpaceHandle : TSendFileAddCompletedSpaceHandle;
begin
  inherited;

    // 添加 已完成信息 目录节点
  SendFileAddCompletedSpaceHandle := TSendFileAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileAddCompletedSpaceHandle.SetCompletedSize( FileSize );
  SendFileAddCompletedSpaceHandle.Update;
  SendFileAddCompletedSpaceHandle.Free;

  CompletedFileSend;
end;

procedure TSendTransferFileHandle.IniFileSend;
begin
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( UpFilePath, PcID );
end;

procedure TSendTransferFileHandle.AddPcUploadingFace;
var
  VstFileTransferDesAddUpload : TVstFileTransferDesAddUpload;
begin
    // 更新 File Transfer
  VstFileTransferDesAddUpload := TVstFileTransferDesAddUpload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesAddUpload );
end;

procedure TSendTransferFileHandle.RefreshLastLoadingFace;
var
  SendFileAddCompletedSpaceHandle : TSendFileAddCompletedSpaceHandle;
  SendFileChildAddCompletedSpaceHandle : TSendFileChildAddCompletedSpaceHandle;
begin
    // 刷新 文件节点
  SendFileChildAddCompletedSpaceHandle := TSendFileChildAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileChildAddCompletedSpaceHandle.SetFilePath( UpFilePath );
  SendFileChildAddCompletedSpaceHandle.SetCompletedSize( LoadingSize );
  SendFileChildAddCompletedSpaceHandle.Update;
  SendFileChildAddCompletedSpaceHandle.Free;

    // 刷新 目录节点
  SendFileAddCompletedSpaceHandle := TSendFileAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileAddCompletedSpaceHandle.SetCompletedSize( LoadingSize );
  SendFileAddCompletedSpaceHandle.Update;
  SendFileAddCompletedSpaceHandle.Free;
end;

procedure TSendTransferFileHandle.RemovePcUploadingFace;
var
  VstFileTransferDesRemoveUpload : TVstFileTransferDesRemoveUpload;
begin
    // 更新 File Transfer
  VstFileTransferDesRemoveUpload := TVstFileTransferDesRemoveUpload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesRemoveUpload );
end;

function TSendTransferFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MyFileSendInfoReadUtil.ReadIsEnable( RootSendPath, PcID );
end;

procedure TSendTransferFileHandle.CompletedFileSend;
var
  SendFileRemoveChildHandle : TSendFileRemoveChildHandle;
  SendFileCheckCompletedHandle : TSendFileCheckCompletedHandle;
begin
    // 删除 文件传输 节点
  SendFileRemoveChildHandle := TSendFileRemoveChildHandle.Create( RootSendPath, PcID );
  SendFileRemoveChildHandle.SetFilePath( UpFilePath );
  SendFileRemoveChildHandle.Update;
  SendFileRemoveChildHandle.Free;

    // 检查是否已经传输完成
  SendFileCheckCompletedHandle := TSendFileCheckCompletedHandle.Create( RootSendPath, PcID );
  SendFileCheckCompletedHandle.Update;
  SendFileCheckCompletedHandle.Free;
end;

procedure TSendTransferFileHandle.SendFileAfter;
begin
  inherited;

    // 刷新 空间信息
  RefreshLastLoadingFace;

  if TransResult = TransFile_OK then // 传输 成功
    CompletedFileSend
  else
  if TransResult = TransFile_LostCon then // 传输 断开
    AddFileSendOffline
  else
    SetFileSendStatusFace( TransResult );  // 传输 失败
end;

procedure TSendTransferFileHandle.SendFileBefore;
begin
  inherited;

  SetFileSendStatusFace( SendPathStatus_Sending );

  StartTimeLoading := Now;
  LoadingSize := 0;
end;

procedure TSendTransferFileHandle.AddFileSendOffline;
var
  SendFileOfflineHandle : TSendFileOfflineHandle;
begin
  SendFileOfflineHandle := TSendFileOfflineHandle.Create( RootSendPath, PcID );
  SendFileOfflineHandle.SetChildFilePath( UpFilePath );
  SendFileOfflineHandle.SetPostion( Position );
  SendFileOfflineHandle.SetFileInfo( FileSize, FileTime );
  SendFileOfflineHandle.Update;
  SendFileOfflineHandle.Free;
end;

procedure TSendTransferFileHandle.SetFileSendStatusFace(SendStatus: string);
var
  SendFileSetChildStatusHandle : TSendFileSetChildStatusHandle;
begin
  if SendStatus = TransFile_TransferCancel then // Cancel
    SendStatus := SendPathStatus_Cancel;

    // 修改 发送状态
  SendFileSetChildStatusHandle := TSendFileSetChildStatusHandle.Create( RootSendPath, PcID );
  SendFileSetChildStatusHandle.SetFilePath( UpFilePath );
  SendFileSetChildStatusHandle.SetSendFileStatus( SendStatus );
  SendFileSetChildStatusHandle.Update;
  SendFileSetChildStatusHandle.Free;
end;

procedure TSendTransferFileHandle.UpdateloadingFace(SendSize: Integer);
begin
  inherited;

  LoadingSize := LoadingSize + SendSize;
  if SecondsBetween( Now, StartTimeLoading ) < 1 then  // 1 秒更新一次
    Exit;

    // 刷新 已完成空间 信息
  RefreshLastLoadingFace;

  LoadingSize := 0;
  StartTimeLoading := Now;
end;

{ TUploadTransferFileHandle }

procedure TUploadTransferFileHandle.AddFileSendOffline;
var
  PcID, FilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  RootSendPath : string;
  SendFileOfflineHandle : TSendFileOfflineHandle;
begin
    // 提取 Job 信息
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( FilePath, PcID );

    // 添加 续传 FileSend Job
  SendFileOfflineHandle := TSendFileOfflineHandle.Create( RootSendPath, PcID );
  SendFileOfflineHandle.SetChildFilePath( FilePath );
  SendFileOfflineHandle.SetPostion( Position );
  SendFileOfflineHandle.SetFileInfo( FileSize, FileTime );
  SendFileOfflineHandle.Update;
  SendFileOfflineHandle.Free;
end;

procedure TUploadTransferFileHandle.ConnErrorHandle;
begin
  AddFileSendOffline;
end;

function TUploadTransferFileHandle.getJobIsContinues: Boolean;
var
  RootSendPath : string;
begin
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( TransferFileInfo.LoadPath, TransferFileInfo.PcID );
  Result := MyFileSendInfoReadUtil.ReadIsEnable( RootSendPath, TransferFileInfo.PcID );
  if not Result then
    RemoveRemoteDownPend;
end;

procedure TUploadTransferFileHandle.RemoveRemoteDownPend;
var
  PcRemoveDownPendFileMsg : TPcRemoveDownPendFileMsg;
begin
  PcRemoveDownPendFileMsg := TPcRemoveDownPendFileMsg.Create;
  PcRemoveDownPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveDownPendFileMsg.SetRemovePath( TransferFileInfo.LoadPath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveDownPendFileMsg );
end;

{ TSendShareFileHandle }

procedure TSendShareFileHandle.AddPcUploadingFace;
var
  VstShareFilePcAddUpload : TVstShareFilePcAddUpload;
begin
  VstShareFilePcAddUpload := TVstShareFilePcAddUpload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcAddUpload );
end;

function TSendShareFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MySharePathInfoReadUtil.ReadFileIsEnable( UpFilePath );
end;

procedure TSendShareFileHandle.RemovePcUploadingFace;
var
  VstShareFilePcRemoveUpload : TVstShareFilePcRemoveUpload;
begin
  VstShareFilePcRemoveUpload := TVstShareFilePcRemoveUpload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcRemoveUpload );
end;

{ TSendFileActivateHandle }

function TSendFileActivateHandle.CheckNextSend: Boolean;
begin
  Result := False;

    // 已经 发送失败
  if not inherited then
    Exit;

    // 取消 上传
  if not CheckUploadContinues then
  begin
    TransResult := ReadFile_UploadCancel;
    Exit;
  end;

  Result := True;
end;

end.
