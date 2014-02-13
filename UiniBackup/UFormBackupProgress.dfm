object frmBackupProgress: TfrmBackupProgress
  Left = 0
  Top = 0
  BorderWidth = 3
  Caption = 'Backup Progress'
  ClientHeight = 253
  ClientWidth = 613
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvBackupProgress: TListView
    Left = 0
    Top = 0
    Width = 613
    Height = 187
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Item Path'
      end
      item
        Caption = 'Pre-set Copy Qty'
        Tag = 2
        Width = 100
      end
      item
        Caption = 'Files'
        Tag = 2
        Width = 70
      end
      item
        Caption = 'Size'
        Tag = 1
        Width = 70
      end
      item
        Caption = 'Completed'
        Width = 70
      end
      item
        Caption = 'Remain Files'
        Tag = 2
        Width = 80
      end
      item
        Caption = 'Remain Size'
        Tag = 1
        Width = 80
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    ExplicitWidth = 595
    ExplicitHeight = 184
  end
  object lvTotal: TListView
    Left = 0
    Top = 187
    Width = 613
    Height = 66
    Align = alBottom
    Columns = <
      item
        AutoSize = True
        Caption = 'Item Path'
      end
      item
        Caption = 'Pre-set Copy Qty'
        Width = 100
      end
      item
        Caption = 'Files'
        Width = 70
      end
      item
        Caption = 'Size'
        Width = 70
      end
      item
        Caption = 'Completed'
        Width = 70
      end
      item
        Caption = 'Remain Files'
        Width = 80
      end
      item
        Caption = 'Remain Size'
        Width = 80
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    ExplicitTop = 184
    ExplicitWidth = 595
  end
end
