object Form12: TForm12
  Left = 0
  Top = 0
  Caption = 'Form12'
  ClientHeight = 468
  ClientWidth = 674
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 448
    Top = 0
    Width = 226
    Height = 468
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 7
      Top = 96
      Width = 30
      Height = 13
      Caption = 'Lan Ip'
      Enabled = False
    end
    object Label2: TLabel
      Left = 7
      Top = 123
      Width = 40
      Height = 13
      Caption = 'Lan Port'
      Enabled = False
    end
    object Label3: TLabel
      Left = 7
      Top = 150
      Width = 63
      Height = 13
      Caption = 'Internet Port'
      Enabled = False
    end
    object Start: TButton
      Left = 22
      Top = 232
      Width = 75
      Height = 25
      Caption = 'Start'
      Enabled = False
      TabOrder = 0
      OnClick = StartClick
    end
    object edtLanIp: TEdit
      Left = 76
      Top = 93
      Width = 121
      Height = 21
      Enabled = False
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      TabOrder = 1
      Text = '192.168.1.99'
    end
    object edtLanPort: TEdit
      Left = 76
      Top = 120
      Width = 121
      Height = 21
      Enabled = False
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      TabOrder = 2
      Text = '8596'
    end
    object edtInternetIp: TEdit
      Left = 76
      Top = 147
      Width = 121
      Height = 21
      Enabled = False
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      TabOrder = 3
      Text = '23661'
    end
    object btnAddMap: TButton
      Left = 22
      Top = 190
      Width = 75
      Height = 25
      Caption = 'Add Map'
      Enabled = False
      TabOrder = 4
      OnClick = btnAddMapClick
    end
    object btnRemoveMap: TButton
      Left = 118
      Top = 190
      Width = 75
      Height = 25
      Caption = 'Remove Map'
      Enabled = False
      TabOrder = 5
      OnClick = btnRemoveMapClick
    end
    object btnClear: TButton
      Left = 120
      Top = 232
      Width = 75
      Height = 25
      Caption = 'Clear'
      Enabled = False
      TabOrder = 6
      OnClick = btnClearClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 448
    Height = 468
    Align = alClient
    ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
    ScrollBars = ssBoth
    TabOrder = 1
  end
end
