unit UFormSpaceLimit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, siComp, UMainFOrm;

type
  TfrmSpaceLimit = class(TForm)
    SeValue: TSpinEdit;
    cbSpaceType: TComboBox;
    lbType: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    siLang_frmSpaceLimit: TsiLang;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AddSmallerThan;
    procedure AddLargerThan;
  public
    function getSpaceValue : Int64;
  end;

const
  LabelType_Smaller = 'Smaller than';
  LabelType_Larger = 'Larger than';

var
  frmSpaceLimit: TfrmSpaceLimit;

implementation

Uses UMyUtil;

{$R *.dfm}

{ TfrmSpaceLimit }

procedure TfrmSpaceLimit.AddLargerThan;
begin
  lbType.Caption := siLang_frmSpaceLimit.GetText( 'lbBigThan' );
end;

procedure TfrmSpaceLimit.AddSmallerThan;
begin
  lbType.Caption := siLang_frmSpaceLimit.GetText( 'lbSmallThan' );
end;

procedure TfrmSpaceLimit.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSpaceLimit.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSpaceLimit.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSpaceLimit.getSpaceValue: Int64;
begin
  Result := MySize.getSpaceValue( SeValue.Value, cbSpaceType.Text );
end;

end.
