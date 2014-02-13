unit UFmShareFileExplorer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, VirtualTrees, ImgList, ComCtrls, ToolWin, Menus, ExtCtrls;

type
  TFrameShareFiles = class(TFrame)
    vstShareFiles: TVirtualStringTree;
    tbVstShareFile: TToolBar;
    tbtnRefresh: TToolButton;
    tbtnAddFavorite: TToolButton;
    ilTb: TImageList;
    ilTbGray: TImageList;
    PmVstShareFile: TPopupMenu;
    Refresh1: TMenuItem;
    AddFavorite1: TMenuItem;
    plDownShareHistoryTitle: TPanel;
    procedure vstShareFilesGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstShareFilesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstShareFilesInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstShareFilesChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure vstShareFilesFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure tbtnRefreshClick(Sender: TObject);
    procedure tbtnAddFavoriteClick(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure AddFavorite1Click(Sender: TObject);
  public
    SharePcID : string;
    procedure IniVstShareFile;
    procedure SetSharePcID( _SharePcID : string );
  end;

const
  VstShareFile_FileName = 0;
  VstShareFile_FileSize = 1;
  VstShareFile_FileTime = 2;

  ShowText_Waiting = 'Waiting...';


implementation

uses UMyShareFace, UIconUtil, UMyUtil, UMyShareControl, UFormFileShareExplorer, UFormUtil;

{$R *.dfm}

procedure TFrameShareFiles.AddFavorite1Click(Sender: TObject);
begin
  tbtnAddFavorite.Click;
end;

procedure TFrameShareFiles.IniVstShareFile;
begin
  vstShareFiles.NodeDataSize := SizeOf( TVstShareFolderData );
  vstShareFiles.Images := MyIcon.getSysIcon;
end;

procedure TFrameShareFiles.Refresh1Click(Sender: TObject);
begin
  tbtnRefresh.Click;
end;

procedure TFrameShareFiles.SetSharePcID(_SharePcID: string);
begin
  SharePcID := _SharePcID;
end;

procedure TFrameShareFiles.tbtnAddFavoriteClick(Sender: TObject);
var
  SelectData : PVstShareFolderData;
begin
  if not Assigned( vstShareFiles.FocusedNode ) then
    Exit;
  SelectData := vstShareFiles.GetNodeData( vstShareFiles.FocusedNode );
  MyFileShareControl.AddFavorite( SelectData.FilePath, SharePcID, SelectData.IsFolder );
end;

procedure TFrameShareFiles.tbtnRefreshClick(Sender: TObject);
var
  RefreshNode : PVirtualNode;
begin
  RefreshNode := vstShareFiles.FocusedNode;
  if not Assigned( RefreshNode ) then
    Exit;

  vstShareFiles.DeleteChildren( RefreshNode );
  frmShareExplorer.SelectShareFolder( SharePcID, vstShareFiles, RefreshNode );
end;

procedure TFrameShareFiles.vstShareFilesChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  frmShareExplorer.EnableBtnOK;
end;

procedure TFrameShareFiles.vstShareFilesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  tbtnRefresh.Enabled := Assigned( Node );
  tbtnAddFavorite.Enabled := Assigned( Node );
  PmVstShareFile.Items[0].Visible := Assigned( Node );
  PmVstShareFile.Items[1].Visible := Assigned( Node );
end;

procedure TFrameShareFiles.vstShareFilesGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData : PVstShareFolderData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData( Node );
    if NodeData.FilePath = ShareFile_NotExist then
      ImageIndex := MyShellTransActionIconUtil.getLoadedError
    else
    if NodeData.IsFolder then
      ImageIndex := MyShellIconUtil.getFolderIcon
    else
      ImageIndex := MyIcon.getIconByFileExt( NodeData.FilePath );
  end
  else
    ImageIndex := -1;
end;

procedure TFrameShareFiles.vstShareFilesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstShareFolderData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstShareFile_FileName then
  begin
    if Node.Parent = Sender.RootNode then
      CellText := NodeData.FilePath
    else
      CellText := MyFileInfo.getFileName( NodeData.FilePath );
  end
  else
  if NodeData.IsWaiting then
    CellText := ''
  else
  if Column = VstShareFile_FileTime then
    CellText := DateTimeToStr( NodeData.FileTime )
  else
  if not NodeData.IsFolder then
    CellText := MySize.getFileSizeStr( NodeData.FileSize )
  else
    CellText := '';
end;

procedure TFrameShareFiles.vstShareFilesInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
begin
  frmShareExplorer.SelectShareFolder( SharePcID, vstShareFiles, Node );
  Inc( ChildCount );
end;

end.
