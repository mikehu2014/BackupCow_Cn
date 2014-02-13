unit UFrmSelectBackupItem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn, RzTabs,
  Spin, pngimage, UFmFilter, UFileBaseInfo, UFrameFilter;

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


  TfrmSelectBackupItem = class(TForm)
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
    seSyncTime: TSpinEdit;
    Image1: TImage;
    ilPcMain16: TImageList;
    chkDisable: TCheckBox;
    FrameFilter: TFrameFilterPage;
    Label1: TLabel;
    tsSelectDes: TRzTabSheet;
    Panel3: TPanel;
    Panel4: TPanel;
    btnOK: TButton;
    BtnCancel: TButton;
    btnNext: TButton;
    Panel2: TPanel;
    GroupBox3: TGroupBox;
    Panel5: TPanel;
    GroupBox2: TGroupBox;
    LvLocalDes: TListView;
    lvNetworkDes: TListView;
    btnAdd: TButton;
    ilNw16: TImageList;
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
    procedure btnAddClick(Sender: TObject);
  private
    FDriveStrings: string;
    function GetDriveString(Index: Integer): string;
    procedure AddDeskTopPath;
    procedure ResetSettings;
  private
    procedure BindListview;
  private
    procedure ReadDefaultSettings;
    procedure AddSelectPath( FullPath : string );  // Add Path
    procedure FindSelectPath( Node : PVirtualNode; SelectPathList : TStringList ); // Find Path
    procedure SetUnChecked( Node : PVirtualNode );   // 清空 Checked
    procedure SetUnCheckDes;
  public
    procedure ClearLastSelected;
    procedure AddOldSelectPath( PathList : TStringList ); // 添加 已选
    function getNewSelectPathList : TStringList;   // 获取 新选
    function getBackupConfigInfo : TBackupConfigInfo;  // 获取 配置信息
  public
    procedure AddLocalDes( DesPath : string );
    procedure AddNetworkDes( PcID : string );
    function getLocalDesList : TStringList;
    function getNetworkDesList : TStringList;
  end;

    // 默认配置
  TReadDefaultSettings = class
  public
    procedure Update;
  private
    procedure ReadLocalDesAvailableSpace;
    procedure ReadNetworkDesAvailableSpace;
  end;

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

var
  frmSelectBackupItem: TfrmSelectBackupItem;
  DeskTopPath : string;


implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UFormSetting, UFormUtil,
  UMyBackupApiInfo, UMyBackupFaceInfo, UMyNetPcInfo;

{$R *.DFM}

procedure TfrmSelectBackupItem.FormCreate(Sender: TObject);
var
  SFI: TSHFileInfo;
  i, Count, DriverCount: Integer;
  DriveMap, Mask: Cardinal;
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
  DriverPath : string;
begin
  BindListview;

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

    // 初始化 磁盘路径
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

    // 添加 桌面路径
  AddDeskTopPath;

    // 加载配置信息
  ResetSettings;
end;

procedure TfrmSelectBackupItem.FormShow(Sender: TObject);
begin
  PcMain.ActivePage := TsSelectFile;
  ModalResult := mrCancel;
  BtnOK.Enabled := False;
  btnNext.Enabled := False;
  ReadDefaultSettings;
end;

procedure TfrmSelectBackupItem.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getNewSelectPathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

procedure TfrmSelectBackupItem.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := getNewSelectPathList;

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick(Sender);

  SelectPathList.Free;
end;

function TfrmSelectBackupItem.getBackupConfigInfo: TBackupConfigInfo;
begin
  Result := TBackupConfigInfo.Create;
  Result.SetSyncInfo( ChkSyncTime.Checked, cbbSyncTime.ItemIndex, seSyncTime.Value );
  Result.SetBackupInfo( chkSyncBackupNow.Checked, chkDisable.Checked );
  Result.SetEncryptInfo( chkIsEncrypt.Checked, edtEncPassword.Text, edtEncPasswordHint.Text );
  Result.SetDeleteInfo( False, 3 );
  Result.SetIncludeFilterList( FrameFilter.getIncludeFilterList );
  Result.SetExcludeFilterList( FrameFilter.getExcludeFilterList );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.AddDeskTopPath;
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

procedure TfrmSelectBackupItem.AddLocalDes(DesPath: string);
var
  i : Integer;
  LvLocalDesData : TLocalDesData;
begin
  for i := 0 to LvLocalDes.Items.Count - 1 do
  begin
    LvLocalDesData := LvLocalDes.Items[i].Data;
    LvLocalDes.Items[i].Checked := LvLocalDesData.DesPath = DesPath;
  end;
end;

procedure TfrmSelectBackupItem.AddNetworkDes(PcID: string);
var
  i : Integer;
  NertworkDesData : TNetworkDesData;
begin
  for i := 0 to lvNetworkDes.Items.Count - 1 do
  begin
    NertworkDesData := lvNetworkDes.Items[i].Data;
    lvNetworkDes.Items[i].Checked := NertworkDesData.PcID = PcID;
  end;
end;

procedure TfrmSelectBackupItem.AddOldSelectPath(PathList: TStringList);
var
  i : Integer;
begin
  for i := 0 to PathList.Count - 1 do
    AddSelectPath( PathList[i] );
end;

procedure TfrmSelectBackupItem.btnAddClick(Sender: TObject);
var
  DestinationPath : string;
begin
  // 选择目录
  DestinationPath := MyHardDisk.getBiggestHardDIsk;
  if not MySelectFolderDialog.SelectNormal('Select your destination folder', '', DestinationPath) then
    Exit;
  DesItemUserApi.AddLocalItem( DestinationPath );
end;

procedure TfrmSelectBackupItem.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectBackupItem.btnNextClick(Sender: TObject);
begin
  PcMain.ActivePageIndex := PcMain.ActivePageIndex + 1;
end;

procedure TfrmSelectBackupItem.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;


procedure TfrmSelectBackupItem.chkIsEncryptClick(Sender: TObject);
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

procedure TfrmSelectBackupItem.ClearLastSelected;
begin
  SetUnChecked( vstSelectPath.RootNode );
  SetUnCheckDes;
end;

procedure TfrmSelectBackupItem.ResetSettings;
begin
  FrameFilter.IniFrame;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.FindSelectPath(Node: PVirtualNode;
  SelectPathList : TStringList);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable 的节点跳过
    if not ( vsDisabled in ChildNode.States ) then
    begin
      if ( ChildNode.CheckState = csCheckedNormal ) then  // 找到选择的路径
      begin
        NodeData := vstSelectPath.GetNodeData( ChildNode );
        SelectPathList.Add( NodeData.FullPath );
      end
      else
      if ChildNode.CheckState = csMixedNormal then  // 找下一层
        FindSelectPath( ChildNode, SelectPathList );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectBackupItem.GetDriveString(Index: Integer): string;

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

function TfrmSelectBackupItem.getLocalDesList: TStringList;
var
  i : Integer;
  LvLocalDesData : TLocalDesData;
begin
  Result := TStringList.Create;
  for i := 0 to LvLocalDes.Items.Count - 1 do
  begin
    if not LvLocalDes.Items[i].Checked then
      Continue;
    LvLocalDesData := LvLocalDes.Items[i].Data;
    Result.Add( LvLocalDesData.DesPath );
  end;
end;

function TfrmSelectBackupItem.getNetworkDesList: TStringList;
var
  i : Integer;
  NertworkDesData : TNetworkDesData;
begin
  Result := TStringList.Create;
  for i := 0 to lvNetworkDes.Items.Count - 1 do
  begin
    if not lvNetworkDes.Items[i].Checked then
      Continue;
    NertworkDesData := lvNetworkDes.Items[i].Data;
    Result.Add( NertworkDesData.PcID );
  end;
end;


function TfrmSelectBackupItem.getNewSelectPathList: TStringList;
begin
  Result := TStringList.Create;
  FindSelectPath( vstSelectPath.RootNode, Result );
end;

procedure TfrmSelectBackupItem.PcMainPageChange(Sender: TObject);
begin
  btnNext.Enabled := PcMain.ActivePage <> TsInclude;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.AddSelectPath(FullPath: string);
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

      // 找到了节点
    if FullPath = NodeFullPath then
    begin
      ChildNode.CheckState := csCheckedNormal;
      ChildNode.States := ChildNode.States - [ vsExpanded, vsHasChildren ];
      ChildNode.States := ChildNode.States + [ vsDisabled ];
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( FullPath, NodeFullPath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      ChildNode.CheckState := csMixedNormal;
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupItem.BindListview;
begin
  LvLocalDes.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindRemoveData( LvLocalDes );
  ListviewUtil.BindRemoveData( lvNetworkDes );
end;

procedure TfrmSelectBackupItem.SetUnCheckDes;
begin
  AddLocalDes( '' );
  AddNetworkDes( '' );
end;

procedure TfrmSelectBackupItem.SetUnChecked(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState <> csUncheckedNormal then
    begin
      ChildNode.CheckState := csUncheckedNormal;
      if vstSelectPath.IsDisabled[ ChildNode ] then
      begin
        vstSelectPath.IsDisabled[ ChildNode ] := False;
        NodeData := vstSelectPath.GetNodeData( ChildNode );
        if MyFilePath.getHasChild( NodeData.FullPath ) then
          vstSelectPath.HasChildren[ ChildNode ] := True;
      end;
      SetUnChecked( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectBackupItem.ReadDefaultSettings;
var
  ReadDefaultSettings : TReadDefaultSettings;
begin
  ReadDefaultSettings := TReadDefaultSettings.Create;
  ReadDefaultSettings.Update;
  ReadDefaultSettings.Free;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectBackupItem.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
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

procedure TfrmSelectBackupItem.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  BtnOK.Enabled := True;
  btnNext.Enabled := True;
end;

procedure TfrmSelectBackupItem.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectBackupItem.vstSelectPathGetImageIndex(
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

procedure TfrmSelectBackupItem.vstSelectPathGetText(
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

procedure TfrmSelectBackupItem.vstSelectPathInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data, ChildData: PShellObjectData;
  sr: TSearchRec;
  FullPath, FileName, FilePath : string;
  ChildNode: PVirtualNode;
  LastWriteTimeSystem: TSystemTime;
begin
  Screen.Cursor := crHourGlass;

    // 搜索目录的信息，找不到则跳过
  Data := Sender.GetNodeData(Node);
  FullPath := MyFilePath.getPath( Data.FullPath );
  if FindFirst( FullPath + '*', faAnyfile, sr ) = 0 then
  begin
    repeat
      FileName := sr.Name;
      if ( FileName = '.' ) or ( FileName = '..' ) then
        Continue;

        // 子路径
      FilePath := FullPath + FileName;

        // 桌面路径
      if FilePath = DeskTopPath then
        Continue;

        // 子节点数据
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

        // 初始化
      if Node.CheckState = csCheckedNormal then   // 如果父节点全部Check, 则子节点 check
        ChildNode.CheckState := csCheckedNormal;
      Sender.ValidateNode(ChildNode, False);

        // 子节点数目
      Inc( ChildCount );

    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  Screen.Cursor := crDefault;
end;


procedure TfrmSelectBackupItem.vstSelectPathInitNode(
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

procedure TReadDefaultSettings.ReadLocalDesAvailableSpace;
var
  LvLocalDes : TListView;
  i : Integer;
  ItemData : TLocalDesData;
  AvailableSpace : Int64;
begin
  LvLocalDes := frmSelectBackupItem.LvLocalDes;
  for i := 0 to LvLocalDes.Items.Count - 1 do
  begin
    ItemData := LvLocalDes.Items[i].Data;
    AvailableSpace := MyHardDisk.getHardDiskFreeSize( ItemData.DesPath );
    LvLocalDes.Items[i].SubItems[0] := MySize.getFileSizeStr( AvailableSpace );
  end;
end;

procedure TReadDefaultSettings.ReadNetworkDesAvailableSpace;
var
  LvNetworkDes : TListView;
  i : Integer;
  ItemData : TNetworkDesData;
  AvailableSpace : Int64;
begin
  LvNetworkDes := frmSelectBackupItem.lvNetworkDes;
  for i := 0 to LvNetworkDes.Items.Count - 1 do
  begin
    ItemData := LvNetworkDes.Items[i].Data;
    AvailableSpace := MyNetPcInfoReadUtil.ReadAvaliableSpace( ItemData.PcID );
    LvNetworkDes.Items[i].SubItems[0] := MySize.getFileSizeStr( AvailableSpace );
  end;
end;

procedure TReadDefaultSettings.Update;
begin
  with frmSelectBackupItem do
  begin
      // Backup Settings
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

    // 读取 目标可用空间
  ReadLocalDesAvailableSpace;
  ReadNetworkDesAvailableSpace;
end;

end.
