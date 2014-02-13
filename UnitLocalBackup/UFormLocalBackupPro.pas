unit UFormLocalBackupPro;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Spin, pngimage, ExtCtrls, StdCtrls, ImgList, UFrameFilter, RzTabs,
  ComCtrls, UFileBaseInfo, Menus, siComp, UMainForm;

type
  TFrmLocalBackupPro = class(TForm)
    LvBackupItem: TListView;
    Panel3: TPanel;
    PcMain: TRzPageControl;
    tsGenernal: TRzTabSheet;
    plBackupSettings: TPanel;
    gbBackupSettings: TGroupBox;
    plPath: TPanel;
    Label1: TLabel;
    edtBackupPath: TEdit;
    plDestination: TPanel;
    gbDestination: TGroupBox;
    TsFilter: TRzTabSheet;
    FrameFilter: TFrameFilterPage;
    Panel1: TPanel;
    Panel8: TPanel;
    btnApplyto: TButton;
    BtnApply: TButton;
    btnCancel: TButton;
    ilPcMain16: TImageList;
    cbbSyncTimeType: TComboBox;
    chkIsAutoSync: TCheckBox;
    chkIsBackupNow: TCheckBox;
    chkIsDisable: TCheckBox;
    Image2: TImage;
    seSyncTimeValue: TSpinEdit;
    LvDestination: TListView;
    tmrHideSave: TTimer;
    Label2: TLabel;
    PmApply: TPopupMenu;
    ApplytoAllBackupItems1: TMenuItem;
    ApplytoMoreBackupItems1: TMenuItem;
    chkIsKeepDeleted: TCheckBox;
    seKeepEditionCount: TSpinEdit;
    lbKeepEditionCount: TLabel;
    siLang_FrmLocalBackupPro: TsiLang;
    procedure FormCreate(Sender: TObject);
    procedure tmrHideSaveTimer(Sender: TObject);
    procedure LvBackupItemDeletion(Sender: TObject; Item: TListItem);
    procedure LvDestinationDeletion(Sender: TObject; Item: TListItem);
    procedure btnCancelClick(Sender: TObject);
    procedure LvBackupItemMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure chkIsAutoSyncClick(Sender: TObject);
    procedure seSyncTimeValueChange(Sender: TObject);
    procedure cbbSyncTimeTypeChange(Sender: TObject);
    procedure chkIsBackupNowClick(Sender: TObject);
    procedure chkIsDisableClick(Sender: TObject);
    procedure LvDestinationClick(Sender: TObject);
    procedure FrameIncludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameIncludeLvMaskInsert(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskInsert(Sender: TObject; Item: TListItem);
    procedure FrameExcludeLvMaskDeletion(Sender: TObject; Item: TListItem);
    procedure FrameIncludebtnSelectFileClick(Sender: TObject);
    procedure FrameExcludebtnSelectFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure btnApplytoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ApplytoAllBackupItems1Click(Sender: TObject);
    procedure ApplytoMoreBackupItems1Click(Sender: TObject);
    procedure LvBackupItemSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure chkIsKeepDeletedClick(Sender: TObject);
    procedure seKeepEditionCountChange(Sender: TObject);
    procedure siLang_FrmLocalBackupProChangeLanguage(Sender: TObject);
  private
    ShowBackupPath : string;
    DesPathCount : Integer;
    LastDesPathList : TStringList;
  private
    procedure SyncTimeChange;
    procedure FileDeletedChange;
    procedure IncludeFilterChange;
    procedure ExcludeFilterChange;
    procedure SelectLvBackupPath( BackupPath : string );
    procedure SetBackupConfigInfo( BackupConfig : TLocalBackupConfigInfo );
  private
    procedure HindeApplyBtn;
    procedure ShowApplyBtn;
  public
    procedure ShowOptions( BackupPath : string );
    procedure RefreshShowOptions( BackupPath : string );
  end;

  FrmLocalBackupProUtil = class
  public
    class procedure SetChangeColor( f : TFont );
    class procedure SetUnChangeColor( f : TFont );
    class function IsChangeColor( f : TFont ): Boolean;
  public
    class function getBackupItemList : TStringList;
    class function getDesPathCount : Integer;
    class function getSelectDesPathList : TStringList;
  public
    class procedure ShowSave( BackupPathList : TStringList );
    class procedure HideSave;
  end;

    // 读取 备份路径 配置
  TLocalBackupProSetConfigHandle = class
  private
    BackupConfigInfo : TLocalBackupConfigInfo;
  public
    constructor Create( _BackupConfigInfo : TLocalBackupConfigInfo );
    procedure Update;
  private
    procedure SetGanernal;
    procedure SetDestination;
    procedure SetFilter;
  end;

    // 配置 应用
  TLocalBackupProApplyHandle = class
  private
    BackupPathList : TStringList;
    IsBackupNow : Boolean;
  public
    constructor Create( _BackupPathList : TStringList );
    procedure Update;
  private
    procedure FindGenernalChange;
    procedure ResetAutoSync;
    procedure ResetIsKeepDeleted;
    procedure ResetIsBackupNow;
    procedure ResetIsDisable;
  private
    procedure FindDestination;
    procedure ResetDestinaiton;
    procedure AddDestination( Path : string );
    procedure RemoveDestination( Path : string );
  private
    procedure FindFilterChange;
    procedure ResetIncludeFilter;
    procedure ResetExcludeFilter;
    procedure BackupNow;
  private
    function IsChange( f : TFont ): Boolean;
  end;

const
  ShowConfirm_ApplyAllItem = 'Are you sure to apply changed settings to all backup items?';

var
  FrmLocalBackupPro: TFrmLocalBackupPro;

implementation

uses ULocalBackupInfo, ULocalBackupFace, UIconUtil, UMyUtil, UFormUtil, ULocalBackupControl,
     UFormBackupItemApply, UFormBackupProperties, UFormLocalBackupPath;

{$R *.dfm}

procedure TFrmLocalBackupPro.ApplytoAllBackupItems1Click(Sender: TObject);
var
  BackupPathList : TStringList;
  LocalBackupProApplyHandle : TLocalBackupProApplyHandle;
begin
    // 确认
  if not MyMessageBox.ShowConfirm( ShowConfirm_ApplyAllItem ) then
    Exit;

  BackupPathList := FrmLocalBackupProUtil.getBackupItemList;

  LocalBackupProApplyHandle := TLocalBackupProApplyHandle.Create( BackupPathList );
  LocalBackupProApplyHandle.Update;
  LocalBackupProApplyHandle.Free;

  BackupPathList.Free;

  HindeApplyBtn;
end;

procedure TFrmLocalBackupPro.ApplytoMoreBackupItems1Click(Sender: TObject);
var
  BackupPathList : TStringList;
  LocalBackupProApplyHandle : TLocalBackupProApplyHandle;
begin
  BackupPathList := FrmLocalBackupProUtil.getBackupItemList;
  frmBackupItemsApply.SetBackupItem( BackupPathList, ShowBackupPath );
  BackupPathList.free;

  if frmBackupItemsApply.ShowModal = mrCancel then
    Exit;

  BackupPathList := frmBackupItemsApply.getSelectItems;

    // 应用
  LocalBackupProApplyHandle := TLocalBackupProApplyHandle.Create( BackupPathList );
  LocalBackupProApplyHandle.Update;
  LocalBackupProApplyHandle.Free;

  BackupPathList.Free;

    // 隐藏
  HindeApplyBtn;
end;

procedure TFrmLocalBackupPro.BtnApplyClick(Sender: TObject);
var
  BackupPathList : TStringList;
  LocalBackupProApplyHandle : TLocalBackupProApplyHandle;
begin
  BackupPathList := MyStringList.getString( ShowBackupPath );

  LocalBackupProApplyHandle := TLocalBackupProApplyHandle.Create( BackupPathList );
  LocalBackupProApplyHandle.Update;
  LocalBackupProApplyHandle.Free;

  BackupPathList.Free;

  HindeApplyBtn;
end;

procedure TFrmLocalBackupPro.btnApplytoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt:TPoint;
begin
  GetCursorPos(pt);
  PmApply.Popup((pt.x-x),(pt.y+(btnApplyTo.Height-y)));
end;

procedure TFrmLocalBackupPro.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmLocalBackupPro.cbbSyncTimeTypeChange(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TFrmLocalBackupPro.chkIsAutoSyncClick(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TFrmLocalBackupPro.chkIsBackupNowClick(Sender: TObject);
begin
  FrmLocalBackupProUtil.SetChangeColor( chkIsBackupNow.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.chkIsDisableClick(Sender: TObject);
begin
  FrmLocalBackupProUtil.SetChangeColor( chkIsDisable.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.chkIsKeepDeletedClick(Sender: TObject);
begin
  seKeepEditionCount.Enabled := chkIsKeepDeleted.Checked;
  FileDeletedChange;
end;

procedure TFrmLocalBackupPro.ExcludeFilterChange;
begin
  FrmLocalBackupProUtil.SetChangeColor( FrameFilter.gbExcludeFilter.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.FileDeletedChange;
begin
  FrmLocalBackupProUtil.SetChangeColor( chkIsKeepDeleted.Font );
  FrmLocalBackupProUtil.SetChangeColor( lbKeepEditionCount.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.FormCreate(Sender: TObject);
begin
  FrameFilter.IniFrame;
  LvBackupItem.SmallImages := MyIcon.getSysIcon;
  LvDestination.SmallImages := MyIcon.getSysIcon;
  ListviewUtil.BindSort( LvBackupItem );
  LastDesPathList := TStringList.Create;
  siLang_FrmLocalBackupProChangeLanguage( nil );
end;

procedure TFrmLocalBackupPro.FormDestroy(Sender: TObject);
begin
  LastDesPathList.Free;
end;

procedure TFrmLocalBackupPro.FrameExcludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := MyStringList.getString( ShowBackupPath );

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameExclude.btnSelectFileClick( Sender );

  SelectPathList.Free;
end;

procedure TFrmLocalBackupPro.FrameExcludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  ExcludeFilterChange;
  FrameFilter.FrameExclude.LvMaskDeletion( Sender, Item );
end;

procedure TFrmLocalBackupPro.FrameExcludeLvMaskInsert(Sender: TObject;
  Item: TListItem);
begin
  ExcludeFilterChange;
end;

procedure TFrmLocalBackupPro.FrameIncludebtnSelectFileClick(Sender: TObject);
var
  SelectPathList : TStringList;
begin
  SelectPathList := MyStringList.getString( ShowBackupPath );

  FrameFilter.SetRootPathList( SelectPathList );
  FrameFilter.FrameInclude.btnSelectFileClick( Sender );

  SelectPathList.Free;
end;

procedure TFrmLocalBackupPro.FrameIncludeLvMaskDeletion(Sender: TObject;
  Item: TListItem);
begin
  IncludeFilterChange;
  FrameFilter.FrameInclude.LvMaskDeletion( Sender, Item );
end;

procedure TFrmLocalBackupPro.FrameIncludeLvMaskInsert(Sender: TObject;
  Item: TListItem);
begin
  IncludeFilterChange;
end;

procedure TFrmLocalBackupPro.HindeApplyBtn;
begin
  BtnApply.Enabled := False;
  btnApplyto.Enabled := False;
end;

procedure TFrmLocalBackupPro.IncludeFilterChange;
begin
  FrmLocalBackupProUtil.SetChangeColor( FrameFilter.gbIncludeFilter.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.LvBackupItemDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TFrmLocalBackupPro.LvBackupItemMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  SelectItem : TListItem;
  ItemData : TLvLocalBackupSourceProData;
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

procedure TFrmLocalBackupPro.LvBackupItemSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  ItemData : TLvLocalBackupSourceProData;
begin
  if not Selected then
    Exit;

  ItemData := Item.Data;
  ShowOptions( ItemData.FullPath );
end;

procedure TFrmLocalBackupPro.LvDestinationClick(Sender: TObject);
begin
  if DesPathCount <> FrmLocalBackupProUtil.getDesPathCount then
  begin
    FrmLocalBackupProUtil.SetChangeColor( gbDestination.Font );
    ShowApplyBtn;
  end;
end;

procedure TFrmLocalBackupPro.LvDestinationDeletion(Sender: TObject;
  Item: TListItem);
var
  ItemData : TObject;
begin
  ItemData := Item.Data;
  ItemData.Free;
end;

procedure TFrmLocalBackupPro.RefreshShowOptions(BackupPath: string);
begin
  if ShowBackupPath = BackupPath then
    ShowBackupPath := '';
  ShowOptions( BackupPath );
end;

procedure TFrmLocalBackupPro.seKeepEditionCountChange(Sender: TObject);
begin
  FileDeletedChange;
end;

procedure TFrmLocalBackupPro.SelectLvBackupPath(BackupPath: string);
var
  i : Integer;
  LvBackupPathData : TLvLocalBackupSourceProData;
begin
  for i := 0 to LvBackupItem.Items.Count - 1 do
  begin
    LvBackupPathData := LvBackupItem.Items[i].Data;
    LvBackupItem.Items[i].Selected := LvBackupPathData.FullPath = BackupPath;
  end;
end;

procedure TFrmLocalBackupPro.seSyncTimeValueChange(Sender: TObject);
begin
  SyncTimeChange;
end;

procedure TFrmLocalBackupPro.SetBackupConfigInfo(
  BackupConfig: TLocalBackupConfigInfo);
var
  LocalBackupProSetConfigHandle : TLocalBackupProSetConfigHandle;
begin
  LocalBackupProSetConfigHandle := TLocalBackupProSetConfigHandle.Create( BackupConfig );
  LocalBackupProSetConfigHandle.Update;
  LocalBackupProSetConfigHandle.Free;
end;

procedure TFrmLocalBackupPro.ShowApplyBtn;
begin
  BtnApply.Enabled := True;
  btnApplyto.Enabled := True;
end;

procedure TFrmLocalBackupPro.ShowOptions(BackupPath: string);
var
  BackupConfigInfo : TLocalBackupConfigInfo;
begin
    // 已选中
  if ShowBackupPath = BackupPath then
    Exit;

  ShowBackupPath := BackupPath;

    // 选择 ListView
  edtBackupPath.Text := BackupPath;
  SelectLvBackupPath( BackupPath );

  BackupConfigInfo := MyLocalBackupSourceReadUtil.getConfig( BackupPath );
  if BackupConfigInfo = nil then // 路径不存在
    Exit;
  SetBackupConfigInfo( BackupConfigInfo );
  BackupConfigInfo.Free;

    // 隐藏 Apply
  HindeApplyBtn;
end;


procedure TFrmLocalBackupPro.siLang_FrmLocalBackupProChangeLanguage(
  Sender: TObject);
begin
  LvBackupItem.Columns[0].Caption := frmBackupProperties.siLang_frmBackupProperties.GetText( 'lvBackupItem' );

  with cbbSyncTimeType.Items do
  begin
    Clear;
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrMin' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrHour' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrDay' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrWeek' ) );
    Add( frmBackupProperties.siLang_frmBackupProperties.GetText( 'StrMonth' ) );
  end;

  with LvDestination do
  begin
    Columns[ 0 ].Caption := frmSelectLocalBackupPath.siLang_frmSelectLocalBackupPath.GetText( 'lvDestination' );
    Columns[ 1 ].Caption := frmSelectLocalBackupPath.siLang_frmSelectLocalBackupPath.GetText( 'lvFreeSpace' );
  end;

  FrameFilter.RefreshLanguage;
end;

procedure TFrmLocalBackupPro.SyncTimeChange;
begin
  FrmLocalBackupProUtil.SetChangeColor( chkIsAutoSync.Font );
  ShowApplyBtn;
end;

procedure TFrmLocalBackupPro.tmrHideSaveTimer(Sender: TObject);
begin
  FrmLocalBackupProUtil.HideSave;
end;

{ FrmBackupProUtil }

class function FrmLocalBackupProUtil.getBackupItemList: TStringList;
var
  LvBackupItem : TListView;
  i : Integer;
  LvBackupData : TLvLocalBackupSourceProData;
begin
  Result := TStringList.Create;

  LvBackupItem := FrmLocalBackupPro.LvBackupItem;
  for i := 0 to LvBackupItem.Items.Count - 1 do
  begin
    LvBackupData := LvBackupItem.Items[i].Data;
    Result.Add( LvBackupData.FullPath );
  end;
end;

class function FrmLocalBackupProUtil.getDesPathCount: Integer;
var
  LvDestination : TListView;
  i : Integer;
begin
  Result := 0;
  LvDestination := FrmLocalBackupPro.LvDestination;
  for i := 0 to LvDestination.Items.Count - 1 do
    if LvDestination.Items[i].Checked then
      Inc( Result );
end;

class function FrmLocalBackupProUtil.getSelectDesPathList: TStringList;
var
  LvDestination : TListView;
  ItemData : TLvLocalBackupDesProData;
  i : Integer;
begin
  Result := TStringList.Create;
  LvDestination := FrmLocalBackupPro.LvDestination;
  for i := 0 to LvDestination.Items.Count - 1 do
    if LvDestination.Items[i].Checked then
    begin
      ItemData := LvDestination.Items[i].Data;
      Result.Add( ItemData.FullPath );
    end;
end;

class procedure FrmLocalBackupProUtil.HideSave;
begin
  with FrmLocalBackupPro do
  begin
    LvBackupItem.Columns[0].Width := 140;
    LvBackupItem.Columns[1].Width := 0;
    tmrHideSave.Enabled := False;
  end;
end;

class function FrmLocalBackupProUtil.IsChangeColor(f: TFont): Boolean;
begin
  Result := f.Color = clBlue;
end;

class procedure FrmLocalBackupProUtil.SetChangeColor(f: TFont);
begin
  f.Color := clBlue;
end;

class procedure FrmLocalBackupProUtil.SetUnChangeColor(f: TFont);
begin
  f.Color := clBlack;
end;

class procedure FrmLocalBackupProUtil.ShowSave(BackupPathList: TStringList);
var
  LvBackupItem : TListView;
  i : Integer;
  LvBackupData : TLvLocalBackupSourceProData;
begin
  LvBackupItem := FrmLocalBackupPro.LvBackupItem;
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

  FrmLocalBackupPro.tmrHideSave.Enabled := True;
end;

{ TLocalBackupProSetConfigHandle }

constructor TLocalBackupProSetConfigHandle.Create(
  _BackupConfigInfo: TLocalBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TLocalBackupProSetConfigHandle.SetDestination;
var
  LastDesPathList : TStringList;
  DesPathList : TStringList;
  LvDestination : TListView;
  i : Integer;
  ItemData : TLvLocalBackupDesProData;
  FreeSpaceStr : string;
  IsSelect : Boolean;
begin
  LastDesPathList := FrmLocalBackupPro.LastDesPathList;
  LastDesPathList.Clear;

  DesPathList := BackupConfigInfo.DesPathList;
  LvDestination := FrmLocalBackupPro.LvDestination;
  for i := 0 to LvDestination.Items.Count - 1 do
  begin
    ItemData := LvDestination.Items[i].Data;
    FreeSpaceStr := MySize.getFileSizeStr( MyHardDisk.getHardDiskFreeSize( ItemData.FullPath ) );
    LvDestination.Items[i].SubItems[0] := FreeSpaceStr;
    IsSelect := DesPathList.IndexOf( ItemData.FullPath ) >= 0;
    LvDestination.Items[i].Checked := IsSelect;
    if IsSelect then
      LastDesPathList.Add( ItemData.FullPath );
  end;

  FrmLocalBackupPro.DesPathCount := FrmLocalBackupProUtil.getDesPathCount;
  FrmLocalBackupProUtil.SetUnChangeColor( FrmLocalBackupPro.gbDestination.Font );
end;

procedure TLocalBackupProSetConfigHandle.SetFilter;
begin
  with FrmLocalBackupPro do
  begin
    FrameFilter.FrameInclude.LvMask.Clear;
    FrameFilter.FrameExclude.LvMask.Clear;
    FrameFilter.SetIncludeFilterList( BackupConfigInfo.IncludeFilterList );
    FrameFilter.SetExcludeFilterList( BackupConfigInfo.ExcludeFilterList );

    FrmLocalBackupProUtil.SetUnChangeColor( FrameFilter.gbIncludeFilter.Font );
    FrmLocalBackupProUtil.SetUnChangeColor( FrameFilter.gbExcludeFilter.Font );
  end;
end;

procedure TLocalBackupProSetConfigHandle.SetGanernal;
begin
  with FrmLocalBackupPro do
  begin
    chkIsAutoSync.Checked := BackupConfigInfo.IsAuctoSync;
    seSyncTimeValue.Value := BackupConfigInfo.SyncTimeValue;
    cbbSyncTimeType.ItemIndex := BackupConfigInfo.SyncTimeType;
    ChkIsBackupNow.Checked := BackupConfigInfo.IsBackupupNow;
    ChkIsDisable.Checked := BackupConfigInfo.IsDisable;
    chkIsKeepDeleted.Checked := BackupConfigInfo.IsKeepDeleted;
    seKeepEditionCount.Value := BackupConfigInfo.KeepEditionCount;

    FrmLocalBackupProUtil.SetUnChangeColor( chkIsAutoSync.Font );
    FrmLocalBackupProUtil.SetUnChangeColor( ChkIsBackupNow.Font );
    FrmLocalBackupProUtil.SetUnChangeColor( ChkIsDisable.Font );
    FrmLocalBackupProUtil.SetUnChangeColor( chkIsKeepDeleted.Font );
    FrmLocalBackupProUtil.SetUnChangeColor( lbKeepEditionCount.Font );
  end;
end;

procedure TLocalBackupProSetConfigHandle.Update;
begin
  SetGanernal;
  SetDestination;
  SetFilter;
end;

{ TLocalBackupProApplyHandle }

procedure TLocalBackupProApplyHandle.AddDestination(Path: string);
var
  i : Integer;
  BackupPath, PathType : string;
  IsKeepDeleted : Boolean;
  LocalBackupSourceAddDesHandle : TLocalBackupSourceAddDesHandle;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    PathType := MyFilePath.getPathType( BackupPath );

      // 读取 是否保存 删除文件
    IsKeepDeleted := MyLocalBackupSourceReadUtil.getIsKeepDeleted( BackupPath );

    LocalBackupSourceAddDesHandle := TLocalBackupSourceAddDesHandle.Create( BackupPath );
    LocalBackupSourceAddDesHandle.SetDesPath( Path );
    LocalBackupSourceAddDesHandle.SetSourcePathType( PathType );
    LocalBackupSourceAddDesHandle.SetDeletedInfo( IsKeepDeleted, 0 );
    LocalBackupSourceAddDesHandle.SetSpaceInfo( 0 , 0 );
    LocalBackupSourceAddDesHandle.Update;
    LocalBackupSourceAddDesHandle.Free;
  end;
end;

procedure TLocalBackupProApplyHandle.BackupNow;
var
  i : Integer;
  BackupPath : string;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];
    MyLocalBackupSourceControl.BackupSelected( BackupPath );
  end;
end;

constructor TLocalBackupProApplyHandle.Create(_BackupPathList: TStringList);
begin
  BackupPathList := _BackupPathList;
  IsBackupNow := False;
end;

procedure TLocalBackupProApplyHandle.FindDestination;
begin
  if IsChange( FrmLocalBackupPro.gbDestination.Font ) then
  begin
    ResetDestinaiton;
    IsBackupNow := True;
  end;
end;

procedure TLocalBackupProApplyHandle.FindFilterChange;
begin
  with FrmLocalBackupPro do
  begin
    if IsChange( FrameFilter.gbIncludeFilter.Font ) then
    begin
      ResetIncludeFilter;
      IsBackupNow := True;
    end;

    if IsChange( FrameFilter.gbExcludeFilter.Font )  then
    begin
      ResetExcludeFilter;
      IsBackupNow := True;
    end;
  end;
end;

procedure TLocalBackupProApplyHandle.FindGenernalChange;
begin
  with FrmLocalBackupPro do
  begin
    if IsChange( chkIsAutoSync.Font )  then
      ResetAutoSync;
    if IsChange( ChkIsBackupNow.Font ) then
      ResetIsBackupNow;
    if IsChange( ChkIsDisable.Font ) then
      ResetIsDisable;
    if IsChange( chkIsKeepDeleted.Font )  then
    begin
      FrmLocalBackupProUtil.SetUnChangeColor( lbKeepEditionCount.Font );
      ResetIsKeepDeleted;
    end;
  end;
end;

function TLocalBackupProApplyHandle.IsChange(f: TFont): Boolean;
begin
  Result := FrmLocalBackupProUtil.IsChangeColor( f );
  if Result then
    FrmLocalBackupProUtil.SetUnChangeColor( f );
end;

procedure TLocalBackupProApplyHandle.RemoveDestination(Path: string);
var
  i : Integer;
  BackupPath : string;
  LocalBackupSourceRemoveDesHandle : TLocalBackupSourceRemoveDesHandle;
begin
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    LocalBackupSourceRemoveDesHandle := TLocalBackupSourceRemoveDesHandle.Create( BackupPath );
    LocalBackupSourceRemoveDesHandle.SetDesPath( Path );
    LocalBackupSourceRemoveDesHandle.Update;
    LocalBackupSourceRemoveDesHandle.Free;
  end;
end;

procedure TLocalBackupProApplyHandle.ResetAutoSync;
var
  IsAutoSync : Boolean;
  SyncTimeType, SyncTimeValue : Integer;
  i : Integer;
  BackupPath : string;
  LocalBackupSourceSetAutoSyncHandle : TLocalBackupSourceSetAutoSyncHandle;
begin
  with FrmLocalBackupPro do
  begin
    IsAutoSync := chkIsAutoSync.Checked;
    SyncTimeType := cbbSyncTimeType.ItemIndex;
    SyncTimeValue := seSyncTimeValue.Value;
  end;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    LocalBackupSourceSetAutoSyncHandle := TLocalBackupSourceSetAutoSyncHandle.Create( BackupPath );
    LocalBackupSourceSetAutoSyncHandle.SetIsAutoSync( IsAutoSync );
    LocalBackupSourceSetAutoSyncHandle.SetSyncInterval( SyncTimeType, SyncTimeValue );
    LocalBackupSourceSetAutoSyncHandle.Update;
    LocalBackupSourceSetAutoSyncHandle.Free;
  end;
end;


procedure TLocalBackupProApplyHandle.ResetDestinaiton;
var
  NewSelectPathList : TStringList;
  LastSelectPathList : TStringList;
  i : Integer;
  SelectPath : string;
begin
  NewSelectPathList := FrmLocalBackupProUtil.getSelectDesPathList;
  LastSelectPathList := FrmLocalBackupPro.LastDesPathList;

    // 遍历当前选择，寻找新增路径
  for i := 0 to NewSelectPathList.Count - 1 do
  begin
    SelectPath := NewSelectPathList[i];
    if LastSelectPathList.IndexOf( SelectPath ) < 0 then
      AddDestination( SelectPath );
  end;

    // 遍历上次选择，寻找删除路径
  for i := 0 to LastSelectPathList.Count - 1 do
  begin
    SelectPath := LastSelectPathList[i];
    if NewSelectPathList.IndexOf( SelectPath ) < 0 then
      RemoveDestination( SelectPath );
  end;

    // 复位，设置上次选择
  LastSelectPathList.Clear;
  for i := 0 to NewSelectPathList.Count - 1 do
    LastSelectPathList.Add( NewSelectPathList[i] );

  NewSelectPathList.Free;
end;

procedure TLocalBackupProApplyHandle.ResetExcludeFilter;
var
  IncludeFliterList : TFileFilterList;
  i, j : Integer;
  BackupPath, FilterType, FilterStr : string;
  LocalBackupSourceExcludeFilterClearHandle : TLocalBackupSourceExcludeFilterClearHandle;
  LocalBackupSourceExcludeFilterAddHandle : TLocalBackupSourceExcludeFilterAddHandle;
begin
  IncludeFliterList := FrmLocalBackupPro.FrameFilter.FrameExclude.getFilterList;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

      // 清空旧的
    LocalBackupSourceExcludeFilterClearHandle := TLocalBackupSourceExcludeFilterClearHandle.Create( BackupPath );
    LocalBackupSourceExcludeFilterClearHandle.Update;
    LocalBackupSourceExcludeFilterClearHandle.Free;

      // 添加新的过滤器
    for j := 0 to IncludeFliterList.Count - 1 do
    begin
      FilterType := IncludeFliterList[j].FilterType;
      FilterStr := IncludeFliterList[j].FilterStr;

      LocalBackupSourceExcludeFilterAddHandle := TLocalBackupSourceExcludeFilterAddHandle.Create( BackupPath );
      LocalBackupSourceExcludeFilterAddHandle.SetFilterInfo( FilterType, FilterStr );
      LocalBackupSourceExcludeFilterAddHandle.Update;
      LocalBackupSourceExcludeFilterAddHandle.Free;
    end;
  end;

  IncludeFliterList.Free;
end;

procedure TLocalBackupProApplyHandle.ResetIncludeFilter;
var
  IncludeFliterList : TFileFilterList;
  i, j : Integer;
  BackupPath, FilterType, FilterStr : string;
  LocalBackupSourceIncludeFilterClearHandle : TLocalBackupSourceIncludeFilterClearHandle;
  LocalBackupSourceIncludeFilterAddHandle : TLocalBackupSourceIncludeFilterAddHandle;
begin
  IncludeFliterList := FrmLocalBackupPro.FrameFilter.FrameInclude.getFilterList;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

      // 清空旧的
    LocalBackupSourceIncludeFilterClearHandle := TLocalBackupSourceIncludeFilterClearHandle.Create( BackupPath );
    LocalBackupSourceIncludeFilterClearHandle.Update;
    LocalBackupSourceIncludeFilterClearHandle.Free;

      // 添加新的过滤器
    for j := 0 to IncludeFliterList.Count - 1 do
    begin
      FilterType := IncludeFliterList[j].FilterType;
      FilterStr := IncludeFliterList[j].FilterStr;

      LocalBackupSourceIncludeFilterAddHandle := TLocalBackupSourceIncludeFilterAddHandle.Create( BackupPath );
      LocalBackupSourceIncludeFilterAddHandle.SetFilterInfo( FilterType, FilterStr );
      LocalBackupSourceIncludeFilterAddHandle.Update;
      LocalBackupSourceIncludeFilterAddHandle.Free;
    end;
  end;

  IncludeFliterList.Free;
end;

procedure TLocalBackupProApplyHandle.ResetIsBackupNow;
var
  IsBackupNow : Boolean;
  i : Integer;
  BackupPath : string;
  LocalBackupSourceSetIsBackupNowHandle : TLocalBackupSourceSetIsBackupNowHandle;
begin
  IsBackupNow := FrmLocalBackupPro.ChkIsBackupNow.Checked;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    LocalBackupSourceSetIsBackupNowHandle := TLocalBackupSourceSetIsBackupNowHandle.Create( BackupPath );
    LocalBackupSourceSetIsBackupNowHandle.SetIsBackupNow( IsBackupNow );
    LocalBackupSourceSetIsBackupNowHandle.Update;
    LocalBackupSourceSetIsBackupNowHandle.Free;
  end;
end;

procedure TLocalBackupProApplyHandle.ResetIsDisable;
var
  IsDisable : Boolean;
  i : Integer;
  BackupPath : string;
  LocalBackupSourceSetIsDisableHandle : TLocalBackupSourceSetIsDisableHandle;
begin
  IsDisable := FrmLocalBackupPro.ChkIsDisable.Checked;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    LocalBackupSourceSetIsDisableHandle := TLocalBackupSourceSetIsDisableHandle.Create( BackupPath );
    LocalBackupSourceSetIsDisableHandle.SetIsDisable( IsDisable );
    LocalBackupSourceSetIsDisableHandle.Update;
    LocalBackupSourceSetIsDisableHandle.Free;
  end;
end;

procedure TLocalBackupProApplyHandle.ResetIsKeepDeleted;
var
  IsKeepDeleted : Boolean;
  KeepEditionCount : Integer;
  i : Integer;
  BackupPath : string;
  LocalBackupSourceSetDeleteHandle : TLocalBackupSourceSetDeleteHandle;
begin
  with FrmLocalBackupPro do
  begin
    IsKeepDeleted := chkIsKeepDeleted.Checked;
    KeepEditionCount := seKeepEditionCount.Value;
  end;

  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPath := BackupPathList[i];

    LocalBackupSourceSetDeleteHandle := TLocalBackupSourceSetDeleteHandle.Create( BackupPath );
    LocalBackupSourceSetDeleteHandle.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
    LocalBackupSourceSetDeleteHandle.Update;
    LocalBackupSourceSetDeleteHandle.Free;
  end;
end;

procedure TLocalBackupProApplyHandle.Update;
begin
    // 显示保存界面
  FrmLocalBackupProUtil.ShowSave( BackupPathList );

    // 一般配置 变化
  FindGenernalChange;

    // 备份目标 变化
  FindDestination;

    // 过滤器配置 变化
  FindFilterChange;

    // 立刻 备份修改 过滤器的 BackupItem
  if IsBackupNow then
    BackupNow;
end;

end.
