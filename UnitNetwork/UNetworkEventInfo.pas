unit UNetworkEventInfo;

interface

type

    // 父类
  TNetworkPcEventBase = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 添加
  TNetworkPcAddEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToCloud;
  end;

    // 上线
  TNetworkPcOnlineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToRestore;
    procedure SetToCloud;
  end;

    // 离线
  TNetworkPcOfflineEvent = class( TNetworkPcEventBase )
  public
    procedure Update;
  private
    procedure SetToBackup;
    procedure SetToRestore;
  end;

    // 事件调用器
  NetworkPcEvent = class
  public
    class procedure AddPc( PcID : string );
    class procedure PcOnline( PcID : string );
    class procedure PcOffline( PcID : string );
  end;

implementation

uses UMyBackupApiInfo, UMyCloudApiInfo, UMyRestoreApiInfo;

{ NetworkPcEvent }

class procedure NetworkPcEvent.AddPc(PcID: string);
var
  NetworkPcAddEvent : TNetworkPcAddEvent;
begin
  NetworkPcAddEvent := TNetworkPcAddEvent.Create( PcID );
  NetworkPcAddEvent.Update;
  NetworkPcAddEvent.Free;
end;

class procedure NetworkPcEvent.PcOffline(PcID: string);
var
  NetworkPcOfflineEvent : TNetworkPcOfflineEvent;
begin
  NetworkPcOfflineEvent := TNetworkPcOfflineEvent.Create( PcID );
  NetworkPcOfflineEvent.Update;
  NetworkPcOfflineEvent.Free;
end;


class procedure NetworkPcEvent.PcOnline(PcID: string);
var
  NetworkPcOnlineEvent : TNetworkPcOnlineEvent;
begin
  NetworkPcOnlineEvent := TNetworkPcOnlineEvent.Create( PcID );
  NetworkPcOnlineEvent.Update;
  NetworkPcOnlineEvent.Free;
end;

{ TNetworkPcEventBase }

constructor TNetworkPcEventBase.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TNetworkPcAddEvent }

procedure TNetworkPcAddEvent.SetToBackup;
begin
  DesItemAppApi.AddNetworkItem( PcID );
end;

procedure TNetworkPcAddEvent.SetToCloud;
begin
  MyCloudAppApi.AddPcItem( PcID );
end;

procedure TNetworkPcAddEvent.Update;
begin
  SetToBackup;
  SetToCloud;
end;

{ TNetworkPcOnlineEvent }

procedure TNetworkPcOnlineEvent.SetToBackup;
begin
//  DesItemAppApi.OnlineDesItem( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToCloud;
begin
  MyCloudAppApi.PcOnline( PcID );
end;

procedure TNetworkPcOnlineEvent.SetToRestore;
begin
  NetworkRestoreAppApi.AddRestorePc( PcID );
end;

procedure TNetworkPcOnlineEvent.Update;
begin
  SetToBackup;
  SetToRestore;
  SetToCloud;
end;

{ TNetworkPcAOfflineEvent }

procedure TNetworkPcOfflineEvent.SetToBackup;
begin
//  NetworkBackupAppApi.OfflineDesItem( PcID );
end;

procedure TNetworkPcOfflineEvent.SetToRestore;
begin
  NetworkRestoreAppApi.RemoveRestorePc( PcID );
end;

procedure TNetworkPcOfflineEvent.Update;
begin
  SetToBackup;
  SetToRestore;
end;

end.
