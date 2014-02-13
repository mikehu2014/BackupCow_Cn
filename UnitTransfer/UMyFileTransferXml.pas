unit UMyFileTransferXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils, uDebug;

type

{$Region ' 传输文件 发送 Xml ' }

  {$Region ' 修改 ' }

    // 修改 单项 父类
  TFileSendWriteXml = class( TChangeInfo )
  public
    SendFilePath, DesPcID : string;
  public
    constructor Create( _SendFilePath, _DesPcID : string );
  protected
    function FindRootIndex : Integer;
    function FindRootNode : IXMLNode;
  end;

  {$Region ' 修改 根节点 ' }

    // 添加 根节点
  TFileSendAddRootXml = class( TFileSendWriteXml )
  private
    SendPathStatus : string;
    SendPathType : string;
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSendPathStatus( _SendPathStatus : string );
    procedure SetSendPathType( _SendPathType : string );
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  private
    procedure RefreshTotalSend;
  end;

    // 改变 发送根的状态
  TFileSendRootStatusXml = class( TFileSendWriteXml )
  private
    SendPathStatus : string;
  public
    procedure SetSendPathStatus( _SendPathStatus : string );
    procedure Update;override;
  end;

    // 修改 节点空间信息
  TFileSendSpaceXml = class( TFileSendWriteXml )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成 空间信息
  TFileSendAddCompletedSpaceXml = class( TFileSendWriteXml )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // 清空 子节点
  TFileSendClearChildXml = class( TFileSendWriteXml )
  public
    procedure Update;override;
  end;

      // 删除
  TFileSendRemoveXml = class( TFileSendWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 修改 子节点 ' }

    // 修改 子节点
  TFileSendWriteChildXml = class( TFileSendWriteXml )
  public
    ChildFilePath : string;
  public
    procedure SetFilePath( _ChildFilePath : string );
  end;

    // 添加 子节点
  TFileSendAddChildXml = class( TFileSendWriteChildXml )
  public
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;override;
  end;

    // 删除 子节点
  TFileSendRemoveChildXml = class( TFileSendWriteChildXml )
  public
    procedure Update;override;
  end;

    // 修改 子节点 位置信息
  TFileSendChildPositionXml = class( TFileSendWriteChildXml )
  private
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' 取消发送 ' }

    // 修改 单项 父类
  TFileSendCancelWriteXml = class( TChangeInfo )
  public
    SendFilePath, DesPcID : string;
  public
    constructor Create( _SendFilePath, _DesPcID : string );
  end;

    // 添加
  TFileSendCancelAddXml = class( TFileSendCancelWriteXml )
  public
    procedure Update;override;
  end;

    // 删除
  TFileSendCancelRemoveXml = class( TFileSendCancelWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 读取 ' }

    // 读取 发送的子文件信息
  TFileSendChildPathReadXml = class
  public
    ChildFileList : IXMLNode;
    SendFilePath, DesPcID : string;
  public
    constructor Create( _ChildFileList : IXMLNode );
    procedure SetSendInfo( _SendFilePath, _DesPcID : string );
    procedure Update;
  end;

    // 读取 上一次 发送文件信息
  TFileSendReadXml = class
  public
    procedure Update;
  private
    procedure ReadFileSendList;
    procedure ReadFileSendCancelList;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 传输文件 接收 Xml ' }

  {$Region ' 修改 ' }

    // 修改 单项 父类
  TFileReceiveWriteXml = class( TChangeInfo )
  public
    SourceFilePath, SourcePcID : string;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
  protected
    function FindNodeIndex : Integer;
    function FindExistNode : IXMLNode;
  end;

    // 添加 根节点
  TFileReceiveAddXml = class( TFileReceiveWriteXml )
  public
    ReceivePath : string;
    SendPathType : string;
    ReceiveStatus : string;
  public
    procedure SetReceivePath( _ReceivePath : string );
    procedure SetSendPathType( _SendPathType : string );
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;override;
  end;

    // 删除
  TFileReceiveRemoveXml = class( TFileReceiveWriteXml )
  public
    procedure Update;override;
  end;

    // 设置 路径空间
  TFileReceiveSetSpaceXml = class( TFileReceiveWriteXml )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成空间
  TFileReceiveAddCompletedSpaceXml = class( TFileReceiveWriteXml )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;


    // 设置 路径状态
  TFileReceiveSetStatusXml = class( TFileReceiveWriteXml )
  private
    ReceiveStatus : string;
  public
    procedure SetStatus( _ReceiveStatus : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 取消接收 ' }

      // 修改 单项 父类
  TFileReceiveCancelWriteXml = class( TChangeInfo )
  public
    SourceFilePath, SourcePcID : string;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
  end;

    // 添加
  TFileReceiveCancelAddXml = class( TFileReceiveCancelWriteXml )
  public
    procedure Update;override;
  end;

    // 删除
  TFileReceiveCancelRemoveXml = class( TFileReceiveCancelWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 读取 ' }

    // 读取
  TFileReceiveReadXml = class
  public
    procedure Update;
  private
    procedure ReadFileReceiveList;
    procedure ReadFileReceiveCancelList;
    procedure StartRevFileFace;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 辅助类 ' }

  MyFileSendXmlUtil = class
  public
    class function getTotalCount : Integer;
  end;

{$EndRegion}

const
  Xml_TotalSendCount = 'tsc';
  Xml_TotalShareDownCount = 'tsdc';

    // 接收文件  节点信息
  Xml_SourceFilePath = 'sfp';
  Xml_SourcePcID = 'spi';
  Xml_ReceivePath = 'rp';
  Xml_SendFileType = 'sft';
  Xml_ReceiveFileStatus = 'rfs';

    // 发送文件  节点信息
  Xml_SendFilePath = 'sfp';
  Xml_DesPcID = 'dpi';
  Xml_SendPathStatus = 'sps';
  Xml_SendPathType = 'spt';
  Xml_ChildFileList = 'cfl';
  Xml_CompletedSize = 'cs';

  Xml_ChildPath = 'cp';
  Xml_FileSize = 'fs';
  Xml_FileTime = 'ft';
  Xml_Position = 'pt';
  Xml_FileCount = 'fc';

implementation

uses UMyFileTransferControl, UFileTransferFace;

{ TFileReceiveWriteXml }

constructor TFileReceiveWriteXml.Create(_SourceFilePath, _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

function TFileReceiveWriteXml.FindExistNode: IXMLNode;
var
  i : Integer;
begin
  i := FindNodeIndex;
  if i = -1 then
    Result := nil
  else
    Result := FileReceiveListXml.ChildNodes[i];
end;

function TFileReceiveWriteXml.FindNodeIndex: Integer;
var
  i : Integer;
  Node : IXMLNode;
  SelectSourceFilePath, SelectSourcePcID : string;
begin
  Result := -1;

  for i := 0 to FileReceiveListXml.ChildNodes.Count - 1 do
  begin
    Node := FileReceiveListXml.ChildNodes[ i ];
    SelectSourceFilePath := MyXmlUtil.GetChildValue( Node, Xml_SourceFilePath );
    SelectSourcePcID := MyXmlUtil.GetChildValue( Node, Xml_SourcePcID );

    if ( SelectSourceFilePath = SourceFilePath ) and
       ( SelectSourcePcID = SourcePcID )
    then
    begin
      Result := i;
      Break;
    end;
  end;
end;

{ TFileReceiveAddXml }

procedure TFileReceiveAddXml.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

procedure TFileReceiveAddXml.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TFileReceiveAddXml.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TFileReceiveAddXml.Update;
var
  Node : IXMLNode;
begin
  inherited;

    // 已存在
  if FindExistNode <> nil then
    Exit;

    // 不存在 则添加
  Node := MyXmlUtil.AddListChild( FileReceiveListXml );
  MyXmlUtil.AddChild( Node, Xml_SourceFilePath, SourceFilePath );
  MyXmlUtil.AddChild( Node, Xml_SourcePcID, SourcePcID );
  MyXmlUtil.AddChild( Node, Xml_ReceivePath, ReceivePath );
  MyXmlUtil.AddChild( Node, Xml_SendFileType, SendPathType );
  MyXmlUtil.AddChild( Node, Xml_ReceiveFileStatus, ReceiveStatus );
end;

{ TFileReceiveRemoveXml }

procedure TFileReceiveRemoveXml.Update;
var
  DeleteIndex : Integer;
begin
  inherited;

  DeleteIndex := FindNodeIndex;

    // 不存在 则跳过
  if DeleteIndex = -1 then
    Exit;

    // 存在 则删除
  FileReceiveListXml.ChildNodes.Delete( DeleteIndex );
end;

{ TFileSendWriteXml }

constructor TFileSendWriteXml.Create(_SendFilePath, _DesPcID: string);
begin
  SendFilePath := _SendFilePath;
  DesPcID := _DesPcID;
end;

function TFileSendWriteXml.FindRootNode: IXMLNode;
var
  i : Integer;
begin
  i := FindRootIndex;
  if i = -1 then
    Result := nil
  else
    Result := FileSendListXml.ChildNodes[i];
end;

function TFileSendWriteXml.FindRootIndex: Integer;
var
  i : Integer;
  Node : IXMLNode;
  SelectSendFilePath, SelectDesPcID : string;
begin
  Result := -1;

  for i := 0 to FileSendListXml.ChildNodes.Count - 1 do
  begin
    Node := FileSendListXml.ChildNodes[ i ];
    SelectSendFilePath := MyXmlUtil.GetChildValue( Node, Xml_SendFilePath );
    SelectDesPcID := MyXmlUtil.GetChildValue( Node, Xml_DesPcID );

    if ( SelectSendFilePath = SendFilePath ) and
       ( SelectDesPcID = DesPcID )
    then
    begin
      Result := i;
      Break;
    end;
  end;
end;

{ TFileSendAddRootXml }

procedure TFileSendAddRootXml.RefreshTotalSend;
var
  TotalSendCount : Integer;
begin
  TotalSendCount := MyXmlUtil.GetChildIntValue( MyFileSendXml, Xml_TotalSendCount );
  TotalSendCount := TotalSendCount + 1;
  MyXmlUtil.AddChild( MyFileSendXml, Xml_TotalSendCount, TotalSendCount );
end;

procedure TFileSendAddRootXml.SetSendPathStatus(_SendPathStatus: string);
begin
  SendPathStatus := _SendPathStatus;
end;

procedure TFileSendAddRootXml.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TFileSendAddRootXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TFileSendAddRootXml.Update;
var
  Node : IXMLNode;
begin
  inherited;

    // 已存在
  if FindRootNode <> nil then
    Exit;

    // 不存在 则添加
  Node := MyXmlUtil.AddListChild( FileSendListXml );
  MyXmlUtil.AddChild( Node, Xml_SendFilePath, SendFilePath );
  MyXmlUtil.AddChild( Node, Xml_DesPcID, DesPcID );
  MyXmlUtil.AddChild( Node, Xml_SendPathStatus, SendPathStatus );
  MyXmlUtil.AddChild( Node, Xml_SendPathType, SendPathType );
  MyXmlUtil.AddChild( Node, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( Node, Xml_FileCount, IntToStr( FileCount ) );

    // 刷新总发送
  RefreshTotalSend;
end;

{ TFileSendWriteChildXml }

procedure TFileSendWriteChildXml.SetFilePath(_ChildFilePath: string);
begin
  ChildFilePath := _ChildFilePath;
end;

{ TFileSendAddChildXml }

procedure TFileSendAddChildXml.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TFileSendAddChildXml.Update;
var
  RootNode, ChildFileListNode : IXMLNode;
  ChildNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 文件集合 节点
  ChildFileListNode := MyXmlUtil.AddChild( RootNode, Xml_ChildFileList );

    // 添加 文件节点
  ChildNode := MyXmlUtil.AddListChild( ChildFileListNode, ChildFilePath );
  MyXmlUtil.AddChild( ChildNode, Xml_ChildPath, ChildFilePath );
  MyXmlUtil.AddChild( ChildNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( ChildNode, Xml_FileTime, FloatToStr( FileTime ) );
end;

{ TFileSendRemoveChildXml }

procedure TFileSendRemoveChildXml.Update;
var
  RootNode, ChildFileListNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 文件集合 节点
  ChildFileListNode := MyXmlUtil.AddChild( RootNode, Xml_ChildFileList );

    // 删除 文件节点
  MyXmlUtil.DeleteListChild( ChildFileListNode, ChildFilePath );
end;

{ TFileSendRemoveXml }

procedure TFileSendRemoveXml.Update;
var
  DeleteIndex : Integer;
begin
  inherited;

  DeleteIndex := FindRootIndex;

    // 不存在 则跳过
  if DeleteIndex = -1 then
    Exit;

    // 存在 则删除
  FileSendListXml.ChildNodes.Delete( DeleteIndex );
end;

{ TFileSendReadXml }

procedure TFileSendReadXml.ReadFileSendCancelList;
var
  i : Integer;
  Node : IXMLNode;
  SendFilePath, DesPcID : string;
  SendFileCancelReadHandle : TSendFileCancelReadHandle;
begin
  for i := 0 to FileSendCancelListXml.ChildNodes.Count - 1 do
  begin
    Node := FileSendCancelListXml.ChildNodes[i];
    SendFilePath := MyXmlUtil.GetChildValue( Node, Xml_SendFilePath );
    DesPcID := MyXmlUtil.GetChildValue( Node, Xml_DesPcID );

    SendFileCancelReadHandle := TSendFileCancelReadHandle.Create( SendFilePath, DesPcID );
    SendFileCancelReadHandle.Update;
    SendFileCancelReadHandle.Free;
  end;
end;
procedure TFileSendReadXml.ReadFileSendList;
var
  i : Integer;
  Node, ChildFileNodeList : IXMLNode;
  SendFilePath, DesPcID : string;
  RootSpace, CompletedSize : Int64;
  FileCount : Integer;
  SendPathStatus, SendPathType : string;
  SendFileReadRootHandle : TSendFileReadRootHandle;
  FileSendChildPathReadXml : TFileSendChildPathReadXml;
begin
  for i := 0 to FileSendListXml.ChildNodes.Count - 1 do
  begin
    Node := FileSendListXml.ChildNodes[i];
    SendFilePath := MyXmlUtil.GetChildValue( Node, Xml_SendFilePath );
    DesPcID := MyXmlUtil.GetChildValue( Node, Xml_DesPcID );
    RootSpace := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_FileSize ), 0 );
    CompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_CompletedSize ), 0 );
    FileCount := StrToIntDef( MyXmlUtil.GetChildValue( Node, Xml_FileCount ), 0 );
    SendPathStatus := MyXmlUtil.GetChildValue( Node, Xml_SendPathStatus );
    SendPathType := MyXmlUtil.GetChildValue( Node, Xml_SendPathType );

      // 读取
    SendFileReadRootHandle := TSendFileReadRootHandle.Create( SendFilePath, DesPcID );
    SendFileReadRootHandle.SetFileSpaceInfo( RootSpace, CompletedSize );
    SendFileReadRootHandle.SetFileCount( FileCount );
    SendFileReadRootHandle.SetSendFileStatus( SendPathStatus );
    SendFileReadRootHandle.SetSendPathType( SendPathType );
    SendFileReadRootHandle.Update;
    SendFileReadRootHandle.Free;

      // 读取 子文件信息
    ChildFileNodeList := MyXmlUtil.AddChild( Node, Xml_ChildFileList );

    FileSendChildPathReadXml := TFileSendChildPathReadXml.Create( ChildFileNodeList );
    FileSendChildPathReadXml.SetSendInfo( SendFilePath, DesPcID );
    FileSendChildPathReadXml.Update;
    FileSendChildPathReadXml.Free;
  end;
end;

procedure TFileSendReadXml.Update;
begin
  ReadFileSendList;

  ReadFileSendCancelList;
end;

{ TFileSendChildPathReadXml }

constructor TFileSendChildPathReadXml.Create(_ChildFileList: IXMLNode);
begin
  ChildFileList := _ChildFileList;
end;

procedure TFileSendChildPathReadXml.SetSendInfo(_SendFilePath,
  _DesPcID: string);
begin
  SendFilePath := _SendFilePath;
  DesPcID := _DesPcID;
end;

procedure TFileSendChildPathReadXml.Update;
var
  i : Integer;
  Node : IXMLNode;
  FilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  SendFileReadChildHandle : TSendFileReadChildHandle;
begin
  for i := 0 to ChildFileList.ChildNodes.Count - 1 do
  begin
    Node := ChildFileList.ChildNodes[i];
    FilePath := MyXmlUtil.GetChildValue( Node, Xml_ChildPath );
    FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_FileSize ), 0 );
    Position := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_Position ), 0 );
    FileTime := StrToFloatDef( MyXmlUtil.GetChildValue( Node, Xml_FileTime ), Now );

      // 读取发送的 子文件
    SendFileReadChildHandle := TSendFileReadChildHandle.Create( SendFilePath, DesPcID );
    SendFileReadChildHandle.SetFilePath( FilePath );
    SendFileReadChildHandle.SetFileInfo( FileSize, Position, FileTime );
    SendFileReadChildHandle.Update;
    SendFileReadChildHandle.Free;
  end;
end;

{ TFileSendSpaceXml }

procedure TFileSendSpaceXml.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TFileSendSpaceXml.Update;
var
  RootNode, ChildFileListNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 修改 节点空间信息
  MyXmlUtil.AddChild( RootNode, Xml_FileSize, IntToStr( FileSize ) );
end;


{ TFileReceiveReadXml }

procedure TFileReceiveReadXml.ReadFileReceiveCancelList;
var
  i : Integer;
  Node : IXMLNode;
  SourceFilePath, SourcePcID : string;
  ReceiveFileCancelReadHandle : TReceiveFileCancelReadHandle;
begin
  for i := 0 to FileReceiveCancelListXml.ChildNodes.Count - 1 do
  begin
    Node := FileReceiveCancelListXml.ChildNodes[i];

    SourceFilePath := MyXmlUtil.GetChildValue( Node, Xml_SourceFilePath );
    SourcePcID := MyXmlUtil.GetChildValue( Node, Xml_SourcePcID );

    ReceiveFileCancelReadHandle := TReceiveFileCancelReadHandle.Create( SourceFilePath, SourcePcID );
    ReceiveFileCancelReadHandle.Update;
    ReceiveFileCancelReadHandle.Free;
  end;
end;

procedure TFileReceiveReadXml.ReadFileReceiveList;
var
  i : Integer;
  Node : IXMLNode;
  SourceFilePath, SourcePcID : string;
  ReceivePath, SendPathType : string;
  ReceiveStatus : string;
  ReceiveFileReadHandle : TReceiveFileReadHandle;
  FileSize, CompletedSize : Int64;
begin
  for i := 0 to FileReceiveListXml.ChildNodes.Count - 1 do
  begin
    Node := FileReceiveListXml.ChildNodes[i];

    SourceFilePath := MyXmlUtil.GetChildValue( Node, Xml_SourceFilePath );
    SourcePcID := MyXmlUtil.GetChildValue( Node, Xml_SourcePcID );
    ReceivePath := MyXmlUtil.GetChildValue( Node, Xml_ReceivePath );
    SendPathType := MyXmlUtil.GetChildValue( Node, Xml_SendFileType );
    FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_FileSize ), 0 );
    CompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_CompletedSize ), 0 );
    ReceiveStatus := MyXmlUtil.GetChildValue( Node, Xml_ReceiveFileStatus );

    ReceiveFileReadHandle := TReceiveFileReadHandle.Create( SourceFilePath, SourcePcID );
    ReceiveFileReadHandle.SetReceivePath( ReceivePath );
    ReceiveFileReadHandle.SetSendPathType( SendPathType );
    ReceiveFileReadHandle.SetFileSpaceInfo( FileSize, CompletedSize );
    ReceiveFileReadHandle.SetReceiveStatus( ReceiveStatus );
    ReceiveFileReadHandle.Update;
    ReceiveFileReadHandle.Free;
  end;
end;

procedure TFileReceiveReadXml.StartRevFileFace;
var
  LvFileReceiveStartInfo : TLvFileReceiveStartInfo;
begin
  LvFileReceiveStartInfo := TLvFileReceiveStartInfo.Create;
  MyFaceChange.AddChange( LvFileReceiveStartInfo );
end;

procedure TFileReceiveReadXml.Update;
begin
  ReadFileReceiveList;

  ReadFileReceiveCancelList;

  StartRevFileFace;
end;

{ TFileReceiveSetSpaceXml }

procedure TFileReceiveSetSpaceXml.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TFileReceiveSetSpaceXml.Update;
var
  Node : IXMLNode;
begin
  inherited;

  Node := FindExistNode;
  if Node = nil then
    Exit;

  MyXmlUtil.AddChild( Node, Xml_FileSize, IntToStr( FileSize ) );
end;

{ TFileReceiveSetStatusXml }

procedure TFileReceiveSetStatusXml.SetStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TFileReceiveSetStatusXml.Update;
var
  Node : IXMLNode;
begin
  inherited;

  Node := FindExistNode;
  if Node = nil then
    Exit;

  MyXmlUtil.AddChild( Node, Xml_ReceiveFileStatus, ReceiveStatus );
end;

{ TFileSendChildPositionXml }

procedure TFileSendChildPositionXml.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TFileSendChildPositionXml.Update;
var
  RootNode, ChildFileListNode : IXMLNode;
  ChildNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 文件集合 节点
  ChildFileListNode := MyXmlUtil.AddChild( RootNode, Xml_ChildFileList );

    // 文件 节点
  ChildNode := MyXmlUtil.FindListChild( ChildFileListNode, ChildFilePath );

    // 不存在
  if ChildNode = nil then
    Exit;

    // 写到 Xml 中
  MyXmlUtil.AddChild( ChildNode, Xml_Position, IntToStr( Position ) );
end;

{ TFileSendRootStatusXml }

procedure TFileSendRootStatusXml.SetSendPathStatus(_SendPathStatus: string);
begin
  SendPathStatus := _SendPathStatus;
end;

procedure TFileSendRootStatusXml.Update;
var
  RootNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 修改 节点空间信息
  MyXmlUtil.AddChild( RootNode, Xml_SendPathStatus, SendPathStatus );
end;

{ TFileSendClearChildXml }

procedure TFileSendClearChildXml.Update;
var
  RootNode, ChildFileListNode : IXMLNode;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 文件集合 节点
  ChildFileListNode := MyXmlUtil.AddChild( RootNode, Xml_ChildFileList );
  ChildFileListNode.ChildNodes.Clear;
end;

{ TFileReceiveCancelAddXml }

procedure TFileReceiveCancelAddXml.Update;
var
  Node : IXMLNode;
begin
  Node := MyXmlUtil.AddListChild( FileReceiveCancelListXml );
  MyXmlUtil.AddChild( Node, Xml_SourceFilePath, SourceFilePath );
  MyXmlUtil.AddChild( Node, Xml_SourcePcID, SourcePcID );
end;

{ TFileSendCancelWriteXml }

constructor TFileSendCancelWriteXml.Create(_SendFilePath, _DesPcID: string);
begin
  SendFilePath := _SendFilePath;
  DesPcID := _DesPcID;
end;

{ TFileSendCancelAddXml }

procedure TFileSendCancelAddXml.Update;
var
  Node : IXMLNode;
begin
  Node := MyXmlUtil.AddListChild( FileSendCancelListXml );
  MyXmlUtil.AddChild( Node, Xml_SendFilePath, SendFilePath );
  MyXmlUtil.AddChild( Node, Xml_DesPcID, DesPcID );
end;

{ TFileSendCancelRemoveXml }

procedure TFileSendCancelRemoveXml.Update;
var
  i : Integer;
  Node : IXMLNode;
  SelectSendFilePath, SelectDesPcID : string;
begin
  for i := 0 to FileSendCancelListXml.ChildNodes.Count - 1 do
  begin
    Node := FileSendCancelListXml.ChildNodes[ i ];
    SelectSendFilePath := MyXmlUtil.GetChildValue( Node, Xml_SendFilePath );
    SelectDesPcID := MyXmlUtil.GetChildValue( Node, Xml_DesPcID );

    if ( SelectSendFilePath = SendFilePath ) and
       ( SelectDesPcID = DesPcID )
    then
    begin
      FileSendCancelListXml.ChildNodes.Delete( i );
      Break;
    end;
  end;
end;

{ TFileReceiveCancelRemoveXml }

procedure TFileReceiveCancelRemoveXml.Update;
var
  i : Integer;
  Node : IXMLNode;
  SelectSourceFilePath, SelectSourcePcID : string;
begin
  for i := 0 to FileReceiveCancelListXml.ChildNodes.Count - 1 do
  begin
    Node := FileReceiveCancelListXml.ChildNodes[ i ];
    SelectSourceFilePath := MyXmlUtil.GetChildValue( Node, Xml_SourceFilePath );
    SelectSourcePcID := MyXmlUtil.GetChildValue( Node, Xml_SourcePcID );

    if ( SelectSourceFilePath = SourceFilePath ) and
       ( SelectSourcePcID = SourcePcID )
    then
    begin
      FileReceiveCancelListXml.ChildNodes.Delete(i);
      Break;
    end;
  end;
end;

{ TFileReceiveCancelWriteXml }

constructor TFileReceiveCancelWriteXml.Create(_SourceFilePath,
  _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

{ TFileSendAddCompletedSpaceXml }

procedure TFileSendAddCompletedSpaceXml.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TFileSendAddCompletedSpaceXml.Update;
var
  RootNode : IXMLNode;
  OldCompletedSize, NewCompletedSize : Int64;
begin
  inherited;

  RootNode := FindRootNode;

    // 不存在
  if RootNode = nil then
    Exit;

    // 添加 节点空间信息
  OldCompletedSize := StrToInt64Def( MyXmlUtil.GetChildValue( RootNode, Xml_CompletedSize ), 0 );
  NewCompletedSize := OldCompletedSize + CompletedSize;
  MyXmlUtil.AddChild( RootNode, Xml_CompletedSize, IntToStr( NewCompletedSize ) );
end;

{ TFileReceiveAddCompletedSpaceXml }

procedure TFileReceiveAddCompletedSpaceXml.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TFileReceiveAddCompletedSpaceXml.Update;
var
  Node : IXMLNode;
  OldCompletedSpace, NewCompletedSpace : Int64;
begin
  inherited;

  Node := FindExistNode;
  if Node = nil then
    Exit;

  OldCompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_CompletedSize ), 0 );
  NewCompletedSpace := OldCompletedSpace + CompletedSpace;
  MyXmlUtil.AddChild( Node, Xml_CompletedSize, IntToStr( NewCompletedSpace ) );
end;

{ MyFileSendXmlUtil }

class function MyFileSendXmlUtil.getTotalCount: Integer;
begin
  Result := MyXmlUtil.GetChildIntValue( MyFileSendXml, Xml_TotalSendCount );
end;

end.
