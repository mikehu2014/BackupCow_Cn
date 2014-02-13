unit UMyCloudDataInfo;

interface

uses Generics.Collections, UDataSetInfo, UMyUtil;

type

{$Region ' ���ݽṹ ' }

    // ���ݽṹ
  TCloudPcBackupInfo = class
  public
    BackupPath : string;
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    constructor Create( _BackupPath : string );
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
  end;
  TCloudPcBackupList = class( TObjectList<TCloudPcBackupInfo> );

    // ���ݽṹ
  TCloudPcInfo = class
  public
    PcID : string;
    CloudPcBackupList : TCloudPcBackupList;
  public
    constructor Create( _PcID : string );
    destructor Destroy; override;
  end;
  TCloudPcList = class( TObjectList<TCloudPcInfo> );

    // ��Pc��Ϣ
  TMyCloudInfo = class( TMyDataInfo )
  public
    CloudPath : string;
    CloudPcList : TCloudPcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݽӿ� ' }

    // ���� ���� List �ӿ�
  TCloudPcListAccessInfo = class
  protected
    CloudPcList : TCloudPcList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TCloudPcAccessInfo = class( TCloudPcListAccessInfo )
  public
    PcID : string;
  protected
    CloudPcIndex : Integer;
    CloudPcInfo : TCloudPcInfo;
  public
    constructor Create( _PcID : string );
  protected
    function FindCloudPcInfo: Boolean;
  end;

    // ���� ���� List �ӿ�
  TCloudPcBackupListAccessInfo = class( TCloudPcAccessInfo )
  protected
    CloudPcBackupList : TCloudPcBackupList;
  protected
    function FindCloudPcBackupList : Boolean;
  end;

    // ���� ���ݽӿ�
  TCloudPcBackupAccessInfo = class( TCloudPcBackupListAccessInfo )
  public
    BackupPath : string;
  protected
    CloudPcBackupIndex : Integer;
    CloudPcBackupInfo : TCloudPcBackupInfo;
  public
    procedure SetBackupPath( _BackupPath : string );
  protected
    function FindCloudPcBackupInfo: Boolean;
  end;

{$EndRegion}

{$Region ' �����޸� ��·����Ϣ ' }

    // �޸�
  TCloudPathWriteInfo = class( TCloudPcListAccessInfo )
  public
    CloudPath : string;
  public
    constructor Create( _CloudPath : string );
  end;

    // ��ȡ��һ������
  TCloudPathReadInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;
  end;

    // ����
  TCloudPathReSetInfo = class( TCloudPathWriteInfo )
  public
    procedure Update;
  end;


{$EndRegion}

{$Region ' �����޸� Pc��Ϣ ' }

    // �޸ĸ���
  TCloudPcWriteInfo = class( TCloudPcAccessInfo )
  end;

    // ���
  TCloudPcAddInfo = class( TCloudPcWriteInfo )
  public
    procedure Update;
  end;

    // ɾ��
  TCloudPcRemoveInfo = class( TCloudPcWriteInfo )
  public
    procedure Update;
  end;


{$EndRegion}

{$Region ' �����޸� ����·�� ' }

    // �޸ĸ���
  TCloudPcBackupWriteInfo = class( TCloudPcBackupAccessInfo )
  end;

    // ���
  TCloudPcBackupAddInfo = class( TCloudPcBackupWriteInfo )
  public
    IsFile : boolean;
  public
    FileCount : integer;
    ItemSize : int64;
  public
    LastBackupTime : TDateTime;
  public
    procedure SetIsFile( _IsFile : boolean );
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
    procedure Update;
  end;

    // ɾ��
  TCloudPcBackupRemoveInfo = class( TCloudPcBackupWriteInfo )
  public
    procedure Update;
  end;

{$EndRegion}

{$Region ' ���ݶ�ȡ Pc��Ϣ ' }

  TCloudPcListReadInfo = class( TCloudPcListAccessInfo )
  public
    function get : TCloudPcList;
  end;


  MyCloudInfoReadUtil = class
  public
    class function ReadCloudPcList : TCloudPcList;
  public
    class function ReadCloudFilePath( PcID, FilePath : string ): string;
    class function ReadCloudAvalibleSpace : Int64;
  end;

{$EndRegion}

var
  MyCloudInfo : TMyCloudInfo;

implementation

{ TCloudPcBackupInfo }

constructor TCloudPcBackupInfo.Create( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

procedure TCloudPcBackupInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudPcBackupInfo.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudPcBackupInfo.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

{ TCloudPcInfo }

constructor TCloudPcInfo.Create( _PcID : string );
begin
  PcID := _PcID;
  CloudPcBackupList := TCloudPcBackupList.Create;
end;


destructor TCloudPcInfo.Destroy;
begin
  CloudPcBackupList.Free;
  inherited;
end;

{ TMyCloudInfo }

constructor TMyCloudInfo.Create;
begin
  inherited;
  CloudPcList := TCloudPcList.Create;
end;

destructor TMyCloudInfo.Destroy;
begin
  CloudPcList.Free;
  inherited;
end;

{ TCloudPcListAccessInfo }

constructor TCloudPcListAccessInfo.Create;
begin
  MyCloudInfo.EnterData;
  CloudPcList := MyCloudInfo.CloudPcList;
end;

destructor TCloudPcListAccessInfo.Destroy;
begin
  MyCloudInfo.LeaveData;
  inherited;
end;

{ TCloudPcAccessInfo }

constructor TCloudPcAccessInfo.Create( _PcID : string );
begin
  inherited Create;
  PcID := _PcID;
end;

function TCloudPcAccessInfo.FindCloudPcInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to CloudPcList.Count - 1 do
    if ( CloudPcList[i].PcID = PcID ) then
    begin
      Result := True;
      CloudPcIndex := i;
      CloudPcInfo := CloudPcList[i];
      break;
    end;
end;

{ TCloudPcBackupListAccessInfo }

function TCloudPcBackupListAccessInfo.FindCloudPcBackupList : Boolean;
begin
  Result := FindCloudPcInfo;
  if Result then
    CloudPcBackupList := CloudPcInfo.CloudPcBackupList
  else
    CloudPcBackupList := nil;
end;

{ TCloudPcBackupAccessInfo }

procedure TCloudPcBackupAccessInfo.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;


function TCloudPcBackupAccessInfo.FindCloudPcBackupInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  if not FindCloudPcBackupList then
    Exit;
  for i := 0 to CloudPcBackupList.Count - 1 do
    if ( CloudPcBackupList[i].BackupPath = BackupPath ) then
    begin
      Result := True;
      CloudPcBackupIndex := i;
      CloudPcBackupInfo := CloudPcBackupList[i];
      break;
    end;
end;

{ TCloudPcAddInfo }

procedure TCloudPcAddInfo.Update;
begin
  if FindCloudPcInfo then
    Exit;

  CloudPcInfo := TCloudPcInfo.Create( PcID );
  CloudPcList.Add( CloudPcInfo );
end;

{ TCloudPcRemoveInfo }

procedure TCloudPcRemoveInfo.Update;
begin
  if not FindCloudPcInfo then
    Exit;

  CloudPcList.Delete( CloudPcIndex );
end;

{ TCloudPcBackupAddInfo }

procedure TCloudPcBackupAddInfo.SetIsFile( _IsFile : boolean );
begin
  IsFile := _IsFile;
end;

procedure TCloudPcBackupAddInfo.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TCloudPcBackupAddInfo.SetSpaceInfo( _FileCount : integer; _ItemSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
end;

procedure TCloudPcBackupAddInfo.Update;
begin
    // ������ �򴴽�
  if not FindCloudPcBackupInfo then
  begin
    CloudPcBackupInfo := TCloudPcBackupInfo.Create( BackupPath );
    CloudPcBackupInfo.SetIsFile( IsFile );
    CloudPcBackupList.Add( CloudPcBackupInfo );
  end;

    // ���� ���������� �ռ���Ϣ
  CloudPcBackupInfo.SetSpaceInfo( FileCount, ItemSize );
  CloudPcBackupInfo.SetLastBackupTime( LastBackupTime );
end;

{ TCloudPcBackupRemoveInfo }

procedure TCloudPcBackupRemoveInfo.Update;
begin
  if not FindCloudPcBackupInfo then
    Exit;

  CloudPcBackupList.Delete( CloudPcBackupIndex );
end;

{ TCloudPathWriteInfo }

constructor TCloudPathWriteInfo.Create(_CloudPath: string);
begin
  inherited Create;
  CloudPath := _CloudPath;
end;

{ TCloudPathReadInfo }

procedure TCloudPathReadInfo.Update;
begin
  MyCloudInfo.CloudPath := CloudPath;
end;

{ TCloudPathReSetInfo }

procedure TCloudPathReSetInfo.Update;
begin
  MyCloudInfo.CloudPath := CloudPath;
  CloudPcList.Clear;
end;

{ TCloudPcListReadInfo }

function TCloudPcListReadInfo.get: TCloudPcList;
var
  i, j: Integer;
  CloudPcInfo : TCloudPcInfo;
  CloudBackupList : TCloudPcBackupList;
  CloudBackupInfo : TCloudPcBackupInfo;
begin
  Result := TCloudPcList.Create;
  for i := 0 to CloudPcList.Count - 1 do
  begin
    CloudPcInfo := TCloudPcInfo.Create( CloudPcList[i].PcID );
    CloudBackupList := CloudPcList[i].CloudPcBackupList;
    for j := 0 to CloudBackupList.Count - 1 do
    begin
      CloudBackupInfo := TCloudPcBackupInfo.Create( CloudBackupList[j].BackupPath );
      CloudBackupInfo.SetIsFile( CloudBackupList[j].IsFile );
      CloudBackupInfo.SetSpaceInfo( CloudBackupList[j].FileCount, CloudBackupList[j].ItemSize );
      CloudBackupInfo.SetLastBackupTime( CloudBackupList[j].LastBackupTime );
      CloudPcInfo.CloudPcBackupList.Add( CloudBackupInfo ) ;
    end;
    Result.Add( CloudPcInfo );
  end;
end;

{ MyCloudInfoReadUtil }

class function MyCloudInfoReadUtil.ReadCloudAvalibleSpace: Int64;
begin
  Result := MyHardDisk.getHardDiskFreeSize( MyCloudInfo.CloudPath );
end;

class function MyCloudInfoReadUtil.ReadCloudFilePath(PcID,
  FilePath: string): string;
begin
  Result := MyFilePath.getPath( MyCloudInfo.CloudPath );
  Result := Result + MyFilePath.getPath( PcID );
  Result := Result + MyFilePath.getDownloadPath( FilePath );
end;

class function MyCloudInfoReadUtil.ReadCloudPcList: TCloudPcList;
var
  CloudPcListReadInfo : TCloudPcListReadInfo;
begin
  CloudPcListReadInfo := TCloudPcListReadInfo.Create;
  Result := CloudPcListReadInfo.get;
  CloudPcListReadInfo.Free;
end;

end.
