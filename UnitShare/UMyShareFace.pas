unit UMyShareFace;

interface

uses UChangeInfo, ComCtrls, virtualtrees, Generics.Collections, UModelUtil, RzTabs, Controls,
     UFmShareFileExplorer, SysUtils, Classes, SyncObjs, DateUtils, uDebug;

type

{$Region ' Form Vst 选择我的共享路径 ' }

    // 修改 父类
  TVstSelectSharePathChange = class( TChangeInfo )
  public
    vstSelectSharePath : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // 修改 单个 父类
  TVstSelectSharePathWrite = class( TVstSelectSharePathChange )
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // 添加
  TVstSelectSharePathAdd = class( TVstSelectSharePathWrite )
  public
    procedure Update;override;
  end;

    // 删除
  TVstSelectSharePathRemove = class( TVstSelectSharePathWrite )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Listview 我的共享路径 ' }

  TVstSharePathData = record
  public
    FullPath, PathType : WideString;
  end;
  PVstSharePathData = ^TVstSharePathData;

      // 修改 父类
  TLvSharePathChange = class( TChangeInfo )
  public
    VstSharePath : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // 修改 指定路径 父类
  TLvSharePathWrite = class( TLvSharePathChange )
  public
    FullPath : string;
  protected
    SharePathNode : PVirtualNode;
    NodeData : PVstSharePathData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode : Boolean;
  end;

    // 添加
  TLvSharePathAdd = class( TLvSharePathWrite )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // 删除
  TLvSharePathRemove = class( TLvSharePathWrite )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Form 选择下载网络共享文件 ' }

  {$Region ' Select Computer ' }

  TLvSharePcData = class
  public
    PcID, PcName : string;
  public
    constructor Create( _PcID, _PcName : string );
  end;

    // 父类
  TLvDownSharePcChange = class( TChangeInfo )
  public
    LvDownSharePc : TListView;
  public
    procedure Update;override;
  end;

    // 修改
  TLvDownSharePcWrite = class( TLvDownSharePcChange )
  public
    PcID : string;
  protected
    PcItem : TListItem;
    PcIndex : Integer;
    PcData : TLvSharePcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcItem : Boolean;
  end;

    // 添加
  TLvDownSharePcAdd = class( TLvDownSharePcWrite )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // 删除
  TLvDownSharePcRemove = class( TLvDownSharePcWrite )
  public
    procedure Update;override;
  end;

    // 清空
  TLvDownSharePcClear = class( TLvDownSharePcChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' History Position ' }

    // 数据结构
  TVstShareHistoryData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
  end;
  PVstShareHistoryData = ^TVstShareHistoryData;

    // 父类
  TVstShareHistoryChange = class( TChangeInfo )
  public
    VstShareHistory : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshClearBtn;
  end;

    // Pc 上/下线
  TVstShareHistoryPcOnline = class( TVstShareHistoryChange )
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // Server 离线
  TVstShareHistoryServerOffline = class( TVstShareHistoryChange )
  public
    procedure Update;override;
  end;

    // 修改
  TVstShareHistoryWrite = class( TVstShareHistoryChange )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathNode : PVirtualNode;
    NodeData : PVstShareHistoryData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // 添加
  TVstShareHistoryAdd = class( TVstShareHistoryWrite )
  public
    DesPcName : string;
    DesPcIsOnline : Boolean;
    PathType : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetDesPcIsOnline( _DesPcIsOnline : Boolean );
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  private
    procedure CheckRemove;
  end;

    // 删除
  TVstShareHistoryRemove = class( TVstShareHistoryWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Favorite Position ' }

    // 数据结构
  TVstShareFavorityData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
  end;
  PVstShareFavorityData = ^TVstShareFavorityData;

    // 父类
  TVstShareFavorityChange = class( TChangeInfo )
  public
    VstShareFavority : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshClearBtn;
  end;

      // Pc 上/下线
  TVstShareFavorityPcOnline = class( TVstShareFavorityChange )
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

      // Server 离线
  TVstShareFavorityServerOffline = class( TVstShareFavorityChange )
  public
    procedure Update;override;
  end;

    // 修改
  TVstShareFavorityWrite = class( TVstShareFavorityChange )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathNode : PVirtualNode;
    NodeData : PVstShareFavorityData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // 添加
  TVstShareFavorityAdd = class( TVstShareFavorityWrite )
  public
    DesPcName : string;
    DesPcIsOnline : Boolean;
    PathType : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetDesPcIsOnline( _DesPcIsOnline : Boolean );
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;


    // 删除
  TVstShareFavorityRemove = class( TVstShareFavorityWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Select Files ' }

  TVstShareFolderData = record
  public
    FilePath : WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    IsWaiting : Boolean;
  end;
  PVstShareFolderData = ^TVstShareFolderData;

    // 辅助类
  VstShareFolderUtil = class
  public
    class function getTap( DesPcID : string ) : TRzTabSheet;
    class function getFrame( ts : TRzTabSheet ):TFrameShareFiles;
    class function getVstShareFiles( DesPcID : string ): TVirtualStringTree;
  end;

    // 修改 单个 父类
  TVstShareFileWrite = class( TChangeInfo )
  protected
    ParentPath, DesPcID : string;
  protected
    VstShareFile : TVirtualStringTree;
    ParentNode : PVirtualNode;
    ParentData : PVstShareFolderData;
  public
    constructor Create( _ParentPath, _DesPcID : string );
  protected
    function FindVstShareFile : Boolean;
    function FindParentNode : Boolean;
  end;

    // 添加
  TVstShareFileAdd = class( TVstShareFileWrite )
  public
    FilePath : string;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string; _IsFolder : Boolean );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;override;
  end;

    // 添加完成
  TVstShareFileCompleted = class( TVstShareFileWrite )
  private
    IsShareCancel : Boolean;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 下载的共享路径历史 ' }

    // 数据结构
  TVstShareDownData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
    SavePath : WideString;
    FileSize, CompletedSize : Int64;
    Status : WideString;
    IsDesPcOnline : Boolean;
  public
    IsIncompleted : Boolean;
  end;
  PVstShareDownData = ^TVstShareDownData;

    // 父类
  TVstShareDownChange = class( TChangeInfo )
  public
    VstShareDown : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // 修改
  TVstShareDownWrite = class( TVstShareDownChange )
  public
    FullPath, DesPcID : string;
  protected
    ShareDownNode : PVirtualNode;
    ShareDownData : PVstShareDownData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindShareDownNode : Boolean;
    procedure RefreshShareDownNode;
  end;

  VstShareDownUtil = class
  public
    class function getNodeIcon( Node : PVirtualNode ): Integer;
    class function getIsFreeLimit( Node : PVirtualNode ): Boolean;
  end;

  {$Region ' 修改 根节点 ' }

    // 添加
  TVstShareDownAdd = class( TVstShareDownWrite )
  private
    DesPcName : string;
    PathType : string;
    SavePath : string;
    FileSize, CompletedSize : Int64;
    IsDecPcOnline : Boolean;
    Status : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetPathType( _PathType : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetIsDecPcOnline( _IsDecPcOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 添加 文件空间
  TVstShareDownAddFileSize = class( TVstShareDownWrite )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成空间
  TVstShareDownAddCompletedSize = class( TVstShareDownWrite )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 已完成空间
  TVstShareDownSetCompletedSize = class( TVstShareDownWrite )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // Pc 上/下线
  TVstShareDownIsOnline = class( TVstShareDownWrite )
  public
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  private
    procedure SetToChildNode;
  end;

    // 设置 状态
  TVstShareDownSetStatus = class( TVstShareDownWrite )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 根据界面 取消 Job
  TVstShareDownClearJob = class( TVstShareDownWrite )
  public
    procedure Update;override;
  private
    procedure RemoveJob( ChildPath : string );
  end;

    // 清空 子节点
  TVstShareDownClearChild = class( TVstShareDownWrite )
  public
    procedure Update;override;
  end;

    // 删除
  TVstShareDownRemove = class( TVstShareDownWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子节点 ' }

    // 修改
  TVstShareDownChildChange = class( TVstShareDownWrite )
  public
    FilePath : string;
  private
    FileNode : PVirtualNode;
    FileData : PVstShareDownData;
  public
    procedure SetFilePath( _FilePath : string );
  private
    function FindFileNode : Boolean;
    procedure RefreshFileNode;
    function getIsFileNode : Boolean;
  end;

    // 添加
  TVstShareDownChildAdd = class( TVstShareDownChildChange )
  private
    DesPcName : string;
    FileSize, CompletedSize : Int64;
    IsDecPcOnline : Boolean;
    SavePath : string;
    Status : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetIsPcOnline( _IsDecPcOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure SetSavePath( _SavePath : string );
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

    // 添加 已完成空间
  TVstShareDownChildAddCompletedSize = class( TVstShareDownChildChange )
  public
    CompletedSize : Integer;
  public
    procedure SetCompletedSize( _CompletedSize : Integer );
    procedure Update;override;
  end;

    // 设置 已完成空间
  TVstShareDownChildSetCompletedSize = class( TVstShareDownChildChange )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 下载状态
  TVstShareDownChildSetStatus = class( TVstShareDownChildChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 删除
  TVstShareDownChildRemove = class( TVstShareDownChildChange )
  public
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Vst 在线 Pc 信息 ' }

    // 数据结构
  TVstShareFilePcData = record
  public
    PcID : WideString;
    PcName : WideString;
  public
    IsShowDownload, IsShowUpload : Boolean;
    UploadCount, DownloadCount : Integer;
  end;
  PVstShareFilePcData = ^TVstShareFilePcData;

    // 父类
  TVstShareFilePcChange = class( TChangeInfo )
  public
    VstShareFilePc : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure ResetExistSharePc( IsExist : Boolean );
  end;

    // 修改
  TVstShareFilePcWrite = class( TVstShareFilePcChange )
  public
    PcID : string;
  protected
    PcNode : PVirtualNode;
    PcData : PVstShareFilePcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
    procedure RefreshPcNode;
  end;

    // 添加
  TVstShareFilePcAdd = class( TVstShareFilePcWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // 删除
  TVstShareFilePcRemove = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // 清空
  TVstShareFileClear = class( TVstShareFilePcChange )
  public
    procedure Update;override;
  end;

  {$Region ' 上传/下载 显示 ' }

    // Pc 添加下载
  TVstShareFilePcAddDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc 删除下载
  TVstShareFilePcRemoveDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc 添加上传
  TVstShareFilePcAddUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc 删除上传
  TVstShareFilePcRemoveUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // 隐藏 Pc 下载
  TVstShareFilePcHidePcDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // 隐藏 Pc 上传
  TVstShareFilePcHidePcUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Vst FileSend Des 隐藏线程 ' }

  TVstShareFilePcHideInfo = class
  public
    PcID : string;
    StartTime : TDateTime;
  public
    constructor Create( _PcID : string );
  end;
  TVstShareFilePcHidePair = TPair< string , TVstShareFilePcHideInfo >;
  TVstShareFilePcHideHash = class(TStringDictionary< TVstShareFilePcHideInfo >);

    // 列隐藏线程
  TVstShareFilePcHideThread = class( TThread )
  private
    Lock : TCriticalSection;
    VstShareFilePcHideDownHash : TVstShareFilePcHideHash;
    VstShareFilePcHideUpHash : TVstShareFilePcHideHash;
  public
    constructor Create;
    procedure AddDownHideInfo( PcID : string );
    procedure AddUpHideInfo( PcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ExistHidePc : Boolean;
    procedure CheckLvHideDown;
    procedure CheckLvHideUp;
  end;

{$EndRegion}

    // 检测是否存在共享目录 Pc
  TVstShareFileCheckExistShare = class( TVstShareFilePcChange )
  public
    procedure Update;override;
  end;

{$EndRegion}

const
  MaxCount_History = 20;

  ShareFile_NotExist = 'Not Exist';

var
  VstShareFilePcHideThread : TVstShareFilePcHideThread;

implementation

uses UMainForm, UIconUtil, UFormSelectSharePath, UFormFileShareExplorer, UNetworkFace, UMyUtil,
     UMyShareControl, UJobControl, URegisterInfo, UFormFreeEdition;

{ TLvSharePathChange }

procedure TLvSharePathChange.Update;
begin
  VstSharePath := frmMainForm.vstSharePath;
end;

{ TLvSharePathWrite }

constructor TLvSharePathWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvSharePathWrite.FindSharePathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSharePathData;
begin
  Result := False;

  SelectNode := VstSharePath.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstSharePath.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      SharePathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLvSharePathAdd }

procedure TLvSharePathAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLvSharePathAdd.Update;
begin
  inherited;

    // 已存在
  if FindSharePathNode then
    Exit;

    // 添加
  SharePathNode := VstSharePath.AddChild( VstSharePath.RootNode );
  NodeData := VstSharePath.GetNodeData( SharePathNode );
  NodeData.FullPath := FullPath;
  NodeData.PathType := PathType;

  if VstSharePath.RootNodeCount = 1 then
    frmMainForm.vstSharePath.TreeOptions.PaintOptions := frmMainForm.vstSharePath.TreeOptions.PaintOptions - [toShowBackground];
end;

{ TLvSharePathRemove }

procedure TLvSharePathRemove.Update;
begin
  inherited;

    // 不存在
  if not FindSharePathNode then
    Exit;

    // 删除
  VstSharePath.DeleteNode( SharePathNode );

  if VstSharePath.RootNodeCount = 0 then
    frmMainForm.vstSharePath.TreeOptions.PaintOptions := frmMainForm.vstSharePath.TreeOptions.PaintOptions + [toShowBackground];
end;

{ TVstSelectSharePathChange }

procedure TVstSelectSharePathChange.Update;
begin
  vstSelectSharePath := frmSelectSharePath.vstSelectPath;
end;

{ TvstSelectSharePathWrite }

constructor TVstSelectSharePathWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TVstSelectSharePathAdd }

procedure TVstSelectSharePathAdd.Update;
begin
  inherited;

  frmSelectSharePath.AddBackupPath( FullPath );
end;

{ TVstSelectSharePathRemove }

procedure TVstSelectSharePathRemove.Update;
begin
  inherited;

  frmSelectSharePath.RemoveBackupPath( FullPath );
end;

{ TLvSharePcData }

constructor TLvSharePcData.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

{ TvstShareFileAdd }

procedure TVstShareFileAdd.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TVstShareFileAdd.SetFilePath(_FilePath: string; _IsFolder: Boolean);
begin
  FilePath := _FilePath;
  IsFolder := _IsFolder;
end;

procedure TVstShareFileAdd.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PVstShareFolderData;
begin
  inherited;

    // 找不到父节点
  if not FindParentNode then
    Exit;

    // 根节点 是文件
  if ParentPath = FilePath then
  begin
    ParentData.FileSize := FileSize;
    ParentData.FileTime := FileTime;
    Exit;
  end;

  ChildNode := VstShareFile.AddChild( ParentNode );
  ChildData := VstShareFile.GetNodeData( ChildNode );
  ChildData.FilePath := FilePath;
  ChildData.IsFolder := IsFolder;
  ChildData.FileSize := FileSize;
  ChildData.FileTime := FileTime;
  ChildData.IsWaiting := False;

    // 可以展开下一层
  if IsFolder then
    VstShareFile.HasChildren[ ChildNode ] := True;

    // Check Box
  ChildNode.CheckType := ctTriStateCheckBox;
  if ParentNode.CheckState = csCheckedNormal then
    ChildNode.CheckState := csCheckedNormal;
end;

{ TVstShareFileWrite }

constructor TVstShareFileWrite.Create(_ParentPath, _DesPcID: string);
begin
  ParentPath := _ParentPath;
  DesPcID := _DesPcID;
end;

function TVstShareFileWrite.FindParentNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFolderData;
begin
  Result := False;

    // 找不到 共享文件
  if not FindVstShareFile then
    Exit;

    // 返回根节点
  if ParentPath = '' then
  begin
    ParentNode := VstShareFile.RootNode;
    Result := True;
  end;

  SelectNode := VstShareFile.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFile.GetNodeData( SelectNode );
    if ParentPath = SelectData.FilePath then  // 找到了节点
    begin
      ParentNode := SelectNode;
      ParentData := SelectData;
      Result := True;
      Break;
    end
    else    // 找到了父节点
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else   // 下一个节点
      SelectNode := SelectNode.NextSibling;
  end;
end;

function TVstShareFileWrite.FindVstShareFile: Boolean;
begin
  VstShareFile := VstShareFolderUtil.getVstShareFiles( DesPcID );
  Result := VstShareFile <> nil;
end;

{ TVstShareFileCompleted }

procedure TVstShareFileCompleted.SetIsShareCancel(_IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TVstShareFileCompleted.Update;
var
  RemoveNode : PVirtualNode;
  RemoveData : PVstShareFolderData;
begin
  inherited;

    // 找不到 父节点
  if not FindParentNode then
    Exit;

    // 删除等待节点
  RemoveNode := ParentNode.FirstChild;
  RemoveData := VstShareFile.GetNodeData( RemoveNode );
  if RemoveData.IsWaiting then
  begin
    if IsShareCancel then
      RemoveData.FilePath := ShareFile_NotExist
    else
      VstShareFile.DeleteNode( RemoveNode );
  end;
end;

{ TVstShareDownChange }

procedure TVstShareDownChange.Update;
begin
  VstShareDown := frmMainForm.VstShareDown;
end;

{ TVstShareDownWrite }

constructor TVstShareDownWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareDownWrite.FindShareDownNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  Result := False;

  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      ShareDownNode := SelectNode;
      ShareDownData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstShareDownWrite.RefreshShareDownNode;
begin
  VstShareDown.RepaintNode( ShareDownNode );
end;

{ TVstShareDownAdd }

procedure TVstShareDownAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareDownAdd.SetIsDecPcOnline(_IsDecPcOnline: Boolean);
begin
  IsDecPcOnline := _IsDecPcOnline;
end;

procedure TVstShareDownAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareDownAdd.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TVstShareDownAdd.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownAdd.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownAdd.Update;
begin
  inherited;

    // 已存在
  if FindShareDownNode then
    Exit;

    // 创建节点
  ShareDownNode := VstShareDown.AddChild( VstShareDown.RootNode );
  ShareDownData := VstShareDown.GetNodeData( ShareDownNode );
  ShareDownData.FullPath := FullPath;
  ShareDownData.PathType := PathType;
  ShareDownData.DesPcID := DesPcID;
  ShareDownData.DesPcName := DesPcName;
  ShareDownData.SavePath := SavePath;
  ShareDownData.FileSize := FileSize;
  ShareDownData.CompletedSize := CompletedSize;
  ShareDownData.IsDesPcOnline := IsDecPcOnline;
  ShareDownData.Status := Status;
  ShareDownData.IsIncompleted := False;

    // ToolButton
  if VstShareDown.RootNodeCount = 1 then
    frmMainForm.tbtnShareDownClear.Enabled := True;
end;

{ TVstShareDownRemove }

procedure TVstShareDownRemove.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteNode( ShareDownNode );

      // ToolButton
  if VstShareDown.RootNodeCount = 0 then
    frmMainForm.tbtnShareDownClear.Enabled := False;
end;

{ TVstShareDownAddFileSize }

procedure TVstShareDownAddFileSize.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TVstShareDownAddFileSize.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  ShareDownData.FileSize := ShareDownData.FileSize + FileSize;
  RefreshShareDownNode;
end;

{ TVstShareDownAddCompletedSize }

procedure TVstShareDownAddCompletedSize.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownAddCompletedSize.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  ShareDownData.CompletedSize := ShareDownData.CompletedSize + CompletedSize;
  RefreshShareDownNode;
end;


{ TVstShareDownChildChange }

function TVstShareDownChildChange.FindFileNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  Result := False;

    // 不存在 根
  if not FindShareDownNode then
    Exit;

    // 文件 是根
  if getIsFileNode then
  begin
    FileNode := ShareDownNode;
    FileData := ShareDownData;
    Result := True;
    Exit;
  end;

  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if SelectData.FullPath = FilePath then
    begin
      FileNode := SelectNode;
      FileData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TVstShareDownChildChange.getIsFileNode: Boolean;
begin
  Result := FilePath = FullPath;
end;

procedure TVstShareDownChildChange.RefreshFileNode;
begin
  VstShareDown.RepaintNode( FileNode );
end;

procedure TVstShareDownChildChange.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TVstShareDownChildAdd }

procedure TVstShareDownChildAdd.CheckFreeLimit;
begin
  if not App_IsFreeLimit then
    Exit;

    // 第一个节点，且 Disable
  if ( ShareDownNode.ChildCount = 1 ) and EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    ShareDownData.IsIncompleted := True;
    RefreshShareDownNode; // 刷新根节点
  end
  else
  if ShareDownData.IsIncompleted and not EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    ShareDownData.IsIncompleted := False;
    RefreshShareDownNode; // 刷新根节点
  end;
end;

procedure TVstShareDownChildAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareDownChildAdd.SetIsPcOnline(_IsDecPcOnline: Boolean);
begin
  IsDecPcOnline := _IsDecPcOnline;
end;

procedure TVstShareDownChildAdd.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TVstShareDownChildAdd.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildAdd.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownChildAdd.Update;
begin
  inherited;

    // 不存在父节点
  if not FindShareDownNode then
    Exit;

    // 文件 是根
  if getIsFileNode then
    Exit;

  FileNode := VstShareDown.AddChild( ShareDownNode );
  FileData := VstShareDown.GetNodeData( FileNode );
  FileData.FullPath := FilePath;
  FileData.PathType := SharePathType_File;
  FileData.DesPcID := DesPcID;
  FileData.DesPcName := DesPcName;
  FileData.FileSize := FileSize;
  FileData.CompletedSize := CompletedSize;
  FileData.IsDesPcOnline := IsDecPcOnline;
  FileData.Status := Status;
  FileData.SavePath := SavePath;

    // 检测 免费版限制
  CheckFreeLimit;
end;

{ TVstShareDownChildAddCompletedSize }

procedure TVstShareDownChildAddCompletedSize.SetCompletedSize(
  _CompletedSize: Integer);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildAddCompletedSize.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

    // 根节点 是文件节点
  if getIsFileNode then
    Exit;

  FileData.CompletedSize := FileData.CompletedSize + CompletedSize;

  RefreshFileNode;
end;

{ TVstShareDownChildRemove }

procedure TVstShareDownChildRemove.CheckFreeLimit;
var
  IsExistDisableNode : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  if not App_IsFreeLimit then
    Exit;

  if ShareDownData.IsIncompleted then
    Exit;

    // 是否 只存在 Disable 节点
  IsExistDisableNode := False;
  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if EditionUtil.getIsLimitShareSpace( SelectData.FileSize ) then
      IsExistDisableNode := True
    else
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // 不存在
  if not IsExistDisableNode then
    Exit;

    // 发送路径 受免费版影响
  ShareDownData.IsIncompleted := True;
  VstShareDown.RepaintNode( ShareDownNode );
  VstShareDown.Expanded[ ShareDownNode ] := True;

    // 显示 试用版限制
  frmFreeEdition.ShowWarnning( FreeEditionError_ShareDownSize );
end;

procedure TVstShareDownChildRemove.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

    // 文件 根节点
  if getIsFileNode then
  begin
//    ShareDownData.CompletedSize := ShareDownData.FileSize;
    Exit;
  end;

  VstShareDown.DeleteNode( FileNode );

    // 检测是否受免费版限制
  CheckFreeLimit;
end;

{ TVstShareDownChildSetStatus }

procedure TVstShareDownChildSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownChildSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

  FileData.Status := Status;

  RefreshFileNode;
end;

{ TLvDownSharePcChange }

procedure TLvDownSharePcChange.Update;
begin
  LvDownSharePc := frmShareExplorer.LvSharePc;
end;

{ TLvDownSharePcWrite }

constructor TLvDownSharePcWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TLvDownSharePcWrite.FindPcItem: Boolean;
var
  i : Integer;
  SelectData : TLvSharePcData;
begin
  Result := False;

  for i := 0 to LvDownSharePc.Items.Count - 1 do
  begin
    SelectData := LvDownSharePc.Items[i].Data;
    if SelectData.PcID = PcID then
    begin
      PcItem := LvDownSharePc.Items[i];
      PcData := SelectData;
      PcIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvDownSharePcAdd }

procedure TLvDownSharePcAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLvDownSharePcAdd.Update;
begin
  inherited;

    // 跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 已存在
  if FindPcItem then
    Exit;

  PcData := TLvSharePcData.Create( PcID, PcName );
  with LvDownSharePc.Items.Add do
  begin
    Caption := PcName;
    ImageIndex := CloudStatusIcon_Online;
    Data := PcData;
  end;
end;

{ TLvDownSharePcRemove }

procedure TLvDownSharePcRemove.Update;
var
  ts : TRzTabSheet;
begin
  inherited;

    // 不存在
  if not FindPcItem then
    Exit;

    // 删除 Tab
  ts := VstShareFolderUtil.getTap( PcData.PcID );
  if ts <> nil then
    ts.Destroy;

    // 删除
  LvDownSharePc.Items.Delete( PcIndex );
end;

{ TLvDownSharePcClear }

procedure TLvDownSharePcClear.Update;
var
  i : Integer;
  PcShareFiles : TRzPageControl;
begin
  inherited;

    // 清空 Pc
  LvDownSharePc.Clear;

    // 清空文件
  PcShareFiles := frmShareExplorer.PcShareFile;
  for i := PcShareFiles.PageCount - 1 downto 0 do
    PcShareFiles.Pages[i].Destroy;
end;

{ VstShareFolderUtil }

class function VstShareFolderUtil.getFrame(ts: TRzTabSheet): TFrameShareFiles;
var
  i  : Integer;
  c : TControl;
begin
  Result := nil;

  for i := 0 to ts.ControlCount - 1 do
  begin
    c := ts.Controls[i];
    if c is TFrameShareFiles then
    begin
      Result := c as TFrameShareFiles;
      Break;
    end;
  end;
end;

class function VstShareFolderUtil.getTap(DesPcID: string): TRzTabSheet;
var
  PcShareFile : TRzPageControl;
  i, j  : Integer;
  ts : TRzTabSheet;
  c : TControl;
  f : TFrameShareFiles;
begin
  Result := nil;

  PcShareFile := frmShareExplorer.PcShareFile;
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    ts := PcShareFile.Pages[i];
    for j := 0 to ts.ControlCount - 1 do
    begin
      c := ts.Controls[j];
      if c is TFrameShareFiles then
      begin
        f := c as TFrameShareFiles;
        if f.SharePcID = DesPcID then
          Result := ts;
        Break;
      end;
    end;
  end;
end;

class function VstShareFolderUtil.getVstShareFiles(
  DesPcID: string): TVirtualStringTree;
var
  PcShareFile : TRzPageControl;
  i, j  : Integer;
  ts : TRzTabSheet;
  c : TControl;
  f : TFrameShareFiles;
begin
  Result := nil;

  PcShareFile := frmShareExplorer.PcShareFile;
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    ts := PcShareFile.Pages[i];
    for j := 0 to ts.ControlCount - 1 do
    begin
      c := ts.Controls[j];
      if c is TFrameShareFiles then
      begin
        f := c as TFrameShareFiles;
        if f.SharePcID = DesPcID then
          Result := f.vstShareFiles;
        Break;
      end;
    end;
  end;
end;

{ TVstShareDownChildSetCompletedSize }

procedure TVstShareDownChildSetCompletedSize.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildSetCompletedSize.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

  FileData.CompletedSize := CompletedSize;
  RefreshFileNode;
end;

{ TVstShareDownIsOnline }

procedure TVstShareDownIsOnline.SetToChildNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    SelectData.IsDesPcOnline := IsOnline;
    VstShareDown.RepaintNode( SelectNode );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstShareDownIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareDownIsOnline.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

    // 设置 根节点
  ShareDownData.IsDesPcOnline := IsOnline;
  RefreshShareDownNode;

    // 设置 子节点
  SetToChildNode;
end;

{ VstShareDownUtil }

class function VstShareDownUtil.getIsFreeLimit(Node: PVirtualNode): Boolean;
var
  NodeData : PVstShareDownData;
begin
  Result := False;
  if not App_IsFreeLimit then
    Exit;

  NodeData := frmMainForm.VstShareDown.GetNodeData( Node );
  if NodeData.PathType = SharePathType_File then
    Result := NodeData.FileSize > FreeEditionLimit_ShareFileSize
  else
  begin
    Result := NodeData.IsIncompleted;
    if Result then
      frmMainForm.VstShareDown.Expanded[ Node ] := True;
  end;
end;

class function VstShareDownUtil.getNodeIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstShareDownData;
begin
  NodeData := frmMainForm.VstShareDown.GetNodeData( Node );
  if App_IsFreeLimit and ( Node.Parent = frmMainForm.VstShareDown.RootNode ) and
       NodeData.IsIncompleted
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.Status = FileShareStatus_Cancel then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if ( Node.Parent = frmMainForm.VstShareDown.RootNode ) and
     ( NodeData.CompletedSize >= NodeData.FileSize )
  then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if not NodeData.IsDesPcOnline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if getIsFreeLimit( Node ) then
    Result := MyShellTransActionIconUtil.getDisable
  else
  if NodeData.Status = FileShareStatus_Waiting then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.Status = FileShareStatus_Downloading then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

{ TVstShareDownSetStatus }

procedure TVstShareDownSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownSetStatus.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

    // 设置 根节点
  ShareDownData.Status := Status;
  RefreshShareDownNode;
end;

{ TVstShareDownSetCompletedSize }

procedure TVstShareDownSetCompletedSize.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownSetCompletedSize.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  ShareDownData.CompletedSize := CompletedSize;
  RefreshShareDownNode;
end;

{ TVstShareHistoryChange }

procedure TVstShareHistoryChange.RefreshClearBtn;
begin
  frmShareExplorer.tbtnShareHistoryClear.Enabled := VstShareHistory.VisibleCount > 0;

    // 显示
  if not frmShareExplorer.tbtnHistory.Visible and
     ( VstShareHistory.VisibleCount > 0 )
  then
  begin
    frmShareExplorer.tbtnHistory.Visible := True;
    if not frmShareExplorer.tbComputer.Visible then
      frmShareExplorer.tbComputer.Visible := True;
  end;
end;

procedure TVstShareHistoryChange.Update;
begin
  VstShareHistory := frmShareExplorer.VstHisroty;
end;

{ TVstShareHistoryWrite }

constructor TVstShareHistoryWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareHistoryWrite.FindPathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  Result := False;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstShareHistoryAdd }

procedure TVstShareHistoryAdd.CheckRemove;
var
  RemoveNode : PVirtualNode;
  RemoveData : PVstShareHistoryData;
begin
  if VstShareHistory.RootNodeCount <= MaxCount_History then
    Exit;

  RemoveNode := VstShareHistory.RootNode.LastChild;
  if not Assigned( RemoveNode ) then
    Exit;

    // 删除
  RemoveData := VstShareHistory.GetNodeData( RemoveNode );
  MyFileShareControl.RemoveHistory( RemoveData.FullPath, RemoveData.DesPcID );
end;

procedure TVstShareHistoryAdd.SetDesPcIsOnline(_DesPcIsOnline: Boolean);
begin
  DesPcIsOnline := _DesPcIsOnline;
end;

procedure TVstShareHistoryAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareHistoryAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareHistoryAdd.Update;
begin
  inherited;

    // 已存在
  if FindPathNode then
    Exit;

    // 添加
  PathNode := VstShareHistory.InsertNode( VstShareHistory.RootNode, amAddChildFirst );
  NodeData := VstShareHistory.GetNodeData( PathNode );
  NodeData.FullPath := FullPath;
  NodeData.DesPcID := DesPcID;
  NodeData.DesPcName := DesPcName;
  NodeData.PathType := PathType;

    // 上线则显示
  VstShareHistory.IsVisible[ PathNode ] := DesPcIsOnline;

    // 刷新清除按钮
  RefreshClearBtn;

    // 超过 20个 则删除
  CheckRemove;
end;

{ TVstShareHistoryRemove }

procedure TVstShareHistoryRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

  VstShareHistory.DeleteNode( PathNode );

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareFavorityChange }

procedure TVstShareFavorityChange.RefreshClearBtn;
begin
  frmShareExplorer.tbtnShareFavoriteClear.Enabled := VstShareFavority.VisibleCount > 0;

    // 显示
  if not frmShareExplorer.tbtnFavorite.Visible and
     ( VstShareFavority.VisibleCount > 0 )
  then
  begin
    frmShareExplorer.tbtnFavorite.Visible := True;
    if not frmShareExplorer.tbComputer.Visible then
      frmShareExplorer.tbComputer.Visible := True;
  end;
end;

procedure TVstShareFavorityChange.Update;
begin
  VstShareFavority := frmShareExplorer.VstFavorite;
end;

{ TVstShareFavorityWrite }

constructor TVstShareFavorityWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareFavorityWrite.FindPathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  Result := False;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstShareFavorityAdd }

procedure TVstShareFavorityAdd.SetDesPcIsOnline(_DesPcIsOnline: Boolean);
begin
  DesPcIsOnline := _DesPcIsOnline;
end;

procedure TVstShareFavorityAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareFavorityAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareFavorityAdd.Update;
begin
  inherited;

    // 已存在
  if FindPathNode then
    Exit;

    // 添加
  PathNode := VstShareFavority.AddChild( VstShareFavority.RootNode );
  NodeData := VstShareFavority.GetNodeData( PathNode );
  NodeData.FullPath := FullPath;
  NodeData.DesPcID := DesPcID;
  NodeData.DesPcName := DesPcName;
  NodeData.PathType := PathType;

    // 上线则显示
  VstShareFavority.IsVisible[ PathNode ] := DesPcIsOnline;

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareFavorityRemove }

procedure TVstShareFavorityRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

  VstShareFavority.DeleteNode( PathNode );

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareHistoryPcOnline }

constructor TVstShareHistoryPcOnline.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstShareHistoryPcOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareHistoryPcOnline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  inherited;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    if SelectData.DesPcID = PcID then
      VstShareHistory.IsVisible[ SelectNode ] := IsOnline;
    SelectNode := SelectNode.NextSibling;
  end;

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareFavorityPcOnline }

constructor TVstShareFavorityPcOnline.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstShareFavorityPcOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareFavorityPcOnline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  inherited;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    if SelectData.DesPcID = PcID then
      VstShareFavority.IsVisible[ SelectNode ] := IsOnline;
    SelectNode := SelectNode.NextSibling;
  end;

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareHistoryServerOffline }

procedure TVstShareHistoryServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  inherited;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    VstShareHistory.IsVisible[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareFavorityServerOffline }

procedure TVstShareFavorityServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  inherited;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    VstShareFavority.IsVisible[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;

    // 刷新清除按钮
  RefreshClearBtn;
end;

{ TVstShareDownClearJob }

procedure TVstShareDownClearJob.RemoveJob(ChildPath: string);
var
  TransferFileShareJobRemoveHandle : TTransferFileShareJobRemoveHandle;
begin
  TransferFileShareJobRemoveHandle := TTransferFileShareJobRemoveHandle.Create( ChildPath, DesPcID );
  TransferFileShareJobRemoveHandle.Update;
  TransferFileShareJobRemoveHandle.Free;
end;


procedure TVstShareDownClearJob.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PVstShareDownData;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

    // 删除 子节点的 Job
  ChildNode := ShareDownNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VstShareDown.GetNodeData( ChildNode );
    RemoveJob( ChildData.SavePath );
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TVstShareDownClearChild }

procedure TVstShareDownClearChild.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteChildren( ShareDownNode );
  VstShareDown.Expanded[ ShareDownNode ] := False;
  RefreshShareDownNode;
end;

{ TVstShareFilePcChange }

procedure TVstShareFilePcChange.ResetExistSharePc(IsExist: Boolean);
begin
  frmMainForm.tbtnShareDownAdd.Enabled := IsExist;
  frmMainForm.PlNoSharePc.Visible := not IsExist;
end;

procedure TVstShareFilePcChange.Update;
begin
  VstShareFilePc := frmMainForm.VstShareFilePc;
end;

{ TVstShareFilePcWrite }

constructor TVstShareFilePcWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TVstShareFilePcWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
begin
  Result := False;

  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      PcNode := SelectNode;
      PcData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TVstShareFilePcWrite.RefreshPcNode;
begin
  VstShareFilePc.RepaintNode( PcNode );
end;

{ TVstShareFilePcAdd }

procedure TVstShareFilePcAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstShareFilePcAdd.Update;
begin
  inherited;

    // 跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 已存在
  if FindPcNode then
    Exit;

    // 添加
  PcNode := VstShareFilePc.AddChild( VstShareFilePc.RootNode );
  PcData := VstShareFilePc.GetNodeData( PcNode );
  PcData.PcID := PcID;
  PcData.PcName := PcName;

    // 出现了共享 Pc
  if VstShareFilePc.RootNodeCount = 1 then
    ResetExistSharePc( True );
end;

{ TVstShareFilePcRemove }

procedure TVstShareFilePcRemove.Update;
begin
  inherited;

    // 不存在
  if not FindPcNode then
    Exit;

    // 删除
  VstShareFilePc.DeleteNode( PcNode );

    // 没有了共享 Pc
  if VstShareFilePc.RootNodeCount = 0 then
    ResetExistSharePc( False );
end;

{ TVstShareFileClear }

procedure TVstShareFileClear.Update;
begin
  inherited;

  VstShareFilePc.Clear;
end;

{ TVstShareFileCheckExistShare }

procedure TVstShareFileCheckExistShare.Update;
begin
  inherited;
  frmMainForm.tmrCheckExistPc.Enabled := True;
end;

{ TVstFileTransferDesAddDownload }

procedure TVstShareFilePcAddDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount + 1;

    // 显示下载列
  if ( PcData.DownloadCount = 1 ) then
  begin
    PcData.IsShowDownload := True;

    VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Download ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

    // 刷新显示
  RefreshPcNode;
end;

{ TVstFileTransferDesRemoveDownload }

procedure TVstShareFilePcRemoveDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount - 1;
  RefreshPcNode;

    // 隐藏下载列
  if ( PcData.DownloadCount = 0 ) then
    VstShareFilePcHideThread.AddDownHideInfo( PcID );
end;

{ TVstFileTransferDesRemoveUpload }

procedure TVstShareFilePcRemoveUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount - 1;
  RefreshPcNode;

    // 隐藏上传列
  if ( PcData.UploadCount = 0 ) then
    VstShareFilePcHideThread.AddUpHideInfo( PcID );
end;

{ TVstFileTransferDesAddUpload }

procedure TVstShareFilePcAddUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount + 1;

    // 显示上传列
  if ( PcData.UploadCount = 1 ) then
  begin
    PcData.IsShowUpload := True;

    VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Upload ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

  RefreshPcNode;
end;

{ TVstFileTransferDesHidePcDownload }

procedure TVstShareFilePcHidePcDownload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // 存在 下载, 跳过
  if PcData.DownloadCount > 0 then
    Exit;

    // 隐藏下载列
  PcData.IsShowDownload := False;
  RefreshPcNode;

    // 是否 所有列 都隐藏
  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.IsShowDownload then // 结束
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // 隐藏
  VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Download ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstFileTransferDesHidePcUpload }

procedure TVstShareFilePcHidePcUpload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // 显示下载列
  if PcData.UploadCount > 0 then
    Exit;

  PcData.IsShowUpload := False;
  VstShareFilePc.RepaintNode( PcNode );

    // 是否 所有列 都隐藏
  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.IsShowUpload then // 结束
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

  VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Upload ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstFileSendDesHideInfo }

constructor TVstShareFilePcHideInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  StartTime := Now;
end;

{ TVstFileSendDesHideThread }

procedure TVstShareFilePcHideThread.AddDownHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstShareFilePcHideInfo;
begin
  Lock.Enter;
  if VstShareFilePcHideDownHash.ContainsKey( PcID ) then
    VstShareFilePcHideDownHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstShareFilePcHideInfo.Create( PcID );
    VstShareFilePcHideDownHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstShareFilePcHideThread.AddUpHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstShareFilePcHideInfo;
begin
  Lock.Enter;
  if VstShareFilePcHideUpHash.ContainsKey( PcID ) then
    VstShareFilePcHideUpHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstShareFilePcHideInfo.Create( PcID );
    VstShareFilePcHideUpHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstShareFilePcHideThread.CheckLvHideDown;
var
  RemoveList : TStringList;
  p : TVstShareFilePcHidePair;
  VstShareFilePcHidePcDownload : TVstShareFilePcHidePcDownload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstShareFilePcHideDownHash do
  begin
      // 没有到隐藏的时间, 跳过
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // 添加 隐藏
    RemoveList.Add( p.Value.PcID );
  end;
    // 遍历 隐藏
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstShareFilePcHideDownHash.Remove( PcID );
          // 隐藏 下载
    VstShareFilePcHidePcDownload := TVstShareFilePcHidePcDownload.Create( PcID );
    MyFaceChange.AddChange( VstShareFilePcHidePcDownload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;

procedure TVstShareFilePcHideThread.CheckLvHideUp;
var
  RemoveList : TStringList;
  p : TVstShareFilePcHidePair;
  VstShareFilePcHidePcUpload : TVstShareFilePcHidePcUpload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstShareFilePcHideUpHash do
  begin
      // 没有到隐藏的时间, 跳过
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // 添加 隐藏
    RemoveList.Add( p.Value.PcID );
  end;
    // 遍历 隐藏
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstShareFilePcHideUpHash.Remove( PcID );
          // 隐藏 下载
    VstShareFilePcHidePcUpload := TVstShareFilePcHidePcUpload.Create( PcID );
    MyFaceChange.AddChange( VstShareFilePcHidePcUpload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;


constructor TVstShareFilePcHideThread.Create;
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;
  VstShareFilePcHideDownHash := TVstShareFilePcHideHash.Create;
  VstShareFilePcHideUpHash := TVstShareFilePcHideHash.Create;
end;

destructor TVstShareFilePcHideThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  VstShareFilePcHideDownHash.Free;
  VstShareFilePcHideUpHash.Free;
  Lock.Free;
  inherited;
end;

procedure TVstShareFilePcHideThread.Execute;
begin
  while not Terminated do
  begin
    if not ExistHidePc then
    begin
      Suspend;
      Continue;
    end;

    if Terminated then
      Break;

    CheckLvHideDown;
    CheckLvHideUp;

    Sleep(100);
  end;

  inherited;
end;


function TVstShareFilePcHideThread.ExistHidePc: Boolean;
begin
  Lock.Enter;
  Result := ( VstShareFilePcHideDownHash.Count > 0 ) or
            ( VstShareFilePcHideUpHash.Count > 0 );
  Lock.Leave;
end;


end.


