unit UFormSelectDes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TfrmSelectLocalBackupDes = class(TForm)
    LvSelectDestination: TListView;
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSelectLocalBackupDes: TfrmSelectLocalBackupDes;

implementation

{$R *.dfm}

end.
