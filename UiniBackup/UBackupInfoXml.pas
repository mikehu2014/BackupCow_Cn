unit UBackupInfoXml;

interface

uses UChangeInfo, xmldom, XMLIntf, msxmldom, XMLDoc, UXmlUtil, UMyUtil, SysUtils, Classes;

type

{$Region ' д ����·�� xml��Ϣ '}

    // ����·��Xml д��Ϣ ����
  TBackupPathWriteXml = class( TChangeInfo )
  public
    FullPath : string;
  protected
    BackupPathNode : IXMLNode;
  public
    constructor Create( _FullPath : string );
  protected
    function FindBackupPathNode : Boolean;
  end;

    // ��� ����·��Xml ��Ϣ
  TBackupPathAddXml = class( TBackupPathWriteXml )
  public
    PathType : string;
    IsDisable, IsBackupNow: Boolean;
    CopyCount : Integer;
  public
    IsAutoSync: Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    FileCount : Integer;
    FolderSpace, CompletedSpace : Int64;
  public
    procedure SetPathType( _PathType : string );
    procedure SetBackupInfo( _IsDisable, _IsBackupNow: Boolean );
    procedure SetAcutoSyncInfo( _IsAutoSync: Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncIntervalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FolderSpace, _CompletedSpace : Int64 );
    procedure Update; override;
  end;

    // ·�� Copy ��
  TBackupPathCopyCountXml = class( TBackupPathWriteXml )
  public
    CopyCount : Integer;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
  end;

      // ·���� �ܿռ�
  TBackupPathSetSpaceXml = class( TBackupPathWriteXml )
  private
    FolderSpace : Int64;
    FileCount : Integer;
  public
    procedure SetFolderSpace( _FolderSpace : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' ���� ״̬��Ϣ ' }

      // �Ƿ� ��ֹ����
  TBackupPathIsDisableXml = class( TBackupPathWriteXml )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // �Ƿ� Backup Now ����
  TBackupPathIsBackupNowXml = class( TBackupPathWriteXml )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ͬ��ʱ�� ��Ϣ ' }

    // ���� ��һ�� ͬ��ʱ��
  TBackupPathSetLastSyncTimeXml = class( TBackupPathWriteXml )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // ���� ��һ�� ͬ��ʱ��
  TBackupPathSetSyncMinsXml = class( TBackupPathWriteXml )
  private
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ����ɿռ� ��Ϣ ' }

    // �޸�
  TBackupPathCompletedSpaceChangeXml = class( TBackupPathWriteXml )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ���
  TBackupPathAddCompletedSpaceXml = class( TBackupPathCompletedSpaceChangeXml )
  public
    procedure Update;override;
  end;

    // ɾ��
  TBackupPathRemoveCompletedSpaceXml = class( TBackupPathCompletedSpaceChangeXml )
  public
    procedure Update;override;
  end;

    // ����
  TBackupPathSetCompletedSpaceXml = class( TBackupPathCompletedSpaceChangeXml )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // �汾����, ���� ���ڵ�
  TBackupPathSetRootNodeXml = class( TBackupPathWriteXml )
  public
    procedure Update; override;
  end;

    // ɾ�� ����·��Xml ��Ϣ
  TBackupPathRemoveXml = class( TBackupPathWriteXml )
  public
    procedure Update; override;
  end;

{$EndRegion}

{$Region ' д ����·��ӵ���� Xml��Ϣ ' }

    // ����
  TBackupPathOwnerChangeXml = class( TBackupPathWriteXml )
  public
    BackupOwnerListNode : IXMLNode;
  protected
    function FindBackupOwnerListNode : Boolean;
  end;

    // ���
  TBackupPathOwnerClearXml = class( TBackupPathOwnerChangeXml )
  public
    procedure Update;override;
  end;

    // �޸�
  TBackupPathOwnerWriteXml = class( TBackupPathOwnerChangeXml )
  public
    PcID : string;
  protected
    BackupOwnerNode : IXMLNode;
  public
    procedure SetPcID( _PcID : string );
  protected
    function FindBackupOwnerNode : Boolean;
    procedure AddBackupOwnerNode;
  end;

    // �޸� �ռ���Ϣ
  TBackupPathOwnerChangeSpaceXml = class( TBackupPathOwnerWriteXml )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ��� �ռ���Ϣ
  TBackupPathOwnerAddSpaceXml = class( TBackupPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // ɾ�� �ռ���Ϣ
  TBackupPathOwnerRemoveSpaceXml = class( TBackupPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

    // ����
  TBackupPathOwnerSetSpaceXml = class( TBackupPathOwnerChangeSpaceXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д ����·�������� Xml��Ϣ ' }

  {$Region ' ���� ������ ' }

    // ����
  TBackupPathIncludeFilterChangeXml = class( TBackupPathWriteXml )
  protected
    IncludeFilterListNode : IXMLNode;
  protected
    function FindIncludeFilterListNode : Boolean;
  end;

    // ���
  TBackupPathIncludeFilterClearXml = class( TBackupPathIncludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // ���
  TBackupPathIncludeFilterAddXml = class( TBackupPathIncludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �ų� ������ ' }

    // ����
  TBackupPathExcludeFilterChangeXml = class( TBackupPathWriteXml )
  protected
    ExcludeFilterListNode : IXMLNode;
  protected
    function FindExcludeFilterListNode : Boolean;
  end;

    // ���
  TBackupPathExcludeFilterClearXml = class( TBackupPathExcludeFilterChangeXml )
  public
    procedure Update;override;
  end;

    // ���
  TBackupPathExcludeFilterAddXml = class( TBackupPathExcludeFilterChangeXml )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' д ����Ŀ¼ Xml��Ϣ ' }

    // д��Ϣ ����
  TBackupFolderWriteXml = class( TChangeInfo )
  public
    FolderPath : string;
  public
    RootFolderNode : IXMLNode;
    FolderNode : IXMLNode;
  public
    constructor Create( _FolderPath : string );
  protected
    function FindRootFolderNode : Boolean;
    function FindFolderNode: Boolean;
  end;

      // ���
  TBackupFolderAddXml = class( TBackupFolderWriteXml )
  public
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFolderInfo( _FileTime : TDateTime; _FileCount : Integer );
    procedure Update;override;
  private
    procedure AddFolderNode;
  end;

    // ���� �ܿռ� ��Ϣ
  TBackupFolderSetSpaceXml = class( TBackupFolderWriteXml )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' �޸� ����ɿռ� ��Ϣ ' }

    // �޸�
  TBackupFolderCompletedSpaceChangeXml = class( TBackupFolderWriteXml )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ���
  TBackupFolderAddCompletedSpaceXml = class( TBackupFolderCompletedSpaceChangeXml )
  public
    procedure Update;override;
  private
    procedure ResetNode( Node : IXMLNode );
  end;

    // ɾ��
  TBackupFolderRemoveCompletedSpaceXml = class( TBackupFolderCompletedSpaceChangeXml )
  public
    procedure Update;override;
  private
    procedure ResetNode( Node : IXMLNode );
  end;

    // ����
  TBackupFolderSetCompletedSpaceXml = class( TBackupFolderCompletedSpaceChangeXml )
  private
    LastCompletedSpace : Int64;
  public
    procedure SetLastCompletedSpace( _LastCompletedSpace : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

    // ɾ��
  TBackupFolderRemoveXml = class( TBackupFolderWriteXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д �����ļ� Xml��Ϣ '}

    // д��Ϣ ����
  TBackupFileWriteXml = class( TChangeInfo )
  public
    FilePath : string;
  protected
    RootFolderNode : IXMLNode;
    FileNode : IXMLNode;
  public
    constructor Create( _FilePath : string );
  protected
    function FindRootFolderNode : Boolean;
    function FindFileNode: Boolean;
  end;

    // ��� ��Ϣ
  TBackupFileAddXml = class( TBackupFileWriteXml )
  public
    FileSize : Int64;
    LastWriteTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : Int64; _LastWriteTime : TDateTime );
    procedure Update;override;
  private
    procedure AddFileNode;
  end;

    // ɾ�� ��Ϣ
  TBackupFileRemoveXml = class( TBackupFileWriteXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д �����ļ����� Xml��Ϣ ' }

    // ����
  TBackupFileCopyChangeXml = class( TBackupFileWriteXml )
  public
    CopyListNode : IXMLNode;
  protected
    function FindCopyListNode : Boolean;
  end;

    // �޸�
  TBackupFileCopyWriteXml = class( TBackupFileCopyChangeXml )
  public
    CopyOwner : string;
  protected
    CopyNode : IXMLNode;
  public
    procedure SetCopyOwner( _CopyOwner : string );
  protected
    function FindCopyNode : Boolean;
    procedure AddCopyNode;
  end;

    // ���
  TBackupFileCopyAddXml = class( TBackupFileCopyWriteXml )
  public
    CopyStatus : string;
  public
    procedure SetCopyStatus( _CopyStatus : string );
    procedure Update;override;
  end;

    // �������
  TBackupFileCopyAddOfflineXml = class( TBackupFileCopyAddXml )
  public
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  end;

    // ɾ��
  TBackupFileCopyRemoveXml = class( TBackupFileCopyWriteXml )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' �� ����Xml��Ϣ ' }

    // �� ����·�� Xml
  TBackupPathXmlReadHandle = class
  public
    BackupPathNode : IXMLNode;
    FullPath : string;
  public
    constructor Create( _BackupPathNode : IXMLNode );
    procedure Update;
  private
    procedure ReadBackupPathOwner;
    procedure ReadBackupPathFilder;
    procedure AddRootPathLoading;
  private
    procedure ResetPathCopyCount;
  end;

    // �� ����·��ӵ���� Xml
  TBackupPathOwnerXmlReadHandle = class
  public
    BackupPathOwnerNode : IXMLNode;
    FullPath : string;
  public
    constructor Create( _BackupPathOwnerNode : IXMLNode );
    procedure SetFullPath( _FullPath : string );
    procedure Update;
  end;

    // �� ����·�� ���� Xml
  TBackupPathFilterXmlReadHandle = class
  public
    BackupPathFilterNode : IXMLNode;
    FullPath : string;
  protected
    FilterType, FilterStr : string;
  public
    constructor Create( _BackupPathFilterNode : IXMLNode );
    procedure SetFullPath( _FullPath : string );
    procedure Update;
  protected
    procedure AddFilterHandle;virtual;abstract;
  end;

    // �� ����·�� �������� Xml
  TBackupPathIncludeFilterXmlReadHandle = class( TBackupPathFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // �� ����·�� �ų����� Xml
  TBackupPathExcludeFilterXmlReadHandle = class( TBackupPathFilterXmlReadHandle )
  protected
    procedure AddFilterHandle;override;
  end;

    // �� ����·����Ŀ¼
  TBackupPathRootFolderXmlReadHandle = class
  public
    BackupPathNode : IXMLNode;
    FullPath : string;
    RootNode : IXMLNode;
  public
    constructor Create( _BackupPathNode : IXMLNode );
    procedure Update;
  private       // Backup Board Face
    procedure AddBackupBoard;
    procedure RemoveBackupBoard;
    procedure RemoveRootPathLoading;
  private
    procedure RootNodeEdition; // �汾����
    procedure ReadRootFolder;
    procedure ReadRootFile;
  end;

    // �� ����Ŀ¼ Xml
  TBackupFolderXmlReadHandle = class
  private
    FolderNode : IXMLNode;
    ParentPath : string;
    FolderPath : string;
  private
    ReadCount : Integer;
    ReadFileCount : Integer;
  public
    constructor Create( _FolderNode : IXMLNode );
    procedure SetParentPath( _ParentPath : string );
    procedure SetReadCount( _ReadCount : Integer );
    procedure SetReadFileCount( _ReadFileCount : Integer );
    procedure Update;
  private
    procedure ReadChildFiles;
    procedure ReadChildFolders;
  private
    function CheckNextRead : Boolean;
    procedure AddFolderLoading;
    procedure AddBackupBoradFileCount;
    procedure RemoveFolderLoading;
  end;

    // �� �ļ� Xml
  TBackupFileXmlReadHandle = class
  public
    ParentPath : string;
    FileNode : IXMLNode;
  public
    FilePath : string;
    FileSize : Int64;
    LastWriteTime : TDateTime;
  public
    constructor Create( _FileNode : IXMLNode );
    procedure SetParentPath( _ParentPath : string );
    procedure Update;
  private
    procedure ReadFileCopy;
  end;

      // �� �ļ����� Xml
  TBackupFileCopyXmlReadHandle = class
  public
    FilePath : string;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    CopyNode : IXMLNode;
    CopyOwner : string;
  public
    constructor Create( _CopyNode : IXMLNode );
    procedure SetFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;
  private
    procedure ReadOfflineCopy;
    procedure ReadLoadedCopy;
  end;

    // ��ȡ ���� Xml ��Ϣ
  TMyBackupXmlRead = class
  public
    procedure Update;
  private
    procedure ReadBackupPath;
    procedure ReadBackupFolder;
    procedure SyncAllBackuPath;
  private
    procedure ReadCompleted;
  end;

{$EndRegion}

const
    // Backup Path Xml
  Xml_FullPath = 'fp';
  Xml_PathType = 'pt';
  Xml_IsDisable = 'id';
  Xml_IsBackupNow = 'ibn';
  Xml_CopyCount = 'cc';
  Xml_IsAutoSync = 'ias';
  Xml_SyncTimeType = 'stt';
  Xml_SyncTimeValue = 'stv';
  Xml_LastSyncTime = 'lst';
  Xml_IsEncrypt = 'ie';
  Xml_Password = 'pw';
  Xml_PasswordHint = 'pwh';
  Xml_FolderSpace = 'fs';
  Xml_CompletedSpace = 'cs';
  Xml_PathFileCount = 'pfc';
  Xml_BackupFolder = 'bf';
  Xml_BackupPathCopyOwnerList = 'bpcol';
  Xml_ExcludeFilterList = 'efl';
  Xml_IncludeFilterList = 'ifl';

  Xml_OwnerPcID = 'opid';
  Xml_OwnerSpace = 'os';
  Xml_OwnerFileCount = 'ofc';

  Xml_FilterType = 'ft';
  Xml_FilterStr = 'fs';

    // Backup File/Folder Xml
  Xml_FileName = 'fn';
  Xml_FileSize = 'fs';
  Xml_LastWriteTime = 'lwt';
  Xml_BackupCopyList = 'bcl';
  Xml_BackupFileList = 'bfl';
  Xml_BackupFolderList = 'bfdl';
  Xml_FileCount = 'fc';
  // Xml_CompletedSpace


    // Backup Copy Info
  Xml_CopyOwner = 'co';
  Xml_CopyStatus = 'cs';
  Xml_Position = 'pt';

var
  DefaultXml_CopyCount : Integer = 1;  // ��ʷ�汾����
  MyBackupXmlWrite : TMyChildXmlChange;   // д Xml

implementation

uses UMyBackupInfo, UBackupInfoFace, UBackupUtil, UJobFace, UMyNetPcInfo, UMyJobInfo, UMyFileTransfer,
     UBackupCow, UBackupBoardInfo, UBackupInfoControl, UJobControl;

{ TBackupPathWriteInfo }

constructor TBackupPathWriteXml.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TBackupPathAddInfo }

procedure TBackupPathAddXml.SetBackupInfo(_IsDisable, _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathAddXml.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TBackupPathAddXml.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupPathAddXml.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TBackupPathAddXml.SetSpaceInfo(_FolderSpace, _CompletedSpace: Int64);
begin
  FolderSpace := _FolderSpace;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupPathAddXml.SetSyncIntervalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathAddXml.SetAcutoSyncInfo(_IsAutoSync: Boolean;
  _LastSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

{ TBackupFileAddInfo }

procedure TBackupFileAddXml.AddFileNode;
var
  RootFolderName : string;
  ChildNodeList, FileNodeList, ChildNode: IXMLNode;
  FolderPath, FileName : string;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
    // ��ȡ �ļ���Ϣ
  FolderPath := ExtractFileDir( FilePath );
  FileName := ExtractFileName( FilePath );

    // ��ȡ ���ڵ���Ϣ
  RootFolderName := MyXmlUtil.GetChildValue( RootFolderNode, Xml_FileName );

    // ���ڵ� �� Ŀ��ڵ�
  if ( RootFolderName = FilePath ) or ( RootFolderName = FolderPath ) then
    ChildNode := RootFolderNode
  else
  begin
      // �Ӹ�Ŀ¼����Ѱ��
    ChildNodeList := MyXmlUtil.AddChild( RootFolderNode, Xml_BackupFolderList );
    RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderName ), FolderPath );
    IsFindNext := True;
    while IsFindNext do             // Ѱ����Ŀ¼
    begin
      FolderName := MyString.GetRootFolder( RemainPath );
      if FolderName = '' then
      begin
        FolderName := RemainPath;
        IsFindNext := False;
      end;

      ChildNode := MyXmlUtil.FindListChild( ChildNodeList, FolderName );
      if ChildNode = nil then // ������Ŀ¼
      begin
        ChildNode := MyXmlUtil.AddListChild( ChildNodeList, FolderName );
        MyXmlUtil.AddChild( ChildNode, Xml_FileName, FolderName );
      end;

        // ��һ��
      ChildNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFolderList );
      RemainPath := MyString.CutRootFolder( RemainPath );
    end;
  end;

    // ��Ѱ �ļ��ڵ�
  FileNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFileList );
  FileNode := MyXmlUtil.FindListChild( FileNodeList, FileName );
  if FileNode = nil then
  begin
    FileNode := MyXmlUtil.AddListChild( FileNodeList, FileName );
    MyXmlUtil.AddChild( FileNode, Xml_FileName, FileName );
  end;
end;

procedure TBackupFileAddXml.SetFileInfo(_FileSize: Int64;
  _LastWriteTime: TDateTime);
begin
  FileSize := _FileSize;
  LastWriteTime := _LastWriteTime;
end;

procedure TBackupFileAddXml.Update;
var
  FileName : string;
begin
    // ������ ���ڵ�
  if not FindRootFolderNode then
    Exit;

    // ���
  AddFileNode;

    // ��ӽڵ���Ϣ
  FileName := ExtractFileName( FilePath );
  MyXmlUtil.AddChild( FileNode, Xml_FileName, FileName );
  MyXmlUtil.AddChild( FileNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( FileNode, Xml_LastWriteTime, FloatToStr( LastWriteTime ) );
end;

{ TBackupXmlRead }

procedure TMyBackupXmlRead.ReadBackupFolder;
var
  i : Integer;
  BackupPathNode : IXMLNode;
  BackuppathRootFolderXmlReadHandle : TBackupPathRootFolderXmlReadHandle;
begin
  for i := 0 to BackupPathHashXml.ChildNodes.Count - 1 do
  begin
    BackupPathNode := BackupPathHashXml.ChildNodes[i];

      // ��ȡ ·��������Ϣ
    BackuppathRootFolderXmlReadHandle := TBackupPathRootFolderXmlReadHandle.Create( BackupPathNode );
    BackuppathRootFolderXmlReadHandle.Update;
    BackuppathRootFolderXmlReadHandle.Free;
  end;
end;

procedure TMyBackupXmlRead.ReadBackupPath;
var
  i : Integer;
  BackupPathNode : IXMLNode;
  BackupPathXmlReadHandle : TBackupPathXmlReadHandle;
begin
  for i := 0 to BackupPathHashXml.ChildNodes.Count - 1 do
  begin
    BackupPathNode := BackupPathHashXml.ChildNodes[i];

      // ��ȡ ����·����Ϣ
    BackupPathXmlReadHandle := TBackupPathXmlReadHandle.Create( BackupPathNode );
    BackupPathXmlReadHandle.Update;
    BackupPathXmlReadHandle.Free;
  end;
end;

procedure TMyBackupXmlRead.ReadCompleted;
var
  BackupXmlReadCompleted : TBackupXmlReadCompleted;
begin
  BackupXmlReadCompleted := TBackupXmlReadCompleted.Create;
  MyBackupFileInfo.AddChange( BackupXmlReadCompleted );
end;

procedure TMyBackupXmlRead.SyncAllBackuPath;
var
  BackupPathSyncAllHandle : TBackupPathSyncAllHandle;
begin
  BackupPathSyncAllHandle := TBackupPathSyncAllHandle.Create;
  BackupPathSyncAllHandle.Update;
  BackupPathSyncAllHandle.Free;
end;

procedure TMyBackupXmlRead.Update;
begin
    // �� ����·��
  ReadBackupPath;

    // �� ����Ŀ¼
  ReadBackupFolder;

    // ��ȡ���
  ReadCompleted;

    // ͬ������·��
  SyncAllBackuPath;
end;

{ TBackupFolderXmlReadHandle }

procedure TBackupFolderXmlReadHandle.AddFolderLoading;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( FolderPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Loading );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

function TBackupFolderXmlReadHandle.CheckNextRead: Boolean;
begin
  Inc( ReadCount );
  if ReadCount >= XmlReadCount_Sleep then
  begin
    Sleep(1);
    ReadCount := 0;
  end;
  AddBackupBoradFileCount;

  Result := MyXmlReadThread.IsRun;
end;

constructor TBackupFolderXmlReadHandle.Create(_FolderNode: IXMLNode);
begin
  FolderNode := _FolderNode;
  ReadCount := 0;
  ReadFileCount := 0;
end;

procedure TBackupFolderXmlReadHandle.AddBackupBoradFileCount;
var
  BackupItemStatusFileCountInfo : TBackupItemStatusFileCountInfo;
begin
  BackupItemStatusFileCountInfo := TBackupItemStatusFileCountInfo.Create( BackupItemStatusType_Loading );
  BackupItemStatusFileCountInfo.SetFileCount( ReadFileCount );
  MyBackupBoardInfo.AddChange( BackupItemStatusFileCountInfo );
end;

procedure TBackupFolderXmlReadHandle.SetParentPath(_ParentPath: string);
begin
  ParentPath := _ParentPath;
end;

procedure TBackupFolderXmlReadHandle.SetReadCount(_ReadCount: Integer);
begin
  ReadCount := _ReadCount;
end;

procedure TBackupFolderXmlReadHandle.SetReadFileCount(_ReadFileCount: Integer);
begin
  ReadFileCount := _ReadFileCount;
end;

procedure TBackupFolderXmlReadHandle.ReadChildFiles;
var
  i : Integer;
  FileListNode, FileNode : IXMLNode;
  BackupFileXmlReadHandle : TBackupFileXmlReadHandle;
begin
    // �ݹ鴦���ļ���·��
  FileListNode := MyXmlUtil.AddChild( FolderNode, Xml_BackupFileList );
  for i := 0 to FileListNode.ChildNodes.Count - 1 do
  begin
    Inc( ReadFileCount );
    if not CheckNextRead then
      Break;

      // ��ȡ��ȡ����Ϣ
    FileNode := FileListNode.ChildNodes[i];

    BackupFileXmlReadHandle := TBackupFileXmlReadHandle.Create( FileNode );
    BackupFileXmlReadHandle.SetParentPath( FolderPath );
    BackupFileXmlReadHandle.Update;
    BackupFileXmlReadHandle.Free;
  end;
end;

procedure TBackupFolderXmlReadHandle.ReadChildFolders;
var
  FolderListNode, SelectFolderNode : IXMLNode;
  i : Integer;
  BackupFolderXmlReadHandle : TBackupFolderXmlReadHandle;
begin

    // �ݹ鴦���ļ���·��
  FolderListNode := MyXmlUtil.AddChild( FolderNode, Xml_BackupFolderList );
  for i := 0 to FolderListNode.ChildNodes.Count - 1 do
  begin
    if not CheckNextRead then
      Break;

      // ��ȡ��ȡ����Ϣ
    SelectFolderNode := FolderListNode.ChildNodes[i];

    BackupFolderXmlReadHandle := TBackupFolderXmlReadHandle.Create( SelectFolderNode );
    BackupFolderXmlReadHandle.SetParentPath( FolderPath );
    BackupFolderXmlReadHandle.SetReadCount( ReadCount );
    BackupFolderXmlReadHandle.SetReadFileCount( ReadFileCount );
    BackupFolderXmlReadHandle.Update;
    ReadCount := BackupFolderXmlReadHandle.ReadCount;
    ReadFileCount := BackupFolderXmlReadHandle.ReadFileCount;
    BackupFolderXmlReadHandle.Free;
  end;
end;

procedure TBackupFolderXmlReadHandle.RemoveFolderLoading;
var
  BackupFolderSetStatusHandle : TBackupFolderSetStatusHandle;
begin
  BackupFolderSetStatusHandle := TBackupFolderSetStatusHandle.Create( FolderPath );
  BackupFolderSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupFolderSetStatusHandle.Update;
  BackupFolderSetStatusHandle.Free;
end;

procedure TBackupFolderXmlReadHandle.Update;
var
  FolderName : string;
  FileSize, CompletedSpace : Int64;
  LastWriteTime : TDateTime;
  FileCount : Integer;
  BackupFolderReadHandle : TBackupFolderReadHandle;
begin
    // ��ȡ Ŀ¼��Ϣ
  FolderName := MyXmlUtil.GetChildValue( FolderNode, Xml_FileName );
  FolderPath := MyFilePath.getPath( ParentPath ) + FolderName;
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( FolderNode, Xml_FileSize ), 0 );
  LastWriteTime := StrToFloatDef( MyXmlUtil.GetChildValue( FolderNode, Xml_LastWriteTime ), Now );

  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( FolderNode, Xml_FileCount ), 0 );
  CompletedSpace := StrToIntDef( MyXmlUtil.GetChildValue( FolderNode, Xml_CompletedSpace ), 0 );

    // �����ȡ����Ϣ
  BackupFolderReadHandle := TBackupFolderReadHandle.Create( FolderPath );
  BackupFolderReadHandle.SetFolderInfo( LastWriteTime, FileCount );
  BackupFolderReadHandle.SetSpaceInfo( FileSize, CompletedSpace );
  BackupFolderReadHandle.Update;
  BackupFolderReadHandle.Free;

    // ��ʾ ���� Loading
  AddFolderLoading;

    // ��ȡ ���ļ�
  ReadChildFiles;

    // ��ȡ ��Ŀ¼
  ReadChildFolders;

    // ���� ���� Loading
  RemoveFolderLoading;
end;

procedure TBackupPathAddXml.Update;
var
  EncryptedPassword : string;
  BackupFolderNode : IXMLNode;
begin
    // �Ѵ���
  if FindBackupPathNode then
    Exit;

  EncryptedPassword := MyEncrypt.EncodeStr( Password );

    // ���� ����·���ڵ�
  BackupPathNode := MyXmlUtil.AddListChild( BackupPathHashXml, FullPath );

    // ���� Path Info
  MyXmlUtil.AddChild( BackupPathNode, Xml_FullPath, FullPath );
  MyXmlUtil.AddChild( BackupPathNode, Xml_PathType, PathType );
  MyXmlUtil.AddChild( BackupPathNode, Xml_IsDisable, BoolToStr( IsDisable ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_IsBackupNow, BoolToStr( IsBackupNow ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_CopyCount, IntToStr( CopyCount ) );

    // ���� �Զ�ͬ�� ͬ�����
  MyXmlUtil.AddChild( BackupPathNode, Xml_IsAutoSync, BoolToStr( IsAutoSync ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_SyncTimeType, IntToStr( SyncTimeType ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_SyncTimeValue, IntToStr( SyncTimeValue ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_LastSyncTime, FloatToStr( LastSyncTime ) );

    // ���� Encrypt Info
  MyXmlUtil.AddChild( BackupPathNode, Xml_IsEncrypt, BoolToStr( IsEncrypt ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_Password, EncryptedPassword );
  MyXmlUtil.AddChild( BackupPathNode, Xml_PasswordHint, PasswordHint );

    // ռ�� �ռ�
  MyXmlUtil.AddChild( BackupPathNode, Xml_FolderSpace, IntToStr( FolderSpace ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_PathFileCount, IntToStr( FileCount ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_CompletedSpace, IntToStr( CompletedSpace ) );

    // ��Ŀ¼�ڵ�
  BackupFolderNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupFolder );
  MyXmlUtil.AddChild( BackupFolderNode, Xml_FileName, FullPath );
end;

{ TBackupPathRemoveXml }

procedure TBackupPathRemoveXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.DeleteListChild( BackupPathHashXml, FullPath );
end;

{ TBackupFileRemoveXml }

procedure TBackupFileRemoveXml.Update;
var
  FileListNode : IXMLNode;
  FileName : string;
begin
    // ������
  if not FindFileNode then
    Exit;

    // ���ļ��б���ɾ��
  FileListNode := FileNode.ParentNode;
  FileName := ExtractFileName( FilePath );
  MyXmlUtil.DeleteListChild( FileListNode, FileName );
end;


{ TBackupPathFolderSpaceXml }

procedure TBackupPathSetSpaceXml.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TBackupPathSetSpaceXml.SetFolderSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TBackupPathSetSpaceXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_FolderSpace, IntToStr( FolderSpace ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_PathFileCount, IntToStr( FileCount ) );
end;

{ TBackupPathCopyCountXml }

procedure TBackupPathCopyCountXml.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupPathCopyCountXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_CopyCount, IntToStr( CopyCount ) );
end;

{ TBackupPathOwnerChangeXml }

function TBackupPathOwnerChangeXml.FindBackupOwnerListNode: Boolean;
begin
  Result := FindBackupPathNode;
  if not Result then
    Exit;
  BackupOwnerListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupPathCopyOwnerList );
end;

function TBackupPathWriteXml.FindBackupPathNode: Boolean;
begin
  BackupPathNode := MyXmlUtil.FindListChild( BackupPathHashXml, FullPath );
  Result := BackupPathNode <> nil;
end;

{ TBackupPathOwnerSetXml }

procedure TBackupPathOwnerSetSpaceXml.Update;
begin
  inherited;

    // ����·��������
  if not FindBackupOwnerListNode then
    Exit;

    // ������ �򴴽�����·��ӵ����
  AddBackupOwnerNode;

    // ����
  MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerSpace, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerFileCount, IntToStr( FileCount ) );
end;

{ TBackupFileSetSpaceXml }

procedure TBackupFolderSetSpaceXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TBackupFolderSetSpaceXml.Update;
begin
    //  ������
  if not FindFolderNode then
    Exit;

  MyXmlUtil.AddChild( FolderNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( FolderNode, Xml_FileCount, IntToStr( FileCount ) );
end;

{ TBackupFileAddCompletedSpaceXml }

procedure TBackupFolderAddCompletedSpaceXml.ResetNode(Node: IXMLNode);
var
  OldCompletedSpace, NewCompletedSpace : Int64;
begin
    // ˢ�� Ŀ¼�ڵ�
  if Node.NodeName <> Xml_BackupFolderList then
  begin
    OldCompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_CompletedSpace ), 0 );
    NewCompletedSpace := OldCompletedSpace + CompletedSpace;
    MyXmlUtil.AddChild( Node, Xml_CompletedSpace, IntToStr( NewCompletedSpace ) );
  end;

    // ˢ�� ���ڵ�
  if ( Node.ParentNode <> nil ) and ( Node.NodeName <> Xml_BackupFolder ) then
    ResetNode( Node.ParentNode );
end;

procedure TBackupFolderAddCompletedSpaceXml.Update;
begin
    //  ������
  if not FindFolderNode then
    Exit;

    // �ݹ� ˢ�½ڵ�
  ResetNode( FolderNode );
end;

{ TBackupFileSetCompletedSpaceXml }

procedure TBackupFolderSetCompletedSpaceXml.SetLastCompletedSpace(
  _LastCompletedSpace: Int64);
begin
  LastCompletedSpace := _LastCompletedSpace;
end;

procedure TBackupFolderSetCompletedSpaceXml.Update;
var
  OldCompeltedSpace : Int64;
begin
    //  ������
  if not FindFolderNode then
    Exit;

    // �ѷ����仯
  OldCompeltedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( FolderNode, Xml_CompletedSpace ), 0 );
  if OldCompeltedSpace <> LastCompletedSpace then
    Exit;

  MyXmlUtil.AddChild( FolderNode, Xml_CompletedSpace, IntToStr( CompletedSpace ) );
end;

{ TBackupFolderWriteXml }

constructor TBackupFolderWriteXml.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

function TBackupFolderWriteXml.FindFolderNode: Boolean;
var
  RootFolderName : string;
  ChildNodeList, ChildNode: IXMLNode;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
  Result := False;

    // �Ҳ��� ���ڵ�
  if not FindRootFolderNode then
    Exit;

  RootFolderName := MyXmlUtil.GetChildValue( RootFolderNode, Xml_FileName );

    // ���ڵ� �� Ŀ��ڵ�
  if RootFolderName = FolderPath then
  begin
    FolderNode := RootFolderNode;
    Result := True;
    Exit;
  end;

    // �Ӹ�Ŀ¼����Ѱ��
  ChildNodeList := MyXmlUtil.AddChild( RootFolderNode, Xml_BackupFolderList );
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // Ѱ����Ŀ¼
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

    ChildNode := MyXmlUtil.FindListChild( ChildNodeList, FolderName );
    if ChildNode = nil then // ������Ŀ¼
      Exit;

      // ��һ��
    ChildNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFolderList );
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

  FolderNode := ChildNode;
  Result := True;
end;

function TBackupFolderWriteXml.FindRootFolderNode: Boolean;
var
  i : Integer;
  BackupPathNode : IXMLNode;
  SelectPath : string;
begin
  Result := False;
  for i := 0 to BackupPathHashXml.ChildNodes.Count - 1 do
  begin
    BackupPathNode := BackupPathHashXml.ChildNodes[i];
    SelectPath := MyXmlUtil.GetChildValue( BackupPathNode, Xml_FullPath );
    if MyMatchMask.CheckEqualsOrChild( FolderPath, SelectPath ) then
    begin
      RootFolderNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupFolder );
      Result := True;
      Break;
    end;
  end;
end;

{ TBackupFolderAddXml }

procedure TBackupFolderAddXml.AddFolderNode;
var
  RootFolderName : string;
  ChildNodeList, ChildNode : IXMLNode;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
  RootFolderName := MyXmlUtil.GetChildValue( RootFolderNode, Xml_FileName );

    // ��·��
  if RootFolderName = FolderPath then
  begin
    FolderNode:= RootFolderNode;
    Exit;
  end;

    // �Ӹ�Ŀ¼����Ѱ��
  ChildNodeList := MyXmlUtil.AddChild( RootFolderNode, Xml_BackupFolderList );
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // Ѱ����Ŀ¼
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

    ChildNode := MyXmlUtil.FindListChild( ChildNodeList, FolderName );
    if ChildNode = nil then // ������Ŀ¼
    begin
      ChildNode := MyXmlUtil.AddListChild( ChildNodeList, FolderName );
      MyXmlUtil.AddChild( ChildNode, Xml_FileName, FolderName );
    end;

      // ��һ��
    ChildNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFolderList );
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

  FolderNode := ChildNode;
end;

procedure TBackupFolderAddXml.SetFolderInfo(_FileTime: TDateTime;
  _FileCount: Integer);
begin
  FileTime := _FileTime;
  FileCount := _FileCount;
end;

procedure TBackupFolderAddXml.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupFolderAddXml.Update;
var
  FolderName : string;
begin
  inherited;

    // ������ ��Ŀ¼
  if not FindRootFolderNode then
    Exit;

    // ���
  AddFolderNode;

    // ��ӽڵ���Ϣ
  FolderName := ExtractFileName( FolderPath );
  MyXmlUtil.AddChild( FolderNode, Xml_FileName, FolderName );
  MyXmlUtil.AddChild( FolderNode, Xml_FileSize, IntToStr( FileSize ) );
  MyXmlUtil.AddChild( FolderNode, Xml_LastWriteTime, FloatToStr( FileTime ) );

  MyXmlUtil.AddChild( FolderNode, Xml_FileCount, IntToStr( FileCount ) );
  MyXmlUtil.AddChild( FolderNode, Xml_CompletedSpace, IntToStr( CompletedSize ) );
end;


constructor TBackupFileWriteXml.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TBackupFileWriteXml.FindFileNode: Boolean;
var
  RootFolderName : string;
  ChildNodeList, FileNodeList, ChildNode: IXMLNode;
  FolderPath, FileName : string;
  RemainPath, FolderName : string;
  IsFindNext : Boolean;
begin
  Result := False;

    // �Ҳ��� ���ڵ�
  if not FindRootFolderNode then
    Exit;

    // ��ȡ �ļ���Ϣ
  FolderPath := ExtractFileDir( FilePath );
  FileName := ExtractFileName( FilePath );

    // ��ȡ ���ڵ���Ϣ
  RootFolderName := MyXmlUtil.GetChildValue( RootFolderNode, Xml_FileName );

    // ���ڵ� �� Ŀ��ڵ�
  if ( RootFolderName = FilePath ) or ( RootFolderName = FolderPath ) then
    ChildNode := RootFolderNode
  else
  begin
      // �Ӹ�Ŀ¼����Ѱ��
    ChildNodeList := MyXmlUtil.AddChild( RootFolderNode, Xml_BackupFolderList );
    RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderName ), FolderPath );
    IsFindNext := True;
    while IsFindNext do             // Ѱ����Ŀ¼
    begin
      FolderName := MyString.GetRootFolder( RemainPath );
      if FolderName = '' then
      begin
        FolderName := RemainPath;
        IsFindNext := False;
      end;

      ChildNode := MyXmlUtil.FindListChild( ChildNodeList, FolderName );
      if ChildNode = nil then // ������Ŀ¼
        Exit;

        // ��һ��
      ChildNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFolderList );
      RemainPath := MyString.CutRootFolder( RemainPath );
    end;
  end;

    // ��Ѱ �ļ��ڵ�
  FileNodeList := MyXmlUtil.AddChild( ChildNode, Xml_BackupFileList );
  FileNode := MyXmlUtil.FindListChild( FileNodeList, FileName );
  Result := FileNode <> nil;
end;

function TBackupFileWriteXml.FindRootFolderNode: Boolean;
var
  i : Integer;
  BackupPathNode : IXMLNode;
  SelectPath : string;
begin
  Result := False;
  for i := 0 to BackupPathHashXml.ChildNodes.Count - 1 do
  begin
    BackupPathNode := BackupPathHashXml.ChildNodes[i];
    SelectPath := MyXmlUtil.GetChildValue( BackupPathNode, Xml_FullPath );
    if MyMatchMask.CheckEqualsOrChild( FilePath, SelectPath ) then
    begin
      RootFolderNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupFolder );
      Result := True;
      Break;
    end;
  end;
end;

{ TBackupFolderRemoveXml }

procedure TBackupFolderRemoveXml.Update;
var
  FolderListNode : IXMLNode;
  FolderName : string;
begin
    // ������
  if not FindFolderNode then
    Exit;

    // ��Ŀ¼�б���ɾ��
  FolderListNode := FolderNode.ParentNode;
  FolderName := ExtractFileName( FolderPath );
  MyXmlUtil.DeleteListChild( FolderListNode, FolderName );
end;


{ TBackupFileCopyWriteXml }

function TBackupFileCopyChangeXml.FindCopyListNode: Boolean;
begin
  Result := False;

    // �ļ�������
  if not FindFileNode then
    Exit;

  CopyListNode := MyXmlUtil.AddChild( FileNode, Xml_BackupCopyList );
  Result := True;
end;

{ TBackupFileCopyWriteXml }

procedure TBackupFileCopyWriteXml.AddCopyNode;
begin
  CopyNode := MyXmlUtil.FindListChild( CopyListNode, CopyOwner );
  if CopyNode = nil then
    CopyNode := MyXmlUtil.AddListChild( CopyListNode, CopyOwner );
end;

function TBackupFileCopyWriteXml.FindCopyNode: Boolean;
begin
  Result := False;

  if not FindCopyListNode then
    Exit;

  CopyNode := MyXmlUtil.AddListChild( CopyListNode, CopyOwner );
  Result := CopyNode <> nil;
end;

procedure TBackupFileCopyWriteXml.SetCopyOwner(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

{ TBackupPathOwnerWriteXml }

procedure TBackupPathOwnerWriteXml.AddBackupOwnerNode;
begin
  BackupOwnerNode := MyXmlUtil.FindListChild( BackupOwnerListNode, PcID );
  if BackupOwnerNode = nil then
  begin
    BackupOwnerNode := MyXmlUtil.AddListChild( BackupOwnerListNode, PcID );
    MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerPcID, PcID );
    MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerSpace, IntToStr(0) );
    MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerFileCount, IntToStr(0) );
  end;
end;

function TBackupPathOwnerWriteXml.FindBackupOwnerNode: Boolean;
begin
  Result := False;
  if not FindBackupOwnerListNode then
    Exit;

  BackupOwnerNode := MyXmlUtil.FindListChild( BackupOwnerListNode, PcID );
  Result := BackupOwnerNode <> nil;
end;

procedure TBackupPathOwnerWriteXml.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TBackupPathOwnerChangeSpaceXml }

procedure TBackupPathOwnerChangeSpaceXml.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TBackupPathOwnerAddSpaceXml }

procedure TBackupPathOwnerAddSpaceXml.Update;
var
  OldFileSize, NewFileSize : Int64;
  OldFileCount, NewFileCount : Integer;
begin
  inherited;

    // ����·��������
  if not FindBackupOwnerListNode then
    Exit;

    // ������ �򴴽�����·��ӵ����
  AddBackupOwnerNode;

  OldFileSize := StrToInt64Def( MyXmlUtil.GetChildValue( BackupOwnerNode, Xml_OwnerSpace ), 0 );
  OldFileCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupOwnerNode, Xml_OwnerFileCount ), 0 );

  NewFileSize := OldFileSize + FileSize;
  NewFileCount := OldFileCount + FileCount;

    // ����
  MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerSpace, IntToStr( NewFileSize ) );
  MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerFileCount, IntToStr( NewFileCount ) );
end;

{ TBackupPathOwnerRemoveSpaceXml }

procedure TBackupPathOwnerRemoveSpaceXml.Update;
var
  OldFileSize, NewFileSize : Int64;
  OldFileCount, NewFileCount : Integer;
begin
  inherited;

    // ����·��ӵ���� ������
  if not FindBackupOwnerNode then
    Exit;

  OldFileSize := StrToInt64Def( MyXmlUtil.GetChildValue( BackupOwnerNode, Xml_OwnerSpace ), 0 );
  OldFileCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupOwnerNode, Xml_OwnerFileCount ), 0 );

  NewFileSize := OldFileSize - FileSize;
  NewFileCount := OldFileCount - FileCount;

    // ������ ��ȫɾ
  if ( NewFileSize <= 0 ) and ( NewFileCount <= 0 ) then
    MyXmlUtil.DeleteListChild( BackupOwnerListNode, PcID )
  else
  begin
      // ����
    MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerSpace, IntToStr( NewFileSize ) );
    MyXmlUtil.AddChild( BackupOwnerNode, Xml_OwnerFileCount, IntToStr( NewFileCount ) );
  end;
end;


{ TBackupPathOwnerClearXml }

procedure TBackupPathOwnerClearXml.Update;
begin
  inherited;

    // ·�� ������
  if not FindBackupOwnerListNode then
    Exit;

    // ���
  BackupOwnerListNode.ChildNodes.Clear;
end;

{ TBackupFileXmlReadHandle }

procedure TBackupFileXmlReadHandle.SetParentPath(_ParentPath: string);
begin
  ParentPath := _ParentPath;
end;

constructor TBackupFileXmlReadHandle.Create(_FileNode: IXMLNode);
begin
  FileNode := _FileNode;
end;

procedure TBackupFileXmlReadHandle.ReadFileCopy;
var
  CopyListNode : IXMLNode;
  i : Integer;
  CopyNode : IXMLNode;
  BackupFileCopyXmlReadHandle : TBackupFileCopyXmlReadHandle;
begin
  CopyListNode := MyXmlUtil.AddChild( FileNode, Xml_BackupCopyList );
  for i := 0 to CopyListNode.ChildNodes.Count - 1 do
  begin
    CopyNode := CopyListNode.ChildNodes[i];
    BackupFileCopyXmlReadHandle := TBackupFileCopyXmlReadHandle.Create( CopyNode );
    BackupFileCopyXmlReadHandle.SetFilePath( FilePath );
    BackupFileCopyXmlReadHandle.SetFileInfo( FileSize, LastWriteTime );
    BackupFileCopyXmlReadHandle.Update;
    BackupFileCopyXmlReadHandle.Free;
  end;
end;

procedure TBackupFileXmlReadHandle.Update;
var
  FileName : string;
  BackupFileReadHandle : TBackupFileReadHandle;
begin
  FileName := MyXmlUtil.GetChildValue( FileNode, Xml_FileName );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( FileNode, Xml_FileSize ), 0 );
  LastWriteTime := StrToFloatDef( MyXmlUtil.GetChildValue( FileNode, Xml_LastWriteTime ), 0 );

  FilePath := MyFilePath.getPath( ParentPath ) + FileName;

    // ���� �ļ���ȡ����Ϣ
  BackupFileReadHandle := TBackupFileReadHandle.Create( FilePath );
  BackupFileReadHandle.SetFileInfo( FileSize, LastWriteTime );
  BackupFileReadHandle.Update;
  BackupFileReadHandle.Free;

    // ��ȡ ���ݸ��� ��Ϣ
  ReadFileCopy;
end;

{ TBackupPathXmlReadHandle }

procedure TBackupPathXmlReadHandle.AddRootPathLoading;
var
  BackupPathSetStatusHandle : TBackupPathSetStatusHandle;
begin
  BackupPathSetStatusHandle := TBackupPathSetStatusHandle.Create( FullPath );
  BackupPathSetStatusHandle.SetStatus( FolderStatus_Loading );
  BackupPathSetStatusHandle.Update;
  BackupPathSetStatusHandle.Free;
end;

constructor TBackupPathXmlReadHandle.Create(_BackupPathNode: IXMLNode);
begin
  BackupPathNode := _BackupPathNode;
end;

procedure TBackupPathXmlReadHandle.ResetPathCopyCount;
var
  BackupPathCopyCountXml : TBackupPathCopyCountXml;
begin
  BackupPathCopyCountXml := TBackupPathCopyCountXml.Create( FullPath );
  BackupPathCopyCountXml.SetCopyCount( DefaultXml_CopyCount );
  MyBackupXmlWrite.AddChange( BackupPathCopyCountXml );
end;

procedure TBackupPathXmlReadHandle.ReadBackupPathFilder;
var
  FilterListNode : IXMLNode;
  i : Integer;
  FilterNode : IXMLNode;
  BackupPathFilterXmlReadHandle : TBackupPathFilterXmlReadHandle;
begin
  FilterListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_IncludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    BackupPathFilterXmlReadHandle := TBackupPathIncludeFilterXmlReadHandle.Create( FilterNode );
    BackupPathFilterXmlReadHandle.SetFullPath( FullPath );
    BackupPathFilterXmlReadHandle.Update;
    BackupPathFilterXmlReadHandle.Free;
  end;

  FilterListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_ExcludeFilterList );
  for i := 0 to FilterListNode.ChildNodes.Count - 1 do
  begin
    FilterNode := FilterListNode.ChildNodes[i];
    BackupPathFilterXmlReadHandle := TBackupPathExcludeFilterXmlReadHandle.Create( FilterNode );
    BackupPathFilterXmlReadHandle.SetFullPath( FullPath );
    BackupPathFilterXmlReadHandle.Update;
    BackupPathFilterXmlReadHandle.Free;
  end;
end;


procedure TBackupPathXmlReadHandle.ReadBackupPathOwner;
var
  BackupPathOwnerListNode : IXMLNode;
  i : Integer;
  BackupPathOwnerNode : IXMLNode;
  BackupPathOwnerXmlReadHandle : TBackupPathOwnerXmlReadHandle;
begin
  BackupPathOwnerListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupPathCopyOwnerList );
  for i := 0 to BackupPathOwnerListNode.ChildNodes.Count - 1 do
  begin
    BackupPathOwnerNode := BackupPathOwnerListNode.ChildNodes[i];

    BackupPathOwnerXmlReadHandle := TBackupPathOwnerXmlReadHandle.Create( BackupPathOwnerNode );
    BackupPathOwnerXmlReadHandle.SetFullPath( FullPath );
    BackupPathOwnerXmlReadHandle.Update;
    BackupPathOwnerXmlReadHandle.Free;
  end;
end;

procedure TBackupPathXmlReadHandle.Update;
var
  PathType : string;
  IsDisable, IsBackupNow : Boolean;
  CopyCount : Integer;
  IsAutoSync : Boolean;
  SyncTimeType, SyncTimeValue : Integer;
  LastSyncTime : TDateTime;
  IsEncrypt : Boolean;
  Password, PasswordHint, DecryptedPassword : string;
  FolderSpace, CompletedSpace : Int64;
  FileCount : Integer;
  BackupPathReadHandle : TBackupPathReadHandle;
begin
    // ������Ϣ
  FullPath := MyXmlUtil.GetChildValue( BackupPathNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PathType );
  if PathType = 'Driver' then
    PathType := PathType_Folder;
  IsDisable := StrToBoolDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_IsDisable ), False );
  IsBackupNow := StrToBoolDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_IsBackupNow ), True );
  CopyCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_CopyCount ), -1 );
  if CopyCount = -1 then
  begin
    ResetPathCopyCount;
    CopyCount := DefaultXml_CopyCount;
  end;

    // �Զ�ͬ����Ϣ
  IsAutoSync := StrToBoolDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_IsAutoSync ), True );
  SyncTimeType := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_SyncTimeType ), TimeType_Hourse );
  SyncTimeValue := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_SyncTimeValue ), 1 );
  LastSyncTime := StrToFloatDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_LastSyncTime ), 0 );

    // ������Ϣ
  IsEncrypt := StrToBoolDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_IsEncrypt ), False );
  Password := MyXmlUtil.GetChildValue( BackupPathNode, Xml_Password );
  PasswordHint := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PasswordHint );
  DecryptedPassword := MyEncrypt.DecodeStr( Password );

    // �ռ���Ϣ
  FolderSpace := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathNode, Xml_FolderSpace ), 0 );
  CompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathNode, Xml_CompletedSpace ), 0 );
  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathNode, Xml_PathFileCount ), 0 );

    // ���� ��ȡ�ı���·��
  BackupPathReadHandle := TBackupPathReadHandle.Create( FullPath );
  BackupPathReadHandle.SetPathInfo( PathType );
  BackupPathReadHandle.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathReadHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathReadHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathReadHandle.SetEncryptInfo( IsEncrypt, DecryptedPassword, PasswordHint );
  BackupPathReadHandle.SetCountInfo( CopyCount, FileCount );
  BackupPathReadHandle.SetSpaceInfo( FolderSpace, CompletedSpace );
  BackupPathReadHandle.Update;
  BackupPathReadHandle.Free;

    // ��ȡ BackupPath Owner
  ReadBackupPathOwner;

    // ��ȡ BackupPath Filter
  ReadBackupPathFilder;

    // ��ʾ·�� ���� Loading
  AddRootPathLoading;
end;

{ TBackupFileCopyXmlReadHandle }

constructor TBackupFileCopyXmlReadHandle.Create(_CopyNode: IXMLNode);
begin
  CopyNode := _CopyNode;
end;

procedure TBackupFileCopyXmlReadHandle.ReadLoadedCopy;
var
  BackupCopyReadLoadedHandle : TBackupCopyReadLoadedHandle;
begin
    // ��� CopyOwner
  BackupCopyReadLoadedHandle := TBackupCopyReadLoadedHandle.Create( FilePath );
  BackupCopyReadLoadedHandle.SetCopyOwner( CopyOwner );
  BackupCopyReadLoadedHandle.Update;
  BackupCopyReadLoadedHandle.Free;
end;

procedure TBackupFileCopyXmlReadHandle.ReadOfflineCopy;
var
  Position : Int64;
  TransferBackupJobAddHandle : TTransferBackupJobAddHandle;
  BackupCopyReadOfflineHandle : TBackupCopyReadOfflineHandle;
begin
    // ��� Copy Owner
  BackupCopyReadOfflineHandle := TBackupCopyReadOfflineHandle.Create( FilePath );
  BackupCopyReadOfflineHandle.SetCopyOwner( CopyOwner );
  BackupCopyReadOfflineHandle.Update;
  BackupCopyReadOfflineHandle.Free;

    // ��ӵ� Job
  Position := StrToInt64Def( MyXmlUtil.GetChildValue( CopyNode, Xml_Position ), 0 );
  TransferBackupJobAddHandle := TTransferBackupJobAddHandle.Create( FilePath, CopyOwner );
  TransferBackupJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferBackupJobAddHandle.Update;
  TransferBackupJobAddHandle.Free;
end;

procedure TBackupFileCopyXmlReadHandle.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupFileCopyXmlReadHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupFileCopyXmlReadHandle.Update;
var
  CopyStatus : string;
begin
  CopyOwner := MyXmlUtil.GetChildValue( CopyNode, Xml_CopyOwner );
  CopyStatus := MyXmlUtil.GetChildValue( CopyNode, Xml_CopyStatus );

    // ���� ������� ����
  if CopyStatus = CopyStatus_Offline then
    ReadOfflineCopy
  else
  if CopyStatus = CopyStatus_Loaded then
    ReadLoadedCopy;
end;

{ TBackupFileCopyAddXml }

procedure TBackupFileCopyAddXml.SetCopyStatus(_CopyStatus: string);
begin
  CopyStatus := _CopyStatus;
end;

procedure TBackupFileCopyAddXml.Update;
begin
  inherited;

    // �ļ�������
  if not FindCopyListNode then
    Exit;

    // �����ڣ��򴴽�
  AddCopyNode;

    // ��� �µ�
  MyXmlUtil.AddChild( CopyNode, Xml_CopyOwner, CopyOwner );
  MyXmlUtil.AddChild( CopyNode, Xml_CopyStatus, CopyStatus );
end;

{ TBackupFileCopyAddOfflineXml }

procedure TBackupFileCopyAddOfflineXml.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TBackupFileCopyAddOfflineXml.Update;
begin
  inherited;

  MyXmlUtil.AddChild( CopyNode, Xml_Position, IntToStr( Position ) );
end;

{ TBackupFileCopyRemoveXml }

procedure TBackupFileCopyRemoveXml.Update;
begin
  inherited;

    // ����������
  if not FindCopyNode then
    Exit;

    // ɾ��
  MyXmlUtil.DeleteListChild( CopyListNode, CopyOwner );
end;

{ TBackuppathRootFolderRead }

procedure TBackupPathRootFolderXmlReadHandle.AddBackupBoard;
var
  BackupItemStatusAddInfo : TBackupItemStatusAddInfo;
begin
  BackupItemStatusAddInfo := TBackupItemStatusAddInfo.Create( BackupItemStatusType_Loading );
  BackupItemStatusAddInfo.SetFullPath( FullPath );
  MyBackupBoardInfo.AddChange( BackupItemStatusAddInfo );
end;

constructor TBackupPathRootFolderXmlReadHandle.Create(_BackupPathNode: IXMLNode);
begin
  BackupPathNode := _BackupPathNode;
end;

procedure TBackupPathRootFolderXmlReadHandle.ReadRootFile;
var
  ParentPath : string;
  BackupFileXmlReadHandle : TBackupFileXmlReadHandle;
  i : Integer;
  FileListNode, FileNode : IXMLNode;
begin
  ParentPath := ExtractFileDir( FullPath );

    // �ݹ鴦���ļ���·��
  FileListNode := MyXmlUtil.AddChild( RootNode, Xml_BackupFileList );
  for i := 0 to FileListNode.ChildNodes.Count - 1 do
  begin
      // ��ȡ��ȡ����Ϣ
    FileNode := FileListNode.ChildNodes[i];

    BackupFileXmlReadHandle := TBackupFileXmlReadHandle.Create( FileNode );
    BackupFileXmlReadHandle.SetParentPath( ParentPath );
    BackupFileXmlReadHandle.Update;
    BackupFileXmlReadHandle.Free;
  end;
end;

procedure TBackupPathRootFolderXmlReadHandle.ReadRootFolder;
var
  BackupFolderXmlReadHandle : TBackupFolderXmlReadHandle;
begin
  BackupFolderXmlReadHandle := TBackupFolderXmlReadHandle.Create( RootNode );
  BackupFolderXmlReadHandle.SetParentPath( '' );
  BackupFolderXmlReadHandle.SetReadCount( 0 );
  BackupFolderXmlReadHandle.SetReadFileCount( 0 );
  BackupFolderXmlReadHandle.Update;
  BackupFolderXmlReadHandle.Free;
end;

procedure TBackupPathRootFolderXmlReadHandle.RemoveBackupBoard;
var
  BackupItemStatusRemoveInfo : TBackupItemStatusRemoveInfo;
begin
  BackupItemStatusRemoveInfo := TBackupItemStatusRemoveInfo.Create( BackupItemStatusType_Loading );
  MyBackupBoardInfo.AddChange( BackupItemStatusRemoveInfo );
end;

procedure TBackupPathRootFolderXmlReadHandle.RemoveRootPathLoading;
var
  BackupPathSetStatusHandle : TBackupPathSetStatusHandle;
begin
  BackupPathSetStatusHandle := TBackupPathSetStatusHandle.Create( FullPath );
  BackupPathSetStatusHandle.SetStatus( FolderStatus_Stop );
  BackupPathSetStatusHandle.Update;
  BackupPathSetStatusHandle.Free;
end;

procedure TBackupPathRootFolderXmlReadHandle.RootNodeEdition;
var
  BackupPathSetRootNodeXml : TBackupPathSetRootNodeXml;
begin
  if MyXmlUtil.GetChildValue( RootNode, Xml_FileName ) = FullPath then
    Exit;

    // ���� ���ڵ�
  MyXmlUtil.AddChild( RootNode, Xml_FileName, FullPath );

    // ���� ���ڵ�
  BackupPathSetRootNodeXml := TBackupPathSetRootNodeXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathSetRootNodeXml );
end;

procedure TBackupPathRootFolderXmlReadHandle.Update;
var
  i : Integer;
  PathType : string;
begin
  FullPath := MyXmlUtil.GetChildValue( BackupPathNode, Xml_FullPath );
  PathType := MyXmlUtil.GetChildValue( BackupPathNode, Xml_PathType );
  RootNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupFolder );

    // �汾����
  RootNodeEdition;

    // �������ʾ
  AddBackupBoard;

    // �����Ŀ¼ Xml
  if PathType = PathType_File then
    ReadRootFile
  else
    ReadRootFolder;

    // �Ƴ� �������ʾ
  RemoveBackupBoard;

    // ɾ�� ������ Loading
  RemoveRootPathLoading;
end;

{ TBackupPathSetRootNodeXml }

procedure TBackupPathSetRootNodeXml.Update;
var
  BackupFolderNode : IXMLNode;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

    // ��Ŀ¼�ڵ�
  BackupFolderNode := MyXmlUtil.AddChild( BackupPathNode, Xml_BackupFolder );
  MyXmlUtil.AddChild( BackupFolderNode, Xml_FileName, FullPath );
end;

{ TBackupPathCompletedSpaceChangeXml }

procedure TBackupPathCompletedSpaceChangeXml.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupPathSetCompletedSpaceXml }

procedure TBackupPathSetCompletedSpaceXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_CompletedSpace, IntToStr( CompletedSpace ) );
end;

{ TBackupPathRemoveCompletedSpaceXml }

procedure TBackupPathRemoveCompletedSpaceXml.Update;
var
  OldCompletedSpace, NewCompletedSpace : Int64;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  OldCompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathNode, Xml_CompletedSpace ), 0 );
  NewCompletedSpace := OldCompletedSpace - CompletedSpace;

  MyXmlUtil.AddChild( BackupPathNode, Xml_CompletedSpace, IntToStr( NewCompletedSpace ) );
end;

{ TBackupPathAddCompletedSpaceXml }

procedure TBackupPathAddCompletedSpaceXml.Update;
var
  OldCompletedSpace, NewCompletedSpace : Int64;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  OldCompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathNode, Xml_CompletedSpace ), 0 );
  NewCompletedSpace := OldCompletedSpace + CompletedSpace;

  MyXmlUtil.AddChild( BackupPathNode, Xml_CompletedSpace, IntToStr( NewCompletedSpace ) );
end;

{ TBackupFolderCompletedSpaceChangeXml }

procedure TBackupFolderCompletedSpaceChangeXml.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupFolderRemoveCompletedSpaceXml }

procedure TBackupFolderRemoveCompletedSpaceXml.ResetNode(Node: IXMLNode);
var
  OldCompletedSpace, NewCompletedSpace : Int64;
begin
    // ˢ�� Ŀ¼�ڵ�
  if Node.NodeName = Xml_BackupFolder then
  begin
    OldCompletedSpace := StrToInt64Def( MyXmlUtil.GetChildValue( Node, Xml_CompletedSpace ), 0 );
    NewCompletedSpace := OldCompletedSpace - CompletedSpace;
    MyXmlUtil.AddChild( Node, Xml_CompletedSpace, IntToStr( NewCompletedSpace ) );
  end;

    // ˢ�� ���ڵ�
  if Node.ParentNode <> nil then
    ResetNode( Node.ParentNode );
end;

procedure TBackupFolderRemoveCompletedSpaceXml.Update;
begin
    //  ������
  if not FindFolderNode then
    Exit;

    // �ݹ� ˢ�½ڵ�
  ResetNode( FolderNode );
end;

{ TBackupPathOwnerXmlReadHandle }

constructor TBackupPathOwnerXmlReadHandle.Create(
  _BackupPathOwnerNode: IXMLNode);
begin
  BackupPathOwnerNode := _BackupPathOwnerNode;
end;

procedure TBackupPathOwnerXmlReadHandle.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupPathOwnerXmlReadHandle.Update;
var
  CopyOwner : string;
  FileSize : Int64;
  FileCount : Integer;
  BackupPathOwnerReadSpaceHandle : TBackupPathOwnerReadSpaceHandle;
begin
  CopyOwner := MyXmlUtil.GetChildValue( BackupPathOwnerNode, Xml_OwnerPcID );
  FileSize := StrToInt64Def( MyXmlUtil.GetChildValue( BackupPathOwnerNode, Xml_OwnerSpace ), 0 );
  FileCount := StrToIntDef( MyXmlUtil.GetChildValue( BackupPathOwnerNode, Xml_OwnerFileCount ), 0 );

  BackupPathOwnerReadSpaceHandle := TBackupPathOwnerReadSpaceHandle.Create( FullPath );
  BackupPathOwnerReadSpaceHandle.SetPcID( CopyOwner );
  BackupPathOwnerReadSpaceHandle.SetSpaceInfo( FileSize, FileCount );
  BackupPathOwnerReadSpaceHandle.Update;
  BackupPathOwnerReadSpaceHandle.Free;
end;

{ TBackupPathFilterXmlReadHandle }

constructor TBackupPathFilterXmlReadHandle.Create(
  _BackupPathFilterNode: IXMLNode);
begin
  BackupPathFilterNode := _BackupPathFilterNode;
end;

procedure TBackupPathFilterXmlReadHandle.SetFullPath(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupPathFilterXmlReadHandle.Update;
begin
    // ��ȡ ������Ϣ
  FilterType := MyXmlUtil.GetChildValue( BackupPathFilterNode, Xml_FilterType );
  FilterStr := MyXmlUtil.GetChildValue( BackupPathFilterNode, Xml_FilterStr );

    // ��� ������
  AddFilterHandle;
end;

{ TBackupPathExcludeFilterXmlReadHandle }

procedure TBackupPathExcludeFilterXmlReadHandle.AddFilterHandle;
var
  BackupPathExcludeFilterReadHandle : TBackupPathExcludeFilterReadHandle;
begin
  BackupPathExcludeFilterReadHandle := TBackupPathExcludeFilterReadHandle.Create( FullPath );
  BackupPathExcludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  BackupPathExcludeFilterReadHandle.Update;
  BackupPathExcludeFilterReadHandle.Free;
end;

{ TBackupPathIncludeFilterXmlReadHandle }

procedure TBackupPathIncludeFilterXmlReadHandle.AddFilterHandle;
var
  BackupPathIncludeFilterReadHandle : TBackupPathIncludeFilterReadHandle;
begin
  BackupPathIncludeFilterReadHandle := TBackupPathIncludeFilterReadHandle.Create( FullPath );
  BackupPathIncludeFilterReadHandle.SetFilterInfo( FilterType, FilterStr );
  BackupPathIncludeFilterReadHandle.Update;
  BackupPathIncludeFilterReadHandle.Free;
end;

{ TBackupPathIncludeFilterChangeXml }

function TBackupPathIncludeFilterChangeXml.FindIncludeFilterListNode: Boolean;
begin
  Result := False;
  if not FindBackupPathNode then
    Exit;

  IncludeFilterListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_IncludeFilterList );
  Result := True;
end;

{ TBackupPathIncludeFilterClearXml }

procedure TBackupPathIncludeFilterClearXml.Update;
begin
  inherited;

    // ������
  if not FindIncludeFilterListNode then
    Exit;

    // ���
  IncludeFilterListNode.ChildNodes.Clear;
end;

{ TBackupPathIncludeFilterAddXml }

procedure TBackupPathIncludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TBackupPathIncludeFilterAddXml.Update;
var
  IncludeFilterNode : IXMLNode;
begin
  inherited;

    // ������
  if not FindIncludeFilterListNode then
    Exit;

  IncludeFilterNode := MyXmlUtil.AddListChild( IncludeFilterListNode );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( IncludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TBackupPathExcludeFilterChangeXml }

function TBackupPathExcludeFilterChangeXml.FindExcludeFilterListNode: Boolean;
begin
  Result := False;
  if not FindBackupPathNode then
    Exit;

  ExcludeFilterListNode := MyXmlUtil.AddChild( BackupPathNode, Xml_ExcludeFilterList );
  Result := True;
end;

{ TBackupPathExcludeFilterClearXml }

procedure TBackupPathExcludeFilterClearXml.Update;
begin
  inherited;

    // ������
  if not FindExcludeFilterListNode then
    Exit;

    // ���
  ExcludeFilterListNode.ChildNodes.Clear;
end;


{ TBackupPathExcludeFilterAddXml }

procedure TBackupPathExcludeFilterAddXml.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TBackupPathExcludeFilterAddXml.Update;
var
  ExcludeFilterNode : IXMLNode;
begin
  inherited;

    // ������
  if not FindExcludeFilterListNode then
    Exit;

  ExcludeFilterNode := MyXmlUtil.AddListChild( ExcludeFilterListNode );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterType, FilterType );
  MyXmlUtil.AddChild( ExcludeFilterNode, Xml_FilterStr, FilterStr );
end;

{ TBackupPathSetLastSyncTimeXml }

procedure TBackupPathSetLastSyncTimeXml.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathSetLastSyncTimeXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_LastSyncTime, FloatToStr( LastSyncTime ) );
end;

{ TBackupPathSetSyncMinsXml }

procedure TBackupPathSetSyncMinsXml.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupPathSetSyncMinsXml.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathSetSyncMinsXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_IsAutoSync, BoolToStr( IsAutoSync ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_SyncTimeType, IntToStr( SyncTimeType ) );
  MyXmlUtil.AddChild( BackupPathNode, Xml_SyncTimeValue, IntToStr( SyncTimeValue ) );
end;

{ TBackupPathIsDisableXml }

procedure TBackupPathIsDisableXml.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupPathIsDisableXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_IsDisable, BoolToStr( IsDisable ) );
end;

{ TBackupPathIsBackupNowXml }

procedure TBackupPathIsBackupNowXml.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathIsBackupNowXml.Update;
begin
    // ������
  if not FindBackupPathNode then
    Exit;

  MyXmlUtil.AddChild( BackupPathNode, Xml_IsBackupNow, BoolToStr( IsBackupNow ) );
end;
end.
