unit UBackupThread;

interface

uses UModelUtil, Generics.Collections, Classes, SysUtils, SyncObjs, UMyUtil, DateUtils,
     Math, URegisterInfo, UMainFormFace, Windows, UFileBaseInfo, sockets, UMyTcp;

type

{$Region ' 备份 扫描 ' }

  TRefreshSpeedInfo = class
  public
    SpeedTime : TDateTime;
    Speed : Int64;
  public
    constructor Create;
    function AddCompleted( CompletedSpace : Int64 ): Boolean;
    procedure ResetSpeed;
  end;

    // 扫描信息
  TScanPathInfo = class
  public
    SourcePath : string; // 源路径
  public
    constructor Create( _SourcePath : string );
  end;
  TScanPathList = class( TObjectList<TScanPathInfo> )end;


    // 搜索的文件信息
  TScanFileInfo = class
  public
    FileName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getEquals( ScanFileInfo : TScanFileInfo ): Boolean;
  end;
  TScanFilePair = TPair< string , TScanFileInfo >;
  TScanFileHash = class( TStringDictionary< TScanFileInfo > );

  {$Region ' 扫描结果信息 ' }

    // 文件比较结果
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // 添加 文件
  TScanResultAddFileInfo = class( TScanResultInfo )
  end;

    // 添加 目录
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // 删除 文件
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // 删除 目录
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

  {$EndRegion}


    // 目录比较算法
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public
    IncludeFilterList : TFileFilterList;  // 包含过滤器
    ExcludeFilterList : TFileFilterList;  // 排除过滤器
  public   // 文件信息
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // 目录信息
    SourceFolderHash : TStringHash;
    DesFolderHash : TStringHash;
  public   // 空间结果
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public
    constructor Create;
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure SetFilterInfo( _IncludeFilterList, _ExcludeFilterList : TFileFilterList );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
    destructor Destroy; override;
  protected
    procedure FindSourceFileInfo;
    procedure FindDesFileInfo;virtual;abstract;
    procedure FileCompare;
    procedure FolderCompare;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;virtual;
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;
    function IsFolderFilter( FolderPath : string ): Boolean;
  private        // 比较结果
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // 比较子目录
    function getScanHandle : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // 文件比较算法
  TFileScanHandle = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // 空间结果
    CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public
    constructor Create( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected
    procedure FindSourceFileInfo;
    function FindDesFileInfo: Boolean;virtual;abstract;
  private        // 比较结果
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

{$EndRegion}


{$Region ' 本地备份 扫描 ' }

    // 本地目录
  TLocalFolderScanHandle = class( TFolderScanHandle )
  public
    DesRootPath, SourceRootPath : string;
  public
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;override;
  protected        // 比较子目录
    function getScanHandle : TFolderScanHandle;override;
  end;

    // 本地文件
  TLocalFileScanHandle = class( TFileScanHandle )
  public
    DesRootPath : string;
  public
    procedure SetRootPath( _DesRootPath : string );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 本地备份 复制/删除 ' }

    // 辅助类
  FileRecycledUtil = class
  public
    class function getEditionPath( FilePath : string; EditionNum : Integer ): string;
  end;

    // 源文件 备份复制
  TLocalFileCopyHandle = class
  protected
    SourFilePath, DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  protected
    RefreshSpeedInfo : TRefreshSpeedInfo;
  protected
    AddCompletedSpace : Int64;
    CopyTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath, _DesFilePath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;
  private
    function CheckNextCopy : Boolean; // 检测是否继续复制
    function getDesIsEnoughSpace : Boolean;  // 检查是否有足够的空间
  protected
    procedure RefreshCompletedSpace;virtual;
  end;

    // 目标文件 回收复制
  TDesFileRecycleCopyHandle = class( TLocalFileCopyHandle )
  protected
    procedure RefreshCompletedSpace;override;
  end;

    // 目标文件 回收
  TDesFileRecycleHandle = class
  public
    DesFilePath : string;
    DesRootPath, SourceRootPath : string;
  public
    RecycledPath : string;
  public
    constructor Create( _DesFilePath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure Update;
  private
    procedure CheckKeedEditionCount;
    procedure FileCopy;
    procedure FileRemove;
  private
    function getExistEditionCount : Integer;
  end;

    // 目标目录 回收
  TDesFolderRecycleHandle = class
  public
    DesFolderPath : string;
    DesRootPath, SourceRootPath : string;
  public
    SleepCount : Integer;
  public
    constructor Create( _DesFolderPath : string );
    procedure SetRootPath( _DesRootPath, _SourceRootPath : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure Update;
  private
    procedure SearchFile( FilePath : string );
    procedure SearchFolder( FolderPath : string );
    procedure FolderRemove;
  private
    function CheckNextRecycled : Boolean;
  end;

{$Endregion}

{$Region ' 本地备份 操作 ' }

    // 扫描信息
  TLocalScanPathInfo = class( TScanPathInfo )
  public
    DesPath : string;
  public
    procedure SetDesPath( _DesPath : string );
  end;

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

    // 结果处理
  TLocalBackupResultHandle = class
  public
    SourcePath, DesPath : string;
    ScanResultInfo : TScanResultInfo;
    SourceFilePath, DesFilePath : string;
    IsRecycled : Boolean;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  public
    constructor Create( _ScanResultInfo : TScanResultInfo );
    procedure SetRootPath( _DesPath, _SourcePath : string );
    procedure SetIsRecycled( _IsRecycled : Boolean );
    procedure SetSpeedInfo( _RefreshSpeedInfo : TRefreshSpeedInfo );
    procedure Update;
  private         // 添加
    procedure SourceFileAdd;
    procedure SourceFolderAdd;
  private         // 删除
    procedure DesFileRemove;
    procedure DesFolderRemove;
  private         // 回收
    procedure DesFileRecycle;
    procedure DesFolderRecycle;
  end;

    // 备份路径处理
  TLocalBackupHandle = class
  public
    LocalScanPathInfo : TLocalScanPathInfo;
    SourcePath, DesPath : string;
  public   // 文件扫描结果
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // 文件变化信息
    ScanResultList : TScanResultList;
  public
    constructor Create( _LocalScanPathInfo : TLocalScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private       // 备份前检测
    function getSourcePathIsExist : Boolean;
    function getDesPathIsBackup: Boolean;
  private       // 扫描
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace;
  private       // 备份
    function getIsFreeLimit : Boolean;
    procedure ResetStartBackupFile;
    procedure BackupFileHandle;
  private       // 备份完成
    procedure ResetBackupCompleted;
  end;

{$EndRegion}


{$Region ' 网络备份 扫描 ' }

    // 网络目录
  TNetworkFolderScanHandle = class( TFolderScanHandle )
  public
    SourceRootPath : string;
  public
    PcID : string;
    TcpSocket : TCustomIpClient;
  public
    procedure SetRootPath( _SourceRootPath : string );
    procedure SetPcInfo( _PcID : string; _TcpSocket : TCustomIpClient );
  protected       // 目标文件信息
    procedure FindDesFileInfo;override;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;override;
  protected        // 比较子目录
    function getScanHandle : TFolderScanHandle;override;
  end;

    // 网络文件
  TNetworkFileScanHandle = class( TFileScanHandle )
  public
    TcpSocket : TCustomIpClient;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
  protected
    function FindDesFileInfo: Boolean;override;
  end;

{$EndRegion}

{$Region ' 网络备份 复制/删除 ' }

    // 源文件 备份复制
  TNetworkFileCopyHandle = class
  protected
    SourFilePath : string;
    PcID, SourceRootPath : string;
    TcpSocket : TCustomIpClient;
    RefreshSpeedInfo : TRefreshSpeedInfo;
  protected
    AddCompletedSpace : Int64;
    StartTime : TDateTime;
  protected
    SleepCount : Integer;
  public
    constructor Create( _SourFilePath : string );
    procedure SetRootPath( _SourceRootPath : string );
    procedure SetDesPcInfo( _PcID : string; _TcpSocket : TCustomIpClient );
    procedure SetRefreshSpeedInfo( _RefreshSppedInfo : TRefreshSpeedInfo );
    procedure Update;
  private
    function CheckNextCopy : Boolean; // 检测是否继续复制
    procedure FileSend;
  protected
    procedure RefreshCompletedSpace;
  end;

{$EndRegion}

{$Region ' 网络备份 操作 ' }

    // 扫描信息
  TNetworkScanPathInfo = class( TScanPathInfo )
  public
    DesPcID : string;
  public
    procedure SetDesPcID( _DesPcID : string );
  end;

    // 备份路径处理
  TNetworkBackupHandle = class
  public
    NetworkScanPathInfo : TNetworkScanPathInfo;
    SourcePath, DesPcID : string;
  public
    TcpSocket : TCustomIpClient;
  public   // 文件扫描结果
    TotalCount : Integer;
    TotalSize, TotalCompleted : Int64;
  public   // 文件变化信息
    ScanResultList : TScanResultList;
  public
    constructor Create( _NetworkScanPathInfo : TNetworkScanPathInfo );
    procedure Update;
    destructor Destroy; override;
  private       // 备份前检测
    function getSourcePathIsExist : Boolean;
    function getDesPcIsBackup: Boolean;
  private       // 扫描
    procedure ScanPathHandle;
    procedure ScanFileHandle;
    procedure ScanFolderHandle;
    procedure ResetSourcePathSpace;
  private       // 备份
    function getIsFreeLimit : Boolean;
    procedure ResetStartBackupFile;
    procedure BackupFileHandle;
    procedure BackupFileAddHandle( FilePath : string );
  private       // 备份完成
    procedure ResetBackupCompleted;
  end;


{$EndRegion}


    // 源目录 扫描
    // 目标目录 复制/删除
  TBackupHandleThread = class( TThread )
  private
    PathLock : TCriticalSection;
    ScanPathList : TScanPathList;
  private
    IsShowFreeLimitError : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public          // 扫描
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    function getScanPathInfo : TScanPathInfo;
    procedure BackupHandle( ScanPathInfo : TScanPathInfo );
  private
    procedure CheckFreeLimit;
    procedure ShowFreeLimitWarnning;
  private
    procedure BackupCompleted;
  end;

    // 本地备份 源路径 扫描和复制
  TMyBackupHandler = class
  private
    LocalBackupThread : TBackupHandleThread;
  public
    IsRun : Boolean;
  public
    constructor Create;
    procedure AddScanPathInfo( ScanPathInfo : TScanPathInfo );
    procedure ShowFreeLimitError;
    procedure StopScan;
  end;

const
  ScanCount_Sleep = 30;
  CopyCount_Sleep = 10;
  LocalBackup_RecycledFolder = 'Recycled';

  FileReq_End = '-1';
  FileReq_File = '0';
  FileReq_Folder = '1';

  FileBackup_End = '-1';
  FileBackup_AddFile = '0';
  FileBackup_AddFolder = '1';
  FileBackup_RemoveFile = '2';
  FileBackup_RemoveFolder = '3';

var
  ScanSource_IsCompleted : Boolean = False;

var
    // 源路径 扫描线程
  MyBackupHandler : TMyBackupHandler;

implementation

uses UMyBackupApiInfo, UMyBackupDataInfo, UMyNetPcInfo, UMyBackupEventInfo;

{ TFileCopyHandle }

function TLocalFileCopyHandle.getDesIsEnoughSpace: Boolean;
var
  FreeSize : Int64;
begin
  Result := True;
  FreeSize := MyHardDisk.getHardDiskFreeSize( DesRootPath );

    // 是否有足够的空间
  if FreeSize >= MyFileInfo.getFileSize( SourFilePath ) then
    Exit;

    // 缺少空间
  DesItemAppApi.setIsLackSpace( DesRootPath, True );

  Result := False;
end;

function TLocalFileCopyHandle.CheckNextCopy: Boolean;
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
  if SecondsBetween( Now, CopyTime ) >= 1 then
  begin
      // 刷新界面
    RefreshCompletedSpace;

      // 检测 是否备份中断
    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
    CopyTime := Now;
  end;

    // 可能已经 Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TLocalFileCopyHandle.Create(_SourFilePath, _DesFilePath: string);
begin
  SourFilePath := _SourFilePath;
  DesFilePath := _DesFilePath;
  SleepCount := 0;
  AddCompletedSpace := 0;
  CopyTime := Now;
end;

procedure TLocalFileCopyHandle.RefreshCompletedSpace;
begin
    // 刷新速度
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // 设置 刷新备份速度
    BackupItemAppApi.SetSpeed( DesRootPath, SourceRootPath, RefreshSpeedInfo.Speed );
    RefreshSpeedInfo.ResetSpeed;
  end;

    // 设置 已完成空间
  BackupItemAppApi.AddBackupCompletedSpace( DesRootPath, SourceRootPath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TLocalFileCopyHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TLocalFileCopyHandle.SetSpeedInfo(
  _RefreshSpeedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TLocalFileCopyHandle.Update;
var
  SourFileStream, DesFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SourceFileTime : TDateTime;
begin
    // 源文件不存在
  if not FileExists( SourFilePath ) then
    Exit;

    // 目标路径没有足够的空间
  if not getDesIsEnoughSpace then
    Exit;

    // 文件流
  try
    SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );
    ForceDirectories( ExtractFileDir( DesFilePath ) );
    DesFileStream := TFileStream.Create( DesFilePath, fmCreate or fmShareDenyNone );

    FullBufSize := SizeOf( Buf );
    RemainSize := SourFileStream.Size;
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
      AddCompletedSpace := AddCompletedSpace + BufSize;
    end;

      // 添加已完成空间
    RefreshCompletedSpace;

    DesFileStream.Free;
    SourFileStream.Free;

      // 设置修改时间
    SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
    MyFileSetTime.SetTime( DesFilePath, SourceFileTime );
  except
  end;
end;

{ TLocalBackupSourceScanThread }

procedure TBackupHandleThread.AddScanPathInfo(
  ScanPathInfo : TScanPathInfo);
begin
  PathLock.Enter;
  ScanPathList.Add( ScanPathInfo );
  PathLock.Leave;

  Resume;
end;

procedure TBackupHandleThread.CheckFreeLimit;
begin
    // 非试用版, 跳过
  if not RegisterInfo.getIsFreeEdition then
    Exit;

    // 检测试用限制
  if IsShowFreeLimitError and
     ( DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace )
  then
    ShowFreeLimitWarnning; // 显示超出限制

  IsShowFreeLimitError := False;
end;

constructor TBackupHandleThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  ScanPathList := TScanPathList.Create;
  ScanPathList.OwnsObjects := False;
  IsShowFreeLimitError := False;
end;

destructor TBackupHandleThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  ScanPathList.OwnsObjects := True;
  ScanPathList.Free;
  PathLock.Free;

  inherited;
end;

procedure TBackupHandleThread.Execute;
var
  ScanPathInfo : TScanPathInfo;
begin
  while not Terminated do
  begin
    ScanPathInfo := getScanPathInfo;
    if ScanPathInfo = nil then
    begin
      CheckFreeLimit; // 检查是否超过试用限制
      if not Terminated then
      begin
        Suspend;
        Continue;
      end;
    end;

    BackupHandle( ScanPathInfo );  // 扫描路径

    ScanPathInfo.Free;
  end;
  inherited;
end;

function TBackupHandleThread.getScanPathInfo: TScanPathInfo;
begin
  PathLock.Enter;
  if ScanPathList.Count > 0 then
  begin
    Result := ScanPathList[0];
    ScanPathList.Delete(0);
  end
  else
    Result := nil;
  PathLock.Leave;
end;

procedure TBackupHandleThread.BackupHandle(ScanPathInfo: TScanPathInfo);
var
  LocalScanPathHandle : TLocalBackupHandle;
  NetworkBackupHandle : TNetworkBackupHandle;
begin
  if ScanPathInfo is TLocalScanPathInfo then
  begin
    LocalScanPathHandle := TLocalBackupHandle.Create( ScanPathInfo as TLocalScanPathInfo );
    LocalScanPathHandle.Update;
    LocalScanPathHandle.Free;
  end
  else
  if ScanPathInfo is TNetworkScanPathInfo then
  begin
    NetworkBackupHandle := TNetworkBackupHandle.Create( ScanPathInfo as TNetworkScanPathInfo );
    NetworkBackupHandle.Update;
    NetworkBackupHandle.Free;
  end;
end;

procedure TBackupHandleThread.ShowFreeLimitWarnning;
var
  ShowFreeEditionWarnning : TShowFreeEditionWarnning;
begin
  ShowFreeEditionWarnning := TShowFreeEditionWarnning.Create( FreeEditionError_BackupSpace );
  MyMainFormFace.AddChange( ShowFreeEditionWarnning );
end;

procedure TBackupHandleThread.BackupCompleted;
begin

end;


{ TScanPathInfo }

constructor TScanPathInfo.Create(_SourcePath: string);
begin
  SourcePath := _SourcePath;
end;

{ TMyLocalBackupSourceScanner }

procedure TMyBackupHandler.AddScanPathInfo(
  ScanPathInfo: TScanPathInfo);
begin
  if not IsRun then
    Exit;

  LocalBackupThread.AddScanPathInfo( ScanPathInfo );
end;

constructor TMyBackupHandler.Create;
begin
  LocalBackupThread := TBackupHandleThread.Create;
  IsRun := True;
end;

procedure TMyBackupHandler.ShowFreeLimitError;
begin
  LocalBackupThread.IsShowFreeLimitError := True;
end;

procedure TMyBackupHandler.StopScan;
begin
  IsRun := False;
  LocalBackupThread.Free;
end;


{ TScanPathHandle }

destructor TLocalBackupHandle.Destroy;
begin
  ScanResultList.Free;
  inherited;
end;

function TLocalBackupHandle.getDesPathIsBackup: Boolean;
var
  DesPathScanCheckHandle : TDesPathScanCheckHandle;
begin
  DesPathScanCheckHandle := TDesPathScanCheckHandle.Create( DesPath );
  Result := DesPathScanCheckHandle.get;
  DesPathScanCheckHandle.Free;
end;

function TLocalBackupHandle.getIsFreeLimit: Boolean;
begin
  Result := DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace;
end;

function TLocalBackupHandle.getSourcePathIsExist: Boolean;
begin
  Result := MyFilePath.getIsExist( SourcePath );

    // 返回 是否存在备份路径
  BackupItemAppApi.SetIsExist( DesPath, SourcePath, Result );
end;

procedure TLocalBackupHandle.BackupFileHandle;
var
  IsRecycled : Boolean;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  i : Integer;
  ScanResultInfo : TScanResultInfo;
  LocalBackupResultHandle : TLocalBackupResultHandle;
begin
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  IsRecycled := BackupItemInfoReadUtil.ReadIsKeepDeleted( DesPath, SourcePath );
  for i := 0 to ScanResultList.Count - 1 do
  begin
    ScanResultInfo := ScanResultList[i];
    LocalBackupResultHandle := TLocalBackupResultHandle.Create( ScanResultInfo );
    LocalBackupResultHandle.SetRootPath( DesPath, SourcePath );
    LocalBackupResultHandle.SetIsRecycled( IsRecycled );
    LocalBackupResultHandle.SetSpeedInfo( RefreshSpeedInfo );
    LocalBackupResultHandle.Update;
    LocalBackupResultHandle.Free;
  end;
  RefreshSpeedInfo.Free;
end;

constructor TLocalBackupHandle.Create(_LocalScanPathInfo: TLocalScanPathInfo);
begin
  LocalScanPathInfo := _LocalScanPathInfo;
  SourcePath := LocalScanPathInfo.SourcePath;
  DesPath := LocalScanPathInfo.DesPath;
  ScanResultList := TScanResultList.Create;
end;

procedure TLocalBackupHandle.ResetBackupCompleted;
var
  Params : TLocalBackupEventParam;
begin
    // 扫描完成
  BackupItemAppApi.SetBackupCompleted( DesPath, SourcePath );

    // 触发事件
  Params.DesPath := DesPath;
  Params.SourcePath := SourcePath;
  Params.IsFile := FileExists( SourcePath );
  Params.FileCount := TotalCount;
  Params.FileSpce := TotalSize;
  LocalBackupEvent.BackupCompleted( Params );
end;

procedure TLocalBackupHandle.ResetSourcePathSpace;
begin
    // 最后一次 显示扫描文件数
  BackupItemAppApi.SetScaningCount( DesPath, SourcePath, TotalCount );

    // 重设 源路径空间
  BackupItemAppApi.SetSpaceInfo( DesPath, SourcePath, TotalCount, TotalSize, TotalCompleted );
end;

procedure TLocalBackupHandle.ResetStartBackupFile;
begin
  BackupItemAppApi.SetStartBackup( DesPath, SourcePath );
end;

procedure TLocalBackupHandle.ScanFileHandle;
var
  LocalFileScanHandle : TLocalFileScanHandle;
begin
  LocalFileScanHandle := TLocalFileScanHandle.Create( SourcePath );
  LocalFileScanHandle.SetRootPath( DesPath );
  LocalFileScanHandle.SetResultList( ScanResultList );
  LocalFileScanHandle.Update;
  TotalSize := LocalFileScanHandle.SourceFileSize;
  TotalCount := 1;
  TotalCompleted := LocalFileScanHandle.CompletedSize;
  LocalFileScanHandle.Free;
end;

procedure TLocalBackupHandle.ScanFolderHandle;
var
  IncludeFilterList : TFileFilterList;  // 包含过滤器
  ExcludeFilterList : TFileFilterList;  // 排除过滤器
  LocalFolderScanHandle : TLocalFolderScanHandle;
begin
  IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesPath, SourcePath );
  ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesPath, SourcePath );

  LocalFolderScanHandle := TLocalFolderScanHandle.Create;
  LocalFolderScanHandle.SetSourceFolderPath( SourcePath );
  LocalFolderScanHandle.SetRootPath( DesPath, SourcePath );
  LocalFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  LocalFolderScanHandle.SetResultList( ScanResultList );
  LocalFolderScanHandle.Update;
  TotalSize := LocalFolderScanHandle.FileSize;
  TotalCount := LocalFolderScanHandle.FileCount;
  TotalCompleted := LocalFolderScanHandle.CompletedSize;
  LocalFolderScanHandle.Free;

  IncludeFilterList.Free;
  ExcludeFilterList.Free;
end;

procedure TLocalBackupHandle.ScanPathHandle;
begin
    // 扫描 本地文件
  if FileExists( SourcePath ) then
    ScanFileHandle
  else   // 扫描 本地目录
    ScanFolderHandle;
end;

procedure TLocalBackupHandle.Update;
begin
    // 源路径不存在, 不扫描
  if not getSourcePathIsExist then
    Exit;

    // 目标路径无法备份，不扫描
  if not getDesPathIsBackup then
    Exit;

    // 扫描路径
  ScanPathHandle;
  ResetSourcePathSpace; // 重设路径空间信息

    // 备份路径
  if not getIsFreeLimit then  // 是否受到试用版限制
  begin
    ResetStartBackupFile;
    BackupFileHandle;
  end;

    // 设置 上次同步时间
  ResetBackupCompleted;
end;


{ TFileRecycledHandle }

procedure TDesFileRecycleHandle.CheckKeedEditionCount;
var
  KeepEditionCount : Integer;
  ExistEditionCount : Integer;
  i : Integer;
  FilePath1, FilePath2 : string;
begin
  KeepEditionCount := BackupItemInfoReadUtil.ReadIsKeepEditionCount( DesRootPath, SourceRootPath );
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

constructor TDesFileRecycleHandle.Create(_DesFilePath: string);
begin
  DesFilePath := _DesFilePath;
end;

procedure TDesFileRecycleHandle.FileCopy;
var
  CopySourcePath, CopyDesPath : string;
  FileRecycledHandle : TDesFileRecycleCopyHandle;
begin
  CopySourcePath := DesFilePath;
  CopyDesPath := RecycledPath;

  FileRecycledHandle := TDesFileRecycleCopyHandle.Create( CopySourcePath, CopyDesPath );
  FileRecycledHandle.SetRootPath( DesRootPath, SourceRootPath );
  FileRecycledHandle.Update;
  FileRecycledHandle.Free;
end;

procedure TDesFileRecycleHandle.FileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

function TDesFileRecycleHandle.getExistEditionCount: Integer;
begin
  Result := 0;
  if not FileExists( RecycledPath ) then
    Exit;
  Inc( Result );

  while FileExists( FileRecycledUtil.getEditionPath( RecycledPath, Result ) ) do
    Inc( Result );
end;

procedure TDesFileRecycleHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TDesFileRecycleHandle.Update;
begin
    // 计算 回收文件保存的路径
  RecycledPath := MyString.CutStartStr( DesRootPath, DesFilePath );
  RecycledPath := MyFilePath.getPath( DesRootPath ) + LocalBackup_RecycledFolder + RecycledPath;

    // 检查保存的版本数
  CheckKeedEditionCount;

    // 文件回收
  FileCopy;

    // 文件删除
  FileRemove;
end;

{ TFileRecycledHandle }

procedure TDesFileRecycleCopyHandle.RefreshCompletedSpace;
begin
end;

{ TFolderRecycleHandle }

function TDesFolderRecycleHandle.CheckNextRecycled: Boolean;
begin
  Result := True;

      // sleep
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;

    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
  end;

    // 可能已经 Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TDesFolderRecycleHandle.Create(_DesFolderPath: string);
begin
  DesFolderPath := _DesFolderPath;
  SleepCount := 0;
end;

procedure TDesFolderRecycleHandle.FolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFolderPath );
end;

procedure TDesFolderRecycleHandle.SearchFile(FilePath: string);
var
  FileRecycledAddHandle : TDesFileRecycleHandle;
begin
  FileRecycledAddHandle := TDesFileRecycleHandle.Create( FilePath );
  FileRecycledAddHandle.SetRootPath( DesRootPath, SourceRootPath );
  FileRecycledAddHandle.Update;
  FileRecycledAddHandle.Free;
end;

procedure TDesFolderRecycleHandle.SearchFolder(FolderPath: string);
var
  FolderRecycleHandle : TDesFolderRecycleHandle;
begin
  FolderRecycleHandle := TDesFolderRecycleHandle.Create( FolderPath );
  FolderRecycleHandle.SetRootPath( DesRootPath, SourceRootPath );
  FolderRecycleHandle.SetSleepCount( SleepCount );
  FolderRecycleHandle.Update;
  SleepCount := FolderRecycleHandle.SleepCount;
  FolderRecycleHandle.Free;
end;

procedure TDesFolderRecycleHandle.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TDesFolderRecycleHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

procedure TDesFolderRecycleHandle.Update;
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
begin
  Result := MyFilePath.getIsModify( DesPath );

    // 设置 是否可写 目标路径
  DesItemAppApi.SetIsWrite( DesPath, Result );
end;

function TDesPathScanCheckHandle.CheckDriverExist: Boolean;
var
  DriverPath : string;
begin
  DriverPath := ExtractFileDrive( DesPath );
  Result := DirectoryExists( DriverPath );

    // 设置 是否存在 目标路径
  DesItemAppApi.SetIsExist( DesPath, Result );

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
begin
  DesItemAppApi.SetIsLackSpace( DesPath, False );
end;

{ TScanFileInfo }

constructor TScanFileInfo.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TScanFileInfo.getEquals(ScanFileInfo: TScanFileInfo): Boolean;
begin
  Result := ( ScanFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( FileTime, ScanFileInfo.FileTime ) );
end;

procedure TScanFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TFolderCompareHandle }

procedure TFolderScanHandle.AddFileResult(FileName : string);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

procedure TFolderScanHandle.AddFolderResult(FolderName: string);
var
  ScanResultAddFolderInfo : TScanResultAddFolderInfo;
begin
  ScanResultAddFolderInfo := TScanResultAddFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultAddFolderInfo );
end;

function TFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := True;

    // N 个文件小停一次
  Inc( SleepCount );
  if SleepCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TFolderScanHandle.CompareChildFolder(SourceFolderName: string);
var
  ChildFolderPath : string;
  FolderScanHandle : TFolderScanHandle;
begin
  ChildFolderPath := MyFilePath.getPath( SourceFolderPath ) + SourceFolderName;
  FolderScanHandle := getScanHandle;
  FolderScanHandle.SetSourceFolderPath( ChildFolderPath );
  FolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  FolderScanHandle.SetResultList( ScanResultList );
  FolderScanHandle.FileCount := FileCount;
  FolderScanHandle.FileSize := FileSize;
  FolderScanHandle.CompletedSize := CompletedSize;
  FolderScanHandle.SleepCount := SleepCount;
  FolderScanHandle.ScanTime := ScanTime;
  FolderScanHandle.Update;
  FileCount := FolderScanHandle.FileCount;
  FileSize := FolderScanHandle.FileSize;
  CompletedSize := FolderScanHandle.CompletedSize;
  SleepCount := FolderScanHandle.SleepCount;
  ScanTime := FolderScanHandle.ScanTime;
  FolderScanHandle.Free;
end;

constructor TFolderScanHandle.Create;
begin
  SourceFileHash := TScanFileHash.Create;
  DesFileHash := TScanFileHash.Create;
  SourceFolderHash := TStringHash.Create;
  DesFolderHash := TStringHash.Create;
  FileCount := 0;
  FileSize := 0;
  CompletedSize := 0;
  SleepCount := 0;
  ScanTime := Now;
end;

destructor TFolderScanHandle.Destroy;
begin
  SourceFileHash.Free;
  DesFileHash.Free;
  SourceFolderHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TFolderScanHandle.FileCompare;
var
  p : TScanFilePair;
  FileName : string;
begin
    // 遍历 源文件
  for p in SourceFileHash do
  begin
      // 检查是否继续扫描
    if not CheckNextScan then
      Break;

      // 添加到统计信息
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

    FileName := p.Value.FileName;

      // 目标文件不存在
    if not DesFileHash.ContainsKey( FileName ) then
    begin
      AddFileResult( FileName );
      Continue;
    end;

      // 目标文件与源文件不一致
    if not p.Value.getEquals( DesFileHash[ FileName ] ) then
    begin
      RemoveFileResult( FileName ); // 先删除
      AddFileResult( FileName );  // 后添加
    end
    else  // 目标文件与源文件一致
      CompletedSize := CompletedSize + p.Value.FileSize;

      // 删除目标文件
    DesFileHash.Remove( FileName );
  end;

    // 遍历目标文件
  for p in DesFileHash do
    RemoveFileResult( p.Value.FileName );  // 删除目标文件
end;

procedure TFolderScanHandle.FindSourceFileInfo;
var
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  SourceScanFileInfo : TScanFileInfo;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( SourceFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
      if IsFolder then
        IsFillter := IsFolderFilter( ChildPath )
      else
        IsFillter := IsFileFilter( ChildPath, sch );
      if IsFillter then  // 文件被过滤
        Continue;

        // 添加到目录结果
      if IsFolder then
        SourceFolderHash.AddString( FileName )
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 添加到文件结果集合中
        SourceScanFileInfo := TScanFileInfo.Create( FileName );
        SourceScanFileInfo.SetFileInfo( FileSize, FileTime );
        SourceFileHash.AddOrSetValue( FileName, SourceScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TStringPart;
  FolderName : string;
begin
    // 遍历源目录
  for p in SourceFolderHash do
  begin
    FolderName := p.Value;

      // 不存在目标目录，则创建
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName )
    else
      DesFolderHash.Remove( FolderName );

      // 比较子目录
    CompareChildFolder( FolderName );
  end;

    // 遍历目标目录
  for p in DesFolderHash do
    RemoveFolderResult( p.Value );
end;

function TFolderScanHandle.getChildPath(ChildName: string): string;
begin
  Result := MyFilePath.getPath( SourceFolderPath ) + ChildName;
end;

function TFolderScanHandle.IsFileFilter(FilePath: string;
  sch: TSearchRec): Boolean;
begin
  Result := True;

    // 不在包含列表中
  if not FileFilterUtil.IsFileInclude( FilePath, sch, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFileExclude( FilePath, sch, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

function TFolderScanHandle.IsFolderFilter(FolderPath: string): Boolean;
begin
  Result := True;

    // 不在包含列表中
  if not FileFilterUtil.IsFolderInclude( FolderPath, IncludeFilterList ) then
    Exit;

    // 在排除列表中
  if FileFilterUtil.IsFolderExclude( FolderPath, ExcludeFilterList ) then
    Exit;

  Result := False;
end;

procedure TFolderScanHandle.RemoveFileResult(FileName : string);
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFolderScanHandle.RemoveFolderResult(FolderName: string);
var
  ScanResultRemoveFolderInfo : TScanResultRemoveFolderInfo;
begin
  ScanResultRemoveFolderInfo := TScanResultRemoveFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultRemoveFolderInfo );
end;

procedure TFolderScanHandle.SetFilterInfo(_IncludeFilterList,
  _ExcludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TFolderScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFolderScanHandle.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TFolderScanHandle.Update;
begin
    // 找源文件信息
  FindSourceFileInfo;

    // 找目标文件信息
  FindDesFileInfo;

    // 文件比较
  FileCompare;

    // 目录比较
  FolderCompare;
end;

{ TScanResultInfo }

constructor TScanResultInfo.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TFileScanHandle }

procedure TFileScanHandle.AddFileResult;
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

constructor TFileScanHandle.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
  CompletedSize := 0;
end;

procedure TFileScanHandle.FindSourceFileInfo;
begin
  SourceFileSize := MyFileInfo.getFileSize( SourceFilePath );
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourceFilePath );
end;

function TFileScanHandle.IsEqualsDes: Boolean;
begin
  Result := ( SourceFileSize = DesFileSize ) and
            ( MyDatetime.Equals( SourceFileTime, DesFileTime ) );
end;

procedure TFileScanHandle.RemoveFileResult;
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFileScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFileScanHandle.Update;
begin
    // 源文件信息
  FindSourceFileInfo;

    // 目标文件不存在
  if not FindDesFileInfo then
  begin
    AddFileResult;
    Exit;
  end;

    // 目标文件与源文件不一致
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
    CompletedSize := SourceFileSize;
end;

{ TLocalFolderScanHandle }

function TLocalFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited;

    // 1 秒钟 检测一次
  if SecondsBetween( Now, ScanTime ) >= 1 then
  begin
      // 显示扫描文件数
    BackupItemAppApi.SetScaningCount( DesRootPath, SourceRootPath, FileCount );

      // 检查是否中断备份
    Result := Result and BackupItemInfoReadUtil.ReadIsEnable( DesRootPath, SourceRootPath );
    ScanTime := Now;
  end;

    // 返回 是否继续扫描
  Result := Result and MyBackupHandler.IsRun;
end;

procedure TLocalFolderScanHandle.FindDesFileInfo;
var
  DesFolderPath : string;
  sch : TSearchRec;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder, IsFillter : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
  DesScanFileInfo : TScanFileInfo;
begin
    // 循环寻找 目录文件信息
  DesFolderPath := MyFilePath.getPath( DesRootPath ) + MyFilePath.getDownloadPath( SourceFolderPath );
  SearcFullPath := MyFilePath.getPath( DesFolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检测文件过滤
      ChildPath := SearcFullPath + FileName;

        // 添加到目录结果
      if DirectoryExists( ChildPath ) then
        DesFolderHash.AddString( FileName )
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 添加到文件结果集合中
        DesScanFileInfo := TScanFileInfo.Create( FileName );
        DesScanFileInfo.SetFileInfo( FileSize, FileTime );
        DesFileHash.Add( FileName, DesScanFileInfo );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

function TLocalFolderScanHandle.getScanHandle: TFolderScanHandle;
var
  LocalFolderScanHandle : TLocalFolderScanHandle;
begin
  LocalFolderScanHandle := TLocalFolderScanHandle.Create;
  LocalFolderScanHandle.SetRootPath( DesRootPath, SourceRootPath );
  Result := LocalFolderScanHandle;
end;

procedure TLocalFolderScanHandle.SetRootPath(_DesRootPath,
  _SourceRootPath: string);
begin
  DesRootPath := _DesRootPath;
  SourceRootPath := _SourceRootPath;
end;

{ TLocalFileScanHandle }

function TLocalFileScanHandle.FindDesFileInfo: Boolean;
var
  DesFilePath : string;
begin
  DesFilePath := MyFilePath.getPath( DesRootPath ) + MyFilePath.getDownloadPath( SourceFilePath );
  Result := FileExists( DesFilePath );
  if not Result then
    Exit;
  DesFileSize := MyFileInfo.getFileSize( DesFilePath );
  DesFileTime := MyFileInfo.getFileLastWriteTime( DesFilePath );
end;

procedure TLocalFileScanHandle.SetRootPath(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

{ TLocalBackupResultHandle }

constructor TLocalBackupResultHandle.Create(_ScanResultInfo: TScanResultInfo);
begin
  ScanResultInfo := _ScanResultInfo;
end;

procedure TLocalBackupResultHandle.DesFileRecycle;
var
  DesFileRecycleHandle : TDesFileRecycleHandle;
begin
  DesFileRecycleHandle := TDesFileRecycleHandle.Create( DesFilePath );
  DesFileRecycleHandle.SetRootPath( DesPath, SourcePath );
  DesFileRecycleHandle.Update;
  DesFileRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFileRemove;
begin
  SysUtils.DeleteFile( DesFilePath );
end;

procedure TLocalBackupResultHandle.DesFolderRecycle;
var
  DesFolderRecycleHandle : TDesFolderRecycleHandle;
begin
  DesFolderRecycleHandle := TDesFolderRecycleHandle.Create( DesFilePath );
  DesFolderRecycleHandle.SetRootPath( DesPath, SourcePath );
  DesFolderRecycleHandle.Update;
  DesFolderRecycleHandle.Free;
end;

procedure TLocalBackupResultHandle.DesFolderRemove;
begin
  MyFolderDelete.DeleteDir( DesFilePath );
end;

procedure TLocalBackupResultHandle.SetIsRecycled(_IsRecycled: Boolean);
begin
  IsRecycled := _IsRecycled;
end;

procedure TLocalBackupResultHandle.SetRootPath(_DesPath, _SourcePath : string);
begin
  DesPath := _DesPath;
  SourcePath := _SourcePath;
end;

procedure TLocalBackupResultHandle.SetSpeedInfo(_RefreshSpeedInfo : TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSpeedInfo;
end;

procedure TLocalBackupResultHandle.SourceFileAdd;
var
  FileCopyHandle : TLocalFileCopyHandle;
begin
  FileCopyHandle := TLocalFileCopyHandle.Create( SourceFilePath, DesFilePath );
  FileCopyHandle.SetRootPath( DesPath, SourcePath );
  FileCopyHandle.SetSpeedInfo( RefreshSpeedInfo );
  FileCopyHandle.Update;
  FileCopyHandle.Free;
end;

procedure TLocalBackupResultHandle.SourceFolderAdd;
begin
  ForceDirectories( DesFilePath );
end;

procedure TLocalBackupResultHandle.Update;
begin
  SourceFilePath := ScanResultInfo.SourceFilePath;
  DesFilePath := MyFilePath.getPath( DesPath ) + MyFilePath.getDownloadPath( SourceFilePath );
  if ScanResultInfo is TScanResultAddFileInfo then
    SourceFileAdd
  else
  if ScanResultInfo is TScanResultAddFolderInfo then
    SourceFolderAdd
  else
  if ScanResultInfo is TScanResultRemoveFileInfo then
  begin
    if IsRecycled then
      DesFileRecycle
    else
      DesFileRemove
  end
  else
  if ScanResultInfo is TScanResultRemoveFolderInfo then
  begin
    if IsRecycled then
      DesFolderRecycle
    else
      DesFolderRemove;
  end;
end;

{ TNetworkFolderScanHandle }

function TNetworkFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := inherited;
end;

procedure TNetworkFolderScanHandle.FindDesFileInfo;
var
  FileReq : string;
  FileName : string;
  FileSize : Int64;
  FileTime : TDateTime;
  ScanFileInfo : TScanFileInfo;
begin
  MySocketUtil.SendString( TcpSocket, SourceFolderPath );
  while True do
  begin
    FileReq := MySocketUtil.RevString( TcpSocket );
    if ( FileReq = FileReq_End ) or ( FileReq = '' ) then // 结束
      Break;
    FileName := MySocketUtil.RevString( TcpSocket );
    if FileReq = FileReq_File then  // 文件
    begin
      FileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), 0 );
      FileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), Now );
      ScanFileInfo := TScanFileInfo.Create( FileName );
      ScanFileInfo.SetFileInfo( FileSize, FileTime );
      DesFileHash.AddOrSetValue( FileName, ScanFileInfo );
    end
    else  // 目录
    if FileReq = FileReq_Folder then
      DesFolderHash.AddString( FileName );
  end;
end;

function TNetworkFolderScanHandle.getScanHandle: TFolderScanHandle;
var
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
begin
  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetRootPath( SourceRootPath );
  NetworkFolderScanHandle.SetPcInfo( PcID, TcpSocket );
  Result := NetworkFolderScanHandle;
end;

procedure TNetworkFolderScanHandle.SetPcInfo(_PcID: string;
  _TcpSocket: TCustomIpClient);
begin
  PcID := _PcID;
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFolderScanHandle.SetRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;



{ TLocalScanPathInfo }

procedure TLocalScanPathInfo.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TNetworkScanPathInfo }

procedure TNetworkScanPathInfo.SetDesPcID(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

{ TNetworkBackupHandle }

procedure TNetworkBackupHandle.BackupFileAddHandle( FilePath : string );
var
  NetworkFileCopyHandle : TNetworkFileCopyHandle;
begin
  NetworkFileCopyHandle := TNetworkFileCopyHandle.Create( FilePath );
  NetworkFileCopyHandle.SetRootPath( SourcePath );
  NetworkFileCopyHandle.SetDesPcInfo( DesPcID, TcpSocket );
  NetworkFileCopyHandle.Update;
  NetworkFileCopyHandle.Free;
end;

procedure TNetworkBackupHandle.BackupFileHandle;
var
  i: Integer;
  ScanResultInfo : TScanResultInfo;
  FileBackupType : string;
  RefreshSpeedInfo : TRefreshSpeedInfo;
  NetworkFileCopyHandle : TNetworkFileCopyHandle;
begin
  RefreshSpeedInfo := TRefreshSpeedInfo.Create;
  for i := 0 to ScanResultList.Count - 1 do
  begin
    ScanResultInfo := ScanResultList[i];
    if ScanResultInfo is TScanResultAddFileInfo then
      FileBackupType := FileBackup_AddFile
    else
    if ScanResultInfo is TScanResultAddFolderInfo then
      FileBackupType := FileBackup_AddFolder
    else
    if ScanResultInfo is TScanResultRemoveFileInfo then
      FileBackupType := FileBackup_RemoveFile
    else
    if ScanResultInfo is TScanResultRemoveFolderInfo then
      FileBackupType := FileBackup_RemoveFolder;

      // 发送给 目标Pc 处理
    MySocketUtil.SendString( TcpSocket, FileBackupType );
    MySocketUtil.SendString( TcpSocket, ScanResultInfo.SourceFilePath );
    if FileBackupType = FileBackup_AddFile then
    begin
      NetworkFileCopyHandle := TNetworkFileCopyHandle.Create( ScanResultInfo.SourceFilePath );
      NetworkFileCopyHandle.SetRootPath( SourcePath );
      NetworkFileCopyHandle.SetDesPcInfo( DesPcID, TcpSocket );
      NetworkFileCopyHandle.SetRefreshSpeedInfo( RefreshSpeedInfo );
      NetworkFileCopyHandle.Update;
      NetworkFileCopyHandle.Free;
    end;
  end;
  MySocketUtil.SendString( TcpSocket, FileBackup_End );
  RefreshSpeedInfo.Free;
end;

constructor TNetworkBackupHandle.Create(
  _NetworkScanPathInfo: TNetworkScanPathInfo);
begin
  NetworkScanPathInfo := _NetworkScanPathInfo;
  SourcePath := NetworkScanPathInfo.SourcePath;
  DesPcID := NetworkScanPathInfo.DesPcID;
  ScanResultList := TScanResultList.Create;
  TcpSocket := TCustomIpClient.Create( nil );
end;


destructor TNetworkBackupHandle.Destroy;
begin
  TcpSocket.Free;
  ScanResultList.Free;
  inherited;
end;

function TNetworkBackupHandle.getDesPcIsBackup: Boolean;
var
  MyTcpConn : TMyTcpConn;
  DesPcIP, DesPcPort : string;
begin
  Result := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );
  if not Result then
    Exit;

    // 提取 目标 Pc 端口
  DesPcIP := MyNetPcInfoReadUtil.ReadIp( DesPcID );
  DesPcPort := MyNetPcInfoReadUtil.ReadPort( DesPcID );

    // 连接 目标 Pc
  MyTcpConn := TMyTcpConn.Create( TcpSocket );
  MyTcpConn.SetConnType( ConnType_NetworkBackup );
  MyTcpConn.SetConnSocket( DesPcIP, DesPcPort );
  Result := MyTcpConn.Conn;
  MyTcpConn.Free;
end;

function TNetworkBackupHandle.getIsFreeLimit: Boolean;
begin
  Result := DesItemInfoReadUtil.ReadTotalSpace > EditionUtil.getFreeMaxBackupSpace;
end;

function TNetworkBackupHandle.getSourcePathIsExist: Boolean;
begin
  Result := MyFilePath.getIsExist( SourcePath );
  BackupItemAppApi.SetIsExist( DesPcID, SourcePath, Result );
end;

procedure TNetworkBackupHandle.ResetBackupCompleted;
var
  Params : TBackupCompletedEventParam;
begin
  BackupItemAppApi.SetBackupCompleted( DesPcID, SourcePath );

  Params.PcID := DesPcID;
  Params.SourcePath := SourcePath;
  Params.IsFile := FileExists( SourcePath );
  Params.FileCount := TotalCount;
  Params.FileSpce := TotalSize;

  NetworkBackupEvent.BackupCompleted( Params );
end;

procedure TNetworkBackupHandle.ResetSourcePathSpace;
begin
  BackupItemAppApi.SetSpaceInfo( DesPcID, SourcePath, TotalCount, TotalSize, TotalCompleted );
end;

procedure TNetworkBackupHandle.ResetStartBackupFile;
begin
  BackupItemAppApi.SetStartBackup( DesPcID, SourcePath );
end;

procedure TNetworkBackupHandle.ScanFileHandle;
var
  NetworkFileScanHandle : TNetworkFileScanHandle;
begin
  NetworkFileScanHandle := TNetworkFileScanHandle.Create( SourcePath );
  NetworkFileScanHandle.SetTcpSocket( TcpSocket );
  NetworkFileScanHandle.SetResultList( ScanResultList );
  NetworkFileScanHandle.Update;
  TotalCount := 1;
  TotalSize := NetworkFileScanHandle.SourceFileSize;
  TotalCompleted := NetworkFileScanHandle.CompletedSize;
  NetworkFileScanHandle.Free;
end;

procedure TNetworkBackupHandle.ScanFolderHandle;
var
  NetworkFolderScanHandle : TNetworkFolderScanHandle;
  IncludeFilterList : TFileFilterList;  // 包含过滤器
  ExcludeFilterList : TFileFilterList;  // 排除过滤器
begin
  IncludeFilterList := BackupItemInfoReadUtil.ReadIncludeFilter( DesPcID, SourcePath );
  ExcludeFilterList := BackupItemInfoReadUtil.ReadExcludeFilter( DesPcID, SourcePath );

  NetworkFolderScanHandle := TNetworkFolderScanHandle.Create;
  NetworkFolderScanHandle.SetRootPath( SourcePath );
  NetworkFolderScanHandle.SetPcInfo( DesPcID, TcpSocket );
  NetworkFolderScanHandle.SetSourceFolderPath( SourcePath );
  NetworkFolderScanHandle.SetFilterInfo( IncludeFilterList, ExcludeFilterList );
  NetworkFolderScanHandle.SetResultList( ScanResultList );
  NetworkFolderScanHandle.Update;
  TotalCount := NetworkFolderScanHandle.FileCount;
  TotalSize := NetworkFolderScanHandle.FileSize;
  TotalCompleted := NetworkFolderScanHandle.CompletedSize;
  NetworkFolderScanHandle.Free;

  ExcludeFilterList.Free;
  IncludeFilterList.Free;

  TcpSocket.Sendln( FileReq_End );
end;

procedure TNetworkBackupHandle.ScanPathHandle;
var
  IsFile : Boolean;
begin
  IsFile := FileExists( SourcePath );

    // 发送本机 PcID
  TcpSocket.Sendln( PcInfo.PcID );
  TcpSocket.Sendln( BoolToStr( IsFile ) );

    // 扫描目录
  if IsFile then
    ScanFileHandle
  else
    ScanFolderHandle;
end;

procedure TNetworkBackupHandle.Update;
begin
    // 源路径不存在, 不扫描
  if not getSourcePathIsExist then
    Exit;

    // 目标Pc离线，不扫描
  if not getDesPcIsBackup then
    Exit;

    // 扫描路径
  ScanPathHandle;
  ResetSourcePathSpace; // 重设路径空间信息

    // 备份路径
  if not getIsFreeLimit then  // 是否受到试用版限制
  begin
    ResetStartBackupFile;
    BackupFileHandle;
  end;

    // 设置 上次同步时间
  ResetBackupCompleted;
end;

{ TNetworkFileScanHandle }

function TNetworkFileScanHandle.FindDesFileInfo: Boolean;
begin
  TcpSocket.Sendln( SourceFilePath );
  Result := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False );
  if not Result then // 目标文件不存在
    Exit;
  DesFileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), 0 );
  DesFileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), Now );
end;

procedure TNetworkFileScanHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TNetworkFileCopyHandle }

function TNetworkFileCopyHandle.CheckNextCopy: Boolean;
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
      // 刷新界面
    RefreshCompletedSpace;

      // 检测 是否备份中断
//    Result := Result and NetworkBackupInfoReadUtil.( DesRootPath, SourceRootPath );
    StartTime := Now;
  end;

    // 可能已经 Disable
  Result := Result and MyBackupHandler.IsRun;
end;

constructor TNetworkFileCopyHandle.Create(_SourFilePath: string);
begin
  SourFilePath := _SourFilePath;
end;

procedure TNetworkFileCopyHandle.FileSend;
var
  SourFileStream : TFileStream;
  Buf : array[0..524287] of Byte;
  FullBufSize, BufSize, ReadSize : Integer;
  RemainSize : Int64;
  SourceFileTime : TDateTime;
begin
    // 文件流
  SourFileStream := TFileStream.Create( SourFilePath, fmOpenRead or fmShareDenyNone );

  FullBufSize := SizeOf( Buf );
  RemainSize := SourFileStream.Size;
  while RemainSize > 0 do
  begin
      // 取消复制 或 程序结束
    if not CheckNextCopy then
      Break;

       // 读取
    BufSize := Min( FullBufSize, RemainSize );
    ReadSize := SourFileStream.Read( Buf, BufSize );

      // 发送
    TcpSocket.SendBuf( Buf, ReadSize );

    RemainSize := RemainSize - ReadSize;
    AddCompletedSpace := AddCompletedSpace + ReadSize;
  end;

    // 添加已完成空间
  RefreshCompletedSpace;

  SourFileStream.Free;
end;

procedure TNetworkFileCopyHandle.RefreshCompletedSpace;
begin
    // 刷新速度
  if RefreshSpeedInfo.AddCompleted( AddCompletedSpace ) then
  begin
        // 设置 刷新备份速度
    BackupItemAppApi.SetSpeed( PcID, SourceRootPath, RefreshSpeedInfo.Speed );
    RefreshSpeedInfo.ResetSpeed;
  end;


  BackupItemAppApi.AddBackupCompletedSpace( PcID, SourceRootPath, AddCompletedSpace );
  AddCompletedSpace := 0;
end;

procedure TNetworkFileCopyHandle.SetDesPcInfo(_PcID: string;
  _TcpSocket: TCustomIpClient);
begin
  PcID := _PcID;
  TcpSocket := _TcpSocket;
end;

procedure TNetworkFileCopyHandle.SetRefreshSpeedInfo(
  _RefreshSppedInfo: TRefreshSpeedInfo);
begin
  RefreshSpeedInfo := _RefreshSppedInfo;
end;

procedure TNetworkFileCopyHandle.SetRootPath(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TNetworkFileCopyHandle.Update;
var
  SourceFileSize : Int64;
  SourceFileTime : TDateTime;
  IsEnoughSpace : Boolean;
begin
    // 源文件不存在
  if not FileExists( SourFilePath ) then
    Exit;

    // 发送 空间
  SourceFileSize := MyFileInfo.getFileSize( SourFilePath );
  MySocketUtil.SendString( TcpSocket, IntToStr( SourceFileSize ) );

    // 是否有足够的空间
  IsEnoughSpace := StrToBool( MySocketUtil.RevString( TcpSocket ) );
  if not IsEnoughSpace then
    Exit;

    // 文件发送
  FileSend;

    // 设置修改时间
  SourceFileTime := MyFileInfo.getFileLastWriteTime( SourFilePath );
  TcpSocket.Sendln( FloatToStr( SourceFileTime ) );
end;
{ TRefreshSpeedInfo }

function TRefreshSpeedInfo.AddCompleted(CompletedSpace: Int64): Boolean;
begin
  Speed := Speed + CompletedSpace;
  Result := SecondsBetween( Now, SpeedTime ) >= 1;
end;

constructor TRefreshSpeedInfo.Create;
begin
  ResetSpeed;
end;

procedure TRefreshSpeedInfo.ResetSpeed;
begin
  SpeedTime := Now;
  Speed := 0;
end;

end.

