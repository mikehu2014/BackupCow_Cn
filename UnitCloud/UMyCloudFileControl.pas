unit UMyCloudFileControl;

interface

type

{$Region ' ��·�� �޸� ' }

    // ���� ɨ����·��
  TCloudPathOnlineScanHandle = class
  public
    OnlinePcID : string;
  public
    procedure SetOnlinePcID( _OnlinePcID : string );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // �޸�
  TCloudPathChangeHandle = class
  protected
    CloudPath : string;
  public
    constructor Create( _CloudlPath : string );
  end;

    // ��ȡ
  TCloudPathReadHandle = class( TCloudPathChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // ���
  TCloudPathAddHandle = class( TCloudPathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // �Ƴ�
  TCloudPathRemoveHandle = class( TCloudPathChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' ��·�� ӵ���� �޸� ' }

    // �޸�
  TCloudPathOwnerChangeHandle = class( TCloudPathChangeHandle )
  public
    OwnerPcID : string;
  public
    procedure SetOwnerPcID( _OwnerPcID : string );
  end;

    // ��ȡ
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

    // ���� ��һ�� ɨ��ʱ��
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

    // ɾ��
  TCloudPathOwnerRemoveHandle = class( TCloudPathOwnerChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$Region ' �޸� �ռ���Ϣ ' }

    // ����
  TCloudPathOwnerChangeSpaceHandle = class( TCloudPathOwnerChangeHandle )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ���
  TCloudPathOwnerSpaceAddHandle = class( TCloudPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToXml;
  end;

    // ɾ��
  TCloudPathOwnerSpaceRemoveHandle = class( TCloudPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

    // ����
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

    // ���ļ� ������
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
    // д Xml
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
    // д �ڴ�
  CloudPathRemoveInfo := TCloudPathRemoveInfo.Create( CloudPath );
  MyCloudFileInfo.AddChange( CloudPathRemoveInfo );
end;

procedure TCloudPathRemoveHandle.RemoveFromXml;
var
  CloudPathRemoveXml : TCloudPathRemoveXml;
begin
    // д Xml
  CloudPathRemoveXml := TCloudPathRemoveXml.Create( CloudPath );
  MyCloudPathXmlWrite.AddChange( CloudPathRemoveXml );
end;

procedure TCloudPathRemoveHandle.Update;
begin
    // ɾ����Ϣ
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
    // д �ڴ�
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
