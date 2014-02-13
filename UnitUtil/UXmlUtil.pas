unit UXmlUtil;

interface

uses xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, SysUtils, Forms, Classes, SyncObjs,
     DateUtils, UMyUtil, UChangeInfo, IniFiles;

type

    // xml 信息 辅助类
  MyXmlUtil = class
  public
    class function getXmlPath : string;
    class function getXmlPathTest : string;
    class procedure IniXml;
  public            // 修改
    class function AddChild( Parent : IXMLNode; ChildName : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName, Value : string ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Integer ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Int64 ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Double ):IXMLNode;overload;
    class function AddChild( Parent : IXMLNode; ChildName : string; Value : Boolean ):IXMLNode;overload;
    class procedure DeleteChild( Parent : IXMLNode; ChildName : string );
  public            // 读取
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

    // 写 Xml 文件 线程
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

    // 根
  Xml_BackupCow = 'bc';

    // 备份信息
  Xml_MyBackupInfo = 'mbi';
  Xml_BackupPathHash = 'bph';

    // 备份文件 删除信息
  Xml_MyBackupRemoveNotifyInfo = 'mbrni';
  Xml_RemoveBackupNotifyHash = 'rbnh';

    // 云信息
  Xml_MyCloudPathInfo = 'mcpi';
  Xml_CloudPathHash = 'cph';

    // 云文件 删除信息
  Xml_MyCloudRemoveNotifyInfo = 'mcrni';
  Xml_RemoveCloudNotifyHash = 'rcnh';

    // 网络计算机信息
  Xml_MyNetPcInfo  = 'mnpi';
  Xml_NetPcHash = 'nph';

    // 批注册信息
  Xml_MyBatRegisterInfo = 'mbri';
  Xml_PcBatRegisterHash = 'pbrh';

    // 搜索下载信息
  Xml_MySearchDownInfo = 'msdi';
  Xml_SearchDownFileHash = 'sdfh';

    // 恢复文件信息
  Xml_MyRestoreFileInfo = 'mrfi';
  Xml_RestoreItemHash = 'rih';

    // 本地备份 源信息
  Xml_MyLocalBackupSourceInfo = 'mlbsi';
  Xml_LocalBackupSourceList = 'lbsl';

    // 本地备份 目标信息
  Xml_MyDestinationInfo = 'mdti';
  Xml_DestinationList = 'dtl';

    // 接收文件信息
  Xml_MyFileReceiveInfo = 'mfri';
  Xml_FileReceiveList = 'frl';
  Xml_FileReceiveCancelList = 'frcl';

    // 发送文件信息
  Xml_MyFileSendInfo = 'mfsi';
  Xml_FileSendList = 'fsl';
  Xml_FileSendCancelList = 'fscl';

    // 共享文件信息
  Xml_MySharePathInfo = 'mspi';
  Xml_SharePathList = 'spl';
  Xml_ShareDownList = 'sdl';
  Xml_ShareHisrotyList = 'shl';
  Xml_ShareFavoriteList = 'sfl';

    // 读取 Xml信息
  XmlReadCount_Sleep = 10;

var
    // Xml Doc 根目录
  MyXmlDoc : TXMLDocument;

    // 备份信息
  MyBackupInfoXml : IXMLNode;
  BackupPathHashXml : IXMLNode;

    // 备份文件 删除信息
  MyBackupRemoveNotifyInfoXml : IXMLNode;
  RemoveBackupNotifyHashXml : IXMLNode;

    // 云信息
  MyCloudPathInfoXml : IXMLNode;
  CloudPathHashXml : IXMLNode;

    // 云文件 删除信息
  MyCloudRemoveNotifyInfoXml : IXMLNode;
  RemoveCloudNotifyHashXml : IXMLNode;

    // 网络计算机信息
  MyNetPcInfoXml : IXMLNode;
  NetPcHashXml : IXMLNode;

    // 批注册信息
  MyBatRegisterXml : IXMLNode;
  PcBatRegisterHashXml : IXMLNode;

    // 搜索下载信息
  MySearchDownXml : IXMLNode;
  SearchDownFileHashXml : IXMLNode;

    // 恢复文件信息
  MyRestoreFileXml : IXMLNode;
  RestoreItemHashXml : IXMLNode;

    // 本地备份 目标信息
  MyDestinationXml : IXMLNode;
  DestinationListXml : IXMLNode;

    // 本地备份 源信息
  MyLocalBackupSourceXml : IXMLNode;
  LocalBackupSourceListXml : IXMLNode;

    // 接收文件信息
  MyFileReceiveXml : IXMLNode;
  FileReceiveListXml : IXMLNode;
  FileReceiveCancelListXml : IXMLNode;

    // 发送文件信息
  MyFileSendXml : IXMLNode;
  FileSendListXml : IXMLNode;
  FileSendCancelListXml : IXMLNode;

    // 共享文件信息
  MySharePathXml : IXMLNode;
  SharePathListXml : IXMLNode;
  ShareDownListXml : IXMLNode;
  ShareHisrotyListXml : IXMLNode;
  ShareFavoriteListXml : IXMLNode;

    // Xml 定时保存
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
    // 创建 根目录
  if MyXmlDoc.DocumentElement = nil then
    MyXmlDoc.DocumentElement := MyXmlDoc.CreateNode( Xml_BackupCow );
  RootNode := MyXmlDoc.DocumentElement;

    // 备份信息的 xml 节点
  MyBackupInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyBackupInfo );
  BackupPathHashXml := MyXmlUtil.AddChild( MyBackupInfoXml, Xml_BackupPathHash );

    // 备份文件 删除信息  xml 节点
  MyBackupRemoveNotifyInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyBackupRemoveNotifyInfo );
  RemoveBackupNotifyHashXml := MyXmlUtil.AddChild( MyBackupRemoveNotifyInfoXml, Xml_RemoveBackupNotifyHash );

    // 云信息的 xml 节点
  MyCloudPathInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyCloudPathInfo );
  CloudPathHashXml := MyXmlUtil.AddChild( MyCloudPathInfoXml, Xml_CloudPathHash );

    // 云文件 删除信息  xml 节点
  MyCloudRemoveNotifyInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyCloudRemoveNotifyInfo );
  RemoveCloudNotifyHashXml := MyXmlUtil.AddChild( MyCloudRemoveNotifyInfoXml, Xml_RemoveCloudNotifyHash );

    // 网络计算机信息的 Xml 节点
  MyNetPcInfoXml := MyXmlUtil.AddChild( RootNode, Xml_MyNetPcInfo );
  NetPcHashXml := MyXmlUtil.AddChild( MyNetPcInfoXml, Xml_NetPcHash );

    // 批注册 Xml 节点
  MyBatRegisterXml := MyXmlUtil.AddChild( RootNode, Xml_MyBatRegisterInfo );
  PcBatRegisterHashXml := MyXmlUtil.AddChild( MyBatRegisterXml, Xml_PcBatRegisterHash );

    // 搜索下载 Xml 节点
  MySearchDownXml := MyXmlUtil.AddChild( RootNode, Xml_MySearchDownInfo );
  SearchDownFileHashXml := MyXmlUtil.AddChild( MySearchDownXml, Xml_SearchDownFileHash );

    // 恢复文件 Xml 节点
  MyRestoreFileXml := MyXmlUtil.AddChild( RootNode, Xml_MyRestoreFileInfo );
  RestoreItemHashXml := MyXmlUtil.AddChild( MyRestoreFileXml, Xml_RestoreItemHash );

    // 本机备份 源信息 Xml 节点
  MyLocalBackupSourceXml := MyXmlUtil.AddChild( RootNode, Xml_MyLocalBackupSourceInfo );
  LocalBackupSourceListXml := MyXmlUtil.AddChild( MyLocalBackupSourceXml, Xml_LocalBackupSourceList );

    // 本机备份 目标信息 Xml 节点
  MyDestinationXml := MyXmlUtil.AddChild( RootNode, Xml_MyDestinationInfo );
  DestinationListXml := MyXmlUtil.AddChild( MyDestinationXml, Xml_DestinationList );

    // 接收文件 Xml 节点
  MyFileReceiveXml := MyXmlUtil.AddChild( RootNode, Xml_MyFileReceiveInfo );
  FileReceiveListXml := MyXmlUtil.AddChild( MyFileReceiveXml, Xml_FileReceiveList );
  FileReceiveCancelListXml := MyXmlUtil.AddChild( MyFileReceiveXml, Xml_FileReceiveCancelList );

    // 发送文件 Xml 节点
  MyFileSendXml := MyXmlUtil.AddChild( RootNode, Xml_MyFileSendInfo );
  FileSendListXml := MyXmlUtil.AddChild( MyFileSendXml, Xml_FileSendList );
  FileSendCancelListXml := MyXmlUtil.AddChild( MyFileSendXml, Xml_FileSendCancelList );

    // 共享文件 Xml 节点
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
    // 找不到则创建
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

      // 10 分钟 保存一次
    IsSaveNow := False;
    StartTime := Now;
    while not Terminated and ( MinutesBetween( Now, StartTime ) < 10 )
          and not IsSaveNow
    do
      Sleep(100);

      // 保存 Xml 文件
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
