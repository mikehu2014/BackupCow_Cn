unit UMyBackupRemoveInfo;

interface

uses classes, UModelUtil, Generics.Collections, UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil;

type

{$Region ' Pc 备份源文件删除 内存信息 ' }

  {$Region ' 数据结构 ' }

    // 删除的备份路径信息
  TRemoveBackupPathInfo = class
  public
    FullPath : string;
    PathType : string;
  public
    constructor Create( _FullPath, _PathType : string );
  end;
  TRemoveBackupPathPair = TPair< string , TRemoveBackupPathInfo >;
  TRemoveBackupPathHash = class(TStringDictionary< TRemoveBackupPathInfo >);


    // 删除的 Pc 文件信息
  TRemoveBackupNofityInfo = class
  public
    PcID : string;
    RemoveBackupPathHash : TRemoveBackupPathHash;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TRemoveBackupNotifyPair = TPair< string , TRemoveBackupNofityInfo >;
  TRemoveBackupNotifyHash = class(TStringDictionary< TRemoveBackupNofityInfo >);

  {$EndRegion}

  {$Region ' 修改 ' }

    // 修改
  TRemoveBackupNotifyChangeInfo = class( TChangeInfo )
  public
    PcID : string;
    RemoveBackupNotifyHash : TRemoveBackupNotifyHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // 修改 指定路径
  TRemoveBackupNotifyWriteInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
  end;

    // 添加
  TRemoveBackupNotifyAddInfo = class( TRemoveBackupNotifyWriteInfo )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // Pc 上线
  TRemoveBackupNotifyPcOnlineInfo = class( TRemoveBackupNotifyChangeInfo )
  public
    procedure Update;override;
  end;

    // 删除
  TRemoveBackupNotifyDeleteInfo = class( TRemoveBackupNotifyWriteInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // 删除 网络 Pc 的备份文件信息
  TMyBackupRemoveNotifyInfo = class( TMyDataChange )
  public
    RemoveBackupNotifyHash : TRemoveBackupNotifyHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' Pc 备份源文件删除 Xml 信息 ' }

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
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // 删除
  TRemoveBackupNotifyDeleteXml = class( TRemoveBackupNotifyWriteXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 读取 ' }

  TPcRemoveBackupPathReadHandle = class
  private
    PcID : string;
    FullPath, PathType : string;
  public
    constructor Create( _PcID : string );
    procedure SetPathInfo( _FullPath, _PathType : string );
    procedure Update;
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

{$EndRegion}

const
  Xml_PcID = 'pi';
  Xml_RemoveBackupPathHash = 'rbph';

  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';

var
  MyBackupRemoveNotifyInfo : TMyBackupRemoveNotifyInfo;
  MyBackupFileRemoveWriteXml : TMyBackupFileRemoveWriteXml;

implementation

uses UMyClient, UMyNetPcInfo;

{ TRemovePcFileInfo }

constructor TRemoveBackupNofityInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  RemoveBackupPathHash := TRemoveBackupPathHash.Create;
end;

destructor TRemoveBackupNofityInfo.Destroy;
begin
  RemoveBackupPathHash.Free;
  inherited;
end;

{ TMyBackupFileRemoveInfo }

constructor TMyBackupRemoveNotifyInfo.Create;
begin
  inherited;

  RemoveBackupNotifyHash := TRemoveBackupNotifyHash.Create;
  AddThread(1);
end;

destructor TMyBackupRemoveNotifyInfo.Destroy;
begin
  DeleteThread(1);
  RemoveBackupNotifyHash.Free;
  inherited;
end;

{ TRemovePcFileAddInfo }

procedure TRemoveBackupNotifyAddInfo.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TRemoveBackupNotifyAddInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
begin
  inherited;

  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    RemoveBackupNotifyHash.addOrSetValue( PcID, TRemoveBackupNofityInfo.Create( PcID ) );

  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then
    Exit;

  RemoveBackupPathHash.AddOrSetValue( FullPath, TRemoveBackupPathInfo.Create( FullPath, PathType ) )
end;

{ TRemovePcFileChangeInfo }

constructor TRemoveBackupNotifyChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRemoveBackupNotifyChangeInfo.Update;
begin
  RemoveBackupNotifyHash := MyBackupRemoveNotifyInfo.RemoveBackupNotifyHash;
end;

{ TRemovePcOnlineInfo }

procedure TRemoveBackupNotifyPcOnlineInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
  p : TRemoveBackupPathPair;
  BackupFileRemoveMsg : TBackupFileRemoveMsg;
begin
  inherited;

  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;
  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;

  for p in RemoveBackupPathHash do
  begin
    BackupFileRemoveMsg := TBackupFileRemoveMsg.Create;
    BackupFileRemoveMsg.SetPcID( PcInfo.PcID );
    BackupFileRemoveMsg.SetFilePath( p.Value.FullPath );
    MyClient.SendMsgToPc( PcID, BackupFileRemoveMsg );
  end;
end;

{ TRemovePcFileWriteInfo }

procedure TRemoveBackupNotifyWriteInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRemovePcFileRemoveInfo }

procedure TRemoveBackupNotifyDeleteInfo.Update;
var
  RemoveBackupPathHash : TRemoveBackupPathHash;
begin
  inherited;

  if not RemoveBackupNotifyHash.ContainsKey( PcID ) then
    Exit;

  RemoveBackupPathHash := RemoveBackupNotifyHash[ PcID ].RemoveBackupPathHash;
  if RemoveBackupPathHash.ContainsKey( FullPath ) then
    RemoveBackupPathHash.Remove( FullPath );

  if RemoveBackupPathHash.Count = 0 then
    RemoveBackupNotifyHash.Remove( PcID );
end;

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

procedure TRemoveBackupNotifyAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TRemoveBackupNotifyAddXml.Update;
var
  RemoveNotifyNode : IXMLNode;
  RemoveBackupPathHashNode : IXMLNode;
  RemoveBackupPathNode : IXMLNode;
begin
  RemoveNotifyNode := MyXmlUtil.AddListChild( RemoveBackupNotifyHashXml, PcID );
  MyXmlUtil.AddChild( RemoveNotifyNode, Xml_PcID, PcID );
  RemoveBackupPathHashNode := MyXmlUtil.AddChild( RemoveNotifyNode, Xml_RemoveBackupPathHash );

  if MyXmlUtil.FindListChild( RemoveBackupPathHashNode, FullPath ) <> nil then
    Exit;

  RemoveBackupPathNode := MyXmlUtil.AddListChild( RemoveBackupPathHashNode, FullPath );
  MyXmlUtil.AddChild( RemoveBackupPathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( RemoveBackupPathNode, Xml_PathType, PathType );
end;

{ TRemoveBackupPathInfo }

constructor TRemoveBackupPathInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

{ TRemoveBackupNotifyDeleteXml }

procedure TRemoveBackupNotifyDeleteXml.Update;
var
  RemoveNotifyNode : IXMLNode;
  RemoveBackupPathHashNode : IXMLNode;
begin
  RemoveNotifyNode := MyXmlUtil.FindListChild( RemoveBackupNotifyHashXml, PcID );
  if RemoveNotifyNode = nil then
    Exit;

  RemoveBackupPathHashNode := MyXmlUtil.AddChild( RemoveNotifyNode, Xml_RemoveBackupPathHash );

  MyXmlUtil.DeleteListChild( RemoveBackupPathHashNode, FullPath );
  if RemoveBackupPathHashNode.ChildNodes.Count = 0 then
    MyXmlUtil.DeleteListChild( RemoveBackupNotifyHashXml, PcID  );
end;
{ TBackupRemoveNotifyRead }

procedure TBackupRemoveNotifyRead.Update;
var
  i, j : Integer;
  RemoveBackupNotify : IXMLNode;
  PcID, FullPath, PathType : string;
  RemoveBackupPathHash, RemoveBackupPathNode : IXMLNode;
  PcRemoveBackupPathReadHandle : TPcRemoveBackupPathReadHandle;
begin
  for i := 0 to RemoveBackupNotifyHashXml.ChildNodes.Count - 1 do
  begin
    RemoveBackupNotify := RemoveBackupNotifyHashXml.ChildNodes[i];
    PcID := MyXmlUtil.GetChildValue( RemoveBackupNotify, Xml_PcID );
    RemoveBackupPathHash := MyXmlUtil.AddChild( RemoveBackupNotify, Xml_RemoveBackupPathHash );
    for j := 0 to RemoveBackupPathHash.ChildNodes.Count - 1 do
    begin
      RemoveBackupPathNode := RemoveBackupPathHash.ChildNodes[j];
      FullPath := MyXmlUtil.GetChildValue( RemoveBackupPathNode, Xml_FullPath );
      PathType := MyXmlUtil.GetChildValue( RemoveBackupPathNode, Xml_PathType );

        // 加载 备份删除路径
      PcRemoveBackupPathReadHandle := TPcRemoveBackupPathReadHandle.Create( PcID );
      PcRemoveBackupPathReadHandle.SetPathInfo( FullPath, PathType );
      PcRemoveBackupPathReadHandle.Update;
      PcRemoveBackupPathReadHandle.Free;
    end;
  end;
end;

{ TPcRemoveBackupPathReadHandle }

constructor TPcRemoveBackupPathReadHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPcRemoveBackupPathReadHandle.SetPathInfo(_FullPath,
  _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TPcRemoveBackupPathReadHandle.Update;
var
  RemoveBackupNotifyAddInfo : TRemoveBackupNotifyAddInfo;
begin
  RemoveBackupNotifyAddInfo := TRemoveBackupNotifyAddInfo.Create( PcID );
  RemoveBackupNotifyAddInfo.SetFullPath( FullPath );
  RemoveBackupNotifyAddInfo.SetPathType( PathType );
  MyBackupRemoveNotifyInfo.AddChange( RemoveBackupNotifyAddInfo );
end;

end.
