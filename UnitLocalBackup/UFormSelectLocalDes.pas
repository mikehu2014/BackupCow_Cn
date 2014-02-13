unit UFormSelectLocalDes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, siComp, UMainForm;

type
  TfrmSelectLocalDes = class(TForm)
    LvDestination: TListView;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    edtBackupSource: TEdit;
    siLang_frmSelectLocalDes: TsiLang;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure siLang_frmSelectLocalDesChangeLanguage(Sender: TObject);
  public
    procedure SetLocalSource( SourcePath : string );
    procedure SetBackupItem( DesPathList : TStringList );
    function getSelectItems : TStringList;
  end;

var
  frmSelectLocalDes: TfrmSelectLocalDes;

implementation

uses UIconUtil;

{$R *.dfm}

procedure TfrmSelectLocalDes.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectLocalDes.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSelectLocalDes.FormCreate(Sender: TObject);
begin
  LvDestination.SmallImages := MyIcon.getSysIcon;
  siLang_frmSelectLocalDesChangeLanguage( nil );
end;

procedure TfrmSelectLocalDes.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSelectLocalDes.getSelectItems: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  for i := 0 to LvDestination.Items.Count - 1 do
    if LvDestination.Items[i].Checked then
      Result.Add( LvDestination.Items[i].Caption );
end;

procedure TfrmSelectLocalDes.SetBackupItem(DesPathList: TStringList);
var
  i : Integer;
  DesPath : string;
begin
  LvDestination.Clear;

  for i := 0 to DesPathList.Count - 1 do
  begin
    DesPath := DesPathList[i];
    with LvDestination.Items.Add do
    begin
      Caption := DesPath;
      ImageIndex := MyIcon.getIconByFilePath( DesPath );
      Checked := True;
    end;
  end;
end;

procedure TfrmSelectLocalDes.SetLocalSource(SourcePath: string);
begin
  edtBackupSource.Text := SourcePath;
end;

procedure TfrmSelectLocalDes.siLang_frmSelectLocalDesChangeLanguage(
  Sender: TObject);
begin
  LvDestination.Columns[0].Caption := siLang_frmSelectLocalDes.GetText( 'lvDestination' );
end;

end.
