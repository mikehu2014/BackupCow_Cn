unit UFormBackupProgress;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, UIconUtil, UFormUtil;

type
  TfrmBackupProgress = class(TForm)
    lvBackupProgress: TListView;
    lvTotal: TListView;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBackupProgress: TfrmBackupProgress;

implementation

uses UMainForm;

{$R *.dfm}

procedure TfrmBackupProgress.FormCreate(Sender: TObject);
var
  NewIcon : TIcon;
begin
  NewIcon := TIcon.Create;
  frmMainForm.ilTbFs.GetIcon( 4, NewIcon );
  Icon := NewIcon;
  NewIcon.Free;

  lvBackupProgress.SmallImages := MyIcon.getSysIcon;

  ListviewUtil.BindSort( lvBackupProgress );
end;

end.
