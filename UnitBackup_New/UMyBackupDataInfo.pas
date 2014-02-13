unit UMyBackupDataInfo;

interface

uses UFileBaseInfo, Generics.Collections, UDataSetInfo, UMyUtil, DateUtils, classes;

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
  public  // ��������
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public  // ����ɾ���ļ�����
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public  // ������
    IncludeFilterList : TFileFilterList;  // �����ļ� ������
    ExcludeFilterList : TFileFilterList;  // �ų��ļ� ������
  public
    constructor Create( _BackupPath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetDeletedInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    destructor Destroy; override;
  end;
  TBackupItemList = class( TObjectList<TBackupItemInfo> )end;

    // Ŀ�� Item
  TDesItemInfo = class
  public
    DesItemID : string;
    BackupItemList : TBackupItemList;
  public
    constructor Create( _DesItemID : string );
    destructor Destroy; override;
  end;
  TDesItemList = class( TObjectList<TDesItemInfo> )end;

    // ����Ŀ�� Item
  TLocalDesItemInfo = class( TDesItemInfo )
  end;

    // ����Ŀ�� Item
  TNetworkDesItemInfo = class( TDesItemInfo )
  end;

    // ������Ϣ
  TMyBackupInfo = class( TMyDataInfo )
  public
    DesItemList : TDesItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TDesItemListAccessInfo = class
  protected
    DesItemList : TDesItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TDesItemAccessInfo = class( TDesItemListAccessInfo )
  public
    DesItemID : string;
  protected
    DesItemIndex : Integer;
    DesItemInfo : TDesItemInfo;
  public
    constructor Create( _DesItemID : string );
  protected
    function FindDesItemInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TBackupItemListAccessInfo = class( TDesItemAccessInfo )
  protected
    BackupItemList : TBackupItemList;
  protected
    function FindBackupItemList : Boolean;
  end;

    // ���� ���ݽӿ�
  TBackupItemAccessInfo = class( TBackupItemListAccessInfo )
  public
    BackupPath : string;
  protected
    BackupItemIndex : Integer;
    BackupItemInfo : TBackupItemInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemInfo: Boolean;
  end;

{$EndRegion}

{$Region ' Ŀ����Ϣ �����޸� ' }

    // ���
  TDesItemAddInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  end;

    // ��� ����Ŀ��
  TDesItemAddLocalInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  end;

    // ��� ����Ŀ��
  TDesItemAddNetworkInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  end;


    // ɾ��
  TDesItemRemoveInfo = class( TDesItemAccessInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ������Ϣ �����޸� ' }

    // �޸ĸ���
  TBackupItemWriteInfo = class( TBackupItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ·����ɾ ' }

    // ���
  TBackupItemAddInfo = class( TBackupItemWriteInfo )
  public
    IsFile : boolean;
  public
    IsDisable, IsBackupNow : boolean;
  public
    IsAutoSync : boolean;
    LastSyncTime : TDateTime;
  public
    SyncTimeType, SyncTimeValue : integer;
  public
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public
    IsKeepDeleted : boolean;
    KeepEditionCount : integer;
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : boolean; _LastSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  end;

    // ɾ��
  TBackupItemRemoveInfo = class( TBackupItemAccessInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�״̬ ' }

    // �Ƿ� ��ֹ����
  TBackupItemSetIsDisableInfo = class( TBackupItemAccessInfo )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  end;

    // �Ƿ� Backup Now ����
  TBackupItemSetIsBackupNowInfo = class( TBackupItemAccessInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸�ͬ�� ' }

    // ���� ��һ�� ͬ��ʱ��
  TBackupItemSetLastSyncTimeInfo = class( TBackupItemWriteInfo )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  end;


    // ���� ͬ������
  TBackupItemSetAutoSyncInfo = class( TBackupItemWriteInfo )
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

  TBackupItemSetRecycleInfo = class( TBackupItemAccessInfo )
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
  TBackupItemSetSpaceInfoInfo = class( TBackupItemAccessInfo )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  end;


    // ��� �������Ϣ
  TBackupItemSetAddCompletedSpaceInfo = class( TBackupItemAccessInfo )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Ŀ����Ϣ ���ݶ�ȡ ' }

    // �ָ���Ϣ
  TLocalRestoreInfo = class
  public
    DesPath, SourcePath : string;
    IsFile : Boolean;
    FileCount : Integer;
    ItemSpace : Int64;
    LastSyncTime : TDateTime;
  public
    constructor Create( _DesPath, _SourcePath : string );
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSpace : Int64 );
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  end;
  TLocalRestoreList = class( TObjectList<TLocalRestoreInfo> )end;


    // ��ȡ �����ܿռ���Ϣ
  TDesItemListReadTotalSpace = class( TDesItemListAccessInfo )
  public
    function get : Int64;
  end;

    // ��ȡ ����Ŀ���б�
  TDesItemListReadLocalList = class( TDesItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ���ػָ��б�
  TDesItemListReadLocalRestoreList = class( TDesItemListAccessInfo )
  public
    function get : TLocalRestoreList;
  end;

    // ��ȡ ���б���·��
  TDesItemReadBackupList = class( TBackupItemListAccessInfo )
  public
    function get : TStringList;
  end;

    // Ŀ����Ϣ ��ȡ
  DesItemInfoReadUtil = class
  public
    class function ReadTotalSpace : Int64;
    class function ReadLocaDesList : TStringList;
    class function ReadLocalRestoreList : TLocalRestoreList;
  public
    class function ReadBackupList( DesItemID : string ): TStringList;
  end;

{$EndRegion}

{$Region ' ������Ϣ ���ݶ�ȡ ' }

    // ��ȡ �Ƿ񱸷���Ч
  TBackupItemReadIsEnable = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ񱣴�ɾ���ļ�
  TBackupItemReadIsKeepDeleted = class( TBackupItemAccessInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ ����ɾ���ļ��汾��
  TBackupItemReadKeepDeletedCount = class( TBackupItemAccessInfo )
  public
    function get : Integer;
  end;

    // ��ȡ ����������
  TBackupItemReadIncludeFilter = class( TBackupItemAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ �ų�������
  TBackupItemReadExcludeFilter = class( TBackupItemAccessInfo )
  public
    function get : TFileFilterList;
  end;


    // ������Ϣ ��ȡ
  BackupItemInfoReadUtil = class
  public
    class function ReadIsEnable( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsKeepDeleted( DesItemID, BackupPath : string ): Boolean;
    class function ReadIsKeepEditionCount( DesItemID, BackupPath : string ): Integer;
  public
    class function ReadIncludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
    class function ReadExcludeFilter( DesItemID, BackupPath : string ): TFileFilterList;
  end;

{$EndRegion}


var
  MyBackupInfo : TMyBackupInfo;

implementation

{ TMyBackupInfo }

constructor TMyBackupInfo.Create;
begin
  inherited;
  DesItemList := TDesItemList.Create;
end;

destructor TMyBackupInfo.Destroy;
begin
  DesItemList.Free;
  inherited;
end;

{ TBackupItemInfo }

constructor TBackupItemInfo.Create(_BackupPath: string);
begin
  BackupPath := _BackupPath;
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

procedure TBackupItemInfo.SetDeletedInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemInfo.SetEncryptInfo(_IsEncrypt: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
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


{ TLocalDesRestoreInfo }

constructor TLocalRestoreInfo.Create(_DesPath, _SourcePath: string);
begin
  DesPath := _DesPath;
  SourcePath := _SourcePath;
end;

procedure TLocalRestoreInfo.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TLocalRestoreInfo.SetLastSyncTime(_LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalRestoreInfo.SetSpaceInfo(_FileCount: Integer;
  _ItemSpace: Int64);
begin
  FileCount := _FileCount;
  ItemSpace := _ItemSpace;
end;

{ TDesItemInfo }

constructor TDesItemInfo.Create(_DesItemID: string);
begin
  DesItemID := _DesItemID;
  BackupItemList := TBackupItemList.Create;
end;

destructor TDesItemInfo.Destroy;
begin
  BackupItemList.Free;
  inherited;
end;

{ TDesItemListAccessInfo }

constructor TDesItemListAccessInfo.Create;
begin
  MyBackupInfo.EnterData;
  DesItemList := MyBackupInfo.DesItemList;
end;

destructor TDesItemListAccessInfo.Destroy;
begin
  MyBackupInfo.LeaveData;
  inherited;
end;

{ TDesItemAccessInfo }

constructor TDesItemAccessInfo.Create( _DesItemID : string );
begin
  inherited Create;
  DesItemID := _DesItemID;
end;

function TDesItemAccessInfo.FindDesItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to DesItemList.Count - 1 do
    if ( DesItemList[i].DesItemID = DesItemID ) then
    begin
      Result := True;
      DesItemIndex := i;
      DesItemInfo := DesItemList[i];
      break;
    end;
end;

{ TDesItemAddInfo }

procedure TDesItemAddInfo.Update;
begin
  if FindDesItemInfo then
    Exit;

  DesItemInfo := TDesItemInfo.Create( DesItemID );
  DesItemList.Add( DesItemInfo );
end;

{ TDesItemRemoveInfo }

procedure TDesItemRemoveInfo.Update;
begin
  if not FindDesItemInfo then
    Exit;

  DesItemList.Delete( DesItemIndex );
end;

{ TBackupItemListAccessInfo }

function TBackupItemListAccessInfo.FindBackupItemList : Boolean;
begin
  Result := FindDesItemInfo;
  if Result then
    BackupItemList := DesItemInfo.BackupItemList
  else
    BackupItemList := nil;
end;

{ TBackupItemAccessInfo }

procedure TBackupItemAccessInfo.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TBackupItemAccessInfo.FindBackupItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    if ( BackupItemList[i].BackupPath = BackupPath ) then
    begin
      Result := True;
      BackupItemIndex := i;
      BackupItemInfo := BackupItemList[i];
      break;
    end;
end;

{ TBackupItemAddInfo }

procedure TBackupItemAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddInfo.SetBackupStatus( _IsDisable, _IsBackupNow : boolean );
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemAddInfo.SetAutoSyncInfo( _IsAutoSync : boolean; _LastSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemAddInfo.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddInfo.SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemAddInfo.SetDeletedInfo( _IsKeepDeleted : boolean; _KeepEditionCount : integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemAddInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddInfo.Update;
begin
  if FindBackupItemInfo then
    Exit;

  BackupItemInfo := TBackupItemInfo.Create( BackupPath );
  BackupItemInfo.SetIsFile( IsFile );
  BackupItemInfo.SetBackupStatus( IsDisable, IsBackupNow );
  BackupItemInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupItemInfo.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
  BackupItemInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemList.Add( BackupItemInfo );

    // ˢ��ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemRemoveInfo }

procedure TBackupItemRemoveInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemList.Delete( BackupItemIndex );
end;

{ TDesItemListReadTotalSpace }

function TDesItemListReadTotalSpace.get: Int64;
var
  i, j : Integer;
begin
  Result := 0;
  for i := 0 to DesItemList.Count - 1 do
    for j := 0 to DesItemList[i].BackupItemList.Count - 1 do
      Result := Result + DesItemList[i].BackupItemList[j].ItemSize;
end;

{ DesItemInfoReadUtil }

class function DesItemInfoReadUtil.ReadBackupList(
  DesItemID: string): TStringList;
var
  DesItemReadBackupList : TDesItemReadBackupList;
begin
  DesItemReadBackupList := TDesItemReadBackupList.Create( DesItemID );
  Result := DesItemReadBackupList.get;
  DesItemReadBackupList.Free;
end;

class function DesItemInfoReadUtil.ReadLocaDesList: TStringList;
var
  DesItemListReadLocalList : TDesItemListReadLocalList;
begin
  DesItemListReadLocalList := TDesItemListReadLocalList.Create;
  Result := DesItemListReadLocalList.get;
  DesItemListReadLocalList.Free;
end;

class function DesItemInfoReadUtil.ReadLocalRestoreList: TLocalRestoreList;
var
  DesItemListReadLocalRestoreList : TDesItemListReadLocalRestoreList;
begin
  DesItemListReadLocalRestoreList := TDesItemListReadLocalRestoreList.Create;
  Result := DesItemListReadLocalRestoreList.get;
  DesItemListReadLocalRestoreList.Free;
end;

class function DesItemInfoReadUtil.ReadTotalSpace: Int64;
var
  DesItemListReadTotalSpace : TDesItemListReadTotalSpace;
begin
  DesItemListReadTotalSpace := TDesItemListReadTotalSpace.Create;
  Result := DesItemListReadTotalSpace.get;
  DesItemListReadTotalSpace.Free;
end;

{ TDesItemListReadLocalList }

function TDesItemListReadLocalList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to DesItemList.Count - 1 do
    if DesItemList[i] is TLocalDesItemInfo then
      Result.Add( DesItemList[i].DesItemID );
end;

{ TDesItemListReadLocalRestoreList }

function TDesItemListReadLocalRestoreList.get: TLocalRestoreList;
var
  i, j: Integer;
  DesInfo : TDesItemInfo;
  BackupList : TBackupItemList;
  BackupInfo : TBackupItemInfo;
  DesRestoreInfo : TLocalRestoreInfo;
begin
  Result := TLocalRestoreList.Create;
  for i := 0 to DesItemList.Count - 1 do
  begin
    DesInfo := DesItemList[i];
    if not ( DesInfo is TLocalDesItemInfo ) then
      Continue;
    BackupList := DesInfo.BackupItemList;
    for j := 0 to BackupList.Count - 1 do
    begin
      BackupInfo := BackupList[j];
      if BackupInfo.CompletedSize < BackupInfo.ItemSize then
        Continue;
      DesRestoreInfo := TLocalRestoreInfo.Create( DesInfo.DesItemID, BackupInfo.BackupPath );
      DesRestoreInfo.SetIsFile( BackupInfo.IsFile );
      DesRestoreInfo.SetSpaceInfo( BackupInfo.FileCount, BackupInfo.ItemSize );
      DesRestoreInfo.SetLastSyncTime( BackupInfo.LasSyncTime );
      Result.Add( DesRestoreInfo );
    end;
  end;
end;

{ TDesItemReadBackupList }

function TDesItemReadBackupList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  if not FindBackupItemList then
    Exit;
  for i := 0 to BackupItemList.Count - 1 do
    Result.Add( BackupItemList[i].BackupPath );
end;

{ BackupItemReadUtil }

class function BackupItemInfoReadUtil.ReadExcludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadExcludeFilter : TBackupItemReadExcludeFilter;
begin
  BackupItemReadExcludeFilter := TBackupItemReadExcludeFilter.Create( DesItemID );
  BackupItemReadExcludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadExcludeFilter.get;
  BackupItemReadExcludeFilter.Free;
end;

class function BackupItemInfoReadUtil.ReadIncludeFilter(DesItemID,
  BackupPath: string): TFileFilterList;
var
  BackupItemReadIncludeFilter : TBackupItemReadIncludeFilter;
begin
  BackupItemReadIncludeFilter := TBackupItemReadIncludeFilter.Create( DesItemID );
  BackupItemReadIncludeFilter.SetBackupPath( BackupPath );
  Result := BackupItemReadIncludeFilter.get;
  BackupItemReadIncludeFilter.Free;
end;

class function BackupItemInfoReadUtil.ReadIsEnable(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsEnable : TBackupItemReadIsEnable;
begin
  BackupItemReadIsEnable := TBackupItemReadIsEnable.Create( DesItemID );
  BackupItemReadIsEnable.SetBackupPath( BackupPath );
  Result := BackupItemReadIsEnable.get;
  BackupItemReadIsEnable.Free;
end;

class function BackupItemInfoReadUtil.ReadIsKeepDeleted(DesItemID,
  BackupPath: string): Boolean;
var
  BackupItemReadIsKeepDeleted : TBackupItemReadIsKeepDeleted;
begin
  BackupItemReadIsKeepDeleted := TBackupItemReadIsKeepDeleted.Create( DesItemID );
  BackupItemReadIsKeepDeleted.SetBackupPath( BackupPath );
  Result := BackupItemReadIsKeepDeleted.get;
  BackupItemReadIsKeepDeleted.Free;
end;

class function BackupItemInfoReadUtil.ReadIsKeepEditionCount(DesItemID,
  BackupPath: string): Integer;
var
  BackupItemReadKeepDeletedCount : TBackupItemReadKeepDeletedCount;
begin
  BackupItemReadKeepDeletedCount := TBackupItemReadKeepDeletedCount.Create( DesItemID );
  BackupItemReadKeepDeletedCount.SetBackupPath( BackupPath );
  Result := BackupItemReadKeepDeletedCount.get;
  BackupItemReadKeepDeletedCount.Free;
end;

{ TBackupItemReadIsEnable }

function TBackupItemReadIsEnable.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := not BackupItemInfo.IsDisable;
end;

{ TBackupItemReadIsKeepDeleted }

function TBackupItemReadIsKeepDeleted.get: Boolean;
begin
  Result := False;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.IsKeepDeleted;
end;

{ TBackupItemReadKeepDeletedCount }

function TBackupItemReadKeepDeletedCount.get: Integer;
begin
  Result := 0;
  if not FindBackupItemInfo then
    Exit;
  Result := BackupItemInfo.KeepEditionCount;
end;

{ TBackupReadIncludeFilter }

function TBackupItemReadIncludeFilter.get: TFileFilterList;
var
  IncludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  IncludeFilterList := BackupItemInfo.IncludeFilterList;
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    FilterType := IncludeFilterList[i].FilterType;
    FilterStr := IncludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupReadExcludeFilter }

function TBackupItemReadExcludeFilter.get: TFileFilterList;
var
  ExcludeFilterList : TFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  if not FindBackupItemInfo then
    Exit;
  ExcludeFilterList := BackupItemInfo.ExcludeFilterList;
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    FilterType := ExcludeFilterList[i].FilterType;
    FilterStr := ExcludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TBackupItemWriteInfo }

procedure TBackupItemWriteInfo.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( BackupItemInfo.SyncTimeType, BackupItemInfo.SyncTimeValue );
  BackupItemInfo.NextSyncTime := IncMinute( BackupItemInfo.LasSyncTime, SyncMins );
end;


{ TBackupItemSetIsDisableInfo }

procedure TBackupItemSetIsDisableInfo.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemSetIsDisableInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsDisable := IsDisable;
end;

{ TBackupItemSetIsBackupNowInfo }

procedure TBackupItemSetIsBackupNowInfo.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsBackupNow := IsBackupNow;
end;

{ TBackupItemSetLastSyncTimeInfo }

procedure TBackupItemSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.LasSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemSetAutoSyncInfo }

procedure TBackupItemSetAutoSyncInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncInfo.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;

  BackupItemInfo.IsAutoSync := IsAutoSync;
  BackupItemInfo.SyncTimeType := SyncTimeType;
  BackupItemInfo.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TBackupItemSetRecycleInfo }

procedure TBackupItemSetRecycleInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemSetRecycleInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.IsKeepDeleted := IsKeepDeleted;
  BackupItemInfo.KeepEditionCount := KeepEditionCount;
end;

{ TBackupItemSetSpaceInfoInfo }

procedure TBackupItemSetSpaceInfoInfo.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.FileCount := FileCount;
  BackupItemInfo.ItemSize := ItemSize;
  BackupItemInfo.CompletedSize := CompletedSize;
end;


{ TBackupItemSetAddCompletedSpaceInfo }

procedure TBackupItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceInfo.Update;
begin
  if not FindBackupItemInfo then
    Exit;
  BackupItemInfo.CompletedSize := BackupItemInfo.CompletedSize + AddCompletedSpace;
end;


{ TDesItemAddLocalInfo }

procedure TDesItemAddLocalInfo.Update;
begin
  if FindDesItemInfo then
    Exit;

  DesItemInfo := TLocalDesItemInfo.Create( DesItemID );
  DesItemList.Add( DesItemInfo );
end;

{ TDesItemAddNetworkInfo }

procedure TDesItemAddNetworkInfo.Update;
begin
  if FindDesItemInfo then
    Exit;

  DesItemInfo := TNetworkDesItemInfo.Create( DesItemID );
  DesItemList.Add( DesItemInfo );
end;

end.
