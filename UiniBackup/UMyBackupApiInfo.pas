unit UMyBackupApiInfo;

interface

type

{$Region ' ���ر��� ' }

  {$Region ' Ŀ��·�� ' }

    // ����
  TLocalBackupDesItemWriteHandle = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
  end;

    // ��ȡ
    // ��ȡ Xml ����
  TLocalBackupDesItemReadHandle = class( TLocalBackupDesItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ���
  TLocalBackupDesItemAddHandle = class( TLocalBackupDesItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TLocalBackupDeItemRemoveHandle = class( TLocalBackupDesItemReadHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' Դ·�� ��ɾ ' }

    // ���
  TLocalBackupItemWriteHandle = class( TLocalBackupDesItemWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // ��ȡ
  TLocalBackupItemReadHandle = class( TLocalBackupItemWriteHandle )
  public  // ·����Ϣ
    IsFile : Boolean;
  public  // ��ѡ״̬
    IsDisable, IsBackupNow : Boolean;
  public  // �Զ�ͬ��
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public  // ɾ��������Ϣ
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ���
  TLocalBackupItemAddHandle = class( TLocalBackupItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TLocalBackupItemRemoveHandle = class( TLocalBackupItemWriteHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' Դ·�� ״̬ ' }

    // �Ƿ� ��ֹ����
  TLocalBackupItemSetIsDisableHandle = class( TLocalBackupItemWriteHandle )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // �Ƿ� Backup Now ����
  TLocalBackupItemSetIsBackupNowHandle = class( TLocalBackupItemWriteHandle )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

    // �û� API
  LocalBackupUserApi = class
  public              // Ŀ��·��
    class procedure AddDesItem( DesPath : string );
    class procedure RemoveDesItem( DesPath : string );
  public              // ����·��
    class procedure AddBackupItem( DesPath, BackupPath : string );
    class procedure RemoveBackupItem( DesPath, BackupPath : string );
    class procedure BackupSelectItem( DesPath, BackupPath : string );
  end;

{$EndRegion}

implementation

uses UMyBackupDataInfo, UMyBackupFaceInfo, UMyBackupXmlInfo;

{ LocalBackupUserApi }

class procedure LocalBackupUserApi.AddBackupItem(DesPath, BackupPath: string);
begin

end;

class procedure LocalBackupUserApi.AddDesItem(DesPath: string);
begin

end;

class procedure LocalBackupUserApi.BackupSelectItem(DesPath,
  BackupPath: string);
begin

end;

class procedure LocalBackupUserApi.RemoveBackupItem(DesPath,
  BackupPath: string);
begin

end;

class procedure LocalBackupUserApi.RemoveDesItem(DesPath: string);
begin

end;

{ TLocalBackupDesItemWriteHandle }

constructor TLocalBackupDesItemWriteHandle.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TLocalBackupDesItemAddHandle }

procedure TLocalBackupDesItemAddHandle.AddToXml;
var
  LocalDesItemAddXml : TLocalDesItemAddXml;
begin
  LocalDesItemAddXml := TLocalDesItemAddXml.Create( DesPath );
  LocalDesItemAddXml.AddChange;
end;

procedure TLocalBackupDesItemAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupDesItemReadHandle }

procedure TLocalBackupDesItemReadHandle.AddToFace;
var
  VstLocalBackupDesItemAdd : TVstLocalBackupDesItemAdd;
begin
  VstLocalBackupDesItemAdd := TVstLocalBackupDesItemAdd.Create( DesPath );
  VstLocalBackupDesItemAdd.AddChange;
end;

procedure TLocalBackupDesItemReadHandle.AddToInfo;
var
  LocalDesItemAddInfo : TLocalDesItemAddInfo;
begin
  LocalDesItemAddInfo := TLocalDesItemAddInfo.Create( DesPath );
  LocalDesItemAddInfo.Update;
  LocalDesItemAddInfo.Free;
end;

procedure TLocalBackupDesItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TlocalBackupDeItemRemoveHandle }

procedure TLocalBackupDeItemRemoveHandle.RemoveFromFace;
var
  VstLocalBackupDesItemRemove : TVstLocalBackupDesItemRemove;
begin
  VstLocalBackupDesItemRemove := TVstLocalBackupDesItemRemove.Create( DesPath );
  VstLocalBackupDesItemRemove.AddChange;
end;

procedure TLocalBackupDeItemRemoveHandle.RemoveFromInfo;
var
  LocalDesItemRemoveInfo : TLocalDesItemRemoveInfo;
begin
  LocalDesItemRemoveInfo := TLocalDesItemRemoveInfo.Create( DesPath );
  LocalDesItemRemoveInfo.Update;
  LocalDesItemRemoveInfo.Free;
end;

procedure TLocalBackupDeItemRemoveHandle.RemoveFromXml;
var
  LocalDesItemRemoveXml : TLocalDesItemRemoveXml;
begin
  LocalDesItemRemoveXml := TLocalDesItemRemoveXml.Create( DesPath );
  LocalDesItemRemoveXml.AddChange;
end;

procedure TLocalBackupDeItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

procedure TLocalBackupItemWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

procedure TLocalBackupItemReadHandle.SetIsFile( _IsFile : Boolean );
begin
  IsFile := _IsFile;
end;

procedure TLocalBackupItemReadHandle.SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemReadHandle.AddToFace;
var
  VstLocalBackupItemAdd : TVstLocalBackupItemAdd;
begin
  VstLocalBackupItemAdd := TVstLocalBackupItemAdd.Create( DesPath );
  VstLocalBackupItemAdd.SetBackupPath( BackupPath );
  VstLocalBackupItemAdd.SetIsFile( IsFile );
  VstLocalBackupItemAdd.SetIsDisable( IsDisable );
  VstLocalBackupItemAdd.SetAutoSyncInfo( IsAutoSync, LasSyncTime );
  VstLocalBackupItemAdd.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  VstLocalBackupItemAdd.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  VstLocalBackupItemAdd.AddChange;
end;

procedure TLocalBackupItemReadHandle.AddToInfo;
var
  LocalBackupItemAddInfo : TLocalBackupItemAddInfo;
begin
  LocalBackupItemAddInfo := TLocalBackupItemAddInfo.Create( DesPath );
  LocalBackupItemAddInfo.SetBackupPath( BackupPath );
  LocalBackupItemAddInfo.SetIsFile( IsFile );
  LocalBackupItemAddInfo.SetBackupStatus( IsDisable, IsBackupNow );
  LocalBackupItemAddInfo.SetAutoSync( IsAutoSync, LasSyncTime );
  LocalBackupItemAddInfo.SetSyncInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddInfo.Update;
  LocalBackupItemAddInfo.Free;
end;

procedure TLocalBackupItemReadHandle.SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TLocalBackupItemReadHandle.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

procedure TLocalBackupItemReadHandle.SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupItemReadHandle.SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;



{ TLocalBackupItemAddHandle }

procedure TLocalBackupItemAddHandle.AddToXml;
var
  LocalBackupItemAddXml : TLocalBackupItemAddXml;
begin
  LocalBackupItemAddXml := TLocalBackupItemAddXml.Create( DesPath );
  LocalBackupItemAddXml.SetBackupPath( BackupPath );
  LocalBackupItemAddXml.SetIsFile( IsFile );
  LocalBackupItemAddXml.SetBackupStatus( IsDisable, IsBackupNow );
  LocalBackupItemAddXml.SetAutoSyncInfo( IsAutoSync, LasSyncTime );
  LocalBackupItemAddXml.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddXml.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddXml.AddChange;
end;

procedure TLocalBackupItemAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupItemRemoveHandle }

procedure TLocalBackupItemRemoveHandle.RemoveFromFace;
var
  VstLocalBackupItemRemove : TVstLocalBackupItemRemove;
begin
  VstLocalBackupItemRemove := TVstLocalBackupItemRemove.Create( DesPath );
  VstLocalBackupItemRemove.SetBackupPath( BackupPath );
  VstLocalBackupItemRemove.AddChange;
end;

procedure TLocalBackupItemRemoveHandle.RemoveFromInfo;
var
  LocalBackupItemRemoveInfo : TLocalBackupItemRemoveInfo;
begin
  LocalBackupItemRemoveInfo := TLocalBackupItemRemoveInfo.Create( DesPath );
  LocalBackupItemRemoveInfo.SetBackupPath( BackupPath );
  LocalBackupItemRemoveInfo.Update;
  LocalBackupItemRemoveInfo.Free;
end;

procedure TLocalBackupItemRemoveHandle.RemoveFromXml;
var
  LocalBackupItemRemoveXml : TLocalBackupItemRemoveXml;
begin
  LocalBackupItemRemoveXml := TLocalBackupItemRemoveXml.Create( DesPath );
  LocalBackupItemRemoveXml.SetBackupPath( BackupPath );
  LocalBackupItemRemoveXml.AddChange;
end;

procedure TLocalBackupItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TLocalBackupItemSetIsDisableHandle }

procedure TLocalBackupItemSetIsDisableHandle.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupItemSetIsDisableHandle.SetToFace;
var
  VstLocalBackupItemSetIsDisable : TVstLocalBackupItemSetIsDisable;
begin
  VstLocalBackupItemSetIsDisable := TVstLocalBackupItemSetIsDisable.Create( DesPath );
  VstLocalBackupItemSetIsDisable.SetBackupPath( BackupPath );
  VstLocalBackupItemSetIsDisable.SetIsDisable( IsDisable );
  VstLocalBackupItemSetIsDisable.AddChange;
end;

procedure TLocalBackupItemSetIsDisableHandle.SetToInfo;
var
  LocalBackupItemSetIsDisableInfo : TLocalBackupItemSetIsDisableInfo;
begin
  LocalBackupItemSetIsDisableInfo := TLocalBackupItemSetIsDisableInfo.Create( DesPath );
  LocalBackupItemSetIsDisableInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetIsDisableInfo.SetIsDisable( IsDisable );
  LocalBackupItemSetIsDisableInfo.Update;
  LocalBackupItemSetIsDisableInfo.Free;
end;

procedure TLocalBackupItemSetIsDisableHandle.SetToXml;
var
  LocalBackupItemSetIsDisableXml : TLocalBackupItemSetIsDisableXml;
begin
  LocalBackupItemSetIsDisableXml := TLocalBackupItemSetIsDisableXml.Create( DesPath );
  LocalBackupItemSetIsDisableXml.SetBackupPath( BackupPath );
  LocalBackupItemSetIsDisableXml.SetIsDisable( IsDisable );
  LocalBackupItemSetIsDisableXml.AddChange;
end;

procedure TLocalBackupItemSetIsDisableHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetIsBackupNowHandle }

procedure TLocalBackupItemSetIsBackupNowHandle.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemSetIsBackupNowHandle.SetToInfo;
var
  LocalBackupItemSetIsBackupNowInfo : TLocalBackupItemSetIsBackupNowInfo;
begin
  LocalBackupItemSetIsBackupNowInfo := TLocalBackupItemSetIsBackupNowInfo.Create( DesPath );
  LocalBackupItemSetIsBackupNowInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowInfo.Update;
  LocalBackupItemSetIsBackupNowInfo.Free;
end;

procedure TLocalBackupItemSetIsBackupNowHandle.SetToXml;
var
  LocalBackupItemSetIsBackupNowXml : TLocalBackupItemSetIsBackupNowXml;
begin
  LocalBackupItemSetIsBackupNowXml := TLocalBackupItemSetIsBackupNowXml.Create( DesPath );
  LocalBackupItemSetIsBackupNowXml.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowXml.AddChange;
end;

procedure TLocalBackupItemSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

end.
