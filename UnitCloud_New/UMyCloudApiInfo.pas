unit UMyCloudApiInfo;

interface

uses SysUtils;

type

{$Region ' 数据修改 云路径 ' }

  TCloudPathWriteHandle = class
  public
    CloudPath : string;
  public
    constructor Create( _CloudPath : string );
  end;

    // 读取
  TCloudPathReadHandle = class( TCloudPathWriteHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
  end;

    // 重设
  TCloudPathResetHandle = class( TCloudPathWriteHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;


{$EndRegion}

{$Region ' 数据修改 Pc信息 ' }

    // 修改
  TCloudPcWriteHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 读取
  TCloudPcReadHandle = class( TCloudPcWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TCloudPcAddHandle = class( TCloudPcReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TCloudPcRemoveHandle = class( TCloudPcWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 数据修改 备份信息 ' }

    // 修改
  TCloudPcBackupWriteHandle = class( TCloudPcWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TCloudPcBackupReadHandle = class( TCloudPcBackupWriteHandle )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // 添加
  TCloudPcBackupAddHandle = class( TCloudPcBackupReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToEvent;
  end;

    // 删除
  TCloudPcBackupRemoveHandle = class( TCloudPcBackupWriteHandle )
  protected
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
    procedure RemoveToEvent;
  end;


{$EndRegion}

{$Region ' 数据读取 ' }

  TPcOnlineHandle = class
  public
    OnlinePcID : string;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  private
    procedure SendRestoreToPc;
  end;

{$EndRegion}

  TCloudAddBackupParams = record
  public
    PcID, BackupPath : string;
    IsFile : Boolean;
    FileCount : Integer;
    FileSpace : Int64;
    LastDateTime : TDateTime;
  end;

  MyCloudAppApi = class
  public
    class procedure AddPcItem( PcID : string );
    class procedure PcOnline( PcID : string );
  public
    class procedure AddBackupPath( Params : TCloudAddBackupParams );
    class procedure RemoveBackupPath( PcID, BackupPath : string );
  end;

implementation

uses UMyCloudDataInfo, UMyCloudXmlInfo, UMyCloudEventInfo, UMyClient, UMyNetPcInfo;

constructor TCloudPcWriteHandle.Create( _PcID : string );
begin
  PcID := _PcID;
end;

{ TCloudPcReadHandle }

procedure TCloudPcReadHandle.AddToInfo;
var
  CloudPcAddInfo : TCloudPcAddInfo;
begin
  CloudPcAddInfo := TCloudPcAddInfo.Create( PcID );
  CloudPcAddInfo.Update;
  CloudPcAddInfo.Free;
end;

procedure TCloudPcReadHandle.Update;
begin
  AddToInfo;
end;

{ TCloudPcAddHandle }

procedure TCloudPcAddHandle.AddToXml;
var
  CloudPcAddXml : TCloudPcAddXml;
begin
  CloudPcAddXml := TCloudPcAddXml.Create( PcID );
  CloudPcAddXml.AddChange;
end;

procedure TCloudPcAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TCloudPcRemoveHandle }

procedure TCloudPcRemoveHandle.RemoveFromInfo;
var
  CloudPcRemoveInfo : TCloudPcRemoveInfo;
begin
  CloudPcRemoveInfo := TCloudPcRemoveInfo.Create( PcID );
  CloudPcRemoveInfo.Update;
  CloudPcRemoveInfo.Free;
end;

procedure TCloudPcRemoveHandle.RemoveFromXml;
var
  CloudPcRemoveXml : TCloudPcRemoveXml;
begin
  CloudPcRemoveXml := TCloudPcRemoveXml.Create( PcID );
  CloudPcRemoveXml.AddChange;
end;

procedure TCloudPcRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

procedure TCloudPcBackupWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

{ TCloudPcBackupReadHandle }

procedure TCloudPcBackupReadHandle.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudPcBackupReadHandle.SetLastBackupTime(
  _LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudPcBackupReadHandle.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudPcBackupReadHandle.AddToInfo;
var
  CloudPcBackupAddInfo : TCloudPcBackupAddInfo;
begin
  CloudPcBackupAddInfo := TCloudPcBackupAddInfo.Create( PcID );
  CloudPcBackupAddInfo.SetBackupPath( BackupPath );
  CloudPcBackupAddInfo.SetIsFile( IsFile );
  CloudPcBackupAddInfo.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupAddInfo.SetLastBackupTime( LastBackupTime );
  CloudPcBackupAddInfo.Update;
  CloudPcBackupAddInfo.Free;
end;

procedure TCloudPcBackupReadHandle.Update;
begin
  AddToInfo;
end;

{ TCloudPcBackupAddHandle }

procedure TCloudPcBackupAddHandle.AddToEvent;
var
  Params : TCloudAddEventParam;
begin
  Params.PcID := PcID;
  Params.BackupPath := BackupPath;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.FileSpace := ItemSize;
  Params.LastDateTime := LastBackupTime;

  MyCloudEventInfo.AddCloudItem( Params );
end;

procedure TCloudPcBackupAddHandle.AddToXml;
var
  CloudPcBackupAddXml : TCloudPcBackupAddXml;
begin
  CloudPcBackupAddXml := TCloudPcBackupAddXml.Create( PcID );
  CloudPcBackupAddXml.SetBackupPath( BackupPath );
  CloudPcBackupAddXml.SetIsFile( IsFile );
  CloudPcBackupAddXml.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupAddXml.SetLastBackupTime( LastBackupTime );
  CloudPcBackupAddXml.AddChange;
end;

procedure TCloudPcBackupAddHandle.Update;
begin
  inherited;
  AddToXml;
  AddToEvent;
end;

{ TCloudPcBackupRemoveHandle }

procedure TCloudPcBackupRemoveHandle.RemoveFromInfo;
var
  CloudPcBackupRemoveInfo : TCloudPcBackupRemoveInfo;
begin
  CloudPcBackupRemoveInfo := TCloudPcBackupRemoveInfo.Create( PcID );
  CloudPcBackupRemoveInfo.SetBackupPath( BackupPath );
  CloudPcBackupRemoveInfo.Update;
  CloudPcBackupRemoveInfo.Free;
end;

procedure TCloudPcBackupRemoveHandle.RemoveFromXml;
var
  CloudPcBackupRemoveXml : TCloudPcBackupRemoveXml;
begin
  CloudPcBackupRemoveXml := TCloudPcBackupRemoveXml.Create( PcID );
  CloudPcBackupRemoveXml.SetBackupPath( BackupPath );
  CloudPcBackupRemoveXml.AddChange;
end;

procedure TCloudPcBackupRemoveHandle.RemoveToEvent;
begin
  MyCloudEventInfo.RemoveCloudItem( PcID, BackupPath );
end;

procedure TCloudPcBackupRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
  RemoveToEvent;
end;

{ MyCloudAppApi }

class procedure MyCloudAppApi.AddBackupPath(Params : TCloudAddBackupParams);
var
  CloudPcBackupAddHandle : TCloudPcBackupAddHandle;
begin
  CloudPcBackupAddHandle := TCloudPcBackupAddHandle.Create( Params.PcID );
  CloudPcBackupAddHandle.SetBackupPath( Params.BackupPath );
  CloudPcBackupAddHandle.SetIsFile( Params.IsFile );
  CloudPcBackupAddHandle.SetSpaceInfo( Params.FileCount, Params.FileSpace );
  CloudPcBackupAddHandle.SetLastBackupTime( Params.LastDateTime );
  CloudPcBackupAddHandle.Update;
  CloudPcBackupAddHandle.Free;
end;

class procedure MyCloudAppApi.AddPcItem(PcID: string);
var
  CloudPcAddHandle : TCloudPcAddHandle;
begin
  CloudPcAddHandle := TCloudPcAddHandle.Create( PcID );
  CloudPcAddHandle.Update;
  CloudPcAddHandle.Free;
end;

class procedure MyCloudAppApi.PcOnline(PcID: string);
var
  PcOnlineHandle : TPcOnlineHandle;
begin
  PcOnlineHandle := TPcOnlineHandle.Create( PcID );
  PcOnlineHandle.Update;
  PcOnlineHandle.Free;
end;

class procedure MyCloudAppApi.RemoveBackupPath(PcID, BackupPath: string);
var
  CloudPcBackupRemoveHandle : TCloudPcBackupRemoveHandle;
begin
  CloudPcBackupRemoveHandle := TCloudPcBackupRemoveHandle.Create( PcID );
  CloudPcBackupRemoveHandle.SetBackupPath( BackupPath );
  CloudPcBackupRemoveHandle.Update;
  CloudPcBackupRemoveHandle.Free;
end;

{ TCloudPathWriteHandle }

constructor TCloudPathWriteHandle.Create(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

{ TCloudPathReadHandle }

procedure TCloudPathReadHandle.SetToInfo;
var
  CloudPathReadInfo : TCloudPathReadInfo;
begin
  CloudPathReadInfo := TCloudPathReadInfo.Create( CloudPath );
  CloudPathReadInfo.Update;
  CloudPathReadInfo.Free;
end;

procedure TCloudPathReadHandle.Update;
begin
  SetToInfo;
end;

{ TCloudPathResetHandle }

procedure TCloudPathResetHandle.SetToInfo;
var
  CloudPathReSetInfo : TCloudPathReSetInfo;
begin
  CloudPathReSetInfo := TCloudPathReSetInfo.Create( CloudPath );
  CloudPathReSetInfo.Update;
  CloudPathReSetInfo.Free;
end;

procedure TCloudPathResetHandle.SetToXml;
var
  CloudPathReSetXml : TCloudPathReSetXml;
begin
  CloudPathReSetXml := TCloudPathReSetXml.Create( CloudPath );
  CloudPathReSetXml.AddChange;
end;

procedure TCloudPathResetHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TPcOnlineHandle }

constructor TPcOnlineHandle.Create(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TPcOnlineHandle.SendRestoreToPc;
var
  CloudPcList : TCloudPcList;
  i, j : Integer;
  OwnerID, OwnerName : string;
  CloudPcBackupInfo : TCloudPcBackupInfo;
  CloudBackupAddRestoreMsg : TCloudBackupAddRestoreMsg;
begin
  CloudPcList := MyCloudInfoReadUtil.ReadCloudPcList;
  for i := 0 to CloudPcList.Count - 1 do
  begin
    OwnerID := CloudPcList[i].PcID;
    OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );
    for j := 0 to CloudPcList[i].CloudPcBackupList.Count - 1 do
    begin
      CloudPcBackupInfo := CloudPcList[i].CloudPcBackupList[j];
      CloudBackupAddRestoreMsg := TCloudBackupAddRestoreMsg.Create;
      CloudBackupAddRestoreMsg.SetPcID( PcInfo.PcID );
      CloudBackupAddRestoreMsg.SetBackupPath( CloudPcBackupInfo.BackupPath );
      CloudBackupAddRestoreMsg.SetIsFile( CloudPcBackupInfo.IsFile );
      CloudBackupAddRestoreMsg.SetOwnerInfo( OwnerID, OwnerName );
      CloudBackupAddRestoreMsg.SetSpaceInfo( CloudPcBackupInfo.FileCount, CloudPcBackupInfo.ItemSize );
      CloudBackupAddRestoreMsg.SetLastBackupTime( CloudPcBackupInfo.LastBackupTime );
      MyClient.SendMsgToPc( OnlinePcID, CloudBackupAddRestoreMsg );
    end;
  end;
  CloudPcList.Free;
end;




procedure TPcOnlineHandle.Update;
begin
  SendRestoreToPc;
end;

end.
