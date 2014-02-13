unit UMyRestoreFileControl;

interface

uses classes, SysUtils;

type

{$Region ' 修改 根路径 ' }

    // 父类
  TRetoreItemChangeHandle = class
  public
    FullPath, RestorePcID : string;
  public
    constructor Create( _FullPath, _RestorePcID : string );
  end;

    // 读取
  TRestoreItemReadHandle = class( TRetoreItemChangeHandle )
  public
    PathType, SavePath : string;
    FileSize, CompletedSpace : Int64;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetPathInfo( _PathType, _SavePath : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetEncryptInfo( _IsEncrypted :Boolean; _Password : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;virtual;
  end;

    // 添加
  TRestoreItemAddHandle = class( TRestoreItemReadHandle )
  public
    procedure Update;override;
  protected
    procedure AddToFace;override;
    procedure AddToXml;
  end;

    // 添加 总空间信息
  TRestoreItemAddSpaceHandle = class( TRetoreItemChangeHandle )
  public
    FileSpace : Int64;
  public
    procedure SetFileSpace( _FileSpace : Int64 );
    procedure Update;
  private
    procedure AddToFace;
    procedure AddToXml;
  end;

    // 添加 已完成空间信息
  TRestoreItemAddCompletedSpaceHandle = class( TRetoreItemChangeHandle )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;
  private
    procedure AddToFace;
    procedure AddToXml;
  end;

    // 删除
  TRestoreItemRemoveHandle = class( TRetoreItemChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  private
    procedure RemoveOfflineJob;
  end;

{$EndRegion}

{$Region ' 修改 子路径 ' }

    // 修改
  TRestoreFileChangeHandle = class
  public
    FilePath, RestorePcID : string;
  public
    constructor Create( _FilePath, _RestorePcID : string );
  end;

    // 读取
  TRestoreFileReadHandle = class( TRestoreFileChangeHandle )
  public
    FileSize, Position : Int64;
    FileTime : TDateTime;
    LocationPcID : string;
  public
    procedure SetSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetLocationPcID( _LocationPcID : string );
    procedure Update;virtual;
  private
    procedure AddToFace;
  end;

    // 添加
  TRestoreFileAddHandle = class( TRestoreFileReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 设置文件状态
  TRestoreFileSetStatusHandle = class( TRestoreFileChangeHandle )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 添加文件 已完成空间信息
  TRestoreFileAddCompletedSpaceHandle = class( TRestoreFileChangeHandle )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;
  private
    procedure AddToFace;
  end;


    // 设置文件续传位置
  TRestoreFileSetPositionHandle = class( TRestoreFileChangeHandle )
  private
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;
  private
    procedure SetToXml;
  end;

    // 删除
  TRestoreFileRemoveHandle = class( TRestoreFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 快速恢复 ' }

  TRestoreFileQuickAddHanlde = class
  public
    RestoreItemPath, RestorePcID : string;
    FilePath, LocationPcID : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _RestoreItemPath, _RestorePcID : string );
    procedure SetPathInfo( _FilePath : string );
    procedure SetLocationPcID( _LocationPcID : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;
  private
    function getIsAddFile : Boolean;
    procedure AddToRestoreFile;
    procedure AddToRestoreJob;
    procedure AddToRemoteUpPend;
    procedure AddRestoreResultFace;
  end;

{$EndRegion}

{$Region ' TotalControl ' }

    // 添加 RestoreItem
  TAddRestoreItemControl = class
  public
    FullPath, RestorePcID : string;
    PathType, SavePath : string;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    constructor Create( _FullPath, _RestorePcID : string );
    procedure SetPathInfo( _PathType, _SavePath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure Update;
  private
    procedure RemoveConflictPath;
    procedure AddRestoreItem;
  end;

    // 添加 RestoreFile
  TAddRestoreFileControl = class
  public
    FilePath, RestorePcID : string;
  public
    FileSize : Int64;
    FileTime : TDateTime;
    LocationPcID : string;
  public
    RestoreItemPath : string;
  public
    constructor Create( _FilePath, _RestorePcID : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetLocationPcID( _LocationPcID : string );
    procedure SetRestoreItemPath( _RestoreItemPath : string );
    procedure Update;
  private
    procedure AddToRestoreFile;
    procedure AddToRestoreItemSpace;
  end;

{$EndRegion}

  MyRestoreControl = class
  public
    class procedure RemovePath( RestorePcID, RestorePath : string );
  end;

implementation

uses UMyRestoreFileInfo, URestoreFileFace, UMyREstoreFileXml, UMyJobInfo, UMyNetPcInfo,
     UJobControl, UMyClient, UChangeInfo;

{ TRetoreFileItemChangeHandle }

constructor TRetoreItemChangeHandle.Create(_FullPath, _RestorePcID: string);
begin
  FullPath := _FullPath;
  RestorePcID := _RestorePcID;
end;

{ TRestoreItemReadHandle }

procedure TRestoreItemReadHandle.AddToFace;
var
  RestorePcName : string;
  VstRestoreDownAddRoot : TVstRestoreDownAddRoot;
begin
  RestorePcName := MyNetPcInfoReadUtil.ReadName( RestorePcID );

  VstRestoreDownAddRoot := TVstRestoreDownAddRoot.Create( FullPath, RestorePcID );
  VstRestoreDownAddRoot.SetSpaceInfo( FileSize, CompletedSpace );
  VstRestoreDownAddRoot.SetPathInfo( PathType, SavePath );
  VstRestoreDownAddRoot.SetRestorePc( RestorePcName );
  VstRestoreDownAddRoot.SetIsScaning( False );
  MyRestoreFileFace.AddChange( VstRestoreDownAddRoot );
end;

procedure TRestoreItemReadHandle.AddToInfo;
var
  RestoreItemAddInfo : TRestoreItemAddInfo;
begin
  RestoreItemAddInfo := TRestoreItemAddInfo.Create( FullPath, RestorePcID );
  RestoreItemAddInfo.SetSavePath( SavePath );
  RestoreItemAddInfo.SetEncryptInfo( IsEncrypted, Password );
  RestoreItemAddInfo.Update;
  RestoreItemAddInfo.Free;
end;

procedure TRestoreItemReadHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreItemReadHandle.SetSpaceInfo(_FileSize, _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TRestoreItemReadHandle.SetPathInfo(_PathType, _SavePath: string);
begin
  PathType := _PathType;
  SavePath := _SavePath;
end;

procedure TRestoreItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TRestoreItemAddHandle }

procedure TRestoreItemAddHandle.AddToFace;
var
  RestorePcName : string;
  VstRestoreDownAddRoot : TVstRestoreDownAddRoot;
begin
  RestorePcName := MyNetPcInfoReadUtil.ReadName( RestorePcID );

  VstRestoreDownAddRoot := TVstRestoreDownAddRoot.Create( FullPath, RestorePcID );
  VstRestoreDownAddRoot.SetSpaceInfo( FileSize, CompletedSpace );
  VstRestoreDownAddRoot.SetPathInfo( PathType, SavePath );
  VstRestoreDownAddRoot.SetRestorePc( RestorePcName );
  VstRestoreDownAddRoot.SetIsScaning( True );
  MyRestoreFileFace.AddChange( VstRestoreDownAddRoot );
end;

procedure TRestoreItemAddHandle.AddToXml;
var
  RestoreFileAddRootXml : TRestoreFileAddRootXml;
begin
  RestoreFileAddRootXml := TRestoreFileAddRootXml.Create( FullPath, RestorePcID );
  RestoreFileAddRootXml.SetPathInfo( PathType, SavePath );
  RestoreFileAddRootXml.SetFileSize( FileSize );
  RestoreFileAddRootXml.SetEncryptInfo( IsEncrypted, Password );
  MyXmlChange.AddChange( RestoreFileAddRootXml );
end;

procedure TRestoreItemAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreItemRemoveHandle }

procedure TRestoreItemRemoveHandle.RemoveFromFace;
var
  VstRestoreDownRemoveRoot : TVstRestoreDownRemoveRoot;
begin
  VstRestoreDownRemoveRoot := TVstRestoreDownRemoveRoot.Create( FullPath, RestorePcID );
  MyRestoreFileFace.AddChange( VstRestoreDownRemoveRoot );
end;

procedure TRestoreItemRemoveHandle.RemoveFromInfo;
var
  RestoreItemRemoveInfo : TRestoreItemRemoveInfo;
begin
  RestoreItemRemoveInfo := TRestoreItemRemoveInfo.Create( FullPath, RestorePcID );
  RestoreItemRemoveInfo.Update;
  RestoreItemRemoveInfo.Free;
end;

procedure TRestoreItemRemoveHandle.RemoveFromXml;
var
  RestoreFileRemoveRootXml : TRestoreFileRemoveRootXml;
begin
  RestoreFileRemoveRootXml := TRestoreFileRemoveRootXml.Create( FullPath, RestorePcID );
  MyXmlChange.AddChange( RestoreFileRemoveRootXml );
end;

procedure TRestoreItemRemoveHandle.RemoveOfflineJob;
var
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
  TransferJobOnlineInfo.SetOnlinePcID( '' );
  TransferJobOnlineInfo.SetJobType( JobType_Restore );
  MyJobInfo.AddChange( TransferJobOnlineInfo );
end;

procedure TRestoreItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveOfflineJob;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TRestoreFileChangeHandle }

constructor TRestoreFileChangeHandle.Create(_FilePath, _RestorePcID: string);
begin
  FilePath := _FilePath;
  RestorePcID := _RestorePcID;
end;

{ TRestoreFileReadHandle }

procedure TRestoreFileReadHandle.AddToFace;
var
  LocatinPcName : string;
  VstRestoreDownAddChild : TVstRestoreDownAddChild;
begin
  LocatinPcName := MyNetPcInfoReadUtil.ReadName( LocationPcID );

  VstRestoreDownAddChild := TVstRestoreDownAddChild.Create( FilePath, RestorePcID );
  VstRestoreDownAddChild.SetSpaceInfo( FileSize, Position );
  VstRestoreDownAddChild.SetLocationPc( LocationPcID, LocatinPcName );
  MyRestoreFileFace.AddChange( VstRestoreDownAddChild );
end;

procedure TRestoreFileReadHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TRestoreFileReadHandle.SetLocationPcID(_LocationPcID: string);
begin
  LocationPcID := _LocationPcID;
end;

procedure TRestoreFileReadHandle.SetSpaceInfo(_FileSize, _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TRestoreFileReadHandle.Update;
begin
  AddToFace;
end;

{ TRestoreFileAddHandle }

procedure TRestoreFileAddHandle.AddToXml;
var
  RestoreFileAddChildXml : TRestoreFileAddChildXml;
begin
  RestoreFileAddChildXml := TRestoreFileAddChildXml.Create( FilePath, RestorePcID );
  RestoreFileAddChildXml.SetFileInfo( FileSize, FileTime );
  RestoreFileAddChildXml.SetLocationID( LocationPcID );
  MyXmlChange.AddChange( RestoreFileAddChildXml );
end;

procedure TRestoreFileAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TRestoreFileRemoveHandle }

procedure TRestoreFileRemoveHandle.RemoveFromFace;
var
  VstRestoreDownRemoveChild : TVstRestoreDownRemoveChild;
begin
  VstRestoreDownRemoveChild := TVstRestoreDownRemoveChild.Create( FilePath, RestorePcID );
  MyRestoreFileFace.AddChange( VstRestoreDownRemoveChild );
end;

procedure TRestoreFileRemoveHandle.RemoveFromXml;
var
  RestoreFileRemoveChildXml : TRestoreFileRemoveChildXml;
begin
  RestoreFileRemoveChildXml := TRestoreFileRemoveChildXml.Create( FilePath, RestorePcID );
  MyXmlChange.AddChange( RestoreFileRemoveChildXml );
end;

procedure TRestoreFileRemoveHandle.Update;
begin
  RemoveFromFace;
  RemoveFromXml;
end;

{ TRestoreFileSetStatusHandle }

procedure TRestoreFileSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TRestoreFileSetStatusHandle.SetToFace;
var
  VstRestoreDownChildStatus : TVstRestoreDownChildStatus;
begin
  VstRestoreDownChildStatus := TVstRestoreDownChildStatus.Create( FilePath, RestorePcID );
  VstRestoreDownChildStatus.SetStatus( Status );
  MyRestoreFileFace.AddChange( VstRestoreDownChildStatus );
end;

procedure TRestoreFileSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TRestoreFileSetPositionHandle }

procedure TRestoreFileSetPositionHandle.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TRestoreFileSetPositionHandle.SetToXml;
var
  RestoreFileChildPositionXml : TRestoreFileChildPositionXml;
begin
  RestoreFileChildPositionXml := TRestoreFileChildPositionXml.Create( FilePath, RestorePcID );
  RestoreFileChildPositionXml.SetPosition( Position );
  MyXmlChange.AddChange( RestoreFileChildPositionXml );
end;

procedure TRestoreFileSetPositionHandle.Update;
begin
  SetToXml;
end;

{ TAddRestoreItemControl }

procedure TAddRestoreItemControl.AddRestoreItem;
var
  RestoreItemAddHandle : TRestoreItemAddHandle;
begin
  RestoreItemAddHandle := TRestoreItemAddHandle.Create( FullPath, RestorePcID );
  RestoreItemAddHandle.SetPathInfo( PathType, SavePath );
  RestoreItemAddHandle.SetSpaceInfo( 0, 0 );
  RestoreItemAddHandle.SetEncryptInfo( IsEncrypted, Password );
  RestoreItemAddHandle.Update;
  RestoreItemAddHandle.Free;
end;

constructor TAddRestoreItemControl.Create(_FullPath, _RestorePcID: string);
begin
  FullPath := _FullPath;
  RestorePcID := _RestorePcID;
end;

procedure TAddRestoreItemControl.RemoveConflictPath;
var
  ExistPathList : TStringList;
  i : Integer;
  RestoreItemRemoveHandle : TRestoreItemRemoveHandle;
begin
  ExistPathList := MyRestoreInfoReadUtil.ReadConflictPath( FullPath, RestorePcID );
  for i := 0 to ExistPathList.Count - 1 do
  begin
    RestoreItemRemoveHandle := TRestoreItemRemoveHandle.Create( ExistPathList[i], RestorePcID );
    RestoreItemRemoveHandle.Update;
    RestoreItemRemoveHandle.Free;
  end;
  ExistPathList.Free;
end;

procedure TAddRestoreItemControl.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TAddRestoreItemControl.SetPathInfo(_PathType, _SavePath: string);
begin
  PathType := _PathType;
  SavePath := _SavePath;
end;

procedure TAddRestoreItemControl.Update;
begin
    // 删除 相同的
  RemoveConflictPath;

    // 添加 新增的
  AddRestoreItem;
end;

{ TRestoreItemAddSpaceHandle }

procedure TRestoreItemAddSpaceHandle.AddToFace;
var
  VstRestoreDownAddRootSpace : TVstRestoreDownAddRootSpace;
begin
  VstRestoreDownAddRootSpace := TVstRestoreDownAddRootSpace.Create( FullPath, RestorePcID );
  VstRestoreDownAddRootSpace.SetFileSize( FileSpace );
  MyRestoreFileFace.AddChange( VstRestoreDownAddRootSpace );
end;

procedure TRestoreItemAddSpaceHandle.AddToXml;
var
  RestoreFileAddRootSizeXml : TRestoreFileAddRootSizeXml;
begin
  RestoreFileAddRootSizeXml := TRestoreFileAddRootSizeXml.Create( FullPath, RestorePcID );
  RestoreFileAddRootSizeXml.SetFileSize( FileSpace );
  MyXmlChange.AddChange( RestoreFileAddRootSizeXml );
end;

procedure TRestoreItemAddSpaceHandle.SetFileSpace(_FileSpace: Int64);
begin
  FileSpace := _FileSpace;
end;

procedure TRestoreItemAddSpaceHandle.Update;
begin
  AddToFace;
  AddToXml;
end;

{ TRestoreItemAddCompletedSpaceHandle }

procedure TRestoreItemAddCompletedSpaceHandle.AddToFace;
var
  VstRestoreDownAddRootCompletedSpace : TVstRestoreDownAddRootCompletedSpace;
begin
  VstRestoreDownAddRootCompletedSpace := TVstRestoreDownAddRootCompletedSpace.Create( FullPath, RestorePcID );
  VstRestoreDownAddRootCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyRestoreFileFace.AddChange( VstRestoreDownAddRootCompletedSpace );
end;

procedure TRestoreItemAddCompletedSpaceHandle.AddToXml;
var
  RestoreFileAddRootCompletedSizeXml : TRestoreFileAddRootCompletedSizeXml;
begin
  RestoreFileAddRootCompletedSizeXml := TRestoreFileAddRootCompletedSizeXml.Create( FullPath, RestorePcID );
  RestoreFileAddRootCompletedSizeXml.SetCompletedSize( CompletedSpace );
  MyXmlChange.AddChange( RestoreFileAddRootCompletedSizeXml );
end;

procedure TRestoreItemAddCompletedSpaceHandle.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TRestoreItemAddCompletedSpaceHandle.Update;
begin
  AddToFace;
  AddToXml;
end;

{ TRestoreFileAddCompletedSpaceHandle }

procedure TRestoreFileAddCompletedSpaceHandle.AddToFace;
var
  VstRestoreDownChildAddCompletedSpace : TVstRestoreDownChildAddCompletedSpace;
begin
  VstRestoreDownChildAddCompletedSpace := TVstRestoreDownChildAddCompletedSpace.Create( FilePath, RestorePcID );
  VstRestoreDownChildAddCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyRestoreFileFace.AddChange( VstRestoreDownChildAddCompletedSpace );
end;

procedure TRestoreFileAddCompletedSpaceHandle.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TRestoreFileAddCompletedSpaceHandle.Update;
begin
  AddToFace;
end;

{ TAddRestoreFileControl }

procedure TAddRestoreFileControl.AddToRestoreFile;
var
  RestoreFileAddHandle : TRestoreFileAddHandle;
begin
  RestoreFileAddHandle := TRestoreFileAddHandle.Create( FilePath, RestorePcID );
  RestoreFileAddHandle.SetSpaceInfo( FileSize, 0 );
  RestoreFileAddHandle.SetFileTime( FileTime );
  RestoreFileAddHandle.SetLocationPcID( LocationPcID );
  RestoreFileAddHandle.Update;
  RestoreFileAddHandle.Free;
end;

procedure TAddRestoreFileControl.AddToRestoreItemSpace;
var
  RestoreItemAddSpaceHandle : TRestoreItemAddSpaceHandle;
begin
  RestoreItemAddSpaceHandle := TRestoreItemAddSpaceHandle.Create( RestoreItemPath, RestorePcID );
  RestoreItemAddSpaceHandle.SetFileSpace( FileSize );
  RestoreItemAddSpaceHandle.Update;
  RestoreItemAddSpaceHandle.Free;
end;

constructor TAddRestoreFileControl.Create(_FilePath, _RestorePcID: string);
begin
  FilePath := _FilePath;
  RestorePcID := _RestorePcID;
end;

procedure TAddRestoreFileControl.SetLocationPcID(_LocationPcID: string);
begin
  LocationPcID := _LocationPcID;
end;

procedure TAddRestoreFileControl.SetRestoreItemPath(_RestoreItemPath: string);
begin
  RestoreItemPath := _RestoreItemPath;
end;

procedure TAddRestoreFileControl.SetFileInfo(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TAddRestoreFileControl.Update;
begin
    // 添加 恢复文件
  AddToRestoreFile;

    // 添加 恢复根总空间
  AddToRestoreItemSpace;
end;

{ MyRestoreControl }

class procedure MyRestoreControl.RemovePath(RestorePcID, RestorePath: string);
var
  RestoreItemRemoveHandle : TRestoreItemRemoveHandle;
begin
  RestoreItemRemoveHandle := TRestoreItemRemoveHandle.Create( RestorePath, RestorePcID );
  RestoreItemRemoveHandle.Update;
  RestoreItemRemoveHandle.Free;
end;

{ TRestoreFileQuickAddHanlde }

procedure TRestoreFileQuickAddHanlde.AddRestoreResultFace;
var
  VstRestoreDownAddFileResult : TVstRestoreDownAddFileResult;
begin
  VstRestoreDownAddFileResult := TVstRestoreDownAddFileResult.Create;
  MyRestoreFileFace.AddChange( VstRestoreDownAddFileResult );
end;

procedure TRestoreFileQuickAddHanlde.AddToRemoteUpPend;
var
  PcAddUpPendRestoreFileMsg : TPcAddUpPendRestoreFileMsg;
begin
  PcAddUpPendRestoreFileMsg := TPcAddUpPendRestoreFileMsg.Create;
  PcAddUpPendRestoreFileMsg.SetPcID( PcInfo.PcID );
  PcAddUpPendRestoreFileMsg.SetFileInfo( 0, FileSize );
  PcAddUpPendRestoreFileMsg.SetFilePath( FilePath );
  MyClient.SendMsgToPc( LocationPcID, PcAddUpPendRestoreFileMsg );
end;

procedure TRestoreFileQuickAddHanlde.AddToRestoreFile;
var
  AddRestoreFileControl : TAddRestoreFileControl;
begin
  AddRestoreFileControl := TAddRestoreFileControl.Create( FilePath, RestorePcID );
  AddRestoreFileControl.SetLocationPcID( LocationPcID );
  AddRestoreFileControl.SetFileInfo( FileSize, FileTime );
  AddRestoreFileControl.SetRestoreItemPath( RestoreItemPath );
  AddRestoreFileControl.Update;
  AddRestoreFileControl.Free;
end;

procedure TRestoreFileQuickAddHanlde.AddToRestoreJob;
var
  RestoreItemSavePath : string;
  SavePath : string;
  TransferRestoreJobAddHandle : TTransferRestoreJobAddHandle;
begin
  RestoreItemSavePath := MyRestoreInfoReadUtil.ReadSavePath( RestoreItemPath, RestorePcID );
  SavePath := StringReplace( FilePath, RestoreItemPath, RestoreItemSavePath, [] );

  TransferRestoreJobAddHandle := TTransferRestoreJobAddHandle.Create( FilePath, LocationPcID );
  TransferRestoreJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferRestoreJobAddHandle.SetDownFilePath( SavePath );
  TransferRestoreJobAddHandle.SetRestorePcID( RestorePcID );
  TransferRestoreJobAddHandle.Update;
  TransferRestoreJobAddHandle.Free;
end;

constructor TRestoreFileQuickAddHanlde.Create(_RestoreItemPath,
  _RestorePcID: string);
begin
  RestoreItemPath := _RestoreItemPath;
  RestorePcID := _RestorePcID;
end;

function TRestoreFileQuickAddHanlde.getIsAddFile: Boolean;
var
  RestoreFileAddInfo : TRestoreFileAddInfo;
begin
  RestoreFileAddInfo := TRestoreFileAddInfo.Create( RestoreItemPath, RestorePcID );
  RestoreFileAddInfo.SetPathInfo( FilePath );
  Result := RestoreFileAddInfo.get;
  RestoreFileAddInfo.Free;
end;

procedure TRestoreFileQuickAddHanlde.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreFileQuickAddHanlde.SetLocationPcID(_LocationPcID: string);
begin
  LocationPcID := _LocationPcID;
end;

procedure TRestoreFileQuickAddHanlde.SetPathInfo(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TRestoreFileQuickAddHanlde.Update;
begin
    // 添加文件失败
  if not getIsAddFile then
    Exit;

    // 添加 恢复文件
  AddToRestoreFile;
  AddToRestoreJob;
  AddToRemoteUpPend;
  AddRestoreResultFace;
end;

end.
