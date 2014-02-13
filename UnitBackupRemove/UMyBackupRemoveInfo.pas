unit UMyBackupRemoveInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo;

type

{$Region ' 数据结构 ' }

    // 删除的备份路径信息
  TRemoveBackupPathInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TRemoveBackupPathPair = TPair< string , TRemoveBackupPathInfo >;
  TRemoveBackupPathHash = class(TStringDictionary< TRemoveBackupPathInfo >);


    // 删除的 Pc 文件信息
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

{$Region ' 修改 ' }

    // 修改
  TRemoveBackupNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveBackupNotifyHash : TRemoveBackupNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // Pc 上线
  TRemoveBackupNotifyPcOnlineInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // 修改 指定路径
  TRemoveBackupNotifyWriteInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // 添加
  TRemoveBackupNotifyAddInfo = class( TRemoveBackupNotifyWriteInfo )
  public
    procedure Update;override;
  end;

    // 删除
  TRemoveBackupNotifyDeleteInfo = class( TRemoveBackupNotifyWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

    // 删除 网络 Pc 的备份文件信息
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

    // 创建 Pc 删除
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    RemoveBackupNotifyHash.addOrSetValue( PcID, TRemoveBackupNofityInfo.Create( PcID ) );

    // 删除 列表
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then // 已存在
    Exit;

    // 添加
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

    // Pc 不存在
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;

    // 遍历 发送删除信息
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

    // Pc 删除 不存在
  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;

    // Pc 删除文件列表
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then
    RemoveBackupPathHash.Remove( FullPath );

    // Pc 已清空
  if RemoveBackupPathHash.Count = 0 then
    RemoveBackupNotifyHash.Remove( PcID );
end;


{ TRemoveBackupPathInfo }

constructor TRemoveBackupPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

end.
