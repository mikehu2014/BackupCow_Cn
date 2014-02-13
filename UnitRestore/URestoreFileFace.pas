unit URestoreFileFace;

interface

uses ComCtrls, UChangeInfo, SysUtils, UMyUtil, VirtualTrees, Math, Classes, UIconUtil,
     Generics.Collections, UModelUtil;

type

  // �ָ�����

{$Region ' Restore Path Detail '}

    // ÿһ�� ·�� Pc ӵ������Ϣ
  TPathOwnerDetailInfo = class
  public
    PcID, PcName : string;
    OwnerSpace : Int64;
  public
    IsOnline : Boolean;
    LastOnlineTime : TDateTime;
  public
    constructor Create( _PcID : string; _OwnerSpace : Int64 );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure SetLastOnlineTime( _LastOnlineTime : TDateTime );
    procedure SetPcName( _PcName : string );
  end;
  TPathOwnerDetailPair = TPair< string , TPathOwnerDetailInfo >;
  TPathOwnerDetailHash = class(TStringDictionary< TPathOwnerDetailInfo >);

    // ListView ����
  TLvBackupPathDetailData = class
  public
    FullPath : string;
    FolderSpace : Int64;
    FileCount, StatusInt : Integer;
    PathOwnerDetailHash : TPathOwnerDetailHash;
  public
    constructor Create( _FullPath : string );
    procedure SetSpaceInfo( _FolderSpace : Int64; _FileCount : Integer );
    procedure SetPathOwnerDetailHash( _PathOwnerDetailHash : TPathOwnerDetailHash );
    destructor Destroy; override;
  end;

    // ��� �ָ� ��Ϣ ·��
  TRestorePathDetaiAddInfo = class( TChangeInfo )
  public
    FullPath, PathType : string;
    FolderSize : Int64;
    FileCount : Integer;
    CopyCount : Integer;
  public
    PathOwnerDetailHash : TPathOwnerDetailHash;
  private
    MaxPercentage, MinPercentage : Integer;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetFolderSize( _FolderSize : Int64; _FileCount : Integer );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure FindRestorePercentage;
  end;

{$EndRegion}

{$Region ' Restore VirtualTree RestoreFile ' }

  PVstRestoreFileData = ^TVstRestoreFileData;
  TVstRestoreFileData = record
  public
    FileName : WideString;
    RestorePercentage : Integer;
    FileSize : Int64;
    FileTime : TDateTime;
    LocationName : WideString;
  public
    LocationID, FilePath : WideString;
    PathType : WideString;
    TotalSpace : Int64;
  end;

    // Ѱ��/���� �ӽڵ�
  TCreateVstRestoreNode = class
  public
    ParentNode : PVirtualNode;
    FileName : string;
  private
    ChildNode : PVirtualNode;
  public
    constructor Create( _FileName : string );
    procedure SetParentNode( _ParentNode : PVirtualNode );
    function get : PVirtualNode;
  private
    function FindChildNode : Boolean;
  end;

    // �ݹ鴴�� �ļ��ڵ�
  TFindVstRestoreFileNode = class
  public
    FilePath : string;
  private
    RootNode : PVirtualNode;
    RemainPath : string;
  public
    constructor Create( _FilePath : string );
    function get : PVirtualNode;
  private
    function FindRootNode : Boolean;
    function FindUnvailableItem : Boolean;
    function CreateChildNode( ParentNode : PVirtualNode; ChildName : string ): PVirtualNode;
  end;

    // ����ļ��ڵ�
  TVstRestoreFileAddInfo = class( TChangeInfo )
  public
    SearchNum : Integer;
    LocationID, FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
    LocationName : string;
  private
    FileNode : PVirtualNode;
  public
    constructor Create( _Location, _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetLocationName( _LocationName : string );
    procedure SetSearchNum( _SearchNum : Integer );
    procedure Update;override;
  private
    function FindFileNode : Boolean;
    procedure UpgradeParentSize;
  end;

    // ���� �ָ��ļ� ���
  TVstRestoreFileSearchCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Restore Listview UnvailablePath ' }

  TLvUnvailabePathData = class
  public
    FullPath, PathType : string;
    FolderSpace : Int64;
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetSpace( _FolderSpace : Int64 );
  end;

{$EndRegion}

  // ������

{$Region ' MainForm ListView Restore Download ' }

    // ���ݽṹ
  PVstRestoreDownData = ^TVstRestoreDownData;
  TVstRestoreDownData = record
  public
    FullPath, SaveAsPath : WideString;
    FileSize, CompletedSize : Int64;
    RestorePcID, RestorePcName : WideString;
    LocationID, LocationName : WideString;
    PathType, Status : WideString;
    ImageIndex : Integer;
  public
    LocationIsOnline : Boolean;
    IsScaning : Boolean;
  end;

    // ������
  VstRestoreDownUtil = class
  public
    class function getStatus( Node : PVirtualNode ) : string;
    class function getStatusIcon( Node : PVirtualNode ): Integer;
  public
    class function getHintStr( Node : PVirtualNode ): string;
  end;

    // ����
  TVstRestoreDownChange = class( TChangeInfo )
  public
    vstRestoreDown : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // Location ����
  TVstRestoreDownLocationOnline = class( TVstRestoreDownChange )
  private
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure Update;override;
  end;

  {$Region ' �޸� ��Ŀ¼ ' }

    // �޸�
  TVstRestoreDownWrite = class( TVstRestoreDownChange )
  public
    FullPath, RestorePcID : string;
  protected
    RestoreItemNode : PVirtualNode;
    RestoreItemData : PVstRestoreDownData;
  public
    constructor Create( _FullPath, _RestorePcID : string );
  protected
    function FindRestoreItemNode : Boolean;
    procedure RefreshRestoreItem;
  end;

    // ��� ��Ŀ¼
  TVstRestoreDownAddRoot = class( TVstRestoreDownWrite )
  public
    FileSize, CompletedSize : Int64;
    PathType, SaveAsPath : string;
    RestorePcName : string;
  public
    IsScaning : Boolean;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetPathInfo( _PathType, _SaveAsPath : string );
    procedure SetRestorePc( _RestorePcName : string );
    procedure SetIsScaning( _IsScaning : Boolean );
    procedure Update;override;
  end;

    // ��� ���ܿռ� ��Ϣ
  TVstRestoreDownAddRootSpace = class( TVstRestoreDownWrite )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // ��� ������ɿռ� ��Ϣ
  TVstRestoreDownAddRootCompletedSpace = class( TVstRestoreDownWrite )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

      // �Ƴ� ��Ŀ¼
  TVstRestoreDownRemoveRoot = class( TVstRestoreDownWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ��Ŀ¼ ' }

    // �޸� ��Ŀ¼
  TVstRestoreDownChildChange = class( TVstRestoreDownChange )
  public
    FilePath, RestorePcID : string;
  protected
    RootNode, ChildNode : PVirtualNode;
    RootData, ChildData : PVstRestoreDownData;
  public
    constructor Create( _FilePath, _RestorePcID : string );
  protected
    function FindRootNode : Boolean;
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
    function getIsFileNode : Boolean;
  end;

    // ��� ��Ŀ¼
  TVstRestoreDownAddChild = class( TVstRestoreDownChildChange )
  public
    FileSize, CompletedSize : Int64;
    LocatinID, LocationName : string;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetLocationPc( _LocatinID, _LocationName : string );
    procedure Update;override;
  end;

    // �޸� ��Ŀ¼ ״̬
  TVstRestoreDownChildStatus = class( TVstRestoreDownChildChange )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // �޸� ��Ŀ¼ ����ɿռ�
  TVstRestoreDownChildAddCompletedSpace = class( TVstRestoreDownChildChange )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

    // �޸� �ָ�Ŀ�� ����
  TVstRestoreDownChildOffline = class( TVstRestoreDownChildChange )
  private
    procedure Update;override;
  end;

    // �Ƴ� ��Ŀ¼
  TVstRestoreDownRemoveChild = class( TVstRestoreDownChildChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� �ָ��ļ�����״̬ ' }

    // ������һ�����
  TVstRestoreDownAddFileResult = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // �������
  TVstRestoreDownSearchCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Restore Computer �б� ' }

    // �ָ��ļ�����Դ
  TRestoreLocationInfo = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  end;
  TRestoreLocationList = class(TObjectList< TRestoreLocationInfo >);

    // �ָ� Pc ����Ϣ
  TRestorePcInfo = class
  public
    RestorePcID : string;
    RestoreLocationList : TRestoreLocationList;
  public
    constructor Create( _RestorePcID : string );
    destructor Destroy; override;
  public
    function getHasOnline : Boolean;
  end;
  TRestorePcList = class( TObjectList<TRestorePcInfo> )
  public
    function getRestorePcInfo( RestorePcID : string ): TRestorePcInfo;
  end;

    // ���ݽṹ
  TVstRestorePcData = record
  public
    RestorePcID, RestorePcName : WideString;
    RestoreItemCount : Integer;
  public
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    IsShowUpload, IsShowDownload : Boolean;
    UploadCount, DownloadCount : Integer;
  end;
  PVstRestorePcData = ^TVstRestorePcData;

    // ����
  TVstRestorePcChange = class( TChangeInfo )
  public
    vstRestorePc : TVirtualStringTree;
    RestorePcList : TRestorePcList;
  public
    procedure Update;override;
  end;

    // �޸�
  TVstRestorePcWrite = class( TVstRestorePcChange )
  public
    RestorePcID : string;
  protected
    PcNode : PVirtualNode;
    NodeData : PVstRestorePcData;
  protected
    RestorePcInfo : TRestorePcInfo;
  public
    constructor Create( _RestorePcID : string );
  protected
    function FindPcNode : Boolean;
    procedure RefreshPcVisible;
  end;

    // ���
  TVstRestorePcAdd = class( TVstRestorePcWrite )
  public
    RestorePcName : string;
  public
    procedure SetRestorePcName( _RestorePcName : string );
    procedure Update;override;
  private
    procedure AddRestorePcInfo;
  end;

    // ���� ���� Item ��
  TVstRestorePcSetItemCount = class( TVstRestorePcWrite )
  public
    RestoreItemCount : Integer;
  public
    procedure SetRestoreItemCount( _RestoreItemCount : Integer );
    procedure Update;override;
  end;

    // ���� �ļ��ɼ���
  TVstRestorePcSetInvisible = class( TVstRestorePcWrite )
  public
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    procedure SetInvisibleInfo( _IsFileInvisible : Boolean; _IvPasswordMD5 : string );
    procedure Update;override;
  end;

    // ˢ�� �ɼ���
  TVstRestorePcRefreshVisible = class( TVstRestorePcWrite )
  public
    procedure Update;override;
  end;

  {$Region ' Restore Location �޸� ' }

    // ����λ�� �޸�
  TVstRestorePcChangeLocation = class( TChangeInfo )
  public
    RestorePcList : TRestorePcList;
  public
    procedure Update;override;
  protected
    procedure RefreshVisible( RestorePcID : string );
  end;

    // ��ʼ�� ���� LocationList
  TVstRestorePcWriteLocation = class( TVstRestorePcChangeLocation )
  public
    RestorePcID : string;
    RestorePcInfo : TRestorePcInfo;
  public
    constructor Create( _RestorePcID : string );
  protected
    function FindRestorePcInfo : Boolean;
  end;

    // ˢ��
  TVstRestorePcRefresh = class( TVstRestorePcWriteLocation )
  public
    procedure Update;override;
  end;

    // ���
  TVstRestorePcClearLocation = class( TVstRestorePcWriteLocation )
  public
    procedure Update;override;
  end;

    // ���
  TVstRestorePcAddLocation = class( TVstRestorePcWriteLocation )
  private
    LocationPcID : string;
    IsOnline : Boolean;
  public
    procedure SetLocationInfo( _LocationPcID : string; _IsOnline : Boolean );
    procedure Update;override;
  end;

    // ����λ�� ��/����
  TVstRestorePcLocationIsOnline = class( TVstRestorePcChangeLocation )
  public
    LocationPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _LocationPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // ����λ�� Server ����
  TVstRestorePcLocationServerOffline = class( TVstRestorePcChangeLocation )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

  TMyRestoreFileFace = class( TMyChildFaceChange )
  public
    RestorePcList : TRestorePcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
//  Label_TotalPercent = 'Data Availability:   %s Available   %s Unavailable';

  RestoreStatus_Completed = 'Completed';
  RestoreStatus_InCompleted = 'Restoring';
  RestoreStatus_Waiting = 'Waiting';
  RestoreStatus_Loading = 'Loading';
  RestoreStatus_Offline = 'Offline';
  RestoreStatus_Searching = 'Searching';

  RestoreHint_RestorePath = 'Restore Path: ';
  RestoreHint_RestorePc = 'Restore Computer: ';
  RestoreHint_SavePath = 'Save Path: ';
  RestoreHint_RestoreFrom = 'Retore From: ';
  RestoreHint_RestoreStatus = 'Status: ';
var
  MyRestoreFileFace : TMyRestoreFileFace;
  RestoreFile_RevSpace : Int64 = 0;
  RestoreFile_TotalSpace : Int64 = 0;
  RestoreFile_LocalPcName : string;
  RestoreFile_SearchCount : Integer = 0;

implementation

uses UFormRestorePath, UMyBackupInfo, UFormRestoreDetail, UMainForm, UBackupInfoFace;


{ TVstRestoreFileAddInfo }

constructor TVstRestoreFileAddInfo.Create(_Location, _FilePath: string);
begin
  LocationID := _Location;
  FilePath := _FilePath;
end;

function TVstRestoreFileAddInfo.FindFileNode: Boolean;
var
  FindVstRestoreFileNode : TFindVstRestoreFileNode;
begin
  FindVstRestoreFileNode := TFindVstRestoreFileNode.Create( FilePath );
  FileNode := FindVstRestoreFileNode.get;
  FindVstRestoreFileNode.Free;

  Result := FileNode <> nil;
end;

procedure TVstRestoreFileAddInfo.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TVstRestoreFileAddInfo.SetLocationName(_LocationName: string);
begin
  LocationName := _LocationName;
end;

procedure TVstRestoreFileAddInfo.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

procedure TVstRestoreFileAddInfo.Update;
var
  FileData : PVstRestoreFileData;
begin
    // ���ڵ� ������
  if not FindFileNode then
    Exit;

  FileData := frmRestore.vstRestoreFile.GetNodeData( FileNode );

    // �ڵ� �Ѵ���
  if FileData.LocationID <> '' then
    Exit;

    // ���� �ڵ���Ϣ
  FileData.FilePath := FilePath;
  FileData.FileSize := FileSize;
  FileData.FileTime := FileTime;
  FileData.LocationID := LocationID;
  FileData.LocationName := LocationName;
  FileData.PathType := PathType_File;

    // ���� ���ڵ� FileSize
  UpgradeParentSize;

    // ��ʾ �ָ��ļ���
  Inc( RestoreSearch_Files );
  frmRestore.lbFiles.Caption := Format( frmRestore.siLang_frmRestore.GetText( 'SearchCount' ), [RestoreSearch_Files] );
end;

procedure TVstRestoreFileAddInfo.UpgradeParentSize;
var
  vstRestoreFile : TVirtualStringTree;
  ChildNode : PVirtualNode;
  ChildData : PVstRestoreFileData;
  TotalSize, TotalSpace : Int64;
  Percentage, TotalPercentage : Integer;
  ShowTotalPerncentage, AvailableStr, UnavailableStr : string;
begin
  vstRestoreFile := frmRestore.vstRestoreFile;

  ChildNode := FileNode;
  while ChildNode.Parent <> vstRestoreFile.RootNode do
  begin
    ChildNode := ChildNode.Parent;
    ChildData := vstRestoreFile.GetNodeData( ChildNode );
    ChildData.FileSize := ChildData.FileSize + FileSize;
  end;

    // Upgrade Restore Percentage
  ChildData := vstRestoreFile.GetNodeData( ChildNode );
  TotalSize := ChildData.FileSize;
  TotalSpace := ChildData.TotalSpace;
  Percentage := MyPercentage.getPercent( TotalSize, TotalSpace );
  ChildData.RestorePercentage := Percentage;
  vstRestoreFile.RepaintNode( ChildNode );

    // Upgrade Retore Total Percentage
  RestoreFile_RevSpace := RestoreFile_RevSpace + FileSize;
  TotalPercentage := MyPercentage.getPercent( RestoreFile_RevSpace, RestoreFile_TotalSpace );
  AvailableStr := MyPercentage.getPercentageStr( TotalPercentage );
  UnavailableStr := MyPercentage.getPercentageStr( Max( 0, 100 - TotalPercentage ) );
  ShowTotalPerncentage := Format( frmRestore.siLang_frmRestore.GetText( 'TotalPercent' ), [ AvailableStr, UnavailableStr ] );
  frmRestore.plRestoreResult.Caption := ShowTotalPerncentage;
end;

{ TFindVstRestoreFile }

constructor TFindVstRestoreFileNode.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TFindVstRestoreFileNode.CreateChildNode(ParentNode: PVirtualNode;
  ChildName: string): PVirtualNode;
var
  CreateVstRestoreNode : TCreateVstRestoreNode;
begin
  CreateVstRestoreNode := TCreateVstRestoreNode.Create( ChildName );
  CreateVstRestoreNode.SetParentNode( ParentNode );
  Result := CreateVstRestoreNode.get;
  CreateVstRestoreNode.Free;
end;

function TFindVstRestoreFileNode.FindRootNode: Boolean;
var
  vstRestoreFile : TVirtualStringTree;
  ChildNode : PVirtualNode;
  ItemData : PVstRestoreFileData;
  FolderPath : string;
begin
  RootNode := nil;
  Result := False;

  vstRestoreFile := frmRestore.vstRestoreFile;
  ChildNode := vstRestoreFile.RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ItemData := vstRestoreFile.GetNodeData( ChildNode );
    FolderPath := ItemData.FilePath;
    if MyMatchMask.CheckEqualsOrChild( FilePath, FolderPath ) then
    begin
      RootNode := ChildNode;
      RemainPath := MyString.CutStartStr( MyFilePath.getPath( FolderPath ), FilePath );
      Result := True;
      Break;
    end;
    ChildNode := ChildNode.NextSibling;
  end;
end;

function TFindVstRestoreFileNode.FindUnvailableItem: Boolean;
var
  LvUnvailablePath : TListView;
  i : Integer;
  LvUnvailabePathData : TLvUnvailabePathData;
  FullPath, PathType : string;
  FolderSpace : Int64;
  vstRestoreFile : TVirtualStringTree;
  ChildNode : PVirtualNode;
  ChildData : PVstRestoreFileData;
begin
  Result := False;

  vstRestoreFile := frmRestore.vstRestoreFile;
  LvUnvailablePath := frmRestore.lvUavailablePath;
  for i := 0 to LvUnvailablePath.Items.Count - 1 do
  begin
    LvUnvailabePathData := LvUnvailablePath.Items[i].Data;
    FullPath := LvUnvailabePathData.FullPath;
    if MyMatchMask.CheckEqualsOrChild( FilePath, FullPath ) then
    begin
      PathType := LvUnvailabePathData.PathType;
      FolderSpace := LvUnvailabePathData.FolderSpace;

        // ��� Vst ����
      ChildNode := vstRestoreFile.AddChild( vstRestoreFile.RootNode );
      ChildNode.CheckState := csUncheckedNormal;
      ChildNode.CheckType := ctTriStateCheckBox;
      ChildData := vstRestoreFile.GetNodeData( ChildNode );
      ChildData.FileName := FullPath;
      ChildData.FilePath := FullPath;
      ChildData.FileSize := 0;
      ChildData.PathType := PathType;
      ChildData.TotalSpace := FolderSpace;

        // ���ظ��ڵ�
      RootNode := ChildNode;
      RemainPath := MyString.CutStartStr( MyFilePath.getPath( FullPath ), FilePath );

        // ɾ�� Lv Unvailable ����
      LvUnvailablePath.Items.Delete( i );

      Result := True;
      Break;
    end;
  end;
end;

function TFindVstRestoreFileNode.get: PVirtualNode;
var
  FolderName : string;
  ParentNode, ChildNode : PVirtualNode;
begin
    // �Ҳ��� ��Ŀ¼
  if not FindRootNode and not FindUnvailableItem then
  begin
    Result := nil;
    Exit;
  end;

    // ��Ŀ¼ ���ļ�
  if RemainPath = '' then
  begin
    Result := RootNode;
    Exit;
  end;

    // �ݹ鴴�� �ڵ�
  ParentNode := RootNode;
  while RemainPath <> '' do
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      RemainPath := '';
    end;
    ChildNode := CreateChildNode( ParentNode, FolderName );
    ParentNode := ChildNode;
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;
  Result := ChildNode;
end;

{ TFindVstRestoreNode }

constructor TCreateVstRestoreNode.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TCreateVstRestoreNode.FindChildNode: Boolean;
var
  vstRestoreFile : TVirtualStringTree;
  SelectNode : PVirtualNode;
  ItemData : PVstRestoreFileData;
  ChildName : string;
begin
  Result := False;

  vstRestoreFile := frmRestore.vstRestoreFile;
  SelectNode := ParentNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    ItemData := vstRestoreFile.GetNodeData( SelectNode );
    ChildName := ItemData.FileName;
    if ChildName = FileName then
    begin
      ChildNode := SelectNode;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TCreateVstRestoreNode.get: PVirtualNode;
var
  vstRestoreFile : TVirtualStringTree;
  ChildData : PVstRestoreFileData;
begin
  vstRestoreFile := frmRestore.vstRestoreFile;

    // ���� �ڵ�
  if FindChildNode then
    Result := ChildNode
  else
  begin     // �����ڵ�
    Result := vstRestoreFile.AddChild( ParentNode );
    Result.CheckState := csUncheckedNormal;
    Result.CheckType:=ctTriStateCheckBox;
    ChildData := vstRestoreFile.GetNodeData( Result );
    ChildData.FileName := FileName;
    ChildData.PathType := PathType_Folder;
    ChildData.FileSize := 0;
    ChildData.LocationID := '';
  end;

end;

procedure TCreateVstRestoreNode.SetParentNode(_ParentNode: PVirtualNode);
begin
  ParentNode := _ParentNode;
end;

{ TLvUnvailabePathData }

constructor TLvUnvailabePathData.Create(_FullPath, _PathType : string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TLvUnvailabePathData.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

{ TPathOwnerDetailInfo }

constructor TPathOwnerDetailInfo.Create(_PcID: string; _OwnerSpace: Int64);
begin
  PcID := _PcID;
  OwnerSpace := _OwnerSpace;
end;

procedure TPathOwnerDetailInfo.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TPathOwnerDetailInfo.SetLastOnlineTime(_LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

procedure TPathOwnerDetailInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

{ TRestorePathShowDetailInfo }

constructor TRestorePathDetaiAddInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
  PathOwnerDetailHash := TPathOwnerDetailHash.Create;
end;

destructor TRestorePathDetaiAddInfo.Destroy;
begin
  PathOwnerDetailHash.Free;
  inherited;
end;

procedure TRestorePathDetaiAddInfo.FindRestorePercentage;
var
  p : TPathOwnerDetailPair;
  TotalPcSpace, MaxPcSpace : Int64;
begin
  TotalPcSpace := 0;
  MaxPcSpace := 0;
  for p in PathOwnerDetailHash do
  begin
    if not p.Value.IsOnline then
      Continue;

    TotalPcSpace := TotalPcSpace + p.Value.OwnerSpace;
    if p.Value.OwnerSpace > MaxPcSpace then
      MaxPcSpace := p.Value.OwnerSpace;
  end;

  MaxPercentage := MyPercentage.getPercent( TotalPcSpace, FolderSize );
  if CopyCount > 1 then
    MinPercentage := MyPercentage.getPercent( MaxPcSpace, FolderSize )
  else
    MinPercentage := MaxPercentage;
end;

procedure TRestorePathDetaiAddInfo.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TRestorePathDetaiAddInfo.SetFolderSize(_FolderSize: Int64;
  _FileCount : Integer);
begin
  FolderSize := _FolderSize;
  FileCount := _FileCount;
end;

procedure TRestorePathDetaiAddInfo.Update;
var
  StatusIcon, StatusInt : Integer;
  lvBackupPathDetail : TListView;
  ItemData : TLvBackupPathDetailData;
begin
    // ·���Ļָ��ٷֱ�
  FindRestorePercentage;

  if MinPercentage >= 100 then
  begin
    StatusIcon := MyShellBackupStatusIconUtil.getFileCompleted;
    StatusInt := 2;
  end
  else
  if MinPercentage = 0 then
  begin
    StatusIcon := MyShellBackupStatusIconUtil.getFileIncompleted;
    StatusInt := 0;
  end
  else
  begin
    StatusIcon := MyShellBackupStatusIconUtil.getFilePartcompleted;
    StatusInt := 1;
  end;

  ItemData := TLvBackupPathDetailData.Create( FullPath );
  ItemData.SetSpaceInfo( FolderSize, FileCount );
  ItemData.StatusInt := StatusInt;
  ItemData.SetPathOwnerDetailHash( PathOwnerDetailHash );

  lvBackupPathDetail := frmRestoreDetail.LvBackupPathDetail;
  with lvBackupPathDetail.Items.Add do
  begin
    Caption := MyFileInfo.getFileName( FullPath );
    SubItems.Add('');
    ImageIndex := PathTypeIconUtil.getIcon( FullPath, PathType );
    SubItemImages[0] := StatusIcon;
    Data := ItemData;
  end;

  if lvBackupPathDetail.Items.Count = 1 then
    lvBackupPathDetail.Items[0].Selected := True;
end;

{ TLvBackupPathDetailData }

constructor TLvBackupPathDetailData.Create( _FullPath : string );
begin
  PathOwnerDetailHash := TPathOwnerDetailHash.Create;
  FullPath := _FullPath;
end;

destructor TLvBackupPathDetailData.Destroy;
begin
  PathOwnerDetailHash.Free;
  inherited;
end;

procedure TLvBackupPathDetailData.SetSpaceInfo(_FolderSpace: Int64;
  _FileCount : Integer);
begin
  FolderSpace := _FolderSpace;
  FileCount := _FileCount;
end;

procedure TLvBackupPathDetailData.SetPathOwnerDetailHash(
  _PathOwnerDetailHash: TPathOwnerDetailHash);
var
  p : TPathOwnerDetailPair;
  PathOwnerDetailInfo : TPathOwnerDetailInfo;
begin
  for p in _PathOwnerDetailHash do
  begin
    PathOwnerDetailInfo := TPathOwnerDetailInfo.Create( p.Value.PcID, p.Value.OwnerSpace );
    PathOwnerDetailInfo.SetIsOnline( p.Value.IsOnline );
    PathOwnerDetailInfo.SetPcName( p.Value.PcName );
    PathOwnerDetailInfo.SetLastOnlineTime( p.Value.LastOnlineTime );
    PathOwnerDetailHash.AddOrSetValue( p.Value.PcID, PathOwnerDetailInfo );
  end;
end;

{ TVstRestoreDownChangeInfo }

procedure TVstRestoreDownChange.Update;
begin
  vstRestoreDown := frmMainForm.vstRestoreDown;
end;

{ TVstRestoreDownAddRootInfo }

procedure TVstRestoreDownAddRoot.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSpace;
end;

procedure TVstRestoreDownAddRoot.SetIsScaning(_IsScaning: Boolean);
begin
  IsScaning := _IsScaning;
end;

procedure TVstRestoreDownAddRoot.SetPathInfo(_PathType,
  _SaveAsPath: string);
begin
  PathType := _PathType;
  SaveAsPath := _SaveAsPath;
end;

procedure TVstRestoreDownAddRoot.SetRestorePc(
  _RestorePcName: string);
begin
  RestorePcName := _RestorePcName;
end;

procedure TVstRestoreDownAddRoot.Update;
begin
  inherited;

    // �Ѵ���
  if FindRestoreItemNode then
    Exit;

  RestoreItemNode := vstRestoreDown.AddChild( vstRestoreDown.RootNode );
  RestoreItemData := vstRestoreDown.GetNodeData( RestoreItemNode );
  RestoreItemData.FullPath := FullPath;
  RestoreItemData.SaveAsPath := SaveAsPath;
  RestoreItemData.PathType := PathType;
  RestoreItemData.ImageIndex := PathTypeIconUtil.getIcon( FullPath, PathType );
  RestoreItemData.FileSize := FileSize;
  RestoreItemData.CompletedSize := CompletedSize;
  RestoreItemData.RestorePcID := RestorePcID;
  RestoreItemData.RestorePcName := RestorePcName;
  RestoreItemData.LocationID := '';
  RestoreItemData.LocationName := '';
  RestoreItemData.LocationIsOnline := True;
  RestoreItemData.IsScaning := IsScaning;

    // ��һ�� ��
  if vstRestoreDown.RootNodeCount = 1 then
    frmMainForm.tbtnRdClear.Enabled := True;
end;

{ TVstRestoreDownAddChildInfo }

procedure TVstRestoreDownAddChild.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstRestoreDownAddChild.SetLocationPc(_LocatinID,
  _LocationName: string);
begin
  LocatinID := _LocatinID;
  LocationName := _LocationName;
end;

procedure TVstRestoreDownAddChild.Update;
begin
  inherited;

    // ���ڵ� ������
  if not FindRootNode then
    Exit;

    // ֹͣɨ��
  if RootData.IsScaning then
    RootData.IsScaning := False;

    // ���ڵ����ļ�
  if getIsFileNode then
  begin
    RootData.LocationID := LocatinID;
    RootData.LocationName := LocationName;
    Exit;
  end;

    // ��� �ӽڵ�
  ChildNode := vstRestoreDown.AddChild( RootNode );
  ChildData := vstRestoreDown.GetNodeData( ChildNode );
  ChildData.FullPath := FilePath;
  ChildData.ImageIndex := MyIcon.getIconByFileExt( FilePath );
  ChildData.PathType := PathType_File;
  ChildData.FileSize := FileSize;
  ChildData.CompletedSize := CompletedSize;
  ChildData.LocationID := LocatinID;
  ChildData.LocationName := LocationName;
  ChildData.Status := RestoreStatus_Waiting;
  ChildData.LocationIsOnline := True;
end;

{ TVstRestoreDownRemoveChildInfo }

procedure TVstRestoreDownRemoveChild.Update;
begin
  inherited;

    // �Ҳ��� ���ڵ�
  if not FindChildNode then
    Exit;

    // �ļ� ���ڵ�
  if getIsFileNode then
    Exit;

    // ɾ�� �ӽڵ�
  vstRestoreDown.DeleteNode( ChildNode );
end;

{ TVstRestoreDownChildChangeInfo }

constructor TVstRestoreDownChildChange.Create(_FilePath,
  _RestorePcID: string);
begin
  FilePath := _FilePath;
  RestorePcID := _RestorePcID;
end;

function TVstRestoreDownChildChange.FindChildNode: Boolean;
var
  SelectChildNode : PVirtualNode;
  SelectChildData : PVstRestoreDownData;
begin
  Result := False;

    // ���ڵ� ������
  if not FindRootNode then
    Exit;

    // ���ڵ� �� �ļ��ڵ�
  if RootData.FullPath = FilePath then
  begin
    ChildNode := RootNode;
    ChildData := RootData;
    Result := True;
    Exit;
  end;

    // Ѱ���ļ��ڵ�
  SelectChildNode := RootNode.FirstChild;
  while Assigned( SelectChildNode ) do
  begin
    SelectChildData := vstRestoreDown.GetNodeData( SelectChildNode );
    if SelectChildData.FullPath = FilePath then
    begin
      ChildNode := SelectChildNode;
      ChildData := SelectChildData;
      Result := True;
      Break;
    end;
    SelectChildNode := SelectChildNode.NextSibling;
  end;

end;

function TVstRestoreDownChildChange.FindRootNode: Boolean;
var
  SelectRootNode : PVirtualNode;
  SelectRootData : PVstRestoreDownData;
begin
  Result := False;

  SelectRootNode := vstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectRootNode ) do  // Ѱ�Ҹ��ڵ�
  begin
    SelectRootData := vstRestoreDown.GetNodeData( SelectRootNode );
    if MyMatchMask.CheckEqualsOrChild( FilePath, SelectRootData.FullPath ) and
       ( SelectRootData.RestorePcID = RestorePcID )
    then
    begin
      RootNode := SelectRootNode;
      RootData := SelectRootData;
      Result := True;
      Break;
    end;
    SelectRootNode := SelectRootNode.NextSibling;
  end;
end;

function TVstRestoreDownChildChange.getIsFileNode: Boolean;
begin
  Result := FilePath = RootData.FullPath;
end;

procedure TVstRestoreDownChildChange.RefreshChildNode;
begin
  vstRestoreDown.RepaintNode( ChildNode );
end;

{ TVstRestoreDownChildStatusInfo }

procedure TVstRestoreDownChildStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstRestoreDownChildStatus.Update;
begin
  inherited;

    // �ӽڵ㲻����
  if not FindChildNode then
    Exit;

    // �ļ� ���ڵ�
  if getIsFileNode then
    Exit;

    // �ڵ�����
  ChildData.Status := Status;

    // �ػ�
  RefreshChildNode;
end;

{ TVstRestoreDownRemoveRootInfo }

procedure TVstRestoreDownRemoveRoot.Update;
begin
  inherited;

    // ������
  if not FindRestoreItemNode then
    Exit;

    // ɾ��
  vstRestoreDown.DeleteNode( RestoreItemNode );

    // ���
  if vstRestoreDown.RootNode.ChildCount = 0 then
    frmMainForm.tbtnRdClear.Enabled := False;
end;

{ TVstRestorePcDataChange }

procedure TVstRestorePcChange.Update;
begin
  vstRestorePc := frmMainForm.vstRestoreComputers;
  RestorePcList := MyRestoreFileFace.RestorePcList;
end;

{ TVstRestorePcWrite }

constructor TVstRestorePcWrite.Create(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

function TVstRestorePcWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestorePcData;
begin
  Result := False;

  SelectNode := vstRestorePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstRestorePc.GetNodeData( SelectNode );
    if SelectData.RestorePcID = RestorePcID then
    begin
      PcNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;

    // ӵ������Ϣ
  RestorePcInfo := RestorePcList.getRestorePcInfo( RestorePcID );
end;

procedure TVstRestorePcWrite.RefreshPcVisible;
begin
  vstRestorePc.IsVisible[ PcNode ] := ( NodeData.RestoreItemCount > 0 ) and
                                       RestorePcInfo.getHasOnline;
end;

{ TVstRestorePcAdd }

procedure TVstRestorePcAdd.AddRestorePcInfo;
begin
  RestorePcInfo := TRestorePcInfo.Create( RestorePcID );
  RestorePcList.Add( RestorePcInfo );
end;

procedure TVstRestorePcAdd.SetRestorePcName(_RestorePcName: string);
begin
  RestorePcName := _RestorePcName;
end;

procedure TVstRestorePcAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindPcNode then
    Exit;

    // ���
  PcNode := vstRestorePc.AddChild( vstRestorePc.RootNode );
  NodeData := vstRestorePc.GetNodeData( PcNode );
  NodeData.RestorePcID := RestorePcID;
  NodeData.RestorePcName := RestorePcName;
  NodeData.RestoreItemCount := 0;
  NodeData.IsFileInvisible := False;
  NodeData.IvPasswordMD5 := '';
  NodeData.IsShowUpload := False;
  NodeData.IsShowDownload := False;
  NodeData.UploadCount := 0;
  NodeData.DownloadCount := 0;

    // ��ӵ���¼��
  AddRestorePcInfo;

    // ˢ�� �ɼ���
  RefreshPcVisible;
end;

{ TVstRestorePcSetItemCount }

procedure TVstRestorePcSetItemCount.SetRestoreItemCount(
  _RestoreItemCount: Integer);
begin
  RestoreItemCount := _RestoreItemCount;
end;

procedure TVstRestorePcSetItemCount.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

    // ˢ�� ����·�� ��
  NodeData.RestoreItemCount := RestoreItemCount;

    // ˢ�� Pc �ɼ���
  RefreshPcVisible;
end;

{ TVstRestoreDownWriteInfo }

constructor TVstRestoreDownWrite.Create(_FullPath, _RestorePcID: string);
begin
  FullPath := _FullPath;
  RestorePcID := _RestorePcID;
end;

function TVstRestoreDownWrite.FindRestoreItemNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstRestoreDownData;
begin
  Result := False;

  SelectNode := vstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstRestoreDown.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and ( SelectData.RestorePcID = RestorePcID ) then
    begin
      RestoreItemNode := SelectNode;
      RestoreItemData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstRestoreDownWrite.RefreshRestoreItem;
begin
  vstRestoreDown.RepaintNode( RestoreItemNode );
end;

{ TVstRestorePcSetInvisible }

procedure TVstRestorePcSetInvisible.SetInvisibleInfo(_IsFileInvisible: Boolean;
  _IvPasswordMD5: string);
begin
  IsFileInvisible := _IsFileInvisible;
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TVstRestorePcSetInvisible.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

    // ����
  NodeData.IsFileInvisible := IsFileInvisible;
  NodeData.IvPasswordMD5 := IvPasswordMD5;
end;

{ TVstRestoreFileSearchCompleted }

procedure TVstRestoreFileSearchCompleted.Update;
begin
  inherited;

  frmRestore.lbSearching.Caption := frmRestore.siLang_frmRestore.GetText( 'SearchComplete' );
end;

{ TVstRestoreDownAddRootSpace }

procedure TVstRestoreDownAddRootSpace.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TVstRestoreDownAddRootSpace.Update;
begin
  inherited;

    // ������
  if not FindRestoreItemNode then
    Exit;

    // ����ܿռ�
  RestoreItemData.FileSize := RestoreItemData.FileSize + FileSize;
  RefreshRestoreItem;
end;

{ TVstRestoreDownAddRootCompletedSpace }

procedure TVstRestoreDownAddRootCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TVstRestoreDownAddRootCompletedSpace.Update;
begin
  inherited;

    // ������
  if not FindRestoreItemNode then
    Exit;

    // ����ܿռ�
  RestoreItemData.CompletedSize := RestoreItemData.CompletedSize + CompletedSpace;
  RefreshRestoreItem;
end;


{ TVstRestoreDownChildAddCompletedSpace }

procedure TVstRestoreDownChildAddCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TVstRestoreDownChildAddCompletedSpace.Update;
begin
  inherited;

    // �ӽڵ㲻����
  if not FindChildNode then
    Exit;

    // �ļ���
  if getIsFileNode then
    Exit;

    // �ڵ�����
  ChildData.CompletedSize := ChildData.CompletedSize + CompletedSpace;

    // �ػ�
  RefreshChildNode;
end;

{ VstRestoreDownUtil }

class function VstRestoreDownUtil.getHintStr(Node: PVirtualNode): string;
var
  VstRestoreFile : TVirtualStringTree;
  ParentNode : PVirtualNode;
  IsRoot : Boolean;
  NodeData, ParentData : PVstRestoreDownData;
  SavePath, RestoerPcName, TempStr : string;
begin
  VstRestoreFile := frmMainForm.vstRestoreDown;
  IsRoot := Node.Parent = VstRestoreFile.RootNode;

  NodeData := VstRestoreFile.GetNodeData( Node );
  if IsRoot then
  begin
    SavePath := NodeData.SaveAsPath;
    RestoerPcName := NodeData.RestorePcName;
  end
  else
  begin
    ParentData := VstRestoreFile.GetNodeData( Node.Parent );
    SavePath := StringReplace( NodeData.FullPath, ParentData.FullPath, ParentData.SaveAsPath, [] );
    RestoerPcName := ParentData.RestorePcName;
  end;

  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintRestorePath' );
  Result := TempStr + NodeData.FullPath +#13#10;
  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintRestorePc' );
  Result := Result + TempStr + RestoerPcName + #13#10;
  TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintSavePath' );
  Result := Result + TempStr + SavePath;
  if not IsRoot then
  begin
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'HintRestoreFrom' );
    Result := Result + #13#10 + TempStr + NodeData.LocationName;
  end;
end;

class function VstRestoreDownUtil.getStatus(Node: PVirtualNode): string;
var
  NodeData : PVstRestoreDownData;
begin
  NodeData := frmMainForm.vstRestoreDown.GetNodeData(Node);
  if NodeData.IsScaning and ( NodeData.FileSize = 0 ) then
    Result := RestoreStatus_Searching
  else
  if not NodeData.LocationIsOnline then
    Result := REstoreStatus_Offline
  else
  if Node.Parent = frmMainForm.vstRestoreDown.RootNode then
  begin
    if NodeData.CompletedSize >= NodeData.FileSize then
      Result := RestoreStatus_Completed
    else
      Result := RestoreStatus_InCompleted;
  end
  else
    Result := NodeData.Status;
end;

class function VstRestoreDownUtil.getStatusIcon(Node : PVirtualNode): Integer;
var
  Status: string;
begin
  Status := getStatus( Node );
  if Status = RestoreStatus_Searching then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if Status = REstoreStatus_Offline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if Status = RestoreStatus_Waiting then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if Status = RestoreStatus_Loading then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
  if Status = RestoreStatus_InCompleted then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
  if Status = RestoreStatus_Completed then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if Status <> '' then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
    Result := -1;
end;

{ TRestoreLocationInfo }

constructor TRestoreLocationInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  IsOnline := False;
end;

procedure TRestoreLocationInfo.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

{ TRestorePcInfo }

constructor TRestorePcInfo.Create(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
  RestoreLocationList := TRestoreLocationList.Create;
end;

destructor TRestorePcInfo.Destroy;
begin
  RestoreLocationList.Free;
  inherited;
end;

function TRestorePcInfo.getHasOnline: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to RestoreLocationList.Count - 1 do
    if RestoreLocationList[i].IsOnline then
    begin
      Result := True;
      Break;
    end;
end;

{ TMyRestoreFileFace }

constructor TMyRestoreFileFace.Create;
begin
  inherited;
  RestorePcList := TRestorePcList.Create;
end;

destructor TMyRestoreFileFace.Destroy;
begin
  RestorePcList.Free;
  inherited;
end;

{ TVstRestorePcChangeLocation }

procedure TVstRestorePcChangeLocation.RefreshVisible( RestorePcID : string );
var
  VstRestorePcRefreshVisible : TVstRestorePcRefreshVisible;
begin
    // ˢ�½�����ʾ
  VstRestorePcRefreshVisible := TVstRestorePcRefreshVisible.Create( RestorePcID );
  VstRestorePcRefreshVisible.Update;
  VstRestorePcRefreshVisible.Free;
end;

procedure TVstRestorePcChangeLocation.Update;
begin
  RestorePcList := MyRestoreFileFace.RestorePcList;
end;

{ TVstRestorePcLocationIsOnline }

constructor TVstRestorePcLocationIsOnline.Create(_LocationPcID: string);
begin
  LocationPcID := _LocationPcID;
end;

procedure TVstRestorePcLocationIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstRestorePcLocationIsOnline.Update;
var
  i, j : Integer;
  RestoreLocationList : TRestoreLocationList;
begin
  inherited;

  for i := 0 to RestorePcList.Count - 1 do
  begin
    RestoreLocationList := RestorePcList[i].RestoreLocationList;
    for j := 0 to RestoreLocationList.Count - 1 do
      if RestoreLocationList[j].PcID = LocationPcID then
      begin
        RestoreLocationList[j].IsOnline := IsOnline;
        RefreshVisible( RestorePcList[i].RestorePcID );
        Break;
      end;
  end;
end;

{ TVstRestorePcLocationServerOffline }

procedure TVstRestorePcLocationServerOffline.Update;
var
  i, j : Integer;
  RestoreLocationList : TRestoreLocationList;
begin
  inherited;

  for i := 0 to RestorePcList.Count - 1 do
  begin
    RestoreLocationList := RestorePcList[i].RestoreLocationList;
    for j := 0 to RestoreLocationList.Count - 1 do
      RestoreLocationList[j].IsOnline := False;
    RefreshVisible( RestorePcList[i].RestorePcID );
  end;
end;

{ TVstRestorePcSetLocation }

constructor TVstRestorePcWriteLocation.Create(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

{ TRestorePcList }

function TRestorePcList.getRestorePcInfo(RestorePcID: string): TRestorePcInfo;
var
  i : Integer;
begin
  Result := nil;

  for i := 0 to Self.Count - 1 do
    if Self[i].RestorePcID = RestorePcID then
    begin
      Result := Self[i];
      Break;
    end;
end;

{ TVstRestorePcRefreshVisible }

procedure TVstRestorePcRefreshVisible.Update;
begin
  inherited;

    // Pc ������
  if not FindPcNode then
    Exit;

    // ˢ�� �ɼ���
  RefreshPcVisible;
end;

{ TVstRestorePcAddLocation }

procedure TVstRestorePcAddLocation.SetLocationInfo(_LocationPcID: string;
  _IsOnline: Boolean);
begin
  LocationPcID := _LocationPcID;
  IsOnline := _IsOnline;
end;

procedure TVstRestorePcAddLocation.Update;
var
  i : Integer;
  RestoreLocationList : TRestoreLocationList;
  IsExist : Boolean;
  RestoreLocationInfo : TRestoreLocationInfo;
begin
  inherited;

  if not FindRestorePcInfo then
    Exit;

  IsExist := False;
  RestoreLocationList := RestorePcInfo.RestoreLocationList;
  for i := 0 to RestoreLocationList.Count - 1 do
    if RestoreLocationList[i].PcID = LocationPcID then
    begin
      RestoreLocationList[i].IsOnline := IsOnline;
      IsExist := True;
      Break;
    end;

  if not IsExist then
  begin
    RestoreLocationInfo := TRestoreLocationInfo.Create( LocationPcID );
    RestoreLocationInfo.SetIsOnline( IsOnline );
    RestoreLocationList.Add( RestoreLocationInfo );
  end;
end;

function TVstRestorePcWriteLocation.FindRestorePcInfo: Boolean;
begin
  RestorePcInfo := RestorePcList.getRestorePcInfo( RestorePcID );
  Result := RestorePcInfo <> nil;
end;

{ TVstRestorePcClearLocation }

procedure TVstRestorePcClearLocation.Update;
begin
  inherited;

  if not FindRestorePcInfo then
    Exit;

  RestorePcInfo.RestoreLocationList.Clear;
end;

{ TVstRestorePcRefresh }

procedure TVstRestorePcRefresh.Update;
begin
  inherited;
  RefreshVisible( RestorePcID );
end;

{ TVstRestoreDownAddFileResult }

procedure TVstRestoreDownAddFileResult.Update;
begin
  inherited;
  inc( RestoreFile_SearchCount );
  frmMainForm.lbFiles.Caption := Format( frmRestore.siLang_frmRestore.GetText( 'SearchCount' ), [RestoreFile_SearchCount] );
end;

{ TVstRestoreDownSearchCompleted }

procedure TVstRestoreDownSearchCompleted.Update;
begin
  inherited;
  frmMainForm.lbSearching.Visible := False;
  frmMainForm.lbFiles.Visible := False;
end;

{ TVstRestoreDownChildOffline }

procedure TVstRestoreDownChildOffline.Update;
begin
  inherited;
  if not FindChildNode then
    Exit;
  ChildData.LocationIsOnline := False;
  RefreshChildNode;
end;

{ TVstRestoreDownLocationOnline }

procedure TVstRestoreDownLocationOnline.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TVstRestoreDownLocationOnline.Update;
var
  SelectNode, ChildNode : PVirtualNode;
  SelectData, ChildData : PVstRestoreDownData;
begin
  inherited;

  SelectNode := vstRestoreDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstRestoreDown.GetNodeData( SelectNode );
    if SelectData.LocationID = OnlinePcID then
    begin
      SelectData.LocationIsOnline := True;
      vstRestoreDown.RepaintNode( SelectNode );
    end;
    ChildNode := SelectNode.FirstChild;
    while Assigned( ChildNode ) do
    begin
      ChildData := vstRestoreDown.GetNodeData( ChildNode );
      if ChildData.LocationID = OnlinePcID then
      begin
        ChildData.LocationIsOnline := True;
        vstRestoreDown.RepaintNode( ChildNode );
      end;
      ChildNode := ChildNode.NextSibling;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

end.
