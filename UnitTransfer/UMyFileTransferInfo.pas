unit UMyFileTransferInfo;

interface

uses Generics.Collections, UChangeInfo, UMyUtil, Classes, SysUtils, uDebug, UDataSetInfo;

type

{$Region ' 发送文件 数据结构 ' }

    // 父类
  TFileSendBaseInfo = class
  public
    FullPath, DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
  end;

    // 正在扫描的
  TFileSendScanInfo = class( TFileSendBaseInfo )end;
  TFileSendScanList = class( TObjectList<TFileSendScanInfo> )end;

    // 需要发送的
  TFileSendInfo = class( TFileSendBaseInfo )
  public
    FileSize, CompletedSize : Int64;
    FileCount : Integer;
    PathType, PathStatus : string;
  public
    procedure SetPathType( _PathType : string );
    procedure SetPathStatus( _PathStatus : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileCount( _FileCount : Integer );
  end;
  TFileSendList = class( TObjectList<TFileSendInfo> )end;

    // 取消发送的, 通知接收方
  TFileSendCancelInfo = class( TFileSendBaseInfo )end;
  TFileSendCancelList = class( TObjectList<TFileSendCancelInfo> )end;

    // 超出免费版限制的
  TFileSendDisableInfo = class( TFileSendBaseInfo )
  public
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;
  TFileSendDisableList = class( TObjectList<TFileSendDisableInfo> )end;


    // 文件发送 控制器
  TMyFileSendInfo = class( TMyDataInfo )
  public
    FileSendScanList : TFileSendScanList; // 正在扫描
    FileSendList : TFileSendList;   // 正在下载
  public
    FileSendCancelList : TFileSendCancelList;  // 已取消
    FileSendDisableList : TFileSendDisableList;  // 试用版限制
  public
    constructor Create;
    destructor Destroy; override;
  end;


{$EndRegion}

{$Region ' 发送文件 数据接口 ' }

    // 访问 集合
  TFileSendAccessInfo = class
  public
    FileSendScanList : TFileSendScanList;
    FileSendList : TFileSendList;
    FileSendCancelList : TFileSendCancelList;
    FileSendDisableList : TFileSendDisableList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 Item 父类
  TFileSendItemBaseAccessInfo = class( TFileSendAccessInfo )
  public
    FullPath, DesPcID : string;
  public
    constructor Create( _FullPath, _DesPcID : string );
  end;

    // 访问 扫描
  TFileSendScanAccessInfo = class( TFileSendItemBaseAccessInfo )
  public
    FileScanIndex : Integer;
    FileScanInfo : TFileSendScanInfo;
  protected
    function FindFileScanInfo : Boolean;
  end;

    // 访问 Item
  TFileSendItemAccessInfo = class( TFileSendItemBaseAccessInfo )
  protected
    FileSendIndex : Integer;
    FileSendInfo : TFileSendInfo;
  protected
    function FindFileSendInfo: Boolean;
  end;

    // 访问 Cancel
  TFileSendCancelAccessInfo = class( TFileSendItemBaseAccessInfo )
  public
    FileCancelIndex : Integer;
    FileCancelInfo : TFileSendCancelInfo;
  protected
    function FindFileCancelInfo : Boolean;
  end;

    // 访问 Disable
  TFileSendDisableAccessInfo = class( TFileSendItemBaseAccessInfo )
  public
    FilePath : string;
  protected
    FileDisableIndex : Integer;
    FileDisableInfo : TFileSendDisableInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindFileDisableInfo: Boolean;
  end;

{$EndRegion}

{$Region ' 发送文件 数据修改 ' }

  {$Region ' 修改 Item 信息 ' }

    // 修改
  TFileSendWriteInfo = class( TFileSendItemAccessInfo )
  end;

    // 添加
  TFileSendAddInfo = class( TFileSendWriteInfo )
  private
    SendPathStatus, SendPathType : string;
    FileSize, CompletedSize : Int64;
    FileCount : Integer;
  public
    procedure SetSendPathStatus( _SendPathStatus, _SendPathType : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;
  end;

    // 改变 发送根的状态
  TFileSendRootStatusInfo = class( TFileSendWriteInfo )
  private
    SendPathStatus : string;
  public
    procedure SetSendPathStatus( _SendPathStatus : string );
    procedure Update;
  end;

    // 设置 文件发送 总空间
  TFileSendSetSendSizeInfo = class( TFileSendWriteInfo )
  private
    SendFileSize : Int64;
  public
    procedure SetSendFileSize( _SendFileSize : Int64 );
    procedure Update;
  end;

    // 添加 文件发送 完成空间
  TFileSendAddCompletedSizeInfo = class( TFileSendWriteInfo )
  private
    AddSize : Int64;
  public
    procedure SetAddSize( _AddSize : Int64 );
    procedure Update;
  end;

    // 删除
  TFileSendRemoveInfo = class( TFileSendWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 修改 扫描路径 信息 ' }

    // 父类
  TFileSendScanWriteInfo = class( TFileSendScanAccessInfo )
  end;

    // 添加
  TFileSendScanAddInfo = class( TFileSendScanWriteInfo )
  public
    procedure Update;
  end;

    // 移除
  TFileSendScanRemoveInfo = class( TFileSendScanWriteInfo )
  public
    function get : Boolean;
  end;

  {$EndRegion}

  {$Region ' 修改 取消发送 信息 ' }

    // 父类
  TFileSendCancelWriteInfo = class( TFileSendCancelAccessInfo )
  end;

    // 添加 文件取消发送
  TFileSendCancelAddInfo = class( TFileSendCancelWriteInfo )
  public
    procedure Update;
  end;

    // 删除 文件取消发送
  TFileSendCancelRemoveInfo = class( TFileSendCancelWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 修改 免费限制 信息 ' }

    // 修改 父类
  TFileSendDisableChangeInfo = class( TFileSendDisableAccessInfo )
  end;

    // 添加
  TFileSendDisableAddInfo = class( TFileSendDisableChangeInfo )
  public
    procedure Update;
  end;

    // 删除
  TFileSendDisableRemoveInfo = class( TFileSendDisableChangeInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 发送文件 数据读取 ' }

  {$Region ' 读取 Item 信息 ' }

      // 等待的路径信息
  TWaitingPathInfo = class
  public
    FullPath, PathType : string;
    FileSize : Int64;
    FileCount : Integer;
  public
    constructor Create( FileSendInfo : TFileSendInfo );
  end;
  TWaitingPathList = class( TObjectList<TWaitingPathInfo> )end;

    // 读取 Pc 等待发送的路径
  TFileSendReadPcWaitingPath = class( TFileSendAccessInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    function get : TWaitingPathList;
  end;

    // 读取 文件根路径
  TFileSendReadFileRootPath = class( TFileSendAccessInfo )
  private
    FilePath, DesPcID : string;
  public
    constructor Create( _FilePath, _DesPcID : string );
    function get : string;
  end;

    // 读取 冲突的路径
  TFileSendReadConflictPath = class( TFileSendItemBaseAccessInfo )
  public
    function get : TStringList;
  end;

      // 读取 发送 是否已完成
  TFileSendReadIsCompleted = class( TFileSendItemAccessInfo )
  public
    function get : Boolean;
  end;

    // 发送路径是否存在
  TFileSendReadIsEnable = class( TFileSendItemAccessInfo )
  public
    function get : Boolean;
  end;

  {$EndRegion}

  {$Region ' 读取 取消发送 信息 ' }

    // 读取 Pc 取消的路径
  TFileSendReadPcCencelPath = class( TFileSendAccessInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    function get : TStringList;
  end;

  {$EndRegion}

  {$Region ' 读取 试用限制 信息 ' }

    // 读取 试用版限制 信息
  TFileSendReadDiablePath = class( TFileSendAccessInfo )
  public
    function get : TFileSendDisableList;
  end;

  {$EndRegion}

    // 读取 辅助类
  MyFileSendInfoReadUtil = class
  public            // 读取 Item
    class function ReadConflictPathList( FullPath, DesPcID : string ): TStringList;
    class function ReadIsEnable( FullPath, DesPcID : string ): Boolean;
    class function ReadIsCompleted( FullPath, DesPcID : string ): Boolean;
  public
    class function ReadPcWattingPcList( PcID : string ): TWaitingPathList;
    class function ReadRootPath( FilePath, DesPcID : string ): string;
  public            // 读取 其他集合
    class function ReadPcCancelPathList( PcID : string ): TStringList;
    class function ReadDisableList : TFileSendDisableList;
  end;

{$EndRegion}


{$Region ' 接收文件 数据结构 ' }

    // 父类
  TFileReceiveBaseInfo = class
  public
    SendPath, SourcePcID : string;
  public
    constructor Create( _SendPath, _SourcePcID : string );
  end;

    // 接收路径 信息
  TFileReceiveInfo = class( TFileReceiveBaseInfo )
  public
    ReceivePath, ReceiveStatus : string;
  public
    procedure SetReceivePath( _ReceivePath : string );
    procedure SetReceiveStatus( _ReceiveStatus : string );
  end;
  TFileReceiveList = class( TObjectList< TFileReceiveInfo > ) end;

    // 取消 接收路径信息
  TFileReceiveCancelInfo = class( TFileReceiveBaseInfo )end;
  TFileReceiveCancelList = class( TObjectList<TFileReceiveCancelInfo> )end;

    //  文件接收 控制器
  TMyFileReceiveInfo = class( TMyDataInfo )
  public
    FileReceiveList : TFileReceiveList;
    FileRceiveCancelList : TFileReceiveCancelList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 接收文件 数据接口 ' }

    // 访问 集合
  TFileReceiveAccessInfo = class
  protected
    FileReceiveList : TFileReceiveList;
    FileReceiveCancelList : TFileReceiveCancelList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 父类
  TFileReceiveItemBaseAccessInfo = class( TFileReceiveAccessInfo )
  public
    SendPath, SourcePcID : string;
  public
    constructor Create( _SendPath, _SourcePcID : string );
  end;

    // 访问 Item
  TFileReceiveItemAccessInfo = class( TFileReceiveItemBaseAccessInfo )
  public
    FileReceiveIndex : Integer;
    FileReceiveInfo : TFileReceiveInfo;
  protected
    function FindFileReceiveInfo : Boolean;
  end;

    // 访问 取消接收
  TFileReceiveCancelAccessInfo = class( TFileReceiveItemBaseAccessInfo )
  public
    FileCancelIndex : Integer;
    FileCancelInfo : TFileReceiveCancelInfo;
  protected
    function FindFileCancelInfo : Boolean;
  end;

{$EndRegion}

{$Region ' 接收文件 数据修改 ' }

  {$Region ' 修改 Item ' }

    // 修改 单项 父类
  TFileReceiveWriteInfo = class( TFileReceiveItemAccessInfo )
  end;

    // 添加
  TFileReceiveAddInfo = class( TFileReceiveWriteInfo )
  public
    ReceivePath : string;
    ReceiveStatus : string;
  public
    procedure SetReceivePath( _ReceivePath : string );
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;
  end;

    // 修改 状态
  TFileReceiveStatusInfo = class( TFileReceiveWriteInfo )
  public
    ReceiveStatus : string;
  public
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;
  end;

    // 删除
  TFileReceiveRemoveInfo = class( TFileReceiveWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 修改 取消接收 ' }

    // 取消路径 父类
  TFileReceiveCancelWriteInfo = class( TFileReceiveCancelAccessInfo )
  end;

    // 添加 取消路径
  TFileReceiveCancelAddInfo = class( TFileReceiveCancelWriteInfo )
  public
    procedure Update;
  end;

    // 删除 取消路径
  TFileReceiveCanceRemoveInfo = class( TFileReceiveCancelWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 接收文件 数据读取 ' }

  {$Region ' 读取 Item 信息 ' }

    // 是否存在 路径
  TFileReceiveReadReceivePathIsExist = class( TFileReceiveAccessInfo )
  public
    ReceivePath : string;
  public
    constructor Create( _ReceivePath : string );
    function get : Boolean;
  end;

    // 获取 根发送路径
  TFileReceiveReadRootSendPath = class( TFileReceiveAccessInfo )
  public
    SendFilePath, SourcePcID : string;
  public
    constructor Create( _SendFilePath, _SendPcID : string );
  public
    function get : string;
  end;

    // 获取 冲突路径
  TFileReceiveReadConflictPath = class( TFileReceiveItemBaseAccessInfo )
  public
    function get : TStringList;
  end;

    // 父类
  TFileReceiveReadRootInfo = class( TFileReceiveItemAccessInfo )
  end;

    // 获取 接收路径
  TFileReceiveReadAgainPath = class( TFileReceiveReadRootInfo )
  public
    function get : string;
  end;

    // 获取 接收是否已经存在
  TFileReceiveReadIsExist = class( TFileReceiveReadRootInfo )
  public
    function get : Boolean;
  end;

    // 获取 接收路径是否完成接收
  TFileReceiveReadIsCompleted = class( TFileReceiveReadRootInfo )
  public
    function get : Boolean;
  end;

  {$EndRegion}

  {$Region ' 读取 取消接收 信息 ' }

      // 读取 Pc 取消的路径
  TFileReceiveReadPcCancelPath = class( TFileReceiveAccessInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    function get : TStringList;
  end;

  {$EndRegion}

  MyFileReceiveInfoReadUtil = class
  public
    class function ReadPcConfilectPath( SendPath, SourcePcID : string ): TStringList; // 获取 冲突的路径
    class function ReadReceivePath( SendPath, SourcePcID : string ): string; // 重复发送，获取上一次接收路径
    class function ReadIsCompleted( SendPath, SourcePcID : string ): Boolean; // 是否已经完成接收
    class function ReadIsExist( SendPath, SourcePcID : string ): Boolean; // 是否存在
  public
    class function ReadReceivePathIsExist( ReceivePath : string ): Boolean;  // 是否 存在相同的接收路径
    class function ReadRootSendPath( SendFilePath, SourcePcID : string ): string; // 获取 根发送路径
  public
    class function ReadPcCancelPathList( PcID : string ): TStringList;  // 获取 取消的路径
  end;

{$EndRegion}


var
  MyFileReceiveInfo : TMyFileReceiveInfo;
  MyFileSendInfo : TMyFileSendInfo;

implementation

uses UMyFileTransferControl, UMyJobInfo, UMyClient, UMyNetPcInfo;

{ TFileReceiveInfo }

procedure TFileReceiveInfo.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

procedure TFileReceiveInfo.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

{ TMyFileReceiveInfo }

constructor TMyFileReceiveInfo.Create;
begin
  inherited;
  FileReceiveList := TFileReceiveList.Create;
  FileRceiveCancelList := TFileReceiveCancelList.Create;
end;

destructor TMyFileReceiveInfo.Destroy;
begin
  FileRceiveCancelList.Free;
  FileReceiveList.Free;
  inherited;
end;

{ TFileReceiveAddInfo }

procedure TFileReceiveAddInfo.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

procedure TFileReceiveAddInfo.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TFileReceiveAddInfo.Update;
begin
    // 已存在 则跳过
  if FindFileReceiveInfo then
    Exit;

    // 不存在 则添加
  FileReceiveInfo := TFileReceiveInfo.Create( SendPath, SourcePcID );
  FileReceiveInfo.SetReceivePath( ReceivePath );
  FileReceiveInfo.SetReceiveStatus( ReceiveStatus );
  FileReceiveList.Add( FileReceiveInfo );
end;

{ TFileReceiveRemoveInfo }

procedure TFileReceiveRemoveInfo.Update;
begin

    // 不存在 则跳过
  if not FindFileReceiveInfo then
    Exit;

    // 存在 则删除
  FileReceiveList.Delete( FileReceiveIndex );
end;

{ TFileSendInfo }

procedure TFileSendInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TFileSendInfo.SetPathStatus(_PathStatus: string);
begin
  PathStatus := _PathStatus;
end;

procedure TFileSendInfo.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TFileSendInfo.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

{ TMyFileSendInfo }

constructor TMyFileSendInfo.Create;
begin
  inherited;
  FileSendList := TFileSendList.Create;
  FileSendCancelList := TFileSendCancelList.Create;
  FileSendDisableList := TFileSendDisableList.Create;
  FileSendScanList := TFileSendScanList.Create;
end;

destructor TMyFileSendInfo.Destroy;
begin
  FileSendScanList.Free;
  FileSendDisableList.Free;
  FileSendCancelList.Free;
  FileSendList.Free;
  inherited;
end;

{ TFileSendAddInfo }

procedure TFileSendAddInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TFileSendAddInfo.SetFileSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TFileSendAddInfo.SetSendPathStatus(_SendPathStatus,
  _SendPathType: string);
begin
  SendPathStatus := _SendPathStatus;
  SendPathType := _SendPathType;
end;

procedure TFileSendAddInfo.Update;
begin
    // 已存在 则跳过
  if FindFileSendInfo then
    Exit;

    // 不存在 则添加
  FileSendInfo := TFileSendInfo.Create( FullPath, DesPcID );
  FileSendInfo.SetPathType( SendPathType );
  FileSendInfo.SetPathStatus( SendPathStatus );
  FileSendInfo.SetSpaceInfo( FileSize, CompletedSize );
  FileSendInfo.SetFileCount( FileCount );
  FileSendList.Add( FileSendInfo );
end;


{ TFileSendRemoveInfo }

procedure TFileSendRemoveInfo.Update;
begin
     // 不存在 则跳过
  if not FindFileSendInfo then
    Exit;

    // 存在 则删除
  FileSendList.Delete( FileSendIndex );
end;

{ TFileSendAddChildCount }

procedure TFileSendSetSendSizeInfo.SetSendFileSize(_SendFileSize: Int64);
begin
  SendFileSize := _SendFileSize;
end;

procedure TFileSendSetSendSizeInfo.Update;
begin
    // 不存在 则跳过
  if not FindFileSendInfo then
    Exit;

    // 设置 总空间
  FileSendInfo.FileSize := SendFileSize;
end;

{ TFileSendRemoveChildCount }

procedure TFileSendAddCompletedSizeInfo.SetAddSize(
  _AddSize: Int64);
begin
  AddSize := _AddSize;
end;

procedure TFileSendAddCompletedSizeInfo.Update;
begin
    // 不存在 则跳过
  if not FindFileSendInfo then
    Exit;

    // 添加
  FileSendInfo.CompletedSize := FileSendInfo.CompletedSize + AddSize;
end;

{ TFileSendRootStatusInfo }

procedure TFileSendRootStatusInfo.SetSendPathStatus(_SendPathStatus: string);
begin
  SendPathStatus := _SendPathStatus;
end;

procedure TFileSendRootStatusInfo.Update;
begin
    // 不存在 则跳过
  if not FindFileSendInfo then
    Exit;

    // 存在 则添加
  FileSendInfo.SetPathStatus( SendPathStatus );
end;

{ TSendFilePcWaitingRead }


constructor TFileSendReadPcWaitingPath.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TFileSendReadPcWaitingPath.get: TWaitingPathList;
var
  i : Integer;
  WaitingPathInfo : TWaitingPathInfo;
begin
  Result := TWaitingPathList.Create;

  for i := 0 to FileSendList.Count - 1 do
  begin
    if FileSendList[i].DesPcID <> PcID then
      Continue;
    if FileSendList[i].PathStatus = SendPathStatus_Waiting then
    begin
      WaitingPathInfo := TWaitingPathInfo.Create( FileSendList[i] );
      Result.Add( WaitingPathInfo );
    end;
  end;
end;

{ TFileReceiveCancelAddInfo }

procedure TFileReceiveCancelAddInfo.Update;
begin
    // 已存在
  if FindFileCancelInfo then
    Exit;

  FileCancelInfo := TFileReceiveCancelInfo.Create( SendPath, SourcePcID );
  FileReceiveCancelList.Add( FileCancelInfo );
end;

{ TReadSendFilePcCencel }

constructor TFileReceiveReadPcCancelPath.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TFileReceiveReadPcCancelPath.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  for i := 0 to FileReceiveCancelList.Count - 1 do
  begin
    if FileReceiveCancelList[i].SourcePcID = PcID then
      Result.Add( FileReceiveCancelList[i].SendPath );
  end;
end;

{ TReadSendFilePcCencel }

constructor TFileSendReadPcCencelPath.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TFileSendReadPcCencelPath.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  for i := 0 to FileSendCancelList.Count - 1 do
    if  FileSendCancelList[i].DesPcID = PcID then
      Result.Add( FileSendCancelList[i].FullPath );
end;

{ TFileReceiveCanceRemoveInfo }

procedure TFileReceiveCanceRemoveInfo.Update;
begin
    // 不存在
  if not FindFileCancelInfo then
    Exit;

    // 删除
  FileReceiveCancelList.Delete( FileCancelIndex );
end;

{ TFileSendCancelAddInfo }

procedure TFileSendCancelAddInfo.Update;
begin
    // 已存在
  if FindFileCancelInfo then
    Exit;

  FileCancelInfo := TFileSendCancelInfo.Create( FullPath, DesPcID );
  FileSendCancelList.Add( FileCancelInfo );
end;

{ TFileSendCancelRemoveInfo }

procedure TFileSendCancelRemoveInfo.Update;
begin
    // 不存在
  if not FindFileCancelInfo then
    Exit;

  FileSendCancelList.Delete( FileCancelIndex );
end;

{ TFileReceiveStatusInfo }

procedure TFileReceiveStatusInfo.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TFileReceiveStatusInfo.Update;
begin
    // 不存在
  if not FindFileReceiveInfo then
    Exit;

  FileReceiveInfo.ReceiveStatus := ReceiveStatus;
end;

{ TFileSendDisableInfo }

procedure TFileSendDisableInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TFileSendDisableAddInfo }

procedure TFileSendDisableAddInfo.Update;
begin
    // 已存在
  if FindFileDisableInfo then
    Exit;

  FileDisableInfo := TFileSendDisableInfo.Create( FullPath, DesPcID );
  FileDisableInfo.SetFilePath( FilePath );
  FileSendDisableList.Add( FileDisableInfo );
end;

{ TFileSendDisableRemoveInfo }

procedure TFileSendDisableRemoveInfo.Update;
begin
  if not FindFileDisableInfo then
    Exit;

  FileSendDisableList.Delete( FileDisableIndex );
end;

{ TReadSendFileDiableList }

function TFileSendReadDiablePath.get: TFileSendDisableList;
var
  i : Integer;
  FileSendDiasbaleInfo, NewFileSendDiasbaleInfo : TFileSendDisableInfo;
begin
  Result := TFileSendDisableList.Create;

  for i := 0 to FileSendDisableList.Count - 1 do
  begin
    FileSendDiasbaleInfo := FileSendDisableList[i];

    NewFileSendDiasbaleInfo := TFileSendDisableInfo.Create( FileSendDiasbaleInfo.FullPath, FileSendDiasbaleInfo.DesPcID );
    NewFileSendDiasbaleInfo.SetFilePath( FileSendDiasbaleInfo.FilePath );
    Result.Add( NewFileSendDiasbaleInfo );
  end;
end;

{ TWaitingPathInfo }

constructor TWaitingPathInfo.Create(FileSendInfo: TFileSendInfo);
begin
  FullPath := FileSendInfo.FullPath;
  PathType := FileSendInfo.PathType;
  FileSize := FileSendInfo.FileSize;
  FileCount := FileSendInfo.FileCount;
end;

{ TMyFileReceiveReadExist }

constructor TFileReceiveReadReceivePathIsExist.Create(_ReceivePath: string);
begin
  inherited Create;
  ReceivePath := _ReceivePath;
end;

function TFileReceiveReadReceivePathIsExist.get: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to FileReceiveList.Count - 1 do
    if FileReceiveList[i].ReceivePath = ReceivePath then
    begin
      Result := True;
      Break;
    end;
end;

{ MyFileReceiveUtil }

class function MyFileReceiveInfoReadUtil.ReadReceivePathIsExist(ReceivePath: string): Boolean;
var
  MyFileReceiveReadExist : TFileReceiveReadReceivePathIsExist;
begin
  MyFileReceiveReadExist := TFileReceiveReadReceivePathIsExist.Create( ReceivePath );
  Result :=  MyFileReceiveReadExist.get;
  MyFileReceiveReadExist.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadReceivePath(SendPath,
  SourcePcID: string): string;
var
  MyFileReceiveReadAgainPath : TFileReceiveReadAgainPath;
begin
  MyFileReceiveReadAgainPath := TFileReceiveReadAgainPath.Create( SendPath, SourcePcID );
  Result := MyFileReceiveReadAgainPath.get;
  MyFileReceiveReadAgainPath.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadIsCompleted(SendPath,
  SourcePcID: string): Boolean;
var
  FileReceiveReadIsCompleted : TFileReceiveReadIsCompleted;
begin
  FileReceiveReadIsCompleted := TFileReceiveReadIsCompleted.Create( SendPath, SourcePcID );
  Result := FileReceiveReadIsCompleted.get;
  FileReceiveReadIsCompleted.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadIsExist(SendPath,
  SourcePcID: string): Boolean;
var
  MyFileReceiveReadIsExist : TFileReceiveReadIsExist;
begin
  MyFileReceiveReadIsExist := TFileReceiveReadIsExist.Create( SendPath, SourcePcID );
  Result := MyFileReceiveReadIsExist.get;
  MyFileReceiveReadIsExist.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadPcCancelPathList(
  PcID: string): TStringList;
var
  ReadReceiveFilePcCencel : TFileReceiveReadPcCancelPath;
begin
  ReadReceiveFilePcCencel := TFileReceiveReadPcCancelPath.Create( PcID );
  Result := ReadReceiveFilePcCencel.get;
  ReadReceiveFilePcCencel.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadPcConfilectPath(SendPath,
  SourcePcID: string): TStringList;
var
  FileReceiveReadConflictPath : TFileReceiveReadConflictPath;
begin
  FileReceiveReadConflictPath := TFileReceiveReadConflictPath.Create( SendPath, SourcePcID );
  Result := FileReceiveReadConflictPath.get;
  FileReceiveReadConflictPath.Free;
end;

class function MyFileReceiveInfoReadUtil.ReadRootSendPath(SendFilePath,
  SourcePcID: string): string;
var
  FileReceiveReadRootSendPath : TFileReceiveReadRootSendPath;
begin
  FileReceiveReadRootSendPath := TFileReceiveReadRootSendPath.Create( SendFilePath, SourcePcID );
  Result := FileReceiveReadRootSendPath.get;
  FileReceiveReadRootSendPath.Free;
end;

{ TMyFileSendReadFileRootPath }

constructor TFileSendReadFileRootPath.Create(_FilePath, _DesPcID: string);
begin
  inherited Create;
  FilePath := _FilePath;
  DesPcID := _DesPcID;
end;

function TFileSendReadFileRootPath.get: string;
var
  i : Integer;
  RootPath : string;
begin
  Result := '';

  for i := 0 to FileSendList.Count - 1 do
  begin
    RootPath := FileSendList[i].FullPath;
    if ( FileSendList[i].DesPcID = DesPcID ) and
       MyMatchMask.CheckEqualsOrChild( FilePath, RootPath )
    then
    begin
      Result := RootPath;
      Break;
    end;
  end;
end;

{ TMyFileSendReadCompleted }

function TFileSendReadIsCompleted.get: Boolean;
begin
  Result := False;
  if not FindFileSendInfo then
    Exit;
  Result := FileSendInfo.CompletedSize >= FileSendInfo.FileSize;
end;

{ MyFileSendInfoReadUtil }

class function MyFileSendInfoReadUtil.ReadConflictPathList(FullPath,
  DesPcID: string): TStringList;
var
  MyFileSendReadConflictPath : TFileSendReadConflictPath;
begin
  MyFileSendReadConflictPath := TFileSendReadConflictPath.Create( FullPath, DesPcID );
  Result := MyFileSendReadConflictPath.get;
  MyFileSendReadConflictPath.Free;
end;

class function MyFileSendInfoReadUtil.ReadDisableList: TFileSendDisableList;
var
  ReadSendFileDiableList : TFileSendReadDiablePath;
begin
  ReadSendFileDiableList := TFileSendReadDiablePath.Create;
  Result := ReadSendFileDiableList.get;
  ReadSendFileDiableList.Free;
end;

class function MyFileSendInfoReadUtil.ReadIsCompleted(FullPath,
  DesPcID: string): Boolean;
var
  MyFileSendReadCompleted : TFileSendReadIsCompleted;
begin
  MyFileSendReadCompleted := TFileSendReadIsCompleted.Create( FullPath, DesPcID );
  Result := MyFileSendReadCompleted.get;
  MyFileSendReadCompleted.Free;
end;

class function MyFileSendInfoReadUtil.ReadIsEnable(FullPath,
  DesPcID: string): Boolean;
var
  MyFileSendReadIsEnable : TFileSendReadIsEnable;
begin
  MyFileSendReadIsEnable := TFileSendReadIsEnable.Create( FullPath, DesPcID );
  Result := MyFileSendReadIsEnable.get;
  MyFileSendReadIsEnable.Free;
end;

class function MyFileSendInfoReadUtil.ReadPcCancelPathList(
  PcID: string): TStringList;
var
  ReadSendFilePcCencel : TFileSendReadPcCencelPath;
begin
  ReadSendFilePcCencel := TFileSendReadPcCencelPath.Create( PcID );
  Result := ReadSendFilePcCencel.get;
  ReadSendFilePcCencel.Free;
end;

class function MyFileSendInfoReadUtil.ReadPcWattingPcList(
  PcID: string): TWaitingPathList;
var
  ReadSendFilePcWaiting : TFileSendReadPcWaitingPath;
begin
  ReadSendFilePcWaiting := TFileSendReadPcWaitingPath.Create( PcID );
  Result := ReadSendFilePcWaiting.get;
  ReadSendFilePcWaiting.Free;
end;

class function MyFileSendInfoReadUtil.ReadRootPath(FilePath,
  DesPcID: string): string;
var
  MyFileSendReadFileRootPath : TFileSendReadFileRootPath;
begin
  MyFileSendReadFileRootPath := TFileSendReadFileRootPath.Create( FilePath, DesPcID );
  Result := MyFileSendReadFileRootPath.get;
  MyFileSendReadFileRootPath.Free;
end;

{ TMyFileReceiveReadAgainPath }

function TFileReceiveReadAgainPath.get: string;
begin
  Result := '';
  if not FindFileReceiveInfo then
    Exit;
  Result := FileReceiveInfo.ReceivePath;
end;

{ TMyFileReceiveReadIsExist }

function TFileReceiveReadIsExist.get: Boolean;
begin
  Result := FindFileReceiveInfo;
end;

{ TMyFileSendReadConflictPath }

function TFileSendReadConflictPath.get: TStringList;
var
  i : Integer;
  SelectPath : string;
begin
  Result := TStringList.Create;
  for i := 0 to FileSendList.Count - 1 do
  begin
    if FileSendList[i].DesPcID <> DesPcID then
      Continue;
    SelectPath := FileSendList[i].FullPath;
    if MyMatchMask.CheckEqualsOrChild( FullPath, SelectPath ) or
       MyMatchMask.CheckChild( SelectPath, FullPath )
    then
      Result.Add( SelectPath );
  end;
end;

{ TFileSendScanAddInfo }

procedure TFileSendScanAddInfo.Update;
begin
    // 已存在
  if FindFileScanInfo then
    Exit;

  FileScanInfo := TFileSendScanInfo.Create( FullPath, DesPcID );
  FileSendScanList.Add( FileScanInfo );
end;

{ TFileSendAccessInfo }

constructor TFileSendAccessInfo.Create;
begin
  MyFileSendInfo.EnterData;
  FileSendScanList := MyFileSendInfo.FileSendScanList;
  FileSendList := MyFileSendInfo.FileSendList;
  FileSendCancelList := MyFileSendInfo.FileSendCancelList;
  FileSendDisableList := MyFileSendInfo.FileSendDisableList;
end;

destructor TFileSendAccessInfo.Destroy;
begin
  MyFileSendInfo.LeaveData;
  inherited;
end;

{ TFileSendRootAccessInfo }

function TFileSendItemAccessInfo.FindFileSendInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileSendList.Count - 1 do
    if ( FileSendList[i].FullPath = FullPath ) and
       ( FileSendList[i].DesPcID = DesPcID )
    then
    begin
      FileSendIndex := i;
      FileSendInfo := FileSendList[i];
      Result := True;
      Break;
    end;
end;

{ TFileSendBaseInfo }

constructor TFileSendBaseInfo.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

{ TFileSendItemBaseAccessInfo }

constructor TFileSendItemBaseAccessInfo.Create(_FullPath, _DesPcID: string);
begin
  inherited Create;
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

{ TFileSendScanAccessInfo }

function TFileSendScanAccessInfo.FindFileScanInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileSendScanList.Count - 1 do
    if ( FileSendScanList[i].FullPath = FullPath ) and
       ( FileSendScanList[i].DesPcID = DesPcID )
    then
    begin
      FileScanIndex := i;
      FileScanInfo := FileSendScanList[i];
      Result := True;
      Break;
    end;
end;


{ TFileSendCancelAccessInfo }

function TFileSendCancelAccessInfo.FindFileCancelInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileSendCancelList.Count - 1 do
    if ( FileSendCancelList[i].FullPath = FullPath ) and
       ( FileSendCancelList[i].DesPcID = DesPcID )
    then
    begin
      FileCancelIndex := i;
      FileCancelInfo := FileSendCancelList[i];
      Result := True;
      Break;
    end;
end;


{ TFileSendDisableAccessInfo }

function TFileSendDisableAccessInfo.FindFileDisableInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileSendDisableList.Count - 1 do
    if ( FileSendDisableList[i].FullPath = FullPath ) and
       ( FileSendDisableList[i].DesPcID = DesPcID ) and
       ( FileSendDisableList[i].FilePath = FilePath )
    then
    begin
      FileDisableIndex := i;
      FileDisableInfo := FileSendDisableList[i];
      Result := True;
      Break;
    end;
end;


procedure TFileSendDisableAccessInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TFileSendScanRemoveInfo }

function TFileSendScanRemoveInfo.get: Boolean;
begin
  Result := FindFileScanInfo;
  if Result then
    FileSendScanList.Delete( FileScanIndex );
end;

{ TMyFileSendReadIsEnable }

function TFileSendReadIsEnable.get: Boolean;
begin
  Result := FindFileSendInfo and ( FileSendInfo.PathStatus <> SendPathStatus_Cancel );
end;

{ TFileReceiveAccessInfo }

constructor TFileReceiveAccessInfo.Create;
begin
  MyFileReceiveInfo.EnterData;
  FileReceiveList := MyFileReceiveInfo.FileReceiveList;
  FileReceiveCancelList := MyFileReceiveInfo.FileRceiveCancelList;
end;

destructor TFileReceiveAccessInfo.Destroy;
begin
  MyFileReceiveInfo.LeaveData;
  inherited;
end;

{ TFileReceiveBaseInfo }

constructor TFileReceiveBaseInfo.Create(_SendPath, _SourcePcID: string);
begin
  SendPath := _SendPath;
  SourcePcID := _SourcePcID;
end;

{ TFileReceiveItemAccessInfo }

function TFileReceiveItemAccessInfo.FindFileReceiveInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileReceiveList.Count - 1 do
    if ( FileReceiveList[i].SendPath = SendPath ) and
       ( FileReceiveList[i].SourcePcID = SourcePcID )
    then
    begin
      FileReceiveIndex := i;
      FileReceiveInfo := FileReceiveList[i];
      Result := True;
      Break;
    end;
end;


{ TFileReceiveItemBaseAccessInfo }

constructor TFileReceiveItemBaseAccessInfo.Create(_SendPath,
  _SourcePcID: string);
begin
  inherited Create;
  SendPath := _SendPath;
  SourcePcID := _SourcePcID;
end;

{ TFileReceiveCancelAccessInfo }

function TFileReceiveCancelAccessInfo.FindFileCancelInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to FileReceiveCancelList.Count - 1 do
    if ( FileReceiveCancelList[i].SendPath = SendPath ) and
       ( FileReceiveCancelList[i].SourcePcID = SourcePcID )
    then
    begin
      FileCancelIndex := i;
      FileCancelInfo := FileReceiveCancelList[i];
      Result := True;
      Break;
    end;
end;

{ TFileReceiveReadConflictPath }

function TFileReceiveReadConflictPath.get: TStringList;
var
  i : Integer;
  SelectPath : string;
begin
  Result := TStringList.Create;

  for i := 0 to FileReceiveList.Count - 1 do
  begin
    if FileReceiveList[i].SourcePcID <> SourcePcID then
      Continue;
    SelectPath := FileReceiveList[i].SendPath;
    if MyMatchMask.CheckEqualsOrChild( SelectPath, SendPath ) or
       MyMatchMask.CheckChild( SendPath, SelectPath )
    then
      Result.Add( SelectPath );
  end;
end;

{ TFileReceiveReadRootSendPath }

constructor TFileReceiveReadRootSendPath.Create(_SendFilePath,
  _SendPcID: string);
begin
  inherited Create;
  SendFilePath := _SendFilePath;
  SourcePcID := _SendPcID;
end;

function TFileReceiveReadRootSendPath.get: string;
var
  i : Integer;
  SendRootPath : string;
begin
  Result := '';

  for i := 0 to FileReceiveList.Count - 1 do
  begin
    if FileReceiveList[i].SourcePcID <> SourcePcID then
      Continue;
    SendRootPath := FileReceiveList[i].SendPath;
    if MyMatchMask.CheckEqualsOrChild( SendFilePath, SendRootPath ) then
    begin
      Result := SendRootPath;
      Break;
    end;
  end;
end;

{ TFileReceiveReadIsCompleted }

function TFileReceiveReadIsCompleted.get: Boolean;
begin
  Result := FindFileReceiveInfo and
           ( FileReceiveInfo.ReceiveStatus = ReceivePathStatus_Completed );
end;

end.


