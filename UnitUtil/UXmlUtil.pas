unit UXmlUtil;

interface

uses xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, SysUtils, Forms, Classes, SyncObjs,
     DateUtils, UMyUtil, UChangeInfo, IniFiles;

type

    // xml ��Ϣ ������
  MyXmlUtil = class
  public
    class function getXmlPath : string;
    class function getXmlPathTest : string;
    class procedure IniXml;
  public            // �޸�
    class function AddChild( Parent : IXMLNode; ChildName : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName, Value : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Integer ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Int64 ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Double ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Boolean ):IXMLNode;overload;
    class procedure DeleteChild( Parent : IXMLNode; ChildName : string );
  public            // ��ȡ
    class function GetChildValue( Parent : IXMLNode; ChildName : string ): string;
    class function GetChildIntValue( Parent : IXMLNode; ChildName : string ): Integer;
    class function GetChildInt64Value( Parent : IXMLNode; ChildName : string ): Int64;
    class function GetChildBoolValue( Parent : IXMLNode; ChildName : string ): Boolean;
    class function GetChildFloatValue( Parent : IXMLNode; ChildName : string ): Double;
  public            // Hash: Key - Value
    class function AddListChild( Parent : IXMLNode; Key : string ):IXMLNode;overload;
    class procedure DeleteListChild( Parent : IXMLNode; Key : string );overload;
    class function FindListChild( Parent : IXMLNode; Key : string ):IXMLNode;overload;
  public            // List
    class function AddListChild( Parent : IXMLNode ):IXMLNode;overload;
    class procedure DeleteListChild( Parent : IXMLNode; NodeIndex : Integer );overload;
  end;

    // д Xml �ļ� �߳�
  TXmlDocSaveThread = class( TThread )
  private
    IsSaveNow : Boolean;
  public
    constructor Create;
    procedure SaveXmlNow;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SaveXmlFile;
  end;

  TMyXmlSave = class
  private
    XmlDocSaveThread : TXmlDocSaveThread;
  public
    constructor Create;
    procedure StartThread;
    procedure SaveNow;
    destructor Destroy; override;
  end;

const
  Xml_ChildName : string = 'cn';
  Xml_AttrKey : string = 'k';
  Xml_ListChild : string = 'lc';

    // ��
  Xml_BackupCow = 'bc';

    // ������Ϣ
  Xml_MyBackupInfo = 'mbi';
  Xml_BackupPathHash = 'bph';

    // �����ļ� ɾ����Ϣ
  Xml_MyBackupRemoveNotifyInfo = 'mbrni';
  Xml_RemoveBackupNotifyHash = 'rbnh';

    // ����Ϣ
  Xml_MyCloudPathInfo = 'mcpi';
  Xml_CloudPathHash = 'cph';

    // ���ļ� ɾ����Ϣ
  Xml_MyCloudRemoveNotifyInfo = 'mcrni';
  Xml_RemoveCloudNotifyHash = 'rcnh';

    // ����������Ϣ
  Xml_MyNetPcInfo  = 'mnpi';
  Xml_NetPcHash = 'nph';

    // ��ע����Ϣ
  Xml_MyBatRegisterInfo = 'mbri';
  Xml_PcBatRegisterHash = 'pbrh';

    // ����������Ϣ
  Xml_MySearchDownInfo = 'msdi';
  Xml_SearchDownFileHash = 'sdfh';

    // �ָ��ļ���Ϣ
  Xml_MyRestoreFileInfo = 'mrfi';
  Xml_RestoreItemHash = 'rih';

    // ���ر��� Դ��Ϣ
  Xml_MyLocalBackupSourceInfo = 'mlbsi';
  Xml_LocalBackupSourceList = 'lbsl';

    // ���ر��� Ŀ����Ϣ
  Xml_MyDestinationInfo = 'mdti';
  Xml_DestinationList = 'dtl';

    // �����ļ���Ϣ
  Xml_MyFileReceiveInfo = 'mfri';
  Xml_FileReceiveList = 'frl';
  Xml_FileReceiveCancelList = 'frcl';

    // �����ļ���Ϣ
  Xml_MyFileSendInfo = 'mfsi';
  Xml_FileSendList = 'fsl';
  Xml_FileSendCancelList = 'fscl';

    // �����ļ���Ϣ
  Xml_MySharePathInfo = 'mspi';
  Xml_SharePathList = 'spl';
  Xml_ShareDownList = 'sdl';
  Xml_ShareHisrotyList = 'shl';
  Xml_ShareFavoriteList = 'sfl';

    // ��ȡ Xml��Ϣ
  XmlReadCount_Sleep = 10;

var
    // Xml Doc ��Ŀ¼
  MyXmlDoc : TXMLDocument;

    // ������Ϣ
  MyBackupInfoXml : IXMLNode;
  BackupPathHashXml : IXMLNode;

    // �����ļ� ɾ����Ϣ
  MyBackupRemoveNotifyInfoXml : IXMLNode;
  RemoveBackupNotifyHashXml : IXMLNode;

    // ����Ϣ
  MyCloudPathInfoXml : IXMLNode;
  CloudPathHashXml : IXMLNode;

    // ���ļ� ɾ����Ϣ
  MyCloudRemoveNotifyInfoXml : IXMLNode;
  RemoveCloudNotifyHashXml : IXMLNode;

    // ����������Ϣ
  MyNetPcInfoXml : IXMLNode;
  NetPcHashXml : IXMLNode;

    // ��ע����Ϣ
  MyBatRegisterXml : IXMLNode;
  PcBatRegisterHashXml : IXMLNode;

    // ����������Ϣ
  MySearchDownXml : IXMLNode;
  SearchDownFileHashXml : IXMLNode;

    // �ָ��ļ���Ϣ
  MyRestoreFileXml : IXMLNode;
  RestoreItemHashXml : IXMLNode;

    // ���ر��� Ŀ����Ϣ
  MyDestinationXml : IXMLNode;
  DestinationListXml : IXMLNode;

    // ���ر��� Դ��Ϣ
  MyLocalBackupSourceXml : IXMLNode;
  LocalBackupSourceListXml : IXMLNode;

    // �����ļ���Ϣ
  MyFileReceiveXml : IXMLNode;
  FileReceiveListXml : IXMLNode;
  FileReceiveCancelListXml : IXMLNode;

    // �����ļ���Ϣ
  MyFileSendXml : IXMLNode;
  FileSendListXml : IXMLNode;
  FileSendCancelListXml : IXMLNode;

    // �����ļ���Ϣ
  MySharePathXml : IXMLNode;
  SharePathListXml : IXMLNode;
  ShareDownListXml : IXMLNode;
  ShareHisrotyListXml : IXMLNode;
  ShareFavoriteListXml : IXMLNode;

    // Xml ��ʱ����
  MyXmlSave : TMyXmlSave;

implementation

{ TMyXmlUtil }

class procedure MyXmlUtil.DeleteChild(Parent: IXMLNode; ChildName: string);
var
  i : Integer;
begin
  for i := 0 to Parent.ChildNodes.Count - 1 do
    if Parent.ChildNodes[i].NodeName = ChildName then
    begin
      Parent.ChildNodes.Delete(i);
      Break;
    end;
end;

class procedure MyXmlUtil.DeleteListChild(Parent: IXMLNode; NodeIndex: Integer);
begin
  Parent.ChildNodes.Delete( NodeIndex );
end;

class procedure MyXmlUtil.DeleteListChild(Parent: IXMLNode; Key: string);
var
  i : Integer;
  Child : IXMLNode;
begin
  for i := 0 to Parent.ChildNodes.Count - 1 do
  begin
    Child := Parent.ChildNodes[i];
    if Child.Attributes[ Xml_AttrKey ] = Key then
    begin
      Parent.ChildNodes.Delete( i );
      Break;
    end;
  end;
end;

class function MyXmlUtil.FindListChild(Parent: IXMLNode; Key: string): IXMLNode;
var
  i : Integer;
  Child : IXMLNode;
begin
  Result := nil;

  for i := 0 to Parent.ChildNodes.Count - 1 do
  begin
    Child := Parent.ChildNodes[i];
    if Child.Attributes[ Xml_AttrKey ] = Key then
    begin
      Result := Child;
      Break;
    end;
  end;
end;


class function MyXmlUtil.GetChildBoolValue(Parent: IXMLNode;
  ChildName: string): Boolean;
begin
  Result := StrToBoolDef( GetChildValue( Parent, ChildName ), False );
end;

class function MyXmlUtil.GetChildFloatValue(Parent: IXMLNode;
  ChildName: string): Double;
begin
  Result := StrToFloatDef( GetChildValue( Parent, ChildName ), Now );
end;

class function MyXmlUtil.GetChildInt64Value(Parent: IXMLNode;
  ChildName: string): Int64;
begin
  Result := StrToInt64Def( GetChildValue( Parent, ChildName ), 0 );
end;

class function MyXmlUtil.GetChildIntValue(Parent: IXMLNode;
  ChildName: string): Integer;
begin
  Result := StrToIntDef( GetChildValue( Parent, ChildName ), 0 );
end;

class function MyXmlUtil.GetChildValue(Parent: IXMLNode;
  ChildName: string): string;
var
  Child : IXMLNode;
begin
  Result := '';
  Child := Parent.ChildNodes.FindNode( ChildName );
  if Child <> nil then
    Result := Child.Text;
end;

class function MyXmlUtil.getXmlPath: string;
begin
  Result := MyAppDataPath.get + 'BackupCowInfo.dat';
end;

class function MyXmlUtil.getXmlPathTest: string;
begin
  Result := MyAppDataPath.get + 'BackupCowInfo.xml';
end;

class procedure MyXmlUtil.IniXml;
var
  XmlPath : string;
  RootNode : IXMLNode;
begin
    // ���� ��Ŀ¼
  if MyXmlDoc.DocumentElement = nil then
    MyXmlDoc.DocumentElement := MyXmlDoc.CreateNode( Xml_BackupCow );
  RootNode := MyXmlDoc.DocumentElement;

    // ������Ϣ�� xml �ڵ�
  MyBackupInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyBackupInfo );
  BackupPathHashXml := MyXmlUtil.AddChild( MyBackupInfoXml, Xml_BackupPathHash );

    // �����ļ� ɾ����Ϣ  xml �ڵ�
  MyBackupRemoveNotifyInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyBackupRemoveNotifyInfo );
  RemoveBackupNotifyHashXml := MyXmlUtil.AddChild( MyBackupRemoveNotifyInfoXml, Xml_RemoveBackupNotifyHash );

    // ����Ϣ�� xml �ڵ�
  MyCloudPathInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyCloudPathInfo );
  CloudPathHashXml := MyXmlUtil.AddChild( MyCloudPathInfoXml, Xml_CloudPathHash );

    // ���ļ� ɾ����Ϣ  xml �ڵ�
  MyCloudRemoveNotifyInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyCloudRemoveNotifyInfo );
  RemoveCloudNotifyHashXml := MyXmlUtil.AddChild( MyCloudRemoveNotifyInfoXml, Xml_RemoveCloudNotifyHash );

    // ����������Ϣ�� Xml �ڵ�
  MyNetPcInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );

    // ��ע�� Xml �ڵ�
  MyBatRegisterXml := MyXmlUtil.AddChild( RootNode, Xml_MyBatRegisterInfo );
  PcBatRegisterHashXml := MyXmlUtil.AddChild( MyBatRegisterXml, Xml_PcBatRegisterHash );

    // �������� Xml �ڵ�
  MySearchDownXml := MyXmlUtil.AddChild( RootNode, Xml_MySearchDownInfo );
  SearchDownFileHashXml := MyXmlUtil.AddChild( MySearchDownXml, Xml_SearchDownFileHash );

    // �ָ��ļ� Xml �ڵ�
  MyRestoreFileXml := MyXmlUtil.AddChild( RootNode, Xml_MyRestoreFileInfo );
  RestoreItemHashXml := MyXmlUtil.AddChild( MyRestoreFileXml, Xml_RestoreItemHash );

    // �������� Դ��Ϣ Xml �ڵ�
  MyLocalBackupSourceXml := MyXmlUtil.AddChild( RootNode, Xml_MyLocalBackupSourceInfo );
  LocalBackupSourceListXml := MyXmlUtil.AddChild( MyLocalBackupSourceXml, Xml_LocalBackupSourceList );

    // �������� Ŀ����Ϣ Xml �ڵ�
  MyDestinationXml := MyXmlUtil.AddChild( RootNode, Xml_MyDestinationInfo );
  DestinationListXml := MyXmlUtil.AddChild( MyDestinationXml, Xml_DestinationList );

    // �����ļ� Xml �ڵ�
  MyFileReceiveXml := MyXmlUtil.AddChild( RootNode, Xml_MyFileReceiveInfo );
  FileReceiveListXml := MyXmlUtil.AddChild( MyFileReceiveXml, Xml_FileReceiveList );
  FileReceiveCancelListXml := MyXmlUtil.AddChild( MyFileReceiveXml, Xml_FileReceiveCancelList );

    // �����ļ� Xml �ڵ�
  MyFileSendXml := MyXmlUtil.AddChild( RootNode, Xml_MyFileSendInfo );
  FileSendListXml := MyXmlUtil.AddChild( MyFileSendXml, Xml_FileSendList );
  FileSendCancelListXml := MyXmlUtil.AddChild( MyFileSendXml, Xml_FileSendCancelList );

    // �����ļ� Xml �ڵ�
  MySharePathXml := MyXmlUtil.AddChild( RootNode, Xml_MySharePathInfo );
  SharePathListXml := MyXmlUtil.AddChild( MySharePathXml, Xml_SharePathList );
  ShareDownListXml := MyXmlUtil.AddChild( MySharePathXml, Xml_ShareDownList );
  ShareHisrotyListXml := MyXmlUtil.AddChild( MySharePathXml, Xml_ShareHisrotyList );
  ShareFavoriteListXml := MyXmlUtil.AddChild( MySharePathXml, Xml_ShareFavoriteList );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName,
  Value: string): IXMLNode;
begin
  Result := AddChild( Parent, ChildName );
  Result.Text := Value;
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Int64): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, IntToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Integer): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, IntToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Boolean): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, BoolToStr( Value ) );
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode; ChildName : string;
  Value: Double): IXMLNode;
begin
  Result := AddChild( Parent, ChildName, FloatToStr( Value ) );
end;

class function MyXmlUtil.AddListChild(Parent: IXMLNode): IXMLNode;
begin
  Result := Parent.AddChild( Xml_ListChild );
end;

class function MyXmlUtil.AddListChild(Parent: IXMLNode; Key: string): IXMLNode;
var
  Child : IXMLNode;
begin
    // �Ҳ����򴴽�
  Child := FindListChild( Parent, Key );
  if Child = nil then
  begin
    Child := Parent.AddChild( Xml_ChildName );
    Child.Attributes[ Xml_AttrKey ] := Key;
  end;

  Result := Child;
end;

class function MyXmlUtil.AddChild(Parent: IXMLNode;
  ChildName: string): IXMLNode;
begin
  Result := Parent.ChildNodes.FindNode( ChildName );
  if Result = nil then
    Result := Parent.AddChild( ChildName );
end;

{ TXmlDocSaveThread }

constructor TXmlDocSaveThread.Create;
begin
  inherited Create( True );
  IsSaveNow := False;
end;

destructor TXmlDocSaveThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TXmlDocSaveThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin

      // 10 ���� ����һ��
    IsSaveNow := False;
    StartTime := Now;
    while not Terminated and ( MinutesBetween( Now, StartTime ) < 10 )
          and not IsSaveNow
    do
      Sleep(100);

      // ���� Xml �ļ�
    SaveXmlFile;
  end;

  inherited;
end;

procedure TXmlDocSaveThread.SaveXmlFile;
begin
  MyXmlChange.EnterXml;
  MyXmlDoc.SaveToFile( MyXmlUtil.getXmlPath );
  MyXmlChange.LeaveXml;
end;

procedure TXmlDocSaveThread.SaveXmlNow;
begin
  IsSaveNow := True;
end;

{ TMyXmlSave }

constructor TMyXmlSave.Create;
begin
  XmlDocSaveThread := TXmlDocSaveThread.Create;
end;

destructor TMyXmlSave.Destroy;
begin
  XmlDocSaveThread.Free;
  inherited;
end;

procedure TMyXmlSave.SaveNow;
begin
  XmlDocSaveThread.SaveXmlNow;
end;

procedure TMyXmlSave.StartThread;
begin
  XmlDocSaveThread.Resume;
end;

end.
