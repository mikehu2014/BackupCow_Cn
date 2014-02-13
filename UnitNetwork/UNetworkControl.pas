unit UNetworkControl;

interface

uses Sockets, USearchServer, UMyNetPcInfo, UMyMaster;

type

{$Region ' Remote Network ' }

    // Join a group
  TStandardNetworkJoinHandle = class
  public
    AccountName : string;
    Password : string;
  public
    constructor Create( _AccountName, _Password : string );
    procedure Update;
  private
    procedure AddToSettingsForm;
    procedure SelectGroup;
  end;

    // Connect to computer
  TAdvanceNetworkConnHandle = class
  public
    Ip, Port : string;
  public
    constructor Create( _Ip, _Port : string );
    procedure Update;
  private
    procedure AddToSettingsForm;
    procedure AddToMainForm;
    procedure SelectComputer;
  end;

{$EndRegion}

{$Region ' �޸� Pc ��Ϣ ' }

    // ����
  TNetPcChangeHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

  {$Region ' ��ɾ��Ϣ ' }

    // ��ȡ
  TNetPcReadHandle = class( TNetPcChangeHandle )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;virtual;
  end;

    // ��� ��Pc ��Ϣ
  TNetPcAddCloudHandle = class( TNetPcReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // ��� ����Pc ��Ϣ
  TNetPcAddHandle = class( TNetPcAddCloudHandle )
  protected
    procedure AddToFace;override;
  end;

  {$EndRegion}

  {$Region ' λ����Ϣ ' }

    // �޸� Reach ����
  TNetPcReachChangeHandle = class( TNetPcChangeHandle )
  protected
    procedure RefreshReachFace;
  end;

    // ���� Reach
  TNetPcSetReachHandle = class( TNetPcReachChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ���� BeReach
  TNetPcSetBeReachHandle = class( TNetPcReachChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

   // ��ȡ ����������Ϣ
  TNetPcSocketReadHandle = class( TNetPcChangeHandle )
  public
    Ip, Port : string;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� ����������Ϣ
  TNetPcSetSocketHandle = class( TNetPcSocketReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

  {$EndRegion}

  {$Region ' ״̬��Ϣ ' }

    // ��������Pc��Ϣ
  TNetworkPcResetHandle = class
  public
    procedure Update;
  private
    procedure SetToInfo;
  end;


    // ���� ѡ��Master��Ϣ
  TNetPcSetRunInfoHandle = class( TNetPcChangeHandle )
  public
    StartTime : TDateTime;
    RanNum : Integer;
  public
    procedure SetSortInfo( _StartTime : TDateTime; _RanNum : Integer );
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // ���� Pc ������Ϣ
  TNetPcSetActivateHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // ���� Pc ��Ϊ ������
  TNetPcBeMasterHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� Pc ����
  TNetPcOnlineHandle = class( TNetPcChangeHandle )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToEvent;
  end;

    // ���� Pc ����
  TNetPcOfflineHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToEvent;
  end;

  {$EndRegion}

  {$Region ' ������Ϣ ' }

    // ��ȡ ���������Ϣ
  TNetPcLastOnlineTimeReadHandle = class( TNetPcChangeHandle )
  public
    LastOnlineTime : TDateTime;
  public
    procedure SetLastOnlineTime( _LastOnlineTime : TDateTime );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� ���������Ϣ
  TNetPcLastOnlineTimeSetHandle = class( TNetPcLastOnlineTimeReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // ��ȡ Pc �ռ���Ϣ
  TNetPcSpaceReadHandle = class( TNetPcChangeHandle )
  public
    UsedSpace, TotalSpace : Int64;
    BackupSpace : Int64;
  public
    procedure SetSpace( _UsedSpace, _TotalSpace : Int64 );
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� Pc �ռ���Ϣ
  TNetPcSpaceSetHandle = class( TNetPcSpaceReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // ��ȡ Pc ������Ϣ
  TNetPcConfigReadHandle = class( TNetPcChangeHandle )
  public
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
    RegisterHardCode, RegisterEdition : string;
    CopyCount : Integer;
  public
    procedure SetFileInvisible( _IsFileInvisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
    procedure SetRegisterEdition( _RegisterEdition, _RegisterHardCode : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� Pc ������Ϣ
  TNetPcConfigSetHandle = class( TNetPcConfigReadHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // ��ȡ �Ƿ� ����Ŀ��
  TNetPcReadIsBackupDesHandle = class( TNetPcChangeHandle )
  public
    IsBackupDes : Boolean;
  public
    procedure SetIsBackupDes( _IsBackupDes : Boolean );
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ���� �Ƿ� ����Ŀ��
  TNetPcSetIsBackupDesHandle = class( TNetPcReadIsBackupDesHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

    // ռ�� �������ƿռ���Ϣ
  TNetPcAddPendingSpaceHandle = class( TNetPcChangeHandle )
  public
    BackupPendingSpace : Int64;
  public
    procedure SetBackupPendingSpace( _BackupPendingSpace : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �޸� Pc ����·�� ' }

    // ��ȡ
  TNetPcReadBackupPathHandle = class( TNetPcChangeHandle )
  public
    FullPath, PathType : string;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
    FolderSpace : Int64;
    FileCount, CopyCount : Integer;
  public
    procedure SetPathInfo( _FullPath, _PathType : string );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure SetSpace( _FolderSpace : Int64 );
    procedure SetCountInfo( _FileCount, _CopyCount : Integer );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // ���
  TNetPcAddBackupPathHandle = class( TNetPcReadBackupPathHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ���
  TNetPcClearBackupPathHandle = class( TNetPcChangeHandle )
  public
    procedure Update;
  private
    procedure ClearInfo;
    procedure ClearXml;
  end;

    // ��ȡ ·��ӵ����
  TNetPcBackupPathOwnerReadHandle = class( TNetPcChangeHandle )
  public
    FullPath, CopyOwner : string;
    OwnerSpace : Int64;
  public
    procedure SetPathInfo( _FullPath, _CopyOwner : string );
    procedure SetOwnerSpace( _OwnerSpace : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ��� ·��ӵ����
  TNetPcBackupPathOwnerAddHandle = class( TNetPcBackupPathOwnerReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

{$EndRegion}

  TMyNetworkControl = class
  public
    procedure ShowPcHint( PcID : string );
    procedure ShowPcDetail( PcID : string );
    procedure RefreshOnlyShow;
    procedure RestartNetwork;
  public
    procedure SetIsBackupDes( PcID : string; IsBackup : Boolean );
  end;


var
  MyNetworkControl : TMyNetworkControl;

implementation

uses  UNetworkFace, UMainForm, UNetPcInfoXml, UFormSetting, URestoreFileFace, UNetworkEventInfo;

{ TSearchServerControl }

procedure TMyNetworkControl.RefreshOnlyShow;
var
  CloudStatusLvRefreshOnlyShowInfo : TVstCloudStatusRefreshOnlyShow;
begin
  CloudStatusLvRefreshOnlyShowInfo := TVstCloudStatusRefreshOnlyShow.Create;
  MyNetworkFace.AddChange( CloudStatusLvRefreshOnlyShowInfo );
end;

procedure TMyNetworkControl.RestartNetwork;
begin
  frmMainForm.plNetworkConn.Visible := False;
  frmMainForm.plFileSendDesConn.Visible := False;
  MasterThread.RestartNetwork;
end;

procedure TMyNetworkControl.SetIsBackupDes(PcID: string; IsBackup: Boolean);
var
  NetPcSetIsBackupDesHandle : TNetPcSetIsBackupDesHandle;
begin
  NetPcSetIsBackupDesHandle := TNetPcSetIsBackupDesHandle.Create( PcID );
  NetPcSetIsBackupDesHandle.SetIsBackupDes( IsBackup );
  NetPcSetIsBackupDesHandle.Update;
  NetPcSetIsBackupDesHandle.Free;
end;

procedure TMyNetworkControl.ShowPcDetail(PcID: string);
begin
  MyNetPcInfoReadUtil.ShowPcDetail( PcID );
end;

procedure TMyNetworkControl.ShowPcHint(PcID: string);
var
  HintStr : string;
  NetworkLvShowHintInfo : TNetworkLvShowHintInfo;
begin
  HintStr := MyNetPcInfoReadUtil.ReadHintInfo( PcID );

  NetworkLvShowHintInfo := TNetworkLvShowHintInfo.Create;
  NetworkLvShowHintInfo.SetHintStr( HintStr );
  MyNetworkFace.AddChange( NetworkLvShowHintInfo );
end;

{ TStandardNetworkJoinHandle }

procedure TStandardNetworkJoinHandle.AddToSettingsForm;
var
  NetworkGroupAddHandle : TLvStandardAddHandle;
  IsAddedGroup : Boolean;
  NetworkGroupPasswordHandle : TLvStandardPasswordHandle;
begin
    // ���
  NetworkGroupAddHandle := TLvStandardAddHandle.Create( AccountName, Password );
  IsAddedGroup := NetworkGroupAddHandle.Update;
  NetworkGroupAddHandle.Free;

    // �Ѿ�����
    // �޸�����
  if not IsAddedGroup then
  begin
    NetworkGroupPasswordHandle := TLvStandardPasswordHandle.Create( AccountName, Password );
    NetworkGroupPasswordHandle.Update;
    NetworkGroupPasswordHandle.Free;
  end;

    // Apply
  frmSetting.btnApply.Enabled := True;
  frmSetting.btnApply.Click;
end;

constructor TStandardNetworkJoinHandle.Create(_AccountName, _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;

procedure TStandardNetworkJoinHandle.SelectGroup;
var
  PmStandardNetworkSelect : TPmStandardNetworkSelect;
begin
  PmStandardNetworkSelect := TPmStandardNetworkSelect.Create;
  PmStandardNetworkSelect.SetSelectStr( AccountName );
  PmStandardNetworkSelect.Update;
  PmStandardNetworkSelect.Free;
end;

procedure TStandardNetworkJoinHandle.Update;
begin
    // ���
  AddToSettingsForm;

    // ѡ��
  SelectGroup;
end;

{ TAdvanceNetworkConnHandle }

procedure TAdvanceNetworkConnHandle.AddToMainForm;
begin

end;

procedure TAdvanceNetworkConnHandle.AddToSettingsForm;
var
  LvAdvanceAddHandle : TLvAdvanceAddHandle;
  IsAdded : Boolean;
begin
  LvAdvanceAddHandle := TLvAdvanceAddHandle.Create( Ip, Port );
  IsAdded := LvAdvanceAddHandle.Update;
  LvAdvanceAddHandle.Free;

    // �Ѵ���
  if not IsAdded then
    Exit;

  frmSetting.btnApply.Enabled := True;
  frmSetting.btnApply.Click;
end;

constructor TAdvanceNetworkConnHandle.Create(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TAdvanceNetworkConnHandle.SelectComputer;
var
  SelectShowStr : string;
  PmAdvaceNetworkSelect : TPmAdvaceNetworkSelect;
begin
  SelectShowStr := Ip + Split_PmAdvance + Port;

    // ������ѡ�������
  PmAdvaceNetworkSelect := TPmAdvaceNetworkSelect.Create;
  PmAdvaceNetworkSelect.SetSelectStr( SelectShowStr );
  PmAdvaceNetworkSelect.Update;
  PmAdvaceNetworkSelect.Free;
end;

procedure TAdvanceNetworkConnHandle.Update;
begin
    // ���
  AddToSettingsForm;

    // ѡ��
  SelectComputer;
end;

{ TNetPcChangeHandle }

constructor TNetPcChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetPcAddHandle }

procedure TNetPcAddHandle.AddToFace;
var
  NetworkPcAddFace : TNetworkPcAddFace;
begin
  NetworkPcAddFace := TNetworkPcAddFace.Create( PcID, PcName );
  NetworkPcAddFace.Update;
  NetworkPcAddFace.Free;
end;

{ TNetPcSetSocketHandle }

procedure TNetPcSetSocketHandle.SetToXml;
var
  NetPcSocketXml : TNetPcSocketXml;
begin
    // д Xml
  NetPcSocketXml := TNetPcSocketXml.Create( PcID );
  NetPcSocketXml.SetSocket( Ip, Port );
  MyNetPcXmlWrite.AddChange( NetPcSocketXml );
end;

procedure TNetPcSetSocketHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TNetPcBeMasterHandle }

procedure TNetPcBeMasterHandle.SetToFace;
var
  NetworkLvServerInfo : TLvNetworkServer;
  CloudStatusLvServerInfo : TVstCloudStatusServer;
begin
  NetworkLvServerInfo := TLvNetworkServer.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvServerInfo );

  CloudStatusLvServerInfo := TVstCloudStatusServer.Create( PcID );
  MyNetworkFace.AddChange( CloudStatusLvServerInfo );
end;

procedure TNetPcBeMasterHandle.SetToInfo;
var
  NetPcServerInfo : TNetPcServerInfo;
begin
  NetPcServerInfo := TNetPcServerInfo.Create( PcID );
  NetPcServerInfo.Update;
  NetPcServerInfo.Free;
end;

procedure TNetPcBeMasterHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcSetReachHandle }

procedure TNetPcSetReachHandle.SetToFace;
begin
  RefreshReachFace;
end;

procedure TNetPcSetReachHandle.SetToInfo;
var
  NetPcReachInfo : TNetPcReachInfo;
begin
    // д �ڴ�
  NetPcReachInfo := TNetPcReachInfo.Create( PcID );
  NetPcReachInfo.Update;
  NetPcReachInfo.Free;
end;

procedure TNetPcSetReachHandle.SetToXml;
var
  NetPcReachXml : TNetPcReachXml;
begin
    // д Xml
  NetPcReachXml := TNetPcReachXml.Create( PcID );
  NetPcReachXml.SetIsReach( True );
  MyNetPcXmlWrite.AddChange( NetPcReachXml );
end;

procedure TNetPcSetReachHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TNetPcSetBeReachHandle }

procedure TNetPcSetBeReachHandle.SetToFace;
begin
  RefreshReachFace;
end;

procedure TNetPcSetBeReachHandle.SetToInfo;
var
  NetPcBeReachInfo : TNetPcBeReachInfo;
begin
    // д �ڴ�
  NetPcBeReachInfo := TNetPcBeReachInfo.Create( PcID );
  NetPcBeReachInfo.Update;
  NetPcBeReachInfo.Free;
end;

procedure TNetPcSetBeReachHandle.SetToXml;
var
  NetPcBeReachXml : TNetPcBeReachXml;
begin
    // д Xml
  NetPcBeReachXml := TNetPcBeReachXml.Create( PcID );
  NetPcBeReachXml.SetIsBeReach( True );
  MyNetPcXmlWrite.AddChange( NetPcBeReachXml );
end;

procedure TNetPcSetBeReachHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TNetPcOnlineHandle }

procedure TNetPcOnlineHandle.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcOnlineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOnline( PcID );
end;

procedure TNetPcOnlineHandle.SetToFace;
var
  NetworkPcOnlineFace : TNetworkPcOnlineFace;
begin
  NetworkPcOnlineFace := TNetworkPcOnlineFace.Create( PcID, PcName );
  NetworkPcOnlineFace.Update;
  NetworkPcOnlineFace.Free;
end;

procedure TNetPcOnlineHandle.SetToInfo;
var
  NetPcOnlineInfo : TNetPcOnlineInfo;
begin
  NetPcOnlineInfo := TNetPcOnlineInfo.Create( PcID );
  NetPcOnlineInfo.Update;
  NetPcOnlineInfo.Free;
end;

procedure TNetPcOnlineHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToEvent;
end;

{ TNetPcReadHandle }

procedure TNetPcReadHandle.AddToFace;
var
  NetworkPcAddCloudFace : TNetworkPcAddCloudFace;
begin
  NetworkPcAddCloudFace := TNetworkPcAddCloudFace.Create( PcID, PcName );
  NetworkPcAddCloudFace.Update;
  NetworkPcAddCloudFace.Free;
end;

procedure TNetPcReadHandle.AddToInfo;
var
  NetPcAddInfo : TNetPcAddInfo;
begin
    // д �ڴ�
  NetPcAddInfo := TNetPcAddInfo.Create( PcID );
  NetPcAddInfo.SetPcName( PcName );
  NetPcAddInfo.Update;
  NetPcAddInfo.Free;
end;

procedure TNetPcReadHandle.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetPcSocketReadHandle }

procedure TNetPcSocketReadHandle.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketReadHandle.SetToFace;
var
  CloudStatusLvSocketInfo : TVstCloudStatusSocket;
begin
  CloudStatusLvSocketInfo := TVstCloudStatusSocket.Create( PcID );
  CloudStatusLvSocketInfo.SetSocket( Ip, Port );
  MyNetworkFace.AddChange( CloudStatusLvSocketInfo );
end;

procedure TNetPcSocketReadHandle.SetToInfo;
var
  NetPcSocketInfo : TNetPcSocketInfo;
begin
    // д �ڴ�
  NetPcSocketInfo := TNetPcSocketInfo.Create( PcID );
  NetPcSocketInfo.SetSocket( Ip, Port );
  NetPcSocketInfo.Update;
  NetPcSocketInfo.Free;
end;

procedure TNetPcSocketReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcLastOnlineTimeReadHandle }

procedure TNetPcLastOnlineTimeReadHandle.SetLastOnlineTime(
  _LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

procedure TNetPcLastOnlineTimeReadHandle.SetToFace;
var
  CloudStatusLvOnlineTimeInfo : TVstCloudStatusOnlineTime;
begin
  CloudStatusLvOnlineTimeInfo := TVstCloudStatusOnlineTime.Create( PcID );
  CloudStatusLvOnlineTimeInfo.SetLastOnlineTime( LastOnlineTime );
  MyNetworkFace.AddChange( CloudStatusLvOnlineTimeInfo );
end;

procedure TNetPcLastOnlineTimeReadHandle.SetToInfo;
var
  NetPcOnlineTimeInfo : TNetPcOnlineTimeInfo;
begin
    // Pc LastOnline
  NetPcOnlineTimeInfo := TNetPcOnlineTimeInfo.Create( PcID );
  NetPcOnlineTimeInfo.SetLastOnlineTime( LastOnlineTime );
  NetPcOnlineTimeInfo.Update;
  NetPcOnlineTimeInfo.Free;
end;

procedure TNetPcLastOnlineTimeReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcConfigReadHandle }

procedure TNetPcConfigReadHandle.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TNetPcConfigReadHandle.SetFileInvisible(_IsFileInvisible: Boolean);
begin
  IsFileInvisible := _IsFileInvisible;
end;

procedure TNetPcConfigReadHandle.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TNetPcConfigReadHandle.SetRegisterEdition(_RegisterEdition,
  _RegisterHardCode: string);
begin
  RegisterEdition := _RegisterEdition;
  RegisterHardCode := _RegisterHardCode;
end;

procedure TNetPcConfigReadHandle.SetToFace;
var
  OwnerCbbFileInvisibleInfo : TOwnerCbbFileInvisibleInfo;
  RegisterLvEditionInfo : TLvRegisterEdition;
  VstRestorePcSetInvisible : TVstRestorePcSetInvisible;
begin
    // Restore Visible
  VstRestorePcSetInvisible := TVstRestorePcSetInvisible.Create( PcID );
  VstRestorePcSetInvisible.SetInvisibleInfo( IsFileInvisible, IvPasswordMD5 );
  MyNetworkFace.AddChange( VstRestorePcSetInvisible );

    // SearchFile Pc FileInvisible
  OwnerCbbFileInvisibleInfo := TOwnerCbbFileInvisibleInfo.Create( PcID );
  OwnerCbbFileInvisibleInfo.SetIsFileInvisible( IsFileInvisible );
  OwnerCbbFileInvisibleInfo.SetIvPasswordMD5( IvPasswordMD5 );
  MyNetworkFace.AddChange( OwnerCbbFileInvisibleInfo );

    // Register Pc Edition
  RegisterLvEditionInfo := TLvRegisterEdition.Create( PcID );
  RegisterLvEditionInfo.SetRegisterEdition( RegisterEdition, RegisterHardCode );
  MyNetworkFace.AddChange( RegisterLvEditionInfo );
end;

procedure TNetPcConfigReadHandle.SetToInfo;
var
  NetPcCloudConfigInfo : TNetPcCloudConfigInfo;
begin
  NetPcCloudConfigInfo := TNetPcCloudConfigInfo.Create( PcID );
  NetPcCloudConfigInfo.SetFileInvisible( IsFileInvisible );
  NetPcCloudConfigInfo.SetIvPasswordMD5( IvPasswordMD5 );
  NetPcCloudConfigInfo.SetRegisterInfo( RegisterEdition, RegisterHardCode );
  NetPcCloudConfigInfo.SetCopyCount( CopyCount );
  NetPcCloudConfigInfo.Update;
  NetPcCloudConfigInfo.Free;
end;

procedure TNetPcConfigReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcSpaceReadHandle }

procedure TNetPcSpaceReadHandle.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TNetPcSpaceReadHandle.SetSpace(_UsedSpace, _TotalSpace: Int64);
begin
  UsedSpace := _UsedSpace;
  TotalSpace := _TotalSpace;
end;

procedure TNetPcSpaceReadHandle.SetToFace;
var
  CloudStatusLvSpaceInfo : TVstCloudStatusSpace;
  VstMyBackupDesSetAvailableSpace : TVstMyBackupDesSetAvailableSpace;
begin
  CloudStatusLvSpaceInfo := TVstCloudStatusSpace.Create( PcID );
  CloudStatusLvSpaceInfo.SetSpace( UsedSpace, TotalSpace );
  CloudStatusLvSpaceInfo.SetBackupSpace( BackupSpace );
  MyNetworkFace.AddChange( CloudStatusLvSpaceInfo );

  VstMyBackupDesSetAvailableSpace := TVstMyBackupDesSetAvailableSpace.Create( PcID );
  VstMyBackupDesSetAvailableSpace.SetSpaceInfo( TotalSpace, TotalSpace - UsedSpace );
  MyNetworkFace.AddChange( VstMyBackupDesSetAvailableSpace );
end;

procedure TNetPcSpaceReadHandle.SetToInfo;
var
  NetPcCloudSpaceInfo : TNetPcCloudSpaceInfo;
begin
    // Pc Space
  NetPcCloudSpaceInfo := TNetPcCloudSpaceInfo.Create( PcID );
  NetPcCloudSpaceInfo.SetSpace( UsedSpace, TotalSpace );
  NetPcCloudSpaceInfo.SetBackupSpace( BackupSpace );
  NetPcCloudSpaceInfo.Update;
  NetPcCloudSpaceInfo.Free;
end;

procedure TNetPcSpaceReadHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcReadIsBackupDesHandle }

procedure TNetPcReadIsBackupDesHandle.SetIsBackupDes(_IsBackupDes: Boolean);
begin
  IsBackupDes := _IsBackupDes;
end;

procedure TNetPcReadIsBackupDesHandle.SetToFace;
var
  VstMyBackupDesSetIsBackup : TVstMyBackupDesSetIsBackup;
begin
    // My BackupDes IsBackup
  VstMyBackupDesSetIsBackup := TVstMyBackupDesSetIsBackup.Create( PcID );
  VstMyBackupDesSetIsBackup.SetIsBackup( IsBackupDes );
  MyNetworkFace.AddChange( VstMyBackupDesSetIsBackup );
end;

procedure TNetPcReadIsBackupDesHandle.SetToInfo;
var
  NetPcIsBackupDesInfo : TNetPcIsBackupDesInfo;
begin
    // �Ƿ񱸷ݵ� Pc
  NetPcIsBackupDesInfo := TNetPcIsBackupDesInfo.Create( PcID );
  NetPcIsBackupDesInfo.SetIsBackup( IsBackupDes );
  NetPcIsBackupDesInfo.Update;
  NetPcIsBackupDesInfo.Free;
end;

procedure TNetPcReadIsBackupDesHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TNetPcSetRunInfoHandle }

procedure TNetPcSetRunInfoHandle.SetSortInfo(_StartTime: TDateTime;
  _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;

procedure TNetPcSetRunInfoHandle.SetToInfo;
var
  NetPcSortInfo : TNetPcSortInfo;
begin
  NetPcSortInfo := TNetPcSortInfo.Create( PcID );
  NetPcSortInfo.SetSortInfo( StartTime, RanNum );
  NetPcSortInfo.Update;
  NetPcSortInfo.Free;
end;

procedure TNetPcSetRunInfoHandle.Update;
begin
  SetToInfo;
end;

{ TNetPcSetActivateHandle }

procedure TNetPcSetActivateHandle.SetToInfo;
var
  NetPcActivateInfo : TNetPcActivateInfo;
begin
  NetPcActivateInfo := TNetPcActivateInfo.Create( PcID );
  NetPcActivateInfo.Update;
  NetPcActivateInfo.Free;
end;

procedure TNetPcSetActivateHandle.Update;
begin
  SetToInfo;
end;

{ TNetworkPcResetHandle }

procedure TNetworkPcResetHandle.SetToInfo;
var
  NetPcResetInfo : TNetPcResetInfo;
begin
    // ���� Pc ��Ϣ
  NetPcResetInfo := TNetPcResetInfo.Create;
  NetPcResetInfo.Update;
  NetPcResetInfo.Free;
end;

procedure TNetworkPcResetHandle.Update;
begin
  SetToInfo;
end;

{ TNetPcOfflineHandle }

procedure TNetPcOfflineHandle.SetToEvent;
begin
  NetworkPcEvent.PcOffline( PcID );
end;

procedure TNetPcOfflineHandle.SetToFace;
var
  NetworkPcOfflineFace : TNetworkPcOfflineFace;
begin
  NetworkPcOfflineFace := TNetworkPcOfflineFace.Create( PcID );
  NetworkPcOfflineFace.Update;
  NetworkPcOfflineFace.Free;
end;

procedure TNetPcOfflineHandle.SetToInfo;
var
  NetPcOfflineInfo : TNetPcOfflineInfo;
begin
  NetPcOfflineInfo := TNetPcOfflineInfo.Create( PcID );
  NetPcOfflineInfo.Update;
  NetPcOfflineInfo.Free;
end;

procedure TNetPcOfflineHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToEvent;
end;

{ TNetPcLastOnlineTimeSetHandle }

procedure TNetPcLastOnlineTimeSetHandle.SetToXml;
var
  NetPcOnlineTimeXml : TNetPcOnlineTimeXml;
begin
  NetPcOnlineTimeXml := TNetPcOnlineTimeXml.Create( PcID );
  NetPcOnlineTimeXml.SetLastOnlineTime( LastOnlineTime );
  MyNetPcXmlWrite.AddChange( NetPcOnlineTimeXml );
end;

procedure TNetPcLastOnlineTimeSetHandle.Update;
begin
  inherited;

  SetToXml;
end;

{ TNetPcSpaceSetHandle }

procedure TNetPcSpaceSetHandle.SetToXml;
var
  NetPcCloudSpaceXml : TNetPcCloudSpaceXml;
begin
  NetPcCloudSpaceXml := TNetPcCloudSpaceXml.Create( PcID );
  NetPcCloudSpaceXml.SetSpace( UsedSpace, TotalSpace );
  NetPcCloudSpaceXml.SetBackupSpace( BackupSpace );
  MyNetPcXmlWrite.AddChange( NetPcCloudSpaceXml );
end;

procedure TNetPcSpaceSetHandle.Update;
begin
  inherited;

  SetToXml;
end;

{ TNetPcConfigSetHandle }

procedure TNetPcConfigSetHandle.SetToXml;
var
  NetPcCloudConfigXml : TNetPcCloudConfigXml;
begin
  NetPcCloudConfigXml := TNetPcCloudConfigXml.Create( PcID );
  NetPcCloudConfigXml.SetFileInvisible( IsFileInvisible );
  NetPcCloudConfigXml.SetIvPasswordMD5( IvPasswordMD5 );
  NetPcCloudConfigXml.SetRegisterEdition( RegisterEdition, RegisterHardCode );
  NetPcCloudConfigXml.SetCopyCount( CopyCount );
  MyNetPcXmlWrite.AddChange( NetPcCloudConfigXml );
end;

procedure TNetPcConfigSetHandle.Update;
begin
  inherited;
  SetToXml;
end;

{ TNetPcReadBackupPathHandle }

procedure TNetPcReadBackupPathHandle.AddToInfo;
var
  NetPcBackupPathAddInfo : TNetPcBackupPathAddInfo;
begin
    // ���� ��Ϣ
  NetPcBackupPathAddInfo := TNetPcBackupPathAddInfo.Create( PcID );
  NetPcBackupPathAddInfo.SetPathInfo( FullPath, PathType );
  NetPcBackupPathAddInfo.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
  NetPcBackupPathAddInfo.SetSpace( FolderSpace );
  NetPcBackupPathAddInfo.SetCountInfo( FileCount, CopyCount );
  NetPcBackupPathAddInfo.Update;
  NetPcBackupPathAddInfo.Free;
end;

procedure TNetPcReadBackupPathHandle.SetCountInfo(_FileCount,
  _CopyCount: Integer);
begin
  FileCount := _FileCount;
  CopyCount := _CopyCount;
end;

procedure TNetPcReadBackupPathHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TNetPcReadBackupPathHandle.SetPathInfo(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TNetPcReadBackupPathHandle.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TNetPcReadBackupPathHandle.Update;
begin
  AddToInfo;
end;

{ TNetPcAddBackupPathHandle }

procedure TNetPcAddBackupPathHandle.AddToXml;
var
  NetPcBackupPathAddXml : TNetPcBackupPathAddXml;
begin
    // д Xml
  NetPcBackupPathAddXml := TNetPcBackupPathAddXml.Create( PcID );
  NetPcBackupPathAddXml.SetPathInfo( FullPath, PathType );
  NetPcBackupPathAddXml.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
  NetPcBackupPathAddXml.SetSpace( FolderSpace );
  NetPcBackupPathAddXml.SetCountInfo( FileCount, CopyCount );
  MyNetPcXmlWrite.AddChange( NetPcBackupPathAddXml );
end;

procedure TNetPcAddBackupPathHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetPcClearBackupPathHandle }

procedure TNetPcClearBackupPathHandle.ClearInfo;
var
  NetPcBackupPathClearInfo : TNetPcBackupPathClearInfo;
begin
     // д �ڴ�
  NetPcBackupPathClearInfo := TNetPcBackupPathClearInfo.Create( PcID );
  NetPcBackupPathClearInfo.Update;
  NetPcBackupPathClearInfo.Free;
end;

procedure TNetPcClearBackupPathHandle.ClearXml;
var
  NetPcBackupPathClearXml : TNetPcBackupPathClearXml;
begin
     // д Xml
  NetPcBackupPathClearXml := TNetPcBackupPathClearXml.Create( PcID );
  MyNetPcXmlWrite.AddChange( NetPcBackupPathClearXml );
end;

procedure TNetPcClearBackupPathHandle.Update;
begin
  ClearInfo;
  ClearXml;
end;

{ TNetPcBackupPathOwnerAddHandle }

procedure TNetPcBackupPathOwnerReadHandle.AddToFace;
var
  IsOwnerOnline : Boolean;
  VstRestorePcAddLocation : TVstRestorePcAddLocation;
begin
  IsOwnerOnline := MyNetPcInfoReadUtil.ReadIsOnline( CopyOwner );

    // Restore Location
  VstRestorePcAddLocation := TVstRestorePcAddLocation.Create( PcID );
  VstRestorePcAddLocation.SetLocationInfo( CopyOwner, IsOwnerOnline );
  MyRestoreFileFace.AddChange( VstRestorePcAddLocation );
end;

procedure TNetPcBackupPathOwnerReadHandle.AddToInfo;
var
  NetPcBackupPathCopyOwnerAddInfo : TNetPcBackupPathCopyOwnerAddInfo;
begin
    // ���� ��Ϣ
  NetPcBackupPathCopyOwnerAddInfo := TNetPcBackupPathCopyOwnerAddInfo.Create( PcID );
  NetPcBackupPathCopyOwnerAddInfo.SetPathInfo( FullPath, CopyOwner );
  NetPcBackupPathCopyOwnerAddInfo.SetOwnerSpace( OwnerSpace );
  NetPcBackupPathCopyOwnerAddInfo.Update;
  NetPcBackupPathCopyOwnerAddInfo.Free;
end;

procedure TNetPcBackupPathOwnerReadHandle.SetOwnerSpace(_OwnerSpace: Int64);
begin
  OwnerSpace := _OwnerSpace;
end;

procedure TNetPcBackupPathOwnerReadHandle.SetPathInfo(_FullPath,
  _CopyOwner: string);
begin
  FullPath := _FullPath;
  CopyOwner := _CopyOwner;
end;

procedure TNetPcBackupPathOwnerReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TNetPcBackupPathOwnerAddHandle }

procedure TNetPcBackupPathOwnerAddHandle.AddToXml;
var
  NetPcBackupPathCopyOwnerAddXml : TNetPcBackupPathCopyOwnerAddXml;
begin
    // д Xml
  NetPcBackupPathCopyOwnerAddXml := TNetPcBackupPathCopyOwnerAddXml.Create( PcID );
  NetPcBackupPathCopyOwnerAddXml.SetPathInfo( FullPath, CopyOwner );
  NetPcBackupPathCopyOwnerAddXml.SetOwnerSpace( OwnerSpace );
  MyNetPcXmlWrite.AddChange( NetPcBackupPathCopyOwnerAddXml );
end;

procedure TNetPcBackupPathOwnerAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TNetPcAddCloudHandle }

procedure TNetPcAddCloudHandle.AddToEvent;
begin
  NetworkPcEvent.AddPc( PcID );
end;

procedure TNetPcAddCloudHandle.AddToXml;
var
  NetPcAddXml : TNetPcAddXml;
begin
    // д Xml
  NetPcAddXml := TNetPcAddXml.Create( PcID );
  NetPcAddXml.SetPcName( PcName );
  MyNetPcXmlWrite.AddChange( NetPcAddXml );
end;

procedure TNetPcAddCloudHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TNetPcAddPendingSpaceHandle }

procedure TNetPcAddPendingSpaceHandle.SetBackupPendingSpace(
  _BackupPendingSpace: Int64);
begin
  BackupPendingSpace := _BackupPendingSpace;
end;

procedure TNetPcAddPendingSpaceHandle.SetToInfo;
var
  NetPcBackupPendingInfo : TNetPcBackupPendingInfo;
begin
    // ��� Pcռ�� Pending �ռ���Ϣ
  NetPcBackupPendingInfo := TNetPcBackupPendingInfo.Create( PcID );
  NetPcBackupPendingInfo.SetFileSize( BackupPendingSpace );
  NetPcBackupPendingInfo.Update;
  NetPcBackupPendingInfo.Free;
end;

procedure TNetPcAddPendingSpaceHandle.Update;
begin
  SetToInfo;
end;

{ TNetPcSetIsBackupDesHandle }

procedure TNetPcSetIsBackupDesHandle.SetToXml;
var
  NetPcIsBackupDesXml : TNetPcIsBackupDesXml;
begin
  NetPcIsBackupDesXml := TNetPcIsBackupDesXml.Create( PcID );
  NetPcIsBackupDesXml.SetIsBackup( IsBackupDes );
  MyNetPcXmlWrite.AddChange( NetPcIsBackupDesXml );
end;

procedure TNetPcSetIsBackupDesHandle.Update;
begin
  inherited;

  SetToXml;
end;

{ TNetPcReachChangeHandle }

procedure TNetPcReachChangeHandle.RefreshReachFace;
var
  ReachStr : string;
  CloudStatusLvReachInfo : TVstCloudStatusReach;
begin
  ReachStr := MyNetPcInfoReadUtil.ReadReachInfo( PcID );

  CloudStatusLvReachInfo := TVstCloudStatusReach.Create( PcID );
  CloudStatusLvReachInfo.SetReachable( ReachStr );
  MyNetworkFace.AddChange( CloudStatusLvReachInfo );
end;

end.
