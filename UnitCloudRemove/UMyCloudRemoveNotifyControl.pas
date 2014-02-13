unit UMyCloudRemoveNotifyControl;

interface

type

    // ����
  TCloudFileRemoveNotifyChangeHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // Pc ����
  TCloudFileRemoveNotifyPcOnlineHandle = class( TCloudFileRemoveNotifyChangeHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // �޸� ·��
  TCloudFileRemoveNotifyWriteHandle = class( TCloudFileRemoveNotifyChangeHandle )
  public
    SourceFilePath : string;
  public
    procedure SetSourceFilePath( _SourceFilePath : string );
  end;

    // ��ȡ
  TCloudFileRemoveNotifyReadHandle = class( TCloudFileRemoveNotifyWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure SendToPc;
  end;

    // ���
  TCloudFileRemoveNotifyAddHandle = class( TCloudFileRemoveNotifyReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TCloudFileRemoveNotifyRemoveHandle = class( TCloudFileRemoveNotifyWriteHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

const
  CloudRemoveNotify_AllBackupItem = 'AllBackupItem';

implementation

uses UMyCloudRemoveNotifyXml, UMyCloudRemoveNotifyInfo, UMyClient, UMyNetPcInfo;

{ TCloudFileRemoveNotifyChangeHandle }

constructor TCloudFileRemoveNotifyChangeHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TCloudFileRemoveNotifyWriteHandle }

procedure TCloudFileRemoveNotifyWriteHandle.SetSourceFilePath(
  _SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TCloudFileRemoveNotifyPcOnlineHandle }

procedure TCloudFileRemoveNotifyPcOnlineHandle.SetToInfo;
var
  RemoveCloudNotifyPcOnlineInfo : TRemoveCloudNotifyPcOnlineInfo;
begin
  RemoveCloudNotifyPcOnlineInfo := TRemoveCloudNotifyPcOnlineInfo.Create( PcID );
  MyCloudRemoveNotifyInfo.AddChange( RemoveCloudNotifyPcOnlineInfo );
end;

procedure TCloudFileRemoveNotifyPcOnlineHandle.Update;
begin
  SetToInfo;
end;

{ TCloudFileRemoveNotifyReadHandle }

procedure TCloudFileRemoveNotifyReadHandle.AddToInfo;
var
  RemoveCloudNotifyAddInfo : TRemoveCloudNotifyAddInfo;
begin
  RemoveCloudNotifyAddInfo := TRemoveCloudNotifyAddInfo.Create( PcID );
  RemoveCloudNotifyAddInfo.SetFullPath( SourceFilePath );
  MyCloudRemoveNotifyInfo.AddChange( RemoveCloudNotifyAddInfo );
end;

procedure TCloudFileRemoveNotifyReadHandle.SendToPc;
var
  CloudFileRemoveMsg : TCloudFileRemoveMsg;
begin
    // ��������
  CloudFileRemoveMsg := TCloudFileRemoveMsg.Create;
  CloudFileRemoveMsg.SetPcID( PcInfo.PcID );
  CloudFileRemoveMsg.SetFilePath( SourceFilePath );
  MyClient.SendMsgToPc( PcID, CloudFileRemoveMsg );
end;

procedure TCloudFileRemoveNotifyReadHandle.Update;
begin
  AddToInfo;

    // Pc ����������֪ͨ
  if MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
    SendToPc;
end;

{ TCloudFileRemoveNotifyAddHandle }

procedure TCloudFileRemoveNotifyAddHandle.AddToXml;
var
  RemoveCloudNotifyAddXml : TRemoveCloudNotifyAddXml;
begin
  RemoveCloudNotifyAddXml := TRemoveCloudNotifyAddXml.Create( PcID );
  RemoveCloudNotifyAddXml.SetFullPath( SourceFilePath );
  MyCloudFileRemoveWriteXml.AddChange( RemoveCloudNotifyAddXml );
end;

procedure TCloudFileRemoveNotifyAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TCloudFileRemoveNotifyRemoveHandle }

procedure TCloudFileRemoveNotifyRemoveHandle.RemoveFromInfo;
var
  RemoveCloudNotifyDeleteInfo : TRemoveCloudNotifyDeleteInfo;
begin
  RemoveCloudNotifyDeleteInfo := TRemoveCloudNotifyDeleteInfo.Create( PcID );
  RemoveCloudNotifyDeleteInfo.SetFullPath( SourceFilePath );
  MyCloudRemoveNotifyInfo.AddChange( RemoveCloudNotifyDeleteInfo );
end;

procedure TCloudFileRemoveNotifyRemoveHandle.RemoveFromXml;
var
  RemoveCloudNotifyDeleteXml : TRemoveCloudNotifyDeleteXml;
begin
  RemoveCloudNotifyDeleteXml := TRemoveCloudNotifyDeleteXml.Create( PcID );
  RemoveCloudNotifyDeleteXml.SetFullPath( SourceFilePath );
  MyCloudFileRemoveWriteXml.AddChange( RemoveCloudNotifyDeleteXml );
end;

procedure TCloudFileRemoveNotifyRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

end.
