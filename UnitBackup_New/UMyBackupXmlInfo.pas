unit UMyBackupXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' 数据修改 ' }

  {$Region ' 目标路径 ' }

  TDesItemChangeXml = class( TXmlChangeInfo )
  protected
    MyBackupNode : IXMLNode;
    DesItemNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

  TDesItemWriteXml = class( TDesItemChangeXml )
  public
    DesItemID : string;
  protected
    DesNodeIndex : Integer;
    DesNode : IXMLNode;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesNode : Boolean;
  end;

    // 添加 本地
  TDesItemAddLocalXml = class( TDesItemWriteXml )
  protected
    procedure Update;override;
  end;

    // 添加 网络
  TDesItemAddNetworkXml = class( TDesItemWriteXml )
  protected
    procedure Update;override;
  end;

    // 删除
  TDesItemRemoveXml = class( TDesItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 增删 ' }

  TBackupWriteXml = class( TDesItemWriteXml )
  public
    BackupNodeList : IXMLNode;
  public
    function FindBackupNodeList : Boolean;
  end;

  TBackupItemWriteXml = class( TBackupWriteXml )
  public
    BackupPath : string;
  protected
    BackupNodeIndex : Integer;
    BackupItemNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemNode : Boolean;
  end;

  TBackupItemAddXml = class( TBackupItemWriteXml )
  public  // 路径信息
    IsFile : Boolean;
  public  // 可选状态
    IsDisable, IsBackupNow : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LasSyncTime : TDateTime;  // 上一次同步时间
  public  // 加密设置
    IsEncrypt : boolean;
    Password, PasswordHint : string;
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
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

  TBackupItemRemoveXml = class( TBackupItemWriteXml )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 源路径 修改状态 ' }

    // 是否 禁止备份
  TBackupItemSetIsDisableXml = class( TBackupItemWriteXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // 是否 Backup Now 备份
  TBackupItemSetIsBackupNowXml = class( TBackupItemWriteXml )
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
  TBackupItemSetLastSyncTimeXml = class( TBackupItemWriteXml )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 设置 同步周期
  TBackupItemSetAutoSyncXml = class( TBackupItemWriteXml )
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

  {$Region ' 源路径 空间信息 ' }

    // 修改
  TBackupItemSetSpaceInfoXml = class( TBackupItemWriteXml )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

  // 修改
  TBackupItemSetAddCompletedSpaceXml = class( TBackupItemWriteXml )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取 备份路径
  TBackupItemReadXml = class
  private
    DesItemID : string;
    BackupItemNode : IXMLNode;
  public
    constructor Create( _BackupItemNode : IXMLNode );
    procedure SetDesItemID( _DesItemID : string );
    procedure Update;
  end;

    // 读取 目标路径
  TBackupDesItemReadXml = class
  private
    DesItemNode : IXMLNode;
  private
    DesItemID : string;
  public
    constructor Create( _DesItemNode : IXMLNode );
    procedure Update;
  private
    procedure ReadBackupItemList;
  end;

    // 读取 本地备份 信息
  TBackupReadXmlHandle = class
  public
    procedure Update;
  end;

{$EndRegion}


const
  Xml_MyBackupInfo = 'mbif';
  Xml_DesItemList = 'dil';

  Xml_DesItemID = 'did';
  Xml_DesItemType = 'dit';
  Xml_BackupItemList = 'bil';

  Xml_BackupPath = 'bp';
  Xml_IsFile = 'if';

  Xml_IsDisable = 'id';
  Xml_IsBackupNow = 'ibn';

  Xml_IsAutoSync = 'ias';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_LastSyncTime = 'lst';

  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_CompletedSize = 'cs';

  Xml_IsKeepDeleted = 'ikd';
  Xml_KeepEditionCount = 'kec';

  Xml_IsEncrypt = 'ie';
  Xml_Password = 'pw';
  Xml_PasswordHint = 'ph';

const
  DesItemType_Local = 'Local';
  DesItemType_Network = 'Network';

implementation

uses UMyBackupApiInfo;

{ TDesItemWriteXml }

constructor TDesItemWriteXml.Create(_DesPath: string);
begin
  DesItemID := _DesPath;
end;

function TDesItemWriteXml.FindDesNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to DesItemNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := DesItemNodeList.ChildNodes[i];
    if MyXmlUtil.GetChildValue( SelectNode, Xml_DesItemID ) = DesItemID then
    begin
      Result := True;
      DesNodeIndex := i;
      DesNode := SelectNode;
      Break;
    end;
  end;
end;

{ TDesItemRemoveXml }

procedure TDesItemRemoveXml.Update;
begin
  inherited;

  if not FindDesNode then
    Exit;

  DesItemNodeList.ChildNodes.Delete( DesNodeIndex );
end;

{ TBackupItemWriteXml }

function TBackupItemWriteXml.FindBackupItemNode: Boolean;
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
      BackupItemNode := SelectNode;
      Break;
    end;
  end;
end;

procedure TBackupItemWriteXml.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TBackupWriteXml }

function TBackupWriteXml.FindBackupNodeList: Boolean;
begin
  Result := FindDesNode;
  if Result then
    BackupNodeList := MyXmlUtil.AddChild( DesNode, Xml_BackupItemList );
end;

{ TBackupItemAddXml }

procedure TBackupItemAddXml.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemAddXml.SetBackupStatus(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemAddXml.SetEncryptInfo(_IsEncrypt: boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemAddXml.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddXml.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddXml.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddXml.Update;
begin
  inherited;

  if FindBackupItemNode or ( BackupNodeList = nil ) then
    Exit;

  BackupItemNode := MyXmlUtil.AddListChild( BackupNodeList );
  MyXmlUtil.AddChild( BackupItemNode, Xml_BackupPath, BackupPath );
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsFile, IsFile );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsDisable, IsDisable );
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsBackupNow, IsBackupNow );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsAutoSync, IsAutoSync );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( BackupItemNode, Xml_SyncTimeValue, SyncTimeValue );
  MyXmlUtil.AddChild( BackupItemNode, Xml_LastSyncTime, LasSyncTime );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsEncrypt, IsEncrypt );
  MyXmlUtil.AddChild( BackupItemNode, Xml_Password, Password );
  MyXmlUtil.AddChild( BackupItemNode, Xml_PasswordHint, PasswordHint );

  MyXmlUtil.AddChild( BackupItemNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( BackupItemNode, Xml_KeepEditionCount, KeepEditionCount );

  MyXmlUtil.AddChild( BackupItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSize );
end;

{ TBackupItemRemoveXml }

procedure TBackupItemRemoveXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupNodeList.ChildNodes.Delete( BackupNodeIndex );
end;

{ TBackupItemSetIsDisableXml }

procedure TBackupItemSetIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemSetIsDisableXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsDisable, IsDisable );
end;

{ TBackupItemSetIsBackupNowXml }

procedure TBackupItemSetIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_IsBackupNow, IsBackupNow );
end;

{ TBackupItemSetLastSyncTimeXml }

procedure TBackupItemSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeXml.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_LastSyncTime, LastSyncTime );
end;

{ TBackupItemSetAutoSyncXml }

procedure TBackupItemSetAutoSyncXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncXml.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
end;


{ TBackupXmlReadHandle }

procedure TBackupReadXmlHandle.Update;
var
  MyBackupNode : IXMLNode;
  DesItemNodeList : IXMLNode;
  i : Integer;
  DesItemNode : IXMLNode;
  BackupDesItemReadXml : TBackupDesItemReadXml;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyBackupInfo );
  DesItemNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_DesItemList );
  for i := 0 to DesItemNodeList.ChildNodes.Count - 1 do
  begin
    DesItemNode := DesItemNodeList.ChildNodes[i];

    BackupDesItemReadXml := TBackupDesItemReadXml.Create( DesItemNode );
    BackupDesItemReadXml.Update;
    BackupDesItemReadXml.Free;
  end;
end;

{ TBackupDesItemReadXml }

constructor TBackupDesItemReadXml.Create(_DesItemNode: IXMLNode);
begin
  DesItemNode := _DesItemNode;
end;

procedure TBackupDesItemReadXml.ReadBackupItemList;
var
  BackupItemList : IXMLNode;
  i : Integer;
  BackupItemNode : IXMLNode;
  BackupItemReadXml : TBackupItemReadXml;
begin
  BackupItemList := MyXmlUtil.AddChild( DesItemNode, Xml_BackupItemList );
  for i := 0 to BackupItemList.ChildNodes.Count - 1 do
  begin
    BackupItemNode := BackupItemList.ChildNodes[i];

    BackupItemReadXml := TBackupItemReadXml.Create( BackupItemNode );
    BackupItemReadXml.SetDesItemID( DesItemID );
    BackupItemReadXml.Update;
    BackupItemReadXml.Free;
  end;
end;

procedure TBackupDesItemReadXml.Update;
var
  DesItemType : string;
  DesItemReadLocalHandle : TDesItemReadLocalHandle;
  DesItemReadNetworkHandle : TDesItemReadNetworkHandle;
begin
  DesItemID := MyXmlUtil.GetChildValue( DesItemNode, Xml_DesItemID );
  DesItemType := MyXmlUtil.GetChildValue( DesItemNode, Xml_DesItemType );

    // 读取 本地目标路径
  if DesItemType = DesItemType_Local then
  begin
    DesItemReadLocalHandle := TDesItemReadLocalHandle.Create( DesItemID );
    DesItemReadLocalHandle.Update;
    DesItemReadLocalHandle.Free;
  end
  else
  begin   // 读取 网络目标路径
    DesItemReadNetworkHandle := TDesItemReadNetworkHandle.Create( DesItemID );
    DesItemReadNetworkHandle.Update;
    DesItemReadNetworkHandle.Free;
  end;


    // 读取 目标路径 的源路径
  ReadBackupItemList;
end;

{ TBackupItemReadXml }

constructor TBackupItemReadXml.Create(_BackupItemNode: IXMLNode);
begin
  BackupItemNode := _BackupItemNode;
end;

procedure TBackupItemReadXml.SetDesItemID(_DesItemID: string);
begin
  DesItemID := _DesItemID;
end;

procedure TBackupItemReadXml.Update;
var
  BackupPath : string;
  IsFile : Boolean;
  IsDisable, IsBackupNow : Boolean;
  IsAutoSync : Boolean; // 是否自动同步
  SyncTimeType, SyncTimeValue : Integer; // 同步间隔
  LastSyncTime : TDateTime;  // 上一次同步时间
  IsKeepDeleted : Boolean;
  KeepEditionCount : Integer;
  FileCount : Integer;
  ItemSize, CompletedSize : Int64; // 空间信息
  BackupItemReadHandle : TBackupItemReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( BackupItemNode, Xml_BackupPath );
  IsFile := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsFile );

  IsDisable := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsDisable );
  IsBackupNow := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsBackupNow );

  IsAutoSync := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsAutoSync );
  SyncTimeType := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeType );
  SyncTimeValue := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_SyncTimeValue );
  LastSyncTime := MyXmlUtil.GetChildFloatValue( BackupItemNode, Xml_LastSyncTime );

  IsKeepDeleted := MyXmlUtil.GetChildBoolValue( BackupItemNode, Xml_IsKeepDeleted );
  KeepEditionCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_KeepEditionCount );

  FileCount := MyXmlUtil.GetChildIntValue( BackupItemNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_ItemSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_CompletedSize );

  BackupItemReadHandle := TBackupItemReadHandle.Create( DesItemID );
  BackupItemReadHandle.SetBackupPath( BackupPath );
  BackupItemReadHandle.SetIsFile( IsFile );
  BackupItemReadHandle.SetBackupStatus( IsDisable, IsBackupNow );
  BackupItemReadHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemReadHandle.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemReadHandle.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemReadHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemReadHandle.Update;
  BackupItemReadHandle.Free;
end;

{ TDesItemChangeXml }

procedure TDesItemChangeXml.Update;
begin
  MyBackupNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyBackupInfo );
  DesItemNodeList := MyXmlUtil.AddChild( MyBackupNode, Xml_DesItemList );
end;


{ TBackupItemSetSpaceInfoXml }

procedure TBackupItemSetSpaceInfoXml.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoXml.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  MyXmlUtil.AddChild( BackupItemNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( BackupItemNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSize );
end;

{ TBackupItemSetAddCompletedSpaceXml }

procedure TBackupItemSetAddCompletedSpaceXml.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceXml.Update;
var
  CompletedSpace : Int64;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  CompletedSpace := MyXmlUtil.GetChildInt64Value( BackupItemNode, Xml_CompletedSize );
  CompletedSpace := CompletedSpace + AddCompletedSpace;
  MyXmlUtil.AddChild( BackupItemNode, Xml_CompletedSize, CompletedSpace );
end;

{ TDesItemAddLocalXml }

procedure TDesItemAddLocalXml.Update;
begin
  inherited;

    // 已存在
  if FindDesNode then
    Exit;

  DesNode := MyXmlUtil.AddListChild( DesItemNodeList );
  MyXmlUtil.AddChild( DesNode, Xml_DesItemID, DesItemID );
  MyXmlUtil.AddChild( DesNode, Xml_DesItemType, DesItemType_Local );
end;

{ TDesItemAddNetworkXml }

procedure TDesItemAddNetworkXml.Update;
begin
  inherited;

    // 已存在
  if FindDesNode then
    Exit;

  DesNode := MyXmlUtil.AddListChild( DesItemNodeList );
  MyXmlUtil.AddChild( DesNode, Xml_DesItemID, DesItemID );
  MyXmlUtil.AddChild( DesNode, Xml_DesItemType, DesItemType_Network );
end;

end.
