unit UMyBackupRemoveControl;

interface

type

    // �޸�
  TBackupRemoveNotifyChangeHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // Pc ����
  TBackupRemoveNotifyPcOnlineHandle = class( TBackupRemoveNotifyChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // �޸� ָ��·��
  TBackupRemoveNotifyWriteHandle = class( TBackupRemoveNotifyChangeHandle )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // ��ȡ
  TBackupRemoveNotifyReadHandle = class( TBackupRemoveNotifyWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure SendToPc;
  end;

    // ���
  TBackupRemoveNotifyAddHandle = class( TBackupRemoveNotifyReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TBackupRemoveNotifyRemoveHandle = class( TBackupRemoveNotifyWriteHandle )
  public
    procedure Update;
  private
    procedure RemoveFromXml;
    procedure RemoveFromInfo;
  end;

implementation

uses UMyNetPcInfo, UMyBackupRemoveInfo, UMyBackupRemoveXml, UMyClient;

{ TBackupRemoveNotifyChangeHandle }

constructor TBackupRemoveNotifyChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TBackupRemoveNotifyReadHandle }

procedure TBackupRemoveNotifyReadHandle.AddToInfo;
var
  RemoveBackupNotifyAddInfo : TRemoveBackupNotifyAddInfo;
begin
  RemoveBackupNotifyAddInfo := TRemoveBackupNotifyAddInfo.Create( PcID );
  RemoveBackupNotifyAddInfo.SetFullPath( FullPath );
  MyBackupRemoveNotifyInfo.AddChange( RemoveBackupNotifyAddInfo );
end;

procedure TBackupRemoveNotifyReadHandle.SendToPc;
var
  BackupFileRemoveMsg : TBackupFileRemoveMsg;
begin
  BackupFileRemoveMsg := TBackupFileRemoveMsg.Create;
  BackupFileRemoveMsg.SetPcID( PcInfo.PcID );
  BackupFileRemoveMsg.SetFilePath( FullPath );
  MyClient.SendMsgToPc( PcID, BackupFileRemoveMsg );
end;

procedure TBackupRemoveNotifyReadHandle.Update;
begin
  AddToInfo;

    // Pc ������֪ͨ Pc
  if MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
    SendToPc;
end;

{ TBackupRemoveNotifyAddHandle }

procedure TBackupRemoveNotifyAddHandle.AddToXml;
var
  RemoveBackupNotifyAddXml : TRemoveBackupNotifyAddXml;
begin
  RemoveBackupNotifyAddXml := TRemoveBackupNotifyAddXml.Create( PcID );
  RemoveBackupNotifyAddXml.SetFullPath( FullPath );
  MyBackupFileRemoveWriteXml.AddChange( RemoveBackupNotifyAddXml );
end;

procedure TBackupRemoveNotifyAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupRemoveNotifyRemoveHandle }

procedure TBackupRemoveNotifyRemoveHandle.RemoveFromInfo;
var
  RemoveBackupNotifyDeleteInfo : TRemoveBackupNotifyDeleteInfo;
begin
  RemoveBackupNotifyDeleteInfo := TRemoveBackupNotifyDeleteInfo.Create( PcID );
  RemoveBackupNotifyDeleteInfo.SetFullPath( FullPath );
  MyBackupRemoveNotifyInfo.AddChange( RemoveBackupNotifyDeleteInfo );
end;

procedure TBackupRemoveNotifyRemoveHandle.RemoveFromXml;
var
  RemoveBackupNotifyDeleteXml : TRemoveBackupNotifyDeleteXml;
begin
  RemoveBackupNotifyDeleteXml := TRemoveBackupNotifyDeleteXml.Create( PcID );
  RemoveBackupNotifyDeleteXml.SetFullPath( FullPath );
  MyBackupFileRemoveWriteXml.AddChange( RemoveBackupNotifyDeleteXml );
end;

procedure TBackupRemoveNotifyRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TBackupRemoveNotifyWriteHandle }

procedure TBackupRemoveNotifyWriteHandle.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TBackupRemoveNotifyPcOnlineHandle }

procedure TBackupRemoveNotifyPcOnlineHandle.SetToInfo;
var
  RemoveBackupNotifyPcOnlineInfo : TRemoveBackupNotifyPcOnlineInfo;
begin
  RemoveBackupNotifyPcOnlineInfo := TRemoveBackupNotifyPcOnlineInfo.Create( PcID );
  MyBackupRemoveNotifyInfo.AddChange( RemoveBackupNotifyPcOnlineInfo );
end;

procedure TBackupRemoveNotifyPcOnlineHandle.Update;
begin
  SetToInfo;
end;

end.
