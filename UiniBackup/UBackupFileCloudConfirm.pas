unit UBackupFileCloudConfirm;

interface

Uses UModelUtil, UFileBaseInfo, Generics.Collections, Classes, SyncObjs, Sockets, UMyTcp,
     SysUtils, UBackupInfoControl, UMyUtil;

type

{$Region ' 主动确认 ' }

    // 确认的文件信息
  TConfirmFileInfo = class( TFileBaseInfo )
  end;
  TConfirmFileList = class( TObjectList< TConfirmFileInfo > );

    // Pc 需要确认的文件
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

    // 确认 备份到 某Pc 的文件 存在
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
    function IsNextConfirm : Boolean; // 是否继续确认
    procedure FileNotExist( FileInfo : TConfirmFileInfo );virtual;abstract;
  end;

    // 确认 备份文件
  TBackupFilePcConfirmHandle = class( TPcConfirmHandle )
  private
    procedure FileNotExist( FileInfo : TConfirmFileInfo );override;
  end;

    // 确认 云文件
  TCloudFilePcConfirmHandle = class( TPcConfirmHandle )
  private
    procedure FileNotExist( FileInfo : TConfirmFileInfo );override;
  end;


    //确认 文件 存在 线程
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

    // 确认 备份的 云文件 存在
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

{$Region ' 被动确认 ' }

    // 判断文件 是否存在
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

    // 判断 备份的文件 是否存在
  TFindBackupFileConfirm = class( TFindFileConfirm )
  public
    function get : Boolean;override;
  end;

    // 判断 云路径上的文件 是否存在
  TFindCloudFileConfirm = class( TFindFileConfirm )
  public
    function get : Boolean;override;
  private
    procedure AddNewBackupCopy;
  end;

    // 处理 确认连接
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
    function IsNextConfirm : Boolean; // 是否继续确认
    function getFindConfirm : TFindFileConfirm;virtual;abstract;
  end;

    // 处理 备份文件
  TAcceptBackupFileConfirmHandle = class( TAcceptFileConfirmHandle )
  protected
    function getFindConfirm : TFindFileConfirm;override;
  end;

    // 处理 云文件
  TAcceptCloudFileConfirmHandle = class( TAcceptFileConfirmHandle )
  protected
    function getFindConfirm : TFindFileConfirm;override;
  end;

    // 处理接收确认线程
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

    // 对方 确认 备份的文件 存在
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
    IsSendConfirm := IsNextConfirm; // 是否继续发送确认
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsSendConfirm ) );
    IsRevConfirm := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False ); // 是否继续接收确认

      // 必须双方同时继续确认
    if not IsSendConfirm or not IsRevConfirm then
      Exit;

      // 确认文件
    ConfirmFileInfo := ConfirmFileList[i];
    ConfirmFile( ConfirmFileInfo );
  end;

    // 没有文件需要确认了
  MySocketUtil.SendString( TcpSocket, BoolToStr( False ) );
end;

procedure TPcConfirmHandle.ConfirmFile(
  ConfirmFileInfo : TConfirmFileInfo);
var
  IsExistFile : Boolean;
begin
    // 发送文件信息
  MySocketUtil.SendString( TcpSocket, ConfirmFileInfo.FileName );
  MySocketUtil.SendString( TcpSocket, IntToStr( ConfirmFileInfo.FileSize ) );
  MySocketUtil.SendString( TcpSocket, FloatToStr( ConfirmFileInfo.LastWriteTime ) );

    // 获取 文件是否存在 返回信息
  IsExistFile := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), True );

    // 文件存在 跳过
  if IsExistFile then
    Exit;

    // 处理 文件不存在
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
    // 连接不上 Pc 或 Pc 繁忙
  if not ConnToConfirmPc then
    Exit;

    // 发送本机 PcID
  MySocketUtil.SendString( TcpSocket, PcInfo.PcID );

    // 确认备份文件存在
  ConfirmAllFile;
end;

{ TCloudPcConfirmList }

function TPcConfirmFileList.getPcConfirm(PcID: string): TPcConfirmFileInfo;
var
  i : Integer;
begin
  Result := nil;

    // 寻找 Pc
  for i := 0 to Self.Count - 1 do
    if Self[i].PcID = PcID then
    begin
      Result := Self[i];
      Break;
    end;

    // 存在 则返回
  if Result <> nil then
    Exit;

    // 不存在 则创建
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
    // 备份副本 删除处理
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
      // 处理确认信息
    if ConfirmType = ConfirmType_Backup then
      AcceptFileConfirmHandle := TAcceptBackupFileConfirmHandle.Create
    else
      AcceptFileConfirmHandle := TAcceptCloudFileConfirmHandle.Create;
    AcceptFileConfirmHandle.SetTcpSocket( TcpSocket );
    AcceptFileConfirmHandle.Update;
    AcceptFileConfirmHandle.Free;

      // 关闭连接
    TcpSocket.Free;

      // 挂起线程
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
      // 是否继续确认文件
    IsSendConfirm := StrToBoolDef( MySocketUtil.RevString( TcpSocket ), False );
    IsRevConfirm := IsNextConfirm;
    MySocketUtil.SendString( TcpSocket, BoolToStr( IsRevConfirm ) );

      // 必须双方继续
    if not IsSendConfirm or not IsRevConfirm then
      Break;

      // 获取文件信息
    FilePath := MySocketUtil.RevString( TcpSocket );
    FileSize := StrToInt64Def( MySocketUtil.RevString( TcpSocket ), -1 );
    FileTime := StrToFloatDef( MySocketUtil.RevString( TcpSocket ), -1 );

      // 对方断开连接
    if ( FilePath = '' ) or ( FileSize = -1 ) or ( FileTime = -1 ) then
      Break;

      // 检测 文件是否存在
    FindFileConfirm := getFindConfirm;
    FindFileConfirm.SetConfirmInfo( ConfirmPcID, FilePath );
    FindFileConfirm.SetFileInfo( FileSize, FileTime );
    IsExistFile := FindFileConfirm.get;
    FindFileConfirm.Free;

      // 发送返回 文件是否存在
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
    // 获取 对方 PcID
  ConfirmPcID := MySocketUtil.RevString( TcpSocket );
  if ConfirmPcID = '' then // 断开连接
    Exit;

    // 确认 对方全部文件
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
    // 组合云文件
  CloudPath := MyFilePath.getPath( MyCloudFileInfo.ReadBackupCloudPath );
  CloudPcPath := CloudPath + MyFilePath.getPath( ConfirmPcID );
  CloudFilePath := CloudPcPath + MyFilePath.getDownloadPath( FilePath );

    // 云文件是否存在
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

    // 读取 文件缓存信息
  TempBackupFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileInfo( FilePath );

    // 文件 不存在
  if TempBackupFileInfo = nil then
    Exit;

    // 文件信息是否一致
  Result := ( TempBackupFileInfo.FileSize = FileSize ) and
            ( MyDatetime.Equals( TempBackupFileInfo.LastWriteTime, FileTime ) );

    // 新的 Copy
  IsNewBackupCopy := Result and not TempBackupFileInfo.TempCopyHash.ContainsKey( ConfirmPcID );

  TempBackupFileInfo.Free;

    // 添加 新的 Copy
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
