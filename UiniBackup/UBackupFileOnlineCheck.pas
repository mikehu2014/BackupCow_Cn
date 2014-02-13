unit UBackupFileOnlineCheck;

interface

uses classes, SysUtils, UModelUtil, UFileBaseInfo, UMyUtil, SyncObjs, uDebug;

type

    // 递归 目录的 过期文件
  TFindBackupFileOnlineCheck = class
  private
    OnlinePcIDHash : TStringHash;
  private
    FullPath : string;
    TempBackupFolderInfo : TTempBackupFolderInfo;
  public
    constructor Create( _FullPath : string );
    procedure SetOnlinePcIDHash( _OnlinePcIDHash : TStringHash );
    procedure Update;
  private
    procedure FindTempBackupFolderInfo;
    procedure CheckFileLostConn;
    procedure CheckFolderLostConn;
    procedure DeleteTempBackupFolderInfo;
  protected
    function CheckNextSearch : Boolean;
    procedure BackupCopyCheck( PcID : string; FileInfo : TTempBackupFileInfo );
  end;

    // 检测处理
  TBackupFileOnlineCheckHandle = class
  public
    OnlinePcIDHash : TStringHash;
    BackupPathList : TStringList;
  public
    constructor Create;
    procedure Update;
    destructor Destroy; override;
  private
    function FindOnlinePcHash : Boolean;
    procedure FindBackupPathList;
    procedure CheckBackupPathList;
  end;

    // 检测线程
  TBackupFileOnlineCheckThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure CheckHandle;
  end;

    // 检测 上线 Pc 文件
  TMyBackupFileOnlineCheckInfo = class
  public
    IsRun : Boolean;
  public
    Lock : TCriticalSection;
    OnlineCheckPcIDList : TStringList;
  public
    BackupFileOnlineCheckThread : TBackupFileOnlineCheckThread;
  public
    constructor Create;
    procedure StopCheck;
    destructor Destroy; override;
  public
    procedure AddOnlinePc( PcID : string );
    function CheckOnlinePcExist : Boolean;
    procedure FindOnlineCheckPc( OnlinePcIDHash : TStringHash );
  end;

var
  MyBackupFileOnlineCheckInfo : TMyBackupFileOnlineCheckInfo;

implementation

uses UMyBackupInfo, UMyClient, UMyNetPcInfo;

{ TBackupFileLostConnScan }

procedure TFindBackupFileOnlineCheck.BackupCopyCheck(PcID: string;
  FileInfo : TTempBackupFileInfo);
var
  FileSize : Int64;
  FileTime : TDateTime;
  FilePath : string;
  BackupFileOnlineCheckMsg : TBackupFileOnlineCheckMsg;
begin
    // Pc 已离线
  if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
  begin
    OnlinePcIDHash.Remove( PcID );
    Exit;
  end;

    // 文件信息
  FileSize := FileInfo.FileSize;
  FileTime := FileInfo.LastWriteTime;

    // 文件路径
  if TempBackupFolderInfo is TTempBackupRootFileInfo then
    FilePath := FullPath
  else
    FilePath := MyFilePath.getPath( FullPath ) + FileInfo.FileName;

    // 发送检测命令
  BackupFileOnlineCheckMsg := TBackupFileOnlineCheckMsg.Create;
  BackupFileOnlineCheckMsg.SetPcID( PcInfo.PcID );
  BackupFileOnlineCheckMsg.SetFilePath( FilePath );
  BackupFileOnlineCheckMsg.SetFileInfo( FileSize, FileTime );
  MyClient.SendMsgToPc( PcID, BackupFileOnlineCheckMsg );
end;

procedure TFindBackupFileOnlineCheck.CheckFileLostConn;
var
  FileHash : TTempBackupFileHash;
  p : TTempBackupFilePair;
  pc : TTempCopyPair;
  FilePath : string;
begin
  FileHash := TempBackupFolderInfo.TempBackupFileHash;
  for p in FileHash do
  begin
      // 程序结束
    if not CheckNextSearch then
      Break;

      // 遍历所有 副本信息
    for pc in p.Value.TempCopyHash do
    begin
        // 程序结束
      if not CheckNextSearch then
        Break;

        // 只检测已下载副本
      if pc.Value.Status <> CopyStatus_Loaded then
        Continue;

      if OnlinePcIDHash.ContainsKey( pc.Value.CopyOwner ) then
        BackupCopyCheck( pc.Value.CopyOwner, p.Value );
    end;
  end;
end;

procedure TFindBackupFileOnlineCheck.CheckFolderLostConn;
var
  TempFolderHash : TTempBackupFolderHash;
  p : TTempBackupFolderPair;
  ChildPath : string;
  BackupFileLostConnScan : TFindBackupFileOnlineCheck;
begin
  TempFolderHash := TempBackupFolderInfo.TempBackupFolderHash;
  for p in TempFolderHash do
  begin
    if not CheckNextSearch then
      Break;

    ChildPath := MyFilePath.getPath( FullPath ) + p.Value.FileName;

      // 递归目录
    BackupFileLostConnScan := TFindBackupFileOnlineCheck.Create( ChildPath );
    BackupFileLostConnScan.SetOnlinePcIDHash( OnlinePcIDHash );
    BackupFileLostConnScan.Update;
    BackupFileLostConnScan.Free;
  end;
end;

function TFindBackupFileOnlineCheck.CheckNextSearch: Boolean;
begin
  Sleep(100);

  Result := MyBackupFileOnlineCheckInfo.IsRun and
           ( OnlinePcIDHash.Count > 0 );
end;

constructor TFindBackupFileOnlineCheck.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TFindBackupFileOnlineCheck.DeleteTempBackupFolderInfo;
begin
  TempBackupFolderInfo.Free;
end;

procedure TFindBackupFileOnlineCheck.FindTempBackupFolderInfo;
begin
  TempBackupFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderInfo( FullPath );
end;

procedure TFindBackupFileOnlineCheck.SetOnlinePcIDHash(
  _OnlinePcIDHash: TStringHash);
begin
  OnlinePcIDHash := _OnlinePcIDHash;
end;

procedure TFindBackupFileOnlineCheck.Update;
begin
    // 读取 备份目录 缓存信息
  FindTempBackupFolderInfo;

    // 分配 Job
  CheckFileLostConn;

    // 分配 子目录 Job
  CheckFolderLostConn;

    // 删除 缓存信息
  DeleteTempBackupFolderInfo;
end;


{ TBackupFileOnlineCheckThread }

procedure TBackupFileOnlineCheckThread.CheckHandle;
var
  BackupFileOnlineCheckHandle : TBackupFileOnlineCheckHandle;
begin
  BackupFileOnlineCheckHandle := TBackupFileOnlineCheckHandle.Create;
  BackupFileOnlineCheckHandle.Update;
  BackupFileOnlineCheckHandle.Free;
end;

constructor TBackupFileOnlineCheckThread.Create;
begin
  inherited Create( True )
end;

destructor TBackupFileOnlineCheckThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupFileOnlineCheckThread.Execute;
begin
  while not Terminated do
  begin
      // 不存在 新上线机器
    if not MyBackupFileOnlineCheckInfo.CheckOnlinePcExist then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 程序结束
    if Terminated then
      Break;

      // 检测上线 Pc
    CheckHandle;
  end;

  inherited;
end;

{ TMyBackupFileOnlineCheckInfo }

procedure TMyBackupFileOnlineCheckInfo.AddOnlinePc(PcID: string);
var
  PcIndex : Integer;
begin
  Lock.Enter;
  PcIndex := OnlineCheckPcIDList.IndexOf( PcID );
  if PcIndex < 0 then
    OnlineCheckPcIDList.Add( PcID );
  Lock.Leave;

  BackupFileOnlineCheckThread.Resume;
end;

function TMyBackupFileOnlineCheckInfo.CheckOnlinePcExist: Boolean;
begin
  Lock.Enter;
  Result := OnlineCheckPcIDList.Count > 0;
  Lock.Leave;
end;

constructor TMyBackupFileOnlineCheckInfo.Create;
begin
  IsRun := True;
  Lock := TCriticalSection.Create;
  OnlineCheckPcIDList := TStringList.Create;
  BackupFileOnlineCheckThread := TBackupFileOnlineCheckThread.Create;
end;

destructor TMyBackupFileOnlineCheckInfo.Destroy;
begin
  IsRun := False;
  OnlineCheckPcIDList.Free;
  Lock.Free;
  inherited;
end;

procedure TMyBackupFileOnlineCheckInfo.FindOnlineCheckPc(
  OnlinePcIDHash: TStringHash);
var
  i : Integer;
  PcID : string;
begin
  Lock.Enter;
  for i := 0 to OnlineCheckPcIDList.Count - 1 do
  begin
    PcID := OnlineCheckPcIDList[i];
    OnlinePcIDHash.AddString( PcID );
  end;
  OnlineCheckPcIDList.Clear;
  Lock.Leave;
end;

procedure TMyBackupFileOnlineCheckInfo.StopCheck;
begin
  IsRun := False;
  BackupFileOnlineCheckThread.Free;
end;

{ TBackupFileOnlineCheckHandle }

procedure TBackupFileOnlineCheckHandle.CheckBackupPathList;
var
  i : Integer;
  BackupPath : string;
  FindBackupFileOnlineCheck : TFindBackupFileOnlineCheck;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    FindBackupFileOnlineCheck := TFindBackupFileOnlineCheck.Create( BackupPath );
    FindBackupFileOnlineCheck.SetOnlinePcIDHash( OnlinePcIDHash );
    FindBackupFileOnlineCheck.Update;
    FindBackupFileOnlineCheck.Free;
  end;
end;

constructor TBackupFileOnlineCheckHandle.Create;
begin
  OnlinePcIDHash := TStringHash.Create;
  BackupPathList := TStringList.Create;
end;

destructor TBackupFileOnlineCheckHandle.Destroy;
begin
  BackupPathList.Free;
  OnlinePcIDHash.Free;
  inherited;
end;

procedure TBackupFileOnlineCheckHandle.FindBackupPathList;
var
  FindBackupFullPathInfo : TFindBackupFullPathInfo;
begin
  FindBackupFullPathInfo := TFindBackupFullPathInfo.Create;
  FindBackupFullPathInfo.SetOutput( BackupPathList );
  FindBackupFullPathInfo.Update;
  FindBackupFullPathInfo.Free;
end;

function TBackupFileOnlineCheckHandle.FindOnlinePcHash: Boolean;
begin
  MyBackupFileOnlineCheckInfo.FindOnlineCheckPc( OnlinePcIDHash );
  Result := OnlinePcIDHash.Count > 0;
end;

procedure TBackupFileOnlineCheckHandle.Update;
begin
  if not FindOnlinePcHash then
    Exit;

  FindBackupPathList;

  CheckBackupPathList;
end;

end.
