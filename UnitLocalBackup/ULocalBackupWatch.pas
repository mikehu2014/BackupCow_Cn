unit ULocalBackupWatch;

interface

uses UChangeInfo, UFileWatcher, SysUtils, UMyUtil, Classes, SyncObjs, DateUtils;

type

{$Region ' ����·�� ������ ' }

    // ·���Ƿ���� ����
  TLocalBackupSourceExistThread = class( TWatchPathExistThread )
  protected
    procedure WatchPathNotEixst( WatchPath : string );override;
    procedure WatchPathExist( WatchPath : string );override;
  end;

    // ���ر����ļ� �仯�����
  TMyLocalBackupSourceWatcher = class
  public
    LocalBackupSourceExistThread : TLocalBackupSourceExistThread;
  public
    constructor Create;
    procedure StopWatch;
    destructor Destroy; override;
  public
    procedure AddWatchExistPath( FullPath : string; IsExist : Boolean );
    procedure RemoveWatchExistPath( FullPath : string );
  end;

{$EndRegion}

{$Region ' Ŀ��·�� ������ ' }

    // �����߳�
  TLocalBackupDesPathWatchThread = class( TThread )
  private
    PathLock : TCriticalSection;
    ExistPathList : TStringList;
    NotExistPathList : TStringList;
    UnModifyPathList : TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure CheckPathExist;
    procedure CheckPathNotExist;
    procedure CheckPathUnmodify;
  private
    procedure DesExistChange( Path : string; IsExist : Boolean );
    procedure DesCanModify( Path : string );
  end;

  {$Region ' ���� �޸� ' }

    // ����
  TLocalBackupDesPathWatcherChange = class( TChangeInfo )
  public
    Path : string;
  public
    PathLock : TCriticalSection;
    ExistPathList : TStringList;
    NotExistPathList : TStringList;
    UnModifyPathList : TStringList;
  public
    constructor Create( _Path : string );
    procedure Update;override;
  end;

    // ��� ����
  TLocalBackupDesPathWatcherAddExist = class( TLocalBackupDesPathWatcherChange )
  public
    procedure Update;override;
  end;

    // ��� ������
  TLocalBackupDesPathWatcherAddNotExist = class( TLocalBackupDesPathWatcherChange )
  public
    procedure Update;override;
  end;

    // ��� �����޸�
  TLocalBackupDesPathWatcherAddUnmodify = class( TLocalBackupDesPathWatcherChange )
  public
    procedure Update;override;
  end;

    // ɾ��
  TLocalBackupDesPathWatcherRemove = class( TLocalBackupDesPathWatcherChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // ��������
  TMyLocalBackupDesWatcher = class( TMyChangeInfo )
  public
    LocalBackupDesPathWatchThread : TLocalBackupDesPathWatchThread;
  public
    constructor Create;
    procedure StopWatch;
  end;

{$EndRegion}

var
    // Դ·��
  MyLocalBackupSourceWatcher : TMyLocalBackupSourceWatcher;

    // Ŀ��·��
  MyLocalBackupDesWatcher : TMyLocalBackupDesWatcher;

implementation

uses ULocalBackupControl, ULocalBackupInfo, UMyBackupInfo, USettingInfo;

{ TMyLocalBackupFileWatcher }

procedure TMyLocalBackupSourceWatcher.AddWatchExistPath(FullPath: string;
  IsExist : Boolean);
begin
  LocalBackupSourceExistThread.AddWatchPath( FullPath, IsExist );
end;

constructor TMyLocalBackupSourceWatcher.Create;
begin
  LocalBackupSourceExistThread := TLocalBackupSourceExistThread.Create;
  LocalBackupSourceExistThread.Resume;
end;

destructor TMyLocalBackupSourceWatcher.Destroy;
begin

  inherited;
end;

procedure TMyLocalBackupSourceWatcher.RemoveWatchExistPath(FullPath: string);
begin
  LocalBackupSourceExistThread.RemoveWatchPath( FullPath );
end;

procedure TMyLocalBackupSourceWatcher.StopWatch;
begin
    // ֹͣ ����
  LocalBackupSourceExistThread.Free;
end;

{ TLocalBackupSourceExistThread }

procedure TLocalBackupSourceExistThread.WatchPathExist(WatchPath: string);
var
  LocalBackupSourceSetExistHandle : TLocalBackupSourceSetExistHandle;
begin
  LocalBackupSourceSetExistHandle := TLocalBackupSourceSetExistHandle.Create( WatchPath );
  LocalBackupSourceSetExistHandle.SetIsExist( True );
  LocalBackupSourceSetExistHandle.Update;
  LocalBackupSourceSetExistHandle.Free;
end;

procedure TLocalBackupSourceExistThread.WatchPathNotEixst(WatchPath: string);
var
  LocalBackupSourceSetExistHandle : TLocalBackupSourceSetExistHandle;
begin
  LocalBackupSourceSetExistHandle := TLocalBackupSourceSetExistHandle.Create( WatchPath );
  LocalBackupSourceSetExistHandle.SetIsExist( False );
  LocalBackupSourceSetExistHandle.Update;
  LocalBackupSourceSetExistHandle.Free;
end;

{ TLocalBackupDesPathWatcherChange }

constructor TLocalBackupDesPathWatcherChange.Create(_Path: string);
begin
  Path := _Path;
end;

procedure TLocalBackupDesPathWatcherChange.Update;
begin
  PathLock := MyLocalBackupDesWatcher.LocalBackupDesPathWatchThread.PathLock;
  ExistPathList := MyLocalBackupDesWatcher.LocalBackupDesPathWatchThread.ExistPathList;
  NotExistPathList := MyLocalBackupDesWatcher.LocalBackupDesPathWatchThread.NotExistPathList;
  UnModifyPathList := MyLocalBackupDesWatcher.LocalBackupDesPathWatchThread.UnModifyPathList;
end;

{ TLocalBackupDesPathWatcherAddExist }

procedure TLocalBackupDesPathWatcherAddExist.Update;
begin
  inherited;

  PathLock.Enter;
  if ExistPathList.IndexOf( Path ) < 0 then
    ExistPathList.Add( Path );
  PathLock.Leave;
end;

{ TLocalBackupDesPathWatcherAddNotExist }

procedure TLocalBackupDesPathWatcherAddNotExist.Update;
begin
  inherited;

  PathLock.Enter;
  if NotExistPathList.IndexOf( Path ) < 0 then
    NotExistPathList.Add( Path );
  PathLock.Leave;
end;

{ TLocalBackupDesPathWatcherAddUnmodify }

procedure TLocalBackupDesPathWatcherAddUnmodify.Update;
begin
  inherited;

  PathLock.Enter;
  if UnModifyPathList.IndexOf( Path ) < 0 then
    UnModifyPathList.Add( Path );
  PathLock.Leave;
end;


{ TDesWritableThread }

procedure TLocalBackupDesPathWatchThread.DesExistChange(Path: string; IsExist: Boolean);
var
  LocalBackupDesExistHandle : TLocalBackupDesExistHandle;
begin
  LocalBackupDesExistHandle := TLocalBackupDesExistHandle.Create( Path );
  LocalBackupDesExistHandle.SetIsExist( IsExist );
  LocalBackupDesExistHandle.Update;
  LocalBackupDesExistHandle.Free;
end;

procedure TLocalBackupDesPathWatchThread.CheckPathExist;
var
  i : Integer;
  Path : string;
begin
  PathLock.Enter;
  for i := ExistPathList.Count - 1 downto 0 do
  begin
    Path := ExistPathList[i];

      // û�б仯 ����
    if MyDesPathUtil.getIsExist( Path ) then
      Continue;

      // ·���仯
    ExistPathList.Delete(i);
    NotExistPathList.Add( Path );

      // �����ⲿ�仯
    DesExistChange( Path, False );
  end;
  PathLock.Leave;
end;

procedure TLocalBackupDesPathWatchThread.CheckPathNotExist;
var
  i : Integer;
  Path : string;
begin
  PathLock.Enter;
  for i := NotExistPathList.Count - 1 downto 0 do
  begin
    Path := NotExistPathList[i];

      // û�б仯 ����
    if not MyDesPathUtil.getIsExist( Path ) then
      Continue;

      // ·���仯
    NotExistPathList.Delete(i);
    ExistPathList.Add( Path );

      // �����ⲿ�仯
    DesExistChange( Path, True );
  end;
  PathLock.Leave;
end;

procedure TLocalBackupDesPathWatchThread.CheckPathUnmodify;
var
  i : Integer;
  Path : string;
begin
  PathLock.Enter;
  for i := UnModifyPathList.Count - 1 downto 0 do
  begin
    Path := UnModifyPathList[i];

      // û�б仯 ����
    if not MyDesPathUtil.getIsModify( Path ) then
      Continue;

      // ·���仯
    UnModifyPathList.Delete(i);

      // �����ⲿ�仯
    DesCanModify( Path );
  end;
  PathLock.Leave;
end;

constructor TLocalBackupDesPathWatchThread.Create;
begin
  inherited Create( True );
  PathLock := TCriticalSection.Create;
  ExistPathList := TStringList.Create;
  NotExistPathList := TStringList.Create;
  UnModifyPathList := TStringList.Create;
end;

procedure TLocalBackupDesPathWatchThread.DesCanModify(Path: string);
var
  BackupDesIsModifyHandle : TLocalBackupDesModifyHandle;
begin
  BackupDesIsModifyHandle := TLocalBackupDesModifyHandle.Create( Path );
  BackupDesIsModifyHandle.SetIsModify( True );
  BackupDesIsModifyHandle.Update;
  BackupDesIsModifyHandle.Free;
end;

destructor TLocalBackupDesPathWatchThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  UnModifyPathList.Free;
  NotExistPathList.Free;
  ExistPathList.Free;
  PathLock.Free;
  inherited;
end;

procedure TLocalBackupDesPathWatchThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    if not Terminated and ( SecondsBetween( Now, StartTime ) < 1 ) then
      Sleep(100);

    if Terminated then
      Break;

      // ���仯
    CheckPathExist;
    CheckPathNotExist;
    CheckPathUnmodify;
  end;
  inherited;
end;


{ TLocalBackupDesPathWatcherRemove }

procedure TLocalBackupDesPathWatcherRemove.Update;
var
  i : Integer;
begin
  inherited;

  PathLock.Enter;
  i := ExistPathList.IndexOf( Path );
  if i >= 0 then
    ExistPathList.Delete(i);
  i := NotExistPathList.IndexOf( Path );
  if i >= 0 then
    NotExistPathList.Delete(i);
  i := UnModifyPathList.IndexOf( Path );
  if i >= 0 then
    UnModifyPathList.Delete(i);
  PathLock.Leave;
end;

{ TMyLocalBackupDesExistWatcher }

constructor TMyLocalBackupDesWatcher.Create;
begin
  inherited;
  LocalBackupDesPathWatchThread := TLocalBackupDesPathWatchThread.Create;
  LocalBackupDesPathWatchThread.Resume;
end;

procedure TMyLocalBackupDesWatcher.StopWatch;
begin
  StopThread;
  LocalBackupDesPathWatchThread.Free;
end;


end.

