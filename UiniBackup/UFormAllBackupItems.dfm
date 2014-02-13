object frmAllBackupItems: TfrmAllBackupItems
  Left = 0
  Top = 0
  BorderWidth = 3
  Caption = 'Backup Items Properities'
  ClientHeight = 305
  ClientWidth = 457
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
  object Label1: TLabel
    Left = 11
    Top = 35
    Width = 23
    Height = 13
    Caption = 'Size:'
  end
  object Label2: TLabel
    Left = 11
    Top = 59
    Width = 41
    Height = 13
    Caption = 'Contain:'
  end
  object lbSize: TLabel
    Left = 82
    Top = 35
    Width = 27
    Height = 13
    Caption = 'lbSize'
  end
  object lbContains: TLabel
    Left = 82
    Top = 59
    Width = 50
    Height = 13
    Caption = 'lbContains'
  end
  object Label3: TLabel
    Left = 11
    Top = 10
    Width = 63
    Height = 13
    Caption = 'Items Count:'
  end
  object lbItemCount: TLabel
    Left = 82
    Top = 10
    Width = 59
    Height = 13
    Caption = 'lbItemCount'
  end
  object lbBackupCopy: TLabel
    Left = 194
    Top = 10
    Width = 88
    Height = 13
    Caption = 'Pre-set Copy Qty:'
  end
  object RzPageControl1: TRzPageControl
    Left = 0
    Top = 167
    Width = 457
    Height = 138
    ActivePage = tsSource
    Align = alBottom
    ShowShadow = False
    TabIndex = 0
    TabOrder = 0
    TabStyle = tsCutCorner
    ExplicitTop = 83
    ExplicitWidth = 456
    FixedDimension = 20
    object tsSource: TRzTabSheet
      Caption = 'Source'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lvBackupCopy: TListView
        Left = 0
        Top = 0
        Width = 455
        Height = 116
        Align = alClient
        Columns = <
          item
            AutoSize = True
            Caption = 'Item Path'
          end
          item
            Caption = 'Files'
            Tag = 2
            Width = 80
          end
          item
            Caption = 'Size'
            Tag = 1
            Width = 80
          end
          item
            Caption = 'Pre-set Copy Qty'
            Tag = 2
            Width = 100
          end>
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitTop = -38
        ExplicitWidth = 454
        ExplicitHeight = 154
      end
    end
    object tsDestination: TRzTabSheet
      Caption = 'Destination'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lvOwnerDetail: TListView
        Left = 0
        Top = 0
        Width = 455
        Height = 116
        Align = alClient
        Columns = <
          item
            AutoSize = True
            Caption = 'Location'
          end
          item
            Caption = 'Location Last Online'
            Width = 110
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
            Caption = 'Percentage'
            Tag = 3
            Width = 70
          end>
        ReadOnly = True
        RowSelect = True
        SmallImages = frmMainForm.ilNw16
        TabOrder = 0
        ViewStyle = vsReport
        ExplicitWidth = 454
        ExplicitHeight = 114
      end
    end
  end
  object spCopyCount: TSpinEdit
    Left = 284
    Top = 7
    Width = 60
    Height = 22
    Enabled = False
    MaxValue = 100
    MinValue = 1
    TabOrder = 1
    Value = 1
  end
  object btnOK: TButton
    Left = 356
    Top = 6
    Width = 53
    Height = 25
    Caption = 'Apply'
    Enabled = False
    TabOrder = 2
  end
end
