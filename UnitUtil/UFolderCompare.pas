unit UFolderCompare;

interface

uses Generics.Collections, dateUtils, SysUtils, Winapi.Windows, UModelUtil, UMyUtil;

type

    // �������ļ���Ϣ
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

  {$Region ' ɨ������Ϣ ' }

    // �ļ��ȽϽ��
  TScanResultInfo = class
  public
    SourceFilePath : string;
  public
    constructor Create( _SourceFilePath : string );
  end;
  TScanResultList = class( TObjectList<TScanResultInfo> );


    // ��� �ļ�
  TScanResultAddFileInfo = class( TScanResultInfo )
  end;

    // ��� Ŀ¼
  TScanResultAddFolderInfo = class( TScanResultInfo )
  end;

    // ɾ�� �ļ�
  TScanResultRemoveFileInfo = class( TScanResultInfo )
  end;

    // ɾ�� Ŀ¼
  TScanResultRemoveFolderInfo = class( TScanResultInfo )
  end;

  {$EndRegion}

    // Ŀ¼�Ƚ��㷨
  TFolderScanHandle = class
  public
    SourceFolderPath : string;
    SleepCount : Integer;
    ScanTime : TDateTime;
  public   // �ļ���Ϣ
    SourceFileHash : TScanFileHash;
    DesFileHash : TScanFileHash;
  public   // Ŀ¼��Ϣ
    SourceFolderHash : TStringHash;
    DesFolderHash : TStringHash;
  public   // �ռ���
    FileCount : Integer;
    FileSize, CompletedSize : Int64;
  public   // �ļ��仯���
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
  protected      // �Ƿ� ֹͣɨ��
    function CheckNextScan : Boolean;virtual;
  protected      // ������
    function IsFileFilter( FilePath : string; sch : TSearchRec ): Boolean;
    function IsFolderFilter( FolderPath : string ): Boolean;
  private        // �ȽϽ��
    function getChildPath( ChildName : string ): string;
    procedure AddFileResult( FileName : string );
    procedure AddFolderResult( FolderName : string );
    procedure RemoveFileResult( FileName : string );
    procedure RemoveFolderResult( FolderName : string );
  protected        // �Ƚ���Ŀ¼
    function getScanHandle : TFolderScanHandle;virtual;abstract;
    procedure CompareChildFolder( SourceFolderName : string );
  end;

    // �ļ��Ƚ��㷨
  TFileScanHandle = class
  public
    SourceFilePath : string;
  public
    SourceFileSize : Int64;
    SourceFileTime : TDateTime;
  public
    DesFileSize : Int64;
    DesFileTime : TDateTime;
  public   // �ռ���
    CompletedSize : Int64;
  public   // �ļ��仯���
    ScanResultList : TScanResultList;
  public
    constructor Create( _SourceFilePath : string );
    procedure SetResultList( _ScanResultList : TScanResultList );
    procedure Update;virtual;
  protected
    procedure FindSourceFileInfo;virtual;abstract;
    function FindDesFileInfo: Boolean;virtual;abstract;
  private        // �ȽϽ��
    function IsEqualsDes : Boolean;
    procedure AddFileResult;
    procedure RemoveFileResult;
  end;

    // ����Դɨ��
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

    // N ���ļ�Сͣһ��
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
    // ���� Դ�ļ�
  for p in SourceFileHash do
  begin
      // ����Ƿ����ɨ��
    if not CheckNextScan then
      Break;

      // ��ӵ�ͳ����Ϣ
    FileSize := FileSize + p.Value.FileSize;
    FileCount := FileCount + 1;

    FileName := p.Value.FileName;

      // Ŀ���ļ�������
    if not DesFileHash.ContainsKey( FileName ) then
    begin
      AddFileResult( FileName );
      Continue;
    end;

      // Ŀ���ļ���Դ�ļ���һ��
    if not p.Value.getEquals( DesFileHash[ FileName ] ) then
    begin
      RemoveFileResult( FileName ); // ��ɾ��
      AddFileResult( FileName );  // �����
    end
    else  // Ŀ���ļ���Դ�ļ�һ��
      CompletedSize := CompletedSize + p.Value.FileSize;

      // ɾ��Ŀ���ļ�
    DesFileHash.Remove( FileName );
  end;

    // ����Ŀ���ļ�
  for p in DesFileHash do
    RemoveFileResult( p.Value.FileName );  // ɾ��Ŀ���ļ�
end;

procedure TFolderScanHandle.FolderCompare;
var
  p : TStringPart;
  FolderName : string;
begin
    // ����ԴĿ¼
  for p in SourceFolderHash do
  begin
    FolderName := p.Value;

      // ������Ŀ��Ŀ¼���򴴽�
    if not DesFolderHash.ContainsKey( FolderName ) then
      AddFolderResult( FolderName )
    else
      DesFolderHash.Remove( FolderName );

      // �Ƚ���Ŀ¼
    CompareChildFolder( FolderName );
  end;

    // ����Ŀ��Ŀ¼
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
    // ��Դ�ļ���Ϣ
  FindSourceFileInfo;

    // ��Ŀ���ļ���Ϣ
  FindDesFileInfo;

    // �ļ��Ƚ�
  FileCompare;

    // Ŀ¼�Ƚ�
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
    // Դ�ļ���Ϣ
  FindSourceFileInfo;

    // Ŀ���ļ�������
  if not FindDesFileInfo then
  begin
    AddFileResult;
    Exit;
  end;

    // Ŀ���ļ���Դ�ļ���һ��
  if not IsEqualsDes then
  begin
    RemoveFileResult;
    AddFileResult;
  end
  else
    CompletedSize := SourceFileSize;
end;

end.
