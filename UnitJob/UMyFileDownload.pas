unit UMyFileDownload;

interface

uses UModelUtil, Sockets, UMyTcp, UMyFileTransfer, UMyUtil, Math, WinSock, Classes, SysUtils,
     DateUtils, SyncObjs, UMyJobInfo, uDebug, udebuglock;

type

{$Region ' 下载文件 ' }

    // 主动下载
  TDownFileHandle = class( TTransferFileConnHandle )
  protected
    function getTransferType : string;override;
  end;

    // 下载 源搜索文件
  TDownSerachSourceFileHandle = class( TDownFileHandle )
  protected
    procedure ConnErrorHandle;override;
    function getJobIsContinues : Boolean;override;
  private
    procedure AddToJob;
  end;

    // 下载 副本搜索文件
  TDownSerachBackupFileHandle = class( TDownFileHandle )
  protected
    procedure ConnErrorHandle;override;
    function getJobIsContinues : Boolean;override;
  private
    procedure AddToJob;
  end;

    // 下载 恢复文件
  TDownRestoreFileHandle = class( TDownFileHandle )
  protected
    procedure ConnErrorHandle;override;
    function getJobIsContinues : Boolean;override;
  private
    procedure AddToJob;
    procedure RemoveRemoteUpPend;
  end;

    // 下载 共享文件
  TDownShareFileHandle = class( TDownFileHandle )
  protected
    procedure ConnErrorHandle;override;
    function getJobIsContinues : Boolean;override;
    procedure AcceptCancelHandle;override;
  private
    procedure AddToJob;
    procedure RemoveRemoteUpPend;
  end;

    // 被动下载
  TAcceptDownFileHandle = class( TTransferFileAcceptHandle )
  protected
    function getTransferType : string;override;
  protected
    function getAcceptIsContinues : Boolean;override;
    function getBackupContinues : Boolean;
    function getReceiveContinues : Boolean;
  end;


{$EndRegion}

{$Region ' 接收文件 ' }

    // 更新 Loading 界面
  TDownloadingFaceThread = class( TThread )
  private
    PcID, DownFilePath : string;
    FileSize, Position : Int64;
  private
    Lock : TCriticalSection;
    LastFaceTime : TDateTime;
    SecondRevSize : Int64;
  public
    constructor Create( _FileSize, _Position : Int64 );
    procedure SetFileInfo( _PcID, _DownFilePath : string );
    procedure AddRevSize( RevSize : Integer );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure UpdateFace;
  end;

    // 接收文件处理
  TRevFileHandle = class( TTransferFile )
  private
    PcID, DownFilePath : string;
    Position, FileSize : Int64;
    FileTime : TDateTime;
    FileType : string;
    IsContinusFile : Boolean;
  private
    TcpSocket : TCustomIpClient;
    PendingJobInfo : TPendingJobInfo;
    DataBuf : TRevDataBuf;
    TransResult : string;
  private
    DownloadingFaceThread : TDownloadingFaceThread;
    StartRevTime : TDateTime;
    AllRevSize : Int64;
  private
    IsMD5Check : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );override;
    procedure SetTransferFileInfo( TransferFileInfo : TTransferFileInfo );override;
    procedure SetPendingJobInfo( _PendingJobInfo : TPendingJobInfo );override;
    procedure Update;override;
    destructor Destroy; override;
  private      // 可能 下载文件已经存在
    function DownFileCheck : string;
    procedure RevFileMD5Confirm;  // 接收文件 是否需要 MD5 验证
    procedure RevFile;
  private     // 接收文件 和 写文件
    function RevDataBuf : Boolean;
    function WriteDataBuf : string;
    function CheckMD5DataBuf : Boolean;
    function CheckWriteSpace : Boolean;
  private      // 界面更新
    procedure AddDownloadingFace;
    procedure UpdateLoadingFace( RevSize : Integer );virtual;
    procedure DeleteDownloadingFace;
    procedure AddDownloadedFace( IsDownExist : Boolean );
  protected
    procedure IniRevFile;virtual;
    function CheckDownloadContinues : Boolean;virtual;
    procedure HandleDataBuf;virtual;
    procedure DownFileExistHandle;virtual;
    procedure RevFileBefore;virtual;
    procedure RevFileAfter;virtual;
  protected       // 检查 文件接收
    function CheckNextRev: Boolean;virtual;
    procedure RevDataSleep( var StartTime : TDateTime; var RevCount : Integer );
    procedure AddPcDownLoadingFace;virtual;
    procedure RemovePcDownLoadingFace;virtual;
  end;

    // 被动 接收 备份文件
  TRevBackupFileHandle = class( TRevFileHandle )
  protected
    function CheckDownloadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure RevFileAfter;override;
  protected
    procedure AddPcDownLoadingFace;override;
    procedure RemovePcDownLoadingFace;override;
  private
    procedure RemoveBackupPendingSize;
    procedure AddCloudPathOwnerSpace;
    procedure DeleteCloudFile;
  end;

    // 被动 接收 传输文件
  TRevTransferFileHandle = class( TRevFileHandle )
  private
    SendFilePath : string;
    SendRootPath : string;
  protected
    procedure IniRevFile;override;
    function CheckDownloadContinues : Boolean;override;
  protected
    procedure AddPcDownLoadingFace;override;
    procedure RemovePcDownLoadingFace;override;
  end;

    // 主动接收文件 处理
  TRevFileActivateHandle = class( TRevFileHandle )
  protected
    function CheckNextRev: Boolean;override;
  end;

    // 接收 共享文件
  TRevShareFileHandle = class( TRevFileActivateHandle )
  private
    ShareParentPath : string;
    ShareFilePath : string;
    IsRootFile : Boolean;
  private
    StartUpdataFaceTime : TDateTime;
    LoadingSize : Integer;
    TotalRev : Int64;
  protected
    procedure IniRevFile;override;
    function CheckDownloadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure RevFileBefore;override;
    procedure RevFileAfter;override;
  protected
    procedure AddPcDownLoadingFace;override;
    procedure RemovePcDownLoadingFace;override;
  private
    procedure SetFileStatus( Status : string ); // 状态设置
    procedure UpdateLoadingFace( RevSize : Integer );override;
    procedure RefreshLastLoadingFace; // 刷新最后的 Loading 空间信息
  private
    procedure AddFileSendOffline;   // 添加 续传 Job
    procedure CompletedFileSend; // 传输文件 完成
    procedure ConfirmShareCancel; // 是否已经取消共享
  end;

    // 接收 下载文件
  TRevDownFileHandle = class( TRevFileActivateHandle )
  protected
    IsEncrypted : Boolean;
    Password : string;
  protected    // 解密
    procedure HandleDataBuf;override;
  end;

    // 接收 搜索下载文件  父类
  TRevSearchDownFileHandle = class( TRevDownFileHandle )
  private
    SourceFilePath : string;
    SourcePcID : string;
  private
    StartUpdataFaceTime : TDateTime;
    LoadingSize : Integer;
  protected
    procedure IniRevFile;override;
    function CheckDownloadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure RevFileBefore;override;
    procedure RevFileAfter;override;
  private
    procedure SetSearchDownStatus( Status : string );
    procedure UpdateLoadingFace( RevSize : Integer );override;
    procedure SetSerachDownPosition;
  protected
    procedure AddSearchDownOffline;virtual;
  end;

    // 接收 搜索下载文件 源文件
  TRevSearchDownSourceFileHandle = class( TRevSearchDownFileHandle )
  protected
    procedure IniRevFile;override;
  protected
    procedure AddSearchDownOffline;override;
  end;

    // 接收 搜索下载文件 备份文件
  TRevSearchDownBackupFileHandle = class( TRevSearchDownFileHandle )
  protected
    procedure IniRevFile;override;
  protected
    procedure AddSearchDownOffline;override;
  end;

    // 接收 恢复文件
  TRevRestoreFileHandle = class( TRevDownFileHandle )
  private
    RestoreItemPath : string;
    RestoreFilePath : string;
    RestorePcID : string;
  private
    StartUpdataFaceTime : TDateTime;
    LoadingSize : Integer;
  protected
    procedure IniRevFile;override;
    function CheckDownloadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure RevFileBefore;override;
    procedure RevFileAfter;override;
  private
    procedure SetRestoreFileStatusFace( Status : string );
    procedure UpdateLoadingFace( RevSize : Integer );override;
    procedure RefreshLoadingSpace;
  private
    procedure AddRestoreOffline;
    procedure RestoreFileCompleted;
  end;

{$EndRegion}

    // 下载文件 控制器
  TMyFileDownload = class( TMyFileTransfer )
  public
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
  protected
    function CreateThread : TTransferHandleThread;override;
  end;

var
  MyFileDownload : TMyFileDownload;

implementation

uses UMyNetPcInfo, UJobFace, UMyCloudFileControl, UNetworkFace, USettingInfo,
     USearchFileFace, UMySearchDownXml, UMySearchDownInfo, URestoreFileFace, UMyCloudPathInfo,
     UMyRestoreFileInfo, UMyRestoreFileXml, UFileTransferFace, UMyShareControl, UMyShareInfo, UJobControl,
     UMyShareFace, UMyRestoreFileControl, UMyFileTransferInfo, UFileSearchControl, UMyClient, UChangeInfo,
     UNetworkControl;


{ TRevFile }

procedure TRevFileHandle.AddDownloadedFace( IsDownExist : Boolean );
var
  PcName, RootID : string;
  UsedTime : Integer;
  TotalSpeed : Int64;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  VirTransferChildLoadedInfo : TVirTransferChildLoadedInfo;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // Cancel
  if DownFilePath = '' then
    Exit;

      // 不显示 Lost Conn
  if TransResult = TransFile_LostCon then
    Exit;

  if IsDownExist or ( TransResult = TransFile_OK ) then
    RootID := RootID_DownLoaded
  else
    RootID := RootID_DownError;

    // 添加 Loaded
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, DownFilePath );
  VirTransferChildAddInfo.SetFileBase( DownFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, TransResult );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );
  MyJobFace.AddChange( VirTransferChildAddInfo );

    // 修改 Loaded
  if IsDownExist then
  begin
    UsedTime := 0;
    TotalSpeed := 0;
  end
  else
  begin
    UsedTime := Max( SecondsBetween( Now, StartRevTime ), 1 );
    TotalSpeed := AllRevSize div UsedTime;
  end;

    // 修改 Loaded 信息
  VirTransferChildLoadedInfo := TVirTransferChildLoadedInfo.Create( RootID );
  VirTransferChildLoadedInfo.SetChildID( PcID, DownFilePath );
  VirTransferChildLoadedInfo.SetTimeInfo( UsedTime, TotalSpeed );
  MyJobFace.AddChange( VirTransferChildLoadedInfo );

    // 错误 跳过
  if RootID = RootID_DownError then
    Exit;

    // 删除存在的 Error
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_DownError );
  VirTransferChildRemoveInfo.SetChildID( PcID, DownFilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TRevFileHandle.AddDownloadingFace;
var
  PcName : string;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
    // 添加 Loading
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_DownLoading );
  VirTransferChildAddInfo.SetChildID( PcID, DownFilePath );
  VirTransferChildAddInfo.SetFileBase( DownFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, FileStatus_Loading );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );

  MyJobFace.AddChange( VirTransferChildAddInfo );

    // 定期更新 Loading 界面
  DownloadingFaceThread := TDownloadingFaceThread.Create( FileSize, Position );
  DownloadingFaceThread.SetFileInfo( PcID, DownFilePath );
  DownloadingFaceThread.Resume;

    // Loaded 信息
  StartRevTime := Now;
  AllRevSize := 0;

    // Pc 位置显示正在下载
  AddPcDownLoadingFace;
end;



procedure TRevFileHandle.AddPcDownLoadingFace;
begin
end;

function TRevFileHandle.CheckMD5DataBuf: Boolean;
var
  SendMD5Str, RevMD5Str : string;
begin
  Result := True;
  if not IsMD5Check then
    Exit;

    // 检测 MD5
  SendMD5Str := MySocketUtil.RevData( TcpSocket );
  RevMD5Str := TransferUtil.getMD5Buffer( DataBuf.HardBuf, DataBuf.BufSize );
  Result := SendMD5Str = RevMD5Str;

    // 发送 返回结果
  MySocketUtil.SendString( TcpSocket, BoolToStr( Result ) );
end;

function TRevFileHandle.CheckNextRev: Boolean;
var
  ThreadStatus : string;
begin
    // 获取 下载线程 状态
  ThreadStatus := MyFileDownload.getThreadStatus;

      // 被删除 或 程序结束
  Result := False;
  if ThreadStatus = ThreadStatus_Stop then
    TransResult := TransFile_LostCon
  else
    Result := True;
end;

function TRevFileHandle.CheckDownloadContinues: Boolean;
begin
  Result := True;
end;

constructor TRevFileHandle.Create;
begin
  DataBuf := TRevDataBuf.Create;
  IsContinusFile := False;
  IsMD5Check := False;
end;

procedure TRevFileHandle.DeleteDownloadingFace;
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // 停止界面更新
  DownloadingFaceThread.Free;

    // 删除 Loading
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_DownLoading );
  VirTransferChildRemoveInfo.SetChildID( PcID, DownFilePath );

  MyJobFace.AddChange( VirTransferChildRemoveInfo );

    // Pc 位置显示正在下载
  RemovePcDownLoadingFace;
end;

destructor TRevFileHandle.Destroy;
begin
  DataBuf.Free;
  inherited;
end;

procedure TRevFileHandle.DownFileExistHandle;
begin

end;

function TRevFileHandle.DownFileCheck: string;
var
  FileExistMsg : string;
  f : Integer;
  OldFileSize : Int64;
  OldFileTime : TDateTime;
begin
  FileExistMsg := WriteFile_OK;

    // 存在文件
  if FileExists( DownFilePath ) then
  begin
      // 获取 以前文件的信息
    OldFileSize := MyFileInfo.getFileSize( DownFilePath );
    OldFileTime := MyFileInfo.getFileLastWriteTime( DownFilePath );

      // 续传
    if IsContinusFile then
      Position := OldFileSize
    else   // 文件已存在
    if ( OldFileSize = FileSize ) and
        MyDatetime.Equals( OldFileTime, FileTime )
    then
      FileExistMsg := WriteFile_Exist
    else   // 存在一个与要求下载不同的文件
    if FileType = FileType_Backup then
      DeleteFile( DownFilePath )
    else
      MyRename.RenameExist( DownFilePath );
  end;

    // 创建文件
  if not FileExists( DownFilePath ) then
  begin
      // 创建 父目录
    if MyCreateFolder.IsCreate( DownFilePath ) then
    begin
      f := FileCreate( DownFilePath );
      FileClose(f);
    end;
  end;


    // 文件不存在 且 空间不足
  if ( FileExistMsg <> WriteFile_Exist ) and not CheckWriteSpace then
    FileExistMsg := WriteFile_SpaceLack;

      // 取消发送
  if DownFilePath = '' then
    FileExistMsg := TransFile_TransferCancel;

    // 发送文件 状态
  MySocketUtil.SendString( TcpSocket, FileExistMsg );

    // 续传
  if IsContinusFile then
    MySocketUtil.SendString( TcpSocket, IntToStr( Position ) );

  Result := FileExistMsg;
end;

procedure TRevFileHandle.HandleDataBuf;
begin

end;

procedure TRevFileHandle.IniRevFile;
begin

end;

procedure TRevFileHandle.RemovePcDownLoadingFace;
begin
end;

function TRevFileHandle.RevDataBuf: Boolean;
var
  RemainSize : Int64;
  Buf : TTransferBuf;
  BufSize, RevSize, RevCount, CoutSize : Integer;
  RevStartTime : TDateTime;
begin
  Result := True;

  RemainSize := FileSize - Position; // 计算剩余 接收文件空间

  DataBuf.ClearWriteData; // 清空上一次的数据

    // 达到接收块数目要求
    // 文件已经全部接收完毕
  RevCount := 0;
  CoutSize := 0;
  RevStartTime := Now;
  while RemainSize > 0 do
  begin
      // 检测是否 继续接收
    if not CheckNextRev then
    begin
      TcpSocket.Disconnect;
      Result := False;
      Break;
    end;

      // 接收 1K 数据
    BufSize := Min( Size_TransferBuf, RemainSize );  // 接收缓冲区空间
    RevSize := MySocketUtil.RevBuf( TcpSocket, Buf, BufSize ); // 接收文件块
    if RevSize = SOCKET_ERROR then // 对方断开了连接
    begin
      TransResult := TransFile_LostCon;
      Result := False;
      Break;
    end;

      // 统计接收数据
    RemainSize := RemainSize - RevSize;
    UpdateLoadingFace( RevSize );

      // 添加到缓冲区, 缓冲区满, 返回 False
    if not DataBuf.AddRevBuf( Buf, RevSize ) then
      Break;

      // 控制速率
    CoutSize := CoutSize + RevSize;
    if CoutSize >= Size_TransferBuf then
    begin
      Inc( RevCount );
      CoutSize := CoutSize - Size_TransferBuf;
    end;
    RevDataSleep( RevStartTime, RevCount );
  end;

    // MD5 错误, 重新接收文件
  if Result and not CheckMD5DataBuf then
  begin
    UpdateLoadingFace( -DataBuf.BufSize );
    Result := RevDataBuf;
  end;
end;

function TRevFileHandle.WriteDataBuf: string;
var
  FileStream : TFileStream;
  WriteSize : Integer;
begin
    // 下载取消
  if not CheckDownloadContinues then
  begin
    Result := WriteFile_DownloadCancel;
    Exit;
  end;

    // 下载文件 不存在
  if ( Position <> 0 ) and not FileExists( DownFilePath ) then
  begin
    Result := WriteFile_FileNotExit;
    Exit;
  end;

    // 下载文件 发生变化
  if MyFileInfo.getFileSize( DownFilePath ) <> Position then
  begin
    Result := WriteFile_FileChange;
    Exit;
  end;

    // 创建目录失败
  if not MyCreateFolder.IsCreate( DownFilePath ) then
  begin
    Sleep(100);
    if not DirectoryExists( ExtractFileDir( DownFilePath ) ) then
    begin
      Result := WriteFile_CreateFolderError;
      Exit;
    end;
  end;

    // 没有足够的空间下载文件
  if not CheckWriteSpace then
  begin
    Result := WriteFile_SpaceLack;
    Exit;
  end;

    // 写磁盘文件
  try
    if not FileExists( DownFilePath ) then
      FileStream := TFileStream.Create( DownFilePath, fmCreate or fmShareDenyNone )
    else
      FileStream := TFileStream.Create( DownFilePath, fmOpenWrite or fmShareDenyNone );
    FileStream.Position := Position;
    WriteSize := FileStream.Write( DataBuf.HardBuf, DataBuf.BufSize );
    FileStream.Free;
  except
    Result := WriteFile_WriteError;
    Exit;
  end;

    // 写文件出错
  if WriteSize <> DataBuf.BufSize then
  begin
    Result := WriteFile_WriteError;
    DebugLog( IntToStr( WriteSize ) + '   ' + IntToStr( DataBuf.BufSize )  );
    Exit;
  end;

    // 文件位置
  Position := Position + WriteSize;
  Result := WriteFile_OK;
end;

procedure TRevFileHandle.RevFile;
var
  ReadBufResult, WriteBufResult : string;
begin
  TransResult := TransFile_OK;
  while FileSize > Position do
  begin
      // 接收 读取磁盘 结果
    ReadBufResult := MySocketUtil.RevData( TcpSocket );

      // 读取磁盘失败 或 断开连接
    if ReadBufResult <> ReadFile_OK then
    begin
      if ReadBufResult = '' then
        TransResult := TransFile_LostCon
      else
        TransResult := ReadBufResult;
      Break;
    end;

      // 接收文件块时，对方可能断开了连接
    if not RevDataBuf then
      Break;

      // 写文件前处理
    HandleDataBuf;

      // 写文件块
    WriteBufResult := WriteDataBuf;

      // 发送写文件块结果, 对方断开连接
    if MySocketUtil.SendString( TcpSocket, WriteBufResult ) = SOCKET_ERROR then
    begin
      TransResult := TransFile_LostCon;
      Break;
    end;

      // 写入文件失败
    if WriteBufResult <> WriteFile_OK then
    begin
      TransResult := WriteBufResult;
      Break;
    end;
  end;

    // 修改文件时间
  if TransResult = TransFile_OK then
    MyFileSetTime.SetTime( DownFilePath, FileTime );
end;

procedure TRevFileHandle.RevFileAfter;
begin

end;

procedure TRevFileHandle.RevFileBefore;
begin

end;

procedure TRevFileHandle.RevFileMD5Confirm;
var
  IsMD5Activate : Boolean;
begin
    // 是否 MD5 主动方
  IsMD5Activate := not TransferUtil.getIsSendMD5Activate( FileType );

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

procedure TRevFileHandle.RevDataSleep(var StartTime: TDateTime;
  var RevCount : Integer);
var
  DownloadSpeed : Integer;
  RevMiSeconds, SleepTime : Int64;
begin
    // 读取 Setting 设置的速度
  DownloadSpeed := TransferSettingInfo.DownloadSpeed;
  if DownloadSpeed = TransferSpeed_Fast then
  begin
    if RevCount = Count_HandleSleep then
    begin
      RevCount := 0;
      SleepTime := 1;
    end
    else
      SleepTime := 0
  end
  else
  begin
    RevMiSeconds := MilliSecondsBetween( Now, StartTime );
    if RevMiSeconds = 0 then // 未够 1秒
      Exit;

    if DownloadSpeed = TransferSpeed_Normal then
      SleepTime := RevMiSeconds
    else
      SleepTime := RevMiSeconds * 9;
  end;

    // 最大 1 秒
  SleepTime := Min( SleepTime, 1000 );

    // 等待
  while ( SleepTime > 0 ) and CheckNextRev do
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

procedure TRevFileHandle.SetPendingJobInfo(_PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

procedure TRevFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TRevFileHandle.SetTransferFileInfo(
  TransferFileInfo: TTransferFileInfo);
begin
  PcID := TransferFileInfo.PcID;
  DownFilePath := TransferFileInfo.LoadPath;
  Position := TransferFileInfo.Position;
  FileSize := TransferFileInfo.FileSize;
  FileTime := TransferFileInfo.FileTime;
  FileType := TransferFileInfo.FileType;
  IsContinusFile := Position > 0;
end;

procedure TRevFileHandle.Update;
var
  DownFileCheckResult : string;
begin
  IniRevFile; // 初始化接收文件

    // 检查 下载的文件状态
  DownFileCheckResult := DownFileCheck;

    // 下载的文件已存在 则 不用接收文件
  if DownFileCheckResult = WriteFile_Exist then
  begin
    TransResult := WriteFile_Exist;
    Position := FileSize;
    AddDownloadedFace( True );

    DownFileExistHandle;
  end
  else    // 开始接收文件
  begin
    RevFileMD5Confirm; // 是否 MD5 检测

    RevFileBefore;

    AddDownloadingFace;
    if DownFileCheckResult = WriteFile_OK then
      RevFile
    else
      TransResult := DownFileCheckResult;
    DeleteDownloadingFace;
    AddDownloadedFace( False );

    RevFileAfter;
  end;
end;

procedure TRevFileHandle.UpdateLoadingFace(RevSize: Integer);
begin
    // Loading
  DownloadingFaceThread.AddRevSize( RevSize );

    // Loaded
  AllRevSize := AllRevSize + RevSize;

    // 主窗口 界面
  TransferSpeedFaceThread.AddDownloadSpeed( RevSize );
end;

function TRevFileHandle.CheckWriteSpace: Boolean;
var
  RemainSpace, RemainSize : Int64;
begin
  RemainSpace := MyHardDisk.getHardDiskFreeSize( DownFilePath );
  RemainSize := FileSize - Position;
  Result := RemainSpace >= RemainSize;
end;

{ TUploadingFaceThread }

procedure TDownloadingFaceThread.AddRevSize(RevSize: Integer);
begin
  Lock.Enter;
  SecondRevSize := SecondRevSize + RevSize;
  Lock.Leave;
end;

constructor TDownloadingFaceThread.Create(_FileSize, _Position: Int64);
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;

  FileSize := _FileSize;
  Position := _Position;
  LastFaceTime := Now;
  SecondRevSize := 0;
end;

destructor TDownloadingFaceThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  Lock.Free;
  inherited;
end;

procedure TDownloadingFaceThread.Execute;
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

procedure TDownloadingFaceThread.SetFileInfo(_PcID, _DownFilePath: string);
begin
  PcID := _PcID;
  DownFilePath := _DownFilePath;
end;

procedure TDownloadingFaceThread.UpdateFace;
var
  TempSecondRevSize : Int64;
  RemainTime : Integer;
  VirTransferChildLoadingInfo : TVirTransferChildLoadingInfo;
begin
  Lock.Enter;
  TempSecondRevSize := SecondRevSize;
  SecondRevSize := 0;
  LastFaceTime := Now;
  Lock.Leave;

  Position := Position + TempSecondRevSize;
  if TempSecondRevSize < 1 then
    RemainTime := MyTime.getMaxTime
  else
    RemainTime := ( FileSize - Position ) div TempSecondRevSize;

  VirTransferChildLoadingInfo := TVirTransferChildLoadingInfo.Create( RootID_DownLoading );
  VirTransferChildLoadingInfo.SetChildID( PcID, DownFilePath );
  VirTransferChildLoadingInfo.SetPercentage( Position, FileSize );
  VirTransferChildLoadingInfo.SetTimeInfo( TempSecondRevSize, RemainTime );

  MyJobFace.AddChange( VirTransferChildLoadingInfo );
end;

{ TDownFileHandle }

function TDownFileHandle.getTransferType: string;
begin
  Result := TransferType_Download;
end;


{ TAcceptDownFileHandle }

function TAcceptDownFileHandle.getAcceptIsContinues: Boolean;
var
  FileType : string;
begin
  FileType := TransferFileInfo.FileType;
  if FileType = FileType_Backup then
    Result := getBackupContinues
  else
  if FileType = FileType_Transfer then
    Result := getReceiveContinues
  else
    Result := True;
end;

function TAcceptDownFileHandle.getBackupContinues: Boolean;
var
  FileRemainSize : Int64;
begin
  FileRemainSize := PendingJobInfo.FileSize - PendingJobInfo.Position;
  Result := ShareSettingInfo.getHardDiskAvailableSpace >= FileRemainSize;
end;

function TAcceptDownFileHandle.getReceiveContinues: Boolean;
var
  FileSendJobInfo : TFileSendJobInfo;
  SendRootPath, DesPcID : string;
begin
  FileSendJobInfo := PendingJobInfo as TFileSendJobInfo;
  DesPcID := TransferFileInfo.PcID;
  SendRootPath := MyFileReceiveInfoReadUtil.ReadRootSendPath( FileSendJobInfo.UploadPath, DesPcID );
  Result := MyFileReceiveInfoReadUtil.ReadIsExist( SendRootPath, DesPcID );
end;

function TAcceptDownFileHandle.getTransferType: string;
begin
  Result := TransferType_Download;
end;

{ TMyFileDownload }

procedure TMyFileDownload.AcceptSocket(TcpSocket: TCustomIpClient);
var
  IsAcceptJob : Boolean;
  AcceptJobInfo : TAcceptJobInfo;
  JobAddInfo : TJobAddInfo;
  DownloadJobChangeInfo : TDownloadJobChangeInfo;
begin
    // 是否繁忙
  MyJobInfo.EnterData;
  IsAcceptJob := MyJobInfo.DownloadJobInfo.CheckAcceptJob;
  MyJobInfo.LeaveData;

    // 不繁忙则 接 Job
  if IsAcceptJob then
  begin
    AcceptJobInfo := TAcceptJobInfo.Create;
    AcceptJobInfo.SetTcpSocket( TcpSocket );

    JobAddInfo := TJobAddInfo.Create;
    JobAddInfo.SetJobInfo( AcceptJobInfo );

    DownloadJobChangeInfo := TDownloadJobChangeInfo.Create;
    DownloadJobChangeInfo.SetJobWriteInfo( JobAddInfo );

    MyJobInfo.AddChange( DownloadJobChangeInfo );
  end
  else
    TcpSocket.Free;
end;


function TMyFileDownload.CreateThread: TTransferHandleThread;
begin
  Result := TDownloadHandleThread.Create;
end;

{ TRevBackupFileHandle }

procedure TRevBackupFileHandle.AddPcDownLoadingFace;
var
  NetworkLvAddDownload : TLvNetworkAddDownload;
begin
    // 添加到 文件备份 界面
  NetworkLvAddDownload := TLvNetworkAddDownload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvAddDownload );
end;

function TRevBackupFileHandle.CheckDownloadContinues: Boolean;
var
  HardDiskAvailableSpace, RemainSize : Int64;
begin
  Result := False;
  if not ShareSettingInfo.IsShare then // 不共享路径
    Exit;

    // 备份文件的剩余空间
  RemainSize := FileSize - Position;

    // 云目录可用空间
  HardDiskAvailableSpace := ShareSettingInfo.getHardDiskAvailableSpace;

    // 返回 是否 有足够的空间
  Result := HardDiskAvailableSpace >= RemainSize;
end;

procedure TRevBackupFileHandle.DownFileExistHandle;
begin
    // 删除 预约空间
  RemoveBackupPendingSize;

    // 添加 备份路径拥有者 空间
  AddCloudPathOwnerSpace;
end;

procedure TRevBackupFileHandle.RemoveBackupPendingSize;
var
  NetPcAddPendingSpaceHandle : TNetPcAddPendingSpaceHandle;
begin
  if IsContinusFile then
    Exit;

  NetPcAddPendingSpaceHandle := TNetPcAddPendingSpaceHandle.Create( PcID );
  NetPcAddPendingSpaceHandle.SetBackupPendingSpace( - FileSize );
  NetPcAddPendingSpaceHandle.Update;
  NetPcAddPendingSpaceHandle.Free;
end;

procedure TRevBackupFileHandle.RemovePcDownLoadingFace;
var
  NetworkLvRemoveDownload : TLvNetworkRemoveDownload;
begin
     // 删除 备份文件 Pc 界面
  NetworkLvRemoveDownload := TLvNetworkRemoveDownload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvRemoveDownload );
end;

procedure TRevBackupFileHandle.DeleteCloudFile;
begin
    // 移除磁盘文件
  MyFolderDelete.FileDelete( DownFilePath );
end;

procedure TRevBackupFileHandle.RevFileAfter;
begin
    // 删除 预约空间
  RemoveBackupPendingSize;

    // 传输结果
  if TransResult = TransFile_OK then // 传输成功
    AddCloudPathOwnerSpace
  else
  if TransResult <> TransFile_LostCon then // 传输失败
    DeleteCloudFile;
end;

procedure TRevBackupFileHandle.AddCloudPathOwnerSpace;
var
  CloudPath : string;
  CloudPathPcFolderSpaceAddHandle : TCloudPathOwnerSpaceAddHandle;
begin
    // 获取 云路径
  CloudPath := MyCloudPathInfoUtil.ReadCloudFileRootPath( DownFilePath );

    // 云路径 不存在
  if CloudPath = '' then
    Exit;

    // 添加 Pc 占用空间信息
  CloudPathPcFolderSpaceAddHandle := TCloudPathOwnerSpaceAddHandle.Create( CloudPath );
  CloudPathPcFolderSpaceAddHandle.SetOwnerPcID( PcID );
  CloudPathPcFolderSpaceAddHandle.SetSpaceInfo( FileSize, 1 );
  CloudPathPcFolderSpaceAddHandle.Update;
  CloudPathPcFolderSpaceAddHandle.Free;
end;

{ TRevSearchDownFileHandle }

procedure TRevSearchDownFileHandle.AddSearchDownOffline;
begin

end;

function TRevSearchDownFileHandle.CheckDownloadContinues: Boolean;
begin
  Result := MySearchDownReadInfoUtil.ReadIsEnable( SourcePcID, SourceFilePath );
end;

procedure TRevSearchDownFileHandle.DownFileExistHandle;
begin
    // 传输完成后设置信息
  SetSearchDownStatus( DownSearchStatus_Loaded );
  SetSerachDownPosition;
end;

procedure TRevSearchDownFileHandle.IniRevFile;
begin
  StartUpdataFaceTime := Now;
  LoadingSize := 0;
end;

procedure TRevSearchDownFileHandle.RevFileAfter;
var
  DownSearchStatus : string;
begin
    // 接收 成功
  if TransResult = TransFile_OK then
    DownSearchStatus := DownSearchStatus_Loaded
  else    // 离线
  if TransResult = TransFile_LostCon then
  begin
    AddSearchDownOffline;
    DownSearchStatus := DownSearchStatus_Offline;
  end
  else   // 接收失败
    DownSearchStatus := TransResult;

    // 传输完成后设置信息
  SetSearchDownStatus( DownSearchStatus );
  SetSerachDownPosition;
end;

procedure TRevSearchDownFileHandle.RevFileBefore;
begin
  Password := MySearchDownReadInfoUtil.ReadPassword( SourcePcID, SourceFilePath );
  IsEncrypted := Password <> '';

    // 界面显示 Loading
  SetSearchDownStatus( DownSearchStatus_Loading );
end;

procedure TRevSearchDownFileHandle.SetSearchDownStatus(Status: string);
var
  DownSearchFileSetStatusHandle : TDownSearchFileSetStatusHandle;
begin
  DownSearchFileSetStatusHandle := TDownSearchFileSetStatusHandle.Create( SourceFilePath, SourcePcID );
  DownSearchFileSetStatusHandle.SetStatus( Status );
  DownSearchFileSetStatusHandle.Update;
  DownSearchFileSetStatusHandle.Free;
end;

procedure TRevSearchDownFileHandle.SetSerachDownPosition;
var
  DownSearchSetCompletedSpaceHandle : TDownSearchSetCompletedSpaceHandle;
begin
  DownSearchSetCompletedSpaceHandle := TDownSearchSetCompletedSpaceHandle.Create( SourceFilePath, SourcePcID );
  DownSearchSetCompletedSpaceHandle.SetCompletedSize( Position );
  DownSearchSetCompletedSpaceHandle.Update;
  DownSearchSetCompletedSpaceHandle.Free;
end;

procedure TRevSearchDownFileHandle.UpdateLoadingFace(RevSize: Integer);
var
  DownSearchFileAddCompletedHandle : TDownSearchFileAddCompletedHandle;
begin
  inherited;

  LoadingSize := LoadingSize + RevSize;

  if SecondsBetween( Now, StartUpdataFaceTime ) < 1 then
    Exit;

  DownSearchFileAddCompletedHandle := TDownSearchFileAddCompletedHandle.Create( SourceFilePath, SourcePcID );
  DownSearchFileAddCompletedHandle.SetCompletedSize( LoadingSize );
  DownSearchFileAddCompletedHandle.Update;
  DownSearchFileAddCompletedHandle.Free;

  LoadingSize := 0;
  StartUpdataFaceTime := Now;
end;

{ TRevRestoreFileHandle }

function TRevRestoreFileHandle.CheckDownloadContinues: Boolean;
begin
  Result := MyRestoreInfoReadUtil.ReadIsEnable( RestoreItemPath, RestorePcID );
end;

procedure TRevRestoreFileHandle.DownFileExistHandle;
var
  RestoreItemAddCompletedSpaceHandle : TRestoreItemAddCompletedSpaceHandle;
begin
    // 添加 根路径 已完成空间
  RestoreItemAddCompletedSpaceHandle := TRestoreItemAddCompletedSpaceHandle.Create( RestoreItemPath, RestorePcID );
  RestoreItemAddCompletedSpaceHandle.SetCompletedSpace( FileSize );
  RestoreItemAddCompletedSpaceHandle.Update;
  RestoreItemAddCompletedSpaceHandle.Free;

  RestoreFileCompleted;
end;

procedure TRevRestoreFileHandle.IniRevFile;
begin
  inherited;

  if PendingJobInfo is TRestoreJobInfo then
  begin
    RestoreFilePath := ( PendingJobInfo as TRestoreJobInfo ).FilePath;
    RestorePcID := ( PendingJobInfo as TRestoreJobInfo ).BackupFilePcID;
    RestoreItemPath := MyRestoreInfoReadUtil.ReadRootPath( RestoreFilePath, RestorePcID );
  end;

  LoadingSize := 0;
  StartUpdataFaceTime := Now;
end;

procedure TRevRestoreFileHandle.RefreshLoadingSpace;
var
  RestoreFileAddCompletedSpaceHandle : TRestoreFileAddCompletedSpaceHandle;
  RestoreItemAddCompletedSpaceHandle : TRestoreItemAddCompletedSpaceHandle;
begin
    // 添加 文件 已完成空间
  RestoreFileAddCompletedSpaceHandle := TRestoreFileAddCompletedSpaceHandle.Create( RestoreFilePath, RestorePcID );
  RestoreFileAddCompletedSpaceHandle.SetCompletedSpace( LoadingSize );
  RestoreFileAddCompletedSpaceHandle.Update;
  RestoreFileAddCompletedSpaceHandle.Free;

    // 添加 根路径 已完成空间
  RestoreItemAddCompletedSpaceHandle := TRestoreItemAddCompletedSpaceHandle.Create( RestoreItemPath, RestorePcID );
  RestoreItemAddCompletedSpaceHandle.SetCompletedSpace( LoadingSize );
  RestoreItemAddCompletedSpaceHandle.Update;
  RestoreItemAddCompletedSpaceHandle.Free;
end;

procedure TRevRestoreFileHandle.RestoreFileCompleted;
var
  RestoreFileRemoveHandle : TRestoreFileRemoveHandle;
begin
    // 删除 文件信息
  RestoreFileRemoveHandle := TRestoreFileRemoveHandle.Create( RestoreFilePath, RestorePcID );
  RestoreFileRemoveHandle.Update;
  RestoreFileRemoveHandle.Free;
end;

procedure TRevRestoreFileHandle.RevFileAfter;
begin
    // 刷新 空间信息
  RefreshLoadingSpace;

    // 接收 成功
  if TransResult = TransFile_OK then
    RestoreFileCompleted
  else    // 离线
  if TransResult = TransFile_LostCon then
    AddRestoreOffline
  else   // 接收失败
    SetRestoreFileStatusFace( TransResult );
end;

procedure TRevRestoreFileHandle.RevFileBefore;
begin
  Password := MyRestoreInfoReadUtil.ReadPassword( RestoreItemPath, RestorePcID );
  IsEncrypted := Password <> '';

  SetRestoreFileStatusFace( RestoreStatus_Loading );
end;

procedure TRevRestoreFileHandle.AddRestoreOffline;
var
  RestoreFileSetPositionHandle : TRestoreFileSetPositionHandle;
  TransferRestoreJobAddHandle : TTransferRestoreJobAddHandle;
begin
    // 离线设置
  SetRestoreFileStatusFace( RestoreStatus_Waiting );

    // 设置 Restore File 续传位置
  RestoreFileSetPositionHandle := TRestoreFileSetPositionHandle.Create( RestoreFilePath, RestorePcID );
  RestoreFileSetPositionHandle.SetPosition( Position );
  RestoreFileSetPositionHandle.Update;
  RestoreFileSetPositionHandle.Free;

    // 添加到 Job
  TransferRestoreJobAddHandle := TTransferRestoreJobAddHandle.Create( RestoreFilePath, PcID );
  TransferRestoreJobAddHandle.SetRestorePcID( RestorePcID );
  TransferRestoreJobAddHandle.SetDownFilePath( DownFilePath );
  TransferRestoreJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferRestoreJobAddHandle.Update;
  TransferRestoreJobAddHandle.Free;
end;

procedure TRevRestoreFileHandle.SetRestoreFileStatusFace(Status: string);
var
  RestoreFileSetStatusHandle : TRestoreFileSetStatusHandle;
begin
  RestoreFileSetStatusHandle := TRestoreFileSetStatusHandle.Create( RestoreFilePath, RestorePcID );
  RestoreFileSetStatusHandle.SetStatus( Status );
  RestoreFileSetStatusHandle.Update;
  RestoreFileSetStatusHandle.Free;
end;

procedure TRevRestoreFileHandle.UpdateLoadingFace(RevSize: Integer);
begin
  inherited;

  LoadingSize := LoadingSize + RevSize;

  if SecondsBetween( Now, StartUpdataFaceTime ) < 1 then
    Exit;

    // 刷新已完成空间信息
  RefreshLoadingSpace;

  StartUpdataFaceTime := Now;
  LoadingSize := 0;
end;

{ TRevDownFileHandle }

procedure TRevDownFileHandle.HandleDataBuf;
begin
  if IsEncrypted then
    DataBufUtil.DecryptRevBuf( DataBuf, Password );
end;

{ TRevShareFileHandle }

procedure TRevShareFileHandle.AddFileSendOffline;
var
  ShareFileDownChildSetCompletedSizeHandle : TShareFileDownChildSetCompletedSizeHandle;
  TransferShareJobAddHandle : TTransferShareJobAddHandle;
begin
    // 设置 子节点 续传位置
  ShareFileDownChildSetCompletedSizeHandle := TShareFileDownChildSetCompletedSizeHandle.Create( PcID, ShareParentPath );
  ShareFileDownChildSetCompletedSizeHandle.SetFilePath( ShareFilePath );
  ShareFileDownChildSetCompletedSizeHandle.SetCompletedSize( Position );
  ShareFileDownChildSetCompletedSizeHandle.Update;
  ShareFileDownChildSetCompletedSizeHandle.Free;

    // Waiting 状态
  SetFileStatus( FileShareStatus_Waiting );

    // 重返 Job 列表
  TransferShareJobAddHandle := TTransferShareJobAddHandle.Create( ShareFilePath, PcID );
  TransferShareJobAddHandle.SetDownFilePath( DownFilePath );
  TransferShareJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferShareJobAddHandle.Update;
  TransferShareJobAddHandle.Free;
end;

procedure TRevShareFileHandle.AddPcDownLoadingFace;
var
  VstShareFilePcAddDownload : TVstShareFilePcAddDownload;
begin
  VstShareFilePcAddDownload := TVstShareFilePcAddDownload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcAddDownload );
end;

function TRevShareFileHandle.CheckDownloadContinues: Boolean;
begin
  Result := MyShareDownInfoReadUtil.ReadIsEnable( PcID, ShareParentPath );
end;

procedure TRevShareFileHandle.CompletedFileSend;
var
  ShareFileDownChildRemoveHandle : TShareFileDownChildRemoveHandle;
begin
    // 删除 子节点
  ShareFileDownChildRemoveHandle := TShareFileDownChildRemoveHandle.Create( PcID, ShareParentPath );
  ShareFileDownChildRemoveHandle.SetFilePath( ShareFilePath );
  ShareFileDownChildRemoveHandle.Update;
  ShareFileDownChildRemoveHandle.Free;
end;

procedure TRevShareFileHandle.ConfirmShareCancel;
var
  ShareFileDownConfirmCancelHandle : TShareFileDownConfirmCancelHandle;
begin
    // 本地取消接收
  if not MyShareDownInfoReadUtil.ReadIsEnable( PcID, ShareParentPath )  then
    Exit;

  ShareFileDownConfirmCancelHandle := TShareFileDownConfirmCancelHandle.Create( PcID, ShareParentPath );
  ShareFileDownConfirmCancelHandle.Update;
  ShareFileDownConfirmCancelHandle.Free;
end;

procedure TRevShareFileHandle.DownFileExistHandle;
var
  ShareFileDownAddCompletedSizeHandle : TShareFileDownAddCompletedSizeHandle;
begin
  inherited;

    // 添加 根节点 已完成空间
  ShareFileDownAddCompletedSizeHandle := TShareFileDownAddCompletedSizeHandle.Create( PcID, ShareParentPath );
  ShareFileDownAddCompletedSizeHandle.SetCompletedSize( FileSize );
  ShareFileDownAddCompletedSizeHandle.Update;
  ShareFileDownAddCompletedSizeHandle.Free;

  CompletedFileSend;
end;

procedure TRevShareFileHandle.IniRevFile;
begin
  if PendingJobInfo is TShareJobInfo then
  begin
    ShareFilePath := ( PendingJobInfo as TShareJobInfo ).FilePath;
    ShareParentPath := MyShareDownInfoReadUtil.ReadRootPath( PcID, ShareFilePath );
    IsRootFile := ShareFilePath = ShareParentPath;
  end;
  LoadingSize := 0;
  TotalRev := 0;
end;

procedure TRevShareFileHandle.RefreshLastLoadingFace;
var
  ShareFileDownChildAddCompletedSizeHandle : TShareFileDownChildAddCompletedSizeHandle;
  ShareFileDownAddCompletedSizeHandle : TShareFileDownAddCompletedSizeHandle;
begin
    // 添加 子节点 已完成空间
  ShareFileDownChildAddCompletedSizeHandle := TShareFileDownChildAddCompletedSizeHandle.Create( PcID, ShareParentPath );
  ShareFileDownChildAddCompletedSizeHandle.SetFilePath( ShareFilePath );
  ShareFileDownChildAddCompletedSizeHandle.SetCompletedSize( LoadingSize );
  ShareFileDownChildAddCompletedSizeHandle.Update;
  ShareFileDownChildAddCompletedSizeHandle.Free;

    // 添加 根节点 已完成空间
  ShareFileDownAddCompletedSizeHandle := TShareFileDownAddCompletedSizeHandle.Create( PcID, ShareParentPath );
  ShareFileDownAddCompletedSizeHandle.SetCompletedSize( LoadingSize );
  ShareFileDownAddCompletedSizeHandle.Update;
  ShareFileDownAddCompletedSizeHandle.Free;

  TotalRev := TotalRev + LoadingSize;
  DebugLog( IntToStr( TotalRev ) );
end;

procedure TRevShareFileHandle.RemovePcDownLoadingFace;
var
  VstShareFilePcRemoveDownload : TVstShareFilePcRemoveDownload;
begin
  VstShareFilePcRemoveDownload := TVstShareFilePcRemoveDownload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcRemoveDownload );
end;

procedure TRevShareFileHandle.RevFileAfter;
begin
    // 刷新 最后的 Loading 空间信息
  RefreshLastLoadingFace;

    // 接收 成功
  if TransResult = TransFile_OK then
    CompletedFileSend
  else    // 离线
  if TransResult = TransFile_LostCon then
    AddFileSendOffline
  else   // 接收失败
    SetFileStatus( TransResult );
end;

procedure TRevShareFileHandle.RevFileBefore;
begin
  SetFileStatus( FileShareStatus_Downloading );
end;

procedure TRevShareFileHandle.SetFileStatus(Status: string);
var
  ShareFileDownChildSetStatusHandle : TShareFileDownChildSetStatusHandle;
begin
    // 设置 子节点状态
  ShareFileDownChildSetStatusHandle := TShareFileDownChildSetStatusHandle.Create( PcID, ShareParentPath );
  ShareFileDownChildSetStatusHandle.SetFilePath( ShareFilePath );
  ShareFileDownChildSetStatusHandle.SetStatus( Status );
  ShareFileDownChildSetStatusHandle.Update;
  ShareFileDownChildSetStatusHandle.Free;

    // 确认是否 取消共享
  if Status = TransFile_TransferCancel then
    ConfirmShareCancel;
end;

procedure TRevShareFileHandle.UpdateLoadingFace(RevSize: Integer);
begin
  inherited;

  LoadingSize := LoadingSize + RevSize;

  if SecondsBetween( Now, StartUpdataFaceTime ) < 1 then
    Exit;

    // 刷新 已完成信息
  RefreshLastLoadingFace;

  StartUpdataFaceTime := Now;
  LoadingSize := 0;
end;

{ TDownShareFileHandle }

procedure TDownShareFileHandle.AcceptCancelHandle;
var
  ShareJobInfo : TShareJobInfo;
  RootPath : string;
  ShareFileDownConfirmCancelHandle : TShareFileDownConfirmCancelHandle;
begin
  ShareJobInfo := PendingJobInfo as TShareJobInfo;
  RootPath := MyShareDownInfoReadUtil.ReadRootPath( TransferFileInfo.PcID, ShareJobInfo.FilePath );

  ShareFileDownConfirmCancelHandle := TShareFileDownConfirmCancelHandle.Create( TransferFileInfo.PcID, RootPath );
  ShareFileDownConfirmCancelHandle.Update;
  ShareFileDownConfirmCancelHandle.Free;
end;

procedure TDownShareFileHandle.AddToJob;
var
  PcID, FilePath, DownloadPath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  TransferShareJobAddHandle : TTransferShareJobAddHandle;
begin
  PcID := TransferFileInfo.PcID;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;
  if PendingJobInfo is TShareJobInfo then
  begin
    FilePath := ( PendingJobInfo as TShareJobInfo ).FilePath;
    DownloadPath := ( PendingJobInfo as TShareJobInfo ).DownloadPath;
  end;

    // 重返 Job 列表
  TransferShareJobAddHandle := TTransferShareJobAddHandle.Create( FilePath, PcID );
  TransferShareJobAddHandle.SetDownFilePath( DownloadPath );
  TransferShareJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferShareJobAddHandle.Update;
  TransferShareJobAddHandle.Free;
end;

procedure TDownShareFileHandle.ConnErrorHandle;
begin
  AddToJob;
end;

function TDownShareFileHandle.getJobIsContinues: Boolean;
var
  ShareJobInfo : TShareJobInfo;
  RootShareDownPath : string;
begin
  ShareJobInfo := PendingJobInfo as TShareJobInfo;
  RootShareDownPath := MyShareDownInfoReadUtil.ReadRootPath( TransferFileInfo.PcID, ShareJobInfo.FilePath );
  Result := MyShareDownInfoReadUtil.ReadIsEnable( TransferFileInfo.PcID, RootShareDownPath );
  if not Result then
    RemoveRemoteUpPend;
end;

procedure TDownShareFileHandle.RemoveRemoteUpPend;
var
  ShareJobInfo : TShareJobInfo;
  PcRemoveUpPendFileMsg : TPcRemoveUpPendFileMsg;
begin
  ShareJobInfo := PendingJobInfo as TShareJobInfo;

  PcRemoveUpPendFileMsg := TPcRemoveUpPendFileMsg.Create;
  PcRemoveUpPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveUpPendFileMsg.SetRemovePath( ShareJobInfo.FilePath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveUpPendFileMsg );
end;

{ TRevTransferFileHandle }

procedure TRevTransferFileHandle.AddPcDownLoadingFace;
var
  VstFileTransferDesAddDownload : TVstFileTransferDesAddDownload;
begin
  VstFileTransferDesAddDownload := TVstFileTransferDesAddDownload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesAddDownload );
end;

function TRevTransferFileHandle.CheckDownloadContinues: Boolean;
begin
  Result := MyFileReceiveInfoReadUtil.ReadIsExist( SendRootPath, PcID );
end;

procedure TRevTransferFileHandle.IniRevFile;
var
  FileSendJobInfo : TFileSendJobInfo;
begin
  FileSendJobInfo := PendingJobInfo as TFileSendJobInfo;
  SendFilePath := FileSendJobInfo.UploadPath;
  SendRootPath := MyFileReceiveInfoReadUtil.ReadRootSendPath( SendFilePath, PcID );
end;

procedure TRevTransferFileHandle.RemovePcDownLoadingFace;
var
  VstFileTransferDesRemoveDownload : TVstFileTransferDesRemoveDownload;
begin
    // 删除 文件传输 Pc 界面
  VstFileTransferDesRemoveDownload := TVstFileTransferDesRemoveDownload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesRemoveDownload );
end;

{ TDownRestoreFileHandle }

procedure TDownRestoreFileHandle.AddToJob;
var
  PcID, FilePath, DownloadPath, RestorePcID : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  RestoreJobInfo : TRestoreJobInfo;
  TransferRestoreJobAddHandle : TTransferRestoreJobAddHandle;
begin
  PcID := TransferFileInfo.PcID;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;
  if PendingJobInfo is TRestoreJobInfo then
  begin
    RestoreJobInfo := PendingJobInfo as TRestoreJobInfo;
    FilePath := RestoreJobInfo.FilePath;
    DownloadPath := RestoreJobInfo.DownloadPath;
    RestorePcID := RestoreJobInfo.BackupFilePcID;
  end;

    // 重返 Job 列表
  TransferRestoreJobAddHandle := TTransferRestoreJobAddHandle.Create( FilePath, PcID );
  TransferRestoreJobAddHandle.SetRestorePcID( RestorePcID );
  TransferRestoreJobAddHandle.SetDownFilePath( DownloadPath );
  TransferRestoreJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferRestoreJobAddHandle.Update;
  TransferRestoreJobAddHandle.Free;
end;

procedure TDownRestoreFileHandle.ConnErrorHandle;
begin
  AddToJob;
end;

function TDownRestoreFileHandle.getJobIsContinues: Boolean;
var
  RestoreJobInfo : TRestoreJobInfo;
  RestorePcID, RestoreItemPath : string;
begin
  RestoreJobInfo := PendingJobInfo as TRestoreJobInfo;
  RestorePcID := RestoreJobInfo.BackupFilePcID;
  RestoreItemPath := MyRestoreInfoReadUtil.ReadRootPath( RestoreJobInfo.FilePath, RestorePcID );
  Result := MyRestoreInfoReadUtil.ReadIsEnable( RestoreItemPath, RestorePcID );
  if not Result then  // 删除 远程 UpPend
    RemoveRemoteUpPend;
end;

procedure TDownRestoreFileHandle.RemoveRemoteUpPend;
var
  RestoreJobInfo : TRestoreJobInfo;
  PcRemoveUpPendFileMsg : TPcRemoveUpPendFileMsg;
begin
  RestoreJobInfo := PendingJobInfo as TRestoreJobInfo;

  PcRemoveUpPendFileMsg := TPcRemoveUpPendFileMsg.Create;
  PcRemoveUpPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveUpPendFileMsg.SetRemovePath( RestoreJobInfo.FilePath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveUpPendFileMsg );
end;

{ TRevFileActivateHandle }

function TRevFileActivateHandle.CheckNextRev: Boolean;
begin
  Result := False;
  if not inherited then
    Exit;

    // 检查 是否 下载取消
  if not CheckDownloadContinues then
  begin
    TransResult := WriteFile_DownloadCancel;
    Exit;
  end;

  Result := True;
end;

{ TDownSerachSourceFileHandle }

procedure TDownSerachSourceFileHandle.AddToJob;
var
  SourceSerachJobInfo : TSourceSearchJobInfo;
  TransferSourceSearchJobAddHandle : TTransferSourceSearchJobAddHandle;
begin
  SourceSerachJobInfo := PendingJobInfo as TSourceSearchJobInfo;

  TransferSourceSearchJobAddHandle := TTransferSourceSearchJobAddHandle.Create( SourceSerachJobInfo.FilePath, SourceSerachJobInfo.PcID );
  TransferSourceSearchJobAddHandle.SetFileInfo( TransferFileInfo.FileSize, TransferFileInfo.Position, TransferFileInfo.FileTime );
  TransferSourceSearchJobAddHandle.SetDownFilePath( TransferFileInfo.LoadPath );
  TransferSourceSearchJobAddHandle.Update;
  TransferSourceSearchJobAddHandle.Free;
end;

procedure TDownSerachSourceFileHandle.ConnErrorHandle;
begin
  AddToJob;
end;

function TDownSerachSourceFileHandle.getJobIsContinues: Boolean;
var
  SourceSerachJobInfo : TSourceSearchJobInfo;
begin
  SourceSerachJobInfo := PendingJobInfo as TSourceSearchJobInfo;
  Result := MySearchDownReadInfoUtil.ReadIsEnable( TransferFileInfo.PcID, SourceSerachJobInfo.FilePath );
end;

{ TDownSerachBackupFileHandle }

procedure TDownSerachBackupFileHandle.AddToJob;
var
  BackupSearchJobInfo : TBackupSearchJobInfo;
  TransferBackupSearchJobAddHandle : TTransferBackupSearchJobAddHandle;
begin
  BackupSearchJobInfo := PendingJobInfo as TBackupSearchJobInfo;

  TransferBackupSearchJobAddHandle := TTransferBackupSearchJobAddHandle.Create( BackupSearchJobInfo.FilePath, BackupSearchJobInfo.PcID );
  TransferBackupSearchJobAddHandle.SetFileInfo( TransferFileInfo.FileSize, TransferFileInfo.Position, TransferFileInfo.FileTime );
  TransferBackupSearchJobAddHandle.SetDownFilePath( TransferFileInfo.LoadPath );
  TransferBackupSearchJobAddHandle.SetSourcePcID( BackupSearchJobInfo.BackupFilePcID );
  TransferBackupSearchJobAddHandle.Update;
  TransferBackupSearchJobAddHandle.Free;
end;

procedure TDownSerachBackupFileHandle.ConnErrorHandle;
begin
  AddToJob;
end;

function TDownSerachBackupFileHandle.getJobIsContinues: Boolean;
var
  BackupSearchJobInfo : TBackupSearchJobInfo;
begin
  BackupSearchJobInfo := PendingJobInfo as TBackupSearchJobInfo;
  Result := MySearchDownReadInfoUtil.ReadIsEnable( BackupSearchJobInfo.BackupFilePcID, BackupSearchJobInfo.FilePath );
end;

{ TRevSearchDownSourceFileHandle }

procedure TRevSearchDownSourceFileHandle.AddSearchDownOffline;
var
  TransferSourceSearchJobAddHandle : TTransferSourceSearchJobAddHandle;
begin
  TransferSourceSearchJobAddHandle := TTransferSourceSearchJobAddHandle.Create( SourceFilePath, PcID );
  TransferSourceSearchJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferSourceSearchJobAddHandle.SetDownFilePath( DownFilePath );
  TransferSourceSearchJobAddHandle.Update;
  TransferSourceSearchJobAddHandle.Free;
end;

procedure TRevSearchDownSourceFileHandle.IniRevFile;
var
  SourceSearchJobInfo : TSourceSearchJobInfo;
begin
  inherited;

  SourceSearchJobInfo := PendingJobInfo as TSourceSearchJobInfo;
  SourcePcID := SourceSearchJobInfo.PcID;
  SourceFilePath := SourceSearchJobInfo.FilePath;
end;

{ TRevSearchDownBackupFileHandle }

procedure TRevSearchDownBackupFileHandle.AddSearchDownOffline;
var
  TransferBackupSearchJobAddHandle : TTransferBackupSearchJobAddHandle;
begin
  TransferBackupSearchJobAddHandle := TTransferBackupSearchJobAddHandle.Create( SourceFilePath, PcID );
  TransferBackupSearchJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupSearchJobAddHandle.SetDownFilePath( DownFilePath );
  TransferBackupSearchJobAddHandle.SetSourcePcID( SourcePcID );
  TransferBackupSearchJobAddHandle.Update;
  TransferBackupSearchJobAddHandle.Free;
end;

procedure TRevSearchDownBackupFileHandle.IniRevFile;
var
  BackupSearchJobInfo : TBackupSearchJobInfo;
begin
  inherited;

  BackupSearchJobInfo := PendingJobInfo as TBackupSearchJobInfo;
  SourcePcID := BackupSearchJobInfo.BackupFilePcID;
  SourceFilePath := BackupSearchJobInfo.FilePath;
end;

end.
