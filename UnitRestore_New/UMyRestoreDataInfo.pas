unit UMyRestoreDataInfo;

interface

uses Generics.Collections, UDataSetInfo;

type

{$Region ' ���ݽṹ ' }

    // ���ݽṹ
  TRestoreDownInfo = class
  public
    RestorePath, RestoreOwner : string;
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    constructor Create( _RestorePath, _RestoreOwner : string );
    procedure SetRestoreFrom( _RestoreFrom : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
  end;
  TRestoreDownList = class( TObjectList<TRestoreDownInfo> );

    // ���ݼ�
  TMyRestoreDownInfo = class( TMyDataInfo )
  public
    RestoreDownList : TRestoreDownList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$EndRegion}

{$Region ' ���ݷ��� ' }

    // ���� ���� List �ӿ�
  TRestoreDownListAccessInfo = class
  protected
    RestoreDownList : TRestoreDownList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

    // ���� ���ݽӿ�
  TRestoreDownAccessInfo = class( TRestoreDownListAccessInfo )
  public
    RestorePath, RestoreOwner : string;
  protected
    RestoreDownIndex : Integer;
    RestoreDownInfo : TRestoreDownInfo;
  public
    constructor Create( _RestorePath, _RestoreOwner : string );
  protected
    function FindRestoreDownInfo: Boolean;
  end;

    // �޸ĸ���
  TRestoreDownWriteInfo = class( TRestoreDownAccessInfo )
  end;

    // ��ȡ����
  TRestoreDownReadInfo = class( TRestoreDownAccessInfo )
  end;


{$EndRegion}

{$Region ' �����޸� ' }

    // ���
  TRestoreDownAddInfo = class( TRestoreDownWriteInfo )
  public
    RestoreFrom : string;
  public
    FileCount : integer;
    FileSize, CompletedSize : int64;
  public
    SavePath : string;
  public
    procedure SetRestoreFrom( _RestoreFrom : string );
    procedure SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
    procedure SetSavePath( _SavePath : string );
    procedure Update;
  end;

    // ɾ��
  TRestoreDownRemoveInfo = class( TRestoreDownWriteInfo )
  public
    procedure Update;
  end;



{$EndRegion}

var
  MyRestoreDownInfo : TMyRestoreDownInfo;

implementation

{ TRestoreDownInfo }

constructor TRestoreDownInfo.Create( _RestorePath, _RestoreOwner : string );
begin
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
end;

procedure TRestoreDownInfo.SetRestoreFrom( _RestoreFrom : string );
begin
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

{ TMyRestoreDownInfo }

constructor TMyRestoreDownInfo.Create;
begin
  inherited Create;
  RestoreDownList := TRestoreDownList.Create;
end;

destructor TMyRestoreDownInfo.Destroy;
begin
  RestoreDownList.Free;
  inherited;
end;

{ TRestoreDownListAccessInfo }

constructor TRestoreDownListAccessInfo.Create;
begin
  MyRestoreDownInfo.EnterData;
  RestoreDownList := MyRestoreDownInfo.RestoreDownList;
end;

destructor TRestoreDownListAccessInfo.Destroy;
begin
  MyRestoreDownInfo.LeaveData;
  inherited;
end;

{ TRestoreDownAccessInfo }

constructor TRestoreDownAccessInfo.Create( _RestorePath, _RestoreOwner : string );
begin
  inherited Create;
  RestorePath := _RestorePath;
  RestoreOwner := _RestoreOwner;
end;

function TRestoreDownAccessInfo.FindRestoreDownInfo: Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := 0 to RestoreDownList.Count - 1 do
    if ( RestoreDownList[i].RestorePath = RestorePath ) and ( RestoreDownList[i].RestoreOwner = RestoreOwner ) then
    begin
      Result := True;
      RestoreDownIndex := i;
      RestoreDownInfo := RestoreDownList[i];
      break;
    end;
end;

{ TRestoreDownAddInfo }

procedure TRestoreDownAddInfo.SetRestoreFrom( _RestoreFrom : string );
begin
  RestoreFrom := _RestoreFrom;
end;

procedure TRestoreDownAddInfo.SetSpaceInfo( _FileCount : integer; _FileSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TRestoreDownAddInfo.SetSavePath( _SavePath : string );
begin
  SavePath := _SavePath;
end;

procedure TRestoreDownAddInfo.Update;
begin
  if FindRestoreDownInfo then
    Exit;

  RestoreDownInfo := TRestoreDownInfo.Create( RestorePath, RestoreOwner );
  RestoreDownInfo.SetRestoreFrom( RestoreFrom );
  RestoreDownInfo.SetSpaceInfo( FileCount, FileSize, CompletedSize );
  RestoreDownInfo.SetSavePath( SavePath );
  RestoreDownList.Add( RestoreDownInfo );
end;

{ TRestoreDownRemoveInfo }

procedure TRestoreDownRemoveInfo.Update;
begin
  if not FindRestoreDownInfo then
    Exit;

  RestoreDownList.Delete( RestoreDownIndex );
end;




end.
