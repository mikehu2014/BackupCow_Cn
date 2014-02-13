unit UFormBackupPath;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn, RzTabs,
  Spin, pngimage, UFmFilter, UFileBaseInfo, UFrameFilter, siComp, UMainForm;

type

  // This data record contains all necessary information about a particular file system object.
  // This can either be a folder (virtual or real) or an image file.
  PShellObjectData = ^TShellObjectData;
  TShellObjectData = record
    FullPath, Display: WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  end;


  TfrmSelectBackupPath = class(TForm)
    PcMain: TRzPageControl;
    TsSelectFile: TRzTabSheet;
    TsGenernal: TRzTabSheet;
    TsInclude: TRzTabSheet;
    vstSelectPath: TVirtualStringTree;
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
    edtEncPassword: TEdit;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    cbbSyncTime: TComboBox;
    chkSyncBackupNow: TCheckBox;
    ChkSyncTime: TCheckBox;
    lbCopyCount: TLabel;
    seCopyCount: TSpinEdit;
    seSyncTime: TSpinEdit;
    Image1: TImage;
    ilPcMain16: TImageList;
    Panel3: TPanel;
    Panel4: TPanel;
    btnOK: TButton;
    BtnCancel: TButton;
    chkDisable: TCheckBox;
    FrameFilter: TFrameFilterPage;
    Label1: TLabel;
    btnNext: TButton;
    silang: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure vstSelectPathGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstSelectPathFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstSelectPathGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectPathInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstSelectPathInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectPathChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormShow(Sender: TObject);
    procedure FrameIncludebtnSelectFileClick(Sender: TObject);
    procedure FrameExcludebtnSelectFileClick(Sender: TObject);
    procedure chkIsEncryptClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure PcMainPageChange(Sender: TObject);
    procedure silangChangeLanguage(Sender: TObject);
  private
    FDriveStrings: string;
    function GetDriveString(Index: Integer): string;
    procedure AddDeskTopPath;
    procedure ResetSettings;
  private
    procedure FindSelectPath( Node : PVirtualNode; SelectPathList : TStringList ); // Find Path
    procedure SetUnChecked( Node : PVirtualNode );   // ��� Checked
    function RemoveNewChecked( Node : PVirtualNode ): Boolean;overload;
    procedure ReadDefaultSettings;
  public
    procedure AddBackupPath( FullPath : string );  // Add Path
    procedure RemoveBackupPath( FullPath : string ); // Remove Path
  public
    procedure RemoveNewChecked; overload;
    function getNewSelectPathList : TStringList;
    function getBackupConfigInfo : TBackupConfigInfo;
  end;

    // Ĭ������
  TReadDefaultSettings = class
  public
    procedure Update;
  end;

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

var
  frmSelectBackupPath: TfrmSelectBackupPath;
  DeskTopPath : string;


implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UFormSetting, UFormBackupProperties;

{$R *.DFM}

procedure TfrmSelectBackupPath.FormCreate(Sender: TObject);
var
  SFI: TSHFileInfo;
  i, Count, DriverCount: Integer;
  DriveMap, Mask: Cardinal;
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
  DriverPath : string;
begin
  vstSelectPath.NodeDataSize := SizeOf(TShellObjectData);
  vstSelectPath.Images := MyIcon.getSysIcon;

  // Fill root level of image tree. Determine which drives are mapped.
  DriverCount := 0;
  DriveMap := GetLogicalDrives;
  Mask := 1;
  for i := 0 to 25 do
  begin
    if (DriveMap and Mask) <> 0 then
      Inc(DriverCount);
    Mask := Mask shl 1;
  end;

  // Determine drive strings which are used in the initialization process.
  Count := GetLogicalDriveStrings(0, nil);
  SetLength(FDriveStrings, Count);
  GetLogicalDriveStrings(Count, PChar(FDriveStrings));

    // ��ʼ�� ����·��
  for i := 0 to DriverCount - 1 do
  begin
    DriverPath := GetDriveString(i);
    if not MyHardDisk.getDriverExist( DriverPath ) then
      Continue;

    RootNode := vstSelectPath.AddChild( vstSelectPath.RootNode );
    RootData := vstSelectPath.GetNodeData( RootNode );
    RootData.FullPath := DriverPath;
    RootData.Display := DriverPath;
    RootData.FileTime := MyFileInfo.getFileLastWriteTime( DriverPath );
    RootData.FileSize := MyHardDisk.getHardDiskAllSize( DriverPath );
    RootData.IsFolder := False;
  end;

    // ��� ����·��
  AddDeskTopPath;

    // ����������Ϣ
  ResetSettings;

    // ˢ������
  silangChangeLanguage( nil );
end;

procedure TfrmSelectBackupPath.FormShow(Sender: TObject);
begin
  PcMain.ActivePage := TsSelectFile;
  ModalResult := mrCancel;
  BtnOK.Enabled := False;
  btnNext.Enabled := False;
  ReadDefaultSettings;
end;

procedure TfrmSelectBackupPath.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getNewSelectPathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

procedure TfrmSelectBackupPath.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getNewSelectPathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

function TfrmSelectBackupPath.getBackupConfigInfo: TBackupConfigInfo;
begin
  Result := TBackupConfigInfo.Create;
  Result.SetCopyCount( seCopyCount.Value );
  Result.SetSyncInfo( ChkSyncTime.Checked, cbbSyncTime.ItemIndex, seSyncTime.Value );
  Result.SetBackupInfo( chkSyncBackupNow.Checked, chkDisable.Checked );
  Result.SetEncryptInfo( chkIsEncrypt.Checked, edtEncPassword.Text, edtEncPasswordHint.Text );
  Result.SetIncludeFilterList( FrameFilter.getIncludeFilterList );
  Result.SetExcludeFilterList( FrameFilter.getExcludeFilterList );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupPath.AddDeskTopPath;
var
  pitem : PITEMIDLIST;
  s: string;
  Node : PVirtualNode;
  NodeData : PShellObjectData;
  i : Integer;
begin
  shGetSpecialFolderLocation(handle,CSIDL_DESKTOP,pitem);
  setlength(s,100);
  shGetPathFromIDList(pitem,pchar(s));
  s := copy( s, 1, Pos( #0, s ) - 1 );
  DeskTopPath := s;

  Node := vstSelectPath.AddChild( vstSelectPath.RootNode );
  NodeData := vstSelectPath.GetNodeData( Node );
  NodeData.FullPath := DeskTopPath;
  NodeData.Display := ExtractFileName( DeskTopPath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( DeskTopPath );
  NodeData.IsFolder := True;
end;

procedure TfrmSelectBackupPath.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectBackupPath.btnNextClick(Sender: TObject);
begin
  PcMain.ActivePageIndex := PcMain.ActivePageIndex + 1;
end;

procedure TfrmSelectBackupPath.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;


procedure TfrmSelectBackupPath.chkIsEncryptClick(Sender: TObject);
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
end;

procedure TfrmSelectBackupPath.RemoveNewChecked;
begin
  RemoveNewChecked( vstSelectPath.RootNode );
end;

procedure TfrmSelectBackupPath.ResetSettings;
begin
  FrameFilter.IniFrame;
end;

function TfrmSelectBackupPath.RemoveNewChecked(Node: PVirtualNode): Boolean;
var
  ChildNode : PVirtualNode;
begin
  Result := True;
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if vsDisabled in ChildNode.States then
      Result := False;

    if ( ChildNode.CheckState = csCheckedNormal ) or
       ( ChildNode.CheckState = csMixedNormal )
    then
    begin
      if not ( vsDisabled in ChildNode.States ) and RemoveNewChecked( ChildNode ) then
        ChildNode.CheckState := csUncheckedNormal;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupPath.FindSelectPath(Node: PVirtualNode;
  SelectPathList : TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable �Ľڵ�����
    if not ( vsDisabled in ChildNode.States ) then
    begin
      if ( ChildNode.CheckState = csCheckedNormal ) then  // �ҵ�ѡ���·��
      begin
        NodeData := vstSelectPath.GetNodeData( ChildNode );
        SelectPathList.Add( NodeData.FullPath );
      end
      else
      if ChildNode.CheckState = csMixedNormal then  // ����һ��
        FindSelectPath( ChildNode, SelectPathList );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectBackupPath.GetDriveString(Index: Integer): string;

// Helper method to extract a sub string (given by Index) from FDriveStrings.

var
  Head, Tail: PChar;

begin
  Head := PChar(FDriveStrings);
  Result := '';
  repeat
    Tail := Head;
    while Tail^ <> #0 do
      Inc(Tail);
    if Index = 0 then
    begin
      SetString(Result, Head, Tail - Head);
      Break;
    end;
    Dec(Index);
    Head := Tail + 1;
  until Head^ = #0;
end;

function TfrmSelectBackupPath.getNewSelectPathList: TStringList;
begin
  Result := TStringList.Create;
  FindSelectPath( vstSelectPath.RootNode, Result );
end;

procedure TfrmSelectBackupPath.PcMainPageChange(Sender: TObject);
begin
  btnNext.Enabled := PcMain.ActivePage <> TsInclude;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupPath.AddBackupPath(FullPath: string);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  NodeFullPath : string;
begin
  ChildNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    NodeData := vstSelectPath.GetNodeData( ChildNode );
    NodeFullPath := NodeData.FullPath;

      // �ҵ��˽ڵ�
    if FullPath = NodeFullPath then
    begin
      ChildNode.CheckState := csCheckedNormal;
      ChildNode.States := ChildNode.States - [ vsExpanded, vsHasChildren ];
      ChildNode.States := ChildNode.States + [ vsDisabled ];
      Break;
    end;

      // �ҵ��˸��ڵ�
    if MyMatchMask.CheckChild( FullPath, NodeFullPath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      ChildNode.CheckState := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // ��һ���ڵ�
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupPath.SetUnChecked(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable �� UnChecked �Ľڵ�����
    if not ( vsDisabled in ChildNode.States ) and
       ( ChildNode.CheckState <> csUncheckedNormal )
    then
    begin
      ChildNode.CheckState := csUncheckedNormal;
      SetUnChecked( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupPath.silangChangeLanguage(Sender: TObject);
begin
  with vstSelectPath.Header do
  begin
    Columns[VstSelectBackupPath_FileName].Text := silang.GetText( 'vstFileName' );
    Columns[VstSelectBackupPath_FileSize].Text := silang.GetText( 'vstFileSize' );
    Columns[VstSelectBackupPath_FileTime].Text := silang.GetText( 'vstFileDate' );
  end;

  with cbbSyncTime.Items do
  begin
    Clear;
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrMin' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrHour' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrDay' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrWeek' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrMonth' ) );
  end;

  FrameFilter.RefreshLanguage;
end;

procedure TfrmSelectBackupPath.ReadDefaultSettings;
var
  ReadDefaultSettings : TReadDefaultSettings;
begin
  ReadDefaultSettings := TReadDefaultSettings.Create;
  ReadDefaultSettings.Update;
  ReadDefaultSettings.Free;
end;

procedure TfrmSelectBackupPath.RemoveBackupPath(FullPath: string);
var
  SelectNode : PVirtualNode;
  SelectData : PShellObjectData;
  NodeFullPath : string;
begin
  SelectNode := vstSelectPath.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectPath.GetNodeData( SelectNode );
    NodeFullPath := SelectData.FullPath;

      // �ҵ��˽ڵ�
    if FullPath = NodeFullPath then
    begin
      SelectNode.CheckState := csUncheckedNormal;
      SelectNode.States := SelectNode.States - [ vsDisabled ];
      if MyFilePath.getHasChild( FullPath ) then
      begin
        SelectNode.States := SelectNode.States + [ vsHasChildren ];
        SetUnChecked( SelectNode );
      end;
      Break;
    end;

      // �ҵ��˸��ڵ�
    if MyMatchMask.CheckChild( FullPath, NodeFullPath ) then
    begin
      SelectNode.States := SelectNode.States + [ vsHasChildren ];
      vstSelectPath.ValidateChildren( SelectNode, False );
      SelectNode := SelectNode.FirstChild;
      Continue;
    end;

      // ��һ���ڵ�
    SelectNode := SelectNode.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupPath.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);

// Click handler to switch the column on which will be sorted. Since we cannot sort image data sorting is actually
// limited to the main column.

begin
  if Button = mbLeft then
  begin
    with Sender do
    begin
      if Column <> MainColumn then
        SortColumn := NoColumn
      else
      begin
        if SortColumn = NoColumn then
        begin
          SortColumn := Column;
          SortDirection := sdAscending;
        end
        else
          if SortDirection = sdAscending then
            SortDirection := sdDescending
          else
            SortDirection := sdAscending;
        Treeview.SortTree(SortColumn, SortDirection, False);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupPath.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  BtnOK.Enabled := True;
  btnNext.Enabled := True;
end;

procedure TfrmSelectBackupPath.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectBackupPath.vstSelectPathGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PShellObjectData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    Data := Sender.GetNodeData(Node);
    ImageIndex := MyIcon.getIconByFilePath( Data.FullPath );
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectBackupPath.vstSelectPathGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData( Node );

  if Column = VstSelectBackupPath_FileName then
    CellText := Data.Display
  else
  if Column = VstSelectBackupPath_FileSize then
  begin
    if Data.IsFolder then
      CellText := ''
    else
     CellText := MySize.getFileSizeStr( Data.FileSize )
  end
  else
  if Column = VstSelectBackupPath_FileTime then
    CellText := DateTimeToStr( Data.FileTime )
  else
    CellText := '';
end;

procedure TfrmSelectBackupPath.vstSelectPathInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data, ChildData: PShellObjectData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // ����Ŀ¼����Ϣ���Ҳ���������
  Data := Sender.GetNodeData(Node);
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // ��·��
      FilePath := FullPath + FileName;

        // ����·��
      if FilePath = DeskTopPath then
        Continue;

        // �ӽڵ�����
      ChildNode := Sender.AddChild( Node );
      ChildData := Sender.GetNodeData(ChildNode);
      ChildData.FullPath := FilePath;
      ChildData.Display := MyFileInfo.getFileName( FilePath );
      if DirectoryExists( FilePath ) then
        ChildData.IsFolder := True
      else
      begin
        ChildData.IsFolder := False;
        ChildData.FileSize := sr.Size
      end;
      FileTimeToSystemTime( sr.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      ChildData.FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

        // ��ʼ��
      if Node.CheckState = csCheckedNormal then   // ������ڵ�ȫ��Check, ���ӽڵ� check
        ChildNode.CheckState := csCheckedNormal;
      Sender.ValidateNode(ChildNode, False);

        // �ӽڵ���Ŀ
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;


procedure TfrmSelectBackupPath.vstSelectPathInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);

  if MyFilePath.getHasChild( Data.FullPath ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

//----------------------------------------------------------------------------------------------------------------------


{ TReadDefaultSettings }

procedure TReadDefaultSettings.Update;
begin
  with frmSelectBackupPath do
  begin
      // Backup Settings
    seCopyCount.Value := frmSetting.seCopyCount.Value;
    ChkSyncTime.Checked := frmSetting.ChkSyncTime.Checked;
    seSyncTime.Value := frmSetting.seSyncTime.Value;
    cbbSyncTime.ItemIndex := frmSetting.cbbSyncTime.ItemIndex;
    chkSyncBackupNow.Checked := True;
    chkDisable.Checked := False;

      // Encrypt Settings
    chkIsEncrypt.Checked := frmSetting.chkIsEncrypt.Checked;
    edtEncPassword.Text := frmSetting.edtEncPassword.Text;
    edtEncPassword2.Text := frmSetting.edtEncPassword2.Text;
    edtEncPasswordHint.Text := frmSetting.edtEncPasswordHint.Text;

      // Filter Settins
    FrameFilter.SetDefaultStatus;
  end;

end;

end.
