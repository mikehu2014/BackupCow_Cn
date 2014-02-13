unit UFileBaseInfo;

interface

uses SysUtils, Generics.Collections, UModelUtil, Classes;

type

    // 文件 的 基本信息
  TFileBaseInfo = class
  public
    FileName : string;
    FileSize : Int64;
    LastWriteTime : TDateTime;
  public
    constructor Create;
    procedure SetFileName( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _LastWriteTime : TDateTime );
    procedure SetFileBaseInfo( FileBaseInfo : TFileBaseInfo );
  end;

{$Region ' 文件基本信息 ' }

    //  临时 文件 信息
  TTempFileInfo = class( TFileBaseInfo )
  end;
  TTempFilePart = TPair< string, TTempFileInfo >;
  TTempFileHash = class( TStringDictionary< TTempFileInfo > )end;
  TTempFolderHash = class;

    // 临时 文件夹 信息
  TTempFolderInfo = class( TFileBaseInfo )
  public
    TempFileHash : TTempFileHash;
    TempFolderHash : TTempFolderHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  TTempFolderPart = TPair< string, TTempFolderInfo >;
  TTempFolderHash = class( TStringDictionary< TTempFolderInfo > )end;

     // 临时 文件副本 信息
  TTempCopyInfo = class
  public
    CopyOwner : string;  // 副本的拥有者
    Status : string;  // 副本的状态
  public
    constructor Create( _CopyOwner, _Status : string );
  end;
  TTempCopyPair = TPair< string , TTempCopyInfo >;
  TTempCopyHash = class(TStringDictionary< TTempCopyInfo >);

{$EndRegion}

{$Region ' 备份文件信息 ' }

    // 临时 备份文件 信息
  TTempBackupFileInfo = class( TFileBaseInfo )
  public
    TempCopyHash : TTempCopyHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  TTempBackupFilePair = TPair< string , TTempBackupFileInfo >;
  TTempBackupFileHash = class(TStringDictionary< TTempBackupFileInfo >);
  TTempBackupFolderHash = class;

    // 临时 备份目录 信息
  TTempBackupFolderInfo = class( TFileBaseInfo )
  public
    TempBackupFileHash : TTempBackupFileHash;
    TempBackupFolderHash : TTempBackupFolderHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  TTempBackupFolderPair = TPair< string, TTempBackupFolderInfo >;
  TTempBackupFolderHash = class(TStringDictionary< TTempBackupFolderInfo >);

{$EndRegion}

    // 过滤信息
  TFileFilterInfo = class
  public
    FilterType : string;
    FilterStr : string;
  public
    constructor Create( _FilterType, _FilterStr : string );
  end;
  TFileFilterList = class( TObjectList<TFileFilterInfo> )end;

    // 备份配置
  TBackupConfigInfo = class
  public
    CopyCount : Integer;
    IsBackupupNow, IsDisable : Boolean;
  public
    IsAuctoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    IncludeFilterList : TFileFilterList;
    ExcludeFilterList : TFileFilterList;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure SetSyncInfo( _IsAutoSync : Boolean; _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetIncludeFilterList( _IncludeFilterList : TFileFilterList );
    procedure SetExcludeFilterList( _ExcludeFilterList : TFileFilterList );
    destructor Destroy; override;
  end;

    // 本地备份配置
  TLocalBackupConfigInfo = class
  public
    IsBackupupNow, IsDisable : Boolean;
  public
    IsAuctoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public
    IncludeFilterList : TFileFilterList;
    ExcludeFilterList : TFileFilterList;
  public
    DesPathList : TStringList;
  public
    procedure SetBackupInfo( _IsBackupNow, _IsDisable : Boolean );
    procedure SetSyncInfo( _IsAutoSync : Boolean; _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetIncludeFilterList( _IncludeFilterList : TFileFilterList );
    procedure SetExcludeFilterList( _ExcludeFilterList : TFileFilterList );
    procedure SetDesPathList( _DesPathList : TStringList );
    destructor Destroy; override;
  end;

  FileFilterUtil = class
  public
    class function IsFileInclude( FilePath : string; sch : TSearchRec; FilterList : TFileFilterList ): Boolean;
    class function IsFileExclude( FilePath : string; sch : TSearchRec; FilterList : TFileFilterList ): Boolean;
  public
    class function IsFolderInclude( FolderPath : string; FilterList : TFileFilterList ): Boolean;
    class function IsFolderExclude( FolderPath : string; FilterList : TFileFilterList ): Boolean;
  end;

const
  FilterType_SmallThan = 'Smallthan';
  FilterType_LargerThan = 'LargerThan';
  FilterType_SystemFile = 'SystemFile';
  FilterType_HiddenFile = 'HiddenFile';
  FilterType_Mask = 'Mask';
  FilterType_Path = 'Path';

const
  FilterBoolean_Yes = 0;
  FilterBoolean_No = 1;

implementation

uses UMyUtil;

{ TFileBaseInfo }

constructor TFileBaseInfo.Create;
begin
  FileSize := 0;
  LastWriteTime := Now;
end;

procedure TFileBaseInfo.SetFileBaseInfo(FileBaseInfo: TFileBaseInfo);
begin
  FileName := FileBaseInfo.FileName;
  FileSize := FileBaseInfo.FileSize;
  LastWriteTime := FileBaseInfo.LastWriteTime;
end;

procedure TFileBaseInfo.SetFileInfo(_FileSize: Int64;
  _LastWriteTime: TDateTime);
begin
  FileSize := _FileSize;
  LastWriteTime := _LastWriteTime;
end;

procedure TFileBaseInfo.SetFileName(_FileName: string);
begin
  FileName := _FileName;
end;

{ TFolderInfo }

constructor TTempFolderInfo.Create;
begin
  inherited;
  TempFileHash := TTempFileHash.Create;
  TempFolderHash := TTempFolderHash.Create;
end;

destructor TTempFolderInfo.Destroy;
begin
  TempFolderHash.Free;
  TempFileHash.Free;

  inherited;
end;

{ TCheckCopyInfo }

constructor TTempCopyInfo.Create(_CopyOwner, _Status: string);
begin
  CopyOwner := _CopyOwner;
  Status := _Status;
end;

{ TCheckFileInfo }

constructor TTempBackupFileInfo.Create;
begin
  inherited Create;
  TempCopyHash := TTempCopyHash.Create;
end;

destructor TTempBackupFileInfo.Destroy;
begin
  TempCopyHash.Free;
  inherited;
end;

{ TCheckFolderInfo }

constructor TTempBackupFolderInfo.Create;
begin
  inherited;
  TempBackupFileHash := TTempBackupFileHash.Create;
  TempBackupFolderHash := TTempBackupFolderHash.Create;
end;

destructor TTempBackupFolderInfo.Destroy;
begin
  TempBackupFileHash.Free;
  TempBackupFolderHash.Free;
  inherited;
end;

{ TFilterInfo }

constructor TFileFilterInfo.Create(_FilterType, _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

{ TBackupConfigInfo }

procedure TBackupConfigInfo.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupConfigInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupConfigInfo.SetEncryptInfo(_IsEncrypt: Boolean; _Password,
  _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupConfigInfo.SetExcludeFilterList(
  _ExcludeFilterList: TFileFilterList);
begin
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TBackupConfigInfo.SetIncludeFilterList(
  _IncludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
end;

destructor TBackupConfigInfo.Destroy;
begin
  IncludeFilterList.Free;
  ExcludeFilterList.Free;
  inherited;
end;

procedure TBackupConfigInfo.SetBackupInfo(_IsBackupNow, _IsDisable: Boolean);
begin
  IsBackupupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TBackupConfigInfo.SetSyncInfo(_IsAutoSync : Boolean;
  _SyncTimeType, _SyncTimeValue: Integer);
begin
  IsAuctoSync := _IsAutoSync;
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

{ FileFilterUtil }

class function FileFilterUtil.IsFileExclude(FilePath: string; sch: TSearchRec;
  FilterList: TFileFilterList): Boolean;
var
  i : Integer;
  FilterType, FilterStr : string;
  FilterInt64 : Int64;
begin
  Result := False;

  for i := 0 to FilterList.Count - 1 do
  begin
    FilterType := FilterList[i].FilterType;
    FilterStr := FilterList[i].FilterStr;

    if FilterType = FilterType_SmallThan then  //小于
    begin
      FilterInt64 := StrToInt64Def( FilterStr, 0 );
      if sch.Size < FilterInt64 then  // 没有通过空间限制
        Result := True;
    end
    else
    if FilterType = FilterType_LargerThan then // 大于
    begin
      FilterInt64 := StrToInt64Def( FilterStr, 0 );
      if sch.Size > FilterInt64 then  // 没有通过空间限制
        Result := True;
    end
    else
    if FilterType = FilterType_SystemFile then   // 系统文件
      Result := ( sch.Attr and faSysFile ) = faSysFile
    else
    if FilterType = FilterType_HiddenFile then   // 隐藏文件
      Result := ( sch.Attr and faHidden ) = faHidden
    else
    if FilterType = FilterType_Mask then  // Mask
    begin
      if MyMatchMask.Check( sch.Name, FilterStr ) then
        Result := True;
    end
    else
    if FilterType = FilterType_Path then  // Select Path
    begin
      if MyMatchMask.CheckEqualsOrChild( FilePath, FilterStr ) then
        Result := True;
    end;

      // 已经被过滤
    if Result then
      Exit;
  end;
end;

class function FileFilterUtil.IsFileInclude(FilePath : string;  sch: TSearchRec;
  FilterList: TFileFilterList): Boolean;
var
  i : Integer;
  FilterType, FilterStr : string;
  FilterInt64 : Int64;
  HasMask, MaskIn : Boolean;
  HasMaskPath, MastInPath : Boolean;
begin
  Result := True;

  HasMask := False;
  MaskIn := False;
  HasMaskPath := False;
  MastInPath := False;
  for i := 0 to FilterList.Count - 1 do
  begin
    FilterType := FilterList[i].FilterType;
    FilterStr := FilterList[i].FilterStr;

    if FilterType = FilterType_SmallThan then  //小于
    begin
      FilterInt64 := StrToInt64Def( FilterStr, 0 );
      if sch.Size > FilterInt64 then  // 没有通过空间限制
        Result := False;
    end
    else
    if FilterType = FilterType_LargerThan then // 大于
    begin
      FilterInt64 := StrToInt64Def( FilterStr, 0 );
      if sch.Size < FilterInt64 then  // 没有通过空间限制
        Result := False;
    end
    else
    if FilterType = FilterType_Mask then  // Mask
    begin
      HasMask := True;
      MaskIn := MaskIn or MyMatchMask.Check( sch.Name, FilterStr );
    end
    else
    if FilterType = FilterType_Path then  // Select Path
    begin
      HasMaskPath := True;
      MastInPath := MastInPath or MyMatchMask.CheckEqualsOrChild( FilePath, FilterStr );
    end;

      // 已经被过滤
    if not Result then
      Exit;
  end;

    // 没有通过 Mask
  if HasMask and not MaskIn then
    Result := False;

    // 没有通过 MaskPath
  if HasMaskPath and not MastInPath then
    Result := False;;
end;

class function FileFilterUtil.IsFolderExclude(FolderPath: string;
  FilterList: TFileFilterList): Boolean;
var
  i : Integer;
  FilterType, FilterStr : string;
begin
  Result := False;
  for i := 0 to FilterList.Count - 1 do
  begin
    FilterType := FilterList[i].FilterType;
    FilterStr := FilterList[i].FilterStr;

    if FilterType = FilterType_Path then
    begin
      if MyMatchMask.CheckEqualsOrChild( FolderPath, FilterStr ) then
        Result := True;
    end;

    if Result then
      Break;
  end;
end;

class function FileFilterUtil.IsFolderInclude(FolderPath: string;
  FilterList: TFileFilterList): Boolean;
var
  i : Integer;
  FilterType, FilterStr : string;
  HasMaskPath, MastInPath : Boolean;
begin
  Result := True;
  HasMaskPath := False;
  MastInPath := False;

  for i := 0 to FilterList.Count - 1 do
  begin
    FilterType := FilterList[i].FilterType;
    FilterStr := FilterList[i].FilterStr;

    if FilterType = FilterType_Path then
    begin
      HasMaskPath := True;
      MastInPath := MastInPath or MyMatchMask.CheckEqualsOrChild( FolderPath, FilterStr );
    end;
  end;

     // 没有通过 MaskPath
  if HasMaskPath and not MastInPath then
    Result := False;
end;

{ TLocalBackupConfigInfo }

destructor TLocalBackupConfigInfo.Destroy;
begin
  DesPathList.Free;
  IncludeFilterList.Free;
  ExcludeFilterList.Free;
  inherited;
end;

procedure TLocalBackupConfigInfo.SetBackupInfo(_IsBackupNow,
  _IsDisable: Boolean);
begin
  IsBackupupNow := _IsBackupNow;
  IsDisable := _IsDisable;
end;

procedure TLocalBackupConfigInfo.SetDeleteInfo(_IsKeepDeleted: Boolean;
  _KeepEditionCount: Integer);
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TLocalBackupConfigInfo.SetDesPathList(_DesPathList: TStringList);
begin
  DesPathList := _DesPathList;
end;

procedure TLocalBackupConfigInfo.SetExcludeFilterList(
  _ExcludeFilterList: TFileFilterList);
begin
  ExcludeFilterList := _ExcludeFilterList;
end;

procedure TLocalBackupConfigInfo.SetIncludeFilterList(
  _IncludeFilterList: TFileFilterList);
begin
  IncludeFilterList := _IncludeFilterList;
end;

procedure TLocalBackupConfigInfo.SetSyncInfo(_IsAutoSync: Boolean;
  _SyncTimeType, _SyncTimeValue: Integer);
begin
  IsAuctoSync := _IsAutoSync;
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

end.
