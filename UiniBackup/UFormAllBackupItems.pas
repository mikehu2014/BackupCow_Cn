unit UFormAllBackupItems;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Spin, RzTabs;

type
  TfrmAllBackupItems = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lbSize: TLabel;
    lbContains: TLabel;
    Label3: TLabel;
    lbItemCount: TLabel;
    RzPageControl1: TRzPageControl;
    tsSource: TRzTabSheet;
    tsDestination: TRzTabSheet;
    lvOwnerDetail: TListView;
    lvBackupCopy: TListView;
    lbBackupCopy: TLabel;
    spCopyCount: TSpinEdit;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
  private
    procedure BindSort;
  public
    { Public declarations }
  end;

var
  frmAllBackupItems: TfrmAllBackupItems;

implementation

uses UMainForm, UFormUtil, UNetworkControl;

{$R *.dfm}

procedure TfrmAllBackupItems.BindSort;
begin
  ListviewUtil.BindSort( lvOwnerDetail );
end;

procedure TfrmAllBackupItems.FormCreate(Sender: TObject);
var
  NewIcon : TIcon;
begin
  NewIcon := TIcon.Create;
  frmMainForm.ilTbFs.GetIcon( 4, NewIcon );
  Icon := NewIcon;
  NewIcon.Free;

    // ≈≈–Ú
  BindSort;
end;

end.
