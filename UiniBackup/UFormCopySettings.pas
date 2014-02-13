unit UFormCopySettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ComCtrls, UIconUtil, Math, UFormUtil;

type
  TfrmCopySetting = class(TForm)
    lvBackupCopy: TListView;
    lbBackupCopy: TLabel;
    btnOK: TButton;
    spCopyCount: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure lvBackupCopyChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvBackupCopyDeletion(Sender: TObject; Item: TListItem);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  LvBackupCopy_FileCount = 0;
  LvBackupCopy_Size = 1;
  LvBackupCopy_CopyCount = 2;

var
  frmCopySetting: TfrmCopySetting;

implementation

uses UBackupInfoFace, UBackupInfoControl;

{$R *.dfm}

procedure TfrmCopySetting.btnOKClick(Sender: TObject);
var
  CopyCount, i : Integer;
  ItemData : TLvBackupCopyData;
  FullPath : string;
begin
  CopyCount := spCopyCount.Value;

  for i := 0 to lvBackupCopy.Items.Count - 1 do
    if lvBackupCopy.Items[i].Selected then
    begin
      lvBackupCopy.Items[i].SubItems[ LvBackupCopy_CopyCount ] := IntToStr( CopyCount );
      ItemData := lvBackupCopy.Items[i].Data;
      FullPath := ItemData.FullPath;

      MyBackupFileControl.ReSetBackupCopyCount( FullPath, CopyCount );
    end;
end;

procedure TfrmCopySetting.FormCreate(Sender: TObject);
begin
  lvBackupCopy.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindSort( lvBackupCopy );
end;

procedure TfrmCopySetting.lvBackupCopyChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  IsSelected : Boolean;
  i, MinCount : Integer;
  ItemData : TLvBackupCopyData;
begin
  IsSelected := lvBackupCopy.Selected <> nil;

  lbBackupCopy.Enabled := IsSelected;
  spCopyCount.Enabled := IsSelected;
  btnOK.Enabled := IsSelected;

  if not IsSelected then
    Exit;

  MinCount := 1000;
  for i := 0 to lvBackupCopy.Items.Count - 1 do
    if lvBackupCopy.Items[i].Selected then
    begin
      ItemData := lvBackupCopy.Items[i].Data;
      MinCount := Min( ItemData.CopyCount, MinCount );
    end;

  spCopyCount.Value := MinCount;
end;

procedure TfrmCopySetting.lvBackupCopyDeletion(Sender: TObject;
  Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

end.


