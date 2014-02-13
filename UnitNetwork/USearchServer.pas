unit USearchServer;

interface

uses classes, UMyNetPcInfo, UModelUtil, Sockets, UMyTcp, SysUtils, DateUtils, Generics.Collections,
     IdHTTP, UMyUrl, SyncObjs, UPortMap;

type

{$Region ' 搜索网络 运行 ' }

    // 搜索网路 父类
  TSearchServerRun = class
  protected
    NetworkModeInfo : TNetworkModeInfo;
  public
    procedure SetNetworkModeInfo( _NetworkModeInfo : TNetworkModeInfo );
    procedure Update;virtual;abstract;
    class function get( NetworkModeType : string ): TSearchServerRun;
    function getIsRemoteCompleted : Boolean;virtual;
  protected
    procedure ExtractInfo;virtual;
  end;

  {$Region ' 局域网 ' }

    // 搜索 局域网 的服务器
  TLanSearchServer = class( TSearchServerRun )
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' Group 网络 ' }

    // Standard Pc Info
  TStandardPcInfo = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
    InternetIp, InternetPort : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
  end;
  TStandardPcPair = TPair< string , TStandardPcInfo >;
  TStandardPcHash = class(TStringDictionary< TStandardPcInfo >);

      // 发送公司网请求
  TFindStandardNetworkHttp = class
  private
    CompanyName, Password : string;
    Cmd : string;
  public
    constructor Create( _CompanyName, _Password : string );
    procedure SetCmd( _Cmd : string );
    function get : string;
  end;

    // HearBeat
  TStandardHearBetThread = class( TThread )
  private
    AccountName, Password : string;
    LastServerNumber : Integer;
  public
    constructor Create;
    procedure SetAccountInfo( _AccountName, _Password : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SendHeartBeat;
    procedure CheckAccountPc;
  end;

    // 找到 一个 Standard Pc
  TStandardPcAddHanlde = class
  private
    StandardPcInfo : TStandardPcInfo;
  public
    constructor Create( _StandardPcInfo : TStandardPcInfo );
    procedure Update;
  private
    procedure AddNetworkPc;
    procedure AddPingMsg;
  end;

    // 搜索 Account Name 的服务器
  TStandSearchServer = class( TSearchServerRun )
  private
    AccountName : string;
    Password : string;
  private
    StandardPcMsg : string;
    StandardPcHash : TStandardPcHash;
  private
    WaitTime : Integer;
  private
    IsRemoteCompleted : Boolean;
    StandardHearBetThread : TStandardHearBetThread;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  private
    function LoginAccount : Boolean;
    procedure FindStandardPcHash;
    procedure PingStandardPcHash;
    procedure LogoutAccount;
  private
    procedure PingMyPc;
    procedure PasswordError;
    procedure AccountNameNotExit;
  protected
    procedure ExtractInfo;override;
  public
    function getIsRemoteCompleted : Boolean;override;
  end;

  {$EndRegion}

  {$Region ' 直连网络 ' }

    // Advace Req Pc Info
  TAdvancePcInfo = class
  public
    PcID : string;
    PcInfoMsgStr : string;
  public
    constructor Create( _PcID, _PcInfoMsgStr : string );
  end;
  TAdvancePcPair = TPair< string , TAdvancePcInfo >;
  TAdvancePcHash = class(TStringDictionary< TAdvancePcInfo >);

    // 搜索 Internet Pc 的服务器
  TAdvanceSearchServer = class( TSearchServerRun )
  private
    Domain : string;
    Ip, Port : string;
  private
    TcpSocket : TCustomIpClient;
  private
    IsRemoteCompleted : Boolean;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure PingMyPc;
    function FindIp: Boolean;
    function ConnTargetPc : Boolean;
    procedure SendInternetPcInfoMsg;
    procedure RevConnPcInfoMsg;
  private       // 等待重启网络
    procedure RestartNetwork;
  protected
    procedure ExtractInfo;override;
  public
    function getIsRemoteCompleted : Boolean;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 搜索网络 运行结果处理 ' }

  {$Region ' Rester Network ' }

  TFindInternetSocket = class
  private
    PortMapping : TPortMapping;
    InternetIp, InternetPort : string;
  public
    constructor Create( _PortMapping : TPortMapping );
    procedure Update;
  private
    function FindInternetIp: Boolean;
    procedure FindInternetPort;
  private
    function FindRouterInternetIp: Boolean;
    function FindWebInternetIp: Boolean;
    procedure SetInternetFace;
  end;

  TRestartNetworkHandle = class
  public
    procedure Update;
  private
    procedure ClearRedirectJob;
    procedure ClearTransferFace;
    procedure ClearCsNetwork;
    procedure ClearNetworkPcInfo;
    procedure ClearNetworkPcFace;
  private
    procedure ClearSearch;
    procedure ClearRestore;
    procedure ClearFileTransfer;
    procedure ClearFileShare;
  private
    procedure LostServerFace;
  end;

  {$EndRegion}

  {$Region ' Be Server ' }

  TNetPcSocket = class
  public
    PcID : string;
    Ip, Port : string;
  public
    constructor Create( _PcID : string );
    procedure SetSocketInfo( _Ip, _Port : string );
  end;
  TNetPcSocketList = class( TObjectList<TNetPcSocket> );

  TBeServerHandle = class
  private
    NetPcSocketList : TNetPcSocketList;
  public
    constructor Create;
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindNetPcSocketList;
    procedure SendBeMasterMsg;
  end;

  {$EndRegion}

  {$Region ' Conn Server ' }

  TConnServerHandle = class
  private
    ServerIp, ServerPort : string;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _ServerIp, _ServerPort : string );
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    function get: Boolean;
  private
    function ConnServer: Boolean;
    procedure SendPcOnline;
    procedure SendMyCloudPcInfo;
    procedure SendAdvancePcMsg;
  private
    procedure ConnServerFace;
    procedure CheckTransferAndSharePcExist;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 等待 Server 线程 ' }

    // 定时 做 PortMapping
  TPortMappingThread = class( TThread )
  private
    LanIp, LanPort : string;
    InternetPort : string;
  private
    PortMapping : TPortMapping;
  public
    constructor Create( _LanIp, _LanPort : string );
    procedure SetPortMapping( _PortMapping : TPortMapping );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // 重启网络线程
  TRestartNetworkThread = class( TThread )
  private
    StartTime : TDateTime;
    IsRestart : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure RunRestart;
    procedure ShowRemainTime;
    procedure StopRestart;
  private
    procedure RestartNetwork;
  end;

    // 搜索 服务器
  TMasterThread = class( TThread )
  private
    IsRestartMaster : Boolean;  // 是否重新选择 Master
  private
    WaitPingTime : Integer;  // 与其他Pc交换信息的时间
    WaitServerNotifyTime : Integer; // 等待服务器通知的时间
  private
    PortMapping : TPortMapping;
    PortMappingThread : TPortMappingThread; // 定时 PortMap
  public
    AdvanceLock : TCriticalSection;  // 其他 Pc Advance
    AdvancePcHash : TAdvancePcHash;
  private
    SearchServerRun : TSearchServerRun; // 运行网络
    RestartNetworkThread : TRestartNetworkThread; // 定时重启网络
  public
    constructor Create;
    procedure RestartNetwork;
    procedure SetWaitPingTime( _WaitPingTime : Integer );
    procedure RevMaxMaster;
    procedure RunRestartThread;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure ResetNetworkPc;
    procedure AddPortMaping;
    procedure RunNetwork;
    procedure WaitPingMsg;
    procedure BeServer;
    procedure WaitServerNotify;
    function ConnServer: Boolean;
    procedure StopNetwork;
    procedure RemovePortMapping;
  private
    procedure SetLanMaster;
    procedure ResetLanMaster;
  end;

{$EndRegion}

const
  Count_SearchServerThread : Integer = 10;

  MsgType_Ping : string = 'Ping';
  MsgType_BackPing : string = 'BackPing';

    // Standard Network Http 连接类型
  Cmd_Login = 'login';
  Cmd_HeartBeat = 'heartbeat';
  Cmd_ReadLoginNumber = 'readloginnumber';
  Cmd_AddServerNumber = 'addservernumber';
  Cmd_ReadServerNumber = 'readservernumber';
  Cmd_Logout = 'logout';

    // Standard Network Http 参数
  HttpReq_CompanyName = 'CompanyName';
  HttpReq_Password = 'Password';
  HttpReq_PcID = 'PcID';
  HttpReq_PcName = 'PcName';
  HttpReq_LanIp = 'LanIp';
  HttpReq_LanPort = 'LanPort';
  HttpReq_InternetIp = 'InternetIp';
  HttpReq_InternetPort = 'InternetPort';
  HttpReq_CloudIDNumber = 'CloudIDNumber';

    // Login 结果
  LoginResult_ConnError = 'ConnError';
  LoginResult_CompanyNotFind = 'CompanyNotFind';
  LoginResult_PasswordError = 'PasswordError';
  LoginResult_OK = 'OK';

    // Resutl Split
  Split_Result = '<Result/>';
  Split_Pc = '<Pc/>';
  Split_PcPro = '<PcPro/>';

  PcProCount = 6;
  PcPro_PcID = 0;
  PcPro_PcName = 1;
  PcPro_LanIp = 2;
  PcPro_LanPort = 3;
  PcPro_InternetIp = 4;
  PcPro_InternetPort = 5;

//  ShowForm_CompanyNameError : string = 'Account name "%s" does not exist.';
//  ShowForm_PasswordError : string = 'Password is incorrect.Please input password again.';
//  ShowForm_ParseError : string = 'Can not parse "%s" to ip address.';

  WaitTime_LAN : Integer = 5;
  WaitTime_Standard : Integer = 20;
  WaitTime_Advance : Integer = 30;

  WaitTime_MyPc : Integer = 2;
  WaitTime_ServerNofity : Integer = 15;

  WaitTime_PortMap = 10; // 分钟

  AdvanceMsg_NotServer = 'NotServer'; // 非服务器
var
  MasterThread : TMasterThread;  // 等待 Server 线程

implementation

uses UNetworkControl, UFormBroadcast, UNetworkFace, UMyUtil, UMyMaster, UMyClient, UMyServer,
     UBackupInfoFace, USettingInfo, UMyFileSearch, UJobFace, uDebug, UNetPcInfoXml,
     USearchFileFace, UFileTransferFace, UMyShareControl, UMyShareFace, UMyJobInfo, UChangeInfo,
     UMainForm;

{ TSearchServerThread }

procedure TMasterThread.AddPortMaping;
var
  FindInternetSocket : TFindInternetSocket;
begin
  FindInternetSocket := TFindInternetSocket.Create( PortMapping );
  FindInternetSocket.Update;
  FindInternetSocket.Free;

    // 定时 PortMap
  if PortMapping.IsPortMapable then
  begin
    PortMappingThread := TPortMappingThread.Create( PcInfo.LanIp, PcInfo.LanPort );
    PortMappingThread.SetPortMapping( PortMapping );
    PortMappingThread.Resume;
  end;
end;

procedure TMasterThread.BeServer;
var
  BeServerHandle : TBeServerHandle;
begin
  if Terminated or IsRestartMaster then
    Exit;

    // 程序结束
    // 其他人 成为 Server
    // 其他人 比较值最大
  if Terminated or ( MasterInfo.MasterID <> '' ) or
     ( MasterInfo.MaxPcID <> PcInfo.PcID )
  then
    Exit;

    // 成为服务器的处理
  BeServerHandle := TBeServerHandle.Create;
  BeServerHandle.Update;
  BeServerHandle.Free;
end;

function TMasterThread.ConnServer: Boolean;
var
  Ip, Port : string;
  TcpSocket : TCustomIpClient;
  ConnServerHandle : TConnServerHandle;
begin
  Result := False;
  if Terminated or IsRestartMaster then
    Exit;

  Ip := MasterInfo.MasterIp;
  Port := MasterInfo.MasterPort;
  TcpSocket := MyClient.TcpSocket;

  ConnServerHandle := TConnServerHandle.Create( Ip, Port );
  ConnServerHandle.SetTcpSocket( TcpSocket );
  Result := ConnServerHandle.get;
  ConnServerHandle.Free;

  if Terminated or IsRestartMaster then
    Result := False;
end;

constructor TMasterThread.Create;
begin
  inherited Create( True );

  AdvanceLock := TCriticalSection.Create;
  AdvancePcHash := TAdvancePcHash.Create;

  WaitPingTime := WaitTime_LAN;
  WaitServerNotifyTime := WaitTime_ServerNofity;
  IsRestartMaster := True;

  RestartNetworkThread := TRestartNetworkThread.Create;
  RestartNetworkThread.Resume;
end;

procedure TMasterThread.SetLanMaster;
begin
  if MasterInfo.MasterID <> PcInfo.PcID then
    Exit;
end;

procedure TMasterThread.SetWaitPingTime(_WaitPingTime: Integer);
begin
  WaitPingTime := _WaitPingTime;
end;

procedure TMasterThread.StopNetwork;
begin
  SearchServerRun.Free;
  RestartNetworkThread.StopRestart;
  MyListener.StopListen;
end;

destructor TMasterThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  RestartNetworkThread.Free;
  AdvancePcHash.Free;
  AdvanceLock.Free;
  inherited;
end;

procedure TMasterThread.Execute;
begin
  PortMapping := TPortMapping.Create;

  while not Terminated do
  begin
      // 初始化
    ResetNetworkPc;

      // 添加 端口映射 Interenet 操作
    AddPortMaping;

      // 运行网络
    RunNetwork;

      // 等待 与其他 Pc 交互信息
    WaitPingMsg;

      // 成为服务器
    BeServer;

      // 等待 Server 通知
    WaitServerNotify;

      // 连接服务器成功, 挂起线程
    if ConnServer then
    begin
      MyClient.StartHeartBeat;
      Suspend;
      MyClient.StopHeartBeat;
    end;

      // 停止运行网络
    StopNetwork;

      // 移除 端口映射
    RemovePortMapping;
  end;

  PortMapping.Free;
  inherited;
end;

procedure TMasterThread.RunNetwork;
var
  IsRemoteCompleted : Boolean;
  PmNetworkOpenChangeInfo : TPmNetworkOpenChangeInfo;
  PmNetworkReturnLocalNetwork : TPmNetworkReturnLocalNetwork;
begin
    // 开始监听
  MyListener.StartListen( PcInfo.LanPort );

    // 运行网络
  SearchServerRun := TSearchServerRun.get( NetworkModeInfo.getNetworkMode );
  SearchServerRun.SetNetworkModeInfo( NetworkModeInfo );
  SearchServerRun.Update;
  IsRemoteCompleted := SearchServerRun.getIsRemoteCompleted;

    // 可以改变网络
  PmNetworkOpenChangeInfo := TPmNetworkOpenChangeInfo.Create;
  MyNetworkFace.AddChange( PmNetworkOpenChangeInfo );

    // 可以重启网路
  IsRestartMaster := False;

    // 远程 登录失败,  返回本地网络
  if not IsRemoteCompleted then
  begin
    PmNetworkReturnLocalNetwork := TPmNetworkReturnLocalNetwork.Create;
    MyNetworkFace.AddChange( PmNetworkReturnLocalNetwork );
  end;
end;

procedure TMasterThread.RunRestartThread;
begin
  RestartNetworkThread.RunRestart;
end;

procedure TMasterThread.RemovePortMapping;
begin
  if PortMapping.IsPortMapable then
    PortMappingThread.Free;
end;

procedure TMasterThread.ResetLanMaster;
begin
  if MasterInfo.MasterID <> PcInfo.PcID then
    Exit;
end;

procedure TMasterThread.ResetNetworkPc;
var
  RestartNetworkHandle : TRestartNetworkHandle;
begin
  RestartNetworkHandle := TRestartNetworkHandle.Create;
  RestartNetworkHandle.Update;
  RestartNetworkHandle.Free;
end;

procedure TMasterThread.RestartNetwork;
var
  PmNetworkCloseChangeInfo : TPmNetworkCloseChangeInfo;
begin
  PmNetworkCloseChangeInfo := TPmNetworkCloseChangeInfo.Create;
  MyNetworkFace.AddChange( PmNetworkCloseChangeInfo );

  IsRestartMaster := True;
  Resume;
end;

procedure TMasterThread.RevMaxMaster;
begin
  WaitServerNotifyTime := WaitServerNotifyTime + WaitServerNotifyTime;
end;

procedure TMasterThread.WaitPingMsg;
var
  StartTime : TDateTime;
  Count : Integer;
  SbMyStatusConningInfo : TSbMyStatusConningInfo;
begin
  Count := 0;
  StartTime := Now;
  while not Terminated and ( MasterInfo.MasterID = '' ) and
        ( SecondsBetween( Now, StartTime ) < WaitPingTime ) and
        not IsRestartMaster
  do
  begin
    Sleep( 100 );

    inc( Count );
    if Count = 10 then
    begin
      SbMyStatusConningInfo := TSbMyStatusConningInfo.Create;
      MyNetworkFace.AddChange( SbMyStatusConningInfo );

      Count := 0;
    end;
  end;
end;

procedure TMasterThread.WaitServerNotify;
var
  StartTime : TDateTime;
  Count : Integer;
  SbMyStatusConningInfo : TSbMyStatusConningInfo;
begin
  Count := 0;
  StartTime := Now;
  while not Terminated and ( MasterInfo.MasterID = '' ) and
        ( SecondsBetween( Now, StartTime ) < WaitServerNotifyTime ) and
        not IsRestartMaster
  do
  begin
    Sleep( 100 );

    inc( Count );
    if Count = 10 then
    begin
      SbMyStatusConningInfo := TSbMyStatusConningInfo.Create;
      MyNetworkFace.AddChange( SbMyStatusConningInfo );

      Count := 0;
    end;
  end;
end;


{ TLanSearchServer }

constructor TLanSearchServer.Create;
begin
    // 开启 广播
  frmBroadcast.OnRevMsgEvent := MyMasterAccept.RevBroadcastStr;
end;

destructor TLanSearchServer.Destroy;
begin
  frmBroadcast.OnRevMsgEvent := nil; // 关广播
  inherited;
end;

procedure TLanSearchServer.Update;
var
  SendBroadcastMsg : TSendLanBroadcast;
begin
    // 获取 广播命令
  SendBroadcastMsg := TSendLanBroadcast.Create;

    // 发送 广播命令
  MyMasterConn.AddChange( SendBroadcastMsg );

    // 设置等待时间
  MasterThread.SetWaitPingTime( WaitTime_LAN );
end;

{ TSearchServerBase }

procedure TSearchServerRun.ExtractInfo;
begin

end;

class function TSearchServerRun.get(
  NetworkModeType: string): TSearchServerRun;
begin
  if NetworkModeType = NetworkMode_LAN then
    Result := TLanSearchServer.Create
  else
  if NetworkModeType = NetworkMode_Standard then
    Result := TStandSearchServer.Create
  else
  if NetworkModeType = NetworkMode_Advance then
    Result := TAdvanceSearchServer.Create;
end;

function TSearchServerRun.getIsRemoteCompleted: Boolean;
begin
  Result := True;
end;

procedure TSearchServerRun.SetNetworkModeInfo(
  _NetworkModeInfo: TNetworkModeInfo);
begin
  NetworkModeInfo := _NetworkModeInfo;
  ExtractInfo;
end;

{ TStandSearchServer }

procedure TStandSearchServer.AccountNameNotExit;
var
  ErrorStr : string;
  StandardAccountError : TStandardAccountError;
begin
  ErrorStr := Format( frmMainForm.siLang_frmMainForm.GetText( 'GroupNameError' ), [AccountName] );
  MyMessageBox.ShowError( ErrorStr );

  StandardAccountError := TStandardAccountError.Create( AccountName );
  StandardAccountError.SetPassword( Password );
  MyNetworkFace.AddChange( StandardAccountError );
end;

constructor TStandSearchServer.Create;
begin
  StandardPcHash := TStandardPcHash.Create;
  StandardHearBetThread := TStandardHearBetThread.Create;
  IsRemoteCompleted := True;
end;

destructor TStandSearchServer.Destroy;
begin
  StandardHearBetThread.Free;
  StandardPcHash.Free;
  LogoutAccount; // Logout
  inherited;
end;

procedure TStandSearchServer.ExtractInfo;
var
  StandardNetworkMode : TStandardNetworkMode;
begin
  inherited;

  StandardNetworkMode := ( NetworkModeInfo as TStandardNetworkMode );
  AccountName := StandardNetworkMode.AccountName;
  Password := StandardNetworkMode.Password;
  StandardHearBetThread.SetAccountInfo( AccountName, Password );
end;

procedure TStandSearchServer.FindStandardPcHash;
var
  PcStrList : TStringList;
  PcProStrList : TStringList;
  i : Integer;
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  StandardPcInfo : TStandardPcInfo;
begin
  PcStrList := MySplitStr.getList( StandardPcMsg, Split_Pc );
  for i := 0 to PcStrList.Count - 1 do
  begin
    PcProStrList := MySplitStr.getList( PcStrList[i], Split_PcPro );
    if PcProStrList.Count = PcProCount then
    begin
      PcID := PcProStrList[ PcPro_PcID ];
      PcName := PcProStrList[ PcPro_PcName ];
      LanIp := PcProStrList[ PcPro_LanIp ];
      LanPort := PcProStrList[ PcPro_LanPort ];
      InternetIp := PcProStrList[ PcPro_InternetIp ];
      InternetPort := PcProStrList[ PcPro_InternetPort ];

      StandardPcInfo := TStandardPcInfo.Create( PcID, PcName );
      StandardPcInfo.SetLanSocket( LanIp, LanPort );
      StandardPcInfo.SetInternetSocket( InternetIp, InternetPort );

      StandardPcHash.AddOrSetValue( PcID, StandardPcInfo );
    end;
    PcProStrList.Free;
  end;
  PcStrList.Free;
end;

function TStandSearchServer.getIsRemoteCompleted: Boolean;
begin
  Result := IsRemoteCompleted;
end;

function TStandSearchServer.LoginAccount: Boolean;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
  HttpStr, HttpResult : string;
  HttpStrList : TStringList;
begin
  Result := False;

    // 登录
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Login );
  HttpStr := FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;

    // 是否登录远程网络失败
  IsRemoteCompleted := False;
    // 网络连接 断开
  if HttpStr = LoginResult_ConnError then
  else  // 帐号不存在
  if HttpStr = LoginResult_CompanyNotFind then
    AccountNameNotExit
  else   // 密码错误
  if HttpStr = LoginResult_PasswordError then
    PasswordError
  else
  begin   // 登录成功
    IsRemoteCompleted := True;
    HttpStrList := MySplitStr.getList( HttpStr, Split_Result );
    if HttpStrList.Count > 0 then
      HttpResult := HttpStrList[0];
    if HttpResult = LoginResult_OK then
    begin
      if HttpStrList.Count > 1 then
        StandardPcMsg := HttpStrList[1];
      Result := True;
    end;
    HttpStrList.Free;
  end;
end;

procedure TStandSearchServer.LogoutAccount;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // Logout
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_Logout );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TStandSearchServer.PasswordError;
var
  StandardPasswordError : TStandardPasswordError;
begin
  MyMessageBox.ShowError( frmMainForm.siLang_frmMainForm.GetText( 'GroupPasswordError' ) );

  StandardPasswordError := TStandardPasswordError.Create( AccountName );
  MyNetworkFace.AddChange( StandardPasswordError );
end;

procedure TStandSearchServer.PingMyPc;
var
  LanConnSendPingMsg : TLanConnSendPingMsg;
begin
  LanConnSendPingMsg := TLanConnSendPingMsg.Create;
  LanConnSendPingMsg.SetRemotePcID( PcInfo.PcID );
  LanConnSendPingMsg.SetRemoteLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  MyMasterConn.AddChange( LanConnSendPingMsg );
end;

procedure TStandSearchServer.PingStandardPcHash;
var
  p : TStandardPcPair;
  StandardPcAddHanlde : TStandardPcAddHanlde;
begin
  for p in StandardPcHash do
  begin
    StandardPcAddHanlde := TStandardPcAddHanlde.Create( p.Value );
    StandardPcAddHanlde.Update;
    StandardPcAddHanlde.Free;
  end;

  if StandardPcHash.Count <= 1 then
    WaitTime := WaitTime_MyPc
  else
    WaitTime := WaitTime_Standard;
end;

procedure TStandSearchServer.Update;
begin
  if LoginAccount then
  begin
    FindStandardPcHash;
    PingStandardPcHash;
  end
  else
  begin
    WaitTime := WaitTime_MyPc;
    PingMyPc;
  end;

  StandardHearBetThread.Resume;
  MasterThread.SetWaitPingTime( WaitTime );
end;

{ TAdvanceSearchServer }

function TAdvanceSearchServer.ConnTargetPc: Boolean;
var
  MyTcpConn : TMyTcpConn;
  NetworkLvAddInfo : TLvNetworkAdd;
begin
  Result := False;

  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( Ip, Port );
  MyTcpConn.SetConnType( ConnType_SearchServer );
  if MyTcpConn.Conn then
  begin
    if MySocketUtil.RevData( TcpSocket ) <> '' then
    begin
      MySocketUtil.SendString( TcpSocket, MasterConn_Advance );
      Result := True;
    end;
  end;
  MyTcpConn.Free;

    // 目标 Pc 离线
  if not Result then
    RestartNetwork;  // 启动定时重启
end;

constructor TAdvanceSearchServer.Create;
begin
  TcpSocket := TCustomIpClient.Create(nil);
  IsRemoteCompleted := True;
end;

destructor TAdvanceSearchServer.Destroy;
begin
  TcpSocket.Free;
  inherited;
end;

procedure TAdvanceSearchServer.ExtractInfo;
var
  AdvanceNetworkMode : TAdvanceNetworkMode;
begin
  inherited;

  AdvanceNetworkMode := ( NetworkModeInfo as TAdvanceNetworkMode );
  Domain := AdvanceNetworkMode.InternetName;
  Port := AdvanceNetworkMode.Port;
end;


function TAdvanceSearchServer.FindIp: Boolean;
var
  AdvanceDnsError : TAdvanceDnsError;
  ErrorStr : string;
begin
  Result := True;
  if MyParseHost.IsIpStr( Domain ) then
  begin
    Ip := Domain;
    Exit;
  end;

  if MyParseHost.HostToIP( Domain, Ip ) then
    Exit;

    // 显示 解析域名失败
  ErrorStr := Format( frmMainForm.siLang_frmMainForm.GetText( 'ParseError' ), [Domain] );
  MyMessageBox.ShowError( ErrorStr );
  AdvanceDnsError := TAdvanceDnsError.Create( Domain, Port );
  MyNetworkFace.AddChange( AdvanceDnsError );

  IsRemoteCompleted := False;
  Result := False;
end;

function TAdvanceSearchServer.getIsRemoteCompleted: Boolean;
begin
  Result := IsRemoteCompleted;
end;

procedure TAdvanceSearchServer.PingMyPc;
var
  LanConnSendPingMsg : TLanConnSendPingMsg;
begin
  LanConnSendPingMsg := TLanConnSendPingMsg.Create;
  LanConnSendPingMsg.SetRemotePcID( PcInfo.PcID );
  LanConnSendPingMsg.SetRemoteLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  MyMasterConn.AddChange( LanConnSendPingMsg );
end;

procedure TAdvanceSearchServer.RestartNetwork;
var
  NetworkLvAddInfo : TLvNetworkAdd;
begin
    // 界面显示 离线机器
  NetworkLvAddInfo := TLvNetworkAdd.Create( Domain );
  NetworkLvAddInfo.SetPcName( Domain );
  MyNetworkFace.AddChange( NetworkLvAddInfo );

  MasterThread.RunRestartThread;
end;

procedure TAdvanceSearchServer.RevConnPcInfoMsg;
var
  MsgStr : string;
  InternetPcInfoMsg : TInternetPcInfoMsg;
  NetPcAddHandle : TNetPcAddHandle;
  InternetConnSendPingMsg : TInternetConnSendPingMsg;
begin
    // 接受命令 并 解释
  MsgStr := MySocketUtil.RevString( TcpSocket );

    // 非服务器
  if ( MsgStr = '' ) or ( MsgStr = AdvanceMsg_NotServer ) then
    Exit;

  InternetPcInfoMsg := TInternetPcInfoMsg.Create;
  InternetPcInfoMsg.SetMsgStr( MsgStr );

    // 添加 Pc
  NetPcAddHandle := TNetPcAddHandle.Create( InternetPcInfoMsg.PcID );
  NetPcAddHandle.SetPcName( InternetPcInfoMsg.PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;

    // 发送 Ping 命令
  InternetConnSendPingMsg := TInternetConnSendPingMsg.Create;
  InternetConnSendPingMsg.SetRemotePcID( InternetPcInfoMsg.PcID );
  InternetConnSendPingMsg.SetRemoteLanSocket( InternetPcInfoMsg.Ip, InternetPcInfoMsg.Port );
  InternetConnSendPingMsg.SetRemoteInternetSocket( InternetPcInfoMsg.InternetIp, InternetPcInfoMsg.InternetPort );
  MyMasterConn.AddChange( InternetConnSendPingMsg );

  InternetPcInfoMsg.Free;
end;

procedure TAdvanceSearchServer.SendInternetPcInfoMsg;
var
  MsgStr : string;
  InternetPcInfoMsg : TInternetPcInfoMsg;
begin
  InternetPcInfoMsg := TInternetPcInfoMsg.Create;
  InternetPcInfoMsg.SetPcID( PcInfo.PcID );
  InternetPcInfoMsg.SetPcName( PcInfo.PcName );
  InternetPcInfoMsg.SetSocketInfo( PcInfo.LanIp, PcInfo.LanPort );
  InternetPcInfoMsg.SetnternetSocketInfo( PcInfo.InternetIp, PcInfo.InternetPort );
  InternetPcInfoMsg.SetCloudIDNumMD5( CloudSafeSettingInfo.getCloudIDNumMD5 );
  MsgStr := InternetPcInfoMsg.getMsgStr;
  InternetPcInfoMsg.Free;

  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TAdvanceSearchServer.Update;
var
  WatiTime : Integer;
begin
  PingMyPc;

  if FindIp and ConnTargetPc then
  begin
    SendInternetPcInfoMsg;
    RevConnPcInfoMsg;
    WatiTime := WaitTime_Advance;
  end
  else
    WatiTime := WaitTime_MyPc;

  MasterThread.SetWaitPingTime( WatiTime );
end;

{ TBeServerHandle }

constructor TBeServerHandle.Create;
begin
  NetPcSocketList := TNetPcSocketList.Create;
end;

destructor TBeServerHandle.Destroy;
begin
  NetPcSocketList.Free;
  inherited;
end;

procedure TBeServerHandle.FindNetPcSocketList;
var
  NetPcInfoHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
  PcID, Ip, Port : string;
  NewNetPcSocket : TNetPcSocket;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcInfoHash do
  begin
    if not p.Value.IsActivate then
      Continue;
    PcID := p.Value.PcID;
    Ip := p.Value.Ip;
    Port := p.Value.Port;
    NewNetPcSocket := TNetPcSocket.Create( PcID );
    NewNetPcSocket.SetSocketInfo( Ip, Port );
    NetPcSocketList.Add( NewNetPcSocket );
  end;
  MyNetPcInfo.LeaveData;
end;

procedure TBeServerHandle.SendBeMasterMsg;
var
  i : Integer;
  PcID, Ip, Port : string;
  ConnSendBeMasterMsg : TConnSendBeMasterMsg;
begin
  for i := 0 to NetPcSocketList.Count - 1 do
  begin
    PcID := NetPcSocketList[i].PcID;
    Ip := NetPcSocketList[i].Ip;
    Port := NetPcSocketList[i].Port;

      // BeMaster 命令
    ConnSendBeMasterMsg := TConnSendBeMasterMsg.Create;
    ConnSendBeMasterMsg.SetRemotePcID( PcID );
    ConnSendBeMasterMsg.SetRemoteSocketInfo( Ip, Port );
    MyMasterConn.AddChange( ConnSendBeMasterMsg );
  end;
end;

procedure TBeServerHandle.Update;
begin
  FindNetPcSocketList;

  SendBeMasterMsg;
end;

{ TNetPcSocket }

constructor TNetPcSocket.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TNetPcSocket.SetSocketInfo(_Ip, _Port : string);
begin
  Ip := _Ip;
  Port := _Port;
end;

{ TConnServerHandle }

procedure TConnServerHandle.CheckTransferAndSharePcExist;
var
  VstShareFileCheckExistShare : TVstShareFileCheckExistShare;
begin
  VstShareFileCheckExistShare := TVstShareFileCheckExistShare.Create;
  MyFaceChange.AddChange( VstShareFileCheckExistShare );
end;

function TConnServerHandle.ConnServer: Boolean;
var
  MyTcpConn : TMyTcpConn;
begin
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnSocket( ServerIp, ServerPort );
  MyTcpConn.SetConnType( ConnType_Server );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;
end;

procedure TConnServerHandle.ConnServerFace;
var
  SbMyStatusConnInfo : TSbMyStatusConnInfo;
  ConnServerSearchFace : TConnServerSearchFace;
begin
  SbMyStatusConnInfo := TSbMyStatusConnInfo.Create;
  MyNetworkFace.AddChange( SbMyStatusConnInfo );

  ConnServerSearchFace := TConnServerSearchFace.Create;
  MySearchFileFace.AddChange( ConnServerSearchFace );
end;

constructor TConnServerHandle.Create(_ServerIp, _ServerPort: string);
begin
  ServerIp := _ServerIp;
  ServerPort := _ServerPort;
end;

procedure TConnServerHandle.SendAdvancePcMsg;
var
  AdvacePcHash : TAdvancePcHash;
  p : TAdvancePcPair;
begin
  MasterThread.AdvanceLock.Enter;
  AdvacePcHash := MasterThread.AdvancePcHash;
  for p in AdvacePcHash do
    MyClient.SendMsgToAll( p.Value.PcInfoMsgStr );
  AdvacePcHash.Clear;
  MasterThread.AdvanceLock.Leave;
end;

procedure TConnServerHandle.SendMyCloudPcInfo;
var
  ClientSendRefreshPcInfo : TClientSendRefreshPcInfo;
begin
    // 发送 云信息 给 Server
  ClientSendRefreshPcInfo := TClientSendRefreshPcInfo.Create( MasterInfo.MasterID );
  MyClient.AddChange( ClientSendRefreshPcInfo );
end;

procedure TConnServerHandle.SendPcOnline;
var
  PcOnlineMsg : TPcOnlineMsg;
  MsgStr : string;
begin

    // 上线信息
  PcOnlineMsg := TPcOnlineMsg.Create;
  PcOnlineMsg.SetPcID( PcInfo.PcID );

    // 上线时间
  MsgStr := PcCloudMsgUtil.getOnlineTimeMsg;
  PcOnlineMsg.SetPcCloudOnlineMsgStr( MsgStr );

    // Pc 基本信息
  MsgStr := PcCloudMsgUtil.getBaseMsg;
  PcOnlineMsg.SetPcCloudBaseMsgStr( MsgStr );

    // 云空间信息
  MsgStr := PcCloudMsgUtil.getSpaceMsg;
  PcOnlineMsg.SetPcCloudSpaceMsgStr( MsgStr );

    // 云配置信息
  MsgStr := PcCloudMsgUtil.getConfigMsg;
  PcOnlineMsg.SetPcCloudConfigMsgStr( MsgStr );

    // 备份路径信息
  MsgStr := PcCloudMsgUtil.getBackupPathMsg;
  PcOnlineMsg.SetPcCloudBackupPathMsgStr( MsgStr );

    // 发送池
  MyClient.SendMsgToAll( PcOnlineMsg );
end;

procedure TConnServerHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

function TConnServerHandle.get: Boolean;
begin
  if ConnServer then
  begin
    ConnServerFace; // 刷新备份界面
    MySocketUtil.SendString( TcpSocket, PcInfo.PcID ); // 发送 Pc 标识
    MyClient.RunRevMsg;  // 启动客户端 接收线程
    SendPcOnline;  // 发送 Pc 上线消息
    SendMyCloudPcInfo; // 发送本地云信息
    SendAdvancePcMsg;  // 连接 本机的 Advance 处理
    CheckTransferAndSharePcExist; // 检测是否存在共享目录Pc
    Result := True;
  end
  else
    Result := False;
end;

{ TRestartNetworkHandle }

procedure TRestartNetworkHandle.ClearCsNetwork;
begin
  MyClient.ClientRestart;
  MyServer.RestartServer;
end;

procedure TRestartNetworkHandle.ClearFileShare;
var
  ShareDownServerOfflineHandle : TShareDownServerOfflineHandle;
  ShareHistoryServerOfflineHandle : TShareHistoryServerOfflineHandle;
  ShareFavorityServerOfflineHandle : TShareFavorityServerOfflineHandle;
begin
    // Share Down
  ShareDownServerOfflineHandle := TShareDownServerOfflineHandle.Create;
  ShareDownServerOfflineHandle.Update;
  ShareDownServerOfflineHandle.Free;

    // Share History
  ShareHistoryServerOfflineHandle := TShareHistoryServerOfflineHandle.Create;
  ShareHistoryServerOfflineHandle.Update;
  ShareHistoryServerOfflineHandle.Free;

    // Share Favority
  ShareFavorityServerOfflineHandle := TShareFavorityServerOfflineHandle.Create;
  ShareFavorityServerOfflineHandle.Update;
  ShareFavorityServerOfflineHandle.Free;
end;

procedure TRestartNetworkHandle.ClearFileTransfer;
var
  VstMyFileAllPcOfflineInfo : TVstMyFileAllPcOfflineInfo;
  LvFileReceiveSetAllPcOfflineInfo : TLvFileReceiveSetAllPcOfflineInfo;
begin
    // 发送 离线
  VstMyFileAllPcOfflineInfo := TVstMyFileAllPcOfflineInfo.Create;
  MyFaceChange.AddChange( VstMyFileAllPcOfflineInfo );

    // 接收 离线
  LvFileReceiveSetAllPcOfflineInfo := TLvFileReceiveSetAllPcOfflineInfo.Create;
  MyFaceChange.AddChange( LvFileReceiveSetAllPcOfflineInfo );
end;

procedure TRestartNetworkHandle.ClearNetworkPcFace;
var
  SbMyStatusNotConnInfo : TSbMyStatusNotConnInfo;
  NetworkServerOfflineFace : TNetworkServerOfflineFace;
begin
  SbMyStatusNotConnInfo := TSbMyStatusNotConnInfo.Create;
  MyNetworkFace.AddChange( SbMyStatusNotConnInfo );

  NetworkServerOfflineFace := TNetworkServerOfflineFace.Create;
  NetworkServerOfflineFace.Update;
  NetworkServerOfflineFace.Free;
end;

procedure TRestartNetworkHandle.ClearNetworkPcInfo;
var
  NetworkPcResetHandle : TNetworkPcResetHandle;
begin
    // 重置 Pc 信息
  NetworkPcResetHandle := TNetworkPcResetHandle.Create;
  NetworkPcResetHandle.Update;
  NetworkPcResetHandle.Free;

    // 重置 Master 信息
  MasterInfo.ResetMaster;
end;

procedure TRestartNetworkHandle.ClearRedirectJob;
var
  RedirectJobPcOfflineInfo : TRedirectJobPcOfflineInfo;
begin
  RedirectJobPcOfflineInfo := TRedirectJobPcOfflineInfo.Create( '' );
  MyJobInfo.AddChange( RedirectJobPcOfflineInfo );
end;

procedure TRestartNetworkHandle.ClearRestore;
var
  AllPcRestoreFileSearchCompleteInfo : TAllPcRestoreFileSearchCompleteInfo;
  AllPcRestoreFileSearchCancelInfo : TAllPcRestoreFileSearchCancelInfo;
begin
    // Restore Req
  AllPcRestoreFileSearchCompleteInfo := TAllPcRestoreFileSearchCompleteInfo.Create;
  MyFileRestoreReq.AddChange( AllPcRestoreFileSearchCompleteInfo );

    // Restore Scan
  AllPcRestoreFileSearchCancelInfo := TAllPcRestoreFileSearchCancelInfo.Create;
  MyFileRestoreScan.AddChange( AllPcRestoreFileSearchCancelInfo );
end;

procedure TRestartNetworkHandle.ClearSearch;
var
  AllPcFileSearchCompleteInfo : TAllPcFileSearchCompleteInfo;
  AllPcFileSearchCancelInfo : TAllPcFileSearchCancelInfo;
begin
    // Search Req
  AllPcFileSearchCompleteInfo := TAllPcFileSearchCompleteInfo.Create;
  MyFileSearchReq.AddChange( AllPcFileSearchCompleteInfo );

    // Search Scan
  AllPcFileSearchCancelInfo := TAllPcFileSearchCancelInfo.Create;
  MyFileSearchScan.AddChange( AllPcFileSearchCancelInfo );
end;

procedure TRestartNetworkHandle.ClearTransferFace;
var
  VirTransferPcOfflineHandle : TVirTransferPcOfflineHandle;
begin
  if MasterInfo.MasterID = '' then
    Exit;

  VirTransferPcOfflineHandle := TVirTransferPcOfflineHandle.Create;
  VirTransferPcOfflineHandle.SetPcID( '' );
  VirTransferPcOfflineHandle.Update;
  VirTransferPcOfflineHandle.Free;
end;

procedure TRestartNetworkHandle.LostServerFace;
var
  LostServerSearchFace : TLostServerSearchFace;
begin
  LostServerSearchFace := TLostServerSearchFace.Create;
  MySearchFileFace.AddChange( LostServerSearchFace );
end;

procedure TRestartNetworkHandle.Update;
begin
  ClearRedirectJob;
  ClearTransferFace; // Transfer Face

  ClearCsNetwork;  // 断开 C/S 网络
  ClearNetworkPcInfo;  // 清除 Pc 连接信息
  ClearNetworkPcFace;  // 清空 网络 界面

  ClearSearch;  // 清空搜索
  ClearRestore;  // 清空恢复
  ClearFileTransfer; // 传输离线
  ClearFileShare;  // 共享离线

    // 禁止备份
  LostServerFace;
end;

{ TFindInternetSocket }

constructor TFindInternetSocket.Create(_PortMapping: TPortMapping);
begin
  PortMapping := _PortMapping;
end;

function TFindInternetSocket.FindInternetIp: Boolean;
begin
    // 从 路由/网站 获取 Internet IP
  if PortMapping.IsPortMapable then
    Result := FindRouterInternetIp
  else
    Result := FindWebInternetIp;
end;

procedure TFindInternetSocket.FindInternetPort;
begin
  if not PortMapping.IsPortMapable then
    InternetPort := PcInfo.LanPort
  else
    InternetPort := MyUpnpUtil.getUpnpPort( PcInfo.LanIp );
end;

function TFindInternetSocket.FindRouterInternetIp: Boolean;
begin
  InternetIp := PortMapping.getInternetIp;
  Result := InternetIp <> '';
end;

function TFindInternetSocket.FindWebInternetIp: Boolean;
var
  getIpHttp : TIdHTTP;
  httpStr : string;
  HttpList : TStringList;
begin
  getIpHttp := TIdHTTP.Create(nil);
  getIpHttp.ConnectTimeout := 5000;
  getIpHttp.ReadTimeout := 5000;
  try
    httpStr := getIpHttp.Get( MyUrl.getIp );

    HttpList := TStringList.Create;
    HttpList.Text := httpStr;
    InternetIp := HttpList[0];
    HttpList.Free;

    Result := True;
  except
    Result := False;
  end;
  getIpHttp.Free;
end;

procedure TFindInternetSocket.SetInternetFace;
var
  ShowIp, ShowPort : string;
  InternetSocketChangeInfo : TInternetSocketChangeInfo;
begin
    // 可能本机未联网
  if InternetIp = '' then
  begin
    ShowIp := Sign_NA;
    ShowPort := Sign_NA;
  end
  else
  begin
    ShowIp := InternetIp;
    ShowPort := InternetPort;
  end;

    // 显示到 Setting 界面
  InternetSocketChangeInfo := TInternetSocketChangeInfo.Create( ShowIp, ShowPort );
  MyNetworkFace.AddChange( InternetSocketChangeInfo );
end;

procedure TFindInternetSocket.Update;
var
  IsConnInternet : Boolean;
begin
  InternetIp := '';
  InternetPort := '';
  IsConnInternet := False;

  if FindInternetIp then
  begin
    FindInternetPort;
    IsConnInternet := True;
  end;

  PcInfo.SetInternetInfo( InternetIp, InternetPort );
  PcInfo.SetIsConnInternet( IsConnInternet );
  SetInternetFace;
end;

{ TAdvancePcInfo }

constructor TAdvancePcInfo.Create(_PcID, _PcInfoMsgStr: string);
begin
  PcID := _PcID;
  PcInfoMsgStr := _PcInfoMsgStr;
end;

{ TStandardPcInfo }

constructor TStandardPcInfo.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TStandardPcInfo.SetInternetSocket(_InternetIp, _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TStandardPcInfo.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

{ TFindStandardNetworkHttp }

constructor TFindStandardNetworkHttp.Create(_CompanyName, _Password: string);
begin
  CompanyName := _CompanyName;
  Password := _Password;
end;

function TFindStandardNetworkHttp.get: string;
var
  PcID, PcName : string;
  LanIp, LanPort : string;
  InternetIp, InternetPort : string;
  CloudIDNumber : string;
  params : TStringlist;
  idhttp : TIdHTTP;
begin
    // 本机信息
  PcID := PcInfo.PcID;
  PcName := PcInfo.PcName;
  LanIp := PcInfo.LanIP;
  LanPort := PcInfo.LanPort;
  InternetIp := PcInfo.InternetIp;
  InternetPort := PcInfo.InternetPort;
  CloudIDNumber := CloudSafeSettingInfo.getCloudIDNumMD5;
  CloudIDNumber := MyEncrypt.EncodeMD5String( CloudIDNumber );

    // 登录并获取在线 Pc 信息
  params := TStringList.Create;
  params.Add( HttpReq_CompanyName + '=' + CompanyName );
  params.Add( HttpReq_Password + '=' + Password );
  params.Add( HttpReq_PcID + '=' + PcID );
  params.Add( HttpReq_PcName + '=' + PcName );
  params.Add( HttpReq_LanIp + '=' + LanIp );
  params.Add( HttpReq_LanPort + '=' + LanPort );
  params.Add( HttpReq_InternetIp + '=' + InternetIp );
  params.Add( HttpReq_InternetPort + '=' + InternetPort );
  params.Add( HttpReq_CloudIDNumber + '=' + CloudIDNumber );

  idhttp := TIdHTTP.Create(nil);
  try
    Result := idhttp.Post( MyUrl.getGroupPcList + '?cmd=' + Cmd, params );
  except
    Result := LoginResult_ConnError;
  end;
  idhttp.Free;

  params.free;
end;

procedure TFindStandardNetworkHttp.SetCmd(_Cmd: string);
begin
  Cmd := _Cmd;
end;

{ TStandardHearBetThread }

procedure TStandardHearBetThread.CheckAccountPc;
var
  Cmd : string;
  ServerNumber : Integer;
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // 本机 非 Server
  if MasterInfo.MasterID <> PcInfo.PcID then
    Exit;

    // 已连接
  if MyNetPcInfoReadUtil.ReadActivePcCount > 1 then
    Exit;

    // 是否第一次
  if LastServerNumber = -1 then
    Cmd := Cmd_AddServerNumber
  else
    Cmd := Cmd_ReadServerNumber;

    // Login Number
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd );
  ServerNumber := StrToIntDef( FindStandardNetworkHttp.get, 0 );
  FindStandardNetworkHttp.Free;

    // 第一次
  if LastServerNumber = -1 then
  begin
    LastServerNumber := ServerNumber;
    Exit;
  end;

    // 与上次想相同
  if LastServerNumber = ServerNumber then
    Exit;

    // 重启网络
  MasterThread.RestartNetwork;
end;

constructor TStandardHearBetThread.Create;
begin
  inherited Create( True );
  LastServerNumber := -1;
end;

destructor TStandardHearBetThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TStandardHearBetThread.Execute;
var
  StartHearBeat, StartCheckAccount : TDateTime;
begin
  StartHearBeat := Now;
  StartCheckAccount := 0;
  while not Terminated do
  begin
      // 5 分钟 发送一次心跳
    if MinutesBetween( Now, StartHearBeat ) >= 5 then
    begin
      SendHeartBeat;
      StartHearBeat := Now;
    end;
      // 10 秒钟 检测一次帐号
    if ( SecondsBetween( Now, StartCheckAccount ) >= 10 ) or
       ( LastServerNumber = -1 ) then
    begin
      CheckAccountPc;
      StartCheckAccount := Now;
    end;
    if Terminated then
      Break;
    Sleep(100);
  end;
  inherited;
end;

procedure TStandardHearBetThread.SendHeartBeat;
var
  FindStandardNetworkHttp : TFindStandardNetworkHttp;
begin
    // 心跳
  FindStandardNetworkHttp := TFindStandardNetworkHttp.Create( AccountName, Password );
  FindStandardNetworkHttp.SetCmd( Cmd_HeartBeat );
  FindStandardNetworkHttp.get;
  FindStandardNetworkHttp.Free;
end;

procedure TStandardHearBetThread.SetAccountInfo(_AccountName,
  _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;

{ TStandardPcAddHanlde }

procedure TStandardPcAddHanlde.AddNetworkPc;
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( StandardPcInfo.PcID );
  NetPcAddHandle.SetPcName( StandardPcInfo.PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

procedure TStandardPcAddHanlde.AddPingMsg;
var
  InternetConnSendPingMsg : TInternetConnSendPingMsg;
begin
  InternetConnSendPingMsg := TInternetConnSendPingMsg.Create;
  InternetConnSendPingMsg.SetRemotePcID( StandardPcInfo.PcID );
  InternetConnSendPingMsg.SetRemoteLanSocket( StandardPcInfo.LanIp, StandardPcInfo.LanPort );
  InternetConnSendPingMsg.SetRemoteInternetSocket( StandardPcInfo.InternetIp, StandardPcInfo.InternetPort );
  MyMasterConn.AddChange( InternetConnSendPingMsg );
end;

constructor TStandardPcAddHanlde.Create(_StandardPcInfo: TStandardPcInfo);
begin
  StandardPcInfo := _StandardPcInfo;
end;

procedure TStandardPcAddHanlde.Update;
begin
  AddNetworkPc;

  AddPingMsg;
end;

{ TPortMappingThread }

constructor TPortMappingThread.Create( _LanIp, _LanPort : string );
begin
  inherited Create( True );
  LanIp := _LanIp;
  LanPort := _LanPort;
  InternetPort := MyUpnpUtil.getUpnpPort( LanIp );
end;

destructor TPortMappingThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TPortMappingThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    PortMapping.AddMapping( LanIp, LanPort, InternetPort );

    StartTime := Now;
    while ( not Terminated ) and ( MinutesBetween( Now, StartTime ) < WaitTime_PortMap ) do
      Sleep(100);
  end;

  PortMapping.RemoveMapping( InternetPort );

  inherited;
end;

procedure TPortMappingThread.SetPortMapping(_PortMapping: TPortMapping);
begin
  PortMapping := _PortMapping;
end;

{ TRestartNetworkThread }

constructor TRestartNetworkThread.Create;
begin
  inherited Create( True );
  IsRestart := False;
end;

destructor TRestartNetworkThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TRestartNetworkThread.Execute;
var
  LastShowTime : TDateTime;
begin
  while not Terminated do
  begin
    LastShowTime := Now;
    while ( not Terminated ) and ( SecondsBetween( Now, LastShowTime ) < 1 ) do
      Sleep(100);
    if Terminated then
      Break;
    ShowRemainTime;
  end;

  inherited;
end;

procedure TRestartNetworkThread.RestartNetwork;
begin
  MyNetworkControl.RestartNetwork;
end;

procedure TRestartNetworkThread.RunRestart;
var
  PlNetworkConnShowInfo : TPlNetworkConnShowInfo;
begin
    // 显示
  PlNetworkConnShowInfo := TPlNetworkConnShowInfo.Create;
  MyNetworkFace.AddChange( PlNetworkConnShowInfo );

    // 开始时间
  StartTime := Now;
  IsRestart := True;

    // 显示剩余时间
  ShowRemainTime;
end;

procedure TRestartNetworkThread.ShowRemainTime;
var
  RemainTime : Integer;
  PlNetworkConnRemainInfo : TPlNetworkConnRemainInfo;
begin
  if not IsRestart then
    Exit;

  RemainTime := 300 - SecondsBetween( Now, StartTime );

  PlNetworkConnRemainInfo := TPlNetworkConnRemainInfo.Create( RemainTime );
  MyNetworkFace.AddChange( PlNetworkConnRemainInfo );

    // 重启网络
  if RemainTime <= 0 then
    Synchronize( RestartNetwork );
end;

procedure TRestartNetworkThread.StopRestart;
var
  PlNetworkConnHideInfo : TPlNetworkConnHideInfo;
begin
    // 隐藏
  PlNetworkConnHideInfo := TPlNetworkConnHideInfo.Create;
  MyNetworkFace.AddChange( PlNetworkConnHideInfo );

  IsRestart := False;
end;

end.
