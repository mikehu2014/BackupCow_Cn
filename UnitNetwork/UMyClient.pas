unit UMyClient;

interface

uses Classes, Sockets, UChangeInfo, SyncObjs, UMyUtil, SysUtils,UMyNetPcInfo, DateUtils, UModelUtil,
     UMyBackupInfo, uDebug, UFileBaseInfo;

type

{$Region ' Server 命令 接收线程 ' }

    // 接收 服务器信息 的线程
  TRevServerMsgThread = class( TThread )
  private
    TcpSocket : TCustomIpClient;
    IsStop : Boolean;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

{$EndRegion}

{$Region ' Server 命令 发送线程 ' }

  TSendServerMsgThread = class( TThread )
  private
    TcpSocket : TCustomIpClient;
  public
    constructor Create;
    procedure SetTcpSocket( _TcpSocket : TCustomIpClient );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function getNextMsg : string;
    procedure SendMsg( MsgStr : string );
  end;

{$EndRegion}

{$Region ' Client 父类信息 ' }

  TPcMsgBase = class( TMsgBase )
  public
    iPcID : string;
  published
    property PcID : string Read iPcID Write iPcID;
  public
    procedure SetPcID( _PcID : string );
  end;

{$EndRegion}

{$Region ' Client 状态信息 ' }

    // Online 父类
  TPcOnlineMsgBase = class( TPcMsgBase )
  private
    iPcCloudOnlineMsgStr : string;
    iPcCloudBaseMsgStr : string;
    iPcCloudSpaceMsgStr : string;
    iPcCloudConfigMsgStr : string;
    iPcCloudBackupPathMsgStr : string;
  published
    property PcCloudOnlineMsgStr : string Read iPcCloudOnlineMsgStr Write iPcCloudOnlineMsgStr;
    property PcCloudBaseMsgStr : string Read iPcCloudBaseMsgStr Write iPcCloudBaseMsgStr;
    property PcCloudSpaceMsgStr : string Read iPcCloudSpaceMsgStr Write iPcCloudSpaceMsgStr;
    property PcCloudConfigMsgStr : string Read iPcCloudConfigMsgStr Write iPcCloudConfigMsgStr;
    property PcCloudBackupPathMsgStr : string Read iPcCloudBackupPathMsgStr Write iPcCloudBackupPathMsgStr;
  public
    procedure SetPcCloudOnlineMsgStr( _PcCloudOnlineMsgStr : string );
    procedure SetPcCloudBaseMsgStr( _PcCloudBaseMsgStr : string );
    procedure SetPcCloudSpaceMsgStr( _PcCloudSpaceMsgStr : string );
    procedure SetPcCloudConfigMsgStr( _PcCloudConfigMsgStr : string );
    procedure SetPcCloudBackupPathMsgStr( _PcCloudBackupPathMsgStr : string );
    procedure Update;override;
  private
    procedure AddNetworkPc;
    procedure SetNetPcOnline;
    procedure AddOnlineJob;
    procedure CheckPcBatRegister;
    procedure SendFileRemove;
    procedure NetPcOnlineBackup;
    procedure CloudFileScan;
  private
    procedure SetFileRestore;
    procedure SetFileSearch;
    procedure SetFileTransfer;
    procedure SetFileShare;
    procedure SendIsShareFile;
  private
    procedure SetPcCloudOnlineMsg;
    procedure SetPcCloudBaseMsg;
    procedure SetPcCloudSpaceMsg;
    procedure SetPcCloudConfigMsg;
    procedure SetPcCloudBackupPathMsg;
  end;

    // Pc Online 信息
  TPcOnlineMsg = class( TPcOnlineMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendBackPcOnline;
  end;

    // Pc 返回 Online 信息
  TPcBackOnlineMsg = class( TPcOnlineMsgBase )
  public
    function getMsgType : string;override;
  end;

    // Pc Offline 信息
  TPcOfflineMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SetNetPcOffline;
  private
    procedure SetOfflineSearch;
    procedure SetOfflineRestore;
    procedure RemoveRedirectJob;
  private
    procedure RemoveOfflinePcTransfer;
    procedure SetFileTransferOfflineFace;
    procedure SetFileShare;
  end;

      // 信息工厂
  TPcStatusMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 网络备份信息 ' }

    // 父类
  TNetworkBackupChangeMsg = class( TPcMsgBase )
  public
    iBackupPath : string;
  published
    property BackupPath : string Read iBackupPath Write iBackupPath;
  public
    procedure SetBackupPath( _BackupPath : string );
  end;

    // 添加 父类
  TNetworkBackupAddMsg = class( TNetworkBackupChangeMsg )
  public
    iIsFile : Boolean;
    iFileCount : Integer;
    iFileSize : Int64;
  public
    iLastBackupTime : TDateTime;
  published
    property IsFile : Boolean Read iIsFile Write iIsFile;
    property FileCount : Integer Read iFileCount Write iFileCount;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property LastBackupTime : TDateTime Read iLastBackupTime Write iLastBackupTime;
  public
    procedure SetIsFile( _IsFile : Boolean );
    procedure SetSpaceInfo( _FileCount : Integer; _FileSize : Int64 );
    procedure SetLastBackupTime( _LastBackupTime : TDateTime );
  end;

    // 添加 Cloud Item
  TNetworkBackupAddCloudMsg = class( TNetworkBackupAddMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 删除 Cloud Item
  TNetworkBackupRemoveCloudMsg = class( TNetworkBackupChangeMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 添加 Restore Item
  TCloudBackupAddRestoreMsg = class( TNetworkBackupAddMsg )
  private
    iOwnerID, iOwnerName : string;
  published
    property OwnerID : string Read iOwnerID Write iOwnerID;
    property OwnerName : string Read iOwnerName Write iOwnerName;
  public
    procedure SetOwnerInfo( _OwnerID, _OwnerName : string );
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 删除 Restore Item
  TCloudBackupRemoveRestoreMsg = class( TNetworkBackupChangeMsg )
  private
    iOwnerID : string;
  published
    property OwnerID : string Read iOwnerID Write iOwnerID;
  public
    procedure SetOwnerID( _OwnerID : string );
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;


    // Add Pend 工厂
  TNetworkBackupMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client Transfer Pending 信息 '}

  {$Region ' 添加 ' }

    // 接收 对方 通知 等待传输
  TPcAddPendFileMsg = class( TPcMsgBase )
  public
    iPosition : Int64;
    iFileSize : Int64;
  published
    property Position : Int64 Read iPosition Write iPosition;
    property FileSize : Int64 Read iFileSize Write iFileSize;
  public
    procedure SetFileInfo( _Position, _FileSize : Int64 );
  end;

    // 等待下载文件 父类
  TPcAddDownPendFileMsg = class( TPcAddPendFileMsg )
  public
    iUpFilePath : string;
  published
    property UpFilePath : string Read iUpFilePath Write iUpFilePath;
  public
    procedure SetUpFilePath( _UpFilePath : string );
  end;

    // 等待 下载备份文件
  TPcAddDownPendBackupFileMsg = class( TPcAddDownPendFileMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 等待 下载传输文件
  TPcAddDownPendTransferFileMsg = class( TPcAddDownPendFileMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;


    // 等待上传文件 父类
  TPcAddUpPendFileMsg = class( TPcAddPendFileMsg )
  public
    iFilePath : string;
  published
    property FilePath : string Read iFilePath Write iFilePath;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 等待 上传搜索文件
  TPcAddUpPendSearchFileMsg = class( TPcAddUpPendFileMsg )
  public
     procedure Update;override;
    function getMsgType : string;override;
  end;

    // 等待 上传恢复文件
  TPcAddUpPendRestoreFileMsg = class( TPcAddUpPendFileMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 删除 ' }

    // 父类
  TPcRemovePendFileMsg = class( TPcMsgBase )
  private
    iRemovePath : string;
  published
    property RemovePath : string Read iRemovePath Write iRemovePath;
  public
    procedure SetRemovePath(_RemovePath : string );
    procedure Update;override;
  protected
    function getRootID : string;virtual;abstract;
  end;

    // 下载
  TPcRemoveDownPendFileMsg = class( TPcRemovePendFileMsg )
  public
    function getMsgType : string;override;
  protected
    function getRootID : string;override;
  end;

    // 上传
  TPcRemoveUpPendFileMsg = class( TPcRemovePendFileMsg )
  public
    function getMsgType : string;override;
  protected
    function getRootID : string;override;
  end;

  {$EndRegion}

    // Add Pend 工厂
  TPcAddPendFileMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get: TMsgBase;override;
  end;


{$EndRegion}

{$Region ' Client Redirect Job 信息 ' }

    // 重定向 Job : a 连 b, a 连不到 b
    // a 通过服务器发给 b, b 连 a
  TPcRedirectJobAddMsg = class( TPcMsgBase )
  public
    iJobMsgStr : string;
  published
    property JobMsgStr : string Read iJobMsgStr Write iJobMsgStr;
  public
    procedure SetJobMsg( _JobMsgStr : string );
    procedure Update;override;
  public
    function getMsgType : string;override;
  private
    function getIsDownload( JobType : string ): Boolean;
  end;

    // 工厂
  TRedirectJobMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 搜索信息 ' }

  {$Region ' 网络文件 请求信息 ' }

    // 文件 搜索 请求信息
  TFileSearchReqMsg = class( TPcMsgBase )
  public
    iSeaarchNum : Integer;
    iSearchFileName: string;
  published
    property SeaarchNum : Integer Read iSeaarchNum Write iSeaarchNum;
    property SearchFileName : string Read iSearchFileName Write iSearchFileName;
  public
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetSearchFileName( _SearchFileName : string );
  end;

    // 源文件 搜索请求
  TSourceFileSearchReqMsg = class( TFileSearchReqMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 备份副本 搜索请求
  TBackupFileSearchReqMsg = class( TFileSearchReqMsg )
  private
    iFileOwnerListStr : string;
  published
    property FileOwnerListStr : string Read iFileOwnerListStr Write iFileOwnerListStr;
  public
    procedure SetFileOwnerList( FileOwnerList : TStringList );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 网络文件 结果信息 ' }

    // 文件 搜索结果  父类
  TFileSearchResultBaseMsg = class( TPcMsgBase )
  public
    iSearchNum : Integer;
    iFilePath : string;
    iFileSize : Int64;
    iFileTime : TDateTime;
  published
    property SearchNum : Integer Read iSearchNum Write iSearchNum;
    property FilePath : string Read iFilePath Write iFilePath;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileTime : TDateTime Read iFileTime Write iFileTime;
  public
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
  end;

    // 源文件 搜索结果
  TSourceFileSearchResultMsg = class( TFileSearchResultBaseMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 备份文件 搜索结果
  TBackupFileSearchResultMsg = class( TFileSearchResultBaseMsg )
  public
    iOwnerID : string;
  published
    property OwnerID : string Read iOwnerID Write iOwnerID;
  public
    procedure SetOwnerID( _OwnerID : string );
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 网络文件 命令信息 ' }

    // 源文件 搜索完成
  TSourceFileSearchCompleteMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 备份文件 搜索完成
  TBackupCopyFileSearchCompleteMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 文件搜索 取消
  TFileSearchCancelMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}


  {$Region ' 恢复文件 请求信息 ' }

    // 恢复路径 命令信息
  TRestorePathMsg = class( TMsgBase )
  public
    iFullPath : string;
    iPathType : string;
  published
    property FullPath : string Read iFullPath Write iFullPath;
    property PathType : string Read iPathType Write iPathType;
  public
    procedure SetPathInfo( _FullPath, _PathType : string );
  end;

    // 恢复文件 请求信息
  TRestoreFileSearchReqMsg = class( TPcMsgBase )
  public
    iSearchNum : Integer;
    iRestorePcID : string;
    iRestorePathMsgList : string;
  published
    property SearchNum : Integer Read iSearchNum Write iSearchNum;
    property RestorePcID : string Read iRestorePcID Write iRestorePcID;
    property RestorePathMsgList : string Read iRestorePathMsgList Write iRestorePathMsgList;
  public
    constructor Create;
    procedure SetSearchNum( _SearchNum : Integer );
    procedure SetRestorePcID( _RestorePcID : string );
    procedure AddRestoreBackupPashMsg( MsgStr : string );
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 恢复文件 结果信息 ' }

      // 恢复文件 搜索结果
  TReStoreFileSearchResultMsg = class( TFileSearchResultBaseMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 恢复文件 命令信息 ' }

    // 恢复文件 搜索完成
  TRestoreFileSearchCompleteMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 恢复文件 取消
  TRestoreSearchCancelMsg = class( TPcMsgBase )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

  TFileSearchMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 传输文件信息 ' }

    // 传输文件信息 父类
  TCliendSendFileBaseMsg = class( TPcMsgBase )
  public
    iSourceFilePath : string;
  published
    property SourceFilePath : string Read iSourceFilePath Write iSourceFilePath;
  public
    procedure SetSourceFilePath( _SourceFilePath : string );
  end;

    // 发送传输文件请求
  TClientSendFileReqMsg = class( TCliendSendFileBaseMsg )
  public
    iSendPathType : string;
    iFileSize : Int64;
    iFileCount : Integer;
  published
    property SendPathType : string Read iSendPathType Write iSendPathType;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileCount : Integer Read iFileCount Write iFileCount;
  public
    procedure SetSendPathType( _SendPathType : string );
    procedure SetFileInfo( _FileSize : Int64; _FileCount : Integer );
    procedure Update;override;
  private
    procedure FeedBackOK;
    procedure ShowSelectForm;
    procedure FeedBackCancel;
  public
    function getMsgType : string;override;
  end;

    // 发送 传输文件请求 返回
  TClientSendFileFeedbackMsg = class( TCliendSendFileBaseMsg )
  public
    iSendPathStatus : string;
  published
    property SendPathStatus : string Read iSendPathStatus Write iSendPathStatus;
  public
    procedure SetSendPathStatus( _SendPathStatus : string );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 发送文件的空间
  TClientSendFileSpaceMsg = class( TCliendSendFileBaseMsg )
  public
    iFileSize : Int64;
  published
    property FileSize : Int64 Read iFileSize Write iFileSize;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 发送 添加 已完成空间信息
  TClientSendFileAddCompletedSpaceMsg = class( TCliendSendFileBaseMsg )
  public
    iCompletedSize : Int64;
  published
    property CompletedSize : Int64 Read iCompletedSize Write iCompletedSize;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

      // 发送 传输文件完成
  TClientSendFileCompletedMsg = class( TCliendSendFileBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 接收方 取消发送
  TClientReceiveFileCancelMsg = class( TCliendSendFileBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 发送方 取消发送
  TClientSendFileCancelMsg = class( TCliendSendFileBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 命令工厂
  TFileTransferMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 文件共享信息 ' }

  {$Region ' 文件列表信息 ' }

    // 父类 文件列表
  TClientSendShareListBaseMsg = class( TPcMsgBase )
  public
    iParentPath : string;
  published
    property ParentPath : string Read iParentPath Write iParentPath;
  public
    procedure SetParentPath( _ParentPath : string );
  end;

    // 请求 文件列表
  TClientSendShareListReqMsg = class( TClientSendShareListBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 返回 文件列表
  TClientSendShareListMsg = class( TClientSendShareListBaseMsg )
  public
    iFilePath : string;
    iIsFolder : Boolean;
    iFileSize : Int64;
    iFileTime : TDateTime;
  published
    property FilePath : string Read iFilePath Write iFilePath;
    property IsFolder : Boolean Read iIsFolder Write iIsFolder;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileTime : TDateTime Read iFileTime Write iFileTime;
  public
    procedure SetFilePath( _FilePath : string; _IsFolder : Boolean );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 完成 文件列表
  TClientSendShareListCompletedMsg = class( TClientSendShareListBaseMsg )
  public
    iIsCancelShare : Boolean;
  published
    property IsCancelShare : Boolean Read iIsCancelShare Write iIsCancelShare;
  public
    procedure SetIsCancelShare( _IsCancelShare : Boolean );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 文件下载 ' }

    // 父类 下载
  TClientSendShareDownBaseMsg = class( TPcMsgBase )
  public
    iDownloadPath : string;
  published
    property DownloadPath : string Read iDownloadPath Write iDownloadPath;
  public
    procedure SetDownloadPath( _DownloadPath : string );
  end;

    // 请求 下载文件
  TClientSendShareDownReqMsg = class( TClientSendShareDownBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 返回 下载文件
  TClientSendShareDownMsg = class( TClientSendShareDownBaseMsg )
  public
    iFilePath : string;
    iFileSize : Int64;
    iFileTime : TDateTime;
  published
    property FilePath : string Read iFilePath Write iFilePath;
    property FileSize : Int64 Read iFileSize Write iFileSize;
    property FileTime : TDateTime Read iFileTime Write iFileTime;
  public
    procedure SetFilePath( _FilePath : string );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 完成 下载文件
  TClientSendShareDownCompletedMsg = class( TClientSendShareDownBaseMsg )
  public
    iIsShareCancel : Boolean;
  published
    property IsShareCancel : Boolean Read iIsShareCancel Write iIsShareCancel;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 文件共享下载 ' }

    // 请求 是否取消下载
  TClientSendShareCancelReqMsg = class( TClientSendShareDownBaseMsg )
  public
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

    // 返回 是否取消下载
  TClientSendShareCancelMsg = class( TClientSendShareDownBaseMsg )
  public
    iIsShareCancel : Boolean;
  published
    property IsShareCancel : Boolean Read iIsShareCancel Write iIsShareCancel;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

  {$EndRegion}

  {$Region ' 是否共享了文件 ' }

  TClientSendIsShareMsg = class( TPcMsgBase )
  public
    iPcName : string;
    iIsShareFile : Boolean;
    iShareFileCount : Integer;
  published
    property PcName : string Read iPcName Write iPcName;
    property IsShareFile : Boolean Read iIsShareFile Write iIsShareFile;
  public
    procedure SetPcName( _PcName : string );
    procedure SetIsShareFile( _IsShareFile : Boolean );
    procedure Update;override;
  public
    function getMsgType : string;override;
  end;

  {$EndRegion}

    // 文件共享 命令工厂
  TFileShareMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 云信息 '}

    // 寻找本机备份路径信息
  TFindBackupPathMsg = class
  private
    NewBackupPathHash : TBackupPathList;
    MsgStr : string;
  public
    constructor Create;
    function get : string;
    destructor Destroy; override;
  private
    procedure FindNewBackupPathHash;
    procedure ScanNewBackupPathHash;
  end;

  PcCloudMsgUtil = class
  public
    class function getOnlineTimeMsg : string;
    class function getBaseMsg : string;
    class function getSpaceMsg : string;
    class function getConfigMsg : string;
    class function getBackupPathMsg : string;
  public
    class procedure setOnlineTimeMsg( MsgStr : string );
    class procedure setBaseMsg( MsgStr : string );
    class procedure setSpaceMsg( MsgStr : string );
    class procedure setConfigMsg( MsgStr : string );
    class procedure setBackupPathMsg( MsgStr : string );
  end;

  {$Region ' 云基本信息 ' }

    // 云信息 更新父类
  TPcCloudOnlineTimeMsg = class( TPcMsgBase )
  private
    iLastOnlineTime : TDateTime;
  published
    property LastOnlineTime : TDateTime Read iLastOnlineTime Write iLastOnlineTime;
  public
    procedure SetOnlineTime( _LastOnlineTime : TDateTime );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // Pc 的 云基本信息
  TPcCloudBaseMsg = class( TPcMsgBase )
  private
    iPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
  published
    property PcName : string Read iPcName Write iPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    procedure SetPcName( _PcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSokcet( _InternetIp, _InternetPort : string );
    procedure Update;override;
  private
    procedure AddNetworkPc;
    procedure CheckNetPcReach;
  end;

    // Pc 的 云空间信息
  TPcCloudSpaceMsg = class( TPcMsgBase )
  private
    iUsedSpace : Int64;
    iTotalSpace : Int64;
    iBackupSpace : Int64;
  published
    property UsedSpace : Int64 Read iUsedSpace Write iUsedSpace;
    property TotalSpace : Int64 Read iTotalSpace Write iTotalSpace;
    property BackupSpace : Int64 Read iBackupSpace Write iBackupSpace;
  public
    procedure SetSpace( _UsedSpace, _TotalSpace : Int64 );
    procedure SetBackupSpace( _BackupSpace : Int64 );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // Pc 的 云配置信息
  TPcCloudConfigMsg = class( TPcMsgBase )
  private
    iCopyCount : Integer;  //  设置的副本数
  private
    iIsFileInvisible : Boolean; // 是否隐藏搜索文件信息;
    iIvPasswordMD5 : string;  // 隐藏文件密码MD5值;
  private
    iRegisterHardCode : string; // 注册 HardCode
    iRegisterEdition : string; // 注册版本
  published
    property IsFileInvisible : Boolean Read iIsFileInvisible Write iIsFileInvisible;
    property IvPasswordMD5 : string Read iIvPasswordMD5 Write iIvPasswordMD5;
    property RegisterHardCode : string Read iRegisterHardCode Write iRegisterHardCode;
    property RegisterEdition : string Read iRegisterEdition Write iRegisterEdition;
    property CopyCount : Integer Read iCopyCount Write iCopyCount;
  public
    procedure SetFileInvisible( _IsFileInvisible : Boolean );
    procedure SetIvPasswordMD5( _IvPasswordMD5 : string );
    procedure SetRegisterEdition( _RegisterEdition, _RegisterHardCode : string );
    procedure SetCopyCount( _CopyCount : Integer );
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 备份路径 添加 信息
  TCloudBackupPathAddMsg = class( TPcMsgBase )
  public
    iFullPath, iPathType : string;
    iIsEncrypt : Boolean;
    iPasswordMD5, iPasswordHint : string;
    iFolderSpace : Int64;
    iFileCount, iCopyCount : Integer;
  public
    iCopyOwnerAddMsgListMsg : string;
  published
    property FullPath : string Read iFullPath Write iFullPath;
    property PathType : string Read iPathType Write iPathType;
    property IsEncrypt : Boolean Read iIsEncrypt Write iIsEncrypt;
    property PasswordMD5 : string Read iPasswordMD5 Write iPasswordMD5;
    property PasswordHint : string Read iPasswordHint Write iPasswordHint;
    property FolderSpace : Int64 Read iFolderSpace Write iFolderSpace;
    property FileCount : Integer Read iFileCount Write iFileCount;
    property CopyCount : Integer Read iCopyCount Write iCopyCount;
    property CopyOwnerAddMsgListMsg : string Read iCopyOwnerAddMsgListMsg Write iCopyOwnerAddMsgListMsg;
  public
    constructor Create;
    procedure SetPathInfo( _FullPath, _PathType : string );
    procedure SetEncryptInfo( _IsEncrypt : Boolean; _PasswordMD5, _PasswordHint : string );
    procedure SetSpace( _FolderSpace : Int64 );
    procedure SetCountInfo( _FileCount, _CopyCount : Integer );
    procedure AddCopyOwnerAddMsg( CopyOwnerAddMsg : string );
    procedure Update;override;
  private
    procedure AddCopyOwner;
  end;

    // 备份路径 副本拥有者 添加
  TCloudBackupPathOwnerAddMsg = class( TPcMsgBase )
  public
    iFullPath, iCopyOwner : string;
    iOwnerSpace : Int64;
  published
    property FullPath : string Read iFullPath Write iFullPath;
    property CopyOwner : string Read iCopyOwner Write iCopyOwner;
    property OwnerSpace : Int64 Read iOwnerSpace Write iOwnerSpace;
  public
    procedure SetPathInfo( _FullPath, _CopyOwner : string );
    procedure SetOwnerSpace( _OwnerSpace : Int64 );
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' 刷新 所有云Pc信息 ' }

    // 刷新 云 Pc 信息
  TRefreshCloudPcBaseMsg = class( TMsgBase )
  private
    iCloudPcID : string;
    iCloudPcName : string;
    iPcCloudOnlineTimeMsgStr : string;
    iPcClousSpaceMsgStr : string;
    iPcCloudConfigMsgStr : string;
    iPcCloudBackupPathMsgStr : string;
  published
    property CloudPcID : string Read iCloudPcID Write iCloudPcID;
    property CloudPcName : string Read iCloudPcName Write iCloudPcName;
    property PcCloudOnlineTimeMsgStr : string Read iPcCloudOnlineTimeMsgStr Write iPcCloudOnlineTimeMsgStr;
    property PcClousSpaceMsgStr : string Read iPcClousSpaceMsgStr Write iPcClousSpaceMsgStr;
    property PcCloudConfigMsgStr : string Read iPcCloudConfigMsgStr Write iPcCloudConfigMsgStr;
    property PcCloudBackupPathMsgStr : string Read iPcCloudBackupPathMsgStr Write iPcCloudBackupPathMsgStr;
  protected
    IsUpdate : Boolean;
  public
    procedure SetCloudPcInfo( _CloudPcID, _CloudPcName : string );
    procedure SetPcCloudOnlineTimeMsgStr( _PcCloudOnlineTimeMsgStr : string );
    procedure SetPcCloudSpaceMsgStr( _PcClousSpaceMsgStr : string );
    procedure SetCloudConfigMsgStr( _PcCloudConfigMsgStr : string );
    procedure SetPcCloudBackupPathMsgStr( _PcCloudBackupPathMsgStr : string );
    procedure Update;override;
  private
    function CheckPcIsUpdate : Boolean;
    procedure SetCloudPcBaseInfo;
    procedure SetCloudOnlineInfo;
    procedure SetCloudSpaceInfo;
    procedure SetCloudConfigInfo;
    procedure SetCloudBackupPathInfo;
  end;

    // 刷新 客户端 云 Pc 信息
  TRefreshClientCloudPcMsg = class( TRefreshCloudPcBaseMsg )
  public
    function getMsgType : string;override;
  end;

    // 刷新 服务器 云 Pc 信息
  TRefreshServerCloudPcMsg = class( TRefreshCloudPcBaseMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendToOtherClinet;
  end;

    // 刷新 Pc 的 备份路径信息
  TRefreshCloudBackupPathMsg = class( TPcMsgBase )
  private
    iBackupPathAddMsgList : string;
  published
    property BackupPathAddMsgList : string Read iBackupPathAddMsgList Write iBackupPathAddMsgList;
  public
    constructor Create;
    procedure AddBackupPathAddMsg( MsgStr : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure ClearOldBackupPath;
    procedure AddNewBackupPath;
    procedure ResetPcBackupItem( ItemCount : Integer );
  end;

  {$EndRegion}

  {$Region ' 云注册信息 ' }

    // 注册信息
  TPcBatRegisterMsg = class( TPcMsgBase )
  private
    iLicenseStr : string;
  published
    property LicenseStr : string Read iLicenseStr Write iLicenseStr;
  public
    procedure SetLicenseStr( _LicenseStr : string );
    procedure Update;override;
    function getMsgType : string;override;
  end;

  {$EndRegion}

    // 云信息工厂
  TRefreshCloudPcMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 文件删除信息 ' }

    // 父类
  TFileRemoveMsg = class( TPcMsgBase )
  private
    iFilePath : string;
  published
    property FilePath : string Read iFilePath Write iFilePath;
  public
    procedure SetFilePath( _FilePath : string );
  end;

    // 备份文件 删除通知
  TBackupFileRemoveMsg = class( TFileRemoveMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure SendRemoveReturn;
  end;

    // 删除完成 返回
  TFileRemoveReturnMsg = class( TFileRemoveMsg )
  end;

    // 备份文件 删除完成 返回
  TBackupFileRemoveReturnMsg = class( TFileRemoveReturnMsg )
  public
    procedure Update;override;
    function getMsgType : string;override;
  end;

    // 命令工厂
  TFileRemoveMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

{$Region ' Client 发送操作 ' }

  {$Region ' 刷新 云信息 ' }

  TFindCloudPcMsg = class
  private
    NetPcInfo : TNetPcInfo;
  public
    constructor Create( _NetPcInfo : TNetPcInfo );
    function getPcCloudOnlineMsg : string;
    function getPcCloudSpaceMsg : string;
    function getPcCloudConfigMsg : string;
    function getPcCloudBackupPathMsg : string;
  end;

  TSendRefreshPcInfo = class( TChangeInfo )
  public
    TargetPcID : string;
  public
    constructor Create( _TargetPcID : string );
    procedure Update;override;
  protected
    function getRefreshCloudPcBaseMsg : TRefreshCloudPcBaseMsg;virtual;abstract;
  end;

    // 客户端发送
  TClientSendRefreshPcInfo = class( TSendRefreshPcInfo )
  protected
    function getRefreshCloudPcBaseMsg : TRefreshCloudPcBaseMsg;override;
  end;

    // 服务器发送
  TServerSendRefreshPcInfo = class( TSendRefreshPcInfo )
  protected
    function getRefreshCloudPcBaseMsg : TRefreshCloudPcBaseMsg;override;
  end;

  {$EndRegion}

  {$Region ' 刷新 备份路径信息 ' }

  TRefreshCloudBackupPathInfo = class( TChangeInfo )
  private
    NewBackupPathHash : TBackupPathList;
  public
    constructor Create;
    procedure Update;override;
    destructor Destroy; override;
  private
    procedure FindNewBackupPathHash;
    procedure ScanNewBackupPathHash;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Client 心跳线程 ' }


  TClientHeartBeatThread = class( TThread )
  private
    IsUpgrade : Boolean;
  public
    constructor Create;
    procedure UpgradeNow;  // 立刻更新
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    procedure SendLastOnline;
    procedure SendCloudSpace;
    procedure SendCloudConfig;
    procedure SendCloudBackupPath;
  end;

{$EndRegion}

{$Region ' Advance 网络 Pc 信息 ' }

  TAdvancePcConnMsg = class( TPcMsgBase )
  private
    iConnPcID, iConnPcName : string;
    iLanIp, iLanPort : string;
    iInternetIp, iInternetPort : string;
  published
    property ConnPcID : string Read iConnPcID Write iConnPcID;
    property ConnPcName : string Read iConnPcName Write iConnPcName;
    property LanIp : string Read iLanIp Write iLanIp;
    property LanPort : string Read iLanPort Write iLanPort;
    property InternetIp : string Read iInternetIp Write iInternetIp;
    property InternetPort : string Read iInternetPort Write iInternetPort;
  public
    procedure SetConnPcInfo( _ConnPcID, _ConnPcName : string );
    procedure SetLanSocket( _LanIp, _LanPort : string );
    procedure SetInternetSocket( _InternetIp, _InternetPort : string );
    procedure Update;override;
    function getMsgType : string;override;
  private
    procedure AddNetworkPc;
    procedure AddPingMsg;
  end;

  TAdvanceConnMsgFactory = class( TMsgFactory )
  public
    constructor Create;
    function get : TMsgBase;override;
  end;

{$EndRegion}

    // 重启 底层网络
  TResetMasterEvent = procedure of object;

    // 客户端信息
  TMyClient = class( TMyMsgChange )
  public
    MsgLock : TCriticalSection;
    SendMsgList : TStringList; // 发送命令队列
  public
    TcpSocket : TCustomIpClient;
    RevServerMsgThread : TRevServerMsgThread;  // 接收命令线程
    SendServerMsgThread : TSendServerMsgThread; // 发送命令线程
    ClientHeartBeatThread : TClientHeartBeatThread; // 发送心跳线程
  public
    IsConnServer : Boolean;
    FResetMaster : TResetMasterEvent;
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure SetFactoryList;override;
  public
    procedure RunRevMsg;
    procedure SendMsgToPc( PcID : string; MsgBase : TMsgBase );
    procedure SendMsgToAll( MsgBase : TMsgBase );overload;
    procedure SendMsgToAll( MstStr : string );overload;
    procedure AddSendMsgStr( MsgStr : string );
    procedure UpgradeCloudInfo;  // 刷新云信息
  public
    procedure StartHeartBeat;
    procedure StopHeartBeat;
  public
    procedure ClientRestart;  // 主动 重启网络
    procedure ServerLostConn; // 被动 重启网络
    property OnResetMaster : TResetMasterEvent read FResetMaster write FResetMaster;
  end;

const
  ThreadCount_ServerMsg : Integer = 2;

  MsgType_PcStatus = 'pst_';
  MsgType_PcStatus_Online = 'pst_ol';
  MsgType_PcStatus_BackOnline = 'pst_bol';
  MsgType_PcStatus_Offline = 'pst_Ofl';

  MsgType_PcAddPend = 'pap_';
  MsgType_PcAddPend_DownBackup = 'pap_db';
  MsgType_PcAddPend_DownTransfer = 'pap_dt';
  MsgType_PcAddPend_UpSearch = 'pap_us';
  MsgType_PcAddPend_UpRestore  = 'pap_ur';
  MsgType_PcAddPend_RemoveDownPend = 'pap_rdp';
  MsgType_PcAddPend_RemoveUpPend = 'pap_rup';

  MsgType_RedirectJob = 'rj_';
  MsgType_RedirectJob_Add = 'rj_ad';

  MsgType_PcSearch = 'psh_';
  MsgType_PcSearch_ReqSource = 'psh_rs';
  MsgType_PcSearch_ResultSource = 'psh_res';
  MsgType_PcSearch_StopSource = 'psh_ss';
  MsgType_PcSearch_ReqBackupCopy = 'psh_rbc';
  MsgType_PcSearch_ResultBackupCopy = 'psh_rebc';
  MsgType_PcSearch_StopBackupCopy = 'psh_sbc';
  MsgType_PcSearch_CancelSearch = 'psh_cs';
  MsgType_PcSearch_ReqRestore = 'psh_rr';
  MsgType_PcSearch_ResultRestore = 'psh_rer';
  MsgType_PcSearch_StopRestore = 'psh_sr';
  MsgType_PcSearch_CancelRestore = 'psh_cr';

  MsgType_CloudPc = 'cp_';
  MsgType_CloudPc_OnlineTime = 'cp_ot';
  MsgType_CloudPc_CloudSpace = 'cp_cs';
  MsgType_CloudPc_CloudConfig = 'cp_cc';
  MsgType_CloudPc_RefreshClient = 'cp_rc';
  MsgType_CloudPc_RefreshServer = 'cp_rs';
  MsgType_CloudPc_RefreshBackupPath = 'cp_rbp';
  MsgType_CloudPc_BatRegister = 'cp_br';

  MsgType_FileRemove = 'fr_';
  MsgType_FileRemove_BackupNotify = 'fr_bn';
  MsgType_FileRemove_BackupReturn = 'fr_br';

  MsgType_FileTransfer = 'ft_';
  MsgType_FileTransfer_SendReq = 'ft_sr';
  MsgType_FileTransfer_SendFeedback = 'ft_sfb';
  MsgType_FileTransfer_SendSpace = 'ft_ss';
  MsgType_FileTransfer_SendAddCompletedSpace = 'ft_sacp';
  MsgType_FileTransfer_SendSCompleted = 'ft_sc';
  MsgType_FileTransfer_SendCancel = 'ft_scc';
  MsgType_FileTransfer_ReceiveCancel = 'ft_rc';

  MsgType_FileShare = 'fs_';
  MsgType_FileShare_ShareListReq = 'fs_slr';
  MsgType_FileShare_ShareList = 'fs_sl';
  MsgType_FileShare_ShareListCompleted = 'fs_slc';
  MsgType_FileShare_ShareDownReq = 'fs_sdr';
  MsgType_FileShare_ShareDown = 'fs_sd';
  MsgType_FileShare_ShareDownCompleted = 'fs_sdc';
  MsgType_FileShare_ShareCancelReq = 'fs_scr';
  MsgType_FileShare_ShareCancel = 'fs_sc';
  MsgType_FileShare_ShareFileCount = 'fs_sfc';

  MsgType_NetworkBackup = 'nb_';
  MsgType_NetworkBackup_AddCloudItem = 'nb_aci';
  MsgType_NetworkBackup_RemoveCloudItem = 'nb_rci';
  MsgType_NetworkBackup_AddRestoreItem = 'nb_ari';
  MsgType_NetworkBackup_RemoveRestoreItem = 'nb_rri';

  MsgType_AdvancePc = 'ap_';
var
  MyClient : TMyClient;

implementation

uses UMyServer,  UNetworkFace, UMyMaster, UJobFace, UMyJobInfo, USearchServer, UMyFileSearch, UMyTcp,
     UNetPcInfoXml, USettingInfo, UMyCloudPathInfo, URegisterInfo, UCloudPathInfoXml, UBackupInfoXml,
     UMyBackupRemoveControl, UNetworkControl, UMyFileTransfer, UmyFileDownload,
     UBackupInfoControl, UMyFileTransferControl, UMyShareControl, UMyShareInfo, UMyShareScan,
     UMyCloudFileControl, URestoreFileFace, USearchFileFace, UFileTransferFace, UMyFileTransferInfo,
     UMyCloudApiInfo, UMyRestoreApiInfo;

{ TRevServerMsgThread }

constructor TRevServerMsgThread.Create;
begin
  inherited Create( True );
  IsStop := False;
end;

destructor TRevServerMsgThread.Destroy;
begin
  Terminate;
  IsStop := True;
  TcpSocket.Disconnect;
  Resume;
  WaitFor;

  inherited;
end;

procedure TRevServerMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
      // 未连接， 则等待连接
    if not TcpSocket.Connected then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;

      // 已连接则接收信息
    MsgStr := MySocketUtil.RevString( TcpSocket );
    if MsgStr = ''  then  // 断开连接
    begin
      if not IsStop then
        MyClient.ServerLostConn
    end
    else
      MyClient.AddMsg( MsgStr );
  end;

  inherited;
end;

procedure TRevServerMsgThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TMyClient }

constructor TMyClient.Create;
begin
  inherited Create;

  IsConnServer := False;

  MsgLock := TCriticalSection.Create;
  SendMsgList := TStringList.Create;

  TcpSocket := TCustomIpClient.Create(nil);

    // 处理 服务器信息的线程
  AddThread( ThreadCount_ServerMsg );

    // 发送 服务器信息 线程
  SendServerMsgThread := TSendServerMsgThread.Create;
  SendServerMsgThread.SetTcpSocket( TcpSocket );

    // 接收 服务器信息 线程
  RevServerMsgThread := TRevServerMsgThread.Create;
  RevServerMsgThread.SetTcpSocket( TcpSocket );

    // 发送心跳线程
  ClientHeartBeatThread := TClientHeartBeatThread.Create;
end;

destructor TMyClient.Destroy;
begin
  ClientHeartBeatThread.Free;
  RevServerMsgThread.Free;
  SendServerMsgThread.Free;

  StopThread;

  TcpSocket.Free;
  SendMsgList.Free;
  MsgLock.Free;
  inherited;
end;

procedure TMyClient.AddSendMsgStr(MsgStr: string);
begin
  MsgLock.Enter;
  SendMsgList.Add( MsgStr );
  MsgLock.Leave;

  SendServerMsgThread.Resume;
end;

procedure TMyClient.ClientRestart;
begin
  IsConnServer := False;
  TcpSocket.Disconnect;
end;

procedure TMyClient.RunRevMsg;
begin
  IsConnServer := True;
  RevServerMsgThread.Resume;
end;

procedure TMyClient.SendMsgToAll(MsgBase: TMsgBase);
var
  MsgStr : string;
begin
  MsgStr := MsgBase.getMsg;
  SendMsgToAll( MsgStr );
  MsgBase.Free;
end;

procedure TMyClient.SendMsgToAll(MstStr: string);
var
  SendClientAllMsg : TSendClientAllMsg;
  SendMsgStr : string;
begin
    // 请求服务器 转发所有 Pc
  SendClientAllMsg := TSendClientAllMsg.Create;
  SendClientAllMsg.SetSendMsgStr( MstStr );

  SendMsgStr := SendClientAllMsg.getMsg;
  AddSendMsgStr( SendMsgStr );

  SendClientAllMsg.Free;
end;

procedure TMyClient.SendMsgToPc(PcID: string; MsgBase: TMsgBase);
var
  SendClientMsg : TSendClientMsg;
  MsgStr : string;
begin
    // 请求服务器 转发 Pc
  SendClientMsg := TSendClientMsg.Create;
  SendClientMsg.SetTargetPcID( PcID );
  SendClientMsg.SetSendMsgBase( MsgBase );

  MsgStr := SendClientMsg.getMsg;
  AddSendMsgStr( MsgStr );

  SendClientMsg.Free;
  MsgBase.Free;
end;

procedure TMyClient.ServerLostConn;
var
  FileSearchClearInfo : TAllPcFileSearchCompleteInfo;
begin
    // 结束 搜索
  FileSearchClearInfo := TAllPcFileSearchCompleteInfo.Create;
  MyFileSearchReq.AddChange( FileSearchClearInfo );

    // 重启 搜索 Master
  if IsConnServer and Assigned( FResetMaster ) then
  begin
    IsConnServer := False;
    FResetMaster;
  end;
end;

procedure TMyClient.SetFactoryList;
var
  MsgFactory : TMsgFactory;
begin
    // Pc 状态命令
  MsgFactory := TPcStatusMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // Pend File 添加命令
  MsgFactory := TPcAddPendFileMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // FileSearch 请求与结果
  MsgFactory := TFileSearchMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // CloudPcInfo
  MsgFactory := TRefreshCloudPcMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // Advance
  MsgFactory := TAdvanceConnMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // FileRemove
  MsgFactory := TFileRemoveMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // File Transfer
  MsgFactory := TFileTransferMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // File Share
  MsgFactory := TFileShareMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // Redirect Job
  MsgFactory := TRedirectJobMsgFactory.Create;
  AddMsgFactory( MsgFactory );

    // Network Backup
  MsgFactory := TNetworkBackupMsgFactory.Create;
  AddMsgFactory( MsgFactory );
end;


procedure TMyClient.StartHeartBeat;
begin
  ClientHeartBeatThread.Resume;
end;

procedure TMyClient.StopHeartBeat;
begin
  ClientHeartBeatThread.Suspend;
end;

procedure TMyClient.UpgradeCloudInfo;
begin
  ClientHeartBeatThread.UpgradeNow;
end;

{ TServerTramitMsgFactory }

constructor TPcStatusMsgFactory.Create;
begin
  inherited Create( MsgType_PcStatus );
end;

function TPcStatusMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_PcStatus_Online then
    Result := TPcOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_BackOnline then
    Result := TPcBackOnlineMsg.Create
  else
  if MsgType = MsgType_PcStatus_Offline then
    Result := TPcOfflineMsg.Create
  else
    Result := nil;
end;

{ TPcOnlineMsg }

function TPcOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Online;
end;

procedure TPcOnlineMsg.SendBackPcOnline;
var
  PcBackOnlineMsg : TPcBackOnlineMsg;
  MsgStr : string;
begin
    // Back Online Msg
  PcBackOnlineMsg := TPcBackOnlineMsg.Create;
  PcBackOnlineMsg.SetPcID( PcInfo.PcID );

    // 上线时间
  MsgStr := PcCloudMsgUtil.getOnlineTimeMsg;
  PcBackOnlineMsg.SetPcCloudOnlineMsgStr( MsgStr );

    // Pc 基本信息
  MsgStr := PcCloudMsgUtil.getBaseMsg;
  PcBackOnlineMsg.SetPcCloudBaseMsgStr( MsgStr );

    // 云空间信息
  MsgStr := PcCloudMsgUtil.getSpaceMsg;
  PcBackOnlineMsg.SetPcCloudSpaceMsgStr( MsgStr );

    // 云配置信息
  MsgStr := PcCloudMsgUtil.getConfigMsg;
  PcBackOnlineMsg.SetPcCloudConfigMsgStr( MsgStr );

    // 备份路径信息
  MsgStr := PcCloudMsgUtil.getBackupPathMsg;
  PcBackOnlineMsg.SetPcCloudBackupPathMsgStr( MsgStr );

  MyClient.SendMsgToPc( PcID, PcBackOnlineMsg );
end;

procedure TPcOnlineMsg.Update;
begin
  inherited;

  SendBackPcOnline;
end;

{ TPcBackOnlineMsg }

function TPcBackOnlineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_BackOnline;
end;

{ TPcOfflineMsg }

procedure TPcOfflineMsg.RemoveOfflinePcTransfer;
var
  VirTransferPcOfflineHandle : TVirTransferPcOfflineHandle;
begin
  VirTransferPcOfflineHandle := TVirTransferPcOfflineHandle.Create;
  VirTransferPcOfflineHandle.SetPcID( PcID );
  VirTransferPcOfflineHandle.Update;
  VirTransferPcOfflineHandle.Free;
end;

procedure TPcOfflineMsg.RemoveRedirectJob;
var
  RedirectJobPcOfflineInfo : TRedirectJobPcOfflineInfo;
begin
  RedirectJobPcOfflineInfo := TRedirectJobPcOfflineInfo.Create( PcID );
  MyJobInfo.AddChange( RedirectJobPcOfflineInfo );
end;

procedure TPcOfflineMsg.SetNetPcOffline;
var
  NetPcOfflineHandle : TNetPcOfflineHandle;
begin
  NetPcOfflineHandle := TNetPcOfflineHandle.Create( PcID );
  NetPcOfflineHandle.Update;
  NetPcOfflineHandle.Free;
end;

procedure TPcOfflineMsg.SetOfflineRestore;
var
  RestoreFileSearchCompleteInfo : TRestoreFileSearchCompleteInfo;
  RestoreFileSearchCancelInfo : TRestoreFileSearchCancelInfo;
begin
    // Restore Req
  RestoreFileSearchCompleteInfo := TRestoreFileSearchCompleteInfo.Create( PcID );
  MyFileRestoreReq.AddChange( RestoreFileSearchCompleteInfo );

    // Restore Scan
  RestoreFileSearchCancelInfo := TRestoreFileSearchCancelInfo.Create( PcID );
  MyFileRestoreScan.AddChange( RestoreFileSearchCancelInfo );
end;

procedure TPcOfflineMsg.SetOfflineSearch;
var
  AllFileSearchCompleteInfo : TAllFileSearchCompleteInfo;
  FileSearchCancelInfo : TFileSearchCancelInfo;
begin
    // Search Req
  AllFileSearchCompleteInfo := TAllFileSearchCompleteInfo.Create( PcID );
  MyFileSearchReq.AddChange( AllFileSearchCompleteInfo );

    // Search Scan
  FileSearchCancelInfo := TFileSearchCancelInfo.Create( PcID );
  MyFileSearchScan.AddChange( FileSearchCancelInfo );
end;

procedure TPcOfflineMsg.SetFileShare;
var
  ShareDownFilePcIsOnlineHandle : TShareDownFilePcIsOnlineHandle;
  ShareHistoryPcOnlineHandle : TShareHistoryPcOnlineHandle;
  ShareFavorityPcOnlineHandle : TShareFavorityPcOnlineHandle;
  SharePcRevIsShareHandle : TSharePcRevIsShareHandle;
begin
    // Share Down
  ShareDownFilePcIsOnlineHandle := TShareDownFilePcIsOnlineHandle.Create( PcID );
  ShareDownFilePcIsOnlineHandle.SetIsOnline( False );
  ShareDownFilePcIsOnlineHandle.Update;
  ShareDownFilePcIsOnlineHandle.Free;

    // Share History
  ShareHistoryPcOnlineHandle := TShareHistoryPcOnlineHandle.Create( PcID );
  ShareHistoryPcOnlineHandle.SetIsOnline( False );
  ShareHistoryPcOnlineHandle.Update;
  ShareHistoryPcOnlineHandle.Free;

    // Share Favorite
  ShareFavorityPcOnlineHandle := TShareFavorityPcOnlineHandle.Create( PcID );
  ShareFavorityPcOnlineHandle.SetIsOnline( False );
  ShareFavorityPcOnlineHandle.Update;
  ShareFavorityPcOnlineHandle.Free;

    // 不共享目录
  SharePcRevIsShareHandle := TSharePcRevIsShareHandle.Create( PcID, '' );
  SharePcRevIsShareHandle.SetIsShareFolder( False );
  SharePcRevIsShareHandle.Update;
  SharePcRevIsShareHandle.Free;
end;

procedure TPcOfflineMsg.SetFileTransferOfflineFace;
var
  SendFilePcOfflineHandle : TSendFilePcOfflineHandle;
  ReceiveFileOnlineHandle : TReceiveFileOnlineHandle;
begin
    // 发送文件
  SendFilePcOfflineHandle := TSendFilePcOfflineHandle.Create( PcID );
  SendFilePcOfflineHandle.Update;
  SendFilePcOfflineHandle.Free;

    // 接收文件
  ReceiveFileOnlineHandle := TReceiveFileOnlineHandle.Create( PcID );
  ReceiveFileOnlineHandle.SetIsOnline( False );
  ReceiveFileOnlineHandle.Update;
  ReceiveFileOnlineHandle.Free;
end;

function TPcOfflineMsg.getMsgType: string;
begin
  Result := MsgType_PcStatus_Offline;
end;

procedure TPcOfflineMsg.Update;
begin
    // 网络状态
  SetNetPcOffline;

    // Job 状态
  RemoveRedirectJob;

    // 搜索状态
  SetOfflineSearch;
  SetOfflineRestore;

    // 传输状态
  RemoveOfflinePcTransfer;

    // 发送文件
  SetFileTransferOfflineFace;
  SetFileShare;
end;

{ TPcOnlineMsgBase }


procedure TPcOnlineMsgBase.AddNetworkPc;
var
  PcCloudBaseMsg : TPcCloudBaseMsg;
  PcName : string;
  NetPcAddHandle : TNetPcAddHandle;
begin
  PcCloudBaseMsg := TPcCloudBaseMsg.Create;
  PcCloudBaseMsg.SetMsgStr( PcCloudBaseMsgStr );
  PcName := PcCloudBaseMsg.PcName;
  PcCloudBaseMsg.Free;

  NetPcAddHandle := TNetPcAddHandle.Create( PcID );
  NetPcAddHandle.SetPcName( PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

procedure TPcOnlineMsgBase.AddOnlineJob;
var
  TransferOnlineJobInfo : TTransferJobOnlineInfo;
begin
  TransferOnlineJobInfo := TTransferJobOnlineInfo.Create;
  TransferOnlineJobInfo.SetOnlinePcID( PcID );
  TransferOnlineJobInfo.SetJobType( JobType_All );
  MyJobInfo.AddChange( TransferOnlineJobInfo );
end;

procedure TPcOnlineMsgBase.CheckPcBatRegister;
var
  PcBatRegisterOnlineInfo : TPcBatRegisterOnlineInfo;
begin
  PcBatRegisterOnlineInfo := TPcBatRegisterOnlineInfo.Create( PcID );
  MyBatRegisterInfo.AddChange( PcBatRegisterOnlineInfo );
end;

procedure TPcOnlineMsgBase.CloudFileScan;
var
  CloudPathOnlineScanHandle : TCloudPathOnlineScanHandle;
begin
  CloudPathOnlineScanHandle := TCloudPathOnlineScanHandle.Create;
  CloudPathOnlineScanHandle.SetOnlinePcID( PcID );
  CloudPathOnlineScanHandle.Update;
  CloudPathOnlineScanHandle.Free;
end;

procedure TPcOnlineMsgBase.NetPcOnlineBackup;
begin
    // 本机上线不检测备份
  if PcID = Network_LocalPcID then
    Exit;

    // Pc 上线至少分隔 5秒
  if SecondsBetween( Now, Time_LastOnlineBackup ) < 5 then
    Exit;
  Time_LastOnlineBackup := Now;

    // 执行同步检测
  MyBackupFileControl.PcOnlineSync;
end;

procedure TPcOnlineMsgBase.SetPcCloudConfigMsg;
begin
  PcCloudMsgUtil.setConfigMsg( PcCloudConfigMsgStr );
end;

procedure TPcOnlineMsgBase.SendFileRemove;
var
  BackupRemoveNotifyPcOnlineHandle : TBackupRemoveNotifyPcOnlineHandle;
begin
    // Source File Remove
  BackupRemoveNotifyPcOnlineHandle := TBackupRemoveNotifyPcOnlineHandle.Create( PcID );
  BackupRemoveNotifyPcOnlineHandle.Update;
  BackupRemoveNotifyPcOnlineHandle.Free;
end;

procedure TPcOnlineMsgBase.SendIsShareFile;
var
  IsShareFile : Boolean;
  ClientSendIsShareMsg : TClientSendIsShareMsg;
begin
  IsShareFile := MySharePathInfoReadUtil.ReadIsExistShare;

  ClientSendIsShareMsg := TClientSendIsShareMsg.Create;
  ClientSendIsShareMsg.SetPcID( PcInfo.PcID );
  ClientSendIsShareMsg.SetPcName( PcInfo.PcName );
  ClientSendIsShareMsg.SetIsShareFile( IsShareFile );
  MyClient.SendMsgToPc( PcID, ClientSendIsShareMsg );
end;

procedure TPcOnlineMsgBase.SetFileRestore;
var
  VstRestoreDownLocationOnline : TVstRestoreDownLocationOnline;
begin
  VstRestoreDownLocationOnline := TVstRestoreDownLocationOnline.Create;
  VstRestoreDownLocationOnline.SetOnlinePcID( PcID );
  MyRestoreFileFace.AddChange( VstRestoreDownLocationOnline );
end;

procedure TPcOnlineMsgBase.SetFileSearch;
var
  VstSearchDownLocationOnline : TVstSearchDownLocationOnline;
begin
  VstSearchDownLocationOnline := TVstSearchDownLocationOnline.Create;
  VstSearchDownLocationOnline.SetOnlinePcID( PcID );
  MySearchFileFace.AddChange( VstSearchDownLocationOnline );
end;

procedure TPcOnlineMsgBase.SetFileShare;
var
  ShareDownFilePcIsOnlineHandle : TShareDownFilePcIsOnlineHandle;
  ShareHistoryPcOnlineHandle : TShareHistoryPcOnlineHandle;
  ShareFavorityPcOnlineHandle : TShareFavorityPcOnlineHandle;
begin
    // Share Down
  ShareDownFilePcIsOnlineHandle := TShareDownFilePcIsOnlineHandle.Create( PcID );
  ShareDownFilePcIsOnlineHandle.SetIsOnline( True );
  ShareDownFilePcIsOnlineHandle.Update;
  ShareDownFilePcIsOnlineHandle.Free;

    // Share History
  ShareHistoryPcOnlineHandle := TShareHistoryPcOnlineHandle.Create( PcID );
  ShareHistoryPcOnlineHandle.SetIsOnline( True );
  ShareHistoryPcOnlineHandle.Update;
  ShareHistoryPcOnlineHandle.Free;

    // Share Favorite
  ShareFavorityPcOnlineHandle := TShareFavorityPcOnlineHandle.Create( PcID );
  ShareFavorityPcOnlineHandle.SetIsOnline( True );
  ShareFavorityPcOnlineHandle.Update;
  ShareFavorityPcOnlineHandle.Free;
end;

procedure TPcOnlineMsgBase.SetFileTransfer;
var
  SendFilePcOnlineHandle : TSendFilePcOnlineHandle;
  ReceiveFileOnlineHandle : TReceiveFileOnlineHandle;
begin
    // 发送文件
  SendFilePcOnlineHandle := TSendFilePcOnlineHandle.Create( PcID );
  SendFilePcOnlineHandle.Update;
  SendFilePcOnlineHandle.Free;

    // 接收文件
  ReceiveFileOnlineHandle := TReceiveFileOnlineHandle.Create( PcID );
  ReceiveFileOnlineHandle.SetIsOnline( True );
  ReceiveFileOnlineHandle.Update;
  ReceiveFileOnlineHandle.Free;
end;

procedure TPcOnlineMsgBase.SetNetPcOnline;
var
  PcCloudBaseMsg : TPcCloudBaseMsg;
  PcName : string;
  NetPcOnlineHandle : TNetPcOnlineHandle;
begin
  PcCloudBaseMsg := TPcCloudBaseMsg.Create;
  PcCloudBaseMsg.SetMsgStr( PcCloudBaseMsgStr );
  PcName := PcCloudBaseMsg.PcName;
  PcCloudBaseMsg.Free;

  NetPcOnlineHandle := TNetPcOnlineHandle.Create( PcID );
  NetPcOnlineHandle.SetPcName( PcName );
  NetPcOnlineHandle.Update;
  NetPcOnlineHandle.Free;
end;

procedure TPcOnlineMsgBase.SetPcCloudBaseMsg;
begin
  PcCloudMsgUtil.setBaseMsg( PcCloudBaseMsgStr );
end;

procedure TPcOnlineMsgBase.SetPcCloudBaseMsgStr(_PcCloudBaseMsgStr: string);
begin
  PcCloudBaseMsgStr := _PcCloudBaseMsgStr;
end;

procedure TPcOnlineMsgBase.SetPcCloudConfigMsgStr(_PcCloudConfigMsgStr: string);
begin
  PcCloudConfigMsgStr := _PcCloudConfigMsgStr;
end;

procedure TPcOnlineMsgBase.SetPcCloudOnlineMsg;
begin
  PcCloudMsgUtil.setOnlineTimeMsg( PcCloudOnlineMsgStr );
end;

procedure TPcOnlineMsgBase.SetPcCloudOnlineMsgStr(_PcCloudOnlineMsgStr: string);
begin
  PcCloudOnlineMsgStr := _PcCloudOnlineMsgStr;
end;

procedure TPcOnlineMsgBase.SetPcCloudBackupPathMsg;
begin
  PcCloudMsgUtil.setBackupPathMsg( PcCloudBackupPathMsgStr );
end;

procedure TPcOnlineMsgBase.SetPcCloudBackupPathMsgStr(
  _PcCloudBackupPathMsgStr: string);
begin
  PcCloudBackupPathMsgStr := _PcCloudBackupPathMsgStr;
end;

procedure TPcOnlineMsgBase.SetPcCloudSpaceMsg;
begin
  PcCloudMsgUtil.setSpaceMsg( PcCloudSpaceMsgStr );
end;

procedure TPcOnlineMsgBase.SetPcCloudSpaceMsgStr(_PcCloudSpaceMsgStr: string);
begin
  PcCloudSpaceMsgStr := _PcCloudSpaceMsgStr;
end;

procedure TPcOnlineMsgBase.Update;
begin
    // Online 处理
  AddNetworkPc;
  SetNetPcOnline;
  AddOnlineJob;
  CheckPcBatRegister;
  SendFileRemove;

    // Pc 上线 其他功能 变化
  SetFileRestore;
  SetFileSearch;
  SetFileTransfer;
  SetFileShare;
  SendIsShareFile;

    // 云信息 更新
  SetPcCloudOnlineMsg;
  SetPcCloudBaseMsg;
  SetPcCloudSpaceMsg;
  SetPcCloudConfigMsg;
  SetPcCloudBackupPathMsg;

    // 启动备份
  NetPcOnlineBackup;
  CloudFileScan;
end;

{ TPcMsgBase }

procedure TPcMsgBase.SetPcID(_PcID: string);
begin
  PcID := _PcID;
end;

{ TPcAddPendFileFaceMsg }

procedure TPcAddPendFileMsg.SetFileInfo(_Position, _FileSize: Int64);
begin
  Position := _Position;
  FileSize := _FileSize;
end;


{ TPcAddDownPendBackupFileFaceMsg }

function TPcAddDownPendBackupFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_DownBackup;
end;

procedure TPcAddDownPendBackupFileMsg.Update;
var
  PcName : string;
  Percentage : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
  NetPcAddPendingSpaceHandle : TNetPcAddPendingSpaceHandle;
begin
    // TTransStatus 界面显示
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Percentage := MyPercentage.getPercent( Position, FileSize );
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_DownPend );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( FileType_Backup, FileStatus_Waiting );
  MyJobFace.AddChange( VirTransferChildAddInfo );

    // 添加 Pc占用 Pending 空间信息
  NetPcAddPendingSpaceHandle := TNetPcAddPendingSpaceHandle.Create( PcID );
  NetPcAddPendingSpaceHandle.SetBackupPendingSpace( FileSize );
  NetPcAddPendingSpaceHandle.Update;
  NetPcAddPendingSpaceHandle.Free;
end;


{ TPcAddUpPendFileFaceMsg }

procedure TPcAddUpPendFileMsg.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TPcAddUpPendSearchFileFaceMsg }

function TPcAddUpPendSearchFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_UpSearch;
end;

procedure TPcAddUpPendSearchFileMsg.Update;
var
  PcName : string;
  Percentage : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Percentage := MyPercentage.getPercent( Position, FileSize );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_UpPend );
  VirTransferChildAddInfo.SetChildID( PcID, FilePath );
  VirTransferChildAddInfo.SetFileBase( FilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( FileType_Search, FileStatus_Waiting );

  MyJobFace.AddChange( VirTransferChildAddInfo );
end;


{ TPcJobMsgFactory }

constructor TPcAddPendFileMsgFactory.Create;
begin
  inherited Create( MsgType_PcAddPend );
end;

function TPcAddPendFileMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_PcAddPend_DownBackup then
    Result := TPcAddDownPendBackupFileMsg.Create
  else
  if MsgType = MsgType_PcAddPend_DownTransfer then
    Result := TPcAddDownPendTransferFileMsg.Create
  else
  if MsgType = MsgType_PcAddPend_UpSearch then
    Result := TPcAddUpPendSearchFileMsg.Create
  else
  if MsgType = MsgType_PcAddPend_UpRestore then
    Result := TPcAddUpPendRestoreFileMsg.Create
  else
  if MsgType = MsgType_PcAddPend_RemoveDownPend then
    Result := TPcRemoveDownPendFileMsg.Create
  else
  if MsgType = MsgType_PcAddPend_RemoveUpPend then
    Result := TPcRemoveUpPendFileMsg.Create
  else
    Result := nil;
end;

{ TPcAddUpPendRestoreFileMsg }

function TPcAddUpPendRestoreFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_UpRestore;
end;

procedure TPcAddUpPendRestoreFileMsg.Update;
var
  PcName : string;
  Percentage : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Percentage := MyPercentage.getPercent( Position, FileSize );

  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_UpPend );
  VirTransferChildAddInfo.SetChildID( PcID, FilePath );
  VirTransferChildAddInfo.SetFileBase( FilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( FileTYpe_Restore, FileStatus_Waiting );

  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

{ TFileSearchMsg }

procedure TFileSearchReqMsg.SetSearchFileName(_SearchFileName: string);
begin
  SearchFileName := _SearchFileName;
end;

{ TFileSearchResultBaseMsg }

procedure TFileSearchResultBaseMsg.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TFileSearchResultBaseMsg.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TFileSearchResultBaseMsg.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

{ TFileSearchBackupResultMsg }

function TBackupFileSearchResultMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ResultBackupCopy;
end;

procedure TBackupFileSearchResultMsg.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

procedure TBackupFileSearchResultMsg.Update;
var
  SearchBackupCopyFileResultinfo : TBackupFileSearchResultinfo;
begin
  SearchBackupCopyFileResultinfo := TBackupFileSearchResultinfo.Create;
  SearchBackupCopyFileResultinfo.SetSearchNum( SearchNum );
  SearchBackupCopyFileResultinfo.SetLocationID( PcID );
  SearchBackupCopyFileResultinfo.SetFilePath( FilePath );
  SearchBackupCopyFileResultinfo.SetFileInfo( FileSize, FileTime );
  SearchBackupCopyFileResultinfo.SetOwnerID( OwnerID );
  MyFileSearchReq.AddChange( SearchBackupCopyFileResultinfo );
end;

{ TBackupCopyFileSearchReqMsg }

function TBackupFileSearchReqMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ReqBackupCopy;
end;

procedure TBackupFileSearchReqMsg.SetFileOwnerList(FileOwnerList: TStringList);
var
  i : Integer;
  FileOwner : string;
begin
  for i := 0 to FileOwnerList.Count - 1 do
  begin
    FileOwner := FileOwnerList[i];
    FileOwnerListStr := MsgUtil.AddMsg( FileOwnerListStr, FileOwner );
  end;
end;

procedure TBackupFileSearchReqMsg.Update;
var
  BackupPcIDList : TStringList;
  BackupFileScanStartInfo : TBackupFileScanStartInfo;
begin
  BackupPcIDList := MsgUtil.getMsgList( FileOwnerListStr );

    // 添加到 搜索队列
  BackupFileScanStartInfo := TBackupFileScanStartInfo.Create;
  BackupFileScanStartInfo.SetSearchPcID( PcID );
  BackupFileScanStartInfo.SetBackupPcIDList( BackupPcIDList );
  BackupFileScanStartInfo.SetSearchNum( SeaarchNum );
  BackupFileScanStartInfo.SetSearchName( SearchFileName );
  MyFileSearchScan.AddChange( BackupFileScanStartInfo );

  BackupPcIDList.Free;
end;

{ TSourceFileSearchReqMsg }

function TSourceFileSearchReqMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ReqSource;
end;

procedure TSourceFileSearchReqMsg.Update;
var
  ScanSourceFileChangeInfo : TSourceFileScanStartInfo;
begin
    // 添加到搜索队列
  ScanSourceFileChangeInfo := TSourceFileScanStartInfo.Create;
  ScanSourceFileChangeInfo.SetSearchPcID( PcID );
  ScanSourceFileChangeInfo.SetSearchNum( SeaarchNum );
  ScanSourceFileChangeInfo.SetSearchName( SearchFileName );
  MyFileSearchScan.AddChange( ScanSourceFileChangeInfo );
end;

{ TFileSearchSourceResultMsg }

function TSourceFileSearchResultMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ResultSource;
end;

procedure TSourceFileSearchResultMsg.Update;
var
  SearchSourceFileResultInfo : TSourceFileSearchResultInfo;
begin
  SearchSourceFileResultInfo := TSourceFileSearchResultInfo.Create;
  SearchSourceFileResultInfo.SetSearchNum( SearchNum );
  SearchSourceFileResultInfo.SetLocationID( PcID );
  SearchSourceFileResultInfo.SetFilePath( FilePath );
  SearchSourceFileResultInfo.SetFileInfo( FileSize, FileTime );
  MyFileSearchReq.AddChange( SearchSourceFileResultInfo );
end;

{ TFileSearchMsgFactory }

constructor TFileSearchMsgFactory.Create;
begin
  inherited Create( MsgType_PcSearch );
end;

function TFileSearchMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_PcSearch_ReqSource then
    Result := TSourceFileSearchReqMsg.Create
  else
  if MsgType = MsgType_PcSearch_ReqBackupCopy then
    Result := TBackupFileSearchReqMsg.Create
  else
  if MsgType = MsgType_PcSearch_ResultSource then
    Result := TSourceFileSearchResultMsg.Create
  else
  if MsgType = MsgType_PcSearch_ResultBackupCopy then
    Result := TBackupFileSearchResultMsg.Create
  else
  if MsgType = MsgType_PcSearch_StopSource then
    Result := TSourceFileSearchCompleteMsg.Create
  else
  if MsgType = MsgType_PcSearch_StopBackupCopy then
    Result := TBackupCopyFileSearchCompleteMsg.Create
  else
  if MsgType = MsgType_PcSearch_CancelSearch then
    Result := TFileSearchCancelMsg.Create
  else
  if MsgType = MsgType_PcSearch_ReqRestore then
    Result := TRestoreFileSearchReqMsg.Create
  else
  if MsgType = MsgType_PcSearch_ResultRestore then
    Result := TReStoreFileSearchResultMsg.Create
  else
  if MsgType = MsgType_PcSearch_StopRestore then
    Result := TRestoreFileSearchCompleteMsg.Create
  else
  if MsgType = MsgType_PcSearch_CancelRestore then
    Result := TRestoreSearchCancelMsg.Create
  else
    Result := nil;
end;

{ TSourceFileSearchStopMsg }

function TSourceFileSearchCompleteMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_StopSource;
end;

procedure TSourceFileSearchCompleteMsg.Update;
var
  FileSearchSourceStopInfo : TSourceFileSearchCompleteInfo;
begin
  FileSearchSourceStopInfo := TSourceFileSearchCompleteInfo.Create( PcID );
  MyFileSearchReq.AddChange( FileSearchSourceStopInfo );
end;

{ TBackupCopyFileSearchStopMsg }

function TBackupCopyFileSearchCompleteMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_StopBackupCopy;
end;

procedure TBackupCopyFileSearchCompleteMsg.Update;
var
  FileSearchBackupCopyStopInfo : TBackupFileSearchCompleteInfo;
begin
  FileSearchBackupCopyStopInfo := TBackupFileSearchCompleteInfo.Create( PcID );
  MyFileSearchReq.AddChange( FileSearchBackupCopyStopInfo );
end;

{ TFileSearchCancelMsg }

function TFileSearchCancelMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_CancelSearch;
end;

procedure TFileSearchCancelMsg.Update;
var
  FileSearchCancelInfo : TFileSearchCancelInfo;
begin
  FileSearchCancelInfo := TFileSearchCancelInfo.Create( PcID );
  MyFileSearchScan.AddChange( FileSearchCancelInfo );
end;

{ TSendServerMsgThread }

constructor TSendServerMsgThread.Create;
begin
  inherited Create( True );
end;

destructor TSendServerMsgThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;
  inherited;
end;

procedure TSendServerMsgThread.Execute;
var
  MsgStr : string;
begin
  while not Terminated do
  begin
    MsgStr := getNextMsg;
    if MsgStr = '' then
    begin
      if not Terminated then
        Suspend;
      Continue;
    end;
    SendMsg( MsgStr );
  end;

  inherited;
end;

function TSendServerMsgThread.getNextMsg: string;
var
  SendMsgList : TStringList;
begin
  MyClient.MsgLock.Enter;
  SendMsgList := MyClient.SendMsgList;
  if SendMsgList.Count > 0 then
  begin
    Result := SendMsgList[0];
    SendMsgList.Delete(0);
  end
  else
    Result := '';
  MyClient.MsgLock.Leave;
end;

procedure TSendServerMsgThread.SendMsg(MsgStr: string);
begin
  MySocketUtil.SendString( TcpSocket, MsgStr );
end;

procedure TSendServerMsgThread.SetTcpSocket(_TcpSocket: TCustomIpClient);
begin
  TcpSocket := _TcpSocket;
end;

{ TPcHearBeatMsg }

function TPcCloudSpaceMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_CloudSpace;
end;

procedure TPcCloudSpaceMsg.SetBackupSpace(_BackupSpace: Int64);
begin
  BackupSpace := _BackupSpace;
end;

procedure TPcCloudSpaceMsg.SetSpace(_UsedSpace, _TotalSpace: Int64);
begin
  UsedSpace := _UsedSpace;
  TotalSpace := _TotalSpace;
end;

procedure TPcCloudSpaceMsg.Update;
var
  NetPcSpaceSetHandle : TNetPcSpaceSetHandle;
begin
  NetPcSpaceSetHandle := TNetPcSpaceSetHandle.Create( PcID );
  NetPcSpaceSetHandle.SetSpace( UsedSpace, TotalSpace );
  NetPcSpaceSetHandle.SetBackupSpace( BackupSpace );
  NetPcSpaceSetHandle.Update;
  NetPcSpaceSetHandle.Free;
end;

{ TPcHeartBeatMsgFactory }

constructor TRefreshCloudPcMsgFactory.Create;
begin
  inherited Create( MsgType_CloudPc );
end;

function TRefreshCloudPcMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_CloudPc_RefreshClient then
    Result := TRefreshClientCloudPcMsg.Create
  else
  if MsgType = MsgType_CloudPc_RefreshServer then
    Result := TRefreshServerCloudPcMsg.Create
  else
  if MsgType = MsgType_CloudPc_RefreshBackupPath then
    Result := TRefreshCloudBackupPathMsg.Create
  else
  if MsgType = MsgType_CloudPc_OnlineTime then
    Result := TPcCloudOnlineTimeMsg.Create
  else
  if MsgType = MsgType_CloudPc_CloudSpace then
    Result := TPcCloudSpaceMsg.Create
  else
  if MsgType = MsgType_CloudPc_CloudConfig then
    Result := TPcCloudConfigMsg.Create
  else
  if MsgType = MsgType_CloudPc_BatRegister then
    Result := TPcBatRegisterMsg.Create
  else
    Result := nil;
end;

{ TPcNetInfoMsg }

function TPcCloudConfigMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_CloudConfig;
end;

procedure TPcCloudConfigMsg.SetCopyCount(_CopyCount: Integer);
begin
  CopyCount := _CopyCount;
end;

procedure TPcCloudConfigMsg.SetFileInvisible(_IsFileInvisible: Boolean);
begin
  IsFileInvisible := _IsFileInvisible;
end;

procedure TPcCloudConfigMsg.SetIvPasswordMD5(_IvPasswordMD5: string);
begin
  IvPasswordMD5 := _IvPasswordMD5;
end;

procedure TPcCloudConfigMsg.SetRegisterEdition(_RegisterEdition,
  _RegisterHardCode: string);
begin
  RegisterEdition := _RegisterEdition;
  RegisterHardCode := _RegisterHardCode;
end;

procedure TPcCloudConfigMsg.Update;
var
  NetPcConfigSetHandle : TNetPcConfigSetHandle;
begin
  NetPcConfigSetHandle := TNetPcConfigSetHandle.Create( PcID );
  NetPcConfigSetHandle.SetCopyCount( CopyCount );
  NetPcConfigSetHandle.SetRegisterEdition( RegisterEdition, RegisterHardCode );
  NetPcConfigSetHandle.SetFileInvisible( IsFileInvisible );
  NetPcConfigSetHandle.SetIvPasswordMD5( IvPasswordMD5 );
  NetPcConfigSetHandle.Update;
  NetPcConfigSetHandle.Free;
end;

{ TPcCloudInfoBaseMsg }

function TPcCloudOnlineTimeMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_OnlineTime;
end;

procedure TPcCloudOnlineTimeMsg.SetOnlineTime(_LastOnlineTime: TDateTime);
begin
  LastOnlineTime := _LastOnlineTime;
end;

{ TRefreshCloudPcMsg }

function TRefreshCloudPcBaseMsg.CheckPcIsUpdate: Boolean;
var
  PcCloudOnlineTimeMsg : TPcCloudOnlineTimeMsg;
  LastOnlineTime : TDateTime;
  NetPcInfoHash : TNetPcInfoHash;
begin
  PcCloudOnlineTimeMsg := TPcCloudOnlineTimeMsg.Create;
  PcCloudOnlineTimeMsg.SetMsgStr( PcCloudOnlineTimeMsgStr );
  LastOnlineTime := PcCloudOnlineTimeMsg.LastOnlineTime;
  PcCloudOnlineTimeMsg.Free;

  Result := False;
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  if not NetPcInfoHash.ContainsKey( CloudPcID ) or
     ( not NetPcInfoHash[ CloudPcID ].IsOnline and
       ( NetPcInfoHash[ CloudPcID ].LastOnlineTime < LastOnlineTime )
     )
  then
    Result := True;
  MyNetPcInfo.LeaveData;
end;

procedure TRefreshCloudPcBaseMsg.SetCloudBackupPathInfo;
var
  RefreshCloudBackupPathMsg : TRefreshCloudBackupPathMsg;
begin
  RefreshCloudBackupPathMsg := TRefreshCloudBackupPathMsg.Create;
  RefreshCloudBackupPathMsg.SetMsgStr( PcCloudBackupPathMsgStr );
  RefreshCloudBackupPathMsg.Update;
  RefreshCloudBackupPathMsg.Free;
end;

procedure TRefreshCloudPcBaseMsg.SetCloudConfigInfo;
begin
  PcCloudMsgUtil.setConfigMsg( PcCloudConfigMsgStr );
end;

procedure TRefreshCloudPcBaseMsg.SetCloudConfigMsgStr(_PcCloudConfigMsgStr: string);
begin
  PcCloudConfigMsgStr := _PcCloudConfigMsgStr;
end;

procedure TRefreshCloudPcBaseMsg.SetCloudOnlineInfo;
begin
  PcCloudMsgUtil.setOnlineTimeMsg( PcCloudOnlineTimeMsgStr );
end;

procedure TRefreshCloudPcBaseMsg.SetCloudPcBaseInfo;
var
  NetPcAddCloudHandle : TNetPcAddCloudHandle;
begin
  NetPcAddCloudHandle := TNetPcAddCloudHandle.Create( CloudPcID );
  NetPcAddCloudHandle.SetPcName( CloudPcName );
  NetPcAddCloudHandle.Update;
  NetPcAddCloudHandle.Free;
end;

procedure TRefreshCloudPcBaseMsg.SetCloudSpaceInfo;
begin
  PcCloudMsgUtil.setSpaceMsg( PcClousSpaceMsgStr );
end;

procedure TRefreshCloudPcBaseMsg.SetPcCloudBackupPathMsgStr(
  _PcCloudBackupPathMsgStr: string);
begin
  PcCloudBackupPathMsgStr := _PcCloudBackupPathMsgStr;
end;

procedure TRefreshCloudPcBaseMsg.SetPcCloudOnlineTimeMsgStr(
  _PcCloudOnlineTimeMsgStr: string);
begin
  PcCloudOnlineTimeMsgStr := _PcCloudOnlineTimeMsgStr;
end;

procedure TRefreshCloudPcBaseMsg.SetPcCloudSpaceMsgStr(_PcClousSpaceMsgStr: string);
begin
  PcClousSpaceMsgStr := _PcClousSpaceMsgStr;
end;

procedure TRefreshCloudPcBaseMsg.SetCloudPcInfo(_CloudPcID, _CloudPcName: string);
begin
  CloudPcID := _CloudPcID;
  CloudPcName := _CloudPcName;
end;

procedure TRefreshCloudPcBaseMsg.Update;
begin
  IsUpdate := False;
  if ( CloudPcID = '' ) or not CheckPcIsUpdate then
    Exit;

  SetCloudPcBaseInfo;
  SetCloudOnlineInfo;
  SetCloudSpaceInfo;
  SetCloudConfigInfo;
  SetCloudBackupPathInfo;

  IsUpdate := True;
end;

{ TPcCloudBaseMsg }

procedure TPcCloudBaseMsg.AddNetworkPc;
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( PcID );
  NetPcAddHandle.SetPcName( PcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

procedure TPcCloudBaseMsg.CheckNetPcReach;
var
  InternetConnSendReachMsg : TInternetConnSendReachMsg;
begin
  InternetConnSendReachMsg := TInternetConnSendReachMsg.Create;
  InternetConnSendReachMsg.SetRemotePcID( PcID );
  InternetConnSendReachMsg.SetRemoteLanSocket( LanIp, LanPort );
  InternetConnSendReachMsg.SetRemoteInternetSocket( InternetIp, InternetPort );
  MyMasterConn.AddChange( InternetConnSendReachMsg );
end;

procedure TPcCloudBaseMsg.SetInternetSokcet(_InternetIp, _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TPcCloudBaseMsg.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TPcCloudBaseMsg.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TPcCloudBaseMsg.Update;
begin
  AddNetworkPc;

  CheckNetPcReach;
end;

procedure TPcCloudOnlineTimeMsg.Update;
var
  NetPcLastOnlineTimeSetHandle : TNetPcLastOnlineTimeSetHandle;
begin
  NetPcLastOnlineTimeSetHandle := TNetPcLastOnlineTimeSetHandle.Create( PcID );
  NetPcLastOnlineTimeSetHandle.SetLastOnlineTime( LastOnlineTime );
  NetPcLastOnlineTimeSetHandle.Update;
  NetPcLastOnlineTimeSetHandle.Free;
end;

{ CloudMsgUtil }

class function PcCloudMsgUtil.getBackupPathMsg: string;
var
  FindBackupPathMsg : TFindBackupPathMsg;
begin
  FindBackupPathMsg := TFindBackupPathMsg.Create;
  Result := FindBackupPathMsg.get;
  FindBackupPathMsg.Free;
end;

class function PcCloudMsgUtil.getBaseMsg: string;
var
  PcCloudBaseMsg : TPcCloudBaseMsg;
begin
    // Pc 基本信息
  PcCloudBaseMsg := TPcCloudBaseMsg.Create;
  PcCloudBaseMsg.SetPcID( PcInfo.PcID );
  PcCloudBaseMsg.SetPcName( PcInfo.PcName );
  PcCloudBaseMsg.SetLanSocket( PcInfo.LanIp, PcInfo.LanPort );
  PcCloudBaseMsg.SetInternetSokcet( PcInfo.InternetIp, PcInfo.InternetPort );
  Result := PcCloudBaseMsg.getMsgStr;
  PcCloudBaseMsg.Free;
end;

class function PcCloudMsgUtil.getConfigMsg: string;
var
  IvPasswordMD5 : string;
  PcCloudConfigMsg : TPcCloudConfigMsg;
begin
  IvPasswordMD5 := MyEncrypt.EncodeMD5String( FileVisibleSettingInfo.RestorePassword );

  PcCloudConfigMsg := TPcCloudConfigMsg.Create;
  PcCloudConfigMsg.SetPcID( PcInfo.PcID );
  PcCloudConfigMsg.SetFileInvisible( FileVisibleSettingInfo.IsFileInvisible );
  PcCloudConfigMsg.SetIvPasswordMD5( IvPasswordMD5 );
  PcCloudConfigMsg.SetRegisterEdition( RegisterInfo.RegisterEditon, PcInfo.PcHardCode );
  PcCloudConfigMsg.SetCopyCount( BackupFileSafeSettingInfo.CopyCount );
  Result := PcCloudConfigMsg.getMsgStr;
  PcCloudConfigMsg.Free;
end;

class function PcCloudMsgUtil.getOnlineTimeMsg: string;
var
  PcCloudOnlineTimeMsg : TPcCloudOnlineTimeMsg;
begin
    // 上线时间
  PcCloudOnlineTimeMsg := TPcCloudOnlineTimeMsg.Create;
  PcCloudOnlineTimeMsg.SetPcID( PcInfo.PcID );
  PcCloudOnlineTimeMsg.SetOnlineTime( Now );
  Result := PcCloudOnlineTimeMsg.getMsgStr;
  PcCloudOnlineTimeMsg.Free;
end;

class function PcCloudMsgUtil.getSpaceMsg: string;
var
  PcCloudSpaceMsg : TPcCloudSpaceMsg;
  UsedSpace, TotalSpace, BackupSpace : Int64;
begin
  UsedSpace := MyCloudPathInfoUtil.ReadCloudTotalUserSpace;
  UsedSpace := UsedSpace + MyNetPcInfoReadUtil.ReadBackupPendingSpace;
  TotalSpace := ShareSettingInfo.getTotalSpace( UsedSpace );
  BackupSpace := MyBackupPathInfoUtil.ReadComsumpCloudSpace;

    // 云空间信息
  PcCloudSpaceMsg := TPcCloudSpaceMsg.Create;
  PcCloudSpaceMsg.SetPcID( PcInfo.PcID );
  PcCloudSpaceMsg.SetSpace( UsedSpace, TotalSpace );
  PcCloudSpaceMsg.SetBackupSpace( BackupSpace );
  Result := PcCloudSpaceMsg.getMsgStr;
  PcCloudSpaceMsg.Free;
end;

class procedure PcCloudMsgUtil.setBackupPathMsg(MsgStr: string);
var
  RefreshCloudBackupPathMsg : TRefreshCloudBackupPathMsg;
begin
  RefreshCloudBackupPathMsg := TRefreshCloudBackupPathMsg.Create;
  RefreshCloudBackupPathMsg.SetMsgStr( MsgStr );
  RefreshCloudBackupPathMsg.Update;
  RefreshCloudBackupPathMsg.Free;
end;

class procedure PcCloudMsgUtil.setBaseMsg(MsgStr: string);
var
  PcCloudBaseMsg : TPcCloudBaseMsg;
begin
  PcCloudBaseMsg := TPcCloudBaseMsg.Create;
  PcCloudBaseMsg.SetMsgStr( MsgStr );
  PcCloudBaseMsg.Update;
  PcCloudBaseMsg.Free;
end;

class procedure PcCloudMsgUtil.setConfigMsg(MsgStr: string);
var
  PcCloudConfigMsg : TPcCloudConfigMsg;
begin
  PcCloudConfigMsg := TPcCloudConfigMsg.Create;
  PcCloudConfigMsg.SetMsgStr( MsgStr );
  PcCloudConfigMsg.Update;
  PcCloudConfigMsg.Free;
end;

class procedure PcCloudMsgUtil.setOnlineTimeMsg(MsgStr: string);
var
  PcCloudOnlineMsg : TPcCloudOnlineTimeMsg;
begin
  PcCloudOnlineMsg := TPcCloudOnlineTimeMsg.Create;
  PcCloudOnlineMsg.SetMsgStr( MsgStr );
  PcCloudOnlineMsg.Update;
  PcCloudOnlineMsg.Free;
end;

class procedure PcCloudMsgUtil.setSpaceMsg(MsgStr: string);
var
  PcCloudSpaceMsg : TPcCloudSpaceMsg;
begin
  PcCloudSpaceMsg := TPcCloudSpaceMsg.Create;
  PcCloudSpaceMsg.SetMsgStr( MsgStr );
  PcCloudSpaceMsg.Update;
  PcCloudSpaceMsg.Free;
end;

{ TRefreshServerCloudPcMsg }

function TRefreshServerCloudPcMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_RefreshServer;
end;

procedure TRefreshServerCloudPcMsg.SendToOtherClinet;
var
  RefreshClientCloudPcMsg : TRefreshClientCloudPcMsg;
begin
  RefreshClientCloudPcMsg := TRefreshClientCloudPcMsg.Create;
  RefreshClientCloudPcMsg.SetCloudPcInfo( CloudPcID, CloudPcName );
  RefreshClientCloudPcMsg.SetPcCloudOnlineTimeMsgStr( PcCloudOnlineTimeMsgStr );
  RefreshClientCloudPcMsg.SetPcCloudSpaceMsgStr( PcClousSpaceMsgStr );
  RefreshClientCloudPcMsg.SetCloudConfigMsgStr( PcCloudConfigMsgStr );
  RefreshClientCloudPcMsg.SetPcCloudBackupPathMsgStr( PcCloudBackupPathMsgStr );

  MyClient.SendMsgToAll( RefreshClientCloudPcMsg );
end;

procedure TRefreshServerCloudPcMsg.Update;
begin
  inherited;

  if IsUpdate then
    SendToOtherClinet;
end;

{ TRefreshClientCloudPcMsg }

function TRefreshClientCloudPcMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_RefreshClient;
end;

{ TClientSendRefreshPcInfo }

constructor TSendRefreshPcInfo.Create(_TargetPcID: string);
begin
  TargetPcID := _TargetPcID;
end;

procedure TSendRefreshPcInfo.Update;
var
  NetPcInfoHash : TNetPcInfoHash;
  p : TNetPcInfoPair;
  RefreshCloudPcBaseMsg : TRefreshCloudPcBaseMsg;
  FindCloudPcMsg : TFindCloudPcMsg;
  MsgStr : string;
begin
  MyNetPcInfo.EnterData;
  NetPcInfoHash := MyNetPcInfo.NetPcInfoHash;
  for p in NetPcInfoHash do
  begin
    if p.Value.IsOnline then
      Continue;

      // 刷新 云 Pc 命令
    RefreshCloudPcBaseMsg := getRefreshCloudPcBaseMsg;
    RefreshCloudPcBaseMsg.SetCloudPcInfo( p.Value.PcID, p.Value.PcName );

      // 找寻云Pc信息
    FindCloudPcMsg := TFindCloudPcMsg.Create( p.Value );
    MsgStr := FindCloudPcMsg.getPcCloudOnlineMsg;
    RefreshCloudPcBaseMsg.SetPcCloudOnlineTimeMsgStr( MsgStr );

    MsgStr := FindCloudPcMsg.getPcCloudSpaceMsg;
    RefreshCloudPcBaseMsg.SetPcCloudSpaceMsgStr( MsgStr );

    MsgStr := FindCloudPcMsg.getPcCloudConfigMsg;
    RefreshCloudPcBaseMsg.SetCloudConfigMsgStr( MsgStr );

    MsgStr := FindCloudPcMsg.getPcCloudBackupPathMsg;
    RefreshCloudPcBaseMsg.SetPcCloudBackupPathMsgStr( MsgStr );
    FindCloudPcMsg.Free;

      // 发送
    MyClient.SendMsgToPc( TargetPcID, RefreshCloudPcBaseMsg );
  end;
  MyNetPcInfo.LeaveData;
end;


{ TClientSendRefreshPcInfo }

function TClientSendRefreshPcInfo.getRefreshCloudPcBaseMsg: TRefreshCloudPcBaseMsg;
begin
  Result := TRefreshServerCloudPcMsg.Create;
end;

{ TFindCloudPcMsg }

constructor TFindCloudPcMsg.Create(_NetPcInfo: TNetPcInfo);
begin
  NetPcInfo := _NetPcInfo;
end;

function TFindCloudPcMsg.getPcCloudBackupPathMsg: string;
var
  PcCloudBackupPathRefreshMsg : TRefreshCloudBackupPathMsg;
  CloudBackupPathAddMsg : TCloudBackupPathAddMsg;
  NetPcBackupPathHash : TNetPcBackupPathHash;
  p : TNetPcBackupPathPair;
  MsgStr : string;
begin
  NetPcBackupPathHash := NetPcInfo.NetPcBackupPathHash;

      // 发送 所有本机的备份路径信息
  PcCloudBackupPathRefreshMsg := TRefreshCloudBackupPathMsg.Create;
  PcCloudBackupPathRefreshMsg.SetPcID( NetPcInfo.PcID );
  for p in NetPcBackupPathHash do
  begin
    CloudBackupPathAddMsg := TCloudBackupPathAddMsg.Create;
    CloudBackupPathAddMsg.SetPcID( NetPcInfo.PcID );
    CloudBackupPathAddMsg.SetPathInfo( p.Value.FullPath, p.Value.PathType );
    CloudBackupPathAddMsg.SetEncryptInfo( p.Value.IsEncrypt, p.Value.PasswordMD5, p.Value.PasswordHint );
    CloudBackupPathAddMsg.SetSpace( p.Value.FolderSpace );
    CloudBackupPathAddMsg.SetCountInfo( p.Value.FileCount, p.Value.CopyCount );
    MsgStr := CloudBackupPathAddMsg.getMsgStr;
    CloudBackupPathAddMsg.Free;

    PcCloudBackupPathRefreshMsg.AddBackupPathAddMsg( MsgStr );
  end;
  Result := PcCloudBackupPathRefreshMsg.getMsgStr;
  PcCloudBackupPathRefreshMsg.Free;
end;


function TFindCloudPcMsg.getPcCloudConfigMsg: string;
var
  PcCloudConfigMsg : TPcCloudConfigMsg;
begin
  PcCloudConfigMsg := TPcCloudConfigMsg.Create;
  PcCloudConfigMsg.SetPcID( NetPcInfo.PcID );
  PcCloudConfigMsg.SetFileInvisible( NetPcInfo.IsFileVisible );
  PcCloudConfigMsg.SetIvPasswordMD5( NetPcInfo.IvPasswordMD5 );
  PcCloudConfigMsg.SetRegisterEdition( NetPcInfo.RegisterEdition, NetPcInfo.RegisterHardCode );
  Result := PcCloudConfigMsg.getMsgStr;
  PcCloudConfigMsg.Free;
end;


function TFindCloudPcMsg.getPcCloudOnlineMsg: string;
var
  PcCloudOnlineTimeMsg : TPcCloudOnlineTimeMsg;
begin
  PcCloudOnlineTimeMsg := TPcCloudOnlineTimeMsg.Create;
  PcCloudOnlineTimeMsg.SetPcID( NetPcInfo.PcID );
  PcCloudOnlineTimeMsg.SetOnlineTime( NetPcInfo.LastOnlineTime );
  Result := PcCloudOnlineTimeMsg.getMsgStr;
  PcCloudOnlineTimeMsg.Free;
end;

function TFindCloudPcMsg.getPcCloudSpaceMsg: string;
var
  PcCloudSpaceMsg : TPcCloudSpaceMsg;
begin
    // 云空间信息
  PcCloudSpaceMsg := TPcCloudSpaceMsg.Create;
  PcCloudSpaceMsg.SetPcID( NetPcInfo.PcID );
  PcCloudSpaceMsg.SetSpace( NetPcInfo.UsedSpace, NetPcInfo.TotalSpace );
  PcCloudSpaceMsg.SetBackupSpace( NetPcInfo.BackupSpace );
  Result := PcCloudSpaceMsg.getMsgStr;
  PcCloudSpaceMsg.Free;
end;

{ TServerSendRefreshPcInfo }

function TServerSendRefreshPcInfo.getRefreshCloudPcBaseMsg: TRefreshCloudPcBaseMsg;
begin
  Result := TRefreshClientCloudPcMsg.Create;
end;

{ TClientHeartBeatThread }

constructor TClientHeartBeatThread.Create;
begin
  inherited Create( True );
end;

destructor TClientHeartBeatThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  inherited;
end;

procedure TClientHeartBeatThread.Execute;
var
  StartTime : TDateTime;
begin
  while not Terminated do
  begin
      // 五分钟发一次心跳
    IsUpgrade := False;
    StartTime := Now;
    while not Terminated and ( MinutesBetween( Now, StartTime ) < 5 ) and
          not IsUpgrade
    do
      Sleep(100);

      // 程序结束
    if Terminated then
      Break;

      // 未连接
    if not MyClient.TcpSocket.Connected then
      Continue;

      // 发送 在线信息
    SendLastOnline;

      // 发送 空间更新信息
    SendCloudSpace;

      // 发送 配置更新信息
    SendCloudConfig;

      // 发送 备份路径信息
    SendCloudBackupPath;
  end;

  inherited;
end;

procedure TClientHeartBeatThread.SendCloudBackupPath;
var
  MsgType, MsgStr, Msg : string;
begin
  MsgType := MsgType_CloudPc_RefreshBackupPath;
  MsgStr := PcCloudMsgUtil.getBackupPathMsg;
  Msg := MsgUtil.getMsg( MsgType, MsgStr );

  MyClient.SendMsgToAll( Msg );
end;

procedure TClientHeartBeatThread.SendCloudConfig;
var
  MsgType, MsgStr, Msg : string;
begin
  MsgType := MsgType_CloudPc_CloudConfig;
  MsgStr := PcCloudMsgUtil.getConfigMsg;
  Msg := MsgUtil.getMsg( MsgType, MsgStr );

  MyClient.SendMsgToAll( Msg );
end;

procedure TClientHeartBeatThread.SendCloudSpace;
var
  MsgType, MsgStr, Msg : string;
begin
  MsgType := MsgType_CloudPc_CloudSpace;
  MsgStr := PcCloudMsgUtil.getSpaceMsg;
  Msg := MsgUtil.getMsg( MsgType, MsgStr );

  MyClient.SendMsgToAll( Msg );
end;

procedure TClientHeartBeatThread.SendLastOnline;
var
  MsgType, MsgStr, Msg : string;
begin
  MsgType := MsgType_CloudPc_OnlineTime;
  MsgStr := PcCloudMsgUtil.getOnlineTimeMsg;
  Msg := MsgUtil.getMsg( MsgType, MsgStr );

  MyClient.SendMsgToAll( Msg );
end;

procedure TClientHeartBeatThread.UpgradeNow;
begin
  IsUpgrade := True;
end;

{ TRefreshBackupPathInfo }

constructor TRefreshCloudBackupPathInfo.Create;
begin
  NewBackupPathHash := TBackupPathList.Create;
end;

destructor TRefreshCloudBackupPathInfo.Destroy;
begin
  NewBackupPathHash.Free;
  inherited;
end;

procedure TRefreshCloudBackupPathInfo.ScanNewBackupPathHash;
var
  PcCloudBackupPathRefreshMsg : TRefreshCloudBackupPathMsg;
  CloudBackupPathAddMsg : TCloudBackupPathAddMsg;
  i : Integer;
  BackupPathInfo : TBackupPathInfo;
  PasswordMD5, MsgStr, SendMsgStr : string;
begin
    // 发送 所有本机的备份路径信息
  PcCloudBackupPathRefreshMsg := TRefreshCloudBackupPathMsg.Create;
  PcCloudBackupPathRefreshMsg.SetPcID( PcInfo.PcID );
  for i := 0 to NewBackupPathHash.Count - 1 do
  begin
    BackupPathInfo := NewBackupPathHash[i];
    PasswordMD5 := MyEncrypt.EncodeMD5String( BackupPathInfo.Password );

    CloudBackupPathAddMsg := TCloudBackupPathAddMsg.Create;
    CloudBackupPathAddMsg.SetPcID( PcInfo.PcID );
    CloudBackupPathAddMsg.SetPathInfo( BackupPathInfo.FullPath, BackupPathInfo.PathType );
    CloudBackupPathAddMsg.SetEncryptInfo( BackupPathInfo.IsEncrypt, PasswordMD5, BackupPathInfo.PasswordHint );
    CloudBackupPathAddMsg.SetSpace( BackupPathInfo.FolderSpace );
    CloudBackupPathAddMsg.SetCountInfo( BackupPathInfo.FileCount, BackupPathInfo.CopyCount );
    MsgStr := CloudBackupPathAddMsg.getMsgStr;
    CloudBackupPathAddMsg.Free;

    PcCloudBackupPathRefreshMsg.AddBackupPathAddMsg( MsgStr );
  end;
  SendMsgStr := PcCloudBackupPathRefreshMsg.getMsg;
  PcCloudBackupPathRefreshMsg.Free;

    // 添加到 发送缓冲
  MyClient.SendMsgToAll( SendMsgStr );
end;

procedure TRefreshCloudBackupPathInfo.FindNewBackupPathHash;
var
  FindBackupPathInfo : TFindBackupPathInfo;
begin
  FindBackupPathInfo := TFindBackupPathInfo.Create;
  FindBackupPathInfo.SetOutput( NewBackupPathHash );
  FindBackupPathInfo.Update;
  FindBackupPathInfo.Free;
end;

procedure TRefreshCloudBackupPathInfo.Update;
begin
  FindNewBackupPathHash;

  ScanNewBackupPathHash;
end;

{ TPcCloudBackupPathMsg }

procedure TRefreshCloudBackupPathMsg.AddBackupPathAddMsg(MsgStr: string);
begin
  BackupPathAddMsgList := MsgUtil.AddMsg( BackupPathAddMsgList, MsgStr );
end;

procedure TRefreshCloudBackupPathMsg.AddNewBackupPath;
var
  MsgList : TStringList;
  MsgStr : string;
  i : Integer;
  VstRestorePcClearLocation : TVstRestorePcClearLocation;
  VstRestorePcRefresh : TVstRestorePcRefresh;
  CloudBackupPathAddMsg : TCloudBackupPathAddMsg;
begin
    // 清空
  VstRestorePcClearLocation := TVstRestorePcClearLocation.Create( PcID );
  MyRestoreFileFace.AddChange( VstRestorePcClearLocation );

    // 添加
  MsgList := MsgUtil.getMsgList( BackupPathAddMsgList );
  ResetPcBackupItem( MsgList.Count );
  for i := 0 to MsgList.Count - 1 do
  begin
    MsgStr := MsgList[i];
    CloudBackupPathAddMsg := TCloudBackupPathAddMsg.Create;
    CloudBackupPathAddMsg.SetMsgStr( MsgStr );
    CloudBackupPathAddMsg.Update;
    CloudBackupPathAddMsg.Free;
  end;
  MsgList.Free;

    // 刷新
  VstRestorePcRefresh := TVstRestorePcRefresh.Create( PcID );
  MyRestoreFileFace.AddChange( VstRestorePcRefresh );
end;

procedure TRefreshCloudBackupPathMsg.ClearOldBackupPath;
var
  NetPcClearBackupPathHandle : TNetPcClearBackupPathHandle;
begin
  NetPcClearBackupPathHandle := TNetPcClearBackupPathHandle.Create( PcID );
  NetPcClearBackupPathHandle.Update;
  NetPcClearBackupPathHandle.Free;
end;

constructor TRefreshCloudBackupPathMsg.Create;
begin
  inherited;
  BackupPathAddMsgList := '';
end;

function TRefreshCloudBackupPathMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_RefreshBackupPath;
end;

procedure TRefreshCloudBackupPathMsg.ResetPcBackupItem(ItemCount: Integer);
var
  VstRestorePcSetItemCount : TVstRestorePcSetItemCount;
begin
  VstRestorePcSetItemCount := TVstRestorePcSetItemCount.Create( PcID );
  VstRestorePcSetItemCount.SetRestoreItemCount( ItemCount );
  MyRestoreFileFace.AddChange( VstRestorePcSetItemCount );
end;

procedure TRefreshCloudBackupPathMsg.Update;
begin
  ClearOldBackupPath;

  AddNewBackupPath;
end;

{ TCloudBackupPathAddMsg }

procedure TCloudBackupPathAddMsg.AddCopyOwner;
var
  CopyOwnerList : TStringList;
  i : Integer;
  CloudBackupPathOwnerAddMsg : TCloudBackupPathOwnerAddMsg;
  CopyOwnerMsgStr : string;
begin
  CopyOwnerList := MsgUtil.getLevelTwoMsgList( CopyOwnerAddMsgListMsg );
  for i := 0 to CopyOwnerList.Count - 1 do
  begin
    CopyOwnerMsgStr := CopyOwnerList[i];

    CloudBackupPathOwnerAddMsg := TCloudBackupPathOwnerAddMsg.Create;
    CloudBackupPathOwnerAddMsg.SetMsgStr( CopyOwnerMsgStr );
    CloudBackupPathOwnerAddMsg.Update;
    CloudBackupPathOwnerAddMsg.Free;
  end;
  CopyOwnerList.Free;
end;

procedure TCloudBackupPathAddMsg.AddCopyOwnerAddMsg(CopyOwnerAddMsg: string);
begin
  CopyOwnerAddMsgListMsg := MsgUtil.AddLevelTwoMsg( CopyOwnerAddMsgListMsg, CopyOwnerAddMsg );
end;

constructor TCloudBackupPathAddMsg.Create;
begin
  inherited;
  FileCount := 0;
  CopyCount := 0;
  CopyOwnerAddMsgListMsg := '';
end;

procedure TCloudBackupPathAddMsg.SetCountInfo(_FileCount, _CopyCount: Integer);
begin
  FileCount := _FileCount;
  CopyCount := _CopyCount;
end;

procedure TCloudBackupPathAddMsg.SetEncryptInfo(_IsEncrypt: Boolean;
  _PasswordMD5, _PasswordHint: string);
begin
  IsEncrypt := _IsEncrypt;
  PasswordMD5 := _PasswordMD5;
  PasswordHint := _PasswordHint;
end;

procedure TCloudBackupPathAddMsg.SetPathInfo(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

procedure TCloudBackupPathAddMsg.SetSpace(_FolderSpace: Int64);
begin
  FolderSpace := _FolderSpace;
end;

procedure TCloudBackupPathAddMsg.Update;
var
  NetPcAddBackupPathHandle : TNetPcAddBackupPathHandle;
begin
    // 写 路径信息
  NetPcAddBackupPathHandle := TNetPcAddBackupPathHandle.Create( PcID );
  NetPcAddBackupPathHandle.SetPathInfo( FullPath, PathType );
  NetPcAddBackupPathHandle.SetEncryptInfo( IsEncrypt, PasswordMD5, PasswordHint );
  NetPcAddBackupPathHandle.SetSpace( FolderSpace );
  NetPcAddBackupPathHandle.SetCountInfo( FileCount, CopyCount );
  NetPcAddBackupPathHandle.Update;
  NetPcAddBackupPathHandle.Free;

    // 备份路径 副本拥有者
  AddCopyOwner;
end;

procedure TFileSearchReqMsg.SetSearchNum(_SearchNum: Integer);
begin
  SeaarchNum := _SearchNum;
end;

{ TRestoreBackupPathMsg }



{ TRestoreFileSearchReqMsg }

procedure TRestoreFileSearchReqMsg.AddRestoreBackupPashMsg(MsgStr: string);
begin
  RestorePathMsgList := MsgUtil.AddMsg( RestorePathMsgList, MsgStr );
end;

constructor TRestoreFileSearchReqMsg.Create;
begin
  inherited;
  RestorePathMsgList := '';
end;

function TRestoreFileSearchReqMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ReqRestore;
end;

procedure TRestoreFileSearchReqMsg.SetRestorePcID(_RestorePcID: string);
begin
  RestorePcID := _RestorePcID;
end;

procedure TRestoreFileSearchReqMsg.SetSearchNum(_SearchNum: Integer);
begin
  SearchNum := _SearchNum;
end;

procedure TRestoreFileSearchReqMsg.Update;
var
  RestoreFileScanStartInfo : TRestoreFileScanStartInfo;
  MsgList : TStringList;
  i : Integer;
  RestorePathMsg : TRestorePathMsg;
begin
  RestoreFileScanStartInfo := TRestoreFileScanStartInfo.Create;
  RestoreFileScanStartInfo.SetSearchNum( SearchNum );
  RestoreFileScanStartInfo.SetSearchPcID( PcID );
  RestoreFileScanStartInfo.SetRestorePcID( RestorePcID );

  MsgList := MsgUtil.getMsgList( RestorePathMsgList );
  for i := 0 to MsgList.Count - 1 do
  begin
    RestorePathMsg := TRestorePathMsg.Create;
    RestorePathMsg.SetMsgStr( MsgList[i] );
    RestoreFileScanStartInfo.AddRestorePath( RestorePathMsg.FullPath, RestorePathMsg.PathType );
    RestorePathMsg.Free;
  end;
  MsgList.Free;

  MyFileRestoreScan.AddChange( RestoreFileScanStartInfo );
end;

{ TRestorePathMsg }

procedure TRestorePathMsg.SetPathInfo(_FullPath, _PathType: string);
begin
  FullPath := _FullPath;
  PathType := _PathType;
end;

{ TRetoreFileSearchResultMsg }

function TReStoreFileSearchResultMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_ResultRestore;
end;

procedure TReStoreFileSearchResultMsg.Update;
var
  RestoreFileSearchResultinfo : TRestoreFileSearchResultinfo;
begin
  RestoreFileSearchResultinfo := TRestoreFileSearchResultinfo.Create;
  RestoreFileSearchResultinfo.SetSearchNum( SearchNum );
  RestoreFileSearchResultinfo.SetLocationID( PcID );
  RestoreFileSearchResultinfo.SetFilePath( FilePath );
  RestoreFileSearchResultinfo.SetFileInfo( FileSize, FileTime );
  MyFileRestoreReq.AddChange( RestoreFileSearchResultinfo );
end;

{ TRestoreFileSearchCompleteMsg }

function TRestoreFileSearchCompleteMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_StopRestore;
end;

procedure TRestoreFileSearchCompleteMsg.Update;
var
  RestoreFileSearchCompleteInfo : TRestoreFileSearchCompleteInfo;
begin
  RestoreFileSearchCompleteInfo := TRestoreFileSearchCompleteInfo.Create( PcID );
  MyFileRestoreReq.AddChange( RestoreFileSearchCompleteInfo );
end;

{ TRestoreSearchCancelMsg }

function TRestoreSearchCancelMsg.getMsgType: string;
begin
  Result := MsgType_PcSearch_CancelRestore;
end;

procedure TRestoreSearchCancelMsg.Update;
var
  RestoreFileSearchCancelInfo : TRestoreFileSearchCancelInfo;
begin
  RestoreFileSearchCancelInfo := TRestoreFileSearchCancelInfo.Create( PcID );
  MyFileRestoreScan.AddChange( RestoreFileSearchCancelInfo );
end;

{ TAdvancePcConnMsg }

procedure TAdvancePcConnMsg.AddNetworkPc;
var
  NetPcAddHandle : TNetPcAddHandle;
begin
  NetPcAddHandle := TNetPcAddHandle.Create( ConnPcID );
  NetPcAddHandle.SetPcName( ConnPcName );
  NetPcAddHandle.Update;
  NetPcAddHandle.Free;
end;

procedure TAdvancePcConnMsg.AddPingMsg;
var
  InternetConnSendPingMsg : TInternetConnSendPingMsg;
begin
  InternetConnSendPingMsg := TInternetConnSendPingMsg.Create;
  InternetConnSendPingMsg.SetRemotePcID( ConnPcID );
  InternetConnSendPingMsg.SetRemoteLanSocket( LanIp, LanPort );
  InternetConnSendPingMsg.SetRemoteInternetSocket( InternetIp, InternetPort );
  MyMasterConn.AddChange( InternetConnSendPingMsg );
end;

function TAdvancePcConnMsg.getMsgType: string;
begin
  Result := MsgType_AdvancePc;
end;

procedure TAdvancePcConnMsg.SetConnPcInfo(_ConnPcID, _ConnPcName: string);
begin
  ConnPcID := _ConnPcID;
  ConnPcName := _ConnPcName;
end;

procedure TAdvancePcConnMsg.SetInternetSocket(_InternetIp,
  _InternetPort: string);
begin
  InternetIp := _InternetIp;
  InternetPort := _InternetPort;
end;

procedure TAdvancePcConnMsg.SetLanSocket(_LanIp, _LanPort: string);
begin
  LanIp := _LanIp;
  LanPort := _LanPort;
end;

procedure TAdvancePcConnMsg.Update;
begin
  AddNetworkPc;
  AddPingMsg;
end;

{ TAdvanceConnMsgFactory }

constructor TAdvanceConnMsgFactory.Create;
begin
  inherited Create( MsgType_AdvancePc );
end;

function TAdvanceConnMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_AdvancePc then
    Result := TAdvancePcConnMsg.Create
  else
    Result := nil;
end;

{ TPcBatRegisterMsg }

function TPcBatRegisterMsg.getMsgType: string;
begin
  Result := MsgType_CloudPc_BatRegister;
end;

procedure TPcBatRegisterMsg.SetLicenseStr(_LicenseStr: string);
begin
  LicenseStr := _LicenseStr;
end;

procedure TPcBatRegisterMsg.Update;
begin
  MyRegisterControl.AddLicense( LicenseStr );
end;

{ TFindBackupPathMsg }

constructor TFindBackupPathMsg.Create;
begin
  NewBackupPathHash := TBackupPathList.Create;
end;

destructor TFindBackupPathMsg.Destroy;
begin
  NewBackupPathHash.Free;
  inherited;
end;

procedure TFindBackupPathMsg.FindNewBackupPathHash;
var
  FindBackupPathInfo : TFindBackupPathInfo;
begin
  FindBackupPathInfo := TFindBackupPathInfo.Create;
  FindBackupPathInfo.SetOutput( NewBackupPathHash );
  FindBackupPathInfo.Update;
  FindBackupPathInfo.Free;
end;

function TFindBackupPathMsg.get: string;
begin
  FindNewBackupPathHash;

  ScanNewBackupPathHash;

  Result := MsgStr;
end;

procedure TFindBackupPathMsg.ScanNewBackupPathHash;
var
  PcCloudBackupPathRefreshMsg : TRefreshCloudBackupPathMsg;
  CloudBackupPathAddMsg : TCloudBackupPathAddMsg;
  i : integer;
  BackupPathInfo : TBackupPathInfo;
  PasswordMD5, AddMsgStr : string;
  po : TBackupPathCopyOwnerPair;
  CloudBackupPathOwnerAddMsg : TCloudBackupPathOwnerAddMsg;
  PathCopyOwnerAddMsg : string;
begin
    // 发送 所有本机的备份路径信息
  PcCloudBackupPathRefreshMsg := TRefreshCloudBackupPathMsg.Create;
  PcCloudBackupPathRefreshMsg.SetPcID( PcInfo.PcID );
  for i := 0 to NewBackupPathHash.Count - 1 do
  begin
    BackupPathInfo := NewBackupPathHash[i];
    PasswordMD5 := MyEncrypt.EncodeMD5String( BackupPathInfo.Password );

    CloudBackupPathAddMsg := TCloudBackupPathAddMsg.Create;
    CloudBackupPathAddMsg.SetPcID( PcInfo.PcID );
    CloudBackupPathAddMsg.SetPathInfo( BackupPathInfo.FullPath, BackupPathInfo.PathType );
    CloudBackupPathAddMsg.SetEncryptInfo( BackupPathInfo.IsEncrypt, PasswordMD5, BackupPathInfo.PasswordHint );
    CloudBackupPathAddMsg.SetSpace( BackupPathInfo.FolderSpace );
    CloudBackupPathAddMsg.SetCountInfo( BackupPathInfo.FileCount, BackupPathInfo.CopyCount );

    for po in BackupPathInfo.BackupPathCopyOwnerHash do
    begin
      CloudBackupPathOwnerAddMsg := TCloudBackupPathOwnerAddMsg.Create;
      CloudBackupPathOwnerAddMsg.SetPcID( PcInfo.PcID );
      CloudBackupPathOwnerAddMsg.SetPathInfo( BackupPathInfo.FullPath, po.Value.PcID );
      CloudBackupPathOwnerAddMsg.SetOwnerSpace( po.Value.OwnerSpace );
      PathCopyOwnerAddMsg := CloudBackupPathOwnerAddMsg.getMsgStr;
      CloudBackupPathOwnerAddMsg.Free;

      CloudBackupPathAddMsg.AddCopyOwnerAddMsg( PathCopyOwnerAddMsg );
    end;

    AddMsgStr := CloudBackupPathAddMsg.getMsgStr;
    CloudBackupPathAddMsg.Free;

    PcCloudBackupPathRefreshMsg.AddBackupPathAddMsg( AddMsgStr );
  end;
  MsgStr := PcCloudBackupPathRefreshMsg.getMsgStr;
  PcCloudBackupPathRefreshMsg.Free;
end;

{ TFileRemoveBaseMsg }

procedure TFileRemoveMsg.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TBackupFileRemoveMsg }

function TBackupFileRemoveMsg.getMsgType: string;
begin
  Result := MsgType_FileRemove_BackupNotify;
end;

procedure TBackupFileRemoveMsg.SendRemoveReturn;
var
  BackupFileRemoveReturnMsg : TBackupFileRemoveReturnMsg;
begin
  BackupFileRemoveReturnMsg := TBackupFileRemoveReturnMsg.Create;
  BackupFileRemoveReturnMsg.SetPcID( PcInfo.PcID );
  BackupFileRemoveReturnMsg.SetFilePath( FilePath );
  MyClient.SendMsgToPc( PcID, BackupFileRemoveReturnMsg );
end;

procedure TBackupFileRemoveMsg.Update;
var
  CloudPath, CloudPcPath, CloudFilePath : string;
begin
    // 组织 云文件路径
  CloudPath := MyFilePath.getPath( MyCloudFileInfo.ReadBackupCloudPath );
  CloudPcPath := CloudPath +  MyFilePath.getPath( PcID );
  CloudFilePath := CloudPcPath + MyFilePath.getDownloadPath( FilePath );

    // 文件/目录
  if FileExists( CloudFilePath ) then
    MyFolderDelete.FileDelete( CloudFilePath )
  else
    MyFolderDelete.DeleteDir( CloudFilePath );

    // 发送返回命令
  SendRemoveReturn;
end;

{ TBackupFileRemoveReturnMsg }

function TBackupFileRemoveReturnMsg.getMsgType: string;
begin
  Result := MsgType_FileRemove_BackupReturn;
end;

procedure TBackupFileRemoveReturnMsg.Update;
var
  BackupRemoveNotifyRemoveHandle : TBackupRemoveNotifyRemoveHandle;
begin
  BackupRemoveNotifyRemoveHandle := TBackupRemoveNotifyRemoveHandle.Create( PcID );
  BackupRemoveNotifyRemoveHandle.SetFullPath( FilePath );
  BackupRemoveNotifyRemoveHandle.Update;
  BackupRemoveNotifyRemoveHandle.Free;
end;

{ TFileRemoveMsgFactory }

constructor TFileRemoveMsgFactory.Create;
begin
  inherited Create( MsgType_FileRemove );
end;

function TFileRemoveMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_FileRemove_BackupNotify then
    Result := TBackupFileRemoveMsg.Create
  else
  if MsgType = MsgType_FileRemove_BackupReturn then
    Result := TBackupFileRemoveReturnMsg.Create
  else
    Result := nil;
end;

{ TCloudBackupPathOwnerAddMsg }

procedure TCloudBackupPathOwnerAddMsg.SetOwnerSpace(_OwnerSpace: Int64);
begin
  OwnerSpace := _OwnerSpace;
end;

procedure TCloudBackupPathOwnerAddMsg.SetPathInfo(_FullPath,
  _CopyOwner: string);
begin
  FullPath := _FullPath;
  CopyOwner := _CopyOwner;
end;

procedure TCloudBackupPathOwnerAddMsg.Update;
var
  NetPcBackupPathOwnerAddHandle : TNetPcBackupPathOwnerAddHandle;
begin
  NetPcBackupPathOwnerAddHandle := TNetPcBackupPathOwnerAddHandle.Create( PcID );
  NetPcBackupPathOwnerAddHandle.SetPathInfo( FullPath, CopyOwner );
  NetPcBackupPathOwnerAddHandle.SetOwnerSpace( OwnerSpace );
  NetPcBackupPathOwnerAddHandle.Update;
  NetPcBackupPathOwnerAddHandle.Free;
end;

{ TClientSendFileReqMsg }

procedure TClientSendFileReqMsg.FeedBackCancel;
var
  ClientSendFileFeedbackMsg : TClientSendFileFeedbackMsg;
begin
    // 发送 feedback 命令
  ClientSendFileFeedbackMsg := TClientSendFileFeedbackMsg.Create;
  ClientSendFileFeedbackMsg.SetPcID( PcInfo.PcID );
  ClientSendFileFeedbackMsg.SetSourceFilePath( SourceFilePath );
  ClientSendFileFeedbackMsg.SetSendPathStatus( SendPathStatus_Cancel );
  MyClient.SendMsgToPc( PcID, ClientSendFileFeedbackMsg );
end;

procedure TClientSendFileReqMsg.FeedBackOK;
var
  AddReceiveFileAutoHandle : TAddReceiveFileAutoHandle;
begin
    // 添加到 ReceivePath
  AddReceiveFileAutoHandle := TAddReceiveFileAutoHandle.Create( SourceFilePath, PcID );
  AddReceiveFileAutoHandle.SetSendPathType( SendPathType );
  AddReceiveFileAutoHandle.SetFileInfo( FileSize, FileCount );
  AddReceiveFileAutoHandle.Update;
  AddReceiveFileAutoHandle.Free;
end;

function TClientSendFileReqMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendReq;
end;

procedure TClientSendFileReqMsg.SetFileInfo(_FileSize: Int64;
  _FileCount: Integer);
begin
  FileSize := _FileSize;
  FileCount := _FileCount;
end;

procedure TClientSendFileReqMsg.SetSendPathType(_SendPathType: string);
begin
  SendPathType := _SendPathType;
end;

procedure TClientSendFileReqMsg.ShowSelectForm;
var
  FromPcName : string;
  FrmSelectReceivePath : TFrmSelectReceivePath;
begin
  FromPcName := MyNetPcInfoReadUtil.ReadName( PcID );

  FrmSelectReceivePath := TFrmSelectReceivePath.Create( SourceFilePath, SendPathType );
  FrmSelectReceivePath.SetFileFrom( PcID, FromPcName );
  FrmSelectReceivePath.SetSpace( FileSize, FileCount );
  MyFaceChange.AddChange( FrmSelectReceivePath );
end;

procedure TClientSendFileReqMsg.Update;
begin
  if FileReceiveSettingInfo.IsAutoReceive or
     MyFileReceiveInfoReadUtil.ReadIsExist( SourceFilePath, PcID )
  then
    FeedBackOK
  else
  if FileReceiveSettingInfo.IsManualReceive then
    ShowSelectForm
  else
    FeedBackCancel;
end;

{ TSendFileMsgFactory }

constructor TFileTransferMsgFactory.Create;
begin
  inherited Create( MsgType_FileTransfer );
end;

function TFileTransferMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_FileTransfer_SendReq then
    Result := TClientSendFileReqMsg.Create
  else
  if MsgType = MsgType_FileTransfer_SendSpace then
    Result := TClientSendFileSpaceMsg.Create
  else
  if MsgType = MsgType_FileTransfer_SendAddCompletedSpace then
    Result := TClientSendFileAddCompletedSpaceMsg.Create
  else
  if MsgType = MsgType_FileTransfer_SendSCompleted then
    Result := TClientSendFileCompletedMsg.Create
  else
  if MsgType = MsgType_FileTransfer_SendFeedback then
    Result := TClientSendFileFeedbackMsg.Create
  else
  if MsgType = MsgType_FileTransfer_SendCancel then
    Result := TClientSendFileCancelMsg.Create
  else
  if MsgType = MsgType_FileTransfer_ReceiveCancel then
    Result := TClientReceiveFileCancelMsg.Create
  else
    Result := nil;
end;

{ TCliendSendFileBaseMsg }

procedure TCliendSendFileBaseMsg.SetSourceFilePath(_SourceFilePath: string);
begin
  SourceFilePath := _SourceFilePath;
end;

{ TClientSendFileSpaceMsg }

function TClientSendFileSpaceMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendSpace;
end;

procedure TClientSendFileSpaceMsg.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TClientSendFileSpaceMsg.Update;
var
  ReceiveFileSetSpaceHandle : TReceiveFileSetSpaceHandle;
begin
  ReceiveFileSetSpaceHandle := TReceiveFileSetSpaceHandle.Create( SourceFilePath, PcID );
  ReceiveFileSetSpaceHandle.SetFileSize( FileSize );
  ReceiveFileSetSpaceHandle.Update;
  ReceiveFileSetSpaceHandle.Free;
end;

{ TClientSendFileCompletedMsg }

function TClientSendFileCompletedMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendSCompleted;
end;

procedure TClientSendFileCompletedMsg.Update;
var
  ReceiveFileSetStatusHandle : TReceiveFileSetStatusHandle;
begin
  inherited;

  ReceiveFileSetStatusHandle := TReceiveFileSetStatusHandle.Create( SourceFilePath, PcID );
  ReceiveFileSetStatusHandle.SetReceiveStatus( ReceivePathStatus_Completed );
  ReceiveFileSetStatusHandle.Update;
  ReceiveFileSetStatusHandle.Free;
end;

{ TClientSendFileFeedbackMsg }

function TClientSendFileFeedbackMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendFeedback;
end;

procedure TClientSendFileFeedbackMsg.SetSendPathStatus(_SendPathStatus: string);
begin
  SendPathStatus := _SendPathStatus;
end;

procedure TClientSendFileFeedbackMsg.Update;
var
  SendFileTransferFeedbackHandle : TSendFileTransferFeedbackHandle;
begin
  SendFileTransferFeedbackHandle := TSendFileTransferFeedbackHandle.Create( SourceFilePath, PcID );
  SendFileTransferFeedbackHandle.SetSendPathStatus( SendPathStatus );
  SendFileTransferFeedbackHandle.Update;
  SendFileTransferFeedbackHandle.Free;
end;

{ TClientReceiveFileCancelMsg }

function TClientReceiveFileCancelMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_ReceiveCancel;
end;

procedure TClientReceiveFileCancelMsg.Update;
var
  SendFileCancelReceiveHandle : TSendFileCancelReceiveHandle;
begin
  SendFileCancelReceiveHandle := TSendFileCancelReceiveHandle.Create( SourceFilePath, PcID );
  SendFileCancelReceiveHandle.Update;
  SendFileCancelReceiveHandle.Free;
end;

{ TClientSendFileCancelMsg }

function TClientSendFileCancelMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendCancel;
end;

procedure TClientSendFileCancelMsg.Update;
var
  ReceiveFileSetStatusHandle : TReceiveFileSetStatusHandle;
begin
  ReceiveFileSetStatusHandle := TReceiveFileSetStatusHandle.Create( SourceFilePath, PcID );
  ReceiveFileSetStatusHandle.SetReceiveStatus( ReceivePathStatus_Cancel );
  ReceiveFileSetStatusHandle.Update;
  ReceiveFileSetStatusHandle.Free;
end;

{ TClientSendFileAddCompletedSpaceMsg }

function TClientSendFileAddCompletedSpaceMsg.getMsgType: string;
begin
  Result := MsgType_FileTransfer_SendAddCompletedSpace;
end;

procedure TClientSendFileAddCompletedSpaceMsg.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TClientSendFileAddCompletedSpaceMsg.Update;
var
  ReceiveFileAddCompletedSpaceHandle : TReceiveFileAddCompletedSpaceHandle;
begin
  ReceiveFileAddCompletedSpaceHandle := TReceiveFileAddCompletedSpaceHandle.Create( SourceFilePath, PcID );
  ReceiveFileAddCompletedSpaceHandle.SetCompletedSpace( CompletedSize );
  ReceiveFileAddCompletedSpaceHandle.Update;
  ReceiveFileAddCompletedSpaceHandle.Free;
end;

{ TClientSendShareListReqMsg }

function TClientSendShareListReqMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareListReq;
end;

procedure TClientSendShareListReqMsg.Update;
var
  FileShareScanInfo : TFileShareScanInfo;
begin
  inherited;

  FileShareScanInfo := TFileShareScanInfo.Create( PcID );
  FileShareScanInfo.SetShareScanInfo( ParentPath, ShareScanType_FileList );

  MyFileShareScanInfo.AddScanInfo( FileShareScanInfo );
end;

{ TClientSendShareListMsg }

function TClientSendShareListMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareList;
end;

procedure TClientSendShareListMsg.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TClientSendShareListMsg.SetFilePath(_FilePath: string;
  _IsFolder: Boolean);
begin
  FilePath := _FilePath;
  IsFolder := _IsFolder;
end;

procedure TClientSendShareListMsg.Update;
var
  ShareFileListAddHandle : TShareExplorerFileAddHandle;
begin
  inherited;

  ShareFileListAddHandle := TShareExplorerFileAddHandle.Create( ParentPath, PcID );
  ShareFileListAddHandle.SetFilePath( FilePath, IsFolder );
  ShareFileListAddHandle.SetFileInfo( FileSize, FileTime );
  ShareFileListAddHandle.Update;
  ShareFileListAddHandle.Free;
end;

{ TClientSendShareDownReqMsg }

function TClientSendShareDownReqMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareDownReq;
end;

procedure TClientSendShareDownReqMsg.Update;
var
  FileShareScanInfo : TFileShareScanInfo;
begin
  inherited;

  FileShareScanInfo := TFileShareScanInfo.Create( PcID );
  FileShareScanInfo.SetShareScanInfo( DownloadPath, ShareScanType_FileDown );
  MyFileShareScanInfo.AddScanInfo( FileShareScanInfo );
end;

{ TClientSendShareDownMsg }

function TClientSendShareDownMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareDown;
end;

procedure TClientSendShareDownMsg.SetFileInfo(_FileSize: Int64;
  _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TClientSendShareDownMsg.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

procedure TClientSendShareDownMsg.Update;
var
  ShareFileDownChildAddHandle : TShareFileDownChildAddHandle;
  ShareFileDownAddFileSizeHandle : TShareFileDownAddFileSizeHandle;
begin
  inherited;

    // 添加
  ShareFileDownChildAddHandle := TShareFileDownChildAddHandle.Create( PcID, DownloadPath );
  ShareFileDownChildAddHandle.SetFilePath( FilePath );
  ShareFileDownChildAddHandle.SetSizeInfo( FileSize, 0 );
  ShareFileDownChildAddHandle.SetFileTime( FileTime );
  ShareFileDownChildAddHandle.SetStatus( FileShareStatus_Waiting );
  ShareFileDownChildAddHandle.Update;
  ShareFileDownChildAddHandle.Free;

    // 添加 根节点空间
  ShareFileDownAddFileSizeHandle := TShareFileDownAddFileSizeHandle.Create( PcID, DownloadPath );
  ShareFileDownAddFileSizeHandle.SetFileSize( FileSize );
  ShareFileDownAddFileSizeHandle.Update;
  ShareFileDownAddFileSizeHandle.Free;
end;

{ TFileShareMsgFactory }

constructor TFileShareMsgFactory.Create;
begin
  inherited Create( MsgType_FileShare );
end;

function TFileShareMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_FileShare_ShareListReq then
    Result := TClientSendShareListReqMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareList then
    Result := TClientSendShareListMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareListCompleted then
    Result := TClientSendShareListCompletedMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareDownReq then
    Result := TClientSendShareDownReqMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareDown then
    Result := TClientSendShareDownMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareDownCompleted then
    Result := TClientSendShareDownCompletedMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareCancelReq then
    Result := TClientSendShareCancelReqMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareCancel then
    Result := TClientSendShareCancelMsg.Create
  else
  if MsgType = MsgType_FileShare_ShareFileCount then
    Result := TClientSendIsShareMsg.Create
  else
    Result := nil;
end;

{ TClientSendShareListBaseMsg }

procedure TClientSendShareListBaseMsg.SetParentPath(_ParentPath: string);
begin
  ParentPath := _ParentPath;
end;

{ TClientSendShareListCompletedMsg }

function TClientSendShareListCompletedMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareListCompleted;
end;

procedure TClientSendShareListCompletedMsg.SetIsCancelShare(
  _IsCancelShare: Boolean);
begin
  IsCancelShare := _IsCancelShare;
end;

procedure TClientSendShareListCompletedMsg.Update;
var
  ShareDownGetListCompletedHandle : TShareDownGetListCompletedHandle;
begin
  inherited;

  ShareDownGetListCompletedHandle := TShareDownGetListCompletedHandle.Create( PcID, ParentPath );
  ShareDownGetListCompletedHandle.SetIsShareCancel( IsCancelShare );
  ShareDownGetListCompletedHandle.Update;
  ShareDownGetListCompletedHandle.Free;
end;

{ TClientSendShareDownBaseMsg }

procedure TClientSendShareDownBaseMsg.SetDownloadPath(_DownloadPath: string);
begin
  DownloadPath := _DownloadPath;
end;

{ TClientSendShareDownCompletedMsg }

function TClientSendShareDownCompletedMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareDownCompleted;
end;

procedure TClientSendShareDownCompletedMsg.SetIsShareCancel(
  _IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TClientSendShareDownCompletedMsg.Update;
var
  ShareDownGetDownCompletedHandle : TShareDownGetDownCompletedHandle;
begin
  inherited;

  ShareDownGetDownCompletedHandle := TShareDownGetDownCompletedHandle.Create( PcID, DownloadPath );
  ShareDownGetDownCompletedHandle.SetIsShareCancel( IsShareCancel );
  ShareDownGetDownCompletedHandle.Update;
  ShareDownGetDownCompletedHandle.Free;
end;

{ TClientSendShareCancelReqMsg }

function TClientSendShareCancelReqMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareCancelReq;
end;

procedure TClientSendShareCancelReqMsg.Update;
var
  IsShareCancel : Boolean;
  ClientSendShareCancelMsg : TClientSendShareCancelMsg;
begin
  inherited;

    // 是否 共享已取消
  IsShareCancel := not MySharePathInfoReadUtil.ReadFileIsEnable( DownloadPath );

    // 发送结果
  ClientSendShareCancelMsg := TClientSendShareCancelMsg.Create;
  ClientSendShareCancelMsg.SetPcID( PcInfo.PcID );
  ClientSendShareCancelMsg.SetDownloadPath( DownloadPath );
  ClientSendShareCancelMsg.SetIsShareCancel( IsShareCancel );
  MyClient.SendMsgToPc( PcID, ClientSendShareCancelMsg );
end;

{ TClientSendShareCancelMsg }

function TClientSendShareCancelMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareCancel;
end;

procedure TClientSendShareCancelMsg.SetIsShareCancel(_IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TClientSendShareCancelMsg.Update;
var
  ShareDownShareCancelHandle : TShareDownShareCancelHandle;
begin
  inherited;

  if not IsShareCancel then
    Exit;

  ShareDownShareCancelHandle := TShareDownShareCancelHandle.Create( PcID, DownloadPath );
  ShareDownShareCancelHandle.Update;
  ShareDownShareCancelHandle.Free;
end;

{ TClientSendIsShareMsg }

function TClientSendIsShareMsg.getMsgType: string;
begin
  Result := MsgType_FileShare_ShareFileCount;
end;

procedure TClientSendIsShareMsg.SetIsShareFile(_IsShareFile: Boolean);
begin
  IsShareFile := _IsShareFile;
end;

procedure TClientSendIsShareMsg.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TClientSendIsShareMsg.Update;
var
  SharePcSetIsShareHandle : TSharePcRevIsShareHandle;
begin
  SharePcSetIsShareHandle := TSharePcRevIsShareHandle.Create( PcID, PcName );
  SharePcSetIsShareHandle.SetIsShareFolder( IsShareFile );
  SharePcSetIsShareHandle.Update;
  SharePcSetIsShareHandle.Free;
end;

{ TPcRemovePendFileMsg }

procedure TPcRemovePendFileMsg.SetRemovePath(_RemovePath: string);
begin
  RemovePath := _RemovePath;
end;

procedure TPcRemovePendFileMsg.Update;
var
  VirTransferChildRemoveInfo : TVirTransferChildRemoveInfo;
begin
  inherited;

  VirTransferChildRemoveInfo := TVirTransferChildRemoveInfo.Create( getRootID );
  VirTransferChildRemoveInfo.SetChildID( PcID, RemovePath );
  MyJobFace.AddChange( VirTransferChildRemoveInfo );
end;

{ TPcRemoveDownPendFileMsg }

function TPcRemoveDownPendFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_RemoveDownPend;
end;

function TPcRemoveDownPendFileMsg.getRootID: string;
begin
  Result := RootID_DownPend;
end;

{ TPcRemoveUpPendFileMsg }

function TPcRemoveUpPendFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_RemoveUpPend;
end;

function TPcRemoveUpPendFileMsg.getRootID: string;
begin
  Result := RootID_UpPend;
end;

{ TPcAddDownPendFileMsg }

procedure TPcAddDownPendFileMsg.SetUpFilePath(_UpFilePath: string);
begin
  UpFilePath := _UpFilePath;
end;

{ TPcAddDownPendTransferFileMsg }

function TPcAddDownPendTransferFileMsg.getMsgType: string;
begin
  Result := MsgType_PcAddPend_DownTransfer;
end;

procedure TPcAddDownPendTransferFileMsg.Update;
var
  PcName : string;
  Percentage : Integer;
  VirTransferChildAddInfo : TVirTransferChildAddInfo;
begin
    // TTransStatus 界面显示
  PcName := MyNetPcInfoReadUtil.ReadName( PcID );
  Percentage := MyPercentage.getPercent( Position, FileSize );
  VirTransferChildAddInfo := TVirTransferChildAddInfo.Create( RootID_DownPend );
  VirTransferChildAddInfo.SetChildID( PcID, UpFilePath );
  VirTransferChildAddInfo.SetFileBase( UpFilePath, PcID );
  VirTransferChildAddInfo.SetFileInfo( PcName, FileSize );
  VirTransferChildAddInfo.SetPercentage( Percentage );
  VirTransferChildAddInfo.SetStatusInfo( FileType_Transfer, FileStatus_Waiting );
  MyJobFace.AddChange( VirTransferChildAddInfo );
end;

{ TPcRedirectJobMsg }

function TPcRedirectJobAddMsg.getIsDownload(JobType: string): Boolean;
begin
  Result := ( JobType = JobType_Backup ) or ( JobType = JobType_FileSend );
end;

function TPcRedirectJobAddMsg.getMsgType: string;
begin
  Result := MsgType_RedirectJob_Add;
end;

procedure TPcRedirectJobAddMsg.SetJobMsg(_JobMsgStr: string);
begin
  JobMsgStr := _JobMsgStr;
end;

procedure TPcRedirectJobAddMsg.Update;
var
  ReqMsg : TTransferReqMsg;
  PendingJobInfo : TPendingJobInfo;
  JobAddInfo : TJobAddInfo;
  TransferJobChangeInfo : TTransferJobChangeInfo;
begin
    // 构造 Job
  ReqMsg := TransferJobMsgFactory.getReqMsg( JobMsgStr );
  PendingJobInfo := TransferJobMsgFactory.getJobInfo( ReqMsg );
  ReqMsg.Free;

    // 添加
  JobAddInfo := TJobAddInfo.Create;
  JobAddInfo.SetJobInfo( PendingJobInfo );

    // 上传/下载
  if getIsDownload( PendingJobInfo.getJobType ) then
    TransferJobChangeInfo := TDownloadJobChangeInfo.Create
  else
    TransferJobChangeInfo := TUploadJobChangeInfo.Create;
  TransferJobChangeInfo.SetJobWriteInfo( JobAddInfo );

    // 添加到队列
  MyJobInfo.AddChange( TransferJobChangeInfo );
end;

{ TRedirectJobMsgFactory }

constructor TRedirectJobMsgFactory.Create;
begin
  inherited Create( MsgType_RedirectJob );
end;

function TRedirectJobMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_RedirectJob_Add then
    Result := TPcRedirectJobAddMsg.Create
  else
    Result := nil;
end;

{ TNetworkBackupChangeMsg }

procedure TNetworkBackupChangeMsg.SetBackupPath(_BackupPath: string);
begin
  BackupPath := _BackupPath;
end;

{ TNetworkBackupAddMsg }

function TNetworkBackupAddCloudMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_AddCloudItem;
end;

procedure TNetworkBackupAddCloudMsg.Update;
var
  Params : TCloudAddBackupParams;
begin
  inherited;

  Params.PcID := PcID;
  Params.BackupPath := BackupPath;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.FileSpace := FileSize;
  Params.LastDateTime := LastBackupTime;

  MyCloudAppApi.AddBackupPath( Params );
end;

{ TNetworkBackupRemoveMsg }

function TNetworkBackupRemoveCloudMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RemoveCloudItem;
end;

procedure TNetworkBackupRemoveCloudMsg.Update;
begin
  inherited;

  MyCloudAppApi.RemoveBackupPath( PcID, BackupPath );
end;

{ TNetworkBackupMsgFactory }

constructor TNetworkBackupMsgFactory.Create;
begin
  inherited Create( MsgType_NetworkBackup );
end;

function TNetworkBackupMsgFactory.get: TMsgBase;
begin
  if MsgType = MsgType_NetworkBackup_AddCloudItem then
    Result := TNetworkBackupAddCloudMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RemoveCloudItem then
    Result := TNetworkBackupRemoveCloudMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_AddRestoreItem then
    Result := TCloudBackupAddRestoreMsg.Create
  else
  if MsgType = MsgType_NetworkBackup_RemoveRestoreItem then
    Result := TCloudBackupRemoveRestoreMsg.Create
  else
    Result := nil;
end;

{ TNetworkBackupWriteMsg }

procedure TNetworkBackupAddMsg.SetIsFile(_IsFile: Boolean);
begin
  IsFile := _IsFile;
end;

procedure TNetworkBackupAddMsg.SetLastBackupTime(_LastBackupTime: TDateTime);
begin
  LastBackupTime := _LastBackupTime;
end;

procedure TNetworkBackupAddMsg.SetSpaceInfo(_FileCount: Integer;
  _FileSize: Int64);
begin
  FileCount := _FileCount;
  FileSize := _FileSize;
end;

{ TCloudBackupAddRestoreMsg }

function TCloudBackupAddRestoreMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_AddRestoreItem;
end;

procedure TCloudBackupAddRestoreMsg.SetOwnerInfo(_OwnerID, _OwnerName: string);
begin
  OwnerID := _OwnerID;
  OwnerName := _OwnerName;
end;

procedure TCloudBackupAddRestoreMsg.Update;
var
  Params : TNetworkRestoreAddParams;
begin
  inherited;

  Params.PcID := PcID;
  Params.BackupPath := BackupPath;
  Params.OwnerID := OwnerID;
  Params.OwnerName := OwnerName;
  Params.IsFile := IsFile;
  Params.FileCount := FileCount;
  Params.ItemSize := FileSize;
  Params.LastBackupTime := LastBackupTime;

  NetworkRestoreAppApi.AddBackupItem( Params );
end;

{ TCloudBackupRemoveRestoreMsg }

function TCloudBackupRemoveRestoreMsg.getMsgType: string;
begin
  Result := MsgType_NetworkBackup_RemoveRestoreItem;
end;

procedure TCloudBackupRemoveRestoreMsg.SetOwnerID(_OwnerID: string);
begin
  OwnerID := _OwnerID;
end;

procedure TCloudBackupRemoveRestoreMsg.Update;
begin
  inherited;

  NetworkRestoreAppApi.RemoveBackupItem( PcID, BackupPath, OwnerID );
end;

end.

