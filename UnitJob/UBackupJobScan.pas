unit UBackupJobScan;

interface

uses UFileBaseInfo, UChangeInfo, Generics.Collections, UMyUtil, Classes,
     Windows, UModelUtil, SyncObjs, SysUtils, Math, uDebug;

type

{$Region ' 扫描目录 ' }

  {$Region ' 数据结构 ' }

    // Pc 的 Available Space
  TTempPcSpace = class
  public
    PcID : string;
    AvailableSpace, ComsumpSpace : Int64;
  public
    constructor Create( _PcID : string );
    procedure SetSpaceInfo( _AvailableSpace, _ComsumpSpace : Int64 );
  public
    function IsSmallThenPc( PcSpace : TTempPcSpace ): Boolean;
  end;
  TTempPcSpaceList = class( TObjectList<TTempPcSpace> )
  public
    procedure SortSpace;
  end;

  TTempBackupPathOwnerInfo = class
  public
    PcID : string;
    OwnerSpace : Int64;
    OwnerFileCount : Integer;
  public
    constructor Create( _PcID : string );
  end;
  TTempBackupPathOwnerPair = TPair< string , TTempBackupPathOwnerInfo >;
  TTempBackupPathOwnerHash = class(TStringDictionary< TTempBackupPathOwnerInfo >);


  {$EndRegion}

  {$Region ' 数据操作 ' }

    // 分配 同步Job 父类
  TBackupJobScanner = class
  protected
    ScanPath : string;
    CopyCount : Integer;
    TempPcSpaceList : TTempPcSpaceList;
    IsNotEnoughPc : Boolean;
  public
    procedure SetScanPath( _ScanPath : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure SetTempPcSpaceList( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;virtual;abstract;
  protected
    procedure CheckFileJob( FileInfo : TTempBackupFileInfo );virtual;
    procedure CheckOfflineJob( FileInfo : TTempBackupFileInfo );
    procedure BackupJobAddHandle( PcID: string; FileInfo : TTempBackupFileInfo );
  protected
    function getFilePath( FileName : string ): string;virtual;
  end;

    // 分配 非根文件 同步Job
  TBackupFileJobScanner = class( TBackupJobScanner )
  public
    procedure Update;override;
  protected
    function getFilePath( FileName : string ): string;override;
  end;

    // 分配 目录 同步Job 父类
  TBackupFolderJobScanner = class( TBackupJobScanner )
  private
    ScanCount, TotalFileCount : Integer;
    TempBackupFolderInfo : TTempBackupFolderInfo;
  public
    constructor Create;
    procedure SetScanCount( _ScanCount : Integer );
    procedure SetTotalCount( _TotalCount : Integer );
    procedure Update;override;
  private
    procedure FindTempBackupFolderInfo;
    procedure CheckFileCopy;
    procedure CheckFolderCopy;
    procedure DeleteTempBackupFolderInfo;
  protected
    function CheckNextSearch : Boolean;virtual;
    function getFolderJobScan : TBackupFolderJobScanner;virtual;abstract;
    procedure ResetFolderJobScan( FolderJobScan : TBackupFolderJobScanner );virtual;
  end;

    // 分配 根路径 同步Job
  TBackupRootJobScanner = class( TBackupFolderJobScanner )
  private
    BackupPathOwnerHash : TTempBackupPathOwnerHash;
    LastCompletedSpace, CompletedSpace : Int64;
  public
    constructor Create;
    procedure SetBackupPathOwnerHash( _BackupPathOwnerHash : TTempBackupPathOwnerHash );
    procedure Update;override;
  protected
    function CheckNextSearch : Boolean;override;
    procedure CheckFileJob( FileInfo : TTempBackupFileInfo );override;
    function getFolderJobScan : TBackupFolderJobScanner;override;
    procedure ResetFolderJobScan( FolderJobScan : TBackupFolderJobScanner );override;
  private
    procedure CheckLoadedJob( FileInfo : TTempBackupFileInfo );
    procedure CheckBackupPathOwner( FileInfo : TTempBackupFileInfo );
  private       // TreeView 界面状态
    procedure ResetAnalyzingStatus;
    procedure ResetStopStatus;
    procedure AddBackupBoardFileCount;
  private       // 目录空间信息状态
    procedure ReadLastCompletedSpace;
    procedure SetCompletedSpace;
  end;

    // 分配 根目录 同步Job
  TBackupRootFolderJobScanner = class( TBackupRootJobScanner )
  end;

    // 分配 根文件 同步Job
  TBackupRootFileJobScanner = class( TBackupRootJobScanner )
  protected
    function getFilePath( FileName : string ): string;override;
  end;

    // 分配 非根目录 同步Job
  TBackupChildFolderJobFolderScanner = class( TBackupFolderJobScanner )
  protected
    function getFolderJobScan : TBackupFolderJobScanner;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 新增 Backup Job 处理 ' }

  TBackupJobAdd = class
  public
    PcID, FilePath : string;
    PcName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _PcID, _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;
  private
    procedure AddToBackupCopy;
    procedure AddToDestinationPc;
    procedure AddToBackupJob;
  end;

{$EndRegion}

{$Region ' 备份 Job 扫描处理 ' }

    // 访问 网络 Pc 可用空间信息
  TFindTempPcSpace = class
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;
  end;

    // 重设 网络 Pc 可用空间
  TResetPcSpace = class
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;
  end;

    // 扫描 备份路径处理
  TBackupPathJobScanner = class
  private
    ScanPath : string;
    CopyCount : Integer;
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create;
    procedure SetScanPath( _ScanPath : string );
    procedure Update;virtual;
    destructor Destroy; override;
  private
    procedure FindTempPcSpaceList;
    procedure BackupJobScan;virtual;abstract;
    procedure ResetPcSpaceList;
  end;

    // 扫描 根路径
  TRootPathJobScanner = class( TBackupPathJobScanner )
  protected
    IsNotEnouthPc : Boolean;
    CompletedSpace : Int64;
    BackupPathOwnerHash : TTempBackupPathOwnerHash;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected
    procedure BackupJobScan;override;
  private
    procedure AddBackupBoard;
    procedure RemoveBackupBoard;
  private
    procedure ResetBackupPathOwner;
    procedure ResetNotEnoughPcBackup;
    procedure ResetCompletedSpace;
    procedure BackupSelectRefresh;
  end;

    // 扫描 非根路径
  TChildPathJobScanner = class( TBackupPathJobScanner )
  protected
    procedure BackupJobScan;override;
  end;

{$EndRegion}

    // 扫描 Job 路径信息
  TBackupJobScanInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TBackupJobScanList = class(TObjectList< TBackupJobScanInfo >);

    // 处理 扫描 Job
  TBackupJobScanHandle = class
  public
    BackupJobScanInfo : TBackupJobScanInfo;
    ScanPath : string;
  public
    constructor Create( _BackupJobScanInfo : TBackupJobScanInfo );
    procedure Update;
  end;

      // 扫描线程
  TBackupJobScanThread = class( TThread )
  private
    Lock : TCriticalSection;
    BackupJobScanList : TBackupJobScanList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddScanInfo( ScanInfo : TBackupJobScanInfo );
  private
    function getNextScanInfo : TBackupJobScanInfo;
    procedure ScanJobHandle( ScanInfo : TBackupJobScanInfo );
    procedure ScanCompleted;
  end;

    // 备份Job 控制器
  TMyBackupJobScanInfo = class
  private
    IsRun : Boolean;
    BackupJobScanThread : TBackupJobScanThread;
  public
    constructor Create;
    procedure AddScanPath( BackupJobScanInfo : TBackupJobScanInfo );
    procedure StopJobScan;
  end;

const
  ScanCount_Sleep : Integer = 10;

var
  MyBackupJobScanInfo : TMyBackupJobScanInfo; // 扫描备份 Job

implementation

uses UJobFace, UMyFileUpload, UMyClient, UMyServer, UMyJobInfo, UMyFileTransfer, UBackupInfoFace,
     UMyBackupInfo, UMyNetPcInfo, USettingInfo, UBackupInfoXml, UBackupBoardInfo,
     UBackupInfoControl, URegisterInfo, UJobControl, UBackupFileConfirm;

{ TCheckFolderScan }

procedure TBackupFolderJobScanner.CheckFileCopy;
var
  FileHash : TTempBackupFileHash;
  p : TTempBackupFilePair;
begin
  FileHash := TempBackupFolderInfo.TempBackupFileHash;
  for p in FileHash do
  begin
      // 程序结束
    if not CheckNextSearch then
      Break;

      // 检测 Job
    CheckFileJob( p.Value );
  end;
end;

procedure TBackupFolderJobScanner.CheckFolderCopy;
var
  FolderHash : TTempBackupFolderHash;
  p : TTempBackupFolderPair;
  FolderName, ChildPath : string;
  BackupFolderJobScanner : TBackupFolderJobScanner;
begin
  FolderHash := TempBackupFolderInfo.TempBackupFolderHash;
  for p in FolderHash do
  begin
      // 程序结束
    if not CheckNextSearch then
      Break;

    FolderName := p.Value.FileName;
    ChildPath := MyFilePath.getPath( ScanPath ) + FolderName;

      // 扫描 子目录
    BackupFolderJobScanner := getFolderJobScan;
    BackupFolderJobScanner.SetScanPath( ChildPath );
    BackupFolderJobScanner.SetScanCount( ScanCount );
    BackupFolderJobScanner.SetTotalCount( TotalFileCount );
    BackupFolderJobScanner.SetCopyCount( CopyCount );
    BackupFolderJobScanner.SetTempPcSpaceList( TempPcSpaceList );
    BackupFolderJobScanner.Update;
    ScanCount := BackupFolderJobScanner.ScanCount;
    TotalFileCount := BackupFolderJobScanner.TotalFileCount;
    IsNotEnoughPc := IsNotEnoughPc or BackupFolderJobScanner.IsNotEnoughPc;
    ResetFolderJobScan( BackupFolderJobScanner );
    BackupFolderJobScanner.Free;
  end;
end;

function TBackupFolderJobScanner.CheckNextSearch: Boolean;
begin
  inc( ScanCount );
  Inc( TotalFileCount );
  if ScanCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    ScanCount := 0;
  end;

  Result := MyBackupJobScanInfo.IsRun;
  Result := Result and MyBackupPathInfoUtil.ReadIsEnable( ScanPath );
end;

constructor TBackupFolderJobScanner.Create;
begin
  inherited;

  ScanCount := 0;
  TotalFileCount := 0;
end;

procedure TBackupFolderJobScanner.DeleteTempBackupFolderInfo;
begin
  TempBackupFolderInfo.Free;
end;

procedure TBackupFolderJobScanner.FindTempBackupFolderInfo;
begin
    // 读取 缓存信息
  TempBackupFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderInfo( ScanPath );
end;

procedure TBackupFolderJobScanner.ResetFolderJobScan(
  FolderJobScan: TBackupFolderJobScanner);
begin

end;

procedure TBackupFolderJobScanner.SetScanCount(_ScanCount: Integer);
begin
  ScanCount := _ScanCount;
end;

procedure TBackupFolderJobScanner.SetTotalCount(_TotalCount: Integer);
begin
  TotalFileCount := _TotalCount;
end;

procedure TBackupFolderJobScanner.Update;
begin
    // 读取 备份目录 缓存信息
  FindTempBackupFolderInfo;

    // 分配 Job
  CheckFileCopy;

    // 分配 子目录 Job
  CheckFolderCopy;

    // 删除 缓冲信息
  DeleteTempBackupFolderInfo;
end;



{ TCheckPcSpace }

function TTempPcSpace.IsSmallThenPc(PcSpace: TTempPcSpace): Boolean;
begin
    // 已备份 空间比较
  if PcSpace.ComsumpSpace > Self.ComsumpSpace then
    Result := True
  else
  if PcSpace.ComsumpSpace = Self.ComsumpSpace then
    Result := PcSpace.AvailableSpace > Self.AvailableSpace // 可用空间比较
  else
    Result := False;
end;

constructor TTempPcSpace.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TCheckPcSpaceList }

procedure TTempPcSpaceList.SortSpace;
var
  i, j : Integer;
  PcSpace1, PcSpace2, Temp : TTempPcSpace;
begin
  Self.OwnsObjects := False;
    // 冒泡排序, 权重小的排后, 权重大的排前.
    // 权重相等, 按空间排序, 空间小的排后, 空间大的排前.
  for i := 0 to Self.Count - 2 do
    for j := 0 to Self.Count - 2 - i do
    begin
      PcSpace1 := Self[ j ];
      PcSpace2 := Self[ j + 1 ];

          // 排前的权重小, 位置发生变化
      if PcSpace1.IsSmallThenPc( PcSpace2 ) then
      begin
        Temp := Self[ j ];
        Self[ j ] := Self[ j + 1 ];
        Self[ j + 1 ] := Temp;
      end;
    end;
  Self.OwnsObjects := True;
end;

{ TFindCheckPcSpace }

constructor TFindTempPcSpace.Create(_TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

procedure TFindTempPcSpace.Update;
var
  NetPcHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
  AvailableSpace, ComsumpSpace : Int64;
  TempPcSpace : TTempPcSpace;
begin
  MyNetPcInfo.EnterData;
  NetPcHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcHash do
  begin
      // 过滤 备份 Pc
    if  not p.Value.IsBackup or  // 黑名单
        not p.Value.IsOnline or  // 离线
       ( p.Value.PcID = PcInfo.PcID ) or  // 本机
       ( TransferSafeSettingInfo.IsRemoveForbid and             // 远程禁止
        not MyParseHost.CheckIpLan( p.Value.Ip, PcInfo.LanIp ) )
    then
      Continue;

      // 添加 备份 Pc
    AvailableSpace := p.Value.TotalSpace - p.Value.UsedSpace;
    ComsumpSpace := MyBackupPathInfoUtil.ReadComsumpPcSpace( p.Value.PcID );
    TempPcSpace := TTempPcSpace.Create( p.Value.PcID );
    TempPcSpace.SetSpaceInfo( AvailableSpace, ComsumpSpace );
    TempPcSpaceList.Add( TempPcSpace );
  end;
  MyNetPcInfo.LeaveData;
end;


{ TBackupJobAddHandle }

procedure TBackupJobAdd.AddToBackupCopy;
var
  BackupCopyAddPendHandle : TBackupCopyAddPendHandle;
begin
  BackupCopyAddPendHandle := TBackupCopyAddPendHandle.Create( FilePath );
  BackupCopyAddPendHandle.SetCopyOwner( PcID );
  BackupCopyAddPendHandle.Update;
  BackupCopyAddPendHandle.Free;
end;

procedure TBackupJobAdd.AddToBackupJob;
var
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( FilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TBackupJobAdd.AddToDestinationPc;
var
  PcAddDownPendBackupFileMsg : TPcAddDownPendBackupFileMsg;
begin
    // 命令
  PcAddDownPendBackupFileMsg := TPcAddDownPendBackupFileMsg.Create;
  PcAddDownPendBackupFileMsg.SetPcID( PcInfo.PcID );
  PcAddDownPendBackupFileMsg.SetFileInfo( 0, FileSize );
  PcAddDownPendBackupFileMsg.SetUpFilePath( FilePath );

  MyClient.SendMsgToPc( PcID, PcAddDownPendBackupFileMsg );
end;

constructor TBackupJobAdd.Create(_PcID, _FilePath: string);
begin
  PcID := _PcID;
  FilePath := _FilePath;
end;

procedure TBackupJobAdd.SetFileInfo(_FileSize: Int64; _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupJobAdd.Update;
begin
    // Pc 已离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
    Exit;

    // Pc Name
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

    // 通知 目标 Pc
  AddToDestinationPc;

    // 添加 Copy 信息
  AddToBackupCopy;

    // 添加 Backup Job
  AddToBackupJob;
end;

{ TBackupJobScanThread }

procedure TBackupJobScanThread.AddScanInfo(ScanInfo: TBackupJobScanInfo);
begin
  Lock.Enter;
  BackupJobScanList.Add( ScanInfo );
  Lock.Leave;

  Resume;
end;

constructor TBackupJobScanThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  BackupJobScanList := TBackupJobScanList.Create;
  BackupJobScanList.OwnsObjects := False;
end;

destructor TBackupJobScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  BackupJobScanList.OwnsObjects := True;
  BackupJobScanList.Free;
  Lock.Free;

  inherited;
end;

procedure TBackupJobScanThread.Execute;
var
  BackupJobScanInfo : TBackupJobScanInfo;
begin
  while not Terminated do
  begin
    BackupJobScanInfo := getNextScanInfo;

      // 已备份所有路径
    if BackupJobScanInfo = nil then
    begin
      ScanCompleted;
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 扫描文件 或 目录
    ScanJobHandle( BackupJobScanInfo );

    BackupJobScanInfo.Free;
  end;

  inherited;
end;

function TBackupJobScanThread.getNextScanInfo: TBackupJobScanInfo;
begin
  Lock.Enter;
  if BackupJobScanList.Count > 0 then
  begin
    Result := BackupJobScanList[0];
    BackupJobScanList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TBackupJobScanThread.ScanCompleted;
var
  BackupTvBackupStopInfo : TBackupTvBackupStopInfo;
begin
    // 通知界面 备份完成
  BackupTvBackupStopInfo := TBackupTvBackupStopInfo.Create;
  MyBackupFileFace.AddChange( BackupTvBackupStopInfo );

    // 更新 云信息
  MyClient.UpgradeCloudInfo;
end;

procedure TBackupJobScanThread.ScanJobHandle(ScanInfo : TBackupJobScanInfo);
var
  BackupJobScanHandle : TBackupJobScanHandle;
begin
  BackupJobScanHandle := TBackupJobScanHandle.Create( ScanInfo );
  BackupJobScanHandle.Update;
  BackupJobScanHandle.Free;
end;

{ TMyBackupJobScanInfo }

procedure TMyBackupJobScanInfo.AddScanPath(BackupJobScanInfo : TBackupJobScanInfo);
begin
  if not IsRun then
    Exit;

  BackupJobScanThread.AddScanInfo( BackupJobScanInfo );
end;

constructor TMyBackupJobScanInfo.Create;
begin
  IsRun := True;
  BackupJobScanThread := TBackupJobScanThread.Create;
end;

procedure TMyBackupJobScanInfo.StopJobScan;
begin
  IsRun := False;
  BackupJobScanThread.Free;
end;


{ TTempBackupPathOwnerInfo }

constructor TTempBackupPathOwnerInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  OwnerSpace := 0;
  OwnerFileCount := 0;
end;

{ TBackupPathScanJobHandle }

constructor TBackupPathJobScanner.Create;
begin
  TempPcSpaceList := TTempPcSpaceList.Create;
end;

destructor TBackupPathJobScanner.Destroy;
begin
  TempPcSpaceList.Free;
  inherited;
end;

procedure TBackupPathJobScanner.FindTempPcSpaceList;
var
  FindTempPcSpace : TFindTempPcSpace;
begin
  TempPcSpaceList.Clear;

  FindTempPcSpace := TFindTempPcSpace.Create( TempPcSpaceList );
  FindTempPcSpace.Update;
  FindTempPcSpace.Free;
end;

procedure TBackupPathJobScanner.ResetPcSpaceList;
var
  ResetPcSpace : TResetPcSpace;
begin
  ResetPcSpace := TResetPcSpace.Create( TempPcSpaceList );
  ResetPcSpace.Update;
  ResetPcSpace.Free;
end;

procedure TBackupPathJobScanner.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TBackupPathJobScanner.Update;
begin
    // 不能备份, 路径为 Disable 的情况
  if not MyBackupPathInfoUtil.ReadIsEnable( ScanPath ) then
    Exit;

    // 读取 网络 Pc 可用空间
  FindTempPcSpaceList;

    // 读取 备份路径 Copy 数
  CopyCount := MyBackupPathInfoUtil.ReadPresetCopyCount( ScanPath );

    // 扫描 备份文件
  BackupJobScan;

    // 重置 网络 Pc 可用空间
  ResetPcSpaceList;
end;

{ TResetPcSpace }

constructor TResetPcSpace.Create(_TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

procedure TResetPcSpace.Update;
var
  NetPcInfoHash : TNetPcInfoHash;
  i : Integer;
  PcID : string;
  OldAvalableSpace, PcAvailableSpace : Int64;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for i := 0 to TempPcSpaceList.Count - 1 do
  begin
    PcID := TempPcSpaceList[i].PcID;
    if NetPcInfoHash.ContainsKey( PcID ) then
    begin
      OldAvalableSpace := NetPcInfoHash[ PcID ].TotalSpace - NetPcInfoHash[ PcID ].UsedSpace;
      PcAvailableSpace := Min( OldAvalableSpace, TempPcSpaceList[i].AvailableSpace );
      NetPcInfoHash[ PcID ].UsedSpace := Max( NetPcInfoHash[ PcID ].TotalSpace - PcAvailableSpace, 0 );
    end;
  end;
  MyNetPcInfo.LeaveData;
end;

procedure TTempPcSpace.SetSpaceInfo(_AvailableSpace, _ComsumpSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
  ComsumpSpace := _ComsumpSpace;
end;

{ TBackupJobScanner }

procedure TBackupJobScanner.BackupJobAddHandle(PcID: string;
  FileInfo: TTempBackupFileInfo);
var
  FileSize: Int64;
  FileTime: TDateTime;
  FilePath : string;
  BackupJobAdd : TBackupJobAdd;
begin
  FilePath := getFilePath( FileInfo.FileName );
  FileSize := FileInfo.FileSize;
  FileTime := FileInfo.LastWriteTime;

    // 添加 Job
  BackupJobAdd := TBackupJobAdd.Create( PcID, FilePath );
  BackupJobAdd.SetFileInfo( FileSize, FileTime );
  BackupJobAdd.Update;
  BackupJobAdd.Free;
end;

procedure TBackupJobScanner.CheckFileJob(FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  NeedBackupCount, i, j : Integer;
  TempPcSpace : TTempPcSpace;
  PcID : string;
  AddedHash : TStringHash;
  IsWriteNotEnough : Boolean;
begin
    // 把未上线的副本启动上线
  CheckOfflineJob( FileInfo );

  CopyHash := FileInfo.TempCopyHash;
  NeedBackupCount := CopyCount - CopyHash.Count;

    // 不需要备份该文件
  if NeedBackupCount <= 0 then
    Exit;

  IsWriteNotEnough := False;
  TempPcSpaceList.SortSpace;  // 根据剩余空间，大到小排序
  AddedHash := TStringHash.Create;   // 已分配的 Pc 列表
  for i := 0 to NeedBackupCount - 1 do  // 为需要备份的文件备份
    for j := 0 to TempPcSpaceList.Count - 1 do  // 按空间优先分配
    begin
      TempPcSpace := TempPcSpaceList[j];
      PcID := TempPcSpace.PcID;

        // Pc 已经分配了
      if CopyHash.ContainsKey( PcID ) or AddedHash.ContainsKey( PcID ) then
        Continue;

        // 空间不足 或者 离线
      if TempPcSpace.AvailableSpace < FileInfo.FileSize then
        Continue;

        // 分配
      AddedHash.AddString( PcID );
      TempPcSpace.AvailableSpace := TempPcSpace.AvailableSpace - FileInfo.FileSize; // 空间减少
      TempPcSpace.ComsumpSpace := TempPcSpace.ComsumpSpace + FileInfo.FileSize; // 占用空间增多
      BackupJobAddHandle( PcID, FileInfo ); // 调用接口
      Break;
    end;

    // Pc 不足
  IsNotEnoughPc := IsNotEnoughPc or IsWriteNotEnough or
                  ( AddedHash.Count < NeedBackupCount );
  AddedHash.Free;
end;

procedure TBackupJobScanner.CheckOfflineJob(FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  p : TTempCopyPair;
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  CopyHash := FileInfo.TempCopyHash;
  for p in CopyHash do
  begin
    if p.Value.Status <> CopyStatus_Offline then
      Continue;
    if not MyNetPcInfoReadUtil.ReadIsOnline( p.Value.CopyOwner ) then
      Continue;

      // 把未启动的 Job 启动
    TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
    TransferJobOnlineInfo.SetOnlinePcID( p.Value.CopyOwner );
    TransferJobOnlineInfo.SetJobType( JobType_Backup );
    MyJobInfo.AddChange( TransferJobOnlineInfo );
  end;
end;

function TBackupJobScanner.getFilePath(FileName: string): string;
begin
  Result := MyFilePath.getPath( ScanPath ) + FileName;
end;

procedure TBackupJobScanner.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupJobScanner.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TBackupJobScanner.SetTempPcSpaceList(
  _TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

{ TBackupFileJobScanner }

function TBackupFileJobScanner.getFilePath(FileName: string): string;
begin
  Result := ScanPath;
end;

procedure TBackupFileJobScanner.Update;
var
  TempBackupFileInfo : TTempBackupFileInfo;
begin
    // 读 备份文件 缓存信息
  TempBackupFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileInfo( ScanPath );

    // 文件不存在
  if TempBackupFileInfo = nil then
    Exit;

    // 检测文件的 Job
  CheckFileJob( TempBackupFileInfo );

  TempBackupFileInfo.Free;
end;

{ TBackupJobScanInfo }

constructor TBackupJobScanInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRootPathJobScanner }

procedure TRootPathJobScanner.AddBackupBoard;
var
  BackupItemStatusAddInfo : TBackupItemStatusAddInfo;
begin
  BackupItemStatusAddInfo := TBackupItemStatusAddInfo.Create( BackupItemStatusType_Analysing );
  BackupItemStatusAddInfo.SetFullPath( ScanPath );
  MyBackupBoardInfo.AddChange( BackupItemStatusAddInfo );
end;

procedure TRootPathJobScanner.BackupJobScan;
var
  BackupRootJobScanner : TBackupRootJobScanner;
begin
    // 搜索 Job
  if FileExists( ScanPath ) then
    BackupRootJobScanner := TBackupRootFileJobScanner.Create
  else
    BackupRootJobScanner := TBackupRootFolderJobScanner.Create;
  BackupRootJobScanner.SetScanPath( ScanPath );
  BackupRootJobScanner.SetCopyCount( CopyCount );
  BackupRootJobScanner.SetTempPcSpaceList( TempPcSpaceList );
  BackupRootJobScanner.SetBackupPathOwnerHash( BackupPathOwnerHash );
  BackupRootJobScanner.Update;
  IsNotEnouthPc := BackupRootJobScanner.IsNotEnoughPc;
  CompletedSpace := BackupRootJobScanner.CompletedSpace;
  BackupRootJobScanner.Free;
end;

constructor TRootPathJobScanner.Create;
begin
  inherited;
  BackupPathOwnerHash := TTempBackupPathOwnerHash.Create;
  IsNotEnouthPc := False;
end;

destructor TRootPathJobScanner.Destroy;
begin
  BackupPathOwnerHash.Free;
  inherited;
end;

procedure TRootPathJobScanner.BackupSelectRefresh;
var
  BackupSelectRefreshHandle : TBackupSelectRefreshHandle;
begin
  BackupSelectRefreshHandle := TBackupSelectRefreshHandle.Create( ScanPath );
  BackupSelectRefreshHandle.Update;
  BackupSelectRefreshHandle.Free;
end;

procedure TRootPathJobScanner.RemoveBackupBoard;
var
  BackupItemStatusRemoveInfo : TBackupItemStatusRemoveInfo;
begin
  BackupItemStatusRemoveInfo := TBackupItemStatusRemoveInfo.Create( BackupItemStatusType_Analysing );
  MyBackupBoardInfo.AddChange( BackupItemStatusRemoveInfo );
end;

procedure TRootPathJobScanner.ResetBackupPathOwner;
var
  BackupPathOwnerClearHandle : TBackupPathOwnerClearHandle;
  p : TTempBackupPathOwnerPair;
  BackupPathOwnerSetSpaceHandle : TBackupPathOwnerSetSpaceHandle;
begin
    // 清空 路径拥有者 信息
  BackupPathOwnerClearHandle := TBackupPathOwnerClearHandle.Create( ScanPath );
  BackupPathOwnerClearHandle.Update;
  BackupPathOwnerClearHandle.Free;

    // 重新设置 路径拥有者 信息
  for p in BackupPathOwnerHash do
  begin
    BackupPathOwnerSetSpaceHandle := TBackupPathOwnerSetSpaceHandle.Create( ScanPath );
    BackupPathOwnerSetSpaceHandle.SetPcID( p.Value.PcID );
    BackupPathOwnerSetSpaceHandle.SetSpaceInfo( p.Value.OwnerSpace, p.Value.OwnerFileCount );
    BackupPathOwnerSetSpaceHandle.Update;
    BackupPathOwnerSetSpaceHandle.Free;
  end;
end;

procedure TRootPathJobScanner.ResetCompletedSpace;
var
  BackupPathSetCompletedSpaceHandle : TBackupPathSetCompletedSpaceHandle;
begin
  BackupPathSetCompletedSpaceHandle := TBackupPathSetCompletedSpaceHandle.Create( ScanPath );
  BackupPathSetCompletedSpaceHandle.SetCompletedSpace( CompletedSpace );
  BackupPathSetCompletedSpaceHandle.Update;
  BackupPathSetCompletedSpaceHandle.Free;
end;

procedure TRootPathJobScanner.ResetNotEnoughPcBackup;
var
  BackupPathSetIsNotEnoughPcHandle : TBackupPathSetIsNotEnoughPcHandle;
begin
  BackupPathSetIsNotEnoughPcHandle := TBackupPathSetIsNotEnoughPcHandle.Create( ScanPath );
  BackupPathSetIsNotEnoughPcHandle.SetIsNotEnoughPc( IsNotEnouthPc );
  BackupPathSetIsNotEnoughPcHandle.Update;
  BackupPathSetIsNotEnoughPcHandle.Free;
end;

procedure TRootPathJobScanner.Update;
begin
    // 显示 正在分配 Job
  AddBackupBoard;

  inherited;

    // 重设 路径拥有者
  ResetBackupPathOwner;

    // 是否 不足计算机 备份
  ResetNotEnoughPcBackup;

    // 重设 路径完成信息
  ResetCompletedSpace;

    // 刷新 选择的节点
  BackupSelectRefresh;

    // 隐藏 显示 分配 Job
  RemoveBackupBoard;
end;

{ TBackupRootFolderJobScanner }

procedure TBackupRootJobScanner.AddBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Analysing );
  BackupItemStatusFileCountInfo.SetFileCount( TotalFileCount );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

procedure TBackupRootJobScanner.CheckBackupPathOwner(
  FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  pc : TTempCopyPair;
  PcID : string;
  FileSize : Int64;
  FileCopy : Integer;
begin
  FileCopy := 0;
  FileSize := FileInfo.FileSize;
  CopyHash := FileInfo.TempCopyHash;
  for pc in CopyHash do
  begin
      // 非已下载
    if pc.Value.Status <> CopyStatus_Loaded then
      Continue;

      // 统计目录完成空间
    Inc( FileCopy );
    if FileCopy <= CopyCount then
      CompletedSpace := CompletedSpace + FileSize;

      // 增加 Pc 的备份空间
    PcID := pc.Value.CopyOwner;
    if not BackupPathOwnerHash.ContainsKey( PcID ) then
      BackupPathOwnerHash.AddOrSetValue( PcID, TTempBackupPathOwnerInfo.Create( PcID ) );
    BackupPathOwnerHash[ PcID ].OwnerSpace := BackupPathOwnerHash[ PcID ].OwnerSpace + FileSize;
    BackupPathOwnerHash[ PcID ].OwnerFileCount := BackupPathOwnerHash[ PcID ].OwnerFileCount + 1;
  end;
end;

procedure TBackupRootJobScanner.CheckFileJob(
  FileInfo: TTempBackupFileInfo);
begin
  CheckLoadedJob( FileInfo );

  inherited;

  CheckBackupPathOwner( FileInfo );
end;

procedure TBackupRootJobScanner.CheckLoadedJob(
  FileInfo: TTempBackupFileInfo);
var
  FilePath : string;
  CopyHash : TTempCopyHash;
  p : TTempCopyPair;
  ConfirmFileInfo : TConfirmFileInfo;
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  FilePath := getFilePath( FileInfo.FileName );

  CopyHash := FileInfo.TempCopyHash;
  for p in CopyHash do
  begin
    if p.Value.Status <> CopyStatus_Loaded then
      Continue;
    if not MyNetPcInfoReadUtil.ReadIsOnline( p.Value.CopyOwner ) then
      Continue;

    ConfirmFileInfo := TConfirmFileInfo.Create;
    ConfirmFileInfo.SetFileBaseInfo( FileInfo );
    ConfirmFileInfo.SetFileName( FilePath );
    MyFileConfirm.AddBackupFileConfirm( p.Value.CopyOwner, ConfirmFileInfo );
  end;
end;

function TBackupRootJobScanner.CheckNextSearch: Boolean;
begin
  AddBackupBoardFileCount;

  Result := inherited;
end;

constructor TBackupRootJobScanner.Create;
begin
  inherited;
  IsNotEnoughPc := False;
  CompletedSpace := 0;
end;

function TBackupRootJobScanner.getFolderJobScan: TBackupFolderJobScanner;
var
  BackupRootFolderJobScanner : TBackupRootJobScanner;
begin
  BackupRootFolderJobScanner := TBackupRootJobScanner.Create;
  BackupRootFolderJobScanner.SetBackupPathOwnerHash( BackupPathOwnerHash );
  Result := BackupRootFolderJobScanner;
end;

procedure TBackupRootJobScanner.ReadLastCompletedSpace;
begin
  LastCompletedSpace := MyBackupFolderInfoUtil.ReadCompletedSpace( ScanPath );
end;

procedure TBackupRootJobScanner.ResetAnalyzingStatus;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Analyzing );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TBackupRootJobScanner.ResetFolderJobScan(
  FolderJobScan: TBackupFolderJobScanner);
var
  BackupRootFolderJobScanner : TBackupRootJobScanner;
begin
  BackupRootFolderJobScanner := FolderJobScan as TBackupRootJobScanner;
  CompletedSpace := CompletedSpace + BackupRootFolderJobScanner.CompletedSpace;
end;

procedure TBackupRootJobScanner.ResetStopStatus;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TBackupRootJobScanner.SetBackupPathOwnerHash(
  _BackupPathOwnerHash: TTempBackupPathOwnerHash);
begin
  BackupPathOwnerHash := _BackupPathOwnerHash;
end;

procedure TBackupRootJobScanner.SetCompletedSpace;
var
  BackupFolderSetCompletedSpaceHanlde : TBackupFolderSetCompletedSpaceHanlde;
begin
  BackupFolderSetCompletedSpaceHanlde := TBackupFolderSetCompletedSpaceHanlde.Create( ScanPath );
  BackupFolderSetCompletedSpaceHanlde.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceHanlde.SetCompletedSpace( CompletedSpace );
  BackupFolderSetCompletedSpaceHanlde.Update;
  BackupFolderSetCompletedSpaceHanlde.Free;
end;

procedure TBackupRootJobScanner.Update;
begin
    // 显示 目录正在 Analyzing
  ResetAnalyzingStatus;

    // 读取 上一次 已完成空间 信息
  ReadLastCompletedSpace;

  inherited;

    // 设置 已完成空间 信息
  SetCompletedSpace;

    // 隐藏 显示
  ResetStopStatus;
end;

{ TBackupChildFolderJobFolderScanner }

function TBackupChildFolderJobFolderScanner.getFolderJobScan: TBackupFolderJobScanner;
begin
  Result := TBackupChildFolderJobFolderScanner.Create;
end;

{ TChildPathJobScanner }

procedure TChildPathJobScanner.BackupJobScan;
var
  BackupJobScanner : TBackupJobScanner;
begin
  if FileExists( ScanPath ) then
    BackupJobScanner := TBackupFileJobScanner.Create
  else
    BackupJobScanner := TBackupChildFolderJobFolderScanner.Create;
  BackupJobScanner.SetScanPath( ScanPath );
  BackupJobScanner.SetCopyCount( CopyCount );
  BackupJobScanner.SetTempPcSpaceList( TempPcSpaceList );
  BackupJobScanner.Update;
  BackupJobScanner.Free;
end;

{ TBackupJobScanHandle }

constructor TBackupJobScanHandle.Create(_BackupJobScanInfo: TBackupJobScanInfo);
begin
  BackupJobScanInfo := _BackupJobScanInfo;
  ScanPath := BackupJobScanInfo.FullPath;
end;

procedure TBackupJobScanHandle.Update;
var
  BackupPathJobScanner : TBackupPathJobScanner;
begin
    // 文件确认
  if ScanPath = BackupFileScanType_FileConfirm then
  begin
    MyFileConfirm.StartConfirm;
    Exit;
  end;

    // 扫描路径的类型
    // 根路径 或者 非根路径
  if MyBackupPathInfoUtil.ReadIsRootPath( ScanPath ) then
    BackupPathJobScanner := TRootPathJobScanner.Create
  else
    BackupPathJobScanner := TChildPathJobScanner.Create;
  BackupPathJobScanner.SetScanPath( ScanPath );
  BackupPathJobScanner.Update;
  BackupPathJobScanner.Free;
end;

{ TBackupRootFileJobScanner }

function TBackupRootFileJobScanner.getFilePath(FileName: string): string;
begin
  Result := ScanPath;
end;

end.

