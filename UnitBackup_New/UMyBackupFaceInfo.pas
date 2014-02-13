unit UMyBackupFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UMyUtil, DateUtils, ComCtrls;

type

{$Region ' 数据结构 ' }

  TVstBackupData = record
  public
    ItemID : WideString;
    IsFile : Boolean;
  public   // 备份状态
    IsExist, IsWrite, IsLackSpace : Boolean;
  public  // 可选状态
    IsDisable : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LastSyncTime, NextSyncTime : TDateTime;  // 上一次同步时间
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
    Percentage : Integer;
    Speed : Int64; // 传输速度
  public
    ShowName, NodeType, NodeStatus : WideString;
    MainIcon, StatusIcon : Integer;
  end;
  PVstBackupData = ^TVstBackupData;

{$EndRegion}

{$Region ' 备份信息 数据修改 ' }

  {$Region ' 目标路径 增删 ' }

  TDesItemChangeFace = class( TFaceChangeInfo )
  public
    VstBackup : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改 目标路径
  TDesItemWriteFace = class( TDesItemChangeFace )
  public
    DesPath : string;
  protected
    DesItemNode : PVirtualNode;
    DesItemData : PVstBackupData;
  protected
    FirstNetworkDesNode : PVirtualNode;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
    procedure RefreshDesNode;
  end;

    // 添加 本地目标
  TDesItemAddLocalFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

    // 添加 网络目标
  TDesItemAddNetworkFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

    // 删除
  TDesItemRemoveFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 目标路径 状态 ' }

    // 修改 路径是否存在
  TDesItemSetIsExistFace = class( TDesItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 路径是否可写
  TDesItemSetIsWriteFace = class( TDesItemWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // 修改 目标路径是否缺少备份空间
  TDesItemSetIsLackSpaceFace = class( TDesItemWriteFace )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}


  {$Region ' 源路径 增删 ' }

    // 修改 源路径
  TBackupItemWriteFace = class( TDesItemWriteFace )
  protected
    BackupPath : string;
  protected
    BackupItemNode : PVirtualNode;
    BackupItemData : PVstBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemNode : Boolean;
    procedure RefreshBackupNode;
  protected
    procedure RefreshNextSyncTime;
    procedure RefreshPercentage;
  end;

    // 添加 源路径
  TBackupItemAddFace = class( TBackupItemWriteFace )
  public
    IsFile : Boolean;
  public  // 可选状态
    IsDisable : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // 删除 源路径
  TBackupItemRemoveFace = class( TBackupItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 状态 ' }

    // 设置 暂停
  TBackupItemSetIsDisableFace = class( TBackupItemWriteFace )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 修改 是否存在
  TBackupItemSetIsExistFace = class( TBackupItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // 修改
  TBackupItemSetStatusFace = class( TBackupItemWriteFace )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
  protected
    procedure Update;override;
  end;

      // 修改
  TBackupItemSetSpeedFace = class( TBackupItemWriteFace )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 自动同步 ' }

    // 设置 自动同步
  TBackupItemSetAutoSyncFace = class( TBackupItemWriteFace )
  public
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

    // 修改
  TBackupItemSetLastSyncTimeFace = class( TBackupItemWriteFace )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' 源路径 空间信息 ' }

   // 设置 空间信息
  TBackupItemSetSpaceInfoFace = class( TBackupItemWriteFace )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TBackupItemSetAddCompletedSpaceFace = class( TBackupItemWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 选择窗口 数据修改 ' }

  {$Region ' 本地目标路径 ' }

  TLocalDesData = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
  end;

    // 父类
  TFrmLocalDesChange = class( TFaceChangeInfo )
  public
    LvDes : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TFrmLocalDesWrite = class( TFrmLocalDesChange )
  public
    DesPath : string;
  protected
    DesIndex : Integer;
    DesItem : TListItem;
    DesData : TLocalDesData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
  end;

    // 添加
  TFrmLocalDesAdd = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

    // 删除
  TFrmLocalDesRemove = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 网络目标路径 ' }

  TNetworkDesData = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 父类
  TFrmNetworkDesChange = class( TFaceChangeInfo )
  public
    LvNetworkDes : TListView;
  protected
    procedure Update;override;
  end;

    // 修改
  TFrmNetworkDesWrite = class( TFrmNetworkDesChange )
  public
    PcID : string;
  protected
    NetworkDesIndex : Integer;
    NetworkDesItem : TListItem;
    NetworkDesData : TNetworkDesData;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetworkDesItemNode : Boolean;
  end;

    // 添加
  TFrmNetworkDesAdd = class( TFrmNetworkDesWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TFrmNetworkDesRemove = class( TFrmNetworkDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 辅助类 ' }

  VstBackupUtil = class
  public             // 状态文本
    class function getLocalDesStatus( Node : PVirtualNode ): string;
    class function getNetworkDesStatus( Node : PVirtualNode ): string;
    class function getBackupStatus( Node : PVirtualNode ): string;
  public             // 状态图标
    class function getDesStatusIcon( Node : PVirtualNode ): Integer;
    class function getBackupStatusIcon( Node : PVirtualNode ): Integer;
  end;

{$EndRegion}

const
  ItemName_BackupRoot = ' or Shared Folders';
  BackupIcon_Folder = 5;
  BackupIcon_PcOffline = 0;
  BackupIcon_PcOnline = 1;

  BackupNodeStatus_WaitingBackup = 'Waiting';
  BackupNodeStatus_Backuping = 'Backuping';
  BackupNodeStatus_Analyizing = 'Analyzing %s Files';
  BackupNodeStatus_Empty = '';

  BackupStatusShow_NotExist = 'Not Exist';
  BackupStatusShow_NotWrite = 'Cannot Write';
  BackupStatusShow_NotSpace = 'Space Insufficient';
  BackupStatusShow_Disable = 'Disable';
  BackupStatusShow_PcOffline = 'Offline';

  BackupStatusShow_Incompleted = 'Incompleted';
  BackupStatusShow_Completed = 'Completed';

const
  FrmDesIcon_PcOffline = 0;
  FrmDesIcon_PcOnline = 1;


const
  BackupNodeType_LocalDes = 'LocalDes';
  BackupNodeType_LocalBackup = 'Backup';

  BackupNodeType_NetworkDes = 'NetworkDes';
  BackupNodeType_NetworkBackup = 'NetworkBackup';

implementation

uses UMainForm, UIconUtil, UFrmSelectBackupItem;

{ TVstBackupDesItemWrite }

constructor TDesItemWriteFace.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TDesItemWriteFace.FindDesItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  FirstNetworkDesNode := nil;
  SelectNode := vstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = DesPath then
    begin
      Result := True;
      DesItemNode := SelectNode;
      DesItemData := SelectData;
      Break;
    end;
    if ( SelectData.NodeType = BackupNodeType_NetworkDes ) and
       not Assigned( FirstNetworkDesNode )
    then
      FirstNetworkDesNode := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TDesItemWriteFace.RefreshDesNode;
begin
  VstBackup.RepaintNode( DesItemNode );
end;

{ TVstBackupDesItemRemove }

procedure TDesItemRemoveFace.Update;
begin
  inherited;

    // 不存在
  if not FindDesItemNode then
    Exit;

  VstBackup.DeleteNode( DesItemNode );
end;

{ TVstBackupItemWrite }

function TBackupItemWriteFace.FindBackupItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  DesItemNode := nil;
  if not FindDesItemNode then
    Exit;
  SelectNode := DesItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = BackupPath then
    begin
      Result := True;
      BackupItemNode := SelectNode;
      BackupItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TBackupItemWriteFace.RefreshBackupNode;
begin
  VstBackup.RepaintNode( BackupItemNode );
end;

procedure TBackupItemWriteFace.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // 计算下次 同步时间
  SyncMins := TimeTypeUtil.getMins( BackupItemData.SyncTimeType, BackupItemData.SyncTimeValue );
  BackupItemData.NextSyncTime := IncMinute( BackupItemData.LastSyncTime, SyncMins );
end;

procedure TBackupItemWriteFace.RefreshPercentage;
begin
  BackupItemData.Percentage := MyPercentage.getPercent( BackupItemData.CompletedSize, BackupItemData.ItemSize );
end;

procedure TBackupItemWriteFace.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TVstBackupItemAdd }

procedure TBackupItemAddFace.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemAddFace.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddFace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddFace.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddFace.Update;
begin
  inherited;

    // 已存在
  if FindBackupItemNode or ( DesItemNode = nil ) then
    Exit;

    // 添加
  BackupItemNode := VstBackup.AddChild( DesItemNode );
  BackupItemData := VstBackup.GetNodeData( BackupItemNode );
  BackupItemData.ItemID := BackupPath;
  BackupItemData.ShowName := BackupPath;
  BackupItemData.IsFile := IsFile;
  BackupItemData.IsDisable := IsDisable;
  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;
  BackupItemData.LastSyncTime := LasSyncTime;
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;
  BackupItemData.IsExist := True;
  BackupItemData.NodeStatus := '';
  BackupItemData.MainIcon := MyIcon.getIconByFilePath( BackupPath );
  if DesItemData.NodeType = BackupNodeType_LocalDes then
    BackupItemData.NodeType := BackupNodeType_LocalBackup
  else
    BackupItemData.NodeType := BackupNodeType_NetworkBackup;

  VstBackup.Expanded[ DesItemNode ] := True;

    // 刷新信息
  RefreshNextSyncTime;
  RefreshPercentage;
end;

{ TVstBackupItemRemove }

procedure TBackupItemRemoveFace.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  VstBackup.DeleteNode( BackupItemNode );
end;

{ TVstBackupItemSetIsDisable }

procedure TBackupItemSetIsDisableFace.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemSetIsDisableFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsDisable := IsDisable;

    // 刷新节点
  RefreshBackupNode;
end;

{ TVstBackupItemSetAutoSync }

procedure TBackupItemSetAutoSyncFace.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncFace.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;

    // 刷新下次同步
  RefreshNextSyncTime;

    // 刷新节点
  RefreshBackupNode;
end;

{ TBackupItemSetSpaceInfoFace }

procedure TBackupItemSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;

    // 刷新节点
  RefreshPercentage;
  RefreshBackupNode;
end;

{ TBackupItemSetAddCompletedSpaceFace }

procedure TBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.CompletedSize := BackupItemData.CompletedSize + AddCompletedSpace;

    // 刷新节点
  RefreshPercentage;
  RefreshBackupNode;
end;

{ TNetworkDesItemChangeFace }

procedure TFrmNetworkDesChange.Update;
begin
  LvNetworkDes := frmSelectBackupItem.lvNetworkDes;
end;

{ TNetworkDesItemWriteFace }

constructor TFrmNetworkDesWrite.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TFrmNetworkDesWrite.FindNetworkDesItemNode : Boolean;
var
  SelectItem : TListItem;
  SelectData : TNetworkDesData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvNetworkDes.Items.Count - 1 do
  begin
    SelectData := LvNetworkDes.Items[i].Data;
    if ( SelectData.PcID = PcID ) then
    begin
      Result := True;
      NetworkDesIndex := i;
      NetworkDesItem := SelectItem;
      NetworkDesData := SelectData;
      Break;
    end;
  end;
end;



{ TNetworkDesData }

constructor TNetworkDesData.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TFrmNetworkDesAdd }

procedure TFrmNetworkDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmNetworkDesAdd.Update;
begin
  inherited;

  if FindNetworkDesItemNode then
    Exit;

  NetworkDesItem := LvNetworkDes.Items.Add;
  NetworkDesData := TNetworkDesData.Create( PcID );
  with NetworkDesItem do
  begin
    Caption := PcName;
    SubItems.Add('');
    Data := NetworkDesData;
    ImageIndex := FrmDesIcon_PcOffline;
  end;
end;

{ TFrmNetworkDesRemove }

procedure TFrmNetworkDesRemove.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  LvNetworkDes.Items.Delete( NetworkDesIndex );
end;

{ TDesItemChangeFace }

procedure TFrmLocalDesChange.Update;
begin
//  LvDes := frmSelectBackupItem;
end;

{ TDesItemChangeFace }

procedure TDesItemChangeFace.Update;
begin
  VstBackup := FrmMainForm.VstBackup;
end;

{ TDesItemWriteFace }

constructor TFrmLocalDesWrite.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;


function TFrmLocalDesWrite.FindDesItemNode : Boolean;
var
  SelectItem : TListItem;
  SelectData : TLocalDesData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvDes.Items.Count - 1 do
  begin
    SelectData := LvDes.Items[i].Data;
    if ( SelectData.DesPath = DesPath ) then
    begin
      Result := True;
      DesIndex := i;
      DesItem := SelectItem;
      DesData := SelectData;
      Break;
    end;
  end;
end;



{ TDesData }

constructor TLocalDesData.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TFrmDesAdd }

procedure TFrmLocalDesAdd.Update;
begin
  inherited;

  if FindDesItemNode then
    Exit;

  DesItem := LvDes.Items.Add;
  DesData := TLocalDesData.Create( DesPath );
  with DesItem do
  begin
    Caption := DesPath;
    SubItems.Add('');
    Data := DesData;
    ImageIndex := MyIcon.getIconByFilePath( DesPath );
  end;
end;

{ TFrmDesRemove }

procedure TFrmLocalDesRemove.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  LvDes.Items.Delete( DesIndex );
end;

{ TDesItemSetIsExistFace }

procedure TDesItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TDesItemSetIsExistFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsExist := IsExist;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsWriteFace }

procedure TDesItemSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TDesItemSetIsWriteFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsWrite := IsWrite;

    // 刷新节点
  RefreshDesNode;
end;

{ TDesItemSetIsLackSpaceFace }

procedure TDesItemSetIsLackSpaceFace.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TDesItemSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsLackSpace := IsLackSpace;

    // 刷新节点
  RefreshDesNode;
end;

{ TBackupItemSetIsExistFace }

procedure TBackupItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TBackupItemSetIsExistFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsExist := IsExist;

    // 刷新节点
  RefreshBackupNode;
end;

{ TBackupItemSetBackupItemStatusFace }

procedure TBackupItemSetStatusFace.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TBackupItemSetStatusFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.NodeStatus := BackupItemStatus;

    // 刷新节点
  RefreshBackupNode;
end;



{ VstBackupUtil }

class function VstBackupUtil.getBackupStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.IsDisable then
    Result := BackupStatusShow_Disable
  else
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
  begin
    if NodeData.Speed <= 0 then
      Result := BackupNodeStatus_Backuping
    else
      Result := MySpeed.getSpeedStr( NodeData.Speed )
  end
  else
  if NodeData.NodeStatus <> '' then
    Result := NodeData.NodeStatus
  else
  if NodeData.CompletedSize >= NodeData.ItemSize then
    Result := BackupStatusShow_Completed
  else
    Result := BackupStatusShow_InCompleted;
end;

class function VstBackupUtil.getBackupStatusIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := MyShellBackupStatusIconUtil.getFileIncompleted
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
    Result := MyShellTransActionIconUtil.getSync
  else
  if NodeData.NodeStatus <> '' then
    Result := MyShellBackupStatusIconUtil.getFilePartcompleted
  else
  if NodeData.CompletedSize >= NodeData.ItemSize then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function VstBackupUtil.getLocalDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := BackupStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := BackupStatusShow_NotSpace
  else
    Result := '';
end;

class function VstBackupUtil.getDesStatusIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist or
     not NodeData.IsWrite or
     NodeData.IsLackSpace
  then
    Result := MyShellBackupStatusIconUtil.getFileIncompleted
  else
    Result := -1;
end;


class function VstBackupUtil.getNetworkDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := BackupStatusShow_PcOffline
  else
  if NodeData.IsLackSpace then
    Result := BackupStatusShow_NotSpace
  else
    Result := '';
end;

{ TBackupItemSetLastSyncTimeFace }

procedure TBackupItemSetLastSyncTimeFace.SetLastSyncTime( _LastSyncTime : TDateTime );
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.LastSyncTime := LastSyncTime;

  RefreshNextSyncTime;
  RefreshBackupNode;
end;


{ TBackupItemSetSpeedFace }

procedure TBackupItemSetSpeedFace.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TBackupItemSetSpeedFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.Speed := Speed;

  RefreshDesNode;
end;

{ TDesItemAddLocalFace }

procedure TDesItemAddLocalFace.Update;
begin
  inherited;

    // 已存在
  if FindDesItemNode then
    Exit;

  if Assigned( FirstNetworkDesNode ) then
    DesItemNode := VstBackup.InsertNode( FirstNetworkDesNode, amInsertBefore )
  else
    DesItemNode := VstBackup.AddChild( VstBackup.RootNode );
  DesItemNode.NodeHeight := 28;

  DesItemData := VstBackup.GetNodeData( DesItemNode );
  DesItemData.ItemID := DesPath;
  DesItemData.IsExist := True;
  DesItemData.IsWrite := True;
  DesItemData.IsLackSpace := False;
  DesItemData.NodeStatus := '';
  DesItemData.ShowName := DesPath;
  DesItemData.MainIcon := BackupIcon_Folder;
  DesItemData.NodeType := BackupNodeType_LocalDes;
end;

{ TDesItemAddNetworkFace }

procedure TDesItemAddNetworkFace.Update;
begin
  inherited;

    // 已存在
  if FindDesItemNode then
    Exit;

  DesItemNode := VstBackup.AddChild( VstBackup.RootNode );
  DesItemNode.NodeHeight := 28;

  DesItemData := VstBackup.GetNodeData( DesItemNode );
  DesItemData.ItemID := DesPath;
  DesItemData.IsExist := True;
  DesItemData.IsWrite := True;
  DesItemData.IsLackSpace := False;
  DesItemData.NodeStatus := '';
  DesItemData.ShowName := DesPath;
  DesItemData.MainIcon := BackupIcon_Folder;
  DesItemData.NodeType := BackupNodeType_NetworkDes;
end;

end.
