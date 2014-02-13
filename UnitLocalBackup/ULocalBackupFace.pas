unit ULocalBackupFace;

interface

uses UChangeInfo, virtualtrees, Generics.Collections, UModelUtil, Classes, SyncObjs, ComCtrls,
     UIconUtil, UMyUtil, SysUtils, DateUtils;

type

{$Region ' 源路径 选择窗口 ' }

      // 写信息 父类
  TVstSelectLocalBackupSourceWriteInfo = class( TFaceChangeInfo )
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 添加 信息
  TVstSelectLocalBackupSourceAddInfo = class( TVstSelectLocalBackupSourceWriteInfo )
  public
    procedure Update;override;
  end;

    // 删除 信息
  TVstSelectLocalBackupSourceRemoveInfo = class( TVstSelectLocalBackupSourceWriteInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$Region ' 源路径 属性窗口 ' }

  {$Region ' 源路径 ' }

    // 数据结构
  TLvLocalBackupSourceProData = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 父类
  TLvLocalBackupSourceProChange = class( TFaceChangeInfo )
  public
    LvLocalBackupSourcePro : TListView;
  public
    procedure Update;override;
  end;

    // 修改
  TLvLocalBackupSourceProWrite = class( TLvLocalBackupSourceProChange )
  public
    FullPath : string;
  protected
    PathItem : TListItem;
    PathIndex : Integer;
  public
    constructor Create( _FullPath : string );
  protected
    function FindPathItem : Boolean;
  end;

    // 添加
  TLvLocalBackupSourceProAdd = class( TLvLocalBackupSourceProWrite )
  public
    procedure Update;override;
  end;

    // 删除
  TLvLocalBackupSourceProRemove = class( TLvLocalBackupSourceProWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 目标路径 ' }

      // 数据结构
  TLvLocalBackupDesProData = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 父类
  TLvLocalBackupDesProChange = class( TFaceChangeInfo )
  public
    LvLocalBackupDesPro : TListView;
  public
    procedure Update;override;
  end;

    // 修改
  TLvLocalBackupDesProWrite = class( TLvLocalBackupDesProChange )
  public
    FullPath : string;
  protected
    PathItem : TListItem;
    PathIndex : Integer;
  public
    constructor Create( _FullPath : string );
  protected
    function FindPathItem : Boolean;
  end;

    // 添加
  TLvLocalBackupDesProAdd = class( TLvLocalBackupDesProWrite )
  public
    procedure Update;override;
  end;

    // 删除
  TLvLocalBackupDesProRemove = class( TLvLocalBackupDesProWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 源路径 界面 ' }

    // 数据结构
  TVstLocalBackupSourceData = record
  public
    FullPath, PathType : WideString;
    IsExist, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    Status, ShowStatus : WideString;
  public
    PathIcon : Integer;
  end;
  PVstLocalBackupSourceData = ^TVstLocalBackupSourceData;

    // 辅助类
  VstLocalBackupSourceUtil = class
  public
    class function IsInclude( FullPath : string ): Boolean;
    class procedure RemoveChild( FullPath : string );
  public
    class function getNextSync( Node : PVirtualNode ): string;
  public
    class function getSelectPathList : TStringList;
    class function getChildPathList( RootPath : string ): TStringList;
  end;

    // 父类
  TLvLocalBackupSourceChange = class( TFaceChangeInfo )
  protected
    VstLocalBackupSource : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure ResetStatusColVisible;
  end;

    // 刷新 显示的 剩余同步时间
  TLVLocalBackupSourceRefreshNextSync = class( TLvLocalBackupSourceChange )
  public
    procedure Update;override;
  end;

    // 修改
  TLvLocalBackupSourceWrite = class( TLvLocalBackupSourceChange )
  protected
    FullPath : string;
  protected
    SourceNode : PVirtualNode;
    SourceData : PVstLocalBackupSourceData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSourceNode : Boolean;
    procedure RefreshNode;
  protected
    procedure RefresNextSyncTime;
  end;

    // 添加
  TLvLocalBackupSourceAdd = class( TLvLocalBackupSourceWrite )
  private
    PathType : string;
    IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime, _NextSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;override;
  end;

    // 删除
  TLvLocalBackupSourceRemove = class( TLvLocalBackupSourceWrite )
  public
    procedure Update;override;
  end;

    // 修改 空间信息
  TLvLocalBackupSourceSpace = class( TLvLocalBackupSourceWrite )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' 修改 同步时间信息 ' }

    // 设置 上一次 同步时间
  TVstLocalBackupSourceSetLastSyncTime = class( TLvLocalBackupSourceWrite )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // 设置 同步周期
  TVstLocalBackupSourceSetSyncTime = class( TLvLocalBackupSourceWrite )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

    // 刷新 下一次 同步时间
  TVstLocalBackupSourceRefreshNextSyncTime = class( TLvLocalBackupSourceWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 状态 ' }

    // 修改 状态
  TLvLocalBackupStatus = class( TLvLocalBackupSourceWrite )
  private
    Status : string;
    ShowStatus : string;
  public
    procedure SetStatus( _Status : string );
    procedure SetShowStatus( _ShowStatus : string );
    procedure Update;override;
  end;

      // 是否 禁止备份
  TVstLocalBackupSourceIsDisable = class( TLvLocalBackupSourceWrite )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // 修改 路径是否存在
  TLvLocalBackupExist = class( TLvLocalBackupSourceWrite )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

    // 扫描完成
  TLocalBackupFaceScanCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 目标路径 界面 ' }

  {$Region ' 数据结构 辅助操作 ' }

    // 数据结构
  TVstLocalBackupDesData = record
  public
    FullPath : WideString;
    FileSize : Int64;
    Status : WideString;
  public
    IsExist, IsModify : Boolean;
    IsLackSpace : Boolean;
  public
    PathType : WideString;
    SourceFileSize : Int64;
  public
    IsDeleted : Boolean;
  public
    PathIcon : Integer;
  end;
  PVstLocalBackupDesData = ^TVstLocalBackupDesData;

  TVstSelectPathInfo = class
  public
    RootPath, SelectPath : string;
    IsDeleted : Boolean;
  public
    constructor Create( _RootPath, _SelectPath : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
  end;
  TVstSelectPathList = class( TObjectList<TVstSelectPathInfo> )end;
  VstLocalBackupDesUtil = class
  public
    class function getRootNodeStatus( Node : PVirtualNode ): string;
    class function getRootNodeIcon( Node : PVirtualNode ): Integer;
  public
    class function getNodeStatusInt( Node : PVirtualNode ): Integer;
  public
    class function getChildNodeStatus( Node : PVirtualNode ): string;
    class function getChildNodeIcon( Node : PVirtualNode ): Integer;
  public
    class function IsExistChild( FullPath : string ): Boolean;
    class function IsExist( FullPath : string ): Boolean;
  public
   class function getDesPathList : TStringList;
   class function getSelectPathList : TVstSelectPathList;
   class function getChildPathList( RootPath : string ): TStringList;
   class function getIsRootNode( FullPath : string ): Boolean;
  public
    class function getDesSourcePath( DesPath, SourcePath : string ): string;
    class function getRecyledPath( DesPath, SourcePath : string ): string;
  end;

    // 修改 父类
  TVstLocalBackupDesChange = class( TFaceChangeInfo )
  public
    VstLocalBackupDes : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshTotalPercentage;
    procedure ResetTotalPercentage;
  end;

    // 修改指定路径 父类
  TVstLocalBackupDesWrite = class( TVstLocalBackupDesChange )
  public
    FullPath : string;
  protected
    RootNode : PVirtualNode;
    RootData : PVstLocalBackupDesData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindRootNode : Boolean;
    procedure RefreshRootNode;
    procedure ResetRootSpace;
  end;

  {$EndRegion}

  {$Region ' 修改 根路径 ' }

    // 添加
  TVstLocalBackupDesAdd = class( TVstLocalBackupDesWrite )
  public
    procedure Update;override;
  end;


    // 本地备份目标 是否存在
  TVstLocalBackupDesIsExist = class( TVstLocalBackupDesWrite )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;override;
  end;

    // 本地备份目标 是否可修改
  TVstLocalBackupDesIsModify = class( TVstLocalBackupDesWrite )
  private
    IsModify : Boolean;
  public
    procedure SetIsModify( _IsModify : Boolean );
    procedure Update;override;
  end;

    // 本地备份目标 是否缺少空间
  TVstLocalBackupDesIsLackSpace = class( TVstLocalBackupDesWrite )
  private
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
    procedure Update;override;
  end;

    // 本地备份 修改状态
  TVstLocalBackupDesStatus = class( TVstLocalBackupDesWrite )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 删除
  TVstLocalBackupDesRemove = class( TVstLocalBackupDesWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子路径 ' }

    // 修改 子路径 父类
  TvstLocalBackupDesChildChange = class( TVstLocalBackupDesWrite )
  public
    ChildPath : string;
  protected
    ChildNode : PVirtualNode;
    ChildData : PVstLocalBackupDesData;
  public
    procedure SetChildPath( _ChildPath : string );
  protected
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
  end;

    // 添加
  TvstLocalBackupDesChildAdd = class( TvstLocalBackupDesChildChange )
  private
    PathType : string;
    SourceSize, CompltedSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;override;
  private
    procedure AddChildNode;
  end;


    // 添加已完成空间
  TvstLocalBackupDesChildAddSpace = class( TvstLocalBackupDesChildChange )
  public
    AddSize : Integer;
  public
    procedure SetAddSize( _AddSize : Integer );
    procedure Update;override;
  end;

    // 设置 空间信息
  TvstLocalBackupDesChildSetSpace = class( TvstLocalBackupDesChildChange )
  public
    SourceSize : Int64;
    CompletedSize : Int64;
  public
    procedure SetSourceSize( _SourceSize : Int64 );
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 状态信息
  TvstLocalBackupDesChildSetStatus = class( TvstLocalBackupDesChildChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // 删除
  TvstLocalBackupDesChildRemove = class( TvstLocalBackupDesChildChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 回收子路径 ' }

    // 修改 回收子路径 父类
  TvstLocalBackupDesDeletedChange = class( TVstLocalBackupDesWrite )
  public
    ChildPath : string;
  protected
    ChildNode : PVirtualNode;
    ChildData : PVstLocalBackupDesData;
  public
    procedure SetChildPath( _ChildPath : string );
  protected
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
  end;

    // 添加
  TvstLocalBackupDesDeletedAdd = class( TvstLocalBackupDesDeletedChange )
  private
    PathType : string;
    CompltedSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSpaceInfo( _CompletedSize : Int64 );
    procedure Update;override;
  end;


    // 添加已完成空间
  TvstLocalBackupDesDeletedAddSpace = class( TvstLocalBackupDesDeletedChange )
  public
    AddSize : Integer;
  public
    procedure SetAddSize( _AddSize : Integer );
    procedure Update;override;
  end;

    // 设置 空间信息
  TvstLocalBackupDesDeletedSetSpace = class( TvstLocalBackupDesDeletedChange )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 删除状态
  TvstLocalBackupDesDeletedSetStatus = class( TvstLocalBackupDesDeletedChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // 删除
  TvstLocalBackupDesDeletedRemove = class( TvstLocalBackupDesDeletedChange )
  public
    procedure Update;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' 刷新 显示状态 线程 ' }

    // 备份源 状态信息
  TSourceStatusShowInfo = class
  public
    SourceRootPath, SourceChangeType : string;
    ChangeCount : Integer;
    StartTime : TDateTime;
    IsShow : Boolean;
  public
    constructor Create( _SourceRootPath : string );
    procedure SetSourceChangeType( _SourceChangeType : string );
  end;
  TSourceStatusShowPair = TPair< string , TSourceStatusShowInfo >;
  TSourceStatusShowHash = class(TStringDictionary< TSourceStatusShowInfo >);


    // 刷新  源路径状态 线程
  TLocalBackupSourceStatusShowThread = class( TThread )
  private
    StatusLock : TCriticalSection;
    SourceStatusShowHash : TSourceStatusShowHash;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddSourceRefresh( SourceRootPath : string; RefreshCount : Integer );
    procedure AddSourceCopy( SourceRootPath : string );
  private
    function RefershShowSourceStatus : Boolean;
  end;

      // 备份目标 状态信息
  TDesStatusShowInfo = class
  public
    DesRootPath, DesChangeType : string;
    StartTime : TDateTime;
    IsShow : Boolean;
  public
    SourceRootPath : string;
  public
    constructor Create( _DesRootPath : string );
    procedure SetDesChangeType( _DesChangeType : string );
  end;
  TDesStatusShowPair = TPair< string , TDesStatusShowInfo >;
  TDesStatusShowHash = class(TStringDictionary< TDesStatusShowInfo >);

    // 刷新  目标路径状态 线程
  TLocalBackupDesStatusShowThread = class( TThread )
  private
    StatusLock : TCriticalSection;
    DesStatusShowHash : TDesStatusShowHash;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddChange( DesRootPath, DesChangeType : string );
    procedure AddRecycled( DesRootPath, SourceRootPath : string );
  private
    procedure SetPlBackupDesVisible( IsVisible: Boolean );
    function RefreshShowStatus: Boolean;
  private
    procedure ShowRecycled( DesPath, SourcePath : string );
    procedure HideReceycled( DesPath, SourcePath : string );
  end;


    // 备份状态 刷新显示
  TMyLocalBackupStatusShow = class
  public
    IsRun : Boolean;
    LocalBackupStatusShowThread : TLocalBackupDesStatusShowThread;
    LocalBackupSourceStatusShowThread : TLocalBackupSourceStatusShowThread;
  public
    constructor Create;
    procedure StopShow;
  public
    procedure AddSourceCopy( SourceRootPath : string );
    procedure AddSourceRefresh( SourceRootPath : string; RefreshCount : Integer );
  public
    procedure AddDesChange( DesRootPath, DesChangeType : string );
    procedure AddDesRecycled( DesRootPath, SourceRootPath : string );
  end;

{$EndRegion}


const  // 界面 信息

  LvLocalBackupSource_FileSize = 0;
  LvLocalBackupSource_FileCount = 1;
  LvLocalBackupSource_FileStatus = 2;

  VstLocalBackupSource_ItemPath = 0;
  VstLocalBackupSource_FileSize = 1;
  VstLocalBackupSource_FileCount = 2;
  VstLocalBackupSource_LastSync = 3;
  VstLocalBackupSource_FileStatus = 4;

  SourceChangeType_Copy = 'Copy';
  SourceChangeType_Refresh = 'Refresh';

  DesChangeType_Add = 'Add';
  DesChangeType_Remove = 'Remove';
  DesChangeType_Recycled = 'Recycled';

const
  LocalBackup_RecycledFolder = 'Recycled';

var
  LocalDes_TotalSpace : Int64 = 0;
  LocalDes_CompletedSpace : Int64 = 0;

var
      // 状态变化 显示线程
  MyLocalBackupStatusShow : TMyLocalBackupStatusShow;

implementation

uses UFormLocalBackupPath, UMainForm, UBackupInfoFace, ULocalBackupControl, UFormLocalBackupPro;

{ TVstSelectLocalBackupSourceAddInfo }

procedure TVstSelectLocalBackupSourceAddInfo.Update;
begin
  frmSelectLocalBackupPath.AddBackupPath( FullPath );
end;

{ TVstSelectLocalBackupSourceRemoveInfo }

procedure TVstSelectLocalBackupSourceRemoveInfo.Update;
begin
  frmSelectLocalBackupPath.RemoveBackupPath( FullPath );
end;

{ TVstSelectLocalBackupSourceWriteInfo }

constructor TVstSelectLocalBackupSourceWriteInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceChange }

constructor TLvLocalBackupSourceWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceChange }

procedure TLvLocalBackupSourceChange.ResetStatusColVisible;
var
  IsEmpty : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  co : TVirtualTreeColumn;
begin
    // 是否存在 非空状态
  IsEmpty := True;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if ( SelectData.Status <> '' ) or not SelectData.IsExist or SelectData.IsDisable then
    begin
      IsEmpty := False;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // 隐藏/显示 列
  Co := VstLocalBackupSource.Header.Columns[ VstLocalBackupSource_FileStatus ];
  if IsEmpty and ( coVisible in co.Options ) then
    co.Options := co.Options - [coVisible]
  else
  if not IsEmpty and  not ( coVisible in co.Options ) then
    co.Options := co.Options + [coVisible];
end;

procedure TLvLocalBackupSourceChange.Update;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
end;



{ TLvLocalBackupSourceAdd }

procedure TLvLocalBackupSourceAdd.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime, _NextSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
  NextSyncTime := _NextSyncTime;
end;

procedure TLvLocalBackupSourceAdd.SetBackupInfo(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLvLocalBackupSourceAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLvLocalBackupSourceAdd.SetSpaceInfo(_FileCount : Integer;
  _FileSize : Int64);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLvLocalBackupSourceAdd.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLvLocalBackupSourceAdd.Update;
begin
  inherited;

    // 已存在
  if FindSourceNode then
    Exit;

    // 添加
  SourceNode := VstLocalBackupSource.AddChild( VstLocalBackupSource.RootNode );
  SourceData := VstLocalBackupSource.GetNodeData( SourceNode );
  SourceData.FullPath := FullPath;
  SourceData.PathType := PathType;
  SourceData.IsExist := True;
  SourceData.IsDisable := IsDisable;
  SourceData.IsAutoSync := IsAutoSync;
  SourceData.SyncTimeType := SyncTimeType;
  SourceData.SyncTimeValue := SyncTimeValue;
  SourceData.LastSyncTime := LastSyncTime;
  SourceData.NextSyncTime := NextSyncTime;
  SourceData.FileCount := FileCount;
  SourceData.FileSize := FileSize;
  SourceData.Status := '';
  SourceData.PathIcon := MyIcon.getIconByPath( PathType, FullPath );

    // 第一个
  if VstLocalBackupSource.RootNodeCount = 1 then
  begin
    frmMainForm.tbtnLocalBackupNow.Enabled := True;
    VstLocalBackupSource.TreeOptions.PaintOptions := VstLocalBackupSource.TreeOptions.PaintOptions - [toShowBackground];
  end;

    // 刷新 显示列
  ResetStatusColVisible;
end;

{ TLvLocalBackupSourceRemove }

procedure TLvLocalBackupSourceRemove.Update;
var
  DeleteIndex : Integer;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 删除
  VstLocalBackupSource.DeleteNode( SourceNode );

    // 清空
  if VstLocalBackupSource.RootNodeCount = 0 then
  begin
    frmMainForm.tbtnLocalBackupNow.Enabled := False;
    VstLocalBackupSource.TreeOptions.PaintOptions := VstLocalBackupSource.TreeOptions.PaintOptions + [toShowBackground];
  end;

    // 刷新显示列
  ResetStatusColVisible;
end;

{ TLvLocalBackupSourceSpace }

procedure TLvLocalBackupSourceSpace.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLvLocalBackupSourceSpace.Update;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 修改
  SourceData.FileCount := FileCount;
  SourceData.FileSize := FileSize;

    // 刷新节点
  RefreshNode;
end;

{ TVstLocalBackupDesIsLackSpace }

procedure TVstLocalBackupDesIsLackSpace.SetIsLackSpace(_IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TVstLocalBackupDesIsLackSpace.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

    // 相同
  if RootData.IsLackSpace = IsLackSpace then
    Exit;

  RootData.IsLackSpace := IsLackSpace;

    // 刷新 根路径
  RefreshRootNode;
end;


function TLvLocalBackupSourceWrite.FindSourceNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
begin
  Result := False;

  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      SourceNode := SelectNode;
      SourceData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TLvLocalBackupSourceWrite.RefreshNode;
begin
  VstLocalBackupSource.RepaintNode( SourceNode );
end;

procedure TLvLocalBackupSourceWrite.RefresNextSyncTime;
var
  SyncMins : Integer;
  NextSyncTime : TDateTime;
begin
    // 下次同步时间
  SyncMins := TimeTypeUtil.getMins( SourceData.SyncTimeType, SourceData.SyncTimeValue );
  NextSyncTime := IncMinute( SourceData.LastSyncTime, SyncMins );
  SourceData.NextSyncTime := NextSyncTime;
end;

{ TLvLocalBackupStatus }

procedure TLvLocalBackupStatus.SetShowStatus(_ShowStatus: string);
begin
  ShowStatus := _ShowStatus;
end;

procedure TLvLocalBackupStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TLvLocalBackupStatus.Update;
var
  SelectItem : TListItem;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 修改
  SourceData.Status := Status;
  SourceData.ShowStatus := ShowStatus;

    // 刷新节点
  RefreshNode;

    // 刷新显示列
  ResetStatusColVisible;
end;

{ TLocalBackupFaceScanCompleted }

procedure TLocalBackupFaceScanCompleted.Update;
begin
  if frmMainForm.VstLocalBackupSource.RootNodeCount > 0 then
    frmMainForm.tbtnLocalBackupNow.Enabled := True;
end;

{ VstLocalBackupDesUtil }

class function VstLocalBackupDesUtil.getChildNodeIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstLocalBackupDesData;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if NodeData.FileSize = 0 then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.FileSize >= NodeData.SourceFileSize then
    Result := MyShellTransActionIconUtil.getLoaded
  else
    Result := MyShellTransActionIconUtil.getWaiting;
end;


class function VstLocalBackupDesUtil.getChildNodeStatus(
  Node: PVirtualNode): string;
var
  NodeData : PVstLocalBackupDesData;
  Percentage : Integer;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if NodeData.FileSize = 0 then
    Result := LocalBackupStatus_InCompleted
  else
  if NodeData.FileSize >= NodeData.SourceFileSize then
    Result := LocalBackupStatus_Completed
  else
  begin
    Percentage := MyPercentage.getPercent( NodeData.FileSize, NodeData.SourceFileSize );
    Result := MyPercentage.getPercentageStr( Percentage ) + ' ' + LocalBackupStatus_Completed;
  end;
end;

class function VstLocalBackupDesUtil.getChildPathList(
  RootPath: string): TStringList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode, ChildNode : PVirtualNode;
  NodeData, ChildData : PVstLocalBackupDesData;
begin
  Result := TStringList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    if NodeData.FullPath = RootPath then
    begin
      ChildNode := SelectNode.FirstChild;
      while Assigned( ChildNode ) do
      begin
        ChildData := vstLocalBackupDes.GetNodeData( ChildNode );
        Result.Add( ChildData.FullPath );
        ChildNode := ChildNode.NextSibling;
      end;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


class function VstLocalBackupDesUtil.getDesPathList: TStringList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstLocalBackupDesData;
begin
  Result := TStringList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    Result.Add( NodeData.FullPath );
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.getDesSourcePath(DesPath,
  SourcePath: string): string;
begin
  Result := MyFilePath.getPath( DesPath );
  Result := Result + MyFilePath.getDownloadPath( SourcePath );
end;

class function VstLocalBackupDesUtil.getIsRootNode(FullPath: string): Boolean;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstLocalBackupDesData;
begin
  Result := False;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    if NodeData.FullPath = FullPath then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.getRecyledPath(DesPath,
  SourcePath: string): string;
begin
  Result := MyFilePath.getPath( DesPath );
  Result := Result + LocalBackup_RecycledFolder + '\';
  Result := Result + MyFilePath.getDownloadPath( SourcePath );
end;

class function VstLocalBackupDesUtil.getRootNodeIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstLocalBackupDesData;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if not NodeData.IsExist or not NodeData.IsModify
  then
    Result := MyShellTransActionIconUtil.getDisable
  else
  if NodeData.Status = LocalBackupStatus_Copying then
    Result := MyShellTransActionIconUtil.getCopyFile
  else
  if NodeData.Status = LocalBackupStatus_Removing then
    Result := MyShellTransActionIconUtil.getRecycle
  else
  begin
    if NodeData.FileSize >= NodeData.SourceFileSize then
      Result := MyShellTransActionIconUtil.getLoaded
    else
    if NodeData.IsLackSpace then
      Result := MyShellTransActionIconUtil.getDisable
    else
    if NodeData.FileSize = 0 then
      Result := MyShellTransActionIconUtil.getLoadedError
    else
      Result := MyShellTransActionIconUtil.getWaiting;
  end;
end;

class function VstLocalBackupDesUtil.getRootNodeStatus(Node: PVirtualNode): string;
var
  NodeData : PVstLocalBackupDesData;
  Percentage : Integer;
  FileSize, SourceSize : Int64;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := LocalBackupStatus_NotExist
  else
  if not NodeData.IsModify then
    Result := LocalBackupStatus_Unmodifiable
  else
  if NodeData.Status <> '' then
    Result := NodeData.Status
  else
  begin
    FileSize := NodeData.FileSize;
    SourceSize := NodeData.SourceFileSize;

      // 根据空间确定状态
    if FileSize >= SourceSize then
    begin
      Result := LocalBackupStatus_Completed;
      if NodeData.IsLackSpace then  // 不是缺少空间的状态
        NodeData.IsLackSpace := False;
    end
    else
    if NodeData.IsLackSpace then
      Result := LocalBackupStatus_LackSpace
    else
    if FileSize = 0 then
      Result := LocalBackupStatus_InCompleted
    else
    begin
      Percentage := MyPercentage.getPercent( FileSize, SourceSize );
      Result := MyPercentage.getPercentageStr( Percentage ) + ' ' + LocalBackupStatus_Completed;
    end;
  end;
end;

class function VstLocalBackupDesUtil.getNodeStatusInt(
  Node: PVirtualNode): Integer;
var
  NodeStatus : string;
begin
  NodeStatus := getRootNodeStatus( Node );
  if NodeStatus = LocalBackupStatus_NotExist then
    Result := 1
  else
  if NodeStatus = LocalBackupStatus_Unmodifiable then
    Result := 2
  else
  if NodeStatus = LocalBackupStatus_LackSpace then
    Result := 3
  else
  if NodeStatus = LocalBackupStatus_Copying then
    Result := 4
  else
  if NodeStatus = LocalBackupStatus_Removing then
    Result := 5
  else
  if NodeStatus = LocalBackupStatus_InCompleted then
    Result := 6
  else
  if NodeStatus = LocalBackupStatus_Completed then
    Result := 8
  else
    Result := 7;
end;


class function VstLocalBackupDesUtil.getSelectPathList: TVstSelectPathList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode, RootNode : PVirtualNode;
  NodeData, RootData : PVstLocalBackupDesData;
  SelectInfo : TVstSelectPathInfo;
begin
  Result := TVstSelectPathList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = vstLocalBackupDes.RootNode then
      RootNode := SelectNode
    else
      RootNode := SelectNode.Parent;

    RootData := vstLocalBackupDes.GetNodeData( RootNode );
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    SelectInfo := TVstSelectPathInfo.Create( RootData.FullPath, NodeData.FullPath );
    SelectInfo.SetIsDeleted( NodeData.IsDeleted );
    Result.Add( SelectInfo );

    SelectNode := vstLocalBackupDes.GetNextSelected( SelectNode );
  end;
end;

class function VstLocalBackupDesUtil.IsExist(FullPath: string): Boolean;
var
  VstLocalBackupDes : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  Node := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := frmMainForm.VstLocalBackupDes.GetNodeData(Node);
    // 不能包含目标路径
    if NodeData.FullPath = FullPath then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.IsExistChild(FullPath: string): Boolean;
var
  VstLocalBackupDes : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  Node := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := VstLocalBackupDes.GetNodeData(Node);
    // 不能包含目标路径
    if MyMatchMask.CheckEqualsOrChild(NodeData.FullPath, FullPath) then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

{ TVstLocalBackupDesStatus }

procedure TVstLocalBackupDesStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstLocalBackupDesStatus.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.Status := Status;

    // 刷新 根路径
  RefreshRootNode;
end;

{ TvstLocalBackupDesChildChange }

function TvstLocalBackupDesChildChange.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;
  if not FindRootNode then
    Exit;

  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if not SelectData.IsDeleted and ( SelectData.FullPath = ChildPath ) then
    begin
      ChildNode := SelectNode;
      ChildData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TvstLocalBackupDesChildChange.RefreshChildNode;
begin
  VstLocalBackupDes.RepaintNode( ChildNode );
end;

procedure TvstLocalBackupDesChildChange.SetChildPath(_ChildPath: string);
begin
  ChildPath := _ChildPath;
end;

{ TvstLocalBackupDesChildAdd }

procedure TvstLocalBackupDesChildAdd.AddChildNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
  IsFindDelted : Boolean;
  FirstDeltedNode : PVirtualNode;
begin
  IsFindDelted := False;
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.IsDeleted then
    begin
      FirstDeltedNode := SelectNode;
      IsFindDelted := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

  if not IsFindDelted then
    ChildNode := VstLocalBackupDes.AddChild( RootNode )
  else
    ChildNode := VstLocalBackupDes.InsertNode( FirstDeltedNode, amInsertBefore );
end;

procedure TvstLocalBackupDesChildAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TvstLocalBackupDesChildAdd.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesChildAdd.Update;
begin
  inherited;

  if not FindRootNode or FindChildNode then
    Exit;

  AddChildNode; // 创建节点
  ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
  ChildData.FullPath := ChildPath;
  ChildData.PathType := PathType;
  ChildData.FileSize := CompltedSize;
  ChildData.SourceFileSize := SourceSize;
  ChildData.IsDeleted := False;
  ChildData.Status := '';
  ChildData.PathIcon := MyIcon.getIconByPath( PathType, VstLocalBackupDesUtil.getDesSourcePath( FullPath, ChildPath ) );

    // 刷新 根路径
  RootData.FileSize := RootData.FileSize + CompltedSize;
  RootData.SourceFileSize := RootData.SourceFileSize + SourceSize;
  RefreshRootNode;

    // 刷新 总百分比
  LocalDes_TotalSpace := LocalDes_TotalSpace + SourceSize;
  LocalDes_CompletedSpace := LocalDes_CompletedSpace + CompltedSize;
  RefreshTotalPercentage;

    // 展开根目录
  if ( RootNode.ChildCount = 1 ) and not VstLocalBackupDes.Expanded[ RootNode ] then
    VstLocalBackupDes.Expanded[ RootNode ] := True;
end;

{ TvstLocalBackupDesChildRemove }

procedure TvstLocalBackupDesChildRemove.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // 修改 根目录
  RootData.FileSize := RootData.FileSize - ChildData.FileSize;
  RootData.SourceFileSize := RootData.SourceFileSize - ChildData.SourceFileSize;
  RefreshRootNode;

    // 刷新 界面
  LocalDes_TotalSpace := LocalDes_TotalSpace - ChildData.SourceFileSize;
  LocalDes_CompletedSpace := LocalDes_CompletedSpace - ChildData.FileSize;
  RefreshTotalPercentage;

    // 删除 子目录
  VstLocalBackupDes.DeleteNode( ChildNode );
end;

{ TvstLocalBackupDesChildSourceSpace }

procedure TvstLocalBackupDesChildSetSpace.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesChildSetSpace.SetSourceSize(
  _SourceSize: Int64);
begin
  SourceSize := _SourceSize;
end;

procedure TvstLocalBackupDesChildSetSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // 修改 子目录
  ChildData.SourceFileSize := SourceSize;
  ChildData.FileSize := CompletedSize;
  VstLocalBackupDes.RepaintNode( ChildNode );

    // 修改 根目录
  ResetRootSpace;

    // 刷新 总百分比
  ResetTotalPercentage;
end;

{ TvstLocalBackupDesChildAddSpace }

procedure TvstLocalBackupDesChildAddSpace.SetAddSize(_AddSize: Integer);
begin
  AddSize := _AddSize;
end;

procedure TvstLocalBackupDesChildAddSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // 刷新文件图标
  if ( ChildData.FileSize = 0 ) and ( ChildData.PathType = PathType_File ) then
    ChildData.PathIcon := MyIcon.getIconByPath( PathType_File, VstLocalBackupDesUtil.getDesSourcePath( FullPath, ChildPath ) );

    // 修改 子路径
  ChildData.FileSize := ChildData.FileSize + AddSize;
  RefreshChildNode;

    // 修改 根路径
  RootData.FileSize := RootData.FileSize + AddSize;
  VstLocalBackupDes.RepaintNode( RootNode );

    // 刷新 总百分比
  LocalDes_CompletedSpace := LocalDes_CompletedSpace + AddSize;
  RefreshTotalPercentage;
end;

{ TVstLocalBackupDesChange }

procedure TVstLocalBackupDesChange.RefreshTotalPercentage;
begin
  frmMainForm.PbLocalBackup.Percent := MyPercentage.getPercent( LocalDes_CompletedSpace, LocalDes_TotalSpace );
  frmMainForm.plLocalBackupPercentShow.Caption := MyPercentage.getCompareStr( LocalDes_CompletedSpace, LocalDes_TotalSpace );
end;

procedure TVstLocalBackupDesChange.ResetTotalPercentage;
var
  TotalSize, TotalCompletedSize : Int64;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  TotalSize := 0;
  TotalCompletedSize := 0;

  SelectNode := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    TotalSize := TotalSize + SelectData.SourceFileSize;
    TotalCompletedSize := TotalCompletedSize + SelectData.FileSize;
    SelectNode := SelectNode.NextSibling;
  end;

    // 设置值 并 刷新界面
  LocalDes_TotalSpace := TotalSize;
  LocalDes_CompletedSpace := TotalCompletedSize;
  RefreshTotalPercentage;
end;


procedure TVstLocalBackupDesChange.Update;
begin
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
end;

{ TVstLocalBackupDesWrite }

constructor TVstLocalBackupDesWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TVstLocalBackupDesWrite.FindRootNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;

  SelectNode := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      RootNode := SelectNode;
      RootData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstLocalBackupDesWrite.RefreshRootNode;
begin
  VstLocalBackupDes.RepaintNode( RootNode );
end;

procedure TVstLocalBackupDesWrite.ResetRootSpace;
var
  SourceFileSize, FileSize : Int64;
  ChildNode : PVirtualNode;
  ChildData : PVstLocalBackupDesData;
begin
  SourceFileSize := 0;
  FileSize := 0;
  ChildNode := RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
    if not ChildData.IsDeleted then
    begin
      SourceFileSize := SourceFileSize + ChildData.SourceFileSize;
      FileSize := FileSize + ChildData.FileSize;
    end;
    ChildNode := ChildNode.NextSibling;
  end;

  RootData.SourceFileSize := SourceFileSize;
  RootData.FileSize := FileSize;
  RefreshRootNode;
end;


{ TVstLocalBackupDesAdd }

procedure TVstLocalBackupDesAdd.Update;
begin
  inherited;

    // 已存在
  if FindRootNode then
    Exit;

    // 创建
  RootNode := VstLocalBackupDes.AddChild( VstLocalBackupDes.RootNode );
  RootData := VstLocalBackupDes.GetNodeData( RootNode );

    // 初始化
  RootData.FullPath := FullPath;
  RootData.FileSize := 0;
  RootData.SourceFileSize := 0;
  RootData.IsExist := True;
  RootData.IsModify := True;
  RootData.IsLackSpace := False;
  RootData.IsDeleted := False;
  RootData.Status := '';
  RootData.PathIcon := MyIcon.getIconByPath( PathType_Folder, FullPath );

    // 第一条路径
  if VstLocalBackupDes.RootNodeCount = 1 then
    VstLocalBackupDes.TreeOptions.PaintOptions := VstLocalBackupDes.TreeOptions.PaintOptions - [toShowBackground];
end;

{ TVstLocalBackupDesRemove }

procedure TVstLocalBackupDesRemove.Update;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

  VstLocalBackupDes.DeleteNode( RootNode );

    // 第一条路径
  if VstLocalBackupDes.RootNodeCount = 0 then
    VstLocalBackupDes.TreeOptions.PaintOptions := VstLocalBackupDes.TreeOptions.PaintOptions + [toShowBackground];
end;

{ TVstLocalBackupDesIsExist }

procedure TVstLocalBackupDesIsExist.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TVstLocalBackupDesIsExist.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.IsExist := IsExist;
  RootData.PathIcon := MyIcon.getIconByPath( PathType_Folder, FullPath );

    // 刷新 根路径
  RefreshRootNode;
end;

{ TVstLocalBackupDesIsModify }

procedure TVstLocalBackupDesIsModify.SetIsModify(_IsModify: Boolean);
begin
  IsModify := _IsModify;
end;

procedure TVstLocalBackupDesIsModify.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.IsModify := IsModify;

    // 刷新 根路径
  RefreshRootNode;
end;

{ TLocalStatusShowInfo }

constructor TSourceStatusShowInfo.Create(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TSourceStatusShowInfo.SetSourceChangeType(_SourceChangeType: string);
begin
  SourceChangeType := _SourceChangeType;
end;

{ TLocalBackupSourceStatusShowThread }

procedure TLocalBackupSourceStatusShowThread.AddSourceCopy(
  SourceRootPath: string);
var
  SourceStatusShowInfo : TSourceStatusShowInfo;
begin
  StatusLock.Enter;
  if not SourceStatusShowHash.ContainsKey( SourceRootPath ) then
  begin
    SourceStatusShowInfo := TSourceStatusShowInfo.Create( SourceRootPath );
    SourceStatusShowHash.AddOrSetValue( SourceRootPath, SourceStatusShowInfo );
  end
  else
    SourceStatusShowInfo := SourceStatusShowHash[ SourceRootPath ];
  if SourceStatusShowInfo.SourceChangeType <> SourceChangeType_Copy then
  begin
    SourceStatusShowInfo.SetSourceChangeType( SourceChangeType_Copy );
    SourceStatusShowInfo.IsShow := True;
  end;
  SourceStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

procedure TLocalBackupSourceStatusShowThread.AddSourceRefresh(
  SourceRootPath: string; RefreshCount: Integer);
var
  SourceStatusShowInfo : TSourceStatusShowInfo;
begin
  StatusLock.Enter;

  if not SourceStatusShowHash.ContainsKey( SourceRootPath ) then
  begin
    SourceStatusShowInfo := TSourceStatusShowInfo.Create( SourceRootPath );
    SourceStatusShowHash.AddOrSetValue( SourceRootPath, SourceStatusShowInfo );
  end
  else
    SourceStatusShowInfo := SourceStatusShowHash[ SourceRootPath ];

  SourceStatusShowInfo.SetSourceChangeType( SourceChangeType_Refresh );
  SourceStatusShowInfo.IsShow := True;
  SourceStatusShowInfo.ChangeCount := RefreshCount;
  SourceStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

constructor TLocalBackupSourceStatusShowThread.Create;
begin
  inherited;
  StatusLock := TCriticalSection.Create;
  SourceStatusShowHash := TSourceStatusShowHash.Create;
end;

destructor TLocalBackupSourceStatusShowThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  SourceStatusShowHash.Free;
  StatusLock.Free;
  inherited;
end;

procedure TLocalBackupSourceStatusShowThread.Execute;
begin
  while not Terminated do
  begin
    if not RefershShowSourceStatus then
      Suspend
    else
      Sleep(200);
  end;
  inherited;
end;


function TLocalBackupSourceStatusShowThread.RefershShowSourceStatus: Boolean;
var
  RemoveList : TStringList;
  i : Integer;
  p : TSourceStatusShowPair;
  NewStatus, ShowStatus : string;
  LocalBackupSourceStatusHandle : TLocalBackupSourceStatusHandle;
begin
  StatusLock.Enter;
  RemoveList := TStringList.Create;

    // 显示
  for p in SourceStatusShowHash do
  begin

      // 是否过期
    if SecondsBetween( Now, p.Value.StartTime ) > 2 then
    begin
      NewStatus := '';
      ShowStatus := '';
      RemoveList.Add( p.Value.SourceRootPath );
    end
    else   // 是否显示
    if not p.Value.IsShow then
      Continue
    else
    begin
      p.Value.IsShow := False;
      if p.Value.SourceChangeType = SourceChangeType_Copy then
      begin
        NewStatus := LocalBackupSourceStatus_Copy;
        ShowStatus := NewStatus;
      end
      else
      begin
        NewStatus := LocalBackupSourceStatus_Refresh;
        ShowStatus := LocalBackupSourceStatus_Refresh + ' ' + IntToStr( p.Value.ChangeCount ) + ' Files';
      end;
    end;

      // 刷新状态
    LocalBackupSourceStatusHandle := TLocalBackupSourceStatusHandle.Create( p.Value.SourceRootPath );
    LocalBackupSourceStatusHandle.SetStatus( NewStatus );
    LocalBackupSourceStatusHandle.SetShowStatus( ShowStatus );
    LocalBackupSourceStatusHandle.Update;
    LocalBackupSourceStatusHandle.Free;
  end;

    // 删除
  for i := 0 to RemoveList.Count - 1 do
    SourceStatusShowHash.Remove( RemoveList[i] );
  RemoveList.Free;

  Result := SourceStatusShowHash.Count > 0;

  StatusLock.Leave;
end;

{ TDesStatusShowInfo }

procedure TDesStatusShowInfo.SetDesChangeType(_DesChangeType: string);
begin
  DesChangeType := _DesChangeType;
end;

constructor TDesStatusShowInfo.Create(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

{ TLocalBackupDesStatusShowThread }

procedure TLocalBackupDesStatusShowThread.AddChange(DesRootPath,
  DesChangeType: string);
var
  DesStatusShowInfo : TDesStatusShowInfo;
begin
  StatusLock.Enter;
  if not DesStatusShowHash.ContainsKey( DesRootPath ) then
  begin
    DesStatusShowInfo := TDesStatusShowInfo.Create( DesRootPath );
    DesStatusShowHash.AddOrSetValue( DesRootPath, DesStatusShowInfo );
  end
  else
    DesStatusShowInfo := DesStatusShowHash[ DesRootPath ];
  if DesStatusShowInfo.DesChangeType <> DesChangeType then
  begin
    if DesStatusShowInfo.DesChangeType = DesChangeType_Recycled then
      HideReceycled( DesStatusShowInfo.DesRootPath, DesStatusShowInfo.SourceRootPath );
    DesStatusShowInfo.SetDesChangeType( DesChangeType );
    DesStatusShowInfo.IsShow := True;
  end;
  DesStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

procedure TLocalBackupDesStatusShowThread.AddRecycled(DesRootPath,
  SourceRootPath: string);
begin
  AddChange( DesRootPath, DesChangeType_Recycled );

    // 设置 源路径
  StatusLock.Enter;
  if DesStatusShowHash.ContainsKey( DesRootPath ) then
    DesStatusShowHash[ DesRootPath ].SourceRootPath := SourceRootPath;
  StatusLock.Leave;
end;

constructor TLocalBackupDesStatusShowThread.Create;
begin
  inherited Create( True );
  StatusLock := TCriticalSection.Create;
  DesStatusShowHash := TDesStatusShowHash.Create;
end;

destructor TLocalBackupDesStatusShowThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  DesStatusShowHash.Free;
  StatusLock.Free;
  inherited;
end;

procedure TLocalBackupDesStatusShowThread.Execute;
begin
  if not Terminated then
    SetPlBackupDesVisible( True );

  while not Terminated do
  begin

    if not RefreshShowStatus then
    begin
      SetPlBackupDesVisible( False );
      Suspend;
      SetPlBackupDesVisible( True );
    end
    else
      Sleep(200);
  end;
  inherited;
end;

procedure TLocalBackupDesStatusShowThread.HideReceycled(DesPath,
  SourcePath: string);
var
  vstLocalBackupDesChildSetStatus : TvstLocalBackupDesChildSetStatus;
  vstLocalBackupDesDeletedSetStatus : TvstLocalBackupDesDeletedSetStatus;
begin
    // 备份路径
  vstLocalBackupDesChildSetStatus := TvstLocalBackupDesChildSetStatus.Create( DesPath );
  vstLocalBackupDesChildSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesChildSetStatus.SetStatus( '' );
  MyFaceChange.AddChange( vstLocalBackupDesChildSetStatus );

    // 回收路径
  vstLocalBackupDesDeletedSetStatus := TvstLocalBackupDesDeletedSetStatus.Create( DesPath );
  vstLocalBackupDesDeletedSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesDeletedSetStatus.SetStatus( '' );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedSetStatus );
end;

function TLocalBackupDesStatusShowThread.RefreshShowStatus: Boolean;
var
  RemoveList : TStringList;
  i : Integer;
  p : TDesStatusShowPair;
  VstLocalBackupDesStatus : TVstLocalBackupDesStatus;
  ShowStatus : string;
begin
  StatusLock.Enter;
  RemoveList := TStringList.Create;

    // 显示
  for p in DesStatusShowHash do
  begin

      // 是否过期
    if SecondsBetween( Now, p.Value.StartTime ) > 2 then
    begin
      ShowStatus := '';
      RemoveList.Add( p.Value.DesRootPath );
    end
    else   // 是否显示
    if not p.Value.IsShow then
      Continue
    else
    begin
      p.Value.IsShow := False;

      if p.Value.DesChangeType = DesChangeType_Add then
        ShowStatus := LocalBackupStatus_Copying
      else
        ShowStatus := LocalBackupStatus_Removing;
    end;

      // 回收的情况
    if p.Value.DesChangeType = DesChangeType_Recycled then
    begin
      if ShowStatus = '' then
        HideReceycled( p.Value.DesRootPath, p.Value.SourceRootPath )
      else
        ShowRecycled( p.Value.DesRootPath, p.Value.SourceRootPath );
      Continue;
    end;

      // 显示
    VstLocalBackupDesStatus := TVstLocalBackupDesStatus.Create( p.Value.DesRootPath );
    VstLocalBackupDesStatus.SetStatus( ShowStatus );
    MyBackupFileFace.AddChange( VstLocalBackupDesStatus );
  end;

    // 删除
  for i := 0 to RemoveList.Count - 1 do
    DesStatusShowHash.Remove( RemoveList[i] );
  RemoveList.Free;

  Result := DesStatusShowHash.Count > 0;

  StatusLock.Leave;
end;

procedure TLocalBackupDesStatusShowThread.SetPlBackupDesVisible(
  IsVisible: Boolean);
var
  PlBackupDesBoardVisibleInfo : TPlBackupDesBoardVisibleInfo;
begin
  PlBackupDesBoardVisibleInfo := TPlBackupDesBoardVisibleInfo.Create( IsVisible );
  MyBackupFileFace.AddChange( PlBackupDesBoardVisibleInfo );
end;

procedure TLocalBackupDesStatusShowThread.ShowRecycled(DesPath,
  SourcePath: string);
var
  vstLocalBackupDesChildSetStatus : TvstLocalBackupDesChildSetStatus;
  vstLocalBackupDesDeletedSetStatus : TvstLocalBackupDesDeletedSetStatus;
begin
    // 备份路径
  vstLocalBackupDesChildSetStatus := TvstLocalBackupDesChildSetStatus.Create( DesPath );
  vstLocalBackupDesChildSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesChildSetStatus.SetStatus( LocalBackupStatus_Recycling );
  MyFaceChange.AddChange( vstLocalBackupDesChildSetStatus );

    // 回收路径
  vstLocalBackupDesDeletedSetStatus := TvstLocalBackupDesDeletedSetStatus.Create( DesPath );
  vstLocalBackupDesDeletedSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesDeletedSetStatus.SetStatus( LocalBackupStatus_Copying );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedSetStatus );
end;

{ TMyLocalBackupStatusShow }

procedure TMyLocalBackupStatusShow.AddDesChange(DesRootPath,
  DesChangeType: string);
begin
  if not IsRun then
    Exit;

  LocalBackupStatusShowThread.AddChange( DesRootPath, DesChangeType );
end;

procedure TMyLocalBackupStatusShow.AddDesRecycled(DesRootPath,
  SourceRootPath: string);
begin
  if not IsRun then
    Exit;

  LocalBackupStatusShowThread.AddRecycled( DesRootPath, SourceRootPath );
end;

procedure TMyLocalBackupStatusShow.AddSourceCopy(SourceRootPath: string);
begin
  if not IsRun then
    Exit;

  LocalBackupSourceStatusShowThread.AddSourceCopy( SourceRootPath );
end;

procedure TMyLocalBackupStatusShow.AddSourceRefresh(SourceRootPath: string;
  RefreshCount: Integer);
begin
  if not IsRun then
    Exit;

  LocalBackupSourceStatusShowThread.AddSourceRefresh( SourceRootPath, RefreshCount );
end;

constructor TMyLocalBackupStatusShow.Create;
begin
  LocalBackupStatusShowThread := TLocalBackupDesStatusShowThread.Create;
  LocalBackupSourceStatusShowThread := TLocalBackupSourceStatusShowThread.Create;
  IsRun := True;
end;

procedure TMyLocalBackupStatusShow.StopShow;
begin
  IsRun := False;
  LocalBackupStatusShowThread.Free;
  LocalBackupSourceStatusShowThread.Free;
end;

{ TLvLocalBackupExist }

procedure TLvLocalBackupExist.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TLvLocalBackupExist.Update;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 修改
  SourceData.IsExist := IsExist;
  SourceData.PathIcon := MyIcon.getIconByPath( SourceData.PathType, FullPath );

    // 刷新节点
  RefreshNode;

    // 刷新显示列
  ResetStatusColVisible;
end;

{ VstLocalBackupSourceUtil }

class function VstLocalBackupSourceUtil.getChildPathList(
  RootPath: string): TStringList;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode, ChildNode : PVirtualNode;
  SelectData, ChildData : PVstLocalBackupSourceData;
begin
  Result := TStringList.Create;

  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if SelectData.FullPath = RootPath then
    begin
      ChildNode := SelectNode.FirstChild;
      while Assigned( ChildNode ) do
      begin
        ChildData := VstLocalBackupSource.GetNodeData( ChildNode );
        Result.Add( ChildData.FullPath );
        ChildNode := ChildNode.NextSibling;
      end;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupSourceUtil.getNextSync(Node: PVirtualNode): string;
var
  VstLocalBackupSource : TVirtualStringTree;
  NodeData : PVstLocalBackupSourceData;
  ShowStr : string;
  ShowStrList : TStringList;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  NodeData := VstLocalBackupSource.GetNodeData( Node );
  if not NodeData.IsAutoSync or NodeData.IsDisable then
    Result := frmMainForm.siLang_frmMainForm.GetText( 'NA' )
  else
  begin
    ShowStr := TimeTypeUtil.getMinShowStr( MinutesBetween( Now, NodeData.NextSyncTime ) );
    Result := LanguageUtil.getSyncTimeStr( ShowStr );
  end;
end;

class function VstLocalBackupSourceUtil.getSelectPathList: TStringList;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
begin
  Result := TStringList.Create;

  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstLocalBackupSource.Selected[ SelectNode ] then
    begin
      SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
      Result.Add( SelectData.FullPath );
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupSourceUtil.IsInclude(FullPath: string): Boolean;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  Result := False;
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;

      // 存在父路径
    if MyMatchMask.CheckEqualsOrChild(FullPath, SourcePath) then
    begin
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

class procedure VstLocalBackupSourceUtil.RemoveChild(FullPath: string);
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;
        // 删除子路径
    if MyMatchMask.CheckChild( SourcePath, FullPath ) then
      MyLocalBackupSourceControl.RemoveSourcePath( SourcePath );

    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLvLocalBackupSourceProData }

constructor TLvLocalBackupSourceProData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceProChange }

procedure TLvLocalBackupSourceProChange.Update;
begin
  LvLocalBackupSourcePro := FrmLocalBackupPro.LvBackupItem;
end;

{ TLvLocalBackupSourceProWrite }

constructor TLvLocalBackupSourceProWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvLocalBackupSourceProWrite.FindPathItem: Boolean;
var
  i : Integer;
  SelectData : TLvLocalBackupSourceProData;
begin
  Result := False;

  for i := 0 to LvLocalBackupSourcePro.Items.Count - 1 do
  begin
    SelectData := LvLocalBackupSourcePro.Items[i].Data;
    if SelectData.FullPath = FullPath then
    begin
      PathItem := LvLocalBackupSourcePro.Items[i];
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvLocalBackupSourceProAdd }

procedure TLvLocalBackupSourceProAdd.Update;
var
  PathData : TLvLocalBackupSourceProData;
begin
  inherited;

    // 已存在
  if FindPathItem then
    Exit;

    // 创建
  PathData := TLvLocalBackupSourceProData.Create( FullPath );
  with LvLocalBackupSourcePro.Items.Add do
  begin
    Caption := ExtractFileName( FullPath );
    SubItems.Add('');
    ImageIndex := MyIcon.getIconByFilePath( FullPath );
    Data := PathData;
  end;
end;

{ TLvLocalBackupSourceProRemove }

procedure TLvLocalBackupSourceProRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPathItem then
    Exit;

    // 删除
  LvLocalBackupSourcePro.Items.Delete( PathIndex );
end;

{ TLvLocalBackupDesProData }

constructor TLvLocalBackupDesProData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupDesProChange }

procedure TLvLocalBackupDesProChange.Update;
begin
  LvLocalBackupDesPro := FrmLocalBackupPro.LvDestination;
end;

{ TLvLocalBackupDesProWrite }

constructor TLvLocalBackupDesProWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvLocalBackupDesProWrite.FindPathItem: Boolean;
var
  i : Integer;
  SelectData : TLvLocalBackupDesProData;
begin
  Result := False;

  for i := 0 to LvLocalBackupDesPro.Items.Count - 1 do
  begin
    SelectData := LvLocalBackupDesPro.Items[i].Data;
    if SelectData.FullPath = FullPath then
    begin
      PathItem := LvLocalBackupDesPro.Items[i];
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvLocalBackupDesProAdd }

procedure TLvLocalBackupDesProAdd.Update;
var
  PathData : TLvLocalBackupDesProData;
begin
  inherited;

    // 已存在
  if FindPathItem then
    Exit;

    // 创建
  PathData := TLvLocalBackupDesProData.Create( FullPath );
  with LvLocalBackupDesPro.Items.Add do
  begin
    Caption := FullPath;
    SubItems.Add('');
    ImageIndex := MyIcon.getIconByFilePath( FullPath );
    Data := PathData;
  end;
end;

{ TLvLocalBackupDesProRemove }

procedure TLvLocalBackupDesProRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPathItem then
    Exit;

    // 删除
  LvLocalBackupDesPro.Items.Delete( PathIndex );
end;

{ TVstLocalBackupSourceSetLastSyncTime }

procedure TVstLocalBackupSourceSetLastSyncTime.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TVstLocalBackupSourceSetLastSyncTime.Update;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 设置 上一次 同步时间
  SourceData.LastSyncTime := LastSyncTime;

    // 刷新 下次同步时间
  RefresNextSyncTime;

    // 刷新节点
  RefreshNode;
end;


{ TVstLocalBackupSourceSetSyncMins }

procedure TVstLocalBackupSourceSetSyncTime.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TVstLocalBackupSourceSetSyncTime.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstLocalBackupSourceSetSyncTime.Update;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 设置 上一次 同步时间
  SourceData.IsAutoSync := IsAutoSync;
  SourceData.SyncTimeType := SyncTimeType;
  SourceData.SyncTimeValue := SyncTimeValue;

    // 刷新 下次同步时间
  RefresNextSyncTime;

    // 刷新节点
  RefreshNode;
end;

{ TVstLocalBackupSourceRefreshNextSyncTime }

procedure TVstLocalBackupSourceRefreshNextSyncTime.Update;
begin
  inherited;
  RefreshNode;
end;

{ TVstLocalBackupSourceIsDisable }

procedure TVstLocalBackupSourceIsDisable.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstLocalBackupSourceIsDisable.Update;
begin
  inherited;

    // 不存在
  if not FindSourceNode then
    Exit;

    // 修改
  SourceData.IsDisable := IsDisable;

    // 刷新节点
  RefreshNode;

    // 刷新显示列
  ResetStatusColVisible;
end;

{ TVstSelectPathInfo }

constructor TVstSelectPathInfo.Create(_RootPath, _SelectPath: string);
begin
  RootPath := _RootPath;
  SelectPath := _SelectPath;
end;

procedure TVstSelectPathInfo.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

{ TvstLocalBackupDesDeletedChange }

function TvstLocalBackupDesDeletedChange.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;
  if not FindRootNode then
    Exit;

  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.IsDeleted and ( SelectData.FullPath = ChildPath ) then
    begin
      ChildNode := SelectNode;
      ChildData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TvstLocalBackupDesDeletedChange.RefreshChildNode;
begin
  VstLocalBackupDes.RepaintNode( ChildNode );
end;

procedure TvstLocalBackupDesDeletedChange.SetChildPath(_ChildPath: string);
begin
  ChildPath := _ChildPath;
end;

{ TvstLocalBackupDesDeletedAdd }

procedure TvstLocalBackupDesDeletedAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TvstLocalBackupDesDeletedAdd.SetSpaceInfo(
  _CompletedSize: Int64);
begin
  CompltedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesDeletedAdd.Update;
var
  ExplorerPath : string;
begin
  inherited;

  if not FindRootNode or FindChildNode then
    Exit;

  ChildNode := VstLocalBackupDes.AddChild( RootNode );
  ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
  ChildData.FullPath := ChildPath;
  ChildData.PathType := PathType;
  ChildData.FileSize := CompltedSize;
  ChildData.IsDeleted := True;
  ChildData.Status := '';
  ChildData.PathIcon := MyShellTransActionIconUtil.getRecycle;

    // 文件 跳过创建目录
  if PathType = PathType_File then
    Exit;
  try
    ExplorerPath := VstLocalBackupDesUtil.getRecyledPath( FullPath, ChildPath );
    ForceDirectories( ExplorerPath );
  except
  end;
end;

{ TvstLocalBackupDesDeletedAddSpace }

procedure TvstLocalBackupDesDeletedAddSpace.SetAddSize(_AddSize: Integer);
begin
  AddSize := _AddSize;
end;

procedure TvstLocalBackupDesDeletedAddSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  ChildData.FileSize := ChildData.FileSize + AddSize;

    // 刷新 子节点
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedSetSpace }

procedure TvstLocalBackupDesDeletedSetSpace.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesDeletedSetSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  ChildData.FileSize := CompletedSize;

    // 刷新 子节点
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedRemove }

procedure TvstLocalBackupDesDeletedRemove.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  VstLocalBackupDes.DeleteNode( ChildNode );
end;

{ TvstLocalBackupDesChildSetStatus }

procedure TvstLocalBackupDesChildSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TvstLocalBackupDesChildSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindChildNode then
    Exit;

  ChildData.Status := Status;

    // 刷新
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedSetStatus }

procedure TvstLocalBackupDesDeletedSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TvstLocalBackupDesDeletedSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindChildNode then
    Exit;

  ChildData.Status := Status;

    // 刷新
  RefreshChildNode;
end;

{ TLVLocalBackupSourceRefreshNextSync }

procedure TLVLocalBackupSourceRefreshNextSync.Update;
begin
  inherited;
  VstLocalBackupSource.Refresh;
end;

end.
