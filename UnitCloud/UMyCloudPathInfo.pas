unit UMyCloudPathInfo;

interface

uses Generics.Collections, SyncObjs, Classes, SysUtils,
     UFileBaseInfo,
     UModelUtil, UMyUtil, UChangeInfo, uDebug, DateUtils;

type

//////// ���ݽṹ ///////////

{$Region ' ��·�� ��Ϣ '}

    // ��·�� ӵ������Ϣ
  TCloudPathOwnerInfo = class
  public
    OwnerPcID : string;
    FileCount : Integer;
    UsedSpace : Int64;
    LastScanTime : TDateTime;
  public
    constructor Create( _OwnerPcID : string );
  end;
  TCloudPathOwnerPair = TPair< string , TCloudPathOwnerInfo >;
  TCloudPathOwnerHash = class(TStringDictionary< TCloudPathOwnerInfo >);


    // ��·����Ϣ
  TCloudPathInfo = class
  public
    CloudPath : string;
    CloudPathOwnerHash : TCloudPathOwnerHash;   // ӵ������Ϣ
  public
    constructor Create( _CloudPath : string );
    destructor Destroy; override;
  end;
  TCloudPathList = class( TObjectList<TCloudPathInfo> )
  public
    function getPath( Path : string ): TCloudPathInfo;
    procedure RemovePath( Path : string );
  private
    function getPathIndex( Path : string ) : Integer;
  end;

{$EndRegion}

{$Region ' ������ ' }

  TMyCloudInfoReadBase = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ����
  TMyCloudInfoReadBaseInfo = class( TMyCloudInfoReadBase )
  public
    CloudPathList : TCloudPathList;
  public
    constructor Create;
  end;

    // ��ȡ ������·��
  TFindCloudPathList = class( TMyCloudInfoReadBaseInfo )
  public
    function get : TStringList;
  end;

      // ��ȡ Pc �� ���� Pc��·��
  TMyCloudPathPcFolderPathRead = class( TMyCloudInfoReadBaseInfo )
  private
    CloudPcID : string;
  public
    procedure SetCloudPcID( _CloudPcID : string );
    function get : TStringList;
  end;

    // ��ȡ ���ļ�·�� �� ����·��
  TMyCloudFileRootPathRead = class( TMyCloudInfoReadBaseInfo )
  private
    CloudFilePath : string;
  public
    procedure SetCloudFilePath( _CloudFilePath : string );
    function get : string;
  end;

    // ��ȡ ��·�����ÿռ�
  TMyCloudPathUserSpaceRead = class( TMyCloudInfoReadBaseInfo )
  public
    function get : Int64;
  end;

    // �޸�
  TMyCloudPathReadInfo = class( TMyCloudInfoReadBaseInfo )
  public
    CloudPath : string;
  protected
    CloudPathInfo : TCloudPathInfo;
  public
    procedure SetCloudPath( _CloudPath : string );
  protected
    function FindCloudPathInfo : Boolean;
  end;

    // ��Ŀ¼ ����Դ
  TMyCloudPathPcIDHashRead = class( TMyCloudPathReadInfo )
  public
    function get : TStringHash;
  end;

    // ��ȡ ·���ռ���Ϣ
  TMyCloudPathOwnerSpaceRead = class( TMyCloudPathReadInfo )
  public
    CloudPath, PcID : string;
  public
    procedure SetPcID( _PcID : string );
    function get : Int64;
  end;

    // ��·��
  MyCloudPathInfoUtil = class
  public
    class function ReadCloudPathPcIDHash( CloudPath : string ): TStringHash;
    class function ReadPcCloudPathList( PcID : string ): TStringList;
    class function ReadCloudPathList : TStringList;
    class function ReadCloudFileRootPath( CloudFilePath : string ): string;
    class function ReadCloudTotalUserSpace : Int64;
    class function ReadCloudPcFileSize( CloudPath, PcID : string ): Int64;
  private
    class function ReadCloudPathInfo( CloudFilePath : string ): TCloudPathInfo;
  end;

{$EndRegion}

//////// �����޸� ///////////

{$Region ' ��·�� �޸� ' }

    // ����
  TCloudPathChangeInfo = class( TChangeInfo )
  protected
    CloudPathList : TCloudPathList;
  public
    procedure Update;override;
  end;

    // Pc ���� ɨ����·��
  TCloudPathOnlineScanInfo = class( TCloudPathChangeInfo )
  public
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
    procedure Update;override;
  private
    procedure OnlineScan( CloudPath : string );
  end;

    // �޸�
  TCloudPathWriteInfo = class( TCloudPathChangeInfo )
  protected
    CloudPath : string;
  protected
    CloudPathInfo : TCloudPathInfo;
  public
    constructor Create( _CloudPath : string );
  protected
    function FindCloudPathInfo : Boolean;
  end;

    // ���
  TCloudPathAddInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TCloudPathRemoveInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' ��·�� ӵ���� �޸� ' }

    // ����
  TCloudPathOwnerChangeInfo = class( TCloudPathWriteInfo )
  public
    OwnerPcID : string;
    CloudPathOwnerHash : TCloudPathOwnerHash;
  public
    procedure SetOwnerPcID( _OwnerPcID : string );
  protected
    function FindCloudPathOwnerHash : Boolean;
  end;

    // ɾ��
  TCloudPathOwnerRemoveInfo = class( TCloudPathOwnerChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸�
  TCloudPathOwnerWriteInfo = class( TCloudPathOwnerChangeInfo )
  protected
    CloudPathOwnerInfo : TCloudPathOwnerInfo;
  protected
    function FindCloudPathOwnerInfo : Boolean;
    procedure AddCloudPathOwnerInfo;
  end;

      // ���
  TCloudPathOwnerAddInfo = class( TCloudPathOwnerWriteInfo )
  public
    FileSize : Int64;
    FileCount : Integer;
    LastScanTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;override;
  end;

    // ���� ���һ�� ɨ��ʱ��
  TCloudPathOwnerSetLastScanTimeInfo = class( TCloudPathOwnerWriteInfo )
  public
    LastScanTime : TDateTime;
  public
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;override;
  end;

  {$Region ' �޸� �ռ���Ϣ ' }

    // �޸� �ռ���Ϣ ����
  TCloudPathOwnerSpaceChangeInfo = class( TCloudPathOwnerWriteInfo )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ��� �ռ���Ϣ
  TCloudPathOwnerAddSpaceInfo = class( TCloudPathOwnerSpaceChangeInfo )
  public
    procedure Update;override;
  end;

    // ���� �ռ���Ϣ
  TCloudPathOwnerRemoveSpaceInfo = class( TCloudPathOwnerSpaceChangeInfo )
  public
    procedure Update;override;
  end;

    // ���� �ռ���Ϣ
  TCloudPathOwnerSetSpaceInfo = class( TCloudPathOwnerSpaceChangeInfo )
  private
    LastFileSize : Int64;
  public
    procedure SetLastFileSize( _LastFileSize : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

    // ��·�� �ܿ�����
  TMyCloudFileInfo = class( TMyDataChange )
  public
    CloudPathList : TCloudPathList;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function ReadBackupCloudPath : string;
  end;

var
  MyCloudFileInfo : TMyCloudFileInfo;

implementation

uses UMyNetPcInfo, UMyClient, UCloudFileScan,
     UMyCloudFileControl;

{ TMyCloudPathIfno }

constructor TMyCloudFileInfo.Create;
begin
  inherited;
  CloudPathList := TCloudPathList.Create;
  AddThread(1);
end;

destructor TMyCloudFileInfo.Destroy;
begin
  CloudPathList.Free;
  inherited;
end;

function TMyCloudFileInfo.ReadBackupCloudPath: string;
begin
  EnterData;
  if CloudPathList.Count > 0 then
    Result := CloudPathList[0].CloudPath
  else
    Result := '';
  LeaveData;
end;

{ TCloudPathInfo }

constructor TCloudPathInfo.Create( _CloudPath : string );
begin
  CloudPath := _CloudPath;
  CloudPathOwnerHash := TCloudPathOwnerHash.Create;
end;

destructor TCloudPathInfo.Destroy;
begin
  CloudPathOwnerHash.Free;
  inherited;
end;

{ TCloudPcFolderInfo }

constructor TCloudPathOwnerInfo.Create( _OwnerPcID : string );
begin
  OwnerPcID := _OwnerPcID;
  UsedSpace := 0;
  FileCount := 0;
  LastScanTime := 0;
end;

{ TCloudPathModifyInfo }

constructor TCloudPathWriteInfo.Create(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

function TCloudPathWriteInfo.FindCloudPathInfo: Boolean;
begin
  CloudPathInfo := CloudPathList.getPath( CloudPath );
  Result := CloudPathInfo <> nil;
end;

{ TCloudPathAddInfo }

procedure TCloudPathAddInfo.Update;
begin
  inherited;

    // �Ѵ���
  if FindCloudPathInfo then
    Exit;

    // ���
  CloudPathInfo := TCloudPathInfo.Create( CloudPath );
  CloudPathList.Add( CloudPathInfo );
end;

{ TCloudPathChangeInfo }

procedure TCloudPathChangeInfo.Update;
begin
  CloudPathList := MyCloudFileInfo.CloudPathList;
end;

{ TCloudPcFolderUsedSpaceInfo }

procedure TCloudPathOwnerSetSpaceInfo.SetLastFileSize(_LastFileSize: Int64);
begin
  LastFileSize := _LastFileSize;
end;

procedure TCloudPathOwnerSetSpaceInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindCloudPathOwnerHash then
    Exit;

    // ������, �򴴽�
  AddCloudPathOwnerInfo;

    // �ѷ����ı�
  if CloudPathOwnerInfo.UsedSpace <> LastFileSize then
    Exit;

    // �޸���Ϣ
  CloudPathOwnerInfo.UsedSpace := FileSize;
  CloudPathOwnerInfo.FileCount := FileCount;
end;

{ TCloudPcUsedSpaceChangeInfo }

procedure TCloudPathOwnerSpaceChangeInfo.SetSpaceInfo(_FileSize : Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TCloudPcUsedSpaceAddInfo }

procedure TCloudPathOwnerAddSpaceInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindCloudPathOwnerHash then
    Exit;

    // ������, �򴴽�
  AddCloudPathOwnerInfo;

    // �޸���Ϣ
  CloudPathOwnerInfo.UsedSpace := CloudPathOwnerInfo.UsedSpace + FileSize;
  CloudPathOwnerInfo.FileCount := CloudPathOwnerInfo.FileCount + FileCount;
end;

{ TCloudPathRemoveInfo }

procedure TCloudPathRemoveInfo.Update;
begin
  inherited;

    // ������
  if not FindCloudPathInfo then
    Exit;

    // ɾ��
  CloudPathList.RemovePath( CloudPath );
end;

{ TCloudPcFolderRemoveInfo }

procedure TCloudPathOwnerRemoveInfo.Update;
begin
  inherited;

    // ·��������
  if not FindCloudPathOwnerHash then
    Exit;

    // ɾ�� ӵ����
  CloudPathOwnerHash.Remove( OwnerPcID );
end;

{ MyCloudPathInfoUtil }

class function MyCloudPathInfoUtil.ReadCloudPathList: TStringList;
var
  FindCloudPathList : TFindCloudPathList;
begin
  FindCloudPathList := TFindCloudPathList.Create;
  Result := FindCloudPathList.get;
  FindCloudPathList.Free;
end;

class function MyCloudPathInfoUtil.ReadCloudPathPcIDHash(
  CloudPath: string): TStringHash;
var
  MyCloudPathPcIDHashRead : TMyCloudPathPcIDHashRead;
begin
  MyCloudPathPcIDHashRead := TMyCloudPathPcIDHashRead.Create;
  MyCloudPathPcIDHashRead.SetCloudPath( CloudPath );
  Result := MyCloudPathPcIDHashRead.get;
  MyCloudPathPcIDHashRead.Free;
end;

class function MyCloudPathInfoUtil.ReadCloudPcFileSize(CloudPath,
  PcID: string): Int64;
var
  MyCloudPathOwnerSpaceRead : TMyCloudPathOwnerSpaceRead;
begin
  MyCloudPathOwnerSpaceRead := TMyCloudPathOwnerSpaceRead.Create;
  MyCloudPathOwnerSpaceRead.SetCloudPath( CloudPath );
  MyCloudPathOwnerSpaceRead.SetPcID( PcID );
  Result := MyCloudPathOwnerSpaceRead.get;
  MyCloudPathOwnerSpaceRead.Free;
end;

class function MyCloudPathInfoUtil.ReadCloudTotalUserSpace: Int64;
var
  MyCloudPathUserSpaceRead : TMyCloudPathUserSpaceRead;
begin
  MyCloudPathUserSpaceRead := TMyCloudPathUserSpaceRead.Create;
  Result := MyCloudPathUserSpaceRead.get;
  MyCloudPathUserSpaceRead.Free;
end;

class function MyCloudPathInfoUtil.ReadPcCloudPathList(
  PcID: string): TStringList;
var
  MyCloudPathPcFolderPathRead : TMyCloudPathPcFolderPathRead;
begin
  MyCloudPathPcFolderPathRead := TMyCloudPathPcFolderPathRead.Create;
  MyCloudPathPcFolderPathRead.SetCloudPcID( PcID );
  Result := MyCloudPathPcFolderPathRead.get;
  MyCloudPathPcFolderPathRead.Free;
end;

class function MyCloudPathInfoUtil.ReadCloudFileRootPath(
  CloudFilePath: string): string;
var
  MyCloudFileRootPathRead : TMyCloudFileRootPathRead;
begin
  MyCloudFileRootPathRead := TMyCloudFileRootPathRead.Create;
  MyCloudFileRootPathRead.SetCloudFilePath( CloudFilePath );
  Result := MyCloudFileRootPathRead.get;
  MyCloudFileRootPathRead.Free;
end;

class function MyCloudPathInfoUtil.ReadCloudPathInfo(
  CloudFilePath : string): TCloudPathInfo;
var
  CloudPathList : TCloudPathList;
  i : Integer;
  CloudPath : string;
begin
  Result := nil;
  CloudPathList := MyCloudFileInfo.CloudPathList;
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i].CloudPath;
    if MyMatchMask.CheckEqualsOrChild( CloudFilePath, CloudPath ) then
    begin
      Result := CloudPathList[i];
      Break;
    end;
  end;
end;

{ TMyCloudPathReadInfoBase }

constructor TMyCloudInfoReadBase.Create;
begin
  MyCloudFileInfo.EnterData;
end;

destructor TMyCloudInfoReadBase.Destroy;
begin
  MyCloudFileInfo.LeaveData;
  inherited;
end;

{ TCloudPathPcFolderChangeInfo }

function TCloudPathOwnerChangeInfo.FindCloudPathOwnerHash: Boolean;
begin
  Result := False;

    // ��·�� ������
  if not FindCloudPathInfo then
    Exit;

  CloudPathOwnerHash := CloudPathInfo.CloudPathOwnerHash;
  Result := True;
end;

{ TCloudPathPcFolderRemoveSpaceInfo }

procedure TCloudPathOwnerRemoveSpaceInfo.Update;
begin
  inherited;

      // ������
  if not FindCloudPathOwnerInfo then
    Exit;

    // �޸� ��Ϣ
  CloudPathOwnerInfo.UsedSpace := CloudPathOwnerInfo.UsedSpace - FileSize;
  CloudPathOwnerInfo.FileCount := CloudPathOwnerInfo.FileCount - FileCount;

    // ӵ���� �����ڿռ���Ϣ
  if ( CloudPathOwnerInfo.UsedSpace = 0 ) and
     ( CloudPathOwnerInfo.FileCount = 0 )
  then
    CloudPathOwnerHash.Remove( OwnerPcID );
end;

{ TMyCloudPathReadInfo }

function TMyCloudPathReadInfo.FindCloudPathInfo: Boolean;
begin
  CloudPathInfo := CloudPathList.getPath( CloudPath );
  Result := CloudPathInfo <> nil;
end;

procedure TMyCloudPathReadInfo.SetCloudPath(_CloudPath: string);
begin
  CloudPath := _CloudPath;
end;

{ TMyCloudPathPcIDHashRead }

function TMyCloudPathPcIDHashRead.get: TStringHash;
var
  CloudPathPcFolderHash : TCloudPathOwnerHash;
  p : TCloudPathOwnerPair;
begin
  Result := TStringHash.Create;

    // ��·�� ������
  if not FindCloudPathInfo then
    Exit;

    // ��� ��·�� PcĿ¼ �� Pc
  CloudPathPcFolderHash := CloudPathInfo.CloudPathOwnerHash;
  for p in CloudPathPcFolderHash do
    Result.AddString( p.Value.OwnerPcID );
end;

{ TMyCloudInfoReadBaseInfo }

constructor TMyCloudInfoReadBaseInfo.Create;
begin
  inherited;
  CloudPathList := MyCloudFileInfo.CloudPathList;
end;

{ TMyCloudPathPcFolderPathRead }

function TMyCloudPathPcFolderPathRead.get: TStringList;
var
  i : Integer;
  CloudPath : string;
begin
  Result := TStringList.Create;

  for i := 0 to CloudPathList.Count - 1 do
    if CloudPathList[i].CloudPathOwnerHash.ContainsKey( CloudPcID ) then
    begin
      CloudPath := MyFilePath.getPath( CloudPathList[i].CloudPath );
      Result.Add( CloudPath + CloudPcID );
    end;
end;

procedure TMyCloudPathPcFolderPathRead.SetCloudPcID(_CloudPcID: string);
begin
  CloudPcID := _CloudPcID;
end;

procedure TCloudPathOwnerChangeInfo.SetOwnerPcID(_OwnerPcID: string);
begin
  OwnerPcID := _OwnerPcID;
end;

{ TCloudPathOwnerWriteInfo }

procedure TCloudPathOwnerWriteInfo.AddCloudPathOwnerInfo;
begin
  if not CloudPathOwnerHash.ContainsKey( OwnerPcID ) then
  begin
    CloudPathOwnerInfo := TCloudPathOwnerInfo.Create( OwnerPcID );
    CloudPathOwnerHash.AddOrSetValue( OwnerPcID, CloudPathOwnerInfo );
  end
  else
    CloudPathOwnerInfo := CloudPathOwnerHash[ OwnerPcID ];
end;

function TCloudPathOwnerWriteInfo.FindCloudPathOwnerInfo: Boolean;
begin
  Result := False;
  if not FindCloudPathOwnerHash then
    Exit;

  Result := CloudPathOwnerHash.ContainsKey( OwnerPcID );
  if Result then
    CloudPathOwnerInfo := CloudPathOwnerHash[ OwnerPcID ];
end;

{ TFindCloudPathList }

function TFindCloudPathList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to CloudPathList.Count - 1 do
    Result.Add( CloudPathList[i].CloudPath );
end;

{ TCloudPathOwnerAddInfo }

procedure TCloudPathOwnerAddInfo.SetLastScanTime(_LastScanTime: TDateTime);
begin
  LastScanTime := _LastScanTime;
end;

procedure TCloudPathOwnerAddInfo.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TCloudPathOwnerAddInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindCloudPathOwnerHash then
    Exit;

    // ������, �򴴽�
  AddCloudPathOwnerInfo;

    // ������Ϣ
  CloudPathOwnerInfo.UsedSpace := FileSize;
  CloudPathOwnerInfo.FileCount := FileCount;
  CloudPathOwnerInfo.LastScanTime := LastScanTime;
end;

{ TMyCloudPathIsFileChild }

function TMyCloudFileRootPathRead.get: string;
var
  i : Integer;
begin
  Result := '';

  for i := 0 to CloudPathList.Count - 1 do
    if MyMatchMask.CheckEqualsOrChild( CloudFilePath, CloudPathList[i].CloudPath ) then
    begin
      Result := CloudPathList[i].CloudPath;
      Break;
    end;
end;

procedure TMyCloudFileRootPathRead.SetCloudFilePath(_CloudFilePath: string);
begin
  CloudFilePath := _CloudFilePath;
end;

{ TMyCloudPathUserSpaceRead }

function TMyCloudPathUserSpaceRead.get: Int64;
var
  i : Integer;
  pp : TCloudPathOwnerPair;
begin
  Result := 0;
  for i := 0 to CloudPathList.Count - 1 do
    for pp in CloudPathList[i].CloudPathOwnerHash do
      Result := Result + pp.Value.UsedSpace;
end;

{ TCloudPathOnlineScanInfo }

procedure TCloudPathOnlineScanInfo.OnlineScan(CloudPath: string);
var
  CloudScanPathInfo : TCloudScanPathInfo;
begin
  CloudScanPathInfo := TCloudScanPathInfo.Create( CloudPath, PcID );
  MyCloudFileScanner.AddScanPath( CloudScanPathInfo );
end;

procedure TCloudPathOnlineScanInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TCloudPathOnlineScanInfo.Update;
var
  i : Integer;
  CloudPath, CloudPcPath : string;
  LastScanTime : TDateTime;
begin
  inherited;
  for i := 0 to CloudPathList.Count - 1 do
  begin
    CloudPath := CloudPathList[i].CloudPath;
    if CloudPathList[i].CloudPathOwnerHash.ContainsKey( PcID ) then
    begin
      LastScanTime := CloudPathList[i].CloudPathOwnerHash[ PcID ].LastScanTime;
      if DaysBetween( Now, LastScanTime ) >= 1 then // 1�� ɨ��һ��
        OnlineScan( CloudPath );
    end
    else
    begin
      CloudPcPath := MyFilePath.getPath( CloudPath ) + PcID;
      if DirectoryExists( CloudPath ) then // Ŀ¼����
        OnlineScan( CloudPath );
    end;
  end;

end;

{ TCloudPathOwnerSetLastScanTimeInfo }

procedure TCloudPathOwnerSetLastScanTimeInfo.SetLastScanTime(
  _LastScanTime: TDateTime);
begin
  LastScanTime := _LastScanTime;
end;

procedure TCloudPathOwnerSetLastScanTimeInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindCloudPathOwnerHash then
    Exit;

    // ������, �򴴽�
  AddCloudPathOwnerInfo;

    // ���� ɨ��ʱ��
  CloudPathOwnerInfo.LastScanTime := LastScanTime;
end;

{ TMyCloudPathOwnerSpaceRead }

function TMyCloudPathOwnerSpaceRead.get: Int64;
begin
  Result := 0;

  if not FindCloudPathInfo then
    Exit;

  if CloudPathInfo.CloudPathOwnerHash.ContainsKey( PcID ) then
    Result := CloudPathInfo.CloudPathOwnerHash[ PcID ].UsedSpace;
end;

procedure TMyCloudPathOwnerSpaceRead.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TCloudPathList }

function TCloudPathList.getPath(Path: string): TCloudPathInfo;
var
  PathIndex : Integer;
begin
  PathIndex := getPathIndex( Path );
  if PathIndex >= 0 then
    Result := Self[ PathIndex ]
  else
    Result := nil;
end;

function TCloudPathList.getPathIndex(Path: string): Integer;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to Self.Count - 1 do
    if Self[i].CloudPath = Path then
    begin
      Result := i;
      Break;
    end;
end;


procedure TCloudPathList.RemovePath(Path: string);
var
  PathIndex : Integer;
begin
  PathIndex := getPathIndex( Path );
  if PathIndex >= 0 then
    Self.Delete( PathIndex );
end;

end.
