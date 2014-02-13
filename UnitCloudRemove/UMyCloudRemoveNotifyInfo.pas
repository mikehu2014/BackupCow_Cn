unit UMyCloudRemoveNotifyInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo;

type

{$Region ' ���ݽṹ ' }

    // ɾ���ı���·����Ϣ
  TRemoveCloudPathInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TRemoveCloudPathPair = TPair< string , TRemoveCloudPathInfo >;
  TRemoveCloudPathHash = class(TStringDictionary< TRemoveCloudPathInfo >);


    // ɾ���� Pc �ļ���Ϣ
  TRemoveCloudNofityInfo = class
  public
    PcID : string;
    RemoveCloudPathHash : TRemoveCloudPathHash;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TRemoveCloudNotifyPair = TPair< string , TRemoveCloudNofityInfo >;
  TRemoveCloudNotifyHash = class(TStringDictionary< TRemoveCloudNofityInfo >);

{$EndRegion}

{$Region ' �޸� ' }

    // �޸�
  TRemoveCloudNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveCloudNotifyHash : TRemoveCloudNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

      // Pc ����
  TRemoveCloudNotifyPcOnlineInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸� ָ��·��
  TRemoveCloudNotifyWriteInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // ���
  TRemoveCloudNotifyAddInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TRemoveCloudNotifyDeleteInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

    // ɾ�� ���� Pc �ı����ļ���Ϣ
  TMyCloudRemoveNotifyInfo = class( TMyDataChange )
  public
    RemoveCloudNotifyHash : TRemoveCloudNotifyHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  MyCloudRemoveNotifyInfo : TMyCloudRemoveNotifyInfo;

implementation

uses UMyClient, UMyNetPcInfo;

{ TRemovePcFileInfo }

constructor TRemoveCloudNofityInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  RemoveCloudPathHash := TRemoveCloudPathHash.Create;
end;

destructor TRemoveCloudNofityInfo.Destroy;
begin
  RemoveCloudPathHash.Free;
  inherited;
end;

{ TMyCloudFileRemoveInfo }

constructor TMyCloudRemoveNotifyInfo.Create;
begin
  inherited;

  RemoveCloudNotifyHash := TRemoveCloudNotifyHash.Create;
  AddThread(1);
end;

destructor TMyCloudRemoveNotifyInfo.Destroy;
begin
  DeleteThread(1);
  RemoveCloudNotifyHash.Free;
  inherited;
end;

{ TRemovePcFileAddInfo }

procedure TRemoveCloudNotifyAddInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    RemoveCloudNotifyHash.addOrSetValue( PcID, TRemoveCloudNofityInfo.Create( PcID ) );

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  if RemoveCloudPathHash.ContainsKey( FullPath ) then
    Exit;

  RemoveCloudPathHash.AddOrSetValue( FullPath, TRemoveCloudPathInfo.Create( FullPath ) )
end;

{ TRemovePcFileChangeInfo }

constructor TRemoveCloudNotifyChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRemoveCloudNotifyChangeInfo.Update;
begin
  RemoveCloudNotifyHash := MyCloudRemoveNotifyInfo.RemoveCloudNotifyHash;
end;

{ TRemovePcOnlineInfo }

procedure TRemoveCloudNotifyPcOnlineInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
  p : TRemoveCloudPathPair;
  CloudFileRemoveMsg : TCloudFileRemoveMsg;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    Exit;

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  for p in RemoveCloudPathHash do
  begin
        // ��������
    CloudFileRemoveMsg := TCloudFileRemoveMsg.Create;
    CloudFileRemoveMsg.SetPcID( PcInfo.PcID );
    CloudFileRemoveMsg.SetFilePath( p.Value.FullPath );
    MyClient.SendMsgToPc( PcID, CloudFileRemoveMsg );
  end;
end;

{ TRemovePcFileWriteInfo }

procedure TRemoveCloudNotifyWriteInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileRemoveInfo }

procedure TRemoveCloudNotifyDeleteInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    Exit;

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  if RemoveCloudPathHash.ContainsKey( FullPath ) then
    RemoveCloudPathHash.Remove( FullPath );

  if RemoveCloudPathHash.Count = 0 then
    RemoveCloudNotifyHash.Remove( PcID );
end;

{ TRemoveCloudPathInfo }

constructor TRemoveCloudPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

end.

