unit UMyShareXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils;

type

{$Region ' 我的 共享路径 ' }

  {$Region ' 修改 Xml 信息 ' }

    // 修改 指定路径 父类
  TSharePathWriteXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    SharePathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode : Boolean;
  end;

    // 添加
  TSharePathAddXml = class( TSharePathWriteXml )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // 删除
  TSharePathRemoveXml = class( TSharePathWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 读取 Xml 信息 ' }

    // 读取信息
  TSharePathXmlRead = class
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 下载 共享路径 ' }

    // 修改 父类
  TShareDownWriteXml = class( TChangeInfo )
  public
    DesPcID : string;
    FullPath : string;
  protected
    ShareDownIndex : Integer;
    ShareDownNode : IXMLNode;
  public
    constructor Create( _DesPcID, _FullPath : string );
  protected
    function FindShareDownNode : Boolean;
  end;

  {$Region ' 修改 根节点 ' }

    // 添加
  TShareDownAddXml = class( TShareDownWriteXml )
  private
    PathType : string;
    SavaPath : string;
    FileSize, CompletedSize : Int64;
    Status : string;
  public
    procedure SetPathType( _PathType : string );
    procedure SetSavePath( _SavaPath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetStatus( _Status : string );
    procedure Update;override;
  private
    procedure RefreshTotalShareDown;
  end;

    // 添加 文件空间
  TShareDownAddFileSizeXml = class( TShareDownWriteXml )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成空间
  TShareDownAddCompletedSizeXml = class( TShareDownWriteXml )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 已完成空间
  TShareDownSetCompletedSizeXml = class( TShareDownWriteXml )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedsize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 设置 状态
  TShareDownSetStatusXml = class( TShareDownWriteXml )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 清空 子节点
  TShareDownClearChildXml = class( TShareDownWriteXml )
  public
    procedure Update;override;
  end;

    // 删除
  TShareDownRemoveXml = class( TShareDownWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子节点 ' }

      // 修改
  TShareDownChildChangeXml = class( TShareDownWriteXml )
  public
    FilePath : string;
  private
    FileListNode : IXMLNode;
    FileNode : IXMLNode;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindFileNode : Boolean;
  end;

      // 添加
  TShareDownChildAddXml = class( TShareDownChildChangeXml )
  private
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
    Status : string;
  public
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // 设置 已完成空间
  TShareDownChildSetCompletedSizeXml = class( TShareDownChildChangeXml )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

     // 设置 文件状态
  TShareDownChildSetStatusXml = class( TShareDownChildChangeXml )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // 删除
  TShareDownChildRemoveXml = class( TShareDownChildChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 读取 ' }

  TShareDownFileListReadXml = class
  public
    FileListNode : IXMLNode;
  public
    FullPath, DesPcID : string;
  public
    constructor Create( _FileListNode : IXMLNode );
    procedure SetParentInfo( _FullPath, _DesPcID : string );
    procedure Update;
  end;

    // 读取信息
  TShareDownXmlRead = class
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 下载历史路径 ' }

    // 修改
  TShareHistoryWriteXml = class( TChangeInfo )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathIndex : Integer;
    PathNode : IXMLNode;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // 添加
  TShareHistoryAddXml = class( TShareHistoryWriteXml )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // 删除
  TShareHistoryRemoveXml = class( TShareHistoryWriteXml )
  public
    procedure Update;override;
  end;

    // 读取
  TShareHistoryXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 收藏夹路径 ' }

    // 修改
  TShareFavoriteWriteXml = class( TChangeInfo )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathIndex : Integer;
    PathNode : IXMLNode;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // 添加
  TShareFavoriteAddXml = class( TShareFavoriteWriteXml )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // 删除
  TShareFavoriteRemoveXml = class( TShareFavoriteWriteXml )
  public
    procedure Update;override;
  end;

    // 读取
  TShareFavoriteXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 辅助类 ' }

  MyShareDownXmlUtil = class
  public
    class function getTotalCount : Integer;
  end;

{$EndRegion}

const
  Xml_TotalShareDownCount = 'tsdc';

  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';

  Xml_DesPcID = 'dp';
  Xml_SavePath = 'sp';
  Xml_FileSize = 'fs';
  Xml_CompletedSize = 'cs';
  Xml_FileList = 'fl';
  Xml_FilePath = 'fp';
  Xml_FileTime = 'ft';
  Xml_Status = 'st';

implementation

uses UMyShareControl;

{ TSharePathWriteXml }

constructor TSharePathWriteXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TSharePathWriteXml.FindSharePathNode: Boolean;
begin
  SharePathNode := MyXmlUtil.FindListChild( SharePathListXml, FullPath );
  Result := SharePathNode <> nil;
end;

{ TSharePathAddXml }

procedure TSharePathAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TSharePathAddXml.Update;
begin
  inherited;

    // 已存在
  if FindSharePathNode then
    Exit;

    // 添加
  SharePathNode := MyXmlUtil.AddListChild( SharePathListXml, FullPath );
  MyXmlUtil.AddChild( SharePathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( SharePathNode, Xml_PathType, PathType );
end;

{ TSharePathRemoveXml }

procedure TSharePathRemoveXml.Update;
begin
  inherited;

    // 不存在
  if not FindSharePathNode then
    Exit;

    // 删除
  MyXmlUtil.DeleteListChild( SharePathListXml, FullPath );
end;

{ TSharePathXmlRead }

procedure TSharePathXmlRead.Update;
var
  i : Integer;
  SharePathNode : IXMLNode;
  FullPath, PathType : string;
  SharePathReadHandle : TSharePathReadHandle;
begin
  for i := 0 to SharePathListXml.ChildNodes.Count - 1 do
  begin
    SharePathNode := SharePathListXml.ChildNodes[i];
    FullPath := MyXmlUtil.GetChildValue( SharePathNode, Xml_FullPath );
    PathType := MyXmlUtil.GetChildValue( SharePathNode, Xml_PathType );

      // 处理读取的 共享路径信息
    SharePathReadHandle := TSharePathReadHandle.Create( FullPath );
    SharePathReadHandle.SetPathType( PathType );
    SharePathReadHandle.Update;
    SharePathReadHandle.Free;
  end;
end;

{ TShareDownWriteXml }

constructor TShareDownWriteXml.Create(_DesPcID, _FullPath: string);
begin
  DesPcID := _DesPcID;
  FullPath := _FullPath;
end;

function TShareDownWriteXml.FindShareDownNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
  SelectDesPcID, SelectFullPath : string;
begin
  Result := False;

  for i := 0 to ShareDownListXml.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareDownListXml.ChildNodes[i];
    SelectDesPcID := MyXmlUtil.GetChildValue( SelectNode, Xml_DesPcID );
    SelectFullPath := MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath );

    if ( SelectDesPcID = DesPcID ) and
       ( SelectFullPath = FullPath )
    then
    begin
      ShareDownNode := SelectNode;
      ShareDownIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TShareDownAddXml }

procedure TShareDownAddXml.RefreshTotalShareDown;
var
  TotalSendCount : Integer;
begin
  TotalSendCount := MyXmlUtil.GetChildIntValue( MySharePathXml, Xml_TotalShareDownCount );
  TotalSendCount := TotalSendCount + 1;
  MyXmlUtil.AddChild( MySharePathXml, Xml_TotalShareDownCount, TotalSendCount );
end;

procedure TShareDownAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareDownAddXml.SetSavePath(_SavaPath: string);
begin
  SavaPath := _SavaPath;
end;

procedure TShareDownAddXml.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownAddXml.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareDownAddXml.Update;
begin
  inherited;

    // 已存在
  if FindShareDownNode then
    Exit;

    // 添加
  ShareDownNode := MyXmlUtil.AddListChild( ShareDownListXml );
  MyXmlUtil.AddChild( ShareDownNode, Xml_DesPcID, DesPcID );
  MyXmlUtil.AddChild( ShareDownNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( ShareDownNode, Xml_PathType, PathType );
  MyXmlUtil.AddChild( ShareDownNode, Xml_SavePath, SavaPath );
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, IntToStr( CompletedSize ) );
  MyXmlUtil.AddChild( ShareDownNode, Xml_Status, Status );

    // 刷新 下载次数
  RefreshTotalShareDown;
end;

{ TShareDownRemoveXml }

procedure TShareDownRemoveXml.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

    // 删除
  ShareDownListXml.ChildNodes.Delete( ShareDownIndex );
end;

{ TShareDownAddFileSizeXml }

procedure TShareDownAddFileSizeXml.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TShareDownAddFileSizeXml.Update;
var
  OldFileSize, NewFileSize : Int64;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  OldFileSize := StrToInt64Def( MyXmlUtil.GetChildValue( ShareDownNode, Xml_FileSize ), 0 );
  NewFileSize := OldFileSize + FileSize;
  MyXmlUtil.AddChild( ShareDownNode, Xml_FileSize, IntToStr( NewFileSize ) );
end;

{ TShareDownAddCompletedSizeXml }

procedure TShareDownAddCompletedSizeXml.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownAddCompletedSizeXml.Update;
var
  OldCompletedSize, NewCompletedSize : Int64;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  OldCompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( ShareDownNode, Xml_CompletedSize ), 0 );
  NewCompletedSize := OldCompletedSize + CompletedSize;
  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, IntToStr( NewCompletedSize ) );
end;

{ TShareDownChildChangeXml }

function TShareDownChildChangeXml.FindFileNode: Boolean;
begin
  Result := False;
  if not FindShareDownNode then
    Exit;

    // List Node
  FileListNode := MyXmlUtil.AddChild( ShareDownNode, Xml_FileList );

  FileNode := MyXmlUtil.FindListChild( FileListNode, FilePath );
  Result := FileNode <> nil;
end;

procedure TShareDownChildChangeXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TShareDownChildAddXml }

procedure TShareDownChildAddXml.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownChildAddXml.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownChildAddXml.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareDownChildAddXml.Update;
begin
  inherited;

    // 已存在
  if not FindShareDownNode then
    Exit;

    // List Node
  FileListNode := MyXmlUtil.AddChild( ShareDownNode, Xml_FileList );

    // 添加
  FileNode := MyXmlUtil.AddListChild( FileListNode, FilePath );
  MyXmlUtil.AddChild( FileNode, Xml_FilePath, FilePath );
  MyXmlUtil.AddChild( FileNode, Xml_DesPcID, DesPcID );
  MyXmlUtil.AddChild( FileNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( FileNode, Xml_CompletedSize, IntToStr( CompletedSize ) );
  MyXmlUtil.AddChild( FileNode, Xml_FileTime, FloatToStr( FileTime ) );
  MyXmlUtil.AddChild( FileNode, Xml_Status, Status );
end;

{ TShareDownChildRemoveXml }

procedure TShareDownChildRemoveXml.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

    // 删除
  MyXmlUtil.DeleteListChild( FileListNode, FilePath );
end;

{ TShareDownXmlRead }

procedure TShareDownXmlRead.Update;
var
  i : Integer;
  ShareDownNode : IXMLNode;
  FullPath, PathType : string;
  DesPcID, SavePath : string;
  FileSize, CompletedSize : Int64;
  Status : string;
  ShareFileDownReadHanlde : TShareFileDownReadHanlde;
  FileListNode : IXMLNode;
  ShareDownFileListReadXml : TShareDownFileListReadXml;
begin
  for i := 0 to ShareDownListXml.ChildNodes.Count - 1 do
  begin
    ShareDownNode := ShareDownListXml.ChildNodes[i];
    FullPath := MyXmlUtil.GetChildValue( ShareDownNode, Xml_FullPath );
    PathType := MyXmlUtil.GetChildValue( ShareDownNode, Xml_PathType );
    SavePath := MyXmlUtil.GetChildValue( ShareDownNode, Xml_SavePath );
    DesPcID := MyXmlUtil.GetChildValue( ShareDownNode, Xml_DesPcID );
    FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( ShareDownNode, Xml_FileSize ), 0 );
    CompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( ShareDownNode, Xml_CompletedSize ), 0 );
    Status := MyXmlUtil.GetChildValue( ShareDownNode, Xml_Status );

      // 读取根目录
    ShareFileDownReadHanlde := TShareFileDownReadHanlde.Create( DesPcID, FullPath );
    ShareFileDownReadHanlde.SetPathType( PathType );
    ShareFileDownReadHanlde.SetSavePath( SavePath );
    ShareFileDownReadHanlde.SetSizeInfo( FileSize, CompletedSize );
    ShareFileDownReadHanlde.SetStatus( Status );
    ShareFileDownReadHanlde.Update;
    ShareFileDownReadHanlde.Free;

      // 读取文件列表
    FileListNode := MyXmlUtil.AddChild( ShareDownNode, Xml_FileList );

    ShareDownFileListReadXml := TShareDownFileListReadXml.Create( FileListNode );
    ShareDownFileListReadXml.SetParentInfo( FullPath, DesPcID );
    ShareDownFileListReadXml.Update;
    ShareDownFileListReadXml.Free;
  end;
end;

{ TShareDownFileListRead }

constructor TShareDownFileListReadXml.Create(_FileListNode: IXMLNode);
begin
  FileListNode := _FileListNode;
end;

procedure TShareDownFileListReadXml.SetParentInfo(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

procedure TShareDownFileListReadXml.Update;
var
  i : Integer;
  FileNode : IXMLNode;
  FilePath : string;
  FileSize, CompletedSize : Int64;
  FileTime : TDateTime;
  Status : string;
  ShareFileDownChildReadHandle : TShareFileDownChildReadHandle;
begin
  for i := 0 to FileListNode.ChildNodes.Count - 1 do
  begin
    FileNode := FileListNode.ChildNodes[i];
    FilePath := MyXmlUtil.GetChildValue( FileNode, Xml_FilePath );
    FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( FileNode, Xml_FileSize ), 0 );
    CompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( FileNode, Xml_CompletedSize ), 0 );
    FileTime := StrToFloatDef( MyXmlUtil.GetChildValue( FileNode, Xml_FileTime ), Now );
    Status := MyXmlUtil.GetChildValue( FileNode, Xml_Status );

    ShareFileDownChildReadHandle := TShareFileDownChildReadHandle.Create( DesPcID, FullPath );
    ShareFileDownChildReadHandle.SetFilePath( FilePath );
    ShareFileDownChildReadHandle.SetSizeInfo( FileSize, CompletedSize );
    ShareFileDownChildReadHandle.SetFileTime( FileTime );
    ShareFileDownChildReadHandle.SetStatus( Status );
    ShareFileDownChildReadHandle.Update;
    ShareFileDownChildReadHandle.Free;
  end;
end;

{ TShareDownChildSetCompletedSizeXml }

procedure TShareDownChildSetCompletedSizeXml.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownChildSetCompletedSizeXml.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

  MyXmlUtil.AddChild( FileNode, Xml_CompletedSize, IntToStr( CompletedSize ) );
end;

{ TShareDownChildSetStatusXml }

procedure TShareDownChildSetStatusXml.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareDownChildSetStatusXml.Update;
begin
  inherited;

    // 不存在
  if not FindFileNode then
    Exit;

  MyXmlUtil.AddChild( FileNode, Xml_Status, Status );
end;

{ TShareDownSetStatusXml }

procedure TShareDownSetStatusXml.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TShareDownSetStatusXml.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  MyXmlUtil.AddChild( ShareDownNode, Xml_Status, Status );
end;

{ TShareDownSetCompletedSizeXml }

procedure TShareDownSetCompletedSizeXml.SetCompletedsize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TShareDownSetCompletedSizeXml.Update;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

  MyXmlUtil.AddChild( ShareDownNode, Xml_CompletedSize, IntToStr( CompletedSize ) );
end;

{ TShareHistoryWriteXml }

constructor TShareHistoryWriteXml.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TShareHistoryWriteXml.FindPathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
  SelectFullPath, SelectPcID : string;
begin
  Result := False;

  for i := 0 to ShareHisrotyListXml.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareHisrotyListXml.ChildNodes[i];
    SelectFullPath := MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath );
    SelectPcID := MyXmlUtil.GetChildValue( SelectNode, Xml_DesPcID );

    if ( SelectFullPath = FullPath ) and
       ( SelectPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TShareHistoryAddXml }

procedure TShareHistoryAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareHistoryAddXml.Update;
begin
  inherited;

    // 已存在
  if FindPathNode then
    Exit;

    // 添加
  PathNode := MyXmlUtil.AddListChild( ShareHisrotyListXml );
  MyXmlUtil.AddChild( PathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( PathNode, Xml_DesPcID, DesPcID );
  MyXmlUtil.AddChild( PathNode, Xml_PathType, PathType );
end;

{ TShareHistoryRemoveXml }

procedure TShareHistoryRemoveXml.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

  ShareHisrotyListXml.ChildNodes.Delete( PathIndex );
end;

{ TShareFavoriteWriteXml }

constructor TShareFavoriteWriteXml.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TShareFavoriteWriteXml.FindPathNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
  SelectFullPath, SelectPcID : string;
begin
  Result := False;

  for i := 0 to ShareFavoriteListXml.ChildNodes.Count - 1 do
  begin
    SelectNode := ShareFavoriteListXml.ChildNodes[i];
    SelectFullPath := MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath );
    SelectPcID := MyXmlUtil.GetChildValue( SelectNode, Xml_DesPcID );

    if ( SelectFullPath = FullPath ) and
       ( SelectPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      PathIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TShareFavoriteAddXml }

procedure TShareFavoriteAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TShareFavoriteAddXml.Update;
begin
  inherited;

    // 已存在
  if FindPathNode then
    Exit;

    // 添加
  PathNode := MyXmlUtil.AddListChild( ShareFavoriteListXml );
  MyXmlUtil.AddChild( PathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( PathNode, Xml_DesPcID, DesPcID );
  MyXmlUtil.AddChild( PathNode, Xml_PathType, PathType );
end;

{ TShareFavoriteRemoveXml }

procedure TShareFavoriteRemoveXml.Update;
begin
  inherited;

    // 不存在
  if not FindPathNode then
    Exit;

  ShareFavoriteListXml.ChildNodes.Delete( PathIndex );
end;

{ TShareHistoryXmlRead }

procedure TShareHistoryXmlRead.Update;
var
  i : Integer;
  PathNode : IXMLNode;
  FullPath, DesPcID, PathType : string;
  ShareHistoryReadHandle : TShareHistoryReadHandle;
begin
  for i := 0 to ShareHisrotyListXml.ChildNodes.Count - 1 do
  begin
    PathNode := ShareHisrotyListXml.ChildNodes[i];
    FullPath := MyXmlUtil.GetChildValue( PathNode, Xml_FullPath );
    DesPcID := MyXmlUtil.GetChildValue( PathNode, Xml_DesPcID );
    PathType := MyXmlUtil.GetChildValue( PathNode, Xml_PathType );

    ShareHistoryReadHandle := TShareHistoryReadHandle.Create( FullPath, DesPcID );
    ShareHistoryReadHandle.SetPathType( PathType );
    ShareHistoryReadHandle.Update;
    ShareHistoryReadHandle.Free;
  end;
end;

{ TShareFavoriteXmlRead }

procedure TShareFavoriteXmlRead.Update;
var
  i : Integer;
  PathNode : IXMLNode;
  FullPath, DesPcID, PathType : string;
  ShareFavorityReadHandle : TShareFavorityReadHandle;
begin
  for i := 0 to ShareFavoriteListXml.ChildNodes.Count - 1 do
  begin
    PathNode := ShareFavoriteListXml.ChildNodes[i];
    FullPath := MyXmlUtil.GetChildValue( PathNode, Xml_FullPath );
    DesPcID := MyXmlUtil.GetChildValue( PathNode, Xml_DesPcID );
    PathType := MyXmlUtil.GetChildValue( PathNode, Xml_PathType );

    ShareFavorityReadHandle := TShareFavorityReadHandle.Create( FullPath, DesPcID );
    ShareFavorityReadHandle.SetPathType( PathType );
    ShareFavorityReadHandle.Update;
    ShareFavorityReadHandle.Free;
  end;
end;

{ TShareDownClearChildXml }

procedure TShareDownClearChildXml.Update;
var
  FileListNode : IXMLNode;
begin
  inherited;

    // 不存在
  if not FindShareDownNode then
    Exit;

    // List Node
  FileListNode := MyXmlUtil.AddChild( ShareDownNode, Xml_FileList );
  FileListNode.ChildNodes.Clear;
end;

{ MyShareDownXmlUtil }

class function MyShareDownXmlUtil.getTotalCount: Integer;
begin
  Result := MyXmlUtil.GetChildIntValue( MySharePathXml, Xml_TotalShareDownCount );
end;

end.
