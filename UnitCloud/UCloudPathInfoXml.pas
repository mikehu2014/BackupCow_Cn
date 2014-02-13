unit UCloudPathInfoXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, Classes, UMyUtil, SysUtils;

type

{$Region ' 云信息 修改 ' }

  {$Region ' 云路径 修改 ' }

    // 修改
  TCloudPathChangeXml = class( TChangeInfo )
  protected
    CloudPath : string;
  protected
    CloudPathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindCloudPathNode : Boolean;
  end;

    // 添加
  TCloudPathAddXml = class( TCloudPathChangeXml )
  public
    procedure Update;override;
  end;

    // 删除
  TCloudPathRemoveXml = class( TCloudPathChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 云路径 拥有者 修改 ' }

    // 修改
  TCloudPathOwnerChangeXml = class( TCloudPathChangeXml )
  public
    OwnerPcID : string;
  protected
    CloudPathOwnerListNode : IXMLNode;
  public
    procedure SetOwnerPcID( _OwnerPcID : string );
  protected
    function FindCloudPathOwnerListNode : Boolean;
  end;

    // 删除 Pc 节点
  TCloudPathOwnerRemoveXml = class( TCloudPathOwnerChangeXml )
  public
    procedure Update;override;
  end;

    // 修改 拥有者
  TCloudPathOwnerWriteXml = class( TCloudPathOwnerChangeXml )
  protected
    CloudPathOwnerNode : IXMLNode;
  public
    function FindCloudPathOwnerNode : Boolean;
    procedure AddCloudPathOwnerNode;
  end;

    // 设置 最后一次 扫描时间
  TCloudPathOwnerSetLastScanTimeXml = class( TCloudPathOwnerWriteXml )
  private
    LastScanTime : TDateTime;
  public
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;override;
  end;

  {$Region ' 修改 空间信息 ' }

    // 修改 空间信息
  TCloudPathOwnerChangeSpaceXml = class( TCloudPathOwnerWriteXml )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // 添加
  TCloudPathOwnerAddSpaceXml = class( TCloudPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // 删除
  TCloudPathOwnerRemoveSpaceXml = class( TCloudPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // 设置
  TCloudPathOwnerSetSpaceXml = class( TCloudPathOwnerChangeSpaceXml )
  private
    LastFileSize : Int64;
  public
    procedure SetLastFileSize( _LastFileSize : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

  {$EndRegion}

{$EndRegion}

{$Region ' 云信息 读取 ' }

    // 读取 云路径 信息
  TCloudPathXmlReadHandle = class
  private
    CloudPathNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudPathNode : IXMLNode );
    procedure Update;
  private       // 读取 云路径 拥有者
    procedure ReadCloudPathOwner;
  end;

    // 读取 云路径目录 信息
  TCloudPathOwnerXmlReadHandle = class
  private
    CloudPathOwnerNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudPathOwnerNode : IXMLNode );
    procedure SetCloudPath( _CloudPath : string );
    procedure Update;
  end;

    // 添加 默认的云路径
  TDefaultCloudPathAddHandle = class
  public
    procedure Update;
  end;

    // 读云路径线程
  TMyCloudFileXmlRead = class
  public
    procedure Update;
  private
    procedure ReadCloudPath;
    procedure AddDefaultCloudPath;
  end;

{$EndRegion}

const
    // Cloud Folder Path
  Xml_FullPath = 'fp';
  Xml_CloudPcFolderList = 'cfl';

    // Cloud Pc Folder
  Xml_CloudPcID = 'cpi';
  Xml_CloudFolder = 'cp';
  Xml_UsedSpace = 'us';
  Xml_FileCount = 'fc';
  Xml_LastScanTime = 'lst';

    // Cloud Folder/File
  Xml_FileName = 'fn';
  Xml_FileSize = 'fs';
  Xml_FileTime = 'ft';
  Xml_FileStatus = 'fss';
  Xml_CloudFileList = 'cfl';
  Xml_CloudFolderList = 'cfdl';


var
  MyCloudPathXmlWrite : TMyChildXmlChange;

implementation

uses UXmlUtil, UMyCloudPathInfo, UBackupCow, UBackupBoardInfo, UMyCloudFileControl;


{ TCloudPathAddXml }

procedure TCloudPathAddXml.Update;
begin
    // 已存在
  if FindCloudPathNode then
    Exit;

    // 添加
  CloudPathNode := MyXmlUtil.AddListChild( CloudPathHashXml, CloudPath );
  MyXmlUtil.AddChild( CloudPathNode, Xml_FullPath, CloudPath );
end;

{ TCloudInfoReadThread }

procedure TMyCloudFileXmlRead.AddDefaultCloudPath;
var
  DefaultCloudPathAddHandle : TDefaultCloudPathAddHandle;
begin
  DefaultCloudPathAddHandle := TDefaultCloudPathAddHandle.Create;
  DefaultCloudPathAddHandle.Update;
  DefaultCloudPathAddHandle.Free;
end;

procedure TMyCloudFileXmlRead.ReadCloudPath;
var
  i : Integer;
  CloudPathNode : IXMLNode;
  CloudPathXmlReadHandle : TCloudPathXmlReadHandle;
begin
  for i := 0 to CloudPathHashXml.ChildNodes.Count - 1 do
  begin
    CloudPathNode := CloudPathHashXml.ChildNodes[i];

    CloudPathXmlReadHandle := TCloudPathXmlReadHandle.Create( CloudPathNode );
    CloudPathXmlReadHandle.Update;
    CloudPathXmlReadHandle.Free;
  end;
end;

procedure TMyCloudFileXmlRead.Update;
begin
    // 云路径 不存在, 添加默认路径
  if CloudPathHashXml.ChildNodes.Count = 0 then
    AddDefaultCloudPath
  else
    ReadCloudPath; // 读取 路径信息
end;

{ TCloudPathXmlReadHandle }

constructor TCloudPathXmlReadHandle.Create(_CloudPathNode: IXMLNode);
begin
  CloudPathNode := _CloudPathNode;
end;

procedure TCloudPathXmlReadHandle.ReadCloudPathOwner;
var
  CloudPathOwnerListNode : IXMLNode;
  i : Integer;
  CloudPathOwnerNode : IXMLNode;
  CloudPathOwnerXmlReadHandle : TCloudPathOwnerXmlReadHandle;
begin
  CloudPathOwnerListNode := MyXmlUtil.AddChild( CloudPathNode, Xml_CloudPcFolderList );
  for i := 0 to CloudPathOwnerListNode.ChildNodes.Count - 1 do
  begin
    CloudPathOwnerNode := CloudPathOwnerListNode.ChildNodes[i];

    CloudPathOwnerXmlReadHandle := TCloudPathOwnerXmlReadHandle.Create( CloudPathOwnerNode );
    CloudPathOwnerXmlReadHandle.SetCloudPath( CloudPath );
    CloudPathOwnerXmlReadHandle.Update;
    CloudPathOwnerXmlReadHandle.Free;
  end;
end;

procedure TCloudPathXmlReadHandle.Update;
var
  CloudPathReadHandle : TCloudPathReadHandle;
begin
  CloudPath := MyXmlUtil.GetChildValue( CloudPathNode, Xml_FullPath );

    // 读取 云路径
  CloudPathReadHandle := TCloudPathReadHandle.Create( CloudPath );
  CloudPathReadHandle.Update;
  CloudPathReadHandle.Free;

    // 读取 云路径 拥有者
  ReadCloudPathOwner;
end;

{ TDefaultCloudPathHandle }

procedure TDefaultCloudPathAddHandle.Update;
var
  DefaultCloudPath : string;
  CloudPathAddHandle : TCloudPathAddHandle;
begin
    // 默认路径
  DefaultCloudPath := MyHardDisk.getBiggestHardDIsk;
  DefaultCloudPath := DefaultCloudPath + 'BackupCow.Backup';

    // 添加 云路径
  CloudPathAddHandle := TCloudPathAddHandle.Create( DefaultCloudPath );
  CloudPathAddHandle.Update;
  CloudPathAddHandle.Free;
end;

{ TCloudPathModifyXml }

constructor TCloudPathChangeXml.Create(_FullPath: string);
begin
  CloudPath := _FullPath;
end;


{ TCloudPathRemoveXml }

procedure TCloudPathRemoveXml.Update;
begin
    // 不存在
  if not FindCloudPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudPathHashXml, CloudPath );
end;

{ TCloudPcFolderRemoveXml }

procedure TCloudPathOwnerRemoveXml.Update;
begin
    // 云路径 不存在
  if not FindCloudPathOwnerListNode then
    Exit;

    // 删除 拥有者
  MyXmlUtil.DeleteListChild( CloudPathOwnerListNode, OwnerPcID );
end;

{ TCloudPathFolderXmlReadHandle }

constructor TCloudPathOwnerXmlReadHandle.Create(_CloudPathOwnerNode: IXMLNode);
begin
  CloudPathOwnerNode := _CloudPathOwnerNode;
end;

procedure TCloudPathOwnerXmlReadHandle.SetCloudPath(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

procedure TCloudPathOwnerXmlReadHandle.Update;
var
  CloudPcID : string;
  CloudUsedSpace : Int64;
  CloudFileCount : Integer;
  LastOnlineTime : TDateTime;
  CloudPathOwnerReadHandle : TCloudPathOwnerReadHandle;
begin
    // 提取 目录信息
  CloudPcID := MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_CloudPcID );
  CloudUsedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  CloudFileCount := StrToIntDef( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_FileCount ), 0 );
  LastOnlineTime := StrToFloatDef( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_LastScanTime ), 0 );

    // 添加 云路径 拥有者 信息
  CloudPathOwnerReadHandle := TCloudPathOwnerReadHandle.Create( CloudPath );
  CloudPathOwnerReadHandle.SetOwnerPcID( CloudPcID );
  CloudPathOwnerReadHandle.SetSpaceInfo( CloudUsedSpace, CloudFileCount );
  CloudPathOwnerReadHandle.SetLastScanTime( LastOnlineTime );
  CloudPathOwnerReadHandle.Update;
  CloudPathOwnerReadHandle.Free;
end;

{ TCloudPcFolderSetRootNodeXml }

function TCloudPathChangeXml.FindCloudPathNode:Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
  SelectPath : string;
begin
  Result := False;
  for i := 0 to CloudPathHashXml.ChildNodes.Count - 1 do
  begin
    SelectNode := CloudPathHashXml.ChildNodes[i];
    SelectPath := MyXmlUtil.GetChildValue( SelectNode, Xml_FullPath );
    if SelectPath = CloudPath then
    begin
      CloudPathNode := SelectNode;
      Result := True;
      Break;
    end;
  end;
end;

{ TCloudPathPcFolderChangeXml }

function TCloudPathOwnerChangeXml.FindCloudPathOwnerListNode: Boolean;
begin
  Result := False;

    // 路径不存在
  if not FindCloudPathNode then
    Exit;

    // 拥有者 列表
  CloudPathOwnerListNode := MyXmlUtil.AddChild( CloudPathNode, Xml_CloudPcFolderList );
  Result := True;
end;

procedure TCloudPathOwnerChangeXml.SetOwnerPcID(_OwnerPcID: string);
begin
  OwnerPcID := _OwnerPcID;
end;

{ TCloudPathPcFolderChangeSpaceXml }

procedure TCloudPathOwnerChangeSpaceXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TCloudPathPcFolderAddSpaceXml }

procedure TCloudPathOwnerAddSpaceXml.Update;
var
  OldUsedSpace : Int64;
  OldFileCount : Integer;
begin
    // 云路径 Pc 目录
  if not FindCloudPathOwnerListNode then
    Exit;

    // 不存在 则添加
  AddCloudPathOwnerNode;

    // Used Space
  OldUsedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  OldUsedSpace := FileSize + OldUsedSpace;
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_UsedSpace, IntToStr( OldUsedSpace ) );

    // File Count
  OldFileCount := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_FileCount ), 0 );
  OldFileCount := OldFileCount + FileCount;
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_FileCount, IntToStr( OldFileCount ) );
end;

{ TCloudPathPcFolderRemoveSpaceXml }

procedure TCloudPathOwnerRemoveSpaceXml.Update;
var
  OldUsedSpace : Int64;
  OldFileCount : Integer;
begin
    // 云路径 Pc 目录
  if not FindCloudPathOwnerNode then
    Exit;

    // Used Space
  OldUsedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  OldUsedSpace := FileSize - OldUsedSpace;
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_UsedSpace, IntToStr( OldUsedSpace ) );

    // File Count
  OldFileCount := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_FileCount ), 0 );
  OldFileCount := OldFileCount - FileCount;
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_FileCount, IntToStr( OldFileCount ) );

    // 没有文件了
  if OldFileCount = 0 then
    MyXmlUtil.DeleteListChild( CloudPathOwnerListNode, OwnerPcID );
end;


{ TCloudPathPcFolderSetSpaceXml }

procedure TCloudPathOwnerSetSpaceXml.SetLastFileSize(_LastFileSize: Int64);
begin
  LastFileSize := _LastFileSize;
end;

procedure TCloudPathOwnerSetSpaceXml.Update;
var
  ReadFileSize : Int64;
begin
    // 不存在
  if not FindCloudPathOwnerListNode then
    Exit;

    // 不存在 则 添加
  AddCloudPathOwnerNode;

    // 空间 已发生变化
  ReadFileSize := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  if ReadFileSize <> LastFileSize then
    Exit;

    // 修改信息
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_UsedSpace, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_FileCount, IntToStr( FileCount ) );
end;

{ TCloudPathOwnerWriteXml }

procedure TCloudPathOwnerWriteXml.AddCloudPathOwnerNode;
begin
  CloudPathOwnerNode := MyXmlUtil.AddListChild( CloudPathOwnerListNode, OwnerPcID );
end;

function TCloudPathOwnerWriteXml.FindCloudPathOwnerNode: Boolean;
begin
  Result := False;
  if not FindCloudPathOwnerListNode then
    Exit;

  CloudPathOwnerNode := MyXmlUtil.FindListChild( CloudPathOwnerListNode, OwnerPcID );
  Result := CloudPathOwnerNode <> nil;
end;

{ TCloudPathOwnerSetLastScanTimeXml }

procedure TCloudPathOwnerSetLastScanTimeXml.SetLastScanTime(
  _LastScanTime: TDateTime);
begin
  LastScanTime := _LastScanTime;
end;

procedure TCloudPathOwnerSetLastScanTimeXml.Update;
begin
    // 云路径 Pc 目录
  if not FindCloudPathOwnerListNode then
    Exit;

    // 不存在 则添加
  AddCloudPathOwnerNode;

    // 设置 最后一次扫描时间
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_LastScanTime, FloatToStr( LastScanTime ) );
end;

end.
