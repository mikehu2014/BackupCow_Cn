unit UBackupInfoFace;

interface

uses UChangeInfo, SysUtils, Generics.Collections, ComCtrls, UMyUtil, UModelUtil, Classes, DateUtils,
     UIconUtil, StdCtrls, uDebug, SyncObjs, RzPanel, VirtualTrees, Math, IniFiles;

type

  PathTypeIconUtil = class
  public
    class function getIcon( FullPath, PathType : string ) : Integer;
  end;

{$Region ' 数据结构与辅助类 '}

    // 界面 VirtualString 路径信息
  PVstBackupItemData = ^TVstBackupItemData;
  TVstBackupItemData = record
  public
    FolderName, PathType : WideString;
    IsEncrypt, IsExist : Boolean;
    IsDiable, IsAuctoSync: Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
    FileCount, CopyCount : Integer;
    ItemSize, CompletedSpace : Int64;
    FolderStatus : WideString;
  end;

    // 界面 ListView 文件信息
  TBackupLvFaceData = class
  public
    FullPath : string;
    IsFolder : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsFolder( _IsFolder : Boolean );
  end;

  TFindNodeIcon = class
  private
    PathType : string;
    IsExist, IsEmpty : Boolean;
    IsLoading, IsWaiting, IsRefreshing, IsAnalyzing : Boolean;
    IsFullBackup, IsEmptyBackup, IsDisable : Boolean;
  public
    constructor Create( Node : PVirtualNode );
    function get : Integer;
  private
    function getFileIcon : Integer;
    function getFolderIcon : Integer;
  end;

  VstBackupItemUtil = class
  public
    class function getStatus( Node : PVirtualNode ): string;
    class function getStatusInt( Node : PVirtualNode ): Integer;
    class function getStatusIcon( Node : PVirtualNode ): Integer;
    class function getStatusHint( Node : PVirtualNode ): string;
    class function getBackupStatus( CompletedSpace, TotalSpace : Int64 ): string;
  public
    class function getNodeFullPath( Node : PVirtualNode ): string;
    class function getHintStr( Node : PVirtualNode ): string;
  public
    class function getNextSyncTimeStr( Node : PVirtualNode ): string;
  public
    class function getSelectPath: string;
    class function getSelectPathList : TStringList;
  public
    class function IsRootPath( FolderPath : string ): Boolean;
  end;

  LvBackupFileUtil = class
  public
    class function IsFolderShow( FolderPath : string ): Boolean;
    class function IsFileShow( FilePath : string ): Boolean;
    class function getBackupStatus( CompletedSpace, TotalSpace : Int64 ): string;
  public
    class function getSelectPath : string;
  end;

{$EndRegion}

{$Region ' 选择备份目录VirtualTree界面 写操作 ' }

    // 写信息 父类
  TBackupVtWriteInfo = class( TChangeInfo )
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 添加 信息
  TBackupVtAddInfo = class( TBackupVtWriteInfo )
  public
    procedure Update;override;
  end;

    // 删除 信息
  TBackupVtRemoveInfo = class( TBackupVtWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 备份路径VirtualTree界面 写操作 '}

    // 添加 第一个 Backup Item 时 界面处理
  TBackupItemFirstHandle = class
  public
    procedure Update;
  end;

    // 没有 Backup Item 时 界面处理
  TBackupItemEmptyHandle = class
  public
    procedure Update;
  end;

    // 父类
  TVstBackupPathChange = class( TChangeInfo )
  public
    VstBackupItem : TVirtualStringTree;
  public
    procedure Update;override;
  end;

  {$Region ' 修改 备份路径 ' }

      // 修改
  TVstBackupPathWrite = class( TVstBackupPathChange )
  public
    FullPath : string;
  protected
    PathNode : PVirtualNode;
    PathData : PVstBackupItemData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindPathNode : Boolean;
    procedure RefreshPathNode;
    procedure RefreshNextSyncTime;
  end;

    // 添加 备份路径
  TVstBackupPathAdd = class( TVstBackupPathWrite )
  public
    PathType : string;
    IsEncrypt : Boolean;
    IsDisable, IsAuctoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
    CopyCount, FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsDisable : Boolean );
    procedure SetSyncTimeInfo( _IsAuctoSync : Boolean; _SyncTimeType, _SyncTimeValue : Integer; _LastSyncTime : TDateTime );
    procedure SetIsEncrypt( _IsEncrypt : Boolean );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 修改 备份 Copy 信息
  TVstBackupPathSetCopyCount = class( TVstBackupPathWrite )
  private
    CopyCount : Integer;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
  private
    procedure ResetChildNode( ChildNode : PVirtualNode );
  end;

  {$Region ' 修改 同步时间信息 ' }

    // 设置 上一次 同步时间
  TVstBackupPathSetLastSyncTime = class( TVstBackupPathWrite )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // 设置 同步周期
  TVstBackupPathSetSyncTime = class( TVstBackupPathWrite )
  private
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

    // 刷新 下一次 同步时间
  TVstBackuppathRefreshNextSyncTime = class( TVstBackupPathWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 状态信息 '}

      // 是修改 Path Exist 状态
  TVstBackupPathIsExist = class( TVstBackupPathWrite )
  public
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;override;
  end;

    // 是否 禁止备份
  TVstBackupPathIsDisable = class( TVstBackupPathWrite )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // 设置 备份路径状态
  TVstBackupPathSetStatus = class( TVstBackupPathWrite )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

  {$EndRegion}

    // 刷新 选择的 Node 信息
  TVstBackupPathRefreshSelectNode = class( TVstBackupPathWrite )
  public
    procedure Update;override;
  end;

      // 删除 根节点信息
  TVstBackupPathRemove = class( TVstBackupPathWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 备份目录 ' }

    // 修改
  TVstBackupFolderChange = class( TVstBackupPathChange )
  public
    FolderPath : string;
  protected
    FolderNode : PVirtualNode;
    FolderData : PVstBackupItemData;
  protected
    RootFolderNode : PVirtualNode;
    RootFolderData : PVstBackupItemData;
  public
    constructor Create( _FolderPath : string );
  protected
    function FindRootFolderNode : Boolean;
    function FindFolderNode : Boolean;
    procedure ResetFolderNode;
  protected
    function FindChildNode( ParentNode : PVirtualNode; ChileName : string ): PVirtualNode;
  end;

    // 添加 备份目录
  TVstBackupFolderAdd = class( TVstBackupFolderChange )
  private
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public
    procedure SetCountInfo( _FileCount : Integer );
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure Update;override;
  private
    procedure IniFolderNode( NewNode : PVirtualNode );
    procedure AddFolderNode;
  end;

    // 设置 备份目录 空间信息
  TVstBackupFolderSetSpace = class( TVstBackupFolderChange )
  private
    FileCount : Integer;
    Size : Int64;
  public
    procedure SetFileCount( _FileCount : Integer );
    procedure SetSize( _Size : Int64 );
    procedure Update;override;
  end;

  {$Region ' 修改 已完成空间 信息 ' }

    // 修改
  TVstBackupFolderChangeCompletedSpace = class( TVstBackupFolderChange )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  protected
    procedure RefreshLvStatus( Node : PVirtualNode );
  end;

    // 添加 已完成空间
  TVstBackupFolderAddCompletedSpace = class( TVstBackupFolderChangeCompletedSpace )
  public
    procedure Update;override;
  end;

    // 删除 已完成空间
  TVstBackupFolderRemoveCompletedSpace = class( TVstBackupFolderChangeCompletedSpace )
  public
    procedure Update;override;
  end;

    // 设置 已完成空间
  TVstBackupFolderSetCompletedSpace = class( TVstBackupFolderChangeCompletedSpace )
  private
    LastCompletedSpace : Int64;
  public
    procedure SetLastCompletedSpace( _LastCompletedSpace : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

    // 设置 节点状态
  TVstBackupFolderSetStatus = class( TVstBackupFolderChange )
  private
    PathStatus : string;
  public
    procedure SetPathStatus( _PathStatus : string );
    procedure Update;override;
  end;

    // 删除 子节点信息
  TVstBackupItemRemoveChild = class( TVstBackupFolderChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 备份信息ListView界面 写操作 ' }

  LvBackupFileStatusUtil = class
  public
    class function getSelectPath : string;
    class function getSelectPathList : TStringList;
  public
    class function getIsFolder( FilePath : string ): Boolean;
  end;

    // 父类
  TLvBackupFileChangeInfo = class( TChangeInfo )
  public
    LvBackupFile : TListView;
  public
    procedure Update;override;
  end;

    // 修改
  TBackupLvWriteInfo = class( TLvBackupFileChangeInfo )
  public
    FilePath : string;
  protected
    FileItem : TListItem;
    ItemIndex : Integer;
    ItemData : TBackupLvFaceData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindFileItem : Boolean;
    function getStatusIcon( BackupStatus : string ): Integer;
  end;

    // 添加 信息
  TBackupLvAddInfo = class( TBackupLvWriteInfo )
  public
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    CopyCount : Integer;
    Status, StatusShow : string;
  public
    procedure SetIsFolder( _IsFolder : Boolean );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetCopyInfo( _CopyCount : Integer );
    procedure SetStatusInfo( _Status, _StatusShow : string );
    procedure Update;override;
  end;
  TBackupLvAddList = class( TObjectList<TBackupLvAddInfo> )end;

    // Backup Status 信息
  TBackupLvStatusInfo = class( TBackupLvWriteInfo )
  private
    CopyCountStatus : string;
    Status, StatusShow : string;
  public
    procedure SetCopyCountStatus( _BackupCopyCount : string );
    procedure SetStatusInfo( _Status, _StatusShow : string );
    procedure Update;override;
  end;

    // 删除 信息
  TBackupLvRemoveInfo = class( TBackupLvWriteInfo )
  public
    procedure Update;override;
  end;

      // 读取一个目录的信息
  TBackupLvReadFolderInfo = class( TLvBackupFileChangeInfo )
  public
    FullPath : string;
    BackupLvAddList : TBackupLvAddList;
  public
    constructor Create( _FullPath : string );
    procedure AddBackupLv( BackupLvAddInfo : TBackupLvAddInfo );
    procedure Update;override;
    destructor Destroy; override;
  end;

    // 清空 信息
  TBackupLvClearInfo = class( TLvBackupFileChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 备份信息 属性窗口界面 写操作 ' }

  {$Region ' 备份文件 详细信息 ' }

  TShowCopyInfo = class
  public
    OwnerID : string;
    OwnerStatus : string;
  public
    OwnerOnlineTime : string;
  public
    constructor Create( _OwnerID, _OwnerStatus : string );
    procedure SetOwnerOnlineTime( _OwnerOnlineTime : string );
  end;
  TShowCopyPair = TPair< string , TShowCopyInfo >;
  TShowCopyHash = class(TStringDictionary< TShowCopyInfo >);


    // 文件 Detail 信息
  TBackupFrmDetailInfo = class( TChangeInfo )
  public
    FullPath : string;
    FileSize : Int64;
    BackupStatus : string;
    FileCount : Integer;
  public
    ShowCopyHash : TShowCopyHash;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  end;

  {$EndRegion}

  {$Region ' 备份路径 属性界面 ' }

      // 数据结构
    TLvBackupPathProData = class
    public
      FullPath : string;
    public
      constructor Create( _FullPath : string );
    end;

      // 父类
    TLvBackupPathProChange = class( TChangeInfo )
    public
      LvBackupPathPro : TListView;
    public
      procedure Update;override;
    end;

      // 修改
    TLvBackupPathProWrite = class( TLvBackupPathProChange )
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
    TLvBackupPathProAdd = class( TLvBackupPathProWrite )
    public
      procedure Update;override;
    end;

      // 删除
    TLvBackupPathProRemove = class( TLvBackupPathProWrite )
    public
      procedure Update;override;
    end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络备份 Panel 公告信息 ' }

    // 显示 公告
  TPlBackupBoardShow = class( TChangeInfo )
  public
    ShowStr : string;
  public
    constructor Create( _ShowStr : string );
    procedure Update;override;
  end;

    // 显示 公告图标
  TPlBackupBoardIconShow = class( TChangeInfo )
  public
    IsShow : Boolean;
  public
    constructor Create( _IsShow : Boolean );
    procedure Update;override;
  end;

    // 公告栏的隐藏
  TBackupBoardInvisibleThread = class( TThread )
  private
    LastStr : string;
    LastTime : TDateTime;
  public
    constructor Create;
    procedure ResetLastStr( _LastStr : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure BackupBoardInvisible;
  end;

{$EndRegion}

{$Region ' 本地备份 Panel 公告信息 ' }

    // 本地备份信息 公告
  TPlBackupDesBoardShowInfo = class( TChangeInfo )
  public
    FilePath : string;
    ShowType : string;
  public
    constructor Create( _FilePath : string );
    procedure SetShowType( _ShowType : string );
    procedure Update;override;
  protected
    procedure ShowFileType;
  end;

    // 本地备份信息 + 空间 公告
  TPlBackupDesBoardShowSizeInfo = class( TPlBackupDesBoardShowInfo )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 本地备份信息 可见性
  TPlBackupDesBoardVisibleInfo = class( TChangeInfo )
  private
    IsVisible : Boolean;
  public
    constructor Create( _IsVisible : Boolean );
    procedure Update;override;
  end;


    // 本地备份进度 可见性
  TPlBackupDesPercentVisibleInfo = class( TChangeInfo )
  private
    IsVisible : Boolean;
    ExplorerPath : string;
  public
    constructor Create( _IsVisible : Boolean );
    procedure SetExplorerPath( _ExplorerPath : string );
    procedure Update;override;
  end;

    // 本地备份进度 公告
  TPlBackupDesBoardPercentInfo = class( TChangeInfo )
  public
    Percent : Integer;
    PercentCompareStr : string;
  public
    constructor Create( _Percent : Integer );
    procedure SetPercentCompareStr( _PercentCompareStr : string );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 备份进度条 写操作 ' }

  TBackupPgWriteInfo = class( TChangeInfo )
  end;

    // 刷新进度条
  TBackupPgRefreshInfo = class( TBackupPgWriteInfo )
  private
    CompletedSize : Int64;
    TotalSize : Int64;
  public
    constructor Create( _CompletedSize, _TotalSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成
  TBackupPgAddCompletedInfo = class( TBackupPgWriteInfo )
  private
    AddSize : Int64;
  public
    constructor Create( _AddSize : Int64 );
    procedure Update;override;
  private
    procedure ShowProgress;
  end;

    // 移除 已完成
  TBackupPgRemoveCompletedInfo = class( TBackupPgWriteInfo )
  private
    RemoveSize : Int64;
  public
    constructor Create( _RemoveSize : Int64 );
    procedure Update;override;
  end;

    // 显示进度条
  TBackupPgShowInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // 隐藏备份 进度条 线程
  TBackupProgressHideThread = class( TThread )
  private
    LastShowTime : TDateTime;
  public
    constructor Create;
    procedure ShowBackupProgress;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HideProgress;
  end;

{$EndRegion}

{$Region ' 备份 界面控制 ' }

    // 备份扫描 完成
  TBackupTvBackupStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

  LanguageUtil = class
  public
    class function getPercentageStr( Str : string ): string;
    class function getSyncTimeStr( Str : string ): string;
  end;

const
  NodeIcon_FolderIncompleted = 0;
  NodeIcon_FolderPartCompleted = 1;
  NodeIcon_FolderCompleted = 2;
  NodeIcon_FolderNotExists = 3;
  NodeIcon_FolderEmpty = 4;
  NodeIcon_FolderLoading = 5;
  NodeIcon_FolderWaiting = 5;
  NodeIcon_FolderRefreshing = 6;
  NodeIcon_FolderAnalyzing = 7;
  NodeIcon_FolderDisable = 15;

  NodeIcon_FileIncompleted = 8;
  NodeIcon_FilePartCompleted = 9;
  NodeIcon_FileCompleted = 10;
  NodeIcon_FileNotExists = 11;
  NodeIcon_FileLoading = 12;
  NodeIcon_FileWaiting = 12;
  NodeIcon_FileRefreshing = 13;
  NodeIcon_FileAnalyzing = 14;
  NodeIcon_FileDisable = 16;

const

  NodeStatusHint_Loading = 'The directory is loading...';
  NodeStatusHint_Waiting = 'The directory is waiting...';
  NodeStatusHint_Refreshing = 'The directory is refreshing...';
  NodeStatusHint_Analyzing = 'The directory is analyzing...';
  NodeStatusHint_NotExists = 'No backup directory exists';
  NodeStatusHint_Disable = 'The directory is Disable';

  NodeStatus_Disable = 'Disable';
  NodeStatus_Loading = 'Loading...';
  NodeStatus_Waiting = 'Waiting...';
  NodeStatus_Refreshing = 'Refreshing...';
  NodeStatus_Analyzing = 'Analyzing...';
  NodeStatus_NotExists = 'Not exists';

  NodeStatus_Empty = 'Empty directory';
  NodeStatus_Incompleted = 'Incompleted';
  NodeStatus_PartCompleted = 'Partially completed';
  NodeStatus_Completed = 'Completed';

  LvFileStatus_FileSize = 0;
  LvFileStatus_FileTime = 1;
  LvFileStatus_CopyCount = 2;
  LvFileStatus_BackupStatus = 3;

  BackupPriorityIcon_Offline = 0;
  BackupPriorityIcon_Online = 1;
  BackupPriorityIcon_Alway = 2;
  BackupPriorityIcon_Never = 3;
  BackupPriorityIcon_High = 4;
  BackupPriorityIcon_Normal = 5;
  BackupPriorityIcon_Low = 6;

  BackupStatus_Disable = 'Disable';

  LvBackupDes_Status = 0;

  Label_SyncTime : string = 'Synchronize Every %d Minutes';
  Label_CopyCount : string = 'Pre-set Copy Quantity : %d';

  SbRemainTime_Min : string = '%d Min';

  NodeStatus_Encrypted = ' (Encrypted)';

  BackupDesBroadType_Copy = 'Copying';
  BackupDesBroadType_Removing = 'Removing';
  BackupDesBroadType_Recycling = 'Recycling';

  PlLocalBackupDesProgress_Heigh = 28;

  FolderStatus_Loading = 'Loading';
  FolderStatus_Waiting = 'Waiting';
  FolderStatus_Refreshing = 'Refreshing';
  FolderStatus_Analyzing = 'Analyzing';
  FolderStatus_Stop = 'Stop';

const
  LocalBackupStatus_Copying  = 'Copying';
  LocalBackupStatus_Removing  = 'Removeing';
  LocalBackupStatus_Disable = 'Disable';
  LocalBackupStatus_NotExist = 'Not Exist';
  LocalBackupStatus_Unmodifiable = 'Cannot Write';
  LocalBackupStatus_LackSpace = 'Space Insufficient';
  LocalBackupStatus_FreeLimit = 'Incompleted';
  LocalBackupStatus_Completed  = 'Completed';
  LocalBackupStatus_InCompleted  = 'Incompleted';
  LocalBackupStatus_Recycled = 'Recycled';
  LocalBackupStatus_Recycling = 'Recycling';

  LocalBackupSourceStatus_Copy = 'Copying';
  LocalBackupSourceStatus_Refresh = 'Analyzing';

const
  Ini_Sync = 'Sync';
  Ini_LastSyncTime = 'LastSyncTime';

  SyncTimeShow_LastSync = 'Last Synchronization: ';
  SyncTimeShow_SyncEvery = 'Synchronize Every: ';
  SyncTimeShow_SyncRemain = 'Sync Time Remain: ';

var
    // Backup Progress
  BackupProgress_Completed : Int64 = 0;
  BackupProgress_Total : Int64 = 0;

  TvNodePath_Selected : string = '';
  MyBackupFileFace : TMyChildFaceChange;
  BackupBoardInvisibleThread : TBackupBoardInvisibleThread;
  BackupProgressHideThread : TBackupProgressHideThread;

  Path_LocalCopyExplorer : string = '';

implementation

uses UMainForm, UFormBackupPath, UFormFilestatusDetail, USettingInfo, UMainFormFace,
     UNetworkFace, UMyBackupInfo,
     UMyNetPcInfo, UFormUtil, UFormBackupProperties, URegisterInfo, UBackupInfoControl,
     ULocalBackupControl;

{ TBackupTvWriteInfo }

constructor TVstBackupPathWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TVstBackupPathWrite.FindPathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupItemData;
  FolderName : string;
begin
  Result := False;

    // 遍历关联目录
  SelectNode := vstBackupItem.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstBackupItem.GetNodeData( SelectNode );
    FolderName := SelectData.FolderName;

      // 找到节点
    if FolderName = FullPath then
    begin
      PathNode := SelectNode;
      PathData := VstBackupItem.GetNodeData( PathNode );
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstBackupPathWrite.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
  SyncMins := TimeTypeUtil.getMins( PathData.SyncTimeType, PathData.SyncTimeValue );
  PathData.NextSyncTime := IncMinute( PathData.LastSyncTime, SyncMins );
end;

procedure TVstBackupPathWrite.RefreshPathNode;
begin
  VstBackupItem.RepaintNode( PathNode );
end;

{ TBackupVtWriteInfo }

constructor TBackupVtWriteInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TBackupLvAddInfo }

procedure TBackupLvAddInfo.SetStatusInfo(_Status, _StatusShow: string);
begin
  Status := _Status;
  StatusShow := _StatusShow;
end;

procedure TBackupLvAddInfo.SetCopyInfo(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupLvAddInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupLvAddInfo.SetIsFolder(_IsFolder: Boolean);
begin
  IsFolder := _IsFolder;
end;

procedure TBackupLvAddInfo.Update;
var
  FileSizeStr, CopyCountStr : string;
begin
  inherited;

    // 已存在
  if FindFileItem then
    Exit;

    // 提取信息
  FileSizeStr := MySize.getFileSizeStr( FileSize );
  if IsFolder then
    CopyCountStr := ''
  else
    CopyCountStr := IntToStr( CopyCount );
  if Status = BackupStatus_Empty then
    StatusShow := '';

    // 添加 数据
  ItemData := TBackupLvFaceData.Create( FilePath );
  ItemData.SetIsFolder( IsFolder );

  StatusShow := LanguageUtil.getPercentageStr( StatusShow );

    // 添加 界面
  with LvBackupFile.Items.Add do
  begin
    Caption := ExtractFileName( FilePath );
    SubItems.Add( FileSizeStr );
    SubItems.Add( DateTimeToStr( FileTime ) );
    SubItems.Add( CopyCountStr );
    SubItems.Add( StatusShow );

    ImageIndex := MyIcon.getIconByFilePath( FilePath );
    SubItemImages[ LvFileStatus_BackupStatus ] := getStatusIcon( Status );

    Data := ItemData;
  end;
end;

{ TBackupLvWriteInfo }

constructor TBackupLvWriteInfo.Create(_FullPath: string);
begin
  FilePath := _FullPath;
end;

{ TBackupTvStatusInfo }

function TBackupLvWriteInfo.FindFileItem: Boolean;
var
  i : Integer;
  SelectData : TBackupLvFaceData;
begin
  Result := False;

  for i := 0 to LvBackupFile.Items.Count - 1 do
  begin
    SelectData := LvBackupFile.Items[i].Data;
    if SelectData.FullPath = FilePath then
    begin
      FileItem := LvBackupFile.Items[i];
      ItemIndex := i;
      ItemData := FileItem.Data;
      Result := True;
      Break;
    end;
  end;
end;

function TBackupLvWriteInfo.getStatusIcon( BackupStatus: string): Integer;
begin
  Result := -1;
  if BackupStatus = BackupStatus_Incompleted then
    Result := MyShellBackupStatusIconUtil.getFileIncompleted
  else
  if BackupStatus = BackupStatus_PartCompleted then
    Result := MyShellBackupStatusIconUtil.getFilePartcompleted
  else
  if BackupStatus = BackupStatus_completed then
    Result := MyShellBackupStatusIconUtil.getFilecompleted;
end;


{ TBackupTvAddRootInfo }

procedure TVstBackupPathAdd.SetBackupInfo(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstBackupPathAdd.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TVstBackupPathAdd.SetIsEncrypt(_IsEncrypt: Boolean);
begin
  IsEncrypt := _IsEncrypt;
end;

procedure TVstBackupPathAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstBackupPathAdd.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstBackupPathAdd.SetSyncTimeInfo(_IsAuctoSync : Boolean;
  _SyncTimeType, _SyncTimeValue: Integer; _LastSyncTime: TDateTime);
begin
  IsAuctoSync := _IsAuctoSync;
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
  LastSyncTime := _LastSyncTime;
end;

procedure TVstBackupPathAdd.Update;
var
  BackupItemFirstHandle : TBackupItemFirstHandle;
begin
  inherited;

    // 已存在
  if FindPathNode then
    Exit;

    // 创建 根节点
  PathNode := VstBackupItem.AddChild( VstBackupItem.RootNode );
  PathData := vstBackupItem.GetNodeData( PathNode );
  PathData.FolderName := FullPath;
  PathData.PathType := PathType;
  PathData.IsEncrypt := IsEncrypt;
  PathData.IsExist := True;
  PathData.IsDiable := IsDisable;
  PathData.IsAuctoSync := IsAuctoSync;
  PathData.SyncTimeType := SyncTimeType;
  PathData.SyncTimeValue := SyncTimeValue;
  PathData.LastSyncTime := LastSyncTime;
  PathData.CopyCount := CopyCount;
  PathData.FileCount := FileCount;
  PathData.ItemSize := FileSize;
  PathData.CompletedSpace := CompletedSize;
  PathData.FolderStatus := FolderStatus_Stop;

    // 计算下次同步时间
  RefreshNextSyncTime;

    // 添加 第一个 BackupItem
  if vstBackupItem.RootNodeCount = 1 then
  begin
    BackupItemFirstHandle := TBackupItemFirstHandle.Create;
    BackupItemFirstHandle.Update;
    BackupItemFirstHandle.Free;
  end;
end;

{ TBackupVtAddInfo }

procedure TBackupVtAddInfo.Update;
begin
  frmSelectBackupPath.AddBackupPath( FullPath );
end;

{ TBackupVtRemoveInfo }

procedure TBackupVtRemoveInfo.Update;
begin
  frmSelectBackupPath.RemoveBackupPath( FullPath );
end;

{ TBackupTvAddChildInfo }

procedure TVstBackupFolderAdd.AddFolderNode;
var
  ParentNode, ChildNode : PVirtualNode;
  ParentData, ChildData : PVstBackupItemData;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
    // 根路径
  if RootFolderData.FolderName = FolderPath then
  begin
    FolderNode := RootFolderNode;
    FolderData := RootFolderData;
    Exit;
  end;

    // 从根目录向下寻找
  ParentNode := RootFolderNode;
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderData.FolderName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // 寻找子目录
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

      // 不存在目录, 则创建
    ChildNode := FindChildNode( ParentNode, FolderName );
    if ChildNode = nil then
    begin
      ChildNode := VstBackupItem.AddChild( ParentNode );
      IniFolderNode( ChildNode );
      ChildData := VstBackupItem.GetNodeData( ChildNode );
      ChildData.FolderName := FolderName;
      ChildData.CopyCount := RootFolderData.CopyCount;
    end;

      // 下一层
    ParentNode := ChildNode;
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

    // 找到节点
  FolderNode := ParentNode;
  FolderData := VstBackupItem.GetNodeData( FolderNode );
end;


procedure TVstBackupFolderAdd.IniFolderNode(NewNode: PVirtualNode);
var
  NewData : PVstBackupItemData;
begin
  NewData := VstBackupItem.GetNodeData( NewNode );

  NewData.ItemSize := 0;
  NewData.CompletedSpace := 0;
  NewData.FileCount := 0;
  NewData.CopyCount := 0;

  NewData.PathType := PathType_Folder;
  NewData.IsEncrypt := False;
  NewData.IsExist := True;
  NewData.IsDiable := False;
  NewData.FolderStatus := FolderStatus_Stop;
end;

procedure TVstBackupFolderAdd.SetCountInfo(_FileCount : Integer);
begin
  FileCount := _FileCount;
end;

procedure TVstBackupFolderAdd.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstBackupFolderAdd.Update;
begin
  inherited;

    // 不存在 根路径
  if not FindRootFolderNode then
    Exit;

    // 添加节点
  AddFolderNode;

    // 设置属性
  FolderData.FileCount := FileCount;
  FolderData.ItemSize := FileSize;
  FolderData.CompletedSpace := CompletedSize;
end;


{ TBackupTvRemoveInfo }

procedure TVstBackupPathRemove.Update;
var
  BackupItemEmptyHandle : TBackupItemEmptyHandle;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // 删除节点
  VstBackupItem.DeleteNode( PathNode );

    // ListView
  frmMainForm.lvFileStatus.Clear;
  frmMainForm.tbtnFsDetail.Enabled := False;
  frmMainForm.tbtnFsOpen.Enabled := False;
  frmMainForm.tbtnFsLvlExplorer.Enabled := False;
  frmMainForm.tbtnFsLvlRemove.Enabled := False;

    // VirtualTree
  frmMainForm.tbtnFsDelete.Enabled := False;
  frmMainForm.tbtnFsExplorer.Enabled := False;

    // 删除 最后一个 BackupItem
  if vstBackupItem.RootNodeCount <= 0 then
  begin
    BackupItemEmptyHandle := TBackupItemEmptyHandle.Create;
    BackupItemEmptyHandle.Update;
    BackupItemEmptyHandle.Free;
  end;
end;

{ TBackupLvRemoveInfo }

procedure TBackupLvRemoveInfo.Update;
begin
  inherited;

    // 不存在
  if not FindFileItem then
    Exit;

    // 删除
  LvBackupFile.Items.Delete( ItemIndex );
end;

{ TBackupLvClearInfo }

procedure TBackupLvClearInfo.Update;
begin
  inherited;

  LvBackupFile.Clear;
  frmMainForm.tbtnFsDetail.Enabled := False;
  frmMainForm.tbtnFsOpen.Enabled := False;
  frmMainForm.tbtnFsLvlExplorer.Enabled := False;
  frmMainForm.tbtnFsLvlRemove.Enabled := False;
end;


{ TBackupLvStatusInfo }

procedure TBackupLvStatusInfo.SetCopyCountStatus(_BackupCopyCount: string);
begin
  CopyCountStatus := _BackupCopyCount;
end;

procedure TBackupLvStatusInfo.SetStatusInfo(_Status, _StatusShow : string);
begin
  Status := _Status;
  StatusShow := _StatusShow;
end;

procedure TBackupLvStatusInfo.Update;
begin
  inherited;

    // 不存在
  if not FindFileItem then
    Exit;

  StatusShow := LanguageUtil.getPercentageStr( StatusShow );

    // 修改信息
  FileItem.SubItems[ LvFileStatus_CopyCount ] := CopyCountStatus;
  FileItem.SubItems[ LvFileStatus_BackupStatus ] := StatusShow;
  FileItem.SubItemImages[ LvFileStatus_BackupStatus ] := getStatusIcon( Status );
end;

{ TBackupLvFaceData }

constructor TBackupLvFaceData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupLvFaceData.SetIsFolder(_IsFolder: Boolean);
begin
  IsFolder := _IsFolder;
end;

{ TShowCopyInfo }

constructor TShowCopyInfo.Create(_OwnerID, _OwnerStatus: string);
begin
  OwnerID := _OwnerID;
  OwnerStatus := _OwnerStatus;
end;

procedure TShowCopyInfo.SetOwnerOnlineTime(_OwnerOnlineTime: string);
begin
  OwnerOnlineTime := _OwnerOnlineTime;
end;

{ TBackupFrmDetailInfo }

constructor TBackupFrmDetailInfo.Create;
begin
  ShowCopyHash := TShowCopyHash.Create;
end;

destructor TBackupFrmDetailInfo.Destroy;
begin
  ShowCopyHash.Free;
  inherited;
end;

procedure TBackupFrmDetailInfo.Update;
var
  LvCopyStatus : TListView;
  p : TShowCopyPair;
  PropertiesStr, BackupStatusStr, OnlineTimeStr, OwnerStr : string;
begin
  BackupStatusStr := frmFileStatusDetail.siLang_frmFileStatusDetail.GetText( BackupStatus );

  frmFileStatusDetail.edtFullPath.Text := FullPath;
  frmFileStatusDetail.lbFileSize.Caption := MySize.getFileSizeStr( FileSize );
  frmFileStatusDetail.lbFileCount.Caption := IntToStr( FileCount );
  frmFileStatusDetail.lbFileStatus.Caption := BackupStatusStr;

  LvCopyStatus := frmFileStatusDetail.lvFileOwners;
  LvCopyStatus.Clear;

  for p in ShowCopyHash do
    with LvCopyStatus.Items.Add do
    begin
      if p.Value.OwnerOnlineTime = Status_Online then
        OnlineTimeStr := frmFileStatusDetail.siLang_frmFileStatusDetail.GetText( 'StrOnline' )
      else
        OnlineTimeStr := p.Value.OwnerOnlineTime;
      OwnerStr := frmFileStatusDetail.siLang_frmFileStatusDetail.GetText( p.Value.OwnerStatus );

      Caption := p.Value.OwnerID;
      SubItems.Add( OnlineTimeStr );
      SubItems.Add( OwnerStr );
      if p.Value.OwnerOnlineTime = Status_Online then
        ImageIndex := CloudStatusIcon_Online
      else
        ImageIndex := CloudStatusIcon_Offline;
    end;

  PropertiesStr := frmFileStatusDetail.siLang_frmFileStatusDetail.GetText( 'StrProperties' );
  frmFileStatusDetail.Caption := ExtractFileName( FullPath ) + ' ' + PropertiesStr;
  frmFileStatusDetail.tbtnFileLink.ImageIndex := MyIcon.getIconByFilePath( FullPath );

  frmFileStatusDetail.Show;
end;

{ TBackupTvBackupStopInfo }

procedure TBackupTvBackupStopInfo.Update;
begin
    // 开启 BackupNow 按钮
  frmMainForm.tbtnBackupNow.Enabled := True;
end;

{ TBackupItemEmptyHandle }

procedure TBackupItemEmptyHandle.Update;
begin
    // tb Treeview
  frmMainForm.tbtnBackupNow.Enabled := False;
  frmMainForm.tbtnBackupClear.Enabled := False;

    // tb Setting
  frmMainForm.plBackupProgress.Visible := False;

    // Backup Broad
  frmMainForm.plBackupBoard.Visible := False;
  frmMainForm.plBackupBoardMain.Visible := False;

  // Enable 背景图案
  frmMainForm.vstBackupItem.TreeOptions.PaintOptions := frmMainForm.vstBackupItem.TreeOptions.PaintOptions + [toShowBackground];
end;

{ TBackupItemFirstHandle }

procedure TBackupItemFirstHandle.Update;
var
   stp : TStringTreeOptions;
begin
    // tb Treeview
  frmMainForm.tbtnBackupNow.Enabled := True;
  frmMainForm.tbtnBackupClear.Enabled := True;

    // disable 背景图案
  frmMainForm.vstBackupItem.TreeOptions.PaintOptions := frmMainForm.vstBackupItem.TreeOptions.PaintOptions - [toShowBackground];
end;

{ TPlBackupBoardShow }

constructor TPlBackupBoardShow.Create(_ShowStr: string);
begin
  ShowStr := _ShowStr;
end;

procedure TPlBackupBoardShow.Update;
var
  plBackupBoard : TRzPanel;
begin
  plBackupBoard := frmMainForm.plBackupBoard;
  if ( ShowStr = '' ) and ( plBackupBoard.Visible ) then
    BackupBoardInvisibleThread.ResetLastStr( plBackupBoard.Caption )
  else
  begin
    plBackupBoard.Caption := ShowStr;
    if ( ShowStr <> '' ) and ( not plBackupBoard.Visible ) then
    begin
      plBackupBoard.Visible := True;
      frmMainForm.plBackupBoardMain.Visible := True;
    end;
  end;
end;

{ TBackupBoardInvisibleThread }

procedure TBackupBoardInvisibleThread.BackupBoardInvisible;
begin
  if frmMainForm.plBackupBoard.Caption = LastStr then
  begin
    frmMainForm.plBackupBoard.Caption := '';
    frmMainForm.plBackupBoard.Visible := False;
    frmMainForm.plBackupBoardMain.Visible := False;
  end;
end;

constructor TBackupBoardInvisibleThread.Create;
begin
  inherited Create( True );
end;

destructor TBackupBoardInvisibleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupBoardInvisibleThread.Execute;
begin
  while not Terminated do
  begin
    while not Terminated and ( SecondsBetween( Now, LastTime ) < 2 ) do
      Sleep(100);

    if Terminated then
      Break;

    Synchronize( BackupBoardInvisible );

    if not Terminated then
      Suspend;
  end;

  inherited;
end;

procedure TBackupBoardInvisibleThread.ResetLastStr(_LastStr: string);
begin
  LastStr := _LastStr;
  LastTime := Now;
  Resume;
end;

{ TBackupTvSpaceInfo }

procedure TVstBackupFolderSetSpace.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TVstBackupFolderSetSpace.SetSize(_Size: Int64);
begin
  Size := _Size;
end;

procedure TVstBackupFolderSetSpace.Update;
begin
  inherited;

    // 不存在
  if not FindFolderNode then
    Exit;

    // Vst
  FolderData.FileCount := FileCount;
  FolderData.ItemSize := Size;

    // 刷新节点
  ResetFolderNode;
end;

{ TBackupProgressInfo }

constructor TBackupPgRefreshInfo.Create(_CompletedSize, _TotalSize: Int64);
begin
  CompletedSize := _CompletedSize;
  TotalSize := _TotalSize;
end;

procedure TBackupPgRefreshInfo.Update;
begin
  BackupProgress_Completed := CompletedSize;
  BackupProgress_Total := TotalSize;
end;

{ TBackupPgAddCompletedInfo }

constructor TBackupPgAddCompletedInfo.Create(_AddSize: Int64);
begin
  AddSize := _AddSize;
end;

procedure TBackupPgAddCompletedInfo.ShowProgress;
var
  ProgressStr : string;
  Percentage : Integer;
begin
    // 空间
  ProgressStr := MyPercentage.getCompareStr( BackupProgress_Completed, BackupProgress_Total );
  frmMainForm.plBackupProgressPercent.Caption :=  ProgressStr;

    // 百分比
  Percentage := MyPercentage.getPercent( BackupProgress_Completed, BackupProgress_Total );
  frmMainForm.PbBackup.Percent := Percentage;

    // 显示进度条
  if not frmMainForm.plBackupProgress.Visible then
    frmMainForm.plBackupProgress.Visible := True;

    // 隐藏进度条
  BackupProgressHideThread.ShowBackupProgress;
end;

procedure TBackupPgAddCompletedInfo.Update;
begin
    // 添加
  BackupProgress_Completed := BackupProgress_Completed + AddSize;
  BackupProgress_Completed := Min( BackupProgress_Completed, BackupProgress_Total );

    // 刷新显示
  ShowProgress;
end;

{ PathTypeIconUtil }

class function PathTypeIconUtil.getIcon(FullPath, PathType: string): Integer;
begin
  if PathType = PathType_File then
    Result := MyIcon.getIconByFileExt( FullPath )
  else
    Result := MyShellIconUtil.getFolderIcon;
end;

{ TBackupTvCopyCountInfo }

procedure TVstBackupPathSetCopyCount.ResetChildNode(ChildNode: PVirtualNode);
var
  SelectNode : PVirtualNode;
  ChildData : PVstBackupItemData;
begin
    // 重设 Copy 数
  ChildData := VstBackupItem.GetNodeData( ChildNode );
  ChildData.CopyCount := CopyCount;
  VstBackupItem.RepaintNode( ChildNode );

    // 刷新 子节点
  SelectNode := ChildNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    ResetChildNode( SelectNode );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstBackupPathSetCopyCount.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TVstBackupPathSetCopyCount.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // 设置 Copy 数
  ResetChildNode( PathNode );

    // 刷新节点
  RefreshPathNode;
end;

{ TBackupTvRemoveChildInfo }

procedure TVstBackupItemRemoveChild.Update;
begin
  inherited;

    // 不存在
  if not FindFolderNode then
    Exit;

    // 删除 选中的节点
  if VstBackupItem.Selected[ FolderNode ] then
  begin
        // ListView
    frmMainForm.lvFileStatus.Clear;
    frmMainForm.tbtnFsDetail.Enabled := False;
    frmMainForm.tbtnFsOpen.Enabled := False;
    frmMainForm.tbtnFsLvlExplorer.Enabled := False;
    frmMainForm.tbtnFsLvlRemove.Enabled := False;
  end;

    // 删除 界面
  vstBackupItem.DeleteNode( FolderNode );
end;

{ TBackupPgRemoveCompletedInfo }

constructor TBackupPgRemoveCompletedInfo.Create(_RemoveSize: Int64);
begin
  RemoveSize := _RemoveSize;
end;

procedure TBackupPgRemoveCompletedInfo.Update;
begin
    // 删除
  BackupProgress_Completed := BackupProgress_Completed - RemoveSize;
  BackupProgress_Completed := Max( BackupProgress_Completed, 0 );
end;

{ TPlBackupDesBoardShowInfo }

constructor TPlBackupDesBoardShowInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TPlBackupDesBoardShowInfo.SetShowType(_ShowType: string);
begin
  ShowType := _ShowType;
end;

procedure TPlBackupDesBoardShowInfo.ShowFileType;
var
  ShowStr : string;
begin
  if ShowType = BackupDesBroadType_Copy then
    ShowStr := 'Copying'
  else
  if ShowType = BackupDesBroadType_Removing then
    ShowStr := 'Removing'
  else
  if ShowType = BackupDesBroadType_Recycling then
    ShowStr := 'Recycling';

  ShowStr := frmMainForm.siLang_frmMainForm.GetText( ShowStr );
  ShowStr := ' ' + ShowStr;

    // 相同 则 跳过
  if frmMainForm.plBackupDesType.Caption = ShowStr then
    Exit;

  frmMainForm.plBackupDesType.Caption := ShowStr;
end;

procedure TPlBackupDesBoardShowInfo.Update;
begin
  ShowFileType;

  frmMainForm.plBackupDesShow.Caption := ExtractFileName( FilePath );
end;

{ TPlBackupDesBoardPercentInfo }

constructor TPlBackupDesBoardPercentInfo.Create(_Percent: Integer);
begin
  Percent := _Percent;
end;

procedure TPlBackupDesBoardPercentInfo.SetPercentCompareStr(
  _PercentCompareStr: string);
begin
  PercentCompareStr := _PercentCompareStr;
end;

procedure TPlBackupDesBoardPercentInfo.Update;
begin
  frmMainForm.PbLocalBackupCopy.Percent := Percent;
  frmMainForm.plLocalBackupCopyPercentShow.Caption := PercentCompareStr;
end;

{ TPlBackupDesBoardShowSizeInfo }

procedure TPlBackupDesBoardShowSizeInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TPlBackupDesBoardShowSizeInfo.Update;
var
  ShowStr : string;
begin
  ShowFileType;

  ShowStr := ExtractFileName( FilePath ) + '   ' + MySize.getFileSizeStr( FileSize );
  frmMainForm.plBackupDesShow.Caption := ShowStr;
end;

{ TPlBackupDesPercentVisibleInfo }

constructor TPlBackupDesPercentVisibleInfo.Create(_IsVisible: Boolean);
begin
  IsVisible := _IsVisible;
end;

procedure TPlBackupDesPercentVisibleInfo.SetExplorerPath(_ExplorerPath: string);
begin
  ExplorerPath := _ExplorerPath;
end;

procedure TPlBackupDesPercentVisibleInfo.Update;
var
  PercentageHeigh, ChangeHeight : Integer;
begin
  if IsVisible then
  begin
    frmMainForm.PbLocalBackupCopy.Percent := 0;
    Path_LocalCopyExplorer := ExplorerPath;
  end
  else
    Path_LocalCopyExplorer := '';

  PercentageHeigh := frmMainForm.plLocalBackupPercentage.Height;
  if not IsVisible and ( PercentageHeigh = PlLocalBackupDesProgress_Heigh ) then
    ChangeHeight := -PlLocalBackupDesProgress_Heigh
  else
  if IsVisible and ( PercentageHeigh = 0 ) then
    ChangeHeight := PlLocalBackupDesProgress_Heigh
  else
    ChangeHeight := 0;
  frmMainForm.plBackupDesBoard.Height := frmMainForm.plBackupDesBoard.Height + ChangeHeight;

  frmMainForm.plLocalCopyExplorer.Visible := IsVisible;
end;

{ TPlBackupDesBoardVisibleInfo }

constructor TPlBackupDesBoardVisibleInfo.Create(_IsVisible: Boolean);
begin
  IsVisible := _IsVisible;
end;

procedure TPlBackupDesBoardVisibleInfo.Update;
begin
  frmMainForm.plBackupDesBoard.Visible := IsVisible;
end;

{ TBackupLvReadFolderInfo }

procedure TBackupLvReadFolderInfo.AddBackupLv(
  BackupLvAddInfo: TBackupLvAddInfo);
begin
  BackupLvAddList.Add( BackupLvAddInfo );
end;

constructor TBackupLvReadFolderInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  BackupLvAddList := TBackupLvAddList.Create;
end;

destructor TBackupLvReadFolderInfo.Destroy;
begin
  BackupLvAddList.Free;
  inherited;
end;

procedure TBackupLvReadFolderInfo.Update;
var
  i : Integer;
begin
  inherited;

    // 选择的已经发生变化
  if FullPath <> TvNodePath_Selected then
    Exit;

    // 清空旧的
  LvBackupFile.Clear;

    // 显示新的
  for i := 0 to BackupLvAddList.Count - 1 do
    BackupLvAddList[i].Update;
end;

{ TBackupProgressHideThread }

constructor TBackupProgressHideThread.Create;
begin
  inherited Create( True );
end;

destructor TBackupProgressHideThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupProgressHideThread.Execute;
begin
  while not Terminated do
  begin
    while not Terminated and ( SecondsBetween( Now, LastShowTime ) < 2 ) do
      Sleep(100);

    if Terminated then
      Break;

      // 隐藏进度条
    Synchronize( HideProgress );

      // 挂起线程
    if SecondsBetween( Now, LastShowTime ) >= 2 then
      Suspend;
  end;
  inherited;
end;

procedure TBackupProgressHideThread.HideProgress;
begin
  if frmMainForm.plBackupProgress.Visible then
    frmMainForm.plBackupProgress.Visible := False;
end;

procedure TBackupProgressHideThread.ShowBackupProgress;
begin
  LastShowTime := Now;
  Resume;
end;

{ TBackupTvCompletedSpaceInfo }

procedure TVstBackupFolderAddCompletedSpace.Update;
var
  IsSelectNodeChild : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstBackupItemData;
begin
  inherited;

      // 不存在
  if not FindFolderNode then
    Exit;

    // 是否需要更新 ListView
  IsSelectNodeChild := MyMatchMask.CheckChild( FolderPath, TvNodePath_Selected );

    // 改变空间信息
  SelectNode := FolderNode;
  while Assigned( SelectNode ) and
        ( SelectNode <> vstBackupItem.RootNode )
  do
  begin
    SelectData := vstBackupItem.GetNodeData( SelectNode );
    SelectData.CompletedSpace := SelectData.CompletedSpace + CompletedSpace;

      // 刷新节点
    vstBackupItem.RepaintNode( SelectNode );

      // 刷新 ListView
    if IsSelectNodeChild then
      RefreshLvStatus( SelectNode );

    SelectNode := SelectNode.Parent;
  end;
end;

{ TBackupTvSetCompletedSpaceInfo }

procedure TVstBackupFolderSetCompletedSpace.SetLastCompletedSpace(
  _LastCompletedSpace: Int64);
begin
  LastCompletedSpace := _LastCompletedSpace;
end;

procedure TVstBackupFolderSetCompletedSpace.Update;
begin
  inherited;

    // 不存在
  if not FindFolderNode then
    Exit;

    // 已发生变化
  if FolderData.CompletedSpace <> LastCompletedSpace then
    Exit;

    // Vst
  FolderData.CompletedSpace := CompletedSpace;

    // 刷新节点
  ResetFolderNode;
end;

{ VstBackupItemUtil }

class function VstBackupItemUtil.getBackupStatus(CompletedSpace,
  TotalSpace: Int64): string;
var
  Percentage : Integer;
begin
  if CompletedSpace >= TotalSpace then
    Result := NodeStatus_Completed
  else
  if CompletedSpace = 0 then
    Result := NodeStatus_Incompleted
  else
  begin
    Percentage := MyPercentage.getPercent( CompletedSpace, TotalSpace );
    Result := MyPercentage.getPercentageStr( Percentage ) + ' ' + NodeStatus_Completed;
  end;
end;

class function VstBackupItemUtil.getHintStr(Node: PVirtualNode): string;
var
  vstBackupItem : TVirtualStringTree;
  NodeData : PVstBackupItemData;
  TempStr, HintStr : string;
  FullPath, SyncTimeStr, LasSyncStr, NextSyncStr: string;
begin
  vstBackupItem := frmMainForm.vstBackupItem;
  NodeData := vstBackupItem.GetNodeData( Node );
  FullPath := VstBackupItemUtil.getNodeFullPath( Node );
  LasSyncStr := DateTimeToStr( NodeData.LastSyncTime );
  if NodeData.IsAuctoSync and not NodeData.IsDiable then
  begin
    SyncTimeStr := TimeTypeUtil.getTimeShow( NodeData.SyncTimeType, NodeData.SyncTimeValue );
    NextSyncStr := DateTimeToStr( NodeData.NextSyncTime );
  end
  else
  begin
    SyncTimeStr := Sign_NA;
    NextSyncStr := Sign_NA;
  end;

  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintItemPath' );
  HintStr := TempStr + FullPath + #13#10;
  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintPersetCopy' );
  HintStr := HintStr + TempStr + IntToStr( NodeData.CopyCount ) + #13#10;
  if Node.Parent = vstBackupItem.RootNode then
  begin
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintSyncTime' );
    HintStr := HintStr + TempStr;
    TempStr := LanguageUtil.getSyncTimeStr( SyncTimeStr );
    HintStr := HintStr + TempStr  + #13#10;
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintLastSync' );
    LasSyncStr := LanguageUtil.getSyncTimeStr( LasSyncStr );
    HintStr := HintStr + TempStr + LasSyncStr + #13#10;
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'NextSync' );
    HintStr := HintStr + TempStr + NextSyncStr + #13#10;
  end;
  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'Status' );
  HintStr := HintStr + TempStr;
  TempStr := VstBackupItemUtil.getStatusHint( Node );
  TempStr := LanguageUtil.getPercentageStr( TempStr );
  HintStr := HintStr + TempStr;

  Result := HintStr;
end;

class function VstBackupItemUtil.getNextSyncTimeStr(Node: PVirtualNode): string;
var
  VstBackupitem : TVirtualStringTree;
  NodeData : PVstBackupItemData;
  ShowStr : string;
  ShowStrList : TStringList;
begin
  VstBackupItem := frmMainForm.vstBackupItem;
  NodeData := VstBackupitem.GetNodeData( Node );
  if not NodeData.IsAuctoSync or NodeData.IsDiable then
    Result := frmMainForm.siLang_frmMainForm.GetText( 'NA' )// Sign_NA
  else
  begin
    ShowStr := TimeTypeUtil.getMinShowStr( MinutesBetween( Now, NodeData.NextSyncTime ) );
    Result := LanguageUtil.getSyncTimeStr( ShowStr );
  end;
end;

class function VstBackupItemUtil.getNodeFullPath(Node: PVirtualNode): string;
var
  VstBackupitem : TVirtualStringTree;
  NodeData : PVstBackupItemData;
begin
  VstBackupItem := frmMainForm.vstBackupItem;

  Result := '';
  while Assigned( Node ) and ( Node <> VstBackupitem.RootNode ) do
  begin
    NodeData := VstBackupitem.GetNodeData( Node );
    if Result = '' then
      Result := NodeData.FolderName
    else
      Result := MyFilePath.getPath( NodeData.FolderName ) + Result;
    Node := Node.Parent;
  end;
end;

class function VstBackupItemUtil.getSelectPath: string;
var
  vstBackupItem : TVirtualStringTree;
begin
  Result := '';
  vstBackupItem := frmMainForm.vstBackupItem;
  if not Assigned( vstBackupItem.FocusedNode ) then
    Exit;

  Result := getNodeFullPath( vstBackupItem.FocusedNode );
end;

class function VstBackupItemUtil.getSelectPathList: TStringList;
var
  vstBackupItem : TVirtualStringTree;
  SelectNode : PVirtualNode;
  FullPath : string;
begin
  Result := TStringList.Create;

  vstBackupItem := frmMainForm.vstBackupItem;
  SelectNode := vstBackupItem.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    FullPath := getNodeFullPath( SelectNode );
    Result.Add( FullPath );
    SelectNode := vstBackupItem.GetNextSelected( SelectNode );
  end;
end;

class function VstBackupItemUtil.getStatus(Node: PVirtualNode): string;
var
  NodeData: PVstBackupItemData;
  TotalSize : Int64;
begin
  NodeData := frmMainForm.vstBackupItem.GetNodeData( Node );

  if NodeData.IsDiable then
    Result := NodeStatus_Disable
  else
  if not NodeData.IsExist then
    Result := NodeStatus_NotExists
  else
  if NodeData.FolderStatus = FolderStatus_Loading then
    Result := NodeStatus_Loading
  else
  if NodeData.FolderStatus = FolderStatus_Waiting then
    Result := NodeStatus_Waiting
  else
  if NodeData.FolderStatus = FolderStatus_Refreshing then
    Result := NodeStatus_Refreshing
  else
  if NodeData.FolderStatus = FolderStatus_Analyzing then
    Result := NodeStatus_Analyzing
  else
  if NodeData.FileCount = 0 then
    Result := NodeStatus_Empty
  else
  begin
    TotalSize := NodeData.CopyCount * NodeData.ItemSize;
    Result := getBackupStatus( NodeData.CompletedSpace, TotalSize );
  end;
end;

class function VstBackupItemUtil.getStatusHint(Node: PVirtualNode): string;
var
  NodeData: PVstBackupItemData;
  Percentage : Integer;
  TotalSize : Int64;
begin
  NodeData := frmMainForm.vstBackupItem.GetNodeData( Node );

  if NodeData.IsDiable then
    Result := NodeStatusHint_Disable
  else
  if not NodeData.IsExist then
    Result := NodeStatusHint_NotExists
  else
  if NodeData.FolderStatus = FolderStatus_Loading then
    Result := NodeStatusHint_Loading
  else
  if NodeData.FolderStatus = FolderStatus_Waiting then
    Result := NodeStatusHint_Waiting
  else
  if NodeData.FolderStatus = FolderStatus_Refreshing then
    Result := NodeStatusHint_Refreshing
  else
  if NodeData.FolderStatus = FolderStatus_Analyzing then
    Result := NodeStatusHint_Analyzing
  else
  if NodeData.FileCount = 0 then
    Result := NodeStatus_Empty
  else
  begin
    TotalSize := NodeData.CopyCount * NodeData.ItemSize;
    Result := getBackupStatus( NodeData.CompletedSpace, TotalSize );
  end;
end;

class function VstBackupItemUtil.getStatusIcon(Node: PVirtualNode): Integer;
var
  FindNodeIcon : TFindNodeIcon;
begin
  FindNodeIcon := TFindNodeIcon.Create( Node );
  Result := FindNodeIcon.get;
  FindNodeIcon.Free;
end;

class function VstBackupItemUtil.getStatusInt(Node: PVirtualNode): Integer;
var
  NodeData: PVstBackupItemData;
  Percentage : Integer;
  TotalSize : Int64;
begin
  NodeData := frmMainForm.vstBackupItem.GetNodeData( Node );

  if NodeData.IsDiable then
    Result := 0
  else
  if not NodeData.IsExist then
    Result := 1
  else
  if NodeData.FolderStatus = FolderStatus_Loading then
    Result := 2
  else
  if NodeData.FolderStatus = FolderStatus_Waiting then
    Result := 3
  else
  if NodeData.FolderStatus = FolderStatus_Refreshing then
    Result := 4
  else
  if NodeData.FolderStatus = FolderStatus_Analyzing then
    Result := 5
  else
  if NodeData.FileCount = 0 then
    Result := 6
  else
  begin
    TotalSize := NodeData.CopyCount * NodeData.ItemSize;
    if TotalSize = NodeData.CompletedSpace then  // Completed
      Result := 202
    else
    if NodeData.CompletedSpace = 0 then  // Incompleted
      Result := 7
    else
    begin
      Percentage := MyPercentage.getPercent( NodeData.CompletedSpace, TotalSize );
      if ( Percentage > 100 ) or ( Percentage < 0 ) then
        Result := 201
      else
        Result := 100 + Percentage;
    end;
  end;
end;

class function VstBackupItemUtil.IsRootPath(FolderPath: string): Boolean;
var
  vstBackupItem : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstBackupItemData;
begin
  Result := False;

  vstBackupItem := frmMainForm.vstBackupItem;
  SelectNode := vstBackupItem.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstBackupItem.GetNodeData( SelectNode );
    if NodeData.FolderName = FolderPath then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TBackupPgShowInfo }

procedure TBackupPgShowInfo.Update;
begin
    // 显示进度条
  if not frmMainForm.plBackupProgress.Visible then
    frmMainForm.plBackupProgress.Visible := True;

    // 定时隐藏
  BackupProgressHideThread.ShowBackupProgress;
end;

{ TFindNodeIcon }

constructor TFindNodeIcon.Create( Node : PVirtualNode );
var
  NodeData : PVstBackupItemData;
begin
  NodeData := frmMainForm.vstBackupItem.GetNodeData( Node );
  PathType := NodeData.PathType;
  IsDisable := NodeData.IsDiable;
  IsExist := NodeData.IsExist;
  IsEmpty := NodeData.FileCount = 0;
  IsLoading := NodeData.FolderStatus = FolderStatus_Loading;
  IsWaiting := NodeData.FolderStatus = FolderStatus_Waiting;
  IsRefreshing := NodeData.FolderStatus = FolderStatus_Refreshing;
  IsAnalyzing := NodeData.FolderStatus = FolderStatus_Analyzing;
  IsEmptyBackup := NodeData.CompletedSpace = 0;
  IsFullBackup := NodeData.CompletedSpace >= ( NodeData.CopyCount * NodeData.ItemSize );
end;

function TFindNodeIcon.get: Integer;
begin
  if PathType = PathType_Folder then
    Result := getFolderIcon
  else
  if PathType = PathType_File then
    Result := getFileIcon;
end;

function TFindNodeIcon.getFileIcon: Integer;
begin
  if IsDisable then
    Result := NodeIcon_FileDisable
  else
  if not IsExist then
    Result := NodeIcon_FileNotExists
  else
  if IsLoading then
    Result := NodeIcon_FileLoading
  else
  if IsWaiting then
    Result := NodeIcon_FileWaiting
  else
  if IsRefreshing then
    Result := NodeIcon_FileRefreshing
  else
  if IsAnalyzing then
    Result := NodeIcon_FileAnalyzing
  else
  if IsFullBackup then
    Result := NodeIcon_FileCompleted
  else
  if IsEmptyBackup then
    Result := NodeIcon_FileIncompleted
  else
    Result := NodeIcon_FilePartCompleted;
end;

function TFindNodeIcon.getFolderIcon: Integer;
begin
  if IsDisable then
    Result := NodeIcon_FolderDisable
  else
  if not IsExist then
    Result := NodeIcon_FolderNotExists
  else
  if IsLoading then
    Result := NodeIcon_FolderLoading
  else
  if IsWaiting then
    Result := NodeIcon_FolderWaiting
  else
  if IsRefreshing then
    Result := NodeIcon_FolderRefreshing
  else
  if IsAnalyzing then
    Result := NodeIcon_FolderAnalyzing
  else
  if IsEmpty then
    Result := NodeIcon_FolderEmpty
  else
  if IsFullBackup then
    Result := NodeIcon_FolderCompleted
  else
  if IsEmptyBackup then
    Result := NodeIcon_FolderIncompleted
  else
    Result := NodeIcon_FolderPartCompleted;
end;


{ TVstBackupItemChange }

procedure TVstBackupPathChange.Update;
begin
  VstBackupItem := frmMainForm.vstBackupItem;
end;

{ TVstBackupItemIsExist }

procedure TVstBackupPathIsExist.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TVstBackupPathIsExist.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // Vst
  PathData.IsExist := IsExist;

    // 刷新节点
  RefreshPathNode;
end;

{ TVstBackupItemResetStatus }

procedure TVstBackupFolderSetStatus.SetPathStatus(_PathStatus: string);
begin
  PathStatus := _PathStatus;
end;

procedure TVstBackupFolderSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindFolderNode then
    Exit;

    // Vst
  FolderData.FolderStatus := PathStatus;

    // 刷新节点
  ResetFolderNode;
end;

{ TLvBackupFileChangeInfo }

procedure TLvBackupFileChangeInfo.Update;
begin
  LvBackupFile := frmMainForm.lvFileStatus;
end;

{ LvBackupFileUtil }

class function LvBackupFileUtil.getBackupStatus(CompletedSpace,
  TotalSpace: Int64): string;
begin
  if CompletedSpace >= TotalSpace then
    Result := BackupStatus_Completed
  else
  if CompletedSpace = 0 then
    Result := BackupStatus_Incompleted
  else
    Result := BackupStatus_PartCompleted
end;

class function LvBackupFileUtil.getSelectPath: string;
var
  SelectItem: TListItem;
  SelectData: TBackupLvFaceData;
begin
  Result := '';

  SelectItem := frmMainForm.lvFileStatus.Selected;
  if SelectItem = nil then
    Exit;

  SelectData := SelectItem.Data;
  Result := SelectData.FullPath;
end;

class function LvBackupFileUtil.IsFileShow(FilePath: string): Boolean;
begin
  Result := ( ExtractFileDir( FilePath ) = TvNodePath_Selected ) or
            ( FilePath = TvNodePath_Selected );
end;

class function LvBackupFileUtil.IsFolderShow(FolderPath: string): Boolean;
begin
  Result := ExtractFileDir( FolderPath ) = TvNodePath_Selected;
end;

{ TVstBackupFolderChange }

constructor TVstBackupFolderChange.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

function TVstBackupFolderChange.FindChildNode(ParentNode: PVirtualNode;
  ChileName: string): PVirtualNode;
var
  ChildNode : PVirtualNode;
  ChildData : PVstBackupItemData;
begin
  Result := nil;

  ChildNode := ParentNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VstBackupItem.GetNodeData( ChildNode );
    if ChildData.FolderName = ChileName then
    begin
      Result := ChildNode;
      Break;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TVstBackupFolderChange.FindFolderNode: Boolean;
var
  ParentNode : PVirtualNode;
  ParentData : PVstBackupItemData;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
  Result := False;

    // 找不到 根节点
  if not FindRootFolderNode then
    Exit;

    // 根节点 是 目标节点
  if RootFolderData.FolderName = FolderPath then
  begin
    Result := True;
    FolderNode := RootFolderNode;
    FolderData := RootFolderData;
    Exit;
  end;

    // 从根目录向下寻找
  ParentNode := RootFolderNode;
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderData.FolderName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // 寻找子目录
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

    ParentNode := FindChildNode( ParentNode, FolderName );
    if ParentNode = nil then // 不存在目录
      Exit;

      // 下一层
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

  FolderNode := ParentNode;
  FolderData := VstBackupItem.GetNodeData( FolderNode );
  Result := True;
end;

function TVstBackupFolderChange.FindRootFolderNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupItemData;
begin
  Result := False;
  SelectNode := VstBackupItem.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackupItem.GetNodeData( SelectNode );
    if MyMatchMask.CheckEqualsOrChild( FolderPath, SelectData.FolderName ) then
    begin
      RootFolderNode := SelectNode;
      RootFolderData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstBackupFolderChange.ResetFolderNode;
begin
  VstBackupItem.RepaintNode( FolderNode );
end;

{ TVstBackupPathSetStatus }

procedure TVstBackupPathSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstBackupPathSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // 设置目录状态
  PathData.FolderStatus := Status;

  RefreshPathNode;
end;

{ TVstBackupFolderChangeCompletedSpace }

procedure TVstBackupFolderChangeCompletedSpace.RefreshLvStatus(
  Node: PVirtualNode);
var
  SelectPath, Status, ShowStatus : string;
  SelectData : PVstBackupItemData;
  TotalSpace, CompletedSpace : Int64;
  BackupLvStatusInfo : TBackupLvStatusInfo;
begin
    // 获取 节点完整路径，并判断是否需要更新
  SelectPath := VstBackupItemUtil.getNodeFullPath( Node );
  if not LvBackupFileUtil.IsFolderShow( SelectPath ) then
    Exit;

    // 提取 节点信息
  SelectData := VstBackupItem.GetNodeData( Node );
  TotalSpace := SelectData.CopyCount * SelectData.ItemSize;
  Status := LvBackupFileUtil.getBackupStatus( SelectData.CompletedSpace, TotalSpace );
  ShowStatus := VstBackupItemUtil.getBackupStatus( SelectData.CompletedSpace, TotalSpace );

    // 刷新 节点信息
  BackupLvStatusInfo := TBackupLvStatusInfo.Create( SelectPath );
  BackupLvStatusInfo.SetCopyCountStatus( '' );
  BackupLvStatusInfo.SetStatusInfo( Status, ShowStatus );
  MyBackupFileFace.AddChange( BackupLvStatusInfo );
end;

procedure TVstBackupFolderChangeCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TVstBackupFolderRemoveCompletedSpace }

procedure TVstBackupFolderRemoveCompletedSpace.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupItemData;
begin
  inherited;

      // 不存在
  if not FindFolderNode then
    Exit;

    // 改变空间信息
  SelectNode := FolderNode;
  while Assigned( SelectNode ) and
        ( SelectNode <> vstBackupItem.RootNode )
  do
  begin
    SelectData := vstBackupItem.GetNodeData( SelectNode );
    SelectData.CompletedSpace := SelectData.CompletedSpace - CompletedSpace;

      // 刷新 节点
    vstBackupItem.RepaintNode( SelectNode );

      // 刷新 ListView 数据
    RefreshLvStatus( SelectNode );

    SelectNode := SelectNode.Parent;
  end;
end;


{ TVstBackupPathRefreshSelectNode }

procedure TVstBackupPathRefreshSelectNode.Update;
var
  RefreshPath : string;
begin
  inherited;

    // 没有选择
  if TvNodePath_Selected = '' then
    Exit;

    // 刷新选择节点
  RefreshPath := TvNodePath_Selected;

    // 刷新节点 与 更新节点存在 关系
  if MyMatchMask.CheckEqualsOrChild( RefreshPath, FullPath ) or
     MyMatchMask.CheckChild( FullPath, RefreshPath )
  then
    MyBackupFileControl.ShowBackupFileStatusNomal( RefreshPath );
end;

{ TLvBackupPathProData }

constructor TLvBackupPathProData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvBackupPathProChange }

procedure TLvBackupPathProChange.Update;
begin
  LvBackupPathPro := frmBackupProperties.LvBackupItem;
end;

{ TLvBackupPathProWrite }

constructor TLvBackupPathProWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvBackupPathProWrite.FindPathItem: Boolean;
var
  i : Integer;
  SelectData : TLvBackupPathProData;
begin
  Result := False;

  for i := 0 to LvBackupPathPro.Items.Count - 1 do
  begin
    SelectData := LvBackupPathPro.Items[i].Data;
    if SelectData.FullPath = FullPath then
    begin
      PathItem := LvBackupPathPro.Items[i];
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvBackupPathProAdd }

procedure TLvBackupPathProAdd.Update;
var
  PathData : TLvBackupPathProData;
begin
  inherited;

    // 已存在
  if FindPathItem then
    Exit;

    // 创建
  PathData := TLvBackupPathProData.Create( FullPath );
  with LvBackupPathPro.Items.Add do
  begin
    Caption := ExtractFileName( FullPath );
    SubItems.Add('');
    ImageIndex := MyIcon.getIconByFilePath( FullPath );
    Data := PathData;
  end;
end;

{ TLvBackupPathProRemove }

procedure TLvBackupPathProRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPathItem then
    Exit;

    // 删除
  LvBackupPathPro.Items.Delete( PathIndex );
end;

{ TVstBackupPathSetLastSyncTime }

procedure TVstBackupPathSetLastSyncTime.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TVstBackupPathSetLastSyncTime.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // 设置 上一次 同步时间
  PathData.LastSyncTime := LastSyncTime;

    // 计算下次同步时间
  RefreshNextSyncTime;

    // 刷新节点
  RefreshPathNode;
end;


{ TVstBackupPathSetSyncMins }

procedure TVstBackupPathSetSyncTime.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TVstBackupPathSetSyncTime.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue : Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstBackupPathSetSyncTime.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // 设置 上一次 同步时间
  PathData.IsAuctoSync := IsAutoSync;
  PathData.SyncTimeType := SyncTimeType;
  PathData.SyncTimeValue := SyncTimeValue;

    // 计算下次同步时间
  RefreshNextSyncTime;

    // 刷新节点
  RefreshPathNode;
end;

{ TVstBackuppathRefreshNextSyncTime }

procedure TVstBackuppathRefreshNextSyncTime.Update;
begin
  inherited;

    // 路径不存在
  if not FindPathNode then
    Exit;

    // 刷新路径信息
  RefreshPathNode;
end;

{ TVstBackupPathIsDisable }

procedure TVstBackupPathIsDisable.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstBackupPathIsDisable.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

    // Vst
  PathData.IsDiable := IsDisable;

    // 刷新节点
  RefreshPathNode;
end;


{ LvBackupFileStatusUtil }

class function LvBackupFileStatusUtil.getIsFolder(FilePath: string): Boolean;
var
  LvFileStatus : TListView;
  i : Integer;
  SelectData: TBackupLvFaceData;
begin
  Result := False;

  LvFileStatus := frmMainForm.lvFileStatus;
  for i := 0 to LvFileStatus.Items.Count - 1 do
  begin
    SelectData := LvFileStatus.Items[i].Data;
    if SelectData.FullPath = FilePath then
    begin
      Result := SelectData.IsFolder;
      break;
    end;
  end;
end;

class function LvBackupFileStatusUtil.getSelectPath: string;
var
  SelectItem: TListItem;
  SelectData: TBackupLvFaceData;
begin
  Result := '';

  SelectItem := frmMainForm.lvFileStatus.Selected;
  if SelectItem = nil then
    Exit;

  SelectData := SelectItem.Data;
  Result := SelectData.FullPath;
end;

class function LvBackupFileStatusUtil.getSelectPathList: TStringList;
var
  LvFileStatus : TListView;
  i : Integer;
  SelectData: TBackupLvFaceData;
begin
  Result := TStringList.Create;

  LvFileStatus := frmMainForm.lvFileStatus;
  for i := 0 to LvFileStatus.Items.Count - 1 do
  begin
    if LvFileStatus.Items[i].Selected then
    begin
      SelectData := LvFileStatus.Items[i].Data;
      Result.Add( SelectData.FullPath );
    end;
  end;
end;

{ TPlBackupBoardIconShow }

constructor TPlBackupBoardIconShow.Create(_IsShow: Boolean);
begin
  IsShow := _IsShow;
end;

procedure TPlBackupBoardIconShow.Update;
begin
  inherited;

  frmMainForm.plBackupBoardIcon.Visible := IsShow;
end;

{ LanguageUtil }

class function LanguageUtil.getPercentageStr(Str: string): string;
var
  ShowStrList : TStringList;
begin
  ShowStrList := MySplitStr.getList( Str, ' ' );
  if ShowStrList.Count = 3 then
  begin
    if ShowStrList[1] <> '%' then
      ShowStrList[0] := frmMainForm.siLang_frmMainForm.GetText( ShowStrList[0] );
    ShowStrList[2] := frmMainForm.siLang_frmMainForm.GetText( ShowStrList[2] );
    Result := ShowStrList[0] + ' ' + ShowStrList[1] + ' ' + ShowStrList[2];
  end
  else
    Result := frmMainForm.siLang_frmMainForm.GetText( Str );
  ShowStrList.Free;
end;

class function LanguageUtil.getSyncTimeStr(Str: string): string;
var
  ShowStr : string;
  ShowStrList : TStringList;
begin
  ShowStr := Str;
  ShowStrList := MySplitStr.getList( ShowStr, ' ' );
  if ShowStrList.Count = 2 then
  begin
    ShowStrList[1] := frmMainForm.siLang_frmMainForm.GetText( ShowStrList[1] );
    ShowStr := ShowStrList[0] + ' ' + ShowStrList[1];
  end;
  ShowStrList.Free;
  Result := ShowStr;
end;

end.
