unit UMyCloudEventInfo;

interface

type

    // 云备份事件
  TMyCloudChangeEvent = class
  public
    PcID, BackupPath : string;
  public
    constructor Create( _PcID, _BackupPath : string );
  end;

    // 添加
  TMyCloudAddEvent = class( TMyCloudChangeEvent )
  public
    IsFile : Boolean;
    FileCount : Integer;
    FileSpace : Int64;
  public
    LastDateTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSpace : Int64 );
    procedure SetLastDateTime( _LastDateTime : TDateTime );
    procedure Update;
  private
    procedure SendToAllPc;
  end;

    // 删除
  TMyCloudRemoveEvent = class( TMyCloudChangeEvent )
  public
    procedure Update;
  private
    procedure SendToAllPc;
  end;

  TCloudAddEventParam = record
  public
    PcID, BackupPath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpace : Int64;
    LastDateTime : TDateTime;
  end;

    // 云备份事件
  MyCloudEventInfo = class
  public
    class procedure AddCloudItem( Params : TCloudAddEventParam );
    class procedure RemoveCloudItem( PcID, BackupPath : string );
  end;

implementation

uses UMyClient, UMyNetPcInfo;

{ MyCloudEventInfo }

class procedure MyCloudEventInfo.AddCloudItem(Params : TCloudAddEventParam);
var
  MyCloudAddEvent : TMyCloudAddEvent;
begin
  MyCloudAddEvent := TMyCloudAddEvent.Create( Params.PcID, Params.BackupPath );
  MyCloudAddEvent.SetIsFile( Params.IsFile );
  MyCloudAddEvent.SetSpaceInfo( Params.FileCount, Params.FileSpace );
  MyCloudAddEvent.SetLastDateTime( Params.LastDateTime );
  MyCloudAddEvent.Update;
  MyCloudAddEvent.Free;
end;

class procedure MyCloudEventInfo.RemoveCloudItem(PcID, BackupPath: string);
var
  MyCloudRemoveEvent : TMyCloudRemoveEvent;
begin
  MyCloudRemoveEvent := TMyCloudRemoveEvent.Create( PcID, BackupPath );
  MyCloudRemoveEvent.Update;
  MyCloudRemoveEvent.Free;
end;

{ TMyCloudChangeEvent }

constructor TMyCloudChangeEvent.Create(_PcID, _BackupPath: string);
begin
  PcID := _PcID;
  BackupPath := _BackupPath;
end;

{ TMyCloudAddEvent }

procedure TMyCloudAddEvent.SendToAllPc;
var
  OwnerName : string;
  CloudBackupAddRestoreMsg : TCloudBackupAddRestoreMsg;
begin
  OwnerName := MyNetPcInfoReadUtil.ReadName( PcID );

  CloudBackupAddRestoreMsg := TCloudBackupAddRestoreMsg.Create;
  CloudBackupAddRestoreMsg.SetPcID( PcInfo.PcID );
  CloudBackupAddRestoreMsg.SetBackupPath( BackupPath );
  CloudBackupAddRestoreMsg.SetIsFile( IsFile );
  CloudBackupAddRestoreMsg.SetOwnerInfo( PcID, OwnerName );
  CloudBackupAddRestoreMsg.SetSpaceInfo( FileCount, FileSpace );
  CloudBackupAddRestoreMsg.SetLastBackupTime( LastDateTime );
  MyClient.SendMsgToAll( CloudBackupAddRestoreMsg );
end;

procedure TMyCloudAddEvent.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TMyCloudAddEvent.SetLastDateTime(_LastDateTime: TDateTime);
begin
  LastDateTime := _LastDateTime;
end;

procedure TMyCloudAddEvent.SetSpaceInfo(_FileCount: Integer; _FileSpace: Int64);
begin
  FileCount := _FileCount;
  FileSpace := _FileSpace;
end;

procedure TMyCloudAddEvent.Update;
begin
  SendToAllPc;
end;

{ TMyCloudRemoveEvent }

procedure TMyCloudRemoveEvent.SendToAllPc;
var
  CloudBackupRemoveRestoreMsg : TCloudBackupRemoveRestoreMsg;
begin
  CloudBackupRemoveRestoreMsg := TCloudBackupRemoveRestoreMsg.Create;
  CloudBackupRemoveRestoreMsg.SetPcID( PcInfo.PcID );
  CloudBackupRemoveRestoreMsg.SetOwnerID( PcID );
  CloudBackupRemoveRestoreMsg.SetBackupPath( BackupPath );
  MyClient.SendMsgToAll( CloudBackupRemoveRestoreMsg );
end;

procedure TMyCloudRemoveEvent.Update;
begin
  SendToAllPc;
end;

end.
