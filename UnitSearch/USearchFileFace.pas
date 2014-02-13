unit USearchFileFace;

interface

uses UChangeInfo, ComCtrls, SysUtils, UMyUtil, StdCtrls, UIconUtil, Generics.Collections, VirtualTrees;

type

{$Region ' 搜索结果 处理 ' }

  TSearchFileLvData = class
  public
    FilePath, FileType : string;
    LocationID, OwnerID : string;
    FileSize : Int64;
    FileTime : TDateTime;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
    BackupPath : string;
  public
    InputPassword, SaveFileName : string;
  public
    constructor Create( _FilePath, _FileType : string );
    procedure SetFilePc( _LocationID, _OwnerID : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure SetBackupPath( _BackupPath : string );
  end;

  TSearchFileLvDataList = class( TObjectList< TSearchFileLvData > )
  public
    constructor Create;
  end;


    // 添加到 Search ListView 界面
  TSearchFileLvAddInfo = class( TChangeInfo )
  private
    SearchNum : Integer;
  public
    LocationID, OwnerID : string;
    LocationName, OwnerName : string;
    FilePath, FileType : string;
    FileSize : Int64;
    FileTime : TDateTime;
    BackupPath : string;
    IsEncrypt : Boolean;
    PasswordMD5, PasswordHint : string;
  public
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetFilePcID( _LocationID, _OwnerID : string );
    procedure SetFilePcName( _LocationName, _OwnerName : string );
    procedure SetFileBase( _FilePath, _FileType : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetBackupPath( _BackupPath : string );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure Update;override;
  end;

  {$EndRegion}

{$Region ' 开始/结束 搜索 ' }

    // 开始
  TSearchFileLvStartInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // 结束
  TSearchFileLvStopInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 连接/断开 服务器 ' }

  TConnServerSearchFace = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  TLostServerSearchFace = class( TChangeInfo )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' My Search Down File ' }

  TVstSearchDownData = record
  public
    SourcePcID, SourceFilePath : WideString;
    DownloadPath, LocationPcID : WideString;
    SourcePcName, LocationPcName : WideString;
    FileSize, CompletedSize : Int64;
    Status : WideString;
  public
    IsLocationOnline : Boolean;
  end;
  PVstSearchDownData = ^TVstSearchDownData;

    // 辅助类
  VstSearchDownUtil = class
  public
    class function getStatusIcon( Status : string ): Integer;
  end;

    // 父类
  TVstSearchDownChange = class( TChangeInfo )
  public
    vstSearchDown : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // Location 上线
  TVstSearchDownLocationOnline = class( TVstSearchDownChange )
  private
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure Update;override;
  end;

    // 修改
  TVstSearchDownWrite = class( TVstSearchDownChange )
  public
    SourcePcID, SourceFilePath : string;
  protected
    SearchDownNode : PVirtualNode;
    SearchDownData : PVstSearchDownData;
  public
    constructor Create( _SourcePcID, _SourceFilePath : string );
  protected
    function FindSearchDownNode : Boolean;
    procedure RefreshNode;
  end;

    // 添加
  TVstSearchDownAdd = class( TVstSearchDownWrite )
  public
    FileSize, CompletedSize : Int64;
    DownlaodPath, LocationPcID : string;
    SourcePcName, LocationName : string;
    Status : string;
  public
    procedure SetDownInfo( _DownlaodPath, _LocationPcID : string );
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetNameInfo( _SourcePcName, _LocationName : string );
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 设置 状态
  TVstSearchDownSetStatus = class( TVstSearchDownWrite )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 上传 Pc 离线
  TVstSearchDownOffline = class( TVstSearchDownWrite )
  public
    procedure Update;override;
  end;

    // 添加 已完成空间
  TVstSearchDownAddCompletedSpace = class( TVstSearchDownWrite )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

    // 设置 已完成 空间
  TVstSearchDownSetCompletedSpace = class( TVstSearchDownWrite )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;override;
  end;

    // 删除
  TVstSearchDownRemove = class( TVstSearchDownWrite )
  public
    procedure Update;override;
  end;

{$EndRegion}

const
  FileType_AllTypes = 'All Types';
  FileType_SourceFile = 'Source File';
  FileType_BackupCopy = 'Backup Copy';

//  Label_SearchCount = '%d Files';
//  Label_Searching = 'Searching...';
//  Label_SearchComplete = 'Search Completed';
//
//  BtnSearch_Search = 'Search';
//  BtnSearch_Stop = 'Stop';

  DownSearchStatus_Waiting = 'Waiting';
  DownSearchStatus_Loading = 'Loading';
  DownSearchStatus_Loaded = 'Completed';
  DownSearchStatus_Offline = 'Offline';

  LvSearchDown_FileSize = 0;
  LvSearchDown_Owner = 1;
  LvSearchDown_Location = 2;
  LvSearchDown_Status = 3;
var
  SearchFile_IsConnServer : Boolean = False;
  SearchCount : Integer = 0;

  MySearchFileFace : TMyChildFaceChange;
implementation

uses UMainForm, UMyFileSearch;

{ TSearchFileLvFaceAddInfo }

procedure TSearchFileLvAddInfo.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

procedure TSearchFileLvAddInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TSearchFileLvAddInfo.SetFileBase(_FilePath, _FileType: string);
begin
  FilePath := _FilePath;
  FileType := _FileType;
end;

procedure TSearchFileLvAddInfo.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TSearchFileLvAddInfo.SetFilePcID(_LocationID, _OwnerID: string);
begin
  LocationID := _LocationID;
  OwnerID := _OwnerID;
end;

procedure TSearchFileLvAddInfo.SetFilePcName(_LocationName,
  _OwnerName: string);
begin
  LocationName := _LocationName;
  OwnerName := _OwnerName;
end;

procedure TSearchFileLvAddInfo.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

procedure TSearchFileLvAddInfo.Update;
var
  LvFileSearch  : TListView;
  SearchFileLvData : TSearchFileLvData;
  lbSearchCount : TLabel;
  TempStr : string;
begin
  if SearchNum <> Number_FileSearch then
    Exit;

  LvFileSearch := frmMainForm.lvSearchFile;
  with LvFileSearch.Items.Add do
  begin
    Caption := ExtractFileName( FilePath );
    SubItems.Add( OwnerName );
    SubItems.Add( BackupPath );
    SubItems.Add( MySize.getFileSizeStr( FileSize ) );
    SubItems.Add( DateTimeToStr( FileTime ) );
    if FileType = FileType_SourceFile then
      TempStr := frmMainForm.siLang_frmMainForm.GetText( 'SourceFile' )
    else
      TempStr := frmMainForm.siLang_frmMainForm.GetText( 'BackupCopy' );
    SubItems.Add( TempStr );
    SubItems.Add( LocationName );
    ImageIndex := MyIcon.getIconByFilePath( FilePath );

    SearchFileLvData := TSearchFileLvData.Create( FilePath, FileType );
    SearchFileLvData.SetFilePc( LocationID, OwnerID );
    SearchFileLvData.SetFileInfo( FileSize, FileTime );
    SearchFileLvData.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
    SearchFileLvData.SetBackupPath( BackupPath );

    Data := SearchFileLvData;
  end;

  Inc( SearchCount );
  lbSearchCount := frmMainForm.lbSearchCount;
  lbSearchCount.Caption := Format( frmMainForm.siLang_frmMainForm.GetText( 'SearchCount' ), [SearchCount] );
end;

{ TSearchFileLvData }

constructor TSearchFileLvData.Create(_FilePath, _FileType: string);
begin
  FilePath := _FilePath;
  FileType := _FileType;
  InputPassword := '';
end;

procedure TSearchFileLvData.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

procedure TSearchFileLvData.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TSearchFileLvData.SetFilePc(_LocationID, _OwnerID: string);
begin
  LocationID := _LocationID;
  OwnerID := _OwnerID;
end;

procedure TSearchFileLvData.SetFileInfo(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

{ TSearchFileStartInfo }

procedure TSearchFileLvStartInfo.Update;
var
  lbSearch, lbSearchCount : TLabel;
  btnSearch : TButton;
begin
  lbSearch := frmMainForm.lbSearchTips;
  lbSearchCount := frmMainForm.lbSearchCount;
  btnSearch := frmMainForm.btnSearch;

  btnSearch.Enabled := SearchFile_IsConnServer;
  btnSearch.Tag := Tag_Searching;
  btnSearch.Caption := frmMainForm.siLang_frmMainForm.GetText( 'Stop' );

  lbSearch.Visible := True;
  lbSearch.Caption := frmMainForm.siLang_frmMainForm.GetText( 'Searching' );

  lbSearchCount.Visible := True;
  SearchCount := 0;
  lbSearchCount.Caption := Format( frmMainForm.siLang_frmMainForm.GetText( 'SearchCount' ), [SearchCount] );
end;

{ TSearchFileStopInfo }

procedure TSearchFileLvStopInfo.Update;
var
  lbSearch, lbSearchCount : TLabel;
  btnSearch : TButton;
begin
  lbSearch := frmMainForm.lbSearchTips;
  lbSearchCount := frmMainForm.lbSearchCount;
  btnSearch := frmMainForm.btnSearch;

  btnSearch.Enabled := SearchFile_IsConnServer;
  btnSearch.Tag := Tag_NoSearch;
  btnSearch.Caption := frmMainForm.siLang_frmMainForm.GetText( 'Search' );

  lbSearch.Caption := frmMainForm.siLang_frmMainForm.GetText( 'SearchComplete' );
end;

{ TConnServerSearchFace }

procedure TConnServerSearchFace.Update;
begin
  SearchFile_IsConnServer := True;
  frmMainForm.btnSearch.Enabled := True;
end;

{ TLostServerSearchFace }

procedure TLostServerSearchFace.Update;
begin
  SearchFile_IsConnServer := False;
  frmMainForm.btnSearch.Enabled := False;
end;

{ TSearchFileLvDataList }

constructor TSearchFileLvDataList.Create;
begin
  inherited Create( False );
end;

{ TVstSearchDownChange }

procedure TVstSearchDownChange.Update;
begin
  vstSearchDown := frmMainForm.vstSearchDown;
end;

{ TVstSearchDownWrite }

constructor TVstSearchDownWrite.Create(_SourcePcID, _SourceFilePath: string);
begin
  SourcePcID := _SourcePcID;
  SourceFilePath := _SourceFilePath;
end;

function TVstSearchDownWrite.FindSearchDownNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSearchDownData;
begin
  Result := False;

  SelectNode := vstSearchDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSearchDown.GetNodeData( SelectNode );
    if ( SelectData.SourcePcID = SourcePcID ) and
       ( SelectData.SourceFilePath = SourceFilePath )
    then
    begin
      SearchDownNode := SelectNode;
      SearchDownData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstSearchDownWrite.RefreshNode;
begin
  vstSearchDown.RepaintNode( SearchDownNode );
end;

{ TVstSearchDownAdd }

procedure TVstSearchDownAdd.SetDownInfo(_DownlaodPath, _LocationPcID: string);
begin
  DownlaodPath := _DownlaodPath;
  LocationPcID := _LocationPcID;
end;

procedure TVstSearchDownAdd.SetNameInfo(_SourcePcName, _LocationName: string);
begin
  SourcePcName := _SourcePcName;
  LocationName := _LocationName;
end;

procedure TVstSearchDownAdd.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstSearchDownAdd.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstSearchDownAdd.Update;
begin
  inherited;

    // 已存在
  if FindSearchDownNode then
    Exit;

    // 添加
  SearchDownNode := vstSearchDown.InsertNode( vstSearchDown.RootNode, amAddChildFirst );
  SearchDownData := vstSearchDown.GetNodeData( SearchDownNode );
  SearchDownData.SourcePcID := SourcePcID;
  SearchDownData.SourceFilePath := SourceFilePath;
  SearchDownData.DownloadPath := DownlaodPath;
  SearchDownData.LocationPcID := LocationPcID;
  SearchDownData.SourcePcName := SourcePcName;
  SearchDownData.LocationPcName := LocationName;
  SearchDownData.FileSize := FileSize;
  SearchDownData.CompletedSize := CompletedSize;
  SearchDownData.Status := Status;
  SearchDownData.IsLocationOnline := True;

  if vstSearchDown.RootNodeCount = 1 then
  begin
    with frmMainForm do
    begin
      tbtnSearchDownClear.Enabled := True;
      slSearchDown.Visible := True;
      plSearchDown.Visible := True;
      slSearchDown.Top := 0;
    end;
  end;
end;

{ TVstSearchDownRemove }

procedure TVstSearchDownRemove.Update;
begin
  inherited;
  if not FindSearchDownNode then
    Exit;
  vstSearchDown.DeleteNode( SearchDownNode );

  if vstSearchDown.RootNodeCount = 0 then
  begin
    with frmMainForm do
    begin
      tbtnSearchDownClear.Enabled := False;
      slSearchDown.Visible := False;
      plSearchDown.Visible := False;
    end;
  end;
end;

{ TVstSearchDownSetStatus }

procedure TVstSearchDownSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstSearchDownSetStatus.Update;
begin
  inherited;

  if not FindSearchDownNode then
    Exit;

  SearchDownData.Status := Status;
  RefreshNode;
end;

{ TVstSearchDownAddCompletedSpace }

procedure TVstSearchDownAddCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TVstSearchDownAddCompletedSpace.Update;
begin
  inherited;

  if not FindSearchDownNode then
    Exit;

  SearchDownData.CompletedSize := SearchDownData.CompletedSize + CompletedSpace;
  RefreshNode;
end;

{ TVstSearchDownSetCompletedSpace }

procedure TVstSearchDownSetCompletedSpace.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TVstSearchDownSetCompletedSpace.Update;
begin
  inherited;

  if not FindSearchDownNode then
    Exit;

  SearchDownData.CompletedSize := CompletedSpace;
  RefreshNode;
end;

{ VstSearchDownUtil }

class function VstSearchDownUtil.getStatusIcon(Status: string): Integer;
begin
  if Status = DownSearchStatus_Waiting then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if Status = DownSearchStatus_Offline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if Status = DownSearchStatus_Loading then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
  if Status = DownSearchStatus_Loaded then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if Status <> '' then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
    Result := -1;
end;

{ TVstSearchDownOffline }

procedure TVstSearchDownOffline.Update;
begin
  inherited;

    // 不存在
  if not FindSearchDownNode then
    Exit;

  SearchDownData.IsLocationOnline := False;
  RefreshNode;
end;

{ TVstSearchDownLocationOnline }

procedure TVstSearchDownLocationOnline.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TVstSearchDownLocationOnline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSearchDownData;
begin
  inherited;

  SelectNode := vstSearchDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := vstSearchDown.GetNodeData( SelectNode );
    if SelectData.LocationPcID = OnlinePcID then
    begin
      SelectData.IsLocationOnline := True;
      vstSearchDown.RepaintNode( SelectNode );
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

end.
