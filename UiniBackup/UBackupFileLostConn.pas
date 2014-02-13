unit UBackupFileLostConn;

interface

uses Classes, SysUtils, DateUtils, UModelUtil, UFileBaseInfo, UMyUtil, Math;

type

    // �ݹ� Ŀ¼�� �����ļ�
  TFindBackupLostConn = class
  private
    ScanPath : string;
    LostConnPcHash : TStringHash;
  private
    ScanCount : Integer;
  public
    constructor Create;
    procedure SetScanPath( _ScanPath : string );
    procedure SetLostConnPcHash( _LostConnPcHash : TStringHash );
    procedure SetScanInfo( _ScanCount : Integer );
    procedure Update;virtual;abstract;
  protected
    function getFilePath( FileName : string ): string; virtual;
    procedure CheckFileInfo( FileInfo : TTempBackupFileInfo );
  private
    procedure RemoveLoadedCopy( PcID : string; FileInfo : TTempBackupFileInfo );
    procedure RemoveOfflineCopy( PcID, FileName : string );
  end;

    // ����Ŀ¼
  TFindBackupFolderLostConn = class( TFindBackupLostConn )
  protected
    TempBackupFolderInfo : TTempBackupFolderInfo;
  public
    procedure Update;override;
  private
    procedure FindTempBackupFolderInfo;
    procedure CheckFileLostConn;
    procedure CheckFolderLostConn;
    procedure DeleteTempBackupFolderInfo;
  private
    function CheckNextSearch : Boolean;
  end;

     // �����ļ�
  TFindBackupFileLostConn = class( TFindBackupLostConn )
  public
    procedure Update;override;
  protected
    function getFilePath( FileName : string ): string;override;
  end;

    // ����
  TCheckPcLostConnHandle = class
  private
    LostConnMin : Integer;
    LostConnPcHash : TStringHash;
    BackupPathHash : TStringHash;
  public
    constructor Create( _LostConnMin : Integer );
    procedure Update;
    destructor Destroy; override;
  private
    function FindLostConnPcHash : Boolean;
    function FindBackupPathHash: Boolean;
    procedure FindLostConnFile;
  end;

    // ��ʱ ��� ���ݸ�������
  TBackupFileLostConnThread = class( TThread )
  private
    WaitMins, TotalMins : Integer;
    IsNowCheck : Boolean;
  public
    constructor Create;
    procedure NowCheck;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure CheckPcLostConn;
    procedure ResetWaitMins;
  end;

    // ��� ���ݸ������� ������
  TMyBackupFileLostConnInfo = class
  private
    IsRun : Boolean;
    BackupFileLostConnThread : TBackupFileLostConnThread;
  public
    constructor Create;
    procedure StartLostConnScan;
    procedure LostConnScanNow;
    procedure StopLostConnScan;
    destructor Destroy; override;
  end;

const
  ScanCount_Sleep : Integer = 10;

var
  MyBackupFileLostConnInfo : TMyBackupFileLostConnInfo;

implementation

uses USettingInfo, UMyNetPcInfo, UMyBackupInfo, UBackupInfoXml, UBackupInfoControl, UBackupInfoFace;

{ TBackupFileLostConnThread }

procedure TBackupFileLostConnThread.CheckPcLostConn;
var
  CheckPcLostConnHandle : TCheckPcLostConnHandle;
begin
  CheckPcLostConnHandle := TCheckPcLostConnHandle.Create( TotalMins );
  CheckPcLostConnHandle.Update;
  CheckPcLostConnHandle.Free;
end;

constructor TBackupFileLostConnThread.Create;
begin
  inherited Create( True );
end;

destructor TBackupFileLostConnThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupFileLostConnThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
      // ���� �ȴ�ʱ��
    ResetWaitMins;

      // �ȴ��������
    IsNowCheck := False;
    StartTime := Now;
    while not Terminated and not IsNowCheck and
         ( MinutesBetween( Now, StartTime ) < WaitMins ) do
      Sleep(100);

      // �������
    if Terminated then
      Break;

      // ���� ����ʱ��
    ResetWaitMins;

      // ��� ��û�� Pc ����
    CheckPcLostConn;
  end;

  inherited;
end;

procedure TBackupFileLostConnThread.NowCheck;
begin
  IsNowCheck := True;
end;

procedure TBackupFileLostConnThread.ResetWaitMins;
var
  NewTotalMinus : Integer;
begin
  NewTotalMinus := TimeTypeUtil.getMins( CloudFileSafeSettingInfo.CloudSafeType, CloudFileSafeSettingInfo.CloudSafeValue );

  TotalMins := NewTotalMinus;
  WaitMins := Min( NewTotalMinus div 2, 60);
end;

{ TCheckPcLostConnHandle }

constructor TCheckPcLostConnHandle.Create( _LostConnMin : Integer );
begin
  LostConnMin := _LostConnMin;
  LostConnPcHash := TStringHash.Create;
  BackupPathHash := TStringHash.Create;
end;

destructor TCheckPcLostConnHandle.Destroy;
begin
  BackupPathHash.Free;
  LostConnPcHash.Free;
  inherited;
end;

function TCheckPcLostConnHandle.FindBackupPathHash : Boolean;
var
  FindBackupPathInPcInfo : TFindBackupPathInPcInfo;
begin
  FindBackupPathInPcInfo := TFindBackupPathInPcInfo.Create( LostConnPcHash );
  FindBackupPathInPcInfo.SetOutput( BackupPathHash );
  FindBackupPathInPcInfo.Update;
  FindBackupPathInPcInfo.Free;

  Result := BackupPathHash.Count > 0;
end;

procedure TCheckPcLostConnHandle.FindLostConnFile;
var
  i : Integer;
  p : TStringPart;
  FullPath : string;
  FindBackupLostConn : TFindBackupLostConn;
begin
  for p in BackupPathHash do
  begin
    FullPath := p.Value;

    if FileExists( FullPath ) then
      FindBackupLostConn := TFindBackupFileLostConn.Create
    else
      FindBackupLostConn := TFindBackupFolderLostConn.Create;
    FindBackupLostConn.SetScanPath( FullPath );
    FindBackupLostConn.SetLostConnPcHash( LostConnPcHash );
    FindBackupLostConn.Update;
    FindBackupLostConn.Free;
  end;
end;

function TCheckPcLostConnHandle.FindLostConnPcHash: Boolean;
var
  NetPcInfoHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcInfoHash do
    if ( not p.Value.IsOnline ) and
       ( MinutesBetween( Now, p.Value.LastOnlineTime ) >= LostConnMin  )
    then
      LostConnPcHash.AddString( p.Value.PcID );
  MyNetPcInfo.LeaveData;

  Result := NetPcInfoHash.Count > 0;
end;

procedure TCheckPcLostConnHandle.Update;
begin
    // Ѱ�� ���� Pc
  if not FindLostConnPcHash then
    Exit;

    // Ѱ�� ���� Pc ���ݵĸ�Ŀ¼
  if not FindBackupPathHash then
    Exit;

    // Ѱ�ҹ��ڵ��ļ�
  FindLostConnFile;
end;

{ TBackupFileLostConnScan }

procedure TFindBackupLostConn.RemoveOfflineCopy(PcID, FileName: string);
var
  FilePath : string;
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
  BackupFileSyncHandle : TBackupFileSyncHandle;
begin
  FilePath := getFilePath( FileName );

    // ɾ�� Backup Copy Info
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;

    // ���� ͬ���ļ�
  BackupFileSyncHandle := TBackupFileSyncHandle.Create( FilePath );
  BackupFileSyncHandle.Update;
  BackupFileSyncHandle.Free;
end;

procedure TFindBackupLostConn.RemoveLoadedCopy(PcID : string; FileInfo : TTempBackupFileInfo);
var
  FilePath : string;
  BackupCopyRemoveControl : TBackupCopyRemoveControl;
begin
  FilePath := getFilePath( FileInfo.FileName );

    // ɾ�� ����
  BackupCopyRemoveControl := TBackupCopyRemoveControl.Create( FilePath, PcID );
  BackupCopyRemoveControl.SetFileSize( FileInfo.FileSize );
  BackupCopyRemoveControl.Update;
  BackupCopyRemoveControl.Free;
end;

procedure TFindBackupLostConn.CheckFileInfo(FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  p : TTempCopyPair;
begin
    // �������� ������Ϣ
  CopyHash := FileInfo.TempCopyHash;
  for p in CopyHash do
    if LostConnPcHash.ContainsKey( p.Value.CopyOwner ) then
    begin
      if p.Value.Status = CopyStatus_Loaded then
        RemoveLoadedCopy( p.Value.CopyOwner, FileInfo )
      else
        RemoveOfflineCopy( p.Value.CopyOwner, FileInfo.FileName );
    end;
end;

constructor TFindBackupLostConn.Create;
begin
  ScanCount := 0;
end;

function TFindBackupLostConn.getFilePath(FileName: string): string;
begin
  Result := MyFilePath.getPath( ScanPath ) + FileName;
end;

procedure TFindBackupLostConn.SetLostConnPcHash(
  _LostConnPcHash: TStringHash);
begin
  LostConnPcHash := _LostConnPcHash;
end;

procedure TFindBackupLostConn.SetScanInfo(_ScanCount: Integer);
begin
  ScanCount := _ScanCount;
end;

procedure TFindBackupLostConn.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

{ TMyBackupFileLostConnInfo }

constructor TMyBackupFileLostConnInfo.Create;
begin
  IsRun := True;
  BackupFileLostConnThread := TBackupFileLostConnThread.Create;
end;

destructor TMyBackupFileLostConnInfo.Destroy;
begin
  IsRun := False;
  inherited;
end;

procedure TMyBackupFileLostConnInfo.LostConnScanNow;
begin
  BackupFileLostConnThread.NowCheck;
end;

procedure TMyBackupFileLostConnInfo.StartLostConnScan;
begin
  BackupFileLostConnThread.Resume;
end;

procedure TMyBackupFileLostConnInfo.StopLostConnScan;
begin
  IsRun := False;
  BackupFileLostConnThread.Free;
end;

{ TFindBackupFolderLostConn }

procedure TFindBackupFolderLostConn.CheckFileLostConn;
var
  FileHash : TTempBackupFileHash;
  p : TTempBackupFilePair;
begin
  FileHash := TempBackupFolderInfo.TempBackupFileHash;
  for p in FileHash do
  begin
      // �������
    if not CheckNextSearch then
      Break;

      // ����ļ��Ƿ��������Pc
    CheckFileInfo( p.Value );
  end;
end;

procedure TFindBackupFolderLostConn.CheckFolderLostConn;
var
  TempFolderHash : TTempBackupFolderHash;
  p : TTempBackupFolderPair;
  ChildPath : string;
  FindBackupFolderLostConn : TFindBackupFolderLostConn;
begin
  TempFolderHash := TempBackupFolderInfo.TempBackupFolderHash;
  for p in TempFolderHash do
  begin
    if not CheckNextSearch then
      Break;

    ChildPath := MyFilePath.getPath( ScanPath ) + p.Value.FileName;

      // �ݹ�Ŀ¼
    FindBackupFolderLostConn := TFindBackupFolderLostConn.Create;
    FindBackupFolderLostConn.SetScanPath( ChildPath );
    FindBackupFolderLostConn.SetLostConnPcHash( LostConnPcHash );
    FindBackupFolderLostConn.SetScanInfo( ScanCount );
    FindBackupFolderLostConn.Update;
    ScanCount := FindBackupFolderLostConn.ScanCount;
    FindBackupFolderLostConn.Free;
  end;
end;

function TFindBackupFolderLostConn.CheckNextSearch: Boolean;
begin
  inc( ScanCount );
  if ScanCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    ScanCount := 0;
  end;

  Result := MyBackupFileLostConnInfo.IsRun;
end;

procedure TFindBackupFolderLostConn.DeleteTempBackupFolderInfo;
begin
  TempBackupFolderInfo.Free;
end;

procedure TFindBackupFolderLostConn.FindTempBackupFolderInfo;
begin
  TempBackupFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderInfo( ScanPath );
end;

procedure TFindBackupFolderLostConn.Update;
begin
    // ��ȡ ����Ŀ¼ ������Ϣ
  FindTempBackupFolderInfo;

    // ���� Job
  CheckFileLostConn;

    // ���� ��Ŀ¼ Job
  CheckFolderLostConn;

    // ɾ�� ������Ϣ
  DeleteTempBackupFolderInfo;
end;

{ TFindBackupFileLostConn }

function TFindBackupFileLostConn.getFilePath(FileName: string): string;
begin
  Result := ScanPath;
end;

procedure TFindBackupFileLostConn.Update;
var
  TempBackupFileInfo : TTempBackupFileInfo;
begin
    // ��ȡ�ļ�����
  TempBackupFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileInfo( ScanPath );

    // �ļ�������
  if TempBackupFileInfo = nil then
    Exit;

    // ����ļ��Ƿ���� ����Pc
  CheckFileInfo( TempBackupFileInfo );
end;

end.
