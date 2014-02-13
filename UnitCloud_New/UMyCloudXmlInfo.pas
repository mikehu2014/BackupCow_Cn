unit UMyCloudXmlInfo;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UMyUtil;

type

{$Region ' 数据修改 云路径信息 ' }

    // 父类
  TCloudPcChangeXml = class( TXmlChangeInfo )
  protected
    MyCloudNode : IXMLNode;
    CloudPcNodeList : IXMLNode;
  protected
    procedure Update;override;
  end;

    // 重设
  TCloudPathReSetXml = class( TCloudPcChangeXml )
  public
    CloudPath : string;
  public
    constructor Create( _CloudPath : string );
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 数据修改 Pc信息 ' }


    // 修改
  TCloudPcWriteXml = class( TCloudPcChangeXml )
  public
    PcID : string;
  protected
    CloudPcIndex : Integer;
    CloudPcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindCloudPcNode: Boolean;
  end;


    // 添加
  TCloudPcAddXml = class( TCloudPcWriteXml )
  public
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPcRemoveXml = class( TCloudPcWriteXml )
  protected
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 数据修改 备份信息 ' }

    // 父类
  TCloudPcBackupChangeXml = class( TCloudPcWriteXml )
  protected
    CloudPcBackupNodeList : IXMLNode;
  protected
    function FindCloudPcBackupNodeList : Boolean;
  end;

    // 修改
  TCloudPcBackupWriteXml = class( TCloudPcBackupChangeXml )
  public
    BackupPath : string;
  protected
    CloudPcBackupIndex : Integer;
    CloudPcBackupNode : IXMLNode;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindCloudPcBackupNode: Boolean;
  end;

    // 添加
  TCloudPcBackupAddXml = class( TCloudPcBackupWriteXml )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPcBackupRemoveXml = class( TCloudPcBackupWriteXml )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 数据读取 ' }

    // 读取
  TCloudPcBackupReadXml = class
  public
    CloudPcBackupNode : IXMLNode;
    PcID : string;
  public
    constructor Create( _CloudPcBackupNode : IXMLNode );
    procedure SetPcID( _PcID : string );
    procedure Update;
  end;

    // 读取
  TCloudPcReadXml = class
  public
    CloudPcNode : IXMLNode;
  public
    PcID : string;
  public
    constructor Create( _CloudPcNode : IXMLNode );
    procedure Update;
  private
    procedure ReadCloudPcBackupList;
  end;


    // 读取
  TMyCloudInfoReadXml = class
  private
    MyCloudNode : IXMLNode;
  public
    procedure Update;
  private
    procedure ReadCloudPath;
    procedure ReadCloudPcList;
  end;

{$EndRegion}

const
  Xml_MyCloudInfo = 'mcif';
  Xml_CloudPath = 'cp';

  Xml_CloudPcList = 'cpl';
  Xml_PcID = 'pid';

  Xml_CloudPcInfo = 'cpi';
  Xml_CloudPcBackupList = 'cpbl';
  Xml_BackupPath = 'bp';
  Xml_IsFile = 'if';
  Xml_FileCount = 'fc';
  Xml_ItemSize = 'is';
  Xml_LastBackupTime = 'lbt';


implementation

uses UMyCloudApiInfo;

{ TCloudPcChangeXml }

procedure TCloudPcChangeXml.Update;
begin
  MyCloudNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyCloudInfo );
  CloudPcNodeList := MyXmlUtil.AddChild( MyCloudNode, Xml_CloudPcList );
end;

{ TCloudPcWriteXml }

constructor TCloudPcWriteXml.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TCloudPcWriteXml.FindCloudPcNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  for i := 0 to CloudPcNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := CloudPcNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_PcID ) = PcID ) then
    begin
      Result := True;
      CloudPcIndex := i;
      CloudPcNode := CloudPcNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPcAddXml }

procedure TCloudPcAddXml.Update;
begin
  inherited;

  if FindCloudPcNode then
    Exit;

  CloudPcNode := MyXmlUtil.AddListChild( CloudPcNodeList );
  MyXmlUtil.AddChild( CloudPcNode, Xml_PcID, PcID );
end;

{ TCloudPcRemoveXml }

procedure TCloudPcRemoveXml.Update;
begin
  inherited;

  if not FindCloudPcNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudPcNodeList, CloudPcIndex );
end;

{ TCloudPcBackupChangeXml }

function TCloudPcBackupChangeXml.FindCloudPcBackupNodeList : Boolean;
begin
  Result := FindCloudPcNode;
  if Result then
    CloudPcBackupNodeList := MyXmlUtil.AddChild( CloudPcNode, Xml_CloudPcBackupList );
end;

{ TCloudPcBackupWriteXml }

procedure TCloudPcBackupWriteXml.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TCloudPcBackupWriteXml.FindCloudPcBackupNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;
  if not FindCloudPcBackupNodeList then
    Exit;
  for i := 0 to CloudPcBackupNodeList.ChildNodes.Count - 1 do
  begin
    SelectNode := CloudPcBackupNodeList.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_BackupPath ) = BackupPath ) then
    begin
      Result := True;
      CloudPcBackupIndex := i;
      CloudPcBackupNode := CloudPcBackupNodeList.ChildNodes[i];
      break;
    end;
  end;
end;

{ TCloudPcBackupAddXml }

procedure TCloudPcBackupAddXml.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudPcBackupAddXml.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudPcBackupAddXml.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudPcBackupAddXml.Update;
begin
  inherited;

    // 不存在 则创建
  if not FindCloudPcBackupNode then
  begin
    CloudPcBackupNode := MyXmlUtil.AddListChild( CloudPcBackupNodeList );
    MyXmlUtil.AddChild( CloudPcBackupNode, Xml_BackupPath, BackupPath );
    MyXmlUtil.AddChild( CloudPcBackupNode, Xml_IsFile, IsFile );
  end;

    // 存在 则重新设置 空间信息
  MyXmlUtil.AddChild( CloudPcBackupNode, Xml_FileCount, FileCount );
  MyXmlUtil.AddChild( CloudPcBackupNode, Xml_ItemSize, ItemSize );
  MyXmlUtil.AddChild( CloudPcBackupNode, Xml_LastBackupTime, LastBackupTime );
end;

{ TCloudPcBackupRemoveXml }

procedure TCloudPcBackupRemoveXml.Update;
begin
  inherited;

  if not FindCloudPcBackupNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudPcBackupNodeList, CloudPcBackupIndex );
end;



{ TCloudPathReSetXml }

constructor TCloudPathReSetXml.Create(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

procedure TCloudPathReSetXml.Update;
begin
  inherited;
  MyXmlUtil.AddChild( MyCloudNode, Xml_CloudPath, CloudPath );
  CloudPcNodeList.ChildNodes.Clear;
end;

{ TMyCloudInfoReadXml }

procedure TMyCloudInfoReadXml.ReadCloudPath;
var
  CloudPath : string;
  CloudPathReSetXml : TCloudPathReSetXml;
  CloudPathReadHandle : TCloudPathReadHandle;
begin
  CloudPath := MyXmlUtil.GetChildValue( MyCloudNode, Xml_CloudPath );
  if CloudPath = '' then
  begin
    CloudPath := MyHardDisk.getBiggestHardDIsk + 'BackupCow.Backup';
    CloudPathReSetXml := TCloudPathReSetXml.Create( CloudPath );
    CloudPathReSetXml.AddChange;
  end;

    // 处理
  CloudPathReadHandle := TCloudPathReadHandle.Create( CloudPath );
  CloudPathReadHandle.Update;
  CloudPathReadHandle.Free;
end;

procedure TMyCloudInfoReadXml.ReadCloudPcList;
var
  CloudPcNodeList : IXMLNode;
  i : Integer;
  CloudPcNode : IXMLNode;
  CloudPcReadXml : TCloudPcReadXml;
begin
  CloudPcNodeList := MyXmlUtil.AddChild( MyCloudNode, Xml_CloudPcList );
  for i := 0 to CloudPcNodeList.ChildNodes.Count - 1 do
  begin
    CloudPcNode := CloudPcNodeList.ChildNodes[i];
    CloudPcReadXml := TCloudPcReadXml.Create( CloudPcNode );
    CloudPcReadXml.Update;
    CloudPcReadXml.Free;
  end;
end;

procedure TMyCloudInfoReadXml.Update;
begin
  MyCloudNode := MyXmlUtil.AddChild( MyXmlDoc.DocumentElement, Xml_MyCloudInfo );

  ReadCloudPath;

  ReadCloudPcList;
end;

{ CloudPcNode }

constructor TCloudPcReadXml.Create( _CloudPcNode : IXMLNode );
begin
  CloudPcNode := _CloudPcNode;
end;

procedure TCloudPcReadXml.ReadCloudPcBackupList;
var
  CloudPcBackupNodeList : IXMLNode;
  i : Integer;
  CloudPcBackupNode : IXMLNode;
  CloudPcBackupReadXml : TCloudPcBackupReadXml;
begin
  CloudPcBackupNodeList := MyXmlUtil.AddChild( CloudPcNode, Xml_CloudPcBackupList );
  for i := 0 to CloudPcBackupNodeList.ChildNodes.Count - 1 do
  begin
    CloudPcBackupNode := CloudPcBackupNodeList.ChildNodes[i];
    CloudPcBackupReadXml := TCloudPcBackupReadXml.Create( CloudPcBackupNode );
    CloudPcBackupReadXml.SetPcID( PcID );
    CloudPcBackupReadXml.Update;
    CloudPcBackupReadXml.Free;
  end;
end;


procedure TCloudPcReadXml.Update;
var
  CloudPcReadHandle : TCloudPcReadHandle;
begin
  PcID := MyXmlUtil.GetChildValue( CloudPcNode, Xml_PcID );

  CloudPcReadHandle := TCloudPcReadHandle.Create( PcID );
  CloudPcReadHandle.Update;
  CloudPcReadHandle.Free;

  ReadCloudPcBackupList;
end;

{ CloudPcBackupNode }

constructor TCloudPcBackupReadXml.Create( _CloudPcBackupNode : IXMLNode );
begin
  CloudPcBackupNode := _CloudPcBackupNode;
end;

procedure TCloudPcBackupReadXml.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TCloudPcBackupReadXml.Update;
var
  BackupPath : string;
  IsFile : boolean;
  FileCount : integer;
  ItemSize : int64;
  LastBackupTime : TDateTime;
  CloudPcBackupReadHandle : TCloudPcBackupReadHandle;
begin
  BackupPath := MyXmlUtil.GetChildValue( CloudPcBackupNode, Xml_BackupPath );
  IsFile := MyXmlUtil.GetChildBoolValue( CloudPcBackupNode, Xml_IsFile );
  FileCount := MyXmlUtil.GetChildIntValue( CloudPcBackupNode, Xml_FileCount );
  ItemSize := MyXmlUtil.GetChildInt64Value( CloudPcBackupNode, Xml_ItemSize );
  LastBackupTime := MyXmlUtil.GetChildFloatValue( CloudPcBackupNode, Xml_LastBackupTime );

  CloudPcBackupReadHandle := TCloudPcBackupReadHandle.Create( PcID );
  CloudPcBackupReadHandle.SetBackupPath( BackupPath );
  CloudPcBackupReadHandle.SetIsFile( IsFile );
  CloudPcBackupReadHandle.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupReadHandle.SetLastBackupTime( LastBackupTime );
  CloudPcBackupReadHandle.Update;
  CloudPcBackupReadHandle.Free;
end;

end.
