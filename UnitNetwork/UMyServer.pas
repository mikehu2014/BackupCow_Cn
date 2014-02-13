unit UMyServer;

interface

uses Classes, Sockets, UChangeInfo, Generics.Collections, SyncObjs, UModelUtil;

type

{$Region ' Client 连接信息 ' }

    // 接收到 Client 的连接
  TAcceptClientSocket = class( TChangeInfo )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocet( _TcpSocket : TCustomIpClient );
    procedure Update;override;
  end;

    // Pc 断开 连接
  TClientLostConn = class( TChangeInfo )
  private
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  private
    procedure RemoveClient;
    procedure SendOffline;
  end;

    // 重启服务器
  TRestartServer = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Clinet 转发命令 ' }

    // 父类
  TSendClientMsgBase = class( TMsgBase )
  public
    iSendMsgStr : string;
  published
    property SendMsgStr : string Read iSendMsgStr Write iSendMsgStr;
  public
    procedure SetSendMsgBase( MsgBase : TMsgBase );
    procedure SetSendMsgStr( _SendMsgStr : string );
  end;

    // 发给 指定 Client
  TSendClientMsg = class( TSendClientMsgBase )
  public
    iTargetPcID : string;
  published
    property TargetPcID : string Read iTargetPcID Write iTargetPcID;
  public
    function getMsgType : string;override;
    procedure SetTargetPcID( _TargetPcID : string );
    procedure Update;override;
  end;

    // 发给 所有 Client
  TSendClientAllMsg = class( TSendClientMsgBase )
  public
    function getMsgType : string;override;
    procedure Update;override;
  end;

  TClientSendMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 命令 接收线程 ' }

    // 服务器 接收 客户端信息 的线程
  TRevClientMsgThread = class( TThread )
  private
    ClientPcID : string;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _TcpSocket : TCustomIpClient );
    procedure SetClientPcID( _ClientPcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure RevMsg( MsgStr : string );
    procedure SendMsg( MsgStr : string );
    procedure LostConn;
  end;
  TRevClientMsgThreadPair = TPair< string , TRevClientMsgThread >;
  TRevClientMsgThreadHash = class(TStringDictionary< TRevClientMsgThread >);

{$EndRegion}

    // 服务器端
  TMyServer = class( TMyMsgChange )
  private      // 接收 客户端命令 线程
    Lock : TCriticalSection;
    RevClientMsgThreadHash : TRevClientMsgThreadHash;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure SetFactoryList;override;
  public
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
    procedure RestartServer;
  end;

const
  ThreadCount_ClientMsg : Integer = 3; // 10 线程处理客户端命令

  MsgType_SendClientMsg : string = 'SendClientMsg';
  MsgType_SendClientMsg_SendPc : string = 'SendClientMsg_SendPc';
  MsgType_SendClientMsg_SendAll : string = 'SendClientMsg_SendAll';

var
  MyServer : TMyServer; // 服务器端

implementation

uses UMyClient, UMyNetPcInfo, UMyTcp;

{ TClientRevThread }

constructor TRevClientMsgThread.Create(_TcpSocket : TCustomIpClient);
begin
  inherited Create( True );
  TcpSocket := _TcpSocket;
end;

destructor TRevClientMsgThread.Destroy;
begin
  Terminate;
  TcpSocket.Disconnect;
  Resume;
  WaitFor;

  TcpSocket.Free;
  inherited;
end;

procedure TRevClientMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
    MsgStr := MySocketUtil.RevString( TcpSocket );
    if MsgStr = '' then
    begin
      LostConn;
      Break;
    end
    else
      RevMsg( MsgStr );
  end;

  inherited;
end;

procedure TRevClientMsgThread.LostConn;
var
  ClientLostConn : TClientLostConn;
begin
  ClientLostConn := TClientLostConn.Create( ClientPcID );
  MyServer.AddChange( ClientLostConn );
end;

procedure TRevClientMsgThread.RevMsg(MsgStr: string);
begin
  MyServer.AddMsg( MsgStr );
end;

procedure TRevClientMsgThread.SendMsg(MsgStr: string);
begin
  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TRevClientMsgThread.SetClientPcID(_ClientPcID: string);
begin
  ClientPcID := _ClientPcID;
end;

{ TMyServer }

procedure TMyServer.AcceptSocket(TcpSocket: TCustomIpClient);
var
  AcceptClientSocket : TAcceptClientSocket;
begin
  AcceptClientSocket := TAcceptClientSocket.Create;
  AcceptClientSocket.SetTcpSocet( TcpSocket );
  AddChange( AcceptClientSocket );
end;

constructor TMyServer.Create;
begin
  inherited Create;

  Lock := TCriticalSection.Create;
  RevClientMsgThreadHash := TRevClientMsgThreadHash.Create;

  AddThread( ThreadCount_ClientMsg );
end;

destructor TMyServer.Destroy;
begin
  Lock.Enter;
  RevClientMsgThreadHash.Clear;
  Lock.Leave;

  StopThread;

  RevClientMsgThreadHash.Free;
  Lock.Free;

  inherited;
end;

procedure TMyServer.RestartServer;
var
  RestartServerInfo : TRestartServer;
begin
  RestartServerInfo := TRestartServer.Create;
  AddChange( RestartServerInfo );
end;

procedure TMyServer.SetFactoryList;
var
  MsgFactory : TMsgFactory;
begin
  MsgFactory := TClientSendMsgFactory.Create;
  AddMsgFactory( MsgFactory );
end;

{ TAcceptClientSocket }

procedure TAcceptClientSocket.SetTcpSocet(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TAcceptClientSocket.Update;
var
  ClientPcID : string;
  NewRevThread : TRevClientMsgThread;
  RevThreadHash : TRevClientMsgThreadHash;
  ServerSendRefreshPcInfo : TServerSendRefreshPcInfo;
begin
  ClientPcID := MySocketUtil.RevString( TcpSocket );

    // 创建 接收线程
  NewRevThread := TRevClientMsgThread.Create( TcpSocket );
  NewRevThread.SetClientPcID( ClientPcID );
  NewRevThread.Resume;

    //  添加 集合中
  MyServer.Lock.Enter;
  RevThreadHash := MyServer.RevClientMsgThreadHash;
  RevThreadHash.AddOrSetValue( ClientPcID, NewRevThread );
  MyServer.Lock.Leave;

    // 发送 云信息 给 Online Pc
  ServerSendRefreshPcInfo := TServerSendRefreshPcInfo.Create( ClientPcID );
  MyClient.AddChange( ServerSendRefreshPcInfo );
end;

{ TSendClientMsg }

function TSendClientMsg.getMsgType: string;
begin
  Result := MsgType_SendClientMsg_SendPc;
end;

procedure TSendClientMsg.SetTargetPcID(_TargetPcID: string);
begin
  TargetPcID := _TargetPcID;
end;

procedure TSendClientMsg.Update;
var
  RevThreadHash : TRevClientMsgThreadHash;
begin
  MyServer.Lock.Enter;
  RevThreadHash := MyServer.RevClientMsgThreadHash;
  if RevThreadHash.ContainsKey( TargetPcID ) then
    RevThreadHash[ TargetPcID ].SendMsg( SendMsgStr );
  MyServer.Lock.Leave;
end;

{ TClientSendMsgFactory }

constructor TClientSendMsgFactory.Create;
begin
  inherited Create( MsgType_SendClientMsg );
end;

function TClientSendMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_SendClientMsg_SendPc then
    Result := TSendClientMsg.Create
  else
  if MsgType = MsgType_SendClientMsg_SendAll then
    Result := TSendClientAllMsg.Create
  else
    Result := nil;
end;

{ TSendClientMsgBase }

procedure TSendClientMsgBase.SetSendMsgBase(MsgBase: TMsgBase);
begin
  SendMsgStr := MsgBase.getMsg;
end;

procedure TSendClientMsgBase.SetSendMsgStr(_SendMsgStr: string);
begin
  SendMsgStr := _SendMsgStr;
end;

{ TSendClientAllMsg }

function TSendClientAllMsg.getMsgType: string;
begin
  Result := MsgType_SendClientMsg_SendAll;
end;

procedure TSendClientAllMsg.Update;
var
  RevThreadHash : TRevClientMsgThreadHash;
  p : TRevClientMsgThreadPair;
begin
  MyServer.Lock.Enter;
  RevThreadHash := MyServer.RevClientMsgThreadHash;
  for p in RevThreadHash do
    p.Value.SendMsg( SendMsgStr );
  MyServer.Lock.Leave;
end;

{ TRestartServer }

procedure TRestartServer.Update;
begin
  MyServer.Lock.Enter;
  MyServer.RevClientMsgThreadHash.Clear;
  MyServer.Lock.Leave;
end;

{ TClientLostConn }

constructor TClientLostConn.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TClientLostConn.RemoveClient;
begin
  MyServer.Lock.Enter;
  if MyServer.RevClientMsgThreadHash.ContainsKey( PcID ) then
    MyServer.RevClientMsgThreadHash.Remove( PcID );
  MyServer.Lock.Leave;
end;

procedure TClientLostConn.SendOffline;
var
  PcOfflineMsg : TPcOfflineMsg;
  SendClientAllMsg : TSendClientAllMsg;
begin
  PcOfflineMsg := TPcOfflineMsg.Create;
  PcOfflineMsg.SetPcID( PcID );

  SendClientAllMsg := TSendClientAllMsg.Create;
  SendClientAllMsg.SetSendMsgBase( PcOfflineMsg );

  MyServer.AddChange( SendClientAllMsg );

  PcOfflineMsg.Free;
end;

procedure TClientLostConn.Update;
begin
  SendOffline;

  RemoveClient;
end;

end.

