unit UMyBackupInfo;

interface

uses SyncObjs, Generics.Collections, UFileBaseInfo, UMyUtil, SysUtils, Classes, UChangeInfo,
     UModelUtil, Math, UBackupInfoFace, DateUtils;

type

/////////// ���ݽṹ  //////////

{$Region ' ������Ϣ '}

  TCopyInfo = class
  public
    CopyOwner : string;  // ������ӵ����
    CopyStatus : string;  // ������״̬
  public
    constructor Create( _CopyOwner, _CopyStatus : string );overload;
    constructor Create( _CopyOwner : string );overload;
  end;
  TCopyInfoPair = TPair< string , TCopyInfo >;
  TCopyInfoHash = class(TStringDictionary< TCopyInfo >);

{$EndRegion}

{$Region ' ����Ŀ¼/�ļ���Ϣ '}

  TBackupFolderInfo = class;

  TBackupFileBaseInfo = class( TFileBaseInfo )
  public
    PaerntFolder : TBackupFolderInfo; // ��Ŀ¼
  public
    constructor Create;
  end;

    // �����ļ���Ϣ
  TBackupFileInfo = class( TBackupFileBaseInfo )
  public
    CopyInfoHash : TCopyInfoHash;  // ÿһ����������Ϣ
  public
    constructor Create;
    destructor Destroy; override;
  end;
  TBackupFileInfoPair = TPair< string , TBackupFileInfo >;
  TBackupFileInfoHash = class(TStringDictionary< TBackupFileInfo >);
  TBackupFolderInfoHash = class;

    // ����Ŀ¼��Ϣ
  TBackupFolderInfo = class( TBackupFileBaseInfo )
  public
    FileCount : Integer;
    CompletedSpace : Int64;
  public
    BackupFileHash : TBackupFileInfoHash;    // �ļ��б�
    BackupFolderHash : TBackupFolderInfoHash;  // Ŀ¼�б�
  public
    constructor Create;
    procedure SetFolderInfo( _FileCount : Integer; _CompletedSpace : Int64 );
    destructor Destroy; override;
  end;
  TBackupFolderInfoPair = TPair< string, TBackupFolderInfo >;
  TBackupFolderInfoHash = class(TStringDictionary< TBackupFolderInfo >);

    // �����ļ� ��Ŀ¼
  TRootBackupFileInfo = class( TBackupFolderInfo )
  end;

{$EndRegion}

{$Region ' ����·����Ϣ '}

    // ����·������ ӵ����
  TBackupPathCopyOwner = class
  public
    PcID : string;
    OwnerSpace : Int64;
    OwnerFileCount : Integer;
  public
    constructor Create( _PcID : string );
  end;
  TBackupPathCopyOwnerPair = TPair< string , TBackupPathCopyOwner >;
  TBackupPathCopyOwnerHash = class(TStringDictionary< TBackupPathCopyOwner >);

    // �����ļ�������
  TBackupFileFilterInfo = class( TFileFilterInfo )
  end;
  TBackupFileFilterList = class( TObjectList< TBackupFileFilterInfo > )end;

    // ����·����Ϣ
  TBackupPathInfo = class
  public
    FullPath, PathType : string; // ·�����ͣ�����·��
    IsDisable, IsBackupNow : Boolean; // �Ƿ��ֹ����,  �Ƿ񱸷���Ŀ¼ �� �Ƿ���� BackupNow
    CopyCount : Integer;  // ���ݸ�����
  public
    IsAutoSync : Boolean; // �Ƿ��Զ�ͬ��
    SyncTimeType, SyncTimeValue : Integer; // ͬ�����
    LasSyncTime : TDateTime;  // ��һ��ͬ��ʱ��
  public
    IsEncrypt : Boolean;  // ��������
    Password, PasswordHint : string;
  public
    FileCount : Integer; // ��Ҫ���ݵ��ļ���
    FolderSpace, CompletedSpace : Int64;  // �ռ���Ϣ
  public
    IncludeFilterList : TBackupFileFilterList;  // �����ļ� ������
    ExcludeFilterList : TBackupFileFilterList;  // �ų��ļ� ������
  public
    BackupFolderInfo : TBackupFolderInfo;  // ����Ŀ¼���ļ���Ϣ
  public
    IsNotEnoughPc : Boolean; // �Ƿ����㹻�� Pc ����
    BackupPathCopyOwnerHash : TBackupPathCopyOwnerHash; // ����·��ӵ����
  public
    constructor Create( _FullPath, _PathType : string );
    procedure SetBackupInfo( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncIntervalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FolderSpace, _CompletedSpace : Int64 );
    destructor Destroy; override;
  end;
  TBackupPathList = class( TObjectList<TBackupPathInfo> )
  public
    function getPath( FullPath : string ): TBackupPathInfo;
    procedure RemovePath( FullPath : string );
  private
    function getPathIndex( FullPath : string ): Integer;
  end;

{$EndRegion}

{$Region ' ������ '}

  TMyBackupInfoReadBase = class
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {$Region ' ����·�� ' }

    // ��ȡ��Ϣ ����
  TMyBackupPathInfoReadBase = class( TMyBackupInfoReadBase )
  public
    BackupPathList : TBackupPathList;
  public
    constructor Create;
  end;

    // ��ȡ ����·��ռ�õ� �ƿռ�
  TMyBackupInfoReadCompletedSpace = class( TMyBackupPathInfoReadBase )
  public
    function get : Int64;
  end;

      // ��ȡ ������ Pc �ռ�
  TMyBackupInfoReadComsumpPcSpace = class( TMyBackupPathInfoReadBase )
  private
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
    function get : Int64;
  end;

      // ��ȡ ���еı���·��
  TMyBackupInfoReadAllBackupPathList = class( TMyBackupPathInfoReadBase )
  public
    function get : TStringList;
  end;

    // ��ȡ ·����Ϣ
  TMyBackupInfoPathRead = class( TMyBackupPathInfoReadBase )
  public
    FilePath : string;
  protected
    BackupPathInfo : TBackupPathInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupPathInfo : Boolean;
  end;

    // ��ȡ����
  TMyBackupInfoReadPassword = class( TMyBackupInfoPathRead )
  public
    function get : string;
  end;

    // ��ȡ Ԥ�� Copy ��
  TMyBackupInfoReadPresetCopyCount = class( TMyBackupInfoPathRead )
  public
    function get : Integer;
  end;

    // ��ȡ �����ļ��Ƿ��������
  TMyBackupInfoReadIsEnable = class( TMyBackupInfoPathRead )
  public
    function get : Boolean;
  end;

    // ��ȡ �Ƿ� ��·��
  TMyBackupInfoReadIsRootPath = class( TMyBackupInfoPathRead )
  public
    function get : Boolean;
  end;

    // ��ȡ ��·��
  TMyBackupInfoReadRootPath = class( TMyBackupInfoPathRead )
  public
    function get : string;
  end;

    // ��ȡ ����·�� ������Ϣ
  TMyBackupInfoReadConfig = class( TMyBackupInfoPathRead )
  public
    function get : TBackupConfigInfo;
  private
    function getFilterList( BackupFilterList : TBackupFileFilterList ) : TFileFilterList;
  end;

    // ��ȡ �Ƿ� �����Զ�����ʱ��
  TMyBackupInfoReadIsAutoSyncTimeOut = class( TMyBackupInfoPathRead )
  public
    function get : Boolean;
  end;

    // ��ȡ ����������
  TMyBackupInfoReadIncludeFilter = class( TMyBackupInfoPathRead )
  public
    function get : TFileFilterList;
  end;

    // ��ȡ �ų�������
  TMyBackupInfoReadExcludeFilter = class( TMyBackupInfoPathRead )
  public
    function get : TFileFilterList;
  end;

    // ������
  MyBackupPathInfoUtil = class
  public
    class function ReadComsumpCloudSpace : Int64;
    class function ReadComsumpPcSpace( PcID : string ): Int64;
    class function ReadPassword( FilePath : string ) : string;
    class function ReadPresetCopyCount( FilePath : string ): Integer;
  public
    class function ReadIsEnable( FilePath : string ): Boolean;
    class function ReadIsRootPath( FilePath : string ): Boolean;
    class function ReadRootPath( FilePath : string ): string;
  public
    class function ReadBackupPathList : TStringList;
    class function ReadBackupConfigInfo( FullPath : string ): TBackupConfigInfo;
    class function ReadIsAutoSyncTimeOut( FullPath : string ): Boolean;
  public
    class function ReadIncludeFilter( FullPath : string ): TFileFilterList;
    class function ReadExcludeFilter( FullPath : string ): TFileFilterList;
  private              // �ڲ�ʹ��
    class function ReadBackupPathInfo( FilePath : string ): TBackupPathInfo;
  end;

  {$EndRegion}

  {$Region ' ����Ŀ¼ ' }

  TMyBackupFolderReadInfo = class( TMyBackupInfoReadBase )
  public
    FolderPath : string;
  protected
    BackupFolderInfo : TBackupFolderInfo;
  public
    procedure SetFolderPath( _FolderPath : string );
  protected
    function FindBackupFolderInfo : Boolean;
  end;

    // ��ȡ ����� �ռ���Ϣ
  TMyBackupFolderReadCompletedSpace = class( TMyBackupFolderReadInfo )
  public
    function get : Int64;
  end;

    // ��ȡ Ŀ¼������Ϣ
  TFindTempBackFolderBaseInfo = class( TMyBackupFolderReadInfo )
  private
    TempFolderInfo : TTempFolderInfo;
  public
    function get : TTempFolderInfo;
  private
    procedure FindFiles;
    procedure FindFolders;
  end;

    // ��ȡ ����Ŀ¼��Ϣ
  TFindTempBackupFolderInfo = class( TMyBackupFolderReadInfo )
  private
    TempBackupFolderInfo : TTempBackupFolderInfo;
  public
    function get : TTempBackupFolderInfo;
  private
    procedure FindFiles;
    procedure FindFolders;
  end;

  MyBackupFolderInfoUtil = class
  public
    class function ReadCompletedSpace( FolderPath : string ): Int64;
  public             // ��ȡ ������Ϣ
    class function ReadTempBackupFolderBaseInfo( FolderPath : string ): TTempFolderInfo;
    class function ReadTempBackupFolderInfo( FolderPath : string ): TTempBackupFolderInfo;
  private              // �ڲ�ʹ��
    class function ReadBackupFolderInfo( FolderPath : string ): TBackupFolderInfo;
  end;

  {$EndRegion}

  {$Region ' �����ļ� ' }

  TMyBackupFileInfoRead = class( TMyBackupInfoReadBase )
  public
    FilePath : string;
  protected
    BackupFileInfo : TBackupFileInfo;
  public
    procedure SetFilePath( _FilePath : string );
  protected
    function FindBackupFileInfo : Boolean;
  end;

    // ��ȡ �����ļ���Ϣ
  TFindTempBackupFileBaseInfo = class( TMyBackupFileInfoRead )
  public
    function get : TTempFileInfo;
  end;

      // ��ȡ �����ļ���Ϣ
  TFindTempBackupFileInfo = class( TMyBackupFileInfoRead )
  public
    function get : TTempBackupFileInfo;
  end;

  MyBackupFileInfoUtil = class
  public            // ��ȡ �����ļ� ��״̬��Ϣ
    class function ReadBackupCopyCount( BackupFileInfo : TBackupFileInfo ): Integer;
    class function ReadBackupStatus( PresetCopyCount, CopyCount : Integer ): string;overload;
    class function ReadBackupStatusShow( PresetCopyCount : Integer; BackupFileInfo : TBackupFileInfo ): string;
  public            // ��ȡ ������Ϣ
    class function ReadTempBackupFileBaseInfo( FilePath : string ): TTempFileInfo;
    class function ReadTempBackupFileInfo( FilePath : string ): TTempBackupFileInfo;
  private           // �ڲ�ʹ��
    class function ReadBackupFileInfo( FilePath : string ): TBackupFileInfo;
  end;

  {$EndRegion}

{$EndRegion}

/////////// ��д���� //////////

{$Region ' д ����·�� ��Ϣ '}

  TBackupPathChangeInfo = class( TChangeInfo )
  protected
    BackupPathList : TBackupPathList;
  public
    procedure Update;override;
  end;

    // ����·�� д��Ϣ ����
  TBackupPathWriteInfo = class( TBackupPathChangeInfo )
  public
    FullPath : string;
  protected
    BackupPathInfo : TBackupPathInfo;
  public
    constructor Create( _FullPath : string );
  protected
    function FindBackupPathInfo : Boolean;
  end;

    // ��� ����·�� ��Ϣ
  TBackupPathAddInfo = class( TBackupPathWriteInfo )
  public
    PathType : string;
    IsDisable, IsBackupNow : Boolean;
    CopyCount : Integer;
  public
    IsAuctoSync : Boolean;
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
    procedure SetBackupInfo( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAuctoSync : Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ����·�� �������仯
  TBackupPathCopyCountInfo = class( TBackupPathWriteInfo )
  private
    CopyCount : Integer;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
  end;

    // ·���� �ܿռ�
  TBackupPathSetSpaceInfo = class( TBackupPathWriteInfo )
  private
    FolderSpace : Int64;
    FileCount : Integer;
  public
    procedure SetFolderSpace( _FolderSpace : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' �޸� ͬ��ʱ�� ' }

    // ���� ��һ�� ͬ��ʱ��
  TBackupPathSetLastSyncTimeInfo = class( TBackupPathWriteInfo )
  private
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;override;
  end;

    // ���� ͬ������
  TBackupPathSetSyncMinsInfo = class( TBackupPathWriteInfo )
  private
    IsAutoSync : Boolean;
    SyncTimeValue, SyncTimeType : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� ״̬��Ϣ ' }

    // �Ƿ����㹻�� Pc ����
  TBackupPathIsNotEnoughPcInfo = class( TBackupPathWriteInfo )
  private
    IsNotEnoughPc : Boolean;
  public
    procedure SetIsNotEnouthPc( _IsNotEnoughPc : Boolean );
    procedure Update;override;
  end;

    // �Ƿ� ��ֹ����
  TBackupPathIsDisableInfo = class( TBackupPathWriteInfo )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;override;
  end;

    // �Ƿ� Backup Now ����
  TBackupPathIsBackupNowInfo = class( TBackupPathWriteInfo )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;override;
  end;


  {$EndRegion}

  {$Region ' �޸� ����� �ռ���Ϣ ' }

    // �޸�
  TBackupPathCompletedSpaceChangeInfo = class( TBackupPathWriteInfo )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ���
  TBackupPathAddCompletedSpaceInfo = class( TBackupPathCompletedSpaceChangeInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TBackupPathRemoveCompletedSpaceInfo = class( TBackupPathCompletedSpaceChangeInfo )
  public
    procedure Update;override;
  end;

    // ����
  TBackupPathSetCompletedSpaceInfo = class( TBackupPathCompletedSpaceChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

    // ɾ�� ����·�� ��Ϣ
  TBackupPathRemoveInfo = class( TBackupPathWriteInfo )
  public
    procedure Update;override;
  end;

  {$Region ' �޸� ����·�� ������� ' }

    // ����·�� ɾ��֪ͨ
  TBackupPathRemoveNotifyInfo = class( TBackupPathWriteInfo )
  public
    procedure Update;override;
  private
    procedure RemoveFile;
    procedure RemoveFolder;
  end;

    // ɾ�� ���� Job
  TBackupPathRemoveOfflineJobInfo = class( TChangeInfo )
  public
    procedure Update;override;
  end;

    // ������Ϣ Xml ��ȡ���
  TBackupXmlReadCompleted = class( TChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' д ����·��ӵ���� ��Ϣ ' }

    // ����
  TBackupPathOwnerChangeInfo = class( TBackupPathWriteInfo )
  public
    BackupPathOwnerHash : TBackupPathCopyOwnerHash;
  protected
    function FindBackupPathOwnerHash : Boolean;
  end;

    // ���
  TBackupPathOwnerClearSpaceInfo = class( TBackupPathOwnerChangeInfo )
  public
    procedure Update;override;
  end;

    // �޸�
  TBackupPathOwnerWriteInfo = class( TBackupPathOwnerChangeInfo )
  public
    PcID : string;
    BackupPathOwnerInfo : TBackupPathCopyOwner;
  public
    procedure SetPcID( _PcID : string );
  protected
    function FindBackupPathOwner : Boolean;
    procedure AddBackupPathOwner;
  end;

    // �޸� �ռ���Ϣ
  TBackupPathOwnerChangeSpaceInfo = class( TBackupPathOwnerWriteInfo )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ��� �ռ���Ϣ
  TBackupPathOwnerAddSpaceInfo = class( TBackupPathOwnerChangeSpaceInfo )
  public
    procedure Update;override;
  end;

    // ɾ�� �ռ���Ϣ
  TBackupPathOwnerRemoveSpaceInfo = class( TBackupPathOwnerChangeSpaceInfo )
  public
    procedure Update;override;
  end;

    // ���� �ռ���Ϣ
  TBackupPathOwnerSetSpaceInfo = class( TBackupPathOwnerChangeSpaceInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д ����·�������� ��Ϣ ' }

  {$Region ' ���������� ' }

    // ���� ������ �޸�
  TBackupPathIncludeFilterChangeInfo = class( TBackupPathWriteInfo )
  public
    IncludeFilterList : TBackupFileFilterList;
  public
    function FindIncludeFilterList : Boolean;
  end;

      // ���
  TBackupPathIncludeFilterClearInfo = class( TBackupPathIncludeFilterChangeInfo )
  public
    procedure Update;override;
  end;

      // ���
  TBackupPathIncludeFilterAddInfo = class( TBackupPathIncludeFilterChangeInfo )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �ų� ������ ' }

    // �ų� ������ �޸�
  TBackupPathExcludeFilterChangeInfo = class( TBackupPathWriteInfo )
  public
    ExcludeFilterList : TBackupFileFilterList;
  public
    function FindExcludeFilterList : Boolean;
  end;

    // ���
  TBackupPathExcludeFilterClearInfo = class( TBackupPathExcludeFilterChangeInfo )
  public
    procedure Update;override;
  end;

    // ���
  TBackupPathExcludeFilterAddInfo = class( TBackupPathExcludeFilterChangeInfo )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
    procedure Update;override;
  end;

  {$EndRegion}


{$EndRegion}

{$Region ' д ����Ŀ¼ ��Ϣ ' }

    // �޸�
  TBackupFolderWriteInfo = class( TChangeInfo )
  public
    FolderPath : string;
  protected
    BackupFolderInfo : TBackupFolderInfo;
  public
    constructor Create( _FolderPath : string );
  protected
    function FindBackupFolderInfo : Boolean;
  end;

      // ���
  TBackupFolderAddInfo = class( TBackupFolderWriteInfo )
  public
    FileSize, CompletedSize : Int64;
    FileTime : TDateTime;
    FileCount : Integer;
  private
    RootFolderInfo : TBackupFolderInfo;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFolderInfo( _FileTime : TDateTime; _FileCount : Integer );
    procedure Update;override;
  private
    function FindRootFolderInfo : Boolean;
    procedure AddBackupFolderInfo;
  end;

      // ����Ŀ¼ �ռ���Ϣ
  TBackupFolderSetSpaceInfo = class( TBackupFolderWriteInfo )
  private
    FolderSpace : Int64;
    FileCount : Integer;
  public
    procedure SetFolderSpace( _FolderSpace : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  end;

  {$Region ' �޸� ����ɿռ� ��Ϣ ' }

    // �޸�
  TBackupFolderCompletedSpaceChangeInfo = class( TBackupFolderWriteInfo )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ����
  TBackupFolderSetCompletedSpaceInfo = class( TBackupFolderCompletedSpaceChangeInfo )
  private
    LastCompletedSpace : Int64;
  public
    procedure SetLastCompletedSpace( _LastCompletedSpace : Int64 );
    procedure Update;override;
  end;

    // ���
  TBackupFolderAddCompletedSpaceInfo = class( TBackupFolderCompletedSpaceChangeInfo )
  public
    procedure Update;override;
  end;

    // ɾ��
  TBackupFolderRemoveCompletedSpaceInfo = class( TBackupFolderCompletedSpaceChangeInfo )
  public
    procedure Update;override;
  end;

  {$EndRegion}


    // ɾ��Ŀ¼ ֪ͨ����Ŀ��
  TBackupFolderRemoveNotifyInfo = class( TBackupFolderWriteInfo )
  public
    procedure Update;override;
  private
    procedure AddToRemoveNotify( PcID : string );
  end;

    // ɾ��
  TBackupFolderRemoveInfo = class( TBackupFolderWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д �����ļ� ��Ϣ '}

    // д��Ϣ ����
  TBackupFileWriteInfo = class( TChangeInfo )
  public
    FilePath : string;
  protected
    BackupFileInfo : TBackupFileInfo;
  public
    constructor Create( _FilePath : string );
  public
    function FindBackupFileInfo: Boolean;
  end;

    // ��� ��Ϣ
  TBackupFileAddInfo = class( TBackupFileWriteInfo )
  public
    FileSize : Int64;
    LastWriteTime : TDateTime;
  private
    RootFolderInfo : TBackupFolderInfo;
  public
    procedure SetFileInfo( _FileSize : Int64; _LastWriteTime : TDateTime );
    procedure Update;override;
  private
    function FindRootFolderInfo : Boolean;
    procedure AddBackupFileInfo;
  end;

    // �����ļ�ɾ����֪ͨ����Ŀ��
  TBackupFileRemoveNotifyInfo = class( TBackupFileWriteInfo )
  public
    procedure Update;override;
  private
    procedure AddToRemoveNotify( PcID : string );
  end;

    // ɾ�� ��Ϣ
  TBackupFileRemoveInfo = class( TBackupFileWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д �����ļ����� ��Ϣ ' }

    // ����
  TBackupFileCopyChangeInfo = class( TBackupFileWriteInfo )
  protected
    BackupCopyHash : TCopyInfoHash;
  protected
    function FindBackupCopyHash : Boolean;
  end;

    // �޸�
  TBackupFileCopyWriteInfo = class( TBackupFileCopyChangeInfo )
  public
    CopyOwner : string;
  public
    BackupCopyInfo : TCopyInfo;
  public
    procedure SetCopyOwner( _CopyOwner : string );
  protected
    function FindBackupCopyInfo : Boolean;
    procedure AddBackupCopyInfo;
  end;

    // ���
  TBackupFileCopyAddInfo = class( TBackupFileCopyWriteInfo )
  public
    CopyStatus : string;
  public
    procedure SetCopyStatus( _CopyStatus : string );
    procedure Update;override;
  end;

    // ɾ��
  TBackupFileCopyRemoveInfo = class( TBackupFileCopyWriteInfo )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' д Ŀ¼���� ��Ϣ ' }

    // �ݹ� ɾ�� Ŀ¼����
  TBackupFolderCopyRemoveHandle = class
  private
    BackupFolderInfo : TBackupFolderInfo;
    CopyOwner, ParentPath : string;
  private
    SearchCount : Integer;
  public
    constructor Create( _BackupFolderInfo : TBackupFolderInfo );
    procedure SetCopyOwner( _CopyOwner : string );
    procedure SetParentPath( _ParentPath : string );
    procedure SetSearchCount( _SearchCount : Integer );
    procedure Update;
  private
    procedure RemoveFilesCopy;
    procedure RemoveChildFolder;
  private
    function CheckNextRemove : Boolean;
    procedure RemoveLoadedCopy( FilePath : string; FileSize : Int64 );
    procedure RemoveBackupCopy( FilePath : string );
  end;

    // ɾ�� ����Ŀ¼ Pc ������Ϣ
  TBackupFolderCopyRemoveInfo = class( TBackupFolderWriteInfo )
  public
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' �� ����·����Ϣ ' }

    // ɨ�� ָ��·��
  TBackupPathScanInfo = class( TChangeInfo )
  private
    FullPath : string;
    IsShowFreeLimt : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;override;
  private
    procedure AddFileConfirm;
  end;

    // ɨ�� ����·��
    // Back Up Now ר��
  TBackupPathScanAllInfo = class( TBackupPathChangeInfo )
  public
    procedure Update;override;
  private
    procedure AddScanPath( Path : string );
  private
    procedure ClearOldFileConfirm;
    procedure AddFileConfirm;
  end;

    // ͬ�� ָ��·��
    // �ж� ��Ѱ� �޶������ܿռ�
  TBackupPathSyncInfo = class( TChangeInfo )
  private
    FullPath : string;
    IsShowFreeLimt : Boolean;
  public
    constructor Create( _FullPath : string );
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;override;
  private
    function CheckFreeEditionLimit : Boolean;
    procedure ShowFreeLimtMsg;
    procedure ScanCompleted;
  private
    procedure ScanJobNow;
  end;

    // ͬ�� ����·��
  TBackupPathSyncAllInfo = class( TBackupPathChangeInfo )
  public
    procedure Update;override;
  private
    procedure AddScanJob( Path : string );
  end;

      // ˢ�� �Ƿ��㹻Pc ����
  TBackupPathReadIsNotEnoughPcInfo = class( TBackupPathChangeInfo )
  public
    procedure Update;override;
  end;

    // ˢ�� ����·�� ���ݽ���
  TBackupPathReadProgressInfo = class( TBackupPathChangeInfo )
  public
    procedure Update;override;
  end;

    // ������ӵ������Ϣ
  TMyCloudPcReadInfo = class
  public
    PcID : string;
    FileCount : Integer;
    FileSpace : Int64;
  public
    constructor Create( _PcID : string );
    procedure Add( AddFileCount : Integer; AddFileSpace : Int64 );
  end;
  TMyCloudPcReadPair = TPair< string , TMyCloudPcReadInfo >;
  TMyCloudPcReadHash = class(TStringDictionary< TMyCloudPcReadInfo >);

    // ˢ�� �����ı��� ӵ������Ϣ
  TBackupPathRefreshMyCloudPcInfo = class( TBackupPathChangeInfo )
  public
    procedure Update;override;
  private
    procedure ClearOldMyCloudPc;
    procedure AddNewMyCloudPc;
  end;

{$EndRegion}

{$Region ' �� �����ļ�/Ŀ¼��Ϣ ' }

    // ��ȡ ������Ϣ ListView ����Ϣ
  TBackupFolderReadLvInfo = class( TBackupFolderWriteInfo )
  private
    BackupLvReadFolderInfo : TBackupLvReadFolderInfo;
    PresetCopyCount : Integer;
  public
    procedure Update; override;
  private
    procedure ShowFiles;
    procedure ShowFolders;
  end;

    // ˢ�� Lv Backup ״̬��Ϣ
  TBackupFileRefreshLvFaceInfo = class( TBackupFileWriteInfo )
  public
    procedure Update;override;
  end;

    // File Detail Form
  TBackupFileReadDetailInfo = class( TBackupFileWriteInfo )
  public
    procedure Update;override;
  end;


{$EndRegion}

{$Region ' ��ȡ������Ϣ ' }

    // ��ȡ ���б���·�� ��Ϣ
  TFindBackupPathInfo = class
  private
    OutputBackupPathHash : TBackupPathList;
  public
    procedure SetOutput( _OutputBackupPathHash : TBackupPathList );
    procedure Update;
  end;

    // ��ȡ ���б���·��
  TFindBackupFullPathInfo = class
  private
    OutputBackupFullPathList : TStringList;
  public
    procedure SetOutput( _OutputBackupFullPathList : TStringList );
    procedure Update;
  end;

    // ��ȡ ���ݵ� Pc �ı���·��
  TFindBackupPathInPcInfo = class
  private
    PcIDHash : TStringHash;
    OutputPathHash : TStringHash;
  public
    constructor Create( _PcIDHash : TStringHash );
    procedure SetOutput( _OutputPathHash : TStringHash );
    procedure Update;
  end;

{$EndRegion}

////////// ���ݶ��� /////////

    // д ����
  TMyBackupFileInfo = class( TMyDataChange )
  public
    BackupPathList : TBackupPathList;
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
    // ���� ״̬
  CopyStatus_Pending = 'Pending';
  CopyStatus_Loading = 'Loading';
  CopyStatus_Offline = 'Offline';
  CopyStatus_Loaded = 'Loaded';

    // ����״̬
  BackupStatus_Empty = 'Empty';
  BackupStatus_Completed = 'Completed';
  BackupStatus_PartCompleted = 'Partially completed';
  BackupStatus_Incompleted = 'Incompleted';

    // ����·��״̬
  BackupPathStatus_Loading = 'Loading';
  BackupPathStatus_NotExist = 'NotExist';
  BackupPathStatus_Normal = 'Normal';

var
  ReadBackupXml_IsCompleted : Boolean = False;

var
  MyBackupFileInfo : TMyBackupFileInfo;  // д ������Ϣ

implementation

uses UBackupFileScan, UBackupJobScan, UBackupUtil, UMyNetPcInfo, UBackupfileConFirm,
     USettingInfo, UMyBackupRemoveControl, UMyClient, UNetworkFace, UMyJobInfo, UJobFace,
     UBackupBoardInfo, UNetPcInfoXml, UBackupInfoControl, URegisterInfo, UMainFormFace, UJobControl,
     UBackupAutoSyncInfo;

{ TBackupPathInfo }

constructor TBackupPathInfo.Create( _FullPath, _PathType : string );
begin
    // ·����Ϣ
  FullPath := _FullPath;
  PathType := _PathType;
  IsDisable := False;
  IsBackupNow := True;

    // ������Ϣ
  IsEncrypt := False;
  Password := '';
  PasswordHint := '';

    // �ռ���Ϣ
  CopyCount := 0;
  FolderSpace := 0;
  FileCount := 0;
  CompletedSpace := 0;

    // ������
  IncludeFilterList := TBackupFileFilterList.Create;
  ExcludeFilterList := TBackupFileFilterList.Create;

    // ��Ŀ¼��Ϣ
  if PathType = PathType_File then
    BackupFolderInfo := TRootBackupFileInfo.Create
  else
    BackupFolderInfo := TBackupFolderInfo.Create;
  BackupFolderInfo.SetFileName( FullPath );

    // ����ӵ������Ϣ
  IsNotEnoughPc := False;
  BackupPathCopyOwnerHash := TBackupPathCopyOwnerHash.Create;
end;

destructor TBackupPathInfo.Destroy;
begin
  ExcludeFilterList.Free;
  IncludeFilterList.Free;
  BackupPathCopyOwnerHash.Free;
  BackupFolderInfo.Free;
  inherited;
end;

procedure TBackupPathInfo.SetSpaceInfo( _FolderSpace, _CompletedSpace: Int64);
begin
  FolderSpace := _FolderSpace;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupPathInfo.SetBackupInfo(_IsDisable, _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathInfo.SetSyncIntervalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathInfo.SetAutoSyncInfo(_IsAutoSync : Boolean;
  _LasSyncTime: TDateTime);
begin
  IsAutoSync := _IsAutoSync;
  LasSyncTime := _LasSyncTime;
end;

procedure TBackupPathInfo.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TBackupPathInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

{ TBackupFolderInfo }

constructor TBackupFolderInfo.Create;
begin
  inherited;
  FileCount := 0;
  CompletedSpace := 0;
  BackupFileHash := TBackupFileInfoHash.Create;
  BackupFolderHash := TBackupFolderInfoHash.Create;
end;

destructor TBackupFolderInfo.Destroy;
begin
  BackupFileHash.Free;
  BackupFolderHash.Free;
  inherited;
end;

procedure TBackupFolderInfo.SetFolderInfo(_FileCount: Integer;
  _CompletedSpace: Int64);
begin
  FileCount := _FileCount;
  CompletedSpace := _CompletedSpace;
end;

{ TBackupFileInfo }

constructor TBackupFileInfo.Create;
begin
  inherited Create;
  CopyInfoHash := TCopyInfoHash.Create;
end;

destructor TBackupFileInfo.Destroy;
begin
  CopyInfoHash.Free;
  inherited;
end;


{ TBackupPathWriteInfo }

constructor TBackupPathWriteInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TBackupPathWriteInfo.FindBackupPathInfo: Boolean;
begin
  BackupPathInfo := BackupPathList.getPath( FullPath );
  Result := BackupPathInfo <> nil;
end;

{ TBackupPathAddInfo }

procedure TBackupPathAddInfo.SetBackupInfo(_IsDisable, _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathAddInfo.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TBackupPathAddInfo.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupPathAddInfo.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TBackupPathAddInfo.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FolderSpace := _FileSize;
  CompletedSpace := _CompletedSize;
end;

procedure TBackupPathAddInfo.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathAddInfo.SetAutoSyncInfo(_IsAuctoSync : Boolean;
  _LastSyncTime: TDateTime);
begin
  IsAuctoSync := _IsAuctoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathAddInfo.Update;
begin
  inherited;

    // �Ѵ���
  if FindBackupPathInfo then
    Exit;

    // ���
  BackupPathInfo := TBackupPathInfo.Create( FullPath, PathType );
  BackupPathInfo.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathInfo.SetAutoSyncInfo( IsAuctoSync, LastSyncTime );
  BackupPathInfo.SetSyncIntervalInfo( SyncTimeType, SyncTimeValue );
  BackupPathInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathInfo.SetCountInfo( CopyCount, FileCount );
  BackupPathInfo.SetSpaceInfo( FolderSpace, CompletedSpace );
  BackupPathList.Add( BackupPathInfo );
end;

{ TBackupFileWriteInfo }

constructor TBackupFileWriteInfo.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

function TBackupFileWriteInfo.FindBackupFileInfo: Boolean;
begin
  BackupFileInfo := MyBackupFileInfoUtil.ReadBackupFileInfo( FilePath );
  Result := BackupFileInfo <> nil;
end;

{ TBackupFileAddInfo }

procedure TBackupFileAddInfo.AddBackupFileInfo;
var
  ParentFolder, NewBackupFolderInfo : TBackupFolderInfo;
  BackupFolderHash : TBackupFolderInfoHash;
  BackupFileHash : TBackupFileInfoHash;
  NewBackupFileInfo : TBackupFileInfo;
  FileName, FolderPath, FolderName, RemainPath : string;
  IsFindNext : Boolean;
begin
    // ��Ŀ¼ �� �ļ���
  FolderPath := ExtractFileDir( FilePath );
  FileName := ExtractFileName( FilePath );

    // ����Ŀ¼ �� ��Ŀ¼
  if ( FilePath = RootFolderInfo.FileName ) or ( FolderPath = RootFolderInfo.FileName ) then
    ParentFolder := RootFolderInfo
  else
  begin   // �Ӹ�Ŀ¼����Ѱ�� ��Ŀ¼
    ParentFolder := RootFolderInfo;
    RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderInfo.FileName ), FolderPath );
    IsFindNext := True;
    while IsFindNext do             // Ѱ����Ŀ¼
    begin
      FolderName := MyString.GetRootFolder( RemainPath );
      if FolderName = '' then
      begin
        FolderName := RemainPath;
        IsFindNext := False;
      end;

        // ������ �򴴽�
      BackupFolderHash := ParentFolder.BackupFolderHash;
      if not BackupFolderHash.ContainsKey( FolderName ) then
      begin
        NewBackupFolderInfo := TBackupFolderInfo.Create;
        NewBackupFolderInfo.SetFileName( FolderName );
        BackupFolderHash.AddOrSetValue( FolderName, NewBackupFolderInfo );
        NewBackupFolderInfo.PaerntFolder := ParentFolder;
      end;

        // ��һ��
      ParentFolder := BackupFolderHash[ FolderName ];
      RemainPath := MyString.CutRootFolder( RemainPath );
    end;
  end;

    // �ļ������� �򴴽�
  BackupFileHash := ParentFolder.BackupFileHash;
  if not BackupFileHash.ContainsKey( FileName ) then
  begin
    NewBackupFileInfo := TBackupFileInfo.Create;
    NewBackupFileInfo.SetFileName( FileName );
    BackupFileHash.AddOrSetValue( FileName, NewBackupFileInfo  );
    NewBackupFileInfo.PaerntFolder := ParentFolder;
  end;
  BackupFileInfo := BackupFileHash[ FileName ];
end;

function TBackupFileAddInfo.FindRootFolderInfo: Boolean;
var
  BackupPathInfo : TBackupPathInfo;
begin
  Result := False;
  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FilePath );
  if BackupPathInfo = nil then
    Exit;

    // ��Ѱ��Ŀ¼
  RootFolderInfo := BackupPathInfo.BackupFolderInfo;
  Result := True;
end;

procedure TBackupFileAddInfo.SetFileInfo(_FileSize: Int64;
  _LastWriteTime: TDateTime);
begin
  FileSize := _FileSize;
  LastWriteTime := _LastWriteTime;
end;

procedure TBackupFileAddInfo.Update;
begin
  inherited;

    // ��Ŀ¼������
  if not FindRootFolderInfo then
    Exit;

    // ����ļ�
  AddBackupFileInfo;
  BackupFileInfo.SetFileInfo( FileSize, LastWriteTime );
end;

{ TCopyInfo }

constructor TCopyInfo.Create(_CopyOwner, _CopyStatus: string);
begin
  CopyOwner := _CopyOwner;
  CopyStatus := _CopyStatus;
end;

constructor TCopyInfo.Create(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

{ TBackupPathRemoveInfo }

procedure TBackupPathRemoveInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

    // ɾ��
  BackupPathList.RemovePath( FullPath );
end;

{ TBackupFileRemoveInfo }

procedure TBackupFileRemoveInfo.Update;
var
  FileName : string;
begin
  inherited;

    // �ļ�������
  if not FindBackupFileInfo then
    Exit;

    // ��Ŀ¼ ɾ���ļ�
  FileName := ExtractFileName( FilePath );
  BackupFileInfo.PaerntFolder.BackupFileHash.Remove( FileName );
end;

{ TBackupFileReadLvInfo }

procedure TBackupFolderReadLvInfo.ShowFiles;
var
  BackupFileHash : TBackupFileInfoHash;
  p : TBackupFileInfoPair;
  FilePath, BackupStatus, BackupStatusShow : string;
  CopyCount : Integer;
  BackupLvAddInfo : TBackupLvAddInfo;
begin
  BackupFileHash := BackupFolderInfo.BackupFileHash;
  for p in BackupFileHash do
  begin
    if BackupFolderInfo is TRootBackupFileInfo then
      FilePath := FolderPath
    else
      FilePath := MyFilePath.getPath( FolderPath ) + p.Value.FileName;
    CopyCount := MyBackupFileInfoUtil.ReadBackupCopyCount( p.Value );
    BackupStatus := MyBackupFileInfoUtil.ReadBackupStatus( PresetCopyCount, CopyCount );
    BackupStatusShow := MyBackupFileInfoUtil.ReadBackupStatusShow( PresetCopyCount, p.Value );

    BackupLvAddInfo := TBackupLvAddInfo.Create( FilePath );
    BackupLvAddInfo.SetFileInfo( p.Value.FileSize, p.Value.LastWriteTime );
    BackupLvAddInfo.SetCopyInfo( CopyCount );
    BackupLvAddInfo.SetStatusInfo( BackupStatus, BackupStatusShow );

    BackupLvReadFolderInfo.AddBackupLv( BackupLvAddInfo );
  end;
end;

procedure TBackupFolderReadLvInfo.ShowFolders;
var
  BackupFolderHash : TBackupFolderInfoHash;
  p : TBackupFolderInfoPair;
  ChildFolderPath, BackupStatus, BackupStatusShow, FileName : string;
  TotalSize : Int64;
  Percentage : Integer;
  BackupLvAddInfo : TBackupLvAddInfo;
begin
  BackupFolderHash := BackupFolderInfo.BackupFolderHash;
  for p in BackupFolderHash do
  begin
    ChildFolderPath := MyFilePath.getPath( FolderPath ) + p.Value.FileName;
    if p.Value.FileCount = 0 then
      BackupStatus := BackupStatus_Empty
    else
    begin
      TotalSize := PresetCopyCount * p.Value.FileSize;
      BackupStatus := LvBackupFileUtil.getBackupStatus( p.Value.CompletedSpace, TotalSize );
      BackupStatusShow := VstBackupItemUtil.getBackupStatus( p.Value.CompletedSpace, TotalSize );
    end;

    BackupLvAddInfo := TBackupLvAddInfo.Create( ChildFolderPath );
    BackupLvAddInfo.SetFileInfo( p.Value.FileSize, p.Value.LastWriteTime );
    BackupLvAddInfo.SetIsFolder( True );
    BackupLvAddInfo.SetCopyInfo( 0 );
    BackupLvAddInfo.SetStatusInfo( BackupStatus, BackupStatusShow );;

    BackupLvReadFolderInfo.AddBackupLv( BackupLvAddInfo );
  end;
end;


procedure TBackupFolderReadLvInfo.Update;
begin
  inherited;

    // Item ���õ� Copy ��
  PresetCopyCount := MyBackupPathInfoUtil.ReadPresetCopyCount( FolderPath );

    // Ŀ¼ ������
  if not FindBackupFolderInfo then
    Exit;

    // ����������ʾ
  BackupLvReadFolderInfo := TBackupLvReadFolderInfo.Create( FolderPath );

    // ���� �ļ�
  ShowFiles;

    // ���� Ŀ¼
  ShowFolders;

    // ��ӵ�����
  MyBackupFileFace.AddChange( BackupLvReadFolderInfo );
end;

{ TMyBackupData }

constructor TMyBackupFileInfo.Create;
begin
  inherited;
  BackupPathList := TBackupPathList.Create;
  AddThread(1);
end;

destructor TMyBackupFileInfo.Destroy;
begin
  BackupPathList.Free;
  inherited;
end;

{ TFindBackupFolderInfo }

procedure TFindTempBackFolderBaseInfo.FindFiles;
var
  BackupFileHash : TBackupFileInfoHash;
  FileHash : TTempFileHash;
  p : TBackupFileInfoPair;
  FileInfo : TTempFileInfo;
begin
  BackupFileHash := BackupFolderInfo.BackupFileHash;
  FileHash := TempFolderInfo.TempFileHash;
  for p in BackupFileHash do
  begin
    FileInfo := TTempFileInfo.Create;
    FileInfo.SetFileBaseInfo( p.Value );
    FileHash.AddOrSetValue( p.Value.FileName, FileInfo );
  end;
end;

procedure TFindTempBackFolderBaseInfo.FindFolders;
var
  BackupFolderHash : TBackupFolderInfoHash;
  FolderHash : TTempFolderHash;
  p : TBackupFolderInfoPair;
  FolderInfo : TTempFolderInfo;
begin
  BackupFolderHash := BackupFolderInfo.BackupFolderHash;
  FolderHash := TempFolderInfo.TempFolderHash;
  for p in BackupFolderHash do
  begin
    FolderInfo := TTempFolderInfo.Create;
    FolderInfo.SetFileBaseInfo( p.Value );
    FolderHash.AddOrSetValue( p.Value.FileName, FolderInfo );
  end;
end;

function TFindTempBackFolderBaseInfo.get: TTempFolderInfo;
begin
  TempFolderInfo := TTempFolderInfo.Create;

    // Ŀ¼����, ��ȡ Ŀ¼��Ϣ
  if FindBackupFolderInfo then
  begin
      // ���� Ŀ¼��Ϣ
    TempFolderInfo.SetFileBaseInfo( BackupFolderInfo );

      // Ѱ�� ���ļ���Ϣ
    FindFiles;

      // Ѱ�� ��Ŀ¼��Ϣ
    FindFolders;
  end;

  Result := TempFolderInfo;
end;

{ TBackupFileReadDetailInfo }

procedure TBackupFileReadDetailInfo.Update;
var
  PresetCopyCount, CopyCount : Integer;
  CopyInfoHash : TCopyInfoHash;
  p : TCopyInfoPair;
  BackupFrmDetailInfo : TBackupFrmDetailInfo;
  ShowCopyHash : TShowCopyHash;
  ShowCopyInfo : TShowCopyInfo;
  LocationName, CopyOwner, OnlineShowStr : string;
begin
  inherited;

  PresetCopyCount := MyBackupPathInfoUtil.ReadPresetCopyCount( FilePath );

    // �����ļ� ������
  if not FindBackupFileInfo then
    Exit;

  CopyCount := MyBackupFileInfoUtil.ReadBackupCopyCount( BackupFileInfo );

  BackupFrmDetailInfo := TBackupFrmDetailInfo.Create;
  BackupFrmDetailInfo.FullPath := FilePath;
  BackupFrmDetailInfo.FileSize := BackupFileInfo.FileSize;
  BackupFrmDetailInfo.FileCount := CopyCount;
  BackupFrmDetailInfo.BackupStatus := MyBackupFileInfoUtil.ReadBackupStatus( PresetCopyCount, CopyCount );
  ShowCopyHash := BackupFrmDetailInfo.ShowCopyHash;

  CopyInfoHash := BackupFileInfo.CopyInfoHash;
  for p in CopyInfoHash do
  begin
    CopyOwner := p.Value.CopyOwner;
    LocationName := MyNetPcInfoReadUtil.ReadName( CopyOwner );
    ShowCopyInfo := TShowCopyInfo.Create( LocationName, p.Value.CopyStatus );
    if MyNetPcInfoReadUtil.ReadIsOnline( CopyOwner ) then
      OnlineShowStr := Status_Online
    else
      OnlineShowStr := DateTimeToStr( MyNetPcInfoReadUtil.ReadLastOnlineTime( CopyOwner ) );
    ShowCopyInfo.SetOwnerOnlineTime( OnlineShowStr );
    ShowCopyHash.AddOrSetValue( p.Value.CopyOwner, ShowCopyInfo );
  end;

  MyBackupFileFace.AddChange( BackupFrmDetailInfo );
end;

{ TFindBackupPathInfo }

procedure TFindBackupPathInfo.SetOutput(_OutputBackupPathHash: TBackupPathList);
begin
  OutputBackupPathHash := _OutputBackupPathHash;
end;

procedure TFindBackupPathInfo.Update;
var
  i : Integer;
  BackupPathList : TBackupPathList;
  BackupPathInfo : TBackupPathInfo;
  OutputBackupPathInfo : TBackupPathInfo;
  OutputBackupPathCopyHash : TBackupPathCopyOwnerHash;
  po : TBackupPathCopyOwnerPair;
  CopyOwnerInfo : TBackupPathCopyOwner;
begin
  MyBackupFileInfo.EnterData;
  BackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
  begin
    BackupPathInfo := BackupPathList[i];
    OutputBackupPathInfo := TBackupPathInfo.Create( BackupPathInfo.FullPath, BackupPathInfo.PathType );
    OutputBackupPathInfo.SetEncryptInfo( BackupPathInfo.IsEncrypt, BackupPathInfo.Password, BackupPathInfo.PasswordHint );
    OutputBackupPathInfo.SetSpaceInfo( BackupPathInfo.FolderSpace, BackupPathInfo.CompletedSpace );
    OutputBackupPathInfo.SetCountInfo( BackupPathInfo.CopyCount, BackupPathInfo.FileCount );
    OutputBackupPathCopyHash := OutputBackupPathInfo.BackupPathCopyOwnerHash;
    for po in BackupPathInfo.BackupPathCopyOwnerHash do
    begin
      CopyOwnerInfo := TBackupPathCopyOwner.Create( po.Value.PcID );
      CopyOwnerInfo.OwnerSpace := po.Value.OwnerSpace;
      OutputBackupPathCopyHash.AddOrSetValue( po.Value.PcID, CopyOwnerInfo );
    end;
    OutputBackupPathHash.Add( OutputBackupPathInfo );
  end;
  MyBackupFileInfo.LeaveData;
end;

{ TBackupPathFolderSpaceInfo }

procedure TBackupPathSetSpaceInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TBackupPathSetSpaceInfo.SetFolderSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TBackupPathSetSpaceInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.FolderSpace := FolderSpace;
  BackupPathInfo.FileCount := FileCount;
end;

{ TBackupPathChangeInfo }

procedure TBackupPathChangeInfo.Update;
begin
  BackupPathList := MyBackupFileInfo.BackupPathList;
end;

{ TFindCheckFolder }

procedure TFindTempBackupFolderInfo.FindFiles;
var
  BackupFileHash : TBackupFileInfoHash;
  p : TBackupFileInfoPair;
  pc : TCopyInfoPair;
  FileHash : TTempBackupFileHash;
  FileInfo : TTempBackupFileInfo;
  CopyHash : TTempCopyHash;
  CopyInfo : TTempCopyInfo;
begin
  BackupFileHash := BackupFolderInfo.BackupFileHash;
  FileHash := TempBackupFolderInfo.TempBackupFileHash;
  for p in BackupFileHash do
  begin
    FileInfo := TTempBackupFileInfo.Create;
    FileInfo.SetFileBaseInfo( p.Value );
    FileHash.AddOrSetValue( p.Value.FileName, FileInfo );
    CopyHash := FileInfo.TempCopyHash;
    for pc in p.Value.CopyInfoHash do
    begin
      CopyInfo := TTempCopyInfo.Create( pc.Value.CopyOwner, pc.Value.CopyStatus );
      CopyHash.Add( pc.Value.CopyOwner, CopyInfo );
    end;
  end;
end;

procedure TFindTempBackupFolderInfo.FindFolders;
var
  BackupFolderHash : TBackupFolderInfoHash;
  p : TBackupFolderInfoPair;
  FolderHash : TTempBackupFolderHash;
  FolderInfo : TTempBackupFolderInfo;
begin
  BackupFolderHash := BackupFolderInfo.BackupFolderHash;
  FolderHash := TempBackupFolderInfo.TempBackupFolderHash;
  for p in BackupFolderHash do
  begin
    FolderInfo := TTempBackupFolderInfo.Create;
    FolderInfo.SetFileBaseInfo( p.Value );
    FolderHash.AddOrSetValue( p.Value.FileName, FolderInfo );
  end;
end;

function TFindTempBackupFolderInfo.get : TTempBackupFolderInfo;
begin
  TempBackupFolderInfo := TTempBackupFolderInfo.Create;

    // Ŀ¼����, ��ȡ Ŀ¼��Ϣ
  if FindBackupFolderInfo then
  begin
      // ������Ϣ
    TempBackupFolderInfo.SetFileBaseInfo( BackupFolderInfo );

      // Ѱ���ļ�
    FindFiles;

      // Ѱ��Ŀ¼
    FindFolders;
  end;

  Result := TempBackupFolderInfo;
end;

{ TBackupFolderCopyRemoveHandle }

function TBackupFolderCopyRemoveHandle.CheckNextRemove: Boolean;
begin
  Inc( SearchCount );
  if SearchCount >= SearchCount_Sleep then
  begin
    SearchCount := 0;
    Sleep(1);
  end;

  Result := MyBackupFileInfo.IsRun;
end;

constructor TBackupFolderCopyRemoveHandle.Create(_BackupFolderInfo : TBackupFolderInfo);
begin
  BackupFolderInfo := _BackupFolderInfo;
  SearchCount := 0;
end;

procedure TBackupFolderCopyRemoveHandle.RemoveChildFolder;
var
  BackupFolderHash : TBackupFolderInfoHash;
  p : TBackupFolderInfoPair;
  ChildPath : string;
  BackupFolderCopyRemoveHandle : TBackupFolderCopyRemoveHandle;
begin
  BackupFolderHash := BackupFolderInfo.BackupFolderHash;
  for p in BackupFolderHash do
  begin
    if not CheckNextRemove then
      Break;

    ChildPath := ParentPath + p.Value.FileName;

      // �ݹ�
    BackupFolderCopyRemoveHandle := TBackupFolderCopyRemoveHandle.Create( p.Value );
    BackupFolderCopyRemoveHandle.SetParentPath( ChildPath );
    BackupFolderCopyRemoveHandle.SetCopyOwner( CopyOwner );
    BackupFolderCopyRemoveHandle.SetSearchCount( SearchCount );
    BackupFolderCopyRemoveHandle.Update;
    SearchCount := BackupFolderCopyRemoveHandle.SearchCount;
    BackupFolderCopyRemoveHandle.Free
  end;
end;

procedure TBackupFolderCopyRemoveHandle.RemoveBackupCopy(FilePath: string);
var
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( CopyOwner );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TBackupFolderCopyRemoveHandle.RemoveFilesCopy;
var
  BackupFileHash : TBackupFileInfoHash;
  p : TBackupFileInfoPair;
  FilePath : string;
begin
  BackupFileHash := BackupFolderInfo.BackupFileHash;
  for p in BackupFileHash do
  begin
    if not CheckNextRemove then
      Break;

    if not p.Value.CopyInfoHash.ContainsKey( CopyOwner ) then
      Continue;

    FilePath := ParentPath + p.Value.FileName;

    if p.Value.CopyInfoHash[ CopyOwner ].CopyStatus = CopyStatus_Loaded then
      RemoveLoadedCopy( FilePath, p.Value.FileSize )
    else
      RemoveBackupCopy( FilePath );
  end;
end;

procedure TBackupFolderCopyRemoveHandle.RemoveLoadedCopy(FilePath: string;
  FileSize : Int64);
var
  BackupCopyRemoveControl : TBackupCopyRemoveControl;
begin
  BackupCopyRemoveControl := TBackupCopyRemoveControl.Create( FilePath, CopyOwner );
  BackupCopyRemoveControl.SetFileSize( FileSize );
  BackupCopyRemoveControl.Update;
  BackupCopyRemoveControl.Free;
end;

procedure TBackupFolderCopyRemoveHandle.SetCopyOwner(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

procedure TBackupFolderCopyRemoveHandle.SetParentPath(_ParentPath: string);
begin
  ParentPath := _ParentPath;
end;

procedure TBackupFolderCopyRemoveHandle.SetSearchCount(_SearchCount: Integer);
begin
  SearchCount := _SearchCount;
end;

procedure TBackupFolderCopyRemoveHandle.Update;
begin
  ParentPath := MyFilePath.getPath( ParentPath );

    // ɾ�ļ�����
  RemoveFilesCopy;

    // ɾ��Ŀ¼����
  RemoveChildFolder;
end;

{ TBackupFolderSpaceInfo }

procedure TBackupFolderSetSpaceInfo.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TBackupFolderSetSpaceInfo.SetFolderSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TBackupFolderSetSpaceInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupFolderInfo then
    Exit;

  BackupFolderInfo.FileSize := FolderSpace;
  BackupFolderInfo.FileCount := FileCount;
end;

{ TFindBackupFullPathInfo }

procedure TFindBackupFullPathInfo.SetOutput(
  _OutputBackupFullPathList: TStringList);
begin
  OutputBackupFullPathList := _OutputBackupFullPathList;
end;

procedure TFindBackupFullPathInfo.Update;
var
  BackupPathList : TBackupPathList;
  i : Integer;
begin
  MyBackupFileInfo.EnterData;
  BackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
    OutputBackupFullPathList.Add( BackupPathList[i].FullPath );
  MyBackupFileInfo.LeaveData;
end;

{ TBackupPathIsEnoughPcInfo }

procedure TBackupPathIsNotEnoughPcInfo.SetIsNotEnouthPc(_IsNotEnoughPc: Boolean);
begin
  IsNotEnoughPc := _IsNotEnoughPc;
end;

procedure TBackupPathIsNotEnoughPcInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.IsNotEnoughPc := IsNotEnoughPc;
end;

{ TBackupPathReadIsEnoughPcInfo }

procedure TBackupPathReadIsNotEnoughPcInfo.Update;
var
  IsNotEnouthPc : Boolean;
  i : Integer;
  BackupCowNotEnoughInfo : TBackupCowNotEnoughInfo;
begin
  inherited;

    // �������б���·�����Ƿ����û���㹻Pc��·��
  IsNotEnouthPc := False;
  for i := 0 to BackupPathList.Count - 1 do
    if BackupPathList[i].IsNotEnoughPc then
    begin
      IsNotEnouthPc := True;
      Break;
    end;

    // ˢ�½���
  BackupCowNotEnoughInfo := TBackupCowNotEnoughInfo.Create( IsNotEnouthPc );
  MyBackupFileFace.AddChange( BackupCowNotEnoughInfo );
end;

{ TBackupPathReadProgressInfo }

procedure TBackupPathReadProgressInfo.Update;
var
  CompletedSize, TotalSize : Int64;
  PathCompletedSize, PathTotalSize : Int64;
  CopyCount : Int64;
  i : Integer;
  pb : TBackupPathCopyOwnerPair;
  BackupProgressInfo : TBackupPgRefreshInfo;
begin
  inherited;

  CompletedSize := 0;
  TotalSize := 0;

    // �������б���·��
  for i := 0 to BackupPathList.Count - 1 do
  begin
    CopyCount := BackupPathList[i].CopyCount;
    PathTotalSize := BackupPathList[i].FolderSpace;
    PathCompletedSize := 0;
    for pb in BackupPathList[i].BackupPathCopyOwnerHash do
      PathCompletedSize := PathCompletedSize + pb.Value.OwnerSpace;

      // ·���ռ��� * Copy ��
    PathTotalSize := PathTotalSize * CopyCount;
    if PathCompletedSize > PathTotalSize then // ���ܴ��� ��ֵ
      PathCompletedSize := PathTotalSize;

    CompletedSize := CompletedSize + PathCompletedSize;
    TotalSize := TotalSize + PathTotalSize;
  end;

    // ��ʾ������
  BackupProgressInfo := TBackupPgRefreshInfo.Create( CompletedSize, TotalSize );
  MyBackupFileFace.AddChange( BackupProgressInfo );
end;

{ TBackupPathCopyCountInfo }

procedure TBackupPathCopyCountInfo.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupPathCopyCountInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.CopyCount := CopyCount;
end;

{ TFindTempBackupFileInfo }

function TFindTempBackupFileInfo.get: TTempBackupFileInfo;
var
  p : TCopyInfoPair;
  CopyHash : TTempCopyHash;
  CopyInfo : TTempCopyInfo;
begin
  Result := nil;

    // �ļ�������
  if not FindBackupFileInfo then
    Exit;

    // ������Ϣ
  Result := TTempBackupFileInfo.Create;
  Result.SetFileBaseInfo( BackupFileInfo );
  CopyHash := Result.TempCopyHash;
  for p in BackupFileInfo.CopyInfoHash do
  begin
    CopyInfo := TTempCopyInfo.Create( p.Value.CopyOwner, p.Value.CopyStatus );
    CopyHash.Add( p.Value.CopyOwner, CopyInfo );
  end;
end;

{ TFindBackupPathInPcInfo }

constructor TFindBackupPathInPcInfo.Create(_PcIDHash : TStringHash);
begin
  PcIDHash := _PcIDHash;
end;

procedure TFindBackupPathInPcInfo.SetOutput(
  _OutputPathHash : TStringHash);
begin
  OutputPathHash := _OutputPathHash;
end;

procedure TFindBackupPathInPcInfo.Update;
var
  BackupPathList : TBackupPathList;
  i : Integer;
  pb : TBackupPathCopyOwnerPair;
  ps : TStringPart;
begin
  MyBackupFileInfo.EnterData;
  BackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
    for pb in BackupPathList[i].BackupPathCopyOwnerHash do
      if PcIDHash.ContainsKey( pb.Value.PcID ) then
      begin
        OutputPathHash.AddString( BackupPathList[i].FullPath );
        Break;
      end;
  MyBackupFileInfo.LeaveData;
end;

{ TBackupCopyLvFaceReadInfo }

procedure TBackupFileRefreshLvFaceInfo.Update;
var
  PresetCopyCount : Integer;
  BackupStatusShow, BackupStatus : string;
  BackupCopyCount : Integer;
  BackupLvStatusInfo : TBackupLvStatusInfo;
begin
  inherited;

  PresetCopyCount := MyBackupPathInfoUtil.ReadPresetCopyCount( FilePath );

    // �ļ�������
  if not FindBackupFileInfo then
    Exit;

    // ��ȡ Lv ��ʾ��Ϣ
  BackupCopyCount := MyBackupFileInfoUtil.ReadBackupCopyCount( BackupFileInfo );
  BackupStatus := MyBackupFileInfoUtil.ReadBackupStatus( PresetCopyCount, BackupCopyCount );
  BackupStatusShow := MyBackupFileInfoUtil.ReadBackupStatusShow( PresetCopyCount, BackupFileInfo );

    // ˢ�½���״̬
  BackupLvStatusInfo := TBackupLvStatusInfo.Create( FilePath );
  BackupLvStatusInfo.SetCopyCountStatus( IntToStr( BackupCopyCount ) );
  BackupLvStatusInfo.SetStatusInfo( BackupStatus, BackupStatusShow );
  MyBackupFileFace.AddChange( BackupLvStatusInfo );
end;

{ TBackupFileRemoveNotifyInfo }

procedure TBackupFileRemoveNotifyInfo.AddToRemoveNotify(PcID: string);
var
  BackupRemoveNofityAddHandle : TBackupRemoveNotifyAddHandle;
begin
  BackupRemoveNofityAddHandle := TBackupRemoveNotifyAddHandle.Create( PcID );
  BackupRemoveNofityAddHandle.SetFullPath( FilePath );
  BackupRemoveNofityAddHandle.Update;
  BackupRemoveNofityAddHandle.Free;
end;

procedure TBackupFileRemoveNotifyInfo.Update;
var
  CopyOwnerHash : TCopyInfoHash;
  p : TCopyInfoPair;
begin
  inherited;

    // �����ļ�������
  if not FindBackupFileInfo then
    Exit;

    // ֪ͨ���ݸ���Ŀ��
  CopyOwnerHash := BackupFileInfo.CopyInfoHash;
  for p in CopyOwnerHash do
    AddToRemoveNotify( p.Value.CopyOwner );
end;

{ TBackupPathScanAndJobAndDesAllInfo }

procedure TBackupPathScanAllInfo.AddFileConfirm;
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  BackupScanPathInfo := TBackupScanPathInfo.Create( BackupFileScanType_FileConfirm );
  MyBackupFileScanInfo.AddScanPathInfo( BackupScanPathInfo );
end;

procedure TBackupPathScanAllInfo.AddScanPath(Path: string);
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin    // ���ɨ��·��
  BackupScanPathInfo := TBackupScanPathInfo.Create( Path );
  BackupScanPathInfo.SetIsShowFreeLimt( True );
  MyBackupFileScanInfo.AddScanPathInfo( BackupScanPathInfo );
end;

procedure TBackupPathScanAllInfo.ClearOldFileConfirm;
begin
  MyFileConfirm.ClearBackupConfirm;
end;

procedure TBackupPathScanAllInfo.Update;
var
  i : Integer;
begin
  inherited;

    // ��� �ɵ��ļ�ȷ��
  ClearOldFileConfirm;

    // ɨ������·��
  for i := 0 to BackupPathList.Count - 1 do
  begin
      // ������ BackupNow
    if not BackupPathList[i].IsBackupNow then
      Continue;
      // Backup Disable
    if BackupPathList[i].IsDisable then
      Continue;
      // ���ɨ��·��
    AddScanPath( BackupPathList[i].FullPath );
  end;

    // ��� �µ��ļ�ȷ��
  AddFileConfirm;
end;

{ TBackupPathRefreshMyCloudPcInfo }

procedure TBackupPathRefreshMyCloudPcInfo.AddNewMyCloudPc;
var
  i : Integer;
  BackupPathCopyOwnerHash : TBackupPathCopyOwnerHash;
  pb : TBackupPathCopyOwnerPair;
  OwnerID : string;
  MyCloudPcReadHash : TMyCloudPcReadHash;
  MyCloudPcReadInfo : TMyCloudPcReadInfo;
  pmc : TMyCloudPcReadPair;
  VstCloudStatusSetHasMyBackupSpace : TVstCloudStatusHasMyBackupSet;
  MyBackupCloudLvAddSpace : TMyBackupCloudLvAddSpace;
begin
  MyCloudPcReadHash := TMyCloudPcReadHash.Create;

    // ͳ��
  for i := 0 to BackupPathList.Count - 1 do     // �������� ����·��
  begin
    for pb in BackupPathList[i].BackupPathCopyOwnerHash do // �������� ·��ӵ����
    begin
      OwnerID := pb.Value.PcID;
      if not MyCloudPcReadHash.ContainsKey( OwnerID ) then
      begin
        MyCloudPcReadInfo := TMyCloudPcReadInfo.Create( OwnerID );
        MyCloudPcReadHash.AddOrSetValue( OwnerID, MyCloudPcReadInfo );
      end
      else
        MyCloudPcReadInfo := MyCloudPcReadHash[ OwnerID ];
      MyCloudPcReadInfo.Add( pb.Value.OwnerFileCount, pb.Value.OwnerSpace );
    end;
  end;

    // ���
  for pmc in MyCloudPcReadHash do
  begin
      // Total Pc
    VstCloudStatusSetHasMyBackupSpace := TVstCloudStatusHasMyBackupSet.Create( pmc.Value.PcID );
    VstCloudStatusSetHasMyBackupSpace.SetSpaceInfo( pmc.Value.FileSpace, pmc.Value.FileCount );
    MyNetworkFace.AddChange( VstCloudStatusSetHasMyBackupSpace );

      // MyBackupFile Pc
    MyBackupCloudLvAddSpace := TMyBackupCloudLvAddSpace.Create( pmc.Value.PcID );
    MyBackupCloudLvAddSpace.SetFileSpace( pmc.Value.FileSpace );
    MyBackupCloudLvAddSpace.SetFileCount( pmc.Value.FileCount );
    MyNetworkFace.AddChange( MyBackupCloudLvAddSpace );
  end;

  MyCloudPcReadHash.Free;
end;

procedure TBackupPathRefreshMyCloudPcInfo.ClearOldMyCloudPc;
var
  VstCloudStatusMyBackupSpaceClear : TVstCloudStatusMyBackupClear;
  MyBackupCloudLvClearInfo : TMyBackupCloudLvClearInfo;
begin
    // Total Pc
  VstCloudStatusMyBackupSpaceClear := TVstCloudStatusMyBackupClear.Create;
  MyNetworkFace.AddChange( VstCloudStatusMyBackupSpaceClear );

    // MyBackup Pc
  MyBackupCloudLvClearInfo := TMyBackupCloudLvClearInfo.Create;
  MyNetworkFace.AddChange( MyBackupCloudLvClearInfo );
end;

procedure TBackupPathRefreshMyCloudPcInfo.Update;
begin
  inherited;

    // ��վɵ�
  ClearOldMyCloudPc;

    // ����µ�
  AddNewMyCloudPc;
end;

{ TMyCloudPcReadInfo }

procedure TMyCloudPcReadInfo.Add(AddFileCount: Integer; AddFileSpace: Int64);
begin
  FileCount := FileCount + AddFileCount;
  FileSpace := FileSpace + AddFileSpace;
end;

constructor TMyCloudPcReadInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  FileCount := 0;
  FileSpace := 0;
end;

{ TBackupPathFreeScanJobInfo }

function TBackupPathSyncInfo.CheckFreeEditionLimit: Boolean;
var
  TotalSpace : Int64;
  BackupPathList : TBackupPathList;
  i : Integer;
begin
  Result := False;
  if not RegisterInfo.getIsFreeEdition then // ����Ѱ�
    Exit;

  TotalSpace := 0;
  BackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
    TotalSpace := TotalSpace + BackupPathList[i].FolderSpace;
  Result := TotalSpace > EditionUtil.getFreeMaxBackupSpace;
end;


constructor TBackupPathSyncInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
  IsShowFreeLimt := False;
end;

procedure TBackupPathSyncInfo.ScanCompleted;
var
  BackupTvBackupStopInfo : TBackupTvBackupStopInfo;
begin
    // ֪ͨ���� ֹͣ����
  BackupTvBackupStopInfo := TBackupTvBackupStopInfo.Create;
  MyBackupFileFace.AddChange( BackupTvBackupStopInfo );

    // ���� ����Ϣ
  MyClient.UpgradeCloudInfo;
end;

procedure TBackupPathSyncInfo.ScanJobNow;
var
  BackupJobScanInfo : TBackupJobScanInfo;
begin
  BackupJobScanInfo := TBackupJobScanInfo.Create( FullPath );
  MyBackupJobScanInfo.AddScanPath( BackupJobScanInfo );
end;

procedure TBackupPathSyncInfo.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathSyncInfo.ShowFreeLimtMsg;
var
  ShowFreeEditionWarnning : TShowFreeEditionWarnning;
begin
  ShowFreeEditionWarnning := TShowFreeEditionWarnning.Create( FreeEditionError_BackupSpace );
  MyMainFormFace.AddChange( ShowFreeEditionWarnning );
end;

procedure TBackupPathSyncInfo.Update;
begin
    // �ļ�ȷ��
  if FullPath = BackupFileScanType_FileConfirm then
  begin
    ScanJobNow;
    Exit;
  end;

    // Disable
  if not MyBackupPathInfoUtil.ReadIsEnable( FullPath ) then
    Exit;

    // ��� �Ƿ� ������Ѱ�����
  if CheckFreeEditionLimit then
  begin
      // ��ʾ ������������ ��ʾ��
    if IsShowFreeLimt then
      ShowFreeLimtMsg;

      // ������ʾ���ݽ���
    ScanCompleted;
  end
  else
    ScanJobNow;  // û�г�������, �����̱���
end;

{ TBackupXmlReadCompleted }

procedure TBackupXmlReadCompleted.Update;
begin
  ReadBackupXml_IsCompleted := True;

    // ���̼���Զ�����
  MyBackupAutoSyncInfo.CheckNow;
end;

{ TBackupFolderCompletedSpaceInfo }

procedure TBackupFolderSetCompletedSpaceInfo.SetLastCompletedSpace(
  _LastCompletedSpace: Int64);
begin
  LastCompletedSpace := _LastCompletedSpace;
end;

procedure TBackupFolderSetCompletedSpaceInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupFolderInfo then
    Exit;

    // �ѱ仯
  if BackupFolderInfo.CompletedSpace <> LastCompletedSpace then
    Exit;

  BackupFolderInfo.CompletedSpace := CompletedSpace;
end;

{ MyBackupFileInfoUtil }

class function MyBackupPathInfoUtil.ReadBackupPathList: TStringList;
var
  MyBackupInfoReadAllBackupPathHash : TMyBackupInfoReadAllBackupPathList;
begin
  MyBackupInfoReadAllBackupPathHash := TMyBackupInfoReadAllBackupPathList.Create;
  Result := MyBackupInfoReadAllBackupPathHash.get;
  MyBackupInfoReadAllBackupPathHash.Free;
end;

class function MyBackupPathInfoUtil.ReadBackupConfigInfo(
  FullPath: string): TBackupConfigInfo;
var
  MyBackupInfoReadConfig : TMyBackupInfoReadConfig;
begin
  MyBackupInfoReadConfig := TMyBackupInfoReadConfig.Create;
  MyBackupInfoReadConfig.SetFilePath( FullPath );
  Result := MyBackupInfoReadConfig.get;
  MyBackupInfoReadConfig.Free;
end;

class function MyBackupPathInfoUtil.ReadBackupPathInfo(
  FilePath: string): TBackupPathInfo;
var
  BackupPathList : TBackupPathList;
  i : Integer;
  SelectPath : string;
begin
  Result := nil;
  BackupPathList := MyBackupFileInfo.BackupPathList;
  for i := 0 to BackupPathList.Count - 1 do
  begin
    SelectPath := BackupPathList[i].FullPath;
    if not MyMatchMask.CheckEqualsOrChild( FilePath, SelectPath )  then
      Continue;
    Result := BackupPathList[i];
    Break;
  end;
end;

class function MyBackupPathInfoUtil.ReadComsumpCloudSpace: Int64;
var
  MyBackupFileInfoReadCompletedSpace : TMyBackupInfoReadCompletedSpace;
begin
  MyBackupFileInfoReadCompletedSpace := TMyBackupInfoReadCompletedSpace.Create;
  Result := MyBackupFileInfoReadCompletedSpace.get;
  MyBackupFileInfoReadCompletedSpace.Free;
end;

class function MyBackupPathInfoUtil.ReadComsumpPcSpace(PcID: string): Int64;
var
  MyBackupInfoReadComsumpPcSpace : TMyBackupInfoReadComsumpPcSpace;
begin
  MyBackupInfoReadComsumpPcSpace := TMyBackupInfoReadComsumpPcSpace.Create;
  MyBackupInfoReadComsumpPcSpace.SetPcID( PcID );
  Result :=  MyBackupInfoReadComsumpPcSpace.get;
  MyBackupInfoReadComsumpPcSpace.Free;
end;

class function MyBackupPathInfoUtil.ReadExcludeFilter(
  FullPath: string): TFileFilterList;
var
  MyBackupInfoReadExcludeFilter : TMyBackupInfoReadExcludeFilter;
begin
  MyBackupInfoReadExcludeFilter := TMyBackupInfoReadExcludeFilter.Create;
  MyBackupInfoReadExcludeFilter.SetFilePath( FullPath );
  Result :=  MyBackupInfoReadExcludeFilter.get;
  MyBackupInfoReadExcludeFilter.Free;
end;

class function MyBackupPathInfoUtil.ReadIncludeFilter(
  FullPath: string): TFileFilterList;
var
  MyBackupInfoReadIncludeFilter : TMyBackupInfoReadIncludeFilter;
begin
  MyBackupInfoReadIncludeFilter := TMyBackupInfoReadIncludeFilter.Create;
  MyBackupInfoReadIncludeFilter.SetFilePath( FullPath );
  Result :=  MyBackupInfoReadIncludeFilter.get;
  MyBackupInfoReadIncludeFilter.Free;
end;

class function MyBackupPathInfoUtil.ReadIsAutoSyncTimeOut(
  FullPath: string): Boolean;
var
  MyBackupInfoReadIsAutoSyncTimeOut : TMyBackupInfoReadIsAutoSyncTimeOut;
begin
  MyBackupInfoReadIsAutoSyncTimeOut := TMyBackupInfoReadIsAutoSyncTimeOut.Create;
  MyBackupInfoReadIsAutoSyncTimeOut.SetFilePath( FullPath );
  Result := MyBackupInfoReadIsAutoSyncTimeOut.get;
  MyBackupInfoReadIsAutoSyncTimeOut.Free;
end;

class function MyBackupPathInfoUtil.ReadIsEnable(FilePath: string): Boolean;
var
  MyBackupInfoReadIsEnable : TMyBackupInfoReadIsEnable;
begin
  MyBackupInfoReadIsEnable := TMyBackupInfoReadIsEnable.Create;
  MyBackupInfoReadIsEnable.SetFilePath( FilePath );
  Result := MyBackupInfoReadIsEnable.get;
  MyBackupInfoReadIsEnable.Free;
end;

class function MyBackupPathInfoUtil.ReadIsRootPath(FilePath: string): Boolean;
var
  MyBackupInfoReadIsRootPath : TMyBackupInfoReadIsRootPath;
begin
  MyBackupInfoReadIsRootPath := TMyBackupInfoReadIsRootPath.Create;
  MyBackupInfoReadIsRootPath.SetFilePath( FilePath );
  Result := MyBackupInfoReadIsRootPath.get;
  MyBackupInfoReadIsRootPath.Free;
end;

class function MyBackupPathInfoUtil.ReadPassword(FilePath: string): string;
var
  MyBackupFileInfoReadPassword : TMyBackupInfoReadPassword;
begin
  MyBackupFileInfoReadPassword := TMyBackupInfoReadPassword.Create;
  MyBackupFileInfoReadPassword.SetFilePath( FilePath );
  Result := MyBackupFileInfoReadPassword.get;
  MyBackupFileInfoReadPassword.Free;
end;

class function MyBackupPathInfoUtil.ReadPresetCopyCount(
  FilePath: string): Integer;
var
  MyBackupInfoReadPresetCopyCount : TMyBackupInfoReadPresetCopyCount;
begin
  MyBackupInfoReadPresetCopyCount := TMyBackupInfoReadPresetCopyCount.Create;
  MyBackupInfoReadPresetCopyCount.SetFilePath( FilePath );
  Result := MyBackupInfoReadPresetCopyCount.get;
  MyBackupInfoReadPresetCopyCount.Free;
end;

class function MyBackupPathInfoUtil.ReadRootPath(FilePath: string): string;
var
  MyBackupInfoReadRootPath : TMyBackupInfoReadRootPath;
begin
  MyBackupInfoReadRootPath := TMyBackupInfoReadRootPath.Create;
  MyBackupInfoReadRootPath.SetFilePath( FilePath );
  Result := MyBackupInfoReadRootPath.get;
  MyBackupInfoReadRootPath.Free;
end;

{ TMyBackupFileInfoReadBase }

constructor TMyBackupPathInfoReadBase.Create;
begin
  inherited;
  BackupPathList := MyBackupFileInfo.BackupPathList;
end;

{ TMyBackupFileInfoReadCompletedSpace }

function TMyBackupInfoReadCompletedSpace.get: Int64;
var
  i : Integer;
  p : TBackupPathCopyOwnerPair;
begin
  Result := 0;

  for i := 0 to BackupPathList.Count - 1 do
    for p in BackupPathList[i].BackupPathCopyOwnerHash do
      Result := Result + p.Value.OwnerSpace;
end;

{ TMyBackupFileInfoReadPassword }

function TMyBackupInfoReadPassword.get: string;
begin
  Result := '';
    // ������
  if not FindBackupPathInfo then
    Exit;
  Result := BackupPathInfo.Password;
end;

{ TMyBackupFileInfoPathRead }

function TMyBackupInfoPathRead.FindBackupPathInfo: Boolean;
begin
  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FilePath );
  Result := BackupPathInfo <> nil;
end;

procedure TMyBackupInfoPathRead.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TMyBackupFileInfoReadPresetCopyCount }

function TMyBackupInfoReadPresetCopyCount.get: Integer;
begin
  Result := 0;

    // ������
  if not FindBackupPathInfo then
    Exit;

  Result := BackupPathInfo.CopyCount;
end;

{ MyBackupFileInfoUtil }

class function MyBackupFileInfoUtil.ReadBackupCopyCount(
  BackupFileInfo: TBackupFileInfo): Integer;
var
  CopyInfoHash : TCopyInfoHash;
  p : TCopyInfoPair;
begin
  Result := 0;
  CopyInfoHash := BackupFileInfo.CopyInfoHash;
  for p in CopyInfoHash do
    if p.Value.CopyStatus = CopyStatus_Loaded then
      Inc( Result );
end;

class function MyBackupFileInfoUtil.ReadBackupFileInfo(
  FilePath: string): TBackupFileInfo;
var
  BackupPathInfo : TBackupPathInfo;
  RootFolderInfo, ParentFolder : TBackupFolderInfo;
  FileName, FolderPath : string;
begin
  Result := nil;

    // Ѱ�Ҹ�Ŀ¼
  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FilePath );
  if BackupPathInfo = nil then
    Exit;
  RootFolderInfo := BackupPathInfo.BackupFolderInfo;

    // ��Ŀ¼ �� �ļ���
  FolderPath := ExtractFileDir( FilePath );
  FileName := ExtractFileName( FilePath );

    // ����Ŀ¼ �� �ļ���Ŀ¼
  if FilePath = RootFolderInfo.FileName then
    ParentFolder := RootFolderInfo
  else
    ParentFolder := MyBackupFolderInfoUtil.ReadBackupFolderInfo( FolderPath );

    // ��Ŀ¼ ������
  if ParentFolder = nil then
    Exit;

    // ��Ŀ¼ �Ƿ�����ļ�
  if ParentFolder.BackupFileHash.ContainsKey( FileName ) then
    Result := ParentFolder.BackupFileHash[ FileName ];
end;

class function MyBackupFileInfoUtil.ReadBackupStatus(PresetCopyCount,
  CopyCount: Integer): string;
begin
  if CopyCount >= PresetCopyCount then
    Result := BackupStatus_Completed
  else
  if CopyCount = 0 then
    Result := BackupStatus_Incompleted
  else
    Result := BackupStatus_PartCompleted;
end;

class function MyBackupFileInfoUtil.ReadBackupStatusShow(
  PresetCopyCount: Integer; BackupFileInfo: TBackupFileInfo): string;
var
  CopyInfoHash : TCopyInfoHash;
  p : TCopyInfoPair;
  CopyStatus : string;
  CopyCount : Integer;
begin
  Result := '';
  CopyCount := 0;
  CopyInfoHash := BackupFileInfo.CopyInfoHash;
  for p in CopyInfoHash do
  begin
    CopyStatus := p.Value.CopyStatus;

      // ���ȼ� ��
    if CopyStatus = CopyStatus_Loading then
    begin
      Result := CopyStatus;
      Break;
    end;

      // ���ȼ� ��
    if CopyStatus = CopyStatus_Pending then
      Result := CopyStatus;

      // ���ȼ� ��
    if ( CopyStatus = CopyStatus_Offline ) and ( Result = '' ) then
      Result := CopyStatus;

      // ��ʾ ״̬
    if CopyStatus = CopyStatus_Loaded then
      Inc( CopyCount );
  end;

    // �Ѿ��ҵ�״̬
  if Result <> '' then
    Exit;

  Result := ReadBackupStatus( PresetCopyCount, CopyCount );
end;

class function MyBackupFileInfoUtil.ReadTempBackupFileBaseInfo(
  FilePath: string): TTempFileInfo;
var
  FindTempBackupFileBaseInfo : TFindTempBackupFileBaseInfo;
begin
  FindTempBackupFileBaseInfo := TFindTempBackupFileBaseInfo.Create;
  FindTempBackupFileBaseInfo.SetFilePath( FilePath );
  Result := FindTempBackupFileBaseInfo.get;
  FindTempBackupFileBaseInfo.Free;
end;

class function MyBackupFileInfoUtil.ReadTempBackupFileInfo(
  FilePath: string): TTempBackupFileInfo;
var
  FindTempBackupFileInfo : TFindTempBackupFileInfo;
begin
  FindTempBackupFileInfo := TFindTempBackupFileInfo.Create;
  FindTempBackupFileInfo.SetFilePath( FilePath );
  Result := FindTempBackupFileInfo.get;
  FindTempBackupFileInfo.Free;
end;

{ TMyBackupInfoReadIsEnable }

function TMyBackupInfoReadIsEnable.get: Boolean;
begin
  Result := False;

    // ������
  if not FindBackupPathInfo then
    Exit;

    // ·������ ���� Enable
  Result := not BackupPathInfo.IsDisable;
end;

{ TMyBackupInfoReadComsumpPcSpace }

function TMyBackupInfoReadComsumpPcSpace.get: Int64;
var
  i : Integer;
  p : TBackupPathCopyOwnerPair;
begin
  Result := 0;
  for i := 0 to BackupPathList.Count - 1 do
    for p in BackupPathList[i].BackupPathCopyOwnerHash do
      if p.Value.PcID = PcID then
        Result := Result + p.Value.OwnerSpace;
end;


procedure TMyBackupInfoReadComsumpPcSpace.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TMyBackupInfoReadIsRootPath }

function TMyBackupInfoReadIsRootPath.get: Boolean;
begin
  Result := BackupPathList.getPathIndex( FilePath ) <> -1;
end;

{ TBackupFolderCompletedSpaceChangeInfo }

procedure TBackupFolderAddCompletedSpaceInfo.Update;
var
  LastRootFolder : TBackupFolderInfo;
  LastPathInfo : TBackupPathInfo;
  PathTotalSpace : Int64;
begin
  inherited;

    // ������
  if not FindBackupFolderInfo then
    Exit;

    // �ݹ� ˢ�� ����ɿռ�
  while BackupFolderInfo <> nil do
  begin
    BackupFolderInfo.CompletedSpace := BackupFolderInfo.CompletedSpace + CompletedSpace;
    LastRootFolder := BackupFolderInfo;
    BackupFolderInfo := BackupFolderInfo.PaerntFolder;
  end;

    // ��Ŀ¼�����, ˢ������Ϣ
  if ( LastRootFolder <> nil ) and ( LastRootFolder.CompletedSpace >= LastRootFolder.FileSize ) then
  begin
    LastPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FolderPath );
    if LastPathInfo <> nil then
      PathTotalSpace := LastPathInfo.CopyCount * LastRootFolder.FileSize;
    if LastRootFolder.CompletedSpace = PathTotalSpace then
      MyClient.UpgradeCloudInfo;
  end;
end;


{ TBackupFolderCompletedSpaceChangeInfo }

procedure TBackupFolderCompletedSpaceChangeInfo.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupPathOwnerChangeInfo }

function TBackupPathOwnerChangeInfo.FindBackupPathOwnerHash: Boolean;
begin
  Result := FindBackupPathInfo;
  if not Result then
    Exit;
  BackupPathOwnerHash := BackupPathInfo.BackupPathCopyOwnerHash;
end;

{ TBackupFolderChangeInfo }

constructor TBackupFolderWriteInfo.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

function TBackupFolderWriteInfo.FindBackupFolderInfo: Boolean;
begin
  BackupFolderInfo := MyBackupFolderInfoUtil.ReadBackupFolderInfo( FolderPath );
  Result := BackupFolderInfo <> nil;
end;

{ TBackupFolderAddInfo }

procedure TBackupFolderAddInfo.AddBackupFolderInfo;
var
  ParentFolder, NewFolderInfo : TBackupFolderInfo;
  FolderHash : TBackupFolderInfoHash;
  FolderName, RemainPath : string;
  IsFindNext : Boolean;
begin
    // ��Ŀ¼
  if RootFolderInfo.FileName = FolderPath then
  begin
    BackupFolderInfo := RootFolderInfo;
    Exit;
  end;

    // �Ӹ�Ŀ¼����Ѱ��
  ParentFolder := RootFolderInfo;
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderInfo.FileName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // Ѱ����Ŀ¼
  begin
      // ��ȡ Ŀ¼��
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then  // ���һ��
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

      // ������ �򴴽�
    FolderHash := ParentFolder.BackupFolderHash;
    if not FolderHash.ContainsKey( FolderName ) then
    begin
      NewFolderInfo := TBackupFolderInfo.Create;
      NewFolderInfo.SetFileName( FolderName );
      FolderHash.AddOrSetValue( FolderName, NewFolderInfo );
      NewFolderInfo.PaerntFolder := ParentFolder;
    end;

      // ��һ��
    ParentFolder := FolderHash[ FolderName ];
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

    // �������һ�� Ŀ¼
  BackupFolderInfo := ParentFolder;
end;

function TBackupFolderAddInfo.FindRootFolderInfo: Boolean;
var
  BackupPathInfo : TBackupPathInfo;
begin
  Result := False;

  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FolderPath );
  if BackupPathInfo = nil then
    Exit;

    // ��Ѱ��Ŀ¼
  RootFolderInfo := BackupPathInfo.BackupFolderInfo;
  Result := True;
end;

procedure TBackupFolderAddInfo.SetFolderInfo(_FileTime: TDateTime;
  _FileCount: Integer);
begin
  FileTime := _FileTime;
  FileCount := _FileCount;
end;

procedure TBackupFolderAddInfo.SetSpaceInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupFolderAddInfo.Update;
begin
  inherited;

    // ������ ��Ŀ¼
  if not FindRootFolderInfo then
    Exit;

    // ����Ŀ¼
  AddBackupFolderInfo;

    // ����Ŀ¼��Ϣ
  BackupFolderInfo.SetFileInfo( FileSize, FileTime );
  BackupFolderInfo.SetFolderInfo( FileCount, CompletedSize );
end;

{ TBackupFolderRemoveInfo }

procedure TBackupFolderRemoveInfo.Update;
var
  FolderName : string;
begin
  inherited;

    // ������
  if not FindBackupFolderInfo then
    Exit;

    // ɾ��Ŀ¼
  FolderName := ExtractFileName( FolderPath );
  BackupFolderInfo.PaerntFolder.BackupFolderHash.Remove( FolderName );
end;

{ TBackupFileBaseInfo }

constructor TBackupFileBaseInfo.Create;
begin
  PaerntFolder := nil;
end;

{ TBackupPathScanFileInfo }

procedure TBackupPathScanInfo.AddFileConfirm;
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin
  BackupScanPathInfo := TBackupScanPathInfo.Create( BackupFileScanType_FileConfirm );
  MyBackupFileScanInfo.AddScanPathInfo( BackupScanPathInfo );
end;

constructor TBackupPathScanInfo.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupPathScanInfo.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathScanInfo.Update;
var
  BackupScanPathInfo : TBackupScanPathInfo;
begin
    // Disable
  if not MyBackupPathInfoUtil.ReadIsEnable( FullPath ) then
    Exit;

    // ���ɨ��·��
  BackupScanPathInfo := TBackupScanPathInfo.Create( FullPath );
  BackupScanPathInfo.SetIsShowFreeLimt( IsShowFreeLimt );
  MyBackupFileScanInfo.AddScanPathInfo( BackupScanPathInfo );

    // ��ʼ�ļ�ȷ��
  AddFileConfirm;
end;

{ TBackupFileCopyWriteInfo }

function TBackupFileCopyChangeInfo.FindBackupCopyHash: Boolean;
begin
  Result := False;

    // �ļ�������
  if not FindBackupFileInfo then
    Exit;

  BackupCopyHash := BackupFileInfo.CopyInfoHash;
  Result := True;
end;

{ TBackupFileCopyWriteInfo }

procedure TBackupFileCopyWriteInfo.AddBackupCopyInfo;
begin
    // ���
  if not BackupCopyHash.ContainsKey( CopyOwner ) then
  begin
    BackupCopyInfo := TCopyInfo.Create( CopyOwner );
    BackupCopyHash.AddOrSetValue( CopyOwner, BackupCopyInfo );
  end
  else
    BackupCopyInfo := BackupCopyHash[ CopyOwner ];
end;

function TBackupFileCopyWriteInfo.FindBackupCopyInfo: Boolean;
begin
  Result := False;
  if not FindBackupCopyHash then
    Exit;
  Result := BackupCopyHash.ContainsKey( CopyOwner );
  if Result then
    BackupCopyInfo := BackupCopyHash[ CopyOwner ];
end;

procedure TBackupFileCopyWriteInfo.SetCopyOwner(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

{ TBackupFileCopyAddInfo }

procedure TBackupFileCopyAddInfo.SetCopyStatus(_CopyStatus: string);
begin
  CopyStatus := _CopyStatus;
end;

procedure TBackupFileCopyAddInfo.Update;
begin
  inherited;

    // �ļ�������
  if not FindBackupCopyHash then
    Exit;

    // �������򴴽�
  AddBackupCopyInfo;
  BackupCopyInfo.CopyStatus := CopyStatus;
end;

{ TBackupFileCopyRemoveInfo }

procedure TBackupFileCopyRemoveInfo.Update;
begin
  inherited;

    // �ļ�������
  if not FindBackupCopyInfo then
    Exit;

    // ɾ��
  BackupCopyHash.Remove( CopyOwner );
end;

{ TBackupPathOwnerWriteInfo }

procedure TBackupPathOwnerWriteInfo.AddBackupPathOwner;
begin
  if not BackupPathOwnerHash.ContainsKey( PcID ) then
  begin
    BackupPathOwnerInfo := TBackupPathCopyOwner.Create( PcID );
    BackupPathOwnerHash.AddOrSetValue( PcID, BackupPathOwnerInfo );
  end
  else
    BackupPathOwnerInfo := BackupPathOwnerHash[ PcID ];
end;

function TBackupPathOwnerWriteInfo.FindBackupPathOwner: Boolean;
begin
  Result := False;
  if not FindBackupPathOwnerHash then
    Exit;

  Result := BackupPathOwnerHash.ContainsKey( PcID );
  if Result then
    BackupPathOwnerInfo := BackupPathOwnerHash[ PcID ];
end;

procedure TBackupPathOwnerWriteInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TBackupPathOwnerClearSpaceInfo }

procedure TBackupPathOwnerClearSpaceInfo.Update;
begin
  inherited;

    // ������ ·��
  if not FindBackupPathOwnerHash then
    Exit;

    // ���
  BackupPathOwnerHash.Clear;
end;

{ TBackupPathOwnerChangeSpaceInfo }

procedure TBackupPathOwnerChangeSpaceInfo.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TBackupPathOwnerAddSpaceInfo }

procedure TBackupPathOwnerAddSpaceInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindBackupPathOwnerHash then
      Exit;

    // ������ �����
  AddBackupPathOwner;

    // ���
  BackupPathOwnerInfo.OwnerSpace := BackupPathOwnerInfo.OwnerSpace + FileSize;
  BackupPathOwnerInfo.OwnerFileCount := BackupPathOwnerInfo.OwnerFileCount + FileCount;
end;

{ TBackupPathOwnerRemoveSpaceInfo }

procedure TBackupPathOwnerRemoveSpaceInfo.Update;
begin
  inherited;

    // ӵ���� ������
  if not FindBackupPathOwner then
    Exit;

    // ɾ��
  BackupPathOwnerInfo.OwnerSpace := BackupPathOwnerInfo.OwnerSpace - FileSize;
  BackupPathOwnerInfo.OwnerFileCount := BackupPathOwnerInfo.OwnerFileCount - FileCount;

    // ӵ���� û�� ���ݱ���
  if ( BackupPathOwnerInfo.OwnerSpace <= 0 ) and
     ( BackupPathOwnerInfo.OwnerFileCount <= 0 )
  then
    BackupPathOwnerHash.Remove( PcID );
end;

{ TBackupPathOwnerSetSpaceInfo }

procedure TBackupPathOwnerSetSpaceInfo.Update;
begin
  inherited;

    // ·�� ������
  if not FindBackupPathOwnerHash then
      Exit;

    // ������ �����
  AddBackupPathOwner;

    // ���
  BackupPathOwnerInfo.OwnerSpace := FileSize;
  BackupPathOwnerInfo.OwnerFileCount := FileCount;
end;


{ TBackupPathCopyOwner }

constructor TBackupPathCopyOwner.Create(_PcID: string);
begin
  PcID := _PcID;
  OwnerSpace := 0;
  OwnerFileCount := 0;
end;

{ TMyBackupInfoReadRootPath }

function TMyBackupInfoReadRootPath.get: string;
begin
  Result := '';

      // ������
  if not FindBackupPathInfo then
    Exit;

  Result := BackupPathInfo.FullPath;
end;

{ TBackupPathSetCompletedSpaceInfo }

procedure TBackupPathSetCompletedSpaceInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.CompletedSpace := CompletedSpace;
end;

{ TBackupPathCompletedSpaceChangeInfo }

procedure TBackupPathCompletedSpaceChangeInfo.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupPathAddCompletedSpaceInfo }

procedure TBackupPathAddCompletedSpaceInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.CompletedSpace := BackupPathInfo.CompletedSpace + CompletedSpace;
end;

{ TBackupPathRemoveCompletedSpaceInfo }

procedure TBackupPathRemoveCompletedSpaceInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.CompletedSpace := BackupPathInfo.CompletedSpace - CompletedSpace;
end;

{ TBackupFolderRemoveCompletedSpaceInfo }

procedure TBackupFolderRemoveCompletedSpaceInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupFolderInfo then
    Exit;

    // �ݹ� ˢ�� ����ɿռ�
  while BackupFolderInfo <> nil do
  begin
    BackupFolderInfo.CompletedSpace := BackupFolderInfo.CompletedSpace - CompletedSpace;
    BackupFolderInfo := BackupFolderInfo.PaerntFolder;
  end;
end;

{ TBackupFolderCopyRemoveInfo }

procedure TBackupFolderCopyRemoveInfo.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TBackupFolderCopyRemoveInfo.Update;
var
  ParentPath : string;
  BackupFolderCopyRemoveHandle : TBackupFolderCopyRemoveHandle;
begin
  inherited;

    // Ŀ¼ ������
  if not FindBackupFolderInfo then
    Exit;

  if FolderPath = BackupFolderInfo.FileName then
    ParentPath := ''
  else
    ParentPath := ExtractFileDir( FolderPath );

    // �ݹ� ɾ�� ӵ����
  BackupFolderCopyRemoveHandle := TBackupFolderCopyRemoveHandle.Create( BackupFolderInfo );
  BackupFolderCopyRemoveHandle.SetCopyOwner( PcID );
  BackupFolderCopyRemoveHandle.SetParentPath( ParentPath );
  BackupFolderCopyRemoveHandle.Update;
  BackupFolderCopyRemoveHandle.Free;
end;

{ MyBackupFolderInfoUtil }

class function MyBackupFolderInfoUtil.ReadBackupFolderInfo(
  FolderPath: string): TBackupFolderInfo;
var
  BackupPathInfo : TBackupPathInfo;
  RootFolderInfo, ParentFolder : TBackupFolderInfo;
  FolderName, RemainPath : string;
  IsFindNext : Boolean;
begin
  Result := nil;

    // Ѱ�� ��Ŀ¼
  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FolderPath );
  if BackupPathInfo = nil then
    Exit;
  RootFolderInfo := BackupPathInfo.BackupFolderInfo;

     // �ҵ���Ŀ¼
  if FolderPath = RootFolderInfo.FileName then
  begin
    Result := RootFolderInfo;
    Exit;
  end;

    // �Ӹ�Ŀ¼����Ѱ��
  ParentFolder := RootFolderInfo;
  RemainPath := MyString.CutStartStr( MyFilePath.getPath( RootFolderInfo.FileName ), FolderPath );
  IsFindNext := True;
  while IsFindNext do             // Ѱ����Ŀ¼
  begin
    FolderName := MyString.GetRootFolder( RemainPath );
    if FolderName = '' then
    begin
      FolderName := RemainPath;
      IsFindNext := False;
    end;

      // ������Ŀ¼
    if not ParentFolder.BackupFolderHash.ContainsKey( FolderName ) then
      Exit;

      // ��һ��
    ParentFolder := ParentFolder.BackupFolderHash[ FolderName ];
    RemainPath := MyString.CutRootFolder( RemainPath );
  end;

    // �������һ�� Ŀ¼
  Result := ParentFolder;
end;

class function MyBackupFolderInfoUtil.ReadCompletedSpace(
  FolderPath: string): Int64;
var
  MyBackupFolderReadCompletedSpace : TMyBackupFolderReadCompletedSpace;
begin
  MyBackupFolderReadCompletedSpace := TMyBackupFolderReadCompletedSpace.Create;
  MyBackupFolderReadCompletedSpace.SetFolderPath( FolderPath );
  Result := MyBackupFolderReadCompletedSpace.get;
  MyBackupFolderReadCompletedSpace.Free;
end;

class function MyBackupFolderInfoUtil.ReadTempBackupFolderBaseInfo(
  FolderPath: string): TTempFolderInfo;
var
  FindTempBackFolderBaseInfo : TFindTempBackFolderBaseInfo;
begin
  FindTempBackFolderBaseInfo := TFindTempBackFolderBaseInfo.Create;
  FindTempBackFolderBaseInfo.SetFolderPath( FolderPath );
  Result := FindTempBackFolderBaseInfo.get;
  FindTempBackFolderBaseInfo.Free;
end;

class function MyBackupFolderInfoUtil.ReadTempBackupFolderInfo(
  FolderPath: string): TTempBackupFolderInfo;
var
  FindTempBackupFolderInfo : TFindTempBackupFolderInfo;
begin
  FindTempBackupFolderInfo := TFindTempBackupFolderInfo.Create;
  FindTempBackupFolderInfo.SetFolderPath( FolderPath );
  Result := FindTempBackupFolderInfo.get;
  FindTempBackupFolderInfo.Free;
end;

{ TMyBackupInfoReadBase }

constructor TMyBackupInfoReadBase.Create;
begin
  MyBackupFileInfo.EnterData;
end;

destructor TMyBackupInfoReadBase.Destroy;
begin
  MyBackupFileInfo.LeaveData;
  inherited;
end;

{ TMyBackupFolderReadInfo }

function TMyBackupFolderReadInfo.FindBackupFolderInfo: Boolean;
begin
  BackupFolderInfo := MyBackupFolderInfoUtil.ReadBackupFolderInfo( FolderPath );
  Result := BackupFolderInfo <> nil;
end;

procedure TMyBackupFolderReadInfo.SetFolderPath(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

{ TMyBackupFolderReadCompletedSpace }

function TMyBackupFolderReadCompletedSpace.get: Int64;
begin
  Result := 0;

    // Ŀ¼������
  if not FindBackupFolderInfo then
    Exit;

  Result := BackupFolderInfo.CompletedSpace;
end;

{ TBackupFolderRemoveNotify }

procedure TBackupFolderRemoveNotifyInfo.AddToRemoveNotify(PcID: string);
var
  BackupRemoveNofityAddHandle : TBackupRemoveNotifyAddHandle;
begin
  BackupRemoveNofityAddHandle := TBackupRemoveNotifyAddHandle.Create( PcID );
  BackupRemoveNofityAddHandle.SetFullPath( FolderPath );
  BackupRemoveNofityAddHandle.Update;
  BackupRemoveNofityAddHandle.Free;
end;

procedure TBackupFolderRemoveNotifyInfo.Update;
var
  BackupPathInfo : TBackupPathInfo;
  BackupPathOwnerHash : TBackupPathCopyOwnerHash;
  p : TBackupPathCopyOwnerPair;
begin
  inherited;

    // ��ȡ ��·��
  BackupPathInfo := MyBackupPathInfoUtil.ReadBackupPathInfo( FolderPath );

    // ��·�� ������
  if BackupPathInfo = nil then
    Exit;

    // ֪ͨ���б���·��ӵ���� ɾ��Ŀ¼
  BackupPathOwnerHash := BackupPathInfo.BackupPathCopyOwnerHash;
  for p in BackupPathOwnerHash do
    AddToRemoveNotify( p.Value.PcID );
end;

{ TBackupPathRemoveNotifyInfo }

procedure TBackupPathRemoveNotifyInfo.RemoveFile;
var
  BackupFileRemoveNotifyInfo : TBackupFileRemoveNotifyInfo;
begin
  BackupFileRemoveNotifyInfo := TBackupFileRemoveNotifyInfo.Create( FullPath );
  BackupFileRemoveNotifyInfo.Update;
  BackupFileRemoveNotifyInfo.Free;
end;

procedure TBackupPathRemoveNotifyInfo.RemoveFolder;
var
  BackupFolderRemoveNotifyInfo : TBackupFolderRemoveNotifyInfo;
begin
  BackupFolderRemoveNotifyInfo := TBackupFolderRemoveNotifyInfo.Create( FullPath );
  BackupFolderRemoveNotifyInfo.Update;
  BackupFolderRemoveNotifyInfo.Free;
end;

procedure TBackupPathRemoveNotifyInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

    // �ֱ�ɾ��
  if BackupPathInfo.PathType = PathType_File then
    RemoveFile
  else
    RemoveFolder;
end;

{ TMyBackupFileInfoRead }

function TMyBackupFileInfoRead.FindBackupFileInfo: Boolean;
begin
  BackupFileInfo := MyBackupFileInfoUtil.ReadBackupFileInfo( FilePath );
  Result := BackupFileInfo <> nil;
end;

procedure TMyBackupFileInfoRead.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TFindTempBackupFileBaseInfo }

function TFindTempBackupFileBaseInfo.get: TTempFileInfo;
begin
  Result := nil;

    // �ļ�������
  if not FindBackupFileInfo then
    Exit;

    // ������Ϣ
  Result := TTempFileInfo.Create;
  Result.SetFileBaseInfo( BackupFileInfo );
end;

{ TMyBackupInfoReadAllBackupPathHash }

function TMyBackupInfoReadAllBackupPathList.get: TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to BackupPathList.Count - 1 do
    Result.Add( BackupPathList[i].FullPath );
end;

{ TBackupPathSyncAllInfo }

procedure TBackupPathSyncAllInfo.AddScanJob(Path: string);
var
  BackupPathSyncInfo : TBackupPathSyncInfo;
begin
  BackupPathSyncInfo := TBackupPathSyncInfo.Create( Path );
  BackupPathSyncInfo.SetIsShowFreeLimt( False );
  BackupPathSyncInfo.Update;
  BackupPathSyncInfo.Free;
end;

procedure TBackupPathSyncAllInfo.Update;
var
  i : Integer;
begin
  inherited;

  for i := 0 to BackupPathList.Count - 1 do
  begin
      // Disable
    if BackupPathList[i].IsDisable then
      Continue;

      // ���� Job
    AddScanJob( BackupPathList[i].FullPath );
  end;
end;

{ TBackupPathIncludeFilterChangeInfo }

function TBackupPathIncludeFilterChangeInfo.FindIncludeFilterList: Boolean;
begin
  Result := False;
  if not FindBackupPathInfo then
    Exit;

  IncludeFilterList := BackupPathInfo.IncludeFilterList;
  Result := True;
end;

{ TBackupPathExcludeFilterChangeInfo }

function TBackupPathExcludeFilterChangeInfo.FindExcludeFilterList: Boolean;
begin
  Result := False;
  if not FindBackupPathInfo then
    Exit;

  ExcludeFilterList := BackupPathInfo.ExcludeFilterList;
  Result := True;
end;


{ TBackupPathIncludeFilterClearInfo }

procedure TBackupPathIncludeFilterClearInfo.Update;
begin
  inherited;

    // ������
  if not FindIncludeFilterList then
    Exit;

    // ���
  IncludeFilterList.Clear;
end;

{ TBackupPathExcludeFilterClearInfo }

procedure TBackupPathExcludeFilterClearInfo.Update;
begin
  inherited;

    // ������
  if not FindExcludeFilterList then
    Exit;

    // ���
  ExcludeFilterList.Clear;
end;

{ TBackupPathIncludeFilterAddInfo }

procedure TBackupPathIncludeFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TBackupPathIncludeFilterAddInfo.Update;
var
  FilterInfo : TBackupFileFilterInfo;
begin
  inherited;

    // ������
  if not FindIncludeFilterList then
    Exit;

    // ���
  FilterInfo := TBackupFileFilterInfo.Create( FilterType, FilterStr );
  IncludeFilterList.Add( FilterInfo );
end;

{ TBackupPathExcludeFilterAddInfo }

procedure TBackupPathExcludeFilterAddInfo.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

procedure TBackupPathExcludeFilterAddInfo.Update;
var
  FilterInfo : TBackupFileFilterInfo;
begin
  inherited;

    // ������
  if not FindExcludeFilterList then
    Exit;

    // ���
  FilterInfo := TBackupFileFilterInfo.Create( FilterType, FilterStr );
  ExcludeFilterList.Add( FilterInfo );
end;


{ TBackupPathSetLastSyncTimeInfo }

procedure TBackupPathSetLastSyncTimeInfo.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathSetLastSyncTimeInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupPathInfo then
    Exit;


  BackupPathInfo.LasSyncTime := LastSyncTime;
end;

{ TBackupPathSetSyncMinsInfo }

procedure TBackupPathSetSyncMinsInfo.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupPathSetSyncMinsInfo.SetSyncInterval( _SyncTimeType,
  _SyncTimeValue: Integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathSetSyncMinsInfo.Update;
begin
  inherited;

    // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.IsAutoSync := IsAutoSync;
  BackupPathInfo.SyncTimeType := SyncTimeType;
  BackupPathInfo.SyncTimeValue := SyncTimeValue;
end;

{ TBackupPathIsDisableInfo }

procedure TBackupPathIsDisableInfo.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupPathIsDisableInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.IsDisable := IsDisable;
end;


{ TBackupPathIsBackupNowInfo }

procedure TBackupPathIsBackupNowInfo.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathIsBackupNowInfo.Update;
begin
  inherited;

      // ������
  if not FindBackupPathInfo then
    Exit;

  BackupPathInfo.IsBackupNow := IsBackupNow;
end;


{ TMyBackupInfoReadConfig }

function TMyBackupInfoReadConfig.get: TBackupConfigInfo;
var
  FilterList : TFileFilterList;
begin
  Result := nil;

  if not FindBackupPathInfo then
    Exit;

  Result := TBackupConfigInfo.Create;
  Result.SetCopyCount( BackupPathInfo.CopyCount );
  Result.SetSyncInfo( BackupPathInfo.IsAutoSync, BackupPathInfo.SyncTimeType, BackupPathInfo.SyncTimeValue );
  Result.SetBackupInfo( BackupPathInfo.IsBackupNow, BackupPathInfo.IsDisable );
  Result.SetEncryptInfo( BackupPathInfo.IsEncrypt, BackupPathInfo.Password, BackupPathInfo.PasswordHint );
  Result.SetIncludeFilterList( getFilterList( BackupPathInfo.IncludeFilterList ) );
  Result.SetExcludeFilterList( getFilterList( BackupPathInfo.ExcludeFilterList ) );
end;

function TMyBackupInfoReadConfig.getFilterList(
  BackupFilterList: TBackupFileFilterList): TFileFilterList;
var
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;
  for i := 0 to BackupFilterList.Count - 1 do
  begin
    FilterType := BackupFilterList[i].FilterType;
    FilterStr := BackupFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TMyBackupInfoReadIncludeFilter }

function TMyBackupInfoReadIncludeFilter.get: TFileFilterList;
var
  IncludeFilterList : TBackupFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;

      // ������
  if not FindBackupPathInfo then
    Exit;

  IncludeFilterList := BackupPathInfo.IncludeFilterList;
  for i := 0 to IncludeFilterList.Count - 1 do
  begin
    FilterType := IncludeFilterList[i].FilterType;
    FilterStr := IncludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TMyBackupInfoReadExcludeFilter }

function TMyBackupInfoReadExcludeFilter.get: TFileFilterList;
var
  ExcludeFilterList : TBackupFileFilterList;
  i : Integer;
  FilterType, FilterStr : string;
  FileFilterInfo : TFileFilterInfo;
begin
  Result := TFileFilterList.Create;

      // ������
  if not FindBackupPathInfo then
    Exit;

  ExcludeFilterList := BackupPathInfo.ExcludeFilterList;
  for i := 0 to ExcludeFilterList.Count - 1 do
  begin
    FilterType := ExcludeFilterList[i].FilterType;
    FilterStr := ExcludeFilterList[i].FilterStr;
    FileFilterInfo := TFileFilterInfo.Create( FilterType, FilterStr );
    Result.Add( FileFilterInfo );
  end;
end;

{ TMyBackupInfoReadIsAutoSyncTimeOut }

function TMyBackupInfoReadIsAutoSyncTimeOut.get: Boolean;
var
  SyncMins : Integer;
begin
  Result := False;

  if not FindBackupPathInfo then
    Exit;

  SyncMins := TimeTypeUtil.getMins( BackupPathInfo.SyncTimeType, BackupPathInfo.SyncTimeValue );
  Result := Now >= IncMinute( BackupPathInfo.LasSyncTime, SyncMins );
end;

{ TBackupPathList }

function TBackupPathList.getPath(FullPath: string): TBackupPathInfo;
var
  SelectIndex : Integer;
begin
  SelectIndex := getPathIndex( FullPath );
  if SelectIndex = -1 then
    Result := nil
  else
    Result := Self[SelectIndex];
end;

function TBackupPathList.getPathIndex(FullPath: string): Integer;
var
  i : Integer;
begin
  Result := -1;

  for i := 0 to Self.Count - 1 do
    if Self[i].FullPath = FullPath then
    begin
      Result := i;
      Break;
    end;
end;

procedure TBackupPathList.RemovePath(FullPath: string);
var
  SelectIndex : Integer;
begin
  SelectIndex := getPathIndex( FullPath );
  if SelectIndex = -1 then
    Exit;
  Self.Delete( SelectIndex );
end;

{ TBackupPathRemoveOfflineJobInfo }

procedure TBackupPathRemoveOfflineJobInfo.Update;
var
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
  TransferJobOnlineInfo.SetOnlinePcID( '' );
  TransferJobOnlineInfo.SetJobType( JobType_Backup );
  MyJobInfo.AddChange( TransferJobOnlineInfo );
end;

end.
