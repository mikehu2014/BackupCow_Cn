unit UJobXml;

interface

uses UModelUtil;

type

{$Region ' ����Job Xml д ' }

  {$Region ' ���ݽṹ ' }

  {$Region ' ���� ' }

    // ����
  TOfflineJobWriteXml = class( TChangeInfo )
  end;

    // ���� �޸�
  TOfflineJobChangeXml = class( TOfflineJobWriteXml )
  public
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
  end;

  {$EndRegion}

  {$Region ' ��� ' }

    // ���� ���
  TOfflineJobAddXml = class( TOfflineJobChangeXml )
  public
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize, _Position : Int64 );
    procedure SetFileTime( _FileTime : TDateTime );
  end;

    // ��� ����
  TOfflineBackupJobAddXml = class( TOfflineJobAddXml )
  public
    UpFilePath : string;
  public
    procedure SetUpFilePath( _UpFilePath : string );
  end;

    // ��� ����
  TOfflineDownJobAddXml = class( TOfflineJobAddXml )
  public
    FilePath : string;
    DownFilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetDownFilePath( _DownFilePath : string );
  end;

    // ��� ����
  TOfflineSearchJobAddXml = class( TOfflineDownJobAddXml )
  public
    IsBackupFile : Boolean;
    BackupFilePcID : string;
  public
    procedure SetSearchXml( _IsBackupFile : Boolean; _BackupFilePcID : string );
  end;

    // ��� �ָ�
  TOfflineRestoreJobAddXml = class( TOfflineDownJobAddXml )
  end;


  {$EndRegion}


  {$EndRegion}

  {$Region ' ���ݲ��� ' }

  {$Region ' ���� ' }

  TOfflineJobChangeXmlHandle = class( TChangeHandle )
  protected
    PcID : string;
  protected
    procedure ExtractInfo;override;
  end;

  {$EndRegion}

  {$Region ' ��� ' }

    // ����
  TOfflineJobAddXmlHandle = class( TOfflineJobChangeXmlHandle )
  protected
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    procedure Update;override;
  protected
    procedure ExtractInfo;override;
  end;

    // ����
  TOfflineBackupJobAddXmlHandle = class( TOfflineJobAddXmlHandle )
  private
    UpFilePath : string;
  protected
    procedure ExtractInfo;override;
  end;

    // ����
  TOfflineDownJobAddXmlHandle = class( TOfflineJobAddXmlHandle )
  protected
    FilePath : string;
    DownFilePath : string;
  protected
    procedure ExtractInfo;override;
  end;

    // ����
  TOfflineSearchJobAddXmlHandle = class( TOfflineDownJobAddXmlHandle )
  private
    IsBackupFile : Boolean;
    BackupFilePcID : string;
  protected
    procedure ExtractInfo;override;
  end;

    // �ָ�
  TOfflineRestoreJobAddXmlHandle = class( TOfflineDownJobAddXmlHandle )
  end;

  {$EndRegion}

{$EndRegion}


  TJobXmlWriteThread = class( TChangeXmlHandleThread )
  end;

implementation

{ TOfflineJobChangeXml }

procedure TOfflineJobChangeXml.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TOfflineJobAddXml }

procedure TOfflineJobAddXml.SetFileInfo(_FileSize, _Position: Int64);
begin
  FileSize := _FileSize;
  Position := _Position;
end;

procedure TOfflineJobAddXml.SetFileTime(_FileTime: TDateTime);
begin
  FileTime := _FileTime;
end;



{ TOfflineBackupJobAddXml }

procedure TOfflineBackupJobAddXml.SetUpFilePath(_UpFilePath: string);
begin
  UpFilePath := _UpFilePath;
end;

{ TOfflineDownJobAddXml }

procedure TOfflineDownJobAddXml.SetDownFilePath(_DownFilePath: string);
begin
  DownFilePath := _DownFilePath;
end;

procedure TOfflineDownJobAddXml.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TOfflineSearchJobAddXml }

procedure TOfflineSearchJobAddXml.SetSearchXml(_IsBackupFile: Boolean;
  _BackupFilePcID: string);
begin
  IsBackupFile := _IsBackupFile;
  BackupFilePcID := _BackupFilePcID;
end;

{ TOfflineJobChangeXmlHandle }

procedure TOfflineJobChangeXmlHandle.ExtractInfo;
var
  OfflineJobChangeXml : TOfflineJobChangeXml;
begin
  OfflineJobChangeXml := ( ChangeInfo as TOfflineJobChangeXml );
  PcID := OfflineJobChangeXml.PcID;
end;

{ TOfflineJobAddXmlHandle }

procedure TOfflineJobAddXmlHandle.ExtractInfo;
var
  OfflineJobAddXml : TOfflineJobAddXml;
begin
  inherited;
  OfflineJobAddXml := ( ChangeInfo as TOfflineJobAddXml );
  FileSize := OfflineJobAddXml.FileSize;
  Position := OfflineJobAddXml.Position;
  FileTime := OfflineJobAddXml.FileTime;
end;

procedure TOfflineJobAddXmlHandle.Update;
begin

end;

{ TOfflineBackupJobAddXmlHandle }

procedure TOfflineBackupJobAddXmlHandle.ExtractInfo;
var
  OfflineBackupJobAddXml : TOfflineBackupJobAddXml;
begin
  inherited;
  OfflineBackupJobAddXml := ( ChangeInfo as TOfflineBackupJobAddXml );
  UpFilePath := OfflineBackupJobAddXml.UpFilePath;
end;

{ TOfflineDownJobAddXmlHandle }

procedure TOfflineDownJobAddXmlHandle.ExtractInfo;
var
  OfflineDownJobAddXml : TOfflineDownJobAddXml;
begin
  inherited;
  OfflineDownJobAddXml := ( ChangeInfo as TOfflineDownJobAddXml );
  FilePath := OfflineDownJobAddXml.FilePath;
  DownFilePath := OfflineDownJobAddXml.DownFilePath;
end;

{ TOfflineSearchJobAddXmlHandle }

procedure TOfflineSearchJobAddXmlHandle.ExtractInfo;
var
  OfflineSearchJobAddXml : TOfflineSearchJobAddXml;
begin
  inherited;
  OfflineSearchJobAddXml := ( ChangeInfo as TOfflineSearchJobAddXml );
  IsBackupFile := OfflineSearchJobAddXml.IsBackupFile;
  BackupFilePcID := OfflineSearchJobAddXml.BackupFilePcID;
end;

end.
