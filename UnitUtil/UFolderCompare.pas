unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UModelUtil, UMyUtil;

type

    // 搜索的文件信息
  TScanFileInfo = class
  public
    FileName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _FileName : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  public
    function getEquals( ScanFileInfo : TScanFileInfo ): Boolean;
  end;
  TScanFilePair = TPair< string , TScanFileInfo >;
  TScanFileHash = class( TStringDictionary< TScanFileInfo > );

  {$Region ' 扫描结果信息 ' }

    // 文件比较结果
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // 添加 文件
  TScanResultAddFileInfo = class( TScanResultInfo )
  end;

    // 添加 目录
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // 删除 文件
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // 删除 目录
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

  {$EndRegion}

    // 目录比较算法
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // 文件信息
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // 目录信息
    SourceFolderHash : TStringHash;
    DesFolderHash : TStringHash;
  public   // 空间结果
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public
    constructor Create;
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
    destructor Destroy; override;
  protected
    procedure FindSourceFileInfo;virtual;abstract;
    procedure FindDesFileInfo;virtual;abstract;
    procedure FileCompare;
    procedure FolderCompare;
  protected      // 是否 停止扫描
    function CheckNextScan : Boolean;virtual;
  protected      // 过滤器
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;
    function IsFolderFilter( FolderPath : string ): Boolean;
  private        // 比较结果
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // 比较子目录
    function getScanHandle : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // 文件比较算法
  TFileScanHandle = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // 空间结果
    CompletedSize : Int64;
  public   // 文件变化结果
    ScanResultList : TScanResultList;
  public
    constructor Create( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected
    procedure FindSourceFileInfo;virtual;abstract;
    function FindDesFileInfo: Boolean;virtual;abstract;
  private        // 比较结果
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

    // 本地源扫描
  TLocalFolderSourceScanHandle = class( TFolderScanHandle )

  end;

implementation

{ TScanFileInfo }

constructor TScanFileInfo.Create(_FileName: string);
begin
  FileName := _FileName;
end;

function TScanFileInfo.getEquals(ScanFileInfo: TScanFileInfo): Boolean;
begin
  Result := ( ScanFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( FileTime, ScanFileInfo.FileTime ) );
end;

procedure TScanFileInfo.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TScanResultInfo }

constructor TScanResultInfo.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TFolderCompareHandle }

procedure TFolderScanHandle.AddFileResult(FileName : string);
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

procedure TFolderScanHandle.AddFolderResult(FolderName: string);
var
  ScanResultAddFolderInfo : TScanResultAddFolderInfo;
begin
  ScanResultAddFolderInfo := TScanResultAddFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultAddFolderInfo );
end;

function TFolderScanHandle.CheckNextScan: Boolean;
begin
  Result := True;

    // N 个文件小停一次
  Inc( SleepCount );
  if SleepCount >= 3 then
  begin
    Sleep(1);
    SleepCount := 0;
  end;
end;

procedure TFolderScanHandle.CompareChildFolder(SourceFolderName: string);
var
  ChildFolderPath : string;
  FolderScanHandle : TFolderScanHandle;
begin
  ChildFolderPath := MyFilePath.getPath( SourceFolderPath ) + SourceFolderName;
  FolderScanHandle := getScanHandle;
  FolderScanHandle.SetSourceFolderPath( ChildFolderPath );
  FolderScanHandle.SetResultList( ScanResultList );
  FolderScanHandle.FileCount := FileCount;
  FolderScanHandle.FileSize := FileSize;
  FolderScanHandle.CompletedSize := CompletedSize;
  FolderScanHandle.SleepCount := SleepCount;
  FolderScanHandle.ScanTime := ScanTime;
  FolderScanHandle.Update;
  FileCount := FolderScanHandle.FileCount;
  FileSize := FolderScanHandle.FileSize;
  CompletedSize := FolderScanHandle.CompletedSize;
  SleepCount := FolderScanHandle.SleepCount;
  ScanTime := FolderScanHandle.ScanTime;
  FolderScanHandle.Free;
end;

constructor TFolderScanHandle.Create;
begin
  SourceFileHash := TScanFileHash.Create;
  DesFileHash := TScanFileHash.Create;
  SourceFolderHash := TStringHash.Create;
  DesFolderHash := TStringHash.Create;
  FileCount := 0;
  FileSize := 0;
  CompletedSize := 0;
  SleepCount := 0;
  ScanTime := Now;
end;

destructor TFolderScanHandle.Destroy;
begin
  SourceFileHash.Free;
  DesFileHash.Free;
  SourceFolderHash.Free;
  DesFolderHash.Free;
  inherited;
end;

procedure TFolderScanHandle.FileCompare;
var
  p : TScanFilePair;
  FileName : string;
begin
    // 遍历 源文件
  for p in SourceFileHash do
  begin
      // 检查是否继续扫描
    if not CheckNextScan then
      Break;

      // 添加到统计信息
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

    FileName := p.Value.FileName;

      // 目标文件不存在
    if not DesFileHash.ContainsKey( FileName ) then
    begin
      AddFileResult( FileName );
      Continue;
    end;

      // 目标文件与源文件不一致
    if not p.Value.getEquals( DesFileHash[ FileName ] ) then
    begin
      RemoveFileResult( FileName ); // 先删除
      AddFileResult( FileName );  // 后添加
    end
    else  // 目标文件与源文件一致
      CompletedSize := CompletedSize + p.Value.FileSize;

      // 删除目标文件
    DesFileHash.Remove( FileName );
  end;

    // 遍历目标文件
  for p in DesFileHash do
    RemoveFileResult( p.Value.FileName );  // 删除目标文件
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TStringPart;
  FolderName : string;
begin
    // 遍历源目录
  for p in SourceFolderHash do
  begin
    FolderName := p.Value;

      // 不存在目标目录，则创建
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName )
    else
      DesFolderHash.Remove( FolderName );

      // 比较子目录
    CompareChildFolder( FolderName );
  end;

    // 遍历目标目录
  for p in DesFolderHash do
    RemoveFolderResult( p.Value );
end;

function TFolderScanHandle.getChildPath(ChildName: string): string;
begin
  Result := MyFilePath.getPath( SourceFolderPath ) + ChildName;
end;

procedure TFolderScanHandle.RemoveFileResult(FileName : string);
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( getChildPath( FileName ) );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFolderScanHandle.RemoveFolderResult(FolderName: string);
var
  ScanResultRemoveFolderInfo : TScanResultRemoveFolderInfo;
begin
  ScanResultRemoveFolderInfo := TScanResultRemoveFolderInfo.Create( getChildPath( FolderName ) );
  ScanResultList.Add( ScanResultRemoveFolderInfo );
end;

procedure TFolderScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFolderScanHandle.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TFolderScanHandle.Update;
begin
    // 找源文件信息
  FindSourceFileInfo;

    // 找目标文件信息
  FindDesFileInfo;

    // 文件比较
  FileCompare;

    // 目录比较
  FolderCompare;
end;

{ TFileScanHandle }

procedure TFileScanHandle.AddFileResult;
var
  ScanResultAddFileInfo : TScanResultAddFileInfo;
begin
  ScanResultAddFileInfo := TScanResultAddFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultAddFileInfo );
end;

constructor TFileScanHandle.Create(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
  CompletedSize := 0;
end;

function TFileScanHandle.IsEqualsDes: Boolean;
begin
  Result := ( SourceFileSize = DesFileSize ) and
            ( MyDatetime.Equals( SourceFileTime, DesFileTime ) );
end;

procedure TFileScanHandle.RemoveFileResult;
var
  ScanResultRemoveFileInfo : TScanResultRemoveFileInfo;
begin
  ScanResultRemoveFileInfo := TScanResultRemoveFileInfo.Create( SourceFilePath );
  ScanResultList.Add( ScanResultRemoveFileInfo );
end;

procedure TFileScanHandle.SetResultList(_ScanResultList: TScanResultList);
begin
  ScanResultList := _ScanResultList;
end;

procedure TFileScanHandle.Update;
begin
    // 源文件信息
  FindSourceFileInfo;

    // 目标文件不存在
  if not FindDesFileInfo then
  begin
    AddFileResult;
    Exit;
  end;

    // 目标文件与源文件不一致
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
    CompletedSize := SourceFileSize;
end;

end.
