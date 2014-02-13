unit UMySearchDownInfo;

interface

uses UChangeInfo, UModelUtil, Generics.Collections;

type

{$Region ' 数据结构 ' }

  TSearchDownFileInfo = class
  public
    SourcePcID, SourceFilePath : string;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    constructor Create( _SourcePcID, _SourceFilePath : string );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
  end;
  TSearchDownFileList = class( TObjectList<TSearchDownFileInfo> )
  public
    function getFile( PcID, FilePath : string ) : TSearchDownFileInfo;
    procedure RemoveFile( PcID, FilePath : string );
  private
    function getFileIndex( PcID, FilePath : string ): Integer;
  end;

{$EndRegion}

{$Region ' 辅助类 ' }

    // 读取父类
  TMySearchDownReadInfo = class
  protected
    SearchDownFileList : TSearchDownFileList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 读取文件
  TMySearchDownReadFileInfo = class( TMySearchDownReadInfo )
  public
    SourcePcID, SourceFilePath : string;
  protected
    SearchDownFileInfo : TSearchDownFileInfo;
  public
    procedure SetSourceInfo( _SourcePcID, _SourceFilePath : string );
  protected
    function FindSearchDownFileInfo : Boolean;
  end;

    // 读取密码
  TMySearchDownReadPassword = class( TMySearchDownReadFileInfo )
  public
    function get : string;
  end;

    // 读取下载是否存在
  TMySearchDownReadEnable = class( TMySearchDownReadFileInfo )
  public
    function get : Boolean;
  end;

    // 读取信息 辅助类
  MySearchDownReadInfoUtil = class
  public
    class function ReadPassword( SourcePcID, SourceFilePath : string ): string;
    class function ReadIsEnable( SourcePcID, SourceFilePath : string ): Boolean;
  end;

{$EndRegion}

{$Region ' 数据变化 ' }

    // 父类
  TSearchDownFileChangeInfo = class( TChangeInfo )
  public
    SearchDownFileList : TSearchDownFileList;
  public
    procedure Update;override;
  end;

    // 修改
  TSearchDownFileWriteInfo = class( TSearchDownFileChangeInfo )
  public
    SourcePcID, SourceFilePath : string;
  protected
    SearchDownFileInfo : TSearchDownFileInfo;
  public
    constructor Create( _SourcePcID, _SourceFilePath : string );
  protected
    function FindSearchDownFileInfo : Boolean;
  end;

    // 添加
  TSearchDownFileAddInfo = class( TSearchDownFileWriteInfo )
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure Update;override;
  end;

    // 移除
  TSearchDownFileRemoveInfo = class( TSearchDownFileWriteInfo )
  public
    procedure Update;override;
  end;

    // 删除 Offline Job
  TSearchDownFileRemoveOfflineInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}


    // 数据对象
  TMySearchDownInfo = class( TMyDataChange )
  public
    SearchDownFileList : TSearchDownFileList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  MySearchDownInfo : TMySearchDownInfo;

implementation

uses UMyJobInfo;

{ TSearchDownFileChangeInfo }

procedure TSearchDownFileChangeInfo.Update;
begin
  SearchDownFileList := MySearchDownInfo.SearchDownFileList;
end;

{ TSearchDownFileInfo }

constructor TSearchDownFileInfo.Create(_SourcePcID, _SourceFilePath: string);
begin
  SourcePcID := _SourcePcID;
  SourceFilePath := _SourceFilePath;
end;

procedure TSearchDownFileInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

{ TMySearchDownInfo }

constructor TMySearchDownInfo.Create;
begin
  inherited;
  SearchDownFileList := TSearchDownFileList.Create;
  AddThread(1);
end;

destructor TMySearchDownInfo.Destroy;
begin
  SearchDownFileList.Free;
  inherited;
end;

{ TSearchDownFileAddInfo }

procedure TSearchDownFileAddInfo.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TSearchDownFileAddInfo.Update;
begin
  inherited;

    // 已存在
  if FindSearchDownFileInfo then
    Exit;

    // 创建
  SearchDownFileInfo := TSearchDownFileInfo.Create( SourcePcID, SourceFilePath );
  SearchDownFileInfo.SetEncryptInfo( IsEncrypted, Password );
  SearchDownFileList.Add( SearchDownFileInfo );
end;

{ TSearchDownFileRemoveInfo }

procedure TSearchDownFileRemoveInfo.Update;
begin
  inherited;

    // 不存在
  if not FindSearchDownFileInfo then
    Exit;

  SearchDownFileList.RemoveFile( SourcePcID, SourceFilePath );
end;

{ TSearchDownFileWriteInfo }

constructor TSearchDownFileWriteInfo.Create(_SourcePcID,
  _SourceFilePath: string);
begin
  SourcePcID := _SourcePcID;
  SourceFilePath := _SourceFilePath;
end;

function TSearchDownFileWriteInfo.FindSearchDownFileInfo: Boolean;
begin
  SearchDownFileInfo := SearchDownFileList.getFile( SourcePcID, SourceFilePath );
  Result := SearchDownFileInfo <> nil;
end;

{ TSearchDownFileList }

function TSearchDownFileList.getFile(PcID,
  FilePath: string): TSearchDownFileInfo;
var
  FileIndex : Integer;
begin
  FileIndex := getFileIndex( PcID, FilePath );
  if FileIndex >= 0 then
    Result := Self[ FileIndex ]
  else
    Result := nil;
end;

function TSearchDownFileList.getFileIndex(PcID, FilePath: string): Integer;
var
  i : Integer;
begin
  Result := -1;

  for i := 0 to Self.Count - 1 do
    if ( Self[i].SourcePcID = PcID ) and
       ( Self[i].SourceFilePath = FilePath )
    then
    begin
      Result := i;
      Break;
    end;
end;

procedure TSearchDownFileList.RemoveFile(PcID, FilePath: string);
var
  FileIndex : Integer;
begin
  FileIndex := getFileIndex( PcID, FilePath );
  if FileIndex >= 0 then
    Self.Delete( FileIndex );
end;

{ TMySearchDownReadInfo }

constructor TMySearchDownReadInfo.Create;
begin
  MySearchDownInfo.EnterData;
  SearchDownFileList := MySearchDownInfo.SearchDownFileList;
end;

destructor TMySearchDownReadInfo.Destroy;
begin
  MySearchDownInfo.LeaveData;
  inherited;
end;

{ TMySearchDownReadFileInfo }

function TMySearchDownReadFileInfo.FindSearchDownFileInfo: Boolean;
begin
  SearchDownFileInfo := SearchDownFileList.getFile( SourcePcID, SourceFilePath );
  Result := SearchDownFileInfo <> nil;
end;

procedure TMySearchDownReadFileInfo.SetSourceInfo(_SourcePcID,
  _SourceFilePath: string);
begin
  SourcePcID := _SourcePcID;
  SourceFilePath := _SourceFilePath;
end;

{ TMySearchDownReadEnable }

function TMySearchDownReadEnable.get: Boolean;
begin
  Result := FindSearchDownFileInfo;
end;

{ TMySearchDownReadPassword }

function TMySearchDownReadPassword.get: string;
begin
  Result := '';
  if not FindSearchDownFileInfo then
    Exit;
  if SearchDownFileInfo.IsEncrypted then
    Result := SearchDownFileInfo.Password;
end;

{ MySearchDownReadInfoUtil }

class function MySearchDownReadInfoUtil.ReadIsEnable(SourcePcID,
  SourceFilePath: string): Boolean;
var
  MySearchDownReadEnable : TMySearchDownReadEnable;
begin
  MySearchDownReadEnable := TMySearchDownReadEnable.Create;
  MySearchDownReadEnable.SetSourceInfo( SourcePcID, SourceFilePath );
  Result := MySearchDownReadEnable.get;
  MySearchDownReadEnable.Free;
end;

class function MySearchDownReadInfoUtil.ReadPassword(SourcePcID,
  SourceFilePath: string): string;
var
  MySearchDownReadPassword : TMySearchDownReadPassword;
begin
  MySearchDownReadPassword := TMySearchDownReadPassword.Create;
  MySearchDownReadPassword.SetSourceInfo( SourcePcID, SourceFilePath );
  Result := MySearchDownReadPassword.get;
  MySearchDownReadPassword.Free;
end;

{ TSearchDownFileRemoveOfflineInfo }

procedure TSearchDownFileRemoveOfflineInfo.Update;
var
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
  TransferJobOnlineInfo.SetOnlinePcID( '' );
  TransferJobOnlineInfo.SetJobType( JobType_SourceSearch );
  MyJobInfo.AddChange( TransferJobOnlineInfo );

  TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
  TransferJobOnlineInfo.SetOnlinePcID( '' );
  TransferJobOnlineInfo.SetJobType( JobType_BackupSearch );
  MyJobInfo.AddChange( TransferJobOnlineInfo );
end;


end.
