unit ULocalBackupFace;

interface

uses UChangeInfo, virtualtrees, Generics.Collections, UModelUtil, Classes, SyncObjs, ComCtrls,
     UIconUtil, UMyUtil, SysUtils, DateUtils;

type

{$Region ' Դ·�� ѡ�񴰿� ' }

      // д��Ϣ ����
  TVstSelectLocalBackupSourceWriteInfo = class( TFaceChangeInfo )
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ��� ��Ϣ
  TVstSelectLocalBackupSourceAddInfo = class( TVstSelectLocalBackupSourceWriteInfo )
  public
    procedure Update;override;
  end;

    // ɾ�� ��Ϣ
  TVstSelectLocalBackupSourceRemoveInfo = class( TVstSelectLocalBackupSourceWriteInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$Region ' Դ·�� ���Դ��� ' }

  {$Region ' Դ·�� ' }

    // ���ݽṹ
  TLvLocalBackupSourceProData = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ����
  TLvLocalBackupSourceProChange = class( TFaceChangeInfo )
  public
    LvLocalBackupSourcePro : TListView;
  public
    procedure Update;override;
  end;

    // �޸�
  TLvLocalBackupSourceProWrite = class( TLvLocalBackupSourceProChange )
  public
    FullPath : string;
  protected
    PathItem : TListItem;
    PathIndex : Integer;
  public
    constructor Create( _FullPath : string );
  protected
    function FindPathItem : Boolean;
  end;

    // ���
  TLvLocalBackupSourceProAdd = class( TLvLocalBackupSourceProWrite )
  public
    procedure Update;override;
  end;

    // ɾ��
  TLvLocalBackupSourceProRemove = class( TLvLocalBackupSourceProWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Ŀ��·�� ' }

      // ���ݽṹ
  TLvLocalBackupDesProData = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ����
  TLvLocalBackupDesProChange = class( TFaceChangeInfo )
  public
    LvLocalBackupDesPro : TListView;
  public
    procedure Update;override;
  end;

    // �޸�
  TLvLocalBackupDesProWrite = class( TLvLocalBackupDesProChange )
  public
    FullPath : string;
  protected
    PathItem : TListItem;
    PathIndex : Integer;
  public
    constructor Create( _FullPath : string );
  protected
    function FindPathItem : Boolean;
  end;

    // ���
  TLvLocalBackupDesProAdd = class( TLvLocalBackupDesProWrite )
  public
    procedure Update;override;
  end;

    // ɾ��
  TLvLocalBackupDesProRemove = class( TLvLocalBackupDesProWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Դ·�� ���� ' }

    // ���ݽṹ
  TVstLocalBackupSourceData = record
  public
    FullPath, PathType : WideString;
    IsExist, IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    Status, ShowStatus : WideString;
  public
    PathIcon : Integer;
  end;
  PVstLocalBackupSourceData = ^TVstLocalBackupSourceData;

    // ������
  VstLocalBackupSourceUtil = class
  public
    class function IsInclude( FullPath : string ): Boolean;
    class procedure RemoveChild( FullPath : string );
  public
    class function getNextSync( Node : PVirtualNode ): string;
  public
    class function getSelectPathList : TStringList;
    class function getChildPathList( RootPath : string ): TStringList;
  end;

    // ����
  TLvLocalBackupSourceChange = class( TFaceChangeInfo )
  protected
    VstLocalBackupSource : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure ResetStatusColVisible;
  end;

    // ˢ�� ��ʾ�� ʣ��ͬ��ʱ��
  TLVLocalBackupSourceRefreshNextSync = class( TLvLocalBackupSourceChange )
  public
    procedure Update;override;
  end;

    // �޸�
  TLvLocalBackupSourceWrite = class( TLvLocalBackupSourceChange )
  protected
    FullPath : string;
  protected
    SourceNode : PVirtualNode;
    SourceData : PVstLocalBackupSourceData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSourceNode : Boolean;
    procedure RefreshNode;
  protected
    procedure RefresNextSyncTime;
  end;

    // ���
  TLvLocalBackupSourceAdd = class( TLvLocalBackupSourceWrite )
  private
    PathType : string;
    IsDisable : Boolean;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime, NextSyncTime : TDateTime;
  public
    FileCount : Integer;
    FileSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime, _NextSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure Update;override;
  end;

    // ɾ��
  TLvLocalBackupSourceRemove = class( TLvLocalBackupSourceWrite )
  public
    procedure Update;override;
  end;

    // �޸� �ռ���Ϣ
  TLvLocalBackupSourceSpace = class( TLvLocalBackupSourceWrite )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' �޸� ͬ��ʱ����Ϣ ' }

    // ���� ��һ�� ͬ��ʱ��
  TVstLocalBackupSourceSetLastSyncTime = class( TLvLocalBackupSourceWrite )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // ���� ͬ������
  TVstLocalBackupSourceSetSyncTime = class( TLvLocalBackupSourceWrite )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

    // ˢ�� ��һ�� ͬ��ʱ��
  TVstLocalBackupSourceRefreshNextSyncTime = class( TLvLocalBackupSourceWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ״̬ ' }

    // �޸� ״̬
  TLvLocalBackupStatus = class( TLvLocalBackupSourceWrite )
  private
    Status : string;
    ShowStatus : string;
  public
    procedure SetStatus( _Status : string );
    procedure SetShowStatus( _ShowStatus : string );
    procedure Update;override;
  end;

      // �Ƿ� ��ֹ����
  TVstLocalBackupSourceIsDisable = class( TLvLocalBackupSourceWrite )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // �޸� ·���Ƿ����
  TLvLocalBackupExist = class( TLvLocalBackupSourceWrite )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

    // ɨ�����
  TLocalBackupFaceScanCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Ŀ��·�� ���� ' }

  {$Region ' ���ݽṹ �������� ' }

    // ���ݽṹ
  TVstLocalBackupDesData = record
  public
    FullPath : WideString;
    FileSize : Int64;
    Status : WideString;
  public
    IsExist, IsModify : Boolean;
    IsLackSpace : Boolean;
  public
    PathType : WideString;
    SourceFileSize : Int64;
  public
    IsDeleted : Boolean;
  public
    PathIcon : Integer;
  end;
  PVstLocalBackupDesData = ^TVstLocalBackupDesData;

  TVstSelectPathInfo = class
  public
    RootPath, SelectPath : string;
    IsDeleted : Boolean;
  public
    constructor Create( _RootPath, _SelectPath : string );
    procedure SetIsDeleted( _IsDeleted : Boolean );
  end;
  TVstSelectPathList = class( TObjectList<TVstSelectPathInfo> )end;
  VstLocalBackupDesUtil = class
  public
    class function getRootNodeStatus( Node : PVirtualNode ): string;
    class function getRootNodeIcon( Node : PVirtualNode ): Integer;
  public
    class function getNodeStatusInt( Node : PVirtualNode ): Integer;
  public
    class function getChildNodeStatus( Node : PVirtualNode ): string;
    class function getChildNodeIcon( Node : PVirtualNode ): Integer;
  public
    class function IsExistChild( FullPath : string ): Boolean;
    class function IsExist( FullPath : string ): Boolean;
  public
   class function getDesPathList : TStringList;
   class function getSelectPathList : TVstSelectPathList;
   class function getChildPathList( RootPath : string ): TStringList;
   class function getIsRootNode( FullPath : string ): Boolean;
  public
    class function getDesSourcePath( DesPath, SourcePath : string ): string;
    class function getRecyledPath( DesPath, SourcePath : string ): string;
  end;

    // �޸� ����
  TVstLocalBackupDesChange = class( TFaceChangeInfo )
  public
    VstLocalBackupDes : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshTotalPercentage;
    procedure ResetTotalPercentage;
  end;

    // �޸�ָ��·�� ����
  TVstLocalBackupDesWrite = class( TVstLocalBackupDesChange )
  public
    FullPath : string;
  protected
    RootNode : PVirtualNode;
    RootData : PVstLocalBackupDesData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindRootNode : Boolean;
    procedure RefreshRootNode;
    procedure ResetRootSpace;
  end;

  {$EndRegion}

  {$Region ' �޸� ��·�� ' }

    // ���
  TVstLocalBackupDesAdd = class( TVstLocalBackupDesWrite )
  public
    procedure Update;override;
  end;


    // ���ر���Ŀ�� �Ƿ����
  TVstLocalBackupDesIsExist = class( TVstLocalBackupDesWrite )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;override;
  end;

    // ���ر���Ŀ�� �Ƿ���޸�
  TVstLocalBackupDesIsModify = class( TVstLocalBackupDesWrite )
  private
    IsModify : Boolean;
  public
    procedure SetIsModify( _IsModify : Boolean );
    procedure Update;override;
  end;

    // ���ر���Ŀ�� �Ƿ�ȱ�ٿռ�
  TVstLocalBackupDesIsLackSpace = class( TVstLocalBackupDesWrite )
  private
    IsLackSpace : Boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : Boolean );
    procedure Update;override;
  end;

    // ���ر��� �޸�״̬
  TVstLocalBackupDesStatus = class( TVstLocalBackupDesWrite )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // ɾ��
  TVstLocalBackupDesRemove = class( TVstLocalBackupDesWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ��·�� ' }

    // �޸� ��·�� ����
  TvstLocalBackupDesChildChange = class( TVstLocalBackupDesWrite )
  public
    ChildPath : string;
  protected
    ChildNode : PVirtualNode;
    ChildData : PVstLocalBackupDesData;
  public
    procedure SetChildPath( _ChildPath : string );
  protected
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
  end;

    // ���
  TvstLocalBackupDesChildAdd = class( TvstLocalBackupDesChildChange )
  private
    PathType : string;
    SourceSize, CompltedSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSpaceInfo( _SourceSize, _CompletedSize : Int64 );
    procedure Update;override;
  private
    procedure AddChildNode;
  end;


    // �������ɿռ�
  TvstLocalBackupDesChildAddSpace = class( TvstLocalBackupDesChildChange )
  public
    AddSize : Integer;
  public
    procedure SetAddSize( _AddSize : Integer );
    procedure Update;override;
  end;

    // ���� �ռ���Ϣ
  TvstLocalBackupDesChildSetSpace = class( TvstLocalBackupDesChildChange )
  public
    SourceSize : Int64;
    CompletedSize : Int64;
  public
    procedure SetSourceSize( _SourceSize : Int64 );
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ���� ״̬��Ϣ
  TvstLocalBackupDesChildSetStatus = class( TvstLocalBackupDesChildChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // ɾ��
  TvstLocalBackupDesChildRemove = class( TvstLocalBackupDesChildChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ������·�� ' }

    // �޸� ������·�� ����
  TvstLocalBackupDesDeletedChange = class( TVstLocalBackupDesWrite )
  public
    ChildPath : string;
  protected
    ChildNode : PVirtualNode;
    ChildData : PVstLocalBackupDesData;
  public
    procedure SetChildPath( _ChildPath : string );
  protected
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
  end;

    // ���
  TvstLocalBackupDesDeletedAdd = class( TvstLocalBackupDesDeletedChange )
  private
    PathType : string;
    CompltedSize : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSpaceInfo( _CompletedSize : Int64 );
    procedure Update;override;
  end;


    // �������ɿռ�
  TvstLocalBackupDesDeletedAddSpace = class( TvstLocalBackupDesDeletedChange )
  public
    AddSize : Integer;
  public
    procedure SetAddSize( _AddSize : Integer );
    procedure Update;override;
  end;

    // ���� �ռ���Ϣ
  TvstLocalBackupDesDeletedSetSpace = class( TvstLocalBackupDesDeletedChange )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ���� ɾ��״̬
  TvstLocalBackupDesDeletedSetStatus = class( TvstLocalBackupDesDeletedChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // ɾ��
  TvstLocalBackupDesDeletedRemove = class( TvstLocalBackupDesDeletedChange )
  public
    procedure Update;override;
  end;


  {$EndRegion}

{$EndRegion}

{$Region ' ˢ�� ��ʾ״̬ �߳� ' }

    // ����Դ ״̬��Ϣ
  TSourceStatusShowInfo = class
  public
    SourceRootPath, SourceChangeType : string;
    ChangeCount : Integer;
    StartTime : TDateTime;
    IsShow : Boolean;
  public
    constructor Create( _SourceRootPath : string );
    procedure SetSourceChangeType( _SourceChangeType : string );
  end;
  TSourceStatusShowPair = TPair< string , TSourceStatusShowInfo >;
  TSourceStatusShowHash = class(TStringDictionary< TSourceStatusShowInfo >);


    // ˢ��  Դ·��״̬ �߳�
  TLocalBackupSourceStatusShowThread = class( TThread )
  private
    StatusLock : TCriticalSection;
    SourceStatusShowHash : TSourceStatusShowHash;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddSourceRefresh( SourceRootPath : string; RefreshCount : Integer );
    procedure AddSourceCopy( SourceRootPath : string );
  private
    function RefershShowSourceStatus : Boolean;
  end;

      // ����Ŀ�� ״̬��Ϣ
  TDesStatusShowInfo = class
  public
    DesRootPath, DesChangeType : string;
    StartTime : TDateTime;
    IsShow : Boolean;
  public
    SourceRootPath : string;
  public
    constructor Create( _DesRootPath : string );
    procedure SetDesChangeType( _DesChangeType : string );
  end;
  TDesStatusShowPair = TPair< string , TDesStatusShowInfo >;
  TDesStatusShowHash = class(TStringDictionary< TDesStatusShowInfo >);

    // ˢ��  Ŀ��·��״̬ �߳�
  TLocalBackupDesStatusShowThread = class( TThread )
  private
    StatusLock : TCriticalSection;
    DesStatusShowHash : TDesStatusShowHash;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddChange( DesRootPath, DesChangeType : string );
    procedure AddRecycled( DesRootPath, SourceRootPath : string );
  private
    procedure SetPlBackupDesVisible( IsVisible: Boolean );
    function RefreshShowStatus: Boolean;
  private
    procedure ShowRecycled( DesPath, SourcePath : string );
    procedure HideReceycled( DesPath, SourcePath : string );
  end;


    // ����״̬ ˢ����ʾ
  TMyLocalBackupStatusShow = class
  public
    IsRun : Boolean;
    LocalBackupStatusShowThread : TLocalBackupDesStatusShowThread;
    LocalBackupSourceStatusShowThread : TLocalBackupSourceStatusShowThread;
  public
    constructor Create;
    procedure StopShow;
  public
    procedure AddSourceCopy( SourceRootPath : string );
    procedure AddSourceRefresh( SourceRootPath : string; RefreshCount : Integer );
  public
    procedure AddDesChange( DesRootPath, DesChangeType : string );
    procedure AddDesRecycled( DesRootPath, SourceRootPath : string );
  end;

{$EndRegion}


const  // ���� ��Ϣ

  LvLocalBackupSource_FileSize = 0;
  LvLocalBackupSource_FileCount = 1;
  LvLocalBackupSource_FileStatus = 2;

  VstLocalBackupSource_ItemPath = 0;
  VstLocalBackupSource_FileSize = 1;
  VstLocalBackupSource_FileCount = 2;
  VstLocalBackupSource_LastSync = 3;
  VstLocalBackupSource_FileStatus = 4;

  SourceChangeType_Copy = 'Copy';
  SourceChangeType_Refresh = 'Refresh';

  DesChangeType_Add = 'Add';
  DesChangeType_Remove = 'Remove';
  DesChangeType_Recycled = 'Recycled';

const
  LocalBackup_RecycledFolder = 'Recycled';

var
  LocalDes_TotalSpace : Int64 = 0;
  LocalDes_CompletedSpace : Int64 = 0;

var
      // ״̬�仯 ��ʾ�߳�
  MyLocalBackupStatusShow : TMyLocalBackupStatusShow;

implementation

uses UFormLocalBackupPath, UMainForm, UBackupInfoFace, ULocalBackupControl, UFormLocalBackupPro;

{ TVstSelectLocalBackupSourceAddInfo }

procedure TVstSelectLocalBackupSourceAddInfo.Update;
begin
  frmSelectLocalBackupPath.AddBackupPath( FullPath );
end;

{ TVstSelectLocalBackupSourceRemoveInfo }

procedure TVstSelectLocalBackupSourceRemoveInfo.Update;
begin
  frmSelectLocalBackupPath.RemoveBackupPath( FullPath );
end;

{ TVstSelectLocalBackupSourceWriteInfo }

constructor TVstSelectLocalBackupSourceWriteInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceChange }

constructor TLvLocalBackupSourceWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceChange }

procedure TLvLocalBackupSourceChange.ResetStatusColVisible;
var
  IsEmpty : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  co : TVirtualTreeColumn;
begin
    // �Ƿ���� �ǿ�״̬
  IsEmpty := True;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if ( SelectData.Status <> '' ) or not SelectData.IsExist or SelectData.IsDisable then
    begin
      IsEmpty := False;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // ����/��ʾ ��
  Co := VstLocalBackupSource.Header.Columns[ VstLocalBackupSource_FileStatus ];
  if IsEmpty and ( coVisible in co.Options ) then
    co.Options := co.Options - [coVisible]
  else
  if not IsEmpty and  not ( coVisible in co.Options ) then
    co.Options := co.Options + [coVisible];
end;

procedure TLvLocalBackupSourceChange.Update;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
end;



{ TLvLocalBackupSourceAdd }

procedure TLvLocalBackupSourceAdd.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime, _NextSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
  NextSyncTime := _NextSyncTime;
end;

procedure TLvLocalBackupSourceAdd.SetBackupInfo(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TLvLocalBackupSourceAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLvLocalBackupSourceAdd.SetSpaceInfo(_FileCount : Integer;
  _FileSize : Int64);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLvLocalBackupSourceAdd.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TLvLocalBackupSourceAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindSourceNode then
    Exit;

    // ���
  SourceNode := VstLocalBackupSource.AddChild( VstLocalBackupSource.RootNode );
  SourceData := VstLocalBackupSource.GetNodeData( SourceNode );
  SourceData.FullPath := FullPath;
  SourceData.PathType := PathType;
  SourceData.IsExist := True;
  SourceData.IsDisable := IsDisable;
  SourceData.IsAutoSync := IsAutoSync;
  SourceData.SyncTimeType := SyncTimeType;
  SourceData.SyncTimeValue := SyncTimeValue;
  SourceData.LastSyncTime := LastSyncTime;
  SourceData.NextSyncTime := NextSyncTime;
  SourceData.FileCount := FileCount;
  SourceData.FileSize := FileSize;
  SourceData.Status := '';
  SourceData.PathIcon := MyIcon.getIconByPath( PathType, FullPath );

    // ��һ��
  if VstLocalBackupSource.RootNodeCount = 1 then
  begin
    frmMainForm.tbtnLocalBackupNow.Enabled := True;
    VstLocalBackupSource.TreeOptions.PaintOptions := VstLocalBackupSource.TreeOptions.PaintOptions - [toShowBackground];
  end;

    // ˢ�� ��ʾ��
  ResetStatusColVisible;
end;

{ TLvLocalBackupSourceRemove }

procedure TLvLocalBackupSourceRemove.Update;
var
  DeleteIndex : Integer;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // ɾ��
  VstLocalBackupSource.DeleteNode( SourceNode );

    // ���
  if VstLocalBackupSource.RootNodeCount = 0 then
  begin
    frmMainForm.tbtnLocalBackupNow.Enabled := False;
    VstLocalBackupSource.TreeOptions.PaintOptions := VstLocalBackupSource.TreeOptions.PaintOptions + [toShowBackground];
  end;

    // ˢ����ʾ��
  ResetStatusColVisible;
end;

{ TLvLocalBackupSourceSpace }

procedure TLvLocalBackupSourceSpace.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TLvLocalBackupSourceSpace.Update;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // �޸�
  SourceData.FileCount := FileCount;
  SourceData.FileSize := FileSize;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TVstLocalBackupDesIsLackSpace }

procedure TVstLocalBackupDesIsLackSpace.SetIsLackSpace(_IsLackSpace: Boolean);
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TVstLocalBackupDesIsLackSpace.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

    // ��ͬ
  if RootData.IsLackSpace = IsLackSpace then
    Exit;

  RootData.IsLackSpace := IsLackSpace;

    // ˢ�� ��·��
  RefreshRootNode;
end;


function TLvLocalBackupSourceWrite.FindSourceNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
begin
  Result := False;

  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      SourceNode := SelectNode;
      SourceData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TLvLocalBackupSourceWrite.RefreshNode;
begin
  VstLocalBackupSource.RepaintNode( SourceNode );
end;

procedure TLvLocalBackupSourceWrite.RefresNextSyncTime;
var
  SyncMins : Integer;
  NextSyncTime : TDateTime;
begin
    // �´�ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( SourceData.SyncTimeType, SourceData.SyncTimeValue );
  NextSyncTime := IncMinute( SourceData.LastSyncTime, SyncMins );
  SourceData.NextSyncTime := NextSyncTime;
end;

{ TLvLocalBackupStatus }

procedure TLvLocalBackupStatus.SetShowStatus(_ShowStatus: string);
begin
  ShowStatus := _ShowStatus;
end;

procedure TLvLocalBackupStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TLvLocalBackupStatus.Update;
var
  SelectItem : TListItem;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // �޸�
  SourceData.Status := Status;
  SourceData.ShowStatus := ShowStatus;

    // ˢ�½ڵ�
  RefreshNode;

    // ˢ����ʾ��
  ResetStatusColVisible;
end;

{ TLocalBackupFaceScanCompleted }

procedure TLocalBackupFaceScanCompleted.Update;
begin
  if frmMainForm.VstLocalBackupSource.RootNodeCount > 0 then
    frmMainForm.tbtnLocalBackupNow.Enabled := True;
end;

{ VstLocalBackupDesUtil }

class function VstLocalBackupDesUtil.getChildNodeIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstLocalBackupDesData;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if NodeData.FileSize = 0 then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.FileSize >= NodeData.SourceFileSize then
    Result := MyShellTransActionIconUtil.getLoaded
  else
    Result := MyShellTransActionIconUtil.getWaiting;
end;


class function VstLocalBackupDesUtil.getChildNodeStatus(
  Node: PVirtualNode): string;
var
  NodeData : PVstLocalBackupDesData;
  Percentage : Integer;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if NodeData.FileSize = 0 then
    Result := LocalBackupStatus_InCompleted
  else
  if NodeData.FileSize >= NodeData.SourceFileSize then
    Result := LocalBackupStatus_Completed
  else
  begin
    Percentage := MyPercentage.getPercent( NodeData.FileSize, NodeData.SourceFileSize );
    Result := MyPercentage.getPercentageStr( Percentage ) + ' ' + LocalBackupStatus_Completed;
  end;
end;

class function VstLocalBackupDesUtil.getChildPathList(
  RootPath: string): TStringList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode, ChildNode : PVirtualNode;
  NodeData, ChildData : PVstLocalBackupDesData;
begin
  Result := TStringList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    if NodeData.FullPath = RootPath then
    begin
      ChildNode := SelectNode.FirstChild;
      while Assigned( ChildNode ) do
      begin
        ChildData := vstLocalBackupDes.GetNodeData( ChildNode );
        Result.Add( ChildData.FullPath );
        ChildNode := ChildNode.NextSibling;
      end;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


class function VstLocalBackupDesUtil.getDesPathList: TStringList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstLocalBackupDesData;
begin
  Result := TStringList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    Result.Add( NodeData.FullPath );
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.getDesSourcePath(DesPath,
  SourcePath: string): string;
begin
  Result := MyFilePath.getPath( DesPath );
  Result := Result + MyFilePath.getDownloadPath( SourcePath );
end;

class function VstLocalBackupDesUtil.getIsRootNode(FullPath: string): Boolean;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode : PVirtualNode;
  NodeData : PVstLocalBackupDesData;
begin
  Result := False;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    if NodeData.FullPath = FullPath then
    begin
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.getRecyledPath(DesPath,
  SourcePath: string): string;
begin
  Result := MyFilePath.getPath( DesPath );
  Result := Result + LocalBackup_RecycledFolder + '\';
  Result := Result + MyFilePath.getDownloadPath( SourcePath );
end;

class function VstLocalBackupDesUtil.getRootNodeIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstLocalBackupDesData;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if not NodeData.IsExist or not NodeData.IsModify
  then
    Result := MyShellTransActionIconUtil.getDisable
  else
  if NodeData.Status = LocalBackupStatus_Copying then
    Result := MyShellTransActionIconUtil.getCopyFile
  else
  if NodeData.Status = LocalBackupStatus_Removing then
    Result := MyShellTransActionIconUtil.getRecycle
  else
  begin
    if NodeData.FileSize >= NodeData.SourceFileSize then
      Result := MyShellTransActionIconUtil.getLoaded
    else
    if NodeData.IsLackSpace then
      Result := MyShellTransActionIconUtil.getDisable
    else
    if NodeData.FileSize = 0 then
      Result := MyShellTransActionIconUtil.getLoadedError
    else
      Result := MyShellTransActionIconUtil.getWaiting;
  end;
end;

class function VstLocalBackupDesUtil.getRootNodeStatus(Node: PVirtualNode): string;
var
  NodeData : PVstLocalBackupDesData;
  Percentage : Integer;
  FileSize, SourceSize : Int64;
begin
  NodeData := frmMainForm.VstLocalBackupDes.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := LocalBackupStatus_NotExist
  else
  if not NodeData.IsModify then
    Result := LocalBackupStatus_Unmodifiable
  else
  if NodeData.Status <> '' then
    Result := NodeData.Status
  else
  begin
    FileSize := NodeData.FileSize;
    SourceSize := NodeData.SourceFileSize;

      // ���ݿռ�ȷ��״̬
    if FileSize >= SourceSize then
    begin
      Result := LocalBackupStatus_Completed;
      if NodeData.IsLackSpace then  // ����ȱ�ٿռ��״̬
        NodeData.IsLackSpace := False;
    end
    else
    if NodeData.IsLackSpace then
      Result := LocalBackupStatus_LackSpace
    else
    if FileSize = 0 then
      Result := LocalBackupStatus_InCompleted
    else
    begin
      Percentage := MyPercentage.getPercent( FileSize, SourceSize );
      Result := MyPercentage.getPercentageStr( Percentage ) + ' ' + LocalBackupStatus_Completed;
    end;
  end;
end;

class function VstLocalBackupDesUtil.getNodeStatusInt(
  Node: PVirtualNode): Integer;
var
  NodeStatus : string;
begin
  NodeStatus := getRootNodeStatus( Node );
  if NodeStatus = LocalBackupStatus_NotExist then
    Result := 1
  else
  if NodeStatus = LocalBackupStatus_Unmodifiable then
    Result := 2
  else
  if NodeStatus = LocalBackupStatus_LackSpace then
    Result := 3
  else
  if NodeStatus = LocalBackupStatus_Copying then
    Result := 4
  else
  if NodeStatus = LocalBackupStatus_Removing then
    Result := 5
  else
  if NodeStatus = LocalBackupStatus_InCompleted then
    Result := 6
  else
  if NodeStatus = LocalBackupStatus_Completed then
    Result := 8
  else
    Result := 7;
end;


class function VstLocalBackupDesUtil.getSelectPathList: TVstSelectPathList;
var
  vstLocalBackupDes : TVirtualStringTree;
  SelectNode, RootNode : PVirtualNode;
  NodeData, RootData : PVstLocalBackupDesData;
  SelectInfo : TVstSelectPathInfo;
begin
  Result := TVstSelectPathList.Create;

  vstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  SelectNode := vstLocalBackupDes.GetFirstSelected;
  while Assigned( SelectNode ) do
  begin
    if SelectNode.Parent = vstLocalBackupDes.RootNode then
      RootNode := SelectNode
    else
      RootNode := SelectNode.Parent;

    RootData := vstLocalBackupDes.GetNodeData( RootNode );
    NodeData := vstLocalBackupDes.GetNodeData( SelectNode );
    SelectInfo := TVstSelectPathInfo.Create( RootData.FullPath, NodeData.FullPath );
    SelectInfo.SetIsDeleted( NodeData.IsDeleted );
    Result.Add( SelectInfo );

    SelectNode := vstLocalBackupDes.GetNextSelected( SelectNode );
  end;
end;

class function VstLocalBackupDesUtil.IsExist(FullPath: string): Boolean;
var
  VstLocalBackupDes : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  Node := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := frmMainForm.VstLocalBackupDes.GetNodeData(Node);
    // ���ܰ���Ŀ��·��
    if NodeData.FullPath = FullPath then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

class function VstLocalBackupDesUtil.IsExistChild(FullPath: string): Boolean;
var
  VstLocalBackupDes : TVirtualStringTree;
  Node: PVirtualNode;
  NodeData: PVstLocalBackupDesData;
begin
  Result := False;
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
  Node := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned(Node) do
  begin
    NodeData := VstLocalBackupDes.GetNodeData(Node);
    // ���ܰ���Ŀ��·��
    if MyMatchMask.CheckEqualsOrChild(NodeData.FullPath, FullPath) then
    begin
      Result := True;
      Break;
    end;
    Node := Node.NextSibling;
  end;
end;

{ TVstLocalBackupDesStatus }

procedure TVstLocalBackupDesStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstLocalBackupDesStatus.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.Status := Status;

    // ˢ�� ��·��
  RefreshRootNode;
end;

{ TvstLocalBackupDesChildChange }

function TvstLocalBackupDesChildChange.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;
  if not FindRootNode then
    Exit;

  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if not SelectData.IsDeleted and ( SelectData.FullPath = ChildPath ) then
    begin
      ChildNode := SelectNode;
      ChildData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TvstLocalBackupDesChildChange.RefreshChildNode;
begin
  VstLocalBackupDes.RepaintNode( ChildNode );
end;

procedure TvstLocalBackupDesChildChange.SetChildPath(_ChildPath: string);
begin
  ChildPath := _ChildPath;
end;

{ TvstLocalBackupDesChildAdd }

procedure TvstLocalBackupDesChildAdd.AddChildNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
  IsFindDelted : Boolean;
  FirstDeltedNode : PVirtualNode;
begin
  IsFindDelted := False;
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.IsDeleted then
    begin
      FirstDeltedNode := SelectNode;
      IsFindDelted := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

  if not IsFindDelted then
    ChildNode := VstLocalBackupDes.AddChild( RootNode )
  else
    ChildNode := VstLocalBackupDes.InsertNode( FirstDeltedNode, amInsertBefore );
end;

procedure TvstLocalBackupDesChildAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TvstLocalBackupDesChildAdd.SetSpaceInfo(_SourceSize,
  _CompletedSize: Int64);
begin
  SourceSize := _SourceSize;
  CompltedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesChildAdd.Update;
begin
  inherited;

  if not FindRootNode or FindChildNode then
    Exit;

  AddChildNode; // �����ڵ�
  ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
  ChildData.FullPath := ChildPath;
  ChildData.PathType := PathType;
  ChildData.FileSize := CompltedSize;
  ChildData.SourceFileSize := SourceSize;
  ChildData.IsDeleted := False;
  ChildData.Status := '';
  ChildData.PathIcon := MyIcon.getIconByPath( PathType, VstLocalBackupDesUtil.getDesSourcePath( FullPath, ChildPath ) );

    // ˢ�� ��·��
  RootData.FileSize := RootData.FileSize + CompltedSize;
  RootData.SourceFileSize := RootData.SourceFileSize + SourceSize;
  RefreshRootNode;

    // ˢ�� �ܰٷֱ�
  LocalDes_TotalSpace := LocalDes_TotalSpace + SourceSize;
  LocalDes_CompletedSpace := LocalDes_CompletedSpace + CompltedSize;
  RefreshTotalPercentage;

    // չ����Ŀ¼
  if ( RootNode.ChildCount = 1 ) and not VstLocalBackupDes.Expanded[ RootNode ] then
    VstLocalBackupDes.Expanded[ RootNode ] := True;
end;

{ TvstLocalBackupDesChildRemove }

procedure TvstLocalBackupDesChildRemove.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // �޸� ��Ŀ¼
  RootData.FileSize := RootData.FileSize - ChildData.FileSize;
  RootData.SourceFileSize := RootData.SourceFileSize - ChildData.SourceFileSize;
  RefreshRootNode;

    // ˢ�� ����
  LocalDes_TotalSpace := LocalDes_TotalSpace - ChildData.SourceFileSize;
  LocalDes_CompletedSpace := LocalDes_CompletedSpace - ChildData.FileSize;
  RefreshTotalPercentage;

    // ɾ�� ��Ŀ¼
  VstLocalBackupDes.DeleteNode( ChildNode );
end;

{ TvstLocalBackupDesChildSourceSpace }

procedure TvstLocalBackupDesChildSetSpace.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesChildSetSpace.SetSourceSize(
  _SourceSize: Int64);
begin
  SourceSize := _SourceSize;
end;

procedure TvstLocalBackupDesChildSetSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // �޸� ��Ŀ¼
  ChildData.SourceFileSize := SourceSize;
  ChildData.FileSize := CompletedSize;
  VstLocalBackupDes.RepaintNode( ChildNode );

    // �޸� ��Ŀ¼
  ResetRootSpace;

    // ˢ�� �ܰٷֱ�
  ResetTotalPercentage;
end;

{ TvstLocalBackupDesChildAddSpace }

procedure TvstLocalBackupDesChildAddSpace.SetAddSize(_AddSize: Integer);
begin
  AddSize := _AddSize;
end;

procedure TvstLocalBackupDesChildAddSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

    // ˢ���ļ�ͼ��
  if ( ChildData.FileSize = 0 ) and ( ChildData.PathType = PathType_File ) then
    ChildData.PathIcon := MyIcon.getIconByPath( PathType_File, VstLocalBackupDesUtil.getDesSourcePath( FullPath, ChildPath ) );

    // �޸� ��·��
  ChildData.FileSize := ChildData.FileSize + AddSize;
  RefreshChildNode;

    // �޸� ��·��
  RootData.FileSize := RootData.FileSize + AddSize;
  VstLocalBackupDes.RepaintNode( RootNode );

    // ˢ�� �ܰٷֱ�
  LocalDes_CompletedSpace := LocalDes_CompletedSpace + AddSize;
  RefreshTotalPercentage;
end;

{ TVstLocalBackupDesChange }

procedure TVstLocalBackupDesChange.RefreshTotalPercentage;
begin
  frmMainForm.PbLocalBackup.Percent := MyPercentage.getPercent( LocalDes_CompletedSpace, LocalDes_TotalSpace );
  frmMainForm.plLocalBackupPercentShow.Caption := MyPercentage.getCompareStr( LocalDes_CompletedSpace, LocalDes_TotalSpace );
end;

procedure TVstLocalBackupDesChange.ResetTotalPercentage;
var
  TotalSize, TotalCompletedSize : Int64;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  TotalSize := 0;
  TotalCompletedSize := 0;

  SelectNode := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    TotalSize := TotalSize + SelectData.SourceFileSize;
    TotalCompletedSize := TotalCompletedSize + SelectData.FileSize;
    SelectNode := SelectNode.NextSibling;
  end;

    // ����ֵ �� ˢ�½���
  LocalDes_TotalSpace := TotalSize;
  LocalDes_CompletedSpace := TotalCompletedSize;
  RefreshTotalPercentage;
end;


procedure TVstLocalBackupDesChange.Update;
begin
  VstLocalBackupDes := frmMainForm.VstLocalBackupDes;
end;

{ TVstLocalBackupDesWrite }

constructor TVstLocalBackupDesWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TVstLocalBackupDesWrite.FindRootNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;

  SelectNode := VstLocalBackupDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      RootNode := SelectNode;
      RootData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstLocalBackupDesWrite.RefreshRootNode;
begin
  VstLocalBackupDes.RepaintNode( RootNode );
end;

procedure TVstLocalBackupDesWrite.ResetRootSpace;
var
  SourceFileSize, FileSize : Int64;
  ChildNode : PVirtualNode;
  ChildData : PVstLocalBackupDesData;
begin
  SourceFileSize := 0;
  FileSize := 0;
  ChildNode := RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
    if not ChildData.IsDeleted then
    begin
      SourceFileSize := SourceFileSize + ChildData.SourceFileSize;
      FileSize := FileSize + ChildData.FileSize;
    end;
    ChildNode := ChildNode.NextSibling;
  end;

  RootData.SourceFileSize := SourceFileSize;
  RootData.FileSize := FileSize;
  RefreshRootNode;
end;


{ TVstLocalBackupDesAdd }

procedure TVstLocalBackupDesAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindRootNode then
    Exit;

    // ����
  RootNode := VstLocalBackupDes.AddChild( VstLocalBackupDes.RootNode );
  RootData := VstLocalBackupDes.GetNodeData( RootNode );

    // ��ʼ��
  RootData.FullPath := FullPath;
  RootData.FileSize := 0;
  RootData.SourceFileSize := 0;
  RootData.IsExist := True;
  RootData.IsModify := True;
  RootData.IsLackSpace := False;
  RootData.IsDeleted := False;
  RootData.Status := '';
  RootData.PathIcon := MyIcon.getIconByPath( PathType_Folder, FullPath );

    // ��һ��·��
  if VstLocalBackupDes.RootNodeCount = 1 then
    VstLocalBackupDes.TreeOptions.PaintOptions := VstLocalBackupDes.TreeOptions.PaintOptions - [toShowBackground];
end;

{ TVstLocalBackupDesRemove }

procedure TVstLocalBackupDesRemove.Update;
begin
  inherited;

    // ������
  if not FindRootNode then
    Exit;

  VstLocalBackupDes.DeleteNode( RootNode );

    // ��һ��·��
  if VstLocalBackupDes.RootNodeCount = 0 then
    VstLocalBackupDes.TreeOptions.PaintOptions := VstLocalBackupDes.TreeOptions.PaintOptions + [toShowBackground];
end;

{ TVstLocalBackupDesIsExist }

procedure TVstLocalBackupDesIsExist.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TVstLocalBackupDesIsExist.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.IsExist := IsExist;
  RootData.PathIcon := MyIcon.getIconByPath( PathType_Folder, FullPath );

    // ˢ�� ��·��
  RefreshRootNode;
end;

{ TVstLocalBackupDesIsModify }

procedure TVstLocalBackupDesIsModify.SetIsModify(_IsModify: Boolean);
begin
  IsModify := _IsModify;
end;

procedure TVstLocalBackupDesIsModify.Update;
begin
  inherited;

  if not FindRootNode then
    Exit;

  RootData.IsModify := IsModify;

    // ˢ�� ��·��
  RefreshRootNode;
end;

{ TLocalStatusShowInfo }

constructor TSourceStatusShowInfo.Create(_SourceRootPath: string);
begin
  SourceRootPath := _SourceRootPath;
end;

procedure TSourceStatusShowInfo.SetSourceChangeType(_SourceChangeType: string);
begin
  SourceChangeType := _SourceChangeType;
end;

{ TLocalBackupSourceStatusShowThread }

procedure TLocalBackupSourceStatusShowThread.AddSourceCopy(
  SourceRootPath: string);
var
  SourceStatusShowInfo : TSourceStatusShowInfo;
begin
  StatusLock.Enter;
  if not SourceStatusShowHash.ContainsKey( SourceRootPath ) then
  begin
    SourceStatusShowInfo := TSourceStatusShowInfo.Create( SourceRootPath );
    SourceStatusShowHash.AddOrSetValue( SourceRootPath, SourceStatusShowInfo );
  end
  else
    SourceStatusShowInfo := SourceStatusShowHash[ SourceRootPath ];
  if SourceStatusShowInfo.SourceChangeType <> SourceChangeType_Copy then
  begin
    SourceStatusShowInfo.SetSourceChangeType( SourceChangeType_Copy );
    SourceStatusShowInfo.IsShow := True;
  end;
  SourceStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

procedure TLocalBackupSourceStatusShowThread.AddSourceRefresh(
  SourceRootPath: string; RefreshCount: Integer);
var
  SourceStatusShowInfo : TSourceStatusShowInfo;
begin
  StatusLock.Enter;

  if not SourceStatusShowHash.ContainsKey( SourceRootPath ) then
  begin
    SourceStatusShowInfo := TSourceStatusShowInfo.Create( SourceRootPath );
    SourceStatusShowHash.AddOrSetValue( SourceRootPath, SourceStatusShowInfo );
  end
  else
    SourceStatusShowInfo := SourceStatusShowHash[ SourceRootPath ];

  SourceStatusShowInfo.SetSourceChangeType( SourceChangeType_Refresh );
  SourceStatusShowInfo.IsShow := True;
  SourceStatusShowInfo.ChangeCount := RefreshCount;
  SourceStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

constructor TLocalBackupSourceStatusShowThread.Create;
begin
  inherited;
  StatusLock := TCriticalSection.Create;
  SourceStatusShowHash := TSourceStatusShowHash.Create;
end;

destructor TLocalBackupSourceStatusShowThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  SourceStatusShowHash.Free;
  StatusLock.Free;
  inherited;
end;

procedure TLocalBackupSourceStatusShowThread.Execute;
begin
  while not Terminated do
  begin
    if not RefershShowSourceStatus then
      Suspend
    else
      Sleep(200);
  end;
  inherited;
end;


function TLocalBackupSourceStatusShowThread.RefershShowSourceStatus: Boolean;
var
  RemoveList : TStringList;
  i : Integer;
  p : TSourceStatusShowPair;
  NewStatus, ShowStatus : string;
  LocalBackupSourceStatusHandle : TLocalBackupSourceStatusHandle;
begin
  StatusLock.Enter;
  RemoveList := TStringList.Create;

    // ��ʾ
  for p in SourceStatusShowHash do
  begin

      // �Ƿ����
    if SecondsBetween( Now, p.Value.StartTime ) > 2 then
    begin
      NewStatus := '';
      ShowStatus := '';
      RemoveList.Add( p.Value.SourceRootPath );
    end
    else   // �Ƿ���ʾ
    if not p.Value.IsShow then
      Continue
    else
    begin
      p.Value.IsShow := False;
      if p.Value.SourceChangeType = SourceChangeType_Copy then
      begin
        NewStatus := LocalBackupSourceStatus_Copy;
        ShowStatus := NewStatus;
      end
      else
      begin
        NewStatus := LocalBackupSourceStatus_Refresh;
        ShowStatus := LocalBackupSourceStatus_Refresh + ' ' + IntToStr( p.Value.ChangeCount ) + ' Files';
      end;
    end;

      // ˢ��״̬
    LocalBackupSourceStatusHandle := TLocalBackupSourceStatusHandle.Create( p.Value.SourceRootPath );
    LocalBackupSourceStatusHandle.SetStatus( NewStatus );
    LocalBackupSourceStatusHandle.SetShowStatus( ShowStatus );
    LocalBackupSourceStatusHandle.Update;
    LocalBackupSourceStatusHandle.Free;
  end;

    // ɾ��
  for i := 0 to RemoveList.Count - 1 do
    SourceStatusShowHash.Remove( RemoveList[i] );
  RemoveList.Free;

  Result := SourceStatusShowHash.Count > 0;

  StatusLock.Leave;
end;

{ TDesStatusShowInfo }

procedure TDesStatusShowInfo.SetDesChangeType(_DesChangeType: string);
begin
  DesChangeType := _DesChangeType;
end;

constructor TDesStatusShowInfo.Create(_DesRootPath: string);
begin
  DesRootPath := _DesRootPath;
end;

{ TLocalBackupDesStatusShowThread }

procedure TLocalBackupDesStatusShowThread.AddChange(DesRootPath,
  DesChangeType: string);
var
  DesStatusShowInfo : TDesStatusShowInfo;
begin
  StatusLock.Enter;
  if not DesStatusShowHash.ContainsKey( DesRootPath ) then
  begin
    DesStatusShowInfo := TDesStatusShowInfo.Create( DesRootPath );
    DesStatusShowHash.AddOrSetValue( DesRootPath, DesStatusShowInfo );
  end
  else
    DesStatusShowInfo := DesStatusShowHash[ DesRootPath ];
  if DesStatusShowInfo.DesChangeType <> DesChangeType then
  begin
    if DesStatusShowInfo.DesChangeType = DesChangeType_Recycled then
      HideReceycled( DesStatusShowInfo.DesRootPath, DesStatusShowInfo.SourceRootPath );
    DesStatusShowInfo.SetDesChangeType( DesChangeType );
    DesStatusShowInfo.IsShow := True;
  end;
  DesStatusShowInfo.StartTime := Now;
  StatusLock.Leave;

  Resume;
end;

procedure TLocalBackupDesStatusShowThread.AddRecycled(DesRootPath,
  SourceRootPath: string);
begin
  AddChange( DesRootPath, DesChangeType_Recycled );

    // ���� Դ·��
  StatusLock.Enter;
  if DesStatusShowHash.ContainsKey( DesRootPath ) then
    DesStatusShowHash[ DesRootPath ].SourceRootPath := SourceRootPath;
  StatusLock.Leave;
end;

constructor TLocalBackupDesStatusShowThread.Create;
begin
  inherited Create( True );
  StatusLock := TCriticalSection.Create;
  DesStatusShowHash := TDesStatusShowHash.Create;
end;

destructor TLocalBackupDesStatusShowThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  DesStatusShowHash.Free;
  StatusLock.Free;
  inherited;
end;

procedure TLocalBackupDesStatusShowThread.Execute;
begin
  if not Terminated then
    SetPlBackupDesVisible( True );

  while not Terminated do
  begin

    if not RefreshShowStatus then
    begin
      SetPlBackupDesVisible( False );
      Suspend;
      SetPlBackupDesVisible( True );
    end
    else
      Sleep(200);
  end;
  inherited;
end;

procedure TLocalBackupDesStatusShowThread.HideReceycled(DesPath,
  SourcePath: string);
var
  vstLocalBackupDesChildSetStatus : TvstLocalBackupDesChildSetStatus;
  vstLocalBackupDesDeletedSetStatus : TvstLocalBackupDesDeletedSetStatus;
begin
    // ����·��
  vstLocalBackupDesChildSetStatus := TvstLocalBackupDesChildSetStatus.Create( DesPath );
  vstLocalBackupDesChildSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesChildSetStatus.SetStatus( '' );
  MyFaceChange.AddChange( vstLocalBackupDesChildSetStatus );

    // ����·��
  vstLocalBackupDesDeletedSetStatus := TvstLocalBackupDesDeletedSetStatus.Create( DesPath );
  vstLocalBackupDesDeletedSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesDeletedSetStatus.SetStatus( '' );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedSetStatus );
end;

function TLocalBackupDesStatusShowThread.RefreshShowStatus: Boolean;
var
  RemoveList : TStringList;
  i : Integer;
  p : TDesStatusShowPair;
  VstLocalBackupDesStatus : TVstLocalBackupDesStatus;
  ShowStatus : string;
begin
  StatusLock.Enter;
  RemoveList := TStringList.Create;

    // ��ʾ
  for p in DesStatusShowHash do
  begin

      // �Ƿ����
    if SecondsBetween( Now, p.Value.StartTime ) > 2 then
    begin
      ShowStatus := '';
      RemoveList.Add( p.Value.DesRootPath );
    end
    else   // �Ƿ���ʾ
    if not p.Value.IsShow then
      Continue
    else
    begin
      p.Value.IsShow := False;

      if p.Value.DesChangeType = DesChangeType_Add then
        ShowStatus := LocalBackupStatus_Copying
      else
        ShowStatus := LocalBackupStatus_Removing;
    end;

      // ���յ����
    if p.Value.DesChangeType = DesChangeType_Recycled then
    begin
      if ShowStatus = '' then
        HideReceycled( p.Value.DesRootPath, p.Value.SourceRootPath )
      else
        ShowRecycled( p.Value.DesRootPath, p.Value.SourceRootPath );
      Continue;
    end;

      // ��ʾ
    VstLocalBackupDesStatus := TVstLocalBackupDesStatus.Create( p.Value.DesRootPath );
    VstLocalBackupDesStatus.SetStatus( ShowStatus );
    MyBackupFileFace.AddChange( VstLocalBackupDesStatus );
  end;

    // ɾ��
  for i := 0 to RemoveList.Count - 1 do
    DesStatusShowHash.Remove( RemoveList[i] );
  RemoveList.Free;

  Result := DesStatusShowHash.Count > 0;

  StatusLock.Leave;
end;

procedure TLocalBackupDesStatusShowThread.SetPlBackupDesVisible(
  IsVisible: Boolean);
var
  PlBackupDesBoardVisibleInfo : TPlBackupDesBoardVisibleInfo;
begin
  PlBackupDesBoardVisibleInfo := TPlBackupDesBoardVisibleInfo.Create( IsVisible );
  MyBackupFileFace.AddChange( PlBackupDesBoardVisibleInfo );
end;

procedure TLocalBackupDesStatusShowThread.ShowRecycled(DesPath,
  SourcePath: string);
var
  vstLocalBackupDesChildSetStatus : TvstLocalBackupDesChildSetStatus;
  vstLocalBackupDesDeletedSetStatus : TvstLocalBackupDesDeletedSetStatus;
begin
    // ����·��
  vstLocalBackupDesChildSetStatus := TvstLocalBackupDesChildSetStatus.Create( DesPath );
  vstLocalBackupDesChildSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesChildSetStatus.SetStatus( LocalBackupStatus_Recycling );
  MyFaceChange.AddChange( vstLocalBackupDesChildSetStatus );

    // ����·��
  vstLocalBackupDesDeletedSetStatus := TvstLocalBackupDesDeletedSetStatus.Create( DesPath );
  vstLocalBackupDesDeletedSetStatus.SetChildPath( SourcePath );
  vstLocalBackupDesDeletedSetStatus.SetStatus( LocalBackupStatus_Copying );
  MyFaceChange.AddChange( vstLocalBackupDesDeletedSetStatus );
end;

{ TMyLocalBackupStatusShow }

procedure TMyLocalBackupStatusShow.AddDesChange(DesRootPath,
  DesChangeType: string);
begin
  if not IsRun then
    Exit;

  LocalBackupStatusShowThread.AddChange( DesRootPath, DesChangeType );
end;

procedure TMyLocalBackupStatusShow.AddDesRecycled(DesRootPath,
  SourceRootPath: string);
begin
  if not IsRun then
    Exit;

  LocalBackupStatusShowThread.AddRecycled( DesRootPath, SourceRootPath );
end;

procedure TMyLocalBackupStatusShow.AddSourceCopy(SourceRootPath: string);
begin
  if not IsRun then
    Exit;

  LocalBackupSourceStatusShowThread.AddSourceCopy( SourceRootPath );
end;

procedure TMyLocalBackupStatusShow.AddSourceRefresh(SourceRootPath: string;
  RefreshCount: Integer);
begin
  if not IsRun then
    Exit;

  LocalBackupSourceStatusShowThread.AddSourceRefresh( SourceRootPath, RefreshCount );
end;

constructor TMyLocalBackupStatusShow.Create;
begin
  LocalBackupStatusShowThread := TLocalBackupDesStatusShowThread.Create;
  LocalBackupSourceStatusShowThread := TLocalBackupSourceStatusShowThread.Create;
  IsRun := True;
end;

procedure TMyLocalBackupStatusShow.StopShow;
begin
  IsRun := False;
  LocalBackupStatusShowThread.Free;
  LocalBackupSourceStatusShowThread.Free;
end;

{ TLvLocalBackupExist }

procedure TLvLocalBackupExist.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TLvLocalBackupExist.Update;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // �޸�
  SourceData.IsExist := IsExist;
  SourceData.PathIcon := MyIcon.getIconByPath( SourceData.PathType, FullPath );

    // ˢ�½ڵ�
  RefreshNode;

    // ˢ����ʾ��
  ResetStatusColVisible;
end;

{ VstLocalBackupSourceUtil }

class function VstLocalBackupSourceUtil.getChildPathList(
  RootPath: string): TStringList;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode, ChildNode : PVirtualNode;
  SelectData, ChildData : PVstLocalBackupSourceData;
begin
  Result := TStringList.Create;

  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    if SelectData.FullPath = RootPath then
    begin
      ChildNode := SelectNode.FirstChild;
      while Assigned( ChildNode ) do
      begin
        ChildData := VstLocalBackupSource.GetNodeData( ChildNode );
        Result.Add( ChildData.FullPath );
        ChildNode := ChildNode.NextSibling;
      end;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupSourceUtil.getNextSync(Node: PVirtualNode): string;
var
  VstLocalBackupSource : TVirtualStringTree;
  NodeData : PVstLocalBackupSourceData;
  ShowStr : string;
  ShowStrList : TStringList;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  NodeData := VstLocalBackupSource.GetNodeData( Node );
  if not NodeData.IsAutoSync or NodeData.IsDisable then
    Result := frmMainForm.siLang_frmMainForm.GetText( 'NA' )
  else
  begin
    ShowStr := TimeTypeUtil.getMinShowStr( MinutesBetween( Now, NodeData.NextSyncTime ) );
    Result := LanguageUtil.getSyncTimeStr( ShowStr );
  end;
end;

class function VstLocalBackupSourceUtil.getSelectPathList: TStringList;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
begin
  Result := TStringList.Create;

  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    if VstLocalBackupSource.Selected[ SelectNode ] then
    begin
      SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
      Result.Add( SelectData.FullPath );
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

class function VstLocalBackupSourceUtil.IsInclude(FullPath: string): Boolean;
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  Result := False;
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;

      // ���ڸ�·��
    if MyMatchMask.CheckEqualsOrChild(FullPath, SourcePath) then
    begin
      Result := True;
      Break;
    end;

    SelectNode := SelectNode.NextSibling;
  end;
end;

class procedure VstLocalBackupSourceUtil.RemoveChild(FullPath: string);
var
  VstLocalBackupSource : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupSourceData;
  SourcePath: string;
begin
  VstLocalBackupSource := frmMainForm.VstLocalBackupSource;
  SelectNode := VstLocalBackupSource.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupSource.GetNodeData( SelectNode );
    SourcePath := SelectData.FullPath;
        // ɾ����·��
    if MyMatchMask.CheckChild( SourcePath, FullPath ) then
      MyLocalBackupSourceControl.RemoveSourcePath( SourcePath );

    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLvLocalBackupSourceProData }

constructor TLvLocalBackupSourceProData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupSourceProChange }

procedure TLvLocalBackupSourceProChange.Update;
begin
  LvLocalBackupSourcePro := FrmLocalBackupPro.LvBackupItem;
end;

{ TLvLocalBackupSourceProWrite }

constructor TLvLocalBackupSourceProWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvLocalBackupSourceProWrite.FindPathItem: Boolean;
var
  i : Integer;
  SelectData : TLvLocalBackupSourceProData;
begin
  Result := False;

  for i := 0 to LvLocalBackupSourcePro.Items.Count - 1 do
  begin
    SelectData := LvLocalBackupSourcePro.Items[i].Data;
    if SelectData.FullPath = FullPath then
    begin
      PathItem := LvLocalBackupSourcePro.Items[i];
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvLocalBackupSourceProAdd }

procedure TLvLocalBackupSourceProAdd.Update;
var
  PathData : TLvLocalBackupSourceProData;
begin
  inherited;

    // �Ѵ���
  if FindPathItem then
    Exit;

    // ����
  PathData := TLvLocalBackupSourceProData.Create( FullPath );
  with LvLocalBackupSourcePro.Items.Add do
  begin
    Caption := ExtractFileName( FullPath );
    SubItems.Add('');
    ImageIndex := MyIcon.getIconByFilePath( FullPath );
    Data := PathData;
  end;
end;

{ TLvLocalBackupSourceProRemove }

procedure TLvLocalBackupSourceProRemove.Update;
begin
  inherited;

    // ������
  if not FindPathItem then
    Exit;

    // ɾ��
  LvLocalBackupSourcePro.Items.Delete( PathIndex );
end;

{ TLvLocalBackupDesProData }

constructor TLvLocalBackupDesProData.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TLvLocalBackupDesProChange }

procedure TLvLocalBackupDesProChange.Update;
begin
  LvLocalBackupDesPro := FrmLocalBackupPro.LvDestination;
end;

{ TLvLocalBackupDesProWrite }

constructor TLvLocalBackupDesProWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvLocalBackupDesProWrite.FindPathItem: Boolean;
var
  i : Integer;
  SelectData : TLvLocalBackupDesProData;
begin
  Result := False;

  for i := 0 to LvLocalBackupDesPro.Items.Count - 1 do
  begin
    SelectData := LvLocalBackupDesPro.Items[i].Data;
    if SelectData.FullPath = FullPath then
    begin
      PathItem := LvLocalBackupDesPro.Items[i];
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvLocalBackupDesProAdd }

procedure TLvLocalBackupDesProAdd.Update;
var
  PathData : TLvLocalBackupDesProData;
begin
  inherited;

    // �Ѵ���
  if FindPathItem then
    Exit;

    // ����
  PathData := TLvLocalBackupDesProData.Create( FullPath );
  with LvLocalBackupDesPro.Items.Add do
  begin
    Caption := FullPath;
    SubItems.Add('');
    ImageIndex := MyIcon.getIconByFilePath( FullPath );
    Data := PathData;
  end;
end;

{ TLvLocalBackupDesProRemove }

procedure TLvLocalBackupDesProRemove.Update;
begin
  inherited;

    // ������
  if not FindPathItem then
    Exit;

    // ɾ��
  LvLocalBackupDesPro.Items.Delete( PathIndex );
end;

{ TVstLocalBackupSourceSetLastSyncTime }

procedure TVstLocalBackupSourceSetLastSyncTime.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TVstLocalBackupSourceSetLastSyncTime.Update;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // ���� ��һ�� ͬ��ʱ��
  SourceData.LastSyncTime := LastSyncTime;

    // ˢ�� �´�ͬ��ʱ��
  RefresNextSyncTime;

    // ˢ�½ڵ�
  RefreshNode;
end;


{ TVstLocalBackupSourceSetSyncMins }

procedure TVstLocalBackupSourceSetSyncTime.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TVstLocalBackupSourceSetSyncTime.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TVstLocalBackupSourceSetSyncTime.Update;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // ���� ��һ�� ͬ��ʱ��
  SourceData.IsAutoSync := IsAutoSync;
  SourceData.SyncTimeType := SyncTimeType;
  SourceData.SyncTimeValue := SyncTimeValue;

    // ˢ�� �´�ͬ��ʱ��
  RefresNextSyncTime;

    // ˢ�½ڵ�
  RefreshNode;
end;

{ TVstLocalBackupSourceRefreshNextSyncTime }

procedure TVstLocalBackupSourceRefreshNextSyncTime.Update;
begin
  inherited;
  RefreshNode;
end;

{ TVstLocalBackupSourceIsDisable }

procedure TVstLocalBackupSourceIsDisable.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TVstLocalBackupSourceIsDisable.Update;
begin
  inherited;

    // ������
  if not FindSourceNode then
    Exit;

    // �޸�
  SourceData.IsDisable := IsDisable;

    // ˢ�½ڵ�
  RefreshNode;

    // ˢ����ʾ��
  ResetStatusColVisible;
end;

{ TVstSelectPathInfo }

constructor TVstSelectPathInfo.Create(_RootPath, _SelectPath: string);
begin
  RootPath := _RootPath;
  SelectPath := _SelectPath;
end;

procedure TVstSelectPathInfo.SetIsDeleted(_IsDeleted: Boolean);
begin
  IsDeleted := _IsDeleted;
end;

{ TvstLocalBackupDesDeletedChange }

function TvstLocalBackupDesDeletedChange.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstLocalBackupDesData;
begin
  Result := False;
  if not FindRootNode then
    Exit;

  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstLocalBackupDes.GetNodeData( SelectNode );
    if SelectData.IsDeleted and ( SelectData.FullPath = ChildPath ) then
    begin
      ChildNode := SelectNode;
      ChildData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TvstLocalBackupDesDeletedChange.RefreshChildNode;
begin
  VstLocalBackupDes.RepaintNode( ChildNode );
end;

procedure TvstLocalBackupDesDeletedChange.SetChildPath(_ChildPath: string);
begin
  ChildPath := _ChildPath;
end;

{ TvstLocalBackupDesDeletedAdd }

procedure TvstLocalBackupDesDeletedAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TvstLocalBackupDesDeletedAdd.SetSpaceInfo(
  _CompletedSize: Int64);
begin
  CompltedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesDeletedAdd.Update;
var
  ExplorerPath : string;
begin
  inherited;

  if not FindRootNode or FindChildNode then
    Exit;

  ChildNode := VstLocalBackupDes.AddChild( RootNode );
  ChildData := VstLocalBackupDes.GetNodeData( ChildNode );
  ChildData.FullPath := ChildPath;
  ChildData.PathType := PathType;
  ChildData.FileSize := CompltedSize;
  ChildData.IsDeleted := True;
  ChildData.Status := '';
  ChildData.PathIcon := MyShellTransActionIconUtil.getRecycle;

    // �ļ� ��������Ŀ¼
  if PathType = PathType_File then
    Exit;
  try
    ExplorerPath := VstLocalBackupDesUtil.getRecyledPath( FullPath, ChildPath );
    ForceDirectories( ExplorerPath );
  except
  end;
end;

{ TvstLocalBackupDesDeletedAddSpace }

procedure TvstLocalBackupDesDeletedAddSpace.SetAddSize(_AddSize: Integer);
begin
  AddSize := _AddSize;
end;

procedure TvstLocalBackupDesDeletedAddSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  ChildData.FileSize := ChildData.FileSize + AddSize;

    // ˢ�� �ӽڵ�
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedSetSpace }

procedure TvstLocalBackupDesDeletedSetSpace.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TvstLocalBackupDesDeletedSetSpace.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  ChildData.FileSize := CompletedSize;

    // ˢ�� �ӽڵ�
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedRemove }

procedure TvstLocalBackupDesDeletedRemove.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  VstLocalBackupDes.DeleteNode( ChildNode );
end;

{ TvstLocalBackupDesChildSetStatus }

procedure TvstLocalBackupDesChildSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TvstLocalBackupDesChildSetStatus.Update;
begin
  inherited;

    // ������
  if not FindChildNode then
    Exit;

  ChildData.Status := Status;

    // ˢ��
  RefreshChildNode;
end;

{ TvstLocalBackupDesDeletedSetStatus }

procedure TvstLocalBackupDesDeletedSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TvstLocalBackupDesDeletedSetStatus.Update;
begin
  inherited;

    // ������
  if not FindChildNode then
    Exit;

  ChildData.Status := Status;

    // ˢ��
  RefreshChildNode;
end;

{ TLVLocalBackupSourceRefreshNextSync }

procedure TLVLocalBackupSourceRefreshNextSync.Update;
begin
  inherited;
  VstLocalBackupSource.Refresh;
end;

end.
