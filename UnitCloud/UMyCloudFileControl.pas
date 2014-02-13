unit UMyCloudFileControl;

interface

type

{$Region ' 云路径 修改 ' }

    // 上线 扫描云路径
  TCloudPathOnlineScanHandle = class
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 修改
  TCloudPathChangeHandle = class
  protected
    CloudPath : string;
  public
    constructor Create( _CloudlPath : string );
  end;

    // 读取
  TCloudPathReadHandle = class( TCloudPathChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // 添加
  TCloudPathAddHandle = class( TCloudPathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 移除
  TCloudPathRemoveHandle = class( TCloudPathChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' 云路径 拥有者 修改 ' }

    // 修改
  TCloudPathOwnerChangeHandle = class( TCloudPathChangeHandle )
  public
    OwnerPcID : string;
  public
    procedure SetOwnerPcID( _OwnerPcID : string );
  end;

    // 读取
  TCloudPathOwnerReadHandle = class( TCloudPathOwnerChangeHandle )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    LastScanTime : TDateTime;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // 设置 上一次 扫描时间
  TCloudPathOwnerSetLastScanTimeHandle = class( TCloudPathOwnerChangeHandle )
  public
    LastScanTime : TDateTime;
  public
    procedure SetLastScanTime( _LastScanTime : TDateTime );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

    // 删除
  TCloudPathOwnerRemoveHandle = class( TCloudPathOwnerChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$Region ' 修改 空间信息 ' }

    // 父类
  TCloudPathOwnerChangeSpaceHandle = class( TCloudPathOwnerChangeHandle )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // 添加
  TCloudPathOwnerSpaceAddHandle = class( TCloudPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToXml;
  end;

    // 删除
  TCloudPathOwnerSpaceRemoveHandle = class( TCloudPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

    // 设置
  TCloudPathOwnerSpaceSetHandle = class( TCloudPathOwnerChangeSpaceHandle )
  private
    LastFileSize : Int64;
  public
    procedure SetLastFileSize( _LastFileSize : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

{$EndRegion}

    // 云文件 控制器
  TMyCloudFileControl = class
  public
    procedure AddSharePath( FullPath : string );
    procedure RemoveSharePath( FullPath : string );
  end;

const
  CloudFileStatus_Loading = 'Loading';
  CloudFileStatus_Loaded = 'Loaded';

var
  MyCloudFileControl : TMyCloudFileControl;

implementation

uses UMyCloudPathInfo, UCloudPathInfoXml;

{ TMyCloudFileControl }

procedure TMyCloudFileControl.AddSharePath(FullPath: string);
var
  SharePathAddHandle : TCloudPathAddHandle;
begin
  SharePathAddHandle := TCloudPathAddHandle.Create( FullPath );
  SharePathAddHandle.Update;
  SharePathAddHandle.Free;
end;

procedure TMyCloudFileControl.RemoveSharePath(FullPath: string);
var
  SharePathRemoveHandle : TCloudPathRemoveHandle;
begin
  SharePathRemoveHandle := TCloudPathRemoveHandle.Create( FullPath );
  SharePathRemoveHandle.Update;
  SharePathRemoveHandle.Free;
end;

{ TSharePathAddHandle }

procedure TCloudPathAddHandle.AddToXml;
var
  CloudPathAddXml : TCloudPathAddXml;
begin
    // 写 Xml
  CloudPathAddXml := TCloudPathAddXml.Create( CloudPath );
  MyCloudPathXmlWrite.AddChange( CloudPathAddXml );
end;

procedure TCloudPathAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TSharePathRemoveHandle }

procedure TCloudPathRemoveHandle.RemoveFromInfo;
var
  CloudPathRemoveInfo : TCloudPathRemoveInfo;
begin
    // 写 内存
  CloudPathRemoveInfo := TCloudPathRemoveInfo.Create( CloudPath );
  MyCloudFileInfo.AddChange( CloudPathRemoveInfo );
end;

procedure TCloudPathRemoveHandle.RemoveFromXml;
var
  CloudPathRemoveXml : TCloudPathRemoveXml;
begin
    // 写 Xml
  CloudPathRemoveXml := TCloudPathRemoveXml.Create( CloudPath );
  MyCloudPathXmlWrite.AddChange( CloudPathRemoveXml );
end;

procedure TCloudPathRemoveHandle.Update;
begin
    // 删除信息
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TCloudPathChangeHandle }

constructor TCloudPathChangeHandle.Create(_CloudlPath: string);
begin
  CloudPath := _CloudlPath;
end;

{ TCloudPathReadHandle }

procedure TCloudPathReadHandle.AddToInfo;
var
  CloudPathAddInfo : TCloudPathAddInfo;
begin
    // 写 内存
  CloudPathAddInfo := TCloudPathAddInfo.Create( CloudPath );
  MyCloudFileInfo.AddChange( CloudPathAddInfo );
end;

procedure TCloudPathReadHandle.Update;
begin
  AddToInfo;
end;

{ TCloudPathPcFolderChangeHandle }

procedure TCloudPathOwnerChangeHandle.SetOwnerPcID(_OwnerPcID: string);
begin
  OwnerPcID := _OwnerPcID;
end;

{ TCloudPathPcFolderChangeSpaceHandle }

procedure TCloudPathOwnerChangeSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TCloudPathPcFolderRemoveHandle }

procedure TCloudPathOwnerRemoveHandle.RemoveFromInfo;
var
  CloudPathOwnerRemoveInfo : TCloudPathOwnerRemoveInfo;
begin
  CloudPathOwnerRemoveInfo := TCloudPathOwnerRemoveInfo.Create( CloudPath );
  CloudPathOwnerRemoveInfo.SetOwnerPcID( OwnerPcID );
  MyCloudFileInfo.AddChange( CloudPathOwnerRemoveInfo );
end;

procedure TCloudPathOwnerRemoveHandle.RemoveFromXml;
var
  CloudPathOwnerRemoveXml : TCloudPathOwnerRemoveXml;
begin
  CloudPathOwnerRemoveXml := TCloudPathOwnerRemoveXml.Create( CloudPath );
  CloudPathOwnerRemoveXml.SetOwnerPcID( OwnerPcID );
  MyCloudPathXmlWrite.AddChange( CloudPathOwnerRemoveXml );
end;

procedure TCloudPathOwnerRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TCloudPathPcFolderSpaceAddHandle }

procedure TCloudPathOwnerSpaceAddHandle.AddToInfo;
var
  CloudPathPcFolderAddSpaceInfo : TCloudPathOwnerAddSpaceInfo;
begin
  CloudPathPcFolderAddSpaceInfo := TCloudPathOwnerAddSpaceInfo.Create( CloudPath );
  CloudPathPcFolderAddSpaceInfo.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderAddSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyCloudFileInfo.AddChange( CloudPathPcFolderAddSpaceInfo );
end;

procedure TCloudPathOwnerSpaceAddHandle.AddToXml;
var
  CloudPathPcFolderAddSpaceXml : TCloudPathOwnerAddSpaceXml;
begin
  CloudPathPcFolderAddSpaceXml := TCloudPathOwnerAddSpaceXml.Create( CloudPath );
  CloudPathPcFolderAddSpaceXml.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderAddSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyCloudPathXmlWrite.AddChange( CloudPathPcFolderAddSpaceXml );
end;

procedure TCloudPathOwnerSpaceAddHandle.Update;
begin
  AddToInfo;
  AddToXml;
end;

{ TCloudPathPcFolderSpaceRemoveHandle }

procedure TCloudPathOwnerSpaceRemoveHandle.RemoveFromInfo;
var
  CloudPathPcFolderRemoveSpaceInfo : TCloudPathOwnerRemoveSpaceInfo;
begin
  CloudPathPcFolderRemoveSpaceInfo := TCloudPathOwnerRemoveSpaceInfo.Create( CloudPath );
  CloudPathPcFolderRemoveSpaceInfo.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderRemoveSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyCloudFileInfo.AddChange( CloudPathPcFolderRemoveSpaceInfo );
end;

procedure TCloudPathOwnerSpaceRemoveHandle.RemoveFromXml;
var
  CloudPathPcFolderRemoveSpaceXml : TCloudPathOwnerRemoveSpaceXml;
begin
  CloudPathPcFolderRemoveSpaceXml := TCloudPathOwnerRemoveSpaceXml.Create( CloudPath );
  CloudPathPcFolderRemoveSpaceXml.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderRemoveSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyCloudPathXmlWrite.AddChange( CloudPathPcFolderRemoveSpaceXml );
end;

procedure TCloudPathOwnerSpaceRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TCloudPathPcFolderSpaceSetHandle }

procedure TCloudPathOwnerSpaceSetHandle.SetLastFileSize(_LastFileSize: Int64);
begin
  LastFileSize := _LastFileSize;
end;

procedure TCloudPathOwnerSpaceSetHandle.SetToInfo;
var
  CloudPathPcFolderSetSpaceInfo : TCloudPathOwnerSetSpaceInfo;
begin
  CloudPathPcFolderSetSpaceInfo := TCloudPathOwnerSetSpaceInfo.Create( CloudPath );
  CloudPathPcFolderSetSpaceInfo.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderSetSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  CloudPathPcFolderSetSpaceInfo.SetLastFileSize( LastFileSize );
  MyCloudFileInfo.AddChange( CloudPathPcFolderSetSpaceInfo );
end;

procedure TCloudPathOwnerSpaceSetHandle.SetToXml;
var
  CloudPathPcFolderSetSpaceXml : TCloudPathOwnerSetSpaceXml;
begin
  CloudPathPcFolderSetSpaceXml := TCloudPathOwnerSetSpaceXml.Create( CloudPath );
  CloudPathPcFolderSetSpaceXml.SetOwnerPcID( OwnerPcID );
  CloudPathPcFolderSetSpaceXml.SetSpaceInfo( FileSize, FileCount );
  CloudPathPcFolderSetSpaceXml.SetLastFileSize( LastFileSize );
  MyCloudPathXmlWrite.AddChange( CloudPathPcFolderSetSpaceXml );
end;

procedure TCloudPathOwnerSpaceSetHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TCloudPathOwnerReadHandle }

procedure TCloudPathOwnerReadHandle.AddToInfo;
var
  CloudPathOwnerAddInfo : TCloudPathOwnerAddInfo;
begin
  CloudPathOwnerAddInfo := TCloudPathOwnerAddInfo.Create( CloudPath );
  CloudPathOwnerAddInfo.SetOwnerPcID( OwnerPcID );
  CloudPathOwnerAddInfo.SetSpaceInfo( FileSize, FileCount );
  CloudPathOwnerAddInfo.SetLastScanTime( LastScanTime );
  MyCloudFileInfo.AddChange( CloudPathOwnerAddInfo );
end;

procedure TCloudPathOwnerReadHandle.SetLastScanTime(_LastScanTime: TDateTime);
begin
  LastScanTime := _LastScanTime;
end;

procedure TCloudPathOwnerReadHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TCloudPathOwnerReadHandle.Update;
begin
  AddToInfo;
end;

{ TCloudPathOwnerSetLastScanTime }

procedure TCloudPathOwnerSetLastScanTimeHandle.SetLastScanTime(
  _LastScanTime: TDateTime);
begin
  LastScanTime := _LastScanTime;
end;

procedure TCloudPathOwnerSetLastScanTimeHandle.SetToInfo;
var
  CloudPathOwnerSetLastScanTimeInfo : TCloudPathOwnerSetLastScanTimeInfo;
begin
  CloudPathOwnerSetLastScanTimeInfo := TCloudPathOwnerSetLastScanTimeInfo.Create( CloudPath );
  CloudPathOwnerSetLastScanTimeInfo.SetOwnerPcID( OwnerPcID );
  CloudPathOwnerSetLastScanTimeInfo.SetLastScanTime( LastScanTime );
  MyCloudFileInfo.AddChange( CloudPathOwnerSetLastScanTimeInfo );
end;

procedure TCloudPathOwnerSetLastScanTimeHandle.SetToXml;
var
  CloudPathOwnerSetLastScanTimeXml : TCloudPathOwnerSetLastScanTimeXml;
begin
  CloudPathOwnerSetLastScanTimeXml := TCloudPathOwnerSetLastScanTimeXml.Create( CloudPath );
  CloudPathOwnerSetLastScanTimeXml.SetOwnerPcID( OwnerPcID );
  CloudPathOwnerSetLastScanTimeXml.SetLastScanTime( LastScanTime );
  MyCloudPathXmlWrite.AddChange( CloudPathOwnerSetLastScanTimeXml );
end;

procedure TCloudPathOwnerSetLastScanTimeHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TCloudPathOnlineScanHandle }

procedure TCloudPathOnlineScanHandle.AddToInfo;
var
  CloudPathOnlineScanInfo : TCloudPathOnlineScanInfo;
begin
  CloudPathOnlineScanInfo := TCloudPathOnlineScanInfo.Create;
  CloudPathOnlineScanInfo.SetPcID( OnlinePcID );
  MyCloudFileInfo.AddChange( CloudPathOnlineScanInfo );
end;

procedure TCloudPathOnlineScanHandle.SetOnlinePcID(_OnlinePcID: string);
begin
  OnlinePcID := _OnlinePcID;
end;

procedure TCloudPathOnlineScanHandle.Update;
begin
  AddToInfo;
end;

end.
