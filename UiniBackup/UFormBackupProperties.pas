unit UFormBackupProperties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzTabs, ComCtrls, ToolWin, ExtCtrls, UMainForm, Spin, UIconUtil,
  ImgList, Menus, RzButton, RzRadChk, UFmFilter, pngimage, UFileBaseInfo,
  UFrameFilter, siComp;

type
  TfrmBackupProperties = class(TForm)
    ilPcMain16: TImageList;
    Panel3: TPanel;
    LvBackupItem: TListView;
    PcMain: TRzPageControl;
    tsGenernal: TRzTabSheet;
    TsFilter: TRzTabSheet;
    Panel1: TPanel;
    Panel8: TPanel;
    btnApplyto: TButton;
    BtnApply: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    lbCopyCount: TLabel;
    cbbSyncTime: TComboBox;
    ChkIsBackupNow: TCheckBox;
    ChkSyncTime: TCheckBox;
    seCopyCount: TSpinEdit;
    seSyncTime: TSpinEdit;
    Panel6: TPanel;
    edtBackupPath: TEdit;
    Label1: TLabel;
    ChkIsDisable: TCheckBox;
    pl5: TPanel;
    gbEncrypt: TGroupBox;
    lbEncPassword: TLabel;
    lbEncPassword2: TLabel;
    lbEncPasswordHint: TLabel;
    lbReqEncPassword: TLabel;
    lbReqEncPassword2: TLabel;
    img3: TImage;
    chkIsEncrypt: TCheckBox;
    edtEncPassword2: TEdit;
    edtEncPasswordHint: TEdit;
    edtEncPassword: TEdit;
    Image1: TImage;
    PmApply: TPopupMenu;
    ApplytoAllBackupItems1: TMenuItem;
    ApplytoMoreBackupItems1: TMenuItem;
    tmrHideSave: TTimer;
    FrameFilter: TFrameFilterPage;
    Label2: TLabel;
    siLang_frmBackupProperties: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure LvBackupItemDeletion(Sender: TObject; Item: TListItem);
    procedure seCopyCountChange(Sender: TObject);
    procedure ChkSyncTimeClick(Sender: TObject);
    procedure seSyncTimeChange(Sender: TObject);
    procedure cbbSyncTimeChange(Sender: TObject);
    procedure LvBackupItemSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnCancelClick(Sender: TObject);
    procedure ChkIsBackupNowClick(Sender: TObject);
    procedure ChkIsDisableClick(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure FrameIncludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameIncludeLvMaskInsert(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskInsert(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameIncludebtnSelectFileClick(Sender: TObject);
    procedure FrameExcludebtnSelectFileClick(Sender: TObject);
    procedure btnApplytoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplytoAllBackupItems1Click(Sender: TObject);
    procedure ApplytoMoreBackupItems1Click(Sender: TObject);
    procedure tmrHideSaveTimer(Sender: TObject);
    procedure LvBackupItemMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure siLang_frmBackupPropertiesChangeLanguage(Sender: TObject);
  private
    ShowBackupPath : string;
  private
    procedure SyncTimeChange;
    procedure IncludeFilterChange;
    procedure ExcludeFilterChange;
    procedure SelectLvBackupPath( BackupPath : string );
    procedure SetBackupConfigInfo( BackupConfigInfo : TBackupConfigInfo );
  private
    procedure HindeApplyBtn;
    procedure ShowApplyBtn;
  public
    procedure ShowOptions( BackupPath : string );
  end;

  FrmBackupProUtil = class
  public
    class procedure SetChangeColor( f : TFont );
    class procedure SetUnChangeColor( f : TFont );
    class function IsChangeColor( f : TFont ): Boolean;
  public
    class function getBackupItemList : TStringList;
  public
    class procedure ShowSave( BackupPathList : TStringList );
    class procedure HideSave;
  end;

    // 读取 备份路径 配置
  TBackupProSetConfigHandle = class
  private
    BackupConfigInfo : TBackupConfigInfo;
  public
    constructor Create( _BackupConfigInfo : TBackupConfigInfo );
    procedure Update;
  private
    procedure SetGanernal;
    procedure SetEncrypt;
    procedure SetFilter;
  end;

    // 设置 备份路径 配置
  TApplyBackupConfigHandle = class
  public
    BackupPathList : TStringList;
  public
    constructor Create( _BackupPathList : TStringList );
    procedure Update;
  private
    procedure FindGenernalChange;
    procedure ResetCopyCount;
    procedure ResetAutoSync;
    procedure ResetIsBackupNow;
    procedure ResetIsDisable;
  private
    procedure FindFilterChange;
    procedure ResetIncludeFilter;
    procedure ResetExcludeFilter;
    procedure BackupNow;
  private
    function IsChange( f : TFont ): Boolean;
  end;

const
  LvBackupCopy_FileCount = 0;
  LvBackupCopy_Size = 1;
  LvBackupCopy_CopyCount = 2;

  LvDestination_AvailableSpace = 0;
  LvDestination_Status = 1;

const
  ShowConfirm_ApplyAllItem = 'Are you sure to apply changed settings to all backup items?';

var
  frmBackupProperties: TfrmBackupProperties;

implementation

uses UBackupInfoFace, Math, UBackupInfoControl, UNetworkControl, UMyNetPcInfo, UMyUtil, UFormUtil,
     UMyBackupInfo, UFormBackupItemApply;

{$R *.dfm}

procedure TfrmBackupProperties.ApplytoAllBackupItems1Click(Sender: TObject);
var
  BackupPathList : TStringList;
  ApplyBackupConfigHandle : TApplyBackupConfigHandle;
begin
    // 确认
  if not MyMessageBox.ShowConfirm( ShowConfirm_ApplyAllItem ) then
    Exit;

  BackupPathList := FrmBackupProUtil.getBackupItemList;

    // 应用
  ApplyBackupConfigHandle := TApplyBackupConfigHandle.Create( BackupPathList );
  ApplyBackupConfigHandle.Update;
  ApplyBackupConfigHandle.Free;

  BackupPathList.Free;

    // 隐藏
  HindeApplyBtn;
end;

procedure TfrmBackupProperties.ApplytoMoreBackupItems1Click(Sender: TObject);
var
  BackupPathList : TStringList;
  ApplyBackupConfigHandle : TApplyBackupConfigHandle;
begin
  BackupPathList := FrmBackupProUtil.getBackupItemList;
  frmBackupItemsApply.SetBackupItem( BackupPathList, ShowBackupPath );
  BackupPathList.free;

  if frmBackupItemsApply.ShowModal = mrCancel then
    Exit;

  BackupPathList := frmBackupItemsApply.getSelectItems;

    // 应用
  ApplyBackupConfigHandle := TApplyBackupConfigHandle.Create( BackupPathList );
  ApplyBackupConfigHandle.Update;
  ApplyBackupConfigHandle.Free;

  BackupPathList.Free;

    // 隐藏
  HindeApplyBtn;
end;

procedure TfrmBackupProperties.BtnApplyClick(Sender: TObject);
var
  BackupPathList : TStringList;
  ApplyBackupConfigHandle : TApplyBackupConfigHandle;
begin
  BackupPathList := MyStringList.getString( ShowBackupPath );

    // 应用
  ApplyBackupConfigHandle := TApplyBackupConfigHandle.Create( BackupPathList );
  ApplyBackupConfigHandle.Update;
  ApplyBackupConfigHandle.Free;

  BackupPathList.Free;

    // 隐藏
  HindeApplyBtn;
end;

procedure TfrmBackupProperties.btnApplytoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt:TPoint;
begin
  GetCursorPos(pt);
  PmApply.Popup((pt.x-x),(pt.y+(btnApplyTo.Height-y)));
end;

procedure TfrmBackupProperties.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBackupProperties.cbbSyncTimeChange(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TfrmBackupProperties.ChkIsBackupNowClick(Sender: TObject);
begin
  FrmBackupProUtil.SetChangeColor( ChkIsBackupNow.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.ChkIsDisableClick(Sender: TObject);
begin
  FrmBackupProUtil.SetChangeColor( ChkIsDisable.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.ChkSyncTimeClick(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TfrmBackupProperties.ExcludeFilterChange;
begin
  FrmBackupProUtil.SetChangeColor( FrameFilter.gbExcludeFilter.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.FormCreate(Sender: TObject);
begin
  LvBackupItem.SmallImages := MyIcon.getSysIcon;
  FrameFilter.IniFrame;
  siLang_frmBackupPropertiesChangeLanguage( nil );
end;

procedure TfrmBackupProperties.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := MyStringList.getString( ShowBackupPath );

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick( Sender );

  SelectPathList.Free;
end;

procedure TfrmBackupProperties.FrameExcludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameFilter.FrameExclude.LvMaskDeletion(Sender, Item);
  ExcludeFilterChange;
end;

procedure TfrmBackupProperties.FrameExcludeLvMaskInsert(Sender: TObject;
  Item: TListItem);
begin
  ExcludeFilterChange;
end;

procedure TfrmBackupProperties.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := MyStringList.getString( ShowBackupPath );

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick( Sender );

  SelectPathList.Free;
end;

procedure TfrmBackupProperties.FrameIncludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  FrameFilter.FrameInclude.LvMaskDeletion(Sender, Item);
  IncludeFilterChange;
end;

procedure TfrmBackupProperties.FrameIncludeLvMaskInsert(Sender: TObject;
  Item: TListItem);
begin
  IncludeFilterChange;
end;

procedure TfrmBackupProperties.HindeApplyBtn;
begin
  BtnApply.Enabled := False;
  btnApplyto.Enabled := False;
end;

procedure TfrmBackupProperties.IncludeFilterChange;
begin
  FrmBackupProUtil.SetChangeColor( FrameFilter.gbIncludeFilter.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.LvBackupItemDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TfrmBackupProperties.LvBackupItemMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectItem : TListItem;
  ItemData : TLvBackupPathProData;
begin
  SelectItem := LvBackupItem.GetItemAt( x, y );
  if SelectItem = nil then
    LvBackupItem.Hint := ''
  else
  begin
    ItemData := SelectItem.Data;
    LvBackupItem.Hint := ItemData.FullPath;
  end;
end;

procedure TfrmBackupProperties.LvBackupItemSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  ItemData : TLvBackupPathProData;
begin
  if not Selected then
    Exit;

  ItemData := Item.Data;
  ShowOptions( ItemData.FullPath );
end;

procedure TfrmBackupProperties.seCopyCountChange(Sender: TObject);
begin
  FrmBackupProUtil.SetChangeColor( lbCopyCount.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.SelectLvBackupPath(BackupPath: string);
var
  i : Integer;
  LvBackupPathData : TLvBackupPathProData;
begin
  for i := 0 to LvBackupItem.Items.Count - 1 do
  begin
    LvBackupPathData := LvBackupItem.Items[i].Data;
    LvBackupItem.Items[i].Selected := LvBackupPathData.FullPath = BackupPath;
  end;
end;

procedure TfrmBackupProperties.seSyncTimeChange(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TfrmBackupProperties.SetBackupConfigInfo(
  BackupConfigInfo: TBackupConfigInfo);
var
  BackupProSetConfigHandle : TBackupProSetConfigHandle;
begin
  BackupProSetConfigHandle := TBackupProSetConfigHandle.Create( BackupConfigInfo );
  BackupProSetConfigHandle.Update;
  BackupProSetConfigHandle.Free;
end;

procedure TfrmBackupProperties.ShowApplyBtn;
begin
  BtnApply.Enabled := True;
  btnApplyto.Enabled := True;
end;

procedure TfrmBackupProperties.ShowOptions(BackupPath: string);
var
  BackupConfigInfo : TBackupConfigInfo;
begin
    // 已选中
  if ShowBackupPath = BackupPath then
    Exit;

  ShowBackupPath := BackupPath;

    // 选择 ListView
  edtBackupPath.Text := BackupPath;
  SelectLvBackupPath( BackupPath );

  BackupConfigInfo := MyBackupPathInfoUtil.ReadBackupConfigInfo( BackupPath );
  if BackupConfigInfo = nil then // 路径不存在
    Exit;
  SetBackupConfigInfo( BackupConfigInfo );
  BackupConfigInfo.Free;

    // 隐藏 Apply
  HindeApplyBtn;
end;

procedure TfrmBackupProperties.siLang_frmBackupPropertiesChangeLanguage(
  Sender: TObject);
begin
  LvBackupItem.Columns[0].Caption := siLang_frmBackupProperties.GetText( 'lvBackupItem' );

  with cbbSyncTime.Items do
  begin
    Clear;
    Add( siLang_frmBackupProperties.GetText( 'StrMin' ) );
    Add( siLang_frmBackupProperties.GetText( 'StrHour' ) );
    Add( siLang_frmBackupProperties.GetText( 'StrDay' ) );
    Add( siLang_frmBackupProperties.GetText( 'StrWeek' ) );
    Add( siLang_frmBackupProperties.GetText( 'StrMonth' ) );
  end;

  FrameFilter.RefreshLanguage;
end;

procedure TfrmBackupProperties.SyncTimeChange;
begin
  FrmBackupProUtil.SetChangeColor( ChkSyncTime.Font );
  ShowApplyBtn;
end;

procedure TfrmBackupProperties.tmrHideSaveTimer(Sender: TObject);
begin
  FrmBackupProUtil.HideSave;  
end;

{ TBackupProSetConfigHandle }

constructor TBackupProSetConfigHandle.Create(
  _BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TBackupProSetConfigHandle.SetEncrypt;
begin
  with frmBackupProperties do
  begin
    chkIsEncrypt.Checked := BackupConfigInfo.IsEncrypt;
    edtEncPassword.Text := BackupConfigInfo.Password;
    edtEncPassword2.Text := BackupConfigInfo.Password;
    edtEncPassword.Text := BackupConfigInfo.PasswordHint;
  end;
end;

procedure TBackupProSetConfigHandle.SetFilter;
begin
  with frmBackupProperties do
  begin
    FrameFilter.FrameInclude.LvMask.Clear;
    FrameFilter.FrameExclude.LvMask.Clear;
    FrameFilter.FrameInclude.SetFilterList( BackupConfigInfo.IncludeFilterList );
    FrameFilter.FrameExclude.SetFilterList( BackupConfigInfo.ExcludeFilterList );

    FrmBackupProUtil.SetUnChangeColor( FrameFilter.gbIncludeFilter.Font );
    FrmBackupProUtil.SetUnChangeColor( FrameFilter.gbExcludeFilter.Font );
  end;
end;

procedure TBackupProSetConfigHandle.SetGanernal;
begin
  with frmBackupProperties do
  begin
    seCopyCount.Value := BackupConfigInfo.CopyCount;
    ChkSyncTime.Checked := BackupConfigInfo.IsAuctoSync;
    seSyncTime.Value := BackupConfigInfo.SyncTimeValue;
    cbbSyncTime.ItemIndex := BackupConfigInfo.SyncTimeType;
    ChkIsBackupNow.Checked := BackupConfigInfo.IsBackupupNow;
    ChkIsDisable.Checked := BackupConfigInfo.IsDisable;

    FrmBackupProUtil.SetUnChangeColor( lbCopyCount.Font );
    FrmBackupProUtil.SetUnChangeColor( ChkSyncTime.Font );
    FrmBackupProUtil.SetUnChangeColor( ChkIsBackupNow.Font );
    FrmBackupProUtil.SetUnChangeColor( ChkIsDisable.Font );
  end;
end;

procedure TBackupProSetConfigHandle.Update;
begin
  SetGanernal;
  SetEncrypt;
  SetFilter;
end;

{ TApplyBackupConfigHandle }

procedure TApplyBackupConfigHandle.BackupNow;
var
  i : Integer;
begin
  for i := 0 to BackupPathList.Count - 1 do
    MyBackupFileControl.BackupSelectFolder( BackupPathList[i] );
end;

constructor TApplyBackupConfigHandle.Create(_BackupPathList: TStringList);
begin
  BackupPathList := _BackupPathList;
end;

procedure TApplyBackupConfigHandle.FindFilterChange;
var
  IsBackupNow : Boolean;
begin
  IsBackupNow := False;
  with frmBackupProperties do
  begin
    if IsChange( FrameFilter.gbIncludeFilter.Font ) then
    begin
      ResetIncludeFilter;
      IsBackupNow := True;
    end;

    if IsChange( FrameFilter.gbExcludeFilter.Font ) then
    begin
      ResetExcludeFilter;
      IsBackupNow := True;
    end;
  end;

    // 立刻 备份修改 过滤器的 BackupItem
  if IsBackupNow then
    BackupNow;
end;

procedure TApplyBackupConfigHandle.FindGenernalChange;
begin
  with frmBackupProperties do
  begin
    if IsChange( lbCopyCount.Font ) then
      ResetCopyCount;
    if IsChange( ChkSyncTime.Font )  then
      ResetAutoSync;
    if IsChange( ChkIsBackupNow.Font ) then
      ResetIsBackupNow;
    if IsChange( ChkIsDisable.Font ) then
      ResetIsDisable;
  end;
end;

function TApplyBackupConfigHandle.IsChange(f: TFont): Boolean;
begin
  Result := FrmBackupProUtil.IsChangeColor( f );
  if Result then
    FrmBackupProUtil.SetUnChangeColor( f );
end;

procedure TApplyBackupConfigHandle.ResetAutoSync;
var
  IsAutoSync : Boolean;
  SyncTimeType, SyncTimeValue : Integer;
  i : Integer;
  BackupPath : string;
  BackupPathSetAutoSyncHandle : TBackupPathSetAutoSyncHandle;
begin
  with frmBackupProperties do
  begin
    IsAutoSync := ChkSyncTime.Checked;
    SyncTimeType := cbbSyncTime.ItemIndex;
    SyncTimeValue := seSyncTime.Value;
  end;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    BackupPathSetAutoSyncHandle := TBackupPathSetAutoSyncHandle.Create( BackupPath );
    BackupPathSetAutoSyncHandle.SetIsAutoSync( IsAutoSync );
    BackupPathSetAutoSyncHandle.SetSyncInterval( SyncTimeType, SyncTimeValue );
    BackupPathSetAutoSyncHandle.Update;
    BackupPathSetAutoSyncHandle.Free;
  end;
end;

procedure TApplyBackupConfigHandle.ResetCopyCount;
var
  CopyCount : Integer;
  i : Integer;
  BackupPath : string;
  BackupPathSetCopyCount : TBackupPathSetCopyCount;
begin
  CopyCount := frmBackupProperties.seCopyCount.Value;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    BackupPathSetCopyCount := TBackupPathSetCopyCount.Create( BackupPath );
    BackupPathSetCopyCount.SetCopyCount( CopyCount );
    BackupPathSetCopyCount.Update;
    BackupPathSetCopyCount.Free;
  end;
end;

procedure TApplyBackupConfigHandle.ResetExcludeFilter;
var
  IncludeFliterList : TFileFilterList;
  i, j : Integer;
  BackupPath, FilterType, FilterStr : string;
  BackupPathExcludeFilterClearHandle : TBackupPathExcludeFilterClearHandle;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
  IncludeFliterList := frmBackupProperties.FrameFilter.FrameExclude.getFilterList;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

      // 清空旧的
    BackupPathExcludeFilterClearHandle := TBackupPathExcludeFilterClearHandle.Create( BackupPath );
    BackupPathExcludeFilterClearHandle.Update;
    BackupPathExcludeFilterClearHandle.Free;

      // 添加新的过滤器
    for j := 0 to IncludeFliterList.Count - 1 do
    begin
      FilterType := IncludeFliterList[j].FilterType;
      FilterStr := IncludeFliterList[j].FilterStr;

      BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( BackupPath );
      BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType, FilterStr );
      BackupPathExcludeFilterAddHandle.Update;
      BackupPathExcludeFilterAddHandle.Free;
    end;
  end;

  IncludeFliterList.Free;
end;

procedure TApplyBackupConfigHandle.ResetIncludeFilter;
var
  IncludeFliterList : TFileFilterList;
  i, j : Integer;
  BackupPath, FilterType, FilterStr : string;
  BackupPathIncludeFilterClearHandle : TBackupPathIncludeFilterClearHandle;
  BackupPathIncludeFilterAddHandle : TBackupPathIncludeFilterAddHandle;
begin
  IncludeFliterList := frmBackupProperties.FrameFilter.FrameInclude.getFilterList;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

      // 清空旧的
    BackupPathIncludeFilterClearHandle := TBackupPathIncludeFilterClearHandle.Create( BackupPath );
    BackupPathIncludeFilterClearHandle.Update;
    BackupPathIncludeFilterClearHandle.Free;

      // 添加新的过滤器
    for j := 0 to IncludeFliterList.Count - 1 do
    begin
      FilterType := IncludeFliterList[j].FilterType;
      FilterStr := IncludeFliterList[j].FilterStr;

      BackupPathIncludeFilterAddHandle := TBackupPathIncludeFilterAddHandle.Create( BackupPath );
      BackupPathIncludeFilterAddHandle.SetFilterInfo( FilterType, FilterStr );
      BackupPathIncludeFilterAddHandle.Update;
      BackupPathIncludeFilterAddHandle.Free;
    end;
  end;

  IncludeFliterList.Free;
end;

procedure TApplyBackupConfigHandle.ResetIsBackupNow;
var
  IsBackupNow : Boolean;
  i : Integer;
  BackupPath : string;
  BackupPathSetIsBackupNowHandle : TBackupPathSetIsBackupNowHandle;
begin
  IsBackupNow := frmBackupProperties.ChkIsBackupNow.Checked;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    BackupPathSetIsBackupNowHandle := TBackupPathSetIsBackupNowHandle.Create( BackupPath );
    BackupPathSetIsBackupNowHandle.SetIsBackupNow( IsBackupNow );
    BackupPathSetIsBackupNowHandle.Update;
    BackupPathSetIsBackupNowHandle.Free;
  end;
end;

procedure TApplyBackupConfigHandle.ResetIsDisable;
var
  IsDisable : Boolean;
  i : Integer;
  BackupPath : string;
  BackupPathSetIsDisableHandle : TBackupPathSetIsDisableHandle;
begin
  IsDisable := frmBackupProperties.ChkIsDisable.Checked;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    BackupPathSetIsDisableHandle := TBackupPathSetIsDisableHandle.Create( BackupPath );
    BackupPathSetIsDisableHandle.SetIsDisable( IsDisable );
    BackupPathSetIsDisableHandle.Update;
    BackupPathSetIsDisableHandle.Free;
  end;
end;

procedure TApplyBackupConfigHandle.Update;
begin
    // 显示保存界面
  FrmBackupProUtil.ShowSave( BackupPathList );
  
    // 一般配置 变化
  FindGenernalChange;

    // 过滤器配置 变化
  FindFilterChange;
end;

{ FrmBackupProUtil }

class function FrmBackupProUtil.getBackupItemList: TStringList;
var
  LvBackupItem : TListView;
  i : Integer;
  LvBackupData : TLvBackupPathProData;
begin
  Result := TStringList.Create;

  LvBackupItem := frmBackupProperties.LvBackupItem;
  for i := 0 to LvBackupItem.Items.Count - 1 do
  begin
    LvBackupData := LvBackupItem.Items[i].Data;
    Result.Add( LvBackupData.FullPath );
  end;
end;

class procedure FrmBackupProUtil.HideSave;
begin
  with frmBackupProperties do
  begin
    LvBackupItem.Columns[0].Width := 140;
    LvBackupItem.Columns[1].Width := 0;    
    tmrHideSave.Enabled := False;
  end;
end;

class function FrmBackupProUtil.IsChangeColor(f: TFont): Boolean;
begin
  Result := f.Color = clBlue;
end;

class procedure FrmBackupProUtil.SetChangeColor(f: TFont);
begin
  f.Color := clBlue;
end;

class procedure FrmBackupProUtil.SetUnChangeColor(f: TFont);
begin
  f.Color := clBlack;
end;

class procedure FrmBackupProUtil.ShowSave(BackupPathList: TStringList);
var
  LvBackupItem : TListView;
  i : Integer;
  LvBackupData : TLvBackupPathProData;
begin
  LvBackupItem := frmBackupProperties.LvBackupItem;
  for i := 0 to LvBackupItem.Items.Count - 1 do
  begin
    LvBackupData := LvBackupItem.Items[i].Data;
    if BackupPathList.IndexOf( LvBackupData.FullPath ) >= 0 then
      LvBackupItem.Items[i].SubItemImages[0] := MyShellTransActionIconUtil.getSave
    else
      LvBackupItem.Items[i].SubItemImages[0] := -1;
  end;

  LvBackupItem.Columns[0].Width := 120;
  LvBackupItem.Columns[1].Width := 20;

  frmBackupProperties.tmrHideSave.Enabled := True;
end;

end.
