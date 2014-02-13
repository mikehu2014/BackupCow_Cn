unit UMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, ExtCtrls, StdCtrls,
  ShellCtrls, xmldom, XMLIntf, auHTTP, auAutoUpgrader, XPMan, ImgList,
  Menus, msxmldom, XMLDoc, RzPanel, RzButton, RzStatus, VirtualTrees, IniFiles,
  FileCtrl,
  ActnList, XPStyleActnCtrls, ActnMan,
  AppEvnts, ActiveX, ShellAPI, TlHelp32,
  Spin, Buttons, ShlObj, UIconUtil, Math,
  DateUtils, CommCtrl, RzShellDialogs, uDebugLock, RzPrgres,
   RzTabs, Grids, ValEdit, ActnCtrls, UFileBaseInfo,
  Series, TeEngine, TeeProcs, Chart, siComp;

const
  hfck = wm_user + $1000;
  AppName_FileCloud = 'FileCloud';
  AppName_FolderTransfer = 'FolderTransfer';

type

  TfrmMainForm = class(TForm)
    pmSetting: TPopupMenu;
    miwizard1: TMenuItem;
    miNormal1: TMenuItem;
    ilStatusBar: TImageList;
    ilTbMf16: TImageList;
    ilTbCoolBar: TImageList;
    pmHelp: TPopupMenu;
    miRegister1: TMenuItem;
    miAbout1: TMenuItem;
    xpmnfst1: TXPManifest;
    Upgrade1: TMenuItem;
    plMainForm: TPanel;
    N1: TMenuItem;
    N2: TMenuItem;
    ContactUs1: TMenuItem;
    HomePage1: TMenuItem;
    pmTbRmNw: TPopupMenu;
    N5: TMenuItem;
    ilPc: TImageList;
    ilBackupSetting: TImageList;
    ilTbMf: TImageList;
    ilTbFs16: TImageList;
    ilTbFs16Gray: TImageList;
    ilNw16: TImageList;
    pmTrayIcon: TPopupMenu;
    miShow1: TMenuItem;
    miOpenFolder4: TMenuItem;
    Exit1: TMenuItem;
    SbMainForm: TRzStatusBar;
    sbNetworkMode: TRzGlyphStatus;
    sbDownSpeed: TRzGlyphStatus;
    sbUpSpeed: TRzGlyphStatus;
    sbEdition: TRzGlyphStatus;
    sbMyStatus: TRzGlyphStatus;
    ilNw: TImageList;
    tbMainForm: TRzToolbar;
    tbtnBackup: TRzToolButton;
    tbtnTransStatus: TRzToolButton;
    tbtnSettings: TRzToolButton;
    tbtnHelp: TRzToolButton;
    tbtnExit: TRzToolButton;
    pmTbRemoveFs: TPopupMenu;
    RemoveAll1: TMenuItem;
    FileDialog: TOpenDialog;
    ilFsTv: TImageList;
    ilShellFile: TImageList;
    OnlineManual1: TMenuItem;
    auApp: TauAutoUpgrader;
    iShellBackupStatus: TImageList;
    ilShellTransAction: TImageList;
    tiApp: TTrayIcon;
    N3: TMenuItem;
    More1: TMenuItem;
    pmTbAddFs: TPopupMenu;
    miAddFiles: TMenuItem;
    miAddFolder: TMenuItem;
    tbtnFileTransfer: TRzToolButton;
    PmTbAddLocallSource: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    ilTbNw: TImageList;
    ilTbNwGray: TImageList;
    pmLvMyCloudStatus: TPopupMenu;
    MenuItem3: TMenuItem;
    tmrAppIni: TTimer;
    RzSpacer2: TRzSpacer;
    Enteragroup1: TMenuItem;
    Connectacomputer1: TMenuItem;
    tmrMultiHide: TTimer;
    ilPageControl: TImageList;
    pmFileSendDesOnline: TPopupMenu;
    tiFileSendDesOnline: TMenuItem;
    tiFileSendDesAll: TMenuItem;
    PmCloudPc: TPopupMenu;
    tiCloudShowOnline: TMenuItem;
    tiCloudShowMyBackup: TMenuItem;
    tiCloudShowAll: TMenuItem;
    tiCloudShowOnlineAndMyBackup: TMenuItem;
    Log1: TMenuItem;
    tbtnFileShare: TRzToolButton;
    tmrCheckExistPc: TTimer;
    tmrDragBackground: TTimer;
    PmCloudShow: TPopupMenu;
    tiSpaceInfo: TMenuItem;
    tiComputerInfo: TMenuItem;
    ilTb24: TImageList;
    ilTb24Gray: TImageList;
    tbtnLocalBackup: TRzToolButton;
    PcMain: TRzPageControl;
    tsMainLocalBackup: TRzTabSheet;
    tsMainNetworkBackup: TRzTabSheet;
    tsFileTransfer: TRzTabSheet;
    tsFileShare: TRzTabSheet;
    tsTransferStatus: TRzTabSheet;
    plLocalBackupDes: TPanel;
    plLocalBackupDesTitle: TPanel;
    plBackupDesBoard: TPanel;
    Panel10: TPanel;
    plBackupDesShow: TPanel;
    plBackupDesType: TPanel;
    plLocalCopyExplorer: TPanel;
    TbCopyingExplorer: TToolBar;
    tbtnLocalCopyExplorer: TToolButton;
    Panel8: TPanel;
    PbLocalBackup: TRzProgressBar;
    plLocalBackupPercentShow: TPanel;
    Panel14: TPanel;
    Panel12: TPanel;
    plLocalBackupPercentage: TPanel;
    PbLocalBackupCopy: TRzProgressBar;
    plLocalBackupCopyPercentShow: TPanel;
    Panel13: TPanel;
    Panel16: TPanel;
    tbLocalBackupDes: TToolBar;
    tbtnBackupDesAdd: TToolButton;
    tbtnBackupDesRemove: TToolButton;
    tbtnBackupDesExplorer: TToolButton;
    ToolButton3: TToolButton;
    VstLocalBackupDes: TVirtualStringTree;
    plLocalBackupSource: TPanel;
    plLocalBackupSourceTitle: TPanel;
    tbLocalBackupSource: TToolBar;
    tbtnLocalBackupNow: TToolButton;
    tbtnLocalBackupSelected: TToolButton;
    tbtnLocalBackupExplorer: TToolButton;
    tbtnLocalBackupAdd: TToolButton;
    tbtnLocalBackupRemove: TToolButton;
    ToolButton15: TToolButton;
    tbtnLocalBackupOptions: TToolButton;
    VstLocalBackupSource: TVirtualStringTree;
    slLocalBackup: TSplitter;
    PcBackup: TRzPageControl;
    tsCloudBackup: TRzTabSheet;
    plNetworkBackup: TPanel;
    slBackupPos: TSplitter;
    plBackupDestination: TPanel;
    plBackupDestinationTitle: TPanel;
    plBackupToCloud: TPanel;
    plNetworkConn: TPanel;
    lbNetworkConn: TLabel;
    btnConnNow: TButton;
    LvNetwork: TListView;
    tbNetwork: TToolBar;
    tbtnNwLan: TToolButton;
    tbtnNwRemove: TToolButton;
    tbNetworkPc: TToolBar;
    tbtnNetworkPcProperties: TToolButton;
    ToolButton4: TToolButton;
    ToolButton12: TToolButton;
    tbtnNetworkMoreInfo: TToolButton;
    tbtnNetworkSelectBackupDes: TToolButton;
    plBackupSource: TPanel;
    plBackupSourceTitle: TPanel;
    plBackupItem: TRzPanel;
    slBackupItem: TSplitter;
    plBackupProgress: TPanel;
    PbBackup: TRzProgressBar;
    plBackupProgressPercent: TPanel;
    Panel11: TPanel;
    Panel15: TPanel;
    lvFileStatus: TListView;
    tbFsListView: TToolBar;
    tbtnFsDetail: TToolButton;
    tbtnFsOpen: TToolButton;
    tbtnFsLvlExplorer: TToolButton;
    tbtnFsLvlRemove: TToolButton;
    vstBackupItem: TVirtualStringTree;
    tbFsTreeview: TToolBar;
    tbtnBackupNow: TToolButton;
    tbtnBackupSelected: TToolButton;
    tbtnFsExplorer: TToolButton;
    tbtnFsSelectFolder: TToolButton;
    tbtnFsDelete: TToolButton;
    tbtnBackupClear: TToolButton;
    ToolButton14: TToolButton;
    tbtnFsVstDetail: TToolButton;
    plBackupBoardMain: TPanel;
    RzPanel1: TRzPanel;
    plBackupBoardIcon: TPanel;
    iWarnning1: TImage;
    plBackupBoard: TRzPanel;
    tsRestore: TRzTabSheet;
    plRestore: TPanel;
    Splitter3: TSplitter;
    plRestoreFile: TPanel;
    vstRestoreDown: TVirtualStringTree;
    tbRestoreDown: TToolBar;
    tbtnRestoreMore: TToolButton;
    tbtnRdExplorer: TToolButton;
    tbtnRdRemoveSelected: TToolButton;
    tbtnRdClear: TToolButton;
    Panel22: TPanel;
    lbFiles: TLabel;
    lbSearching: TLabel;
    Panel9: TPanel;
    plRestoreComputers: TPanel;
    Panel26: TPanel;
    tbRestoreNetwork: TToolBar;
    tbtnRestoreLan: TToolButton;
    tbtnRestoreRemote: TToolButton;
    vstRestoreComputers: TVirtualStringTree;
    tbRestoreComputers: TToolBar;
    tbtnRestoreNow: TToolButton;
    tbtnRestoreSpecific: TToolButton;
    tsFileSearch: TRzTabSheet;
    plSearchFile: TPanel;
    slSearchDown: TSplitter;
    plSearchDown: TPanel;
    Panel7: TPanel;
    tbSearchDown: TToolBar;
    tbtnSearchDownExplorer: TToolButton;
    tbtnSdRemoveSelected: TToolButton;
    tbtnSearchDownClear: TToolButton;
    ToolButton17: TToolButton;
    tbtnSearchDownSettings: TToolButton;
    Panel1: TPanel;
    vstSearchDown: TVirtualStringTree;
    plFileSearch: TPanel;
    plSearchFileDisPlay: TPanel;
    lvSearchFile: TListView;
    plSfToolBar: TPanel;
    lbSearchTips: TLabel;
    lbSearchCount: TLabel;
    tbSearchFile: TToolBar;
    tbtnSfSaveas: TToolButton;
    tbtnSfExplorer: TToolButton;
    plSearchFileInfo: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pltntpnl12: TPanel;
    edtSearchFileName: TEdit;
    pltntpnl15: TPanel;
    btnSearch: TButton;
    Panel3: TPanel;
    cbbFileType: TComboBox;
    cbbOnlinePc: TComboBoxEx;
    cbbOwner: TComboBoxEx;
    plFileSearchTital: TPanel;
    tsCloudStatus: TRzTabSheet;
    plCloudManager: TPanel;
    PcCloudStatus: TRzPageControl;
    tsCloudComputers: TRzTabSheet;
    plTitle: TPanel;
    PlAllCloudPc: TPanel;
    plCloudPcMain: TPanel;
    slCloudPc: TSplitter;
    plCloudTotalInfo: TPanel;
    PcCloudTotal: TRzPageControl;
    tsCloudTotalChart: TRzTabSheet;
    ctCloudStatus: TChart;
    peCloudStatus: TPieSeries;
    tsCloudTotalList: TRzTabSheet;
    vlCloudTotal: TValueListEditor;
    vstCloudPc: TVirtualStringTree;
    tbCloudPc: TToolBar;
    tbtnCloudPcDetail: TToolButton;
    ToolButton5: TToolButton;
    tbtnCloudShowType: TToolButton;
    ToolButton13: TToolButton;
    tbtnShowType: TToolButton;
    tsMyCloudComputers: TRzTabSheet;
    Splitter1: TSplitter;
    PlMyCloudDes: TPanel;
    Panel4: TPanel;
    PgMyCloudDes: TRzPageControl;
    TsMyCloudChart: TRzTabSheet;
    ctMyCloud: TChart;
    seMyCloudPc: TBarSeries;
    TsMyCloudList: TRzTabSheet;
    lvMyCloudPc: TListView;
    Panel21: TPanel;
    Panel20: TPanel;
    VstMyBackupDes: TVirtualStringTree;
    tbCloudDestination: TToolBar;
    tbtnMyCloudBackup: TToolButton;
    tbtnMyCloudNotBackup: TToolButton;
    ToolButton11: TToolButton;
    tbtnMyBackupDesProperties: TToolButton;
    tbtnMyCloudDesSelectAll: TToolButton;
    tsMyShareCloud: TRzTabSheet;
    Splitter4: TSplitter;
    Panel23: TPanel;
    Panel27: TPanel;
    Panel28: TPanel;
    RzPageControl1: TRzPageControl;
    RzTabSheet1: TRzTabSheet;
    Chart1: TChart;
    BarSeries1: TBarSeries;
    RzTabSheet2: TRzTabSheet;
    ListView1: TListView;
    Panel24: TPanel;
    Panel25: TPanel;
    vstMyShareCloud: TVirtualStringTree;
    ToolBar1: TToolBar;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    plFileTransfer: TPanel;
    Splitter2: TSplitter;
    PcFileTransfer: TRzPageControl;
    tsFileSend: TRzTabSheet;
    plFileSender: TPanel;
    plFileSendTitle: TPanel;
    tbMyFileSender: TToolBar;
    tbtnSendFile: TToolButton;
    tbtnResetnd: TToolButton;
    tbtnSendExplorer: TToolButton;
    tbtnSendRemove: TToolButton;
    tbtnSendClear: TToolButton;
    ToolButton9: TToolButton;
    vstMyFileSend: TVirtualStringTree;
    plFileSendFreeHint: TPanel;
    Label5: TLabel;
    Image1: TImage;
    LinkLabel2: TLinkLabel;
    tsFileReceive: TRzTabSheet;
    plFileRevc: TPanel;
    plFileReceiveTitle: TPanel;
    lvMyFileReceive: TListView;
    tbMyFileReceive: TToolBar;
    tbtnReceiveExplorer: TToolButton;
    tbtnReceiveRemove: TToolButton;
    tbtnReceiveClear: TToolButton;
    ToolButton16: TToolButton;
    tbtnReceiveSettings: TToolButton;
    ToolButton10: TToolButton;
    Panel5: TPanel;
    plFileTransferDesTop: TPanel;
    plFileTransferDesTitle: TPanel;
    tbFileSendDesNetwork: TToolBar;
    tbtnFileSendLocalNetwork: TToolButton;
    tbtnFileSendRemoteNetwork: TToolButton;
    plFileSendDesConn: TPanel;
    lbFileSendDesConn: TLabel;
    Button1: TButton;
    vstFileTransferDes: TVirtualStringTree;
    plFileTransferDesMulti: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    tbFileSendDes: TToolBar;
    tbtnFileSendDesAdd: TToolButton;
    ToolButton7: TToolButton;
    tbtnFileSendOnline: TToolButton;
    plFileSendNoPc: TPanel;
    NbNoPcTransferFile: TNotebook;
    PlNoPcSendFile: TPanel;
    Image4: TImage;
    lbFileReceiveTips: TLabel;
    Label15: TLabel;
    PlNoPcRevFile: TPanel;
    IWarnning: TImage;
    lbFileSendTips: TLabel;
    Label16: TLabel;
    Panel19: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    plFileShare: TPanel;
    slSharePath: TSplitter;
    PcFileShare: TRzPageControl;
    tsShareDown: TRzTabSheet;
    plShareDown: TPanel;
    VstShareDown: TVirtualStringTree;
    tbShareDown: TToolBar;
    tbtnShareDownAdd: TToolButton;
    tbtnDownloadAgain: TToolButton;
    tbtnShareDownExplorer: TToolButton;
    tbtnShareDownRemove: TToolButton;
    tbtnShareDownClear: TToolButton;
    ToolButton6: TToolButton;
    plDownShareHistoryTitle: TPanel;
    plShareLimtHint: TPanel;
    Label10: TLabel;
    Image3: TImage;
    LinkLabel1: TLinkLabel;
    tsSharePath: TRzTabSheet;
    plMySharePath: TPanel;
    Panel2: TPanel;
    tbSharePath: TToolBar;
    tbtnSharePathAdd: TToolButton;
    tbtnSharePathRemove: TToolButton;
    tbtnSharePathExplorer: TToolButton;
    ToolButton8: TToolButton;
    vstSharePath: TVirtualStringTree;
    plShareFilePc: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    tbFileShareNetwork: TToolBar;
    tbtnFileShareLan: TToolButton;
    tbtnFileShareRemote: TToolButton;
    VstShareFilePc: TVirtualStringTree;
    tbShareFilePc: TToolBar;
    tbtnDownPcShare: TToolButton;
    PlNoSharePc: TPanel;
    Label9: TLabel;
    Image2: TImage;
    plTransStatusBase: TPanel;
    plTransStatusNew: TPanel;
    vstTransStatus: TVirtualStringTree;
    tbTransStatus: TToolBar;
    tbtnTsCollapse: TToolButton;
    tbtnTsExpand: TToolButton;
    ToolButton1: TToolButton;
    tbtnTsClearDowned: TToolButton;
    tbtnTsClearUped: TToolButton;
    tbtnTsClearDownError: TToolButton;
    tbtnClearUpError: TToolButton;
    ToolButton2: TToolButton;
    tbtnTsExplorer: TToolButton;
    tbtnStart: TToolButton;
    tbtnPause: TToolButton;
    tbtnStop: TToolButton;
    Panel6: TPanel;
    spMain1: TRzSpacer;
    plBackupFileNoPc: TPanel;
    Panel31: TPanel;
    Image6: TImage;
    lbNotPcDis: TLabel;
    lbPcNotFind: TLabel;
    Panel32: TPanel;
    lbNoPcTips: TLabel;
    lbRemoteAction: TLabel;
    lbRemotePcNotConn: TLabel;
    Image5: TImage;
    lbNotConn: TLabel;
    Label22: TLabel;
    Image7: TImage;
    Label23: TLabel;
    tbtnRestoreAgain: TToolButton;
    ToolButton23: TToolButton;
    XmlDoc: TXMLDocument;
    tsBackup: TRzTabSheet;
    Panel29: TPanel;
    tsRestoreNew: TRzTabSheet;
    Panel30: TPanel;
    vstRestore: TVirtualStringTree;
    tbRestore: TToolBar;
    tbtnRestoreSelected: TToolButton;
    tbtnRestoreExplorer: TToolButton;
    Panel34: TPanel;
    Splitter5: TSplitter;
    vstRestoreHistory: TVirtualStringTree;
    Panel33: TPanel;
    tbBackup: TToolBar;
    tbtnBackupNowNew: TToolButton;
    tbtnBackupSelectedNew: TToolButton;
    tbtnAddBackupSource: TToolButton;
    tbtnBackupRemove: TToolButton;
    tbtnBackupExplorer: TToolButton;
    ToolButton30: TToolButton;
    ToolButton31: TToolButton;
    VstBackup: TVirtualStringTree;
    siLangDispatcherMain: TsiLangDispatcher;
    siLang_frmMainForm: TsiLang;
    lbTips: TLabel;
    procedure tbtnMainFormClick(Sender: TObject);
    procedure tbtnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miAddFilesClick(Sender: TObject);
    procedure miAddFolderClick(Sender: TObject);
    procedure tbtnFsSelectFolderClick(Sender: TObject);
    procedure tbtnFsDeleteClick(Sender: TObject);
    procedure btnBackupMyFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LvNetworkDeletion(Sender: TObject; Item: TListItem);
    procedure LvNetworkMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure vstTransStatusFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstTransStatusGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstTransStatusGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure lvSearchFileDeletion(Sender: TObject; Item: TListItem);
    procedure btnSearchClick(Sender: TObject);
    procedure lvCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure edtSearchFileNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtSearchFileNameEnter(Sender: TObject);
    procedure edtSearchFileNameExit(Sender: TObject);
    procedure cbbOwnerExit(Sender: TObject);
    procedure cbbOnlinePcExit(Sender: TObject);
    procedure lvSearchFileSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbtnSfExplorerClick(Sender: TObject);
    procedure tbtnSfSaveasClick(Sender: TObject);
    procedure lvSearchFileDblClick(Sender: TObject);
    procedure tbtnTsExplorerClick(Sender: TObject);
    procedure vstTransStatusFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnFsExplorerClick(Sender: TObject);
    procedure lvFileStatusDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnFsOpenClick(Sender: TObject);
    procedure tbtnFsDetailClick(Sender: TObject);
    procedure lvFileStatusDblClick(Sender: TObject);
    procedure tbtnSettingsClick(Sender: TObject);
    procedure tbtnSyncSettingClick(Sender: TObject);
    procedure tbtnTsCollapseClick(Sender: TObject);
    procedure tbtnTsExpandClick(Sender: TObject);
    procedure tbtnTsClearDownedClick(Sender: TObject);
    procedure tbtnTsClearUpedClick(Sender: TObject);
    procedure tbtnTsClearDownErrorClick(Sender: TObject);
    procedure tbtnClearUpErrorClick(Sender: TObject);
    procedure vstTransStatusDblClick(Sender: TObject);
    procedure tbtnNwLanClick(Sender: TObject);
    procedure Upgrade1Click(Sender: TObject);
    procedure ContactUs1Click(Sender: TObject);
    procedure HomePage1Click(Sender: TObject);
    procedure miAbout1Click(Sender: TObject);
    procedure RemoveAll1Click(Sender: TObject);
    procedure OnlineManual1Click(Sender: TObject);
    procedure tbtnNwRemoveClick(Sender: TObject);
    procedure miRegister1Click(Sender: TObject);
    procedure lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
    procedure vstCloudPcGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstCloudPcGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstCloudPcFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstCloudPcCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Exit1Click(Sender: TObject);
    procedure miShow1Click(Sender: TObject);
    procedure lvSearchDownloadDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnSearchDownExplorerClick(Sender: TObject);
    procedure lvSearchDownloadDblClick(Sender: TObject);
    procedure tbtnSearchDownClearClick(Sender: TObject);
    procedure tbtnSdRemoveSelectedClick(Sender: TObject);
    procedure vstRestoreDownGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstRestoreDownGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure tbtnRdExplorerClick(Sender: TObject);
    procedure vstRestoreDownFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstRestoreDownChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnRdRemoveSelectedClick(Sender: TObject);
    procedure tbtnRdClearClick(Sender: TObject);
    procedure btnConnNowClick(Sender: TObject);
    procedure vstBackupItemGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstBackupItemGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstBackupItemFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure lvFileStatusSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure vstBackupItemFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstBackupItemMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure vstBackupItemCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure Properties1Click(Sender: TObject);
    procedure vstCloudPcFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnCloudPcDetailClick(Sender: TObject);
    procedure LvNetworkDblClick(Sender: TObject);
    procedure vstCloudPcDblClick(Sender: TObject);
    procedure tbtnCloudShowTypeClick(Sender: TObject);
    procedure tiAppClick(Sender: TObject);
    procedure More1Click(Sender: TObject);
    procedure tbtnBackupDesAddClick(Sender: TObject);
    procedure lvMyDestinationDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnBackupDesRemoveClick(Sender: TObject);
    procedure tbtnBackupDesExplorerClick(Sender: TObject);
    procedure lvFileStatusKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tbtnRestoreMoreClick(Sender: TObject);
    procedure lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnSendFileClick(Sender: TObject);
    procedure tbtnReceiveSettingsClick(Sender: TObject);
    procedure vstMyFileSendGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstMyFileSendGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstMyFileSendChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnSendExplorerClick(Sender: TObject);
    procedure tbtnSendRemoveClick(Sender: TObject);
    procedure tbtnSendClearClick(Sender: TObject);
    procedure lvMyFileReceiveDeletion(Sender: TObject; Item: TListItem);
    procedure lvMyFileReceiveChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure tbtnReceiveExplorerClick(Sender: TObject);
    procedure tbtnReceiveRemoveClick(Sender: TObject);
    procedure tbtnReceiveClearClick(Sender: TObject);
    procedure vstMyFileSendMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure lvMyFileReceiveDblClick(Sender: TObject);
    procedure tbtnSearchDownSettingsClick(Sender: TObject);
    procedure lvMyCloudPcDblClick(Sender: TObject);
    procedure lvMyDestinationDblClick(Sender: TObject);
    procedure lvLocalBackupSourceDeletion(Sender: TObject; Item: TListItem);
    procedure lvLocalBackupSourceChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure tbtnLocalBackupExplorerClick(Sender: TObject);
    procedure tbtnLocalBackupRemoveClick(Sender: TObject);
    procedure tbtnLocalBackupNowClick(Sender: TObject);
    procedure lvLocalBackupSourceDblClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure tbtnLocalCopyExplorerClick(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure vstMyFileSendFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure pmLvMyCloudStatusPopup(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure tmrAppIniTimer(Sender: TObject);
    procedure tbtnLocalBackupAddClick(Sender: TObject);
    procedure tsCloudBackupMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure tsLocalBackupMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure Enteragroup1Click(Sender: TObject);
    procedure Connectacomputer1Click(Sender: TObject);
    procedure vstFileTransferDesGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstFileTransferDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstFileTransferDesDragOver(Sender: TBaseVirtualTree;
      Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
      Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure vstMyFileSendDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure vstFileTransferDesChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnFileSendDesAddClick(Sender: TObject);
    procedure tbtnFileSendOnlineClick(Sender: TObject);
    procedure tiFileSendDesClick(Sender: TObject);
    procedure PcFileTransferTabClick(Sender: TObject);
    procedure tiCloudPcShowClick(Sender: TObject);
    procedure VstLocalBackupDesGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VstLocalBackupDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstLocalBackupDesChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnFileSendRemoteNetworkClick(Sender: TObject);
    procedure lvLocalBackupSourceMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure VstLocalBackupDesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure VstLocalBackupDesCompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstFileTransferDesDblClick(Sender: TObject);
    procedure vstTransStatusExpanded(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstTransStatusCollapsed(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tmrMultiHideTimer(Sender: TObject);
    procedure VstLocalBackupDesDragOver(Sender: TBaseVirtualTree;
      Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
      Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure Log1Click(Sender: TObject);
    procedure tbtnSharePathAddClick(Sender: TObject);
    procedure tbtnSharePathRemoveClick(Sender: TObject);
    procedure tbtnSharePathExplorerClick(Sender: TObject);
    procedure tbtnShareDownAddClick(Sender: TObject);
    procedure VstShareDownGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstShareDownGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstShareDownChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnShareDownRemoveClick(Sender: TObject);
    procedure tbtnShareDownExplorerClick(Sender: TObject);
    procedure tbtnShareDownClearClick(Sender: TObject);
    procedure VstShareDownMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure VstShareFilePcGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VstShareFilePcGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tbtnFileShareRemoteClick(Sender: TObject);
    procedure VstShareFilePcFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnDownPcShareClick(Sender: TObject);
    procedure VstShareFilePcDblClick(Sender: TObject);
    procedure tmrCheckExistPcTimer(Sender: TObject);
    procedure VstShareDownFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure PcFileShareMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure tsShareDownMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure tsSharePathMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure tbtnNetworkPcPropertiesClick(Sender: TObject);
    procedure LvNetworkSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure PcFileTransferPageChange(Sender: TObject);
    procedure VstLocalBackupSourceGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VstLocalBackupSourceGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstLocalBackupSourceChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure VstLocalBackupSourceDragOver(Sender: TBaseVirtualTree;
      Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
      Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure tmrDragBackgroundTimer(Sender: TObject);
    procedure VstMyBackupDesGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VstMyBackupDesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstMyBackupDesFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnMyCloudBackupClick(Sender: TObject);
    procedure tbtnMyCloudNotBackupClick(Sender: TObject);
    procedure tbtnMyCloudDesSelectAllClick(Sender: TObject);
    procedure VstMyBackupDesChange(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure tbtnNetworkSelectBackupDesClick(Sender: TObject);
    procedure VstMyBackupDesDblClick(Sender: TObject);
    procedure tbtnMyBackupDesPropertiesClick(Sender: TObject);
    procedure tbtnNetworkMoreInfoClick(Sender: TObject);
    procedure tbtnShowTypeClick(Sender: TObject);
    procedure tiSpaceInfoClick(Sender: TObject);
    procedure tiComputerInfoClick(Sender: TObject);
    procedure tbtnFsVstDetailClick(Sender: TObject);
    procedure vstBackupItemChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnBackupSelectedClick(Sender: TObject);
    procedure tbtnBackupClearClick(Sender: TObject);
    procedure tbtnFsLvlExplorerClick(Sender: TObject);
    procedure lvFileStatusChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure BackupCow1Click(Sender: TObject);
    procedure tbtnFsLvlRemoveClick(Sender: TObject);
    procedure VstLocalBackupSourceFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnLocalBackupOptionsClick(Sender: TObject);
    procedure VstLocalBackupSourceMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure VstLocalBackupDesFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnLocalBackupSelectedClick(Sender: TObject);
    procedure vstRestoreComputersGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstRestoreComputersGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure tbtnRestoreRemoteClick(Sender: TObject);
    procedure tbtnRestoreNowClick(Sender: TObject);
    procedure vstRestoreComputersFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnRestoreSpecificClick(Sender: TObject);
    procedure vstRestoreComputersDblClick(Sender: TObject);
    procedure vstRestoreDownMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vstSearchDownGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstSearchDownGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSearchDownChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSearchDownFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure vstSearchDownDblClick(Sender: TObject);
    procedure vstRestoreDownDblClick(Sender: TObject);
    procedure VstShareDownDblClick(Sender: TObject);
    procedure vstSharePathGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstSharePathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSharePathChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSharePathFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnResetndClick(Sender: TObject);
    procedure tbtnDownloadAgainClick(Sender: TObject);
    procedure vstRestoreDownFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnRestoreAgainClick(Sender: TObject);
    procedure vstMyFileSendDblClick(Sender: TObject);
    procedure vstSharePathDblClick(Sender: TObject);
    procedure vstMyFileSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvMyFileReceiveKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VstShareDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstSharePathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvMyFileReceiveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VstLocalBackupSourceDblClick(Sender: TObject);
    procedure VstLocalBackupSourceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VstLocalBackupDesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VstLocalBackupDesDblClick(Sender: TObject);
    procedure vstBackupItemKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstBackupItemDblClick(Sender: TObject);
    procedure vstRestoreDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvSearchFileKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure vstSearchDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VstLocalBackupSourceCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstRestoreDownCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstMyFileSendCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure VstShareDownCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure vstSharePathCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure VstBackupGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstBackupGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstBackupDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure VstBackupFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VstBackupChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnBackupRemoveClick(Sender: TObject);
    procedure tbtnAddBackupSourceClick(Sender: TObject);
    procedure tbtnBackupSelectedNewClick(Sender: TObject);
    procedure VstBackupPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure tbtnBackupExplorerClick(Sender: TObject);
    procedure vstRestoreGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstRestoreGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstRestoreChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tbtnRestoreExplorerClick(Sender: TObject);
    procedure English1Click(Sender: TObject);
    procedure siLang_frmMainFormChangeLanguage(Sender: TObject);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMQueryEndSession(var Message: TMessage);
      message WM_QUERYENDSESSION;
    procedure createparams(var params: tcreateparams); override;
    procedure restorerequest(var Msg: TMessage); message hfck;
  private
    procedure ResetAppWay;
    procedure MainFormIni;
    procedure CreateRegister;
    procedure CreateForm;
    procedure LoadMainFormIni;
    procedure BindDrogHint;
    procedure BindToolbar;
    procedure BindSort;
    procedure BindSysItemIcon;
    procedure IniCbbSearch;
    procedure IniChart;
    procedure AppUpgrade;
    procedure BindVstData;
    procedure SaveMainFormIni;
    procedure DestoryForm;
    procedure DestroyRegister;
  private // ����
    procedure ShowMainForm;
    procedure HideMainForm;
  private
    procedure TsVirExpand(IsExpand: Boolean);
    procedure ClearTsVirRootNode(RootID: string);
    function getVstIsSelectRoot(vst: TVirtualStringTree): Boolean;
    function getVstBackupItemPercentage(Node: PVirtualNode): Integer;
  private
    procedure ResetCloudPcShowType(CloudPcShowType: string);
    procedure ResetCloudColShowType( IsSpaceInfo : Boolean );
  private // File Transfer
    procedure VstFileTransferFirstDrop;
    procedure ResetFileSendDesVisible;
    procedure ResetSelectSendPcVisible;
    procedure ResetIsOnlyShowOnlne(IsOnlyOnline: Boolean);
  public
    procedure PmLocalNetworkSelect;
    procedure PmRemoteNetworkSelect(SelectStr: string);
  public
    procedure RefreshRegisterEdition;
    procedure SearchPcFile(OwnerID: string);
  end;

{$Region ' ������ ' }

  MainFormUtil = class
  public
    class procedure IniRestoreNow;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

  TSelectBackupItemHandle = class
  public
    procedure Update;
  private
    procedure AddOldSelectedItem;
    procedure AddNewSelectedItem;
  end;

{$EndRegion}

{$Region ' ���籸�� ' }

    // ��� ���� Item, Ĭ������
  TAddBackupItemHandle = class
  public
    BackupPathList : TStringList;
  public
    constructor Create( _BackupPathList : TStringList );
    procedure Update;
  private
    function IsInclude( ItemPath: string ): Boolean;
    procedure RemoveChild( ItemPath: string );
  protected
    procedure AddPath( ItemPath : string );virtual;
  end;

    // ��� ���� Item, �ض�����
  TAddBackupItemConfigHandle = class( TAddBackupItemHandle )
  public
    BackupConfigInfo : TBackupConfigInfo;
  public
    procedure SetBackupConfigInfo( _BackupConfigInfo : TBackupConfigInfo );
  protected
    procedure AddPath( ItemPath : string );override;
  end;

{$EndRegion}

{$Region ' ���ر��� ' }

    // ��� ���ر���Դ ·��
  TAddLocalBackupSourceHandle = class
  private
    VstLocalBackupSource : TVirtualStringTree;
  public
    SourcePathList : TStringList;
  public
    constructor Create( _SourcePathList : TStringList );
    procedure Update;virtual;
  protected
    function IsSourceInclude( ItemPath : string ): Boolean; // ����Դ·�� �Ƿ��Ѱ���
    function IsIncludeDes( ItemPath : string ): Boolean;  // �Ƿ��Ѱ��� ����Ŀ��·��
    procedure RemoveChild( ItemPath : string );   // ɾ��·������·��
    procedure AddSourcePath( ItemPath : string );virtual;abstract; // ��� Դ·��
  end;

    // ��� ���ر���Դ ·�� Ĭ������
  TAddLocalBackupSourceDefaultHandle = class( TAddLocalBackupSourceHandle )
  public
    DesPathList : TStringList;
  public
    procedure Update;override;
  protected
    procedure FindDesPathList;
    procedure AddSourcePath( ItemPath : string );override; // ��� Դ·��
    procedure DestoryDesPathList;
  end;

    // ��� ���ر���Դ ���� ·��
  TAddLocalBackupSourceConfigHandle = class( TAddLocalBackupSourceHandle )
  private
    BackupConfig : TLocalBackupConfigInfo;
  public
    procedure SetConfig( _BackupConfig : TLocalBackupConfigInfo );
  protected
    procedure AddSourcePath( ItemPath : string );override;  // ��� Դ·��
  end;

    // ��� ���ر���Ŀ�� ·��
  TAddLocalBackupDesHandle = class
  private
    DesPath : string;
  public
    constructor Create( _DesPath : string );
    procedure Update;
  private
    function IsSourceInclude: Boolean; // ����Դ·�� �Ƿ��Ѱ���
    function IsDesExist: Boolean; // ����Ŀ��·�� �Ƿ����
  private
    procedure AddSourceBackupPath; // ����Ŀ�� ���ݵ�Դ
  end;

{$EndRegion}

{$Region ' ����ָ� ' }

  TRestoreFileNowHandle = class
  public
    RestorePcID : string;
  public
    constructor Create( _RestorePcID : string );
    procedure Update;
  private
    procedure AddRestoreItem( Path, PathType : string );
  end;


  TRestoreFileAgainHandle = class
  public
    RestorePcID, RestorePath : string;
    PathType, SavePath : string;
  public
    constructor Create( _RestorePcID, _RestorePath : string );
    procedure SetPathInfo( _PathType, _SavePath : string );
    procedure Update;
  end;

{$EndRegion}

{$Region ' �ļ����� ' }

  TAddFileSendHandle = class
  public
    FileList : TStringList;
    PcList : TStringList;
  public
    constructor Create( _FileList, _PcList : TStringList );
    procedure Update;
  private
    procedure RemoveExistFile;
    procedure AddNewFile;
  end;

{$EndRegion}

{$Region ' �ļ��������� ' }

  TSearchDownloadHandle = class
  public
    DownloadPath : string;
  public
    constructor Create( _DownloadPath : string );
  end;

{$EndRegion}

{$Region ' �϶��ļ� ' }

    // �϶� �����ļ�����
  TAddDropBackupFile = class
  private
    FilePathList: TStringList;
  private
    IsAddLocalDes, IsAddLocalBackup, IsAddNetworkBackup : Boolean;
    ItemID : string;
  public
    constructor Create( _FilePathList: TStringList );
    procedure Update;
  private
    procedure FindDropBackupInfo;
  end;

  // �϶��ļ�����
  TDropFileHandle = class
  public
    Msg: TMessage;
  public
    DropFileType: string;
    FilePathList: TStringList;
  public
    constructor Create(_Msg: TMessage);
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindFilePathList;
    procedure FindDropFileType;
  private
    procedure AddLocalBackupSource;
    procedure AddLocalBackupDes;
    procedure AddBackupItem;
    procedure AddFileSend;
    procedure AddFileTransferDes;
    procedure AddFileShare;
    procedure AddFileBackup;
  private
    procedure ResetStatus;
    procedure ShowMainForm;
  end;

{$EndRegion}

{$Region ' Cloud Status '}

    // ѡ�� ����Ŀ�� ������
  VstMyBackupDestinationUtil = class
  public
    class procedure SetIsBackup( IsBackup : Boolean );
  end;

    // ���� ��Pc ������
  VstCloudComputerUtil = class
  public
    class procedure ShowSpaceInfo;
    class procedure ShowComputerInfo;
  public
    class function getIsSpaceCol( Col : Integer ): Boolean;
  end;

{$EndRegion}

{$Region ' �汾���� ' }

  // �汾����
  // �ļ�����İ汾
  TFolderTransferEnter = class
  public
    procedure Update;
  private
    procedure ResetBroadcast;
    procedure ResetTcpPort;
    procedure ResetConfigPath;
    procedure ResetHomePage;
  private
    procedure ResetMainForm;
    procedure HideMainFormControl;
    procedure ResetFileTransfer;
    procedure ResetSettingForm;
    procedure ResetConnaPc;
    procedure ResetJoinaGroup;
    procedure ResetAboutForm;
    procedure ResetFreeEditionForm;
  end;

  // �汾����
  // ����
  TBackupCowLiteEnter = class
  public
    procedure Update;
  private
    procedure HindeMainFormControl;
    procedure ResetSettingForm;
    procedure ResetFreeEditionForm;
    procedure ResetMainForm;
  end;

{$EndRegion}

const
  AppRunWay_BackupCow = 'BackupCow';
  AppRunWay_BackupCowLite = 'BackupCowLite';
  AppRunWay_FolderTransfer = 'FolderTransfer';

const // �϶��ļ�
  DropFileType_BackupFile = 'BackupFile';
  DropFileType_LocalBackupFile = 'LocalBackupFile';
  DropFileType_LocalDesFolder = 'LocalDesFolder';
  DropFileType_SendFile = 'SendFile';
  DropFileType_FileTransferDes = 'FileTransferDes';
  DropFileType_FileShare = 'FileShare';
  DropFileType_Backup = 'Backup';

//  DropFile_Hint = 'Drag and drop files or folders here from Windows Explorer';
//  DropFolder_Hint = 'Drag and drop folders here from Windows Explorer';

var // �϶��ļ�
  DragFile_IsFileTransferDes: Boolean = False; // �϶��ļ�
  DragFile_FileTransferDesStart: Boolean = True; // �Ƿ�ʼ�϶��ļ�
  DragFile_FileTransferDesLastX: Integer = 0;
  DragFile_FileTransferDesLastY: Integer = 0;
  DropFileDes_HideStartTime: TDateTime;

  DragFile_FileBackupLastX : Integer = 0;
  DragFile_FileBackupLastY : Integer = 0;

  DropFile_IsLocalBackupSource: Boolean = True;

var // ���ư汾
  App_RunWay: string = AppRunWay_BackupCow;

const
  VstBackup_BackupName = 0;
  VstBackup_FileCount = 1;
  VstBackup_FileSize = 2;
  VstBackup_NextBackup = 3;
  VstBackup_Percentage = 4;
  VstBackup_Status = 5;

  VstRestore_RestoreName = 0;
  VstRestore_RestoreOwner = 1;
  VstRestore_FileCount = 2;
  VstRestore_FileSize = 3;
  VstRestore_LastBackupTime = 4;

const
  Time_ShowHint: Integer = 30000;

//  EditTip_SearchName
//    : string =
//    'Enter a full file name or part of the file name.( Leave blank or . to view all files )';

  Tag_NoSearch = 1;
  Tag_Searching = 2;

//  MessageShow_DeleteSureThisItem
//    : string = 'Are you sure to remove selected backup Files or Folders?';
//  MessageShow_DeleteSureAllItem
//    : string = 'Are you sure to remove all backup items?';
  ShowForm_RemoteForbid
    : string =
    'Please upgrade to the Enterprise edition in order to use this feature.';
  MessageShow_DeleteSureThisDestination
    : string = 'Are you sure to remove this destination?';

  MessageShow_ExistDestination: string = 'The destination is exist.';
  MessageShow_ExistBackupRoot
    : string = 'The destination has existed in you backup items';
  MessageShow_BackupExistDes
    : string = 'The backup item has existed in you destinations';

  // Backup Item
  FormTitle_SelectBackupPath= 'Select your backup folder';
  ShowForm_BackupItemExist = 'Failed to add This %s, which has been existed in you backup items';
  ShowForm_NetworkFolder = 'Network folder can not add';

  // Local BackupItem
  ShowForm_LocalBackupDesItemExist = 'Failed to add This %s, which has been existed in you Destination';

  // Network
  ShowForm_RestartNetwork = 'Are you sure to restart network?';

  SelectFolderTitle_SaveAs: string = 'Select a folder to save the file.';
  SelectFolderTitle_SelectBackupItem = 'Select your backup folder';
  SelectFolderTitle_SelectDestination = 'Select your destination folder';

  ShowForm_RemoveSelected: string = 'Are you sure to remove?';
  ShowForm_ClearSearchDown
    : string = 'Are you sure to clear all success download records?';
  ShowForm_ClearRestoreDown
    : string = 'Are you sure to clear all success restore records?';

  ShowForm_RemoveFileSend: string = 'Are you sure to remove?' + #13#10 +
    '(If a file is in "Sending" status, the file transfer will be also cancelled.)';
  ShowForm_RemoveFileRevceive: string = 'Are you sure to remove?' + #13#10 +
    '(If a file is in "Receiving" status, the file transfer will be also cancelled.)';
  ShowForm_ClearFileSend
    : string = 'Are you sure to clear all success file transfer records ?';
  ShowForm_ClearFileReceive
    : string = 'Are you sure to clear all success file transfer records ?';

  ShowForm_RemoveShareDown: string = 'Are you sure to remove?' + #13#10 +
    '(If a file is in "Downloading" status, the file transfer will be also cancelled.)';
  ShowForm_ClearShareDown
    : string = 'Are you sure to clear all success file transfer records ?';

  ShowForm_RemoveRestore : string =  'Are you sure to remove?' + #13#10 +
    '(If the status is "Restoring", the restoration process will be also cancelled.)';

  ShowForm_RemoveSharePath: string = 'Are you sure to remove?';

  ShowForm_SharePathExist
    : string =
    'Failed to add This %s, which has been existed in you Share Path';

  ShowForm_AppExpired: string = 'Your Backup Cow has expired already.';

  // NetworkMode Show Str
  NetworkModeShow_LAN = 'LAN';
  NetworkModeShow_Standard = 'Remote ( Standard )';
  NetworkModeShow_Advanced = 'Remote ( Advanced )';

  // NetworkMode Show Icon
  NetworkModeIcon_LAN = 1;
  NetworkModeIcon_Remote = 8;

  // Vst Cloud Pc
  vstCloudPc_PcName = 0;
  vstCloudPc_TotalSpace = 1;
  vstCloudPc_UsedSpace = 2;
  vstCloudPc_AvailableSpace = 3;
  vstCloudPc_BackupSpace = 4;
  vstCloudPc_Status = 5;
  vstCloudPc_LastOnlineTime = 6;
  vstCloudPc_Reachable = 7;
  vstCloudPc_Position = 8;

  // Vst Restore Down File
  VstRestoreDown_FileName = 0;
  VstRestoreDown_Owner = 1;
  VstRestoreDown_FileSize = 2;
  VstRestoreDown_Percentage = 3;
  VstRestoreDown_Status = 4;

  // Vst Backup Item
  VstBackupItem_FullPath = 0;
  VstBackupItem_FileCount = 1;
  VstBackupItem_Size = 2;
  VstBackupItem_NextSync = 3;
  VstBackupItem_Status = 4;

  // Page MainForm
  NbPage_LocalFileStatus = 0;
  NbPage_FileStatus = 1;
  NbPage_FileTransfer = 2;
  NbPage_FileShare = 3;
  NbPage_TransferStatus = 4;

  // Vst SendFile
  VstSendFile_FilePath = 0;
  VstSendFile_FileSize = 1;
  VstSendFile_Destination = 2;
  VstSendFile_Percentage = 3;
  VstSendFile_Status = 4;

  // Vst FileTransfer
  VstFileSendDes_PcName = 0;
  VstFileSendDes_Upload = 1;
  VstFileSendDes_Download = 2;

  // Vst LocalBackupDes
  VstLocalBackupDes_FilePath = 0;
  VstLocalBackupDes_FileSize = 1;
  VstLocalBackupDes_FileStatus = 2;

  // Vst ShareDown
  VstShareDown_FilePath = 0;
  VstShareDown_OwnerName = 1;
  VstShareDown_FileSize = 2;
  VstShareDown_Percentage = 3;
  VstShareDown_Status = 4;

  // Vst SharePc
  VstSharePc_PcName = 0;
  VstSharePc_Upload = 1;
  VstSharePc_Download = 2;

    // Vst RestorePC
  VstRestorePc_PcName = 0;
  VstRestorePc_Upload = 1;
  VstRestorePc_Download = 2;

    // Vst Share Path
  VstSharePath_FilePath = 0;
  VstSharePath_FileSize = 1;
  VstSharePath_FileTime = 2;

    // Vst SearchDown
  VstSearchDown_FileName = 0;
  VstSearchDown_FileOwner = 1;
  VstSearchDown_FileSize = 2;
  VstSearchDown_FileFrom = 3;
  VstSearchDown_Percentage = 4;
  VstSearchDown_Status = 5;

  CbbSearchType_All = 0;
  CbbSearchType_Source = 1;
  CbbSearchType_BackupCopy = 2;

  LkBackupRedirectTag_File = 0;
  LkBackupRedirectTag_Folder = 1;

  Section_SaveAsPath = 'SaveAsPath';

  tbtnBackupDesIcon_Enable = 3;
  tbtnBackupDesIcon_Disable = 4;

  tbtnBackupDesHint_Enable = 'Enable';
  tbtnBackupDesHint_Disable = 'Disable';

  BackupItemHint_ItemPath = 'Path: ';
  BackupItemHint_PersetCopy = 'Perset Copy Qty: ';
  BackupItemHint_SyncTime = 'Sync Interval: ';
  BackupItemHint_LastSyncTime = 'Last Sync: ';
  BackupItemHint_NextSyncTime = 'Next Sync: ';

  BackupItemHint_IncludeFile = 'Incloude Files: ';
  BackupItemHint_Size = 'Total Space: ';
  BackupItemHint_Status = 'Status: ';


const // Cloud Pc ��ʾ����
  VstCloudPcShowType_Online = 'Online';
  VstCloudPcShowType_MyBackup = 'MyBackup';
  VstCloudPcShowType_OnlineAndMyBackup = 'OnlineAndMyBackup';
  VstCloudPcShowType_All = 'All';

  MiCloudPc_Online = 0;
  MiCloudPc_MyBackup = 1;
  MiCloudPc_OnlineAndMyBackup = 2;
  MiCloudPc_All = 3;

const
  PageNotPcTransfer_Send = 0;
  PageNotPcTransfer_Receive = 1;

var // Ӧ�ó���
  App_IsExit: Boolean = True;
  AppRun_IsHide: Boolean = False; // ϵͳ�Զ�����
  App_IsFreeLimit: Boolean = False; // ���ð�����
  DefaultPage_MainForm: Integer = NbPage_LocalFileStatus; // Ĭ�ϵ���ʾҳ��

var
  frmMainForm: TfrmMainForm;
  FolderPath_SelectDefault: string = '';
  VstCloudPc_ShowType: string = '';

implementation

uses UFormUtil, UXmlUtil, UFormBackupPath, UBackupCow, UBackupInfoControl,
  UBackupInfoFace, ULocalBackupInfo, ULocalBackupFace, ULocalBackupControl,
  UMyBackupFaceInfo, UMyBackupApiInfo, UFrmSelectBackupItem, UMyBackupDataInfo,
  UMyRestoreFaceInfo, UMyCloudDataInfo,
  UNetworkFace, UNetworkControl, UJobFace, UMyUtil, UJobControl,
  UFileSearchControl, USearchFileFace, UMyRestoreFileControl,
  UMyNetPcInfo, UMyCloudPathInfo, UFormSetting, UFormRestorePath, UMyUrl,
  UFormAbout, UFormRegisterNew,
  URegisterInfo, URestoreFileFace, UBackupBoardInfo, UMyBackupInfo,
  UAppEditionInfo, URegisterInfoIO,
  UBackupFileScan, UBackupJobScan, UFormSelectTransfer, UMyFileTransferControl,
  UFileTransferFace,
  USettingInfo, UFormLocalBackupPath, UFormFreeEdition,
  UFromEnterGroup, UFormConnPc,
  UFormExitWarnning, UDebugForm, UFormSelectSharePath, UMyShareFace,
  UMyShareControl, UMyFileSearch,
  UFormFileShareExplorer, UFormbroadcast, UFormBackupProperties, UFormFileSelect,
  UFormLocalBackupPro, UFormBackupItemApply, UFormSelectLocalSource, UFormSelectLocalDes;

{$R *.dfm}




procedure TfrmMainForm.tiFileSendDesClick(Sender: TObject);
var
  IsOnlyOnline: Boolean;
begin
  if (Sender as TMenuItem).ImageIndex = PmRemoteNetworkIcon_Selected then
    Exit;

  // �ı� ToolBar
  IsOnlyOnline := Sender = tiFileSendDesOnline;
  ResetIsOnlyShowOnlne(IsOnlyOnline);

  // �ı� ����
  ResetFileSendDesVisible;
  ResetSelectSendPcVisible;
  tbtnFileSendDesAdd.Enabled := False;
end;

procedure TfrmMainForm.AppUpgrade;
begin
  if AppUpgradeModeUtil.getIsPrivateApp then
    auApp.InfoFileURL := MyUrl.getAppUpgradePrite
  else
    auApp.InfoFileURL := MyUrl.getAppUpgrade;
  auApp.CheckUpdate;
end;

procedure TfrmMainForm.BindDrogHint;
begin
  vstFileTransferDes.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
  VstLocalBackupSource.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
  VstLocalBackupDes.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFolder' );
  VstSharePath.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
end;

procedure TfrmMainForm.BindSort;
begin
  ListviewUtil.BindSort(lvFileStatus);
  ListviewUtil.BindSort(lvSearchFile);
  ListviewUtil.BindSort(lvMyCloudPc);
  ListviewUtil.BindSort(lvMyFileReceive);

  VirtualTreeUtil.BindSort( VstLocalBackupSource );
  VirtualTreeUtil.BindSort( vstBackupItem );
  VirtualTreeUtil.BindSort( vstRestoreDown );
  VirtualTreeUtil.BindSort( vstCloudPc );
  VirtualTreeUtil.BindSort( vstMyFileSend );
  VirtualTreeUtil.BindSort( VstShareDown );
  VirtualTreeUtil.BindSort( vstSharePath );
end;

procedure TfrmMainForm.BindSysItemIcon;
begin
  lvFileStatus.SmallImages := MyIcon.getSysIcon;
  vstTransStatus.Images := MyIcon.getSysIcon;
  lvSearchFile.SmallImages := MyIcon.getSysIcon;
  vstRestoreDown.Images := MyIcon.getSysIcon;
  vstMyFileSend.Images := MyIcon.getSysIcon;
  lvMyFileReceive.SmallImages := MyIcon.getSysIcon;
  VstLocalBackupSource.Images := MyIcon.getSysIcon;
  VstLocalBackupDes.Images := MyIcon.getSysIcon;
  VstShareDown.Images := MyIcon.getSysIcon;
  vstSearchDown.Images := MyIcon.getSysIcon;
  vstSharePath.Images := MyIcon.getSysIcon;
  VstBackup.Images := MyIcon.getSysIcon;
  vstRestore.Images := MyIcon.getSysIcon;
end;

procedure TfrmMainForm.BindToolbar;
begin
  vstBackupItem.PopupMenu := FormUtil.getPopMenu(tbFsTreeview);
  lvFileStatus.PopupMenu := FormUtil.getPopMenu(tbFsListView);
  LvNetwork.PopupMenu := FormUtil.getPopMenu( tbNetworkPc );
  vstTransStatus.PopupMenu := FormUtil.getPopMenu(tbTransStatus);
  lvSearchFile.PopupMenu := FormUtil.getPopMenu(tbSearchFile);
  vstRestoreDown.PopupMenu := FormUtil.getPopMenu(tbRestoreDown);
  vstCloudPc.PopupMenu := FormUtil.getPopMenu(tbCloudPc);
  VstLocalBackupDes.PopupMenu := FormUtil.getPopMenu(tbLocalBackupDes);
  vstMyFileSend.PopupMenu := FormUtil.getPopMenu(tbMyFileSender);
  lvMyFileReceive.PopupMenu := FormUtil.getPopMenu(tbMyFileReceive);
  VstLocalBackupSource.PopupMenu := FormUtil.getPopMenu(tbLocalBackupSource);
  vstFileTransferDes.PopupMenu := FormUtil.getPopMenu(tbFileSendDes);
  VstShareDown.PopupMenu := FormUtil.getPopMenu(tbShareDown);
  vstSharePath.PopupMenu :=  FormUtil.getPopMenu(tbSharePath);
  VstShareFilePc.PopupMenu := FormUtil.getPopMenu(tbShareFilePc);
  VstMyBackupDes.PopupMenu := FormUtil.getPopMenu( tbCloudDestination );
  vstRestoreComputers.PopupMenu := FormUtil.getPopMenu( tbRestoreComputers );
  vstSearchDown.PopupMenu := FormUtil.getPopMenu( tbSearchDown );
end;

procedure TfrmMainForm.BindVstData;
begin
  vstTransStatus.NodeDataSize := SizeOf(TTransferData);
  vstCloudPc.NodeDataSize := SizeOf(TCloudPcData);
  vstRestoreDown.NodeDataSize := SizeOf(TVstRestoreDownData);
  vstBackupItem.NodeDataSize := SizeOf(TVstBackupItemData);
  vstMyFileSend.NodeDataSize := SizeOf(TVstMyFileSendData);
  vstFileTransferDes.NodeDataSize := SizeOf(TVstFileTransferDesData);
  VstLocalBackupSource.NodeDataSize := SizeOf(TVstLocalBackupSourceData);
  VstLocalBackupDes.NodeDataSize := SizeOf(TvstLocalBackupDesData);
  VstShareDown.NodeDataSize := SizeOf(TVstShareDownData);
  VstShareFilePc.NodeDataSize := SizeOf(TVstShareFilePcData);
  VstMyBackupDes.NodeDataSize := SizeOf(TVstMyBackupDesData);
  vstRestoreComputers.NodeDataSize := SizeOf(TVstRestorePcData);
  vstSearchDown.NodeDataSize := SizeOf(TVstSearchDownData);
  vstSharePath.NodeDataSize := SizeOf(TVstSharePathData);
  VstBackup.NodeDataSize := SizeOf(TVstBackupData);
  vstRestore.NodeDataSize := SizeOf(TVstRestoreData);
end;

procedure TfrmMainForm.miAbout1Click(Sender: TObject);
begin
  frmAbout.Show;
end;

procedure TfrmMainForm.miAddFilesClick(Sender: TObject);
var
  BackupPathList : TStringList;
  AddBackupItemHandle : TAddBackupItemHandle;
begin
  if not FileDialog.Execute then
    Exit;

  BackupPathList := MyStringList.getStrings( FileDialog.Files );

    // ��� Backup Item
  AddBackupItemHandle := TAddBackupItemHandle.Create( BackupPathList );
  AddBackupItemHandle.Update;
  AddBackupItemHandle.Free;

  BackupPathList.Free;
end;

procedure TfrmMainForm.miAddFolderClick(Sender: TObject);
var
  BackupPathList : TStringList;
  AddBackupItemHandle : TAddBackupItemHandle;
begin
  // ѡ��Ŀ¼
  if not MySelectFolderDialog.SelectNormal(SelectFolderTitle_SelectBackupItem, '',
                                       FolderPath_SelectDefault)
  then
    Exit;

  BackupPathList := MyStringList.getString( FolderPath_SelectDefault );

    // ��� Backup Item
  AddBackupItemHandle := TAddBackupItemHandle.Create( BackupPathList );
  AddBackupItemHandle.Update;
  AddBackupItemHandle.Free;

  BackupPathList.Free;
end;

procedure TfrmMainForm.miRegister1Click(Sender: TObject);
begin
  frmRegisterNew.Show;
end;

procedure TfrmMainForm.miShow1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  ShowMainForm;
end;

procedure TfrmMainForm.More1Click(Sender: TObject);
begin
  frmSetting.pcMain.ActivePage := frmSetting.tsRemoveNetwork;
  frmSetting.Show;
end;

procedure TfrmMainForm.OnlineManual1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.OnlineManual);
end;

procedure TfrmMainForm.PcFileShareMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  TabIndex: Integer;
  IsShowHint: Boolean;
  HintStr: string;
begin
  TabIndex := PcFileShare.TabAtPos(X, Y);
  if TabIndex >= 0 then
  begin
    IsShowHint := True;
    HintStr := PcFileShare.Pages[TabIndex].Hint;
  end
  else
  begin
    IsShowHint := False;
    HintStr := '';
  end;

  PcFileShare.Hint := HintStr;
  PcFileShare.ShowHint := IsShowHint;
end;

procedure TfrmMainForm.PcFileTransferPageChange(Sender: TObject);
begin
  NbNoPcTransferFile.PageIndex := PcFileTransfer.ActivePageIndex;
end;

procedure TfrmMainForm.PcFileTransferTabClick(Sender: TObject);
begin
  if (PcFileTransfer.ActivePage = tsFileReceive) and
    (LvFileReceive_NewCount > 0) then
  begin
    tsFileReceive.Caption := LvFileReceive_Caption;
    LvFileReceive_NewCount := 0;
  end;
end;

procedure TfrmMainForm.PmLocalNetworkSelect;
begin
  PmRemoteNetworkSelect('');

  tbtnNwLan.ImageIndex := PmNetworkIcon_Selected;
  tbtnNwRemove.ImageIndex := -1;

  tbtnFileSendLocalNetwork.ImageIndex := PmNetworkIcon_Selected;
  tbtnFileSendRemoteNetwork.ImageIndex := -1;

  tbtnFileShareLan.ImageIndex := PmNetworkIcon_Selected;
  tbtnFileShareRemote.ImageIndex := -1;

  tbtnRestoreLan.ImageIndex := PmNetworkIcon_Selected;
  tbtnRestoreRemote.ImageIndex := -1;

  sbNetworkMode.Caption := frmMainForm.siLang_frmMainForm.GetText( 'NetLAN' );
  sbNetworkMode.ImageIndex := NetworkModeIcon_LAN;
end;

procedure TfrmMainForm.pmLvMyCloudStatusPopup(Sender: TObject);
begin
  pmLvMyCloudStatus.Items[0].Visible := lvMyCloudPc.Selected <> nil;
end;

procedure TfrmMainForm.PmRemoteNetworkSelect(SelectStr: string);
var
  i: Integer;
  IsStandard, IsFindItem: Boolean;
  ShowStr: string;
  SplitCount: Integer;
begin
  tbtnNwLan.ImageIndex := -1;
  tbtnNwRemove.ImageIndex := PmNetworkIcon_Selected;

  tbtnFileSendLocalNetwork.ImageIndex := -1;
  tbtnFileSendRemoteNetwork.ImageIndex := PmNetworkIcon_Selected;

  tbtnFileShareLan.ImageIndex := -1;
  tbtnFileShareRemote.ImageIndex := PmNetworkIcon_Selected;

  tbtnRestoreLan.ImageIndex := -1;
  tbtnRestoreRemote.ImageIndex := PmNetworkIcon_Selected;

  IsStandard := True;
  IsFindItem := False;
  SplitCount := 0;
  for i := 0 to pmTbRmNw.Items.Count - 1 do
    if pmTbRmNw.Items[i].Caption = '-' then
    begin
      if IsStandard and not IsFindItem then
        IsStandard := False;

      // �ָ���
      Inc(SplitCount);
      if SplitCount = 2 then
        Break; // ����
    end
    else if pmTbRmNw.Items[i].Caption = SelectStr then
    begin
      pmTbRmNw.Items[i].ImageIndex := PmRemoteNetworkIcon_Selected;
      pmTbRmNw.Items[i].Default := True;
      IsFindItem := True;
    end
    else
    begin
      pmTbRmNw.Items[i].ImageIndex := -1;
      pmTbRmNw.Items[i].Default := False;
    end;

  // û��ѡ��
  if not IsFindItem then
    Exit;

  // ���� ����
  if IsStandard then
    ShowStr := frmMainForm.siLang_frmMainForm.GetText( 'NetStandard' )
  else
    ShowStr := frmMainForm.siLang_frmMainForm.GetText( 'NetAdvance' );
  sbNetworkMode.Caption := ShowStr;
  sbNetworkMode.ImageIndex := NetworkModeIcon_Remote;
end;

procedure TfrmMainForm.Properties1Click(Sender: TObject);
var
  SelectItem: TListItem;
  ItemData: TNetworkPcItemData;
begin
  SelectItem := LvNetwork.Selected;
  if SelectItem = nil then
    Exit;
  ItemData := SelectItem.Data;

  MyNetworkControl.ShowPcDetail(ItemData.PcID);
end;

procedure TfrmMainForm.RefreshRegisterEdition;
var
  RegisterEdition: string;
  ShowStrList : TStringList;
  IsShowRemoteNetwork: Boolean;
  BackupCowUnRegisterInfo: TBackupCowUnRegisterInfo;
begin
  RegisterEdition := RegisterInfo.RegisterEditon;

  // �Ƿ����ð�
  App_IsFreeLimit := RegisterInfo.getIsFreeEdition;

  // Status Bar
  sbEdition.Caption := RegisterInfo.getAppEditionDate;


  // Remote Network
  IsShowRemoteNetwork := RegisterEdition <> RegisterEditon_Professional;
  if IsShowRemoteNetwork then
  begin
    tbtnNwRemove.DropdownMenu := pmTbRmNw;
    tbtnFileSendRemoteNetwork.DropdownMenu := pmTbRmNw;
    tbtnFileShareRemote.DropdownMenu := pmTbRmNw;
    tbtnRestoreRemote.DropdownMenu := pmTbRmNw;
  end
  else
  begin
    tbtnNwRemove.DropdownMenu := nil;
    tbtnFileSendRemoteNetwork.DropdownMenu := nil;
    tbtnFileShareRemote.DropdownMenu := nil;
    tbtnRestoreRemote.DropdownMenu := nil;
  end;

  // Setting
  frmSetting.IsEnableRemoteNetwork := IsShowRemoteNetwork;

  // ���������
  if not IsShowRemoteNetwork and (NetworkModeInfo <> nil) and
    not(NetworkModeInfo is TLanNetworkMode) then
    tbtnNwLan.Click;

  // �����ð汾 �� �������ڼ�ʱ
  AppExpiredCheckThread.SetIsExpired(not RegisterInfo.getIsPermanent);
end;

procedure TfrmMainForm.RemoveAll1Click(Sender: TObject);
var
  RootNode: PVirtualNode;
  NodeData: PVstBackupItemData;
begin
  if not MyMessageBox.ShowConfirm( siLang_frmMainForm.GetText( 'ConfirmBackupClear' ) ) then
    Exit;

  // ɾ�� ���и�Ŀ¼
  RootNode := vstBackupItem.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    NodeData := vstBackupItem.GetNodeData(RootNode);
    MyBackupFileControl.RemoveBackupPath(NodeData.FolderName);
    RootNode := RootNode.NextSibling;
  end;
end;



procedure TfrmMainForm.ResetAppWay;
var
  FolderTransferEnter: TFolderTransferEnter;
  BackupCowLiteEnter: TBackupCowLiteEnter;
begin
  // ���� Folder Transfer �汾
  if App_RunWay = AppRunWay_FolderTransfer then
  begin
    FolderTransferEnter := TFolderTransferEnter.Create;
    FolderTransferEnter.Update;
    FolderTransferEnter.Free;
  end
  else // ���� Lite ��
    if App_RunWay = AppRunWay_BackupCowLite then
  begin
    BackupCowLiteEnter := TBackupCowLiteEnter.Create;
    BackupCowLiteEnter.Update;
    BackupCowLiteEnter.Free;
  end;
end;

procedure TfrmMainForm.ResetCloudColShowType(IsSpaceInfo: Boolean);
var
  SelectItem, UnSelectItem: TMenuItem;
begin
  if IsSpaceInfo then
  begin
    SelectItem := tiSpaceInfo;
    UnSelectItem := tiComputerInfo;
  end
  else
  begin
    SelectItem := tiComputerInfo;
    UnSelectItem := tiSpaceInfo;
  end;

  SelectItem.ImageIndex := PmRemoteNetworkIcon_Selected;
  UnSelectItem.ImageIndex := -1;
  tbtnShowType.Caption := SelectItem.Caption;
  tbtnShowType.Hint := SelectItem.Hint;
end;


procedure TfrmMainForm.ResetCloudPcShowType(CloudPcShowType: string);
var
  MiCloudPc, i: Integer;
  mi: TMenuItem;
begin
  if CloudPcShowType = VstCloudPcShowType_Online then
    MiCloudPc := MiCloudPc_Online
  else if CloudPcShowType = VstCloudPcShowType_MyBackup then
    MiCloudPc := MiCloudPc_MyBackup
  else if CloudPcShowType = VstCloudPcShowType_OnlineAndMyBackup then
    MiCloudPc := MiCloudPc_OnlineAndMyBackup
  else if CloudPcShowType = VstCloudPcShowType_All then
    MiCloudPc := MiCloudPc_All;

  // �Ľ���
  for i := 0 to PmCloudPc.Items.Count - 1 do
  begin
    mi := PmCloudPc.Items[i];
    if i = MiCloudPc then
    begin
      mi.ImageIndex := PmRemoteNetworkIcon_Selected;
      tbtnCloudShowType.Caption := mi.Caption;
      tbtnCloudShowType.Hint := mi.Hint;
    end
    else
      mi.ImageIndex := -1;
  end;

  VstCloudPc_ShowType := CloudPcShowType;
end;

procedure TfrmMainForm.ResetFileSendDesVisible;
var
  Node: PVirtualNode;
  NodeData: PVstFileTransferDesData;
  IsExistPc : Boolean;
begin
  Node := vstFileTransferDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := vstFileTransferDes.GetNodeData(Node);
    if VstFileSendDes_IsOnlyOnline then
    begin
      if not NodeData.IsOnline then
        vstFileTransferDes.IsVisible[Node] := False;
    end
    else if not NodeData.IsOnline then
      vstFileTransferDes.IsVisible[Node] := True;
    Node := Node.NextSibling;
  end;
  vstFileTransferDes.Refresh;

    // ������ Pc
  IsExistPc := vstFileTransferDes.VisibleCount > 0;
  VstSelectSendPcUtil.ResetVisiblePc( IsExistPc );
end;

procedure TfrmMainForm.ResetIsOnlyShowOnlne(IsOnlyOnline: Boolean);
var
  SelectItem, UnSelectItem: TMenuItem;
begin
  if IsOnlyOnline then
  begin
    SelectItem := tiFileSendDesOnline;
    UnSelectItem := tiFileSendDesAll;
    VstFileSendDes_IsOnlyOnline := True;
  end
  else
  begin
    SelectItem := tiFileSendDesAll;
    UnSelectItem := tiFileSendDesOnline;
    VstFileSendDes_IsOnlyOnline := False;
  end;

  SelectItem.ImageIndex := PmRemoteNetworkIcon_Selected;
  UnSelectItem.ImageIndex := -1;
  tbtnFileSendOnline.Caption := SelectItem.Caption;
  tbtnFileSendOnline.Hint := SelectItem.Hint;
end;

procedure TfrmMainForm.ResetSelectSendPcVisible;
var
  VstSelectSendPc : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstSelectSendPcData;
  IsExistPc : Boolean;
begin
  VstSelectSendPc := frmSelectTransfer.VstSelectSendPc;
  Node := VstSelectSendPc.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := VstSelectSendPc.GetNodeData(Node);
    if VstFileSendDes_IsOnlyOnline then
    begin
      if not NodeData.IsOnline then
        VstSelectSendPc.IsVisible[Node] := False;
    end
    else if not NodeData.IsOnline then
      VstSelectSendPc.IsVisible[Node] := True;
    Node := Node.NextSibling;
  end;
  VstSelectSendPc.Refresh;
end;

procedure TfrmMainForm.btnBackupMyFileClick(Sender: TObject);
begin
  tbtnBackupNow.Enabled := False;
  MyBackupFileControl.BackupNow;
end;

procedure TfrmMainForm.btnSearchClick(Sender: TObject);
begin
  btnSearch.Enabled := False;

  // ֹͣ����
  if btnSearch.Tag = Tag_Searching then
  begin
    MyFileSearchControl.SearchFileStop;
    Exit;
  end;

  // ��� ����Ϣ
  lvSearchFile.Clear;

  // ��ʼ ����
  MyFileSearchControl.SearchFileStart;
end;

procedure TfrmMainForm.Button1Click(Sender: TObject);
begin
  peCloudStatus.AddPie(21, '10 GB Cloud Used Space', clBlue);
  peCloudStatus.AddPie(45, '20 GB Cloud Space Available to My Backups', clFuchsia);
  peCloudStatus.AddPie(33, '30 GB My Available Space', clGreen);
end;

procedure TfrmMainForm.btnConnNowClick(Sender: TObject);
begin
  MyNetworkControl.RestartNetwork;
end;

procedure TfrmMainForm.cbbOnlinePcExit(Sender: TObject);
begin
  if cbbOnlinePc.ItemIndex < 0 then
    cbbOnlinePc.ItemIndex := 0;
end;

procedure TfrmMainForm.cbbOwnerExit(Sender: TObject);
begin
  if cbbOwner.ItemIndex < 0 then
    cbbOwner.ItemIndex := 0;
end;

procedure TfrmMainForm.ClearTsVirRootNode(RootID: string);
var
  RootNode: PVirtualNode;
  RootData: PTransferData;
begin
  RootNode := vstTransStatus.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    RootData := vstTransStatus.GetNodeData(RootNode);
    if RootData.NodeID = RootID then
    begin
      vstTransStatus.DeleteChildren(RootNode);
      RootData.FileSize := 0;
      RootData.ChildCount := 0;
      Break;
    end;
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tiComputerInfoClick(Sender: TObject);
begin
  VstCloudComputerUtil.ShowComputerInfo;
  ResetCloudColShowType( False );
end;

procedure TfrmMainForm.Connectacomputer1Click(Sender: TObject);
begin
  frmConnComputer.ShowConnToPc;
end;

procedure TfrmMainForm.ContactUs1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.ContactUs);
end;

procedure TfrmMainForm.CreateForm;
begin
  frmRegisterNew := TfrmRegisterNew.Create(nil);
  frmSelectBackupPath := TfrmSelectBackupPath.Create(Self);
  frmRestore := TfrmRestore.Create(Self);
  frmSelectLocalBackupPath := TfrmSelectLocalBackupPath.Create(Self);
  FrmLocalBackupPro := TFrmLocalBackupPro.Create(Self);
  frmShareExplorer := TfrmShareExplorer.Create(Self);
end;

procedure TfrmMainForm.createparams(var params: tcreateparams);
begin
  inherited createparams(params);
  if App_RunWay = AppRunWay_FolderTransfer then
    params.WinClassName := AppName_FolderTransfer
  else
    params.WinClassName := AppName_FileCloud;
end;

procedure TfrmMainForm.CreateRegister;
begin
  // ��ȡ ע����Ϣ
  RegisterInfo := TRegisterInfo.Create;
  RegisterInfo.FirstLoadLicense;
  AppExpiredCheckThread := TAppExpiredCheckThread.Create;
  AppExpiredCheckThread.Resume;
end;

procedure TfrmMainForm.DestoryForm;
begin
  ComboboxUtil.ClearData(cbbOnlinePc);
  ComboboxUtil.ClearData(cbbOwner);
end;

procedure TfrmMainForm.DestroyRegister;
begin
  AppExpiredCheckThread.Free;
  RegisterInfo.Free;
  frmRegisterNew.Free;
end;

procedure TfrmMainForm.DropFiles(var Msg: TMessage);
var
  DropFileHandle: TDropFileHandle;
begin
  DropFileHandle := TDropFileHandle.Create(Msg);
  DropFileHandle.Update;
  DropFileHandle.Free;
end;

procedure TfrmMainForm.edtSearchFileNameEnter(Sender: TObject);
begin
  if edtSearchFileName.Text <> frmMainForm.siLang_frmMainForm.GetText( 'SearchTips' ) then
    Exit;

  edtSearchFileName.Clear;
  edtSearchFileName.Font.Color := clWindowText;
end;

procedure TfrmMainForm.edtSearchFileNameExit(Sender: TObject);
begin
  if edtSearchFileName.Text <> '' then
    Exit;

  edtSearchFileName.Font.Color := clInactiveCaptionText;
  edtSearchFileName.Text := frmMainForm.siLang_frmMainForm.GetText( 'SearchTips' );
end;

procedure TfrmMainForm.edtSearchFileNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and btnSearch.Enabled and
    (btnSearch.Tag = Tag_NoSearch) then
    btnSearch.Click;
end;

procedure TfrmMainForm.English1Click(Sender: TObject);
var
  mi : TMenuItem;
begin
  mi := Sender as TMenuItem;
  siLangDispatcherMain.ActiveLanguage := mi.Tag;
end;

procedure TfrmMainForm.Enteragroup1Click(Sender: TObject);
begin
  frmJoinGroup.ShowJobaGroup;
end;

procedure TfrmMainForm.Exit1Click(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  tbtnExit.Click;
end;

procedure TfrmMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not App_IsExit then
  begin
    CanClose := False;
    HideMainForm;
  end;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
begin
  MyIcon := TMyIcon.Create;
  frmSetting := TfrmSetting.Create(Self);
  frmAbout := TfrmAbout.Create(Self);
  frmFreeEdition := TfrmFreeEdition.Create(Self);
  frmSelectTransfer := TfrmSelectTransfer.Create( Self );
  ResetAppWay; // �汾�仯
  MyIcon.SaveMyIcon;
  tiApp.Visible := True;
  LoadMainFormIni;
  IniChart;
  siLang_frmMainFormChangeLanguage(nil);
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  try
    AppPiracyCheckThread.Free;
    SaveMainFormIni;
    BackupCow.Free;
    MyIcon.Free;
    DestoryForm;
    DestroyRegister;
  except
  end;
end;

procedure TfrmMainForm.HideMainForm;
begin
  ShowWindow(Self.Handle, SW_HIDE);
end;

procedure TfrmMainForm.HomePage1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb(MyUrl.getHome);
end;

procedure TfrmMainForm.BackupCow1Click(Sender: TObject);
begin
  MyInternetExplorer.OpenWeb( Url_BackuCowHome );
end;

procedure TfrmMainForm.IniCbbSearch;
var
  NewItem: TCbbSearchData;
begin
  // Location
  with cbbOnlinePc.ItemsEx.Add do
  begin
    Caption := siLang_frmMainForm.GetText( 'StrAllPc' );
    ImageIndex := CloudStatusIcon_Online;
    NewItem := TCbbSearchData.Create('');
    Data := NewItem;
  end;
  cbbOnlinePc.ItemIndex := 0;

  // Owner
  with cbbOwner.ItemsEx.Add do
  begin
    Caption := siLang_frmMainForm.GetText( 'StrAllPc' );
    ImageIndex := CloudStatusIcon_Online;
    NewItem := TCbbSearchData.Create('');
    Data := NewItem;
  end;
  cbbOwner.ItemIndex := 0;

  // FileType
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'AllType' ));
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'SourceFile' ));
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'BackupCopy' ));
  cbbFileType.ItemIndex := 0;
end;

procedure TfrmMainForm.IniChart;
begin
  peCloudStatus.Clear;
  vlCloudTotal.Strings.Clear;
end;

function TfrmMainForm.getVstBackupItemPercentage(Node: PVirtualNode): Integer;
var
  RootNode: PVirtualNode;
  RootData, NodeData: PVstBackupItemData;
  TotalSpace: Int64;
begin
  RootNode := Node;
  while RootNode.Parent <> vstBackupItem.RootNode do
    RootNode := RootNode.Parent;
  RootData := vstBackupItem.GetNodeData(RootNode);
  NodeData := vstBackupItem.GetNodeData(Node);

  TotalSpace := RootData.CopyCount * NodeData.ItemSize;
  Result := MyPercentage.getPercent(NodeData.CompletedSpace, TotalSpace);
end;

function TfrmMainForm.getVstIsSelectRoot(vst: TVirtualStringTree): Boolean;
var
  RootNode: PVirtualNode;
begin
  Result := False;
  RootNode := vst.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    // ɾ�� ѡ�е�
    if vsSelected in RootNode.States then
    begin
      Result := True;
      Break;
    end;
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TfrmMainForm.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  frmFreeEdition.ShowInfomation;
end;

procedure TfrmMainForm.LoadMainFormIni;
var
  NbMainPage: Integer;
  IsBackup, IsFileSendDesOnlyOnline: Boolean;
  CloudPcShowType: string;
  iniFile: TIniFile;
  i: Integer;
  tb: TRzToolButton;
begin
  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  NbMainPage := iniFile.ReadInteger(frmMainForm.Name, PcMain.Name,DefaultPage_MainForm);
  PcBackup.ActivePageIndex := iniFile.ReadInteger(frmMainForm.Name,PcBackup.Name, 0);
  PcFileTransfer.ActivePageIndex := iniFile.ReadInteger(frmMainForm.Name,PcFileTransfer.Name, 0);
  PcFileShare.ActivePageIndex := iniFile.ReadInteger(frmMainForm.Name,PcFileShare.Name, 0);

  IsFileSendDesOnlyOnline := iniFile.ReadBool(frmMainForm.Name,tbtnFileSendOnline.Name, True);
  CloudPcShowType := iniFile.ReadString(frmMainForm.Name,tbtnCloudShowType.Name, VstCloudPcShowType_Online);
  FolderPath_SelectDefault := iniFile.ReadString(frmMainForm.Name,Section_SaveAsPath, '');
  iniFile.Free;

  NbNoPcTransferFile.PageIndex := PcFileTransfer.ActivePageIndex;

  if NbMainPage = NbPage_LocalFileStatus then
    tbtnLocalBackup.Enabled := True
  else
  if NbMainPage = NbPage_FileStatus then
    tbtnBackup.Down := True
  else
  if NbMainPage = NbPage_FileTransfer then
    tbtnFileTransfer.Down := True
  else
  if NbMainPage = NbPage_FileShare then
    tbtnFileShare.Down := True
  else if NbMainPage = NbPage_TransferStatus then
    tbtnTransStatus.Down := True
  else
  begin
    NbMainPage := NbMainPage;
    tbtnBackup.Down := True;
  end;
  PcMain.ActivePageIndex := NbMainPage;


  // FileTransfer Pc Show
  ResetIsOnlyShowOnlne(IsFileSendDesOnlyOnline);

  // Cloud Pc ShowType
  ResetCloudPcShowType(CloudPcShowType);
end;

procedure TfrmMainForm.Log1Click(Sender: TObject);
begin
  Form12.Show;
end;

procedure TfrmMainForm.lvCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvCloudTotalDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvFileStatusChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  tbtnFsLvlRemove.Enabled := lvFileStatus.SelCount > 0;
end;

procedure TfrmMainForm.lvFileStatusDblClick(Sender: TObject);
begin
  if tbtnFsDetail.Enabled then
    tbtnFsDetail.Click
  else if tbtnFsOpen.Enabled then
    tbtnFsOpen.Click;
end;

procedure TfrmMainForm.lvFileStatusDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvFileStatusKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    if tbtnFsDetail.Enabled then
      tbtnFsDetail.Click
    else if tbtnFsOpen.Enabled then
      tbtnFsOpen.Click;
  end;

  MyKeyBorad.CheckDelete( tbtnFsLvlRemove, Key );
end;

procedure TfrmMainForm.lvFileStatusSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  SelectData: TBackupLvFaceData;
  IsShowPro, IsShowOpen: Boolean;
begin
  IsShowPro := False;
  IsShowOpen := False;
  if Selected then
  begin
    SelectData := Item.Data;
    IsShowOpen := SelectData.IsFolder;
    IsShowPro := not IsShowOpen;
  end;

  tbtnFsDetail.Enabled := IsShowPro;
  tbtnFsOpen.Enabled := IsShowOpen;
  tbtnFsLvlExplorer.Enabled := Selected;
end;

procedure TfrmMainForm.lvLocalBackupSourceChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  tbtnLocalBackupRemove.Enabled := VstLocalBackupSource.SelectedCount > 0;
  tbtnLocalBackupExplorer.Enabled := VstLocalBackupSource.SelectedCount = 1;
end;

procedure TfrmMainForm.lvLocalBackupSourceDblClick(Sender: TObject);
begin
  if tbtnLocalBackupExplorer.Enabled then
    tbtnLocalBackupExplorer.Click;
end;

procedure TfrmMainForm.lvLocalBackupSourceDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvLocalBackupSourceMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
begin
  SelectNode := VstLocalBackupSource.GetNodeAt( X, Y );
  if Assigned( SelectNode ) then
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    VstLocalBackupSource.Hint := SelectData.FullPath;
  end
  else
    VstLocalBackupSource.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
end;

procedure TfrmMainForm.lvMyCloudPcDblClick(Sender: TObject);
var
  ItemData: TMyBackupCloudLvData;
begin
  if lvMyCloudPc.Selected = nil then
    Exit;
  ItemData := lvMyCloudPc.Selected.Data;
  MyNetworkControl.ShowPcDetail(ItemData.PcID);
end;

procedure TfrmMainForm.lvMyCloudPcDeletion(Sender: TObject; Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyDestinationDblClick(Sender: TObject);
begin
  if tbtnBackupDesExplorer.Enabled then
    tbtnBackupDesExplorer.Click;
end;

procedure TfrmMainForm.lvMyDestinationDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyFileReceiveChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  SelectCount: Integer;
begin
  SelectCount := lvMyFileReceive.SelCount;

  tbtnReceiveRemove.Enabled := SelectCount > 0;
  tbtnReceiveExplorer.Enabled := SelectCount = 1;
end;

procedure TfrmMainForm.lvMyFileReceiveDblClick(Sender: TObject);
begin
  if tbtnReceiveExplorer.Enabled then
    tbtnReceiveExplorer.Click;
end;

procedure TfrmMainForm.lvMyFileReceiveDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData: TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmMainForm.lvMyFileReceiveKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnReceiveRemove, tbtnReceiveExplorer, Key );
end;

procedure TfrmMainForm.lvMyFileReceiveMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectItem : TListItem;
  ItemData : TLvFileReceiveData;
  HintStr : string;
begin
  SelectItem := lvMyFileReceive.GetItemAt( x, y );
  if SelectItem <> nil then
  begin
    ItemData := SelectItem.Data;
    HintStr := 'Send File Path: ' + ItemData.SourceFilePath + #13#10;
    HintStr := HintStr + 'Receive File Path: ' + ItemData.ReceivePath;
  end
  else
    HintStr := '';
  lvMyFileReceive.Hint := HintStr;
end;

procedure TfrmMainForm.LvNetworkDblClick(Sender: TObject);
var
  SelectItem: TListItem;
  ItemData: TNetworkPcItemData;
begin
  SelectItem := LvNetwork.Selected;
  if SelectItem = nil then
    Exit;
  ItemData := SelectItem.Data;
  MyNetworkControl.ShowPcDetail(ItemData.PcID);
end;

procedure TfrmMainForm.LvNetworkDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.LvNetworkMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  ListItem: TListItem;
  ItemData: TNetworkPcItemData;
  PcID: string;
begin
  frmMainForm.LvNetwork.ShowHint := False;
  ListItem := frmMainForm.LvNetwork.GetItemAt(X, Y);
  if ListItem = nil then
    Exit;
  ItemData := ListItem.Data;
  PcID := ItemData.PcID;
  MyNetworkControl.ShowPcHint(PcID);
end;

procedure TfrmMainForm.LvNetworkSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  tbtnNetworkPcProperties.Enabled := Selected;
end;

procedure TfrmMainForm.lvSearchDownloadDblClick(Sender: TObject);
begin
  if tbtnSearchDownExplorer.Enabled then
    tbtnSearchDownExplorer.Click;
end;

procedure TfrmMainForm.lvSearchDownloadDeletion(Sender: TObject;
  Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchFileDblClick(Sender: TObject);
begin
  if tbtnSfExplorer.Enabled then
    tbtnSfExplorer.Click
  else if tbtnSfSaveas.Enabled then
    tbtnSfSaveas.Click;
end;

procedure TfrmMainForm.lvSearchFileDeletion(Sender: TObject; Item: TListItem);
var
  Data: TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmMainForm.lvSearchFileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not ( Key = VK_RETURN ) then
    Exit;

  if tbtnSfExplorer.Enabled then
    tbtnSfExplorer.Click
  else if tbtnSfSaveas.Enabled then
    tbtnSfSaveas.Click;
end;

procedure TfrmMainForm.lvSearchFileSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  IsShowExlporer: Boolean;
  ItemData: TSearchFileLvData;
  LocationID: string;
begin
  // �򿪱����ļ�
  IsShowExlporer := False;
  if Selected then
  begin
    ItemData := Item.Data;
    LocationID := ItemData.LocationID;
    if LocationID = Network_LocalPcID then
      IsShowExlporer := lvSearchFile.SelCount = 1;
  end;

  tbtnSfExplorer.Enabled := IsShowExlporer;
  tbtnSfSaveas.Enabled := lvSearchFile.Selected <> nil;
end;

procedure TfrmMainForm.MainFormIni;
begin
  App_IsExit := False;
  DragAcceptFiles(Handle, True); // ������Ҫ�����ļ� WM_DROPFILES �Ϸ���Ϣ
  Application.HintHidePause := Time_ShowHint;
  MainFormHandle := Self.Handle;

  CreateRegister; // ע����Ϣ
  CreateForm; // ���� �Ӵ���
  BindSysItemIcon; // ϵͳͼ��
  BindToolbar; // ToolBar �� �ؼ��Ҽ� PopMenu
  BindSort; // ����
  BindDrogHint; // �϶��ļ�����
  IniChart; // ��ͼ
  IniCbbSearch; // All Computers
  AppUpgrade; // App Upgrade
  BindVstData; // Vst NodeData Size ��

  FormUtil.EnableToolbar(tbNetwork, False);
  FormUtil.EnableToolbar(tbFileSendDesNetwork, False);
  FormUtil.EnableToolbar(tbFileShareNetwork, False);
  FormUtil.EnableToolbar(tbRestoreNetwork, False);

  tbNetwork.Images := ilTbNw;
  tbFileSendDesNetwork.Images := ilTbNw;
  tbFileShareNetwork.Images := ilTbNw;
  tbRestoreNetwork.Images := ilTbNw;

  BackupCow := TBackupCow.Create;

  // ������ �汾��Ϣ
  RefreshRegisterEdition;

  // ������
  AppPiracyCheckThread := TAppPiracyCheckThread.Create;
  AppPiracyCheckThread.Resume;
end;

procedure TfrmMainForm.MenuItem1Click(Sender: TObject);
var
  i: Integer;
  FilePath: string;
  LocalBackupSourceList : TStringList;
  AddLocalBackupSourceHandle : TAddLocalBackupSourceDefaultHandle;
begin
  if not FileDialog.Execute then
    Exit;

  LocalBackupSourceList := MyStringList.getStrings( FileDialog.Files );

  AddLocalBackupSourceHandle := TAddLocalBackupSourceDefaultHandle.Create( LocalBackupSourceList );
  AddLocalBackupSourceHandle.Update;
  AddLocalBackupSourceHandle.Free;

  LocalBackupSourceList.Free;
end;

procedure TfrmMainForm.MenuItem2Click(Sender: TObject);
var
  ShowStr : string;
  LocalSourceList : TStringList;
  AddLocalBackupSourceHandle : TAddLocalBackupSourceDefaultHandle;
begin
  ShowStr := siLang_frmMainForm.GetText( 'StrSelectBackupFolder' );

  // ѡ��Ŀ¼
  if not MySelectFolderDialog.SelectNormal(ShowStr, '',
    FolderPath_SelectDefault)
  then
    Exit;

  LocalSourceList := MyStringList.getString( FolderPath_SelectDefault );

  AddLocalBackupSourceHandle := TAddLocalBackupSourceDefaultHandle.Create( LocalSourceList );
  AddLocalBackupSourceHandle.Update;
  AddLocalBackupSourceHandle.Free;

  LocalSourceList.Free;
end;

procedure TfrmMainForm.MenuItem3Click(Sender: TObject);
var
  ItemData: TMyBackupCloudLvData;
begin
  if lvMyCloudPc.Selected = nil then
    Exit;
  ItemData := lvMyCloudPc.Selected.Data;
  MyNetworkControl.ShowPcDetail(ItemData.PcID);
end;

procedure TfrmMainForm.restorerequest(var Msg: TMessage);
begin
  if not App_IsExit then
    ShowMainForm;
end;

procedure TfrmMainForm.SaveMainFormIni;
var
  iniFile: TIniFile;
begin
  iniFile := TIniFile.Create(MyIniFile.getIniFilePath);
  iniFile.WriteInteger(frmMainForm.Name, PcMain.Name, PcMain.ActivePageIndex);
  iniFile.WriteInteger(frmMainForm.Name, PcBackup.Name,PcBackup.ActivePageIndex);
  iniFile.WriteInteger(frmMainForm.Name, PcFileTransfer.Name,PcFileTransfer.ActivePageIndex);
  iniFile.WriteInteger(frmMainForm.Name, PcFileShare.Name,PcFileShare.ActivePageIndex);

  iniFile.WriteBool(frmMainForm.Name, tbtnFileSendOnline.Name,VstFileSendDes_IsOnlyOnline);
  iniFile.WriteString(frmMainForm.Name, tbtnCloudShowType.Name,VstCloudPc_ShowType);

  iniFile.WriteString(frmMainForm.Name, Section_SaveAsPath,FolderPath_SelectDefault);
  iniFile.Free;
end;

procedure TfrmMainForm.SearchPcFile(OwnerID: string);
var
  i: Integer;
  ItemData: TCbbSearchData;
begin
  // Page
  tbtnBackup.Down := True;
  tbtnBackup.Click;
  PcBackup.ActivePage := tsFileSearch;

  // Owner
  for i := 0 to cbbOwner.ItemsEx.Count - 1 do
  begin
    ItemData := cbbOwner.ItemsEx.Items[i].Data;
    if ItemData.PcID = OwnerID then
    begin
      cbbOwner.ItemIndex := i;
      Break;
    end;
  end;

  // Location
  cbbOnlinePc.ItemIndex := 0;

  // Type
  cbbFileType.ItemIndex := CbbSearchType_BackupCopy;

  // ��ʼ ����
  if btnSearch.Enabled then
    btnSearch.Click;
end;

procedure TfrmMainForm.ShowMainForm;
begin
  if not Self.Visible then
    Self.Visible := True;
  ShowWindow(Self.Handle, SW_RESTORE);
  SetForegroundWindow(Self.Handle);
end;

procedure TfrmMainForm.siLang_frmMainFormChangeLanguage(Sender: TObject);
var
  Node : PVirtualNode;
  NodeData : PTransferData;
  j : Integer;
begin
  with VstLocalBackupSource.Header do
  begin
    Columns[ VstLocalBackupSource_ItemPath ].Text := siLang_frmMainForm.GetText( 'lvItemPath' );
    Columns[ VstLocalBackupSource_FileSize ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstLocalBackupSource_FileCount ].Text := siLang_frmMainForm.GetText( 'lvFiles' );
    Columns[ VstLocalBackupSource_LastSync ].Text := siLang_frmMainForm.GetText( 'lvNextSync' );
    Columns[ VstLocalBackupSource_FileStatus ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with VstLocalBackupDes.Header do
  begin
    Columns[ VstLocalBackupDes_FilePath ].Text := siLang_frmMainForm.GetText( 'lvDirectory' );
    Columns[ VstLocalBackupDes_FileSize ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstLocalBackupDes_FileStatus ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with vstBackupItem.Header do
  begin
    Columns[ VstBackupItem_FullPath ].Text := siLang_frmMainForm.GetText( 'lvItemPath' );
    Columns[ VstBackupItem_FileCount ].Text := siLang_frmMainForm.GetText( 'lvFiles' );
    Columns[ VstBackupItem_Size ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstBackupItem_NextSync ].Text := siLang_frmMainForm.GetText( 'lvNextSync' );
    Columns[ VstBackupItem_Status ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with lvFileStatus do
  begin
    Columns[ 0 ].Caption := siLang_frmMainForm.GetText( 'lvFileName' );
    Columns[ LvFileStatus_FileSize + 1 ].Caption := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ LvFileStatus_FileTime + 1 ].Caption := siLang_frmMainForm.GetText( 'lvFileDate' );
    Columns[ LvFileStatus_CopyCount + 1 ].Caption := siLang_frmMainForm.GetText( 'CopyQty' );
    Columns[ LvFileStatus_BackupStatus + 1 ].Caption := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with vstRestoreDown.Header do
  begin
    Columns[ VstRestoreDown_FileName ].Text := siLang_frmMainForm.GetText( 'lvRestoreItem' );
    Columns[ VstRestoreDown_Owner ].Text := siLang_frmMainForm.GetText( 'Owner' );
    Columns[ VstRestoreDown_FileSize ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstRestoreDown_Percentage ].Text := siLang_frmMainForm.GetText( 'lvPercentage' );
    Columns[ VstRestoreDown_Status ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with lvSearchFile do
  begin
    Columns[ 0 ].Caption := siLang_frmMainForm.GetText( 'FileName' );
    Columns[ 1 ].Caption := siLang_frmMainForm.GetText( 'Owner' );
    Columns[ 2 ].Caption := siLang_frmMainForm.GetText( 'lvBackupPath' );
    Columns[ 3 ].Caption := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ 4 ].Caption := siLang_frmMainForm.GetText( 'lvFileDate' );
    Columns[ 5 ].Caption := siLang_frmMainForm.GetText( 'lvType' );
    Columns[ 6 ].Caption := siLang_frmMainForm.GetText( 'lvLocation' );
  end;

  with vstSearchDown.Header do
  begin
    Columns[ VstSearchDown_FileName ].Text := siLang_frmMainForm.GetText( 'lvFileName' );
    Columns[ VstSearchDown_FileOwner ].Text := siLang_frmMainForm.GetText( 'Owner' );
    Columns[ VstSearchDown_FileSize ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstSearchDown_FileFrom ].Text := siLang_frmMainForm.GetText( 'lvDownloadFrom' );
    Columns[ VstSearchDown_Percentage ].Text := siLang_frmMainForm.GetText( 'lvPercentage' );
    Columns[ VstSearchDown_Status ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
  end;

  with vstCloudPc.Header do
  begin
    Columns[ vstCloudPc_PcName ].Text := siLang_frmMainForm.GetText( 'lvPcName' );
    Columns[ vstCloudPc_TotalSpace ].Text := siLang_frmMainForm.GetText( 'TotalShare' );
    Columns[ vstCloudPc_UsedSpace ].Text := siLang_frmMainForm.GetText( 'lvUseSpace' );
    Columns[ vstCloudPc_AvailableSpace ].Text := siLang_frmMainForm.GetText( 'CloudConsumption' );
    Columns[ vstCloudPc_BackupSpace ].Text := siLang_frmMainForm.GetText( 'lvAvailableSpace' );
    Columns[ vstCloudPc_Status ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
    Columns[ vstCloudPc_LastOnlineTime ].Text := siLang_frmMainForm.GetText( 'lvLastOnline' );
    Columns[ vstCloudPc_Reachable ].Text := siLang_frmMainForm.GetText( 'Reachable' );
    Columns[ vstCloudPc_Position ].Text := siLang_frmMainForm.GetText( 'lvPosition' );
  end;

  with vlCloudTotal do
  begin
    TitleCaptions.Clear;
    TitleCaptions.Add( siLang_frmMainForm.GetText( 'lvDiscription' ) );
    TitleCaptions.Add( siLang_frmMainForm.GetText( 'lvValue' ) );
  end;

  with vstTransStatus.Header do
  begin
    Columns[ VstTransStatus_FileName ].Text := siLang_frmMainForm.GetText( 'FileName' );
    Columns[ VstTransStatus_Location ].Text := siLang_frmMainForm.GetText( 'lvLocation' );
    Columns[ VstTransStatus_FileSize ].Text := siLang_frmMainForm.GetText( 'lvFileSize' );
    Columns[ VstTransStatus_Pecentage ].Text := siLang_frmMainForm.GetText( 'lvPercentage' );
    Columns[ VstTransStatus_Type ].Text := siLang_frmMainForm.GetText( 'lvTransferType' );
    Columns[ VstTransStatus_Status ].Text := siLang_frmMainForm.GetText( 'lvStatus' );
    Columns[ VstTransStatus_UsedTime ].Text := siLang_frmMainForm.GetText( 'UsedTime' );
    Columns[ VstTransStatus_Speed ].Text := siLang_frmMainForm.GetText( 'lvSpeed' );
    Columns[ VstTransStatus_RemianTime ].Text := siLang_frmMainForm.GetText( 'lvRemainTime' );
  end;

  Node := vstTransStatus.RootNode.FirstChild;
  while Assigned( Node ) do
  begin
    NodeData := vstTransStatus.GetNodeData( Node );
    NodeData.FileName := siLang_frmMainForm.GetText( NodeData.NodeID );
    vstTransStatus.RepaintNode( Node );
    Node := Node.NextSibling;
  end;

  j := cbbFileType.ItemIndex;
  cbbFileType.Items.Clear;
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'AllType' ));
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'SourceFile' ));
  cbbFileType.Items.Add(siLang_frmMainForm.GetText( 'BackupCopy' ));
  cbbFileType.ItemIndex := j;

  if cbbOwner.Items.Count >= 1 then
    cbbOwner.ItemsEx.Items[0].Caption := siLang_frmMainForm.GetText( 'StrAllPc' );

  if cbbOnlinePc.Items.Count >= 1 then
    cbbOnlinePc.ItemsEx.Items[0].Caption := siLang_frmMainForm.GetText( 'StrAllPc' );

  with LvNetwork do
  begin
    Columns[0].Caption := siLang_frmMainForm.GetText( 'LvNetworkPc' );
    Columns[LvNetwork_Upload + 1].Caption := siLang_frmMainForm.GetText( 'lvUpload' );
    Columns[LvNetwork_Download + 1].Caption := siLang_frmMainForm.GetText( 'lvDownload' );
  end;

  edtSearchFileName.Text := siLang_frmMainForm.GetText( 'SearchTips' );

    // Status Bar
  try
    if Assigned( RegisterInfo ) then
      sbEdition.Caption := RegisterInfo.getAppEditionDate;
  except
  end;
end;

procedure TfrmMainForm.tiSpaceInfoClick(Sender: TObject);
begin
  VstCloudComputerUtil.ShowSpaceInfo;
  ResetCloudColShowType( True );
end;

procedure TfrmMainForm.tbtnBackupSelectedClick(Sender: TObject);
var
  SelectPathList : TStringList;
  i : Integer;
begin
  SelectPathList := VstBackupItemUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
    MyBackupFileControl.BackupSelectFolder( SelectPathList[i] );
  SelectPathList.Free;
end;

procedure TfrmMainForm.tbtnBackupSelectedNewClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
begin
  SelectNode := VstBackup.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_LocalBackup then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.BackupSelectItem( ParentData.ItemID, NodeData.ItemID );
    end
    else
    if NodeData.NodeType = BackupNodeType_NetworkBackup then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.BackupSelectItem( ParentData.ItemID, NodeData.ItemID );
    end;
    SelectNode := VstBackup.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnClearUpErrorClick(Sender: TObject);
begin
  ClearTsVirRootNode(RootID_UpError);
  tbtnClearUpError.Enabled := False;
end;

procedure TfrmMainForm.tbtnCloudPcDetailClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  NodeData: PCloudPcData;
begin
  SelectNode := vstCloudPc.FocusedNode;
  if SelectNode = nil then
    Exit;

  NodeData := vstCloudPc.GetNodeData(SelectNode);
  MyNetworkControl.ShowPcDetail(NodeData.PcID);
end;

procedure TfrmMainForm.tbtnExitClick(Sender: TObject);
begin
  if App_IsExit then
    Exit;

  // ��ʾ�˳���ʾ
  if ApplicationSettingInfo.IsShowDialogBeforeExist then
  begin
    if frmExitConfirm.ShowModal <> mrYes then
      Exit;
  end;

  HideMainForm;

  App_IsExit := True;
  MyXmlSave.SaveNow;
  Close;
end;

procedure TfrmMainForm.tbtnSharePathExplorerClick(Sender: TObject);
var
  SelectData : PVstSharePathData;
begin
  if not Assigned( vstSharePath.FocusedNode ) then
    Exit;
  SelectData := vstSharePath.GetNodeData( vstSharePath.FocusedNode );
  MyExplore.OperFolder(SelectData.FullPath);
end;

procedure TfrmMainForm.tbtnFsLvlExplorerClick(Sender: TObject);
var
  FullPath: string;
begin
  FullPath := LvBackupFileUtil.getSelectPath;

  MyExplore.OperFolder( FullPath );
end;

procedure TfrmMainForm.tbtnFsLvlRemoveClick(Sender: TObject);
var
  SelectPathList : TStringList;
  i : Integer;
  SelectPath : string;
begin
    // ȷ��ɾ��
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmBackupRemove' )) then
    Exit;

    // ɾ��
  SelectPathList := LvBackupFileStatusUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    SelectPath := SelectPathList[i];
    if LvBackupFileStatusUtil.getIsFolder( SelectPath ) then
      MyBackupFileControl.FolderCancelBackup( SelectPath )
    else
      MyBackupFileControl.FileCancelBackup( SelectPath );
  end;
  SelectPathList.Free;

    // ˢ��
  MyBackupFileControl.ShowBackupFileStatusNomal( TvNodePath_Selected );
end;

procedure TfrmMainForm.tbtnFileSendDesAddClick(Sender: TObject);
var
  DesPcList: TStringList;
  Node: PVirtualNode;
  NodeData: PVstFileTransferDesData;
begin
  DesPcList := TStringList.Create;

  Node := vstFileTransferDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    if vsSelected in Node.States then
    begin
      NodeData := vstFileTransferDes.GetNodeData(Node);
      DesPcList.Add(NodeData.PcID);
    end;
    Node := Node.NextSibling;
  end;

  frmSelectTransfer.ShowSelectFiles(DesPcList);

  DesPcList.Free;
end;

procedure TfrmMainForm.tbtnFileSendOnlineClick(Sender: TObject);
begin
  tbtnFileSendOnline.Down := True;
  tbtnFileSendOnline.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnFileSendRemoteNetworkClick(Sender: TObject);
begin
  if tbtnFileSendRemoteNetwork.DropdownMenu = nil then
  begin
    MyMessageBox.ShowWarnning(ShowForm_RemoteForbid);
    Exit;
  end;

  tbtnFileSendRemoteNetwork.Down := True;
  tbtnFileSendRemoteNetwork.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnFsDeleteClick(Sender: TObject);
var
  SelectPathList : TStringList;
  i : Integer;
  RemovePath : string;
begin
    // ȷ��ɾ��
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmBackupRemove' )) then
    Exit;

    // ɾ��ѡ���
  SelectPathList := VstBackupItemUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    RemovePath := SelectPathList[i];
    if VstBackupItemUtil.IsRootPath( RemovePath ) then
      MyBackupFileControl.RemoveBackupPath( RemovePath )
    else
      MyBackupFileControl.FolderCancelBackup( RemovePath );
  end;
  SelectPathList.Free;
end;

procedure TfrmMainForm.tbtnFsDetailClick(Sender: TObject);
var
  FullPath: string;
begin
  FullPath := LvBackupFileUtil.getSelectPath;

  MyBackupFileControl.ShowBackupFileDetail(FullPath);
end;

procedure TfrmMainForm.tbtnFsExplorerClick(Sender: TObject);
var
  FullPath: string;
begin
  if not Assigned( vstBackupItem.FocusedNode ) then
    Exit;

  FullPath := VstBackupItemUtil.getNodeFullPath( vstBackupItem.FocusedNode );
  MyExplore.OperFolder(FullPath);
end;

procedure TfrmMainForm.tbtnNetworkMoreInfoClick(Sender: TObject);
begin
  tbtnBackup.Down := True;
  tbtnBackup.Click;
  PcBackup.ActivePage := tsCloudStatus;
  PcCloudStatus.ActivePage := tsCloudComputers;
end;

procedure TfrmMainForm.tbtnNetworkPcPropertiesClick(Sender: TObject);
var
  SelectItem: TListItem;
  ItemData: TNetworkPcItemData;
begin
  SelectItem := LvNetwork.Selected;
  if SelectItem = nil then
    Exit;
  ItemData := SelectItem.Data;
  MyNetworkControl.ShowPcDetail(ItemData.PcID);
end;

procedure TfrmMainForm.tbtnNetworkSelectBackupDesClick(Sender: TObject);
begin
  tbtnBackup.Down := True;
  tbtnBackup.Click;
  PcBackup.ActivePage := tsCloudStatus;
  PcCloudStatus.ActivePage := tsMyCloudComputers;
end;

procedure TfrmMainForm.tbtnNwLanClick(Sender: TObject);
begin
  frmSetting.pmLanNetworkClick(Sender);
end;

procedure TfrmMainForm.tbtnNwRemoveClick(Sender: TObject);
begin
  // ��֧�� Remote Network
  if tbtnNwRemove.DropdownMenu = nil then
  begin
    MyMessageBox.ShowWarnning(ShowForm_RemoteForbid);
    Exit;
  end;

  tbtnNwRemove.Down := True;
  tbtnNwRemove.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnFsOpenClick(Sender: TObject);
var
  SelectNode, ChildNode: PVirtualNode;
  SelectChildPath, ChildPath: string;
begin
    // Lv Backup Select Path
  SelectChildPath := LvBackupFileUtil.getSelectPath;

    // BackupItem Selected Node
  SelectNode := vstBackupItem.FocusedNode;
  if SelectNode = nil then
    Exit;

    // Ѱ��ѡ��Ľڵ�
  ChildNode := SelectNode.FirstChild;
  while Assigned(ChildNode) do
  begin
    ChildPath := VstBackupItemUtil.getNodeFullPath( ChildNode );
    if ChildPath = SelectChildPath then
    begin
      vstBackupItem.Selected[SelectNode] := False;
      vstBackupItem.FocusedNode := ChildNode;
      vstBackupItem.Selected[ChildNode] := True;

      Break;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnFsSelectFolderClick(Sender: TObject);
var
  BackupPathList : TStringList;
  AddBackupItemConfigHandle : TAddBackupItemConfigHandle;
  BackupConfigInfo : TBackupConfigInfo;
begin
    // ȡ��ѡ��
  if frmSelectBackupPath.ShowModal = mrCancel then
  begin
    frmSelectBackupPath.RemoveNewChecked;
    Exit;
  end;

  BackupPathList := frmSelectBackupPath.getNewSelectPathList;
  BackupConfigInfo := frmSelectBackupPath.getBackupConfigInfo;

    // ��� Backup Item
  AddBackupItemConfigHandle := TAddBackupItemConfigHandle.Create( BackupPathList );
  AddBackupItemConfigHandle.SetBackupConfigInfo( BackupConfigInfo );
  AddBackupItemConfigHandle.Update;
  AddBackupItemConfigHandle.Free;

  BackupConfigInfo.Free;
  BackupPathList.Free;
end;

procedure TfrmMainForm.tbtnFsVstDetailClick(Sender: TObject);
var
  SelectPath : string;
begin
  SelectPath := VstBackupItemUtil.getSelectPath;
  frmBackupProperties.ShowOptions( SelectPath );
  frmBackupProperties.Show;
end;

procedure TfrmMainForm.tbtnLocalBackupAddClick(Sender: TObject);
var
  LocalSourceList : TStringList;
  BackupConfig : TLocalBackupConfigInfo;
  AddLocalBackupSourceConfigHandle : TAddLocalBackupSourceConfigHandle;
begin
  if frmSelectLocalBackupPath.ShowModal = mrCancel then
  begin
    frmSelectLocalBackupPath.RemoveNewChecked;
    Exit;
  end;

  LocalSourceList := frmSelectLocalBackupPath.getNewSelectList;
  BackupConfig := frmSelectLocalBackupPath.getLocalBackupConfigInfo;

  AddLocalBackupSourceConfigHandle := TAddLocalBackupSourceConfigHandle.Create( LocalSourceList );
  AddLocalBackupSourceConfigHandle.SetConfig( BackupConfig );
  AddLocalBackupSourceConfigHandle.Update;
  AddLocalBackupSourceConfigHandle.Free;

  BackupConfig.Free;
  LocalSourceList.Free;
end;

procedure TfrmMainForm.tbtnLocalBackupExplorerClick(Sender: TObject);
var
  SelectData : PVstLocalBackupSourceData;
begin
  if not Assigned( VstLocalBackupSource.FocusedNode ) then
    Exit;
  SelectData := VstLocalBackupSource.GetNodeData( VstLocalBackupSource.FocusedNode );
  MyExplore.OperFolder(SelectData.FullPath);
end;

procedure TfrmMainForm.tbtnLocalBackupNowClick(Sender: TObject);
begin
  tbtnLocalBackupNow.Enabled := False;
  MyLocalBackupSourceControl.BackupNowClick;
end;

procedure TfrmMainForm.tbtnLocalBackupOptionsClick(Sender: TObject);
var
  SelectData : PVstLocalBackupSourceData;
begin
  if not Assigned( VstLocalBackupSource.FocusedNode ) then
    Exit;
  SelectData := VstLocalBackupSource.GetNodeData( VstLocalBackupSource.FocusedNode );
  FrmLocalBackupPro.RefreshShowOptions( SelectData.FullPath );
  FrmLocalBackupPro.Show;
end;

procedure TfrmMainForm.tbtnLocalBackupRemoveClick(Sender: TObject);
var
  SelectPathList, ChildPathList : TStringList;
  i , j : Integer;
  SelectPath : string;
begin
    // ɾ�� ȷ��
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmBackupRemove' )) then
    Exit;

  SelectPathList := VstLocalBackupSourceUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    SelectPath := SelectPathList[i];

      // ɾ�� Ŀ��Ŀ¼
    ChildPathList := MyLocalBackupSourceReadUtil.getDesPathList( SelectPath );
    for j := 0 to ChildPathList.Count - 1 do
      MyLocalBackupSourceControl.RemoveSourceDesPath( SelectPath, ChildPathList[j] );
    ChildPathList.Free;

    MyLocalBackupSourceControl.RemoveSourcePath( SelectPath );
  end;
  SelectPathList.Free;
end;

procedure TfrmMainForm.tbtnLocalBackupSelectedClick(Sender: TObject);
var
  SelectPathList : TStringList;
  i : Integer;
  SelectPath : string;
begin
  tbtnLocalBackupNow.Enabled := False;

  SelectPathList := VstLocalBackupSourceUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    SelectPath := SelectPathList[i];
    MyLocalBackupSourceControl.BackupSelected( SelectPath );
  end;
  SelectPathList.Free;
end;

procedure TfrmMainForm.tbtnMainFormClick(Sender: TObject);
begin
  PcMain.ActivePageIndex := (Sender as TRzToolButton).Tag;
end;

procedure TfrmMainForm.tbtnMyBackupDesPropertiesClick(Sender: TObject);
var
  NodeData : PVstMyBackupDesData;
begin
  if not Assigned( VstMyBackupDes.FocusedNode ) then
    Exit;

  NodeData := VstMyBackupDes.GetNodeData( VstMyBackupDes.FocusedNode );
  MyNetworkControl.ShowPcDetail( NodeData.PcID );
end;

procedure TfrmMainForm.tbtnMyCloudBackupClick(Sender: TObject);
begin
  VstMyBackupDestinationUtil.SetIsBackup( True );
end;

procedure TfrmMainForm.tbtnMyCloudDesSelectAllClick(Sender: TObject);
begin
  VstMyBackupDes.SelectAll( True );
end;

procedure TfrmMainForm.tbtnMyCloudNotBackupClick(Sender: TObject);
begin
  VstMyBackupDestinationUtil.SetIsBackup( False );
end;

procedure TfrmMainForm.tbtnReceiveClearClick(Sender: TObject);
var
  i: Integer;
  ItemData: TLvFileReceiveData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_ClearFileReceive) then
    Exit;

  for i := 0 to lvMyFileReceive.Items.Count - 1 do
  begin
    ItemData := lvMyFileReceive.Items[i].Data;

      // ɾ�� ����� ��ȡ ȡ����
    if ( ItemData.ReceiveStatus = ReceivePathStatus_Completed ) or
       ( ItemData.ReceiveStatus = ReceivePathStatus_Cancel )
    then
      MyFileTransferControl.RemoveReceiveFile( ItemData.SourceFilePath, ItemData.SourcePcID );
  end;
end;

procedure TfrmMainForm.tbtnReceiveExplorerClick(Sender: TObject);
var
  ItemData: TLvFileReceiveData;
begin
  if lvMyFileReceive.Selected = nil then
    Exit;

  ItemData := lvMyFileReceive.Selected.Data;
  MyExplore.OperFolder(ItemData.ReceivePath);
end;

procedure TfrmMainForm.tbtnReceiveRemoveClick(Sender: TObject);
var
  i: Integer;
  ItemData: TLvFileReceiveData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_RemoveFileRevceive) then
    Exit;

  for i := 0 to lvMyFileReceive.Items.Count - 1 do
  begin
    if not lvMyFileReceive.Items[i].Selected then
      Continue;
    ItemData := lvMyFileReceive.Items[i].Data;

    MyFileTransferControl.RemoveReceiveFile(ItemData.SourceFilePath,
      ItemData.SourcePcID);
  end;
end;

procedure TfrmMainForm.tbtnReceiveSettingsClick(Sender: TObject);
begin
  frmSetting.pcMain.ActivePage := frmSetting.tsFileTransfer;
  frmSetting.Show;
end;

procedure TfrmMainForm.tbtnSharePathRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstSharePathData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_RemoveSharePath) then
    Exit;

  SelectNode := vstSharePath.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSharePath.GetNodeData( SelectNode );
    MyFileShareControl.RemoveSharePath(SelectData.FullPath);
    SelectNode := vstSharePath.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnShowTypeClick(Sender: TObject);
begin
  tbtnShowType.Down := True;
  tbtnShowType.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnResetndClick(Sender: TObject);
var
  SendPathList, DesPcList : TStringList;
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  SendPathList := TStringList.Create;
  DesPcList := TStringList.Create;

  SelectNode := vstMyFileSend.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = vstMyFileSend.RootNode then
    begin
      SelectData := vstMyFileSend.GetNodeData( SelectNode );
      SendPathList.Clear;
      DesPcList.Clear;
      SendPathList.Add( SelectData.FilePath );
      DesPcList.Add( SelectData.DesID );
      MyFileTransferControl.AddSendFile( SendPathList, DesPcList );
    end;
    SelectNode := vstMyFileSend.GetNextSelected( SelectNode );
  end;

  DesPcList.Free;
  SendPathList.Free;
end;

procedure TfrmMainForm.tbtnRestoreAgainClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDownData;
  RestoreFileAgainHandle : TRestoreFileAgainHandle;
begin
    // ��ʼ����������
  lbSearching.Visible := True;
  lbFiles.Visible := True;
  lbSearching.Caption := frmMainForm.siLang_frmMainForm.GetText( 'Searching' );
  lbFiles.Caption := Format( frmMainForm.siLang_frmMainForm.GetText( 'SearchCount' ), [0] );
  RestoreFile_SearchCount := 0;

    // �ָ�����ѡ���
  SelectNode := vstRestoreDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = vstRestoreDown.RootNode then
    begin
      NodeData := vstRestoreDown.GetNodeData( SelectNode );
      RestoreFileAgainHandle := TRestoreFileAgainHandle.Create( NodeData.RestorePcID, NodeData.FullPath );
      RestoreFileAgainHandle.SetPathInfo( NodeData.PathType, NodeData.SaveAsPath );
      RestoreFileAgainHandle.Update;
      RestoreFileAgainHandle.Free;
    end;
    SelectNode := vstRestoreDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnRestoreExplorerClick(Sender: TObject);
var
  NodeData, ParentData : PVstRestoreData;
  NodeType, ExplorerPath : string;
begin
  if not Assigned( vstRestore.FocusedNode ) then
    Exit;
  NodeData := vstRestore.GetNodeData( vstRestore.FocusedNode );
  NodeType := NodeData.NodeType;
  if NodeType = RestoreNodeType_LocalDes then
    ExplorerPath := NodeData.ItemID
  else
  if NodeType = RestoreNodeType_LocalRestore then
  begin
    ParentData := vstRestore.GetNodeData( vstRestore.FocusedNode.Parent );
    ExplorerPath := MyFilePath.getPath( ParentData.ItemID ) + MyFilePath.getDownloadPath( NodeData.ItemID );
  end
  else
  if NodeType = RestoreNodeType_NetworkRestore then
  begin
    ExplorerPath := MyFilePath.getPath( MyCloudInfo.CloudPath );
    ExplorerPath := ExplorerPath + MyFilePath.getPath( NodeData.OwnerID );
    ExplorerPath := ExplorerPath + MyFilePath.getDownloadPath( NodeData.ItemID );
  end;
  MyExplore.OperFolder( ExplorerPath );
end;

procedure TfrmMainForm.tbtnRestoreMoreClick(Sender: TObject);
begin
  frmRestore.ReadRestorePcList;
  frmRestore.Show;
end;

procedure TfrmMainForm.tbtnRestoreRemoteClick(Sender: TObject);
begin
  // ��֧�� Remote Network
  if tbtnRestoreRemote.DropdownMenu = nil then
  begin
    MyMessageBox.ShowWarnning(ShowForm_RemoteForbid);
    Exit;
  end;

  tbtnRestoreRemote.Down := True;
  tbtnRestoreRemote.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnRestoreSpecificClick(Sender: TObject);
var
  NodeData : PVstRestorePcData;
begin
  if not Assigned( vstRestoreComputers.FocusedNode ) then
    Exit;

  frmRestore.Show;
  NodeData := vstRestoreComputers.GetNodeData( vstRestoreComputers.FocusedNode );
  frmRestore.RestorePc( NodeData.RestorePcID );
end;

procedure TfrmMainForm.tbtnTsClearDownedClick(Sender: TObject);
begin
  ClearTsVirRootNode(RootID_DownLoaded);
  tbtnTsClearDowned.Enabled := False;
end;

procedure TfrmMainForm.tbtnTsClearDownErrorClick(Sender: TObject);
begin
  ClearTsVirRootNode(RootID_DownError);
  tbtnTsClearDownError.Enabled := False;
end;

procedure TfrmMainForm.tbtnTsClearUpedClick(Sender: TObject);
begin
  ClearTsVirRootNode(RootID_UpLoaded);
  tbtnTsClearUped.Enabled := False;
end;

procedure TfrmMainForm.tbtnTsCollapseClick(Sender: TObject);
begin
  TsVirExpand(False);
end;

procedure TfrmMainForm.tbtnTsExpandClick(Sender: TObject);
begin
  TsVirExpand(True);
end;

procedure TfrmMainForm.tbtnTsExplorerClick(Sender: TObject);
var
  ItemData: PTransferData;
  FilePath: string;
begin
  ItemData := vstTransStatus.GetNodeData(vstTransStatus.FocusedNode);
  FilePath := ItemData.FilePath;
  MyExplore.OperFolder(FilePath);
end;

procedure TfrmMainForm.tiAppClick(Sender: TObject);
begin
  if App_IsExit then
    Exit;
  ShowMainForm;
end;

procedure TfrmMainForm.tiCloudPcShowClick(Sender: TObject);
var
  CloudPcShowType: string;
begin
  if Sender = tiCloudShowOnline then
    CloudPcShowType := VstCloudPcShowType_Online
  else if Sender = tiCloudShowMyBackup then
    CloudPcShowType := VstCloudPcShowType_MyBackup
  else if Sender = tiCloudShowOnlineAndMyBackup then
    CloudPcShowType := VstCloudPcShowType_OnlineAndMyBackup
  else if Sender = tiCloudShowAll then
    CloudPcShowType := VstCloudPcShowType_All;

  // ��ѡ��
  if CloudPcShowType = VstCloudPc_ShowType then
    Exit;

  ResetCloudPcShowType(CloudPcShowType);

  MyNetworkControl.RefreshOnlyShow;
end;

procedure TfrmMainForm.tbtnRdClearClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  NodeData: PVstRestoreDownData;
begin
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmClear' )) then
    Exit;

  SelectNode := vstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreDown.GetNodeData( SelectNode );
    if NodeData.CompletedSize >= NodeData.FileSize then
      MyRestoreControl.RemovePath( NodeData.RestorePcID, NodeData.FullPath );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnRdExplorerClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  NodeData: PVstRestoreDownData;
begin
  SelectNode := vstRestoreDown.FocusedNode;
  if SelectNode = nil then
    Exit;

  if SelectNode.Parent <> vstRestoreDown.RootNode then
    SelectNode := SelectNode.Parent;

  NodeData := vstRestoreDown.GetNodeData(SelectNode);
  MyExplore.OperFolder(NodeData.SaveAsPath);
end;

procedure TfrmMainForm.tbtnRdRemoveSelectedClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData : PVstRestoreDownData;
begin
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmRemove' )) then
    Exit;

  SelectNode := vstRestoreDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstRestoreDown.GetNodeData( SelectNode );
    if SelectNode.Parent = vstRestoreDown.RootNode then
      MyRestoreControl.RemovePath( NodeData.RestorePcID, NodeData.FullPath );
    SelectNode := vstRestoreDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnLocalCopyExplorerClick(Sender: TObject);
begin
  if Path_LocalCopyExplorer <> '' then
    MyExplore.OperFolder(Path_LocalCopyExplorer);
end;

procedure TfrmMainForm.tmrAppIniTimer(Sender: TObject);
begin
  tmrAppIni.Enabled := False;
  MainFormIni;
end;

procedure TfrmMainForm.tmrMultiHideTimer(Sender: TObject);
begin
  if SecondsBetween(Now, DropFileDes_HideStartTime) >= 2 then
  begin
    plFileTransferDesMulti.Visible := False;
    tmrMultiHide.Enabled := False;
  end;
end;

procedure TfrmMainForm.tbtnRestoreNowClick(Sender: TObject);
var
  NodeData : PVstRestorePcData;
  RestoreFileNowHandle : TRestoreFileNowHandle;
begin
  if not Assigned( vstRestoreComputers.FocusedNode ) then
    Exit;

    // ��ʼ����������
  MainFormUtil.IniRestoreNow;

    // �����ָ�����
  NodeData := vstRestoreComputers.GetNodeData( vstRestoreComputers.FocusedNode );
  RestoreFileNowHandle := TRestoreFileNowHandle.Create( NodeData.RestorePcID );
  RestoreFileNowHandle.Update;
  RestoreFileNowHandle.Free;
end;

procedure TfrmMainForm.tmrCheckExistPcTimer(Sender: TObject);
begin
  tmrCheckExistPc.Enabled := False;

    // File Share
  if VstShareFilePc.VisibleCount = 0 then
  begin
    PlNoSharePc.Visible := True;
    tbtnShareDownAdd.Enabled := False;
  end;

    // File Transfer
  if vstFileTransferDes.VisibleCount = 0 then
    VstSelectSendPcUtil.ResetVisiblePc( False );

    // File Backup
  if LvNetwork.Items.Count = 0 then
    plBackupFileNoPc.Visible := True;
end;

procedure TfrmMainForm.tmrDragBackgroundTimer(Sender: TObject);
var
  TreeOp : TStringTreeOptions;
begin
  tmrDragBackground.Enabled := False;

    // Network BackupItem
  if vstBackupItem.RootNodeCount = 0 then
  begin
    TreeOp := vstBackupItem.TreeOptions;
    TreeOp.PaintOptions := TreeOp.PaintOptions + [toShowBackground];
  end;

    // Local Backup Source
  if VstLocalBackupSource.RootNodeCount = 0 then
  begin
    TreeOp := VstLocalBackupSource.TreeOptions;
    TreeOp.PaintOptions := TreeOp.PaintOptions + [toShowBackground];
  end;

    // Local Backup Destination
  if VstLocalBackupDes.RootNodeCount = 0 then
  begin
    TreeOp := VstLocalBackupDes.TreeOptions;
    TreeOp.PaintOptions := TreeOp.PaintOptions + [toShowBackground];
  end;

    // File Send
  if vstMyFileSend.RootNodeCount = 0 then
  begin
    TreeOp := vstMyFileSend.TreeOptions;
    TreeOp.PaintOptions := TreeOp.PaintOptions + [toShowBackground];
  end;

    // File Share
  if vstSharePath.RootNodeCount = 0 then
  begin
    TreeOp := vstSharePath.TreeOptions;
    TreeOp.PaintOptions := TreeOp.PaintOptions + [toShowBackground];
  end;
end;

procedure TfrmMainForm.tbtnShareDownAddClick(Sender: TObject);
begin
  frmShareExplorer.Show;
  frmShareExplorer.SelectDefaultPc;
end;

procedure TfrmMainForm.tbtnShareDownClearClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  SelectData: PVstShareDownData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_ClearShareDown) then
    Exit;

  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned(SelectNode) do
  begin
    SelectData := VstShareDown.GetNodeData(SelectNode);
    // ɾ����ɵ�
    if SelectData.CompletedSize = SelectData.FileSize then
      MyFileShareControl.RemoveShareDown(SelectData.FullPath,
        SelectData.DesPcID);
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnShareDownExplorerClick(Sender: TObject);
var
  NodeData: PVstShareDownData;
begin
  if not Assigned(VstShareDown.FocusedNode) then
    Exit;

  NodeData := VstShareDown.GetNodeData(VstShareDown.FocusedNode);
  MyExplore.OperFolder(NodeData.SavePath);
end;

procedure TfrmMainForm.tbtnShareDownRemoveClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  SelectData: PVstShareDownData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_RemoveShareDown) then
    Exit;

  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned(SelectNode) do
  begin
    if VstShareDown.Selected[SelectNode] then
    begin
      // ɾ�� ���ڵ�
      SelectData := VstShareDown.GetNodeData(SelectNode);
      MyFileShareControl.RemoveShareDown(SelectData.FullPath,
        SelectData.DesPcID);
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnCloudShowTypeClick(Sender: TObject);
begin
  tbtnCloudShowType.Down := True;
  tbtnCloudShowType.CheckMenuDropdown;
end;

procedure TfrmMainForm.tbtnDownloadAgainClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  SelectNode := VstShareDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = VstShareDown.RootNode then
    begin
      SelectData := VstShareDown.GetNodeData( SelectNode );
      MyFileShareControl.AddShareDownAgain( SelectData.FullPath, SelectData.DesPcID, SelectData.SavePath, SelectData.PathType );
      MyFileShareControl.GetFileShareDown( SelectData.DesPcID, SelectData.FullPath );
    end;
    SelectNode := VstShareDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnDownPcShareClick(Sender: TObject);
var
  NodeData: PVstShareFilePcData;
begin
  if not Assigned(VstShareFilePc.FocusedNode) then
    Exit;
  NodeData := VstShareFilePc.GetNodeData(VstShareFilePc.FocusedNode);

  frmShareExplorer.Show;
  frmShareExplorer.SelectSharePc(NodeData.PcID, NodeData.PcName);
end;

procedure TfrmMainForm.tsCloudBackupMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if PcBackup.ShowHint then
    PcBackup.ShowHint := False;
end;

procedure TfrmMainForm.tsLocalBackupMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if PcBackup.ShowHint then
    PcBackup.ShowHint := False;
end;

procedure TfrmMainForm.tsShareDownMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if PcFileShare.ShowHint then
    PcFileShare.ShowHint := False;
end;

procedure TfrmMainForm.tsSharePathMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if PcFileShare.ShowHint then
    PcFileShare.ShowHint := False;
end;

procedure TfrmMainForm.tbtnSharePathAddClick(Sender: TObject);
begin
  frmSelectSharePath.Show;
end;

procedure TfrmMainForm.tbtnFileShareRemoteClick(Sender: TObject);
begin
  if tbtnFileShareRemote.DropdownMenu = nil then
  begin
    MyMessageBox.ShowWarnning(ShowForm_RemoteForbid);
    Exit;
  end;

  tbtnFileShareRemote.Down := True;
  tbtnFileShareRemote.CheckMenuDropdown;
end;


procedure TfrmMainForm.tbtnAddBackupSourceClick(Sender: TObject);
var
  SelectBackupItemHandle : TSelectBackupItemHandle;
begin
  SelectBackupItemHandle := TSelectBackupItemHandle.Create;
  SelectBackupItemHandle.Update;
  SelectBackupItemHandle.Free;
end;

procedure TfrmMainForm.tbtnBackupClearClick(Sender: TObject);
var
  RootNode: PVirtualNode;
  NodeData: PVstBackupItemData;
begin
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmBackupClear' )) then
    Exit;

  // ɾ�� ���и�Ŀ¼
  RootNode := vstBackupItem.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    NodeData := vstBackupItem.GetNodeData(RootNode);
    MyBackupFileControl.RemoveBackupPath(NodeData.FolderName);
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnBackupDesAddClick(Sender: TObject);
var
  ShowStr : string;
  AddLocalBackupDesHandle : TAddLocalBackupDesHandle;
begin
  ShowStr := siLang_frmMainForm.GetText( 'StrSelectDesFolder' );

  if not MySelectFolderDialog.Select(ShowStr,
                                     FolderPath_SelectDefault, FolderPath_SelectDefault)
  then
    Exit;

  AddLocalBackupDesHandle := TAddLocalBackupDesHandle.Create( FolderPath_SelectDefault );
  AddLocalBackupDesHandle.Update;
  AddLocalBackupDesHandle.Free;
end;

procedure TfrmMainForm.tbtnBackupDesExplorerClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  SelectData, RootData: PVstLocalBackupDesData;
  ExplorerPath: string;
begin
  SelectNode := VstLocalBackupDes.FocusedNode;
  if not Assigned(SelectNode) then
    Exit;

  SelectData := VstLocalBackupDes.GetNodeData(SelectNode);
  if SelectNode.Parent = VstLocalBackupDes.RootNode then
    ExplorerPath := SelectData.FullPath
  else
  begin
    RootData := VstLocalBackupDes.GetNodeData(SelectNode.Parent);
    if SelectData.IsDeleted then
      ExplorerPath := VstLocalBackupDesUtil.getRecyledPath( RootData.FullPath, SelectData.FullPath )
    else
      ExplorerPath := VstLocalBackupDesUtil.getDesSourcePath( RootData.FullPath, SelectData.FullPath );
  end;

  MyExplore.OperFolder(ExplorerPath);
end;

procedure TfrmMainForm.tbtnBackupDesRemoveClick(Sender: TObject);
var
  SelectPathList : TVstSelectPathList;
  ChildPathList : TStringList;
  i, j: Integer;
  RootPath, SelectPath : string;
begin
  // ɾ�� ȷ��
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmRemove' )) then
    Exit;

    // Ѱ�� ɾ����·��
  SelectPathList := VstLocalBackupDesUtil.getSelectPathList;
  for i := 0 to SelectPathList.Count - 1 do
  begin
    RootPath := SelectPathList[i].RootPath;
    SelectPath := SelectPathList[i].SelectPath;

      // ɾ�� Ŀ�� ��·��
    if RootPath = SelectPath then
    begin
      ChildPathList := VstLocalBackupDesUtil.getChildPathList( SelectPath );
      for j := 0 to ChildPathList.Count - 1 do
        MyLocalBackupSourceControl.RemoveSourceDesPath( ChildPathList[j], SelectPath );
      ChildPathList.Free;

            // ɾ�� Ŀ��·��
      MyLocalBackupDesControl.RemoveDesPath( SelectPath );
    end
    else   // ɾ�� ����·��
    if SelectPathList[i].IsDeleted then
      MyLocalBackupSourceControl.RemoveSourceDeletedPath( SelectPath, RootPath )
    else   // ɾ��Ŀ���Դ·��
      MyLocalBackupSourceControl.RemoveSourceDesPath( SelectPath, RootPath );

  end;
  SelectPathList.Free;
end;

procedure TfrmMainForm.tbtnBackupExplorerClick(Sender: TObject);
var
  ExplorerPath : string;
  NodeData : PVstBackupData;
begin
  if not Assigned( VstBackup.FocusedNode ) then
    Exit;

  NodeData := VstBackup.GetNodeData( VstBackup.FocusedNode );
  ExplorerPath := NodeData.ItemID;
  MyExplore.OperFolder( ExplorerPath );
end;

procedure TfrmMainForm.tbtnBackupRemoveClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
begin
  SelectNode := VstBackup.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_LocalDes then
      DesItemUserApi.RemoveItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = BackupNodeType_LocalBackup ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.RemoveItem( ParentData.ItemID, NodeData.ItemID );
    end
    else
    if NodeData.NodeType = BackupNodeType_NetworkDes then
      DesItemUserApi.RemoveItem( NodeData.ItemID )
    else
    if ( NodeData.NodeType = BackupNodeType_NetworkBackup ) and
         Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      BackupItemUserApi.RemoveItem( ParentData.ItemID, NodeData.ItemID );
    end;
    SelectNode := VstBackup.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.TsVirExpand(IsExpand: Boolean);
var
  RootNode: PVirtualNode;
  RootData: PTransferData;
begin
  RootNode := vstTransStatus.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    vstTransStatus.Expanded[RootNode] := IsExpand;
    RootData := vstTransStatus.GetNodeData(RootNode);
    RootData.IsExpand := IsExpand;
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnSdRemoveSelectedClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstSearchDownData;
begin
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmRemove' )) then
    Exit;

  SelectNode := vstSearchDown.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSearchDown.GetNodeData( SelectNode );
    MyFileSearchControl.RemoveSearchDown( SelectData.SourcePcID, SelectData.SourceFilePath );
    SelectNode := vstSearchDown.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnSearchDownClearClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstSearchDownData;
begin
  if not MyMessageBox.ShowConfirm(siLang_frmMainForm.GetText( 'ConfirmClear' )) then
    Exit;

  SelectNode := vstSearchDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSearchDown.GetNodeData( SelectNode );
    if SelectData.CompletedSize >= SelectData.FileSize then
      MyFileSearchControl.RemoveSearchDown( SelectData.SourcePcID, SelectData.SourceFilePath );
    SelectNode := SelectNode.NextSibling;
  end;

  tbtnSearchDownClear.Enabled := VstShareDown.RootNodeCount > 0;
end;

procedure TfrmMainForm.tbtnSearchDownExplorerClick(Sender: TObject);
var
  NodeData : PVstSearchDownData;
begin
  if not Assigned( vstSearchDown.FocusedNode ) then
    Exit;
  NodeData := VstShareDown.GetNodeData( vstSearchDown.FocusedNode );
  MyExplore.OperFolder(NodeData.DownloadPath);
end;

procedure TfrmMainForm.tbtnSearchDownSettingsClick(Sender: TObject);
begin
  frmSetting.pcMain.ActivePage := frmSetting.tsFileSearch;
  frmSetting.Show;
end;

procedure TfrmMainForm.tbtnSendClearClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  SelectData: PVstMyFileSendData;
  SendFileRemoveRootHandle: TSendFileRemoveRootHandle;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_ClearFileSend) then
    Exit;

  SelectNode := vstMyFileSend.RootNode.FirstChild;
  while Assigned(SelectNode) do
  begin
    SelectData := vstMyFileSend.GetNodeData(SelectNode);
      // ɾ�� ����� ���� ȡ����
    if ( SelectData.CompletedSize >= SelectData.FileSize ) or
       ( SelectData.Status = SendPathStatus_Cancel ) or
       ( SelectData.Status = SendPathStatus_Completed )
    then
      MyFileTransferControl.RemoveSendFile(SelectData.FilePath,SelectData.DesID);
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmMainForm.tbtnSendExplorerClick(Sender: TObject);
var
  ItemData: PVstMyFileSendData;
begin
  if not Assigned(vstMyFileSend.FocusedNode) then
    Exit;
  ItemData := vstMyFileSend.GetNodeData(vstMyFileSend.FocusedNode);
  MyExplore.OperFolder(ItemData.FilePath);
end;

procedure TfrmMainForm.tbtnSendFileClick(Sender: TObject);
begin
  frmSelectTransfer.ShowSelectFiles;
end;

procedure TfrmMainForm.tbtnSendRemoveClick(Sender: TObject);
var
  SelectNode: PVirtualNode;
  SelectData: PVstMyFileSendData;
begin
  if not MyMessageBox.ShowConfirm(ShowForm_RemoveFileSend) then
    Exit;

  // ɾ��ѡ���
  SelectNode := vstMyFileSend.GetFirstSelected;
  while Assigned(SelectNode) do
  begin
    if SelectNode.Parent = vstMyFileSend.RootNode then
    begin
      SelectData := vstMyFileSend.GetNodeData(SelectNode);

      // ɾ�� ���ڵ�
      MyFileTransferControl.RemoveSendFile(SelectData.FilePath, SelectData.DesID);
    end;
    SelectNode := vstMyFileSend.GetNextSelected( SelectNode );
  end;
end;

procedure TfrmMainForm.tbtnSettingsClick(Sender: TObject);
begin
  frmSetting.Show;
end;

procedure TfrmMainForm.tbtnSfExplorerClick(Sender: TObject);
var
  ItemData: TSearchFileLvData;
  LocationID, OwnerID: string;
  FileType, FilePath: string;
  ExplorerPath: string;
begin
  ItemData := lvSearchFile.Selected.Data;
  FileType := ItemData.FileType;
  FilePath := ItemData.FilePath;
  if FileType = FileType_SourceFile then // Դ�ļ�
    ExplorerPath := FilePath
  else
  begin // �����ļ�
    OwnerID := ItemData.OwnerID;
    FilePath := MyFilePath.getDownloadPath(FilePath);

    ExplorerPath := MyCloudFileInfo.ReadBackupCloudPath;
    ExplorerPath := MyFilePath.getPath(ExplorerPath) + OwnerID;
    ExplorerPath := MyFilePath.getPath(ExplorerPath) + FilePath;
  end;

  MyExplore.OperFolder(ExplorerPath);
end;

procedure TfrmMainForm.tbtnSfSaveasClick(Sender: TObject);
var
  DownloadPath: string;
begin
  if FileSearchDownSettingInfo.IsSelectDownloadPath then
  begin
    if MySelectFolderDialog.Select(SelectFolderTitle_SaveAs,
      FolderPath_SelectDefault, FolderPath_SelectDefault) then
      MyFileSearchControl.SearchSaveAs(FolderPath_SelectDefault);
  end
  else
    MyFileSearchControl.SearchSaveAs(FileSearchDownSettingInfo.DownloadPath);
end;

procedure TfrmMainForm.tbtnSyncSettingClick(Sender: TObject);
begin
  frmSetting.Show;
  frmSetting.pcMain.ActivePage := frmSetting.tsBackup;
  frmSetting.seSyncTime.SetFocus;
end;

procedure TfrmMainForm.Upgrade1Click(Sender: TObject);
begin
  auApp.ShowMessages := auApp.ShowMessages + [mNoUpdateAvailable];
  auApp.CheckUpdate;
end;

procedure TfrmMainForm.VstBackupChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  IsShowExplorer : Boolean;
begin
  tbtnBackupRemove.Enabled := Sender.SelectedCount > 0;
  tbtnBackupSelectedNew.Enabled := Sender.SelectedCount > 0;

  SelectNode := Sender.FocusedNode;
  if Assigned( SelectNode )  then
  begin
    NodeData := Sender.GetNodeData( SelectNode );
    IsShowExplorer := NodeData.NodeType <> BackupNodeType_NetworkDes;
  end
  else
    IsShowExplorer := False;
  tbtnBackupExplorer.Enabled := IsShowExplorer;
end;

procedure TfrmMainForm.VstBackupDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;

  // ����״̬
  if (Pt.X > 0) and (Pt.Y > 0) then
  begin
    DragFile_FileBackupLastX := Pt.X;
    DragFile_FileBackupLastY := Pt.Y;
  end;
end;

procedure TfrmMainForm.VstBackupFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PVstBackupData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.VstBackupGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstBackupData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstBackup_BackupName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end
    else
    if Column = VstBackup_Status then
    begin
      if (Kind = ikNormal) or (Kind = ikSelected) then
        ImageIndex := VstBackupUtil.getDesStatusIcon( Node )
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstBackup_BackupName then
      ImageIndex := NodeData.MainIcon
    else
    if Column = VstBackup_Status then
      ImageIndex := VstBackupUtil.getBackupStatusIcon( Node )
  end;
end;

procedure TfrmMainForm.VstBackupGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstBackupData;
begin
  CellText := '';
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstBackup_BackupName then
      CellText := NodeData.ShowName
    else
    if Column = VstBackup_Status then
    begin
      if NodeData.NodeType = BackupNodeType_LocalDes then
        CellText := VstBackupUtil.getLocalDesStatus( Node )
      else
        CellText := VstBackupUtil.getNetworkDesStatus( Node );
    end;
  end
  else
  if Column = VstBackup_BackupName then
    CellText := NodeData.ShowName
  else
  if Column = VstBackup_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstBackupItem_Size then
    CellText := MySize.getFileSizeStr( NodeData.ItemSize )
  else
  if Column = VstBackup_NextBackup then
    CellText := formatdatetime('yyyy-mm-dd hh:mm', NodeData.NextSyncTime )
  else
  if Column = VstBackup_Percentage then
    CellText := MyPercentage.getPercentageStr( NodeData.Percentage )
  else
  if Column = VstBackup_Status then
    CellText := VstBackupUtil.getBackupStatus( Node );

end;

procedure TfrmMainForm.vstBackupItemChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsSelected : Boolean;
begin
  IsSelected := vstBackupItem.SelectedCount > 0;
  tbtnBackupSelected.Enabled := IsSelected;
  tbtnFsDelete.Enabled := IsSelected;
end;

procedure TfrmMainForm.vstBackupItemCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstBackupItemData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
  RootNode: PVirtualNode;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  if Column = VstBackupItem_FullPath then
    Result := CompareText(NodeData1.FolderName, NodeData2.FolderName)
  else if Column = VstBackupItem_FileCount then
    Result := NodeData1.FileCount - NodeData2.FileCount
  else if Column = VstBackupItem_Size then
    Result := MySize.compareSize(NodeData1.ItemSize, NodeData2.ItemSize)
  else if Column = VstBackupItem_NextSync then
    Result := MyDatetime.Compare( NodeData1.NextSyncTime, NodeData2.NextSyncTime )
  else if Column = VstBackupItem_Status then
  begin
    Count1 := VstBackupItemUtil.getStatusInt( Node1 );
    Count2 := VstBackupItemUtil.getStatusInt( Node2 );
    Result := Count1 - Count2;
  end;
end;

procedure TfrmMainForm.vstBackupItemDblClick(Sender: TObject);
begin
  if not Assigned( vstBackupItem.FocusedNode ) then
    Exit;

  if vstBackupItem.FocusedNode.ChildCount = 0 then
    MyButton.Click( tbtnFsExplorer );
end;

procedure TfrmMainForm.vstBackupItemFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  IsSelectedRoot, IsSelected: Boolean;
  FullPath: string;
begin
  if Assigned( Node ) then
  begin
    IsSelected := True;
    IsSelectedRoot := Node.Parent = vstBackupItem.RootNode;

      // Show ListView
    FullPath := VstBackupItemUtil.getNodeFullPath( Node );
    MyBackupFileControl.ShowBackupFileStatus(FullPath);

      // Reset SelectNode
    TvNodePath_Selected := FullPath;
  end
  else
  begin
    IsSelectedRoot := False;
    IsSelected := False;
    TvNodePath_Selected := '';
  end;

  tbtnFsExplorer.Enabled := IsSelected;
  tbtnFsVstDetail.Enabled := IsSelectedRoot;
end;

procedure TfrmMainForm.vstBackupItemFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PVstBackupItemData;
begin
  Data := vstBackupItem.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.vstBackupItemGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if (Column = 0) and ((Kind = ikNormal) or (Kind = ikSelected)) then
    ImageIndex := VstBackupItemUtil.getStatusIcon( Node )
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstBackupItemGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstBackupItemData;
  ShowStrList : TStringList;
begin
  NodeData := vstBackupItem.GetNodeData(Node);
  if Column = VstBackupItem_FullPath then
  begin
    if NodeData.IsEncrypt then
      CellText := NodeData.FolderName + NodeStatus_Encrypted
    else
      CellText := NodeData.FolderName;
  end
  else if Column = VstBackupItem_Status then
  begin
    CellText := VstBackupItemUtil.getStatus( Node );
    CellText := LanguageUtil.getPercentageStr( CellText );
  end
  else if Column = VstBackupItem_FileCount then
    CellText := MyCount.getCountStr(NodeData.FileCount)
  else if Column = VstBackupItem_Size then
    CellText := MySize.getFileSizeStr(NodeData.ItemSize)
  else
  if Column = VstBackupItem_NextSync then
  begin
    if Node.Parent = Sender.RootNode then
      CellText := VstBackupItemUtil.getNextSyncTimeStr( Node )
    else
      CellText := '';
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstBackupItemKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnFsDelete, tbtnFsExplorer, Key );
end;

procedure TfrmMainForm.vstBackupItemMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
begin
  Node := vstBackupItem.GetNodeAt(X, Y);
  if (Node <> nil) then
    vstBackupItem.Hint := VstBackupItemUtil.getHintStr( Node )
  else
    vstBackupItem.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
end;

procedure TfrmMainForm.VstBackupPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if ( Node.Parent = Sender.RootNode ) and ( Column = VstBackup_BackupName ) then
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
end;

procedure TfrmMainForm.vstCloudPcCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PCloudPcData;
  Space1, Space2: Int64;
  Str1, Str2: string;
  dt1, dt2, dtNow: TDateTime;
begin
  NodeData1 := vstCloudPc.GetNodeData(Node1);
  NodeData2 := vstCloudPc.GetNodeData(Node2);

  if Column = vstCloudPc_PcName then
    Result := CompareText(NodeData1.PcName, NodeData2.PcName)
  else if Column = vstCloudPc_TotalSpace then
  begin
    if NodeData1.IsOnline then
      Space1 := NodeData1.TotalSpace
    else
      Space1 := 0;
    if NodeData2.IsOnline then
      Space2 := NodeData2.TotalSpace
    else
      Space2 := 0;
    Result := MySize.compareSize(Space1, Space2);
  end
  else if Column = vstCloudPc_UsedSpace then
  begin
    if NodeData1.IsOnline then
      Space1 := NodeData1.UsedSpace
    else
      Space1 := 0;
    if NodeData2.IsOnline then
      Space2 := NodeData2.UsedSpace
    else
      Space2 := 0;
    Result := MySize.compareSize(Space1, Space2);
  end
  else if Column = vstCloudPc_AvailableSpace then
  begin
    if NodeData1.IsOnline then
      Space1 := max((NodeData1.TotalSpace - NodeData1.UsedSpace), 0)
    else
      Space1 := 0;
    if NodeData2.IsOnline then
      Space2 := max((NodeData2.TotalSpace - NodeData2.UsedSpace), 0)
    else
      Space2 := 0;
    Result := MySize.compareSize(Space1, Space2);
  end
  else if Column = vstCloudPc_BackupSpace then
    Result := MySize.compareSize(NodeData1.BackupSpace, NodeData2.BackupSpace)
  else if Column = vstCloudPc_Status then
  begin
    if NodeData1.IsServer then
      Str1 := Status_Server
    else if NodeData1.IsOnline then
      Str1 := Status_Online
    else
      Str1 := Status_Offline;
    if NodeData2.IsServer then
      Str2 := Status_Server
    else if NodeData2.IsOnline then
      Str2 := Status_Online
    else
      Str2 := Status_Offline;
    Result := CompareText(Str1, Str2);
  end
  else if Column = vstCloudPc_LastOnlineTime then
  begin
    dtNow := Now;
    if NodeData1.IsOnline then
      dt1 := dtNow
    else
      dt1 := NodeData1.LastOnline;
    if NodeData2.IsOnline then
      dt2 := dtNow
    else
      dt2 := NodeData2.LastOnline;
    Result := MyDatetime.Compare(dt1, dt2);
  end
  else if Column = vstCloudPc_Reachable then
    Result := CompareText(NodeData1.Reachable, NodeData2.Reachable)
  else if Column = vstCloudPc_Position then
    Result := CompareText(NodeData1.Position, NodeData2.Position);
end;

procedure TfrmMainForm.vstCloudPcDblClick(Sender: TObject);
begin
  if tbtnCloudPcDetail.Enabled then
    tbtnCloudPcDetail.Click;
end;

procedure TfrmMainForm.vstCloudPcFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnCloudPcDetail.Enabled := Node <> nil;
end;

procedure TfrmMainForm.vstCloudPcFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PCloudPcData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.vstCloudPcGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PCloudPcData;
begin
  if (Column = 0) and ((Kind = ikNormal) or (Kind = ikSelected)) then
  begin
    NodeData := vstCloudPc.GetNodeData(Node);
    if NodeData.IsServer then
      ImageIndex := CloudStatusIcon_Server
    else if NodeData.IsOnline then
      ImageIndex := CloudStatusIcon_Online
    else
      ImageIndex := CloudStatusIcon_Offline;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstCloudPcGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  CloudPcData: PCloudPcData;
  AvailableSize: Int64;
begin
  CloudPcData := vstCloudPc.GetNodeData(Node);
  if Column = vstCloudPc_PcName then
    CellText := CloudPcData.PcName
  else if Column = vstCloudPc_TotalSpace then
  begin
    if CloudPcData.IsOnline then
      CellText := MySize.getFileSizeStr(CloudPcData.TotalSpace)
    else
      CellText := Sign_NA;
  end
  else if Column = vstCloudPc_UsedSpace then
  begin
    if CloudPcData.IsOnline then
      CellText := MySize.getFileSizeStr(CloudPcData.UsedSpace)
    else
      CellText := Sign_NA;
  end
  else if Column = vstCloudPc_AvailableSpace then
  begin
    if CloudPcData.IsOnline then
    begin
      AvailableSize := CloudPcData.TotalSpace - CloudPcData.UsedSpace;
      AvailableSize := max(0, AvailableSize);
      CellText := MySize.getFileSizeStr(AvailableSize)
    end
    else
      CellText := Sign_NA;
  end
  else if Column = vstCloudPc_BackupSpace then
    CellText := MySize.getFileSizeStr(CloudPcData.BackupSpace)
  else if Column = vstCloudPc_Status then
  begin
    if CloudPcData.IsServer then
      CellText := Status_Server
    else if CloudPcData.IsOnline then
      CellText := Status_Online
    else
      CellText := Status_Offline;
  end
  else if Column = vstCloudPc_LastOnlineTime then
  begin
    if CloudPcData.IsOnline then
      CellText := siLang_frmMainForm.GetText( 'Live' )
    else
      CellText := DateTimeToStr( CloudPcData.LastOnline );
  end
  else if Column = vstCloudPc_Reachable then
    CellText := CloudPcData.Reachable
  else if Column = vstCloudPc_Position then
    CellText := CloudPcData.Position;
end;

procedure TfrmMainForm.vstFileTransferDesChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnFileSendDesAdd.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.vstFileTransferDesDblClick(Sender: TObject);
begin
  if tbtnFileSendDesAdd.Enabled then
    tbtnFileSendDesAdd.Click;
end;

procedure TfrmMainForm.vstFileTransferDesDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  Node: PVirtualNode;
  NodeData: PVstFileTransferDesData;
begin
  Accept := False;

  // ��ʾ��ѡ
  if DragFile_FileTransferDesStart then
  begin
    VstFileTransferFirstDrop;
    DragFile_FileTransferDesStart := False;
  end;

  // ��ѡ
  if ssCtrl in Shift then
  begin
    Node := Sender.GetNodeAt(Pt.X, Pt.Y);
    if Assigned(Node) then
    begin
      NodeData := Sender.GetNodeData(Node);
      if MilliSecondsBetween(Now, NodeData.StartChangeTime) > 500 then
      begin
        NodeData.StartChangeTime := Now;
        Sender.Selected[Node] := not(vsSelected in Node.States);
      end;
    end;
  end;

  // ����״̬
  DragFile_IsFileTransferDes := True;
  if (Pt.X > 0) and (Pt.Y > 0) then
  begin
    DragFile_FileTransferDesLastX := Pt.X;
    DragFile_FileTransferDesLastY := Pt.Y;
  end;

  // ��ʾ ��ѡ
  if not plFileTransferDesMulti.Visible then
    plFileTransferDesMulti.Visible := True;

  // ���� ��ѡ
  DropFileDes_HideStartTime := Now;
  if not tmrMultiHide.Enabled then
    tmrMultiHide.Enabled := True;
end;

procedure TfrmMainForm.vstFileTransferDesGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstFileTransferDesData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := vstFileTransferDes.GetNodeData(Node);
    if (Column = VstFileSendDes_PcName) then
    begin
      if NodeData.IsOnline then
        ImageIndex := NetworkIcon_Online
      else
        ImageIndex := NetworkIcon_Offline;
    end
    else if Column = VstFileSendDes_Upload then
    begin
      if NodeData.IsShowUpload then
        ImageIndex := NetworkIcon_Upload
      else
        ImageIndex := -1;
    end
    else if Column = VstFileSendDes_Download then
    begin
      if NodeData.IsShowDownload then
        ImageIndex := NetworkIcon_Download
      else
        ImageIndex := -1;
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstFileTransferDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstFileTransferDesData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstFileSendDes_PcName then
    CellText := NodeData.PcName
  else if Column = VstFileSendDes_Upload then
  begin
    if NodeData.IsShowUpload then
      CellText := IntToStr(NodeData.UploadCount)
    else
      CellText := '';
  end
  else if Column = VstFileSendDes_Download then
  begin
    if NodeData.IsShowDownload then
      CellText := IntToStr(NodeData.DownloadCount)
    else
      CellText := '';
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.VstFileTransferFirstDrop;
var
  Node: PVirtualNode;
  NodeData: PVstFileTransferDesData;
begin
  // Ѱ��Ŀ��Pc
  Node := vstFileTransferDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := vstFileTransferDes.GetNodeData(Node);
    if vsSelected in Node.States then
      vstFileTransferDes.Selected[Node] := False;
    Node := Node.NextSibling;
  end;
end;

procedure TfrmMainForm.VstLocalBackupDesChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnBackupDesRemove.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.VstLocalBackupDesCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstLocalBackupDesData;
  Int1, Int2: Integer;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);
  if Column = VstLocalBackupDes_FilePath then
    Result := CompareText(NodeData1.FullPath, NodeData2.FullPath)
  else if Column = VstLocalBackupDes_FileSize then
    Result := MySize.compareSize(NodeData1.FileSize, NodeData2.FileSize)
  else if Column = VstLocalBackupDes_FileStatus then
  begin
    Int1 := VstLocalBackupDesUtil.getNodeStatusInt(Node1);
    Int2 := VstLocalBackupDesUtil.getNodeStatusInt(Node2);
    Result := Int1 - Int2;
  end
  else
    Result := 0;
end;

procedure TfrmMainForm.VstLocalBackupDesDblClick(Sender: TObject);
begin
  if not Assigned( VstLocalBackupDes.FocusedNode ) then
    Exit;

  if VstLocalBackupDes.FocusedNode.ChildCount = 0 then
    MyButton.Click( tbtnBackupDesExplorer );
end;

procedure TfrmMainForm.VstLocalBackupDesDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;
  DropFile_IsLocalBackupSource := False;
end;

procedure TfrmMainForm.VstLocalBackupDesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnBackupDesExplorer.Enabled := Assigned( Node );
end;

procedure TfrmMainForm.VstLocalBackupDesGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstLocalBackupDesData;
  FullPath: string;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := Sender.GetNodeData(Node);
    if Column = VstLocalBackupDes_FilePath then // �ļ�
    begin
      FullPath := NodeData.FullPath;
      if Sender.Expanded[Node] then
        ImageIndex := MyShellIconUtil.getFolderExpandIcon
      else
        ImageIndex := NodeData.PathIcon;
    end
    else if Column = VstLocalBackupDes_FileStatus then
    begin
      if Node.Parent = Sender.RootNode then
        ImageIndex := VstLocalBackupDesUtil.getRootNodeIcon(Node)
      else
      if NodeData.IsDeleted then
      begin
        if NodeData.Status = LocalBackupStatus_Copying then
          ImageIndex := MyShellTransActionIconUtil.getCopyFile
        else
          ImageIndex := MyShellTransActionIconUtil.getLoaded
      end
      else
      if NodeData.Status = LocalBackupStatus_Recycling then
        ImageIndex := MyShellTransActionIconUtil.getRecycle2
      else
        ImageIndex := VstLocalBackupDesUtil.getChildNodeIcon(Node);
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.VstLocalBackupDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstLocalBackupDesData;
  ShowStrList : TStringList;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstLocalBackupDes_FilePath then
    CellText := NodeData.FullPath
  else if Column = VstLocalBackupDes_FileSize then
      CellText := MySize.getFileSizeStr(NodeData.FileSize)
  else if Column = VstLocalBackupDes_FileStatus then
  begin
    if Node.Parent = Sender.RootNode then
      CellText := VstLocalBackupDesUtil.getRootNodeStatus(Node)
    else
    if NodeData.Status <> '' then
      CellText := NodeData.Status
    else
    if NodeData.IsDeleted then
      CellText := LocalBackupStatus_Recycled
    else
      CellText := VstLocalBackupDesUtil.getChildNodeStatus(Node);
    CellText := LanguageUtil.getPercentageStr( CellText );
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.VstLocalBackupDesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnBackupDesRemove, tbtnBackupDesExplorer, Key );
end;

procedure TfrmMainForm.VstLocalBackupDesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
  HintStr, FreeSpaceStr, StatusStr, TempStr: string;
  ShowStrList : TStringList;
begin
  Node := VstLocalBackupDes.GetNodeAt(X, Y);
  if Assigned(Node) then
  begin
    FreeSpaceStr := '';
    NodeData := VstLocalBackupDes.GetNodeData(Node);
    if Node.Parent = VstLocalBackupDes.RootNode then
    begin
      if DirectoryExists( NodeData.FullPath ) then
        FreeSpaceStr := MySize.getFileSizeStr( MyHardDisk.getHardDiskFreeSize( NodeData.FullPath ) );
      StatusStr := VstLocalBackupDesUtil.getRootNodeStatus(Node);
    end
    else
      StatusStr := VstLocalBackupDesUtil.getChildNodeStatus(Node);
    TempStr := siLang_frmMainForm.GetText( 'HintDirectory' );
    HintStr := TempStr + NodeData.FullPath;
    if FreeSpaceStr <> '' then
    begin
      TempStr := siLang_frmMainForm.GetText( 'HintAvailable' );
      HintStr := HintStr + #13#10 + TempStr + FreeSpaceStr;
    end;
    TempStr := siLang_frmMainForm.GetText( 'Status' );
    HintStr := HintStr + #13#10 + TempStr;
    StatusStr := LanguageUtil.getPercentageStr( StatusStr );
    HintStr := HintStr + StatusStr;
  end
  else
    HintStr := frmMainForm.siLang_frmMainForm.GetText( 'DragFolder' );
  VstLocalBackupDes.Hint := HintStr;
end;

procedure TfrmMainForm.VstLocalBackupSourceChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnLocalBackupSelected.Enabled := VstLocalBackupSource.SelectedCount > 0;
  tbtnLocalBackupRemove.Enabled := VstLocalBackupSource.SelectedCount > 0;
end;

procedure TfrmMainForm.VstLocalBackupSourceCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex;
  var Result: Integer);
var
  NodeData1, NodeData2: PVstLocalBackupSourceData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  if Column = VstLocalBackupSource_ItemPath then
    Result := CompareText(NodeData1.FullPath, NodeData2.FullPath)
  else if Column = VstLocalBackupSource_FileCount then
    Result := NodeData1.FileCount - NodeData2.FileCount
  else if Column = VstLocalBackupSource_FileSize then
  begin
    Space1 := NodeData1.FileSize;
    Space2 := NodeData2.FileSize;
    Result := MySize.compareSize(Space1, Space2);
  end
  else if Column = VstLocalBackupSource_LastSync then
    Result := MyDatetime.Compare( NodeData1.NextSyncTime, NodeData2.NextSyncTime )
  else if Column = VstLocalBackupSource_FileStatus then
    Result := 0
end;

procedure TfrmMainForm.VstLocalBackupSourceDblClick(Sender: TObject);
begin
  MyButton.Click( tbtnLocalBackupExplorer );
end;

procedure TfrmMainForm.VstLocalBackupSourceDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;
  DropFile_IsLocalBackupSource := True;
end;

procedure TfrmMainForm.VstLocalBackupSourceFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnLocalBackupExplorer.Enabled := Assigned( Node );
  tbtnLocalBackupOptions.Enabled := Assigned( Node );
end;

procedure TfrmMainForm.VstLocalBackupSourceGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstLocalBackupSourceData;
  FullPath, Status: string;
  IsFile : Boolean;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := Sender.GetNodeData(Node);
    if Column = VstLocalBackupSource_ItemPath then // �ļ�
      ImageIndex := NodeData.PathIcon
    else
    if Column = VstLocalBackupSource_FileStatus then
    begin
      Status := NodeData.Status;
      if NodeData.IsDisable then
        ImageIndex := MyShellTransActionIconUtil.getDisable
      else
      if not NodeData.IsExist then
        ImageIndex := MyShellTransActionIconUtil.getLoadedError
      else
      if Status = LocalBackupSourceStatus_Copy then
        ImageIndex := MyShellTransActionIconUtil.getCopyFile
      else
      if Status = LocalBackupSourceStatus_Refresh then
        ImageIndex := MyShellTransActionIconUtil.getAnalyze
      else
        ImageIndex := -1;
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.VstLocalBackupSourceGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstLocalBackupSourceData;
  StrList : TStringList;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstLocalBackupSource_ItemPath then
    CellText := NodeData.FullPath
  else
  if Column = VstLocalBackupSource_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstLocalBackupSource_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstLocalBackupSource_LastSync then
    CellText := VstLocalBackupSourceUtil.getNextSync( Node )
  else
  if Column = VstLocalBackupSource_FileStatus then
  begin
    if NodeData.IsDisable then
      CellText := LocalBackupStatus_Disable
    else
    if not NodeData.IsExist then
      CellText := LocalBackupStatus_NotExist
    else
      CellText := NodeData.ShowStatus;

    CellText := LanguageUtil.getPercentageStr( CellText );
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.VstLocalBackupSourceKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnLocalBackupRemove, tbtnLocalBackupExplorer, Key );
end;

procedure TfrmMainForm.VstLocalBackupSourceMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
  NodeData : PVstLocalBackupSourceData;
  LastSyncStr, NextSyncStr, HintStr, TempStr : string;
  ShowStrList : TStringList;
begin
  Node := VstLocalBackupSource.GetNodeAt( x, y );
  if Assigned( Node ) then
  begin
    NodeData := VstLocalBackupSource.GetNodeData( Node );

    if NodeData.IsAutoSync and not NodeData.IsDisable then
    begin
      LastSyncStr := DateTimeToStr( NodeData.LastSyncTime );
      NextSyncStr := DateTimeToStr( NodeData.NextSyncTime );
    end
    else
    begin
      LastSyncStr := Sign_NA;
      NextSyncStr := Sign_NA;
    end;

    TempStr := siLang_frmMainForm.GetText( 'HintItemPath' );
    HintStr := TempStr + NodeData.FullPath + #13#10;
    TempStr := siLang_frmMainForm.GetText( 'HintSyncTime' );
    HintStr := HintStr + TempStr;
    TempStr := TimeTypeUtil.getTimeShow( NodeData.SyncTimeType, NodeData.SyncTimeValue );
    TempStr := LanguageUtil.getSyncTimeStr( TempStr );
    HintStr := HintStr + TempStr + #13#10;;
    TempStr := siLang_frmMainForm.GetText( 'HintLastSync' );
    HintStr := HintStr + TempStr + LastSyncStr + #13#10;
    TempStr := siLang_frmMainForm.GetText( 'NextSync' );
    HintStr := HintStr + TempStr + NextSyncStr;
  end
  else
    HintStr := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );

  VstLocalBackupSource.Hint := HintStr;
end;

procedure TfrmMainForm.VstMyBackupDesChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if Sender.SelectedCount > 1 then
  begin
    tbtnMyCloudBackup.Enabled := True;
    tbtnMyCloudNotBackup.Enabled := True;
  end;
end;

procedure TfrmMainForm.VstMyBackupDesDblClick(Sender: TObject);
begin
  tbtnMyBackupDesProperties.Click;
end;

procedure TfrmMainForm.VstMyBackupDesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  NodeData : PVstMyBackupDesData;
begin
  if not Assigned( Node ) then
    Exit;

  NodeData := Sender.GetNodeData( Node );
  tbtnMyCloudBackup.Enabled := not NodeData.IsBackup;
  tbtnMyCloudNotBackup.Enabled := not tbtnMyCloudBackup.Enabled;
end;

procedure TfrmMainForm.VstMyBackupDesGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstMyBackupDesData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := Sender.GetNodeData(Node);
    if Column = VstMyBackupDes_PcName then // �ļ�
    begin
      if NodeData.IsOnline then
        ImageIndex := CloudStatusIcon_Online
      else
        ImageIndex := CloudStatusIcon_Offline;
    end
    else
    if Column = VstMyBackupDes_BackupToThis then
    begin
      if NodeData.IsBackup then
        ImageIndex := CloudStatusIcon_BackupToThis
      else
        ImageIndex := CloudStatusIcon_NotBackupToThis;
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.VstMyBackupDesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstMyBackupDesData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstMyBackupDes_PcName then
    CellText := NodeData.PcName
  else
  if Column = VstMyBackupDes_TotalSpace then
    CellText := MySize.getFileSizeStr( NodeData.TotalSpace )
  else
  if Column = VstMyBackupDes_AvailableSpace then
    CellText := MySize.getFileSizeStr( NodeData.AvalableSpace )
  else
  if Column = VstMyBackupDes_BackupToThis then
  begin
    if NodeData.IsBackup then
      CellText := 'Yes'
    else
      CellText := 'No';
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstMyFileSendChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnSendRemove.Enabled := Sender.SelectedCount > 0;
  tbtnResetnd.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.vstMyFileSendCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstMyFileSendData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
  RootNode: PVirtualNode;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  if Column = VstSendFile_FilePath then
    Result := CompareText(NodeData1.FilePath, NodeData2.FilePath)
  else if Column = VstSendFile_FileSize then
    Result := MySize.compareSize(NodeData1.FileSize, NodeData2.FileSize)
  else if Column = VstSendFile_Destination then
    Result := CompareText(NodeData1.DesName, NodeData2.DesName)
  else if Column = VstSendFile_Percentage then
  begin
    Count1 := MyPercentage.getPercent( NodeData1.CompletedSize, NodeData1.FileSize );
    Count2 := MyPercentage.getPercent( NodeData2.CompletedSize, NodeData2.FileSize );
    Result := Count1 - Count2;
  end
  else if Column = VstSendFile_Status then
    Result := CompareText(NodeData1.Status, NodeData2.Status);
end;

procedure TfrmMainForm.vstMyFileSendDblClick(Sender: TObject);
begin
  if not Assigned( vstMyFileSend.FocusedNode ) then
    Exit;

  if ( vstMyFileSend.FocusedNode.ChildCount = 0 ) and tbtnSendExplorer.Enabled then
    tbtnSendExplorer.Click;
end;

procedure TfrmMainForm.vstMyFileSendDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
begin
  Accept := False;
  DragFile_IsFileTransferDes := False;
end;

procedure TfrmMainForm.vstMyFileSendFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
var
  IsShowFreeHint: Boolean;
begin
  tbtnSendExplorer.Enabled := Assigned( Node );
  IsShowFreeHint := False;

  plFileSendFreeHint.Visible := Assigned( Node ) and MyFileTransferFaceUtil.getIsFreeLimit( Node );
end;

procedure TfrmMainForm.vstMyFileSendGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  ItemData: PVstMyFileSendData;
  SendFileStatus: string;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstSendFile_FilePath then
    begin
      ItemData := Sender.GetNodeData(Node);
      ImageIndex := MyIcon.getIconByFilePath(ItemData.FilePath);
    end
    else if Column = VstSendFile_Status then
      ImageIndex := MyFileTransferFaceUtil.getSendNodeStatusIcon(Node)
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstMyFileSendGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstMyFileSendData;
  Percentage: Integer;
  NodeStatus: string;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstSendFile_FilePath then
    CellText := MyFileInfo.getFileName(NodeData.FilePath)
  else if Column = VstSendFile_FileSize then
  begin
    if NodeData.Status = SendPathStatus_Scanning then
      CellText := ''
    else
      CellText := MySize.getFileSizeStr(NodeData.FileSize);
  end
  else if Column = VstSendFile_Destination then
    CellText := NodeData.DesName
  else if Column = VstSendFile_Percentage then
  begin
    NodeStatus := NodeData.Status;
    if NodeStatus = SendPathStatus_Scanning then
      CellText := ''
    else
    begin
      if (NodeData.FileSize = 0) and (NodeStatus = SendPathStatus_Sending) then
        Percentage := 0
      else if NodeData.Status = SendPathStatus_Completed then
        Percentage := 100
      else
        Percentage := MyPercentage.getPercent(NodeData.CompletedSize,
          NodeData.FileSize);
      CellText := MyPercentage.getPercentageStr(Percentage);
    end;
  end
  else if Column = VstSendFile_Status then
    CellText := MyFileTransferFaceUtil.getSendNodeStatus(Node)
  else
    CellText := '';
end;

procedure TfrmMainForm.vstMyFileSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if MyKeyBorad.CheckCtrlEnter( tbtnResetnd, Key, Shift ) then
    Exit;
  MyKeyBorad.CheckDeleteAndEnter( tbtnSendRemove, tbtnSendExplorer, Key );
end;

procedure TfrmMainForm.vstMyFileSendMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectNode: PVirtualNode;
  NodeData: PVstMyFileSendData;
  HintStr: string;
begin
  SelectNode := vstMyFileSend.GetNodeAt(X, Y);
  if SelectNode = nil then
  begin
    vstMyFileSend.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' );
  end
  else
  begin
    NodeData := vstMyFileSend.GetNodeData(SelectNode);
    HintStr := NodeData.FilePath + #13#10;
    HintStr := HintStr + NodeData.Status;

    vstMyFileSend.Hint := HintStr;
  end;
end;

procedure TfrmMainForm.vstRestoreChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  IsShowExplorer : Boolean;
  NodeData, ParentData : PVstRestoreData;
  NodeType : string;
begin
  IsShowExplorer := False;
  if Assigned( Sender.FocusedNode ) then
  begin
    NodeData := Sender.GetNodeData( Sender.FocusedNode );
    NodeType := NodeData.NodeType;
    if ( NodeType = RestoreNodeType_LocalDes ) or
       ( NodeType = RestoreNodeType_LocalRestore )
    then
      IsShowExplorer := True
    else
    if NodeType = RestoreNodeType_NetworkRestore then
    begin
      ParentData := Sender.GetNodeData( Sender.FocusedNode.Parent );
      if ParentData.ItemID = Network_LocalPcID then
        IsShowExplorer := True;
    end;
  end;
  tbtnRestoreExplorer.Enabled := IsShowExplorer;
  tbtnRestoreSelected.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.vstRestoreComputersDblClick(Sender: TObject);
begin
  if tbtnRestoreSpecific.Enabled then
    tbtnRestoreSpecific.Click;
end;

procedure TfrmMainForm.vstRestoreComputersFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnRestoreNow.Enabled := Assigned( Node );
  tbtnRestoreSpecific.Enabled := Assigned( Node );
end;

procedure TfrmMainForm.vstRestoreComputersGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstRestorePcData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstRestorePc_PcName then
      ImageIndex := NetworkIcon_Online
    else
    begin
      NodeData := Sender.GetNodeData(Node);
      if Column = VstRestorePc_Upload then
      begin
        if NodeData.IsShowUpload then
          ImageIndex := NetworkIcon_Upload
        else
          ImageIndex := -1;
      end
      else if Column = VstRestorePc_Download then
      begin
        if NodeData.IsShowDownload then
          ImageIndex := NetworkIcon_Download
        else
          ImageIndex := -1;
      end
      else
        ImageIndex := -1;
    end;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstRestoreComputersGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstRestorePcData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstRestorePc_PcName then
    CellText := NodeData.RestorePcName
  else if Column = VstRestorePc_Upload then
  begin
    if NodeData.IsShowUpload then
      CellText := IntToStr(NodeData.UploadCount)
    else
      CellText := '';
  end
  else if Column = VstRestorePc_Download then
  begin
    if NodeData.IsShowDownload then
      CellText := IntToStr(NodeData.DownloadCount)
    else
      CellText := '';
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstRestoreDownChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnRdRemoveSelected.Enabled := vstRestoreDown.SelectedCount > 0;
  tbtnRestoreAgain.Enabled := vstRestoreDown.SelectedCount > 0;
end;

procedure TfrmMainForm.vstRestoreDownCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstRestoreDownData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
  RootNode: PVirtualNode;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  if Column = VstRestoreDown_FileName then
    Result := CompareText(NodeData1.FullPath, NodeData2.FullPath)
  else if Column = VstRestoreDown_Owner then
    Result := CompareText(NodeData1.RestorePcName, NodeData2.RestorePcName)
  else if Column = VstRestoreDown_FileSize then
    Result := MySize.compareSize(NodeData1.FileSize, NodeData2.FileSize)
  else if Column = VstRestoreDown_Percentage then
  begin
    Count1 := MyPercentage.getPercent( NodeData1.CompletedSize, NodeData1.FileSize );
    Count2 := MyPercentage.getPercent( NodeData2.CompletedSize, NodeData2.FileSize );
    Result := Count1 - Count2;
  end
  else if Column = VstRestoreDown_Status then
    Result := CompareText(NodeData1.Status, NodeData2.Status);
end;

procedure TfrmMainForm.vstRestoreDownDblClick(Sender: TObject);
begin
  if not Assigned( vstRestoreDown.FocusedNode ) then
    Exit;

  if vstRestoreDown.FocusedNode.ChildCount = 0 then
    MyButton.Click( tbtnRdExplorer );
end;

procedure TfrmMainForm.vstRestoreDownFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnRdExplorer.Enabled := Assigned(Node);
end;

procedure TfrmMainForm.vstRestoreDownFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PVstRestoreDownData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.vstRestoreDownGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstRestoreDownData;
  NodeStatus : string;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = 0 then
    begin
      NodeData := vstRestoreDown.GetNodeData(Node);
      ImageIndex := NodeData.ImageIndex;
    end
    else
    if Column = VstRestoreDown_Status then
      ImageIndex := VstRestoreDownUtil.getStatusIcon( Node)
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstRestoreDownGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  IsRootNode: Boolean;
  NodeData: PVstRestoreDownData;
  ParentData: PVstRestoreDownData;
begin
  IsRootNode := Node.Parent = vstRestoreDown.RootNode;
  NodeData := vstRestoreDown.GetNodeData(Node);
  if Column = VstRestoreDown_FileName then
  begin
    if IsRootNode then
      CellText := NodeData.FullPath
    else
      CellText := ExtractFileName(NodeData.FullPath);
  end
  else if Column = VstRestoreDown_FileSize then
    CellText := MySize.getFileSizeStr(NodeData.FileSize)
  else if Column = VstRestoreDown_Owner then
  begin
    if IsRootNode then
      CellText := NodeData.RestorePcName
    else
    begin
      ParentData := vstRestoreDown.GetNodeData(Node.Parent);
      CellText := ParentData.RestorePcName;
    end;
  end
  else
  if Column = VstRestoreDown_Percentage then
    CellText := MyPercentage.getPercentageStr( NodeData.CompletedSize, NodeData.FileSize )
  else if Column = VstRestoreDown_Status then
  begin
    CellText := vstRestoreDownUtil.getStatus( Node );
    CellText := siLang_frmMainForm.GetText( CellText );
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstRestoreDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnRdRemoveSelected, tbtnRdExplorer, Key );
end;

procedure TfrmMainForm.vstRestoreDownMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
  HintStr : string;
begin
  Node := vstRestoreDown.GetNodeAt( x, y );
  if Assigned( Node ) then
    HintStr := VstRestoreDownUtil.getHintStr( Node )
  else
    HintStr := '';
  vstRestoreDown.Hint := HintStr;
end;

procedure TfrmMainForm.vstRestoreGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstRestoreData;
begin
  ImageIndex := -1;
  NodeData := Sender.GetNodeData( Node );
  if Node.Parent = Sender.RootNode then
  begin
    if Column = VstRestore_RestoreName then
    begin
      if Kind = ikState then
        ImageIndex := NodeData.MainIcon
    end;
  end
  else
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstRestore_RestoreName then
      ImageIndex := NodeData.MainIcon;
  end;
end;

procedure TfrmMainForm.vstRestoreGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstRestoreData;
begin
  CellText := '';

  NodeData := Sender.GetNodeData( Node );
  if Column = VstRestore_RestoreName then
    CellText := NodeData.ShowName
  else
  if Node.Parent = Sender.RootNode then
    CellText := ''
  else
  if Column = VstRestore_RestoreOwner then
    CellText := NodeData.OwnerName
  else
  if Column = VstRestore_FileCount then
    CellText := MyCount.getCountStr( NodeData.FileCount )
  else
  if Column = VstRestore_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstRestore_LastBackupTime then
    CellText := formatdatetime('yyyy-mm-dd hh:mm', NodeData.LastBackupTime );
end;

procedure TfrmMainForm.vstSearchDownChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnSdRemoveSelected.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.vstSearchDownDblClick(Sender: TObject);
begin
  if tbtnSearchDownExplorer.Enabled then
    tbtnSearchDownExplorer.Click;
end;

procedure TfrmMainForm.vstSearchDownFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnSearchDownExplorer.Enabled := Assigned( Node );
end;

procedure TfrmMainForm.vstSearchDownGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstSearchDownData;
  FullPath, Status: string;
  IsFile : Boolean;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    NodeData := Sender.GetNodeData(Node);
    if Column = VstSearchDown_FileName then // �ļ�
      ImageIndex := MyIcon.getIconByFilePath( NodeData.DownloadPath )
    else
    if Column = VstSearchDown_Status then
    begin
      if not NodeData.IsLocationOnline then
        Status := DownSearchStatus_Offline
      else
      if NodeData.CompletedSize >= NodeData.FileSize then
        Status := DownSearchStatus_Loaded
      else
        Status := NodeData.Status;
      ImageIndex := VstSearchDownUtil.getStatusIcon( Status );
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstSearchDownGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstSearchDownData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstSearchDown_FileName then
    CellText := ExtractFileName( NodeData.DownloadPath )
  else
  if Column = VstSearchDown_FileOwner then
    CellText := NodeData.SourcePcName
  else
  if Column = VstSearchDown_FileSize then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
  if Column = VstSearchDown_Percentage then
    CellText := MyPercentage.getPercentageStr( NodeData.CompletedSize, NodeData.FileSize )
  else
  if Column = VstSearchDown_FileFrom then
    CellText := NodeData.LocationPcName
  else
  if Column = VstSearchDown_Status then
  begin
    if not NodeData.IsLocationOnline then
      CellText := DownSearchStatus_Offline
    else
    if NodeData.CompletedSize >= NodeData.FileSize then
      CellText := DownSearchStatus_Loaded
    else
      CellText := NodeData.Status;
    CellText := LanguageUtil.getPercentageStr( CellText );
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstSearchDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnSdRemoveSelected, tbtnSearchDownExplorer, Key );
end;

procedure TfrmMainForm.VstShareDownChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnDownloadAgain.Enabled := Sender.SelectedCount > 0;
  tbtnShareDownRemove.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.VstShareDownCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstShareDownData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
  RootNode: PVirtualNode;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  if Column = VstShareDown_FilePath then
    Result := CompareText(NodeData1.FullPath, NodeData2.FullPath)
  else if Column = VstShareDown_OwnerName then
    Result := CompareText(NodeData1.DesPcName, NodeData2.DesPcName)
  else if Column = VstShareDown_FileSize then
    Result := MySize.compareSize( NodeData1.FileSize, NodeData2.FileSize )
  else if Column = VstShareDown_Percentage then
  begin
    Count1 := MyPercentage.getPercent( NodeData1.CompletedSize, NodeData1.FileSize );
    Count2 := MyPercentage.getPercent( NodeData2.CompletedSize, NodeData2.FileSize );
    Result := Count1 - Count2;
  end
  else if Column = VstShareDown_Status then
    Result := CompareText(NodeData1.Status, NodeData2.Status);
end;

procedure TfrmMainForm.VstShareDownDblClick(Sender: TObject);
begin
  if not Assigned( VstShareDown.FocusedNode ) then
    Exit;

  if ( VstShareDown.FocusedNode.ChildCount = 0 ) and tbtnShareDownExplorer.Enabled then
    tbtnShareDownExplorer.Click;
end;

procedure TfrmMainForm.VstShareDownFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnShareDownExplorer.Enabled := Assigned(Node);
  plShareLimtHint.Visible := Assigned(Node) and VstShareDownUtil.getIsFreeLimit(Node);
end;

procedure TfrmMainForm.VstShareDownGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstShareDownData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstShareDown_FilePath then
    begin
      NodeData := Sender.GetNodeData(Node);
      if NodeData.PathType = SharePathType_Folder then
        ImageIndex := MyShellIconUtil.getFolderIcon
      else
        ImageIndex := MyIcon.getIconByFileExt(NodeData.FullPath);
    end
    else if Column = VstShareDown_Status then
      ImageIndex := VstShareDownUtil.getNodeIcon(Node)
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.VstShareDownGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstShareDownData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstShareDown_FilePath then
    CellText := ExtractFileName(NodeData.FullPath)
  else if Column = VstShareDown_OwnerName then
    CellText := NodeData.DesPcName
  else if Column = VstShareDown_FileSize then
    CellText := MySize.getFileSizeStr(NodeData.FileSize)
  else if Column = VstShareDown_Percentage then
  begin
    if (NodeData.Status = FileShareStatus_Cancel) and
      (NodeData.FileSize = 0) then
      CellText := MyPercentage.getPercentageStr(0)
    else
      CellText := MyPercentage.getPercentageStr(NodeData.CompletedSize,
        NodeData.FileSize)
  end
  else if Column = VstShareDown_Status then
  begin
    // ���ð�����
    if App_IsFreeLimit and ( Node.Parent = VstShareDown.RootNode ) and
       NodeData.IsIncompleted
    then
      CellText := FileShareStatus_Incompleted
    else
    if NodeData.Status = FileShareStatus_Cancel then
      CellText := FileShareStatus_CancelShow
    else if (Node.Parent = Sender.RootNode) and
      (NodeData.CompletedSize >= NodeData.FileSize) then
      CellText := FileShareStatus_Completed
    else if not NodeData.IsDesPcOnline then
      CellText := FileShareStatus_Offline
    else if VstShareDownUtil.getIsFreeLimit(Node) then
      CellText := FileShareStatus_FreeLimit
    else
      CellText := NodeData.Status;
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.VstShareDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if MyKeyBorad.CheckCtrlEnter( tbtnDownloadAgain, Key, Shift ) then
    Exit;
  MyKeyBorad.CheckDeleteAndEnter( tbtnSdRemoveSelected, tbtnShareDownExplorer, Key );
end;

procedure TfrmMainForm.VstShareDownMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
  NodeData: PVstShareDownData;
  HintStr: string;
begin
  Node := VstShareDown.GetNodeAt(X, Y);
  if not Assigned(Node) then
  begin
    VstShareDown.Hint := '';
    Exit;
  end;
  NodeData := VstShareDown.GetNodeData(Node);
  HintStr := 'Source Path: ' + NodeData.FullPath + #13#10;
  HintStr := HintStr + 'Save Path: ' + NodeData.SavePath;
  VstShareDown.Hint := HintStr;
end;

procedure TfrmMainForm.VstShareFilePcDblClick(Sender: TObject);
begin
  if tbtnDownPcShare.Enabled then
    tbtnDownPcShare.Click;
end;

procedure TfrmMainForm.VstShareFilePcFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnDownPcShare.Enabled := Assigned(Node);
end;

procedure TfrmMainForm.VstShareFilePcGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstShareFilePcData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstSharePc_PcName then
      ImageIndex := NetworkIcon_Online
    else
    begin
      NodeData := Sender.GetNodeData(Node);
      if Column = VstSharePc_Upload then
      begin
        if NodeData.IsShowUpload then
          ImageIndex := NetworkIcon_Upload
        else
          ImageIndex := -1;
      end
      else if Column = VstSharePc_Download then
      begin
        if NodeData.IsShowDownload then
          ImageIndex := NetworkIcon_Download
        else
          ImageIndex := -1;
      end
      else
        ImageIndex := -1;
    end;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.VstShareFilePcGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PVstShareFilePcData;
begin
  NodeData := Sender.GetNodeData(Node);
  if Column = VstSharePc_PcName then
    CellText := NodeData.PcName
  else if Column = VstSharePc_Upload then
  begin
    if NodeData.IsShowUpload then
      CellText := IntToStr(NodeData.UploadCount)
    else
      CellText := '';
  end
  else if Column = VstSharePc_Download then
  begin
    if NodeData.IsShowDownload then
      CellText := IntToStr(NodeData.DownloadCount)
    else
      CellText := '';
  end
  else
    CellText := '';
end;

procedure TfrmMainForm.vstSharePathChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  tbtnSharePathRemove.Enabled := Sender.SelectedCount > 0;
end;

procedure TfrmMainForm.vstSharePathCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1, NodeData2: PVstSharePathData;
  Count1, Count2: Integer;
  Space1, Space2: Int64;
  Str1, Str2: string;
  RootNode: PVirtualNode;
begin
  NodeData1 := Sender.GetNodeData(Node1);
  NodeData2 := Sender.GetNodeData(Node2);

  Result := CompareText(NodeData1.FullPath, NodeData2.FullPath);
end;

procedure TfrmMainForm.vstSharePathDblClick(Sender: TObject);
begin
  if tbtnSharePathExplorer.Enabled then
    tbtnSharePathExplorer.Click;
end;

procedure TfrmMainForm.vstSharePathFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnSharePathExplorer.Enabled := Assigned( Node );
end;

procedure TfrmMainForm.vstSharePathGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstSharePathData;
begin
  if (Kind = ikNormal) or (Kind = ikSelected) then
  begin
    if Column = VstSharePath_FilePath then
    begin
      NodeData := Sender.GetNodeData( Node );
      ImageIndex := MyIcon.getIconByFilePath( NodeData.FullPath );
    end
    else
      ImageIndex := -1;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstSharePathGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstSharePathData;
  IsExistPath : Boolean;
  FullPath : string;
begin
  NodeData := Sender.GetNodeData( Node );
  FullPath := NodeData.FullPath;
  if Column = VstSharePath_FilePath then
    CellText := FullPath
  else
  begin
    IsExistPath := MyFilePath.getIsExist( FullPath );
    if not IsExistPath then
      CellText := ''
    else
    if Column = VstSharePath_FileSize then
    begin
      if NodeData.PathType = PathType_File then
        CellText := MySize.getFileSizeStr( MyFileInfo.getFileSize( FullPath ) )
      else
        CellText := '';
    end
    else
    if Column = VstSharePath_FileTime then
      CellText := DateTimeToStr( MyFileInfo.getFileLastWriteTime( FullPath ) )
    else
      CellText := '';
  end;
end;

procedure TfrmMainForm.vstSharePathKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  MyKeyBorad.CheckDeleteAndEnter( tbtnSharePathRemove, tbtnSharePathExplorer, Key );
end;

procedure TfrmMainForm.vstTransStatusCollapsed(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  NodeData: PTransferData;
begin
  NodeData := Sender.GetNodeData(Node);
  NodeData.IsExpand := False;
end;

procedure TfrmMainForm.vstTransStatusDblClick(Sender: TObject);
begin
  if tbtnTsExplorer.Enabled then
    tbtnTsExplorer.Click;
end;

procedure TfrmMainForm.vstTransStatusExpanded(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  NodeData: PTransferData;
begin
  NodeData := Sender.GetNodeData(Node);
  NodeData.IsExpand := True;
end;

procedure TfrmMainForm.vstTransStatusFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnTsExplorer.Enabled := (Node <> nil) and
    (Node.Parent <> vstTransStatus.RootNode);
end;

procedure TfrmMainForm.vstTransStatusFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PTransferData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmMainForm.vstTransStatusGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PTransferData;
  IconPath: string;
begin
  if (Column = 0) and ((Kind = ikNormal) or (Kind = ikSelected)) then
  begin
    if Node.Parent = vstTransStatus.RootNode then
    begin
      if vsExpanded in Node.States then
        ImageIndex := MyShellIconUtil.getFolderExpandIcon
      else
        ImageIndex := MyShellIconUtil.getFolderIcon;
    end
    else
    begin
      NodeData := vstTransStatus.GetNodeData(Node);
      IconPath := NodeData.FilePath;
      ImageIndex := MyIcon.getIconByFilePath(IconPath);
    end;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmMainForm.vstTransStatusGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data, ParentData: PTransferData;
  ParentID: string;
  IsPend, IsLoading: Boolean;
begin
  Data := Sender.GetNodeData(Node);
  if Column = VstTransStatus_FileName then
  begin
    if Node.Parent = vstTransStatus.RootNode then
    begin
      if Data.ChildCount = 0 then
        CellText := Data.FileName
      else
        CellText := Data.FileName + ' (' + IntToStr(Data.ChildCount) + ')'
    end
    else
      CellText := Data.FileName;
  end
  else if Column = VstTransStatus_FileSize then
    CellText := MySize.getFileSizeStr(Data.FileSize)
  else if Node.Parent = vstTransStatus.RootNode then
    CellText := ''
  else if Column = VstTransStatus_Location then
    CellText := Data.Location
  else if Column = VstTransStatus_Pecentage then
    CellText := MyPercentage.getPercentageStr(Data.Percentage)
  else if Column = VstTransStatus_Type then
  begin
    if Node.Parent = Sender.RootNode then
      CellText := ''
    else
    begin
      CellText := siLang_frmMainForm.GetText( Data.FileType );
      if Data.IsMD5 then
        CellText := CellText + Sign_MD5;
    end;
  end
  else if Column = VstTransStatus_Status then
    CellText := siLang_frmMainForm.GetText( Data.FileStatus )
  else
  begin
    ParentData := vstTransStatus.GetNodeData(Node.Parent);
    ParentID := ParentData.NodeID;
    IsPend := (ParentID = RootID_DownPend) or (ParentID = RootID_UpPend);
    IsLoading := (ParentID = RootID_DownLoading) or
      (ParentID = RootID_UpLoading);

    if IsPend then
      CellText := ''
    else if Column = VstTransStatus_UsedTime then
    begin
      if IsLoading then
        CellText := MyTime.getMyTimeStr(SecondsBetween(Now, Data.StartTime))
      else
        CellText := MyTime.getMyTimeStr(Data.UsedTime);
    end
    else if Column = VstTransStatus_Speed then
      CellText := MySpeed.getSpeedStr(Data.Speed)
    else if not IsLoading then
      CellText := ''
    else if Column = VstTransStatus_RemianTime then
      CellText := MyTime.getMyTimeStr(Data.RemianTime)
    else
      CellText := '';
  end;
end;

procedure TfrmMainForm.WMQueryEndSession(var Message: TMessage);
begin
  try
    Message.Result := 1;
    if not App_IsExit then
      tbtnExit.Click;
  except
  end;

end;

{ TDropFileHandle }

procedure TDropFileHandle.AddLocalBackupDes;
var
  i: Integer;
  FilePath: string;
  AddLocalBackupDesHandle : TAddLocalBackupDesHandle;
begin
  for i := 0 to FilePathList.Count - 1 do
  begin
    FilePath := FilePathList[i];

    if not DirectoryExists(FilePath) then // ֻ���Ŀ¼
      Continue;

    AddLocalBackupDesHandle := TAddLocalBackupDesHandle.Create( FilePath );
    AddLocalBackupDesHandle.Update;
    AddLocalBackupDesHandle.Free;
  end;
end;

procedure TDropFileHandle.AddBackupItem;
var
  AddBackupItemHandle : TAddBackupItemHandle;
begin
  AddBackupItemHandle := TAddBackupItemHandle.Create( FilePathList );
  AddBackupItemHandle.Update;
  AddBackupItemHandle.Free;
end;

procedure TDropFileHandle.AddFileBackup;
var
  AddDropBackupFile : TAddDropBackupFile;
begin
  AddDropBackupFile := TAddDropBackupFile.Create( FilePathList );
  AddDropBackupFile.Update;
  AddDropBackupFile.Free;
end;

procedure TDropFileHandle.AddFileSend;
begin
  frmSelectTransfer.ShowSelectDes(FilePathList);
end;

procedure TDropFileHandle.AddFileShare;
var
  i: Integer;
  FilePath: string;
begin
  for i := 0 to FilePathList.Count - 1 do
  begin
    FilePath := FilePathList[i];
    MyFileShareControl.AddSharePath(FilePath);
  end;
end;

procedure TDropFileHandle.AddFileTransferDes;
var
  DesPcList: TStringList;
  vstFileTransferDes: TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstFileTransferDesData;
  CheckFileShendFreeLimit: TCheckFileSendFreeLimit;
  IsFreeLimit: Boolean;
begin
  DesPcList := TStringList.Create;

  // Ѱ��Ŀ��Pc
  vstFileTransferDes := frmMainForm.vstFileTransferDes;
  Node := vstFileTransferDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    if vsSelected in Node.States then
    begin
      NodeData := vstFileTransferDes.GetNodeData(Node);
      DesPcList.Add(NodeData.PcID);
    end;
    Node := Node.NextSibling;
  end;

  // ��ѡ�����
  if DesPcList.Count = 0 then
  begin
    Node := vstFileTransferDes.GetNodeAt(DragFile_FileTransferDesLastX,
      DragFile_FileTransferDesLastY);
    if Assigned(Node) then
    begin
      vstFileTransferDes.Selected[Node] := True;
      NodeData := vstFileTransferDes.GetNodeData(Node);
      DesPcList.Add(NodeData.PcID);
    end
    else
      AddFileSend;
  end;

  // ��� �Ƿ��� ���ð�����
  CheckFileShendFreeLimit := TCheckFileSendFreeLimit.Create(FilePathList);
  IsFreeLimit := CheckFileShendFreeLimit.get;
  CheckFileShendFreeLimit.Free;

  // �����ļ�
  if not IsFreeLimit and (DesPcList.Count > 0) then
    MyFileTransferControl.AddSendFile(FilePathList, DesPcList);

  DesPcList.Free;
end;

procedure TDropFileHandle.AddLocalBackupSource;
var
  AddLocalBackupSourceHandle : TAddLocalBackupSourceDefaultHandle;
begin
  AddLocalBackupSourceHandle := TAddLocalBackupSourceDefaultHandle.Create( FilePathList );
  AddLocalBackupSourceHandle.Update;
  AddLocalBackupSourceHandle.Free;
end;

constructor TDropFileHandle.Create(_Msg: TMessage);
begin
  Msg := _Msg;
  FilePathList := TStringList.Create;
end;

destructor TDropFileHandle.Destroy;
begin
  FilePathList.Free;
  inherited;
end;

procedure TDropFileHandle.FindDropFileType;
var
  PageIndex : Integer;
begin
  PageIndex := frmMainForm.PcMain.ActivePageIndex;
  if PageIndex = NbPage_LocalFileStatus then
  begin
    if DropFile_IsLocalBackupSource then
      DropFileType := DropFileType_LocalBackupFile
    else
      DropFileType := DropFileType_LocalDesFolder;
  end
  else
  if ( PageIndex = NbPage_FileStatus ) then
  begin
    if frmMainForm.PcBackup.ActivePage = frmMainForm.tsCloudBackup then
      DropFileType := DropFileType_BackupFile
    else
    if frmMainForm.PcBackup.ActivePage = frmMainForm.tsBackup then
      DropFileType := DropFileType_Backup;
  end
  else
  if ( PageIndex = NbPage_FileTransfer ) and
     ( frmMainForm.PcFileTransfer.ActivePage = frmMainForm.tsFileSend )
  then
  begin
    if DragFile_IsFileTransferDes then
      DropFileType := DropFileType_FileTransferDes
    else
      DropFileType := DropFileType_SendFile;
  end
  else
  if ( PageIndex = NbPage_FileShare ) and
     ( frmMainForm.PcFileShare.ActivePage = frmMainForm.tsSharePath )
  then
    DropFileType := DropFileType_FileShare;
end;

procedure TDropFileHandle.FindFilePathList;
var
  FilesCount: Integer; // �ļ�����
  i: Integer;
  FileName: array [0 .. 255] of Char;
  FilePath: string;
begin
  // ��ȡ�ļ�����
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);

  try
    // ��ȡ�ļ���
    for i := 0 to FilesCount - 1 do
    begin
      DragQueryFile(Msg.WParam, i, FileName, 256);
      FilePath := FileName;
      FilePath := MyFilePath.getLinkPath( FilePath );
      FilePathList.Add(FilePath);
    end;
  except
  end;

  // �ͷ�
  DragFinish(Msg.WParam);
end;

procedure TDropFileHandle.ResetStatus;
begin
  frmMainForm.plFileTransferDesMulti.Visible := False;

  DragFile_IsFileTransferDes := False;
  DragFile_FileTransferDesStart := True;
  DragFile_FileTransferDesLastX := 0;
  DragFile_FileTransferDesLastY := 0;

  DropFile_IsLocalBackupSource := True;
end;

procedure TDropFileHandle.ShowMainForm;
begin
  SetForegroundWindow(frmMainForm.Handle);
end;

procedure TDropFileHandle.Update;
begin
  // Ѱ���϶����ļ��б�
  FindFilePathList;
  FindDropFileType;

  // ��ͬ�Ĵ���
  if DropFileType = DropFileType_BackupFile then
    AddBackupItem
  else if DropFileType = DropFileType_LocalBackupFile then
    AddLocalBackupSource
  else if DropFileType = DropFileType_LocalDesFolder then
    AddLocalBackupDes
  else if DropFileType = DropFileType_SendFile then
    AddFileSend
  else if DropFileType = DropFileType_FileTransferDes then
    AddFileTransferDes
  else if DropFileType = DropFileType_FileShare then
    AddFileShare
  else if DropFileType = DropFileType_Backup then
    AddFileBackup;

  // ����״̬
  ResetStatus;

    // ��ʾ����
  ShowMainForm;
end;

{ TFolderTransferEnter }

procedure TFolderTransferEnter.HideMainFormControl;
begin
  DefaultPage_MainForm := NbPage_FileTransfer;
  with frmMainForm do
  begin
    tbtnLocalBackup.Visible := False;
    tbtnBackup.Visible := False;
    spMain1.Visible := False;
  end;
end;

procedure TFolderTransferEnter.ResetAboutForm;
var
  NewIcon: TIcon;
begin
  // FormIcon
  NewIcon := TIcon.Create;
  frmMainForm.ilTbMf16.GetIcon(7, NewIcon);
  frmAbout.Icon := NewIcon;
  NewIcon.Free;

  frmAbout.nbMain.PageIndex := PageIndex_FolderTransfer;
end;

procedure TFolderTransferEnter.ResetBroadcast;
begin
  UdpPort_Broadcast := 7542;
end;

procedure TFolderTransferEnter.ResetConfigPath;
begin
  AppData_Name := 'FolderTransfer';
  RegKey_Root := '\Software\FolderTransfer';
  Default_CloudPathName := 'FolderTransfer.Backup';
  Default_ReceivePathName := 'FolderTransfer.Receive';
  Default_SearchDownPathName := 'FolderTransfer.Download';
  Default_DownloadPathName := 'FolderTransfer.Download';
end;

procedure TFolderTransferEnter.ResetConnaPc;
begin
  DefaultPort_ConnPc := '8585';
end;

procedure TFolderTransferEnter.ResetFileTransfer;
begin
  with frmMainForm do
  begin
    lbFileSendTips.Caption := MyAppEdition.ReplaceFs( lbFileSendTips.Caption );
    lbFileReceiveTips.Caption := MyAppEdition.ReplaceFs( lbFileReceiveTips.Caption );
  end;

  with frmSelectTransfer do
    lbFileSendTips.Caption := MyAppEdition.ReplaceFs( lbFileSendTips.Caption );
end;

procedure TFolderTransferEnter.ResetFreeEditionForm;
begin
  with frmFreeEdition do
  begin
    lvEditionCompare.Items.Delete(0);
  end;
end;

procedure TFolderTransferEnter.ResetMainForm;
var
  NewIcon: TIcon;
  mi : TMenuItem;
begin
  // FormIcon
  NewIcon := TIcon.Create;
  frmMainForm.ilTbMf16.GetIcon(7, NewIcon);
  frmMainForm.Icon := NewIcon;
  NewIcon.Free;

  frmMainForm.Caption := 'Folder Transfer';

   // TrayIcon
  NewIcon := TIcon.Create;
  frmMainForm.ilTbMf16.GetIcon(7, NewIcon);
  frmMainForm.tiApp.Icon := NewIcon;
  frmMainForm.tiApp.Hint := 'Folder Transfer';
  NewIcon.Free;


  mi := TMenuItem.Create( frmMainForm );
  mi.Caption := 'Backup + Sync + Transfer';
  mi.ImageIndex := 4;
  mi.OnClick := frmMainForm.BackupCow1Click;
  frmMainForm.pmHelp.Items.Insert( 6, mi );

  with frmMainForm.lbRemotePcNotConn do
    Caption := MyAppEdition.ReplaceFs( Caption );
end;

procedure TFolderTransferEnter.ResetHomePage;
begin
  Url_AppHomePage := Url_FolderTranferHome;
end;

procedure TFolderTransferEnter.ResetJoinaGroup;
begin
  ShowHint_RunApp := MyAppEdition.ReplaceFs( ShowHint_RunApp );
end;

procedure TFolderTransferEnter.ResetTcpPort;
begin
  Default_LanPort := 8585;
  UpnpPort_Start := 25250;
end;

procedure TFolderTransferEnter.ResetSettingForm;
begin
  with frmSetting do
  begin
    tsBackup.TabVisible := False;
    tsPrivacy.TabVisible := False;
    tsFileSearch.TabVisible := False;
    plCloudShareSettings.Visible := False;
    plCloudSafeSetting.Visible := False;
    chkShowRemote.Visible := False;

    tsCloud.Caption := 'Group ID';
    chkIsCloudID.Caption := 'Group Security ID Number';
    gbCloudSafe.Caption := 'Group Security';
    lbCloudSafe.Caption := 'Only allow computers with a same security ID to connect together to form a network.'
  end;
end;

procedure TFolderTransferEnter.Update;
begin
  ResetConfigPath;
  ResetBroadcast;
  ResetTcpPort;
  ResetHomePage;

  ResetMainForm;
  HideMainFormControl;
  ResetFileTransfer;
  ResetConnaPc;
  ResetJoinaGroup;
  ResetSettingForm;
  ResetAboutForm;
  ResetFreeEditionForm;
end;

{ TBackupCowLiteEnter }

procedure TBackupCowLiteEnter.HindeMainFormControl;
begin
  with frmMainForm do
  begin
    tbtnLocalBackup.Visible := False;
    tbtnFileTransfer.Visible := False;
    tbtnFileShare.Visible := False;
    tbNetwork.Visible := False;
    tbRestoreNetwork.Visible := False;
    sbNetworkMode.Visible := False;
  end;
end;

procedure TBackupCowLiteEnter.ResetFreeEditionForm;
var
  i: Integer;
begin
  with frmFreeEdition do
  begin
    for i := lvEditionCompare.Items.Count - 1 downto 1 do
      lvEditionCompare.Items.Delete(i);
  end;
end;

procedure TBackupCowLiteEnter.ResetMainForm;
begin
  with frmMainForm do
  begin
    tbNetworkPc.Visible := True;
    tsCloudBackup.Caption := 'Backup to Local Network';
    tsCloudBackup.Hint := 'Backup between local network computers';
    Caption := 'Backup Cow - Lite Edition';
  end;
end;

procedure TBackupCowLiteEnter.ResetSettingForm;
begin
  with frmSetting do
  begin
    plCloudSafeSetting.Visible := False;
    tsPrivacy.TabVisible := False;
    tsRemoveNetwork.TabVisible := False;
    plFileTransferManger.Visible := False;
    tsFileTransfer.TabVisible := False;
  end;
end;

procedure TBackupCowLiteEnter.Update;
begin
  HindeMainFormControl;
  ResetSettingForm;
  ResetFreeEditionForm;
  ResetMainForm;
end;

{ TAddLocalBackupSourceHandle }

constructor TAddLocalBackupSourceHandle.Create( _SourcePathList : TStringList );
begin
  SourcePathList := _SourcePathList;
end;

function TAddLocalBackupSourceHandle.IsIncludeDes(ItemPath: string): Boolean;
var
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;
  Node := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := VstLocalBackupSource.GetNodeData(Node);
    // ���ܰ���Ŀ��·��
    if MyMatchMask.CheckEqualsOrChild(NodeData.FullPath, ItemPath) then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

function TAddLocalBackupSourceHandle.IsSourceInclude(ItemPath: string): Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  Result := False;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;

      // ���ڸ�·��
    if MyMatchMask.CheckEqualsOrChild(ItemPath, SourcePath) then
    begin
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TAddLocalBackupSourceHandle.RemoveChild(ItemPath: string);
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;
        // ɾ����·��
    if MyMatchMask.CheckChild( SourcePath, ItemPath ) then
      MyLocalBackupSourceControl.RemoveSourcePath( SourcePath );

    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TAddLocalBackupSourceHandle.Update;
var
  i : Integer;
  ItemPath, ShowErrorStr : string;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;

  for i := 0 to SourcePathList.Count - 1 do
  begin
    ItemPath := SourcePathList[i];

      // Դ·�� ���� ��ӵ�·��
    if IsSourceInclude( ItemPath ) then
    begin
      ShowErrorStr := Format(ShowForm_BackupItemExist, [ItemPath]);
      MyMessageBox.ShowWarnning(ShowErrorStr);
      Break;
    end;

      // ��ӵ�·�� ���� Ŀ��·��
    if IsIncludeDes( ItemPath ) then
    begin
      ShowErrorStr := Format(ShowForm_LocalBackupDesItemExist, [ItemPath]);
      MyMessageBox.ShowWarnning(ShowErrorStr);
      Continue;
    end;

      // ��ɾ�� ��·����Ȼ�����
    RemoveChild( ItemPath );
    AddSourcePath( ItemPath );
  end;
end;

{ VstMyBackupDestinationUtil }

class procedure VstMyBackupDestinationUtil.SetIsBackup(IsBackup: Boolean);
var
  VstMyBackupDes : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstMyBackupDesData;
begin
  VstMyBackupDes := frmMainForm.VstMyBackupDes;

  SelectNode := VstMyBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstMyBackupDes.Selected[ SelectNode ] then
    begin
      SelectData := VstMyBackupDes.GetNodeData( SelectNode );
      SelectData.IsBackup := IsBackup;
      VstMyBackupDes.RepaintNode( SelectNode );

      MyNetworkControl.SetIsBackupDes( SelectData.PcID, IsBackup );
    end;
    SelectNode := SelectNode.NextSibling;
  end;

  frmMainForm.tbtnMyCloudBackup.Enabled := not IsBackup;
  frmMainForm.tbtnMyCloudNotBackup.Enabled := IsBackup;
end;

{ VstCloudComputerUtil }

class function VstCloudComputerUtil.getIsSpaceCol(Col: Integer): Boolean;
begin
  Result := ( Col = vstCloudPc_TotalSpace ) or
            ( Col = vstCloudPc_UsedSpace ) or
            ( Col = vstCloudPc_AvailableSpace ) or
            ( Col = vstCloudPc_BackupSpace );
end;

class procedure VstCloudComputerUtil.ShowComputerInfo;
var
  cols : TVirtualTreeColumns;
  i : Integer;
begin
  cols := frmMainForm.vstCloudPc.Header.Columns;
  for i := 1 to cols.Count - 1 do
    if not getIsSpaceCol( i ) then
      cols[i].Options := cols[i].Options + [coVisible]
    else
      cols[i].Options := cols[i].Options - [coVisible]
end;

class procedure VstCloudComputerUtil.ShowSpaceInfo;
var
  cols : TVirtualTreeColumns;
  i : Integer;
begin
  cols := frmMainForm.vstCloudPc.Header.Columns;
  for i := 1 to cols.Count - 1 do
    if getIsSpaceCol( i ) then
      cols[i].Options := cols[i].Options + [coVisible]
    else
      cols[i].Options := cols[i].Options - [coVisible]
end;

{ TAddBackupItemHandle }

procedure TAddBackupItemHandle.AddPath(ItemPath: string);
begin
  MyBackupFileControl.AddBackupPath( ItemPath );
end;

constructor TAddBackupItemHandle.Create(_BackupPathList: TStringList);
begin
  BackupPathList := _BackupPathList;
end;

function TAddBackupItemHandle.IsInclude(ItemPath: string): Boolean;
var
  vstBackupItem : TVirtualStringTree;
  RootNode: PVirtualNode;
  RootData: PVstBackupItemData;
  FullPath: string;
begin
  Result := False;

  vstBackupItem := frmMainForm.vstBackupItem;
  RootNode := vstBackupItem.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    RootData := vstBackupItem.GetNodeData(RootNode);
    FullPath := RootData.FolderName;

    // ���ڸ�·��
    if MyMatchMask.CheckEqualsOrChild(ItemPath, FullPath) then
    begin
      Result := True;
      Break;
    end;

    RootNode := RootNode.NextSibling;
  end;
end;


procedure TAddBackupItemHandle.RemoveChild(ItemPath: string);
var
  vstBackupItem : TVirtualStringTree;
  RootNode: PVirtualNode;
  RootData: PVstBackupItemData;
  FullPath: string;
begin
  vstBackupItem := frmMainForm.vstBackupItem;
  RootNode := vstBackupItem.RootNode.FirstChild;
  while Assigned(RootNode) do
  begin
    RootData := vstBackupItem.GetNodeData(RootNode);
    FullPath := RootData.FolderName;

    // ɾ����·��
    if MyMatchMask.CheckChild(FullPath, ItemPath) then
      MyBackupFileControl.RemoveBackupPath(FullPath);

    RootNode := RootNode.NextSibling;
  end;
end;

procedure TAddBackupItemHandle.Update;
var
  i : Integer;
  ItemPath, ShowErrorStr : string;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    ItemPath := BackupPathList[i];
        // �Ѵ��� ���ڵ�
    if IsInclude( ItemPath ) then
    begin
      ShowErrorStr := Format( ShowForm_BackupItemExist, [ItemPath] );
      MyMessageBox.ShowWarnning(ShowErrorStr);
      Break;
    end;

      // ��ɾ�� ��·����Ȼ�� ���·��
    RemoveChild( ItemPath );

      // ���
    AddPath( ItemPath );
  end;
end;

{ TAddLocalBackupDesHandle }

constructor TAddLocalBackupDesHandle.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

procedure TAddLocalBackupDesHandle.AddSourceBackupPath;
var
  BackupPathList : TStringList;
  i : Integer;
  BackupPath : string;
  HasBackupPath : Boolean;
begin
  BackupPathList := FrmLocalBackupProUtil.getBackupItemList;
  HasBackupPath := BackupPathList.Count > 0;
  frmSelectLocalBackupSource.SetDestination( DesPath );
  frmSelectLocalBackupSource.SetBackupItem( BackupPathList );
  BackupPathList.free;

  if not HasBackupPath or ( frmSelectLocalBackupSource.ShowModal = mrCancel ) then
    Exit;

  BackupPathList := frmSelectLocalBackupSource.getSelectItems;
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    MyLocalBackupSourceControl.AddSourceDesPath( BackupPath, DesPath );
    MyLocalBackupSourceControl.BackupSelected( BackupPath );
  end;
  BackupPathList.Free;
end;

function TAddLocalBackupDesHandle.IsDesExist: Boolean;
var
  VstLocalBackupDes : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;

  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  Node := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := frmMainForm.VstLocalBackupDes.GetNodeData(Node);
    // ���ܰ���Ŀ��·��
    if NodeData.FullPath = DesPath then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

function TAddLocalBackupDesHandle.IsSourceInclude: Boolean;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  Result := False;

  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;

      // ���ڸ�·��
    if MyMatchMask.CheckEqualsOrChild( DesPath, SourcePath ) then
    begin
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TAddLocalBackupDesHandle.Update;
var
  ShowErrorStr: string;
begin
    // ��ӵ�·�� �Ѵ���
  if IsDesExist then
  begin
    ShowErrorStr := Format(ShowForm_LocalBackupDesItemExist, [DesPath]);
    MyMessageBox.ShowWarnning(ShowErrorStr);
    Exit;
  end;

     // ����Դ·�� �Ѱ��� ��ӵ�·��
  if IsSourceInclude then
  begin
    ShowErrorStr := Format(ShowForm_BackupItemExist, [DesPath]);
    MyMessageBox.ShowWarnning(ShowErrorStr);
    Exit;
  end;

    // ���
  MyLocalBackupDesControl.AddDesPath(DesPath);

    // ѡ��Դ·��
  AddSourceBackupPath;
end;

{ TAddBackupItemConfigHandle }

procedure TAddBackupItemConfigHandle.AddPath(ItemPath: string);
begin
  MyBackupFileControl.AddBackupPath( ItemPath, BackupConfigInfo );
end;

procedure TAddBackupItemConfigHandle.SetBackupConfigInfo(
  _BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

{ TAddFileSendHandle }

procedure TAddFileSendHandle.AddNewFile;
begin

end;

constructor TAddFileSendHandle.Create(_FileList, _PcList: TStringList);
begin
  FileList := _FileList;
  PcList := _PcList;
end;

procedure TAddFileSendHandle.RemoveExistFile;
begin

end;

procedure TAddFileSendHandle.Update;
begin
  RemoveExistFile;
  AddNewFile;
end;

{ TAddLocalBackupSourceConfigHandle }

procedure TAddLocalBackupSourceConfigHandle.AddSourcePath(ItemPath: string);
begin
  MyLocalBackupSourceControl.AddSourcePath( ItemPath, BackupConfig );
end;

procedure TAddLocalBackupSourceConfigHandle.SetConfig(
  _BackupConfig: TLocalBackupConfigInfo);
begin
  BackupConfig := _BackupConfig;
end;

{ TAddLocalBackupSourceDefaultHandle }

procedure TAddLocalBackupSourceDefaultHandle.AddSourcePath(ItemPath: string);
begin
  MyLocalBackupSourceControl.AddSourcePath( ItemPath, DesPathList );
end;

procedure TAddLocalBackupSourceDefaultHandle.DestoryDesPathList;
begin
  DesPathList.Free;
end;

procedure TAddLocalBackupSourceDefaultHandle.FindDesPathList;
var
  SourcePath : string;
begin
  DesPathList := VstLocalBackupDesUtil.getDesPathList;
  if DesPathList.Count <= 1 then  // ����ѡ��·��
    Exit;
  if SourcePathList.Count <= 0 then
    Exit;
  SourcePath := SourcePathList[0];

    // ����ѡ��·��
  frmselectlocalDes.SetLocalSource( SourcePath );
  frmselectlocalDes.SetBackupItem( DesPathList );

    // û��ѡ��
  if frmSelectLocalDes.ShowModal = mrCancel then
  begin
    DesPathList.Clear;
    Exit;
  end;

    // ��ȡ ѡ���·��
  DesPathList.Free;
  DesPathList := frmSelectLocalDes.getSelectItems;
end;

procedure TAddLocalBackupSourceDefaultHandle.Update;
begin
  FindDesPathList;

  inherited;

  DestoryDesPathList;
end;

{ TRestoreFileNowHandle }

procedure TRestoreFileNowHandle.AddRestoreItem(Path, PathType: string);
var
  SavePath : string;
  AddRestoreItemControl : TAddRestoreItemControl;
begin
  SavePath := RestoreSavePathUtil.getSavePath( Path, PathType );

  AddRestoreItemControl := TAddRestoreItemControl.Create( Path, RestorePcID );
  AddRestoreItemControl.SetPathInfo( PathType, SavePath );
  AddRestoreItemControl.SetEncryptInfo( False, '' );
  AddRestoreItemControl.Update;
  AddRestoreItemControl.Free;
end;

constructor TRestoreFileNowHandle.Create(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

procedure TRestoreFileNowHandle.Update;
var
  RestoreFileSearchAddInfo : TRestoreFileSearchAddInfo;
  NetPcBackupPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
begin
  RestoreSearch_IsQuick := True;
  RestoreQuick_RestorePcID := RestorePcID;

  RestoreFileSearchAddInfo := TRestoreFileSearchAddInfo.Create( RestorePcID );
  NetPcBackupPathHash := MyNetPcInfoReadUtil.ReadRestoreAblePath( RestorePcID );
  for p in NetPcBackupPathHash do
  begin
    AddRestoreItem( p.Value.FullPath, p.Value.PathType );
    RestoreFileSearchAddInfo.AddRestorePath( p.Value.FullPath, p.Value.PathType );
  end;
  NetPcBackupPathHash.Free;
  MyFileRestoreReq.AddChange( RestoreFileSearchAddInfo );
end;

{ TSearchDownloadHandle }

constructor TSearchDownloadHandle.Create(_DownloadPath: string);
begin
  DownloadPath := _DownloadPath;
end;

{ TRestoreFileAgainHandle }

constructor TRestoreFileAgainHandle.Create(_RestorePcID, _RestorePath: string);
begin
  RestorePcID := _RestorePcID;
  RestorePath := _RestorePath;
end;

procedure TRestoreFileAgainHandle.SetPathInfo(_PathType, _SavePath: string);
begin
  PathType := _PathType;
  SavePath := _SavePath;
end;

procedure TRestoreFileAgainHandle.Update;
var
  AddRestoreItemControl : TAddRestoreItemControl;
  RestoreFileSearchAddInfo : TRestoreFileSearchAddInfo;
begin
  RestoreSearch_IsQuick := True;
  RestoreQuick_RestorePcID := RestorePcID;

    // ��� Restore Item
  AddRestoreItemControl := TAddRestoreItemControl.Create( RestorePath, RestorePcID );
  AddRestoreItemControl.SetPathInfo( PathType, SavePath );
  AddRestoreItemControl.SetEncryptInfo( False, '' );
  AddRestoreItemControl.Update;
  AddRestoreItemControl.Free;

    // ���� �ָ��ļ�
  RestoreFileSearchAddInfo := TRestoreFileSearchAddInfo.Create( RestorePcID );
  RestoreFileSearchAddInfo.AddRestorePath( RestorePath, PathType );
  MyFileRestoreReq.AddChange( RestoreFileSearchAddInfo );
end;

{ MainFormUtil }

class procedure MainFormUtil.IniRestoreNow;
begin
    // ��ʼ����������
  with frmMainForm do
  begin
    lbSearching.Visible := True;
    lbFiles.Visible := True;
    lbSearching.Caption := frmMainForm.siLang_frmMainForm.GetText( 'Searching' );
    lbFiles.Caption := Format( frmMainForm.siLang_frmMainForm.GetText( 'SearchCount' ), [0] );
  end;
  RestoreFile_SearchCount := 0;
end;

{ TAddDropBackupFile }

constructor TAddDropBackupFile.Create(_FilePathList: TStringList);
begin
  FilePathList := _FilePathList;
end;

procedure TAddDropBackupFile.FindDropBackupInfo;
var
  SelectNode : PVirtualNode;
  NodeData, ParentData : PVstBackupData;
begin
  IsAddLocalDes := False;
  IsAddLocalBackup := False;
  IsAddNetworkBackup := False;

  with frmMainForm do
  begin
    SelectNode := VstBackup.GetNodeAt( DragFile_FileBackupLastX, DragFile_FileBackupLastY );
    if not Assigned( SelectNode ) then
      Exit;
    NodeData := VstBackup.GetNodeData( SelectNode );
    if NodeData.NodeType = BackupNodeType_NetworkDes then
    begin
      IsAddNetworkBackup := True;
      ItemID := NodeData.ItemID;
    end
    else
    if ( NodeData.NodeType = BackupNodeType_LocalDes ) and
       Assigned( SelectNode.Parent )
    then
    begin
      ParentData := VstBackup.GetNodeData( SelectNode.Parent );
      IsAddLocalBackup := True;
      ItemID := NodeData.ItemID;
    end;
  end;
end;

procedure TAddDropBackupFile.Update;
var
  i: Integer;
  FilePath: string;
begin
  FindDropBackupInfo;

  for i := 0 to FilePathList.Count - 1 do
  begin
    FilePath := FilePathList[i];
    if IsAddLocalDes then
      DesItemUserApi.AddLocalItem( FilePath )
    else
    if IsAddLocalBackup then
      BackupItemUserApi.AddItem( ItemID, FilePath )
    else
    if IsAddNetworkBackup then
      BackupItemUserApi.AddItem( ItemID, FilePath );
  end;
end;

{ TSelectBackupItemHandle }

procedure TSelectBackupItemHandle.AddNewSelectedItem;
var
  BackupConfigInfo : TBackupConfigInfo;
  BackupPathList : TStringList;
  LocaDesList, NetworkDesList : TStringList;
  i, j : Integer;
begin
  BackupConfigInfo := frmSelectBackupItem.getBackupConfigInfo;

  BackupPathList := frmSelectBackupItem.getNewSelectPathList;
  LocaDesList := frmSelectBackupItem.getLocalDesList;
  NetworkDesList := frmSelectBackupItem.getNetworkDesList;
  for i := 0 to LocaDesList.Count - 1 do
    for j := 0 to BackupPathList.Count - 1 do
      BackupItemUserApi.AddItem( LocaDesList[i], BackupPathList[j], BackupConfigInfo );
  for i := 0 to NetworkDesList.Count - 1 do
    for j := 0 to BackupPathList.Count - 1 do
      BackupItemUserApi.AddItem( NetworkDesList[i], BackupPathList[j], BackupConfigInfo );
  NetworkDesList.Free;
  LocaDesList.Free;
  BackupPathList.Free;

  BackupConfigInfo.Free;
end;

procedure TSelectBackupItemHandle.AddOldSelectedItem;
var
  VstBackup : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstBackupData;
  BackupPathList : TStringList;
  DesPath, DesPcID : string;
begin
    // ��վ�ѡ��
  frmSelectBackupItem.ClearLastSelected;

  VstBackup := frmMainForm.VstBackup;
  SelectNode := VstBackup.FocusedNode;
  if not Assigned( SelectNode ) then
    Exit;

  if SelectNode.Parent <> VstBackup.RootNode then
    SelectNode := SelectNode.Parent;
  NodeData := VstBackup.GetNodeData( SelectNode );

  DesPath := '';
  DesPcID := '';
  if NodeData.NodeType = BackupNodeType_LocalDes then
  begin
    DesPath := NodeData.ItemID;
    BackupPathList := DesItemInfoReadUtil.ReadBackupList( NodeData.ItemID );
  end
  else
  begin
    DesPcID := NodeData.ItemID;
    BackupPathList := DesItemInfoReadUtil.ReadBackupList( NodeData.ItemID );
  end;

  frmSelectBackupItem.AddLocalDes( DesPath );
  frmSelectBackupItem.AddNetworkDes( DesPcID );
  frmSelectBackupItem.AddOldSelectPath( BackupPathList );

  BackupPathList.Free;
end;

procedure TSelectBackupItemHandle.Update;
begin
    // ����ѡ���·��
  AddOldSelectedItem;

    // �û�ѡ��·��
  if frmSelectBackupItem.ShowModal <> mrOK then
    Exit;

    // �����ѡ��·��
  AddNewSelectedItem;
end;

end.
