object frmJoinGroup: TfrmJoinGroup
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 3
  Caption = #12493#12483#12488#12527#12540#12463#12464#12523#12540#12503#12395#21442#21152#12375#12390
  ClientHeight = 191
  ClientWidth = 339
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000262626004F4C4C00595353005D5C5C0077626200707070007C7C7C008359
    5900826E6E0096676600B8797400EEA14500FFBE4C00D3816700DD9B7400E7B0
    6D00FFC85D002E75B40045B1E800848080008F8F8F0094949400A9878700BA99
    9800B6A5A500BCBBB800CD949400C4989800D6A28300D2A39900D9BD9200C1A3
    A100CEA4A400D3ABA900D8BDA400C9BCB800D2B7B600D0BDBD00FFDB8200FFDD
    8800FFE29300F3DFA000FFECA400FFEFAB00CDC2C200EBE1E100ECECEC000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    1414141400000000001414141400001419190506140000001419190506141425
    2020180914000014252020180914142F2E261C17000000142F2E261C17000014
    221B0B03000000001E221B0B0400250F0C100F0A040404040F0C100F0807211F
    0D11110E011212011F0D11110E0621232729280F15131314232729280F062123
    2A2C2B10002D0121232A2C2B101621212121211D00240121212121211D000000
    00000000061A01020606000000000000000000250F0C100F0807000000000000
    000000211F0D11110E0600000000000000000021232729280F06000000000000
    00000021232A2C2B101600000000000000000021212121211D0000000000C3E1
    000081C00000018000000381000083C100000000000000000000000000000200
    000002010000FC0F0000F80F0000F80F0000F80F0000F80F0000F81F0000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PcMain: TRzPageControl
    Left = 0
    Top = 0
    Width = 339
    Height = 191
    ActivePage = tsSignupGroup
    Align = alClient
    BoldCurrentTab = True
    ShowFocusRect = False
    ShowShadow = False
    TabIndex = 1
    TabOrder = 0
    TabStyle = tsRoundCorners
    FixedDimension = 19
    object tsJoinGroup: TRzTabSheet
      Caption = #12493#12483#12488#12527#12540#12463#12464#12523#12540#12503#12395#21442#21152#12375#12390
      object Label1: TLabel
        Left = 14
        Top = 64
        Width = 60
        Height = 13
        Caption = #12464#12523#12540#12503#21517
      end
      object Label2: TLabel
        Left = 14
        Top = 90
        Width = 60
        Height = 13
        Caption = #12497#12473#12527#12540#12489
      end
      object Label3: TLabel
        Left = 71
        Top = 14
        Width = 187
        Height = 45
        Caption = #21516#12376#12464#12523#12540#12503#20869#12398#12467#12531#12500#12517#12540#12479#12493#12483#12488#12527#12540#12463#21161#12369#21512#12387#12390#12496#12483#12463#12450#12483#12503#12501#12449#12452#12523
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = '@Arial Unicode MS'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object Image1: TImage
        Left = 23
        Top = 13
        Width = 32
        Height = 32
        Picture.Data = {
          055449636F6E0000010001002020000001000800A80800001600000028000000
          2000000040000000010008000000000000040000000000000000000000010000
          0001000000000000262626004F4C4C005953530065595500646464006C6A6A00
          7762620070707000767575007C7C7C0083595900826E6E00B8797400C76A6A00
          FEA82100FFB13000FCB44300FFBA4200FFBE4C00D3816700DD9B7400E7B06D00
          EFBC7300FFC45600FFC85D00FFCB6500FFD06E00FFD474002E75B40045B1E800
          84808000888888008F8F8F009C8A8A0099999900A9878700B9908E00AA979400
          BA999800BCBBB800C48D8D00C4989800CB9D9D00C8A78C00E9BF9900C1A3A100
          CEA4A400C7AAAA00CCAEAE00C9BCB800D1B1B100D2B7B600D6BFB200D0BDBD00
          DCC59400FACB8400FFDB8200FFDD8800FFE29300FFE69A00D6CBAB00F3DFA000
          FFECA400FFEFAB00FFF2B300A2D4FB00CDC2C200D0C7C700D6CDCD00D0D0D000
          DED7D700E1E1E100E6E6E600E9E9E900FFF0E100F9F9F9000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000021212121210000000000000000000000000000000A0A0A0A
          0A0000000000050505050507051F000000000000000000000000050505050505
          051F00000005302E2E2E2E2A25040A0000000000000000000005302E2E2E2E2A
          25040A0036454A4A48344622272A0900000000000000000036454A4A48344622
          272A090036454C4C483334242A2B2300000000000000000036454C4C48333424
          2A2B23000036362F472F290D2926000000000000000000000036362F472F290D
          2926000000002F1515150E0E0B0000000000000A0A0A210000002B1515150E0E
          0B00000000002A0F0F1115290E030A0A0A091D021D1D0A0A0A0A2A0F0F111515
          0E031F0000442D10121212131615030101011D1E1E1D010101022D1012121213
          1615090000441713181919181315012343321E42421D28432301171318191918
          13150800002F381A1A1B1B1A1A150C2323231E1E1E1E2323232F381A1A1B1B1A
          1A150800002F171B393A3A3A1C150900000000234B010A00002F171B393A3A3A
          1C150900342F1B3A3C3F3F3B3A150800000000234B010A00342F1B3A3C3F3F3B
          3A150800332F373B404141403B150900000000234B010A00332F373B3F414140
          3B150900342F2F2F34353D3E3C1523000000000001230000342F2F2F32353D3E
          3C1523000000000033333131302E000000000000010800000000000031313131
          302E000000000000000000000000000000050505050505051F00000000000000
          0000000000000000000000000000000005302E2E2E2E2E25040A000000000000
          00000000000000000000000000000036454A4A48344522272A09000000000000
          0000000000000000000000000000003645364C483334242A2B23000000000000
          0000000000000000000000000000000036362F472F290D292500000000000000
          00000000000000000000000000000000002F1515140E0E0B0000000000000000
          00000000000000000000000000000000002C0F0F1115150E0321000000000000
          000000000000000000000000000000002F2D1012121213161508000000000000
          000000000000000000000000000000002F171318191918131508000000000000
          000000000000000000000000000000002F381A1A1B1B1A1A1509000000000000
          000000000000000000000000000000002F171B393A3A3A1C1508000000000000
          000000000000000000000000000000312F1B3A3C3F3F3B3A1508000000000000
          000000000000000000000000000000312F373B404141403B1509000000000000
          000000000000000000000000000000312F2F2F32353D3E3C1523000000000000
          0000000000000000000000000000000000000031313131302E00000000000000
          00000000FFFFFFFFF07FFF07C03FFC03801FF801001FF001001FF001803FF803
          C07E1C07C0000001800000018000000180000001801E1801001E1001001E1001
          001F3001F03F3F03FFF807FFFFF003FFFFE003FFFFE003FFFFF007FFFFF80FFF
          FFF803FFFFF003FFFFF003FFFFF003FFFFF003FFFFE003FFFFE003FFFFE003FF
          FFFE07FF}
      end
      object edtGroupName: TEdit
        Left = 77
        Top = 61
        Width = 164
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 0
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtPassword: TEdit
        Left = 77
        Top = 90
        Width = 164
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 1
        OnKeyUp = edtPasswordKeyUp
      end
      object btnOK: TButton
        Left = 77
        Top = 125
        Width = 75
        Height = 25
        Caption = #30906#35469
        TabOrder = 2
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 162
        Top = 125
        Width = 75
        Height = 25
        Caption = #12461#12515#12531#12475#12523
        TabOrder = 3
        OnClick = btnCancelClick
      end
      object lkCreateGroup: TLinkLabel
        Left = 249
        Top = 64
        Width = 160
        Height = 17
        Caption = '<a>'#12493#12483#12488#12527#12540#12463#12464#12523#12540#12503#12398#20316#25104'</a>'
        TabOrder = 4
        OnLinkClick = lkCreateGroupLinkClick
      end
      object LinkLabel1: TLinkLabel
        Left = 249
        Top = 90
        Width = 100
        Height = 17
        Caption = '<a>'#12497#12473#12527#12540#12489#12434#24536#12428'</a>'
        TabOrder = 5
        OnLinkClick = LinkLabel1LinkClick
      end
      object LinkLabel2: TLinkLabel
        Left = 249
        Top = 129
        Width = 64
        Height = 17
        Caption = '<a>'#12418#12387#12392#24773#22577'</a>'
        TabOrder = 6
        OnLinkClick = LinkLabel2LinkClick
      end
    end
    object tsSignupGroup: TRzTabSheet
      Caption = #12493#12483#12488#12527#12540#12463#12464#12523#12540#12503#30331#37682
      ExplicitTop = 25
      ExplicitHeight = 165
      object Label4: TLabel
        Left = 14
        Top = 24
        Width = 60
        Height = 13
        Caption = #12464#12523#12540#12503#21517
      end
      object Label5: TLabel
        Left = 14
        Top = 50
        Width = 84
        Height = 13
        Caption = #12513#12540#12523#12450#12489#12524#12473
      end
      object Label6: TLabel
        Left = 14
        Top = 77
        Width = 60
        Height = 13
        Caption = #12497#12473#12527#12540#12489
      end
      object Label7: TLabel
        Left = 14
        Top = 107
        Width = 96
        Height = 13
        Caption = #12497#12473#12527#12540#12489#12398#30906#35469
      end
      object edtSignName: TEdit
        Left = 102
        Top = 21
        Width = 203
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 0
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtSignEmail: TEdit
        Left = 102
        Top = 50
        Width = 203
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        TabOrder = 1
        OnKeyUp = edtGroupNameKeyUp
      end
      object btnSignOK: TButton
        Left = 88
        Top = 136
        Width = 75
        Height = 25
        Caption = #30331#37682
        TabOrder = 4
        OnClick = btnSignOKClick
      end
      object btnSignCancel: TButton
        Left = 191
        Top = 136
        Width = 75
        Height = 25
        Caption = #12461#12515#12531#12475#12523
        TabOrder = 5
        OnClick = btnCancelClick
      end
      object edtSignPassword: TEdit
        Left = 102
        Top = 77
        Width = 203
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 2
        OnKeyUp = edtGroupNameKeyUp
      end
      object edtSignPassword2: TEdit
        Left = 102
        Top = 104
        Width = 203
        Height = 21
        ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
        PasswordChar = '*'
        TabOrder = 3
        OnKeyUp = edtSignPassword2KeyUp
      end
    end
  end
  object siLang_frmJoinGroup: TsiLang
    Version = '6.5.2'
    StringsTypes.Strings = (
      'TIB_STRINGLIST'
      'TSTRINGLIST')
    DefaultLanguage = 2
    NumOfLanguages = 3
    ActiveLanguage = 3
    LangDispatcher = frmMainForm.siLangDispatcherMain
    LangDelim = 1
    LangNames.Strings = (
      'English'
      'Chinese'
      'Japanese')
    Language = 'Japanese'
    ExcludedProperties.Strings = (
      'Category'
      'SecondaryShortCuts'
      'HelpKeyword'
      'InitialDir'
      'HelpKeyword'
      'ActivePage'
      'ImeName'
      'DefaultExt'
      'FileName'
      'FieldName'
      'PickList'
      'DisplayFormat'
      'EditMask'
      'KeyList'
      'LookupDisplayFields'
      'DropDownSpecRow'
      'TableName'
      'DatabaseName'
      'IndexName'
      'MasterFields'
      'SQL'
      'DeleteSQL'
      'UpdateSQL'
      'ModifySQL'
      'KeyFields'
      'LookupKeyFields'
      'LookupResultField'
      'DataField'
      'KeyField'
      'ListField')
    Left = 160
    Top = 96
    TranslationData = {
      73007400430061007000740069006F006E0073005F0055006E00690063006F00
      640065000D000A005400660072006D004A006F0069006E00470072006F007500
      700001004A006F0069006E00200061002000470072006F00750070000100A052
      6551517FDC7EC47E0100CD30C330C830EF30FC30AF30B030EB30FC30D7306B30
      C253A0525730663001000D000A00620074006E00430061006E00630065006C00
      0100430061006E00630065006C000100D653886D0100AD30E330F330BB30EB30
      01000D000A00620074006E004F004B0001004F004B0001006E78A48B0100BA78
      8D8A01000D000A00620074006E005300690067006E00430061006E0063006500
      6C000100430061006E00630065006C000100D653886D0100AD30E330F330BB30
      EB3001000D000A00620074006E005300690067006E004F004B00010053006900
      67006E002000550070000100E86C8C5101007B76329301000D000A004C006100
      620065006C0031000100470072006F007500700020004E0061006D0065000100
      C47E0D540100B030EB30FC30D7300D5401000D000A004C006100620065006C00
      32000100500061007300730077006F00720064000100C65B01780100D130B930
      EF30FC30C93001000D000A004C006100620065006C003300010043006F006D00
      7000750074006500720073002000630061006E00200063006F006E006E006500
      63007400200074006F0067006500740068006500720020006200790020006A00
      6F0069006E0069006E006700200061002000730061006D006500200067007200
      6F00750070002E00010028570C54004E2A4E517FDC7EC47E85518476A18B977B
      3A67FD801F59924EF8760759FD4E8765F64E01000C545830B030EB30FC30D730
      85516E30B330F330D430E530FC30BF30CD30C330C830EF30FC30AF30A9525130
      085463306630D030C330AF30A230C330D730D530A130A430EB3001000D000A00
      4C006100620065006C0034000100470072006F007500700020004E0061006D00
      65000100C47E0D540100B030EB30FC30D7300D5401000D000A004C0061006200
      65006C003500010045006D00610069006C0001003575505BAE90F64E30574057
      0100E130FC30EB30A230C930EC30B93001000D000A004C006100620065006C00
      36000100500061007300730077006F00720064000100C65B01780100D130B930
      EF30FC30C93001000D000A004C006100620065006C0037000100520065007400
      7900700065002000500061007300730077006F00720064000100C65B01786E78
      A48B0100D130B930EF30FC30C9306E30BA788D8A01000D000A004C0069006E00
      6B004C006100620065006C00310001003C0061003E0046006F00720067006500
      74002000700061007300730077006F00720064003C002F0061003E0001003C00
      61003E00D85FB08BC65B01783C002F0061003E0001003C0061003E00D130B930
      EF30FC30C9309230D85F8C303C002F0061003E0001000D000A004C0069006E00
      6B004C006100620065006C00320001003C0061003E004D006F00720065002000
      49006E0066006F006D006100740069006F006E003C002F0061003E0001003C00
      61003E00F4661A59E14F6F603C002F0061003E0001003C0061003E0082306330
      6830C56031583C002F0061003E0001000D000A006C006B004300720065006100
      74006500470072006F007500700001003C0061003E0043007200650061007400
      6500200061002000670072006F00750070003C002F0061003E0001003C006100
      3E001B52FA5E517FDC7EC47E3C002F0061003E0001003C0061003E00CD30C330
      C830EF30FC30AF30B030EB30FC30D7306E305C4F10623C002F0061003E000100
      0D000A00740073004A006F0069006E00470072006F007500700001004A006F00
      69006E00200061002000470072006F00750070000100A0526551517FDC7EC47E
      0100CD30C330C830EF30FC30AF30B030EB30FC30D7306B30C253A05257306630
      01000D000A00740073005300690067006E0075007000470072006F0075007000
      01005300690067006E00200055007000200061002000470072006F0075007000
      0100E86C8C51004E2A4E517FDC7EC47E0100CD30C330C830EF30FC30AF30B030
      EB30FC30D7307B76329301000D000A0073007400480069006E00740073005F00
      55006E00690063006F00640065000D000A007300740044006900730070006C00
      610079004C006100620065006C0073005F0055006E00690063006F0064006500
      0D000A007300740046006F006E00740073005F0055006E00690063006F006400
      65000D000A005400660072006D004A006F0069006E00470072006F0075007000
      01005400610068006F006D00610001005400610068006F006D00610001004000
      41007200690061006C00200055006E00690063006F006400650020004D005300
      01000D000A004C006100620065006C00330001005400610068006F006D006100
      01005400610068006F006D0061000100400041007200690061006C0020005500
      6E00690063006F006400650020004D00530001000D000A00730074004D007500
      6C00740069004C0069006E00650073005F0055006E00690063006F0064006500
      0D000A007300740044006C0067007300430061007000740069006F006E007300
      5F0055006E00690063006F00640065000D000A005700610072006E0069006E00
      670001005700610072006E0069006E0067000100010001000D000A0045007200
      72006F00720001004500720072006F0072000100010001000D000A0049006E00
      66006F0072006D006100740069006F006E00010049006E0066006F0072006D00
      6100740069006F006E000100010001000D000A0043006F006E00660069007200
      6D00010043006F006E006600690072006D000100010001000D000A0059006500
      7300010026005900650073000100010001000D000A004E006F00010026004E00
      6F000100010001000D000A004F004B0001004F004B000100010001000D000A00
      430061006E00630065006C000100430061006E00630065006C00010001000100
      0D000A00410062006F007200740001002600410062006F007200740001000100
      01000D000A005200650074007200790001002600520065007400720079000100
      010001000D000A00490067006E006F007200650001002600490067006E006F00
      720065000100010001000D000A0041006C006C000100260041006C006C000100
      010001000D000A004E006F00200054006F00200041006C006C0001004E002600
      6F00200074006F00200041006C006C000100010001000D000A00590065007300
      200054006F00200041006C006C000100590065007300200074006F0020002600
      41006C006C000100010001000D000A00480065006C0070000100260048006500
      6C0070000100010001000D000A007300740053007400720069006E0067007300
      5F0055006E00690063006F00640065000D000A00730074004F00740068006500
      720053007400720069006E00670073005F0055006E00690063006F0064006500
      0D000A00730074004C006F00630061006C00650073005F0055006E0069006300
      6F00640065000D000A007300740043006F006C006C0065006300740069006F00
      6E0073005F0055006E00690063006F00640065000D000A007300740043006800
      6100720053006500740073005F0055006E00690063006F00640065000D000A00
      5400660072006D004A006F0069006E00470072006F0075007000010044004500
      4600410055004C0054005F004300480041005200530045005400010047004200
      32003300310032005F0043004800410052005300450054000100530048004900
      460054004A00490053005F00430048004100520053004500540001000D000A00
      4C006100620065006C0033000100440045004600410055004C0054005F004300
      48004100520053004500540001004700420032003300310032005F0043004800
      410052005300450054000100530048004900460054004A00490053005F004300
      48004100520053004500540001000D000A00}
  end
end