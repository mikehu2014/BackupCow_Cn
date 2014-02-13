unit UFormExitWarnning;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, siComp, UMainForm;

type
  TfrmExitConfirm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    btnYes: TButton;
    btnNo: TButton;
    ChkIsShow: TCheckBox;
    siLang_frmExitConfirm: TsiLang;
    procedure btnYesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExitConfirm: TfrmExitConfirm;

implementation

uses UFormSetting, IniFiles, UMyUtil;

{$R *.dfm}

procedure TfrmExitConfirm.btnYesClick(Sender: TObject);
var
  IniFile : TIniFile;
begin
  if ChkIsShow.Checked then
  begin
    IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
    IniFile.WriteBool( frmSetting.Name, frmSetting.chkShowAppExistDialog.Name, False );
    IniFile.Free;
  end;
end;

end.
