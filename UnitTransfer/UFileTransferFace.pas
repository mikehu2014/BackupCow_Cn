unit UFileTransferFace;

interface

uses UChangeInfo, Classes, ComCtrls, UMyUtil, UFormUtil, Generics.Collections, VirtualTrees, UIconUtil,
     uDebug, SysUtils, UModelUtil, SyncObjs, DateUtils, Controls;

type

{$Region ' 选择 发送文件 窗口 ' }

    // 数据结构
  TVstSelectSendPcData = record
  public
    PcID, PcName : WideString;
    IsOnline : Boolean;
  end;
  PVstSelectSendPcData = ^TVstSelectSendPcData;

  VstSelectSendPcUtil = class
  public
    class procedure ResetVisiblePc( IsExist : Boolean );
  end;

      // 修改
  TVstSelectSendPcChange = class( TChangeInfo )
  public
    vstSelectSendPc : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // Server 离线
  TVstSelectSendPcServerOffline = class( TVstSelectSendPcChange )
  public
    procedure Update;override;
  private
    procedure PcOffline( PcID : string );
  end;

    // 修改 单Pc
  TVstSelectSendPcWrite = class( TVstSelectSendPcChange )
  public
    PcID : string;
  private
    PcNode : PVirtualNode;
    PcData : PVstSelectSendPcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
    procedure CreatePcNode;
  end;

    // 添加
  TVstSelectSendPcAdd = class( TVstSelectSendPcWrite )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // 上线
  TVstSelectSendPcOnline = class( TVstSelectSendPcWrite )
  public
    procedure Update;override;
  end;

    // 下线
  TVstSelectSendPcOffline = class( TVstSelectSendPcWrite )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' Vst 发送文件 ' }

    // 空间 数据
  TVstMyFileSendData = record
  public
    FilePath, SendPathType : WideString;
    FileSize, CompletedSize : Int64;
    Status : WideString;
  public
    DesID, DesName : WideString;
    DesIsOnline : Boolean;
  public
    IsIncompleted : Boolean;
  end;
  PVstMyFileSendData = ^TVstMyFileSendData;

    // 修改 父类
  TVstMyFileSendChangeInfo = class( TChangeInfo )
  public
    VstMyFileSend : TVirtualStringTree;
  public
    procedure Update;override;
  end;

  {$Region ' 根节点 修改 ' }

    // 修改  根节点 父类
  TVstMyFileSendWriteInfo = class( TVstMyFileSendChangeInfo )
  public
    FilePath, PcID : string;
  public
    RootNode : PVirtualNode;
    RootData : PVstMyFileSendData;
  public
    constructor Create( _FilePath, _PcID : string );
  protected
    function FindRootNode : boolean;
    procedure RefreshRootNode;
  end;

    // 添加 根节点
  TVstMyFileSendAddInfo = class( TVstMyFileSendWriteInfo )
  public
    PcName : string;
    PcIsOnline : Boolean;
    FileSize, CompletedSize : Int64;
    Status : string;
    SendPathType : string;
  public
    procedure SetPcName( _PcName : string );
    procedure SetPcIsOnline( _PcIsOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetSendPathType( _SendPathType : string );
    procedure Update;override;
  end;

    // 删除 根节点
  TVstMyFileSendRemoveInfo = class( TVstMyFileSendWriteInfo )
  public
    procedure Update;override;
  end;

      // 改变节点空间信息
  TVstMyFileSendSpaceInfo = class( TVstMyFileSendWriteInfo )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 根节点 完成空间
  TVstMyFileSendAddCompletedSize = class( TVstMyFileSendWriteInfo )
  public
    AddSize : Int64;
  public
    procedure SetAddSize( _AddSize : Int64 );
    procedure Update;override;
  end;

    // 改变节点 状态信息
  TVstMyFileSendStatusInfo = class( TVstMyFileSendWriteInfo )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

      // 清空 子节点
  TVstMyFileSendCancelChildInfo = class( TVstMyFileSendWriteInfo )
  public
    procedure Update;override;
  private
    procedure RemoveChildJob( ChildPath : string );
  end;

    // Pc 上线改变
  TVstMyFilePcOnlineInfo = class( TVstMyFileSendChangeInfo )
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // 所有 Pc 离线
  TVstMyFileAllPcOfflineInfo = class( TVstMyFileSendChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 子节点 修改 ' }

    // 修改 子节点 父类
  TVstMyFileSendChildChangeInfo = class( TVstMyFileSendWriteInfo )
  private
    ChildPath : string;
  private
    ChildNode : PVirtualNode;
    ChildData : PVstMyFileSendData;
  public
    procedure SetChildPath( _ChildPath : string );
  protected
    function FindChildNode : Boolean;
    procedure RefreshChildNode;
    function getIsRootFile : Boolean;
  end;

    // 添加 子节点
  TVstMyFileSendAddChildInfo = class( TVstMyFileSendChildChangeInfo )
  public
    PcName : string;
    PcIsOnline : Boolean;
    FileSize, CompletedSize : Int64;
    Status : string;
  public
    procedure SetPcName( _PcName : string );
    procedure SetPcIsOnline( _PcIsOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

    // 删除 子节点
  TVstMyFileSendRemoveChildInfo = class( TVstMyFileSendChildChangeInfo )
  public
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

    // 改变 子节点状态
  TVstMyFileSendChildStatusInfo = class( TVstMyFileSendChildChangeInfo )
  public
    SendStatus : string;
  public
    procedure SetSendStatus( _SendStatus : string );
    procedure Update;override;
  end;

    // 添加 子节点 已完成空间信息
  TVstMyFileSendChildAddCompletedInfo = class( TVstMyFileSendChildChangeInfo )
  public
    CompletedSize : Integer;
  public
    procedure SetCompletedSize( _CompletedSize : Integer );
    procedure Update;override;
  end;


  {$EndRegion}

  MyFileTransferFaceUtil = class
  public
    class function getReceiveStatusIcon( Status : string ): Integer;
  public
    class function getSendNodeStatus( Node : PVirtualNode ): string;
    class function getSendNodeStatusIcon( Node : PVirtualNode ): Integer;
    class function getIsFreeLimit( Node : PVirtualNode ): Boolean;
  end;

{$EndRegion}

{$Region ' Lv 接收文件 ' }

  LvFileReceiveUtil = class
  public
    class function ReadReceiveStatus( IsOnline : Boolean; Status : string ): string;
    class function ReadReceiveStatusIcon( IsOnline : Boolean; Status : string ): Integer;
  end;

    // 界面 数据结构
  TLvFileReceiveData = class
  public
    SourceFilePath, SourcePcID : string;
    ReceivePath, ReceiveStatus : string;
    SourcePcIsOnline : Boolean;
    FileSize, CompletedSize : Int64;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
    procedure SetReceivePath( _ReceivePath : string );
    procedure SetSourcePcIsOnline( _SourcePcIsOnline : Boolean );
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
  end;

    // 修改 父类
  TLvFileReceiveChangeInfo = class( TChangeInfo )
  public
    LvMyFileReceive : TListView;
  public
    procedure Update;override;
  end;

    // 修改 单项 父类
  TLvFileReceiveWriteInfo = class( TLvFileReceiveChangeInfo )
  public
    SourceFilePath, SourcePcID : string;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
  protected
    function FindExistIndex : Integer;
    function FindExistItem : TListItem;
  end;

    // 添加
  TLvFileReceiveAddInfo = class( TLvFileReceiveWriteInfo )
  public
    SourcePcName : string;
    FileSize, CompletedSize : Int64;
    ReceivePath, SendPathType : string;
    ReceiveStatus : string;
    SourcePcIsOnline : Boolean;
  public
    procedure SetSourcePcName( _SourcePcName : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetReceivePath( _ReceivePath : string );
    procedure SetSendPathType( _SendPathType : string );
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure SetSourcePcIsOnline( _SourcePcIsOnline : Boolean );
    procedure Update;override;
  end;

    // 删除
  TLvFileReceiveRemoveInfo = class( TLvFileReceiveWriteInfo )
  public
    procedure Update;override;
  end;

    // 设置 空间信息
  TLvFileReceiveSetSpaceInfo = class( TLvFileReceiveWriteInfo )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // 添加 已完成信息
  TLvFileReceiveAddCompletedSpace = class( TLvFileReceiveWriteInfo )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

    // 设置 接收状态信息
  TLvFileReceiveSetStatusInfo = class( TLvFileReceiveWriteInfo )
  private
    ReceiveStatus : string;
  public
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;override;
  end;

    // 设置 Pc 上线状态
  TLvFileReceiveSetSourceOnlineInfo = class( TLvFileReceiveChangeInfo )
  private
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // 所有 Pc 离线
  TLvFileReceiveSetAllPcOfflineInfo = class( TLvFileReceiveChangeInfo )
  public
    procedure Update;override;
  end;

    // 开始接收
  TLvFileReceiveStartInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Vst 发送Pc列表 ' }

  TVstFileTransferDesData = record
  public
    PcID, PcName : WideString;
    IsOnline : Boolean;
    StartChangeTime : TDateTime;
  public
    IsShowUpload, IsShowDownload : Boolean;
    UploadCount, DownloadCount : Integer;
  end;
  PVstFileTransferDesData = ^TVstFileTransferDesData;

    // 修改
  TVstFileTransferDesChange = class( TChangeInfo )
  public
    vstFileTransferDes : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshVisiblePc( IsExist : Boolean );
  end;

    // Server 离线
  TVstFileTransferDesServerOffline = class( TVstFileTransferDesChange )
  public
    procedure Update;override;
  private
    procedure PcOffline( PcID : string );
  end;

    // 修改 单Pc
  TVstFileTransferDesWrite = class( TVstFileTransferDesChange )
  public
    PcID : string;
  private
    PcNode : PVirtualNode;
    PcData : PVstFileTransferDesData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
    procedure CreatePcNode;
  end;

    // 添加
  TVstFileTransferDesAdd = class( TVstFileTransferDesWrite )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // 上线
  TVstFileTransferDesOnline = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // 下线
  TVstFileTransferDesOffline = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

  {$Region ' 上传/下载 显示 ' }

    // Pc 添加下载
  TVstFileTransferDesAddDownload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // Pc 删除下载
  TVstFileTransferDesRemoveDownload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // Pc 添加上传
  TVstFileTransferDesAddUpload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // Pc 删除上传
  TVstFileTransferDesRemoveUpload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // 隐藏 Pc 下载
  TVstFileTransferDesHidePcDownload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

    // 隐藏 Pc 上传
  TVstFileTransferDesHidePcUpload = class( TVstFileTransferDesWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 接收前选择接收路径 ' }

  TFrmSelectReceivePath = class( TChangeInfo )
  public
    SendFilePath, PathType : string;
    FileFromPcID, FileFromPcName : string;
    FileSize : Int64;
    FileCount : Integer;
  public
    constructor Create( _FilePath, _PathType : string );
    procedure SetFileFrom( _FileFromPcID, _FileFromPcName : string );
    procedure SetSpace( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  private
    procedure FreedBackupCancel;
  end;

{$EndRegion}

{$Region ' Vst FileSend Des 隐藏线程 ' }

  TVstFileSendDesHideInfo = class
  public
    PcID : string;
    StartTime : TDateTime;
  public
    constructor Create( _PcID : string );
  end;
  TVstFileSendDesHidePair = TPair< string , TVstFileSendDesHideInfo >;
  TVstFileSendDesHideHash = class(TStringDictionary< TVstFileSendDesHideInfo >);

    // 列隐藏线程
  TVstFileSendDesHideThread = class( TThread )
  private
    Lock : TCriticalSection;
    VstFileSendDesDownHideHash : TVstFileSendDesHideHash;
    VstFileSendDesUpHideHash : TVstFileSendDesHideHash;
  public
    constructor Create;
    procedure AddDownHideInfo( PcID : string );
    procedure AddUpHideInfo( PcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ExistHidePc : Boolean;
    procedure CheckLvHideDown;
    procedure CheckLvHideUp;
  end;

{$EndRegion}

const
  LvMyFileReceive_FileSize = 0;
  LvMyFileReceive_SourcePcID = 1;
  LvMyFileReceive_Percentage = 2;
  LvMyFileReceive_Status = 3;

  LvFileReceive_Caption = 'My File Receiver';

const
    // 发送状态
  SendStatusShow_Waiting = 'Waiting';
  SendStatusShow_Sending = 'Sending';
  SendStatusShow_Completed = 'Completed';
  SendStatusShow_Cancel = 'Cancel';
  SendStatusShow_Offline = 'Offline';
  SendStatusShow_Disable = 'Disable';
  SendStatusShow_Scanning = 'Scanning';
  SendStatusShow_Incompleted = 'Incompleted';

var
  VstFileSendDesHideThread : TVstFileSendDesHideThread;
  VstFileSendDes_IsOnlyOnline : Boolean = True;
  LvFileReceive_NewCount : Integer = 0;
  LvFileReceive_IsStart : Boolean = False;

implementation

uses UFormSelectTransfer, UNetworkFace, UMainForm, UMyFileTransferControl, URegisterInfo,
     UMyClient, UMyNetPcInfo, UFormSelectReceiveFile, UFormFreeEdition;

{ TVstMyFileSendChangeInfo }

procedure TVstMyFileSendChangeInfo.Update;
begin
  VstMyFileSend := frmMainForm.vstMyFileSend;
end;

{ TVstMyFileSendWriteInfo }

constructor TVstMyFileSendWriteInfo.Create(_FilePath, _PcID: string);
begin
  FilePath := _FilePath;
  PcID := _PcID;
end;

function TVstMyFileSendWriteInfo.FindRootNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  Result := False;

  SelectNode := VstMyFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstMyFileSend.GetNodeData( SelectNode );
      // 找到目标节点
    if ( SelectData.DesID = PcID ) and
       ( SelectData.FilePath = FilePath )
    then
    begin
      RootNode := SelectNode;
      RootData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstMyFileSendWriteInfo.RefreshRootNode;
begin
  VstMyFileSend.RepaintNode( RootNode );
end;

{ TVstMyFileSendStatusInfo }

procedure TVstMyFileSendChildStatusInfo.SetSendStatus(_SendStatus: string);
begin
  SendStatus := _SendStatus;
end;

procedure TVstMyFileSendChildStatusInfo.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  ChildData.Status := SendStatus;

  RefreshChildNode;
end;

{ TVstMyFileSendStatusInfo }

procedure TVstMyFileSendStatusInfo.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstMyFileSendStatusInfo.Update;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

  RootData.Status := Status;

    // 刷新节点
  RefreshRootNode;
end;

{ TVstMyFileSendAddInfo }


procedure TVstMyFileSendAddInfo.SetFileSpaceInfo(_FileSize,
  _CompletedSize : Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstMyFileSendAddInfo.SetPcIsOnline(_PcIsOnline: Boolean);
begin
  PcIsOnline := _PcIsOnline;
end;

procedure TVstMyFileSendAddInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstMyFileSendAddInfo.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TVstMyFileSendAddInfo.SetStatus(_Status: string);
begin
  Status := _Status;
end;


procedure TVstMyFileSendAddInfo.Update;
begin
  inherited;

    // 已存在
  if FindRootNode then
    Exit;

    // 不存在 则添加
  RootNode := VstMyFileSend.AddChild( VstMyFileSend.RootNode );
  RootData := VstMyFileSend.GetNodeData( RootNode );
  RootData.FilePath := FilePath;
  RootData.DesID := PcID;
  RootData.DesName := PcName;
  RootData.DesIsOnline := PcIsOnline;
  RootData.Status := Status;
  RootData.FileSize := FileSize;
  RootData.CompletedSize := CompletedSize;
  RootData.SendPathType := SendPathType;
  RootData.IsIncompleted := False;

    // Enable Clear 按钮
  if VstMyFileSend.RootNode.ChildCount = 1 then
  begin
    frmMainForm.tbtnSendClear.Enabled := True;
      // disable 背景图案
    VstMyFileSend.TreeOptions.PaintOptions := VstMyFileSend.TreeOptions.PaintOptions - [toShowBackground];
  end;
end;

{ TVstMyFileSendAddChildInfo }

procedure TVstMyFileSendAddChildInfo.CheckFreeLimit;
begin
  if not App_IsFreeLimit then
    Exit;

    // 第一个节点，且 Disable
  if ( RootNode.ChildCount = 1 ) and EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    RootData.IsIncompleted := True;
    RefreshRootNode; // 刷新根节点
  end
  else
  if RootData.IsIncompleted and not EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    RootData.IsIncompleted := False;
    RefreshRootNode; // 刷新根节点
  end;
end;

procedure TVstMyFileSendAddChildInfo.SetFileSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstMyFileSendAddChildInfo.SetPcIsOnline(_PcIsOnline: Boolean);
begin
  PcIsOnline := _PcIsOnline;
end;

procedure TVstMyFileSendAddChildInfo.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstMyFileSendAddChildInfo.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstMyFileSendAddChildInfo.Update;
begin
  inherited;

    // 找不到 根
  if not FindRootNode then
    Exit;

    // 文件是根
  if getIsRootFile then
    Exit;

    // 添加 子节点
  ChildNode := VstMyFileSend.AddChild( RootNode );
  ChildData := VstMyFileSend.GetNodeData( ChildNode );
  ChildData.FilePath := ChildPath;
  ChildData.SendPathType := SendPathType_File;
  ChildData.DesID := PcID;
  ChildData.DesName := PcName;
  ChildData.DesIsOnline := PcIsOnline;
  ChildData.Status := Status;
  ChildData.FileSize := FileSize;
  ChildData.CompletedSize := CompletedSize;

    // 是否 受到试用版限制
  CheckFreeLimit;
end;

{ TVstMyFileSendRemoveInfo }

procedure TVstMyFileSendRemoveInfo.Update;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

  VstMyFileSend.DeleteNode( RootNode );

      // Disable Clear 按钮
  if VstMyFileSend.RootNode.ChildCount = 0 then
  begin
    frmMainForm.tbtnSendClear.Enabled := False;
          // Enable 背景图案
    VstMyFileSend.TreeOptions.PaintOptions := VstMyFileSend.TreeOptions.PaintOptions + [toShowBackground];
  end;
end;

{ TVstMyFileSendSpaceInfo }

procedure TVstMyFileSendSpaceInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TVstMyFileSendSpaceInfo.Update;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

  RootData.FileSize := FileSize;

    // 刷新节点
  RefreshRootNode;
end;

{ TLvFileReceiveData }

constructor TLvFileReceiveData.Create(_SourceFilePath, _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
  FileSize := 0;
  CompletedSize := 0;
end;

procedure TLvFileReceiveData.SetFileSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TLvFileReceiveData.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

procedure TLvFileReceiveData.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TLvFileReceiveData.SetSourcePcIsOnline(_SourcePcIsOnline: Boolean);
begin
  SourcePcIsOnline := _SourcePcIsOnline;
end;

{ TLvFileReceiveChangeInfo }

procedure TLvFileReceiveChangeInfo.Update;
begin
  LvMyFileReceive := frmMainForm.lvMyFileReceive;
end;

{ TLvFileReceiveWriteInfo }

constructor TLvFileReceiveWriteInfo.Create(_SourceFilePath,
  _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

function TLvFileReceiveWriteInfo.FindExistIndex: Integer;
var
  i : Integer;
  ItemData : TLvFileReceiveData;
begin
  Result := -1;

  for i := 0 to LvMyFileReceive.Items.Count - 1 do
  begin
    ItemData := LvMyFileReceive.Items[i].Data;
    if ( ItemData.SourceFilePath = SourceFilePath ) and
       ( ItemData.SourcePcID = SourcePcID )
    then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TLvFileReceiveWriteInfo.FindExistItem: TListItem;
var
  SelectIndex : Integer;
begin
  SelectIndex := FindExistIndex;
  if SelectIndex = -1 then
    Result := nil
  else
    Result := LvMyFileReceive.Items[ SelectIndex ];
end;

{ TLvFileReceiveAddInfo }

procedure TLvFileReceiveAddInfo.SetFileSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TLvFileReceiveAddInfo.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

procedure TLvFileReceiveAddInfo.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TLvFileReceiveAddInfo.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TLvFileReceiveAddInfo.SetSourcePcIsOnline(_SourcePcIsOnline: Boolean);
begin
  SourcePcIsOnline := _SourcePcIsOnline;
end;

procedure TLvFileReceiveAddInfo.SetSourcePcName(_SourcePcName: string);
begin
  SourcePcName := _SourcePcName;
end;

procedure TLvFileReceiveAddInfo.Update;
var
  ItemData : TLvFileReceiveData;
  MainIcon, StatusIcon : Integer;
  Status, CaptionStr : string;
  Percentage : Integer;
begin
  inherited;

    // 显示的百分比
  if ReceiveStatus = ReceivePathStatus_Completed then
    Percentage := 100
  else
  if FileSize = 0 then
    Percentage := 0
  else
    Percentage := MyPercentage.getPercent( CompletedSize, FileSize );

    // 状态信息
  if SendPathType = SendPathType_File then
    MainIcon := MyIcon.getIconByFileExt( SourceFilePath )
  else
    MainIcon := MyShellIconUtil.getFolderIcon;

  Status := LvFileReceiveUtil.ReadReceiveStatus( SourcePcIsOnline, ReceiveStatus );
  StatusIcon := LvFileReceiveUtil.ReadReceiveStatusIcon( SourcePcIsOnline, ReceiveStatus );

  ItemData := TLvFileReceiveData.Create( SourceFilePath, SourcePcID );
  ItemData.SetReceivePath( ReceivePath );
  ItemData.SetSourcePcIsOnline( SourcePcIsOnline );
  ItemData.SetReceiveStatus( ReceiveStatus );
  ItemData.SetFileSpaceInfo( FileSize, CompletedSize );

    // 创建并添加到界面
  with LvMyFileReceive.Items.Add do
  begin
    Caption := MyFileInfo.getFileName( SourceFilePath );
    SubItems.Add( MySize.getFileSizeStr( FileSize ) );
    SubItems.Add( SourcePcName );
    SubItems.Add( MyPercentage.getPercentageStr( Percentage ) );
    SubItems.Add( Status );
    ImageIndex := MainIcon;
    SubItemImages[ LvMyFileReceive_Status ] := StatusIcon;
    Data := ItemData;
  end;

    // Enable Clear
  if LvMyFileReceive.Items.Count = 1 then
    frmMainForm.tbtnReceiveClear.Enabled := True;

    // 新的接收
  if LvFileReceive_IsStart and
    ( frmMainForm.PcFileTransfer.ActivePage <> frmMainForm.tsFileReceive )
  then
  begin
    Inc( LvFileReceive_NewCount );
    CaptionStr := LvFileReceive_Caption + ' (' + IntToStr( LvFileReceive_NewCount ) + ')';
    frmMainForm.tsFileReceive.Caption := CaptionStr;
  end;
end;

{ TLvFileReceiveRemoveInfo }

procedure TLvFileReceiveRemoveInfo.Update;
var
  DeleteIndex : Integer;
begin
  inherited;

  DeleteIndex := FindExistIndex;
  if DeleteIndex = -1 then
    Exit;

  LvMyFileReceive.Items.Delete( DeleteIndex );

      // Disable Clear
  if LvMyFileReceive.Items.Count = 0 then
    frmMainForm.tbtnReceiveClear.Enabled := False;
end;


{ TLvFileReceiveSetSpaceInfo }

procedure TLvFileReceiveSetSpaceInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TLvFileReceiveSetSpaceInfo.Update;
var
  SelectItem : TListItem;
  SelectData : TLvFileReceiveData;
begin
  inherited;

  SelectItem := FindExistItem;
  if SelectItem = nil then
    Exit;

    // 设置数据
  SelectData := SelectItem.Data;
  SelectData.FileSize := FileSize;

    // 添加界面
  SelectItem.SubItems[ LvMyFileReceive_FileSize ] := MySize.getFileSizeStr( FileSize );
end;

{ TVstMyFileSendRemoveChildInfo }

procedure TVstMyFileSendRemoveChildInfo.CheckFreeLimit;
var
  IsExistDisableNode : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  if not App_IsFreeLimit then
    Exit;
  if RootData.IsIncompleted then
    Exit;

    // 是否 只存在 Disable 节点
  IsExistDisableNode := False;
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstMyFileSend.GetNodeData( SelectNode );
    if EditionUtil.getIsLimitFileSendSpace( SelectData.FileSize ) then
      IsExistDisableNode := True
    else
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // 不存在
  if not IsExistDisableNode then
    Exit;

    // 发送路径 受免费版影响
  RootData.IsIncompleted := True;
  RefreshRootNode; // 刷新根节点
  VstMyFileSend.Expanded[ RootNode ] := True;  // 展开节点

    // 显示 试用版限制
  frmFreeEdition.ShowWarnning( FreeEditionError_SendFileSize );
end;

procedure TVstMyFileSendRemoveChildInfo.Update;
begin
  inherited;

    // 找不到 子节点
  if not FindChildNode then
    Exit;

    // 文件节点是根节点
  if getIsRootFile then
  begin
    RootData.CompletedSize := RootData.FileSize;
    Exit;
  end;

    // 删除 子节点
  VstMyFileSend.DeleteNode( ChildNode );

      // 根目录 已完成
  if RootNode.ChildCount = 0 then
    VstMyFileSend.RepaintNode( RootNode );

    // 检测 是否受试用版限制
  CheckFreeLimit;
end;

{ MyFileTransferFaceUtil }

class function MyFileTransferFaceUtil.getSendNodeStatus(Node: PVirtualNode): string;
var
  vstMyFileSend : TVirtualStringTree;
  NodeData : PVstMyFileSendData;
begin
  vstMyFileSend := frmMainForm.vstMyFileSend;
  NodeData := vstMyFileSend.GetNodeData( Node );
  if App_IsFreeLimit and ( Node.Parent <> vstMyFileSend.RootNode ) and
     ( NodeData.FileSize > FreeEditionLimit_SendFileSize )
  then
    Result := SendPathStatus_Disable  // 试用版, 功能限制
  else
  if App_IsFreeLimit and ( Node.Parent = vstMyFileSend.RootNode ) and
     NodeData.IsIncompleted
  then
    Result := SendPathStatus_Incompleted
  else
  if ( NodeData.Status = SendPathStatus_Cancel ) or
     ( NodeData.Status = SendPathStatus_Completed )
  then
    Result := NodeData.Status   // 取消 或 已完成
  else
  if not NodeData.DesIsOnline then
    Result := SendPathStatus_Offline  // 离线
  else
    Result := NodeData.Status;   // 其他状态
end;

class function MyFileTransferFaceUtil.getSendNodeStatusIcon(
  Node: PVirtualNode): Integer;
var
  NodeStatus : string;
begin
  NodeStatus := getSendNodeStatus( Node );
  if NodeStatus = SendPathStatus_Incompleted then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if ( NodeStatus = SendPathStatus_Waiting ) or
     ( NodeStatus = SendPathStatus_Scanning )
  then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeStatus = SendPathStatus_Sending then
    Result := MyShellTransActionIconUtil.getUpLoading
  else
  if NodeStatus = SendPathStatus_Completed then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if NodeStatus = SendPathStatus_Disable then
    Result := MyShellTransActionIconUtil.getDisable
  else
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

class function MyFileTransferFaceUtil.getIsFreeLimit(
  Node: PVirtualNode): Boolean;
var
  NodeData : PVstMyFileSendData;
begin
  Result := False;
  if not App_IsFreeLimit then
    Exit;

  NodeData := frmMainForm.vstMyFileSend.GetNodeData( Node );
  if NodeData.SendPathType = SendPathType_File then
    Result := EditionUtil.getIsLimitFileSendSpace( NodeData.FileSize )
  else
  begin
    Result := NodeData.IsIncompleted;
    if Result then
      frmMainForm.vstMyFileSend.Expanded[ Node ] := True;
  end;
end;

class function MyFileTransferFaceUtil.getReceiveStatusIcon(
  Status: string): Integer;
begin
  if Status = ReceivePathStatus_Completed then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if Status = ReceivePathStatus_Receiving then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
  if Status = ReceivePathStatus_Offline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if Status = ReceivePathStatus_Cancel then
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

{ TLvFileReceiveSetStatusInfo }

procedure TLvFileReceiveSetStatusInfo.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TLvFileReceiveSetStatusInfo.Update;
var
  SelectItem : TListItem;
  ItemData : TLvFileReceiveData;
begin
  inherited;

  SelectItem := FindExistItem;
  if SelectItem = nil then
    Exit;
  ItemData := SelectItem.Data;

  SelectItem.SubItems[ LvMyFileReceive_Status ] := ReceiveStatus;
  SelectItem.SubItemImages[ LvMyFileReceive_Status ] := MyFileTransferFaceUtil.getReceiveStatusIcon( ReceiveStatus );
  ItemData.ReceiveStatus := ReceiveStatus;

    // 显示界面
  if ReceiveStatus = ReceivePathStatus_Completed then
  begin
    ItemData.CompletedSize := ItemData.FileSize;
    SelectItem.SubItems[ LvMyFileReceive_Percentage ] := MyPercentage.getPercentageStr( 100 );
  end;
end;


{ TVstMyFileSendChildChangeInfo }

function TVstMyFileSendChildChangeInfo.FindChildNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  Result := False;
  if not FindRootNode then
    Exit;

    // 文件是根节点
  if getIsRootFile then
  begin
    ChildNode := RootNode;
    ChildData := RootData;
    Result := True;
    Exit;
  end;

    // 寻找子节点
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstMyFileSend.GetNodeData( SelectNode );
    if SelectData.FilePath = ChildPath then  // 找到要删除的节点
    begin
      ChildNode := SelectNode;
      ChildData := VstMyFileSend.GetNodeData( ChildNode );
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TVstMyFileSendChildChangeInfo.getIsRootFile: Boolean;
begin
  Result := ChildPath = FilePath;
end;

procedure TVstMyFileSendChildChangeInfo.RefreshChildNode;
begin
  VstMyFileSend.RepaintNode( ChildNode );
end;

procedure TVstMyFileSendChildChangeInfo.SetChildPath(_ChildPath: string);
begin
  ChildPath := _ChildPath;
end;

{ TVstMyFilePcOnlineInfo }

constructor TVstMyFilePcOnlineInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstMyFilePcOnlineInfo.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstMyFilePcOnlineInfo.Update;
var
  SelectNode, SelectChildNode : PVirtualNode;
  SelectData, SelectChildData : PVstMyFileSendData;
begin
  inherited;

  SelectNode := VstMyFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstMyFileSend.GetNodeData( SelectNode );
      // 找到目标节点
    if ( SelectData.DesID = PcID ) then
    begin
      SelectData.DesIsOnline := IsOnline;
      VstMyFileSend.RepaintNode( SelectNode );

        // 修改子节点
      SelectChildNode := SelectNode.FirstChild;
      while Assigned( SelectChildNode ) do
      begin
        SelectChildData := VstMyFileSend.GetNodeData( SelectChildNode );
        SelectChildData.DesIsOnline := IsOnline;
        VstMyFileSend.RepaintNode( SelectChildNode );
        SelectChildNode := SelectChildNode.NextSibling;
      end;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ LvFileReceiveUtil }

class function LvFileReceiveUtil.ReadReceiveStatus(IsOnline: Boolean;
  Status: string): string;
begin
  if ( Status = ReceivePathStatus_Receiving ) and not IsOnline then
    Result := ReceivePathStatus_Offline
  else
    Result := Status;
end;

class function LvFileReceiveUtil.ReadReceiveStatusIcon(IsOnline: Boolean;
  Status: string): Integer;
begin
  if ( Status = ReceivePathStatus_Receiving ) and not IsOnline then
    Result := MyFileTransferFaceUtil.getReceiveStatusIcon( ReceivePathStatus_Offline )
  else
    Result := MyFileTransferFaceUtil.getReceiveStatusIcon( Status );
end;

{ TLvFileReceiveSetSourceOnlineInfo }

constructor TLvFileReceiveSetSourceOnlineInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TLvFileReceiveSetSourceOnlineInfo.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TLvFileReceiveSetSourceOnlineInfo.Update;
var
  i : Integer;
  ItemData : TLvFileReceiveData;
begin
  inherited;

  for i := 0 to LvMyFileReceive.Items.Count - 1 do
  begin
    ItemData := LvMyFileReceive.Items[i].Data;
    if ItemData.SourcePcID = PcID then
    begin
      LvMyFileReceive.Items[i].SubItems[ LvMyFileReceive_Status ] := LvFileReceiveUtil.ReadReceiveStatus( IsOnline, ItemData.ReceiveStatus );
      LvMyFileReceive.Items[i].SubItemImages[ LvMyFileReceive_Status ] := LvFileReceiveUtil.ReadReceiveStatusIcon( IsOnline, ItemData.ReceiveStatus );
    end;
  end;
end;

{ TLvFileReceiveSetAllPcOfflineInfo }

procedure TLvFileReceiveSetAllPcOfflineInfo.Update;
var
  i : Integer;
  ItemData : TLvFileReceiveData;
  SelectItem : TListItem;
begin
  inherited;

  for i := 0 to LvMyFileReceive.Items.Count - 1 do
  begin
    SelectItem := LvMyFileReceive.Items[i];
    ItemData := SelectItem.Data;
    SelectItem.SubItems[ LvMyFileReceive_Status ] := LvFileReceiveUtil.ReadReceiveStatus( False, ItemData.ReceiveStatus );
    SelectItem.SubItemImages[ LvMyFileReceive_Status ] := LvFileReceiveUtil.ReadReceiveStatusIcon( False, ItemData.ReceiveStatus );
  end;
end;

{ TVstMyFileAllPcOfflineInfo }

procedure TVstMyFileAllPcOfflineInfo.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  inherited;

  SelectNode := VstMyFileSend.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstMyFileSend.GetNodeData( SelectNode );
      // 找到目标节点
    SelectData.DesIsOnline := False;
      // 刷新
    VstMyFileSend.RepaintNode( SelectNode );

    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstMyFileSendClearChildInfo }

procedure TVstMyFileSendCancelChildInfo.RemoveChildJob(ChildPath: string);
var
  SendFileRemoveChildJobHandle : TSendFileRemoveChildJobHandle;
begin
  SendFileRemoveChildJobHandle := TSendFileRemoveChildJobHandle.Create( FilePath, PcID );
  SendFileRemoveChildJobHandle.SetFilePath( ChildPath );
  SendFileRemoveChildJobHandle.Update;
  SendFileRemoveChildJobHandle.Free;
end;

procedure TVstMyFileSendCancelChildInfo.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstMyFileSendData;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

    // 删除 子节点
  VstMyFileSend.DeleteChildren( RootNode );
  VstMyFileSend.Expanded[ RootNode ] := False;
  VstMyFileSend.RepaintNode( RootNode );
end;


{ TVstFileTransferDesChange }

procedure TVstFileTransferDesChange.RefreshVisiblePc( IsExist : Boolean );
begin
  VstSelectSendPcUtil.ResetVisiblePc( IsExist );
end;

procedure TVstFileTransferDesChange.Update;
begin
  vstFileTransferDes := frmMainForm.vstFileTransferDes;
end;

{ TVstFileTransferDesWrite }

constructor TVstFileTransferDesWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstFileTransferDesWrite.CreatePcNode;
begin
    // 创建界面和显示数据
  PcNode := vstFileTransferDes.AddChild( vstFileTransferDes.RootNode );
  PcData := vstFileTransferDes.GetNodeData( PcNode );
  PcData.PcID := PcID;
  PcData.PcName := PcID;
  PcData.DownloadCount := 0;
  PcData.UploadCount := 0;
  PcData.IsShowUpload := False;
  PcData.IsShowDownload := False;
  PcData.IsOnline := False;

    // 隐藏
  if VstFileSendDes_IsOnlyOnline then
    vstFileTransferDes.IsVisible[ PcNode ] := False;
end;

function TVstFileTransferDesWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstFileTransferDesData;
begin
  Result := False;
  SelectNode := vstFileTransferDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstFileTransferDes.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      PcNode := SelectNode;
      PcData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstFileTransferDesAdd }

procedure TVstFileTransferDesAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstFileTransferDesAdd.Update;
begin
  inherited;

//     跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 不存在 则 创建
  if not FindPcNode then
    CreatePcNode;

    // 改名
  PcData.PcName := PcName;

    // 第一台显示的 Pc
  if vstFileTransferDes.VisibleCount = 1 then
    RefreshVisiblePc( True );
end;

{ TVstFileTransferDesOnline }

procedure TVstFileTransferDesOnline.Update;
begin
  inherited;

    // 跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 不存在, 则创建
  if not FindPcNode then
    CreatePcNode;

    // 排序
  VirtualTreeUtil.MoveToTop( vstFileTransferDes, PcNode );

    // 设置 Pc 为 上线
  PcData.IsOnline := True;
  if VstFileSendDes_IsOnlyOnline then
    vstFileTransferDes.IsVisible[ PcNode ] := True;
  vstFileTransferDes.RepaintNode( PcNode );

    // 第一台显示的 Pc
  if vstFileTransferDes.VisibleCount = 1 then
    RefreshVisiblePc( True );
end;

{ TVstFileTransferDesOffline }

procedure TVstFileTransferDesOffline.Update;
begin
  inherited;

  if not FindPcNode then
    Exit;

      // 排序
  VirtualTreeUtil.MoveToBottom( vstFileTransferDes, PcNode );

  PcData.IsOnline := False;
  if VstFileSendDes_IsOnlyOnline then
    vstFileTransferDes.IsVisible[ PcNode ] := False;
  vstFileTransferDes.RepaintNode( PcNode );

    // 最后一台显示的 Pc
  if vstFileTransferDes.VisibleCount = 0 then
    RefreshVisiblePc( False );
end;

{ TVstFileTransferDesServerOffline }

procedure TVstFileTransferDesServerOffline.PcOffline(PcID: string);
var
  VstFileTransferDesOffline : TVstFileTransferDesOffline;
begin
  VstFileTransferDesOffline := TVstFileTransferDesOffline.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesOffline );
end;

procedure TVstFileTransferDesServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstFileTransferDesData;
begin
  inherited;

  SelectNode := vstFileTransferDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstFileTransferDes.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      PcOffline( SelectData.PcID );  // Pc 离线处理
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLvFileReceiveStartInfo }

procedure TLvFileReceiveStartInfo.Update;
begin
  LvFileReceive_IsStart := True;
end;

{ TVstFileTransferDesAddDownload }

procedure TVstFileTransferDesAddDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount + 1;

    // 显示下载列
  if ( PcData.DownloadCount = 1 ) then
  begin
    PcData.IsShowDownload := True;

    VtCol := vstFileTransferDes.Header.Columns[ VstFileSendDes_Download ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

  vstFileTransferDes.RepaintNode( PcNode );
end;

{ TVstFileTransferDesRemoveDownload }

procedure TVstFileTransferDesRemoveDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount - 1;
  vstFileTransferDes.RepaintNode( PcNode );

    // 隐藏下载列
  if ( PcData.DownloadCount = 0 ) then
    VstFileSendDesHideThread.AddDownHideInfo( PcID );
end;

{ TVstFileTransferDesRemoveUpload }

procedure TVstFileTransferDesRemoveUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount - 1;
  vstFileTransferDes.RepaintNode( PcNode );

    // 隐藏上传列
  if ( PcData.UploadCount = 0 ) then
    VstFileSendDesHideThread.AddUpHideInfo( PcID );
end;

{ TVstFileTransferDesAddUpload }

procedure TVstFileTransferDesAddUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount + 1;

    // 显示上传列
  if ( PcData.UploadCount = 1 ) then
  begin
    PcData.IsShowUpload := True;

    VtCol := vstFileTransferDes.Header.Columns[ VstFileSendDes_Upload ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

  vstFileTransferDes.RepaintNode( PcNode );
end;

{ TVstFileSendDesHideThread }

procedure TVstFileSendDesHideThread.AddDownHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstFileSendDesHideInfo;
begin
  Lock.Enter;
  if VstFileSendDesDownHideHash.ContainsKey( PcID ) then
    VstFileSendDesDownHideHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstFileSendDesHideInfo.Create( PcID );
    VstFileSendDesDownHideHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstFileSendDesHideThread.AddUpHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstFileSendDesHideInfo;
begin
  Lock.Enter;
  if VstFileSendDesUpHideHash.ContainsKey( PcID ) then
    VstFileSendDesUpHideHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstFileSendDesHideInfo.Create( PcID );
    VstFileSendDesUpHideHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstFileSendDesHideThread.CheckLvHideDown;
var
  RemoveList : TStringList;
  p : TVstFileSendDesHidePair;
  VstFileTransferDesHidePcDownload : TVstFileTransferDesHidePcDownload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstFileSendDesDownHideHash do
  begin
      // 没有到隐藏的时间, 跳过
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // 添加 隐藏
    RemoveList.Add( p.Value.PcID );
  end;
    // 遍历 隐藏
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstFileSendDesDownHideHash.Remove( PcID );
          // 隐藏 下载
    VstFileTransferDesHidePcDownload := TVstFileTransferDesHidePcDownload.Create( PcID );
    MyFaceChange.AddChange( VstFileTransferDesHidePcDownload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;

procedure TVstFileSendDesHideThread.CheckLvHideUp;
var
  RemoveList : TStringList;
  p : TVstFileSendDesHidePair;
  VstFileTransferDesHidePcUpload : TVstFileTransferDesHidePcUpload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstFileSendDesUpHideHash do
  begin
      // 没有到隐藏的时间, 跳过
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // 添加 隐藏
    RemoveList.Add( p.Value.PcID );
  end;
    // 遍历 隐藏
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstFileSendDesUpHideHash.Remove( PcID );
          // 隐藏 下载
    VstFileTransferDesHidePcUpload := TVstFileTransferDesHidePcUpload.Create( PcID );
    MyFaceChange.AddChange( VstFileTransferDesHidePcUpload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;


constructor TVstFileSendDesHideThread.Create;
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;
  VstFileSendDesDownHideHash := TVstFileSendDesHideHash.Create;
  VstFileSendDesUpHideHash := TVstFileSendDesHideHash.Create;
end;

destructor TVstFileSendDesHideThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  VstFileSendDesDownHideHash.Free;
  VstFileSendDesUpHideHash.Free;
  Lock.Free;
  inherited;
end;

procedure TVstFileSendDesHideThread.Execute;
begin
  while not Terminated do
  begin
    if not ExistHidePc then
    begin
      Suspend;
      Continue;
    end;

    if Terminated then
      Break;

    CheckLvHideDown;
    CheckLvHideUp;

    Sleep(100);
  end;

  inherited;
end;


function TVstFileSendDesHideThread.ExistHidePc: Boolean;
begin
  Lock.Enter;
  Result := ( VstFileSendDesDownHideHash.Count > 0 ) or
            ( VstFileSendDesUpHideHash.Count > 0 );
  Lock.Leave;
end;

{ TVstFileSendDesHideInfo }

constructor TVstFileSendDesHideInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  StartTime := Now;
end;

{ TVstFileTransferDesHidePcDownload }

procedure TVstFileTransferDesHidePcDownload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstFileTransferDesData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // 存在 下载, 跳过
  if  PcData.DownloadCount > 0 then
    Exit;

    // 隐藏下载列
  PcData.IsShowDownload := False;
  vstFileTransferDes.RepaintNode( PcNode );

    // 是否 所有列 都隐藏
  SelectNode := vstFileTransferDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstFileTransferDes.GetNodeData( SelectNode );
    if SelectData.IsShowDownload then // 结束
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // 隐藏
  VtCol := vstFileTransferDes.Header.Columns[ VstFileSendDes_Download ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstFileTransferDesHidePcUpload }

procedure TVstFileTransferDesHidePcUpload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstFileTransferDesData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // 显示下载列
  if PcData.UploadCount > 0 then
    Exit;

  PcData.IsShowUpload := False;
  vstFileTransferDes.RepaintNode( PcNode );

    // 是否 所有列 都隐藏
  SelectNode := vstFileTransferDes.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstFileTransferDes.GetNodeData( SelectNode );
    if SelectData.IsShowUpload then // 结束
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

  VtCol := vstFileTransferDes.Header.Columns[ VstFileSendDes_Upload ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstMyFileSendAddCompletedSize }

procedure TVstMyFileSendAddCompletedSize.SetAddSize(_AddSize: Int64);
begin
  AddSize := _AddSize;
end;

procedure TVstMyFileSendAddCompletedSize.Update;
begin
  inherited;

    // 不存在
  if not FindRootNode then
    Exit;

  RootData.CompletedSize := RootData.CompletedSize + AddSize;

    // 刷新节点
  RefreshRootNode;
end;

{ TLvFileREceiveAddCompletedSpace }

procedure TLvFileReceiveAddCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TLvFileReceiveAddCompletedSpace.Update;
var
  SelectItem : TListItem;
  SelectData : TLvFileReceiveData;
  Percentage : Integer;
begin
  inherited;

  SelectItem := FindExistItem;
  if SelectItem = nil then
    Exit;

    // 设置数据
  SelectData := SelectItem.Data;
  SelectData.CompletedSize := SelectData.CompletedSize + CompletedSpace;
  Percentage := MyPercentage.getPercent( SelectData.CompletedSize, SelectData.FileSize );

    // 显示界面
  SelectItem.SubItems[ LvMyFileReceive_Percentage ] := MyPercentage.getPercentageStr( Percentage );
end;

{ TVstMyFileSendChildAddCompletedInfo }

procedure TVstMyFileSendChildAddCompletedInfo.SetCompletedSize(
  _CompletedSize: Integer);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstMyFileSendChildAddCompletedInfo.Update;
begin
  inherited;

  if not FindChildNode then
    Exit;

  if getIsRootFile then
    Exit;

  ChildData.CompletedSize := ChildData.CompletedSize + CompletedSize;

  RefreshChildNode;
end;

{ TVstSelectSendPcChange }

procedure TVstSelectSendPcChange.Update;
begin
  vstSelectSendPc := frmSelectTransfer.VstSelectSendPc;
end;

{ TVstSelectSendPcServerOffline }

procedure TVstSelectSendPcServerOffline.PcOffline(PcID: string);
var
  VstSelectSendPcOffline : TVstSelectSendPcOffline;
begin
  VstSelectSendPcOffline := TVstSelectSendPcOffline.Create( PcID );
  MyFaceChange.AddChange( VstSelectSendPcOffline );
end;

procedure TVstSelectSendPcServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSelectSendPcData;
begin
  inherited;

  SelectNode := vstSelectSendPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectSendPc.GetNodeData( SelectNode );
    if SelectData.IsOnline then
      PcOffline( SelectData.PcID );  // Pc 离线处理
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstSelectSendPcWrite }

constructor TVstSelectSendPcWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstSelectSendPcWrite.CreatePcNode;
begin
    // 创建界面和显示数据
  PcNode := vstSelectSendPc.AddChild( vstSelectSendPc.RootNode );
  PcData := vstSelectSendPc.GetNodeData( PcNode );
  PcData.PcID := PcID;
  PcData.PcName := PcID;
  PcData.IsOnline := False;

  vstSelectSendPc.CheckType[ PcNode ] := ctTriStateCheckBox;

    // 隐藏
  if VstFileSendDes_IsOnlyOnline then
    vstSelectSendPc.IsVisible[ PcNode ] := False;
end;

function TVstSelectSendPcWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSelectSendPcData;
begin
  Result := False;
  SelectNode := vstSelectSendPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSelectSendPc.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      PcNode := SelectNode;
      PcData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstSelectSendPcAdd }

procedure TVstSelectSendPcAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstSelectSendPcAdd.Update;
begin
  inherited;

    // 跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 不存在 则 创建
  if not FindPcNode then
    CreatePcNode;

    // 改名
  PcData.PcName := PcName;
end;

{ TVstSelectSendPcOnline }

procedure TVstSelectSendPcOnline.Update;
begin
  inherited;

    // 跳过本机
  if PcID = Network_LocalPcID then
    Exit;

    // 不存在, 则创建
  if not FindPcNode then
    CreatePcNode;

    // 排序
  VirtualTreeUtil.MoveToTop( vstSelectSendPc, PcNode );

    // 设置 Pc 为 上线
  PcData.IsOnline := True;
  if VstFileSendDes_IsOnlyOnline then
    vstSelectSendPc.IsVisible[ PcNode ] := True;
  vstSelectSendPc.RepaintNode( PcNode );
end;

{ TVstSelectSendPcOffline }

procedure TVstSelectSendPcOffline.Update;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // 排序
  VirtualTreeUtil.MoveToBottom( vstSelectSendPc, PcNode );

  PcData.IsOnline := False;
  if VstFileSendDes_IsOnlyOnline then
    vstSelectSendPc.IsVisible[ PcNode ] := False;
  vstSelectSendPc.RepaintNode( PcNode );
end;

{ VstSelectSendPcUtil }

class procedure VstSelectSendPcUtil.ResetVisiblePc(IsExist: Boolean);
begin
  if frmMainForm.plFileSendNoPc.Visible <> not IsExist then
  begin
    frmMainForm.plFileSendNoPc.Visible := not IsExist;
    frmSelectTransfer.PlNoPcSend.Visible := frmMainForm.plFileSendNoPc.Visible;
    if IsExist then
      frmMainForm.vstFileTransferDes.Hint := frmMainForm.siLang_frmMainForm.GetText( 'DragFile' )
    else
    begin
      frmMainForm.vstFileTransferDes.Hint := '';
      frmSelectTransfer.plShowAllComputers.Visible := frmMainForm.vstFileTransferDes.RootNodeCount > 0;
    end;
  end;
end;

{ TFrmSelectReceivePath }

constructor TFrmSelectReceivePath.Create(_FilePath, _PathType: string);
begin
  SendFilePath := _FilePath;
  PathType := _PathType;
end;

procedure TFrmSelectReceivePath.FreedBackupCancel;
var
  ClientSendFileFeedbackMsg : TClientSendFileFeedbackMsg;
begin
    // 发送 feedback 命令
  ClientSendFileFeedbackMsg := TClientSendFileFeedbackMsg.Create;
  ClientSendFileFeedbackMsg.SetPcID( PcInfo.PcID );
  ClientSendFileFeedbackMsg.SetSourceFilePath( SendFilePath );
  ClientSendFileFeedbackMsg.SetSendPathStatus( SendPathStatus_Cancel );
  MyClient.SendMsgToPc( FileFromPcID, ClientSendFileFeedbackMsg );
end;

procedure TFrmSelectReceivePath.SetFileFrom(_FileFromPcID, _FileFromPcName: string);
begin
  FileFromPcID := _FileFromPcID;
  FileFromPcName := _FileFromPcName;
end;

procedure TFrmSelectReceivePath.SetSpace(_FileSize: Int64; _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TFrmSelectReceivePath.Update;
var
  ReceivePath : string;
  AddReceiveFileManualHandle : TAddReceiveFileManualHandle;
begin
  ReceivePath := ReceiveFileControlUtil.getReceivePath( SendFilePath );

  frmSelectReceive.SetFileInfo( ExtractFileName( SendFilePath ), FileFromPcName );
  frmSelectReceive.SetFileSpace( FileSize, FileCount );
  frmSelectReceive.SetReceivePath( ReceivePath );
  if frmSelectReceive.ShowModal = mrCancel then // 取消接收
  begin
    FreedBackupCancel;
    Exit;
  end;
  ReceivePath := frmSelectReceive.getReceivePath;

  AddReceiveFileManualHandle := TAddReceiveFileManualHandle.Create( SendFilePath, FileFromPcID );
  AddReceiveFileManualHandle.SetSendPathType( PathType );
  AddReceiveFileManualHandle.SetFileInfo( FileSize, FileCount );
  AddReceiveFileManualHandle.SetReceivePath( ReceivePath );
  AddReceiveFileManualHandle.Update;
  AddReceiveFileManualHandle.Free;
end;

end.
