object frmBackupItemDetail: TfrmBackupItemDetail
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = 'test Properties'
  ClientHeight = 294
  ClientWidth = 461
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 15
    Top = 64
    Width = 23
    Height = 13
    Caption = 'Size:'
  end
  object Label2: TLabel
    Left = 15
    Top = 93
    Width = 41
    Height = 13
    Caption = 'Contain:'
  end
  object Label3: TLabel
    Left = 15
    Top = 120
    Width = 35
    Height = 13
    Caption = 'Status:'
  end
  object lbSize: TLabel
    Left = 70
    Top = 64
    Width = 27
    Height = 13
    Caption = 'lbSize'
  end
  object lbContains: TLabel
    Left = 70
    Top = 93
    Width = 50
    Height = 13
    Caption = 'lbContains'
  end
  object lbStatus: TLabel
    Left = 70
    Top = 120
    Width = 39
    Height = 13
    Caption = 'lbStatus'
  end
  object lvOwnerDetail: TListView
    Left = 0
    Top = 144
    Width = 461
    Height = 150
    Align = alBottom
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
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 461
    Height = 49
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkSoft
    BevelOuter = bvNone
    TabOrder = 1
    object edtFullPath: TEdit
      Left = 55
      Top = 11
      Width = 381
      Height = 21
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      ReadOnly = True
      TabOrder = 0
    end
    object tbFileLink: TToolBar
      Left = 8
      Top = 5
      Width = 40
      Height = 40
      Align = alNone
      ButtonHeight = 32
      ButtonWidth = 32
      Caption = 'tbFileLink'
      Images = frmMainForm.ilFsTv
      TabOrder = 1
      object tbtnFileLink: TToolButton
        Left = 0
        Top = 0
        Caption = 'tbtnFileLink'
        ImageIndex = 0
        OnClick = tbtnFileLinkClick
      end
    end
  end
end
