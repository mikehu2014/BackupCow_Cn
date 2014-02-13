unit UMyFileUpload;

interface

uses UModelUtil, Sockets, UMyFileTransfer, UMyUtil, Classes, SysUtils, Math, WinSock, DateUtils,
     SyncObjs, Generics.Collections, UMyJobInfo, UChangeInfo, uDebug;

type

{$Region ' �ϴ��ļ� ' }

    // �����ϴ�
  TUploadFileHandle = class( TTransferFileConnHandle )
  protected
    function getTransferType : string;override;
  end;

    // �����ϴ� ����
  TUploadBackupFileHandle = class( TUploadFileHandle )
  protected
    function getJobIsContinues : Boolean;override;
    procedure ConnErrorHandle;override;
    procedure AcceptCancelHandle;override;
  private       // ɾ�� ������Ϣ �� ���·��� Job
    procedure RemovePendingInfo;
    procedure RefreshBackupJob;
  private        // Offline
    procedure AddOfflineInfo;
    procedure AddOfflineJobInfo;
  private       // ɾ��Զ��Pc DownPend
    procedure RemoveRemoteDownPend;
  end;

    // �����ϴ� �����ļ�
  TUploadTransferFileHandle = class( TUploadFileHandle )
  protected
    function getJobIsContinues : Boolean;override;
    procedure ConnErrorHandle;override;
  private        // ��� Job
    procedure AddFileSendOffline;
  private       // ɾ��Զ��Pc DownPend
    procedure RemoveRemoteDownPend;
  end;

    // �����ϴ�
  TAcceptUploadFileHandle = class( TTransferFileAcceptHandle )
  protected
    function getTransferType : string;override;
  protected
    function getAcceptIsContinues : Boolean;override;
    function getFileShareContinues : Boolean;
  end;

{$EndRegion}

{$Region ' �����ļ� ' }

    // ���� Loading ����
  TUploadingFaceThread = class( TThread )
  private
    PcID, UpFilePath : string;
    FileSize, Position : Int64;
  private
    Lock : TCriticalSection;
    LastFaceTime : TDateTime;
    SecondSendSize : Int64;
  public
    constructor Create( _FileSize, _Position : Int64 );
    procedure SetFileInfo( _PcID, _UpFilePath : string );
    procedure AddSendSize( SendSize : Integer );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure UpdateFace;
  end;

    // �����ļ�����
  TSendFileHandle = class(TTransferFile)
  private
    PcID, UpFilePath : string;
    Position, FileSize : Int64;
    FileTime : TDateTime;
    IsContinusFile : Boolean;
    FileType : string;
  private
    TcpSocket : TCustomIpClient;
    PendingJobInfo : TPendingJobInfo;
    DataBuf : TSendDataBuf;
    TransResult : string;
  private
    UploadingFaceThread : TUploadingFaceThread;
    StartSendTime : TDateTime;
    AllSendSize : Int64;
  private
    IsMD5Check : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );override;
    procedure SetTransferFileInfo( TransferFileInfo : TTransferFileInfo );override;
    procedure SetPendingJobInfo( _PendingJobInfo : TPendingJobInfo );override;
    procedure Update;override;
    destructor Destroy; override;
  private       // ���� �Ѵ��� ��Ҫ���ص��ļ�
    procedure IniFileSend;virtual;
    function DownFileCheck : string;
    procedure SendFileMD5Confirm;  // �����ļ� �Ƿ���Ҫ MD5 ��֤
    procedure SendFile;
  private       // ���ļ� �� �����ļ�
    function ReadDataBuf : string;virtual;
    function SendDataBuf : Boolean;
    function CheckMD5DataBuf : Boolean;
  protected     // �������
    procedure AddUploadingFace;
    procedure UpdateloadingFace( SendSize : Integer );virtual;
    procedure DeleteUploadingFace;
    procedure AddUploadedFace( IsDownExist : Boolean );
  protected
    procedure DownFileExistHandle;virtual;
    function CheckUploadContinues : Boolean;virtual;
    procedure SendFileBefore;virtual;
    procedure HandleDataBuf;virtual;
    procedure SendFileAfter;virtual;
  protected       // ����Ƿ��������
    function CheckNextSend : Boolean;virtual;
    procedure SendFileSleep( var StartTime : TDateTime; var SendCount : Integer );
    procedure AddPcUploadingFace;virtual;
    procedure RemovePcUploadingFace;virtual;
  end;

    // ���� �����ļ� ����
  TSendFileActivateHandle = class( TSendFileHandle )
  protected
    function CheckNextSend : Boolean;override;
  end;

    // ���� �����ļ�
  TSendBackupFileHandle = class( TSendFileActivateHandle )
  private
    IsEncrypted : Boolean;
    Password : string;
  private
    IsRemoteConn : Boolean;
  private
    LastUploadFaceTime : TDateTime;
  protected
    function CheckUploadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure HandleDataBuf;override;
    procedure SendFileBefore;override;
    procedure SendFileAfter;override;
  protected    // ���ͼ��
    procedure IniFileSend;override;
    function CheckNextSend : Boolean;override;
    procedure UpdateloadingFace( SendSize : Integer );override;
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  private       // Normal
    procedure AddUploadingInfo;
    procedure AddUploadedInfo;
  private       // Offline
    procedure AddOfflineInfo;  // ����ʱʹ��
    procedure AddOfflineJob;
  private       // Transfer Error
    procedure DeleteUploadingInfo; // ����ʧ��ʱʹ��
    procedure RefreshBackupJob; // ���·��� Job
  end;

    // ���� �����ļ�
  TSendTransferFileHandle = class( TSendFileActivateHandle )
  private
    RootSendPath : string;
    StartTimeLoading : TDateTime;
    LoadingSize : Integer;
  protected
    procedure IniFileSend;override;
    function CheckUploadContinues : Boolean;override;
    procedure DownFileExistHandle;override;
    procedure SendFileBefore;override;
    procedure SendFileAfter;override;
  protected    // ���ͼ��
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  private
    procedure UpdateloadingFace( SendSize : Integer );override; // ������һС�����ļ�
    procedure RefreshLastLoadingFace; // ˢ������ Loading �ռ���Ϣ
    procedure SetFileSendStatusFace( SendStatus : string ); // �޸� ����״̬��ʾ
  private
    procedure AddFileSendOffline;   // ��� ���� Job
    procedure CompletedFileSend; // �����ļ� ���
  end;

    // ���� ���� �����ļ�
  TSendShareFileHandle = class( TSendFileHandle )
  protected
    function CheckUploadContinues : Boolean;override;
  protected
    procedure AddPcUploadingFace;override;
    procedure RemovePcUploadingFace;override;
  end;

{$EndRegion}

  TMyFileUpload = class( TMyFileTransfer )
  public
    procedure AcceptSocket( TcpSocket : TCustomIpClient );
  protected
    function CreateThread : TTransferHandleThread;override;
  end;

var
  MyFileUpload : TMyFileUpload;

implementation

uses UMyNetPcInfo, UMyTcp, UJobFace, UMyBackupInfo, UBackupInfoXml, UNetworkFace, USettingInfo,
     UBackupInfoFace, UNetPcInfoXml, UBackupFileScan, UBackupInfoControl, UMyFileTransferControl,
     UMyFileTransferInfo, UFileTransferFace, UJobControl, UMyShareInfo, UMyShareFace, UMyClient;

{ TSendFile }

procedure TSendFileHandle.AddPcUploadingFace;
begin
end;

procedure TSendFileHandle.AddUploadedFace( IsDownExist : Boolean );
var
  PcName, RootID : string;
  TotalSpeed : Int64;
  UsedTime : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  VirTransferChildLoadedInfo : TVirTransferChildLoadedInfo;
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // ����ʾ Lost Conn
  if TransResult = TransFile_LostCon then
    Exit;

  if IsDownExist or ( TransResult = TransFile_OK ) then
    RootID := RootID_UpLoaded
  else
    RootID := RootID_UpError;

    // ��� Loaded
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, TransResult );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );
  MyJobFace.AddChange( VirTransferChildAddInfo );

    // ˢ�� Loaded ��Ϣ
  if IsDownExist then
  begin
    UsedTime := 0;
    TotalSpeed := 0;
  end
  else
  begin
    UsedTime := Max( SecondsBetween( Now, StartSendTime ), 1 );
    TotalSpeed := AllSendSize div UsedTime;
  end;

    // �޸� Loaded ��Ϣ
  VirTransferChildLoadedInfo := TVirTransferChildLoadedInfo.Create( RootID );
  VirTransferChildLoadedInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildLoadedInfo.SetTimeInfo( UsedTime, TotalSpeed );
  MyJobFace.AddChange( VirTransferChildLoadedInfo );

    // ���� ����
  if RootID = RootID_UpError then
    Exit;

    // ɾ�����ڵ� Error
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_UpError );
  VirTransferChildRemoveInfo.SetChildID( PcID, UpFilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TSendFileHandle.AddUploadingFace;
var
  PcName : string;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
    // ��� Loading
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_UpLoading );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Position, FileSize );
  VirTransferChildAddInfo.SetStatusInfo( FileType, FileStatus_Loading );
  VirTransferChildAddInfo.SetIsMD5( IsMD5Check );

  MyJobFace.AddChange( VirTransferChildAddInfo );

    // ���� Loading
  UploadingFaceThread := TUploadingFaceThread.Create( FileSize, Position );
  UploadingFaceThread.SetFileInfo( PcID, UpFilePath );
  UploadingFaceThread.Resume;

    // ���� Loaded
  AllSendSize := 0;
  StartSendTime := Now;

    // Pc λ����ʾ�����ϴ�
  AddPcUploadingFace;
end;

function TSendFileHandle.CheckMD5DataBuf: Boolean;
var
  SendMD5Str : string;
  MD5ResultStr : string;
begin
  Result := True;
  if not IsMD5Check then
    Exit;

  SendMD5Str := TransferUtil.getMD5Buffer( DataBuf.HardBuf, DataBuf.BufSize );
  MySocketUtil.SendString( TcpSocket, SendMD5Str );
  MD5ResultStr := MySocketUtil.RevData( TcpSocket );
  Result := StrToBoolDef( MD5ResultStr, False );
end;

function TSendFileHandle.CheckNextSend : Boolean;
var
  ThreadStatus : string;
begin
    // ��ȡ ��ǰ�߳� ״̬
  ThreadStatus := MyFileUpload.getThreadStatus;

  Result := False;

    // �����߳� �����仯
  if ThreadStatus = ThreadStatus_Stop then
    TransResult := TransFile_LostCon
  else
    Result := True;
end;

function TSendFileHandle.CheckUploadContinues: Boolean;
begin
  Result := True;
end;

constructor TSendFileHandle.Create;
begin
  DataBuf := TSendDataBuf.Create;
  IsContinusFile := False;
  IsMD5Check := False;
end;

procedure TSendFileHandle.DeleteUploadingFace;
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
    // ֹͣ Loading �������
  UploadingFaceThread.Free;

    // ɾ�� Loading
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID_UpLoading );
  VirTransferChildRemoveInfo.SetChildID( PcID, UpFilePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );

    // Pc λ����ʾ�ϴ�
  RemovePcUploadingFace;
end;


destructor TSendFileHandle.Destroy;
begin
  DataBuf.Free;
  inherited;
end;

procedure TSendFileHandle.DownFileExistHandle;
begin
end;

procedure TSendFileHandle.SendFileSleep(var StartTime: TDateTime;
  var SendCount : Integer);
var
  SendMiSeconds, SleepTime : Int64;
  UploadSpeed : Integer;
begin
  UploadSpeed := TransferSettingInfo.UploadSpeed;

     // ����ٶ�
  if UploadSpeed = TransferSpeed_Fast then
  begin
    if SendCount = Count_HandleSleep then
    begin
      SendCount := 0;
      SleepTime := 1;
    end
    else
      SleepTime := 0;
  end
  else
  begin
    SendMiSeconds := MilliSecondsBetween( Now, StartTime );
    if SendMiSeconds = 0 then // δ�� 1 ����
      Exit;

         // �е��ٶ�
    if UploadSpeed = TransferSpeed_Normal then
      SleepTime := SendMiSeconds
    else  // �����ٶ�
      SleepTime := SendMiSeconds * 9;
  end;

    // ��� 1 ��
  SleepTime := Min( SleepTime, 1000 );

    // Sleep
  while ( SleepTime > 0 ) and CheckNextSend do
  begin
    if SleepTime <= 100 then
    begin
      Sleep( SleepTime );
      Break;
    end;
    Sleep(100);
    SleepTime := SleepTime - 100;
  end;
  StartTime := Now;
end;

function TSendFileHandle.DownFileCheck: string;
var
  DownFileCheckMsg : string;
begin
  DownFileCheckMsg := MySocketUtil.RevData( TcpSocket );
  if IsContinusFile then
    Position := StrToInt64Def( MySocketUtil.RevData( TcpSocket ), 0 );
  Result := DownFileCheckMsg;
end;

procedure TSendFileHandle.HandleDataBuf;
begin

end;

procedure TSendFileHandle.IniFileSend;
begin

end;

function TSendFileHandle.ReadDataBuf: string;
var
  FileStream : TFileStream;
  RemainSize : Int64;
  BufSize, ReadSize : Integer;
begin
    // ȡ���ϴ�
  if not CheckUploadContinues then
  begin
    Result := ReadFile_UploadCancel;
    Exit;
  end;

    // �ϴ��ļ�������
  if not FileExists( UpFilePath ) then
  begin
    Result := ReadFile_FileNotExist;
    Exit;
  end;

    // �ϴ��ļ������˱仯
  if ( MyFileInfo.getFileSize( UpFilePath ) <> FileSize ) or
     ( not MyDatetime.Equals( MyFileInfo.getFileLastWriteTime( UpFilePath ), FileTime )  )
  then
  begin
    Result := ReadFile_FileChange;
    Exit;
  end;

    // ��ȡ�����ļ�
  try
    FileStream := TFileStream.Create( UpFilePath, fmOpenRead or fmShareDenyNone );
    FileStream.Position := Position; // ���ö��ļ���ʼλ��
    RemainSize := FileSize - Position;  // �ļ�ʣ���С
    BufSize := Min( RemainSize, Size_DataBuf ); // ��ȡ�ļ��Ĵ�С
    ReadSize := FileStream.Read( DataBuf.HardBuf, BufSize ); // ��ȡ�ļ�
    FileStream.Free;
  except
    Result := ReadFile_ReadError;
    Exit;
  end;

    // ��ȡ ����
  if ReadSize <> BufSize then
  begin
    Result := ReadFile_ReadError;
    Exit;
  end;

    // ��ȡ�ɹ�
  DataBuf.SetBufInfo( ReadSize );
  Result := ReadFile_OK;
end;


procedure TSendFileHandle.RemovePcUploadingFace;
begin
end;

function TSendFileHandle.SendDataBuf: Boolean;
var
  Buf : TTransferBuf;
  BufSize, SendSize, TotalSendSize : Integer;
  SendCount : Integer;
  SendStartTime : TDateTime;
begin
  Result := True;

  TotalSendSize := 0;
  SendCount := 0;
  SendStartTime := Now;
  while True do
  begin
      // ����Ƿ� ��������
    if not CheckNextSend then  // ������������
    begin
      TcpSocket.Disconnect; // �Ͽ�����
      Result := False;
      Break;
    end;

      // ���� NK ����
    BufSize := DataBuf.getSendBuf( Buf );
    if BufSize <= 0 then // �������
      Break;
    SendSize := TcpSocket.SendBuf( Buf, BufSize );
    if SendSize = SOCKET_ERROR then  // �Է���������
    begin
      TransResult := TransFile_LostCon;
      Result := False;
      Break;
    end;

      // ����λ��
    TotalSendSize := TotalSendSize + SendSize;

      // ����
    UpdateloadingFace( SendSize );

      // sleep CPU
    SendFileSleep( SendStartTime, SendCount );
    Inc( SendCount );
  end;



    // MD5 ����, ���·���
  if Result and not CheckMD5DataBuf then
  begin
    UpdateloadingFace( -DataBuf.BufSize );
    DataBuf.SendPosition := 0;
    Result := SendDataBuf;
    Exit;
  end;

    // ���ͳɹ�
  if Result then
    Position := Position + TotalSendSize;
end;

procedure TSendFileHandle.SendFile;
var
  ReadFileResult, WriteFileResult : string;
begin
  TransResult := TransFile_OK;
  while FileSize > Position do
  begin
      // ��ȡ�����ļ�
    ReadFileResult := ReadDataBuf;

      // ���� ��ȡ�ļ���� , �Է����ܶϿ�����
    if MySocketUtil.SendString( TcpSocket, ReadFileResult ) = SOCKET_ERROR then
    begin
      TransResult := TransFile_LostCon;
      Break;
    end;

      // ��ȡ�ļ� ʧ��
    if ReadFileResult <> ReadFile_OK then
    begin
      TransResult := ReadFileResult;
      Break;
    end;

      // �����ļ�ǰ����
      // ���� MD5 ��
    HandleDataBuf;

      // ���ʹ����ļ�, ���ܳ��ֶԷ��Ͽ�����
    if not SendDataBuf then
      Break;

      // ���� д���ļ����
    WriteFileResult := MySocketUtil.RevData( TcpSocket );

      // д���ļ�ʧ��
    if WriteFileResult <> WriteFile_OK then
    begin
      if WriteFileResult = '' then   // �Է��Ͽ�����
        TransResult := TransFile_LostCon
      else
        TransResult := WriteFileResult;
      Break;
    end;
  end;
end;

procedure TSendFileHandle.SendFileAfter;
begin
end;

procedure TSendFileHandle.SendFileBefore;
begin
end;

procedure TSendFileHandle.SendFileMD5Confirm;
var
  IsMD5Activate : Boolean;
begin
    // �Ƿ� MD5 ������
  IsMD5Activate := TransferUtil.getIsSendMD5Activate( FileType );

    // MD5 ������ ����
    // MD5 ������ �����
  if IsMD5Activate then
  begin
    IsMD5Check := TransferSafeSettingInfo.IsMD5Check;
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsMD5Check ) );
  end
  else
    IsMD5Check := StrToBoolDef( MySocketUtil.RevData( TcpSocket ), False );
end;

procedure TSendFileHandle.SetPendingJobInfo(_PendingJobInfo: TPendingJobInfo);
begin
  PendingJobInfo := _PendingJobInfo;
end;

procedure TSendFileHandle.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

procedure TSendFileHandle.SetTransferFileInfo(
  TransferFileInfo: TTransferFileInfo);
begin
  PcID := TransferFileInfo.PcID;
  UpFilePath := TransferFileInfo.LoadPath;
  Position := TransferFileInfo.Position;
  FileSize := TransferFileInfo.FileSize;
  FileTime := TransferFileInfo.FileTime;
  FileType := TransferFileInfo.FileType;
  IsContinusFile := Position > 0;
end;

procedure TSendFileHandle.Update;
var
  DownFileCheckResult : string;
begin
  IniFileSend; // ��ʼ�� �ļ�����

  DownFileCheckResult := DownFileCheck;

    // ���ط� �ļ����� �� ���ͽ���
  if DownFileCheckResult = WriteFile_Exist then
  begin
    TransResult := WriteFile_Exist;
    Position := FileSize;
    AddUploadedFace( True );

    DownFileExistHandle;
  end
  else    // �����ļ�
  begin
    SendFileMD5Confirm; // �Ƿ� MD5 ���

    SendFileBefore;  // �����ļ�ǰ ����

    AddUploadingFace;
    if DownFileCheckResult = WriteFile_OK then
      SendFile
    else
      TransResult := DownFileCheckResult;
    DeleteUploadingFace;
    AddUploadedFace( False );

    SendFileAfter;  // �����ļ��� ����
  end;
end;

procedure TSendFileHandle.UpdateloadingFace(SendSize: Integer);
begin
    // Loading
  UploadingFaceThread.AddSendSize( SendSize );

    // Loaded
  AllSendSize := AllSendSize + SendSize;

    // �����ڽ���
  TransferSpeedFaceThread.AddUploadSpeed( SendSize );
end;

{ TUploadingFaceThread }

procedure TUploadingFaceThread.AddSendSize(SendSize: Integer);
begin
  Lock.Enter;
  SecondSendSize := SecondSendSize + SendSize;
  Lock.Leave;
end;

constructor TUploadingFaceThread.Create(_FileSize, _Position: Int64);
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  FileSize := _FileSize;
  Position := _Position;
  SecondSendSize := 0;
  LastFaceTime := Now;
end;

destructor TUploadingFaceThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  Lock.Free;
  inherited;
end;

procedure TUploadingFaceThread.Execute;
begin
  while not Terminated do
  begin
    while ( SecondsBetween( Now, LastFaceTime ) < 1 ) and not Terminated do
      Sleep( 100 );

    if Terminated then
      Break;

    UpdateFace;
  end;

  inherited;
end;

procedure TUploadingFaceThread.SetFileInfo(_PcID, _UpFilePath: string);
begin
  PcID := _PcID;
  UpFilePath := _UpFilePath;
end;

procedure TUploadingFaceThread.UpdateFace;
var
  TempSecondSendSize : Int64;
  RemainTime : Integer;
  VirTransferChildLoadingInfo : TVirTransferChildLoadingInfo;
begin
  Lock.Enter;
  TempSecondSendSize := SecondSendSize;
  SecondSendSize := 0;
  LastFaceTime := Now;
  Lock.Leave;

  Position := Position + TempSecondSendSize;
  if TempSecondSendSize < 1 then
    RemainTime := MyTime.getMaxTime
  else
    RemainTime := ( FileSize - Position ) div TempSecondSendSize;

  VirTransferChildLoadingInfo := TVirTransferChildLoadingInfo.Create( RootID_UpLoading );
  VirTransferChildLoadingInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildLoadingInfo.SetPercentage( Position, FileSize );
  VirTransferChildLoadingInfo.SetTimeInfo( TempSecondSendSize, RemainTime );

  MyJobFace.AddChange( VirTransferChildLoadingInfo );
end;


{ TUploadBackupFileHandle1 }

procedure TUploadBackupFileHandle.AcceptCancelHandle;
begin
  RemovePendingInfo;
  RefreshBackupJob;
end;

procedure TUploadBackupFileHandle.AddOfflineInfo;
var
  PcID, FilePath : string;
  Position : Int64;
  BackupCopyAddOfflineHandle : TBackupCopyAddOfflineHandle;
begin
    // ��ȡ��Ϣ
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  Position := TransferFileInfo.Position;

    // ��� Offline Backup Copy
  BackupCopyAddOfflineHandle := TBackupCopyAddOfflineHandle.Create( FilePath );
  BackupCopyAddOfflineHandle.SetCopyOwner( PcID );
  BackupCopyAddOfflineHandle.SetPosition( Position );
  BackupCopyAddOfflineHandle.Update;
  BackupCopyAddOfflineHandle.Free;
end;

procedure TUploadBackupFileHandle.AddOfflineJobInfo;
var
  PcID, FilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
    // ��ȡ��Ϣ
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;

    // ��ӵ� Offline
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( FilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TUploadBackupFileHandle.ConnErrorHandle;
begin
    // ���� �� ȡ������
  if TransferFileInfo.Position > 0 then
  begin
    AddOfflineInfo;
    AddOfflineJobInfo;
  end
  else
  begin
    RemovePendingInfo;  // ɾ�� Pending
    RefreshBackupJob;   // ���·��� Job
  end;
end;

function TUploadBackupFileHandle.getJobIsContinues: Boolean;
begin
  Result := MyBackupPathInfoUtil.ReadIsEnable( TransferFileInfo.LoadPath );
  if not Result then  // ɾ�� ����Ŀ�� DownPend
    RemoveRemoteDownPend;
end;

{ TAcceptUploadFile }

function TAcceptUploadFileHandle.getAcceptIsContinues: Boolean;
var
  FileType : string;
begin
  FileType := TransferFileInfo.FileType;
  if FileType = FileType_Share then
    Result := getFileShareContinues
  else
    Result := True;
end;

function TAcceptUploadFileHandle.getFileShareContinues: Boolean;
begin
  Result := MySharePathInfoReadUtil.ReadFileIsEnable( TransferFileInfo.LoadPath );
end;

function TAcceptUploadFileHandle.getTransferType: string;
begin
  Result := TransferType_Upload;
end;

{ TUploadFileHandle }

function TUploadFileHandle.getTransferType: string;
begin
  Result := TransferType_Upload;
end;

{ TSendBackupFileHandle }

procedure TSendBackupFileHandle.AddOfflineInfo;
var
  BackupCopyAddOfflineHandle : TBackupCopyAddOfflineHandle;
begin
  BackupCopyAddOfflineHandle := TBackupCopyAddOfflineHandle.Create( UpFilePath );
  BackupCopyAddOfflineHandle.SetCopyOwner( PcID );
  BackupCopyAddOfflineHandle.SetPosition( Position );
  BackupCopyAddOfflineHandle.Update;
  BackupCopyAddOfflineHandle.Free;
end;

function TSendBackupFileHandle.CheckNextSend: Boolean;
begin
  Result := False;

    // �Ѿ� ����ʧ��
  if not inherited then
    Exit;

    // ��ֹ Զ�̴���
  if IsRemoteConn and TransferSafeSettingInfo.IsRemoveForbid then
    TransResult := TransFile_RemoteForbid
  else
    Result := True;
end;

function TSendBackupFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MyBackupPathInfoUtil.ReadIsEnable( UpFilePath );
end;

procedure TSendBackupFileHandle.AddOfflineJob;
var
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( UpFilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TSendBackupFileHandle.AddPcUploadingFace;
var
  NetworkLvAddUpload : TLvNetworkAddUpload;
begin
    // ���� Network Listview
  NetworkLvAddUpload := TLvNetworkAddUpload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvAddUpload );
end;

procedure TSendBackupFileHandle.AddUploadedInfo;
var
  BackupCopyAddControl : TBackupCopyAddControl;
begin
    // ��� ����
  BackupCopyAddControl := TBackupCopyAddControl.Create( UpFilePath, PcID );
  BackupCopyAddControl.SetFileSize( FileSize );
  BackupCopyAddControl.Update;
  BackupCopyAddControl.Free;
end;

procedure TSendBackupFileHandle.AddUploadingInfo;
var
  BackupCopyAddLoadingHandle : TBackupCopyAddLoadingHandle;
begin
  BackupCopyAddLoadingHandle := TBackupCopyAddLoadingHandle.Create( UpFilePath );
  BackupCopyAddLoadingHandle.SetCopyOwner( PcID );
  BackupCopyAddLoadingHandle.Update;
  BackupCopyAddLoadingHandle.Free;
end;

procedure TSendBackupFileHandle.DeleteUploadingInfo;
var
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( UpFilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TSendBackupFileHandle.DownFileExistHandle;
begin
  AddUploadedInfo;
end;

procedure TSendBackupFileHandle.HandleDataBuf;
begin
  if IsEncrypted then
    DataBufUtil.EncryptSendBuf( DataBuf, Password );
end;

procedure TSendBackupFileHandle.IniFileSend;
var
  RemoteIp : string;
begin
    // ��ȡ ������Ϣ
  Password := MyBackupPathInfoUtil.ReadPassword( UpFilePath );
  IsEncrypted := Password <> '';

    // ��ȡ �Ƿ�Զ������
  RemoteIp := MyNetPcInfoReadUtil.ReadIp( PcID );
  IsRemoteConn := not MyParseHost.CheckIpLan( PcInfo.LanIp, RemoteIp );
end;

procedure TSendBackupFileHandle.RefreshBackupJob;
var
  BackupFileRefreshJobHandle : TBackupFileSyncHandle;
begin
    // ���ļ�����, �����·��� Job
  if ( TransResult = ReadFile_FileNotExist ) or
     ( TransResult = ReadFile_FileChange ) or
     ( TransResult = ReadFile_ReadError )
  then
    Exit;

    // ���·��� Job
  BackupFileRefreshJobHandle := TBackupFileSyncHandle.Create( UpFilePath );
  BackupFileRefreshJobHandle.Update;
  BackupFileRefreshJobHandle.Free;
end;

procedure TSendBackupFileHandle.RemovePcUploadingFace;
var
  NetworkLvRemoveUpload : TLvNetworkRemoveUpload;
begin
    // ���� Network ListView
  NetworkLvRemoveUpload := TLvNetworkRemoveUpload.Create( PcID );
  MyNetworkFace.AddChange( NetworkLvRemoveUpload );
end;

procedure TSendBackupFileHandle.SendFileAfter;
begin
    // ���� �ɹ�
  if TransResult = TransFile_OK then
    AddUploadedInfo
  else    // ����
  if ( TransResult = TransFile_LostCon ) and ( Position > 0 ) then
  begin
    Sleep(500);
    AddOfflineInfo;
    AddOfflineJob;
  end
  else   // ����ʧ��
  begin
    DeleteUploadingInfo;
    RefreshBackupJob;
  end;
end;

procedure TSendBackupFileHandle.SendFileBefore;
begin
    // ��� Loading ��Ϣ
  AddUploadingInfo;
end;

procedure TSendBackupFileHandle.UpdateloadingFace(SendSize: Integer);
var
  BackupPgShowInfo : TBackupPgShowInfo;
begin
  inherited;

    // 1 ������Ӧһ��
  if SecondsBetween( Now, LastUploadFaceTime ) < 1 then
    Exit;

    // ��ʾ������
  BackupPgShowInfo := TBackupPgShowInfo.Create;
  MyBackupFileFace.AddChange( BackupPgShowInfo );

  LastUploadFaceTime := Now;
end;

{ TMyFileUpload }

procedure TMyFileUpload.AcceptSocket(TcpSocket: TCustomIpClient);
var
  IsAcceptJob : Boolean;
  AcceptJobInfo : TAcceptJobInfo;
  JobAddInfo : TJobAddInfo;
  UploadJobChangeInfo : TUploadJobChangeInfo;
begin
    // �Ƿ�æ
  MyJobInfo.EnterData;
  IsAcceptJob := MyJobInfo.UploadJobInfo.CheckAcceptJob;
  MyJobInfo.LeaveData;

    // ����æ�� �� Job
  if IsAcceptJob then
  begin
    AcceptJobInfo := TAcceptJobInfo.Create;
    AcceptJobInfo.SetTcpSocket( TcpSocket );

    JobAddInfo := TJobAddInfo.Create;
    JobAddInfo.SetJobInfo( AcceptJobInfo );

    UploadJobChangeInfo := TUploadJobChangeInfo.Create;
    UploadJobChangeInfo.SetJobWriteInfo( JobAddInfo );

    MyJobInfo.AddChange( UploadJobChangeInfo );
  end
  else
    TcpSocket.Free;
end;

procedure TUploadBackupFileHandle.RefreshBackupJob;
var
  FilePath : string;
  BackupFileRefreshJobHandle : TBackupFileSyncHandle;
begin
  FilePath := TransferFileInfo.LoadPath;

    // ���·��� Job
  BackupFileRefreshJobHandle := TBackupFileSyncHandle.Create( FilePath );
  BackupFileRefreshJobHandle.Update;
  BackupFileRefreshJobHandle.Free;
end;

procedure TUploadBackupFileHandle.RemovePendingInfo;
var
  FilePath, PcID : string;
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
    // ��ȡ��Ϣ
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;

    // ɾ�� Pending ������Ϣ
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TUploadBackupFileHandle.RemoveRemoteDownPend;
var
  PcRemoveDownPendFileMsg : TPcRemoveDownPendFileMsg;
begin
  PcRemoveDownPendFileMsg := TPcRemoveDownPendFileMsg.Create;
  PcRemoveDownPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveDownPendFileMsg.SetRemovePath( TransferFileInfo.LoadPath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveDownPendFileMsg );
end;

function TMyFileUpload.CreateThread: TTransferHandleThread;
begin
  Result := TUploadHandleThread.Create;
end;

{ TSendTransferFileHandle }

procedure TSendTransferFileHandle.DownFileExistHandle;
var
  SendFileAddCompletedSpaceHandle : TSendFileAddCompletedSpaceHandle;
begin
  inherited;

    // ��� �������Ϣ Ŀ¼�ڵ�
  SendFileAddCompletedSpaceHandle := TSendFileAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileAddCompletedSpaceHandle.SetCompletedSize( FileSize );
  SendFileAddCompletedSpaceHandle.Update;
  SendFileAddCompletedSpaceHandle.Free;

  CompletedFileSend;
end;

procedure TSendTransferFileHandle.IniFileSend;
begin
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( UpFilePath, PcID );
end;

procedure TSendTransferFileHandle.AddPcUploadingFace;
var
  VstFileTransferDesAddUpload : TVstFileTransferDesAddUpload;
begin
    // ���� File Transfer
  VstFileTransferDesAddUpload := TVstFileTransferDesAddUpload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesAddUpload );
end;

procedure TSendTransferFileHandle.RefreshLastLoadingFace;
var
  SendFileAddCompletedSpaceHandle : TSendFileAddCompletedSpaceHandle;
  SendFileChildAddCompletedSpaceHandle : TSendFileChildAddCompletedSpaceHandle;
begin
    // ˢ�� �ļ��ڵ�
  SendFileChildAddCompletedSpaceHandle := TSendFileChildAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileChildAddCompletedSpaceHandle.SetFilePath( UpFilePath );
  SendFileChildAddCompletedSpaceHandle.SetCompletedSize( LoadingSize );
  SendFileChildAddCompletedSpaceHandle.Update;
  SendFileChildAddCompletedSpaceHandle.Free;

    // ˢ�� Ŀ¼�ڵ�
  SendFileAddCompletedSpaceHandle := TSendFileAddCompletedSpaceHandle.Create( RootSendPath, PcID );
  SendFileAddCompletedSpaceHandle.SetCompletedSize( LoadingSize );
  SendFileAddCompletedSpaceHandle.Update;
  SendFileAddCompletedSpaceHandle.Free;
end;

procedure TSendTransferFileHandle.RemovePcUploadingFace;
var
  VstFileTransferDesRemoveUpload : TVstFileTransferDesRemoveUpload;
begin
    // ���� File Transfer
  VstFileTransferDesRemoveUpload := TVstFileTransferDesRemoveUpload.Create( PcID );
  MyFaceChange.AddChange( VstFileTransferDesRemoveUpload );
end;

function TSendTransferFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MyFileSendInfoReadUtil.ReadIsEnable( RootSendPath, PcID );
end;

procedure TSendTransferFileHandle.CompletedFileSend;
var
  SendFileRemoveChildHandle : TSendFileRemoveChildHandle;
  SendFileCheckCompletedHandle : TSendFileCheckCompletedHandle;
begin
    // ɾ�� �ļ����� �ڵ�
  SendFileRemoveChildHandle := TSendFileRemoveChildHandle.Create( RootSendPath, PcID );
  SendFileRemoveChildHandle.SetFilePath( UpFilePath );
  SendFileRemoveChildHandle.Update;
  SendFileRemoveChildHandle.Free;

    // ����Ƿ��Ѿ��������
  SendFileCheckCompletedHandle := TSendFileCheckCompletedHandle.Create( RootSendPath, PcID );
  SendFileCheckCompletedHandle.Update;
  SendFileCheckCompletedHandle.Free;
end;

procedure TSendTransferFileHandle.SendFileAfter;
begin
  inherited;

    // ˢ�� �ռ���Ϣ
  RefreshLastLoadingFace;

  if TransResult = TransFile_OK then // ���� �ɹ�
    CompletedFileSend
  else
  if TransResult = TransFile_LostCon then // ���� �Ͽ�
    AddFileSendOffline
  else
    SetFileSendStatusFace( TransResult );  // ���� ʧ��
end;

procedure TSendTransferFileHandle.SendFileBefore;
begin
  inherited;

  SetFileSendStatusFace( SendPathStatus_Sending );

  StartTimeLoading := Now;
  LoadingSize := 0;
end;

procedure TSendTransferFileHandle.AddFileSendOffline;
var
  SendFileOfflineHandle : TSendFileOfflineHandle;
begin
  SendFileOfflineHandle := TSendFileOfflineHandle.Create( RootSendPath, PcID );
  SendFileOfflineHandle.SetChildFilePath( UpFilePath );
  SendFileOfflineHandle.SetPostion( Position );
  SendFileOfflineHandle.SetFileInfo( FileSize, FileTime );
  SendFileOfflineHandle.Update;
  SendFileOfflineHandle.Free;
end;

procedure TSendTransferFileHandle.SetFileSendStatusFace(SendStatus: string);
var
  SendFileSetChildStatusHandle : TSendFileSetChildStatusHandle;
begin
  if SendStatus = TransFile_TransferCancel then // Cancel
    SendStatus := SendPathStatus_Cancel;

    // �޸� ����״̬
  SendFileSetChildStatusHandle := TSendFileSetChildStatusHandle.Create( RootSendPath, PcID );
  SendFileSetChildStatusHandle.SetFilePath( UpFilePath );
  SendFileSetChildStatusHandle.SetSendFileStatus( SendStatus );
  SendFileSetChildStatusHandle.Update;
  SendFileSetChildStatusHandle.Free;
end;

procedure TSendTransferFileHandle.UpdateloadingFace(SendSize: Integer);
begin
  inherited;

  LoadingSize := LoadingSize + SendSize;
  if SecondsBetween( Now, StartTimeLoading ) < 1 then  // 1 �����һ��
    Exit;

    // ˢ�� ����ɿռ� ��Ϣ
  RefreshLastLoadingFace;

  LoadingSize := 0;
  StartTimeLoading := Now;
end;

{ TUploadTransferFileHandle }

procedure TUploadTransferFileHandle.AddFileSendOffline;
var
  PcID, FilePath : string;
  FileSize, Position : Int64;
  FileTime : TDateTime;
  RootSendPath : string;
  SendFileOfflineHandle : TSendFileOfflineHandle;
begin
    // ��ȡ Job ��Ϣ
  PcID := TransferFileInfo.PcID;
  FilePath := TransferFileInfo.LoadPath;
  FileSize := TransferFileInfo.FileSize;
  Position := TransferFileInfo.Position;
  FileTime := TransferFileInfo.FileTime;
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( FilePath, PcID );

    // ��� ���� FileSend Job
  SendFileOfflineHandle := TSendFileOfflineHandle.Create( RootSendPath, PcID );
  SendFileOfflineHandle.SetChildFilePath( FilePath );
  SendFileOfflineHandle.SetPostion( Position );
  SendFileOfflineHandle.SetFileInfo( FileSize, FileTime );
  SendFileOfflineHandle.Update;
  SendFileOfflineHandle.Free;
end;

procedure TUploadTransferFileHandle.ConnErrorHandle;
begin
  AddFileSendOffline;
end;

function TUploadTransferFileHandle.getJobIsContinues: Boolean;
var
  RootSendPath : string;
begin
  RootSendPath := MyFileSendInfoReadUtil.ReadRootPath( TransferFileInfo.LoadPath, TransferFileInfo.PcID );
  Result := MyFileSendInfoReadUtil.ReadIsEnable( RootSendPath, TransferFileInfo.PcID );
  if not Result then
    RemoveRemoteDownPend;
end;

procedure TUploadTransferFileHandle.RemoveRemoteDownPend;
var
  PcRemoveDownPendFileMsg : TPcRemoveDownPendFileMsg;
begin
  PcRemoveDownPendFileMsg := TPcRemoveDownPendFileMsg.Create;
  PcRemoveDownPendFileMsg.SetPcID( PcInfo.PcID );
  PcRemoveDownPendFileMsg.SetRemovePath( TransferFileInfo.LoadPath );
  MyClient.SendMsgToPc( TransferFileInfo.PcID, PcRemoveDownPendFileMsg );
end;

{ TSendShareFileHandle }

procedure TSendShareFileHandle.AddPcUploadingFace;
var
  VstShareFilePcAddUpload : TVstShareFilePcAddUpload;
begin
  VstShareFilePcAddUpload := TVstShareFilePcAddUpload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcAddUpload );
end;

function TSendShareFileHandle.CheckUploadContinues: Boolean;
begin
  Result := MySharePathInfoReadUtil.ReadFileIsEnable( UpFilePath );
end;

procedure TSendShareFileHandle.RemovePcUploadingFace;
var
  VstShareFilePcRemoveUpload : TVstShareFilePcRemoveUpload;
begin
  VstShareFilePcRemoveUpload := TVstShareFilePcRemoveUpload.Create( PcID );
  MyFaceChange.AddChange( VstShareFilePcRemoveUpload );
end;

{ TSendFileActivateHandle }

function TSendFileActivateHandle.CheckNextSend: Boolean;
begin
  Result := False;

    // �Ѿ� ����ʧ��
  if not inherited then
    Exit;

    // ȡ�� �ϴ�
  if not CheckUploadContinues then
  begin
    TransResult := ReadFile_UploadCancel;
    Exit;
  end;

  Result := True;
end;

end.
