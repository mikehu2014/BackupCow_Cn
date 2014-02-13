unit UMyRestoreXmlInfo;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc;

type

{$Region ' 数据修改 ' }

    // 父类
  TRestoreDownChangeXml = class( TXmlChangeInfo )
  protected
    MyRestoreDownNode : IXMLNode;
    RestoreDownNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 修改
  TRestoreDownWriteXml = class( TRestoreDownChangeXml )
  public
    RestorePath, RestoreOwner : string;
  protected
    RestoreDownIndex : Integer;
    RestoreDownNode : IXMLNode;
  public
    constructor Create( _RestorePath, _RestoreOwner : string );
  protected
    function FindRestoreDownNode: Boolean;
  end;


    // 添加
  TRestoreDownAddXml = class( TRestoreDownWriteXml )
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetRestoreFrom( _RestoreFrom : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
  protected
    procedure Update;override;
  end;

    // 删除
  TRestoreDownRemoveXml = class( TRestoreDownWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取 下载节点
  TRestoreDownReadXml = class
  public
    RestoreDownNode : IXMLNode;
  public
    constructor Create( _RestoreDownNode : IXMLNode );
    procedure Update;
  end;

    // 读取 恢复下载
  TMyRestoreDownReadXml = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_MyRestoreDownInfo = 'mrdi';
  Xml_RestoreDownList = 'rdl';
  Xml_RestorePath = 'rp';
  Xml_RestoreOwner = 'ro';
  Xml_RestoreFrom = 'rf';
  Xml_FileCount = 'fc';
  Xml_FileSize = 'fs';
  Xml_CompletedSize = 'cs';
  Xml_SavePath = 'sp';


implementation

uses UMyRestoreApiInfo;

{ TRestoreDownChangeXml }

procedure TRestoreDownChangeXml.Update;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreDownNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreDownList );
end;

{ TRestoreDownWriteXml }

constructor TRestoreDownWriteXml.Create( _RestorePath, _RestoreOwner : string );
begin
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
end;


function TRestoreDownWriteXml.FindRestoreDownNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to RestoreDownNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := RestoreDownNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestorePath ) = RestorePath ) and ( MyXmlUtil.GetChildValue( SelectNode, Xml_RestoreOwner ) = RestoreOwner ) then
    begin
      Result := True;
      RestoreDownIndex := i;
      RestoreDownNode := RestoreDownNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TRestoreDownAddXml }

procedure TRestoreDownAddXml.SetRestoreFrom( _RestoreFrom : string );
begin
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownAddXml.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddXml.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

procedure TRestoreDownAddXml.Update;
begin
  inherited;

  if FindRestoreDownNode then
    Exit;

  RestoreDownNode := MyXmlUtil.AddListChild( RestoreDownNodeList );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_RestorePath, RestorePath );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreOwner, RestoreOwner );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_RestoreFrom, RestoreFrom );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_FileSize, FileSize );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_CompletedSize, CompletedSize );
  MyXmlUtil.AddChild( RestoreDownNode, Xml_SavePath, SavePath );
end;

{ TRestoreDownRemoveXml }

procedure TRestoreDownRemoveXml.Update;
begin
  inherited;

  if not FindRestoreDownNode then
    Exit;

  MyXmlUtil.DeleteListChild( RestoreDownNodeList, RestoreDownIndex );
end;



{ TRestoreDownReadXmlHandle }

procedure TMyRestoreDownReadXml.Update;
var
  MyRestoreDownNode : IXMLNode;
  RestoreDownNodeList : IXMLNode;
  i : Integer;
  RestoreDownNode : IXMLNode;
  RestoreDownReadXml : TRestoreDownReadXml;
begin
  MyRestoreDownNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyRestoreDownInfo );
  RestoreDownNodeList := MyXmlUtil.AddChild( MyRestoreDownNode, Xml_RestoreDownList );
  for i := 0 to RestoreDownNodeList.ChildNodes.Count - 1 do
  begin
    RestoreDownNode := RestoreDownNodeList.ChildNodes[i];
    RestoreDownReadXml := TRestoreDownReadXml.Create( RestoreDownNode );
    RestoreDownReadXml.Update;
    RestoreDownReadXml.Free;
  end;
end;



{ RestoreDownNode }

constructor TRestoreDownReadXml.Create( _RestoreDownNode : IXMLNode );
begin
  RestoreDownNode := _RestoreDownNode;
end;

procedure TRestoreDownReadXml.Update;
var
  RestorePath, RestoreOwner, RestoreFrom : string;
  FileCount : integer;
  FileSize, CompletedSize : int64;
  SavePath : string;
  RestoreDownReadHandle : TRestoreDownReadHandle;
begin
  RestorePath := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestorePath );
  RestoreOwner := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestoreOwner );
  RestoreFrom := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_RestoreFrom );
  FileCount := MyXmlUtil.GetChildIntValue( RestoreDownNode, Xml_FileCount );
  FileSize := MyXmlUtil.GetChildInt64Value( RestoreDownNode, Xml_FileSize );
  CompletedSize := MyXmlUtil.GetChildInt64Value( RestoreDownNode, Xml_CompletedSize );
  SavePath := MyXmlUtil.GetChildValue( RestoreDownNode, Xml_SavePath );

  RestoreDownReadHandle := TRestoreDownReadHandle.Create( RestorePath, RestoreOwner );
  RestoreDownReadHandle.SetRestoreFrom( RestoreFrom );
  RestoreDownReadHandle.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownReadHandle.SetSavePath( SavePath );
  RestoreDownReadHandle.Update;
  RestoreDownReadHandle.Free;
end;



end.
