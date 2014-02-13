unit UMyShareScan;

interface

uses Classes, Generics.Collections, SysUtils, Windows, UMyUtil, SyncObjs;

type

    // ����ɨ����Ϣ
  TFileShareScanInfo = class
  public
    DesPcID : string;
    ShareScanPath : string;
    ShareScanType : string;
  public
    constructor Create( _DesPcID : string );
    procedure SetShareScanInfo( _ShareScanPath, _ShareScanType : string );
  end;
  TFileShareScanList = TObjectList<TFileShareScanInfo>;

  {$Region ' �����ļ� ������� ' }

    // �����ļ�, ����
  TShareFileAddHandleBase = class
  public
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    ParentPath : string;
    DesPcID : string;
  public
    constructor Create( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetReqInfo( _ParentPath, _DesPcID : string );
  end;

    // ���� List �ļ�
  TShareFileListAddHandle = class( TShareFileAddHandleBase )
  public
    IsFolder : Boolean;
  public
    procedure SetIsFolder( _IsFolder : Boolean );
    procedure Update;
  end;

    // ���� ���� �ļ�
  TShareFileDownAddHandle = class( TShareFileAddHandleBase )
  public
    procedure Update;
  private
    procedure AddToUpPend;
    procedure SendToTarget;
  end;

  {$EndRegion}

  {$Region ' �����ļ� �㷨 ' }

    // Ѱ�ҹ�����Ϣ ����
  TFileShareScanBaseHandle = class
  public
    ScanPath : string;
    DesPcID : string;
  public
    constructor Create( _ScanPath : string );
    procedure SetDesPcID( _DesPcID : string );
  protected
    function CheckNextScan: Boolean;
  end;

    // Ѱ�� �ļ��б�
  TFileShareScanListHandle = class( TFileShareScanBaseHandle )
  public
    procedure Update;
  end;

    // Ѱ�� �ļ�����, �ļ������
  TFileShareScanFileDownHandle = class( TFileShareScanBaseHandle )
  public
    procedure Update;
  end;

    // Ѱ�� �ļ�����, Ŀ¼�����
  TFileShareScanFolderDownHandle = class( TFileShareScanBaseHandle )
  private
    RootScanPath : string;
  public
    procedure SetRootScanPath( _RootScanPath : string );
    procedure Update;
  private
    procedure ScanChildFolder( ChildFolderPath : string );
  end;

  {$EndRegion}

  {$Region ' ɨ����Ϣ ���� ' }

  TFileShareScanInfoHandle = class
  public
    FileShareScanInfo : TFileShareScanInfo;
  public
    DesPcID : string;
    ShareScanPath : string;
    ShareScanType : string;
  private
    IsShareCancel : Boolean;
  public
    constructor Create( _FileShareScanInfo : TFileShareScanInfo );
    procedure Update;
  private
    procedure ScanRootList;
    procedure ScanFolderList;
    procedure ScanFileList;
    procedure ScanFolderDown;
    procedure ScanFileDown;
  private
    procedure ScanListCompleted;
    procedure ScanDownCompleted;
  end;

  {$EndRegion}

    // ɨ���߳�
  TFileShareScanThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure HandleScan( FileShareScanInfo : TFileShareScanInfo );
  end;
  TFileShareScanThreadList = class( TObjectList<TFileShareScanThread> )
  public
    procedure StopAllThread;
    procedure RunAllThread;
  end;

    // ɨ����ƶ���
  TMyFileShareScanInfo = class
  public
    IsRun : Boolean;
    DataLock : TCriticalSection;
    FileShareScanList : TFileShareScanList;
  public
    FileShareScanThreadList : TFileShareScanThreadList;
  public
    constructor Create;
    procedure StopScan;
    destructor Destroy; override;
  public
    procedure AddScanInfo( FileShareScanInfo : TFileShareScanInfo );
    function getScanInfo : TFileShareScanInfo;
  end;

const
  ShareScanType_FileList = 'FileList';
  ShareScanType_FileDown = 'FileDown';

  ScanThread_Count = 1;

var
  MyFileShareScanInfo : TMyFileShareScanInfo;

implementation

uses UMyClient, UMyNetPcInfo, UMyShareInfo, UMyShareControl, UJobFace;

{ TFileShareScanInfo }

constructor TFileShareScanInfo.Create(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

procedure TFileShareScanInfo.SetShareScanInfo(_ShareScanPath,
  _ShareScanType: string);
begin
  ShareScanPath := _ShareScanPath;
  ShareScanType := _ShareScanType;
end;

{ TFileShareScanThread }

constructor TFileShareScanThread.Create;
begin
  inherited Create( True );
end;

destructor TFileShareScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TFileShareScanThread.Execute;
var
  FileShareScanInfo : TFileShareScanInfo;
begin
  while not Terminated do
  begin
    FileShareScanInfo := MyFileShareScanInfo.getScanInfo;
    if FileShareScanInfo = nil then
    begin
      Suspend;
      Continue;
    end;

      // ����ɨ����Ϣ
    HandleScan( FileShareScanInfo );

    FileShareScanInfo.Free;
  end;
  inherited;
end;

procedure TFileShareScanThread.HandleScan(
  FileShareScanInfo: TFileShareScanInfo);
var
  FileShareScanInfoHandle : TFileShareScanInfoHandle;
begin
  FileShareScanInfoHandle := TFileShareScanInfoHandle.Create( FileShareScanInfo );
  FileShareScanInfoHandle.Update;
  FileShareScanInfoHandle.Free;
end;

{ TFileShareScanListHandle }

procedure TFileShareScanListHandle.Update;
var
  sch : TSearchRec;
  LastWriteTimeSystem: TSystemTime;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  ShareListFileAddHandle : TShareFileListAddHandle;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      ChildPath := SearcFullPath + FileName;
      IsFolder := DirectoryExists( ChildPath );
        // ��ȡ �ļ���С
      FileSize := sch.Size;
        // ��ȡ �޸�ʱ��
      FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
      LastWriteTimeSystem.wMilliseconds := 0;
      FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

        // �ҵ��ļ�
      ShareListFileAddHandle := TShareFileListAddHandle.Create( ChildPath );
      ShareListFileAddHandle.SetIsFolder( IsFolder );
      ShareListFileAddHandle.SetFileInfo( FileSize, FileTime );
      ShareListFileAddHandle.SetReqInfo( ScanPath, DesPcID );
      ShareListFileAddHandle.Update;
      ShareListFileAddHandle.Free;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;
{ TFindShareListFile }

constructor TShareFileAddHandleBase.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TShareFileAddHandleBase.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime
end;

procedure TShareFileAddHandleBase.SetReqInfo(_ParentPath, _DesPcID: string);
begin
  ParentPath := _ParentPath;
  DesPcID := _DesPcID;
end;

{ TFileShareScanBaseHandle }

function TFileShareScanBaseHandle.CheckNextScan: Boolean;
begin
  Result := MyFileShareScanInfo.IsRun;
end;

constructor TFileShareScanBaseHandle.Create(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TFileShareScanBaseHandle.SetDesPcID(_DesPcID: string);
begin
  DesPcID := _DesPcID;
end;

{ TFileShareScanFolderDownHandle }

procedure TFileShareScanFolderDownHandle.ScanChildFolder(
  ChildFolderPath: string);
var
  FileShareScanFolderDownHandle : TFileShareScanFolderDownHandle;
begin
  FileShareScanFolderDownHandle := TFileShareScanFolderDownHandle.Create( ChildFolderPath );
  FileShareScanFolderDownHandle.SetRootScanPath( RootScanPath );
  FileShareScanFolderDownHandle.SetDesPcID( DesPcID );
  FileShareScanFolderDownHandle.Update;
  FileShareScanFolderDownHandle.Free;
end;

procedure TFileShareScanFolderDownHandle.SetRootScanPath(_RootScanPath: string);
begin
  RootScanPath := _RootScanPath;
end;

procedure TFileShareScanFolderDownHandle.Update;
var
  sch : TSearchRec;
  LastWriteTimeSystem: TSystemTime;
  SearcFullPath, FileName, ChildPath : string;
  IsFolder : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  ShareFileDownAddHandle : TShareFileDownAddHandle;
begin
    // ѭ��Ѱ�� Ŀ¼�ļ���Ϣ
  SearcFullPath := MyFilePath.getPath( ScanPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat

        // ����Ƿ����ɨ��
      if not CheckNextScan then
        Break;

      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      ChildPath := SearcFullPath + FileName;
      if DirectoryExists( ChildPath ) then
        ScanChildFolder( ChildPath )
      else
      begin
          // ��ȡ �ļ���С
        FileSize := sch.Size;
          // ��ȡ �޸�ʱ��
        FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
        LastWriteTimeSystem.wMilliseconds := 0;
        FileTime := SystemTimeToDateTime( LastWriteTimeSystem );

          // �ҵ��ļ�
        ShareFileDownAddHandle := TShareFileDownAddHandle.Create( ChildPath );
        ShareFileDownAddHandle.SetFileInfo( FileSize, FileTime );
        ShareFileDownAddHandle.SetReqInfo( RootScanPath, DesPcID );
        ShareFileDownAddHandle.Update;
        ShareFileDownAddHandle.Free;
      end;

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

{ TShareFileListAddHandle }

procedure TShareFileListAddHandle.SetIsFolder(_IsFolder: Boolean);
begin
  IsFolder := _IsFolder;
end;

procedure TShareFileListAddHandle.Update;
var
  ClientSendShareListMsg : TClientSendShareListMsg;
begin
  ClientSendShareListMsg := TClientSendShareListMsg.Create;
  ClientSendShareListMsg.SetPcID( PcInfo.PcID );
  ClientSendShareListMsg.SetParentPath( ParentPath );
  ClientSendShareListMsg.SetFilePath( FilePath, IsFolder );
  ClientSendShareListMsg.SetFileInfo( FileSize, FileTime );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareListMsg );
end;

{ TShareFileDownAddHandle }

procedure TShareFileDownAddHandle.AddToUpPend;
var
  DesPcName : string;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );

    // ��ӵ�����
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_UpPend );
  VirTransferChildAddInfo.SetChildID( DesPcID, FilePath );
  VirTransferChildAddInfo.SetFileBase( FilePath, DesPcID );
  VirTransferChildAddInfo.SetFileInfo( DesPcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( 0 );
  VirTransferChildAddInfo.SetStatusInfo( FileType_Share, FileStatus_Waiting );
  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

procedure TShareFileDownAddHandle.SendToTarget;
var
  ClientSendShareDownMsg : TClientSendShareDownMsg;
begin
  ClientSendShareDownMsg := TClientSendShareDownMsg.Create;
  ClientSendShareDownMsg.SetPcID( PcInfo.PcID );
  ClientSendShareDownMsg.SetDownloadPath( ParentPath );
  ClientSendShareDownMsg.SetFilePath( FilePath );
  ClientSendShareDownMsg.SetFileInfo( FileSize, FileTime );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareDownMsg );
end;

procedure TShareFileDownAddHandle.Update;
begin
  AddToUpPend;

  SendToTarget;
end;

{ TFileShareScanFileDownHandle }

procedure TFileShareScanFileDownHandle.Update;
var
  FileSize : Int64;
  FileTime : TDateTime;
  ShareFileDownAddHandle : TShareFileDownAddHandle;
begin
  FileSize := MyFileInfo.getFileSize( ScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ScanPath );

    // �ҵ��ļ�
  ShareFileDownAddHandle := TShareFileDownAddHandle.Create( ScanPath );
  ShareFileDownAddHandle.SetFileInfo( FileSize, FileTime );
  ShareFileDownAddHandle.SetReqInfo( ScanPath, DesPcID );
  ShareFileDownAddHandle.Update;
  ShareFileDownAddHandle.Free;
end;

{ TMyFileShareScanInfo }

procedure TMyFileShareScanInfo.AddScanInfo(
  FileShareScanInfo: TFileShareScanInfo);
begin
  DataLock.Enter;
  FileShareScanList.Add( FileShareScanInfo );
  DataLock.Leave;

    // �����߳�
  if IsRun then
    FileShareScanThreadList.RunAllThread;
end;

constructor TMyFileShareScanInfo.Create;
var
  i : Integer;
  FileShareScanThread : TFileShareScanThread;
begin
  DataLock := TCriticalSection.Create;
  FileShareScanList := TFileShareScanList.Create;
  FileShareScanList.OwnsObjects := False;

  FileShareScanThreadList := TFileShareScanThreadList.Create;
  for i := 0 to ScanThread_Count - 1 do
  begin
    FileShareScanThread := TFileShareScanThread.Create;
    FileShareScanThreadList.Add( FileShareScanThread );
  end;

  IsRun := True;
end;

destructor TMyFileShareScanInfo.Destroy;
begin
  FileShareScanThreadList.Free;
  FileShareScanList.OwnsObjects := True;
  FileShareScanList.Free;
  DataLock.Free;
  inherited;
end;

function TMyFileShareScanInfo.getScanInfo: TFileShareScanInfo;
begin
  DataLock.Enter;
  if FileShareScanList.Count > 0 then
  begin
    Result := FileShareScanList[0];
    FileShareScanList.Delete(0);
  end
  else
    Result := nil;
  DataLock.Leave;
end;

procedure TMyFileShareScanInfo.StopScan;
var
  i : Integer;
begin
  IsRun := False;

    // ֹͣ�߳�
  FileShareScanThreadList.StopAllThread;
end;

{ TFileShareScanThreadList }

procedure TFileShareScanThreadList.RunAllThread;
var
  i : Integer;
begin
  for i := 0 to Self.Count - 1 do
    Self[i].Resume;
end;

procedure TFileShareScanThreadList.StopAllThread;
var
  i : Integer;
begin
  for i := Self.Count - 1 downto 0 do
    Self.Delete( i );
end;

{ TFileShareScanInfoHandle }

constructor TFileShareScanInfoHandle.Create(
  _FileShareScanInfo: TFileShareScanInfo);
begin
  FileShareScanInfo := _FileShareScanInfo;
  DesPcID := FileShareScanInfo.DesPcID;
  ShareScanPath := FileShareScanInfo.ShareScanPath;
  ShareScanType := FileShareScanInfo.ShareScanType;
end;

procedure TFileShareScanInfoHandle.ScanDownCompleted;
var
  ClientSendShareDownCompletedMsg : TClientSendShareDownCompletedMsg;
begin
  ClientSendShareDownCompletedMsg := TClientSendShareDownCompletedMsg.Create;
  ClientSendShareDownCompletedMsg.SetPcID( PcInfo.PcID );
  ClientSendShareDownCompletedMsg.SetDownloadPath( ShareScanPath );
  ClientSendShareDownCompletedMsg.SetIsShareCancel( IsShareCancel );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareDownCompletedMsg );
end;

procedure TFileShareScanInfoHandle.ScanFileDown;
var
  FileShareScanFileDownHandle : TFileShareScanFileDownHandle;
begin
  FileShareScanFileDownHandle := TFileShareScanFileDownHandle.Create( ShareScanPath );
  FileShareScanFileDownHandle.SetDesPcID( DesPcID );
  FileShareScanFileDownHandle.Update;
  FileShareScanFileDownHandle.Free;
end;

procedure TFileShareScanInfoHandle.ScanFileList;
var
  FileSize : Int64;
  FileTime : TDateTime;
  ShareListFileAddHandle : TShareFileListAddHandle;
begin
  FileSize := MyFileInfo.getFileSize( ShareScanPath );
  FileTime := MyFileInfo.getFileLastWriteTime( ShareScanPath );

    // �ҵ��ļ�
  ShareListFileAddHandle := TShareFileListAddHandle.Create( ShareScanPath );
  ShareListFileAddHandle.SetIsFolder( False );
  ShareListFileAddHandle.SetFileInfo( FileSize, FileTime );
  ShareListFileAddHandle.SetReqInfo( ShareScanPath, DesPcID );
  ShareListFileAddHandle.Update;
  ShareListFileAddHandle.Free;
end;

procedure TFileShareScanInfoHandle.ScanFolderDown;
var
  FileShareScanFolderDownHandle : TFileShareScanFolderDownHandle;
begin
  FileShareScanFolderDownHandle := TFileShareScanFolderDownHandle.Create( ShareScanPath );
  FileShareScanFolderDownHandle.SetDesPcID( DesPcID );
  FileShareScanFolderDownHandle.SetRootScanPath( ShareScanPath );
  FileShareScanFolderDownHandle.Update;
  FileShareScanFolderDownHandle.Free;
end;

procedure TFileShareScanInfoHandle.ScanFolderList;
var
  FileShareScanListHandle : TFileShareScanListHandle;
begin
  FileShareScanListHandle := TFileShareScanListHandle.Create( ShareScanPath );
  FileShareScanListHandle.SetDesPcID( DesPcID );
  FileShareScanListHandle.Update;
  FileShareScanListHandle.Free;
end;

procedure TFileShareScanInfoHandle.ScanListCompleted;
var
  ClientSendShareListCompletedMsg : TClientSendShareListCompletedMsg;
begin
  ClientSendShareListCompletedMsg := TClientSendShareListCompletedMsg.Create;
  ClientSendShareListCompletedMsg.SetPcID( PcInfo.PcID );
  ClientSendShareListCompletedMsg.SetParentPath( ShareScanPath );
  ClientSendShareListCompletedMsg.SetIsCancelShare( IsShareCancel );
  MyClient.SendMsgToPc( DesPcID, ClientSendShareListCompletedMsg );
end;

procedure TFileShareScanInfoHandle.ScanRootList;
var
  SharePathList : TStringList;
  i : Integer;
  SharePath : string;
  IsFolder : Boolean;
  FileSize : Int64;
  FileTime : TDateTime;
  ClientSendShareListMsg : TClientSendShareListMsg;
begin
  SharePathList := MySharePathInfoReadUtil.ReadSharePathList;
  for i := 0 to SharePathList.Count - 1 do
  begin
    SharePath := SharePathList[i];
    IsFolder := DirectoryExists( SharePath );
    FileSize := MyFileInfo.getFileSize( SharePath );
    FileTime := MyFileInfo.getFileLastWriteTime( SharePath );

    ClientSendShareListMsg := TClientSendShareListMsg.Create;
    ClientSendShareListMsg.SetParentPath( '' );
    ClientSendShareListMsg.SetFilePath( SharePath, IsFolder );
    ClientSendShareListMsg.SetFileInfo( FileSize, FileTime );
    ClientSendShareListMsg.SetPcID( PcInfo.PcID );
    MyClient.SendMsgToPc( DesPcID, ClientSendShareListMsg );
  end;
  SharePathList.Free;
end;

procedure TFileShareScanInfoHandle.Update;
begin
    // �ļ� �б�
  if ShareScanType = ShareScanType_FileList then
  begin
      // ������ ����·��
    IsShareCancel := False;

    if ShareScanPath = '' then
      ScanRootList
    else
    if not MySharePathInfoReadUtil.ReadFileIsEnable( ShareScanPath ) then
      IsShareCancel := True
    else
    if FileExists( ShareScanPath ) then
      ScanFileList
    else
      ScanFolderList;
    ScanListCompleted;
  end
  else   // �ļ� ����
  begin
       // ������ ����·��
    IsShareCancel := False;
    if not MySharePathInfoReadUtil.ReadFileIsEnable( ShareScanPath ) then
      IsShareCancel := True
    else
    if FileExists( ShareScanPath ) then
      ScanFileDown
    else
      ScanFolderDown;
    ScanDownCompleted;
  end;
end;

end.
