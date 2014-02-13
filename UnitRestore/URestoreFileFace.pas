unit URestoreFileFace;

interface

uses ComCtrls, UChangeInfo, SysUtils, UMyUtil, VirtualTrees, Math, Classes, UIconUtil,
     Generics.Collections, UModelUtil;

type

  // 恢复窗口

{$Region ' Restore Path Detail '}

    // 每一条 路径 Pc 拥有者信息
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

    // ListView 数据
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

    // 添加 恢复 信息 路径
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

    // 寻找/创建 子节点
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

    // 递归创建 文件节点
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

    // 添加文件节点
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

    // 搜索 恢复文件 完成
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

  // 主窗口

{$Region ' MainForm ListView Restore Download ' }

    // 数据结构
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

    // 辅助类
  VstRestoreDownUtil = class
  public
    class function getStatus( Node : PVirtualNode ) : string;
    class function getStatusIcon( Node : PVirtualNode ): Integer;
  public
    class function getHintStr( Node : PVirtualNode ): string;
  end;

    // 父类
  TVstRestoreDownChange = class( TChangeInfo )
  public
    vstRestoreDown : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // Location 上线
  TVstRestoreDownLocationOnline = class( TVstRestoreDownChange )
  private
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure Update;override;
  end;

  {$Region ' 修改 根目录 ' }

    // 修改
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

    // 添加 根目录
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

    // 添加 根总空间 信息
  TVstRestoreDownAddRootSpace = class( TVstRestoreDownWrite )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 根已完成空间 信息
  TVstRestoreDownAddRootCompletedSpace = class( TVstRestoreDownWrite )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

      // 移除 根目录
  TVstRestoreDownRemoveRoot = class( TVstRestoreDownWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子目录 ' }

    // 修改 子目录
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

    // 添加 子目录
  TVstRestoreDownAddChild = class( TVstRestoreDownChildChange )
  public
    FileSize, CompletedSize : Int64;
    LocatinID, LocationName : string;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetLocationPc( _LocatinID, _LocationName : string );
    procedure Update;override;
  end;

    // 修改 子目录 状态
  TVstRestoreDownChildStatus = class( TVstRestoreDownChildChange )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 修改 子目录 已完成空间
  TVstRestoreDownChildAddCompletedSpace = class( TVstRestoreDownChildChange )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

    // 修改 恢复目标 离线
  TVstRestoreDownChildOffline = class( TVstRestoreDownChildChange )
  private
    procedure Update;override;
  end;

    // 移除 子目录
  TVstRestoreDownRemoveChild = class( TVstRestoreDownChildChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 恢复文件搜索状态 ' }

    // 搜索到一个结果
  TVstRestoreDownAddFileResult = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // 搜索完成
  TVstRestoreDownSearchCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Restore Computer 列表 ' }

    // 恢复文件的来源
  TRestoreLocationInfo = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
  end;
  TRestoreLocationList = class(TObjectList< TRestoreLocationInfo >);

    // 恢复 Pc 的信息
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

    // 数据结构
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

    // 父类
  TVstRestorePcChange = class( TChangeInfo )
  public
    vstRestorePc : TVirtualStringTree;
    RestorePcList : TRestorePcList;
  public
    procedure Update;override;
  end;

    // 修改
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

    // 添加
  TVstRestorePcAdd = class( TVstRestorePcWrite )
  public
    RestorePcName : string;
  public
    procedure SetRestorePcName( _RestorePcName : string );
    procedure Update;override;
  private
    procedure AddRestorePcInfo;
  end;

    // 设置 备份 Item 数
  TVstRestorePcSetItemCount = class( TVstRestorePcWrite )
  public
    RestoreItemCount : Integer;
  public
    procedure SetRestoreItemCount( _RestoreItemCount : Integer );
    procedure Update;override;
  end;

    // 设置 文件可见性
  TVstRestorePcSetInvisible = class( TVstRestorePcWrite )
  public
    IsFileInvisible : Boolean;
    IvPasswordMD5 : string;
  public
    procedure SetInvisibleInfo( _IsFileInvisible : Boolean; _IvPasswordMD5 : string );
    procedure Update;override;
  end;

    // 刷新 可见性
  TVstRestorePcRefreshVisible = class( TVstRestorePcWrite )
  public
    procedure Update;override;
  end;

  {$Region ' Restore Location 修改 ' }

    // 备份位置 修改
  TVstRestorePcChangeLocation = class( TChangeInfo )
  public
    RestorePcList : TRestorePcList;
  public
    procedure Update;override;
  protected
    procedure RefreshVisible( RestorePcID : string );
  end;

    // 初始化 设置 LocationList
  TVstRestorePcWriteLocation = class( TVstRestorePcChangeLocation )
  public
    RestorePcID : string;
    RestorePcInfo : TRestorePcInfo;
  public
    constructor Create( _RestorePcID : string );
  protected
    function FindRestorePcInfo : Boolean;
  end;

    // 刷新
  TVstRestorePcRefresh = class( TVstRestorePcWriteLocation )
  public
    procedure Update;override;
  end;

    // 清空
  TVstRestorePcClearLocation = class( TVstRestorePcWriteLocation )
  public
    procedure Update;override;
  end;

    // 添加
  TVstRestorePcAddLocation = class( TVstRestorePcWriteLocation )
  private
    LocationPcID : string;
    IsOnline : Boolean;
  public
    procedure SetLocationInfo( _LocationPcID : string; _IsOnline : Boolean );
    procedure Update;override;
  end;

    // 备份位置 上/下线
  TVstRestorePcLocationIsOnline = class( TVstRestorePcChangeLocation )
  public
    LocationPcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _LocationPcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // 备份位置 Server 离线
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
    // 根节点 不存在
  if not FindFileNode then
    Exit;

  FileData := frmRestore.vstRestoreFile.GetNodeData( FileNode );

    // 节点 已存在
  if FileData.LocationID <> '' then
    Exit;

    // 设置 节点信息
  FileData.FilePath := FilePath;
  FileData.FileSize := FileSize;
  FileData.FileTime := FileTime;
  FileData.LocationID := LocationID;
  FileData.LocationName := LocationName;
  FileData.PathType := PathType_File;

    // 更新 父节点 FileSize
  UpgradeParentSize;

    // 显示 恢复文件数
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

        // 添加 Vst 界面
      ChildNode := vstRestoreFile.AddChild( vstRestoreFile.RootNode );
      ChildNode.CheckState := csUncheckedNormal;
      ChildNode.CheckType := ctTriStateCheckBox;
      ChildData := vstRestoreFile.GetNodeData( ChildNode );
      ChildData.FileName := FullPath;
      ChildData.FilePath := FullPath;
      ChildData.FileSize := 0;
      ChildData.PathType := PathType;
      ChildData.TotalSpace := FolderSpace;

        // 返回根节点
      RootNode := ChildNode;
      RemainPath := MyString.CutStartStr( MyFilePath.getPath( FullPath ), FilePath );

        // 删除 Lv Unvailable 界面
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
    // 找不到 根目录
  if not FindRootNode and not FindUnvailableItem then
  begin
    Result := nil;
    Exit;
  end;

    // 根目录 是文件
  if RemainPath = '' then
  begin
    Result := RootNode;
    Exit;
  end;

    // 递归创建 节点
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

    // 存在 节点
  if FindChildNode then
    Result := ChildNode
  else
  begin     // 创建节点
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
    // 路径的恢复百分比
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

    // 已存在
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

    // 第一个 根
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

    // 根节点 不存在
  if not FindRootNode then
    Exit;

    // 停止扫描
  if RootData.IsScaning then
    RootData.IsScaning := False;

    // 根节点是文件
  if getIsFileNode then
  begin
    RootData.LocationID := LocatinID;
    RootData.LocationName := LocationName;
    Exit;
  end;

    // 添加 子节点
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

    // 找不到 父节点
  if not FindChildNode then
    Exit;

    // 文件 根节点
  if getIsFileNode then
    Exit;

    // 删除 子节点
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

    // 根节点 不存在
  if not FindRootNode then
    Exit;

    // 根节点 是 文件节点
  if RootData.FullPath = FilePath then
  begin
    ChildNode := RootNode;
    ChildData := RootData;
    Result := True;
    Exit;
  end;

    // 寻找文件节点
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
  while Assigned( SelectRootNode ) do  // 寻找根节点
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

    // 子节点不存在
  if not FindChildNode then
    Exit;

    // 文件 根节点
  if getIsFileNode then
    Exit;

    // 节点数据
  ChildData.Status := Status;

    // 重画
  RefreshChildNode;
end;

{ TVstRestoreDownRemoveRootInfo }

procedure TVstRestoreDownRemoveRoot.Update;
begin
  inherited;

    // 不存在
  if not FindRestoreItemNode then
    Exit;

    // 删除
  vstRestoreDown.DeleteNode( RestoreItemNode );

    // 清空
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

    // 拥有者信息
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

    // 已存在
  if FindPcNode then
    Exit;

    // 添加
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

    // 添加到记录中
  AddRestorePcInfo;

    // 刷新 可见性
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

    // 不存在
  if not FindPcNode then
    Exit;

    // 刷新 备份路径 数
  NodeData.RestoreItemCount := RestoreItemCount;

    // 刷新 Pc 可见性
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

    // 不存在
  if not FindPcNode then
    Exit;

    // 设置
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

    // 不存在
  if not FindRestoreItemNode then
    Exit;

    // 添加总空间
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

    // 不存在
  if not FindRestoreItemNode then
    Exit;

    // 添加总空间
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

    // 子节点不存在
  if not FindChildNode then
    Exit;

    // 文件根
  if getIsFileNode then
    Exit;

    // 节点数据
  ChildData.CompletedSize := ChildData.CompletedSize + CompletedSpace;

    // 重画
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
    // 刷新界面显示
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

    // Pc 不存在
  if not FindPcNode then
    Exit;

    // 刷新 可见性
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
