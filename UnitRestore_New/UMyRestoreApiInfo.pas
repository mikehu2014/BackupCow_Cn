unit UMyRestoreApiInfo;

interface

type

{$Region ' 恢复文件 ' }

{$Region ' 网络恢复 ' }

  {$Region ' 数据修改 Pc信息 ' }

    // 修改
  TNetworkRestoreDesWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 添加
  TNetworkRestoreDesAddHandle = class( TNetworkRestoreDesWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;


    // 删除
  TNetworkRestoreDesRemoveHandle = class( TNetworkRestoreDesWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

  {$EndRegion}

  {$Region ' 数据修改 备份信息 ' }

    // 修改
  TNetworkRestoreItemWriteHandle = class( TNetworkRestoreDesWriteHandle )
  public
    OwnerID : string;
    BackupPath : string;
  public
    procedure SetOwnerID( _OwnerID : string );
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TNetworkRestoreItemAddHandle = class( TNetworkRestoreItemWriteHandle )
  public
    IsFile : boolean;
  public
    OwnerName : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetOwnerName( _OwnerName : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 删除
  TNetworkRestoreItemRemoveHandle = class( TNetworkRestoreItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

  {$EndRegion}

    // 参数结构
  TNetworkRestoreAddParams = record
  public
    PcID, BackupPath : string;
    OwnerID, OwnerName : string;
    IsFile : Boolean;
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  end;

    // 网络文件恢复
  NetworkRestoreAppApi = class
  public
    class procedure AddRestorePc( PcID : string );
    class procedure RemoveRestorePc( PcID : string );
  public
    class procedure AddBackupItem( Params : TNetworkRestoreAddParams );
    class procedure RemoveBackupItem( PcID, BackupPath, OwnerID : string );
  end;


{$EndRegion}

{$Region ' 本地恢复 ' }

  {$Region ' 数据修改 目标信息 ' }

    // 修改
  TLocalRestoreDesWriteHandle = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
  end;

    // 添加
  TLocalRestoreDesAddHandle = class( TLocalRestoreDesWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;

    // 删除
  TLocalRestoreDesRemoveHandle = class( TLocalRestoreDesWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

  {$EndRegion}

  {$Region ' 数据修改 源信息 ' }

    // 修改
  TLocalRestoreItemWriteHandle = class( TLocalRestoreDesWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TLocalRestoreItemAddHandle = class( TLocalRestoreItemWriteHandle )
  public
    IsFile : boolean;
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 删除
  TLocalRestoreItemRemoveHandle = class( TLocalRestoreItemWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromFace;
  end;

  {$EndRegion}

    // 参数结构
  TLocalRestoreAddParams = record
  public
    DesPath, BackupPath : string;
    IsFile : Boolean;
    FileCount : integer;
    ItemSize : int64;
    LastBackupTime : TDateTime;
  end;


    // 本地文件恢复
  LocalRestoreAppApi = class
  public
    class procedure AddRestoreDes( DesPath : string );
    class procedure RemoveRestoreDes( DesPath : string );
  public
    class procedure AddBackupItem( Params : TLocalRestoreAddParams );
    class procedure RemoveBackupItem( DesPath, BackupPath : string );
  end;

{$EndRegion}

{$EndRegion}

{$Region ' 恢复文件下载 ' }

    // 修改
  TRestoreDownWriteHandle = class
  public
    RestorePath, RestoreOwner : string;
  public
    constructor Create( _RestorePath, _RestoreOwner : string );
  end;

    // 读取
  TRestoreDownReadHandle = class( TRestoreDownWriteHandle )
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetRestoreFrom( _RestoreFrom : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TRestoreDownAddHandle = class( TRestoreDownReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TRestoreDownRemoveHandle = class( TRestoreDownWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;




{$EndRegion}

implementation

uses UMyRestoreFaceInfo, UMyNetPcInfo, UMyRestoreDataInfo, UMyRestoreXmlInfo;

constructor TNetworkRestoreDesWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;

{ TRestorePcReadHandle }

procedure TNetworkRestoreDesAddHandle.AddToFace;
var
  PcName : string;
  RestorePcAddFace : TNetworkRestoreDesAddFace;
begin
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

  RestorePcAddFace := TNetworkRestoreDesAddFace.Create( PcID );
  RestorePcAddFace.SetPcName( PcName );
  RestorePcAddFace.AddChange;
end;

procedure TNetworkRestoreDesAddHandle.Update;
begin
  AddToFace;
end;


{ TRestorePcRemoveHandle }

procedure TNetworkRestoreDesRemoveHandle.RemoveFromFace;
var
  RestorePcRemoveFace : TNetworkRestoreDesRemoveFace;
begin
  RestorePcRemoveFace := TNetworkRestoreDesRemoveFace.Create( PcID );
  RestorePcRemoveFace.AddChange;
end;

procedure TNetworkRestoreDesRemoveHandle.Update;
begin
  RemoveFromFace;
end;

procedure TNetworkRestoreItemWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

{ TRestorePcBackupReadHandle }

procedure TNetworkRestoreItemAddHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TNetworkRestoreItemAddHandle.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TNetworkRestoreItemAddHandle.SetOwnerName( _OwnerName : string );
begin
  OwnerName := _OwnerName;
end;

procedure TNetworkRestoreItemAddHandle.SetSpaceInfo( _FileCount : integer; _FileSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TNetworkRestoreItemAddHandle.AddToFace;
var
  RestorePcBackupAddFace : TNetworkRestoreItemAddFace;
begin
  RestorePcBackupAddFace := TNetworkRestoreItemAddFace.Create( PcID );
  RestorePcBackupAddFace.SetOwnerID( OwnerID );
  RestorePcBackupAddFace.SetBackupPath( BackupPath );
  RestorePcBackupAddFace.SetIsFile( IsFile );
  RestorePcBackupAddFace.SetOwnerName( OwnerName );
  RestorePcBackupAddFace.SetSpaceInfo( FileCount, FileSize );
  RestorePcBackupAddFace.SetLastBackupTime( LastBackupTime );
  RestorePcBackupAddFace.AddChange;
end;

procedure TNetworkRestoreItemAddHandle.Update;
begin
  AddToFace;
end;

{ TRestorePcBackupRemoveHandle }

procedure TNetworkRestoreItemRemoveHandle.RemoveFromFace;
var
  RestorePcBackupRemoveFace : TNetworkRestoreItemRemoveFace;
begin
  RestorePcBackupRemoveFace := TNetworkRestoreItemRemoveFace.Create( PcID );
  RestorePcBackupRemoveFace.SetOwnerID( OwnerID );
  RestorePcBackupRemoveFace.SetBackupPath( BackupPath );
  RestorePcBackupRemoveFace.AddChange;
end;


procedure TNetworkRestoreItemRemoveHandle.Update;
begin
  RemoveFromFace;
end;

{ MyRestoreAppApi }

class procedure NetworkRestoreAppApi.AddBackupItem(Params : TNetworkRestoreAddParams);
var
  NetworkRestoreItemAddHandle : TNetworkRestoreItemAddHandle;
begin
  NetworkRestoreItemAddHandle := TNetworkRestoreItemAddHandle.Create( Params.PcID );
  NetworkRestoreItemAddHandle.SetOwnerID( Params.OwnerID );
  NetworkRestoreItemAddHandle.SetBackupPath( Params.BackupPath );
  NetworkRestoreItemAddHandle.SetIsFile( Params.IsFile );
  NetworkRestoreItemAddHandle.SetOwnerName( Params.OwnerName );
  NetworkRestoreItemAddHandle.SetSpaceInfo( Params.FileCount, Params.ItemSize );
  NetworkRestoreItemAddHandle.SetLastBackupTime( Params.LastBackupTime );
  NetworkRestoreItemAddHandle.Update;
  NetworkRestoreItemAddHandle.Free;
end;


class procedure NetworkRestoreAppApi.AddRestorePc(PcID : string);
var
  RestorePcAddHandle : TNetworkRestoreDesAddHandle;
begin
  RestorePcAddHandle := TNetworkRestoreDesAddHandle.Create( PcID );
  RestorePcAddHandle.Update;
  RestorePcAddHandle.Free;
end;

class procedure NetworkRestoreAppApi.RemoveBackupItem(PcID, BackupPath, OwnerID: string);
var
  NetworkRestoreItemRemoveHandle : TNetworkRestoreItemRemoveHandle;
begin
  NetworkRestoreItemRemoveHandle := TNetworkRestoreItemRemoveHandle.Create( PcID );
  NetworkRestoreItemRemoveHandle.SetOwnerID( OwnerID );
  NetworkRestoreItemRemoveHandle.SetBackupPath( BackupPath );
  NetworkRestoreItemRemoveHandle.Update;
  NetworkRestoreItemRemoveHandle.Free;
end;

class procedure NetworkRestoreAppApi.RemoveRestorePc(PcID: string);
var
  RestorePcRemoveHandle : TNetworkRestoreDesRemoveHandle;
begin
  RestorePcRemoveHandle := TNetworkRestoreDesRemoveHandle.Create( PcID );
  RestorePcRemoveHandle.Update;
  RestorePcRemoveHandle.Free;
end;

procedure TNetworkRestoreItemWriteHandle.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

{ LocalRestoreAppApi }

class procedure LocalRestoreAppApi.AddBackupItem(Params : TLocalRestoreAddParams);
var
  LocalRestoreItemAddHandle : TLocalRestoreItemAddHandle;
begin
  LocalRestoreItemAddHandle := TLocalRestoreItemAddHandle.Create( Params.DesPath );
  LocalRestoreItemAddHandle.SetBackupPath( Params.BackupPath );
  LocalRestoreItemAddHandle.SetIsFile( Params.IsFile );
  LocalRestoreItemAddHandle.SetSpaceInfo( Params.FileCount, Params.ItemSize );
  LocalRestoreItemAddHandle.SetLastBackupTime( Params.LastBackupTime );
  LocalRestoreItemAddHandle.Update;
  LocalRestoreItemAddHandle.Free;
end;

class procedure LocalRestoreAppApi.AddRestoreDes(DesPath: string);
var
  LocalRestoreDesAddHandle : TLocalRestoreDesAddHandle;
begin
  LocalRestoreDesAddHandle := TLocalRestoreDesAddHandle.Create( DesPath );
  LocalRestoreDesAddHandle.Update;
  LocalRestoreDesAddHandle.Free;
end;

class procedure LocalRestoreAppApi.RemoveBackupItem(DesPath,
  BackupPath: string);
var
  LocalRestoreItemRemoveHandle : TLocalRestoreItemRemoveHandle;
begin
  LocalRestoreItemRemoveHandle := TLocalRestoreItemRemoveHandle.Create( DesPath );
  LocalRestoreItemRemoveHandle.SetBackupPath( BackupPath );
  LocalRestoreItemRemoveHandle.Update;
  LocalRestoreItemRemoveHandle.Free;
end;

class procedure LocalRestoreAppApi.RemoveRestoreDes(DesPath: string);
var
  LocalRestoreDesRemoveHandle : TLocalRestoreDesRemoveHandle;
begin
  LocalRestoreDesRemoveHandle := TLocalRestoreDesRemoveHandle.Create( DesPath );
  LocalRestoreDesRemoveHandle.Update;
  LocalRestoreDesRemoveHandle.Free;
end;

constructor TLocalRestoreDesWriteHandle.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;

{ TRestorePcReadHandle }

procedure TLocalRestoreDesAddHandle.AddToFace;
var
  RestorePcAddFace : TLocalRestoreDesAddFace;
begin
  RestorePcAddFace := TLocalRestoreDesAddFace.Create( DesPath );
  RestorePcAddFace.AddChange;
end;

procedure TLocalRestoreDesAddHandle.Update;
begin
  AddToFace;
end;


{ TRestorePcRemoveHandle }

procedure TLocalRestoreDesRemoveHandle.RemoveFromFace;
var
  RestorePcRemoveFace : TLocalRestoreDesRemoveFace;
begin
  RestorePcRemoveFace := TLocalRestoreDesRemoveFace.Create( DesPath );
  RestorePcRemoveFace.AddChange;
end;

procedure TLocalRestoreDesRemoveHandle.Update;
begin
  RemoveFromFace;
end;

{ TLocalRestoreItemWriteHandle }

procedure TLocalRestoreItemWriteHandle.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TLocalRestoreItemAddHandle }

procedure TLocalRestoreItemAddHandle.AddToFace;
var
  RestorePcBackupAddFace : TLocalRestoreItemAddFace;
begin
  RestorePcBackupAddFace := TLocalRestoreItemAddFace.Create( DesPath );
  RestorePcBackupAddFace.SetBackupPath( BackupPath );
  RestorePcBackupAddFace.SetIsFile( IsFile );
  RestorePcBackupAddFace.SetSpaceInfo( FileCount, FileSize );
  RestorePcBackupAddFace.SetLastBackupTime( LastBackupTime );
  RestorePcBackupAddFace.AddChange;
end;

procedure TLocalRestoreItemAddHandle.SetIsFile(_IsFile: boolean);
begin
  IsFile := _IsFile;
end;

procedure TLocalRestoreItemAddHandle.SetLastBackupTime(
  _LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TLocalRestoreItemAddHandle.SetSpaceInfo(_FileCount: integer;
  _FileSize: int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalRestoreItemAddHandle.Update;
begin
  AddToFace;
end;

{ TLocalRestoreItemRemoveHandle }

procedure TLocalRestoreItemRemoveHandle.RemoveFromFace;
var
  RestorePcBackupRemoveFace : TNetworkRestoreItemRemoveFace;
begin
  RestorePcBackupRemoveFace := TNetworkRestoreItemRemoveFace.Create( DesPath );
  RestorePcBackupRemoveFace.SetBackupPath( BackupPath );
  RestorePcBackupRemoveFace.AddChange;
end;

procedure TLocalRestoreItemRemoveHandle.Update;
begin
  RemoveFromFace;
end;

constructor TRestoreDownWriteHandle.Create( _RestorePath, _RestoreOwner : string );
begin
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
end;

{ TRestoreDownReadHandle }

procedure TRestoreDownReadHandle.SetRestoreFrom( _RestoreFrom : string );
begin
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownReadHandle.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownReadHandle.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

procedure TRestoreDownReadHandle.AddToInfo;
var
  RestoreDownAddInfo : TRestoreDownAddInfo;
begin
  RestoreDownAddInfo := TRestoreDownAddInfo.Create( RestorePath, RestoreOwner );
  RestoreDownAddInfo.SetRestoreFrom( RestoreFrom );
  RestoreDownAddInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddInfo.SetSavePath( SavePath );
  RestoreDownAddInfo.Update;
  RestoreDownAddInfo.Free;
end;

procedure TRestoreDownReadHandle.AddToFace;
var
  RestoreDownAddFace : TRestoreDownAddFace;
begin
  RestoreDownAddFace := TRestoreDownAddFace.Create( RestorePath, RestoreOwner );
  RestoreDownAddFace.SetRestoreFrom( RestoreFrom );
  RestoreDownAddFace.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddFace.SetSavePath( SavePath );
  RestoreDownAddFace.AddChange;
end;

procedure TRestoreDownReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreDownAddHandle }

procedure TRestoreDownAddHandle.AddToXml;
var
  RestoreDownAddXml : TRestoreDownAddXml;
begin
  RestoreDownAddXml := TRestoreDownAddXml.Create( RestorePath, RestoreOwner );
  RestoreDownAddXml.SetRestoreFrom( RestoreFrom );
  RestoreDownAddXml.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownAddXml.SetSavePath( SavePath );
  RestoreDownAddXml.AddChange;
end;

procedure TRestoreDownAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreDownRemoveHandle }

procedure TRestoreDownRemoveHandle.RemoveFromInfo;
var
  RestoreDownRemoveInfo : TRestoreDownRemoveInfo;
begin
  RestoreDownRemoveInfo := TRestoreDownRemoveInfo.Create( RestorePath, RestoreOwner );
  RestoreDownRemoveInfo.Update;
  RestoreDownRemoveInfo.Free;
end;

procedure TRestoreDownRemoveHandle.RemoveFromFace;
var
  RestoreDownRemoveFace : TRestoreDownRemoveFace;
begin
  RestoreDownRemoveFace := TRestoreDownRemoveFace.Create( RestorePath, RestoreOwner );
  RestoreDownRemoveFace.AddChange;
end;

procedure TRestoreDownRemoveHandle.RemoveFromXml;
var
  RestoreDownRemoveXml : TRestoreDownRemoveXml;
begin
  RestoreDownRemoveXml := TRestoreDownRemoveXml.Create( RestorePath, RestoreOwner );
  RestoreDownRemoveXml.AddChange;
end;

procedure TRestoreDownRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;






end.
