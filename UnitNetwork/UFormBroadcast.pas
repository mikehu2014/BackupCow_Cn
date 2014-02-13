unit UFormBroadcast;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, winsock,
  StdCtrls, UMyUtil;

const
  WM_SOCK = WM_USER + 1;     //自定义windows消息

var
  UdpPort_Broadcast : Integer = 6542;            //设定UDP端口号

type
  TStrEvent = procedure( s : string ) of object;

    // 广播 窗口
  TfrmBroadcast = class(TForm)
  private
    s: TSocket;
    addr: TSockAddr;
    FSockAddrIn : TSockAddrIn;
    FRevMsgEvent : TStrEvent;
  private       // 收发 广播
    procedure RevBroadcast( var Message: TMessage ); message WM_SOCK;
    procedure SendBroadcast( Msg : string );
    procedure SendBroadcastToIp( Msg : string; Ip: AnsiString );
  public
     constructor Create;
     destructor Destroy; override;
  public        // 收发数据
    procedure SendMsg( Msg: string );
    procedure RevMsg( Msg : string );
    property OnRevMsgEvent: TStrEvent read FRevMsgEvent write FRevMsgEvent;
  end;

var
  frmBroadcast : TfrmBroadcast;

implementation

{$R *.dfm}


procedure TfrmBroadcast.RevBroadcast(var Message: TMessage);
var
  buf : array[0..4095] of Char;
  len: integer;
  flen: integer;
  Event: word;
  value: string;
begin
  try
    flen:=sizeof(FSockAddrIn);
    FSockAddrIn.SIn_Port := htons(UdpPort_Broadcast);
    Event := WSAGetSelectEvent(Message.LParam);
    if Event <> FD_READ then
      Exit;

    len := recvfrom(s, buf, SizeOf( buf ), 0, FSockAddrIn, flen );
    value := copy( buf, 1, len + 1 );

        // 线程处理接收广播
    RevMsg( value );
  except
  end;
end;

procedure TfrmBroadcast.SendBroadcast(Msg: string);
var
  IpList : TStringList;
  i : Integer;
begin
  IpList := MyBroadcastIpList.get;
  for i := 0 to IpList.Count - 1 do
    SendBroadcastToIp( Msg, IpList[i] );
  IpList.Free;
end;

procedure TfrmBroadcast.SendBroadcastToIp(Msg: string; Ip: AnsiString);
var
   value{,hostname}: string;
   len: integer;
   flen : Integer;
   buf: TByteArray;
begin
  try
    flen := SizeOf( FSockAddrIn );
    FSockAddrIn.SIn_Addr.S_addr := inet_addr(pansichar(Ip));
    value := Msg;
    len := sendto(s, value[1], Length(value) * 2, 0, FSockAddrIn, flen);
  except
  end;
end;

procedure TfrmBroadcast.SendMsg(Msg: String);
begin
  SendBroadcast( Msg );
end;


constructor TfrmBroadcast.Create;
var
   TempWSAData: TWSAData;
   optval: integer;
begin
  inherited Create( nil );
  FRevMsgEvent := nil;

      // 初始化 Socket
  if WSAStartup($101, TempWSAData)=1 then;
//    showmessage('StartUp Error!');

      // 创建 Socket
  s := Socket( AF_INET, SOCK_DGRAM, 0 );
  if (s = INVALID_SOCKET) then   //Socket创建失败
  begin
//    showmessage(inttostr(WSAGetLastError())+'  Socket创建失败');
    CloseSocket(s);
    exit;
  end;

    //发送方 SockAddr 绑定
  addr.sin_family := AF_INET;
  addr.sin_addr.S_addr := INADDR_ANY;
  addr.sin_port := htons(UdpPort_Broadcast);
  if Bind(s, addr, sizeof(addr)) <> 0  then
  begin
//   showmessage('bind fail');
   Exit;
  end;

    // 广播发送 UDP 信息
  optval:= 1;
  if setsockopt(s,SOL_SOCKET,SO_BROADCAST, PAnsiChar(@optval),sizeof(optval)) = SOCKET_ERROR then
  begin
//   showmessage('无法进行UDP广播');
   Exit;
  end;

    //接收端SockAddrIn设定
  WSAAsyncSelect(s, Self.Handle , WM_SOCK, FD_READ);
  FSockAddrIn.SIn_Family := AF_INET;
  FSockAddrIn.SIn_Port := htons(UdpPort_Broadcast);
end;

destructor TfrmBroadcast.Destroy;
begin
  CloseSocket(s);
  inherited;
end;

procedure TfrmBroadcast.RevMsg(Msg: string);
begin
  if Assigned( FRevMsgEvent ) then
    FRevMsgEvent( Msg );
end;

end.
