unit UFormRestorePath;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, UMyUtil, IniFiles,
  ExtCtrls,FileCtrl, ImgList, ToolWin, Menus,
  VirtualTrees, RzLabel, RzPanel, UFormUtil, UModelUtil, Generics.Collections,
  siComp;

type

    // �ָ�·�� ������Ϣ
  TRestorePasswordInfo = class
  public
    FullPath : string;
    Password : string;
  public
    constructor Create( _FullPath, _Password : string );
  end;
  TRestorePasswordPair = TPair< string , TRestorePasswordInfo >;
  TRestorePasswordHash = class(TStringDictionary< TRestorePasswordInfo >);


  TfrmRestore = class(TForm)
    plBottom: TPanel;
    plLeft: TPanel;
    PlMain: TPanel;
    PlMainCenter: TPanel;
    nbMain: TNotebook;
    plCloudPc: TPanel;
    lvRestorePcID: TListView;
    plBackupPath: TPanel;
    lvRestoreBackupPath: TListView;
    Image2: TImage;
    ilTbRestorePath: TImageList;
    ilpmTbRestore: TImageList;
    plRestoreFile: TPanel;
    Panel3: TPanel;
    btnBack: TButton;
    btnCancel: TButton;
    btnNext: TButton;
    plSavePath: TPanel;
    tbRestoreSavePath: TToolBar;
    tbtnChangeSavePath: TToolButton;
    lvRestoreSavePath: TListView;
    plRestoreResult: TPanel;
    Panel5: TPanel;
    vstRestoreFile: TVirtualStringTree;
    lvUavailablePath: TListView;
    sl1: TSplitter;
    plDecrypt: TPanel;
    lvDecrypt: TListView;
    plPasswordTop: TPanel;
    lbEncryptPassword: TLabel;
    edtEncryptPassword: TEdit;
    btnEncryptPasswordOK: TButton;
    lbEncryptPasswordHint: TLabel;
    edtEncryptPasswordHint: TEdit;
    tbRetoerBackupPath: TToolBar;
    tbtnSelectAllPath: TToolButton;
    tbtnRemoveAll: TToolButton;
    tbtnRestoreFile: TToolButton;
    PlMainTop: TPanel;
    Image1: TImage;
    ilPmTbRestoreGray: TImageList;
    plTitle: TRzPanel;
    tbRestoreFile: TToolBar;
    tbtnFileSelectAll: TToolButton;
    tbtnFileUnSelectAll: TToolButton;
    ToolButton1: TToolButton;
    slUnRestorePath: TSplitter;
    LvUnavailableRestorePath: TListView;
    tbtnRestorePathPro: TToolButton;
    ToolButton2: TToolButton;
    tbRestorePc: TToolBar;
    tbtnPcRefresh: TToolButton;
    tbtnPcPro: TToolButton;
    tbtnExplorer: TToolButton;
    ToolButton3: TToolButton;
    btnRestoreNow: TButton;
    ilTbRestorePathGray: TImageList;
    siLang_frmRestore: TsiLang;
    Panel1: TPanel;
    lbSearching: TLabel;
    lbFiles: TLabel;
    procedure lvRestorePcIDDeletion(Sender: TObject; Item: TListItem);
    procedure btnCancelClick(Sender: TObject);
    procedure nbMainPageChanged(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvRestorePcIDSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvRestorePcIDDblClick(Sender: TObject);
    procedure lvRestoreBackupPathDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnSelectAllPathClick(Sender: TObject);
    procedure tbtnRemoveAllClick(Sender: TObject);
    procedure lvRestoreBackupPathClick(Sender: TObject);
    procedure vstRestoreFileFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstRestoreFileGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure FormCreate(Sender: TObject);
    procedure lvUavailablePathDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnFileSelectAllClick(Sender: TObject);
    procedure tbtnFileUnSelectAllClick(Sender: TObject);
    procedure vstRestoreFileClick(Sender: TObject);
    procedure lvRestoreSavePathDeletion(Sender: TObject; Item: TListItem);
    procedure lvRestoreSavePathSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbtnChangeSavePathClick(Sender: TObject);
    procedure lvDecryptDeletion(Sender: TObject; Item: TListItem);
    procedure lvDecryptSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnEncryptPasswordOKClick(Sender: TObject);
    procedure vstRestoreFileGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tbtnRestoreFileClick(Sender: TObject);
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormDestroy(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure tbtnRestorePathProClick(Sender: TObject);
    procedure tbtnPcRefreshClick(Sender: TObject);
    procedure tbtnPcProClick(Sender: TObject);
    procedure tbtnExplorerClick(Sender: TObject);
    procedure lvRestoreBackupPathSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnRestoreNowClick(Sender: TObject);
    procedure lvRestoreBackupPathDblClick(Sender: TObject);
    procedure siLang_frmRestoreChangeLanguage(Sender: TObject);
  private
    procedure BindToolBar;
    procedure BindSysItemIcon;
    procedure BindSort;
  private         // Set ����
    procedure SetBackupPathCheck( IsCheck : Boolean );
    procedure SetRestoreFileCheck( IsCheck : Boolean );overload;
    procedure SetRestoreFileCheck( ParentNode : PVirtualNode; CheckState : TCheckState );overload;
  public
    RestorePcID : string;
    IsEncrypted : Boolean;
    RestorePasswordHash : TRestorePasswordHash;
  private
    procedure CloudRestoreFileBack;
  private
    procedure EnterNextPage;
    procedure EnterBackPage;
    procedure ShowTitle;
  private
    procedure NextClick;
    procedure OKClick;
  public
    procedure ReadRestorePcList; // ���� Restore Pc �б�
    procedure RestorePc( PcID : string );
  end;

{$Region ' ������ ' }

  RestoreFormUtil = class
  public
    class function getExplorerPath : string;
  end;

{$EndRegion}

{$Region ' Btn Next/Back ' }

    // Restore Path Next
  TRestorePathNextClick = class
  public
    procedure Update;
  private
    procedure IniRestoreInfo;
    procedure AddUnavailablePath;
    procedure AddRestorePathDetail;
    procedure AddToSearch;
  end;

    // Click Next
  TBtnRestoreNextClick = class
  public
    procedure Update;
  private
    procedure RestorePcNext;
    procedure RestorePathNext;
    procedure RestoreFileNext;
    procedure RestoreSavePathNext;
  private
    function IsInvisiblePassword : Boolean;
    procedure EnterNextPage;
  end;

{$EndRegion}

{$Region ' Restore Computers ' }

    // ���ݽṹ
  TRestorePcItemData = class
  public
    PcID, PcName : string;
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetInvisibleInfo( _IsFileInvisible : Boolean; _IvPasswordMD5 : string );
  end;

    // ��ȡ Restore Pc ��Ϣ
  TReadRestorePcListHandle = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Restore Backup Path ' }

      // ����
  TLvBackupPathData = class
  public
    FullPath, PathType : string;
    FolderSpace : Int64;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetFolderSpace( _FolderSpace : Int64 );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
  end;

    // ��ȡ ·�� �б�
  TReadRestorePcBackupPathListHandle = class
  private
    RestorePcID : string;
    RestorePathList : TStringList;
  public
    constructor Create( _RestorePcID : string );
    procedure Update;
    destructor Destroy; override;
  private
    procedure ReadAvaliablePath;
    procedure ReadUnavaliablePath;
    procedure ReadRestorePathPro;
  end;

    // �ָ�����·��
  TRestoreSpecificPathHandle = class
  private
    RestorePcID : string;
  public
    constructor Create;
    procedure Update;
  private
    procedure AddRestoreItem( Path, PathType : string );
  end;

{$EndRegion}

{$Region ' Restore Save Path ' }

  TLvSavePathData = class
  public
    FullPath, PathType : string;
    SavePath : string;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetSavePath( _SavePath : string );
  end;

  RestoreSavePathUtil = class
  public
    class function getSavePath( FullPath, PathType : string ): string;
  end;

    // ��� Restore SavePath
  TRestoreSavePathAddHandle = class
  public
    FullPath, PathType : string;
  private
    SavePath : string;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure Update;
  private
    procedure FindSavePath;
    procedure AddListview;
  private
    procedure FindSaveFilePath;
    procedure FindSaveFolderPath;
  end;

{$EndRegion}

{$Region ' Restore Encrypted Path ' }

  TLvRestoreDecryptData = class
  public
    RestorePathList : TStringList;
    PasswordMD5 : string;
    PasswordHint : string;
  public
    constructor Create;
    procedure AddRestorePath( RestorePath : string );
    destructor Destroy; override;
  end;


    // ��� Retore DecryptPath
  TRestoreDecryptPathAddHanlde = class
  public
    FullPath, PathType : string;
    PasswordMD5, PasswordHint : string;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetPassword( _PasswordMD5, _PasswordHint : string );
    procedure Update;
  private
    function FindExistItem : Boolean;
    procedure AddNewItem;
  end;


{$EndRegion}

{$Region ' ���� Restore Items/Files '}

    // ����
  TFindChildRestoreJobBaseHandle = class
  private
    ParentNode : PVirtualNode;
  private
    FullPath, SavePath : string;
  public
    procedure SetParentNode( _ParentNode : PVirtualNode );
    procedure SetPathInfo( _FullPath, _SavePath : string );
    procedure Update;virtual;abstract;
  private
    procedure AddRestoreJob( ChildNode : PVirtualNode );
  end;

    // Find Child Node Restore File
  TFindChildRestoreJobHandle = class( TFindChildRestoreJobBaseHandle )
  public
    procedure Update;override;
  private
    procedure FindChildNode( ChildNode : PVirtualNode );
  end;

    // Find FileNode
  TFindFileRestoreJobHandle = class( TFindChildRestoreJobBaseHandle )
  public
    procedure Update;override;
  end;

    // Find Restore File
  TFindRestoreJobHandle = class
  public
    procedure Update;
  private
    function getRootNode( FullPath : string ): PVirtualNode;
  end;

{$EndRegion}

{$Region ' �ָ��ļ����� �ӿ� ' }

    // Add Restore Item
  TRestoreItemAddResultHandle = class
  public
    FullPath, SavePath : string;
    PathType : string;
    RestorePcID : string;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    constructor Create( _FullPath, _SavePath : string );
    procedure SetPathType( _PathType : string );
    procedure SetRestorePcID( _RestorePcID : string );
    procedure Update;
  private
    procedure FindEncryptInfo;
    procedure AddRestoreItem;
  end;

    // Add Restore Job
  TRestoreFileAddResultHandle = class
  public
    LocationID, FilePath : string;
    LocationName, DownFilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
    RestorePcID, RestoreRootPath : string;
  public
    constructor Create( _LocationID, _FilePath : string );
    procedure SetDownFileInfo( _LocationName, _DownFilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetRestoreRootPath( _RestoreRootPath : string );
    procedure Update;
  private
    procedure AddToRestoreFile;
    procedure AddToJob;
    procedure AddToRemoveUpPend;
  end;

{$EndRegion}

const
  NbPageIndex_pgCloudPc = 0;
  NbPageIndex_pgBackupPath = 1;
  NbPageIndex_pgRestoreFile = 2;
  NbPageIndex_pgSavePath = 3;
  NbPageIndex_pgDecrypt = 4;

  NbPageTitle_pgCloudPc = 'pgCloudPc';
  NbPageTitle_pgBackupPath = 'pgBackupPath';
  NbPageTitle_pgRestoreFile = 'pgRestoreFile';
  NbPageTitle_pgSavePath = 'pgSavePath';
  NbPageTitle_pgDecrypt = 'pgDecrypt';

  Ary_NbPageTitle : array[0..4] of string =
      (
         NbPageTitle_pgCloudPc, NbPageTitle_pgBackupPath,
         NbPageTitle_pgRestoreFile, NbPageTitle_pgSavePath,
         NbPageTitle_pgDecrypt
      );

  vst_FileName : Integer = 0;
  vst_Percent : Integer = 1;
  vst_FileSize : Integer = 2;
  vst_FileTime : Integer = 3;
  vst_FileLocation : Integer = 4;

  Encrypted_Yes = 'Yes';
  Encrypted_No = 'No';

  BtnNextCaption_Next = '&Next';
  BtnNextCaption_OK = 'OK';

  BtnNextTag_Next = 0;
  BtnNextTao_OK = 1;


  LvRestoreSavePath_RestorePath = 0;

//  MessageShow_SelectPathRestore : string = 'Please select folders you wish to save';
//  ShowHint_PasswordError : string = 'Password is incorrect.';

const
  RestoreForm_Title = 'Restore %s'' Files';

//const
//  Label_SearchCount = '%d Files';
//  Label_Searching = 'Searching...';
//  Label_SearchComplete = 'Search Completed';

var
  frmRestore: TfrmRestore;
  RestoreSearch_Files : Integer = 0;

implementation

uses UNetworkFace, UMyNetPcInfo, URestoreFileFace, UMyFileSearch, UMyBackupInfo,
     UIconUtil, UMyJobInfo, UJobFace, UMyClient, UMainForm, UFormRestoreDetail, UNetPcInfoXml,
     UMyRestoreFileXml, UMyRestoreFileInfo, UBackupInfoFace, UFormSearchOwnerDecrypt,
     UMyRestoreFileControl, UJobControl, UNetworkControl, UMyCloudPathInfo;

{$R *.dfm}

{ TfrmRestore }

procedure TfrmRestore.BindSort;
begin
  ListviewUtil.BindSort( lvRestorePcID );
  ListviewUtil.BindSort( lvRestoreBackupPath );
  ListviewUtil.BindSort( lvRestoreSavePath );
  ListviewUtil.BindSort( lvUavailablePath );
  ListviewUtil.BindSort( lvDecrypt );
end;

procedure TfrmRestore.BindSysItemIcon;
begin
  lvRestoreBackupPath.SmallImages := MyIcon.getSysIcon;
  vstRestoreFile.Images := MyIcon.getSysIcon;
  lvUavailablePath.SmallImages := MyIcon.getSysIcon;
  lvRestoreSavePath.SmallImages := MyIcon.getSysIcon;
  lvDecrypt.SmallImages := MyIcon.getSysIcon;
  LvUnavailableRestorePath.SmallImages := MyIcon.getSysIcon;
end;

procedure TfrmRestore.BindToolBar;
begin
  lvRestoreBackupPath.PopupMenu := FormUtil.getPopMenu( tbRetoerBackupPath );
  vstRestoreFile.PopupMenu := FormUtil.getPopMenu( tbRestoreFile );
  lvRestoreSavePath.PopupMenu := FormUtil.getPopMenu( tbRestoreSavePath );
  lvRestorePcID.PopupMenu := FormUtil.getPopMenu( tbRestorePc );
end;

procedure TfrmRestore.btnBackClick(Sender: TObject);
begin
  if nbMain.PageIndex = NbPageIndex_pgRestoreFile then
    CloudRestoreFileBack;

  nbMain.PageIndex := nbMain.PageIndex - 1;
  EnterBackPage;
end;

procedure TfrmRestore.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRestore.btnEncryptPasswordOKClick(Sender: TObject);
var
  LvRestoreDecryptData : TLvRestoreDecryptData;
  InputPassword, InputPasswordMD5, PasswordMD5 : string;
  i, SelectIndex : Integer;
  FullPath : string;
  RestoerPasswordInfo : TRestorePasswordInfo;
begin
  InputPassword := edtEncryptPassword.Text;
  InputPasswordMD5 := MyEncrypt.EncodeMD5String( InputPassword );

  LvRestoreDecryptData := lvDecrypt.Selected.Data;
  PasswordMD5 := LvRestoreDecryptData.PasswordMD5;

    // �������� ��ȷ
  if InputPasswordMD5 = PasswordMD5 then
  begin
      // ��¼ ���ܵ�·����Ϣ
    for i := 0 to LvRestoreDecryptData.RestorePathList.Count - 1 do
    begin
      FullPath := LvRestoreDecryptData.RestorePathList[i];
      RestoerPasswordInfo := TRestorePasswordInfo.Create( FullPath, InputPassword );
      RestorePasswordHash.AddOrSetValue( FullPath, RestoerPasswordInfo );
    end;

      // ɾ�� �ѽ��� Item
    SelectIndex := lvDecrypt.Selected.Index;
    lvDecrypt.Items.Delete( SelectIndex );
    if lvDecrypt.Items.Count <= 0 then
      frmRestore.btnNext.Click
    else
      lvDecrypt.Items[0].Selected := True;
  end
  else
    MyMessageHint.ShowError( edtEncryptPassword.Handle, siLang_frmRestore.GetText( 'PasswordError' ) );
end;

procedure TfrmRestore.btnNextClick(Sender: TObject);
begin
  if btnNext.Tag = BtnNextTag_Next then
    NextClick
  else
    OKClick;
end;

procedure TfrmRestore.btnRestoreNowClick(Sender: TObject);
var
  RestoreSpecificPathHandle : TRestoreSpecificPathHandle;
begin
  MainFormUtil.IniRestoreNow;

  RestoreSpecificPathHandle := TRestoreSpecificPathHandle.Create;
  RestoreSpecificPathHandle.Update;
  RestoreSpecificPathHandle.Free;

  Close;
end;

procedure TfrmRestore.SetBackupPathCheck(IsCheck: Boolean);
var
  i : Integer;
begin
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
    lvRestoreBackupPath.Items[i].Checked := IsCheck;

  btnNext.Enabled := IsCheck and ( lvRestoreBackupPath.Items.Count > 0 );
end;

procedure TfrmRestore.SetRestoreFileCheck(ParentNode: PVirtualNode;
  CheckState: TCheckState);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := ParentNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildNode.CheckState := CheckState;
    SetRestoreFileCheck( ChildNode, CheckState );
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmRestore.ShowTitle;
var
  ShowStr : string;
  StrList : TStringList;
begin
  ShowStr := siLang_frmRestore.GetText( Ary_NbPageTitle[ nbMain.PageIndex ] );
  StrList := MySplitStr.getList( ShowStr, '#13#10' );
  if StrList.Count = 2 then
    ShowStr := StrList[0] + #13#10 + StrList[1];
  StrList.Free;
  plTitle.Caption := ShowStr;
end;

procedure TfrmRestore.siLang_frmRestoreChangeLanguage(Sender: TObject);
begin
  with lvRestorePcID do
  begin
    Columns[ 0 ].Caption := siLang_frmRestore.GetText( 'lvRestorePcName' );
    Columns[ LvRestorePc_PcID + 1 ].Caption := siLang_frmRestore.GetText( 'lvPcID' );
  end;

  with lvRestoreBackupPath do
  begin
    Columns[ 0 ].Caption := siLang_frmRestore.GetText( 'lvRestorePath' );
    Columns[ 1 ].Caption := siLang_frmRestore.GetText( 'Files' );
    Columns[ 2 ].Caption := siLang_frmRestore.GetText( 'lvSize' );
    Columns[ 3 ].Caption := siLang_frmRestore.GetText( 'lvCopyQty' );
    Columns[ 4 ].Caption := siLang_frmRestore.GetText( 'Encrypted' );
  end;

  with LvUnavailableRestorePath do
  begin
    Columns[ 0 ].Caption := siLang_frmRestore.GetText( 'UnAvailablePath' );
    Columns[ 1 ].Caption := siLang_frmRestore.GetText( 'Files' );
    Columns[ 2 ].Caption := siLang_frmRestore.GetText( 'lvSize' );
    Columns[ 3 ].Caption := siLang_frmRestore.GetText( 'lvCopyQty' );
    Columns[ 4 ].Caption := siLang_frmRestore.GetText( 'Encrypted' );
  end;

  with vstRestoreFile.Header do
  begin
    Columns[0].Text := siLang_frmRestore.GetText( 'lvRestoreFileName' );
    Columns[1].Text := siLang_frmRestore.GetText( 'lvPercentage' );
    Columns[2].Text := siLang_frmRestore.GetText( 'lvFileSize' );
    Columns[4].Text := siLang_frmRestore.GetText( 'lvRestoreFrom' );
  end;

  with lvUavailablePath do
  begin
    Columns[0].Caption := siLang_frmRestore.GetText( 'UnAvailablePath' );
    Columns[1].Caption := siLang_frmRestore.GetText( 'lvSize' );
  end;

  with lvRestoreSavePath do
  begin
    Columns[0].Caption := siLang_frmRestore.GetText( 'lvRestorePath' );
    Columns[1].Caption := siLang_frmRestore.GetText( 'SavePath' );
  end;

  with lvDecrypt do
  begin
    Columns[0].Caption := siLang_frmRestore.GetText( 'lvEncryptedPath' );
  end;
end;

procedure TfrmRestore.SetRestoreFileCheck(IsCheck: Boolean);
var
  CheckState : TCheckState;
begin
  if IsCheck then
    CheckState := csCheckedNormal
  else
    CheckState := csUncheckedNormal;

  SetRestoreFileCheck( vstRestoreFile.RootNode, CheckState );
  vstRestoreFile.Refresh;
  btnNext.Enabled := IsCheck and ( vstRestoreFile.RootNode.ChildCount > 0 );
end;

procedure TfrmRestore.CloudRestoreFileBack;
var
  ResotreFileSearchStopInfo : TResotreFileSearchStopInfo;
begin
  ResotreFileSearchStopInfo := TResotreFileSearchStopInfo.Create;
  MyFileRestoreReq.InsertChange( ResotreFileSearchStopInfo );
end;


procedure TfrmRestore.EnterBackPage;
var
  IsShowBack, IsShowNext : Boolean;
  PageIndex : Integer;
  NextCaption : string;
  NextTag : Integer;
begin
  IsShowBack := True;
  IsShowNext := true;
  NextCaption := BtnNextCaption_Next;
  NextTag := BtnNextTag_Next;

  PageIndex := nbMain.PageIndex;
  if PageIndex = NbPageIndex_pgCloudPc then
    IsShowBack := False;

  btnBack.Enabled := IsShowBack;
  btnNext.Enabled := IsShowNext;
  btnNext.Caption := siLang_frmRestore.GetText( NextCaption );
  btnNext.Tag := NextTag;
end;

procedure TfrmRestore.EnterNextPage;
var
  IsShowBack, IsShowNext : Boolean;
  PageIndex : Integer;
  NextCaption : string;
  NextTag : Integer;
begin
  IsShowBack := True;
  IsShowNext := False;
  NextCaption := BtnNextCaption_Next;
  NextTag := BtnNextTag_Next;

  PageIndex := nbMain.PageIndex;
  if PageIndex = NbPageIndex_pgCloudPc then
    IsShowBack := False
  else
  if PageIndex = NbPageIndex_pgSavePath then
  begin
    IsShowNext := True;
    if not IsEncrypted then
    begin
      NextCaption := BtnNextCaption_OK;
      NextTag := BtnNextTao_OK;
    end;
  end
  else
  if PageIndex = NbPageIndex_pgDecrypt then
  begin
    NextCaption := BtnNextCaption_OK;
    NextTag := BtnNextTao_OK;
  end;

  btnBack.Enabled := IsShowBack;
  btnNext.Enabled := IsShowNext;
  btnNext.Caption := siLang_frmRestore.GetText( NextCaption );
  btnNext.Tag := NextTag;
end;

procedure TfrmRestore.FormCreate(Sender: TObject);
begin
  vstRestoreFile.NodeDataSize := SizeOf( TVstRestoreFileData );

  BindToolBar;
  BindSysItemIcon;
  BindSort;

  RestorePasswordHash := TRestorePasswordHash.Create;

  siLang_frmRestoreChangeLanguage( nil );
end;

procedure TfrmRestore.FormDestroy(Sender: TObject);
begin
  RestorePasswordHash.Free;
end;

procedure TfrmRestore.FormShow(Sender: TObject);
begin
  nbMain.PageIndex := NbPageIndex_pgCloudPc;
  if lvRestorePcID.Selected <> nil then
    lvRestorePcID.Selected.Selected := False;
  EnterNextPage;
  ShowTitle;
end;

procedure TfrmRestore.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  tbtnRestoreFile.Click;
end;

procedure TfrmRestore.lvRestoreSavePathDeletion(Sender: TObject;
  Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestore.lvRestoreSavePathSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  tbtnChangeSavePath.Enabled := Selected;
end;

procedure TfrmRestore.lvDecryptDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestore.lvDecryptSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  IsShowDecrypt : Boolean;
  LvRestoreDecryptData : TLvRestoreDecryptData;
begin
  IsShowDecrypt := Selected;

  if IsShowDecrypt then
  begin
    LvRestoreDecryptData := Item.Data;
    edtEncryptPasswordHint.Text := LvRestoreDecryptData.PasswordHint;
    edtEncryptPassword.Clear;
  end;

  lbEncryptPasswordHint.Visible := IsShowDecrypt;
  edtEncryptPasswordHint.Visible := IsShowDecrypt;
  lbEncryptPassword.Visible := IsShowDecrypt;
  edtEncryptPassword.Visible := IsShowDecrypt;
  btnEncryptPasswordOK.Visible := IsShowDecrypt;
end;

procedure TfrmRestore.lvRestoreBackupPathClick(Sender: TObject);
var
  i : Integer;
  IsShowNext : Boolean;
begin
  IsShowNext := False;
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
    if lvRestoreBackupPath.Items[i].Checked then
    begin
      IsShowNext := True;
      Break;
    end;
  btnNext.Enabled := IsShowNext;
  btnRestoreNow.Enabled := IsShowNext;
end;

procedure TfrmRestore.lvRestoreBackupPathDblClick(Sender: TObject);
begin
  if tbtnExplorer.Enabled then
    tbtnExplorer.Click;
end;

procedure TfrmRestore.lvRestoreBackupPathDeletion(Sender: TObject;
  Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestore.lvRestoreBackupPathSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  IsEnable : Boolean;
  SelectRestorePath : string;
begin
  if Selected then
  begin
    SelectRestorePath := RestoreFormUtil.getExplorerPath;
    IsEnable := FileExists( SelectRestorePath ) or DirectoryExists( SelectRestorePath );
  end
  else
    IsEnable := False;
  tbtnExplorer.Enabled := IsEnable;
end;

procedure TfrmRestore.lvRestorePcIDDblClick(Sender: TObject);
begin
  if btnNext.Enabled then
    btnNext.Click;
end;

procedure TfrmRestore.lvRestorePcIDDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestore.lvRestorePcIDSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  tbtnPcPro.Enabled := Selected;
  btnNext.Enabled := True;
end;

procedure TfrmRestore.lvUavailablePathDeletion(Sender: TObject;
  Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestore.nbMainPageChanged(Sender: TObject);
begin
  ShowTitle;
  btnRestoreNow.Visible := nbMain.PageIndex = NbPageIndex_pgBackupPath;
end;

procedure TfrmRestore.NextClick;
var
  BtnRestoreNextClick : TBtnRestoreNextClick;
begin
  BtnRestoreNextClick := TBtnRestoreNextClick.Create;
  BtnRestoreNextClick.Update;
  BtnRestoreNextClick.Free;
end;

procedure TfrmRestore.OKClick;
var
  FindRestoreJobHandle : TFindRestoreJobHandle;
begin
  frmRestore.Close;

  Application.ProcessMessages;

  FindRestoreJobHandle := TFindRestoreJobHandle.Create;
  FindRestoreJobHandle.Update;
  FindRestoreJobHandle.Free;
end;

procedure TfrmRestore.ReadRestorePcList;
var
  ReadRestorePcListHandle : TReadRestorePcListHandle;
begin
  ReadRestorePcListHandle := TReadRestorePcListHandle.Create;
  ReadRestorePcListHandle.Update;
  ReadRestorePcListHandle.Free;
end;

procedure TfrmRestore.RestorePc(PcID: string);
var
  i : Integer;
  ItemData : TRestorePcItemData;
begin
    // ��ȡ
  ReadRestorePcList;

    // ѡ��
  for i := 0 to lvRestorePcID.Items.Count - 1 do
  begin
    ItemData := lvRestorePcID.Items[i].Data;
    lvRestorePcID.Items[i].Selected := ItemData.PcID = PcID;
  end;

    // ��һ��
  btnNext.Click;
end;

var
  Restore_SavePath : string = '';
procedure TfrmRestore.tbtnChangeSavePathClick(Sender: TObject);
var
  ItemData : TLvSavePathData;
  ShowStr, FileName, SavePath : string;
  i : Integer;
begin
  ShowStr := siLang_frmRestore.GetText( 'SelectSave' );
  if MySelectFolderDialog.Select( ShowStr, Restore_SavePath, Restore_SavePath, Self.Handle ) then
  begin
    for i := 0 to lvRestoreSavePath.Items.Count - 1 do
    begin
      if not lvRestoreSavePath.Items[i].Selected then
        Continue;

      ItemData := lvRestoreSavePath.Items[i].Data;
      FileName := MyFileInfo.getFileName( ItemData.FullPath );
      FileName := MyFilePath.getDownloadPath( FileName );
      SavePath := MyFilePath.getPath( Restore_SavePath ) + FileName;

      ItemData.SavePath := SavePath;
      lvRestoreSavePath.Items[i].SubItems[ LvRestoreSavePath_RestorePath ] := SavePath;
    end;
  end;
end;

procedure TfrmRestore.tbtnExplorerClick(Sender: TObject);
begin
  MyExplore.OperFolder( RestoreFormUtil.getExplorerPath );
end;

procedure TfrmRestore.tbtnFileSelectAllClick(Sender: TObject);
begin
  SetRestoreFileCheck( True );
end;

procedure TfrmRestore.tbtnFileUnSelectAllClick(Sender: TObject);
begin
  SetRestoreFileCheck( False );
end;

procedure TfrmRestore.tbtnPcProClick(Sender: TObject);
var
  ItemData : TRestorePcItemData;
begin
  if lvRestorePcID.Selected = nil then
    Exit;
  ItemData := lvRestorePcID.Selected.Data;
  MyNetworkControl.ShowPcDetail( ItemData.PcID );
end;

procedure TfrmRestore.tbtnPcRefreshClick(Sender: TObject);
begin
  ReadRestorePcList;
end;

procedure TfrmRestore.tbtnRemoveAllClick(Sender: TObject);
begin
  SetBackupPathCheck( False );
end;

procedure TfrmRestore.tbtnRestoreFileClick(Sender: TObject);
begin
  frmRestore.Close;
  frmMainForm.SearchPcFile( RestorePcID );
end;

procedure TfrmRestore.tbtnRestorePathProClick(Sender: TObject);
begin
  frmRestoreDetail.Show;
end;

procedure TfrmRestore.tbtnSelectAllPathClick(Sender: TObject);
begin
  SetBackupPathCheck( True );
end;

procedure TfrmRestore.ToolButton1Click(Sender: TObject);
begin
  frmRestoreDetail.Show;
end;

procedure TfrmRestore.vstRestoreFileClick(Sender: TObject);
var
  IsShowNext : Boolean;
  RootNode : PVirtualNode;
begin
  IsShowNext := False;

  RootNode := vstRestoreFile.RootNode.FirstChild;
  while Assigned( RootNode ) do
  begin
    if ( RootNode.CheckState = csCheckedNormal ) or
       ( RootNode.CheckState = csMixedNormal )
    then
    begin
      IsShowNext := True;
      Break;
    end;
    RootNode := RootNode.NextSibling;
  end;

  btnNext.Enabled := IsShowNext;
end;

procedure TfrmRestore.vstRestoreFileFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PVstRestoreFileData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmRestore.vstRestoreFileGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  ItemData : PVstRestoreFileData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    ItemData := vstRestoreFile.GetNodeData( Node );
    ImageIndex := PathTypeIconUtil.getIcon( ItemData.FilePath, ItemData.PathType );
  end
  else
    ImageIndex := -1;
end;

procedure TfrmRestore.vstRestoreFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  ItemData : PVstRestoreFileData;
begin
  ItemData := vstRestoreFile.GetNodeData( Node );
  if Column = vst_FileName then
    CellText := ItemData.FileName
  else
  if Column = vst_FileSize then
    CellText := MySize.getFileSizeStr( ItemData.FileSize )
  else
  if Column = vst_Percent then
  begin
    if Node.Parent = vstRestoreFile.RootNode then
      CellText := MyPercentage.getPercentageStr( ItemData.RestorePercentage )
    else
      CellText := ''
  end
  else
  if ( ItemData.PathType <> PathType_File ) then
    CellText := ''
  else
  if Column = vst_FileTime then
    CellText := DateTimeToStr( ItemData.FileTime )
  else
  if Column = vst_FileLocation then
    CellText := ItemData.LocationName
  else
    CellText := '';
end;

{ TRestoreSavePathAddHandle }

procedure TRestoreSavePathAddHandle.AddListview;
var
  ItemData : TLvSavePathData;
begin
  with frmRestore.lvRestoreSavePath.Items.Add do
  begin
    Caption := FullPath;
    SubItems.Add( SavePath );
    ImageIndex := PathTypeIconUtil.getIcon( FullPath, PathType );
    SubItemImages[ LvRestoreSavePath_RestorePath ] := ImageIndex;

    ItemData := TLvSavePathData.Create( FullPath, PathType );
    ItemData.SetSavePath( SavePath );
    Data := ItemData;
  end;
end;

constructor TRestoreSavePathAddHandle.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TRestoreSavePathAddHandle.FindSaveFilePath;
var
  FileExt, SavePathBefore : string;
begin
    // �ļ�������
  if not FileExists( SavePath ) then
    Exit;

  FileExt := ExtractFileExt( SavePath );
  SavePathBefore := MyString.CutStopStr( FileExt, SavePath );
  SavePath := SavePathBefore + '.Restore' + FileExt;
end;

procedure TRestoreSavePathAddHandle.FindSaveFolderPath;
begin
    // Ŀ¼������
  if not DirectoryExists( SavePath ) then
    Exit;

  SavePath := SavePath + '.Restore';
end;

procedure TRestoreSavePathAddHandle.FindSavePath;
begin
  SavePath := FullPath;
  if MyNetworkFolderUtil.IsNetworkFolder( SavePath ) then
    SavePath := MyFilePath.getDownloadPath( SavePath );
  SavePath := MyHardDisk.getAvailablePath( SavePath );
  if PathType = PathType_File then
    FindSaveFilePath
  else
  if PathType = PathType_Folder then
    FindSaveFolderPath;
end;

procedure TRestoreSavePathAddHandle.Update;
begin
  FindSavePath;

  AddListview;
end;

{ TRestoreDecryptPathAddHanlde }

procedure TRestoreDecryptPathAddHanlde.AddNewItem;
var
  LvDecrypt : TListView;
  LvRestoreDecryptData : TLvRestoreDecryptData;
begin
  LvDecrypt := frmRestore.lvDecrypt;
  with LvDecrypt.Items.Add do
  begin
    Caption := FullPath;
    ImageIndex := PathTypeIconUtil.getIcon( FullPath, PathType );

    LvRestoreDecryptData := TLvRestoreDecryptData.Create;
    LvRestoreDecryptData.PasswordMD5 := PasswordMD5;
    LvRestoreDecryptData.PasswordHint := PasswordHint;
    LvRestoreDecryptData.AddRestorePath( FullPath );
    Data := LvRestoreDecryptData;
  end;

  if LvDecrypt.Items.Count = 1 then
    LvDecrypt.Items[0].Selected := True;
end;

constructor TRestoreDecryptPathAddHanlde.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

function TRestoreDecryptPathAddHanlde.FindExistItem: Boolean;
var
  LvDecrypt : TListView;
  i : Integer;
  LvRestoreDecryptData : TLvRestoreDecryptData;
begin
  Result := False;

  LvDecrypt := frmRestore.lvDecrypt;
  for i := 0 to LvDecrypt.Items.Count - 1 do
  begin
    LvRestoreDecryptData := LvDecrypt.Items[i].Data;
    if  LvRestoreDecryptData.PasswordMD5 = PasswordMD5 then
    begin
      LvDecrypt.Items[i].Caption := LvDecrypt.Items[i].Caption + ',  ' + FullPath;
      LvRestoreDecryptData.AddRestorePath( FullPath );
      Result := True;
      Break;
    end;
  end;
end;

procedure TRestoreDecryptPathAddHanlde.SetPassword(_PasswordMD5,
  _PasswordHint: string);
begin
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TRestoreDecryptPathAddHanlde.Update;
begin
  if FindExistItem then
    Exit;

  AddNewItem;
end;

{ TFindRestoreJobHandle }

procedure TFindChildRestoreJobHandle.FindChildNode(ChildNode: PVirtualNode);
var
  FindRestoreJobHandle : TFindChildRestoreJobHandle;
begin
  FindRestoreJobHandle := TFindChildRestoreJobHandle.Create;
  FindRestoreJobHandle.SetPathInfo( FullPath, SavePath );
  FindRestoreJobHandle.SetParentNode( ChildNode );
  FindRestoreJobHandle.Update;
  FindRestoreJobHandle.Free;
end;

procedure TFindChildRestoreJobHandle.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PVstRestoreFileData;
begin
  ChildNode := ParentNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState = csCheckedNormal then
    begin
      ChildData := frmRestore.vstRestoreFile.GetNodeData( ChildNode );
      if ChildData.PathType = PathType_File then
        AddRestoreJob( ChildNode )
      else
        FindChildNode( ChildNode );
    end
    else
    if ChildNode.CheckState = csMixedNormal then
      FindChildNode( ChildNode );

    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TFindRestoreJobHandle }

function TFindRestoreJobHandle.getRootNode(FullPath: string): PVirtualNode;
var
  vstRestoreFile : TVirtualStringTree;
  RootNode : PVirtualNode;
  RootData : PVstRestoreFileData;
begin
  vstRestoreFile := frmRestore.vstRestoreFile;

  Result := nil;
  RootNode := vstRestoreFile.RootNode.FirstChild;
  while Assigned( RootNode ) do
  begin
    RootData := vstRestoreFile.GetNodeData( RootNode );
    if RootData.FilePath = FullPath then
    begin
      Result := RootNode;
      Break;
    end;
    RootNode := RootNode.NextSibling;
  end;
end;

procedure TFindRestoreJobHandle.Update;
var
  LvRestoreSavePath : TListView;
  i : Integer;
  LvSavePathData : TLvSavePathData;
  FullPath, SavePath : string;
  RootNode : PVirtualNode;
  RootData : PVstRestoreFileData;
  RestoreItemAddHandle : TRestoreItemAddResultHandle;
  FindChildRestoreJobBaseHandle : TFindChildRestoreJobBaseHandle;
begin
  LvRestoreSavePath := frmRestore.lvRestoreSavePath;
  for i := 0 to LvRestoreSavePath.Items.Count - 1 do
  begin
    LvSavePathData := LvRestoreSavePath.Items[i].Data;
    FullPath := LvSavePathData.FullPath;
    SavePath := LvSavePathData.SavePath;
    RootNode := getRootNode( FullPath );

    if RootNode = nil then
      Continue;

      // ���� ��Ŀ¼
    RootData := frmRestore.vstRestoreFile.GetNodeData( RootNode );
    RestoreItemAddHandle := TRestoreItemAddResultHandle.Create( FullPath, SavePath );
    RestoreItemAddHandle.SetPathType( LvSavePathData.PathType );
    RestoreItemAddHandle.SetRestorePcID( frmRestore.RestorePcID );
    RestoreItemAddHandle.Update;
    RestoreItemAddHandle.Free;

      // �ļ��ڵ���Ŀ¼�ڵ㲻ͬ����
    if LvSavePathData.PathType = PathType_File then
      FindChildRestoreJobBaseHandle := TFindFileRestoreJobHandle.Create
    else
      FindChildRestoreJobBaseHandle := TFindChildRestoreJobHandle.Create;

      // Find RestoreFile
    FindChildRestoreJobBaseHandle.SetPathInfo( FullPath, SavePath );
    FindChildRestoreJobBaseHandle.SetParentNode( RootNode );
    FindChildRestoreJobBaseHandle.Update;
    FindChildRestoreJobBaseHandle.Free;
  end;
end;

{ TRestoreJobAddHandle }

procedure TRestoreFileAddResultHandle.AddToJob;
var
  TransferRestoreJobAddHandle : TTransferRestoreJobAddHandle;
begin
  TransferRestoreJobAddHandle := TTransferRestoreJobAddHandle.Create( FilePath, LocationID );
  TransferRestoreJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferRestoreJobAddHandle.SetDownFilePath( DownFilePath );
  TransferRestoreJobAddHandle.SetRestorePcID( RestorePcID );
  TransferRestoreJobAddHandle.Update;
  TransferRestoreJobAddHandle.Free;
end;

procedure TRestoreFileAddResultHandle.AddToRemoveUpPend;
var
  PcAddUpPendRestoreFileMsg : TPcAddUpPendRestoreFileMsg;
begin
  PcAddUpPendRestoreFileMsg := TPcAddUpPendRestoreFileMsg.Create;
  PcAddUpPendRestoreFileMsg.SetPcID( PcInfo.PcID );
  PcAddUpPendRestoreFileMsg.SetFileInfo( 0, FileSize );
  PcAddUpPendRestoreFileMsg.SetFilePath( FilePath );
  MyClient.SendMsgToPc( LocationID, PcAddUpPendRestoreFileMsg );
end;

procedure TRestoreFileAddResultHandle.AddToRestoreFile;
var
  AddRestoreFileControl : TAddRestoreFileControl;
begin
  AddRestoreFileControl := TAddRestoreFileControl.Create( FilePath, RestorePcID );
  AddRestoreFileControl.SetFileInfo( FileSize, FileTime );
  AddRestoreFileControl.SetLocationPcID( LocationID );
  AddRestoreFileControl.SetRestoreItemPath( RestoreRootPath );
  AddRestoreFileControl.Update;
  AddRestoreFileControl.Free;
end;

constructor TRestoreFileAddResultHandle.Create(_LocationID, _FilePath: string);
begin
  LocationID := _LocationID;
  FilePath := _FilePath;
end;

procedure TRestoreFileAddResultHandle.SetDownFileInfo(_LocationName,
  _DownFilePath: string);
begin
  LocationName := _LocationName;
  DownFilePath := _DownFilePath;
end;

procedure TRestoreFileAddResultHandle.SetFileInfo(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreFileAddResultHandle.SetRestoreRootPath(
  _RestoreRootPath: string);
begin
  RestoreRootPath := _RestoreRootPath;
end;

procedure TRestoreFileAddResultHandle.Update;
begin
  RestorePcID := frmRestore.RestorePcID;

    // ��� Restore ��¼
  AddToRestoreFile;

    // ��� Restore Job
  AddToJob;

    // ��� Location UpPend
  AddToRemoveUpPend;
end;

{ TFindChildRestoreJobBaseHandle }

procedure TFindChildRestoreJobBaseHandle.AddRestoreJob(ChildNode: PVirtualNode);
var
  ChildData : PVstRestoreFileData;
  SaveFilePath : string;
  RestoreJobAddHandle : TRestoreFileAddResultHandle;
begin
  ChildData := frmRestore.vstRestoreFile.GetNodeData( ChildNode );
  SaveFilePath := StringReplace( ChildData.FilePath, FullPath, SavePath, [] );

  RestoreJobAddHandle := TRestoreFileAddResultHandle.Create( ChildData.LocationID, ChildData.FilePath );
  RestoreJobAddHandle.SetDownFileInfo( ChildData.LocationName, SaveFilePath );
  RestoreJobAddHandle.SetFileInfo( ChildData.FileSize, ChildData.FileTime );
  RestoreJobAddHandle.SetRestoreRootPath( FullPath );
  RestoreJobAddHandle.Update;
  RestoreJobAddHandle.Free;
end;

procedure TFindChildRestoreJobBaseHandle.SetParentNode(
  _ParentNode: PVirtualNode);
begin
  ParentNode := _ParentNode;
end;

procedure TFindChildRestoreJobBaseHandle.SetPathInfo(_FullPath,
  _SavePath: string);
begin
  FullPath := _FullPath;
  SavePath := _SavePath;
end;

{ TFindFileRestoreJobHandle }

procedure TFindFileRestoreJobHandle.Update;
begin
  AddRestoreJob( ParentNode );
end;

{ TRestoreItemAddHandle }

procedure TRestoreItemAddResultHandle.AddRestoreItem;
var
  AddRestoreItemControl : TAddRestoreItemControl;
begin
  AddRestoreItemControl := TAddRestoreItemControl.Create( FullPath, RestorePcID );
  AddRestoreItemControl.SetPathInfo( PathType, SavePath );
  AddRestoreItemControl.SetEncryptInfo( IsEncrypted, Password );
  AddRestoreItemControl.Update;
  AddRestoreItemControl.Free;
end;

constructor TRestoreItemAddResultHandle.Create(_FullPath, _SavePath: string);
begin
  FullPath := _FullPath;
  SavePath := _SavePath;
end;

procedure TRestoreItemAddResultHandle.FindEncryptInfo;
var
  RestorePasswordHash : TRestorePasswordHash;
  p : TRestorePasswordPair;
begin
  RestorePasswordHash := frmRestore.RestorePasswordHash;
  if RestorePasswordHash.ContainsKey( FullPath ) then
  begin
    IsEncrypted := True;
    Password := RestorePasswordHash[ FullPath ].Password;
  end
  else
  begin
    IsEncrypted := False;
    Password := '';
  end;
end;

procedure TRestoreItemAddResultHandle.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TRestoreItemAddResultHandle.SetRestorePcID(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

procedure TRestoreItemAddResultHandle.Update;
begin
    // ��Ѱ ������Ϣ
  FindEncryptInfo;

    // ��� Restore Item
  AddRestoreItem;
end;

{ TRestorePasswordInfo }

constructor TRestorePasswordInfo.Create(_FullPath, _Password: string);
begin
  FullPath := _FullPath;
  Password := _Password;
end;

{ TRestorePcItemData }

constructor TRestorePcItemData.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
  IsFileInvisible := False;
  IvPasswordMD5 := '';
end;

procedure TRestorePcItemData.SetInvisibleInfo(_IsFileInvisible: Boolean;
  _IvPasswordMD5: string);
begin
  IsFileInvisible := _IsFileInvisible;
  IvPasswordMD5 := _IvPasswordMD5;
end;


{ TReadRestorePcListHandle }

procedure TReadRestorePcListHandle.Update;
var
  LvRestorePc : TListView;
  VstRestorePc : TVirtualStringTree;
  PcNode : PVirtualNode;
  NodeData : PVstRestorePcData;
  PcData : TRestorePcItemData;
begin
  LvRestorePc := frmRestore.lvRestorePcID;
  VstRestorePc := frmMainForm.vstRestoreComputers;

    // ��� �ɵ�
  LvRestorePc.Clear;

    // ��� �µ�
  PcNode := VstRestorePc.RootNode.FirstChild;
  while Assigned( PcNode ) do
  begin
    if VstRestorePc.IsVisible[ PcNode ] then
    begin
      NodeData := VstRestorePc.GetNodeData( PcNode );
      PcData := TRestorePcItemData.Create( NodeData.RestorePcID, NodeData.RestorePcName );
      PcData.SetInvisibleInfo( NodeData.IsFileInvisible, NodeData.IvPasswordMD5 );
      with LvRestorePc.Items.Add do
      begin
        Caption := NodeData.RestorePcName;
        SubItems.Add( NodeData.RestorePcID );
        Data := PcData;
        ImageIndex := CloudStatusIcon_Online;
      end;
    end;
    PcNode := PcNode.NextSibling;
  end;
end;


{ TLvBackupPathData }

constructor TLvBackupPathData.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TLvBackupPathData.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TLvBackupPathData.SetFolderSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

{ TReadRestorePcBackupPathListHandle }

constructor TReadRestorePcBackupPathListHandle.Create(_RestorePcID: string);
begin
  RestorePathList := TStringList.Create;
  RestorePcID := _RestorePcID;
end;

destructor TReadRestorePcBackupPathListHandle.Destroy;
begin
  RestorePathList.Free;
  inherited;
end;

procedure TReadRestorePcBackupPathListHandle.ReadAvaliablePath;
var
  LvRestoreBackupPath : TListView;
  NetPcBackupPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  LvBackupPathData : TLvBackupPathData;
  EncryptStr : string;
  CopyCount : Integer;
begin
  LvRestoreBackupPath := frmRestore.lvRestoreBackupPath;
  LvRestoreBackupPath.Clear;

  NetPcBackupPathHash := MyNetPcInfoReadUtil.ReadRestoreAblePath( RestorePcID );
  for p in NetPcBackupPathHash do
  begin
    LvBackupPathData := TLvBackupPathData.Create( p.Value.FullPath, p.Value.PathType );
    LvBackupPathData.SetFolderSpace( p.Value.FolderSpace );
    LvBackupPathData.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    if p.Value.IsEncrypt then
      EncryptStr := Encrypted_Yes
    else
      EncryptStr := Encrypted_No;
    EncryptStr := frmRestore.siLang_frmRestore.GetText( EncryptStr );

    with LvRestoreBackupPath.Items.Add do
    begin
      Caption := p.Value.FullPath;
      SubItems.Add( MyCount.getCountStr( p.Value.FileCount ) );
      SubItems.Add( MySize.getFileSizeStr( p.Value.FolderSpace ) );
      SubItems.Add( IntToStr( p.Value.CopyCount ) );
      SubItems.Add( EncryptStr );
      ImageIndex := PathTypeIconUtil.getIcon( p.Value.FullPath, p.Value.PathType );
      Data := LvBackupPathData;
    end;
    RestorePathList.Add( p.Value.FullPath );
  end;
  NetPcBackupPathHash.Free;
end;


procedure TReadRestorePcBackupPathListHandle.ReadRestorePathPro;
var
  LvRestoreBackupPath : TListView;
  NetPcBackupPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  LvBackupPathData : TLvBackupPathData;
  EncryptStr : string;
  CopyCount : Integer;
  i : Integer;
  RestoreLvBackupPathDetailReadInfo : TNetPcShowRestorePathDetailInfo;
begin
  frmRestoreDetail.LvBackupPathDetail.Clear;
  frmRestoreDetail.lvBackupPathLocation.Clear;
  frmRestoreDetail.RestorePcName := MyNetPcInfoReadUtil.ReadName( RestorePcID );

     // ��ȡ ·����ϸ ��Ϣ
  for i := 0 to RestorePathList.Count - 1 do
    MyNetPcInfoReadUtil.ShowPcRestorePathDetail( RestorePcID, RestorePathList[i] );
end;

procedure TReadRestorePcBackupPathListHandle.ReadUnavaliablePath;
var
  LvRestoreBackupPath : TListView;
  NetPcBackupPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  LvBackupPathData : TLvBackupPathData;
  EncryptStr : string;
  CopyCount : Integer;
begin
  LvRestoreBackupPath := frmRestore.LvUnavailableRestorePath;
  LvRestoreBackupPath.Clear;

  NetPcBackupPathHash := MyNetPcInfoReadUtil.ReadUnRestoreAblePath( RestorePcID );
  for p in NetPcBackupPathHash do
  begin
    LvBackupPathData := TLvBackupPathData.Create( p.Value.FullPath, p.Value.PathType );
    LvBackupPathData.SetFolderSpace( p.Value.FolderSpace );
    LvBackupPathData.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    if p.Value.IsEncrypt then
      EncryptStr := Encrypted_Yes
    else
      EncryptStr := Encrypted_No;
    EncryptStr := frmRestore.siLang_frmRestore.GetText( EncryptStr );

    with LvRestoreBackupPath.Items.Add do
    begin
      Caption := p.Value.FullPath;
      SubItems.Add( MyCount.getCountStr( p.Value.FileCount ) );
      SubItems.Add( MySize.getFileSizeStr( p.Value.FolderSpace ) );
      SubItems.Add( IntToStr( p.Value.CopyCount ) );
      SubItems.Add( EncryptStr );
      ImageIndex := PathTypeIconUtil.getIcon( p.Value.FullPath, p.Value.PathType );
      Data := LvBackupPathData;
    end;
    RestorePathList.Add( p.Value.FullPath );
  end;
  NetPcBackupPathHash.Free;
end;


procedure TReadRestorePcBackupPathListHandle.Update;
var
  IsExistUnavailable : Boolean;
begin
  ReadAvaliablePath;
  ReadUnavaliablePath;
  ReadRestorePathPro;

  with frmRestore do
  begin
    IsExistUnavailable := LvUnavailableRestorePath.Items.Count > 0;
    slUnRestorePath.Visible := IsExistUnavailable;
    LvUnavailableRestorePath.Visible := IsExistUnavailable;
    if IsExistUnavailable then
      slUnRestorePath.Top := 0;
  end;
end;

{ TBtnRestoreNextClick }

procedure TBtnRestoreNextClick.EnterNextPage;
var
  IsShowBack, IsShowNext : Boolean;
  PageIndex : Integer;
  NextCaption : string;
  NextTag : Integer;
begin
  IsShowBack := True;
  IsShowNext := False;
  NextCaption := BtnNextCaption_Next;
  NextTag := BtnNextTag_Next;

  PageIndex := frmRestore.nbMain.PageIndex;
  if PageIndex = NbPageIndex_pgCloudPc then
    IsShowBack := False
  else
  if PageIndex = NbPageIndex_pgSavePath then
  begin
    IsShowNext := True;
    if not frmRestore.IsEncrypted then
    begin
      NextCaption := BtnNextCaption_OK;
      NextTag := BtnNextTao_OK;
    end;
  end
  else
  if PageIndex = NbPageIndex_pgDecrypt then
  begin
    NextCaption := BtnNextCaption_OK;
    NextTag := BtnNextTao_OK;
  end;

  frmRestore.btnBack.Enabled := IsShowBack;
  frmRestore.btnNext.Enabled := IsShowNext;
  frmRestore.btnNext.Caption := frmRestore.siLang_frmRestore.GetText( NextCaption );
  frmRestore.btnNext.Tag := NextTag;
end;

function TBtnRestoreNextClick.IsInvisiblePassword: Boolean;
var
  ItemData : TRestorePcItemData;
begin
  Result := True;
  ItemData := frmRestore.lvRestorePcID.Selected.Data;
  if not ItemData.IsFileInvisible then // û�м���
    Exit;

    // ��������
  Result := frmIvDecrypt.PcDecrypt( ItemData.PcName, ItemData.PcID, ItemData.IvPasswordMD5 );
end;

procedure TBtnRestoreNextClick.RestoreFileNext;
var
  RootNode : PVirtualNode;
  RootData : PVstRestoreFileData;
  FullPath, PathType : string;
  RestoreSavePathAddHandle : TRestoreSavePathAddHandle;
begin
  frmRestore.lvRestoreSavePath.Clear;

  RootNode := frmRestore.vstRestoreFile.RootNode.FirstChild;
  while Assigned( RootNode ) do
  begin
      // ѡ���˸��ڵ�
    if ( RootNode.CheckState = csCheckedNormal ) or
       ( RootNode.CheckState = csMixedNormal )
    then
    begin
        // ��ȡ�ڵ���Ϣ
      RootData := frmRestore.vstRestoreFile.GetNodeData( RootNode );
      FullPath := RootData.FilePath;
      PathType := RootData.PathType;

        // ��� Restore SavePath
      RestoreSavePathAddHandle := TRestoreSavePathAddHandle.Create( FullPath, PathType );
      RestoreSavePathAddHandle.Update;
      RestoreSavePathAddHandle.Free;
    end;

    RootNode := RootNode.NextSibling;
  end;
end;

procedure TBtnRestoreNextClick.RestorePathNext;
var
  RestorePathNextClick : TRestorePathNextClick;
begin
  RestorePathNextClick := TRestorePathNextClick.Create;
  RestorePathNextClick.Update;
  RestorePathNextClick.Free;
end;

procedure TBtnRestoreNextClick.RestorePcNext;
var
  ItemData : TRestorePcItemData;
  ReadRestorePcBackupPathListHandle : TReadRestorePcBackupPathListHandle;
begin
  ItemData := frmRestore.lvRestorePcID.Selected.Data;
  frmRestore.RestorePcID := ItemData.PcID;
  frmRestore.Caption := Format( frmRestore.siLang_frmRestore.GetText( 'StrRestoreTitle' ), [ItemData.PcName] );

    // ���� Restore Pc �� BackupPath List
  ReadRestorePcBackupPathListHandle := TReadRestorePcBackupPathListHandle.Create( ItemData.PcID );
  ReadRestorePcBackupPathListHandle.Update;
  ReadRestorePcBackupPathListHandle.Free;

  frmRestore.btnRestoreNow.Enabled := False;
  frmRestore.tbtnExplorer.Enabled := False;
end;

procedure TBtnRestoreNextClick.RestoreSavePathNext;
var
  lvRestoreBackupPath : TListView;
  i : Integer;
  LvBackupPathData : TLvBackupPathData;
  RestoreDecryptPathAddHanlde : TRestoreDecryptPathAddHanlde;
  FullPath, PathType : string;
  PasswordMD5, PasswordHint : string;
begin
  frmRestore.lvDecrypt.Clear;

  lvRestoreBackupPath := frmRestore.lvRestoreBackupPath;
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
  begin
    if not lvRestoreBackupPath.Items[i].Checked then
      Continue;

    LvBackupPathData := lvRestoreBackupPath.Items[i].Data;
    if not LvBackupPathData.IsEncrypt then
      Continue;

      // ��ȡ ������Ϣ
    FullPath := LvBackupPathData.FullPath;
    PathType := LvBackupPathData.PathType;
    PasswordMD5 := LvBackupPathData.PasswordMD5;
    PasswordHint := LvBackupPathData.PasswordHint;

      // ���
    RestoreDecryptPathAddHanlde := TRestoreDecryptPathAddHanlde.Create( FullPath, PathType );
    RestoreDecryptPathAddHanlde.SetPassword( PasswordMD5, PasswordHint );
    RestoreDecryptPathAddHanlde.Update;
    RestoreDecryptPathAddHanlde.Free;
  end;
end;

procedure TBtnRestoreNextClick.Update;
var
  nbMain : TNotebook;
begin
  nbMain := frmRestore.nbMain;

  if nbMain.PageIndex = NbPageIndex_pgCloudPc then
  begin
    if not IsInvisiblePassword then // File Invisible
      Exit;
    RestorePcNext;
  end
  else
  if nbMain.PageIndex = NbPageIndex_pgBackupPath then
    RestorePathNext
  else
  if nbMain.PageIndex = NbPageIndex_pgRestoreFile then
    RestoreFileNext
  else
  if nbMain.PageIndex = NbPageIndex_pgSavePath then
    RestoreSavePathNext;

  nbMain.PageIndex := nbMain.PageIndex + 1;
  EnterNextPage;
end;

{ TRestorePathNextClick }

procedure TRestorePathNextClick.AddRestorePathDetail;
var
  lvRestoreBackupPath : TListView;
  i : Integer;
  ItemData : TLvBackupPathData;
  RestoreLvBackupPathDetailReadInfo : TNetPcShowRestorePathDetailInfo;
begin
  frmRestoreDetail.LvBackupPathDetail.Clear;
  frmRestoreDetail.lvBackupPathLocation.Clear;

  lvRestoreBackupPath := frmRestore.lvRestoreBackupPath;
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
  begin
      // û��ѡ�� ����
    if not lvRestoreBackupPath.Items[i].Checked then
      Continue;

    ItemData := lvRestoreBackupPath.Items[i].Data;

      // ��ȡ ·����ϸ ��Ϣ
    MyNetPcInfoReadUtil.ShowPcRestorePathDetail( frmRestore.RestorePcID, ItemData.FullPath );
  end;
end;

procedure TRestorePathNextClick.AddToSearch;
var
  lvRestoreBackupPath : TListView;
  i : Integer;
  ItemData : TLvBackupPathData;
  RestoreFileSearchAddInfo : TRestoreFileSearchAddInfo;
begin
  RestoreSearch_IsQuick := False;
  frmMainForm.lbSearching.Visible := False;
  frmMainForm.lbFiles.Visible := False;

  RestoreFileSearchAddInfo := TRestoreFileSearchAddInfo.Create( frmRestore.RestorePcID );
  lvRestoreBackupPath := frmRestore.lvRestoreBackupPath;
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
  begin
      // û��ѡ�� ����
    if not lvRestoreBackupPath.Items[i].Checked then
      Continue;

      // ��ȡ����
    ItemData := lvRestoreBackupPath.Items[i].Data;

      // ��� �ָ�����
    RestoreFileSearchAddInfo.AddRestorePath( ItemData.FullPath, ItemData.PathType );
  end;
  MyFileRestoreReq.AddChange( RestoreFileSearchAddInfo );
end;

procedure TRestorePathNextClick.AddUnavailablePath;
var
  lvRestoreBackupPath : TListView;
  lvUavailablePath : TListView;
  i : Integer;
  ItemData : TLvBackupPathData;
  FullPath, PathType : string;
  FolderSpace : Int64;
  LvUnvailablePathData : TLvUnvailabePathData;
begin
    // ��� ����Ϣ
  lvUavailablePath := frmRestore.lvUavailablePath;
  lvUavailablePath.Clear;

    // ��ʼ�� ���տռ���Ϣ
  RestoreFile_RevSpace := 0;
  RestoreFile_TotalSpace := 0;
  frmRestore.IsEncrypted := False;

    // ������Ҫ�ָ���·��
  lvRestoreBackupPath := frmRestore.lvRestoreBackupPath;
  for i := 0 to lvRestoreBackupPath.Items.Count - 1 do
  begin
      // û��ѡ�� ����
    if not lvRestoreBackupPath.Items[i].Checked then
      Continue;

      // ��ȡ����
    ItemData := lvRestoreBackupPath.Items[i].Data;
    FullPath := ItemData.FullPath;
    PathType := ItemData.PathType;
    FolderSpace := ItemData.FolderSpace;

      // ����ָ��ܿռ�
    RestoreFile_TotalSpace := RestoreFile_TotalSpace + FolderSpace;

      // �Ƿ�ѡ���˼���Ŀ¼
    frmRestore.IsEncrypted := frmRestore.IsEncrypted or ItemData.IsEncrypt;

      // ��� ����
    LvUnvailablePathData := TLvUnvailabePathData.Create( FullPath, PathType );
    LvUnvailablePathData.SetSpace( FolderSpace );
    with lvUavailablePath.Items.Add do
    begin
      Caption := FullPath;
      SubItems.Add( MySize.getFileSizeStr( FolderSpace ) );
      ImageIndex := PathTypeIconUtil.getIcon( FullPath, PathType );
      Data := LvUnvailablePathData;
    end;
  end;
end;

procedure TRestorePathNextClick.IniRestoreInfo;
begin
    // ��ʼ�� �����ָ��ļ���
  frmRestore.lbSearching.Caption := frmRestore.siLang_frmRestore.GetText( 'Searching' );
  RestoreSearch_Files := 0;
  frmRestore.lbFiles.Caption := Format( frmRestore.siLang_frmRestore.GetText( 'SearchCount' ), [0] );

    // ��� ����ʾ��Ϣ
  frmRestore.vstRestoreFile.Clear;
  frmRestore.plRestoreResult.Caption := Format( frmRestore.siLang_frmRestore.GetText( 'TotalPercent' ), [ MyPercentage.getPercentageStr(0), MyPercentage.getPercentageStr(100) ] );

    // ��ʼ����Ϣ
  frmRestore.RestorePasswordHash.Clear;
end;

procedure TRestorePathNextClick.Update;
begin
  IniRestoreInfo;
  AddUnavailablePath;
  AddRestorePathDetail;
  AddToSearch;
end;

{ TLvSavePathData }

constructor TLvSavePathData.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TLvSavePathData.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TLvRestoreDecryptData }

procedure TLvRestoreDecryptData.AddRestorePath(RestorePath: string);
begin
  RestorePathList.Add( RestorePath );
end;

constructor TLvRestoreDecryptData.Create;
begin
  RestorePathList := TStringList.Create;
end;

destructor TLvRestoreDecryptData.Destroy;
begin
  RestorePathList.Free;
  inherited;
end;

{ RestoreSavePathUtil }

class function RestoreSavePathUtil.getSavePath(FullPath,
  PathType: string): string;
var
  SavePath : string;
  FileExt, SavePathBefore : string;
begin
  SavePath := FullPath;

  if MyNetworkFolderUtil.IsNetworkFolder( SavePath ) then
    SavePath := MyFilePath.getDownloadPath( SavePath );

  SavePath := MyHardDisk.getAvailablePath( SavePath );

  if PathType = PathType_File then // �ļ������
  begin
    if FileExists( SavePath ) then
    begin

      FileExt := ExtractFileExt( SavePath );
      SavePathBefore := MyString.CutStopStr( FileExt, SavePath );
      SavePath := SavePathBefore + '.Restore' + FileExt;
    end;
  end
  else
  if PathType = PathType_Folder then  // Ŀ¼�����
  begin
    if DirectoryExists( SavePath ) then
      SavePath := SavePath + '.Restore';
  end;

  Result := SavePath;
end;

{ RestoreFormUtil }

class function RestoreFormUtil.getExplorerPath: string;
var
  Item : TListItem;
  ItemData : TLvBackupPathData;
  RestorePath : string;
begin
  Result := '';
  Item := frmRestore.lvRestoreBackupPath.Selected;
  if Item = nil then
    Exit;
  ItemData := Item.Data;
  RestorePath := ItemData.FullPath;
  RestorePath := MyFilePath.getDownloadPath( RestorePath );
  Result := MyFilePath.getPath( MyCloudFileInfo.ReadBackupCloudPath ) + frmRestore.RestorePcID;
  Result := MyFilePath.getPath( Result ) + RestorePath;
end;

{ TRestoreSpecificPathHandle }

procedure TRestoreSpecificPathHandle.AddRestoreItem(Path, PathType: string);
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

constructor TRestoreSpecificPathHandle.Create;
begin
  RestorePcID := frmRestore.RestorePcID;
end;

procedure TRestoreSpecificPathHandle.Update;
var
  RestoreFileSearchAddInfo : TRestoreFileSearchAddInfo;
  LvBackupPath : TListView;
  i : Integer;
  ItemData : TLvBackupPathData;
begin
  RestoreSearch_IsQuick := True;
  RestoreQuick_RestorePcID := RestorePcID;

  RestoreFileSearchAddInfo := TRestoreFileSearchAddInfo.Create( RestorePcID );
  LvBackupPath := frmRestore.lvRestoreBackupPath;
  for i := 0 to LvBackupPath.Items.Count - 1 do
  begin
    if not LvBackupPath.Items[i].Checked then
      Continue;
    ItemData := LvBackupPath.Items[i].Data;
    AddRestoreItem( ItemData.FullPath, ItemData.PathType );
    RestoreFileSearchAddInfo.AddRestorePath( ItemData.FullPath, ItemData.PathType );
  end;
  MyFileRestoreReq.AddChange( RestoreFileSearchAddInfo );
end;

end.

