unit UMyUrl;

interface

//const
//  Url_Home = 'http://127.0.0.1:2456/WebSite/';
//  Url_Register = Url_Home;

//  Url_Home = 'http://www.backupcow.com/';
//  Url_Register = Url_Home + 'register/';
//  Url_Download = Url_Home + 'Download/';
//
//  Url_GetIp = Url_Register + 'ip/default.aspx?act=getip';
//  Url_GetTrialKey = Url_Register + 'Activate/GetTrialKey.aspx';
//  Url_GetPayLicenseKey = Url_Register + 'Activate/GetPayKey.aspx';
//  Url_GetBatPayLicenseKey = Url_Register + 'Activate/GetBatPayKey.aspx';
//
//  Url_GetCompanyList = Url_Register + 'company/GetCompanyList.aspx';
//  Url_RemoteRegister = Url_Home + 'remotegroup.aspx';
//  Url_ForgetPassword = Url_Home + 'ForgetPassword.aspx';
//  Url_RemoteInstruction = Url_Home + 'Instruction.aspx';
//
//  Url_Contact = Url_Home + 'ContactUs.asp';
//  Url_BuyNow = Url_Home + 'BuyNow.asp';
//  Url_OnlineManual = Url_Home + 'support.asp';
//
//  Url_AppUpgrade = Url_Download + 'BackupCowUpgrade.inf';
//  Url_AppUpgrade_Private = Url_Download + 'BackupCowUpgrade_Private.inf';

type

  MyUrl = class
  public
    class function getHome : string;
    class function getRegister : string;
    class function getDownload : string;
  public
    class function getIp : string;
    class function getTrialKey : string;
    class function getBatPayKey : string;
  public
    class function getGroupPcList : string;
    class function GroupSignup : string;
    class function GroupSignupHandle : string;
    class function GroupForgetPassword : string;
    class function GroupInstruction : string;
  public
    class function ContactUs : string;
    class function BuyNow : string;
    class function OnlineManual : string;
  public
    class function getAppUpgrade : string;
    class function getAppUpgradePrite : string;
    class function getAppRunMark : string;
  end;

//  Url_Home = 'http://127.0.0.1:2456/WebSite/';
//  Url_Register = Url_Home;

//  Url_Home = 'http://www.backupcow.com/';
//  Url_Register = Url_Home + 'register/';
//  Url_Download = Url_Home + 'Download/';

const
  HttpMarkRun_HardCode = 'HardCode';
  HttpMarkRun_PcID = 'PcID';
  HttpMarkRun_PcName = 'PcName';

const
  Url_BackuCowHome = 'http://www.backupcow.com/';
  Url_FolderTranferHome = 'http://www.foldertransfer.com/';
  Url_Register = 'register/';


//  Url_BackuCowHome = 'http://localhost:21101/BackupCow/';
//  Url_FolderTranferHome = 'http://localhost:21106/FolderTransfer/';
//  Url_Register = '';


var
  Url_AppHomePage : string = Url_BackuCowHome;

implementation

{ MyUrl }

class function MyUrl.getHome: string;
begin
  Result := Url_AppHomePage;
end;

class function MyUrl.getIp: string;
begin
  Result := getRegister + 'ip/default.aspx?act=getip';
end;

class function MyUrl.getRegister: string;
begin
  Result := getHome + Url_Register;
end;

class function MyUrl.BuyNow: string;
begin
  Result := getHome + 'BuyNow.asp';
end;

class function MyUrl.ContactUs: string;
begin
  Result := getHome + 'ContactUs.asp';
end;

class function MyUrl.getAppRunMark: string;
begin
  Result := getRegister + 'AppRunMark.aspx';
end;

class function MyUrl.getAppUpgrade: string;
begin
  Result := getDownload + 'BackupCowUpgrade.inf';
end;

class function MyUrl.getAppUpgradePrite: string;
begin
  Result := getDownload + 'BackupCowUpgrade_Private.inf';
end;

class function MyUrl.getBatPayKey: string;
begin
  Result := getRegister + 'Activate/GetBatPayKey.aspx';
end;

class function MyUrl.getTrialKey: string;
begin
  Result := getRegister + 'Activate/GetTrialKey.aspx';
end;

class function MyUrl.GroupForgetPassword: string;
begin
  Result := getHome + 'ForgetPassword.aspx';
end;

class function MyUrl.GroupInstruction: string;
begin
  Result := getHome + 'Instruction.aspx';
end;

class function MyUrl.GroupSignup: string;
begin
  Result := getHome + 'remotegroup.aspx';
end;

class function MyUrl.GroupSignupHandle: string;
begin
  Result := getHome + 'RemoteGroupSignup.aspx';
end;

class function MyUrl.OnlineManual: string;
begin
  Result := getHome + 'support.asp';
end;

class function MyUrl.getDownload: string;
begin
  Result := getHome + 'Download/';
end;


class function MyUrl.getGroupPcList: string;
begin
  Result := getRegister + 'company/GetCompanyList.aspx';
end;

end.
