unit URegisterInfo;

interface

uses IniFiles, UMyUtil, SysUtils, Classes, kg_dnc, URegisterInfoIO, Generics.Collections, UModelUtil,
     SyncObjs, UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, DateUtils, idhttp, uDebug;

type

{$Region ' ����ע����Ϣ ' }

    // Ѱ�� ����ע�� ��Ϣ
  TFindWebRegisterInfo = class
  private
    LincenseStr : string;
    Hardcode, EditionNum, LastDateStr : string;
  private
    RegisterEdition : string;
    LastDate : TDateTime;
  public
    procedure Update;
  private
    function LoadLinceseStr : Boolean;
    function FindLincenseInfo : Boolean;
    function CheckHardCode : Boolean;
    function CheckEditionNum : Boolean;
    function CheckLastDate : Boolean;
  end;

    // ���� �汾��Ϣ
  TRegisterInfoLoad = class
  public
    procedure Update;
  end;

    // ����汾��Ϣ
  TRegisterInfoSave = class
  private
    LicenseStr : string;
  public
    constructor Create( _LicenseStr : string );
    procedure Update;
  private
    function CheckLicenseStr : Boolean;
    procedure SaveLicenseStr;
    procedure ResetAppTime;
  end;

    // ����վ�ϵǼ�ʹ�����
  TRegisterUserToWeb = class
  public
    procedure Update;
  private
    function IsWebRegister : Boolean;
    procedure RunRegisterThread;
  end;

      // ע����Ϣ
  TRegisterInfo = class
  public
    RegisterEditon : string;
    LastDate : TDateTime;
  public
    procedure FirstLoadLicense;
    procedure LoadLicense;
    procedure SaveLicense( LicenseStr : string );
  public
    function getAppEditionDate : string;
    function getIsPermanent : Boolean;
    function getIsFreeEdition : Boolean;
  end;

    // ����ע�� ������
  TMyRegisterControl = class
  public
    procedure AddLicense( LicenseStr : string );
  end;

    // ��¼ ʹ����Ϣ
  TAppFreeUserMarkThread = class( TThread )
  public
    constructor Create;
  protected
    procedure Execute; override;
  private
    procedure SaveFreeLicense( LicenseStr : string );
  end;

{$EndRegion}

{$Region ' ��ע����Ϣ ' }

  {$Region ' ���ݽṹ ' }

    // Pc ����ע����Ϣ
  TPcBatRegisterInfo = class
  public
    PcID : string;
    LicenseStr : string;
  public
    constructor Create( _PcID, _LicenseStr : string );
  end;
  TPcBatRegisterPair = TPair< string , TPcBatRegisterInfo >;
  TPcBatRegisterHash = class(TStringDictionary< TPcBatRegisterInfo >);

  {$EndRegion}

  {$Region ' �仯 ' }

    // ����
  TPcBatRegisterChangeInfo = class( TChangeInfo )
  public
    PcID : string;
  protected
    PcBatRegisterHash : TPcBatRegisterHash;
  public
    constructor Create( _PcID : string );
    procedure Update;override;
  end;

    // ����
  TPcBatRegisterAddInfo = class( TPcBatRegisterChangeInfo )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;override;
  end;

    // Pc Online ���� License
  TPcBatRegisterOnlineInfo = class( TPcBatRegisterChangeInfo )
  private
    LicenseStr : string;
  public
    procedure Update;override;
  private
    procedure SendLicenseToPc;
  end;

  {$EndRegion}

    // ��ע����Ϣ
  TMyBatRegisterInfo = class( TMyDataChange )
  public
    PcBatRegisterHash : TPcBatRegisterHash;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ��ע�� Xml ' }

  {$Region ' �޸� ' }

    // ����
  TPcBatRegisterChangeXml = class( TChangeInfo )
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
  end;

    // ����
  TPcBatRegisterAddXml = class( TPcBatRegisterChangeInfo )
  public
    LicenseStr : string;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;override;
  end;

    // ɾ��
  TPcBatRegisterRemoveXml = class( TPcBatRegisterChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' ��ȡ ' }

    // ���� Pc �� ��ע����Ϣ
  TPcBatRegisterXmlReadHandle = class
  private
    PcID : string;
    LicenseStr : string;
  public
    constructor Create( _PcID, _LicenseStr : string );
    procedure Update;
  end;

    // ��ȡ
  TBatRegisterXmlRead = class
  public
    procedure Update;
  end;

  {$EndRegion}

    // ��ע�� Xml ��Ϣ
  TMyBatRegisteWriterXml = class( TMyChildXmlChange )
  end;

{$EndRegion}

{$Region ' ���ע��״̬��Ϣ ' }

    // �޸� ϵͳ����ʱ��
  TUpdateAppRunTime = class
  private
    DelRunTime : Integer;
  private
    RunTime : Int64;
  public
    constructor Create( _DelRunTime : Integer );
    procedure Update;
  private
    procedure ReadRunTime;
    procedure UpdateRunTIme;
    procedure WriteRunTime;
  private
    procedure CheckAppStartTime;
  end;

    // ��ȡ��ҳʱ��
  TGetWebTime = class
  private
    DateStr : string;
  public
    function get : TDateTime;
  private
    function FindDateStr : Boolean;
    function getMonth( MonthStr : string ): Word;
  end;

    // ��������Ƿ����
  TAppExpiredCheck = class
  private
    ExpiredDate : TDateTime;
    IsCheckWebTime : Boolean;
  public
    constructor Create( _ExpiredDate : TDateTime );
    procedure SetIsCheckWebTime( _IsCheckWebTime : Boolean );
    function getIsExpired : Boolean;
  private
    function CheckLocalTime: Boolean;  // ����ʱ��
    function CheckWebTime: Boolean;   // ����ʱ��
    function CheckAppRunTime : Boolean;  // ������¼�� ��������ʱ��
  end;

    // ���ڼ�������Ƿ����
    // ��ʱд AppRun ʱ��
  TAppExpiredCheckThread = class( TThread )
  private
    IsExpired : Boolean;
  public
    constructor Create;
    procedure SetIsExpired( _IsExpired : Boolean );
    destructor Destroy; override;
  protected
    procedure Execute;override;
  public
    procedure WriteAppTime;
    procedure CheckExpired;
    procedure ShowExpired;
  end;


{$EndRegion}

  EditionUtil = class
  public
    class function getFreeMaxBackupSpace : Int64;
    class function getEditionInt( RegisterEdition : string ): Integer;
  public
    class function getIsLimitShareSpace( FileSize : Int64 ): Boolean;
    class function getIsLimitFileSendSpace( FileSize : Int64 ): Boolean;
  public
    class function getSendFileIsLimit( FilePath : string ): Boolean;
  end;

const
  Ini_Register = 'Register';
  Ini_License = 'License';

    // License
  Lincense_Split : string = '|';
  Lincense_SplitCount : Integer = 3;
  Lincense_HardCode : Integer = 0;
  Lincense_EditionInfo : Integer = 1;
  Lincense_LastDate : Integer = 2;

    // License Edition Number
  EditionNum_Try : string = '0';
  EditionNum_Professional : string = '1';
  EditionNum_Enterprise : string = '2';

    // �汾��Ϣ
  RegisterEdition_Evaluate = 'Evaluation';  // ���ð�( �°治ʹ�� )
  RegisterEditon_Free = 'Free'; // ��Ѱ�
  RegisterEditon_Professional = 'Professional';  // רҵע���
  RegisterEditon_Enterprise = 'Enterprise';  // ��ҵע���

  Xml_PcID = 'pi';
  Xml_LicenseStr = 'ls';
  Time_CheckEdition : Integer = 1;


  FreeEditionLimit_BackupItem = 5;
  FreeEditionLimit_SendFileCount = 1000;
  FreeEditionLimit_SendFileSize = 100 * 1024 * 1024;
  FreeEditionLimit_ShareFileSize = 100 * 1024 * 1024;

  FreeEditionError_BackupSpace = 'Total size limit of backup source files is 3 GB in Free Ediition.';
  FreeEditionError_SendFileSize = 'You are not allowed to transfer a file larger than 100 MB in the Free Edition. ' + #13#10 +
                                  'Please upgrade the software to a Registered Edition.';
  FreeEditionError_SendFileCount = 'The free edition doesn''t allow you to transfer a folder with more than 1000 files inside.';
  FreeEditionError_ShareDownSize = 'You are not allowed to download a shared file larger than 100 MB in the Free Edition. ' + #13#10 +
                                  'Please upgrade the software to a Registered Edition.';
  FreeEditionError_ShareDownCount = 'The free edition doesn''t allow you to download a shared folder with more than 1000 files inside.';

var
  RegisterInfo : TRegisterInfo;  // ����ע����Ϣ
  AppExpiredCheckThread : TAppExpiredCheckThread; // ��Ȿ��ע����Ϣ
  MyBatRegisterInfo : TMyBatRegisterInfo;  // ��ע����Ϣ
  MyBatRegisteWriterXml : TMyBatRegisteWriterXml;  // ��ע�� Xml
  MyRegisterControl : TMyRegisterControl; // ע�������

implementation

uses UMyClient, UMyNetPcInfo, UXmlUtil, UMainForm, UFormRegisterNew, UMyFileTransferControl,
     UNetworkFace, UMyUrl, UMyShareControl;

{ TCheckWebRegister }

function TFindWebRegisterInfo.CheckEditionNum: Boolean;
begin
  Result := True;

  if EditionNum = EditionNum_Professional then
    RegisterEdition := RegisterEditon_Professional
  else
  if EditionNum = EditionNum_Enterprise then
    RegisterEdition := RegisterEditon_Enterprise
  else
    Result := False;
end;

function TFindWebRegisterInfo.CheckHardCode: Boolean;
begin
  Result := MyMacAddress.Equals( Hardcode );
end;

function TFindWebRegisterInfo.CheckLastDate: Boolean;
var
  AppExpiredCheck : TAppExpiredCheck;
begin
  Result := StrToFloatDef( LastDateStr, -1 ) <> -1;

    // LastDate �ַ�����ʽ����
  if not Result then
    Exit;

  LastDate := StrToFloat( LastDateStr);

    // ��� �Ƿ����
  AppExpiredCheck := TAppExpiredCheck.Create( LastDate );
  AppExpiredCheck.SetIsCheckWebTime( False );
  Result := not AppExpiredCheck.getIsExpired;
  AppExpiredCheck.Free;
end;

procedure TFindWebRegisterInfo.Update;
begin
    // ��� license ��Ϣ
  if not ( LoadLinceseStr and FindLincenseInfo and CheckHardCode and
           CheckEditionNum and CheckLastDate )
  then
  begin
    RegisterEdition := RegisterEditon_Free;
    LastDate := IncYear( Now, 100 );
  end;

     // ���ö�ȡ�� license ��Ϣ
  RegisterInfo.RegisterEditon := RegisterEdition;
  RegisterInfo.LastDate := LastDate;
end;

function TFindWebRegisterInfo.FindLincenseInfo: Boolean;
var
  DecLincenseStr : string;
  LincenseList : TStringList;
begin
  Result := False;

      // ����
  DecLincenseStr := KeyDec( LincenseStr );

    // ��ȡ Lincense ��Ϣ
  LincenseList := MySplitStr.getList( DecLincenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
  begin
    Hardcode := LincenseList[ Lincense_HardCode ];
    EditionNum := LincenseList[ Lincense_EditionInfo ];
    LastDateStr := LincenseList[ Lincense_LastDate ];

    Result := True;
  end;
  LincenseList.Free;
end;

function TFindWebRegisterInfo.LoadLinceseStr: Boolean;
var
  iniFile : TIniFile;
begin
  Result := False;

    // Ini �ļ��� Lincense �ַ���
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  LincenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

    // Lincense ������
  if LincenseStr = '' then
    Exit;

  Result := True;
end;

{ TRegisterInfoLoadIni }

procedure TRegisterInfoLoad.Update;
var
  FindWebRegisterInfo : TFindWebRegisterInfo;
begin
  FindWebRegisterInfo := TFindWebRegisterInfo.Create;
  FindWebRegisterInfo.Update;
  FindWebRegisterInfo.Free;
end;

{ TRegisterInfo }

procedure TRegisterInfo.FirstLoadLicense;
var
  RegisterUserToWeb : TRegisterUserToWeb;
begin
    // ����
  LoadLicense;

    // ���û�������ϵǼ�ʹ��, ��Ǽ�
  RegisterUserToWeb := TRegisterUserToWeb.Create;
  RegisterUserToWeb.Update;
  RegisterUserToWeb.Free;
end;

function TRegisterInfo.getAppEditionDate: string;
begin
  Result := RegisterEditon;
  Result := frmMainForm.siLang_frmMainForm.GetText( Result );
  if getIsFreeEdition then
    Result := Result + frmMainForm.siLang_frmMainForm.GetText( 'LimitFeature' )
  else
  if getIsPermanent then
    Result := Result + frmMainForm.siLang_frmMainForm.GetText( 'Permanent' )
  else
    Result := Result + Format( frmMainForm.siLang_frmMainForm.GetText( 'Expireon' ), [DateToStr( LastDate )] );
end;

function TRegisterInfo.getIsFreeEdition: Boolean;
begin
  Result := RegisterEditon = RegisterEditon_Free;
end;

function TRegisterInfo.getIsPermanent: Boolean;
var
  Year2100 : TDateTime;
begin
  Year2100 := EncodeDate( 2100,1,1 );
  Result := ( RegisterEditon = RegisterEditon_Free ) or
            ( LastDate > Year2100 );
end;

procedure TRegisterInfo.LoadLicense;
var
  RegisterInfoLoad : TRegisterInfoLoad;
begin
  RegisterInfoLoad := TRegisterInfoLoad.Create;
  RegisterInfoLoad.Update;
  RegisterInfoLoad.Free;
end;

procedure TRegisterInfo.SaveLicense(LicenseStr: string);
var
  RegisterInfoSave : TRegisterInfoSave;
begin
  RegisterInfoSave := TRegisterInfoSave.Create( LicenseStr );
  RegisterInfoSave.Update;
  RegisterInfoSave.Free;
end;

{ TPcBaterRegisterInfo }

constructor TPcBatRegisterInfo.Create(_PcID, _LicenseStr: string);
begin
  PcID := _PcID;
  LicenseStr := _LicenseStr;
end;

{ TMyBatRegisterInfo }

constructor TMyBatRegisterInfo.Create;
begin
  inherited Create;
  PcBatRegisterHash := TPcBatRegisterHash.Create;
  AddThread( 1 );
end;

destructor TMyBatRegisterInfo.Destroy;
begin
  StopThread;
  PcBatRegisterHash.Free;
  inherited;
end;

{ TPcBatRegisterChangeInfo }

constructor TPcBatRegisterChangeInfo.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TPcBatRegisterChangeInfo.Update;
begin
  PcBatRegisterHash := MyBatRegisterInfo.PcBatRegisterHash;
end;

{ TPcBatRegisterAddInfo }

procedure TPcBatRegisterAddInfo.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TPcBatRegisterAddInfo.Update;
var
  NewBatRegisterInfo : TPcBatRegisterInfo;
begin
  inherited;

  NewBatRegisterInfo := TPcBatRegisterInfo.Create( PcID, LicenseStr );
  PcBatRegisterHash.AddOrSetValue( PcID, NewBatRegisterInfo );
end;

{ TPcBatRegisterOnlineInfo }

procedure TPcBatRegisterOnlineInfo.SendLicenseToPc;
var
  PcBatRegisterMsg : TPcBatRegisterMsg;
  PcBatRegisterRemoveXml : TPcBatRegisterRemoveXml;
begin
  PcBatRegisterMsg := TPcBatRegisterMsg.Create;
  PcBatRegisterMsg.SetPcID( PcInfo.PcID );
  PcBatRegisterMsg.SetLicenseStr( LicenseStr );
  MyClient.SendMsgToPc( PcID, PcBatRegisterMsg );

    // ɾ�� Xml
  PcBatRegisterRemoveXml := TPcBatRegisterRemoveXml.Create( PcID );
  MyBatRegisteWriterXml.AddChange( PcBatRegisterRemoveXml );
end;

procedure TPcBatRegisterOnlineInfo.Update;
begin
  inherited;

  if PcBatRegisterHash.ContainsKey( PcID ) then
  begin
    LicenseStr := PcBatRegisterHash[ PcID ].LicenseStr;
    PcBatRegisterHash.Remove( PcID );
    SendLicenseToPc;
  end;
end;

{ TPcBatRegisterChangeXml }

constructor TPcBatRegisterChangeXml.Create(_PcID: string);
begin
  PcID := _PcID;
end;

{ TPcBatRegisterAddXml }

procedure TPcBatRegisterAddXml.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TPcBatRegisterAddXml.Update;
var
  PcBatRegisterNode : IXMLNode;
begin
  PcBatRegisterNode := MyXmlUtil.AddListChild( PcBatRegisterHashXml, PcID );
  MyXmlUtil.AddChild( PcBatRegisterNode, Xml_PcID, PcID );
  MyXmlUtil.AddChild( PcBatRegisterNode, Xml_LicenseStr, LicenseStr );
end;

{ TPcBatRegisterRemoveXml }

procedure TPcBatRegisterRemoveXml.Update;
begin
  MyXmlUtil.DeleteListChild( PcBatRegisterHashXml, PcID );
end;

{ TPcBatRegisterXmlReadHandle }

constructor TPcBatRegisterXmlReadHandle.Create(_PcID, _LicenseStr: string);
begin
  PcID := _PcID;
  LicenseStr := _LicenseStr;
end;

procedure TPcBatRegisterXmlReadHandle.Update;
var
  PcBatRegisterAddInfo : TPcBatRegisterAddInfo;
begin
  PcBatRegisterAddInfo := TPcBatRegisterAddInfo.Create( PcID );
  PcBatRegisterAddInfo.SetLicenseStr( LicenseStr );
  MyBatRegisterInfo.AddChange( PcBatRegisterAddInfo );
end;

{ TBatRegisterXmlRead }

procedure TBatRegisterXmlRead.Update;
var
  i : Integer;
  PcBatRegisterNode : IXMLNode;
  PcID, LicenseStr : string;
  PcBatRegisterXmlReadHandle : TPcBatRegisterXmlReadHandle;
begin
  for i := 0 to PcBatRegisterHashXml.ChildNodes.Count - 1 do
  begin
    PcBatRegisterNode := PcBatRegisterHashXml.ChildNodes[i];
    PcID := MyXmlUtil.GetChildValue( PcBatRegisterNode, Xml_PcID );
    LicenseStr := MyXmlUtil.GetChildValue( PcBatRegisterNode, Xml_LicenseStr );

    PcBatRegisterXmlReadHandle := TPcBatRegisterXmlReadHandle.Create( PcID, LicenseStr );
    PcBatRegisterXmlReadHandle.Update;
    PcBatRegisterXmlReadHandle.Free;
  end;
end;

{ TWriteAppRunTime }

procedure TUpdateAppRunTime.CheckAppStartTime;
var
  ReadAppStartTime : TReadAppStartTime;
  IsExistStartTimeKey : Boolean;
  WriteAppStartTime : TWriteAppStartTime;
begin
    // ��ȡ ����ʼʱ�� Key , �ж��Ƿ����
  ReadAppStartTime := TReadAppStartTime.Create;
  ReadAppStartTime.ReadKey;
  IsExistStartTimeKey := ( ReadAppStartTime.RegistryKey <> '' ) or
                         ( ReadAppStartTime.AppDataKey <> '' );
  ReadAppStartTime.Free;

    // ���� ��
  if IsExistStartTimeKey then
    Exit;

    // ��������д��
  WriteAppStartTime := TWriteAppStartTime.Create( Now );
  WriteAppStartTime.Update;
  WriteAppStartTime.Free;
end;

constructor TUpdateAppRunTime.Create(_DelRunTime: Integer);
begin
  DelRunTime := _DelRunTime;
end;

procedure TUpdateAppRunTime.UpdateRunTIme;
begin
  RunTime := RunTime + DelRunTime;
end;


procedure TUpdateAppRunTime.ReadRunTime;
var
  ReadAppRunTime : TReadAppRunTime;
begin
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;
end;

procedure TUpdateAppRunTime.WriteRunTime;
var
  WriteAppRunTime : TWriteAppRunTime;
begin
  WriteAppRunTime := TWriteAppRunTime.Create( RunTime );
  WriteAppRunTime.Update;
  WriteAppRunTime.Free;
end;

procedure TUpdateAppRunTime.Update;
begin
  ReadRunTime;
  UpdateRunTIme;
  WriteRunTime;

  CheckAppStartTime;
end;

{ TCheckAppOutDate }

function TAppExpiredCheck.CheckAppRunTime: Boolean;
var
  ReadAppStartTime : TReadAppStartTime;
  StartTime, NowTime : TDateTime;
  ReadAppRunTime : TReadAppRunTime;
  RunTime : Int64;
begin
    // ����ʼʱ��
  ReadAppStartTime := TReadAppStartTime.Create;
  StartTime := ReadAppStartTime.get;
  ReadAppStartTime.Free;

    // ��������ʱ��
  ReadAppRunTime := TReadAppRunTime.Create;
  RunTime := ReadAppRunTime.get;
  ReadAppRunTime.Free;

    // �����ϵ�ʱ��
  NowTime := IncMinute( StartTime, RunTime );

  Result := ExpiredDate > NowTime;
end;

function TAppExpiredCheck.CheckLocalTime: Boolean;
begin
  Result := ExpiredDate > Now;
end;

function TAppExpiredCheck.CheckWebTime: Boolean;
var
  GetWebTime : TGetWebTime;
  ReadWebTime : TReadWebTime;
  WebTime : TDateTime;
  WriteWebTime : TWriteWebTime;
begin
  Result := True;
  if not IsCheckWebTime then
    Exit;

    // ������վ ��ȡ����ʱ��
  GetWebTime := TGetWebTime.Create;
  WebTime := GetWebTime.get;
  GetWebTime.Free;

    // �޷�������վ
  if WebTime = -1 then
  begin
      // ��ȡ��һ�η�����վ��ʱ��
    ReadWebTime := TReadWebTime.Create;
    WebTime := ReadWebTime.get;
    ReadWebTime.Free;
  end
  else
  begin
      // ��¼��η�����վ��ʱ��
    WriteWebTime := TWriteWebTime.Create( WebTime );
    WriteWebTime.Update;
    WriteWebTime.Free;
  end;

    // �жϰ汾�Ƿ����
  Result := ExpiredDate > WebTime;
end;

constructor TAppExpiredCheck.Create(_ExpiredDate: TDateTime);
begin
  ExpiredDate := _ExpiredDate;
end;

function TAppExpiredCheck.getIsExpired: Boolean;
begin
  Result := not CheckLocalTime or
            not CheckWebTime or
            not CheckAppRunTime;
end;

procedure TAppExpiredCheck.SetIsCheckWebTime(_IsCheckWebTime: Boolean);
begin
  IsCheckWebTime := _IsCheckWebTime;
end;

{ TGetWebTime }

function TGetWebTime.FindDateStr: Boolean;
var
  getTimeHttp : TIdHTTP;
begin
  getTimeHttp := TIdHTTP.Create(nil);
  getTimeHttp.HandleRedirects := True;
  try
    getTimeHttp.Get( 'http://www.BackupCow.com/' );
    DateStr := getTimeHttp.Response.RawHeaders.Values[ 'Date' ];
    Result := True;
  except
    Result := False;
  end;
  getTimeHttp.Free;
end;

function TGetWebTime.get: TDateTime;
var
  YearStr, MonthStr, DayStr : string;
  Year, Month, Day: Word;
begin
  Result := Now;
  Exit;

  if not FindDateStr then
    Exit;

  DateStr := Copy(DateStr, 6, 11);
  YearStr := Copy(DateStr, 8, 4);
  MonthStr := Copy(DateStr, 4, 3);
  DayStr := Copy(DateStr, 1, 2);

  Year := StrToIntDef( YearStr, 0 );
  Month := getMonth( MonthStr );
  Day := StrToIntDef( DayStr, 0 );

  if ( Year = 0 ) or ( Month = 0 ) or ( Day = 0 ) then
    Exit;

  Result := EncodeDate( Year, Month, Day );
end;

function TGetWebTime.getMonth(MonthStr: string): Word;
var
  m : Word;
begin
  if CompareText(MonthStr, 'jan') = 0 then
    m := 1
  else if CompareText(MonthStr, 'feb') = 0 then
    m := 2
  else if CompareText(MonthStr, 'mar') = 0 then
    m := 3
  else if CompareText(MonthStr, 'apr') = 0 then
    m := 4
  else if CompareText(MonthStr, 'may') = 0 then
    m := 5
  else if CompareText(MonthStr, 'jun') = 0 then
    m := 6
  else if CompareText(MonthStr, 'jul') = 0 then
    m := 7
  else if CompareText(MonthStr, 'aug') = 0 then
    m := 8
  else if CompareText(MonthStr, 'sep') = 0 then
    m := 9
  else if CompareText(MonthStr, 'oct') = 0 then
    m := 10
  else if CompareText(MonthStr, 'nov') = 0 then
    m := 11
  else if CompareText(MonthStr, 'dec') = 0 then
    m := 12
  else
    m := 0;
end;

{ TCheckOutDateThread }

procedure TAppExpiredCheckThread.CheckExpired;
var
  CheckAppExpired : TAppExpiredCheck;
  IsExpired : Boolean;
begin
    // ��� �Ƿ� ����
  CheckAppExpired := TAppExpiredCheck.Create( RegisterInfo.LastDate );
  CheckAppExpired.SetIsCheckWebTime( True );
  IsExpired := CheckAppExpired.getIsExpired;
  CheckAppExpired.Free;

    // ����
  if IsExpired then
    Synchronize( ShowExpired );
end;

constructor TAppExpiredCheckThread.Create;
begin
  inherited Create( True );
  IsExpired := True;
end;

destructor TAppExpiredCheckThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TAppExpiredCheckThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while ( not Terminated ) and
          ( IsExpired or ( MinutesBetween( Now, StartTime ) < Time_CheckEdition ) )
    do
      Sleep( 100 );


      // �������
    if Terminated then
      Break;

      // ���� App����ʱ��
    WriteAppTime;

      // ��� ������Ϣ
    CheckExpired;
  end;

  inherited;
end;

procedure TAppExpiredCheckThread.SetIsExpired(_IsExpired: Boolean);
begin
  IsExpired := _IsExpired;
end;

procedure TAppExpiredCheckThread.ShowExpired;
begin
  frmMainForm.RefreshRegisterEdition;
end;

procedure TAppExpiredCheckThread.WriteAppTime;
var
  UpdateAppRunTime : TUpdateAppRunTime;
begin
  UpdateAppRunTime := TUpdateAppRunTime.Create( Time_CheckEdition );
  UpdateAppRunTime.Update;
  UpdateAppRunTime.Free;
end;


{ TRegisterInfoSave }

function TRegisterInfoSave.CheckLicenseStr: Boolean;
var
  iniFile : TIniFile;
  ReadLicenseStr : string;
begin
    // Ini �ļ��� Lincense �ַ���
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  ReadLicenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

  Result := ReadLicenseStr <> LicenseStr;

    // ���� Ini �ļ�
  MyHideFile.Hide( MyIniFile.getIniFilePath );
end;

constructor TRegisterInfoSave.Create(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TRegisterInfoSave.ResetAppTime;
var
  WriteAppStartTime : TWriteAppStartTime;
  WriteAppRunTime : TWriteAppRunTime;
begin
    // ��¼ ����ʼ����ʱ��
  WriteAppStartTime := TWriteAppStartTime.Create( Now );
  WriteAppStartTime.Update;
  WriteAppStartTime.Free;

    // ��¼ ��������ʱ��
  WriteAppRunTime := TWriteAppRunTime.Create( 0 );
  WriteAppRunTime.Update;
  WriteAppRunTime.Free;
end;

procedure TRegisterInfoSave.SaveLicenseStr;
var
  IniFile : TIniFile;
begin
    // д Ini �ļ�
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_Register, Ini_License, LicenseStr );
  IniFile.Free;

    // �����ļ�
  MyHideFile.Hide( MyIniFile.getIniFilePath );
end;

procedure TRegisterInfoSave.Update;
begin
    // ��ͬ�� License
  if not CheckLicenseStr then
    Exit;

    // ���� License
  SaveLicenseStr;

    // ���� App ʱ��
  ResetAppTime;
end;

{ FreeEditionUtil }

class function EditionUtil.getEditionInt(RegisterEdition: string): Integer;
begin
  if RegisterEdition = RegisterEditon_Enterprise then
    Result := 2
  else
  if RegisterEdition = RegisterEditon_Professional then
    Result := 1
  else
    Result := 0;
end;

class function EditionUtil.getSendFileIsLimit(FilePath: string): Boolean;
begin
  Result := MyFileInfo.getFileSize( FilePath ) >= FreeEditionLimit_SendFileSize;
end;

class function EditionUtil.getFreeMaxBackupSpace: Int64;
begin
  Result := 3 * Size_GB;
end;

class function EditionUtil.getIsLimitFileSendSpace(FileSize: Int64): Boolean;
begin
  Result := False;
  if not RegisterInfo.getIsFreeEdition then
    Exit;
  Result := FileSize > FreeEditionLimit_SendFileSize;
end;

class function EditionUtil.getIsLimitShareSpace(FileSize: Int64): Boolean;
begin
  Result := False;
  if not RegisterInfo.getIsFreeEdition then
    Exit;
  Result := FileSize > FreeEditionLimit_ShareFileSize;
end;

{ TMyRegisterControl }

procedure TMyRegisterControl.AddLicense(LicenseStr: string);
var
  RefreshRegisterInfo : TLvRegisterRefresh;
  SendFileEnterProEditionHandle : TSendFileEnterProEditionHandle;
  ShareDownResetFreeLimitHandle : TShareDownResetFreeLimitHandle;
begin
  RegisterInfo.SaveLicense( LicenseStr );
  RegisterInfo.LoadLicense;

    // ˢ��ע����Ϣ
  RefreshRegisterInfo := TLvRegisterRefresh.Create;
  MyNetworkFace.AddChange( RefreshRegisterInfo );

    // ˢ������Ϣ
  MyClient.UpgradeCloudInfo;

    // ���������ƵĴ��ļ�����
  SendFileEnterProEditionHandle := TSendFileEnterProEditionHandle.Create;
  SendFileEnterProEditionHandle.Update;
  SendFileEnterProEditionHandle.Free;

    // ���������ƵĴ��ļ�����
  ShareDownResetFreeLimitHandle := TShareDownResetFreeLimitHandle.Create;
  ShareDownResetFreeLimitHandle.Update;
  ShareDownResetFreeLimitHandle.Free;
end;

{ TAppFreeUserMarkThread }

constructor TAppFreeUserMarkThread.Create;
begin
  inherited Create( True );
  FreeOnTerminate := True;
end;

procedure TAppFreeUserMarkThread.Execute;
var
  Url, HardCode, PcName, PcID : string;
  IdHttp : TIdHTTP;
  ParamList : TStringList;
  LicenseStr : string;
begin
  Url := MyUrl.getTrialKey;
  HardCode := MyMacAddress.getStr;
  PcName := MyComputerName.get;
  PcID := MyComputerID.get;

  ParamList := TStringList.Create;
  ParamList.Add( HttpReqTrial_HardCode + '=' + HardCode );
  ParamList.Add( HttpReqTrial_PcName + '=' + PcName );
  ParamList.Add( HttpReqTrial_PcID + '=' + PcID );
  IdHttp := TIdHTTP.Create(nil);
  try
    LicenseStr := IdHttp.Post( Url, ParamList );
  except
    LicenseStr := '';
  end;
  IdHttp.Free;
  ParamList.Free;

    // �Ǽ�
  if LicenseStr <> '' then
    SaveFreeLicense( LicenseStr );
end;

procedure TAppFreeUserMarkThread.SaveFreeLicense( LicenseStr : string );
var
  IniFile : TIniFile;
begin
    // д Ini �ļ�
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_Register, Ini_License, LicenseStr );
  IniFile.Free;

    // �����ļ�
  MyHideFile.Hide( MyIniFile.getIniFilePath );
end;

{ TRegisterUserToWeb }

function TRegisterUserToWeb.IsWebRegister: Boolean;
var
  iniFile : TIniFile;
  LicenseStr, HardCode : string;
  LincenseList : TStringList;
begin
  Result := False;

    // Ini �ļ��� Lincense �ַ���
  iniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  LicenseStr := iniFile.ReadString( Ini_Register, Ini_License, '' );
  iniFile.Free;

    // ��
  if LicenseStr = '' then
    Exit;

    // ����
  LicenseStr := KeyDec( LicenseStr );

    // ��ȡ��Ϣ
  LincenseList := MySplitStr.getList( LicenseStr, Lincense_Split );
  if LincenseList.Count = 3 then
    Result := MyMacAddress.Equals( LincenseList[ Lincense_HardCode ] );
  LincenseList.Free;
end;

procedure TRegisterUserToWeb.RunRegisterThread;
var
  AppFreeUserMarkThread : TAppFreeUserMarkThread;
begin
  AppFreeUserMarkThread := TAppFreeUserMarkThread.Create;
  AppFreeUserMarkThread.Resume;
end;

procedure TRegisterUserToWeb.Update;
begin
    // û��ע�� �� ����ע���߳�
  Register_IsFirst := not IsWebRegister; // δע��
  if Register_IsFirst then
    RunRegisterThread;
end;

end.