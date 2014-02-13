unit UMyCloudRemoveNotifyInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' Pc ����Դ�ļ�ɾ�� �ڴ���Ϣ ' }

  {$Region ' ���ݽṹ ' }

    // ɾ���ı���·����Ϣ
  TRemoveCloudPathInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TRemoveCloudPathPair = TPair< string , TRemoveCloudPathInfo >;
  TRemoveCloudPathHash = class(TStringDictionary< TRemoveCloudPathInfo >);


    // ɾ���� Pc �ļ���Ϣ
  TRemoveCloudNofityInfo = class
  public
    PcID : string;
    RemoveCloudPathHash : TRemoveCloudPathHash;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TRemoveCloudNotifyPair = TPair< string , TRemoveCloudNofityInfo >;
  TRemoveCloudNotifyHash = class(TStringDictionary< TRemoveCloudNofityInfo >);

  {$EndRegion}

  {$Region ' �޸� ' }

    // �޸�
  TRemoveCloudNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveCloudNotifyHash : TRemoveCloudNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // �޸� ָ��·��
  TRemoveCloudNotifyWriteInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // ���
  TRemoveCloudNotifyAddInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

    // Pc ����
  TRemoveCloudNotifyPcOnlineInfo = class( TRemoveCloudNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TRemoveCloudNotifyDeleteInfo = class( TRemoveCloudNotifyWriteInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // ɾ�� ���� Pc �ı����ļ���Ϣ
  TMyCloudRemoveNotifyInfo = class( TMyDataChange )
  public
    RemoveCloudNotifyHash : TRemoveCloudNotifyHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' Pc ����Դ�ļ�ɾ�� Xml ��Ϣ ' }

  {$Region ' �޸� ' }

    // �޸�
  TRemoveCloudNotifyChangeXml = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // �޸� ָ��·��
  TRemoveCloudNotifyWriteXml = class( TRemoveCloudNotifyChangeXml )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // ���
  TRemoveCloudNotifyAddXml = class( TRemoveCloudNotifyWriteXml )
  public
    procedure Update;override;
  end;

    // ɾ��
  TRemoveCloudNotifyDeleteXml = class( TRemoveCloudNotifyWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' ��ȡ ' }

  TPcRemoveCloudPathReadHandle = class
  private
    PcID : string;
    FullPath : string;
  public
    constructor Create( _PcID : string );
    procedure SetPathInfo( _FullPath : string );
    procedure Update;
  end;

    // ��ȡ Xml �ļ���Ϣ
  TCloudRemoveNotifyRead = class
  public
    procedure Update;
  end;

  {$EndRegion}

    // ɾ�� ���� Pc �ı����ļ���Ϣ
  TMyCloudFileRemoveWriteXml = class( TMyChildXmlChange )
  end;

{$EndRegion}

const
  Xml_PcID = 'pi';
  Xml_RemoveCloudPathHash = 'rbph';

  Xml_FullPath = 'fp';

var
  MyCloudRemoveNotifyInfo : TMyCloudRemoveNotifyInfo;
  MyCloudFileRemoveWriteXml : TMyCloudFileRemoveWriteXml;

implementation

uses UMyClient, UMyNetPcInfo;

{ TRemovePcFileInfo }

constructor TRemoveCloudNofityInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  RemoveCloudPathHash := TRemoveCloudPathHash.Create;
end;

destructor TRemoveCloudNofityInfo.Destroy;
begin
  RemoveCloudPathHash.Free;
  inherited;
end;

{ TMyCloudFileRemoveInfo }

constructor TMyCloudRemoveNotifyInfo.Create;
begin
  inherited;

  RemoveCloudNotifyHash := TRemoveCloudNotifyHash.Create;
  AddThread(1);
end;

destructor TMyCloudRemoveNotifyInfo.Destroy;
begin
  DeleteThread(1);
  RemoveCloudNotifyHash.Free;
  inherited;
end;

{ TRemovePcFileAddInfo }

procedure TRemoveCloudNotifyAddInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    RemoveCloudNotifyHash.addOrSetValue( PcID, TRemoveCloudNofityInfo.Create( PcID ) );

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  if RemoveCloudPathHash.ContainsKey( FullPath ) then
    Exit;

  RemoveCloudPathHash.AddOrSetValue( FullPath, TRemoveCloudPathInfo.Create( FullPath ) )
end;

{ TRemovePcFileChangeInfo }

constructor TRemoveCloudNotifyChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRemoveCloudNotifyChangeInfo.Update;
begin
  RemoveCloudNotifyHash := MyCloudRemoveNotifyInfo.RemoveCloudNotifyHash;
end;

{ TRemovePcOnlineInfo }

procedure TRemoveCloudNotifyPcOnlineInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
  p : TRemoveCloudPathPair;
  CloudFileRemoveMsg : TCloudFileRemoveMsg;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    Exit;

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  for p in RemoveCloudPathHash do
  begin
        // ��������
    CloudFileRemoveMsg := TCloudFileRemoveMsg.Create;
    CloudFileRemoveMsg.SetPcID( PcInfo.PcID );
    CloudFileRemoveMsg.SetFilePath( p.Value.FullPath );
    MyClient.SendMsgToPc( PcID, CloudFileRemoveMsg );
  end;
end;

{ TRemovePcFileWriteInfo }

procedure TRemoveCloudNotifyWriteInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileRemoveInfo }

procedure TRemoveCloudNotifyDeleteInfo.Update;
var
  RemoveCloudPathHash : TRemoveCloudPathHash;
begin
  inherited;

  if not RemoveCloudNotifyHash.ContainsKey( PcID ) then
    Exit;

  RemoveCloudPathHash := RemoveCloudNotifyHash[ PcID ].RemoveCloudPathHash;
  if RemoveCloudPathHash.ContainsKey( FullPath ) then
    RemoveCloudPathHash.Remove( FullPath );

  if RemoveCloudPathHash.Count = 0 then
    RemoveCloudNotifyHash.Remove( PcID );
end;

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

{ TRemoveCloudPathInfo }

constructor TRemoveCloudPathInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
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

        // ���� ����ɾ��·��
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

