unit UBackupInfoControl;

interface

uses Classes, Generics.Collections, SyncObjs, Windows, UModelUtil, SysUtils, UMyUtil,
     VirtualTrees, Math, uDebug, UFileBaseInfo;

type

{$Region ' 备份路径 Control ' }

    // 修改 备份路径 父类
  TBackupPathChangeHandle = class
  protected
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 读取 备份路径
  TBackupPathReadHandle = class( TBackupPathChangeHandle )
  protected
    PathType : string;
    IsDisable, IsBackupNow : Boolean;
    CopyCount : Integer;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    FileCount : Integer;
    FolderSpace, CompletedSpace : Int64;
  public
    procedure SetPathInfo( _PathType : string );
    procedure SetBackupInfo( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FolderSpace, _CompletedSpace : Int64 );
    procedure Update;virtual;
  protected
    procedure AddToInfo;   // 写 数据
    procedure AddToFace;  // 写 界面
  end;

    // 添加 备份路径
  TBackupPathAddHandle = class( TBackupPathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;   // 写xml操作
  end;

    // 修改 备份路径 Copy 数
  TBackupPathSetCopyCount = class( TBackupPathChangeHandle )
  private
    CopyCount : Integer;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
    procedure SetToFace;
  private
    procedure SyncFileNow;
  end;

    // 设置 备份路径 总空间信息
  TBackupPathSetSpaceHandle = class( TBackupPathChangeHandle )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

      // 刷新 选择的备份节点信息
  TBackupSelectRefreshHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure RefreshFace;
  end;

  {$Region ' 设置状态 ' }

    // 设置 备份路径是否存在
  TBackupPathSetExistHandle = class( TBackupPathChangeHandle )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 备份路径 是否禁止备份
  TBackupPathSetIsDisableHandle = class( TBackupPathChangeHandle )
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
  TBackupPathSetIsBackupNowHandle = class( TBackupPathChangeHandle )
  private
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

    // 设置 备份路径状态
  TBackupPathSetStatusHandle = class( TBackupPathChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 备份路径是否有足够的空间
  TBackupPathSetIsNotEnoughPcHandle = class( TBackupPathChangeHandle )
  public
    IsNotEnoughPc : Boolean;
  public
    procedure SetIsNotEnoughPc( _IsNotEnoughPc : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure RefreshNotEnough;
  end;

  {$EndRegion}

  {$Region ' 设置同步时间 ' }

    // 上一次 同步时间
  TBackupPathSetLastSyncTimeHandle = class( TBackupPathChangeHandle )
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
  TBackupPathSetAutoSyncHandle = class( TBackupPathChangeHandle )
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
  TBackupPathRefreshLastSyncTimeHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' 扫描与同步 ' }

    // 扫描 指定路径
  TBackupPathScanHandle = class( TBackupPathChangeHandle )
  public
    IsShowFreeLimt : Boolean;
  public
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 扫描 所有路径
  TBackupPathScanAllHandle = class
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 同步 指定路径
  TBackupPathSyncHandle = class( TBackupPathChangeHandle )
  public
    IsShowFreeLimt : Boolean;
  public
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 同步 所有路径
  TBackupPathSyncAllHandle = class
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

  {$EndRegion}

  {$Region ' 修改 已完成空间 信息 ' }

    // 修改
  TBackupPathChangeCompletedSpaceHandle = class( TBackupPathChangeHandle )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // 添加
  TBackupPathAddCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToXml;
  end;

    // 删除
  TBackupPathRemoveCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

    // 设置
  TBackupPathSetCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

      // 移除 备份路径
  TBackupPathRemoveHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveBackupNotify;
    procedure RemoveBackupOffline;
  private  // 删除 本地信息
    procedure RemoveBackupInfo;
    procedure RemoveBackupXml;
    procedure RemoveFromFace;
  end;

{$EndRegion}

{$Region ' 备份路径拥有者 Control ' }

    // 清空
  TBackupPathOwnerClearHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromXml;
  end;

    // 父类
  TBackupPathOwnerChangeHandle = class( TBackupPathChangeHandle )
  public
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
  end;

    // 修改 空间
  TBackupPathOwnerChangeSpaceHandle = class( TBackupPathOwnerChangeHandle )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // 添加 空间
  TBackupPathOwnerAddSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;

    // 删除 空间
  TBackupPathOwnerRemoveSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // 读取 空间
  TBackupPathOwnerReadSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // 设置
  TBackupPathOwnerSetSpaceHandle = class( TBackupPathOwnerReadSpaceHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 备份路径过滤器 Control ' }

    // 父类
  TBackupPathFilterChangeHandle = class( TBackupPathChangeHandle )
  end;

      // 添加 过滤器 父类
  TBackupPathFilterWriteHandle = class( TBackupPathFilterChangeHandle )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
  end;

  {$Region ' 修改 包含 过滤器 ' }

    // 清空
  TBackupPathIncludeFilterClearHandle = class( TBackupPathFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // 读取 包含 过滤器
  TBackupPathIncludeFilterReadHandle = class( TBackupPathFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加 包含 过滤器
  TBackupPathIncludeFilterAddHandle = class( TBackupPathIncludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

  {$Region ' 修改 排除 过滤器 ' }

      // 清空
  TBackupPathExcludeFilterClearHandle = class( TBackupPathFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // 读取 排除 过滤器
  TBackupPathExcludeFilterReadHandle = class( TBackupPathFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加 排除 过滤器
  TBackupPathExcludeFilterAddHandle = class( TBackupPathExcludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 备份目录 Control ' }

    // 父类
  TBackupFolderChangeHandle = class
  protected
    FolderPath : string;
  public
    constructor Create( _FolderPath : string );
  end;

    // 读取 目录
  TBackupFolderReadHandle = class( TBackupFolderChangeHandle )
  public
    FileSize, CompletedSpace : Int64;
    FileTime : TDateTime;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetFolderInfo( _FileTime : TDateTime; _FileCount : Integer );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 目录
  TBackupFolderAddHandle = class( TBackupFolderReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

     // 设置 备份目录 总空间
  TBackupFolderSetSpaceHandle = class( TBackupFolderChangeHandle )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

  {$Region ' 修改 已完成空间 信息 ' }

    // 设置 备份目录 已完成空间
  TBackupFolderChangeCompletedSpaceHanlde = class( TBackupFolderChangeHandle )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // 设置 备份目录 已完成空间
  TBackupFolderSetCompletedSpaceHanlde = class( TBackupFolderChangeCompletedSpaceHanlde )
  private
    LastCompletedSpace : Int64;
  public
    procedure SetLastCompletedSpace( _LastCompletedSpace : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 添加 备份目录 已完成空间
  TBackupFolderAddCompletedSpaceHandle = class( TBackupFolderSetCompletedSpaceHanlde )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;

    // 删除 备份目录 已完成空间
  TBackupFolderRemoveCompletedSpaceHandle = class( TBackupFolderSetCompletedSpaceHanlde )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromToXml;
  end;

  {$EndRegion}

    // 设置 目录 状态
  TBackupFolderSetStatusHandle = class( TBackupFolderChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 删除 目录
  TBackupFolderRemoveHandle = class( TBackupFolderChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromNotify;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
    procedure RemoveFromFace;
  end;


{$EndRegion}

{$Region ' 备份文件 Control ' }

    // 父类
  TBackupFileChangeHandle = class
  protected
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;

    // 读取 备份文件
  TBackupFileReadHandle = class( TBackupFileChangeHandle )
  protected
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // 添加 备份文件
  TBackupFileAddHandle = class( TBackupFileReadHandle )
  public
    procedure Update;override;
  private
    procedure AddBackupXml;
  end;

    // 同步 备份文件
  TBackupFileSyncHandle = class( TBackupFileChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

      // 删除 备份文件
  TBackupFileRemoveHandle = class( TBackupFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromNotify;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 备份文件副本 Control ' }

    // 修改 备份副本信息
  TBackupCopyChangeHandle = class( TBackupFileChangeHandle )
  public
    CopyOwner : string;
  public
    procedure SetCopyOwner( _CopyOwner : string );
  protected
    procedure RefreshFace;
  end;

    // 添加 Pending 副本
  TBackupCopyAddPendHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 添加 Loading 副本
  TBackupCopyAddLoadingHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 读取 Offline 副本
  TBackupCopyReadOfflineHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加 Offline 副本
  TBackupCopyAddOfflineHandle = class( TBackupCopyReadOfflineHandle )
  private
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取 Loaded 副本
  TBackupCopyReadLoadedHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // 添加 Loaded 副本
  TBackupCopyAddLoadedHandle = class( TBackupCopyReadLoadedHandle )
  public
    procedure Update;override;
  protected
    procedure AddToXml;
  end;

    // 删除 备份副本信息
  TBackupCopyRemoveHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' Total Control ' }

  TBackupCopyChangeControl = class
  public
    FilePath, PcID : string;
    FileSize : Int64;
  private
    RootBackupPath : string;
  public
    constructor Create( _FilePath, _PcID : string );
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;virtual;
  end;

    // 添加 备份 Copy
  TBackupCopyAddControl = class( TBackupCopyChangeControl )
  public
    procedure Update;override;
  private
    procedure AddBackupCopy; // 添加文件 Copy
    procedure AddBackupPathCopy; // 添加路径 Copy
  private
    procedure AddBackupFolderCompletedSpace;  // 备份目录 已完成空间
    procedure AddBackupPathCompletedSpace;  // 备份路径 已完成空间
  end;

    // 删除 备份 Copy
  TBackupCopyRemoveControl = class( TBackupCopyChangeControl )
  public
    procedure Update;override;
  private       // 移除副本信息
    procedure RemoveBackupCopy;
    procedure RemoveBackupPathCopy;
  private
    procedure RemoveBackupFolderCompletedSpace;  // 备份文件 已完成空间
    procedure RemoveBackupPathCompletedSpace;  // 备份路径 已完成空间
  private       // 立刻同步该文件
    procedure SyncFileNow;
  end;

    // 取消备份某目录
  TBackupFolderCancelBackupControl = class
  public
    FolderPath : string;
  public
    constructor Create( _FolderPath : string );
    procedure Update;
  private
    procedure AddToExcludeFilter;
    procedure RemoveFolder;
  end;

    // 取消备份某文件
  TBackupFileCancelBackupControl = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
    procedure Update;
  private
    procedure AddToExcludeFilter;
    procedure RemoveFile;
  end;

{$EndRegion}

{$Region ' Control Util ' }

    // 添加 备份路径
  TBackupPathAddControl = class
  public
    FullPath, PathType : string;
    IsDisable, IsBackupNow : Boolean;
    CopyCount : Integer;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 添加 备份路径 默认配置
  TBackupPathAddDefaultControl = class( TBackupPathAddControl )
  public
    procedure Update;
  private
    procedure FindGenernalInfo;
    procedure FindEncryptInfo;
  private
    procedure AddBackupPath;
    procedure AddBackupFilter;
    procedure BackupPathNow;
  end;

    // 添加 备份路径 指定配置
  TBackupPathAddConfigControl = class( TBackupPathAddControl )
  private
    BackupConfigInfo : TBackupConfigInfo;
    IncludeFileFilterList : TFileFilterList;
    ExcludeFileFilterList : TFileFilterList;
  public
    procedure SetBackupConfigInfo( _BackupConfigInfo : TBackupConfigInfo );
    procedure Update;
  private
    procedure FindGenernalInfo;
    procedure FindEncryptInfo;
    procedure FindFilterInfo;
  private
    procedure AddBackupPath;
    procedure AddBackupFilter;
    procedure BackupPathNow;
  private
    function IsPathFilter( FilterInfo : TFileFilterInfo ): Boolean;
  end;

{$EndRegion}

    // 备份路径变化控制器
  TMyBackupFileControl = class
  public        // 备份路径 操作
    procedure AddBackupPath( FullPath : string );overload;
    procedure AddBackupPath( FullPath : string; BackupConfigInfo : TBackupConfigInfo );overload;
    procedure RemoveBackupPath( FullPath : string );
  public        // 备份文件/目录 操作
    procedure ShowBackupFileStatus( FullPath : string );
    procedure ShowBackupFileStatusNomal( FullPath : string );
    procedure ShowBackupFileDetail( FullPath : string );
    procedure FolderCancelBackup( FolderPath : string );
    procedure FileCancelBackup( FilePath : string );
  public        // 扫描备份路径
    procedure BackupNow;
    procedure BackupSelectFolder( FolderPath : string );
  public        // 同步备份路径
    procedure PcOnlineSync;
  end;

const
    // 确认文件
  BackupFileScanType_FileConfirm = 'FileConfirm';

var
  MyBackupFileControl : TMyBackupFileControl;

implementation

uses UMainForm, UMyBackupInfo, UBackupFileScan,UBackupInfoFace, UBackupInfoXml, UBackupUtil,
     USettingInfo, UMyNetPcInfo, UNetPcInfoXml, UNetworkFace, UMyJobInfo;

{ TBackupPathControl }


procedure TMyBackupFileControl.AddBackupPath(FullPath: string);
var
  BackupPathAddDefaultControl : TBackupPathAddDefaultControl;
begin
  BackupPathAddDefaultControl := TBackupPathAddDefaultControl.Create( FullPath );
  BackupPathAddDefaultControl.Update;
  BackupPathAddDefaultControl.Free;
end;


procedure TMyBackupFileControl.AddBackupPath(FullPath: string;
  BackupConfigInfo: TBackupConfigInfo);
var
  BackupPathAddConfigControl : TBackupPathAddConfigControl;
begin
  BackupPathAddConfigControl := TBackupPathAddConfigControl.Create( FullPath );
  BackupPathAddConfigControl.SetBackupConfigInfo( BackupConfigInfo );
  BackupPathAddConfigControl.Update;
  BackupPathAddConfigControl.Free;
end;

procedure TMyBackupFileControl.BackupNow;
var
  BackupPathScanAllHandle : TBackupPathScanAllHandle;
begin
  BackupPathScanAllHandle := TBackupPathScanAllHandle.Create;
  BackupPathScanAllHandle.Update;
  BackupPathScanAllHandle.Free;
end;

procedure TMyBackupFileControl.BackupSelectFolder(FolderPath: string);
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
  BackupPathScanHandle := TBackupPathScanHandle.Create( FolderPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TMyBackupFileControl.PcOnlineSync;
var
  BackupPathSyncAllHandle : TBackupPathSyncAllHandle;
begin
  BackupPathSyncAllHandle := TBackupPathSyncAllHandle.Create;
  BackupPathSyncAllHandle.Update;
  BackupPathSyncAllHandle.Free;
end;

procedure TMyBackupFileControl.FileCancelBackup(FilePath: string);
var
  BackupFileCancelBackupControl : TBackupFileCancelBackupControl;
begin
  BackupFileCancelBackupControl := TBackupFileCancelBackupControl.Create( FilePath );
  BackupFileCancelBackupControl.Update;
  BackupFileCancelBackupControl.Free;
end;

procedure TMyBackupFileControl.FolderCancelBackup(FolderPath: string);
var
  BackupFolderCancelBackupControl : TBackupFolderCancelBackupControl;
begin
  BackupFolderCancelBackupControl := TBackupFolderCancelBackupControl.Create( FolderPath );
  BackupFolderCancelBackupControl.Update;
  BackupFolderCancelBackupControl.Free;
end;

procedure TMyBackupFileControl.RemoveBackupPath(FullPath: string);
var
  BackupPathRemove : TBackupPathRemoveHandle;
begin
  BackupPathRemove := TBackupPathRemoveHandle.Create( FullPath );
  BackupPathRemove.Update;
  BackupPathRemove.Free;
end;

procedure TMyBackupFileControl.ShowBackupFileDetail(FullPath: string);
var
  BackupFileReadDetailInfo : TBackupFileReadDetailInfo;
begin
  BackupFileReadDetailInfo := TBackupFileReadDetailInfo.Create( FullPath );
  MyBackupFileInfo.InsertChange( BackupFileReadDetailInfo );
end;

procedure TMyBackupFileControl.ShowBackupFileStatus(FullPath: string);
var
  BackupFileReadLvInfo : TBackupFolderReadLvInfo;
begin
  BackupFileReadLvInfo := TBackupFolderReadLvInfo.Create( FullPath );
  MyBackupFileInfo.InsertChange( BackupFileReadLvInfo );
end;

procedure TMyBackupFileControl.ShowBackupFileStatusNomal(FullPath: string);
var
  BackupFileReadLvInfo : TBackupFolderReadLvInfo;
begin
  BackupFileReadLvInfo := TBackupFolderReadLvInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupFileReadLvInfo );
end;

{ TBackupPathAdd }

procedure TBackupPathAddHandle.AddToXml;
var
  BackupPathAddXml : TBackupPathAddXml;
begin
  BackupPathAddXml := TBackupPathAddXml.Create( FullPath );
  BackupPathAddXml.SetPathType( PathType );
  BackupPathAddXml.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddXml.SetAcutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddXml.SetSyncIntervalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddXml.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddXml.SetCountInfo( CopyCount, FileCount );
  BackupPathAddXml.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathAddXml );
end;

procedure TBackupPathAddHandle.Update;
begin
  inherited;

    // 添加 Xml
  AddToXml;
end;

{ TBackupPathRemove }

procedure TBackupPathRemoveHandle.RemoveBackupInfo;
var
  BackupPathRemoveInfo : TBackupPathRemoveInfo;
begin
  BackupPathRemoveInfo := TBackupPathRemoveInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathRemoveInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupNotify;
var
  BackupPathRemoveNotifyInfo : TBackupPathRemoveNotifyInfo;
begin
  BackupPathRemoveNotifyInfo := TBackupPathRemoveNotifyInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathRemoveNotifyInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupOffline;
var
  BackupPathRemoveOfflineJobInfo : TBackupPathRemoveOfflineJobInfo;
begin
  BackupPathRemoveOfflineJobInfo := TBackupPathRemoveOfflineJobInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRemoveOfflineJobInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupXml;
var
  BackupPathRemoteXml : TBackupPathRemoveXml;
begin
  BackupPathRemoteXml := TBackupPathRemoveXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathRemoteXml );
end;

procedure TBackupPathRemoveHandle.RemoveFromFace;
var
  BackupVtRemoveInfo : TBackupVtRemoveInfo;
  BackupTvRemoveRootInfo : TVstBackupPathRemove;
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
  LvBackupPathProRemove : TLvBackupPathProRemove;
begin
    // 删除 选择路径
  BackupVtRemoveInfo := TBackupVtRemoveInfo.Create( FullPath );
  MyBackupFileFace.AddChange( BackupVtRemoveInfo );

    // 删除 显示路径
  BackupTvRemoveRootInfo := TVstBackupPathRemove.Create( FullPath );
  MyBackupFileFace.InsertChange( BackupTvRemoveRootInfo );

    // 删除 属性窗口
  LvBackupPathProRemove := TLvBackupPathProRemove.Create( FullPath );
  MyBackupFileFace.AddChange( LvBackupPathProRemove );

    // 刷新 备份进度
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // 刷新 我的备份云信息
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;


procedure TBackupPathRemoveHandle.Update;
begin
    // 通知 备份目标
  RemoveBackupNotify;

    // 删除 信息
  RemoveBackupInfo;

    // 启动离线 Job
  RemoveBackupOffline;

    // 删除 界面
  RemoveFromFace;

    // 删除 Xml
  RemoveBackupXml;
end;

{ TBackupPathSetCopyCount }

procedure TBackupPathSetCopyCount.SyncFileNow;
var
  BackupFileSyncHandle : TBackupFileSyncHandle;
begin
  BackupFileSyncHandle := TBackupFileSyncHandle.Create( FullPath );
  BackupFileSyncHandle.Update;
  BackupFileSyncHandle.Free;
end;

procedure TBackupPathSetCopyCount.SetToInfo;
var
  BackupPathCopyCountInfo : TBackupPathCopyCountInfo;
begin
  BackupPathCopyCountInfo := TBackupPathCopyCountInfo.Create( FullPath );
  BackupPathCopyCountInfo.SetCopyCount( CopyCount );
  MyBackupFileInfo.AddChange( BackupPathCopyCountInfo );
end;

procedure TBackupPathSetCopyCount.SetToXml;
var
  BackupPathCopyCountXml : TBackupPathCopyCountXml;
begin
  BackupPathCopyCountXml := TBackupPathCopyCountXml.Create( FullPath );
  BackupPathCopyCountXml.SetCopyCount( CopyCount );
  MyBackupXmlWrite.AddChange( BackupPathCopyCountXml );
end;

procedure TBackupPathSetCopyCount.SetToFace;
var
  BackupTvCopyCountInfo : TVstBackupPathSetCopyCount;
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // 刷新 VstBackupItem
  BackupTvCopyCountInfo := TVstBackupPathSetCopyCount.Create( FullPath );
  BackupTvCopyCountInfo.SetCopyCount( CopyCount );
  MyBackupFileFace.AddChange( BackupTvCopyCountInfo );

    // 刷新 备份进度
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // 刷新 我的备份云信息
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathSetCopyCount.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupPathSetCopyCount.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;

  SyncFileNow;
end;

{ TBackupCopyAddHandle }

procedure TBackupCopyReadLoadedHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus(  CopyStatus_Loaded  );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyReadLoadedHandle.Update;
begin
    // 添加到内存
  AddToInfo;

    // 刷新 界面
  RefreshFace;
end;

{ TBackupCopyRemoveHandle }

procedure TBackupCopyRemoveHandle.RemoveFromInfo;
var
  BackupFileCopyRemoveInfo : TBackupFileCopyRemoveInfo;
begin
    // 删除 备份文件副本 内存
  BackupFileCopyRemoveInfo := TBackupFileCopyRemoveInfo.Create( FilePath );
  BackupFileCopyRemoveInfo.SetCopyOwner( CopyOwner );
  MyBackupFileInfo.AddChange( BackupFileCopyRemoveInfo );
end;

procedure TBackupCopyRemoveHandle.RemoveFromXml;
var
  BackupFileCopyRemoveXml : TBackupFileCopyRemoveXml;
begin
  BackupFileCopyRemoveXml := TBackupFileCopyRemoveXml.Create( FilePath );
  BackupFileCopyRemoveXml.SetCopyOwner( CopyOwner );
  MyBackupXmlWrite.AddChange( BackupFileCopyRemoveXml );
end;

procedure TBackupCopyRemoveHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromXml;

    // 刷新 界面
  RefreshFace;
end;

{ TBackupPathBaseAddHandle }

procedure TBackupPathReadHandle.AddToInfo;
var
  BackupPathAddInfo : TBackupPathAddInfo;
begin
    // 添加路径
  BackupPathAddInfo := TBackupPathAddInfo.Create( FullPath );
  BackupPathAddInfo.SetPathType( PathType );
  BackupPathAddInfo.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddInfo.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddInfo.SetCountInfo( CopyCount, FileCount );
  BackupPathAddInfo.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathAddInfo );
end;

procedure TBackupPathReadHandle.AddToFace;
var
  BackupVtAddInfo : TBackupVtAddInfo;
  VstBackupItemAddRoot : TVstBackupPathAdd;
  LvBackupPathProAdd : TLvBackupPathProAdd;
begin
    // 选择 备份路径窗口
  BackupVtAddInfo := TBackupVtAddInfo.Create( FullPath );
  MyBackupFileFace.AddChange( BackupVtAddInfo );

    // 添加 BackupItem 窗口
  VstBackupItemAddRoot := TVstBackupPathAdd.Create( FullPath );
  VstBackupItemAddRoot.SetPathType( PathType );
  VstBackupItemAddRoot.SetBackupInfo( IsDisable );
  VstBackupItemAddRoot.SetSyncTimeInfo( IsAutoSync, SyncTimeType, SyncTimeValue, LastSyncTime );
  VstBackupItemAddRoot.SetIsEncrypt( IsEncrypt );
  VstBackupItemAddRoot.SetCountInfo( CopyCount, FileCount );
  VstBackupItemAddRoot.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupItemAddRoot );

    // 属性窗口
  LvBackupPathProAdd := TLvBackupPathProAdd.Create( FullPath );
  MyBackupFileFace.AddChange( LvBackupPathProAdd );
end;

procedure TBackupPathReadHandle.SetBackupInfo(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathReadHandle.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TBackupPathReadHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupPathReadHandle.SetPathInfo(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TBackupPathReadHandle.SetSpaceInfo(_FolderSpace, _CompletedSpace: Int64);
begin
  FolderSpace := _FolderSpace;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupPathReadHandle.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathReadHandle.SetAutoSyncInfo(_IsAutoSync : Boolean;
  _LastSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathReadHandle.Update;
begin
    // 内存
  AddToInfo;

    // 显示路径 界面
  AddToFace;
end;

{ TBackupFileAddHandle }

procedure TBackupFileAddHandle.AddBackupXml;
var
  BackupFileAddXml : TBackupFileAddXml;
begin
  BackupFileAddXml := TBackupFileAddXml.Create( FilePath );
  BackupFileAddXml.SetFileInfo( FileSize, FileTime );
  MyBackupXmlWrite.AddChange( BackupFileAddXml );
end;

procedure TBackupFileAddHandle.Update;
begin
    // 文件正在使用
  if MyFileInfo.getFileIsInUse( FilePath ) then
    Exit;

  inherited;

    // 添加到 磁盘
  AddBackupXml;
end;

{ TBackupFileRemoveHandle }

procedure TBackupFileRemoveHandle.RemoveFromInfo;
var
  BackupFileRemoveInfo : TBackupFileRemoveInfo;
begin
  BackupFileRemoveInfo := TBackupFileRemoveInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupFileRemoveInfo );
end;

procedure TBackupFileRemoveHandle.RemoveFromNotify;
var
  BackupFileRemoveNotifyInfo : TBackupFileRemoveNotifyInfo;
begin
  BackupFileRemoveNotifyInfo := TBackupFileRemoveNotifyInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupFileRemoveNotifyInfo );
end;

procedure TBackupFileRemoveHandle.RemoveFromXml;
var
  BackupFileRemoveXml : TBackupFileRemoveXml;
begin
  BackupFileRemoveXml := TBackupFileRemoveXml.Create( FilePath );
  MyBackupXmlWrite.AddChange( BackupFileRemoveXml );
end;

procedure TBackupFileRemoveHandle.Update;
begin
    // 通知 备份文件目标
  RemoveFromNotify;

    // 删除 内存
  RemoveFromInfo;

    // 删除 磁盘
  RemoveFromXml;
end;

{ TBackupFileBaseAddHanlde }

procedure TBackupFileReadHandle.AddToInfo;
var
  BackupFileAddInfo : TBackupFileAddInfo;
begin
  BackupFileAddInfo := TBackupFileAddInfo.Create( FilePath );
  BackupFileAddInfo.SetFileInfo( FileSize, FileTime );
  MyBackupFileInfo.AddChange( BackupFileAddInfo );
end;

procedure TBackupFileReadHandle.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupFileReadHandle.Update;
begin
    // 添加到 内存
  AddToInfo;
end;

{ TBackupCopyChangeHandle }

procedure TBackupCopyChangeHandle.RefreshFace;
var
  BackupCopyLvFaceReadInfo : TBackupFileRefreshLvFaceInfo;
begin
    // 刷新 ListView 界面
  if not LvBackupFileUtil.IsFileShow( FilePath ) then
    Exit;

    // 刷新 状态
  BackupCopyLvFaceReadInfo := TBackupFileRefreshLvFaceInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupCopyLvFaceReadInfo );
end;

procedure TBackupCopyChangeHandle.SetCopyOwner(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

{ TBackupPathChangeHandle }

constructor TBackupPathChangeHandle.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupCopyAddLoadedHandle.AddToXml;
var
  BackupFileCopyAddXml : TBackupFileCopyAddXml;
begin
    // 添加 备份文件副本 磁盘
  BackupFileCopyAddXml := TBackupFileCopyAddXml.Create( FilePath );
  BackupFileCopyAddXml.SetCopyOwner( CopyOwner );
  BackupFileCopyAddXml.SetCopyStatus( CopyStatus_Loaded );
  MyBackupXmlWrite.AddChange( BackupFileCopyAddXml );
end;

procedure TBackupCopyAddLoadedHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathResetExistHandle }

procedure TBackupPathSetExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TBackupPathSetExistHandle.SetToFace;
var
  VstBackupItemIsExist : TVstBackupPathIsExist;
begin
  VstBackupItemIsExist := TVstBackupPathIsExist.Create( FullPath );
  VstBackupItemIsExist.SetIsExist( IsExist );
  MyBackupFileFace.AddChange( VstBackupItemIsExist );
end;

procedure TBackupPathSetExistHandle.Update;
begin
  SetToFace;
end;

{ TBackupFileChangeHandle }

constructor TBackupFileChangeHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupFolderSetCompletedSpaceHanlde }

procedure TBackupFolderSetCompletedSpaceHanlde.SetLastCompletedSpace(
  _LastCompletedSpace: Int64);
begin
  LastCompletedSpace := _LastCompletedSpace;
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToFace;
var
  VstBackupFolderSetCompletedSpace : TVstBackupFolderSetCompletedSpace;
begin
  VstBackupFolderSetCompletedSpace := TVstBackupFolderSetCompletedSpace.Create( FolderPath );
  VstBackupFolderSetCompletedSpace.SetLastCompletedSpace( LastCompletedSpace );
  VstBackupFolderSetCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderSetCompletedSpace );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToInfo;
var
  BackupFolderSetCompletedSpaceInfo : TBackupFolderSetCompletedSpaceInfo;
begin
  BackupFolderSetCompletedSpaceInfo := TBackupFolderSetCompletedSpaceInfo.Create( FolderPath );
  BackupFolderSetCompletedSpaceInfo.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderSetCompletedSpaceInfo );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToXml;
var
  BackupFolderSetCompletedSpaceXml : TBackupFolderSetCompletedSpaceXml;
begin
  BackupFolderSetCompletedSpaceXml := TBackupFolderSetCompletedSpaceXml.Create( FolderPath );
  BackupFolderSetCompletedSpaceXml.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderSetCompletedSpaceXml );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupCopyAddPendHandle }

procedure TBackupCopyAddPendHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Pending );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyAddPendHandle.Update;
begin
  AddToInfo;

    // 刷新 界面
  RefreshFace;
end;

{ TBackupCopyAddLoadingHandle }

procedure TBackupCopyAddLoadingHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Loading );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyAddLoadingHandle.Update;
begin
  AddToInfo;

    // 刷新 界面
  RefreshFace;
end;

{ TBackupCopyReadOfflineHandle }

procedure TBackupCopyReadOfflineHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Offline );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyReadOfflineHandle.Update;
begin
  AddToInfo;

    // 刷新 界面
  RefreshFace;
end;

{ TBackupCopyAddOfflineHandle }

procedure TBackupCopyAddOfflineHandle.AddToXml;
var
  BackupFileCopyAddOfflineXml : TBackupFileCopyAddOfflineXml;
begin
    // 添加 备份文件副本 磁盘
  BackupFileCopyAddOfflineXml := TBackupFileCopyAddOfflineXml.Create( FilePath );
  BackupFileCopyAddOfflineXml.SetCopyOwner( CopyOwner );
  BackupFileCopyAddOfflineXml.SetCopyStatus( CopyStatus_Offline );
  BackupFileCopyAddOfflineXml.SetPosition( Position );
  MyBackupXmlWrite.AddChange( BackupFileCopyAddOfflineXml );
end;

procedure TBackupCopyAddOfflineHandle.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TBackupCopyAddOfflineHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupFileRefreshJobHandle }

procedure TBackupFileSyncHandle.AddToInfo;
var
  BackupPathFreeScanJobInfo : TBackupPathSyncInfo;
begin
  BackupPathFreeScanJobInfo := TBackupPathSyncInfo.Create( FilePath );
  BackupPathFreeScanJobInfo.SetIsShowFreeLimt( False );
  MyBackupFileInfo.AddChange( BackupPathFreeScanJobInfo );
end;

procedure TBackupFileSyncHandle.Update;
begin
  AddToInfo;
end;

{ TBackupFolderAddCompletedSpaceHandle }

procedure TBackupFolderAddCompletedSpaceHandle.AddToFace;
var
  VstBackupItemAddCompletedSpace : TVstBackupFolderAddCompletedSpace;
begin
    // 添加 已完成空间信息
  VstBackupItemAddCompletedSpace := TVstBackupFolderAddCompletedSpace.Create( FolderPath );
  VstBackupItemAddCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupItemAddCompletedSpace );
end;

procedure TBackupFolderAddCompletedSpaceHandle.AddToInfo;
var
  BackupFolderAddCompletedSpaceInfo : TBackupFolderAddCompletedSpaceInfo;
begin
    // 添加 备份目录 已完成空间
  BackupFolderAddCompletedSpaceInfo := TBackupFolderAddCompletedSpaceInfo.Create( FolderPath );
  BackupFolderAddCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderAddCompletedSpaceInfo );
end;

procedure TBackupFolderAddCompletedSpaceHandle.AddToXml;
var
  BackupFolderAddCompletedSpaceXml : TBackupFolderAddCompletedSpaceXml;
begin
  BackupFolderAddCompletedSpaceXml := TBackupFolderAddCompletedSpaceXml.Create( FolderPath );
  BackupFolderAddCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderAddCompletedSpaceXml );
end;

procedure TBackupFolderAddCompletedSpaceHandle.Update;
begin
  AddToInfo;

  AddToFace;

  AddToXml;
end;

{ TBackupPathOwnerSpaceChangeHandle }

procedure TBackupPathOwnerChangeHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TBackupPathOwnerSetSpaceHandle }

procedure TBackupPathOwnerSetSpaceHandle.SetToXml;
var
  BackupPathOwnerSetXml : TBackupPathOwnerSetSpaceXml;
begin
  BackupPathOwnerSetXml := TBackupPathOwnerSetSpaceXml.Create( FullPath );
  BackupPathOwnerSetXml.SetPcID( PcID );
  BackupPathOwnerSetXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerSetXml );
end;

procedure TBackupPathOwnerSetSpaceHandle.Update;
begin
  inherited;

  SetToXml;
end;

{ TBackupPathOwnerAddSpaceHandle }

procedure TBackupPathOwnerAddSpaceHandle.AddToFace;
var
  VstCloudStatusAddHasMyBackupSpace : TVstCloudStatusHasMyBackupAdd;
  BackupPgAddCompletedInfo : TBackupPgAddCompletedInfo;
  MyBackupCloudLvAddSpace : TMyBackupCloudLvAddSpace;
begin
    // 添加 云Pc我的备份文件
  VstCloudStatusAddHasMyBackupSpace := TVstCloudStatusHasMyBackupAdd.Create( PcID );
  VstCloudStatusAddHasMyBackupSpace.SetSpaceInfo( FileSize, FileCount );
  MyNetworkFace.AddChange( VstCloudStatusAddHasMyBackupSpace );

    // 添加 备份进度条
  BackupPgAddCompletedInfo := TBackupPgAddCompletedInfo.Create( FileSize );
  MyBackupFileFace.AddChange( BackupPgAddCompletedInfo );

    // 添加 我的备份文件分布
  MyBackupCloudLvAddSpace := TMyBackupCloudLvAddSpace.Create( PcID );
  MyBackupCloudLvAddSpace.SetFileSpace( FileSize );
  MyBackupCloudLvAddSpace.SetFileCount( FileCount );
  MyNetworkFace.AddChange( MyBackupCloudLvAddSpace );
end;

procedure TBackupPathOwnerAddSpaceHandle.AddToInfo;
var
  BackupPathOwnerAddSpaceInfo : TBackupPathOwnerAddSpaceInfo;
begin
  BackupPathOwnerAddSpaceInfo := TBackupPathOwnerAddSpaceInfo.Create( FullPath );
  BackupPathOwnerAddSpaceInfo.SetPcID( PcID );
  BackupPathOwnerAddSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerAddSpaceInfo );
end;

procedure TBackupPathOwnerAddSpaceHandle.AddToXml;
var
  BackupPathOwnerAddSpaceXml : TBackupPathOwnerAddSpaceXml;
begin
  BackupPathOwnerAddSpaceXml := TBackupPathOwnerAddSpaceXml.Create( FullPath );
  BackupPathOwnerAddSpaceXml.SetPcID( PcID );
  BackupPathOwnerAddSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerAddSpaceXml );
end;

procedure TBackupPathOwnerAddSpaceHandle.Update;
begin
  AddToInfo;

  AddToFace;

  AddToXml;
end;

{ TBackupCopyAddControl }

procedure TBackupCopyAddControl.AddBackupCopy;
var
  BackupCopyAddLoadedHandle : TBackupCopyAddLoadedHandle;
begin
  BackupCopyAddLoadedHandle := TBackupCopyAddLoadedHandle.Create( FilePath );
  BackupCopyAddLoadedHandle.SetCopyOwner( PcID );
  BackupCopyAddLoadedHandle.Update;
  BackupCopyAddLoadedHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupFolderCompletedSpace;
var
  FolderPath : string;
  BackupFolderAddCompletedSpaceHandle : TBackupFolderAddCompletedSpaceHandle;
begin
  if FilePath = RootBackupPath then
    FolderPath := FilePath
  else
    FolderPath := ExtractFileDir( FilePath );

  BackupFolderAddCompletedSpaceHandle := TBackupFolderAddCompletedSpaceHandle.Create( FolderPath );
  BackupFolderAddCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupFolderAddCompletedSpaceHandle.Update;
  BackupFolderAddCompletedSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupPathCompletedSpace;
var
  BackupPathAddCompletedSpaceHandle : TBackupPathAddCompletedSpaceHandle;
begin
  BackupPathAddCompletedSpaceHandle := TBackupPathAddCompletedSpaceHandle.Create( RootBackupPath );
  BackupPathAddCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupPathAddCompletedSpaceHandle.Update;
  BackupPathAddCompletedSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupPathCopy;
var
  BackupPathOwnerAddSpaceHandle : TBackupPathOwnerAddSpaceHandle;
begin
  BackupPathOwnerAddSpaceHandle := TBackupPathOwnerAddSpaceHandle.Create( RootBackupPath );
  BackupPathOwnerAddSpaceHandle.SetPcID( PcID );
  BackupPathOwnerAddSpaceHandle.SetSpaceInfo( FileSize, 1 );
  BackupPathOwnerAddSpaceHandle.Update;
  BackupPathOwnerAddSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.Update;
begin
  inherited;

    // 根路径 不存咋
  if RootBackupPath = '' then
    Exit;

    // 添加 Copy 信息
  AddBackupCopy;
  AddBackupPathCopy;

    // 添加 空间信息
  AddBackupFolderCompletedSpace;
  AddBackupPathCompletedSpace;
end;

{ TBackupFolderSetSpaceHandle }

procedure TBackupFolderSetSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TBackupFolderSetSpaceHandle.SetToFace;
var
  VstBackupFolderSetSpace : TVstBackupFolderSetSpace;
begin
    // 写 界面
  VstBackupFolderSetSpace := TVstBackupFolderSetSpace.Create( FolderPath );
  VstBackupFolderSetSpace.SetSize( FileSize );
  VstBackupFolderSetSpace.SetFileCount( FileCount );
  MyBackupFileFace.AddChange( VstBackupFolderSetSpace );
end;

procedure TBackupFolderSetSpaceHandle.SetToInfo;
var
  BackupFolderSpaceInfo : TBackupFolderSetSpaceInfo;
begin
    // 写 内存
  BackupFolderSpaceInfo := TBackupFolderSetSpaceInfo.Create( FolderPath );
  BackupFolderSpaceInfo.SetFolderSpace( FileSize );
  BackupFolderSpaceInfo.SetFileCount( FileCount );
  MyBackupFileInfo.AddChange( BackupFolderSpaceInfo );
end;

procedure TBackupFolderSetSpaceHandle.SetToXml;
var
  BackupFolderSetSpaceXml : TBackupFolderSetSpaceXml;
begin
  BackupFolderSetSpaceXml := TBackupFolderSetSpaceXml.Create( FolderPath );
  BackupFolderSetSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupFolderSetSpaceXml );
end;

procedure TBackupFolderSetSpaceHandle.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupPathSetSpaceHandle }

procedure TBackupPathSetSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TBackupPathSetSpaceHandle.SetToFace;
var
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // 刷新 备份进度
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // 刷新 我的备份云信息
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathSetSpaceHandle.SetToInfo;
var
  BackupPathSetSpaceInfo : TBackupPathSetSpaceInfo;
begin
    // 写 内存
  BackupPathSetSpaceInfo := TBackupPathSetSpaceInfo.Create( FullPath );
  BackupPathSetSpaceInfo.SetFolderSpace( FileSize );
  BackupPathSetSpaceInfo.SetFileCount( FileCount );
  MyBackupFileInfo.AddChange( BackupPathSetSpaceInfo );
end;

procedure TBackupPathSetSpaceHandle.SetToXml;
var
  BackupPathSetSpaceXml : TBackupPathSetSpaceXml;
begin
    // 写 Xml
  BackupPathSetSpaceXml := TBackupPathSetSpaceXml.Create( FullPath );
  BackupPathSetSpaceXml.SetFolderSpace( FileSize );
  BackupPathSetSpaceXml.SetFileCount( FileCount );
  MyBackupXmlWrite.AddChange( BackupPathSetSpaceXml );
end;

procedure TBackupPathSetSpaceHandle.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupFolderChangeHandle }

constructor TBackupFolderChangeHandle.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

{ TBackupFolderReadHandle }

procedure TBackupFolderReadHandle.AddToFace;
var
  VstBackupFolderAdd : TVstBackupFolderAdd;
  BackupLvAddInfo : TBackupLvAddInfo;
begin
    // Backup Item
  VstBackupFolderAdd := TVstBackupFolderAdd.Create( FolderPath );
  VstBackupFolderAdd.SetCountInfo( FileCount );
  VstBackupFolderAdd.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderAdd );
end;

procedure TBackupFolderReadHandle.AddToInfo;
var
  BackupFolderAddInfo : TBackupFolderAddInfo;
begin
  BackupFolderAddInfo := TBackupFolderAddInfo.Create( FolderPath );
  BackupFolderAddInfo.SetFolderInfo( FileTime, FileCount );
  BackupFolderAddInfo.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderAddInfo );
end;

procedure TBackupFolderReadHandle.SetFolderInfo(_FileTime: TDateTime;
  _FileCount: Integer);
begin
  FileTime := _FileTime;
  FileCount := _FileCount;
end;

procedure TBackupFolderReadHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupFolderReadHandle.Update;
begin
  AddToInfo;

  AddToFace;
end;

{ TBackupFolderAddHandle }

procedure TBackupFolderAddHandle.AddToXml;
var
  BackupFolderAddXml : TBackupFolderAddXml;
begin
  BackupFolderAddXml := TBackupFolderAddXml.Create( FolderPath );
  BackupFolderAddXml.SetFolderInfo( FileTime, FileCount );
  BackupFolderAddXml.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderAddXml );
end;

procedure TBackupFolderAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupFolderRemoveHandle }

procedure TBackupFolderRemoveHandle.RemoveFromFace;
var
  VstBackupItemRemoveChild : TVstBackupItemRemoveChild;
begin
  VstBackupItemRemoveChild := TVstBackupItemRemoveChild.Create( FolderPath );
  MyBackupFileFace.AddChange( VstBackupItemRemoveChild );
end;

procedure TBackupFolderRemoveHandle.RemoveFromInfo;
var
  BackupFolderRemoveInfo : TBackupFolderRemoveInfo;
begin
  BackupFolderRemoveInfo := TBackupFolderRemoveInfo.Create( FolderPath );
  MyBackupFileInfo.AddChange( BackupFolderRemoveInfo );
end;

procedure TBackupFolderRemoveHandle.RemoveFromNotify;
var
  BackupFolderRemoveNotify : TBackupFolderRemoveNotifyInfo;
begin
  BackupFolderRemoveNotify := TBackupFolderRemoveNotifyInfo.Create( FolderPath );
  MyBackupFileInfo.AddChange( BackupFolderRemoveNotify );
end;

procedure TBackupFolderRemoveHandle.RemoveFromXml;
var
  BackupFolderRemoveXml : TBackupFolderRemoveXml;
begin
  BackupFolderRemoveXml := TBackupFolderRemoveXml.Create( FolderPath );
  MyBackupXmlWrite.AddChange( BackupFolderRemoveXml );
end;

procedure TBackupFolderRemoveHandle.Update;
begin
  RemoveFromNotify;

  RemoveFromInfo;

  RemoveFromFace;

  RemoveFromXml;
end;

{ TBackupPathOwnerSpaceHandle }

procedure TBackupPathOwnerChangeSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TBackupPathOwnerClearHandle }

procedure TBackupPathOwnerClearHandle.ClearFromInfo;
var
  BackupPathOwnerClearSpaceInfo : TBackupPathOwnerClearSpaceInfo;
begin
  BackupPathOwnerClearSpaceInfo := TBackupPathOwnerClearSpaceInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathOwnerClearSpaceInfo );
end;

procedure TBackupPathOwnerClearHandle.ClearFromXml;
var
  BackupPathOwnerClearXml : TBackupPathOwnerClearXml;
begin
  BackupPathOwnerClearXml := TBackupPathOwnerClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathOwnerClearXml );
end;

procedure TBackupPathOwnerClearHandle.Update;
begin
  ClearFromInfo;

  ClearFromXml;
end;

{ TBackupPathOwnerRemoveSpaceHandle }

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromFace;
var
  VstCloudStatusHasMyBackupRemove : TVstCloudStatusHasMyBackupRemove;
  BackupPgRemoveCompletedInfo : TBackupPgRemoveCompletedInfo;
  MyBackupCloudLvRemoveSpace : TMyBackupCloudLvRemoveSpace;
begin
    // 添加 云Pc我的备份文件
  VstCloudStatusHasMyBackupRemove := TVstCloudStatusHasMyBackupRemove.Create( PcID );
  VstCloudStatusHasMyBackupRemove.SetSpaceInfo( FileSize, FileCount );
  MyNetworkFace.AddChange( VstCloudStatusHasMyBackupRemove );

    // 添加 备份进度条
  BackupPgRemoveCompletedInfo := TBackupPgRemoveCompletedInfo.Create( FileSize );
  MyBackupFileFace.AddChange( BackupPgRemoveCompletedInfo );

    // 添加 我的备份文件分布
  MyBackupCloudLvRemoveSpace := TMyBackupCloudLvRemoveSpace.Create( PcID );
  MyBackupCloudLvRemoveSpace.SetFileSpace( FileSize );
  MyBackupCloudLvRemoveSpace.SetFileCount( FileCount );
  MyNetworkFace.AddChange( MyBackupCloudLvRemoveSpace );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromInfo;
var
  BackupPathOwnerRemoveSpaceInfo : TBackupPathOwnerRemoveSpaceInfo;
begin
  BackupPathOwnerRemoveSpaceInfo := TBackupPathOwnerRemoveSpaceInfo.Create( FullPath );
  BackupPathOwnerRemoveSpaceInfo.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerRemoveSpaceInfo );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromXml;
var
  BackupPathOwnerRemoveSpaceXml : TBackupPathOwnerRemoveSpaceXml;
begin
  BackupPathOwnerRemoveSpaceXml := TBackupPathOwnerRemoveSpaceXml.Create( FullPath );
  BackupPathOwnerRemoveSpaceXml.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerRemoveSpaceXml );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromFace;

  RemoveFromXml;
end;

{ TBackupPathOwnerReadSpaceHandle }

procedure TBackupPathOwnerReadSpaceHandle.SetToFace;
var
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // 刷新 备份进度
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // 刷新 我的备份云信息
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathOwnerReadSpaceHandle.SetToInfo;
var
  BackupPathOwnerSetSpaceInfo : TBackupPathOwnerSetSpaceInfo;
begin
  BackupPathOwnerSetSpaceInfo := TBackupPathOwnerSetSpaceInfo.Create( FullPath );
  BackupPathOwnerSetSpaceInfo.SetPcID( PcID );
  BackupPathOwnerSetSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerSetSpaceInfo );
end;

procedure TBackupPathOwnerReadSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupFolderSetStatusHandle }

procedure TBackupFolderSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TBackupFolderSetStatusHandle.SetToFace;
var
  VstBackupFolderSetStatus : TVstBackupFolderSetStatus;
begin
  VstBackupFolderSetStatus := TVstBackupFolderSetStatus.Create( FolderPath );
  VstBackupFolderSetStatus.SetPathStatus( Status );
  MyBackupFileFace.AddChange( VstBackupFolderSetStatus );
end;

procedure TBackupFolderSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TBackupPathSetStatusHandle }

procedure TBackupPathSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TBackupPathSetStatusHandle.SetToFace;
var
  VstBackupPathSetStatus : TVstBackupPathSetStatus;
begin
  VstBackupPathSetStatus := TVstBackupPathSetStatus.Create( FullPath );
  VstBackupPathSetStatus.SetStatus( Status );
  MyBackupFileFace.AddChange( VstBackupPathSetStatus );
end;

procedure TBackupPathSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TBackupCopyChangeControl }

constructor TBackupCopyChangeControl.Create(_FilePath, _PcID: string);
begin
  FilePath := _FilePath;
  PcID := _PcID;
end;

procedure TBackupCopyChangeControl.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TBackupCopyChangeControl.Update;
begin
  RootBackupPath := MyBackupPathInfoUtil.ReadRootPath( FilePath );
end;

{ TBackupCopyRemoveControl }

procedure TBackupCopyRemoveControl.SyncFileNow;
var
  BackupFileSyncHandle : TBackupFileSyncHandle;
begin
  BackupFileSyncHandle := TBackupFileSyncHandle.Create( FilePath );
  BackupFileSyncHandle.Update;
  BackupFileSyncHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupCopy;
var
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupFolderCompletedSpace;
var
  FolderPath : string;
  BackupFolderRemoveCompletedSpaceHandle : TBackupFolderRemoveCompletedSpaceHandle;
begin
  if FilePath = RootBackupPath then
    FolderPath := FilePath
  else
    FolderPath := ExtractFileDir( FilePath );

  BackupFolderRemoveCompletedSpaceHandle := TBackupFolderRemoveCompletedSpaceHandle.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupFolderRemoveCompletedSpaceHandle.Update;
  BackupFolderRemoveCompletedSpaceHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupPathCompletedSpace;
var
  BackupPathRemoveCompletedSpaceHandle : TBackupPathRemoveCompletedSpaceHandle;
begin
  BackupPathRemoveCompletedSpaceHandle := TBackupPathRemoveCompletedSpaceHandle.Create( RootBackupPath );
  BackupPathRemoveCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupPathRemoveCompletedSpaceHandle.Update;
  BackupPathRemoveCompletedSpaceHandle.Free;
end;


procedure TBackupCopyRemoveControl.RemoveBackupPathCopy;
var
  BackupPathOwnerRemoveSpaceHandle : TBackupPathOwnerRemoveSpaceHandle;
begin
  BackupPathOwnerRemoveSpaceHandle := TBackupPathOwnerRemoveSpaceHandle.Create( RootBackupPath );
  BackupPathOwnerRemoveSpaceHandle.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceHandle.SetSpaceInfo( FileSize, 1 );
  BackupPathOwnerRemoveSpaceHandle.Update;
  BackupPathOwnerRemoveSpaceHandle.Free;
end;

procedure TBackupCopyRemoveControl.Update;
begin
  inherited;

    // 根路径不存在
  if RootBackupPath = '' then
    Exit;

    // 删除 Copy 信息
  RemoveBackupCopy;
  RemoveBackupPathCopy;

    // 删除 空间信息
  RemoveBackupFolderCompletedSpace;
  RemoveBackupPathCompletedSpace;

    // 立刻同步该文件
  SyncFileNow;
end;

{ TBackupPathSetCompletedSpaceHandle }

procedure TBackupPathSetCompletedSpaceHandle.SetToInfo;
var
  BackupPathSetCompletedSpaceInfo : TBackupPathSetCompletedSpaceInfo;
begin
  BackupPathSetCompletedSpaceInfo := TBackupPathSetCompletedSpaceInfo.Create( FullPath );
  BackupPathSetCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathSetCompletedSpaceInfo );
end;

procedure TBackupPathSetCompletedSpaceHandle.SetToXml;
var
  BackupPathSetCompletedSpaceXml : TBackupPathSetCompletedSpaceXml;
begin
  BackupPathSetCompletedSpaceXml := TBackupPathSetCompletedSpaceXml.Create( FullPath );
  BackupPathSetCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathSetCompletedSpaceXml );
end;

procedure TBackupPathSetCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TBackupFolderChangeCompletedSpaceHanlde }

procedure TBackupFolderChangeCompletedSpaceHanlde.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupFolderRemoveCompletedSpaceHandle }

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromFace;
var
  VstBackupFolderRemoveCompletedSpace : TVstBackupFolderRemoveCompletedSpace;
begin
    // 添加 已完成空间信息
  VstBackupFolderRemoveCompletedSpace := TVstBackupFolderRemoveCompletedSpace.Create( FolderPath );
  VstBackupFolderRemoveCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderRemoveCompletedSpace );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromInfo;
var
  BackupFolderRemoveCompletedSpaceInfo : TBackupFolderRemoveCompletedSpaceInfo;
begin
    // 添加 备份目录 已完成空间
  BackupFolderRemoveCompletedSpaceInfo := TBackupFolderRemoveCompletedSpaceInfo.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderRemoveCompletedSpaceInfo );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromToXml;
var
  BackupFolderRemoveCompletedSpaceXml : TBackupFolderRemoveCompletedSpaceXml;
begin
  BackupFolderRemoveCompletedSpaceXml := TBackupFolderRemoveCompletedSpaceXml.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderRemoveCompletedSpaceXml );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromToXml;
end;

{ TBackupPathChangeCompletedSpaceHandle }

procedure TBackupPathChangeCompletedSpaceHandle.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupPathAddCompletedSpaceHandle }

procedure TBackupPathAddCompletedSpaceHandle.AddToInfo;
var
  BackupPathAddCompletedSpaceInfo : TBackupPathAddCompletedSpaceInfo;
begin
  BackupPathAddCompletedSpaceInfo := TBackupPathAddCompletedSpaceInfo.Create( FullPath );
  BackupPathAddCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathAddCompletedSpaceInfo );
end;

procedure TBackupPathAddCompletedSpaceHandle.AddToXml;
var
  BackupPathAddCompletedSpaceXml : TBackupPathAddCompletedSpaceXml;
begin
  BackupPathAddCompletedSpaceXml := TBackupPathAddCompletedSpaceXml.Create( FullPath );
  BackupPathAddCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathAddCompletedSpaceXml );
end;

procedure TBackupPathAddCompletedSpaceHandle.Update;
begin
  AddToInfo;
  AddToXml;
end;

{ TBackupPathRemoveCompletedSpaceHandle }

procedure TBackupPathRemoveCompletedSpaceHandle.RemoveFromInfo;
var
  BackupPathRemoveCompletedSpaceInfo : TBackupPathRemoveCompletedSpaceInfo;
begin
  BackupPathRemoveCompletedSpaceInfo := TBackupPathRemoveCompletedSpaceInfo.Create( FullPath );
  BackupPathRemoveCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathRemoveCompletedSpaceInfo );
end;

procedure TBackupPathRemoveCompletedSpaceHandle.RemoveFromXml;
var
  BackupPathRemoveCompletedSpaceXml : TBackupPathRemoveCompletedSpaceXml;
begin
  BackupPathRemoveCompletedSpaceXml := TBackupPathRemoveCompletedSpaceXml.Create( FullPath );
  BackupPathRemoveCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathRemoveCompletedSpaceXml );
end;

procedure TBackupPathRemoveCompletedSpaceHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TBackupPathSetIsNotEnoughSpaceHandle }

procedure TBackupPathSetIsNotEnoughPcHandle.RefreshNotEnough;
var
  BackupPathReadIsEnoughPcInfo : TBackupPathReadIsNotEnoughPcInfo;
begin
    // 刷新 所有路径是否存在 不足够的 Pc
  BackupPathReadIsEnoughPcInfo := TBackupPathReadIsNotEnoughPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadIsEnoughPcInfo );
end;

procedure TBackupPathSetIsNotEnoughPcHandle.SetIsNotEnoughPc(
  _IsNotEnoughPc: Boolean);
begin
  IsNotEnoughPc := _IsNotEnoughPc;
end;


procedure TBackupPathSetIsNotEnoughPcHandle.SetToInfo;
var
  BackupPathIsEnoughPcInfo : TBackupPathIsNotEnoughPcInfo;
begin
    // 刷新 当前扫描路径 是否 足够 Pc
  BackupPathIsEnoughPcInfo := TBackupPathIsNotEnoughPcInfo.Create( FullPath );
  BackupPathIsEnoughPcInfo.SetIsNotEnouthPc( IsNotEnoughPc );
  MyBackupFileInfo.AddChange( BackupPathIsEnoughPcInfo );
end;

procedure TBackupPathSetIsNotEnoughPcHandle.Update;
begin
  SetToInfo;
  RefreshNotEnough;
end;

{ TBackupSelectRefreshHandle }

procedure TBackupSelectRefreshHandle.RefreshFace;
var
  VstBackupPathRefreshSelectNode : TVstBackupPathRefreshSelectNode;
begin
  VstBackupPathRefreshSelectNode := TVstBackupPathRefreshSelectNode.Create( FullPath );
  MyBackupFileFace.AddChange( VstBackupPathRefreshSelectNode );
end;

procedure TBackupSelectRefreshHandle.Update;
begin
  RefreshFace;
end;

{ TBackupPathScanAllHandle }

procedure TBackupPathScanAllHandle.AddToInfo;
var
  BackupPathScanAllInfo : TBackupPathScanAllInfo;
begin
  BackupPathScanAllInfo := TBackupPathScanAllInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathScanAllInfo );
end;

procedure TBackupPathScanAllHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathSyncAllHandle }

procedure TBackupPathSyncAllHandle.AddToInfo;
var
  BackupPathSyncAllInfo : TBackupPathSyncAllInfo;
begin
  BackupPathSyncAllInfo := TBackupPathSyncAllInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathSyncAllInfo );
end;

procedure TBackupPathSyncAllHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathScanHandle }

procedure TBackupPathScanHandle.AddToInfo;
var
  BackupPathScanFileInfo : TBackupPathScanInfo;
begin
  BackupPathScanFileInfo := TBackupPathScanInfo.Create( FullPath );
  BackupPathScanFileInfo.SetIsShowFreeLimt( IsShowFreeLimt );
  MyBackupFileInfo.AddChange( BackupPathScanFileInfo );
end;

procedure TBackupPathScanHandle.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathScanHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathAddControl }

procedure TBackupPathAddDefaultControl.AddBackupFilter;
var
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // 过滤 隐藏文件
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_SystemFile, '' );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;

    // 过滤 系统文件
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_HiddenFile, '' );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

procedure TBackupPathAddDefaultControl.AddBackupPath;
var
  BackupPathAddHandle : TBackupPathAddHandle;
begin
    // 添加 备份路径
  BackupPathAddHandle := TBackupPathAddHandle.Create( FullPath );
  BackupPathAddHandle.SetPathInfo( PathType );
  BackupPathAddHandle.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddHandle.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddHandle.SetCountInfo( CopyCount, 0 );
  BackupPathAddHandle.SetSpaceInfo( 0, 0 );
  BackupPathAddHandle.Update;
  BackupPathAddHandle.Free;
end;

procedure TBackupPathAddDefaultControl.BackupPathNow;
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
    // 立刻 备份路径
  BackupPathScanHandle := TBackupPathScanHandle.Create( FullPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TBackupPathAddDefaultControl.FindEncryptInfo;
begin
    // 加密信息
  IsEncrypt := BackupFileEncryptSettingInfo.IsEncrypt;
  if not IsEncrypt then
  begin
    Password := '';
    PasswordHint := '';
  end
  else
  begin
    Password := BackupFileEncryptSettingInfo.Password;
    PasswordHint := BackupFileEncryptSettingInfo.PasswordHint;
  end;
end;

procedure TBackupPathAddDefaultControl.FindGenernalInfo;
begin
    // 路径类型
  PathType := MyFilePath.getPathType( FullPath );

    // 基本信息
  IsDisable := False;
  IsBackupNow := True;
  CopyCount := BackupFileSafeSettingInfo.CopyCount;
  IsAutoSync := SyncTimeSettingInfo.IsAutoSync;
  SyncTimeType := SyncTimeSettingInfo.TimeType;
  SyncTimeValue := SyncTimeSettingInfo.SyncTime;
  LastSyncTime := Now;
end;

procedure TBackupPathAddDefaultControl.Update;
begin
    // 获取 默认普通信息
  FindGenernalInfo;

    // 获取 加密信息
  FindEncryptInfo;

    // 添加 备份路径
  AddBackupPath;

    // 添加 默认的过滤器
  AddBackupFilter;

    // 立刻备份
  BackupPathNow;
end;

{ TBackupPathAddControl }

constructor TBackupPathAddControl.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TBackupPathAddConfigControl }

procedure TBackupPathAddConfigControl.AddBackupFilter;
var
  i : Integer;
  FilterInfo : TFileFilterInfo;
  BackupPathIncludeFilterAddHandle : TBackupPathIncludeFilterAddHandle;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // 包含 过滤器
  for i := 0 to IncludeFileFilterList.Count - 1 do
  begin
    FilterInfo := IncludeFileFilterList[i];

      // 不是当前路径的 过滤器
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // 添加 过滤器
    BackupPathIncludeFilterAddHandle := TBackupPathIncludeFilterAddHandle.Create( FullPath );
    BackupPathIncludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    BackupPathIncludeFilterAddHandle.Update;
    BackupPathIncludeFilterAddHandle.Free;
  end;

    // 排除 过滤器
  for i := 0 to ExcludeFileFilterList.Count - 1 do
  begin
    FilterInfo := ExcludeFileFilterList[i];

        // 不是当前路径的 过滤器
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // 添加 过滤器
    BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
    BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    BackupPathExcludeFilterAddHandle.Update;
    BackupPathExcludeFilterAddHandle.Free;
  end;
end;

procedure TBackupPathAddConfigControl.AddBackupPath;
var
  BackupPathAddHandle : TBackupPathAddHandle;
begin
    // 添加 备份路径
  BackupPathAddHandle := TBackupPathAddHandle.Create( FullPath );
  BackupPathAddHandle.SetPathInfo( PathType );
  BackupPathAddHandle.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddHandle.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddHandle.SetCountInfo( CopyCount, 0 );
  BackupPathAddHandle.SetSpaceInfo( 0, 0 );
  BackupPathAddHandle.Update;
  BackupPathAddHandle.Free;
end;

procedure TBackupPathAddConfigControl.BackupPathNow;
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
    // 立刻 备份路径
  BackupPathScanHandle := TBackupPathScanHandle.Create( FullPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TBackupPathAddConfigControl.FindEncryptInfo;
begin
    // 加密信息
  IsEncrypt := BackupConfigInfo.IsEncrypt;
  if not IsEncrypt then
  begin
    Password := '';
    PasswordHint := '';
  end
  else
  begin
    Password := BackupConfigInfo.Password;
    PasswordHint := BackupConfigInfo.PasswordHint;
  end;
end;


procedure TBackupPathAddConfigControl.FindFilterInfo;
begin
  IncludeFileFilterList := BackupConfigInfo.IncludeFilterList;
  ExcludeFileFilterList := BackupConfigInfo.ExcludeFilterList;
end;

procedure TBackupPathAddConfigControl.FindGenernalInfo;
begin
    // 路径类型
  PathType := MyFilePath.getPathType( FullPath );

    // 基本信息
  IsDisable := BackupConfigInfo.IsDisable;
  IsBackupNow := BackupConfigInfo.IsBackupupNow;
  CopyCount := BackupConfigInfo.CopyCount;
  IsAutoSync := BackupConfigInfo.IsAuctoSync;
  SyncTimeType := BackupConfigInfo.SyncTimeType;
  SyncTimeValue := BackupConfigInfo.SyncTimeValue;
  LastSyncTime := Now;
end;

function TBackupPathAddConfigControl.IsPathFilter(
  FilterInfo: TFileFilterInfo): Boolean;
begin
  Result := True;
  if FilterInfo.FilterType <> FilterType_Path then
    Exit;

  Result := MyMatchMask.CheckEqualsOrChild( FilterInfo.FilterStr, FullPath );
end;

procedure TBackupPathAddConfigControl.SetBackupConfigInfo(
  _BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TBackupPathAddConfigControl.Update;
begin
    // 提取信息
  FindGenernalInfo;
  FindEncryptInfo;
  FindFilterInfo;

    // 添加信息
  AddBackupPath;
  AddBackupFilter;
  BackupPathNow;
end;

{ TBackupPathFilterAddHandle }

procedure TBackupPathFilterWriteHandle.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

{ TBackupPathIncludeFilterAddHandle }

procedure TBackupPathIncludeFilterReadHandle.AddToInfo;
var
  BackupPathIncludeFilterAddInfo : TBackupPathIncludeFilterAddInfo;
begin
  BackupPathIncludeFilterAddInfo := TBackupPathIncludeFilterAddInfo.Create( FullPath );
  BackupPathIncludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  MyBackupFileInfo.AddChange( BackupPathIncludeFilterAddInfo );
end;

procedure TBackupPathIncludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathIncludeFilterAddHandle }

procedure TBackupPathIncludeFilterAddHandle.AddToXml;
var
  BackupPathIncludeFilterAddXml : TBackupPathIncludeFilterAddXml;
begin
  BackupPathIncludeFilterAddXml := TBackupPathIncludeFilterAddXml.Create( FullPath );
  BackupPathIncludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyBackupXmlWrite.AddChange( BackupPathIncludeFilterAddXml );
end;

procedure TBackupPathIncludeFilterAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathExcludeFilterAddHandle }

procedure TBackupPathExcludeFilterReadHandle.AddToInfo;
var
  BackupPathExcludeFilterAddInfo : TBackupPathExcludeFilterAddInfo;
begin
  BackupPathExcludeFilterAddInfo := TBackupPathExcludeFilterAddInfo.Create( FullPath );
  BackupPathExcludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  MyBackupFileInfo.AddChange( BackupPathExcludeFilterAddInfo );
end;

procedure TBackupPathExcludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathExcludeFilterAddHandle }

procedure TBackupPathExcludeFilterAddHandle.AddToXml;
var
  BackupPathExcludeFilterAddXml : TBackupPathExcludeFilterAddXml;
begin
  BackupPathExcludeFilterAddXml := TBackupPathExcludeFilterAddXml.Create( FullPath );
  BackupPathExcludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyBackupXmlWrite.AddChange( BackupPathExcludeFilterAddXml );
end;

procedure TBackupPathExcludeFilterAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathFilterClearHandle }

procedure TBackupPathIncludeFilterClearHandle.ClearToInfo;
var
  BackupPathIncludeFilterClearInfo : TBackupPathIncludeFilterClearInfo;
begin
  BackupPathIncludeFilterClearInfo := TBackupPathIncludeFilterClearInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathIncludeFilterClearInfo );
end;

procedure TBackupPathIncludeFilterClearHandle.ClearToXml;
var
  BackupPathIncludeFilterClearXml : TBackupPathIncludeFilterClearXml;
begin
  BackupPathIncludeFilterClearXml := TBackupPathIncludeFilterClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathIncludeFilterClearXml );
end;

procedure TBackupPathIncludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TBackupPathExcludeFilterClearHandle }

procedure TBackupPathExcludeFilterClearHandle.ClearToInfo;
var
  BackupPathExcludeFilterClearInfo : TBackupPathExcludeFilterClearInfo;
begin
  BackupPathExcludeFilterClearInfo := TBackupPathExcludeFilterClearInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathExcludeFilterClearInfo );
end;

procedure TBackupPathExcludeFilterClearHandle.ClearToXml;
var
  BackupPathExcludeFilterClearXml : TBackupPathExcludeFilterClearXml;
begin
  BackupPathExcludeFilterClearXml := TBackupPathExcludeFilterClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathExcludeFilterClearXml );
end;

procedure TBackupPathExcludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TBackupPathSetLastSyncTimeHandle }

procedure TBackupPathSetLastSyncTimeHandle.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToFace;
var
  VstBackupPathSetLastSyncTime : TVstBackupPathSetLastSyncTime;
begin
  VstBackupPathSetLastSyncTime := TVstBackupPathSetLastSyncTime.Create( FullPath );
  VstBackupPathSetLastSyncTime.SetLastSyncTime( LastSyncTime );
  MyBackupFileFace.AddChange( VstBackupPathSetLastSyncTime );
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToInfo;
var
  BackupPathSetLastSyncTimeInfo : TBackupPathSetLastSyncTimeInfo;
begin
  BackupPathSetLastSyncTimeInfo := TBackupPathSetLastSyncTimeInfo.Create( FullPath );
  BackupPathSetLastSyncTimeInfo.SetLastSyncTime( LastSyncTime );
  MyBackupFileInfo.AddChange( BackupPathSetLastSyncTimeInfo );
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToXml;
var
  BackupPathSetLastSyncTimeXml : TBackupPathSetLastSyncTimeXml;
begin
  BackupPathSetLastSyncTimeXml := TBackupPathSetLastSyncTimeXml.Create( FullPath );
  BackupPathSetLastSyncTimeXml.SetLastSyncTime( LastSyncTime );
  MyBackupXmlWrite.AddChange( BackupPathSetLastSyncTimeXml );
end;

procedure TBackupPathSetLastSyncTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathSetSyncMinsHandle }

procedure TBackupPathSetAutoSyncHandle.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupPathSetAutoSyncHandle.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue : Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathSetAutoSyncHandle.SetToFace;
var
  VstBackupPathSetSyncMins : TVstBackupPathSetSyncTime;
begin
  VstBackupPathSetSyncMins := TVstBackupPathSetSyncTime.Create( FullPath );
  VstBackupPathSetSyncMins.SetIsAutoSync( IsAutoSync );
  VstBackupPathSetSyncMins.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  MyBackupFileFace.AddChange( VstBackupPathSetSyncMins );
end;

procedure TBackupPathSetAutoSyncHandle.SetToInfo;
var
  BackupPathSetSyncMinsInfo : TBackupPathSetSyncMinsInfo;
begin
  BackupPathSetSyncMinsInfo := TBackupPathSetSyncMinsInfo.Create( FullPath );
  BackupPathSetSyncMinsInfo.SetIsAutoSync( IsAutoSync );
  BackupPathSetSyncMinsInfo.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyBackupFileInfo.AddChange( BackupPathSetSyncMinsInfo );
end;

procedure TBackupPathSetAutoSyncHandle.SetToXml;
var
  BackupPathSetSyncMinsXml : TBackupPathSetSyncMinsXml;
begin
  BackupPathSetSyncMinsXml := TBackupPathSetSyncMinsXml.Create( FullPath );
  BackupPathSetSyncMinsXml.SetIsAutoSync( IsAutoSync );
  BackupPathSetSyncMinsXml.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyBackupXmlWrite.AddChange( BackupPathSetSyncMinsXml );
end;

procedure TBackupPathSetAutoSyncHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathRefreshLastSyncTimeHanlde }

procedure TBackupPathRefreshLastSyncTimeHandle.SetToFace;
var
  VstBackuppathRefreshNextSyncTime : TVstBackuppathRefreshNextSyncTime;
begin
  VstBackuppathRefreshNextSyncTime := TVstBackuppathRefreshNextSyncTime.Create( FullPath );
  MyBackupFileFace.AddChange( VstBackuppathRefreshNextSyncTime );
end;

procedure TBackupPathRefreshLastSyncTimeHandle.Update;
begin
  SetToFace;
end;

{ TBackupPathSetIsDisableHandle }

procedure TBackupPathSetIsDisableHandle.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupPathSetIsDisableHandle.SetToFace;
var
  VstBackupPathIsDisable : TVstBackupPathIsDisable;
begin
  VstBackupPathIsDisable := TVstBackupPathIsDisable.Create( FullPath );
  VstBackupPathIsDisable.SetIsDisable( IsDisable );
  MyBackupFileFace.AddChange( VstBackupPathIsDisable );
end;

procedure TBackupPathSetIsDisableHandle.SetToInfo;
var
  BackupPathIsDisableInfo : TBackupPathIsDisableInfo;
begin
  BackupPathIsDisableInfo := TBackupPathIsDisableInfo.Create( FullPath );
  BackupPathIsDisableInfo.SetIsDisable( IsDisable );
  MyBackupFileInfo.AddChange( BackupPathIsDisableInfo );
end;

procedure TBackupPathSetIsDisableHandle.SetToXml;
var
  BackupPathIsDisableXml : TBackupPathIsDisableXml;
begin
  BackupPathIsDisableXml := TBackupPathIsDisableXml.Create( FullPath );
  BackupPathIsDisableXml.SetIsDisable( IsDisable );
  MyBackupXmlWrite.AddChange( BackupPathIsDisableXml );
end;

procedure TBackupPathSetIsDisableHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathSetIsBackupNowHandle }

procedure TBackupPathSetIsBackupNowHandle.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathSetIsBackupNowHandle.SetToXml;
var
  BackupPathIsBackupNowXml : TBackupPathIsBackupNowXml;
begin
  BackupPathIsBackupNowXml := TBackupPathIsBackupNowXml.Create( FullPath );
  BackupPathIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  MyBackupXmlWrite.AddChange( BackupPathIsBackupNowXml );
end;

procedure TBackupPathSetIsBackupNowHandle.SetToInfo;
var
  BackupPathIsBackupNowInfo : TBackupPathIsBackupNowInfo;
begin
  BackupPathIsBackupNowInfo := TBackupPathIsBackupNowInfo.Create( FullPath );
  BackupPathIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  MyBackupFileInfo.AddChange( BackupPathIsBackupNowInfo );
end;

procedure TBackupPathSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TBackupFolderAddMaskControl }

procedure TBackupFolderCancelBackupControl.AddToExcludeFilter;
var
  RootPath : string;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // 读取 根路径
  RootPath := MyBackupPathInfoUtil.ReadRootPath( FolderPath );

    // 添加 排除过滤
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( RootPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_Path, FolderPath );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

constructor TBackupFolderCancelBackupControl.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

procedure TBackupFolderCancelBackupControl.RemoveFolder;
var
  BackupFolderRemoveHandle : TBackupFolderRemoveHandle;
begin
  BackupFolderRemoveHandle := TBackupFolderRemoveHandle.Create( FolderPath );
  BackupFolderRemoveHandle.Update;
  BackupFolderRemoveHandle.Free;
end;

procedure TBackupFolderCancelBackupControl.Update;
begin
  AddToExcludeFilter;
  RemoveFolder;
end;

{ TBackupFileAddMaskControl }

procedure TBackupFileCancelBackupControl.AddToExcludeFilter;
var
  RootPath : string;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // 读取 根路径
  RootPath := MyBackupPathInfoUtil.ReadRootPath( FilePath );

    // 添加 排除过滤
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( RootPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_Path, FilePath );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

constructor TBackupFileCancelBackupControl.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupFileCancelBackupControl.RemoveFile;
var
  BackupFileRemoveHandle : TBackupFileRemoveHandle;
begin
  BackupFileRemoveHandle := TBackupFileRemoveHandle.Create( FilePath );
  BackupFileRemoveHandle.Update;
  BackupFileRemoveHandle.Free;
end;

procedure TBackupFileCancelBackupControl.Update;
begin
  AddToExcludeFilter;
  RemoveFile;
end;

{ TBackupPathSyncHandle }

procedure TBackupPathSyncHandle.AddToInfo;
var
  BackupPathFreeScanJobInfo : TBackupPathSyncInfo;
begin
  BackupPathFreeScanJobInfo := TBackupPathSyncInfo.Create( FullPath );
  BackupPathFreeScanJobInfo.SetIsShowFreeLimt( IsShowFreeLimt );
  MyBackupFileInfo.AddChange( BackupPathFreeScanJobInfo );
end;

procedure TBackupPathSyncHandle.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathSyncHandle.Update;
begin
  AddToInfo;
end;

end.

