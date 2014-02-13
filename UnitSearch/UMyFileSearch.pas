unit UMyFileSearch;

interface

uses UChangeInfo, Classes, UFileBaseInfo, UMyClient, UMyUtil, SysUtils, SyncObjs,
     UModelUtil, Generics.Collections, uDebug, Windows;

type

{$Region ' �ݹ��ļ����� ' }

   // �ݹ� �����ļ�
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

    // ���� �����ļ�
  TBackupFolderSearch = class( TFolderSearchBase )
  protected
    procedure FindScanPath;override;
    function getSearchResultMsg : TFileSearchResultBaseMsg;override;
    function getFolderSearch : TFolderSearchBase;override;
    function CheckNextSearch : Boolean;override;
  end;

    // ���� ���ļ�
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

    // ���� �ָ� ���ļ�
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


{$Region ' �����ļ����� ���� ' }

  {$Region ' �ļ����� ' }

    // ��ʼ ����
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

    // ���� ����
  TFileSearchStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure SendCancelToNetworkPc;
    procedure SearchCompleteFace;
    procedure ClearReqPcList;
  end;

  {$EndRegion}

  {$Region ' �ļ�������� ' }

     // ����
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

    // �����ļ�
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

    // Դ�ļ�
  TSourceFileSearchResultInfo = class( TNetworkFileSearchResultInfo )
  protected
    function getFileType : string;override;
    function getOwnerID : string;override;
  end;

    // �����ļ�
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

  {$Region ' �ļ�������� ' }

      // Pc �ļ����� ��� ����
  TFileSearchCompleteInfo = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure SearchCompleteFace;  // ��������
  end;

    // Pc Դ�ļ����� ���
  TSourceFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  end;

    // Pc �����ļ����� ���
  TBackupFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  end;

    // Pc Դ�ļ� �� �����ļ����� ���
  TAllFileSearchCompleteInfo = class( TFileSearchCompleteInfo )
  public
    procedure Update;override;
  private
    procedure StopSourceFile;
    procedure StopBackupCopyFile;
  end;

    // ���� Pc Դ�ļ� �� �����ļ����� ���
  TAllPcFileSearchCompleteInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure ClearReqList;
    procedure SearchCompleteFace;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �����ļ����� ɨ�� ' }

  {$Region ' �ļ�ɨ�� ' }

    // �ļ� ������ʼ ����
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

    // �����ļ� ������ʼ
  TNetworkFileScanStartInfo = class( TFileScanStartInfo )
  public
    SearchName : string;
  public
    procedure SetSearchName( _SearchName : string );
  end;

    // Դ�ļ� ������ʼ
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

    // �����ļ� ������ʼ
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

  {$Region ' ɨ������ ' }

    // Pc ȡ�� ����
  TFileSearchCancelInfo = class( TChangeInfo )
  public
    SearchPcID : string;
  public
    constructor Create( _SearchPcID : string );
    procedure Update;override;
  end;

    // ������ ����
    // ���� Pc ȡ�� ����
  TAllPcFileSearchCancelInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �����ļ����� ���� ' }

    // �����ļ������ Pc ��Ϣ
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

    // �ļ����� ����
  TMyFileSearchBase = class( TMyChangeBase )
  public
    PcSourceFileReqInfo : TPcFileReqInfo;
    PcBackupFileReqInfo : TPcFileReqInfo;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // �ļ����� ���� �� ���ս��
  TMyFileSearchReq = class( TMyFileSearchBase )
  public
    constructor Create;
  end;

    // �ļ����� ɨ��
  TMyFileSearchScan = class( TMyFileSearchBase )
  public
    constructor Create;
  end;

{$EndRegion}


{$Region ' �ָ��ļ����� ���� ' }

  {$Region ' �ļ����� ' }

    // �ָ� ·����Ϣ
  TRestorePathInfo = class
  public
    FullPath : string;
    PathType : string;
  public
    constructor Create( _FullPath, _PathType : string );
  end;
  TRestorePathPair = TPair< string , TRestorePathInfo >;
  TRestorePathHash = class(TStringDictionary< TRestorePathInfo >);

    // ��� �ָ��ļ� ����
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

      // ���� �ָ�
  TResotreFileSearchStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  private
    procedure SendCancelToNetworkPc;
    procedure ClearReqPcList;
  end;

  {$EndRegion}

  {$Region ' �ļ�������� ' }

  TRestoreFileSearchResultinfo = class( TFileSearchResultInfo )
  public
    procedure Update;override;
  private
    procedure AddToRestoreForm;
    procedure AddToQuickRestore;
  end;

  {$EndRegion}

  {$Region ' �ļ�������� ' }

    // ����
  TRestoreFileSeachCompletedBase = class( TChangeInfo )
  protected
    procedure RestoreCompleted;
  private
    procedure RestoreFormCompleted;
    procedure RestoreFileCompelted;
  end;

    // Pc �ָ��ļ����� ���
  TRestoreFileSearchCompleteInfo = class( TRestoreFileSeachCompletedBase )
  private
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // ���� Pc �ָ��ļ����� ���
  TAllPcRestoreFileSearchCompleteInfo = class( TRestoreFileSeachCompletedBase )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �ָ��ļ����� ɨ�� ' }

  {$Region ' �ļ�ɨ�� '}

    // �ָ��ļ� ������ʼ
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

  {$Region ' ɨ������ ' }

      // Pc ȡ�� ����
  TRestoreFileSearchCancelInfo = class( TChangeInfo )
  public
    SearchPcID : string;
  public
    constructor Create( _SearchPcID : string );
    procedure Update;override;
  end;

    // ������ ����
    // ���� Pc ȡ�� ����
  TAllPcRestoreFileSearchCancelInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �ָ��ļ����� ���� ' }

    // �ָ��ļ� ����
  TMyFileResotreBase = class( TMyChangeBase )
  public
    PcRestoreFileReqInfo : TPcFileReqInfo;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // �ָ��ļ� ����
  TMyFileRestoreReq = class( TMyFileResotreBase )
  public
    constructor Create;
  end;

    // �ָ��ļ� ɨ��
  TMyFileRestoreScan = class( TMyFileResotreBase )
  public
    constructor Create;
  end;

{$EndRegion}

const
  SearchCount_Sleep = 10;
  ThreadCount_Scan = 2;

var
  Number_FileSearch : Integer = 0; // ���������
  Number_FileRestore : Integer = 0; // �ָ������
  RestoreSearch_IsQuick : Boolean = False; // �Ƿ���ٻָ�
  RestoreQuick_RestorePcID : string = ''; // ���ٻָ��� Pc ID

    // ���� �ļ�����
  MyFileSearchReq : TMyFileSearchReq;
  MyFileSearchScan : TMyFileSearchScan;

    // �ָ� �ļ�����
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
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // �����һ��Ŀ¼
      if DirectoryExists( SearcFullPath + FileName )  then
        CheckNextFolder( FileName )
      else   // �Ƿ� Ҫ�ҵ��ļ�
      if IsSearchFile( FileName ) then
      begin
        FilePath := MyFilePath.getPath( FolderPath ) + FileName;
        FileSize := sch.Size; // �ռ���Ϣ
          // ��ȡ�޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ���ͽ��
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
    // ��Ŀ¼ ·��
  ChildFolderPath := MyFilePath.getPath( FolderPath ) + FolderName;

    // ���� ��һ��
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
    // ��ȡ �ļ���
  FileName := ExtractFileName( ScanPath );

    // �ж� �Ƿ� Ҫ�ҵ��ļ�
  if not IsSearchFile( FileName ) then
    Exit;

    // ��ȡ�ļ���Ϣ
  FileSize := MyFileInfo.getFileSize( ScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // ���ͽ��
  SendSearchResult( FolderPath, FileSize, FileTime );
end;

procedure TFolderSearchBase.SendSearchResult(FilePath: string; FileSize: Int64;
  FileTime: TDateTime);
var
  FileSearchResultBaseMsg : TFileSearchResultBaseMsg;
begin
  FilePath := MyFilePath.getUploadPath( FilePath );

    // ���� Դ�ļ� ���
  FileSearchResultBaseMsg := getSearchResultMsg;
  FileSearchResultBaseMsg.SetPcID( PcInfo.PcID );
  FileSearchResultBaseMsg.SetSearchNum( SearchNum );
  FileSearchResultBaseMsg.SetFilePath( FilePath );
  FileSearchResultBaseMsg.SetFileInfo( FileSize, FileTime );

    // ��ӵ��ͻ��˷��Ͷ���
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
    // ��ȡ ɨ�����·��
  FindScanPath;

    // ɨ�� �ļ�/Ŀ¼
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
    // ��ȡ ������·��
  CloudPathList := MyCloudPathInfoUtil.ReadCloudPathList;
    // �ж� ÿһ����·�� ӵ����
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
    // ��ȡ ��·���� ӵ����
  CloudPathOwnerList := MyFilePath.getChildFolderList( CloudPath );
    // ��Ҫ ������ӵ���� �Ƿ������·����
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
    // ��ӵ��������
  AddBackupCopyReqPc( PcID );

    // ���� ��������
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
    // ��ӵ����� Pc ����
  AddSourceReqPc( PcID );

    // ���� ��������
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
    // ���� �����ļ� ����
  Inc( Number_FileSearch );
  SearchNum := Number_FileSearch;

    // ��ʼ�����ļ� ����
  StartSearchFace;

    // ������ �ļ�����
  IsSearchSource := ( FileType = FileType_AllTypes ) or
                    ( FileType = FileType_SourceFile );

  IsSearchBackupCopy := ( FileType = FileType_AllTypes ) or
                        ( FileType = FileType_BackupCopy );

    // ���� ��������
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

    // û�н�������
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
    // ȡ�� ����
  FileSearchCancelMsg := TFileSearchCancelMsg.Create;
  FileSearchCancelMsg.SetPcID( PcInfo.PcID );

    // ���뵽 ���� ����
  MyClient.SendMsgToAll( FileSearchCancelMsg );
end;

procedure TFileSearchStopInfo.Update;
begin
    // ��� �������к�
  inc( Number_FileSearch );

    // ����ȡ������֪ͨ
  SendCancelToNetworkPc;

    // ������������
  SearchCompleteFace;

    // ��������б�
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

        // ���� �ָ��ļ�
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
    // ������� ��ʱ
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

    // ��ӵ�����
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
    // ��Ϣ ��ʱ
  if SearchNum <> Number_FileRestore then
    Exit;

    // �Ƿ���п��ٻָ�
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

    // ����
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
    // ��� �������к�
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
    // ����
  VstRestoreDownSearchCompleted := TVstRestoreDownSearchCompleted.Create;
  MyRestoreFileFace.AddChange( VstRestoreDownSearchCompleted );
end;

procedure TRestoreFileSeachCompletedBase.RestoreFormCompleted;
var
  VstRestoreFileSearchCompleted : TVstRestoreFileSearchCompleted;
begin
    // ����
  VstRestoreFileSearchCompleted := TVstRestoreFileSearchCompleted.Create;
  MyRestoreFileFace.AddChange( VstRestoreFileSearchCompleted );
end;

end.
