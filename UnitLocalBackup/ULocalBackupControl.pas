unit ULocalBackupControl;

interface

uses UMyUtil, SysUtils, Classes, UFileBaseInfo, DateUtils;

type

{$Region ' 源路径 修改 ' }

    // 修改
  TLocalBackupSourceChangeHandle = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 读取
  TLocalBackupSourceReadHandle = class( TLocalBackupSourceChangeHandle )
  private
    PathType : string;
    IsBackupNow, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
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
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TLocalBackupSourceAddHandle = class( TLocalBackupSourceReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 修改 空间信息
  TLocalBackupSourceSpaceHandle = class( TLocalBackupSourceChangeHandle )
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$Region ' 修改 状态信息 ' }

    // 修改 状态信息
  TLocalBackupSourceStatusHandle = class( TLocalBackupSourceChangeHandle )
  private
    Status : string;
    ShowStatus : string;
  public
    procedure SetStatus( _Status : string );
    procedure SetShowStatus( _ShowStatus : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 修改 路径存在
  TLocalBackupSourceSetExistHandle = class( TLocalBackupSourceChangeHandle )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 备份路径 是否禁止备份
  TLocalBackupSourceSetIsDisableHandle = class( TLocalBackupSourceChangeHandle )
  private
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 设置 备份路径 是否不参与BackupUpNow
  TLocalBackupSourceSetIsBackupNowHandle = class( TLocalBackupSourceChangeHandle )
  private
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

  {$Region ' 设置同步时间 ' }

    // 上一次 同步时间
  TLocalBackupSourceSetLastSyncTimeHandle = class( TLocalBackupSourceChangeHandle )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 同步间隔
  TLocalBackupSourceSetAutoSyncHandle = class( TLocalBackupSourceChangeHandle )
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 刷新 下一次 同步时间
  TLocalBackupSourceRefreshNextSyncTimeHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' 设置同步删除信息 ' }

  TLocalBackupSourceSetDeleteHandle = class( TLocalBackupSourceChangeHandle )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeletedInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

    // 删除
  TLocalBackupSourceRemoveHandle = class( TLocalBackupSourceChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
    procedure RemoveFromFace;
  end;

    // 扫描完成
  TLocalBackupSourceAllScanCompletedHandle = class
  public
    procedure Update;
  private
    procedure AddToFace;
  end;

{$EndRegion}

{$Region ' 源路径 过滤器 修改 ' }

    // 父类
  TLocalBackupSourceFilterChangeHandle = class( TLocalBackupSourceChangeHandle )
  end;

      // 添加 过滤器 父类
  TLocalBackupSourceFilterWriteHandle = class( TLocalBackupSourceFilterChangeHandle )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
  end;

  {$Region ' 修改 包含 过滤器 ' }

    // 清空
  TLocalBackupSourceIncludeFilterClearHandle = class( TLocalBackupSourceFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // 读取 包含 过滤器
  TLocalBackupSourceIncludeFilterReadHandle = class( TLocalBackupSourceFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加 包含 过滤器
  TLocalBackupSourceIncludeFilterAddHandle = class( TLocalBackupSourceIncludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

  {$Region ' 修改 排除 过滤器 ' }

      // 清空
  TLocalBackupSourceExcludeFilterClearHandle = class( TLocalBackupSourceFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // 读取 排除 过滤器
  TLocalBackupSourceExcludeFilterReadHandle = class( TLocalBackupSourceFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加 排除 过滤器
  TLocalBackupSourceExcludeFilterAddHandle = class( TLocalBackupSourceExcludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}


{$EndRegion}

{$Region ' 源路径目标 修改 '}

    // 修改
  TLocalBackupSourceChangeDesHandle = class( TLocalBackupSourceChangeHandle )
  public
    DesPath : string;
  public
    procedure SetDesPath( _DesPath : string );
  end;

    // 读取
  TLocalBackupSourceReadDesHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    SourcePathType : string;
    SourceSize, CompltedSize : Int64;
  public
    IsKeepDeleted : Boolean;
    DeletedSpace : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure SetDeletedInfo( _IsKeepDeleted : Boolean; _DeletedSpace : Int64 );
    procedure SetSourcePathType( _SourcePathType : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TLocalBackupSourceAddDesHandle = class( TLocalBackupSourceReadDesHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 添加 已完成空间信息
  TLocalBackupSourceAddDesCompletedSpaceHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    AddCompltedSize : Int64;
  public
    procedure SetAddCompltedSize( _AddCompltedSize : Int64 );
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;


    // 设置空间信息
  TLocalBackupSourceSetDesSpaceHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    SourceSize, CompltedSize : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 添加 已回收 空间信息
  TLocalBackupSourceAddDesDeletedSpaceHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    AddRecycledSpace : Int64;
  public
    procedure SetAddRecycledSpace( _AddRecycledSpace : Int64 );
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;


    // 设置 已回收 空间信息
  TLocalBackupSourceSetDesDeletedSpaceHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    RecycledSpace : Int64;
  public
    procedure SetRecycledSpace( _RecycledSpace : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;


    // 删除
  TLocalBackupSourceRemoveDesHandle = class( TLocalBackupSourceChangeDesHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 源路径 处理 ' }

    // 备份指定路径
  TLocalSourceBackupHandle = class
  public
    SourcePath : string;
    DesPathList : TStringList;
  public
    IsShowFreeLimit : Boolean;
  public
    constructor Create( _SourcePath : string );
    procedure SetIsShowFreeLimit( _IsShowFreeLimit : Boolean );
    procedure Update;
    destructor Destroy; override;
  private
    function getIsEnable : Boolean;
    procedure ReadDesPathList;
    procedure AddToScanPath;
    procedure SetLastSyncTime;
  end;

{$EndRegion}

{$Region ' 源路径 添加 ' }

    // 添加 源路径
  TAddLocalBackupSorceControl = class
  public
    FullPath, PathType : string;
    IsDisable, IsBackupNow : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    constructor Create( _FullPath : string );
  protected
    procedure BackupNow;
  end;

    // 添加 源路径 默认配置
  TAddLocalBackupSourceDefaultControl = class( TAddLocalBackupSorceControl )
  public
    DesPathList : TStringList;
  public
    procedure SetDesPathList( _DesPathList : TStringList );
    procedure Update;
  private
    procedure FindGenernal;
    procedure AddSourcepath;
    procedure AddSourceFilter;
    procedure AddSourceDesPath;
  end;

    // 添加 源路径 指定配置
  TAddLocalBackupSourceConfigControl = class( TAddLocalBackupSorceControl )
  private
    BackupConfigInfo : TLocalBackupConfigInfo;
  public
    procedure SetBackupConfigInfo( _BackupConfigInfo : TLocalBackupConfigInfo );
    procedure Update;
  private
    procedure FindGenernal;
    procedure AddSourcepath;
    procedure AddSourceFilter;
    procedure AddSourceDesPath;
  private
    function IsPathFilter( FilterInfo : TFileFilterInfo ): Boolean;
  end;

{$EndRegion}

    // 界面控制器
  TMyLocalBackupSourceControl = class
  public
    procedure AddSourcePath( FullPath : string; DesPathList : TStringList );overload;
    procedure AddSourcePath( FullPath : string; BackupConfig : TLocalBackupConfigInfo );overload;
    procedure RemoveSourcePath( FullPath : string );
  public
    procedure AddSourceDesPath( FullPath, DesPath : string );
    procedure RemoveSourceDesPath( FullPath, DesPath : string );
  public
    procedure RemoveSourceDeletedPath( FullPath, DesPath : string );
  public
    procedure BackupNowClick;
    procedure BackupSelected( SourcePath : string );
    procedure SyncTimeBackup( SourcePath : string );
  end;


{$Region ' 目标路径 ' }

    // 辅助类
  MyDesPathUtil = class
  public
    class function getDesPath( SourPath, DesPath : string ): string;
  public
    class function getIsModify( DesPath : string ): Boolean;
    class function getIsExist( DesPath : string ): Boolean;
  end;


    // 修改 本地备份目标
  TLocalBackupDesChangeHandle = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

  {$Region ' 路径增删 ' }

    // 读取 本地备份目标
  TLocalBackupDesReadHandle = class( TLocalBackupDesChangeHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToFace;
    procedure AddToInfo;
  end;

    // 添加 本地备份目标
  TLocalBackupDesAddHandle = class( TLocalBackupDesReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 移除 本地备份目标
  TLocalBackupDesRemoveHandle = class( TLocalBackupDesChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 状态变化 ' }

    // 本地备份目标 是否存在
  TLocalBackupDesExistHandle = class( TLocalBackupDesChangeHandle )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 本地备份目标 是否可修改
  TLocalBackupDesModifyHandle = class( TLocalBackupDesChangeHandle )
  private
    IsModify : Boolean;
  public
    procedure SetIsModify( _IsModify : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 本地备份目标 空间不足
  TLocalBackupDesLackSpaceHandle = class( TLocalBackupDesChangeHandle )
  public
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

{$EndRegion}

    // 备份路径 总控制器
  TMyLocalBackupDesControl = class
  public
    procedure AddDesPath( DesPath : string );
    procedure RemoveDesPath( DesPath : string );
  end;

const
  LocalBackupScanType_AddBackupItem = 'AddBackupItem';
  LocalBackupScanType_ReadBackupItem = 'ReadBackupItem';

  LocalBackupScanType_FileModify = 'FileModify';
  LocalBackupScanType_BackupNowClick = 'BackupNowClick';
  LocalBackupScanType_SyncTime = 'SyncTime';

  LocalBackupScanType_AddDesItem = 'AddDesItem';
  LocalBackupScanType_DesBackupNow = 'DesBackupNow';

  WatchPathStatus_NotExist = 'Not Exist';

  DefaultPath_Des = 'BackupCow.LocalBackup';

var
  MyLocalBackupSourceControl : TMyLocalBackupSourceControl;
  MyLocalBackupDesControl : TMyLocalBackupDesControl;

implementation

uses ULocalBackupInfo, ULocalBackupXml, ULocalBackupFace, UMyBackupInfo,
     USettingInfo, UXmlUtil, UChangeInfo, ULocalBackupScan;

{ TLocalBackupSourceChangeHandle }

constructor TLocalBackupSourceChangeHandle.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLocalBackupSourceSpaceHandle }

procedure TLocalBackupSourceSpaceHandle.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceSpaceHandle.SetToFace;
var
  LvLocalBackupSourceSpace : TLvLocalBackupSourceSpace;
begin
  LvLocalBackupSourceSpace := TLvLocalBackupSourceSpace.Create( FullPath );
  LvLocalBackupSourceSpace.SetSpaceInfo( FileSize, FileCount );
  MyFaceChange.AddChange( LvLocalBackupSourceSpace );
end;

procedure TLocalBackupSourceSpaceHandle.SetToInfo;
var
  LocalBackupSourceSpaceInfo : TLocalBackupSourceSpaceInfo;
begin
  LocalBackupSourceSpaceInfo := TLocalBackupSourceSpaceInfo.Create( FullPath );
  LocalBackupSourceSpaceInfo.SetSpaceInfo( FileCount, FileSize );
  LocalBackupSourceSpaceInfo.Update;
  LocalBackupSourceSpaceInfo.Free;
end;

procedure TLocalBackupSourceSpaceHandle.SetToXml;
var
  LocalBackupSourceSpaceXml : TLocalBackupSourceSpaceXml;
begin
  LocalBackupSourceSpaceXml := TLocalBackupSourceSpaceXml.Create( FullPath );
  LocalBackupSourceSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyXmlChange.AddChange( LocalBackupSourceSpaceXml );
end;

procedure TLocalBackupSourceSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupSourceReadHandle }

procedure TLocalBackupSourceReadHandle.AddToFace;
var
  VstSelectLocalBackupSourceAddInfo : TVstSelectLocalBackupSourceAddInfo;
  LvLocalBackupSourceAdd : TLvLocalBackupSourceAdd;
  LvLocalBackupSourceProAdd : TLvLocalBackupSourceProAdd;
begin
    // 选择路径
  VstSelectLocalBackupSourceAddInfo := TVstSelectLocalBackupSourceAddInfo.Create( FullPath );
  MyFaceChange.AddChange( VstSelectLocalBackupSourceAddInfo );

    // 显示路径
  LvLocalBackupSourceAdd := TLvLocalBackupSourceAdd.Create( FullPath );
  LvLocalBackupSourceAdd.SetPathType( PathType );
  LvLocalBackupSourceAdd.SetBackupInfo( IsDisable );
  LvLocalBackupSourceAdd.SetAutoSyncInfo( IsAutoSync, LastSyncTime, NextSyncTime );
  LvLocalBackupSourceAdd.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LvLocalBackupSourceAdd.SetSpaceInfo( FileCount, FileSize );
  MyFaceChange.AddChange( LvLocalBackupSourceAdd );

    // 属性窗口
  LvLocalBackupSourceProAdd := TLvLocalBackupSourceProAdd.Create( FullPath );
  MyFaceChange.AddChange( LvLocalBackupSourceProAdd );
end;

procedure TLocalBackupSourceReadHandle.AddToInfo;
var
  LocalBackupSourceAddInfo : TLocalBackupSourceAddInfo;
begin
  LocalBackupSourceAddInfo := TLocalBackupSourceAddInfo.Create( FullPath );
  LocalBackupSourceAddInfo.SetPathType( PathType );
  LocalBackupSourceAddInfo.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceAddInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime, NextSyncTime );
  LocalBackupSourceAddInfo.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceAddInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceAddInfo.SetSpaceInfo( FileCount, FileSize );
  LocalBackupSourceAddInfo.Update;
  LocalBackupSourceAddInfo.Free;
end;

procedure TLocalBackupSourceReadHandle.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceReadHandle.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceReadHandle.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceReadHandle.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLocalBackupSourceReadHandle.SetSpaceInfo(_FileCount: Integer;
  _FileSize : Int64);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLocalBackupSourceReadHandle.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceReadHandle.Update;
var
  SyncMins : Integer;
begin
    // 计算下次 同步时间
  SyncMins := TimeTypeUtil.getMins( SyncTimeType, SyncTimeValue );
  NextSyncTime := IncMinute( LastSyncTime, SyncMins );

    // 添加信息
  AddToInfo;
  AddToFace;
end;

{ TLocalBackupSourceAddHandle }

procedure TLocalBackupSourceAddHandle.AddToXml;
var
  LocalBackupSourceAddXml : TLocalBackupSourceAddXml;
begin
  LocalBackupSourceAddXml := TLocalBackupSourceAddXml.Create( FullPath );
  LocalBackupSourceAddXml.SetPathType( PathType );
  LocalBackupSourceAddXml.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceAddXml.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupSourceAddXml.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceAddXml.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceAddXml.SetSpaceInfo( FileCount, FileSize );
  MyXmlChange.AddChange( LocalBackupSourceAddXml );
end;

procedure TLocalBackupSourceAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TLocalBackupSourceRemoveHandle }

procedure TLocalBackupSourceRemoveHandle.RemoveFromFace;
var
  VstSelectLocalBackupSourceRemoveInfo : TVstSelectLocalBackupSourceRemoveInfo;
  LvLocalBackupSourceRemove : TLvLocalBackupSourceRemove;
  LvLocalBackupSourceProRemove : TLvLocalBackupSourceProRemove;
begin
  VstSelectLocalBackupSourceRemoveInfo := TVstSelectLocalBackupSourceRemoveInfo.Create( FullPath );
  MyFaceChange.AddChange( VstSelectLocalBackupSourceRemoveInfo );

  LvLocalBackupSourceRemove := TLvLocalBackupSourceRemove.Create( FullPath );
  MyFaceChange.AddChange( LvLocalBackupSourceRemove );

  LvLocalBackupSourceProRemove := TLvLocalBackupSourceProRemove.Create( FullPath );
  MyFaceChange.AddChange( LvLocalBackupSourceProRemove );
end;

procedure TLocalBackupSourceRemoveHandle.RemoveFromInfo;
var
  LocalBackupSourceRemoveInfo : TLocalBackupSourceRemoveInfo;
begin
  LocalBackupSourceRemoveInfo := TLocalBackupSourceRemoveInfo.Create( FullPath );
  LocalBackupSourceRemoveInfo.Update;
  LocalBackupSourceRemoveInfo.Free;
end;

procedure TLocalBackupSourceRemoveHandle.RemoveFromXml;
var
  LocalBackupSourceRemoveXml : TLocalBackupSourceRemoveXml;
begin
  LocalBackupSourceRemoveXml := TLocalBackupSourceRemoveXml.Create( FullPath );
  MyXmlChange.AddChange( LocalBackupSourceRemoveXml );
end;

procedure TLocalBackupSourceRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
  RemoveFromFace;
end;

{ TLocalBackupSourceStatusHandle }

procedure TLocalBackupSourceStatusHandle.SetShowStatus(_ShowStatus: string);
begin
  ShowStatus := _ShowStatus;
end;

procedure TLocalBackupSourceStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TLocalBackupSourceStatusHandle.SetToFace;
var
  LvLocalBackupStatus : TLvLocalBackupStatus;
begin
  LvLocalBackupStatus := TLvLocalBackupStatus.Create( FullPath );
  LvLocalBackupStatus.SetStatus( Status );
  LvLocalBackupStatus.SetShowStatus( ShowStatus );
  MyFaceChange.AddChange( LvLocalBackupStatus );
end;

procedure TLocalBackupSourceStatusHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupSourceScanCompletedHandle }

procedure TLocalBackupSourceAllScanCompletedHandle.AddToFace;
var
  LocalBackupFaceScanCompleted : TLocalBackupFaceScanCompleted;
begin
  LocalBackupFaceScanCompleted := TLocalBackupFaceScanCompleted.Create;
  MyFaceChange.AddChange( LocalBackupFaceScanCompleted );
end;

procedure TLocalBackupSourceAllScanCompletedHandle.Update;
begin
  AddToFace;
end;

{ TMyLocalBackupSourceControl }

procedure TMyLocalBackupSourceControl.AddSourcePath(FullPath: string;
  DesPathList : TStringList);
var
  AddLocalBackupSourceDefaultControl : TAddLocalBackupSourceDefaultControl;
begin
  AddLocalBackupSourceDefaultControl := TAddLocalBackupSourceDefaultControl.Create( FullPath );
  AddLocalBackupSourceDefaultControl.SetDesPathList( DesPathList );
  AddLocalBackupSourceDefaultControl.Update;
  AddLocalBackupSourceDefaultControl.Free;
end;

procedure TMyLocalBackupSourceControl.AddSourceDesPath(FullPath,
  DesPath: string);
var
  SourceType : string;
  IsKeepDeleted : Boolean;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  SourceType := MyFilePath.getPathType( FullPath );
  IsKeepDeleted := MyLocalBackupSourceReadUtil.getIsKeepDeleted( FullPath );

  LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( FullPath );
  LocalBackupSourceAddDesHandle.SetDesPath( DesPath );
  LocalBackupSourceAddDesHandle.SetSpaceInfo( 0, 0 );
  LocalBackupSourceAddDesHandle.SetSourcePathType( SourceType );
  LocalBackupSourceAddDesHandle.SetDeletedInfo( IsKeepDeleted, 0 );
  LocalBackupSourceAddDesHandle.Update;
  LocalBackupSourceAddDesHandle.Free;
end;

procedure TMyLocalBackupSourceControl.AddSourcePath(FullPath: string;
  BackupConfig: TLocalBackupConfigInfo);
var
  AddLocalBackupSourceConfigControl : TAddLocalBackupSourceConfigControl;
begin
  AddLocalBackupSourceConfigControl := TAddLocalBackupSourceConfigControl.Create( FullPath );
  AddLocalBackupSourceConfigControl.SetBackupConfigInfo( BackupConfig );
  AddLocalBackupSourceConfigControl.Update;
  AddLocalBackupSourceConfigControl.Free;
end;

procedure TMyLocalBackupSourceControl.BackupNowClick;
var
  BackupNowPathList : TStringList;
  i : Integer;
begin
    // 读取 参与 BackupNow 的 源路径
  BackupNowPathList := MyLocalBackupSourceReadUtil.getBackupNowPathList;
  for i := 0 to BackupNowPathList.Count - 1 do
    BackupSelected( BackupNowPathList[i] );
  BackupNowPathList.Free;
end;

procedure TMyLocalBackupSourceControl.BackupSelected(SourcePath: string);
var
  LocalSourceBackupHandle : TLocalSourceBackupHandle;
begin
  LocalSourceBackupHandle := TLocalSourceBackupHandle.Create( SourcePath );
  LocalSourceBackupHandle.SetIsShowFreeLimit( True );
  LocalSourceBackupHandle.Update;
  LocalSourceBackupHandle.Free;
end;

procedure TMyLocalBackupSourceControl.RemoveSourceDeletedPath(FullPath,
  DesPath: string);
var
  LocalBackupSourceSetDeleteHandle : TLocalBackupSourceSetDeleteHandle;
begin
  LocalBackupSourceSetDeleteHandle := TLocalBackupSourceSetDeleteHandle.Create( FullPath );
  LocalBackupSourceSetDeleteHandle.SetDeletedInfo( False, 3 );
  LocalBackupSourceSetDeleteHandle.Update;
  LocalBackupSourceSetDeleteHandle.Free;
end;

procedure TMyLocalBackupSourceControl.RemoveSourceDesPath(FullPath,
  DesPath: string);
var
  LocalBackupSourceRemoveDesHandle : TLocalBackupSourceRemoveDesHandle;
begin
  LocalBackupSourceRemoveDesHandle := TLocalBackupSourceRemoveDesHandle.Create( FullPath );
  LocalBackupSourceRemoveDesHandle.SetDesPath( DesPath );
  LocalBackupSourceRemoveDesHandle.Update;
  LocalBackupSourceRemoveDesHandle.Free;
end;

procedure TMyLocalBackupSourceControl.RemoveSourcePath(FullPath: string);
var
  LocalBackupSourceRemoveHandle : TLocalBackupSourceRemoveHandle;
begin
  LocalBackupSourceRemoveHandle := TLocalBackupSourceRemoveHandle.Create( FullPath );
  LocalBackupSourceRemoveHandle.Update;
  LocalBackupSourceRemoveHandle.Free;
end;

procedure TMyLocalBackupSourceControl.SyncTimeBackup(SourcePath: string);
var
  LocalSourceBackupHandle : TLocalSourceBackupHandle;
begin
  LocalSourceBackupHandle := TLocalSourceBackupHandle.Create( SourcePath );
  LocalSourceBackupHandle.SetIsShowFreeLimit( False );
  LocalSourceBackupHandle.Update;
  LocalSourceBackupHandle.Free;
end;

{ TBackupDestinationChangeHandle }

constructor TLocalBackupDesChangeHandle.Create(_FullPath: string);
begin
  FullPath := _FullPath
end;

{ TBackupDestinationReadHandle }

procedure TLocalBackupDesReadHandle.AddToFace;
var
  VstLocalBackupDesAdd : TVstLocalBackupDesAdd;
  LvLocalBackupDesProAdd : TLvLocalBackupDesProAdd;
begin
  VstLocalBackupDesAdd := TVstLocalBackupDesAdd.Create( FullPath );
  MyFaceChange.AddChange( VstLocalBackupDesAdd );

  LvLocalBackupDesProAdd := TLvLocalBackupDesProAdd.Create( FullPath );
  MyFaceChange.AddChange( LvLocalBackupDesProAdd );
end;

procedure TLocalBackupDesReadHandle.AddToInfo;
var
  MyDesPathAddInfo : TLocalBackupDesAddInfo;
begin
  MyDesPathAddInfo := TLocalBackupDesAddInfo.Create( FullPath );
  MyDesPathAddInfo.Update;
  MyDesPathAddInfo.Free;
end;

procedure TLocalBackupDesReadHandle.Update;
begin
    // 添加 内存数据结构
  AddToInfo;

    // 添加 界面
  AddToFace;
end;

{ TBackupDestinationAddHandle }

procedure TLocalBackupDesAddHandle.AddToXml;
var
  MyDesPathAddXml : TLocalBackupDesAddXml;
begin
  MyDesPathAddXml := TLocalBackupDesAddXml.Create( FullPath );
  MyXmlChange.AddChange( MyDesPathAddXml );
end;

procedure TLocalBackupDesAddHandle.Update;
begin
  inherited;

    // 添加 Xml 数据信息
  AddToXml;
end;

{ TBackupDestinationRemoveHandle }

procedure TLocalBackupDesRemoveHandle.RemoveFromFace;
var
  VstLocalBackupDesRemove : TVstLocalBackupDesRemove;
  LvLocalBackupDesProRemove : TLvLocalBackupDesProRemove;
begin
  VstLocalBackupDesRemove := TVstLocalBackupDesRemove.Create( FullPath );
  MyFaceChange.AddChange( VstLocalBackupDesRemove );

  LvLocalBackupDesProRemove := TLvLocalBackupDesProRemove.Create( FullPath );
  MyFaceChange.AddChange( LvLocalBackupDesProRemove );
end;

procedure TLocalBackupDesRemoveHandle.RemoveFromInfo;
var
  MyDesPathRemoveInfo : TLocalBackupDesRemoveInfo;
begin
  MyDesPathRemoveInfo := TLocalBackupDesRemoveInfo.Create( FullPath );
  MyDesPathRemoveInfo.Update;
  MyDesPathRemoveInfo.Free;
end;

procedure TLocalBackupDesRemoveHandle.RemoveFromXml;
var
  MyDesPathRemoveXml : TLocalBackupDesRemoveXml;
begin
  MyDesPathRemoveXml := TLocalBackupDesRemoveXml.Create( FullPath );
  MyXmlChange.AddChange( MyDesPathRemoveXml );
end;

procedure TLocalBackupDesRemoveHandle.Update;
begin
  RemoveFromFace;

  RemoveFromInfo;

  RemoveFromXml;
end;

{ TBackupDestinationWritableHandle }

procedure TLocalBackupDesExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TLocalBackupDesExistHandle.SetToFace;
var
  VstLocalBackupDesIsExist : TVstLocalBackupDesIsExist;
begin
  VstLocalBackupDesIsExist := TVstLocalBackupDesIsExist.Create( FullPath );
  VstLocalBackupDesIsExist.SetIsExist( IsExist );
  MyFaceChange.AddChange( VstLocalBackupDesIsExist );
end;

procedure TLocalBackupDesExistHandle.Update;
begin
  SetToFace;
end;

{ TBackupDesUnModifiableHandle }

procedure TLocalBackupDesModifyHandle.SetIsModify(_IsModify: Boolean);
begin
  IsModify := _IsModify;
end;

procedure TLocalBackupDesModifyHandle.SetToFace;
var
  VstLocalBackupDesIsModify : TVstLocalBackupDesIsModify;
begin
  VstLocalBackupDesIsModify := TVstLocalBackupDesIsModify.Create( FullPath );
  VstLocalBackupDesIsModify.SetIsModify( IsModify );
  MyFaceChange.AddChange( VstLocalBackupDesIsModify );
end;

procedure TLocalBackupDesModifyHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupDesLackSpaceHandle }

procedure TLocalBackupDesLackSpaceHandle.SetIsLackSpace(_IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TLocalBackupDesLackSpaceHandle.SetToFace;
var
  VstLocalBackupDesIsLackSpace : TVstLocalBackupDesIsLackSpace;
begin
  VstLocalBackupDesIsLackSpace := TVstLocalBackupDesIsLackSpace.Create( FullPath );
  VstLocalBackupDesIsLackSpace.SetIsLackSpace( IsLackSpace );
  MyFaceChange.AddChange( VstLocalBackupDesIsLackSpace );
end;

procedure TLocalBackupDesLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TMyLocalBackupDesControl }

procedure TMyLocalBackupDesControl.AddDesPath(DesPath: string);
var
  BackupDestinationAddHandle : TLocalBackupDesAddHandle;
begin
  BackupDestinationAddHandle := TLocalBackupDesAddHandle.Create( DesPath );
  BackupDestinationAddHandle.Update;
  BackupDestinationAddHandle.Free;
end;

procedure TMyLocalBackupDesControl.RemoveDesPath(DesPath: string);
var
  BackupDestinationRemoveHandle : TLocalBackupDesRemoveHandle;
begin
  BackupDestinationRemoveHandle := TLocalBackupDesRemoveHandle.Create( DesPath );
  BackupDestinationRemoveHandle.Update;
  BackupDestinationRemoveHandle.Free;
end;

{ MyDesPathUtil }

class function MyDesPathUtil.getDesPath(SourPath, DesPath: string): string;
begin
  Result := MyFilePath.getPath( DesPath ) + MyFilePath.getDownloadPath( SourPath );
end;

class function MyDesPathUtil.getIsExist(DesPath: string): Boolean;
begin
  if MyNetworkFolderUtil.IsNetworkFolder( DesPath ) then
    Result := MyNetworkFolderUtil.NetworkFolderExist( DesPath )
  else
    Result := DirectoryExists( DesPath );
end;

class function MyDesPathUtil.getIsModify(DesPath: string): Boolean;
var
  FilePath : string;
  h : Integer;
begin
  Result := False;

  FilePath := MyFilePath.getPath( DesPath ) + 'BackupCow_TestModify.cy';
  if not FileExists( FilePath ) then
  begin
    h := FileCreate( FilePath );
    if h = -1 then  // 创建失败
      Exit;
    FileClose( h );
  end;
  Result := SysUtils.DeleteFile( FilePath ); // 返回是否删除
end;


{ TLocalBackupSourceSetExistHandle }

procedure TLocalBackupSourceSetExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TLocalBackupSourceSetExistHandle.SetToFace;
var
  LvLocalBackupExist : TLvLocalBackupExist;
begin
  LvLocalBackupExist := TLvLocalBackupExist.Create( FullPath );
  LvLocalBackupExist.SetIsExist( IsExist );
  MyFaceChange.AddChange( LvLocalBackupExist );
end;

procedure TLocalBackupSourceSetExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupSourceChangeDesHandle }

procedure TLocalBackupSourceChangeDesHandle.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TLocalBackupSourceReadDesHandle }

procedure TLocalBackupSourceReadDesHandle.AddToFace;
var
  vstLocalBackupDesChildAdd : TvstLocalBackupDesChildAdd;
  vstLocalBackupDesDeletedAdd : TvstLocalBackupDesDeletedAdd;
begin
  vstLocalBackupDesChildAdd := TvstLocalBackupDesChildAdd.Create( DesPath );
  vstLocalBackupDesChildAdd.SetChildPath( FullPath );
  vstLocalBackupDesChildAdd.SetPathType( SourcePathType );
  vstLocalBackupDesChildAdd.SetSpaceInfo( SourceSize, CompltedSize );
  MyFaceChange.AddChange( vstLocalBackupDesChildAdd );

    // 不支持删除
  if not IsKeepDeleted then
    Exit;

    // 添加 回收目录
  vstLocalBackupDesDeletedAdd := TvstLocalBackupDesDeletedAdd.Create( DesPath );
  vstLocalBackupDesDeletedAdd.SetChildPath( FullPath );
  vstLocalBackupDesDeletedAdd.SetPathType( SourcePathType );
  vstLocalBackupDesDeletedAdd.SetSpaceInfo( DeletedSpace );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedAdd );
end;

procedure TLocalBackupSourceReadDesHandle.AddToInfo;
var
  LocalBackupSourceAddDesInfo : TLocalBackupSourceAddDesInfo;
begin
  LocalBackupSourceAddDesInfo := TLocalBackupSourceAddDesInfo.Create( FullPath );
  LocalBackupSourceAddDesInfo.SetDesPath( DesPath );
  LocalBackupSourceAddDesInfo.SetSpaceInfo( SourceSize, CompltedSize );
  LocalBackupSourceAddDesInfo.SetDeletedSpace( DeletedSpace );
  LocalBackupSourceAddDesInfo.Update;
  LocalBackupSourceAddDesInfo.Free;
end;

procedure TLocalBackupSourceReadDesHandle.SetDeletedInfo(_IsKeepDeleted : Boolean;
  _DeletedSpace: Int64);
begin
  IsKeepDeleted := _IsKeepDeleted;
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSourceReadDesHandle.SetSourcePathType(
  _SourcePathType: string);
begin
  SourcePathType := _SourcePathType;
end;

procedure TLocalBackupSourceReadDesHandle.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceReadDesHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TLocalBackupSourceAddDesHandle }

procedure TLocalBackupSourceAddDesHandle.AddToXml;
var
  LocalBackupSourceAddDesXml : TLocalBackupSourceAddDesXml;
begin
  LocalBackupSourceAddDesXml := TLocalBackupSourceAddDesXml.Create( FullPath );
  LocalBackupSourceAddDesXml.SetDesPath( DesPath );
  LocalBackupSourceAddDesXml.SetSpaceInfo( SourceSize, CompltedSize );
  LocalBackupSourceAddDesXml.SetDeletedSpace( DeletedSpace );
  MyXmlChange.AddChange( LocalBackupSourceAddDesXml );
end;

procedure TLocalBackupSourceAddDesHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupSourceRemoveDesHandle }

procedure TLocalBackupSourceRemoveDesHandle.RemoveFromFace;
var
  vstLocalBackupDesChildRemove : TvstLocalBackupDesChildRemove;
  vstLocalBackupDesDeletedRemove : TvstLocalBackupDesDeletedRemove;
begin
  vstLocalBackupDesChildRemove := TvstLocalBackupDesChildRemove.Create( DesPath );
  vstLocalBackupDesChildRemove.SetChildPath( FullPath );
  MyFaceChange.AddChange( vstLocalBackupDesChildRemove );

  vstLocalBackupDesDeletedRemove := TvstLocalBackupDesDeletedRemove.Create( DesPath );
  vstLocalBackupDesDeletedRemove.SetChildPath( FullPath );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedRemove );
end;

procedure TLocalBackupSourceRemoveDesHandle.RemoveFromInfo;
var
  LocalBackupSourceRemoveDesInfo : TLocalBackupSourceRemoveDesInfo;
begin
  LocalBackupSourceRemoveDesInfo := TLocalBackupSourceRemoveDesInfo.Create( FullPath );
  LocalBackupSourceRemoveDesInfo.SetDesPath( DesPath );
  LocalBackupSourceRemoveDesInfo.Update;
  LocalBackupSourceRemoveDesInfo.Free;
end;

procedure TLocalBackupSourceRemoveDesHandle.RemoveFromXml;
var
  LocalBackupSourceRemoveDesXml : TLocalBackupSourceRemoveDesXml;
begin
  LocalBackupSourceRemoveDesXml := TLocalBackupSourceRemoveDesXml.Create( FullPath );
  LocalBackupSourceRemoveDesXml.SetDesPath( DesPath );
  MyXmlChange.AddChange( LocalBackupSourceRemoveDesXml );
end;

procedure TLocalBackupSourceRemoveDesHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TLocalBackupSourceSetDesSpaceHandle }

procedure TLocalBackupSourceSetDesSpaceHandle.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceSetDesSpaceHandle.SetToFace;
var
  vstLocalBackupDesChildSetSpace : TvstLocalBackupDesChildSetSpace;
begin
  vstLocalBackupDesChildSetSpace := TvstLocalBackupDesChildSetSpace.Create( DesPath );
  vstLocalBackupDesChildSetSpace.SetChildPath( FullPath );
  vstLocalBackupDesChildSetSpace.SetSourceSize( SourceSize );
  vstLocalBackupDesChildSetSpace.SetCompletedSize( CompltedSize );
  MyFaceChange.AddChange( vstLocalBackupDesChildSetSpace );
end;

procedure TLocalBackupSourceSetDesSpaceHandle.SetToInfo;
var
  LocalBackupSourceSetDesSpaceInfo : TLocalBackupSourceSetDesSpaceInfo;
begin
  LocalBackupSourceSetDesSpaceInfo := TLocalBackupSourceSetDesSpaceInfo.Create( FullPath );
  LocalBackupSourceSetDesSpaceInfo.SetDesPath( DesPath );
  LocalBackupSourceSetDesSpaceInfo.SetSpaceInfo( SourceSize, CompltedSize );
  LocalBackupSourceSetDesSpaceInfo.Update;
  LocalBackupSourceSetDesSpaceInfo.Free;
end;

procedure TLocalBackupSourceSetDesSpaceHandle.SetToXml;
var
  LocalBackupSourceSetDesSpaceXml : TLocalBackupSourceSetDesSpaceXml;
begin
  LocalBackupSourceSetDesSpaceXml := TLocalBackupSourceSetDesSpaceXml.Create( FullPath );
  LocalBackupSourceSetDesSpaceXml.SetDesPath( DesPath );
  LocalBackupSourceSetDesSpaceXml.SetSpaceInfo( SourceSize, CompltedSize );
  MyXmlChange.AddChange( LocalBackupSourceSetDesSpaceXml );
end;

procedure TLocalBackupSourceSetDesSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupSourceAddDesCompletedSpaceHandle }

procedure TLocalBackupSourceAddDesCompletedSpaceHandle.AddToFace;
var
  vstLocalBackupDesChildAddSpace : TvstLocalBackupDesChildAddSpace;
begin
  vstLocalBackupDesChildAddSpace := TvstLocalBackupDesChildAddSpace.Create( DesPath );
  vstLocalBackupDesChildAddSpace.SetChildPath( FullPath );
  vstLocalBackupDesChildAddSpace.SetAddSize( AddCompltedSize );
  MyFaceChange.AddChange( vstLocalBackupDesChildAddSpace );
end;

procedure TLocalBackupSourceAddDesCompletedSpaceHandle.AddToInfo;
var
  LocalBackupSourceAddDesCompletedSpaceInfo : TLocalBackupSourceAddDesCompletedSpaceInfo;
begin
  LocalBackupSourceAddDesCompletedSpaceInfo := TLocalBackupSourceAddDesCompletedSpaceInfo.Create( FullPath );
  LocalBackupSourceAddDesCompletedSpaceInfo.SetDesPath( DesPath );
  LocalBackupSourceAddDesCompletedSpaceInfo.SetAddCompltedSize( AddCompltedSize );
  LocalBackupSourceAddDesCompletedSpaceInfo.Update;
  LocalBackupSourceAddDesCompletedSpaceInfo.Free;
end;

procedure TLocalBackupSourceAddDesCompletedSpaceHandle.AddToXml;
var
  LocalBackupSourceAddDesCompletedSpaceXml : TLocalBackupSourceAddDesCompletedSpaceXml;
begin
  LocalBackupSourceAddDesCompletedSpaceXml := TLocalBackupSourceAddDesCompletedSpaceXml.Create( FullPath );
  LocalBackupSourceAddDesCompletedSpaceXml.SetDesPath( DesPath );
  LocalBackupSourceAddDesCompletedSpaceXml.SetAddCompltedSize( AddCompltedSize );
  MyXmlChange.AddChange( LocalBackupSourceAddDesCompletedSpaceXml );
end;

procedure TLocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize(
  _AddCompltedSize: Int64);
begin
  AddCompltedSize := _AddCompltedSize;
end;

procedure TLocalBackupSourceAddDesCompletedSpaceHandle.Update;
begin
  AddToInfo;
  AddToFace;
  AddToXml;
end;

{ TAddLocalBackupSourceDefaultControl }

procedure TAddLocalBackupSourceDefaultControl.AddSourceDesPath;
var
  i : Integer;
  DesPath : string;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i];

    LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( FullPath );
    LocalBackupSourceAddDesHandle.SetSourcePathType( PathType );
    LocalBackupSourceAddDesHandle.SetDesPath( DesPath );
    LocalBackupSourceAddDesHandle.SetSpaceInfo( 0, 0 );
    LocalBackupSourceAddDesHandle.SetDeletedInfo( IsKeepDeleted, 0 );
    LocalBackupSourceAddDesHandle.Update;
    LocalBackupSourceAddDesHandle.Free;
  end;
end;

procedure TAddLocalBackupSourceDefaultControl.AddSourceFilter;
var
  LocalBackupSourceExcludeFilterAddHandle : TLocalBackupSourceExcludeFilterAddHandle;
begin
    // 过滤 隐藏文件
  LocalBackupSourceExcludeFilterAddHandle := TLocalBackupSourceExcludeFilterAddHandle.Create( FullPath );
  LocalBackupSourceExcludeFilterAddHandle.SetFilterInfo( FilterType_SystemFile, '' );
  LocalBackupSourceExcludeFilterAddHandle.Update;
  LocalBackupSourceExcludeFilterAddHandle.Free;

    // 过滤 系统文件
  LocalBackupSourceExcludeFilterAddHandle := TLocalBackupSourceExcludeFilterAddHandle.Create( FullPath );
  LocalBackupSourceExcludeFilterAddHandle.SetFilterInfo( FilterType_HiddenFile, '' );
  LocalBackupSourceExcludeFilterAddHandle.Update;
  LocalBackupSourceExcludeFilterAddHandle.Free;
end;

procedure TAddLocalBackupSourceDefaultControl.AddSourcepath;
var
  LocalBackupSourceAddHandle : TLocalBackupSourceAddHandle;
begin
  LocalBackupSourceAddHandle := TLocalBackupSourceAddHandle.Create( FullPath );
  LocalBackupSourceAddHandle.SetPathType( PathType );
  LocalBackupSourceAddHandle.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupSourceAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceAddHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceAddHandle.SetSpaceInfo( 0, 0 );
  LocalBackupSourceAddHandle.Update;
  LocalBackupSourceAddHandle.Free;
end;

procedure TAddLocalBackupSourceDefaultControl.FindGenernal;
begin
    // 路径类型
  PathType := MyFilePath.getPathType( FullPath );

    // 基本信息
  IsDisable := False;
  IsBackupNow := True;
  IsAutoSync := SyncTimeSettingInfo.IsAutoSync;
  SyncTimeType := SyncTimeSettingInfo.TimeType;
  SyncTimeValue := SyncTimeSettingInfo.SyncTime;
  IsKeepDeleted := False;
  KeepEditionCount := 3;
  LastSyncTime := Now;
end;

procedure TAddLocalBackupSourceDefaultControl.SetDesPathList(
  _DesPathList: TStringList);
begin
  DesPathList := _DesPathList;
end;

procedure TAddLocalBackupSourceDefaultControl.Update;
begin
  FindGenernal;
  AddSourcepath;
  AddSourceFilter;
  AddSourceDesPath;
  BackupNow;
end;

{ TAddLocalBackupSorceControl }

procedure TAddLocalBackupSorceControl.BackupNow;
begin
  MyLocalBackupSourceControl.BackupSelected( FullPath );
end;

constructor TAddLocalBackupSorceControl.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TAddLocalBackupSourceConfigControl }

procedure TAddLocalBackupSourceConfigControl.AddSourceDesPath;
var
  DesPathList : TStringList;
  i : Integer;
  DesPath : string;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  DesPathList := BackupConfigInfo.DesPathList;
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i];

    LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( FullPath );
    LocalBackupSourceAddDesHandle.SetSourcePathType( PathType );
    LocalBackupSourceAddDesHandle.SetDesPath( DesPath );
    LocalBackupSourceAddDesHandle.SetSpaceInfo( 0, 0 );
    LocalBackupSourceAddDesHandle.SetDeletedInfo( IsKeepDeleted, 0 );
    LocalBackupSourceAddDesHandle.Update;
    LocalBackupSourceAddDesHandle.Free;
  end;
end;

procedure TAddLocalBackupSourceConfigControl.AddSourceFilter;
var
  IncludeFileFilterList : TFileFilterList;
  ExcludeFileFilterList : TFileFilterList;
  i : Integer;
  FilterInfo : TFileFilterInfo;
  LocalBackupSourceIncludeFilterAddHandle : TLocalBackupSourceIncludeFilterAddHandle;
  LocalBackupSourceExcludeFilterAddHandle : TLocalBackupSourceExcludeFilterAddHandle;
begin
  IncludeFileFilterList := BackupConfigInfo.IncludeFilterList;
  ExcludeFileFilterList := BackupConfigInfo.ExcludeFilterList;

    // 包含 过滤器
  for i := 0 to IncludeFileFilterList.Count - 1 do
  begin
    FilterInfo := IncludeFileFilterList[i];

      // 不是当前路径的 过滤器
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // 添加 过滤器
    LocalBackupSourceIncludeFilterAddHandle := TLocalBackupSourceIncludeFilterAddHandle.Create( FullPath );
    LocalBackupSourceIncludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    LocalBackupSourceIncludeFilterAddHandle.Update;
    LocalBackupSourceIncludeFilterAddHandle.Free;
  end;

    // 排除 过滤器
  for i := 0 to ExcludeFileFilterList.Count - 1 do
  begin
    FilterInfo := ExcludeFileFilterList[i];

        // 不是当前路径的 过滤器
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // 添加 过滤器
    LocalBackupSourceExcludeFilterAddHandle := TLocalBackupSourceExcludeFilterAddHandle.Create( FullPath );
    LocalBackupSourceExcludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    LocalBackupSourceExcludeFilterAddHandle.Update;
    LocalBackupSourceExcludeFilterAddHandle.Free;
  end;
end;

procedure TAddLocalBackupSourceConfigControl.AddSourcepath;
var
  LocalBackupSourceAddHandle : TLocalBackupSourceAddHandle;
begin
  LocalBackupSourceAddHandle := TLocalBackupSourceAddHandle.Create( FullPath );
  LocalBackupSourceAddHandle.SetPathType( PathType );
  LocalBackupSourceAddHandle.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupSourceAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceAddHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceAddHandle.SetSpaceInfo( 0, 0 );
  LocalBackupSourceAddHandle.Update;
  LocalBackupSourceAddHandle.Free;
end;

procedure TAddLocalBackupSourceConfigControl.FindGenernal;
begin
    // 路径类型
  PathType := MyFilePath.getPathType( FullPath );

    // 基本信息
  IsDisable := BackupConfigInfo.IsDisable;
  IsBackupNow := BackupConfigInfo.IsBackupupNow;
  IsAutoSync := BackupConfigInfo.IsAuctoSync;
  SyncTimeType := BackupConfigInfo.SyncTimeType;
  SyncTimeValue := BackupConfigInfo.SyncTimeValue;
  IsKeepDeleted := BackupConfigInfo.IsKeepDeleted;
  KeepEditionCount := BackupConfigInfo.KeepEditionCount;
  LastSyncTime := Now;
end;

function TAddLocalBackupSourceConfigControl.IsPathFilter(
  FilterInfo: TFileFilterInfo): Boolean;
begin
  Result := True;
  if FilterInfo.FilterType <> FilterType_Path then
    Exit;

  Result := MyMatchMask.CheckEqualsOrChild( FilterInfo.FilterStr, FullPath );
end;

procedure TAddLocalBackupSourceConfigControl.SetBackupConfigInfo(
  _BackupConfigInfo: TLocalBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TAddLocalBackupSourceConfigControl.Update;
begin
  FindGenernal;
  AddSourcepath;
  AddSourceFilter;
  AddSourceDesPath;
  BackupNow;
end;

{ TLocalBackupSourceFilterWriteHandle }

procedure TLocalBackupSourceFilterWriteHandle.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

{ TLocalBackupSourceIncludeFilterClearHandle }

procedure TLocalBackupSourceIncludeFilterClearHandle.ClearToInfo;
var
  LocalBackupSourceIncludeFilterClearInfo : TLocalBackupSourceIncludeFilterClearInfo;
begin
  LocalBackupSourceIncludeFilterClearInfo := TLocalBackupSourceIncludeFilterClearInfo.Create( FullPath );
  LocalBackupSourceIncludeFilterClearInfo.Update;
  LocalBackupSourceIncludeFilterClearInfo.Free;
end;

procedure TLocalBackupSourceIncludeFilterClearHandle.ClearToXml;
var
  LocalBackupSourceIncludeFilterClearXml : TLocalBackupSourceIncludeFilterClearXml;
begin
  LocalBackupSourceIncludeFilterClearXml := TLocalBackupSourceIncludeFilterClearXml.Create( FullPath );
  MyXmlChange.AddChange( LocalBackupSourceIncludeFilterClearXml );
end;

procedure TLocalBackupSourceIncludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TLocalBackupSourceIncludeFilterReadHandle }

procedure TLocalBackupSourceIncludeFilterReadHandle.AddToInfo;
var
  LocalBackupSourceIncludeFilterAddInfo : TLocalBackupSourceIncludeFilterAddInfo;
begin
  LocalBackupSourceIncludeFilterAddInfo := TLocalBackupSourceIncludeFilterAddInfo.Create( FullPath );
  LocalBackupSourceIncludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceIncludeFilterAddInfo.Update;
  LocalBackupSourceIncludeFilterAddInfo.Free;
end;

procedure TLocalBackupSourceIncludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TLocalBackupSourceIncludeFilterAddHandle }

procedure TLocalBackupSourceIncludeFilterAddHandle.AddToXml;
var
  LocalBackupSourceIncludeFilterAddXml : TLocalBackupSourceIncludeFilterAddXml;
begin
  LocalBackupSourceIncludeFilterAddXml := TLocalBackupSourceIncludeFilterAddXml.Create( FullPath );
  LocalBackupSourceIncludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyXmlChange.AddChange( LocalBackupSourceIncludeFilterAddXml );
end;

procedure TLocalBackupSourceIncludeFilterAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupSourceExcludeFilterClearHandle }

procedure TLocalBackupSourceExcludeFilterClearHandle.ClearToInfo;
var
  LocalBackupSourceExcludeFilterClearInfo : TLocalBackupSourceExcludeFilterClearInfo;
begin
  LocalBackupSourceExcludeFilterClearInfo := TLocalBackupSourceExcludeFilterClearInfo.Create( FullPath );
  LocalBackupSourceExcludeFilterClearInfo.Update;
  LocalBackupSourceExcludeFilterClearInfo.Free;
end;

procedure TLocalBackupSourceExcludeFilterClearHandle.ClearToXml;
var
  LocalBackupSourceExcludeFilterClearXml : TLocalBackupSourceExcludeFilterClearXml;
begin
  LocalBackupSourceExcludeFilterClearXml := TLocalBackupSourceExcludeFilterClearXml.Create( FullPath );
  MyXmlChange.AddChange( LocalBackupSourceExcludeFilterClearXml );
end;

procedure TLocalBackupSourceExcludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TLocalBackupSourceExcludeFilterReadHandle }

procedure TLocalBackupSourceExcludeFilterReadHandle.AddToInfo;
var
  LocalBackupSourceExcludeFilterAddInfo : TLocalBackupSourceExcludeFilterAddInfo;
begin
  LocalBackupSourceExcludeFilterAddInfo := TLocalBackupSourceExcludeFilterAddInfo.Create( FullPath );
  LocalBackupSourceExcludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceExcludeFilterAddInfo.Update;
  LocalBackupSourceExcludeFilterAddInfo.Free;
end;

procedure TLocalBackupSourceExcludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TLocalBackupSourceExcludeFilterAddHandle }

procedure TLocalBackupSourceExcludeFilterAddHandle.AddToXml;
var
  LocalBackupSourceExcludeFilterAddXml : TLocalBackupSourceExcludeFilterAddXml;
begin
  LocalBackupSourceExcludeFilterAddXml := TLocalBackupSourceExcludeFilterAddXml.Create( FullPath );
  LocalBackupSourceExcludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyXmlChange.AddChange( LocalBackupSourceExcludeFilterAddXml );
end;

procedure TLocalBackupSourceExcludeFilterAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupSourceSetIsDisableHandle }

procedure TLocalBackupSourceSetIsDisableHandle.SetIsDisable(
  _IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceSetIsDisableHandle.SetToFace;
var
  VstLocalBackupSourceIsDisable : TVstLocalBackupSourceIsDisable;
begin
  VstLocalBackupSourceIsDisable := TVstLocalBackupSourceIsDisable.Create( FullPath );
  VstLocalBackupSourceIsDisable.SetIsDisable( IsDisable );
  MyFaceChange.AddChange( VstLocalBackupSourceIsDisable );
end;

procedure TLocalBackupSourceSetIsDisableHandle.SetToInfo;
var
  LocalBackupSourceIsDisableInfo : TLocalBackupSourceIsDisableInfo;
begin
  LocalBackupSourceIsDisableInfo := TLocalBackupSourceIsDisableInfo.Create( FullPath );
  LocalBackupSourceIsDisableInfo.SetIsDisable( IsDisable );
  LocalBackupSourceIsDisableInfo.Update;
  LocalBackupSourceIsDisableInfo.Free;
end;

procedure TLocalBackupSourceSetIsDisableHandle.SetToXml;
var
  LocalBackupSourceIsDisableXml : TLocalBackupSourceIsDisableXml;
begin
  LocalBackupSourceIsDisableXml := TLocalBackupSourceIsDisableXml.Create( FullPath );
  LocalBackupSourceIsDisableXml.SetIsDisable( IsDisable );
  MyXmlChange.AddChange( LocalBackupSourceIsDisableXml );
end;

procedure TLocalBackupSourceSetIsDisableHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupSourceSetIsBackupNowHandle }

procedure TLocalBackupSourceSetIsBackupNowHandle.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupSourceSetIsBackupNowHandle.SetToInfo;
var
  LocalBackupSourceIsBackupNowInfo : TLocalBackupSourceIsBackupNowInfo;
begin
  LocalBackupSourceIsBackupNowInfo := TLocalBackupSourceIsBackupNowInfo.Create( FullPath );
  LocalBackupSourceIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  LocalBackupSourceIsBackupNowInfo.Update;
  LocalBackupSourceIsBackupNowInfo.Free;
end;

procedure TLocalBackupSourceSetIsBackupNowHandle.SetToXml;
var
  LocalBackupSourceIsBackupNowXml : TLocalBackupSourceIsBackupNowXml;
begin
  LocalBackupSourceIsBackupNowXml := TLocalBackupSourceIsBackupNowXml.Create( FullPath );
  LocalBackupSourceIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  MyXmlChange.AddChange( LocalBackupSourceIsBackupNowXml );
end;

procedure TLocalBackupSourceSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TLocalBackupSourceSetLastSyncTimeHandle }

procedure TLocalBackupSourceSetLastSyncTimeHandle.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceSetLastSyncTimeHandle.SetToFace;
var
  VstLocalBackupSourceSetLastSyncTime : TVstLocalBackupSourceSetLastSyncTime;
begin
  VstLocalBackupSourceSetLastSyncTime := TVstLocalBackupSourceSetLastSyncTime.Create( FullPath );
  VstLocalBackupSourceSetLastSyncTime.SetLastSyncTime( LastSyncTime );
  MyFaceChange.AddChange( VstLocalBackupSourceSetLastSyncTime );
end;

procedure TLocalBackupSourceSetLastSyncTimeHandle.SetToInfo;
var
  LocalBackupSourceSetLastSyncTimeInfo : TLocalBackupSourceSetLastSyncTimeInfo;
begin
  LocalBackupSourceSetLastSyncTimeInfo := TLocalBackupSourceSetLastSyncTimeInfo.Create( FullPath );
  LocalBackupSourceSetLastSyncTimeInfo.SetLastSyncTime( LastSyncTime );
  LocalBackupSourceSetLastSyncTimeInfo.Update;
  LocalBackupSourceSetLastSyncTimeInfo.Free;
end;

procedure TLocalBackupSourceSetLastSyncTimeHandle.SetToXml;
var
  LocalBackupSourceSetLastSyncTimeXml : TLocalBackupSourceSetLastSyncTimeXml;
begin
  LocalBackupSourceSetLastSyncTimeXml := TLocalBackupSourceSetLastSyncTimeXml.Create( FullPath );
  LocalBackupSourceSetLastSyncTimeXml.SetLastSyncTime( LastSyncTime );
  MyXmlChange.AddChange( LocalBackupSourceSetLastSyncTimeXml );
end;

procedure TLocalBackupSourceSetLastSyncTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;


{ TLocalBackupSourceSetAutoSyncHandle }

procedure TLocalBackupSourceSetAutoSyncHandle.SetIsAutoSync(
  _IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupSourceSetAutoSyncHandle.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceSetAutoSyncHandle.SetToFace;
var
  VstLocalBackupSourceSetSyncMins : TVstLocalBackupSourceSetSyncTime;
begin
  VstLocalBackupSourceSetSyncMins := TVstLocalBackupSourceSetSyncTime.Create( FullPath );
  VstLocalBackupSourceSetSyncMins.SetIsAutoSync( IsAutoSync );
  VstLocalBackupSourceSetSyncMins.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyFaceChange.AddChange( VstLocalBackupSourceSetSyncMins );
end;

procedure TLocalBackupSourceSetAutoSyncHandle.SetToInfo;
var
  LocalBackupSourceSetSyncMinsInfo : TLocalBackupSourceSetSyncMinsInfo;
begin
  LocalBackupSourceSetSyncMinsInfo := TLocalBackupSourceSetSyncMinsInfo.Create( FullPath );
  LocalBackupSourceSetSyncMinsInfo.SetIsAutoSync( IsAutoSync );
  LocalBackupSourceSetSyncMinsInfo.SetSyncInterval( SyncTimeType, SyncTimeValue );
  LocalBackupSourceSetSyncMinsInfo.Update;
  LocalBackupSourceSetSyncMinsInfo.Free;
end;

procedure TLocalBackupSourceSetAutoSyncHandle.SetToXml;
var
  LocalBackupSourceSetSyncMinsXml : TLocalBackupSourceSetSyncMinsXml;
begin
  LocalBackupSourceSetSyncMinsXml := TLocalBackupSourceSetSyncMinsXml.Create( FullPath );
  LocalBackupSourceSetSyncMinsXml.SetIsAutoSync( IsAutoSync );
  LocalBackupSourceSetSyncMinsXml.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyXmlChange.AddChange( LocalBackupSourceSetSyncMinsXml );
end;

procedure TLocalBackupSourceSetAutoSyncHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupSourceRefreshLastSyncTimeHandle }

procedure TLocalBackupSourceRefreshNextSyncTimeHandle.SetToFace;
var
  LVLocalBackupSourceRefreshNextSync : TLVLocalBackupSourceRefreshNextSync;
begin
  LVLocalBackupSourceRefreshNextSync := TLVLocalBackupSourceRefreshNextSync.Create;
  MyFaceChange.AddChange( LVLocalBackupSourceRefreshNextSync );
end;

procedure TLocalBackupSourceRefreshNextSyncTimeHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupSourceSetDeleteHandle }

procedure TLocalBackupSourceSetDeleteHandle.SetDeletedInfo(
  _IsKeepDeleted: Boolean; _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceSetDeleteHandle.SetToInfo;
var
  LocalBackupSorceSetDeleteInfo : TLocalBackupSorceSetDeleteInfo;
begin
  LocalBackupSorceSetDeleteInfo := TLocalBackupSorceSetDeleteInfo.Create( FullPath );
  LocalBackupSorceSetDeleteInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSorceSetDeleteInfo.Update;
  LocalBackupSorceSetDeleteInfo.Free;
end;

procedure TLocalBackupSourceSetDeleteHandle.SetToXml;
var
  LocalBackupSorceSetDeleteXml : TLocalBackupSorceSetDeleteXml;
begin
  LocalBackupSorceSetDeleteXml := TLocalBackupSorceSetDeleteXml.Create( FullPath );
  LocalBackupSorceSetDeleteXml.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  MyXmlChange.AddChange( LocalBackupSorceSetDeleteXml );
end;

procedure TLocalBackupSourceSetDeleteHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TLocalBackupSourceAddDesDeletedSpaceHandle }

procedure TLocalBackupSourceAddDesDeletedSpaceHandle.AddToFace;
var
  vstLocalBackupDesDeletedAddSpace : TvstLocalBackupDesDeletedAddSpace;
begin
  vstLocalBackupDesDeletedAddSpace := TvstLocalBackupDesDeletedAddSpace.Create( DesPath );
  vstLocalBackupDesDeletedAddSpace.SetChildPath( FullPath );
  vstLocalBackupDesDeletedAddSpace.SetAddSize( AddRecycledSpace );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedAddSpace );
end;

procedure TLocalBackupSourceAddDesDeletedSpaceHandle.AddToInfo;
var
  LocalBackupSorceAddDeletedSpaceInfo : TLocalBackupSorceAddDeletedSpaceInfo;
begin
  LocalBackupSorceAddDeletedSpaceInfo := TLocalBackupSorceAddDeletedSpaceInfo.Create( FullPath );
  LocalBackupSorceAddDeletedSpaceInfo.SetDesPath( DesPath );
  LocalBackupSorceAddDeletedSpaceInfo.SetAddDeletedSpace( AddRecycledSpace );
  LocalBackupSorceAddDeletedSpaceInfo.Update;
  LocalBackupSorceAddDeletedSpaceInfo.Free;
end;

procedure TLocalBackupSourceAddDesDeletedSpaceHandle.AddToXml;
var
  LocalBackupSorceAddDeletedSpaceXml : TLocalBackupSorceAddDeletedSpaceXml;
begin
  LocalBackupSorceAddDeletedSpaceXml := TLocalBackupSorceAddDeletedSpaceXml.Create( FullPath );
  LocalBackupSorceAddDeletedSpaceXml.SetDesPath( DesPath );
  LocalBackupSorceAddDeletedSpaceXml.SetAddDeletedSpace( AddRecycledSpace );
  MyXmlChange.AddChange( LocalBackupSorceAddDeletedSpaceXml );
end;

procedure TLocalBackupSourceAddDesDeletedSpaceHandle.SetAddRecycledSpace(
  _AddRecycledSpace: Int64);
begin
  AddRecycledSpace := _AddRecycledSpace;
end;

procedure TLocalBackupSourceAddDesDeletedSpaceHandle.Update;
begin
  AddToInfo;
  AddToFace;
  AddToXml;
end;

{ TLocalBackupSourceSetDesDeletedSpaceHandle }

procedure TLocalBackupSourceSetDesDeletedSpaceHandle.SetRecycledSpace(
  _RecycledSpace: Int64);
begin
  RecycledSpace := _RecycledSpace;
end;

procedure TLocalBackupSourceSetDesDeletedSpaceHandle.SetToFace;
var
  vstLocalBackupDesDeletedSetSpace : TvstLocalBackupDesDeletedSetSpace;
begin
  vstLocalBackupDesDeletedSetSpace := TvstLocalBackupDesDeletedSetSpace.Create( DesPath );
  vstLocalBackupDesDeletedSetSpace.SetChildPath( FullPath );
  vstLocalBackupDesDeletedSetSpace.SetCompletedSize( RecycledSpace );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedSetSpace );
end;

procedure TLocalBackupSourceSetDesDeletedSpaceHandle.SetToInfo;
var
  LocalBackupSorceSetDeletedSpaceInfo : TLocalBackupSorceSetDeletedSpaceInfo;
begin
  LocalBackupSorceSetDeletedSpaceInfo := TLocalBackupSorceSetDeletedSpaceInfo.Create( FullPath );
  LocalBackupSorceSetDeletedSpaceInfo.SetDesPath( DesPath );
  LocalBackupSorceSetDeletedSpaceInfo.SetDeletedSpace( RecycledSpace );
  LocalBackupSorceSetDeletedSpaceInfo.Update;
  LocalBackupSorceSetDeletedSpaceInfo.Free;
end;

procedure TLocalBackupSourceSetDesDeletedSpaceHandle.SetToXml;
var
  LocalBackupSorceSetDeletedSpaceXml : TLocalBackupSorceSetDeletedSpaceXml;
begin
  LocalBackupSorceSetDeletedSpaceXml := TLocalBackupSorceSetDeletedSpaceXml.Create( FullPath );
  LocalBackupSorceSetDeletedSpaceXml.SetDesPath( DesPath );
  LocalBackupSorceSetDeletedSpaceXml.SetDeletedSpace( RecycledSpace );
  MyXmlChange.AddChange( LocalBackupSorceSetDeletedSpaceXml );
end;

procedure TLocalBackupSourceSetDesDeletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalSourceBackupHandle }

procedure TLocalSourceBackupHandle.AddToScanPath;
var
  ScanPathInfo : TScanPathInfo;
  i : Integer;
begin
    // 扫描源路径
  ScanPathInfo := TScanPathInfo.Create( SourcePath );
  ScanPathInfo.SetIsShowFreeLimit( IsShowFreeLimit );
  for i := 0 to DesPathList.Count - 1 do
    ScanPathInfo.AddDesPath( DesPathList[i] );
  MyLocalBackupHandler.AddScanPathInfo( ScanPathInfo );
end;

constructor TLocalSourceBackupHandle.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
  DesPathList := nil;
end;

destructor TLocalSourceBackupHandle.Destroy;
begin
  DesPathList.Free;
  inherited;
end;

function TLocalSourceBackupHandle.getIsEnable: Boolean;
begin
  Result := MyLocalBackupSourceReadUtil.getIsEnable( SourcePath );
end;

procedure TLocalSourceBackupHandle.ReadDesPathList;
begin
  DesPathList := MyLocalBackupSourceReadUtil.getDesPathList( SourcePath );
end;

procedure TLocalSourceBackupHandle.SetIsShowFreeLimit(
  _IsShowFreeLimit: Boolean);
begin
  IsShowFreeLimit := _IsShowFreeLimit;
end;

procedure TLocalSourceBackupHandle.SetLastSyncTime;
var
  LocalBackupSourceSetLastSyncTimeHandle : TLocalBackupSourceSetLastSyncTimeHandle;
begin
  LocalBackupSourceSetLastSyncTimeHandle := TLocalBackupSourceSetLastSyncTimeHandle.Create( SourcePath );
  LocalBackupSourceSetLastSyncTimeHandle.SetLastSyncTime( Now );
  LocalBackupSourceSetLastSyncTimeHandle.Update;
  LocalBackupSourceSetLastSyncTimeHandle.Free;
end;

procedure TLocalSourceBackupHandle.Update;
begin
    // 检测 路径是否 Disable
  if not getIsEnable then
    Exit;

    // 读取 目标路径
  ReadDesPathList;

    // 添加到 扫描器
  AddToScanPath;

    // 设置 上一次同步时间
  SetLastSyncTime;
end;

end.
