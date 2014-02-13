unit UFormLocalBackupPath;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  VirtualTrees, StdCtrls,
  ImgList, ComCtrls, ExtCtrls, SyncObjs, UIconUtil, RzPanel, RzDlgBtn, RzTabs;

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


  TfrmSelectLocalBackupPath = class(TForm)
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
  private
    FDriveStrings: string;
    function GetDriveString(Index: Integer): string;
    procedure AddDeskTopPath;
  private
    procedure FindSelectPath( Node : PVirtualNode; SelectPathList : TStringList ); // Find Path
    function RemoveNewChecked( Node : PVirtualNode ): Boolean;overload;
    procedure SetUnChecked( Node : PVirtualNode );   // ��� Checked
  public
    procedure AddBackupPath( FullPath : string );  // Add Path
    procedure RemoveBackupPath( FullPath : string ); // Remove Path
  public
    function getNewSelectList : TStringList;  // get SelectList
    procedure RemoveNewChecked;overload;  // Remove Select
  end;

const
  VstSelectLocalBackupPath_FileName = 0;
  VstSelectLocalBackupPath_FileSize = 1;
  VstSelectLocalBackupPath_FileTime = 2;

var
  frmSelectLocalBackupPath: TfrmSelectLocalBackupPath;
  DeskTopPath : string;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  FileCtrl, ShellAPI, Mask, ShlObj, ActiveX, UMyUtil, UMainForm, ULocalBackupControl;

{$R *.DFM}

procedure TfrmSelectLocalBackupPath.FormCreate(Sender: TObject);
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
end;

procedure TfrmSelectLocalBackupPath.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
  if diaBtn.BtnOK.Enabled then
    diaBtn.BtnOK.Enabled := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectLocalBackupPath.AddDeskTopPath;
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

procedure TfrmSelectLocalBackupPath.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectLocalBackupPath.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;


function TfrmSelectLocalBackupPath.RemoveNewChecked(Node: PVirtualNode): Boolean;
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

procedure TfrmSelectLocalBackupPath.FindSelectPath(Node: PVirtualNode;
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

function TfrmSelectLocalBackupPath.GetDriveString(Index: Integer): string;

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

function TfrmSelectLocalBackupPath.getNewSelectList: TStringList;
begin
  Result := TStringList.Create;
  FindSelectPath( vstSelectPath.RootNode, Result );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectLocalBackupPath.AddBackupPath(FullPath: string);
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

procedure TfrmSelectLocalBackupPath.SetUnChecked(Node: PVirtualNode);
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

procedure TfrmSelectLocalBackupPath.RemoveBackupPath(FullPath: string);
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

procedure TfrmSelectLocalBackupPath.RemoveNewChecked;
begin
  RemoveNewChecked( vstSelectPath.RootNode );
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TfrmSelectLocalBackupPath.vdtBackupFolderHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState;
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

procedure TfrmSelectLocalBackupPath.vstSelectPathChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  if not diaBtn.BtnOK.Enabled then
    diaBtn.BtnOK.Enabled := True;
end;

procedure TfrmSelectLocalBackupPath.vstSelectPathFreeNode(
  Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;


procedure TfrmSelectLocalBackupPath.vstSelectPathGetImageIndex(
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

procedure TfrmSelectLocalBackupPath.vstSelectPathGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: String);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData( Node );

  if Column = VstSelectLocalBackupPath_FileName then
    CellText := Data.Display
  else
  if Column = VstSelectLocalBackupPath_FileSize then
  begin
    if Data.IsFolder then
      CellText := ''
    else
     CellText := MySize.getFileSizeStr( Data.FileSize )
  end
  else
  if Column = VstSelectLocalBackupPath_FileTime then
    CellText := DateTimeToStr( Data.FileTime )
  else
    CellText := '';
end;

procedure TfrmSelectLocalBackupPath.vstSelectPathInitChildren(
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


procedure TfrmSelectLocalBackupPath.vstSelectPathInitNode(
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


end.
