unit UClouFileOnlineCheck;

interface

uses classes, SysUtils, UModelUtil, UFileBaseInfo, UMyUtil, SyncObjs;

type

    // �ݹ� Ŀ¼�� �����ļ�
  TFindCloudFileOnlineCheck = class
  private
    FullPath : string;
    CloudPcPath, CloudPcID : string;
    TempCloudFolderInfo : TTempCloudFolderInfo;
  public
    constructor Create( _FullPath : string );
    procedure SetCloudPcInfo( _CloudPcPath, _CloudPcID : string );
    procedure Update;
  private
    procedure FindTempCloudFolderInfo;
    procedure CheckFileLostConn;
    procedure CheckFolderLostConn;
    procedure DeleteTempCloudFolderInfo;
  protected
    function CheckNextSearch : Boolean;
    procedure CloudFileCheck( FileInfo : TTempCloudFileInfo );
  end;

    // ��⴦��
  TCloudFileOnlineCheckHandle = class
  public
    OnlinePcID : string;
    CloudPcPathList : TStringList;
  public
    constructor Create( _OnlinePcID : string );
    procedure Update;
  private
    procedure FindCloudPcPathList;
    procedure CheckCloudPcPathList;
    procedure DeleteCloudPcPathList;
  end;

    // ����߳�
  TCloudFileOnlineCheckThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure CheckOnliePcHandle( OnlinePcID : string );
  end;

    // ��� ���� Pc �ļ�
  TMyCloudFileOnlineCheckInfo = class
  public
    IsRun : Boolean;
  public
    Lock : TCriticalSection;
    OnlineCheckPcIDList : TStringList;
  public
    CloudFileOnlineCheckThread : TCloudFileOnlineCheckThread;
  public
    constructor Create;
    procedure StopCheck;
    destructor Destroy; override;
  public
    procedure AddOnlinePc( PcID : string );
    function getCheckPcID : string;
  end;

var
  MyCloudFileOnlineCheckInfo : TMyCloudFileOnlineCheckInfo;

implementation

uses UMyBackupInfo, UMyClient, UMyNetPcInfo, UMyCloudPathInfo;

{ TBackupFileLostConnScan }

procedure TFindCloudFileOnlineCheck.CloudFileCheck( FileInfo : TTempCloudFileInfo );
var
  FilePath, FileStatus : string;
  FileSize : Int64;
  FileTime : TDateTime;
  CloudFileOnlineCheckMsg : TCloudFileOnlineCheckMsg;
begin
  FileSize := FileInfo.FileSize;
  FileTime := FileInfo.LastWriteTime;
  FileStatus := FileInfo.FileStatus;
  FilePath := MyFilePath.getPath( FullPath ) + FileInfo.FileName;

    // �����ļ� ���
  CloudFileOnlineCheckMsg := TCloudFileOnlineCheckMsg.Create;
  CloudFileOnlineCheckMsg.SetPcID( PcInfo.PcID );
  CloudFileOnlineCheckMsg.SetFilePath( FilePath );
  CloudFileOnlineCheckMsg.SetFileInfo( FileSize, FileTime );
  CloudFileOnlineCheckMsg.SetFileStatus( FileStatus );
  MyClient.SendMsgToPc( CloudPcID, CloudFileOnlineCheckMsg );
end;

procedure TFindCloudFileOnlineCheck.CheckFileLostConn;
var
  FileHash : TTempCloudFileHash;
  p : TTempCloudFilePair;
begin
  FileHash := TempCloudFolderInfo.TempCloudFileHash;
  for p in FileHash do
  begin
      // �������
    if not CheckNextSearch then
      Break;

      // ���ļ� ���
    CloudFileCheck( p.Value );
  end;
end;

procedure TFindCloudFileOnlineCheck.CheckFolderLostConn;
var
  TempFolderHash : TTempCloudFolderHash;
  p : TTempCloudFolderPair;
  ChildPath : string;
  FindCloudFileOnlineCheck : TFindCloudFileOnlineCheck;
begin
  TempFolderHash := TempCloudFolderInfo.TempCloudFolderHash;
  for p in TempFolderHash do
  begin
    if not CheckNextSearch then
      Break;

    ChildPath := MyFilePath.getPath( FullPath ) + p.Value.FileName;

      // �ݹ�Ŀ¼
    FindCloudFileOnlineCheck := TFindCloudFileOnlineCheck.Create( ChildPath );
    FindCloudFileOnlineCheck.SetCloudPcInfo( CloudPcPath, CloudPcID );
    FindCloudFileOnlineCheck.Update;
    FindCloudFileOnlineCheck.Free;
  end;
end;

function TFindCloudFileOnlineCheck.CheckNextSearch: Boolean;
begin
  Sleep(100);

  Result := MyCloudFileOnlineCheckInfo.IsRun and
            MyNetPcInfoReadUtil.ReadIsOnline( CloudPcID );
end;

constructor TFindCloudFileOnlineCheck.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TFindCloudFileOnlineCheck.DeleteTempCloudFolderInfo;
begin
  TempCloudFolderInfo.Free;
end;

procedure TFindCloudFileOnlineCheck.FindTempCloudFolderInfo;
var
  CloudFolderPath : string;
  FindTempCloudFolderInfo : TFindCloudFolderInfo;
begin
  if FullPath = '' then
    CloudFolderPath := CloudPcPath
  else
    CloudFolderPath := MyFilePath.getPath( CloudPcPath ) + FullPath;

    // ��ȡ��������
  TempCloudFolderInfo := MyCloudFolderInfoUtil.ReadTempFolderInfo( CloudFolderPath );
end;

procedure TFindCloudFileOnlineCheck.SetCloudPcInfo(_CloudPcPath,
  _CloudPcID: string);
begin
  CloudPcPath := _CloudPcPath;
  CloudPcID := _CloudPcID;
end;

procedure TFindCloudFileOnlineCheck.Update;
begin
    // ��ȡ ��������
  FindTempCloudFolderInfo;

    // ���� Job
  CheckFileLostConn;

    // ���� ��Ŀ¼ Job
  CheckFolderLostConn;

    // ɾ����������
  DeleteTempCloudFolderInfo;
end;


{ TBackupFileOnlineCheckThread }

procedure TCloudFileOnlineCheckThread.CheckOnliePcHandle( OnlinePcID : string );
var
  BackupFileOnlineCheckHandle : TCloudFileOnlineCheckHandle;
begin
  BackupFileOnlineCheckHandle := TCloudFileOnlineCheckHandle.Create( OnlinePcID );
  BackupFileOnlineCheckHandle.Update;
  BackupFileOnlineCheckHandle.Free;
end;

constructor TCloudFileOnlineCheckThread.Create;
begin
  inherited Create( True )
end;

destructor TCloudFileOnlineCheckThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TCloudFileOnlineCheckThread.Execute;
var
  OnlinePcID : string;
begin
  while not Terminated do
  begin
    OnlinePcID := MyCloudFileOnlineCheckInfo.getCheckPcID;

      // ������ �����߻���
    if OnlinePcID = '' then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // �������
    if Terminated then
      Break;

      // ������� Pc
    CheckOnliePcHandle( OnlinePcID );
  end;

  inherited;
end;

{ TMyBackupFileOnlineCheckInfo }

procedure TMyCloudFileOnlineCheckInfo.AddOnlinePc(PcID: string);
var
  PcIndex : Integer;
begin
  Lock.Enter;
  PcIndex := OnlineCheckPcIDList.IndexOf( PcID );
  if PcIndex < 0 then
    OnlineCheckPcIDList.Add( PcID );
  Lock.Leave;

  CloudFileOnlineCheckThread.Resume;
end;

constructor TMyCloudFileOnlineCheckInfo.Create;
begin
  IsRun := True;
  Lock := TCriticalSection.Create;
  OnlineCheckPcIDList := TStringList.Create;
  CloudFileOnlineCheckThread := TCloudFileOnlineCheckThread.Create;
end;

destructor TMyCloudFileOnlineCheckInfo.Destroy;
begin
  IsRun := False;
  OnlineCheckPcIDList.Free;
  Lock.Free;
  inherited;
end;

function TMyCloudFileOnlineCheckInfo.getCheckPcID: string;
begin
  Lock.Enter;
  if OnlineCheckPcIDList.Count > 0 then
  begin
    Result := OnlineCheckPcIDList[ 0 ];
    OnlineCheckPcIDList.Delete( 0 );
  end
  else
    Result := '';
  Lock.Leave;
end;

procedure TMyCloudFileOnlineCheckInfo.StopCheck;
begin
  IsRun := False;
  CloudFileOnlineCheckThread.Free;
end;

{ TBackupFileOnlineCheckHandle }

procedure TCloudFileOnlineCheckHandle.CheckCloudPcPathList;
var
  i : Integer;
  CloudPcPath : string;
  FindCloudFileOnlineCheck : TFindCloudFileOnlineCheck;
begin
  for i := 0 to CloudPcPathList.Count - 1 do
  begin
    CloudPcPath := CloudPcPathList[i];

    FindCloudFileOnlineCheck := TFindCloudFileOnlineCheck.Create( '' );
    FindCloudFileOnlineCheck.SetCloudPcInfo( CloudPcPath, OnlinePcID );
    FindCloudFileOnlineCheck.Update;
    FindCloudFileOnlineCheck.Free;
  end;
end;

constructor TCloudFileOnlineCheckHandle.Create( _OnlinePcID : string );
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TCloudFileOnlineCheckHandle.DeleteCloudPcPathList;
begin
  CloudPcPathList.Free;
end;

procedure TCloudFileOnlineCheckHandle.FindCloudPcPathList;
begin
  CloudPcPathList := MyCloudPathInfoUtil.ReadPcCloudPathList( OnlinePcID );
end;


procedure TCloudFileOnlineCheckHandle.Update;
begin
    // ��ȡ ��������
  FindCloudPcPathList;

    // �ݹ��� Pc ��·��
  CheckCloudPcPathList;

    // ɾ�� ��������
  DeleteCloudPcPathList;
end;

end.
