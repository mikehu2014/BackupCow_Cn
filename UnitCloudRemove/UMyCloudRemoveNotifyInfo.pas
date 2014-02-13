unit UMyCloudRemoveNotifyInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo;

type

{$Region ' 数据结构 ' }

    // 删除的备份路径信息
  TRemoveCloudPathInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TRemoveCloudPathPair = TPair< string , TRemoveCloudPathInfo >;
  TRemoveCloudPathHash = class(TStringDictionary< TRemoveCloudPathInfo >);


    // 删除的 Pc 文件信息
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

{$Region ' 修改 ' }

    // 修改
  TRemoveCloudNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveCloudNotifyHash : TRemoveCloudNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

      // Pc 上线
  TRemoveCloudNotifyPcOnlineInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // 修改 指定路径
  TRemoveCloudNotifyWriteInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // 添加
  TRemoveCloudNotifyAddInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

    // 删除
  TRemoveCloudNotifyDeleteInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

    // 删除 网络 Pc 的备份文件信息
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
        // 发送命令
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

