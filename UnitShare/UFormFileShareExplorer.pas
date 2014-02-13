unit UFormFileShareExplorer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, RzPanel, RzDlgBtn, VirtualTrees, ComCtrls, UMainForm,
  RzTabs, StdCtrls, IniFiles, ImgList, ToolWin, ShellAPI, Generics.Collections;

type
  TfrmShareExplorer = class(TForm)
    ilMain: TImageList;
    plMain: TPanel;
    PcShareFile: TRzPageControl;
    plButton: TPanel;
    Panel3: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    plDownloadPath: TPanel;
    Label1: TLabel;
    edtDownloadPath: TEdit;
    btnDownloadPath: TButton;
    tbComputer: TToolBar;
    tbtnAllPc: TToolButton;
    tbtnHistory: TToolButton;
    tbtnFavorite: TToolButton;
    Splitter1: TSplitter;
    NbSelectPc: TNotebook;
    PlFavorite: TPanel;
    PlAllPc: TPanel;
    PlHistory: TPanel;
    LvSharePc: TListView;
    VstFavorite: TVirtualStringTree;
    VstHisroty: TVirtualStringTree;
    TbShareFavorite: TToolBar;
    tbtnShareFavoriteRemove: TToolButton;
    tbtnShareFavoriteClear: TToolButton;
    tbShareHistory: TToolBar;
    tbtnShareHistoryRemove: TToolButton;
    tbtnShareHistoryClear: TToolButton;
    tbtnShareHistoryAddFavorite: TToolButton;
    procedure LvSharePcDeletion(Sender: TObject; Item: TListItem);
    procedure PcShareFileClose(Sender: TObject; var AllowClose: Boolean);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDownloadPathClick(Sender: TObject);
    procedure tbtnAllPcClick(Sender: TObject);
    procedure tbtnHistoryClick(Sender: TObject);
    procedure tbtnFavoriteClick(Sender: TObject);
    procedure VstHisrotyGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstFavoriteGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VstFavoriteGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstHisrotyGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstHisrotyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LvSharePcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VstFavoriteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tbtnShareHistoryRemoveClick(Sender: TObject);
    procedure tbtnShareHistoryClearClick(Sender: TObject);
    procedure tbtnShareHistoryAddFavoriteClick(Sender: TObject);
    procedure tbtnShareFavoriteRemoveClick(Sender: TObject);
    procedure tbtnShareFavoriteClearClick(Sender: TObject);
    procedure VstHisrotyFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure VstFavoriteFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure VstHisrotyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VstFavoriteMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
  private
    function AddTap( PcID, PcName : string; TabType : Integer ):boolean;
    procedure AddSelectNode( FullPath, PcID : string; IsFolder : Boolean );
    procedure SelectSharePc( SelectItem : TListItem );overload;
    procedure SelectHistory( Node : PVirtualNode );
    procedure SelectFavorite( Node : PVirtualNode );
  private
    procedure ClearSelect( Node : PVirtualNode );
  private
    procedure LoadIni;
    procedure SaveIni;
  public         // Frame 调用
    procedure SelectShareFolder( SelectPcID : string; Vst : TVirtualStringTree; SelectNode : PVirtualNode );
    procedure EnableBtnOK;
    procedure SelectSharePc( PcID, PcName : string );overload;
    procedure SelectDefaultPc;
  end;

    // 选中的下载文件
  TShareDownSelectFileInfo = class
  public
    SelectPcID, SelectPath : string;
    IsFolder : Boolean;
    FileSize : Int64;
  public
    constructor Create( _SelectPcID, _SelectPath : string );
    procedure SetFileInfo( _IsFolder : Boolean; _FileSize : Int64 );
  end;
  TShareDownSelectFileList = class( TObjectList<TShareDownSelectFileInfo> )end;

    // 寻找选中的下载文件
  TFindShareDownFileList = class
  public
    SelectPcID : string;
    Vst : TVirtualStringTree;
    Node : PVirtualNode;
  public
    ShareDownFileList : TShareDownSelectFileList;
  public
    constructor Create( _SelectPcID : string );
    procedure SetVst( _Vst : TVirtualStringTree );
    procedure SetNode( _Node : PVirtualNode );
    procedure SetShareDown( _ShareDownFileList : TShareDownSelectFileList );
    procedure Update;
  private
    procedure FindChild( ChindNode : PVirtualNode );
  end;

    // 下载 选中文件
  TFindShareDownFileHandle = class
  private
    ShareDownFileList : TShareDownSelectFileList;
  public
    constructor Create;
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindShareDownFileList;
    function getDownFileIsFreeLimit: Boolean;
    procedure AddShareDownFileList;
  end;

const
  VstShareFile_FileName = 0;
  VstShareFile_FileSize = 1;
  VstShareFile_FileTime = 2;

  NbPcPage_All = 0;
  NbPcPage_History = 1;
  NbPcPage_Favorite = 2;

  VstShareHistroy_FileName = 0;
  VstShareHistroy_Location = 1;

  VstShareFavorite_FileName = 0;
  VstShareFavorite_Location = 1;

  TsTap_AllPc = 0;
  TsTap_History = 1;
  TsTap_Favorite = 2;

  ShowText_Waiting = 'Waiting...';

  ShowForm_ClearShareHistory = 'Are you sure to clear all history records ?';
  ShowForm_ClearShareFavorite = 'Are you sure to clear all favorite records ?';

  FormTitle_SelectDownPath = 'Select your download path';

var
  Default_DownloadPathName : string = 'BackupCow.Download';

var
  frmShareExplorer: TfrmShareExplorer;

implementation

uses UMyShareControl, UMyShareFace, UIconUtil, UMyUtil, UFmShareFileExplorer, UNetworkFace, UFormUtil,
     URegisterInfo, UFormFreeEdition;

{$R *.dfm}

procedure TfrmShareExplorer.AddSelectNode(FullPath, PcID: string;
  IsFolder: Boolean);
var
  VstShareFile : TVirtualStringTree;
  NewNode : PVirtualNode;
  NewNodeData : PVstShareFolderData;
begin
    // 初始化 根节点
  VstShareFile := VstShareFolderUtil.getVstShareFiles( PcID );
  VstShareFile.Clear;
  NewNode := VstShareFile.AddChild( VstShareFile.RootNode );
  NewNode.CheckType := ctTriStateCheckBox;
  NewNodeData := VstShareFile.GetNodeData( NewNode );
  NewNodeData.FilePath := FullPath;
  NewNodeData.IsFolder := IsFolder;
  NewNodeData.FileSize := 0;
  NewNodeData.FileTime := Now;
  NewNodeData.IsWaiting := False;
  VstShareFile.ValidateNode( NewNode, False );

    // 初始化 子节点
  SelectShareFolder( PcID, VstShareFile, NewNode );
end;

function TfrmShareExplorer.AddTap(PcID, PcName: string;
  TabType : Integer): boolean;
var
  ts : TRzTabSheet;
  f : TFrameShareFiles;
begin
  Result := True;

  ts := VstShareFolderUtil.getTap( PcID );

    // 已存在
  if ts <> nil then
  begin
    if ts.Tag = TabType then
    begin
      frmShareExplorer.PcShareFile.ActivePage := ts;
      Result := False;
      Exit;
    end
    else
      ts.Destroy;
  end;

    // 创建 Tap
  ts := TRzTabSheet.Create( Self );
  ts.PageControl := frmShareExplorer.PcShareFile;
  ts.Caption := PcName;
  ts.Align := alClient;
  ts.Padding.Left := 5;
  ts.Padding.Top := 5;
  ts.Padding.Right := 5;
  ts.Padding.Bottom := 5;
  ts.ImageIndex := CloudStatusIcon_Online;
  ts.Tag := TabType;

    // 创建 Frame
  f := TFrameShareFiles.Create(nil);
  f.SetSharePcID( PcID );
  f.IniVstShareFile;
  f.Parent := ts;
  f.Align := alClient;
  f.Top:=0;
  f.Left:=0;

    // 显示
  ts.Show;
end;

procedure TfrmShareExplorer.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmShareExplorer.btnDownloadPathClick(Sender: TObject);
var
  DownloadPath : string;
begin
  if MySelectFolderDialog.Select( FormTitle_SelectDownPath, edtDownloadPath.Text, DownloadPath, Self.Handle ) then
    edtDownloadPath.Text := DownloadPath;
end;

procedure TfrmShareExplorer.btnOKClick(Sender: TObject);
var
  FindShareDownFileHandle : TFindShareDownFileHandle;
begin
  FindShareDownFileHandle := TFindShareDownFileHandle.Create;
  FindShareDownFileHandle.Update;
  FindShareDownFileHandle.Free;
end;

procedure TfrmShareExplorer.ClearSelect(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // UnChecked 的节点跳过
    if ChildNode.CheckState <> csUncheckedNormal then
    begin
      ChildNode.CheckState := csUncheckedNormal;
      ClearSelect( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmShareExplorer.DropFiles(var Msg: TMessage);
var
  FilesCount: Integer; // 文件总数
  FileName: array[0..255] of Char;
begin
  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);

  try
    // 获取文件名
    if FilesCount > 0 then
    begin
      DragQueryFile(Msg.WParam, 0, FileName, 256);
      edtDownloadPath.Text := FileName;
    end;
  except
  end;

  // 释放
  DragFinish(Msg.WParam);
end;

procedure TfrmShareExplorer.EnableBtnOK;
begin
  if not btnOK.Enabled then
  begin
    btnOK.Enabled := True;
    plDownloadPath.Visible := True;
  end;
end;

procedure TfrmShareExplorer.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i : Integer;
  f : TFrameShareFiles;
begin
    // 遍历所有页
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    f := VstShareFolderUtil.getFrame( PcShareFile.Pages[i] );
    if f = nil then
      Continue;
    ClearSelect( f.vstShareFiles.RootNode );
  end;
end;

procedure TfrmShareExplorer.FormCreate(Sender: TObject);
begin
  LoadIni;

  VstHisroty.Images := MyIcon.getSysIcon;
  VstFavorite.Images := MyIcon.getSysIcon;

  VstHisroty.NodeDataSize := SizeOf( TVstShareHistoryData );
  VstFavorite.NodeDataSize := SizeOf( TVstShareFavorityData );

  VstHisroty.PopupMenu := FormUtil.getPopMenu( tbShareHistory );
  VstFavorite.PopupMenu := FormUtil.getPopMenu( TbShareFavorite );

  edtDownloadPath.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFolder' );
  DragAcceptFiles( Handle, TRUE); //设置需要处理文件 WM_DROPFILES 拖放消息

  NbSelectPc.PageIndex := NbPcPage_All;
end;

procedure TfrmShareExplorer.FormDestroy(Sender: TObject);
begin
  SaveIni;
end;

procedure TfrmShareExplorer.FormShow(Sender: TObject);
begin
  btnOK.Enabled := False;
  plDownloadPath.Visible := False;
end;

procedure TfrmShareExplorer.LoadIni;
var
  DefaultDownloadPath : string;
  IniFile : TIniFile;
begin
  DefaultDownloadPath := MyHardDisk.getBiggestHardDIsk + Default_DownloadPathName;

  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  edtDownloadPath.Text := IniFile.ReadString( Self.Name, edtDownloadPath.Name, DefaultDownloadPath );
  IniFile.Free;
end;

procedure TfrmShareExplorer.LvSharePcDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmShareExplorer.LvSharePcMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SelectItem : TListItem;
begin
  SelectItem := LvSharePc.GetItemAt( x, Y );
  if SelectItem <> nil then
    SelectSharePc( SelectItem );
end;

procedure TfrmShareExplorer.PcShareFileClose(Sender: TObject;
  var AllowClose: Boolean);
begin
  AllowClose := True;
end;

procedure TfrmShareExplorer.SaveIni;
var
  IniFile : TIniFile;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Self.Name, edtDownloadPath.Name, edtDownloadPath.Text );
  IniFile.Free;
end;

procedure TfrmShareExplorer.SelectDefaultPc;
begin
  if PcShareFile.PageCount > 0 then
    Exit;

  if LvSharePc.Items.Count <= 0 then
    Exit;

  SelectSharePc( LvSharePc.Items[0] );
end;

procedure TfrmShareExplorer.SelectFavorite(Node : PVirtualNode);
var
  NodeData : PVstShareFavorityData;
  VstShareFile : TVirtualStringTree;
  OldNodeData : PVstShareFolderData;
  IsFolder : Boolean;
begin
  NodeData := VstFavorite.GetNodeData( Node );

    // 已存在
  if not AddTap( NodeData.DesPcID, NodeData.DesPcName, TsTap_Favorite ) then
  begin
    VstShareFile := VstShareFolderUtil.getVstShareFiles( NodeData.DesPcID );
    OldNodeData := VstShareFile.GetNodeData( VstShareFile.RootNode.FirstChild );
    if OldNodeData.FilePath = NodeData.FullPath then
      Exit;
  end;

    // 初始化 节点
  IsFolder := NodeData.PathType = SharePathType_Folder;
  AddSelectNode( NodeData.FullPath, NodeData.DesPcID, IsFolder );
end;

procedure TfrmShareExplorer.SelectHistory(Node : PVirtualNode);
var
  NodeData : PVstShareHistoryData;
  VstShareFile : TVirtualStringTree;
  OldNodeData : PVstShareFolderData;
  IsFolder : Boolean;
begin
  NodeData := VstHisroty.GetNodeData( Node );

    // 已存在
  if not AddTap( NodeData.DesPcID, NodeData.DesPcName, TsTap_History ) then
  begin
    VstShareFile := VstShareFolderUtil.getVstShareFiles( NodeData.DesPcID );
    OldNodeData := VstShareFile.GetNodeData( VstShareFile.RootNode.FirstChild );
    if OldNodeData.FilePath = NodeData.FullPath then
      Exit;
  end;

    // 初始化 节点
  IsFolder := NodeData.PathType = SharePathType_Folder;
  AddSelectNode( NodeData.FullPath, NodeData.DesPcID, IsFolder );
end;

procedure TfrmShareExplorer.SelectShareFolder( SelectPcID : string; Vst : TVirtualStringTree;
  SelectNode : PVirtualNode);
var
  FilePath : string;
  SelectData : PVstShareFolderData;
  WaitNode : PVirtualNode;
  WaitData : PVstShareFolderData;
begin
    // Waiting Node
  WaitNode := Vst.AddChild( SelectNode );
  WaitData := Vst.GetNodeData( WaitNode );
  WaitData.FilePath := ShowText_Waiting;
  WaitData.IsWaiting := True;
  WaitData.IsFolder := True;

    // 请求的文件节点
  if SelectNode = Vst.RootNode then
    FilePath := ''
  else
  begin
    SelectData := Vst.GetNodeData( SelectNode );
    FilePath := SelectData.FilePath;

      // 展开节点
    Vst.ValidateNode( WaitNode, False );
    Vst.Expanded[ SelectNode ] := True;
  end;

    // 发送请求
  MyFileShareControl.GetFileShareList( SelectPcID, FilePath );
end;

procedure TfrmShareExplorer.SelectSharePc(PcID, PcName: string);
var
  vstShareFile : TVirtualStringTree;
begin
    // 已存在
  if not AddTap( PcID, PcName, TsTap_AllPc ) then
    Exit;

    // 初始化
  vstShareFile := VstShareFolderUtil.getVstShareFiles( PcID );
  vstShareFile.Clear;
  SelectShareFolder( PcID, vstShareFile, vstShareFile.RootNode );
end;

procedure TfrmShareExplorer.SelectSharePc(SelectItem : TListItem);
var
  ItemData : TLvSharePcData;
  vstShareFile : TVirtualStringTree;
begin
  ItemData := SelectItem.Data;
  SelectSharePc( ItemData.PcID, ItemData.PcName );
end;

procedure TfrmShareExplorer.tbtnAllPcClick(Sender: TObject);
begin
  NbSelectPc.PageIndex := NbPcPage_All;
end;

procedure TfrmShareExplorer.tbtnFavoriteClick(Sender: TObject);
begin
  NbSelectPc.PageIndex := NbPcPage_Favorite;
end;

procedure TfrmShareExplorer.tbtnHistoryClick(Sender: TObject);
begin
  NbSelectPc.PageIndex := NbPcPage_History;
end;

procedure TfrmShareExplorer.tbtnShareFavoriteClearClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  if not MyMessageBox.ShowConfirm( ShowForm_ClearShareFavorite ) then
    Exit;

  SelectNode := VstFavorite.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFavorite.GetNodeData( SelectNode );
    if VstFavorite.IsVisible[ SelectNode ] then
      MyFileShareControl.RemoveFavorite( SelectData.FullPath, SelectData.DesPcID );
    SelectNode := SelectNode.NextSibling;
  end;

  tbtnShareFavoriteClear.Enabled := False;
end;

procedure TfrmShareExplorer.tbtnShareFavoriteRemoveClick(Sender: TObject);
var
  NodeData : PVstShareFavorityData;
begin
  if not Assigned( VstFavorite.FocusedNode ) then
    Exit;
  NodeData := VstFavorite.GetNodeData( VstFavorite.FocusedNode );
  MyFileShareControl.RemoveFavorite( NodeData.FullPath, NodeData.DesPcID );
end;

procedure TfrmShareExplorer.tbtnShareHistoryAddFavoriteClick(Sender: TObject);
var
  NodeData : PVstShareHistoryData;
  IsFolder : Boolean;
begin
  if not Assigned( VstHisroty.FocusedNode ) then
    Exit;
  NodeData := VstHisroty.GetNodeData( VstHisroty.FocusedNode );
  IsFolder := NodeData.PathType = SharePathType_Folder;
  MyFileShareControl.AddFavorite( NodeData.FullPath, NodeData.DesPcID, IsFolder );
end;

procedure TfrmShareExplorer.tbtnShareHistoryClearClick(Sender: TObject);
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  if not MyMessageBox.ShowConfirm( ShowForm_ClearShareHistory ) then
    Exit;

  SelectNode := VstHisroty.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstHisroty.GetNodeData( SelectNode );
    if VstHisroty.IsVisible[ SelectNode ] then
      MyFileShareControl.RemoveHistory( SelectData.FullPath, SelectData.DesPcID );
    SelectNode := SelectNode.NextSibling;
  end;

  tbtnShareHistoryClear.Enabled := False;
end;

procedure TfrmShareExplorer.tbtnShareHistoryRemoveClick(Sender: TObject);
var
  NodeData : PVstShareHistoryData;
begin
  if not Assigned( VstHisroty.FocusedNode ) then
    Exit;
  NodeData := VstHisroty.GetNodeData( VstHisroty.FocusedNode );
  MyFileShareControl.RemoveHistory( NodeData.FullPath, NodeData.DesPcID );
end;

procedure TfrmShareExplorer.VstFavoriteFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnShareFavoriteRemove.Enabled := Assigned( Node );
end;

procedure TfrmShareExplorer.VstFavoriteGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstShareFavorityData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    if NodeData.PathType = SharePathType_File then
      ImageIndex := MyIcon.getIconByFileExt( NodeData.FullPath )
    else
      ImageIndex := MyShellIconUtil.getFolderIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmShareExplorer.VstFavoriteGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstShareFavorityData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstShareFavorite_FileName then
    CellText := MyFileInfo.getFileName( NodeData.FullPath )
  else
  if Column = VstShareFavorite_Location then
    CellText := NodeData.DesPcName
  else
    CellText := '';
end;

procedure TfrmShareExplorer.VstFavoriteMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
begin
  Node := VstFavorite.GetNodeAt( x, y );
  if Assigned( Node ) then
    SelectFavorite( Node );
end;


procedure TfrmShareExplorer.VstFavoriteMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
  NodeData : PVstShareFavorityData;
begin
  Node := VstFavorite.GetNodeAt( x, y );
  if Assigned( Node ) then
  begin
    NodeData := VstFavorite.GetNodeData( Node );
    VstFavorite.Hint := NodeData.FullPath + #13#10 + NodeData.DesPcName;
  end
  else
    VstHisroty.Hint := '';
end;

procedure TfrmShareExplorer.VstHisrotyFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnShareHistoryRemove.Enabled := Assigned( Node );
  tbtnShareHistoryAddFavorite.Enabled := Assigned( Node );
end;

procedure TfrmShareExplorer.VstHisrotyGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstShareHistoryData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    if NodeData.PathType = SharePathType_File then
      ImageIndex := MyIcon.getIconByFileExt( NodeData.FullPath )
    else
      ImageIndex := MyShellIconUtil.getFolderIcon;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmShareExplorer.VstHisrotyGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstShareHistoryData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstShareHistroy_FileName then
    CellText := MyFileInfo.getFileName( NodeData.FullPath )
  else
  if Column = VstShareHistroy_Location then
    CellText := NodeData.DesPcName
  else
    CellText := '';
end;

procedure TfrmShareExplorer.VstHisrotyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
begin
  Node := VstHisroty.GetNodeAt( x, y );
  if Assigned( Node ) then
    SelectHistory( Node );
end;

procedure TfrmShareExplorer.VstHisrotyMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Node : PVirtualNode;
  NodeData : PVstShareHistoryData;
begin
  Node := VstHisroty.GetNodeAt( x, y );
  if Assigned( Node ) then
  begin
    NodeData := VstHisroty.GetNodeData( Node );
    VstHisroty.Hint := NodeData.FullPath + #13#10 + NodeData.DesPcName;
  end
  else
    VstHisroty.Hint := '';
end;

{ TShareDownSelectFileInfo }

constructor TShareDownSelectFileInfo.Create(_SelectPcID, _SelectPath: string);
begin
  SelectPcID := _SelectPcID;
  SelectPath := _SelectPath;
end;

procedure TShareDownSelectFileInfo.SetFileInfo(_IsFolder: Boolean;
  _FileSize: Int64);
begin
  IsFolder := _IsFolder;
  FileSize := _FileSize;
end;

{ TFindShareDownFileList }

constructor TFindShareDownFileList.Create(_SelectPcID: string);
begin
  SelectPcID := _SelectPcID;
end;

procedure TFindShareDownFileList.FindChild(ChindNode: PVirtualNode);
var
  FindShareDownFileList : TFindShareDownFileList;
begin
  FindShareDownFileList := TFindShareDownFileList.Create( SelectPcID );
  FindShareDownFileList.SetVst( Vst );
  FindShareDownFileList.SetNode( ChindNode );
  FindShareDownFileList.SetShareDown( ShareDownFileList );
  FindShareDownFileList.Update;
  FindShareDownFileList.Free;
end;

procedure TFindShareDownFileList.SetNode(_Node: PVirtualNode);
begin
  Node := _Node;
end;

procedure TFindShareDownFileList.SetShareDown(
  _ShareDownFileList: TShareDownSelectFileList);
begin
  ShareDownFileList := _ShareDownFileList;
end;

procedure TFindShareDownFileList.SetVst(_Vst: TVirtualStringTree);
begin
  Vst := _Vst;
end;

procedure TFindShareDownFileList.Update;
var
  ChildNode : PVirtualNode;
  NodeData : PVstShareFolderData;
  ShareDownSelectFileInfo : TShareDownSelectFileInfo;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ( ChildNode.CheckState = csCheckedNormal ) then  // 找到选择的路径
    begin
      NodeData := Vst.GetNodeData( ChildNode );

        // 添加到列表中
      ShareDownSelectFileInfo := TShareDownSelectFileInfo.Create( SelectPcID, NodeData.FilePath );
      ShareDownSelectFileInfo.SetFileInfo( NodeData.IsFolder, NodeData.FileSize );
      ShareDownFileList.Add( ShareDownSelectFileInfo );
    end
    else
    if ChildNode.CheckState = csMixedNormal then  // 找下一层
      FindChild( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TFindShareDownFileHandle }

procedure TFindShareDownFileHandle.AddShareDownFileList;
var
  i : Integer;
  DownFileInfo : TShareDownSelectFileInfo;
  SelectPcID, SelectPath : string;
  IsFolder : Boolean;
  DownloadPath : string;
begin
  DownloadPath := frmShareExplorer.edtDownloadPath.Text;

  for i := 0 to ShareDownFileList.Count - 1 do
  begin
    DownFileInfo := ShareDownFileList[i];
    SelectPcID := DownFileInfo.SelectPcID;
    SelectPath := DownFileInfo.SelectPath;
    IsFolder := DownFileInfo.IsFolder;

      // 添加 根节点
    MyFileShareControl.AddShareDown( SelectPath, SelectPcID, DownloadPath, IsFolder );

      // 发送 下载请求
    MyFileShareControl.GetFileShareDown( SelectPcID, SelectPath );

      // 添加 历史
    MyFileShareControl.AddHistory( SelectPath, SelectPcID, IsFolder );
  end;
end;

constructor TFindShareDownFileHandle.Create;
begin
  ShareDownFileList := TShareDownSelectFileList.Create;
end;

destructor TFindShareDownFileHandle.Destroy;
begin
  ShareDownFileList.Free;
  inherited;
end;

procedure TFindShareDownFileHandle.FindShareDownFileList;
var
  PcShareFile : TRzPageControl;
  i : Integer;
  f : TFrameShareFiles;
  FindShareDownFileList : TFindShareDownFileList;
begin
    // 遍历所有页
  PcShareFile := frmShareExplorer.PcShareFile;
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    f := VstShareFolderUtil.getFrame( PcShareFile.Pages[i] );
    if f = nil then
      Continue;
      // 寻找每一页选中的 下载文件
    FindShareDownFileList := TFindShareDownFileList.Create( f.SharePcID );
    FindShareDownFileList.SetVst( f.vstShareFiles );
    FindShareDownFileList.SetNode( f.vstShareFiles.RootNode );
    FindShareDownFileList.SetShareDown( ShareDownFileList );
    FindShareDownFileList.Update;
    FindShareDownFileList.Free;
  end;
end;

function TFindShareDownFileHandle.getDownFileIsFreeLimit: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not RegisterInfo.getIsFreeEdition then
    Exit;

  for i := 0 to ShareDownFileList.Count - 1 do
  begin
    if ShareDownFileList[i].IsFolder then
      Continue;
    if EditionUtil.getIsLimitShareSpace( ShareDownFileList[i].FileSize ) then
    begin
      frmFreeEdition.ShowWarnning( FreeEditionError_ShareDownSize );;
      Result := True;
      Break;
    end;
  end;
end;

procedure TFindShareDownFileHandle.Update;
begin
    // 寻找选中的文件
  FindShareDownFileList;

    // 试用版限制
  if getDownFileIsFreeLimit then
    Exit;

    // 添加 共享下载
  AddShareDownFileList;

  frmShareExplorer.Close;
end;

end.
