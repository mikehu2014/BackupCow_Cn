unit ULocalBackupScan;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, URegisterInfo, UMainFormFace, Windows, UFileBaseInfo;

type

{$Region ' 扫描 算法 ' }

  TScanDesPathInfo = class;
  TScanDesPathList = class;

    // 本地备份 扫描  父类
  TLocalBackupSourceScanner = class
  protected
    SourcePath, SourceRootPath : string;  // 源路径
    DesPathList : TScanDesPathList;
  protected
    TotalFileCount : Integer;
    TotalFileSize : Int64;
  public
    constructor Create;
    procedure SetSourcePath( _SourcePath, _SourceRootPath : string );
    procedure SetDesPathList( _DesPathList : TScanDesPathList );
    procedure SetTotalSpaceInfo( _TotalFileCount : Integer; _TotalFileSize : Int64 );
    procedure Update;virtual;abstract;
  protected
    procedure CheckSourceFileAdd( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure ShowRefreshFace;
  protected
    procedure AddDesFile( SourceFile, DesRootPath : string );
    procedure RemoveDesFile( DesFile, DesRootPath : string );
    procedure ModifyDesFile( SourceFile, DesRootPath : string );
  end;

    // 本地备份 扫描 源文件
  TLocalBackupSourceFileScanner = class( TLocalBackupSourceScanner )
  public
    procedure Update;override;
  end;

    // 本地备份 扫描 源目录
  TLocalBackupSourceFolderScanner = class( TLocalBackupSourceScanner )
  private
    SourceFileNameHash : TStringHash; // 源文件列表
    ScanCount : Integer;   // 计算扫描目录，每 30 个 sleep 1 秒
    ScanTime : TDateTime; // 定时检测中断, 每 1 秒
  private
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public
    constructor Create;
    procedure SetScanInfo( _ScanCount : Integer; _ScanTime : TDateTime );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure Update;override;
    destructor Destroy; override;
  private        // 检查 源路径
    procedure CheckSourceFiles;
    procedure CheckSourceFolderAdd( FolderPath : string );
  private        // 检测 备份路径
    procedure CheckDesFiles;
    procedure CheckDesFile( DesPath : string; DesPathInfo : TScanDesPathInfo );
  private
    function CheckNextSearch : Boolean;
  private        // 过滤器
    function IsSearchFile( FilePath : string; sch : TSearchRec ): Boolean;
    function IsSearchFolder( FolderPath : string ): Boolean;
  end;

{$EndRegion}

{$Region ' 扫描 信息 ' }

      // 目标路径信息
  TScanDesPathInfo = class
  public
    FullPath : string;
    TotalSpace : Int64;
  public
    constructor Create( _FullPath : string );
    procedure AddSpace( Space : Int64 );
  end;
  TScanDesPathList = class( TObjectList< TScanDesPathInfo > )end;

      // 扫描信息
  TScanPathInfo = class
  public
    SourcePath : string;
    DesPathList : TStringList;
  public
    IsShowFreeLimit : Boolean;
  public
    constructor Create( _SourcePath : string );
    procedure AddDesPath( DesPath : string );
    procedure SetIsShowFreeLimit( _IsShowFreeLimit : Boolean );
    destructor Destroy; override;
  end;
  TScanPathList = class( TObjectList<TScanPathInfo> )end;

    // 扫描前, 检测目标路径
  TDesPathScanCheckHandle = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
    function get : Boolean;
  private
    function CheckDriverExist: Boolean;
    function CheckDesModify : Boolean;
    procedure ResetLackSpace;
  end;

    // 扫描源路径
  TScanPathHandle = class
  public
    ScanPathInfo : TScanPathInfo;
  public
    SourcePath : string;
    DesPathList : TScanDesPathList;
    TotalSize : Int64;
    TotalCount : Integer;
  public
    constructor Create( _ScanPathInfo : TScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private
    function CheckScanPathExist : Boolean;
    procedure FindDesPathList;
    procedure ScanSourcePath;
    procedure ResetScanPathSpace;
    procedure ResetLastSyncTime;
  private
    function CheckDesPath( DesPath : string ): Boolean;
  end;

{$EndRegion}

{$Region ' 复制/删除 算法 ' }

      // 文件复制
  TFileCopyHandle = class
  protected
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  protected
    SourFileSize, DesFileSize : Int64;
    IsFirstShow, IsShowPercentage : Boolean;
    StartTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  protected
    function CheckNextCopy : Boolean; // 检测是否继续复制
    procedure RefreshFace;virtual; // 刷新界面
    procedure SetPercentageVisible( IsVisible : Boolean );
    procedure ShowPercentage;
    procedure AddCompletedSpace;virtual;
  private
    function CheckIsEnoughSpace : Boolean;  // 检查是否有足够的空间
    procedure CheckDesRootModify; // 检查目录是否可修改
  end;

    // 复制 本地文件
  TFileCopyAddHandle = class
  private
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  private
    function CheckDesFileExist : Boolean;
    procedure FileCopy;
    procedure ShowBackupDesBoard;
  end;

    // 回收 文件
  TFileRecycledHandle = class( TFileCopyHandle )
  protected
    procedure RefreshFace;override; // 刷新界面
    procedure AddCompletedSpace;override; // 刷新已完成空间
  end;

  FileRecycledUtil = class
  public
    class function getEditionPath( FilePath : string; EditionNum : Integer ): string;
  end;

    // 回收 本地文件
  TFileRecycledAddHandle = class
  public
    DesRootPath, DesFilePath : string;
    SourceRootPath : string;
  public
    RecycledPath : string;
  public
    constructor Create( _DesRootPath, _DesFilePath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure Update;
  private
    procedure CheckKeedEditionCount;
    procedure FileCopy;
    procedure FileRemove;
    procedure ShowBackupDesBoard;
  private
    function getExistEditionCount : Integer;
  end;

    // 回收 本地目录
  TFolderRecycleHandle = class
  public
    DesRootPath, DesFolderPath : string;
    SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesRootPath, _DesFolderPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRecycled : Boolean;
  end;

    // 删除 本地文件
  TFileCopyRemoveHandle = class
  private
    DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    constructor Create( _DesFilePath : string );
    procedure SetDesRootPath( _DesRootPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure Update;
  private
    procedure ShowBackupDesBoard;
    procedure RemoveCompletedSpace;
  private
    procedure CheckDesRootModify;
  end;

    // 删除 本地目录
  TFolderRemoveHandle = class
  private
    DesFolderPath : string;
    DesRootPath, SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesFolderPath : string );
    procedure SetDesRootPath( _DesRootPath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRemove : Boolean;
  end;

{$Endregion}

{$Region ' 复制/删除 信息 ' }

    // 本地文件 变化信息
  TDesFileChangeInfo = class
  public
    SourcePath, DesPath : string;
    DesChangeType : string;
    SourceRootPath, DesRootPath : string;
  public
    constructor Create( _DesPath, _DesRootPath : string );
    procedure SetSourcePath( _SourcePath : string );
    procedure SetSourceRootPath( _SourceRootPath : string );
    procedure SetDesChangeType( _DesChangeType : string );
  end;
  TDesFileChangeList = class( TObjectList<TDesFileChangeInfo> )end;

    // 处理变化
  TDesFileChangeHandle = class
  public
    DesFileChangeInfo : TDesFileChangeInfo;
  private
    DesChangeType, DesRootPath : string;
    SourcePath, DesPath, SourceRootPath : string;
  public
    constructor Create( _DesFileChangeInfo : TDesFileChangeInfo );
    procedure Update;
  private
    procedure CopyFileHandle;
    procedure RecycleFileHandle;
    procedure RemoveFileHandle;
  private
    procedure AddStatusFace;
  end;

{$EndRegion}


    // 源目录 扫描
    // 目标目录 复制/删除
  TLocalBackupThread = class( TThread )
  private
    PathLock : TCriticalSection;
    ScanPathList : TScanPathList;
    LastScanHash : TStringHash;
  private
    IsNewScan : Boolean;
    DesFileChangeList : TDesFileChangeList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // 扫描
    function ExistScanPath : Boolean;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    function getScanPathInfo : TScanPathInfo;
    procedure ScanPathHandle( ScanPathInfo : TScanPathInfo );
  public          // 复制 与 删除
    procedure AddChange( DesFileChangeInfo : TDesFileChangeInfo );
    function getChange : TDesFileChangeInfo;
    procedure HandleChange( DesFileChangeInfo : TDesFileChangeInfo );
    procedure HandleFileChange;
  private
    procedure CheckFreeLimit( IsShowError : Boolean );
    procedure StopScanLocalBackupSource;
  private
    procedure ClearFileChange;
    procedure ShowFreeLimitWarnning;
  end;

    // 本地备份 源路径 扫描和复制
  TMyLocalBackupHandler = class
  private
    LocalBackupThread : TLocalBackupThread;
  public
    IsRun : Boolean;
  public
    constructor Create;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    procedure AddDesFileChangeInfo( DesFileChangeInfo : TDesFileChangeInfo );
    procedure StopScan;
  end;

const
  ScanCount_Sleep = 30;
  CopyCount_Sleep = 10;

var
  ScanSource_IsCompleted : Boolean = False;

var
    // 源路径 扫描线程
  MyLocalBackupHandler : TMyLocalBackupHandler;

implementation

uses ULocalBackupControl, ULocalBackupFace, UBackupInfoFace, ULocalBackupInfo;

{ TMyDesChangeInfo }

constructor TDesFileChangeInfo.Create(_DesPath, _DesRootPath: string);
begin
  DesPath := _DesPath;
  DesRootPath := _DesRootPath;
end;

procedure TDesFileChangeInfo.SetDesChangeType(_DesChangeType: string);
begin
  DesChangeType := _DesChangeType;
end;

procedure TDesFileChangeInfo.SetSourcePath(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

procedure TDesFileChangeInfo.SetSourceRootPath(_SourceRootPath : string);
begin
  SourceRootPath := _SourceRootPath;
end;

{ TLocalCopyAddHandle }

function TFileCopyAddHandle.CheckDesFileExist: Boolean;
var
  SourceFileSize, DesFileSize : Int64;
  SourceFileTime, DesFileTime : TDateTime;
begin
  Result := False;

  if not FileExists( DesFilePath ) then
    Exit;

  SourceFileSize := MyFileInfo.getFileSize( SourFilePath );
  DesFileSize := MyFileInfo.getFileSize( DesFilePath );
  if SourceFileSize <> DesFileSize then
    Exit;

  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
  DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );
  if not MyDatetime.Equals( SourceFileTime, DesFileTime ) then
    Exit;

  Result := True;
end;

constructor TFileCopyAddHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
end;

procedure TFileCopyAddHandle.FileCopy;
var
  FileCopyHandle : TFileCopyHandle;
begin
  FileCopyHandle := TFileCopyHandle.Create( SourFilePath, DesFilePath );
  FileCopyHandle.SetDesRootPath( DesRootPath, SourceRootPath );
  FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

procedure TFileCopyAddHandle.SetDesRootPath(_DesRootPath, _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyAddHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( SourFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Copy );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileCopyAddHandle.Update;
var
  ParentFolder : string;
begin
    // 显示本地复制 公告
  ShowBackupDesBoard;

    // 目录 则 创建目录
  if DirectoryExists( SourFilePath ) then
  begin
      // 创建目录
    ForceDirectories( DesFilePath );
  end
  else  // 文件 则 复制文件
  if FileExists( SourFilePath ) and not CheckDesFileExist then
  begin
    ParentFolder := ExtractFileDir( DesFilePath );
    ForceDirectories( ParentFolder );
    FileCopy;
  end;
end;

{ TLocalCopyRemoveHandle }

constructor TFileCopyRemoveHandle.Create(_DesFilePath: string);
begin
  DesFilePath := _DesFilePath;
end;

procedure TFileCopyRemoveHandle.RemoveCompletedSpace;
var
  FileSize : Int64;
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  FileSize := MyFileInfo.getFileSize( DesFilePath );
  if FileSize > 0 then
    FileSize := -FileSize;

  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( FileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;
end;

procedure TFileCopyRemoveHandle.SetDesRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

procedure TFileCopyRemoveHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyRemoveHandle.CheckDesRootModify;
var
  BackupDesIsModifyHandle : TLocalBackupDesModifyHandle;
begin
    // 判断 目标根路径 是否可修改
  if MyDesPathUtil.getIsModify( DesRootPath ) then
    Exit;

  BackupDesIsModifyHandle := TLocalBackupDesModifyHandle.Create( DesRootPath );
  BackupDesIsModifyHandle.SetIsModify( False );
  BackupDesIsModifyHandle.Update;
  BackupDesIsModifyHandle.Free;
end;

procedure TFileCopyRemoveHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( DesFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Removing );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileCopyRemoveHandle.Update;
begin
    // 显示 本地删除公告
  ShowBackupDesBoard;

    // 减少目标路径已完成空间
  RemoveCompletedSpace;

    // 删除文件
  if not MyFolderDelete.FileDelete( DesFilePath ) then
    CheckDesRootModify;
end;

{ TFileCopyHandle }

procedure TFileCopyHandle.CheckDesRootModify;
var
  BackupDesIsModifyHandle : TLocalBackupDesModifyHandle;
begin
    // 判断 目标根路径 是否可修改
  if MyFilePath.getIsModify( DesRootPath ) then
    Exit;

    // 不可修改
  BackupDesIsModifyHandle := TLocalBackupDesModifyHandle.Create( DesRootPath );
  BackupDesIsModifyHandle.SetIsModify( False );
  BackupDesIsModifyHandle.Update;
  BackupDesIsModifyHandle.Free;
end;

function TFileCopyHandle.CheckIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
  LocalBackupDesLackSpaceHandle : TLocalBackupDesLackSpaceHandle;
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  Result := True;
  FreeSize := MyHardDisk.getHardDiskFreeSize( DesRootPath );

    // 是否有足够的空间
  if FreeSize >= MyFileInfo.getFileSize( SourFilePath ) then
    Exit;

    // 缺少空间
  LocalBackupDesLackSpaceHandle := TLocalBackupDesLackSpaceHandle.Create( DesRootPath );
  LocalBackupDesLackSpaceHandle.SetIsLackSpace( True );
  LocalBackupDesLackSpaceHandle.Update;
  LocalBackupDesLackSpaceHandle.Free;

    // 减少计算的空间
  SourFileSize := MyFileInfo.getFileSize( SourFilePath );
  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( -SourFileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;

  Result := False;
end;

function TFileCopyHandle.CheckNextCopy: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= CopyCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;

    // 1 秒钟 刷新一次界面
  if SecondsBetween( Now, StartTime ) >= 1 then
  begin
      // 如果 第一秒 复制小于 30%, 显示进度条
    if IsFirstShow then
    begin
      IsFirstShow := False;
      IsShowPercentage := MyPercentage.getPercent( DesFileSize, SourFileSize ) < 30;
      if IsShowPercentage then
        SetPercentageVisible( True );
    end;
    if IsShowPercentage then
      ShowPercentage;
    StartTime := Now;

      // 刷新界面
    RefreshFace;

      // 检测 是否复制中断
    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    Result := Result and MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath );
  end;

    // 可能已经 Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFileCopyHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
  SleepCount := 0;
  IsShowPercentage := False;
  IsFirstShow := True;
  StartTime := Now;
end;

procedure TFileCopyHandle.RefreshFace;
begin
    // 更新 界面
  MyLocalBackupStatusShow.AddSourceCopy( SourceRootPath );
  MyLocalBackupStatusShow.AddDesChange( DesRootPath, DesChangeType_Add );
end;

procedure TFileCopyHandle.AddCompletedSpace;
var
  LocalBackupSourceAddDesCompletedSpaceHandle : TLocalBackupSourceAddDesCompletedSpaceHandle;
begin
  LocalBackupSourceAddDesCompletedSpaceHandle := TLocalBackupSourceAddDesCompletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesCompletedSpaceHandle.SetAddCompltedSize( SourFileSize );
  LocalBackupSourceAddDesCompletedSpaceHandle.Update;
  LocalBackupSourceAddDesCompletedSpaceHandle.Free;
end;

procedure TFileCopyHandle.SetDesRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TFileCopyHandle.SetPercentageVisible(IsVisible: Boolean);
var
  PlBackupDesPercentVisibleInfo : TPlBackupDesPercentVisibleInfo;
begin
  PlBackupDesPercentVisibleInfo := TPlBackupDesPercentVisibleInfo.Create( IsVisible );
  PlBackupDesPercentVisibleInfo.SetExplorerPath( SourFilePath );
  MyBackupFileFace.AddChange( PlBackupDesPercentVisibleInfo );
end;

procedure TFileCopyHandle.ShowPercentage;
var
  Percentage : Integer;
  PercentageCompareStr : string;
  PlBackupDesBoardPercentInfo : TPlBackupDesBoardPercentInfo;
begin
  Percentage := MyPercentage.getPercent( DesFileSize, SourFileSize );
  PercentageCompareStr := MyPercentage.getCompareStr( DesFileSize, SourFileSize );

  PlBackupDesBoardPercentInfo := TPlBackupDesBoardPercentInfo.Create( Percentage );
  PlBackupDesBoardPercentInfo.SetPercentCompareStr( PercentageCompareStr );
  MyBackupFileFace.AddChange( PlBackupDesBoardPercentInfo );
end;

procedure TFileCopyHandle.Update;
var
  SourFileStream, DesFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SleepCount, PercentCount : Integer;
  SourceFileTime : TDateTime;
begin
    // 源文件不存在
  if not FileExists( SourFilePath ) then
    Exit;

    // 目标路径没有足够的空间
  if not CheckIsEnoughSpace then
    Exit;

    // 文件流
  SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );
  try
    ForceDirectories( ExtractFileDir( DesFilePath ) );
    DesFileStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );
    SourFileSize := SourFileStream.Size;
    DesFileSize := 0;

    FullBufSize := SizeOf( Buf );
    RemainSize := SourFileSize;
    while RemainSize > 0 do
    begin
        // 取消复制 或 程序结束
      if not CheckNextCopy then
        Break;

      BufSize := Min( FullBufSize, RemainSize );
      if SourFileStream.Read( Buf, BufSize ) <> BufSize then
        Break;
      if DesFileStream.Write( Buf, BufSize ) <> BufSize then
        Break;
      RemainSize := RemainSize - BufSize;
      DesFileSize := DesFileSize + BufSize;
    end;
    DesFileStream.Free;

      // 统计已完成信息
    AddCompletedSpace;

      // 设置修改时间
    SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
    MyFileSetTime.SetTime( DesFilePath, SourceFileTime );
  except
    CheckDesRootModify; // 检测目录是否可修改
  end;
  SourFileStream.Free;

    // 隐藏进度
  if IsShowPercentage then
    SetPercentageVisible( False );
end;

{ TLocalBackupSourceScanThread }

procedure TLocalBackupThread.AddChange(
  DesFileChangeInfo: TDesFileChangeInfo);
begin
  PathLock.Enter;
  DesFileChangeList.Add( DesFileChangeInfo );
  PathLock.Leave;

  Resume;
end;

procedure TLocalBackupThread.AddScanPathInfo(
  ScanPathInfo : TScanPathInfo);
begin
  PathLock.Enter;
  ScanPathList.Add( ScanPathInfo );
  IsNewScan := not LastScanHash.ContainsKey( ScanPathInfo.SourcePath );
  PathLock.Leave;

  Resume;
end;

procedure TLocalBackupThread.CheckFreeLimit( IsShowError : Boolean );
begin
    // 非试用版, 跳过
  if not RegisterInfo.getIsFreeEdition then
    Exit;

    // 超出试用限制
  if MyLocalBackupSourceReadUtil.getTotalSapce > EditionUtil.getFreeMaxBackupSpace then
  begin
    ClearFileChange; // 清除文件变化
    if IsShowError then  // 显示限制错误
      ShowFreeLimitWarnning;
  end;
end;

procedure TLocalBackupThread.ClearFileChange;
begin
  PathLock.Enter;
  DesFileChangeList.OwnsObjects := True;
  DesFileChangeList.Clear;
  DesFileChangeList.OwnsObjects := False;
  PathLock.Leave;
end;

constructor TLocalBackupThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  ScanPathList := TScanPathList.Create;
  ScanPathList.OwnsObjects := False;
  LastScanHash := TStringHash.Create;
  DesFileChangeList := TDesFileChangeList.Create;
  DesFileChangeList.OwnsObjects := False;
end;

destructor TLocalBackupThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  DesFileChangeList.OwnsObjects := True;
  DesFileChangeList.Free;
  LastScanHash.Free;
  ScanPathList.OwnsObjects := True;
  ScanPathList.Free;
  PathLock.Free;

  inherited;
end;

procedure TLocalBackupThread.Execute;
var
  ScanPathInfo : TScanPathInfo;
  IsShowError : Boolean;
begin
  while not Terminated do
  begin
      // 扫描
    ScanPathInfo := getScanPathInfo;
    if ScanPathInfo <> nil then
    begin
      IsShowError := ScanPathInfo.IsShowFreeLimit;
      ScanPathHandle( ScanPathInfo );  // 扫描路径
      ScanPathInfo.Free;
      Continue;
    end;

      // 复制 / 删除
    CheckFreeLimit( IsShowError ); // 检查是否超过试用限制
    IsNewScan := False;
    HandleFileChange;  // 处理 复制/删除文件
    if not ExistScanPath then  // 没有 要扫描的文件, 挂起线程
    begin
      StopScanLocalBackupSource;
      if not Terminated then
        Suspend;
    end;
  end;
  inherited;
end;


function TLocalBackupThread.ExistScanPath: Boolean;
begin
  PathLock.Enter;
  Result := ScanPathList.Count > 0;
  PathLock.Leave;
end;

function TLocalBackupThread.getChange: TDesFileChangeInfo;
begin
  PathLock.Enter;
  if DesFileChangeList.Count > 0 then
  begin
    Result := DesFileChangeList[0];
    DesFileChangeList.Delete(0);
  end
  else
    Result := nil;
  PathLock.Leave;
end;

function TLocalBackupThread.getScanPathInfo: TScanPathInfo;
var
  i : Integer;
  SourcePath : string;
begin
  PathLock.Enter;
  Result := nil;
  for i := 0 to ScanPathList.Count - 1 do
  begin
    SourcePath := ScanPathList[i].SourcePath;
    if LastScanHash.ContainsKey( SourcePath ) then
      Continue;
    Result := ScanPathList[i];
    ScanPathList.Delete(0);
    LastScanHash.AddString( Result.SourcePath );
    Break;
  end;
  PathLock.Leave;
end;

procedure TLocalBackupThread.HandleChange(
  DesFileChangeInfo: TDesFileChangeInfo);
var
  DesFileChangeHandle : TDesFileChangeHandle;
begin
  try
    // 处理文件变化
    DesFileChangeHandle := TDesFileChangeHandle.Create( DesFileChangeInfo );
    DesFileChangeHandle.Update;
    DesFileChangeHandle.Free;
  except
  end;
end;

procedure TLocalBackupThread.HandleFileChange;
var
  DesFileChangeInfo : TDesFileChangeInfo;
begin
  while not Terminated do
  begin
      // 来了新的扫描路径
    if IsNewScan then
      Break;

    DesFileChangeInfo := getChange;
    if DesFileChangeInfo = nil then
    begin
      PathLock.Enter;
      LastScanHash.Clear;
      PathLock.Leave;
      Break;
    end;
    HandleChange( DesFileChangeInfo );
    DesFileChangeInfo.Free;

    Sleep(1);
  end;
end;

procedure TLocalBackupThread.ScanPathHandle(ScanPathInfo: TScanPathInfo);
var
  ScanPathHandle : TScanPathHandle;
begin
  try
    ScanPathHandle := TScanPathHandle.Create( ScanPathInfo );
    ScanPathHandle.Update;
    ScanPathHandle.Free;
  except
  end;
end;

procedure TLocalBackupThread.ShowFreeLimitWarnning;
var
  ShowFreeEditionWarnning : TShowFreeEditionWarnning;
begin
  ShowFreeEditionWarnning := TShowFreeEditionWarnning.Create( FreeEditionError_BackupSpace );
  MyMainFormFace.AddChange( ShowFreeEditionWarnning );
end;

procedure TLocalBackupThread.StopScanLocalBackupSource;
var
  LocalBackupSourceAllScanCompletedHandle : TLocalBackupSourceAllScanCompletedHandle;
begin
  LocalBackupSourceAllScanCompletedHandle := TLocalBackupSourceAllScanCompletedHandle.Create;
  LocalBackupSourceAllScanCompletedHandle.Update;
  LocalBackupSourceAllScanCompletedHandle.Free;
end;

{ TScanPathInfo }

procedure TScanPathInfo.AddDesPath(DesPath: string);
begin
  DesPathList.Add( DesPath );
end;

constructor TScanPathInfo.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
  DesPathList := TStringList.Create;
  IsShowFreeLimit := False;
end;

destructor TScanPathInfo.Destroy;
begin
  DesPathList.Free;
  inherited;
end;

procedure TScanPathInfo.SetIsShowFreeLimit(_IsShowFreeLimit: Boolean);
begin
  IsShowFreeLimit := _IsShowFreeLimit;
end;

{ TLocalBackupSourceFolderScanner }

procedure TLocalBackupSourceFolderScanner.CheckSourceFolderAdd(
  FolderPath: string);
var
  i : Integer;
  DesChildPath : string;
  DesPath, DesFolderPath : string;
  LocalBackupSourceFolderScanner : TLocalBackupSourceFolderScanner;
begin
  DesChildPath := MyFilePath.getDownloadPath( FolderPath );

    // 遍历目标路径
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesFolderPath := MyFilePath.getPath( DesPath ) + DesChildPath;

      // 创建目录
    if not DirectoryExists( DesFolderPath ) then
      AddDesFile( FolderPath, DesPath );
  end;

    // 扫描下一层
  LocalBackupSourceFolderScanner := TLocalBackupSourceFolderScanner.Create;
  LocalBackupSourceFolderScanner.SetSourcePath( FolderPath, SourceRootPath );
  LocalBackupSourceFolderScanner.SetDesPathList( DesPathList );
  LocalBackupSourceFolderScanner.SetScanInfo( ScanCount, ScanTime );
  LocalBackupSourceFolderScanner.SetTotalSpaceInfo( TotalFileCount, TotalFileSize );
  LocalBackupSourceFolderScanner.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalBackupSourceFolderScanner.Update;
  ScanCount := LocalBackupSourceFolderScanner.ScanCount;
  ScanTime := LocalBackupSourceFolderScanner.ScanTime;
  TotalFileCount := LocalBackupSourceFolderScanner.TotalFileCount;
  TotalFileSize := LocalBackupSourceFolderScanner.TotalFileSize;
  LocalBackupSourceFolderScanner.Free;
end;


procedure TLocalBackupSourceFolderScanner.CheckDesFile(
  DesPath: string; DesPathInfo : TScanDesPathInfo);
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( DesPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      if SourceFileNameHash.ContainsKey( FileName ) then
        Continue;

      ChildPath := SearcFullPath + FileName ;

          // 添加目标目录 文件空间
      if not DirectoryExists( ChildPath ) then
        DesPathInfo.AddSpace( sch.Size );

      RemoveDesFile( ChildPath, DesPathInfo.FullPath );

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TLocalBackupSourceFolderScanner.CheckDesFiles;
var
  i : Integer;
  DesPath, DesScanPath : string;
begin
  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesScanPath := MyFilePath.getPath( DesPath );
    DesScanPath := DesScanPath + MyFilePath.getDownloadPath( SourcePath );

    CheckDesFile( DesScanPath, DesPathList[i] );
  end;
end;

function TLocalBackupSourceFolderScanner.CheckNextSearch: Boolean;
begin
  Result := True;

    // N 个文件小停一次
  Inc( ScanCount );
  if ScanCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    ScanCount := 0;
  end;

    // 1 秒钟 检测一次
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // 刷新界面
    ShowRefreshFace;

      // 检查是否中断
    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    ScanTime := Now;
  end;

    // 返回 是否继续扫描
  Result := Result and MyLocalBackupHandler.IsRun;
end;

procedure TLocalBackupSourceFolderScanner.CheckSourceFiles;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsSearchResult : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( SourcePath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsSearchResult := IsSearchFolder( ChildPath )
      else
        IsSearchResult := IsSearchFile( ChildPath, sch );
      if not IsSearchResult then  // 文件被过滤
        Continue;

      SourceFileNameHash.AddString( FileName );

        // 检查下一层目录
      if IsFolder then
        CheckSourceFolderAdd( ChildPath )
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

        TotalFileSize := TotalFileSize + FileSize;
        TotalFileCount := TotalFileCount + 1;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 检查 文件信息
        CheckSourceFileAdd( ChildPath, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

constructor TLocalBackupSourceFolderScanner.Create;
begin
  inherited;
  SourceFileNameHash := TStringHash.Create;
  ScanCount := 0;
  ScanTime := Now;
end;

destructor TLocalBackupSourceFolderScanner.Destroy;
begin
  SourceFileNameHash.Free;
  inherited;
end;

function TLocalBackupSourceFolderScanner.IsSearchFile(FilePath: string;
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

function TLocalBackupSourceFolderScanner.IsSearchFolder(
  FolderPath: string): Boolean;
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

procedure TLocalBackupSourceFolderScanner.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TLocalBackupSourceFolderScanner.SetScanInfo(_ScanCount: Integer;
  _ScanTime : TDateTime);
begin
  ScanCount := _ScanCount;
  ScanTime := _ScanTime;
end;

procedure TLocalBackupSourceFolderScanner.Update;
begin
    // 检测 源路径
  CheckSourceFiles;

    // 检测 目标路径
  CheckDesFiles;

    // 刷新界面
  ShowRefreshFace;
end;

{ TLocalBackupSourceScanner }

procedure TLocalBackupSourceScanner.AddDesFile(SourceFile, DesRootPath: string);
var
  DesChildPath : string;
  DesFileChangeInfo : TDesFileChangeInfo;
begin
    // 文件正在使用
  if MyFileInfo.getFileIsInUse( SourceFile ) then
    Exit;

  DesChildPath := MyFilePath.getPath( DesRootPath );
  DesChildPath := DesChildPath + MyFilePath.getDownloadPath( SourceFile );

  DesFileChangeInfo := TDesFileChangeInfo.Create( DesChildPath, DesRootPath );
  DesFileChangeInfo.SetSourcePath( SourceFile );
  DesFileChangeInfo.SetDesChangeType( DesChangeType_Add );
  DesFileChangeInfo.SetSourceRootPath( SourceRootPath );

  MyLocalBackupHandler.AddDesFileChangeInfo( DesFileChangeInfo );
end;

procedure TLocalBackupSourceScanner.CheckSourceFileAdd(FilePath: string;
  FileSize: Int64; FileTime: TDateTime);
var
  i : Integer;
  DesChildPath : string;
  DesPath, DesFilePath : string;
  DesFileSize : Int64;
  DesFileTime : TDateTime;
begin
  DesChildPath := MyFilePath.getDownloadPath( FilePath );

  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;
    DesFilePath := MyFilePath.getPath( DesPath ) + DesChildPath;

      // 添加
    if not FileExists( DesFilePath ) then
      AddDesFile( FilePath, DesPath )
    else
    begin
      DesFileSize := MyFileInfo.getFileSize( DesFilePath );
      DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );

        // 目标路径 空间统计
      DesPathList[i].AddSpace( DesFileSize );

        // 覆盖
      if ( DesFileSize <> FileSize ) or
         not MyDatetime.Equals( DesFileTime, FileTime )
      then
        ModifyDesFile( FilePath, DesPath );
    end;
  end;
end;

constructor TLocalBackupSourceScanner.Create;
begin
  TotalFileCount := 0;
  TotalFileSize := 0;
end;

procedure TLocalBackupSourceScanner.ModifyDesFile(SourceFile,
  DesRootPath: string);
var
  DesChildPath : string;
  DesFileChangeInfo : TDesFileChangeInfo;
begin
  DesChildPath := MyFilePath.getPath( DesRootPath );
  DesChildPath := DesChildPath + MyFilePath.getDownloadPath( SourceFile );

    // 先删除
  RemoveDesFile( DesChildPath, DesRootPath );

    // 再添加
  AddDesFile( SourceFile, DesRootPath );
end;

procedure TLocalBackupSourceScanner.ShowRefreshFace;
begin
  MyLocalBackupStatusShow.AddSourceRefresh( SourceRootPath, TotalFileCount );
end;

procedure TLocalBackupSourceScanner.RemoveDesFile(DesFile,
  DesRootPath: string);
var
  DesFileChangeInfo : TDesFileChangeInfo;
begin
    // 根节点不存在 删除保护
  if not MyFilePath.getIsExist( SourceRootPath ) then
    Exit;

  DesFileChangeInfo := TDesFileChangeInfo.Create( DesFile, DesRootPath );
  DesFileChangeInfo.SetDesChangeType( DesChangeType_Remove );
  DesFileChangeInfo.SetSourceRootPath( SourceRootPath );

  MyLocalBackupHandler.AddDesFileChangeInfo( DesFileChangeInfo );
end;

procedure TLocalBackupSourceScanner.SetDesPathList(_DesPathList: TScanDesPathList);
begin
  DesPathList := _DesPathList;
end;

procedure TLocalBackupSourceScanner.SetSourcePath(
  _SourcePath, _SourceRootPath: string);
begin
  SourcePath := _SourcePath;
  SourceRootPath := _SourceRootPath;
end;

procedure TLocalBackupSourceScanner.SetTotalSpaceInfo(_TotalFileCount: Integer;
  _TotalFileSize: Int64);
begin
  TotalFileCount := _TotalFileCount;
  TotalFileSize := _TotalFileSize;
end;

{ TLocalBackupSourceFileScanner }

procedure TLocalBackupSourceFileScanner.Update;
var
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
begin
  SourceFileSize := MyFileInfo.getFileSize( SourcePath );
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourcePath );

  TotalFileCount := 1;
  TotalFileSize := SourceFileSize;

    // 检测
  CheckSourceFileAdd( SourcePath, SourceFileSize, SourceFileTime );

    // 显示 刷新界面
  ShowRefreshFace;
end;

{ TMyLocalBackupSourceScanner }

procedure TMyLocalBackupHandler.AddDesFileChangeInfo(
  DesFileChangeInfo: TDesFileChangeInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddChange( DesFileChangeInfo );
end;

procedure TMyLocalBackupHandler.AddScanPathInfo(
  ScanPathInfo: TScanPathInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddScanPathInfo( ScanPathInfo );
end;

constructor TMyLocalBackupHandler.Create;
begin
  LocalBackupThread := TLocalBackupThread.Create;
  IsRun := True;
end;

procedure TMyLocalBackupHandler.StopScan;
begin
  IsRun := False;
  LocalBackupThread.Free;
end;



{ TScanDesPathInfo }

procedure TScanDesPathInfo.AddSpace(Space: Int64);
begin
  TotalSpace := TotalSpace + Space;
end;

constructor TScanDesPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  TotalSpace := 0;
end;

{ TScanPathHandle }

function TScanPathHandle.CheckDesPath(DesPath: string): Boolean;
var
  DesPathScanCheckHandle : TDesPathScanCheckHandle;
begin
  DesPathScanCheckHandle := TDesPathScanCheckHandle.Create( DesPath );
  Result := DesPathScanCheckHandle.get;
  DesPathScanCheckHandle.Free;
end;

function TScanPathHandle.CheckScanPathExist: Boolean;
var
  LocalBackupSourceSetExistHandle : TLocalBackupSourceSetExistHandle;
begin
  Result := MyFilePath.getIsExist( SourcePath );

    // 设置源路径 是否存在
  LocalBackupSourceSetExistHandle := TLocalBackupSourceSetExistHandle.Create( SourcePath );
  LocalBackupSourceSetExistHandle.SetIsExist( Result );
  LocalBackupSourceSetExistHandle.Update;
  LocalBackupSourceSetExistHandle.Free;
end;

constructor TScanPathHandle.Create(_ScanPathInfo: TScanPathInfo);
begin
  ScanPathInfo := _ScanPathInfo;
  SourcePath := ScanPathInfo.SourcePath;
  DesPathList := TScanDesPathList.Create;
end;

destructor TScanPathHandle.Destroy;
begin
  DesPathList.Free;
  inherited;
end;

procedure TScanPathHandle.FindDesPathList;
var
  i : Integer;
  DesPath : string;
  ScanDesPathInfo : TScanDesPathInfo;
begin
  for i := 0 to ScanPathInfo.DesPathList.Count - 1 do
  begin
    DesPath := ScanPathInfo.DesPathList[i];
    if not CheckDesPath( DesPath ) then // 目录不存在/目录不能修改
      Continue;
    ScanDesPathInfo := TScanDesPathInfo.Create( DesPath );
    DesPathList.Add( ScanDesPathInfo );
  end;
end;

procedure TScanPathHandle.ResetLastSyncTime;
var
  LocalBackupSourceSetLastSyncTimeHandle : TLocalBackupSourceSetLastSyncTimeHandle;
begin
  LocalBackupSourceSetLastSyncTimeHandle := TLocalBackupSourceSetLastSyncTimeHandle.Create( SourcePath );
  LocalBackupSourceSetLastSyncTimeHandle.SetLastSyncTime( Now );
  LocalBackupSourceSetLastSyncTimeHandle.Update;
  LocalBackupSourceSetLastSyncTimeHandle.Free;
end;

procedure TScanPathHandle.ResetScanPathSpace;
var
  LocalBackupSourceSpaceHandle : TLocalBackupSourceSpaceHandle;
  i : Integer;
  DesPath : string;
  LocalBackupSourceSetDesSpaceHandle : TLocalBackupSourceSetDesSpaceHandle;
begin
    // 设置空间信息
  LocalBackupSourceSpaceHandle := TLocalBackupSourceSpaceHandle.Create( SourcePath );
  LocalBackupSourceSpaceHandle.SetSpaceInfo( TotalCount, TotalSize );
  LocalBackupSourceSpaceHandle.Update;
  LocalBackupSourceSpaceHandle.Free;

  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i].FullPath;

    LocalBackupSourceSetDesSpaceHandle := TLocalBackupSourceSetDesSpaceHandle.Create( SourcePath );
    LocalBackupSourceSetDesSpaceHandle.SetDesPath( DesPath );
    LocalBackupSourceSetDesSpaceHandle.SetSpaceInfo( TotalSize, DesPathList[i].TotalSpace );
    LocalBackupSourceSetDesSpaceHandle.Update;
    LocalBackupSourceSetDesSpaceHandle.Free;
  end;
end;

procedure TScanPathHandle.ScanSourcePath;
var
  IncludeFilterList : TFileFilterList;  // 包含过滤器
  ExcludeFilterList : TFileFilterList;  // 排除过滤器
  LocalBackupSourceScanner : TLocalBackupSourceScanner;
  LocalBackupSourceFolderScanner : TLocalBackupSourceFolderScanner;
begin
  IncludeFilterList := MyLocalBackupSourceReadUtil.ReadIncludeFilter( SourcePath );
  ExcludeFilterList := MyLocalBackupSourceReadUtil.ReadExcludeFilter( SourcePath );

    // 扫描
  if FileExists( SourcePath ) then
    LocalBackupSourceScanner := TLocalBackupSourceFileScanner.Create
  else
  begin
    LocalBackupSourceFolderScanner := TLocalBackupSourceFolderScanner.Create;
    LocalBackupSourceFolderScanner.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
    LocalBackupSourceScanner := LocalBackupSourceFolderScanner;
  end;
  LocalBackupSourceScanner.SetSourcePath( SourcePath, SourcePath );
  LocalBackupSourceScanner.SetDesPathList( DesPathList );
  LocalBackupSourceScanner.Update;
  TotalSize := LocalBackupSourceScanner.TotalFileSize;
  TotalCount := LocalBackupSourceScanner.TotalFileCount;
  LocalBackupSourceScanner.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

procedure TScanPathHandle.Update;
begin
    // 源路径不存在, 不扫描
  if not CheckScanPathExist then
    Exit;

    // 目标路径
  FindDesPathList;

    // 扫描源路径
  ScanSourcePath;

    // 重设路径空间信息
  ResetScanPathSpace;;

    // 设置 上次同步时间
  ResetLastSyncTime;
end;

{ TDesFileChangeHandle }

procedure TDesFileChangeHandle.CopyFileHandle;
var
  FileCopyAddHandle : TFileCopyAddHandle;
begin
  AddStatusFace;

  FileCopyAddHandle := TFileCopyAddHandle.Create( SourcePath, DesPath );
  FileCopyAddHandle.SetDesRootPath( DesRootPath, SourceRootPath );
  FileCopyAddHandle.Update;
  FileCopyAddHandle.Free;
end;

constructor TDesFileChangeHandle.Create(_DesFileChangeInfo: TDesFileChangeInfo);
begin
  DesFileChangeInfo := _DesFileChangeInfo;
  DesChangeType := DesFileChangeInfo.DesChangeType;
  DesRootPath := DesFileChangeInfo.DesRootPath;
  SourcePath := DesFileChangeInfo.SourcePath;
  DesPath := DesFileChangeInfo.DesPath;
  SourceRootPath := DesFileChangeInfo.SourceRootPath;
end;

procedure TDesFileChangeHandle.RecycleFileHandle;
var
  FileRecycledAddHandle : TFileRecycledAddHandle;
  FolderRecycleHandle : TFolderRecycleHandle;
begin
  if FileExists( DesPath ) then
  begin
    FileRecycledAddHandle := TFileRecycledAddHandle.Create( DesRootPath, DesPath );
    FileRecycledAddHandle.SetSourceRootPath( SourceRootPath );
    FileRecycledAddHandle.Update;
    FileRecycledAddHandle.Free;
  end
  else
  begin
    FolderRecycleHandle := TFolderRecycleHandle.Create( DesRootPath, DesPath );
    FolderRecycleHandle.SetSourceRootPath( SourceRootPath );
    FolderRecycleHandle.Update;
    FolderRecycleHandle.Free;
  end;
end;

procedure TDesFileChangeHandle.AddStatusFace;
begin
    // 源路径 状态
  if DesChangeType = DesChangeType_Add then
    MyLocalBackupStatusShow.AddSourceCopy( SourceRootPath );

    // 目标路径 状态
  MyLocalBackupStatusShow.AddDesChange( DesRootPath, DesChangeType );
end;

procedure TDesFileChangeHandle.RemoveFileHandle;
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
  FolderRemoveHandle : TFolderRemoveHandle;
begin
    // 删除
  AddStatusFace;

  if FileExists( DesPath ) then
  begin
    FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( DesPath );
    FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
    FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
    FileCopyRemoveHandle.Update;
    FileCopyRemoveHandle.Free;
  end
  else
  begin
    FolderRemoveHandle := TFolderRemoveHandle.Create( DesPath );
    FolderRemoveHandle.SetDesRootPath( DesRootPath );
    FolderRemoveHandle.SetSourceRootPath( SourceRootPath );
    FolderRemoveHandle.Update;
    FolderRemoveHandle.Free;
  end;
end;

procedure TDesFileChangeHandle.Update;
begin
    // Des Disable, 则跳过
  if not MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath ) then
    Exit;

    // BackupSource 已删除
  if ( DesChangeType =  DesChangeType_Add ) and
      not MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath )
  then
    Exit;

    // 处理变化
  if DesChangeType = DesChangeType_Add then
    CopyFileHandle
  else
  if DesChangeType = DesChangeType_Remove then
  begin
      // 回收 或 删除
    if MyLocalBackupSourceReadUtil.getIsKeepDeleted( SourceRootPath ) then
      RecycleFileHandle
    else
      RemoveFileHandle;
  end;
end;

{ TFileRecycledHandle }

procedure TFileRecycledAddHandle.CheckKeedEditionCount;
var
  KeepEditionCount : Integer;
  ExistEditionCount : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
  KeepEditionCount := MyLocalBackupSourceReadUtil.getKeedEditionCount( SourceRootPath );
  ExistEditionCount := getExistEditionCount;
  if ( ExistEditionCount = 0 ) or ( KeepEditionCount = 0 ) then
    Exit;

    // 版本 数超多
    // 删除 最低版本
  if ExistEditionCount >= KeepEditionCount then
  begin
    FilePath1 := FileRecycledUtil.getEditionPath( RecycledPath, KeepEditionCount - 1 );
    MyFolderDelete.FileDelete( FilePath1 );
  end;

    // 改名版本数
  ExistEditionCount := Min( ExistEditionCount, KeepEditionCount  );

    // 版本上移
  for i := ExistEditionCount downto 2 do
  begin
    FilePath1 := FileRecycledUtil.getEditionPath( RecycledPath, i - 1 );
    FilePath2 := FileRecycledUtil.getEditionPath( RecycledPath, i );
    RenameFile( FilePath1, FilePath2 );
  end;

    // 当前版本设为最后一个版本
  RenameFile( RecycledPath, FileRecycledUtil.getEditionPath( RecycledPath, 1 ) )
end;

constructor TFileRecycledAddHandle.Create(_DesRootPath, _DesFilePath: string);
begin
  DesRootPath := _DesRootPath;
  DesFilePath := _DesFilePath;
end;

procedure TFileRecycledAddHandle.FileCopy;
var
  CopySourcePath, CopySourceRootPath : string;
  CopyDesRootPath, CopyDesPath : string;
  FileRecycledHandle : TFileRecycledHandle;
begin
  CopySourceRootPath := SourceRootPath;
  CopyDesRootPath := DesRootPath;
  CopySourcePath := DesFilePath;
  CopyDesPath := RecycledPath;

  FileRecycledHandle := TFileRecycledHandle.Create( CopySourcePath, CopyDesPath );
  FileRecycledHandle.SetDesRootPath( CopyDesRootPath, CopySourceRootPath );
  FileRecycledHandle.Update;
  FileRecycledHandle.Free;
end;

procedure TFileRecycledAddHandle.FileRemove;
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
begin
  FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( DesFilePath );
  FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
  FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
  FileCopyRemoveHandle.Update;
  FileCopyRemoveHandle.Free;
end;

function TFileRecycledAddHandle.getExistEditionCount: Integer;
begin
  Result := 0;
  if not FileExists( RecycledPath ) then
    Exit;
  Inc( Result );

  while FileExists( FileRecycledUtil.getEditionPath( RecycledPath, Result ) ) do
    Inc( Result );
end;

procedure TFileRecycledAddHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFileRecycledAddHandle.ShowBackupDesBoard;
var
  PlBackupDesBoardShowInfo : TPlBackupDesBoardShowInfo;
begin
  PlBackupDesBoardShowInfo := TPlBackupDesBoardShowInfo.Create( DesFilePath );
  PlBackupDesBoardShowInfo.SetShowType( BackupDesBroadType_Recycling );
  MyBackupFileFace.AddChange( PlBackupDesBoardShowInfo );
end;

procedure TFileRecycledAddHandle.Update;
begin
    // 计算 回收文件保存的路径
  RecycledPath := MyString.CutStartStr( DesRootPath, DesFilePath );
  RecycledPath := MyFilePath.getPath( DesRootPath ) + LocalBackup_RecycledFolder + RecycledPath;

    // 显示正在回收
  MyLocalBackupStatusShow.AddDesRecycled( DesRootPath, SourceRootPath );

    // 显示正在回收
  ShowBackupDesBoard;

    // 检查保存的版本数
  CheckKeedEditionCount;

    // 文件回收
  FileCopy;

    // 文件删除
  FileRemove;
end;

{ TFileRecycledHandle }

procedure TFileRecycledHandle.RefreshFace;
begin
  MyLocalBackupStatusShow.AddDesRecycled( DesRootPath, SourceRootPath );
end;

procedure TFileRecycledHandle.AddCompletedSpace;
var
  LocalBackupSourceAddDesDeletedSpaceHandle : TLocalBackupSourceAddDesDeletedSpaceHandle;
begin
  LocalBackupSourceAddDesDeletedSpaceHandle := TLocalBackupSourceAddDesDeletedSpaceHandle.Create( SourceRootPath );
  LocalBackupSourceAddDesDeletedSpaceHandle.SetDesPath( DesRootPath );
  LocalBackupSourceAddDesDeletedSpaceHandle.SetAddRecycledSpace( SourFileSize );
  LocalBackupSourceAddDesDeletedSpaceHandle.Update;
  LocalBackupSourceAddDesDeletedSpaceHandle.Free;
end;

{ TFolderRecycleHandle }

function TFolderRecycleHandle.CheckNextRecycled: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

    Result := Result and MyLocalBackupSourceReadUtil.getIsEnable( SourceRootPath );
    Result := Result and MyLocalBackupSourceReadUtil.getDesIsEnable( SourceRootPath, DesRootPath );
  end;

    // 可能已经 Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFolderRecycleHandle.Create(_DesRootPath, _DesFolderPath: string);
begin
  DesRootPath := _DesRootPath;
  DesFolderPath := _DesFolderPath;
  SleepCount := 0;
end;

procedure TFolderRecycleHandle.FolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TFolderRecycleHandle.SearchFile(FilePath: string);
var
  FileRecycledAddHandle : TFileRecycledAddHandle;
begin
  FileRecycledAddHandle := TFileRecycledAddHandle.Create( DesRootPath, FilePath );
  FileRecycledAddHandle.SetSourceRootPath( SourceRootPath );
  FileRecycledAddHandle.Update;
  FileRecycledAddHandle.Free;
end;

procedure TFolderRecycleHandle.SearchFolder(FolderPath: string);
var
  FolderRecycleHandle : TFolderRecycleHandle;
begin
  FolderRecycleHandle := TFolderRecycleHandle.Create( DesRootPath, FolderPath );
  FolderRecycleHandle.SetSourceRootPath( SourceRootPath );
  FolderRecycleHandle.SetSleepCount( SleepCount );
  FolderRecycleHandle.Update;
  SleepCount := FolderRecycleHandle.SleepCount;
  FolderRecycleHandle.Free;
end;

procedure TFolderRecycleHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TFolderRecycleHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFolderRecycleHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextRecycled then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( ChildPath )
      else
        SearchFile( ChildPath );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // 目录删除
  FolderRemove;
end;

{ FileRecycledUtil }

class function FileRecycledUtil.getEditionPath(FilePath: string;
  EditionNum: Integer): string;
var
  AfterStr : string;
  BeforeStr : string;
begin
  AfterStr := ExtractFileExt( FilePath );
  BeforeStr := MyString.CutStopStr( AfterStr, FilePath );
  Result := BeforeStr + '.(' + IntToStr(EditionNum) + ')' + AfterStr;
end;

{ TDesPathScanCheckHandle }

function TDesPathScanCheckHandle.CheckDesModify: Boolean;
var
  LocalBackupDesModifyHandle : TLocalBackupDesModifyHandle;
begin
  Result := MyFilePath.getIsModify( DesPath );

  LocalBackupDesModifyHandle := TLocalBackupDesModifyHandle.Create( DesPath );
  LocalBackupDesModifyHandle.SetIsModify( Result );
  LocalBackupDesModifyHandle.Update;
  LocalBackupDesModifyHandle.Free;
end;

function TDesPathScanCheckHandle.CheckDriverExist: Boolean;
var
  DriverPath : string;
  LocalBackupDesExistHandle : TLocalBackupDesExistHandle;
begin
  DriverPath := ExtractFileDrive( DesPath );
  Result := DirectoryExists( DriverPath );

    // 重设
  LocalBackupDesExistHandle := TLocalBackupDesExistHandle.Create( DesPath );
  LocalBackupDesExistHandle.SetIsExist( Result );
  LocalBackupDesExistHandle.Update;
  LocalBackupDesExistHandle.Free;

    // 创建目录
  if Result then
    ForceDirectories( DesPath );
end;

constructor TDesPathScanCheckHandle.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TDesPathScanCheckHandle.get: Boolean;
begin
  Result := False;

    // 驱动器 不存在
  if not CheckDriverExist then
    Exit;

    // 目标路径 不能写入
  if not CheckDesModify then
    Exit;

    // 重设 缺小空间
  ResetLackSpace;

    // 通过检查
  Result := True;
end;

procedure TDesPathScanCheckHandle.ResetLackSpace;
var
  LocalBackupDesLackSpaceHandle : TLocalBackupDesLackSpaceHandle;
begin
  LocalBackupDesLackSpaceHandle := TLocalBackupDesLackSpaceHandle.Create( DesPath );
  LocalBackupDesLackSpaceHandle.SetIsLackSpace( False );
  LocalBackupDesLackSpaceHandle.Update;
  LocalBackupDesLackSpaceHandle.Free;
end;

{ TFolderRemoveHandle }

function TFolderRemoveHandle.CheckNextRemove: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

      // 检查是否中断
    Result := Result and MyLocalBackupDesReadUtil.getIsEnable( DesRootPath );
  end;

    // 可能已经 Disable
  Result := Result and MyLocalBackupHandler.IsRun;
end;

constructor TFolderRemoveHandle.Create(_DesFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
end;

procedure TFolderRemoveHandle.FolderRemove;
begin

end;

procedure TFolderRemoveHandle.SearchFile(FilePath: string);
var
  FileCopyRemoveHandle : TFileCopyRemoveHandle;
begin
  FileCopyRemoveHandle := TFileCopyRemoveHandle.Create( FilePath );
  FileCopyRemoveHandle.SetDesRootPath( DesRootPath );
  FileCopyRemoveHandle.SetSourceRootPath( SourceRootPath );
  FileCopyRemoveHandle.Update;
  FileCopyRemoveHandle.Free;
end;

procedure TFolderRemoveHandle.SearchFolder(FolderPath: string);
var
  FolderRemoveHandle : TFolderRemoveHandle;
begin
  FolderRemoveHandle := TFolderRemoveHandle.Create( FolderPath );
  FolderRemoveHandle.SetDesRootPath( DesRootPath );
  FolderRemoveHandle.SetSourceRootPath( SourceRootPath );
  FolderRemoveHandle.SetSleepCount( SleepCount );
  FolderRemoveHandle.Update;
  SleepCount := FolderRemoveHandle.SleepCount;
  FolderRemoveHandle.Free;
end;

procedure TFolderRemoveHandle.SetDesRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

procedure TFolderRemoveHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TFolderRemoveHandle.SetSourceRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TFolderRemoveHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextRemove then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        SearchFolder( ChildPath )
      else
        SearchFile( ChildPath );

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);

    // 目录删除
  FolderRemove;
end;

end.

