unit UMyBackupFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UMyUtil, DateUtils;

type

{$Region ' 数据结构 ' }

  TVstBackupData = record
  public
    ItemName : string;
    IsFile : Boolean;
  public  // 可选状态
    IsDisable : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime, NextSyncTime : TDateTime;  // 上一次同步时间
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  end;
  PVstBackupData = ^TVstBackupData;

{$EndRegion}

{$Region ' 本地备份 数据修改 ' }

    // 修改 父类
  TVstBackupWrite = class( TFaceChangeInfo )
  public
    VstBackup : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

  {$Region ' 根路径 ' }

    // 修改 根父类
  TVstLocalBackupRootWrite = class( TVstBackupWrite )
  protected
    RootNode : PVirtualNode;
    RootData : PVstBackupData;
  protected
    function FindRootNode : Boolean;
  end;

    // 添加 默认根
  TVstLocalBackupRootAddDefault = class( TVstLocalBackupRootWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 目标路径 ' }

    // 修改 目标路径
  TVstLocalBackupDesItemWrite = class( TVstLocalBackupRootWrite )
  public
    DesPath : string;
  protected
    DesNode : PVirtualNode;
    DesData : PVstBackupData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesNode : Boolean;
  end;

    // 添加
  TVstLocalBackupDesItemAdd = class( TVstLocalBackupDesItemWrite )
  protected
    procedure Update;override;
  end;

    // 删除
  TVstLocalBackupDesItemRemove = class( TVstLocalBackupDesItemWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 ' }

    // 修改 源路径
  TVstLocalBackupItemWrite = class( TVstLocalBackupDesItemWrite )
  protected
    BackupPath : string;
  protected
    BackupNode : PVirtualNode;
    BackupData : PVstBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupNode : Boolean;
    procedure RefreshBackupNode;
    procedure RefreshNextSyncTime;
  end;

    // 添加 源路径
  TVstLocalBackupItemAdd = class( TVstLocalBackupItemWrite )
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

    // 设置 暂停
  TVstLocalBackupItemSetIsDisable = class( TVstLocalBackupItemWrite )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 设置 自动同步
  TVstLocalBackupItemSetAutoSync = class( TVstLocalBackupItemWrite )
  public
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

    // 设置 空间信息
  TVstLocalBackupSetSpace = class( TVstLocalBackupItemWrite )
  public
    FileCount : Integer;
    ItemSize, CompletedSize : Int64;
  public
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TVstLocalBackupAddCompletedSpace = class( TVstLocalBackupItemWrite )
  protected
    AddCompletedSpace : Integer;
  public
    procedure SetAddCompeletedSpace( _AddCompletedSpace : Integer );
  protected
    procedure Update;override;
  end;

    // 删除 源路径
  TVstLocalBackupItemRemove = class( TVstLocalBackupItemWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络备份 数据修改 ' }

  {$Region ' 目标Pc ' }

    // 修改 目标路径
  TVstNetworkBackupPcItemWrite = class( TVstBackupWrite )
  public
    PcID : string;
  protected
    PcNode : PVirtualNode;
    PcData : PVstBackupData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
  end;

    // 添加
  TVstNetworkBackupPcItemAdd = class( TVstNetworkBackupPcItemWrite )
  protected
    procedure Update;override;
  end;

    // 删除
  TVstNetworkBackupPcItemRemove = class( TVstNetworkBackupPcItemWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 ' }

    // 修改 源路径
  TVstNetworkBackupItemWrite = class( TVstNetworkBackupPcItemWrite )
  protected
    BackupPath : string;
  protected
    BackupNode : PVirtualNode;
    BackupData : PVstBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupNode : Boolean;
    procedure RefreshBackupNode;
    procedure RefreshNextSyncTime;
  end;

    // 添加 源路径
  TVstNetworkBackupItemAdd = class( TVstNetworkBackupItemWrite )
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
    procedure SetAutoSync( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // 设置 暂停
  TVstNetworkBackupItemSetIsDisable = class( TVstNetworkBackupItemWrite )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 设置 自动同步
  TVstNetworkBackupItemSetAutoSync = class( TVstNetworkBackupItemWrite )
  public
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

    // 设置 空间信息
  TVstNetworkBackupSetSpace = class( TVstNetworkBackupItemWrite )
  public
    FileCount : Integer;
    ItemSize, CompletedSize : Int64;
  public
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TVstNetworkBackupAddCompletedSpace = class( TVstNetworkBackupItemWrite )
  protected
    AddCompletedSpace : Integer;
  public
    procedure SetAddCompeletedSpace( _AddCompletedSpace : Integer );
  protected
    procedure Update;override;
  end;

    // 删除 源路径
  TVstNetworkBackupItemRemove = class( TVstNetworkBackupItemWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

const
  ItemName_LocalBackupRoot = 'Local or Shared Folders';

implementation

uses UMainForm;

{ TVstBackupWriteInfo }

procedure TVstBackupWrite.Update;
begin
  VstBackup := frmMainForm.VstBackup;
end;

{ TVstLocalBackupAddDefaultNode }

function TVstLocalBackupRootWrite.FindRootNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;

  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemName = ItemName_LocalBackupRoot then
    begin
      Result := True;
      RootNode := SelectNode;
      RootData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstLocalBackupDesItemWrite }

constructor TVstLocalBackupDesItemWrite.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TVstLocalBackupDesItemWrite.FindDesNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  RootNode := nil;
  if not FindRootNode then
    Exit;
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemName = DesPath then
    begin
      Result := True;
      DesNode := SelectNode;
      DesData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstLocalBackupRootAdd }

procedure TVstLocalBackupRootAddDefault.Update;
begin
  inherited;

    // 已存在
  if FindRootNode then
    Exit;

  RootNode := VstBackup.AddChild( VstBackup.RootNode );
  RootData := VstBackup.GetNodeData( RootNode );
  RootData.ItemName := ItemName_LocalBackupRoot;
end;

{ TVstLocalBackupDesItemAdd }

procedure TVstLocalBackupDesItemAdd.Update;
begin
  inherited;

    // 已存在
  if FindDesNode or ( RootNode = nil ) then
    Exit;

  DesNode := VstBackup.AddChild( RootNode );
  DesData := VstBackup.GetNodeData( DesNode );
  DesData.ItemName := DesPath;
end;

{ TVstLocalBackupDesItemRemove }

procedure TVstLocalBackupDesItemRemove.Update;
begin
  inherited;

    // 不存在
  if not FindDesNode then
    Exit;

  VstBackup.DeleteNode( DesNode );
end;

{ TVstLocalBackupItemWrite }

function TVstLocalBackupItemWrite.FindBackupNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  DesNode := nil;
  if not FindDesNode then
    Exit;
  SelectNode := DesNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemName = BackupPath then
    begin
      Result := True;
      BackupNode := SelectNode;
      BackupData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstLocalBackupItemWrite.RefreshBackupNode;
begin
  VstBackup.RepaintNode( BackupNode );
end;

procedure TVstLocalBackupItemWrite.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // 计算下次 同步时间
  SyncMins := TimeTypeUtil.getMins( BackupData.SyncTimeType, BackupData.SyncTimeValue );
  BackupData.NextSyncTime := IncMinute( BackupData.LasSyncTime, SyncMins );
end;

procedure TVstLocalBackupItemWrite.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TVstLocalBackupItemAdd }

procedure TVstLocalBackupItemAdd.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TVstLocalBackupItemAdd.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstLocalBackupItemAdd.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TVstLocalBackupItemAdd.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstLocalBackupItemAdd.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstLocalBackupItemAdd.Update;
begin
  inherited;

    // 已存在
  if FindBackupNode or ( DesNode = nil ) then
    Exit;

    // 添加
  BackupNode := VstBackup.AddChild( DesNode );
  BackupData := VstBackup.GetNodeData( BackupNode );
  BackupData.ItemName := BackupPath;
  BackupData.IsFile := IsFile;
  BackupData.IsDisable := IsDisable;
  BackupData.IsAutoSync := IsAutoSync;
  BackupData.SyncTimeType := SyncTimeType;
  BackupData.SyncTimeValue := SyncTimeValue;
  BackupData.LasSyncTime := LasSyncTime;
  BackupData.FileCount := FileCount;
  BackupData.ItemSize := ItemSize;
  BackupData.CompletedSize := CompletedSize;

    // 刷新下次同步
  RefreshNextSyncTime;
end;

{ TVstLocalBackupItemRemove }

procedure TVstLocalBackupItemRemove.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  VstBackup.DeleteNode( BackupNode );
end;

{ TVstLocalBackupItemSetIsDisable }

procedure TVstLocalBackupItemSetIsDisable.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstLocalBackupItemSetIsDisable.Update;
begin
  inherited;

  if not FindBackupNode then
    Exit;

  BackupData.IsDisable := IsDisable;

    // 刷新节点
  RefreshBackupNode;
end;

{ TVstLocalBackupItemSetAutoSync }

procedure TVstLocalBackupItemSetAutoSync.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TVstLocalBackupItemSetAutoSync.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstLocalBackupItemSetAutoSync.Update;
begin
  inherited;

  if not FindBackupNode then
    Exit;

  BackupData.IsAutoSync := IsAutoSync;
  BackupData.SyncTimeType := SyncTimeType;
  BackupData.SyncTimeValue := SyncTimeValue;

    // 刷新下次同步
  RefreshNextSyncTime;

    // 刷新节点
  RefreshBackupNode;
end;

{ TVstLocalBackupSetSpace }

procedure TVstLocalBackupSetSpace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstLocalBackupSetSpace.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  BackupData.FileCount := FileCount;
  BackupData.ItemSize := ItemSize;
  BackupData.CompletedSize := CompletedSize;
  RefreshBackupNode;
end;

{ TVstLocalBackupAddCompletedSpace }

procedure TVstLocalBackupAddCompletedSpace.SetAddCompeletedSpace(
  _AddCompletedSpace: Integer);
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TVstLocalBackupAddCompletedSpace.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  BackupData.CompletedSize := BackupData.CompletedSize + AddCompletedSpace;
  RefreshBackupNode;
end;


{ TVstNetworkBackupDesItemWrite }

constructor TVstNetworkBackupPcItemWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TVstNetworkBackupPcItemWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  SelectNode := VstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemName = PcID then
    begin
      Result := True;
      PcNode := SelectNode;
      PcData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstNetworkBackupDesItemAdd }

procedure TVstNetworkBackupPcItemAdd.Update;
begin
  inherited;

    // 已存在
  if FindPcNode then
    Exit;

  PcNode := VstBackup.AddChild( VstBackup.RootNode );
  PcData := VstBackup.GetNodeData( PcNode );
  PcData.ItemName := PcID;
end;

{ TVstNetworkBackupDesItemRemove }

procedure TVstNetworkBackupPcItemRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPcNode then
    Exit;

  VstBackup.DeleteNode( PcNode );
end;

{ TVstNetworkBackupItemWrite }

function TVstNetworkBackupItemWrite.FindBackupNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  PcNode := nil;
  if not FindPcNode then
    Exit;
  SelectNode := PcNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemName = BackupPath then
    begin
      Result := True;
      BackupNode := SelectNode;
      BackupData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstNetworkBackupItemWrite.RefreshBackupNode;
begin
  VstBackup.RepaintNode( BackupNode );
end;

procedure TVstNetworkBackupItemWrite.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // 计算下次 同步时间
  SyncMins := TimeTypeUtil.getMins( BackupData.SyncTimeType, BackupData.SyncTimeValue );
  BackupData.NextSyncTime := IncMinute( BackupData.LasSyncTime, SyncMins );
end;

procedure TVstNetworkBackupItemWrite.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TVstNetworkBackupItemAdd }

procedure TVstNetworkBackupItemAdd.SetAutoSync(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TVstNetworkBackupItemAdd.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstNetworkBackupItemAdd.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TVstNetworkBackupItemAdd.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstNetworkBackupItemAdd.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstNetworkBackupItemAdd.Update;
begin
  inherited;

    // 已存在
  if FindBackupNode or ( PcNode = nil ) then
    Exit;

    // 添加
  BackupNode := VstBackup.AddChild( PcNode );
  BackupData := VstBackup.GetNodeData( BackupNode );
  BackupData.ItemName := BackupPath;
  BackupData.IsFile := IsFile;
  BackupData.IsDisable := IsDisable;
  BackupData.IsAutoSync := IsAutoSync;
  BackupData.SyncTimeType := SyncTimeType;
  BackupData.SyncTimeValue := SyncTimeValue;
  BackupData.LasSyncTime := LasSyncTime;
  BackupData.FileCount := FileCount;
  BackupData.ItemSize := ItemSize;
  BackupData.CompletedSize := CompletedSize;

    // 刷新下次同步
  RefreshNextSyncTime;
end;

{ TVstNetworkBackupItemRemove }

procedure TVstNetworkBackupItemRemove.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  VstBackup.DeleteNode( BackupNode );
end;

{ TVstNetworkBackupItemSetIsDisable }

procedure TVstNetworkBackupItemSetIsDisable.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstNetworkBackupItemSetIsDisable.Update;
begin
  inherited;

  if not FindBackupNode then
    Exit;

  BackupData.IsDisable := IsDisable;

    // 刷新节点
  RefreshBackupNode;
end;

{ TVstNetworkBackupItemSetAutoSync }

procedure TVstNetworkBackupItemSetAutoSync.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TVstNetworkBackupItemSetAutoSync.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstNetworkBackupItemSetAutoSync.Update;
begin
  inherited;

  if not FindBackupNode then
    Exit;

  BackupData.IsAutoSync := IsAutoSync;
  BackupData.SyncTimeType := SyncTimeType;
  BackupData.SyncTimeValue := SyncTimeValue;

    // 刷新下次同步
  RefreshNextSyncTime;

    // 刷新节点
  RefreshBackupNode;
end;

{ TVstNetworkBackupSetSpace }

procedure TVstNetworkBackupSetSpace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstNetworkBackupSetSpace.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  BackupData.FileCount := FileCount;
  BackupData.ItemSize := ItemSize;
  BackupData.CompletedSize := CompletedSize;
  RefreshBackupNode;
end;

{ TVstNetworkBackupAddCompletedSpace }

procedure TVstNetworkBackupAddCompletedSpace.SetAddCompeletedSpace(
  _AddCompletedSpace: Integer);
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TVstNetworkBackupAddCompletedSpace.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  BackupData.CompletedSize := BackupData.CompletedSize + AddCompletedSpace;
  RefreshBackupNode;
end;


end.
