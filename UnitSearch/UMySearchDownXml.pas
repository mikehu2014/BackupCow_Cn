unit UMySearchDownXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, SysUtils, UMyUtil;

type

{$Region ' 修改 ' }

   // 父类
  TSearchDownChangeXml = class( TChangeInfo )
  public
    SourcePcID, SourceFilePath : string;
  protected
    SearchDownFileIndex : Integer;
    SearchDownFileNode : IXMLNode;
  public
    constructor Create( _SourcePcID, _SourceFilePath : string );
  protected
    function FindSearchDownNode : Boolean;
  end;

    // 添加
  TSearchDownAddXml = class( TSearchDownChangeXml )
  public
    DownloadPath : string;
    FileSize : Int64;
    FileTime : TDateTime;
    LocationID : string;
  public
    IsBackupFile : Boolean;
  public
    IsEncrypted : Boolean;
    InputPassword : string;
  public
    procedure SetDownInfo( _DownLoadPath, _LocationID : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure SetBackupInfo( _IsBackupFile : Boolean );
    procedure SetEncryptInfo( _IsEncrypted : Boolean; _InputPassword : string );
    procedure Update;override;
  end;

    // 改变 下载状态
  TSearchDownStatusXml = class( TSearchDownChangeXml )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // 改变 下载位置
  TSearchDownPositionXml = class( TSearchDownChangeXml )
  public
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  end;


    // 删除
  TSearchDownRemoveXml = class( TSearchDownChangeXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' 读取 ' }

    // 读取 SearchDown 文件
  TSerachDownFileXmlReadHandle = class
  public
    SearchDownFileNode : IXMLNode;
  public
    constructor Create( _SearchDownNode : IXMLNode );
    procedure Update;
  end;

    // 读取信息
  TSearchDownXmlRead = class
  public
    procedure Update;
  end;

{$EndRegion}

const
  Xml_SourcePcID = 'spi';
  Xml_FilePath = 'fp';
  Xml_DownloadPath = 'dlp';
  Xml_FileSize = 'fs';
  Xml_FileTime = 'ft';
  Xml_Postion = 'ps';
  Xml_LocationID = 'li';
  Xml_Status = 'st';
  Xml_IsBackupFile = 'ibf';
  Xml_BackupFilePcID = 'bfpi';
  Xml_IsEncrypted = 'ie';
  Xml_InputPassword = 'ip';

var
  MySearchDownWriteXml : TMyChildXmlChange;

implementation

uses USearchFileFace, UMyNetPcInfo, UMyJobInfo, UJobFace, UMySearchDownInfo, UFileSearchControl,
     UJobControl;

{ TSearchDownChangeXml }

function TSearchDownChangeXml.FindSearchDownNode: Boolean;
var
  i : Integer;
  SelectNode : IXMLNode;
begin
  Result := False;

  for i := 0 to SearchDownFileHashXml.ChildNodes.Count - 1 do
  begin
    SelectNode := SearchDownFileHashXml.ChildNodes[i];
    if ( MyXmlUtil.GetChildValue( SelectNode, Xml_SourcePcID ) = SourcePcID ) and
       ( MyXmlUtil.GetChildValue( SelectNode, Xml_FilePath ) = SourceFilePath )
    then
    begin
      SearchDownFileIndex := i;
      SearchDownFileNode := SelectNode;
      Result := True;
      Break;
    end;
  end;
end;

constructor TSearchDownChangeXml.Create(_SourcePcID, _SourceFilePath: string);
begin
  SourcePcID := _SourcePcID;
  SourceFilePath := _SourceFilePath;
end;

{ TSearchDownAddXml }

procedure TSearchDownAddXml.SetBackupInfo(_IsBackupFile: Boolean);
begin
  IsBackupFile := _IsBackupFile;
end;

procedure TSearchDownAddXml.SetDownInfo(_DownLoadPath, _LocationID: string);
begin
  DownloadPath := _DownLoadPath;
  LocationID := _LocationID;
end;

procedure TSearchDownAddXml.SetEncryptInfo(_IsEncrypted: Boolean;
  _InputPassword: string);
begin
  IsEncrypted := _IsEncrypted;
  InputPassword := _InputPassword;
end;

procedure TSearchDownAddXml.SetFileInfo(_FileSize: Int64;
  _FileTime : TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TSearchDownAddXml.Update;
var
  EncryptedPassword : string;
begin
    // 已存在
  if FindSearchDownNode then
    Exit;

  SearchDownFileNode := MyXmlUtil.AddListChild( SearchDownFileHashXml );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_SourcePcID, SourcePcID );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_FilePath, SourceFilePath );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_DownloadPath, DownloadPath );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_FileTime, FloatToStr( FileTime ) );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_Postion, IntToStr( 0 ) );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_LocationID, LocationID );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_IsBackupFile, BoolToStr( IsBackupFile ) );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_Status, DownSearchStatus_Waiting );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_IsEncrypted, BoolToStr( IsEncrypted ) );

  EncryptedPassword := MyEncrypt.EncodeStr( InputPassword );
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_InputPassword, EncryptedPassword );
end;

{ TSearchDownPositionXml }

procedure TSearchDownPositionXml.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TSearchDownPositionXml.Update;
begin
    // 不存在
  if not FindSearchDownNode then
    Exit;

  MyXmlUtil.AddChild( SearchDownFileNode, Xml_Postion, IntToStr( Position ) );
end;

{ TSearchDownRemoveXml }

procedure TSearchDownRemoveXml.Update;
begin
    // 不存在
  if not FindSearchDownNode then
    Exit;

  SearchDownFileHashXml.ChildNodes.Delete( SearchDownFileIndex );
end;

{ TSearchDownXmlRead }

procedure TSearchDownXmlRead.Update;
var
  i : Integer;
  SearchDownFileNode : IXMLNode;
  SerachDownFileXmlReadHandle : TSerachDownFileXmlReadHandle;
begin
  for i := 0 to SearchDownFileHashXml.ChildNodes.Count - 1 do
  begin
    SearchDownFileNode := SearchDownFileHashXml.ChildNodes[i];
    SerachDownFileXmlReadHandle := TSerachDownFileXmlReadHandle.Create( SearchDownFileNode );
    SerachDownFileXmlReadHandle.Update;
    SerachDownFileXmlReadHandle.Free;
  end;
end;

{ TSearchDownStatusXml }

procedure TSearchDownStatusXml.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TSearchDownStatusXml.Update;
begin
    // 不存在
  if not FindSearchDownNode then
    Exit;

    // 修改 状态
  MyXmlUtil.AddChild( SearchDownFileNode, Xml_Status, Status );
end;

{ TSerachDownFileXmlReadHandle }

constructor TSerachDownFileXmlReadHandle.Create(_SearchDownNode: IXMLNode);
begin
  SearchDownFileNode := _SearchDownNode;
end;

procedure TSerachDownFileXmlReadHandle.Update;
var
  SourcePcID, SourceFilePath : string;
  DownloadPath, FilePath : string;
  Position, FileSize : Int64;
  FileTime : TDateTime;
  LocationID : string;
  IsBackupFile : Boolean;
  IsEncrypted : Boolean;
  EncryptedPassword, InputPassword : string;
  DownSearchFileReadHandle : TDownSearchFileReadHandle;
  TransferSourceSearchJobAddHandle : TTransferSourceSearchJobAddHandle;
  TransferBackupSearchJobAddHandle : TTransferBackupSearchJobAddHandle;
begin
    // 提取信息
  SourcePcID := MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_SourcePcID );
  SourceFilePath := MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_FilePath );
  DownloadPath := MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_DownloadPath );
  Position := StrToInt64Def( MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_Postion ), 0 );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_FileSize ), 0 );
  FileTime := StrToFloatDef( MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_FileTime ), Now );
  LocationID := MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_LocationID );
  IsBackupFile := StrToBoolDef( MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_IsBackupFile ), False );
  IsEncrypted := StrToBoolDef( MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_IsEncrypted ), False );
  EncryptedPassword := MyXmlUtil.GetChildValue( SearchDownFileNode, Xml_InputPassword );
  InputPassword := MyEncrypt.DecodeStr( EncryptedPassword );
  if SourcePcID = '' then
    SourcePcID := LocationID;

    // 处理信息
  DownSearchFileReadHandle := TDownSearchFileReadHandle.Create( SourceFilePath, SourcePcID );
  DownSearchFileReadHandle.SetDownInfo( DownloadPath, LocationID );
  DownSearchFileReadHandle.SetFileSpaceInfo( FileSize, Position );
  DownSearchFileReadHandle.SetFileTime( FileTime );
  DownSearchFileReadHandle.SetEncryptInfo( IsEncrypted, InputPassword );
  DownSearchFileReadHandle.SetIsBackupFile( IsBackupFile );
  DownSearchFileReadHandle.Update;
  DownSearchFileReadHandle.Free;

    // 已完成
  if Position >= FileSize then
    Exit;

    // 源文件 下载 Job
  if not IsBackupFile then
  begin
    TransferSourceSearchJobAddHandle := TTransferSourceSearchJobAddHandle.Create( SourceFilePath, LocationID );
    TransferSourceSearchJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
    TransferSourceSearchJobAddHandle.SetDownFilePath( DownloadPath );
    TransferSourceSearchJobAddHandle.Update;
    TransferSourceSearchJobAddHandle.Free;
  end
  else
  begin  // 备份文件下载 Job
    TransferBackupSearchJobAddHandle := TTransferBackupSearchJobAddHandle.Create( SourceFilePath, LocationID );
    TransferBackupSearchJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
    TransferBackupSearchJobAddHandle.SetDownFilePath( DownloadPath );
    TransferBackupSearchJobAddHandle.SetSourcePcID( SourcePcID );
    TransferBackupSearchJobAddHandle.Update;
    TransferBackupSearchJobAddHandle.Free;
  end;

end;

end.
