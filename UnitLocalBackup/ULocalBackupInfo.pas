unit ULocalBackupInfo;

interface

uses UChangeInfo, Generics.Collections, UModelUtil, UMyUtil, Classes, UFileBaseInfo,
     SysUtils, DateUtils, UDataSetInfo;

type

{$Region ' Դ·�� ���ݽṹ ' }

    // Ŀ��·�� ��Ϣ
  TLocalBackupSourceDesInfo = class
  public
    FullPath : string;
    SourceSize, CompletedSize : Int64;
    DeletedSpace : Int64;
  public
    constructor Create( _FullPath : string );
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
  end;
  TLocalBackupSourceDesList = class( TObjectList<TLocalBackupSourceDesInfo> )end;

    // Դ·�� ��Ϣ
  TLocalBackupSourceInfo = class
  public
    FullPath, PathType : string;
    IsBackupNow, IsDisable : Boolean;
  public     // �Զ�ͬ��
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public    // ����ɾ���ļ�
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    FileCount : Integer;
    FileSize : Int64;
  public             // ������
    IncludeFilterList : TFileFilterList;
    ExcludeFilterList : TFileFilterList;
  public
    DesPathList : TLocalBackupSourceDesList; // Ŀ��·��
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime, _NextSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    destructor Destroy; override;
  end;
  TLocalBackupSourceList = class( TObjectList<TLocalBackupSourceInfo> )end;


    // ���ݶ���
  TMyLocalBackupSourceInfo = class( TMyDataInfo )
  public
    LocalBackupSourceList : TLocalBackupSourceList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' Դ·�� ���ݽӿ� ' }

  {$Region ' Դ·�� ' }

    // ���� ����
  TLocalBackupSourceAccessInfo = class
  protected
    LocalBackupSourceList : TLocalBackupSourceList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� Item
  TLocalBackupSourceItemAccessInfo = class( TLocalBackupSourceAccessInfo )
  protected
    FullPath : string;
  protected
    SourceIndex : Integer;
    SourceInfo : TLocalBackupSourceInfo;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSourceInfo : Boolean;virtual;
  end;

  {$EndRegion}

  {$Region ' Ŀ��·�� ' }

    // ���� ԴItem Ŀ�꼯��
  TLocalBackupSourceItemDesAccessInfo = class( TLocalBackupSourceItemAccessInfo )
  protected
    DesPathList : TLocalBackupSourceDesList;
  protected
    function FindSourceInfo : Boolean;override;
  end;

    // ���� ԴItem Ŀ��Item
  TLocalBackupSourceItemDesPathAccessInfo = class( TLocalBackupSourceItemDesAccessInfo )
  public
    DesPath : string;
  protected
    DesPathIndex : Integer;
    DesPathInfo : TLocalBackupSourceDesInfo;
  public
    procedure SetDesPath( _DesPath : string );
  protected
    function FindDesPathInfo : Boolean;
  end;

  {$EndRegion}

  {$Region ' ������ ' }

    // ����������
  TLocalBackupSourceItemIncludeAccessInfo = class( TLocalBackupSourceItemAccessInfo )
  protected
    IncludeFilterList : TFileFilterList;
  protected
    function FindSourceInfo : Boolean;override;
  end;

    // �ų� ������
  TLocalBackupSourceItemExcludeAccessInfo = class( TLocalBackupSourceItemAccessInfo )
  protected
    ExcludeFilterList : TFileFilterList;
  protected
    function FindSourceInfo : Boolean;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Դ·�� �����޸� ' }

    // �޸�
  TLocalBackupSourceWriteInfo = class( TLocalBackupSourceItemAccessInfo )
  protected
    procedure RefreshNextSyncTime;
  end;

  {$Region ' ������Ϣ�޸� ' }

    // ���
  TLocalBackupSourceAddInfo = class( TLocalBackupSourceWriteInfo )
  private
    PathType : string;
    IsBackupNow, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime, _NextSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;
  end;

    // ���ÿռ���Ϣ
  TLocalBackupSourceSpaceInfo = class( TLocalBackupSourceWriteInfo )
  private
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;
  end;

    // ɾ��
  TLocalBackupSourceRemoveInfo = class( TLocalBackupSourceWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �޸� ͬ��ʱ�� ' }

    // ���� ��һ�� ͬ��ʱ��
  TLocalBackupSourceSetLastSyncTimeInfo = class( TLocalBackupSourceWriteInfo )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  end;

    // ���� ͬ������
  TLocalBackupSourceSetSyncMinsInfo = class( TLocalBackupSourceWriteInfo )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' ���ñ���ɾ���ļ���Ϣ ' }

  TLocalBackupSorceSetDeleteInfo = class( TLocalBackupSourceWriteInfo )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;
  private
    procedure ResetToFace;
    procedure AddDeletedFace( DesPathInfo : TLocalBackupSourceDesInfo );
    procedure RemoveDeletedFace( DesPathInfo : TLocalBackupSourceDesInfo );
  end;

  {$EndRegion}

  {$Region ' ���� ·��״̬ ' }

    // �Ƿ� ��ֹ����
  TLocalBackupSourceIsDisableInfo = class( TLocalBackupSourceWriteInfo )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  end;

    // �Ƿ� Backup Now ����
  TLocalBackupSourceIsBackupNowInfo = class( TLocalBackupSourceWriteInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' Դ·�� ������ �޸� ' }

  {$Region ' ���������� ' }

    // ���� ������ �޸�
  TLocalBackupSourceIncludeFilterWriteInfo = class( TLocalBackupSourceItemIncludeAccessInfo )
  end;

      // ���
  TLocalBackupSourceIncludeFilterClearInfo = class( TLocalBackupSourceIncludeFilterWriteInfo )
  public
    procedure Update;
  end;

      // ���
  TLocalBackupSourceIncludeFilterAddInfo = class( TLocalBackupSourceIncludeFilterWriteInfo )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' �ų� ������ ' }

    // �ų� ������ �޸�
  TLocalBackupSourceExcludeFilterChangeInfo = class( TLocalBackupSourceItemExcludeAccessInfo )
  end;

    // ���
  TLocalBackupSourceExcludeFilterClearInfo = class( TLocalBackupSourceExcludeFilterChangeInfo )
  public
    procedure Update;
  end;

    // ���
  TLocalBackupSourceExcludeFilterAddInfo = class( TLocalBackupSourceExcludeFilterChangeInfo )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Դ·��Ŀ�� �޸� ' }

    // �޸�
  TLocalBackupSourceWriteDesInfo = class( TLocalBackupSourceItemDesPathAccessInfo )
  end;

    // ���
  TLocalBackupSourceAddDesInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    SourceSize, CompltedSize : Int64;
    DeletedSpace : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;
  end;

      // ��� ����ɿռ���Ϣ
  TLocalBackupSourceAddDesCompletedSpaceInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    AddCompltedSize : Int64;
  public
    procedure SetAddCompltedSize( _AddCompltedSize : Int64 );
    procedure Update;
  end;

    // ���ÿռ���Ϣ
  TLocalBackupSourceSetDesSpaceInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    SourceSize, CompltedSize : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;
  end;

    // ��� ��ɾ�� �ռ���Ϣ
  TLocalBackupSorceAddDeletedSpaceInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    AddDeletedSpace : Int64;
  public
    procedure SetAddDeletedSpace( _AddDeletedSpace : Int64 );
    procedure Update;
  end;

    // ���� ��ɾ�� �ռ���Ϣ
  TLocalBackupSorceSetDeletedSpaceInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    DeletedSpace : Int64;
  public
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;
  end;

    // ɾ��
  TLocalBackupSourceRemoveDesInfo = class( TLocalBackupSourceWriteDesInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Դ·�� ���ݶ�ȡ ' }

  {$Region ' ��ȡ ������Ϣ ' }

    // ����
  TMyLocalBackupSourceReadInfo = class( TLocalBackupSourceAccessInfo )
  end;

    // ��ȡ �ܿռ���Ϣ
  TMyLocalBackupSourceReadTotalSpace = class( TMyLocalBackupSourceReadInfo )
  public
    function get : Int64;
  end;

    // ��ȡ ���б���·��
  TMyLocalBackupSourceReadPathList = class( TMyLocalBackupSourceReadInfo )
  public
    function get : TStringList;
  end;

    // ��ȡ ����BackupNow·��
  TMyLocalBackupSourceReadBackupNowPathList = class( TMyLocalBackupSourceReadInfo)
  public
    function get : TStringList;
  end;

    // ��ȡ ���� ����ͬ�����ڵ� ·��
  TMyLocalBackupSourceReadAutoSyncPathList = class( TMyLocalBackupSourceReadInfo)
  public
    function get : TStringList;
  end;

  {$EndRegion}

  {$Region ' ��ȡ Item ��Ϣ ' }

    // ����
  TMyLocalBackupSourceItemReadInfo = class( TLocalBackupSourceItemAccessInfo )
  end;

    // ��ȡ ������Ϣ
  TMyLocalBackupSourceReadConfig = class( TMyLocalBackupSourceItemReadInfo )
  private
    BackupConfig : TLocalBackupConfigInfo;
  public
    function get : TLocalBackupConfigInfo;
  private
    procedure FindGenernal;
    procedure FindDestination;
    procedure FindFilter;
  private
    function getFilterList( FileFilterList : TFileFilterList ) : TFileFilterList;
  end;

    // ��ȡ Դ·�� �Ƿ� ��Ч
  TMyLocalBackupSourceReadIsEnable = class( TMyLocalBackupSourceItemReadInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ Դ·�� �Ƿ� ����ɾ���ļ�
  TMyLocalBackupSourceReadIsKeepDeleted = class( TMyLocalBackupSourceItemReadInfo )
  public
    function get : Boolean;
  end;

    // ��ȡ Դ·�� �Ƿ� ɾ���ļ��İ汾��
  TMyLocalBackupSourceReadKeepEditionCount = class( TMyLocalBackupSourceItemReadInfo )
  public
    function get : Integer;
  end;

  {$EndRegion}

  {$Region ' ��ȡ Ŀ��·�� ��Ϣ ' }

      // ��ȡ Ŀ��·��
  TMyLocalBackupSourceReadDesPathList = class( TLocalBackupSourceItemDesAccessInfo )
  public
    function get : TStringList;
  end;

      // ��ȡ Ŀ��·�� �Ƿ���Ч
  TMyLocalBackupSourceReadDesIsEnable = class( TLocalBackupSourceItemDesPathAccessInfo )
  public
    function get : Boolean;
  end;

  {$EndRegion}

  {$Region ' ��ȡ ������ ��Ϣ ' }

    // ��ȡ ����������
  TMyLocalBackupSourceReadIncludeFilter = class( TLocalBackupSourceItemIncludeAccessInfo )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ �ų�������
  TMyLocalBackupSourceReadExcludeFilter = class( TLocalBackupSourceItemExcludeAccessInfo )
  public
    function get : TFileFilterList;
  end;

  {$EndRegion}

    // ������
  MyLocalBackupSourceReadUtil = class
  public             // ��ȡ ������Ϣ
    class function getTotalSapce : Int64;
    class function getSourcePathLilst : TStringList;
    class function getBackupNowPathList : TStringList;
    class function getAutoSyncPathList : TStringList;
  public             // ��ȡ Item ��Ϣ
    class function getConfig( FullPath : string ): TLocalBackupConfigInfo;
    class function getIsEnable( FullPath : string ): Boolean;
    class function getIsKeepDeleted( FullPath : string ) : Boolean;
    class function getKeedEditionCount( FullPath : string ): Integer;
  public            // ��ȡ Ŀ��·�� ��Ϣ
    class function getDesPathList( FullPath : string ): TStringList;
    class function getDesIsEnable( SourceRoot, DesRoot : string ): Boolean;
  public            // ��ȡ ������ ��Ϣ
    class function ReadIncludeFilter( FullPath : string ): TFileFilterList;
    class function ReadExcludeFilter( FullPath : string ): TFileFilterList;
  end;

{$EndRegion}


{$Region ' Ŀ��·�� ���ݽṹ ' }

    // Ŀ��·��
  TLocalBackupDesInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TLocalBackupDesPair = TPair< string , TLocalBackupDesInfo >;
  TLocalBackupDesHash = class(TStringDictionary< TLocalBackupDesInfo >);

    // ���ݶ���
  TMyLocalBackupDesInfo = class( TMyDataInfo )
  public
    DestinationHash : TLocalBackupDesHash; // ���ݵ�Ŀ��λ����Ϣ
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' Ŀ��·�� ���ݽӿ� ' }

    // ���� ����
  TLocalBackupDesAccessInfo = class
  public
    DestinationHash : TLocalBackupDesHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� Item
  TLocalBackupDesItemAccessInfo = class( TLocalBackupDesAccessInfo )
  public
    FullPath : string;
  protected
    BackupDesInfo : TLocalBackupDesInfo;
  public
    constructor Create( _FullPath : string );
  protected
    function FindBackupDesInfo : Boolean;
  end;

{$EndRegion}

{$Region ' Ŀ��·�� �����޸� ' }

    // �޸� ����Ŀ��·��
  TLocalBackupDesWriteInfo = class( TLocalBackupDesItemAccessInfo )
  end;

    // ��� Ŀ��·��
  TLocalBackupDesAddInfo = class( TLocalBackupDesWriteInfo )
  public
    procedure Update;
  end;

    // ɾ�� Ŀ��·��
  TLocalBackupDesRemoveInfo = class( TLocalBackupDesWriteInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' Ŀ��·�� ���ݶ�ȡ ' }


    // ��ȡ ����·��
  TMyLocalBackupDesReadPathList = class( TLocalBackupDesAccessInfo )
  public
    function get : TStringList;
  end;

  TLocalBackupDesReadIsEnable = class( TLocalBackupDesItemAccessInfo )
  public
    function get : Boolean;
  end;

  MyLocalBackupDesReadUtil = class
  public
    class function getAllDesPath : TStringList;
    class function getIsEnable( FullPath : string ): Boolean;
  end;

{$EndRegion}


var
  MyLocalBackupSourceInfo : TMyLocalBackupSourceInfo;
  MyLocalBackupDesInfo : TMyLocalBackupDesInfo;

implementation

uses  ULocalBackupControl, ULocalBackupScan, ULocalBackupFace;

{ TLocalBackupSourceInfo }

constructor TLocalBackupSourceInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
  FileCount := 0;
  FileSize := 0;
  IsKeepDeleted := False;
  DesPathList := TLocalBackupSourceDesList.Create;
  IncludeFilterList := TFileFilterList.Create;
  ExcludeFilterList := TFileFilterList.Create;
end;

destructor TLocalBackupSourceInfo.Destroy;
begin
  IncludeFilterList.Free;
  ExcludeFilterList.Free;
  DesPathList.Free;
  inherited;
end;

procedure TLocalBackupSourceInfo.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime, _NextSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
  NextSyncTime := _NextSyncTime;
end;

procedure TLocalBackupSourceInfo.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceInfo.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceInfo.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

{ TMyLocalBackupSourceInfo }

constructor TMyLocalBackupSourceInfo.Create;
begin
  inherited;
  LocalBackupSourceList := TLocalBackupSourceList.Create;
end;

destructor TMyLocalBackupSourceInfo.Destroy;
begin
  LocalBackupSourceList.Free;
  inherited;
end;

{ TLocalBackupSourceAddInfo }

procedure TLocalBackupSourceAddInfo.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime, _NextSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
  NextSyncTime := _NextSyncTime;
end;

procedure TLocalBackupSourceAddInfo.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceAddInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceAddInfo.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLocalBackupSourceAddInfo.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceAddInfo.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceAddInfo.Update;
begin
    // �Ѵ���
  if FindSourceInfo then
    Exit;

    // ���
  SourceInfo := TLocalBackupSourceInfo.Create( FullPath, PathType );
  SourceInfo.SetBackupInfo( IsBackupNow, IsDisable );
  SourceInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime, NextSyncTime );
  SourceInfo.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  SourceInfo.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  SourceInfo.SetSpaceInfo( FileCount, FileSize );
  LocalBackupSourceList.Add( SourceInfo );
end;

{ TLocalBackupSourceRemoveInfo }

procedure TLocalBackupSourceRemoveInfo.Update;
begin
    // ������
  if not FindSourceInfo then
    Exit;

    // ɾ��
  LocalBackupSourceList.Delete( SourceIndex );
end;


{ TLocalBackupSourceWriteInfo }

procedure TLocalBackupSourceWriteInfo.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( SourceInfo.SyncTimeType, SourceInfo.SyncTimeValue );
  SourceInfo.NextSyncTime := IncMinute( SourceInfo.LastSyncTime, SyncMins );
end;

{ TLocalBackupSourceSpaceInfo }

procedure TLocalBackupSourceSpaceInfo.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceSpaceInfo.Update;
begin
    // ������
  if not FindSourceInfo then
    Exit;

    // ���� �ռ���Ϣ
  SourceInfo.SetSpaceInfo( FileCount, FileSize );
end;

{ TDestinationInfo }

constructor TLocalBackupDesInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TMyDesPathRemoveInfo }

procedure TLocalBackupDesRemoveInfo.Update;
begin
    // ������
  if not FindBackupDesInfo then
    Exit;

    // ɾ�� ���ݽṹ
  DestinationHash.Remove( FullPath );
end;

{ TMyDesPathAddInfo }

procedure TLocalBackupDesAddInfo.Update;
begin
    // �Ѵ���
  if FindBackupDesInfo then
    Exit;

    // ��� ���ݽṹ
  BackupDesInfo := TLocalBackupDesInfo.Create( FullPath );
  DestinationHash.AddOrSetValue( FullPath, BackupDesInfo );
end;

{ TMyDestinationInfo }

constructor TMyLocalBackupDesInfo.Create;
begin
  inherited;
  DestinationHash := TLocalBackupDesHash.Create;
end;

destructor TMyLocalBackupDesInfo.Destroy;
begin
  DestinationHash.Free;
  inherited;
end;

{ TLocalBackupSourceAddDesInfo }

procedure TLocalBackupSourceAddDesInfo.SetDeletedSpace(_DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSourceAddDesInfo.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceAddDesInfo.Update;
begin
    // Ŀ��·�� �Ѵ���
  if FindDesPathInfo then
    Exit;

    // Դ·�� ������
  if DesPathList = nil then
    Exit;

    // ���
  DesPathInfo := TLocalBackupSourceDesInfo.Create( DesPath );
  DesPathInfo.SetSpaceInfo( SourceSize, CompltedSize );
  DesPathInfo.SetDeletedSpace( DeletedSpace );
  DesPathList.Add( DesPathInfo );
end;

{ TLocalBackupSourceDesInfo }

constructor TLocalBackupSourceDesInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  SourceSize := 0;
  CompletedSize := 0;
end;

procedure TLocalBackupSourceDesInfo.SetDeletedSpace(_DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSourceDesInfo.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompletedSize := _CompletedSize;
end;

{ TLocalBackupSourceRemoveDesInfo }

procedure TLocalBackupSourceRemoveDesInfo.Update;
begin
    // ������
  if not FindDesPathInfo then
    Exit;

    // ɾ��
  DesPathList.Delete( DesPathIndex );
end;

{ TLocalBackupSourceSetDesSpaceInfo }

procedure TLocalBackupSourceSetDesSpaceInfo.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceSetDesSpaceInfo.Update;
begin
    // ������
  if not FindDesPathInfo then
    Exit;

    // ���ÿռ���Ϣ
  DesPathInfo.SetSpaceInfo( SourceSize, CompltedSize );
end;

{ TLocalBackupSourceAddDesCompletedSpaceInfo }

procedure TLocalBackupSourceAddDesCompletedSpaceInfo.SetAddCompltedSize(
  _AddCompltedSize: Int64);
begin
  AddCompltedSize := _AddCompltedSize;
end;

procedure TLocalBackupSourceAddDesCompletedSpaceInfo.Update;
begin
    // ������
  if not FindDesPathInfo then
    Exit;

    // ���ÿռ���Ϣ
  DesPathInfo.CompletedSize := DesPathInfo.CompletedSize + AddCompltedSize;
end;

{ TMyLocalBackupDesReadPathList }

function TMyLocalBackupDesReadPathList.get: TStringList;
var
  p : TLocalBackupDesPair;
begin
  Result := TStringList.Create;
  for p in DestinationHash do
    Result.Add( p.Value.FullPath );
end;

{ MyLocalBackupDesUtil }

class function MyLocalBackupDesReadUtil.getAllDesPath: TStringList;
var
  MyLocalBackupDesReadPathList : TMyLocalBackupDesReadPathList;
begin
  MyLocalBackupDesReadPathList := TMyLocalBackupDesReadPathList.Create;
  Result := MyLocalBackupDesReadPathList.get;
  MyLocalBackupDesReadPathList.Free;
end;

{ TLocalBackupSourceIncludeFilterClearInfo }

procedure TLocalBackupSourceIncludeFilterClearInfo.Update;
begin
  if not FindSourceInfo then
    Exit;

  IncludeFilterList.Clear;
end;

{ TLocalBackupSourceIncludeFilterAddInfo }

procedure TLocalBackupSourceIncludeFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceIncludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
    // ������
  if not FindSourceInfo then
    Exit;

    // ���
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
  IncludeFilterList.Add( FilterInfo );
end;

{ TLocalBackupSourceExcludeFilterClearInfo }

procedure TLocalBackupSourceExcludeFilterClearInfo.Update;
begin
  if not FindSourceInfo then
    Exit;

  ExcludeFilterList.Clear;
end;

{ TLocalBackupSourceExcludeFilterAddInfo }

procedure TLocalBackupSourceExcludeFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceExcludeFilterAddInfo.Update;
var
  FilterInfo : TFileFilterInfo;
begin
    // ������
  if not FindSourceInfo then
    Exit;

    // ���
  FilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
  ExcludeFilterList.Add( FilterInfo );
end;

{ TMyLocalBackupSourceReadConfig }

procedure TMyLocalBackupSourceReadConfig.FindDestination;
var
  DesPathList : TStringList;
  SourceDesPathList : TLocalBackupSourceDesList;
  i : Integer;
begin
  DesPathList := TStringList.Create;
  SourceDesPathList := SourceInfo.DesPathList;
  for i := 0 to SourceDesPathList.Count - 1 do
    DesPathList.Add( SourceDesPathList[i].FullPath );
  BackupConfig.SetDesPathList( DesPathList );
end;

procedure TMyLocalBackupSourceReadConfig.FindFilter;
begin
  BackupConfig.SetIncludeFilterList( getFilterList( SourceInfo.IncludeFilterList ) );
  BackupConfig.SetExcludeFilterList( getFilterList( SourceInfo.ExcludeFilterList ) );
end;

procedure TMyLocalBackupSourceReadConfig.FindGenernal;
begin
  BackupConfig.SetBackupInfo( SourceInfo.IsBackupNow, SourceInfo.IsDisable );
  BackupConfig.SetSyncInfo( SourceInfo.IsAutoSync, SourceInfo.SyncTimeType, SourceInfo.SyncTimeValue );
  BackupConfig.SetDeleteInfo( SourceInfo.IsKeepDeleted, SourceInfo.KeepEditionCount );
end;

function TMyLocalBackupSourceReadConfig.get: TLocalBackupConfigInfo;
begin
  Result := nil;
  if not FindSourceInfo then
    Exit;

  BackupConfig := TLocalBackupConfigInfo.Create;
  FindGenernal;
  FindDestination;
  FindFilter;
  Result := BackupConfig;
end;

function TMyLocalBackupSourceReadConfig.getFilterList(
  FileFilterList: TFileFilterList): TFileFilterList;
var
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  for i := 0 to FileFilterList.Count - 1 do
  begin
    FilterType := FileFilterList[i].FilterType;
    FilterStr := FileFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ MyLocalBackupSourceUtil }

class function MyLocalBackupSourceReadUtil.getAutoSyncPathList: TStringList;
var
  MyLocalBackupSourceReadAutoSyncPathList : TMyLocalBackupSourceReadAutoSyncPathList;
begin
  MyLocalBackupSourceReadAutoSyncPathList := TMyLocalBackupSourceReadAutoSyncPathList.Create;
  Result := MyLocalBackupSourceReadAutoSyncPathList.get;
  MyLocalBackupSourceReadAutoSyncPathList.Free;
end;

class function MyLocalBackupSourceReadUtil.getConfig(
  FullPath: string): TLocalBackupConfigInfo;
var
  MyLocalBackupSourceReadConfig : TMyLocalBackupSourceReadConfig;
begin
  MyLocalBackupSourceReadConfig := TMyLocalBackupSourceReadConfig.Create( FullPath );
  Result := MyLocalBackupSourceReadConfig.get;
  MyLocalBackupSourceReadConfig.Free;
end;

class function MyLocalBackupSourceReadUtil.getDesPathList(
  FullPath: string): TStringList;
var
  MyLocalBackupSourceReadDesPathList : TMyLocalBackupSourceReadDesPathList;
begin
  MyLocalBackupSourceReadDesPathList := TMyLocalBackupSourceReadDesPathList.Create( FullPath );
  Result := MyLocalBackupSourceReadDesPathList.get;
  MyLocalBackupSourceReadDesPathList.Free;
end;

class function MyLocalBackupSourceReadUtil.getDesIsEnable(SourceRoot,
  DesRoot: string): Boolean;
var
  MyLocalBackupSourceReadDesIsEnable : TMyLocalBackupSourceReadDesIsEnable;
begin
  MyLocalBackupSourceReadDesIsEnable := TMyLocalBackupSourceReadDesIsEnable.Create( SourceRoot );
  MyLocalBackupSourceReadDesIsEnable.SetDesPath( DesRoot );
  Result := MyLocalBackupSourceReadDesIsEnable.get;
  MyLocalBackupSourceReadDesIsEnable.Free;
end;

class function MyLocalBackupSourceReadUtil.getIsEnable(FullPath: string): Boolean;
var
  MyLocalBackupSourceReadIsEnable : TMyLocalBackupSourceReadIsEnable;
begin
  MyLocalBackupSourceReadIsEnable := TMyLocalBackupSourceReadIsEnable.Create( FullPath );
  Result := MyLocalBackupSourceReadIsEnable.get;
  MyLocalBackupSourceReadIsEnable.Free;
end;

class function MyLocalBackupSourceReadUtil.getIsKeepDeleted(
  FullPath: string): Boolean;
var
  MyLocalBackupSourceReadIsKeepDeleted : TMyLocalBackupSourceReadIsKeepDeleted;
begin
  MyLocalBackupSourceReadIsKeepDeleted := TMyLocalBackupSourceReadIsKeepDeleted.Create( FullPath );
  Result := MyLocalBackupSourceReadIsKeepDeleted.get;
  MyLocalBackupSourceReadIsKeepDeleted.Free;
end;

class function MyLocalBackupSourceReadUtil.getKeedEditionCount(
  FullPath: string): Integer;
var
  MyLocalBackupSourceReadKeepEditionCount : TMyLocalBackupSourceReadKeepEditionCount;
begin
  MyLocalBackupSourceReadKeepEditionCount := TMyLocalBackupSourceReadKeepEditionCount.Create( FullPath );
  Result := MyLocalBackupSourceReadKeepEditionCount.get;
  MyLocalBackupSourceReadKeepEditionCount.Free;
end;

class function MyLocalBackupSourceReadUtil.getBackupNowPathList: TStringList;
var
  MyLocalBackupSourceReadBackupNowPathList : TMyLocalBackupSourceReadBackupNowPathList;
begin
  MyLocalBackupSourceReadBackupNowPathList := TMyLocalBackupSourceReadBackupNowPathList.Create;
  Result := MyLocalBackupSourceReadBackupNowPathList.get;
  MyLocalBackupSourceReadBackupNowPathList.Free;
end;

class function MyLocalBackupSourceReadUtil.getSourcePathLilst: TStringList;
var
  MyLocalBackupSourceReadPathList : TMyLocalBackupSourceReadPathList;
begin
  MyLocalBackupSourceReadPathList := TMyLocalBackupSourceReadPathList.Create;
  Result := MyLocalBackupSourceReadPathList.get;
  MyLocalBackupSourceReadPathList.Free;
end;

class function MyLocalBackupSourceReadUtil.getTotalSapce: Int64;
var
  MyLocalBackupSourceReadTotalSpace : TMyLocalBackupSourceReadTotalSpace;
begin
  MyLocalBackupSourceReadTotalSpace := TMyLocalBackupSourceReadTotalSpace.Create;
  Result := MyLocalBackupSourceReadTotalSpace.get;
  MyLocalBackupSourceReadTotalSpace.Free;
end;

class function MyLocalBackupSourceReadUtil.ReadExcludeFilter(
  FullPath: string): TFileFilterList;
var
  MyLocalBackupSourceReadExcludeFilter : TMyLocalBackupSourceReadExcludeFilter;
begin
  MyLocalBackupSourceReadExcludeFilter := TMyLocalBackupSourceReadExcludeFilter.Create( FullPath );
  Result := MyLocalBackupSourceReadExcludeFilter.get;
  MyLocalBackupSourceReadExcludeFilter.Free;
end;

class function MyLocalBackupSourceReadUtil.ReadIncludeFilter(
  FullPath: string): TFileFilterList;
var
  MyLocalBackupSourceReadIncludeFilter : TMyLocalBackupSourceReadIncludeFilter;
begin
  MyLocalBackupSourceReadIncludeFilter := TMyLocalBackupSourceReadIncludeFilter.Create( FullPath );
  Result := MyLocalBackupSourceReadIncludeFilter.get;
  MyLocalBackupSourceReadIncludeFilter.Free;
end;

{ TLocalBackupSourceSetLastSyncTimeInfo }

procedure TLocalBackupSourceSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceSetLastSyncTimeInfo.Update;
begin
    // ������
  if not FindSourceInfo then
    Exit;

  SourceInfo.LastSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TLocalBackupSourceSetSyncMinsInfo }

procedure TLocalBackupSourceSetSyncMinsInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupSourceSetSyncMinsInfo.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceSetSyncMinsInfo.Update;
begin
    // ������
  if not FindSourceInfo then
    Exit;

  SourceInfo.IsAutoSync := IsAutoSync;
  SourceInfo.SyncTimeType := SyncTimeType;
  SourceInfo.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefreshNextSyncTime;
end;

{ TLocalBackupSourceIsDisableInfo }

procedure TLocalBackupSourceIsDisableInfo.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceIsDisableInfo.Update;
begin
      // ������
  if not FindSourceInfo then
    Exit;

  SourceInfo.IsDisable := IsDisable;
end;

{ TLocalBackupSourceIsBackupNowInfo }

procedure TLocalBackupSourceIsBackupNowInfo.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupSourceIsBackupNowInfo.Update;
begin
      // ������
  if not FindSourceInfo then
    Exit;

  SourceInfo.IsBackupNow := IsBackupNow;
end;

{ TMyLocalBackupSourceReadDesPathList }

function TMyLocalBackupSourceReadDesPathList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  if not FindSourceInfo then
    Exit;

  for i := 0 to DesPathList.Count - 1 do
    Result.Add( DesPathList[i].FullPath );
end;

{ TMyLocalBackupSourceReadIsEnable }

function TMyLocalBackupSourceReadIsEnable.get: Boolean;
begin
  Result := False;

  if not FindSourceInfo then
    Exit;

  Result := not SourceInfo.IsDisable;
end;

{ TMyLocalBackupSourceReadTotalSpace }

function TMyLocalBackupSourceReadTotalSpace.get: Int64;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to LocalBackupSourceList.Count - 1 do
    Result := LocalBackupSourceList[i].FileSize;
end;

{ TMyLocalBackupSourceReadDesIsEnable }

function TMyLocalBackupSourceReadDesIsEnable.get: Boolean;
begin
  Result := FindDesPathInfo;
end;

{ TMyLocalBackupSourceReadIncludeFilter }

function TMyLocalBackupSourceReadIncludeFilter.get: TFileFilterList;
var
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;

      // ������
  if not FindSourceInfo then
    Exit;

  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    FilterType := IncludeFilterList[i].FilterType;
    FilterStr := IncludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TMyLocalBackupSourceReadExcludeFilter }

function TMyLocalBackupSourceReadExcludeFilter.get: TFileFilterList;
var
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;

      // ������
  if not FindSourceInfo then
    Exit;

  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    FilterType := ExcludeFilterList[i].FilterType;
    FilterStr := ExcludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TMyLocalBackupSourceReadPathList }

function TMyLocalBackupSourceReadPathList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to LocalBackupSourceList.Count - 1 do
    Result.Add( LocalBackupSourceList[i].FullPath );
end;

{ TLocalBackupSorceSetDeleteInfo }

procedure TLocalBackupSorceSetDeleteInfo.AddDeletedFace(
  DesPathInfo: TLocalBackupSourceDesInfo);
var
  vstLocalBackupDesDeletedAdd : TvstLocalBackupDesDeletedAdd;
begin
  vstLocalBackupDesDeletedAdd := TvstLocalBackupDesDeletedAdd.Create( DesPathInfo.FullPath );
  vstLocalBackupDesDeletedAdd.SetChildPath( FullPath );
  vstLocalBackupDesDeletedAdd.SetPathType( SourceInfo.PathType );
  vstLocalBackupDesDeletedAdd.SetSpaceInfo( DesPathInfo.DeletedSpace );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedAdd );
end;

procedure TLocalBackupSorceSetDeleteInfo.RemoveDeletedFace(
  DesPathInfo: TLocalBackupSourceDesInfo);
var
  vstLocalBackupDesDeletedRemove : TvstLocalBackupDesDeletedRemove;
begin
  vstLocalBackupDesDeletedRemove := TvstLocalBackupDesDeletedRemove.Create( DesPathInfo.FullPath );
  vstLocalBackupDesDeletedRemove.SetChildPath( FullPath );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedRemove );
end;

procedure TLocalBackupSorceSetDeleteInfo.ResetToFace;
var
  DesPathList : TLocalBackupSourceDesList;
  i : Integer;
begin
  DesPathList := SourceInfo.DesPathList;
  for i := 0 to DesPathList.Count - 1 do
  begin
    if IsKeepDeleted then
      AddDeletedFace( DesPathList[i] )
    else
      RemoveDeletedFace( DesPathList[i] );
  end;
end;

procedure TLocalBackupSorceSetDeleteInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSorceSetDeleteInfo.Update;
begin
    // ������
  if not FindSourceInfo then
    Exit;

    // ���淢���仯
  if SourceInfo.IsKeepDeleted <> IsKeepDeleted then
    ResetToFace;

  SourceInfo.IsKeepDeleted := IsKeepDeleted;
  SourceInfo.KeepEditionCount := KeepEditionCount;
end;

{ TLocalBackupSorceAddDeletedSpaceInfo }

procedure TLocalBackupSorceAddDeletedSpaceInfo.SetAddDeletedSpace(
  _AddDeletedSpace: Int64);
begin
  AddDeletedSpace := _AddDeletedSpace;
end;

procedure TLocalBackupSorceAddDeletedSpaceInfo.Update;
begin
    // ������
  if not FindDesPathInfo then
    Exit;

  DesPathInfo.DeletedSpace := DesPathInfo.DeletedSpace + AddDeletedSpace;
end;

{ TLocalBackupSorceSetDeletedSpaceInfo }

procedure TLocalBackupSorceSetDeletedSpaceInfo.SetDeletedSpace(
  _DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSorceSetDeletedSpaceInfo.Update;
begin
    // ������
  if not FindDesPathInfo then
    Exit;

  DesPathInfo.DeletedSpace := DeletedSpace;
end;

{ TMyLocalBackupSourceReadIsKeepDeleted }

function TMyLocalBackupSourceReadIsKeepDeleted.get: Boolean;
begin
  Result := False;

  if not FindSourceInfo then
    Exit;

  Result := SourceInfo.IsKeepDeleted;
end;

{ TMyLocalBackupSourceReadKeepEditionCount }

function TMyLocalBackupSourceReadKeepEditionCount.get: Integer;
begin
  Result := 0;

  if not FindSourceInfo then
    Exit;

  if SourceInfo.IsKeepDeleted then
    Result := SourceInfo.KeepEditionCount;
end;

{ TMyLocalBackupSourceReadBackupNowPathList }

function TMyLocalBackupSourceReadBackupNowPathList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to LocalBackupSourceList.Count - 1 do
    if LocalBackupSourceList[i].IsBackupNow then
      Result.Add( LocalBackupSourceList[i].FullPath );
end;


{ TMyLocalBackupSourceReadAutoSyncPathList }

function TMyLocalBackupSourceReadAutoSyncPathList.get: TStringList;
var
  i : Integer;
  SourceInfo : TLocalBackupSourceInfo;
begin
  Result := TStringList.Create;
  for i := 0 to LocalBackupSourceList.Count - 1 do
  begin
    SourceInfo := LocalBackupSourceList[i];
    if not SourceInfo.IsAutoSync then
      Continue;
    if Now >= SourceInfo.NextSyncTime then
      Result.Add( SourceInfo.FullPath );
  end;
end;

{ TLocalBackupSourceAccessInfo }

constructor TLocalBackupSourceAccessInfo.Create;
begin
  MyLocalBackupSourceInfo.EnterData;
  LocalBackupSourceList := MyLocalBackupSourceInfo.LocalBackupSourceList;
end;

destructor TLocalBackupSourceAccessInfo.Destroy;
begin
  MyLocalBackupSourceInfo.LeaveData;
  inherited;
end;

{ TLocalBackupSourceItemAccessInfo }

constructor TLocalBackupSourceItemAccessInfo.Create(_FullPath: string);
begin
  inherited Create;
  FullPath := _FullPath;
end;

function TLocalBackupSourceItemAccessInfo.FindSourceInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to LocalBackupSourceList.Count - 1 do
    if LocalBackupSourceList[i].FullPath = FullPath then
    begin
      SourceIndex := i;
      SourceInfo := LocalBackupSourceList[i];
      Result := True;
      Break;
    end;
end;

{ TLocalBackupSourceItemDesAccessInfo }

function TLocalBackupSourceItemDesAccessInfo.FindSourceInfo: Boolean;
begin
  Result := inherited;
  if Result then
    DesPathList := SourceInfo.DesPathList
  else
    DesPathList := nil;
end;

{ TLocalBackupSourceItemDesPathAccessInfo }

function TLocalBackupSourceItemDesPathAccessInfo.FindDesPathInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindSourceInfo then
    Exit;

  for i := 0 to DesPathList.Count - 1 do
    if DesPathList[i].FullPath = DesPath then
    begin
      DesPathIndex := i;
      DesPathInfo := DesPathList[i];
      Result := True;
      Break;
    end;
end;

procedure TLocalBackupSourceItemDesPathAccessInfo.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TLocalBackupSourceItemIncludeAccessInfo }

function TLocalBackupSourceItemIncludeAccessInfo.FindSourceInfo: Boolean;
begin
  Result := inherited;
  if Result then
    IncludeFilterList := SourceInfo.IncludeFilterList
  else
    IncludeFilterList := nil;
end;

{ TLocalBackupSourceItemExcludeAccessInfo }

function TLocalBackupSourceItemExcludeAccessInfo.FindSourceInfo: Boolean;
begin
  Result := inherited;
  if Result then
    ExcludeFilterList := SourceInfo.ExcludeFilterList
  else
    ExcludeFilterList := nil;
end;

{ TLocalBackupDesAccessInfo }

constructor TLocalBackupDesAccessInfo.Create;
begin
  MyLocalBackupDesInfo.EnterData;
  DestinationHash := MyLocalBackupDesInfo.DestinationHash;
end;

destructor TLocalBackupDesAccessInfo.Destroy;
begin
  MyLocalBackupDesInfo.LeaveData;
  inherited;
end;

{ TLocalBackupDesItemAccessInfo }

constructor TLocalBackupDesItemAccessInfo.Create(_FullPath: string);
begin
  inherited Create;
  FullPath := _FullPath;
end;

function TLocalBackupDesItemAccessInfo.FindBackupDesInfo: Boolean;
begin
  Result := DestinationHash.ContainsKey( FullPath );
  if Result then
    BackupDesInfo := DestinationHash[ FullPath ];
end;

class function MyLocalBackupDesReadUtil.getIsEnable(FullPath: string): Boolean;
var
  LocalBackupDesReadIsEnable : TLocalBackupDesReadIsEnable;
begin
  LocalBackupDesReadIsEnable := TLocalBackupDesReadIsEnable.Create( FullPath );
  Result := LocalBackupDesReadIsEnable.get;
  LocalBackupDesReadIsEnable.Free;
end;

{ TLocalBackupDesReadIsEnable }

function TLocalBackupDesReadIsEnable.get: Boolean;
begin
  Result := FindBackupDesInfo;
end;

end.

