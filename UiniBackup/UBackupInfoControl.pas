unit UBackupInfoControl;

interface

uses Classes, Generics.Collections, SyncObjs, Windows, UModelUtil, SysUtils, UMyUtil,
     VirtualTrees, Math, uDebug, UFileBaseInfo;

type

{$Region ' ����·�� Control ' }

    // �޸� ����·�� ����
  TBackupPathChangeHandle = class
  protected
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ��ȡ ����·��
  TBackupPathReadHandle = class( TBackupPathChangeHandle )
  protected
    PathType : string;
    IsDisable, IsBackupNow : Boolean;
    CopyCount : Integer;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    FileCount : Integer;
    FolderSpace, CompletedSpace : Int64;
  public
    procedure SetPathInfo( _PathType : string );
    procedure SetBackupInfo( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LastSyncTime : TDateTime );
    procedure SetSyncInternalInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _Password, _PasswordHint : string );
    procedure SetCountInfo( _CopyCount, _FileCount : Integer );
    procedure SetSpaceInfo( _FolderSpace, _CompletedSpace : Int64 );
    procedure Update;virtual;
  protected
    procedure AddToInfo;   // д ����
    procedure AddToFace;  // д ����
  end;

    // ��� ����·��
  TBackupPathAddHandle = class( TBackupPathReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;   // дxml����
  end;

    // �޸� ����·�� Copy ��
  TBackupPathSetCopyCount = class( TBackupPathChangeHandle )
  private
    CopyCount : Integer;
  public
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
    procedure SetToFace;
  private
    procedure SyncFileNow;
  end;

    // ���� ����·�� �ܿռ���Ϣ
  TBackupPathSetSpaceHandle = class( TBackupPathChangeHandle )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

      // ˢ�� ѡ��ı��ݽڵ���Ϣ
  TBackupSelectRefreshHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure RefreshFace;
  end;

  {$Region ' ����״̬ ' }

    // ���� ����·���Ƿ����
  TBackupPathSetExistHandle = class( TBackupPathChangeHandle )
  private
    IsExist : Boolean;
  public
    procedure SetIsExist( _IsExist : Boolean );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // ���� ����·�� �Ƿ��ֹ����
  TBackupPathSetIsDisableHandle = class( TBackupPathChangeHandle )
  private
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ���� ����·�� �Ƿ񲻲���BackupUpNow
  TBackupPathSetIsBackupNowHandle = class( TBackupPathChangeHandle )
  private
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

    // ���� ����·��״̬
  TBackupPathSetStatusHandle = class( TBackupPathChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // ���� ����·���Ƿ����㹻�Ŀռ�
  TBackupPathSetIsNotEnoughPcHandle = class( TBackupPathChangeHandle )
  public
    IsNotEnoughPc : Boolean;
  public
    procedure SetIsNotEnoughPc( _IsNotEnoughPc : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure RefreshNotEnough;
  end;

  {$EndRegion}

  {$Region ' ����ͬ��ʱ�� ' }

    // ��һ�� ͬ��ʱ��
  TBackupPathSetLastSyncTimeHandle = class( TBackupPathChangeHandle )
  public
    LastSyncTime : TDateTime;
  public
    procedure SetLastSyncTime( _LastSyncTime : TDateTime );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ͬ�����
  TBackupPathSetAutoSyncHandle = class( TBackupPathChangeHandle )
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
  public
    procedure SetIsAutoSync( _IsAutoSync : Boolean );
    procedure SetSyncInterval( _SyncTimeType, _SyncTimeValue : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ˢ�� ��һ�� ͬ��ʱ��
  TBackupPathRefreshLastSyncTimeHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' ɨ����ͬ�� ' }

    // ɨ�� ָ��·��
  TBackupPathScanHandle = class( TBackupPathChangeHandle )
  public
    IsShowFreeLimt : Boolean;
  public
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // ɨ�� ����·��
  TBackupPathScanAllHandle = class
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // ͬ�� ָ��·��
  TBackupPathSyncHandle = class( TBackupPathChangeHandle )
  public
    IsShowFreeLimt : Boolean;
  public
    procedure SetIsShowFreeLimt( _IsShowFreeLimt : Boolean );
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // ͬ�� ����·��
  TBackupPathSyncAllHandle = class
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

  {$EndRegion}

  {$Region ' �޸� ����ɿռ� ��Ϣ ' }

    // �޸�
  TBackupPathChangeCompletedSpaceHandle = class( TBackupPathChangeHandle )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ���
  TBackupPathAddCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToXml;
  end;

    // ɾ��
  TBackupPathRemoveCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

    // ����
  TBackupPathSetCompletedSpaceHandle = class( TBackupPathChangeCompletedSpaceHandle )
  public
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

  {$EndRegion}

      // �Ƴ� ����·��
  TBackupPathRemoveHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveBackupNotify;
    procedure RemoveBackupOffline;
  private  // ɾ�� ������Ϣ
    procedure RemoveBackupInfo;
    procedure RemoveBackupXml;
    procedure RemoveFromFace;
  end;

{$EndRegion}

{$Region ' ����·��ӵ���� Control ' }

    // ���
  TBackupPathOwnerClearHandle = class( TBackupPathChangeHandle )
  public
    procedure Update;
  private
    procedure ClearFromInfo;
    procedure ClearFromXml;
  end;

    // ����
  TBackupPathOwnerChangeHandle = class( TBackupPathChangeHandle )
  public
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
  end;

    // �޸� �ռ�
  TBackupPathOwnerChangeSpaceHandle = class( TBackupPathOwnerChangeHandle )
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
  end;

    // ��� �ռ�
  TBackupPathOwnerAddSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;

    // ɾ�� �ռ�
  TBackupPathOwnerRemoveSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // ��ȡ �ռ�
  TBackupPathOwnerReadSpaceHandle = class( TBackupPathOwnerChangeSpaceHandle )
  public
    procedure Update;virtual;
  private
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // ����
  TBackupPathOwnerSetSpaceHandle = class( TBackupPathOwnerReadSpaceHandle )
  public
    procedure Update;override;
  private
    procedure SetToXml;
  end;

{$EndRegion}

{$Region ' ����·�������� Control ' }

    // ����
  TBackupPathFilterChangeHandle = class( TBackupPathChangeHandle )
  end;

      // ��� ������ ����
  TBackupPathFilterWriteHandle = class( TBackupPathFilterChangeHandle )
  public
    FilterType, FilterStr : string;
  public
    procedure SetFilterInfo( _FilterType, _FilterStr : string );
  end;

  {$Region ' �޸� ���� ������ ' }

    // ���
  TBackupPathIncludeFilterClearHandle = class( TBackupPathFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // ��ȡ ���� ������
  TBackupPathIncludeFilterReadHandle = class( TBackupPathFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // ��� ���� ������
  TBackupPathIncludeFilterAddHandle = class( TBackupPathIncludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

  {$Region ' �޸� �ų� ������ ' }

      // ���
  TBackupPathExcludeFilterClearHandle = class( TBackupPathFilterChangeHandle )
  public
    procedure Update;
  public
    procedure ClearToInfo;
    procedure ClearToXml;
  end;

    // ��ȡ �ų� ������
  TBackupPathExcludeFilterReadHandle = class( TBackupPathFilterWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // ��� �ų� ������
  TBackupPathExcludeFilterAddHandle = class( TBackupPathExcludeFilterReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ����Ŀ¼ Control ' }

    // ����
  TBackupFolderChangeHandle = class
  protected
    FolderPath : string;
  public
    constructor Create( _FolderPath : string );
  end;

    // ��ȡ Ŀ¼
  TBackupFolderReadHandle = class( TBackupFolderChangeHandle )
  public
    FileSize, CompletedSpace : Int64;
    FileTime : TDateTime;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize, _CompletedSpace : Int64 );
    procedure SetFolderInfo( _FileTime : TDateTime; _FileCount : Integer );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ��� Ŀ¼
  TBackupFolderAddHandle = class( TBackupFolderReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

     // ���� ����Ŀ¼ �ܿռ�
  TBackupFolderSetSpaceHandle = class( TBackupFolderChangeHandle )
  private
    FileSize : Int64;
    FileCount : Integer;
  public
    procedure SetSpaceInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

  {$Region ' �޸� ����ɿռ� ��Ϣ ' }

    // ���� ����Ŀ¼ ����ɿռ�
  TBackupFolderChangeCompletedSpaceHanlde = class( TBackupFolderChangeHandle )
  public
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
  end;

    // ���� ����Ŀ¼ ����ɿռ�
  TBackupFolderSetCompletedSpaceHanlde = class( TBackupFolderChangeCompletedSpaceHanlde )
  private
    LastCompletedSpace : Int64;
  public
    procedure SetLastCompletedSpace( _LastCompletedSpace : Int64 );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ��� ����Ŀ¼ ����ɿռ�
  TBackupFolderAddCompletedSpaceHandle = class( TBackupFolderSetCompletedSpaceHanlde )
  public
    procedure Update;
  private
    procedure AddToInfo;
    procedure AddToFace;
    procedure AddToXml;
  end;

    // ɾ�� ����Ŀ¼ ����ɿռ�
  TBackupFolderRemoveCompletedSpaceHandle = class( TBackupFolderSetCompletedSpaceHanlde )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromToXml;
  end;

  {$EndRegion}

    // ���� Ŀ¼ ״̬
  TBackupFolderSetStatusHandle = class( TBackupFolderChangeHandle )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // ɾ�� Ŀ¼
  TBackupFolderRemoveHandle = class( TBackupFolderChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromNotify;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
    procedure RemoveFromFace;
  end;


{$EndRegion}

{$Region ' �����ļ� Control ' }

    // ����
  TBackupFileChangeHandle = class
  protected
    FilePath : string;
  public
    constructor Create( _FilePath : string );
  end;

    // ��ȡ �����ļ�
  TBackupFileReadHandle = class( TBackupFileChangeHandle )
  protected
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // ��� �����ļ�
  TBackupFileAddHandle = class( TBackupFileReadHandle )
  public
    procedure Update;override;
  private
    procedure AddBackupXml;
  end;

    // ͬ�� �����ļ�
  TBackupFileSyncHandle = class( TBackupFileChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

      // ɾ�� �����ļ�
  TBackupFileRemoveHandle = class( TBackupFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromNotify;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' �����ļ����� Control ' }

    // �޸� ���ݸ�����Ϣ
  TBackupCopyChangeHandle = class( TBackupFileChangeHandle )
  public
    CopyOwner : string;
  public
    procedure SetCopyOwner( _CopyOwner : string );
  protected
    procedure RefreshFace;
  end;

    // ��� Pending ����
  TBackupCopyAddPendHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // ��� Loading ����
  TBackupCopyAddLoadingHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure AddToInfo;
  end;

    // ��ȡ Offline ����
  TBackupCopyReadOfflineHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
  end;

    // ��� Offline ����
  TBackupCopyAddOfflineHandle = class( TBackupCopyReadOfflineHandle )
  private
    Position : Int64;
  public
    procedure SetPosition( _Position : Int64 );
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ��ȡ Loaded ����
  TBackupCopyReadLoadedHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // ��� Loaded ����
  TBackupCopyAddLoadedHandle = class( TBackupCopyReadLoadedHandle )
  public
    procedure Update;override;
  protected
    procedure AddToXml;
  end;

    // ɾ�� ���ݸ�����Ϣ
  TBackupCopyRemoveHandle = class( TBackupCopyChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

{$EndRegion}

{$Region ' Total Control ' }

  TBackupCopyChangeControl = class
  public
    FilePath, PcID : string;
    FileSize : Int64;
  private
    RootBackupPath : string;
  public
    constructor Create( _FilePath, _PcID : string );
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;virtual;
  end;

    // ��� ���� Copy
  TBackupCopyAddControl = class( TBackupCopyChangeControl )
  public
    procedure Update;override;
  private
    procedure AddBackupCopy; // ����ļ� Copy
    procedure AddBackupPathCopy; // ���·�� Copy
  private
    procedure AddBackupFolderCompletedSpace;  // ����Ŀ¼ ����ɿռ�
    procedure AddBackupPathCompletedSpace;  // ����·�� ����ɿռ�
  end;

    // ɾ�� ���� Copy
  TBackupCopyRemoveControl = class( TBackupCopyChangeControl )
  public
    procedure Update;override;
  private       // �Ƴ�������Ϣ
    procedure RemoveBackupCopy;
    procedure RemoveBackupPathCopy;
  private
    procedure RemoveBackupFolderCompletedSpace;  // �����ļ� ����ɿռ�
    procedure RemoveBackupPathCompletedSpace;  // ����·�� ����ɿռ�
  private       // ����ͬ�����ļ�
    procedure SyncFileNow;
  end;

    // ȡ������ĳĿ¼
  TBackupFolderCancelBackupControl = class
  public
    FolderPath : string;
  public
    constructor Create( _FolderPath : string );
    procedure Update;
  private
    procedure AddToExcludeFilter;
    procedure RemoveFolder;
  end;

    // ȡ������ĳ�ļ�
  TBackupFileCancelBackupControl = class
  public
    FilePath : string;
  public
    constructor Create( _FilePath : string );
    procedure Update;
  private
    procedure AddToExcludeFilter;
    procedure RemoveFile;
  end;

{$EndRegion}

{$Region ' Control Util ' }

    // ��� ����·��
  TBackupPathAddControl = class
  public
    FullPath, PathType : string;
    IsDisable, IsBackupNow : Boolean;
    CopyCount : Integer;
  public
    IsAutoSync : Boolean;
    SyncTimeType, SyncTimeValue : Integer;
    LastSyncTime : TDateTime;
  public
    IsEncrypt : Boolean;
    Password, PasswordHint : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ��� ����·�� Ĭ������
  TBackupPathAddDefaultControl = class( TBackupPathAddControl )
  public
    procedure Update;
  private
    procedure FindGenernalInfo;
    procedure FindEncryptInfo;
  private
    procedure AddBackupPath;
    procedure AddBackupFilter;
    procedure BackupPathNow;
  end;

    // ��� ����·�� ָ������
  TBackupPathAddConfigControl = class( TBackupPathAddControl )
  private
    BackupConfigInfo : TBackupConfigInfo;
    IncludeFileFilterList : TFileFilterList;
    ExcludeFileFilterList : TFileFilterList;
  public
    procedure SetBackupConfigInfo( _BackupConfigInfo : TBackupConfigInfo );
    procedure Update;
  private
    procedure FindGenernalInfo;
    procedure FindEncryptInfo;
    procedure FindFilterInfo;
  private
    procedure AddBackupPath;
    procedure AddBackupFilter;
    procedure BackupPathNow;
  private
    function IsPathFilter( FilterInfo : TFileFilterInfo ): Boolean;
  end;

{$EndRegion}

    // ����·���仯������
  TMyBackupFileControl = class
  public        // ����·�� ����
    procedure AddBackupPath( FullPath : string );overload;
    procedure AddBackupPath( FullPath : string; BackupConfigInfo : TBackupConfigInfo );overload;
    procedure RemoveBackupPath( FullPath : string );
  public        // �����ļ�/Ŀ¼ ����
    procedure ShowBackupFileStatus( FullPath : string );
    procedure ShowBackupFileStatusNomal( FullPath : string );
    procedure ShowBackupFileDetail( FullPath : string );
    procedure FolderCancelBackup( FolderPath : string );
    procedure FileCancelBackup( FilePath : string );
  public        // ɨ�豸��·��
    procedure BackupNow;
    procedure BackupSelectFolder( FolderPath : string );
  public        // ͬ������·��
    procedure PcOnlineSync;
  end;

const
    // ȷ���ļ�
  BackupFileScanType_FileConfirm = 'FileConfirm';

var
  MyBackupFileControl : TMyBackupFileControl;

implementation

uses UMainForm, UMyBackupInfo, UBackupFileScan,UBackupInfoFace, UBackupInfoXml, UBackupUtil,
     USettingInfo, UMyNetPcInfo, UNetPcInfoXml, UNetworkFace, UMyJobInfo;

{ TBackupPathControl }


procedure TMyBackupFileControl.AddBackupPath(FullPath: string);
var
  BackupPathAddDefaultControl : TBackupPathAddDefaultControl;
begin
  BackupPathAddDefaultControl := TBackupPathAddDefaultControl.Create( FullPath );
  BackupPathAddDefaultControl.Update;
  BackupPathAddDefaultControl.Free;
end;


procedure TMyBackupFileControl.AddBackupPath(FullPath: string;
  BackupConfigInfo: TBackupConfigInfo);
var
  BackupPathAddConfigControl : TBackupPathAddConfigControl;
begin
  BackupPathAddConfigControl := TBackupPathAddConfigControl.Create( FullPath );
  BackupPathAddConfigControl.SetBackupConfigInfo( BackupConfigInfo );
  BackupPathAddConfigControl.Update;
  BackupPathAddConfigControl.Free;
end;

procedure TMyBackupFileControl.BackupNow;
var
  BackupPathScanAllHandle : TBackupPathScanAllHandle;
begin
  BackupPathScanAllHandle := TBackupPathScanAllHandle.Create;
  BackupPathScanAllHandle.Update;
  BackupPathScanAllHandle.Free;
end;

procedure TMyBackupFileControl.BackupSelectFolder(FolderPath: string);
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
  BackupPathScanHandle := TBackupPathScanHandle.Create( FolderPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TMyBackupFileControl.PcOnlineSync;
var
  BackupPathSyncAllHandle : TBackupPathSyncAllHandle;
begin
  BackupPathSyncAllHandle := TBackupPathSyncAllHandle.Create;
  BackupPathSyncAllHandle.Update;
  BackupPathSyncAllHandle.Free;
end;

procedure TMyBackupFileControl.FileCancelBackup(FilePath: string);
var
  BackupFileCancelBackupControl : TBackupFileCancelBackupControl;
begin
  BackupFileCancelBackupControl := TBackupFileCancelBackupControl.Create( FilePath );
  BackupFileCancelBackupControl.Update;
  BackupFileCancelBackupControl.Free;
end;

procedure TMyBackupFileControl.FolderCancelBackup(FolderPath: string);
var
  BackupFolderCancelBackupControl : TBackupFolderCancelBackupControl;
begin
  BackupFolderCancelBackupControl := TBackupFolderCancelBackupControl.Create( FolderPath );
  BackupFolderCancelBackupControl.Update;
  BackupFolderCancelBackupControl.Free;
end;

procedure TMyBackupFileControl.RemoveBackupPath(FullPath: string);
var
  BackupPathRemove : TBackupPathRemoveHandle;
begin
  BackupPathRemove := TBackupPathRemoveHandle.Create( FullPath );
  BackupPathRemove.Update;
  BackupPathRemove.Free;
end;

procedure TMyBackupFileControl.ShowBackupFileDetail(FullPath: string);
var
  BackupFileReadDetailInfo : TBackupFileReadDetailInfo;
begin
  BackupFileReadDetailInfo := TBackupFileReadDetailInfo.Create( FullPath );
  MyBackupFileInfo.InsertChange( BackupFileReadDetailInfo );
end;

procedure TMyBackupFileControl.ShowBackupFileStatus(FullPath: string);
var
  BackupFileReadLvInfo : TBackupFolderReadLvInfo;
begin
  BackupFileReadLvInfo := TBackupFolderReadLvInfo.Create( FullPath );
  MyBackupFileInfo.InsertChange( BackupFileReadLvInfo );
end;

procedure TMyBackupFileControl.ShowBackupFileStatusNomal(FullPath: string);
var
  BackupFileReadLvInfo : TBackupFolderReadLvInfo;
begin
  BackupFileReadLvInfo := TBackupFolderReadLvInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupFileReadLvInfo );
end;

{ TBackupPathAdd }

procedure TBackupPathAddHandle.AddToXml;
var
  BackupPathAddXml : TBackupPathAddXml;
begin
  BackupPathAddXml := TBackupPathAddXml.Create( FullPath );
  BackupPathAddXml.SetPathType( PathType );
  BackupPathAddXml.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddXml.SetAcutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddXml.SetSyncIntervalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddXml.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddXml.SetCountInfo( CopyCount, FileCount );
  BackupPathAddXml.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathAddXml );
end;

procedure TBackupPathAddHandle.Update;
begin
  inherited;

    // ��� Xml
  AddToXml;
end;

{ TBackupPathRemove }

procedure TBackupPathRemoveHandle.RemoveBackupInfo;
var
  BackupPathRemoveInfo : TBackupPathRemoveInfo;
begin
  BackupPathRemoveInfo := TBackupPathRemoveInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathRemoveInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupNotify;
var
  BackupPathRemoveNotifyInfo : TBackupPathRemoveNotifyInfo;
begin
  BackupPathRemoveNotifyInfo := TBackupPathRemoveNotifyInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathRemoveNotifyInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupOffline;
var
  BackupPathRemoveOfflineJobInfo : TBackupPathRemoveOfflineJobInfo;
begin
  BackupPathRemoveOfflineJobInfo := TBackupPathRemoveOfflineJobInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRemoveOfflineJobInfo );
end;

procedure TBackupPathRemoveHandle.RemoveBackupXml;
var
  BackupPathRemoteXml : TBackupPathRemoveXml;
begin
  BackupPathRemoteXml := TBackupPathRemoveXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathRemoteXml );
end;

procedure TBackupPathRemoveHandle.RemoveFromFace;
var
  BackupVtRemoveInfo : TBackupVtRemoveInfo;
  BackupTvRemoveRootInfo : TVstBackupPathRemove;
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
  LvBackupPathProRemove : TLvBackupPathProRemove;
begin
    // ɾ�� ѡ��·��
  BackupVtRemoveInfo := TBackupVtRemoveInfo.Create( FullPath );
  MyBackupFileFace.AddChange( BackupVtRemoveInfo );

    // ɾ�� ��ʾ·��
  BackupTvRemoveRootInfo := TVstBackupPathRemove.Create( FullPath );
  MyBackupFileFace.InsertChange( BackupTvRemoveRootInfo );

    // ɾ�� ���Դ���
  LvBackupPathProRemove := TLvBackupPathProRemove.Create( FullPath );
  MyBackupFileFace.AddChange( LvBackupPathProRemove );

    // ˢ�� ���ݽ���
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // ˢ�� �ҵı�������Ϣ
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;


procedure TBackupPathRemoveHandle.Update;
begin
    // ֪ͨ ����Ŀ��
  RemoveBackupNotify;

    // ɾ�� ��Ϣ
  RemoveBackupInfo;

    // �������� Job
  RemoveBackupOffline;

    // ɾ�� ����
  RemoveFromFace;

    // ɾ�� Xml
  RemoveBackupXml;
end;

{ TBackupPathSetCopyCount }

procedure TBackupPathSetCopyCount.SyncFileNow;
var
  BackupFileSyncHandle : TBackupFileSyncHandle;
begin
  BackupFileSyncHandle := TBackupFileSyncHandle.Create( FullPath );
  BackupFileSyncHandle.Update;
  BackupFileSyncHandle.Free;
end;

procedure TBackupPathSetCopyCount.SetToInfo;
var
  BackupPathCopyCountInfo : TBackupPathCopyCountInfo;
begin
  BackupPathCopyCountInfo := TBackupPathCopyCountInfo.Create( FullPath );
  BackupPathCopyCountInfo.SetCopyCount( CopyCount );
  MyBackupFileInfo.AddChange( BackupPathCopyCountInfo );
end;

procedure TBackupPathSetCopyCount.SetToXml;
var
  BackupPathCopyCountXml : TBackupPathCopyCountXml;
begin
  BackupPathCopyCountXml := TBackupPathCopyCountXml.Create( FullPath );
  BackupPathCopyCountXml.SetCopyCount( CopyCount );
  MyBackupXmlWrite.AddChange( BackupPathCopyCountXml );
end;

procedure TBackupPathSetCopyCount.SetToFace;
var
  BackupTvCopyCountInfo : TVstBackupPathSetCopyCount;
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // ˢ�� VstBackupItem
  BackupTvCopyCountInfo := TVstBackupPathSetCopyCount.Create( FullPath );
  BackupTvCopyCountInfo.SetCopyCount( CopyCount );
  MyBackupFileFace.AddChange( BackupTvCopyCountInfo );

    // ˢ�� ���ݽ���
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // ˢ�� �ҵı�������Ϣ
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathSetCopyCount.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TBackupPathSetCopyCount.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;

  SyncFileNow;
end;

{ TBackupCopyAddHandle }

procedure TBackupCopyReadLoadedHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus(  CopyStatus_Loaded  );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyReadLoadedHandle.Update;
begin
    // ��ӵ��ڴ�
  AddToInfo;

    // ˢ�� ����
  RefreshFace;
end;

{ TBackupCopyRemoveHandle }

procedure TBackupCopyRemoveHandle.RemoveFromInfo;
var
  BackupFileCopyRemoveInfo : TBackupFileCopyRemoveInfo;
begin
    // ɾ�� �����ļ����� �ڴ�
  BackupFileCopyRemoveInfo := TBackupFileCopyRemoveInfo.Create( FilePath );
  BackupFileCopyRemoveInfo.SetCopyOwner( CopyOwner );
  MyBackupFileInfo.AddChange( BackupFileCopyRemoveInfo );
end;

procedure TBackupCopyRemoveHandle.RemoveFromXml;
var
  BackupFileCopyRemoveXml : TBackupFileCopyRemoveXml;
begin
  BackupFileCopyRemoveXml := TBackupFileCopyRemoveXml.Create( FilePath );
  BackupFileCopyRemoveXml.SetCopyOwner( CopyOwner );
  MyBackupXmlWrite.AddChange( BackupFileCopyRemoveXml );
end;

procedure TBackupCopyRemoveHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromXml;

    // ˢ�� ����
  RefreshFace;
end;

{ TBackupPathBaseAddHandle }

procedure TBackupPathReadHandle.AddToInfo;
var
  BackupPathAddInfo : TBackupPathAddInfo;
begin
    // ���·��
  BackupPathAddInfo := TBackupPathAddInfo.Create( FullPath );
  BackupPathAddInfo.SetPathType( PathType );
  BackupPathAddInfo.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddInfo.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddInfo.SetCountInfo( CopyCount, FileCount );
  BackupPathAddInfo.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathAddInfo );
end;

procedure TBackupPathReadHandle.AddToFace;
var
  BackupVtAddInfo : TBackupVtAddInfo;
  VstBackupItemAddRoot : TVstBackupPathAdd;
  LvBackupPathProAdd : TLvBackupPathProAdd;
begin
    // ѡ�� ����·������
  BackupVtAddInfo := TBackupVtAddInfo.Create( FullPath );
  MyBackupFileFace.AddChange( BackupVtAddInfo );

    // ��� BackupItem ����
  VstBackupItemAddRoot := TVstBackupPathAdd.Create( FullPath );
  VstBackupItemAddRoot.SetPathType( PathType );
  VstBackupItemAddRoot.SetBackupInfo( IsDisable );
  VstBackupItemAddRoot.SetSyncTimeInfo( IsAutoSync, SyncTimeType, SyncTimeValue, LastSyncTime );
  VstBackupItemAddRoot.SetIsEncrypt( IsEncrypt );
  VstBackupItemAddRoot.SetCountInfo( CopyCount, FileCount );
  VstBackupItemAddRoot.SetSpaceInfo( FolderSpace, CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupItemAddRoot );

    // ���Դ���
  LvBackupPathProAdd := TLvBackupPathProAdd.Create( FullPath );
  MyBackupFileFace.AddChange( LvBackupPathProAdd );
end;

procedure TBackupPathReadHandle.SetBackupInfo(_IsDisable,
  _IsBackupNow: Boolean);
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathReadHandle.SetCountInfo(_CopyCount, _FileCount: Integer);
begin
  CopyCount := _CopyCount;
  FileCount := _FileCount;
end;

procedure TBackupPathReadHandle.SetEncryptInfo(_IsEncrypt: Boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupPathReadHandle.SetPathInfo(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TBackupPathReadHandle.SetSpaceInfo(_FolderSpace, _CompletedSpace: Int64);
begin
  FolderSpace := _FolderSpace;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupPathReadHandle.SetSyncInternalInfo(_SyncTimeType,
  _SyncTimeValue: Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathReadHandle.SetAutoSyncInfo(_IsAutoSync : Boolean;
  _LastSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathReadHandle.Update;
begin
    // �ڴ�
  AddToInfo;

    // ��ʾ·�� ����
  AddToFace;
end;

{ TBackupFileAddHandle }

procedure TBackupFileAddHandle.AddBackupXml;
var
  BackupFileAddXml : TBackupFileAddXml;
begin
  BackupFileAddXml := TBackupFileAddXml.Create( FilePath );
  BackupFileAddXml.SetFileInfo( FileSize, FileTime );
  MyBackupXmlWrite.AddChange( BackupFileAddXml );
end;

procedure TBackupFileAddHandle.Update;
begin
    // �ļ�����ʹ��
  if MyFileInfo.getFileIsInUse( FilePath ) then
    Exit;

  inherited;

    // ��ӵ� ����
  AddBackupXml;
end;

{ TBackupFileRemoveHandle }

procedure TBackupFileRemoveHandle.RemoveFromInfo;
var
  BackupFileRemoveInfo : TBackupFileRemoveInfo;
begin
  BackupFileRemoveInfo := TBackupFileRemoveInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupFileRemoveInfo );
end;

procedure TBackupFileRemoveHandle.RemoveFromNotify;
var
  BackupFileRemoveNotifyInfo : TBackupFileRemoveNotifyInfo;
begin
  BackupFileRemoveNotifyInfo := TBackupFileRemoveNotifyInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupFileRemoveNotifyInfo );
end;

procedure TBackupFileRemoveHandle.RemoveFromXml;
var
  BackupFileRemoveXml : TBackupFileRemoveXml;
begin
  BackupFileRemoveXml := TBackupFileRemoveXml.Create( FilePath );
  MyBackupXmlWrite.AddChange( BackupFileRemoveXml );
end;

procedure TBackupFileRemoveHandle.Update;
begin
    // ֪ͨ �����ļ�Ŀ��
  RemoveFromNotify;

    // ɾ�� �ڴ�
  RemoveFromInfo;

    // ɾ�� ����
  RemoveFromXml;
end;

{ TBackupFileBaseAddHanlde }

procedure TBackupFileReadHandle.AddToInfo;
var
  BackupFileAddInfo : TBackupFileAddInfo;
begin
  BackupFileAddInfo := TBackupFileAddInfo.Create( FilePath );
  BackupFileAddInfo.SetFileInfo( FileSize, FileTime );
  MyBackupFileInfo.AddChange( BackupFileAddInfo );
end;

procedure TBackupFileReadHandle.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TBackupFileReadHandle.Update;
begin
    // ��ӵ� �ڴ�
  AddToInfo;
end;

{ TBackupCopyChangeHandle }

procedure TBackupCopyChangeHandle.RefreshFace;
var
  BackupCopyLvFaceReadInfo : TBackupFileRefreshLvFaceInfo;
begin
    // ˢ�� ListView ����
  if not LvBackupFileUtil.IsFileShow( FilePath ) then
    Exit;

    // ˢ�� ״̬
  BackupCopyLvFaceReadInfo := TBackupFileRefreshLvFaceInfo.Create( FilePath );
  MyBackupFileInfo.AddChange( BackupCopyLvFaceReadInfo );
end;

procedure TBackupCopyChangeHandle.SetCopyOwner(_CopyOwner: string);
begin
  CopyOwner := _CopyOwner;
end;

{ TBackupPathChangeHandle }

constructor TBackupPathChangeHandle.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

procedure TBackupCopyAddLoadedHandle.AddToXml;
var
  BackupFileCopyAddXml : TBackupFileCopyAddXml;
begin
    // ��� �����ļ����� ����
  BackupFileCopyAddXml := TBackupFileCopyAddXml.Create( FilePath );
  BackupFileCopyAddXml.SetCopyOwner( CopyOwner );
  BackupFileCopyAddXml.SetCopyStatus( CopyStatus_Loaded );
  MyBackupXmlWrite.AddChange( BackupFileCopyAddXml );
end;

procedure TBackupCopyAddLoadedHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathResetExistHandle }

procedure TBackupPathSetExistHandle.SetIsExist(_IsExist: Boolean);
begin
  IsExist := _IsExist;
end;

procedure TBackupPathSetExistHandle.SetToFace;
var
  VstBackupItemIsExist : TVstBackupPathIsExist;
begin
  VstBackupItemIsExist := TVstBackupPathIsExist.Create( FullPath );
  VstBackupItemIsExist.SetIsExist( IsExist );
  MyBackupFileFace.AddChange( VstBackupItemIsExist );
end;

procedure TBackupPathSetExistHandle.Update;
begin
  SetToFace;
end;

{ TBackupFileChangeHandle }

constructor TBackupFileChangeHandle.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupFolderSetCompletedSpaceHanlde }

procedure TBackupFolderSetCompletedSpaceHanlde.SetLastCompletedSpace(
  _LastCompletedSpace: Int64);
begin
  LastCompletedSpace := _LastCompletedSpace;
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToFace;
var
  VstBackupFolderSetCompletedSpace : TVstBackupFolderSetCompletedSpace;
begin
  VstBackupFolderSetCompletedSpace := TVstBackupFolderSetCompletedSpace.Create( FolderPath );
  VstBackupFolderSetCompletedSpace.SetLastCompletedSpace( LastCompletedSpace );
  VstBackupFolderSetCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderSetCompletedSpace );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToInfo;
var
  BackupFolderSetCompletedSpaceInfo : TBackupFolderSetCompletedSpaceInfo;
begin
  BackupFolderSetCompletedSpaceInfo := TBackupFolderSetCompletedSpaceInfo.Create( FolderPath );
  BackupFolderSetCompletedSpaceInfo.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderSetCompletedSpaceInfo );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.SetToXml;
var
  BackupFolderSetCompletedSpaceXml : TBackupFolderSetCompletedSpaceXml;
begin
  BackupFolderSetCompletedSpaceXml := TBackupFolderSetCompletedSpaceXml.Create( FolderPath );
  BackupFolderSetCompletedSpaceXml.SetLastCompletedSpace( LastCompletedSpace );
  BackupFolderSetCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderSetCompletedSpaceXml );
end;

procedure TBackupFolderSetCompletedSpaceHanlde.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupCopyAddPendHandle }

procedure TBackupCopyAddPendHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Pending );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyAddPendHandle.Update;
begin
  AddToInfo;

    // ˢ�� ����
  RefreshFace;
end;

{ TBackupCopyAddLoadingHandle }

procedure TBackupCopyAddLoadingHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Loading );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyAddLoadingHandle.Update;
begin
  AddToInfo;

    // ˢ�� ����
  RefreshFace;
end;

{ TBackupCopyReadOfflineHandle }

procedure TBackupCopyReadOfflineHandle.AddToInfo;
var
  BackupFileCopyAddInfo : TBackupFileCopyAddInfo;
begin
  BackupFileCopyAddInfo := TBackupFileCopyAddInfo.Create( FilePath );
  BackupFileCopyAddInfo.SetCopyOwner( CopyOwner );
  BackupFileCopyAddInfo.SetCopyStatus( CopyStatus_Offline );
  MyBackupFileInfo.AddChange( BackupFileCopyAddInfo );
end;

procedure TBackupCopyReadOfflineHandle.Update;
begin
  AddToInfo;

    // ˢ�� ����
  RefreshFace;
end;

{ TBackupCopyAddOfflineHandle }

procedure TBackupCopyAddOfflineHandle.AddToXml;
var
  BackupFileCopyAddOfflineXml : TBackupFileCopyAddOfflineXml;
begin
    // ��� �����ļ����� ����
  BackupFileCopyAddOfflineXml := TBackupFileCopyAddOfflineXml.Create( FilePath );
  BackupFileCopyAddOfflineXml.SetCopyOwner( CopyOwner );
  BackupFileCopyAddOfflineXml.SetCopyStatus( CopyStatus_Offline );
  BackupFileCopyAddOfflineXml.SetPosition( Position );
  MyBackupXmlWrite.AddChange( BackupFileCopyAddOfflineXml );
end;

procedure TBackupCopyAddOfflineHandle.SetPosition(_Position: Int64);
begin
  Position := _Position;
end;

procedure TBackupCopyAddOfflineHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupFileRefreshJobHandle }

procedure TBackupFileSyncHandle.AddToInfo;
var
  BackupPathFreeScanJobInfo : TBackupPathSyncInfo;
begin
  BackupPathFreeScanJobInfo := TBackupPathSyncInfo.Create( FilePath );
  BackupPathFreeScanJobInfo.SetIsShowFreeLimt( False );
  MyBackupFileInfo.AddChange( BackupPathFreeScanJobInfo );
end;

procedure TBackupFileSyncHandle.Update;
begin
  AddToInfo;
end;

{ TBackupFolderAddCompletedSpaceHandle }

procedure TBackupFolderAddCompletedSpaceHandle.AddToFace;
var
  VstBackupItemAddCompletedSpace : TVstBackupFolderAddCompletedSpace;
begin
    // ��� ����ɿռ���Ϣ
  VstBackupItemAddCompletedSpace := TVstBackupFolderAddCompletedSpace.Create( FolderPath );
  VstBackupItemAddCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupItemAddCompletedSpace );
end;

procedure TBackupFolderAddCompletedSpaceHandle.AddToInfo;
var
  BackupFolderAddCompletedSpaceInfo : TBackupFolderAddCompletedSpaceInfo;
begin
    // ��� ����Ŀ¼ ����ɿռ�
  BackupFolderAddCompletedSpaceInfo := TBackupFolderAddCompletedSpaceInfo.Create( FolderPath );
  BackupFolderAddCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderAddCompletedSpaceInfo );
end;

procedure TBackupFolderAddCompletedSpaceHandle.AddToXml;
var
  BackupFolderAddCompletedSpaceXml : TBackupFolderAddCompletedSpaceXml;
begin
  BackupFolderAddCompletedSpaceXml := TBackupFolderAddCompletedSpaceXml.Create( FolderPath );
  BackupFolderAddCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderAddCompletedSpaceXml );
end;

procedure TBackupFolderAddCompletedSpaceHandle.Update;
begin
  AddToInfo;

  AddToFace;

  AddToXml;
end;

{ TBackupPathOwnerSpaceChangeHandle }

procedure TBackupPathOwnerChangeHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TBackupPathOwnerSetSpaceHandle }

procedure TBackupPathOwnerSetSpaceHandle.SetToXml;
var
  BackupPathOwnerSetXml : TBackupPathOwnerSetSpaceXml;
begin
  BackupPathOwnerSetXml := TBackupPathOwnerSetSpaceXml.Create( FullPath );
  BackupPathOwnerSetXml.SetPcID( PcID );
  BackupPathOwnerSetXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerSetXml );
end;

procedure TBackupPathOwnerSetSpaceHandle.Update;
begin
  inherited;

  SetToXml;
end;

{ TBackupPathOwnerAddSpaceHandle }

procedure TBackupPathOwnerAddSpaceHandle.AddToFace;
var
  VstCloudStatusAddHasMyBackupSpace : TVstCloudStatusHasMyBackupAdd;
  BackupPgAddCompletedInfo : TBackupPgAddCompletedInfo;
  MyBackupCloudLvAddSpace : TMyBackupCloudLvAddSpace;
begin
    // ��� ��Pc�ҵı����ļ�
  VstCloudStatusAddHasMyBackupSpace := TVstCloudStatusHasMyBackupAdd.Create( PcID );
  VstCloudStatusAddHasMyBackupSpace.SetSpaceInfo( FileSize, FileCount );
  MyNetworkFace.AddChange( VstCloudStatusAddHasMyBackupSpace );

    // ��� ���ݽ�����
  BackupPgAddCompletedInfo := TBackupPgAddCompletedInfo.Create( FileSize );
  MyBackupFileFace.AddChange( BackupPgAddCompletedInfo );

    // ��� �ҵı����ļ��ֲ�
  MyBackupCloudLvAddSpace := TMyBackupCloudLvAddSpace.Create( PcID );
  MyBackupCloudLvAddSpace.SetFileSpace( FileSize );
  MyBackupCloudLvAddSpace.SetFileCount( FileCount );
  MyNetworkFace.AddChange( MyBackupCloudLvAddSpace );
end;

procedure TBackupPathOwnerAddSpaceHandle.AddToInfo;
var
  BackupPathOwnerAddSpaceInfo : TBackupPathOwnerAddSpaceInfo;
begin
  BackupPathOwnerAddSpaceInfo := TBackupPathOwnerAddSpaceInfo.Create( FullPath );
  BackupPathOwnerAddSpaceInfo.SetPcID( PcID );
  BackupPathOwnerAddSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerAddSpaceInfo );
end;

procedure TBackupPathOwnerAddSpaceHandle.AddToXml;
var
  BackupPathOwnerAddSpaceXml : TBackupPathOwnerAddSpaceXml;
begin
  BackupPathOwnerAddSpaceXml := TBackupPathOwnerAddSpaceXml.Create( FullPath );
  BackupPathOwnerAddSpaceXml.SetPcID( PcID );
  BackupPathOwnerAddSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerAddSpaceXml );
end;

procedure TBackupPathOwnerAddSpaceHandle.Update;
begin
  AddToInfo;

  AddToFace;

  AddToXml;
end;

{ TBackupCopyAddControl }

procedure TBackupCopyAddControl.AddBackupCopy;
var
  BackupCopyAddLoadedHandle : TBackupCopyAddLoadedHandle;
begin
  BackupCopyAddLoadedHandle := TBackupCopyAddLoadedHandle.Create( FilePath );
  BackupCopyAddLoadedHandle.SetCopyOwner( PcID );
  BackupCopyAddLoadedHandle.Update;
  BackupCopyAddLoadedHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupFolderCompletedSpace;
var
  FolderPath : string;
  BackupFolderAddCompletedSpaceHandle : TBackupFolderAddCompletedSpaceHandle;
begin
  if FilePath = RootBackupPath then
    FolderPath := FilePath
  else
    FolderPath := ExtractFileDir( FilePath );

  BackupFolderAddCompletedSpaceHandle := TBackupFolderAddCompletedSpaceHandle.Create( FolderPath );
  BackupFolderAddCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupFolderAddCompletedSpaceHandle.Update;
  BackupFolderAddCompletedSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupPathCompletedSpace;
var
  BackupPathAddCompletedSpaceHandle : TBackupPathAddCompletedSpaceHandle;
begin
  BackupPathAddCompletedSpaceHandle := TBackupPathAddCompletedSpaceHandle.Create( RootBackupPath );
  BackupPathAddCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupPathAddCompletedSpaceHandle.Update;
  BackupPathAddCompletedSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.AddBackupPathCopy;
var
  BackupPathOwnerAddSpaceHandle : TBackupPathOwnerAddSpaceHandle;
begin
  BackupPathOwnerAddSpaceHandle := TBackupPathOwnerAddSpaceHandle.Create( RootBackupPath );
  BackupPathOwnerAddSpaceHandle.SetPcID( PcID );
  BackupPathOwnerAddSpaceHandle.SetSpaceInfo( FileSize, 1 );
  BackupPathOwnerAddSpaceHandle.Update;
  BackupPathOwnerAddSpaceHandle.Free;
end;

procedure TBackupCopyAddControl.Update;
begin
  inherited;

    // ��·�� ����զ
  if RootBackupPath = '' then
    Exit;

    // ��� Copy ��Ϣ
  AddBackupCopy;
  AddBackupPathCopy;

    // ��� �ռ���Ϣ
  AddBackupFolderCompletedSpace;
  AddBackupPathCompletedSpace;
end;

{ TBackupFolderSetSpaceHandle }

procedure TBackupFolderSetSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TBackupFolderSetSpaceHandle.SetToFace;
var
  VstBackupFolderSetSpace : TVstBackupFolderSetSpace;
begin
    // д ����
  VstBackupFolderSetSpace := TVstBackupFolderSetSpace.Create( FolderPath );
  VstBackupFolderSetSpace.SetSize( FileSize );
  VstBackupFolderSetSpace.SetFileCount( FileCount );
  MyBackupFileFace.AddChange( VstBackupFolderSetSpace );
end;

procedure TBackupFolderSetSpaceHandle.SetToInfo;
var
  BackupFolderSpaceInfo : TBackupFolderSetSpaceInfo;
begin
    // д �ڴ�
  BackupFolderSpaceInfo := TBackupFolderSetSpaceInfo.Create( FolderPath );
  BackupFolderSpaceInfo.SetFolderSpace( FileSize );
  BackupFolderSpaceInfo.SetFileCount( FileCount );
  MyBackupFileInfo.AddChange( BackupFolderSpaceInfo );
end;

procedure TBackupFolderSetSpaceHandle.SetToXml;
var
  BackupFolderSetSpaceXml : TBackupFolderSetSpaceXml;
begin
  BackupFolderSetSpaceXml := TBackupFolderSetSpaceXml.Create( FolderPath );
  BackupFolderSetSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupFolderSetSpaceXml );
end;

procedure TBackupFolderSetSpaceHandle.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupPathSetSpaceHandle }

procedure TBackupPathSetSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TBackupPathSetSpaceHandle.SetToFace;
var
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // ˢ�� ���ݽ���
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // ˢ�� �ҵı�������Ϣ
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathSetSpaceHandle.SetToInfo;
var
  BackupPathSetSpaceInfo : TBackupPathSetSpaceInfo;
begin
    // д �ڴ�
  BackupPathSetSpaceInfo := TBackupPathSetSpaceInfo.Create( FullPath );
  BackupPathSetSpaceInfo.SetFolderSpace( FileSize );
  BackupPathSetSpaceInfo.SetFileCount( FileCount );
  MyBackupFileInfo.AddChange( BackupPathSetSpaceInfo );
end;

procedure TBackupPathSetSpaceHandle.SetToXml;
var
  BackupPathSetSpaceXml : TBackupPathSetSpaceXml;
begin
    // д Xml
  BackupPathSetSpaceXml := TBackupPathSetSpaceXml.Create( FullPath );
  BackupPathSetSpaceXml.SetFolderSpace( FileSize );
  BackupPathSetSpaceXml.SetFileCount( FileCount );
  MyBackupXmlWrite.AddChange( BackupPathSetSpaceXml );
end;

procedure TBackupPathSetSpaceHandle.Update;
begin
  SetToInfo;

  SetToFace;

  SetToXml;
end;

{ TBackupFolderChangeHandle }

constructor TBackupFolderChangeHandle.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

{ TBackupFolderReadHandle }

procedure TBackupFolderReadHandle.AddToFace;
var
  VstBackupFolderAdd : TVstBackupFolderAdd;
  BackupLvAddInfo : TBackupLvAddInfo;
begin
    // Backup Item
  VstBackupFolderAdd := TVstBackupFolderAdd.Create( FolderPath );
  VstBackupFolderAdd.SetCountInfo( FileCount );
  VstBackupFolderAdd.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderAdd );
end;

procedure TBackupFolderReadHandle.AddToInfo;
var
  BackupFolderAddInfo : TBackupFolderAddInfo;
begin
  BackupFolderAddInfo := TBackupFolderAddInfo.Create( FolderPath );
  BackupFolderAddInfo.SetFolderInfo( FileTime, FileCount );
  BackupFolderAddInfo.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderAddInfo );
end;

procedure TBackupFolderReadHandle.SetFolderInfo(_FileTime: TDateTime;
  _FileCount: Integer);
begin
  FileTime := _FileTime;
  FileCount := _FileCount;
end;

procedure TBackupFolderReadHandle.SetSpaceInfo(_FileSize,
  _CompletedSpace: Int64);
begin
  FileSize := _FileSize;
  CompletedSpace := _CompletedSpace;
end;

procedure TBackupFolderReadHandle.Update;
begin
  AddToInfo;

  AddToFace;
end;

{ TBackupFolderAddHandle }

procedure TBackupFolderAddHandle.AddToXml;
var
  BackupFolderAddXml : TBackupFolderAddXml;
begin
  BackupFolderAddXml := TBackupFolderAddXml.Create( FolderPath );
  BackupFolderAddXml.SetFolderInfo( FileTime, FileCount );
  BackupFolderAddXml.SetSpaceInfo( FileSize, CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderAddXml );
end;

procedure TBackupFolderAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupFolderRemoveHandle }

procedure TBackupFolderRemoveHandle.RemoveFromFace;
var
  VstBackupItemRemoveChild : TVstBackupItemRemoveChild;
begin
  VstBackupItemRemoveChild := TVstBackupItemRemoveChild.Create( FolderPath );
  MyBackupFileFace.AddChange( VstBackupItemRemoveChild );
end;

procedure TBackupFolderRemoveHandle.RemoveFromInfo;
var
  BackupFolderRemoveInfo : TBackupFolderRemoveInfo;
begin
  BackupFolderRemoveInfo := TBackupFolderRemoveInfo.Create( FolderPath );
  MyBackupFileInfo.AddChange( BackupFolderRemoveInfo );
end;

procedure TBackupFolderRemoveHandle.RemoveFromNotify;
var
  BackupFolderRemoveNotify : TBackupFolderRemoveNotifyInfo;
begin
  BackupFolderRemoveNotify := TBackupFolderRemoveNotifyInfo.Create( FolderPath );
  MyBackupFileInfo.AddChange( BackupFolderRemoveNotify );
end;

procedure TBackupFolderRemoveHandle.RemoveFromXml;
var
  BackupFolderRemoveXml : TBackupFolderRemoveXml;
begin
  BackupFolderRemoveXml := TBackupFolderRemoveXml.Create( FolderPath );
  MyBackupXmlWrite.AddChange( BackupFolderRemoveXml );
end;

procedure TBackupFolderRemoveHandle.Update;
begin
  RemoveFromNotify;

  RemoveFromInfo;

  RemoveFromFace;

  RemoveFromXml;
end;

{ TBackupPathOwnerSpaceHandle }

procedure TBackupPathOwnerChangeSpaceHandle.SetSpaceInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

{ TBackupPathOwnerClearHandle }

procedure TBackupPathOwnerClearHandle.ClearFromInfo;
var
  BackupPathOwnerClearSpaceInfo : TBackupPathOwnerClearSpaceInfo;
begin
  BackupPathOwnerClearSpaceInfo := TBackupPathOwnerClearSpaceInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathOwnerClearSpaceInfo );
end;

procedure TBackupPathOwnerClearHandle.ClearFromXml;
var
  BackupPathOwnerClearXml : TBackupPathOwnerClearXml;
begin
  BackupPathOwnerClearXml := TBackupPathOwnerClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathOwnerClearXml );
end;

procedure TBackupPathOwnerClearHandle.Update;
begin
  ClearFromInfo;

  ClearFromXml;
end;

{ TBackupPathOwnerRemoveSpaceHandle }

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromFace;
var
  VstCloudStatusHasMyBackupRemove : TVstCloudStatusHasMyBackupRemove;
  BackupPgRemoveCompletedInfo : TBackupPgRemoveCompletedInfo;
  MyBackupCloudLvRemoveSpace : TMyBackupCloudLvRemoveSpace;
begin
    // ��� ��Pc�ҵı����ļ�
  VstCloudStatusHasMyBackupRemove := TVstCloudStatusHasMyBackupRemove.Create( PcID );
  VstCloudStatusHasMyBackupRemove.SetSpaceInfo( FileSize, FileCount );
  MyNetworkFace.AddChange( VstCloudStatusHasMyBackupRemove );

    // ��� ���ݽ�����
  BackupPgRemoveCompletedInfo := TBackupPgRemoveCompletedInfo.Create( FileSize );
  MyBackupFileFace.AddChange( BackupPgRemoveCompletedInfo );

    // ��� �ҵı����ļ��ֲ�
  MyBackupCloudLvRemoveSpace := TMyBackupCloudLvRemoveSpace.Create( PcID );
  MyBackupCloudLvRemoveSpace.SetFileSpace( FileSize );
  MyBackupCloudLvRemoveSpace.SetFileCount( FileCount );
  MyNetworkFace.AddChange( MyBackupCloudLvRemoveSpace );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromInfo;
var
  BackupPathOwnerRemoveSpaceInfo : TBackupPathOwnerRemoveSpaceInfo;
begin
  BackupPathOwnerRemoveSpaceInfo := TBackupPathOwnerRemoveSpaceInfo.Create( FullPath );
  BackupPathOwnerRemoveSpaceInfo.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerRemoveSpaceInfo );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.RemoveFromXml;
var
  BackupPathOwnerRemoveSpaceXml : TBackupPathOwnerRemoveSpaceXml;
begin
  BackupPathOwnerRemoveSpaceXml := TBackupPathOwnerRemoveSpaceXml.Create( FullPath );
  BackupPathOwnerRemoveSpaceXml.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceXml.SetSpaceInfo( FileSize, FileCount );
  MyBackupXmlWrite.AddChange( BackupPathOwnerRemoveSpaceXml );
end;

procedure TBackupPathOwnerRemoveSpaceHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromFace;

  RemoveFromXml;
end;

{ TBackupPathOwnerReadSpaceHandle }

procedure TBackupPathOwnerReadSpaceHandle.SetToFace;
var
  BackupPathReadProgressInfo : TBackupPathReadProgressInfo;
  BackupPathRefreshMyCloudPcInfo : TBackupPathRefreshMyCloudPcInfo;
begin
    // ˢ�� ���ݽ���
  BackupPathReadProgressInfo := TBackupPathReadProgressInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadProgressInfo );

    // ˢ�� �ҵı�������Ϣ
  BackupPathRefreshMyCloudPcInfo := TBackupPathRefreshMyCloudPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathRefreshMyCloudPcInfo );
end;

procedure TBackupPathOwnerReadSpaceHandle.SetToInfo;
var
  BackupPathOwnerSetSpaceInfo : TBackupPathOwnerSetSpaceInfo;
begin
  BackupPathOwnerSetSpaceInfo := TBackupPathOwnerSetSpaceInfo.Create( FullPath );
  BackupPathOwnerSetSpaceInfo.SetPcID( PcID );
  BackupPathOwnerSetSpaceInfo.SetSpaceInfo( FileSize, FileCount );
  MyBackupFileInfo.AddChange( BackupPathOwnerSetSpaceInfo );
end;

procedure TBackupPathOwnerReadSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
end;

{ TBackupFolderSetStatusHandle }

procedure TBackupFolderSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TBackupFolderSetStatusHandle.SetToFace;
var
  VstBackupFolderSetStatus : TVstBackupFolderSetStatus;
begin
  VstBackupFolderSetStatus := TVstBackupFolderSetStatus.Create( FolderPath );
  VstBackupFolderSetStatus.SetPathStatus( Status );
  MyBackupFileFace.AddChange( VstBackupFolderSetStatus );
end;

procedure TBackupFolderSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TBackupPathSetStatusHandle }

procedure TBackupPathSetStatusHandle.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TBackupPathSetStatusHandle.SetToFace;
var
  VstBackupPathSetStatus : TVstBackupPathSetStatus;
begin
  VstBackupPathSetStatus := TVstBackupPathSetStatus.Create( FullPath );
  VstBackupPathSetStatus.SetStatus( Status );
  MyBackupFileFace.AddChange( VstBackupPathSetStatus );
end;

procedure TBackupPathSetStatusHandle.Update;
begin
  SetToFace;
end;

{ TBackupCopyChangeControl }

constructor TBackupCopyChangeControl.Create(_FilePath, _PcID: string);
begin
  FilePath := _FilePath;
  PcID := _PcID;
end;

procedure TBackupCopyChangeControl.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TBackupCopyChangeControl.Update;
begin
  RootBackupPath := MyBackupPathInfoUtil.ReadRootPath( FilePath );
end;

{ TBackupCopyRemoveControl }

procedure TBackupCopyRemoveControl.SyncFileNow;
var
  BackupFileSyncHandle : TBackupFileSyncHandle;
begin
  BackupFileSyncHandle := TBackupFileSyncHandle.Create( FilePath );
  BackupFileSyncHandle.Update;
  BackupFileSyncHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupCopy;
var
  BackupCopyRemoveHandle : TBackupCopyRemoveHandle;
begin
  BackupCopyRemoveHandle := TBackupCopyRemoveHandle.Create( FilePath );
  BackupCopyRemoveHandle.SetCopyOwner( PcID );
  BackupCopyRemoveHandle.Update;
  BackupCopyRemoveHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupFolderCompletedSpace;
var
  FolderPath : string;
  BackupFolderRemoveCompletedSpaceHandle : TBackupFolderRemoveCompletedSpaceHandle;
begin
  if FilePath = RootBackupPath then
    FolderPath := FilePath
  else
    FolderPath := ExtractFileDir( FilePath );

  BackupFolderRemoveCompletedSpaceHandle := TBackupFolderRemoveCompletedSpaceHandle.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupFolderRemoveCompletedSpaceHandle.Update;
  BackupFolderRemoveCompletedSpaceHandle.Free;
end;

procedure TBackupCopyRemoveControl.RemoveBackupPathCompletedSpace;
var
  BackupPathRemoveCompletedSpaceHandle : TBackupPathRemoveCompletedSpaceHandle;
begin
  BackupPathRemoveCompletedSpaceHandle := TBackupPathRemoveCompletedSpaceHandle.Create( RootBackupPath );
  BackupPathRemoveCompletedSpaceHandle.SetCompletedSpace( FileSize );
  BackupPathRemoveCompletedSpaceHandle.Update;
  BackupPathRemoveCompletedSpaceHandle.Free;
end;


procedure TBackupCopyRemoveControl.RemoveBackupPathCopy;
var
  BackupPathOwnerRemoveSpaceHandle : TBackupPathOwnerRemoveSpaceHandle;
begin
  BackupPathOwnerRemoveSpaceHandle := TBackupPathOwnerRemoveSpaceHandle.Create( RootBackupPath );
  BackupPathOwnerRemoveSpaceHandle.SetPcID( PcID );
  BackupPathOwnerRemoveSpaceHandle.SetSpaceInfo( FileSize, 1 );
  BackupPathOwnerRemoveSpaceHandle.Update;
  BackupPathOwnerRemoveSpaceHandle.Free;
end;

procedure TBackupCopyRemoveControl.Update;
begin
  inherited;

    // ��·��������
  if RootBackupPath = '' then
    Exit;

    // ɾ�� Copy ��Ϣ
  RemoveBackupCopy;
  RemoveBackupPathCopy;

    // ɾ�� �ռ���Ϣ
  RemoveBackupFolderCompletedSpace;
  RemoveBackupPathCompletedSpace;

    // ����ͬ�����ļ�
  SyncFileNow;
end;

{ TBackupPathSetCompletedSpaceHandle }

procedure TBackupPathSetCompletedSpaceHandle.SetToInfo;
var
  BackupPathSetCompletedSpaceInfo : TBackupPathSetCompletedSpaceInfo;
begin
  BackupPathSetCompletedSpaceInfo := TBackupPathSetCompletedSpaceInfo.Create( FullPath );
  BackupPathSetCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathSetCompletedSpaceInfo );
end;

procedure TBackupPathSetCompletedSpaceHandle.SetToXml;
var
  BackupPathSetCompletedSpaceXml : TBackupPathSetCompletedSpaceXml;
begin
  BackupPathSetCompletedSpaceXml := TBackupPathSetCompletedSpaceXml.Create( FullPath );
  BackupPathSetCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathSetCompletedSpaceXml );
end;

procedure TBackupPathSetCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TBackupFolderChangeCompletedSpaceHanlde }

procedure TBackupFolderChangeCompletedSpaceHanlde.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupFolderRemoveCompletedSpaceHandle }

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromFace;
var
  VstBackupFolderRemoveCompletedSpace : TVstBackupFolderRemoveCompletedSpace;
begin
    // ��� ����ɿռ���Ϣ
  VstBackupFolderRemoveCompletedSpace := TVstBackupFolderRemoveCompletedSpace.Create( FolderPath );
  VstBackupFolderRemoveCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyBackupFileFace.AddChange( VstBackupFolderRemoveCompletedSpace );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromInfo;
var
  BackupFolderRemoveCompletedSpaceInfo : TBackupFolderRemoveCompletedSpaceInfo;
begin
    // ��� ����Ŀ¼ ����ɿռ�
  BackupFolderRemoveCompletedSpaceInfo := TBackupFolderRemoveCompletedSpaceInfo.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupFolderRemoveCompletedSpaceInfo );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.RemoveFromToXml;
var
  BackupFolderRemoveCompletedSpaceXml : TBackupFolderRemoveCompletedSpaceXml;
begin
  BackupFolderRemoveCompletedSpaceXml := TBackupFolderRemoveCompletedSpaceXml.Create( FolderPath );
  BackupFolderRemoveCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupFolderRemoveCompletedSpaceXml );
end;

procedure TBackupFolderRemoveCompletedSpaceHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromToXml;
end;

{ TBackupPathChangeCompletedSpaceHandle }

procedure TBackupPathChangeCompletedSpaceHandle.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

{ TBackupPathAddCompletedSpaceHandle }

procedure TBackupPathAddCompletedSpaceHandle.AddToInfo;
var
  BackupPathAddCompletedSpaceInfo : TBackupPathAddCompletedSpaceInfo;
begin
  BackupPathAddCompletedSpaceInfo := TBackupPathAddCompletedSpaceInfo.Create( FullPath );
  BackupPathAddCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathAddCompletedSpaceInfo );
end;

procedure TBackupPathAddCompletedSpaceHandle.AddToXml;
var
  BackupPathAddCompletedSpaceXml : TBackupPathAddCompletedSpaceXml;
begin
  BackupPathAddCompletedSpaceXml := TBackupPathAddCompletedSpaceXml.Create( FullPath );
  BackupPathAddCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathAddCompletedSpaceXml );
end;

procedure TBackupPathAddCompletedSpaceHandle.Update;
begin
  AddToInfo;
  AddToXml;
end;

{ TBackupPathRemoveCompletedSpaceHandle }

procedure TBackupPathRemoveCompletedSpaceHandle.RemoveFromInfo;
var
  BackupPathRemoveCompletedSpaceInfo : TBackupPathRemoveCompletedSpaceInfo;
begin
  BackupPathRemoveCompletedSpaceInfo := TBackupPathRemoveCompletedSpaceInfo.Create( FullPath );
  BackupPathRemoveCompletedSpaceInfo.SetCompletedSpace( CompletedSpace );
  MyBackupFileInfo.AddChange( BackupPathRemoveCompletedSpaceInfo );
end;

procedure TBackupPathRemoveCompletedSpaceHandle.RemoveFromXml;
var
  BackupPathRemoveCompletedSpaceXml : TBackupPathRemoveCompletedSpaceXml;
begin
  BackupPathRemoveCompletedSpaceXml := TBackupPathRemoveCompletedSpaceXml.Create( FullPath );
  BackupPathRemoveCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyBackupXmlWrite.AddChange( BackupPathRemoveCompletedSpaceXml );
end;

procedure TBackupPathRemoveCompletedSpaceHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromXml;
end;

{ TBackupPathSetIsNotEnoughSpaceHandle }

procedure TBackupPathSetIsNotEnoughPcHandle.RefreshNotEnough;
var
  BackupPathReadIsEnoughPcInfo : TBackupPathReadIsNotEnoughPcInfo;
begin
    // ˢ�� ����·���Ƿ���� ���㹻�� Pc
  BackupPathReadIsEnoughPcInfo := TBackupPathReadIsNotEnoughPcInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathReadIsEnoughPcInfo );
end;

procedure TBackupPathSetIsNotEnoughPcHandle.SetIsNotEnoughPc(
  _IsNotEnoughPc: Boolean);
begin
  IsNotEnoughPc := _IsNotEnoughPc;
end;


procedure TBackupPathSetIsNotEnoughPcHandle.SetToInfo;
var
  BackupPathIsEnoughPcInfo : TBackupPathIsNotEnoughPcInfo;
begin
    // ˢ�� ��ǰɨ��·�� �Ƿ� �㹻 Pc
  BackupPathIsEnoughPcInfo := TBackupPathIsNotEnoughPcInfo.Create( FullPath );
  BackupPathIsEnoughPcInfo.SetIsNotEnouthPc( IsNotEnoughPc );
  MyBackupFileInfo.AddChange( BackupPathIsEnoughPcInfo );
end;

procedure TBackupPathSetIsNotEnoughPcHandle.Update;
begin
  SetToInfo;
  RefreshNotEnough;
end;

{ TBackupSelectRefreshHandle }

procedure TBackupSelectRefreshHandle.RefreshFace;
var
  VstBackupPathRefreshSelectNode : TVstBackupPathRefreshSelectNode;
begin
  VstBackupPathRefreshSelectNode := TVstBackupPathRefreshSelectNode.Create( FullPath );
  MyBackupFileFace.AddChange( VstBackupPathRefreshSelectNode );
end;

procedure TBackupSelectRefreshHandle.Update;
begin
  RefreshFace;
end;

{ TBackupPathScanAllHandle }

procedure TBackupPathScanAllHandle.AddToInfo;
var
  BackupPathScanAllInfo : TBackupPathScanAllInfo;
begin
  BackupPathScanAllInfo := TBackupPathScanAllInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathScanAllInfo );
end;

procedure TBackupPathScanAllHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathSyncAllHandle }

procedure TBackupPathSyncAllHandle.AddToInfo;
var
  BackupPathSyncAllInfo : TBackupPathSyncAllInfo;
begin
  BackupPathSyncAllInfo := TBackupPathSyncAllInfo.Create;
  MyBackupFileInfo.AddChange( BackupPathSyncAllInfo );
end;

procedure TBackupPathSyncAllHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathScanHandle }

procedure TBackupPathScanHandle.AddToInfo;
var
  BackupPathScanFileInfo : TBackupPathScanInfo;
begin
  BackupPathScanFileInfo := TBackupPathScanInfo.Create( FullPath );
  BackupPathScanFileInfo.SetIsShowFreeLimt( IsShowFreeLimt );
  MyBackupFileInfo.AddChange( BackupPathScanFileInfo );
end;

procedure TBackupPathScanHandle.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathScanHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathAddControl }

procedure TBackupPathAddDefaultControl.AddBackupFilter;
var
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // ���� �����ļ�
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_SystemFile, '' );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;

    // ���� ϵͳ�ļ�
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_HiddenFile, '' );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

procedure TBackupPathAddDefaultControl.AddBackupPath;
var
  BackupPathAddHandle : TBackupPathAddHandle;
begin
    // ��� ����·��
  BackupPathAddHandle := TBackupPathAddHandle.Create( FullPath );
  BackupPathAddHandle.SetPathInfo( PathType );
  BackupPathAddHandle.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddHandle.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddHandle.SetCountInfo( CopyCount, 0 );
  BackupPathAddHandle.SetSpaceInfo( 0, 0 );
  BackupPathAddHandle.Update;
  BackupPathAddHandle.Free;
end;

procedure TBackupPathAddDefaultControl.BackupPathNow;
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
    // ���� ����·��
  BackupPathScanHandle := TBackupPathScanHandle.Create( FullPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TBackupPathAddDefaultControl.FindEncryptInfo;
begin
    // ������Ϣ
  IsEncrypt := BackupFileEncryptSettingInfo.IsEncrypt;
  if not IsEncrypt then
  begin
    Password := '';
    PasswordHint := '';
  end
  else
  begin
    Password := BackupFileEncryptSettingInfo.Password;
    PasswordHint := BackupFileEncryptSettingInfo.PasswordHint;
  end;
end;

procedure TBackupPathAddDefaultControl.FindGenernalInfo;
begin
    // ·������
  PathType := MyFilePath.getPathType( FullPath );

    // ������Ϣ
  IsDisable := False;
  IsBackupNow := True;
  CopyCount := BackupFileSafeSettingInfo.CopyCount;
  IsAutoSync := SyncTimeSettingInfo.IsAutoSync;
  SyncTimeType := SyncTimeSettingInfo.TimeType;
  SyncTimeValue := SyncTimeSettingInfo.SyncTime;
  LastSyncTime := Now;
end;

procedure TBackupPathAddDefaultControl.Update;
begin
    // ��ȡ Ĭ����ͨ��Ϣ
  FindGenernalInfo;

    // ��ȡ ������Ϣ
  FindEncryptInfo;

    // ��� ����·��
  AddBackupPath;

    // ��� Ĭ�ϵĹ�����
  AddBackupFilter;

    // ���̱���
  BackupPathNow;
end;

{ TBackupPathAddControl }

constructor TBackupPathAddControl.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TBackupPathAddConfigControl }

procedure TBackupPathAddConfigControl.AddBackupFilter;
var
  i : Integer;
  FilterInfo : TFileFilterInfo;
  BackupPathIncludeFilterAddHandle : TBackupPathIncludeFilterAddHandle;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // ���� ������
  for i := 0 to IncludeFileFilterList.Count - 1 do
  begin
    FilterInfo := IncludeFileFilterList[i];

      // ���ǵ�ǰ·���� ������
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // ��� ������
    BackupPathIncludeFilterAddHandle := TBackupPathIncludeFilterAddHandle.Create( FullPath );
    BackupPathIncludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    BackupPathIncludeFilterAddHandle.Update;
    BackupPathIncludeFilterAddHandle.Free;
  end;

    // �ų� ������
  for i := 0 to ExcludeFileFilterList.Count - 1 do
  begin
    FilterInfo := ExcludeFileFilterList[i];

        // ���ǵ�ǰ·���� ������
    if not IsPathFilter( FilterInfo ) then
      Continue;

      // ��� ������
    BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( FullPath );
    BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterInfo.FilterType, FilterInfo.FilterStr );
    BackupPathExcludeFilterAddHandle.Update;
    BackupPathExcludeFilterAddHandle.Free;
  end;
end;

procedure TBackupPathAddConfigControl.AddBackupPath;
var
  BackupPathAddHandle : TBackupPathAddHandle;
begin
    // ��� ����·��
  BackupPathAddHandle := TBackupPathAddHandle.Create( FullPath );
  BackupPathAddHandle.SetPathInfo( PathType );
  BackupPathAddHandle.SetBackupInfo( IsDisable, IsBackupNow );
  BackupPathAddHandle.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupPathAddHandle.SetSyncInternalInfo( SyncTimeType, SyncTimeValue );
  BackupPathAddHandle.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  BackupPathAddHandle.SetCountInfo( CopyCount, 0 );
  BackupPathAddHandle.SetSpaceInfo( 0, 0 );
  BackupPathAddHandle.Update;
  BackupPathAddHandle.Free;
end;

procedure TBackupPathAddConfigControl.BackupPathNow;
var
  BackupPathScanHandle : TBackupPathScanHandle;
begin
    // ���� ����·��
  BackupPathScanHandle := TBackupPathScanHandle.Create( FullPath );
  BackupPathScanHandle.SetIsShowFreeLimt( True );
  BackupPathScanHandle.Update;
  BackupPathScanHandle.Free;
end;

procedure TBackupPathAddConfigControl.FindEncryptInfo;
begin
    // ������Ϣ
  IsEncrypt := BackupConfigInfo.IsEncrypt;
  if not IsEncrypt then
  begin
    Password := '';
    PasswordHint := '';
  end
  else
  begin
    Password := BackupConfigInfo.Password;
    PasswordHint := BackupConfigInfo.PasswordHint;
  end;
end;


procedure TBackupPathAddConfigControl.FindFilterInfo;
begin
  IncludeFileFilterList := BackupConfigInfo.IncludeFilterList;
  ExcludeFileFilterList := BackupConfigInfo.ExcludeFilterList;
end;

procedure TBackupPathAddConfigControl.FindGenernalInfo;
begin
    // ·������
  PathType := MyFilePath.getPathType( FullPath );

    // ������Ϣ
  IsDisable := BackupConfigInfo.IsDisable;
  IsBackupNow := BackupConfigInfo.IsBackupupNow;
  CopyCount := BackupConfigInfo.CopyCount;
  IsAutoSync := BackupConfigInfo.IsAuctoSync;
  SyncTimeType := BackupConfigInfo.SyncTimeType;
  SyncTimeValue := BackupConfigInfo.SyncTimeValue;
  LastSyncTime := Now;
end;

function TBackupPathAddConfigControl.IsPathFilter(
  FilterInfo: TFileFilterInfo): Boolean;
begin
  Result := True;
  if FilterInfo.FilterType <> FilterType_Path then
    Exit;

  Result := MyMatchMask.CheckEqualsOrChild( FilterInfo.FilterStr, FullPath );
end;

procedure TBackupPathAddConfigControl.SetBackupConfigInfo(
  _BackupConfigInfo: TBackupConfigInfo);
begin
  BackupConfigInfo := _BackupConfigInfo;
end;

procedure TBackupPathAddConfigControl.Update;
begin
    // ��ȡ��Ϣ
  FindGenernalInfo;
  FindEncryptInfo;
  FindFilterInfo;

    // �����Ϣ
  AddBackupPath;
  AddBackupFilter;
  BackupPathNow;
end;

{ TBackupPathFilterAddHandle }

procedure TBackupPathFilterWriteHandle.SetFilterInfo(_FilterType,
  _FilterStr: string);
begin
  FilterType := _FilterType;
  FilterStr := _FilterStr;
end;

{ TBackupPathIncludeFilterAddHandle }

procedure TBackupPathIncludeFilterReadHandle.AddToInfo;
var
  BackupPathIncludeFilterAddInfo : TBackupPathIncludeFilterAddInfo;
begin
  BackupPathIncludeFilterAddInfo := TBackupPathIncludeFilterAddInfo.Create( FullPath );
  BackupPathIncludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  MyBackupFileInfo.AddChange( BackupPathIncludeFilterAddInfo );
end;

procedure TBackupPathIncludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathIncludeFilterAddHandle }

procedure TBackupPathIncludeFilterAddHandle.AddToXml;
var
  BackupPathIncludeFilterAddXml : TBackupPathIncludeFilterAddXml;
begin
  BackupPathIncludeFilterAddXml := TBackupPathIncludeFilterAddXml.Create( FullPath );
  BackupPathIncludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyBackupXmlWrite.AddChange( BackupPathIncludeFilterAddXml );
end;

procedure TBackupPathIncludeFilterAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathExcludeFilterAddHandle }

procedure TBackupPathExcludeFilterReadHandle.AddToInfo;
var
  BackupPathExcludeFilterAddInfo : TBackupPathExcludeFilterAddInfo;
begin
  BackupPathExcludeFilterAddInfo := TBackupPathExcludeFilterAddInfo.Create( FullPath );
  BackupPathExcludeFilterAddInfo.SetFilterInfo( FilterType, FilterStr );
  MyBackupFileInfo.AddChange( BackupPathExcludeFilterAddInfo );
end;

procedure TBackupPathExcludeFilterReadHandle.Update;
begin
  AddToInfo;
end;

{ TBackupPathExcludeFilterAddHandle }

procedure TBackupPathExcludeFilterAddHandle.AddToXml;
var
  BackupPathExcludeFilterAddXml : TBackupPathExcludeFilterAddXml;
begin
  BackupPathExcludeFilterAddXml := TBackupPathExcludeFilterAddXml.Create( FullPath );
  BackupPathExcludeFilterAddXml.SetFilterInfo( FilterType, FilterStr );
  MyBackupXmlWrite.AddChange( BackupPathExcludeFilterAddXml );
end;

procedure TBackupPathExcludeFilterAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TBackupPathFilterClearHandle }

procedure TBackupPathIncludeFilterClearHandle.ClearToInfo;
var
  BackupPathIncludeFilterClearInfo : TBackupPathIncludeFilterClearInfo;
begin
  BackupPathIncludeFilterClearInfo := TBackupPathIncludeFilterClearInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathIncludeFilterClearInfo );
end;

procedure TBackupPathIncludeFilterClearHandle.ClearToXml;
var
  BackupPathIncludeFilterClearXml : TBackupPathIncludeFilterClearXml;
begin
  BackupPathIncludeFilterClearXml := TBackupPathIncludeFilterClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathIncludeFilterClearXml );
end;

procedure TBackupPathIncludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TBackupPathExcludeFilterClearHandle }

procedure TBackupPathExcludeFilterClearHandle.ClearToInfo;
var
  BackupPathExcludeFilterClearInfo : TBackupPathExcludeFilterClearInfo;
begin
  BackupPathExcludeFilterClearInfo := TBackupPathExcludeFilterClearInfo.Create( FullPath );
  MyBackupFileInfo.AddChange( BackupPathExcludeFilterClearInfo );
end;

procedure TBackupPathExcludeFilterClearHandle.ClearToXml;
var
  BackupPathExcludeFilterClearXml : TBackupPathExcludeFilterClearXml;
begin
  BackupPathExcludeFilterClearXml := TBackupPathExcludeFilterClearXml.Create( FullPath );
  MyBackupXmlWrite.AddChange( BackupPathExcludeFilterClearXml );
end;

procedure TBackupPathExcludeFilterClearHandle.Update;
begin
  ClearToInfo;
  ClearToXml;
end;

{ TBackupPathSetLastSyncTimeHandle }

procedure TBackupPathSetLastSyncTimeHandle.SetLastSyncTime(
  _LastSyncTime: TDateTime);
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToFace;
var
  VstBackupPathSetLastSyncTime : TVstBackupPathSetLastSyncTime;
begin
  VstBackupPathSetLastSyncTime := TVstBackupPathSetLastSyncTime.Create( FullPath );
  VstBackupPathSetLastSyncTime.SetLastSyncTime( LastSyncTime );
  MyBackupFileFace.AddChange( VstBackupPathSetLastSyncTime );
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToInfo;
var
  BackupPathSetLastSyncTimeInfo : TBackupPathSetLastSyncTimeInfo;
begin
  BackupPathSetLastSyncTimeInfo := TBackupPathSetLastSyncTimeInfo.Create( FullPath );
  BackupPathSetLastSyncTimeInfo.SetLastSyncTime( LastSyncTime );
  MyBackupFileInfo.AddChange( BackupPathSetLastSyncTimeInfo );
end;

procedure TBackupPathSetLastSyncTimeHandle.SetToXml;
var
  BackupPathSetLastSyncTimeXml : TBackupPathSetLastSyncTimeXml;
begin
  BackupPathSetLastSyncTimeXml := TBackupPathSetLastSyncTimeXml.Create( FullPath );
  BackupPathSetLastSyncTimeXml.SetLastSyncTime( LastSyncTime );
  MyBackupXmlWrite.AddChange( BackupPathSetLastSyncTimeXml );
end;

procedure TBackupPathSetLastSyncTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathSetSyncMinsHandle }

procedure TBackupPathSetAutoSyncHandle.SetIsAutoSync(_IsAutoSync: Boolean);
begin
  IsAutoSync := _IsAutoSync;
end;

procedure TBackupPathSetAutoSyncHandle.SetSyncInterval(_SyncTimeType,
  _SyncTimeValue : Integer);
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupPathSetAutoSyncHandle.SetToFace;
var
  VstBackupPathSetSyncMins : TVstBackupPathSetSyncTime;
begin
  VstBackupPathSetSyncMins := TVstBackupPathSetSyncTime.Create( FullPath );
  VstBackupPathSetSyncMins.SetIsAutoSync( IsAutoSync );
  VstBackupPathSetSyncMins.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  MyBackupFileFace.AddChange( VstBackupPathSetSyncMins );
end;

procedure TBackupPathSetAutoSyncHandle.SetToInfo;
var
  BackupPathSetSyncMinsInfo : TBackupPathSetSyncMinsInfo;
begin
  BackupPathSetSyncMinsInfo := TBackupPathSetSyncMinsInfo.Create( FullPath );
  BackupPathSetSyncMinsInfo.SetIsAutoSync( IsAutoSync );
  BackupPathSetSyncMinsInfo.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyBackupFileInfo.AddChange( BackupPathSetSyncMinsInfo );
end;

procedure TBackupPathSetAutoSyncHandle.SetToXml;
var
  BackupPathSetSyncMinsXml : TBackupPathSetSyncMinsXml;
begin
  BackupPathSetSyncMinsXml := TBackupPathSetSyncMinsXml.Create( FullPath );
  BackupPathSetSyncMinsXml.SetIsAutoSync( IsAutoSync );
  BackupPathSetSyncMinsXml.SetSyncInterval( SyncTimeType, SyncTimeValue );
  MyBackupXmlWrite.AddChange( BackupPathSetSyncMinsXml );
end;

procedure TBackupPathSetAutoSyncHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathRefreshLastSyncTimeHanlde }

procedure TBackupPathRefreshLastSyncTimeHandle.SetToFace;
var
  VstBackuppathRefreshNextSyncTime : TVstBackuppathRefreshNextSyncTime;
begin
  VstBackuppathRefreshNextSyncTime := TVstBackuppathRefreshNextSyncTime.Create( FullPath );
  MyBackupFileFace.AddChange( VstBackuppathRefreshNextSyncTime );
end;

procedure TBackupPathRefreshLastSyncTimeHandle.Update;
begin
  SetToFace;
end;

{ TBackupPathSetIsDisableHandle }

procedure TBackupPathSetIsDisableHandle.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupPathSetIsDisableHandle.SetToFace;
var
  VstBackupPathIsDisable : TVstBackupPathIsDisable;
begin
  VstBackupPathIsDisable := TVstBackupPathIsDisable.Create( FullPath );
  VstBackupPathIsDisable.SetIsDisable( IsDisable );
  MyBackupFileFace.AddChange( VstBackupPathIsDisable );
end;

procedure TBackupPathSetIsDisableHandle.SetToInfo;
var
  BackupPathIsDisableInfo : TBackupPathIsDisableInfo;
begin
  BackupPathIsDisableInfo := TBackupPathIsDisableInfo.Create( FullPath );
  BackupPathIsDisableInfo.SetIsDisable( IsDisable );
  MyBackupFileInfo.AddChange( BackupPathIsDisableInfo );
end;

procedure TBackupPathSetIsDisableHandle.SetToXml;
var
  BackupPathIsDisableXml : TBackupPathIsDisableXml;
begin
  BackupPathIsDisableXml := TBackupPathIsDisableXml.Create( FullPath );
  BackupPathIsDisableXml.SetIsDisable( IsDisable );
  MyBackupXmlWrite.AddChange( BackupPathIsDisableXml );
end;

procedure TBackupPathSetIsDisableHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupPathSetIsBackupNowHandle }

procedure TBackupPathSetIsBackupNowHandle.SetIsBackupNow(_IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupPathSetIsBackupNowHandle.SetToXml;
var
  BackupPathIsBackupNowXml : TBackupPathIsBackupNowXml;
begin
  BackupPathIsBackupNowXml := TBackupPathIsBackupNowXml.Create( FullPath );
  BackupPathIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  MyBackupXmlWrite.AddChange( BackupPathIsBackupNowXml );
end;

procedure TBackupPathSetIsBackupNowHandle.SetToInfo;
var
  BackupPathIsBackupNowInfo : TBackupPathIsBackupNowInfo;
begin
  BackupPathIsBackupNowInfo := TBackupPathIsBackupNowInfo.Create( FullPath );
  BackupPathIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  MyBackupFileInfo.AddChange( BackupPathIsBackupNowInfo );
end;

procedure TBackupPathSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ TBackupFolderAddMaskControl }

procedure TBackupFolderCancelBackupControl.AddToExcludeFilter;
var
  RootPath : string;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // ��ȡ ��·��
  RootPath := MyBackupPathInfoUtil.ReadRootPath( FolderPath );

    // ��� �ų�����
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( RootPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_Path, FolderPath );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

constructor TBackupFolderCancelBackupControl.Create(_FolderPath: string);
begin
  FolderPath := _FolderPath;
end;

procedure TBackupFolderCancelBackupControl.RemoveFolder;
var
  BackupFolderRemoveHandle : TBackupFolderRemoveHandle;
begin
  BackupFolderRemoveHandle := TBackupFolderRemoveHandle.Create( FolderPath );
  BackupFolderRemoveHandle.Update;
  BackupFolderRemoveHandle.Free;
end;

procedure TBackupFolderCancelBackupControl.Update;
begin
  AddToExcludeFilter;
  RemoveFolder;
end;

{ TBackupFileAddMaskControl }

procedure TBackupFileCancelBackupControl.AddToExcludeFilter;
var
  RootPath : string;
  BackupPathExcludeFilterAddHandle : TBackupPathExcludeFilterAddHandle;
begin
    // ��ȡ ��·��
  RootPath := MyBackupPathInfoUtil.ReadRootPath( FilePath );

    // ��� �ų�����
  BackupPathExcludeFilterAddHandle := TBackupPathExcludeFilterAddHandle.Create( RootPath );
  BackupPathExcludeFilterAddHandle.SetFilterInfo( FilterType_Path, FilePath );
  BackupPathExcludeFilterAddHandle.Update;
  BackupPathExcludeFilterAddHandle.Free;
end;

constructor TBackupFileCancelBackupControl.Create(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TBackupFileCancelBackupControl.RemoveFile;
var
  BackupFileRemoveHandle : TBackupFileRemoveHandle;
begin
  BackupFileRemoveHandle := TBackupFileRemoveHandle.Create( FilePath );
  BackupFileRemoveHandle.Update;
  BackupFileRemoveHandle.Free;
end;

procedure TBackupFileCancelBackupControl.Update;
begin
  AddToExcludeFilter;
  RemoveFile;
end;

{ TBackupPathSyncHandle }

procedure TBackupPathSyncHandle.AddToInfo;
var
  BackupPathFreeScanJobInfo : TBackupPathSyncInfo;
begin
  BackupPathFreeScanJobInfo := TBackupPathSyncInfo.Create( FullPath );
  BackupPathFreeScanJobInfo.SetIsShowFreeLimt( IsShowFreeLimt );
  MyBackupFileInfo.AddChange( BackupPathFreeScanJobInfo );
end;

procedure TBackupPathSyncHandle.SetIsShowFreeLimt(_IsShowFreeLimt: Boolean);
begin
  IsShowFreeLimt := _IsShowFreeLimt;
end;

procedure TBackupPathSyncHandle.Update;
begin
  AddToInfo;
end;

end.

