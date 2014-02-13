unit UFormBackupPriority;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ImgList, StdCtrls, ToolWin, UMainForm, UMyUtil;

type
  TfrmBackupPriority = class(TForm)
    LvPc: TListView;
    ToolBar1: TToolBar;
    ilSelectHardCode: TImageList;
    tbtnAlway: TToolButton;
    tbtnLow: TToolButton;
    tbtnNerver: TToolButton;
    tbtnHigh: TToolButton;
    tbtnNormal: TToolButton;
    ilDiable: TImageList;
    ToolButton1: TToolButton;
    ilNw16: TImageList;
    procedure LvPcChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure LvPcDeletion(Sender: TObject; Item: TListItem);
    procedure tbtnAlwayClick(Sender: TObject);
    procedure tbtnNerverClick(Sender: TObject);
    procedure tbtnHighClick(Sender: TObject);
    procedure tbtnNormalClick(Sender: TObject);
    procedure tbtnLowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LvPcCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
  private
    procedure SetPcPriority( Priority : string );
  public
    function getPriorityIcon( Priority : string ): Integer;
  end;

const
  LvPc_Avalible = 0;
  LvPc_Priority = 1;

var
  frmBackupPriority: TfrmBackupPriority;

implementation

uses UBackupInfoFace, UNetworkControl, UMyNetPcInfo, UFormUtil;

{$R *.dfm}

procedure TfrmBackupPriority.FormCreate(Sender: TObject);
begin
  LvPc.OnColumnClick := ListviewUtil.ColumnClick;
end;

function TfrmBackupPriority.getPriorityIcon(Priority: string): Integer;
begin
  if Priority = BackupPriority_Alway then
    Result := BackupPriorityIcon_Alway
  else
  if Priority = BackupPriority_High then
    Result := BackupPriorityIcon_High
  else
  if Priority = BackupPriority_Normal then
    Result := BackupPriorityIcon_Normal
  else
  if Priority = BackupPriority_Low then
    Result := BackupPriorityIcon_Low
  else
  if Priority = BackupPriority_Never then
    Result := BackupPriorityIcon_Never
  else
    Result := -1;
end;

procedure TfrmBackupPriority.LvPcChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  IsSelect : Boolean;
begin
  IsSelect := LvPc.Selected <> nil;

  tbtnAlway.Enabled := IsSelect;
  tbtnNerver.Enabled := IsSelect;
  tbtnHigh.Enabled := IsSelect;
  tbtnNormal.Enabled := IsSelect;
  tbtnLow.Enabled := IsSelect;
end;

procedure TfrmBackupPriority.LvPcCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  LvTag : Integer;
  ColumnNum, SortNum, SortType : Integer;
  ItemStr1, ItemStr2 : string;
  SortStr1, SortStr2 : string;
  CompareSize : Int64;
begin
  LvTag := ( Sender as TListView ).Tag;

  SortType := LvTag div 1000;
  LvTag := LvTag mod 1000;
  SortNum := LvTag div 100;
  LvTag := LvTag mod 100;
  ColumnNum := LvTag;

    // 找出 要排序的列
  if ColumnNum = 0 then
  begin
    ItemStr1 := Item1.Caption;
    ItemStr2 := Item2.Caption;
  end
  else
  begin
    ItemStr1 := Item1.SubItems[ ColumnNum - 1 ];
    ItemStr2 := Item2.SubItems[ ColumnNum - 1 ];
  end;

    // 正序/倒序 排序
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

    // 排序 方式
  if ColumnNum = 0 then  // Pc 名 排序
    Compare := CompareText( SortStr1, SortStr2 )
  else
  if ColumnNum = LvPc_Avalible + 1 then  // 可用空间 排序
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
  if ColumnNum = LvPc_Priority + 1 then  // 权重 排序
    Compare := BackupPriorityUtil.getPriorityInt( SortStr1 ) - BackupPriorityUtil.getPriorityInt( SortStr2 )
  else
    Compare := CompareText( SortStr1, SortStr2 ); // Others

end;

procedure TfrmBackupPriority.LvPcDeletion(Sender: TObject; Item: TListItem);
var
  Data : TObject;
begin
  Data := Item.Data;
  Data.Free;
end;

procedure TfrmBackupPriority.SetPcPriority(Priority: string);
var
  i : Integer;
  ItemData : TLvBackupPriorityData;
  PcID : string;
begin
  for i := 0 to LvPc.Items.Count - 1 do
    if LvPc.Items[i].Selected then
    begin
      LvPc.Items[i].SubItems[ LvPc_Priority ] := Priority;
      LvPc.Items[i].SubItemImages[ LvPc_Priority ] := getPriorityIcon( Priority );
      ItemData := LvPc.Items[i].Data;
      PcID := ItemData.PcID;

      MyNetworkControl.SetPcBackupPriority( PcID, Priority );
    end;
end;

procedure TfrmBackupPriority.tbtnAlwayClick(Sender: TObject);
begin
  SetPcPriority( BackupPriority_Alway );
end;

procedure TfrmBackupPriority.tbtnHighClick(Sender: TObject);
begin
  SetPcPriority( BackupPriority_High );
end;

procedure TfrmBackupPriority.tbtnLowClick(Sender: TObject);
begin
  SetPcPriority( BackupPriority_Low );
end;

procedure TfrmBackupPriority.tbtnNerverClick(Sender: TObject);
begin
  SetPcPriority( BackupPriority_Never );
end;

procedure TfrmBackupPriority.tbtnNormalClick(Sender: TObject);
begin
  SetPcPriority( BackupPriority_Normal );
end;

end.
