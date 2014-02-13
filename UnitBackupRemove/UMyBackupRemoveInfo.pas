unit UMyBackupRemoveInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo;

type

{$Region ' ���ݽṹ ' }

    // ɾ���ı���·����Ϣ
  TRemoveBackupPathInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TRemoveBackupPathPair = TPair< string , TRemoveBackupPathInfo >;
  TRemoveBackupPathHash = class(TStringDictionary< TRemoveBackupPathInfo >);


    // ɾ���� Pc �ļ���Ϣ
  TRemoveBackupNofityInfo = class
  public
    PcID : string;
    RemoveBackupPathHash : TRemoveBackupPathHash;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TRemoveBackupNotifyPair = TPair< string , TRemoveBackupNofityInfo >;
  TRemoveBackupNotifyHash = class(TStringDictionary< TRemoveBackupNofityInfo >);

{$EndRegion}

{$Region ' �޸� ' }

    // �޸�
  TRemoveBackupNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveBackupNotifyHash : TRemoveBackupNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // Pc ����
  TRemoveBackupNotifyPcOnlineInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸� ָ��·��
  TRemoveBackupNotifyWriteInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // ���
  TRemoveBackupNotifyAddInfo = class( TRemoveBackupNotifyWriteInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TRemoveBackupNotifyDeleteInfo = class( TRemoveBackupNotifyWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

    // ɾ�� ���� Pc �ı����ļ���Ϣ
  TMyBackupRemoveNotifyInfo = class( TMyDataChange )
  public
    RemoveBackupNotifyHash : TRemoveBackupNotifyHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;


var
  MyBackupRemoveNotifyInfo : TMyBackupRemoveNotifyInfo;


implementation

uses UMyClient, UMyNetPcInfo;

{ TRemovePcFileInfo }

constructor TRemoveBackupNofityInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  RemoveBackupPathHash := TRemoveBackupPathHash.Create;
end;

destructor TRemoveBackupNofityInfo.Destroy;
begin
  RemoveBackupPathHash.Free;
  inherited;
end;

{ TMyBackupFileRemoveInfo }

constructor TMyBackupRemoveNotifyInfo.Create;
begin
  inherited;

  RemoveBackupNotifyHash := TRemoveBackupNotifyHash.Create;
  AddThread(1);
end;

destructor TMyBackupRemoveNotifyInfo.Destroy;
begin
  StopThread;
  RemoveBackupNotifyHash.Free;
  inherited;
end;

{ TRemovePcFileAddInfo }

procedure TRemoveBackupNotifyAddInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
begin
  inherited;

    // ���� Pc ɾ��
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    RemoveBackupNotifyHash.addOrSetValue( PcID, TRemoveBackupNofityInfo.Create( PcID ) );

    // ɾ�� �б�
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then // �Ѵ���
    Exit;

    // ���
  RemoveBackupPathHash.AddOrSetValue( FullPath, TRemoveBackupPathInfo.Create( FullPath ) )
end;

{ TRemovePcFileChangeInfo }

constructor TRemoveBackupNotifyChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRemoveBackupNotifyChangeInfo.Update;
begin
  RemoveBackupNotifyHash := MyBackupRemoveNotifyInfo.RemoveBackupNotifyHash;
end;

{ TRemovePcOnlineInfo }

procedure TRemoveBackupNotifyPcOnlineInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
  p : TRemoveBackupPathPair;
  BackupFileRemoveMsg : TBackupFileRemoveMsg;
begin
  inherited;

    // Pc ������
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;

    // ���� ����ɾ����Ϣ
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  for p in RemoveBackupPathHash do
  begin
    BackupFileRemoveMsg := TBackupFileRemoveMsg.Create;
    BackupFileRemoveMsg.SetPcID( PcInfo.PcID );
    BackupFileRemoveMsg.SetFilePath( p.Value.FullPath );
    MyClient.SendMsgToPc( PcID, BackupFileRemoveMsg );
  end;
end;

{ TRemovePcFileWriteInfo }

procedure TRemoveBackupNotifyWriteInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileRemoveInfo }

procedure TRemoveBackupNotifyDeleteInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
begin
  inherited;

    // Pc ɾ�� ������
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;

    // Pc ɾ���ļ��б�
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then
    RemoveBackupPathHash.Remove( FullPath );

    // Pc �����
  if RemoveBackupPathHash.Count = 0 then
    RemoveBackupNotifyHash.Remove( PcID );
end;


{ TRemoveBackupPathInfo }

constructor TRemoveBackupPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

end.
