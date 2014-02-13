unit UFileSearchControl;

interface

uses USearchFileFace, UMyUtil, SysUtils, Classes, UModelUtil, Generics.Collections, VirtualTrees;

type

{$Region ' 修改 ' }

    // 父类
  TDownSearchFileChangeHandle = class
  public
    SourceFilePath, SourcePcID : string;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
  end;

    // 读取
  TDownSearchFileReadHandle = class( TDownSearchFileChangeHandle )
  public
    DownFilePath, LocationPcID : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    IsEncrypted : Boolean;
    Password : string;
  public
    IsBackupFile : Boolean;
  public
    procedure SetDownInfo( _DownFilePath, _LocationPcID : string );
    procedure SetFileSpaceInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _Password : string );
    procedure SetIsBackupFile( _IsBackupFile : Boolean );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TDownSearchFileAddHandle = class( TDownSearchFileReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 设置状态
  TDownSearchFileSetStatusHandle = class( TDownSearchFileChangeHandle )
  private
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 添加 已完成
  TDownSearchFileAddCompletedHandle = class( TDownSearchFileChangeHandle )
  private
    CompletedSpace : Integer;
  public
    procedure SetCompletedSize( _CompletedSpace : Integer );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // 设置 已完成
  TDownSearchSetCompletedSpaceHandle = class( TDownSearchFileChangeHandle )
  public
    CompletedSpace : Integer;
  public
    procedure SetCompletedSize( _CompletedSpace : Integer );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 删除
  TDownSearchFileRemoveHandle = class( TDownSearchFileChangeHandle )
  public
    procedure Update;
  public
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  private
    procedure RemoveOffline;
  end;

{$EndRegion}

{$Region ' 下载文件 辅助类 ' }

    // 搜索 下载
  TSaveAsFileHandle = class
  private
    DownloadPath : string;
    ItemData : TSearchFileLvData;
  private
    FilePath, DownFilePath : string;
    LocationPcID, LocationNanme : string;
    FileSize : Int64;
    FileTime : TDateTime;
  private
    IsBackupFile : Boolean;
    BackupFilePcID : string;
  private
    IsEncrypted : Boolean;
    InputPassword : string;
  public
    constructor Create( _DownloadPath : string );
    procedure SetItemData( _ItemData : TSearchFileLvData );
    procedure Update;
  private
    procedure RemoveExistFileDown;
    procedure AddToSearchDown;
    procedure AddToSourceSearchJob;
    procedure AddToBackupSearchJob;
  end;

    // 解密 下载文件 信息
  TSearchFileDecryptInfo = class
  public
    PasswordMD5, PasswordHint : string;
    ItemDataList : TSearchFileLvDataList;
  public
    constructor Create( _PasswordMD5 : string );
    procedure SetPasswordHint( _PasswordHint : string );
    destructor Destroy; override;
  end;
  TSearchFileDecryptPair = TPair< string , TSearchFileDecryptInfo >;
  TSearchFileDecryptHash = class(TStringDictionary< TSearchFileDecryptInfo >);

    // 保存的文件名
  TFindSaveFileNameHandle = class
  public
    ItemDataList : TSearchFileLvDataList;
    DownloadPath : string;
  public
    constructor Create( _ItemDataList : TSearchFileLvDataList );
    procedure SetDownloadPath( _DownloadPath : string );
    procedure Update;
  private
    procedure SetFirstName;
    procedure ResetExistName;
    function ExistFileName( FileName : string; Pos : Integer ): Boolean;
  end;

    // 保存搜索文件
  TSaveAsAllFileHandle = class
  public
    DownloadPath : string;
    ItemDataList : TSearchFileLvDataList;
    SearchFileDecryptHash : TSearchFileDecryptHash;
  public
    constructor Create( _DownloadPath : string );
    procedure Update;
    destructor Destroy; override;
  private
    procedure FindItemDataList;
    function FindSearchDecryptHash : Boolean;
    procedure DecryptSearchFile;
    procedure FindSaveFileName;
    procedure SaveAsFileHandle;
  end;

{$EndRegion}

{$Region ' 搜索文件 辅助类 '}

    // 搜索 开始
  TSearchFileStartHandle = class
  public
    LocationIDList : TStringList;
    OwnerIDList : TStringList;
    SearchName, FileType : string;
  public
    constructor Create;
    procedure Update;
    destructor Destroy; override;
  private
    function CheckPcDecrypted: Boolean;
    procedure FindLocationIDList;
    procedure FindOwnerIDList;
    procedure SearchFileReq;
  end;

{$EndRegion}

    // 界面控制器
  TMyFileSearchControl = class
  public
    procedure SearchFileStart;
    procedure SearchFileStop;
  public
    procedure SearchSaveAs( DownloadPath : string );
    procedure RemoveSearchDown( SourcePcID, SourcePath : string );
  end;

var
  MyFileSearchControl : TMyFileSearchControl;

implementation

uses UMyFileSearch, UJobFace, UMyNetPcInfo, UMyClient, UMyServer, UMyJobInfo, UMainForm,
     ComCtrls, UNetworkFace, UFormSearchOwnerDecrypt, UNetPcInfoXml, UFormSearchFileDecrypt,
     UMySearchDownInfo, UMySearchDownXml, URestoreFileFace, UMyRestoreFileInfo, UMyRestoreFileXml,
     UJobControl;

{ TFileSearchControl }



procedure TMyFileSearchControl.RemoveSearchDown(SourcePcID, SourcePath: string);
var
  DownSearchFileRemoveHandle : TDownSearchFileRemoveHandle;
begin
  DownSearchFileRemoveHandle := TDownSearchFileRemoveHandle.Create( SourcePath, SourcePcID );
  DownSearchFileRemoveHandle.Update;
  DownSearchFileRemoveHandle.Free;
end;

procedure TMyFileSearchControl.SearchFileStart;
var
  SearchFileStartHandle : TSearchFileStartHandle;
begin
  SearchFileStartHandle := TSearchFileStartHandle.Create;
  SearchFileStartHandle.Update;
  SearchFileStartHandle.Free;
end;

procedure TMyFileSearchControl.SearchFileStop;
var
  FileSearchRemoveInfo : TFileSearchStopInfo;
begin
  FileSearchRemoveInfo := TFileSearchStopInfo.Create;
  MyFileSearchReq.InsertChange( FileSearchRemoveInfo );
end;

procedure TMyFileSearchControl.SearchSaveAs(DownloadPath: string);
var
  SaveAsAllFileHandle : TSaveAsAllFileHandle;
begin
  SaveAsAllFileHandle := TSaveAsAllFileHandle.Create( DownloadPath );
  SaveAsAllFileHandle.Update;
  SaveAsAllFileHandle.Free;
end;

{ TSaveAsFile }

procedure TSaveAsFileHandle.AddToSourceSearchJob;
var
  TransferSourceSearchJobAddHandle : TTransferSourceSearchJobAddHandle;
begin
  TransferSourceSearchJobAddHandle := TTransferSourceSearchJobAddHandle.Create( FilePath, LocationPcID );
  TransferSourceSearchJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferSourceSearchJobAddHandle.SetDownFilePath( DownFilePath );
  TransferSourceSearchJobAddHandle.Update;
  TransferSourceSearchJobAddHandle.Free;
end;

procedure TSaveAsFileHandle.AddToBackupSearchJob;
var
  TransferBackupSearchJobAddHandle : TTransferBackupSearchJobAddHandle;
begin
  TransferBackupSearchJobAddHandle := TTransferBackupSearchJobAddHandle.Create( FilePath, LocationPcID );
  TransferBackupSearchJobAddHandle.SetFileInfo( FileSize, 0, FileTime );
  TransferBackupSearchJobAddHandle.SetDownFilePath( DownFilePath );
  TransferBackupSearchJobAddHandle.SetSourcePcID( BackupFilePcID );
  TransferBackupSearchJobAddHandle.Update;
  TransferBackupSearchJobAddHandle.Free;
end;


procedure TSaveAsFileHandle.AddToSearchDown;
var
  DownSearchFileAddHandle : TDownSearchFileAddHandle;
begin

    // 处理信息
  DownSearchFileAddHandle := TDownSearchFileAddHandle.Create( FilePath, BackupFilePcID );
  DownSearchFileAddHandle.SetDownInfo( DownFilePath, LocationPcID );
  DownSearchFileAddHandle.SetFileSpaceInfo( FileSize, 0 );
  DownSearchFileAddHandle.SetFileTime( FileTime );
  DownSearchFileAddHandle.SetEncryptInfo( IsEncrypted, InputPassword );
  DownSearchFileAddHandle.SetIsBackupFile( IsBackupFile );
  DownSearchFileAddHandle.Update;
  DownSearchFileAddHandle.Free;
end;

constructor TSaveAsFileHandle.Create(_DownloadPath: string);
begin
  DownloadPath := _DownloadPath;
end;

procedure TSaveAsFileHandle.RemoveExistFileDown;
var
  DownSearchFileRemoveHandle : TDownSearchFileRemoveHandle;
begin
    // 是否已存在
  if not MySearchDownReadInfoUtil.ReadIsEnable( BackupFilePcID, FilePath ) then
    Exit;

    // 存在则删除
  DownSearchFileRemoveHandle := TDownSearchFileRemoveHandle.Create( FilePath, BackupFilePcID );
  DownSearchFileRemoveHandle.Update;
  DownSearchFileRemoveHandle.Free;
end;

procedure TSaveAsFileHandle.SetItemData(_ItemData: TSearchFileLvData);
begin
  ItemData := _ItemData;
end;

procedure TSaveAsFileHandle.Update;
begin
    // 加密 且 没有输入密码 , 跳过
  if ItemData.IsEncrypt and
     ( ItemData.PasswordMD5 <> MyEncrypt.EncodeMD5String( ItemData.InputPassword ) )
  then
    Exit;

    // 提取信息
  BackupFilePcID := ItemData.OwnerID;
  FilePath := ItemData.FilePath;
  DownFilePath := MyFilePath.getPath( DownloadPath ) +  ItemData.SaveFileName;
  LocationPcID := ItemData.LocationID;
  FileSize := ItemData.FileSize;
  FileTime := ItemData.FileTime;
  IsBackupFile := ItemData.FileType = FileType_BackupCopy;
  IsEncrypted := ItemData.IsEncrypt;
  InputPassword := ItemData.InputPassword;

    // 添加记录
  RemoveExistFileDown;
  AddToSearchDown;

    // 添加 Job
  if not IsBackupFile then
    AddToSourceSearchJob
  else
    AddToBackupSearchJob;
end;

{ TSearchFileStartHandle }

function TSearchFileStartHandle.CheckPcDecrypted: Boolean;
var
  cbbOwnerPc : TComboBoxEx;
  SelectIndex : Integer;
  ItemData : TCbbOwnerData;
  OwnerID, OwnerName, PasswordMD5 : string;
begin
  Result := True;

    // 格式错误
  cbbOwnerPc := frmMainForm.cbbOwner;
  SelectIndex := cbbOwnerPc.ItemIndex;
  if ( SelectIndex <= 0 ) or ( SelectIndex >= cbbOwnerPc.ItemsEx.Count ) then
    Exit;

    // 没有加密
  ItemData := cbbOwnerPc.ItemsEx.Items[ SelectIndex ].Data;
  if ( ItemData.PcID = Network_LocalPcID ) or
       not ItemData.IsFileInvisible
  then
    Exit;

  OwnerID := ItemData.PcID;
  OwnerName := MyNetPcInfoReadUtil.ReadName( OwnerID );
  PasswordMD5 := ItemData.IvPasswordMD5;
  Result := frmIvDecrypt.PcDecrypt( OwnerName, OwnerID, PasswordMD5 );
end;


constructor TSearchFileStartHandle.Create;
begin
  LocationIDList := TStringList.Create;
  OwnerIDList := TStringList.Create;
end;

destructor TSearchFileStartHandle.Destroy;
begin
  LocationIDList.Free;
  OwnerIDList.Free;
  inherited;
end;

procedure TSearchFileStartHandle.FindLocationIDList;
var
  cbbOnlinePc : TComboBoxEx;
  SelectIndex, i : Integer;
  ItemData : TCbbLocationData;
  LocationID : string;
begin
  cbbOnlinePc := frmMainForm.cbbOnlinePc;
  SelectIndex := cbbOnlinePc.ItemIndex;
  if ( SelectIndex < 0 ) or ( SelectIndex >= cbbOnlinePc.ItemsEx.Count ) then
    Exit;

    // All Computers
  if SelectIndex = 0 then
  begin
    for i := 1 to cbbOnlinePc.ItemsEx.Count - 1 do
    begin
      ItemData := cbbOnlinePc.ItemsEx.Items[ i ].Data;
      LocationID := ItemData.PcID;
      LocationIDList.Add( LocationID );
    end;
  end
  else
  begin
    ItemData := cbbOnlinePc.ItemsEx.Items[ SelectIndex ].Data;
    LocationID := ItemData.PcID;
    LocationIDList.Add( LocationID );
  end;
end;

procedure TSearchFileStartHandle.FindOwnerIDList;
var
  cbbOwnerPc : TComboBoxEx;
  SelectIndex, i : Integer;
  ItemData : TCbbOwnerData;
  OwnerID : string;
begin
  cbbOwnerPc := frmMainForm.cbbOwner;
  SelectIndex := cbbOwnerPc.ItemIndex;
  if ( SelectIndex < 0 ) or ( SelectIndex >= cbbOwnerPc.ItemsEx.Count ) then
    Exit;

    // All Computers
  if SelectIndex = 0 then
  begin
    for i := 1 to cbbOwnerPc.ItemsEx.Count - 1 do
    begin
      ItemData := cbbOwnerPc.ItemsEx.Items[ i ].Data;
      if ( ItemData.PcID <> Network_LocalPcID ) and
           ItemData.IsFileInvisible and
         ( ItemData.IvPasswordMD5 <> ItemData.InputIvPasswordMD5 )
      then
        Continue;
      OwnerID := ItemData.PcID;
      OwnerIDList.Add( OwnerID );
    end;
  end
  else
  begin
    ItemData := cbbOwnerPc.ItemsEx.Items[ SelectIndex ].Data;
    if ( ItemData.PcID = Network_LocalPcID ) or
       not ItemData.IsFileInvisible or
       ( ItemData.IvPasswordMD5 = ItemData.InputIvPasswordMD5 )
    then
    begin
      OwnerID := ItemData.PcID;
      OwnerIDList.Add( OwnerID );
    end;
  end;
end;

procedure TSearchFileStartHandle.SearchFileReq;
var
  FileSearchStartInfo : TFileSearchStartInfo;
begin
  FileSearchStartInfo := TFileSearchStartInfo.Create( SearchName );
  FileSearchStartInfo.SetLocationIDList( LocationIDList );
  FileSearchStartInfo.SetOwnerIDList( OwnerIDList );
  FileSearchStartInfo.SetFileType( FileType );
  MyFileSearchReq.AddChange( FileSearchStartInfo );
end;

procedure TSearchFileStartHandle.Update;
begin
    // File Owner 解密失败
  if not CheckPcDecrypted then
    Exit;

    // 文件位置
  FindLocationIDList;

    // 文件拥有者
  FindOwnerIDList;

    // 文件名
  SearchName := frmMainForm.edtSearchFileName.Text;
  if SearchName = frmMainForm.siLang_frmMainForm.GetText( 'SearchTips' ) then
    SearchName := '';
  SearchName := '*' + SearchName + '*';

    // 文件类型
  if frmMainForm.cbbFileType.ItemIndex = 0 then
    FileType := FileType_AllTypes
  else
  if frmMainForm.cbbFileType.ItemIndex = 1 then
    FileType := FileType_SourceFile
  else
    FileType := FileType_BackupCopy;

    // 开始搜索
  SearchFileReq;
end;

{ TSaveAsAllFileHandle }

constructor TSaveAsAllFileHandle.Create( _DownloadPath : string );
begin
  DownloadPath := _DownloadPath;
  ItemDataList := TSearchFileLvDataList.Create;
  SearchFileDecryptHash := TSearchFileDecryptHash.Create;
end;

procedure TSaveAsAllFileHandle.DecryptSearchFile;
var
  p : TSearchFileDecryptPair;
  InputPassword : string;
  ItemDataList : TSearchFileLvDataList;
  i : Integer;
begin
  for p in SearchFileDecryptHash do
  begin
    frmSearchFileDecrypt.ClearItems;
    frmSearchFileDecrypt.SetPasswordInfo( p.Value.PasswordMD5, p.Value.PasswordHint );
    ItemDataList := p.Value.ItemDataList;
    for i := 0 to ItemDataList.Count - 1 do
      frmSearchFileDecrypt.AddItem( ItemDataList[i].FilePath, ItemDataList[i].BackupPath );
    InputPassword := frmSearchFileDecrypt.getInputPassword;

    for i := 0 to ItemDataList.Count - 1 do
      ItemDataList[i].InputPassword := InputPassword;
  end;
end;

destructor TSaveAsAllFileHandle.Destroy;
begin
  SearchFileDecryptHash.Free;
  ItemDataList.Free;
  inherited;
end;

procedure TSaveAsAllFileHandle.FindItemDataList;
var
  lvSearchFile : TListView;
  ItemData : TSearchFileLvData;
  i, Count : Integer;
begin
  lvSearchFile := frmMainForm.lvSearchFile;
  Count := 0;
  for i := lvSearchFile.Selected.Index to lvSearchFile.Items.Count - 1 do
  if lvSearchFile.Items[i].Selected then
  begin
    ItemData := lvSearchFile.Items[i].Data;
    ItemDataList.Add( ItemData );
    Inc( Count );
    if Count >= lvSearchFile.SelCount then
      Break;
  end;
end;

procedure TSaveAsAllFileHandle.FindSaveFileName;
var
  FindSaveFileNameHandle : TFindSaveFileNameHandle;
begin
  FindSaveFileNameHandle := TFindSaveFileNameHandle.Create( ItemDataList );
  FindSaveFileNameHandle.SetDownloadPath( DownloadPath );
  FindSaveFileNameHandle.Update;
  FindSaveFileNameHandle.Free;
end;

function TSaveAsAllFileHandle.FindSearchDecryptHash: Boolean;
var
  i : Integer;
  ItemData : TSearchFileLvData;
  PasswordMD5 : string;
begin
  for i := 0 to ItemDataList.Count - 1 do
  begin
    ItemData := ItemDataList[i];
    if not ItemData.IsEncrypt then
      Continue;
    PasswordMD5 := ItemData.PasswordMD5;
    if not SearchFileDecryptHash.ContainsKey( PasswordMD5 ) then
    begin
      SearchFileDecryptHash.AddOrSetValue( PasswordMD5, TSearchFileDecryptInfo.Create( PasswordMD5 ) );
      SearchFileDecryptHash[ PasswordMD5 ].SetPasswordHint( ItemData.PasswordHint );
    end;
    SearchFileDecryptHash[ PasswordMD5 ].ItemDataList.Add( ItemData );
  end;

  Result := SearchFileDecryptHash.Count > 0;
end;

procedure TSaveAsAllFileHandle.SaveAsFileHandle;
var
  i : Integer;
  SaveAsFileHandle : TSaveAsFileHandle;
begin
  for i := 0 to ItemDataList.Count - 1 do
  begin
    SaveAsFileHandle := TSaveAsFileHandle.Create( DownloadPath );
    SaveAsFileHandle.SetItemData( ItemDataList[i] );
    SaveAsFileHandle.Update;
    SaveAsFileHandle.Free;
  end;
end;

procedure TSaveAsAllFileHandle.Update;
begin
    // 寻找 所选择的数据
  FindItemDataList;

    // 解密
  if FindSearchDecryptHash then
    DecryptSearchFile;

    // 如果存在 相同文件， 改名
  FindSaveFileName;

    // 下载
  SaveAsFileHandle;
end;

{ TSearchFileDecryptInfo }

constructor TSearchFileDecryptInfo.Create(_PasswordMD5: string);
begin
  PasswordMD5 := _PasswordMD5;
  ItemDataList := TSearchFileLvDataList.Create;
end;

destructor TSearchFileDecryptInfo.Destroy;
begin
  ItemDataList.Free;
  inherited;
end;

procedure TSearchFileDecryptInfo.SetPasswordHint(_PasswordHint: string);
begin
  PasswordHint := _PasswordHint;
end;

{ TFindSaveFileNameHandle }

constructor TFindSaveFileNameHandle.Create(
  _ItemDataList: TSearchFileLvDataList);
begin
  ItemDataList := _ItemDataList;
end;

function TFindSaveFileNameHandle.ExistFileName(FileName: string;
  Pos : Integer): Boolean;
var
  i : Integer;
begin
  Result := True;
  if FileExists( MyFilePath.getPath( DownloadPath ) + FileName ) then
    Exit;

  for i := 0 to Pos - 1 do
    if ItemDataList[i].SaveFileName = FileName then
      Exit;

  Result := False;
end;

procedure TFindSaveFileNameHandle.ResetExistName;
var
  i, j : Integer;
  FileName, SaveAsFileName : string;
begin
  for i := 0 to ItemDataList.Count - 1 do
  begin
    FileName := ItemDataList[i].SaveFileName;
    SaveAsFileName := FileName;
    j := 0;
    while ExistFileName( SaveAsFileName, i ) do
    begin
      Inc(j);
      SaveAsFileName := MyRename.getFileName( FileName, j );
    end;
    ItemDataList[i].SaveFileName := SaveAsFileName;
  end;
end;

procedure TFindSaveFileNameHandle.SetDownloadPath(_DownloadPath: string);
begin
  DownloadPath := _DownloadPath;
end;

procedure TFindSaveFileNameHandle.SetFirstName;
var
  i : Integer;
  FileName : string;
begin
  for i := 0 to ItemDataList.Count - 1 do
  begin
    FileName := ExtractFileName( ItemDataList[i].FilePath );
    ItemDataList[i].SaveFileName := FileName;
  end;
end;

procedure TFindSaveFileNameHandle.Update;
begin
  SetFirstName;

  ResetExistName;
end;

{ TDownSearchFileChangeHandle }

constructor TDownSearchFileChangeHandle.Create(_SourceFilePath, _SourcePcID : string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

{ TDownSearchFileReadHandle }

procedure TDownSearchFileReadHandle.AddToFace;
var
  SourcePcName, LocationPcName : string;
  VstSearchDownAdd : TVstSearchDownAdd;
begin
  SourcePcName := MyNetPcInfoReadUtil.ReadName( SourcePcID );
  LocationPcName := MyNetPcInfoReadUtil.ReadName( LocationPcID );

  VstSearchDownAdd := TVstSearchDownAdd.Create( SourcePcID, SourceFilePath );
  VstSearchDownAdd.SetDownInfo( DownFilePath, LocationPcID );
  VstSearchDownAdd.SetSpaceInfo( FileSize, Position );
  VstSearchDownAdd.SetNameInfo( SourcePcName, LocationPcName );
  VstSearchDownAdd.SetStatus( DownSearchStatus_Waiting );
  MySearchFileFace.AddChange( VstSearchDownAdd );
end;

procedure TDownSearchFileReadHandle.AddToInfo;
var
  SearchDownFileAddInfo : TSearchDownFileAddInfo;
begin
  SearchDownFileAddInfo := TSearchDownFileAddInfo.Create( SourcePcID, SourceFilePath );
  SearchDownFileAddInfo.SetEncryptInfo( IsEncrypted, Password );
  MySearchDownInfo.AddChange( SearchDownFileAddInfo );
end;

procedure TDownSearchFileReadHandle.SetDownInfo(_DownFilePath, _LocationPcID: string);
begin
  DownFilePath := _DownFilePath;
  locationPcID := _LocationPcID;
end;

procedure TDownSearchFileReadHandle.SetEncryptInfo(_IsEncrypted: Boolean;
  _Password: string);
begin
  IsEncrypted := _IsEncrypted;
  Password := _Password;
end;

procedure TDownSearchFileReadHandle.SetFileSpaceInfo(_FileSize,
  _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TDownSearchFileReadHandle.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;

procedure TDownSearchFileReadHandle.SetIsBackupFile(_IsBackupFile: Boolean);
begin
  IsBackupFile := _IsBackupFile;
end;

procedure TDownSearchFileReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDownSearchFileAddHandle }

procedure TDownSearchFileAddHandle.AddToXml;
var
  SearchDownAddXml : TSearchDownAddXml;
begin
    // 写 Xml
  SearchDownAddXml := TSearchDownAddXml.Create( SourcePcID, SourceFilePath );
  SearchDownAddXml.SetDownInfo( DownFilePath, LocationPcID );
  SearchDownAddXml.SetFileInfo( FileSize, FileTime );
  SearchDownAddXml.SetBackupInfo( IsBackupFile );
  SearchDownAddXml.SetEncryptInfo( IsEncrypted, Password );
  MySearchDownWriteXml.AddChange( SearchDownAddXml );
end;

procedure TDownSearchFileAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TDownSearchFileRemoveHandle }

procedure TDownSearchFileRemoveHandle.RemoveFromFace;
var
  VstSearchDownRemove : TVstSearchDownRemove;
begin
  VstSearchDownRemove := TVstSearchDownRemove.Create( SourcePcID, SourceFilePath );
  MySearchFileFace.AddChange( VstSearchDownRemove );
end;

procedure TDownSearchFileRemoveHandle.RemoveFromInfo;
var
  SearchDownFileRemoveInfo : TSearchDownFileRemoveInfo;
begin
  SearchDownFileRemoveInfo := TSearchDownFileRemoveInfo.Create( SourcePcID, SourceFilePath );
  MySearchDownInfo.AddChange( SearchDownFileRemoveInfo );
end;

procedure TDownSearchFileRemoveHandle.RemoveFromXml;
var
  SearchDownRemoveXml : TSearchDownRemoveXml;
begin
  SearchDownRemoveXml := TSearchDownRemoveXml.Create( SourcePcID, SourceFilePath );
  MySearchDownWriteXml.AddChange( SearchDownRemoveXml );
end;

procedure TDownSearchFileRemoveHandle.RemoveOffline;
var
  SearchDownFileRemoveOfflineInfo : TSearchDownFileRemoveOfflineInfo;
begin
  SearchDownFileRemoveOfflineInfo := TSearchDownFileRemoveOfflineInfo.Create;
  MySearchDownInfo.AddChange( SearchDownFileRemoveOfflineInfo );
end;

procedure TDownSearchFileRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveOffline;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TDownSearchFileSetStatusHandle }

procedure TDownSearchFileSetStatusHandle.SetToFace;
var
  VstSearchDownSetStatus : TVstSearchDownSetStatus;
begin
  VstSearchDownSetStatus := TVstSearchDownSetStatus.Create( SourcePcID, SourceFilePath );
  VstSearchDownSetStatus.SetStatus( Status );
  MySearchFileFace.AddChange( VstSearchDownSetStatus );
end;

procedure TDownSearchFileSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TDownSearchFileSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TDownSearchFileAddCompletedHandle }

procedure TDownSearchFileAddCompletedHandle.SetCompletedSize(
  _CompletedSpace: Integer);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TDownSearchFileAddCompletedHandle.SetToFace;
var
  VstSearchDownAddCompletedSpace : TVstSearchDownAddCompletedSpace;
begin
  VstSearchDownAddCompletedSpace := TVstSearchDownAddCompletedSpace.Create( SourcePcID, SourceFilePath );
  VstSearchDownAddCompletedSpace.SetCompletedSpace( CompletedSpace );
  MySearchFileFace.AddChange( VstSearchDownAddCompletedSpace );
end;

procedure TDownSearchFileAddCompletedHandle.Update;
begin
  SetToFace;
end;

{ TDownSearchSetCompletedSpaceHandle }

procedure TDownSearchSetCompletedSpaceHandle.SetCompletedSize(
  _CompletedSpace: Integer);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TDownSearchSetCompletedSpaceHandle.SetToFace;
var
  VstSearchDownSetCompletedSpace : TVstSearchDownSetCompletedSpace;
begin
  VstSearchDownSetCompletedSpace := TVstSearchDownSetCompletedSpace.Create( SourcePcID, SourceFilePath );
  VstSearchDownSetCompletedSpace.SetCompletedSpace( CompletedSpace );
  MySearchFileFace.AddChange( VstSearchDownSetCompletedSpace );
end;

procedure TDownSearchSetCompletedSpaceHandle.SetToXml;
var
  SearchDownPositionXml : TSearchDownPositionXml;
begin
  SearchDownPositionXml := TSearchDownPositionXml.Create( SourcePcID, SourceFilePath );
  SearchDownPositionXml.SetPosition( CompletedSpace );
  MySearchDownWriteXml.AddChange( SearchDownPositionXml );
end;

procedure TDownSearchSetCompletedSpaceHandle.Update;
begin
  SetToFace;
  SetToXml;
end;

end.
