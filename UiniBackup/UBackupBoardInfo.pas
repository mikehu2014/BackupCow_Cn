unit UBackupBoardInfo;

interface

uses UModelUtil, Generics.Collections, UChangeInfo, Classes, SysUtils;

type

{$Region ' ���ݽṹ ' }

      // ����·�� ������Ϣ
  TBackupItemStatusInfo = class
  public
    StatusType : string;
    FullPath : string;
    FileCount : Integer;
  public
    constructor Create( _StatusType : string );
    procedure SetFullPath( _FullPath : string );
    procedure SetFileCount( _FileCount : Integer );
  end;
  TBackupItemStatusPair = TPair< string , TBackupItemStatusInfo >;
  TBackupItemStatusHash = class(TStringDictionary< TBackupItemStatusInfo >);

{$EndRegion}

{$Region ' �����޸� ' }

  {$Region ' Backup Item �޸� ' }

    // �޸� ����
  TBackupItemStatusChangeInfo = class( TChangeInfo )
  public
    StatusType : string;
  public
    BackupItemStatusHash : TBackupItemStatusHash;
  public
    constructor Create( _StatusType : string );
    procedure Update;override;
  private
    procedure ShowBackupBoard;
  end;

    // ���
  TBackupItemStatusAddInfo = class( TBackupItemStatusChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
    procedure Update;override;
  end;

    // �޸� �ļ���
  TBackupItemStatusFileCountInfo = class( TBackupItemStatusChangeInfo )
  public
    FileCount : Integer;
  public
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  end;

    // �Ƴ�
  TBackupItemStatusRemoveInfo = class( TBackupItemStatusChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Cloud Item ' }

      // �޸� ����
  TCloudItemStatusChangeInfo = class( TChangeInfo )
  public
    StatusType : string;
  public
    CloudItemStatusHash : TBackupItemStatusHash;
  public
    constructor Create( _StatusType : string );
    procedure Update;override;
  private
    procedure ShowBackupBoard;
  end;

    // ���
  TCloudItemStatusAddInfo = class( TCloudItemStatusChangeInfo )
  public
    FullPath : string;
  public
    procedure SetFullPath( _FullPath : string );
    procedure Update;override;
  end;

    // �޸� �ļ���
  TCloudItemStatusFileCountInfo = class( TCloudItemStatusChangeInfo )
  public
    FileCount : Integer;
  public
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  end;

    // �Ƴ�
  TCloudItemStatusRemoveInfo = class( TCloudItemStatusChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // δע��
  TBackupCowUnRegisterInfo = class( TChangeInfo )
  public
    IsUnRegister : Boolean;
  public
    constructor Create( _IsUnRegister : Boolean );
    procedure Update;override;
  end;

    // Pc ����
  TBackupCowNotEnoughInfo = class( TChangeInfo )
  public
    IsNotEnough : Boolean;
  public
    constructor Create( _IsNotEnough : Boolean );
    procedure Update;override;
  end;

{$EndRegion}

    // ��ʱ ��ʾ ������߳�
  TBackupBoardShowThread = class( TThread )
  public
    IsChange : Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure ShowBackupBoardStr;
  private
    function getIsUnRegisterStr : string;
    function getNotEnoughtPcStr : string;
    function getBackupItemStr : string;
  end;

    // ���ݶ���
  TMyBackupBoardInfo = class( TMyDataChange )
  public
    BackupItemStatusHash : TBackupItemStatusHash;
    CloudItemStatusHash : TBackupItemStatusHash;
    IsUnRegister, IsNotEnoughPc : Boolean;
  public
    BackupBoardShowThread : TBackupBoardShowThread;
  public
    constructor Create;
    procedure StopBackupBoardShow;
    destructor Destroy; override;
  public
    procedure ShowBackupBoard;
  end;

const
  BackupItemStatusType_Loading = 'Loading';
  BackupItemStatusType_Refreshing = 'Refreshing';
  BackupItemStatusType_Analysing = 'Analyzing';

  CloudItemStatus_Loading = 'Loading';

  BackupBoard_UnRegister : string = 'Your Backup Cow has expired already.';
  BackupBoard_NotEnoughtPc = 'No enough computers or storage space to backup all ' +
                                      'your files and folders. Please check the Cloud Status.';
var
  MyBackupBoardInfo : TMyBackupBoardInfo;

implementation

uses UBackupInfoFace, UMainForm;

{ TBackupItemStatusInfo }

constructor TBackupItemStatusInfo.Create(_StatusType: string);
begin
  StatusType := _StatusType;
end;

procedure TBackupItemStatusInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TBackupItemStatusInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TMyBackupBoardInfo }

constructor TMyBackupBoardInfo.Create;
begin
  inherited;
  BackupBoardShowThread := TBackupBoardShowThread.Create;
  BackupItemStatusHash := TBackupItemStatusHash.Create;
  CloudItemStatusHash := TBackupItemStatusHash.Create;
  IsUnRegister := False;
  AddThread(1);
end;

destructor TMyBackupBoardInfo.Destroy;
begin
  StopThread;
  CloudItemStatusHash.Free;
  BackupItemStatusHash.Free;
  inherited;
end;

procedure TMyBackupBoardInfo.ShowBackupBoard;
begin
  BackupBoardShowThread.IsChange := True;
  BackupBoardShowThread.Resume;
end;

procedure TMyBackupBoardInfo.StopBackupBoardShow;
begin
  BackupBoardShowThread.Free;
end;

{ TBackupItemStatusAddInfo }

procedure TBackupItemStatusAddInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupItemStatusAddInfo.Update;
var
  BackupItemStatsInfo : TBackupItemStatusInfo;
begin
  inherited;

  BackupItemStatsInfo := TBackupItemStatusInfo.Create( StatusType );
  BackupItemStatsInfo.SetFullPath( FullPath );
  BackupItemStatsInfo.SetFileCount( 0 );
  BackupItemStatusHash.AddOrSetValue( StatusType, BackupItemStatsInfo );

    // ��ʾ����
  ShowBackupBoard;
end;

{ TBackupItemStatusRemoveInfo }

procedure TBackupItemStatusRemoveInfo.Update;
begin
  inherited;

  BackupItemStatusHash.Remove( StatusType );

    // ��ʾ����
  ShowBackupBoard;
end;

{ TBackupItemStatusChangeInfo }

constructor TBackupItemStatusChangeInfo.Create(_StatusType: string);
begin
  StatusType := _StatusType;
end;

procedure TBackupItemStatusChangeInfo.ShowBackupBoard;
begin
  MyBackupBoardInfo.ShowBackupBoard;
end;

procedure TBackupItemStatusChangeInfo.Update;
begin
  BackupItemStatusHash := MyBackupBoardInfo.BackupItemStatusHash;
end;

{ TBackupItemStatusFileCountInfo }

procedure TBackupItemStatusFileCountInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TBackupItemStatusFileCountInfo.Update;
begin
  inherited;

  if BackupItemStatusHash.ContainsKey( StatusType ) then
    BackupItemStatusHash[ StatusType ].SetFileCount( FileCount );

    // ��ʾ����
  ShowBackupBoard;
end;

{ TBackupBoardShowThread }

constructor TBackupBoardShowThread.Create;
begin
  inherited Create( True );
  IsChange := False;
end;

destructor TBackupBoardShowThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TBackupBoardShowThread.Execute;
begin
  while not Terminated do
  begin
    if not IsChange then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

    IsChange := False;
    ShowBackupBoardStr;

    Sleep(100);
  end;

  inherited;
end;

function TBackupBoardShowThread.getBackupItemStr : string;
var
  BackupItemStatusHash : TBackupItemStatusHash;
  CloudItemStatusHash : TBackupItemStatusHash;
  p : TBackupItemStatusPair;
  ShowStr, TempStr : string;
  PlBackupBoardShow : TPlBackupBoardShow;
begin
    // ��ȡ BackupItem ��Ϣ
  ShowStr := '';
  MyBackupBoardInfo.EnterData;
  BackupItemStatusHash := MyBackupBoardInfo.BackupItemStatusHash;
  CloudItemStatusHash := MyBackupBoardInfo.CloudItemStatusHash;
  for p in BackupItemStatusHash do
  begin
    if ShowStr <> '' then
      ShowStr := ShowStr + '        ';
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'StrBackupItem' );
    ShowStr := ShowStr + TempStr + p.Value.FullPath;
    ShowStr := ShowStr + ' ' + frmMainForm.siLang_frmMainForm.GetText( p.Value.StatusType );
    if p.Value.FileCount > 0 then
      ShowStr := ShowStr + ' ' + IntToStr( p.Value.FileCount ) + frmMainForm.siLang_frmMainForm.GetText( 'StrFiles' );
  end;
  for p in CloudItemStatusHash do
  begin
    if ShowStr <> '' then
      ShowStr := ShowStr + '        ';
    TempStr := frmMainForm.siLang_frmMainForm.GetText( 'StrCloudIni' );
    ShowStr := ShowStr + TempStr;
    if p.Value.FileCount > 0 then
      ShowStr := ShowStr + IntToStr( p.Value.FileCount ) + frmMainForm.siLang_frmMainForm.GetText( 'StrFiles' );
  end;
  MyBackupBoardInfo.LeaveData;

  Result := ShowStr;
end;

function TBackupBoardShowThread.getIsUnRegisterStr: string;
begin
  if MyBackupBoardInfo.IsUnRegister then
    Result := BackupBoard_UnRegister + '        '
  else
    Result := '';
end;

function TBackupBoardShowThread.getNotEnoughtPcStr: string;
begin
  if MyBackupBoardInfo.IsNotEnoughPc then
    Result := frmMainForm.siLang_frmMainForm.GetText( 'NotEnouthPc' )
  else
    Result := '';
end;

procedure TBackupBoardShowThread.ShowBackupBoardStr;
var
  ShowStr, BackupItemStr, NotEnoughStr : string;
  IsShowNotEnough : Boolean;
  PlBackupBoardShow : TPlBackupBoardShow;
  PlBackupBoardIconShow : TPlBackupBoardIconShow;
begin
  NotEnoughStr := getNotEnoughtPcStr;
  IsShowNotEnough := NotEnoughStr <> '';

  ShowStr := getIsUnRegisterStr;
  ShowStr := ShowStr + NotEnoughStr;
  BackupItemStr := getBackupItemStr;
  if ( ShowStr <> '' ) and ( BackupItemStr <> '' ) then
    ShowStr := ShowStr + #13#10 + '  ';
  ShowStr := ShowStr + BackupItemStr;
  if ShowStr <> '' then
    ShowStr := '  ' + ShowStr;

    // ���½���
  PlBackupBoardShow := TPlBackupBoardShow.Create( ShowStr );
  MyBackupFileFace.AddChange( PlBackupBoardShow );

    // ��ʾ Warnning ͼ��
  PlBackupBoardIconShow := TPlBackupBoardIconShow.Create( IsShowNotEnough );
  MyBackupFileFace.AddChange( PlBackupBoardIconShow );
end;

{ TBackupCowUnRegisterInfo }

constructor TBackupCowUnRegisterInfo.Create(_IsUnRegister: Boolean);
begin
  IsUnRegister := _IsUnRegister;
end;

procedure TBackupCowUnRegisterInfo.Update;
begin
  MyBackupBoardInfo.IsUnRegister := IsUnRegister;
  MyBackupBoardInfo.ShowBackupBoard;
end;

{ TBackupCowNotEnoughInfo }

constructor TBackupCowNotEnoughInfo.Create(_IsNotEnough: Boolean);
begin
  IsNotEnough := _IsNotEnough;
end;

procedure TBackupCowNotEnoughInfo.Update;
begin
  MyBackupBoardInfo.IsNotEnoughPc := IsNotEnough;
  MyBackupBoardInfo.ShowBackupBoard;
end;

{ TCloudItemStatusChangeInfo }

constructor TCloudItemStatusChangeInfo.Create(_StatusType: string);
begin
  StatusType := _StatusType;
end;

procedure TCloudItemStatusChangeInfo.ShowBackupBoard;
begin
  MyBackupBoardInfo.ShowBackupBoard;
end;

procedure TCloudItemStatusChangeInfo.Update;
begin
  CloudItemStatusHash := MyBackupBoardInfo.CloudItemStatusHash;
end;

{ TCloudItemStatusAddInfo }

procedure TCloudItemStatusAddInfo.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TCloudItemStatusAddInfo.Update;
var
  CloudItemStatsInfo : TBackupItemStatusInfo;
begin
  inherited;

  CloudItemStatsInfo := TBackupItemStatusInfo.Create( StatusType );
  CloudItemStatsInfo.SetFullPath( FullPath );
  CloudItemStatsInfo.SetFileCount( 0 );
  CloudItemStatusHash.AddOrSetValue( StatusType, CloudItemStatsInfo );

    // ��ʾ����
  ShowBackupBoard;
end;


{ TCloudItemStatusFileCountInfo }

procedure TCloudItemStatusFileCountInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TCloudItemStatusFileCountInfo.Update;
begin
  inherited;

  if CloudItemStatusHash.ContainsKey( StatusType ) then
    CloudItemStatusHash[ StatusType ].SetFileCount( FileCount );

    // ��ʾ����
  ShowBackupBoard;
end;

{ TCloudItemStatusRemoveInfo }

procedure TCloudItemStatusRemoveInfo.Update;
begin
  inherited;

  CloudItemStatusHash.Remove( StatusType );

    // ��ʾ����
  ShowBackupBoard;
end;

end.
