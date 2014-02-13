unit UAppEditionInfo;

interface

uses classes, SysUtils, DateUtils, Defence, Forms, UChangeInfo, IniFiles, UMyUtil;

type

  AppUpgradeModeUtil = class
  public
    class function getIsPrivateApp : Boolean;
    class procedure SetPrivateApp;
    class procedure SetNormalApp;
  end;

    // 检查盗版状态 线程
  TAppPiracyCheckThread = class( TThread )
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getAppPiracy : Boolean;
    procedure MakeAppError;
    procedure ShowPiracyFace;
  end;

const
  Ini_Application : string = 'Application';
  Ini_Application_UpgradeMode : string = 'UpgradeMode';

  UpgradeMode_PrivateMode : string = 'PrivateMode';

var
  AppPiracyCheckThread : TAppPiracyCheckThread;

implementation

uses UMainForm, UMyClient, UMyBackupInfo, UBackupInfoFace, UNetworkFace, UMyNetPcInfo, UMyJobInfo;

{ TCheckAppPiracyThread }

procedure TAppPiracyCheckThread.MakeAppError;
var
  RanNum : Integer;
begin
  Randomize;
  RanNum := Random( 6 );
  if RanNum = 0 then
    MyClient := nil
  else
  if RanNum = 1 then
    MyBackupFileInfo := nil
  else
  if RanNum = 2 then
    MyNetPcInfo := nil
  else
  if RanNum = 3 then
    MyJobInfo := nil
  else
  if RanNum = 4 then
    MyBackupFileFace := nil
  else
  if RanNum = 5 then
    MyNetworkFace := nil
end;

procedure TAppPiracyCheckThread.ShowPiracyFace;
begin
  frmMainForm.Caption := ' ' + frmMainForm.Caption;
end;

constructor TAppPiracyCheckThread.Create;
begin
  inherited Create( True );
end;


destructor TAppPiracyCheckThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TAppPiracyCheckThread.Execute;
var
  StartTime : TDateTime;
  IsPraicy : Boolean;
begin
    // 获取是否盗版
  IsPraicy := getAppPiracy;
  if IsPraicy then
  begin
    Synchronize( ShowPiracyFace ); // 界面显示
//    Memory_IsFree := False; // 不释放内存
  end;

  while not Terminated and IsPraicy do
  begin
    StartTime := Now;
    while not Terminated and ( MinutesBetween( Now, StartTime ) < 10 ) do
      Sleep( 100 );

      // 程序结束
    if Terminated then
      Break;

      // 出错的概率 1 / 12 , 两小时内
    Randomize;
    if Random( 12 ) <> 0 then
      Continue;

      // 改变状态
    MakeAppError;
  end;

  inherited;
end;

function TAppPiracyCheckThread.getAppPiracy: Boolean;
var
  MyCRC32: longInt;
  strA, strB: string;
begin
  MyCRC32 := $00112233;
  MyFileCRC32(Application.ExeName, MyCRC32);
  strA := inttohex(TrueCRC32, 8);
  strB := inttohex(MyCRC32, 8);
  Result := CompareStr(strA, strB) <> 0;
end;

{ AppUpgradeModeUtil }

class function AppUpgradeModeUtil.getIsPrivateApp: Boolean;
var
  iniFile : TIniFile;
begin
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  Result := iniFile.ReadString( Ini_Application, Ini_Application_UpgradeMode, '' ) = UpgradeMode_PrivateMode;
  iniFile.Free;
end;

class procedure AppUpgradeModeUtil.SetNormalApp;
var
  iniFile : TIniFile;
begin
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  iniFile.WriteString( Ini_Application, Ini_Application_UpgradeMode, '' );
  iniFile.Free;
end;

class procedure AppUpgradeModeUtil.SetPrivateApp;
var
  iniFile : TIniFile;
begin
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  iniFile.WriteString( Ini_Application, Ini_Application_UpgradeMode, UpgradeMode_PrivateMode );
  iniFile.Free;
end;

end.
