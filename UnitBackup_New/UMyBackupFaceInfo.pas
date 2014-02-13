unit UMyBackupFaceInfo;

interface

uses UChangeInfo, VirtualTrees, UMyUtil, DateUtils, ComCtrls;

type

{$Region ' ���ݽṹ ' }

  TVstBackupData = record
  public
    ItemID : WideString;
    IsFile : Boolean;
  public   // ����״̬
    IsExist, IsWrite, IsLackSpace : Boolean;
  public  // ��ѡ״̬
    IsDisable : Boolean;
  public  // �Զ�ͬ��
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LastSyncTime, NextSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
    Percentage : Integer;
    Speed : Int64; // �����ٶ�
  public
    ShowName, NodeType, NodeStatus : WideString;
    MainIcon, StatusIcon : Integer;
  end;
  PVstBackupData = ^TVstBackupData;

{$EndRegion}

{$Region ' ������Ϣ �����޸� ' }

  {$Region ' Ŀ��·�� ��ɾ ' }

  TDesItemChangeFace = class( TFaceChangeInfo )
  public
    VstBackup : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // �޸� Ŀ��·��
  TDesItemWriteFace = class( TDesItemChangeFace )
  public
    DesPath : string;
  protected
    DesItemNode : PVirtualNode;
    DesItemData : PVstBackupData;
  protected
    FirstNetworkDesNode : PVirtualNode;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
    procedure RefreshDesNode;
  end;

    // ��� ����Ŀ��
  TDesItemAddLocalFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

    // ��� ����Ŀ��
  TDesItemAddNetworkFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

    // ɾ��
  TDesItemRemoveFace = class( TDesItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Ŀ��·�� ״̬ ' }

    // �޸� ·���Ƿ����
  TDesItemSetIsExistFace = class( TDesItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // �޸� ·���Ƿ��д
  TDesItemSetIsWriteFace = class( TDesItemWriteFace )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
  protected
    procedure Update;override;
  end;

    // �޸� Ŀ��·���Ƿ�ȱ�ٱ��ݿռ�
  TDesItemSetIsLackSpaceFace = class( TDesItemWriteFace )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
  protected
    procedure Update;override;
  end;

  {$EndRegion}


  {$Region ' Դ·�� ��ɾ ' }

    // �޸� Դ·��
  TBackupItemWriteFace = class( TDesItemWriteFace )
  protected
    BackupPath : string;
  protected
    BackupItemNode : PVirtualNode;
    BackupItemData : PVstBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindBackupItemNode : Boolean;
    procedure RefreshBackupNode;
  protected
    procedure RefreshNextSyncTime;
    procedure RefreshPercentage;
  end;

    // ��� Դ·��
  TBackupItemAddFace = class( TBackupItemWriteFace )
  public
    IsFile : Boolean;
  public  // ��ѡ״̬
    IsDisable : Boolean;
  public  // �Զ�ͬ��
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public  // �ռ���Ϣ
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // �ռ���Ϣ
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
  protected
    procedure Update;override;
  end;

    // ɾ�� Դ·��
  TBackupItemRemoveFace = class( TBackupItemWriteFace )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Դ·�� ״̬ ' }

    // ���� ��ͣ
  TBackupItemSetIsDisableFace = class( TBackupItemWriteFace )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
  protected
    procedure Update;override;
  end;

    // �޸� �Ƿ����
  TBackupItemSetIsExistFace = class( TBackupItemWriteFace )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
  protected
    procedure Update;override;
  end;

    // �޸�
  TBackupItemSetStatusFace = class( TBackupItemWriteFace )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
  protected
    procedure Update;override;
  end;

      // �޸�
  TBackupItemSetSpeedFace = class( TBackupItemWriteFace )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Դ·�� �Զ�ͬ�� ' }

    // ���� �Զ�ͬ��
  TBackupItemSetAutoSyncFace = class( TBackupItemWriteFace )
  public
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncTime( _SyncTimeType, _SyncTimeValue : Integer );
  protected
    procedure Update;override;
  end;

    // �޸�
  TBackupItemSetLastSyncTimeFace = class( TBackupItemWriteFace )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
  protected
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' Դ·�� �ռ���Ϣ ' }

   // ���� �ռ���Ϣ
  TBackupItemSetSpaceInfoFace = class( TBackupItemWriteFace )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // ��� ����ɿռ���Ϣ
  TBackupItemSetAddCompletedSpaceFace = class( TBackupItemWriteFace )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ѡ�񴰿� �����޸� ' }

  {$Region ' ����Ŀ��·�� ' }

  TLocalDesData = class
  public
    DesPath : string;
  public
    constructor Create( _DesPath : string );
  end;

    // ����
  TFrmLocalDesChange = class( TFaceChangeInfo )
  public
    LvDes : TListView;
  protected
    procedure Update;override;
  end;

    // �޸�
  TFrmLocalDesWrite = class( TFrmLocalDesChange )
  public
    DesPath : string;
  protected
    DesIndex : Integer;
    DesItem : TListItem;
    DesData : TLocalDesData;
  public
    constructor Create( _DesPath : string );
  protected
    function FindDesItemNode : Boolean;
  end;

    // ���
  TFrmLocalDesAdd = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

    // ɾ��
  TFrmLocalDesRemove = class( TFrmLocalDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' ����Ŀ��·�� ' }

  TNetworkDesData = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ����
  TFrmNetworkDesChange = class( TFaceChangeInfo )
  public
    LvNetworkDes : TListView;
  protected
    procedure Update;override;
  end;

    // �޸�
  TFrmNetworkDesWrite = class( TFrmNetworkDesChange )
  public
    PcID : string;
  protected
    NetworkDesIndex : Integer;
    NetworkDesItem : TListItem;
    NetworkDesData : TNetworkDesData;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetworkDesItemNode : Boolean;
  end;

    // ���
  TFrmNetworkDesAdd = class( TFrmNetworkDesWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
  protected
    procedure Update;override;
  end;

    // ɾ��
  TFrmNetworkDesRemove = class( TFrmNetworkDesWrite )
  protected
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ������ ' }

  VstBackupUtil = class
  public             // ״̬�ı�
    class function getLocalDesStatus( Node : PVirtualNode ): string;
    class function getNetworkDesStatus( Node : PVirtualNode ): string;
    class function getBackupStatus( Node : PVirtualNode ): string;
  public             // ״̬ͼ��
    class function getDesStatusIcon( Node : PVirtualNode ): Integer;
    class function getBackupStatusIcon( Node : PVirtualNode ): Integer;
  end;

{$EndRegion}

const
  ItemName_BackupRoot = ' or Shared Folders';
  BackupIcon_Folder = 5;
  BackupIcon_PcOffline = 0;
  BackupIcon_PcOnline = 1;

  BackupNodeStatus_WaitingBackup = 'Waiting';
  BackupNodeStatus_Backuping = 'Backuping';
  BackupNodeStatus_Analyizing = 'Analyzing %s Files';
  BackupNodeStatus_Empty = '';

  BackupStatusShow_NotExist = 'Not Exist';
  BackupStatusShow_NotWrite = 'Cannot Write';
  BackupStatusShow_NotSpace = 'Space Insufficient';
  BackupStatusShow_Disable = 'Disable';
  BackupStatusShow_PcOffline = 'Offline';

  BackupStatusShow_Incompleted = 'Incompleted';
  BackupStatusShow_Completed = 'Completed';

const
  FrmDesIcon_PcOffline = 0;
  FrmDesIcon_PcOnline = 1;


const
  BackupNodeType_LocalDes = 'LocalDes';
  BackupNodeType_LocalBackup = 'Backup';

  BackupNodeType_NetworkDes = 'NetworkDes';
  BackupNodeType_NetworkBackup = 'NetworkBackup';

implementation

uses UMainForm, UIconUtil, UFrmSelectBackupItem;

{ TVstBackupDesItemWrite }

constructor TDesItemWriteFace.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

function TDesItemWriteFace.FindDesItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  FirstNetworkDesNode := nil;
  SelectNode := vstBackup.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = DesPath then
    begin
      Result := True;
      DesItemNode := SelectNode;
      DesItemData := SelectData;
      Break;
    end;
    if ( SelectData.NodeType = BackupNodeType_NetworkDes ) and
       not Assigned( FirstNetworkDesNode )
    then
      FirstNetworkDesNode := SelectNode;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TDesItemWriteFace.RefreshDesNode;
begin
  VstBackup.RepaintNode( DesItemNode );
end;

{ TVstBackupDesItemRemove }

procedure TDesItemRemoveFace.Update;
begin
  inherited;

    // ������
  if not FindDesItemNode then
    Exit;

  VstBackup.DeleteNode( DesItemNode );
end;

{ TVstBackupItemWrite }

function TBackupItemWriteFace.FindBackupItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstBackupData;
begin
  Result := False;
  DesItemNode := nil;
  if not FindDesItemNode then
    Exit;
  SelectNode := DesItemNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstBackup.GetNodeData( SelectNode );
    if SelectData.ItemID = BackupPath then
    begin
      Result := True;
      BackupItemNode := SelectNode;
      BackupItemData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TBackupItemWriteFace.RefreshBackupNode;
begin
  VstBackup.RepaintNode( BackupItemNode );
end;

procedure TBackupItemWriteFace.RefreshNextSyncTime;
var
  SyncMins : Integer;
begin
    // �����´� ͬ��ʱ��
  SyncMins := TimeTypeUtil.getMins( BackupItemData.SyncTimeType, BackupItemData.SyncTimeValue );
  BackupItemData.NextSyncTime := IncMinute( BackupItemData.LastSyncTime, SyncMins );
end;

procedure TBackupItemWriteFace.RefreshPercentage;
begin
  BackupItemData.Percentage := MyPercentage.getPercent( BackupItemData.CompletedSize, BackupItemData.ItemSize );
end;

procedure TBackupItemWriteFace.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TVstBackupItemAdd }

procedure TBackupItemAddFace.SetAutoSyncInfo(_IsAutoSync: Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupItemAddFace.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemAddFace.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TBackupItemAddFace.SetSpaceInfo(_FileCount: Integer; _ItemSize,
  _CompletedSize: Int64);
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemAddFace.SetSyncTimeInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemAddFace.Update;
begin
  inherited;

    // �Ѵ���
  if FindBackupItemNode or ( DesItemNode = nil ) then
    Exit;

    // ���
  BackupItemNode := VstBackup.AddChild( DesItemNode );
  BackupItemData := VstBackup.GetNodeData( BackupItemNode );
  BackupItemData.ItemID := BackupPath;
  BackupItemData.ShowName := BackupPath;
  BackupItemData.IsFile := IsFile;
  BackupItemData.IsDisable := IsDisable;
  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;
  BackupItemData.LastSyncTime := LasSyncTime;
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;
  BackupItemData.IsExist := True;
  BackupItemData.NodeStatus := '';
  BackupItemData.MainIcon := MyIcon.getIconByFilePath( BackupPath );
  if DesItemData.NodeType = BackupNodeType_LocalDes then
    BackupItemData.NodeType := BackupNodeType_LocalBackup
  else
    BackupItemData.NodeType := BackupNodeType_NetworkBackup;

  VstBackup.Expanded[ DesItemNode ] := True;

    // ˢ����Ϣ
  RefreshNextSyncTime;
  RefreshPercentage;
end;

{ TVstBackupItemRemove }

procedure TBackupItemRemoveFace.Update;
begin
  inherited;
  if not FindBackupItemNode then
    Exit;
  VstBackup.DeleteNode( BackupItemNode );
end;

{ TVstBackupItemSetIsDisable }

procedure TBackupItemSetIsDisableFace.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemSetIsDisableFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsDisable := IsDisable;

    // ˢ�½ڵ�
  RefreshBackupNode;
end;

{ TVstBackupItemSetAutoSync }

procedure TBackupItemSetAutoSyncFace.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupItemSetAutoSyncFace.SetSyncTime(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemSetAutoSyncFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.IsAutoSync := IsAutoSync;
  BackupItemData.SyncTimeType := SyncTimeType;
  BackupItemData.SyncTimeValue := SyncTimeValue;

    // ˢ���´�ͬ��
  RefreshNextSyncTime;

    // ˢ�½ڵ�
  RefreshBackupNode;
end;

{ TBackupItemSetSpaceInfoFace }

procedure TBackupItemSetSpaceInfoFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.FileCount := FileCount;
  BackupItemData.ItemSize := ItemSize;
  BackupItemData.CompletedSize := CompletedSize;

    // ˢ�½ڵ�
  RefreshPercentage;
  RefreshBackupNode;
end;

{ TBackupItemSetAddCompletedSpaceFace }

procedure TBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemSetAddCompletedSpaceFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.CompletedSize := BackupItemData.CompletedSize + AddCompletedSpace;

    // ˢ�½ڵ�
  RefreshPercentage;
  RefreshBackupNode;
end;

{ TNetworkDesItemChangeFace }

procedure TFrmNetworkDesChange.Update;
begin
  LvNetworkDes := frmSelectBackupItem.lvNetworkDes;
end;

{ TNetworkDesItemWriteFace }

constructor TFrmNetworkDesWrite.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TFrmNetworkDesWrite.FindNetworkDesItemNode : Boolean;
var
  SelectItem : TListItem;
  SelectData : TNetworkDesData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvNetworkDes.Items.Count - 1 do
  begin
    SelectData := LvNetworkDes.Items[i].Data;
    if ( SelectData.PcID = PcID ) then
    begin
      Result := True;
      NetworkDesIndex := i;
      NetworkDesItem := SelectItem;
      NetworkDesData := SelectData;
      Break;
    end;
  end;
end;



{ TNetworkDesData }

constructor TNetworkDesData.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TFrmNetworkDesAdd }

procedure TFrmNetworkDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TFrmNetworkDesAdd.Update;
begin
  inherited;

  if FindNetworkDesItemNode then
    Exit;

  NetworkDesItem := LvNetworkDes.Items.Add;
  NetworkDesData := TNetworkDesData.Create( PcID );
  with NetworkDesItem do
  begin
    Caption := PcName;
    SubItems.Add('');
    Data := NetworkDesData;
    ImageIndex := FrmDesIcon_PcOffline;
  end;
end;

{ TFrmNetworkDesRemove }

procedure TFrmNetworkDesRemove.Update;
begin
  inherited;

  if not FindNetworkDesItemNode then
    Exit;

  LvNetworkDes.Items.Delete( NetworkDesIndex );
end;

{ TDesItemChangeFace }

procedure TFrmLocalDesChange.Update;
begin
//  LvDes := frmSelectBackupItem;
end;

{ TDesItemChangeFace }

procedure TDesItemChangeFace.Update;
begin
  VstBackup := FrmMainForm.VstBackup;
end;

{ TDesItemWriteFace }

constructor TFrmLocalDesWrite.Create( _DesPath : string );
begin
  DesPath := _DesPath;
end;


function TFrmLocalDesWrite.FindDesItemNode : Boolean;
var
  SelectItem : TListItem;
  SelectData : TLocalDesData;
  i: Integer;
begin
  Result := False;
  for i := 0 to LvDes.Items.Count - 1 do
  begin
    SelectData := LvDes.Items[i].Data;
    if ( SelectData.DesPath = DesPath ) then
    begin
      Result := True;
      DesIndex := i;
      DesItem := SelectItem;
      DesData := SelectData;
      Break;
    end;
  end;
end;



{ TDesData }

constructor TLocalDesData.Create(_DesPath: string);
begin
  DesPath := _DesPath;
end;

{ TFrmDesAdd }

procedure TFrmLocalDesAdd.Update;
begin
  inherited;

  if FindDesItemNode then
    Exit;

  DesItem := LvDes.Items.Add;
  DesData := TLocalDesData.Create( DesPath );
  with DesItem do
  begin
    Caption := DesPath;
    SubItems.Add('');
    Data := DesData;
    ImageIndex := MyIcon.getIconByFilePath( DesPath );
  end;
end;

{ TFrmDesRemove }

procedure TFrmLocalDesRemove.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;

  LvDes.Items.Delete( DesIndex );
end;

{ TDesItemSetIsExistFace }

procedure TDesItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TDesItemSetIsExistFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsExist := IsExist;

    // ˢ�½ڵ�
  RefreshDesNode;
end;

{ TDesItemSetIsWriteFace }

procedure TDesItemSetIsWriteFace.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TDesItemSetIsWriteFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsWrite := IsWrite;

    // ˢ�½ڵ�
  RefreshDesNode;
end;

{ TDesItemSetIsLackSpaceFace }

procedure TDesItemSetIsLackSpaceFace.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TDesItemSetIsLackSpaceFace.Update;
begin
  inherited;

  if not FindDesItemNode then
    Exit;
  DesItemData.IsLackSpace := IsLackSpace;

    // ˢ�½ڵ�
  RefreshDesNode;
end;

{ TBackupItemSetIsExistFace }

procedure TBackupItemSetIsExistFace.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TBackupItemSetIsExistFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.IsExist := IsExist;

    // ˢ�½ڵ�
  RefreshBackupNode;
end;

{ TBackupItemSetBackupItemStatusFace }

procedure TBackupItemSetStatusFace.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TBackupItemSetStatusFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.NodeStatus := BackupItemStatus;

    // ˢ�½ڵ�
  RefreshBackupNode;
end;



{ VstBackupUtil }

class function VstBackupUtil.getBackupStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if NodeData.IsDisable then
    Result := BackupStatusShow_Disable
  else
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
  begin
    if NodeData.Speed <= 0 then
      Result := BackupNodeStatus_Backuping
    else
      Result := MySpeed.getSpeedStr( NodeData.Speed )
  end
  else
  if NodeData.NodeStatus <> '' then
    Result := NodeData.NodeStatus
  else
  if NodeData.CompletedSize >= NodeData.ItemSize then
    Result := BackupStatusShow_Completed
  else
    Result := BackupStatusShow_InCompleted;
end;

class function VstBackupUtil.getBackupStatusIcon(
  Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := MyShellBackupStatusIconUtil.getFileIncompleted
  else
  if NodeData.NodeStatus = BackupNodeStatus_Backuping then
    Result := MyShellTransActionIconUtil.getSync
  else
  if NodeData.NodeStatus <> '' then
    Result := MyShellBackupStatusIconUtil.getFilePartcompleted
  else
  if NodeData.CompletedSize >= NodeData.ItemSize then
    Result := MyShellBackupStatusIconUtil.getFilecompleted
  else
    Result := MyShellBackupStatusIconUtil.getFileIncompleted;
end;

class function VstBackupUtil.getLocalDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := BackupStatusShow_NotExist
  else
  if not NodeData.IsWrite then
    Result := BackupStatusShow_NotWrite
  else
  if NodeData.IsLackSpace then
    Result := BackupStatusShow_NotSpace
  else
    Result := '';
end;

class function VstBackupUtil.getDesStatusIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist or
     not NodeData.IsWrite or
     NodeData.IsLackSpace
  then
    Result := MyShellBackupStatusIconUtil.getFileIncompleted
  else
    Result := -1;
end;


class function VstBackupUtil.getNetworkDesStatus(Node: PVirtualNode): string;
var
  NodeData : PVstBackupData;
begin
  NodeData := frmMainForm.VstBackup.GetNodeData( Node );
  if not NodeData.IsExist then
    Result := BackupStatusShow_PcOffline
  else
  if NodeData.IsLackSpace then
    Result := BackupStatusShow_NotSpace
  else
    Result := '';
end;

{ TBackupItemSetLastSyncTimeFace }

procedure TBackupItemSetLastSyncTimeFace.SetLastSyncTime( _LastSyncTime : TDateTime );
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;

  BackupItemData.LastSyncTime := LastSyncTime;

  RefreshNextSyncTime;
  RefreshBackupNode;
end;


{ TBackupItemSetSpeedFace }

procedure TBackupItemSetSpeedFace.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TBackupItemSetSpeedFace.Update;
begin
  inherited;

  if not FindBackupItemNode then
    Exit;
  BackupItemData.Speed := Speed;

  RefreshDesNode;
end;

{ TDesItemAddLocalFace }

procedure TDesItemAddLocalFace.Update;
begin
  inherited;

    // �Ѵ���
  if FindDesItemNode then
    Exit;

  if Assigned( FirstNetworkDesNode ) then
    DesItemNode := VstBackup.InsertNode( FirstNetworkDesNode, amInsertBefore )
  else
    DesItemNode := VstBackup.AddChild( VstBackup.RootNode );
  DesItemNode.NodeHeight := 28;

  DesItemData := VstBackup.GetNodeData( DesItemNode );
  DesItemData.ItemID := DesPath;
  DesItemData.IsExist := True;
  DesItemData.IsWrite := True;
  DesItemData.IsLackSpace := False;
  DesItemData.NodeStatus := '';
  DesItemData.ShowName := DesPath;
  DesItemData.MainIcon := BackupIcon_Folder;
  DesItemData.NodeType := BackupNodeType_LocalDes;
end;

{ TDesItemAddNetworkFace }

procedure TDesItemAddNetworkFace.Update;
begin
  inherited;

    // �Ѵ���
  if FindDesItemNode then
    Exit;

  DesItemNode := VstBackup.AddChild( VstBackup.RootNode );
  DesItemNode.NodeHeight := 28;

  DesItemData := VstBackup.GetNodeData( DesItemNode );
  DesItemData.ItemID := DesPath;
  DesItemData.IsExist := True;
  DesItemData.IsWrite := True;
  DesItemData.IsLackSpace := False;
  DesItemData.NodeStatus := '';
  DesItemData.ShowName := DesPath;
  DesItemData.MainIcon := BackupIcon_Folder;
  DesItemData.NodeType := BackupNodeType_NetworkDes;
end;

end.
