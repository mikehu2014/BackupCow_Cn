object FrmEnterMask: TFrmEnterMask
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 5
  Caption = #28670#36942#26465#20214#20837#21147
  ClientHeight = 146
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = SHIFTJIS_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001000800680500001600000028000000100000002000
    0000010008000000000000010000000000000000000000010000000100000000
    0000AE5B1200BF6B1500B4641B00B9671900BC6B1D00B5692200C2701A00C170
    2100C4752400C9772100CC7D2500C97D2900CE7F290099664400CF852B00CD83
    2D00D3872E00DA942500DE9D2B00DF9E2E00CB893500CD8E3B00D38A3100D78B
    3100DA8F3100DC943600D8943800DB993D00DD983D00DFA02F00E0A03200E1A2
    3500E0A53900B79C7300B9A07900C38A4300CF924100CA984F00D2974700D59B
    4A00DCA34A00D9A15000DBA55500DCA65700D8A45A00E3AC4300E4AC4400E1AC
    4C00E6AE4E00E6B14B00E8B24F00E4AE5300E5B05100E9B75600EABB5C00EBBC
    5F00ECBD5E00C3A06200CEA76A00DAA86200D3B37700D2B37E00E2B16300ECBE
    6200E5B97200EDC06400EFC36800EFC56A00EEC56C00F0C66B00F0C66D00F1C9
    6F00E9C17700F2CB7100F2CE7F00D0B78D00DAC29700D5C09E00F4D48A00E4D2
    A400E8D6AC00F5DFAD00F6E3B400F5E4BD00E6DDC700ECE0C900EEE3D000EEE6
    D300F1E7D300F3E8D200F2EEE300F6F0E400F9F0E000FEFFFF00000000000000
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
    00000000060300000000000000000000000000001512010E0000000000000000
    00000000161E0204000000000000000000000000252107050000000000000000
    00000000272F0A0800000000000000000000000028320B080000000000000000
    000000002A360F0C0000000000000000000000002A3917100000000000000000
    0000000049381C0C00000000000000000000003E453834112400000000000000
    0000414B4745421C181B000000000000003B4F4A48474731181A260000000000
    3F5253545A5957573C2D2A29000000235D5E5C5B585150554D3D4C4E22000035
    2F1313131F1F1F1F1F1F1F213100003A3336383939454239393839323A00FCFF
    0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F0000FC3F
    0000F81F0000F00F0000E0070000C0030000800100008001000080010000}
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 281
    Height = 105
    Align = alTop
    AutoSize = False
    Caption = 
      #20363#65306#13#10#13#10'*. doc'#8211#12377#12409#12390#12398'Word'#12489#12461#12517#12513#12531#12488#13#10#13#10'*. xls'#8211#12377#12409#12390#12398'Excel'#12489#12461#12517#12513#12531#12488#13#10#13#10'*. htm'#8211 +
      #12377#12409#12390#12398'Html'#12489#12461#12517#12513#12531#12488
    WordWrap = True
    ExplicitWidth = 294
  end
  object Panel1: TPanel
    Left = 0
    Top = 105
    Width = 281
    Height = 41
    Align = alClient
    BevelEdges = [beTop]
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 0
    object Label2: TLabel
      Left = 4
      Top = 16
      Width = 48
      Height = 13
      Caption = #12429#36942#26465#20214
    end
    object edtMask: TEdit
      Left = 58
      Top = 11
      Width = 93
      Height = 21
      ImeName = #20013#25991' - QQ'#25340#38899#36755#20837#27861
      TabOrder = 0
      Text = '*.doc'
    end
    object btnOK: TButton
      Left = 155
      Top = 9
      Width = 58
      Height = 25
      Caption = #30906#23450
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 216
      Top = 9
      Width = 58
      Height = 25
      Caption = #12461#12515#12531#12475#12523
      TabOrder = 2
      OnClick = btnCancelClick
    end
  end
  object siLang_FrmEnterMask: TsiLang
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
    Left = 176
    Top = 16
    TranslationData = {
      73007400430061007000740069006F006E0073005F0055006E00690063006F00
      640065000D000A005400460072006D0045006E007400650072004D0061007300
      6B00010045006E007400650072002000610020004D00610073006B000100938F
      6551C78FE46E6167F64E0100FE6F4E906167F64E65519B5201000D000A006200
      74006E00430061006E00630065006C000100430061006E00630065006C000100
      D653886D0100AD30E330F330BB30EB3001000D000A00620074006E004F004B00
      01004F004B0001006E789A5B0100BA789A5B01000D000A004C00610062006500
      6C00310001004500780061006D0070006C00650073003A001900190020002000
      2A002E0064006F00630020001320200061006C006C0020004D00690063007200
      6F0073006F0066007400200057006F0072006400200064006F00630075006D00
      65006E007400730019001900200020002A002E0078006C007300200013202000
      61006C006C0020004D006900630072006F0073006F0066007400200045007800
      630065006C002000730070007200650061006400730068006500650074007300
      19001900200020002A002E00680074006D0020001320200061006C006C002000
      480054004D004C002000660069006C006500730001008B4F505B3A0019001900
      200020002A002E0064006F006300200013202000406209678476200057006F00
      7200640020008765636819001900200020002A002E0078006C00730020001320
      2000406209678476200045007800630065006C00200087656368190019002000
      20002A002E00680074006D002000132020004062096784762000480074006D00
      6C0020008765636801008B4F1AFF19001A0019001A002A002E00200064006F00
      630013205930793066306E3057006F0072006400C930AD30E530E130F330C830
      19001A0019001A002A002E00200078006C00730013205930793066306E304500
      7800630065006C00C930AD30E530E130F330C83019001A0019001A002A002E00
      2000680074006D0013205930793066306E30480074006D006C00C930AD30E530
      E130F330C83001000D000A004C006100620065006C003200010020004D006100
      73006B000100C78FE46E6167F64E01008D304E906167F64E01000D000A007300
      7400480069006E00740073005F0055006E00690063006F00640065000D000A00
      7300740044006900730070006C00610079004C006100620065006C0073005F00
      55006E00690063006F00640065000D000A007300740046006F006E0074007300
      5F0055006E00690063006F00640065000D000A005400460072006D0045006E00
      7400650072004D00610073006B0001005400610068006F006D00610001005400
      610068006F006D0061000100400041007200690061006C00200055006E006900
      63006F006400650020004D00530001000D000A00730074004D0075006C007400
      69004C0069006E00650073005F0055006E00690063006F00640065000D000A00
      7300740044006C0067007300430061007000740069006F006E0073005F005500
      6E00690063006F00640065000D000A005700610072006E0069006E0067000100
      5700610072006E0069006E0067000100010001000D000A004500720072006F00
      720001004500720072006F0072000100010001000D000A0049006E0066006F00
      72006D006100740069006F006E00010049006E0066006F0072006D0061007400
      69006F006E000100010001000D000A0043006F006E006600690072006D000100
      43006F006E006600690072006D000100010001000D000A005900650073000100
      26005900650073000100010001000D000A004E006F00010026004E006F000100
      010001000D000A004F004B0001004F004B000100010001000D000A0043006100
      6E00630065006C000100430061006E00630065006C000100010001000D000A00
      410062006F007200740001002600410062006F00720074000100010001000D00
      0A00520065007400720079000100260052006500740072007900010001000100
      0D000A00490067006E006F007200650001002600490067006E006F0072006500
      0100010001000D000A0041006C006C000100260041006C006C00010001000100
      0D000A004E006F00200054006F00200041006C006C0001004E0026006F002000
      74006F00200041006C006C000100010001000D000A0059006500730020005400
      6F00200041006C006C000100590065007300200074006F002000260041006C00
      6C000100010001000D000A00480065006C00700001002600480065006C007000
      0100010001000D000A007300740053007400720069006E00670073005F005500
      6E00690063006F00640065000D000A00730074004F0074006800650072005300
      7400720069006E00670073005F0055006E00690063006F00640065000D000A00
      6500640074004D00610073006B002E00540065007800740001002A002E006400
      6F0063000100010001000D000A00730074004C006F00630061006C0065007300
      5F0055006E00690063006F00640065000D000A007300740043006F006C006C00
      65006300740069006F006E0073005F0055006E00690063006F00640065000D00
      0A0073007400430068006100720053006500740073005F0055006E0069006300
      6F00640065000D000A005400460072006D0045006E007400650072004D006100
      73006B000100440045004600410055004C0054005F0043004800410052005300
      4500540001004700420032003300310032005F00430048004100520053004500
      54000100530048004900460054004A00490053005F0043004800410052005300
      4500540001000D000A00}
  end
end