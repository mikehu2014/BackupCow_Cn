unit UMyFileTransferControl;

interface

uses classes, VirtualTrees, SysUtils, Generics.Collections, uDebug;

type

{$Region ' �޸� ����·�� ' }

  {$Region ' ����͸����� ' }

    // �޸� ���� ����
  TSendFileChangeHandle = class
  public
    RootPath, DestinationID : string;
  public
    constructor Create( _RootPath, _DestinationID : string );
  end;

  {$EndRegion}

  {$Region ' �޸� ��·�� ' }

      // ��ȡ ���͸�·��
  TSendFileReadRootHandle = class( TSendFileChangeHandle )
  private
    FileSize, CompletedSize : Int64;
    FileCount : Integer;
    SendFileStatus : string;
    SendPathType : string;
  public
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetFileCount( _FileCount : Integer );
    procedure SetSendFileStatus( _SendFileStatus : string );
    procedure SetSendPathType( _SendPathType : string );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ��� ���͸�·��
  TSendFileAddRootHandle = class( TSendFileReadRootHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
    procedure AddToRemotePc;
  private
    function CheckExistScanning : Boolean;
  end;

    // ���� ɾ�� ��Ŀ¼ ����
  TSendFileRemoveRootHandle = class( TSendFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  private
    procedure RemoveFromRemote;
    procedure AddToFileSendCancelList;
    procedure RemoveFileScanningInfo;
  private
    procedure RemoveOfflineJob;
  end;

    // �޸� ��·�� ����״̬
  TSendFileSetStatusHandle = class( TSendFileChangeHandle )
  public
    SendFileStatus : string;
  public
    procedure SetSendFileStatus( _SendFileStatus : string );
    procedure Update;
  private
    procedure SetToXml;
    procedure SetToInfo;
    procedure SetToFace;
  end;

    // �޸� ��·�� �ռ���Ϣ
  TSendFileSetSpaceHandle = class( TSendFileChangeHandle )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;
  private
    procedure SetToXml;
    procedure SetToFace;
    procedure SetToInfo;
  private
    procedure SetToRemote;
  end;

    // ��� ����� �ռ�
  TSendFileAddCompletedSpaceHandle = class( TSendFileChangeHandle )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;
  private
    procedure SetToXml;
    procedure SetToFace;
    procedure SetToInfo;
  private
    procedure SetToRemote;
  end;

    // ��� �����Ƿ����
  TSendFileCheckCompletedHandle = class( TSendFileChangeHandle )
  public
    procedure Update;
  private
    procedure SendCompletedToRemote;
  end;

  {$Region ' ����ȡ������,֪ͨĿ��,��Ŀ������ ' }

    // ��ȡ
  TSendFileCancelReadHandle = class( TSendFileChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // ���
  TSendFileCancelAddHandle = class( TSendFileCancelReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TSendFileCancelRemoveHandle = class( TSendFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' �޸� ��·�� ' }

      // �޸� ��·�� ����
  TSendFileChangeChildHandle = class( TSendFileChangeHandle )
  protected
    FilePath : string;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // ��ȡ ������·��
  TSendFileReadChildHandle = class( TSendFileChangeChildHandle )
  protected
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    procedure SetFileInfo( _FileSize, _Position : Int64; _FileTime : TDateTime );
    procedure Update;virtual;
  protected
    procedure AddToFace;
    procedure AddToMyJobInfo;
  protected
    procedure AddToSendDisableInfo;
  end;

    // ��� ������·��
  TSendFileAddChildHandle = class( TSendFileReadChildHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ������ɺ� ɾ�� �ӽڵ� ����
  TSendFileRemoveChildHandle = class( TSendFileChangeChildHandle )
  public
    procedure Update;
  private
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  end;

    // ���� ɾ�� �ӽڵ� ���� Job
  TSendFileRemoveChildJobHandle = class( TSendFileChangeChildHandle )
  public
    procedure Update;
  private
    procedure RemoveTransferJob;
  end;

    // �޸� �ӽڵ� ״̬
  TSendFileSetChildStatusHandle = class( TSendFileChangeChildHandle )
  private
    SendFileStatus : string;
  public
    procedure SetSendFileStatus( _SendFileStatus : string );
    procedure Update;
  private
    procedure SetToFace;
  end;

    // ��� ����� �ռ�
  TSendFileChildAddCompletedSpaceHandle = class( TSendFileChangeChildHandle )
  private
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;
  private
    procedure SetToFace;
  end;

  {$EndRegion}

  {$Region ' �ⲿ�ӿ� ' }

  {$Region ' �����ļ� ״̬�仯 ' }

    // ���շ� ���ش���״̬
  TSendFileTransferFeedbackHandle = class( TSendFileChangeHandle )
  public
    SendPathStatus : string;
  public
    procedure SetSendPathStatus( _SendPathStatus : string );
    procedure Update;
  private
    procedure AddToTransferScan;
  end;

    // ���շ� ȡ������
  TSendFileCancelReceiveHandle = class( TSendFileChangeHandle )
  public
    procedure Update;
  private
    procedure AddToXml;
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ����·�� �������
  TSendFileCompletedHandle = class( TSendFileChangeHandle )
  public
    procedure Update;
  private
    procedure SetCompletedStatus;
    procedure SendToRemotePc;
  end;

  {$EndRegion}

  {$Region ' Pc ��/���� ' }

    // Pc ����
  TSendFilePcOnlineHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;
  private
    procedure SetToRootFace;
    procedure SendFileSendRequest;
    procedure SendFileSendCancelList;
  end;

    // Pc ����
  TSendFilePcOfflineHandle = class
  public
    PcID : string;
  public
    constructor Create( _PcID : string );
    procedure Update;
  private
    procedure SetToRootFace;
  end;

      // �����ļ������� Ŀ�� Pc ����
  TSendFileOfflineHandle = class( TSendFileChangeHandle )
  public
    ChildFilePath : string;
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    procedure SetChildFilePath( _ChildFilePath : string );
    procedure SetPostion( _Position : Int64 );
    procedure SetFileInfo( _FileSize: Int64; _FileTime : TDateTime );
    procedure Update;
  private
    procedure SetFileSendFaceOffline;
    procedure SetFileSendPositionXml;
    procedure AddToMyJob;
  end;

  {$EndRegion}

  {$Region ' ��Ѱ���� ' }

    // ��Ѱ� ת ���Ѱ� ���� ������ļ�
  TSendFileEnableChildHandle = class( TSendFileChangeChildHandle )
  protected
    FileSize, Position : Int64;
    FileTime : TDateTime;
  public
    procedure Update;
  private
    procedure SetToFace;
    procedure AddToMyJobInfo;
    procedure RemoveFromSendDisableInfo;
  end;

    // ע������
  TSendFileEnterProEditionHandle = class
  public
    procedure Update;
  private
    procedure EnableBigSendFile( RootPath, DesPcID, FilePath : string );
  end;

  {$EndRegion}

  {$EndRegion}

  {$Region ' ɨ�� ���·����Ϣ ' }

      // ��� �����ļ�ǰ��ɨ��
  TSendFileAddScaningHandle = class
  public
    FileList, DesPcList : TStringList;
  public
    constructor Create( _FileList, _DesPcList : TStringList );
    procedure Update;
  private
    procedure AddToScanFace;
    procedure AddToScanningInfo( ScanningPath, DesPcID : string );
  private
    procedure AddToFolderScan;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' �޸� ����·�� ' }

    // �޸� ����
  TReceiveFileChangeHandle = class
  public
    SourceFilePath, SourcePcID : string;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
  end;

  {$Region ' �ļ����� ' }

    // ��ȡ ����·��
  TReceiveFileReadHandle = class( TReceiveFileChangeHandle )
  private
    SendPathType : string;
    FileSize, CompletedSize : Int64;
    RecevicePath, ReceiveStatus : string;
  public
    procedure SetSendPathType( _SendPathType : string );
    procedure SetFileSpaceInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetReceivePath( _RecevicePath : string );
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;virtual;
  protected
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // ��� ����·��
  TReceiveFileAddHandle = class( TReceiveFileReadHandle )
  private
    FileCount : Integer;
  public
    procedure SetFileCount( _FileCount : Integer );
    procedure Update;override;
  protected
    procedure AddToXml;
    procedure AddToShowHint;
  end;

    // ɾ�� ����·��
  TReceiveFileRemoveHandle = class( TReceiveFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
  private
    procedure RemoveFromRemote;
    procedure AddToCancelList;
  end;

    // ���� ����·�� �ռ���Ϣ
  TReceiveFileSetSpaceHandle = class( TReceiveFileChangeHandle )
  private
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;
  private
    procedure SetFace;
    procedure SetXml;
  end;

    // ��� ����� �ռ���Ϣ
  TReceiveFileAddCompletedSpaceHandle = class( TReceiveFileChangeHandle )
  private
    CompletedSpace : Int64;
  public
    procedure SetCompletedSpace( _CompletedSpace : Int64 );
    procedure Update;
  private
    procedure SetToFace;
    procedure SetToXml;
  end;

    // ����·�� ����״̬�仯
  TReceiveFileSetStatusHandle = class( TReceiveFileChangeHandle )
  private
    ReceiveStatus : string;
  public
    procedure SetReceiveStatus( _ReceiveStatus : string );
    procedure Update;
  private
    procedure SetFace;
    procedure SetInfo;
    procedure SetXml;
  end;

  {$EndRegion}

  {$Region ' ȡ�� �ļ����� ' }

    // ��ȡ
  TReceiveFileCancelReadHandle = class( TReceiveFileChangeHandle )
  public
    procedure Update;virtual;
  protected
    procedure AddToInfo;
  end;

    // ���
  TReceiveFileCancelAddHandle = class( TReceiveFileCancelReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // ɾ��
  TReceiveFileCancelRemoveHandle = class( TReceiveFileChangeHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromXml;
  end;

  {$EndRegion}

  {$Region ' Pc ���� ' }

      // �ı� Pc ����״̬
  TReceiveFileOnlineHandle = class
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;
  private
    procedure SetToFace;
    procedure SendReceiveCancelList;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ����·�� ��Ӳ��� ' }

    // ��� ����·�� �Ƿ������ͬ, ��������ɾ��
  TAddSendFileHandle = class
  public
    SendPathList, DesPcList : TStringList;
  public
    constructor Create( _SendPathList, _DesPcList : TStringList );
    procedure Update;
  private       // ɾ�� �ظ��� �ļ�����Item
    procedure RemoveConflict;
    procedure RemoveConflictPath( SendPath, DesPcID : string );
  private
    procedure AddToSendFileScan;
  end;

    // ���� ������
  ReceiveFileControlUtil = class
  public
    class function getReceivePath( SendRootPath : string ): string;
  private
    class function ExistPath( ReceivePath : string ): Boolean;
  end;

    // ��� ����·�� �Ƿ������ͬ, ��������ɾ��
  TAddReceiveFileHandle = class
  public
    SourceFilePath, SourcePcID : string;
    SendPathType : string;
    ReceivePath : string;
  public
    FileSize : Int64;
    FileCount : Integer;
  public
    constructor Create( _SourceFilePath, _SourcePcID : string );
    procedure SetSendPathType( _SendPathType : string );
    procedure SetFileInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;
  protected
    procedure FindReceicePath;virtual;
    procedure RemoveExistPath;
    procedure AddReceivePath;
    procedure AddToSendFeedBack;
  end;

    // �Զ�����
  TAddReceiveFileAutoHandle = class( TAddReceiveFileHandle )
  protected
    procedure FindReceicePath;override;
  end;

    // �ֶ�����
  TAddReceiveFileManualHandle = class( TAddReceiveFileHandle )
  public
    procedure SetReceivePath( _ReceivePath : string );
  end;

{$EndRegion}

  TMyFileTransferControl = class
  public
    procedure AddSendFile( FileList, DesPcList : TStringList );
    procedure RemoveSendFile( FilePath, DesPcID : string );
  public
    procedure RemoveReceiveFile( SourceFilePath, SourcePcID : string );
  end;

const
    // ���� ·�� ����
  SendPathType_File = 'File';
  SendPathType_Folder = 'Folder';

    // ���� Item״̬
  SendPathStatus_Waiting = 'Waiting';
  SendPathStatus_Sending = 'Sending';
  SendPathStatus_Completed = 'Completed';
  SendPathStatus_Cancel = 'Cancel';

    // ���� ��ʾ״̬
  SendPathStatus_Incompleted = 'Incompleted';
  SendPathStatus_Offline = 'Offline';
  SendPathStatus_Disable = 'Disable';
  SendPathStatus_Scanning = 'Scanning';

    // ���� Item״̬
  ReceivePathStatus_Receiving = 'Receving';
  ReceivePathStatus_Cancel = 'Cancel';
  ReceivePathStatus_Completed = 'Completed';

    // ���� ��ʾ״̬
  ReceivePathStatus_Offline = 'Offline';

const
  RevFileTitle_RevFile = 'Receiving File';
  RevFileTitle_RevFolder = 'Receiving Folder';
  RevFileHint_Name = 'Name: ';
  RevFileHint_From = 'From: ';
  RevFileHint_Size = 'Size: ';
  RevFileHint_Count = 'Incloud: %d Files';

var
  MyFileTransferControl : TMyFileTransferControl;

implementation

uses UMyNetPcInfo, UMyFileTransferInfo, UMyFileTransferXml, UFileTransferFace, USettingInfo,
     UTransferJobScan, UMainForm, UMyClient, UJobFace, UMyJobInfo, UJobControl, UMyUtil, URegisterInfo,
     UMainFormFace, UChangeInfo;

{ TMyFileTransferControl }

procedure TMyFileTransferControl.AddSendFile(FileList, DesPcList: TStringList);
var
  AddSendFileHandle : TAddSendFileHandle;
begin
  AddSendFileHandle := TAddSendFileHandle.Create( FileList, DesPcList );
  AddSendFileHandle.Update;
  AddSendFileHandle.Free;
end;

procedure TMyFileTransferControl.RemoveReceiveFile(SourceFilePath,
  SourcePcID: string);
var
  ReceiveFileRemoveHandle : TReceiveFileRemoveHandle;
begin
  ReceiveFileRemoveHandle := TReceiveFileRemoveHandle.Create( SourceFilePath, SourcePcID );
  ReceiveFileRemoveHandle.Update;
  ReceiveFileRemoveHandle.Free;
end;

procedure TMyFileTransferControl.RemoveSendFile( FilePath, DesPcID : string );
var
  SendFileRemoveRootHandle : TSendFileRemoveRootHandle;
begin
    // ɾ��
  SendFileRemoveRootHandle := TSendFileRemoveRootHandle.Create( FilePath, DesPcID );
  SendFileRemoveRootHandle.Update;
  SendFileRemoveRootHandle.Free;
end;

{ TSendFileAddHandle }

procedure TSendFileAddChildHandle.AddToXml;
var
  FileSendAddChildXml : TFileSendAddChildXml;
begin
  FileSendAddChildXml := TFileSendAddChildXml.Create( RootPath, DestinationID );
  FileSendAddChildXml.SetFilePath( FilePath );
  FileSendAddChildXml.SetFileInfo( FileSize, FileTime );
  MyXmlChange.AddChange( FileSendAddChildXml );
end;

procedure TSendFileAddChildHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TSendFileAddRootHandle }

procedure TSendFileAddRootHandle.AddToRemotePc;
var
  ClientSendFileReqMsg : TClientSendFileReqMsg;
begin
  ClientSendFileReqMsg := TClientSendFileReqMsg.Create;
  ClientSendFileReqMsg.SetPcID( PcInfo.PcID );
  ClientSendFileReqMsg.SetSourceFilePath( RootPath );
  ClientSendFileReqMsg.SetSendPathType( SendPathType );
  ClientSendFileReqMsg.SetFileInfo( FileSize, FileCount );
  MyClient.SendMsgToPc( DestinationID, ClientSendFileReqMsg );
end;

procedure TSendFileAddRootHandle.AddToXml;
var
  FileSendAddRootXml : TFileSendAddRootXml;
begin
  FileSendAddRootXml := TFileSendAddRootXml.Create( RootPath, DestinationID );
  FileSendAddRootXml.SetSpaceInfo( FileSize, FileCount );
  FileSendAddRootXml.SetSendPathStatus( SendFileStatus );
  FileSendAddRootXml.SetSendPathType( SendPathType );
  MyXmlChange.AddChange( FileSendAddRootXml );
end;

function TSendFileAddRootHandle.CheckExistScanning: Boolean;
var
  FileSendScanRemoveInfo : TFileSendScanRemoveInfo;
begin
  FileSendScanRemoveInfo := TFileSendScanRemoveInfo.Create( RootPath, DestinationID );
  Result := FileSendScanRemoveInfo.get;
  FileSendScanRemoveInfo.Free;
end;

procedure TSendFileAddRootHandle.Update;
begin
    // ��ɨ�������ɾ��
  if not CheckExistScanning then
    Exit;

  inherited;

  AddToXml;

  AddToRemotePc;
end;

{ TSendFileReadRootHandle }

procedure TSendFileReadRootHandle.AddToFace;
var
  DestinationName : string;
  PcIsOnline : Boolean;
  VstMyFileSendAddInfo : TVstMyFileSendAddInfo;
begin
  DestinationName := MyNetPcInfoReadUtil.ReadName( DestinationID );
  PcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DestinationID );

  VstMyFileSendAddInfo := TVstMyFileSendAddInfo.Create( RootPath, DestinationID );
  VstMyFileSendAddInfo.SetPcName( DestinationName );
  VstMyFileSendAddInfo.SetFileSpaceInfo( FileSize, CompletedSize );
  VstMyFileSendAddInfo.SetStatus( SendFileStatus );
  VstMyFileSendAddInfo.SetPcIsOnline( PcIsOnline );
  VstMyFileSendAddInfo.SetSendPathType( SendPathType );
  MyFaceChange.AddChange( VstMyFileSendAddInfo );
end;

procedure TSendFileReadRootHandle.AddToInfo;
var
  FileSendAddInfo : TFileSendAddInfo;
begin
  FileSendAddInfo := TFileSendAddInfo.Create( RootPath, DestinationID );
  FileSendAddInfo.SetSendPathStatus( SendFileStatus, SendPathType );
  FileSendAddInfo.SetFileSpaceInfo( FileSize, CompletedSize );
  FileSendAddInfo.SetFileCount( FileCount );
  FileSendAddInfo.Update;
  FileSendAddInfo.Free;
end;

procedure TSendFileReadRootHandle.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TSendFileReadRootHandle.SetFileSpaceInfo(_FileSize,
  _CompletedSize : Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TSendFileReadRootHandle.SetSendFileStatus(_SendFileStatus: string);
begin
  SendFileStatus := _SendFileStatus;
end;

procedure TSendFileReadRootHandle.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TSendFileReadRootHandle.Update;
begin
  AddToInfo;

  AddToFace;
end;

{ TSendFileReadChildHandle }

procedure TSendFileReadChildHandle.AddToFace;
var
  DesPcName : string;
  DesPcIsOnline : Boolean;
  VstMyFileSendAddChildInfo : TVstMyFileSendAddChildInfo;
begin
    // ��ȡ Ŀ����Ϣ
  DesPcName := MyNetPcInfoReadUtil.ReadName( DestinationID );
  DesPcIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( DestinationID );

    // ����ӽڵ�
  VstMyFileSendAddChildInfo := TVstMyFileSendAddChildInfo.Create( RootPath, DestinationID );
  VstMyFileSendAddChildInfo.SetPcName( DesPcName );
  VstMyFileSendAddChildInfo.SetChildPath( FilePath );
  VstMyFileSendAddChildInfo.SetFileSpaceInfo( FileSize, Position );
  VstMyFileSendAddChildInfo.SetStatus( SendPathStatus_Waiting );
  VstMyFileSendAddChildInfo.SetPcIsOnline( DesPcIsOnline );
  MyFaceChange.AddChange( VstMyFileSendAddChildInfo );
end;

procedure TSendFileReadChildHandle.AddToMyJobInfo;
var
  TransferFileSendJobAddHandle : TTransferFileSendJobAddHandle;
begin
  TransferFileSendJobAddHandle := TTransferFileSendJobAddHandle.Create( FilePath, DestinationID );
  TransferFileSendJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferFileSendJobAddHandle.Update;
  TransferFileSendJobAddHandle.Free;
end;

procedure TSendFileReadChildHandle.AddToSendDisableInfo;
var
  FileSendDisableAddInfo : TFileSendDisableAddInfo;
begin
  FileSendDisableAddInfo := TFileSendDisableAddInfo.Create( RootPath, DestinationID );
  FileSendDisableAddInfo.SetFilePath( FilePath );
  FileSendDisableAddInfo.Update;
  FileSendDisableAddInfo.Free;
end;

procedure TSendFileReadChildHandle.SetFileInfo(_FileSize, _Position: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  Position := _Position;
  FileTime := _FileTime;
end;

procedure TSendFileReadChildHandle.Update;
begin
    // Send File ����
  AddToFace;

    // ��Ѱ湦������
  if EditionUtil.getIsLimitFileSendSpace( FileSize ) then
    AddToSendDisableInfo // ��¼ Disable
  else
    AddToMyJobInfo;   // ��� Job
end;

{ TSendFileChangeHandle }

constructor TSendFileChangeHandle.Create(_RootPath, _DestinationID: string);
begin
  RootPath := _RootPath;
  DestinationID := _DestinationID;
end;

{ TSendFileRemoveRootHandle }

procedure TSendFileRemoveRootHandle.AddToFileSendCancelList;
var
  SendFileCancelAddHandle : TSendFileCancelAddHandle;
begin
  SendFileCancelAddHandle := TSendFileCancelAddHandle.Create( RootPath, DestinationID );
  SendFileCancelAddHandle.Update;
  SendFileCancelAddHandle.Free;
end;

procedure TSendFileRemoveRootHandle.RemoveFileScanningInfo;
var
  FileSendScanRemoveInfo : TFileSendScanRemoveInfo;
begin
  FileSendScanRemoveInfo := TFileSendScanRemoveInfo.Create( RootPath, DestinationID );
  FileSendScanRemoveInfo.get;
  FileSendScanRemoveInfo.Free;
end;

procedure TSendFileRemoveRootHandle.RemoveFromFace;
var
  VstMyFileSendRemoveInfo : TVstMyFileSendRemoveInfo;
begin
  VstMyFileSendRemoveInfo := TVstMyFileSendRemoveInfo.Create( RootPath, DestinationID );
  MyFaceChange.AddChange( VstMyFileSendRemoveInfo );
end;

procedure TSendFileRemoveRootHandle.RemoveFromInfo;
var
  FileSendRemoveInfo : TFileSendRemoveInfo;
begin
  FileSendRemoveInfo := TFileSendRemoveInfo.Create( RootPath, DestinationID );
  FileSendRemoveInfo.Update;
  FileSendRemoveInfo.Free;
end;

procedure TSendFileRemoveRootHandle.RemoveFromRemote;
var
  ClientSendFileCancelMsg : TClientSendFileCancelMsg;
begin
  ClientSendFileCancelMsg := TClientSendFileCancelMsg.Create;
  ClientSendFileCancelMsg.SetPcID( PcInfo.PcID );
  ClientSendFileCancelMsg.SetSourceFilePath( RootPath );
  MyClient.SendMsgToPc( DestinationID, ClientSendFileCancelMsg );
end;

procedure TSendFileRemoveRootHandle.RemoveFromXml;
var
  FileSendRemoveXml : TFileSendRemoveXml;
begin
  FileSendRemoveXml := TFileSendRemoveXml.Create( RootPath, DestinationID );
  MyXmlChange.AddChange( FileSendRemoveXml );
end;

procedure TSendFileRemoveRootHandle.RemoveOfflineJob;
var
  TransferJobOnlineInfo : TTransferJobOnlineInfo;
begin
  TransferJobOnlineInfo := TTransferJobOnlineInfo.Create;
  TransferJobOnlineInfo.SetOnlinePcID( '' );
  TransferJobOnlineInfo.SetJobType( JobType_FileSend );
  MyJobInfo.AddChange( TransferJobOnlineInfo );
end;

procedure TSendFileRemoveRootHandle.Update;
begin
    // ·��δ�������,  ɾ�� Զ��
  if not MyFileSendInfoReadUtil.ReadIsCompleted( RootPath, DestinationID ) then
  begin
    if MyNetPcInfoReadUtil.ReadIsOnline( DestinationID ) then
      RemoveFromRemote
    else
      AddToFileSendCancelList;
  end;

    // ɾ�� ����
  RemoveFileScanningInfo;
  RemoveFromInfo;
  RemoveOfflineJob;

    // ɾ�� �����Xml
  RemoveFromFace;
  RemoveFromXml;
end;

{ TSendFileSetSpaceHandle }

procedure TSendFileSetSpaceHandle.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TSendFileSetSpaceHandle.SetToFace;
var
  VstMyFileSendSpaceInfo : TVstMyFileSendSpaceInfo;
begin
  VstMyFileSendSpaceInfo := TVstMyFileSendSpaceInfo.Create( RootPath, DestinationID );
  VstMyFileSendSpaceInfo.SetFileSize( FileSize );
  MyFaceChange.AddChange( VstMyFileSendSpaceInfo );
end;

procedure TSendFileSetSpaceHandle.SetToInfo;
var
  FileSendSetChildSendSizeInfo : TFileSendSetSendSizeInfo;
begin
  FileSendSetChildSendSizeInfo := TFileSendSetSendSizeInfo.Create( RootPath, DestinationID );
  FileSendSetChildSendSizeInfo.SetSendFileSize( FileSize );
  FileSendSetChildSendSizeInfo.Update;
  FileSendSetChildSendSizeInfo.Free;
end;

procedure TSendFileSetSpaceHandle.SetToRemote;
var
  ClientSendFileSpaceMsg : TClientSendFileSpaceMsg;
begin
  ClientSendFileSpaceMsg := TClientSendFileSpaceMsg.Create;
  ClientSendFileSpaceMsg.SetSourceFilePath( RootPath );
  ClientSendFileSpaceMsg.SetPcID( PcInfo.PcID );
  ClientSendFileSpaceMsg.SetFileSize( FileSize );
  MyClient.SendMsgToPc( DestinationID, ClientSendFileSpaceMsg );
end;

procedure TSendFileSetSpaceHandle.SetToXml;
var
  FileSendSpaceXml : TFileSendSpaceXml;
begin
  FileSendSpaceXml := TFileSendSpaceXml.Create( RootPath, DestinationID );
  FileSendSpaceXml.SetFileSize( FileSize );
  MyXmlChange.AddChange( FileSendSpaceXml );
end;

procedure TSendFileSetSpaceHandle.Update;
begin
  SetToXml;

  SetToFace;

  SetToInfo;

  SetToRemote;
end;

{ TReceiveFileChangeHandle }

constructor TReceiveFileChangeHandle.Create(_SourceFilePath,
  _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

{ TReceiveFileAddHandle }

procedure TReceiveFileAddHandle.AddToShowHint;
var
  TitleStr, HintStr : string;
  SourceFileName : string;
  ShowTrayHintStr : TShowTrayHintStr;
begin
    // ����ʾ Hint
  if not FileReceiveSettingInfo.IsRevFileShowHint then
    Exit;

    // Hint ����
  if SendPathType = SendPathType_File then
    TitleStr := RevFileTitle_RevFile
  else
    TitleStr := RevFileTitle_RevFolder;

    // Hint ����
  SourceFileName := MyNetPcInfoReadUtil.ReadName( SourcePcID );
  HintStr := RevFileHint_Name + MyFileInfo.getFileName( RecevicePath );
  HintStr := HintStr + #13#10 + RevFileHint_From + SourceFileName;
  HintStr := HintStr + #13#10 + RevFileHint_Size + MySize.getFileSizeStr( FileSize );
  if SendPathType = SendPathType_Folder then
    HintStr := HintStr + #13#10 + Format( RevFileHint_Count, [FileCount] );

    // ��ʾ Hint
  ShowTrayHintStr := TShowTrayHintStr.Create( TitleStr, HintStr );
  MyMainFormFace.AddChange( ShowTrayHintStr );
end;

procedure TReceiveFileAddHandle.AddToXml;
var
  FileReceiveAddXml : TFileReceiveAddXml;
begin
  FileReceiveAddXml := TFileReceiveAddXml.Create( SourceFilePath, SourcePcID );
  FileReceiveAddXml.SetSendPathType( SendPathType );
  FileReceiveAddXml.SetReceivePath( RecevicePath );
  FileReceiveAddXml.SetReceiveStatus( ReceiveStatus );
  MyXmlChange.AddChange( FileReceiveAddXml );
end;

procedure TReceiveFileAddHandle.SetFileCount(_FileCount: Integer);
begin
  FileCount := _FileCount;
end;

procedure TReceiveFileAddHandle.Update;
begin
  inherited;

  AddToXml;

  AddToShowHint;
end;

{ TReceiveFileReadHandle }

procedure TReceiveFileReadHandle.AddToFace;
var
  SourcePcName : string;
  SourceIsOnline : Boolean;
  LvFileReceiveAddInfo : TLvFileReceiveAddInfo;
begin
  SourcePcName := MyNetPcInfoReadUtil.ReadName( SourcePcID );
  SourceIsOnline := MyNetPcInfoReadUtil.ReadIsOnline( SourcePcID );

  LvFileReceiveAddInfo := TLvFileReceiveAddInfo.Create( SourceFilePath, SourcePcID );
  LvFileReceiveAddInfo.SetSourcePcName( SourcePcName );
  LvFileReceiveAddInfo.SetFileSpaceInfo( FileSize, CompletedSize );
  LvFileReceiveAddInfo.SetSendPathType( SendPathType );
  LvFileReceiveAddInfo.SetReceivePath( RecevicePath );
  LvFileReceiveAddInfo.SetReceiveStatus( ReceiveStatus );
  LvFileReceiveAddInfo.SetSourcePcIsOnline( SourceIsOnline );
  MyFaceChange.AddChange( LvFileReceiveAddInfo );
end;

procedure TReceiveFileReadHandle.AddToInfo;
var
  FileReceiveAddInfo : TFileReceiveAddInfo;
begin
  FileReceiveAddInfo := TFileReceiveAddInfo.Create( SourceFilePath, SourcePcID );
  FileReceiveAddInfo.SetReceivePath( RecevicePath );
  FileReceiveAddInfo.SetReceiveStatus( ReceiveStatus );
  FileReceiveAddInfo.Update;
  FileReceiveAddInfo.Free;
end;

procedure TReceiveFileReadHandle.SetFileSpaceInfo(_FileSize, _CompletedSize : Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TReceiveFileReadHandle.SetReceivePath(_RecevicePath: string);
begin
  RecevicePath := _RecevicePath;
end;

procedure TReceiveFileReadHandle.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TReceiveFileReadHandle.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TReceiveFileReadHandle.Update;
begin
  AddToInfo;

  AddToFace;
end;

{ TReceiveFileRemoveHandle }

procedure TReceiveFileRemoveHandle.AddToCancelList;
var
  ReceiveFileCancelAddHandle : TReceiveFileCancelAddHandle;
begin
  ReceiveFileCancelAddHandle := TReceiveFileCancelAddHandle.Create( SourceFilePath, SourcePcID );
  ReceiveFileCancelAddHandle.Update;
  ReceiveFileCancelAddHandle.Free;
end;

procedure TReceiveFileRemoveHandle.RemoveFromFace;
var
  LvFileReceiveRemoveInfo : TLvFileReceiveRemoveInfo;
begin
  LvFileReceiveRemoveInfo := TLvFileReceiveRemoveInfo.Create( SourceFilePath, SourcePcID );
  MyFaceChange.AddChange( LvFileReceiveRemoveInfo );
end;

procedure TReceiveFileRemoveHandle.RemoveFromInfo;
var
  FileReceiveRemoveInfo : TFileReceiveRemoveInfo;
begin
  FileReceiveRemoveInfo := TFileReceiveRemoveInfo.Create( SourceFilePath, SourcePcID );
  FileReceiveRemoveInfo.Update;
  FileReceiveRemoveInfo.Free;
end;

procedure TReceiveFileRemoveHandle.RemoveFromRemote;
var
  ClientReceiveFileCancelMsg : TClientReceiveFileCancelMsg;
begin
  ClientReceiveFileCancelMsg := TClientReceiveFileCancelMsg.Create;
  ClientReceiveFileCancelMsg.SetPcID( PcInfo.PcID );
  ClientReceiveFileCancelMsg.SetSourceFilePath( SourceFilePath );
  MyClient.SendMsgToPc( SourcePcID, ClientReceiveFileCancelMsg );
end;

procedure TReceiveFileRemoveHandle.RemoveFromXml;
var
  FileReceiveRemoveXml : TFileReceiveRemoveXml;
begin
  FileReceiveRemoveXml := TFileReceiveRemoveXml.Create( SourceFilePath, SourcePcID );
  MyXmlChange.AddChange( FileReceiveRemoveXml );
end;

procedure TReceiveFileRemoveHandle.Update;
begin
     // û�н�����ɣ� ֪ͨ ���ͷ� ɾ��
  if not MyFileReceiveInfoReadUtil.ReadIsCompleted( SourceFilePath, SourcePcID ) then
  begin
    if MyNetPcInfoReadUtil.ReadIsOnline( SourcePcID ) then
      RemoveFromRemote
    else
      AddToCancelList;
  end;

    // ����ɾ��
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
end;

{ TReceiveFileSetSpaceHandle }

procedure TReceiveFileSetSpaceHandle.SetFace;
var
  LvFileReceiveSetSpaceInfo : TLvFileReceiveSetSpaceInfo;
begin
  LvFileReceiveSetSpaceInfo := TLvFileReceiveSetSpaceInfo.Create( SourceFilePath, SourcePcID );
  LvFileReceiveSetSpaceInfo.SetFileSize( FileSize );
  MyFaceChange.AddChange( LvFileReceiveSetSpaceInfo );
end;

procedure TReceiveFileSetSpaceHandle.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TReceiveFileSetSpaceHandle.SetXml;
var
  FileReceiveSetSpaceXml : TFileReceiveSetSpaceXml;
begin
  FileReceiveSetSpaceXml := TFileReceiveSetSpaceXml.Create( SourceFilePath, SourcePcID );
  FileReceiveSetSpaceXml.SetFileSize( FileSize );
  MyXmlChange.AddChange( FileReceiveSetSpaceXml );
end;

procedure TReceiveFileSetSpaceHandle.Update;
begin
  SetFace;

  SetXml;
end;

{ TSendFileRemoveChildHandle }

procedure TSendFileRemoveChildHandle.RemoveFromFace;
var
  VstMyFileSendRemoveChildInfo : TVstMyFileSendRemoveChildInfo;
begin
  VstMyFileSendRemoveChildInfo := TVstMyFileSendRemoveChildInfo.Create( RootPath, DestinationID );
  VstMyFileSendRemoveChildInfo.SetChildPath( FilePath );
  MyFaceChange.AddChange( VstMyFileSendRemoveChildInfo );
end;

procedure TSendFileRemoveChildHandle.RemoveFromXml;
var
  FileSendRemoveChildXml : TFileSendRemoveChildXml;
begin
  FileSendRemoveChildXml := TFileSendRemoveChildXml.Create( RootPath, DestinationID );
  FileSendRemoveChildXml.SetFilePath( FilePath );
  MyXmlChange.AddChange( FileSendRemoveChildXml );
end;

procedure TSendFileRemoveChildHandle.Update;
begin
  RemoveFromFace;

  RemoveFromXml;
end;

{ TSendFileCompletedHandle }

procedure TSendFileCompletedHandle.SendToRemotePc;
var
  ClientSendFileCompletedMsg : TClientSendFileCompletedMsg;
begin
  ClientSendFileCompletedMsg := TClientSendFileCompletedMsg.Create;
  ClientSendFileCompletedMsg.SetPcID( PcInfo.PcID );
  ClientSendFileCompletedMsg.SetSourceFilePath( RootPath );
  MyClient.SendMsgToPc( DestinationID, ClientSendFileCompletedMsg );
end;

procedure TSendFileCompletedHandle.SetCompletedStatus;
var
  SendFileSetStatusHandle : TSendFileSetStatusHandle;
begin
  SendFileSetStatusHandle := TSendFileSetStatusHandle.Create( RootPath, DestinationID );
  SendFileSetStatusHandle.SetSendFileStatus( SendPathStatus_Completed );
  SendFileSetStatusHandle.Update;
  SendFileSetStatusHandle.Free;
end;

procedure TSendFileCompletedHandle.Update;
begin
    // ����״̬Ϊ�����
  SetCompletedStatus;

    // ����Զ�������
  SendToRemotePc;
end;

{ TReceiveFileCompletedHandle }

procedure TReceiveFileSetStatusHandle.SetFace;
var
  LvFileReceiveSetStatusInfo : TLvFileReceiveSetStatusInfo;
begin
  LvFileReceiveSetStatusInfo := TLvFileReceiveSetStatusInfo.Create( SourceFilePath, SourcePcID );
  LvFileReceiveSetStatusInfo.SetReceiveStatus( ReceiveStatus );
  MyFaceChange.AddChange( LvFileReceiveSetStatusInfo );
end;

procedure TReceiveFileSetStatusHandle.SetInfo;
var
  FileReceiveStatusInfo : TFileReceiveStatusInfo;
begin
  FileReceiveStatusInfo := TFileReceiveStatusInfo.Create( SourceFilePath, SourcePcID );
  FileReceiveStatusInfo.SetReceiveStatus( ReceiveStatus );
  FileReceiveStatusInfo.Update;
  FileReceiveStatusInfo.Free;
end;

procedure TReceiveFileSetStatusHandle.SetReceiveStatus(_ReceiveStatus: string);
begin
  ReceiveStatus := _ReceiveStatus;
end;

procedure TReceiveFileSetStatusHandle.SetXml;
var
  FileReceiveSetStatusXml : TFileReceiveSetStatusXml;
begin
  FileReceiveSetStatusXml := TFileReceiveSetStatusXml.Create( SourceFilePath, SourcePcID );
  FileReceiveSetStatusXml.SetStatus( ReceiveStatus );
  MyXmlChange.AddChange( FileReceiveSetStatusXml );
end;

procedure TReceiveFileSetStatusHandle.Update;
begin
  SetFace;

  SetInfo;

  SetXml;
end;

{ TSendFileRemoveChildJobHandle }

procedure TSendFileRemoveChildJobHandle.RemoveTransferJob;
var
  TransferFileSendJobRemoveHandle : TTransferFileSendJobRemoveHandle;
begin
  TransferFileSendJobRemoveHandle := TTransferFileSendJobRemoveHandle.Create( FilePath, DestinationID );
  TransferFileSendJobRemoveHandle.Update;
  TransferFileSendJobRemoveHandle.Free;
end;

procedure TSendFileRemoveChildJobHandle.Update;
begin
  RemoveTransferJob;
end;

{ TSendFileContinusChildHandle }

procedure TSendFileOfflineHandle.AddToMyJob;
var
  TransferFileSendJobAddHandle : TTransferFileSendJobAddHandle;
begin
  TransferFileSendJobAddHandle := TTransferFileSendJobAddHandle.Create( ChildFilePath, DestinationID );
  TransferFileSendJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferFileSendJobAddHandle.Update;
  TransferFileSendJobAddHandle.Free;
end;

procedure TSendFileOfflineHandle.SetChildFilePath(_ChildFilePath: string);
begin
  ChildFilePath := _ChildFilePath;
end;

procedure TSendFileOfflineHandle.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TSendFileOfflineHandle.SetFileSendFaceOffline;
var
  VstMyFileSendChildStatusInfo : TVstMyFileSendChildStatusInfo;
begin
  VstMyFileSendChildStatusInfo := TVstMyFileSendChildStatusInfo.Create( RootPath, DestinationID );
  VstMyFileSendChildStatusInfo.SetChildPath( ChildFilePath );
  VstMyFileSendChildStatusInfo.SetSendStatus( SendPathStatus_Waiting );  // ���� Waiting �б�
  MyFaceChange.AddChange( VstMyFileSendChildStatusInfo );
end;

procedure TSendFileOfflineHandle.SetFileSendPositionXml;
var
  FileSendChildPositionXml : TFileSendChildPositionXml;
begin
  FileSendChildPositionXml := TFileSendChildPositionXml.Create( RootPath, DestinationID );
  FileSendChildPositionXml.SetFilePath( ChildFilePath );
  FileSendChildPositionXml.SetPosition( Position );
  MyXmlChange.AddChange( FileSendChildPositionXml );
end;

procedure TSendFileOfflineHandle.SetPostion(_Position: Int64);
begin
  Position := _Position;
end;

procedure TSendFileOfflineHandle.Update;
begin
    // ���� ������Ϣ
  SetFileSendFaceOffline;

    // ���� ����λ����Ϣ
  SetFileSendPositionXml;

    // ��� �� Job
  AddToMyJob;
end;

{ TSendFileRootOnlineInfo }

constructor TSendFilePcOnlineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TSendFilePcOnlineHandle.SendFileSendCancelList;
var
  SendCancelList : TStringList;
  i : Integer;
  SendFilePath : string;
  ClientSendFileCancelMsg : TClientSendFileCancelMsg;
  SendFileCancelRemoveHandle : TSendFileCancelRemoveHandle;
begin
  SendCancelList := MyFileSendInfoReadUtil.ReadPcCancelPathList(PcID);

  for i := 0 to SendCancelList.Count - 1 do
  begin
    SendFilePath := SendCancelList[i];

      // ���� ȡ������
    ClientSendFileCancelMsg := TClientSendFileCancelMsg.Create;
    ClientSendFileCancelMsg.SetPcID( PcInfo.PcID );
    ClientSendFileCancelMsg.SetSourceFilePath( SendFilePath );
    MyClient.SendMsgToPc( PcID, ClientSendFileCancelMsg );

      // ɾ�� ȡ������
    SendFileCancelRemoveHandle := TSendFileCancelRemoveHandle.Create( SendFilePath, PcID );
    SendFileCancelRemoveHandle.Update;
    SendFileCancelRemoveHandle.Free;
  end;

  SendCancelList.Free;
end;

procedure TSendFilePcOnlineHandle.SendFileSendRequest;
var
  WaitingPathList : TWaitingPathList;
  i : Integer;
  ClientSendFileReqMsg : TClientSendFileReqMsg;
  SendPath, SendPathType : string;
  FileSize : Int64;
  FileCount : Integer;
begin
    // ��ȡ �ȴ����͵�·��
  WaitingPathList := MyFileSendInfoReadUtil.ReadPcWattingPcList( PcID );

    // ���� ����
  for i := 0 to WaitingPathList.Count - 1 do
  begin
    SendPath := WaitingPathList[i].FullPath;
    SendPathType := WaitingPathList[i].PathType;
    FileSize := WaitingPathList[i].FileSize;
    FileCount := WaitingPathList[i].FileCount;

      // ���ʹ�������
    ClientSendFileReqMsg := TClientSendFileReqMsg.Create;
    ClientSendFileReqMsg.SetPcID( PcInfo.PcID );
    ClientSendFileReqMsg.SetSourceFilePath( SendPath );
    ClientSendFileReqMsg.SetSendPathType( SendPathType );
    ClientSendFileReqMsg.SetFileInfo( FileSize, FileCount );
    MyClient.SendMsgToPc( PcID, ClientSendFileReqMsg );
  end;

  WaitingPathList.Free;
end;

procedure TSendFilePcOnlineHandle.SetToRootFace;
var
  VstMyFilePcOnlineInfo : TVstMyFilePcOnlineInfo;
begin
  VstMyFilePcOnlineInfo := TVstMyFilePcOnlineInfo.Create( PcID );
  VstMyFilePcOnlineInfo.SetIsOnline( True );
  MyFaceChange.AddChange( VstMyFilePcOnlineInfo );
end;

procedure TSendFilePcOnlineHandle.Update;
begin
  SetToRootFace;

  SendFileSendRequest;

  SendFileSendCancelList;
end;

{ TAddSendFileHandle }

procedure TAddSendFileHandle.AddToSendFileScan;
var
  SendFileAddScaningHandle : TSendFileAddScaningHandle;
begin
     // ��� ·��
  SendFileAddScaningHandle := TSendFileAddScaningHandle.Create( SendPathList, DesPcList );
  SendFileAddScaningHandle.Update;
  SendFileAddScaningHandle.Free;
end;

constructor TAddSendFileHandle.Create(_SendPathList, _DesPcList: TStringList);
begin
  SendPathList := _SendPathList;
  DesPcList := _DesPcList;
end;


procedure TAddSendFileHandle.RemoveConflict;
var
  i, j : Integer;
  FilePath, DesPcID : string;
begin
    // ��� ������Ϣ
  for i := 0 to SendPathList.Count - 1 do
  begin
    FilePath := SendPathList[i];
    for j := 0 to DesPcList.Count - 1 do
    begin
      DesPcID := DesPcList[j];

        // ����Ѵ���, ��ɾ��
      RemoveConflictPath( FilePath, DesPcID );
    end;
  end;
end;

procedure TAddSendFileHandle.RemoveConflictPath(SendPath, DesPcID: string);
var
  ConflictPathList : TStringList;
  i : Integer;
begin
    // �ҳ���ͻ��·����ɾ��
  ConflictPathList := MyFileSendInfoReadUtil.ReadConflictPathList( SendPath, DesPcID );
  for i := 0 to ConflictPathList.Count - 1 do
    MyFileTransferControl.RemoveSendFile( ConflictPathList[i], DesPcID );
  ConflictPathList.Free;
end;

procedure TAddSendFileHandle.Update;
begin
    // ɾ�� �ɵķ���·��
  RemoveConflict;

    // ��� �µķ���·��
  AddToSendFileScan;
end;

{ TAddReceiveFileHandle }

procedure TAddReceiveFileHandle.AddReceivePath;
var
  ReceiveFileAddHandle : TReceiveFileAddHandle;
begin
    // ����ļ�����
  ReceiveFileAddHandle := TReceiveFileAddHandle.Create( SourceFilePath, SourcePcID );
  ReceiveFileAddHandle.SetReceivePath( ReceivePath );
  ReceiveFileAddHandle.SetSendPathType( SendPathType );
  ReceiveFileAddHandle.SetFileSpaceInfo( FileSize, 0 );
  ReceiveFileAddHandle.SetFileCount( FileCount );
  ReceiveFileAddHandle.SetReceiveStatus( ReceivePathStatus_Receiving );
  ReceiveFileAddHandle.Update;
  ReceiveFileAddHandle.Free;
end;

procedure TAddReceiveFileHandle.AddToSendFeedBack;
var
  ClientSendFileFeedbackMsg : TClientSendFileFeedbackMsg;
begin
    // ���� feedback ����
  ClientSendFileFeedbackMsg := TClientSendFileFeedbackMsg.Create;
  ClientSendFileFeedbackMsg.SetPcID( PcInfo.PcID );
  ClientSendFileFeedbackMsg.SetSourceFilePath( SourceFilePath );
  ClientSendFileFeedbackMsg.SetSendPathStatus( SendPathStatus_Sending );
  MyClient.SendMsgToPc( SourcePcID, ClientSendFileFeedbackMsg );
end;

constructor TAddReceiveFileHandle.Create(_SourceFilePath, _SourcePcID: string);
begin
  SourceFilePath := _SourceFilePath;
  SourcePcID := _SourcePcID;
end;

procedure TAddReceiveFileHandle.FindReceicePath;
begin

end;

procedure TAddReceiveFileHandle.RemoveExistPath;
var
  RemovePathList : TStringList;
  i : Integer;
  RemovePath : string;
  ReceiveFileRemoveHandle : TReceiveFileRemoveHandle;
begin
    // ��ȡ ��ͻ��·��
  RemovePathList := MyFileReceiveInfoReadUtil.ReadPcConfilectPath( SourceFilePath, SourcePcID );

    // ɾ��
  for i := 0 to RemovePathList.Count - 1 do
  begin
    RemovePath := RemovePathList[i];

    ReceiveFileRemoveHandle := TReceiveFileRemoveHandle.Create( RemovePath, SourcePcID );
    ReceiveFileRemoveHandle.Update;
    ReceiveFileRemoveHandle.Free;
  end;

  RemovePathList.Free;
end;

procedure TAddReceiveFileHandle.SetFileInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TAddReceiveFileHandle.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TAddReceiveFileHandle.Update;
begin
    // Ѱ�ҽ���·��
  FindReceicePath;

    // ɾ�� ���ڵĽ�����Ϣ
  RemoveExistPath;

    // ��� �µĽ�����Ϣ
  AddReceivePath;

    // ���� FeedBack ����
  AddToSendFeedBack;
end;

{ TSendFileTransferFeedbackHandle }

procedure TSendFileTransferFeedbackHandle.AddToTransferScan;
var
  FileList, DesPcList : TStringList;
  TransferScanInfo : TTransferScanInfo;
begin
  FileList := TStringList.Create;
  DesPcList := TStringList.Create;
  FileList.Add( RootPath );
  DesPcList.Add( DestinationID );

    // ��� ɨ����Ϣ
  TransferScanInfo := TTransferScanInfo.Create( ScanType_Job );
  TransferScanInfo.SetList( FileList, DesPcList );
  MyTransferJobScanInfo.AddScanInfo( TransferScanInfo );

  DesPcList.Free;
  FileList.Free;
end;

procedure TSendFileTransferFeedbackHandle.SetSendPathStatus(
  _SendPathStatus: string);
begin
  SendPathStatus := _SendPathStatus;
end;

procedure TSendFileTransferFeedbackHandle.Update;
var
  SendFileSetStatusHandle : TSendFileSetStatusHandle;
begin
    // ֻ�з�����������, ��ɨ��·��
  if SendPathStatus = SendPathStatus_Sending then
    AddToTransferScan;

    // ���� ״̬��Ϣ
  SendFileSetStatusHandle := TSendFileSetStatusHandle.Create( RootPath, DestinationID );
  SendFileSetStatusHandle.SetSendFileStatus( SendPathStatus );
  SendFileSetStatusHandle.Update;
  SendFileSetStatusHandle.Free;
end;

{ TReceiveFileOnlineHandle }

constructor TReceiveFileOnlineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TReceiveFileOnlineHandle.SendReceiveCancelList;
var
  ReceiveCancelList : TStringList;
  i : Integer;
  SourceFilePath : string;
  ClientReceiveFileCancelMsg : TClientReceiveFileCancelMsg;
  ReceiveFileCancelRemoveHandle : TReceiveFileCancelRemoveHandle;
begin
  if not IsOnline then
    Exit;

    // ��ȡ ȡ����·��
  ReceiveCancelList := MyFileReceiveInfoReadUtil.ReadPcCancelPathList( PcID );

  for i := 0 to ReceiveCancelList.Count - 1 do
  begin
    SourceFilePath := ReceiveCancelList[i];

      // ���� ȡ������
    ClientReceiveFileCancelMsg := TClientReceiveFileCancelMsg.Create;
    ClientReceiveFileCancelMsg.SetPcID( PcInfo.PcID );
    ClientReceiveFileCancelMsg.SetSourceFilePath( SourceFilePath );
    MyClient.SendMsgToPc( PcID, ClientReceiveFileCancelMsg );

      // ɾ�� ȡ������
    ReceiveFileCancelRemoveHandle := TReceiveFileCancelRemoveHandle.Create( SourceFilePath, PcID );
    ReceiveFileCancelRemoveHandle.Update;
    ReceiveFileCancelRemoveHandle.Free;
  end;

  ReceiveCancelList.Free;
end;

procedure TReceiveFileOnlineHandle.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TReceiveFileOnlineHandle.SetToFace;
var
  LvFileReceiveSetSourceOnlineInfo : TLvFileReceiveSetSourceOnlineInfo;
begin
  LvFileReceiveSetSourceOnlineInfo := TLvFileReceiveSetSourceOnlineInfo.Create( PcID );
  LvFileReceiveSetSourceOnlineInfo.SetIsOnline( IsOnline );
  MyFaceChange.AddChange( LvFileReceiveSetSourceOnlineInfo );
end;

procedure TReceiveFileOnlineHandle.Update;
begin
  SetToFace;

  SendReceiveCancelList;
end;

{ TSendFileCancelReceiveHandle }

procedure TSendFileCancelReceiveHandle.AddToFace;
var
  VstMyFileSendClearChildInfo : TVstMyFileSendCancelChildInfo;
  VstMyFileSendStatusInfo : TVstMyFileSendStatusInfo;
begin
    // ����ļ�
  VstMyFileSendClearChildInfo := TVstMyFileSendCancelChildInfo.Create( RootPath, DestinationID );
  MyFaceChange.AddChange( VstMyFileSendClearChildInfo );

    // ���� ȡ�� ״̬
  VstMyFileSendStatusInfo := TVstMyFileSendStatusInfo.Create( RootPath, DestinationID );
  VstMyFileSendStatusInfo.SetStatus( SendPathStatus_Cancel );
  MyFaceChange.AddChange( VstMyFileSendStatusInfo );
end;

procedure TSendFileCancelReceiveHandle.AddToInfo;
var
  FileSendRootStatusInfo : TFileSendRootStatusInfo;
begin
  FileSendRootStatusInfo := TFileSendRootStatusInfo.Create( RootPath, DestinationID );
  FileSendRootStatusInfo.SetSendPathStatus( SendPathStatus_Cancel );
  FileSendRootStatusInfo.Update;
  FileSendRootStatusInfo.Free;
end;

procedure TSendFileCancelReceiveHandle.AddToXml;
var
  FileSendClearChildXml : TFileSendClearChildXml;
  FileSendRootStatusXml : TFileSendRootStatusXml;
begin
    // ��� �����ӽڵ���Ϣ
  FileSendClearChildXml := TFileSendClearChildXml.Create( RootPath, DestinationID );
  MyXmlChange.AddChange( FileSendClearChildXml );

    // �޸� ״̬
  FileSendRootStatusXml := TFileSendRootStatusXml.Create( RootPath, DestinationID );
  FileSendRootStatusXml.SetSendPathStatus( SendPathStatus_Cancel );
  MyXmlChange.AddChange( FileSendRootStatusXml );
end;

procedure TSendFileCancelReceiveHandle.Update;
begin
  AddToXml;

  AddToInfo;

  AddToFace;
end;

{ TSendFileCancelAddHandle }

procedure TSendFileCancelAddHandle.AddToXml;
var
  FileSendCancelAddXml : TFileSendCancelAddXml;
begin
  FileSendCancelAddXml := TFileSendCancelAddXml.Create( RootPath, DestinationID );
  MyXmlChange.AddChange( FileSendCancelAddXml );
end;

procedure TSendFileCancelAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TReceiveFileCancelAddHandle }

procedure TReceiveFileCancelAddHandle.AddToXml;
var
  FileReceiveCancelAddXml : TFileReceiveCancelAddXml;
begin
  FileReceiveCancelAddXml := TFileReceiveCancelAddXml.Create( SourceFilePath, SourcePcID );
  MyXmlChange.AddChange( FileReceiveCancelAddXml );
end;

procedure TReceiveFileCancelAddHandle.Update;
begin
  inherited;

  AddToXml;
end;

{ TReceiveFileCancelRemoveHandle }

procedure TReceiveFileCancelRemoveHandle.RemoveFromInfo;
var
  FileReceiveCanceRemoveInfo : TFileReceiveCanceRemoveInfo;
begin
  FileReceiveCanceRemoveInfo := TFileReceiveCanceRemoveInfo.Create( SourceFilePath, SourcePcID );
  FileReceiveCanceRemoveInfo.Update;
  FileReceiveCanceRemoveInfo.Free;
end;

procedure TReceiveFileCancelRemoveHandle.RemoveFromXml;
var
  FileReceiveCancelRemoveXml : TFileReceiveCancelRemoveXml;
begin
  FileReceiveCancelRemoveXml := TFileReceiveCancelRemoveXml.Create( SourceFilePath, SourcePcID );
  MyXmlChange.AddChange( FileReceiveCancelRemoveXml );
end;

procedure TReceiveFileCancelRemoveHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromXml;
end;

{ TReceiveFileCancelReadHandle }

procedure TReceiveFileCancelReadHandle.AddToInfo;
var
  FileReceiveCancelAddInfo : TFileReceiveCancelAddInfo;
begin
  FileReceiveCancelAddInfo := TFileReceiveCancelAddInfo.Create( SourceFilePath, SourcePcID );
  FileReceiveCancelAddInfo.Update;
  FileReceiveCancelAddInfo.Free;
end;


procedure TReceiveFileCancelReadHandle.Update;
begin
  AddToInfo;
end;

{ TSendFileCancelReadHandle }

procedure TSendFileCancelReadHandle.AddToInfo;
var
  FileSendCancelAddInfo : TFileSendCancelAddInfo;
begin
  FileSendCancelAddInfo := TFileSendCancelAddInfo.Create( RootPath, DestinationID );
  FileSendCancelAddInfo.Update;
  FileSendCancelAddInfo.Free;
end;

procedure TSendFileCancelReadHandle.Update;
begin
  AddToInfo;
end;

{ TSendFileCancelRemoveHandle }

procedure TSendFileCancelRemoveHandle.RemoveFromInfo;
var
  FileSendCancelRemoveInfo : TFileSendCancelRemoveInfo;
begin
  FileSendCancelRemoveInfo := TFileSendCancelRemoveInfo.Create( RootPath, DestinationID );
  FileSendCancelRemoveInfo.Update;
  FileSendCancelRemoveInfo.Free;
end;

procedure TSendFileCancelRemoveHandle.RemoveFromXml;
var
  FileSendCancelRemoveXml : TFileSendCancelRemoveXml;
begin
  FileSendCancelRemoveXml := TFileSendCancelRemoveXml.Create( RootPath, DestinationID );
  MyXmlChange.AddChange( FileSendCancelRemoveXml );
end;

procedure TSendFileCancelRemoveHandle.Update;
begin
  RemoveFromInfo;

  RemoveFromXml;
end;

{ TSendFileSetStatusHandle }

procedure TSendFileSetStatusHandle.SetSendFileStatus(_SendFileStatus: string);
begin
  SendFileStatus := _SendFileStatus;
end;

procedure TSendFileSetStatusHandle.SetToFace;
var
  VstMyFileSendStatusInfo : TVstMyFileSendStatusInfo;
begin
  VstMyFileSendStatusInfo := TVstMyFileSendStatusInfo.Create( RootPath, DestinationID );
  VstMyFileSendStatusInfo.SetStatus( SendFileStatus );
  MyFaceChange.AddChange( VstMyFileSendStatusInfo );
end;


procedure TSendFileSetStatusHandle.SetToInfo;
var
  FileSendRootStatusInfo : TFileSendRootStatusInfo;
begin
  FileSendRootStatusInfo := TFileSendRootStatusInfo.Create( RootPath, DestinationID );
  FileSendRootStatusInfo.SetSendPathStatus( SendFileStatus );
  FileSendRootStatusInfo.Update;
  FileSendRootStatusInfo.Free;
end;

procedure TSendFileSetStatusHandle.SetToXml;
var
  FileSendRootStatusXml : TFileSendRootStatusXml;
begin
  FileSendRootStatusXml := TFileSendRootStatusXml.Create( RootPath, DestinationID );
  FileSendRootStatusXml.SetSendPathStatus( SendFileStatus );
  MyXmlChange.AddChange( FileSendRootStatusXml );
end;

procedure TSendFileSetStatusHandle.Update;
begin
  SetToXml;

  SetToInfo;

  SetToFace;
end;

{ TSendFileEnableChildHandle }

procedure TSendFileEnableChildHandle.RemoveFromSendDisableInfo;
var
  FileSendDisableRemoveInfo : TFileSendDisableRemoveInfo;
begin
  FileSendDisableRemoveInfo := TFileSendDisableRemoveInfo.Create( RootPath, DestinationID );
  FileSendDisableRemoveInfo.SetFilePath( FilePath );
  FileSendDisableRemoveInfo.Update;
  FileSendDisableRemoveInfo.Free;
end;

procedure TSendFileEnableChildHandle.SetToFace;
var
  VstMyFileSendChildStatusInfo : TVstMyFileSendChildStatusInfo;
begin
  VstMyFileSendChildStatusInfo := TVstMyFileSendChildStatusInfo.Create( RootPath, DestinationID );
  VstMyFileSendChildStatusInfo.SetChildPath( FilePath );
  VstMyFileSendChildStatusInfo.SetSendStatus( SendPathStatus_Waiting );
  MyFaceChange.AddChange( VstMyFileSendChildStatusInfo );
end;


procedure TSendFileEnableChildHandle.AddToMyJobInfo;
var
  TransferFileSendJobAddHandle : TTransferFileSendJobAddHandle;
begin
    // ��ɾ�� ��·��
  if not MyFileSendInfoReadUtil.ReadIsEnable( RootPath, DestinationID ) then
    Exit;

  TransferFileSendJobAddHandle := TTransferFileSendJobAddHandle.Create( FilePath, DestinationID );
  TransferFileSendJobAddHandle.SetFileInfo( FileSize, Position, FileTime );
  TransferFileSendJobAddHandle.Update;
  TransferFileSendJobAddHandle.Free;
end;

procedure TSendFileEnableChildHandle.Update;
begin
  FileSize := MyFileInfo.getFileSize( FilePath );
  FileTime := MyFileInfo.getFileLastWriteTime( FilePath );
  Position := 0;

  SetToFace;

  AddToMyJobInfo;

  RemoveFromSendDisableInfo;
end;

{ TSendFileChangeWriteHandle }

procedure TSendFileChangeChildHandle.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;


{ TSendFileEnProEditionHandle }

procedure TSendFileEnterProEditionHandle.EnableBigSendFile(RootPath, DesPcID,
  FilePath: string);
var
  SendFileEnableChildHandle : TSendFileEnableChildHandle;
begin
  SendFileEnableChildHandle := TSendFileEnableChildHandle.Create( RootPath, DesPcID );
  SendFileEnableChildHandle.SetFilePath( FilePath );
  SendFileEnableChildHandle.Update;
  SendFileEnableChildHandle.Free;
end;

procedure TSendFileEnterProEditionHandle.Update;
var
  FileSendDisableList : TFileSendDisableList;
  i : Integer;
  FileSendDisableInfo : TFileSendDisableInfo;
begin
    // ������Ѱ�
  if RegisterInfo.getIsFreeEdition then
    Exit;

  FileSendDisableList := MyFileSendInfoReadUtil.ReadDisableList;

    // ����
  for i := 0 to FileSendDisableList.Count - 1 do
  begin
    FileSendDisableInfo := FileSendDisableList[i];

    EnableBigSendFile( FileSendDisableInfo.FullPath, FileSendDisableInfo.DesPcID, FileSendDisableInfo.FilePath );
  end;

  FileSendDisableList.Free;
end;

{ TSendFileSetChildStatusHandle }

procedure TSendFileSetChildStatusHandle.SetSendFileStatus(
  _SendFileStatus: string);
begin
  SendFileStatus := _SendFileStatus;
end;

procedure TSendFileSetChildStatusHandle.SetToFace;
var
  VstMyFileSendChildStatusInfo : TVstMyFileSendChildStatusInfo;
begin
  VstMyFileSendChildStatusInfo := TVstMyFileSendChildStatusInfo.Create( RootPath, DestinationID );
  VstMyFileSendChildStatusInfo.SetChildPath( FilePath );
  VstMyFileSendChildStatusInfo.SetSendStatus( SendFileStatus );
  MyFaceChange.AddChange( VstMyFileSendChildStatusInfo );
end;

procedure TSendFileSetChildStatusHandle.Update;
begin
  SetToFace;
end;

{ TSendFilePcOfflineHandle }

constructor TSendFilePcOfflineHandle.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TSendFilePcOfflineHandle.SetToRootFace;
var
  VstMyFilePcOnlineInfo : TVstMyFilePcOnlineInfo;
begin
  VstMyFilePcOnlineInfo := TVstMyFilePcOnlineInfo.Create( PcID );
  VstMyFilePcOnlineInfo.SetIsOnline( False );
  MyFaceChange.AddChange( VstMyFilePcOnlineInfo );
end;


procedure TSendFilePcOfflineHandle.Update;
begin
  SetToRootFace;
end;

{ TSendFileAddCompletedSpaceHandle }

procedure TSendFileAddCompletedSpaceHandle.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TSendFileAddCompletedSpaceHandle.SetToFace;
var
  VstMyFileSendAddCompletedSize : TVstMyFileSendAddCompletedSize;
begin
  VstMyFileSendAddCompletedSize := TVstMyFileSendAddCompletedSize.Create( RootPath, DestinationID );
  VstMyFileSendAddCompletedSize.SetAddSize( CompletedSize );
  MyFaceChange.AddChange( VstMyFileSendAddCompletedSize );
end;

procedure TSendFileAddCompletedSpaceHandle.SetToInfo;
var
  FileSendAddCompletedSizeInfo : TFileSendAddCompletedSizeInfo;
begin
  FileSendAddCompletedSizeInfo := TFileSendAddCompletedSizeInfo.Create( RootPath, DestinationID );
  FileSendAddCompletedSizeInfo.SetAddSize( CompletedSize );
  FileSendAddCompletedSizeInfo.Update;
  FileSendAddCompletedSizeInfo.Free;
end;

procedure TSendFileAddCompletedSpaceHandle.SetToRemote;
var
  ClientSendFileAddCompletedSpaceMsg : TClientSendFileAddCompletedSpaceMsg;
begin
  ClientSendFileAddCompletedSpaceMsg := TClientSendFileAddCompletedSpaceMsg.Create;
  ClientSendFileAddCompletedSpaceMsg.SetPcID( PcInfo.PcID );
  ClientSendFileAddCompletedSpaceMsg.SetSourceFilePath( RootPath );
  ClientSendFileAddCompletedSpaceMsg.SetCompletedSize( CompletedSize );
  MyClient.SendMsgToPc( DestinationID, ClientSendFileAddCompletedSpaceMsg );
end;

procedure TSendFileAddCompletedSpaceHandle.SetToXml;
var
  FileSendAddCompletedSpaceXml : TFileSendAddCompletedSpaceXml;
begin
  FileSendAddCompletedSpaceXml := TFileSendAddCompletedSpaceXml.Create( RootPath, DestinationID );
  FileSendAddCompletedSpaceXml.SetCompletedSize( CompletedSize );
  MyXmlChange.AddChange( FileSendAddCompletedSpaceXml );
end;

procedure TSendFileAddCompletedSpaceHandle.Update;
begin
  SetToXml;

  SetToFace;

  SetToInfo;

  SetToRemote;
end;

{ TReceiveFileAddCompletedSpaceHandle }

procedure TReceiveFileAddCompletedSpaceHandle.SetCompletedSpace(
  _CompletedSpace: Int64);
begin
  CompletedSpace := _CompletedSpace;
end;

procedure TReceiveFileAddCompletedSpaceHandle.SetToFace;
var
  LvFileREceiveAddCompletedSpace : TLvFileReceiveAddCompletedSpace;
begin
  LvFileREceiveAddCompletedSpace := TLvFileReceiveAddCompletedSpace.Create( SourceFilePath, SourcePcID );
  LvFileREceiveAddCompletedSpace.SetCompletedSpace( CompletedSpace );
  MyFaceChange.AddChange( LvFileREceiveAddCompletedSpace );
end;

procedure TReceiveFileAddCompletedSpaceHandle.SetToXml;
var
  FileReceiveAddCompletedSpaceXml : TFileReceiveAddCompletedSpaceXml;
begin
  FileReceiveAddCompletedSpaceXml := TFileReceiveAddCompletedSpaceXml.Create( SourceFilePath, SourcePcID );
  FileReceiveAddCompletedSpaceXml.SetCompletedSpace( CompletedSpace );
  MyXmlChange.AddChange( FileReceiveAddCompletedSpaceXml );
end;

procedure TReceiveFileAddCompletedSpaceHandle.Update;
begin
  SetToFace;

  SetToXml;
end;

{ TSendFileChildAddCompletedSpaceHandle }

procedure TSendFileChildAddCompletedSpaceHandle.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TSendFileChildAddCompletedSpaceHandle.SetToFace;
var
  VstMyFileSendChildAddCompletedInfo : TVstMyFileSendChildAddCompletedInfo;
begin
  VstMyFileSendChildAddCompletedInfo := TVstMyFileSendChildAddCompletedInfo.Create( RootPath, DestinationID );
  VstMyFileSendChildAddCompletedInfo.SetChildPath( FilePath );
  VstMyFileSendChildAddCompletedInfo.SetCompletedSize( CompletedSize );
  MyFaceChange.AddChange( VstMyFileSendChildAddCompletedInfo );
end;

procedure TSendFileChildAddCompletedSpaceHandle.Update;
begin
  SetToFace;
end;

{ TSendFileAddScaningHandle }

procedure TSendFileAddScaningHandle.AddToScanFace;
var
  i, j : Integer;
  RootPath, DesPcID, DesPcName, SendPathType : string;
  VstMyFileSendAddInfo : TVstMyFileSendAddInfo;
begin
  for i := 0 to FileList.Count - 1 do
  begin
    RootPath := FileList[i];
    if FileExists( RootPath ) then
      SendPathType := SendPathType_File
    else
      SendPathType := SendPathType_Folder;
    for j := 0 to DesPcList.Count - 1 do
    begin
      DesPcID := DesPcList[j];
      DesPcName := MyNetPcInfoReadUtil.ReadName( DesPcID );

        // ��� Scanning ����
      VstMyFileSendAddInfo := TVstMyFileSendAddInfo.Create( RootPath, DesPcID );
      VstMyFileSendAddInfo.SetPcName( DesPcName );
      VstMyFileSendAddInfo.SetFileSpaceInfo( 0, 0 );
      VstMyFileSendAddInfo.SetStatus( SendPathStatus_Scanning );
      VstMyFileSendAddInfo.SetPcIsOnline( True );
      VstMyFileSendAddInfo.SetSendPathType( SendPathType );
      MyFaceChange.AddChange( VstMyFileSendAddInfo );

        // ��¼ ��·������ɨ��
      AddToScanningInfo( RootPath, DesPcID );
    end;
  end;
end;

procedure TSendFileAddScaningHandle.AddToScanningInfo( ScanningPath, DesPcID : string );
var
  FileSendScanAddInfo : TFileSendScanAddInfo;
begin
  FileSendScanAddInfo := TFileSendScanAddInfo.Create( ScanningPath, DesPcID );
  FileSendScanAddInfo.Update;
  FileSendScanAddInfo.Free;
end;

constructor TSendFileAddScaningHandle.Create(_FileList,
  _DesPcList: TStringList);
begin
  FileList := _FileList;
  DesPcList := _DesPcList;
end;

procedure TSendFileAddScaningHandle.AddToFolderScan;
var
  TransferScanInfo : TTransferScanInfo;
begin
  TransferScanInfo := TTransferScanInfo.Create( ScanType_Size );
  TransferScanInfo.SetList( FileList, DesPcList );
  MyTransferJobScanInfo.AddScanInfo( TransferScanInfo );
end;


procedure TSendFileAddScaningHandle.Update;
begin
    // Scanning ����
  AddToScanFace;

    // Scan Thread
  AddToFolderScan;
end;

{ ReceiveFileControlUti }

class function ReceiveFileControlUtil.ExistPath(ReceivePath: string): Boolean;
begin
    // ���� �� ����·�� �Ƿ����
  Result := FileExists( ReceivePath ) or DirectoryExists( ReceivePath ) or
            MyFileReceiveInfoReadUtil.ReadReceivePathIsExist( ReceivePath );
end;

class function ReceiveFileControlUtil.getReceivePath(
  SendRootPath: string): string;
var
  ReceivePath, OrgReceivePath, SaveName : string;
  NameNumber : Integer;
begin
    // �ļ���
  SaveName := MyFileInfo.getFileName( SendRootPath );
  SaveName := MyFilePath.getDownloadPath( SaveName );

    // ����·��
  ReceivePath := FileReceiveSettingInfo.ReceivePath;
  ReceivePath := MyFilePath.getPath( ReceivePath ) + SaveName;
  OrgReceivePath := ReceivePath;

    // ������ͬ���·��
  NameNumber := 1;
  while ExistPath( ReceivePath ) do
  begin
    ReceivePath := MyRename.getFileName( OrgReceivePath, NameNumber );
    Inc( NameNumber );
  end;

    // ����
  Result := ReceivePath;
end;

{ TAddReceiveFileAutoHandle }

procedure TAddReceiveFileAutoHandle.FindReceicePath;
begin
    // ������ظ����ͣ����ȡ��һ�ν��յ�·��
  ReceivePath := MyFileReceiveInfoReadUtil.ReadReceivePath( SourceFilePath, SourcePcID );

    // �ظ�����
  if ReceivePath <> '' then
    Exit;

    // ��ȡ ����·��
  ReceivePath := ReceiveFileControlUtil.getReceivePath( SourceFilePath );
end;

{ TAddReceiveFileManualHandle }

procedure TAddReceiveFileManualHandle.SetReceivePath(_ReceivePath: string);
begin
  ReceivePath := _ReceivePath;
end;

{ TSendFileCheckCompletedHandle }

procedure TSendFileCheckCompletedHandle.SendCompletedToRemote;
var
  SendFileCompletedHandle : TSendFileCompletedHandle;
begin
  SendFileCompletedHandle := TSendFileCompletedHandle.Create( RootPath, DestinationID );
  SendFileCompletedHandle.Update;
  SendFileCompletedHandle.Free;
end;

procedure TSendFileCheckCompletedHandle.Update;
begin
  if MyFileSendInfoReadUtil.ReadIsCompleted( RootPath, DestinationID ) then
    SendCompletedToRemote;
end;

end.
