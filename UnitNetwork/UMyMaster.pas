unit UMyMaster;

interface

uses UChangeInfo, UMyUtil, UMyNetPcInfo, UMyTcp, Sockets, SysUtils, uDebug;

type

{$Region ' 命令信息 ' }

  TPcInfoBaseMsg = class( TMsgBase )
  private
    iPcID : string;
    iIp, iPort : string;
  published
    property PcID : string Read iPcID Write iPcID;
    property Ip : string Read iIp Write iIp;
    property Port : string Read iPort Write iPort;
  public
    procedure SetPcID( _PcID : string );
    procedure SetSocketInfo( _Ip, _Port : string );
  end;

    // 局域网 Pc 信息
  TPcInfoMsg = class( TPcInfoBaseMsg )
  private
    iPcName : string;
    iCloudIDNumMD5 : string;
  published
    property PcName : string Read iPcName Write iPcName;
    property CloudIDNumMD5 : string Read iCloudIDNumMD5 Write iCloudIDNumMD5;
  public
    procedure SetPcName( _PcName : string );
    procedure SetSocketInfo( _Ip, _Port : string );
    procedure SetCloudIDNumMD5( _CloudIDNumMD5 : string );
  end;

    // 互联网 Pc 信息
  TInternetPcInfoMsg = class( TPcInfoMsg )
  private
    iInternetIp : string;
    iInternetPort : string;
  published
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    constructor SetnternetSocketInfo( _InternetIp, _InternetPort : string );
  end;

    // 局域网 广播
  TLanBroadcastMsg = class( TPcInfoMsg )
  end;

    // Reach 信息
  TPcReadhInfoMsg = class( TPcInfoBaseMsg )
  end;


    // Pc 选 Master 信息
  TPcRunInfoMsg = class( TMsgBase )
  private
    iStartTime : TDateTime;
    iRanNum : Integer;
  published
    property StartTime : TDateTime Read iStartTime Write iStartTime;
    property RanNum : Integer Read iRanNum Write iRanNum;
  public
    procedure SetRunInfo( _StartTime : TDateTime; _RanNum : Integer );
  end;


{$EndRegion}

{$Region ' Master 命令 ' }

    // 接收到 连接
  TMasterAcceptSocket = class( TChangeInfo )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;override;
  private
    procedure CheckMasterConn( MasterConn : string );
  end;

  {$Region ' 广播命令 ' }

    // 发送 广播命令
  TSendLanBroadcast = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // 接收 广播命令
  TRevLanBroadcast = class( TChangeInfo )
  private
    BroadcastStr : string;
    LanPcMsgStr : string;
  private
    PcID, PcName : string;
    LanIp, LanPort : string;
    CloudIDNumMD5 : string;
  public
    procedure SetBroadcastStr( _BroadcastStr : string );
    procedure Update;override;
  private
    function CheckBroadcastMsg : Boolean;
    procedure FindBroadcastMsg;
  private
    procedure AddNetworkPc;
    procedure SendLanPing;
  end;

  {$EndRegion}

  {$Region ' 命令 父类 ' }

      // 父类
  TConnHandle = class
  protected
    RemovePcID : string;
  protected
    LocalIp, LocalPort : string;
    RemoveIp, RemovePort : string;
  protected
    TcpSocket : TCustomIpClient;
  public
    procedure SetRemovePcID( _RemovePcID : string );
    procedure SetLocalSocket( _LocalIp, _LocalPort : string );
    procedure SetRemoveSocket( _RemoveIp, _RemovePort : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;virtual;abstract;
    function getMasterConn : string;virtual;abstract;
  end;

  {$EndRegion}

  {$Region ' Ping 命令 ' }

      // Ping 父类
  TPingHandle = class( TConnHandle )
  private
    RemoveStartTime : TDateTime;
    RemoveRanNum : Integer;
  protected
    procedure SendLocalPcRunInfo;
    function RevRemovePcRunInfo: Boolean;
    procedure SendLocalIsMaster;
    function RevRemoveIsMaster : Boolean;
  protected
    procedure SetRemotePcActivateInfo;
    procedure SetRemovePcSortInfo;
    procedure SetRemotePcSocket;
  protected
    procedure SetBeMaster;
  end;

    // 连接 Ping
  TConnPingHandle = class( TPingHandle )
  public
    procedure Update;override;
  private
    procedure SendLocalPcInfo;
    procedure SetRemovePcReach;
  protected
    function getMasterConn : string;override;
  end;

    // 接收 Ping
  TAcceptPingHandle = class( TPingHandle )
  private
    RemovePcName : string;
  public
    procedure Update;override;
  protected
    function RevRemovePcInfo : Boolean;
    procedure AddNetworkPc;
    procedure SetRemotePcBeReach;
  end;

  {$EndRegion}

  {$Region ' BeMaster 命令 ' }

    // 连接 BeMaster
  TConnBeMasterHandle = class( TConnHandle )
  public
    procedure Update;override;
  protected
    function getMasterConn : string;override;
  end;

    // 接收 BeMaster
  TAcceptBeMasterHandle = class( TConnHandle )
  public
    procedure Update;override;
  private
    procedure SetBeMaster;
  end;

  {$EndRegion}

  {$Region ' Reach 命令 ' }

      //  Reach 父类
  TReachHandle = class( TConnHandle )
  protected
    procedure SetRemovePcSocketInfo;
    procedure SetRemovePcActivateInfo;
  end;

    // 连接 Reach
  TConnReachHandle = class( TReachHandle )
  public
    procedure Update;override;
  private
    procedure SendReachInfo;
  private
    procedure SetRemovePcReach;
  protected
    function getMasterConn : string;override;
  end;

    // 接受 Reach
  TAcceptReachHandle = class( TReachHandle )
  public
    procedure Update;override;
  private
    function RevReachInfo: boolean;
  private
    procedure SetRemovePcBeReach;
  end;

  {$EndRegion}

  {$Region ' Advance 命令 ' }

      // 接收 Advance
  TAcceptAdvanceHandle = class( TConnHandle )
  private
    ConnPcID, ConnPcName : string;
    ConnLanIp, ConnLanPort : string;
    ConnInternetIp, ConnInternetPort : string;
  private
    AdvancePcMsgStr : string;
  public
    procedure Update;override;
  private
    function RevInternetPcInfoMsg: Boolean;
    procedure FindAdvancePcMsgStr;
    procedure SendPcConnInfo;
  private
    procedure SendAdvancePcMsgStr;
    procedure AddAdvancePcMsgStr;
  end;

  {$EndRegion}


  {$Region ' 连接处理 ' }

    // 连接 并处理 父类
  TConnSendMsgBase = class( TChangeInfo )
  private
    RemotePcID : string;
  protected
    TcpSocket : TCustomIpClient;
  public
    constructor Create;
    procedure SetRemotePcID( _RemotePcID : string );
    procedure Update;override;
    destructor Destroy; override;
  protected
    function CreateConnHandle : TConnHandle;virtual;abstract;
    function ConnTargerPc : Boolean;virtual;abstract;
  protected
    procedure SetConnHandleInfo( ConnHandle : TConnHandle );virtual;
    function ConnTarget( ConnIp, ConnPort : string ) : Boolean;
  end;

    // 局域网 Ping
  TLanConnSendPingMsg = class( TConnSendMsgBase )
  protected
    RemoteLanIp, RemoteLanPort : string;
  public
    procedure SetRemoteLanSocket( _RemoteLanIp, _RemoteLanPort : string );
  protected
    function CreateConnHandle : TConnHandle;override;
    function ConnTargerPc : Boolean;override;
  end;

    // 互联网 命令 父类
  TInternetConnSendMsg = class( TConnSendMsgBase )
  protected
    RemoteLanIp, RemoteLanPort : string;
    RemoteInternetIp, RemoteInternetPort : string;
  protected
    IsLanConn, IsInternetConn : Boolean;
  public
    procedure SetRemoteLanSocket( _RemoteLanIp, _RemoteLanPort : string );
    procedure SetRemoteInternetSocket( _RemoteInternetIp, _RemoteInternetPort : string );
  protected
    procedure SetConnHandleInfo( ConnHandle : TConnHandle );override;
    function ConnLanAndInternet :Boolean;
  end;

    // 互联网 Ping 命令
  TInternetConnSendPingMsg = class( TInternetConnSendMsg )
  protected
    function CreateConnHandle : TConnHandle;override;
    function ConnTargerPc : Boolean;override;
  end;

    // 互联网 Reach 命令
  TInternetConnSendReachMsg = class( TInternetConnSendMsg )
  private
    IsBeReach : Boolean;
  protected
    function CreateConnHandle : TConnHandle;override;
    function ConnTargerPc : Boolean;override;
  end;

    // Be Master
  TConnSendBeMasterMsg = class( TConnSendMsgBase )
  private
    RemoteIp, RemotePort : string;
  public
    procedure SetRemoteSocketInfo( _RemoteIp, _RemotePort : string );
  protected
    function CreateConnHandle : TConnHandle;override;
    function ConnTargerPc : Boolean;override;
  end;

  {$EndRegion}

{$EndRegion}

    // 处理 Conn 命令
  TMyMasterConn = class( TMyChangeBase )
  public
    constructor Create;
  end;

    // 处理 Accept 命令
  TMyMasterAccept = class( TMyChangeBase )
  public
    constructor Create;
  public
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
    procedure RevBroadcastStr( BroadcastStr : string );
  end;

const
  ThreadCount_MasterMsg : Integer = 2;

  MsgType_MasterMsg : string = 'MasterMsg';
  MsgType_MasterMsg_Broadcast : string = 'MasterMsg_Broadcast';
  MsgType_MasterMsg_Ping : string = 'MasterMsg_Ping';
  MsgType_MasterMsg_BackPing : string = 'MasterMsg_BackPing';
  MsgType_MasterMsg_BeMaster : string = 'MasterMsg_BeMaster';
  MsgType_MasterMsg_CheckReach : string = 'MasterMsg_CheckReach';

  MasterConn_Ping = 'Ping';
  MasterConn_BeMaster = 'BeMaster';
  MasterConn_CheckReach = 'CheckReach';
  MasterConn_Advance = 'Advance';

var
  MyMasterConn : TMyMasterConn;
  MyMasterAccept : TMyMasterAccept;

implementation

uses UFormBroadcast, UNetworkFace, UNetPcInfoXml, USettingInfo, USearchServer, UMyClient,
     UNetworkControl;

{ TMyMaster }

constructor TMyMasterConn.Create;
begin
  inherited;
  AddThread( ThreadCount_MasterMsg );
end;

{ TMasterAcceptSocket }

procedure TMasterAcceptSocket.CheckMasterConn(MasterConn: string);
var
  ConnHandle : TConnHandle;
begin
  if MasterConn = MasterConn_Ping then
    ConnHandle := TAcceptPingHandle.Create
  else
  if MasterConn = MasterConn_BeMaster then
    ConnHandle := TAcceptBeMasterHandle.Create
  else
  if MasterConn = MasterConn_CheckReach then
    ConnHandle := TAcceptReachHandle.Create
  else
  if MasterConn = MasterConn_Advance then
    ConnHandle := TAcceptAdvanceHandle.Create;

  ConnHandle.SetTcpSocket( TcpSocket );
  ConnHandle.Update;
  ConnHandle.Free;
end;

procedure TMasterAcceptSocket.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TMasterAcceptSocket.Update;
var
  MasterConn : string;
begin
  MySocketUtil.SendString( TcpSocket, PcInfo.PcID ); // 发送连接成功
  MasterConn := MySocketUtil.RevData( TcpSocket );   // 获取 连接类型
  if MasterConn <> '' then
    CheckMasterConn( MasterConn );
  TcpSocket.Free;
end;

{ TSendBroadcastMsg }

procedure TSendLanBroadcast.Update;
var
  CloudIDNumMD5 : string;
  LanBroadcastMsg : TLanBroadcastMsg;
  MsgInfo : TMsgInfo;
  MsgType, MsgStr, Msg : string;
begin
  CloudIDNumMD5 := CloudSafeSettingInfo.getCloudIDNumMD5;

      // 获取 广播信息
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetPcID( PcInfo.PcID );
  LanBroadcastMsg.SetPcName( PcInfo.PcName );
  LanBroadcastMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  LanBroadcastMsg.SetCloudIDNumMD5( CloudIDNumMD5 );
  MsgStr := LanBroadcastMsg.getMsgStr;
  LanBroadcastMsg.Free;

    // 广播信息的版本
  MsgType := IntToStr( ConnEdition_Now );

    // 包装 广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsgInfo( MsgType, MsgStr );
  Msg := MsgInfo.getMsg;
  MsgInfo.Free;

    // 发送 广播信息
  frmBroadcast.SendMsg( Msg );
end;


{ TLanBroadcastBaseMsg }

procedure TPcInfoMsg.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TPcInfoMsg.SetCloudIDNumMD5(_CloudIDNumMD5: string);
begin
  CloudIDNumMD5 := _CloudIDNumMD5;
end;

procedure TPcInfoMsg.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;


{ TLanBackupPingMsg }

procedure TPcRunInfoMsg.SetRunInfo(_StartTime: TDateTime;
  _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;



{ TRevBroadcastMsg }

procedure TRevLanBroadcast.AddNetworkPc;
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( PcID );
  NetPcAddHandle.SetPcName( PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

function TRevLanBroadcast.CheckBroadcastMsg: Boolean;
var
  MsgInfo : TMsgInfo;
  MsgType, MsgStr : string;
  BroadcastEdition : Integer;
begin
    // 分解广播信息
  MsgInfo := TMsgInfo.Create;
  MsgInfo.SetMsg( BroadcastStr );
  MsgType := MsgInfo.MsgType;
  MsgStr := MsgInfo.MsgStr;
  MsgInfo.Free;

  BroadcastEdition := StrToIntDef( MsgType, 0 );
  LanPcMsgStr := MsgStr;

    // 返回 广播信息 版本号是否正确
  Result := BroadcastEdition = ConnEdition_Now;
end;

procedure TRevLanBroadcast.FindBroadcastMsg;
var
  LanBroadcastMsg : TLanBroadcastMsg;
begin
  LanBroadcastMsg := TLanBroadcastMsg.Create;
  LanBroadcastMsg.SetMsgStr( LanPcMsgStr );
  PcID := LanBroadcastMsg.PcID;
  PcName := LanBroadcastMsg.PcName;
  LanIp := LanBroadcastMsg.Ip;
  LanPort := LanBroadcastMsg.Port;
  CloudIDNumMD5 := LanBroadcastMsg.CloudIDNumMD5;
  LanBroadcastMsg.Free;
end;

procedure TRevLanBroadcast.SendLanPing;
var
  LanConnSendPingMsg : TLanConnSendPingMsg;
begin
  LanConnSendPingMsg := TLanConnSendPingMsg.Create;
  LanConnSendPingMsg.SetRemotePcID( PcID );
  LanConnSendPingMsg.SetRemoteLanSocket( LanIp, LanPort );
  MyMasterConn.AddChange( LanConnSendPingMsg );
end;

procedure TRevLanBroadcast.SetBroadcastStr(_BroadcastStr: string);
begin
  BroadcastStr := _BroadcastStr;
end;

procedure TRevLanBroadcast.Update;
begin
    // 广播信息 不合法
  if not CheckBroadcastMsg then
    Exit;

    // 解释 广播信息
  FindBroadcastMsg;

    // 子网 不同
  if CloudIDNumMD5 <> CloudSafeSettingInfo.getCloudIDNumMD5 then
    Exit;

    // 添加 Pc 信息
  AddNetworkPc;

    // 发 Ping 信息
  SendLanPing;
end;

{ TConnHandle }

procedure TConnHandle.SetLocalSocket(_LocalIp, _LocalPort: string);
begin
  LocalIp := _LocalIp;
  LocalPort := _LocalPort;
end;

procedure TConnHandle.SetRemovePcID(_RemovePcID: string);
begin
  RemovePcID := _RemovePcID;
end;

procedure TConnHandle.SetRemoveSocket(_RemoveIp, _RemovePort: string);
begin
  RemoveIp := _RemoveIp;
  RemovePort := _RemovePort;
end;

procedure TConnHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TConnSendMsgBase }

function TConnSendMsgBase.ConnTarget(ConnIp,
  ConnPort : string): Boolean;
var
  MyTcpConn : TMyTcpConn;
begin
    // 连接对方
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ConnIp, ConnPort );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
    Result := MySocketUtil.RevData( TcpSocket ) = RemotePcID
  else
    Result := False;
  MyTcpConn.Free;
end;

constructor TConnSendMsgBase.Create;
begin
  TcpSocket := TCustomIpClient.Create(nil);
end;

destructor TConnSendMsgBase.Destroy;
begin
  TcpSocket.Free;
  inherited;
end;


procedure TConnSendMsgBase.SetConnHandleInfo( ConnHandle : TConnHandle );
begin
  ConnHandle.SetRemovePcID( RemotePcID );
  ConnHandle.SetTcpSocket( TcpSocket );
end;

procedure TConnSendMsgBase.SetRemotePcID(_RemotePcID: string);
begin
  RemotePcID := _RemotePcID;
end;

procedure TConnSendMsgBase.Update;
var
  ConnHandle : TConnHandle;
begin
    // 连接 Pc 失败
  if not ConnTargerPc then
    Exit;

    // 处理
  ConnHandle := CreateConnHandle;
  SetConnHandleInfo( ConnHandle );
  MySocketUtil.SendString( TcpSocket, ConnHandle.getMasterConn );
  ConnHandle.Update;
  ConnHandle.Free;
end;

{ TPingHandle }

function TPingHandle.RevRemoveIsMaster: Boolean;
var
  MsgStr : string;
  IsMaster : Boolean;
begin
  Result := False;
  MsgStr := MySocketUtil.RevData( TcpSocket );
  if MsgStr = '' then
    Exit;

  IsMaster := StrToBoolDef( MsgStr, False );

  if IsMaster and ( MasterInfo.MasterID = '' ) then
  begin
    MasterInfo.SetMasterInfo( RemovePcID, RemoveIp, RemovePort );
    SetBeMaster;
  end;

  Result := True;
end;

function TPingHandle.RevRemovePcRunInfo: Boolean;
var
  MsgStr : string;
  RemovePcRunInfoMsg : TPcRunInfoMsg;
begin
  Result := False;
  MsgStr := MySocketUtil.RevData( TcpSocket );
  if MsgStr = '' then
    Exit;

  RemovePcRunInfoMsg := TPcRunInfoMsg.Create;
  RemovePcRunInfoMsg.SetMsgStr( MsgStr );
  RemoveStartTime := RemovePcRunInfoMsg.StartTime;
  RemoveRanNum := RemovePcRunInfoMsg.RanNum;
  RemovePcRunInfoMsg.Free;

  SetRemovePcSortInfo;

  Result := True;
end;

procedure TPingHandle.SendLocalIsMaster;
var
  IsMaster : Boolean;
begin
  IsMaster := MasterInfo.MasterID = PcInfo.PcID;
  MySocketUtil.SendString( TcpSocket, BoolToStr( IsMaster ) );
end;

procedure TPingHandle.SendLocalPcRunInfo;
var
  LocalPcRunInfoMsg : TPcRunInfoMsg;
  MsgStr : string;
begin
  LocalPcRunInfoMsg := TPcRunInfoMsg.Create;
  LocalPcRunInfoMsg.SetRunInfo( PcInfo.StartTime, PcInfo.RanNum );
  MsgStr := LocalPcRunInfoMsg.getMsgStr;
  LocalPcRunInfoMsg.Free;

  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TPingHandle.SetRemotePcActivateInfo;
var
  NetPcSetActivateHandle : TNetPcSetActivateHandle;
begin
  NetPcSetActivateHandle := TNetPcSetActivateHandle.Create( RemovePcID );
  NetPcSetActivateHandle.Update;
  NetPcSetActivateHandle.Free;
end;

procedure TPingHandle.SetRemotePcSocket;
var
  NetPcSetSocketHandle : TNetPcSetSocketHandle;
begin
  NetPcSetSocketHandle := TNetPcSetSocketHandle.Create( RemovePcID );
  NetPcSetSocketHandle.SetSocket( RemoveIp, RemovePort );
  NetPcSetSocketHandle.Update;
  NetPcSetSocketHandle.Free;
end;

procedure TPingHandle.SetBeMaster;
var
  NetPcBeMasterHandle : TNetPcBeMasterHandle;
begin
  NetPcBeMasterHandle := TNetPcBeMasterHandle.Create( RemovePcID );
  NetPcBeMasterHandle.Update;
  NetPcBeMasterHandle.Free;
end;

procedure TPingHandle.SetRemovePcSortInfo;
var
  NetPcSetRunInfoHandle : TNetPcSetRunInfoHandle;
begin
    // 设置 选举Master 信息
  NetPcSetRunInfoHandle := TNetPcSetRunInfoHandle.Create( RemovePcID );
  NetPcSetRunInfoHandle.SetSortInfo( RemoveStartTime, RemoveRanNum );
  NetPcSetRunInfoHandle.Update;
  NetPcSetRunInfoHandle.Free;

    // 检查 Master 信息
  if MasterInfo.CheckMax( RemovePcID, RemoveStartTime, RemoveRanNum ) then
    MasterThread.RevMaxMaster;
end;

{ TConnPingHandle }

function TConnPingHandle.getMasterConn: string;
begin
  Result := MasterConn_Ping;
end;

procedure TConnPingHandle.SendLocalPcInfo;
var
  LocalPcInfoMsg : TPcInfoMsg;
  MsgStr : string;
begin
  LocalPcInfoMsg := TPcInfoMsg.Create;
  LocalPcInfoMsg.SetPcID( PcInfo.PcID );
  LocalPcInfoMsg.SetPcName( PcInfo.PcName );
  LocalPcInfoMsg.SetSocketInfo( LocalIp, LocalPort );
  MsgStr := LocalPcInfoMsg.getMsgStr;
  LocalPcInfoMsg.Free;

  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TConnPingHandle.SetRemovePcReach;
var
  NetPcSetReachHandle : TNetPcSetReachHandle;
begin
  NetPcSetReachHandle := TNetPcSetReachHandle.Create( RemovePcID );
  NetPcSetReachHandle.Update;
  NetPcSetReachHandle.Free;
end;

procedure TConnPingHandle.Update;
begin
  SetRemotePcActivateInfo; // 激活
  SetRemovePcReach;  // Reach
  SetRemotePcSocket; // Socket 信息

    // Local Pc
  SendLocalPcInfo;

    // Local Run
  SendLocalPcRunInfo;

    // Remove Run
  if not RevRemovePcRunInfo then
    Exit;

    // Local Master
  SendLocalIsMaster;

    // Remove Master
  RevRemoveIsMaster;
end;

{ TAcceptPingHandle }

procedure TAcceptPingHandle.AddNetworkPc;
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( RemovePcID );
  NetPcAddHandle.SetPcName( RemovePcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

function TAcceptPingHandle.RevRemovePcInfo: Boolean;
var
  MsgStr : string;
  RemovePcInfoMsg : TPcInfoMsg;
begin
  Result := False;
  MsgStr := MySocketUtil.RevData( TcpSocket );
  if MsgStr = '' then
    Exit;

  RemovePcInfoMsg := TPcInfoMsg.Create;
  RemovePcInfoMsg.SetMsgStr( MsgStr );
  RemovePcID := RemovePcInfoMsg.PcID;
  RemovePcName := RemovePcInfoMsg.PcName;
  RemoveIp := RemovePcInfoMsg.Ip;
  RemovePort := RemovePcInfoMsg.Port;
  RemovePcInfoMsg.Free;

  AddNetworkPc;
  SetRemotePcSocket;
  SetRemotePcActivateInfo; // 激活
  SetRemotePcBeReach;

  Result := True;
end;

procedure TAcceptPingHandle.SetRemotePcBeReach;
var
  NetPcSetBeReachHandle : TNetPcSetBeReachHandle;
begin
  NetPcSetBeReachHandle := TNetPcSetBeReachHandle.Create( RemovePcID );
  NetPcSetBeReachHandle.Update;
  NetPcSetBeReachHandle.Free;
end;

procedure TAcceptPingHandle.Update;
begin
  if not RevRemovePcInfo then
    Exit;

  if not RevRemovePcRunInfo then
    Exit;

  SendLocalPcRunInfo;

  if not RevRemoveIsMaster then
    Exit;

  SendLocalIsMaster;
end;

{ TConnBeMasterHandle }

function TConnBeMasterHandle.getMasterConn: string;
begin
  Result := MasterConn_BeMaster;
end;

procedure TConnBeMasterHandle.Update;
begin
  MySocketUtil.SendString( TcpSocket, PcInfo.PcID );
end;

{ TAcceptBeMasterHandle }

procedure TAcceptBeMasterHandle.SetBeMaster;
var
  NetPcBeMasterHandle : TNetPcBeMasterHandle;
begin
  NetPcBeMasterHandle := TNetPcBeMasterHandle.Create( RemovePcID );
  NetPcBeMasterHandle.Update;
  NetPcBeMasterHandle.Free;
end;

procedure TAcceptBeMasterHandle.Update;
var
  MasterIp, MasterPort : string;
begin
  RemovePcID := MySocketUtil.RevData( TcpSocket );
  if RemovePcID = '' then
    Exit;

  if MasterInfo.MasterID = '' then
  begin
    MasterIp := MyNetPcInfoReadUtil.ReadIp( RemovePcID );
    MasterPort := MyNetPcInfoReadUtil.ReadPort( RemovePcID );
    MasterInfo.SetMasterInfo( RemovePcID, MasterIp, MasterPort );
    SetBeMaster;
  end;
end;

{ TConnReachHandle }

function TConnReachHandle.getMasterConn: string;
begin
  Result := MasterConn_CheckReach;
end;

procedure TConnReachHandle.SendReachInfo;
var
  PcReadhInfoMsg : TPcReadhInfoMsg;
  MsgStr : string;
begin
  PcReadhInfoMsg := TPcReadhInfoMsg.Create;
  PcReadhInfoMsg.SetPcID( PcInfo.PcID );
  PcReadhInfoMsg.SetSocketInfo( LocalIp, LocalPort );
  MsgStr := PcReadhInfoMsg.getMsgStr;
  PcReadhInfoMsg.Free;

  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TConnReachHandle.SetRemovePcReach;
var
  NetPcSetReachHandle : TNetPcSetReachHandle;
begin
  NetPcSetReachHandle := TNetPcSetReachHandle.Create( RemovePcID );
  NetPcSetReachHandle.Update;
  NetPcSetReachHandle.Free;
end;

procedure TConnReachHandle.Update;
begin
  SetRemovePcSocketInfo;
  SetRemovePcActivateInfo;
  SetRemovePcReach;

  SendReachInfo;
end;

{ TPcInfoBaseMsg }

procedure TPcInfoBaseMsg.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPcInfoBaseMsg.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TReachHandle }

procedure TReachHandle.SetRemovePcActivateInfo;
var
  NetPcSetActivateHandle : TNetPcSetActivateHandle;
begin
  NetPcSetActivateHandle := TNetPcSetActivateHandle.Create( RemovePcID );
  NetPcSetActivateHandle.Update;
  NetPcSetActivateHandle.Free;
end;

procedure TReachHandle.SetRemovePcSocketInfo;
var
  NetPcSetSocketHandle : TNetPcSetSocketHandle;
begin
  NetPcSetSocketHandle := TNetPcSetSocketHandle.Create( RemovePcID );
  NetPcSetSocketHandle.SetSocket( RemoveIp, RemovePort );
  NetPcSetSocketHandle.Update;
  NetPcSetSocketHandle.Free;
end;

{ TAcceptReachHandle }

function TAcceptReachHandle.RevReachInfo: boolean;
var
  MsgStr : string;
  PcReachInfoMsg : TPcReadhInfoMsg;
begin
  Result := False;
  MsgStr := MySocketUtil.RevData( TcpSocket );
  if MsgStr = '' then
    Exit;

  PcReachInfoMsg := TPcReadhInfoMsg.Create;
  PcReachInfoMsg.SetMsgStr( MsgStr );
  RemovePcID := PcReachInfoMsg.PcID;
  RemoveIp := PcReachInfoMsg.Ip;
  RemovePort := PcReachInfoMsg.Port;
  PcReachInfoMsg.Free;

  SetRemovePcSocketInfo;
  SetRemovePcActivateInfo;
  SetRemovePcBeReach;

  Result := True;
end;

procedure TAcceptReachHandle.SetRemovePcBeReach;
var
  NetPcSetBeReachHandle : TNetPcSetBeReachHandle;
begin
  NetPcSetBeReachHandle := TNetPcSetBeReachHandle.Create( RemovePcID );
  NetPcSetBeReachHandle.Update;
  NetPcSetBeReachHandle.Free;
end;

procedure TAcceptReachHandle.Update;
begin
  RevReachInfo;
end;


{ TMyMasterAccept }

procedure TMyMasterAccept.AcceptSocket(TcpSocket: TCustomIpClient);
var
  MasterAcceptSocket : TMasterAcceptSocket;
begin
  MasterAcceptSocket := TMasterAcceptSocket.Create;
  MasterAcceptSocket.SetTcpSocket( TcpSocket );
  AddChange( MasterAcceptSocket );
end;

procedure TMyMasterAccept.RevBroadcastStr(BroadcastStr: string);
var
  RevLanBroadcast : TRevLanBroadcast;
begin
  RevLanBroadcast := TRevLanBroadcast.Create;
  RevLanBroadcast.SetBroadcastStr( BroadcastStr );

  AddChange( RevLanBroadcast );
end;

constructor TMyMasterAccept.Create;
begin
  inherited Create;
  AddThread( ThreadCount_MasterMsg );
end;

{ TInternetPcInfoMsg }

constructor TInternetPcInfoMsg.SetnternetSocketInfo(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

{ TAcceptAdvanceHandle }


procedure TAcceptAdvanceHandle.AddAdvancePcMsgStr;
var
  AdvancePcInfo : TAdvancePcInfo;
begin
  MasterThread.AdvanceLock.Enter;
  AdvancePcInfo := TAdvancePcInfo.Create( ConnPcID, AdvancePcMsgStr );
  MasterThread.AdvancePcHash.AddOrSetValue( ConnPcID, AdvancePcInfo );
  MasterThread.AdvanceLock.Leave;
end;

procedure TAcceptAdvanceHandle.FindAdvancePcMsgStr;
var
  AdvancePcConnMsg : TAdvancePcConnMsg;
begin
  AdvancePcConnMsg := TAdvancePcConnMsg.Create;
  AdvancePcConnMsg.SetConnPcInfo( ConnPcID, ConnPcName );
  AdvancePcConnMsg.SetLanSocket( ConnLanIp, ConnLanPort );
  AdvancePcConnMsg.SetInternetSocket( ConnInternetIp, ConnInternetPort );
  AdvancePcMsgStr := AdvancePcConnMsg.getMsg;
  AdvancePcConnMsg.Free;
end;

function TAcceptAdvanceHandle.RevInternetPcInfoMsg: Boolean;
var
  MsgStr : string;
  CloudIDNumMD5 : string;
  InternetPcInfoMsg : TInternetPcInfoMsg;
begin
  Result := False;

  MsgStr := MySocketUtil.RevData( TcpSocket );
  if MsgStr = '' then
    Exit;

  InternetPcInfoMsg := TInternetPcInfoMsg.Create;
  InternetPcInfoMsg.SetMsgStr( MsgStr );
  ConnPcID := InternetPcInfoMsg.PcID;
  ConnPcName := InternetPcInfoMsg.PcName;
  ConnLanIp := InternetPcInfoMsg.Ip;
  ConnLanPort := InternetPcInfoMsg.Port;
  ConnInternetIp := InternetPcInfoMsg.InternetIp;
  ConnInternetPort := InternetPcInfoMsg.InternetPort;
  CloudIDNumMD5 := InternetPcInfoMsg.CloudIDNumMD5;
  InternetPcInfoMsg.Free;

    // 是否 同一个 CloudNumber
  Result := CloudIDNumMD5 = CloudSafeSettingInfo.getCloudIDNumMD5;
end;

procedure TAcceptAdvanceHandle.SendAdvancePcMsgStr;
begin
  MyClient.SendMsgToAll( AdvancePcMsgStr );
end;

procedure TAcceptAdvanceHandle.SendPcConnInfo;
var
  MsgStr : string;
  InternetPcInfoMsg : TInternetPcInfoMsg;
begin
    // 如果是Server就发送本机的连接信息
  if MyClient.IsConnServer and ( MasterInfo.MasterID = PcInfo.PcID ) then
  begin
    InternetPcInfoMsg := TInternetPcInfoMsg.Create;
    InternetPcInfoMsg.SetPcID( PcInfo.PcID );
    InternetPcInfoMsg.SetPcName( PcInfo.PcName );
    InternetPcInfoMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
    InternetPcInfoMsg.SetnternetSocketInfo( PcInfo.InternetIp, PcInfo.InternetPort );
    InternetPcInfoMsg.SetCloudIDNumMD5( CloudSafeSettingInfo.getCloudIDNumMD5 );
    MsgStr := InternetPcInfoMsg.getMsgStr;
    InternetPcInfoMsg.Free;
  end
  else
    MsgStr := AdvanceMsg_NotServer;

  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TAcceptAdvanceHandle.Update;
begin
  if not RevInternetPcInfoMsg then
    Exit;

  FindAdvancePcMsgStr;

  if MyClient.IsConnServer then
    SendAdvancePcMsgStr
  else
    AddAdvancePcMsgStr;

  SendPcConnInfo;
end;

{ TLanConnSendPingMsg }

function TLanConnSendPingMsg.ConnTargerPc: Boolean;
begin
  Result := ConnTarget( RemoteLanIp, RemoteLanPort );
end;

function TLanConnSendPingMsg.CreateConnHandle: TConnHandle;
begin
  Result := TConnPingHandle.Create;
  Result.SetLocalSocket( PcInfo.LanIp, PcInfo.LanPort );
  Result.SetRemoveSocket( RemoteLanIp, RemoteLanPort );
end;


procedure TLanConnSendPingMsg.SetRemoteLanSocket(_RemoteLanIp,
  _RemoteLanPort: string);
begin
  RemoteLanIp := _RemoteLanIp;
  RemoteLanPort := _RemoteLanPort;
end;

{ TLanConnSendBeMasterMsg }

function TConnSendBeMasterMsg.ConnTargerPc: Boolean;
begin
  Result := ConnTarget( RemoteIp, RemotePort );
end;

function TConnSendBeMasterMsg.CreateConnHandle: TConnHandle;
begin
  Result := TConnBeMasterHandle.Create;
end;

{ TInternetConnSendMsg }

function TInternetConnSendMsg.ConnLanAndInternet: Boolean;
begin
  IsLanConn := False;
  IsInternetConn := False;

    // 简单地判断是否同一网段
  if not MyParseHost.CheckIpLan( RemoteLanIp, PcInfo.LanIp ) then
    IsInternetConn := ConnTarget( RemoteInternetIp, RemoteInternetPort )
  else
  begin
    if ConnTarget( RemoteLanIp, RemoteLanPort ) then
      IsLanConn := True
    else
    if ConnTarget( RemoteInternetIp, RemoteInternetPort ) then
      IsInternetConn := True;
  end;

  Result := IsLanConn or IsInternetConn;
end;

procedure TInternetConnSendMsg.SetConnHandleInfo(ConnHandle: TConnHandle);
begin
  inherited;

  if IsLanConn then
  begin
    ConnHandle.SetLocalSocket( PcInfo.LanIp, PcInfo.LanPort );
    ConnHandle.SetRemoveSocket( RemoteLanIp, RemoteLanPort );
  end
  else
  begin
    ConnHandle.SetLocalSocket( PcInfo.InternetIp, PcInfo.InternetPort );
    ConnHandle.SetRemoveSocket( RemoteInternetIp, RemoteInternetPort );
  end;
end;

procedure TInternetConnSendMsg.SetRemoteInternetSocket(_RemoteInternetIp,
  _RemoteInternetPort: string);
begin
  RemoteInternetIp := _RemoteInternetIp;
  RemoteInternetPort := _RemoteInternetPort;
end;

procedure TInternetConnSendMsg.SetRemoteLanSocket(_RemoteLanIp,
  _RemoteLanPort: string);
begin
  RemoteLanIp := _RemoteLanIp;
  RemoteLanPort := _RemoteLanPort;
end;

{ TInternetConnSendPingMsg }

function TInternetConnSendPingMsg.ConnTargerPc: Boolean;
begin
  Result := ConnLanAndInternet;
end;

function TInternetConnSendPingMsg.CreateConnHandle: TConnHandle;
begin
  Result := TConnPingHandle.Create;
end;

{ TInternetConnSendReachMsg }

function TInternetConnSendReachMsg.ConnTargerPc: Boolean;
begin
  Result := ConnLanAndInternet;
end;

function TInternetConnSendReachMsg.CreateConnHandle: TConnHandle;
begin
  Result := TConnReachHandle.Create;
end;

procedure TConnSendBeMasterMsg.SetRemoteSocketInfo(_RemoteIp,
  _RemotePort: string);
begin
  RemoteIp := _RemoteIp;
  RemotePort := _RemotePort;
end;

end.

