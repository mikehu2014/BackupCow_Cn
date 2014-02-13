unit UFormAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, GIFImg, siComp;

type
  TfrmAbout = class(TForm)
    NbMain: TNotebook;
    plBackupCow: TPanel;
    plFolderTransfer: TPanel;
    CodingBest: TLabel;
    Label1: TLabel;
    lbEdition: TLabel;
    Image1: TImage;
    LinkLabel1: TLinkLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbFolderTransferEdition: TLabel;
    Image2: TImage;
    LinkLabel2: TLinkLabel;
    siLang_frmAbout: TsiLang;
    procedure LinkLabel1LinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure Image1DblClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    function getAppEdition : string;
  public
    { Public declarations }
  end;

const
  PageIndex_BackupCow = 0;
  PageIndex_FolderTransfer = 1;

var
  frmAbout: TfrmAbout;
  AppEdition_IsReset : Boolean = False;

implementation

uses UMyUtil, UAppEditionInfo, UMainForm, UMyUrl;

{$R *.dfm}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lbEdition.Caption := getAppEdition;
  lbFolderTransferEdition.Caption := getAppEdition;
  NbMain.PageIndex := PageIndex_BackupCow;
end;

function TfrmAbout.getAppEdition: string;
var
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  szName: array[0..255] of Char;
  Value: Pointer;
  Len: UINT;
  TransString:string;
begin
  InfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(Application.ExeName), Wnd, InfoSize, VerBuf) then
      begin
        Value :=nil;
        VerQueryValue(VerBuf, '\VarFileInfo\Translation', Value, Len);
        if Value <> nil then
           TransString := IntToHex(MakeLong(HiWord(Longint(Value^)), LoWord(Longint(Value^))), 8);
        Result := '';
        StrPCopy(szName, '\StringFileInfo\'+Transstring+'\FileVersion');
                                                        // ^^^^^^^此处换成ProductVersion得到的是"产品版本"
        if VerQueryValue(VerBuf, szName, Value, Len) then
           Result := StrPas(PChar(Value));
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure TfrmAbout.Image1DblClick(Sender: TObject);
begin
  AppEdition_IsReset := True;
end;

procedure TfrmAbout.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  InputStr : string;
begin
  if ( Button <> mbRight ) or not AppEdition_IsReset then
    Exit;

    // 改变 BackupCow 运行模式
  InputStr := InputBox( 'Infomation', 'Backup Cow', '' );

    // Private Backup Cow
  if InputStr = 'privatemode' then
  begin
    AppUpgradeModeUtil.SetPrivateApp;  // 保存 Ini
    frmMainForm.auApp.InfoFileURL := MyUrl.getAppUpgradePrite; // 重定向更新
  end
  else  // Normal
  if InputStr = 'normalmode' then
  begin
    AppUpgradeModeUtil.SetNormalApp;
    frmMainForm.auApp.InfoFileURL := MyUrl.getAppUpgrade;
  end;

  AppEdition_IsReset := False;
end;

procedure TfrmAbout.LinkLabel1LinkClick(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  MyInternetExplorer.OpenWeb( MyUrl.getHome );
end;

end.
