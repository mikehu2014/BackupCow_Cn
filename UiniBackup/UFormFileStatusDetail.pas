unit UFormFileStatusDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,ComCtrls, SyncObjs, UMyUtil, UIconUtil,
  ImgList, ExtCtrls, ToolWin, RzButton, UFormUtil, UMainForm, siComp;

type


  TfrmFileStatusDetail = class(TForm)
    lvFileOwners: TListView;
    lb2: TLabel;
    lb4: TLabel;
    lbFileCount: TLabel;
    lb6: TLabel;
    lbFileStatus: TLabel;
    Panel1: TPanel;
    lbFileSize: TLabel;
    edtFullPath: TEdit;
    tbFileLink: TToolBar;
    tbtnFileLink: TToolButton;
    siLang_frmFileStatusDetail: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure tbtnFileLinkClick(Sender: TObject);
    procedure siLang_frmFileStatusDetailChangeLanguage(Sender: TObject);
  private
    procedure BindSort;
  public
    { Public declarations }
  end;

const
  PcStatus_Online : string = 'Online';
  Icon_PcOnline : Integer = 0;
  Icon_PcOffline : Integer = 1;

  ShowFileStatus_UpPend : string = 'UpPend';
  ShowFileStatus_UpLoading : string = 'UpLoading';
  ShowFileStatus_UpLoaded : string = 'UpLoaded';

  LvFileOwner_OwnerID : Integer = 0;
  LvFileOwner_OwnerLastOnline : Integer = 1;
  LvFileOwner_FileStatus : Integer = 2;

var
  frmFileStatusDetail: TfrmFileStatusDetail;
implementation

{$R *.dfm}

procedure TfrmFileStatusDetail.tbtnFileLinkClick(Sender: TObject);
begin
  MyExplore.OperFolder( edtFullPath.Text );
end;

procedure TfrmFileStatusDetail.BindSort;
begin
  ListviewUtil.BindSort( lvFileOwners );
end;

procedure TfrmFileStatusDetail.FormCreate(Sender: TObject);
var
  NewIcon : TIcon;
begin
  tbFileLink.Images := MyIcon.getSysIcon32;
  BindSort;

  NewIcon := TIcon.Create;
  frmMainForm.ilTb24.GetIcon( 6, NewIcon );
  Icon := NewIcon;
  NewIcon.Free;

  siLang_frmFileStatusDetailChangeLanguage( nil );
end;

procedure TfrmFileStatusDetail.siLang_frmFileStatusDetailChangeLanguage(
  Sender: TObject);
begin
  with lvFileOwners do
  begin
    Columns[ LvFileOwner_OwnerID ].Caption := siLang_frmFileStatusDetail.GetText( 'lvLocation' );
    Columns[ LvFileOwner_OwnerLastOnline ].Caption := siLang_frmFileStatusDetail.GetText( 'lvLastOnline' );
    Columns[ LvFileOwner_FileStatus ].Caption := siLang_frmFileStatusDetail.GetText( 'lvFileStatus' );
  end;
end;

end.
