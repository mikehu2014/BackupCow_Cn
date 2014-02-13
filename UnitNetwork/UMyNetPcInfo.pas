unit UMyNetPcInfo;

interface

uses UChangeInfo, Generics.Collections, SyncObjs, SysUtils, UModelUtil, UMyUtil, Math,
     uDebug, DateUtils, UDataSetInfo;

type

{$Region ' ����Pc ���ݽṹ ' }

    // ��·�� ���ݸ���ӵ����
  TNetPcBackupPathCopyOwnerInfo = class
  public
    CopyOwner : string;
    OwnerSpace : Int64;
  public
    constructor Create( _CopyOwner : string; _OwnerSpace : Int64 );
  end;
  TNetPcBackupPathCopyOwnerPair = TPair< string , TNetPcBackupPathCopyOwnerInfo >;
  TNetPcBackupPathCopyOwnerHash = class(TStringDictionary< TNetPcBackupPathCopyOwnerInfo >);


    // �� ·����Ϣ
  TNetPcBackupPathInfo = class
  public
    FullPath, PathType : string;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
    FolderSpace : Int64;
    FileCount, CopyCount : Integer;
  public
    NetPcBackupPathCopyOwnerHash : TNetPcBackupPathCopyOwnerHash;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure SetSpace( _FolderSpace : Int64 );
    procedure SetCountInfo( _FileCount, _CopyCount : Integer );
    destructor Destroy; override;
  end;
  TNetPcBackupPathPair = TPair< string , TNetPcBackupPathInfo >;
  TNetPcBackupPathHash = class(TStringDictionary< TNetPcBackupPathInfo >);

    // Pc ��Ϣ ����
  TPcInfoBase = class
  public
    PcID, PcName : string;
  public
    StartTime : TDateTime;
    RanNum : Integer;
  public
    procedure SetPcInfo( _PcID, _PcName : string );
    procedure SetSortInfo( _StartTime : TDateTime; _RanNum : Integer );
  end;

    // ������ Pc ��Ϣ
  TPcInfo = class( TPcInfoBase )
  public
    PcHardCode : string;
  public
    LanIp, LanPort : string;
    InternetIp, InternetPort : string;
  public
    IsConnInternet : Boolean;
  public
    procedure SetPcHardCode( _PcHardCode : string );
    procedure SetLanInfo( _LanIp, _LanPort : string );
    procedure SetInternetInfo( _InternetIp, _InternetPort : string );
    procedure SetIsConnInternet( _IsConnInternet : Boolean );
  end;


    // ���� Pc ��Ϣ
  TNetPcInfo = class( TPcInfoBase )
  public
    Ip, Port : string;
    IsReach, IsBeReach : Boolean;
    IsActivate, IsOnline, IsServer : Boolean;
    IsBackup : Boolean;
  public
    LastOnlineTime : TDateTime;
    UsedSpace, TotalSpace, BackupSpace : Int64;
    BackupPendingSpace : Int64;
  public
    IsFileVisible : Boolean; // �Ƿ������ļ���Ϣ
    IvPasswordMD5 : string;  // �����ļ�����MD5ֵ
  public
    RegisterHardCode : string; // ע�� HardCode
    RegisterEdition : string; // ע��汾
    CopyCount : Integer; // ������
  public
    NetPcBackupPathHash : TNetPcBackupPathHash;  // ����·��
  public
    constructor Create;
    procedure SetSocketInfo( _Ip, _Port : string );
    destructor Destroy; override;
  end;

  TNetPcInfoPair = TPair< string , TNetPcInfo >;
  TNetPcInfoHash = class(TStringDictionary< TNetPcInfo >);

{$EndRegion}

{$Region ' ����ģʽ ���ݽṹ ' }

    // ����ģʽ ����
  TNetworkModeInfo = class
  public
    function getNetworkMode : string; virtual; abstract;
  end;

    // ������ģʽ
  TLanNetworkMode = class( TNetworkModeInfo )
  public
    function getNetworkMode : string;override;
  end;

    // Account Name ģʽ
  TStandardNetworkMode = class( TNetworkModeInfo )
  public
    AccountName : string;
    Password : string;
  public
    procedure SetAccountInfo( _AccountName, _Password : string );
    function getNetworkMode : string;override;
  end;

    // Internet Pc ģʽ
  TAdvanceNetworkMode = class( TNetworkModeInfo )
  public
    InternetName : string;
    Port : string;
  public
    procedure SetInternetInfo( _InternetName, _Port : string );
    function getNetworkMode : string;override;
  end;

{$EndRegion}

{$Region ' Master��Ϣ, ���ݽṹ ' }

  TMasterInfo = class
  public
    MaxStartTime : TDateTime;
    MaxRanNum : Integer;
    MaxPcID : string;
  public
    MasterID : string;
    MasterIp, MasterPort : string;
  public
    CheckLock : TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure ResetMaster;
    function CheckMax( PcID : string; StartTime : TDateTime; RanNum : Integer ) :Boolean;
    procedure SetMasterInfo( _MasterID, _MasterIp, _MasterPort : string );
  end;

{$EndRegion}

{$Region ' ����Pc ���ݽӿ� ' }

    // ���� ����
  TNetPcAccessInfo = class
  protected
    NetPcInfoHash : TNetPcInfoHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� Item
  TNetPcItemAccessInfo = class( TNetPcAccessInfo )
  public
    PcID : string;
  protected
    NetPcInfo : TNetPcInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetPcInfo: Boolean;
  end;

{$EndRegion}

{$Region ' ����Pc �����޸� ' }

  {$Region ' �޸� ����Pc��Ϣ ' }

    // ���� Pc ��Ϣ
  TResetPcInfo = class
  private
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;
  end;

    // ���� ���� Pc ״̬
    // ��������ʱʹ��
  TNetPcResetInfo = class( TNetPcAccessInfo )
  public
    procedure Update;
  end;

    // �޸�
  TNetPcWriteInfo = class( TNetPcItemAccessInfo )
  end;

  {$Region ' ��ɾ��Ϣ ' }

      // ���� Pc
  TNetPcAddInfo = class( TNetPcWriteInfo )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;
  end;

    // ɾ�� Pc
  TNetPcRemoveInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' λ����Ϣ ' }

    // �޸� Socket
  TNetPcSocketInfo = class( TNetPcWriteInfo )
  private
    Ip, Port : string;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure Update;
  end;

    // �޸� Reach
  TNetPcReachInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

    // �޸� BeReach
  TNetPcBeReachInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ״̬��Ϣ ' }

    // �޸� Sort
  TNetPcSortInfo = class( TNetPcWriteInfo )
  public
    StartTime : TDateTime;
    RanNum : Integer;
  public
    procedure SetSortInfo( _StartTime : TDateTime; _RanNum : Integer );
    procedure Update;
  end;

    // �޸� Online
  TNetPcOnlineInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

    // �޸� Offline
  TNetPcOfflineInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

    // �޸� Server
  TNetPcServerInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

    // ���� Pc
  TNetPcActivateInfo = class( TNetPcWriteInfo )
  public
    procedure Update;
  end;

    // �Ƿ񱸷ݵ� ��Pc
  TNetPcIsBackupDesInfo = class( TNetPcWriteInfo )
  public
    IsBackup : Boolean;
  public
    procedure SetIsBackup( _IsBackup : Boolean );
    procedure Update;
  end;

    // Backup Pending
  TNetPcBackupPendingInfo = class( TNetPcWriteInfo )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' �޸� ����Pc����Ϣ ' }

      // ����ʱ��
  TNetPcOnlineTimeInfo = class( TNetPcWriteInfo )
  public
    LastOnlineTime : TDateTime;
  public
    procedure SetLastOnlineTime( _LastOnlineTime : TDateTime );
    procedure Update;
  end;

    // �޸� �ƿռ���Ϣ
  TNetPcCloudSpaceInfo = class( TNetPcWriteInfo )
  public
    UsedSpace, TotalSpace : Int64;
    BackupSpace : Int64;
  public
    procedure SetSpace( _UsedSpace, _TotalSpace : Int64 );
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;
  end;

    // �޸� ��������Ϣ
  TNetPcCloudConfigInfo = class( TNetPcWriteInfo )
  public
    IsFileVisible: Boolean;
    IvPasswordMD5 : string;
  private
    RegisterHardCode : string;
    RegisterEdition : string;
    CopyCount : Integer;
  public
    procedure SetFileInvisible( _IsFileVisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
    procedure SetRegisterInfo( _RegisterEdition, _RegisterHardCode : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;
  end;

    // �޸� Pc �Ʊ���·��
  TNetPcBackupPathChangeInfo = class( TNetPcWriteInfo )
  protected
    NetPcBackupPathHash : TNetPcBackupPathHash;
  protected
    function FindNetPcBackupPathHash : Boolean;
  end;

    // ��� Pc �Ʊ���·��
  TNetPcBackupPathAddInfo = class( TNetPcBackupPathChangeInfo )
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
    procedure Update;
  end;

    // ��� Pc �Ʊ���·��
  TNetPcBackupPathClearInfo = class( TNetPcBackupPathChangeInfo )
  public
    procedure Update;
  end;

    // ��� Pc �Ʊ���·�� ӵ����
  TNetPcBackupPathCopyOwnerAddInfo = class( TNetPcBackupPathChangeInfo )
  public
    FullPath, CopyOwner : string;
    OwnerSpace : Int64;
  public
    procedure SetPathInfo( _FullPath, _CopyOwner : string );
    procedure SetOwnerSpace( _OwnerSpace : Int64 );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ����Pc ���ݶ�ȡ ' }

  {$Region ' ��ȡ ���� ' }

    // ��ȡ��Ϣ ����
  TNetPcReadInfo = class( TNetPcAccessInfo )
  end;

    // ��ռ�õ��ƿռ���Ϣ���ȴ�������Ϣ
  TNetPcReadBackupPendingSpace = class( TNetPcReadInfo )
  public
    function get : Int64;
  end;

    // ���ߵ� Pc ��Ŀ
  TNetPcReadActivateCount = class( TNetPcReadInfo )
  public
    function get : Integer;
  end;

  {$EndRegion}

  {$Region ' ��ȡ Item ' }

    // ��ȡ Item ����
  TNetPcItemReadInfo = class( TNetPcItemAccessInfo )
  end;

    // ��ȡ Pc ��
  TNetPcItemReadName = class( TNetPcItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ Ip
  TNetPcItemReadIp = class( TNetPcItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ Port
  TNetPcItemReadPort = class( TNetPcItemAccessInfo )
  public
    function get : string;
  end;

    // ��ȡ �Ƿ�����
  TNetPcItemReadIsOnline = class( TNetPcItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ�����
  TNetPcItemReadIsReach = class( TNetPcItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ Pc �������ʱ��
  TNetPcItemReadLastOnlineTime = class( TNetPcItemAccessInfo )
  public
    function get : TDateTime;
  end;

    // ��ȡ Pc �������ʱ��
  TNetPcItemReadAvailableSpace = class( TNetPcItemAccessInfo )
  public
    function get : Int64;
  end;

      // ��ȡ ���� ����·��
  TMyNetPcReadBackupPathListHandle = class( TNetPcItemReadInfo )
  public
    function get : TNetPcBackupPathHash;
  end;

    // ��ȡ �ɻָ��ı���·��
  TMyNetPcReadAvailableBackupPathHandle = class( TNetPcItemReadInfo )
  public
    function get : TNetPcBackupPathHash;
  end;

    // ��ȡ ���ɻָ��ı���·��
  TMyNetPcReadUnavailableBackupPathHandle = class( TNetPcItemReadInfo )
  public
    function get : TNetPcBackupPathHash;
  end;

      // ListView Network Hint ��Ϣ
  TNetPcReadHintInfo = class( TNetPcItemReadInfo )
  public
    function get : string;
  private
    function getSocketStr : string;
    function getAvailableSpaceStr : string;
  end;

    // Net Pc �� Reach ״̬
  TNetPcReadReachInfo = class( TNetPcItemReadInfo )
  public
    function get : string;
  end;

    // Restore LvBackupPathDetail ��ȡ
  TNetPcShowRestorePathDetailInfo = class( TNetPcItemReadInfo )
  private
    RestorePath : string;
  public
    procedure SetRestorelPath( _RestorePath : string );
    procedure Update;
  end;

    // ��ȡ Pc ����ϸ��Ϣ
  TNetPcShowDetailInfo = class( TNetPcItemReadInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

    // ��ȡ ������
  MyNetPcInfoReadUtil = class
  public
    class function ReadName( PcID : string ): string;
    class function ReadIp( PcID : string ): string;
    class function ReadPort( PcID : string ): string;
    class function ReadIsOnline( PcID : string ): Boolean;
    class function ReadIsReach( PcID : string ): Boolean;
    class function ReadLastOnlineTime( PcID : string ): TDateTime;
    class function ReadAvaliableSpace( PcID : string ): Int64;
  public
    class function ReadHintInfo( PcID : string ): string;
    class function ReadReachInfo( PcID : string ): string;
    class function ReadBackupPendingSpace : Int64;
    class function ReadActivePcCount : Integer;
  public
    class function ReadRestoreAblePath( PcID : string ) : TNetPcBackupPathHash;
    class function ReadUnrestoreAblePath( PcID : string ) : TNetPcBackupPathHash;
  public
    class procedure ShowPcDetail( PcID : string );
    class procedure ShowPcRestorePathDetail( RestorePcID, RestorePath : string );
  end;

{$EndREgion}


    // ���� Pc ��Ϣ ����
  TMyNetPcInfo = class( TMyDataInfo )
  public
    NetPcInfoHash : TNetPcInfoHash; // ���� Pc ��Ϣ
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  NetworkMode_LAN : string = 'LAN';  // ������
  NetworkMode_Standard : string = 'Standard';  // ��˾��
  NetworkMode_Advance : string = 'Advance';  // Internet

  BackupPriority_Alway = 'Alway';
  BackupPriority_Never = 'Nerver';
  BackupPriority_High = 'High';
  BackupPriority_Normal = 'Normal';
  BackupPriority_Low = 'Low';

var   // ��ʼ�� ��Ϣ
  Time_LastOnlineBackup : TDateTime = 0;

var
  PcInfo : TPcInfo;
  NetworkModeInfo : TNetworkModeInfo;
  MasterInfo : TMasterInfo;
  MyNetPcInfo : TMyNetPcInfo;

implementation

uses UNetworkFace, USearchServer, UMyJobInfo, URestoreFileFace, UBackupInfoFace,
     USettingInfo, UFileTransferFace, UMyShareFace, UBackupInfoControl, UMainForm;

{ TNetPcInfo }

constructor TNetPcInfo.Create;
begin
  IsReach := False;
  IsBeReach := False;
  IsOnline := False;
  IsServer := False;
  IsActivate := False;
  UsedSpace := 0;
  TotalSpace := 0;
  CopyCount := 0;
  BackupPendingSpace := 0;
  IsBackup := True;
  NetPcBackupPathHash := TNetPcBackupPathHash.Create;
end;

destructor TNetPcInfo.Destroy;
begin
  NetPcBackupPathHash.Free;
  inherited;
end;

procedure TNetPcInfo.SetSocketInfo(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;


{ TMySearchServerInfo }

constructor TMyNetPcInfo.Create;
begin
  inherited;
  NetPcInfoHash := TNetPcInfoHash.Create;
end;

destructor TMyNetPcInfo.Destroy;
begin
  NetPcInfoHash.Free;
  inherited;
end;

{ TStandardNetworkMode }

function TStandardNetworkMode.getNetworkMode: string;
begin
  Result := NetworkMode_Standard;
end;

procedure TStandardNetworkMode.SetAccountInfo(_AccountName, _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
end;


{ TAdvanceNetworkMode }

function TAdvanceNetworkMode.getNetworkMode: string;
begin
  Result := NetworkMode_Advance;
end;

procedure TAdvanceNetworkMode.SetInternetInfo(_InternetName, _Port: string);
begin
  InternetName := _InternetName;
  Port := _Port;
end;

{ TLanNetworkMode }

function TLanNetworkMode.getNetworkMode: string;
begin
  Result := NetworkMode_LAN;
end;

{ TSearchPcAddInfo }

procedure TNetPcAddInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

{ TPcInfoBase }

procedure TPcInfoBase.SetPcInfo(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TPcInfoBase.SetSortInfo(_StartTime: TDateTime; _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;

{ TPcInfo }

procedure TPcInfo.SetInternetInfo(_InternetIp, _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TPcInfo.SetIsConnInternet(_IsConnInternet: Boolean);
begin
  IsConnInternet := _IsConnInternet;
end;

procedure TPcInfo.SetLanInfo(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TPcInfo.SetPcHardCode(_PcHardCode: string);
begin
  PcHardCode := _PcHardCode;
end;

{ TMasterInfo }

function TMasterInfo.CheckMax(PcID: string; StartTime: TDateTime;
  RanNum: Integer): Boolean;
begin
  Result := False;

    // ����
  if PcID = PcInfo.PcID then
    Exit;

    // ����Ƿ����� Pc
  CheckLock.Enter;
  if ( PcID = MaxPcID ) or ( StartTime > MaxStartTime ) or
     ( ( StartTime = MaxStartTime ) and ( RanNum > MaxRanNum ) )
  then
  begin
    MaxPcID := PcID;
    MaxStartTime := StartTime;
    MaxRanNum := RanNum;
    Result := True;
  end;
  CheckLock.Leave;
end;

constructor TMasterInfo.Create;
begin
  CheckLock := TCriticalSection.Create;
end;

destructor TMasterInfo.Destroy;
begin
  CheckLock.Free;
  inherited;
end;

procedure TMasterInfo.SetMasterInfo(_MasterID,
  _MasterIp, _MasterPort: string);
begin
  CheckLock.Enter;
  if MasterID = '' then
  begin
    MasterID := _MasterID;
    MasterIp := _MasterIp;
    MasterPort := _MasterPort;
  end;
  CheckLock.Leave;
end;

procedure TMasterInfo.ResetMaster;
begin
  CheckLock.Enter;
  MaxPcID := PcInfo.PcID;
  MaxStartTime := PcInfo.StartTime;
  MaxRanNum := PcInfo.RanNum;
  MasterID := '';
  CheckLock.Leave;
end;

{ TNetPcReachInfo }

procedure TNetPcReachInfo.Update;
begin
      // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsReach := True;
end;

{ TNetPcBeReachInfo }

procedure TNetPcBeReachInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsBeReach := True;
end;

{ TNetPcOnlineInfo }

procedure TNetPcOnlineInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsOnline := True;
end;

{ TNetPcServerInfo }

procedure TNetPcServerInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsServer := True;
end;

{ TNetPcSortInfo }

procedure TNetPcSortInfo.SetSortInfo(_StartTime: TDateTime; _RanNum: Integer);
begin
  StartTime := _StartTime;
  RanNum := _RanNum;
end;

procedure TNetPcSortInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.SetSortInfo( StartTime, RanNum );
end;

{ TNetPcSocketInfo }

procedure TNetPcSocketInfo.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketInfo.Update;
begin
      // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.SetSocketInfo( Ip, Port );
end;

{ TNetPcResetInfo }

procedure TNetPcResetInfo.Update;
var
  p : TNetPcInfoPair;
  ResetPcInfo : TResetPcInfo;
begin
  for p in NetPcInfoHash do
  begin
    ResetPcInfo := TResetPcInfo.Create( p.Value.PcID );
    ResetPcInfo.Update;
    ResetPcInfo.Free;
  end;
end;

{ TNetPcRemoveInfo }

procedure TNetPcRemoveInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfoHash.Remove( PcID );
end;

procedure TNetPcAddInfo.Update;
begin
    // �Ѵ���
  if FindNetPcInfo then
  begin
    NetPcInfo.PcName := PcName;  // ����
    Exit;
  end;

    // ����
  NetPcInfo := TNetPcInfo.Create;
  NetPcInfo.SetPcInfo( PcID, PcName );
  NetPcInfoHash.AddOrSetValue( PcID, NetPcInfo );
end;

{ TSearchPcShowHintInfo }

function TNetPcReadHintInfo.get: string;
var
  ShowStr, TempStr : string;
begin
  Result := '';

    // ������
  if not FindNetPcInfo then
    Exit;

  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintName' );
  ShowStr := TempStr + NetPcInfo.PcName + #13#10;
  if NetPcInfo.IsOnline then
  begin
    ShowStr := ShowStr + getSocketStr;
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintAvailable' );
    ShowStr := ShowStr + TempStr + getAvailableSpaceStr
  end
  else
    ShowStr := ShowStr + frmMainForm.siLang_frmMainForm.GetText( 'HintOffline' );;
  Result := ShowStr;
end;

function TNetPcReadHintInfo.getAvailableSpaceStr: string;
begin
  if not NetPcInfo.IsOnline then
    Result := ''
  else
    Result := MySize.getFileSizeStr( NetPcInfo.TotalSpace - NetPcInfo.UsedSpace );
end;

function TNetPcReadHintInfo.getSocketStr: string;
var
  TempStr : string;
begin
  Result := NetworkListviewUtil.getLocation( NetPcInfo.Ip, NetPcInfo.Port );
  if Result <> '' then
  begin
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'lvPosition' ) + ': ';
    Result := TempStr + Result + #10#13;
  end;
end;

{ TNetPcOfflineInfo }

procedure TNetPcOfflineInfo.Update;
var
  ResetPcInfo : TResetPcInfo;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.BackupPendingSpace := 0;

  ResetPcInfo := TResetPcInfo.Create( PcID );
  ResetPcInfo.Update;
  ResetPcInfo.Free;
end;

{ TResetPcInfo }

constructor TResetPcInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TResetPcInfo.Update;
var
  NetPcInfoHash : TNetPcInfoHash;
  NetPcInfo : TNetPcInfo;
begin
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  if NetPcInfoHash.ContainsKey( PcID ) then
  begin
    NetPcInfo := NetPcInfoHash[ PcID ];
    NetPcInfo.IsActivate := False;
    NetPcInfo.IsOnline := False;
    NetPcInfo.IsServer := False;
  end;
end;

{ TNetPcBackupPathInfo }

constructor TNetPcBackupPathInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
  FolderSpace := 0;
  FileCount := 0;
  CopyCount := 0;
  IsEncrypt := False;
  NetPcBackupPathCopyOwnerHash := TNetPcBackupPathCopyOwnerHash.Create;
end;

{ TNetPcCheckReachFace }

function TNetPcReadReachInfo.get: string;
begin
  Result := '';

  if not FindNetPcInfo then
    Exit;

  Result := NetworkListviewUtil.getReachable( NetPcInfo.IsReach, NetPcInfo.IsBeReach );
end;

destructor TNetPcBackupPathInfo.Destroy;
begin
  NetPcBackupPathCopyOwnerHash.Free;
  inherited;
end;

procedure TNetPcBackupPathInfo.SetCountInfo(_FileCount, _CopyCount: Integer);
begin
  FileCount := _FileCount;
  CopyCount := _CopyCount;
end;

procedure TNetPcBackupPathInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TNetPcBackupPathInfo.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

{ TNetPcHeartBeatInfo }



procedure TNetPcCloudSpaceInfo.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TNetPcCloudSpaceInfo.SetSpace(_UsedSpace, _TotalSpace: Int64);
begin
  UsedSpace := _UsedSpace;
  TotalSpace := _TotalSpace;
end;

procedure TNetPcCloudSpaceInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.UsedSpace := UsedSpace;
  NetPcInfo.TotalSpace := TotalSpace;
  NetPcInfo.BackupSpace := BackupSpace;
end;

{ TNetPcFirstHeartBeatInfo }

procedure TNetPcCloudConfigInfo.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TNetPcCloudConfigInfo.SetFileInvisible(_IsFileVisible: Boolean);
begin
  IsFileVisible := _IsFileVisible;
end;

procedure TNetPcCloudConfigInfo.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TNetPcCloudConfigInfo.SetRegisterInfo(_RegisterEdition,
  _RegisterHardCode: string);
begin
  RegisterEdition := _RegisterEdition;
  RegisterHardCode := _RegisterHardCode;
end;

procedure TNetPcCloudConfigInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsFileVisible := IsFileVisible;
  NetPcInfo.IvPasswordMD5 := IvPasswordMD5;
  NetPcInfo.RegisterHardCode := RegisterHardCode;
  NetPcInfo.RegisterEdition := RegisterEdition;
  NetPcInfo.CopyCount := CopyCount;
end;

{ TNetPcOnlineTimeInfo }

procedure TNetPcOnlineTimeInfo.SetLastOnlineTime(_LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

procedure TNetPcOnlineTimeInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.LastOnlineTime := LastOnlineTime;
end;

{ TNetPcBackupPathAddInfo }

procedure TNetPcBackupPathAddInfo.SetCountInfo(_FileCount, _CopyCount: Integer);
begin
  FileCount := _FileCount;
  CopyCount := _CopyCount;
end;

procedure TNetPcBackupPathAddInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TNetPcBackupPathAddInfo.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TNetPcBackupPathAddInfo.SetPathInfo(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TNetPcBackupPathAddInfo.Update;
var
  NewPcBackupPathInfo : TNetPcBackupPathInfo;
begin
    // ������
  if not FindNetPcBackupPathHash then
    Exit;

  NewPcBackupPathInfo := TNetPcBackupPathInfo.Create( FullPath, PathType );
  NewPcBackupPathInfo.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
  NewPcBackupPathInfo.SetSpace( FolderSpace );
  NewPcBackupPathInfo.SetCountInfo( FileCount, CopyCount );
  NetPcBackupPathHash.AddOrSetValue( FullPath, NewPcBackupPathInfo );
end;

{ TNetPcBackupPathChangeInfo }

function TNetPcBackupPathChangeInfo.FindNetPcBackupPathHash: Boolean;
begin
  Result := FindNetPcInfo;
  if Result then
    NetPcBackupPathHash := NetPcInfo.NetPcBackupPathHash;
end;

{ TNetPcBackupPathClearInfo }

procedure TNetPcBackupPathClearInfo.Update;
begin
    // ������
  if not FindNetPcBackupPathHash then
    Exit;

  NetPcBackupPathHash.Clear;
end;

{ TNetPcBackupPathCopyOwnerInfo }

constructor TNetPcBackupPathCopyOwnerInfo.Create(_CopyOwner: string;
  _OwnerSpace: Int64);
begin
  CopyOwner := _CopyOwner;
  OwnerSpace := _OwnerSpace;
end;

{ TNetPcBackupPathCopyOwnerAddInfo }

procedure TNetPcBackupPathCopyOwnerAddInfo.SetOwnerSpace(_OwnerSpace: Int64);
begin
  OwnerSpace := _OwnerSpace;
end;

procedure TNetPcBackupPathCopyOwnerAddInfo.SetPathInfo(_FullPath,
  _CopyOwner: string);
begin
  FullPath := _FullPath;
  CopyOwner := _CopyOwner;
end;

procedure TNetPcBackupPathCopyOwnerAddInfo.Update;
var
  CopyOwnerHash : TNetPcBackupPathCopyOwnerHash;
begin
    // ������
  if not FindNetPcBackupPathHash then
    Exit;

    // ������
  if not  NetPcBackupPathHash.ContainsKey( FullPath ) then
    Exit;

    // ��� ·��ӵ����
  CopyOwnerHash := NetPcBackupPathHash[ FullPath ].NetPcBackupPathCopyOwnerHash;
  CopyOwnerHash.AddOrSetValue( CopyOwner, TNetPcBackupPathCopyOwnerInfo.Create( CopyOwner, OwnerSpace ) );
end;

{ TRestoreLvBackupPathDetailReadInfo }

procedure TNetPcShowRestorePathDetailInfo.SetRestorelPath(_RestorePath: string);
begin
  RestorePath := _RestorePath;
end;

procedure TNetPcShowRestorePathDetailInfo.Update;
var
  NetPcPathInfo : TNetPcBackupPathInfo;
  RestorePathDetaiAddlInfo : TRestorePathDetaiAddInfo;
  PathOwnerDetailHash : TPathOwnerDetailHash;
  p : TNetPcBackupPathCopyOwnerPair;
  IsOnline : Boolean;
  CopyOwner, OwnerName : string;
  OwnerSpace : Int64;
  LastOnlineTime : TDateTime;
  CopyCount : Integer;
  PathOwnerDetailInfo : TPathOwnerDetailInfo;
begin
  if not FindNetPcInfo then
    Exit;

  if not NetPcInfo.NetPcBackupPathHash.ContainsKey( RestorePath ) then
    Exit;

  NetPcPathInfo := NetPcInfo.NetPcBackupPathHash[ RestorePath ];

  CopyCount := NetPcPathInfo.CopyCount;
  if CopyCount = 0 then
    CopyCount := NetPcInfo.CopyCount;

  RestorePathDetaiAddlInfo := TRestorePathDetaiAddInfo.Create( RestorePath, NetPcPathInfo.PathType );
  RestorePathDetaiAddlInfo.SetFolderSize( NetPcPathInfo.FolderSpace, NetPcPathInfo.FileCount );
  RestorePathDetaiAddlInfo.SetCopyCount( CopyCount );
  PathOwnerDetailHash := RestorePathDetaiAddlInfo.PathOwnerDetailHash;

  for p in NetPcPathInfo.NetPcBackupPathCopyOwnerHash do
  begin
    CopyOwner := p.Value.CopyOwner;
    OwnerSpace := p.Value.OwnerSpace;
    IsOnline := MyNetPcInfoReadUtil.ReadIsOnline( CopyOwner );
    OwnerName := MyNetPcInfoReadUtil.ReadName( CopyOwner );
    LastOnlineTime := MyNetPcInfoReadUtil.ReadLastOnlineTime( CopyOwner );

    PathOwnerDetailInfo := TPathOwnerDetailInfo.Create( CopyOwner, OwnerSpace );
    PathOwnerDetailInfo.SetIsOnline( IsOnline );
    PathOwnerDetailInfo.SetPcName( OwnerName );
    PathOwnerDetailInfo.SetLastOnlineTime( LastOnlineTime );
    PathOwnerDetailHash.AddOrSetValue( CopyOwner, PathOwnerDetailInfo );
  end;

  MyRestoreFileFace.AddChange( RestorePathDetaiAddlInfo );
end;

{ TNetPcBackupPendingInfo }

procedure TNetPcBackupPendingInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TNetPcBackupPendingInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.BackupPendingSpace := NetPcInfo.BackupPendingSpace + FileSize;
  NetPcInfo.BackupPendingSpace := Max( NetPcInfo.BackupPendingSpace, 0 );
end;

{ TNetPcActivateInfo }

procedure TNetPcActivateInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  if not NetPcInfo.IsActivate then
  begin
    NetPcInfo.IsReach := False;
    NetPcInfo.IsBeReach := False;
    NetPcInfo.IsActivate := True;
  end;
end;

{ TNetPcReadDetailInfo }

procedure TNetPcShowDetailInfo.Update;
var
  LocalPcID : string;
  LocalPcInfo : TNetPcInfo;
  ShowNetworkPcDetail : TShowNetworkPcDetail;
  ReachableStr : string;
  AvalibleSpace : Int64;
  ShowMyBackupItemHash : TShowMyBackupItemHash;
  ShowMyBackupItemInfo : TShowMyBackupItemInfo;
  ShowBackupToMeItemHash : TShowBackupToMeHash;
  ShowBackupToMeItemInfo : TShowBackupToMeInfo;
  BackupItemHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  BackupSize : Int64;
begin
  if not FindNetPcInfo then
    Exit;

  LocalPcID := Network_LocalPcID;
  if not MyNetPcInfo.NetPcInfoHash.ContainsKey( LocalPcID ) then
    Exit;

    // ������Ϣ
  LocalPcInfo := MyNetPcInfo.NetPcInfoHash[ LocalPcID ];

  with NetPcInfo do
  begin
    ReachableStr := NetworkListviewUtil.getReachable( IsReach, IsBeReach );
    AvalibleSpace := TotalSpace - UsedSpace - BackupPendingSpace;

      // ������Ϣ
    ShowNetworkPcDetail := TShowNetworkPcDetail.Create( PcID, PcName );
    ShowNetworkPcDetail.SetOnlineInfo( IsOnline, LastOnlineTime );
    ShowNetworkPcDetail.SetPositionInfo( ReachableStr, Ip, Port );
    ShowNetworkPcDetail.SetShareSpace( TotalSpace, UsedSpace + BackupPendingSpace );
    ShowNetworkPcDetail.SetConsumeSpace( AvalibleSpace, BackupSpace );
  end;

    // �ҵı���
  ShowMyBackupItemHash := ShowNetworkPcDetail.ShowMyBackupItemHash;
  BackupItemHash := LocalPcInfo.NetPcBackupPathHash;
  for p in BackupItemHash do
    if p.Value.NetPcBackupPathCopyOwnerHash.ContainsKey( PcID ) then
    begin
      BackupSize := p.Value.NetPcBackupPathCopyOwnerHash[ PcID ].OwnerSpace;

      ShowMyBackupItemInfo := TShowMyBackupItemInfo.Create( p.Value.FullPath, p.Value.PathType );
      ShowMyBackupItemInfo.SetSpaceInfo( p.Value.FolderSpace, BackupSize );
      ShowMyBackupItemHash.AddOrSetValue( p.Value.FullPath, ShowMyBackupItemInfo );
    end;


    // ���ݵ���
  ShowBackupToMeItemHash := ShowNetworkPcDetail.ShowBackupToMeHash;
  BackupItemHash := NetPcInfo.NetPcBackupPathHash;
  for p in BackupItemHash do
    if p.Value.NetPcBackupPathCopyOwnerHash.ContainsKey( LocalPcID ) then
    begin
      BackupSize := p.Value.NetPcBackupPathCopyOwnerHash[ LocalPcID ].OwnerSpace;

      ShowBackupToMeItemInfo := TShowBackupToMeInfo.Create( p.Value.FullPath, p.Value.PathType );
      ShowBackupToMeItemInfo.SetSpaceInfo( p.Value.FolderSpace, BackupSize );
      ShowBackupToMeItemHash.AddOrSetValue( p.Value.FullPath, ShowBackupToMeItemInfo );
    end;

    // ��ʾ�� ���Դ��ڽ���
  MyNetworkFace.AddChange( ShowNetworkPcDetail );
end;


{ TNetPcIsBackupDesInfo }

procedure TNetPcIsBackupDesInfo.SetIsBackup(_IsBackup: Boolean);
begin
  IsBackup := _IsBackup;
end;

procedure TNetPcIsBackupDesInfo.Update;
begin
    // ������
  if not FindNetPcInfo then
    Exit;

  NetPcInfo.IsBackup := IsBackup;
end;

{ TMyNetPcReadBackupPathListHandle }

function TMyNetPcReadBackupPathListHandle.get: TNetPcBackupPathHash;
var
  NetPcPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  OutputPathInfo : TNetPcBackupPathInfo;
begin
  Result := TNetPcBackupPathHash.Create;
  if not FindNetPcInfo then
    Exit;
  NetPcPathHash := NetPcInfo.NetPcBackupPathHash;
  for p in NetPcPathHash do
  begin
    OutputPathInfo := TNetPcBackupPathInfo.Create( p.Value.FullPath, p.Value.PathType );
    OutputPathInfo.SetSpace( p.Value.FolderSpace );
    OutputPathInfo.SetCountInfo( p.Value.FileCount, p.Value.CopyCount );
    OutputPathInfo.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    Result.AddOrSetValue( p.Value.FullPath, OutputPathInfo );
  end;
end;

{ TMyNetPcReadAvailableBackupPathHandle }

function TMyNetPcReadAvailableBackupPathHandle.get: TNetPcBackupPathHash;
var
  NetPcPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  OutputPathInfo : TNetPcBackupPathInfo;
  IsExistOnline : Boolean;
  pp : TNetPcBackupPathCopyOwnerPair;
  OwnerPcID : string;
begin
  Result := TNetPcBackupPathHash.Create;
  if not FindNetPcInfo then
    Exit;
  NetPcPathHash := NetPcInfo.NetPcBackupPathHash;
  for p in NetPcPathHash do
  begin
    IsExistOnline := False;
    for pp in p.Value.NetPcBackupPathCopyOwnerHash do
    begin
      OwnerPcID := pp.Value.CopyOwner;
      if NetPcInfoHash.ContainsKey( OwnerPcID ) and NetPcInfoHash[ OwnerPcID ].IsOnline then
      begin
        IsExistOnline := True;
        Break;
      end;
    end;

    if not IsExistOnline then
      Continue;

    OutputPathInfo := TNetPcBackupPathInfo.Create( p.Value.FullPath, p.Value.PathType );
    OutputPathInfo.SetSpace( p.Value.FolderSpace );
    OutputPathInfo.SetCountInfo( p.Value.FileCount, p.Value.CopyCount );
    OutputPathInfo.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    Result.AddOrSetValue( p.Value.FullPath, OutputPathInfo );
  end;
end;

{ TMyNetPcReadUnavailableBackupPathHandle }

function TMyNetPcReadUnavailableBackupPathHandle.get: TNetPcBackupPathHash;
var
  NetPcPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  OutputPathInfo : TNetPcBackupPathInfo;
  IsExistOnline : Boolean;
  pp : TNetPcBackupPathCopyOwnerPair;
  OwnerPcID : string;
begin
  Result := TNetPcBackupPathHash.Create;
  if not FindNetPcInfo then
    Exit;
  NetPcPathHash := NetPcInfo.NetPcBackupPathHash;
  for p in NetPcPathHash do
  begin
    IsExistOnline := False;
    for pp in p.Value.NetPcBackupPathCopyOwnerHash do
    begin
      OwnerPcID := pp.Value.CopyOwner;
      if NetPcInfoHash.ContainsKey( OwnerPcID ) and NetPcInfoHash[ OwnerPcID ].IsOnline then
      begin
        IsExistOnline := True;
        Break;
      end;
    end;

    if IsExistOnline then
      Continue;

    OutputPathInfo := TNetPcBackupPathInfo.Create( p.Value.FullPath, p.Value.PathType );
    OutputPathInfo.SetSpace( p.Value.FolderSpace );
    OutputPathInfo.SetCountInfo( p.Value.FileCount, p.Value.CopyCount );
    OutputPathInfo.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    Result.AddOrSetValue( p.Value.FullPath, OutputPathInfo );
  end;
end;

{ TNetPcAccessInfo }

constructor TNetPcAccessInfo.Create;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
end;

destructor TNetPcAccessInfo.Destroy;
begin
  MyNetPcInfo.LeaveData;
  inherited;
end;

{ TNetPcItemAccessInfo }

constructor TNetPcItemAccessInfo.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TNetPcItemAccessInfo.FindNetPcInfo: Boolean;
begin
  Result := NetPcInfoHash.ContainsKey( PcID );
  if Result then
    NetPcInfo := NetPcInfoHash[ PcID ];
end;

{ MyNetPcInfoReadUtil }

class function MyNetPcInfoReadUtil.ReadActivePcCount: Integer;
var
  NetPcReadActivateCount : TNetPcReadActivateCount;
begin
  NetPcReadActivateCount := TNetPcReadActivateCount.Create;
  Result := NetPcReadActivateCount.get;
  NetPcReadActivateCount.Free;
end;

class function MyNetPcInfoReadUtil.ReadAvaliableSpace(PcID: string): Int64;
var
  NetPcItemReadAvailableSpace : TNetPcItemReadAvailableSpace;
begin
  NetPcItemReadAvailableSpace := TNetPcItemReadAvailableSpace.Create( PcID );
  Result := NetPcItemReadAvailableSpace.get;
  NetPcItemReadAvailableSpace.Free;
end;

class function MyNetPcInfoReadUtil.ReadBackupPendingSpace: Int64;
var
  NetPcReadBackupPendingSpace : TNetPcReadBackupPendingSpace;
begin
  NetPcReadBackupPendingSpace := TNetPcReadBackupPendingSpace.Create;
  Result := NetPcReadBackupPendingSpace.get;
  NetPcReadBackupPendingSpace.Free;
end;

class function MyNetPcInfoReadUtil.ReadHintInfo(PcID: string): string;
var
  NetPcReadHintInfo : TNetPcReadHintInfo;
begin
  NetPcReadHintInfo := TNetPcReadHintInfo.Create( PcID );
  Result := NetPcReadHintInfo.get;
  NetPcReadHintInfo.Free;
end;

class function MyNetPcInfoReadUtil.ReadIp(PcID: string): string;
var
  NetPcItemReadIp : TNetPcItemReadIp;
begin
  NetPcItemReadIp := TNetPcItemReadIp.Create( PcID );
  Result := NetPcItemReadIp.get;
  NetPcItemReadIp.Free;
end;

class function MyNetPcInfoReadUtil.ReadIsOnline(PcID: string): Boolean;
var
  NetPcItemReadIsOnline : TNetPcItemReadIsOnline;
begin
  NetPcItemReadIsOnline := TNetPcItemReadIsOnline.Create( PcID );
  Result := NetPcItemReadIsOnline.get;
  NetPcItemReadIsOnline.Free;
end;

class function MyNetPcInfoReadUtil.ReadIsReach(PcID: string): Boolean;
var
  NetPcItemReadIsReach : TNetPcItemReadIsReach;
begin
  NetPcItemReadIsReach := TNetPcItemReadIsReach.Create( PcID );
  Result := NetPcItemReadIsReach.get;
  NetPcItemReadIsReach.Free;
end;

class function MyNetPcInfoReadUtil.ReadLastOnlineTime(PcID: string): TDateTime;
var
  NetPcItemReadLastOnlineTime : TNetPcItemReadLastOnlineTime;
begin
  NetPcItemReadLastOnlineTime := TNetPcItemReadLastOnlineTime.Create( PcID );
  Result := NetPcItemReadLastOnlineTime.get;
  NetPcItemReadLastOnlineTime.Free;
end;

class function MyNetPcInfoReadUtil.ReadName(PcID: string): string;
var
  NetPcItemReadName : TNetPcItemReadName;
begin
  NetPcItemReadName := TNetPcItemReadName.Create( PcID );
  Result := NetPcItemReadName.get;
  NetPcItemReadName.Free;
end;

class function MyNetPcInfoReadUtil.ReadPort(PcID: string): string;
var
  NetPcItemReadPort : TNetPcItemReadPort;
begin
  NetPcItemReadPort := TNetPcItemReadPort.Create( PcID );
  Result := NetPcItemReadPort.get;
  NetPcItemReadPort.Free;
end;

class function MyNetPcInfoReadUtil.ReadReachInfo(PcID: string): string;
var
  NetPcReadReachInfo : TNetPcReadReachInfo;
begin
  NetPcReadReachInfo := TNetPcReadReachInfo.Create( PcID );
  Result := NetPcReadReachInfo.get;
  NetPcReadReachInfo.Free;
end;

class function MyNetPcInfoReadUtil.ReadRestoreAblePath(
  PcID: string): TNetPcBackupPathHash;
var
  MyNetPcReadAvailableBackupPathHandle : TMyNetPcReadAvailableBackupPathHandle;
begin
  MyNetPcReadAvailableBackupPathHandle := TMyNetPcReadAvailableBackupPathHandle.Create( PcID );
  Result := MyNetPcReadAvailableBackupPathHandle.get;
  MyNetPcReadAvailableBackupPathHandle.Free;
end;

class function MyNetPcInfoReadUtil.ReadUnrestoreAblePath(
  PcID: string): TNetPcBackupPathHash;
var
  MyNetPcReadUnavailableBackupPathHandle : TMyNetPcReadUnavailableBackupPathHandle;
begin
  MyNetPcReadUnavailableBackupPathHandle := TMyNetPcReadUnavailableBackupPathHandle.Create( PcID );
  Result := MyNetPcReadUnavailableBackupPathHandle.get;
  MyNetPcReadUnavailableBackupPathHandle.Free;
end;

class procedure MyNetPcInfoReadUtil.ShowPcDetail(PcID: string);
var
  NetPcShowDetailInfo : TNetPcShowDetailInfo;
begin
  NetPcShowDetailInfo := TNetPcShowDetailInfo.Create( PcID );
  NetPcShowDetailInfo.Update;
  NetPcShowDetailInfo.Free;
end;

class procedure MyNetPcInfoReadUtil.ShowPcRestorePathDetail(RestorePcID, RestorePath: string);
var
  NetPcShowRestorePathDetailInfo : TNetPcShowRestorePathDetailInfo;
begin
  NetPcShowRestorePathDetailInfo := TNetPcShowRestorePathDetailInfo.Create( RestorePcID );
  NetPcShowRestorePathDetailInfo.SetRestorelPath( RestorePath );
  NetPcShowRestorePathDetailInfo.Update;
  NetPcShowRestorePathDetailInfo.Free;
end;

{ TNetPcItemReadPcName }

function TNetPcItemReadName.get: string;
begin
  if not FindNetPcInfo then
    Result := PcID
  else
    Result := NetPcInfo.PcName;
end;

{ TNetPcItemReadSocket }

function TNetPcItemReadIp.get: string;
begin
  Result := '';
  if not FindNetPcInfo then
    Exit;
  Result := NetPcInfo.Ip;
end;

{ TNetPcItemReadLastOnlineTime }

function TNetPcItemReadLastOnlineTime.get: TDateTime;
begin
  Result := 0;
  if not FindNetPcInfo then
    Exit;
  Result := NetPcInfo.LastOnlineTime;
end;

{ TNetPcItemReadIsOnline }

function TNetPcItemReadIsOnline.get: Boolean;
begin
  Result := False;
  if not FindNetPcInfo then
    Exit;
  Result := NetPcInfo.IsOnline;
end;

{ TNetPcItemReadPort }

function TNetPcItemReadPort.get: string;
begin
  Result := '';
  if not FindNetPcInfo then
    Exit;
  Result := NetPcInfo.Port;
end;

{ TNetPcItemReadIsReach }

function TNetPcItemReadIsReach.get: Boolean;
begin
  Result := False;
  if not FindNetPcInfo then
    Exit;
  Result := NetPcInfo.IsReach;
end;

{ TNetPcReadBackupPendingSpace }

function TNetPcReadBackupPendingSpace.get: Int64;
var
  p : TNetPcInfoPair;
begin
  Result := 0;
  for p in NetPcInfoHash do
    if p.Value.IsOnline then
      Result := Result + p.Value.BackupPendingSpace;
end;

{ TNetPcReadActivateCount }

function TNetPcReadActivateCount.get: Integer;
var
  p : TNetPcInfoPair;
begin
  Result := 0;
  for p in NetPcInfoHash do
    if p.Value.IsActivate then
      Inc( Result );
end;

{ TNetPcItemReadAvailableSpace }

function TNetPcItemReadAvailableSpace.get: Int64;
begin
  Result := 0;
  if not FindNetPcInfo then
    Exit;
  Result := Max( NetPcInfo.TotalSpace - NetPcInfo.UsedSpace, 0 );
end;

end.
