unit ULocalBackupXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' Դ·�� �޸� ' }

    // �޸� ����
  TLocalBackupSourceChangeXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    SourcePathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSourcePathNode : Boolean;
  end;

    // ���
  TLocalBackupSourceAddXml = class( TLocalBackupSourceChangeXml )
  private
    PathType : string;
    IsBackupNow, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  private
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;override;
  end;

    // �޸� �ռ���Ϣ
  TLocalBackupSourceSpaceXml = class( TLocalBackupSourceChangeXml )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' ���� ״̬��Ϣ ' }

      // �Ƿ� ��ֹ����
  TLocalBackupSourceIsDisableXml = class( TLocalBackupSourceChangeXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // �Ƿ� Backup Now ����
  TLocalBackupSourceIsBackupNowXml = class( TLocalBackupSourceChangeXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ͬ��ʱ�� ��Ϣ ' }

    // ���� ��һ�� ͬ��ʱ��
  TLocalBackupSourceSetLastSyncTimeXml = class( TLocalBackupSourceChangeXml )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // ���� ��һ�� ͬ��ʱ��
  TLocalBackupSourceSetSyncMinsXml = class( TLocalBackupSourceChangeXml )
  private
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' ���ñ���ɾ���ļ���Ϣ ' }

    // ������Ϣ
  TLocalBackupSorceSetDeleteXml = class( TLocalBackupSourceChangeXml )
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

    // ɾ��
  TLocalBackupSourceRemoveXml = class( TLocalBackupSourceChangeXml )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' Դ·�� ������ �޸� ' }

  {$Region ' ���� ������ ' }

    // ����
  TLocalBackupSourceIncludeFilterChangeXml = class( TLocalBackupSourceChangeXml )
  protected
    IncludeFilterListNode : IXMLNode;
  protected
    function FindIncludeFilterListNode : Boolean;
  end;

    // ���
  TLocalBackupSourceIncludeFilterClearXml = class( TLocalBackupSourceIncludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // ���
  TLocalBackupSourceIncludeFilterAddXml = class( TLocalBackupSourceIncludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �ų� ������ ' }

    // ����
  TLocalBackupSourceExcludeFilterChangeXml = class( TLocalBackupSourceChangeXml )
  protected
    ExcludeFilterListNode : IXMLNode;
  protected
    function FindExcludeFilterListNode : Boolean;
  end;

    // ���
  TLocalBackupSourceExcludeFilterClearXml = class( TLocalBackupSourceExcludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // ���
  TLocalBackupSourceExcludeFilterAddXml = class( TLocalBackupSourceExcludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}


{$EndRegion}

{$Region ' Դ·��Ŀ�� �޸� ' }

    // ����
  TLocalBackupSourceChangeDesXml = class( TLocalBackupSourceChangeXml )
  public
    DesPathListNode : IXMLNode;
  public
    function FindDesPathListNode : Boolean;
  end;

    // �޸�
  TLocalBackupSourceWriteDesXml = class( TLocalBackupSourceChangeDesXml )
  public
    DesPath : string;
  protected
    DesPathNode : IXMLNode;
  public
    procedure SetDesPath( _DesPath : string );
  protected
    function FindDesPathNode : Boolean;
  end;

    // ���
  TLocalBackupSourceAddDesXml = class( TLocalBackupSourceWriteDesXml )
  public
    SourceSize, CompltedSize : Int64;
    DeletedSpace : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;override;
  end;

    // ��� ����ɿռ���Ϣ
  TLocalBackupSourceAddDesCompletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    AddCompltedSize : Int64;
  public
    procedure SetAddCompltedSize( _AddCompltedSize : Int64 );
    procedure Update;override;
  end;

    // �޸� �ռ���Ϣ
  TLocalBackupSourceSetDesSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    SourceSize, CompltedSize : Int64;
  public
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ��� ��ɾ�� �ռ���Ϣ
  TLocalBackupSorceAddDeletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    AddDeletedSpace : Int64;
  public
    procedure SetAddDeletedSpace( _AddDeletedSpace : Int64 );
    procedure Update;override;
  end;

    // ���� ��ɾ�� �ռ���Ϣ
  TLocalBackupSorceSetDeletedSpaceXml = class( TLocalBackupSourceWriteDesXml )
  public
    DeletedSpace : Int64;
  public
    procedure SetDeletedSpace( _DeletedSpace : Int64 );
    procedure Update;override;
  end;


    // ɾ��
  TLocalBackupSourceRemoveDesXml = class( TLocalBackupSourceWriteDesXml )
  public
    procedure Update;override;
  end;

    // �汾����
  TLocalBackupSourceIsAddDesToSourceXml = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Դ·�� ��ȡ ' }

    // ��ȡ Դ·��Ŀ��
  TLocalBackupSourceReadDesXmlHandle = class
  public
    DesPathNode : IXMLNode;
    SourcePath, PathType : string;
    IsKeepDeleted : Boolean;
  public
    constructor Create( _DesPathNode : IXMLNode );
    procedure SetSourcePath( _SourcePath, _PathType : string );
    procedure SetIsKeepDeleted( _IsKeepDeleted : Boolean );
    procedure Update;
  end;

    // �� ����·�� ���� Xml
  TLocalBackupSourceFilterXmlReadHandle = class
  public
    FilterNode : IXMLNode;
    FullPath : string;
  protected
    FilterType, FilterStr : string;
  public
    constructor Create( _FilterNode : IXMLNode );
    procedure SetFullPath( _FullPath : string );
    procedure Update;
  protected
    procedure AddFilterHandle;virtual;abstract;
  end;

    // �� ����·�� �������� Xml
  TLocalBackupSourceIncludeFilterXmlReadHandle = class( TLocalBackupSourceFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // �� ����·�� �ų����� Xml
  TLocalBackupSourceExcludeFilterXmlReadHandle = class( TLocalBackupSourceFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // ��ȡ Դ·��
  TLocalBackupSorceReadXmlHandle = class
  public
    SourcePathNode : IXMLNode;
    FullPath, PathType : string;
  public
    IsKeepDeleted : Boolean;
  private
    IsAddEditionDes : Boolean;
  public
    constructor Create( _SourcePathNode : IXMLNode );
    procedure SetIsAddEditionDes( _IsAddEditionDes : Boolean );
    procedure Update;
  private
    procedure ReadSourceFilter;
    procedure ReadDesPathList;
    procedure AddEditionDesPathList;
  end;

    // ��ȡ ��Ϣ
  TLocalBackupSourceXmlRead = class
  public
    procedure Update;
  end;


{$EndRegion}


{$Region ' Ŀ��·�� �޸� ' }

       // �޸� ����
  TLocalBackupDesChangeXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    BackupDesNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindBackupDesNode : Boolean;
  end;

    // ��� Ŀ��·��
  TLocalBackupDesAddXml = class( TLocalBackupDesChangeXml )
  public
    procedure Update;override;
  end;

    // ɾ�� Ŀ��·��
  TLocalBackupDesRemoveXml = class( TLocalBackupDesChangeXml )
  public
    procedure Update;override;
  end;

    // ��ֹ ��� Ĭ��·��
  TLocalBackupDesDisableDefaultPathXml = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Ŀ��·�� ��ȡ ' }

    //Ŀ��·�� ��ȡ
  TLocalBackupDesXmlReadHandle = class
  public
    DesPathNode : IXMLNode;
  public
    constructor Create( _DesPathNode : IXMLNode );
    procedure Update;
  end;

    // ��ȡ
  TLocalBackupDesXmlRead = class
  public
    procedure Update;
  private
    procedure AddMyDesPathList;
    procedure AddDefaultDesPath;
  end;


{$EndRegion}

const  // Xml ��Ϣ

  Xml_IsAddSourceToDes = 'iastd';
  Xml_IsAddDesToSource = 'iadts';

    // Դ��Ϣ
  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';
  Xml_IsBackupNow = 'ib';
  Xml_IsDisable = 'id';
  Xml_IsAuctoSync = 'ias';
  Xml_LastSyncTime = 'lst';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_IsKeepDeleted = 'ikd';
  Xml_KeepEdtionCount = 'kec';
  Xml_FileSize = 'fs';
  Xml_FileCount = 'fc';
  Xml_DesPathList = 'dpl';
  Xml_IncludeFilterList = 'ifl';
  Xml_ExcludeFilterList = 'efl';

    // ������ ��Ϣ
  Xml_FilterType = 'ft';
  XMl_FilterStr = 'fs';

    // Դ·��Ŀ��
//  Xml_FullPath = 'fp';
  Xml_SourceSize = 'ss';
  Xml_CompltedSize = 'cs';
  Xml_DeletedSpace = 'ds';

    // Ŀ����Ϣ
  Xml_IsAddDefault = 'iad';

implementation

uses ULocalBackupInfo, ULocalBackupControl;

{ TLocalBackupSourceChangeXml }

constructor TLocalBackupSourceChangeXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLocalBackupSourceChangeXml.FindSourcePathNode: Boolean;
begin
  SourcePathNode := MyXmlUtil.FindListChild( LocalBackupSourceListXml, FullPath );
  Result := SourcePathNode <> nil;
end;

{ TLocalBackupSourceAddXml }

procedure TLocalBackupSourceAddXml.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceAddXml.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceAddXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSourceAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLocalBackupSourceAddXml.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

procedure TLocalBackupSourceAddXml.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceAddXml.Update;
begin
    // �Ѵ���
  if FindSourcePathNode then
    Exit;

    // ���
  SourcePathNode := MyXmlUtil.AddListChild( LocalBackupSourceListXml, FullPath );

  MyXmlUtil.AddChild( SourcePathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( SourcePathNode, Xml_PathType, PathType );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsBackupNow, IsBackupNow );
  MyXmlUtil.AddChild( SourcePathNode, Xml_IsDisable, IsDisable );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsAuctoSync, IsAutoSync );
  MyXmlUtil.AddChild( SourcePathNode, Xml_LastSyncTime, LastSyncTime );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeType, SyncTimeType );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeValue, SyncTimeValue );

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( SourcePathNode, Xml_KeepEdtionCount, KeepEditionCount );

  MyXmlUtil.AddChild( SourcePathNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( SourcePathNode, Xml_FileCount, FileCount );
end;

{ TLocalBackupSourceRemoveXml }

procedure TLocalBackupSourceRemoveXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.DeleteListChild( LocalBackupSourceListXml, FullPath );
end;

{ TLocalBackupSourceSpaceXml }

procedure TLocalBackupSourceSpaceXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLocalBackupSourceSpaceXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_FileCount, IntToStr( FileCount ) );
end;

{ TLocalBackupSourceXmlRead }

procedure TLocalBackupSourceXmlRead.Update;
var
  IsAddDesToSource : Boolean;
  i : Integer;
  Node : IXMLNode;
  LocalBackupSorceReadXmlHandle : TLocalBackupSorceReadXmlHandle;
  LocalBackupSourceIsAddDesToSourceXml : TLocalBackupSourceIsAddDesToSourceXml;
begin
  IsAddDesToSource := StrToBoolDef( MyXmlUtil.GetChildValue( MyLocalBackupSourceXml, Xml_IsAddDesToSource ), true);

    // ��ȡ Դ·��
  for i := 0 to LocalBackupSourceListXml.ChildNodes.Count - 1 do
  begin
    Node := LocalBackupSourceListXml.ChildNodes[i];

    LocalBackupSorceReadXmlHandle := TLocalBackupSorceReadXmlHandle.Create( Node );
    LocalBackupSorceReadXmlHandle.SetIsAddEditionDes( IsAddDesToSource );
    LocalBackupSorceReadXmlHandle.Update;
    LocalBackupSorceReadXmlHandle.Free;
  end;

    // �Ѿ��汾���ݣ�����
  if not IsAddDesToSource then
    Exit;

    // �汾����
  LocalBackupSourceIsAddDesToSourceXml := TLocalBackupSourceIsAddDesToSourceXml.Create;
  MyXmlChange.AddChange( LocalBackupSourceIsAddDesToSourceXml );
end;

{ TMyDesPathChangeXml }

constructor TLocalBackupDesChangeXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TMyDesPathAddXml }

procedure TLocalBackupDesAddXml.Update;
begin
    // �Ѵ���
  if FindBackupDesNode then
    Exit;

  BackupDesNode := MyXmlUtil.AddListChild( DestinationListXml, FullPath );
  MyXmlUtil.AddChild( BackupDesNode, Xml_FullPath, FullPath );
end;

{ TMyDesPathRemoveXml }

procedure TLocalBackupDesRemoveXml.Update;
begin
    // ������
  if not FindBackupDesNode then
    Exit;

  MyXmlUtil.DeleteListChild( DestinationListXml, FullPath );
end;

{ TMyDestinationXmlRead }

procedure TLocalBackupDesXmlRead.AddDefaultDesPath;
var
  IsAddDefault : Boolean;
  DesPath : string;
  BackupDestinationReadHandle : TLocalBackupDesReadHandle;
  MyDesDisableDefaultPathXml : TLocalBackupDesDisableDefaultPathXml;
begin
  IsAddDefault := StrToBoolDef( MyXmlUtil.GetChildValue( MyDestinationXml, Xml_IsAddDefault ), True );
  if not IsAddDefault then
    Exit;

  DesPath := MyHardDisk.getBiggestHardDIsk + DefaultPath_Des;
  ForceDirectories( DesPath );

    // ��� Ĭ�ϵ� ���� ����Ŀ��·��
  BackupDestinationReadHandle := TLocalBackupDesReadHandle.Create( DesPath );
  BackupDestinationReadHandle.Update;
  BackupDestinationReadHandle.Free;

    // ��ֹ��һ�����
  MyDesDisableDefaultPathXml := TLocalBackupDesDisableDefaultPathXml.Create;
  MyXmlChange.AddChange( MyDesDisableDefaultPathXml );
end;

procedure TLocalBackupDesXmlRead.AddMyDesPathList;
var
  i : Integer;
  DesNode : IXMLNode;
  LocalBackupDesXmlReadHandle : TLocalBackupDesXmlReadHandle;
begin
  for i := 0 to DestinationListXml.ChildNodes.Count - 1 do
  begin
    DesNode := DestinationListXml.ChildNodes[i];

    LocalBackupDesXmlReadHandle := TLocalBackupDesXmlReadHandle.Create( DesNode );
    LocalBackupDesXmlReadHandle.Update;
    LocalBackupDesXmlReadHandle.Free;
  end;
end;

procedure TLocalBackupDesXmlRead.Update;
begin
    // ���Ĭ��·��
  if DestinationListXml.ChildNodes.Count = 0 then
    AddDefaultDesPath
  else       // ��� ���ر���Ŀ��·��
    AddMyDesPathList;
end;

function TLocalBackupDesChangeXml.FindBackupDesNode: Boolean;
begin
  BackupDesNode := MyXmlUtil.FindListChild( DestinationListXml, FullPath );
  Result := BackupDesNode <> nil;
end;

{ TMyDesDisableDefaultPathXml }

procedure TLocalBackupDesDisableDefaultPathXml.Update;
begin
  MyXmlUtil.AddChild( MyDestinationXml, Xml_IsAddDefault, BoolToStr( False ) );
end;

{ TLocalBackupSourceChangeDesXml }

function TLocalBackupSourceChangeDesXml.FindDesPathListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    DesPathListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_DesPathList );
end;

{ TLocalBackupSourceWriteDesXml }

function TLocalBackupSourceWriteDesXml.FindDesPathNode: Boolean;
begin
  Result := False;
  DesPathListNode := nil;
  if not FindDesPathListNode then
    Exit;

  DesPathNode := MyXmlUtil.FindListChild( DesPathListNode, DesPath );
  Result := DesPathNode <> nil;
end;

procedure TLocalBackupSourceWriteDesXml.SetDesPath(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TLocalBackupSourceAddDesXml }

procedure TLocalBackupSourceAddDesXml.SetDeletedSpace(_DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSourceAddDesXml.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceAddDesXml.Update;
begin
  inherited;

    // �Ѵ���
  if FindDesPathNode then
    Exit;

    // Դ������
  if DesPathListNode = nil then
    Exit;

    // ���
  DesPathNode := MyXmlUtil.AddListChild( DesPathListNode, DesPath );
  MyXmlUtil.AddChild( DesPathNode, Xml_FullPath, DesPath );
  MyXmlUtil.AddChild( DesPathNode, Xml_SourceSize, SourceSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, CompltedSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

{ TLocalBackupSourceRemoveDesXml }

procedure TLocalBackupSourceRemoveDesXml.Update;
begin
  inherited;

    // ������
  if not FindDesPathNode then
    Exit;

    // ɾ��
  MyXmlUtil.DeleteListChild( DesPathListNode, DesPath );
end;

{ TLocalBackupSourceSetDesSpaceXml }

procedure TLocalBackupSourceSetDesSpaceXml.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TLocalBackupSourceSetDesSpaceXml.Update;
begin
  inherited;

    // ������
  if not FindDesPathNode then
    Exit;

    // �޸� �ռ���Ϣ
  MyXmlUtil.AddChild( DesPathNode, Xml_SourceSize, SourceSize );
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, CompltedSize );
end;

{ TLocalBackupSourceAddDesCompletedSpaceXml }

procedure TLocalBackupSourceAddDesCompletedSpaceXml.SetAddCompltedSize(
  _AddCompltedSize: Int64);
begin
  AddCompltedSize := _AddCompltedSize;
end;

procedure TLocalBackupSourceAddDesCompletedSpaceXml.Update;
var
  NewCompltedSpace : Int64;
begin
  inherited;

    // ������
  if not FindDesPathNode then
    Exit;

  NewCompltedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_CompltedSize );
  NewCompltedSpace := NewCompltedSpace + AddCompltedSize;

    // �޸� �ռ���Ϣ
  MyXmlUtil.AddChild( DesPathNode, Xml_CompltedSize, NewCompltedSpace );
end;

{ TLocalBackupSorceReadXmlHandle }

procedure TLocalBackupSorceReadXmlHandle.AddEditionDesPathList;
var
  i : Integer;
  DesNode : IXMLNode;
  DesPath : string;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  for i := 0 to DestinationListXml.ChildNodes.Count - 1 do
  begin
    DesNode := DestinationListXml.ChildNodes[i];
    DesPath := MyXmlUtil.GetChildValue( DesNode, Xml_FullPath );

      // ��ʾ��Ϣ
    LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( FullPath );
    LocalBackupSourceAddDesHandle.SetDesPath( DesPath );
    LocalBackupSourceAddDesHandle.SetSourcePathType( PathType );
    LocalBackupSourceAddDesHandle.SetDeletedInfo( False, 0 );
    LocalBackupSourceAddDesHandle.SetSpaceInfo( 0, 0 );
    LocalBackupSourceAddDesHandle.Update;
    LocalBackupSourceAddDesHandle.Free;
  end;
end;

constructor TLocalBackupSorceReadXmlHandle.Create(_SourcePathNode: IXMLNode);
begin
  SourcePathNode := _SourcePathNode;
end;

procedure TLocalBackupSorceReadXmlHandle.ReadDesPathList;
var
  DesPathListNode : IXMLNode;
  i : Integer;
  DesPathNode : IXMLNode;
  LocalBackupSourceReadDesXmlHandle : TLocalBackupSourceReadDesXmlHandle;
begin
  DesPathListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_DesPathList );
  for i := 0 to DesPathListNode.ChildNodes.Count - 1 do
  begin
    DesPathNode := DesPathListNode.ChildNodes[i];

    LocalBackupSourceReadDesXmlHandle := TLocalBackupSourceReadDesXmlHandle.Create( DesPathNode );
    LocalBackupSourceReadDesXmlHandle.SetSourcePath( FullPath, PathType );
    LocalBackupSourceReadDesXmlHandle.SetIsKeepDeleted( IsKeepDeleted );
    LocalBackupSourceReadDesXmlHandle.Update;
    LocalBackupSourceReadDesXmlHandle.Free;
  end;
end;

procedure TLocalBackupSorceReadXmlHandle.ReadSourceFilter;
var
  FilterListNode : IXMLNode;
  i : Integer;
  FilterNode : IXMLNode;
  LocalBackupSourceFilterXmlReadHandle : TLocalBackupSourceFilterXmlReadHandle;
begin
  FilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_IncludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    LocalBackupSourceFilterXmlReadHandle := TLocalBackupSourceIncludeFilterXmlReadHandle.Create( FilterNode );
    LocalBackupSourceFilterXmlReadHandle.SetFullPath( FullPath );
    LocalBackupSourceFilterXmlReadHandle.Update;
    LocalBackupSourceFilterXmlReadHandle.Free;
  end;

  FilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_ExcludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    LocalBackupSourceFilterXmlReadHandle := TLocalBackupSourceExcludeFilterXmlReadHandle.Create( FilterNode );
    LocalBackupSourceFilterXmlReadHandle.SetFullPath( FullPath );
    LocalBackupSourceFilterXmlReadHandle.Update;
    LocalBackupSourceFilterXmlReadHandle.Free;
  end;
end;

procedure TLocalBackupSorceReadXmlHandle.SetIsAddEditionDes(
  _IsAddEditionDes: Boolean);
begin
  IsAddEditionDes := _IsAddEditionDes;
end;

procedure TLocalBackupSorceReadXmlHandle.Update;
var
  IsBackupNow, IsDisable : Boolean;
  IsAutoSync : Boolean;
  SyncTimeType, SyncTimeValue : Integer;
  LastSyncTime : TDateTime;
  KeepEditionCount : Integer;
  FileSize : Int64;
  FileCount : Integer;
  LocalBackupSourceReadHandle : TLocalBackupSourceReadHandle;
begin
    // ��ȡ �ڵ���Ϣ
  FullPath := MyXmlUtil.GetChildValue( SourcePathNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( SourcePathNode, Xml_PathType );
  IsBackupNow := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsBackupNow ), True );
  IsDisable := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsDisable ), False );
  IsAutoSync := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsAuctoSync ), True );
  SyncTimeType := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_SyncTimeType ), TimeType_Minutes );
  SyncTimeValue := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_SyncTimeValue ), 60 );
  LastSyncTime := StrToFloatDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_LastSyncTime ), 0 );
  IsKeepDeleted := StrToBoolDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_IsKeepDeleted ), False );
  KeepEditionCount := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_KeepEdtionCount ), 3 );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( SourcePathNode, Xml_FileSize ), 0 );
  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( SourcePathNode, Xml_FileCount ), 0 );

    // ��ȡ ·����Ϣ
  LocalBackupSourceReadHandle := TLocalBackupSourceReadHandle.Create( FullPath );
  LocalBackupSourceReadHandle.SetPathType( PathType );
  LocalBackupSourceReadHandle.SetBackupInfo( IsBackupNow, IsDisable );
  LocalBackupSourceReadHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupSourceReadHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  LocalBackupSourceReadHandle.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupSourceReadHandle.SetSpaceInfo( FileCount, FileSize );
  LocalBackupSourceReadHandle.Update;
  LocalBackupSourceReadHandle.Free;

    // ��ȡ ��������Ϣ
  ReadSourceFilter;

    // ��ȡ Ŀ��·��
  if IsAddEditionDes then
    AddEditionDesPathList  // �汾����
  else
    ReadDesPathList;
end;


{ TLocalBackupSourceReadDesXmlHandle }

constructor TLocalBackupSourceReadDesXmlHandle.Create(_DesPathNode: IXMLNode);
begin
  DesPathNode := _DesPathNode;
end;

procedure TLocalBackupSourceReadDesXmlHandle.SetIsKeepDeleted(
  _IsKeepDeleted: Boolean);
begin
  IsKeepDeleted := _IsKeepDeleted;
end;

procedure TLocalBackupSourceReadDesXmlHandle.SetSourcePath(_SourcePath, _PathType: string);
begin
  SourcePath := _SourcePath;
  PathType := _PathType;
end;

procedure TLocalBackupSourceReadDesXmlHandle.Update;
var
  DesPath : string;
  SourceSize, CompltedSize : Int64;
  DeletedSpace : Int64;
  LocalBackupSourceReadDesHandle : TLocalBackupSourceReadDesHandle;
begin
    // ��ȡ��Ϣ
  DesPath := MyXmlUtil.GetChildValue( DesPathNode, Xml_FullPath );
  SourceSize := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_SourceSize );
  CompltedSize := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_CompltedSize );
  DeletedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_DeletedSpace );


    // ��ʾ��Ϣ
  LocalBackupSourceReadDesHandle := TLocalBackupSourceReadDesHandle.Create( SourcePath );
  LocalBackupSourceReadDesHandle.SetDesPath( DesPath );
  LocalBackupSourceReadDesHandle.SetSourcePathType( PathType );
  LocalBackupSourceReadDesHandle.SetSpaceInfo( SourceSize, CompltedSize );
  LocalBackupSourceReadDesHandle.SetDeletedInfo( IsKeepDeleted, DeletedSpace );
  LocalBackupSourceReadDesHandle.Update;
  LocalBackupSourceReadDesHandle.Free;
end;

{ TLocalBackupDesXmlReadHandle }

constructor TLocalBackupDesXmlReadHandle.Create(_DesPathNode: IXMLNode);
begin
  DesPathNode := _DesPathNode;
end;

procedure TLocalBackupDesXmlReadHandle.Update;
var
  DesPath : string;
  BackupDestinationReadHandle : TLocalBackupDesReadHandle;
begin
    // ��ȡ��Ϣ
  DesPath := MyXmlUtil.GetChildValue( DesPathNode, Xml_FullPath );

    // ���� ����Ŀ��·��
  BackupDestinationReadHandle := TLocalBackupDesReadHandle.Create( DesPath );
  BackupDestinationReadHandle.Update;
  BackupDestinationReadHandle.Free;
end;

{ TLocalBackupSourceIncludeFilterChangeXml }

function TLocalBackupSourceIncludeFilterChangeXml.FindIncludeFilterListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    IncludeFilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_IncludeFilterList );
end;

{ TLocalBackupSourceIncludeFilterClearXml }

procedure TLocalBackupSourceIncludeFilterClearXml.Update;
begin
  inherited;

  if not FindIncludeFilterListNode then
    Exit;

  IncludeFilterListNode.ChildNodes.Clear;
end;

{ TLocalBackupSourceIncludeFilterAddXml }

procedure TLocalBackupSourceIncludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceIncludeFilterAddXml.Update;
var
  IncludeFilterNode : IXMLNode;
begin
  inherited;

    // ������
  if not FindIncludeFilterListNode then
    Exit;

  IncludeFilterNode := MyXmlUtil.AddListChild( IncludeFilterListNode );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TLocalBackupSourceExcludeFilterChangeXml }

function TLocalBackupSourceExcludeFilterChangeXml.FindExcludeFilterListNode: Boolean;
begin
  Result := FindSourcePathNode;
  if Result then
    ExcludeFilterListNode := MyXmlUtil.AddChild( SourcePathNode, Xml_ExcludeFilterList );
end;

{ TLocalBackupSourceExcludeFilterClearXml }

procedure TLocalBackupSourceExcludeFilterClearXml.Update;
begin
  inherited;

  if not FindExcludeFilterListNode then
    Exit;

  ExcludeFilterListNode.ChildNodes.Clear;
end;

{ TLocalBackupSourceExcludeFilterAddXml }

procedure TLocalBackupSourceExcludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TLocalBackupSourceExcludeFilterAddXml.Update;
var
  ExcludeFilterNode : IXMLNode;
begin
  inherited;

    // ������
  if not FindExcludeFilterListNode then
    Exit;

  ExcludeFilterNode := MyXmlUtil.AddListChild( ExcludeFilterListNode );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TLocalBackupSourceFilterXmlReadHandle }

constructor TLocalBackupSourceFilterXmlReadHandle.Create(_FilterNode: IXMLNode);
begin
  FilterNode := _FilterNode;
end;

procedure TLocalBackupSourceFilterXmlReadHandle.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TLocalBackupSourceFilterXmlReadHandle.Update;
begin
    // ��ȡ ������Ϣ
  FilterType := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterType );
  FilterStr := MyXmlUtil.GetChildValue( FilterNode, Xml_FilterStr );

    // ��� ������
  AddFilterHandle;
end;


{ TLocalBackupSourceIncludeFilterXmlReadHandle }

procedure TLocalBackupSourceIncludeFilterXmlReadHandle.AddFilterHandle;
var
  LocalBackupSourceIncludeFilterReadHandle : TLocalBackupSourceIncludeFilterReadHandle;
begin
  LocalBackupSourceIncludeFilterReadHandle := TLocalBackupSourceIncludeFilterReadHandle.Create( FullPath );
  LocalBackupSourceIncludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceIncludeFilterReadHandle.Update;
  LocalBackupSourceIncludeFilterReadHandle.Free;
end;

{ TLocalBackupSourceExcludeFilterXmlReadHandle }

procedure TLocalBackupSourceExcludeFilterXmlReadHandle.AddFilterHandle;
var
  LocalBackupSourceExcludeFilterReadHandle : TLocalBackupSourceExcludeFilterReadHandle;
begin
  LocalBackupSourceExcludeFilterReadHandle := TLocalBackupSourceExcludeFilterReadHandle.Create( FullPath );
  LocalBackupSourceExcludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  LocalBackupSourceExcludeFilterReadHandle.Update;
  LocalBackupSourceExcludeFilterReadHandle.Free;
end;

{ TLocalBackupSourceIsDisableXml }

procedure TLocalBackupSourceIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLocalBackupSourceIsDisableXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsDisable, BoolToStr( IsDisable ) );
end;

{ TLocalBackupSourceIsBackupNowXml }

procedure TLocalBackupSourceIsBackupNowXml.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TLocalBackupSourceIsBackupNowXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsBackupNow, BoolToStr( IsBackupNow ) );
end;

{ TLocalBackupSourceSetLastSyncTimeXml }

procedure TLocalBackupSourceSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TLocalBackupSourceSetLastSyncTimeXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_LastSyncTime, FloatToStr( LastSyncTime ) );
end;

{ TLocalBackupSourceSetSyncMinsXml }

procedure TLocalBackupSourceSetSyncMinsXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TLocalBackupSourceSetSyncMinsXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLocalBackupSourceSetSyncMinsXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsAuctoSync, BoolToStr( IsAutoSync ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeType, IntToStr( SyncTimeType ) );
  MyXmlUtil.AddChild( SourcePathNode, Xml_SyncTimeValue, IntToStr( SyncTimeValue ) );
end;

{ TLocalBackupSourceIsAddDesToSourceXml }

procedure TLocalBackupSourceIsAddDesToSourceXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( MyLocalBackupSourceXml, Xml_IsAddDesToSource, False );
end;

{ TLocalBackupSorceSetDeleteXml }

procedure TLocalBackupSorceSetDeleteXml.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupSorceSetDeleteXml.Update;
begin
    // ������
  if not FindSourcePathNode then
    Exit;

  MyXmlUtil.AddChild( SourcePathNode, Xml_IsKeepDeleted, IsKeepDeleted );
  MyXmlUtil.AddChild( SourcePathNode, Xml_KeepEdtionCount, KeepEditionCount );
end;

{ TLocalBackupSorceAddDeletedSpaceXml }

procedure TLocalBackupSorceAddDeletedSpaceXml.SetAddDeletedSpace(
  _AddDeletedSpace: Int64);
begin
  AddDeletedSpace := _AddDeletedSpace;
end;

procedure TLocalBackupSorceAddDeletedSpaceXml.Update;
var
  DeletedSpace : Int64;
begin
    // ������
  if not FindDesPathNode then
    Exit;

  DeletedSpace := MyXmlUtil.GetChildInt64Value( DesPathNode, Xml_DeletedSpace );
  DeletedSpace := DeletedSpace + AddDeletedSpace;
  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

{ TLocalBackupSorceSetDeletedSpaceXml }

procedure TLocalBackupSorceSetDeletedSpaceXml.SetDeletedSpace(
  _DeletedSpace: Int64);
begin
  DeletedSpace := _DeletedSpace;
end;

procedure TLocalBackupSorceSetDeletedSpaceXml.Update;
begin
    // ������
  if not FindDesPathNode then
    Exit;

  MyXmlUtil.AddChild( DesPathNode, Xml_DeletedSpace, DeletedSpace );
end;

end.
