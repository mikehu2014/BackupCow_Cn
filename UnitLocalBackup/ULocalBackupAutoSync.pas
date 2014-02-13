unit ULocalBackupAutoSync;

interface

uses classes, SysUtils, DateUtils;

type

    // �ȴ��߳�
  TLocalAutoSyncThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure CheckAutoSync;
  end;

    // ���ر��� �Զ�ͬ����
  TMyLocalAutoSyncHandler = class
  public
    LocalAutoSyncThread : TLocalAutoSyncThread;
  public
    constructor Create;
    procedure StopThread;
  end;

var
  MyLocalAutoSyncHandler : TMyLocalAutoSyncHandler;

implementation

uses ULocalBackupInfo, ULocalBackupControl;

{ TLocalAutoSyncThread }

constructor TLocalAutoSyncThread.Create;
begin
  inherited Create( True );
end;

destructor TLocalAutoSyncThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TLocalAutoSyncThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while not Terminated and ( MinutesBetween( Now, StartTime ) < 1 ) do
      Sleep(100);
    if Terminated then
      Break;
    CheckAutoSync;
  end;
  inherited;
end;

procedure TLocalAutoSyncThread.CheckAutoSync;
var
  SyncPathList : TStringList;
  i : Integer;
  LocalBackupSourceRefreshNextSyncTimeHandle : TLocalBackupSourceRefreshNextSyncTimeHandle;
begin
    // ͬ���Զ�ͬ�����ļ�
  SyncPathList := MyLocalBackupSourceReadUtil.getAutoSyncPathList;
  for i := 0 to SyncPathList.Count - 1 do
    MyLocalBackupSourceControl.SyncTimeBackup( SyncPathList[i] );
  SyncPathList.Free;

    // ˢ����һ��ͬ��ʱ��
  LocalBackupSourceRefreshNextSyncTimeHandle := TLocalBackupSourceRefreshNextSyncTimeHandle.Create;
  LocalBackupSourceRefreshNextSyncTimeHandle.Update;
  LocalBackupSourceRefreshNextSyncTimeHandle.Free
end;

{ TMyLocalAutoSyncHandler }

constructor TMyLocalAutoSyncHandler.Create;
begin
  LocalAutoSyncThread := TLocalAutoSyncThread.Create;
  LocalAutoSyncThread.Resume;
end;

procedure TMyLocalAutoSyncHandler.StopThread;
begin
  LocalAutoSyncThread.Free;
end;

end.
