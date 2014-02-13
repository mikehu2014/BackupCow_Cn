unit UBackupAutoSyncInfo;

interface

uses classes, DateUtils, SysUtils;

type

    // 检测 同步时间
  TBackupAutoSyncHandle = class
  public
    BackupPathList : TStringList;
  public
    procedure Update;
  private
    procedure RefreshSynTime( BackupPath : string );
    procedure AutoBackup( BackupPath : string );
  end;

    // 等待线程
  TBackupAutoSyncThread = class( TThread )
  private
    IsCheckNow : Boolean;
    LastLocalBackupTime : TDateTime;
  public
    constructor Create;
    procedure CheckNow;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleCheck;
  end;

    // 控制器
  TMyBackupAutoSyncInfo = class
  public
    IsRun : Boolean;
    BackupAutoSyncThread : TBackupAutoSyncThread;
  public
    constructor Create;
    procedure CheckNow;
    procedure StopSync;
  end;

var
  MyBackupAutoSyncInfo : TMyBackupAutoSyncInfo;

implementation

uses UMyBackupInfo, UBackupInfoControl, USettingInfo, ULocalBackupControl, ULocalBackupInfo;

{ TBackupAutoSyncThread }

procedure TBackupAutoSyncThread.CheckNow;
begin
  IsCheckNow := True;
end;

constructor TBackupAutoSyncThread.Create;
begin
  inherited Create;
  LastLocalBackupTime := Now;
end;

destructor TBackupAutoSyncThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupAutoSyncThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    IsCheckNow := False;
    StartTime := Now;
    while not Terminated and not IsCheckNow and
          ( MinutesBetween( Now, StartTime ) < 1 )
    do
      Sleep(100);
    if Terminated then
      Break;

      // 检测 网络备份 同步时间
    HandleCheck;
  end;
  inherited;
end;

procedure TBackupAutoSyncThread.HandleCheck;
var
  BackupAutoSyncHandle : TBackupAutoSyncHandle;
begin
  BackupAutoSyncHandle := TBackupAutoSyncHandle.Create;
  BackupAutoSyncHandle.Update;
  BackupAutoSyncHandle.Free;
end;

{ TBackupAutoSyncHandle }

procedure TBackupAutoSyncHandle.AutoBackup(BackupPath: string);
var
  BackupPathSetLastSyncTimeHandle : TBackupPathSetLastSyncTimeHandle;
  BackupPathScanHandle : TBackupPathScanHandle;
begin
    // 设置上一次 备份时间
  BackupPathSetLastSyncTimeHandle := TBackupPathSetLastSyncTimeHandle.Create( BackupPath );
  BackupPathSetLastSyncTimeHandle.SetLastSyncTime( Now );
  BackupPathSetLastSyncTimeHandle.Update;
  BackupPathSetLastSyncTimeHandle.Free;

    // 开始备份
  BackupPathScanHandle := TBackupPathScanHandle.Create( BackupPath );
  BackupPathScanHandle.SetIsShowFreeLimt( False );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TBackupAutoSyncHandle.RefreshSynTime(BackupPath: string);
var
  BackupPathRefreshLastSyncTimeHandle : TBackupPathRefreshLastSyncTimeHandle;
begin
  BackupPathRefreshLastSyncTimeHandle := TBackupPathRefreshLastSyncTimeHandle.Create( BackupPath );
  BackupPathRefreshLastSyncTimeHandle.Update;
  BackupPathRefreshLastSyncTimeHandle.Free;
end;

procedure TBackupAutoSyncHandle.Update;
var
  i : Integer;
  BackupPath : string;
begin
  BackupPathList := MyBackupPathInfoUtil.ReadBackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    if MyBackupPathInfoUtil.ReadIsAutoSyncTimeOut( BackupPath ) then
      AutoBackup( BackupPath )
    else
      RefreshSynTime( BackupPath );
  end;
  BackupPathList.Free;
end;

{ TMyBackupAutoSyncInfo }

procedure TMyBackupAutoSyncInfo.CheckNow;
begin
  if not IsRun then
    Exit;

  BackupAutoSyncThread.CheckNow;
end;

constructor TMyBackupAutoSyncInfo.Create;
begin
  IsRun := True;
  BackupAutoSyncThread := TBackupAutoSyncThread.Create;
  BackupAutoSyncThread.Resume;
end;

procedure TMyBackupAutoSyncInfo.StopSync;
begin
  IsRun := False;
  BackupAutoSyncThread.Free;
end;

end.
