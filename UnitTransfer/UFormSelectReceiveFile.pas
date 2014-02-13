unit UFormSelectReceiveFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, UMyUtil;

type
  TfrmSelectReceive = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Image5: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Panel2: TPanel;
    btnRecevicePathBrowse: TButton;
    edtRecevicePath: TEdit;
    lbRecevicePath: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    lbFileName: TLabel;
    lbFileFrom: TLabel;
    lbFileSize: TLabel;
    lbIncludeFiles: TLabel;
    procedure btnRecevicePathBrowseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetFileInfo( FileName, FileFrom : string );
    procedure SetFileSpace( FileSize : Int64; FileCount : Integer );
    procedure SetReceivePath( ReceivePath : string );
  public
    function getReceivePath : string;
  end;

const
  FormTitle_ResetReceivePath : string = 'Select your receive path';

var
  frmSelectReceive: TfrmSelectReceive;

implementation

{$R *.dfm}

{ TfrmReceiveFile }

procedure TfrmSelectReceive.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectReceive.btnOKClick(Sender: TObject);
begin
  Close;
  ModalResult := mrOk;
end;

procedure TfrmSelectReceive.btnRecevicePathBrowseClick(Sender: TObject);
var
  ReceivePath : string;
begin
  if MySelectFolderDialog.Select( FormTitle_ResetReceivePath, edtRecevicePath.Text, ReceivePath, Self.Handle ) then
    edtRecevicePath.Text := ReceivePath;
end;

procedure TfrmSelectReceive.FormShow(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmSelectReceive.getReceivePath: string;
begin
  Result := edtRecevicePath.Text;
end;

procedure TfrmSelectReceive.SetFileInfo(FileName, FileFrom: string);
begin
  lbFileName.Caption := FileName;
  lbFileFrom.Caption := FileFrom;
end;

procedure TfrmSelectReceive.SetFileSpace(FileSize: Int64; FileCount: Integer);
begin
  lbFileSize.Caption := MySize.getFileSizeStr( FileSize );
  lbIncludeFiles.Caption := MyCount.getCountStr( FileCount );
end;

procedure TfrmSelectReceive.SetReceivePath(ReceivePath: string);
begin
  edtRecevicePath.Text := ReceivePath;
end;

end.
