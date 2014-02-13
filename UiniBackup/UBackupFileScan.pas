unit UBackupFileScan;

interface

uses Generics.Collections, UChangeInfo, SyncObjs, SysUtils, StrUtils, Windows, Classes,
     UFileBaseInfo, UMyUtil, UModelUtil, uDebug, DateUtils;

type

{$Region ' 扫描文件夹核心算法 '}

    // 扫描处理 父类
  TFileScannerBase = class
  protected
    ScanPath : string;  // 扫描路径
    ScanRootPath : string; // 扫描的根路径
  protected
    FileCount : Integer;  // 文件数
    FolderSpace : Int64; // 路径空间大小
  public
    constructor Create( _ScanPath : string );
    procedure SetScanRootPath( _ScanRootPath : string );
  protected    // 扫描时 文件变化
    procedure FileAddHandle( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure FileModifyHandle( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure FileRemoveHandle( FilePath : string );
  protected    // 扫描时 目录变化
    procedure FolderAddHandle( FolderPath : string; FileTime : TDateTime );
    procedure FolderRemoveHandle( FolderPath : string );
  protected    // 设置路径空间信息
    procedure ResetFolderSpaceInfo;
  protected    // 状态变化
    procedure AddFolderRefreshing;
    procedure RemoveFolderRefreshing;
  end;

    // 文件夹比较扫描
  TFolderScanner = class( TFileScannerBase )
  private
    SleepCount, TotalFileCount : Integer;   // 计算扫描目录，每 10 个 sleep 1 秒
  private
    IncludeFilterList : TFileFilterList; // 包含过滤器
    ExcludeFilterList : TFileFilterList; // 排除过滤器
  private
    LastFolderInfo : TTempFolderInfo;
    LastChildFileHash : TTempFileHash;
    LastChildFolderHash : TTempFolderHash;
  public
    procedure SetFilterList( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure SetCountInfo( _SleepCount, _TotalFileCount : Integer );
    procedure Update;
  private
    procedure FindLastFolderInfo;
    procedure DeeteLastFolderInfo;
  private
    procedure CheckNewFiles;
    procedure CheckFileAdd( FileName : string; FileSize : Int64; FileTime : TDateTime );
    procedure CheckFolderAdd( FolderName : string; FolderTime : TDateTime );
  private
    procedure CheckOldFiles;
  private
    function CheckNextSearch : Boolean;
    procedure ResetBackupBoardFileCount;
  private
    function IsSearchFile( FilePath : string; sch : TSearchRec ): Boolean;
    function IsSearchFolder( FolderPath : string ): Boolean;
  end;

    // 文件 扫描
  TFileScanner = class( TFileScannerBase )
  private
    OldFileSize : Int64;
    OldFileTime : TDateTime;
  protected
    NewFileSize : Int64;
  public
    procedure Update;
  private
    function FindOldFileInfo : Boolean;
    procedure ResetBackupBoardFileCount;
  end;

{$EndRegion}

    // 扫描路径 信息
  TBackupScanPathInfo = class
  public
    FullPath : string;
    IsShowFreeLimt : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
  end;
  TBackupScanPathList = class( TObjectList<TBackupScanPathInfo> );

    // 扫描路径 处理
  TBackupPathScanHandle = class
  private
    BackupScanPathInfo : TBackupScanPathInfo;
    ScanPath : string;
  private
    PathSpace : Int64;
    PathFileCount : Integer;
  public
    constructor Create( _BackupScanPathInfo : TBackupScanPathInfo );
    procedure Update;
  private
    procedure AddBackupBoard;
    procedure FileScanner;   // 扫描的路径是 文件
    procedure FolderScanner; // 扫描的路径是 目录
    procedure RemoveBackupBoard;
  private
    function IsStartScan : Boolean;
    procedure ResetBackupPathSpace; // 设置备份路径空间信息
    procedure BackupSelectRefresh; // 刷新 Listview
    procedure ResetLastSyncTime; // 重设上一次备份时间
    procedure BackupNow;
  end;

    // 扫描路径 线程
  TBackupFileScanThread = class( TThread )
  private
    Lock : TCriticalSection;
    BackupScanPathList : TBackupScanPathList;
  public
    constructor Create;
    procedure AddScanPathInfo( BackupScanPathInfo : TBackupScanPathInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextScanPathInfo : TBackupScanPathInfo;
    procedure HandleScanPath( BackupScanPathInfo : TBackupScanPathInfo );
  end;

    // 备份文件 扫描的信息
  TMyBackupFileScanInfo = class
  private
    IsRun : Boolean;
    BackupFileScanThread : TBackupFileScanThread;
  public
    constructor Create;
    procedure AddScanPathInfo( BackupScanPathInfo : TBackupScanPathInfo );
    procedure StopFileScan;
  end;


const
  SearchCount_Sleep : Integer = 10;  // 搜索 10 个文件 Sleep 1 毫秒


var
  MyBackupFileScanInfo : TMyBackupFileScanInfo;  // 扫描的路径信息

implementation

uses UBackupInfoFace, UBackupInfoXml, UMyBackupInfo,UBackupUtil, UBackupBoardInfo, UBackupJobScan,
     UBackupInfoControl;


{ TFolderScanner }

function TFolderScanner.CheckNextSearch: Boolean;
begin
    // 交出 CPU
  Inc( SleepCount );
  if SleepCount >= SearchCount_Sleep then
  begin
    Sleep( 1 );
    SleepCount := 0;
  end;
  ResetBackupBoardFileCount;

    // 扫描路径是否存在
  Result := MyBackupFileScanInfo.IsRun;
  Result := Result and MyBackupPathInfoUtil.ReadIsEnable( ScanPath );
end;

procedure TFolderScanner.ResetBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusFileCountInfo.SetFileCount( TotalFileCount );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

procedure TFolderScanner.CheckFileAdd(FileName: string; FileSize: Int64;
  FileTime: TDateTime);
var
  FilePath : string;
begin
  FilePath := MyFilePath.getPath( ScanPath ) + FileName;

    // 新增一个文件
  if not LastChildFileHash.ContainsKey( FileName ) then
    FileAddHandle( FilePath, FileSize, FileTime )
  else
  begin
      // 修改了一个文件
    if ( LastChildFileHash[ FileName ].FileSize <> FileSize ) or
        not MyDatetime.Equals( LastChildFileHash[ FileName ].LastWriteTime, FileTime )
    then
      FileModifyHandle( FilePath, FileSize, FileTime );

      // 移除已处理文件
    LastChildFileHash.Remove( FileName );
  end;
end;

procedure TFolderScanner.CheckFolderAdd(FolderName: string; FolderTime : TDateTime);
var
  IsFolder : Boolean;
  FolderSize : Int64;
  FolderPath : string;
  FolderScanner : TFolderScanner;
begin
  FolderSize := 0;
  FolderPath := MyFilePath.getPath( ScanPath ) + FolderName;

    // 新增一个目录
  if not LastChildFolderHash.ContainsKey( FolderName ) then
    FolderAddHandle( FolderPath, FolderTime )
  else  // 移除已处理的目录
    LastChildFolderHash.Remove( FolderName );

    // 扫描下一层文件夹
  FolderScanner := TFolderScanner.Create( FolderPath );
  FolderScanner.SetScanRootPath( ScanRootPath );
  FolderScanner.SetFilterList( IncludeFilterList, ExcludeFilterList );
  FolderScanner.SetCountInfo( SleepCount, TotalFileCount );
  FolderScanner.Update;
  SleepCount := FolderScanner.SleepCount;  // 刷新 Scan Count
  FolderSpace := FolderSpace + FolderScanner.FolderSpace;
  FileCount := FileCount + FolderScanner.FileCount;
  TotalFileCount := FolderScanner.TotalFileCount;
  FolderScanner.Free;
end;

procedure TFolderScanner.CheckNewFiles;
var
  sch : TSearchRec;
  SearcFullPath, FileName, FilePath : string;
  IsFolder, IsSearch : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile , sch ) = 0 then
  begin
    repeat
        // 检查是否继续扫描
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 文件路径
      FilePath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( FilePath );
      if IsFolder then
        IsSearch := IsSearchFolder( FilePath )
      else
        IsSearch := IsSearchFile( FilePath, sch );
      if not IsSearch then // 已经被过滤
        Continue;

        // 获取修改时间
      FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

        // 检查下一层目录
      if IsFolder then
        CheckFolderAdd( FileName, FileTime )
      else
      begin
        FileSize := sch.Size;
        FolderSpace := FolderSpace + FileSize;
        Inc( FileCount );
        Inc( TotalFileCount );

          // 检查文件信息
        CheckFileAdd( FileName, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TFolderScanner.CheckOldFiles;
var
  pf : TTempFilePart;
  pfd : TTempFolderPart;
  FileName, FolderName : string;
  FilePath, FolderPath : string;
begin
    // 扫描 已删除的 旧文件信息
  for pf in LastChildFileHash do
  begin
      // 检查是否继续扫描
    if not CheckNextSearch then
      Break;

      // 移除 旧文件
    FilePath := MyFilePath.getPath( ScanPath ) + pf.Value.FileName;
    FileRemoveHandle( FilePath );
  end;

    // 扫描 已删除的 旧目录信息
  for pfd in LastChildFolderHash do
  begin
      // 检查是否继续扫描
    if not CheckNextSearch then
      Break;

      // 移除 旧目录
    FolderPath := MyFilePath.getPath( ScanPath ) + pfd.Value.FileName;
    FolderRemoveHandle( FolderPath );
  end;
end;

procedure TFolderScanner.DeeteLastFolderInfo;
begin
  LastFolderInfo.Free;
end;

procedure TFolderScanner.FindLastFolderInfo;
begin
    // 读取 缓存
  LastFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderBaseInfo( ScanPath );
  LastChildFileHash := LastFolderInfo.TempFileHash;
  LastChildFolderHash := LastFolderInfo.TempFolderHash;
end;

function TFolderScanner.IsSearchFile(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := False;

    // 不在包含列表中
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := True;
end;

function TFolderScanner.IsSearchFolder(FolderPath: string): Boolean;
begin
  Result := False;

    // 不在包含列表中
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := True;
end;

procedure TFolderScanner.SetCountInfo(_SleepCount, _TotalFileCount : Integer);
begin
  SleepCount := _SleepCount;
  TotalFileCount := _TotalFileCount;
end;

procedure TFolderScanner.SetFilterList(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TFolderScanner.Update;
begin
    // 界面显示正在刷新
  AddFolderRefreshing;

    // 访问历史缓存数据
  FindLastFolderInfo;

    // 检查新的文件结构
  CheckNewFiles;

    // 检查旧的文件结构
  CheckOldFiles;

    // 设置 目录 空间数据
  ResetFolderSpaceInfo;

    // 删除 缓存数据
  DeeteLastFolderInfo;

    // 移除界面刷新显示
  RemoveFolderRefreshing;
end;

{ TMyBackupScanInfo }

procedure TMyBackupFileScanInfo.AddScanPathInfo(
  BackupScanPathInfo: TBackupScanPathInfo);
begin
  if not IsRun then
    Exit;

  BackupFileScanThread.AddScanPathInfo( BackupScanPathInfo );
end;

constructor TMyBackupFileScanInfo.Create;
begin
  IsRun := True;
  BackupFileScanThread := TBackupFileScanThread.Create;
end;

procedure TMyBackupFileScanInfo.StopFileScan;
begin
  IsRun := False;
  BackupFileScanThread.Free;
end;

{ TRootFolderScanner }

procedure TBackupPathScanHandle.AddBackupBoard;
var
  BackupItemStatusAddInfo : TBackupItemStatusAddInfo;
begin
  BackupItemStatusAddInfo := TBackupItemStatusAddInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusAddInfo.SetFullPath( ScanPath );
  MyBackupBoardInfo.AddChange( BackupItemStatusAddInfo );
end;

procedure TBackupPathScanHandle.BackupNow;
var
  BackupPathSyncHandle : TBackupPathSyncHandle;
begin
  BackupPathSyncHandle := TBackupPathSyncHandle.Create( ScanPath );
  BackupPathSyncHandle.SetIsShowFreeLimt( BackupScanPathInfo.IsShowFreeLimt );
  BackupPathSyncHandle.Update;
  BackupPathSyncHandle.Free;
end;

procedure TBackupPathScanHandle.BackupSelectRefresh;
var
  BackupSelectRefreshHandle : TBackupSelectRefreshHandle;
begin
  BackupSelectRefreshHandle := TBackupSelectRefreshHandle.Create( ScanPath );
  BackupSelectRefreshHandle.Update;
  BackupSelectRefreshHandle.Free;
end;

constructor TBackupPathScanHandle.Create(
  _BackupScanPathInfo: TBackupScanPathInfo);
begin
  BackupScanPathInfo := _BackupScanPathInfo;
  ScanPath := BackupScanPathInfo.FullPath;
end;

procedure TBackupPathScanHandle.FileScanner;
var
  FileScanner : TFileScanner;
begin
    // 扫描文件
  FileScanner := TFileScanner.Create( ScanPath );
  FileScanner.SetScanRootPath( ScanPath );
  FileScanner.Update;
  PathSpace := FileScanner.FolderSpace;
  PathFileCount := 1;
  FileScanner.Free;
end;


procedure TBackupPathScanHandle.FolderScanner;
var
  IncludeFilterList : TFileFilterList;
  ExcludeFilterList : TFileFilterList;
  FolderScanner : TFolderScanner;
begin
    // 读取过滤器 缓存
  IncludeFilterList := MyBackupPathInfoUtil.ReadIncludeFilter( ScanPath );
  ExcludeFilterList := MyBackupPathInfoUtil.ReadExcludeFilter( ScanPath );

    // 扫描目录
  FolderScanner := TFolderScanner.Create( ScanPath );
  FolderScanner.SetScanRootPath( ScanPath );
  FolderScanner.SetFilterList( IncludeFilterList, ExcludeFilterList );
  FolderScanner.SetCountInfo( 0, 0 );
  FolderScanner.Update;
  PathSpace := FolderScanner.FolderSpace;
  PathFileCount := FolderScanner.FileCount;
  FolderScanner.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

function TBackupPathScanHandle.IsStartScan: Boolean;
var
  BackupPathSetExistHandle : TBackupPathSetExistHandle;
begin
  Result := False;

    // 文件确认
  if ScanPath = BackupFileScanType_FileConfirm then
  begin
    BackupNow;
    Exit;
  end;

    // 已删除 或 已禁止 备份
  if not MyBackupPathInfoUtil.ReadIsEnable( ScanPath ) then
    Exit;

  // 扫描路径 是否存在
  Result := MyFilePath.getIsExist( ScanPath );

    // 显示路径是否存在
  BackupPathSetExistHandle := TBackupPathSetExistHandle.Create( ScanPath );
  BackupPathSetExistHandle.SetIsExist( Result );
  BackupPathSetExistHandle.Update;
  BackupPathSetExistHandle.Free;
end;

procedure TBackupPathScanHandle.RemoveBackupBoard;
var
  BackupItemStatusRemoveInfo : TBackupItemStatusRemoveInfo;
begin
  BackupItemStatusRemoveInfo := TBackupItemStatusRemoveInfo.Create( BackupItemStatusType_Refreshing );
  MyBackupBoardInfo.AddChange( BackupItemStatusRemoveInfo );
end;

procedure TBackupPathScanHandle.ResetBackupPathSpace;
var
  BackupPathSetSpaceHandle : TBackupPathSetSpaceHandle;
begin
    // 非根路径
  if not MyBackupPathInfoUtil.ReadIsRootPath( ScanPath ) then
    Exit;

  BackupPathSetSpaceHandle := TBackupPathSetSpaceHandle.Create( ScanPath );
  BackupPathSetSpaceHandle.SetSpaceInfo( PathSpace, PathFileCount );
  BackupPathSetSpaceHandle.Update;
  BackupPathSetSpaceHandle.Free;
end;

procedure TBackupPathScanHandle.ResetLastSyncTime;
var
  BackupPathSetLastSyncTimeHandle : TBackupPathSetLastSyncTimeHandle;
begin
  BackupPathSetLastSyncTimeHandle := TBackupPathSetLastSyncTimeHandle.Create( ScanPath );
  BackupPathSetLastSyncTimeHandle.SetLastSyncTime( Now );
  BackupPathSetLastSyncTimeHandle.Update;
  BackupPathSetLastSyncTimeHandle.Free;
end;

procedure TBackupPathScanHandle.Update;
begin
    // 不用扫描
  if not IsStartScan then
    Exit;

    // 显示 正在扫描
  AddBackupBoard;

    // 扫描路径
  if FileExists( ScanPath ) then
    FileScanner
  else
  if DirectoryExists( ScanPath ) then
    FolderScanner;

    // 移除显示
  RemoveBackupBoard;

    // 设置 路径空间信息
  ResetBackupPathSpace;

    // 刷新 Listview
  BackupSelectRefresh;

    // 重设上一次备份时间
  ResetLastSyncTime;

    // 立刻备份
  BackupNow;
end;

{ TFileScanner }

procedure TFileScanner.ResetBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Refreshing );
  BackupItemStatusFileCountInfo.SetFileCount( 1 );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

function TFileScanner.FindOldFileInfo: Boolean;
var
  TempFileInfo : TTempFileInfo;
begin
  Result := False;

    // 访问缓存数据
  TempFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileBaseInfo( ScanPath );
  if TempFileInfo = nil then
    Exit;

  OldFileSize := TempFileInfo.FileSize;
  OldFileTime := TempFileInfo.LastWriteTime;

  TempFileInfo.Free;

  Result := True;
end;

procedure TFileScanner.Update;
var
  IsExistOld : Boolean;
  NewFileTime : TDateTime;
begin
    // 界面显示正在刷新
  AddFolderRefreshing;

    // 上一次 扫描的文件信息
  IsExistOld := FindOldFileInfo;

    // 当前扫描的文件信息
  NewFileSize := MyFileInfo.getFileSize( ScanPath );
  NewFileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // 新增文件
  if not IsExistOld then
    FileAddHandle( ScanPath, NewFileSize, NewFileTime )
  else     // 文件发生变化
  if ( NewFileSize <> OldFileSize ) or
     not MyDatetime.Equals( NewFileTime, OldFileTime )
  then
    FileModifyHandle( ScanPath, NewFileSize, NewFileTime );

    // 设置 根目录空间信息
  FolderSpace := NewFileSize;
  FileCount := 1;
  ResetFolderSpaceInfo;

    // 显示 公告栏
  ResetBackupBoardFileCount;

    // 移除界面刷新显示
  RemoveFolderRefreshing;
end;

{ TFileScannerBase }

constructor TFileScannerBase.Create(_ScanPath: string);
begin
  ScanPath := _ScanPath;
  FolderSpace := 0;
  FileCount := 0;
end;

procedure TFileScannerBase.FileAddHandle(FilePath: string;
  FileSize: Int64; FileTime: TDateTime);
var
  BackupFileAddHandle : TBackupFileAddHandle;
begin
  BackupFileAddHandle := TBackupFileAddHandle.Create( FilePath );
  BackupFileAddHandle.SetFileInfo( FileSize, FileTime );
  BackupFileAddHandle.Update;
  BackupFileAddHandle.Free;
end;

procedure TFileScannerBase.FileModifyHandle(FilePath: string; FileSize: Int64;
  FileTime: TDateTime);
begin
  FileRemoveHandle( FilePath );
  FileAddHandle( FilePath, FileSize, FileTime );
end;


procedure TFileScannerBase.FileRemoveHandle(FilePath: string);
var
  BackupFileRemoveHandle : TBackupFileRemoveHandle;
begin
    // 删除保护
  if not MyFilePath.getIsExist( ScanRootPath ) then
    Exit;

  BackupFileRemoveHandle := TBackupFileRemoveHandle.Create( FilePath );
  BackupFileRemoveHandle.Update;
  BackupFileRemoveHandle.Free;
end;

procedure TFileScannerBase.FolderAddHandle(FolderPath: string;
  FileTime: TDateTime);
var
  BackupFolderAddHandle : TBackupFolderAddHandle;
begin
  BackupFolderAddHandle := TBackupFolderAddHandle.Create( FolderPath );
  BackupFolderAddHandle.SetFolderInfo( FileTime, 0 );
  BackupFolderAddHandle.SetSpaceInfo( 0, 0 );
  BackupFolderAddHandle.Update;
  BackupFolderAddHandle.Free;
end;

procedure TFileScannerBase.FolderRemoveHandle(FolderPath: string);
var
  BackupFolderRemoveHandle : TBackupFolderRemoveHandle;
begin
    // 删除保护
  if not MyFilePath.getIsExist( ScanRootPath ) then
    Exit;

  BackupFolderRemoveHandle := TBackupFolderRemoveHandle.Create( FolderPath );
  BackupFolderRemoveHandle.Update;
  BackupFolderRemoveHandle.Free;
end;

procedure TFileScannerBase.ResetFolderSpaceInfo;
var
  BackupFolderSetSpaceHandle : TBackupFolderSetSpaceHandle;
begin
  BackupFolderSetSpaceHandle := TBackupFolderSetSpaceHandle.Create( ScanPath );
  BackupFolderSetSpaceHandle.SetSpaceInfo( FolderSpace, FileCount );
  BackupFolderSetSpaceHandle.Update;
  BackupFolderSetSpaceHandle.Free;
end;

procedure TFileScannerBase.SetScanRootPath(_ScanRootPath: string);
begin
  ScanRootPath := _ScanRootPath;
end;

procedure TFileScannerBase.AddFolderRefreshing;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Refreshing );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TFileScannerBase.RemoveFolderRefreshing;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

{ TBackupFileScanThread }

procedure TBackupFileScanThread.AddScanPathInfo(
  BackupScanPathInfo: TBackupScanPathInfo);
begin
  Lock.Enter;
  BackupScanPathList.Add( BackupScanPathInfo );
  Lock.Leave;

  Resume;
end;

constructor TBackupFileScanThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  BackupScanPathList := TBackupScanPathList.Create;
  BackupScanPathList.OwnsObjects := False;
end;

destructor TBackupFileScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  BackupScanPathList.OwnsObjects := True;
  BackupScanPathList.Free;
  Lock.Free;

  inherited;
end;

procedure TBackupFileScanThread.Execute;
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  while not Terminated do
  begin
      // 获取下一个需要扫描的路径
    BackupScanPathInfo := getNextScanPathInfo;

      // 没有 需要扫描的路径, 挂起线程
    if BackupScanPathInfo = nil then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 扫描路径
    HandleScanPath( BackupScanPathInfo );

      // 扫描结束
    BackupScanPathInfo.Free;
  end;

  inherited;
end;

function TBackupFileScanThread.getNextScanPathInfo: TBackupScanPathInfo;
begin
  Lock.Enter;
  if BackupScanPathList.Count > 0 then
  begin
    Result := BackupScanPathList[0];
    BackupScanPathList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TBackupFileScanThread.HandleScanPath(
  BackupScanPathInfo: TBackupScanPathInfo);
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
  BackupPathScanHandle := TBackupPathScanHandle.Create( BackupScanPathInfo );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

{ TBackupScanPathInfo }

constructor TBackupScanPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  IsShowFreeLimt := False;
end;

procedure TBackupScanPathInfo.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

end.

