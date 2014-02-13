unit UBackupJobScan;

interface

uses UFileBaseInfo, UChangeInfo, Generics.Collections, UMyUtil, Classes,
     Windows, UModelUtil, SyncObjs, SysUtils, Math, uDebug;

type

{$Region ' ɨ��Ŀ¼ ' }

  {$Region ' ���ݽṹ ' }

    // Pc �� Available Space
  TTempPcSpace = class
  public
    PcID : string;
    AvailableSpace, ComsumpSpace : Int64;
  public
    constructor Create( _PcID : string );
    procedure SetSpaceInfo( _AvailableSpace, _ComsumpSpace : Int64 );
  public
    function IsSmallThenPc( PcSpace : TTempPcSpace ): Boolean;
  end;
  TTempPcSpaceList = class( TObjectList<TTempPcSpace> )
  public
    procedure SortSpace;
  end;

  TTempBackupPathOwnerInfo = class
  public
    PcID : string;
    OwnerSpace : Int64;
    OwnerFileCount : Integer;
  public
    constructor Create( _PcID : string );
  end;
  TTempBackupPathOwnerPair = TPair< string , TTempBackupPathOwnerInfo >;
  TTempBackupPathOwnerHash = class(TStringDictionary< TTempBackupPathOwnerInfo >);


  {$EndRegion}

  {$Region ' ���ݲ��� ' }

    // ���� ͬ��Job ����
  TBackupJobScanner = class
  protected
    ScanPath : string;
    CopyCount : Integer;
    TempPcSpaceList : TTempPcSpaceList;
    IsNotEnoughPc : Boolean;
  public
    procedure SetScanPath( _ScanPath : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure SetTempPcSpaceList( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;virtual;abstract;
  protected
    procedure CheckFileJob( FileInfo : TTempBackupFileInfo );virtual;
    procedure CheckOfflineJob( FileInfo : TTempBackupFileInfo );
    procedure BackupJobAddHandle( PcID: string; FileInfo : TTempBackupFileInfo );
  protected
    function getFilePath( FileName : string ): string;virtual;
  end;

    // ���� �Ǹ��ļ� ͬ��Job
  TBackupFileJobScanner = class( TBackupJobScanner )
  public
    procedure Update;override;
  protected
    function getFilePath( FileName : string ): string;override;
  end;

    // ���� Ŀ¼ ͬ��Job ����
  TBackupFolderJobScanner = class( TBackupJobScanner )
  private
    ScanCount, TotalFileCount : Integer;
    TempBackupFolderInfo : TTempBackupFolderInfo;
  public
    constructor Create;
    procedure SetScanCount( _ScanCount : Integer );
    procedure SetTotalCount( _TotalCount : Integer );
    procedure Update;override;
  private
    procedure FindTempBackupFolderInfo;
    procedure CheckFileCopy;
    procedure CheckFolderCopy;
    procedure DeleteTempBackupFolderInfo;
  protected
    function CheckNextSearch : Boolean;virtual;
    function getFolderJobScan : TBackupFolderJobScanner;virtual;abstract;
    procedure ResetFolderJobScan( FolderJobScan : TBackupFolderJobScanner );virtual;
  end;

    // ���� ��·�� ͬ��Job
  TBackupRootJobScanner = class( TBackupFolderJobScanner )
  private
    BackupPathOwnerHash : TTempBackupPathOwnerHash;
    LastCompletedSpace, CompletedSpace : Int64;
  public
    constructor Create;
    procedure SetBackupPathOwnerHash( _BackupPathOwnerHash : TTempBackupPathOwnerHash );
    procedure Update;override;
  protected
    function CheckNextSearch : Boolean;override;
    procedure CheckFileJob( FileInfo : TTempBackupFileInfo );override;
    function getFolderJobScan : TBackupFolderJobScanner;override;
    procedure ResetFolderJobScan( FolderJobScan : TBackupFolderJobScanner );override;
  private
    procedure CheckLoadedJob( FileInfo : TTempBackupFileInfo );
    procedure CheckBackupPathOwner( FileInfo : TTempBackupFileInfo );
  private       // TreeView ����״̬
    procedure ResetAnalyzingStatus;
    procedure ResetStopStatus;
    procedure AddBackupBoardFileCount;
  private       // Ŀ¼�ռ���Ϣ״̬
    procedure ReadLastCompletedSpace;
    procedure SetCompletedSpace;
  end;

    // ���� ��Ŀ¼ ͬ��Job
  TBackupRootFolderJobScanner = class( TBackupRootJobScanner )
  end;

    // ���� ���ļ� ͬ��Job
  TBackupRootFileJobScanner = class( TBackupRootJobScanner )
  protected
    function getFilePath( FileName : string ): string;override;
  end;

    // ���� �Ǹ�Ŀ¼ ͬ��Job
  TBackupChildFolderJobFolderScanner = class( TBackupFolderJobScanner )
  protected
    function getFolderJobScan : TBackupFolderJobScanner;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ���� Backup Job ���� ' }

  TBackupJobAdd = class
  public
    PcID, FilePath : string;
    PcName : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    constructor Create( _PcID, _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;
  private
    procedure AddToBackupCopy;
    procedure AddToDestinationPc;
    procedure AddToBackupJob;
  end;

{$EndRegion}

{$Region ' ���� Job ɨ�账�� ' }

    // ���� ���� Pc ���ÿռ���Ϣ
  TFindTempPcSpace = class
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;
  end;

    // ���� ���� Pc ���ÿռ�
  TResetPcSpace = class
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create( _TempPcSpaceList : TTempPcSpaceList );
    procedure Update;
  end;

    // ɨ�� ����·������
  TBackupPathJobScanner = class
  private
    ScanPath : string;
    CopyCount : Integer;
  private
    TempPcSpaceList : TTempPcSpaceList;
  public
    constructor Create;
    procedure SetScanPath( _ScanPath : string );
    procedure Update;virtual;
    destructor Destroy; override;
  private
    procedure FindTempPcSpaceList;
    procedure BackupJobScan;virtual;abstract;
    procedure ResetPcSpaceList;
  end;

    // ɨ�� ��·��
  TRootPathJobScanner = class( TBackupPathJobScanner )
  protected
    IsNotEnouthPc : Boolean;
    CompletedSpace : Int64;
    BackupPathOwnerHash : TTempBackupPathOwnerHash;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  protected
    procedure BackupJobScan;override;
  private
    procedure AddBackupBoard;
    procedure RemoveBackupBoard;
  private
    procedure ResetBackupPathOwner;
    procedure ResetNotEnoughPcBackup;
    procedure ResetCompletedSpace;
    procedure BackupSelectRefresh;
  end;

    // ɨ�� �Ǹ�·��
  TChildPathJobScanner = class( TBackupPathJobScanner )
  protected
    procedure BackupJobScan;override;
  end;

{$EndRegion}

    // ɨ�� Job ·����Ϣ
  TBackupJobScanInfo = class
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;
  TBackupJobScanList = class(TObjectList< TBackupJobScanInfo >);

    // ���� ɨ�� Job
  TBackupJobScanHandle = class
  public
    BackupJobScanInfo : TBackupJobScanInfo;
    ScanPath : string;
  public
    constructor Create( _BackupJobScanInfo : TBackupJobScanInfo );
    procedure Update;
  end;

      // ɨ���߳�
  TBackupJobScanThread = class( TThread )
  private
    Lock : TCriticalSection;
    BackupJobScanList : TBackupJobScanList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddScanInfo( ScanInfo : TBackupJobScanInfo );
  private
    function getNextScanInfo : TBackupJobScanInfo;
    procedure ScanJobHandle( ScanInfo : TBackupJobScanInfo );
    procedure ScanCompleted;
  end;

    // ����Job ������
  TMyBackupJobScanInfo = class
  private
    IsRun : Boolean;
    BackupJobScanThread : TBackupJobScanThread;
  public
    constructor Create;
    procedure AddScanPath( BackupJobScanInfo : TBackupJobScanInfo );
    procedure StopJobScan;
  end;

const
  ScanCount_Sleep : Integer = 10;

var
  MyBackupJobScanInfo : TMyBackupJobScanInfo; // ɨ�豸�� Job

implementation

uses UJobFace, UMyFileUpload, UMyClient, UMyServer, UMyJobInfo, UMyFileTransfer, UBackupInfoFace,
     UMyBackupInfo, UMyNetPcInfo, USettingInfo, UBackupInfoXml, UBackupBoardInfo,
     UBackupInfoControl, URegisterInfo, UJobControl, UBackupFileConfirm;

{ TCheckFolderScan }

procedure TBackupFolderJobScanner.CheckFileCopy;
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

      // ��� Job
    CheckFileJob( p.Value );
  end;
end;

procedure TBackupFolderJobScanner.CheckFolderCopy;
var
  FolderHash : TTempBackupFolderHash;
  p : TTempBackupFolderPair;
  FolderName, ChildPath : string;
  BackupFolderJobScanner : TBackupFolderJobScanner;
begin
  FolderHash := TempBackupFolderInfo.TempBackupFolderHash;
  for p in FolderHash do
  begin
      // �������
    if not CheckNextSearch then
      Break;

    FolderName := p.Value.FileName;
    ChildPath := MyFilePath.getPath( ScanPath ) + FolderName;

      // ɨ�� ��Ŀ¼
    BackupFolderJobScanner := getFolderJobScan;
    BackupFolderJobScanner.SetScanPath( ChildPath );
    BackupFolderJobScanner.SetScanCount( ScanCount );
    BackupFolderJobScanner.SetTotalCount( TotalFileCount );
    BackupFolderJobScanner.SetCopyCount( CopyCount );
    BackupFolderJobScanner.SetTempPcSpaceList( TempPcSpaceList );
    BackupFolderJobScanner.Update;
    ScanCount := BackupFolderJobScanner.ScanCount;
    TotalFileCount := BackupFolderJobScanner.TotalFileCount;
    IsNotEnoughPc := IsNotEnoughPc or BackupFolderJobScanner.IsNotEnoughPc;
    ResetFolderJobScan( BackupFolderJobScanner );
    BackupFolderJobScanner.Free;
  end;
end;

function TBackupFolderJobScanner.CheckNextSearch: Boolean;
begin
  inc( ScanCount );
  Inc( TotalFileCount );
  if ScanCount >= ScanCount_Sleep then
  begin
    Sleep(1);
    ScanCount := 0;
  end;

  Result := MyBackupJobScanInfo.IsRun;
  Result := Result and MyBackupPathInfoUtil.ReadIsEnable( ScanPath );
end;

constructor TBackupFolderJobScanner.Create;
begin
  inherited;

  ScanCount := 0;
  TotalFileCount := 0;
end;

procedure TBackupFolderJobScanner.DeleteTempBackupFolderInfo;
begin
  TempBackupFolderInfo.Free;
end;

procedure TBackupFolderJobScanner.FindTempBackupFolderInfo;
begin
    // ��ȡ ������Ϣ
  TempBackupFolderInfo := MyBackupFolderInfoUtil.ReadTempBackupFolderInfo( ScanPath );
end;

procedure TBackupFolderJobScanner.ResetFolderJobScan(
  FolderJobScan: TBackupFolderJobScanner);
begin

end;

procedure TBackupFolderJobScanner.SetScanCount(_ScanCount: Integer);
begin
  ScanCount := _ScanCount;
end;

procedure TBackupFolderJobScanner.SetTotalCount(_TotalCount: Integer);
begin
  TotalFileCount := _TotalCount;
end;

procedure TBackupFolderJobScanner.Update;
begin
    // ��ȡ ����Ŀ¼ ������Ϣ
  FindTempBackupFolderInfo;

    // ���� Job
  CheckFileCopy;

    // ���� ��Ŀ¼ Job
  CheckFolderCopy;

    // ɾ�� ������Ϣ
  DeleteTempBackupFolderInfo;
end;



{ TCheckPcSpace }

function TTempPcSpace.IsSmallThenPc(PcSpace: TTempPcSpace): Boolean;
begin
    // �ѱ��� �ռ�Ƚ�
  if PcSpace.ComsumpSpace > Self.ComsumpSpace then
    Result := True
  else
  if PcSpace.ComsumpSpace = Self.ComsumpSpace then
    Result := PcSpace.AvailableSpace > Self.AvailableSpace // ���ÿռ�Ƚ�
  else
    Result := False;
end;

constructor TTempPcSpace.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TCheckPcSpaceList }

procedure TTempPcSpaceList.SortSpace;
var
  i, j : Integer;
  PcSpace1, PcSpace2, Temp : TTempPcSpace;
begin
  Self.OwnsObjects := False;
    // ð������, Ȩ��С���ź�, Ȩ�ش����ǰ.
    // Ȩ�����, ���ռ�����, �ռ�С���ź�, �ռ�����ǰ.
  for i := 0 to Self.Count - 2 do
    for j := 0 to Self.Count - 2 - i do
    begin
      PcSpace1 := Self[ j ];
      PcSpace2 := Self[ j + 1 ];

          // ��ǰ��Ȩ��С, λ�÷����仯
      if PcSpace1.IsSmallThenPc( PcSpace2 ) then
      begin
        Temp := Self[ j ];
        Self[ j ] := Self[ j + 1 ];
        Self[ j + 1 ] := Temp;
      end;
    end;
  Self.OwnsObjects := True;
end;

{ TFindCheckPcSpace }

constructor TFindTempPcSpace.Create(_TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

procedure TFindTempPcSpace.Update;
var
  NetPcHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
  AvailableSpace, ComsumpSpace : Int64;
  TempPcSpace : TTempPcSpace;
begin
  MyNetPcInfo.EnterData;
  NetPcHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcHash do
  begin
      // ���� ���� Pc
    if  not p.Value.IsBackup or  // ������
        not p.Value.IsOnline or  // ����
       ( p.Value.PcID = PcInfo.PcID ) or  // ����
       ( TransferSafeSettingInfo.IsRemoveForbid and             // Զ�̽�ֹ
        not MyParseHost.CheckIpLan( p.Value.Ip, PcInfo.LanIp ) )
    then
      Continue;

      // ��� ���� Pc
    AvailableSpace := p.Value.TotalSpace - p.Value.UsedSpace;
    ComsumpSpace := MyBackupPathInfoUtil.ReadComsumpPcSpace( p.Value.PcID );
    TempPcSpace := TTempPcSpace.Create( p.Value.PcID );
    TempPcSpace.SetSpaceInfo( AvailableSpace, ComsumpSpace );
    TempPcSpaceList.Add( TempPcSpace );
  end;
  MyNetPcInfo.LeaveData;
end;


{ TBackupJobAddHandle }

procedure TBackupJobAdd.AddToBackupCopy;
var
  BackupCopyAddPendHandle : TBackupCopyAddPendHandle;
begin
  BackupCopyAddPendHandle := TBackupCopyAddPendHandle.Create( FilePath );
  BackupCopyAddPendHandle.SetCopyOwner( PcID );
  BackupCopyAddPendHandle.Update;
  BackupCopyAddPendHandle.Free;
end;

procedure TBackupJobAdd.AddToBackupJob;
var
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
begin
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( FilePath, PcID );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TBackupJobAdd.AddToDestinationPc;
var
  PcAddDownPendBackupFileMsg : TPcAddDownPendBackupFileMsg;
begin
    // ����
  PcAddDownPendBackupFileMsg := TPcAddDownPendBackupFileMsg.Create;
  PcAddDownPendBackupFileMsg.SetPcID( PcInfo.PcID );
  PcAddDownPendBackupFileMsg.SetFileInfo( 0, FileSize );
  PcAddDownPendBackupFileMsg.SetUpFilePath( FilePath );

  MyClient.SendMsgToPc( PcID, PcAddDownPendBackupFileMsg );
end;

constructor TBackupJobAdd.Create(_PcID, _FilePath: string);
begin
  PcID := _PcID;
  FilePath := _FilePath;
end;

procedure TBackupJobAdd.SetFileInfo(_FileSize: Int64; _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupJobAdd.Update;
begin
    // Pc ������
  if not MyNetPcInfoReadUtil.ReadIsOnline( PcID ) then
    Exit;

    // Pc Name
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );

    // ֪ͨ Ŀ�� Pc
  AddToDestinationPc;

    // ��� Copy ��Ϣ
  AddToBackupCopy;

    // ��� Backup Job
  AddToBackupJob;
end;

{ TBackupJobScanThread }

procedure TBackupJobScanThread.AddScanInfo(ScanInfo: TBackupJobScanInfo);
begin
  Lock.Enter;
  BackupJobScanList.Add( ScanInfo );
  Lock.Leave;

  Resume;
end;

constructor TBackupJobScanThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  BackupJobScanList := TBackupJobScanList.Create;
  BackupJobScanList.OwnsObjects := False;
end;

destructor TBackupJobScanThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  BackupJobScanList.OwnsObjects := True;
  BackupJobScanList.Free;
  Lock.Free;

  inherited;
end;

procedure TBackupJobScanThread.Execute;
var
  BackupJobScanInfo : TBackupJobScanInfo;
begin
  while not Terminated do
  begin
    BackupJobScanInfo := getNextScanInfo;

      // �ѱ�������·��
    if BackupJobScanInfo = nil then
    begin
      ScanCompleted;
      if not Terminated then
        Suspend;
      Continue;
    end;

      // ɨ���ļ� �� Ŀ¼
    ScanJobHandle( BackupJobScanInfo );

    BackupJobScanInfo.Free;
  end;

  inherited;
end;

function TBackupJobScanThread.getNextScanInfo: TBackupJobScanInfo;
begin
  Lock.Enter;
  if BackupJobScanList.Count > 0 then
  begin
    Result := BackupJobScanList[0];
    BackupJobScanList.Delete(0);
  end
  else
    Result := nil;
  Lock.Leave;
end;

procedure TBackupJobScanThread.ScanCompleted;
var
  BackupTvBackupStopInfo : TBackupTvBackupStopInfo;
begin
    // ֪ͨ���� �������
  BackupTvBackupStopInfo := TBackupTvBackupStopInfo.Create;
  MyBackupFileFace.AddChange( BackupTvBackupStopInfo );

    // ���� ����Ϣ
  MyClient.UpgradeCloudInfo;
end;

procedure TBackupJobScanThread.ScanJobHandle(ScanInfo : TBackupJobScanInfo);
var
  BackupJobScanHandle : TBackupJobScanHandle;
begin
  BackupJobScanHandle := TBackupJobScanHandle.Create( ScanInfo );
  BackupJobScanHandle.Update;
  BackupJobScanHandle.Free;
end;

{ TMyBackupJobScanInfo }

procedure TMyBackupJobScanInfo.AddScanPath(BackupJobScanInfo : TBackupJobScanInfo);
begin
  if not IsRun then
    Exit;

  BackupJobScanThread.AddScanInfo( BackupJobScanInfo );
end;

constructor TMyBackupJobScanInfo.Create;
begin
  IsRun := True;
  BackupJobScanThread := TBackupJobScanThread.Create;
end;

procedure TMyBackupJobScanInfo.StopJobScan;
begin
  IsRun := False;
  BackupJobScanThread.Free;
end;


{ TTempBackupPathOwnerInfo }

constructor TTempBackupPathOwnerInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  OwnerSpace := 0;
  OwnerFileCount := 0;
end;

{ TBackupPathScanJobHandle }

constructor TBackupPathJobScanner.Create;
begin
  TempPcSpaceList := TTempPcSpaceList.Create;
end;

destructor TBackupPathJobScanner.Destroy;
begin
  TempPcSpaceList.Free;
  inherited;
end;

procedure TBackupPathJobScanner.FindTempPcSpaceList;
var
  FindTempPcSpace : TFindTempPcSpace;
begin
  TempPcSpaceList.Clear;

  FindTempPcSpace := TFindTempPcSpace.Create( TempPcSpaceList );
  FindTempPcSpace.Update;
  FindTempPcSpace.Free;
end;

procedure TBackupPathJobScanner.ResetPcSpaceList;
var
  ResetPcSpace : TResetPcSpace;
begin
  ResetPcSpace := TResetPcSpace.Create( TempPcSpaceList );
  ResetPcSpace.Update;
  ResetPcSpace.Free;
end;

procedure TBackupPathJobScanner.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TBackupPathJobScanner.Update;
begin
    // ���ܱ���, ·��Ϊ Disable �����
  if not MyBackupPathInfoUtil.ReadIsEnable( ScanPath ) then
    Exit;

    // ��ȡ ���� Pc ���ÿռ�
  FindTempPcSpaceList;

    // ��ȡ ����·�� Copy ��
  CopyCount := MyBackupPathInfoUtil.ReadPresetCopyCount( ScanPath );

    // ɨ�� �����ļ�
  BackupJobScan;

    // ���� ���� Pc ���ÿռ�
  ResetPcSpaceList;
end;

{ TResetPcSpace }

constructor TResetPcSpace.Create(_TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

procedure TResetPcSpace.Update;
var
  NetPcInfoHash : TNetPcInfoHash;
  i : Integer;
  PcID : string;
  OldAvalableSpace, PcAvailableSpace : Int64;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for i := 0 to TempPcSpaceList.Count - 1 do
  begin
    PcID := TempPcSpaceList[i].PcID;
    if NetPcInfoHash.ContainsKey( PcID ) then
    begin
      OldAvalableSpace := NetPcInfoHash[ PcID ].TotalSpace - NetPcInfoHash[ PcID ].UsedSpace;
      PcAvailableSpace := Min( OldAvalableSpace, TempPcSpaceList[i].AvailableSpace );
      NetPcInfoHash[ PcID ].UsedSpace := Max( NetPcInfoHash[ PcID ].TotalSpace - PcAvailableSpace, 0 );
    end;
  end;
  MyNetPcInfo.LeaveData;
end;

procedure TTempPcSpace.SetSpaceInfo(_AvailableSpace, _ComsumpSpace: Int64);
begin
  AvailableSpace := _AvailableSpace;
  ComsumpSpace := _ComsumpSpace;
end;

{ TBackupJobScanner }

procedure TBackupJobScanner.BackupJobAddHandle(PcID: string;
  FileInfo: TTempBackupFileInfo);
var
  FileSize: Int64;
  FileTime: TDateTime;
  FilePath : string;
  BackupJobAdd : TBackupJobAdd;
begin
  FilePath := getFilePath( FileInfo.FileName );
  FileSize := FileInfo.FileSize;
  FileTime := FileInfo.LastWriteTime;

    // ��� Job
  BackupJobAdd := TBackupJobAdd.Create( PcID, FilePath );
  BackupJobAdd.SetFileInfo( FileSize, FileTime );
  BackupJobAdd.Update;
  BackupJobAdd.Free;
end;

procedure TBackupJobScanner.CheckFileJob(FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  NeedBackupCount, i, j : Integer;
  TempPcSpace : TTempPcSpace;
  PcID : string;
  AddedHash : TStringHash;
  IsWriteNotEnough : Boolean;
begin
    // ��δ���ߵĸ�����������
  CheckOfflineJob( FileInfo );

  CopyHash := FileInfo.TempCopyHash;
  NeedBackupCount := CopyCount - CopyHash.Count;

    // ����Ҫ���ݸ��ļ�
  if NeedBackupCount <= 0 then
    Exit;

  IsWriteNotEnough := False;
  TempPcSpaceList.SortSpace;  // ����ʣ��ռ䣬��С����
  AddedHash := TStringHash.Create;   // �ѷ���� Pc �б�
  for i := 0 to NeedBackupCount - 1 do  // Ϊ��Ҫ���ݵ��ļ�����
    for j := 0 to TempPcSpaceList.Count - 1 do  // ���ռ����ȷ���
    begin
      TempPcSpace := TempPcSpaceList[j];
      PcID := TempPcSpace.PcID;

        // Pc �Ѿ�������
      if CopyHash.ContainsKey( PcID ) or AddedHash.ContainsKey( PcID ) then
        Continue;

        // �ռ䲻�� ���� ����
      if TempPcSpace.AvailableSpace < FileInfo.FileSize then
        Continue;

        // ����
      AddedHash.AddString( PcID );
      TempPcSpace.AvailableSpace := TempPcSpace.AvailableSpace - FileInfo.FileSize; // �ռ����
      TempPcSpace.ComsumpSpace := TempPcSpace.ComsumpSpace + FileInfo.FileSize; // ռ�ÿռ�����
      BackupJobAddHandle( PcID, FileInfo ); // ���ýӿ�
      Break;
    end;

    // Pc ����
  IsNotEnoughPc := IsNotEnoughPc or IsWriteNotEnough or
                  ( AddedHash.Count < NeedBackupCount );
  AddedHash.Free;
end;

procedure TBackupJobScanner.CheckOfflineJob(FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  p : TTempCopyPair;
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  CopyHash := FileInfo.TempCopyHash;
  for p in CopyHash do
  begin
    if p.Value.Status <> CopyStatus_Offline then
      Continue;
    if not MyNetPcInfoReadUtil.ReadIsOnline( p.Value.CopyOwner ) then
      Continue;

      // ��δ������ Job ����
    TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
    TransferJobOnlineInfo.SetOnlinePcID( p.Value.CopyOwner );
    TransferJobOnlineInfo.SetJobType( JobType_Backup );
    MyJobInfo.AddChange( TransferJobOnlineInfo );
  end;
end;

function TBackupJobScanner.getFilePath(FileName: string): string;
begin
  Result := MyFilePath.getPath( ScanPath ) + FileName;
end;

procedure TBackupJobScanner.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupJobScanner.SetScanPath(_ScanPath: string);
begin
  ScanPath := _ScanPath;
end;

procedure TBackupJobScanner.SetTempPcSpaceList(
  _TempPcSpaceList: TTempPcSpaceList);
begin
  TempPcSpaceList := _TempPcSpaceList;
end;

{ TBackupFileJobScanner }

function TBackupFileJobScanner.getFilePath(FileName: string): string;
begin
  Result := ScanPath;
end;

procedure TBackupFileJobScanner.Update;
var
  TempBackupFileInfo : TTempBackupFileInfo;
begin
    // �� �����ļ� ������Ϣ
  TempBackupFileInfo := MyBackupFileInfoUtil.ReadTempBackupFileInfo( ScanPath );

    // �ļ�������
  if TempBackupFileInfo = nil then
    Exit;

    // ����ļ��� Job
  CheckFileJob( TempBackupFileInfo );

  TempBackupFileInfo.Free;
end;

{ TBackupJobScanInfo }

constructor TBackupJobScanInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TRootPathJobScanner }

procedure TRootPathJobScanner.AddBackupBoard;
var
  BackupItemStatusAddInfo : TBackupItemStatusAddInfo;
begin
  BackupItemStatusAddInfo := TBackupItemStatusAddInfo.Create( BackupItemStatusType_Analysing );
  BackupItemStatusAddInfo.SetFullPath( ScanPath );
  MyBackupBoardInfo.AddChange( BackupItemStatusAddInfo );
end;

procedure TRootPathJobScanner.BackupJobScan;
var
  BackupRootJobScanner : TBackupRootJobScanner;
begin
    // ���� Job
  if FileExists( ScanPath ) then
    BackupRootJobScanner := TBackupRootFileJobScanner.Create
  else
    BackupRootJobScanner := TBackupRootFolderJobScanner.Create;
  BackupRootJobScanner.SetScanPath( ScanPath );
  BackupRootJobScanner.SetCopyCount( CopyCount );
  BackupRootJobScanner.SetTempPcSpaceList( TempPcSpaceList );
  BackupRootJobScanner.SetBackupPathOwnerHash( BackupPathOwnerHash );
  BackupRootJobScanner.Update;
  IsNotEnouthPc := BackupRootJobScanner.IsNotEnoughPc;
  CompletedSpace := BackupRootJobScanner.CompletedSpace;
  BackupRootJobScanner.Free;
end;

constructor TRootPathJobScanner.Create;
begin
  inherited;
  BackupPathOwnerHash := TTempBackupPathOwnerHash.Create;
  IsNotEnouthPc := False;
end;

destructor TRootPathJobScanner.Destroy;
begin
  BackupPathOwnerHash.Free;
  inherited;
end;

procedure TRootPathJobScanner.BackupSelectRefresh;
var
  BackupSelectRefreshHandle : TBackupSelectRefreshHandle;
begin
  BackupSelectRefreshHandle := TBackupSelectRefreshHandle.Create( ScanPath );
  BackupSelectRefreshHandle.Update;
  BackupSelectRefreshHandle.Free;
end;

procedure TRootPathJobScanner.RemoveBackupBoard;
var
  BackupItemStatusRemoveInfo : TBackupItemStatusRemoveInfo;
begin
  BackupItemStatusRemoveInfo := TBackupItemStatusRemoveInfo.Create( BackupItemStatusType_Analysing );
  MyBackupBoardInfo.AddChange( BackupItemStatusRemoveInfo );
end;

procedure TRootPathJobScanner.ResetBackupPathOwner;
var
  BackupPathOwnerClearHandle : TBackupPathOwnerClearHandle;
  p : TTempBackupPathOwnerPair;
  BackupPathOwnerSetSpaceHandle : TBackupPathOwnerSetSpaceHandle;
begin
    // ��� ·��ӵ���� ��Ϣ
  BackupPathOwnerClearHandle := TBackupPathOwnerClearHandle.Create( ScanPath );
  BackupPathOwnerClearHandle.Update;
  BackupPathOwnerClearHandle.Free;

    // �������� ·��ӵ���� ��Ϣ
  for p in BackupPathOwnerHash do
  begin
    BackupPathOwnerSetSpaceHandle := TBackupPathOwnerSetSpaceHandle.Create( ScanPath );
    BackupPathOwnerSetSpaceHandle.SetPcID( p.Value.PcID );
    BackupPathOwnerSetSpaceHandle.SetSpaceInfo( p.Value.OwnerSpace, p.Value.OwnerFileCount );
    BackupPathOwnerSetSpaceHandle.Update;
    BackupPathOwnerSetSpaceHandle.Free;
  end;
end;

procedure TRootPathJobScanner.ResetCompletedSpace;
var
  BackupPathSetCompletedSpaceHandle : TBackupPathSetCompletedSpaceHandle;
begin
  BackupPathSetCompletedSpaceHandle := TBackupPathSetCompletedSpaceHandle.Create( ScanPath );
  BackupPathSetCompletedSpaceHandle.SetCompletedSpace( CompletedSpace );
  BackupPathSetCompletedSpaceHandle.Update;
  BackupPathSetCompletedSpaceHandle.Free;
end;

procedure TRootPathJobScanner.ResetNotEnoughPcBackup;
var
  BackupPathSetIsNotEnoughPcHandle : TBackupPathSetIsNotEnoughPcHandle;
begin
  BackupPathSetIsNotEnoughPcHandle := TBackupPathSetIsNotEnoughPcHandle.Create( ScanPath );
  BackupPathSetIsNotEnoughPcHandle.SetIsNotEnoughPc( IsNotEnouthPc );
  BackupPathSetIsNotEnoughPcHandle.Update;
  BackupPathSetIsNotEnoughPcHandle.Free;
end;

procedure TRootPathJobScanner.Update;
begin
    // ��ʾ ���ڷ��� Job
  AddBackupBoard;

  inherited;

    // ���� ·��ӵ����
  ResetBackupPathOwner;

    // �Ƿ� �������� ����
  ResetNotEnoughPcBackup;

    // ���� ·�������Ϣ
  ResetCompletedSpace;

    // ˢ�� ѡ��Ľڵ�
  BackupSelectRefresh;

    // ���� ��ʾ ���� Job
  RemoveBackupBoard;
end;

{ TBackupRootFolderJobScanner }

procedure TBackupRootJobScanner.AddBackupBoardFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Analysing );
  BackupItemStatusFileCountInfo.SetFileCount( TotalFileCount );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

procedure TBackupRootJobScanner.CheckBackupPathOwner(
  FileInfo: TTempBackupFileInfo);
var
  CopyHash : TTempCopyHash;
  pc : TTempCopyPair;
  PcID : string;
  FileSize : Int64;
  FileCopy : Integer;
begin
  FileCopy := 0;
  FileSize := FileInfo.FileSize;
  CopyHash := FileInfo.TempCopyHash;
  for pc in CopyHash do
  begin
      // ��������
    if pc.Value.Status <> CopyStatus_Loaded then
      Continue;

      // ͳ��Ŀ¼��ɿռ�
    Inc( FileCopy );
    if FileCopy <= CopyCount then
      CompletedSpace := CompletedSpace + FileSize;

      // ���� Pc �ı��ݿռ�
    PcID := pc.Value.CopyOwner;
    if not BackupPathOwnerHash.ContainsKey( PcID ) then
      BackupPathOwnerHash.AddOrSetValue( PcID, TTempBackupPathOwnerInfo.Create( PcID ) );
    BackupPathOwnerHash[ PcID ].OwnerSpace := BackupPathOwnerHash[ PcID ].OwnerSpace + FileSize;
    BackupPathOwnerHash[ PcID ].OwnerFileCount := BackupPathOwnerHash[ PcID ].OwnerFileCount + 1;
  end;
end;

procedure TBackupRootJobScanner.CheckFileJob(
  FileInfo: TTempBackupFileInfo);
begin
  CheckLoadedJob( FileInfo );

  inherited;

  CheckBackupPathOwner( FileInfo );
end;

procedure TBackupRootJobScanner.CheckLoadedJob(
  FileInfo: TTempBackupFileInfo);
var
  FilePath : string;
  CopyHash : TTempCopyHash;
  p : TTempCopyPair;
  ConfirmFileInfo : TConfirmFileInfo;
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  FilePath := getFilePath( FileInfo.FileName );

  CopyHash := FileInfo.TempCopyHash;
  for p in CopyHash do
  begin
    if p.Value.Status <> CopyStatus_Loaded then
      Continue;
    if not MyNetPcInfoReadUtil.ReadIsOnline( p.Value.CopyOwner ) then
      Continue;

    ConfirmFileInfo := TConfirmFileInfo.Create;
    ConfirmFileInfo.SetFileBaseInfo( FileInfo );
    ConfirmFileInfo.SetFileName( FilePath );
    MyFileConfirm.AddBackupFileConfirm( p.Value.CopyOwner, ConfirmFileInfo );
  end;
end;

function TBackupRootJobScanner.CheckNextSearch: Boolean;
begin
  AddBackupBoardFileCount;

  Result := inherited;
end;

constructor TBackupRootJobScanner.Create;
begin
  inherited;
  IsNotEnoughPc := False;
  CompletedSpace := 0;
end;

function TBackupRootJobScanner.getFolderJobScan: TBackupFolderJobScanner;
var
  BackupRootFolderJobScanner : TBackupRootJobScanner;
begin
  BackupRootFolderJobScanner := TBackupRootJobScanner.Create;
  BackupRootFolderJobScanner.SetBackupPathOwnerHash( BackupPathOwnerHash );
  Result := BackupRootFolderJobScanner;
end;

procedure TBackupRootJobScanner.ReadLastCompletedSpace;
begin
  LastCompletedSpace := MyBackupFolderInfoUtil.ReadCompletedSpace( ScanPath );
end;

procedure TBackupRootJobScanner.ResetAnalyzingStatus;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Analyzing );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TBackupRootJobScanner.ResetFolderJobScan(
  FolderJobScan: TBackupFolderJobScanner);
var
  BackupRootFolderJobScanner : TBackupRootJobScanner;
begin
  BackupRootFolderJobScanner := FolderJobScan as TBackupRootJobScanner;
  CompletedSpace := CompletedSpace + BackupRootFolderJobScanner.CompletedSpace;
end;

procedure TBackupRootJobScanner.ResetStopStatus;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( ScanPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TBackupRootJobScanner.SetBackupPathOwnerHash(
  _BackupPathOwnerHash: TTempBackupPathOwnerHash);
begin
  BackupPathOwnerHash := _BackupPathOwnerHash;
end;

procedure TBackupRootJobScanner.SetCompletedSpace;
var
  BackupFolderSetCompletedSpaceHanlde : TBackupFolderSetCompletedSpaceHanlde;
begin
  BackupFolderSetCompletedSpaceHanlde := TBackupFolderSetCompletedSpaceHanlde.Create( ScanPath );
  BackupFolderSetCompletedSpaceHanlde.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceHanlde.SetCompletedSpace( CompletedSpace );
  BackupFolderSetCompletedSpaceHanlde.Update;
  BackupFolderSetCompletedSpaceHanlde.Free;
end;

procedure TBackupRootJobScanner.Update;
begin
    // ��ʾ Ŀ¼���� Analyzing
  ResetAnalyzingStatus;

    // ��ȡ ��һ�� ����ɿռ� ��Ϣ
  ReadLastCompletedSpace;

  inherited;

    // ���� ����ɿռ� ��Ϣ
  SetCompletedSpace;

    // ���� ��ʾ
  ResetStopStatus;
end;

{ TBackupChildFolderJobFolderScanner }

function TBackupChildFolderJobFolderScanner.getFolderJobScan: TBackupFolderJobScanner;
begin
  Result := TBackupChildFolderJobFolderScanner.Create;
end;

{ TChildPathJobScanner }

procedure TChildPathJobScanner.BackupJobScan;
var
  BackupJobScanner : TBackupJobScanner;
begin
  if FileExists( ScanPath ) then
    BackupJobScanner := TBackupFileJobScanner.Create
  else
    BackupJobScanner := TBackupChildFolderJobFolderScanner.Create;
  BackupJobScanner.SetScanPath( ScanPath );
  BackupJobScanner.SetCopyCount( CopyCount );
  BackupJobScanner.SetTempPcSpaceList( TempPcSpaceList );
  BackupJobScanner.Update;
  BackupJobScanner.Free;
end;

{ TBackupJobScanHandle }

constructor TBackupJobScanHandle.Create(_BackupJobScanInfo: TBackupJobScanInfo);
begin
  BackupJobScanInfo := _BackupJobScanInfo;
  ScanPath := BackupJobScanInfo.FullPath;
end;

procedure TBackupJobScanHandle.Update;
var
  BackupPathJobScanner : TBackupPathJobScanner;
begin
    // �ļ�ȷ��
  if ScanPath = BackupFileScanType_FileConfirm then
  begin
    MyFileConfirm.StartConfirm;
    Exit;
  end;

    // ɨ��·��������
    // ��·�� ���� �Ǹ�·��
  if MyBackupPathInfoUtil.ReadIsRootPath( ScanPath ) then
    BackupPathJobScanner := TRootPathJobScanner.Create
  else
    BackupPathJobScanner := TChildPathJobScanner.Create;
  BackupPathJobScanner.SetScanPath( ScanPath );
  BackupPathJobScanner.Update;
  BackupPathJobScanner.Free;
end;

{ TBackupRootFileJobScanner }

function TBackupRootFileJobScanner.getFilePath(FileName: string): string;
begin
  Result := ScanPath;
end;

end.

