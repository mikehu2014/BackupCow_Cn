unit UNetworkFace;

interface

uses UChangeInfo, ComCtrls, ExtCtrls, ListActns, SysUtils, UMyUtil, Math, RzStatus, Classes,
     VirtualTrees, Graphics, Generics.Collections, UModelUtil, Series, ValEdit, SyncObjs,
     DateUtils, uDebug;

type

{$Region ' Network Listview ���� '}

  {$Region ' ���ݽṹ�븨���� ' }

  TNetworkPcItemData = class
  public
    PcID : string;
    UploadingCount : Integer;
    DownloadingCount : Integer;
  public
    constructor Create( _PcID : string );
  end;

  NetworkListviewUtil = class
  public
    class function getReachable( IsReach, IsBeReach : Boolean ): string;
    class function getLocation( Ip, Port : string ): string;
  end;

  {$EndRegion}

  {$Region ' д �仯��Ϣ ' }

    // �޸� ����
  TLvNetworkChange = class( TChangeInfo )
  public
    LvNetwork : TListView;
  public
    procedure Update;override;
  end;

    // ���
  TNetworkLvClear = class( TLvNetworkChange )
  public
    procedure Update;override;
  end;

  {$Region ' Pc ������Ϣ ' }

    // �޸� Pc ����
  TLvNetworkWrite = class( TLvNetworkChange )
  public
    PcID : string;
  protected
    PcItem : TListItem;
    ItemData : TNetworkPcItemData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcItem : Boolean;
  end;

    // ���
  TLvNetworkAdd = class( TLvNetworkWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  private
    procedure CreatePcItem;
  end;

    // ���� ͼ��
  TLvNetworkOnline = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // ���� ͼ��
  TLvNetworkOffline = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // Server ͼ��
  TLvNetworkServer = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Pc ������Ϣ ' }

    // ��� �ϴ�
  TLvNetworkAddUpload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // ��� ����
  TLvNetworkAddDownload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // �Ƴ� �ϴ�
  TLvNetworkRemoveUpload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // �Ƴ� ����
  TLvNetworkRemoveDownload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  end;

    // ���� �ϴ�
  TNetworkLvItemHideUpload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  private
    procedure CheckHideUploadColumn;
  end;

    // ���� ����
  TNetworkLvItemHideDownload = class( TLvNetworkWrite )
  public
    procedure Update;override;
  private
    procedure CheckHideDownloadColumn;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' Network Listview ���������߳� ' }

  TNetworkLvHideInfo = class
  public
    PcID : string;
    StartTime : TDateTime;
  public
    constructor Create( _PcID : string );
  end;
  TNetworkLvHidePair = TPair< string , TNetworkLvHideInfo >;
  TNetworkLvHideHash = class(TStringDictionary< TNetworkLvHideInfo >);

    // �������߳�
  TNetworkLvItemHideThread = class( TThread )
  private
    Lock : TCriticalSection;
    NetworkLvDownHideHash : TNetworkLvHideHash;
    NetworkLvUpHideHash : TNetworkLvHideHash;
  public
    constructor Create;
    procedure AddDownHideInfo( PcID : string );
    procedure AddUpHideInfo( PcID : string );
    function ExistPc( PcID : string ): Boolean;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ExistHidePc : Boolean;
    procedure CheckLvHideDown;
    procedure CheckLvHideUp;
  end;

  {$EndRegion}

  {$Region ' �� �仯��Ϣ ' }

  TNetworkLvReadInfo = class( TChangeInfo )
  end;

  TNetworkLvShowHintInfo = class( TNetworkLvReadInfo )
  public
    HintStr : string;
  public
    procedure SetHintStr( _HintStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' CloudStatus Listview ���� ' }

  PCloudPcData = ^TCloudPcData;
  TCloudPcData = record
  public
    PcID, PcName : string;
    UsedSpace, TotalSpace, BackupSpace : Int64;
    LastOnline : TDateTime;
    Reachable, Position : string;
  public
    IsServer, IsOnline : Boolean;
  public
    HasMyBackupSize : Int64;
    HasMyBackupFile : Integer;
  end;

  CloudStatusVstReader = class
  public
    class function getPcItemData( PcID : string ):PVirtualNode;
  public
    class procedure RefreshNodeVisible( Node : PVirtualNode );
  end;

    // ����
  TVstCloudStatusChange = class( TChangeInfo )
  protected
    vstCloudPc : TVirtualStringTree;
  public
    procedure Update;override;
  end;

   // �޸�
  TVstCloudStatusWrite = class( TVstCloudStatusChange )
  public
    PcID : string;
  protected
    PcNode : PVirtualNode;
    NodeData : PCloudPcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
  protected
    procedure RefreshNode;
    procedure RefreshTotalSpace; // ˢ���ܿռ�
    procedure RefershNodeVisible; // ���˽ڵ�
  end;

    // ���
  TVstCloudStatusAdd = class( TVstCloudStatusWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  private
    procedure CreatePcNode;
  end;

    // �޸� Socket
  TVstCloudStatusSocket = class( TVstCloudStatusWrite )
  private
    Ip, Port : string;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure Update;override;
  end;

    // �޸� Reachable
  TVstCloudStatusReach = class( TVstCloudStatusWrite )
  private
    Reachable : string;
  public
    procedure SetReachable( _Reachable : string );
    procedure Update;override;
  end;

    // ����
  TVstCloudStatusOnline = class( TVstCloudStatusWrite )
  public
    procedure Update;override;
  end;

    // ����
  TVstCloudStatusOffline = class( TVstCloudStatusWrite )
  public
    procedure Update;override;
  end;

    // Server
  TVstCloudStatusServer = class( TVstCloudStatusWrite )
  public
    procedure Update;override;
  end;

    // �޸� ӵ���ҵı���
  TVstCloudStatusHasMyBackupChange = class( TVstCloudStatusWrite )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ��� �ҵı����ļ���Ϣ
  TVstCloudStatusHasMyBackupAdd = class( TVstCloudStatusHasMyBackupChange )
  public
    procedure Update;override;
  end;

    // ɾ�� �ҵı����ļ���Ϣ
  TVstCloudStatusHasMyBackupRemove = class( TVstCloudStatusHasMyBackupChange )
  public
    procedure Update;override;
  end;

    // ��� ӵ�б���������Ϣ
  TVstCloudStatusMyBackupClear = class( TVstCloudStatusChange )
  public
    procedure Update;override;
  end;

    // ���� �ҵı����ļ���Ϣ
  TVstCloudStatusHasMyBackupSet = class( TVstCloudStatusHasMyBackupChange )
  public
    procedure Update;override;
  end;

    // �޸� �ռ���Ϣ
  TVstCloudStatusSpace = class( TVstCloudStatusWrite )
  public
    UsedSpace, TotalSpace : Int64;
    BackupSpace : Int64;
  public
    procedure SetSpace( _UsedSpace, _TotalSpace : Int64 );
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;override;
  end;

    // ����ʱ��
  TVstCloudStatusOnlineTime = class( TVstCloudStatusWrite )
  public
    LastOnlineTime : TDateTime;
  public
    procedure SetLastOnlineTime( _LastOnlineTime : TDateTime );
    procedure Update;override;
  end;

    // ��ȡ ���һ��������Ϣ
  TVstCloudStatusLastOnline = class( TVstCloudStatusOnlineTime )
  public
    BackupSpace : Int64;
  public
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;override;
  end;

    // ����������
  TVstCloudStatusServerOffline = class( TVstCloudStatusChange )
  public
    procedure Update;override;
  end;

    // ˢ�� Only Show
  TVstCloudStatusRefreshOnlyShow = class( TVstCloudStatusChange )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' CloudTotalStatus Listview ���� ' }

    // ˢ��
  TCloudTotalLvRefreshInfo = class( TChangeInfo )
  public
    TotalSpace, UsedSpace : Int64;
    AvailableSpace, MyAvailableSpace : Int64;
  public
    constructor Create( _TotalSpace, _UsedSpace : Int64 );
    procedure SetAvailableSpace( _AvailableSpace, _MyAvailableSpace : Int64 );
    procedure Update;override;
  private
    procedure ShowDetailList;
    procedure ShowChart;
  end;

{$EndRegion}

{$Region ' My Backup Destination ���� ' }

  TVstMyBackupDesData = record
  public
    PcID, PcName : WideString;
    TotalSpace, AvalableSpace : Int64;
    IsOnline, IsBackup : Boolean;
  end;
  PVstMyBackupDesData = ^TVstMyBackupDesData;

    // ����
  TVstMyBackupDesChange = class( TChangeInfo )
  public
    VstBackupDes : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // �޸�
  TVstMyBackupDesWrite = class( TVstMyBackupDesChange )
  public
    PcID : string;
  protected
    PcNode : PVirtualNode;
    NodeData : PVstMyBackupDesData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
  protected
    procedure RefreshNode;
  end;

    // ���
  TVstMyBackupDesAdd = class( TVstMyBackupDesWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  private
    procedure AddPcNode;
  end;

    // ����
  TVstMyBackupDesOnline = class( TVstMyBackupDesWrite )
  public
    procedure Update;override;
  end;

    // ����
  TVstMyBackupDesOffline = class( TVstMyBackupDesWrite )
  public
    procedure Update;override;
  end;

    // Server ����
  TVstMyBackupDesServerOffline = class( TVstMyBackupDesChange )
  public
    procedure Update;override;
  private
    procedure PcOffline( PcID : string );
  end;

    // ���� ���ÿռ�
  TVstMyBackupDesSetAvailableSpace = class( TVstMyBackupDesWrite )
  public
    TotalSpace : Int64;
    AvaliableSpace : Int64;
  public
    procedure SetSpaceInfo( _TotalSpace, _AvaliableSpace : Int64 );
    procedure Update;override;
  end;

    // ���� �Ƿ񱸷ݵ�Pc
  TVstMyBackupDesSetIsBackup = class( TVstMyBackupDesWrite )
  public
    IsBackup : Boolean;
  public
    procedure SetIsBackup( _IsBackup : Boolean );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' My Backup Cloud Status ���� ' }

    // Lv Item ����
  TMyBackupCloudLvData = class
  public
    PcID, PcName : string;
    FileCount : Integer;
    FileSpace : Int64;
    Percentage : Integer;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
  end;

    // ��ȡ Lv Item
  MyBackupCloudLvReader = class
  public
    class function getPcItem( PcID : string ):TListItem;
    class function CreatePcItem( PcID : string ): TListItem;
  private
    class function ReadPcName( PcID : string ): string;
    class function ReadPcIsOnline( PcID : string ): Boolean;
  end;

    // �޸� My Backup Cloud Status
  TMyBackupCloudLvChangeInfo = class( TChangeInfo )
  public
    PcID : string;
  public
    LvMyCloudPc : TListView;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // �޸� �ռ���Ϣ ����
  TMyBackupCloudLvWriteSpace = class( TMyBackupCloudLvChangeInfo )
  public
    PcItem : TListItem;
    ItemData : TMyBackupCloudLvData;
  public
    FileCount : Integer;
    FileSpace : Int64;
  public
    procedure SetFileSpace( _FileSpace : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  protected
    procedure RefreshSpaceShow;
  end;

    // ��� �ռ���Ϣ
  TMyBackupCloudLvAddSpace = class( TMyBackupCloudLvWriteSpace )
  public
    procedure Update;override;
  end;

    // ɾ�� �ռ���Ϣ
  TMyBackupCloudLvRemoveSpace = class( TMyBackupCloudLvWriteSpace )
  public
    procedure Update;override;
  end;

    // ��� Pc ��Ϣ
  TMyBackupCloudLvClearInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸� ������Ϣ
  TMyBackupCloudLvOnlineInfo = class( TMyBackupCloudLvChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸� ������Ϣ
  TMyBackupCloudLvOfflineInfo = class( TMyBackupCloudLvChangeInfo )
  public
    procedure Update;override;
  end;

  TMyBackupCloudPcChartInfo = class
  public
    PcName : string;
    Percentage : Integer;
    IsOnline : Boolean;
  public
    constructor Create( _PcName : string; _Percentage : Integer );
    procedure SetIsOnline( _IsOnline : Boolean );
  end;
  TMyBackupCloudPcChartList = class( TObjectList<TMyBackupCloudPcChartInfo> )
  public
    procedure SortByPercentage;
  end;

    // ˢ�� ��ͼ
  TMyBackupCloudChartRefreshInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // ˢ�±�ͼ �߳�
  TMyCloudPcChartRefreshThread = class( TThread )
  private
    IsRefresh : Boolean;
  public
    constructor Create;
    procedure SetRefreshChart;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure RefreshChart;
  end;

{$EndRegion}

{$Region ' FileSearch Comobox ' }

  TCbbSearchData = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

  {$Region ' Cbb Location ' }

  TCbbLocationData = class( TCbbSearchData )
  end;

  {$Region ' ��ȡ / ���� ' }

  LocationCbbReader = class
  public
    class function getPcItem( PcID : string ):TListControlItem;
    class function createPcItem( PcID : string ):TListControlItem;
  end;

  {$EndRegion}

  {$Region ' �޸� ' }

    // ����
  TLocationCbbChangeInfo = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // �޸� Pc ����
  TLocationCbbWriteInfo = class( TLocationCbbChangeInfo )
  protected
    PcItem : TListControlItem;
  public
    procedure Update;override;
  end;

    // ���
  TLocationCbbAddInfo = class( TLocationCbbWriteInfo )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // �Ƴ�
  TLocationCbbRemoveInfo = class( TLocationCbbChangeInfo )
  public
    procedure Update;override;
  end;

    // ���
  TLocationCbbClearInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' Cbb Owner ' }

  TCbbOwnerData = class( TCbbSearchData )
  public
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    InputIvPasswordMD5 : string;
  public
    procedure SetIsFileInvisible( _IsFileInvisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
  end;

  {$Region ' ��ȡ / ���� ' }

  OwnerCbbReader = class
  public
    class function getPcItem( PcID : string ):TListControlItem;
    class function createPcItem( PcID : string ):TListControlItem;
  end;

  {$EndRegion}

  {$Region ' �޸� ' }

    // ����
  TOwnerCbbChangeInfo = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // �޸� Pc ����
  TOwnerCbbWriteInfo = class( TOwnerCbbChangeInfo )
  protected
    PcItem : TListControlItem;
    CbbOwnerData : TCbbOwnerData;
  public
    procedure Update;override;
  end;

    // ���
  TOwnerCbbAddInfo = class( TOwnerCbbWriteInfo )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // ����
  TOwnerCbbOnlineInfo = class( TOwnerCbbWriteInfo )
  public
    procedure Update;override;
  end;

    // ����
  TOwnerCbbOfflineInfo = class( TOwnerCbbWriteInfo  )
  public
    procedure Update;override;
  end;

    // ����������
  TOwnerCbbServerOfflineInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // File Invisble �ı�
  TOwnerCbbFileInvisibleInfo = class( TOwnerCbbWriteInfo )
  private
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    procedure SetIsFileInvisible( _IsFileInvisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
    procedure Update;override;
  end;

    // ���������
  TOwnerCbbInputIvPasswordMD5Info = class( TOwnerCbbWriteInfo )
  private
    InputIvPasswordMD5 : string;
  public
    procedure SetInputIvPasswordMD5( _InputIvPasswordMD5 : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$EndRegion}

{$EndRegion}

{$Region ' Register ListView ���� '}

  {$Region ' ���ݽṹ ' }

  TRegisterPcItemData = class
  public
    PcID, PcName : string;
    RegisterHardCode, RegisterEdition : string;
  public
    constructor Create( _PcID : string );
    procedure SetPcName( _PcName : string );
  end;

  {$EndRegion}

  {$Region ' �����޸� ' }

    // ����
  TLvRegisterChange = class( TChangeInfo )
  public
    LvRegisterPc : TListView;
  public
    procedure Update;override;
  end;

    // �޸�
  TLvRegisterWrite = class( TLvRegisterChange )
  public
    PcID : string;
  protected
    PcItem : TListItem;
    ItemData : TRegisterPcItemData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcItem : Boolean;
  end;

    // ���
  TLvRegisterAdd = class( TLvRegisterWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  private
    procedure AddPcItem;
  end;

    // ����ע��汾
  TLvRegisterEdition = class( TLvRegisterWrite )
  public
    RegisterHardCode : string;
    RegisterEdition : string;
  public
    procedure SetRegisterEdition( _RegisterEdition, _RegisterHardCode : string );
    procedure Update;override;
  end;

    // ���� ͼ��
  TLvRegisterOnline = class( TLvRegisterWrite )
  public
    procedure Update;override;
  end;

    // ���� ͼ��
  TLvRegisterOffline = class( TLvRegisterWrite )
  public
    procedure Update;override;
  end;

    // ����������
  TLvRegisterServerOffline = class( TLvRegisterChange )
  public
    procedure Update;override;
  end;

    // ˢ�� ע����Ϣ
  TLvRegisterRefresh = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' StatusBar ������� '}

  TSbMyStatusChangeInfo = class( TChangeInfo )
  protected
    SbMyStatus : TRzGlyphStatus;
  public
    procedure Update;override;
  end;

    // δ����
  TSbMyStatusNotConnInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

    // ��������
  TSbMyStatusConningInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

    // ������
  TSbMyStatusConnInfo = class( TSbMyStatusChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Settting ���� ' }

    // ��������ʱ ��ȡ���� InternetIp Ȼ�� ӳ�䵽 Settings ����
  TInternetSocketChangeInfo = class( TChangeInfo )
  public
    InternetIp, InternetPort : string;
  public
    constructor Create( _InternetIp, _InternetPort : string );
    procedure Update;override;
  end;

    // ��¼ Account ��������
  TStandardError = class( TChangeInfo )
  private
    AccountName : string;
  public
    constructor Create( _AccountName : string );
  end;

    // �������
  TStandardPasswordError = class( TStandardError )
  public
    procedure Update;override;
  end;

    // �ʺŲ�����
  TStandardAccountError = class( TStandardError )
  private
    Password : string;
  public
    procedure SetPassword( _Password : string );
    procedure Update;override;
  end;

    // Dns Error
  TAdvanceDnsError = class( TChangeInfo )
  private
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
    procedure Update;override;
  end;

    // Dns ���
  TAdvanceDnsComplete = class( TChangeInfo )
  public
    Domain, DnsResult : string;
    IsParseError : Boolean;
  public
    constructor Create( _Domain, _DnsResult : string );
    procedure SetIsParseError( _IsParseError : Boolean );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Pm Network ���� ' }

  TPmNetworkOpenChangeInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  TPmNetworkCloseChangeInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  TPmNetworkReturnLocalNetwork = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Network Conn ����'}

    // �޸� ����
  TPlNetworkConnChangeInfo = class( TChangeInfo )
  protected
    plNetworkConn : TPanel;
    plFileSendDesConn : TPanel;
  public
    procedure Update;override;
  end;

    // ��ʾ�����ȴ�
  TPlNetworkConnShowInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

    // ����ʱ
  TPlNetworkConnRemainInfo = class( TPlNetworkConnChangeInfo )
  public
    ShowTime : Integer;
  public
    constructor Create( _ShowTime : Integer );
    procedure Update;override;
  end;

    // ���������ȴ�
  TPlNetworkConnHideInfo = class( TPlNetworkConnChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Form Network Pc Detail ' }

    // �ҵı���
  TShowMyBackupItemInfo = class
  public
    FullPath, PathType : string;
    TotalSize, BackupSize : Int64;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetSpaceInfo( _TotalSize, _BackupSize : Int64 );
  end;
  TShowMyBackupItemPair = TPair< string , TShowMyBackupItemInfo >;
  TShowMyBackupItemHash = class(TStringDictionary< TShowMyBackupItemInfo >);

    // ���ݵ��һ�
  TShowBackupToMeInfo = class
  public
    FullPath, PathType : string;
    TotalSize, BackupSize : Int64;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetSpaceInfo( _TotalSize, _BackupSize : Int64 );
  end;
  TShowBackupToMePair = TPair< string , TShowBackupToMeInfo >;
  TShowBackupToMeHash = class(TStringDictionary< TShowBackupToMeInfo >);


    // ��ʾ Pc ��ϸ��Ϣ
  TShowNetworkPcDetail = class( TChangeInfo )
  public
    ComputerID, ComputerName : string;
    IsOnline : Boolean;
    LastOnlineTime : TDateTime;
    Reachable, Ip, Port : string;
  public
    TotalShareSpace, UsedSpace : Int64;
    AvailableSpace, CloudConsumption : Int64;
  public
    ShowMyBackupItemHash : TShowMyBackupItemHash; // �ҵı���
    ShowBackupToMeHash : TShowBackupToMeHash; // ���ݵ��һ�
  public
    constructor Create( _ComputerID, _ComputerName : string );
    procedure SetOnlineInfo( _IsOnline : Boolean; _LastOnlineTime : TDateTime );
    procedure SetPositionInfo( _Reachable, _Ip, _Port : string );
    procedure SetShareSpace( _TotalShareSpace, _UsedSpace : Int64 );
    procedure SetConsumeSpace( _AvailableSpace, _CloudConsumption : Int64 );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure ShowMyBackupItem;
    procedure ShowBackupToMeItem;
  end;

{$EndRegion}

{$Region ' Total Face ȫ������ ' }

    // ��� ���� �� Pc ����
  TNetworkPcAddCloudFace = class
  public
    PcID, PcName : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure Update;virtual;
  protected
    procedure AddLvCloudStatus;
    procedure AddVstMyCloudDes;
    procedure AddLvRegister;
    procedure AddCbbOwner;
    procedure AddVstFileTransferDes;
    procedure AddVstRestorePc;
  end;

    // ���
  TNetworkPcAddFace = class( TNetworkPcAddCloudFace )
  public
    procedure Update;override;
  private
    procedure AddLvNetwork;
  end;

    // ����
  TNetworkPcOnlineFace = class
  public
    PcID, PcName : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure Update;
  private
    procedure SetLvNetwork;
    procedure SetVstMyCloudDes;
    procedure SetLvCloudStatus;
    procedure SetLvMyBackupCloudStatus;
    procedure SetLvRegisterPc;
    procedure SetVstFileTransferDes;
    procedure SetCbbOwner;
    procedure AddCbbLocation;
    procedure SetToRestorePc;
  end;

    // ����
  TNetworkPcOfflineFace = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;
  private
    procedure SetLvNetwork;
    procedure SetVstMyCloudDes;
    procedure SetLvCloudStatus;
    procedure SetLvMyBackupCloudStatus;
    procedure SetLvRegisterPc;
    procedure SetVstFileTransferDes;
    procedure SetCbbOwner;
    procedure RemoveCbbLocation;
    procedure SetToRestoreFace;
  end;

    // ������ ����
  TNetworkServerOfflineFace = class
  public
    procedure Update;
  private
    procedure ClearLvNetwork;
    procedure SetVstMyCloudDes;
    procedure SetLvCloudStatus;
    procedure SetLvRegisterPc;
    procedure SetVstFileTransferDes;
    procedure SetCbbOwner;
    procedure ClearCbbLocation;
    procedure ClearShareDownPc;
    procedure ClearShareFilePc;
    procedure SetToRestoreFace;
  end;

{$EndRegion}

const
  Reachable_Reach : string = 'Reach';
  Reachable_BeReach : string = 'BeReach';
  Reachable_BothReach : string = 'Both Reach';
  Reachable_UnReach : string = 'UnReach';

  Status_Online = 'Online';
  Status_Offline = 'Offline';
  Status_Server = 'Server';
  Status_Live = 'Live';

  NetworkIcon_Offline : Integer = 0;
  NetworkIcon_Online : Integer = 1;
  NetworkIcon_Server : Integer = 1;
  NetworkIcon_Download : Integer = 3;
  NetworkIcon_Upload : Integer = 4;

  CloudStatusIcon_Offline = 0;
  CloudStatusIcon_Online  = 1;
  CloudStatusIcon_Server = 2;
  CloudStatusIcon_BackupToThis = 3;
  CloudStatusIcon_NotBackupToThis = 7;

  LvRegisterIcon_Offline = 0;
  LvRegisterIcon_Online = 1;
  LvRegisterIcon_FreeEdition = 2;
  LvRegisterIcon_ProEdition = 3;

  LvCloudStatus_SubitemCount = 8;

  LvCloudStatus_TotalSpace = 0;
  LvCloudStatus_UsedSpace = 1;
  LvCloudStatus_AvailableSpace = 2;
  LvCloudStatus_BackupSpace = 3;
  LvCloudStatus_Status = 4;
  LvCloudStatus_LastOnlineTime = 5;
  LvCloudStatus_Reachable = 6;
  LvCloudStatus_Position = 7;

  LvNetwork_Upload = 0;
  LvNetwork_Download = 1;

  LvNetworkWidth_Upload = 60;
  LvNetworkWidth_Download = 70;

  LvRestorePc_PcID = 0;
  LvRestorePc_LastOnlineTime = 1;

  PcName_MyComputer = ' (MyComputer)';
  PcStatus_Unknown = 'Unknown';

//  SbMyStatus_NotConn = 'Not Connected';
//  SbMyStatus_Conning = 'Connecting';
//  SbMyStatus_Conn = 'Connected';

  SbMyStatusIcon_NotConn = 6;
  SbMyStatusIcon_Conn = 7;

  LvRegister_PcID = 0;
  LvRetister_Edition = 1;

  LvCloudTotal_UsedSpace = 0;
  LvCloudTotal_AvailableSpace = 1;
  LvCloudTotal_MyAvailableSpace = 2;

  VstMyBackupDes_PcName = 0;
  VstMyBackupDes_TotalSpace = 1;
  VstMyBackupDes_AvailableSpace = 2;
  VstMyBackupDes_BackupToThis = 3;

  PlNetworkConn_ShowRemain = 'It will connect again after %s mins.';

//  VlCloudTotal_TotalSpace = 'Total Cloud Space';
//  VlCloudTotal_UsedSpace = 'Used Cloud Space';
//  VlCloudTotal_AvailableSpace = 'Available Cloud Space';
//  VlCloudTotal_MyAvailableSpace = 'Cloud Space Available to My Backups';
//  VlCloudTotal_MyShareAvailableSpace = 'My Shared Space (Not Used)';

  Height_HasBackup = 315;
  Height_NoBackup = 215;

  LvMyCloudPc_FileCount = 0;
  LvMyCloudPc_FileSize = 1;
  LvMyCloudPc_Percentage = 2;

//  DomainParse_NotFind = '%s(not found)';

var
  Network_LocalPcID : string;
  CloudTotal_LocalAvailable : Int64 = 0;

  MyNetworkFace : TMyChildFaceChange;
  NetworkLvItemHideThread : TNetworkLvItemHideThread;
  MyCloudPcChartRefreshThread : TMyCloudPcChartRefreshThread;

implementation

uses UMainForm, UFormUtil, UFormRestorePath, UFormSetting, UFormRegisterNew, UBackupInfoFace,
     UFormNetworkPcDetail, UBackupInfoControl, URegisterInfo, UFileTransferFace, UMyShareFace,
     URestoreFileFace, UFromEnterGroup, UFormConnPc;

{ TNetworkLvWriteInfo }

constructor TLvNetworkWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TLvNetworkWrite.FindPcItem: Boolean;
var
  i : Integer;
  SelectData : TNetworkPcItemData;
begin
  Result := False;

  for i := 0 to LvNetwork.Items.Count - 1 do
  begin
    SelectData := LvNetwork.Items[i].Data;
    if SelectData.PcID = PcID then
    begin
      PcItem := LvNetwork.Items[i];
      ItemData := PcItem.Data;
      Result := True;
      Break;
    end;
  end;
end;

{ TNetworkLvAddInfo }

procedure TLvNetworkAdd.CreatePcItem;
begin
    // ��������
  PcItem := LvNetwork.Items.Add;
  PcItem.Caption := PcID;
  PcItem.SubItems.Add('');
  PcItem.SubItems.Add('');
  PcItem.ImageIndex := NetworkIcon_Offline;

    // ��������
  ItemData := TNetworkPcItemData.Create( PcID );
  PcItem.Data := ItemData;

    // �� Pc ��
  if frmMainForm.plBackupFileNoPc.Visible then
    frmMainForm.plBackupFileNoPc.Visible := False;
end;

procedure TLvNetworkAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLvNetworkAdd.Update;
begin
  inherited;

    // ����
  if PcID = Network_LocalPcID then
    Exit;

    // ������ �򴴽�
  if not FindPcItem then
    CreatePcItem;

    // ���� Pc Name
  if PcID = Network_LocalPcID then
    PcName := PcName + PcName_MyComputer;
  PcItem.Caption := PcName;
end;


{ NetworkListviewReader }

class function NetworkListviewUtil.getLocation(Ip, Port: string): string;
begin
  if Ip = '' then
    Result := ''
  else
  if Port = '' then
    Result := Ip
  else
    Result := Ip + ' : ' + Port;
end;

class function NetworkListviewUtil.getReachable(IsReach,
  IsBeReach: Boolean): string;
begin
  if IsReach and IsBeReach then
    Result := Reachable_BothReach
  else
  if IsReach then
    Result := Reachable_Reach
  else
  if IsBeReach then
    Result := Reachable_BeReach
  else
    Result := Reachable_UnReach;

  Result := frmMainForm.siLang_frmMainForm.GetText( Result );
end;

{ TPcItemData }

constructor TNetworkPcItemData.Create(_PcID: string);
begin
  PcID := _PcID;
  UploadingCount := 0;
  DownloadingCount := 0;
end;

{ TNetworkLvShowHintInfo }

procedure TNetworkLvShowHintInfo.SetHintStr(_HintStr: string);
begin
  HintStr := _HintStr;
end;

procedure TNetworkLvShowHintInfo.Update;
var
  LvNetwork : TListView;
begin
  LvNetwork := frmMainForm.LvNetwork;
  LvNetwork.Hint := HintStr;
  LvNetwork.ShowHint := True;
end;

{ TNetworkLvClearInfo }

procedure TNetworkLvClear.Update;
var
  i : Integer;
  ItemData : TNetworkPcItemData;
begin
  inherited;

  for i := LvNetwork.Items.Count - 1 downto 0 do
  begin
    ItemData := LvNetwork.Items[i].Data;
      // �봫�����, ��ɾ��
    if ( ItemData.UploadingCount > 0 ) or
       ( ItemData.DownloadingCount > 0 ) or
         NetworkLvItemHideThread.ExistPc( ItemData.PcID ) or
       ( ItemData.PcID = Network_LocalPcID )
    then
    begin
      LvNetwork.Items[i].ImageIndex := NetworkIcon_Offline;
      Continue;
    end;
    LvNetwork.Items.Delete(i);
  end;
end;

{ TNetworkLvOnlineInfo }

procedure TLvNetworkOnline.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // ����ͼ��
  if PcItem.ImageIndex <> NetworkIcon_Server then
    PcItem.ImageIndex := NetworkIcon_Online;
end;

{ TNetworkLvOfflineInfo }

procedure TLvNetworkOffline.Update;
begin
  inherited;

    // �����ڣ� ������
  if not FindPcItem then
    Exit;

  PcItem.ImageIndex := NetworkIcon_Offline;
end;

{ TNetworkLvServerInfo }

procedure TLvNetworkServer.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

  PcItem.ImageIndex := NetworkIcon_Server;
end;

{ TCloudStatusLvWriteInfo }

constructor TVstCloudStatusWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TVstCloudStatusWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PCloudPcData;
begin
  Result := False;

  SelectNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstCloudPc.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      Result := True;
      PcNode := SelectNode;
      NodeData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstCloudStatusWrite.RefershNodeVisible;
begin
  CloudStatusVstReader.RefreshNodeVisible( PcNode );
end;

procedure TVstCloudStatusWrite.RefreshNode;
begin
  vstCloudPc.RepaintNode( PcNode );
end;

procedure TVstCloudStatusWrite.RefreshTotalSpace;
var
  AllTotalSpace, AllTotalUsed : Int64;
  AllTotalAvailable, AllTotalMyAvailable : Int64;
  ChildNode : PVirtualNode;
  ChildData : PCloudPcData;
  CloudTotalLvRefreshInfo : TCloudTotalLvRefreshInfo;
begin
  AllTotalSpace := 0;
  AllTotalUsed := 0;

  ChildNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := vstCloudPc.GetNodeData( ChildNode );
    if ChildData.IsOnline then
    begin
      AllTotalSpace := AllTotalSpace + ChildData.TotalSpace;
      AllTotalUsed := AllTotalUsed + ChildData.UsedSpace;
    end;
    ChildNode := ChildNode.NextSibling;
  end;

  AllTotalAvailable := AllTotalSpace - AllTotalUsed;
  AllTotalAvailable := Max( 0, AllTotalAvailable );

  AllTotalMyAvailable := AllTotalAvailable - CloudTotal_LocalAvailable;
  AllTotalMyAvailable := Max( 0, AllTotalMyAvailable );

    // ���½���
  CloudTotalLvRefreshInfo := TCloudTotalLvRefreshInfo.Create( AllTotalSpace, AllTotalUsed );
  CloudTotalLvRefreshInfo.SetAvailableSpace( AllTotalAvailable, AllTotalMyAvailable );
  MyNetworkFace.AddChange( CloudTotalLvRefreshInfo );
end;

{ TCloudStatusLvAddInfo }

procedure TVstCloudStatusAdd.CreatePcNode;
begin
  PcNode := vstCloudPc.AddChild( vstCloudPc.RootNode );
  NodeData := vstCloudPc.GetNodeData( PcNode );
  NodeData.IsOnline := False;
  NodeData.IsServer := False;
  NodeData.PcID := PcID;
  NodeData.HasMyBackupSize := 0;
  NodeData.HasMyBackupFile := 0;
end;

procedure TVstCloudStatusAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstCloudStatusAdd.Update;
begin
  inherited;

    // ������ �򴴽�
  if not FindPcNode then
    CreatePcNode;

  if PcID = Network_LocalPcID then
    PcName := PcName + PcName_MyComputer;
  NodeData.PcName := PcName;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TCloudStatusLvOnlineInfo }

procedure TVstCloudStatusOnline.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.IsOnline := True;

    // ���˽ڵ�
  RefershNodeVisible;

    // ���� �ŵ�һ
  if PcID = Network_LocalPcID then
    VirtualTreeUtil.MoveToTop( vstCloudPc, PcNode )
  else
    VirtualTreeUtil.MoveToSecond( vstCloudPc, PcNode );

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TCloudStatusLvOfflineInfo }

procedure TVstCloudStatusOffline.Update;
var
  DelUsed, DelTotal : Int64;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.IsOnline := False;
  NodeData.IsServer := False;

    // ���˽ڵ�
  RefershNodeVisible;

    // ���� �ŵ�һ
  if PcID <> Network_LocalPcID then
    VirtualTreeUtil.MoveToBottom( vstCloudPc, PcNode );

    // ˢ�½ڵ�
  RefreshNode;

    // ˢ���ܿռ�
  RefreshTotalSpace;
end;

{ TCloudStatusLvServerInfo }

procedure TVstCloudStatusServer.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.IsServer := True;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TCloudStatusLvSocketInfo }

procedure TVstCloudStatusSocket.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TVstCloudStatusSocket.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.Position := NetworkListviewUtil.getLocation( Ip, Port );

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TCbbSearchData }

constructor TCbbSearchData.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ LocationCbbReader }

class function LocationCbbReader.createPcItem(PcID: string): TListControlItem;
var
  cbbLocation : TComboBoxEx;
  ItemData : TCbbLocationData;
begin
  Result := getPcItem( PcID );
  if Result <> nil then
    Exit;

  cbbLocation := frmMainForm.cbbOnlinePc;
  Result := cbbLocation.ItemsEx.Add;
  ItemData := TCbbLocationData.Create( PcID );
  Result.Data := ItemData;
end;

class function LocationCbbReader.getPcItem(PcID: string): TListControlItem;
var
  cbbLocation : TComboBoxEx;
  LvNetwork : TListView;
  i : Integer;
  ItemData : TCbbSearchData;
begin
  Result := nil;

  cbbLocation := frmMainForm.cbbOnlinePc;
  for i := 0 to cbbLocation.ItemsEx.Count - 1 do
  begin
    ItemData := cbbLocation.ItemsEx.Items[i].Data;
    if ItemData.PcID = PcID then
    begin
      Result := cbbLocation.ItemsEx.Items[i];
      Break;
    end;
  end;
end;

{ TLocationCbbWriteInfo }

procedure TLocationCbbWriteInfo.Update;
begin
  PcItem := LocationCbbReader.createPcItem( PcID );
end;

{ TLocationCbbAddInfo }

procedure TLocationCbbAddInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLocationCbbAddInfo.Update;
begin
  inherited;

  PcItem.Caption := PcName;
  PcItem.ImageIndex := CloudStatusIcon_Online;
end;

{ TLocationCbbChangeInfo }

constructor TLocationCbbChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetworkPcAddFace }

procedure TNetworkPcAddFace.AddLvNetwork;
var
  NetworkLvAddInfo : TLvNetworkAdd;
begin
  NetworkLvAddInfo := TLvNetworkAdd.Create( PcID );
  NetworkLvAddInfo.SetPcName( PcName );

  MyNetworkFace.AddChange( NetworkLvAddInfo );
end;

procedure TNetworkPcAddFace.Update;
begin
  inherited;

  AddLvNetwork;
end;

{ TNetworkPcOfflineFace }

constructor TNetworkPcOfflineFace.Create(_PcID: string);
begin
  PcID :=_PcID;
end;

procedure TNetworkPcOfflineFace.RemoveCbbLocation;
var
  LocationCbbRemoveInfo : TLocationCbbRemoveInfo;
begin
  LocationCbbRemoveInfo := TLocationCbbRemoveInfo.Create( PcID );
  MyNetworkFace.AddChange( LocationCbbRemoveInfo );
end;

procedure TNetworkPcOfflineFace.SetCbbOwner;
var
  OwnerCbbOfflineInfo : TOwnerCbbOfflineInfo;
begin
  OwnerCbbOfflineInfo := TOwnerCbbOfflineInfo.Create( PcID );
  MyNetworkFace.AddChange( OwnerCbbOfflineInfo );
end;

procedure TNetworkPcOfflineFace.SetLvCloudStatus;
var
  CloudStatusLvOfflineInfo : TVstCloudStatusOffline;
begin
  CloudStatusLvOfflineInfo := TVstCloudStatusOffline.Create( PcID );
  MyNetworkFace.AddChange( CloudStatusLvOfflineInfo );
end;

procedure TNetworkPcOfflineFace.SetLvMyBackupCloudStatus;
var
  MyBackupCloudLvOfflineInfo : TMyBackupCloudLvOfflineInfo;
begin
  MyBackupCloudLvOfflineInfo := TMyBackupCloudLvOfflineInfo.Create( PcID );
  MyNetworkFace.AddChange( MyBackupCloudLvOfflineInfo );
end;

procedure TNetworkPcOfflineFace.SetLvNetwork;
var
  NetworkLvOfflineInfo : TLvNetworkOffline;
begin
  NetworkLvOfflineInfo := TLvNetworkOffline.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvOfflineInfo );
end;


procedure TNetworkPcOfflineFace.SetLvRegisterPc;
var
  RegisterLvOfflineInfo : TLvRegisterOffline;
begin
  RegisterLvOfflineInfo := TLvRegisterOffline.Create( PcID );
  MyNetworkFace.AddChange( RegisterLvOfflineInfo );
end;


procedure TNetworkPcOfflineFace.SetToRestoreFace;
var
  VstRestorePcLocationIsOnline : TVstRestorePcLocationIsOnline;
begin
  VstRestorePcLocationIsOnline := TVstRestorePcLocationIsOnline.Create( PcID );
  VstRestorePcLocationIsOnline.SetIsOnline( False );
  MyRestoreFileFace.AddChange( VstRestorePcLocationIsOnline );
end;

procedure TNetworkPcOfflineFace.SetVstFileTransferDes;
var
  VstFileTransferDesOffline : TVstFileTransferDesOffline;
  VstSelectSendPcOffline : TVstSelectSendPcOffline;
begin
  VstFileTransferDesOffline := TVstFileTransferDesOffline.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesOffline );

  VstSelectSendPcOffline := TVstSelectSendPcOffline.Create( PcID );
  MyFaceChange.AddChange( VstSelectSendPcOffline );
end;

procedure TNetworkPcOfflineFace.SetVstMyCloudDes;
var
  VstMyBackupDesOffline : TVstMyBackupDesOffline;
begin
  VstMyBackupDesOffline := TVstMyBackupDesOffline.Create( PcID );
  MyBackupFileFace.AddChange( VstMyBackupDesOffline );
end;

procedure TNetworkPcOfflineFace.Update;
begin
  SetLvNetwork;

  SetVstMyCloudDes;

  SetLvCloudStatus;

  SetLvMyBackupCloudStatus;

  SetLvRegisterPc;

  SetVstFileTransferDes;

  SetCbbOwner;

  RemoveCbbLocation;

  SetToRestoreFace;
end;

{ TNetworkPcOnlineFace }

procedure TNetworkPcOnlineFace.AddCbbLocation;
var
  LocationCbbAddInfo : TLocationCbbAddInfo;
begin
  LocationCbbAddInfo := TLocationCbbAddInfo.Create( PcID );
  LocationCbbAddInfo.SetPcName( PcName );
  MyNetworkFace.AddChange( LocationCbbAddInfo );
end;

constructor TNetworkPcOnlineFace.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TNetworkPcOnlineFace.SetCbbOwner;
var
  OwnerCbbOnlineInfo : TOwnerCbbOnlineInfo;
begin
  OwnerCbbOnlineInfo := TOwnerCbbOnlineInfo.Create( PcID );
  MyNetworkFace.AddChange( OwnerCbbOnlineInfo );
end;

procedure TNetworkPcOnlineFace.SetLvCloudStatus;
var
  CloudStatusLvOnlineInfo : TVstCloudStatusOnline;
begin
  CloudStatusLvOnlineInfo := TVstCloudStatusOnline.Create( PcID );
  MyNetworkFace.AddChange( CloudStatusLvOnlineInfo );
end;

procedure TNetworkPcOnlineFace.SetLvMyBackupCloudStatus;
var
  MyBackupCloudLvOnlineInfo : TMyBackupCloudLvOnlineInfo;
begin
  MyBackupCloudLvOnlineInfo := TMyBackupCloudLvOnlineInfo.Create( PcID );
  MyNetworkFace.AddChange( MyBackupCloudLvOnlineInfo );
end;

procedure TNetworkPcOnlineFace.SetLvNetwork;
var
  NetworkLvOnlineInfo : TLvNetworkOnline;
begin
  NetworkLvOnlineInfo := TLvNetworkOnline.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvOnlineInfo );
end;

procedure TNetworkPcOnlineFace.SetLvRegisterPc;
var
  RegisterLvOnlineInfo : TLvRegisterOnline;
begin
  RegisterLvOnlineInfo := TLvRegisterOnline.Create( PcID );
  MyNetworkFace.AddChange( RegisterLvOnlineInfo );
end;

procedure TNetworkPcOnlineFace.SetToRestorePc;
var
  VstRestorePcLocationIsOnline : TVstRestorePcLocationIsOnline;
begin
  VstRestorePcLocationIsOnline := TVstRestorePcLocationIsOnline.Create( PcID );
  VstRestorePcLocationIsOnline.SetIsOnline( True );
  MyRestoreFileFace.AddChange( VstRestorePcLocationIsOnline );
end;

procedure TNetworkPcOnlineFace.SetVstFileTransferDes;
var
  VstFileTransferDesOnline : TVstFileTransferDesOnline;
  VstSelectSendPcOnline : TVstSelectSendPcOnline;
begin
  VstFileTransferDesOnline := TVstFileTransferDesOnline.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesOnline );

  VstSelectSendPcOnline := TVstSelectSendPcOnline.Create( PcID );
  MyFaceChange.AddChange( VstSelectSendPcOnline );
end;

procedure TNetworkPcOnlineFace.SetVstMyCloudDes;
var
  VstMyBackupDesOnline : TVstMyBackupDesOnline;
begin
  VstMyBackupDesOnline := TVstMyBackupDesOnline.Create( PcID );
  MyBackupFileFace.AddChange( VstMyBackupDesOnline );
end;

procedure TNetworkPcOnlineFace.Update;
begin
  SetLvNetwork;

  SetVstMyCloudDes;

  SetLvCloudStatus;

  SetLvMyBackupCloudStatus;

  SetLvRegisterPc;

  SetVstFileTransferDes;

  SetCbbOwner;

  AddCbbLocation;

  SetToRestorePc;
end;

{ OwnerCbbReader }

class function OwnerCbbReader.createPcItem(PcID: string): TListControlItem;
var
  cbbOwner : TComboBoxEx;
  ItemData : TCbbOwnerData;
begin
  Result := getPcItem( PcID );
  if Result <> nil then
    Exit;

  cbbOwner := frmMainForm.cbbOwner;
  Result := cbbOwner.ItemsEx.Add;
  ItemData := TCbbOwnerData.Create( PcID );
  Result.Data := ItemData;
end;

class function OwnerCbbReader.getPcItem(PcID: string): TListControlItem;
var
  cbbOwner : TComboBoxEx;
  LvNetwork : TListView;
  i : Integer;
  ItemData : TCbbSearchData;
begin
  Result := nil;

  cbbOwner := frmMainForm.cbbOwner;
  for i := 0 to cbbOwner.ItemsEx.Count - 1 do
  begin
    ItemData := cbbOwner.ItemsEx.Items[i].Data;
    if ItemData.PcID = PcID then
    begin
      Result := cbbOwner.ItemsEx.Items[i];
      Break;
    end;
  end;
end;

{ TOwnerCbbChangeInfo }

constructor TOwnerCbbChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TOwnerCbbWriteInfo }

procedure TOwnerCbbWriteInfo.Update;
begin
  PcItem := OwnerCbbReader.createPcItem( PcID );
  CbbOwnerData := PcItem.Data;
end;

{ TOwnerCbbAddInfo }

procedure TOwnerCbbAddInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TOwnerCbbAddInfo.Update;
begin
  inherited;

  if PcItem.ImageIndex = -1 then
    PcItem.ImageIndex := CloudStatusIcon_Offline;
  PcItem.Caption := PcName;
end;

{ TOwnerCbbOnlineInfo }

procedure TOwnerCbbOnlineInfo.Update;
begin
  inherited;

  PcItem.ImageIndex := CloudStatusIcon_Online;

  if PcID = Network_LocalPcID then
    ComboboxUtil.MoveToTop( frmMainForm.cbbOwner, PcItem )
  else
    ComboboxUtil.MoveToSecond( frmMainForm.cbbOwner, PcItem );

  if frmMainForm.cbbOwner.ItemIndex <= 0 then
    frmMainForm.cbbOwner.ItemIndex := 0;
end;

{ TOwnerCbbOfflineInfo }

procedure TOwnerCbbOfflineInfo.Update;
begin
  inherited;

  PcItem.ImageIndex := CloudStatusIcon_Offline;

  if PcID <> Network_LocalPcID then
    ComboboxUtil.MoveToBottom( frmMainForm.cbbOwner, PcItem );

  if frmMainForm.cbbOwner.ItemIndex <= 0 then
    frmMainForm.cbbOwner.ItemIndex := 0;
end;

{ LocationCbbRemoveInfo }

procedure TLocationCbbRemoveInfo.Update;
var
  PcItem : TListControlItem;
  cbbLocation : TComboBoxEx;
  Data : TObject;
begin
  PcItem := LocationCbbReader.getPcItem( PcID );
  if PcItem = nil then
    Exit;

  Data := PcItem.Data;
  Data.Free;
  cbbLocation := frmMainForm.cbbOnlinePc;
  cbbLocation.ItemsEx.Delete( PcItem.Index );
end;

{ TNetworkLvAddUpload }

procedure TLvNetworkAddUpload.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // ��� �ϴ���Ŀ
  ItemData.UploadingCount := ItemData.UploadingCount + 1;
  if ItemData.UploadingCount < 1 then
    Exit;

  PcItem.SubItems[ LvNetwork_Upload ] := IntToStr( ItemData.UploadingCount );
  if PcItem.SubItemImages[ LvNetwork_Upload ] <> NetworkIcon_Upload then
    PcItem.SubItemImages[ LvNetwork_Upload ] := NetworkIcon_Upload;

    // ��ʾ����
  if lvNetwork.Columns[ LvNetwork_Upload + 1 ].Width = 0 then
  begin
    lvNetwork.Columns[0].Width := lvNetwork.Columns[0].Width - LvNetworkWidth_Upload;
    lvNetwork.Columns[ LvNetwork_Upload + 1 ].Width := LvNetworkWidth_Upload;
  end;
end;

{ TNetworkLvAddDownload }

procedure TLvNetworkAddDownload.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // ��� ������Ŀ
  ItemData.DownloadingCount := ItemData.DownloadingCount + 1;
  if ItemData.DownloadingCount < 1 then
    Exit;

    // ��ʾ ������Ϣ
  PcItem.SubItems[ LvNetwork_Download ] := IntToStr( ItemData.DownloadingCount );
  if PcItem.SubItemImages[ LvNetwork_Download ] <> NetworkIcon_Download then
    PcItem.SubItemImages[ LvNetwork_Download ] := NetworkIcon_Download;

    // ��ʾ ������
  if lvNetwork.Columns[ LvNetwork_Download + 1 ].Width = 0 then
  begin
    lvNetwork.Columns[0].Width := lvNetwork.Columns[0].Width - LvNetworkWidth_Download;
    lvNetwork.Columns[ LvNetwork_Download + 1 ].Width := LvNetworkWidth_Download;
  end;
end;

{ TNetworkLvRemoveUpload }

procedure TLvNetworkRemoveUpload.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // �����ϴ���Ŀ
  ItemData.UploadingCount := ItemData.UploadingCount - 1;
  if ItemData.UploadingCount <= 0 then
  begin
    PcItem.SubItems[ LvNetwork_Upload ] := '0';
      // ���������
    NetworkLvItemHideThread.AddUpHideInfo( PcID );
  end
  else
    PcItem.SubItems[ LvNetwork_Upload ] := IntToStr( ItemData.UploadingCount );
end;

{ TNetworkLvRemoveDownload }

procedure TLvNetworkRemoveDownload.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // ����������Ŀ
  ItemData.DownloadingCount := ItemData.DownloadingCount - 1;
  if ItemData.DownloadingCount <= 0 then
  begin
    PcItem.SubItems[ LvNetwork_Download ] := '0';
    
          // ���������
    NetworkLvItemHideThread.AddDownHideInfo( PcID );
  end
  else
    PcItem.SubItems[ LvNetwork_Download ] := IntToStr( ItemData.DownloadingCount );
end;

{ TCloudStatusLvAllOfflineInfo }

procedure TVstCloudStatusServerOffline.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PCloudPcData;
  PcID : string;
  CloudStatusLvOfflineInfo : TVstCloudStatusOffline;
begin
  inherited;

  ChildNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := vstCloudPc.GetNodeData( ChildNode );
    PcID := ChildData.PcID;
    CloudStatusLvOfflineInfo := TVstCloudStatusOffline.Create( PcID );
    MyNetworkFace.InsertChange( CloudStatusLvOfflineInfo );
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TCloudStatusLvReachInfo }

procedure TVstCloudStatusReach.SetReachable(_Reachable: string);
begin
  Reachable := _Reachable;
end;

procedure TVstCloudStatusReach.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.Reachable := Reachable;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TCloudStatusLvHeartBeatInfo }

procedure TVstCloudStatusSpace.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TVstCloudStatusSpace.SetSpace(_UsedSpace, _TotalSpace: Int64);
begin
  UsedSpace := _UsedSpace;
  TotalSpace := _TotalSpace;
end;

procedure TVstCloudStatusSpace.Update;
var
  AvailableSpace, DelUsed, DelTotal : Int64;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  AvailableSpace := TotalSpace - UsedSpace;
  AvailableSpace := Max( 0, AvailableSpace );

    // ���� Available
  if PcID = Network_LocalPcID then
    CloudTotal_LocalAvailable := AvailableSpace;

  NodeData.UsedSpace := UsedSpace;
  NodeData.TotalSpace := TotalSpace;
  NodeData.BackupSpace := BackupSpace;

    // ˢ�½ڵ�
  RefreshNode;

    // ˢ���ܿռ�
  RefreshTotalSpace;
end;

{ TCloudStatusLvLastOnlineInfo }

procedure TVstCloudStatusLastOnline.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TVstCloudStatusLastOnline.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.BackupSpace := BackupSpace;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TNetworkPcAddCloudFace }

procedure TNetworkPcAddCloudFace.AddCbbOwner;
var
  OwnerCbbAddInfo : TOwnerCbbAddInfo;
begin
  OwnerCbbAddInfo := TOwnerCbbAddInfo.Create( PcID );
  OwnerCbbAddInfo.SetPcName( PcName );

  MyNetworkFace.AddChange( OwnerCbbAddInfo );
end;


procedure TNetworkPcAddCloudFace.AddLvCloudStatus;
var
  CloudStatusLvAddInfo : TVstCloudStatusAdd;
begin
  CloudStatusLvAddInfo := TVstCloudStatusAdd.Create( PcID );
  CloudStatusLvAddInfo.SetPcName( PcName );

  MyNetworkFace.AddChange( CloudStatusLvAddInfo );
end;

procedure TNetworkPcAddCloudFace.AddLvRegister;
var
  RegisterLvAddInfo : TLvRegisterAdd;
begin
  RegisterLvAddInfo := TLvRegisterAdd.Create( PcID );
  RegisterLvAddInfo.SetPcName( PcName );
  MyNetworkFace.AddChange( RegisterLvAddInfo );
end;

procedure TNetworkPcAddCloudFace.AddVstFileTransferDes;
var
  VstFileTransferDesAdd : TVstFileTransferDesAdd;
  VstSelectSendPcAdd : TVstSelectSendPcAdd;
begin
  VstFileTransferDesAdd := TVstFileTransferDesAdd.Create( PcID );
  VstFileTransferDesAdd.SetPcName( PcName );
  MyFaceChange.AddChange( VstFileTransferDesAdd );

  VstSelectSendPcAdd := TVstSelectSendPcAdd.Create( PcID );
  VstSelectSendPcAdd.SetPcName( PcName );
  MyFaceChange.AddChange( VstSelectSendPcAdd );
end;

procedure TNetworkPcAddCloudFace.AddVstMyCloudDes;
var
  VstMyBackupDesAdd : TVstMyBackupDesAdd;
begin
  VstMyBackupDesAdd := TVstMyBackupDesAdd.Create( PcID );
  VstMyBackupDesAdd.SetPcName( PcName );
  MyNetworkFace.AddChange( VstMyBackupDesAdd );
end;

procedure TNetworkPcAddCloudFace.AddVstRestorePc;
var
  VstRestorePcAdd : TVstRestorePcAdd;
begin
  VstRestorePcAdd := TVstRestorePcAdd.Create( PcID );
  VstRestorePcAdd.SetRestorePcName( PcName );
  MyRestoreFileFace.AddChange( VstRestorePcAdd );
end;

constructor TNetworkPcAddCloudFace.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TNetworkPcAddCloudFace.Update;
begin
  AddVstMyCloudDes;

  AddLvCloudStatus;

  AddLvRegister;

  AddCbbOwner;

  AddVstFileTransferDes;

  AddVstRestorePc;
end;

{ TCloudStatusLvOnlineTimeInfo }

procedure TVstCloudStatusOnlineTime.SetLastOnlineTime(
  _LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

procedure TVstCloudStatusOnlineTime.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.LastOnline := LastOnlineTime;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TNetworkServerOfflineFace }

procedure TNetworkServerOfflineFace.ClearCbbLocation;
var
  LocationCbbClearInfo : TLocationCbbClearInfo;
begin
  LocationCbbClearInfo := TLocationCbbClearInfo.Create;
  MyNetworkFace.AddChange( LocationCbbClearInfo );
end;

procedure TNetworkServerOfflineFace.SetCbbOwner;
var
  OwnerCbbServerOfflineInfo : TOwnerCbbServerOfflineInfo;
begin
  OwnerCbbServerOfflineInfo := TOwnerCbbServerOfflineInfo.Create;
  MyNetworkFace.AddChange( OwnerCbbServerOfflineInfo );
end;

procedure TNetworkServerOfflineFace.SetLvCloudStatus;
var
  CloudStatusLvServerOfflineInfo : TVstCloudStatusServerOffline;
begin
  CloudStatusLvServerOfflineInfo := TVstCloudStatusServerOffline.Create;
  MyNetworkFace.AddChange( CloudStatusLvServerOfflineInfo );
end;

procedure TNetworkServerOfflineFace.ClearLvNetwork;
var
  NetworkLvClearInfo : TNetworkLvClear;
begin
  NetworkLvClearInfo := TNetworkLvClear.Create;
  MyNetworkFace.AddChange( NetworkLvClearInfo );
end;

procedure TNetworkServerOfflineFace.ClearShareDownPc;
var
  LvDownSharePcClear : TLvDownSharePcClear;
begin
  LvDownSharePcClear := TLvDownSharePcClear.Create;
  MyFaceChange.AddChange( LvDownSharePcClear );
end;

procedure TNetworkServerOfflineFace.ClearShareFilePc;
var
  VstShareFileClear : TVstShareFileClear;
begin
  VstShareFileClear := TVstShareFileClear.Create;
  MyFaceChange.AddChange( VstShareFileClear );
end;

procedure TNetworkServerOfflineFace.SetLvRegisterPc;
var
  RegisterLvServerOfflineInfo : TLvRegisterServerOffline;
begin
  RegisterLvServerOfflineInfo := TLvRegisterServerOffline.Create;
  MyNetworkFace.AddChange( RegisterLvServerOfflineInfo );
end;

procedure TNetworkServerOfflineFace.SetToRestoreFace;
var
  VstRestorePcLocationServerOffline : TVstRestorePcLocationServerOffline;
begin
  VstRestorePcLocationServerOffline := TVstRestorePcLocationServerOffline.Create;
  MyRestoreFileFace.AddChange( VstRestorePcLocationServerOffline );
end;

procedure TNetworkServerOfflineFace.SetVstFileTransferDes;
var
  VstFileTransferDesServerOffline : TVstFileTransferDesServerOffline;
  VstSelectSendPcServerOffline : TVstSelectSendPcServerOffline;
begin
  VstFileTransferDesServerOffline := TVstFileTransferDesServerOffline.Create;
  MyFaceChange.AddChange( VstFileTransferDesServerOffline );

  VstSelectSendPcServerOffline := TVstSelectSendPcServerOffline.Create;
  MyFaceChange.AddChange( VstSelectSendPcServerOffline );
end;

procedure TNetworkServerOfflineFace.SetVstMyCloudDes;
var
  VstMyBackupDesServerOffline : TVstMyBackupDesServerOffline;
begin
  VstMyBackupDesServerOffline := TVstMyBackupDesServerOffline.Create;
  MyBackupFileFace.AddChange( VstMyBackupDesServerOffline );
end;

procedure TNetworkServerOfflineFace.Update;
begin
  ClearLvNetwork;

  SetVstMyCloudDes;

  SetLvCloudStatus;

  SetLvRegisterPc;

  SetVstFileTransferDes;

  SetCbbOwner;

  ClearCbbLocation;

  ClearShareDownPc;

  ClearShareFilePc;

  SetToRestoreFace;
end;


{ TLocationCbbServerOfflineInfo }

procedure TOwnerCbbServerOfflineInfo.Update;
var
  cbbOwner : TComboBoxEx;
  ItemData : TCbbSearchData;
  i : Integer;
begin
  cbbOwner := frmMainForm.cbbOwner;

  for i := 0 to cbbOwner.ItemsEx.Count - 1 do
  begin
    ItemData := cbbOwner.ItemsEx.Items[i].Data;
    if ItemData.PcID = '' then
      Continue;
    cbbOwner.ItemsEx.Items[i].ImageIndex := CloudStatusIcon_Offline;
  end;
end;

{ TLocationCbbClearInfo }

procedure TLocationCbbClearInfo.Update;
var
  CbbLocation : TComboBoxEx;
  ItemData : TCbbSearchData;
  i : Integer;
begin
  CbbLocation := frmMainForm.cbbOnlinePc;
  for i := CbbLocation.ItemsEx.Count - 1 downto 0 do
  begin
    ItemData := CbbLocation.ItemsEx.Items[i].Data;
    if ItemData.PcID = '' then
      Continue;
    ItemData.Free;
    CbbLocation.ItemsEx.Delete( i );
  end;
end;


{ TSbMyStatusNotConnInfo }

procedure TSbMyStatusNotConnInfo.Update;
begin
  inherited;

  SbMyStatus.Caption := frmMainForm.siLang_frmMainForm.GetText( 'NetNotConn' );
  SbMyStatus.ImageIndex := SbMyStatusIcon_NotConn;
  SbMyStatus.Tag := 0;
end;

{ TSbMyStatusConningInfo }

procedure TSbMyStatusConningInfo.Update;
var
  t : Integer;
  ShowStr : string;
  i, DotLen, ShowIcon : Integer;
begin
  inherited;

  SbMyStatus.Tag := SbMyStatus.Tag + 1;
  t := SbMyStatus.Tag;

  if ( t mod 2 ) = 0 then
    ShowIcon := SbMyStatusIcon_NotConn
  else
    ShowIcon := SbMyStatusIcon_Conn;

  ShowStr := frmMainForm.siLang_frmMainForm.GetText( 'NetConnecting' );
  DotLen := t mod 4;
  for i := 0 to DotLen - 1 do
    ShowStr := ShowStr + '.';

  SbMyStatus.Caption := ShowStr;
  SbMyStatus.ImageIndex := ShowIcon;
end;

{ TSbMyStatusConnInfo }

procedure TSbMyStatusConnInfo.Update;
begin
  inherited;

  SbMyStatus.Caption := frmMainForm.siLang_frmMainForm.GetText( 'NetConnected' );
  SbMyStatus.ImageIndex := SbMyStatusIcon_Conn;
  SbMyStatus.Tag := 0;
end;

{ TSbMyStatusChangeInfo }

procedure TSbMyStatusChangeInfo.Update;
begin
  SbMyStatus := frmMainForm.sbMyStatus;
end;

{ TInternetSocketChangeInfo }

constructor TInternetSocketChangeInfo.Create(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TInternetSocketChangeInfo.Update;
begin
  frmSetting.edtInternetIp.Text := InternetIp;
  frmSetting.edtInternetPort.Text := InternetPort;
end;

{ TPmNetworkOpenChangeInfo }

procedure TPmNetworkOpenChangeInfo.Update;
begin
  FormUtil.EnableToolbar( frmMainForm.tbNetwork, True );
  FormUtil.EnableToolbar( frmMainForm.tbFileSendDesNetwork, True );
  FormUtil.EnableToolbar( frmMainForm.tbFileShareNetwork, True );
  FormUtil.EnableToolbar( frmMainForm.tbRestoreNetwork, True );
end;

{ TPmNetworkCloseChangeInfo }

procedure TPmNetworkCloseChangeInfo.Update;
begin
  FormUtil.EnableToolbar( frmMainForm.tbNetwork, False );
  FormUtil.EnableToolbar( frmMainForm.tbFileSendDesNetwork, False );
  FormUtil.EnableToolbar( frmMainForm.tbFileShareNetwork, False );
  FormUtil.EnableToolbar( frmMainForm.tbRestoreNetwork, False );
end;

{ TStandardPasswordError }

procedure TStandardPasswordError.Update;
begin
  frmJoinGroup.ShowResetPassword( AccountName );
end;

{ TStandardAccountError }

procedure TStandardAccountError.SetPassword(_Password: string);
begin
  Password := _Password;
end;

procedure TStandardAccountError.Update;
begin
  frmJoinGroup.ShowGroupNotExist( AccountName, Password );
end;

{ TStandardError }

constructor TStandardError.Create(_AccountName: string);
begin
  AccountName := _AccountName;
end;

{ TAdvanceDnsComplete }

constructor TAdvanceDnsComplete.Create(_Domain, _DnsResult: string);
begin
  Domain := _Domain;
  DnsResult := _DnsResult;
end;

procedure TAdvanceDnsComplete.SetIsParseError(_IsParseError: Boolean);
begin
  IsParseError := _IsParseError;
end;

procedure TAdvanceDnsComplete.Update;
var
  LvAdvance : TListView;
  i : Integer;
  LvAdvanceData : TLvAdvanceData;
begin
  LvAdvance := frmSetting.lvAdvance;
  for i := 0 to LvAdvance.Items.Count - 1 do
  begin
    LvAdvanceData := LvAdvance.Items[i].Data;
    if LvAdvanceData.Domain = Domain then
    begin
      LvAdvance.Items[i].Caption := DnsResult;
      if IsParseError then
        LvAdvance.Items[i].SubItems[ LvAdvance_Domain ] := Format( frmSetting.siLang_frmSetting.GetText( 'ParseError' ), [Domain] );
      Break;
    end;
  end;
end;

{ TAdvanceDnsError }

constructor TAdvanceDnsError.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

procedure TAdvanceDnsError.Update;
begin
  frmConnComputer.ShowDnsError( Domain, Port );
end;

{ TRegisterPcItemData }

constructor TRegisterPcItemData.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRegisterPcItemData.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

{ TRegisterLvWriteInfo }

constructor TLvRegisterWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TLvRegisterWrite.FindPcItem: Boolean;
var
  i : Integer;
  SelectData : TRegisterPcItemData;
begin
  Result := False;

  for i := 0 to LvRegisterPc.Items.Count - 1 do
  begin
    SelectData := LvRegisterPc.Items[i].Data;
    if SelectData.PcID = PcID then
    begin
      Result := True;
      PcItem := LvRegisterPc.Items[i];
      ItemData := SelectData;
      Break;
    end;
  end;
end;

{ TRegisterLvAddInfo }

procedure TLvRegisterAdd.AddPcItem;
begin
  PcItem := LvRegisterPc.Items.Add;
  ListviewUtil.AddSubitem( PcItem, 2 );
  ItemData := TRegisterPcItemData.Create( PcID );
  PcItem.Data := ItemData;
end;

procedure TLvRegisterAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLvRegisterAdd.Update;
begin
  inherited;

    // ������, �򴴽�
  if not FindPcItem then
    AddPcItem;

  if PcID = Network_LocalPcID then
    PcName := PcName + PcName_MyComputer;

  PcItem.Caption := PcName;
  PcItem.SubItems[ LvRegister_PcID ] := PcID;

  ItemData.SetPcName( PcName );
end;

{ TRegisterLvOnlineInfo }

procedure TLvRegisterOnline.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

  PcItem.ImageIndex := LvRegisterIcon_Online;

  if PcID = Network_LocalPcID then
    ListviewUtil.MoveToTop( PcItem )
  else
    ListviewUtil.MoveToSecond( PcItem );
end;

{ TRegisterLvOfflineInfo }

procedure TLvRegisterOffline.Update;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

  PcItem.ImageIndex := LvRegisterIcon_Offline;

  if PcID <> Network_LocalPcID then
    ListviewUtil.MoveToBottom( PcItem );
end;

{ TRegisterLvServerOfflineInfo }

procedure TLvRegisterServerOffline.Update;
var
  i : Integer;
  PcItem : TListItem;
  ItemData : TRegisterPcItemData;
  PcID : string;
  RegisterLvOfflineInfo : TLvRegisterOffline;
begin
  inherited;

  for i := 0 to LvRegisterPc.Items.Count - 1 do
  begin
    PcItem := LvRegisterPc.Items[i];
    if PcItem.ImageIndex <> LvRegisterIcon_Offline then
    begin
      ItemData := PcItem.Data;
      PcID := ItemData.PcID;

      RegisterLvOfflineInfo := TLvRegisterOffline.Create( PcID );
      MyNetworkFace.InsertChange( RegisterLvOfflineInfo );
    end;
  end;
end;

{ TRegisterEditionInfo }

procedure TLvRegisterEdition.SetRegisterEdition(_RegisterEdition,
  _RegisterHardCode: string);
begin
  RegisterEdition := _RegisterEdition;
  RegisterHardCode := _RegisterHardCode;
end;

procedure TLvRegisterEdition.Update;
var
  RegisterIcon : Integer;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // �汾����
  if ( RegisterEdition = RegisterEdition_Evaluate ) or
     ( RegisterEdition = '' )
  then
    RegisterEdition := RegisterEditon_Free;

    // �汾ͼ��
  if RegisterEdition = RegisterEditon_Free then
    RegisterIcon := LvRegisterIcon_FreeEdition
  else
    RegisterIcon := LvRegisterIcon_ProEdition;

  PcItem.SubItems[ LvRetister_Edition ] := RegisterEdition;
  PcItem.SubItemImages[ LvRetister_Edition ] := RegisterIcon;
  ItemData.RegisterEdition := RegisterEdition;
  ItemData.RegisterHardCode := RegisterHardCode;
end;

{ TRefreshRegisterInfo }

procedure TLvRegisterRefresh.Update;
begin
  frmMainForm.RefreshRegisterEdition;
end;

{ TCloudTotalLvRefreshInfo }

constructor TCloudTotalLvRefreshInfo.Create(_TotalSpace, _UsedSpace: Int64);
begin
  TotalSpace := _TotalSpace;
  UsedSpace := _UsedSpace;
end;

procedure TCloudTotalLvRefreshInfo.SetAvailableSpace(_AvailableSpace,
  _MyAvailableSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
  MyAvailableSpace := _MyAvailableSpace;
end;

procedure TCloudTotalLvRefreshInfo.ShowChart;
var
  psCloudStatus : TPieSeries;
  Percentage : Integer;
  ShowStr : string;
  MyShareAvailableSpace : Int64;
begin
    // ��ͼ
  psCloudStatus := frmMainForm.peCloudStatus;
  psCloudStatus.Clear;

    // ����
  ShowStr :=  frmMainForm.siLang_frmMainForm.GetText( 'StrTotalSpace' ) + ': ';
  ShowStr := ShowStr + MySize.getFileSizeStr( TotalSpace );
  frmMainForm.ctCloudStatus.Title.Text.Clear;
  frmMainForm.ctCloudStatus.Title.Text.Add( ShowStr );

    // ���ÿռ�
  Percentage := MyPercentage.getPercent( UsedSpace, TotalSpace );
  ShowStr := MySize.getFileSizeStr( UsedSpace ) + ' ' + frmMainForm.siLang_frmMainForm.GetText( 'StrUseSpace' );
  psCloudStatus.AddPie( Percentage, ShowStr, clBlue );

    // �ҹ���Ŀ��ÿռ�
  MyShareAvailableSpace := AvailableSpace - MyAvailableSpace;
  Percentage := MyPercentage.getPercent( MyShareAvailableSpace, TotalSpace );
  ShowStr := MySize.getFileSizeStr( MyShareAvailableSpace ) + ' ' + frmMainForm.siLang_frmMainForm.GetText( 'SpaceMyShare' );
  psCloudStatus.AddPie( Percentage, ShowStr, clYellow );

    // ���ÿռ�
  Percentage := MyPercentage.getPercent( MyAvailableSpace, TotalSpace );;
  ShowStr := MySize.getFileSizeStr( MyAvailableSpace ) + ' ' + frmMainForm.siLang_frmMainForm.GetText( 'StrSpaceAvailable' );
  psCloudStatus.AddPie( Percentage, ShowStr, clFuchsia );
end;

procedure TCloudTotalLvRefreshInfo.ShowDetailList;
var
  vlCloudTotal : TValueListEditor;
  KeyShow, ValueShow : string;
begin
    // ��ϸ��Ϣ
  vlCloudTotal := frmMainForm.vlCloudTotal;
  vlCloudTotal.Strings.Clear;

    // �ܿռ�
  KeyShow := frmMainForm.siLang_frmMainForm.GetText( 'StrTotalSpace' );
  ValueShow := MySize.getFileSizeStr( TotalSpace );
  vlCloudTotal.Strings.Add( KeyShow + '=' + ValueShow );

    // ���ÿռ�
  KeyShow := frmMainForm.siLang_frmMainForm.GetText( 'StrUseSpace' );
  ValueShow := MySize.getFileSizeStr( UsedSpace );
  vlCloudTotal.Strings.Add( KeyShow + '=' + ValueShow );

    // ���ÿռ�
  KeyShow := frmMainForm.siLang_frmMainForm.GetText( 'StrAvailableSpace' );
  ValueShow := MySize.getFileSizeStr( AvailableSpace );
  vlCloudTotal.Strings.Add( KeyShow + '=' + ValueShow );

      // ���ÿռ�
  KeyShow := frmMainForm.siLang_frmMainForm.GetText( 'StrSpaceAvailable' );
  ValueShow := MySize.getFileSizeStr( MyAvailableSpace );
  vlCloudTotal.Strings.Add( KeyShow + '=' + ValueShow );
end;

procedure TCloudTotalLvRefreshInfo.Update;
begin
    // ��ʾ �б�
  ShowDetailList;

    // ��ʾ ��ͼ
  ShowChart;
end;

{ CloudStatusVstReader }

class procedure CloudStatusVstReader.RefreshNodeVisible(Node: PVirtualNode);
var
  vstCloudPc : TVirtualStringTree;
  NodeData : PCloudPcData;
  IsNodeVisible : Boolean;
begin
  vstCloudPc := frmMainForm.vstCloudPc;
  NodeData := vstCloudPc.GetNodeData( Node );
  if VstCloudPc_ShowType = VstCloudPcShowType_Online then
    IsNodeVisible := NodeData.IsOnline
  else
  if VstCloudPc_ShowType = VstCloudPcShowType_MyBackup then
    IsNodeVisible := NodeData.HasMyBackupFile > 0
  else
  if VstCloudPc_ShowType = VstCloudPcShowType_OnlineAndMyBackup then
    IsNodeVisible := NodeData.IsOnline or ( NodeData.HasMyBackupFile > 0 )
  else
  if VstCloudPc_ShowType = VstCloudPcShowType_All then
    IsNodeVisible := True;

  vstCloudPc.IsVisible[ Node ] := IsNodeVisible;
end;

class function CloudStatusVstReader.getPcItemData(PcID: string): PVirtualNode;
var
  vstCloudPc : TVirtualStringTree;
  ChildNode : PVirtualNode;
  ChildData : PCloudPcData;
begin
  Result := nil;

  vstCloudPc := frmMainForm.vstCloudPc;
  ChildNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := vstCloudPc.GetNodeData( ChildNode );
    if ChildData.PcID = PcID then
    begin
      Result := ChildNode;
      Break;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TCbbOwnerData }

procedure TCbbOwnerData.SetIsFileInvisible(_IsFileInvisible: Boolean);
begin
  IsFileInvisible := _IsFileInvisible;
end;

procedure TCbbOwnerData.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

{ TOwnerCbbFileInvisibleInfo }

procedure TOwnerCbbFileInvisibleInfo.SetIsFileInvisible(
  _IsFileInvisible: Boolean);
begin
  IsFileInvisible := _IsFileInvisible;
end;

procedure TOwnerCbbFileInvisibleInfo.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TOwnerCbbFileInvisibleInfo.Update;
begin
  inherited;

  if Network_LocalPcID = PcID then
    IsFileInvisible := False;

  CbbOwnerData.SetIsFileInvisible( IsFileInvisible );
  CbbOwnerData.SetIvPasswordMD5( IvPasswordMD5 );
end;

{ TOwnerCbbInputIvPasswordMD5Info }

procedure TOwnerCbbInputIvPasswordMD5Info.SetInputIvPasswordMD5(
  _InputIvPasswordMD5: string);
begin
  InputIvPasswordMD5 := _InputIvPasswordMD5;
end;

procedure TOwnerCbbInputIvPasswordMD5Info.Update;
begin
  inherited;

  CbbOwnerData.InputIvPasswordMD5 := InputIvPasswordMD5;
end;


{ TPlNetworkConnShowInfo }

procedure TPlNetworkConnShowInfo.Update;
begin
  inherited;

  plNetworkConn.Visible := True;
  plFileSendDesConn.Visible := True;
end;

{ TPlNetworkConnHideInfo }

procedure TPlNetworkConnHideInfo.Update;
begin
  inherited;

  plNetworkConn.Visible := False;
  plFileSendDesConn.Visible := False;
end;

{ TPlNetworkConnRemainInfo }

constructor TPlNetworkConnRemainInfo.Create(_ShowTime: Integer);
begin
  ShowTime := _ShowTime;
end;

procedure TPlNetworkConnRemainInfo.Update;
var
  ShowConnAfter : string;
  ShowTimeStr : string;
begin
  inherited;

  ShowConnAfter := frmMainForm.siLang_frmMainForm.GetText( 'StrConnAfterMins' );

  ShowTimeStr := MyTime.getMyMinTimeStr( ShowTime );
  frmMainForm.lbNetworkConn.Caption := Format( ShowConnAfter, [ ShowTimeStr ] );
  frmMainForm.lbFileSendDesConn.Caption := Format( ShowConnAfter, [ ShowTimeStr ] );
end;

{ TPlNetworkConnChangeInfo }

procedure TPlNetworkConnChangeInfo.Update;
begin
  plNetworkConn := frmMainForm.plNetworkConn;
  plFileSendDesConn := frmMainForm.plFileSendDesConn;
end;

{ TShowNetworkPcDetail }

constructor TShowNetworkPcDetail.Create(_ComputerID, _ComputerName: string);
begin
  ComputerID := _ComputerID;
  ComputerName := _ComputerName;

  ShowMyBackupItemHash := TShowMyBackupItemHash.Create;
  ShowBackupToMeHash := TShowBackupToMeHash.Create;
end;

destructor TShowNetworkPcDetail.Destroy;
begin
  ShowBackupToMeHash.Free;
  ShowMyBackupItemHash.Free;
  inherited;
end;

procedure TShowNetworkPcDetail.SetConsumeSpace(_AvailableSpace,
  _CloudConsumption: Int64);
begin
  AvailableSpace := _AvailableSpace;
  CloudConsumption := _CloudConsumption;
end;

procedure TShowNetworkPcDetail.SetOnlineInfo(_IsOnline: Boolean;
  _LastOnlineTime: TDateTime);
begin
  IsOnline := _IsOnline;
  LastOnlineTime := _LastOnlineTime;
end;

procedure TShowNetworkPcDetail.SetPositionInfo(_Reachable, _Ip, _Port: string);
begin
  Reachable := _Reachable;
  Ip := _Ip;
  Port := _Port;
end;

procedure TShowNetworkPcDetail.SetShareSpace(_TotalShareSpace,
  _UsedSpace: Int64);
begin
  TotalShareSpace := _TotalShareSpace;
  UsedSpace := _UsedSpace;
end;

procedure TShowNetworkPcDetail.ShowBackupToMeItem;
var
  LvBackupToMeItem : TListView;
  p : TShowBackupToMePair;
  Percentage : Integer;
begin
//  LvBackupToMeItem := frmNetworkPcDetail.lvBackupToMe;
//
//  LvBackupToMeItem.Clear;
//  for p in ShowBackupToMeHash do
//  begin
//    with LvBackupToMeItem.Items.Add do
//    begin
//      Caption := p.Value.FullPath;
//      SubItems.Add( MySize.getFileSizeStr( p.Value.TotalSize ) );
//      SubItems.Add( MySize.getFileSizeStr( p.Value.BackupSize ) );
//      Percentage := MyPercentage.getPercent( p.Value.BackupSize, p.Value.TotalSize );
//      SubItems.Add( MyPercentage.getPercentageStr( Percentage ) );
//      ImageIndex := PathTypeIconUtil.getIcon( p.Value.FullPath, p.Value.PathType );
//    end;
//  end;
end;

procedure TShowNetworkPcDetail.ShowMyBackupItem;
var
  LvMyBackupItem : TListView;
  p : TShowMyBackupItemPair;
  Percentage : Integer;
begin
  LvMyBackupItem := frmNetworkPcDetail.lvMyBackup;
  LvMyBackupItem.Clear;

    // û�б��� ���ر�����Ϣ
  if ShowMyBackupItemHash.Count > 0 then
  begin
    LvMyBackupItem.Visible := True;
    frmNetworkPcDetail.Height := Height_HasBackup;
  end
  else
  begin
    frmNetworkPcDetail.Height := Height_NoBackup;
    LvMyBackupItem.Visible := False;
    Exit;
  end;

  for p in ShowMyBackupItemHash do
  begin
    with LvMyBackupItem.Items.Add do
    begin
      Caption := p.Value.FullPath;
      SubItems.Add( MySize.getFileSizeStr( p.Value.TotalSize ) );
      SubItems.Add( MySize.getFileSizeStr( p.Value.BackupSize ) );
      Percentage := MyPercentage.getPercent( p.Value.BackupSize, p.Value.TotalSize );
      SubItems.Add( MyPercentage.getPercentageStr( Percentage ) );
      ImageIndex := PathTypeIconUtil.getIcon( p.Value.FullPath, p.Value.PathType );
    end;
  end;
end;

procedure TShowNetworkPcDetail.Update;
var
  LastOnlineShowStr : string;
  PcBigIcon : TIcon;
  IconIndex : Integer;
begin
    // ��Ϣ ��֧
  if IsOnline then
  begin
    LastOnlineShowStr := Status_Live;
    IconIndex := NetworkIcon_Online;
  end
  else
  begin
    LastOnlineShowStr := DateTimeToStr( LastOnlineTime );
    IconIndex := NetworkIcon_Offline;
  end;

    // ���� û���� Pc ���ӹ�
  if Ip = '' then
    Ip := Sign_NA;
  if Port = '' then
    Port := Sign_NA;

    // ���� ������Ϣ
  with frmNetworkPcDetail do
  begin
      // ����
//    Caption := ComputerName + ' Properties';
    edtComputerName.Text := ComputerName;


      // ͼ��
    PcBigIcon := TIcon.Create;
    frmMainForm.ilNw.GetIcon( IconIndex, PcBigIcon );
    iPcStatus.Picture.Icon := PcBigIcon;
    PcBigIcon.Free;

      // Pc ������Ϣ
    lbComputerID.Caption := ComputerID;
    lbLastOnlineTime.Caption := LastOnlineShowStr;
    lbReachable.Caption := Reachable;
    lbIp.Caption := Ip;
    lbPort.Caption := Port;

      // Pc �ƿռ���Ϣ
    lbTotalShace.Caption := MySize.getFileSizeStr( TotalShareSpace );
    lbAvailableSpace.Caption := MySize.getFileSizeStr( AvailableSpace );
    lbUsedSpace.Caption := MySize.getFileSizeStr( UsedSpace );
    lbCloudConsumpition.Caption := MySize.getFileSizeStr( CloudConsumption );
  end;

    // ����������Ϣ
  ShowMyBackupItem;

    // ���ݵ���������Ϣ
  ShowBackupToMeItem;

    // ��ʾ ����
  frmNetworkPcDetail.Show;
end;

{ TShowMyBackupItemInfo }

constructor TShowMyBackupItemInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TShowMyBackupItemInfo.SetSpaceInfo(_TotalSize, _BackupSize: Int64);
begin
  TotalSize := _TotalSize;
  BackupSize := _BackupSize;
end;

{ TShowBackupToMeInfo }

constructor TShowBackupToMeInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TShowBackupToMeInfo.SetSpaceInfo(_TotalSize, _BackupSize: Int64);
begin
  TotalSize := _TotalSize;
  BackupSize := _BackupSize;
end;

{ TCloudStatusLvRefreshOnlyShowInfo }

procedure TVstCloudStatusRefreshOnlyShow.Update;
var
  ChildNode : PVirtualNode;
begin
  inherited;

  ChildNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    CloudStatusVstReader.RefreshNodeVisible( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
  vstCloudPc.Refresh;
end;

{ TCloudStatusLvHasMyBackupFileClearInfo }

procedure TVstCloudStatusMyBackupClear.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PCloudPcData;
begin
  inherited;

  ChildNode := vstCloudPc.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := vstCloudPc.GetNodeData( ChildNode );
    ChildData.HasMyBackupSize := 0;
    ChildData.HasMyBackupFile := 0;
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TNetworkLvHideInfo }

constructor TNetworkLvHideInfo.Create(_PcID: string);
begin
  StartTime := Now;
  PcID := _PcID;
end;

{ TNetworkLvColumHideThread }

procedure TNetworkLvItemHideThread.AddDownHideInfo(PcID: string);
var
  NetworkLvHideInfo : TNetworkLvHideInfo;
begin
  Lock.Enter;
  if NetworkLvDownHideHash.ContainsKey( PcID ) then
    NetworkLvDownHideHash[ PcID ].StartTime := Now
  else
  begin
    NetworkLvHideInfo := TNetworkLvHideInfo.Create( PcID );
    NetworkLvDownHideHash.AddOrSetValue( PcID, NetworkLvHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TNetworkLvItemHideThread.CheckLvHideDown;
var
  RemoveList : TStringList;
  p : TNetworkLvHidePair;
  NetworkLvItemHideDownload : TNetworkLvItemHideDownload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in NetworkLvDownHideHash do
  begin
      // û�е����ص�ʱ��, ����
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // ��� ����
    RemoveList.Add( p.Value.PcID );
  end;
    // ���� ����
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    NetworkLvDownHideHash.Remove( PcID );
          // ���� ����
    NetworkLvItemHideDownload := TNetworkLvItemHideDownload.Create( PcID );
    MyNetworkFace.AddChange( NetworkLvItemHideDownload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;

procedure TNetworkLvItemHideThread.CheckLvHideUp;
var
  RemoveList : TStringList;
  p : TNetworkLvHidePair;
  NetworkLvItemHideUpload : TNetworkLvItemHideUpload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in NetworkLvUpHideHash do
  begin
      // û�е����ص�ʱ��, ����
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // ��� ����
    RemoveList.Add( p.Value.PcID );
  end;
    // ���� ����
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    NetworkLvUpHideHash.Remove( PcID );
          // ���� ����
    NetworkLvItemHideUpload := TNetworkLvItemHideUpload.Create( PcID );
    MyNetworkFace.AddChange( NetworkLvItemHideUpload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;

constructor TNetworkLvItemHideThread.Create;
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;
  NetworkLvDownHideHash := TNetworkLvHideHash.Create;
  NetworkLvUpHideHash := TNetworkLvHideHash.Create;
end;

destructor TNetworkLvItemHideThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  NetworkLvUpHideHash.Free;
  NetworkLvDownHideHash.Free;
  Lock.Free;
  inherited;
end;

procedure TNetworkLvItemHideThread.Execute;
begin
  while not Terminated do
  begin
    if not ExistHidePc then
    begin
      Suspend;
      Continue;
    end;

    if Terminated then
      Break;

    CheckLvHideDown;
    CheckLvHideUp;

    Sleep(100);
  end;

  inherited;
end;

function TNetworkLvItemHideThread.ExistHidePc: Boolean;
begin
  Lock.Enter;
  Result := ( NetworkLvDownHideHash.Count > 0 ) or
            ( NetworkLvUpHideHash.Count > 0 );
  Lock.Leave;
end;

function TNetworkLvItemHideThread.ExistPc(PcID: string): Boolean;
begin
  Lock.Enter;
  Result := NetworkLvDownHideHash.ContainsKey( PcID ) or
            NetworkLvUpHideHash.ContainsKey( PcID );
  Lock.Leave;
end;

procedure TNetworkLvItemHideThread.AddUpHideInfo(PcID: string);
var
  NetworkLvHideInfo : TNetworkLvHideInfo;
begin
  Lock.Enter;
  if NetworkLvUpHideHash.ContainsKey( PcID ) then
    NetworkLvUpHideHash[ PcID ].StartTime := Now
  else
  begin
    NetworkLvHideInfo := TNetworkLvHideInfo.Create( PcID );
    NetworkLvUpHideHash.AddOrSetValue( PcID, NetworkLvHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

{ TNetworkLvItemHideDownload }

procedure TNetworkLvItemHideDownload.CheckHideDownloadColumn;
var
  i : Integer;
  RemoveWidth : Integer;
begin
  for i := 0 to lvNetwork.Items.Count - 1 do
    if lvNetwork.Items[i].SubItems[ LvNetwork_Download ] <> '' then // ��������
      Exit;

    // ����
  RemoveWidth := lvNetwork.Columns[ LvNetwork_Download + 1 ].Width;
  lvNetwork.Columns[ LvNetwork_Download + 1 ].Width := 0;
  lvNetwork.Columns[0].Width := lvNetwork.Columns[0].Width + RemoveWidth;
end;

procedure TNetworkLvItemHideDownload.Update;
begin
  inherited;

  if FindPcItem then
  begin
      // ���� ����
    if ItemData.DownloadingCount <> 0 then
      Exit;

      // ���� Pc ������
    PcItem.SubItems[ LvNetwork_Download ] := '';
    PcItem.SubItemImages[ LvNetwork_Download ] := -1;
  end;

    // ����Ƿ� ���� ������
  CheckHideDownloadColumn;
end;

{ TNetworkLvItemHideUpload }

procedure TNetworkLvItemHideUpload.CheckHideUploadColumn;
var
  i : Integer;
  RemoveWidth : Integer;
begin
  for i := 0 to lvNetwork.Items.Count - 1 do
    if lvNetwork.Items[i].SubItems[ LvNetwork_Upload ] <> '' then
      Exit;

    // ����
  RemoveWidth := lvNetwork.Columns[ LvNetwork_Upload + 1 ].Width;
  lvNetwork.Columns[ LvNetwork_Upload + 1 ].Width := 0;
  lvNetwork.Columns[0].Width := lvNetwork.Columns[0].Width + RemoveWidth;
end;

procedure TNetworkLvItemHideUpload.Update;
begin
  inherited;

    // Pc ����
  if FindPcItem then
  begin
      // ��������
    if ItemData.UploadingCount <> 0 then
      Exit;

      // ���� �ϴ���Ϣ
    PcItem.SubItems[ LvNetwork_Upload ] := '';
    PcItem.SubItemImages[ LvNetwork_Upload ] := -1;
  end;

    // ��� �Ƿ���Ҫ���� �ϴ���
  CheckHideUploadColumn;
end;

{ TMyBackupCloudLvChangeInfo }

constructor TMyBackupCloudLvChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TMyBackupCloudLvChangeInfo.Update;
begin
  LvMyCloudPc := frmMainForm.lvMyCloudPc;
end;

{ TMyBackupCloudLvWriteSpace }

procedure TMyBackupCloudLvWriteSpace.RefreshSpaceShow;
var
  Percentage : Integer;
begin
  Percentage := MyPercentage.getPercent( ItemData.FileSpace, BackupProgress_Total );
  ItemData.Percentage := Percentage;

    // ˢ�� List
  PcItem.SubItems[ LvMyCloudPc_FileCount ] := IntToStr( ItemData.FileCount );
  PcItem.SubItems[ LvMyCloudPc_FileSize ] := MySize.getFileSizeStr( ItemData.FileSpace );
  PcItem.SubItems[ LvMyCloudPc_Percentage ] := MyPercentage.getPercentageStr( Percentage );

    // ˢ�� ��ͼ
  MyCloudPcChartRefreshThread.SetRefreshChart;
end;

procedure TMyBackupCloudLvWriteSpace.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TMyBackupCloudLvWriteSpace.SetFileSpace(_FileSpace: Int64);
begin
  FileSpace := _FileSpace;
end;

procedure TMyBackupCloudLvWriteSpace.Update;
begin
  inherited;
  PcItem := MyBackupCloudLvReader.CreatePcItem( PcID );
  ItemData := PcItem.Data;
end;

{ TMyBackupCloudLvOnlineInfo }

procedure TMyBackupCloudLvOnlineInfo.Update;
var
  PcItem : TListItem;
  ItemData : TMyBackupCloudLvData;
begin
  inherited;

    // û�� ��������
  PcItem := MyBackupCloudLvReader.getPcItem( PcID );
  if PcItem = nil then
    Exit;
  PcItem.ImageIndex := CloudStatusIcon_Online;

  ItemData := PcItem.Data;
  ItemData.IsOnline := True;

  MyCloudPcChartRefreshThread.SetRefreshChart;
end;

{ MyBackupCloudLvReader }

class function MyBackupCloudLvReader.CreatePcItem(PcID: string): TListItem;
var
  LvMyCloudPc : TListView;
  ItemData : TMyBackupCloudLvData;
  PcName : string;
  PcIsOnline : Boolean;
begin
  Result := getPcItem( PcID );
  if Result <> nil then
    Exit;

  LvMyCloudPc := frmMainForm.lvMyCloudPc;
  Result := LvMyCloudPc.Items.Add;
  ListviewUtil.AddSubitem( Result, 3 );
  ItemData := TMyBackupCloudLvData.Create( PcID );
  Result.Data := ItemData;

  PcName := ReadPcName( PcID );
  Result.Caption := PcName;
  ItemData.PcName := PcName;

  PcIsOnline := ReadPcIsOnline( PcID );
  ItemData.IsOnline := PcIsOnline;
  if PcIsOnline then
    Result.ImageIndex := CloudStatusIcon_Online
  else
    Result.ImageIndex := CloudStatusIcon_Offline;
end;

class function MyBackupCloudLvReader.getPcItem(PcID: string): TListItem;
var
  lvMyCloudPc : TListView;
  i : Integer;
  ItemData : TMyBackupCloudLvData;
begin
  Result := nil;

  lvMyCloudPc := frmMainForm.lvMyCloudPc;
  for i := 0 to lvMyCloudPc.Items.Count - 1 do
  begin
    ItemData := lvMyCloudPc.Items[i].Data;
    if ItemData.PcID = PcID then
    begin
      Result := lvMyCloudPc.Items[i];
      Break;
    end;
  end;
end;

class function MyBackupCloudLvReader.ReadPcIsOnline(PcID: string): Boolean;
var
  vstCloudPcNode : PVirtualNode;
  ItemData : PCloudPcData;
begin
  Result := False;

  vstCloudPcNode := CloudStatusVstReader.getPcItemData( PcID );
  if Assigned( vstCloudPcNode ) then
  begin
    ItemData := frmMainForm.vstCloudPc.GetNodeData( vstCloudPcNode );
    Result := ItemData.IsOnline;
  end;
end;

class function MyBackupCloudLvReader.ReadPcName(PcID: string): string;
var
  vstCloudPcNode : PVirtualNode;
  ItemData : PCloudPcData;
begin
  Result := '';

  vstCloudPcNode := CloudStatusVstReader.getPcItemData( PcID );
  if Assigned( vstCloudPcNode ) then
  begin
    ItemData := frmMainForm.vstCloudPc.GetNodeData( vstCloudPcNode );
    Result := ItemData.PcName;
  end;
end;

{ TMyBackupCloudLvData }

constructor TMyBackupCloudLvData.Create(_PcID: string);
begin
  PcID := _PcID;
  FileCount := 0;
  FileSpace := 0;
  Percentage := 0;
end;

{ TMyBackupCloudLvAddInfo }

procedure TMyBackupCloudLvAddSpace.Update;
begin
  inherited;

    // �޸Ŀռ���Ϣ
  ItemData.FileCount := ItemData.FileCount + FileCount;
  ItemData.FileSpace := ItemData.FileSpace + FileSpace;

    // ˢ����ʾ
  RefreshSpaceShow;
end;

{ TMyBackupCloudLvRemoveInfo }

procedure TMyBackupCloudLvRemoveSpace.Update;
begin
  inherited;

    // �޸Ŀռ���Ϣ
  ItemData.FileCount := ItemData.FileCount - FileCount;
  ItemData.FileSpace := ItemData.FileSpace - FileSpace;

    // ˢ����ʾ
  RefreshSpaceShow;
end;

{ TMyBackupCloudLvClearInfo }

procedure TMyBackupCloudLvClearInfo.Update;
begin
  frmMainForm.lvMyCloudPc.Clear;
end;

{ TMyCloudPcChartRefreshThread }

constructor TMyCloudPcChartRefreshThread.Create;
begin
  inherited Create( True );
  IsRefresh := False;
end;

destructor TMyCloudPcChartRefreshThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TMyCloudPcChartRefreshThread.Execute;
var
  LastTime : TDateTime;
begin
  while not Terminated do
  begin
    if not IsRefresh then
    begin
      Suspend;
      Continue;
    end;

      // ˢ�±�ͼ
    IsRefresh := False;
    RefreshChart;

    LastTime := Now;
    while ( not Terminated ) and ( SecondsBetween( Now, LastTime ) < 2 ) do
      Sleep(100);
  end;
  inherited;
end;

procedure TMyCloudPcChartRefreshThread.RefreshChart;
var
  MyBackupCloudChartRefreshInfo : TMyBackupCloudChartRefreshInfo;
begin
  MyBackupCloudChartRefreshInfo := TMyBackupCloudChartRefreshInfo.Create;
  MyNetworkFace.AddChange( MyBackupCloudChartRefreshInfo );
end;

procedure TMyCloudPcChartRefreshThread.SetRefreshChart;
begin
  IsRefresh := True;
  Resume;
end;

{ TMyBackupCloudChartRefreshInfo }

procedure TMyBackupCloudChartRefreshInfo.Update;
var
  MyBackupCloudPcChartList : TMyBackupCloudPcChartList;
  MyBackupCloudPcChartInfo : TMyBackupCloudPcChartInfo;
  LvMyCloudPc : TListView;
  i : Integer;
  ItemData : TMyBackupCloudLvData;
  peMyCloudPc : TBarSeries;
  Percentage : Integer;
  PcName : string;
begin
  MyBackupCloudPcChartList := TMyBackupCloudPcChartList.Create;

    // Ѱ������
  LvMyCloudPc := frmMainForm.lvMyCloudPc;
  for i := 0 to LvMyCloudPc.Items.Count - 1 do
  begin
    ItemData := LvMyCloudPc.Items[i].Data;
    MyBackupCloudPcChartInfo := TMyBackupCloudPcChartInfo.Create( ItemData.PcName, ItemData.Percentage );
    MyBackupCloudPcChartInfo.SetIsOnline( ItemData.IsOnline );
    MyBackupCloudPcChartList.Add( MyBackupCloudPcChartInfo );
  end;

    // ����
  MyBackupCloudPcChartList.SortByPercentage;

    // ��ʾ
  peMyCloudPc := frmMainForm.seMyCloudPc;
  peMyCloudPc.Clear;
  for i := 0 to MyBackupCloudPcChartList.Count - 1 do
  begin
    MyBackupCloudPcChartInfo := MyBackupCloudPcChartList[i];
    Percentage := MyBackupCloudPcChartInfo.Percentage;
    PcName := MyBackupCloudPcChartInfo.PcName;
    if MyBackupCloudPcChartInfo.IsOnline then
      peMyCloudPc.Add( Percentage, PcName, clBlue )
    else
      peMyCloudPc.Add( Percentage, PcName );
  end;

  MyBackupCloudPcChartList.Free;
end;

{ TMyBackupCloudLvOfflineInfo }

procedure TMyBackupCloudLvOfflineInfo.Update;
var
  PcItem : TListItem;
  ItemData : TMyBackupCloudLvData;
begin
  inherited;

    // û�� ��������
  PcItem := MyBackupCloudLvReader.getPcItem( PcID );
  if PcItem = nil then
    Exit;
  PcItem.ImageIndex := CloudStatusIcon_Offline;

  ItemData := PcItem.Data;
  ItemData.IsOnline := False;

  MyCloudPcChartRefreshThread.SetRefreshChart;
end;

{ TMyBackupCloudPcChartInfo }

constructor TMyBackupCloudPcChartInfo.Create(_PcName: string;
  _Percentage: Integer);
begin
  PcName := _PcName;
  Percentage := _Percentage;
end;

procedure TMyBackupCloudPcChartInfo.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

{ TMyBackupCloudPcChartList }

procedure TMyBackupCloudPcChartList.SortByPercentage;
var
  i, j : Integer;
  Temp : TMyBackupCloudPcChartInfo;
begin
  Self.OwnsObjects := False;

    // ð������, Ȩ��С���ź�, Ȩ�ش����ǰ.
  for i := 0 to Self.Count - 2 do
    for j := 0 to Self.Count - 2 - i do
    begin
      if Self[ j + 1 ].Percentage > Self[ j ].Percentage then
      begin
        Temp := Self[ j + 1 ];
        Self[ j + 1 ] := Self[ j ];
        Self[ j ] := Temp;
      end;
    end;

  Self.OwnsObjects := True;
end;

{ TLvNetworkChangeInfo }

procedure TLvNetworkChange.Update;
begin
  LvNetwork := frmMainForm.LvNetwork;
end;

{ TCloudStatusLvSetHasMyBackupFile }

procedure TVstCloudStatusHasMyBackupSet.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.HasMyBackupSize := FileSize;
  NodeData.HasMyBackupFile := FileCount;

    // ˢ�� �ڵ� �ɼ���
  RefershNodeVisible;
end;

{ TVstCloudStatusAddHasMyBackupSpace }

procedure TVstCloudStatusHasMyBackupAdd.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.HasMyBackupSize := NodeData.HasMyBackupSize + FileSize;
  NodeData.HasMyBackupFile := NodeData.HasMyBackupFile + FileCount;

    // ˢ�� �ڵ� �ɼ���
  RefershNodeVisible;
end;

{ TVstCloudStatusHasMyBackupChange }

procedure TVstCloudStatusHasMyBackupChange.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TVstCloudStatusHasMyBackupRemove }

procedure TVstCloudStatusHasMyBackupRemove.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.HasMyBackupSize := NodeData.HasMyBackupSize - FileSize;
  NodeData.HasMyBackupFile := NodeData.HasMyBackupFile - FileCount;

    // ˢ�� �ڵ� �ɼ���
  RefershNodeVisible;
end;

{ TVstMyBackupDesChange }

procedure TVstMyBackupDesChange.Update;
begin
  VstBackupDes := frmMainForm.VstMyBackupDes;
end;

{ TVstMyBackupDesWrite }

constructor TVstMyBackupDesWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TVstMyBackupDesWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyBackupDesData;
begin
  Result := False;

  SelectNode := VstBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackupDes.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      PcNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstMyBackupDesWrite.RefreshNode;
begin
  VstBackupDes.RepaintNode( PcNode );
end;

{ TVstMyBackupDesAdd }

procedure TVstMyBackupDesAdd.AddPcNode;
begin
  PcNode := VstBackupDes.AddChild( VstBackupDes.RootNode );
  NodeData := VstBackupDes.GetNodeData( PcNode );
  NodeData.PcID := PcID;
  NodeData.IsOnline := False;
  NodeData.IsBackup := True;
end;

procedure TVstMyBackupDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstMyBackupDesAdd.Update;
begin
  inherited;

    // ����
  if PcID = Network_LocalPcID then
    Exit;

    // ������ �򴴽�
  if not FindPcNode then
    AddPcNode;

  NodeData.PcName := PcName;
end;

{ TVstMyBackupDesOnline }

procedure TVstMyBackupDesOnline.Update;
begin
  inherited;

    // ������ �򴴽�
  if not FindPcNode then
    Exit;

  NodeData.IsOnline := True;

    // �Ƶ�����
  VirtualTreeUtil.MoveToTop( VstBackupDes, PcNode );

    // ˢ�� �ڵ�
  RefreshNode;
end;

{ TVstMyBackupDesOffline }

procedure TVstMyBackupDesOffline.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.IsOnline := False;

    // �Ƶ�����
  VirtualTreeUtil.MoveToBottom( VstBackupDes, PcNode );

    // ˢ�� �ڵ�
  RefreshNode;
end;

{ TVstMyBackupDesServerOffline }

procedure TVstMyBackupDesServerOffline.PcOffline(PcID: string);
var
  VstMyBackupDesOffline : TVstMyBackupDesOffline;
begin
  VstMyBackupDesOffline := TVstMyBackupDesOffline.Create( PcID );
  VstMyBackupDesOffline.Update;
  VstMyBackupDesOffline.Free;
end;

procedure TVstMyBackupDesServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyBackupDesData;
begin
  inherited;

  SelectNode := VstBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackupDes.GetNodeData( SelectNode );
    PcOffline( SelectData.PcID );
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstMyBackupDesSetAvailableSpace }

procedure TVstMyBackupDesSetAvailableSpace.SetSpaceInfo(
  _TotalSpace, _AvaliableSpace: Int64);
begin
  TotalSpace := _TotalSpace;
  AvaliableSpace := _AvaliableSpace;
end;

procedure TVstMyBackupDesSetAvailableSpace.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.TotalSpace := TotalSpace;
  NodeData.AvalableSpace := AvaliableSpace;

    // ˢ�� �ڵ�
  RefreshNode;
end;

{ TVstMyBackupDesSetIsBackup }

procedure TVstMyBackupDesSetIsBackup.SetIsBackup(_IsBackup: Boolean);
begin
  IsBackup := _IsBackup;
end;

procedure TVstMyBackupDesSetIsBackup.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

  NodeData.IsBackup := IsBackup;

    // ˢ�� �ڵ�
  RefreshNode;
end;

{ TPmNetworkReturnLocalNetwork }

procedure TPmNetworkReturnLocalNetwork.Update;
begin
  frmMainForm.tbtnNwLan.Click;
end;

{ TVstCloudStatusChange }

procedure TVstCloudStatusChange.Update;
begin
  vstCloudPc := frmMainForm.vstCloudPc;
end;

{ TLvRegisterChange }

procedure TLvRegisterChange.Update;
begin
  LvRegisterPc := frmRegisterNew.lvComputer;
end;

end.
