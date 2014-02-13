unit UMyUtil;

interface

uses SysUtils, Masks, StrUtils, Windows, WinSock, Nb30, Sockets, DateUtils, Math, Controls, ShellAPI,
     Classes, Forms, ShlObj, ActiveX, UEncrypt, Dialogs, CommCtrl, Messages, CnMD5, TlHelp32, WinInet,
     FileCtrl, IniFiles, ComCtrls, ComObj, udebug;

type

  MySize = class
  public
    class function getFileSizeStr(FileSize: Int64): string;
    class function getFileSize(FileSizeStr: string): Int64;
    class function compareSize( Size1, Size2 : Int64 ): Integer;
  public
    class function getSpaceValue( Value : Integer; SpaceType : string ): Int64;
    class function getSizeValue( FileSizeType, Value : integer ): Int64;
  end;

  MyPercentage = class
  public
    class function getPercentageStr(Percentage: Integer): string;overload;
    class function getPercentageStr( Position, FileSize : Int64 ): string;overload;
    class function getStrToPercentage(s: string): Integer;
    class function getPercent( Position, FileSize : Int64 ): Integer;
  public
    class function getCompareStr( Position, FileSize : Int64 ): string;
  end;

  MySpeed = class
  public
    class function getSpeedStr(Speed: Integer): string; static;
    class function getStrToSpeed(s: string): Integer; static;
  end;

  MyTime = class
  public
    class function getMyTimeStr(Time: Integer): string;
    class function getMyMinTimeStr(Time: Integer): string;
    class function getMaxTime : Integer;
  public

  end;

  MyCount = class
  public
    class function getCountStr( Count : Integer ): string;
    class function getCountInt( CountStr : string ): Integer;
  end;

  MyMatchMask = class
  public
    class function Check( FileName, MaskStr : string ): Boolean;
    class function CheckEqualsOrChild( ChildPath, ParentPath : string ): Boolean;
    class function CheckChild( ChildPath, ParentPath : string ): Boolean;
  end;

  MyFileInfo = class
  public
    class function getFileLastWriteTime( FilePath : string ): TDateTime;
    class function getFileSize( FilePath : string ): Int64;
    class function getFileName( FullPath : string ): string;
  public
    class function getFileIsInUse( FilePath : string ): Boolean;
  end;

  MyFilePath = class
  public
    class function getPath( s : string ) : string;
    class function getHasChild( FullPath : string ): Boolean;
    class function getLinkPath( LinkFile : string ): string;
  public
    class function getDownloadPath( Path : string ): string;
    class function getUploadPath( Path : string ): string;
  public
    class function getIsExist( FullPath : string ): Boolean;
    class function getIsModify( FullPath : string ): Boolean;
    class function getPathType( FullPath : string ): string;
    class function getIsDriver( FullPath : string ): Boolean;
    class function getDriverExist( FullPath : string ): Boolean;
  public
    class function getChildFolderList( FolderPath : string ): TStringList;
  public
    class function getNetworkPcPath : string;
    class function getDesklopPath : string;
  end;

  MyDatetime = class
  public
    class function Equals( t1, t2 : TDateTime ): Boolean;
    class function Compare( dt1, dt2 : TDateTime ): Integer;
  public
    class function getAgoStr( t : TDateTime ): string;
    class function getAfterStr( t : TDateTime ): string;
  private
    class function getStr( t : TDateTime ): string;
  end;

  MyCpuID = class
  public
    class function get : string;
  end;


  MyComputerID = class
  public
    class function get : string;
  private
    class function Read : string;
    class function getNewPcID : string;
    class procedure Save( PcID : string );
  end;

  MyMacAddress = class
  public
    class function getStr : string;
    class function getFirstStr : string;
    class function Equals( OldHardCode : string ): Boolean;
  private
    class function getStrList : TStringList;
  end;


  MyComputerName = class
  public
    class function get : string;
  end;

  MyParseHost = class
  public
    class function IsIpStr(Str: string): Boolean;
    class function IsPortStr(str : string): Boolean;
  public
    class function HostToIP(Name: AnsiString; var Ip: string): Boolean;
    class function getIpStr( var Domain : string ): string;
  public
    class function CheckIpLan( Ip1, Ip2 : string ): Boolean;
  end;

  TFileTimes = (ftLastAccess, ftLastWrite, ftCreation);
  MyFileSetTime = class
  public
    class procedure SetTime(FileName: string; DateTime: TDateTime);
  end;

  MyRename = class
  public
    class procedure RenameExist(FilePath: string);
    class function getFileName( FileName : string; i : Integer ) : string;
  end;


  MyDriver = class
  public
    class function IsDriver( FullPath : string ): Boolean;
  end;

  MyIpList = class
  public
    class function get: TStringList;
  end;

  MyIp = class
  public
    class function get: string;
  end;

  MyBroadcastIpList = class
  public
    class function get: TStringList;
  private
    class function getBroadcastIp( IpStr, MaskStr : string ): string;
  end;

  MyHardDisk = class
  public
    class function CheckHardDisk(BackupFoldePath: string; FileSize: int64): Boolean; // 检查磁盘空间是否足够
    class function getHardDiskFreeSize(BackupFolderPath: string): Int64; // 获取 当前路径可用磁盘空间
    class function getHardDiskAllSize( Path : string ): Int64; // 获取 当前路径所有磁盘空间
    class function getNetworkFolderFree( Path : string ): Int64;
  public
    class function getAllHardDisk: TStringList; // 获取所有磁盘 C:\
    class function getBiggestHardDIsk: string; // 获取最大的磁盘路径  C:\
    class function getAvailablePath( FilePath : string ): string; // 如果 FilePath 磁盘不存在，则选择磁盘最大的
    class function getDriverExist( Driver : string ): Boolean; // 磁盘是否存在
  end;

  MyString = class
  public
    class function CutStartStr( CutStr, SourceStr : string ): string;
    class function CutStopStr( CutStr, SourceStr : string ): string;
    class function CutRootFolder( FilePath : string ): string;
    class function CutLastFolder( FilePath : string ): string;
  public
    class function GetBeforeStr( SplitStr, SourceStr : string ): string;
    class function GetAfterStr( SplitStr, SourceStr : string ): string;
    class function GetRootFolder( FilePath : string ): string;
    class function GetLastFolder( FilePath : string ): string;
  public
    class function GetLastPos( SubStr, SourceStr : string ): Integer;
  end;

  MyStringList = class
  public
    class function getStrings( ss : TStrings ): TStringList;
    class function getString( s : string ): TStringList;
  end;

  MyExplore = class
  public
    class procedure OperFolder(FilePath: string);
  end;

  MySelectFolderDialog = class
  public
    class function SelectNetPc( ShowStr : string; var OutPath : string ) : Boolean;
  public
    class function Select( ShowStr, IniPath : string; var OutPath : string ) : Boolean;overload;
    class function Select( ShowStr, IniPath : string; var OutPath : string; h : Integer ) : Boolean;overload;
  public
    class function SelectNormal( ShowStr, IniPath : string; var OutPath : string ): Boolean;
  end;

  MyIniFile = class
  public
    class function getIniFilePath: string;
  end;

  MyAppDataPath = class
  public
   class function get : string;
  end;

  MyEncrypt = class
  public
    class function EncodeMD5String( s : string ): string;
  public
    class function EncodeStr( s : string ): string;
    class function DecodeStr( s : string ): string;
  end;

  MyMessageBox = class
  public
    class procedure ShowError( ShowStr : string );overload;
    class procedure ShowError( Handle : Integer; ShowStr : string );overload;
    class procedure ShowErrorTop( ShowStr : string );
  public
    class procedure ShowOk( ShowStr : string );overload;
    class procedure ShowOk( Handle : Integer; ShowStr : string );overload;
  public
    class procedure ShowWarnning( ShowStr : string );overload;
    class procedure ShowWarnning( Handle : Integer; ShowStr : string );overload;
  public
    class function ShowConfirm( ShowStr : string ): Boolean;
  end;

  MyMessageHint = class
  public
    class procedure ShowHint( h:HWND; HintStr:string; Title : AnsiString; IconType, ShowTime:Integer );overload;
    class procedure ShowHint( h:HWND; HintStr:string; Title : AnsiString; IconType :Integer );overload;
  public
    class procedure ShowOk( Handle : Integer; HintStr : string );
    class procedure ShowWarnning( Handle : Integer; HintStr : string );
    class procedure ShowError( Handle : Integer; HintStr : string );
  end;

  MySplitStr = class
  public
    class function getList( s, SplitStr: string ): TStringList;
    class function GetDriveString( DriveString : string; Index: Integer ): string;
  end;

  MyAppRun = class
  public
    class function getAppCount : Integer;
  end;

  MyInternetExplorer = class
  public
    class procedure OpenWeb( Url : string );
  end;

  MyHideFile = class
  public
    class procedure Hide( FilePath : string );
  end;

  MyFolderDelete = class
  public
    class function DeleteDir(sDirectory: string): Boolean;
  public
    class function FileDelete( FilePath : string ): Boolean;
    class procedure RemoveParentFolder( FilePathPath : string );
    class function IsExistChild( FolderPath : string ): Boolean;
  end;

  MyUpnpUtil = class
  public
    class function getUpnpPort( LanIp : string ): string;
  end;

  MyNetworkFolderUtil = class
  public
    class function IsNetworkFolder( Path : string ): Boolean;
    class function NetworkFolderExist( Path : string ): Boolean;
  end;

  MyNetworkConnUtil = class
  public
    class function getExistLan : Boolean;
  end;

  MyCreateFolder = class
  public
    class function IsCreate( FilePath : string ) : Boolean;
  end;

  MyMD5Util = class
  public
    class function getBuffer( const Buffer; Count: Longword ): string;
  end;

  TimeTypeUtil = class
  public
    class function getMins( TimeType, TimeInt : Integer ): Integer;
    class function getMinShowStr( Mins : Integer ): string;
    class procedure FindTimeInfo( Mins : Integer; var TimeType, TimeInt : Integer );
  public
    class function getTimeTypeStr( TimeType : Integer ): string;
    class function getTimeShow( TimeType, TimeValue : Integer ): string;
  end;

  MyEmail = class
  public
    class function IsVaildEmailAddr(EmailAddr:String):boolean;
  end;

  MyAppEdition = class
  public
    class function ReplaceFs( s : string ): string;
  end;

  MyFireWall = class
  public
    class procedure MakeThrough;
  end;

  MyKeyBorad = class
  public
    class procedure CheckDelete( tbtn : TToolButton; Key : Word );
    class procedure CheckEnter( tbtn: TToolButton; Key : Word );
    class procedure CheckDeleteAndEnter( tbtnDel, tbtnEnter : TToolButton; Key : Word );
  public
    class function CheckCtrlEnter( tbtn: TToolButton; Key : Word; Shift: TShiftState ): Boolean;
  end;

  MyButton = class
  public
    class procedure Click( tbtn : TToolButton );
  end;

const
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH     = 8;

const
  TimeType_Minutes = 0;
  TimeType_Hourse = 1;
  TimeType_Day = 2;
  TimeType_Week = 3;
  TimeType_Month = 4;


  TimeTypeInt_Minutes = 1;
  TimeTypeInt_Hourse = 60 * TimeTypeInt_Minutes;
  TimeTypeInt_Day = 24 * TimeTypeInt_Hourse;
  TimeTypeInt_Week = 7 * TimeTypeInt_Day;
  TimeTypeInt_Month = 30 * TimeTypeInt_Day;

  ShowTime_Months = 'Months';
  ShowTime_Weeks = 'Weeks';
  ShowTime_Days = 'Days';
  ShowTime_Hours = 'Hours';
  ShowTime_Minutes = 'Minutes';

  Time_Day = ' Days';
  Time_Hour = ' Hours';
  Time_Min = ' Minutes';

const
  DiscriptName_BackupCow = 'Backup Cow';
  DiscriptName_FolderTransfer = 'Folder Transfer';

var
  UpnpPort_Start : Integer = 15150;
  AppData_Name : string = 'BackupCow';

Type
  TIPAddressString = Array[0..4*4-1] of AnsiChar;

  PIPAddrString = ^TIPAddrString;
    TIPAddrString = Record
    Next      : PIPAddrString;
    IPAddress : TIPAddressString;
    IPMask    : TIPAddressString;
    Context   : Integer;
  End;

  PIPAdapterInfo = ^TIPAdapterInfo;
    TIPAdapterInfo = Record { IP_ADAPTER_INFO }
    Next                : PIPAdapterInfo;
    ComboIndex          : Integer;
    AdapterName         : Array[0..MAX_ADAPTER_NAME_LENGTH+3] of ansiChar;
    Description         : Array[0..MAX_ADAPTER_DESCRIPTION_LENGTH+3] of ansiChar;
    AddressLength       : Integer;
    Address             : Array[1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index               : Integer;
    _Type               : Integer;
    DHCPEnabled         : Integer;
    CurrentIPAddress    : PIPAddrString;
    IPAddressList       : TIPAddrString;
    GatewayList         : TIPAddrString;
  End;

const
  FileSizeType_KB = 0;
  FileSizeType_MB = 1;
  FileSizeType_GB = 2;
  FileSizeType_TB = 3;

  FileSize_B = ' B';
  FileSize_KB = ' KB';
  FileSize_MB = ' MB';
  FileSize_GB = ' GB';

  Size_B: Int64 = 1;
  Size_KB: Int64 = 1024;
  Size_MB: Int64 = 1024 * 1024;
  Size_GB: Int64 = 1024 * 1024 * 1024;

const
  PathType_Folder = 'Folder';
  PathType_File = 'File';

const
  Sign_Driver = '_Driver';
  Sign_NetworkFolder = 'NetworkFolder_';
  Sign_Percentage = ' %';
  Sign_Speed = ' / S';
  Sign_ComparePercent = '/';
  Sign_NA = 'N/A';

  EncodeKey_Config = 'CyBackupCow2011';

  Split_MacAddress = '-';

  Ini_BackupCow = 'BackupCow';
  Ini_ComputerID = 'ComputerID';
var
  Register_IsFirst : Boolean = False;

var
  MainFormHandle : Integer;


implementation

{ MySize }

class function MySize.compareSize(Size1, Size2: Int64): Integer;
begin
  if Size1 > Size2 then
    Result := 1
  else
  if Size1 = Size2 then
    Result := 0
  else
    Result := -1;
end;

class function MySize.getFileSize(FileSizeStr: string): Int64;
var
  ResultStr: string;
  FileSizeExt: Int64;
  FileSizeDouble: Double;
  ResultSize: Int64;
begin
  if Pos(FileSize_GB, FileSizeStr) > 0 then
  begin
    ResultStr := Copy(FileSizeStr, 1, Pos(FileSize_GB, FileSizeStr) - 1);
    FileSizeExt := Size_GB;
  end
  else
  if Pos(FileSize_MB, FileSizeStr) > 0 then
  begin
    ResultStr := Copy(FileSizeStr, 1, Pos(FileSize_MB, FileSizeStr) - 1);
    FileSizeExt := Size_MB;
  end
  else
  if Pos(FileSize_KB, FileSizeStr) > 0 then
  begin
    ResultStr := Copy(FileSizeStr, 1, Pos(FileSize_KB, FileSizeStr) - 1);
    FileSizeExt := Size_KB;
  end
  else
  if Pos(FileSize_B, FileSizeStr) > 0 then
  begin
    ResultStr := Copy(FileSizeStr, 1, Pos(FileSize_B, FileSizeStr) - 1);
    FileSizeExt := Size_B;
  end
  else
  begin
    Result := 0;
    Exit;
  end;

  if FileSizeExt = Size_B then
    ResultSize := StrToIntDef( ResultStr, 0 )
  else
  begin
    FileSizeDouble := StrToFloatdef(ResultStr, 0);
    ResultSize := Round(FileSizeDouble * 100) * (FileSizeExt div 100);
  end;

  Result := ResultSize;
end;

class function MySize.getFileSizeStr(FileSize: Int64): string;
const
  FileSizeShowLen: Integer = 3;
var
  FileSizeDouble: Double;
  FileSizeExt: string;
  FileSizeLen: Integer;
  i: Integer;
  a: Integer;
begin
  if FileSize < 0 then
    FileSize := 0;

  if FileSize >= Size_GB then
  begin
    FileSizeDouble := FileSize / Size_GB;
    FileSizeExt := FileSize_GB;
  end
  else
    if FileSize >= Size_MB then
    begin
      FileSizeDouble := FileSize / Size_MB;
      FileSizeExt := FileSize_MB;
    end
    else
      if FileSize >= Size_KB then
      begin
        FileSizeDouble := FileSize / Size_KB;
        FileSizeExt := FileSize_KB;
      end
      else
      begin
        FileSizeDouble := FileSize;
        FileSizeExt := FileSize_B;
      end;

  FileSizeLen := Length(IntToStr(trunc(FileSizeDouble)));
  a := 1;
  for i := 0 to FileSizeShowLen - FileSizeLen - 1 do
    a := a * 10;
  FileSizeDouble := Trunc(FileSizeDouble * a) / a;

  Result := FloatToStr(FileSizeDouble) + FileSizeExt;
end;

class function MySize.getSizeValue(FileSizeType, Value: integer): Int64;
var
  BaseInt : Int64;
begin
  if FileSizeType = FileSizeType_KB then
    BaseInt := Size_KB
  else
  if FileSizeType = FileSizeType_MB then
    BaseInt := Size_MB
  else
  if FileSizeType = FileSizeType_GB then
    BaseInt := Size_GB
  else
  if FileSizeType = FileSizeType_TB then
    BaseInt := Size_GB * 1024
  else
    BaseInt := 1;

  Result := BaseInt * Value;
end;

class function MySize.getSpaceValue(Value: Integer; SpaceType: string): Int64;
begin
  SpaceType := ' ' + SpaceType;

  if SpaceType = FileSize_B then
    Result := Size_B
  else
  if SpaceType = FileSize_KB then
    Result := Size_KB
  else
  if SpaceType = FileSize_MB then
    Result := Size_MB
  else
  if SpaceType = FileSize_GB then
    Result := Size_GB
  else
    Result := Size_B;

  Result := Value * Result;
end;

{ MyMatchMask }

class function MyMatchMask.Check(FileName, MaskStr: string): Boolean;
begin
  try
    Result := MatchesMask( FileName, MaskStr );
  except
    Result := False;
  end;
end;

class function MyMatchMask.CheckChild(ChildPath, ParentPath: string): Boolean;
begin
  ParentPath := MyFilePath.getPath( ParentPath );
  Result := Pos( ParentPath, ChildPath ) > 0;
end;

class function MyMatchMask.CheckEqualsOrChild(ChildPath, ParentPath: string): Boolean;
begin
    // 相等的情况
  if ChildPath = ParentPath then
    Result := True
  else
    Result := CheckChild( ChildPath, ParentPath );
end;

{ MyFileInfo }

class function MyFileInfo.getFileIsInUse(FilePath: string): Boolean;
var
  hfileres : HFILE;
begin
  Result :=   false;
  if not FileExists( FilePath ) then
    exit;
  hfileres := createfile( pchar(FilePath), GENERIC_READ, 0, nil, open_existing, file_attribute_normal,   0);
  Result := (hfileres   =   invalid_handle_value);
  if not result then
    closehandle(hfileres);
end;

class function MyFileInfo.getFileLastWriteTime(FilePath: string): TDateTime;
var
  sch: TSearchRec;
  LastWriteTimeSystem: TSystemTime;
begin
  if FindFirst( FilePath, faAnyFile, sch ) = 0 then
  begin
    FileTimeToSystemTime( sch.FindData.ftLastWriteTime, LastWriteTimeSystem );
    LastWriteTimeSystem.wMilliseconds := 0;  // 移除毫秒
    Result := SystemTimeToDateTime(LastWriteTimeSystem);
  end
  else
    Result := Now;
  SysUtils.FindClose(sch);
end;

class function MyFileInfo.getFileSize(FilePath: string): Int64;
var
  sch: TSearchRec;
begin
  if FindFirst( FilePath , faAnyfile , sch ) = 0 then
    Result := sch.Size
  else
    Result := 0;
  SysUtils.FindClose(sch);
end;

class function MyFileInfo.getFileName(FullPath: string): string;
begin
  if ExtractFileName( FullPath ) = '' then
    Result := FullPath
  else
    Result := ExtractFileName( FullPath );
end;

{ MyFilePath }

class function MyFilePath.getChildFolderList(FolderPath: string): TStringList;
var
  sch : TSearchRec;
  SearcFullPath, FileName : string;
begin
  Result := TStringList.Create;

    // 循环寻找 子目录信息
  SearcFullPath := MyFilePath.getPath( FolderPath );
  if FindFirst( SearcFullPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

        // 检查下一层目录
      if DirectoryExists( SearcFullPath + FileName )  then
        Result.Add( FileName );

    until FindNext(sch) <> 0;
  end;

  SysUtils.FindClose(sch);
end;

class function MyFilePath.getDesklopPath: string;
var
  pitem : PITEMIDLIST;
  s: string;
begin
  shGetSpecialFolderLocation(0,CSIDL_DESKTOP,pitem);
  setlength(s,100);
  shGetPathFromIDList(pitem,pchar(s));
  s := copy( s, 1, Pos( #0, s ) - 1 );
  Result := s;
end;

class function MyFilePath.getDownloadPath(Path: string): string;
begin
    // 替换 网上邻居
  Result := StringReplace( Path, '\\\', '\' + Sign_NetworkFolder, [] );
  Result := StringReplace( Result, '\\', Sign_NetworkFolder, [] );

    // 替换 驱动器
  Result := StringReplace( Result, ':', Sign_Driver, [] );
end;

class function MyFilePath.getDriverExist(FullPath: string): Boolean;
begin
  Result := DirectoryExists( ExtractFileDrive( FullPath ) );
end;

class function MyFilePath.getHasChild(FullPath: string): Boolean;
var
  FileName  : string;
  sch : TSearchRec;
begin
  Result := False;
  if not FileExists( FullPath ) then
  begin
      // 循环寻找 目录文件信息
    FullPath := MyFilePath.getPath( FullPath );
    if FindFirst( FullPath + '*', faAnyfile, sch ) = 0 then
    begin
      repeat
        FileName := sch.Name;
        if ( FileName <> '.' ) and ( FileName <> '..') then
        begin
          Result := True;
          Break;
        end;
      until FindNext(sch) <> 0;
    end;
    SysUtils.FindClose(sch);
  end;
end;

class function MyFilePath.getIsDriver(FullPath: string): Boolean;
var
  PStr: PChar;
  DriveArr: array[0..4*26] of Char; {每个驱动器 4 字节, 最多 26 个驱动器}
begin
  GetLogicalDriveStrings(SizeOf(DriveArr), DriveArr); {函数调用就这么简单}

  PStr := DriveArr;                 {因为 PStr 是 #0 结尾的, 所以现在它指向的是前 4 个字节}
  Result := False;
  While True do
  begin
    if FullPath = PStr then
    begin
      Result := True;
      Break;
    end;

    Inc(PStr,StrLen(PStr)+1);       {字符串指针是可以运算的, 这里相当于指针移动 4 个位置, 而指向下一个}
    if(Byte(PStr[0]) = 0) then   {如果下一个的第一个字符就是空, 就是没有了, While 等着 nil 终止呢}
      Break;
  end;
end;

class function MyFilePath.getIsExist(FullPath: string): Boolean;
begin
  if FileExists( FullPath ) then
    Result := True
  else
  if MyNetworkFolderUtil.IsNetworkFolder( FullPath ) then
    Result := MyNetworkFolderUtil.NetworkFolderExist( FullPath )
  else
    Result := DirectoryExists( FullPath );
end;

class function MyFilePath.getIsModify(FullPath: string): Boolean;
var
  FilePath : string;
  h : Integer;
begin
  Result := False;

  FilePath := MyFilePath.getPath( FullPath ) + 'BackupCow_TestModify.cy';
  if not FileExists( FilePath ) then
  begin
    h := FileCreate( FilePath );
    if h = -1 then  // 创建失败
      Exit;
    FileClose( h );
  end;
  Result := SysUtils.DeleteFile( FilePath ); // 返回是否删除
end;

 {
   Load方法的第二个参数还可以传递STGM_WRITE或STGM_READWRITE，表示对快捷方式信息的访问权限
     STGM_READ：只读
     STGM_WRITE：只写
     STGM_READWRITE：读写
   GetPath方法的第三个参数还可以传递SLGP_UNCPRIORITY或SLGP_SHORTPATH，表示返回的目标路径格式
     SLGP_UNCPRIORIT：UNC网络路径
     SLGP_SHORTPATH ：DOS 8.3格式路径
     SLGP_RAWPATH      : 长路径
 }
class function MyFilePath.getLinkPath(LinkFile: string): string;
const
  IID_IPersistFile:TGUID = '{0000010B-0000-0000-C000-000000000046}';
var
  intfLink : IShellLink;
  IntfPersist : IPersistFile;
  pfd : _WIN32_FIND_DATA;
  bSuccess : Boolean;
  szgetpath : array[0..max_path] of char;
begin
  Result := '';
  IntfLink := CreateComObject(CLSID_ShellLink) as IShellLink;
  bSuccess := ( IntfLink <> nil ) and SUCCEEDED(IntfLink.QueryInterface(IID_IPersistFile,IntfPersist))
                and SUCCEEDED(IntfPersist.Load(PChar(WideString(LinkFile)),STGM_READ))
                and SUCCEEDED(intfLink.GetPath(szgetpath,MAX_PATH,pfd,SLGP_RAWPATH));
  if bSuccess then
    Result := szgetpath
  else
    Result:= LinkFile;
end;



class function MyFilePath.getNetworkPcPath: string;
var
  FilePath: array [0..255] of char;
begin
  SHGetSpecialFolderPath(0, @FilePath[0], CSIDL_NETHOOD, True);
  Result := FilePath;
end;

class function MyFilePath.getPath(s: string): string;
begin
  if s = '' then
    Result := ''
  else
  if RightStr( s, 1 ) <> '\' then
    Result := s + '\'
  else
    Result := s;
end;

class function MyFilePath.getPathType(FullPath: string): string;
begin
  if DirectoryExists( FullPath ) then
    Result := PathType_Folder
  else
    Result := PathType_File;
end;

class function MyFilePath.getUploadPath(Path: string): string;
begin
    // 替换 网上邻居
  Result := StringReplace( Path, Sign_NetworkFolder, '\\',  [] );

    // 替换 驱动器
  Result := StringReplace( Result, Sign_Driver, ':', [] );
  if RightStr( Result, 1 ) = ':' then
    Result := Result + '\';
end;

{ MyMacAdress }

Function GetAdaptersInfo(AI : PIPAdapterInfo; Var BufLen : Integer) : Integer;
StdCall; External 'iphlpapi.dll' Name 'GetAdaptersInfo';

Function MACToStr(ByteArr : PByte; Len : Integer) : String;
Begin
Result := '';
   While (Len > 0) do Begin
      Result := Result+IntToHex(ByteArr^,2)+'-';
      ByteArr := Pointer(Integer(ByteArr)+SizeOf(Byte));
      Dec(Len);
    End;
    SetLength(Result,Length(Result)-1); { remove last dash }
End;

Function GetAddrString(Addr : PIPAddrString) : String;
  Begin
    Result := '';
    While (Addr <> nil) do Begin
      Result := Result+'A: '+Addr^.IPAddress+' M: '+Addr^.IPMask+#13;
      Addr := Addr^.Next;
    End;
End;

{ MyComputerName }

class function MyComputerName.get: string;
var
  cnamebuffer: pchar;
  clen: ^dword;
begin
  getmem(cnamebuffer, 255);
  new(clen);
  clen^ := 255;
  getcomputername(cnamebuffer, clen^);
  Result := strpas(cnamebuffer);
  freemem(cnamebuffer, 255);
  dispose(clen);
end;


{ MyParseHost }

class function MyParseHost.CheckIpLan(Ip1, Ip2: string): Boolean;
var
  s1, s2 : string;
begin
  Result := False;
  s1 := MyString.GetBeforeStr( '.', Ip1 );
  s2 := MyString.GetBeforeStr( '.', Ip2 );
  Result := s1 = s2;
end;

class function MyParseHost.getIpStr(var Domain: string): string;
begin
  if IsIpStr( Domain ) then
  begin
    Result := Domain;
    Domain := '';
  end
  else
    Result := '';
end;

class function MyParseHost.HostToIP(Name: AnsiString; var Ip: string): Boolean;
var
  wsdata: TWSAData;
  hostName: array[0..255] of AnsiChar;
  hostEnt: PHostEnt;
  addr: PansiChar;
begin
  Result := False;

  WSAStartup($0101, wsdata);
  try
    gethostname(@hostName, sizeof(hostName));
    StrPCopy(hostName, Name);
    hostEnt := gethostbyname(@hostName);
    if Assigned(hostEnt) and Assigned(hostEnt^.h_addr_list) then
    begin
      addr := pansichar( hostEnt^.h_addr_list^ );
      if Assigned(addr) then
      begin
        IP := Format('%d.%d.%d.%d', [byte(addr[0]),
          byte(addr[1]), byte(addr[2]), byte(addr[3])]);
        Result := True;
      end;
    end;
  except
  end;
  WSACleanup;
end;

class function MyParseHost.IsIpStr(Str: string): Boolean;
var
  I, K, DotCnt: Integer;
  Num: string;
  Arr: array[1..4] of string;
begin
  Result := False;
  DotCnt := 0;
  for I := 1 to Length(Str) do
  begin
    if not (Str[I] in ['0'..'9', '.']) then
      Exit
    else
      if Str[I] = '.' then
        inc(DotCnt);
  end;
  if DotCnt <> 3 then Exit;
  for K := 1 to 3 do
  begin
    I := Pos('.', Str);
    Num := Copy(Str, 1, I - 1);
    Delete(Str, 1, I);
    Arr[K] := Num;
  end;
  Arr[4] := Str;

  try
    DotCnt := 0;
    for I := 1 to 4 do
    begin
      K := StrToInt(Arr[I]);
      if ((K >= 0) and (K <= 255)) then
        Inc(DotCnt);
    end;
    if (DotCnt = 4) then
      Result := True;
  except
  end;
end;

class function MyParseHost.IsPortStr(str: string): Boolean;
var
  Port : Integer;
begin
  Port := StrToIntDef( str, -1 );
  Result := ( Port >= 1 ) and ( Port <= 65535 );
end;

{ MyPercentage }

class function MyPercentage.getCompareStr(Position, FileSize: Int64): string;
begin
  Result := MySize.getFileSizeStr( Position ) + Sign_ComparePercent + MySize.getFileSizeStr( FileSize );
end;

class function MyPercentage.getPercent(Position, FileSize: Int64): Integer;
begin
  if FileSize <= 0 then
  begin
    Result := 100;
    Exit;
  end;

  Result := ( Position * 100 ) div FileSize;
  Result := Min( Result, 100 );
end;

class function MyPercentage.getPercentageStr(Position, FileSize: Int64): string;
begin
  Result := getPercentageStr( getPercent( Position, FileSize ) );
end;

class function MyPercentage.getPercentageStr(Percentage: Integer): string;
begin
  if Percentage < 0 then
    Percentage := 0
  else
  if Percentage > 100 then
    Percentage := 100;

  Result := IntToStr(Percentage) + Sign_Percentage;
end;

class function MyPercentage.getStrToPercentage(s: string): Integer;
begin
  s := Copy(s, 1, Pos(Sign_Percentage, s) - 1);
  Result := StrToIntDef( s, 0 );
end;

{ MyDatetime }

class function MyDatetime.Compare(dt1, dt2: TDateTime): Integer;
begin
  if dt1 > dt2 then
    Result := 1
  else
  if dt1 = dt2 then
    Result := 0
  else
    Result := -1;
end;

class function MyDatetime.Equals(t1, t2: TDateTime): Boolean;
begin
  Result := SecondsBetween( t1, t2 ) < 5;
end;

class function MyDatetime.getAfterStr(t: TDateTime): string;
begin
  Result := getStr( t );
end;

class function MyDatetime.getAgoStr(t: TDateTime): string;
begin
  Result := getStr( t ) + ' ago';
end;

class function MyDatetime.getStr(t: TDateTime): string;
var
  NowTime : TDateTime;
  ShowInt : integer;
  ShowStr : string;
begin
  NowTime := Now;

  ShowInt := DaysBetween( NowTime, t );
  if ShowInt > 0 then
  begin
    ShowInt := Min( ShowInt, 365 );
    ShowStr := Time_Day;
  end
  else
  begin
    ShowInt := HoursBetween( NowTime, t );
    if ShowInt > 0 then
      ShowStr := Time_Hour
    else
    begin
      ShowInt := MinutesBetween( NowTime, t );
      ShowInt := max( 1, ShowInt );
      ShowStr := Time_Min;
    end;
  end;

  Result := IntToStr( ShowInt ) + ShowStr;
end;

{ MySpeed }

class function MySpeed.getSpeedStr(Speed: Integer): string;
begin
  Result := MySize.getFileSizeStr(Speed) + Sign_Speed;
end;

class function MySpeed.getStrToSpeed(s: string): Integer;
begin
  s := Copy(s, 1, Pos(Sign_Speed, s) - 1);
  Result := MySize.getFileSize(s);
end;

class function MyTime.getMaxTime: Integer;
begin
  Result := 86399;
end;

class function MyTime.getMyMinTimeStr(Time: Integer): string;
var
  s, m, h: string;
begin
    // 限定 最大值
  if Time > getMaxTime then
    Time := getMaxTime;

    // 秒
  if Time > 0 then
  begin
    s := IntToStr(Time mod 60);
    if Length(s) < 2 then
      s := '0' + s;
  end
  else
    s := '00';

    // 分
  Time := (Time div 60);
  if Time > 0 then
  begin
    m := IntToStr(Time mod 60);
    if Length(m) < 2 then
      m := '0' + m;
  end
  else
    m := '00';

    // 分秒 显示
  Result := m + ':' + s;
end;


class function MyTime.getMyTimeStr(Time: Integer): string;
var
  s, m, h: string;
begin
    // 限定 最大值
  if Time > getMaxTime then
    Time := getMaxTime;

    // 秒
  if Time > 0 then
  begin
    s := IntToStr(Time mod 60);
    if Length(s) < 2 then
      s := '0' + s;
  end
  else
    s := '00';

    // 分
  Time := (Time div 60);
  if Time > 0 then
  begin
    m := IntToStr(Time mod 60);
    if Length(m) < 2 then
      m := '0' + m;
  end
  else
    m := '00';

    // 时
  Time := (Time div 60);
  if Time > 0 then
  begin
    h := IntToStr(min( 23, Time ));
    if Length(h) < 2 then
      h := '0' + h;
  end
  else
    h := '00';

    // 时分秒 显示
  Result := h + ':' + m + ':' + s;
end;

class procedure MyFileSetTime.SetTime( FileName: string; DateTime: TDateTime);
var
  Handle: THandle;
  FileTime: TFileTime;
  SystemTime: TSystemTime;
  Times: TFileTimes;
begin
  if not FileExists( FileName ) then
    Exit;

  Times := ftLastWrite;

  Handle := CreateFile(PChar(FileName), GENERIC_WRITE, FILE_SHARE_READ, nil,
    OPEN_EXISTING, 0, 0);

  if Handle <> INVALID_HANDLE_VALUE then
  try
    DateTimeToSystemTime(DateTime, SystemTime);

    if Windows.SystemTimeToFileTime(SystemTime, FileTime) then
    begin
      case Times of
        ftLastAccess:
          SetFileTime(Handle, nil, @FileTime, nil);
        ftLastWrite:
          SetFileTime(Handle, nil, nil, @FileTime);
        ftCreation:
          SetFileTime(Handle, @FileTime, nil, nil);
      end;
    end;
  finally
    CloseHandle(Handle);
  end;
end;

class function MyRename.getFileName(FileName: string; i: Integer): string;
var
  FileExt : string;
begin
  FileExt := ExtractFileExt( FileName );
  FileName := Copy( FileName, 1, length( FileName ) - length( FileExt ) );
  Result := FileName + '(' + IntToStr(i) + ')' + FileExt;
end;

class procedure MyRename.RenameExist(FilePath: string);
var
  i : Integer;
  FileName, FileExt : string;
  NewFilePath : string;
begin
  FileExt := ExtractFileExt( FilePath );
  FileName := Copy( FilePath, 1, length( FilePath ) - length( FileExt ) );

  i := 1;
  while true do
  begin
    NewFilePath := FileName + '(' + IntToStr(i) + ')' + FileExt;

    if FileExists( NewFilePath ) then
    begin
      Inc( i );
      Continue;
    end;

    RenameFile( FilePath, NewFilePath );
    Break;
  end;
end;

{ MyDriver }

class function MyDriver.IsDriver(FullPath: string): Boolean;
var
  PStr: PChar;
  DriveArr: array[0..4*26] of Char; {每个驱动器 4 字节, 最多 26 个驱动器}
begin
  GetLogicalDriveStrings(SizeOf(DriveArr), DriveArr); {函数调用就这么简单}

  PStr := DriveArr;                 {因为 PStr 是 #0 结尾的, 所以现在它指向的是前 4 个字节}
  Result := False;
  While True do
  begin
    if FullPath = PStr then
    begin
      Result := True;
      Break;
    end;

    Inc(PStr,StrLen(PStr)+1);       {字符串指针是可以运算的, 这里相当于指针移动 4 个位置, 而指向下一个}
    if(Byte(PStr[0]) = 0) then   {如果下一个的第一个字符就是空, 就是没有了, While 等着 nil 终止呢}
      Break;
  end;
end;

{ MyIpList }

class function MyIpList.get: TStringList;
type
  TaPInAddr = array[0..255] of PInAddr; //Use Winsock.pas
  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of char;
  i, j: integer;
  GInitData: TWSADATA;
  TempStr : string;
begin
  Result := TStringList.Create;

  wsastartup($101, GInitData);
  GetHostName(@Buffer, SizeOf(Buffer));
  phe := GetHostByName(@buffer);

  if not assigned(phe) then
    exit;
  pptr := PaPInAddr(Phe^.h_addr_list);
  i := 0;

  while pptr^[I] <> nil do
  begin
    Result.Add(StrPas(inet_ntoa(pptr^[I]^)));
    inc(i);
  end;
  wsacleanup;

    // 排序
  Result.Sort;

    // 搜索 192.168 排第一
  for i := 1 to Result.Count - 1 do
    if Pos( '192.168.', Result[i] ) > 0 then
    begin
      TempStr := Result[i];
      Result.Delete( i );
      Result.Insert( 0, TempStr );
      Break;
    end;

    // 搜索 192.168.1 排第一
  for i := 1 to Result.Count - 1 do
    if Pos( '192.168.1', Result[i] ) > 0 then
    begin
      TempStr := Result[i];
      Result.Delete( i );
      Result.Insert( 0, TempStr );
      Break;
    end;
end;


{ MyIp }

class function MyIp.get: string;
var
  IpList : TStringList;
begin
  IpList := MyIpList.get;
  Result := IpList[0];
  IpList.Free;
end;

{ MyHardDisk }

class function MyHardDisk.getAllHardDisk: TStringList;
var
  Drive: Char;
  DriveLetter: string[4];
begin
  Result := TStringList.Create;

  for Drive := 'A' to 'Z' do
  begin
    DriveLetter := Drive + ':\';
    if GetDriveType(PChar(Drive + ':\')) = DRIVE_FIXED then
      Result.Add(DriveLetter);
  end;
end;

class function MyHardDisk.getAvailablePath(FilePath: string): string;
var
  Driver, LocalDriver, FolderPath : string;
begin
  Driver := ExtractFileDrive( FilePath );
  Driver := MyFilePath.getPath( Driver );

    // 磁盘存在
  if DirectoryExists( Driver ) and
     ( GetDriveType(PChar(Driver)) = DRIVE_FIXED )
  then
  begin
    Result := FilePath;
    Exit;
  end;

    // 返回 本地磁盘 + 原来目录
  LocalDriver := getBiggestHardDIsk;
  FolderPath := MyString.CutStartStr( Driver, FilePath );
  Result := LocalDriver + FolderPath;
end;

class function MyHardDisk.CheckHardDisk(BackupFoldePath: string;
  FileSize: int64): Boolean;
begin
  Result := (getHardDiskFreeSize(BackupFoldePath) - FileSize) > 0
end;

class function MyHardDisk.getHardDiskAllSize(Path: string): Int64;
var
  d: string;
  i: Integer;
begin
  d := ExtractFileDrive(Path);
  i := CompareStr(d, 'A:') + 1;
  Result := DiskSize(i);
end;

class function MyHardDisk.getHardDiskFreeSize(BackupFolderPath: string): Int64;
var
  d: string;
  i: Integer;
begin
    // 网上邻居的情况
  if MyNetworkFolderUtil.IsNetworkFolder( BackupFolderPath ) then
  begin
    Result := getNetworkFolderFree( BackupFolderPath );
    Exit;
  end;

    // 普通路径的情况
  d := ExtractFileDrive(BackupFolderPath);
  i := CompareStr(d, 'A:') + 1;
  if getDriverExist( d + '\' ) then
    Result := DiskFree(i)
  else
    Result := 0;
end;

class function MyHardDisk.getNetworkFolderFree(Path: string): Int64;
var
  FreeSpace, TotalSpace : Int64;
begin
  if not GetDiskFreeSpaceEx( PChar( Path ), FreeSpace, TotalSpace, nil ) then
    Result := -1
  else
    Result := FreeSpace;
end;

class function MyHardDisk.getBiggestHardDIsk: string;
var
  i: Integer;
  AllHardDisk: TStringList;
  MaxHardSize, SelectHardSize: Int64;
  MaxNum: Integer;
begin
  AllHardDisk := getAllHardDisk;

  MaxHardSize := 0;
  MaxNum := 0;
  for i := 0 to AllHardDisk.Count - 1 do
  begin
    SelectHardSize := getHardDiskFreeSize(AllHardDisk[i]);
    if SelectHardSize > MaxHardSize then
    begin
      MaxHardSize := SelectHardSize;
      MaxNum := i;
    end;
  end;

  Result := AllHardDisk[MaxNum];
  AllHardDisk.Free;
end;


class function MyHardDisk.getDriverExist(Driver: string): Boolean;
var
  NotUsed, VolFlags: DWORD;
  Buf: array[0..MAX_PATH] of Char;
begin
  Result := GetVolumeInformation(PChar(Driver), Buf, sizeof(Buf), nil, NotUsed, VolFlags, nil, 0);
end;

{ MyString }

class function MyString.CutLastFolder(FilePath: string): string;
var
  LastFolderStr : string;
begin
  LastFolderStr := GetLastFolder( FilePath );
  LastFolderStr := '\' + LastFolderStr;

  Result := CutStopStr( LastFolderStr, FilePath );
  if RightStr( Result, 1 ) = ':'  then // 驱动器
    Result := Result + '\';
end;

class function MyString.CutRootFolder(FilePath: string): string;
var
  RootFolderStr : string;
begin
  RootFolderStr := GetRootFolder( FilePath );
  RootFolderStr := MyFilePath.getPath( RootFolderStr );

  Result := CutStartStr( RootFolderStr, FilePath );
end;

class function MyString.CutStartStr(CutStr, SourceStr: string): string;
var
  CutStrLen, SourceStrLen : Integer;
begin
  CutStrLen := Length( CutStr );
  SourceStrLen := Length( SourceStr );

  Result := Copy( SourceStr, CutStrLen + 1, SourceStrLen - CutStrLen );
end;

class function MyString.CutStopStr(CutStr, SourceStr: string): string;
var
  CutStrLen, SourceStrLen : Integer;
begin
  CutStrLen := Length( CutStr );
  SourceStrLen := Length( SourceStr );

  Result := Copy( SourceStr, 1, SourceStrLen - CutStrLen );
end;

class function MyString.GetAfterStr(SplitStr, SourceStr: string): string;
var
  SplitStrLen, SourceStrLen : Integer;
  SplitStrPostion, StartPosition : Integer;
  StrLen : Integer;
begin
  SplitStrLen := Length( SplitStr );
  SourceStrLen := Length( SourceStr );
  SplitStrPostion := GetLastPos( SplitStr, SourceStr );

  StartPosition := SplitStrPostion + SplitStrLen;
  StrLen := SourceStrLen - StartPosition + 1;

  if SplitStrPostion > 0 then
    Result := Copy( SourceStr, StartPosition, StrLen )
  else
    Result := '';
end;

class function MyString.GetBeforeStr(SplitStr, SourceStr: string): string;
var
  SplitStrPostion : Integer;
begin
  SplitStrPostion := Pos( SplitStr, SourceStr );

  if SplitStrPostion > 0 then
    Result := Copy( SourceStr, 1, SplitStrPostion - 1 )
  else
    Result := '';
end;

class function MyString.GetLastFolder(FilePath: string): string;
begin
    // 驱动器
  if RightStr( FilePath, 1 ) = '\' then
  begin
    FilePath := Copy( FilePath, 1, length( FilePath ) - 1 );
    Result := GetLastFolder( FilePath );
    if RightStr( Result, 1 ) = ':' then
      Result := Result + '\';
  end
  else
    Result := GetAfterStr( '\', FilePath );
end;

class function MyString.GetLastPos(SubStr, SourceStr: string): Integer;
var
  SubLen, SourceLen : Integer;
  StartPos, CutPos : Integer;
begin
  SubLen := Length( SubStr );
  CutPos := 0;

  Result := pos( SubStr, SourceStr );
  while Result > 0 do
  begin
    StartPos := Result + SubLen;
    CutPos := CutPos + StartPos - 1;
    SourceLen := length( SourceStr );
    SourceStr := Copy( SourceStr, StartPos, SourceLen - StartPos + 1 );
    Result := pos( SubStr, SourceStr );
  end;

  Result := Result + CutPos;
end;

class function MyString.GetRootFolder(FilePath: string): string;
var
  DriverPath : string;
  DriverLen : Integer;
begin
  if LeftStr( FilePath, 2 ) = '\\'  then // 网上邻居
  begin
    FilePath := Copy( FilePath, 3, length( FilePath ) - 2 );
    Result := GetBeforeStr( '\', FilePath );
    if Result <> '' then
      Result := '\\' + Result;
  end
  else
  if Copy( FilePath, 2, 2 ) = ':\' then // 驱动器
  begin
    if Length( FilePath ) > 3 then
      Result := Copy( FilePath, 1, 3 )
    else
      Result := ''
  end
  else
    Result := GetBeforeStr( '\', FilePath );
end;

{ MyExplore }

class procedure MyExplore.OperFolder(FilePath: string);
begin
  try
    if FileExists( FilePath ) then
      ShellExecute(0, 'open', 'explorer.exe', PChar('/n,/select,' + FilePath ), nil, SW_SHOW )
    else
    if DirectoryExists( FilePath ) then
      ShellExecute(0, 'open', 'explorer.exe', PChar('/n,' + FilePath ), nil, SW_SHOW )
  except
    DebugLog( 'Explorer Api Error' );
  end;
end;

{ MySelectFolderDialog }

var
  IniFolderPath : string = '';
function BrowseCallbackProc(hwnd: HWND;uMsg: UINT;lParam: Cardinal;lpData: Cardinal): integer; stdcall;
begin
  if uMsg=BFFM_INITIALIZED then
    result :=SendMessage(Hwnd,BFFM_SETSELECTION,Ord(TRUE),Longint(PChar(IniFolderPath)))
  else
  result :=1
end;

function SelDir(const Caption: string; const Root: WideString; out Directory: string; h : Integer): Boolean;
var
  WindowList: Pointer;
  BrowseInfo: TBrowseInfo;
  Buffer: PChar;
  RootItemIDList, ItemIDList: PItemIDList;
  ShellMalloc: IMalloc;
  IDesktopFolder: IShellFolder;
  Eaten, Flags: LongWord;
begin
  Result := False;
  Directory := '';
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  if (ShGetMalloc(ShellMalloc) = S_OK) and (ShellMalloc <> nil) then
  begin
    Buffer := ShellMalloc.Alloc(MAX_PATH);
    try
      RootItemIDList := nil;
      if Root <> '' then
      begin
        SHGetDesktopFolder(IDesktopFolder);
        IDesktopFolder.ParseDisplayName(h, nil, POleStr(Root), Eaten, RootItemIDList, Flags);
      end;
      with BrowseInfo do
      begin
        hwndOwner := h;
        pidlRoot := RootItemIDList;
        pszDisplayName := Buffer;
        lpszTitle := PChar(Caption);
        ulFlags := BIF_RETURNONLYFSDIRS + BIF_NEWDIALOGSTYLE;
        lpfn :=@BrowseCallbackProc;
        lParam :=BFFM_INITIALIZED;
      end;
      WindowList := DisableTaskWindows(0);
      try
        ItemIDList := ShBrowseForFolder(BrowseInfo);
      finally
        EnableTaskWindows(WindowList);
      end;
      Result := ItemIDList <> nil;
      if Result then
      begin
        ShGetPathFromIDList(ItemIDList, Buffer);
        ShellMalloc.Free(ItemIDList);
        Directory := Buffer;
      end;
    finally
      ShellMalloc.Free(Buffer);
    end;
  end;
end;

class function MySelectFolderDialog.Select(ShowStr, IniPath: string;
  var OutPath: string): Boolean;
begin
  Result := Select( ShowStr, IniPath, OutPath, Application.Handle );
end;

class function MySelectFolderDialog.Select(ShowStr, IniPath: string;
  var OutPath: string; h: Integer): Boolean;
begin
  if MyNetworkFolderUtil.IsNetworkFolder( IniPath ) then
    IniPath := '';

  IniFolderPath := IniPath;
  Result := SelDir( ShowStr, '', OutPath, h );
end;

class function MySelectFolderDialog.SelectNetPc(ShowStr: string;
  var OutPath: string): Boolean;
begin
  IniFolderPath := '';
  Result := SelDir( ShowStr, MyFilePath.getNetworkPcPath, OutPath, Application.Handle );
end;

class function MySelectFolderDialog.SelectNormal(ShowStr, IniPath: string;
  var OutPath: string): Boolean;
begin
    // 网上邻居, 则清空
  if MyNetworkFolderUtil.IsNetworkFolder( OutPath ) then
    OutPath := '';

  Result := SelectDirectory( ShowStr, IniPath, OutPath );
end;

{ MyIniFile }

class function MyIniFile.getIniFilePath: string;
begin
  Result := MyAppDataPath.get + 'BackupCowConfig.dat';
end;

{ MyEncrypt }

class function MyEncrypt.DecodeStr(s: string): string;
begin
  Result := '';

  if s = '' then
    Exit;

  try
    Result := DecryStrHex( s, EncodeKey_Config );
  except
    Result := '';
  end;
end;


class function MyEncrypt.EncodeMD5String(s: string): string;
begin
  Result := '';

  if s = '' then
    Exit;

  Result := MD5Print( MD5String( s ) );
end;

class function MyEncrypt.EncodeStr(s: string): string;
begin
  Result := '';

  if s = '' then
    Exit;

  Result := EncryStrHex( s, EncodeKey_Config );
end;

{ MyMessageBox }

class function MyMessageBox.ShowConfirm(ShowStr: string): Boolean;
begin
  Result := MessageDlg( ShowStr, mtConfirmation, [mbYes, mbNo], 0 ) = mrYes;
end;

class procedure MyMessageBox.ShowError(ShowStr: string);
begin
  ShowError( MainFormHandle, ShowStr );
end;

class procedure MyMessageBox.ShowError(Handle: Integer; ShowStr: string);
begin
  MessageBox( Handle, PChar( ShowStr ), 'Error', MB_ICONERROR );
end;

class procedure MyMessageBox.ShowErrorTop(ShowStr: string);
begin
  MessageBox( MainFormHandle, PChar( ShowStr ), 'Error', MB_ICONERROR or MB_TOPMOST );
end;

class procedure MyMessageBox.ShowOk(Handle: Integer; ShowStr: string);
begin
  MessageBox( Handle, PChar( ShowStr ), 'OK', MB_ICONINFORMATION );
end;

class procedure MyMessageBox.ShowOk(ShowStr: string);
begin
  ShowOk( MainFormHandle, ShowStr );
end;

class procedure MyMessageBox.ShowWarnning(Handle: Integer; ShowStr: string);
begin
  MessageBox( Handle, PChar( ShowStr ), 'Warning', MB_ICONWARNING );
end;

class procedure MyMessageBox.ShowWarnning(ShowStr: string);
begin
  ShowWarnning( MainFormHandle, ShowStr );
end;


{ MyMessageHint }

class procedure MyMessageHint.ShowError(Handle: Integer; HintStr: string);
begin
  MyMessageBox.ShowError( Handle, HintStr );
//  ShowHint( Handle, HintStr, 'Error', 3 );
end;

class procedure MyMessageHint.ShowHint(h: HWND; HintStr: string;
  Title: AnsiString; IconType, ShowTime: Integer);
var
 r : TRect;                       //是一个记录（Record），保存了矩形的（左上角右下角两个点）4个坐标或2个点的值。
 hTooltip: Cardinal;    //Cardinal是无符号32位整数 ，取值0到4294967295范围。
 ti: TToolInfo;
begin
 hToolTip := CreateWindow('Tooltips_Class32',nil,$40,0,0,0,0,0,0,hInstance,nil);
 if hToolTip <> 0 then
 begin
   SetWindowPos(hToolTip, HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);  //让气泡在最前面
   ti.cbSize := SizeOf(TToolInfo);
   ti.uFlags := TTF_IDISHWND or TTF_TRACK;
   ti.hInst := hInstance;
   ti.lpszText :=pchar(HintStr);
   SendMessage(hToolTip, TTM_ADDTOOL, 0, Integer(@ti));
   if (IconType > 3) or (IconType < 0) then IconType:=0;
   SendMessage(hToolTip,WM_USER + 32,IconType,Integer(Title));
   GetWindowRect(H,R);             //获取指定控件的坐标,R.Right 、R.Left、R.Bottom、R.Top
   SendMessage(hToolTip,TTM_TRACKPOSITION, 0, MAKELONG((r.Right - r.Left) div 2 + r.Left, (r.Bottom - r.Top) div 2 + r.Top));      // 定义气泡位置
   SendMessage(hToolTip, TTM_TRACKACTIVATE, Integer(True), Integer(@ti));
   Sleep(ShowTime);
   DestroyWindow(hToolTip);
 end;
end;

class procedure MyMessageHint.ShowHint(h: HWND; HintStr: string;
  Title: AnsiString; IconType: Integer);
begin
  ShowHint( h, HintStr, Title, IconType, 2000 );
end;

class procedure MyMessageHint.ShowOk(Handle: Integer; HintStr: string);
begin
  MyMessageBox.ShowOk( Handle, HintStr );
//  ShowHint( Handle, HintStr, 'Infomation', 1 );
end;

class procedure MyMessageHint.ShowWarnning(Handle: Integer; HintStr: string);
begin
  MyMessageBox.ShowWarnning( Handle, HintStr );
//  ShowHint( Handle, HintStr, 'Warnning', 2 );
end;

{ MySplitStr }

class function MySplitStr.GetDriveString(DriveString: string;
  Index: Integer): string;
var
  Head, Tail: PChar;
begin
  Head := PChar(DriveString);
  Result := '';
  repeat
    Tail := Head;
    while Tail^ <> #0 do
      Inc(Tail);
    if Index = 0 then
    begin
      SetString(Result, Head, Tail - Head);
      Break;
    end;
    Dec(Index);
    Head := Tail + 1;
  until Head^ = #0;
end;

class function MySplitStr.getList(s, SplitStr: string): TStringList;
var
  FindStr : string;
  BeforePos, AfterPos : Integer;
  LenSplit : Integer;
begin
  s := SplitStr + s + SplitStr;
  LenSplit := Length( SplitStr );

  Result := TStringList.Create;

  while s <> SplitStr do
  begin
    BeforePos := Pos( SplitStr, s );
    s := Copy( s, LenSplit + 1, Length( s ) - LenSplit );
    AfterPos := Pos( SplitStr, s );
    FindStr := Copy( s, 1, AfterPos - 1 );
    if FindStr <> '' then
      Result.Add( FindStr );
    s := Copy( s, Length( FindStr ) + 1, Length( s ) - Length( FindStr ) );
  end;
end;


{ MyAppRun }

class function MyAppRun.getAppCount: Integer;
var
  AppName : string;
  ProcessName : string; //进程名
  ContinueLoop:BOOL;
  FSnapshotHandle:THandle; //进程快照句柄
  FProcessEntry32:TProcessEntry32; //进程入口的结构体信息
begin
  AppName := ExtractFileName( Application.ExeName );

  FSnapshotHandle:=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0); //创建一个进程快照
  FProcessEntry32.dwSize:=Sizeof(FProcessEntry32);
  ContinueLoop:=Process32First(FSnapshotHandle,FProcessEntry32); //得到系统中第一个进程

  //循环例举
  Result := 0;
  while ContinueLoop  do
  begin
    ProcessName := FProcessEntry32.szExeFile;
    if ProcessName = AppName then
      inc( Result );
    ContinueLoop:=Process32Next(FSnapshotHandle,FProcessEntry32);
  end;
end;


{ MyInternetExplorer }

class procedure MyInternetExplorer.OpenWeb(Url: string);
begin
  ShellExecute(0, 'open', pchar( Url ), '', '', SW_Show);
end;

{ MyHideFile }

class procedure MyHideFile.Hide(FilePath: string);
var
  FileAttr : Integer;
begin
    // 文件不存在
  if not FileExists( FilePath ) then
    Exit;

        // 隐藏文件
  FileAttr := GetFileAttributes( PChar( FilePath ) );
  FileAttr := FileAttr or faHidden;
  SetFileAttributes( PChar( FilePath ), FileAttr );
end;

{ MyAppDataPath }

class function MyAppDataPath.get: string;
var
  FilePath: array [0..255] of char;
begin
  SHGetSpecialFolderPath(0, @FilePath[0], CSIDL_COMMON_APPDATA, True);
  Result := FilePath;
  Result := Result + '\' + AppData_Name + '\';

  if not DirectoryExists( Result ) then
    ForceDirectories( Result );
end;


{ MyFileDelete }

class function MyFolderDelete.DeleteDir(sDirectory: string): Boolean;
//删除目录和目录下得所有文件和文件夹
var
  sr: TSearchRec;
  sPath,sFile: String;
begin
  Result := False;

    // 目录不存在
  if not DirectoryExists( sDirectory ) then
    Exit;

  //检查目录名后面是否有 '\'
  sPath := MyFilePath.getPath( sDirectory );

  //------------------------------------------------------------------
  if FindFirst(sPath+'*.*',faAnyFile, sr) = 0 then
  begin
    repeat
      sFile:=Trim(sr.Name);
      if sFile='.' then Continue;
      if sFile='..' then Continue;

      sFile:=sPath+sr.Name;
      if (sr.Attr and faDirectory)<>0 then
        DeleteDir( sFile )
      else
      if (sr.Attr and faAnyFile) = sr.Attr then
        SysUtils.DeleteFile( sFile ); //删除文件
    until FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
  end;
  Result := RemoveDir(sPath);
  //------------------------------------------------------------------
end;

class function MyFolderDelete.FileDelete(FilePath: string): Boolean;
var
  ParentPath : string;
begin
  Result := False;

    // 文件不存在
  if not FileExists( FilePath ) then
    Exit;

    // 删除 文件
  Result := SysUtils.DeleteFile( FilePath );
  
    // 父目录为空 则 删除父目录
  RemoveParentFolder( FilePath );
end;

class function MyFolderDelete.IsExistChild(FolderPath : string): Boolean;
var
  sch : TSearchRec;
  FileName : string;
begin
  Result := False;
  
    // 循环寻找 目录文件信息
  FolderPath := MyFilePath.getPath( FolderPath );
  if FindFirst( FolderPath + '*', faAnyfile, sch ) = 0 then
  begin
    repeat
      FileName := sch.Name;

      if ( FileName = '.' ) or ( FileName = '..') then
        Continue;

      Result := True;
      Break;

    until FindNext(sch) <> 0;
  end;
  SysUtils.FindClose(sch);
end;

class procedure MyFolderDelete.RemoveParentFolder(FilePathPath: string);
var
  ParentFolderPath : string;
begin
  ParentFolderPath := ExtractFileDir( FilePathPath );

    // 父目录为空 则 删除父目录
  if not IsExistChild( ParentFolderPath ) then
    if RemoveDir( ParentFolderPath ) then
      RemoveParentFolder( ParentFolderPath );
end;

{ MyUpnpUtil }

class function MyUpnpUtil.getUpnpPort(LanIp: string): string;
var
  SplitList : TStringList;
  s : string;
begin

  SplitList := TStringList.Create;
  SplitList.Delimiter := '.';
  SplitList.DelimitedText := LanIp;

  if SplitList.Count >= 4 then
    Result := IntToStr( UpnpPort_Start + StrToInt( SplitList[3] ) );

  SplitList.Free;
end;


{ MyNetworkFolderUtil }

class function MyNetworkFolderUtil.IsNetworkFolder(Path: string): Boolean;
begin
  Result := LeftStr( Path, 2 ) = '\\';
end;

class function MyNetworkFolderUtil.NetworkFolderExist(Path: string): Boolean;
var
  FolderPath : string;
  sc : TSearchRec;
begin
  FolderPath := MyFilePath.getPath( Path ) + '*.*';
  Result := FindFirst( FolderPath, faAnyFile, sc ) = 0;
  SysUtils.FindClose( sc );
end;

{ MyNetworkConnUtil }

class function MyNetworkConnUtil.getExistLan: Boolean;
var
  Types : integer;
begin
  Types := INTERNET_CONNECTION_LAN;
  Result := internetGetConnectedState( @types, 0 );
end;

{ MyCreateFolder }

class function MyCreateFolder.IsCreate( FilePath : string ): Boolean;
begin
  try
    Result := ForceDirectories( ExtractFilePath( FilePath ) );
  except
    Result := False;
  end;
end;

{ MyMD5Util }

class function MyMD5Util.getBuffer(const Buffer; Count: Longword): string;
begin
  Result := MD5Print( MD5Buffer( Buffer, Count ) );
end;

{ MyCpu }

const
  ID_BIT = $200000; // EFLAGS ID bit
type
  TCPUID = array[1..4] of Longint;
  TVendor = array [0..11] of char;

function IsCPUID_Available : Boolean; register;
asm
  PUSHFD {direct access to flags no possible, only via stack}
  POP EAX {flags to EAX}
  MOV EDX,EAX {save current flags}
  XOR EAX,ID_BIT {not ID bit}
  PUSH EAX {onto stack}
  POPFD {from stack to flags, with not ID bit}
  PUSHFD {back to stack}
  POP EAX {get back to EAX}
  XOR EAX,EDX {check if ID bit affected}
  JZ @exit {no, CPUID not availavle}
  MOV AL,True {Result=True}
  @exit:
end;

function GetCPUID : TCPUID; assembler; register;
asm
  PUSH EBX {Save affected register}
  PUSH EDI
  MOV EDI,EAX {@Resukt}
  MOV EAX,1
  DW $A20F {CPUID Command}
  STOSD {CPUID[1]}
  MOV EAX,EBX
  STOSD {CPUID[2]}
  MOV EAX,ECX
  STOSD {CPUID[3]}
  MOV EAX,EDX
  STOSD {CPUID[4]}
  POP EDI {Restore registers}
  POP EBX
end;

function GetCPUVendor : TVendor; assembler; register;
asm
  PUSH EBX {Save affected register}
  PUSH EDI
  MOV EDI,EAX {@Result (TVendor)}
  MOV EAX,0
  DW $A20F {CPUID Command}
  MOV EAX,EBX
  XCHG EBX,ECX {save ECX result}
  MOV ECX,4
  @1:
  STOSB
  SHR EAX,8
  LOOP @1
  MOV EAX,EDX
  MOV ECX,4
  @2:
  STOSB
  SHR EAX,8
  LOOP @2
  MOV EAX,EBX
  MOV ECX,4
  @3:
  STOSB
  SHR EAX,8
  LOOP @3
  POP EDI {Restore registers}
  POP EBX
end;

class function MyCpuID.get: string;
var
  CPUID : TCPUID;
  i : Integer;
begin
  Result := '';
  try
    for i := 1 to 4 do
      CPUID[i] := -1;

    CPUID := GetCPUID;

    for i := 1 to 4 do
      Result := Result + IntToHex( CPUID[i],8 );
  except
  end;
end;

{ MyHardCode }

class function MyMacAddress.Equals(OldHardCode: string): Boolean;
var
  NewHardCode : string;
  OldHardCodeList, NewHardCodeList : TStringList;
  MaxList, MinList: TStringList;
  i : Integer;
begin
    // 读取这次运行程序的网卡地址
  NewHardCode := getStr;

    // 新旧网卡地址对比
  OldHardCodeList := MySplitStr.getList( OldHardCode, Split_MacAddress );
  NewHardCodeList := MySplitStr.getList( NewHardCode, Split_MacAddress );

    // 网卡数 小的与大的比较
  if OldHardCodeList.Count > NewHardCodeList.Count then
  begin
    MaxList := OldHardCodeList;
    MinList := NewHardCodeList;
  end
  else
  begin
    MaxList := NewHardCodeList;
    MinList := OldHardCodeList;
  end;

    // 有一个 不相同则返回 False
  Result := True;
  for i := 0 to MinList.Count - 1 do
    if MaxList.IndexOf( MinList[i] ) < 0 then
    begin
      Result := False;
      Break;
    end;

  NewHardCodeList.Free;
  OldHardCodeList.Free;
end;


class function MyMacAddress.getFirstStr: string;
var
  AI,Work : PIPAdapterInfo;
  Size    : Integer;
  Res     : Integer;
  MacAddress : string;
begin
  Size := 5120;
  GetMem( AI, Size );
  work := ai;
  Res := GetAdaptersInfo( AI, Size );
  If ( Res <> ERROR_SUCCESS ) Then
    SetLastError( Res );

  //网卡地址：
  MacAddress := MACToStr( @Work^.Address, Work^.AddressLength );
  MacAddress := StringReplace( MacAddress, '-', '', [rfReplaceAll] );
  Result := MacAddress;

  FreeMem(AI,Size);
end;

var
  MacAdress_Local : string = '';
class function MyMacAddress.getStr: string;
var
  MacAddressList : TStringList;
  i : Integer;
begin
    // 已读取
  if MacAdress_Local <> '' then
  begin
    Result := MacAdress_Local;
    Exit;
  end;

    // 读取 所有网卡
  Result := '';
  MacAddressList := getStrList;
  for i := 0 to MacAddressList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + Split_MacAddress;
    Result := Result + MacAddressList[i];
  end;
  MacAddressList.Free;

    // 记录，下次不用再读
  MacAdress_Local := Result;
end;

class function MyMacAddress.getStrList: TStringList;
var
  AI,Work : PIPAdapterInfo;
  Size    : Integer;
  Res     : Integer;
  MacAddress : string;
begin
  Result := TStringList.Create;

  Size := 5120;
  GetMem( AI, Size );
  work := ai;
  Res := GetAdaptersInfo( AI, Size );
  If ( Res <> ERROR_SUCCESS ) Then
    SetLastError( Res );

  //网卡地址：
  repeat
    MacAddress := MACToStr( @Work^.Address, Work^.AddressLength );
    MacAddress := StringReplace( MacAddress, '-', '', [rfReplaceAll] );
    Result.Add( MacAddress );
    work := work^.Next;
  until (work=nil);

  FreeMem(AI,Size);
end;

{ MyComputerID }

var
  ComputerID_Local : string = '';
class function MyComputerID.get: string;
begin
    // 已读过，不在读
  if ComputerID_Local <> '' then
  begin
    Result := ComputerID_Local;
    Exit;
  end;

    // 读取 PcID
  Result := Read;

    // 读取 成功
  if Result <> '' then
    Exit;

    // 新建一个 PcID
  Result := getNewPcID;

    // 保存 PcID
  Save( Result );

    // 保存, 下次不再读
  ComputerID_Local := Result;
end;

class function MyComputerID.getNewPcID: string;
var
  PcID, s : string;
  i : Integer;
  n : Integer;
  c : Char;
begin
    // 之前已使用过
  if not Register_IsFirst then
  begin
    Result := MyMacAddress.getFirstStr;
    Exit;
  end;

  PcID := '';
  for i := 1 to 8 do
  begin
    Randomize;
    n := Random( 36 );
    if n < 10 then
      s := IntToStr( n )
    else
    begin
      n := n - 10 + 65;
      c := Char(n);
      s := c;
    end;
    PcID := PcID + s;
  end;
  Result := PcID;
end;

class function MyComputerID.Read: string;
var
  IniFile : TIniFile;
  EncryptPcID : string;
begin
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  EncryptPcID := IniFile.ReadString( Ini_BackupCow, Ini_ComputerID, '' );
  IniFile.Free;

  Result := MyEncrypt.DecodeStr( EncryptPcID );
end;

class procedure MyComputerID.Save(PcID: string);
var
  EncryptPcID : string;
  IniFile : TIniFile;
begin
  EncryptPcID := MyEncrypt.EncodeStr( PcID );
  IniFile := TIniFile.Create( MyIniFile.getIniFilePath );
  IniFile.WriteString( Ini_BackupCow, Ini_ComputerID, EncryptPcID );
  IniFile.Free;
end;

{ MyCount }

class function MyCount.getCountInt(CountStr: string): Integer;
begin
  Result := StrToIntDef( StringReplace( CountStr, ',', '', [rfReplaceAll] ), 0 );
end;

class function MyCount.getCountStr(Count: Integer): string;
var
  CountStr : string;
  i, j : Integer;
begin
  Result := '';

  CountStr := IntToStr( Count );
  j := 0;
  for i := Length( CountStr ) downto 1 do
  begin
    Result := CountStr[i] + Result;
    inc(j);
    if ( j = 3 ) and ( i <> 1 ) then
    begin
      Result := ',' + Result;
      j := 0;
    end;
  end;
end;

{ MyStringList }

class function MyStringList.getString(s: string): TStringList;
begin
  Result := TStringList.Create;
  Result.Add( s );
end;

class function MyStringList.getStrings(ss: TStrings): TStringList;
var
  i : Integer;
begin
  Result := TStringList.Create;
  for i := 0 to ss.Count - 1 do
    Result.Add( ss[i] );
end;

{ TimeTypeUtil }

class procedure TimeTypeUtil.FindTimeInfo(Mins: Integer; var TimeType,
  TimeInt: Integer);
var
  BaseInt : Integer;
begin
    // 距离上一次同步的分钟数
  if Mins >= TimeTypeInt_Month then
  begin
    TimeType := TimeType_Month;
    BaseInt := TimeTypeInt_Month;
  end
  else
  if Mins >= TimeTypeInt_Week then
  begin
    TimeType := TimeType_Week;
    BaseInt := TimeTypeInt_Week;
  end
  else
  if Mins >= TimeTypeInt_Day then
  begin
    TimeType := TimeType_Day;
    BaseInt := TimeTypeInt_Day;
  end
  else
  if Mins >= TimeTypeInt_Hourse then
  begin
    TimeType := TimeType_Hourse;
    BaseInt := TimeTypeInt_Hourse;
  end
  else
  begin
    TimeType := TimeType_Minutes;
    BaseInt := TimeTypeInt_Minutes;
  end;
  TimeInt := Mins div BaseInt;
end;

class function TimeTypeUtil.getMins(TimeType, TimeInt: Integer): Integer;
var
  BaseInt : Integer;
begin
  if TimeType = TimeType_Minutes then
    BaseInt := TimeTypeInt_Minutes
  else
  if TimeType = TimeType_Hourse then
    BaseInt := TimeTypeInt_Hourse
  else
  if TimeType = TimeType_Day then
    BaseInt := TimeTypeInt_Day
  else
  if TimeType = TimeType_Week then
    BaseInt := TimeTypeInt_Week
  else
  if TimeType = TimeType_Month then
    BaseInt := TimeTypeInt_Month
  else
    BaseInt := TimeTypeInt_Minutes;

  Result := BaseInt * TimeInt;
end;

class function TimeTypeUtil.getMinShowStr(Mins: Integer): string;
var
  BaseInt, LeftInt : Integer;
  RightStr : string;
begin
    // 距离上一次同步的分钟数
  if Mins >= TimeTypeInt_Month then
  begin
    BaseInt := TimeTypeInt_Month;
    RightStr := ShowTime_Months;
  end
  else
  if Mins >= TimeTypeInt_Week then
  begin
    BaseInt := TimeTypeInt_Week;
    RightStr := ShowTime_Weeks;
  end
  else
  if Mins >= TimeTypeInt_Day then
  begin
    BaseInt := TimeTypeInt_Day;
    RightStr := ShowTime_Days;
  end
  else
  if Mins >= TimeTypeInt_Hourse then
  begin
    BaseInt := TimeTypeInt_Hourse;
    RightStr := ShowTime_Hours;
  end
  else
  begin
    BaseInt := TimeTypeInt_Minutes;
    RightStr := ShowTime_Minutes;
  end;
  LeftInt := Mins div BaseInt;
  Result := IntToStr( LeftInt ) + ' ' + RightStr;
end;

class function TimeTypeUtil.getTimeShow(TimeType, TimeValue: Integer): string;
var
  TimeTypeStr, TimeValueStr : string;
begin
  TimeValueStr := IntToStr( TimeValue );
  TimeTypeStr := getTimeTypeStr( TimeType );

  Result := TimeValueStr + ' ' + TimeTypeStr;
end;

class function TimeTypeUtil.getTimeTypeStr(TimeType: Integer): string;
begin
  if TimeType = TimeType_Minutes then
    Result := ShowTime_Minutes
  else
  if TimeType = TimeType_Hourse then
    Result := ShowTime_Hours
  else
  if TimeType = TimeType_Day then
    Result := ShowTime_Days
  else
  if TimeType = TimeType_Week then
    Result := ShowTime_Weeks
  else
  if TimeType = TimeType_Month then
    Result := ShowTime_Months
  else
    Result := ShowTime_Minutes;
end;


{ MyEmail }

class function MyEmail.IsVaildEmailAddr(EmailAddr: String): boolean;
var
  Number,I:integer;     //Number用于给字符 '@ '计数
  TempStr:String;
begin
  Result := False;

  TempStr := EmailAddr;

    // 统计 @
  Number := 0;
  for I:=1 to Length(TempStr) do
    if TempStr[I]= '@' then
    begin
      INC(Number);
      if Number > 1 then //个数大于１
        Exit;
    end;

    //如果字符 '@ '的位置在字符串开头或者末尾，则不合法
  if ( TempStr[1]= '@') or ( TempStr[length(TempStr)] = '@') then
    Exit;

  I := pos( '@',TempStr);//获取字符 '@ '在字符串当中的位置
  delete( TempStr, 1, I );//获取字符串中字符 '@'后面的剩余子串
  if Length(TempStr) < 3 then //如果剩余子串的长度小于3,则不合法
    Exit;

    //如果剩余的子串当中不含有字符 '. '，或者其位置在//子串的开头或者末尾，则不合法
  if ( pos( '.',TempStr) = 0 ) or ( pos( '.',TempStr) = length( TempStr ) ) or
     ( pos( '.',TempStr) = 1 )
  then
    Exit;

    //以上的判断都通过，则表示地址字符串为合法
  Result:=True;
end;

{ MyAppEdition }

class function MyAppEdition.ReplaceFs(s: string): string;
begin
  Result := StringReplace( s, DiscriptName_BackupCow, DiscriptName_FolderTransfer, [rfReplaceAll] );
end;

{ MyKeyBorad }

class function MyKeyBorad.CheckCtrlEnter(tbtn: TToolButton; Key: Word;
  Shift: TShiftState): Boolean;
begin
  Result := False;
  if ( ssCtrl in Shift ) and ( Key = VK_RETURN ) and tbtn.Enabled then
  begin
    Result := True;
    tbtn.Click;
  end;
end;

class procedure MyKeyBorad.CheckDelete(tbtn: TToolButton; Key: Word);
begin
  if ( Key = VK_DELETE ) and tbtn.Enabled then
    tbtn.Click;
end;

class procedure MyKeyBorad.CheckDeleteAndEnter(tbtnDel, tbtnEnter: TToolButton;
  Key: Word);
begin
  CheckDelete( tbtnDel, Key );
  CheckEnter( tbtnEnter, Key );
end;

class procedure MyKeyBorad.CheckEnter(tbtn: TToolButton; Key: Word);
begin
  if ( Key = VK_RETURN ) and tbtn.Enabled then
    tbtn.Click;
end;

{ MyButton }

class procedure MyButton.Click(tbtn: TToolButton);
begin
  if tbtn.Enabled then
    tbtn.Click;
end;

{ MyFireWall }

class procedure MyFireWall.MakeThrough;
const
  NET_FW_SCOPE_ALL = 0;
  NET_FW_IP_VERSION_ANY = 2;
var
  FirewallObject: Variant;
  FirewallManager: Variant;
  FirewallProfile: Variant;
begin
  try
    FirewallObject := CreateOleObject('HNetCfg.FwAuthorizedApplication');
    FirewallObject.ProcessImageFileName := Application.ExeName;
    FirewallObject.Name := ExtractFileName( Application.ExeName );
    FirewallObject.Scope := NET_FW_SCOPE_ALL;
    FirewallObject.IpVersion := NET_FW_IP_VERSION_ANY;
    FirewallObject.Enabled := True;
    FirewallManager := CreateOleObject('HNetCfg.FwMgr');
    FirewallProfile := FirewallManager.LocalPolicy.CurrentProfile;
    FirewallProfile.AuthorizedApplications.Add(FirewallObject);
  except
  end;
end;

{ MyBroadcastIpList }

class function MyBroadcastIpList.get: TStringList;
var
  AI,Work : PIPAdapterInfo;
  Size    : Integer;
  Res     : Integer;
  IpStr, MaskStr : string;
  BroadcastIp : string;
begin
  Result := TStringList.Create;

  Size := 5120;
  GetMem(AI,Size);
  work:=ai;
  Res := GetAdaptersInfo(AI,Size);
  If (Res <> ERROR_SUCCESS) Then
   Begin
     SetLastError(Res);
     RaiseLastWin32Error;
     exit;
   End;
  repeat
    IpStr := work.IPAddressList.IPAddress;
    MaskStr := work.IPAddressList.IPMask;
    BroadcastIp := getBroadcastIp( IpStr, MaskStr );
    Result.Add( BroadcastIp );
    work:=work^.Next ;
  until (work=nil);
end;

class function MyBroadcastIpList.getBroadcastIp(IpStr, MaskStr: string): string;
var
  IpList, MaskList : TStringList;
  i : Integer;
  MaskNum, IpNum, BroNum : Byte;
begin
  Result := '';

  IpList := TStringList.Create;
  IpList.Delimiter := '.';
  IpList.DelimitedText := IpStr;

  MaskList := TStringList.Create;
  MaskList.Delimiter := '.';
  MaskList.DelimitedText := MaskStr;
  if ( MaskList.Count = 4 ) and ( IpList.Count = 4 ) then
  begin
    for i := 0 to MaskList.Count - 1 do
    begin
      MaskNum := StrToIntDef( MaskList[i], 0 );
      MaskNum := not MaskNum;
      IpNum := StrToIntDef( IpList[i], 0 );
      BroNum := IpNum or MaskNum;
      if Result <> '' then
        Result := Result + '.';
      Result := Result + IntToStr( BroNum );
    end;
  end;
  MaskList.Free;

  IpList.Free;
end;

end.
