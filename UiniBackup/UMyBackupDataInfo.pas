unit UMyBackupDataInfo;

interface

uses UFileBaseInfo, Generics.Collections, UDataSetInfo, UMyUtil, DateUtils;

type

{$Region ' ���ݽṹ ' }

    // ���� Item ��Ϣ
  TBackupItemInfo = class
  public  // ·����Ϣ
    BackupPath : string;
    IsFile : Boolean;
  public  // ��ѡ״̬
    IsDisable, IsBackupNow : Boolean;
  public  // �Զ�ͬ��
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime, NextSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public  // ������
    IncludeFilterList : TFileFilterList;  // �����ļ� ������
    ExcludeFilterList : TFileFilterList;  // �ų��ļ� ������
  public
    constructor Create( _BackupPath : string; _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    destructor Destroy; override;
  end;

    // ���� BackupItem
  TLocalBackupItemInfo = class( TBackupItemInfo )
  protected
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  protected
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
  end;
  TLocalBackupItemList = class( TObjectList<TLocalBackupItemInfo> )end;

    // ���� BackupItem
  TNetworkBackupItemInfo = class( TBackupItemInfo )
  protected
    IsEncrypt : Boolean;  // ��������
    Password, PasswordHint : string;
  public
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
  end;
  TNetworkBackupItemList = class( TObjectList<TNetworkBackupItemInfo> )end;

    // ���ر��� Ŀ����Ϣ
  TLocalDesItemInfo = class
  public
    DesPath : string;
    LocalBackupItemList : TLocalBackupItemList;
  public
    constructor Create( _DesPath : string );
    destructor Destroy; override;
  end;
  TLocalDesItemList = class( TObjectList<TLocalDesItemInfo> )end;

    // ���籸�� Ŀ����Ϣ
  TNetworkDesItemInfo = class
  public
    PcID : string;
    NetworkBackupItemList : TNetworkBackupItemList;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TNetworkDesItemList = class( TObjectList<TNetworkDesItemInfo> )end;

    // ������Ϣ
  TMyBackupInfo = class( TMyDataInfo )
  public
    LocalDesItemList : TLocalDesItemList;
    NetworkDesItemList : TNetworkDesItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ر��� ���ݽӿ� ' }

    // ���� ����
  TBackupAccessInfo = class
  public
    LocalDesItemList : TLocalDesItemList; // ���ر���
    NetworkDesItemList : TNetworkDesItemList; // ���籸��
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ر��� Ŀ��·��
  TLocalDesItemAccessInfo = class( TBackupAccessInfo )
  public
    DesPath : string;
  public
    DesItemIndex : Integer;
    DesItemInfo : TLocalDesItemInfo;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemInfo : Boolean;
  end;

    // ���� ���ر��� Դ����
  TLocalBackupAccessInfo = class( TLocalDesItemAccessInfo )
  public
    BackupItemList : TLocalBackupItemList;
  protected
    function FindBackupItemList : Boolean;
  end;

    // ���� ���ر��� Դ·��
  TLocalBackupItemAccessInfo = class( TLocalBackupAccessInfo )
  public
    BackupPath : string;
  protected
    BackupItemIndex : Integer;
    BackupItemInfo : TLocalBackupItemInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemInfo : Boolean;
  end;

{$EndRegion}

{$Region ' ���籸�� ���ݽӿ� ' }

    // ���� ���籸�� Ŀ��Pc
  TNetworkDesItemAccessInfo = class( TBackupAccessInfo )
  public
    PcID : string;
  protected
    DesItemIndex : Integer;
    DesItemInfo : TNetworkDesItemInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindDesItemInfo : Boolean;
  end;

    // ���� ���籸�� Դ����
  TNetworkBackupAccessInfo = class( TNetworkDesItemAccessInfo )
  public
    BackupItemList : TNetworkBackupItemList;
  public
    function FindBackupItemList : Boolean;
  end;

    // ���� ���籸�� Դ·��
  TNetworkBackupItemAccessInfo = class( TNetworkBackupAccessInfo )
  public
    BackupPath : string;
  public
    BackupItemIndex : Integer;
    BackupItemInfo : TNetworkBackupItemInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemInfo : Boolean;
  end;

{$EndRegion}

{$Region ' ���ر��� �����޸� ' }

    // ���ر��� Ŀ��·�� ����
  TLocalDesItemWriteInfo = class( TLocalDesItemAccessInfo )
  end;

  {$Region ' Ŀ��·�� ' }

    // ���
  TLocalDesItemAddInfo = class( TLocalDesItemWriteInfo )
  public
    procedure Update;
  end;

    // ɾ��
  TLocalDesItemRemoveInfo = class( TLocalDesItemWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

    // ���ر��� Դ·�� ����
  TLocalBackupItemWriteInfo = class( TLocalBackupItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ��ɾ·�� ' }

    // ���
  TLocalBackupItemAddInfo = class( TLocalBackupItemWriteInfo )
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
    procedure SetAutoSync( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;
  end;

    // ɾ��
  TLocalBackupItemRemoveInfo = class( TLocalBackupItemWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

    // �Ƿ� ��ֹ����
  TLocalBackupItemSetIsDisableInfo = class( TLocalBackupItemWriteInfo )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  end;

    // �Ƿ� Backup Now ����
  TLocalBackupItemSetIsBackupNowInfo = class( TLocalBackupItemWriteInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�ͬ�� ' }

    // ���� ��һ�� ͬ��ʱ��
  TLocalBackupItemSetLastSyncTimeInfo = class( TLocalBackupItemWriteInfo )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  end;

    // ���� ͬ������
  TLocalBackupItemSetAutoSyncInfo = class( TLocalBackupItemWriteInfo )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ļ��� ' }

  TLocalBackupItemSetRecycleInfo = class( TLocalBackupItemWriteInfo )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ŀռ� ' }

    // ���� �ռ���Ϣ
  TLocalBackupItemSetSpaceInfo = class( TLocalBackupItemWriteInfo )
  public
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;
  end;

    // ��� �������Ϣ
  TLocalBackupItemAddCompletedSpaceInfo = class( TLocalBackupItemWriteInfo )
  public
    AddCompletedSpace : Integer;
  public
    procedure SetAddCompetedSpace( _AddCompletedSpace : Integer );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ���籸�� �����޸� ' }

    // ���ر��� Ŀ��·�� ����
  TNetworkDesItemWriteInfo = class( TNetworkDesItemAccessInfo )
  end;

  {$Region ' ��ɾ·�� ' }

    // ���
  TNetworkDesItemAddInfo = class( TNetworkDesItemWriteInfo )
  public
    procedure Update;
  end;

    // ɾ��
  TNetworkDesItemRemoveInfo = class( TNetworkDesItemWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

    // ���ر��� Դ·�� ����
  TNetworkBackupItemWriteInfo = class( TNetworkBackupItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ��ɾ·�� ' }

    // ���
  TNetworkBackupItemAddInfo = class( TNetworkBackupItemWriteInfo )
  public  // ·����Ϣ
    IsFile : Boolean;
  public  // ��ѡ״̬
    IsDisable, IsBackupNow : Boolean;
  public  // �Զ�ͬ��
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime, NextSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public
    IsEncrypt : Boolean;  // ��������
    Password, PasswordHint : string;
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSync( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure Update;
  end;

    // ɾ��
  TNetworkBackupItemRemoveInfo = class( TNetworkBackupItemWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

    // �Ƿ� ��ֹ����
  TNetworkBackupItemSetIsDisableInfo = class( TNetworkBackupItemWriteInfo )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  end;

    // �Ƿ� Backup Now ����
  TNetworkBackupItemSetIsBackupNowInfo = class( TNetworkBackupItemWriteInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�ͬ�� ' }

    // ���� ��һ�� ͬ��ʱ��
  TNetworkBackupItemSetLastSyncTimeInfo = class( TNetworkBackupItemWriteInfo )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  end;

    // ���� ͬ������
  TNetworkBackupItemSetAutoSyncInfo = class( TNetworkBackupItemWriteInfo )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸Ŀռ� ' }

    // ���� �ռ���Ϣ
  TNetworkBackupItemSetSpaceInfo = class( TNetworkBackupItemWriteInfo )
  public
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;
  end;

    // ��� �������Ϣ
  TNetworkBackupItemAddCompletedSpaceInfo = class( TNetworkBackupItemWriteInfo )
  public
    AddCompletedSpace : Integer;
  public
    procedure SetAddCompetedSpace( _AddCompletedSpace : Integer );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

var
  MyBackupInfo : TMyBackupInfo;

implementation

{ TMyBackupInfo }

constructor TMyBackupInfo.Create;
begin
  inherited;
  LocalDesItemList := TLocalDesItemList.Create;
  NetworkDesItemList := TNetworkDesItemList.Create;
end;

destructor TMyBackupInfo.Destroy;
begin
  NetworkDesItemList.Free;
  LocalDesItemList.Free;
  inherited;
end;

{ TNetworkDestinationInfo }

constructor TNetworkDesItemInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  NetworkBackupItemList := TNetworkBackupItemList.Create;
end;

destructor TNetworkDesItemInfo.Destroy;
begin
  NetworkBackupItemList.Free;
  inherited;
end;

{ TLocalDestinationInfo }

constructor TLocalDesItemInfo.Create(_DesPath: string);
begin
  DesPath := _DesPath;
  LocalBackupItemList := TLocalBackupItemList.Create;
end;

destructor TLocalDesItemInfo.Destroy;
begin
  LocalBackupItemList.Free;
  inherited;
end;

{ TBackupItemInfo }

constructor TBackupItemInfo.Create(_BackupPath: string; _IsFile: Boolean);
begin
  BackupPath := _BackupPath;
  IsFile := _IsFile;
  IncludeFilterList := TFileFilterList.Create;
  ExcludeFilterList := TFileFilterList.Create;
end;

destructor TBackupItemInfo.Destroy;
begin
  ExcludeFilterList.Free;
  IncludeFilterList.Free;
  inherited;
end;

procedure TBackupItemInfo.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemInfo.SetBackupStatus(_IsDisable, _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemInfo.SetSpaceInfo(_FileCount : Integer;
  _ItemSize, _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemInfo.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

{ TBackupAccessInfo }

constructor TBackupAccessInfo.Create;
begin
  MyBackupInfo.EnterData;
  LocalDesItemList := MyBackupInfo.LocalDesItemList;
  NetworkDesItemList := MyBackupInfo.NetworkDesItemList;
end;

destructor TBackupAccessInfo.Destroy;
begin
  MyBackupInfo.LeaveData;
  inherited;
end;

{ TBackupItemNetworkInfo }

procedure TNetworkBackupItemInfo.SetEncryptInfo(_IsEncrypt: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

{ TBackupItemLocalInfo }

procedure TLocalBackupItemInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

{ TLocalDesItemAccessInfo }

constructor TLocalDesItemAccessInfo.Create(_DesPath: string);
begin
  inherited Create;
  DesPath := _DesPath;
end;

function TLocalDesItemAccessInfo.FindDesItemInfo: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to LocalDesItemList.Count - 1 do
    if LocalDesItemList[i].DesPath = DesPath then
    begin
      Result := True;
      DesItemIndex := i;
      DesItemInfo := LocalDesItemList[i];
      Break;
    end;
end;

{ TLocalBackupAccessInfo }

function TLocalBackupItemAccessInfo.FindBackupItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if BackupItemList[i].BackupPath = BackupPath then
    begin
      Result := True;
      BackupItemIndex := i;
      BackupItemInfo := BackupItemList[i];
      Break;
    end;
end;

procedure TLocalBackupItemAccessInfo.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TLocalBackupAccessInfo }

function TLocalBackupAccessInfo.FindBackupItemList: Boolean;
begin
  Result := FindDesItemInfo;
  if Result then
    BackupItemList := DesItemInfo.LocalBackupItemList;
end;

{ TNetworkBackupAccessInfo }

constructor TNetworkDesItemAccessInfo.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TNetworkDesItemAccessInfo.FindDesItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to NetworkDesItemList.Count - 1 do
    if NetworkDesItemList[i].PcID = PcID then
    begin
      Result := True;
      DesItemIndex := i;
      DesItemInfo := NetworkDesItemList[i];
      Break;
    end;
end;

{ TNetworkBackupAccessInfo }

function TNetworkBackupAccessInfo.FindBackupItemList: Boolean;
begin
  Result := FindDesItemInfo;
  if Result then
    BackupItemList := DesItemInfo.NetworkBackupItemList;
end;

{ TNetworkBackupItemAccessInfo }

function TNetworkBackupItemAccessInfo.FindBackupItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if BackupItemList[i].BackupPath = BackupPath then
    begin
      Result := True;
      BackupItemIndex := i;
      BackupItemInfo := BackupItemList[i];
      Break;
    end;
end;

procedure TNetworkBackupItemAccessInfo.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TLocalDesItemAddInfo }

procedure TLocalDesItemAddInfo.Update;
begin
    // �Ѵ���, ����
  if FindDesItemInfo then
    Exit;

    // ���
  DesItemInfo := TLocalDesItemInfo.Create( DesPath );
  LocalDesItemList.Add( DesItemInfo );
end;

{ TLocalDesItemRemoveInfo }

procedure TLocalDesItemRemoveInfo.Update;
begin
    // �����ڣ�������
  if not FindDesItemInfo then
    Exit;

    // ɾ��
  LocalDesItemList.Delete( DesItemIndex );
end;

{ TLocalBackupItemAddInfo }

procedure TLocalBackupItemAddInfo.SetAutoSync(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TLocalBackupItemAddInfo.SetBackupStatus(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemAddInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupItemAddInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TLocalBackupItemAddInfo.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TLocalBackupItemAddInfo.SetSyncInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupItemAddInfo.Update;
begin
    // �Ѵ���
  if FindBackupItemInfo then
    Exit;

    // ���
  BackupItemInfo := TLocalBackupItemInfo.Create( BackupPath, IsFile );
  BackupItemInfo.SetBackupStatus( IsDisable, IsBackupNow );
  BackupItemInfo.SetAutoSyncInfo( IsAutoSync, LasSyncTime );
  BackupItemInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemList.Add( BackupItemInfo );

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TLocalBackupItemRemoveInfo }

procedure TLocalBackupItemRemoveInfo.Update;
begin
    // ������
  if not FindBackupItemInfo then
    Exit;

    // ɾ��
  BackupItemList.Delete( BackupItemIndex );
end;

{ TLocalBackupItemSetIsDisableInfo }

procedure TLocalBackupItemSetIsDisableInfo.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupItemSetIsDisableInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsDisable := IsDisable;
end;

{ TLocalBackupItemSetIsBackupNowInfo }

procedure TLocalBackupItemSetIsBackupNowInfo.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupItemSetIsBackupNowInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsBackupNow := IsBackupNow;
end;

{ TLocalBackupItemSetLastSyncTimeInfo }

procedure TLocalBackupItemSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupItemSetLastSyncTimeInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.LasSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TLocalBackupItemSetAutoSyncInfo }

procedure TLocalBackupItemSetAutoSyncInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupItemSetAutoSyncInfo.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupItemSetAutoSyncInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.IsAutoSync := IsAutoSync;
  BackupItemInfo.SyncTimeType := SyncTimeType;
  BackupItemInfo.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TLocalBackupItemSetRecycleInfo }

procedure TLocalBackupItemSetRecycleInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupItemSetRecycleInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsKeepDeleted := IsKeepDeleted;
  BackupItemInfo.KeepEditionCount := KeepEditionCount;
end;

{ TLocalBackupItemSetSpaceInfo }

procedure TLocalBackupItemSetSpaceInfo.SetSpaceInfo(_FileCount: Integer;
  _ItemSize, _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TLocalBackupItemSetSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
end;

{ TLocalBackupItemAddCompletedSpaceInfo }

procedure TLocalBackupItemAddCompletedSpaceInfo.SetAddCompetedSpace(
  _AddCompletedSpace: Integer);
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TLocalBackupItemAddCompletedSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.CompletedSize := BackupItemInfo.CompletedSize + AddCompletedSpace;
end;

{ TNetworkDesItemAddInfo }

procedure TNetworkDesItemAddInfo.Update;
begin
    // �Ѵ���, ����
  if FindDesItemInfo then
    Exit;

    // ���
  DesItemInfo := TNetworkDesItemInfo.Create( PcID );
  NetworkDesItemList.Add( DesItemInfo );
end;

{ TNetworkDesItemRemoveInfo }

procedure TNetworkDesItemRemoveInfo.Update;
begin
    // �����ڣ�������
  if not FindDesItemInfo then
    Exit;

    // ɾ��
  NetworkDesItemList.Delete( DesItemIndex );
end;

{ TNetworkBackupItemAddInfo }

procedure TNetworkBackupItemAddInfo.SetAutoSync(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TNetworkBackupItemAddInfo.SetBackupStatus(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TNetworkBackupItemAddInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TNetworkBackupItemAddInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TNetworkBackupItemAddInfo.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TNetworkBackupItemAddInfo.SetSyncInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TNetworkBackupItemAddInfo.Update;
begin
    // �Ѵ���
  if FindBackupItemInfo then
    Exit;

    // ���
  BackupItemInfo := TNetworkBackupItemInfo.Create( BackupPath, IsFile );
  BackupItemInfo.SetBackupStatus( IsDisable, IsBackupNow );
  BackupItemInfo.SetAutoSyncInfo( IsAutoSync, LasSyncTime );
  BackupItemInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemList.Add( BackupItemInfo );

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TNetworkBackupItemRemoveInfo }

procedure TNetworkBackupItemRemoveInfo.Update;
begin
    // ������
  if not FindBackupItemInfo then
    Exit;

    // ɾ��
  BackupItemList.Delete( BackupItemIndex );
end;

{ TNetworkBackupItemSetIsDisableInfo }

procedure TNetworkBackupItemSetIsDisableInfo.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TNetworkBackupItemSetIsDisableInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsDisable := IsDisable;
end;

{ TNetworkBackupItemSetIsBackupNowInfo }

procedure TNetworkBackupItemSetIsBackupNowInfo.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TNetworkBackupItemSetIsBackupNowInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsBackupNow := IsBackupNow;
end;

{ TNetworkBackupItemSetLastSyncTimeInfo }

procedure TNetworkBackupItemSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TNetworkBackupItemSetLastSyncTimeInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.LasSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TNetworkBackupItemSetAutoSyncInfo }

procedure TNetworkBackupItemSetAutoSyncInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TNetworkBackupItemSetAutoSyncInfo.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TNetworkBackupItemSetAutoSyncInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsAutoSync := IsAutoSync;
  BackupItemInfo.SyncTimeType := SyncTimeType;
  BackupItemInfo.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TNetworkBackupItemSetSpaceInfo }

procedure TNetworkBackupItemSetSpaceInfo.SetSpaceInfo(_FileCount: Integer;
  _ItemSize, _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TNetworkBackupItemSetSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
end;

{ TNetworkBackupItemAddCompletedSpaceInfo }

procedure TNetworkBackupItemAddCompletedSpaceInfo.SetAddCompetedSpace(
  _AddCompletedSpace: Integer);
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TNetworkBackupItemAddCompletedSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.CompletedSize := BackupItemInfo.CompletedSize + AddCompletedSpace;
end;

{ TLocalBackupItemWriteInfo }

procedure TLocalBackupItemWriteInfo.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( BackupItemInfo.SyncTimeType, BackupItemInfo.SyncTimeValue );
  BackupItemInfo.NextSyncTime := IncMinute( BackupItemInfo.LasSyncTime, SyncMins );
end;

{ TNetworkBackupItemWriteInfo }

procedure TNetworkBackupItemWriteInfo.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( BackupItemInfo.SyncTimeType, BackupItemInfo.SyncTimeValue );
  BackupItemInfo.NextSyncTime := IncMinute( BackupItemInfo.LasSyncTime, SyncMins );
end;

end.
