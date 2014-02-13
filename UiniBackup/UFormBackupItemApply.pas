unit UFormBackupItemApply;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, siComp, UMainForm;

type
  TfrmBackupItemsApply = class(TForm)
    LvBackupItem: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    btnSelectAll: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    siLang_frmBackupItemsApply: TsiLang;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure siLang_frmBackupItemsApplyChangeLanguage(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetBackupItem( BackupPathList : TStringList; SelectPath : string );overload;
    procedure SetBackupItem( BackupPathList, SelectPathList : TStringList );overload;
    function getSelectItems : TStringList;
  end;

var
  frmBackupItemsApply: TfrmBackupItemsApply;

implementation

uses UIconUtil, UMyUtil;

{$R *.dfm}

procedure TfrmBackupItemsApply.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupItemsApply.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmBackupItemsApply.btnSelectAllClick(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to LvBackupItem.Items.Count - 1 do
    LvBackupItem.Items[i].Checked := True;
end;

procedure TfrmBackupItemsApply.FormCreate(Sender: TObject);
begin
  LvBackupItem.SmallImages := MyIcon.getSysIcon;
  siLang_frmBackupItemsApplyChangeLanguage(nil);
end;

procedure TfrmBackupItemsApply.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmBackupItemsApply.getSelectItems: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;

  for i := 0 to LvBackupItem.Items.Count - 1 do
    if LvBackupItem.Items[i].Checked then
      Result.Add( LvBackupItem.Items[i].Caption );
end;

procedure TfrmBackupItemsApply.SetBackupItem(BackupPathList,
  SelectPathList: TStringList);
var
  i : Integer;
  BackupPath : string;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    with LvBackupItem.Items.Add do
    begin
      Caption := BackupPath;
      ImageIndex := MyIcon.getIconByFilePath( BackupPath );
      if SelectPathList.IndexOf( BackupPath ) >= 0 then
        Checked := True;
    end;
  end;
end;

procedure TfrmBackupItemsApply.SetBackupItem(BackupPathList: TStringList;
  SelectPath : string);
var
  SelectPathList : TStringList;
begin
  SelectPathList := MyStringList.getString( SelectPath );
  SetBackupItem( BackupPathList, SelectPathList );
  SelectPathList.Free;
end;

procedure TfrmBackupItemsApply.siLang_frmBackupItemsApplyChangeLanguage(
  Sender: TObject);
begin
  LvBackupItem.Columns[0].Caption := siLang_frmBackupItemsApply.GetText( 'lvBackupItem' );
end;

end.
