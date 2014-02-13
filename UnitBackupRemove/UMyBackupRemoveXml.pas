unit UMyBackupRemoveXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' 修改 ' }

    // 修改
  TRemoveBackupNotifyChangeXml = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 修改 指定路径
  TRemoveBackupNotifyWriteXml = class( TRemoveBackupNotifyChangeXml )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // 添加
  TRemoveBackupNotifyAddXml = class( TRemoveBackupNotifyWriteXml )
  public
    procedure Update;override;
  end;

    // 删除
  TRemoveBackupNotifyDeleteXml = class( TRemoveBackupNotifyWriteXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 读取 ' }

    // 读取 删除文件信息
  TPcRemoveBackupFileNotifyXmlReadHandle = class
  public
    RemoveNotifyNode : IXMLNode;
    PcID : string;
  public
    constructor Create( _RemoveNotifyNode : IXMLNode );
    procedure SetPcID( _PcID : string );
    procedure Update;
  end;

    // 读取 Pc 节点信息
  TPcBackupRemoveNotifyNodeXmlReadHandle = class
  public
    PcRemoveNotifyNode : IXMLNode;
    PcID : string;
  public
    constructor Create( _PcRemoveNotifyNode : IXMLNode );
    procedure Update;
  private
    procedure ReadRemoveFile;
  end;

    // 读取 Xml 文件信息
  TBackupRemoveNotifyRead = class
  public
    procedure Update;
  end;

{$EndRegion}

    // 删除 网络 Pc 的备份文件信息
  TMyBackupFileRemoveWriteXml = class( TMyChildXmlChange )
  end;

const
  Xml_PcID = 'pi';
  Xml_RemoveBackupPathHash = 'rbph';

  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';

var
  MyBackupFileRemoveWriteXml : TMyBackupFileRemoveWriteXml;

implementation

uses UMyBackupRemoveInfo, UMyBackupRemoveControl;

{ TRemovePcFileChangeXml }

constructor TRemoveBackupNotifyChangeXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TRemovePcFileWriteXml }

procedure TRemoveBackupNotifyWriteXml.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileAddXml }

procedure TRemoveBackupNotifyAddXml.Update;
var
  PcRemoveNode : IXMLNode;
  RemovePathHashNode : IXMLNode;
  RemovePathNode : IXMLNode;
begin
    // Pc 节点
  PcRemoveNode := MyXmlUtil.FindListChild( RemoveBackupNotifyHashXml, PcID );
  if PcRemoveNode = nil then  // 不存在 则创建
  begin
    PcRemoveNode := MyXmlUtil.AddListChild( RemoveBackupNotifyHashXml, PcID );
    MyXmlUtil.AddChild( PcRemoveNode, Xml_PcID, PcID );
  end;

    // 删除路径列表
  RemovePathHashNode := MyXmlUtil.AddChild( PcRemoveNode, Xml_RemoveBackupPathHash );

    // 已存在
  if MyXmlUtil.FindListChild( RemovePathHashNode, FullPath ) <> nil then
    Exit;

    // 创建
  RemovePathNode := MyXmlUtil.AddListChild( RemovePathHashNode, FullPath );
  MyXmlUtil.AddChild( RemovePathNode, Xml_FullPath, FullPath );
end;

{ TRemoveBackupNotifyDeleteXml }

procedure TRemoveBackupNotifyDeleteXml.Update;
var
  PcRemoveNode : IXMLNode;
  RemovePathHashNode : IXMLNode;
begin
    // Pc 删除 节点
  PcRemoveNode := MyXmlUtil.FindListChild( RemoveBackupNotifyHashXml, PcID );
  if PcRemoveNode = nil then
    Exit;

    // 删除列表
  RemovePathHashNode := MyXmlUtil.AddChild( PcRemoveNode, Xml_RemoveBackupPathHash );

    // 删除
  MyXmlUtil.DeleteListChild( RemovePathHashNode, FullPath );
  if RemovePathHashNode.ChildNodes.Count = 0 then
    MyXmlUtil.DeleteListChild( RemoveBackupNotifyHashXml, PcID  );
end;
{ TBackupRemoveNotifyRead }

procedure TBackupRemoveNotifyRead.Update;
var
  i : Integer;
  PcRemoveBackupNotify : IXMLNode;
  PcBackupRemoveNotifyNodeXmlReadHandle : TPcBackupRemoveNotifyNodeXmlReadHandle;
begin
  for i := 0 to RemoveBackupNotifyHashXml.ChildNodes.Count - 1 do
  begin
    PcRemoveBackupNotify := RemoveBackupNotifyHashXml.ChildNodes[i];

    PcBackupRemoveNotifyNodeXmlReadHandle := TPcBackupRemoveNotifyNodeXmlReadHandle.Create( PcRemoveBackupNotify );
    PcBackupRemoveNotifyNodeXmlReadHandle.Update;
    PcBackupRemoveNotifyNodeXmlReadHandle.Free;
  end;
end;

{ TPcBackupRemoveNotifyNodeXmlReadHandle }

constructor TPcBackupRemoveNotifyNodeXmlReadHandle.Create(
  _PcRemoveNotifyNode: IXMLNode);
begin
  PcRemoveNotifyNode := _PcRemoveNotifyNode;
end;

procedure TPcBackupRemoveNotifyNodeXmlReadHandle.ReadRemoveFile;
var
  i : Integer;
  RemoveBackupPathHash, RemoveBackupPathNode : IXMLNode;
  PcRemoveBackupFileNotifyXmlReadHandle : TPcRemoveBackupFileNotifyXmlReadHandle;
begin
  RemoveBackupPathHash := MyXmlUtil.AddChild( PcRemoveNotifyNode, Xml_RemoveBackupPathHash );
  for i := 0 to RemoveBackupPathHash.ChildNodes.Count - 1 do
  begin
    RemoveBackupPathNode := RemoveBackupPathHash.ChildNodes[i];

    PcRemoveBackupFileNotifyXmlReadHandle := TPcRemoveBackupFileNotifyXmlReadHandle.Create( RemoveBackupPathNode );
    PcRemoveBackupFileNotifyXmlReadHandle.SetPcID( PcID );
    PcRemoveBackupFileNotifyXmlReadHandle.Update;
    PcRemoveBackupFileNotifyXmlReadHandle.Free;
  end;
end;

procedure TPcBackupRemoveNotifyNodeXmlReadHandle.Update;
begin
  PcID := MyXmlUtil.GetChildValue( PcRemoveNotifyNode, Xml_PcID );

  ReadRemoveFile;
end;

{ TPcRemoveBackupFileNotifyXmlReadHandle }

constructor TPcRemoveBackupFileNotifyXmlReadHandle.Create(
  _RemoveNotifyNode: IXMLNode);
begin
  RemoveNotifyNode := _RemoveNotifyNode;
end;

procedure TPcRemoveBackupFileNotifyXmlReadHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPcRemoveBackupFileNotifyXmlReadHandle.Update;
var
  FullPath : string;
  BackupRemoveNotifyReadHandle : TBackupRemoveNotifyReadHandle;
begin
  FullPath := MyXmlUtil.GetChildValue( RemoveNotifyNode, Xml_FullPath );

  BackupRemoveNotifyReadHandle := TBackupRemoveNotifyReadHandle.Create( PcID );
  BackupRemoveNotifyReadHandle.SetFullPath( FullPath );
  BackupRemoveNotifyReadHandle.Update;
  BackupRemoveNotifyReadHandle.Free;
end;

end.
