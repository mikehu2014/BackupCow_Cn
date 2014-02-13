object frmSelectLocalBackupDes: TfrmSelectLocalBackupDes
  Left = 0
  Top = 0
  Caption = 'Select Destinations'
  ClientHeight = 301
  ClientWidth = 398
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object LvSelectDestination: TListView
    Left = 0
    Top = 41
    Width = 398
    Height = 219
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Directory'
      end
      item
        Caption = 'Available Space'
        Width = 100
      end>
    TabOrder = 0
    ViewStyle = vsReport
    ExplicitTop = 44
  end
  object Panel1: TPanel
    Left = 0
    Top = 260
    Width = 398
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 344
    ExplicitTop = 168
    ExplicitWidth = 185
    object btnOK: TButton
      Left = 233
      Top = 9
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 317
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 398
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Select your destination folders'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    ExplicitLeft = 232
    ExplicitTop = 152
    ExplicitWidth = 185
  end
end
