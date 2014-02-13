unit ULocalBackupXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' 源路径 修改 ' }

    // 修改 父类
  TLocalBackupSourceChangeXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    SourcePathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSourcePathNode : Boolean;
  end;

    // 添加
  TLocalBackupSourceAddXml = class( TLocalBackupSourceChangeXml )
  private
    PathType : string;
    IsBackupNow, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  private
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;override;
  end;

    // 修改 空间信息
  TLocalBackupSourceSpaceXml = class( TLocalBackupSourceChangeXml )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' 设置 状态信息 ' }

      // 是否 禁止备份
  TLocalBackupSourceIsDisableXml = class( TLocalBackupSourceChangeXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // 是否 Backup Now 备份
  TLocalBackupSourceIsBackupNowXml = class( TLocalBackupSourceChangeXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 同步时间 信息 ' }

    // 设置 上一次 同步时间
  TLocalBackupSourceSetLastSyncTimeXml = class( TLocalBackupSourceChangeXml )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // 设置 上一次 同步时间
  TLocalBackupSourceSetSyncMinsXml = class( TLocalBackupSourceChangeXml )
  private
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 设置保存删除文件信息 ' }

    // 设置信息
  TLocalBackupSorceSetDeleteXml = class( TLocalBackupSourceChangeXml )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

    // 删除
  TLocalBackupSourceRemoveXml = class( TLocalBackupSourceChangeXml )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 源路径 过滤器 修改 ' }

  {$Region ' 包含 过滤器 ' }

    // 父类
  TLocalBackupSourceIncludeFilterChangeXml = class( TLocalBackupSourceChangeXml )
  protected
    IncludeFilterListNode : IXMLNode;
  protected
    function FindIncludeFilterListNode : Boolean;
  end;

    // 清空
  TLocalBackupSourceIncludeFilterClearXml = class( TLocalBackupSourceIncludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // 添加
  TLocalBackupSourceIncludeFilterAddXml = class( TLocalBackupSourceIncludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 排除 过滤器 ' }

    // 父类
  TLocalBackupSourceExcludeFilterChangeXml = class( TLocalBackupSourceChangeXml )
  protected
    ExcludeFilterListNode : IXMLNode;
  protected
    function FindExcludeFilterListNode : Boolean;
  end;

    // 清空
  TLocalBackupSourceExcludeFilterClearXml = class( TLocalBackupSourceExcludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // 添加
  TLocalBackupSourceExcludeFilterAddXml = class( TLocalBackupSourceExcludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}


{$EndRegion}

{$Region ' 源路径目标 修改 ' }

    // 父类
  TLocalBackupSourceChangeDesXml = class( TLocalBackupSourceChangeXml )
  public
    DesPathListNode : IXMLNode;
  public
    function FindDesPathListNode : Boolean;
  end;

    // 修改
  TLocalBackupSourceWriteDesXml = class( TLocalBackupSourceChangeDesXml )
  public
    DesPath : string;
  protected
    DesPathNode : IXMLNode;
  public
    procedure SetDesPath( _DesPath : string );
  protected
    function FindDesPathNode : Boolean;
  end;

    // 添加
  TLocalBackupSourceAddDesXml = class( TLocalBackupSourceWriteDesXml )
  public
    SourceSize, CompltedSize : Int64;
    DeletedSpace : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成空间信息
  TLocalBackupSourceAddDesCompletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    AddCompltedSize : Int64;
  public
    procedure SetAddCompltedSize( _AddCompltedSize : Int64 );
    procedure Update;override;
  end;

    // 修改 空间信息
  TLocalBackupSourceSetDesSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    SourceSize, CompltedSize : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已删除 空间信息
  TLocalBackupSorceAddDeletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    AddDeletedSpace : Int64;
  public
    procedure SetAddDeletedSpace( _AddDeletedSpace : Int64 );
    procedure Update;override;
  end;

    // 设置 已删除 空间信息
  TLocalBackupSorceSetDeletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    DeletedSpace : Int64;
  public
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;override;
  end;


    // 删除
  TLocalBackupSourceRemoveDesXml = class( TLocalBackupSourceWriteDesXml )
  public
    procedure Update;override;
  end;

    // 版本兼容
  TLocalBackupSourceIsAddDesToSourceXml = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 源路径 读取 ' }

    // 读取 源路径目标
  TLocalBackupSourceReadDesXmlHandle = class
  public
    DesPathNode : IXMLNode;
    SourcePath, PathType : string;
    IsKeepDeleted : Boolean;
  public
    constructor Create( _DesPathNode : IXMLNode );
    procedure SetSourcePath( _SourcePath, _PathType : string );
    procedure SetIsKeepDeleted( _IsKeepDeleted : Boolean );
    procedure Update;
  end;

    // 读 备份路径 过滤 Xml
  TLocalBackupSourceFilterXmlReadHandle = class
  public
    FilterNode : IXMLNode;
    FullPath : string;
  protected
    FilterType, FilterStr : string;
  public
    constructor Create( _FilterNode : IXMLNode );
    procedure SetFullPath( _FullPath : string );
    procedure Update;
  protected
    procedure AddFilterHandle;virtual;abstract;
  end;

    // 读 备份路径 包含过滤 Xml
  TLocalBackupSourceIncludeFilterXmlReadHandle = class( TLocalBackupSourceFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // 读 备份路径 排除过滤 Xml
  TLocalBackupSourceExcludeFilterXmlReadHandle = class( TLocalBackupSourceFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // 读取 源路径
  TLocalBackupSorceReadXmlHandle = class
  public
    SourcePathNode : IXMLNode;
    FullPath, PathType : string;
  public
    IsKeepDeleted : Boolean;
  private
    IsAddEditionDes : Boolean;
  public
    constructor Create( _SourcePathNode : IXMLNode );
    procedure SetIsAddEditionDes( _IsAddEditionDes : Boolean );
    procedure Update;
  private
    procedure ReadSourceFilter;
    procedure ReadDesPathList;
    procedure AddEditionDesPathList;
  end;

    // 读取 信息
  TLocalBackupSourceXmlRead = class
  public
    procedure Update;
  end;


{$EndRegion}


{$Region ' 目标路径 修改 ' }

       // 修改 父类
  TLocalBackupDesChangeXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    BackupDesNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindBackupDesNode : Boolean;
  end;

    // 添加 目标路径
  TLocalBackupDesAddXml = class( TLocalBackupDesChangeXml )
  public
    procedure Update;override;
  end;

    // 删除 目标路径
  TLocalBackupDesRemoveXml = class( TLocalBackupDesChangeXml )
  public
    procedure Update;override;
  end;

    // 禁止 添加 默认路径
  TLocalBackupDesDisableDefaultPathXml = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 目标路径 读取 ' }

    //目标路径 读取
  TLocalBackupDesXmlReadHandle = class
  public
    DesPathNode : IXMLNode;
  public
    constructor Create( _DesPathNode : IXMLNode );
    procedure Update;
  end;

    // 读取
  TLocalBackupDesXmlRead = class
  public
    procedure Update;
  private
    procedure AddMyDesPathList;
    procedure AddDefaultDesPath;
  end;


{$EndRegion}

const  // Xml 信息

  Xml_IsAddSourceToDes = 'iastd';
  Xml_IsAddDesToSource = 'iadts';

    // 源信息
  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';
  Xml_IsBackupNow = 'ib';
  Xml_IsDisable = 'id';
  Xml_IsAuctoSync = 'ias';
  Xml_LastSyncTime = 'lst';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_IsKeepDeleted = 'ikd';
  Xml_KeepEdtionCount = 'kec';
  Xml_FileSize = 'fs';
  Xml_FileCount = 'fc';
  Xml_DesPathList = 'dpl';
  Xml_IncludeFilterList = 'ifl';
  Xml_ExcludeFilterList = 'efl';

    // 过滤器 信息
  Xml_FilterType = 'ft';
  XMl_FilterStr = 'fs';

    // 源路径目标
//  Xml_FullPath = 'fp';
  Xml_SourceSize = 'ss';
  Xml_CompltedSize = 'cs';
  Xml_DeletedSpace = 'ds';

    // 目标信息
  Xml_IsAddDefault = 'iad';

implementation

uses ULocalBackupInfo, ULocalBackupControl;

{ TLocalBackupSourceChangeXml }

constructor TLocalBackupSourceChangeXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLocalBackupSourceChangeXml.FindSourcePathNode: Boolean;
begin
  SourcePathNode := MyXmlUtil.FindListChild( LocalBackupSourceListXml, FullPath );
  Result := SourcePathNode <> nil;
end;

{ TLocalBackupSourceAddXml }

procedure TLocalBackupSourceAddXml.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceAddXml.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLocalBackupSourceAddXml.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceAddXml.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceAddXml.Update;
begin
    // 已存在
  if FindSourcePathNode then
    Exit;

    // 添加
  SourcePathNode := MyXmlUtil.AddListChild( LocalBackupSourceListXml, FullPath );

  MyXmlUtil.AddChild( SourcePathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( SourcePathNode, Xml_PathType, PathType );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsBackupNow, IsBackupNow );
  MyXmlUtil.AddChild( SourcePathNode, Xml_IsDisable, IsDisable );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsAuctoSync, IsAutoSync );
  MyXmlUtil.AddChild( SourcePathNode, Xml_LastSyncTime, LastSyncTime );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeValue, SyncTimeValue );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( SourcePathNode, Xml_KeepEdtionCount, KeepEditionCount );

  MyXmlUtil.AddChild( SourcePathNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( SourcePathNode, Xml_FileCount, FileCount );
end;

{ TLocalBackupSourceRemoveXml }

procedure TLocalBackupSourceRemoveXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.DeleteListChild( LocalBackupSourceListXml, FullPath );
end;

{ TLocalBackupSourceSpaceXml }

procedure TLocalBackupSourceSpaceXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLocalBackupSourceSpaceXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_FileCount, IntToStr( FileCount ) );
end;

{ TLocalBackupSourceXmlRead }

procedure TLocalBackupSourceXmlRead.Update;
var
  IsAddDesToSource : Boolean;
  i : Integer;
  Node : IXMLNode;
  LocalBackupSorceReadXmlHandle : TLocalBackupSorceReadXmlHandle;
  LocalBackupSourceIsAddDesToSourceXml : TLocalBackupSourceIsAddDesToSourceXml;
begin
  IsAddDesToSource := StrToBoolDef( MyXmlUtil.GetChildValue( MyLocalBackupSourceXml, Xml_IsAddDesToSource ), true);

    // 读取 源路径
  for i := 0 to LocalBackupSourceListXml.ChildNodes.Count - 1 do
  begin
    Node := LocalBackupSourceListXml.ChildNodes[i];

    LocalBackupSorceReadXmlHandle := TLocalBackupSorceReadXmlHandle.Create( Node );
    LocalBackupSorceReadXmlHandle.SetIsAddEditionDes( IsAddDesToSource );
    LocalBackupSorceReadXmlHandle.Update;
    LocalBackupSorceReadXmlHandle.Free;
  end;

    // 已经版本兼容，跳过
  if not IsAddDesToSource then
    Exit;

    // 版本兼容
  LocalBackupSourceIsAddDesToSourceXml := TLocalBackupSourceIsAddDesToSourceXml.Create;
  MyXmlChange.AddChange( LocalBackupSourceIsAddDesToSourceXml );
end;

{ TMyDesPathChangeXml }

constructor TLocalBackupDesChangeXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TMyDesPathAddXml }

procedure TLocalBackupDesAddXml.Update;
begin
    // 已存在
  if FindBackupDesNode then
    Exit;

  BackupDesNode := MyXmlUtil.AddListChild( DestinationListXml, FullPath );
  MyXmlUtil.AddChild( BackupDesNode, Xml_FullPath, FullPath );
end;

{ TMyDesPathRemoveXml }

procedure TLocalBackupDesRemoveXml.Update;
begin
    // 不存在
  if not FindBackupDesNode then
    Exit;

  MyXmlUtil.DeleteListChild( DestinationListXml, FullPath );
end;

{ TMyDestinationXmlRead }

procedure TLocalBackupDesXmlRead.AddDefaultDesPath;
var
  IsAddDefault : Boolean;
  DesPath : string;
  BackupDestinationReadHandle : TLocalBackupDesReadHandle;
  MyDesDisableDefaultPathXml : TLocalBackupDesDisableDefaultPathXml;
begin
  IsAddDefault := StrToBoolDef( MyXmlUtil.GetChildValue( MyDestinationXml, Xml_IsAddDefault ), True );
  if not IsAddDefault then
    Exit;

  DesPath := MyHardDisk.getBiggestHardDIsk + DefaultPath_Des;
  ForceDirectories( DesPath );

    // 添加 默认的 本地 备份目标路径
  BackupDestinationReadHandle := TLocalBackupDesReadHandle.Create( DesPath );
  BackupDestinationReadHandle.Update;
  BackupDestinationReadHandle.Free;

    // 禁止下一次添加
  MyDesDisableDefaultPathXml := TLocalBackupDesDisableDefaultPathXml.Create;
  MyXmlChange.AddChange( MyDesDisableDefaultPathXml );
end;

procedure TLocalBackupDesXmlRead.AddMyDesPathList;
var
  i : Integer;
  DesNode : IXMLNode;
  LocalBackupDesXmlReadHandle : TLocalBackupDesXmlReadHandle;
begin
  for i := 0 to DestinationListXml.ChildNodes.Count - 1 do
  begin
    DesNode := DestinationListXml.ChildNodes[i];

    LocalBackupDesXmlReadHandle := TLocalBackupDesXmlReadHandle.Create( DesNode );
    LocalBackupDesXmlReadHandle.Update;
    LocalBackupDesXmlReadHandle.Free;
  end;
end;

procedure TLocalBackupDesXmlRead.Update;
begin
    // 添加默认路径
  if DestinationListXml.ChildNodes.Count = 0 then
    AddDefaultDesPath
  else       // 添加 本地备份目标路径
    AddMyDesPathList;
end;

function TLocalBackupDesChangeXml.FindBackupDesNode: Boolean;
begin
  BackupDesNode := MyXmlUtil.FindListChild( DestinationListXml, FullPath );
  Result := BackupDesNode <> nil;
end;

{ TMyDesDisableDefaultPathXml }

procedure TLocalBackupDesDisableDefaultPathXml.Update;
begin
  MyXmlUtil.AddChild( MyDestinationXml, Xml_IsAddDefault, BoolToStr( False ) );
end;

{ TLocalBackupSourceChangeDesXml }

function TLocalBackupSourceChangeDesXml.FindDesPathListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    DesPathListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_DesPathList );
end;

{ TLocalBackupSourceWriteDesXml }

function TLocalBackupSourceWriteDesXml.FindDesPathNode: Boolean;
begin
  Result := False;
  DesPathListNode := nil;
  if not FindDesPathListNode then
    Exit;

  DesPathNode := MyXmlUtil.FindListChild( DesPathListNode, DesPath );
  Result := DesPathNode <> nil;
end;

procedure TLocalBackupSourceWriteDesXml.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TLocalBackupSourceAddDesXml }

procedure TLocalBackupSourceAddDesXml.SetDeletedSpace(_DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSourceAddDesXml.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceAddDesXml.Update;
begin
  inherited;

    // 已存在
  if FindDesPathNode then
    Exit;

    // 源不存在
  if DesPathListNode = nil then
    Exit;

    // 添加
  DesPathNode := MyXmlUtil.AddListChild( DesPathListNode, DesPath );
  MyXmlUtil.AddChild( DesPathNode, Xml_FullPath, DesPath );
  MyXmlUtil.AddChild( DesPathNode, Xml_SourceSize, SourceSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, CompltedSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

{ TLocalBackupSourceRemoveDesXml }

procedure TLocalBackupSourceRemoveDesXml.Update;
begin
  inherited;

    // 不存在
  if not FindDesPathNode then
    Exit;

    // 删除
  MyXmlUtil.DeleteListChild( DesPathListNode, DesPath );
end;

{ TLocalBackupSourceSetDesSpaceXml }

procedure TLocalBackupSourceSetDesSpaceXml.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceSetDesSpaceXml.Update;
begin
  inherited;

    // 不存在
  if not FindDesPathNode then
    Exit;

    // 修改 空间信息
  MyXmlUtil.AddChild( DesPathNode, Xml_SourceSize, SourceSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, CompltedSize );
end;

{ TLocalBackupSourceAddDesCompletedSpaceXml }

procedure TLocalBackupSourceAddDesCompletedSpaceXml.SetAddCompltedSize(
  _AddCompltedSize: Int64);
begin
  AddCompltedSize := _AddCompltedSize;
end;

procedure TLocalBackupSourceAddDesCompletedSpaceXml.Update;
var
  NewCompltedSpace : Int64;
begin
  inherited;

    // 不存在
  if not FindDesPathNode then
    Exit;

  NewCompltedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_CompltedSize );
  NewCompltedSpace := NewCompltedSpace + AddCompltedSize;

    // 修改 空间信息
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, NewCompltedSpace );
end;

{ TLocalBackupSorceReadXmlHandle }

procedure TLocalBackupSorceReadXmlHandle.AddEditionDesPathList;
var
  i : Integer;
  DesNode : IXMLNode;
  DesPath : string;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  for i := 0 to DestinationListXml.ChildNodes.Count - 1 do
  begin
    DesNode := DestinationListXml.ChildNodes[i];
    DesPath := MyXmlUtil.GetChildValue( DesNode, Xml_FullPath );

      // 显示信息
    LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( FullPath );
    LocalBackupSourceAddDesHandle.SetDesPath( DesPath );
    LocalBackupSourceAddDesHandle.SetSourcePathType( PathType );
    LocalBackupSourceAddDesHandle.SetDeletedInfo( False, 0 );
    LocalBackupSourceAddDesHandle.SetSpaceInfo( 0, 0 );
    LocalBackupSourceAddDesHandle.Update;
    LocalBackupSourceAddDesHandle.Free;
  end;
end;

constructor TLocalBackupSorceReadXmlHandle.Create(_SourcePathNode: IXMLNode);
begin
  SourcePathNode := _SourcePathNode;
end;

procedure TLocalBackupSorceReadXmlHandle.ReadDesPathList;
var
  DesPathListNode : IXMLNode;
  i : Integer;
  DesPathNode : IXMLNode;
  LocalBackupSourceReadDesXmlHandle : TLocalBackupSourceReadDesXmlHandle;
begin
  DesPathListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_DesPathList );
  for i := 0 to DesPathListNode.ChildNodes.Count - 1 do
  begin
    DesPathNode := DesPathListNode.ChildNodes[i];

    LocalBackupSourceReadDesXmlHandle := TLocalBackupSourceReadDesXmlHandle.Create( DesPathNode );
    LocalBackupSourceReadDesXmlHandle.SetSourcePath( FullPath, PathType );
    LocalBackupSourceReadDesXmlHandle.SetIsKeepDeleted( IsKeepDeleted );
    LocalBackupSourceReadDesXmlHandle.Update;
    LocalBackupSourceReadDesXmlHandle.Free;
  end;
end;

procedure TLocalBackupSorceReadXmlHandle.ReadSourceFilter;
var
  FilterListNode : IXMLNode;
  i : Integer;
  FilterNode : IXMLNode;
  LocalBackupSourceFilterXmlReadHandle : TLocalBackupSourceFilterXmlReadHandle;
begin
  FilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_IncludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    LocalBackupSourceFilterXmlReadHandle := TLocalBackupSourceIncludeFilterXmlReadHandle.Create( FilterNode );
    LocalBackupSourceFilterXmlReadHandle.SetFullPath( FullPath );
    LocalBackupSourceFilterXmlReadHandle.Update;
    LocalBackupSourceFilterXmlReadHandle.Free;
  end;

  FilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_ExcludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    LocalBackupSourceFilterXmlReadHandle := TLocalBackupSourceExcludeFilterXmlReadHandle.Create( FilterNode );
    LocalBackupSourceFilterXmlReadHandle.SetFullPath( FullPath );
    LocalBackupSourceFilterXmlReadHandle.Update;
    LocalBackupSourceFilterXmlReadHandle.Free;
  end;
end;

procedure TLocalBackupSorceReadXmlHandle.SetIsAddEditionDes(
  _IsAddEditionDes: Boolean);
begin
  IsAddEditionDes := _IsAddEditionDes;
end;

procedure TLocalBackupSorceReadXmlHandle.Update;
var
  IsBackupNow, IsDisable : Boolean;
  IsAutoSync : Boolean;
  SyncTimeType, SyncTimeValue : Integer;
  LastSyncTime : TDateTime;
  KeepEditionCount : Integer;
  FileSize : Int64;
  FileCount : Integer;
  LocalBackupSourceReadHandle : TLocalBackupSourceReadHandle;
begin
    // 提取 节点信息
  FullPath := MyXmlUtil.GetChildValue( SourcePathNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( SourcePathNode, Xml_PathType );
  IsBackupNow := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsBackupNow ), True );
  IsDisable := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsDisable ), False );
  IsAutoSync := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsAuctoSync ), True );
  SyncTimeType := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_SyncTimeType ), TimeType_Minutes );
  SyncTimeValue := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_SyncTimeValue ), 60 );
  LastSyncTime := StrToFloatDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_LastSyncTime ), 0 );
  IsKeepDeleted := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsKeepDeleted ), False );
  KeepEditionCount := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_KeepEdtionCount ), 3 );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( SourcePathNode, Xml_FileSize ), 0 );
  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_FileCount ), 0 );

    // 读取 路径信息
  LocalBackupSourceReadHandle := TLocalBackupSourceReadHandle.Create( FullPath );
  LocalBackupSourceReadHandle.SetPathType( PathType );
  LocalBackupSourceReadHandle.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceReadHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupSourceReadHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceReadHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceReadHandle.SetSpaceInfo( FileCount, FileSize );
  LocalBackupSourceReadHandle.Update;
  LocalBackupSourceReadHandle.Free;

    // 读取 过滤器信息
  ReadSourceFilter;

    // 读取 目标路径
  if IsAddEditionDes then
    AddEditionDesPathList  // 版本兼容
  else
    ReadDesPathList;
end;


{ TLocalBackupSourceReadDesXmlHandle }

constructor TLocalBackupSourceReadDesXmlHandle.Create(_DesPathNode: IXMLNode);
begin
  DesPathNode := _DesPathNode;
end;

procedure TLocalBackupSourceReadDesXmlHandle.SetIsKeepDeleted(
  _IsKeepDeleted: Boolean);
begin
  IsKeepDeleted := _IsKeepDeleted;
end;

procedure TLocalBackupSourceReadDesXmlHandle.SetSourcePath(_SourcePath, _PathType: string);
begin
  SourcePath := _SourcePath;
  PathType := _PathType;
end;

procedure TLocalBackupSourceReadDesXmlHandle.Update;
var
  DesPath : string;
  SourceSize, CompltedSize : Int64;
  DeletedSpace : Int64;
  LocalBackupSourceReadDesHandle : TLocalBackupSourceReadDesHandle;
begin
    // 提取信息
  DesPath := MyXmlUtil.GetChildValue( DesPathNode, Xml_FullPath );
  SourceSize := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_SourceSize );
  CompltedSize := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_CompltedSize );
  DeletedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_DeletedSpace );


    // 显示信息
  LocalBackupSourceReadDesHandle := TLocalBackupSourceReadDesHandle.Create( SourcePath );
  LocalBackupSourceReadDesHandle.SetDesPath( DesPath );
  LocalBackupSourceReadDesHandle.SetSourcePathType( PathType );
  LocalBackupSourceReadDesHandle.SetSpaceInfo( SourceSize, CompltedSize );
  LocalBackupSourceReadDesHandle.SetDeletedInfo( IsKeepDeleted, DeletedSpace );
  LocalBackupSourceReadDesHandle.Update;
  LocalBackupSourceReadDesHandle.Free;
end;

{ TLocalBackupDesXmlReadHandle }

constructor TLocalBackupDesXmlReadHandle.Create(_DesPathNode: IXMLNode);
begin
  DesPathNode := _DesPathNode;
end;

procedure TLocalBackupDesXmlReadHandle.Update;
var
  DesPath : string;
  BackupDestinationReadHandle : TLocalBackupDesReadHandle;
begin
    // 提取信息
  DesPath := MyXmlUtil.GetChildValue( DesPathNode, Xml_FullPath );

    // 本地 备份目标路径
  BackupDestinationReadHandle := TLocalBackupDesReadHandle.Create( DesPath );
  BackupDestinationReadHandle.Update;
  BackupDestinationReadHandle.Free;
end;

{ TLocalBackupSourceIncludeFilterChangeXml }

function TLocalBackupSourceIncludeFilterChangeXml.FindIncludeFilterListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    IncludeFilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_IncludeFilterList );
end;

{ TLocalBackupSourceIncludeFilterClearXml }

procedure TLocalBackupSourceIncludeFilterClearXml.Update;
begin
  inherited;

  if not FindIncludeFilterListNode then
    Exit;

  IncludeFilterListNode.ChildNodes.Clear;
end;

{ TLocalBackupSourceIncludeFilterAddXml }

procedure TLocalBackupSourceIncludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceIncludeFilterAddXml.Update;
var
  IncludeFilterNode : IXMLNode;
begin
  inherited;

    // 不存在
  if not FindIncludeFilterListNode then
    Exit;

  IncludeFilterNode := MyXmlUtil.AddListChild( IncludeFilterListNode );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TLocalBackupSourceExcludeFilterChangeXml }

function TLocalBackupSourceExcludeFilterChangeXml.FindExcludeFilterListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    ExcludeFilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_ExcludeFilterList );
end;

{ TLocalBackupSourceExcludeFilterClearXml }

procedure TLocalBackupSourceExcludeFilterClearXml.Update;
begin
  inherited;

  if not FindExcludeFilterListNode then
    Exit;

  ExcludeFilterListNode.ChildNodes.Clear;
end;

{ TLocalBackupSourceExcludeFilterAddXml }

procedure TLocalBackupSourceExcludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceExcludeFilterAddXml.Update;
var
  ExcludeFilterNode : IXMLNode;
begin
  inherited;

    // 不存在
  if not FindExcludeFilterListNode then
    Exit;

  ExcludeFilterNode := MyXmlUtil.AddListChild( ExcludeFilterListNode );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TLocalBackupSourceFilterXmlReadHandle }

constructor TLocalBackupSourceFilterXmlReadHandle.Create(_FilterNode: IXMLNode);
begin
  FilterNode := _FilterNode;
end;

procedure TLocalBackupSourceFilterXmlReadHandle.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TLocalBackupSourceFilterXmlReadHandle.Update;
begin
    // 提取 过滤信息
  FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
  FilterStr := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterStr );

    // 添加 过滤器
  AddFilterHandle;
end;


{ TLocalBackupSourceIncludeFilterXmlReadHandle }

procedure TLocalBackupSourceIncludeFilterXmlReadHandle.AddFilterHandle;
var
  LocalBackupSourceIncludeFilterReadHandle : TLocalBackupSourceIncludeFilterReadHandle;
begin
  LocalBackupSourceIncludeFilterReadHandle := TLocalBackupSourceIncludeFilterReadHandle.Create( FullPath );
  LocalBackupSourceIncludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceIncludeFilterReadHandle.Update;
  LocalBackupSourceIncludeFilterReadHandle.Free;
end;

{ TLocalBackupSourceExcludeFilterXmlReadHandle }

procedure TLocalBackupSourceExcludeFilterXmlReadHandle.AddFilterHandle;
var
  LocalBackupSourceExcludeFilterReadHandle : TLocalBackupSourceExcludeFilterReadHandle;
begin
  LocalBackupSourceExcludeFilterReadHandle := TLocalBackupSourceExcludeFilterReadHandle.Create( FullPath );
  LocalBackupSourceExcludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceExcludeFilterReadHandle.Update;
  LocalBackupSourceExcludeFilterReadHandle.Free;
end;

{ TLocalBackupSourceIsDisableXml }

procedure TLocalBackupSourceIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceIsDisableXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsDisable, BoolToStr( IsDisable ) );
end;

{ TLocalBackupSourceIsBackupNowXml }

procedure TLocalBackupSourceIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupSourceIsBackupNowXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsBackupNow, BoolToStr( IsBackupNow ) );
end;

{ TLocalBackupSourceSetLastSyncTimeXml }

procedure TLocalBackupSourceSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceSetLastSyncTimeXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_LastSyncTime, FloatToStr( LastSyncTime ) );
end;

{ TLocalBackupSourceSetSyncMinsXml }

procedure TLocalBackupSourceSetSyncMinsXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupSourceSetSyncMinsXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceSetSyncMinsXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsAuctoSync, BoolToStr( IsAutoSync ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeType, IntToStr( SyncTimeType ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeValue, IntToStr( SyncTimeValue ) );
end;

{ TLocalBackupSourceIsAddDesToSourceXml }

procedure TLocalBackupSourceIsAddDesToSourceXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( MyLocalBackupSourceXml, Xml_IsAddDesToSource, False );
end;

{ TLocalBackupSorceSetDeleteXml }

procedure TLocalBackupSorceSetDeleteXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSorceSetDeleteXml.Update;
begin
    // 不存在
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( SourcePathNode, Xml_KeepEdtionCount, KeepEditionCount );
end;

{ TLocalBackupSorceAddDeletedSpaceXml }

procedure TLocalBackupSorceAddDeletedSpaceXml.SetAddDeletedSpace(
  _AddDeletedSpace: Int64);
begin
  AddDeletedSpace := _AddDeletedSpace;
end;

procedure TLocalBackupSorceAddDeletedSpaceXml.Update;
var
  DeletedSpace : Int64;
begin
    // 不存在
  if not FindDesPathNode then
    Exit;

  DeletedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_DeletedSpace );
  DeletedSpace := DeletedSpace + AddDeletedSpace;
  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

{ TLocalBackupSorceSetDeletedSpaceXml }

procedure TLocalBackupSorceSetDeletedSpaceXml.SetDeletedSpace(
  _DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSorceSetDeletedSpaceXml.Update;
begin
    // 不存在
  if not FindDesPathNode then
    Exit;

  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

end.
