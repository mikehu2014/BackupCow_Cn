object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Form3'
  ClientHeight = 282
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 0
    Top = 41
    Width = 386
    Height = 200
    Align = alClient
    Columns = <>
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 72
    ExplicitWidth = 250
    ExplicitHeight = 150
  end
  object Panel1: TPanel
    Left = 0
    Top = 241
    Width = 386
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 104
    ExplicitTop = 168
    ExplicitWidth = 185
    object btnSelectAll: TButton
      Left = 56
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Select All'
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 150
      Top = 9
      Width = 75
      Height = 25
      Caption = 'OK'
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 240
      Top = 9
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 386
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Select backup items to apply'
    TabOrder = 2
    ExplicitLeft = 88
    ExplicitTop = 96
    ExplicitWidth = 185
  end
end
