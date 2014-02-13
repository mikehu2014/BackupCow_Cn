unit UFileConfirm;

interface

Uses UModelUtil, UFileBaseInfo, Generics.Collections, Classes, SyncObjs, Sockets, UMyTcp,
     SysUtils, UBackupInfoControl, UMyUtil;

type

{$Region ' ����ȷ�� ' }

    // ȷ�ϵ��ļ���Ϣ
  TConfirmFileInfo = class( TFileBaseInfo )
  end;
  TConfirmFileList = class( TObjectList< TConfirmFileInfo > );

    // Pc ��Ҫȷ�ϵ��ļ�
  TPcConfirmFileInfo = class
  public
    PcID : string;
    ConfirmFileList : TConfirmFileList;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TPcConfirmFileList = class( TObjectList< TPcConfirmFileInfo > )
  public
    function getPcConfirm( PcID : string ): TPcConfirmFileInfo;
  end;

    // ȷ�� ���ݵ� ĳPc ���ļ� ����
  TPcConfirmHandle = class
  public
    CloudPcConfirmInfo : TPcConfirmFileInfo;
    TcpSocket : TCustomIpClient;
  public
    constructor Create( _CloudPcConfirmInfo : TPcConfirmFileInfo );
    procedure Update;
    destructor Destroy; override;
  private
    function ConnToConfirmPc : Boolean;
    procedure ConfirmAllFile;
  private
    procedure ConfirmFile( ConfirmFileInfo : TConfirmFileInfo );
  private
    function IsNextConfirm : Boolean; // �Ƿ����ȷ��
    procedure FileNotExist( FileInfo : TConfirmFileInfo );virtual;abstract;
  end;

    // ȷ�� �����ļ�
  TBackupFilePcConfirmHandle = class( TPcConfirmHandle )
  private
    procedure FileNotExist( FileInfo : TConfirmFileInfo );override;
  end;

    // ȷ�� ���ļ�
  TCloudFilePcConfirmHandle = class( TPcConfirmHandle )
  private
    procedure FileNotExist( FileInfo : TConfirmFileInfo );override;
  end;


    //ȷ�� �ļ� ���� �߳�
  TFileConfirmThread = class( TThread )
  private
    Lock : TCriticalSection;
    BackupFilePcConfirmList : TPcConfirmFileList;
    CloudFilePcConfirmList : TPcConfirmFileList;
  public
    constructor Create;
    procedure AddBackupFileConfrim( PcID : string; ConfirmFileInfo : TConfirmFileInfo );
    procedure AddCloudFileConfrim( PcID : string; ConfirmFileInfo : TConfirmFileInfo );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    function getBackupFilePcConfrimInfo : TPcConfirmFileInfo;
    function getCloudFilePcConfrimInfo : TPcConfirmFileInfo;
  public
    procedure HandleBackupFilePcConfirm( CloudPcConfirmInfo : TPcConfirmFileInfo );
    procedure HandleCloudFilePcConfirm( CloudPcConfirmInfo : TPcConfirmFileInfo );
  end;

    // ȷ�� ���ݵ� ���ļ� ����
  TMyFileConfirm = class
  private
    FileConfirmThread : TFileConfirmThread;
    IsRun : Boolean;
  public
    constructor Create;
    procedure StopConfirm;
  public
    procedure AddBackupFileConfirm( PcID : string; ConfirmFileInfo : TConfirmFileInfo );
    procedure AddCloudFileConfirm( PcID : string; ConfirmFileInfo : TConfirmFileInfo );
    procedure StartConfirm;
  end;

{$EndRegion}

{$Region ' ����ȷ�� ' }

    // �ж��ļ� �Ƿ����
  TFindFileConfirm = class
  public
    ConfirmPcID, FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetConfirmInfo( _ConfirmPcID, _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    function get : Boolean;virtual;abstract;
  end;

    // �ж� ���ݵ��ļ� �Ƿ����
  TFindBackupFileConfirm = class( TFindFileConfirm )
  public
    function get : Boolean;override;
  end;

    // �ж� ��·���ϵ��ļ� �Ƿ����
  TFindCloudFileConfirm = class( TFindFileConfirm )
  public
    function get : Boolean;override;
  private
    procedure AddNewBackupCopy;
  end;

    // ���� ȷ������
  TAcceptFileConfirmHandle = class
  public
    TcpSocket : TCustomIpClient;
    ConfirmPcID : string;
  public
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    procedure Update;
  private
    procedure ConfirmAllFile;
  protected
    function IsNextConfirm : Boolean; // �Ƿ����ȷ��
    function getFindConfirm : TFindFileConfirm;virtual;abstract;
  end;

    // ���� �����ļ�
  TAcceptBackupFileConfirmHandle = class( TAcceptFileConfirmHandle )
  protected
    function getFindConfirm : TFindFileConfirm;override;
  end;

    // ���� ���ļ�
  TAcceptCloudFileConfirmHandle = class( TAcceptFileConfirmHandle )
  protected
    function getFindConfirm : TFindFileConfirm;override;
  end;

    // �������ȷ���߳�
  TAcceptConfirmFileThread = class( TThread )
  public
    IsConfirming : Boolean;
    TcpSocket : TCustomIpClient;
    ConfirmType : string;
  public
    constructor Create;
    procedure AcceptBackupConfirm( _TcpSocket : TCustomIpClient );
    procedure AcceptCloudConfirm( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;
  TAcceptConfirmFileThreadList = class( TObjectList<TAcceptConfirmFileThread> )
  public
    function getIdelThread : TAcceptConfirmFileThread;
  end;

    // �Է� ȷ�� ���ݵ��ļ� ����
  TMyFileAcceptConfirm = class
  public
    IsRun : Boolean;
    Lock : TCriticalSection;
    AcceptConfirmFileThreadList : TAcceptConfirmFileThreadList;
  public
    constructor Create;
    procedure AddBackupConfirm( TcpSocket : TCustomIpClient );
    procedure AddCloudConfirm( TcpSocket : TCustomIpClient );
    procedure StopConfirm;
    destructor Destroy; override;
  end;

{$EndRegion}

const
  ConfirmType_Backup = 'Backup';
  ConfirmType_Cloud = 'Cloud';

var
  MyFileConfirm : TMyFileConfirm;
  MyFileAcceptConfirm : TMyFileAcceptConfirm;

implementation

uses UMyBackupInfo, UMyCloudPathInfo, UMyNetPcInfo;

{ TCloudPcConfirmInfo }

constructor TPcConfirmFileInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  ConfirmFileList := TConfirmFileList.Create;
end;

destructor TPcConfirmFileInfo.Destroy;
begin
  ConfirmFileList.Free;
  inherited;
end;

{ TCloudFileConfirmThread }

procedure TFileConfirmThread.AddBackupFileConfrim(PcID: string;
  ConfirmFileInfo: TConfirmFileInfo);
var
  CloudPcConfirmInfo : TPcConfirmFileInfo;
begin
  Lock.Enter;
  CloudPcConfirmInfo := BackupFilePcConfirmList.getPcConfirm( PcID );
  CloudPcConfirmInfo.ConfirmFileList.Add( ConfirmFileInfo );
  Lock.Leave;
end;

procedure TFileConfirmThread.AddCloudFileConfrim(PcID: string;
  ConfirmFileInfo: TConfirmFileInfo);
var
  CloudPcConfirmInfo : TPcConfirmFileInfo;
begin
  Lock.Enter;
  CloudPcConfirmInfo := CloudFilePcConfirmList.getPcConfirm( PcID );
  CloudPcConfirmInfo.ConfirmFileList.Add( ConfirmFileInfo );
  Lock.Leave;
end;

constructor TFileConfirmThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  BackupFilePcConfirmList := TPcConfirmFileList.Create;
  BackupFilePcConfirmList.OwnsObjects := False;
  CloudFilePcConfirmList := TPcConfirmFileList.Create;
  CloudFilePcConfirmList.OwnsObjects := False;
end;

destructor TFileConfirmThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  CloudFilePcConfirmList.OwnsObjects := True;
  CloudFilePcConfirmList.Free;
  BackupFilePcConfirmList.OwnsObjects := True;
  BackupFilePcConfirmList.Free;
  Lock.Free;
  inherited;
end;

procedure TFileConfirmThread.Execute;
var
  PcConfirmInfo : TPcConfirmFileInfo;
begin
  while not Terminated do
  begin
    PcConfirmInfo := getBackupFilePcConfrimInfo;

    if PcConfirmInfo <> nil then
      HandleBackupFilePcConfirm( PcConfirmInfo )
    else
    begin
      PcConfirmInfo := getCloudFilePcConfrimInfo;
      if PcConfirmInfo = nil then
      begin
        Suspend;
        Resume;
      end;
      HandleCloudFilePcConfirm( PcConfirmInfo )
    end;

    PcConfirmInfo.Free;
  end;
  inherited;
end;

function TFileConfirmThread.getBackupFilePcConfrimInfo: TPcConfirmFileInfo;
begin
  Lock.Enter;
  if BackupFilePcConfirmList.Count > 0 then
  begin
    Result := BackupFilePcConfirmList[0];
    BackupFilePcConfirmList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

function TFileConfirmThread.getCloudFilePcConfrimInfo: TPcConfirmFileInfo;
begin
  Lock.Enter;
  if CloudFilePcConfirmList.Count > 0 then
  begin
    Result := CloudFilePcConfirmList[0];
    CloudFilePcConfirmList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TFileConfirmThread.HandleBackupFilePcConfirm(
  CloudPcConfirmInfo: TPcConfirmFileInfo);
var
  BackupFilePcConfirmHandle : TBackupFilePcConfirmHandle;
begin
  BackupFilePcConfirmHandle := TBackupFilePcConfirmHandle.Create( CloudPcConfirmInfo );
  BackupFilePcConfirmHandle.Update;
  BackupFilePcConfirmHandle.Free;
end;

procedure TFileConfirmThread.HandleCloudFilePcConfirm(
  CloudPcConfirmInfo: TPcConfirmFileInfo);
var
  CloudFilePcConfirmHandle : TCloudFilePcConfirmHandle;
begin
  CloudFilePcConfirmHandle := TCloudFilePcConfirmHandle.Create( CloudPcConfirmInfo );
  CloudFilePcConfirmHandle.Update;
  CloudFilePcConfirmHandle.Free;
end;


{ TMyBackupFileCloudConfirm }

procedure TMyFileConfirm.AddBackupFileConfirm( PcID : string;
  ConfirmFileInfo : TConfirmFileInfo );
begin
  if not IsRun then
    Exit;

  FileConfirmThread.AddBackupFileConfrim( PcID, ConfirmFileInfo );
end;

procedure TMyFileConfirm.AddCloudFileConfirm(PcID: string;
  ConfirmFileInfo: TConfirmFileInfo);
begin
  if not IsRun then
    Exit;

  FileConfirmThread.AddCloudFileConfrim( PcID, ConfirmFileInfo );
end;

constructor TMyFileConfirm.Create;
begin
  FileConfirmThread := TFileConfirmThread.Create;
  IsRun := True;
end;

procedure TMyFileConfirm.StartConfirm;
begin
  if not IsRun then
    Exit;

  FileConfirmThread.Resume;
end;

procedure TMyFileConfirm.StopConfirm;
begin
  IsRun := False;
  FileConfirmThread.Free;
end;

{ TCloudPcFileConfirmHandle }

procedure TPcConfirmHandle.ConfirmAllFile;
var
  ConfirmFileList : TConfirmFileList;
  i : Integer;
  ConfirmFileInfo : TConfirmFileInfo;
  IsSendConfirm, IsRevConfirm : Boolean;
begin
  ConfirmFileList := CloudPcConfirmInfo.ConfirmFileList;
  for i := 0 to ConfirmFileList.Count - 1 do
  begin
    IsSendConfirm := IsNextConfirm; // �Ƿ��������ȷ��
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsSendConfirm ) );
    IsRevConfirm := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False ); // �Ƿ��������ȷ��

      // ����˫��ͬʱ����ȷ��
    if not IsSendConfirm or not IsRevConfirm then
      Exit;

      // ȷ���ļ�
    ConfirmFileInfo := ConfirmFileList[i];
    ConfirmFile( ConfirmFileInfo );
  end;

    // û���ļ���Ҫȷ����
  MySocketUtil.SendString( TcpSocket, BoolToStr( False ) );
end;

procedure TPcConfirmHandle.ConfirmFile(
  ConfirmFileInfo : TConfirmFileInfo);
var
  IsExistFile : Boolean;
begin
    // �����ļ���Ϣ
  MySocketUtil.SendString( TcpSocket, ConfirmFileInfo.FileName );
  MySocketUtil.SendString( TcpSocket, IntToStr( ConfirmFileInfo.FileSize ) );
  MySocketUtil.SendString( TcpSocket, FloatToStr( ConfirmFileInfo.LastWriteTime ) );

    // ��ȡ �ļ��Ƿ���� ������Ϣ
  IsExistFile := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), True );

    // �ļ����� ����
  if IsExistFile then
    Exit;

    // ���� �ļ�������
  FileNotExist( ConfirmFileInfo );
end;

function TPcConfirmHandle.ConnToConfirmPc: Boolean;
begin

end;

constructor TPcConfirmHandle.Create(
  _CloudPcConfirmInfo: TPcConfirmFileInfo);
begin
  CloudPcConfirmInfo := _CloudPcConfirmInfo;
  TcpSocket := TCustomIpClient.Create(nil);
end;

destructor TPcConfirmHandle.Destroy;
begin
  TcpSocket.Free;
  inherited;
end;

function TPcConfirmHandle.IsNextConfirm: Boolean;
begin
  Result := MyFileConfirm.IsRun;
end;

procedure TPcConfirmHandle.Update;
begin
    // ���Ӳ��� Pc �� Pc ��æ
  if not ConnToConfirmPc then
    Exit;

    // ���ͱ��� PcID
  MySocketUtil.SendString( TcpSocket, PcInfo.PcID );

    // ȷ�ϱ����ļ�����
  ConfirmAllFile;
end;

{ TCloudPcConfirmList }

function TPcConfirmFileList.getPcConfirm(PcID: string): TPcConfirmFileInfo;
var
  i : Integer;
begin
  Result := nil;

    // Ѱ�� Pc
  for i := 0 to Self.Count - 1 do
    if Self[i].PcID = PcID then
    begin
      Result := Self[i];
      Break;
    end;

    // ���� �򷵻�
  if Result <> nil then
    Exit;

    // ������ �򴴽�
  Result := TPcConfirmFileInfo.Create( PcID );
  Self.Add( Result );
end;

{ TMyBackupFileAcceptConfirm }

procedure TMyFileAcceptConfirm.AddBackupConfirm(TcpSocket: TCustomIpClient);
var
  AcceptThread : TAcceptConfirmFileThread;
begin
  if not IsRun then
    Exit;

  Lock.Enter;
  AcceptThread := AcceptConfirmFileThreadList.getIdelThread;
  if AcceptThread <> nil then
    AcceptThread.AcceptBackupConfirm( TcpSocket )
  else
    TcpSocket.Free;
  Lock.Leave;
end;

procedure TMyFileAcceptConfirm.AddCloudConfirm(
  TcpSocket: TCustomIpClient);
var
  AcceptThread : TAcceptConfirmFileThread;
begin
  if not IsRun then
    Exit;

  Lock.Enter;
  AcceptThread := AcceptConfirmFileThreadList.getIdelThread;
  if AcceptThread <> nil then
    AcceptThread.AcceptCloudConfirm( TcpSocket )
  else
    TcpSocket.Free;
  Lock.Leave;
end;

constructor TMyFileAcceptConfirm.Create;
var
  i : Integer;
  AcceptConfirmFileThread : TAcceptConfirmFileThread;
begin
  Lock := TCriticalSection.Create;
  AcceptConfirmFileThreadList := TAcceptConfirmFileThreadList.Create;
  for i := 1 to 5 do
  begin
    AcceptConfirmFileThread := TAcceptConfirmFileThread.Create;
    AcceptConfirmFileThreadList.Add( AcceptConfirmFileThread );
  end;
  IsRun := True;
end;

destructor TMyFileAcceptConfirm.Destroy;
begin
  Lock.Free;
  inherited;
end;

procedure TMyFileAcceptConfirm.StopConfirm;
begin
  IsRun := False;
  AcceptConfirmFileThreadList.Free;
end;

{ TBackupFilePcConfirmHandle }

procedure TBackupFilePcConfirmHandle.FileNotExist(FileInfo: TConfirmFileInfo);
var
  BackupCopyRemoveControl : TBackupCopyRemoveControl;
begin
    // ���ݸ��� ɾ������
  BackupCopyRemoveControl := TBackupCopyRemoveControl.Create( FileInfo.FileName, CloudPcConfirmInfo.PcID );
  BackupCopyRemoveControl.SetFileSize( FileInfo.FileSize );
  BackupCopyRemoveControl.Update;
  BackupCopyRemoveControl.Free;
end;

{ TCloudFilePcConfirmHandle }

procedure TCloudFilePcConfirmHandle.FileNotExist(FileInfo: TConfirmFileInfo);
begin
  inherited;

end;

{ TAcceptConfirmFileThread }

procedure TAcceptConfirmFileThread.AcceptBackupConfirm(_TcpSocket: TCustomIpClient);
begin
  IsConfirming := True;
  TcpSocket := _TcpSocket;
  ConfirmType := ConfirmType_Backup;
  Resume;
end;

procedure TAcceptConfirmFileThread.AcceptCloudConfirm(
  _TcpSocket: TCustomIpClient);
begin
  IsConfirming := True;
  TcpSocket := _TcpSocket;
  ConfirmType := ConfirmType_Cloud;
  Resume;
end;

constructor TAcceptConfirmFileThread.Create;
begin
  inherited Create( True );
  IsConfirming := False;
end;

destructor TAcceptConfirmFileThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TAcceptConfirmFileThread.Execute;
var
  AcceptFileConfirmHandle : TAcceptFileConfirmHandle;
begin
  while not Terminated do
  begin
      // ����ȷ����Ϣ
    if ConfirmType = ConfirmType_Backup then
      AcceptFileConfirmHandle := TAcceptBackupFileConfirmHandle.Create
    else
      AcceptFileConfirmHandle := TAcceptCloudFileConfirmHandle.Create;
    AcceptFileConfirmHandle.SetTcpSocket( TcpSocket );
    AcceptFileConfirmHandle.Update;
    AcceptFileConfirmHandle.Free;

      // �ر�����
    TcpSocket.Free;

      // �����߳�
    IsConfirming := False;
    Suspend;
  end;
  inherited;
end;

{ TAcceptFileConfirmHandle }

procedure TAcceptFileConfirmHandle.ConfirmAllFile;
var
  FilePath : string;
  FileSize : Int64;
  FileTime : TDateTime;
  IsSendConfirm, IsRevConfirm, IsExistFile : Boolean;
  FindFileConfirm : TFindFileConfirm;
begin
  while True do
  begin
      // �Ƿ����ȷ���ļ�
    IsSendConfirm := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False );
    IsRevConfirm := IsNextConfirm;
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsRevConfirm ) );

      // ����˫������
    if not IsSendConfirm or not IsRevConfirm then
      Break;

      // ��ȡ�ļ���Ϣ
    FilePath := MySocketUtil.RevString( TcpSocket );
    FileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), -1 );
    FileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), -1 );

      // �Է��Ͽ�����
    if ( FilePath = '' ) or ( FileSize = -1 ) or ( FileTime = -1 ) then
      Break;

      // ��� �ļ��Ƿ����
    FindFileConfirm := getFindConfirm;
    FindFileConfirm.SetConfirmInfo( ConfirmPcID, FilePath );
    FindFileConfirm.SetFileInfo( FileSize, FileTime );
    IsExistFile := FindFileConfirm.get;
    FindFileConfirm.Free;

      // ���ͷ��� �ļ��Ƿ����
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsExistFile ) );
  end;
end;

function TAcceptFileConfirmHandle.IsNextConfirm: Boolean;
begin
  Result := MyFileAcceptConfirm.IsRun;
end;

procedure TAcceptFileConfirmHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TAcceptFileConfirmHandle.Update;
begin
    // ��ȡ �Է� PcID
  ConfirmPcID := MySocketUtil.RevString( TcpSocket );
  if ConfirmPcID = '' then // �Ͽ�����
    Exit;

    // ȷ�� �Է�ȫ���ļ�
  ConfirmAllFile;
end;

{ TFindFileConfirm }

procedure TFindFileConfirm.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TFindFileConfirm.SetConfirmInfo(_ConfirmPcID, _FilePath: string);
begin
  ConfirmPcID := _ConfirmPcID;
  FilePath := _FilePath;
end;

{ TFindBackupFileConfirm }

function TFindBackupFileConfirm.get: Boolean;
var
  CloudPath, CloudPcPath, CloudFilePath : string;
begin
    // ������ļ�
  CloudPath := MyFilePath.getPath( MyCloudFileInfo.ReadBackupCloudPath );
  CloudPcPath := CloudPath + MyFilePath.getPath( ConfirmPcID );
  CloudFilePath := CloudPcPath + MyFilePath.getDownloadPath( FilePath );

    // ���ļ��Ƿ����
  Result := FileExists( CloudFilePath ) and
            ( MyFileInfo.getFileSize( CloudFilePath ) = FileSize ) and
            ( MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( CloudFilePath ), FileTime ) );
end;

{ TFindCloudFileConfirm }

procedure TFindCloudFileConfirm.AddNewBackupCopy;
var
  BackupCopyAddControl : TBackupCopyAddControl;
begin
  BackupCopyAddControl := TBackupCopyAddControl.Create( FilePath, ConfirmPcID );
  BackupCopyAddControl.SetFileSize( FileSize );
  BackupCopyAddControl.Update;
  BackupCopyAddControl.Free;
end;

function TFindCloudFileConfirm.get: Boolean;
var
  TempBackupFileInfo : TTempBackupFileInfo;
  IsNewBackupCopy : Boolean;
begin
  Result := False;

    // ��ȡ �ļ�������Ϣ
  TempBackupFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileInfo( FilePath );

    // �ļ� ������
  if TempBackupFileInfo = nil then
    Exit;

    // �ļ���Ϣ�Ƿ�һ��
  Result := ( TempBackupFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( TempBackupFileInfo.LastWriteTime, FileTime ) );

    // �µ� Copy
  IsNewBackupCopy := Result and not TempBackupFileInfo.TempCopyHash.ContainsKey( ConfirmPcID );

  TempBackupFileInfo.Free;

    // ��� �µ� Copy
  if IsNewBackupCopy then
    AddNewBackupCopy;
end;

{ TAcceptBackupFileConfirmHandle }

function TAcceptBackupFileConfirmHandle.getFindConfirm: TFindFileConfirm;
begin
  Result := TFindBackupFileConfirm.Create;
end;

{ TAcceptCloudFileConfirmHandle }

function TAcceptCloudFileConfirmHandle.getFindConfirm: TFindFileConfirm;
begin
  Result := TFindCloudFileConfirm.Create;
end;

{ TAcceptConfirmFileThreadList }

function TAcceptConfirmFileThreadList.getIdelThread: TAcceptConfirmFileThread;
var
  i : Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
    if not Self[i].IsConfirming then
    begin
      Result := Self[i];
      Break;
    end;
end;

end.
