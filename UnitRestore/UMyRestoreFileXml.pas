unit UMyRestoreFileXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, UMyUtil;

type

{$Region ' 修改 根节点 ' }

    // 修改 父类
  TRestoreFileChangeXml = class( TChangeInfo )
  public
    FullPath, RestorePcID : string;
  protected
    RestoreItemIndex : Integer;
    RestoreItemNode : IXMLNode;
  public
    constructor Create( _FullPath, _RestorePcID : string );
  protected
    function FindRestoreItemNode : Boolean;
  end;

    // 添加 根目录
  TRestoreFileAddRootXml = class( TRestoreFileChangeXml )
  public
    PathType, SaveAsPath : string;
    FileSize : Int64;
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetPathInfo( _PathType, _SaveAsPath : string );
    procedure SetFileSize( _FileSize : Int64 );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure Update;override;
  end;

    // 添加 总空间
  TRestoreFileAddRootSizeXml = class( TRestoreFileChangeXml )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成 空间
  TRestoreFileAddRootCompletedSizeXml = class( TRestoreFileChangeXml )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 移除 根目录
  TRestoreFileRemoveRootXml = class( TRestoreFileChangeXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 修改 子节点 ' }

    // 修改 子文件 父类
  TRestoreFileChildChangeXml = class( TChangeInfo )
  public
    FilePath, RestorePcID : string;
  protected
    RootNode, ChildListNode : IXMLNode;
    ChildNode : IXMLNode;
  public
    constructor Create( _FilePath, _RestorePcID : string );
  protected
    function FindRootNode : Boolean;
    function FindChildNode : Boolean;
  end;

    // 添加 子文件
  TRestoreFileAddChildXml = class( TRestoreFileChildChangeXml )
  public
    FileSize : Int64;
    FileTime : TDateTime;
    LocationID : string;
  public
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetLocationID( _LocationID : string );
    procedure Update;override;
  end;

    // 设置 子文件 位置
  TRestoreFileChildPositionXml = class( TRestoreFileChildChangeXml )
  private
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  end;

    // 移除 子文件
  TRestoreFileRemoveChildXml = class( TRestoreFileChildChangeXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 读取 ' }

    // 读取 文件节点
  TRestoreFileXmlReadHandle = class
  public
    RestoreFileNode : IXMLNode;
    FullPath, SavePath : string;
    RestorePcID : string;
  public
    constructor Create( _RestoreFileNode : IXMLNode );
    procedure SetPathInfo( _FullPath, _SavePath : string );
    procedure SetRestorePcID( _RestorePcID : string );
    procedure Update;
  end;

    // 读取 根节点
  TRestoreItemXmlReadHandle = class
  public
    RestoreItemNode : IXMLNode;
    FullPath, SavePath : string;
    RestorePcID : string;
  public
    constructor Create( _RestoreItemNode : IXMLNode );
    procedure Update;
  private
    procedure ReadRestoreFileList;
  end;

    // 读取 恢复文件 Xml
  TRestoreFileXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';
  Xml_SaveAsPath = 'sap';
  Xml_IsEncrypt = 'ie';
  Xml_Password = 'pw';
  Xml_FileSize = 'fs';
  Xml_CompletedSpace = 'cs';
  Xml_RestorePcID = 'rpi';
  Xml_RestoreFileList = 'rfl';

  Xml_LocationID = 'li';
  Xml_FileTime = 'ft';
  Xml_Position = 'ps';

implementation

uses URestoreFileFace, UMyNetPcInfo, UMyRestoreFileInfo, UJobFace, UMyJobInfo, UMyRestoreFileControl,
     UJobControl;

{ TRestoreFileChangeXml }

constructor TRestoreFileChangeXml.Create(_FullPath, _RestorePcID: string);
begin
  FullPath := _FullPath;
  RestorePcID := _RestorePcID;
end;

function TRestoreFileChangeXml.FindRestoreItemNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;

  for i := 0 to RestoreItemHashXml.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreItemHashXml.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath ) = FullPath ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestorePcID ) = RestorePcID )
    then
    begin
      RestoreItemIndex := i;
      RestoreItemNode := SelectNode;
      Result := True;
      Break;
    end;
  end;
end;

{ TRestoreFileAddRootXml }

procedure TRestoreFileAddRootXml.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreFileAddRootXml.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TRestoreFileAddRootXml.SetPathInfo(_PathType,
  _SaveAsPath: string);
begin
  PathType := _PathType;
  SaveAsPath := _SaveAsPath;
end;

procedure TRestoreFileAddRootXml.Update;
var
  EnctypedPassword : string;
begin
    // 已存在
  if FindRestoreItemNode then
    Exit;

    // 添加
  EnctypedPassword := MyEncrypt.EncodeStr( Password );

  RestoreItemNode := MyXmlUtil.AddListChild( RestoreItemHashXml );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_PathType, PathType );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_SaveAsPath, SaveAsPath );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_RestorePcID, RestorePcID );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_IsEncrypt, BoolToStr( IsEncrypted ) );
  MyXmlUtil.AddChild( RestoreItemNode, Xml_Password, EnctypedPassword );
end;

{ TRestoreFileAddChildXml }

procedure TRestoreFileAddChildXml.SetFileInfo(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TRestoreFileAddChildXml.SetLocationID(_LocationID: string);
begin
  LocationID := _LocationID;
end;

procedure TRestoreFileAddChildXml.Update;
begin
    // 根节点 不存在
  if not FindRootNode then
    Exit;

    // 添加
  ChildNode := MyXmlUtil.AddListChild( ChildListNode, FilePath );
  MyXmlUtil.AddChild( ChildNode, Xml_FullPath, FilePath );
  MyXmlUtil.AddChild( ChildNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( ChildNode, Xml_FileTime, FloatToStr( FileTime ) );
  MyXmlUtil.AddChild( ChildNode, Xml_LocationID, LocationID );
  MyXmlUtil.AddChild( ChildNode, Xml_Position, IntToStr(0) );
end;

{ TRestoreFileXmlRead }

procedure TRestoreFileXmlRead.Update;
var
  i : Integer;
  RestoreItemNode : IXMLNode;
  RestoreItemXmlReadHandle : TRestoreItemXmlReadHandle;
begin
  for i := 0 to RestoreItemHashXml.ChildNodes.Count - 1 do
  begin
    RestoreItemNode := RestoreItemHashXml.ChildNodes[i];
    RestoreItemXmlReadHandle := TRestoreItemXmlReadHandle.Create( RestoreItemNode );
    RestoreItemXmlReadHandle.Update;
    RestoreItemXmlReadHandle.Free;
  end;
end;

{ TRestoreFileChildChangeXml }

constructor TRestoreFileChildChangeXml.Create(_FilePath,
  _RestorePcID: string);
begin
  FilePath := _FilePath;
  RestorePcID := _RestorePcID;
end;

function TRestoreFileChildChangeXml.FindChildNode: Boolean;
var
  i : Integer;
  RestoreNode : IXMLNode;
  RestoreFilePath : string;
begin
  Result := False;

    // 根节点 不存在
  if not FindRootNode then
    Exit;

  for i := 0 to ChildListNode.ChildNodes.Count - 1 do
  begin
    RestoreNode := ChildListNode.ChildNodes[i];
    RestoreFilePath := MyXmlUtil.GetChildValue( RestoreNode, Xml_FullPath );
    if RestoreFilePath = FilePath then
    begin
      ChildNode := RestoreNode;
      Result := True;
      Break;
    end;
  end;
end;

function TRestoreFileChildChangeXml.FindRootNode: Boolean;
var
  i : Integer;
  RestoreItemNode : IXMLNode;
  RestoreItemPath : string;
begin
  Result := False;

  for i := 0 to RestoreItemHashXml.ChildNodes.Count - 1 do
  begin
    RestoreItemNode := RestoreItemHashXml.ChildNodes[i];
    RestoreItemPath := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_FullPath );
    if MyMatchMask.CheckEqualsOrChild( FilePath, RestoreItemPath ) and
       ( MyXmlUtil.GetChildValue( RestoreItemNode, Xml_RestorePcID ) = RestorePcID )
    then
    begin
      RootNode := RestoreItemNode;
      ChildListNode := MyXmlUtil.AddChild( RootNode, Xml_RestoreFileList );
      Result := True;
      Break;
    end;
  end;
end;

{ TRestoreFileRemoveChildXml }

procedure TRestoreFileRemoveChildXml.Update;
begin
    // 子节点 不存在
  if not FindRootNode then
    Exit;

    // 删除 子节点
  ChildListNode := MyXmlUtil.AddChild( RootNode, Xml_RestoreFileList );
  MyXmlUtil.DeleteListChild( ChildListNode, FilePath );
end;

{ TRestoreFileRemoveRootXml }

procedure TRestoreFileRemoveRootXml.Update;
begin
    // 不存在
  if not FindRestoreItemNode then
    Exit;

    // 删除
  RestoreItemHashXml.ChildNodes.Delete( RestoreItemIndex );
end;

{ TRestoreFileChildPositionXml }

procedure TRestoreFileChildPositionXml.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TRestoreFileChildPositionXml.Update;
begin
    // 子节点不存在
  if not FindChildNode then
    Exit;

  MyXmlUtil.AddChild( ChildNode, Xml_Position, IntToStr( Position ) );
end;

{ TRestoreItemXmlReadHandle }

constructor TRestoreItemXmlReadHandle.Create(_RestoreItemNode: IXMLNode);
begin
  RestoreItemNode := _RestoreItemNode;
end;

procedure TRestoreItemXmlReadHandle.ReadRestoreFileList;
var
  RestoreFileListNode : IXMLNode;
  i : Integer;
  RestoreFileNode : IXMLNode;
  RestoreFileXmlReadHandle : TRestoreFileXmlReadHandle;
begin
  RestoreFileListNode := MyXmlUtil.AddChild( RestoreItemNode, Xml_RestoreFileList );
  for i := 0 to RestoreFileListNode.ChildNodes.Count - 1 do
  begin
    RestoreFileNode := RestoreFileListNode.ChildNodes[i];
    RestoreFileXmlReadHandle := TRestoreFileXmlReadHandle.Create( RestoreFileNode );
    RestoreFileXmlReadHandle.SetPathInfo( FullPath, SavePath );
    RestoreFileXmlReadHandle.SetRestorePcID( RestorePcID );
    RestoreFileXmlReadHandle.Update;
    RestoreFileXmlReadHandle.Free;
  end;
end;

procedure TRestoreItemXmlReadHandle.Update;
var
  PathType : string;
  FileSize, CompletedSpace : Int64;
  IsEncrypted : Boolean;
  EncryptedPassword, Password : string;
  RestoreItemReadHandle : TRestoreItemReadHandle;
begin
    // 提取信息
  FullPath := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_PathType );
  SavePath := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_SaveAsPath );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( RestoreItemNode, Xml_FileSize ), 0 );
  CompletedSpace := MyXmlUtil.GetChildInt64Value(RestoreItemNode, Xml_CompletedSpace );
  RestorePcID := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_RestorePcID );
  IsEncrypted := StrToBoolDef( MyXmlUtil.GetChildValue( RestoreItemNode, Xml_IsEncrypt ), False );
  EncryptedPassword := MyXmlUtil.GetChildValue( RestoreItemNode, Xml_Password );
  Password := MyEncrypt.DecodeStr( EncryptedPassword );

    // 处理信息
  RestoreItemReadHandle := TRestoreItemReadHandle.Create( FullPath, RestorePcID );
  RestoreItemReadHandle.SetPathInfo( PathType, SavePath );
  RestoreItemReadHandle.SetSpaceInfo( FileSize, CompletedSpace );
  RestoreItemReadHandle.SetEncryptInfo( IsEncrypted, Password );
  RestoreItemReadHandle.Update;
  RestoreItemReadHandle.Free;

    // 读取 恢复文件列表
  ReadRestoreFileList;
end;

{ TRestoreFileXmlReadHandle1 }

constructor TRestoreFileXmlReadHandle.Create(_RestoreFileNode: IXMLNode);
begin
  RestoreFileNode := _RestoreFileNode;
end;

procedure TRestoreFileXmlReadHandle.SetPathInfo(_FullPath, _SavePath: string);
begin
  FullPath := _FullPath;
  SavePath := _SavePath;
end;

procedure TRestoreFileXmlReadHandle.SetRestorePcID(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

procedure TRestoreFileXmlReadHandle.Update;
var
  RestoreFilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  LocationID, DownFilePath : string;
  RestoreFileReadHandle : TRestoreFileReadHandle;
  TransferRestoreJobAddHandle : TTransferRestoreJobAddHandle;
begin
    // 提取信息
  RestoreFilePath := MyXmlUtil.GetChildValue( RestoreFileNode, Xml_FullPath );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( RestoreFileNode, Xml_FileSize ), 0 );
  Position := StrToInt64Def( MyXmlUtil.GetChildValue( RestoreFileNode, Xml_Position ), 0 );
  FileTime := StrToFloatDef( MyXmlUtil.GetChildValue( RestoreFileNode, Xml_FileTime ), Now );
  LocationID := MyXmlUtil.GetChildValue( RestoreFileNode, Xml_LocationID );

    // 处理信息
  RestoreFileReadHandle := TRestoreFileReadHandle.Create( RestoreFilePath, RestorePcID );
  RestoreFileReadHandle.SetLocationPcID( LocationID );
  RestoreFileReadHandle.SetSpaceInfo( FileSize, Position );
  RestoreFileReadHandle.SetFileTime( FileTime );
  RestoreFileReadHandle.Update;
  RestoreFileReadHandle.Free;

    // 续传 恢复 Job
  DownFilePath := StringReplace( RestoreFilePath, FullPath, SavePath, [] );
  TransferRestoreJobAddHandle := TTransferRestoreJobAddHandle.Create( RestoreFilePath, LocationID );
  TransferRestoreJobAddHandle.SetRestorePcID( RestorePcID );
  TransferRestoreJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferRestoreJobAddHandle.SetDownFilePath( DownFilePath );
  TransferRestoreJobAddHandle.Update;
  TransferRestoreJobAddHandle.Free;
end;

{ TRestoreFileAddRootSize }

procedure TRestoreFileAddRootSizeXml.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TRestoreFileAddRootSizeXml.Update;
var
  RootSize : Int64;
begin
    // 根目录不存在
  if not FindRestoreItemNode then
    Exit;

    // 刷新 总空间数
  RootSize := MyXmlUtil.GetChildInt64Value( RestoreItemNode, Xml_FileSize );
  RootSize := RootSize + FileSize;
  MyXmlUtil.AddChild( RestoreItemNode, Xml_FileSize, RootSize );
end;

{ TRestoreFileAddRootCompletedSize }

procedure TRestoreFileAddRootCompletedSizeXml.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TRestoreFileAddRootCompletedSizeXml.Update;
var
  RootCompletedSpace : Int64;
begin
    // 根目录不存在
  if not FindRestoreItemNode then
    Exit;

    // 刷新 总空间数
  RootCompletedSpace := MyXmlUtil.GetChildInt64Value( RestoreItemNode, Xml_CompletedSpace );
  RootCompletedSpace := RootCompletedSpace + CompletedSize;
  MyXmlUtil.AddChild( RestoreItemNode, Xml_CompletedSpace, RootCompletedSpace );
end;

end.
