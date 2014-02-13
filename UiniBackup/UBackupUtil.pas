unit UBackupUtil;

interface

type

  TFindNodeIcon = class
  private
    PathType : string;
    BackupStatus : string;
  public
    constructor Create( _PathType, _BackupStatus : string );
    function get : Integer;
  private
    function getFileIcon : Integer;
    function getFolderIcon : Integer;
  end;

  BackupUtil = class
  public
    class function getNodeIcon( PathType, BackupStatus : string ): Integer;
    class function getNodeHint( BackupStatus : string ): string;
  end;

implementation

uses UBackupInfoFace, UMyBackupInfo, UMyUtil;

{ BackupUtil }

class function BackupUtil.getNodeHint(BackupStatus: string): string;
begin
  if BackupStatus = BackupPathStatus_Loading then
    Result := NodeStatus_Loading
  else
  if BackupStatus = BackupPathStatus_NotExist then
    Result := NodeStatus_NotExists
  else
  if BackupStatus = BackupStatus_Empty then
    Result := NodeStatus_Empty
  else
  if BackupStatus = BackupStatus_Completed then
    Result := NodeStatus_Completed
  else
  if BackupStatus = BackupStatus_PartCompleted then
    Result := NodeStatus_PartCompleted
  else
  if BackupStatus = BackupStatus_Incompleted then
    Result := NodeStatus_Incompleted;
end;

class function BackupUtil.getNodeIcon(PathType, BackupStatus: string): Integer;
var
  FindNodeIcon : TFindNodeIcon;
begin
  FindNodeIcon := TFindNodeIcon.Create( PathType, BackupStatus );
  Result := FindNodeIcon.get;
  FindNodeIcon.Free;
end;

{ TFindNodeIcon }

constructor TFindNodeIcon.Create(_PathType, _BackupStatus: string);
begin
  PathType := _PathType;
  BackupStatus := _BackupStatus;
end;

function TFindNodeIcon.get: Integer;
begin
  if PathType = PathType_Folder then
    Result := getFolderIcon
  else
  if PathType = PathType_File then
    Result := getFileIcon;
end;

function TFindNodeIcon.getFileIcon: Integer;
begin
  if BackupStatus = BackupPathStatus_Loading then
    Result := NodeIcon_FileLoading
  else
  if BackupStatus = BackupPathStatus_NotExist then
    Result := NodeIcon_FileNotExists
  else
  if BackupStatus = BackupStatus_Empty then
    Result := NodeIcon_FileIncompleted
  else
  if BackupStatus = BackupStatus_Completed then
    Result := NodeIcon_FileCompleted
  else
  if BackupStatus = BackupStatus_PartCompleted then
    Result := NodeIcon_FilePartCompleted
  else
  if BackupStatus = BackupStatus_Incompleted then
    Result := NodeIcon_FileIncompleted;
end;

function TFindNodeIcon.getFolderIcon: Integer;
begin
  if BackupStatus = BackupPathStatus_Loading then
    Result := NodeIcon_FolderLoading
  else
  if BackupStatus = BackupPathStatus_NotExist then
    Result := NodeIcon_FolderNotExists
  else
  if BackupStatus = BackupStatus_Empty then
    Result := NodeIcon_FolderEmpty
  else
  if BackupStatus = BackupStatus_Completed then
    Result := NodeIcon_FolderCompleted
  else
  if BackupStatus = BackupStatus_PartCompleted then
    Result := NodeIcon_FolderPartCompleted
  else
  if BackupStatus = BackupStatus_Incompleted then
    Result := NodeIcon_FolderIncompleted;
end;

end.
