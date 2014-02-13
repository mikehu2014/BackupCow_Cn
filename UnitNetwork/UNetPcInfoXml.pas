unit UNetPcInfoXml;

interface

uses UChangeInfo, UXmlUtil, xmldom, XMLIntf, msxmldom, XMLDoc, SysUtils;

type

{$Region ' 写 网络Pc Xml ' }

    // 添加 Pc 然后修改
  TNetPcWriteXml = class( TChangeInfo )
  public
    PcID : string;
  protected
    NetPcNode : IXMLNode;
  public
    constructor Create( _PcID : string );
  protected
    function FindNetPcNode : Boolean;
  end;

      // 增加 Pc
  TNetPcAddXml = class( TNetPcWriteXml )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

      // 修改 Socket
  TNetPcSocketXml = class( TNetPcWriteXml )
  private
    Ip, Port : string;
  public
    procedure SetSocket( _Ip, _Port : string );
    procedure Update;override;
  end;

      // 修改 Reach
  TNetPcReachXml = class( TNetPcWriteXml )
  private
    IsReach : Boolean;
  public
    procedure SetIsReach( _IsReach : Boolean );
    procedure Update;override;
  end;

    // 修改 BeReach
  TNetPcBeReachXml = class( TNetPcWriteXml )
  private
    IsBeReach : Boolean;
  public
    procedure SetIsBeReach( _IsBeReach : Boolean );
    procedure Update;override;
  end;

    // 上线时间
  TNetPcOnlineTimeXml = class( TNetPcWriteXml )
  public
    LastOnlineTime : TDateTime;
  public
    procedure SetLastOnlineTime( _LastOnlineTime : TDateTime );
    procedure Update;override;
  end;

    // 是否备份到Pc
  TNetPcIsBackupDesXml = class( TNetPcWriteXml )
  public
    IsBackup : Boolean;
  public
    procedure SetIsBackup( _IsBackup : Boolean );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 写 网络Pc 云信息 Xml ' }


    // 修改 云空间信息
  TNetPcCloudSpaceXml = class( TNetPcWriteXml )
  public
    UsedSpace, TotalSpace : Int64;
    BackupSpace : Int64;
  public
    procedure SetSpace( _UsedSpace, _TotalSpace : Int64 );
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;override;
  end;

      // 修改 云配置信息
  TNetPcCloudConfigXml = class( TNetPcWriteXml )
  public
    IsFileVisible : Boolean;
    IvPasswordMD5 : string;
  private
    RegisterHardCode : string;
    RegisterEdition : string;
    CopyCount : Integer;
  public
    procedure SetFileInvisible( _IsFileVisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
    procedure SetRegisterEdition( _RegisterEdition, _RegisterHardCode : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
  end;

    // 修改 输入的  FileInvisible Password
  TNetPcCloudInputIvPasswordXml = class( TNetPcWriteXml )
  public
    InputIvPasswordMD5 : string;
  public
    procedure SetInputIvPasswordMD5( _InputIvPasswordMD5 : string );
    procedure Update;override;
  end;

    // 网络 Pc 云路径 改变
  TNetPcBackupPathChangeXml = class( TNetPcWriteXml )
  protected
    NetPcBackupPathHashNode : IXMLNode;
  protected
    function FindNetPcBackupPathHashNode : Boolean;
  end;

    // 网络 Pc 云路径 添加
  TNetPcBackupPathAddXml = class( TNetPcBackupPathChangeXml )
  public
    FullPath, PathType : string;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
    FolderSpace : Int64;
    FileCount, CopyCount : Integer;
  public
    procedure SetPathInfo( _FullPath, _PathType : string );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure SetSpace( _FolderSpace : Int64 );
    procedure SetCountInfo( _FileCount, _CopyCount : Integer );
    procedure Update;override;
  end;

    // 网络 Pc 云路径 清空
  TNetPcBackupPathClearXml = class( TNetPcBackupPathChangeXml )
  public
    procedure Update;override;
  end;

    // 添加 Pc 云备份路径 拥有者
  TNetPcBackupPathCopyOwnerAddXml = class( TNetPcBackupPathChangeXml )
  public
    FullPath, CopyOwner : string;
    OwnerSpace : Int64;
  public
    procedure SetPathInfo( _FullPath, _CopyOwner : string );
    procedure SetOwnerSpace( _OwnerSpace : Int64 );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 读 网络Pc Xml ' }

    // 读取 Pc 节点信息
  TNetPcNodeReadHandle = class
  public
    PcNode : IXMLNode;
  private
    PcID, PcName : string;
    PcHardCode : string;
    Ip, Port : string;
    IsReach, IsBeReach : Boolean;
    IsBackup : Boolean;
  private
    LastOnlineTime : TDateTime;
    UsedSpace, TotalSpace, BackupSpace : Int64;
  private
    IsFileInvisible : Boolean;
    IvPasswordMD5, InputIvPasswordMD5 : string;
    RegisterHardCode, RegisterEdition : string;
    CopyCount : Integer;
  public
    constructor Create( _PcNode : IXMLNode );
    procedure Update;
  private
    procedure FindPcInfo;
    procedure AddNetworkPc;
    procedure SetPcSocket;
    procedure SetLastOnlineTime;
    procedure SetPcSpace;
    procedure SetPcConfig;
    procedure SetPcIsBackupDes;
    procedure SetReachableFace;
  private
    procedure ReadPcBackupPath;
  end;

    // Pc 备份路径信息 读取
  TNetPcBackupPathReadHandle = class
  public
    BackupPathNode : IXMLNode;
  public
    PcID, FullPath : string;
  public
    constructor Create( _BackupPathNode : IXMLNode );
    procedure SetPcID( _PcID : string );
    procedure Update;
  private
    procedure ReadBackupPathCopyOwner;
  end;

    // Pc 备份路径拥有者信息 读取
  TNetPcBackupPathCopyOwnerReadHandle = class
  public
    CopyOwnerNode : IXMLNode;
  public
    PcID, FullPath : string;
  public
    constructor Create( _CopyOwnerNode : IXMLNode );
    procedure SetPathInfo( _PcID, _FullPath : string );
    procedure Update;
  end;

  TNetPcXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

const
    // Net Pc Info
  Xml_PcID = 'pi';
  Xml_PcName = 'pn';
  Xml_Ip = 'ip';
  Xml_Port = 'pt';
  Xml_Reach = 'rh';
  Xml_BeReach = 'brh';
  Xml_HasMyBackupFile = 'hbf';
  Xml_LastOnlineTime = 'lot';
  Xml_IsBackup = 'ib';
  Xml_BackupPriority = 'bp';
  Xml_UsedSpace = 'us';
  Xml_TotalSpace = 'ts';
  Xml_BackupSpace = 'bs';
  Xml_IsFileVisible = 'ifv';
  Xml_IvPasswordMD5 = 'ipwm';
  Xml_InputIvPasswordMD5 = 'iipm';
  Xml_RegisterHardCode = 'rhc';
  Xml_RegisterEdition = 'rd';
  Xml_CopyCount = 'cc';
  Xml_NetPcBackupPathList = 'npbpl';

    // Net Pc Backup Path
  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';
  Xml_IsEncrypt = 'ie';
  Xml_PasswordMD5 = 'pwm';
  Xml_PasswordHint = 'pwh';
  Xml_FolderSpace = 'fs';
  Xml_FileCount = 'fc';
  Xml_PathCopyCount = 'pcc';
  Xml_CopyOwnerList = 'col';

    // CopyOwnerList
  Xml_CopyOwner = 'co';
  Xml_OwnerSpace = 'os';

var
  MyNetPcXmlWrite : TMyChildXmlChange;

implementation

uses UMyNetPcInfo, UNetworkFace, URestoreFileFace, UNetworkControl;

{ TNetPcReachInfo }

procedure TNetPcReachXml.SetIsReach(_IsReach: Boolean);
begin
  IsReach := _IsReach;
end;

procedure TNetPcReachXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_Reach, BoolToStr( IsReach ) );
end;

{ TNetPcBeReachInfo }

procedure TNetPcBeReachXml.SetIsBeReach(_IsBeReach: Boolean);
begin
  IsBeReach := _IsBeReach;
end;

procedure TNetPcBeReachXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_BeReach, BoolToStr( IsBeReach ) );
end;

{ TNetPcSocketXml }

procedure TNetPcSocketXml.SetSocket(_Ip, _Port: string);
begin
  Ip := _Ip;
  Port := _Port;
end;

procedure TNetPcSocketXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_Ip, Ip );
  MyXmlUtil.AddChild( NetPcNode, Xml_Port, Port );
end;

{ TNetPcAddXml }

procedure TNetPcAddXml.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TNetPcAddXml.Update;
begin
      // 已存在
  if FindNetPcNode then
  begin
    MyXmlUtil.AddChild( NetPcNode, Xml_PcName, PcName );
    Exit;
  end;

    // 添加
  NetPcNode := MyXmlUtil.AddListChild( NetPcHashXml, PcID );
  MyXmlUtil.AddChild( NetPcNode, Xml_PcID, PcID );
  MyXmlUtil.AddChild( NetPcNode, Xml_PcName, PcName );
end;

{ TNetPcWriteXml }

constructor TNetPcWriteXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TNetPcWriteXml.FindNetPcNode: Boolean;
begin
  NetPcNode := MyXmlUtil.FindListChild( NetPcHashXml, PcID );
  Result := NetPcNode <> nil;
end;

{ TNetPcXmlRead }

procedure TNetPcXmlRead.Update;
var
  i : Integer;
  PcXmlNode : IXMLNode;
  NetPcNodeReadHandle : TNetPcNodeReadHandle;
begin
  for i := 0 to NetPcHashXml.ChildNodes.Count - 1 do
  begin
    PcXmlNode := NetPcHashXml.ChildNodes[i];
    NetPcNodeReadHandle := TNetPcNodeReadHandle.Create( PcXmlNode );
    NetPcNodeReadHandle.Update;
    NetPcNodeReadHandle.Free;
  end;
end;


{ TNetPcHeartBeatXml }

procedure TNetPcCloudSpaceXml.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TNetPcCloudSpaceXml.SetSpace(_UsedSpace, _TotalSpace: Int64);
begin
  UsedSpace := _UsedSpace;
  TotalSpace := _TotalSpace;
end;

procedure TNetPcCloudSpaceXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_UsedSpace, IntToStr( UsedSpace ) );
  MyXmlUtil.AddChild( NetPcNode, Xml_TotalSpace, IntToStr( TotalSpace ) );
  MyXmlUtil.AddChild( NetPcNode, Xml_BackupSpace, IntToStr( BackupSpace ) );
end;

{ TNetPcFirstHeartBeatXml }

procedure TNetPcCloudConfigXml.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TNetPcCloudConfigXml.SetFileInvisible(_IsFileVisible: Boolean);
begin
  IsFileVisible := _IsFileVisible;
end;

procedure TNetPcCloudConfigXml.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TNetPcCloudConfigXml.SetRegisterEdition(_RegisterEdition,
  _RegisterHardCode: string);
begin
  RegisterEdition := _RegisterEdition;
  RegisterHardCode := _RegisterHardCode;
end;

procedure TNetPcCloudConfigXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_IsFileVisible, BoolToStr( IsFileVisible ) );
  MyXmlUtil.AddChild( NetPcNode, Xml_IvPasswordMD5, IvPasswordMD5 );
  MyXmlUtil.AddChild( NetPcNode, Xml_RegisterHardCode, RegisterHardCode );
  MyXmlUtil.AddChild( NetPcNode, Xml_RegisterEdition, RegisterEdition );
  MyXmlUtil.AddChild( NetPcNode, Xml_CopyCount, IntToStr( CopyCount ) );
end;

{ TNetPcOnlineTimeXml }

procedure TNetPcOnlineTimeXml.SetLastOnlineTime(_LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

procedure TNetPcOnlineTimeXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_LastOnlineTime, FloatToStr( LastOnlineTime ) );
end;

{ TNetPcBackupPathChangeXml }

function TNetPcBackupPathChangeXml.FindNetPcBackupPathHashNode: Boolean;
begin
    // 不存在
  Result := FindNetPcNode;
  if Result then
    NetPcBackupPathHashNode := MyXmlUtil.AddChild( NetPcNode, Xml_NetPcBackupPathList );
end;

{ TNetPcBackupPathAddXml }

procedure TNetPcBackupPathAddXml.SetCountInfo(_FileCount, _CopyCount: Integer);
begin
  FileCount := _FileCount;
  CopyCount := _CopyCount;
end;

procedure TNetPcBackupPathAddXml.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TNetPcBackupPathAddXml.SetPathInfo(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TNetPcBackupPathAddXml.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TNetPcBackupPathAddXml.Update;
var
  NetPcBackupPathNode : IXMLNode;
begin
    // 不存在
  if not FindNetPcBackupPathHashNode then
    Exit;

  NetPcBackupPathNode := MyXmlUtil.AddListChild( NetPcBackupPathHashNode, FullPath );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_PathType, PathType );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_IsEncrypt, BoolToStr( IsEncrypt ) );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_PasswordMD5, PasswordMD5 );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_PasswordHint, PasswordHint );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_FolderSpace, IntToStr( FolderSpace ) );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_FileCount, IntToStr( FileCount ) );
  MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_PathCopyCount, IntToStr( CopyCount ) );
end;

{ TNetPcBackupPathClearXml }

procedure TNetPcBackupPathClearXml.Update;
begin
    // 不存在
  if not FindNetPcBackupPathHashNode then
    Exit;

  NetPcBackupPathHashNode.ChildNodes.Clear;
end;

{ TNetPcBackupPathCopyOwnerAddXml }

procedure TNetPcBackupPathCopyOwnerAddXml.SetOwnerSpace(_OwnerSpace: Int64);
begin
  OwnerSpace := _OwnerSpace;
end;

procedure TNetPcBackupPathCopyOwnerAddXml.SetPathInfo(_FullPath,
  _CopyOwner: string);
begin
  FullPath := _FullPath;
  CopyOwner := _CopyOwner;
end;

procedure TNetPcBackupPathCopyOwnerAddXml.Update;
var
  NetPcBackupPathNode : IXMLNode;
  CopyOwnerListNode : IXMLNode;
  CopyOwnerNode : IXMLNode;
begin
    // 不存在
  if not FindNetPcBackupPathHashNode then
    Exit;

  NetPcBackupPathNode := MyXmlUtil.AddListChild( NetPcBackupPathHashNode, FullPath );
  CopyOwnerListNode := MyXmlUtil.AddChild( NetPcBackupPathNode, Xml_CopyOwnerList );
  CopyOwnerNode := MyXmlUtil.AddListChild( CopyOwnerListNode, CopyOwner );
  MyXmlUtil.AddChild( CopyOwnerNode, Xml_CopyOwner, CopyOwner );
  MyXmlUtil.AddChild( CopyOwnerNode, Xml_OwnerSpace, IntToStr( OwnerSpace ) );
end;

{ TNetPcCloudInputIvPasswordXml }

procedure TNetPcCloudInputIvPasswordXml.SetInputIvPasswordMD5(
  _InputIvPasswordMD5: string);
begin
  InputIvPasswordMD5 := _InputIvPasswordMD5;
end;

procedure TNetPcCloudInputIvPasswordXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_InputIvPasswordMD5, InputIvPasswordMD5 );
end;

{ TNetPcIsBackupDesXml }

procedure TNetPcIsBackupDesXml.SetIsBackup(_IsBackup: Boolean);
begin
  IsBackup := _IsBackup;
end;

procedure TNetPcIsBackupDesXml.Update;
begin
    // 不存在
  if not FindNetPcNode then
    Exit;

  MyXmlUtil.AddChild( NetPcNode, Xml_IsBackup, BoolToStr( IsBackup ) );
end;

{ TNetPcNodeReadHandle }

procedure TNetPcNodeReadHandle.AddNetworkPc;
var
  NetPcReadHandle : TNetPcReadHandle;
begin
  NetPcReadHandle := TNetPcReadHandle.Create( PcID );
  NetPcReadHandle.SetPcName( PcName );
  NetPcReadHandle.Update;
  NetPcReadHandle.Free;
end;

constructor TNetPcNodeReadHandle.Create(_PcNode: IXMLNode);
begin
  PcNode := _PcNode;
end;

procedure TNetPcNodeReadHandle.FindPcInfo;
var
  IsBackupStr : string;
  BackupPriority : string;
begin
    // Part I
  PcID := MyXmlUtil.GetChildValue( PcNode, Xml_PcID );
  PcName := MyXmlUtil.GetChildValue( PcNode, Xml_PcName );
  Ip := MyXmlUtil.GetChildValue( PcNode, Xml_Ip );
  Port := MyXmlUtil.GetChildValue( PcNode, Xml_Port );
  IsReach := StrToBoolDef( MyXmlUtil.GetChildValue( PcNode, Xml_Reach ), False );
  IsBeReach := StrToBoolDef( MyXmlUtil.GetChildValue( PcNode, Xml_BeReach ), False );
  IsBackupStr := MyXmlUtil.GetChildValue( PcNode, Xml_IsBackup );
  if IsBackupStr = '' then
  begin
    BackupPriority := MyXmlUtil.GetChildValue( PcNode, Xml_BackupPriority );
    IsBackup := BackupPriority <> BackupPriority_Never;
  end
  else
    IsBackup := StrToBoolDef( IsBackupStr, True );

    // Part II
  LastOnlineTime := StrToFloatDef( MyXmlUtil.GetChildValue( PcNode, Xml_LastOnlineTime ), Now );
  UsedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( PcNode, Xml_UsedSpace ), 0 );
  TotalSpace := StrToInt64Def( MyXmlUtil.GetChildValue( PcNode, Xml_TotalSpace ), 0 );
  BackupSpace := StrToInt64Def( MyXmlUtil.GetChildValue( PcNode, Xml_BackupSpace ), 0 );

    // Part III
  IsFileInvisible := StrToBoolDef( MyXmlUtil.GetChildValue( PcNode, Xml_IsFileVisible ), False );
  IvPasswordMD5 := MyXmlUtil.GetChildValue( PcNode, Xml_IvPasswordMD5 );
  InputIvPasswordMD5 := MyXmlUtil.GetChildValue( PcNode, Xml_InputIvPasswordMD5 );
  RegisterEdition := MyXmlUtil.GetChildValue( PcNode, Xml_RegisterEdition );
  RegisterHardCode := MyXmlUtil.GetChildValue( PcNode, Xml_RegisterHardCode );
  CopyCount := StrToIntDef( MyXmlUtil.GetChildValue( PcNode, Xml_CopyCount ), 0 );
end;

procedure TNetPcNodeReadHandle.ReadPcBackupPath;
var
  BackupPathListNode : IXMLNode;
  i : Integer;
  BackupPathNode : IXMLNode;
  NetPcBackupPathReadHandle : TNetPcBackupPathReadHandle;
  VstRestorePcSetItemCount : TVstRestorePcSetItemCount;
begin
  BackupPathListNode := MyXmlUtil.AddChild( PcNode, Xml_NetPcBackupPathList );
  for i := 0 to BackupPathListNode.ChildNodes.Count - 1 do
  begin
    BackupPathNode := BackupPathListNode.ChildNodes[i];
    NetPcBackupPathReadHandle := TNetPcBackupPathReadHandle.Create( BackupPathNode );
    NetPcBackupPathReadHandle.SetPcID( PcID );
    NetPcBackupPathReadHandle.Update;
    NetPcBackupPathReadHandle.Free;
  end;

    // Restore Pc 信息
  VstRestorePcSetItemCount := TVstRestorePcSetItemCount.Create( PcID );
  VstRestorePcSetItemCount.SetRestoreItemCount( BackupPathListNode.ChildNodes.Count );
  MyRestoreFileFace.AddChange( VstRestorePcSetItemCount );
end;

procedure TNetPcNodeReadHandle.SetLastOnlineTime;
var
  NetPcLastOnlineTimeReadHandle : TNetPcLastOnlineTimeReadHandle;
begin
  NetPcLastOnlineTimeReadHandle := TNetPcLastOnlineTimeReadHandle.Create( PcID );
  NetPcLastOnlineTimeReadHandle.SetLastOnlineTime( LastOnlineTime );
  NetPcLastOnlineTimeReadHandle.Update;
  NetPcLastOnlineTimeReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.SetPcConfig;
var
  NetPcConfigReadHandle : TNetPcConfigReadHandle;
begin
  NetPcConfigReadHandle := TNetPcConfigReadHandle.Create( PcID );
  NetPcConfigReadHandle.SetFileInvisible( IsFileInvisible );
  NetPcConfigReadHandle.SetIvPasswordMD5( IvPasswordMD5 );
  NetPcConfigReadHandle.SetRegisterEdition( RegisterEdition, RegisterHardCode );
  NetPcConfigReadHandle.SetCopyCount( CopyCount );
  NetPcConfigReadHandle.Update;
  NetPcConfigReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.SetPcIsBackupDes;
var
  NetPcReadIsBackupDesHandle : TNetPcReadIsBackupDesHandle;
begin
  NetPcReadIsBackupDesHandle := TNetPcReadIsBackupDesHandle.Create( PcID );
  NetPcReadIsBackupDesHandle.SetIsBackupDes( IsBackup );
  NetPcReadIsBackupDesHandle.Update;
  NetPcReadIsBackupDesHandle.Free;
end;

procedure TNetPcNodeReadHandle.SetPcSocket;
var
  NetPcSocketReadHandle : TNetPcSocketReadHandle;
begin
  NetPcSocketReadHandle := TNetPcSocketReadHandle.Create( PcID );
  NetPcSocketReadHandle.SetSocket( Ip, Port );
  NetPcSocketReadHandle.Update;
  NetPcSocketReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.SetPcSpace;
var
  NetPcSpaceReadHandle : TNetPcSpaceReadHandle;
begin
  NetPcSpaceReadHandle := TNetPcSpaceReadHandle.Create( PcID );
  NetPcSpaceReadHandle.SetSpace( UsedSpace, TotalSpace );
  NetPcSpaceReadHandle.SetBackupSpace( BackupSpace );
  NetPcSpaceReadHandle.Update;
  NetPcSpaceReadHandle.Free;
end;

procedure TNetPcNodeReadHandle.SetReachableFace;
var
  ReachableStr : string;
  CloudStatusLvReachInfo : TVstCloudStatusReach;
begin
    // Reach able
  if Ip = '' then
    ReachableStr := ''
  else
    ReachableStr := NetworkListviewUtil.getReachable( IsReach, IsBeReach );
  CloudStatusLvReachInfo := TVstCloudStatusReach.Create( PcID );
  CloudStatusLvReachInfo.SetReachable( ReachableStr );
  MyNetworkFace.AddChange( CloudStatusLvReachInfo );
end;

procedure TNetPcNodeReadHandle.Update;
begin
    // 提取 Pc 信息
  FindPcInfo;

    // 设置 Pc 信息
  AddNetworkPc;
  SetPcSocket;
  SetLastOnlineTime;
  SetPcSpace;
  SetPcConfig;
  SetPcIsBackupDes;
  SetReachableFace;

    // 读取 Pc 的备份路径
  ReadPcBackupPath;
end;

{ TNetPcBackupPathReadHandle }

constructor TNetPcBackupPathReadHandle.Create(_BackupPathNode: IXMLNode);
begin
  BackupPathNode := _BackupPathNode;
end;

procedure TNetPcBackupPathReadHandle.ReadBackupPathCopyOwner;
var
  CopyOwnerListNode : IXMLNode;
  i : Integer;
  CopyOwnerNode : IXMLNode;
  NetPcBackupPathCopyOwnerReadHandle : TNetPcBackupPathCopyOwnerReadHandle;
begin
  CopyOwnerListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_CopyOwnerList );
  for i := 0 to CopyOwnerListNode.ChildNodes.Count - 1 do
  begin
    CopyOwnerNode := CopyOwnerListNode.ChildNodes[i];
    NetPcBackupPathCopyOwnerReadHandle := TNetPcBackupPathCopyOwnerReadHandle.Create( CopyOwnerNode );
    NetPcBackupPathCopyOwnerReadHandle.SetPathInfo( PcID, FullPath );
    NetPcBackupPathCopyOwnerReadHandle.Update;
    NetPcBackupPathCopyOwnerReadHandle.Free;
  end;
end;

procedure TNetPcBackupPathReadHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TNetPcBackupPathReadHandle.Update;
var
  PathType : string;
  IsEncrypt : Boolean;
  PasswordMD5, PasswordHint : string;
  FolderSpace : Int64;
  FileCount, CopyCount : Integer;
  NetPcReadBackupPathHandle : TNetPcReadBackupPathHandle;
begin
    // 提取 信息
  FullPath := MyXmlUtil.GetChildValue( BackupPathNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PathType );
  IsEncrypt := StrToBoolDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_IsEncrypt ), False );
  PasswordMD5 := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PasswordMD5 );
  PasswordHint := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PasswordHint );
  FolderSpace := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathNode, Xml_FolderSpace ), 0 );
  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_FileCount ), 0 );
  CopyCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_PathCopyCount ), 0 );

    // 处理 信息
  NetPcReadBackupPathHandle := TNetPcReadBackupPathHandle.Create( PcID );
  NetPcReadBackupPathHandle.SetPathInfo( FullPath, PathType );
  NetPcReadBackupPathHandle.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
  NetPcReadBackupPathHandle.SetSpace( FolderSpace );
  NetPcReadBackupPathHandle.SetCountInfo( FileCount, CopyCount );
  NetPcReadBackupPathHandle.Update;
  NetPcReadBackupPathHandle.Free;

    // 读取 备份路径的 拥有者
  ReadBackupPathCopyOwner;
end;

{ TNetPcBackupPathCopyOwnerReadHandle }

constructor TNetPcBackupPathCopyOwnerReadHandle.Create(
  _CopyOwnerNode: IXMLNode);
begin
  CopyOwnerNode := _CopyOwnerNode;
end;

procedure TNetPcBackupPathCopyOwnerReadHandle.SetPathInfo(_PcID,
  _FullPath: string);
begin
  PcID := _PcID;
  FullPath := _FullPath;
end;

procedure TNetPcBackupPathCopyOwnerReadHandle.Update;
var
  CopyOwner : string;
  OwnerSpace : Int64;
  NetPcBackupPathOwnerReadHandle : TNetPcBackupPathOwnerReadHandle;
begin
    // 提取 信息
  CopyOwner := MyXmlUtil.GetChildValue( CopyOwnerNode, Xml_CopyOwner );
  OwnerSpace := StrToInt64Def( MyXmlUtil.GetChildValue( CopyOwnerNode, Xml_OwnerSpace ), 0 );

    // 处理 信息
  NetPcBackupPathOwnerReadHandle := TNetPcBackupPathOwnerReadHandle.Create( PcID );
  NetPcBackupPathOwnerReadHandle.SetPathInfo( FullPath, CopyOwner );
  NetPcBackupPathOwnerReadHandle.SetOwnerSpace( OwnerSpace );
  NetPcBackupPathOwnerReadHandle.Update;
  NetPcBackupPathOwnerReadHandle.Free;
end;

end.

