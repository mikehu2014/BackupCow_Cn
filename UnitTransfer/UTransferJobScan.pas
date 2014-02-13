unit UTransferJobScan;

interface

uses SyncObjs, Classes, SysUtils, Generics.Collections, UMyUtil, Windows, uDebug;

type

{$Region ' 扫描发送的 文件 ' }

    // 扫描 发送 Job 父类
  TTransferJobScanHandle = class
  public
    ScanType : string;
    ScanPath : string;
    DesPcList : TStringList;
  public
    ScanSize : Int64;
  public
    procedure SetScanType( _ScanType : string );
    procedure SetScanPath( _ScanPath : string );
    procedure SetDesPcList( _DesPcList : TStringList );
  protected
    procedure AddSendFile( FilePath : string; FileSize : Int64; FileTime : TDateTime );
  end;

    // 扫描 文件 发送 Job
  TTransferFileScanHandle = class( TTransferJobScanHandle )
  public
    procedure Update;
  end;

    // 扫描 文件夹 发送 Job
  TTransferFolderScanHandle = class( TTransferJobScanHandle )
  public
    ScanFileCount : Integer; // 总文件数
  public
    FolderPath : string;
    ScanCount : Integer;
  public
    constructor Create( _FolderPath : string );
    procedure SetScanCount( _ScanCount : Integer );
    procedure Update;
  private
    procedure ScanNextFolder( ChildFolderPath : string );
    function CheckNextSearch : Boolean;
  end;

{$EndRegion}

    // 扫描 信息
  TTransferScanInfo = class
  public
    ScanType : string;
    ScanPathList : TStringList;
    DestinationList : TStringList;
  public
    constructor Create( _ScanType : string );
    procedure SetList( NewScanPathList, NewDestinationList : TStringList );
    destructor Destroy; override;
  end;
  TTransferScanList = class( TObjectList< TTransferScanInfo > )end;

    // 扫描处理
  TTransferScanHandle = class
  public
    TransferScanInfo : TTransferScanInfo;
    ScanType : string;
  public
    constructor Create( _TransferScanInfo : TTransferScanInfo );
    procedure Update;
  private
    procedure ScanFile( FilePath : string );
    procedure ScanFolder( FolderPath : string );
  private
    procedure ResetRootSpace( FilePath : string; FileSize : Int64 );
    procedure AddFileSendRoot( FilePath : string; FileSize : Int64; FileCount : Integer );
  end;

    // 扫描线程
  TTransferScanJobThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // 控制器
  TMyTransferJobScanInfo = class
  public
    Lock : TCriticalSection;
    TransferScanList : TTransferScanList;
  public
    IsRun : Boolean;
    TransferScanJobThread : TTransferScanJobThread;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public
    procedure AddScanInfo( TransferScanInfo : TTransferScanInfo );
    function getScanInfo : TTransferScanInfo;
  end;

const
  CopyCount_Sleep = 10;
  ScanType_Job = 'Job';
  ScanType_Size = 'Size';

var
  MyTransferJobScanInfo : TMyTransferJobScanInfo;

implementation

uses UMyFileTransferControl, UFileTransferFace, UMyClient, UMyNetPcInfo, UChangeInfo;

{ TMyTransferJobScanInfo }

procedure TMyTransferJobScanInfo.AddScanInfo(
  TransferScanInfo : TTransferScanInfo);
begin
  Lock.Enter;
  TransferScanList.Add( TransferScanInfo );
  Lock.Leave;

  if IsRun then
    TransferScanJobThread.Resume;
end;

constructor TMyTransferJobScanInfo.Create;
begin
  Lock := TCriticalSection.Create;
  TransferScanList := TTransferScanList.Create;
  TransferScanList.OwnsObjects := False;
  TransferScanJobThread := TTransferScanJobThread.Create;
  IsRun := True;
end;

destructor TMyTransferJobScanInfo.Destroy;
begin
  TransferScanList.OwnsObjects := True;
  TransferScanList.Free;
  Lock.Free;
  inherited;
end;

function TMyTransferJobScanInfo.getScanInfo: TTransferScanInfo;
begin
  Lock.Enter;
  if TransferScanList.Count > 0 then
  begin
    Result := TransferScanList[0];
    TransferScanList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TMyTransferJobScanInfo.StopScan;
begin
  IsRun := False;
  TransferScanJobThread.Free;
end;

{ TTransferScanJobThread }

constructor TTransferScanJobThread.Create;
begin
  inherited Create( True );
end;

destructor TTransferScanJobThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TTransferScanJobThread.Execute;
var
  TransferScanInfo : TTransferScanInfo;
  TransferScanHandle : TTransferScanHandle;
begin
  while not Terminated do
  begin
    TransferScanInfo := MyTransferJobScanInfo.getScanInfo;
    if TransferScanInfo = nil then
    begin
      Suspend;
      Continue;
    end;

    if Terminated then
      Break;

      // 处理 扫描信息
    TransferScanHandle := TTransferScanHandle.Create( TransferScanInfo );
    TransferScanHandle.Update;
    TransferScanHandle.Free;

    TransferScanInfo.Free;
  end;
  inherited;
end;

{ TTransferScanInfo }

constructor TTransferScanInfo.Create( _ScanType : string );
begin
  ScanType := _ScanType;
  ScanPathList := TStringList.Create;
  DestinationList := TStringList.Create;
end;

destructor TTransferScanInfo.Destroy;
begin
  ScanPathList.Free;
  DestinationList.Free;
  inherited;
end;

procedure TTransferScanInfo.SetList(NewScanPathList,
  NewDestinationList: TStringList);
var
  i : Integer;
begin
  for i := 0 to NewScanPathList.Count - 1 do
    ScanPathList.Add( NewScanPathList[i] );

  for i := 0 to NewDestinationList.Count - 1 do
    DestinationList.Add( NewDestinationList[i] );
end;

{ TTransferScanHandle }

procedure TTransferScanHandle.AddFileSendRoot(FilePath: string;
  FileSize: Int64; FileCount : Integer);
var
  DesPcList : TStringList;
  i : Integer;
  SendPathType, DesPcID : string;
  VstMyFileSendRemoveInfo : TVstMyFileSendRemoveInfo;
  SendFileAddRootHandle : TSendFileAddRootHandle;
begin

    // 路径类型
  if FileExists( FilePath ) then
    SendPathType := SendPathType_File
  else
    SendPathType := SendPathType_Folder;

  DesPcList := TransferScanInfo.DestinationList;
  for i := 0 to DesPcList.Count - 1 do
  begin
    DesPcID := DesPcList[i];

      // 删除 Scan 界面
    VstMyFileSendRemoveInfo := TVstMyFileSendRemoveInfo.Create( FilePath, DesPcID );
    MyFaceChange.AddChange( VstMyFileSendRemoveInfo );

      // 添加 根目录 发送
    SendFileAddRootHandle := TSendFileAddRootHandle.Create( FilePath, DesPcID );
    SendFileAddRootHandle.SetFileSpaceInfo( FileSize, 0 );
    SendFileAddRootHandle.SetFileCount( FileCount );
    SendFileAddRootHandle.SetSendFileStatus( SendPathStatus_Waiting );
    SendFileAddRootHandle.SetSendPathType( SendPathType );
    SendFileAddRootHandle.Update;
    SendFileAddRootHandle.Free;
  end;
end;

constructor TTransferScanHandle.Create(_TransferScanInfo: TTransferScanInfo);
begin
  TransferScanInfo := _TransferScanInfo;
  ScanType := TransferScanInfo.ScanType;
end;

procedure TTransferScanHandle.ResetRootSpace(FilePath: string; FileSize: Int64);
var
  DesPcList : TStringList;
  i : Integer;
  DesPcID : string;
  SendFileSetSpaceHandle : TSendFileSetSpaceHandle;
begin
  DesPcList := TransferScanInfo.DestinationList;
  for i := 0 to DesPcList.Count - 1 do
  begin
    DesPcID := DesPcList[i];

      // 设置空间
    SendFileSetSpaceHandle := TSendFileSetSpaceHandle.Create( FilePath, DesPcID );
    SendFileSetSpaceHandle.SetFileSize( FileSize );
    SendFileSetSpaceHandle.Update;
    SendFileSetSpaceHandle.Free;
  end;
end;

procedure TTransferScanHandle.ScanFile(FilePath: string);
var
  DesList : TStringList;
  TransferFileScanHandle : TTransferFileScanHandle;
  RootSpace : Int64;
  RootFileCount : Integer;
begin
  DesList := TransferScanInfo.DestinationList;

  TransferFileScanHandle := TTransferFileScanHandle.Create;
  TransferFileScanHandle.SetScanType( ScanType );
  TransferFileScanHandle.SetScanPath( FilePath );
  TransferFileScanHandle.SetDesPcList( DesList );
  TransferFileScanHandle.Update;
  RootSpace := TransferFileScanHandle.ScanSize;
  TransferFileScanHandle.Free;

  RootFileCount := 1;

    // 重设 根空间
  if ScanType = ScanType_Job then
    ResetRootSpace( FilePath, RootSpace )
  else
    AddFileSendRoot( FilePath, RootSpace, RootFileCount );
end;

procedure TTransferScanHandle.ScanFolder(FolderPath: string);
var
  DesList : TStringList;
  TransferFolderScanHandle : TTransferFolderScanHandle;
  RootSpace : Int64;
  RootFileCount : Integer;
begin
  DesList := TransferScanInfo.DestinationList;

  TransferFolderScanHandle := TTransferFolderScanHandle.Create( FolderPath );
  TransferFolderScanHandle.SetScanType( ScanType );
  TransferFolderScanHandle.SetScanPath( FolderPath );
  TransferFolderScanHandle.SetDesPcList( DesList );
  TransferFolderScanHandle.Update;
  RootSpace := TransferFolderScanHandle.ScanSize;
  RootFileCount := TransferFolderScanHandle.ScanFileCount;
  TransferFolderScanHandle.Free;

    // 重设 空间
  if ScanType = ScanType_Job then
    ResetRootSpace( FolderPath, RootSpace )
  else
    AddFileSendRoot( FolderPath, RootSpace, RootFileCount );
end;

procedure TTransferScanHandle.Update;
var
  ScanPathList : TStringList;
  i : Integer;
  ScanPath : string;
begin
  ScanPathList := TransferScanInfo.ScanPathList;
  for i := 0 to ScanPathList.Count - 1 do
  begin
    ScanPath := ScanPathList[i];
    if FileExists( ScanPath ) then
      ScanFile( ScanPath )
    else
    if DirectoryExists( ScanPath ) then
      ScanFolder( ScanPath );
  end;
end;

{ TTransferFolderScanHandle }

function TTransferFolderScanHandle.CheckNextSearch: Boolean;
begin
    // 交出 CPU
  Inc( ScanCount );
  if ScanCount >= CopyCount_Sleep then
  begin
    Sleep( 1 );
    ScanCount := 0;
  end;

    // 扫描路径是否存在
  Result := MyTransferJobScanInfo.IsRun;
end;

constructor TTransferFolderScanHandle.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
  ScanCount := 0;
  ScanSize := 0;
  ScanFileCount := 0;
end;

procedure TTransferFolderScanHandle.ScanNextFolder(ChildFolderPath: string);
var
  TransferFolderScanHandle : TTransferFolderScanHandle;
begin
  TransferFolderScanHandle := TTransferFolderScanHandle.Create( ChildFolderPath );
  TransferFolderScanHandle.SetScanPath( ScanPath );
  TransferFolderScanHandle.SetScanType( ScanType );
  TransferFolderScanHandle.SetDesPcList( DesPcList );
  TransferFolderScanHandle.SetScanCount( ScanCount );
  TransferFolderScanHandle.Update;
  ScanSize := ScanSize + TransferFolderScanHandle.ScanSize;
  ScanFileCount := ScanFileCount + TransferFolderScanHandle.ScanFileCount;
  ScanCount := TransferFolderScanHandle.ScanCount;
  TransferFolderScanHandle.Free;
end;

procedure TTransferFolderScanHandle.SetScanCount(_ScanCount: Integer);
begin
  ScanCount := _ScanCount;
end;

procedure TTransferFolderScanHandle.Update;
var
  sch : TSearchRec;
  SearcFullPath, FileName : string;
  ChildPath : string;
  FileSize : Int64;
  FileTime : TDateTime;
  LastWriteTimeSystem: TSystemTime;
begin
    // 循环寻找 目录文件信息
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // 检查是否继续扫描
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      ChildPath := SearcFullPath + FileName;

        // 检查下一层目录
      if DirectoryExists( ChildPath )  then
        ScanNextFolder( ChildPath )
      else
      begin
          // 获取 文件大小
        FileSize := sch.Size;

          // 获取 修改时间
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // 检查 文件信息
        AddSendFile( ChildPath, FileSize, FileTime );

          // 总空间 和 总文件数
        ScanSize := ScanSize + FileSize;
        Inc( ScanFileCount );
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

{ TTransferJobScanHandle }

procedure TTransferJobScanHandle.AddSendFile(FilePath: string; FileSize: Int64;
  FileTime: TDateTime);
var
  i : Integer;
  DesPcID : string;
  SendFileAddHandle : TSendFileAddChildHandle;
  PcAddDownPendTransferFileMsg : TPcAddDownPendTransferFileMsg;
begin
    // 并不是扫描 Job
  if ScanType <> ScanType_Job then
    Exit;

  for i := 0 to DesPcList.Count - 1 do
  begin
    DesPcID := DesPcList[i];

      // 添加
    SendFileAddHandle := TSendFileAddChildHandle.Create( ScanPath, DesPcID );
    SendFileAddHandle.SetFilePath( FilePath );
    SendFileAddHandle.SetFileInfo( FileSize, 0, FileTime );
    SendFileAddHandle.Update;
    SendFileAddHandle.Free;

      // Remove 添加 UpPend
    PcAddDownPendTransferFileMsg := TPcAddDownPendTransferFileMsg.Create;
    PcAddDownPendTransferFileMsg.SetPcID( PcInfo.PcID );
    PcAddDownPendTransferFileMsg.SetUpFilePath( FilePath );
    PcAddDownPendTransferFileMsg.SetFileInfo( 0, FileSize );
    MyClient.SendMsgToPc( DesPcID, PcAddDownPendTransferFileMsg );
  end;
end;

procedure TTransferJobScanHandle.SetDesPcList(_DesPcList: TStringList);
begin
  DesPcList := _DesPcList;
end;

procedure TTransferJobScanHandle.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TTransferJobScanHandle.SetScanType(_ScanType: string);
begin
  ScanType := _ScanType;
end;

{ TTransferFileScanHandle }

procedure TTransferFileScanHandle.Update;
var
  FileSize : Int64;
  FileTime : TDateTime;
begin
    // 读取文件信息
  FileSize := MyFileInfo.getFileSize( ScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // 添加
  AddSendFile( ScanPath, FileSize, FileTime );

    // 总空间
  ScanSize := FileSize;
end;

end.
