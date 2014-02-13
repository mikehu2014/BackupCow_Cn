unit UMyShareControl;

interface

uses SysUtils, VirtualTrees, Classes, ComCtrls, uDebug;

type

{$Region ' 修改 共享路径 ' }

    // 修改
  TSharePathChangeHandle = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  protected
    procedure RefreshIsShareFolder;
  end;

    // 读取
  TSharePathReadHandle = class( TSharePathChangeHandle )
  public
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TSharePathAddHandle = class( TSharePathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TSharePathRemoveHandle = class( TSharePathChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 修改 下载共享 ' }

    // 父类
  TShareFileDownChangeHandle = class
  public
    DesPcID : string;
    ParentPath : string;
  public
    constructor Create( _DesPcID, _ParentPath : string );
  end;

  {$Region ' 修改 根节点 ' }

  {$Region ' 增/删/改 ' }

    // 读取
  TShareFileDownReadHanlde = class( TShareFileDownChangeHandle )
  private
    PathType : string;
    SavePath : string;
    FileSize, CompletedSize : Int64;
    Status : string;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetStatus( _Status : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TShareFileDownAddHanlde = class( TShareFileDownReadHanlde )
  public
    procedure Update;override;
  protected
    procedure AddToXml;
  end;

    // 添加 FileSize
  TShareFileDownAddFileSizeHandle = class( TShareFileDownChangeHandle )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;
  private
    procedure AddToXml;
    procedure AddToFace;
  end;

    // 添加 CompletedSize
  TShareFileDownAddCompletedSizeHandle = class( TShareFileDownChangeHandle )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;
  private
    procedure AddToXml;
    procedure AddToFace;
  end;

      // 设置 状态
  TShareFileDownSetStatusHandle = class( TShareFileDownChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 删除
  TShareFileDownRemoveHandle = class( TShareFileDownChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 其他 ' }

    // Pc 上/下线
  TShareFileDownIsOnlineHandle = class( TShareFileDownChangeHandle )
  public
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 删除 Job
  TShareFileDownRemoveChildJobHandle = class( TShareFileDownChangeHandle )
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 清空 子节点
  TShareFileDownClearChildHandle = class( TShareFileDownChangeHandle )
  public
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 确认是否 取消备份
  TShareFileDownConfirmCancelHandle = class( TShareFileDownChangeHandle )
  public
    procedure Update;
  private
    procedure AddToMsg;
  end;

    // 获取 文件 List 完成
  TShareDownGetListCompletedHandle = class( TShareFileDownChangeHandle )
  private
    IsShareCancel : Boolean;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 获取 文件 下载 完成
  TShareDownGetDownCompletedHandle = class( TShareFileDownChangeHandle )
  private
    IsShareCancel : Boolean;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;
  private
    procedure SetToStatus;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' 修改 子节点 ' }

    // 修改
  TShareFileDownChildChangeHandle = class( TShareFileDownChangeHandle )
  protected
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 读取
  TShareFileDownChildReadHandle = class( TShareFileDownChildChangeHandle )
  protected
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
    Status : string;
  private
    SavePath : string;
  public
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetStatus( _Status : string );
    procedure Update;virtual;
  protected
    procedure AddToFace;
    procedure AddToJob;
    procedure AddToDisableInfo;
  end;

    // 添加
  TShareFileDownChildAddHandle = class( TShareFileDownChildReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 添加 已完成 空间信息
  TShareFileDownChildAddCompletedSizeHandle = class( TShareFileDownChildChangeHandle )
  private
    CompletedSize : Integer;
  public
    procedure SetCompletedSize( _CompletedSize : Integer );
    procedure Update;
  private
    procedure AddToFace;
  end;

    // 设置 已完成 空间信息, 续传
  TShareFileDownChildSetCompletedSizeHandle = class( TShareFileDownChildChangeHandle )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 设置状态
  TShareFileDownChildSetStatusHandle = class( TShareFileDownChildChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 删除
  TShareFileDownChildRemoveHandle = class( TShareFileDownChildChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' 外部接口 ' }

    // Pc 上/下线 调用
  TShareDownFilePcIsOnlineHandle = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  end;

    // 服务器 离线
  TShareDownServerOfflineHandle = class
  public
    procedure Update;
  private
    procedure SetOffline( DesPcID, FullPath : string );
  end;

    // 返回 文件
  TShareExplorerFileAddHandle = class
  public
    ParentPath, DesPcID : string;
    FilePath : string;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _ParentPath, _DesPcID : string );
    procedure SetFilePath( _FilePath : string; _IsFolder : Boolean );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;
  private
    procedure AddToFace;
  end;

      // 传输过程断线
  TShareDownFileLostConnHandle = class( TShareFileDownChildChangeHandle )
  public
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure Update;
  end;

    // 共享方取消共享
  TShareDownShareCancelHandle = class( TShareFileDownChangeHandle )
  public
    procedure Update;
  private
    procedure ClearChild;
    procedure SetCancelStatus;
  end;

    // 试用版变注册版 调用
  TShareDownResetFreeLimitHandle = class
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 下载历史路径 ' }

    // 修改
  TShareHistoryChangeHandle = class
  public
    FullPath : string;
    DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
  end;

    // 读取
  TShareHistoryReadHandle = class( TShareHistoryChangeHandle )
  protected
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;virtual;
  protected
    procedure AddToFace;
  end;

    // 添加
  TShareHistoryAddHandle = class( TShareHistoryReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareHistoryRemoveHandle = class( TShareHistoryChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // Pc 上/下线
  TShareHistoryPcOnlineHandle = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 服务器 离线
  TShareHistoryServerOfflineHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 下载我的收藏路径 ' }

    // 修改
  TShareFavorityChangeHandle = class
  public
    FullPath : string;
    DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
  end;

    // 读取
  TShareFavorityReadHandle = class( TShareFavorityChangeHandle )
  protected
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;virtual;
  protected
    procedure AddToFace;
  end;

    // 添加
  TShareFavorityAddHandle = class( TShareFavorityReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TShareFavorityRemoveHandle = class( TShareFavorityChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

      // Pc 上/下线
  TShareFavorityPcOnlineHandle = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 服务器 离线
  TShareFavorityServerOfflineHandle = class
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 是否共享了路径 ' }

    // 发送 是否 共享目录
  TSharePcSendIsShareHandle = class
  public
    IsShareFolder : Boolean;
  public
    constructor Create( _IsShareFolder : Boolean );
    procedure Update;
  end;

    // 接收 是否 共享目录
  TSharePcRevIsShareHandle = class
  public
    PcID, PcName : string;
    IsShareFolder : Boolean;
  public
    constructor Create( _PcID, _PcName : string );
    procedure SetIsShareFolder( _IsShareFolder : Boolean );
    procedure Update;
  private
    procedure AddToSelectLvPc;
    procedure AddToShowVstPc;
  private
    procedure RemoveFromSelectLvPc;
    procedure RemoveFromShowVstPc;
  end;

{$EndRegion}

{$Region ' 辅助类 ' }

    // 找寻下载路径
  TFindDownSavePath = class
  public
    FullPath : string;
    SavePath : string;
    DownPcID : string;
  public
    constructor Create( _FullPath, _SavePath : string );
    procedure SetDownPcID( _DownPcID : string );
    function get : string;
  private
    function ExistPath( Path : string ): Boolean;
  end;

    // 删除 冲突的 Share Down
  TRemoveShareDownConflict = class
  public
    FullPath : string;
    DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
    procedure Update;
  end;

    // 删除 冲突的 Share Path
  TRemoveExistSharePath = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
    function Update : Boolean;
  end;

    // 删除 冲突的 下载历史
  TRemoveExistShareHistory = class
  public
    FullPath : string;
    DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
    procedure Update;
  end;

    // 删除 冲突的 下载收藏夹
  TRemoveExistShareFavorite = class
  public
    FullPath : string;
    DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
    procedure Update;
  end;

{$EndRegion}

  TMyFileShareControl = class
  public         // 请求方调用
    procedure GetFileShareList( DesPcID, ParentPath : string );
    procedure GetFileShareDown( DesPcID, ParentPath : string );
  public         // 共享路径
    procedure AddSharePath( FullPath : string );
    procedure RemoveSharePath( FullPath : string );
  public         // 共享下载
    procedure AddShareDown( FullPath, DesPcID, SavePath : string; IsFolder : Boolean );
    procedure AddShareDownAgain( FullPath, DesPcID, SavePath, PathType : string );
    procedure RemoveShareDown( FullPath, DesPcID : string );
  public         // 下载历史
    procedure AddHistory( FullPath, DesPcID : string; IsFolder : Boolean );
    procedure RemoveHistory( FullPath, DesPcID : string );
  public         // 我的收藏夹
    procedure AddFavorite( FullPath, DesPcID : string; IsFolder : Boolean );
    procedure RemoveFavorite( FullPath, DesPcID : string );
  end;

const
  SharePathType_File = 'File';
  SharePathType_Folder = 'Folder';

  FileShareStatus_Waiting = 'Waiting';
  FileShareStatus_Downloading = 'Downloading';
  FileShareStatus_Offline = 'Offline';
  FileShareStatus_Completed= 'Completed';
  FileShareStatus_Cancel = 'Cancel';
  FileShareStatus_FreeLimit = 'Disable';
  FileShareStatus_Incompleted= 'Incompleted';

  FileShareStatus_CancelShow = 'Share Removed';
var
  IsConfirmAdd_ShareDown : Boolean;

var
  MyFileShareControl : TMyFileShareControl;

implementation

uses UMyClient, UMyNetPcInfo, UMyShareInfo, UMyShareFace, UMyShareXml, UMyShareScan, UMyUtil,
     UJobControl, UMainForm, UFormFileShareExplorer, URegisterInfo, UChangeInfo;

{ TMyShareControl }

procedure TMyFileShareControl.AddFavorite(FullPath, DesPcID: string;
  IsFolder: Boolean);
var
  RemoveExistShareFavorite : TRemoveExistShareFavorite;
  ShareFavorityAddHandle : TShareFavorityAddHandle;
  PathType : string;
begin
    // 删除 相同的
  RemoveExistShareFavorite := TRemoveExistShareFavorite.Create( FullPath, DesPcID );
  RemoveExistShareFavorite.Update;
  RemoveExistShareFavorite.Free;

    // 路径类型
  if IsFolder then
    PathType := SharePathType_Folder
  else
    PathType := SharePathType_File;

    // 添加
  ShareFavorityAddHandle := TShareFavorityAddHandle.Create( FullPath, DesPcID );
  ShareFavorityAddHandle.SetPathType( PathType );
  ShareFavorityAddHandle.Update;
  ShareFavorityAddHandle.Free;
end;

procedure TMyFileShareControl.AddHistory(FullPath, DesPcID: string;
  IsFolder: Boolean);
var
  RemoveExistShareHistory : TRemoveExistShareHistory;
  ShareHistoryAddHandle : TShareHistoryAddHandle;
  PathType : string;
begin
    // 删除相同的
  RemoveExistShareHistory := TRemoveExistShareHistory.Create( FullPath, DesPcID );
  RemoveExistShareHistory.Update;
  RemoveExistShareHistory.Free;

    // 路径类型
  if IsFolder then
    PathType := SharePathType_Folder
  else
    PathType := SharePathType_File;

    // 添加
  ShareHistoryAddHandle := TShareHistoryAddHandle.Create( FullPath, DesPcID );
  ShareHistoryAddHandle.SetPathType( PathType );
  ShareHistoryAddHandle.Update;
  ShareHistoryAddHandle.Free;
end;

procedure TMyFileShareControl.AddShareDown(FullPath, DesPcID, SavePath: string;
  IsFolder : Boolean);
var
  PathType : string;
  FindDownSavePath : TFindDownSavePath;
  RemoveShareDownConfilect : TRemoveShareDownConflict;
  ShareFileDownAddHanlde : TShareFileDownAddHanlde;
begin
    // 路径类型
  if IsFolder then
    PathType := SharePathType_Folder
  else
    PathType := SharePathType_File;

    // 保存位置
  FindDownSavePath := TFindDownSavePath.Create( FullPath, SavePath );
  FindDownSavePath.SetDownPcID( DesPcID );
  SavePath := FindDownSavePath.get;
  FindDownSavePath.Free;

    // 删除 冲突项
  RemoveShareDownConfilect := TRemoveShareDownConflict.Create( FullPath, DesPcID );
  RemoveShareDownConfilect.Update;
  RemoveShareDownConfilect.Free;

    // 添加
  ShareFileDownAddHanlde := TShareFileDownAddHanlde.Create( DesPcID, FullPath );
  ShareFileDownAddHanlde.SetPathType( PathType );
  ShareFileDownAddHanlde.SetSavePath( SavePath );
  ShareFileDownAddHanlde.SetSizeInfo( 0, 0 );
  ShareFileDownAddHanlde.SetStatus( FileShareStatus_Downloading );
  ShareFileDownAddHanlde.Update;
  ShareFileDownAddHanlde.Free;
end;

procedure TMyFileShareControl.AddShareDownAgain(FullPath, DesPcID, SavePath,
  PathType: string);
var
  RemoveExistShareDown : TRemoveShareDownConflict;
  ShareFileDownAddHanlde : TShareFileDownAddHanlde;
begin
    // 删除 冲突项
  RemoveExistShareDown := TRemoveShareDownConflict.Create( FullPath, DesPcID );
  RemoveExistShareDown.Update;
  RemoveExistShareDown.Free;

    // 添加
  ShareFileDownAddHanlde := TShareFileDownAddHanlde.Create( DesPcID, FullPath );
  ShareFileDownAddHanlde.SetPathType( PathType );
  ShareFileDownAddHanlde.SetSavePath( SavePath );
  ShareFileDownAddHanlde.SetSizeInfo( 0, 0 );
  ShareFileDownAddHanlde.SetStatus( FileShareStatus_Downloading );
  ShareFileDownAddHanlde.Update;
  ShareFileDownAddHanlde.Free;
end;

procedure TMyFileShareControl.AddSharePath(FullPath: string);
var
  RemoveExistSharePath : TRemoveExistSharePath;
  IsAdd : Boolean;
  ErrorStr : string;
  PathType : string;
  SharePathAddHandle : TSharePathAddHandle;
begin
    // 删除 子路径
  RemoveExistSharePath := TRemoveExistSharePath.Create( FullPath );
  IsAdd := RemoveExistSharePath.Update;
  RemoveExistSharePath.Free;

    // 存在 父路径
  if not IsAdd then
  begin
    ErrorStr := Format( ShowForm_SharePathExist, [FullPath] );
    MyMessageBox.ShowWarnning( ErrorStr );
    Exit;
  end;

    // 路径类型
  if FileExists( FullPath ) then
    PathType := SharePathType_File
  else
    PathType := SharePathType_Folder;

    // 添加
  SharePathAddHandle := TSharePathAddHandle.Create( FullPath );
  SharePathAddHandle.SetPathType( PathType );
  SharePathAddHandle.Update;
  SharePathAddHandle.Free;
end;

procedure TMyFileShareControl.GetFileShareDown(DesPcID, ParentPath: string);
var
  ClientSendShareDownReqMsg : TClientSendShareDownReqMsg;
begin
  ClientSendShareDownReqMsg := TClientSendShareDownReqMsg.Create;
  ClientSendShareDownReqMsg.SetPcID( PcInfo.PcID );
  ClientSendShareDownReqMsg.SetDownloadPath( ParentPath );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareDownReqMsg );
end;

procedure TMyFileShareControl.GetFileShareList(DesPcID, ParentPath: string);
var
  ClientSendShareListReqMsg : TClientSendShareListReqMsg;
begin
  ClientSendShareListReqMsg := TClientSendShareListReqMsg.Create;
  ClientSendShareListReqMsg.SetPcID( PcInfo.PcID );
  ClientSendShareListReqMsg.SetParentPath( ParentPath );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareListReqMsg );
end;

procedure TMyFileShareControl.RemoveFavorite(FullPath, DesPcID: string);
var
  ShareFavorityRemoveHandle : TShareFavorityRemoveHandle;
begin
  ShareFavorityRemoveHandle := TShareFavorityRemoveHandle.Create( FullPath, DesPcID );
  ShareFavorityRemoveHandle.Update;
  ShareFavorityRemoveHandle.Free;
end;

procedure TMyFileShareControl.RemoveHistory(FullPath, DesPcID: string);
var
  ShareHistoryRemoveHandle : TShareHistoryRemoveHandle;
begin
  ShareHistoryRemoveHandle := TShareHistoryRemoveHandle.Create( FullPath, DesPcID );
  ShareHistoryRemoveHandle.Update;
  ShareHistoryRemoveHandle.Free;
end;

procedure TMyFileShareControl.RemoveShareDown(FullPath, DesPcID: string);
var
  ShareFileDownRemoveHandle : TShareFileDownRemoveHandle;
begin
    // 删除 节点
  ShareFileDownRemoveHandle := TShareFileDownRemoveHandle.Create( DesPcID, FullPath );
  ShareFileDownRemoveHandle.Update;
  ShareFileDownRemoveHandle.Free;
end;

procedure TMyFileShareControl.RemoveSharePath(FullPath: string);
var
  SharePathRemoveHandle : TSharePathRemoveHandle;
begin
  SharePathRemoveHandle := TSharePathRemoveHandle.Create( FullPath );
  SharePathRemoveHandle.Update;
  SharePathRemoveHandle.Free;
end;

{ TSharePathChangeHandle }

constructor TSharePathChangeHandle.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TSharePathChangeHandle.RefreshIsShareFolder;
var
  SharePcSendIsShareHandle : TSharePcSendIsShareHandle;
  IsSharePath : Boolean;
begin
    // 读取 是否存在共享路径
  IsSharePath := MySharePathInfoReadUtil.ReadIsExistShare;

    // 发送 给所有 Pc
  SharePcSendIsShareHandle := TSharePcSendIsShareHandle.Create( IsSharePath );
  SharePcSendIsShareHandle.Update;
  SharePcSendIsShareHandle.Free;
end;

{ TSharePathReadHandle }

procedure TSharePathReadHandle.AddToFace;
var
  LvSharePathAdd : TLvSharePathAdd;
  VstSelectSharePathAdd : TVstSelectSharePathAdd;
begin
  LvSharePathAdd := TLvSharePathAdd.Create( FullPath );
  LvSharePathAdd.SetPathType( PathType );
  MyFaceChange.AddChange( LvSharePathAdd );

  VstSelectSharePathAdd := TVstSelectSharePathAdd.Create( FullPath );
  MyFaceChange.AddChange( VstSelectSharePathAdd );
end;

procedure TSharePathReadHandle.AddToInfo;
var
  SharePathAddInfo : TSharePathAddInfo;
begin
  SharePathAddInfo := TSharePathAddInfo.Create( FullPath );
  SharePathAddInfo.SetPathType( PathType );
  SharePathAddInfo.Update;
  SharePathAddInfo.Free;
end;

procedure TSharePathReadHandle.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TSharePathReadHandle.Update;
begin
  AddToInfo;

  AddToFace;
end;

{ TSharePathAddHandle }

procedure TSharePathAddHandle.AddToXml;
var
  SharePathAddXml : TSharePathAddXml;
begin
  SharePathAddXml := TSharePathAddXml.Create( FullPath );
  SharePathAddXml.SetPathType( PathType );
  MyXmlChange.AddChange( SharePathAddXml );
end;

procedure TSharePathAddHandle.Update;
begin
  inherited;

  AddToXml;

  RefreshIsShareFolder;
end;

{ TSharePathRemoveHandle }

procedure TSharePathRemoveHandle.RemoveFromFace;
var
  LvSharePathRemove : TLvSharePathRemove;
  VstSelectSharePathRemove : TVstSelectSharePathRemove;
begin
  LvSharePathRemove := TLvSharePathRemove.Create( FullPath );
  MyFaceChange.AddChange( LvSharePathRemove );

  VstSelectSharePathRemove := TVstSelectSharePathRemove.Create( FullPath );
  MyFaceChange.AddChange( VstSelectSharePathRemove );
end;

procedure TSharePathRemoveHandle.RemoveFromInfo;
var
  SharePathRemoveInfo : TSharePathRemoveInfo;
begin
  SharePathRemoveInfo := TSharePathRemoveInfo.Create( FullPath );
  SharePathRemoveInfo.Update;
  SharePathRemoveInfo.Free;
end;

procedure TSharePathRemoveHandle.RemoveFromXml;
var
  SharePathRemoveXml : TSharePathRemoveXml;
begin
  SharePathRemoveXml := TSharePathRemoveXml.Create( FullPath );
  MyXmlChange.AddChange( SharePathRemoveXml );
end;

procedure TSharePathRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;

  RefreshIsShareFolder;
end;

{ TShareFileListAddHandle }

procedure TShareExplorerFileAddHandle.AddToFace;
var
  VstShareFileAdd : TVstShareFileAdd;
begin
  VstShareFileAdd := TVstShareFileAdd.Create( ParentPath, DesPcID );
  VstShareFileAdd.SetFilePath( FilePath, IsFolder );
  VstShareFileAdd.SetFileInfo( FileSize, FileTime );
  MyFaceChange.AddChange( VstShareFileAdd );
end;

constructor TShareExplorerFileAddHandle.Create(_ParentPath, _DesPcID: string);
begin
  ParentPath := _ParentPath;
  DesPcID := _DesPcID;
end;

procedure TShareExplorerFileAddHandle.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TShareExplorerFileAddHandle.SetFilePath(_FilePath: string;
  _IsFolder: Boolean);
begin
  FilePath := _FilePath;
  IsFolder := _IsFolder;
end;

procedure TShareExplorerFileAddHandle.Update;
begin
  AddToFace;
end;

{ TShareFileDownAddHanlde }

procedure TShareFileDownAddHanlde.AddToXml;
var
  ShareDownAddXml : TShareDownAddXml;
begin
  ShareDownAddXml := TShareDownAddXml.Create( DesPcID, ParentPath );
  ShareDownAddXml.SetPathType( PathType );
  ShareDownAddXml.SetSavePath( SavePath );
  ShareDownAddXml.SetSizeInfo( FileSize, CompletedSize );
  ShareDownAddXml.SetStatus( Status );
  MyXmlChange.AddChange( ShareDownAddXml );
end;

procedure TShareFileDownAddHanlde.Update;
begin
  inherited;

  AddToXml;
end;

{ TShareFileDownChangeHandle }

constructor TShareFileDownChangeHandle.Create(_DesPcID, _ParentPath: string);
begin
  DesPcID := _DesPcID;
  ParentPath := _ParentPath;
end;

{ TShareFileDownReadHanlde }

procedure TShareFileDownReadHanlde.AddToFace;
var
  DesPcName : string;
  DesPcIsOnline : Boolean;
  VstShareDownAdd : TVstShareDownAdd;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );

  VstShareDownAdd := TVstShareDownAdd.Create( ParentPath, DesPcID );
  VstShareDownAdd.SetDesPcName( DesPcName );
  VstShareDownAdd.SetPathType( PathType );
  VstShareDownAdd.SetSavePath( SavePath );
  VstShareDownAdd.SetSizeInfo( FileSize, CompletedSize );
  VstShareDownAdd.SetIsDecPcOnline( DesPcIsOnline );
  VstShareDownAdd.SetStatus( Status );

  MyFaceChange.AddChange( VstShareDownAdd );
end;

procedure TShareFileDownReadHanlde.AddToInfo;
var
  ShareDownAddInfo : TShareDownAddInfo;
begin
  ShareDownAddInfo := TShareDownAddInfo.Create( DesPcID, ParentPath );
  ShareDownAddInfo.SetSavePath( SavePath );
  ShareDownAddInfo.Update;
  ShareDownAddInfo.Free;
end;

procedure TShareFileDownReadHanlde.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareFileDownReadHanlde.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareFileDownReadHanlde.SetSizeInfo(_FileSize,
  _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareFileDownReadHanlde.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareFileDownReadHanlde.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TShareFileDownRemoveHandle }

procedure TShareFileDownRemoveHandle.RemoveFromFace;
var
  VstShareDownRemove : TVstShareDownRemove;
begin
  VstShareDownRemove := TVstShareDownRemove.Create( ParentPath, DesPcID );
  MyFaceChange.AddChange( VstShareDownRemove );
end;

procedure TShareFileDownRemoveHandle.RemoveFromInfo;
var
  ShareDownRemoveInfo : TShareDownRemoveInfo;
begin
  ShareDownRemoveInfo := TShareDownRemoveInfo.Create( DesPcID, ParentPath );
  ShareDownRemoveInfo.Update;
  ShareDownRemoveInfo.Free;
end;

procedure TShareFileDownRemoveHandle.RemoveFromXml;
var
  ShareDownRemoveXml : TShareDownRemoveXml;
begin
  ShareDownRemoveXml := TShareDownRemoveXml.Create( DesPcID, ParentPath );
  MyXmlChange.AddChange( ShareDownRemoveXml );
end;

procedure TShareFileDownRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TShareFileDownAddFileSizeHandle }

procedure TShareFileDownAddFileSizeHandle.AddToFace;
var
  VstShareDownAddFileSize : TVstShareDownAddFileSize;
begin
  VstShareDownAddFileSize := TVstShareDownAddFileSize.Create( ParentPath, DesPcID );
  VstShareDownAddFileSize.SetFileSize( FileSize );
  MyFaceChange.AddChange( VstShareDownAddFileSize );
end;

procedure TShareFileDownAddFileSizeHandle.AddToXml;
var
  ShareDownAddFileSizeXml : TShareDownAddFileSizeXml;
begin
  ShareDownAddFileSizeXml := TShareDownAddFileSizeXml.Create( DesPcID, ParentPath );
  ShareDownAddFileSizeXml.SetFileSize( FileSize );
  MyXmlChange.AddChange( ShareDownAddFileSizeXml );
end;

procedure TShareFileDownAddFileSizeHandle.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TShareFileDownAddFileSizeHandle.Update;
begin
  AddToXml;

  AddToFace;
end;

{ TShareFileDownAddCompletedSizeHandle }

procedure TShareFileDownAddCompletedSizeHandle.AddToFace;
var
  VstShareDownAddCompletedSize : TVstShareDownAddCompletedSize;
begin
  VstShareDownAddCompletedSize := TVstShareDownAddCompletedSize.Create( ParentPath, DesPcID );
  VstShareDownAddCompletedSize.SetCompletedSize( CompletedSize );
  MyFaceChange.AddChange( VstShareDownAddCompletedSize );
end;

procedure TShareFileDownAddCompletedSizeHandle.AddToXml;
var
  ShareDownAddCompletedSizeXml : TShareDownAddCompletedSizeXml;
begin
  ShareDownAddCompletedSizeXml := TShareDownAddCompletedSizeXml.Create( DesPcID, ParentPath );
  ShareDownAddCompletedSizeXml.SetCompletedSize( CompletedSize );
  MyXmlChange.AddChange( ShareDownAddCompletedSizeXml );
end;

procedure TShareFileDownAddCompletedSizeHandle.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareFileDownAddCompletedSizeHandle.Update;
begin
  AddToXml;

  AddToFace;
end;

{ TShareFileDownChildChangeHandle }

procedure TShareFileDownChildChangeHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TShareFileDownChildReadHandle }

procedure TShareFileDownChildReadHandle.AddToDisableInfo;
var
  ShareDownDisableAddInfo : TShareDownDisableAddInfo;
begin
  ShareDownDisableAddInfo := TShareDownDisableAddInfo.Create( DesPcID, FilePath );
  ShareDownDisableAddInfo.SetSavePath( SavePath );
  ShareDownDisableAddInfo.SetSizeInfo( FileSize, CompletedSize );
  ShareDownDisableAddInfo.SetFileTime( FileTime );
  ShareDownDisableAddInfo.Update;
  ShareDownDisableAddInfo.Free;
end;

procedure TShareFileDownChildReadHandle.AddToFace;
var
  DesPcName : string;
  DesPcIsOnline : Boolean;
  VstShareDownChildAdd : TVstShareDownChildAdd;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );

  VstShareDownChildAdd := TVstShareDownChildAdd.Create( ParentPath, DesPcID );
  VstShareDownChildAdd.SetFilePath( FilePath );
  VstShareDownChildAdd.SetDesPcName( DesPcName );
  VstShareDownChildAdd.SetSizeInfo( FileSize, CompletedSize );
  VstShareDownChildAdd.SetIsPcOnline( DesPcIsOnline );
  VstShareDownChildAdd.SetStatus( Status );
  VstShareDownChildAdd.SetSavePath( SavePath );
  MyFaceChange.AddChange( VstShareDownChildAdd );
end;

procedure TShareFileDownChildReadHandle.AddToJob;
var
  TransferShareJobAddHandle : TTransferShareJobAddHandle;
begin
    // 添加 到 Job
  TransferShareJobAddHandle := TTransferShareJobAddHandle.Create( FilePath, DesPcID );
  TransferShareJobAddHandle.SetFileInfo( FileSize, CompletedSize, FileTime );
  TransferShareJobAddHandle.SetDownFilePath( SavePath );
  TransferShareJobAddHandle.Update;
  TransferShareJobAddHandle.Free;
end;

procedure TShareFileDownChildReadHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareFileDownChildReadHandle.SetSizeInfo(_FileSize,
  _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareFileDownChildReadHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareFileDownChildReadHandle.Update;
var
  RelatePath : string;
begin
    // 保存的路径
  SavePath := MyShareDownInfoReadUtil.ReadSavePath( DesPcID, ParentPath );
  RelatePath := ExtractRelativePath( MyFilePath.getPath( ParentPath ), FilePath );
  SavePath := MyFilePath.getPath( SavePath ) + RelatePath;

    // 添加到界面
  AddToFace;

    // 添加到 Job 列表
  if ( Status = FileShareStatus_Waiting ) or
     ( Status = FileShareStatus_Downloading )
  then
  begin
      // 免费版限制
    if EditionUtil.getIsLimitShareSpace( FileSize ) then
      AddToDisableInfo
    else
      AddToJob;
  end;

end;

{ TShareFileDownChildAddHandle }

procedure TShareFileDownChildAddHandle.AddToXml;
var
  ShareDownChildAddXml : TShareDownChildAddXml;
begin
  ShareDownChildAddXml := TShareDownChildAddXml.Create( DesPcID, ParentPath );
  ShareDownChildAddXml.SetFilePath( FilePath );
  ShareDownChildAddXml.SetSizeInfo( FileSize, CompletedSize );
  ShareDownChildAddXml.SetFileTime( FileTime );
  ShareDownChildAddXml.SetStatus( Status );
  MyXmlChange.AddChange( ShareDownChildAddXml );
end;

procedure TShareFileDownChildAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TShareFileDownChildAddCompletedSizeHandle }

procedure TShareFileDownChildAddCompletedSizeHandle.AddToFace;
var
  VstShareDownChildAddCompletedSize : TVstShareDownChildAddCompletedSize;
begin
  VstShareDownChildAddCompletedSize := TVstShareDownChildAddCompletedSize.Create( ParentPath, DesPcID );
  VstShareDownChildAddCompletedSize.SetFilePath( FilePath );
  VstShareDownChildAddCompletedSize.SetCompletedSize( CompletedSize );
  MyFaceChange.AddChange( VstShareDownChildAddCompletedSize );
end;

procedure TShareFileDownChildAddCompletedSizeHandle.SetCompletedSize(
  _CompletedSize: Integer);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareFileDownChildAddCompletedSizeHandle.Update;
begin
  AddToFace;
end;

{ TShareFileDownChildRemoveHandle }

procedure TShareFileDownChildRemoveHandle.RemoveFromFace;
var
  VstShareDownChildRemove : TVstShareDownChildRemove;
begin
  VstShareDownChildRemove := TVstShareDownChildRemove.Create( ParentPath, DesPcID );
  VstShareDownChildRemove.SetFilePath( FilePath );
  MyFaceChange.AddChange( VstShareDownChildRemove );
end;

procedure TShareFileDownChildRemoveHandle.RemoveFromXml;
var
  ShareDownChildRemoveXml : TShareDownChildRemoveXml;
begin
  ShareDownChildRemoveXml := TShareDownChildRemoveXml.Create( DesPcID, ParentPath );
  ShareDownChildRemoveXml.SetFilePath( FilePath );
  MyXmlChange.AddChange( ShareDownChildRemoveXml );
end;

procedure TShareFileDownChildRemoveHandle.Update;
begin
  RemoveFromFace;

  RemoveFromXml;
end;

{ TFindDownSavePath }

constructor TFindDownSavePath.Create(_FullPath, _SavePath: string);
begin
  FullPath := _FullPath;
  SavePath := _SavePath;
end;

function TFindDownSavePath.ExistPath(Path: string): Boolean;
begin
  Result := FileExists( Path ) or DirectoryExists( Path ) or
            MyShareDownInfoReadUtil.ReadDownPathIsExist( Path );
end;

function TFindDownSavePath.get: string;
var
  ReadLastPath : string;
  DownloadPath, OrgDownloadPath, SaveName : string;
  NameNumber : Integer;
begin
    // 是否重复下载
  ReadLastPath := MyShareDownInfoReadUtil.ReadSavePath( DownPcID, FullPath );
  if ReadLastPath <> '' then
  begin
    Result := ReadLastPath;
    Exit;
  end;

    // 文件名
  SaveName := MyFileInfo.getFileName( FullPath );
  SaveName := MyFilePath.getDownloadPath( SaveName );

    // 完整路径
  DownloadPath := MyFilePath.getPath( SavePath ) + SaveName;
  OrgDownloadPath := DownloadPath;

    // 存在相同则改路径
  NameNumber := 1;
  while ExistPath( DownloadPath ) do
  begin
    DownloadPath := MyRename.getFileName( OrgDownloadPath, NameNumber );
    Inc( NameNumber );
  end;

    // 返回
  Result := DownloadPath;
end;

procedure TFindDownSavePath.SetDownPcID(_DownPcID: string);
begin
  DownPcID := _DownPcID;
end;

{ TShareFileDownChildSetStatusHandle }

procedure TShareFileDownChildSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareFileDownChildSetStatusHandle.SetToFace;
var
  VstShareDownChildSetStatus : TVstShareDownChildSetStatus;
begin
  VstShareDownChildSetStatus := TVstShareDownChildSetStatus.Create( ParentPath, DesPcID );
  VstShareDownChildSetStatus.SetFilePath( FilePath );
  VstShareDownChildSetStatus.SetStatus( Status );
  MyFaceChange.AddChange( VstShareDownChildSetStatus );
end;

procedure TShareFileDownChildSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TRemoveExistShareDown }

constructor TRemoveShareDownConflict.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

procedure TRemoveShareDownConflict.Update;
var
  ConfilectPathList : TStringList;
  i : Integer;
begin
  ConfilectPathList := MyShareDownInfoReadUtil.ReadConfilctPathList( DesPcID, FullPath );
  for i := 0 to ConfilectPathList.Count - 1 do
    MyFileShareControl.RemoveShareDown( ConfilectPathList[i], DesPcID );
  ConfilectPathList.Free;
end;

{ TShareDownFileLostConnHandle }

procedure TShareDownFileLostConnHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownFileLostConnHandle.SetSizeInfo(_FileSize,
  _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownFileLostConnHandle.Update;
begin

end;

{ TShareFileDownChildSetCompletedSizeHandle }

procedure TShareFileDownChildSetCompletedSizeHandle.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareFileDownChildSetCompletedSizeHandle.SetToFace;
var
  VstShareDownChildSetCompletedSize : TVstShareDownChildSetCompletedSize;
begin
  VstShareDownChildSetCompletedSize := TVstShareDownChildSetCompletedSize.Create( ParentPath, DesPcID );
  VstShareDownChildSetCompletedSize.SetFilePath( FilePath );
  VstShareDownChildSetCompletedSize.SetCompletedSize( CompletedSize );
  MyFaceChange.AddChange( VstShareDownChildSetCompletedSize );
end;

procedure TShareFileDownChildSetCompletedSizeHandle.SetToXml;
var
  ShareDownChildSetCompletedSizeXml : TShareDownChildSetCompletedSizeXml;
begin
  ShareDownChildSetCompletedSizeXml := TShareDownChildSetCompletedSizeXml.Create( DesPcID, ParentPath );
  ShareDownChildSetCompletedSizeXml.SetFilePath( FilePath );
  ShareDownChildSetCompletedSizeXml.SetCompletedSize( CompletedSize );
  MyXmlChange.AddChange( ShareDownChildSetCompletedSizeXml );
end;

procedure TShareFileDownChildSetCompletedSizeHandle.Update;
begin
  SetToFace;

  SetToXml;
end;

{ TShareFileDownIsOnlineHandle }

procedure TShareFileDownIsOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareFileDownIsOnlineHandle.SetToFace;
var
  VstShareDownIsOnline : TVstShareDownIsOnline;
begin
  VstShareDownIsOnline := TVstShareDownIsOnline.Create( ParentPath, DesPcID );
  VstShareDownIsOnline.SetIsOnline( IsOnline );
  MyFaceChange.AddChange( VstShareDownIsOnline );
end;

procedure TShareFileDownIsOnlineHandle.Update;
begin
  SetToFace;
end;

{ TShareDownFilePcIsOnlineHandle }

constructor TShareDownFilePcIsOnlineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TShareDownFilePcIsOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareDownFilePcIsOnlineHandle.Update;
var
  DownPathList : TStringList;
  i : Integer;
  FullPath : string;
  ShareFileDownIsOnlineHandle : TShareFileDownIsOnlineHandle;
begin
  DownPathList := MyShareDownInfoReadUtil.ReadPcDownPathList( PcID );

  for i := 0 to DownPathList.Count - 1 do
  begin
    FullPath := DownPathList[i];

    ShareFileDownIsOnlineHandle := TShareFileDownIsOnlineHandle.Create( PcID, FullPath );
    ShareFileDownIsOnlineHandle.SetIsOnline( IsOnline );
    ShareFileDownIsOnlineHandle.Update;
    ShareFileDownIsOnlineHandle.Free;
  end;

  DownPathList.Free;
end;

{ TShareDownServerOfflineHandle }

procedure TShareDownServerOfflineHandle.SetOffline(DesPcID, FullPath: string);
var
  ShareFileDownIsOnlineHandle : TShareFileDownIsOnlineHandle;
begin
  ShareFileDownIsOnlineHandle := TShareFileDownIsOnlineHandle.Create( DesPcID, FullPath );
  ShareFileDownIsOnlineHandle.SetIsOnline( False );
  ShareFileDownIsOnlineHandle.Update;
  ShareFileDownIsOnlineHandle.Free;
end;

procedure TShareDownServerOfflineHandle.Update;
var
  ShareDownList : TShareDownList;
  i : Integer;
begin
  MyShareDownInfo.EnterData;
  ShareDownList := MyShareDownInfo.ShareDownList;
  for i := 0 to ShareDownList.Count - 1 do
    SetOffline( ShareDownList[i].DesPcID, ShareDownList[i].FullPath );
  MyShareDownInfo.LeaveData;
end;

{ TShareFileDownSetStatusHandle }

procedure TShareFileDownSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareFileDownSetStatusHandle.SetToFace;
var
  VstShareDownSetStatus : TVstShareDownSetStatus;
begin
  VstShareDownSetStatus := TVstShareDownSetStatus.Create( ParentPath, DesPcID );
  VstShareDownSetStatus.SetStatus( Status );
  MyFaceChange.AddChange( VstShareDownSetStatus );
end;

procedure TShareFileDownSetStatusHandle.SetToXml;
var
  ShareDownSetStatusXml : TShareDownSetStatusXml;
begin
  ShareDownSetStatusXml := TShareDownSetStatusXml.Create( DesPcID, ParentPath );
  ShareDownSetStatusXml.SetStatus( Status );
  MyXmlChange.AddChange( ShareDownSetStatusXml );
end;

procedure TShareFileDownSetStatusHandle.Update;
begin
  SetToFace;

  SetToXml;
end;

{ TRemoveExistSharePath }

constructor TRemoveExistSharePath.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TRemoveExistSharePath.Update: Boolean;
var
  VstSharePath : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstSharePathData;
begin
  Result := True;
  VstSharePath := frmMainForm.vstSharePath;
  SelectNode := VstSharePath.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstSharePath.GetNodeData( SelectNode );
    if MyMatchMask.CheckEqualsOrChild( FullPath, SelectData.FullPath )  then
    begin
      Result := False; // 存在父路径
      Break;
    end;
    if MyMatchMask.CheckChild( SelectData.FullPath, FullPath ) then
      MyFileShareControl.RemoveSharePath( SelectData.FullPath );
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TShareHistoryChangeHandle }

constructor TShareHistoryChangeHandle.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

{ TShareHistoryRemoveHandle }

procedure TShareHistoryRemoveHandle.RemoveFromFace;
var
  VstShareHistoryRemove : TVstShareHistoryRemove;
begin
  VstShareHistoryRemove := TVstShareHistoryRemove.Create( FullPath, DesPcID );
  MyFaceChange.AddChange( VstShareHistoryRemove );
end;

procedure TShareHistoryRemoveHandle.RemoveFromXml;
var
  ShareHistoryRemoveXml : TShareHistoryRemoveXml;
begin
  ShareHistoryRemoveXml := TShareHistoryRemoveXml.Create( FullPath, DesPcID );
  MyXmlChange.AddChange( ShareHistoryRemoveXml );
end;

procedure TShareHistoryRemoveHandle.Update;
begin
  RemoveFromFace;

  RemoveFromXml;
end;

{ TShareHistoryAddHandle }

procedure TShareHistoryAddHandle.AddToXml;
var
  ShareHistoryAddXml : TShareHistoryAddXml;
begin
  ShareHistoryAddXml := TShareHistoryAddXml.Create( FullPath, DesPcID );
  ShareHistoryAddXml.SetPathType( PathType );
  MyXmlChange.AddChange( ShareHistoryAddXml );
end;

procedure TShareHistoryAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TShareHistoryReadHandle }

procedure TShareHistoryReadHandle.AddToFace;
var
  DesPcName : string;
  DesPcIsOnline : Boolean;
  VstShareHistoryAdd : TVstShareHistoryAdd;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );

  VstShareHistoryAdd := TVstShareHistoryAdd.Create( FullPath, DesPcID );
  VstShareHistoryAdd.SetDesPcName( DesPcName );
  VstShareHistoryAdd.SetPathType( PathType );
  VstShareHistoryAdd.SetDesPcIsOnline( DesPcIsOnline );
  MyFaceChange.AddChange( VstShareHistoryAdd );
end;

procedure TShareHistoryReadHandle.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareHistoryReadHandle.Update;
begin
  AddToFace;
end;

{ TShareFavorityChangeHandle }

constructor TShareFavorityChangeHandle.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

{ TShareFavorityReadHandle }

procedure TShareFavorityReadHandle.AddToFace;
var
  DesPcName : string;
  DesPcIsOnline : Boolean;
  VstShareFavorityAdd : TVstShareFavorityAdd;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DesPcID );

  VstShareFavorityAdd := TVstShareFavorityAdd.Create( FullPath, DesPcID );
  VstShareFavorityAdd.SetDesPcName( DesPcName );
  VstShareFavorityAdd.SetPathType( PathType );
  VstShareFavorityAdd.SetDesPcIsOnline( DesPcIsOnline );
  MyFaceChange.AddChange( VstShareFavorityAdd );
end;

procedure TShareFavorityReadHandle.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareFavorityReadHandle.Update;
begin
  AddToFace;
end;

{ TShareFavorityAddHandle }

procedure TShareFavorityAddHandle.AddToXml;
var
  ShareFavoriteAddXml : TShareFavoriteAddXml;
begin
  ShareFavoriteAddXml := TShareFavoriteAddXml.Create( FullPath, DesPcID );
  ShareFavoriteAddXml.SetPathType( PathType );
  MyXmlChange.AddChange( ShareFavoriteAddXml );
end;

procedure TShareFavorityAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TShareFavorityRemoveHandle }

procedure TShareFavorityRemoveHandle.RemoveFromFace;
var
  VstShareFavorityRemove : TVstShareFavorityRemove;
begin
  VstShareFavorityRemove := TVstShareFavorityRemove.Create( FullPath, DesPcID );
  MyFaceChange.AddChange( VstShareFavorityRemove );
end;

procedure TShareFavorityRemoveHandle.RemoveFromXml;
var
  ShareFavoriteRemoveXml : TShareFavoriteRemoveXml;
begin
  ShareFavoriteRemoveXml := TShareFavoriteRemoveXml.Create( FullPath, DesPcID );
  MyXmlChange.AddChange( ShareFavoriteRemoveXml );
end;

procedure TShareFavorityRemoveHandle.Update;
begin
  RemoveFromFace;

  RemoveFromXml;
end;

{ TRemoveExistShareHistory }

constructor TRemoveExistShareHistory.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

procedure TRemoveExistShareHistory.Update;
var
  VstHistory : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  VstHistory := frmShareExplorer.VstHisroty;
  SelectNode := VstHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstHistory.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin  // 删除旧的
      MyFileShareControl.RemoveHistory( FullPath, DesPcID );
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TRemoveExistShareFavorite }

constructor TRemoveExistShareFavorite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

procedure TRemoveExistShareFavorite.Update;
var
  VstFavorite : TVirtualStringTree;
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  VstFavorite := frmShareExplorer.VstFavorite;
  SelectNode := VstFavorite.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstFavorite.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin  // 删除旧的
      MyFileShareControl.RemoveFavorite( FullPath, DesPcID );
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TShareHistoryPcOnlineHandle }

constructor TShareHistoryPcOnlineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TShareHistoryPcOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareHistoryPcOnlineHandle.SetToFace;
var
  VstShareHistoryPcOnline : TVstShareHistoryPcOnline;
begin
  VstShareHistoryPcOnline := TVstShareHistoryPcOnline.Create( PcID );
  VstShareHistoryPcOnline.SetIsOnline( IsOnline );
  MyFaceChange.AddChange( VstShareHistoryPcOnline );
end;

procedure TShareHistoryPcOnlineHandle.Update;
begin
  SetToFace;
end;

{ TShareHistoryServerOfflineHandle }

procedure TShareHistoryServerOfflineHandle.SetToFace;
var
  VstShareHistoryServerOffline : TVstShareHistoryServerOffline;
begin
  VstShareHistoryServerOffline := TVstShareHistoryServerOffline.Create;
  MyFaceChange.AddChange( VstShareHistoryServerOffline );
end;

procedure TShareHistoryServerOfflineHandle.Update;
begin
  SetToFace;
end;

{ TShareFavorityPcOnlineHandle }

constructor TShareFavorityPcOnlineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TShareFavorityPcOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TShareFavorityPcOnlineHandle.SetToFace;
var
  VstShareFavorityPcOnline : TVstShareFavorityPcOnline;
begin
  VstShareFavorityPcOnline := TVstShareFavorityPcOnline.Create( PcID );
  VstShareFavorityPcOnline.SetIsOnline( IsOnline );
  MyFaceChange.AddChange( VstShareFavorityPcOnline );
end;

procedure TShareFavorityPcOnlineHandle.Update;
begin
  SetToFace;
end;

{ TShareFavorityServerOfflineHandle }

procedure TShareFavorityServerOfflineHandle.SetToFace;
var
  VstShareFavorityServerOffline : TVstShareFavorityServerOffline;
begin
  VstShareFavorityServerOffline := TVstShareFavorityServerOffline.Create;
  MyFaceChange.AddChange( VstShareFavorityServerOffline );
end;

procedure TShareFavorityServerOfflineHandle.Update;
begin
  SetToFace;
end;

{ TShareDownShareCancelHandle }

procedure TShareDownShareCancelHandle.ClearChild;
var
  ShareFileDownClearChildHandle : TShareFileDownClearChildHandle;
begin
  ShareFileDownClearChildHandle := TShareFileDownClearChildHandle.Create( DesPcID, ParentPath );
  ShareFileDownClearChildHandle.Update;
  ShareFileDownClearChildHandle.Free;
end;

procedure TShareDownShareCancelHandle.SetCancelStatus;
var
  ShareFileDownSetStatusHandle : TShareFileDownSetStatusHandle;
begin
  ShareFileDownSetStatusHandle := TShareFileDownSetStatusHandle.Create( DesPcID, ParentPath );
  ShareFileDownSetStatusHandle.SetStatus( FileShareStatus_Cancel );
  ShareFileDownSetStatusHandle.Update;
  ShareFileDownSetStatusHandle.Free;
end;

procedure TShareDownShareCancelHandle.Update;
begin
  ClearChild;
  SetCancelStatus;
end;

{ TShareFileDownRemoveChildJobHandle }

procedure TShareFileDownRemoveChildJobHandle.SetToFace;
var
  VstShareDownClearJob : TVstShareDownClearJob;
begin
  VstShareDownClearJob := TVstShareDownClearJob.Create( ParentPath, DesPcID );
  MyFaceChange.AddChange( VstShareDownClearJob );
end;

procedure TShareFileDownRemoveChildJobHandle.Update;
begin
  SetToFace;
end;

{ TShareFileDownClearChildHandle }

procedure TShareFileDownClearChildHandle.SetToFace;
var
  VstShareDownClearChild : TVstShareDownClearChild;
begin
  VstShareDownClearChild := TVstShareDownClearChild.Create( ParentPath, DesPcID );
  MyFaceChange.AddChange( VstShareDownClearChild );
end;

procedure TShareFileDownClearChildHandle.SetToXml;
var
  ShareDownClearChildXml : TShareDownClearChildXml;
begin
  ShareDownClearChildXml := TShareDownClearChildXml.Create( DesPcID, ParentPath );
  MyXmlChange.AddChange( ShareDownClearChildXml );
end;

procedure TShareFileDownClearChildHandle.Update;
begin
  SetToFace;

  SetToXml;
end;

{ TShareFileDownConfirmCancelHandle }

procedure TShareFileDownConfirmCancelHandle.AddToMsg;
var
  ClientSendShareCancelReqMsg : TClientSendShareCancelReqMsg;
begin
  ClientSendShareCancelReqMsg := TClientSendShareCancelReqMsg.Create;
  ClientSendShareCancelReqMsg.SetPcID( PcInfo.PcID );
  ClientSendShareCancelReqMsg.SetDownloadPath( ParentPath );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareCancelReqMsg );
end;

procedure TShareFileDownConfirmCancelHandle.Update;
begin
  AddToMsg;
end;

{ TShareDownGetListCompletedHandle }

procedure TShareDownGetListCompletedHandle.SetIsShareCancel(_IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TShareDownGetListCompletedHandle.SetToFace;
var
  VstShareFileCompleted : TVstShareFileCompleted;
begin
  VstShareFileCompleted := TVstShareFileCompleted.Create( ParentPath, DesPcID );
  VstShareFileCompleted.SetIsShareCancel( IsShareCancel );
  MyFaceChange.AddChange( VstShareFileCompleted );
end;

procedure TShareDownGetListCompletedHandle.Update;
begin
  SetToFace;
end;

{ TShareDownGetDownCompletedHandle }

procedure TShareDownGetDownCompletedHandle.SetIsShareCancel(
  _IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TShareDownGetDownCompletedHandle.SetToStatus;
var
  ShareFileDownSetStatusHandle : TShareFileDownSetStatusHandle;
begin
    // 对方 取消共享
  ShareFileDownSetStatusHandle := TShareFileDownSetStatusHandle.Create( DesPcID, ParentPath );
  ShareFileDownSetStatusHandle.SetStatus( FileShareStatus_Cancel );
  ShareFileDownSetStatusHandle.Update;
  ShareFileDownSetStatusHandle.Free;
end;

procedure TShareDownGetDownCompletedHandle.Update;
begin
  if IsShareCancel then
    SetToStatus;
end;

{ TSharePcSetIsShareHandle }

constructor TSharePcRevIsShareHandle.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

procedure TSharePcRevIsShareHandle.RemoveFromSelectLvPc;
var
  LvDownSharePcRemove : TLvDownSharePcRemove;
begin
  LvDownSharePcRemove := TLvDownSharePcRemove.Create( PcID );
  MyFaceChange.AddChange( LvDownSharePcRemove );
end;

procedure TSharePcRevIsShareHandle.RemoveFromShowVstPc;
var
  VstShareFilePcRemove : TVstShareFilePcRemove;
begin
  VstShareFilePcRemove := TVstShareFilePcRemove.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcRemove );
end;

procedure TSharePcRevIsShareHandle.SetIsShareFolder(_IsShareFolder: Boolean);
begin
  IsShareFolder := _IsShareFolder;
end;

procedure TSharePcRevIsShareHandle.AddToSelectLvPc;
var
  LvDownSharePcAdd : TLvDownSharePcAdd;
begin
  LvDownSharePcAdd := TLvDownSharePcAdd.Create( PcID );
  LvDownSharePcAdd.SetPcName( PcName );
  MyFaceChange.AddChange( LvDownSharePcAdd );
end;

procedure TSharePcRevIsShareHandle.AddToShowVstPc;
var
  VstShareFilePcAdd : TVstShareFilePcAdd;
begin
  VstShareFilePcAdd := TVstShareFilePcAdd.Create( PcID );
  VstShareFilePcAdd.SetPcName( PcName );
  MyFaceChange.AddChange( VstShareFilePcAdd );
end;

procedure TSharePcRevIsShareHandle.Update;
begin
  if IsShareFolder then
  begin
    AddToSelectLvPc;
    AddToShowVstPc;
  end
  else
  begin
    RemoveFromSelectLvPc;
    RemoveFromShowVstPc;
  end;
end;

{ TSharePcSendIsShareHandle }

constructor TSharePcSendIsShareHandle.Create(_IsShareFolder: Boolean);
begin
  IsShareFolder := _IsShareFolder;
end;

procedure TSharePcSendIsShareHandle.Update;
var
  ClientSendIsShareMsg : TClientSendIsShareMsg;
begin
  ClientSendIsShareMsg := TClientSendIsShareMsg.Create;
  ClientSendIsShareMsg.SetPcID( PcInfo.PcID );
  ClientSendIsShareMsg.SetPcName( PcInfo.PcName );
  ClientSendIsShareMsg.SetIsShareFile( IsShareFolder );
  MyClient.SendMsgToAll( ClientSendIsShareMsg );
end;

{ TShareDownResetFreeLimitHandle }

procedure TShareDownResetFreeLimitHandle.Update;
var
  ShareDownDisableList : TShareDownDisableList;
  i : Integer;
  DesPcID, FilePath, SavePath : string;
  FileSize, CompltedSize : Int64;
  FileTime : TDateTime;
  TransferShareJobAddHandle : TTransferShareJobAddHandle;
  ShareDownDisableRemoveInfo : TShareDownDisableRemoveInfo;
begin
    // 还是免费版
  if RegisterInfo.getIsFreeEdition then
    Exit;

    // 读取 免费限制的路径
  ShareDownDisableList := MyShareDownInfoReadUtil.ReadDisablePathList;

    // 启动 Job
  for i := 0 to ShareDownDisableList.Count - 1 do
  begin
    DesPcID := ShareDownDisableList[i].DesPcID;
    FilePath := ShareDownDisableList[i].FilePath;
    SavePath := ShareDownDisableList[i].SavePath;
    FileSize := ShareDownDisableList[i].FileSize;
    CompltedSize := ShareDownDisableList[i].CompletedSize;
    FileTime := ShareDownDisableList[i].FileTime;

      // 添加 到 Job
    TransferShareJobAddHandle := TTransferShareJobAddHandle.Create( FilePath, DesPcID );
    TransferShareJobAddHandle.SetFileInfo( FileSize, CompltedSize, FileTime );
    TransferShareJobAddHandle.SetDownFilePath( SavePath );
    TransferShareJobAddHandle.Update;
    TransferShareJobAddHandle.Free;

      // 删除记录
    ShareDownDisableRemoveInfo := TShareDownDisableRemoveInfo.Create( DesPcID, FilePath );
    ShareDownDisableRemoveInfo.Update;
    ShareDownDisableRemoveInfo.Free;
  end;

  ShareDownDisableList.Free;
end;

end.
