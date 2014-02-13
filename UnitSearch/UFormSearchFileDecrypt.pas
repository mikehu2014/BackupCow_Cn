unit UFormSearchFileDecrypt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, UMyUtil, UIconUtil, siComp, UMainForm;

type
  TfrmSearchFileDecrypt = class(TForm)
    lvEncryptFile: TListView;
    Panel1: TPanel;
    Label1: TLabel;
    edtPasswordHint: TEdit;
    Label2: TLabel;
    edtPassword: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    siLang_frmSearchFileDecrypt: TsiLang;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure siLang_frmSearchFileDecryptChangeLanguage(Sender: TObject);
  private
    PasswordMD5 : string;
    InputPassword : string;
  public
    procedure ClearItems;
    procedure SetPasswordInfo( _PasswordMD5, PasswordHint : string );
    procedure AddItem( FilePath, BackupPath : string );
    function getInputPassword : string;
  end;

const
  ShowHint_PasswordError : string = 'Password is incorrect.';

var
  frmSearchFileDecrypt: TfrmSearchFileDecrypt;

implementation

{$R *.dfm}

{ TfrmSearchFileDecrypt }

procedure TfrmSearchFileDecrypt.AddItem(FilePath, BackupPath: string);
var
  FileName : string;
begin
  FileName := ExtractFileName( FilePath );

  with lvEncryptFile.Items.Add do
  begin
    Caption := FileName;
    SubItems.Add( BackupPath );
    ImageIndex := MyIcon.getIconByFileExt( FilePath );
  end;
end;

procedure TfrmSearchFileDecrypt.btnCancelClick(Sender: TObject);
begin
  InputPassword := '';
  Close;
end;

procedure TfrmSearchFileDecrypt.btnOKClick(Sender: TObject);
var
  Password, InputPasswordMD5 : string;
begin
  Password := edtPassword.Text;
  InputPasswordMD5 := MyEncrypt.EncodeMD5String( Password );
  if InputPasswordMD5 = PasswordMD5 then
  begin
    InputPassword := Password;
    Close;
  end
  else
    MyMessageHint.ShowError( edtPassword.Handle, siLang_frmSearchFileDecrypt.GetText( 'StrPasswordError' ) );
end;

procedure TfrmSearchFileDecrypt.ClearItems;
begin
  lvEncryptFile.Clear;
end;

procedure TfrmSearchFileDecrypt.FormCreate(Sender: TObject);
begin
  lvEncryptFile.SmallImages := MyIcon.getSysIcon;
  siLang_frmSearchFileDecryptChangeLanguage( nil );
end;

function TfrmSearchFileDecrypt.getInputPassword: string;
begin
  InputPassword := '';
  ShowModal;
  Result := InputPassword;
end;

procedure TfrmSearchFileDecrypt.SetPasswordInfo(_PasswordMD5,
  PasswordHint: string);
begin
  edtPassword.Clear;
  edtPasswordHint.Text := PasswordHint;
  PasswordMD5 := _PasswordMD5;
end;

procedure TfrmSearchFileDecrypt.siLang_frmSearchFileDecryptChangeLanguage(
  Sender: TObject);
begin
  with lvEncryptFile do
  begin
    Columns[ 0 ].Caption := siLang_frmSearchFileDecrypt.GetText( 'lvFileName' );
    Columns[ 1 ].Caption := siLang_frmSearchFileDecrypt.GetText( 'lvBackupPath' );
  end;
end;

end.
