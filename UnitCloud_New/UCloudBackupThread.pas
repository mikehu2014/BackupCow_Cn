unit UCloudBackupThread;

interface

uses classes, Sockets, UBackupThread, UModelUtil, SysUtils, Windows, UmyUtil, UMyTcp, math;

type

{$Region ' 网络备份 被扫描 ' }

  TNetworkFolderAccessScanHandle = class
  public
    TcpSocket : TCustomIpClient;
    PcID : string;
  public
    DesFileHash : TScanFileHash;
    DesFolderHash : TStringHash;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetPcID( _PcID : string );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ScanFolder( FolderPath : string );
    procedure SendScanResult;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;
  end;

  TNetworkFileAccessScanHandle = class
  public
    TcpSocket : TCustomIpClient;
    PcID : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetPcID( _PcID : string );
    procedure Update;
  end;

{$EndRegion}

{$Region ' 网络备份 被备份 ' }

  TBackupFileReceiveHandle = class
  public
    DesFilePath : string;
    TcpSocket : TCustomIpClient;
    SourceFileSize : Int64;
  public
    constructor Create( _DesFilePath : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure FileReceive;
    function CheckNextReceive : Boolean;
  end;

  TNetworkAccessBackupHandle = class
  public
    TcpSocket : TCustomIpClient;
    PcID : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetPcID( _PcID : string );
    procedure Update;
  private
    procedure FileAddHandle( DesFilePath : string );
  end;

{$EndRegion}

    // 备份算法
  TCloudBackupHandle = class
  public
    TcpSocket : TCustomIpClient;
    PcID : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure ScanHandle;
    procedure BackupHandle;
  end;

  TCloudBackupThread = class( TThread )
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure BackupHandle;
  end;

    // 云备份处理
  TMyCloudBackupHandler = class
  public
    CloudBackupThread : TCloudBackupThread;
  public
    constructor Create;
    procedure StopRun;
  public
    procedure ReceiveBackup( TcpSocket : TCustomIpClient );
  end;

var
  MyCloudBackupHandler : TMyCloudBackupHandler;

implementation

uses UMyCloudDataInfo;

{ TCloudBackupThread }

procedure TCloudBackupThread.BackupHandle;
var
  CloudBackupHandle : TCloudBackupHandle;
begin
  CloudBackupHandle := TCloudBackupHandle.Create( TcpSocket );
  CloudBackupHandle.Update;
  CloudBackupHandle.Free;
end;

constructor TCloudBackupThread.Create;
begin
  inherited Create( True );
end;

destructor TCloudBackupThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TCloudBackupThread.Execute;
begin
  while not Terminated do
  begin
      // 处理备份扫描
    BackupHandle;

      // 断开连接
    TcpSocket.Free;

    if not Terminated then
      Suspend;
  end;

  inherited;
end;

procedure TCloudBackupThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  Resume;
end;

{ TNetworkFolderAccessScanHandle }

function TNetworkFolderAccessScanHandle.CheckNextScan: Boolean;
begin
  Result := True;
end;

constructor TNetworkFolderAccessScanHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  DesFileHash := TScanFileHash.Create;
  DesFolderHash := TStringHash.Create;
end;

destructor TNetworkFolderAccessScanHandle.Destroy;
begin
  DesFileHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TNetworkFolderAccessScanHandle.ScanFolder(FolderPath: string);
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  DesScanFileInfo : TScanFileInfo;
begin
  DesFileHash.Clear;
  DesFolderHash.Clear;

    // 循环寻找 目录文件信息
  SearcFullPath := MyCloudInfoReadUtil.ReadCloudFilePath( PcID, FolderPath );
  SearcFullPath := MyFilePath.getPath( SearcFullPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;

        // 添加到目录结果
      if DirectoryExists( ChildPath ) then
        DesFolderHash.AddString( FileName )
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 添加到文件结果集合中
        DesScanFileInfo := TScanFileInfo.Create( FileName );
        DesScanFileInfo.SetFileInfo( FileSize, FileTime );
        DesFileHash.Add( FileName, DesScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TNetworkFolderAccessScanHandle.SendScanResult;
var
  p : TScanFilePair;
  ps : TStringPart;
begin
    // 发文件信息
  for p in DesFileHash do
  begin
    MySocketUtil.SendString( TcpSocket, FileReq_File );
    MySocketUtil.SendString( TcpSocket, p.Value.FileName );
    MySocketUtil.SendString( TcpSocket, IntToStr( p.Value.FileSize ) );
    MySocketUtil.SendString( TcpSocket, FloatToStr( p.Value.FileTime ) );
  end;

    // 发目录信息
  for ps in DesFolderHash do
  begin
    MySocketUtil.SendString( TcpSocket, FileReq_Folder );
    MySocketUtil.SendString( TcpSocket, p.Value.FileName );
  end;

    // 发送结束
  MySocketUtil.SendString( TcpSocket, FileReq_End );

    // 清空历史数据
  DesFileHash.Clear;
  DesFolderHash.Clear;
end;

procedure TNetworkFolderAccessScanHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TNetworkFolderAccessScanHandle.Update;
var
  FolderPath : string;
begin
  while True do
  begin
    FolderPath := MySocketUtil.RevString( TcpSocket );
    if ( FolderPath = FileReq_End ) or ( FolderPath = '' ) then
      Break;
    ScanFolder( FolderPath );
    SendScanResult;
  end;
end;

{ TNetworkFileAccessScanHandle }

constructor TNetworkFileAccessScanHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileAccessScanHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TNetworkFileAccessScanHandle.Update;
var
  SourceFilePath, DesFilePath : string;
  IsExistFile : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
begin
    // 接收源文件路径
  SourceFilePath := MySocketUtil.RevString( TcpSocket );

    // 提取目标文件路径
  DesFilePath := MyCloudInfoReadUtil.ReadCloudFilePath( PcID, SourceFilePath );

    // 发送文件信息
  IsExistFile := FileExists( DesFilePath );
  MySocketUtil.SendString( TcpSocket, BoolToStr( IsExistFile ) );
  if not IsExistFile then
    Exit;
  FileSize := MyFileInfo.getFileSize( SourceFilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );
  MySocketUtil.SendString( TcpSocket, IntToStr( FileSize ) );
  MySocketUtil.SendString( TcpSocket, FloatToStr( FileTime ) );
end;

{ TMyCloudBackupHandler }

constructor TMyCloudBackupHandler.Create;
begin
  CloudBackupThread := TCloudBackupThread.Create;
end;

procedure TMyCloudBackupHandler.ReceiveBackup(TcpSocket: TCustomIpClient);
begin
  CloudBackupThread.SetTcpSocket( TcpSocket );
end;

procedure TMyCloudBackupHandler.StopRun;
begin
  CloudBackupThread.Free;
end;

{ TNetworkAccessBackupHandle }

constructor TNetworkAccessBackupHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TNetworkAccessBackupHandle.FileAddHandle(DesFilePath: string);
var
  BackupFileReceiveHandle : TBackupFileReceiveHandle;
begin
  BackupFileReceiveHandle := TBackupFileReceiveHandle.Create( DesFilePath );
  BackupFileReceiveHandle.SetTcpSocket( TcpSocket );
  BackupFileReceiveHandle.Update;
  BackupFileReceiveHandle.Free;
end;

procedure TNetworkAccessBackupHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TNetworkAccessBackupHandle.Update;
var
  FileBackupType : string;
  SourceFilePath, DesFilePath : string;
begin
  while True do
  begin
    FileBackupType := MySocketUtil.RevString( TcpSocket );
    if ( FileBackupType = FileBackup_End ) or ( FileBackupType = '' ) then
      Break;
    SourceFilePath := MySocketUtil.RevString( TcpSocket );
    DesFilePath := MyCloudInfoReadUtil.ReadCloudFilePath( PcID, SourceFilePath );
    if FileBackupType = FileBackup_AddFile then
      FileAddHandle( DesFilePath )
    else
    if FileBackupType = FileBackup_AddFolder then
      ForceDirectories( DesFilePath )
    else
    if FileBackupType = FileBackup_RemoveFile then
      SysUtils.DeleteFile( DesFilePath )
    else
    if FileBackupType = FileBackup_RemoveFolder then
      MyFolderDelete.DeleteDir( DesFilePath );
  end;
end;

{ TBackupFileReceiveHandle }

function TBackupFileReceiveHandle.CheckNextReceive: Boolean;
begin
  Result := True;
end;

constructor TBackupFileReceiveHandle.Create(_DesFilePath: string);
begin
  DesFilePath := _DesFilePath;
end;

procedure TBackupFileReceiveHandle.FileReceive;
var
  DesFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReceiveSize : Integer;
  RemainSize : Int64;
begin
  ForceDirectories( ExtractFileDir( DesFilePath ) );
  DesFileStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );
  FullBufSize := SizeOf( Buf );
  RemainSize := SourceFileSize;
  while RemainSize > 0 do
  begin
      // 取消复制 或 程序结束
    if not CheckNextReceive then
      Break;

    BufSize := Min( FullBufSize, RemainSize );
    ReceiveSize := TcpSocket.ReceiveBuf( Buf, BufSize );
    DesFileStream.Write( Buf, ReceiveSize );
    RemainSize := RemainSize - ReceiveSize;
  end;
  DesFileStream.Free;
end;

procedure TBackupFileReceiveHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TBackupFileReceiveHandle.Update;
var
  IsEnoughSpace : Boolean;
  FileTime : TDateTime;
begin
  SourceFileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), 0 );
  IsEnoughSpace := MyCloudInfoReadUtil.ReadCloudAvalibleSpace >= SourceFileSize;
  MySocketUtil.SendString( TcpSocket, BoolToStr( IsEnoughSpace ) );

    // 空间不足
  if not IsEnoughSpace then
    Exit;

    // 文件接收
  FileReceive;

    // 设置文件修改时间
  FileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), Now );
  MyFileSetTime.SetTime( DesFilePath, FileTime );
end;

{ TCloudBackupHandle }

procedure TCloudBackupHandle.BackupHandle;
var
  NetworkAccessBackupHandle : TNetworkAccessBackupHandle;
begin
  NetworkAccessBackupHandle := TNetworkAccessBackupHandle.Create( TcpSocket );
  NetworkAccessBackupHandle.SetPcID( PcID );
  NetworkAccessBackupHandle.Update;
  NetworkAccessBackupHandle.Free;
end;

constructor TCloudBackupHandle.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TCloudBackupHandle.ScanHandle;
var
  IsFile : Boolean;
  NetworkFolderAccessScanHandle : TNetworkFolderAccessScanHandle;
  NetworkFileAccessScanHandle : TNetworkFileAccessScanHandle;
begin
  IsFile := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), True );
  if IsFile then
  begin
    NetworkFileAccessScanHandle := TNetworkFileAccessScanHandle.Create( TcpSocket );
    NetworkFileAccessScanHandle.SetPcID( PcID );
    NetworkFileAccessScanHandle.Update;
    NetworkFileAccessScanHandle.Free;
  end
  else
  begin
    NetworkFolderAccessScanHandle := TNetworkFolderAccessScanHandle.Create( TcpSocket );
    NetworkFolderAccessScanHandle.SetPcID( PcID );
    NetworkFolderAccessScanHandle.Update;
    NetworkFolderAccessScanHandle.Free;
  end;
end;

procedure TCloudBackupHandle.Update;
begin
  PcID := MySocketUtil.RevString( TcpSocket );

    // 分析需要备份的文件
  ScanHandle;

    // 备份文件
  BackupHandle;
end;

end.
