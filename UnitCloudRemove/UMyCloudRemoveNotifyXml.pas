unit UMyCloudRemoveNotifyXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' 修改 ' }

    // 修改
  TRemoveCloudNotifyChangeXml = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // 修改 指定路径
  TRemoveCloudNotifyWriteXml = class( TRemoveCloudNotifyChangeXml )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // 添加
  TRemoveCloudNotifyAddXml = class( TRemoveCloudNotifyWriteXml )
  public
    procedure Update;override;
  end;

    // 删除
  TRemoveCloudNotifyDeleteXml = class( TRemoveCloudNotifyWriteXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 读取 ' }

  TPcRemoveCloudPathReadHandle = class
  private
    PcID : string;
    FullPath : string;
  public
    constructor Create( _PcID : string );
    procedure SetPathInfo( _FullPath : string );
    procedure Update;
  end;

    // 读取 Xml 文件信息
  TCloudRemoveNotifyRead = class
  public
    procedure Update;
  end;

{$EndRegion}

    // 删除 网络 Pc 的备份文件信息
  TMyCloudFileRemoveWriteXml = class( TMyChildXmlChange )
  end;

const
  Xml_PcID = 'pi';
  Xml_RemoveCloudPathHash = 'rbph';

  Xml_FullPath = 'fp';

var
  MyCloudFileRemoveWriteXml : TMyCloudFileRemoveWriteXml;

implementation

uses UMyCloudRemoveNotifyInfo;

{ TRemovePcFileChangeXml }

constructor TRemoveCloudNotifyChangeXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TRemovePcFileWriteXml }

procedure TRemoveCloudNotifyWriteXml.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileAddXml }

procedure TRemoveCloudNotifyAddXml.Update;
var
  RemoveNotifyNode : IXMLNode;
  RemoveCloudPathHashNode : IXMLNode;
  RemoveCloudPathNode : IXMLNode;
begin
  RemoveNotifyNode := MyXmlUtil.AddListChild( RemoveCloudNotifyHashXml, PcID );
  MyXmlUtil.AddChild( RemoveNotifyNode, Xml_PcID, PcID );
  RemoveCloudPathHashNode := MyXmlUtil.AddChild( RemoveNotifyNode, Xml_RemoveCloudPathHash );

  if MyXmlUtil.FindListChild( RemoveCloudPathHashNode, FullPath ) <> nil then
    Exit;

  RemoveCloudPathNode := MyXmlUtil.AddListChild( RemoveCloudPathHashNode, FullPath );
  MyXmlUtil.AddChild( RemoveCloudPathNode, Xml_FullPath, FullPath );
end;

{ TRemoveCloudNotifyDeleteXml }

procedure TRemoveCloudNotifyDeleteXml.Update;
var
  RemoveNotifyNode : IXMLNode;
  RemoveCloudPathHashNode : IXMLNode;
begin
  RemoveNotifyNode := MyXmlUtil.FindListChild( RemoveCloudNotifyHashXml, PcID );
  if RemoveNotifyNode = nil then
    Exit;

  RemoveCloudPathHashNode := MyXmlUtil.AddChild( RemoveNotifyNode, Xml_RemoveCloudPathHash );

  MyXmlUtil.DeleteListChild( RemoveCloudPathHashNode, FullPath );
  if RemoveCloudPathHashNode.ChildNodes.Count = 0 then
    MyXmlUtil.DeleteListChild( RemoveCloudNotifyHashXml, PcID  );
end;
{ TCloudRemoveNotifyRead }

procedure TCloudRemoveNotifyRead.Update;
var
  i, j : Integer;
  RemoveCloudNotify : IXMLNode;
  PcID, FullPath : string;
  RemoveCloudPathHash, RemoveCloudPathNode : IXMLNode;
  PcRemoveCloudPathReadHandle : TPcRemoveCloudPathReadHandle;
begin
  for i := 0 to RemoveCloudNotifyHashXml.ChildNodes.Count - 1 do
  begin
    RemoveCloudNotify := RemoveCloudNotifyHashXml.ChildNodes[i];
    PcID := MyXmlUtil.GetChildValue( RemoveCloudNotify, Xml_PcID );
    RemoveCloudPathHash := MyXmlUtil.AddChild( RemoveCloudNotify, Xml_RemoveCloudPathHash );
    for j := 0 to RemoveCloudPathHash.ChildNodes.Count - 1 do
    begin
      RemoveCloudPathNode := RemoveCloudPathHash.ChildNodes[j];
      FullPath := MyXmlUtil.GetChildValue( RemoveCloudPathNode, Xml_FullPath );

        // 加载 备份删除路径
      PcRemoveCloudPathReadHandle := TPcRemoveCloudPathReadHandle.Create( PcID );
      PcRemoveCloudPathReadHandle.SetPathInfo( FullPath );
      PcRemoveCloudPathReadHandle.Update;
      PcRemoveCloudPathReadHandle.Free;
    end;
  end;
end;

{ TPcRemoveCloudPathReadHandle }

constructor TPcRemoveCloudPathReadHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPcRemoveCloudPathReadHandle.SetPathInfo(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TPcRemoveCloudPathReadHandle.Update;
var
  RemoveCloudNotifyAddInfo : TRemoveCloudNotifyAddInfo;
begin
  RemoveCloudNotifyAddInfo := TRemoveCloudNotifyAddInfo.Create( PcID );
  RemoveCloudNotifyAddInfo.SetFullPath( FullPath );
  MyCloudRemoveNotifyInfo.AddChange( RemoveCloudNotifyAddInfo );
end;


end.
