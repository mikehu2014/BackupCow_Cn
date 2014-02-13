unit UMyShareInfo;

interface

uses Generics.Collections, UModelUtil, UChangeInfo, Classes, UDataSetInfo;

type

{$Region ' 共享路径 数据结构 ' }

    // 共享路径信息
  TSharePathInfo = class
  public
    FullPath : string;
    PathType : string;
  public
    constructor Create( _FullPath, _PathType : string );
  end;
  TSharePathPair = TPair< string , TSharePathInfo >;
  TSharePathHash = class(TStringDictionary< TSharePathInfo >);

    // 共享路径控制器
  TMySharePathInfo = class( TMyDataInfo )
  public
    SharePathHash : TSharePathHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 共享路径 数据接口 ' }

    // 访问 集合
  TSharePathAccessInfo = class
  public
    SharePathHash : TSharePathHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 Item
  TSharePathItemAccessInfo = class( TSharePathAccessInfo )
  public
    FullPath : string;
  protected
    SharePathInfo : TSharePathInfo;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathInfo : Boolean;
  end;

{$EndRegion}

{$Region ' 共享路径 数据修改 ' }

    // 修改 指定路径 父类
  TSharePathWriteInfo = class( TSharePathItemAccessInfo )
  end;

    // 添加
  TSharePathAddInfo = class( TSharePathWriteInfo )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;
  end;

    // 删除
  TSharePathRemoveInfo = class( TSharePathWriteInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' 共享路径 数据读取 ' }

    // 读取 是否存在一条共享路径
  TSharePathReadIsExistShare = class( TSharePathAccessInfo )
  public
    function get : Boolean;
  end;

    // 读取 文件是否共享
  TSharePathReadIsEnable = class( TSharePathAccessInfo )
  private
    FilePath : string;
  public
    constructor Create( _FilePath : string );
    function get : Boolean;
  end;

    // 读取 所有共享路径
  TSharePathReadPathList = class( TSharePathAccessInfo )
  public
    function get : TStringList;
  end;

    // 读取 信息辅助类
  MySharePathInfoReadUtil = class
  public
    class function ReadIsExistShare : Boolean;  // 是否存在共享路径
    class function ReadFileIsEnable( FilePath : string ): Boolean;  // 文件是否共享
    class function ReadSharePathList : TStringList;  // 读取所有共享路径
  end;

{$EndRegion}


{$Region ' 共享下载 数据结构 ' }

    // 共享下载信息
  TShareDownInfo = class
  public
    DesPcID : string;
    FullPath : string;
    SavePath : string;
  public
    constructor Create( _DesPcID, _FullPath : string );
    procedure SetSavePath( _SavePath : string );
  end;
  TShareDownList = class( TObjectList<TShareDownInfo> )end;

    // 试用版功能限制
  TShareDownDisableInfo = class
  public
    DesPcID, FilePath, SavePath : string;
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _DesPcID, _FilePath, _SavePath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
  end;
  TShareDownDisableList = class( TObjectList<TShareDownDisableInfo> )end;

      // 下载 历史记录器
  TMyShareDownInfo = class( TMyDataInfo )
  public
    ShareDownList : TShareDownList;
    ShareDownDisableList : TShareDownDisableList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' 共享下载 数据接口 ' }

    // 访问 集合
  TShareDownAccessInfo = class
  public
    ShareDownList : TShareDownList;
    ShareDownDisableList : TShareDownDisableList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 Item
  TShareDownItemAccessInfo = class( TShareDownAccessInfo )
  public
    DesPcID, FullPath : string;
  protected
    ShareDownIndex : Integer;
    ShareDownInfo : TShareDownInfo;
  public
    constructor Create( _DesPcID, _FullPath : string );
  protected
    function FindShareDownInfo : Boolean;
  end;

    // 访问 免费限制
  TShareDownDisableAccessInfo = class( TShareDownAccessInfo )
  public
    DesPcID, FilePath : string;
  protected
    ShareDownDisableIndex : Integer;
    ShareDownDisableInfo : TShareDownDisableInfo;
  public
    constructor Create( _DesPcID, _FilePath : string );
  protected
    function FindShareDownDisable : Boolean;
  end;

{$EndRegion}

{$Region ' 共享下载 数据修改 ' }

  {$Region ' 修改 Item 信息 ' }

    // 修改 父类
  TShareDownWriteInfo = class( TShareDownItemAccessInfo )
  end;

    // 添加
  TShareDownAddInfo = class( TShareDownWriteInfo )
  private
    SavePath : string;
  public
    procedure SetSavePath( _SavePath : string );
    procedure Update;
  end;

    // 删除
  TShareDownRemoveInfo = class( TShareDownWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

  {$Region ' 修改 试用限制 信息 ' }

    // 修改
  TShareDownDisableWriteInfo = class( TShareDownDisableAccessInfo )
  end;

    // 添加
  TShareDownDisableAddInfo = class( TShareDownDisableWriteInfo )
  public
    SavePath : string;
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetSavePath( _SavePath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure Update;
  end;

    // 删除
  TShareDownDisableRemoveInfo = class( TShareDownDisableWriteInfo )
  public
    procedure Update;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 共享下载 数据读取 ' }

  {$Region ' 读取 Item 集合 ' }

  TShareDownReadInfo = class( TShareDownAccessInfo )
  end;

    // 是否存在 相同的 下载路径
  TShareDownReadIsExistDownPath = class( TShareDownReadInfo )
  public
    DownloadPath : string;
  public
    constructor Create( _DownloadPath : string );
    function get : Boolean;
  end;

    // 获取 Pc 的下载路径
  TShareDownReadPcShareDown = class( TShareDownReadInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    function get : TStringList;
  end;

    // 读取 根目录
  TShareDownReadRootPath = class( TShareDownReadInfo )
  public
    PcID, FilePath : string;
  public
    constructor Create( _PcID, _FilePath : string );
    function get : string;
  end;

    // 读取 冲突的路径
  TShareDownReadConflictPath = class( TShareDownItemAccessInfo )
  public
    function get : TStringList;
  end;

  {$EndRegion}

  {$Region ' 读取 Item ' }

    // 读取根路径信息
  TShareDownReadRootInfo = class( TShareDownItemAccessInfo )
  end;

    // 读取 保存路径
  TShareDownReadSavePath = class( TShareDownReadRootInfo )
  public
    function get : string;
  end;

    // 是否存在 路径
  TShareDownReadIsExist = class( TShareDownReadRootInfo )
  public
    function get : Boolean;
  end;

  {$EndRegion}

  {$Region ' 读取 免费下载 ' }

      // 读取免费限制的
  TShareDownReadDisablePath = class( TShareDownReadInfo )
  public
    function get : TShareDownDisableList;
  end;

  {$EndRegion}

    // 读取信息 辅助类
  MyShareDownInfoReadUtil = class
  public
    class function ReadSavePath( DesPcID, FullPath : string ): string;
    class function ReadIsEnable( DesPcID, FullPath : string ): Boolean;
    class function ReadConfilctPathList( DesPcID, FullPath : string ): TStringList;
  public
    class function ReadRootPath( DesPcID, FilePath : string ): string;
    class function ReadDownPathIsExist( DownPath : string ): Boolean;
    class function ReadPcDownPathList( PcID : string ): TStringList;
  public
    class function ReadDisablePathList : TShareDownDisableList;
  end;

{$EndRegion}

var
  MySharePathInfo : TMySharePathInfo;
  MyShareDownInfo : TMyShareDownInfo;

implementation

uses UMyClient, UMyUtil, UMyShareControl, UMyNetPcInfo;

{ TSharePathInfo }

constructor TSharePathInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

{ TMySharePathInfo }

constructor TMySharePathInfo.Create;
begin
  inherited Create;
  SharePathHash := TSharePathHash.Create;
end;

destructor TMySharePathInfo.Destroy;
begin
  SharePathHash.Free;
  inherited;
end;

{ TSharePathAddInfo }

procedure TSharePathAddInfo.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TSharePathAddInfo.Update;
begin
    // 已存在
  if FindSharePathInfo then
    Exit;

  SharePathInfo := TSharePathInfo.Create( FullPath, PathType );
  SharePathHash.AddOrSetValue( FullPath, SharePathInfo );
end;

{ TSharePathRemoveInfo }

procedure TSharePathRemoveInfo.Update;
begin
    // 不存在
  if not FindSharePathInfo then
    Exit;

  SharePathHash.Remove( FullPath );
end;

{ TShareDownInfo }

constructor TShareDownInfo.Create(_DesPcID, _FullPath: string);
begin
  DesPcID := _DesPcID;
  FullPath := _FullPath;
end;

procedure TShareDownInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TMyShareDownInfo }

constructor TMyShareDownInfo.Create;
begin
  inherited;
  ShareDownList := TShareDownList.Create;
  ShareDownDisableList := TShareDownDisableList.Create;
end;

destructor TMyShareDownInfo.Destroy;
begin
  ShareDownDisableList.Free;
  ShareDownList.Free;
  inherited;
end;

{ TShareDownRemoveInfo }

procedure TShareDownRemoveInfo.Update;
begin
    // 不存在
  if not FindShareDownInfo then
    Exit;

    // 删除
  ShareDownList.Delete( ShareDownIndex );
end;

{ TShareDownAddInfo }

procedure TShareDownAddInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareDownAddInfo.Update;
begin
    // 已存在
  if FindShareDownInfo then
    Exit;

    // 添加
  ShareDownInfo := TShareDownInfo.Create( DesPcID, FullPath );
  ShareDownInfo.SetSavePath( SavePath );
  ShareDownList.Add( ShareDownInfo );
end;

{ TShareDownDisableInfo }

constructor TShareDownDisableInfo.Create(_DesPcID, _FilePath,
  _SavePath: string);
begin
  DesPcID := _DesPcID;
  FilePath := _FilePath;
  SavePath := _SavePath;
end;

procedure TShareDownDisableInfo.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownDisableInfo.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

{ TShareDownDisableAddInfo }

procedure TShareDownDisableAddInfo.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TShareDownDisableAddInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TShareDownDisableAddInfo.SetSizeInfo(_FileSize,
  _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TShareDownDisableAddInfo.Update;
begin
    // 已存在
  if FindShareDownDisable then
    Exit;

    // 添加
  ShareDownDisableInfo := TShareDownDisableInfo.Create( DesPcID, FilePath, SavePath );
  ShareDownDisableInfo.SetSizeInfo( FileSize, CompletedSize );
  ShareDownDisableInfo.SetFileTime( FileTime );
  ShareDownDisableList.Add( ShareDownDisableInfo );
end;

{ TShareDownDisableRemoveInfo }

procedure TShareDownDisableRemoveInfo.Update;
begin
    // 不存在
  if not FindShareDownDisable then
    Exit;

    // 删除
  ShareDownDisableList.Delete( ShareDownDisableIndex )
end;

{ TShareDownDisableRead }

function TShareDownReadDisablePath.get: TShareDownDisableList;
var
  i : Integer;
  DesPcID, FilePath, SavePath : string;
  ShareDownDisableInfo : TShareDownDisableInfo;
begin
  Result := TShareDownDisableList.Create;

  for i := 0 to ShareDownDisableList.Count - 1 do
  begin
    DesPcID := ShareDownDisableList[i].DesPcID;
    FilePath := ShareDownDisableList[i].FilePath;
    SavePath := ShareDownDisableList[i].SavePath;
    ShareDownDisableInfo := TShareDownDisableInfo.Create( DesPcID, FilePath, SavePath );
    ShareDownDisableInfo.SetSizeInfo( ShareDownDisableList[i].FileSize, ShareDownDisableList[i].CompletedSize );
    ShareDownDisableInfo.SetFileTime( ShareDownDisableList[i].FileTime );
    Result.Add( ShareDownDisableInfo );
  end;
end;

{ TMySharePathReadIsShare }

function TSharePathReadIsExistShare.get: Boolean;
begin
  Result := SharePathHash.Count > 0;
end;

{ TMySharePathReadEnable }

constructor TSharePathReadIsEnable.Create(_FilePath: string);
begin
  inherited Create;
  FilePath := _FilePath;
end;

function TSharePathReadIsEnable.get: Boolean;
var
  p : TSharePathPair;
begin
  Result := False;

  for p in SharePathHash do
    if MyMatchMask.CheckEqualsOrChild( FilePath, p.Value.FullPath ) then
    begin
      Result := True;
      Break;
    end;
end;

{ MySharePathReadInfoUtil }

class function MySharePathInfoReadUtil.ReadFileIsEnable(FilePath: string): Boolean;
var
  MySharePathReadEnable : TSharePathReadIsEnable;
begin
  MySharePathReadEnable := TSharePathReadIsEnable.Create( FilePath );
  Result := MySharePathReadEnable.get;
  MySharePathReadEnable.Free;
end;

class function MySharePathInfoReadUtil.ReadIsExistShare: Boolean;
var
  MySharePathReadIsShare : TSharePathReadIsExistShare;
begin
  MySharePathReadIsShare := TSharePathReadIsExistShare.Create;
  Result := MySharePathReadIsShare.get;
  MySharePathReadIsShare.Free;
end;

class function MySharePathInfoReadUtil.ReadSharePathList: TStringList;
var
  SharePathReadPathList : TSharePathReadPathList;
begin
  SharePathReadPathList := TSharePathReadPathList.Create;
  Result := SharePathReadPathList.get;
  SharePathReadPathList.Free;
end;

{ TMyShareDownReadDownloadExist }

constructor TShareDownReadIsExistDownPath.Create(_DownloadPath: string);
begin
  inherited Create;
  DownloadPath := _DownloadPath;
end;

function TShareDownReadIsExistDownPath.get: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i].SavePath = DownloadPath then
    begin
      Result := True;
      Break;
    end;
end;

{ TMyShareDownReadRootPath }

constructor TShareDownReadRootPath.Create(_PcID, _FilePath: string);
begin
  inherited Create;
  PcID := _PcID;
  FilePath := _FilePath;
end;

function TShareDownReadRootPath.get: string;
var
  i : Integer;
begin
  Result := '';

  for i := 0 to ShareDownList.Count - 1 do
  begin
    if ShareDownList[i].DesPcID <> PcID then
      Continue;
    if MyMatchMask.CheckEqualsOrChild( FilePath, ShareDownList[i].FullPath ) then
    begin
      Result := ShareDownList[i].FullPath;
      Break;
    end;
  end;
end;

{ TMyShareDownReadSavePath }

function TShareDownReadSavePath.get: string;
begin
  Result := '';
  if not FindShareDownInfo then
    Exit;
  Result := ShareDownInfo.SavePath;
end;

{ TMyShareDownReadExist }

function TShareDownReadIsExist.get: Boolean;
begin
  Result := FindShareDownInfo;
end;

{ MyShareDownInfoReadUtil }

class function MyShareDownInfoReadUtil.ReadConfilctPathList(DesPcID,
  FullPath: string): TStringList;
var
  MyShareDownReadConflictPath : TShareDownReadConflictPath;
begin
  MyShareDownReadConflictPath := TShareDownReadConflictPath.Create( DesPcID, FullPath );
  Result := MyShareDownReadConflictPath.get;
  MyShareDownReadConflictPath.Free;
end;

class function MyShareDownInfoReadUtil.ReadDisablePathList: TShareDownDisableList;
var
  ShareDownDisableRead : TShareDownReadDisablePath;
begin
  ShareDownDisableRead := TShareDownReadDisablePath.Create;
  Result := ShareDownDisableRead.get;
  ShareDownDisableRead.Free;
end;

class function MyShareDownInfoReadUtil.ReadDownPathIsExist(
  DownPath: string): Boolean;
var
  MyShareDownReadDownloadExist : TShareDownReadIsExistDownPath;
begin
  MyShareDownReadDownloadExist := TShareDownReadIsExistDownPath.Create( DownPath );
  Result := MyShareDownReadDownloadExist.get;
  MyShareDownReadDownloadExist.Free;
end;

class function MyShareDownInfoReadUtil.ReadPcDownPathList(
  PcID: string): TStringList;
var
  MyShareDownReadPcDownPath : TShareDownReadPcShareDown;
begin
  MyShareDownReadPcDownPath := TShareDownReadPcShareDown.Create( PcID );
  Result := MyShareDownReadPcDownPath.get;
  MyShareDownReadPcDownPath.Free;
end;

class function MyShareDownInfoReadUtil.ReadIsEnable(DesPcID,
  FullPath: string): Boolean;
var
  MyShareDownReadExist : TShareDownReadIsExist;
begin
  MyShareDownReadExist := TShareDownReadIsExist.Create( DesPcID, FullPath );
  Result := MyShareDownReadExist.get;
  MyShareDownReadExist.Free;
end;

class function MyShareDownInfoReadUtil.ReadRootPath(DesPcID,
  FilePath: string): string;
var
  MyShareDownReadRootPath : TShareDownReadRootPath;
begin
  MyShareDownReadRootPath := TShareDownReadRootPath.Create( DesPcID, FilePath );
  Result := MyShareDownReadRootPath.get;
  MyShareDownReadRootPath.Free;
end;

class function MyShareDownInfoReadUtil.ReadSavePath(DesPcID,
  FullPath: string): string;
var
  MyShareDownReadSavePath : TShareDownReadSavePath;
begin
  MyShareDownReadSavePath := TShareDownReadSavePath.Create( DesPcID, FullPath );
  Result := MyShareDownReadSavePath.get;
  MyShareDownReadSavePath.Free;
end;

{ TMyShareDownReadConflictPath }

function TShareDownReadConflictPath.get: TStringList;
var
  i : Integer;
  SelectPath : string;
begin
  Result := TStringList.Create;
  for i := 0 to ShareDownList.Count - 1 do
  begin
    if ShareDownList[i].DesPcID <> DesPcID then
      Continue;
    SelectPath := ShareDownList[i].FullPath;
    if MyMatchMask.CheckEqualsOrChild( SelectPath, FullPath ) or
       MyMatchMask.CheckChild( FullPath, SelectPath )
    then
      Result.Add( SelectPath );
  end;
end;

{ TMyShareDownReadPcDownPath }

constructor TShareDownReadPcShareDown.Create(_PcID: string);
begin
  inherited Create;
  PcID := _PcID;
end;

function TShareDownReadPcShareDown.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to ShareDownList.Count - 1 do
    if ShareDownList[i].DesPcID = PcID then
      Result.Add( ShareDownList[i].FullPath );
end;

{ TSharePathAccessInfo }

constructor TSharePathAccessInfo.Create;
begin
  MySharePathInfo.EnterData;
  SharePathHash := MySharePathInfo.SharePathHash;
end;

destructor TSharePathAccessInfo.Destroy;
begin
  MySharePathInfo.LeaveData;
  inherited;
end;

{ TSharePathItemAccessInfo }

constructor TSharePathItemAccessInfo.Create(_FullPath: string);
begin
  inherited Create;
  FullPath := _FullPath;
end;

function TSharePathItemAccessInfo.FindSharePathInfo: Boolean;
begin
  Result := SharePathHash.ContainsKey( FullPath );
  if Result then
    SharePathInfo := SharePathHash[ FullPath ];
end;

{ TSharePathReadPathList }

function TSharePathReadPathList.get: TStringList;
var
  p : TSharePathPair;
begin
  Result := TStringList.Create;
  for p in SharePathHash do
    Result.Add( p.Value.FullPath );
end;

{ TShareDownAccessInfo }

constructor TShareDownAccessInfo.Create;
begin
  MyShareDownInfo.EnterData;
  ShareDownList := MyShareDownInfo.ShareDownList;
  ShareDownDisableList := MyShareDownInfo.ShareDownDisableList;
end;

destructor TShareDownAccessInfo.Destroy;
begin
  MyShareDownInfo.LeaveData;
  inherited;
end;

{ TShareDownItemAccessInfo }

constructor TShareDownItemAccessInfo.Create(_DesPcID, _FullPath: string);
begin
  inherited Create;
  DesPcID := _DesPcID;
  FullPath := _FullPath;
end;

function TShareDownItemAccessInfo.FindShareDownInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to ShareDownList.Count - 1 do
    if ( ShareDownList[i].DesPcID = DesPcID ) and
       ( ShareDownList[i].FullPath = FullPath )
    then
    begin
      ShareDownInfo := ShareDownList[i];
      ShareDownIndex := i;
      Result := True;
      Break;
    end;
end;

{ TShareDownDisableAccessInfo }

constructor TShareDownDisableAccessInfo.Create(_DesPcID, _FilePath: string);
begin
  inherited Create;
  DesPcID := _DesPcID;
  FilePath := _FilePath;
end;

function TShareDownDisableAccessInfo.FindShareDownDisable: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to ShareDownDisableList.Count - 1 do
    if ( ShareDownDisableList[i].DesPcID = DesPcID ) and
       ( ShareDownDisableList[i].FilePath = FilePath )
    then
    begin
      ShareDownDisableIndex := i;
      ShareDownDisableInfo := ShareDownDisableList[i];
      Result := True;
      Break;
    end;
end;

end.
