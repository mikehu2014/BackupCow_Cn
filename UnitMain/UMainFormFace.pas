unit UMainFormFace;

interface

uses UChangeInfo;

type

{$Region ' Status Bar ������� ' }

    // ����
  TStatusBarChangeInfo = class( TChangeInfo )
  public
    ShowStr : string;
  public
    constructor Create( _ShowStr : string );
  end;

    // Backup Cow ģʽ
  TModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ����ģʽ
  TNetworkModeChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // �ϴ��ٶ�
  TUpSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // �����ٶ�
  TDownSpeedChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ͬ��ʱ��
  TSyncTimeChangeInfo = class( TStatusBarChangeInfo )
  private
    HintStr : string;
  public
    procedure SetHintStr( _HintStr : string );
    procedure Update;override;
  end;

    // �汾��
  TEditionChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

    // ���� ����״̬
  TNetStatusChangeInfo = class( TStatusBarChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' FreeEdition ������ʾ ' }

  TShowFreeEditionWarnning = class( TChangeInfo )
  public
    WarnningStr : string;
  public
    constructor Create( _WarnningStr : string );
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' TrayIcon ��ʾ '}

  TShowTrayHintStr = class( TChangeInfo )
  public
    TitleStr : string;
    ContentStr : string;
  public
    constructor Create( _TitleStr, _ContentStr : string );
    procedure Update;override;
  end;

{$EndRegion}

var
  MyMainFormFace : TMyChildFaceChange;

implementation

uses UMainForm, UFormFreeEdition;

{ TStatusBarChangeInfo }

constructor TStatusBarChangeInfo.Create(_ShowStr: string);
begin
  ShowStr := _ShowStr;
end;

{ TModeChangeInfo }

procedure TModeChangeInfo.Update;
begin
end;

{ TNetworkModeChangeInfo }

procedure TNetworkModeChangeInfo.Update;
begin
  frmMainForm.sbNetworkMode.Caption := ShowStr;
end;

{ TUpSpeedChangeInfo }

procedure TUpSpeedChangeInfo.Update;
begin
  frmMainForm.sbUpSpeed.Caption := ShowStr;
end;

{ TDownSpeedChangeInfo }

procedure TDownSpeedChangeInfo.Update;
begin
  frmMainForm.sbDownSpeed.Caption := ShowStr;
end;

{ TSyncTimeChangeInfo }

procedure TSyncTimeChangeInfo.SetHintStr(_HintStr: string);
begin
  HintStr := _HintStr;
end;

procedure TSyncTimeChangeInfo.Update;
begin

end;

{ TEditionChangeInfo }

procedure TEditionChangeInfo.Update;
begin
  frmMainForm.sbEdition.Caption := ShowStr;
end;

{ TNetStatusChangeInfo }

procedure TNetStatusChangeInfo.Update;
begin
  frmMainForm.sbMyStatus.Caption := ShowStr;
end;

{ TShowFreeEditionWarnning }

constructor TShowFreeEditionWarnning.Create(_WarnningStr: string);
begin
  WarnningStr := _WarnningStr;
end;

procedure TShowFreeEditionWarnning.Update;
begin
  frmFreeEdition.ShowWarnning( WarnningStr );
end;

{ TShowTrayHintStr }

constructor TShowTrayHintStr.Create(_TitleStr, _ContentStr: string);
begin
  TitleStr := _TitleStr;
  ContentStr := _ContentStr;
end;

procedure TShowTrayHintStr.Update;
begin
  with frmMainForm do
  begin
    tiApp.BalloonTitle := TitleStr;
    tiApp.BalloonHint := ContentStr;
    tiApp.ShowBalloonHint;
  end;
end;

end.
