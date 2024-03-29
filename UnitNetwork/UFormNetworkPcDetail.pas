unit UFormNetworkPcDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, UIconUtil, siComp;

type
  TfrmNetworkPcDetail = class(TForm)
    Panel1: TPanel;
    edtComputerName: TEdit;
    iPcStatus: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbComputerID: TLabel;
    lbReachable: TLabel;
    lbIp: TLabel;
    lbPort: TLabel;
    lbLastOnlineTime: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbTotalShace: TLabel;
    lbAvailableSpace: TLabel;
    lbCloudConsumpition: TLabel;
    lbUsedSpace: TLabel;
    lvMyBackup: TListView;
    siLang_frmNetworkPcDetail: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure siLang_frmNetworkPcDetailChangeLanguage(Sender: TObject);
  private
    procedure BindToolbar;
    procedure BindSort;
  public
    { Public declarations }
  end;

var
  frmNetworkPcDetail: TfrmNetworkPcDetail;

implementation

uses UMainForm, UFormUtil;

{$R *.dfm}

{ TfrmNetworkPcDetail }

procedure TfrmNetworkPcDetail.BindSort;
begin
  ListviewUtil.BindSort( lvMyBackup );
//  ListviewUtil.BindSort( lvBackupToMe );
end;

procedure TfrmNetworkPcDetail.BindToolbar;
begin
  lvMyBackup.SmallImages := MyIcon.getSysIcon;
//  lvBackupToMe.SmallImages := MyIcon.getSysIcon;
end;

procedure TfrmNetworkPcDetail.FormCreate(Sender: TObject);
var
  NewIcon : TIcon;
begin
  BindToolbar;
  BindSort;

  NewIcon := TIcon.Create;
  frmMainForm.ilTb24.GetIcon( 6, NewIcon );
  Icon := NewIcon;
  NewIcon.Free;

  siLang_frmNetworkPcDetailChangeLanguage( nil );
end;

procedure TfrmNetworkPcDetail.siLang_frmNetworkPcDetailChangeLanguage(
  Sender: TObject);
begin
  with lvMyBackup do
  begin
    Columns[0].Caption := siLang_frmNetworkPcDetail.GetText( 'lvBackupItem' );
    Columns[1].Caption := siLang_frmNetworkPcDetail.GetText( 'lvTotalSize' );
    Columns[2].Caption := siLang_frmNetworkPcDetail.GetText( 'lvBackupSize' );
    Columns[3].Caption := siLang_frmNetworkPcDetail.GetText( 'lvPercentage' );
  end;
end;

end.
