unit UFormSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,IniFiles,FileCtrl,
  Winsock,ShellAPI, ShlObj, UMyUtil, Spin, ToolWin, ImgList,
  RzButton, RzRadChk, Mask, RzEdit, RzSpnEdt, Menus, SyncObjs,
  RzTabs, pngimage, siComp;

type

{$Region ' Form Setting ' }

    // Dns 线程
  TAdvanceDnsThread = class( TThread )
  private
    Lock : TCriticalSection;
    DomainList : TStringList;
  public
    constructor Create;
    procedure AddDns( Domain : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextDomain : string;
  end;

  TfrmSetting = class(TForm)
    Panel2: TPanel;
    btnApply: TButton;
    btnCancel: TButton;
    btnOK: TButton;
    ilTbRn: TImageList;
    ilLvRemove: TImageList;
    ilTbRnGray: TImageList;
    PcMain: TRzPageControl;
    tsBackup: TRzTabSheet;
    tsCloud: TRzTabSheet;
    tsPrivacy: TRzTabSheet;
    tsLocalNetwork: TRzTabSheet;
    tsRemoveNetwork: TRzTabSheet;
    tsTransfer: TRzTabSheet;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    img6: TImage;
    seCopyCount: TSpinEdit;
    pl4: TPanel;
    gbCycle: TGroupBox;
    img7: TImage;
    seSyncTime: TSpinEdit;
    pl5: TPanel;
    gbEncrypt: TGroupBox;
    lbEncPassword: TLabel;
    lbEncPassword2: TLabel;
    lbEncPasswordHint: TLabel;
    lbReqEncPassword: TLabel;
    lbReqEncPassword2: TLabel;
    img3: TImage;
    chkIsEncrypt: TCheckBox;
    edtEncPassword2: TEdit;
    edtEncPasswordHint: TEdit;
    btnResetPassword: TButton;
    edtEncPassword: TEdit;
    plCloudShareSettings: TPanel;
    gbCloud: TGroupBox;
    lbSharePath: TLabel;
    lb3: TLabel;
    lbMinSpace: TLabel;
    lbMaxSpace: TLabel;
    img2: TImage;
    edtSharePath: TEdit;
    btnSharePath: TButton;
    chkIsShare: TCheckBox;
    plCloudSafeSetting: TPanel;
    GroupBox6: TGroupBox;
    Panel10: TPanel;
    GroupBox7: TGroupBox;
    lbIvPassword: TLabel;
    lbIvPassword2: TLabel;
    Image3: TImage;
    lbReqIvPassword: TLabel;
    lbReqIvPassword2: TLabel;
    lbIvFileSearch: TLabel;
    lbIvRestore: TLabel;
    edtIvPassword: TEdit;
    edtivPassword2: TEdit;
    chkIsFileInvisible: TCheckBox;
    pl7: TPanel;
    gb3: TGroupBox;
    lbPcName: TLabel;
    lb5: TLabel;
    img9: TImage;
    edtPcName: TEdit;
    edtPcID: TEdit;
    Panel3: TPanel;
    GroupBox2: TGroupBox;
    lb1: TLabel;
    lb2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    img8: TImage;
    img1: TImage;
    cbbIP: TComboBox;
    edtPort: TEdit;
    edtInternetIp: TEdit;
    edtInternetPort: TEdit;
    plStandardNetwork: TPanel;
    GroupBox3: TGroupBox;
    Panel4: TPanel;
    plStandardBottom: TPanel;
    lvStandard: TListView;
    tbLvStandard: TToolBar;
    tbtnStandardAdd: TToolButton;
    tbtnStandardRemove: TToolButton;
    tbtnStandardChangePassword: TToolButton;
    tbtnStandardSelected: TToolButton;
    plStardardTop: TPanel;
    nbStandard: TNotebook;
    plStandardDiscription: TPanel;
    Label10: TLabel;
    LinkLabel1: TLinkLabel;
    plSstandardAdd: TPanel;
    Label6: TLabel;
    Label9: TLabel;
    edtAccountName: TEdit;
    btnStanardOK: TButton;
    btnStandardCancel: TButton;
    edtAccountPassword: TEdit;
    plAdvanceNetwork: TPanel;
    GroupBox4: TGroupBox;
    Panel8: TPanel;
    plAdvanceTop: TPanel;
    plAdvanceBottom: TPanel;
    tbLvAdvance: TToolBar;
    tbtnAdvanceAdd: TToolButton;
    tbtnAdvanceRemove: TToolButton;
    tbtnAdvanceSelected: TToolButton;
    lvAdvance: TListView;
    nbAdvance: TNotebook;
    plAdvanceDiscription: TPanel;
    Label13: TLabel;
    plAdvanceAdd: TPanel;
    Label11: TLabel;
    Label12: TLabel;
    edtDomain: TEdit;
    btnAdvanceAdd: TButton;
    btnAdvanceCancel: TButton;
    edtAdvancePort: TEdit;
    plFileTransferManger: TPanel;
    Panel7: TPanel;
    Panel9: TPanel;
    gb2: TGroupBox;
    lb8: TLabel;
    lb13: TLabel;
    lb14: TLabel;
    lb15: TLabel;
    lb16: TLabel;
    lb18: TLabel;
    img5: TImage;
    trbUpSpeed: TTrackBar;
    seUploadThread: TSpinEdit;
    gb1: TGroupBox;
    lb7: TLabel;
    lb9: TLabel;
    lb10: TLabel;
    lb11: TLabel;
    lb12: TLabel;
    lb17: TLabel;
    img4: TImage;
    trbDownSpeed: TTrackBar;
    seDownloadThread: TSpinEdit;
    GroupBox5: TGroupBox;
    Image1: TImage;
    Label14: TLabel;
    chkShowRemote: TRzCheckBox;
    chkMD5: TRzCheckBox;
    tsApplication: TRzTabSheet;
    chkRunAppStartup: TRzCheckBox;
    tsFileTransfer: TRzTabSheet;
    Panel11: TPanel;
    GroupBox8: TGroupBox;
    lbRecevicePath: TLabel;
    edtRecevicePath: TEdit;
    btnRecevicePathBrowse: TButton;
    Image4: TImage;
    tsFileSearch: TRzTabSheet;
    Panel12: TPanel;
    GroupBox9: TGroupBox;
    Label8: TLabel;
    Image5: TImage;
    edtDownloadPath: TEdit;
    btnDownloadPathBrowse: TButton;
    chkIsSelectDownloadPath: TCheckBox;
    Image6: TImage;
    Image7: TImage;
    chkShowAppExistDialog: TCheckBox;
    chkRevFileShowHint: TRzCheckBox;
    ChkSyncTime: TCheckBox;
    cbbSyncTime: TComboBox;
    Panel5: TPanel;
    gbCloudSafe: TGroupBox;
    lbCloudIDNum: TLabel;
    Image8: TImage;
    lbReqCloudIDNum: TLabel;
    lbCloudSafe: TLabel;
    chkIsCloudID: TCheckBox;
    edtCloudIDNum: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    seCloudLostValue: TSpinEdit;
    cbbCloudLostTye: TComboBox;
    Image2: TImage;
    seMaxSpaceValue: TSpinEdit;
    cbbMaxSpaceType: TComboBox;
    seMinSpaceValue: TSpinEdit;
    cbbMinSpaceType: TComboBox;
    rbAutoReceive: TRadioButton;
    rbManualReceive: TRadioButton;
    rbNerverReceive: TRadioButton;
    Label15: TLabel;
    cbbLanguage: TComboBox;
    siLang_frmSetting: TsiLang;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SettingChange(Sender: TObject);
    procedure chkIsEncryptClick(Sender: TObject);
    procedure chkIsShareClick(Sender: TObject);
    procedure chkIsCloudIDClick(Sender: TObject);
    procedure chkIsFileInvisibleClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure tbtnStandardAddClick(Sender: TObject);
    procedure tbtnAdvanceAddClick(Sender: TObject);
    procedure btnStandardCancelClick(Sender: TObject);
    procedure btnStanardOKClick(Sender: TObject);
    procedure lvStandardDeletion(Sender: TObject; Item: TListItem);
    procedure lvAdvanceDeletion(Sender: TObject; Item: TListItem);
    procedure lvStandardSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbtnStandardChangePasswordClick(Sender: TObject);
    procedure tbtnStandardRemoveClick(Sender: TObject);
    procedure btnAdvanceAddClick(Sender: TObject);
    procedure tbtnAdvanceRemoveClick(Sender: TObject);
    procedure btnAdvanceCancelClick(Sender: TObject);
    procedure lvAdvanceSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbtnStandardSelectedClick(Sender: TObject);
    procedure tbtnAdvanceSelectedClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvStandardDblClick(Sender: TObject);
    procedure lvAdvanceDblClick(Sender: TObject);
    procedure btnResetPasswordClick(Sender: TObject);
    procedure btnSharePathClick(Sender: TObject);
    procedure chkRunAppStartupClick(Sender: TObject);
    procedure btnDownloadPathBrowseClick(Sender: TObject);
    procedure chkIsSelectDownloadPathClick(Sender: TObject);
    procedure btnRecevicePathBrowseClick(Sender: TObject);
    procedure ChkSyncTimeClick(Sender: TObject);
    procedure lvStandardKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvAdvanceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure rbNerverReceiveClick(Sender: TObject);
    procedure siLang_frmSettingChangeLanguage(Sender: TObject);
  public
    procedure SaveIni;
    procedure LoadIni;
  public
    procedure SetFirstApplySettings;
    procedure SetApplySettings;
    procedure SetCancelSettings;
    procedure LoadNetworkMode;
  private
    procedure BindSettingChange( Wcontrol: TWinControl );
    procedure BindToolbar;
    procedure BindSort;
    procedure ShowApplyButton;
    procedure AfterApplyClick;
    function BtnAppClick : Boolean;
  public          // 主界面 网络模式 改变
    procedure pmLanNetworkClick(Sender: TObject);
    procedure pmStandardNetworkClick(Sender: TObject);
    procedure pmAdvanceNetworkClick(Sender: TObject);
  public          // 错误时窗口提示
    procedure StandardChangePassword( AccountName : string );
  private
    AdvanceDnsThread : TAdvanceDnsThread;
  public
    IsEnableRemoteNetwork : Boolean;
  end;


{$EndRegion}

{$Region ' Remote Network Listview 添加 ' }

    // 修改 父类
  TLvStandardChangeHandle = class
  public
    AccountName : string;
    AccountPassword : string;
  public
    constructor Create( _AccountName, _AccountPassword : string );
  end;

    // 添加 network group
    // 已存在 返回 False
  TLvStandardAddHandle = class( TLvStandardChangeHandle )
  public
    function Update: Boolean;
  end;

    // network group 修改密码
  TLvStandardPasswordHandle = class( TLvStandardChangeHandle )
  public
    procedure Update;
  end;

    // 添加 Advance  Listview
    // 已存在 返回 False
  TLvAdvanceAddHandle = class
  private
    Domain, Port : string;
  public
    constructor Create( _Domain, _Port : string );
    function Update: Boolean;
  end;


{$EndRegion}

{$Region ' Remote Network Lv Data ' }

  TLvStandardData = class
  public
    AccountName : string;
    Password : string;
    IsSelected : Boolean;
  public
    constructor Create( _AccountName, _Password : string );
  end;

  TLvAdvanceData = class
  public
    Domain : string;
    Port : string;
    IsSelected : Boolean;
  public
    constructor Create( _Domain, _Port : string );
  end;

{$EndRegion}


    // 辅助类
  LvRemoteNetworkUtil = class
  public
    class function getLvAdvanceData( Domain, Port : string ): TLvAdvanceData;
    class procedure setLvAdvanceSelected( Domain, Port : string );
    class function getLvAdvanceSelectedData : TLvAdvanceData;
  public
    class function getLvStandardData( AccountName : string ):TLvStandardData;
    class procedure setLvStandardSelected( AccountName : string );
    class function getLvStandardSelectedData : TLvStandardData;
  public       // 改变网络模式
    class procedure SetLanSelected;
    class procedure SetStandardSelected( AccountName : string );
    class procedure SetAdvanceSelected( Domain, Port : string );
  public       // Pm Advance 显示
    class function getAdvanceShowStr( Domain, Port : string ): string;
    class function getAdvancePcInfo( ShowStr : string; var Domain, Port : string ): Boolean;
  end;

    // Network Mode 改变辅助
  NetworkModeChangeUtil = class
  public
    class procedure EnterLan;
    class procedure EnterStandard( AccountName, Password : string );
    class procedure EnterAdvance( Domain, Port : string );
  public
    class procedure SaveEnterLan;
    class procedure SaveEnterStandard( AccountName : string );
    class procedure SaveEnterAdvance( Domain, Port : string );
  end;


{$Region ' Remote Network Apply/Cancel ' }

  TCheckApplyLocalNetwork = class
  public
    function get : Boolean;
  end;

    // Standard Network Apply
  TApplyStandardNetwork = class
  private
    SplitIndex : Integer;
    IsChangeSelectPassword : Boolean;
    IsChangeNetwork : Boolean;
  public
    procedure Update;
    function getIsChangeNetwork : Boolean;
  private
    procedure RemoveOldItem;
    procedure FindSplitIndex;
    procedure AddNewItem;
    procedure SelectedItem;
  private
    procedure AddPmItem( AccountName : string );
    procedure RemovePmItem( AccountName : string );
  end;

    // Standard Network Cancel
  TCancelStandardNetwork = class
  public
    procedure Update;
  private
    procedure RemoveNewItem;
    procedure AddOldItem;
    procedure SelectedItem;
  end;

    // Advance Network Apply
  TApplyAdvanceNetwork = class
  private
    SplitIndex, SplitModeIndex : Integer;
    IsChangeNetwork : Boolean;
  public
    procedure Update;
    function getIsChangeNetwork : Boolean;
  private
    procedure FindSplitIndex;
    procedure RemoveOldItem;
    procedure AddNewItem;
    procedure SelectedItem;
  private
    procedure RemovePmItem( Domain, Port : string );
    procedure AddPmItem( Domain, Port : string );
  end;

    // Advance Network Cancel
  TCancelAdvanceNetwork = class
  public
    procedure Update;
  private
    procedure RemoveNewItem;
    procedure AddOldItem;
    procedure SelectedItem;
  end;

{$EndRegion}

{$Region ' Network Mode Select ' }

  TPmNetworkChange = class
  public
    procedure Update;virtual;abstract;
  end;

  {$Region ' Local Network ' }

  TPmLocalNetworkChange = class( TPmNetworkChange )
  public
    procedure Update;override;
  end;

  TPmLocalNetworkLoad = class( TPmLocalNetworkChange )
  end;

  TPmLocalNetworkSelect = class( TPmLocalNetworkChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  TPmRemoteNetworkChange = class( TPmNetworkChange )
  public
    SelectStr : string;
  public
    procedure SetSelectStr( _SelectStr : string );
    procedure Update;override;
  end;

  {$Region ' Standard Network ' }

    // Standard Netowrk Change
  TPmStandardNetworkChange = class( TPmRemoteNetworkChange )
  public
    procedure Update;override;
  end;

    // Load From Ini File
  TPmStandardNetworkLoad = class( TPmStandardNetworkChange )
  end;

    // User Selected
  TPmStandardNetworkSelect = class( TPmStandardNetworkChange )
  public
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' Advance Network ' }

    // Advance Netowrk Change
  TPmAdvanceNetworkChange = class( TPmRemoteNetworkChange )
  public
    procedure Update;override;
  end;

    // Load From Ini File
  TPmAdvanceNetworkLoad = class( TPmAdvanceNetworkChange )
  end;

    // User Selected
  TPmAdvaceNetworkSelect = class( TPmAdvanceNetworkChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // Load Ini
  TNetworkModeLoadIni = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Setting Parent ' }

    // Setting 处理 父类
  TSettingHandle = class
  public
    procedure Update;virtual;
  private       // Local Network
    procedure SetNetworkInfo;virtual;abstract;
  private       // Remove Network
    procedure SetStandardNetworkInfo;virtual;abstract;
    procedure SetAdvanceNetworkInfo; virtual;abstract;
  private       // Transfers
    procedure SetFileTransferInfo;virtual;abstract;
    procedure SetTransferSafeInfo;virtual;abstract;
  private       // Backup
    procedure SetBackupFileSafeInfo;virtual;abstract;
    procedure SetSyncTimeInfo;virtual;abstract;
    procedure SetEncodeFileInfo;virtual;abstract;
  private       // Cloud
    procedure SetShareInfo;virtual;abstract;
    procedure SetCloudSafeInfo;virtual;abstract;
  private       // File Visible
    procedure SetFileVisibleInfo;virtual;abstract;
  private       // Application
    procedure SetApplicetionInfo;virtual;abstract;
  private       // File Receive
    procedure SetFileReceiveInfo;virtual;abstract;
  private       // File SearchDown
    procedure SetFileSearchDownInfo;virtual;abstract;
  end;

{$EndRegion}

{$Region ' Setting Ini ' }

    // Setting Ini 处理
  TFormSettingIniHandle = class( TSettingHandle )
  protected
    IniFile : TIniFile;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // Ini 加载
  TFormSettingLoadIni = class( TFormSettingIniHandle )
  private       // Local Network
    procedure SetNetworkInfo;override;
  private       // Remove Network
    procedure SetStandardNetworkInfo;override;
    procedure SetAdvanceNetworkInfo;override;
  private       // Transfers
    procedure SetFileTransferInfo;override;
    procedure SetTransferSafeInfo;override;
  private       // Backup
    procedure SetBackupFileSafeInfo;override;
    procedure SetSyncTimeInfo;override;
    procedure SetEncodeFileInfo;override;
  private       // Cloud
    procedure SetShareInfo;override;
    procedure SetCloudSafeInfo;override;
  private       // File Visible
    procedure SetFileVisibleInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  private       // File Receive
    procedure SetFileReceiveInfo;override;
  private       // File SearchDown
    procedure SetFileSearchDownInfo;override;
  end;

    // Ini 保存
  TFormSettingSaveIni = class( TFormSettingIniHandle )
  private       // Local Network
    procedure SetNetworkInfo;override;
  private       // Remove Network
    procedure SetStandardNetworkInfo;override;
    procedure SetAdvanceNetworkInfo;override;
  private       // Transfers
    procedure SetFileTransferInfo;override;
    procedure SetTransferSafeInfo;override;
  private       // Backup
    procedure SetBackupFileSafeInfo;override;
    procedure SetSyncTimeInfo;override;
    procedure SetEncodeFileInfo;override;
  private       // Cloud
    procedure SetShareInfo;override;
    procedure SetCloudSafeInfo;override;
  private       // File Visible
    procedure SetFileVisibleInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  private       // File Receive
    procedure SetFileReceiveInfo;override;
  private       // File SearchDown
    procedure SetFileSearchDownInfo;override;
  end;

{$EndRegion}

{$Region ' Setting Apply ' }

      // Click Apply Click
  TCheckApplyClick = class
  private
    ShowErrorStr : string;
    ErrorHandle : Integer;
  public
    function get : Boolean;
  private
    function CheckComputer: Boolean;
    function CheckEncFile: Boolean;
    function CheckCloudID : Boolean;
    function CheckFileInvisible : Boolean;
  end;

    // Apply
  TSetApplyHandleBase = class( TSettingHandle )
  private
    IsRestartNetwork : Boolean;
    IsFirstApply : Boolean;
  private       // Local Network
    procedure SetNetworkInfo;override;
  private       // Remove Network
    procedure SetStandardNetworkInfo;override;
    procedure SetAdvanceNetworkInfo;override;
  private       // Transfers
    procedure SetFileTransferInfo;override;
    procedure SetTransferSafeInfo;override;
  private       // Backup
    procedure SetBackupFileSafeInfo;override;
    procedure SetSyncTimeInfo;override;
    procedure SetEncodeFileInfo;override;
  private       // Cloud
    procedure SetShareInfo;override;
    procedure SetCloudSafeInfo;override;
  private       // File Visible
    procedure SetFileVisibleInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  private       // File Receive
    procedure SetFileReceiveInfo;override;
  private       // File SearchDown
    procedure SetFileSearchDownInfo;override;
  end;

    // 第一次 Apply
  TSetFirstApplyHandle = class( TSetApplyHandleBase )
  public
    constructor Create;
  end;

    // 第一次之后 Apply
  TSetApplyHandle = class( TSetApplyHandleBase )
  public
    constructor Create;
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Setting Cancel ' }

    // Cancel
  TSetCancelHandle = class( TSettingHandle )
  private       // Local Network
    procedure SetNetworkInfo;override;
  private       // Remove Network
    procedure SetStandardNetworkInfo;override;
    procedure SetAdvanceNetworkInfo;override;
  private       // Transfers
    procedure SetFileTransferInfo;override;
    procedure SetTransferSafeInfo;override;
  private       // Backup
    procedure SetBackupFileSafeInfo;override;
    procedure SetSyncTimeInfo;override;
    procedure SetEncodeFileInfo;override;
  private       // Cloud
    procedure SetShareInfo;override;
    procedure SetCloudSafeInfo;override;
  private       // File Visible
    procedure SetFileVisibleInfo;override;
  private       // Application
    procedure SetApplicetionInfo;override;
  private       // File Receive
    procedure SetFileReceiveInfo;override;
  private       // File SearchDown
    procedure SetFileSearchDownInfo;override;
  end;

{$EndRegion}

const
  AddStandardResult_OK = 0;
  AddStandardResult_NameEmpty = 1;
  AddStandardResult_PasswordEmpty = 2;
  AddStandardResult_Exist = 3;

var
  Default_LanPort : Integer = 9595;

const
  rgSpeed_Low = 0;
  rgSpeed_Normal = 1;
  rgSpeed_High  = 2;

  Default_IsShare = True;
  Default_MaxSpaceType = FileSizeType_GB;
  Default_MaxSpaceValue = 10;
  Default_MinSpaceType = FileSizeType_GB;
  Default_MinSpaceValue = 1;

  Default_SyncTime : Integer = 60;
  Default_IsSync : Boolean = True;
  Default_SyncTimeType = 0;
  Default_IsAutoSync = True;

  Default_IsEncrypt : Boolean = False;
  Default_Password : string = '';
  Default_PasswordTips : string = '';

  Default_Speed : Integer = rgSpeed_High;
  Default_UpThreadCount : Integer = 5;
  Default_DownThreadCount : Integer = 5;

  Default_CopyCount : Integer = 1;
  Default_CloudLostValue = 5;
  Default_CloudLostType = TimeType_Day;

  Default_CheckMD5 : Boolean = False;
  Default_CheckRemoteForbid : Boolean = False;

  Default_CloudSafe : Boolean = False;
  Default_CloudIDNum : string = '';

  Default_IvFileSearch : Boolean = False;
  Default_IvRestore : Boolean = False;
  Default_IvPassword : string = '';

  Default_RunAppStartup : Boolean = False;
  Default_ShowDialogBeforeExit : Boolean = True;
  Default_Language = 1;

  Default_IsReceiveFile : Boolean = True;
  Default_IsShowReceiveHint : Boolean = True;

  Default_IsSelectSearchDown : Boolean = False;


  Ini_AccountName = 'AccountName';
  Ini_AccountPassword = 'AccountPassword';
  Ini_Domain = 'Domain';
  Ini_Port = 'Port';

  Icon_StandardNetwork = 0;
  Icon_SelectNetwork = 1;
  Icon_AdvanceNetwork = 2;

  Tag_RemoteOpen : Integer = 0;
  Tag_RemoteClose : Integer = 1;

    // Computer
//  ShowHint_InputComputerName : string = 'Please input Computer Name';
//  ShowHint_PortError : string = 'Port number is incorrect. Please Input a number between 1 and 65535';

    // File Encrypt
//  ShowHint_InputPassword : string = 'Please input Password';
//  ShowHint_PasswordNotMatch : string = 'Password and Retype Password are not matched';
//  ShowForm_ResetPassword = 'New pre-set password will only take effect for new backup items.' + #10#13 +
//                                    'Your previous backup items still use the old encryption password. Are you sure to proceed ?';

    // Share
//  ShowForm_ResetSharePath : string = 'If you change the share path, all previous backups of other cloud users will be lost. Are you sure to change?';
  FormTitle_ResetSharePath : string = 'Select your share path';

    // Cloud ID Num
//  ShowHint_InputCloudIDNum : string = 'Please input ID Number';

    // File Invisible
//  ShowHint_InputRestorePassword = 'Please input Restore Password';
//  ShowHint_RestorePasswordNotMatch = 'Password and Retype Restore Password are not matched';

    // Remote Network
//  ShowHint_InputAccountName : string = 'Please input Group Name';
//  ShowHint_AccountExist : string = 'Group Name is exist';
//  ShowHint_InputDomain : string = 'Please input Domain or Ip';
//  ShowHint_ComputerExist : string = 'Computer is exist';

    // File Transfer
  FormTitle_ResetReceivePath : string = 'Select your receive path';
//  FormTitle_ResetDownloadPath : string = 'Select your download path';

  NbPage_Discription = 0;
  NbPage_Add = 1;

  BtnStandardOKTag_Add = 0;
  BtnStandardOKTag_ChangePassword = 1;

  PmNetworkIcon_Selected = 0;
  PmRemoteNetworkIcon_Selected = 3;

  Ini_NetworkMode = 'NetworkMode';
  Ini_SelectedMode = 'SelectedMode';
  Ini_SelectStr = 'SelectStr';

  SelectedMode_Local = 'Local';
  SelectedMode_Standard = 'Standard';
  SelectedMode_Advance = 'Advance';

  Split_PmAdvance : string = ' : ';

  LvAdvance_Port = 0;
  LvAdvance_Domain = 1;

  Dns_Parsing : string = 'Parsing';



var
  Default_CloudPathName : string = 'BackupCow.Backup';
  Default_ReceivePathName : string = 'BackupCow.Receive';
  Default_SearchDownPathName : string = 'BackupCow.Download';

var
  frmSetting : TfrmSetting;

implementation

uses USettingInfo, UBackupInfoFace, UMyBackupInfo, UMyClient, UMyFileTransfer, UMyFileDownload,
     UMyFileUpload, UMainForm, UMyNetPcInfo, USearchServer, UNetworkFace, UFormUtil,
     UBackupFileLostConn, UMyUrl, UMyCloudFileControl, URestoreFileFace, UBackupInfoXml, URegisterInfoIO,
     UFromEnterGroup;

{$R *.dfm}

procedure TfrmSetting.AfterApplyClick;
begin
    // Encrypt
  lbReqEncPassword.Visible := False;
  lbReqEncPassword2.Visible := False;
  btnResetPassword.Visible := chkIsEncrypt.Checked and ( edtEncPassword.Text <> '' );
  edtEncPassword.ReadOnly := btnResetPassword.Visible;
  edtEncPassword2.ReadOnly := btnResetPassword.Visible;
  edtEncPasswordHint.ReadOnly := btnResetPassword.Visible;

    // Cloud ID
  lbReqCloudIDNum.Visible := False;

    // File Invisible
  lbReqIvPassword.Visible := False;
  lbReqIvPassword2.Visible := False;
end;

procedure TfrmSetting.BindSettingChange( Wcontrol: TWinControl );
var
  i : Integer;
  c : TControl;
begin
  for i := 0 to Wcontrol.ControlCount - 1 do
  begin
    c := Wcontrol.Controls[i];
    if c.Tag = -1 then
      Continue;
    if c is TSpinEdit then
      ( c as TSpinEdit ).OnChange := SettingChange
    else
    if c is TEdit then
      ( c as TEdit ).OnChange := SettingChange
    else
    if c is TRzNumericEdit then
      ( c as TRzNumericEdit ).OnChange := SettingChange
    else
    if c is TComboBox then
      ( c as TComboBox ).OnChange := SettingChange
    else
    if c is TTrackBar then
      ( c as TTrackBar ).OnChange := SettingChange
    else
    if c is TRzCheckBox then
      ( c as TRzCheckBox ).OnClick := SettingChange
    else
    if c is TWinControl then
      BindSettingChange( c as TWinControl );
  end;
end;

procedure TfrmSetting.BindSort;
begin
  ListviewUtil.BindSort( lvStandard );
  ListviewUtil.BindSort( lvAdvance );
end;

procedure TfrmSetting.BindToolbar;
begin
  lvStandard.PopupMenu := FormUtil.getPopMenu( tbLvStandard );
  lvAdvance.PopupMenu := FormUtil.getPopMenu( tbLvAdvance );
end;

procedure TfrmSetting.btnAdvanceAddClick(Sender: TObject);
var
  LvAdvanceData : TLvAdvanceData;
  Domain, Port, Ip, ErrorStr : string;
  LvAdvanceAddHandle : TLvAdvanceAddHandle;
begin
    // 判断输入是否错误
  Domain := edtDomain.Text;
  Port := edtAdvancePort.Text;

  ErrorStr := '';
  if Domain = '' then
    ErrorStr := siLang_frmSetting.GetText( 'InputDomain' )
  else
  if not MyParseHost.IsPortStr( Port ) then
    ErrorStr := siLang_frmSetting.GetText( 'PortError' )
  else
  begin
    LvAdvanceAddHandle := TLvAdvanceAddHandle.Create( Domain, Port );
    if not LvAdvanceAddHandle.Update then    // 已存在 返回 False
      ErrorStr := siLang_frmSetting.GetText( 'ComputerExist' );
    LvAdvanceAddHandle.Free;
  end;

    // 错误的情况
  if ErrorStr <> '' then
  begin
    MyMessageHint.ShowError( Self.Handle, ErrorStr );
    Exit;
  end;

    // 切换页面
  nbAdvance.PageIndex := NbPage_Discription;
  ShowApplyButton;
end;


procedure TfrmSetting.btnAdvanceCancelClick(Sender: TObject);
begin
  nbAdvance.PageIndex := NbPage_Discription;
end;

function TfrmSetting.BtnAppClick: Boolean;
var
  CheckApplyClick : TCheckApplyClick;
  IsApply : Boolean;
begin
  Result := False;

  CheckApplyClick := TCheckApplyClick.Create;
  IsApply := CheckApplyClick.get;
  CheckApplyClick.Free;

  if not IsApply then
    Exit;

  btnApply.Enabled := False;

  SetApplySettings;

  SaveIni;

  AfterApplyClick;

    // 更新 云信息
  MyClient.UpgradeCloudInfo;
  Result := True;
end;

procedure TfrmSetting.btnApplyClick(Sender: TObject);
begin
  BtnAppClick;
end;

procedure TfrmSetting.btnCancelClick(Sender: TObject);
begin
  frmSetting.Close;

  SetCancelSettings;
end;

procedure TfrmSetting.btnOKClick(Sender: TObject);
var
  IsCloseSetForm : Boolean;
begin
  IsCloseSetForm := True;

    // Apply Click
  if btnApply.Enabled and not BtnAppClick then
    IsCloseSetForm := False;

    // Close Error
  if IsCloseSetForm then
    frmSetting.Close;
end;

procedure TfrmSetting.btnRecevicePathBrowseClick(Sender: TObject);
var
  ReceivePath : string;
begin
  if MySelectFolderDialog.Select( FormTitle_ResetReceivePath, edtRecevicePath.Text, ReceivePath, Self.Handle ) then
  begin
    edtRecevicePath.Text := ReceivePath;
    ShowApplyButton;
  end;
end;

procedure TfrmSetting.btnResetPasswordClick(Sender: TObject);
var
  ShowStr : string;
begin
  ShowStr := siLang_frmSetting.GetText( 'ResetPassword1' );
  ShowStr := ShowStr + #13#10 + siLang_frmSetting.GetText( 'ResetPassword2' );
  if not MyMessageBox.ShowConfirm( ShowStr ) then
    Exit;

  edtEncPassword.ReadOnly := False;
  edtEncPassword2.ReadOnly := False;
  edtEncPasswordHint.ReadOnly := False;

  lbReqEncPassword.Visible := True;
  lbREqEncPassword2.Visible := True;
end;

procedure TfrmSetting.btnSharePathClick(Sender: TObject);
var
  SharePath : string;
begin
  if MySelectFolderDialog.Select( FormTitle_ResetSharePath, edtSharePath.Text, SharePath, Self.Handle ) then
  begin
    edtSharePath.Text := SharePath;
    ShowApplyButton;
  end;
end;


procedure TfrmSetting.btnStanardOKClick(Sender: TObject);
var
  IsAddGroup : Boolean;
  AccountName, AccountPassword, ErrorStr : string;
  NetworkGroupAddHandle : TLvStandardAddHandle;
  NetworkGroupPasswordHandle : TLvStandardPasswordHandle;
begin
    // 判断输入是否错误
  IsAddGroup := btnStanardOK.Tag = BtnStandardOKTag_Add;
  AccountName := edtAccountName.Text;
  AccountPassword := edtAccountPassword.Text;

  ErrorStr := '';
  if AccountName = '' then
    ErrorStr := siLang_frmSetting.GetText( 'InputGroupName' )
  else
  if AccountPassword = '' then
    ErrorStr := siLang_frmSetting.GetText( 'InputPassword' )
  else
  if IsAddGroup then  // 添加组
  begin
    NetworkGroupAddHandle := TLvStandardAddHandle.Create( AccountName, AccountPassword );
    if not NetworkGroupAddHandle.Update then
      ErrorStr := siLang_frmSetting.GetText( 'GroupNameExist' );
    NetworkGroupAddHandle.Free
  end
  else        // 修改组密码
  begin
    NetworkGroupPasswordHandle := TLvStandardPasswordHandle.Create( AccountName, AccountPassword );
    NetworkGroupPasswordHandle.Update;
    NetworkGroupPasswordHandle.Free;
  end;

    // 错误的情况
  if ErrorStr <> '' then
  begin
    MyMessageHint.ShowError( Self.Handle, ErrorStr );
    Exit;
  end;

    // 添加 / 修改密码 成功
  nbStandard.PageIndex := NbPage_Discription;
  ShowApplyButton;
end;

procedure TfrmSetting.btnStandardCancelClick(Sender: TObject);
begin
  nbStandard.PageIndex := NbPage_Discription;
end;

procedure TfrmSetting.btnDownloadPathBrowseClick(Sender: TObject);
var
  DownloadPath : string;
begin
  if MySelectFolderDialog.Select( siLang_frmSetting.GetText( 'SelectDownPath' ), edtDownloadPath.Text, DownloadPath, Self.Handle ) then
  begin
    edtDownloadPath.Text := DownloadPath;
    ShowApplyButton;
  end;
end;

procedure TfrmSetting.StandardChangePassword(AccountName: string);
begin
  edtAccountName.Text := AccountName;
  edtAccountName.ReadOnly := True;
  btnStanardOK.Tag := BtnStandardOKTag_ChangePassword;
  edtAccountPassword.Clear;
  nbStandard.PageIndex := NbPage_Add;
end;

procedure TfrmSetting.chkIsCloudIDClick(Sender: TObject);
var
  IsShow : Boolean;
begin
  IsShow := chkIsCloudID.Checked;

  lbCloudIDNum.Enabled := IsShow;
  edtCloudIDNum.Enabled := IsShow;
  lbReqCloudIDNum.Visible := IsShow;

  ShowApplyButton;
end;

procedure TfrmSetting.chkIsEncryptClick(Sender: TObject);
var
  IsShow : Boolean;
  IsReset : Boolean;
begin
  IsShow := chkIsEncrypt.Checked;

  lbEncPassword.Enabled := IsShow;
  edtEncPassword.Enabled := IsShow;

  lbEncPassword2.Enabled := IsShow;
  edtEncPassword2.Enabled := IsShow;

  lbEncPasswordHint.Enabled := IsShow;
  edtEncPasswordHint.Enabled := IsShow;

  if IsShow then
  begin
    IsReset := edtEncPassword.Text <> '';

    btnResetPassword.Visible := IsReset;

    lbReqEncPassword.Visible := not IsReset;
    lbREqEncPassword2.Visible := not IsReset;

    edtEncPassword.ReadOnly := IsReset;
    edtEncPassword2.ReadOnly := IsReset;
    edtEncPasswordHint.ReadOnly := IsReset;
  end
  else
  begin
    btnResetPassword.Visible := False;
    lbReqEncPassword.Visible := False;
    lbREqEncPassword2.Visible := False;
  end;

  ShowApplyButton;
end;

procedure TfrmSetting.chkIsFileInvisibleClick(Sender: TObject);
var
  IsShow : Boolean;
begin
  IsShow := chkIsFileInvisible.Checked;

  lbIvFileSearch.Enabled := IsShow;
  lbIvRestore.Enabled := IsShow;

  lbIvPassword.Enabled := IsShow;
  edtIvPassword.Enabled := IsShow;
  lbReqIvPassword.Visible := IsShow;

  lbIvPassword2.Enabled := IsShow;
  edtIvPassword2.Enabled := IsShow;
  lbReqIvPassword2.Visible := IsShow;

  ShowApplyButton;
end;

procedure TfrmSetting.chkIsShareClick(Sender: TObject);
var
  IsShow : Boolean;
begin
  IsShow := chkIsShare.Checked;

  lbSharePath.Enabled := IsShow;
  edtSharePath.Enabled := IsShow;
  btnSharePath.Enabled := IsShow;

  lbMinSpace.Enabled := IsShow;
  seMinSpaceValue.Enabled := IsShow;
  cbbMinSpaceType.Enabled := IsShow;

  lbMaxSpace.Enabled := IsShow;
  seMaxSpaceValue.Enabled := IsShow;
  cbbMaxSpaceType.Enabled := IsShow;

  ShowApplyButton;
end;

procedure TfrmSetting.chkRunAppStartupClick(Sender: TObject);
begin
  SetApplySettings;
end;

procedure TfrmSetting.ChkSyncTimeClick(Sender: TObject);
var
  IsEnable : Boolean;
begin
  IsEnable := ChkSyncTime.Checked;
  seSyncTime.Enabled := IsEnable;
  cbbSyncTime.Enabled := IsEnable;

  ShowApplyButton;
end;

procedure TfrmSetting.chkIsSelectDownloadPathClick(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.FormCreate(Sender: TObject);
var
  IpList : TStringList;
  Ip : string;
  i : Integer;
begin
  AdvanceDnsThread := TAdvanceDnsThread.Create;

  BindSettingChange( Self );
  BindToolbar;
  BindSort;

  cbbIP.Clear;
  IpList := MyIpList.get;
  for i := 0 to IpList.Count - 1 do
  begin
    Ip := IpList[i];
    cbbIP.Items.Add( Ip );
  end;
  IpList.Free;

  if App_RunWay = AppRunWay_FolderTransfer then
    PcMain.ActivePage := tsLocalNetwork
  else
    pcMain.ActivePage := tsBackup;

  IsEnableRemoteNetwork := True;

  siLang_frmSettingChangeLanguage( nil );
end;

procedure TfrmSetting.FormDestroy(Sender: TObject);
begin
  AdvanceDnsThread.Free;
end;

procedure TfrmSetting.FormShow(Sender: TObject);
begin
  btnApply.Enabled := False;
  AfterApplyClick;
end;

procedure TfrmSetting.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmSetting.LoadIni;
var
  FormSettingLoadIni : TFormSettingLoadIni;
begin
  FormSettingLoadIni := TFormSettingLoadIni.Create;
  FormSettingLoadIni.Update;
  FormSettingLoadIni.Free;
end;

procedure TfrmSetting.LoadNetworkMode;
var
  NetworkModeLoadIni : TNetworkModeLoadIni;
begin
  NetworkModeLoadIni := TNetworkModeLoadIni.Create;
  NetworkModeLoadIni.Update;
  NetworkModeLoadIni.Free;
end;

procedure TfrmSetting.lvAdvanceDblClick(Sender: TObject);
begin
  if tbtnAdvanceSelected.Enabled then
    tbtnAdvanceSelected.Click;
end;

procedure TfrmSetting.lvAdvanceDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmSetting.lvAdvanceKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnAdvanceRemove, tbtnAdvanceSelected, Key );
end;

procedure TfrmSetting.lvAdvanceSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  tbtnAdvanceRemove.Enabled := Selected;
  tbtnAdvanceSelected.Enabled := Selected;
end;

procedure TfrmSetting.lvStandardDblClick(Sender: TObject);
begin
  if tbtnStandardSelected.Enabled then
    tbtnStandardSelected.Click;
end;

procedure TfrmSetting.lvStandardDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmSetting.lvStandardKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnStandardRemove, tbtnStandardSelected, Key );
end;

procedure TfrmSetting.lvStandardSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  tbtnStandardRemove.Enabled := Selected;
  tbtnStandardChangePassword.Enabled := Selected;
  tbtnStandardSelected.Enabled := Selected;
end;

procedure TfrmSetting.pmAdvanceNetworkClick(Sender: TObject);
var
  SelectShowStr : string;
  miSelected : TMenuItem;
  PmAdvaceNetworkSelect : TPmAdvaceNetworkSelect;
begin
  miSelected := ( Sender as TMenuItem );
  SelectShowStr := miSelected.Caption;

  if ( miSelected.ImageIndex = PmRemoteNetworkIcon_Selected ) and
       not MyMessageBox.ShowConfirm( ShowForm_RestartNetwork )
  then
    Exit;

    // 进入所选择的网络
  PmAdvaceNetworkSelect := TPmAdvaceNetworkSelect.Create;
  PmAdvaceNetworkSelect.SetSelectStr( SelectShowStr );
  PmAdvaceNetworkSelect.Update;
  PmAdvaceNetworkSelect.Free;
end;

procedure TfrmSetting.pmLanNetworkClick(Sender: TObject);
var
  PmLocalNetworkSelect : TPmLocalNetworkSelect;
begin
  if ( frmMainForm.tbtnNwLan.ImageIndex = PmNetworkIcon_Selected ) and
       not MyMessageBox.ShowConfirm( ShowForm_RestartNetwork )
  then
    Exit;

  PmLocalNetworkSelect := TPmLocalNetworkSelect.Create;
  PmLocalNetworkSelect.Update;
  PmLocalNetworkSelect.Free;
end;

procedure TfrmSetting.pmStandardNetworkClick(Sender: TObject);
var
  miSelected : TMenuItem;
  SelectStr : string;
  PmStandardNetworkSelect : TPmStandardNetworkSelect;
begin
  miSelected := Sender as TMenuItem;
  SelectStr := miSelected.Caption;

  if ( miSelected.ImageIndex = PmRemoteNetworkIcon_Selected ) and
       not MyMessageBox.ShowConfirm( ShowForm_RestartNetwork )
  then
    Exit;

  PmStandardNetworkSelect := TPmStandardNetworkSelect.Create;
  PmStandardNetworkSelect.SetSelectStr( SelectStr );
  PmStandardNetworkSelect.Update;
  PmStandardNetworkSelect.Free;
end;

procedure TfrmSetting.rbNerverReceiveClick(Sender: TObject);
var
  IsEnable : Boolean;
begin
  IsEnable := not rbNerverReceive.Checked;
  lbRecevicePath.Enabled := IsEnable;
  EdtRecevicePath.Enabled := IsEnable;
  btnRecevicePathBrowse.Enabled := IsEnable;
  chkRevFileShowHint.Enabled := IsEnable;

  ShowApplyButton;
end;


procedure TfrmSetting.SaveIni;
var
  FormSettingSaveIni : TFormSettingSaveIni;
begin
  FormSettingSaveIni := TFormSettingSaveIni.Create;
  FormSettingSaveIni.Update;
  FormSettingSaveIni.Free;

    // 隐藏 配置文件
  MyHideFile.Hide( MyIniFile.getIniFilePath );
end;

procedure TfrmSetting.SetApplySettings;
var
  SetApplyHandle : TSetApplyHandle;
begin
  SetApplyHandle := TSetApplyHandle.Create;
  SetApplyHandle.Update;
  SetApplyHandle.Free;
end;

procedure TfrmSetting.SetCancelSettings;
var
  SetCancelHandle : TSetCancelHandle;
begin
  SetCancelHandle := TSetCancelHandle.Create;
  SetCancelHandle.Update;
  SetCancelHandle.Free;
end;

procedure TfrmSetting.SetFirstApplySettings;
var
  SetFirstApplyHandle : TSetFirstApplyHandle;
begin
  SetFirstApplyHandle := TSetFirstApplyHandle.Create;
  SetFirstApplyHandle.Update;
  SetFirstApplyHandle.Free;
end;

procedure TfrmSetting.SettingChange(Sender: TObject);
begin
  ShowApplyButton;
end;

procedure TfrmSetting.ShowApplyButton;
begin
  btnApply.Enabled := True;
end;

procedure TfrmSetting.siLang_frmSettingChangeLanguage(Sender: TObject);
var
  i, j : Integer;
begin
  j := cbbSyncTime.ItemIndex;
  cbbSyncTime.Items.Clear;
  cbbSyncTime.Items.Add( siLang_frmSetting.GetText( 'Minues' ) );
  cbbSyncTime.Items.Add( siLang_frmSetting.GetText( 'Hours' ) );
  cbbSyncTime.Items.Add( siLang_frmSetting.GetText( 'Days' ) );
  cbbSyncTime.Items.Add( siLang_frmSetting.GetText( 'Weeks' ) );
  cbbSyncTime.Items.Add( siLang_frmSetting.GetText( 'Months' ) );
  cbbSyncTime.ItemIndex := j;

  j := cbbCloudLostTye.ItemIndex;
  cbbCloudLostTye.Items.Clear;
  cbbCloudLostTye.Items.Add( siLang_frmSetting.GetText( 'Minues' ) );
  cbbCloudLostTye.Items.Add( siLang_frmSetting.GetText( 'Hours' ) );
  cbbCloudLostTye.Items.Add( siLang_frmSetting.GetText( 'Days' ) );
  cbbCloudLostTye.Items.Add( siLang_frmSetting.GetText( 'Weeks' ) );
  cbbCloudLostTye.Items.Add( siLang_frmSetting.GetText( 'Months' ) );
  cbbCloudLostTye.ItemIndex := j;

  j := cbbLanguage.ItemIndex;
  cbbLanguage.Items.Clear;
  cbbLanguage.Items.Add( siLang_frmSetting.GetText( 'English' ) );
  cbbLanguage.Items.Add( siLang_frmSetting.GetText( 'Chinese' ) );
  cbbLanguage.Items.Add( siLang_frmSetting.GetText( 'Japanese' ) );
  cbbLanguage.ItemIndex := j;

  with lvStandard do
  begin
    Columns[0].Caption := siLang_frmSetting.GetText( 'lvGroupName' );
  end;

  with lvAdvance do
  begin
    Columns[0].Caption := siLang_frmSetting.GetText( 'lvIP' );
    Columns[LvAdvance_Port + 1].Caption := siLang_frmSetting.GetText( 'Port' );
    Columns[LvAdvance_Domain + 1].Caption := siLang_frmSetting.GetText( 'lvDomain' );
  end;
end;

procedure TfrmSetting.tbtnAdvanceAddClick(Sender: TObject);
begin
  edtDomain.Clear;
  edtAdvancePort.Text := '9595';
  nbAdvance.PageIndex := NbPage_Add;
end;

procedure TfrmSetting.tbtnAdvanceRemoveClick(Sender: TObject);
begin
  lvAdvance.DeleteSelected;
  ShowApplyButton;
end;

procedure TfrmSetting.tbtnAdvanceSelectedClick(Sender: TObject);
var
  SelectItem : TListItem;
  ItemData : TLvAdvanceData;
begin
      // 不支持 Remote Network
  if not IsEnableRemoteNetwork then
  begin
    MyMessageBox.ShowWarnning( ShowForm_RemoteForbid );
    Exit;
  end;

  SelectItem := lvAdvance.Selected;
  if SelectItem = nil then
    Exit;

  ItemData := SelectItem.Data;
  if ItemData.IsSelected then
  begin
    ItemData.IsSelected := False;
    SelectItem.ImageIndex := Icon_AdvanceNetwork
  end
  else
    LvRemoteNetworkUtil.SetAdvanceSelected( ItemData.Domain, ItemData.Port );

  ShowApplyButton;
end;


procedure TfrmSetting.tbtnStandardAddClick(Sender: TObject);
begin
  edtAccountName.Clear;
  edtAccountPassword.Clear;
  edtAccountName.ReadOnly := False;
  btnStanardOK.Tag := BtnStandardOKTag_Add;
  nbStandard.PageIndex := NbPage_Add;
end;

procedure TfrmSetting.tbtnStandardChangePasswordClick(Sender: TObject);
var
  LvStarndData : TLvStandardData;
begin
  LvStarndData := lvStandard.Selected.Data;
  StandardChangePassword( LvStarndData.AccountName );
end;

procedure TfrmSetting.tbtnStandardRemoveClick(Sender: TObject);
begin
  lvStandard.DeleteSelected;
  ShowApplyButton;
end;

procedure TfrmSetting.tbtnStandardSelectedClick(Sender: TObject);
var
  SelectItem : TListItem;
  ItemData : TLvStandardData;
begin
    // 不支持 Remote Network
  if not IsEnableRemoteNetwork then
  begin
    MyMessageBox.ShowWarnning( Self.Handle, ShowForm_RemoteForbid );
    Exit;
  end;

  SelectItem := lvStandard.Selected;
  if SelectItem = nil then
    Exit;

  ItemData := SelectItem.Data;
  if ItemData.IsSelected then
  begin
    ItemData.IsSelected := False;
    SelectItem.ImageIndex := Icon_StandardNetwork
  end
  else
    LvRemoteNetworkUtil.setLvStandardSelected( ItemData.AccountName );

  ShowApplyButton;
end;

{ TFormSettingLoadIni }

procedure TFormSettingLoadIni.SetAdvanceNetworkInfo;
var
  ItemCount, i : Integer;
  LvAdvanceData : TLvAdvanceData;
  SectionName, Domain, Port : string;
  LvAdvanceAddHandle : TLvAdvanceAddHandle;
begin
  with frmSetting do
  begin
    ItemCount := IniFile.ReadInteger( frmSetting.Name, lvAdvance.Name, 0 );

    for i := 0 to ItemCount - 1 do
    begin
      SectionName := lvAdvance.Name + IntToStr(i);
      Domain := IniFile.ReadString( SectionName, Ini_Domain, '' );
      Port := IniFile.ReadString( SectionName, Ini_Port, '' );

        // Ini 文件 损坏
      if ( Domain = '' ) or ( Port = '' ) then
        Continue;

        // 添加 Advance 界面
      LvAdvanceAddHandle := TLvAdvanceAddHandle.Create( Domain, Port );
      LvAdvanceAddHandle.Update;
      LvAdvanceAddHandle.Free;
    end;
  end;
end;

procedure TFormSettingLoadIni.SetApplicetionInfo;
begin
  with frmSetting do
  begin
    chkRunAppStartup.Checked := IniFile.ReadBool( frmSetting.Name, chkRunAppStartup.Name, Default_RunAppStartup );
    chkShowAppExistDialog.Checked := IniFile.ReadBool( frmSetting.Name, chkShowAppExistDialog.Name, Default_ShowDialogBeforeExit );
    cbbLanguage.ItemIndex := IniFile.ReadInteger( frmSetting.Name, cbbLanguage.Name, Default_Language );
  end;
end;

procedure TFormSettingLoadIni.SetBackupFileSafeInfo;
begin
  with frmSetting do
  begin
    seCopyCount.Value := IniFile.ReadInteger( frmSetting.Name, seCopyCount.Name, Default_CopyCount );

    seCloudLostValue.Value := IniFile.ReadInteger( frmSetting.Name, seCloudLostValue.Name, Default_CloudLostValue );
    cbbCloudLostTye.ItemIndex := IniFile.ReadInteger( frmSetting.Name, cbbCloudLostTye.Name, Default_CloudLostType );

    DefaultXml_CopyCount := seCopyCount.Value;
  end;
end;

procedure TFormSettingLoadIni.SetCloudSafeInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    chkIsCloudID.Checked := IniFile.ReadBool( frmSetting.Name, chkIsCloudID.Name, Default_CloudSafe );

      // 解密
    KeyStr := IniFile.ReadString( frmSetting.Name, edtCloudIDNum.Name, Default_CloudIDNum );
    KeyStr := MyEncrypt.DecodeStr( KeyStr );

    edtCloudIDNum.Text := KeyStr;
  end;
end;

procedure TFormSettingLoadIni.SetEncodeFileInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    edtEncPasswordHint.Text := IniFile.ReadString( frmSetting.Name, edtEncPasswordHint.Name, Default_PasswordTips );
    chkIsEncrypt.Checked := IniFile.ReadBool( frmSetting.Name, chkIsEncrypt.Name, Default_IsEncrypt );

      // 解密
    KeyStr := IniFile.ReadString( frmSetting.Name, edtEncPassword.Name, Default_Password );
    KeyStr := MyEncrypt.DecodeStr( KeyStr );

    edtEncPassword.Text := KeyStr;
    edtEncPassword2.Text := KeyStr;
  end;

end;

procedure TFormSettingLoadIni.SetFileReceiveInfo;
var
  DefaultReceivePath : string;
begin
  DefaultReceivePath := MyHardDisk.getBiggestHardDIsk + Default_ReceivePathName;

  with frmSetting do
  begin
    edtRecevicePath.Text := IniFile.ReadString( frmSetting.Name, edtRecevicePath.Name, DefaultReceivePath );
    chkRevFileShowHint.Checked := IniFile.ReadBool( frmSetting.Name, chkRevFileShowHint.Name, Default_IsShowReceiveHint );

    rbAutoReceive.Checked := IniFile.ReadBool( frmSetting.Name, rbAutoReceive.Name, True );
    rbManualReceive.Checked := IniFile.ReadBool( frmSetting.Name, rbManualReceive.Name, False );
    rbNerverReceive.Checked := IniFile.ReadBool( frmSetting.Name, rbNerverReceive.Name, False );
  end;
end;

procedure TFormSettingLoadIni.SetFileSearchDownInfo;
var
  DefaultDownloadPath : string;
begin
  DefaultDownloadPath := MyHardDisk.getBiggestHardDIsk + Default_SearchDownPathName;

  with frmSetting do
  begin
    chkIsSelectDownloadPath.Checked := IniFile.ReadBool( frmSetting.Name, chkIsSelectDownloadPath.Name, Default_IsSelectSearchDown );
    edtDownloadPath.Text := IniFile.ReadString( frmSetting.Name, edtDownloadPath.Name, DefaultDownloadPath );
  end;
end;

procedure TFormSettingLoadIni.SetFileTransferInfo;
begin
  with frmSetting do
  begin
    trbDownSpeed.Position := IniFile.ReadInteger( frmSetting.Name, trbDownSpeed.Name, Default_Speed );
    trbUpSpeed.Position := IniFile.ReadInteger( frmSetting.Name, trbUpSpeed.Name, Default_Speed );

    seUploadThread.Value := IniFile.ReadInteger( frmSetting.Name, seUploadThread.Name, Default_UpThreadCount );
    seDownloadThread.Value := IniFile.ReadInteger( frmSetting.Name, seDownloadThread.Name, Default_DownThreadCount );
  end;

end;

procedure TFormSettingLoadIni.SetFileVisibleInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    chkIsFileInvisible.Checked := IniFile.ReadBool( frmSetting.Name, chkIsFileInvisible.Name, Default_IvFileSearch );

    KeyStr := IniFile.ReadString( frmSetting.Name, edtIvPassword.Name, Default_IvPassword );
    KeyStr := MyEncrypt.DecodeStr( KeyStr );

    edtIvPassword.Text := KeyStr;
    edtivPassword2.Text := KeyStr;
  end;
end;

procedure TFormSettingLoadIni.SetNetworkInfo;
var
  DefaulePcID : string;
  DefaulePcName : string;
  DefaultIp : Integer;
  CbbItemIndex : Integer;
begin
    // 默认值
  DefaulePcID := MyComputerID.get;
  DefaulePcName := MyComputerName.get;
  DefaultIp := 0;

  with frmSetting do
  begin
    edtPcID.Text := DefaulePcID;
    edtPcName.Text := IniFile.ReadString( frmSetting.Name, EdtPcName.Name, DefaulePcName );
    CbbItemIndex := IniFile.ReadInteger( frmSetting.Name, CbbIp.Name, DefaultIp);
    edtPort.Text := IniFile.ReadString( frmSetting.Name, EdtPort.Name, IntToStr( Default_LanPort ) );

      // 出现越界的情况
    if CbbItemIndex >= cbbIp.Items.Count then
      CbbItemIndex := 0;

    cbbIp.ItemIndex := CbbItemIndex
  end;
end;



procedure TFormSettingLoadIni.SetShareInfo;
var
  DefaultSharePath : string;
begin
  DefaultSharePath := MyHardDisk.getBiggestHardDIsk + Default_CloudPathName;

  with frmSetting do
  begin
    chkIsShare.Checked := IniFile.ReadBool( frmSetting.Name, chkIsShare.Name, Default_IsShare );
    edtSharePath.Text := IniFile.ReadString( frmSetting.Name, edtSharePath.Name, DefaultSharePath );

    cbbMinSpaceType.ItemIndex := IniFile.ReadInteger( frmSetting.Name, cbbMinSpaceType.Name, Default_MinSpaceType );
    seMinSpaceValue.Value := IniFile.ReadInteger( frmSetting.Name, seMinSpaceValue.Name, Default_MinSpaceValue );

    cbbMaxSpaceType.ItemIndex := IniFile.ReadInteger( frmSetting.Name, cbbMaxSpaceType.Name, Default_MaxSpaceType );
    seMaxSpaceValue.Value := IniFile.ReadInteger( frmSetting.Name, seMaxSpaceValue.Name, Default_MaxSpaceValue );
  end;
end;

procedure TFormSettingLoadIni.SetStandardNetworkInfo;
var
  ItemCount, i : Integer;
  LvStandardData : TLvStandardData;
  SectionName, AccountName, EncryptedPassword, Password : string;
begin
  with frmSetting do
  begin
    ItemCount := IniFile.ReadInteger( frmSetting.Name, lvStandard.Name, 0 );

    for i := 0 to ItemCount - 1 do
    begin
      SectionName := lvStandard.Name + IntToStr(i);
      AccountName := IniFile.ReadString( SectionName, Ini_AccountName, '' );
      EncryptedPassword := IniFile.ReadString( SectionName, Ini_AccountPassword, '' );

        // Ini 文件 损坏
      if ( AccountName = '' ) or ( EncryptedPassword = '' ) then
        Continue;

      Password := MyEncrypt.DecodeStr( EncryptedPassword );

      LvStandardData := TLvStandardData.Create( AccountName, Password );
      with lvStandard.Items.Add do
      begin
        Caption := AccountName;
        ImageIndex := Icon_StandardNetwork;
        Data := LvStandardData;
      end;
    end;
  end;
end;

procedure TFormSettingLoadIni.SetSyncTimeInfo;
begin
  with frmSetting do
  begin
    ChkSyncTime.Checked := IniFile.ReadBool( frmSetting.Name, ChkSyncTime.Name, Default_IsSync );
    seSyncTime.Value := IniFile.ReadInteger( frmSetting.Name, seSyncTime.Name, Default_SyncTime );
    cbbSyncTime.ItemIndex := IniFile.ReadInteger( frmSetting.Name, ChkSyncTime.Name, Default_SyncTimeType );
  end;
end;

procedure TFormSettingLoadIni.SetTransferSafeInfo;
begin
  with frmSetting do
  begin
    chkMD5.Checked := IniFile.ReadBool( frmSetting.Name, chkMD5.Name, Default_CheckMD5 );
    chkShowRemote.Checked := IniFile.ReadBool( frmSetting.Name, chkShowRemote.Name, Default_CheckRemoteForbid );
  end;
end;

{ TFormSettingIniHandle }

constructor TFormSettingIniHandle.Create;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
end;

destructor TFormSettingIniHandle.Destroy;
begin
  IniFile.Free;
  inherited;
end;

{ TFormSettingSaveIni }

procedure TFormSettingSaveIni.SetAdvanceNetworkInfo;
var
  ItemCount, i : Integer;
  LvAdvanceData : TLvAdvanceData;
  SectionName : string;
begin
  with frmSetting do
  begin
    ItemCount := lvAdvance.Items.Count;
    IniFile.WriteInteger( frmSetting.Name, lvAdvance.Name, ItemCount );

    for i := 0 to lvAdvance.Items.Count - 1 do
    begin
      SectionName := lvAdvance.Name + IntToStr(i);
      LvAdvanceData := lvAdvance.Items[i].Data;

      IniFile.WriteString( SectionName, Ini_Domain, LvAdvanceData.Domain );
      IniFile.WriteString( SectionName, Ini_Port, LvAdvanceData.Port );
    end;
  end;
end;


procedure TFormSettingSaveIni.SetApplicetionInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkRunAppStartup.Name, chkRunAppStartup.Checked );
    IniFile.WriteBool( frmSetting.Name, chkShowAppExistDialog.Name, chkShowAppExistDialog.Checked );
    IniFile.WriteInteger( frmSetting.Name, cbbLanguage.Name, cbbLanguage.ItemIndex );
  end;
end;

procedure TFormSettingSaveIni.SetBackupFileSafeInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteInteger( frmSetting.Name, seCopyCount.Name, seCopyCount.Value );

    IniFile.WriteInteger( frmSetting.Name, seCloudLostValue.Name, seCloudLostValue.Value );
    IniFile.WriteInteger( frmSetting.Name, cbbCloudLostTye.Name, cbbCloudLostTye.ItemIndex );
  end;
end;

procedure TFormSettingSaveIni.SetCloudSafeInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkIsCloudID.Name, chkIsCloudID.Checked );

      // 加密
    KeyStr := edtCloudIDNum.Text;
    KeyStr := MyEncrypt.EncodeStr( KeyStr );
    IniFile.WriteString( frmSetting.Name, edtCloudIDNum.Name, KeyStr );
  end;
end;

procedure TFormSettingSaveIni.SetEncodeFileInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    IniFile.WriteString( frmSetting.Name, edtEncPasswordHint.Name, edtEncPasswordHint.Text );
    IniFile.WriteBool( frmSetting.Name, chkIsEncrypt.Name, chkIsEncrypt.Checked );

    KeyStr := edtEncPassword.Text;
    KeyStr := MyEncrypt.EncodeStr( KeyStr );
    IniFile.WriteString( frmSetting.Name, edtEncPassword.Name, KeyStr );
  end;
end;

procedure TFormSettingSaveIni.SetFileReceiveInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteString( frmSetting.Name, edtRecevicePath.Name, edtRecevicePath.Text );
    IniFile.WriteBool( frmSetting.Name, chkRevFileShowHint.Name, chkRevFileShowHint.Checked );

    IniFile.WriteBool( frmSetting.Name, rbAutoReceive.Name, rbAutoReceive.Checked );
    IniFile.WriteBool( frmSetting.Name, rbManualReceive.Name, rbManualReceive.Checked );
    IniFile.WriteBool( frmSetting.Name, rbNerverReceive.Name, rbNerverReceive.Checked );
  end;
end;

procedure TFormSettingSaveIni.SetFileSearchDownInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkIsSelectDownloadPath.Name, chkIsSelectDownloadPath.Checked );
    IniFile.WriteString( frmSetting.Name, edtDownloadPath.Name, edtDownloadPath.Text );
  end;
end;

procedure TFormSettingSaveIni.SetFileTransferInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteInteger( frmSetting.Name, trbDownSpeed.Name, trbDownSpeed.Position );
    IniFile.WriteInteger( frmSetting.Name, trbUpSpeed.Name, trbUpSpeed.Position );

    IniFile.WriteInteger( frmSetting.Name, seUploadThread.Name, seUploadThread.Value );
    IniFile.WriteInteger( frmSetting.Name, seDownloadThread.Name, seDownloadThread.value );
  end;
end;

procedure TFormSettingSaveIni.SetFileVisibleInfo;
var
  KeyStr : string;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkIsFileInvisible.Name, chkIsFileInvisible.Checked );

      // 加密
    KeyStr := edtIvPassword.Text;
    KeyStr := MyEncrypt.EncodeStr( KeyStr );
    IniFile.WriteString( frmSetting.Name, edtIvPassword.Name, KeyStr );
  end;
end;

procedure TFormSettingSaveIni.SetNetworkInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteString( frmSetting.Name, EdtPcName.Name, EdtPcName.Text );
    IniFile.WriteInteger( frmSetting.Name, CbbIp.Name, CbbIp.ItemIndex );
    IniFile.WriteString( frmSetting.Name, EdtPort.Name, EdtPort.Text );
  end;
end;

procedure TFormSettingSaveIni.SetShareInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkIsShare.Name, chkIsShare.Checked );
    IniFile.WriteString( frmSetting.Name, edtSharePath.Name, edtSharePath.Text );

    IniFile.WriteInteger( frmSetting.Name, cbbMinSpaceType.Name, cbbMinSpaceType.ItemIndex );
    IniFile.WriteInteger( frmSetting.Name, seMinSpaceValue.Name, seMinSpaceValue.Value );

    IniFile.WriteInteger( frmSetting.Name, cbbMaxSpaceType.Name, cbbMaxSpaceType.ItemIndex );
    IniFile.WriteInteger( frmSetting.Name, seMaxSpaceValue.Name, seMaxSpaceValue.Value );
  end;
end;

procedure TFormSettingSaveIni.SetStandardNetworkInfo;
var
  ItemCount, i : Integer;
  LvStandardData : TLvStandardData;
  SectionName, EncryptedPassword : string;
begin
  with frmSetting do
  begin
    ItemCount := lvStandard.Items.Count;
    IniFile.WriteInteger( frmSetting.Name, lvStandard.Name, ItemCount );

    for i := 0 to lvStandard.Items.Count - 1 do
    begin
      SectionName := lvStandard.Name + IntToStr(i);
      LvStandardData := lvStandard.Items[i].Data;
      EncryptedPassword := MyEncrypt.EncodeStr( LvStandardData.Password );

      IniFile.WriteString( SectionName, Ini_AccountName, LvStandardData.AccountName );
      IniFile.WriteString( SectionName, Ini_AccountPassword, EncryptedPassword );
    end;
  end;
end;


procedure TFormSettingSaveIni.SetSyncTimeInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, ChkSyncTime.Name, ChkSyncTime.Checked );
    IniFile.WriteInteger( frmSetting.Name, seSyncTime.Name, seSyncTime.Value );
    IniFile.WriteInteger( frmSetting.Name, cbbSyncTime.Name, cbbSyncTime.ItemIndex );
  end;
end;

procedure TFormSettingSaveIni.SetTransferSafeInfo;
begin
  with frmSetting do
  begin
    IniFile.WriteBool( frmSetting.Name, chkMD5.Name, chkMD5.Checked );
    IniFile.WriteBool( frmSetting.Name, chkShowRemote.Name, chkShowRemote.Checked );
  end;
end;

{ TSetApplyHandle }

procedure TSetApplyHandleBase.SetAdvanceNetworkInfo;
var
  ApplyAdvanceNetwork : TApplyAdvanceNetwork;
begin
  ApplyAdvanceNetwork := TApplyAdvanceNetwork.Create;
  ApplyAdvanceNetwork.Update;
  if ApplyAdvanceNetwork.getIsChangeNetwork then
    IsRestartNetwork := True;
  ApplyAdvanceNetwork.Free;
end;

procedure TSetApplyHandleBase.SetApplicetionInfo;
var
  IsChangeStartup : Boolean;
begin
  with frmSetting do
  begin
    with ApplicationSettingInfo do
    begin
        // 是否发生变化
      IsChangeStartup := IsRunAppStartUp <> chkRunAppStartup.Checked;
      IsRunAppStartUp := chkRunAppStartup.Checked;
      IsShowDialogBeforeExist := chkShowAppExistDialog.Checked;
    end;
  end;

    // 改变 开机启动 设置
  if IsChangeStartup and not IsFirstApply then
    RunAppStartupUtil.Startup( ApplicationSettingInfo.IsRunAppStartUp );

  if frmSetting.cbbLanguage.ItemIndex < 0 then
    frmSetting.cbbLanguage.ItemIndex := 0;
  frmMainForm.siLangDispatcherMain.ActiveLanguage := ( frmSetting.cbbLanguage.ItemIndex + 1 );
end;

procedure TSetApplyHandleBase.SetBackupFileSafeInfo;
var
  IsCheckLostConn : Boolean;
begin
  with frmSetting do
  begin
    with BackupFileSafeSettingInfo do
    begin
      CopyCount := seCopyCount.Value;
    end;

    with CloudFileSafeSettingInfo do
    begin
      IsCheckLostConn := ( CloudSafeValue <> seCloudLostValue.Value ) or
                         ( CloudSafeType <> cbbCloudLostTye.ItemIndex );

      CloudSafeValue := seCloudLostValue.Value;
      CloudSafeType := cbbCloudLostTye.ItemIndex;
    end;
  end;

    // 立刻 检测 过期 Pc
  if not IsFirstApply then
    MyBackupFileLostConnInfo.LostConnScanNow;
end;

procedure TSetApplyHandleBase.SetCloudSafeInfo;
begin
  with frmSetting do
  begin
    with CloudSafeSettingInfo do
    begin
      if ( IsCloudSafe <> chkIsCloudID.Checked ) or
         ( CloudIDNum <> edtCloudIDNum.Text )
      then
        IsRestartNetwork := True;

      IsCloudSafe := chkIsCloudID.Checked;
      CloudIDNum := edtCloudIDNum.Text;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetEncodeFileInfo;
begin
  with frmSetting do
  begin
    with BackupFileEncryptSettingInfo do
    begin
      IsEncrypt := chkIsEncrypt.Checked;
      Password := edtEncPassword.Text;
      PasswordHint := edtEncPasswordHint.Text;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetFileReceiveInfo;
begin
  with frmSetting do
  begin
    with FileReceiveSettingInfo do
    begin
      ReceivePath := edtRecevicePath.Text;
      IsRevFileShowHint := chkRevFileShowHint.Checked;

      IsAutoReceive := rbAutoReceive.Checked;
      IsManualReceive := rbManualReceive.Checked;
      IsNerverReceive := rbNerverReceive.Checked;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetFileSearchDownInfo;
begin
  with frmSetting do
  begin
    with FileSearchDownSettingInfo do
    begin
      IsSelectDownloadPath := chkIsSelectDownloadPath.Checked;
      DownloadPath := edtDownloadPath.Text;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetFileTransferInfo;
begin
  with frmSetting do
  begin
    with TransferSettingInfo do
    begin
      UpThreadCount := seUploadThread.Value;
      UploadSpeed := trbUpSpeed.Position;
      DownThreadCount := seDownloadThread.Value;
      DownloadSpeed := trbDownSpeed.Position;
    end;
  end;

    // 重设 上传 线程数
  MyFileUpload.ResetRunThreadCount( TransferSettingInfo.UpThreadCount );

    // 重设 下载 线程
  MyFileDownload.ResetRunThreadCount( TransferSettingInfo.DownThreadCount );
end;

procedure TSetApplyHandleBase.SetFileVisibleInfo;
begin
  with frmSetting do
  begin
    with FileVisibleSettingInfo do
    begin
      IsFileInvisible := chkIsFileInvisible.Checked;
      RestorePassword := edtivPassword2.Text;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetNetworkInfo;
begin
  with frmSetting do
  begin
    with PcSettingInfo do
    begin
      if ( PcName <> edtPcName.Text ) or ( LanIp <> cbbIP.Text ) or
         ( LanPort <> edtPort.Text )
      then
        IsRestartNetwork := True;

      PcID := edtPcID.Text;
      PcName := edtPcName.Text;
      LanIp := cbbIP.Text;
      LanPort := edtPort.Text;
    end;
  end;

  PcInfo.PcID := PcSettingInfo.PcID;
  PcInfo.PcName := PcSettingInfo.PcName;
  PcInfo.LanIp := PcSettingInfo.LanIp;
  PcInfo.LanPort := PcSettingInfo.LanPort;

  RestoreFile_LocalPcName := PcSettingInfo.PcName;
end;

procedure TSetApplyHandleBase.SetShareInfo;
var
  IsChangeSharePath : Boolean;
  OldSharePath : string;
begin
  with frmSetting do
  begin
    with ShareSettingInfo do
    begin
        // 云路径 发生变化
      if IsShare and ( edtSharePath.Text <> SharePath ) then
      begin
        OldSharePath := SharePath;
        IsChangeSharePath := True;
      end
      else
        IsChangeSharePath := False;

      IsShare := chkIsShare.Checked;
      SharePath := edtSharePath.Text;

      MaxSpaceType := cbbMaxSpaceType.ItemIndex;
      MaxSpaceValue := seMaxSpaceValue.Value;

      MinSpaceType := cbbMinSpaceType.ItemIndex;
      MinSpaceValue := seMinSpaceValue.Value;
    end;
  end;

    // 云路径变化处理
  if IsChangeSharePath then
  begin
    MyCloudFileControl.AddSharePath( ShareSettingInfo.SharePath );
    MyCloudFileControl.RemoveSharePath( OldSharePath );
  end;
end;

procedure TSetApplyHandleBase.SetStandardNetworkInfo;
var
  CheckApplyLocalNetwork : TCheckApplyLocalNetwork;
  ApplyStandardNetwork : TApplyStandardNetwork;
begin
    // 是否 进入局域网
  CheckApplyLocalNetwork := TCheckApplyLocalNetwork.Create;
  if CheckApplyLocalNetwork.get then
    IsRestartNetwork := True;
  CheckApplyLocalNetwork.Free;

  ApplyStandardNetwork := TApplyStandardNetwork.Create;
  ApplyStandardNetwork.Update;
  if ApplyStandardNetwork.getIsChangeNetwork then
    IsRestartNetwork := True;
  ApplyStandardNetwork.Free;
end;

procedure TSetApplyHandleBase.SetSyncTimeInfo;
begin
  with frmSetting do
  begin
    with SyncTimeSettingInfo do
    begin
      IsAutoSync := ChkSyncTime.Checked;
      SyncTime := seSyncTime.Value;
      TimeType := cbbSyncTime.ItemIndex;
    end;
  end;
end;

procedure TSetApplyHandleBase.SetTransferSafeInfo;
begin
  with frmSetting do
  begin
    with TransferSafeSettingInfo do
    begin
      IsMD5Check := chkMD5.Checked;
      IsRemoveForbid := chkShowRemote.Checked;
    end;
  end;
end;

{ TSetApplyHandle }

constructor TSetApplyHandle.Create;
begin
  inherited Create;
  IsFirstApply := False;
end;

procedure TSetApplyHandle.Update;
begin
  IsRestartNetwork := False;

  inherited;

  if IsRestartNetwork then
    MasterThread.RestartNetwork;
end;

{ TSettingHandle }

procedure TSettingHandle.Update;
begin
  SetNetworkInfo;

  SetStandardNetworkInfo;
  SetAdvanceNetworkInfo;

  SetFileTransferInfo;
  SetTransferSafeInfo;

  SetBackupFileSafeInfo;
  SetSyncTimeInfo;
  SetEncodeFileInfo;

  SetShareInfo;
  SetCloudSafeInfo;

  SetFileVisibleInfo;

  SetApplicetionInfo;

  SetFileReceiveInfo;

  SetFileSearchDownInfo;
end;

{ TSetCancelHandle }

procedure TSetCancelHandle.SetAdvanceNetworkInfo;
var
  CancelAdvanceNetwork : TCancelAdvanceNetwork;
begin
  CancelAdvanceNetwork := TCancelAdvanceNetwork.Create;
  CancelAdvanceNetwork.Update;
  CancelAdvanceNetwork.Free;
end;

procedure TSetCancelHandle.SetApplicetionInfo;
begin
  with frmSetting do
  begin
    with ApplicationSettingInfo do
    begin
      chkRunAppStartup.Checked := IsRunAppStartUp;
      chkShowAppExistDialog.Checked := IsShowDialogBeforeExist;
    end;
  end;
end;

procedure TSetCancelHandle.SetBackupFileSafeInfo;
begin
  with frmSetting do
  begin
    with BackupFileSafeSettingInfo do
    begin
      seCopyCount.Value := CopyCount;
    end;
    with CloudFileSafeSettingInfo do
    begin
      cbbCloudLostTye.ItemIndex := CloudSafeType;
      seCloudLostValue.Value := CloudSafeValue;
    end;
  end;
end;

procedure TSetCancelHandle.SetCloudSafeInfo;
begin
  with frmSetting do
  begin
    with CloudSafeSettingInfo do
    begin
      chkIsCloudID.Checked := IsCloudSafe;
      edtCloudIDNum.Text := CloudIDNum;
    end;
  end;
end;


procedure TSetCancelHandle.SetEncodeFileInfo;
begin
  with frmSetting do
  begin
    with BackupFileEncryptSettingInfo do
    begin
      chkIsEncrypt.Checked := IsEncrypt;
      edtEncPassword.Text := Password;
      edtEncPassword2.Text := Password;
      edtEncPasswordHint.Text := PasswordHint;
    end;
  end;
end;

procedure TSetCancelHandle.SetFileReceiveInfo;
begin
  with frmSetting do
  begin
    with FileReceiveSettingInfo do
    begin
      edtRecevicePath.Text := ReceivePath;
      chkRevFileShowHint.Checked := IsRevFileShowHint;

      rbAutoReceive.Checked := IsAutoReceive;
      rbManualReceive.Checked := IsManualReceive;
      rbNerverReceive.Checked := IsNerverReceive;
    end;
  end;
end;

procedure TSetCancelHandle.SetFileSearchDownInfo;
begin
  with frmSetting do
  begin
    with FileSearchDownSettingInfo do
    begin
      chkIsSelectDownloadPath.Checked := IsSelectDownloadPath;
      edtDownloadPath.Text := DownloadPath;
    end;
  end;
end;

procedure TSetCancelHandle.SetFileTransferInfo;
begin
  with frmSetting do
  begin
    with TransferSettingInfo do
    begin
      seUploadThread.Value := UpThreadCount;
      trbUpSpeed.Position := UploadSpeed;
      seDownloadThread.Value := DownThreadCount;
      trbDownSpeed.Position := DownloadSpeed;
    end;
  end;
end;

procedure TSetCancelHandle.SetFileVisibleInfo;
begin
  with frmSetting do
  begin
    with FileVisibleSettingInfo do
    begin
      chkIsFileInvisible.Checked := IsFileInvisible;
      edtivPassword2.Text := RestorePassword;
    end;
  end;
end;


procedure TSetCancelHandle.SetNetworkInfo;
begin
  with frmSetting do
  begin
    with PcSettingInfo do
    begin
      edtPcName.Text := PcName;
      cbbIP.Text := LanIp;
      edtPort.Text := LanPort;
    end;
  end;
end;

procedure TSetCancelHandle.SetShareInfo;
begin
  with frmSetting do
  begin
    with ShareSettingInfo do
    begin
      chkIsShare.Checked := IsShare;
      edtSharePath.Text := SharePath;

      cbbMaxSpaceType.ItemIndex := MaxSpaceType;
      seMaxSpaceValue.Value := MaxSpaceValue;

      cbbMinSpaceType.ItemIndex := MinSpaceType;
      seMinSpaceValue.Value := MinSpaceValue;
    end;
  end;
end;

procedure TSetCancelHandle.SetStandardNetworkInfo;
var
  CancelStandardNetwork : TCancelStandardNetwork;
begin
  CancelStandardNetwork := TCancelStandardNetwork.Create;
  CancelStandardNetwork.Update;
  CancelStandardNetwork.Free;
end;

procedure TSetCancelHandle.SetSyncTimeInfo;
begin
  with frmSetting do
  begin
    with SyncTimeSettingInfo do
    begin
      ChkSyncTime.Checked := IsAutoSync;
      seSyncTime.Value:= SyncTime;
      cbbSyncTime.ItemIndex := TimeType;
    end;
  end;
end;

procedure TSetCancelHandle.SetTransferSafeInfo;
begin
  with frmSetting do
  begin
    with TransferSafeSettingInfo do
    begin
      chkMD5.Checked := IsMD5Check;
      chkShowRemote.Checked := IsRemoveForbid;
    end;
  end;
end;


{ TCheckApplyClick }

function TCheckApplyClick.CheckCloudID: Boolean;
begin
    // 没有 ID Num
  if not frmSetting.chkIsCloudID.Checked then
  begin
    Result := True;
    Exit;
  end;

    // 没有 输入 ID Num
  if frmSetting.edtCloudIDNum.Text = '' then
  begin
    Result := False;
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText('InputSecureID');
    ErrorHandle := frmSetting.edtCloudIDNum.Handle;
  end
  else
    Result := True;

      // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsCloud;
    frmSetting.edtCloudIDNum.SetFocus;
  end;
end;

function TCheckApplyClick.CheckComputer: Boolean;
var
  edtComputerName, edtPort, edtError : TEdit;
  Port : Integer;
begin
  edtComputerName := frmSetting.edtPcName;
  edtPort := frmSetting.edtPort;

  Port := StrToIntDef( edtPort.Text, -1 );

  Result := False;
  if edtComputerName.Text = '' then
  begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'InputPcName' );
    edtError := edtComputerName;
  end
  else
  if ( Port < 1 ) or ( Port > 65535 ) then
  begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'PortError' );
    edtError := edtPort;
  end
  else
    Result := True;

    // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsLocalNetwork;
    edtError.SetFocus;
    ErrorHandle := edtError.Handle;
  end;
end;

function TCheckApplyClick.CheckEncFile: Boolean;
var
  edtEncPassword, edtEncPassword2, edtError : TEdit;
begin
    // 没有 加密
  if not frmSetting.chkIsEncrypt.Checked then
  begin
    Result := True;
    Exit;
  end;

  edtEncPassword := frmSetting.edtEncPassword;
  edtEncPassword2 := frmSetting.edtEncPassword2;

    // 没有 输入密码
  Result := False;
  if edtEncPassword.Text = '' then
  begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'InputPassword' );
    edtError := edtEncPassword;
  end
  else   // 密码 与 密码确认 不匹配
  if edtEncPassword.Text <> edtEncPassword2.Text then
   begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'PasswordNotMatch' );
    edtError := edtEncPassword2;
  end
  else
    Result := True;

    // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsBackup;
    edtError.SetFocus;
    ErrorHandle := edtError.Handle;
  end;
end;

function TCheckApplyClick.CheckFileInvisible: Boolean;
var
  edtIvPassword, edtIvPassword2, edtError : TEdit;
begin
      // 没有 File Invisible
  if not frmSetting.chkIsFileInvisible.Checked then
  begin
    Result := True;
    Exit;
  end;

  edtIvPassword := frmSetting.edtIvPassword;
  edtIvPassword2 := frmSetting.edtIvPassword2;

    // 没有 输入密码
  Result := False;
  if edtIvPassword.Text = '' then
  begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'InputRestorePassword' );
    edtError := edtIvPassword;
  end
  else   // 密码 与 密码确认 不匹配
  if edtIvPassword.Text <> edtIvPassword2.Text then
  begin
    ShowErrorStr := frmSetting.siLang_frmSetting.GetText( 'RestorePasswordNotMatch' );
    edtError := edtIvPassword2;
  end
  else
    Result := True;


      // 智能改错
  if not Result then
  begin
    frmSetting.pcMain.ActivePage := frmSetting.tsPrivacy;
    edtError.SetFocus;
    ErrorHandle := edtError.Handle;
  end;
end;

function TCheckApplyClick.get: Boolean;
begin
  if CheckComputer and CheckEncFile and CheckCloudID and
     CheckFileInvisible
  then
    Result := True
  else
  begin
    Result := False;
    MyMessageHint.ShowError( ErrorHandle, ShowErrorStr );
  end;
end;


{ TLvAccountData }

constructor TLvStandardData.Create(_AccountName, _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
  IsSelected := False;
end;

{ TLvAdvanceData }

constructor TLvAdvanceData.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
  IsSelected := False;
end;

{ TApplyStandardNetwork }

procedure TApplyStandardNetwork.AddNewItem;
var
  RemoveAccountList : TRemoteAccountList;
  lvStandard : TListView;
  i: Integer;
  LvStandardData : TLvStandardData;
  AccountName, Password : string;
  RemoveAccountInfo : TRemoteAccountInfo;
begin
  lvStandard := frmSetting.lvStandard;
  RemoveAccountList := StandardNetworkSettingInfo.RemoteAccountList;

    // 遍历新的
  for i := 0 to lvStandard.Items.Count - 1 do
  begin
    LvStandardData := lvStandard.Items[i].Data;
    AccountName := LvStandardData.AccountName;
    Password := LvStandardData.Password;

      // 旧的 是否存在 新的
    RemoveAccountInfo := StandardNetworkSettingInfo.getAccount( AccountName );
    if RemoveAccountInfo <> nil then  // 存在则跳过
      Continue;

      // 添加新的
    RemoveAccountInfo := TRemoteAccountInfo.Create( AccountName, Password );
    RemoveAccountList.Add( RemoveAccountInfo );

    AddPmItem( AccountName );
  end;
end;

procedure TApplyStandardNetwork.AddPmItem(AccountName: string);
var
  pmNetwork : TPopupMenu;
  mi : TMenuItem;
begin
  pmNetwork := frmMainForm.pmTbRmNw;

  mi := TMenuItem.Create(nil);
  mi.Caption := AccountName;
  mi.ImageIndex := -1;
  mi.OnClick := frmSetting.pmStandardNetworkClick;
  pmNetwork.Items.Insert( SplitIndex, mi );

  Inc( SplitIndex );
end;

procedure TApplyStandardNetwork.FindSplitIndex;
var
  pmNetwork : TPopupMenu;
  i : Integer;
begin
  pmNetwork := frmMainForm.pmTbRmNw;

  SplitIndex := 0;
  for i := 0 to pmNetwork.Items.Count - 1 do
  begin
    if pmNetwork.Items[i].Caption = '-' then
    begin
      SplitIndex := i;
      Break;
    end;
  end;
end;

function TApplyStandardNetwork.getIsChangeNetwork: Boolean;
begin
  Result := IsChangeNetwork;
end;

procedure TApplyStandardNetwork.RemoveOldItem;
var
  RemoteAccountList : TRemoteAccountList;
  i : Integer;
  AccountName, Password : string;
  LvStandardData : TLvStandardData;
begin
  RemoteAccountList := StandardNetworkSettingInfo.RemoteAccountList;

    // 遍历 旧数据
  for i := RemoteAccountList.Count - 1 downto 0 do
  begin
    AccountName := RemoteAccountList[i].AccountName;
    Password := RemoteAccountList[i].Password;

      // 新数据 是否存在 旧数据
    LvStandardData := LvRemoteNetworkUtil.getLvStandardData( AccountName );
    if LvStandardData <> nil then  // 存在 则 跳过
    begin
      if RemoteAccountList[i].IsSelected and ( Password <> LvStandardData.Password ) then
        IsChangeSelectPassword := True;
      RemoteAccountList[i].Password := LvStandardData.Password;
      Continue;
    end;

      // 不存在 则 删除
    RemoteAccountList.Delete(i);
    RemovePmItem( AccountName );
  end;
end;

procedure TApplyStandardNetwork.RemovePmItem(AccountName: string);
var
  pmNetwork : TPopupMenu;
  i : Integer;
begin
  pmNetwork := frmMainForm.pmTbRmNw;
  for i := 0 to pmNetwork.Items.Count - 1 do
    if pmNetwork.Items[i].Caption = AccountName then
    begin
      pmNetwork.Items.Delete(i);
      Break;
    end;
end;

procedure TApplyStandardNetwork.SelectedItem;
var
  ItemData : TLvStandardData;
  RemoteAccountInfo : TRemoteAccountInfo;
begin
  IsChangeNetwork := False;

    // 网络模式 改变
  ItemData := LvRemoteNetworkUtil.getLvStandardSelectedData;
  if ItemData <> nil then
  begin
    RemoteAccountInfo := StandardNetworkSettingInfo.getSelected;
    if ( RemoteAccountInfo = nil ) or
       ( RemoteAccountInfo.AccountName <> ItemData.AccountName )
    then
    begin
      frmMainForm.PmRemoteNetworkSelect( ItemData.AccountName );
      RemoteNetworkSettingUtil.SetStandardSelected( ItemData.AccountName );
      NetworkModeChangeUtil.EnterStandard( ItemData.AccountName, ItemData.Password );
      NetworkModeChangeUtil.SaveEnterStandard( ItemData.AccountName );
      IsChangeNetwork:= True;
    end
    else
    if ( RemoteAccountInfo <> nil ) and
       ( RemoteAccountInfo.AccountName = ItemData.AccountName ) and
        IsChangeSelectPassword
    then
    begin
      NetworkModeChangeUtil.EnterStandard( ItemData.AccountName, ItemData.Password );
      IsChangeNetwork := True;
    end;
  end;
end;

procedure TApplyStandardNetwork.Update;
begin
  IsChangeSelectPassword := False;

  RemoveOldItem;

  FindSplitIndex;

  AddNewItem;

  SelectedItem;
end;

{ TCancelStandardNetwork }

procedure TCancelStandardNetwork.AddOldItem;
var
  RemoteAccountList : TRemoteAccountList;
  lvStandard : TListView;
  i, j : Integer;
  AccountName, Password : string;
  IsExistItem : Boolean;
  LvStandardData : TLvStandardData;
begin
  lvStandard := frmSetting.lvStandard;
  RemoteAccountList := StandardNetworkSettingInfo.RemoteAccountList;

    // 遍历 旧数据
  for i := 0 to RemoteAccountList.Count - 1 do
  begin
    AccountName := RemoteAccountList[i].AccountName;
    Password := RemoteAccountList[i].Password;

      // 新数据 是否存在 旧数据
    LvStandardData := LvRemoteNetworkUtil.getLvStandardData( AccountName );
    if LvStandardData <> nil then
      Continue;

      // 不存在 则 添加
    LvStandardData := TLvStandardData.Create( AccountName, Password );
    with lvStandard.Items.Insert( i ) do
    begin
      Caption := AccountName;
      ImageIndex := Icon_StandardNetwork;
      Data := LvStandardData;
    end;
  end;
end;

procedure TCancelStandardNetwork.RemoveNewItem;
var
  lvStandard : TListView;
  i : Integer;
  LvStandardData : TLvStandardData;
  AccountName, Password : string;
  RemoteAccountInfo : TRemoteAccountInfo;
begin
  lvStandard := frmSetting.lvStandard;

    // 遍历新的
  for i := lvStandard.Items.Count - 1 downto 0 do
  begin
    LvStandardData := lvStandard.Items[i].Data;
    AccountName := LvStandardData.AccountName;
    Password := LvStandardData.Password;

      // 旧的是否存在新的
    RemoteAccountInfo := StandardNetworkSettingInfo.getAccount( AccountName );
    if RemoteAccountInfo <> nil then // 存在则跳过
    begin
      LvStandardData.Password := RemoteAccountInfo.Password;
      Continue;
    end;

      // 删除新的
    lvStandard.Items.Delete(i);
  end;
end;

procedure TCancelStandardNetwork.SelectedItem;
var
  RemoteAccountInfo : TRemoteAccountInfo;
  ItemData : TLvStandardData;
begin
  RemoteAccountInfo := StandardNetworkSettingInfo.getSelected;
  if RemoteAccountInfo = nil then
    Exit;
  ItemData := LvRemoteNetworkUtil.getLvStandardSelectedData;
  if ( ItemData = nil ) or ( ItemData.AccountName <> RemoteAccountInfo.AccountName ) then
    LvRemoteNetworkUtil.SetStandardSelected( RemoteAccountInfo.AccountName );
end;

procedure TCancelStandardNetwork.Update;
begin
  RemoveNewItem;

  AddOldItem;

  SelectedItem;
end;

{ TApplyAdvanceNetwork }

procedure TApplyAdvanceNetwork.AddNewItem;
var
  RemoteInternetList : TRemoteInternetList;
  lvAdvance : TListView;
  i, j : Integer;
  LvAdvanceData : TLvAdvanceData;
  Domain, Port : string;
  IsExitItem : Boolean;
  RemoteInternetInfo : TRemoteInternetInfo;
begin
  lvAdvance := frmSetting.lvAdvance;
  RemoteInternetList := AdvanceNetworkSettingInfo.RemoteInternetList;

    // 遍历新的
  for i := 0 to lvAdvance.Items.Count - 1 do
  begin
    LvAdvanceData := lvAdvance.Items[i].Data;
    Domain := LvAdvanceData.Domain;
    Port := LvAdvanceData.Port;

      // 旧的是否存在新的
    RemoteInternetInfo := AdvanceNetworkSettingInfo.getInternet( Domain, Port );
    if RemoteInternetInfo <> nil then // 存在则跳过
      Continue;

      // 添加新的
    RemoteInternetInfo := TRemoteInternetInfo.Create( Domain, Port );
    RemoteInternetList.Add( RemoteInternetInfo );

    AddPmItem( Domain, Port );
  end;
end;

procedure TApplyAdvanceNetwork.AddPmItem(Domain, Port: string);
var
  ShowStr : string;
  pmNetwork : TPopupMenu;
  mi : TMenuItem;
begin
  ShowStr := LvRemoteNetworkUtil.getAdvanceShowStr( Domain, Port );

  pmNetwork := frmMainForm.pmTbRmNw;

  mi := TMenuItem.Create(frmMainForm);
  mi.Caption := ShowStr;
  mi.ImageIndex := -1;
  mi.OnClick := frmSetting.pmAdvanceNetworkClick;
  pmNetwork.Items.Insert( SplitModeIndex, mi );
end;

procedure TApplyAdvanceNetwork.FindSplitIndex;
var
  pmNetwork : TPopupMenu;
  IsSplitOne : Boolean;
  i : Integer;
begin
  pmNetwork := frmMainForm.pmTbRmNw;

  SplitIndex := 0;
  SplitModeIndex := 0;
  IsSplitOne := True;
  for i := 0 to pmNetwork.Items.Count - 1 do
  begin
    if pmNetwork.Items[i].Caption = '-' then
    begin
      if IsSplitOne then
      begin
        SplitIndex := i;
        IsSplitOne := False;
      end
      else
      begin
        SplitModeIndex := i;
        Break;
      end;
    end;
  end;
end;

function TApplyAdvanceNetwork.getIsChangeNetwork: Boolean;
begin
  Result := IsChangeNetwork;
end;

procedure TApplyAdvanceNetwork.RemoveOldItem;
var
  RemoteInternetList : TRemoteInternetList;
  lvAdvance : TListView;
  i, j : Integer;
  Domain, Port : string;
  IsExistItem : Boolean;
  LvAdvanceData : TLvAdvanceData;
begin
  lvAdvance := frmSetting.lvAdvance;
  RemoteInternetList := AdvanceNetworkSettingInfo.RemoteInternetList;

    // 遍历 旧数据
  for i := RemoteInternetList.Count - 1 downto 0 do
  begin
    Domain := RemoteInternetList[i].Domain;
    Port := RemoteInternetList[i].Port;

      // 新数据 是否存在 旧数据
    LvAdvanceData := LvRemoteNetworkUtil.getLvAdvanceData( Domain, Port );
    if LvAdvanceData <> nil then  // 存在 则 跳过
      Continue;

      // 不存在 则 删除
    RemoteInternetList.Delete(i);
    RemovePmItem( Domain, Port );
  end;
end;

procedure TApplyAdvanceNetwork.RemovePmItem(Domain, Port: string);
var
  pmNetwork : TPopupMenu;
  i : Integer;
  ShowStr : string;
  mi : TMenuItem;
begin
  ShowStr := LvRemoteNetworkUtil.getAdvanceShowStr( Domain, Port );

  pmNetwork := frmMainForm.pmTbRmNw;
  for i := SplitIndex to pmNetwork.Items.Count - 1 do
    if pmNetwork.Items[i].Caption = ShowStr then
    begin
      mi := pmNetwork.Items[i];
      pmNetwork.Items.Delete(i);
      mi.Free;
      Break;
    end;
end;

procedure TApplyAdvanceNetwork.SelectedItem;
var
  ItemData : TLvAdvanceData;
  RemoteInternetInfo : TRemoteInternetInfo;
  SelectStr : string;
begin
  IsChangeNetwork := False;

  ItemData := LvRemoteNetworkUtil.getLvAdvanceSelectedData;
  if ItemData = nil then
    Exit;

  RemoteInternetInfo := AdvanceNetworkSettingInfo.getSelected;
  if ( RemoteInternetInfo = nil ) or
     ( RemoteInternetInfo.Domain <> ItemData.Domain ) or
     ( RemoteInternetInfo.Port <> ItemData.Port )
  then
  begin
    SelectStr := LvRemoteNetworkUtil.getAdvanceShowStr( ItemData.Domain, ItemData.Port );

    frmMainForm.PmRemoteNetworkSelect( SelectStr );
    RemoteNetworkSettingUtil.SetAdvanceSelected( ItemData.Domain, ItemData.Port );
    NetworkModeChangeUtil.EnterAdvance( ItemData.Domain, ItemData.Port );
    NetworkModeChangeUtil.SaveEnterAdvance( ItemData.Domain, ItemData.Port );
    IsChangeNetwork := True;
  end;
end;

procedure TApplyAdvanceNetwork.Update;
begin
  FindSplitIndex;

  RemoveOldItem;

  AddNewItem;

  SelectedItem;
end;

{ TCancelAdvanceNetwork }

procedure TCancelAdvanceNetwork.AddOldItem;
var
  RemoteInternetList : TRemoteInternetList;
  lvAdvance : TListView;
  i, j : Integer;
  Domain, Port, Ip : string;
  IsExistItem : Boolean;
  LvAdvanceData : TLvAdvanceData;
begin
  lvAdvance := frmSetting.lvAdvance;
  RemoteInternetList := AdvanceNetworkSettingInfo.RemoteInternetList;

    // 遍历 旧数据
  for i := 0 to RemoteInternetList.Count - 1 do
  begin
    Domain := RemoteInternetList[i].Domain;
    Port := RemoteInternetList[i].Port;

      // 新数据 是否存在 旧数据
    LvAdvanceData := LvRemoteNetworkUtil.getLvAdvanceData( Domain, Port );
    if LvAdvanceData <> nil then // 存在则跳过
      Continue;

      // 不存在 则 添加
    LvAdvanceData := TLvAdvanceData.Create( Domain, Port );
    Ip := MyParseHost.getIpStr( Domain );
    with lvAdvance.Items.Add do
    begin
      Caption := Domain;
      SubItems.Add( Ip );
      SubItems.Add( Port );
      ImageIndex := Icon_AdvanceNetwork;
      Data := LvAdvanceData;
    end;
  end;
end;


procedure TCancelAdvanceNetwork.RemoveNewItem;
var
  lvAdvance : TListView;
  i : Integer;
  LvAdvanceData : TLvAdvanceData;
  Domain, Port : string;
  RemoteInternetInfo : TRemoteInternetInfo;
begin
  lvAdvance := frmSetting.lvAdvance;

    // 遍历新的
  for i := lvAdvance.Items.Count - 1 downto 0 do
  begin
    LvAdvanceData := lvAdvance.Items[i].Data;
    Domain := LvAdvanceData.Domain;
    Port := LvAdvanceData.Port;

      // 旧的是否存在新的
    RemoteInternetInfo := AdvanceNetworkSettingInfo.getInternet( Domain, Port );
    if RemoteInternetInfo <> nil then  // 存在则跳过
      Continue;

      // 删除新的
    lvAdvance.Items.Delete(i);
  end;
end;

procedure TCancelAdvanceNetwork.SelectedItem;
var
  ItemData : TLvAdvanceData;
  RemoteInternetInfo : TRemoteInternetInfo;
begin

  ItemData := LvRemoteNetworkUtil.getLvAdvanceSelectedData;
  if ItemData = nil then
    Exit;

  RemoteInternetInfo := AdvanceNetworkSettingInfo.getSelected;
  if ( RemoteInternetInfo = nil ) or
     ( RemoteInternetInfo.Domain <> ItemData.Domain ) or
     ( RemoteInternetInfo.Port <> ItemData.Port )
  then
    LvRemoteNetworkUtil.SetAdvanceSelected( ItemData.Domain, ItemData.Port );
end;

procedure TCancelAdvanceNetwork.Update;
begin
  RemoveNewItem;

  AddOldItem;

  SelectedItem;
end;

{ TPmAdvanceNetworkSelect }

procedure TPmRemoteNetworkChange.SetSelectStr(_SelectStr: string);
begin
  SelectStr := _SelectStr;
end;

procedure TPmRemoteNetworkChange.Update;
begin
  frmMainForm.PmRemoteNetworkSelect( SelectStr );
end;

{ TPmAdvanceNetworkChange }

procedure TPmAdvanceNetworkChange.Update;
var
  i : Integer;
  RemoteInternetList : TRemoteInternetList;
  Domain, Port, ShowStr : string;
begin
  inherited;

    // 获取所选择网络信息
  LvRemoteNetworkUtil.getAdvancePcInfo( SelectStr, Domain, Port );

    // Set Lv Advance
  LvRemoteNetworkUtil.SetAdvanceSelected( Domain, Port );

    // 数据改变
  RemoteNetworkSettingUtil.SetAdvanceSelected( Domain, Port );

    // 改变 内核 网络模式
  NetworkModeChangeUtil.EnterAdvance( Domain, Port );
end;

{ TPmAdvaceNetworkSelect }

procedure TPmAdvaceNetworkSelect.Update;
var
  Domain, Port : string;
begin
  inherited;

  LvRemoteNetworkUtil.getAdvancePcInfo( SelectStr, Domain, Port );
  NetworkModeChangeUtil.SaveEnterAdvance( Domain, Port );

  MasterThread.RestartNetwork;
end;

{ TPmLocalNetworkChange }

procedure TPmLocalNetworkChange.Update;
begin
    // 主界面 改变
  frmMainForm.PmLocalNetworkSelect;

      // Setting 界面改变
  LvRemoteNetworkUtil.SetLanSelected;

      // 数据改变
  RemoteNetworkSettingUtil.SetLanSelected;

    // 网络模式 改变
  NetworkModeChangeUtil.EnterLan;
end;

{ TPmLocalNetworkSelect }

procedure TPmLocalNetworkSelect.Update;
begin
  inherited;

    // 保存 Ini
  NetworkModeChangeUtil.SaveEnterLan;

    // 重启网络
  MasterThread.RestartNetwork;
end;

{ TPmStandardNetworkChange }

procedure TPmStandardNetworkChange.Update;
var
  i : Integer;
  RemoteAccountList : TRemoteAccountList;
  AccountName, Password : string;
  RemoteAccountInfo : TRemoteAccountInfo;
begin
  inherited;

  AccountName := SelectStr;
  RemoteAccountInfo := StandardNetworkSettingInfo.getAccount( AccountName );
  Password := RemoteAccountInfo.Password;

    // Lv Standard
  LvRemoteNetworkUtil.SetStandardSelected( AccountName );

    // 数据改变
  RemoteNetworkSettingUtil.SetStandardSelected( AccountName );

    // 改变 内核 网络模式
  NetworkModeChangeUtil.EnterStandard( AccountName, Password );
end;

{ TPmStandardNetworkSelect }

procedure TPmStandardNetworkSelect.Update;
var
  AccountName : string;
begin
  inherited;

  AccountName := SelectStr;
  NetworkModeChangeUtil.SaveEnterStandard( AccountName );

  MasterThread.RestartNetwork;
end;

{ TNetworkModeLoad }

procedure TNetworkModeLoadIni.Update;
var
  IniFile : TIniFile;
  NetworkMode, NetworkStr : string;
  PmNetworkChange : TPmNetworkChange;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  NetworkMode := IniFile.ReadString( Ini_NetworkMode, Ini_SelectedMode, SelectedMode_Local );
  NetworkStr := IniFile.ReadString( Ini_NetworkMode, Ini_SelectStr, '' );
  IniFile.Free;

    // 不支持 Remote Network
  if ( not frmSetting.IsEnableRemoteNetwork ) or
     ( App_RunWay = AppRunWay_BackupCowLite )
  then
  begin
    NetworkMode := SelectedMode_Local;
    NetworkStr := '';
  end;

  if NetworkMode = SelectedMode_Standard then
    PmNetworkChange := TPmStandardNetworkLoad.Create
  else
  if NetworkMode = SelectedMode_Advance then
    PmNetworkChange := TPmAdvanceNetworkLoad.Create
  else
    PmNetworkChange := TPmLocalNetworkLoad.Create;

  if PmNetworkChange is TPmRemoteNetworkChange then
    ( PmNetworkChange as TPmRemoteNetworkChange ).SetSelectStr( NetworkStr );

  PmNetworkChange.Update;
  PmNetworkChange.Free;
end;

{ LvRemoteNetworkUtil }

class function LvRemoteNetworkUtil.getAdvancePcInfo(ShowStr: string; var Domain,
  Port: string): Boolean;
var
  StrList : TStringList;
begin
  StrList := MySplitStr.getList( ShowStr, Split_PmAdvance );
  if StrList.Count = 2 then
  begin
    Domain := StrList[0];
    Port := StrList[1];
    Result := True;
  end
  else
    Result := False;
  StrList.Free;
end;

class function LvRemoteNetworkUtil.getAdvanceShowStr(Domain,
  Port: string): string;
begin
  Result := Domain + Split_PmAdvance + Port;
end;

class function LvRemoteNetworkUtil.getLvAdvanceData(Domain,
  Port: string): TLvAdvanceData;
var
  lvAdvance : TListView;
  i : Integer;
  LvAdvanceData : TLvAdvanceData;
begin
  Result := nil;

  lvAdvance := frmSetting.lvAdvance;
  for i := 0 to lvAdvance.Items.Count - 1 do
  begin
    LvAdvanceData := lvAdvance.Items[i].Data;
    if ( LvAdvanceData.Domain = Domain ) and
       ( LvAdvanceData.Port = Port )
    then
    begin
      Result := LvAdvanceData;
      Break;
    end;
  end;
end;

class function LvRemoteNetworkUtil.getLvAdvanceSelectedData: TLvAdvanceData;
var
  lvAdvance : TListView;
  i : Integer;
  LvAdvanceData : TLvAdvanceData;
begin
  Result := nil;

  lvAdvance := frmSetting.lvAdvance;
  for i := 0 to lvAdvance.Items.Count - 1 do
  begin
    LvAdvanceData := lvAdvance.Items[i].Data;
    if LvAdvanceData.IsSelected then
    begin
      Result := LvAdvanceData;
      Break;
    end;
  end;
end;

class function LvRemoteNetworkUtil.getLvStandardData(
  AccountName: string): TLvStandardData;
var
  LvStandard : TListView;
  i : Integer;
  LvStandardData : TLvStandardData;
begin
  Result := nil;

  LvStandard := frmSetting.lvStandard;
  for i := 0 to LvStandard.Items.Count - 1 do
  begin
    LvStandardData := LvStandard.Items[i].Data;
    if LvStandardData.AccountName = AccountName then
    begin
      Result := LvStandardData;
      Break;
    end;
  end;
end;

class function LvRemoteNetworkUtil.getLvStandardSelectedData: TLvStandardData;
var
  LvStandard : TListView;
  i : Integer;
  LvStandardData : TLvStandardData;
begin
  Result := nil;

  LvStandard := frmSetting.lvStandard;
  for i := 0 to LvStandard.Items.Count - 1 do
  begin
    LvStandardData := LvStandard.Items[i].Data;
    if LvStandardData.IsSelected then
    begin
      Result := LvStandardData;
      Break;
    end;
  end;
end;

class procedure LvRemoteNetworkUtil.SetAdvanceSelected(Domain, Port: string);
begin
  setLvStandardSelected('');
  setLvAdvanceSelected( Domain, Port );
end;

class procedure LvRemoteNetworkUtil.SetLanSelected;
begin
  setLvStandardSelected('');
  setLvAdvanceSelected('', '');
end;

class procedure LvRemoteNetworkUtil.setLvAdvanceSelected(Domain, Port: string);
var
  lvAdvance : TListView;
  i : Integer;
  LvAdvanceData : TLvAdvanceData;
begin
  lvAdvance := frmSetting.lvAdvance;
  for i := 0 to lvAdvance.Items.Count - 1 do
  begin
    LvAdvanceData := lvAdvance.Items[i].Data;
    if ( LvAdvanceData.Domain = Domain ) and
       ( LvAdvanceData.Port = Port )
    then
    begin
      LvAdvanceData.IsSelected := True;
      lvAdvance.Items[i].ImageIndex := Icon_SelectNetwork;
    end
    else
    begin
      LvAdvanceData.IsSelected := False;
      lvAdvance.Items[i].ImageIndex := Icon_AdvanceNetwork;
    end;
  end;
end;

class procedure LvRemoteNetworkUtil.setLvStandardSelected(AccountName: string);
var
  LvStandard : TListView;
  i : Integer;
  LvAccountData : TLvStandardData;
begin
  LvStandard := frmSetting.lvStandard;
  for i := 0 to LvStandard.Items.Count - 1 do
  begin
    LvAccountData := LvStandard.Items[i].Data;
    if LvAccountData.AccountName = AccountName then
    begin
      LvAccountData.IsSelected := True;
      LvStandard.Items[i].ImageIndex := Icon_SelectNetwork;
    end
    else
    begin
      LvAccountData.IsSelected := False;
      LvStandard.Items[i].ImageIndex := Icon_StandardNetwork;
    end;
  end;
end;

class procedure LvRemoteNetworkUtil.SetStandardSelected(AccountName: string);
begin
  setLvStandardSelected( AccountName );
  setLvAdvanceSelected('', '');
end;

{ NetworkModeChangeUtil }

class procedure NetworkModeChangeUtil.EnterAdvance(Domain, Port: string);
var
  Temp : TNetworkModeInfo;
  AdvanceNetworkMode : TAdvanceNetworkMode;
begin
  AdvanceNetworkMode := TAdvanceNetworkMode.Create;
  AdvanceNetworkMode.SetInternetInfo( Domain, Port );

  Temp := NetworkModeInfo;
  NetworkModeInfo := AdvanceNetworkMode;
  Temp.Free;
end;

class procedure NetworkModeChangeUtil.EnterLan;
var
  Temp : TNetworkModeInfo;
  LanNetworkMode : TLanNetworkMode;
begin
  LanNetworkMode := TLanNetworkMode.Create;

  Temp := NetworkModeInfo;
  NetworkModeInfo := LanNetworkMode;
  Temp.Free;
end;


class procedure NetworkModeChangeUtil.EnterStandard(AccountName,
  Password: string);
var
  Temp : TNetworkModeInfo;
  StandardNetworkMode : TStandardNetworkMode;
begin
  StandardNetworkMode := TStandardNetworkMode.Create;
  StandardNetworkMode.SetAccountInfo( AccountName, Password );

  Temp := NetworkModeInfo;
  NetworkModeInfo := StandardNetworkMode;
  Temp.Free;
end;

class procedure NetworkModeChangeUtil.SaveEnterAdvance(Domain, Port: string);
var
  SelectStr : string;
  IniFile : TIniFile;
begin
  SelectStr := LvRemoteNetworkUtil.getAdvanceShowStr( Domain, Port );

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectedMode, SelectedMode_Advance );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectStr, SelectStr );
  IniFile.Free;
end;

class procedure NetworkModeChangeUtil.SaveEnterLan;
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectedMode, SelectedMode_Local );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectStr, '' );
  IniFile.Free;
end;

class procedure NetworkModeChangeUtil.SaveEnterStandard(AccountName: string);
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectedMode, SelectedMode_Standard );
  IniFile.WriteString( Ini_NetworkMode, Ini_SelectStr, AccountName );
  IniFile.Free;
end;

{ TCheckApplyLocalNetwork }

function TCheckApplyLocalNetwork.get: Boolean;
var
  RemoteAccountInfo : TRemoteAccountInfo;
  RemoteInternetInfo : TRemoteInternetInfo;
  StandardItemData : TLvStandardData;
  AdvanceItemData : TLvAdvanceData;
begin
  Result := False;

  StandardItemData := LvRemoteNetworkUtil.getLvStandardSelectedData;
  AdvanceItemData := LvRemoteNetworkUtil.getLvAdvanceSelectedData;
  if ( StandardItemData <> nil ) or ( AdvanceItemData <> nil ) then
    Exit;

  RemoteAccountInfo := StandardNetworkSettingInfo.getSelected;
  RemoteInternetInfo := AdvanceNetworkSettingInfo.getSelected;
  if ( RemoteAccountInfo <> nil ) or ( RemoteInternetInfo <> nil ) then
  begin
    frmMainForm.PmLocalNetworkSelect;
    RemoteNetworkSettingUtil.SetLanSelected;
    NetworkModeChangeUtil.EnterLan;
    NetworkModeChangeUtil.SaveEnterLan;
    Result := True;
  end;
end;

{ TAdvanceDnsThread }

procedure TAdvanceDnsThread.AddDns(Domain: string);
begin
  Lock.Enter;
  DomainList.Add( Domain );
  Lock.Leave;

  Resume;
end;

constructor TAdvanceDnsThread.Create;
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;
  DomainList := TStringList.Create;
end;

destructor TAdvanceDnsThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  DomainList.Free;
  Lock.Free;
  inherited;
end;

procedure TAdvanceDnsThread.Execute;
var
  Domain, DnsResult : string;
  IsParseError : Boolean;
  AdvanceDnsComplete : TAdvanceDnsComplete;
begin
  while not Terminated do
  begin
      // 获取需要解释的域名
    Domain := getNextDomain;
    if Domain = '' then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 域名解释
    IsParseError := not MyParseHost.HostToIP( Domain, DnsResult );
    if IsParseError then
      DnsResult := Sign_NA;

      // 显示解释结果
    AdvanceDnsComplete := TAdvanceDnsComplete.Create( Domain, DnsResult );
    AdvanceDnsComplete.SetIsParseError( IsParseError );
    AdvanceDnsComplete.Update;
    AdvanceDnsComplete.Free;
  end;

  inherited;
end;

function TAdvanceDnsThread.getNextDomain: string;
begin
  Lock.Enter;
  if DomainList.Count > 0 then
  begin
    Result := DomainList[0];
    DomainList.Delete(0);
  end
  else
    Result := '';
  Lock.Leave;
end;

{ TLvAdvanceAddHandle }

constructor TLvAdvanceAddHandle.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
end;

function TLvAdvanceAddHandle.Update: Boolean;
var
  LvAdvanceData : TLvAdvanceData;
  Ip : string;
begin
  Result := False;
  LvAdvanceData := LvRemoteNetworkUtil.getLvAdvanceData( Domain, Port );
  if LvAdvanceData <> nil then  // 已存在
    Exit;
  Result := True;

    // 添加 Advance 界面
  LvAdvanceData := TLvAdvanceData.Create( Domain, Port );

    // 判断 输入的是 Ip 或是 Domain
  if MyParseHost.IsIpStr( Domain ) then
  begin
    Ip := Domain;
    Domain := '';
  end
  else
  begin
    Ip := Dns_Parsing;
    frmSetting.AdvanceDnsThread.AddDns( Domain ); // 解释域名
  end;

    // 添加
  with frmSetting.lvAdvance.Items.Add do
  begin
    Caption := Ip;
    SubItems.Add( Port );
    SubItems.Add( Domain );
    ImageIndex := Icon_AdvanceNetwork;
    Data := LvAdvanceData;
  end;
end;

{ TSetFirstApplyHandle }

constructor TSetFirstApplyHandle.Create;
begin
  inherited;
  IsFirstApply := True;
end;

{ TAddStandardNetworkHandle }

function TLvStandardAddHandle.Update: Boolean;
var
  LvAccountData : TLvStandardData;
begin
     // 存在相同, 则结束
  LvAccountData := LvRemoteNetworkUtil.getLvStandardData( AccountName );
  if LvAccountData <> nil then
  begin
    Result := False;
    Exit;
  end;
  Result := True;

    // 添加到界面
  LvAccountData := TLvStandardData.Create( AccountName, AccountPassword );
  with frmSetting.lvStandard.Items.Add do
  begin
    Caption := AccountName;
    ImageIndex := Icon_StandardNetwork;
    Data := LvAccountData;
  end;
end;

{ TNetworkGroupChangeHandle }

constructor TLvStandardChangeHandle.Create(_AccountName,
  _AccountPassword: string);
begin
  AccountName := _AccountName;
  AccountPassword := _AccountPassword;
end;

{ TNetworkGroupPasswordHandle }

procedure TLvStandardPasswordHandle.Update;
var
  LvAccountData : TLvStandardData;
begin
     // 存在相同, 则结束
  LvAccountData := LvRemoteNetworkUtil.getLvStandardData( AccountName );
  if LvAccountData <> nil then
    LvAccountData.Password := AccountPassword;
end;

end.
