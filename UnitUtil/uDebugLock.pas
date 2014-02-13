unit uDebugLock;

interface

uses
  Classes, Windows, SysUtils;

type
  TDebugLockItem = packed record
    ThreadId: Cardinal;
    Msg: string;
    MsgLast: string;
    LastTick: Cardinal;
  end;
  PDebugLockItem = ^TDebugLockItem;

  TDebugLock = class
    FLock: TRTLCriticalSection;
    FList: TList;
  private
    procedure Lock;
    procedure Unlock;
    procedure Clean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure AddDebug(ThreadId: Cardinal);
    procedure RemoveDebug(ThreadId: Cardinal);
  public
    procedure Debug(Msg: string);
    function TrackDebug: string;
  end;

var
  DebugLock: TDebugLock;

implementation

{ TDebugLock }

procedure TDebugLock.AddDebug(ThreadId: Cardinal);
var
  DebugLockItem: PDebugLockItem;
begin
  New(DebugLockItem);
  DebugLockItem^.ThreadId := ThreadId;
  DebugLockItem^.Msg := '';
  DebugLockItem^.MsgLast := '';
  DebugLockItem^.LastTick := GetTickCount;
  Lock;
  try
    FList.Add(DebugLockItem);
  finally
    Unlock;
  end;
end;

procedure TDebugLock.Clean;
var
  I: Integer;
begin
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      Dispose(PDebugLockItem(FList.Items[I]));
    end;
    FList.Clear;
  finally
    Unlock;
  end;
end;

constructor TDebugLock.Create;
begin
  inherited Create;
  InitializeCriticalSection(FLock);
  FList := TList.Create;
end;

procedure TDebugLock.Debug(Msg: string);
var
  ThreadId: Cardinal;
  I: Integer;
  Index: Integer;
  DebugLockItem: PDebugLockItem;
begin
  ThreadId := GetCurrentThreadId;
  Index := -1;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      if PDebugLockItem(FList.Items[I])^.ThreadId = ThreadId then
      begin
        Index := I;
        Break;
      end;
    end;
  finally
    Unlock;
  end;

  if Index > -1 then
  begin
    PDebugLockItem(FList.Items[I])^.Msg := PDebugLockItem(FList.Items[I])^.MsgLast;
    PDebugLockItem(FList.Items[I])^.MsgLast := Msg;
    PDebugLockItem(FList.Items[I])^.LastTick := GetTickCount;
  end else
  begin
{    New(DebugLockItem);
    DebugLockItem^.ThreadId := ThreadId;
    DebugLockItem^.Msg := '';
    DebugLockItem^.MsgLast := Msg;
    DebugLockItem^.LastTick := GetTickCount;
    Lock;
    try
      FList.Add(DebugLockItem);
    finally
      Unlock;
    end;      }
  end;
end;

destructor TDebugLock.Destroy;
begin
  Clean;
  FList.Free;
  DeleteCriticalSection(FLock);
  inherited Destroy;
end;

procedure TDebugLock.Lock;
begin
  EnterCriticalSection(FLock);
end;

procedure TDebugLock.RemoveDebug(ThreadId: Cardinal);
var
  I: Integer;
  DebugLockItem: PDebugLockItem;
begin
  DebugLockItem := nil;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      if PDebugLockItem(FList.Items[I])^.ThreadId = ThreadId then
      begin
        DebugLockItem := FList.Items[I];
        FList.Delete(I);
        Break;
      end;
    end;
  finally
    Unlock;
  end;
  if DebugLockItem <> nil then
  begin
    Dispose(DebugLockItem);
  end;
end;

function TDebugLock.TrackDebug: string;
var
  I: Integer;
  DebugLockItem: PDebugLockItem;
begin
  Result := '--TDebugLock.TrackDebug--' + #13#10;
  Lock;
  try
    for I := 0 to FList.Count - 1 do
    begin
      DebugLockItem := FList.Items[I];
      Result := Result + Format('ThreadId: %u, Msg: %s -> LastMsg: %s, LastTick: %dms'
        , [DebugLockItem^.ThreadId, DebugLockItem^.Msg, DebugLockItem^.MsgLast, GetTickCount - DebugLockItem^.LastTick]) + #13#10;
    end;
  finally
    Unlock;
  end;
end;

procedure TDebugLock.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

initialization
  DebugLock := TDebugLock.Create;

finalization
  DebugLock.Free;

end.

