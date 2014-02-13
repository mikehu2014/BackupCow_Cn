unit UFormSelectSharePath;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn;

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


  TfrmSelectSharePath = class(TForm)
    vstSelectPath: TVirtualStringTree;
    diaBtn: TRzDialogButtons;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDriveStrings: string;
    function GetDriveString(Index: Integer): string;
    procedure AddDeskTopPath;
  private
    function FindHasChild( Node : PVirtualNode ) : Boolean;  // 是否 存在子节点
    procedure FindBackupPath( Node : PVirtualNode ); // Find Path
    procedure SetUnChecked( Node : PVirtualNode );   // 清空 Checked
  public
    procedure AddBackupPath( FullPath : string );  // Add Path
    procedure RemoveBackupPath( FullPath : string ); // Remove Path
    procedure ClearBackupPath( Node : PVirtualNode ); // Clear Path
  private
    procedure RemoveOldAddChildNode( Node : PVirtualNode ); // Add Path, Remove Old Add Child Path
    function CancelNowChecked( Node : PVirtualNode ): Boolean;
  end;

const
  VstSelectBackupPath_FileName = 0;
  VstSelectBackupPath_FileSize = 1;
  VstSelectBackupPath_FileTime = 2;

var
  frmSelectSharePath: TfrmSelectSharePath;
  DeskTopPath : string;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UMainForm, UMyShareControl;

{$R *.DFM}

//----------------------------------------------------------------------------------------------------------------------


//----------------- utility functions ----------------------------------------------------------------------------------


function GetIconIndex(Name: string; Flags: Cardinal): Integer;
var
  SFI: TSHFileInfo;
begin
  if SHGetFileInfo(PChar(Name), 0, SFI, SizeOf(TSHFileInfo), Flags) = 0 then
    Result := -1
  else
    Result := SFI.iIcon;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure GetOpenAndClosedIcons(Name: string; var Open, Closed: Integer);
begin
  Closed := GetIconIndex(Name, SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
  Open := GetIconIndex(Name, SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_OPENICON);
end;

//----------------- TDrawTreeForm --------------------------------------------------------------------------------------

procedure TfrmSelectSharePath.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CancelNowChecked( vstSelectPath.RootNode );
end;

procedure TfrmSelectSharePath.FormCreate(Sender: TObject);
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
end;

procedure TfrmSelectSharePath.FormShow(Sender: TObject);
begin
  if diaBtn.BtnOK.Enabled then
    diaBtn.BtnOK.Enabled := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSharePath.AddDeskTopPath;
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

procedure TfrmSelectSharePath.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectSharePath.btnOKClick(Sender: TObject);
begin
  FindBackupPath( vstSelectPath.RootNode );
  Close;
end;


function TfrmSelectSharePath.CancelNowChecked(Node: PVirtualNode): Boolean;
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
      if not ( vsDisabled in ChildNode.States ) and CancelNowChecked( ChildNode ) then
        ChildNode.CheckState := csUncheckedNormal;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;


procedure TfrmSelectSharePath.ClearBackupPath( Node : PVirtualNode );
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  FullPath : string;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable 的节点
    if ( vsDisabled in ChildNode.States ) then
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      FullPath := NodeData.FullPath;

      ChildNode.States := ChildNode.States - [ vsDisabled ];
      ChildNode.CheckState := csUncheckedNormal;
    end
    else
      RemoveOldAddChildNode( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
end;


procedure TfrmSelectSharePath.RemoveOldAddChildNode(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  FullPath : string;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable 的节点跳过
    if ( vsDisabled in ChildNode.States ) then
    begin
      NodeData := vstSelectPath.GetNodeData( ChildNode );
      FullPath := NodeData.FullPath;

      ChildNode.States := ChildNode.States - [ vsDisabled ];

        // 控制器 //
      MyFileShareControl.RemoveSharePath( FullPath );
    end
    else
      RemoveOldAddChildNode( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSharePath.FindBackupPath(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  FullPath : string;
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
        FullPath := NodeData.FullPath;

          // 删除 已选的子目录
        RemoveOldAddChildNode( ChildNode );

          // 控制器 //
        MyFileShareControl.AddSharePath( FullPath );
      end
      else
      if ChildNode.CheckState = csMixedNormal then  // 找下一层
        FindBackupPath( ChildNode );
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TfrmSelectSharePath.GetDriveString(Index: Integer): string;

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

function TfrmSelectSharePath.FindHasChild(Node: PVirtualNode): Boolean;
var
  Data: PShellObjectData;
  FullPath, FileName  : string;
  sch : TSearchRec;
begin
  Data := vstSelectPath.GetNodeData(Node);
  FullPath := Data.FullPath;

  Result := False;
  if not FileExists( FullPath ) then
  begin
      // 循环寻找 目录文件信息
    FullPath := MyFilePath.getPath( FullPath );
    if FindFirst( FullPath + '*', faAnyfile, sch ) = 0 then
    begin
      repeat
        FileName := sch.Name;
        if ( FileName <> '.' ) and ( FileName <> '..') then
        begin
          Result := True;
          Break;
        end;
      until FindNext(sch) <> 0;
    end;
    SysUtils.FindClose(sch);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSharePath.AddBackupPath(FullPath: string);
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

procedure TfrmSelectSharePath.SetUnChecked(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
      // Disable 和 UnChecked 的节点跳过
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

procedure TfrmSelectSharePath.RemoveBackupPath(FullPath: string);
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
      ChildNode.CheckState := csUncheckedNormal;
      ChildNode.States := ChildNode.States - [ vsDisabled ];
      if FindHasChild( ChildNode ) then
      begin
        ChildNode.States := ChildNode.States + [ vsHasChildren ];
        SetUnChecked( ChildNode );
      end;
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( FullPath, NodeFullPath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      vstSelectPath.ValidateChildren( ChildNode, False );
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectSharePath.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
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

procedure TfrmSelectSharePath.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if not diaBtn.BtnOK.Enabled then
    diaBtn.BtnOK.Enabled := True;
end;

procedure TfrmSelectSharePath.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectSharePath.vstSelectPathGetImageIndex(
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

procedure TfrmSelectSharePath.vstSelectPathGetText(
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

procedure TfrmSelectSharePath.vstSelectPathInitChildren(
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


procedure TfrmSelectSharePath.vstSelectPathInitNode(
  Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);

  if FindHasChild( Node ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

//----------------------------------------------------------------------------------------------------------------------


end.
