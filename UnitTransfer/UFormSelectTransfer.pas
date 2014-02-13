unit UFormSelectTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, StdCtrls, ComCtrls, ExtCtrls, ShellAPI, UIconUtil, UMyUtil, ShlObj,
  ImgList, UMainForm, Menus, RzTabs;

type
  TfrmSelectTransfer = class(TForm)
    plButtons: TPanel;
    ilPcMain: TImageList;
    PcMain: TRzPageControl;
    tsSelectFile: TRzTabSheet;
    vstSelectSendFile: TVirtualStringTree;
    tsSelectDes: TRzTabSheet;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    VstSelectSendPc: TVirtualStringTree;
    PlNoPcSend: TPanel;
    Panel2: TPanel;
    lbFileSendTips: TLabel;
    Label1: TLabel;
    Image4: TImage;
    plShowAllComputers: TPanel;
    btnShowAllPc: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Label13: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    procedure vstSelectSendFileGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure vstSelectSendFileGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure vstSelectSendFileInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstSelectSendFileInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstSelectSendFileFreeNode(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure vstSelectSendFileChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure lvSelectSendDesDeletion(Sender: TObject; Item: TListItem);
    procedure lvSelectSendDesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VstSelectSendPcGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VstSelectSendPcGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure VstSelectSendPcChecked(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure btnShowAllPcClick(Sender: TObject);
  public
    procedure DropFiles(var Msg: TMessage); message WM_DROPFILES;
  private
    procedure IniVstSelectFile;
    procedure AddDeskTopPath;
    procedure VstSelectFileUnCheck( Node : PVirtualNode );
    procedure VstSelectFileCheck( Node : PVirtualNode );
    function IsSelectDes : Boolean;
  private
    procedure AddSendFile( FullPath : string );
    procedure AddSendFiles( FilePathList : TStringList );
    function SendSelectFile: Boolean;
  private
    procedure AddSendFileDes( DesPcList : TStringList );overload;
    procedure AddSendFileDes( PcID : string );overload;
  private
    procedure CancelLastSelect;
    procedure CancelPcSelect;
    procedure SetDefaultPcSelect;
  public
    procedure ShowSelectFiles;overload;
    procedure ShowSelectDes( FilePathList : TStringList );
    procedure ShowSelectFiles( DesPcList : TStringList );overload;
  end;

  FormFileSendUtil = class
  public
    class function getDesklopNode : PVirtualNode;
  end;

    // 检测 发送文件是否受试用版限制
  TCheckFileSendFreeLimit = class
  public
    FileList : TStringList;
  public
    constructor Create( _FileList : TStringList );
    function get : Boolean;
  private
    function getIsFileCountLimit( FolderPath : string ): Boolean;
    function getFileCount( FolderPath : string ): Integer;
  end;

    // 寻找 选中的文件 和 Pc
  TFindSendFileHandle = class
  private
    FileList : TStringList;
    DesPcList : TStringList;
  public
    constructor Create;
    function Update: Boolean;
    destructor Destroy; override;
  private
    function FindFileList : Boolean;
    function FindDesPcList : Boolean;
  private
    function getIsFreeLimit : Boolean;
    procedure FindSelectFile( Node : PVirtualNode );
  end;

const
    // Vst SelectSendFile
  VstSelectSendFile_FileName = 0;
  VstSelectSendFile_FileSize = 1;
  VstSelectSendFile_FileDate = 2;

    // Vst SelectSendPc
  VstSelectSendPc_PcName = 0;
  VstSelectSendPc_Status = 1;

  BtnOKTag_Next = 0;
  BtnOKTag_OK = 1;

  BtnOKCaption_Next = 'Next';
  BtnOKCaption_OK = 'OK';

  ShowError_SelectFile = 'Please select files';
  ShowError_SelectDestination = 'Please select Destinations';

  PageSelectDes_Normal = 0;
  PageSelectDes_NoPc = 1;

var
  frmSelectTransfer: TfrmSelectTransfer;

implementation

uses UFormBackupPath, UFileTransferFace, UMyFileTransferControl, URegisterInfo, UFormFreeEdition,
     UNetworkFace;

{$R *.dfm}

{ TfrmSelectTransfer }

procedure TfrmSelectTransfer.AddDeskTopPath;
var
  Node : PVirtualNode;
  NodeData : PShellObjectData;
begin
  DeskTopPath := MyFilePath.getDesklopPath;

  Node := vstSelectSendFile.AddChild( vstSelectSendFile.RootNode );
  NodeData := vstSelectSendFile.GetNodeData( Node );
  NodeData.FullPath := DeskTopPath;
  NodeData.Display := ExtractFileName( DeskTopPath );
  NodeData.FileTime := MyFileInfo.getFileLastWriteTime( DeskTopPath );
  NodeData.IsFolder := True;
end;

procedure TfrmSelectTransfer.AddSendFile(FullPath: string);
var
  ParentNode : PVirtualNode;
  ChildNode : PVirtualNode;
  NodeData : PShellObjectData;
  NodeFullPath : string;
begin
    // 是否桌面的情况
  if MyMatchMask.CheckEqualsOrChild( FullPath, DeskTopPath ) then
  begin
    ParentNode := FormFileSendUtil.getDesklopNode;
    ParentNode.States := ParentNode.States + [ vsHasChildren ];
    ParentNode.CheckState := csMixedNormal;
    vstSelectSendFile.ValidateChildren( ParentNode, False );
    vstSelectSendFile.Expanded[ ParentNode ] := True;
  end
  else
    ParentNode := vstSelectSendFile.RootNode;

  ChildNode := ParentNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    NodeData := vstSelectSendFile.GetNodeData( ChildNode );
    NodeFullPath := NodeData.FullPath;

      // 找到了节点
    if FullPath = NodeFullPath then
    begin
      VstSelectFileCheck( ChildNode );
      ChildNode.CheckState := csCheckedNormal;
      Break;
    end;

      // 找到了父节点
    if MyMatchMask.CheckChild( FullPath, NodeFullPath ) then
    begin
      ChildNode.States := ChildNode.States + [ vsHasChildren ];
      ChildNode.CheckState := csMixedNormal;
      vstSelectSendFile.ValidateChildren( ChildNode, False );
      vstSelectSendFile.Expanded[ ChildNode ] := True;
      ChildNode := ChildNode.FirstChild;
      Continue;
    end;

      // 下一个节点
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.AddSendFileDes(DesPcList: TStringList);
var
  i : Integer;
begin
  for i := 0 to DesPcList.Count - 1 do
    AddSendFileDes( DesPcList[i] );
end;

procedure TfrmSelectTransfer.AddSendFileDes(PcID: string);
var
  SelectNode : PVirtualNode;
  SelectData : PVstSelectSendPcData;
begin
  SelectNode := VstSelectSendPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstSelectSendPc.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      VstSelectSendPc.CheckState[ SelectNode ] := csCheckedNormal;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.AddSendFiles(FilePathList: TStringList);
var
  i : Integer;
begin
  for i := 0 to FilePathList.Count - 1 do
    AddSendFile( FilePathList[i] );
end;

procedure TfrmSelectTransfer.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectTransfer.btnOKClick(Sender: TObject);
begin
  if btnOK.Tag = BtnOKTag_Next then
  begin
    tsSelectDes.TabVisible := True;
    PcMain.ActivePage := tsSelectDes;
    btnOK.Tag := BtnOKTag_OK;
    btnOK.Caption := BtnOKCaption_OK;
    btnOK.Enabled := VstSelectSendPc.CheckedCount > 0;
  end
  else
  if SendSelectFile then
    Close;
end;

procedure TfrmSelectTransfer.btnShowAllPcClick(Sender: TObject);
begin
  frmMainForm.tiFileSendDesAll.Click;
end;

procedure TfrmSelectTransfer.CancelLastSelect;
var
  PcNode : PVirtualNode;
begin
    // 取消选择文件
  VstSelectFileUnCheck( vstSelectSendFile.RootNode );

    // 取消离线的 Pc
  PcNode := VstSelectSendPc.GetFirstChecked;
  while Assigned( PcNode ) do
  begin
    if not VstSelectSendPc.IsVisible[ PcNode ] then // 离线 Pc
      VstSelectSendPc.CheckState[ PcNode ] := csUncheckedNormal;
    PcNode := VstSelectSendPc.GetNextChecked( PcNode );
  end;
end;

procedure TfrmSelectTransfer.CancelPcSelect;
var
  PcNode : PVirtualNode;
begin
    // 所有选择的 Pc
  PcNode := VstSelectSendPc.GetFirstChecked;
  while Assigned( PcNode ) do
  begin
    VstSelectSendPc.CheckState[ PcNode ] := csUncheckedNormal;
    PcNode := VstSelectSendPc.GetNextChecked( PcNode );
  end;
end;

procedure TfrmSelectTransfer.DropFiles(var Msg: TMessage);
var
  FilesCount: Integer; // 文件总数
  i: Integer;
  FileName: array[0..255] of Char;
  FilePath : string;
begin
  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);

  try
    // 获取文件名
    for i := 0 to FilesCount - 1 do
    begin
      DragQueryFile(Msg.WParam, i, FileName, 256);
      FilePath := FileName;

      AddSendFile( FilePath );
    end;
  except
  end;

  // 释放
  DragFinish(Msg.WParam);

  btnOK.Enabled := True;
end;

procedure TfrmSelectTransfer.FormCreate(Sender: TObject);
begin
  DragAcceptFiles( Handle, TRUE); //设置需要处理文件 WM_DROPFILES 拖放消息
  IniVstSelectFile;
  VstSelectSendPc.NodeDataSize := SizeOf( TVstSelectSendPcData );
end;

procedure TfrmSelectTransfer.IniVstSelectFile;
var
  SFI: TSHFileInfo;
  i, Count, DriverCount: Integer;
  DriveMap, Mask: Cardinal;
  FDriveStrings: string;
  RootNode : PVirtualNode;
  RootData : PShellObjectData;
  DriverPath : string;
begin
  vstSelectSendFile.NodeDataSize := SizeOf(TShellObjectData);
  vstSelectSendFile.Images := MyIcon.getSysIcon;

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
    DriverPath := MySplitStr.GetDriveString( FDriveStrings, i );
    if not MyHardDisk.getDriverExist( DriverPath ) then
      Continue;

    RootNode := vstSelectSendFile.AddChild( vstSelectSendFile.RootNode );
    RootData := vstSelectSendFile.GetNodeData( RootNode );
    RootData.FullPath := DriverPath;
    RootData.Display := DriverPath;
    RootData.FileTime := MyFileInfo.getFileLastWriteTime( DriverPath );
    RootData.FileSize := MyHardDisk.getHardDiskAllSize( DriverPath );
    RootData.IsFolder := False;
  end;

    // 添加 桌面
  AddDeskTopPath;
end;

function TfrmSelectTransfer.IsSelectDes: Boolean;
var
  SelectNode : PVirtualNode;
begin
  Result := False;

  SelectNode := VstSelectSendPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstSelectSendPc.CheckState[ SelectNode ] = csCheckedNormal then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.lvSelectSendDesDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmSelectTransfer.lvSelectSendDesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  btnOK.Enabled := IsSelectDes;
end;

function TfrmSelectTransfer.SendSelectFile: Boolean;
var
  FindSendFileHandle : TFindSendFileHandle;
begin
  FindSendFileHandle := TFindSendFileHandle.Create;
  Result := FindSendFileHandle.Update;
  FindSendFileHandle.Free;
end;

procedure TfrmSelectTransfer.SetDefaultPcSelect;
var
  PcNode : PVirtualNode;
begin
    // 已经选择
  if VstSelectSendPc.CheckedCount > 0 then
    Exit;

    // 显示多台Pc
  if VstSelectSendPc.VisibleCount <> 1 then
    Exit;

    // 第一台显示的 Pc
  PcNode := VstSelectSendPc.RootNode.FirstChild;
  while Assigned( PcNode ) do
  begin
    if VstSelectSendPc.IsVisible[ PcNode ] then // 默认选择一台
    begin
      VstSelectSendPc.CheckState[ PcNode ] := csCheckedNormal;
      Break;
    end;
    PcNode := PcNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.ShowSelectDes( FilePathList : TStringList );
begin
    // 取消上一次选择
  CancelLastSelect;
  SetDefaultPcSelect; // 设置默认选择的 Pc

  btnOK.Enabled := VstSelectSendPc.CheckedCount > 0;
  btnOK.Tag := BtnOKTag_OK;;
  btnOK.Caption := BtnOKCaption_OK;

  tsSelectDes.TabVisible := True;
  tsSelectFile.PageIndex := 0;
  PcMain.ActivePage := tsSelectDes;

  AddSendFiles( FilePathList );

  Show;
end;

procedure TfrmSelectTransfer.ShowSelectFiles(DesPcList: TStringList);
begin
    // 取消上一次选择
  CancelLastSelect;
  CancelPcSelect;

  btnOK.Enabled := False;
  btnOK.Tag := BtnOKTag_OK;;
  btnOK.Caption := BtnOKCaption_OK;

  tsSelectDes.TabVisible := True;
  tsSelectDes.PageIndex := 0;
  PcMain.ActivePage := tsSelectFile;

  AddSendFileDes( DesPcList );

  Show;
end;

procedure TfrmSelectTransfer.ShowSelectFiles;
begin
    // 取消上一次选择
  CancelLastSelect;
  SetDefaultPcSelect; // 设置默认选择的 Pc

    // 按钮
  btnOK.Enabled := False;
  btnOK.Tag := BtnOKTag_Next;
  btnOK.Caption := BtnOKCaption_Next;

    // Page
  tsSelectDes.TabVisible := False;
  tsSelectFile.PageIndex := 0;
  PcMain.ActivePage := tsSelectFile;

    // 显示窗口
  Show;
end;

procedure TfrmSelectTransfer.VstSelectFileCheck(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState <> csCheckedNormal then
    begin
      VstSelectFileCheck( ChildNode );
      ChildNode.CheckState := csCheckedNormal;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.VstSelectFileUnCheck(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState <> csUncheckedNormal then
    begin
      VstSelectFileUnCheck( ChildNode );
      ChildNode.CheckState := csUncheckedNormal;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

procedure TfrmSelectTransfer.vstSelectSendFileChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  btnOK.Enabled := Sender.CheckedCount > 0;
end;

procedure TfrmSelectTransfer.vstSelectSendFileFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TfrmSelectTransfer.vstSelectSendFileGetImageIndex(
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

procedure TfrmSelectTransfer.vstSelectSendFileGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData( Node );

  if Column = VstSelectSendFile_FileName then
    CellText := Data.Display
  else
  if Column = VstSelectSendFile_FileSize then
  begin
    if Data.IsFolder then
      CellText := ''
    else
     CellText := MySize.getFileSizeStr( Data.FileSize )
  end
  else
  if Column = VstSelectSendFile_FileDate then
    CellText := DateTimeToStr( Data.FileTime )
  else
    CellText := '';
end;

procedure TfrmSelectTransfer.vstSelectSendFileInitChildren(
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

procedure TfrmSelectTransfer.vstSelectSendFileInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);

  if MyFilePath.getHasChild( Data.FullPath ) then
    Include(InitialStates, ivsHasChildren);

  Node.CheckType := ctTriStateCheckBox;
end;

procedure TfrmSelectTransfer.VstSelectSendPcChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  btnOK.Enabled := VstSelectSendPc.CheckedCount > 0;
end;

procedure TfrmSelectTransfer.VstSelectSendPcGetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  NodeData: PVstSelectSendPcData;
begin
  if ( Column = 0 ) and
     ( ( Kind = ikNormal ) or ( Kind = ikSelected ) )
  then
  begin
    NodeData := Sender.GetNodeData(Node);
    if NodeData.IsOnline then
      ImageIndex := CloudStatusIcon_Online
    else
      ImageIndex := CloudStatusIcon_Offline;
  end
  else
    ImageIndex := -1;
end;

procedure TfrmSelectTransfer.VstSelectSendPcGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData : PVstSelectSendPcData;
begin
  NodeData := Sender.GetNodeData( Node );
  if Column = VstSelectSendPc_PcName then
    CellText := NodeData.PcName
  else
  if Column = VstSelectSendPc_Status then
  begin
    if NodeData.IsOnline then
      CellText := Status_Online
    else
      CellText := Status_Offline;
  end
  else
    CellText :=''
end;

{ TFindSendFileHandle }

constructor TFindSendFileHandle.Create;
begin
  FileList := TStringList.Create;
  DesPcList := TStringList.Create;
end;

destructor TFindSendFileHandle.Destroy;
begin
  DesPcList.Free;
  FileList.Free;
  inherited;
end;

function TFindSendFileHandle.FindDesPcList: Boolean;
var
  VstSelectSendPc : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstSelectSendPcData;
begin
  VstSelectSendPc := frmSelectTransfer.VstSelectSendPc;
  SelectNode := VstSelectSendPc.GetFirstChecked;
  while Assigned( SelectNode ) do
  begin
    if VstSelectSendPc.CheckState[SelectNode] = csCheckedNormal then
    begin
      SelectData := VstSelectSendPc.GetNodeData( SelectNode );
      DesPcList.Add( SelectData.PcID );
    end;
    SelectNode := VstSelectSendPc.GetNextChecked( SelectNode );
  end;
  Result := DesPcList.Count > 0;
end;

function TFindSendFileHandle.FindFileList: Boolean;
begin
  FindSelectFile( frmSelectTransfer.vstSelectSendFile.RootNode );

  Result := FileList.Count > 0;
end;

procedure TFindSendFileHandle.FindSelectFile(Node: PVirtualNode);
var
  ChildNode : PVirtualNode;
  ChildData : PShellObjectData;
begin
  ChildNode := Node.FirstChild;
  while Assigned( ChildNode ) do
  begin
    if ChildNode.CheckState = csCheckedNormal then
    begin
      ChildData := frmSelectTransfer.vstSelectSendFile.GetNodeData( ChildNode );
      FileList.Add( ChildData.FullPath );
    end
    else
    if ChildNode.CheckState = csMixedNormal then
      FindSelectFile( ChildNode );
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TFindSendFileHandle.getIsFreeLimit: Boolean;
var
  CheckFileShendFreeLimit : TCheckFileSendFreeLimit;
begin
  // 检测 是否受 试用版限制
  CheckFileShendFreeLimit := TCheckFileSendFreeLimit.Create(FileList);
  Result := CheckFileShendFreeLimit.get;
  CheckFileShendFreeLimit.Free;
end;

function TFindSendFileHandle.Update: Boolean;
begin
  Result := False;

    // 没有 选择文件
  if not FindFileList then
  begin
    MyMessageBox.ShowWarnning( frmSelectTransfer.Handle, ShowError_SelectFile );
    Exit;
  end;

    // 没有 选择目标 Pc
  if not FindDesPcList then
  begin
    MyMessageBox.ShowWarnning( frmSelectTransfer.Handle, ShowError_SelectDestination );
    Exit;
  end;

    // 受试用版限制
  if getIsFreeLimit then
    Exit;

    // 调用外部接口
  MyFileTransferControl.AddSendFile( FileList, DesPcList );

  Result := True;
end;

{ TCheckFileShendFreeLimit }

function TCheckFileSendFreeLimit.getIsFileCountLimit(FolderPath: string): Boolean;
begin
  Result := getFileCount( FolderPath ) >= FreeEditionLimit_SendFileCount;
end;

constructor TCheckFileSendFreeLimit.Create(_FileList: TStringList);
begin
  FileList := _FileList;
end;

function TCheckFileSendFreeLimit.get: Boolean;
var
  i : Integer;
  FilePath : string;
begin
  Result := False;
  if not RegisterInfo.getIsFreeEdition then  // 非免费版, 跳过
    Exit;

    // 检查是否存在超过 100MB 的文件
  for i := 0 to FileList.Count - 1 do
  begin
    FilePath := FileList[i];
    if EditionUtil.getSendFileIsLimit( FilePath ) then
    begin
      frmFreeEdition.ShowWarnning( FreeEditionError_SendFileSize );
      Result := True;
      Break;
    end;
    if DirectoryExists( FilePath ) and getIsFileCountLimit( FilePath ) then
    begin
      frmFreeEdition.ShowWarnning( FreeEditionError_SendFileCount );
      Result := True;
      Break;
    end;
  end;
end;

function TCheckFileSendFreeLimit.getFileCount(FolderPath: string): Integer;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
  Result := 0;

    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      ChildPath := SearcFullPath + FileName;

      if DirectoryExists( ChildPath ) then
        Result := Result + getFileCount( ChildPath )
      else
        Inc( Result );

        // 超过限制
      if Result > FreeEditionLimit_SendFileCount then
        Break;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

{ FormFileSendUtil }

class function FormFileSendUtil.getDesklopNode: PVirtualNode;
var
  SelectNode : PVirtualNode;
  NodeData : PShellObjectData;
begin
  Result := frmSelectTransfer.vstSelectSendFile.RootNode.FirstChild;
  SelectNode := Result;
  while Assigned( SelectNode ) do
  begin
    NodeData := frmSelectTransfer.vstSelectSendFile.GetNodeData( SelectNode );
    if NodeData.FullPath = DeskTopPath then
    begin
      Result := SelectNode;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

end.
