unit UMyRestoreFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UIconUtil;

type

{$Region ' 恢复文件 ' }

{$Region ' 数据结构 ' }

      // 数据结构
  TVstRestoreData = record
  public
    ItemID : WideString;
  public
    IsFile : boolean;
    OwnerID,OwnerName : WideString;
  public
    FileCount : integer;
    FileSize : int64;
    LastBackupTime : TDateTime;
  public
    ShowName, NodeType : WideString;
    MainIcon : Integer;
  end;
  PVstRestoreData = ^TVstRestoreData;


{$EndRegion}

{$Region ' 本地备份 ' }

  {$Region ' 数据修改 目标信息 ' }

    // 父类
  TLocalRestoreDesChangeFace = class( TFaceChangeInfo )
  public
    VstRestore : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TLocalRestoreDesWriteFace = class( TLocalRestoreDesChangeFace )
  public
    DesPath : string;
  protected
    RestoreDesNode : PVirtualNode;
    RestoreDesData : PVstRestoreData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindRestoreDesNode : Boolean;
  end;

    // 添加
  TLocalRestoreDesAddFace = class( TLocalRestoreDesWriteFace )
  protected
    procedure Update;override;
  end;

    // 删除
  TLocalRestoreDesRemoveFace = class( TLocalRestoreDesWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 数据修改 备份信息 ' }

    // 修改
  TLocalRestoreItemWriteFace = class( TLocalRestoreDesWriteFace )
  public
    BackupPath : string;
  protected
    RestoreItemNode : PVirtualNode;
    RestoreItemData : PVstRestoreData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindRestorePcBackupNode : Boolean;
  end;

    // 添加
  TLocalRestoreItemAddFace = class( TLocalRestoreItemWriteFace )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    FileSize : int64;
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TLocalRestoreItemRemoveFace = class( TLocalRestoreItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络备份 ' }

  {$Region ' 数据修改 Pc信息 ' }

    // 父类
  TNetworkRestoreDesChangeFace = class( TFaceChangeInfo )
  public
    VstRestore : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TNetworkRestoreDesWriteFace = class( TNetworkRestoreDesChangeFace )
  public
    PcID : string;
  protected
    RestoreDesNode : PVirtualNode;
    RestoreDesData : PVstRestoreData;
  public
    constructor Create( _PcID : string );
  protected
    function FindRestoreDesNode : Boolean;
  end;

    // 添加
  TNetworkRestoreDesAddFace = class( TNetworkRestoreDesWriteFace )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TNetworkRestoreDesRemoveFace = class( TNetworkRestoreDesWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 数据修改 备份信息 ' }

    // 修改
  TNetworkRestoreItemWriteFace = class( TNetworkRestoreDesWriteFace )
  public
    OwnerID, BackupPath : string;
  protected
    RestorePcBackupNode : PVirtualNode;
    RestorePcBackupData : PVstRestoreData;
  public
    procedure SetOwnerID( _OwnerID : string );
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindRestorePcBackupNode : Boolean;
  end;

    // 添加
  TNetworkRestoreItemAddFace = class( TNetworkRestoreItemWriteFace )
  public
    IsFile : boolean;
  public
    OwnerName : string;
  public
    FileCount : integer;
    FileSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
  protected
    procedure Update;override;
  end;


    // 删除
  TNetworkRestoreItemRemoveFace = class( TNetworkRestoreItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$EndRegion}

{$Region ' 恢复文件下载 ' }

{$Region ' 数据结构 ' }

    // 数据结构
  TRestoreDownData = record
  public
    RestorePath, RestoreOwner : string;
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  end;
  PRestoreDownData = ^TRestoreDownData;

{$EndRegion}

{$Region ' 数据修改 ' }

    // 父类
  TRestoreDownChangeFace = class( TFaceChangeInfo )
  public
    VstRestoreDown : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownWriteFace = class( TRestoreDownChangeFace )
  public
    RestorePath, RestoreOwner : string;
  protected
    RestoreDownNode : PVirtualNode;
    RestoreDownData : PRestoreDownData;
  public
    constructor Create( _RestorePath, _RestoreOwner : string );
  protected
    function FindRestoreDownNode : Boolean;
  end;


    // 添加
  TRestoreDownAddFace = class( TRestoreDownWriteFace )
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetRestoreFrom( _RestoreFrom : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreDownRemoveFace = class( TRestoreDownWriteFace )
  protected
    procedure Update;override;
  end;




{$EndRegion}

{$EndRegion}

const
  RestoreIcon_PcOnline = 1;
  RestoreIcon_Folder = 5;

  RestoreNodeType_LocalDes = 'LocalDes';
  RestoreNodeType_LocalRestore = 'LocalRestore';
  RestoreNodeType_NetworkDes = 'NetworkDes';
  RestoreNodeType_NetworkRestore = 'NetworkRestore';


implementation

uses UMainForm;

{ TRestorePcChangeFace }

procedure TNetworkRestoreDesChangeFace.Update;
begin
  VstRestore := frmMainForm.vstRestore;
end;

{ TRestorePcWriteFace }

constructor TNetworkRestoreDesWriteFace.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TNetworkRestoreDesWriteFace.FindRestoreDesNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  SelectNode := VstRestore.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if ( SelectData.ItemID = PcID ) then
    begin
      Result := True;
      RestoreDesNode := SelectNode;
      RestoreDesData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcAddFace }

procedure TNetworkRestoreDesAddFace.SetPcName( _PcName : string );
begin
  PcName := _PcName;
end;

procedure TNetworkRestoreDesAddFace.Update;
begin
  inherited;

  if FindRestoreDesNode then
    Exit;

  RestoreDesNode := VstRestore.AddChild( VstRestore.RootNode );
  RestoreDesNode.NodeHeight := 28;

  RestoreDesData := VstRestore.GetNodeData( RestoreDesNode );
  RestoreDesData.ItemID := PcID;
  RestoreDesData.ShowName := PcName;
  RestoreDesData.MainIcon := RestoreIcon_PcOnline;
  RestoreDesData.NodeType := RestoreNodeType_NetworkDes;
end;

{ TRestorePcRemoveFace }

procedure TNetworkRestoreDesRemoveFace.Update;
begin
  inherited;

  if not FindRestoreDesNode then
    Exit;

  VstRestore.DeleteNode( RestoreDesNode );
end;

{ TRestorePcBackupWriteFace }

procedure TNetworkRestoreItemWriteFace.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


procedure TNetworkRestoreItemWriteFace.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

function TNetworkRestoreItemWriteFace.FindRestorePcBackupNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  if not FindRestoreDesNode then
    Exit;
  SelectNode := RestoreDesNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if ( SelectData.ItemID = BackupPath ) and ( SelectData.OwnerID = OwnerID ) then
    begin
      Result := True;
      RestorePcBackupNode := SelectNode;
      RestorePcBackupData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcBackupAddFace }

procedure TNetworkRestoreItemAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TNetworkRestoreItemAddFace.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TNetworkRestoreItemAddFace.SetOwnerName( _OwnerName : string );
begin
  OwnerName := _OwnerName;
end;

procedure TNetworkRestoreItemAddFace.SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TNetworkRestoreItemAddFace.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindRestorePcBackupNode then
  begin

    RestorePcBackupNode := VstRestore.AddChild( RestoreDesNode );
    RestorePcBackupData := VstRestore.GetNodeData( RestorePcBackupNode );
    RestorePcBackupData.ItemID := BackupPath;
    RestorePcBackupData.ShowName := BackupPath;
    RestorePcBackupData.IsFile := IsFile;
    RestorePcBackupData.OwnerID := OwnerID;
    RestorePcBackupData.OwnerName := OwnerName;
    RestorePcBackupData.NodeType := RestoreNodeType_NetworkRestore;

    if IsFile then
      RestorePcBackupData.MainIcon := MyIcon.getIconByFileExt( BackupPath )
    else
      RestorePcBackupData.MainIcon := MyShellIconUtil.getFolderIcon;

    if not VstRestore.Expanded[ RestoreDesNode ] then
      VstRestore.Expanded[ RestoreDesNode ] := True;
  end;

    // 修改 空间信息
  RestorePcBackupData.FileCount := FileCount;
  RestorePcBackupData.FileSize := FileSize;
  RestorePcBackupData.LastBackupTime := LastBackupTime;
end;

{ TRestorePcBackupRemoveFace }

procedure TNetworkRestoreItemRemoveFace.Update;
begin
  inherited;

  if not FindRestorePcBackupNode then
    Exit;

  VstRestore.DeleteNode( RestorePcBackupNode );
end;

{ TRestorePcWriteFace }

constructor TLocalRestoreDesWriteFace.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;


function TLocalRestoreDesWriteFace.FindRestoreDesNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  SelectNode := VstRestore.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if ( SelectData.ItemID = DesPath ) then
    begin
      Result := True;
      RestoreDesNode := SelectNode;
      RestoreDesData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcAddFace }

procedure TLocalRestoreDesAddFace.Update;
begin
  inherited;

  if FindRestoreDesNode then
    Exit;

  RestoreDesNode := VstRestore.AddChild( VstRestore.RootNode );
  RestoreDesNode.NodeHeight := 28;

  RestoreDesData := VstRestore.GetNodeData( RestoreDesNode );
  RestoreDesData.ItemID := DesPath;
  RestoreDesData.ShowName := DesPath;
  RestoreDesData.MainIcon := RestoreIcon_Folder;
  RestoreDesData.NodeType := RestoreNodeType_LocalDes;
end;

{ TRestorePcRemoveFace }

procedure TLocalRestoreDesRemoveFace.Update;
begin
  inherited;

  if not FindRestoreDesNode then
    Exit;

  VstRestore.DeleteNode( RestoreDesNode );
end;

{ TRestorePcBackupWriteFace }

procedure TLocalRestoreItemWriteFace.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

function TLocalRestoreItemWriteFace.FindRestorePcBackupNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreData;
begin
  Result := False;
  if not FindRestoreDesNode then
    Exit;
  SelectNode := RestoreDesNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestore.GetNodeData( SelectNode );
    if SelectData.ItemID = BackupPath  then
    begin
      Result := True;
      RestoreItemNode := SelectNode;
      RestoreItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestorePcBackupAddFace }

procedure TLocalRestoreItemAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TLocalRestoreItemAddFace.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TLocalRestoreItemAddFace.SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalRestoreItemAddFace.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindRestorePcBackupNode then
  begin

    RestoreItemNode := VstRestore.AddChild( RestoreDesNode );
    RestoreItemData := VstRestore.GetNodeData( RestoreItemNode );
    RestoreItemData.ItemID := BackupPath;
    RestoreItemData.ShowName := BackupPath;
    RestoreItemData.IsFile := IsFile;
    RestoreItemData.OwnerName := 'My Computer';
    RestoreItemData.NodeType := RestoreNodeType_LocalRestore;

    if IsFile then
      RestoreItemData.MainIcon := MyIcon.getIconByFileExt( BackupPath )
    else
      RestoreItemData.MainIcon := MyShellIconUtil.getFolderIcon;

    if not VstRestore.Expanded[ RestoreDesNode ] then
      VstRestore.Expanded[ RestoreDesNode ] := True;
  end;

    // 修改 空间信息
  RestoreItemData.FileCount := FileCount;
  RestoreItemData.FileSize := FileSize;
  RestoreItemData.LastBackupTime := LastBackupTime;
end;

{ TRestorePcBackupRemoveFace }

procedure TLocalRestoreItemRemoveFace.Update;
begin
  inherited;

  if not FindRestorePcBackupNode then
    Exit;

  VstRestore.DeleteNode( RestoreItemNode );
end;


{ TLocalRestoreDesChangeFace }

procedure TLocalRestoreDesChangeFace.Update;
begin
  VstRestore := frmMainForm.vstRestore;
end;

{ TRestoreDownChangeFace }

procedure TRestoreDownChangeFace.Update;
begin
  VstRestoreDown := frmMainForm.vstRestoreHistory;
end;

{ TRestoreDownWriteFace }

constructor TRestoreDownWriteFace.Create( _RestorePath, _RestoreOwner : string );
begin
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
end;


function TRestoreDownWriteFace.FindRestoreDownNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PRestoreDownData;
begin
  Result := False;
  SelectNode := VstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstRestoreDown.GetNodeData( SelectNode );
    if ( SelectData.RestorePath = RestorePath ) and ( SelectData.RestoreOwner = RestoreOwner ) then
    begin
      Result := True;
      RestoreDownNode := SelectNode;
      RestoreDownData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRestoreDownAddFace }

procedure TRestoreDownAddFace.SetRestoreFrom( _RestoreFrom : string );
begin
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownAddFace.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddFace.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

procedure TRestoreDownAddFace.Update;
begin
  inherited;

  if FindRestoreDownNode then
    Exit;

  RestoreDownNode := VstRestoreDown.AddChild( VstRestoreDown.RootNode );
  RestoreDownData := VstRestoreDown.GetNodeData( RestoreDownNode );
  RestoreDownData.RestorePath := RestorePath;
  RestoreDownData.RestoreOwner := RestoreOwner;
  RestoreDownData.RestoreFrom := RestoreFrom;
  RestoreDownData.FileCount := FileCount;
  RestoreDownData.FileSize := FileSize;
  RestoreDownData.CompletedSize := CompletedSize;
  RestoreDownData.SavePath := SavePath;
end;

{ TRestoreDownRemoveFace }

procedure TRestoreDownRemoveFace.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  VstRestoreDown.DeleteNode( RestoreDownNode );
end;





end.
