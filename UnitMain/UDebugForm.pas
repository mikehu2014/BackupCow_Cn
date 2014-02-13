unit UDebugForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UPortMap, ExtCtrls, UChangeInfo;

type
  TForm12 = class(TForm)
    Panel1: TPanel;
    Start: TButton;
    edtLanIp: TEdit;
    edtLanPort: TEdit;
    edtInternetIp: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnAddMap: TButton;
    btnRemoveMap: TButton;
    btnClear: TButton;
    Memo1: TMemo;
    procedure StartClick(Sender: TObject);
    procedure btnAddMapClick(Sender: TObject);
    procedure btnRemoveMapClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TWriteLog = class( TChangeInfo )
  public
    s : string;
  public
    constructor Create(_s : string);
    procedure Update;override;
  end;

var
  Form12: TForm12;

implementation

{$R *.dfm}

procedure TForm12.btnAddMapClick(Sender: TObject);
begin
//  PortMapping.AddMapping( edtLanIp.Text, edtLanPort.Text, edtInternetIp.Text );
end;

procedure TForm12.btnClearClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm12.btnRemoveMapClick(Sender: TObject);
begin
//  PortMapping.RemoveMapping( edtInternetIp.Text );
end;

procedure TForm12.StartClick(Sender: TObject);
begin
  btnAddMap.Enabled := True;
  btnRemoveMap.Enabled := True;

//  PortMapping := TPortMapping.Create;
end;

{ TWriteLog }

constructor TWriteLog.Create(_s: string);
begin
  s := _s;
end;

procedure TWriteLog.Update;
begin
//  Form12.Memo1.Lines.Add( s );
end;

end.
