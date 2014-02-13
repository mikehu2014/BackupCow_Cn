unit UMyTcp;

interface

uses classes, sockets, UMyUtil, Windows, WinSock, UChangeInfo, SysUtils, DateUtils, uDebug,
     uDebugLock, Generics.Collections, SyncObjs;

type

    // 监听
  TListenThread = class( TThread )
  private
    ListenSocket : TCustomTcpServer;
  public
    constructor Create( ListenPort : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
  end;

    // Tcp 连接信息
  TTcpConnInfo = class( TMsgBase )
  private
    iConnEdiiton : Integer;
    iConnType : string;
  published
    property ConnEdiiton : Integer Read iConnEdiiton Write iConnEdiiton;
    property ConnType : string Read iConnType Write iConnType;
  public
    procedure SetConnInfo( _ConnEdiiton : Integer; _ConnType : string );
  end;

    // 如果 一定时间内连接端口失败，则断开连接
  TDisConnThread = class( TThread )
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // 连接
  TMyTcpConn = class
  private
    TcpSocket : TCustomIpClient;
    ConnTime : Integer;
  private
    ConnEdiiton : Integer;
    ConnType : string;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetConnSocket( Ip, Port : string );
    procedure SetConnType( _ConnType : string );
    function Conn : Boolean;
  private
    function ConnTarget : Boolean;
    function SocketConn : Boolean;
    function CheckConnSuccess : Boolean;
  end;

{$Region ' 处理连接 ' }

    // 数据结构
  TTcpAcceptInfo = class
  public
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
  end;
  TTcpAcceptList = class( TObjectList<TTcpAcceptInfo> )end;

    // 处理
  TAcceptSocketHandle = class
  public
    TcpAcceptInfo : TTcpAcceptInfo;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpAcceptInfo : TTcpAcceptInfo );
    procedure Update;
  private
    function HandleConn( ConnType : string ): Boolean;
  end;

    // 处理连接线程
  THandleListenThread = class( TThread )
  private
    DataLock : TCriticalSection;
    TcpAcceptList : TTcpAcceptList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure Handle( TcpAcceptInfo : TTcpAcceptInfo );
  end;
  THandleListenThreadList = class( TObjectList<THandleListenThread> )
  public
    procedure RunAllThread;
    procedure StopAllThread;
  end;

{$EndRegion}

  MySocketUtil = class
  public
    class function RevBusyData( TcpSocket : TCustomIpClient ): string;overload;
    class function RevData( TcpSocket : TCustomIpClient ): string;overload;
    class function RevData( TcpSocket : TCustomIpClient; WaitTime : Integer ): string;overload;
    class function RevBuf( TcpSocket : TCustomIpClient; var Buf; BufSize: Integer ) : Integer;
  public
    class function RevString( TcpSocket : TCustomIpClient ): string;
    class function SendString( TcpSocket : TCustomIpClient; MsgStr : string ): Integer;
  end;

    // 连接池
  TMyListener = class
  private
    ListenThread : TListenThread;
    HandleListenThreadList : THandleListenThreadList;
  private
    DataLock : TCriticalSection;
    TcpAcceptList : TTcpAcceptList;
  public
    constructor Create;
    procedure StopHandle;
    destructor Destroy; override;
  public
    procedure StartListen( Port : string );
    procedure StopListen;
  public
    procedure AddTcpAccept( TcpAcceptInfo : TTcpAcceptInfo );
    function getTcpAccept : TTcpAcceptInfo;
  end;

const
  ConnResult_OK : string = 'OK';
  ConnResult_Error : string = 'Error';

  ConnEdition_Now : Integer = 17;
  ConnType_SearchServer : string = 'SearchServer';
  ConnType_Server : string = 'Server';
  ConnType_UploadFile : string = 'UploadFile';
  ConnType_DownloadFile : string = 'DownloadFile';
  ConnType_ConfirmBackupFile : string = 'ConfirmBackupFile';
  ConnType_ConnfirmCloudFile : string = 'ConfirmCloudFIle';
  ConnType_NetworkBackup : string = 'NetworkBackup';

  WaitTime_Accept : Integer = 5;   // 5 秒钟 Accept
  WaitTime_Busy : Integer = 5; // 5 秒钟 Busy
  WaitTime_RevData : Integer = 60; // 60 秒 断开连接

  ThreadCount_Conn : Integer = 2;
  ConnTime_Client : Integer = 20;

  ErrorMark_RevString = '</Error_Mark_RevStr>';
var
  MyListener : TMyListener;
  ListenPort_Tcp : Integer = 9595;

implementation

uses UMyMaster, UMyServer, UMyFileDownload, UMyFileUpLoad, UMyNetPcInfo, UBackupFileConfirm,
     UCloudBackupThread;

{ TListenThread }

procedure TListenThread.AcceptSocket(TcpSocket: TCustomIpClient);
var
  TcpAcceptInfo : TTcpAcceptInfo;
begin
  TcpAcceptInfo := TTcpAcceptInfo.Create( TcpSocket );
  MyListener.AddTcpAccept( TcpAcceptInfo );
end;

constructor TListenThread.Create( ListenPort : string );
begin
  inherited Create( True );

  ListenSocket := TCustomTcpServer.Create(nil);
  ListenSocket.LocalHost := '0.0.0.0';
  ListenSocket.LocalPort := ListenPort;
  ListenSocket.Active := True;
end;

destructor TListenThread.Destroy;
begin
  Terminate;
  ListenSocket.Close;
  Resume;
  WaitFor;

  ListenSocket.Free;
  inherited;
end;

procedure TListenThread.Execute;
var
  TcpSocket : TCustomIpClient;
begin
  while not Terminated do
  begin
    TcpSocket := TCustomIpClient.Create(nil);
    if ListenSocket.Accept( TcpSocket ) then
      AcceptSocket( TcpSocket )
    else
      TcpSocket.Free;
  end;
  inherited;
end;

{ MyTcpConn }

function TMyTcpConn.CheckConnSuccess: Boolean;
var
  TcpConnInfo : TTcpConnInfo;
  MsgStr : string;
begin
  TcpConnInfo := TTcpConnInfo.Create;
  TcpConnInfo.SetConnInfo( ConnEdiiton, ConnType );
  MsgStr := TcpConnInfo.getMsgStr;
  TcpConnInfo.Free;

  MySocketUtil.SendString( TcpSocket, MsgStr );

  Result := MySocketUtil.RevData( TcpSocket ) = ConnResult_OK ;
end;

function TMyTcpConn.Conn: Boolean;
begin
  Result := ConnTarget and CheckConnSuccess;
end;

function TMyTcpConn.ConnTarget: Boolean;
begin
    // 连不上
  if not SocketConn then
  begin
    Result := False;
    Exit;
  end;

    // 多次出现空连接， 可能端口被其他程序占用
  if ConnTime >= ConnTime_Client then
  begin
    Result := False;
    Exit;
  end;

    // 连上了 但出现 连接错误
  if MySocketUtil.RevString( TcpSocket ) <> ConnResult_OK then
  begin
    TcpSocket.Disconnect;  // 关闭连接
    Sleep( 100 );  // 等待时间
    Inc( ConnTime );
    Result := ConnTarget;  //再连接一次
  end
  else
    Result := true;  // 连接成功
end;

constructor TMyTcpConn.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
  ConnEdiiton := ConnEdition_Now;
  ConnTime := 0;
end;

procedure TMyTcpConn.SetConnSocket(Ip, Port: string);
begin
  TcpSocket.RemoteHost := Ip;
  TcpSocket.RemotePort := Port;
end;

procedure TMyTcpConn.SetConnType(_ConnType: string);
begin
  ConnType := _ConnType;
end;

function TMyTcpConn.SocketConn: Boolean;
var
  DisConnThread : TDisConnThread;
begin
  DisConnThread := TDisConnThread.Create( TcpSocket );
  DisConnThread.Resume;
  Result := TcpSocket.Connect;
  DisConnThread.Free;
end;

{ TTcpConnInfo }

procedure TTcpConnInfo.SetConnInfo(_ConnEdiiton: Integer; _ConnType: string);
begin
  ConnEdiiton := _ConnEdiiton;
  ConnType := _ConnType;
end;

{ TMyListener }

procedure TMyListener.AddTcpAccept(TcpAcceptInfo: TTcpAcceptInfo);
begin
  DataLock.Enter;
  TcpAcceptList.Add( TcpAcceptInfo );
  DataLock.Leave;

  HandleListenThreadList.RunAllThread;
end;

constructor TMyListener.Create;
var
  i : Integer;
  HandleListenThread : THandleListenThread;
begin
  DataLock := TCriticalSection.Create;
  TcpAcceptList := TTcpAcceptList.Create;
  TcpAcceptList.OwnsObjects := False;
  HandleListenThreadList := THandleListenThreadList.Create;
  for i := 0 to ThreadCount_Conn - 1 do
  begin
    HandleListenThread := THandleListenThread.Create;
    HandleListenThreadList.Add( HandleListenThread );
  end;
end;

destructor TMyListener.Destroy;
begin
  HandleListenThreadList.Free;
  TcpAcceptList.OwnsObjects := True;
  TcpAcceptList.Free;
  DataLock.Free;
  inherited;
end;

function TMyListener.getTcpAccept: TTcpAcceptInfo;
begin
  DataLock.Enter;
  if TcpAcceptList.Count > 0 then
  begin
    Result := TcpAcceptList[0];
    TcpAcceptList.Delete(0);
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TMyListener.StartListen(Port: string);
begin
  ListenThread := TListenThread.Create( Port );
  ListenThread.Resume;
end;

procedure TMyListener.StopHandle;
begin
  HandleListenThreadList.StopAllThread;
end;

procedure TMyListener.StopListen;
begin
  ListenThread.Free;
end;

{ MySocketUtil }

class function MySocketUtil.RevBuf(TcpSocket: TCustomIpClient; var Buf;
  BufSize: Integer): Integer;
var
  StartTime, WaitDataStart : TDateTime;
begin
  Result := SOCKET_ERROR;

  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < WaitTime_RevData ) do
  begin
    WaitDataStart := Now;
    if TcpSocket.WaitForData( 100 ) then // 等待数据
    begin
      Result := TcpSocket.ReceiveBuf( Buf, BufSize );
      Break;
    end
    else
    if MilliSecondsBetween( Now, WaitDataStart ) < 90 then
      Break;
  end;
end;

class function MySocketUtil.RevData(TcpSocket: TCustomIpClient): string;
begin
  Result := MySocketUtil.RevData( TcpSocket, WaitTime_RevData );
end;

class function MySocketUtil.RevBusyData(TcpSocket: TCustomIpClient): string;
var
  StartTime : TDateTime;
begin
  StartTime := Now;
  Result := RevData( TcpSocket, WaitTime_Busy );
    // Busy
  if Result = '' then
  begin
    TcpSocket.Disconnect;
    while ( SecondsBetween( Now, StartTime ) < 2 ) do
      Sleep(100);
  end;
end;

class function MySocketUtil.RevData(TcpSocket: TCustomIpClient;
  WaitTime: Integer): string;
var
  StartTime, WaitDataStart : TDateTime;
begin
  Result := '';

  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < WaitTime ) do
  begin
    WaitDataStart := Now;
    if TcpSocket.WaitForData( 100 ) then // 等待数据
    begin
      Result := RevString( TcpSocket );
      Break;
    end
    else
    if MilliSecondsBetween( Now, WaitDataStart ) < 90 then
      Break;
  end;
end;


class function MySocketUtil.RevString(TcpSocket: TCustomIpClient): string;
begin
  Result := TcpSocket.Receiveln;
  if Pos( ErrorMark_RevString, Result ) > 0 then
    Result := MyString.CutStopStr( ErrorMark_RevString, Result );
end;

class function MySocketUtil.SendString(TcpSocket: TCustomIpClient;
  MsgStr: string): Integer;
begin
  if Length( AnsiString( MsgStr ) ) = 510 then
    MsgStr := MsgStr + ErrorMark_RevString;
  Result := TcpSocket.Sendln( MsgStr );
end;

{ TDisConnThread }

constructor TDisConnThread.Create(_TcpSocket: TCustomIpClient);
begin
  inherited Create( True );
  TcpSocket := _TcpSocket;
end;

destructor TDisConnThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TDisConnThread.Execute;
var
  StartTime : TDateTime;
  IsConn : Boolean;
begin
    // 5 秒内没有连接上 则断开连接
  IsConn := False;
  StartTime := Now;
  while ( SecondsBetween( Now, StartTime ) < 5 ) do
    if not Terminated then
      Sleep(100)
    else
    begin
      IsConn := True;
      Break;
    end;

    // 超时断开连接
  if not IsConn then
    TcpSocket.Disconnect;

  inherited;
end;

{ THandleListenThread }

constructor THandleListenThread.Create;
begin
  inherited Create( True );
end;

destructor THandleListenThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure THandleListenThread.Execute;
var
  TcpAcceptInfo : TTcpAcceptInfo;
begin
  while not Terminated do
  begin
    TcpAcceptInfo := MyListener.getTcpAccept;

    if TcpAcceptInfo = nil then
    begin
      Suspend;
      Continue;
    end;

    Handle( TcpAcceptInfo );

    TcpAcceptInfo.Free;
  end;
  inherited;
end;

procedure THandleListenThread.Handle(TcpAcceptInfo: TTcpAcceptInfo);
var
  AcceptSocketHandle : TAcceptSocketHandle;
begin
  AcceptSocketHandle := TAcceptSocketHandle.Create( TcpAcceptInfo );
  AcceptSocketHandle.Update;
  AcceptSocketHandle.Free;
end;

{ TTcpAcceptInfo }

constructor TTcpAcceptInfo.Create(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TAcceptSocketHandle }

constructor TAcceptSocketHandle.Create(_TcpAcceptInfo: TTcpAcceptInfo);
begin
  TcpAcceptInfo := _TcpAcceptInfo;
  TcpSocket := TcpAcceptInfo.TcpSocket;
end;

function TAcceptSocketHandle.HandleConn(ConnType: string): Boolean;
begin
  Result := True;

  if ConnType = ConnType_SearchServer then
    MyMasterAccept.AcceptSocket( TcpSocket )
  else
  if ConnType = ConnType_Server then
    MyServer.AcceptSocket( TcpSocket )
  else
  if ConnType = ConnType_UploadFile then
    MyFileDownload.AcceptSocket( TcpSocket )
  else
  if ConnType = ConnType_DownloadFile then
    MyFileUpload.AcceptSocket( TcpSocket )
  else
  if ConnType = ConnType_ConfirmBackupFile then
    MyFileAcceptConfirm.AddBackupConfirm( TcpSocket )
  else
  if ConnType = ConnType_ConnfirmCloudFile then
    MyFileAcceptConfirm.AddCloudConfirm( TcpSocket )
  else
  if ConnType = ConnType_NetworkBackup then
    MyCloudBackupHandler.ReceiveBackup( TcpSocket )
  else
    Result := False;
end;


procedure TAcceptSocketHandle.Update;
var
  MsgStr : string;
  TcpConnInfo : TTcpConnInfo;
  ConnResult, ConnType : string;
begin
    // 发送连接成功标志
  MySocketUtil.SendString( TcpSocket, ConnResult_OK );

    // 接收 Tcp 连接信息
  MsgStr := MySocketUtil.RevData( TcpSocket, WaitTime_Accept );
  if MsgStr = '' then
  begin
    TcpSocket.Free;
    Exit;
  end;

    // 解释 连接信息
  TcpConnInfo := TTcpConnInfo.Create;
  TcpConnInfo.SetMsgStr( MsgStr );
  if TcpConnInfo.ConnEdiiton = ConnEdition_Now  then
    ConnResult := ConnResult_OK
  else
    ConnResult := ConnResult_Error;
  ConnType := TcpConnInfo.ConnType;
  TcpConnInfo.Free;

    // 发送 连接结果
  MySocketUtil.SendString( TcpSocket, ConnResult );

    // 处理 连接结果
  if ConnResult = ConnResult_OK then
    HandleConn( ConnType )
  else
    TcpSocket.Free;
end;

{ THandleListenThreadList }

procedure THandleListenThreadList.RunAllThread;
var
  i : Integer;
begin
  for i := 0 to Self.Count - 1 do
    Self[i].Resume;
end;

procedure THandleListenThreadList.StopAllThread;
var
  i : Integer;
begin
  for i := Self.Count - 1 downto 0 do
    Self.Delete(i);
end;

end.

