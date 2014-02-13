unit UFormSearchOwnerDecrypt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, UMyUtil, siComp, UMainForm;

type
  TfrmIvDecrypt = class(TForm)
    lbPassword: TLabel;
    edtPassword: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    lbPcName: TLabel;
    edtPcName: TEdit;
    edtPcID: TEdit;
    lbPcID: TLabel;
    Label1: TLabel;
    siLang_frmIvDecrypt: TsiLang;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  public
    InputPasswordMD5 : string;
    PasswordMD5 : string;
  public
    function PcDecrypt( PcName, PcID, _PasswordMD5 : string ): Boolean;
  end;

const
  ShowHint_PasswordError : string = 'Password is incorrect.';

var
  frmIvDecrypt: TfrmIvDecrypt;

implementation

{$R *.dfm}

{ TfrmIvDecrypt }


procedure TfrmIvDecrypt.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmIvDecrypt.btnOKClick(Sender: TObject);
var
  InputPassword : string;
begin
  InputPassword := edtPassword.Text;
  InputPassword := MyEncrypt.EncodeMD5String( InputPassword );
  if InputPassword = PasswordMD5 then
  begin
    InputPasswordMD5 := InputPassword;
    Close
  end
  else
    MyMessageHint.ShowError( edtPassword.Handle, siLang_frmIvDecrypt.GetText( 'StrPasswordError' ) );
end;

function TfrmIvDecrypt.PcDecrypt(PcName, PcID, _PasswordMD5: string): Boolean;
begin
  edtPcName.Text := PcName;
  edtPcID.Text := PcID;
  edtPassword.Clear;
  PasswordMD5 := _PasswordMD5;

  InputPasswordMD5 := '';
  ShowModal;
  Result := InputPasswordMD5 = PasswordMD5;
end;

end.
