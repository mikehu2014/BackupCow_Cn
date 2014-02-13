unit UFormSelectLocalSource;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, siComp, UMainForm;

type
  TfrmSelectLocalBackupSource = class(TForm)
    Panel2: TPanel;
    LvBackupItem: TListView;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    edtDestination: TEdit;
    Label1: TLabel;
    siLang_frmSelectLocalBackupSource: TsiLang;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure siLang_frmSelectLocalBackupSourceChangeLanguage(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetDestination( DesPath : string );
    procedure SetBackupItem( BackupPathList : TStringList );
    function getSelectItems : TStringList;
  end;

var
  frmSelectLocalBackupSource: TfrmSelectLocalBackupSource;

implementation

Uses UIconUtil;

{$R *.dfm}

procedure TfrmSelectLocalBackupSource.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectLocalBackupSource.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSelectLocalBackupSource.FormCreate(Sender: TObject);
begin
  LvBackupItem.SmallImages := MyIcon.getSysIcon;
  siLang_frmSelectLocalBackupSourceChangeLanguage( nil );
end;

procedure TfrmSelectLocalBackupSource.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSelectLocalBackupSource.getSelectItems: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  for i := 0 to LvBackupItem.Items.Count - 1 do
    if LvBackupItem.Items[i].Checked then
      Result.Add( LvBackupItem.Items[i].Caption );
end;

procedure TfrmSelectLocalBackupSource.SetBackupItem(BackupPathList: TStringList);
var
  i : Integer;
  BackupPath : string;
begin
  LvBackupItem.Clear;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    with LvBackupItem.Items.Add do
    begin
      Caption := BackupPath;
      ImageIndex := MyIcon.getIconByFilePath( BackupPath );
      Checked := True;
    end;
  end;
end;

procedure TfrmSelectLocalBackupSource.SetDestination(DesPath: string);
begin
  edtDestination.Text := DesPath;
end;

procedure TfrmSelectLocalBackupSource.siLang_frmSelectLocalBackupSourceChangeLanguage(
  Sender: TObject);
begin
  LvBackupItem.Columns[0].Caption := siLang_frmSelectLocalBackupSource.GetText( 'lvBackupItem' );
end;

end.
