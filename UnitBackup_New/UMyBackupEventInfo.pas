unit UMyBackupEventInfo;

interface

uses SysUtils;

type

  TBackupCompletedEventParam = record
  public
    PcID, SourcePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpce : Int64;
  end;

    // 网络备份 事件
  NetworkBackupEvent = class
  public
    class procedure BackupCompleted( Params : TBackupCompletedEventParam );
    class procedure RemoveBackupItem( PcID, SourcePath : string );
  end;

  TLocalBackupEventParam = record
  public
    DesPath, SourcePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpce : Int64;
  end;

    // 本地备份 事件
  LocalBackupEvent = class
  public
    class procedure AddDesPath( DesPath : string );
    class procedure RemoveDesPath( DesPath : string );
  public
    class procedure BackupCompleted( Params : TLocalBackupEventParam );
    class procedure RemoveBackupItem( DesPath, SourcePath : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo, UMyRestoreApiInfo;

{ NetworkBackupMsgEvent }

class procedure NetworkBackupEvent.BackupCompleted(Params : TBackupCompletedEventParam);
var
  NetworkBackupAddMsg : TNetworkBackupAddCloudMsg;
begin
  NetworkBackupAddMsg := TNetworkBackupAddCloudMsg.Create;
  NetworkBackupAddMsg.SetPcID( PcInfo.PcID );
  NetworkBackupAddMsg.SetBackupPath( Params.SourcePath );
  NetworkBackupAddMsg.SetIsFile( Params.IsFile );
  NetworkBackupAddMsg.SetSpaceInfo( Params.FileCount, Params.FileSpce );
  NetworkBackupAddMsg.SetLastBackupTime( Now );
  MyClient.SendMsgToPc( Params.PcID, NetworkBackupAddMsg );
end;

class procedure NetworkBackupEvent.RemoveBackupItem(PcID,
  SourcePath: string);
var
  NetworkBackupRemoveMsg : TNetworkBackupRemoveCloudMsg;
begin
  NetworkBackupRemoveMsg := TNetworkBackupRemoveCloudMsg.Create;
  NetworkBackupRemoveMsg.SetPcID( PcInfo.PcID );
  NetworkBackupRemoveMsg.SetBackupPath( SourcePath );
  MyClient.SendMsgToPc( PcID, NetworkBackupRemoveMsg );
end;

{ LocalBackupEventInfo }

class procedure LocalBackupEvent.AddDesPath(DesPath: string);
begin
  LocalRestoreAppApi.AddRestoreDes( DesPath );
end;

class procedure LocalBackupEvent.BackupCompleted(
  Params: TLocalBackupEventParam);
var
  RestoreParams : TLocalRestoreAddParams;
begin
  RestoreParams.DesPath := Params.DesPath;
  RestoreParams.BackupPath := Params.SourcePath;
  RestoreParams.IsFile := Params.IsFile;
  RestoreParams.FileCount := Params.FileCount;
  RestoreParams.ItemSize := Params.FileSpce;
  RestoreParams.LastBackupTime := Now;

  LocalRestoreAppApi.AddBackupItem( RestoreParams );
end;

class procedure LocalBackupEvent.RemoveBackupItem(DesPath,
  SourcePath: string);
begin
  LocalRestoreAppApi.RemoveBackupItem( DesPath, SourcePath );
end;

class procedure LocalBackupEvent.RemoveDesPath(DesPath: string);
begin
  LocalRestoreAppApi.RemoveRestoreDes( DesPath );
end;

end.
