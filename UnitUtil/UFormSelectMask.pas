unit UFormSelectMask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, siComp, UMainForm;

type
  TFrmEnterMask = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    Label2: TLabel;
    edtMask: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    siLang_FrmEnterMask: TsiLang;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    function getMaskStr : string;
  end;

var
  FrmEnterMask: TFrmEnterMask;

implementation

{$R *.dfm}

procedure TFrmEnterMask.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmEnterMask.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TFrmEnterMask.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TFrmEnterMask.getMaskStr: string;
begin
  Result := edtMask.Text;
end;

end.
