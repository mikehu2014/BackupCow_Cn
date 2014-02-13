unit UMyBackupApiInfo;

interface

uses SysUtils, UFileBaseInfo, classes;

type


{$Region ' 目标路径 增删 ' }

    // 父类
  TDesItemWriteHandle = class
  public
    DesItemID : string;
  public
    constructor Create( _DesPath : string );
  end;

    // 读取 本地 Des
  TDesItemReadLocalHandle = class( TDesItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 本地 Des
  TDesItemAddLocalHandle = class( TDesItemReadLocalHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 读取 网络 Des
  TDesItemReadNetworkHandle = class( TDesItemWriteHandle )
  public
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加 网络 Des
  TDesItemAddNetworkHandle = class( TDesItemReadNetworkHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TDesItemRemoveHandle = class( TDesItemWriteHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
    procedure RemoveFromEvent;
  end;

{$EndRegion}

{$Region ' 目标路径 状态 ' }

      // 修改 是否存在路径
  TDesItemSetIsExistHandle = class( TDesItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否可写
  TDesItemSetIsWriteHandle = class( TDesItemWriteHandle )
  public
    IsWrite : boolean;
  public
    procedure SetIsWrite( _IsWrite : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 是否缺少空间
  TDesItemSetIsLackSpaceHandle = class( TDesItemWriteHandle )
  public
    IsLackSpace : boolean;
  public
    procedure SetIsLackSpace( _IsLackSpace : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}


{$Region ' 源路径 增删 ' }

    // 添加
  TBackupItemWriteHandle = class( TDesItemWriteHandle )
  public
    BackupPath : string;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 读取
  TBackupItemReadHandle = class( TBackupItemWriteHandle )
  public  // 路径信息
    IsFile : Boolean;
  public  // 可选状态
    IsDisable, IsBackupNow : Boolean;
  public  // 自动同步
    IsAutoSync : Boolean; // 是否自动同步
    SyncTimeType, SyncTimeValue : Integer; // 同步间隔
    LastSyncTime : TDateTime;  // 上一次同步时间
  public  // 加密设置
    IsEncrypt : boolean;
    Password, PasswordHint : string;
  public  // 删除保留信息
    IsKeepDeleted : Boolean;
    KeepEditionCount : Integer;
  public  // 空间信息
    FileCount : Integer;
    ItemSize, CompletedSize : Int64; // 空间信息
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
    procedure SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
    procedure SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
    procedure SetEncryptInfo( _IsEncrypt : boolean; _Password, _PasswordHint : string );
    procedure SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
    procedure SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
    procedure Update;virtual;
  private
    procedure AddToInfo;
    procedure AddToFace;
  end;

    // 添加
  TBackupItemAddHandle = class( TBackupItemReadHandle )
  public
    procedure Update;override;
  private
    procedure AddToXml;
  end;

    // 删除
  TBackupItemRemoveHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  private
    procedure RemoveFromInfo;
    procedure RemoveFromFace;
    procedure RemoveFromXml;
    procedure RemoveFromEvent;
  end;

{$EndRegion}

{$Region ' 源路径 状态 ' }

    // 是否 禁止备份
  TBackupItemSetIsDisableHandle = class( TBackupItemWriteHandle )
  public
    IsDisable : Boolean;
  public
    procedure SetIsDisable( _IsDisable : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToFace;
    procedure SetToXml;
  end;

    // 是否 Backup Now 备份
  TBackupItemSetIsBackupNowHandle = class( TBackupItemWriteHandle )
  public
    IsBackupNow : Boolean;
  public
    procedure SetIsBackupNow( _IsBackupNow : Boolean );
    procedure Update;
  private
    procedure SetToInfo;
    procedure SetToXml;
  end;

    // 修改 是否存在
  TBackupItemSetIsExistHandle = class( TBackupItemWriteHandle )
  public
    IsExist : boolean;
  public
    procedure SetIsExist( _IsExist : boolean );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改 状态
  TBackupItemSetBackupItemStatusHandle = class( TBackupItemWriteHandle )
  public
    BackupItemStatus : string;
  public
    procedure SetBackupItemStatus( _BackupItemStatus : string );
    procedure Update;
  private
     procedure SetToFace;
  end;

    // 修改
  TBackupItemSetSpeedHandle = class( TBackupItemWriteHandle )
  public
    Speed : int64;
  public
    procedure SetSpeed( _Speed : int64 );
    procedure Update;
  private
     procedure SetToFace;
  end;

{$EndRegion}

{$Region ' 源路径 空间信息 ' }

    // 修改 统计空间信息
  TBackupItemSetSpaceInfoHandle = class( TBackupItemWriteHandle )
  public
    FileCount : integer;
    ItemSize, CompletedSize : int64;
  public
    procedure SetSpaceInfo( _FileCount : integer; _ItemSize, _CompletedSize : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

    // 修改
  TBackupItemAddCompletedSpaceHandle = class( TBackupItemWriteHandle )
  public
    AddCompletedSpace : int64;
  public
    procedure SetAddCompletedSpace( _AddCompletedSpace : int64 );
    procedure Update;
  private
     procedure SetToInfo;
     procedure SetToFace;
     procedure SetToXml;
  end;

{$EndRegion}

{$Region ' 源路径 同步信息 ' }

    // 修改
  TBackupItemSetLastSyncTimeHandle = class( TBackupItemWriteHandle )
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

{$EndRegion}

{$Region ' 源路径 其他操作 ' }

    // 用户选定备份
  TBackupSelectedItemHandle = class( TBackupItemWriteHandle )
  public
    procedure Update;
  end;

    // 刷新恢复路径列表
  TBackupRefreshRestoreHandle = class
  public
    procedure Update;
  private
    procedure ReadDesList;
    procedure ReadBackupList;
  end;

{$EndRegion}


    // 目标路径 用户接口
  DesItemUserApi = class
  public
    class procedure AddLocalItem( DesItemID : string );
    class procedure RemoveItem( DesItemID : string );
  end;

    // 目标路径 程序接口
  DesItemAppApi = class
  public
    class procedure AddNetworkItem( DesItemID : string );
  public
    class procedure SetIsExist( DesItemID : string; IsExist : Boolean );
    class procedure SetIsWrite( DesItemID : string; IsWrite : Boolean );
    class procedure SetIsLackSpace( DesItemID : string; IsLackSpace : Boolean );
  end;

    // 备份路径 用户接口
  BackupItemUserApi = class
  public              // 备份路径
    class procedure AddItem( DesItemID, BackupPath : string );overload;
    class procedure AddItem( DesItemID, BackupPath : string; BackupConfigInfo : TBackupConfigInfo );overload;
    class procedure RemoveItem( DesItemID, BackupPath : string );
    class procedure BackupSelectItem( DesItemID, BackupPath : string );
  end;

    // 备份路径 程序接口
  BackupItemAppApi = class
  public              // 备份路径
    class procedure SetIsExist( DesItemID, BackupPath : string; IsExist : Boolean );
    class procedure SetSpaceInfo( DesItemID, BackupPath : string; FileCount : Integer;
                                        FileSpace, CompletedSpce : Int64 );
    class procedure RefreshLocalRestoreItem;
  public              // 备份路径 备份过程
    class procedure SetWaitingBackup( DesItemID, BackupPath : string );
    class procedure SetScaningCount( DesItemID, BackupPath : string; FileCount : Integer );
    class procedure SetStartBackup( DesItemID, BackupPath : string );
    class procedure SetSpeed( DesItemID, BackupPath : string; Speed : Int64 );
    class procedure AddBackupCompletedSpace( DesItemID, BackupPath : string; CompletedSpace : Int64 );
    class procedure SetBackupCompleted( DesItemID, BackupPath : string );
  end;


implementation

uses UMyBackupDataInfo, UMyBackupFaceInfo, UMyBackupXmlInfo, UMyNetPcInfo, UMyUtil, UBackupThread,
     UMyBackupEventInfo, UMyRestoreApiInfo;

{ LocalBackupUserApi }

class procedure BackupItemUserApi.AddItem(DesItemID, BackupPath: string);
var
  IsFile : Boolean;
  BackupItemAddHandle : TBackupItemAddHandle;
begin
  IsFile := FileExists( BackupPath );

  BackupItemAddHandle := TBackupItemAddHandle.Create( DesItemID );
  BackupItemAddHandle.SetBackupPath( BackupPath );
  BackupItemAddHandle.SetIsFile( IsFile );
  BackupItemAddHandle.SetBackupStatus( False, True );
  BackupItemAddHandle.SetAutoSyncInfo( True, Now );
  BackupItemAddHandle.SetSyncTimeInfo( TimeType_Hourse, 1 );
  BackupItemAddHandle.SetSpaceInfo( 0, 0, 0 );
  BackupItemAddHandle.SetDeleteInfo( False, 3 );
  BackupItemAddHandle.SetEncryptInfo( False, '', '' );
  BackupItemAddHandle.Update;
  BackupItemAddHandle.Free;
end;


class procedure BackupItemUserApi.AddItem(DesItemID, BackupPath: string;
  BackupConfigInfo: TBackupConfigInfo);
var
  IsFile : Boolean;
  BackupItemAddHandle : TBackupItemAddHandle;
begin
  IsFile := FileExists( BackupPath );

  BackupItemAddHandle := TBackupItemAddHandle.Create( DesItemID );
  BackupItemAddHandle.SetBackupPath( BackupPath );
  BackupItemAddHandle.SetIsFile( IsFile );
  BackupItemAddHandle.SetBackupStatus( BackupConfigInfo.IsDisable, BackupConfigInfo.IsBackupupNow );
  BackupItemAddHandle.SetAutoSyncInfo( BackupConfigInfo.IsAuctoSync, Now );
  BackupItemAddHandle.SetSyncTimeInfo( BackupConfigInfo.SyncTimeType, BackupConfigInfo.SyncTimeValue );
  BackupItemAddHandle.SetSpaceInfo( 0, 0, 0 );
  BackupItemAddHandle.SetDeleteInfo( BackupConfigInfo.IsKeepDeleted, BackupConfigInfo.KeepEditionCount );
  BackupItemAddHandle.SetEncryptInfo( BackupConfigInfo.IsEncrypt, BackupConfigInfo.Password, BackupConfigInfo.PasswordHint );
  BackupItemAddHandle.Update;
  BackupItemAddHandle.Free;
end;


class procedure BackupItemUserApi.BackupSelectItem(DesItemID,
  BackupPath: string);
var
  BackupSelectedItemHandle : TBackupSelectedItemHandle;
begin
  BackupSelectedItemHandle := TBackupSelectedItemHandle.Create( DesItemID );
  BackupSelectedItemHandle.SetBackupPath( BackupPath );
  BackupSelectedItemHandle.Update;
  BackupSelectedItemHandle.Free;
end;

class procedure BackupItemUserApi.RemoveItem(DesItemID,
  BackupPath: string);
var
  BackupItemRemoveHandle : TBackupItemRemoveHandle;
begin
  BackupItemRemoveHandle := TBackupItemRemoveHandle.Create( DesItemID );
  BackupItemRemoveHandle.SetBackupPath( BackupPath );
  BackupItemRemoveHandle.Update;
  BackupItemRemoveHandle.Free;
end;

{ TLocalBackupDesItemWriteHandle }

constructor TDesItemWriteHandle.Create(_DesPath: string);
begin
  DesItemID := _DesPath;
end;


{ TlocalBackupDeItemRemoveHandle }

procedure TDesItemRemoveHandle.RemoveFromEvent;
begin
  LocalBackupEvent.RemoveDesPath( DesItemID );
end;

procedure TDesItemRemoveHandle.RemoveFromFace;
var
  DesItemRemoveFace : TDesItemRemoveFace;
  FrmLocalDesRemove : TFrmLocalDesRemove;
begin
  DesItemRemoveFace := TDesItemRemoveFace.Create( DesItemID );
  DesItemRemoveFace.AddChange;

  FrmLocalDesRemove := TFrmLocalDesRemove.Create( DesItemID );
  FrmLocalDesRemove.AddChange;
end;

procedure TDesItemRemoveHandle.RemoveFromInfo;
var
  LocalDesItemRemoveInfo : TDesItemRemoveInfo;
begin
  LocalDesItemRemoveInfo := TDesItemRemoveInfo.Create( DesItemID );
  LocalDesItemRemoveInfo.Update;
  LocalDesItemRemoveInfo.Free;
end;

procedure TDesItemRemoveHandle.RemoveFromXml;
var
  LocalDesItemRemoveXml : TDesItemRemoveXml;
begin
  LocalDesItemRemoveXml := TDesItemRemoveXml.Create( DesItemID );
  LocalDesItemRemoveXml.AddChange;
end;

procedure TDesItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
  RemoveFromEvent;
end;

procedure TBackupItemWriteHandle.SetBackupPath( _BackupPath : string );
begin
  BackupPath := _BackupPath;
end;

procedure TBackupItemReadHandle.SetIsFile( _IsFile : Boolean );
begin
  IsFile := _IsFile;
end;

procedure TBackupItemReadHandle.SetBackupStatus( _IsDisable, _IsBackupNow : Boolean );
begin
  IsDisable := _IsDisable;
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemReadHandle.AddToFace;
var
  BackupItemAddFace : TBackupItemAddFace;
begin
  BackupItemAddFace := TBackupItemAddFace.Create( DesItemID );
  BackupItemAddFace.SetBackupPath( BackupPath );
  BackupItemAddFace.SetIsFile( IsFile );
  BackupItemAddFace.SetIsDisable( IsDisable );
  BackupItemAddFace.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  BackupItemAddFace.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  BackupItemAddFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  BackupItemAddFace.AddChange;
end;

procedure TBackupItemReadHandle.AddToInfo;
var
  LocalBackupItemAddInfo : TBackupItemAddInfo;
begin
  LocalBackupItemAddInfo := TBackupItemAddInfo.Create( DesItemID );
  LocalBackupItemAddInfo.SetBackupPath( BackupPath );
  LocalBackupItemAddInfo.SetIsFile( IsFile );
  LocalBackupItemAddInfo.SetBackupStatus( IsDisable, IsBackupNow );
  LocalBackupItemAddInfo.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupItemAddInfo.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddInfo.SetDeletedInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddInfo.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  LocalBackupItemAddInfo.Update;
  LocalBackupItemAddInfo.Free;
end;

procedure TBackupItemReadHandle.SetAutoSyncInfo( _IsAutoSync : Boolean; _LasSyncTime : TDateTime );
begin
  IsAutoSync := _IsAutoSync;
  LastSyncTime := _LasSyncTime;
end;

procedure TBackupItemReadHandle.SetSyncTimeInfo( _SyncTimeType, _SyncTimeValue : Integer );
begin
  SyncTimeType := _SyncTimeType;
  SyncTimeValue := _SyncTimeValue;
end;

procedure TBackupItemReadHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

procedure TBackupItemReadHandle.SetDeleteInfo( _IsKeepDeleted : Boolean; _KeepEditionCount : Integer );
begin
  IsKeepDeleted := _IsKeepDeleted;
  KeepEditionCount := _KeepEditionCount;
end;

procedure TBackupItemReadHandle.SetEncryptInfo(_IsEncrypt: boolean;
  _Password, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  Password := _Password;
  PasswordHint := _PasswordHint;
end;

procedure TBackupItemReadHandle.SetSpaceInfo( _FileCount : Integer; _ItemSize, _CompletedSize : Int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;



{ TLocalBackupItemAddHandle }

procedure TBackupItemAddHandle.AddToXml;
var
  LocalBackupItemAddXml : TBackupItemAddXml;
begin
  LocalBackupItemAddXml := TBackupItemAddXml.Create( DesItemID );
  LocalBackupItemAddXml.SetBackupPath( BackupPath );
  LocalBackupItemAddXml.SetIsFile( IsFile );
  LocalBackupItemAddXml.SetBackupStatus( IsDisable, IsBackupNow );
  LocalBackupItemAddXml.SetAutoSyncInfo( IsAutoSync, LastSyncTime );
  LocalBackupItemAddXml.SetSyncTimeInfo( SyncTimeType, SyncTimeValue );
  LocalBackupItemAddXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemAddXml.SetDeleteInfo( IsKeepDeleted, KeepEditionCount );
  LocalBackupItemAddXml.SetEncryptInfo( IsEncrypt, Password, PasswordHint );
  LocalBackupItemAddXml.AddChange;
end;

procedure TBackupItemAddHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TLocalBackupItemRemoveHandle }

procedure TBackupItemRemoveHandle.RemoveFromEvent;
begin
  LocalBackupEvent.RemoveBackupItem( DesItemID, BackupPath );
end;

procedure TBackupItemRemoveHandle.RemoveFromFace;
var
  BackupItemRemoveFace : TBackupItemRemoveFace;
begin
  BackupItemRemoveFace := TBackupItemRemoveFace.Create( DesItemID );
  BackupItemRemoveFace.SetBackupPath( BackupPath );
  BackupItemRemoveFace.AddChange;
end;

procedure TBackupItemRemoveHandle.RemoveFromInfo;
var
  LocalBackupItemRemoveInfo : TBackupItemRemoveInfo;
begin
  LocalBackupItemRemoveInfo := TBackupItemRemoveInfo.Create( DesItemID );
  LocalBackupItemRemoveInfo.SetBackupPath( BackupPath );
  LocalBackupItemRemoveInfo.Update;
  LocalBackupItemRemoveInfo.Free;
end;

procedure TBackupItemRemoveHandle.RemoveFromXml;
var
  LocalBackupItemRemoveXml : TBackupItemRemoveXml;
begin
  LocalBackupItemRemoveXml := TBackupItemRemoveXml.Create( DesItemID );
  LocalBackupItemRemoveXml.SetBackupPath( BackupPath );
  LocalBackupItemRemoveXml.AddChange;
end;

procedure TBackupItemRemoveHandle.Update;
begin
  RemoveFromInfo;
  RemoveFromFace;
  RemoveFromXml;
  RemoveFromEvent;
end;

{ TLocalBackupItemSetIsDisableHandle }

procedure TBackupItemSetIsDisableHandle.SetIsDisable(_IsDisable: Boolean);
begin
  IsDisable := _IsDisable;
end;

procedure TBackupItemSetIsDisableHandle.SetToFace;
var
  BackupItemSetIsDisableFace : TBackupItemSetIsDisableFace;
begin
  BackupItemSetIsDisableFace := TBackupItemSetIsDisableFace.Create( DesItemID );
  BackupItemSetIsDisableFace.SetBackupPath( BackupPath );
  BackupItemSetIsDisableFace.SetIsDisable( IsDisable );
  BackupItemSetIsDisableFace.AddChange;
end;

procedure TBackupItemSetIsDisableHandle.SetToInfo;
var
  LocalBackupItemSetIsDisableInfo : TBackupItemSetIsDisableInfo;
begin
  LocalBackupItemSetIsDisableInfo := TBackupItemSetIsDisableInfo.Create( DesItemID );
  LocalBackupItemSetIsDisableInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetIsDisableInfo.SetIsDisable( IsDisable );
  LocalBackupItemSetIsDisableInfo.Update;
  LocalBackupItemSetIsDisableInfo.Free;
end;

procedure TBackupItemSetIsDisableHandle.SetToXml;
var
  LocalBackupItemSetIsDisableXml : TBackupItemSetIsDisableXml;
begin
  LocalBackupItemSetIsDisableXml := TBackupItemSetIsDisableXml.Create( DesItemID );
  LocalBackupItemSetIsDisableXml.SetBackupPath( BackupPath );
  LocalBackupItemSetIsDisableXml.SetIsDisable( IsDisable );
  LocalBackupItemSetIsDisableXml.AddChange;
end;

procedure TBackupItemSetIsDisableHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetIsBackupNowHandle }

procedure TBackupItemSetIsBackupNowHandle.SetIsBackupNow(
  _IsBackupNow: Boolean);
begin
  IsBackupNow := _IsBackupNow;
end;

procedure TBackupItemSetIsBackupNowHandle.SetToInfo;
var
  LocalBackupItemSetIsBackupNowInfo : TBackupItemSetIsBackupNowInfo;
begin
  LocalBackupItemSetIsBackupNowInfo := TBackupItemSetIsBackupNowInfo.Create( DesItemID );
  LocalBackupItemSetIsBackupNowInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowInfo.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowInfo.Update;
  LocalBackupItemSetIsBackupNowInfo.Free;
end;

procedure TBackupItemSetIsBackupNowHandle.SetToXml;
var
  LocalBackupItemSetIsBackupNowXml : TBackupItemSetIsBackupNowXml;
begin
  LocalBackupItemSetIsBackupNowXml := TBackupItemSetIsBackupNowXml.Create( DesItemID );
  LocalBackupItemSetIsBackupNowXml.SetBackupPath( BackupPath );
  LocalBackupItemSetIsBackupNowXml.SetIsBackupNow( IsBackupNow );
  LocalBackupItemSetIsBackupNowXml.AddChange;
end;

procedure TBackupItemSetIsBackupNowHandle.Update;
begin
  SetToInfo;
  SetToXml;
end;

{ LocalBackupAppApi }

class procedure BackupItemAppApi.RefreshLocalRestoreItem;
var
  LocalBackupRefreshRestoreHandle : TBackupRefreshRestoreHandle;
begin
  LocalBackupRefreshRestoreHandle := TBackupRefreshRestoreHandle.Create;
  LocalBackupRefreshRestoreHandle.Update;
  LocalBackupRefreshRestoreHandle.Free;
end;

class procedure BackupItemAppApi.AddBackupCompletedSpace(DesItemID,
  BackupPath: string; CompletedSpace: Int64);
var
  BackupItemAddCompletedSpaceHandle : TBackupItemAddCompletedSpaceHandle;
begin
  BackupItemAddCompletedSpaceHandle := TBackupItemAddCompletedSpaceHandle.Create( DesItemID );
  BackupItemAddCompletedSpaceHandle.SetBackupPath( BackupPath );
  BackupItemAddCompletedSpaceHandle.SetAddCompletedSpace( CompletedSpace );
  BackupItemAddCompletedSpaceHandle.Update;
  BackupItemAddCompletedSpaceHandle.Free;
end;

class procedure BackupItemAppApi.SetBackupCompleted(DesItemID,
  BackupPath: string);
var
  LocalBackupItemSetBackupItemStatusHandle : TBackupItemSetBackupItemStatusHandle;
  LocalBackupItemSetLastSyncTimeHandle : TBackupItemSetLastSyncTimeHandle;
begin
    // 刷新 节点状态
  LocalBackupItemSetBackupItemStatusHandle := TBackupItemSetBackupItemStatusHandle.Create( DesItemID );
  LocalBackupItemSetBackupItemStatusHandle.SetBackupPath( BackupPath );
  LocalBackupItemSetBackupItemStatusHandle.SetBackupItemStatus( BackupNodeStatus_Empty );
  LocalBackupItemSetBackupItemStatusHandle.Update;
  LocalBackupItemSetBackupItemStatusHandle.Free;

    // 刷新 上次同步时间
  LocalBackupItemSetLastSyncTimeHandle := TBackupItemSetLastSyncTimeHandle.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeHandle.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeHandle.SetLastSyncTime( Now );
  LocalBackupItemSetLastSyncTimeHandle.Update;
  LocalBackupItemSetLastSyncTimeHandle.Free;
end;

class procedure BackupItemAppApi.SetIsExist(DesItemID,
  BackupPath: string; IsExist: Boolean);
var
  BackupItemSetIsExistHandle : TBackupItemSetIsExistHandle;
begin
  BackupItemSetIsExistHandle := TBackupItemSetIsExistHandle.Create( DesItemID );
  BackupItemSetIsExistHandle.SetBackupPath( BackupPath );
  BackupItemSetIsExistHandle.SetIsExist( IsExist );
  BackupItemSetIsExistHandle.Update;
  BackupItemSetIsExistHandle.Free;
end;

class procedure BackupItemAppApi.SetScaningCount(DesItemID,
  BackupPath: string; FileCount: Integer);
var
  StatusStr : string;
  BackupItemSetBackupItemStatusHandle : TBackupItemSetBackupItemStatusHandle;
begin
  StatusStr := Format( BackupNodeStatus_Analyizing, [inttostr(FileCount)] );

  BackupItemSetBackupItemStatusHandle := TBackupItemSetBackupItemStatusHandle.Create( DesItemID );
  BackupItemSetBackupItemStatusHandle.SetBackupPath( BackupPath );
  BackupItemSetBackupItemStatusHandle.SetBackupItemStatus( StatusStr );
  BackupItemSetBackupItemStatusHandle.Update;
  BackupItemSetBackupItemStatusHandle.Free;
end;

class procedure BackupItemAppApi.SetSpaceInfo(DesItemID,
  BackupPath: string; FileCount: Integer; FileSpace, CompletedSpce: Int64);
var
  BackupItemSetSpaceInfoHandle : TBackupItemSetSpaceInfoHandle;
begin
  BackupItemSetSpaceInfoHandle := TBackupItemSetSpaceInfoHandle.Create( DesItemID );
  BackupItemSetSpaceInfoHandle.SetBackupPath( BackupPath );
  BackupItemSetSpaceInfoHandle.SetSpaceInfo( FileCount, FileSpace, CompletedSpce );
  BackupItemSetSpaceInfoHandle.Update;
  BackupItemSetSpaceInfoHandle.Free;
end;

class procedure BackupItemAppApi.SetSpeed(DesItemID,
  BackupPath: string; Speed: Int64);
var
  BackupItemSetSpeedHandle : TBackupItemSetSpeedHandle;
begin
  BackupItemSetSpeedHandle := TBackupItemSetSpeedHandle.Create( DesItemID );
  BackupItemSetSpeedHandle.SetBackupPath( BackupPath );
  BackupItemSetSpeedHandle.SetSpeed( Speed );
  BackupItemSetSpeedHandle.Update;
  BackupItemSetSpeedHandle.Free;
end;



class procedure BackupItemAppApi.SetStartBackup(DesItemID,
  BackupPath: string);
var
  BackupItemSetBackupItemStatusHandle : TBackupItemSetBackupItemStatusHandle;
begin
  BackupItemSetBackupItemStatusHandle := TBackupItemSetBackupItemStatusHandle.Create( DesItemID );
  BackupItemSetBackupItemStatusHandle.SetBackupPath( BackupPath );
  BackupItemSetBackupItemStatusHandle.SetBackupItemStatus( BackupNodeStatus_Backuping );
  BackupItemSetBackupItemStatusHandle.Update;
  BackupItemSetBackupItemStatusHandle.Free;
end;

class procedure BackupItemAppApi.SetWaitingBackup(DesItemID,
  BackupPath: string);
var
  BackupItemSetBackupItemStatusHandle : TBackupItemSetBackupItemStatusHandle;
begin
  BackupItemSetBackupItemStatusHandle := TBackupItemSetBackupItemStatusHandle.Create( DesItemID );
  BackupItemSetBackupItemStatusHandle.SetBackupPath( BackupPath );
  BackupItemSetBackupItemStatusHandle.SetBackupItemStatus( BackupNodeStatus_WaitingBackup );
  BackupItemSetBackupItemStatusHandle.Update;
  BackupItemSetBackupItemStatusHandle.Free;
end;

{ TLocalDesItemSetIsExistHandle }

procedure TDesItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TDesItemSetIsExistHandle.SetToFace;
var
  DesItemSetIsExistFace : TDesItemSetIsExistFace;
begin
  DesItemSetIsExistFace := TDesItemSetIsExistFace.Create( DesItemID );
  DesItemSetIsExistFace.SetIsExist( IsExist );
  DesItemSetIsExistFace.AddChange;
end;

procedure TDesItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsWriteHandle }

procedure TDesItemSetIsWriteHandle.SetIsWrite( _IsWrite : boolean );
begin
  IsWrite := _IsWrite;
end;

procedure TDesItemSetIsWriteHandle.SetToFace;
var
  DesItemSetIsWriteFace : TDesItemSetIsWriteFace;
begin
  DesItemSetIsWriteFace := TDesItemSetIsWriteFace.Create( DesItemID );
  DesItemSetIsWriteFace.SetIsWrite( IsWrite );
  DesItemSetIsWriteFace.AddChange;
end;

procedure TDesItemSetIsWriteHandle.Update;
begin
  SetToFace;
end;

{ TLocalDesItemSetIsLackSpaceHandle }

procedure TDesItemSetIsLackSpaceHandle.SetIsLackSpace( _IsLackSpace : boolean );
begin
  IsLackSpace := _IsLackSpace;
end;

procedure TDesItemSetIsLackSpaceHandle.SetToFace;
var
  DesItemSetIsLackSpaceFace : TDesItemSetIsLackSpaceFace;
begin
  DesItemSetIsLackSpaceFace := TDesItemSetIsLackSpaceFace.Create( DesItemID );
  DesItemSetIsLackSpaceFace.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceFace.AddChange;
end;

procedure TDesItemSetIsLackSpaceHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetIsExistHandle }

procedure TBackupItemSetIsExistHandle.SetIsExist( _IsExist : boolean );
begin
  IsExist := _IsExist;
end;

procedure TBackupItemSetIsExistHandle.SetToFace;
var
  LocalBackupItemSetIsExistFace : TBackupItemSetIsExistFace;
begin
  LocalBackupItemSetIsExistFace := TBackupItemSetIsExistFace.Create( DesItemID );
  LocalBackupItemSetIsExistFace.SetBackupPath( BackupPath );
  LocalBackupItemSetIsExistFace.SetIsExist( IsExist );
  LocalBackupItemSetIsExistFace.AddChange;
end;

procedure TBackupItemSetIsExistHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetSpaceInfoHandle }

procedure TBackupItemSetSpaceInfoHandle.SetSpaceInfo( _FileCount : integer;
  _ItemSize, _CompletedSize : int64 );
begin
  FileCount := _FileCount;
  ItemSize := _ItemSize;
  CompletedSize := _CompletedSize;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToInfo;
var
  LocalBackupItemSetSpaceInfoInfo : TBackupItemSetSpaceInfoInfo;
begin
  LocalBackupItemSetSpaceInfoInfo := TBackupItemSetSpaceInfoInfo.Create( DesItemID );
  LocalBackupItemSetSpaceInfoInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoInfo.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoInfo.Update;
  LocalBackupItemSetSpaceInfoInfo.Free;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToXml;
var
  LocalBackupItemSetSpaceInfoXml : TBackupItemSetSpaceInfoXml;
begin
  LocalBackupItemSetSpaceInfoXml := TBackupItemSetSpaceInfoXml.Create( DesItemID );
  LocalBackupItemSetSpaceInfoXml.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoXml.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoXml.AddChange;
end;

procedure TBackupItemSetSpaceInfoHandle.SetToFace;
var
  LocalBackupItemSetSpaceInfoFace : TBackupItemSetSpaceInfoFace;
begin
  LocalBackupItemSetSpaceInfoFace := TBackupItemSetSpaceInfoFace.Create( DesItemID );
  LocalBackupItemSetSpaceInfoFace.SetBackupPath( BackupPath );
  LocalBackupItemSetSpaceInfoFace.SetSpaceInfo( FileCount, ItemSize, CompletedSize );
  LocalBackupItemSetSpaceInfoFace.AddChange;
end;

procedure TBackupItemSetSpaceInfoHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetBackupItemStatusHandle }

procedure TBackupItemSetBackupItemStatusHandle.SetBackupItemStatus( _BackupItemStatus : string );
begin
  BackupItemStatus := _BackupItemStatus;
end;

procedure TBackupItemSetBackupItemStatusHandle.SetToFace;
var
  LocalBackupItemSetBackupItemStatusFace : TBackupItemSetStatusFace;
begin
  LocalBackupItemSetBackupItemStatusFace := TBackupItemSetStatusFace.Create( DesItemID );
  LocalBackupItemSetBackupItemStatusFace.SetBackupPath( BackupPath );
  LocalBackupItemSetBackupItemStatusFace.SetBackupItemStatus( BackupItemStatus );
  LocalBackupItemSetBackupItemStatusFace.AddChange;
end;

procedure TBackupItemSetBackupItemStatusHandle.Update;
begin
  SetToFace;
end;

{ TLocalBackupItemSetAddCompletedSpaceHandle }

procedure TBackupItemAddCompletedSpaceHandle.SetAddCompletedSpace( _AddCompletedSpace : int64 );
begin
  AddCompletedSpace := _AddCompletedSpace;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToInfo;
var
  LocalBackupItemSetAddCompletedSpaceInfo : TBackupItemSetAddCompletedSpaceInfo;
begin
  LocalBackupItemSetAddCompletedSpaceInfo := TBackupItemSetAddCompletedSpaceInfo.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceInfo.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceInfo.Update;
  LocalBackupItemSetAddCompletedSpaceInfo.Free;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToXml;
var
  LocalBackupItemSetAddCompletedSpaceXml : TBackupItemSetAddCompletedSpaceXml;
begin
  LocalBackupItemSetAddCompletedSpaceXml := TBackupItemSetAddCompletedSpaceXml.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceXml.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceXml.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceXml.AddChange;
end;

procedure TBackupItemAddCompletedSpaceHandle.SetToFace;
var
  LocalBackupItemSetAddCompletedSpaceFace : TBackupItemSetAddCompletedSpaceFace;
begin
  LocalBackupItemSetAddCompletedSpaceFace := TBackupItemSetAddCompletedSpaceFace.Create( DesItemID );
  LocalBackupItemSetAddCompletedSpaceFace.SetBackupPath( BackupPath );
  LocalBackupItemSetAddCompletedSpaceFace.SetAddCompletedSpace( AddCompletedSpace );
  LocalBackupItemSetAddCompletedSpaceFace.AddChange;
end;

procedure TBackupItemAddCompletedSpaceHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TBackupSelectedItemHandle }

procedure TBackupSelectedItemHandle.Update;
var
  ScanPathInfo : TLocalScanPathInfo;
begin
    // 添加扫描路径
  ScanPathInfo := TLocalScanPathInfo.Create( BackupPath );
  ScanPathInfo.SetDesPath( DesItemID );
  MyBackupHandler.AddScanPathInfo( ScanPathInfo );

    // 如果超过限制，则显示提示框
  MyBackupHandler.ShowFreeLimitError;
end;

{ TLocalBackupItemSetLastSyncTimeHandle }

procedure TBackupItemSetLastSyncTimeHandle.SetLastSyncTime( _LastSyncTime : TDateTime );
begin
  LastSyncTime := _LastSyncTime;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToInfo;
var
  LocalBackupItemSetLastSyncTimeInfo : TBackupItemSetLastSyncTimeInfo;
begin
  LocalBackupItemSetLastSyncTimeInfo := TBackupItemSetLastSyncTimeInfo.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeInfo.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeInfo.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeInfo.Update;
  LocalBackupItemSetLastSyncTimeInfo.Free;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToXml;
var
  LocalBackupItemSetLastSyncTimeXml : TBackupItemSetLastSyncTimeXml;
begin
  LocalBackupItemSetLastSyncTimeXml := TBackupItemSetLastSyncTimeXml.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeXml.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeXml.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeXml.AddChange;
end;

procedure TBackupItemSetLastSyncTimeHandle.SetToFace;
var
  LocalBackupItemSetLastSyncTimeFace : TBackupItemSetLastSyncTimeFace;
begin
  LocalBackupItemSetLastSyncTimeFace := TBackupItemSetLastSyncTimeFace.Create( DesItemID );
  LocalBackupItemSetLastSyncTimeFace.SetBackupPath( BackupPath );
  LocalBackupItemSetLastSyncTimeFace.SetLastSyncTime( LastSyncTime );
  LocalBackupItemSetLastSyncTimeFace.AddChange;
end;

procedure TBackupItemSetLastSyncTimeHandle.Update;
begin
  SetToInfo;
  SetToFace;
  SetToXml;
end;

{ TLocalBackupItemSetSpeedHandle }

procedure TBackupItemSetSpeedHandle.SetSpeed( _Speed : int64 );
begin
  Speed := _Speed;
end;

procedure TBackupItemSetSpeedHandle.SetToFace;
var
  LocalBackupItemSetSpeedFace : TBackupItemSetSpeedFace;
begin
  LocalBackupItemSetSpeedFace := TBackupItemSetSpeedFace.Create( DesItemID );
  LocalBackupItemSetSpeedFace.SetBackupPath( BackupPath );
  LocalBackupItemSetSpeedFace.SetSpeed( Speed );
  LocalBackupItemSetSpeedFace.AddChange;
end;

procedure TBackupItemSetSpeedHandle.Update;
begin
  SetToFace;
end;

{ DesItemUserApi }

class procedure DesItemUserApi.AddLocalItem(DesItemID: string);
var
  DesItemAddLocalHandle : TDesItemAddLocalHandle;
begin
  DesItemAddLocalHandle := TDesItemAddLocalHandle.Create( DesItemID );
  DesItemAddLocalHandle.Update;
  DesItemAddLocalHandle.Free;
end;

class procedure DesItemUserApi.RemoveItem(DesItemID: string);
var
  DesItemRemoveHandle : TDesItemRemoveHandle;
begin
  DesItemRemoveHandle := TDesItemRemoveHandle.Create( DesItemID );
  DesItemRemoveHandle.Update;
  DesItemRemoveHandle.Free;
end;

{ DesItemAppApi }

class procedure DesItemAppApi.AddNetworkItem(DesItemID: string);
var
  DesItemAddNetworkHandle : TDesItemAddNetworkHandle;
begin
  DesItemAddNetworkHandle := TDesItemAddNetworkHandle.Create( DesItemID );
  DesItemAddNetworkHandle.Update;
  DesItemAddNetworkHandle.Free;
end;


class procedure DesItemAppApi.SetIsExist(DesItemID: string; IsExist: Boolean);
var
  DesItemSetIsExistHandle : TDesItemSetIsExistHandle;
begin
  DesItemSetIsExistHandle := TDesItemSetIsExistHandle.Create( DesItemID );
  DesItemSetIsExistHandle.SetIsExist( IsExist );
  DesItemSetIsExistHandle.Update;
  DesItemSetIsExistHandle.Free;
end;


class procedure DesItemAppApi.SetIsLackSpace(DesItemID: string;
  IsLackSpace: Boolean);
var
  DesItemSetIsLackSpaceHandle : TDesItemSetIsLackSpaceHandle;
begin
  DesItemSetIsLackSpaceHandle := TDesItemSetIsLackSpaceHandle.Create( DesItemID );
  DesItemSetIsLackSpaceHandle.SetIsLackSpace( IsLackSpace );
  DesItemSetIsLackSpaceHandle.Update;
  DesItemSetIsLackSpaceHandle.Free;
end;

class procedure DesItemAppApi.SetIsWrite(DesItemID: string; IsWrite: Boolean);
var
  DesItemSetIsWriteHandle : TDesItemSetIsWriteHandle;
begin
  DesItemSetIsWriteHandle := TDesItemSetIsWriteHandle.Create( DesItemID );
  DesItemSetIsWriteHandle.SetIsWrite( IsWrite );
  DesItemSetIsWriteHandle.Update;
  DesItemSetIsWriteHandle.Free;
end;

{ TBackupRefreshRestoreHandle }

procedure TBackupRefreshRestoreHandle.ReadBackupList;
begin

end;

procedure TBackupRefreshRestoreHandle.ReadDesList;
begin

end;

procedure TBackupRefreshRestoreHandle.Update;
begin

end;

{ TDesItemReadLocalHandle }

procedure TDesItemReadLocalHandle.AddToFace;
var
  DesItemAddLocalFace : TDesItemAddLocalFace;
begin
  DesItemAddLocalFace := TDesItemAddLocalFace.Create( DesItemID );
  DesItemAddLocalFace.AddChange;
end;

procedure TDesItemReadLocalHandle.AddToInfo;
var
  DesItemAddLocalInfo : TDesItemAddLocalInfo;
begin
  DesItemAddLocalInfo := TDesItemAddLocalInfo.Create( DesItemID );
  DesItemAddLocalInfo.Update;
  DesItemAddLocalInfo.Free;
end;

procedure TDesItemReadLocalHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddLocalHandle }

procedure TDesItemAddLocalHandle.AddToXml;
var
  DesItemAddLocalXml : TDesItemAddLocalXml;
begin
  DesItemAddLocalXml := TDesItemAddLocalXml.Create( DesItemID );
  DesItemAddLocalXml.AddChange;
end;

procedure TDesItemAddLocalHandle.Update;
begin
  inherited;
  AddToXml;
end;

{ TDesItemReadNetworkHandle }

procedure TDesItemReadNetworkHandle.AddToFace;
var
  DesItemAddNetworkFace : TDesItemAddNetworkFace;
begin
  DesItemAddNetworkFace := TDesItemAddNetworkFace.Create( DesItemID );
  DesItemAddNetworkFace.AddChange;
end;

procedure TDesItemReadNetworkHandle.AddToInfo;
var
  DesItemAddNetworkInfo : TDesItemAddNetworkInfo;
begin
  DesItemAddNetworkInfo := TDesItemAddNetworkInfo.Create( DesItemID );
  DesItemAddNetworkInfo.Update;
  DesItemAddNetworkInfo.Free;
end;

procedure TDesItemReadNetworkHandle.Update;
begin
  AddToInfo;
  AddToFace;
end;

{ TDesItemAddNetworkHandle }

procedure TDesItemAddNetworkHandle.AddToXml;
var
  DesItemAddNetworkXml : TDesItemAddNetworkXml;
begin
  DesItemAddNetworkXml := TDesItemAddNetworkXml.Create( DesItemID );
  DesItemAddNetworkXml.AddChange;
end;

procedure TDesItemAddNetworkHandle.Update;
begin
  inherited;
  AddToXml;
end;

end.
