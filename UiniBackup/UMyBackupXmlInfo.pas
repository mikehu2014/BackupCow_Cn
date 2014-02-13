unit UMyBackupXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' 本地备份 修改Xml ' }

  {$Region ' 目标路径 ' }

  TLocalDesItemWriteXml = class( TXmlChangeInfo )
  public
    DesPath : string;
  protected
    DesNodeIndex : Integer;
    DesNode : IXMLNode;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesNode : Boolean;
  end;

  TLocalDesItemAddXml = class( TLocalDesItemWriteXml )
  protected
    procedure Update;override;
  end;

  TLocalDesItemRemoveXml = class( TLocalDesItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 增删 ' }

  TLocalBackupWriteXml = class( TLocalDesItemWriteXml )
  public
    BackupNodeList : IXMLNode;
  public
    function FindBackupNodeList : Boolean;
  end;

  TLocalBackupItemWriteXml = class( TLocalBackupWriteXml )
  public
    BackupPath : string;
  protected
    BackupNodeIndex : Integer;
    BackupNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupNode : Boolean;
  end;

  TLocalBackupItemAddXml = class( TLocalBackupItemWriteXml )
  public  // 路径信息
    IsFile : Boolean;
  public  // 可选状态
    IsDisable, IsBackupNow : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
  public  // 删除保留信息
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

  TLocalBackupItemRemoveXml = class( TLocalBackupItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 修改状态 ' }

    // 是否 禁止备份
  TLocalBackupItemSetIsDisableXml = class( TLocalBackupItemWriteXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 是否 Backup Now 备份
  TLocalBackupItemSetIsBackupNowXml = class( TLocalBackupItemWriteXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 同步信息 ' }

    // 设置 上一次 同步时间
  TLocalBackupItemSetLastSyncTimeXml = class( TLocalBackupItemWriteXml )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TLocalBackupItemSetAutoSyncXml = class( TLocalBackupItemWriteXml )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络备份 修改Xml ' }

  {$Region ' 目标Pc ' }

  TNetworkPcItemWriteXml = class( TXmlChangeInfo )
  public
    PcID : string;
  protected
    PcNodeIndex : Integer;
    PcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
  end;

  TNetworkPcItemAddXml = class( TNetworkPcItemWriteXml )
  protected
    procedure Update;override;
  end;

  TNetworkPcItemRemoveXml = class( TNetworkPcItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 增删 ' }

  TNetworkBackupWriteXml = class( TNetworkPcItemWriteXml )
  public
    BackupNodeList : IXMLNode;
  public
    function FindBackupNodeList : Boolean;
  end;

  TNetworkBackupItemWriteXml = class( TNetworkBackupWriteXml )
  public
    BackupPath : string;
  protected
    BackupNodeIndex : Integer;
    BackupNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupNode : Boolean;
  end;

  TNetworkBackupItemAddXml = class( TNetworkBackupItemWriteXml )
  public  // 路径信息
    IsFile : Boolean;
  public  // 可选状态
    IsDisable, IsBackupNow : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
  public  // 删除保留信息
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSync( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

  TNetworkBackupItemRemoveXml = class( TNetworkBackupItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 修改状态 ' }

    // 是否 禁止备份
  TNetworkBackupItemSetIsDisableXml = class( TNetworkBackupItemWriteXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 是否 Backup Now 备份
  TNetworkBackupItemSetIsBackupNowXml = class( TNetworkBackupItemWriteXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 同步信息 ' }

    // 设置 上一次 同步时间
  TNetworkBackupItemSetLastSyncTimeXml = class( TNetworkBackupItemWriteXml )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TNetworkBackupItemSetAutoSyncXml = class( TNetworkBackupItemWriteXml )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 本地备份 读取Xml ' }

    // 读取 备份路径
  TLocalBackupItemReadXml = class
  private
    DesPath : string;
    BackupItemNode : IXMLNode;
  public
    constructor Create( _BackupItemNode : IXMLNode );
    procedure SetDesPath( _DesPath : string );
    procedure Update;
  end;

    // 读取 目标路径
  TLocalBackupDesItemReadXml = class
  private
    DesItemNode : IXMLNode;
  private
    DesPath : string;
  public
    constructor Create( _DesItemNode : IXMLNode );
    procedure Update;
  private
    procedure ReadBackupItemList;
  end;

    // 读取 本地备份 信息
  TLocalBackupReadXmlHandle = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_DesPath = 'dp';
  Xml_BackupItemList = 'bil';

  Xml_BackupPath = 'bp';
  Xml_IsFile = 'if';
  Xml_IsDisable = 'id';
  Xml_IsBackupNow = 'ibn';
  Xml_IsAutoSync = 'ias';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_LastSyncTime = 'lst';
  Xml_IsKeepDeleted = 'ikd';
  Xml_KeepEditionCount = 'kec';
  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_CompeltedSize = 'cs';

implementation

uses UMyBackupApiInfo;

{ TLocalDesItemWriteXml }

constructor TLocalDesItemWriteXml.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TLocalDesItemWriteXml.FindDesNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to LocalDesItemListXml.ChildNodes.Count - 1 do
  begin
    SelectNode := LocalDesItemListXml.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_DesPath ) = DesPath then
    begin
      Result := True;
      DesNodeIndex := i;
      DesNode := SelectNode;
      Break;
    end;
  end;
end;

{ TLocalDesItemAddXml }

procedure TLocalDesItemAddXml.Update;
begin
    // 已存在
  if FindDesNode then
    Exit;

  DesNode := MyXmlUtil.AddListChild( LocalDesItemListXml );
  MyXmlUtil.AddChild( DesNode, Xml_DesPath, DesPath );
end;

{ TLocalDesItemRemoveXml }

procedure TLocalDesItemRemoveXml.Update;
begin
  if not FindDesNode then
    Exit;

  LocalDesItemListXml.ChildNodes.Delete( DesNodeIndex );
end;

{ TLocalBackupItemWriteXml }

function TLocalBackupItemWriteXml.FindBackupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  BackupNodeList := nil;
  if not FindBackupNodeList then
    Exit;
  for i := 0 to BackupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath then
    begin
      Result := True;
      BackupNodeIndex := i;
      BackupNode := SelectNode;
      Break;
    end;
  end;
end;

procedure TLocalBackupItemWriteXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TLocalBackupWriteXml }

function TLocalBackupWriteXml.FindBackupNodeList: Boolean;
begin
  Result := FindDesNode;
  if Result then
    BackupNodeList := MyXmlUtil.AddChild( DesNode, Xml_BackupItemList );
end;

{ TLocalBackupItemAddXml }

procedure TLocalBackupItemAddXml.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TLocalBackupItemAddXml.SetBackupStatus(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupItemAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TLocalBackupItemAddXml.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TLocalBackupItemAddXml.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupItemAddXml.Update;
begin
  if FindBackupNode or ( BackupNodeList = nil ) then
    Exit;

  BackupNode := MyXmlUtil.AddListChild( BackupNodeList );
  MyXmlUtil.AddChild( BackupNode, Xml_BackupPath, BackupPath );
  MyXmlUtil.AddChild( BackupNode, Xml_IsFile, IsFile );

  MyXmlUtil.AddChild( BackupNode, Xml_IsDisable, IsDisable );
  MyXmlUtil.AddChild( BackupNode, Xml_IsBackupNow, IsBackupNow );

  MyXmlUtil.AddChild( BackupNode, Xml_IsAutoSync, IsAutoSync );
  MyXmlUtil.AddChild( BackupNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( BackupNode, Xml_SyncTimeValue, SyncTimeValue );
  MyXmlUtil.AddChild( BackupNode, Xml_LastSyncTime, LasSyncTime );

  MyXmlUtil.AddChild( BackupNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( BackupNode, Xml_KeepEditionCount, KeepEditionCount );

  MyXmlUtil.AddChild( BackupNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupNode, Xml_CompeltedSize, CompletedSize );
end;

{ TLocalBackupItemRemoveXml }

procedure TLocalBackupItemRemoveXml.Update;
begin
  if not FindBackupNode then
    Exit;

  BackupNodeList.ChildNodes.Delete( BackupNodeIndex );
end;

{ TLocalBackupItemSetIsDisableXml }

procedure TLocalBackupItemSetIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupItemSetIsDisableXml.Update;
begin
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_IsDisable, IsDisable );
end;

{ TLocalBackupItemSetIsBackupNowXml }

procedure TLocalBackupItemSetIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemSetIsBackupNowXml.Update;
begin
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_IsBackupNow, IsBackupNow );
end;

{ TLocalBackupItemSetLastSyncTimeXml }

procedure TLocalBackupItemSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupItemSetLastSyncTimeXml.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_LastSyncTime, LastSyncTime );
end;

{ TLocalBackupItemSetAutoSyncXml }

procedure TLocalBackupItemSetAutoSyncXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupItemSetAutoSyncXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupItemSetAutoSyncXml.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
end;

{ TNetworkDesItemWriteXml }

constructor TNetworkPcItemWriteXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TNetworkPcItemWriteXml.FindPcNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to NetworkDesItemListXml.ChildNodes.Count - 1 do
  begin
    SelectNode := NetworkDesItemListXml.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_DesPath ) = PcID then
    begin
      Result := True;
      PcNodeIndex := i;
      PcNode := SelectNode;
      Break;
    end;
  end;
end;

{ TNetworkDesItemAddXml }

procedure TNetworkPcItemAddXml.Update;
begin
    // 已存在
  if FindPcNode then
    Exit;

  PcNode := MyXmlUtil.AddListChild( NetworkDesItemListXml );
  MyXmlUtil.AddChild( PcNode, Xml_DesPath, PcID );
end;

{ TNetworkDesItemRemoveXml }

procedure TNetworkPcItemRemoveXml.Update;
begin
  if not FindPcNode then
    Exit;

  NetworkDesItemListXml.ChildNodes.Delete( PcNodeIndex );
end;

{ TNetworkBackupItemWriteXml }

function TNetworkBackupItemWriteXml.FindBackupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  BackupNodeList := nil;
  if not FindBackupNodeList then
    Exit;
  for i := 0 to BackupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := BackupNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath then
    begin
      Result := True;
      BackupNodeIndex := i;
      BackupNode := SelectNode;
      Break;
    end;
  end;
end;

procedure TNetworkBackupItemWriteXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TNetworkBackupWriteXml }

function TNetworkBackupWriteXml.FindBackupNodeList: Boolean;
begin
  Result := FindPcNode;
  if Result then
    BackupNodeList := MyXmlUtil.AddChild( PcNode, Xml_BackupItemList );
end;

{ TNetworkBackupItemAddXml }

procedure TNetworkBackupItemAddXml.SetAutoSync(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TNetworkBackupItemAddXml.SetBackupStatus(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TNetworkBackupItemAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TNetworkBackupItemAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TNetworkBackupItemAddXml.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TNetworkBackupItemAddXml.SetSyncInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TNetworkBackupItemAddXml.Update;
begin
  if FindBackupNode or ( BackupNodeList = nil ) then
    Exit;

  BackupNode := MyXmlUtil.AddListChild( BackupNodeList );
  MyXmlUtil.AddChild( BackupNode, Xml_BackupPath, BackupPath );
  MyXmlUtil.AddChild( BackupNode, Xml_IsFile, IsFile );

  MyXmlUtil.AddChild( BackupNode, Xml_IsDisable, IsDisable );
  MyXmlUtil.AddChild( BackupNode, Xml_IsBackupNow, IsBackupNow );

  MyXmlUtil.AddChild( BackupNode, Xml_IsAutoSync, IsAutoSync );
  MyXmlUtil.AddChild( BackupNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( BackupNode, Xml_SyncTimeValue, SyncTimeValue );
  MyXmlUtil.AddChild( BackupNode, Xml_LastSyncTime, LasSyncTime );

  MyXmlUtil.AddChild( BackupNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( BackupNode, Xml_KeepEditionCount, KeepEditionCount );

  MyXmlUtil.AddChild( BackupNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupNode, Xml_CompeltedSize, CompletedSize );
end;

{ TNetworkBackupItemRemoveXml }

procedure TNetworkBackupItemRemoveXml.Update;
begin
  if not FindBackupNode then
    Exit;

  BackupNodeList.ChildNodes.Delete( BackupNodeIndex );
end;

{ TNetworkBackupItemSetIsDisableXml }

procedure TNetworkBackupItemSetIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TNetworkBackupItemSetIsDisableXml.Update;
begin
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_IsDisable, IsDisable );
end;

{ TNetworkBackupItemSetIsBackupNowXml }

procedure TNetworkBackupItemSetIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TNetworkBackupItemSetIsBackupNowXml.Update;
begin
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_IsBackupNow, IsBackupNow );
end;

{ TNetworkBackupItemSetLastSyncTimeXml }

procedure TNetworkBackupItemSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TNetworkBackupItemSetLastSyncTimeXml.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
  MyXmlUtil.AddChild( BackupNode, Xml_LastSyncTime, LastSyncTime );
end;

{ TNetworkBackupItemSetAutoSyncXml }

procedure TNetworkBackupItemSetAutoSyncXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TNetworkBackupItemSetAutoSyncXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TNetworkBackupItemSetAutoSyncXml.Update;
begin
  inherited;
  if not FindBackupNode then
    Exit;
end;


{ TLocalBackupXmlReadHandle }

procedure TLocalBackupReadXmlHandle.Update;
var
  i : Integer;
  DesItemNode : IXMLNode;
  LocalBackupDesItemReadXml : TLocalBackupDesItemReadXml;
begin
  for i := 0 to LocalDesItemListXml.ChildNodes.Count - 1 do
  begin
    DesItemNode := LocalDesItemListXml.ChildNodes[i];

    LocalBackupDesItemReadXml := TLocalBackupDesItemReadXml.Create( DesItemNode );
    LocalBackupDesItemReadXml.Update;
    LocalBackupDesItemReadXml.Free;
  end;
end;

{ TLocalBackupDesItemReadXml }

constructor TLocalBackupDesItemReadXml.Create(_DesItemNode: IXMLNode);
begin
  DesItemNode := _DesItemNode;
end;

procedure TLocalBackupDesItemReadXml.ReadBackupItemList;
var
  BackupItemList : IXMLNode;
  i : Integer;
  BackupItemNode : IXMLNode;
  LocalBackupItemReadXml : TLocalBackupItemReadXml;
begin
  BackupItemList := MyXmlUtil.AddChild( DesItemNode, Xml_BackupItemList );
  for i := 0 to BackupItemList.ChildNodes.Count - 1 do
  begin
    BackupItemNode := BackupItemList.ChildNodes[i];

    LocalBackupItemReadXml := TLocalBackupItemReadXml.Create( BackupItemNode );
    LocalBackupItemReadXml.SetDesPath( DesPath );
    LocalBackupItemReadXml.Update;
    LocalBackupItemReadXml.Free;
  end;
end;

procedure TLocalBackupDesItemReadXml.Update;
var
  LocalBackupDesItemReadHandle : TLocalBackupDesItemReadHandle;
begin
  DesPath := MyXmlUtil.GetChildValue( DesItemNode, Xml_DesPath );

    // 读取 目标路径
  LocalBackupDesItemReadHandle := TLocalBackupDesItemReadHandle.Create( DesPath );
  LocalBackupDesItemReadHandle.Update;
  LocalBackupDesItemReadHandle.Free;

    // 读取 目标路径 的源路径
  ReadBackupItemList;
end;

{ TLocalBackupItemReadXml }

constructor TLocalBackupItemReadXml.Create(_BackupItemNode: IXMLNode);
begin
  BackupItemNode := _BackupItemNode;
end;

procedure TLocalBackupItemReadXml.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

procedure TLocalBackupItemReadXml.Update;
var
  BackupPath : string;
  IsFile : Boolean;
  IsDisable, IsBackupNow : Boolean;
  IsAutoSync : Boolean; // 是否自动同步
  SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  LasSyncTime : TDateTime;  // 上一次同步时间
  IsKeepDeleted : Boolean;
  KeepEditionCount : Integer;
  FileCount : Integer;
  ItemSize, CompletedSize : Int64; // 空间信息
begin
  BackupPath := MyXmlUtil.GetChildValue( BackupItemNode, Xml_BackupPath );
  IsFile := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsFile );

  IsDisable := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsDisable );
  IsBackupNow := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsBackupNow );

  IsAutoSync := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsAutoSync );
  SyncTimeType := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeType );
  SyncTimeValue := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeValue );
  LasSyncTime := MyXmlUtil.GetChildFloatValue( BackupItemNode, Xml_LastSyncTime );

  IsKeepDeleted := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsKeepDeleted );
  KeepEditionCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_KeepEditionCount );

  FileCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_ItemSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_CompeltedSize );
end;

end.
