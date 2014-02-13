unit UCloudPathInfoXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, Classes, UMyUtil, SysUtils;

type

{$Region ' ����Ϣ �޸� ' }

  {$Region ' ��·�� �޸� ' }

    // �޸�
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

    // ���
  TCloudPathAddXml = class( TCloudPathChangeXml )
  public
    procedure Update;override;
  end;

    // ɾ��
  TCloudPathRemoveXml = class( TCloudPathChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' ��·�� ӵ���� �޸� ' }

    // �޸�
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

    // ɾ�� Pc �ڵ�
  TCloudPathOwnerRemoveXml = class( TCloudPathOwnerChangeXml )
  public
    procedure Update;override;
  end;

    // �޸� ӵ����
  TCloudPathOwnerWriteXml = class( TCloudPathOwnerChangeXml )
  protected
    CloudPathOwnerNode : IXMLNode;
  public
    function FindCloudPathOwnerNode : Boolean;
    procedure AddCloudPathOwnerNode;
  end;

    // ���� ���һ�� ɨ��ʱ��
  TCloudPathOwnerSetLastScanTimeXml = class( TCloudPathOwnerWriteXml )
  private
    LastScanTime : TDateTime;
  public
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;override;
  end;

  {$Region ' �޸� �ռ���Ϣ ' }

    // �޸� �ռ���Ϣ
  TCloudPathOwnerChangeSpaceXml = class( TCloudPathOwnerWriteXml )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ���
  TCloudPathOwnerAddSpaceXml = class( TCloudPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // ɾ��
  TCloudPathOwnerRemoveSpaceXml = class( TCloudPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // ����
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

{$Region ' ����Ϣ ��ȡ ' }

    // ��ȡ ��·�� ��Ϣ
  TCloudPathXmlReadHandle = class
  private
    CloudPathNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudPathNode : IXMLNode );
    procedure Update;
  private       // ��ȡ ��·�� ӵ����
    procedure ReadCloudPathOwner;
  end;

    // ��ȡ ��·��Ŀ¼ ��Ϣ
  TCloudPathOwnerXmlReadHandle = class
  private
    CloudPathOwnerNode : IXMLNode;
    CloudPath : string;
  public
    constructor Create( _CloudPathOwnerNode : IXMLNode );
    procedure SetCloudPath( _CloudPath : string );
    procedure Update;
  end;

    // ��� Ĭ�ϵ���·��
  TDefaultCloudPathAddHandle = class
  public
    procedure Update;
  end;

    // ����·���߳�
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
    // �Ѵ���
  if FindCloudPathNode then
    Exit;

    // ���
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
    // ��·�� ������, ���Ĭ��·��
  if CloudPathHashXml.ChildNodes.Count = 0 then
    AddDefaultCloudPath
  else
    ReadCloudPath; // ��ȡ ·����Ϣ
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

    // ��ȡ ��·��
  CloudPathReadHandle := TCloudPathReadHandle.Create( CloudPath );
  CloudPathReadHandle.Update;
  CloudPathReadHandle.Free;

    // ��ȡ ��·�� ӵ����
  ReadCloudPathOwner;
end;

{ TDefaultCloudPathHandle }

procedure TDefaultCloudPathAddHandle.Update;
var
  DefaultCloudPath : string;
  CloudPathAddHandle : TCloudPathAddHandle;
begin
    // Ĭ��·��
  DefaultCloudPath := MyHardDisk.getBiggestHardDIsk;
  DefaultCloudPath := DefaultCloudPath + 'BackupCow.Backup';

    // ��� ��·��
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
    // ������
  if not FindCloudPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( CloudPathHashXml, CloudPath );
end;

{ TCloudPcFolderRemoveXml }

procedure TCloudPathOwnerRemoveXml.Update;
begin
    // ��·�� ������
  if not FindCloudPathOwnerListNode then
    Exit;

    // ɾ�� ӵ����
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
    // ��ȡ Ŀ¼��Ϣ
  CloudPcID := MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_CloudPcID );
  CloudUsedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  CloudFileCount := StrToIntDef( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_FileCount ), 0 );
  LastOnlineTime := StrToFloatDef( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_LastScanTime ), 0 );

    // ��� ��·�� ӵ���� ��Ϣ
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

    // ·��������
  if not FindCloudPathNode then
    Exit;

    // ӵ���� �б�
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
    // ��·�� Pc Ŀ¼
  if not FindCloudPathOwnerListNode then
    Exit;

    // ������ �����
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
    // ��·�� Pc Ŀ¼
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

    // û���ļ���
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
    // ������
  if not FindCloudPathOwnerListNode then
    Exit;

    // ������ �� ���
  AddCloudPathOwnerNode;

    // �ռ� �ѷ����仯
  ReadFileSize := StrToInt64Def( MyXmlUtil.GetChildValue( CloudPathOwnerNode, Xml_UsedSpace ), 0 );
  if ReadFileSize <> LastFileSize then
    Exit;

    // �޸���Ϣ
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
    // ��·�� Pc Ŀ¼
  if not FindCloudPathOwnerListNode then
    Exit;

    // ������ �����
  AddCloudPathOwnerNode;

    // ���� ���һ��ɨ��ʱ��
  MyXmlUtil.AddChild( CloudPathOwnerNode, Xml_LastScanTime, FloatToStr( LastScanTime ) );
end;

end.
