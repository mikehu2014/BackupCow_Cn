unit UFormConnPc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzTabs, StdCtrls, ExtCtrls, siComp, UMainForm;

type
  TfrmConnComputer = class(TForm)
    pcMain: TRzPageControl;
    tsConnToOther: TRzTabSheet;
    tsConnByOther: TRzTabSheet;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    edtIp: TEdit;
    Label3: TLabel;
    edtPort: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    edtLanIp: TEdit;
    Label4: TLabel;
    Label6: TLabel;
    edtLanPort: TEdit;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    edtInternetIp: TEdit;
    Label7: TLabel;
    edtInternetPort: TEdit;
    siLang_frmConnComputer: TsiLang;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure edtIpKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtPortKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    procedure ShowConnToPc;
    procedure ShowDnsError( Ip, Port : string );
  end;

var
  DefaultPort_ConnPc : string = '9595';

var
  frmConnComputer: TfrmConnComputer;

implementation

uses UFormSetting, UNetworkControl, UMyUtil;

{$R *.dfm}

procedure TfrmConnComputer.btnCancelClick(Sender: TObject);
begin
  Close
end;

procedure TfrmConnComputer.btnOKClick(Sender: TObject);
var
  Ip, Port : string;
  ErrorStr : string;
  AdvanceNetworkConnHandle : TAdvanceNetworkConnHandle;
begin
  Ip := edtIp.Text;
  Port := edtPort.Text;

    // 输入信息 不能为空
  ErrorStr := '';
  if Ip = '' then
    ErrorStr := frmSetting.siLang_frmSetting.GetText( 'InputDomain' )
  else
  if Port = '' then
    ErrorStr := frmSetting.siLang_frmSetting.GetText( 'InputPassword' );

    // 出错
  if ErrorStr <> '' then
  begin
    MyMessageBox.ShowError( Self.Handle, ErrorStr );
    Exit;
  end;

    // 添加 并 选择
  AdvanceNetworkConnHandle := TAdvanceNetworkConnHandle.Create( ip, Port );
  AdvanceNetworkConnHandle.Update;
  AdvanceNetworkConnHandle.Free;

  Close;
end;

procedure TfrmConnComputer.ShowConnToPc;
begin
  edtIp.Clear;
  edtPort.Text := DefaultPort_ConnPc;
  Show;
end;

procedure TfrmConnComputer.ShowDnsError( Ip, Port : string );
begin
  edtIp.Text := Ip;
  edtPort.Text := Port;
  Show;
end;

procedure TfrmConnComputer.edtIpKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    selectnext(twincontrol(sender),true,true);
end;

procedure TfrmConnComputer.edtPortKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    btnOK.Click;
end;

procedure TfrmConnComputer.FormShow(Sender: TObject);
begin
  edtLanIp.Text := frmSetting.cbbIP.Text;
  edtLanPort.Text := frmSetting.edtPort.Text;
  edtInternetIp.Text := frmSetting.edtInternetIp.Text;
  edtInternetPort.Text := frmSetting.edtInternetPort.Text;

  pcMain.ActivePage := tsConnToOther;
end;

end.
