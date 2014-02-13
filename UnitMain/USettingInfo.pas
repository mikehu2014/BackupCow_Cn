unit USettingInfo;

interface

uses UMyUtil, Math, Generics.Collections, SysUtils;

type

    // Pc ��Ϣ
  TPcSettingInfo = class
  public
    PcID, PcName : string;
    LanIp, LanPort : string;
  end;

    // ���� ״̬
  TTransferSettingInfo = class
  public
    UpThreadCount : Integer;
    UploadSpeed : Integer;
  public
    DownThreadCount : Integer;
    DownloadSpeed : Integer;
  end;

    // ���� ��ȫ
  TTransferSafeSettingInfo = class
  public
    IsMD5Check : Boolean;
    IsRemoveForbid : Boolean;
  end;


    // �����ļ� ��ȫ��Ϣ
  TBackupFileSafeSettingInfo = class
  public
    CopyCount : Integer;
  end;

    // ͬ��ʱ��
  TSyncTimeSettingInfo = class
  public
    IsAutoSync : Boolean;
    TimeType : Integer;
    SyncTime : Integer;
  public
    function getSyncMins : Integer;
  end;

    // ��������
  TBackupFileEncryptSettingInfo = class
  public
    IsEncrypt : Boolean;
    Password : string;
    PasswordHint : string;
  end;

    // ��������
  TShareSettingInfo = class
  public
    IsShare : Boolean;
    SharePath : string;
  public
    MaxSpaceType, MaxSpaceValue : Integer;
    MinSpaceType, MinSpaceValue : Integer;
  public
    function getHardDiskAvailableSpace : Int64;
    function getAvailableSpace( UsedSpace: Int64 ) : Int64;
    function getTotalSpace( UsedSpace: Int64 ): Int64;
  end;

    // �ư�ȫ ����
  TCloudSafeSettingInfo = class
  public
    IsCloudSafe : Boolean;
    CloudIDNum : string;
  public
    function getCloudIDNumMD5 : string;
  end;

    // ���ļ���ȫ ����
  TCloudFileSafeSettingInfo = class
  public
    CloudSafeType : Integer;
    CloudSafeValue : Integer;
  end;

    // �ļ��ɼ��� ����
  TFileVisibleSettingInfo = class
  public
    IsFileInvisible : Boolean;
    RestorePassword : string;
  end;

    // Ӧ�ó��� ����
  TApplicationSettingInfo = class
  public
    IsRunAppStartUp : Boolean;
    IsShowDialogBeforeExist : Boolean;
  end;

    // �ļ����� ����
  TFileReceiveSettingInfo = class
  public
    IsAutoReceive : Boolean;
    IsManualReceive : Boolean;
    IsNerverReceive : Boolean;
  public
    ReceivePath : string;
  public
    IsRevFileShowHint : Boolean;
  end;

    // �ļ��������� ����
  TFileSearchDownSettingInfo = class
  public
    IsSelectDownloadPath : Boolean;
    DownloadPath : string;
  end;

    // Standard Account ��Ϣ
  TRemoteAccountInfo = class
  public
    AccountName : string;
    Password : string;
    IsSelected : Boolean;
  public
    constructor Create( _AccountName, _Password : string );
  end;
  TRemoteAccountList = TObjectList< TRemoteAccountInfo >;

      // Standard Setting Info
  TStandardNetworkSettingInfo = class
  public
    RemoteAccountList : TRemoteAccountList;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function getAccount( AccountName : string ): TRemoteAccountInfo;
    procedure SetSelected( AccountName : string );
    function getSelected : TRemoteAccountInfo;
  end;

    // Advance Internet Pc ��Ϣ
  TRemoteInternetInfo = class
  public
    Domain : string;
    Port : string;
    IsSelected : Boolean;
  public
    constructor Create( _Domain, _Port : string );
  end;
  TRemoteInternetList = TObjectList< TRemoteInternetInfo >;

    // Advance Network SettingInfo
  TAdvanceNetworkSettingInfo = class
  public
    RemoteInternetList : TRemoteInternetList;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function getInternet( Domain, Port : string ): TRemoteInternetInfo;
    procedure SetSelected( Domain, Port: string );
    function getSelected : TRemoteInternetInfo;
  end;

  RemoteNetworkSettingUtil = class
  public
    class procedure SetLanSelected;
    class procedure SetStandardSelected( AccountName : string );
    class procedure SetAdvanceSelected( Domain, Port : string );
  end;

const
  TransferSpeed_Fast = 2;
  TransferSpeed_Normal = 1;
  TransferSpeed_Slow = 0;

var
  PcSettingInfo : TPcSettingInfo;

  TransferSettingInfo : TTransferSettingInfo;
  TransferSafeSettingInfo : TTransferSafeSettingInfo;

  BackupFileSafeSettingInfo : TBackupFileSafeSettingInfo;
  SyncTimeSettingInfo : TSyncTimeSettingInfo;
  BackupFileEncryptSettingInfo : TBackupFileEncryptSettingInfo;

  ShareSettingInfo : TShareSettingInfo;
  CloudSafeSettingInfo : TCloudSafeSettingInfo;
  CloudFileSafeSettingInfo : TCloudFileSafeSettingInfo;

  FileVisibleSettingInfo : TFileVisibleSettingInfo;

  ApplicationSettingInfo : TApplicationSettingInfo;

  FileReceiveSettingInfo : TFileReceiveSettingInfo;

  FileSearchDownSettingInfo : TFileSearchDownSettingInfo;

  StandardNetworkSettingInfo : TStandardNetworkSettingInfo;
  AdvanceNetworkSettingInfo : TAdvanceNetworkSettingInfo;

implementation

{ TShareSettingInfo }

function TShareSettingInfo.getAvailableSpace( UsedSpace: Int64 ): Int64;
var
  HardLeaveSpace, PresetMaxSpace : Int64;
  TempMax, TempMin : Int64;
begin
  if not IsShare then
  begin
    Result := -1;
    Exit;
  end;

  TempMax := MySize.getSizeValue( MaxSpaceType, MaxSpaceValue );
  TempMin := MySize.getSizeValue( MinSpaceType, MinSpaceValue );

    // ����ʣ�¿ռ�
  HardLeaveSpace := MyHardDisk.getHardDiskFreeSize( SharePath ) - TempMin;

    // �������ռ�
  PresetMaxSpace := TempMax - UsedSpace;

    // ���ÿռ�
  Result := Min( HardLeaveSpace, PresetMaxSpace );
  Result := Max( Result, 0 );
end;

function TShareSettingInfo.getHardDiskAvailableSpace: Int64;
var
  TempMin, HardLeaveSpace : Int64;
begin
  if not IsShare then
  begin
    Result := -1;
    Exit;
  end;

    // ����ʣ�¿ռ�
  TempMin := MySize.getSizeValue( MinSpaceType, MinSpaceValue );

  HardLeaveSpace := MyHardDisk.getHardDiskFreeSize( SharePath );
  Result := Max( HardLeaveSpace - TempMin, 0 );
end;

function TShareSettingInfo.getTotalSpace(UsedSpace: Int64): Int64;
var
  AvailableSpace : Int64;
begin
    // ���ÿռ�
  AvailableSpace := getAvailableSpace( UsedSpace );

    // �ܿռ�
  Result := AvailableSpace + UsedSpace;
end;

{ TCloudSafeSettingInfo }

function TCloudSafeSettingInfo.getCloudIDNumMD5: string;
begin
  if IsCloudSafe then
    Result := MyEncrypt.EncodeMD5String( CloudIDNum )
  else
    Result := '';
end;

{ TRemoveAccountInfo }

constructor TRemoteAccountInfo.Create(_AccountName, _Password: string);
begin
  AccountName := _AccountName;
  Password := _Password;
  IsSelected := False;
end;

{ TRemoveInternetInfo }

constructor TRemoteInternetInfo.Create(_Domain, _Port: string);
begin
  Domain := _Domain;
  Port := _Port;
  IsSelected := False;
end;

{ TStandardNetworkSettingInfo }

constructor TStandardNetworkSettingInfo.Create;
begin
  RemoteAccountList := TRemoteAccountList.Create;
end;

destructor TStandardNetworkSettingInfo.Destroy;
begin
  RemoteAccountList.Free;
  inherited;
end;

function TStandardNetworkSettingInfo.getAccount(
  AccountName: string): TRemoteAccountInfo;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to RemoteAccountList.Count - 1 do
    if RemoteAccountList[i].AccountName = AccountName then
    begin
      Result := RemoteAccountList[i];
      Break;
    end;
end;

function TStandardNetworkSettingInfo.getSelected: TRemoteAccountInfo;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to RemoteAccountList.Count - 1 do
    if RemoteAccountList[i].IsSelected then
    begin
      Result := RemoteAccountList[i];
      Break;
    end;
end;

procedure TStandardNetworkSettingInfo.SetSelected(AccountName: string);
var
  i : Integer;
begin
  for i := 0 to RemoteAccountList.Count - 1 do
    if RemoteAccountList[i].AccountName = AccountName then
      RemoteAccountList[i].IsSelected := True
    else
      RemoteAccountList[i].IsSelected := False;
end;


{ TAdvanceNetworkSettingInfo }

constructor TAdvanceNetworkSettingInfo.Create;
begin
  RemoteInternetList := TRemoteInternetList.Create;
end;

destructor TAdvanceNetworkSettingInfo.Destroy;
begin
  RemoteInternetList.Free;
  inherited;
end;

function TAdvanceNetworkSettingInfo.getInternet(Domain,
  Port: string): TRemoteInternetInfo;
var
  i : Integer;
begin
  Result := nil;

  for i := 0 to RemoteInternetList.Count - 1 do
    if ( RemoteInternetList[i].Domain = Domain ) and
       ( RemoteInternetList[i].Port = Port )
    then
    begin
      Result := RemoteInternetList[i];
      Break;
    end;
end;

function TAdvanceNetworkSettingInfo.getSelected: TRemoteInternetInfo;
var
  i : Integer;
begin
  Result := nil;

  for i := 0 to RemoteInternetList.Count - 1 do
    if RemoteInternetList[i].IsSelected then
    begin
      Result := RemoteInternetList[i];
      Break;
    end;
end;
procedure TAdvanceNetworkSettingInfo.SetSelected(Domain, Port: string);
var
  i : Integer;
begin
  for i := 0 to RemoteInternetList.Count - 1 do
    if ( RemoteInternetList[i].Domain = Domain ) and
       ( RemoteInternetList[i].Port = Port )
    then
      RemoteInternetList[i].IsSelected := True
    else
      RemoteInternetList[i].IsSelected := False;
end;

{ RemoteNetworkSettingUtil }

class procedure RemoteNetworkSettingUtil.SetAdvanceSelected(Domain,
  Port: string);
begin
  StandardNetworkSettingInfo.SetSelected( '' );
  AdvanceNetworkSettingInfo.SetSelected( Domain, Port );
end;

class procedure RemoteNetworkSettingUtil.SetLanSelected;
begin
  StandardNetworkSettingInfo.SetSelected( '' );
  AdvanceNetworkSettingInfo.SetSelected( '', '' );
end;

class procedure RemoteNetworkSettingUtil.SetStandardSelected(
  AccountName: string);
begin
  StandardNetworkSettingInfo.SetSelected( AccountName );
  AdvanceNetworkSettingInfo.SetSelected( '', '' );
end;

{ TSyncTimeSettingInfo }

function TSyncTimeSettingInfo.getSyncMins: Integer;
begin
  Result := TimeTypeUtil.getMins( TimeType, SyncTime );
end;

end.

