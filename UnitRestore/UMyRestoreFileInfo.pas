unit UMyRestoreFileInfo;

interface

uses UModelUtil, Generics.Collections, UChangeInfo, UMyUtil, Classes, SysUtils, UDataSetInfo;

type

{$Region ' 数据结构 ' }

    // Restore Item 信息
  TRestoreItemInfo = class
  public
    RestorePath, RestorePcID : string;
    SavePath : string;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    RestoreFileHash : TStringHash; // 快速恢复时使用
  public
    constructor Create( _FullPath, _RestorePcID : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure SetSavePath( _SavePath : string );
    destructor Destroy; override;
  end;
  TRestoreItemList = class( TObjectList<TRestoreItemInfo> )
  public
    function getItem( FullPath, RestorePcID : string ):TRestoreItemInfo;
    procedure RemoveItem( FullPath, RestorePcID : string );
  private
    function getItemIndex( FullPath, RestorePcID : string ): Integer;
  end;

{$EndRegion}

{$Region ' 数据接口 ' }

    // 访问 集合
  TRestoreAccessInfo = class
  public
    RestoreItemList : TRestoreItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 访问 Item
  TRestoreItemAccessInfo = class( TRestoreAccessInfo )
  public
    RestorePath, RestorePcID : string;
  protected
    RestoreItemIndex : Integer;
    RestoreItemInfo : TRestoreItemInfo;
  public
    constructor Create( _RestorePath, _RestorePcID : string );
  protected
    function FindRestoreItemInfo : Boolean;
  end;

{$EndRegion}

{$Region ' 数据修改 ' }

    // 修改
  TRestoreItemWriteInfo = class( TRestoreItemAccessInfo )
  end;

    // 添加
  TRestoreItemAddInfo = class( TRestoreItemWriteInfo )
  public
    SavePath : string;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetSavePath( _SavePath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure Update;
  end;

    // 移除
  TRestoreItemRemoveInfo = class( TRestoreItemWriteInfo )
  public
    procedure Update;
  end;

    // 快速恢复，文件搜索结果
  TRestoreFileAddInfo = class( TRestoreItemWriteInfo )
  public
    FilePath : string;
  public
    procedure SetPathInfo( _FilePath : string );
    function get : Boolean;
  end;

{$EndRegion}

{$Region ' 数据读取 ' }

      // 读取 根路径
  TRestoreFileReadRootPath = class( TRestoreAccessInfo )
  public
    FilePath, RestorePcID : string;
  public
    constructor Create( _FilePath, _RestorePcID : string );
    function get : string;
  end;

    // 父类
  TRestoreItemReadInfo = class( TRestoreItemAccessInfo )
  end;

    // 读取 冲突的路径
  TRestoreFileReadConflictPath = class( TRestoreItemReadInfo )
  public
    function get : TStringList;
  end;

    // 读取 保存路径
  TRestoreItemReadSavePath = class( TRestoreItemReadInfo )
  public
    function get : string;
  end;

    // 读取 密码
  TRestoreItemReadPassword = class( TRestoreItemReadInfo )
  public
    function get : string;
  end;

    // 读取 是否生效
  TRestoreItemReadIsEnable = class( TRestoreItemReadInfo )
  public
    function get : Boolean;
  end;


    // 读取 辅助类
  MyRestoreInfoReadUtil = class
  public
    class function ReadConflictPath( RestorePath, RestorePcID : string ): TStringList;
    class function ReadSavePath( RestorePath, RestorePcID : string ): string;
    class function ReadPassword( RestorePath, RestorePcID : string ): string;
    class function ReadIsEnable( RestorePath, RestorePcID : string ): Boolean;
  public
    class function ReadRootPath( FilePath, RestorePcID : string ): string;
  end;

{$EndRegion}

    // 恢复 文件信息
  TMyRestoreFileInfo = class( TMyDataInfo )
  public
    RestoreItemList : TRestoreItemList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  MyRestoreFileInfo : TMyRestoreFileInfo;

implementation


{ TRestoreItemInfo }

constructor TRestoreItemInfo.Create(_FullPath, _RestorePcID: string);
begin
  RestorePath := _FullPath;
  RestorePcID := _RestorePcID;
  RestoreFileHash := TStringHash.Create;
end;

destructor TRestoreItemInfo.Destroy;
begin
  RestoreFileHash.Free;
  inherited;
end;

procedure TRestoreItemInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreItemInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

{ TMyRestoreFileInfo }

constructor TMyRestoreFileInfo.Create;
begin
  inherited;
  RestoreItemList := TRestoreItemList.Create;
end;

destructor TMyRestoreFileInfo.Destroy;
begin
  RestoreItemList.Free;
  inherited;
end;

{ TRestoreItemAddInfo }

procedure TRestoreItemAddInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TRestoreItemAddInfo.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TRestoreItemAddInfo.Update;
begin
    // 已存在
  if FindRestoreItemInfo then
    Exit;

    // 添加
  RestoreItemInfo := TRestoreItemInfo.Create( RestorePath, RestorePcID );
  RestoreItemInfo.SetSavePath( SavePath );
  RestoreItemInfo.SetEncryptInfo( IsEncrypted, Password );
  RestoreItemList.Add( RestoreItemInfo );
end;

{ TRestoreItemRemoveInfo }

procedure TRestoreItemRemoveInfo.Update;
begin
    // 不存在
  if not FindRestoreItemInfo then
    Exit;

    // 删除
  RestoreItemList.Delete( RestoreItemIndex );
end;

{ TRestoreItemList }

function TRestoreItemList.getItem(FullPath, RestorePcID: string): TRestoreItemInfo;
var
  ItemIndex : Integer;
begin
  ItemIndex := getItemIndex( FullPath, RestorePcID );
  if ItemIndex = -1 then
    Result := nil
  else
    Result := Self[ ItemIndex ];
end;

function TRestoreItemList.getItemIndex(FullPath, RestorePcID: string): Integer;
var
  i : Integer;
begin
  Result := -1;

  for i := 0 to Self.Count - 1 do
    if ( Self[i].RestorePath = FullPath ) and ( Self[i].RestorePcID = RestorePcID ) then
    begin
      Result := i;
      Break;
    end;
end;

procedure TRestoreItemList.RemoveItem(FullPath, RestorePcID: string);
var
  ItemIndex : Integer;
begin
  ItemIndex := getItemIndex( FullPath, RestorePcID );
  if ItemIndex >= 0 then
    Self.Delete( ItemIndex );
end;

{ TRestoreFileReadExistList }

function TRestoreFileReadConflictPath.get: TStringList;
var
  i : Integer;
  SelectPath : string;
begin
  Result := TStringList.Create;
  for i := 0 to RestoreItemList.Count - 1 do
  begin
    if RestoreItemList[i].RestorePcID <> RestorePcID then
      Continue;

    SelectPath := RestoreItemList[i].RestorePath;
    if MyMatchMask.CheckEqualsOrChild( RestorePath, SelectPath ) or
       MyMatchMask.CheckChild( SelectPath, RestorePath )
    then
      Result.Add( RestorePath );
  end;
end;

{ MyRestoreFileUtil }

class function MyRestoreInfoReadUtil.ReadConflictPath(RestorePath,
  RestorePcID: string): TStringList;
var
  RestoreFileReadExistList : TRestoreFileReadConflictPath;
begin
  RestoreFileReadExistList := TRestoreFileReadConflictPath.Create( RestorePath, RestorePcID );
  Result := RestoreFileReadExistList.get;
  RestoreFileReadExistList.Free;
end;

class function MyRestoreInfoReadUtil.ReadIsEnable(RestorePath,
  RestorePcID: string): Boolean;
var
  RestoreItemReadIsEnable : TRestoreItemReadIsEnable;
begin
  RestoreItemReadIsEnable := TRestoreItemReadIsEnable.Create( RestorePath, RestorePcID );
  Result := RestoreItemReadIsEnable.get;
  RestoreItemReadIsEnable.Free;
end;

class function MyRestoreInfoReadUtil.ReadPassword(RestorePath,
  RestorePcID: string): string;
var
  RestoreItemReadPassword : TRestoreItemReadPassword;
begin
  RestoreItemReadPassword := TRestoreItemReadPassword.Create( RestorePath, RestorePcID );
  RestorePath := RestoreItemReadPassword.get;
  RestoreItemReadPassword.Free;
end;

class function MyRestoreInfoReadUtil.ReadRootPath(FilePath,
  RestorePcID: string): string;
var
  RestoreFileReadRootPath : TRestoreFileReadRootPath;
begin
  RestoreFileReadRootPath := TRestoreFileReadRootPath.Create( FilePath, RestorePcID );
  Result := RestoreFileReadRootPath.get;
  RestoreFileReadRootPath.Free;
end;

class function MyRestoreInfoReadUtil.ReadSavePath(RestorePath,
  RestorePcID: string): string;
var
  RestoreItemReadSavePath : TRestoreItemReadSavePath;
begin
  RestoreItemReadSavePath := TRestoreItemReadSavePath.Create( RestorePath, RestorePcID );
  Result := RestoreItemReadSavePath.get;
  RestoreItemReadSavePath.Free;
end;

{ TRestoreFileAddInfo }

function TRestoreFileAddInfo.get: Boolean;
begin
  Result := False;

    // 根不存在
  if not FindRestoreItemInfo then
    Exit;

    // 文件已存在
  if RestoreItemInfo.RestoreFileHash.ContainsKey( FilePath ) then
    Exit;

    // 记录已添加
  RestoreItemInfo.RestoreFileHash.AddString( FilePath );

  Result := True;
end;

procedure TRestoreFileAddInfo.SetPathInfo(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TRestoreFileReadRootPath }

constructor TRestoreFileReadRootPath.Create(_FilePath, _RestorePcID: string);
begin
  inherited Create;
  FilePath := _FilePath;
  RestorePcID := _RestorePcID;
end;

function TRestoreFileReadRootPath.get: string;
var
  i : Integer;
  RestorePath : string;
begin
  Result := '';
  for i := 0 to RestoreItemList.Count - 1 do
  begin
    if RestoreItemList[i].RestorePcID <> RestorePcID then
      Continue;

    RestorePath := RestoreItemList[i].RestorePath;
    if MyMatchMask.CheckEqualsOrChild( FilePath, RestorePath ) then
    begin
      Result := RestorePath;
      Break;
    end;
  end;
end;

{ TRestoreItemReadSavePath }

function TRestoreItemReadSavePath.get: string;
begin
  Result := '';
  if not FindRestoreItemInfo then
    Exit;
  Result := RestoreItemInfo.SavePath;
end;

{ TRestoreAccessInfo }

constructor TRestoreAccessInfo.Create;
begin
  MyRestoreFileInfo.EnterData;
  RestoreItemList := MyRestoreFileInfo.RestoreItemList;
end;


destructor TRestoreAccessInfo.Destroy;
begin
  MyRestoreFileInfo.LeaveData;
  inherited;
end;

{ TRestoreItemAccessInfo }

constructor TRestoreItemAccessInfo.Create(_RestorePath, _RestorePcID: string);
begin
  inherited Create;
  RestorePath := _RestorePath;
  RestorePcID := _RestorePcID;
end;

function TRestoreItemAccessInfo.FindRestoreItemInfo: Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 0 to RestoreItemList.Count - 1 do
    if ( RestoreItemList[i].RestorePath = RestorePath ) and
       ( RestoreItemList[i].RestorePcID = RestorePcID )
    then
    begin
      RestoreItemIndex := i;
      RestoreItemInfo := RestoreItemList[i];
      Result := True;
      Break;
    end;
end;

{ TRestoreItemReadPassword }

function TRestoreItemReadPassword.get: string;
begin
  Result := '';
  if not FindRestoreItemInfo then
    Exit;
  if RestoreItemInfo.IsEncrypted then
    Result := RestoreItemInfo.Password;
end;

{ TRestoreItemReadIsEnable }

function TRestoreItemReadIsEnable.get: Boolean;
begin
  Result := FindRestoreItemInfo;
end;

end.
