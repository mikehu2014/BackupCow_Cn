unit UBackupFileWatcher;

interface

uses UFileWatcher, UChangeInfo, SysUtils, Classes, UModelUtil, Generics.Collections, SyncObjs, DateUtils;

type

      // 路径是否存在 监听
  TBackupItemExistThread = class( TWatchPathExistThread )
  protected
    procedure WatchPathNotEixst( WatchPath : string );override;
    procedure WatchPathExist( WatchPath : string );override;
  end;

    // 备份文件 变化检测器
  TMyBackupFileWatcher = class
  public
    BackupItemExistThread : TBackupItemExistThread;
  public
    constructor Create;
    procedure StopWatch;
  public
    procedure AddWatchPath( WatchPath : string; IsExist : Boolean );
    procedure RemoveWatchPath( WatchPath : string );
  end;

var
  MyBackupFileWatcher : TMyBackupFileWatcher;

implementation

uses UBackupInfoControl, UMyUtil, UBackupFileScan;

{ TMyBackupFileWatcher }

procedure TMyBackupFileWatcher.AddWatchPath(WatchPath: string;
  IsExist : Boolean);
begin
  BackupItemExistThread.AddWatchPath( WatchPath, IsExist );
end;

constructor TMyBackupFileWatcher.Create;
begin
  BackupItemExistThread := TBackupItemExistThread.Create;
  BackupItemExistThread.Resume;
end;

procedure TMyBackupFileWatcher.RemoveWatchPath(WatchPath: string);
begin
  BackupItemExistThread.RemoveWatchPath( WatchPath );
end;

procedure TMyBackupFileWatcher.StopWatch;
begin
      // 停止检测 备份路径
  BackupItemExistThread.Free;
end;

{ TBackupItemExistThread }

procedure TBackupItemExistThread.WatchPathExist(WatchPath: string);
var
  BackupPathResetExistHandle : TBackupPathSetExistHandle;
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  BackupPathResetExistHandle := TBackupPathSetExistHandle.Create( WatchPath );
  BackupPathResetExistHandle.SetIsExist( True );
  BackupPathResetExistHandle.Update;
  BackupPathResetExistHandle.Free;
end;

procedure TBackupItemExistThread.WatchPathNotEixst(WatchPath: string);
var
  BackupPathResetExistHandle : TBackupPathSetExistHandle;
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  BackupPathResetExistHandle := TBackupPathSetExistHandle.Create( WatchPath );
  BackupPathResetExistHandle.SetIsExist( False );
  BackupPathResetExistHandle.Update;
  BackupPathResetExistHandle.Free;
end;

end.
