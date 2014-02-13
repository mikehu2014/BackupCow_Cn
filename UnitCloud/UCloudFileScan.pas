unit UCloudFileScan;

interface

uses classes, syncobjs, Generics.Collections, SysUtils, Windows, UMyUtil;

type

    // ɨ��·����Ϣ
  TCloudScanPathInfo = class
  public
    CloudPath : string;
    CloudPathOwner : string;
  public
    constructor Create( _CloudPath, _CloudPathOwner : string );
  end;
  TCloudScanPathList = class( TObjectList<TCloudScanPathInfo> );

    // �ݹ�ɨ��Ŀ¼
  TCloudFolderScanHanlde = class
  public
    FolderPath : string;
    PcID : string;
    SourceFolderPath : string;
  private
    FolderSize : Int64;
    FileCount : Integer;
    SleepCount : Integer;
  public
    constructor Create( _FolderPath : string );
    procedure SetPcID( _PcID : string );
    procedure SetSleepCount( _SleepCount : Integer );
    procedure SetSourceFolderPath( _SourceFolderPath : string );
    procedure Update;
  private
    function CheckNextScan : Boolean;
    procedure ScanChildFolder( ChildFolderName : string );
  private
    procedure CloudFileConfirm( FileName : string; FileSize : Int64; FileTime : TDateTime );
  end;

    // ���� ɨ��·��
  TCloudScanPathHandle = class
  public
    CloudScanPathInfo : TCloudScanPathInfo;
    CloudPath, CloudPcID : string;
    LastFileSize, FileSize : Int64;
    FileCount : Integer;
  public
    constructor Create( _CloudScanPathInfo : TCloudScanPathInfo );
    procedure Update;
  private
    procedure StartConfirm;
    procedure SetLastScanTime;
  private
    procedure ReadLastFileSize;
    procedure ResetCloudOwnerSpace;
  end;

    // ɨ���߳�
  TCloudFileScanThread = class( TThread )
  private
    Lock : TCriticalSection;
    CloudScanPathList : TCloudScanPathList;
  public
    constructor Create;
    procedure AddScanPath( CloudScanPathInfo : TCloudScanPathInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getScanPath : TCloudScanPathInfo;
    procedure HandleScanPath( CloudScanPathInfo : TCloudScanPathInfo );
  end;

    // ���ļ� ɨ��
  TMyCloudFileScanner = class
  public
    IsRun : Boolean;
    CloudFileScanThread : TCloudFileScanThread;
  public
    constructor Create;
    procedure AddScanPath( CloudScanPathInfo : TCloudScanPathInfo );
    procedure StopScan;
  end;

var
  MyCloudFileScanner : TMyCloudFileScanner;

implementation

uses UBackupFileConfirm, UMyNetPcInfo, UMyCloudFileControl, UMyCloudPathInfo;

{ TCloudFileScanThread }

procedure TCloudFileScanThread.AddScanPath(
  CloudScanPathInfo: TCloudScanPathInfo);
begin
  Lock.Enter;
  CloudScanPathList.Add( CloudScanPathInfo );
  Lock.Leave;

  Resume;
end;

constructor TCloudFileScanThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  CloudScanPathList := TCloudScanPathList.Create;
  CloudScanPathList.OwnsObjects := False;
end;

destructor TCloudFileScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  CloudScanPathList.OwnsObjects := True;
  CloudScanPathList.Free;
  Lock.Free;
  inherited;
end;

procedure TCloudFileScanThread.Execute;
var
  ScanPathInfo : TCloudScanPathInfo;
begin
  while not Terminated do
  begin
    ScanPathInfo := getScanPath;
    if ScanPathInfo = nil then
    begin
      Suspend;
      Continue;
    end;
    HandleScanPath( ScanPathInfo );
    ScanPathInfo.Free;
  end;
  inherited;
end;

function TCloudFileScanThread.getScanPath: TCloudScanPathInfo;
begin
  Lock.Enter;
  if CloudScanPathList.Count > 0 then
  begin
    Result := CloudScanPathList[0];
    CloudScanPathList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TCloudFileScanThread.HandleScanPath(
  CloudScanPathInfo: TCloudScanPathInfo);
var
  CloudScanPathHandle : TCloudScanPathHandle;
begin
  CloudScanPathHandle := TCloudScanPathHandle.Create( CloudScanPathInfo );
  CloudScanPathHandle.Update;
  CloudScanPathHandle.Free;
end;

{ TCloudScanPathInfo }

constructor TCloudScanPathInfo.Create(_CloudPath, _CloudPathOwner: string);
begin
  CloudPath := _CloudPath;
  CloudPathOwner := _CloudPathOwner;
end;

{ TCloudFileScanHandle }

constructor TCloudScanPathHandle.Create(_CloudScanPathInfo: TCloudScanPathInfo);
begin
  CloudScanPathInfo := _CloudScanPathInfo;
  CloudPath := CloudScanPathInfo.CloudPath;
  CloudPcID := CloudScanPathInfo.CloudPathOwner;
end;

procedure TCloudScanPathHandle.ReadLastFileSize;
begin
  LastFileSize := MyCloudPathInfoUtil.ReadCloudPcFileSize( CloudPath, CloudPcID );
end;

procedure TCloudScanPathHandle.ResetCloudOwnerSpace;
var
  CloudPathOwnerSpaceSetHandle : TCloudPathOwnerSpaceSetHandle;
begin
  CloudPathOwnerSpaceSetHandle := TCloudPathOwnerSpaceSetHandle.Create( CloudPath );
  CloudPathOwnerSpaceSetHandle.SetOwnerPcID( CloudPcID );
  CloudPathOwnerSpaceSetHandle.SetSpaceInfo( FileSize, FileCount );
  CloudPathOwnerSpaceSetHandle.SetLastFileSize( LastFileSize );
  CloudPathOwnerSpaceSetHandle.Update;
  CloudPathOwnerSpaceSetHandle.Free;
end;

procedure TCloudScanPathHandle.SetLastScanTime;
var
  CloudPathOwnerSetLastScanTimeHandle : TCloudPathOwnerSetLastScanTimeHandle;
begin
    // ���ߣ�û����ȫȷ��
  if not MyNetPcInfoReadUtil.ReadIsOnline( CloudPcID ) then
    Exit;

    // ���� ���ɨ��ʱ��
  CloudPathOwnerSetLastScanTimeHandle := TCloudPathOwnerSetLastScanTimeHandle.Create( CloudPath );
  CloudPathOwnerSetLastScanTimeHandle.SetOwnerPcID( CloudPcID );
  CloudPathOwnerSetLastScanTimeHandle.SetLastScanTime( Now );
  CloudPathOwnerSetLastScanTimeHandle.Update;
  CloudPathOwnerSetLastScanTimeHandle.Free;
end;

procedure TCloudScanPathHandle.StartConfirm;
begin
  MyFileConfirm.StartConfirm;
end;

procedure TCloudScanPathHandle.Update;
var
  ScanPath : string;
  CloudFolderScanHanlde : TCloudFolderScanHanlde;
begin
    // ��ȡ ��һ�� �ռ���Ϣ
  ReadLastFileSize;

    // ��ȡ ɨ��·��
  ScanPath := MyFilePath.getPath( CloudPath ) + CloudPcID;

    // ������Ҫ ȷ�ϵ��ļ�
  CloudFolderScanHanlde := TCloudFolderScanHanlde.Create( ScanPath );
  CloudFolderScanHanlde.SetPcID( CloudPcID );
  CloudFolderScanHanlde.SetSourceFolderPath( '' );
  CloudFolderScanHanlde.Update;
  FileSize := CloudFolderScanHanlde.FolderSize;
  FileCount := CloudFolderScanHanlde.FileCount;
  CloudFolderScanHanlde.Free;

    // ��ʼ ȷ��
  StartConfirm;

    // ���½����Ѿ�ȷ��
  SetLastScanTime;

    // �������� �ռ���Ϣ
  ResetCloudOwnerSpace;
end;

{ TCloudFolderScanHanlde }

function TCloudFolderScanHanlde.CheckNextScan: Boolean;
begin
  Inc( SleepCount );
  if SleepCount >= 10 then
  begin
    Sleep(1);
    SleepCount := 0;
  end;

  Result := MyCloudFileScanner.IsRun;
end;

procedure TCloudFolderScanHanlde.CloudFileConfirm(FileName: string;
  FileSize: Int64; FileTime: TDateTime);
var
  SourceFilePath : string;
  ConfirmFileInfo : TConfirmFileInfo;
begin
  SourceFilePath := MyFilePath.getPath( SourceFolderPath ) + FileName;
  SourceFilePath := MyFilePath.getUploadPath( SourceFilePath );

  ConfirmFileInfo := TConfirmFileInfo.Create;
  ConfirmFileInfo.SetFileName( SourceFilePath );
  ConfirmFileInfo.SetFileInfo( FileSize, FileTime );
  MyFileConfirm.AddCloudFileConfirm( PcID, ConfirmFileInfo );
end;

constructor TCloudFolderScanHanlde.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
  FolderSize := 0;
  FileCount := 0;
  SleepCount := 0;
end;

procedure TCloudFolderScanHanlde.ScanChildFolder(ChildFolderName: string);
var
  ChildFolderPath, ChildSourceFolderPath : string;
  CloudFolderScanHanlde : TCloudFolderScanHanlde;
begin
  ChildFolderPath := MyFilePath.getPath( FolderPath ) + ChildFolderName;
  ChildSourceFolderPath := MyFilePath.getPath( SourceFolderPath ) + ChildFolderName;

  CloudFolderScanHanlde := TCloudFolderScanHanlde.Create( ChildFolderPath );
  CloudFolderScanHanlde.SetPcID( PcID );
  CloudFolderScanHanlde.SetSleepCount( SleepCount );
  CloudFolderScanHanlde.SetSourceFolderPath( ChildSourceFolderPath );
  CloudFolderScanHanlde.Update;
  FolderSize := FolderSize + CloudFolderScanHanlde.FolderSize;
  FileCount := FileCount + CloudFolderScanHanlde.FileCount;
  SleepCount := CloudFolderScanHanlde.SleepCount;
  CloudFolderScanHanlde.Free;
end;

procedure TCloudFolderScanHanlde.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TCloudFolderScanHanlde.SetSleepCount(_SleepCount: Integer);
begin
  SleepCount := _SleepCount;
end;

procedure TCloudFolderScanHanlde.SetSourceFolderPath(_SourceFolderPath: string);
begin
  SourceFolderPath := _SourceFolderPath;
end;

procedure TCloudFolderScanHanlde.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName, FilePath : string;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      FilePath := SearcFullPath + FileName;

        // �����һ��Ŀ¼
      if DirectoryExists( FilePath )  then
        ScanChildFolder( FileName )
      else
      begin
        FileSize := sch.Size;

          // ��ȡ�޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ���ͳ����Ϣ
        Inc( FileCount );
        FolderSize := FolderSize + FileSize;


          // ����ļ���Ϣ
        CloudFileConfirm( FileName, FileSize, FileTime );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

{ TMyCloudFileScanner }

procedure TMyCloudFileScanner.AddScanPath(
  CloudScanPathInfo: TCloudScanPathInfo);
begin
  if not IsRun then
    Exit;
  CloudScanPathInfo.Free;
//  CloudFileScanThread.AddScanPath( CloudScanPathInfo );
end;

constructor TMyCloudFileScanner.Create;
begin
  CloudFileScanThread := TCloudFileScanThread.Create;
  IsRun := True;
end;

procedure TMyCloudFileScanner.StopScan;
begin
  IsRun := False;
  CloudFileScanThread.Free;
end;

end.
