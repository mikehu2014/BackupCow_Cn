unit UMyCloudFaceInfo;

interface

uses VirtualTrees, UChangeInfo;

type

{$Region ' 数据结构 ' }

    // 数据结构
  TCloudPcBackupData = record
  public
    ItemID : string;
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  end;
  PCloudPcBackupData = ^TCloudPcBackupData;


{$EndRegion}

{$Region ' 数据修改 Pc信息 ' }

    // 父类
  TCloudPcChangeFace = class( TFaceChangeInfo )
  public
    VstTCloudPc : TVirtualStringTree;
  protected
    procedure Update;override;
  end;

    // 修改
  TCloudPcWriteFace = class( TCloudPcChangeFace )
  public
    PcID : string;
  protected
    CloudPcNode : PVirtualNode;
    CloudPcData : PCloudPcBackupData;
  public
    constructor Create( _PcID : string );
    function FindCloudPcNode : Boolean;
  end;

    // 添加
  TCloudPcAddFace = class( TCloudPcWriteFace )
  public
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPcRemoveFace = class( TCloudPcWriteFace )
  protected
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' 数据修改 备份信息 ' }

    // 修改
  TCloudPcBackupWriteFace = class( TCloudPcWriteFace )
  public
    BackupPath : string;
  protected
    CloudPcBackupNode : PVirtualNode;
    CloudPcBackupData : PCloudPcBackupData;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindCloudPcBackupNode : Boolean;
  end;

    // 添加
  TCloudPcBackupAddFace = class( TCloudPcBackupWriteFace )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
  protected
    procedure Update;override;
  end;

    // 删除
  TCloudPcBackupRemoveFace = class( TCloudPcBackupWriteFace )
  protected
    procedure Update;override;
  end;

{$EndRegion}

implementation

uses UMainForm;

{ TCloudPcChangeFace }

procedure TCloudPcChangeFace.Update;
begin
  VstTCloudPc := frmMainForm.vstBackupShare;
end;

{ TCloudPcWriteFace }

constructor TCloudPcWriteFace.Create( _PcID : string );
begin
  PcID := _PcID;
end;


function TCloudPcWriteFace.FindCloudPcNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PCloudPcBackupData;
begin
  Result := False;
  SelectNode := VstTCloudPc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstTCloudPc.GetNodeData( SelectNode );
    if ( SelectData.ItemID = PcID ) then
    begin
      Result := True;
      CloudPcNode := SelectNode;
      CloudPcData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TCloudPcAddFace }

procedure TCloudPcAddFace.Update;
begin
  inherited;

  if FindCloudPcNode then
    Exit;

  CloudPcNode := VstTCloudPc.AddChild( VstTCloudPc.RootNode );
  CloudPcData := VstTCloudPc.GetNodeData( CloudPcNode );
  CloudPcData.ItemID := PcID;
end;

{ TCloudPcRemoveFace }

procedure TCloudPcRemoveFace.Update;
begin
  inherited;

  if not FindCloudPcNode then
    Exit;

  VstTCloudPc.DeleteNode( CloudPcNode );
end;

{ TCloudPcBackupWriteFace }

procedure TCloudPcBackupWriteFace.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TCloudPcBackupWriteFace.FindCloudPcBackupNode : Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PCloudPcBackupData;
begin
  Result := False;
  if not FindCloudPcNode then
    Exit;
  SelectNode := CloudPcNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstTCloudPc.GetNodeData( SelectNode );
    if ( SelectData.ItemID = BackupPath ) then
    begin
      Result := True;
      CloudPcBackupNode := SelectNode;
      CloudPcBackupData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TCloudPcBackupAddFace }

procedure TCloudPcBackupAddFace.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudPcBackupAddFace.SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TCloudPcBackupAddFace.Update;
begin
  inherited;

  if FindCloudPcBackupNode then
    Exit;

  CloudPcBackupNode := VstTCloudPc.AddChild( VstTCloudPc.RootNode );
  CloudPcBackupData := VstTCloudPc.GetNodeData( CloudPcBackupNode );
  CloudPcBackupData.ItemID := BackupPath;
  CloudPcBackupData.IsFile := IsFile;
  CloudPcBackupData.FileCount := FileCount;
  CloudPcBackupData.ItemSize := ItemSize;
  CloudPcBackupData.CompletedSize := CompletedSize;
end;

{ TCloudPcBackupRemoveFace }

procedure TCloudPcBackupRemoveFace.Update;
begin
  inherited;

  if not FindCloudPcBackupNode then
    Exit;

  VstTCloudPc.DeleteNode( CloudPcBackupNode );
end;


end.
