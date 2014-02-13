unit UFormBackupItemDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ToolWin, ExtCtrls, UMainForm, UMyUtil;

type
  TfrmBackupItemDetail = class(TForm)
    lvOwnerDetail: TListView;
    Panel1: TPanel;
    edtFullPath: TEdit;
    tbFileLink: TToolBar;
    tbtnFileLink: TToolButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbSize: TLabel;
    lbContains: TLabel;
    lbStatus: TLabel;
    procedure tbtnFileLinkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure BindSort;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBackupItemDetail: TfrmBackupItemDetail;

implementation

uses UFormUtil;

{$R *.dfm}

procedure TfrmBackupItemDetail.BindSort;
begin
  ListviewUtil.BindSort( lvOwnerDetail );
end;

procedure TfrmBackupItemDetail.FormCreate(Sender: TObject);
var
  NewIcon : TIcon;
begin
  NewIcon := TIcon.Create;
  frmMainForm.ilTbFs.GetIcon( 4, NewIcon );
  Icon := NewIcon;
  NewIcon.Free;

  BindSort;
end;

procedure TfrmBackupItemDetail.tbtnFileLinkClick(Sender: TObject);
begin
  MyExplore.OperFolder( edtFullPath.Text );
end;

end.
