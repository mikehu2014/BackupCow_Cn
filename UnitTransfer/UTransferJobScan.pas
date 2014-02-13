unit UTransferJobScan;

interface

uses SyncObjs, Classes, SysUtils, Generics.Collections, UMyUtil, Windows, uDebug;

type

{$Region ' ɨ�跢�͵� �ļ� ' }

    // ɨ�� ���� Job ����
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

    // ɨ�� �ļ� ���� Job
  TTransferFileScanHandle = class( TTransferJobScanHandle )
  public
    procedure Update;
  end;

    // ɨ�� �ļ��� ���� Job
  TTransferFolderScanHandle = class( TTransferJobScanHandle )
  public
    ScanFileCount : Integer; // ���ļ���
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

    // ɨ�� ��Ϣ
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

    // ɨ�账��
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

    // ɨ���߳�
  TTransferScanJobThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

    // ������
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

      // ���� ɨ����Ϣ
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

    // ·������
  if FileExists( FilePath ) then
    SendPathType := SendPathType_File
  else
    SendPathType := SendPathType_Folder;

  DesPcList := TransferScanInfo.DestinationList;
  for i := 0 to DesPcList.Count - 1 do
  begin
    DesPcID := DesPcList[i];

      // ɾ�� Scan ����
    VstMyFileSendRemoveInfo := TVstMyFileSendRemoveInfo.Create( FilePath, DesPcID );
    MyFaceChange.AddChange( VstMyFileSendRemoveInfo );

      // ��� ��Ŀ¼ ����
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

      // ���ÿռ�
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

    // ���� ���ռ�
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

    // ���� �ռ�
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
    // ���� CPU
  Inc( ScanCount );
  if ScanCount >= CopyCount_Sleep then
  begin
    Sleep( 1 );
    ScanCount := 0;
  end;

    // ɨ��·���Ƿ����
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
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextSearch then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      ChildPath := SearcFullPath + FileName;

        // �����һ��Ŀ¼
      if DirectoryExists( ChildPath )  then
        ScanNextFolder( ChildPath )
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;

          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // ��� �ļ���Ϣ
        AddSendFile( ChildPath, FileSize, FileTime );

          // �ܿռ� �� ���ļ���
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
    // ������ɨ�� Job
  if ScanType <> ScanType_Job then
    Exit;

  for i := 0 to DesPcList.Count - 1 do
  begin
    DesPcID := DesPcList[i];

      // ���
    SendFileAddHandle := TSendFileAddChildHandle.Create( ScanPath, DesPcID );
    SendFileAddHandle.SetFilePath( FilePath );
    SendFileAddHandle.SetFileInfo( FileSize, 0, FileTime );
    SendFileAddHandle.Update;
    SendFileAddHandle.Free;

      // Remove ��� UpPend
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
    // ��ȡ�ļ���Ϣ
  FileSize := MyFileInfo.getFileSize( ScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // ���
  AddSendFile( ScanPath, FileSize, FileTime );

    // �ܿռ�
  ScanSize := FileSize;
end;

end.
