unit UJobFace;

interface

uses  UChangeInfo, VirtualTrees, SysUtils, Classes, SyncObjs, UModelUtil, UMyUtil, DateUtils, Forms, ComCtrls;

type

{$Region ' 传输文件 VirtualTree 界面 ' }

  PTransferData = ^TTransferData;
  TTransferData = record
    NodeID : WideString;
    FileName, Location : WideString;
    FileSize : Int64;
    Percentage : Integer;
    FileType, FileStatus : WideString;
    Speed : Int64;
    UsedTime, RemianTime : Integer;
    FilePath, LocationID : WideString;
    StartTime : TDateTime;
    ChildCount : Integer;
    IsMD5 : Boolean;
    IsExpand : Boolean;
  end;

  {$Region ' 父类 '}

    // 父类
  TVirTransferWriteInfo = class( TChangeInfo )
  protected
    VirTransStatus : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // 父类 修改
  TVirTransferChangeBaseInfo = class( TVirTransferWriteInfo )
  public
    RootID : string;
  public
    constructor Create( _RootID : string );
  end;

      // 父类 修改
  TVirTransferChangeInfo = class( TVirTransferChangeBaseInfo )
  protected
    RootNode : PVirtualNode;
    RootData : PTransferData;
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 根目录 '}

    // 添加
  TVirTransferRootAddInfo = class( TVirTransferChangeBaseInfo )
  public
    RootName : string;
  public
    procedure SetRootName( _RootName : string );
    procedure Update;override;
  end;

    // 清空
  TVirTransferRootClearInfo = class( TVirTransferChangeInfo )
  public
    procedure Update;override;
  end;

    // 名字 显示
  TVirTransferRootNameInfo = class( TVirTransferChangeInfo )
  public
    RootName : string;
  public
    procedure SetRootName( _RootName : string );
    procedure Update;override;
  end;

    // 大小 显示
  TVirTransferRootSizeInfo = class( TVirTransferChangeInfo )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 子目录 ' }

      // 清空 某 Pc 类型
  TVirTransferChildRemovePcChange = class( TVirTransferChangeInfo )
  public
    PcID, FileType : string;
    IsRemoveAllPc : Boolean;
  private
    SearchCount : Integer;
  public
    procedure SetPcID( _PcID : string );
    procedure SetFileType( _FileType : string );
    procedure Update;override;
  private
    procedure RemoveChild( ChildID : string );
    function CheckNextRemove : Boolean;
  end;

    // 子 父类
  TVirTransferChildBaseChange = class( TVirTransferChangeInfo )
  protected
    ChildID : string;
  protected
    ChildNode : PVirtualNode;
    ChildData : PTransferData;
  public
    procedure SetChildID( _ChildID : string );overload;
    procedure SetChildID( _PcID, _FilePath : string );overload;
  private
    function FindChild : Boolean;
    procedure ResetToolBtn( IsEnable : Boolean );
  end;

    // 父类
  TVirTransferChildChange = class( TVirTransferChildBaseChange )
  public
    procedure Update;override;
  end;

    // 添加
  TVirTransferChildAddInfo = class( TVirTransferChildBaseChange )
  public
    FileName, Location : string;
    FileSize : Int64;
    Percentage : Integer;
    FileType, FileStatus : string;
    FilePath, LocationID : string;
    IsMD5 : Boolean;
  public
    constructor Create( _RootID : string );
    procedure SetFileBase( _FilePath, _LocationID : string );
    procedure SetFileInfo( _Location : string; _FileSize : Int64 );
    procedure SetPercentage( _Percentage : Integer );overload;
    procedure SetPercentage( _Position, _FileSize : Int64 );overload;
    procedure SetStatusInfo( _FileType, _FileStatus : string );
    procedure SetIsMD5( _IsMD5 : Boolean );
    procedure Update;override;
  end;

    // 删除
  TVirTransferChildRemoveInfo = class( TVirTransferChildChange )
  public
    procedure Update;override;
  end;

    // 更新 Loading 时的状态
  TVirTransferChildLoadingInfo = class( TVirTransferChildChange )
  public
    Percentage, RemainTime : Integer;
    Speed : Int64;
  public
    procedure SetPercentage( _Position, _FileSize : Int64 );
    procedure SetTimeInfo( _Speed : Int64; _RemainTime : Integer );
    procedure Update;override;
  end;

    // 更新 Loaded 状态
  TVirTransferChildLoadedInfo = class( TVirTransferChildChange )
  public
    UsedTime : Integer;
    Speed : Int64;
  public
    procedure SetTimeInfo( _UsedTime : Integer; _Speed : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

      // Pc 下线
  TVirTransferPcOfflineHandle = class
  private
    PcID : string;
  public
    procedure SetPcID( _PcID : string );
    procedure Update;
  private
    procedure ClearBackup;
    procedure ClearDownload;
    procedure ClearRestore;
  end;

{$EndRegion}

{$Region ' 界面线程 ' }

    // 更新传输速度
  TTransferSpeedFaceThread = class( TThread )
  private
    Lock : TCriticalSection;
    DownloadSpeed : Int64;
    UploadSpeed : Int64;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
  public
    procedure AddDownloadSpeed( Speed : Int64 );
    procedure AddUploadSpeed( Speed : Int64 );
  private
    procedure ShowDownloadSpeed;
    procedure ShowUploadSpeed;
  end;

{$EndRegion}

    // Job Face 界面控制
  TMyJobFace = class( TMyChildFaceChange )
  private
    Lock : TCriticalSection;
    DeletePendHash : TStringHash;
  public
    constructor Create;
    destructor Destroy; override;
  private
    procedure AddUnDeletePend( RootID, ChildID : string );
    function CheckUnDeletePend( RootID, ChildID : string ): Boolean;
  end;

const
  RootID_DownPend = 'StrDownPend';
  RootID_UpPend = 'StrUpPend';
  RootID_DownLoading = 'StrDownLoading';
  RootID_UpLoading = 'StrUpLoading';
  RootID_DownLoaded = 'StrDownLoaded';
  RootID_UpLoaded = 'StrUpLoaded';
  RootID_DownError = 'StrDownError';
  RootID_UpError = 'StrUpError';

  RootName_DownPend = 'StrDownPend';
  RootName_UpPend = 'StrUpPend';
  RootName_DownLoading = 'StrDownloading';
  RootName_UpLoading = 'StrUploading';
  RootName_DownLoaded = 'StrDownloaded';
  RootName_UpLoaded = 'StrUploaded';
  RootName_DownError = 'StrDownError';
  RootName_UpError = 'StrUpError';

  VstTransStatus_FileName = 0;
  VstTransStatus_Location = 1;
  VstTransStatus_FileSize = 2;
  VstTransStatus_Pecentage = 3;
  VstTransStatus_Type = 4;
  VstTransStatus_Status = 5;
  VstTransStatus_UsedTime = 6;
  VstTransStatus_Speed = 7;
  VstTransStatus_RemianTime = 8;

  FileType_Backup = 'Backup';
  FileType_Search = 'Search';
  FileType_Restore = 'Restore';
  FileType_Transfer = 'Transfer';
  FileType_Share = 'Share';

  FileStatus_Waiting = 'Waiting';
  FileStatus_Busy = 'Busy';
  FileStatus_Offline = 'Offline';
  FileStatus_Loading = 'Loading';
  FileStatus_Pause = 'Pause';
  FileStatus_Loaded = 'Loaded';

  Ary_TransferCount : Integer = 8;
  Ary_RootID : Integer = 0;
  Ary_RootName : Integer = 1;

  Ary_TransferRoot : array[ 0..7, 0..1] of string =
          (
             ( RootID_DownPend, RootName_DownPend ),
             ( RootID_UpPend, RootName_UpPend ),
             ( RootID_DownLoading, RootName_DownLoading ),
             ( RootID_UpLoading, RootName_UpLoading ),
             ( RootID_DownLoaded, RootName_DownLoaded ),
             ( RootID_UpLoaded, RootName_UpLoaded ),
             ( RootID_DownError, RootName_DownError ),
             ( RootID_UpError, RootName_UpError )
          );

  Sign_MD5 = ' (MD5)';

var
  MyJobFace : TMyJobFace;
  TransferSpeedFaceThread : TTransferSpeedFaceThread;

implementation

uses UMainForm, UMainFormFace;

{ TVirTransferRootNameInfo }

procedure TVirTransferRootNameInfo.SetRootName(_RootName: string);
begin
  RootName := _RootName;
end;

procedure TVirTransferRootNameInfo.Update;
begin
  inherited;

  RootData.FileName := RootName;
end;

{ TVirTransferRootSizeInfo }

procedure TVirTransferRootSizeInfo.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TVirTransferRootSizeInfo.Update;
begin
  inherited;

  RootData.FileSize := FileSize;
end;

{ TVirTransferChildChange }

procedure TVirTransferChildBaseChange.SetChildID(_ChildID: string);
begin
  ChildID := _ChildID;
end;

function TVirTransferChildBaseChange.FindChild: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PTransferData;
begin
  Result := False;
  ChildNode := nil;
  SelectNode := RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VirTransStatus.GetNodeData( SelectNode );
    if SelectData.NodeID = ChildID then
    begin
      Result := True;
      ChildNode := SelectNode;
      ChildData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TVirTransferChildBaseChange.ResetToolBtn( IsEnable : Boolean );
var
  tbtn : TToolButton;
begin
  if RootID = RootID_DownLoaded then
    tbtn := frmMainForm.tbtnTsClearDowned
  else
  if RootID = RootID_UpLoaded then
    tbtn := frmMainForm.tbtnTsClearUped
  else
  if RootID = RootID_DownError then
    tbtn := frmMainForm.tbtnTsClearDownError
  else
  if RootID = RootID_UpError then
    tbtn := frmMainForm.tbtnClearUpError
  else
    Exit;

  tbtn.Enabled := IsEnable;
end;

procedure TVirTransferChildBaseChange.SetChildID(_PcID, _FilePath: string);
begin
  ChildID := _PcID + '|' + _FilePath;
end;

{ TVirTransferChildChange }

procedure TVirTransferChildChange.Update;
begin
  inherited;

  FindChild;
end;

{ TVirTransferChildAddInfo }

constructor TVirTransferChildAddInfo.Create(_RootID: string);
begin
  inherited;
  IsMD5 := False;
end;

procedure TVirTransferChildAddInfo.SetFileBase(_FilePath, _LocationID: string);
begin
  FilePath := _FilePath;
  LocationID := _LocationID;
  FileName := ExtractFileName( FilePath );
end;

procedure TVirTransferChildAddInfo.SetFileInfo(_Location : string;
  _FileSize: Int64);
begin
  Location := _Location;
  FileSize := _FileSize;
end;

procedure TVirTransferChildAddInfo.SetIsMD5(_IsMD5: Boolean);
begin
  IsMD5 := _IsMD5;
end;

procedure TVirTransferChildAddInfo.SetPercentage(_Position, _FileSize: Int64);
begin
  SetPercentage( MyPercentage.getPercent( _Position, _FileSize ) );
end;

procedure TVirTransferChildAddInfo.SetPercentage(_Percentage: Integer);
begin
  Percentage := _Percentage;
end;

procedure TVirTransferChildAddInfo.SetStatusInfo(_FileType,
  _FileStatus: string);
begin
  FileType := _FileType;
  FileStatus := _FileStatus;
end;

procedure TVirTransferChildAddInfo.Update;
var
  IsAdded : Boolean;
begin
    // 已删除
  if MyJobFace.CheckUnDeletePend( RootID, ChildID ) then
    Exit;

  inherited;

    //  没有找到相同则创建
  IsAdded := True;
  if ( RootID = RootID_DownError ) or ( RootID = RootID_UpError ) then
    if FindChild then
    begin
      IsAdded := False;
      VirTransStatus.MoveTo( ChildNode, RootNode.LastChild, amInsertAfter, False );
    end;

    // 添加 新的
  if IsAdded then
  begin
    RootData.FileSize := RootData.FileSize + FileSize;
    RootData.ChildCount := RootData.ChildCount + 1;

    ChildNode := VirTransStatus.AddChild( RootNode );
    ChildData := VirTransStatus.GetNodeData( ChildNode );
    ChildData.NodeID := ChildID;
  end;

    // 添加信息
  ChildData.FileName := FileName;
  ChildData.LocationID := LocationID;
  ChildData.Location := Location;
  ChildData.FilePath := FilePath;
  ChildData.FileSize := FileSize;
  ChildData.Percentage := Percentage;
  ChildData.FileType := FileType;
  ChildData.FileStatus := FileStatus;
  ChildData.StartTime := Now;
  ChildData.IsMD5 := IsMD5;

    // 出现子节点
  if RootNode.ChildCount = 1 then
  begin
    ResetToolBtn( True );
    if RootData.IsExpand and not VirTransStatus.Expanded[ RootNode ] then
      VirTransStatus.Expanded[ RootNode ] := True;
  end;
end;

{ TVirTransferRootAddInfo }

procedure TVirTransferRootAddInfo.SetRootName(_RootName: string);
begin
  RootName := _RootName;
end;

procedure TVirTransferRootAddInfo.Update;
var
  RootNode : PVirtualNode;
  Data : PTransferData;
begin
  inherited;

  RootNode := VirTransStatus.AddChild( nil );
  Data := VirTransStatus.GetNodeData( RootNode );
  Data.NodeID := RootID;
  Data.FileName := RootName;
  Data.FileSize := 0;
  Data.ChildCount := 0;
  Data.IsMD5 := False;
  Data.IsExpand := False;
end;

{ TVirTransferChangeInfo }

constructor TVirTransferChangeBaseInfo.Create(_RootID: string);
begin
  RootID := _RootID;
end;

{ TVirTransferChangeInfo }

procedure TVirTransferChangeInfo.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PTransferData;
begin
  inherited;

  SelectNode := VirTransStatus.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VirTransStatus.GetNodeData( SelectNode );
    if SelectData.NodeID = RootID then
    begin
      RootNode := SelectNode;
      RootData := SelectData;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;



{ TMyJobFace }

procedure TMyJobFace.AddUnDeletePend(RootID, ChildID: string);
var
  PendStr : string;
begin
  PendStr := RootID + '|' + ChildID;

  Lock.Enter;
  DeletePendHash.AddString( PendStr );
  Lock.Leave;
end;

function TMyJobFace.CheckUnDeletePend(RootID, ChildID: string): Boolean;
var
  PendStr : string;
begin
  PendStr := RootID + '|' + ChildID;

  Lock.Enter;
  if DeletePendHash.ContainsKey( PendStr ) then
  begin
    DeletePendHash.Remove( PendStr );
    Result := True;
  end
  else
    Result := False;
  Lock.Leave;
end;

constructor TMyJobFace.Create;
begin
  inherited;
  Lock := TCriticalSection.Create;
  DeletePendHash := TStringHash.Create;
end;

destructor TMyJobFace.Destroy;
begin
  DeletePendHash.Free;
  Lock.Free;
  inherited;
end;

{ TVirTransferChildLoadingInfo }

procedure TVirTransferChildLoadingInfo.SetPercentage(_Position,
  _FileSize: Int64);
begin
  Percentage := MyPercentage.getPercent( _Position, _FileSize );
end;

procedure TVirTransferChildLoadingInfo.SetTimeInfo(_Speed : Int64;
  _RemainTime: Integer);
begin
  Speed := _Speed;
  RemainTime := _RemainTime;
end;

procedure TVirTransferChildLoadingInfo.Update;
begin
  inherited;

  if ChildNode = nil then
    Exit;

  ChildData.Percentage := Percentage;
  ChildData.Speed := Speed;
  ChildData.RemianTime := RemainTime;

  VirTransStatus.RepaintNode( ChildNode );
end;

{ TVirTransferChildLoadedInfo }

procedure TVirTransferChildLoadedInfo.SetTimeInfo(_UsedTime: Integer;
  _Speed: Int64);
begin
  UsedTime := _UsedTime;
  Speed := _Speed;
end;

procedure TVirTransferChildLoadedInfo.Update;
begin
  inherited;

  if ChildNode = nil then
    Exit;

  ChildData.UsedTime := UsedTime;
  ChildData.Speed := Speed;
end;

{ TVirTransferWriteInfo }

procedure TVirTransferWriteInfo.Update;
begin
  VirTransStatus := frmMainForm.vstTransStatus;
end;

{ TVirTransferRootClearInfo }

procedure TVirTransferRootClearInfo.Update;
begin
  inherited;

  VirTransStatus.DeleteChildren( RootNode );
end;

{ TVirTransferChildRemoveInfo }

procedure TVirTransferChildRemoveInfo.Update;
begin
  inherited;

  if ChildNode <> nil then
  begin
    RootData.FileSize := RootData.FileSize - ChildData.FileSize;
    RootData.ChildCount := RootData.ChildCount - 1;
    VirTransStatus.DeleteNode( ChildNode );
  end
  else   // 添加到等待删除列表
    MyJobFace.AddUnDeletePend( RootID, ChildID );

    // 出现子节点消失
  if RootNode.ChildCount = 0 then
    ResetToolBtn( False );
end;

{ TTransferSpeedFaceThread }

procedure TTransferSpeedFaceThread.AddDownloadSpeed(Speed: Int64);
begin
  Lock.Enter;
  DownloadSpeed := DownloadSpeed + Speed;
  Lock.Leave;
end;

procedure TTransferSpeedFaceThread.AddUploadSpeed(Speed: Int64);
begin
  Lock.Enter;
  UploadSpeed := UploadSpeed + Speed;
  Lock.Leave;
end;

constructor TTransferSpeedFaceThread.Create;
begin
  inherited Create( True );
  Lock := TCriticalSection.Create;
  DownloadSpeed := 0;
  UploadSpeed := 0;
end;

destructor TTransferSpeedFaceThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  Lock.Free;
  inherited;
end;

procedure TTransferSpeedFaceThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
    StartTime := Now;
    while ( SecondsBetween( Now, StartTime ) < 1 ) and not Terminated do
      Sleep(100);

    if Terminated then
      Break;

    ShowDownloadSpeed;

    ShowUploadSpeed;
  end;

  inherited;
end;

procedure TTransferSpeedFaceThread.ShowDownloadSpeed;
var
  TempSize : Int64;
  ShowStr : string;
  DownSpeedChangeInfo : TDownSpeedChangeInfo;
begin
  Lock.Enter;
  TempSize := DownloadSpeed;
  DownloadSpeed := 0;
  Lock.Leave;

  ShowStr := MySpeed.getSpeedStr( TempSize );
  DownSpeedChangeInfo := TDownSpeedChangeInfo.Create( ShowStr );
  MyMainFormFace.AddChange( DownSpeedChangeInfo );
end;

procedure TTransferSpeedFaceThread.ShowUploadSpeed;
var
  TempSize : Int64;
  ShowStr : string;
  UpSpeedChangeInfo : TUpSpeedChangeInfo;
begin
  Lock.Enter;
  TempSize := UploadSpeed;
  UploadSpeed := 0;
  Lock.Leave;

  ShowStr := MySpeed.getSpeedStr( TempSize );
  UpSpeedChangeInfo := TUpSpeedChangeInfo.Create( ShowStr );
  MyMainFormFace.AddChange( UpSpeedChangeInfo );
end;

{ TVirTransferChildRemovePcChange }

function TVirTransferChildRemovePcChange.CheckNextRemove: Boolean;
begin
  inc( SearchCount );
  if SearchCount >= 5 then
  begin
    SearchCount := 0;
    Sleep(1);
    Application.ProcessMessages;
  end;

  Result := MyFaceChange.IsRun;
end;

procedure TVirTransferChildRemovePcChange.RemoveChild(ChildID: string);
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( RootID );
  VirTransferChildRemoveInfo.SetChildID( ChildID );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

procedure TVirTransferChildRemovePcChange.SetFileType(_FileType: string);
begin
  FileType := _FileType;
end;

procedure TVirTransferChildRemovePcChange.SetPcID(_PcID: string);
begin
  PcID := _PcID;
  IsRemoveAllPc := PcID = '';
end;

procedure TVirTransferChildRemovePcChange.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PTransferData;
begin
  inherited;

  SearchCount := 0;
  ChildNode := RootNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VirTransStatus.GetNodeData( ChildNode );
    if ( ChildData.FileType = FileType ) and
       ( IsRemoveAllPc or ( ChildData.LocationID = PcID ) )
    then
      RemoveChild( ChildData.NodeID );

    ChildNode := ChildNode.NextSibling;

      // 程序退出
    if not CheckNextRemove then
      Break;
  end;
end;

{ TVirTransferPcOfflineHandle }

procedure TVirTransferPcOfflineHandle.ClearBackup;
var
  VirTransferChildRemovePcChange : TVirTransferChildRemovePcChange;
begin
    // 删除 UpPend
  VirTransferChildRemovePcChange := TVirTransferChildRemovePcChange.Create( RootID_DownPend );
  VirTransferChildRemovePcChange.SetPcID( PcID );
  VirTransferChildRemovePcChange.SetFileType( FileType_Backup );
  MyJobFace.AddChange( VirTransferChildRemovePcChange );
end;

procedure TVirTransferPcOfflineHandle.ClearDownload;
var
  VirTransferChildRemovePcChange : TVirTransferChildRemovePcChange;
begin
    // 删除 UpPend
  VirTransferChildRemovePcChange := TVirTransferChildRemovePcChange.Create( RootID_UpPend );
  VirTransferChildRemovePcChange.SetPcID( PcID );
  VirTransferChildRemovePcChange.SetFileType( FileType_Search );
  MyJobFace.AddChange( VirTransferChildRemovePcChange );
end;

procedure TVirTransferPcOfflineHandle.ClearRestore;
var
  VirTransferChildRemovePcChange : TVirTransferChildRemovePcChange;
begin
    // 删除 UpPend
  VirTransferChildRemovePcChange := TVirTransferChildRemovePcChange.Create( RootID_UpPend );
  VirTransferChildRemovePcChange.SetPcID( PcID );
  VirTransferChildRemovePcChange.SetFileType( FileType_Restore );
  MyJobFace.AddChange( VirTransferChildRemovePcChange );
end;

procedure TVirTransferPcOfflineHandle.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVirTransferPcOfflineHandle.Update;
begin
  ClearBackup;

  ClearDownload;

  ClearRestore;
end;

end.
