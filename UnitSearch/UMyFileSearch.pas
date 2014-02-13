unit UMyFileSearch;

interface

uses UChangeInfo, Classes, UFileBaseInfo, UMyClient, UMyUtil, SysUtils, SyncObjs,
     UModelUtil, Generics.Collections, uDebug, Windows;

type

{$Region ' 递归文件搜索 ' }

   // 递归 搜索文件
  TFolderSearchBase = class
  private
    SearchCount : Integer;
    SearchNum : Integer;
  private
    FolderPath, ScanPath : string;
    SearchPcID, SearchName : string;
    IsSearchAllFile : Boolean;
  public
    constructor Create;
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetFolderPath( _FolderPath : string );
    procedure SetSearchInfo( _SearchPcID, _SearchName : string );
    procedure SetSearchCount( _SearchCount : Integer );
    procedure Update;
  protected
    function getSearchResultMsg : TFileSearchResultBaseMsg;virtual;abstract;
    function getFolderSearch : TFolderSearchBase;virtual;abstract;
    function CheckNextSearch : Boolean;virtual;
  protected
    procedure FindScanPath;virtual;abstract;
    procedure CheckFile;
    procedure CheckFolder;
  private
    function IsSearchFile( FileName : string ): Boolean;
    procedure SendSearchResult( FilePath : string; FileSize : Int64; FileTime : TDateTime );
    procedure CheckNextFolder( FolderName : string );
  end;

    // 搜索 备份文件
  TBackupFolderSearch = class( TFolderSearchBase )
  protected
    procedure FindScanPath;override;
    function getSearchResultMsg : TFileSearchResultBaseMsg;override;
    function getFolderSearch : TFolderSearchBase;override;
    function CheckNextSearch : Boolean;override;
  end;

    // 搜索 云文件
  TCloudFolderSearch = class( TFolderSearchBase )
  private
    CloudPcID : string;
    CloudPcPath : string;
  public
    procedure SetCloudPcID( _CloudPcID : string );
    procedure SetCloudPcPath( _CloudPcPath : string );
  protected
    procedure FindScanPath;override;
    function getSearchResultMsg : TFileSearchResultBaseMsg;override;
    function getFolderSearch : TFolderSearchBase;override;
    function CheckNextSearch : Boolean;override;
  end;

    // 搜索 恢复 云文件
  TRestoreCloudFolderSearch = class( TFolderSearchBase )
  private
    CloudPcPath : string;
  public
    procedure SetCloudPcPath( _CloudPcPath : string );
  protected
    procedure FindScanPath;override;
    function getSearchResultMsg : TFileSearchResultBaseMsg;override;
    function getFolderSearch : TFolderSearchBase;override;
    function CheckNextSearch : Boolean;override;
  end;

{$EndRegion}


{$Region ' 网络文件搜索 请求 ' }

  {$Region ' 文件请求 ' }

    // 开始 搜索
  TFileSearchStartInfo = class( TChangeInfo )
  public
    SearchName : string;
    LocationIDList, OwnerIDList : TStringList;
    FileType : string;
  private
    SearchNum : Integer;
  public
    constructor Create( _SearchName : string );
    procedure SetFileType( _FileType : string );
    procedure SetOwnerIDList( _OwnerIDList : TStringList );
    procedure SetLocationIDList( _LocationIDList : TStringList );
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure SearchPcSource( PcID : string);
    procedure SearchPcBackupCopy( PcID : string );
  private
    procedure StartSearchFace;
    procedure StopSearchFace;
    procedure AddSourceReqPc( PcID : string );
    procedure AddBackupCopyReqPc( PcID : string );
  end;

    // 结束 搜索
  TFileSearchStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure SendCancelToNetworkPc;
    procedure SearchCompleteFace;
    procedure ClearReqPcList;
  end;

  {$EndRegion}

  {$Region ' 文件搜索结果 ' }

     // 父类
  TFileSearchResultInfo = class( TChangeInfo )
  public
    SearchNum : Integer;
    LocationID : string;
    FilePath : string;
  public
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetLocationID( _LocationID : string );
    procedure SetFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;

    // 网络文件
  TNetworkFileSearchResultInfo = class( TFileSearchResultInfo )
  private
    BackupPath : string;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
  public
    procedure Update;override;
  protected
    function getFileType : string;virtual;abstract;
    function getOwnerID : string;virtual;abstract;
  private
    procedure FindBackupPathInfo;
  end;

    // 源文件
  TSourceFileSearchResultInfo = class( TNetworkFileSearchResultInfo )
  protected
    function getFileType : string;override;
    function getOwnerID : string;override;
  end;

    // 备份文件
  TBackupFileSearchResultinfo = class( TNetworkFileSearchResultInfo )
  public
    OwnerID : string;
  public
    procedure SetOwnerID( _OwnerID : string );
  protected
    function getFileType : string;override;
    function getOwnerID : string;override;
  end;

  {$EndRegion}

  {$Region ' 文件结果命令 ' }

      // Pc 文件搜索 完成 父类
  TFileSearchCompleteInfo = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure SearchCompleteFace;  // 开启界面
  end;

    // Pc 源文件搜索 完成
  TSourceFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  end;

    // Pc 备份文件搜索 完成
  TBackupFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  end;

    // Pc 源文件 和 备份文件搜索 完成
  TAllFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  private
    procedure StopSourceFile;
    procedure StopBackupCopyFile;
  end;

    // 所有 Pc 源文件 和 备份文件搜索 完成
  TAllPcFileSearchCompleteInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure ClearReqList;
    procedure SearchCompleteFace;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络文件搜索 扫描 ' }

  {$Region ' 文件扫描 ' }

    // 文件 搜索开始 父类
  TFileScanStartInfo = class( TChangeInfo )
  public
    SearchNum : Integer;
    SearchPcID : string;
  public
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetSearchPcID( _SearchPcID : string );
    procedure Update;override;
  protected
    procedure AddSearchScan;virtual;abstract;
    procedure FindPathList;virtual;abstract;
    procedure ScanPathList;virtual;abstract;
    procedure SendSearchComplete;virtual;abstract;
    procedure DeleteSearchScan;virtual;abstract;
  end;

    // 网络文件 搜索开始
  TNetworkFileScanStartInfo = class( TFileScanStartInfo )
  public
    SearchName : string;
  public
    procedure SetSearchName( _SearchName : string );
  end;

    // 源文件 搜索开始
  TSourceFileScanStartInfo = class( TNetworkFileScanStartInfo )
  public
    BackupPathList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure AddSearchScan;override;
    procedure FindPathList;override;
    procedure ScanPathList;override;
    procedure SendSearchComplete;override;
    procedure DeleteSearchScan;override;
  end;

    // 副本文件 搜索开始
  TBackupFileScanStartInfo = class( TNetworkFileScanStartInfo )
  private
    CloudPcPathList : TStringList;
    BackupPcIDList : TStringList;
  public
    constructor Create;
    procedure SetBackupPcIDList( _BackupPcIDList : TStringList );
    destructor Destroy; override;
  protected
    procedure AddSearchScan;override;
    procedure FindPathList;override;
    procedure ScanPathList;override;
    procedure SendSearchComplete;override;
    procedure DeleteSearchScan;override;
  private
    procedure FindCloudPathExistBackupPcID( CloudPath : string );
  end;

  {$EndRegion}

  {$Region ' 扫描命令 ' }

    // Pc 取消 搜索
  TFileSearchCancelInfo = class( TChangeInfo )
  public
    SearchPcID : string;
  public
    constructor Create( _SearchPcID : string );
    procedure Update;override;
  end;

    // 服务器 离线
    // 所有 Pc 取消 搜索
  TAllPcFileSearchCancelInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 网络文件搜索 对象 ' }

    // 发出文件请求的 Pc 信息
  TPcFileReqInfo = class
  public
    PcLock : TCriticalSection;
    PcIDHash : TStringHash;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddPcID( PcID : string );
    function IsExistPc( PcID : string ): Boolean;
    function RemovePcID( PcID : string ): Boolean;
    function IsEmpty : Boolean;
    procedure Clear;
  end;

    // 文件搜索 父类
  TMyFileSearchBase = class( TMyChangeBase )
  public
    PcSourceFileReqInfo : TPcFileReqInfo;
    PcBackupFileReqInfo : TPcFileReqInfo;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 文件搜索 请求 和 接收结果
  TMyFileSearchReq = class( TMyFileSearchBase )
  public
    constructor Create;
  end;

    // 文件搜索 扫描
  TMyFileSearchScan = class( TMyFileSearchBase )
  public
    constructor Create;
  end;

{$EndRegion}


{$Region ' 恢复文件搜索 请求 ' }

  {$Region ' 文件请求 ' }

    // 恢复 路径信息
  TRestorePathInfo = class
  public
    FullPath : string;
    PathType : string;
  public
    constructor Create( _FullPath, _PathType : string );
  end;
  TRestorePathPair = TPair< string , TRestorePathInfo >;
  TRestorePathHash = class(TStringDictionary< TRestorePathInfo >);

    // 添加 恢复文件 请求
  TRestoreFileSearchAddInfo = class( TChangeInfo )
  public
    RestorePcID : string;
    RestorePathHash : TRestorePathHash;
  private
    SearchNum : Integer;
    OnlinePcIDList : TStringList;
  public
    constructor Create( _RestorePcID : string );
    procedure AddRestorePath( FullPath, PathType : string );
    procedure Update;override;
    destructor Destroy; override;
  private
    function getOnlinePcIDList : TStringList;
    procedure SendRestoreFileMsg( PcID : string );
  end;

      // 结束 恢复
  TResotreFileSearchStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure SendCancelToNetworkPc;
    procedure ClearReqPcList;
  end;

  {$EndRegion}

  {$Region ' 文件搜索结果 ' }

  TRestoreFileSearchResultinfo = class( TFileSearchResultInfo )
  public
    procedure Update;override;
  private
    procedure AddToRestoreForm;
    procedure AddToQuickRestore;
  end;

  {$EndRegion}

  {$Region ' 文件结果命令 ' }

    // 父类
  TRestoreFileSeachCompletedBase = class( TChangeInfo )
  protected
    procedure RestoreCompleted;
  private
    procedure RestoreFormCompleted;
    procedure RestoreFileCompelted;
  end;

    // Pc 恢复文件搜索 完成
  TRestoreFileSearchCompleteInfo = class( TRestoreFileSeachCompletedBase )
  private
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // 所有 Pc 恢复文件搜索 完成
  TAllPcRestoreFileSearchCompleteInfo = class( TRestoreFileSeachCompletedBase )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件搜索 扫描 ' }

  {$Region ' 文件扫描 '}

    // 恢复文件 搜索开始
  TRestoreFileScanStartInfo = class( TFileScanStartInfo )
  public
    RestorePcID : string;
    RestorePathHash : TRestorePathHash;
  private
    CloudPcPathList : TStringList;
  public
    constructor Create;
    procedure SetRestorePcID( _RestorePcID : string );
    procedure AddRestorePath( FullPath, PathType : string );
    destructor Destroy; override;
  protected
    procedure AddSearchScan;override;
    procedure FindPathList;override;
    procedure ScanPathList;override;
    procedure SendSearchComplete;override;
    procedure DeleteSearchScan;override;
  end;

  {$EndRegion}

  {$Region ' 扫描命令 ' }

      // Pc 取消 搜索
  TRestoreFileSearchCancelInfo = class( TChangeInfo )
  public
    SearchPcID : string;
  public
    constructor Create( _SearchPcID : string );
    procedure Update;override;
  end;

    // 服务器 离线
    // 所有 Pc 取消 搜索
  TAllPcRestoreFileSearchCancelInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' 恢复文件搜索 对象 ' }

    // 恢复文件 父类
  TMyFileResotreBase = class( TMyChangeBase )
  public
    PcRestoreFileReqInfo : TPcFileReqInfo;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // 恢复文件 请求
  TMyFileRestoreReq = class( TMyFileResotreBase )
  public
    constructor Create;
  end;

    // 恢复文件 扫描
  TMyFileRestoreScan = class( TMyFileResotreBase )
  public
    constructor Create;
  end;

{$EndRegion}

const
  SearchCount_Sleep = 10;
  ThreadCount_Scan = 2;

var
  Number_FileSearch : Integer = 0; // 搜索的序号
  Number_FileRestore : Integer = 0; // 恢复的序号
  RestoreSearch_IsQuick : Boolean = False; // 是否快速恢复
  RestoreQuick_RestorePcID : string = ''; // 快速恢复的 Pc ID

    // 网络 文件搜索
  MyFileSearchReq : TMyFileSearchReq;
  MyFileSearchScan : TMyFileSearchScan;

    // 恢复 文件搜索
  MyFileRestoreReq : TMyFileRestoreReq;
  MyFileRestoreScan : TMyFileRestoreScan;

implementation

uses UMyBackupInfo,  UMyNetPcInfo, UMyServer, UMyCloudPathInfo, USearchFileFace,
     URestoreFileFace, UMyRestoreFileInfo, UMyRestoreFileControl;

{ TScanSourceFileHandle }

procedure TSourceFileScanStartInfo.AddSearchScan;
begin
  MyFileSearchScan.PcSourceFileReqInfo.AddPcID( SearchPcID );
end;

constructor TSourceFileScanStartInfo.Create;
begin
  BackupPathList := TStringList.Create;
end;

procedure TSourceFileScanStartInfo.DeleteSearchScan;
begin
  MyFileSearchScan.PcSourceFileReqInfo.RemovePcID( SearchPcID )
end;

destructor TSourceFileScanStartInfo.Destroy;
begin
  BackupPathList.Free;
  inherited;
end;

procedure TSourceFileScanStartInfo.FindPathList;
var
  NetworkBackupPathList : TBackupPathList;
  i : Integer;
  FullPath : string;
begin
  MyBackupFileInfo.EnterData;
  NetworkBackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to NetworkBackupPathList.Count - 1 do
  begin
    FullPath := NetworkBackupPathList[i].FullPath;
    BackupPathList.Add( FullPath );
  end;
  MyBackupFileInfo.LeaveData;
end;

procedure TSourceFileScanStartInfo.ScanPathList;
var
  i : Integer;
  BackupPath : string;
  BackupFolderSearch : TBackupFolderSearch;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    BackupFolderSearch := TBackupFolderSearch.Create;
    BackupFolderSearch.SetFolderPath( BackupPath );
    BackupFolderSearch.SetSearchInfo( SearchPcID, SearchName );
    BackupFolderSearch.SetSearchNum( SearchNum );
    BackupFolderSearch.SetSearchCount( 0 );
    BackupFolderSearch.Update;
    BackupFolderSearch.Free;
  end
end;

procedure TSourceFileScanStartInfo.SendSearchComplete;
var
  SourceFileSearchCompleteMsg : TSourceFileSearchCompleteMsg;
begin
  SourceFileSearchCompleteMsg := TSourceFileSearchCompleteMsg.Create;
  SourceFileSearchCompleteMsg.SetPcID( PcInfo.PcID );

  MyClient.SendMsgToPc( SearchPcID, SourceFileSearchCompleteMsg );
end;

{ TBackupFolderSearch }

procedure TFolderSearchBase.CheckFolder;
var
  sch : TSearchRec;
  SearcFullPath, FileName , FilePath: string;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检查下一层目录
      if DirectoryExists( SearcFullPath + FileName )  then
        CheckNextFolder( FileName )
      else   // 是否 要找的文件
      if IsSearchFile( FileName ) then
      begin
        FilePath := MyFilePath.getPath( FolderPath ) + FileName;
        FileSize := sch.Size; // 空间信息
          // 获取修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 发送结果
        SendSearchResult( FilePath, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

procedure TFolderSearchBase.CheckNextFolder(FolderName: string);
var
  ChildFolderPath : string;
  FolderSearchBase : TFolderSearchBase;
begin
    // 子目录 路径
  ChildFolderPath := MyFilePath.getPath( FolderPath ) + FolderName;

    // 搜索 下一层
  FolderSearchBase := getFolderSearch;
  FolderSearchBase.SetFolderPath( ChildFolderPath );
  FolderSearchBase.SetSearchInfo( SearchPcID, SearchName );
  FolderSearchBase.SetSearchNum( SearchNum );
  FolderSearchBase.SetSearchCount( SearchCount );
  SearchCount := FolderSearchBase.SearchCount;
  FolderSearchBase.Update;
  FolderSearchBase.Free;
end;

function TFolderSearchBase.CheckNextSearch: Boolean;
begin
  Inc( SearchCount );
  if SearchCount >= SearchCount_Sleep then
  begin
    Sleep(1);
    SearchCount := 0;
  end;
end;

constructor TFolderSearchBase.Create;
begin
  SearchCount := 0;
end;

function TFolderSearchBase.IsSearchFile(FileName: string): Boolean;
begin
  Result := IsSearchAllFile or MyMatchMask.Check( FileName, SearchName );
end;

procedure TFolderSearchBase.CheckFile;
var
  FileName : string;
  FileSize : Int64;
  FileTime : TDateTime;
begin
    // 提取 文件名
  FileName := ExtractFileName( ScanPath );

    // 判断 是否 要找的文件
  if not IsSearchFile( FileName ) then
    Exit;

    // 提取文件信息
  FileSize := MyFileInfo.getFileSize( ScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // 发送结果
  SendSearchResult( FolderPath, FileSize, FileTime );
end;

procedure TFolderSearchBase.SendSearchResult(FilePath: string; FileSize: Int64;
  FileTime: TDateTime);
var
  FileSearchResultBaseMsg : TFileSearchResultBaseMsg;
begin
  FilePath := MyFilePath.getUploadPath( FilePath );

    // 搜索 源文件 结果
  FileSearchResultBaseMsg := getSearchResultMsg;
  FileSearchResultBaseMsg.SetPcID( PcInfo.PcID );
  FileSearchResultBaseMsg.SetSearchNum( SearchNum );
  FileSearchResultBaseMsg.SetFilePath( FilePath );
  FileSearchResultBaseMsg.SetFileInfo( FileSize, FileTime );

    // 添加到客户端发送队列
  MyClient.SendMsgToPc( SearchPcID, FileSearchResultBaseMsg );
end;

procedure TFolderSearchBase.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

procedure TFolderSearchBase.SetSearchCount(_SearchCount: Integer);
begin
  SearchCount := _SearchCount;
end;

procedure TFolderSearchBase.SetSearchInfo(_SearchPcID,_SearchName: string);
begin
  SearchPcID := _SearchPcID;
  SearchName := _SearchName;
  IsSearchAllFile := SearchName = '';
end;

procedure TFolderSearchBase.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

procedure TFolderSearchBase.Update;
begin
    // 获取 扫描磁盘路径
  FindScanPath;

    // 扫描 文件/目录
  if FileExists( ScanPath ) then
    CheckFile
  else
    CheckFolder;
end;

{ TBackupFolderSearch }

function TBackupFolderSearch.CheckNextSearch: Boolean;
begin
  inherited;

  Result := MyFileSearchScan.PcSourceFileReqInfo.IsExistPc( SearchPcID );
  Result := Result and MyFileSearchScan.IsRun;
end;

procedure TBackupFolderSearch.FindScanPath;
begin
  ScanPath := FolderPath;
end;

function TBackupFolderSearch.getFolderSearch: TFolderSearchBase;
begin
  Result := TBackupFolderSearch.Create;
end;

function TBackupFolderSearch.getSearchResultMsg:TFileSearchResultBaseMsg;
begin
  Result := TSourceFileSearchResultMsg.Create;
end;

{ TCloudFolderSearch }

function TCloudFolderSearch.CheckNextSearch: Boolean;
begin
  inherited;

  Result := MyFileSearchScan.PcBackupFileReqInfo.IsExistPc( SearchPcID );
  Result := Result and MyFileSearchScan.IsRun;
end;

procedure TCloudFolderSearch.FindScanPath;
begin
  if FolderPath = '' then
    ScanPath := CloudPcPath
  else
    ScanPath := MyFilePath.getPath( CloudPcPath ) + FolderPath;
end;

function TCloudFolderSearch.getFolderSearch: TFolderSearchBase;
var
  CloudFolderSearch : TCloudFolderSearch;
begin
  CloudFolderSearch := TCloudFolderSearch.Create;
  CloudFolderSearch.SetCloudPcID( CloudPcID );
  CloudFolderSearch.SetCloudPcPath( CloudPcPath );
  Result := CloudFolderSearch;
end;

function TCloudFolderSearch.getSearchResultMsg: TFileSearchResultBaseMsg;
var
  FileSearchBackupResultMsg : TBackupFileSearchResultMsg;
begin
  FileSearchBackupResultMsg := TBackupFileSearchResultMsg.Create;
  FileSearchBackupResultMsg.SetOwnerID( CloudPcID );
  Result := FileSearchBackupResultMsg;
end;

procedure TCloudFolderSearch.SetCloudPcID(_CloudPcID: string);
begin
  CloudPcID := _CloudPcID;
end;

procedure TCloudFolderSearch.SetCloudPcPath(_CloudPcPath: string);
begin
  CloudPcPath := _CloudPcPath;
end;

{ TScanBackupCopyFileHandle }

procedure TBackupFileScanStartInfo.AddSearchScan;
begin
  MyFileSearchScan.PcBackupFileReqInfo.AddPcID( SearchPcID );
end;

constructor TBackupFileScanStartInfo.Create;
begin
  CloudPcPathList := TStringList.Create;
  BackupPcIDList := TStringList.Create;
end;

procedure TBackupFileScanStartInfo.DeleteSearchScan;
begin
  MyFileSearchScan.PcBackupFileReqInfo.RemovePcID( SearchPcID );
end;

destructor TBackupFileScanStartInfo.Destroy;
begin
  BackupPcIDList.Free;
  CloudPcPathList.Free;
  inherited;
end;

procedure TBackupFileScanStartInfo.FindPathList;
var
  i : Integer;
  CloudPathList : TStringList;
  CloudPath : string;
begin
    // 读取 所有云路径
  CloudPathList := MyCloudPathInfoUtil.ReadCloudPathList;
    // 判断 每一条云路径 拥有者
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i];
    FindCloudPathExistBackupPcID( CloudPath );
  end;
  CloudPathList.Free;
end;

procedure TBackupFileScanStartInfo.FindCloudPathExistBackupPcID(
  CloudPath: string);
var
  CloudPathOwnerList : TStringList;
  i : Integer;
  BackupPcID, CloudPcPath : string;
begin
    // 获取 云路径的 拥有者
  CloudPathOwnerList := MyFilePath.getChildFolderList( CloudPath );
    // 需要 搜索的拥有者 是否存在云路径上
  for i := 0 to BackupPcIDList.Count - 1 do
  begin
    BackupPcID := BackupPcIDList[i];
    if CloudPathOwnerList.IndexOf( BackupPcID ) >= 0 then
    begin
      CloudPcPath := MyFilePath.getPath( CloudPath ) + BackupPcID;
      CloudPcPathList.Add( CloudPcPath );
    end;
  end;
  CloudPathOwnerList.Free;
end;

procedure TBackupFileScanStartInfo.ScanPathList;
var
  i : Integer;
  CloudPcID, CloudPcPath : string;
  CloudFolderSearch : TCloudFolderSearch;
begin
  for i := 0 to CloudPcPathList.Count - 1 do
  begin
    CloudPcPath := CloudPcPathList[i];
    CloudPcID := ExtractFileName( CloudPcPath );

    CloudFolderSearch := TCloudFolderSearch.Create;
    CloudFolderSearch.SetCloudPcID( CloudPcID );
    CloudFolderSearch.SetCloudPcPath( CloudPcPath );
    CloudFolderSearch.SetFolderPath('');
    CloudFolderSearch.SetSearchInfo( SearchPcID, SearchName  );
    CloudFolderSearch.SetSearchNum( SearchNum );
    CloudFolderSearch.SetSearchCount( 0 );
    CloudFolderSearch.Update;
    CloudFolderSearch.Free;
  end;
end;

procedure TBackupFileScanStartInfo.SendSearchComplete;
var
  BackupCopyFileSearchCompleteMsg : TBackupCopyFileSearchCompleteMsg;
begin
  BackupCopyFileSearchCompleteMsg := TBackupCopyFileSearchCompleteMsg.Create;
  BackupCopyFileSearchCompleteMsg.SetPcID( PcInfo.PcID );

  MyClient.SendMsgToPc( SearchPcID, BackupCopyFileSearchCompleteMsg );
end;

procedure TBackupFileScanStartInfo.SetBackupPcIDList(
  _BackupPcIDList: TStringList);
var
  i : Integer;
begin
  for i := 0 to _BackupPcIDList.Count - 1 do
    BackupPcIDList.Add( _BackupPcIDList[i] );
end;

{ TScanFileHandle }

procedure TFileScanStartInfo.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

procedure TFileScanStartInfo.SetSearchPcID(_SearchPcID: string);
begin
  SearchPcID := _SearchPcID;
end;

procedure TFileScanStartInfo.Update;
begin
  AddSearchScan;

  FindPathList;

  ScanPathList;

  SendSearchComplete;
end;

{ TSearchFileResultInfo }

procedure TFileSearchResultInfo.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TFileSearchResultInfo.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TFileSearchResultInfo.SetLocationID(_LocationID: string);
begin
  LocationID := _LocationID;
end;

procedure TFileSearchResultInfo.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

{ TSearchBackupCopyFileResultinfo }

function TBackupFileSearchResultinfo.getFileType: string;
begin
  Result := FileType_BackupCopy;
end;

function TBackupFileSearchResultinfo.getOwnerID: string;
begin
  Result := OwnerID;
end;

procedure TBackupFileSearchResultinfo.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

{ TSearchSourceFileResultInfo }

function TSourceFileSearchResultInfo.getFileType: string;
begin
  Result := FileType_SourceFile;
end;

function TSourceFileSearchResultInfo.getOwnerID: string;
begin
  Result := LocationID;
end;

{ TFileSearchAddInfo }

procedure TFileSearchStartInfo.AddBackupCopyReqPc(PcID: string);
begin
  MyFileSearchReq.PcBackupFileReqInfo.AddPcID( PcID );
end;

procedure TFileSearchStartInfo.AddSourceReqPc(PcID: string);
begin
  MyFileSearchReq.PcSourceFileReqInfo.AddPcID( PcID );
end;

constructor TFileSearchStartInfo.Create(_SearchName: string);
begin
  SearchName := _SearchName;
  LocationIDList := TStringList.Create;
  OwnerIDList := TStringList.Create;
end;

destructor TFileSearchStartInfo.Destroy;
begin
  LocationIDList.Free;
  OwnerIDList.Free;
  inherited;
end;

procedure TFileSearchStartInfo.SearchPcBackupCopy(PcID: string);
var
  BackupCopyFileSearchReqMsg : TBackupFileSearchReqMsg;
  i : Integer;
begin
    // 添加到请求队列
  AddBackupCopyReqPc( PcID );

    // 发送 请求命令
  BackupCopyFileSearchReqMsg := TBackupFileSearchReqMsg.Create;
  BackupCopyFileSearchReqMsg.SetPcID( PcInfo.PcID );
  BackupCopyFileSearchReqMsg.SetFileOwnerList( OwnerIDList );
  BackupCopyFileSearchReqMsg.SetSearchNum( SearchNum );
  BackupCopyFileSearchReqMsg.SetSearchFileName( SearchName );
  MyClient.SendMsgToPc( PcID, BackupCopyFileSearchReqMsg );
end;

procedure TFileSearchStartInfo.SearchPcSource(PcID: string);
var
  SourceFileSearchReqMsg : TSourceFileSearchReqMsg;
begin
    // 添加到请求 Pc 队列
  AddSourceReqPc( PcID );

    // 发送 请求命令
  SourceFileSearchReqMsg := TSourceFileSearchReqMsg.Create;
  SourceFileSearchReqMsg.SetPcID( PcInfo.PcID );
  SourceFileSearchReqMsg.SetSearchNum( SearchNum );
  SourceFileSearchReqMsg.SetSearchFileName( SearchName );
  MyClient.SendMsgToPc( PcID, SourceFileSearchReqMsg );
end;

procedure TFileSearchStartInfo.SetFileType(_FileType: string);
begin
  FileType := _FileType;
end;

procedure TFileSearchStartInfo.SetLocationIDList(_LocationIDList: TStringList);
var
  i : Integer;
begin
  for i := 0 to _LocationIDList.Count - 1 do
    LocationIDList.Add( _LocationIDList[i] );
end;

procedure TFileSearchStartInfo.SetOwnerIDList(_OwnerIDList: TStringList);
var
  i : Integer;
begin
  for i := 0 to _OwnerIDList.Count - 1 do
    OwnerIDList.Add( _OwnerIDList[i] );
end;

procedure TFileSearchStartInfo.StartSearchFace;
var
  SearchFileStartInfo : TSearchFileLvStartInfo;
begin
  SearchFileStartInfo := TSearchFileLvStartInfo.Create;
  MySearchFileFace.AddChange( SearchFileStartInfo );
end;

procedure TFileSearchStartInfo.StopSearchFace;
var
  SearchFileLvStopInfo : TSearchFileLvStopInfo;
begin
  SearchFileLvStopInfo := TSearchFileLvStopInfo.Create;
  MySearchFileFace.AddChange( SearchFileLvStopInfo );
end;

procedure TFileSearchStartInfo.Update;
var
  IsSearchSource, IsSearchBackupCopy : Boolean;
  IsStartSearch : Boolean;
  i : Integer;
  PcID : string;
begin
    // 设置 搜索文件 号码
  Inc( Number_FileSearch );
  SearchNum := Number_FileSearch;

    // 开始搜索文件 界面
  StartSearchFace;

    // 搜索的 文件类型
  IsSearchSource := ( FileType = FileType_AllTypes ) or
                    ( FileType = FileType_SourceFile );

  IsSearchBackupCopy := ( FileType = FileType_AllTypes ) or
                        ( FileType = FileType_BackupCopy );

    // 发送 搜索命令
  IsStartSearch := False;
  for i := 0 to LocationIDList.Count - 1 do
  begin
    PcID := LocationIDList[i];
    if IsSearchSource and ( OwnerIDList.IndexOf( PcID ) >= 0 ) then
    begin
      IsStartSearch := True;
      SearchPcSource( PcID );
    end;
    if IsSearchBackupCopy and ( OwnerIDList.Count > 0 ) then
    begin
      IsStartSearch := True;
      SearchPcBackupCopy( PcID );
    end;
  end;

    // 没有进行搜索
  if not IsStartSearch then
    StopSearchFace
end;

{ TMyFileSearchReq }


constructor TMyFileSearchBase.Create;
begin
  inherited;

  PcSourceFileReqInfo := TPcFileReqInfo.Create;
  PcBackupFileReqInfo := TPcFileReqInfo.Create;
end;

destructor TMyFileSearchBase.Destroy;
begin
  IsRun := False;
  StopThread;

  PcSourceFileReqInfo.Free;
  PcBackupFileReqInfo.Free;
  inherited;
end;

{ TMyFileSearchReq }

constructor TMyFileSearchReq.Create;
begin
  inherited;
  AddThread( 1 );
end;

{ TFileSearchStopInfo }

constructor TFileSearchCompleteInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TFileSearchCompleteInfo.SearchCompleteFace;
var
  SearchFileLvStopInfo : TSearchFileLvStopInfo;
begin
  SearchFileLvStopInfo := TSearchFileLvStopInfo.Create;
  MySearchFileFace.AddChange( SearchFileLvStopInfo );
end;

{ TFileSearchSourceStopInfo }

procedure TSourceFileSearchCompleteInfo.Update;
begin
  if MyFileSearchReq.PcSourceFileReqInfo.RemovePcID( PcID ) and
     MyFileSearchReq.PcBackupFileReqInfo.IsEmpty
  then
    SearchCompleteFace;
end;

{ TFileSearchBackupCopyStopInfo }

procedure TBackupFileSearchCompleteInfo.Update;
begin
  if MyFileSearchReq.PcBackupFileReqInfo.RemovePcID( PcID ) and
     MyFileSearchReq.PcSourceFileReqInfo.IsEmpty
  then
    SearchCompleteFace;
end;

{ TFileSearchCancelInfo }

constructor TFileSearchCancelInfo.Create(_SearchPcID: string);
begin
  SearchPcID := _SearchPcID;
end;

procedure TFileSearchCancelInfo.Update;
begin
  MyFileSearchScan.PcSourceFileReqInfo.RemovePcID( SearchPcID );
  MyFileSearchScan.PcBackupFileReqInfo.RemovePcID( SearchPcID );
end;

{ TFileSearchRemoveInfo }

procedure TFileSearchStopInfo.ClearReqPcList;
begin
  MyFileSearchReq.PcSourceFileReqInfo.Clear;
  MyFileSearchReq.PcBackupFileReqInfo.Clear;
end;

procedure TFileSearchStopInfo.SearchCompleteFace;
var
  SearchFileLvStopInfo : TSearchFileLvStopInfo;
begin
  SearchFileLvStopInfo := TSearchFileLvStopInfo.Create;
  MySearchFileFace.InsertChange( SearchFileLvStopInfo );
end;

procedure TFileSearchStopInfo.SendCancelToNetworkPc;
var
  FileSearchCancelMsg : TFileSearchCancelMsg;
begin
    // 取消 搜索
  FileSearchCancelMsg := TFileSearchCancelMsg.Create;
  FileSearchCancelMsg.SetPcID( PcInfo.PcID );

    // 插入到 发送 队列
  MyClient.SendMsgToAll( FileSearchCancelMsg );
end;

procedure TFileSearchStopInfo.Update;
begin
    // 添加 搜索序列号
  inc( Number_FileSearch );

    // 发送取消搜索通知
  SendCancelToNetworkPc;

    // 返回搜索界面
  SearchCompleteFace;

    // 清除请求列表
  ClearReqPcList;
end;

{ TFileSearchAllStopInfo }

procedure TAllFileSearchCompleteInfo.StopBackupCopyFile;
var
  FileSearchBackupCopyStopInfo : TBackupFileSearchCompleteInfo;
begin
  FileSearchBackupCopyStopInfo := TBackupFileSearchCompleteInfo.Create( PcID );
  FileSearchBackupCopyStopInfo.Update;
  FileSearchBackupCopyStopInfo.Free;
end;

procedure TAllFileSearchCompleteInfo.StopSourceFile;
var
  FileSearchSourceStopInfo : TSourceFileSearchCompleteInfo;
begin
  FileSearchSourceStopInfo := TSourceFileSearchCompleteInfo.Create( PcID );
  FileSearchSourceStopInfo.Update;
  FileSearchSourceStopInfo.Free;
end;

procedure TAllFileSearchCompleteInfo.Update;
begin
  StopSourceFile;

  StopBackupCopyFile;
end;

{ TFileSearchClearInfo }

procedure TAllPcFileSearchCompleteInfo.ClearReqList;
begin
  MyFileSearchReq.PcSourceFileReqInfo.Clear;
  MyFileSearchReq.PcBackupFileReqInfo.Clear;
end;

procedure TAllPcFileSearchCompleteInfo.SearchCompleteFace;
var
  SearchFileLvStopInfo : TSearchFileLvStopInfo;
begin
  SearchFileLvStopInfo := TSearchFileLvStopInfo.Create;
  MySearchFileFace.AddChange( SearchFileLvStopInfo );
end;

procedure TAllPcFileSearchCompleteInfo.Update;
begin
  SearchCompleteFace;

  ClearReqList;
end;

{ TRestorePathInfo }

constructor TRestorePathInfo.Create(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

{ TRestoreFileSearchAddInfo }

procedure TRestoreFileSearchAddInfo.AddRestorePath(FullPath, PathType: string);
var
  RestorePathInfo : TRestorePathInfo;
begin
  RestorePathInfo := TRestorePathInfo.Create( FullPath, PathType );
  RestorePathHash.AddOrSetValue( FullPath, RestorePathInfo );
end;

constructor TRestoreFileSearchAddInfo.Create(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
  RestorePathHash := TRestorePathHash.Create;
end;

destructor TRestoreFileSearchAddInfo.Destroy;
begin
  RestorePathHash.Free;
  inherited;
end;

function TRestoreFileSearchAddInfo.getOnlinePcIDList: TStringList;
var
  NetPcInfoHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
begin
  Result := TStringList.Create;

  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcInfoHash do
    if p.Value.IsOnline then
      Result.Add( p.Value.PcID );
  MyNetPcInfo.LeaveData;
end;


procedure TRestoreFileSearchAddInfo.SendRestoreFileMsg(PcID: string);
var
  RestoreFileSearchReqMsg : TRestoreFileSearchReqMsg;
  RestorePathMsg : TRestorePathMsg;
  p : TRestorePathPair;
  MsgStr : string;
begin
  RestoreFileSearchReqMsg := TRestoreFileSearchReqMsg.Create;
  RestoreFileSearchReqMsg.SetPcID( PcInfo.PcID );
  RestoreFileSearchReqMsg.SetSearchNum( SearchNum );
  RestoreFileSearchReqMsg.SetRestorePcID( RestorePcID );
  for p in RestorePathHash do
  begin
    RestorePathMsg := TRestorePathMsg.Create;
    RestorePathMsg.SetPathInfo( p.Value.FullPath, p.Value.PathType );
    MsgStr := RestorePathMsg.getMsgStr;
    RestorePathMsg.Free;

    RestoreFileSearchReqMsg.AddRestoreBackupPashMsg( MsgStr );
  end;

  MyClient.SendMsgToPc( PcID, RestoreFileSearchReqMsg );
end;

procedure TRestoreFileSearchAddInfo.Update;
var
  OnlinePcIDList : TStringList;
  i : Integer;
  PcID : string;
begin
  Inc( Number_FileRestore );
  SearchNum := Number_FileRestore;

  OnlinePcIDList := getOnlinePcIDList;
  for i := 0 to OnlinePcIDList.Count - 1 do
  begin
    PcID := OnlinePcIDList[i];
    MyFileRestoreReq.PcRestoreFileReqInfo.AddPcID( PcID );
    SendRestoreFileMsg( PcID );
  end;
  OnlinePcIDList.Free;
end;

{ TPcFileReqInfo }

procedure TPcFileReqInfo.AddPcID(PcID: string);
begin
  PcLock.Enter;
  PcIDHash.AddString( PcID );
  PcLock.Leave;
end;

procedure TPcFileReqInfo.Clear;
begin
  PcLock.Enter;
  PcIDHash.Clear;
  PcLock.Leave;
end;

constructor TPcFileReqInfo.Create;
begin
  PcLock := TCriticalSection.Create;
  PcIDHash := TStringHash.Create;
end;

destructor TPcFileReqInfo.Destroy;
begin
  PcIDHash.Free;
  PcLock.Free;
  inherited;
end;

function TPcFileReqInfo.IsEmpty: Boolean;
begin
  PcLock.Enter;
  Result := PcIDHash.Count <= 0;
  PcLock.Leave;
end;

function TPcFileReqInfo.IsExistPc(PcID: string): Boolean;
begin
  PcLock.Enter;
  Result := PcIDHash.ContainsKey( PcID );
  PcLock.Leave;
end;

function TPcFileReqInfo.RemovePcID(PcID: string): Boolean;
begin
  PcLock.Enter;
  PcIDHash.Remove( PcID );
  Result := PcIDHash.Count <= 0;
  PcLock.Leave;
end;

{ TFileSearchAllPcCancel }

procedure TAllPcFileSearchCancelInfo.Update;
begin
  MyFileSearchScan.PcSourceFileReqInfo.Clear;
  MyFileSearchScan.PcBackupFileReqInfo.Clear;
end;

{ TNetworkFileScanStartInfo }

procedure TNetworkFileScanStartInfo.SetSearchName(_SearchName: string);
begin
  SearchName := _SearchName;
end;

{ TRestoreFileScanStartInfo }

procedure TRestoreFileScanStartInfo.AddRestorePath(FullPath, PathType: string);
var
  RestorePathInfo : TRestorePathInfo;
begin
  RestorePathInfo := TRestorePathInfo.Create( FullPath, PathType );
  RestorePathHash.AddOrSetValue( FullPath, RestorePathInfo );
end;

procedure TRestoreFileScanStartInfo.AddSearchScan;
begin
  MyFileRestoreScan.PcRestoreFileReqInfo.AddPcID( SearchPcID );
end;

constructor TRestoreFileScanStartInfo.Create;
begin
  RestorePathHash := TRestorePathHash.Create;
  CloudPcPathList := TStringList.Create;
end;

procedure TRestoreFileScanStartInfo.DeleteSearchScan;
begin
  MyFileRestoreScan.PcRestoreFileReqInfo.RemovePcID( SearchPcID );
end;

destructor TRestoreFileScanStartInfo.Destroy;
begin
  CloudPcPathList.Free;
  RestorePathHash.Free;
  inherited;
end;

procedure TRestoreFileScanStartInfo.FindPathList;
var
  CloudPathList : TStringList;
  CloudPathOwnerList : TStringList;
  i : Integer;
  CloudPath, CloudPcPath : string;
begin
  CloudPathList := MyCloudPathInfoUtil.ReadCloudPathList;
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i];

    CloudPathOwnerList := MyFilePath.getChildFolderList( CloudPath );
    if CloudPathOwnerList.IndexOf( RestorePcID ) >= 0 then
    begin
      CloudPcPath := MyFilePath.getPath( CloudPath ) + RestorePcID;
      CloudPcPathList.Add( CloudPcPath );
    end;
    CloudPathOwnerList.Free;
  end;
  CloudPathList.Free;
end;

procedure TRestoreFileScanStartInfo.ScanPathList;
var
  i : Integer;
  p : TRestorePathPair;
  CloudPcPath, RestorePath: string;
  RestoreCloudFolderSearch : TRestoreCloudFolderSearch;
begin
  for i := 0 to CloudPcPathList.Count - 1 do
  begin
    CloudPcPath := CloudPcPathList[i];
    for p in RestorePathHash do
    begin
      RestorePath := p.Value.FullPath;
      RestorePath := MyFilePath.getDownloadPath( RestorePath );

        // 搜索 恢复文件
      RestoreCloudFolderSearch := TRestoreCloudFolderSearch.Create;
      RestoreCloudFolderSearch.SetCloudPcPath( CloudPcPath );
      RestoreCloudFolderSearch.SetSearchNum( SearchNum );
      RestoreCloudFolderSearch.SetFolderPath( RestorePath );
      RestoreCloudFolderSearch.SetSearchInfo( SearchPcID, '' );
      RestoreCloudFolderSearch.SetSearchCount( 0 );
      RestoreCloudFolderSearch.Update;
      RestoreCloudFolderSearch.Free;
    end;
  end;
end;

procedure TRestoreFileScanStartInfo.SendSearchComplete;
var
  RestoreFileSearchCompleteMsg : TRestoreFileSearchCompleteMsg;
begin
  RestoreFileSearchCompleteMsg := TRestoreFileSearchCompleteMsg.Create;
  RestoreFileSearchCompleteMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToPc( SearchPcID, RestoreFileSearchCompleteMsg );
end;

procedure TRestoreFileScanStartInfo.SetRestorePcID(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

{ TMyFileResotreBase }

constructor TMyFileResotreBase.Create;
begin
  inherited;
  PcRestoreFileReqInfo := TPcFileReqInfo.Create
end;

destructor TMyFileResotreBase.Destroy;
begin
  IsRun := False;
  StopThread;

  PcRestoreFileReqInfo.Free;
  inherited;
end;

{ TMyFileSearchScan }

constructor TMyFileSearchScan.Create;
begin
  inherited;
  AddThread( ThreadCount_Scan );
end;

{ TMyFileRestoreReq }

constructor TMyFileRestoreReq.Create;
begin
  inherited;
  AddThread( 1 );
end;

{ TMyFileRestoreScan }

constructor TMyFileRestoreScan.Create;
begin
  inherited;
  AddThread( ThreadCount_Scan );
end;

{ TRestoreCloudFolderSearch }

function TRestoreCloudFolderSearch.CheckNextSearch: Boolean;
begin
  inherited;

  Result := MyFileRestoreScan.PcRestoreFileReqInfo.IsExistPc( SearchPcID );
  Result := Result and MyFileRestoreScan.IsRun;
end;

procedure TRestoreCloudFolderSearch.FindScanPath;
begin
  if FolderPath = '' then
    ScanPath := CloudPcPath
  else
    ScanPath := MyFilePath.getPath( CloudPcPath ) + FolderPath;
end;

function TRestoreCloudFolderSearch.getFolderSearch: TFolderSearchBase;
var
  RestoreCloudFolderSearch : TRestoreCloudFolderSearch;
begin
  RestoreCloudFolderSearch := TRestoreCloudFolderSearch.Create;
  RestoreCloudFolderSearch.SetCloudPcPath( CloudPcPath );
  Result := RestoreCloudFolderSearch;
end;

function TRestoreCloudFolderSearch.getSearchResultMsg: TFileSearchResultBaseMsg;
begin
  Result := TReStoreFileSearchResultMsg.Create;
end;

procedure TRestoreCloudFolderSearch.SetCloudPcPath(_CloudPcPath: string);
begin
  CloudPcPath := _CloudPcPath;
end;

{ TNetworkFileSearchResultInfo }

procedure TNetworkFileSearchResultInfo.FindBackupPathInfo;
var
  FileOwnerID : string;
  NetPcInfoHash : TNetPcInfoHash;
  p : TNetPcBackupPathPair;
begin
  FileOwnerID := getOwnerID;

  BackupPath := '';
  IsEncrypt := False;
  PasswordMD5 := '';
  PasswordHint := '';

  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  if NetPcInfoHash.ContainsKey( FileOwnerID ) then
    for p in NetPcInfoHash[ FileOwnerID ].NetPcBackupPathHash do
      if MyMatchMask.CheckEqualsOrChild( FilePath, p.Value.FullPath ) then
      begin
        BackupPath := p.Value.FullPath;
        IsEncrypt := p.Value.IsEncrypt;
        PasswordMD5 := p.Value.PasswordMD5;
        PasswordHint := p.Value.PasswordHint;
        Break;
      end;
  MyNetPcInfo.LeaveData;
end;

procedure TNetworkFileSearchResultInfo.Update;
var
  FileOwerID, FileType : string;
  LocationName, OwnerName : string;
  SearchFileLvAddInfo : TSearchFileLvAddInfo;
begin
    // 搜索结果 过时
  if SearchNum <> Number_FileSearch then
    Exit;

  FileOwerID := getOwnerID;
  FileType := getFileType;

  LocationName := MyNetPcInfoReadUtil.ReadName( LocationID );
  OwnerName := MyNetPcInfoReadUtil.ReadName( FileOwerID );

  FindBackupPathInfo;

  SearchFileLvAddInfo := TSearchFileLvAddInfo.Create;
  SearchFileLvAddInfo.SetSearchNum( SearchNum );
  SearchFileLvAddInfo.SetFilePcID( LocationID, FileOwerID );
  SearchFileLvAddInfo.SetFilePcName( LocationName, OwnerName );
  SearchFileLvAddInfo.SetFileBase( FilePath, FileType );
  SearchFileLvAddInfo.SetFileInfo( FileSize, FileTime );
  SearchFileLvAddInfo.SetBackupPath( BackupPath );
  SearchFileLvAddInfo.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );

  MySearchFileFace.AddChange( SearchFileLvAddInfo );
end;

{ TRestoreFileSearchResultinfo }

procedure TRestoreFileSearchResultinfo.AddToQuickRestore;
var
  RootPath : string;
  RestoreFileQuickAddHanlde : TRestoreFileQuickAddHanlde;
begin
  RootPath := MyRestoreInfoReadUtil.ReadRootPath( FilePath, RestoreQuick_RestorePcID );

  RestoreFileQuickAddHanlde := TRestoreFileQuickAddHanlde.Create( RootPath, RestoreQuick_RestorePcID );
  RestoreFileQuickAddHanlde.SetPathInfo( FilePath );
  RestoreFileQuickAddHanlde.SetLocationPcID( LocationID );
  RestoreFileQuickAddHanlde.SetFileInfo( FileSize, FileTime );
  RestoreFileQuickAddHanlde.Update;
  RestoreFileQuickAddHanlde.Free;
end;

procedure TRestoreFileSearchResultinfo.AddToRestoreForm;
var
  LocationName : string;
  VstRestoreFileAddInfo : TVstRestoreFileAddInfo;
begin
  LocationName := MyNetPcInfoReadUtil.ReadName( LocationID );

    // 添加到界面
  VstRestoreFileAddInfo := TVstRestoreFileAddInfo.Create( LocationID, FilePath );
  VstRestoreFileAddInfo.SetFileInfo( FileSize, FileTime );
  VstRestoreFileAddInfo.SetSearchNum( SearchNum );
  VstRestoreFileAddInfo.SetLocationName( LocationName );
  MyRestoreFileFace.AddChange( VstRestoreFileAddInfo );
end;

procedure TRestoreFileSearchResultinfo.Update;
var
  VstRestoreFileAddInfo : TVstRestoreFileAddInfo;
begin
    // 信息 过时
  if SearchNum <> Number_FileRestore then
    Exit;

    // 是否进行快速恢复
  if RestoreSearch_IsQuick then
    AddToQuickRestore
  else
    AddToRestoreForm;
end;

{ TRestoreFileSearchCompleteInfo }


constructor TRestoreFileSearchCompleteInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TRestoreFileSearchCompleteInfo.Update;
begin
  if MyFileRestoreReq.PcRestoreFileReqInfo.RemovePcID( PcID ) then
    RestoreCompleted;
end;

{ TAllPcRestoreFileSearchCompleteInfo }

procedure TAllPcRestoreFileSearchCompleteInfo.Update;
begin
  MyFileRestoreReq.PcRestoreFileReqInfo.Clear;

    // 结束
  RestoreCompleted;
end;

{ TRestoreFileSearchCancelInfo }

constructor TRestoreFileSearchCancelInfo.Create(_SearchPcID: string);
begin
  SearchPcID := _SearchPcID;
end;

procedure TRestoreFileSearchCancelInfo.Update;
begin
  MyFileRestoreScan.PcRestoreFileReqInfo.RemovePcID( SearchPcID );
end;

{ TAllPcRestoreFileSearchCancelInfo }

procedure TAllPcRestoreFileSearchCancelInfo.Update;
begin
  MyFileRestoreScan.PcRestoreFileReqInfo.Clear;
end;

{ TResotreFileSearchStopInfo }

procedure TResotreFileSearchStopInfo.ClearReqPcList;
begin
  MyFileRestoreReq.PcRestoreFileReqInfo.Clear;
end;

procedure TResotreFileSearchStopInfo.SendCancelToNetworkPc;
var
  RestoreSearchCancelMsg : TRestoreSearchCancelMsg;
begin
  RestoreSearchCancelMsg := TRestoreSearchCancelMsg.Create;
  RestoreSearchCancelMsg.SetPcID( PcInfo.PcID );
  MyClient.SendMsgToAll( RestoreSearchCancelMsg );
end;

procedure TResotreFileSearchStopInfo.Update;
begin
    // 添加 搜索序列号
  inc( Number_FileRestore );

  SendCancelToNetworkPc;

  ClearReqPcList;
end;

{ TRestoreFileSeachCompletedBase }

procedure TRestoreFileSeachCompletedBase.RestoreCompleted;
begin
  if RestoreSearch_IsQuick then
    RestoreFileCompelted
  else
    RestoreFormCompleted;
end;

procedure TRestoreFileSeachCompletedBase.RestoreFileCompelted;
var
  VstRestoreDownSearchCompleted : TVstRestoreDownSearchCompleted;
begin
    // 结束
  VstRestoreDownSearchCompleted := TVstRestoreDownSearchCompleted.Create;
  MyRestoreFileFace.AddChange( VstRestoreDownSearchCompleted );
end;

procedure TRestoreFileSeachCompletedBase.RestoreFormCompleted;
var
  VstRestoreFileSearchCompleted : TVstRestoreFileSearchCompleted;
begin
    // 结束
  VstRestoreFileSearchCompleted := TVstRestoreFileSearchCompleted.Create;
  MyRestoreFileFace.AddChange( VstRestoreFileSearchCompleted );
end;

end.
