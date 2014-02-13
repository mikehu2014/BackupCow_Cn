unit UFormRestoreDetail;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, ImgList, StdCtrls, siComp, UMainForm;

type

  TfrmRestoreDetail = class(TForm)
    plCheckFolderPcInfo: TPanel;
    Splitter1: TSplitter;
    LvBackupPathDetail: TListView;
    Panel1: TPanel;
    lvBackupPathLocation: TListView;
    Label1: TLabel;
    edtRestorePath: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lbRestorePc: TLabel;
    lbRestoreSize: TLabel;
    lbRestoreFiles: TLabel;
    siLang_frmRestoreDetail: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure LvBackupPathDetailSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LvBackupPathDetailDeletion(Sender: TObject; Item: TListItem);
    procedure LvBackupPathDetailCompare(Sender: TObject; Item1,
      Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure siLang_frmRestoreDetailChangeLanguage(Sender: TObject);
  private
    procedure BindSort;
    { Private declarations }
  public
    RestorePcName : string;
  end;

var
  frmRestoreDetail: TfrmRestoreDetail;

implementation

uses UMyUtil, UFormRestorePath, UIconUtil, URestoreFileFace, UNetworkFace, UFormUtil;

{$R *.dfm}

procedure TfrmRestoreDetail.BindSort;
begin
  LvBackupPathDetail.OnColumnClick := ListviewUtil.ColumnClick;
  ListviewUtil.BindSort( lvBackupPathLocation );
end;


procedure TfrmRestoreDetail.FormCreate(Sender: TObject);
begin
  BindSort;

  LvBackupPathDetail.SmallImages := MyIcon.getSysIcon;

  siLang_frmRestoreDetailChangeLanguage( nil );
end;

procedure TfrmRestoreDetail.LvBackupPathDetailCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  LvTag : Integer;
  ColumnNum, SortNum, SortType : Integer;
  ItemStr1, ItemStr2 : string;
  SortStr1, SortStr2 : string;
  CompareSize : Int64;
  ItemData1 : TLvBackupPathDetailData;
  ItemData2 : TLvBackupPathDetailData;
begin
  LvTag := ( Sender as TListView ).Tag;

  SortType := LvTag div 1000;
  LvTag := LvTag mod 1000;
  SortNum := LvTag div 100;
  LvTag := LvTag mod 100;
  ColumnNum := LvTag;

    // ’“≥ˆ “™≈≈–Úµƒ¡–
  if ColumnNum = 0 then
  begin
    ItemStr1 := Item1.Caption;
    ItemStr2 := Item2.Caption;
  end
  else
  begin
    ItemData1 := Item1.Data;
    ItemData2 := item2.Data;
    ItemStr1 := IntToStr( ItemData1.StatusInt );
    ItemStr2 := IntToStr( ItemData2.StatusInt );
  end;

    // ’˝–Ú/µπ–Ú ≈≈–Ú
  if SortNum = 1 then
  begin
    SortStr1 := ItemStr1;
    SortStr2 := ItemStr2;
  end
  else
  begin
    SortStr1 := ItemStr2;
    SortStr2 := ItemStr1;
  end;

    // ≈≈–Ú ∑Ω Ω
  if SortType = SortType_String then  // ◊÷∑˚¥Æ≈≈–Ú
    Compare := CompareText( SortStr1, SortStr2 )
  else
  if SortType = SortType_Size then  // Size ≈≈–Ú
  begin
    CompareSize := MySize.getFileSize( SortStr1 ) - MySize.getFileSize( SortStr2 );
    if CompareSize > 0 then
      Compare := 1
    else
    if CompareSize = 0 then
      Compare := 0
    else
      Compare := -1;
  end
  else
  if SortType = SortType_Int then  // Count ≈≈–Ú
    Compare := StrToIntDef( SortStr1, 0 ) - StrToIntDef( SortStr2, 0 )
  else
  if SortType = SortType_Percentage then  // Percentage ≈≈–Ú
    Compare := MyPercentage.getStrToPercentage( SortStr1 ) - MyPercentage.getStrToPercentage( SortStr2 )
  else
    Compare := CompareText( SortStr1, SortStr2 ); // Others
end;

procedure TfrmRestoreDetail.LvBackupPathDetailDeletion(Sender: TObject;
  Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmRestoreDetail.LvBackupPathDetailSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  ItemData : TLvBackupPathDetailData;
  PathOwnerDetailHash : TPathOwnerDetailHash;
  p : TPathOwnerDetailPair;
  Percentage, ImgIndex : Integer;
  StatusStr : string;
begin
  lvBackupPathLocation.Clear;

  if not Selected then
    Exit;

  ItemData := Item.Data;

  edtRestorePath.Text := ItemData.FullPath;
  lbRestorePc.Caption := RestorePcName;
  lbRestoreSize.Caption := MySize.getFileSizeStr( ItemData.FolderSpace );
  lbRestoreFiles.Caption := MyCount.getCountStr( ItemData.FileCount ) + ' Files';

  PathOwnerDetailHash := ItemData.PathOwnerDetailHash;
  for p in PathOwnerDetailHash do
  begin
    if p.Value.IsOnline then
    begin
      StatusStr := Status_Online;
      ImgIndex := CloudStatusIcon_Online
    end
    else
    begin
      StatusStr := Status_Offline;
      ImgIndex := CloudStatusIcon_Offline;
    end;
    StatusStr := siLang_frmRestoreDetail.GetText( StatusStr );

    with lvBackupPathLocation.Items.Add do
    begin
      Caption := p.Value.PcName;
      SubItems.Add( MySize.getFileSizeStr( p.Value.OwnerSpace ) );
      SubItems.Add( StatusStr );
      ImageIndex := ImgIndex;
    end;
  end;
end;

procedure TfrmRestoreDetail.siLang_frmRestoreDetailChangeLanguage(
  Sender: TObject);
begin
  with LvBackupPathDetail do
  begin
    Columns[0].Caption := siLang_frmRestoreDetail.GetText( 'lvRestoreFrom' );
  end;

  with lvBackupPathLocation do
  begin
    Columns[0].Caption := siLang_frmRestoreDetail.GetText( 'lvRestoreItem' );
    Columns[1].Caption := siLang_frmRestoreDetail.GetText( 'lvSize' );
    Columns[2].Caption := siLang_frmRestoreDetail.GetText( 'lvStatus' );
  end;
end;

end.
