unit UMyShareFace;

interface

uses UChangeInfo, ComCtrls, virtualtrees, Generics.Collections, UModelUtil, RzTabs, Controls,
     UFmShareFileExplorer, SysUtils, Classes, SyncObjs, DateUtils, uDebug;

type

{$Region ' Form Vst ѡ���ҵĹ���·�� ' }

    // �޸� ����
  TVstSelectSharePathChange = class( TChangeInfo )
  public
    vstSelectSharePath : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // �޸� ���� ����
  TVstSelectSharePathWrite = class( TVstSelectSharePathChange )
  public
    FullPath : string;
  public
    constructor Create( _FullPath : string );
  end;

    // ���
  TVstSelectSharePathAdd = class( TVstSelectSharePathWrite )
  public
    procedure Update;override;
  end;

    // ɾ��
  TVstSelectSharePathRemove = class( TVstSelectSharePathWrite )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Listview �ҵĹ���·�� ' }

  TVstSharePathData = record
  public
    FullPath, PathType : WideString;
  end;
  PVstSharePathData = ^TVstSharePathData;

      // �޸� ����
  TLvSharePathChange = class( TChangeInfo )
  public
    VstSharePath : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // �޸� ָ��·�� ����
  TLvSharePathWrite = class( TLvSharePathChange )
  public
    FullPath : string;
  protected
    SharePathNode : PVirtualNode;
    NodeData : PVstSharePathData;
  public
    constructor Create( _FullPath : string );
  protected
    function FindSharePathNode : Boolean;
  end;

    // ���
  TLvSharePathAdd = class( TLvSharePathWrite )
  private
    PathType : string;
  public
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;

    // ɾ��
  TLvSharePathRemove = class( TLvSharePathWrite )
  public
    procedure Update;override;
  end;

{$EndRegion}

{$Region ' Form ѡ���������繲���ļ� ' }

  {$Region ' Select Computer ' }

  TLvSharePcData = class
  public
    PcID, PcName : string;
  public
    constructor Create( _PcID, _PcName : string );
  end;

    // ����
  TLvDownSharePcChange = class( TChangeInfo )
  public
    LvDownSharePc : TListView;
  public
    procedure Update;override;
  end;

    // �޸�
  TLvDownSharePcWrite = class( TLvDownSharePcChange )
  public
    PcID : string;
  protected
    PcItem : TListItem;
    PcIndex : Integer;
    PcData : TLvSharePcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcItem : Boolean;
  end;

    // ���
  TLvDownSharePcAdd = class( TLvDownSharePcWrite )
  private
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // ɾ��
  TLvDownSharePcRemove = class( TLvDownSharePcWrite )
  public
    procedure Update;override;
  end;

    // ���
  TLvDownSharePcClear = class( TLvDownSharePcChange )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' History Position ' }

    // ���ݽṹ
  TVstShareHistoryData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
  end;
  PVstShareHistoryData = ^TVstShareHistoryData;

    // ����
  TVstShareHistoryChange = class( TChangeInfo )
  public
    VstShareHistory : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshClearBtn;
  end;

    // Pc ��/����
  TVstShareHistoryPcOnline = class( TVstShareHistoryChange )
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

    // Server ����
  TVstShareHistoryServerOffline = class( TVstShareHistoryChange )
  public
    procedure Update;override;
  end;

    // �޸�
  TVstShareHistoryWrite = class( TVstShareHistoryChange )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathNode : PVirtualNode;
    NodeData : PVstShareHistoryData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // ���
  TVstShareHistoryAdd = class( TVstShareHistoryWrite )
  public
    DesPcName : string;
    DesPcIsOnline : Boolean;
    PathType : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetDesPcIsOnline( _DesPcIsOnline : Boolean );
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  private
    procedure CheckRemove;
  end;

    // ɾ��
  TVstShareHistoryRemove = class( TVstShareHistoryWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Favorite Position ' }

    // ���ݽṹ
  TVstShareFavorityData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
  end;
  PVstShareFavorityData = ^TVstShareFavorityData;

    // ����
  TVstShareFavorityChange = class( TChangeInfo )
  public
    VstShareFavority : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure RefreshClearBtn;
  end;

      // Pc ��/����
  TVstShareFavorityPcOnline = class( TVstShareFavorityChange )
  public
    PcID : string;
    IsOnline : Boolean;
  public
    constructor Create( _PcID : string );
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  end;

      // Server ����
  TVstShareFavorityServerOffline = class( TVstShareFavorityChange )
  public
    procedure Update;override;
  end;

    // �޸�
  TVstShareFavorityWrite = class( TVstShareFavorityChange )
  public
    FullPath : string;
    DesPcID : string;
  protected
    PathNode : PVirtualNode;
    NodeData : PVstShareFavorityData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindPathNode : Boolean;
  end;

    // ���
  TVstShareFavorityAdd = class( TVstShareFavorityWrite )
  public
    DesPcName : string;
    DesPcIsOnline : Boolean;
    PathType : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetDesPcIsOnline( _DesPcIsOnline : Boolean );
    procedure SetPathType( _PathType : string );
    procedure Update;override;
  end;


    // ɾ��
  TVstShareFavorityRemove = class( TVstShareFavorityWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Select Files ' }

  TVstShareFolderData = record
  public
    FilePath : WideString;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    IsWaiting : Boolean;
  end;
  PVstShareFolderData = ^TVstShareFolderData;

    // ������
  VstShareFolderUtil = class
  public
    class function getTap( DesPcID : string ) : TRzTabSheet;
    class function getFrame( ts : TRzTabSheet ):TFrameShareFiles;
    class function getVstShareFiles( DesPcID : string ): TVirtualStringTree;
  end;

    // �޸� ���� ����
  TVstShareFileWrite = class( TChangeInfo )
  protected
    ParentPath, DesPcID : string;
  protected
    VstShareFile : TVirtualStringTree;
    ParentNode : PVirtualNode;
    ParentData : PVstShareFolderData;
  public
    constructor Create( _ParentPath, _DesPcID : string );
  protected
    function FindVstShareFile : Boolean;
    function FindParentNode : Boolean;
  end;

    // ���
  TVstShareFileAdd = class( TVstShareFileWrite )
  public
    FilePath : string;
    IsFolder : Boolean;
    FileSize : Int64;
    FileTime : TDateTime;
  public
    procedure SetFilePath( _FilePath : string; _IsFolder : Boolean );
    procedure SetFileInfo( _FileSize : Int64; _FileTime : TDateTime );
    procedure Update;override;
  end;

    // ������
  TVstShareFileCompleted = class( TVstShareFileWrite )
  private
    IsShareCancel : Boolean;
  public
    procedure SetIsShareCancel( _IsShareCancel : Boolean );
    procedure Update;override;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' ���صĹ���·����ʷ ' }

    // ���ݽṹ
  TVstShareDownData = record
  public
    FullPath, PathType : WideString;
    DesPcID, DesPcName : WideString;
    SavePath : WideString;
    FileSize, CompletedSize : Int64;
    Status : WideString;
    IsDesPcOnline : Boolean;
  public
    IsIncompleted : Boolean;
  end;
  PVstShareDownData = ^TVstShareDownData;

    // ����
  TVstShareDownChange = class( TChangeInfo )
  public
    VstShareDown : TVirtualStringTree;
  public
    procedure Update;override;
  end;

    // �޸�
  TVstShareDownWrite = class( TVstShareDownChange )
  public
    FullPath, DesPcID : string;
  protected
    ShareDownNode : PVirtualNode;
    ShareDownData : PVstShareDownData;
  public
    constructor Create( _FullPath, _DesPcID : string );
  protected
    function FindShareDownNode : Boolean;
    procedure RefreshShareDownNode;
  end;

  VstShareDownUtil = class
  public
    class function getNodeIcon( Node : PVirtualNode ): Integer;
    class function getIsFreeLimit( Node : PVirtualNode ): Boolean;
  end;

  {$Region ' �޸� ���ڵ� ' }

    // ���
  TVstShareDownAdd = class( TVstShareDownWrite )
  private
    DesPcName : string;
    PathType : string;
    SavePath : string;
    FileSize, CompletedSize : Int64;
    IsDecPcOnline : Boolean;
    Status : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetPathType( _PathType : string );
    procedure SetSavePath( _SavePath : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetIsDecPcOnline( _IsDecPcOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // ��� �ļ��ռ�
  TVstShareDownAddFileSize = class( TVstShareDownWrite )
  public
    FileSize : Int64;
  public
    procedure SetFileSize( _FileSize : Int64 );
    procedure Update;override;
  end;

    // ��� ����ɿռ�
  TVstShareDownAddCompletedSize = class( TVstShareDownWrite )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ���� ����ɿռ�
  TVstShareDownSetCompletedSize = class( TVstShareDownWrite )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // Pc ��/����
  TVstShareDownIsOnline = class( TVstShareDownWrite )
  public
    IsOnline : Boolean;
  public
    procedure SetIsOnline( _IsOnline : Boolean );
    procedure Update;override;
  private
    procedure SetToChildNode;
  end;

    // ���� ״̬
  TVstShareDownSetStatus = class( TVstShareDownWrite )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // ���ݽ��� ȡ�� Job
  TVstShareDownClearJob = class( TVstShareDownWrite )
  public
    procedure Update;override;
  private
    procedure RemoveJob( ChildPath : string );
  end;

    // ��� �ӽڵ�
  TVstShareDownClearChild = class( TVstShareDownWrite )
  public
    procedure Update;override;
  end;

    // ɾ��
  TVstShareDownRemove = class( TVstShareDownWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' �޸� �ӽڵ� ' }

    // �޸�
  TVstShareDownChildChange = class( TVstShareDownWrite )
  public
    FilePath : string;
  private
    FileNode : PVirtualNode;
    FileData : PVstShareDownData;
  public
    procedure SetFilePath( _FilePath : string );
  private
    function FindFileNode : Boolean;
    procedure RefreshFileNode;
    function getIsFileNode : Boolean;
  end;

    // ���
  TVstShareDownChildAdd = class( TVstShareDownChildChange )
  private
    DesPcName : string;
    FileSize, CompletedSize : Int64;
    IsDecPcOnline : Boolean;
    SavePath : string;
    Status : string;
  public
    procedure SetDesPcName( _DesPcName : string );
    procedure SetSizeInfo( _FileSize, _CompletedSize : Int64 );
    procedure SetIsPcOnline( _IsDecPcOnline : Boolean );
    procedure SetStatus( _Status : string );
    procedure SetSavePath( _SavePath : string );
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

    // ��� ����ɿռ�
  TVstShareDownChildAddCompletedSize = class( TVstShareDownChildChange )
  public
    CompletedSize : Integer;
  public
    procedure SetCompletedSize( _CompletedSize : Integer );
    procedure Update;override;
  end;

    // ���� ����ɿռ�
  TVstShareDownChildSetCompletedSize = class( TVstShareDownChildChange )
  public
    CompletedSize : Int64;
  public
    procedure SetCompletedSize( _CompletedSize : Int64 );
    procedure Update;override;
  end;

    // ���� ����״̬
  TVstShareDownChildSetStatus = class( TVstShareDownChildChange )
  public
    Status : string;
  public
    procedure SetStatus( _Status : string );
    procedure Update;override;
  end;

    // ɾ��
  TVstShareDownChildRemove = class( TVstShareDownChildChange )
  public
    procedure Update;override;
  private
    procedure CheckFreeLimit;
  end;

  {$EndRegion}

{$EndRegion}

{$Region ' Vst ���� Pc ��Ϣ ' }

    // ���ݽṹ
  TVstShareFilePcData = record
  public
    PcID : WideString;
    PcName : WideString;
  public
    IsShowDownload, IsShowUpload : Boolean;
    UploadCount, DownloadCount : Integer;
  end;
  PVstShareFilePcData = ^TVstShareFilePcData;

    // ����
  TVstShareFilePcChange = class( TChangeInfo )
  public
    VstShareFilePc : TVirtualStringTree;
  public
    procedure Update;override;
  protected
    procedure ResetExistSharePc( IsExist : Boolean );
  end;

    // �޸�
  TVstShareFilePcWrite = class( TVstShareFilePcChange )
  public
    PcID : string;
  protected
    PcNode : PVirtualNode;
    PcData : PVstShareFilePcData;
  public
    constructor Create( _PcID : string );
  protected
    function FindPcNode : Boolean;
    procedure RefreshPcNode;
  end;

    // ���
  TVstShareFilePcAdd = class( TVstShareFilePcWrite )
  public
    PcName : string;
  public
    procedure SetPcName( _PcName : string );
    procedure Update;override;
  end;

    // ɾ��
  TVstShareFilePcRemove = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // ���
  TVstShareFileClear = class( TVstShareFilePcChange )
  public
    procedure Update;override;
  end;

  {$Region ' �ϴ�/���� ��ʾ ' }

    // Pc �������
  TVstShareFilePcAddDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc ɾ������
  TVstShareFilePcRemoveDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc ����ϴ�
  TVstShareFilePcAddUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // Pc ɾ���ϴ�
  TVstShareFilePcRemoveUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // ���� Pc ����
  TVstShareFilePcHidePcDownload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

    // ���� Pc �ϴ�
  TVstShareFilePcHidePcUpload = class( TVstShareFilePcWrite )
  public
    procedure Update;override;
  end;

  {$EndRegion}

  {$Region ' Vst FileSend Des �����߳� ' }

  TVstShareFilePcHideInfo = class
  public
    PcID : string;
    StartTime : TDateTime;
  public
    constructor Create( _PcID : string );
  end;
  TVstShareFilePcHidePair = TPair< string , TVstShareFilePcHideInfo >;
  TVstShareFilePcHideHash = class(TStringDictionary< TVstShareFilePcHideInfo >);

    // �������߳�
  TVstShareFilePcHideThread = class( TThread )
  private
    Lock : TCriticalSection;
    VstShareFilePcHideDownHash : TVstShareFilePcHideHash;
    VstShareFilePcHideUpHash : TVstShareFilePcHideHash;
  public
    constructor Create;
    procedure AddDownHideInfo( PcID : string );
    procedure AddUpHideInfo( PcID : string );
    destructor Destroy; override;
  protected
    procedure Execute; override;
  private
    function ExistHidePc : Boolean;
    procedure CheckLvHideDown;
    procedure CheckLvHideUp;
  end;

{$EndRegion}

    // ����Ƿ���ڹ���Ŀ¼ Pc
  TVstShareFileCheckExistShare = class( TVstShareFilePcChange )
  public
    procedure Update;override;
  end;

{$EndRegion}

const
  MaxCount_History = 20;

  ShareFile_NotExist = 'Not Exist';

var
  VstShareFilePcHideThread : TVstShareFilePcHideThread;

implementation

uses UMainForm, UIconUtil, UFormSelectSharePath, UFormFileShareExplorer, UNetworkFace, UMyUtil,
     UMyShareControl, UJobControl, URegisterInfo, UFormFreeEdition;

{ TLvSharePathChange }

procedure TLvSharePathChange.Update;
begin
  VstSharePath := frmMainForm.vstSharePath;
end;

{ TLvSharePathWrite }

constructor TLvSharePathWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

function TLvSharePathWrite.FindSharePathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstSharePathData;
begin
  Result := False;

  SelectNode := VstSharePath.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstSharePath.GetNodeData( SelectNode );
    if SelectData.FullPath = FullPath then
    begin
      SharePathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TLvSharePathAdd }

procedure TLvSharePathAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TLvSharePathAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindSharePathNode then
    Exit;

    // ���
  SharePathNode := VstSharePath.AddChild( VstSharePath.RootNode );
  NodeData := VstSharePath.GetNodeData( SharePathNode );
  NodeData.FullPath := FullPath;
  NodeData.PathType := PathType;

  if VstSharePath.RootNodeCount = 1 then
    frmMainForm.vstSharePath.TreeOptions.PaintOptions := frmMainForm.vstSharePath.TreeOptions.PaintOptions - [toShowBackground];
end;

{ TLvSharePathRemove }

procedure TLvSharePathRemove.Update;
begin
  inherited;

    // ������
  if not FindSharePathNode then
    Exit;

    // ɾ��
  VstSharePath.DeleteNode( SharePathNode );

  if VstSharePath.RootNodeCount = 0 then
    frmMainForm.vstSharePath.TreeOptions.PaintOptions := frmMainForm.vstSharePath.TreeOptions.PaintOptions + [toShowBackground];
end;

{ TVstSelectSharePathChange }

procedure TVstSelectSharePathChange.Update;
begin
  vstSelectSharePath := frmSelectSharePath.vstSelectPath;
end;

{ TvstSelectSharePathWrite }

constructor TVstSelectSharePathWrite.Create(_FullPath: string);
begin
  FullPath := _FullPath;
end;

{ TVstSelectSharePathAdd }

procedure TVstSelectSharePathAdd.Update;
begin
  inherited;

  frmSelectSharePath.AddBackupPath( FullPath );
end;

{ TVstSelectSharePathRemove }

procedure TVstSelectSharePathRemove.Update;
begin
  inherited;

  frmSelectSharePath.RemoveBackupPath( FullPath );
end;

{ TLvSharePcData }

constructor TLvSharePcData.Create(_PcID, _PcName: string);
begin
  PcID := _PcID;
  PcName := _PcName;
end;

{ TvstShareFileAdd }

procedure TVstShareFileAdd.SetFileInfo(_FileSize: Int64; _FileTime: TDateTime);
begin
  FileSize := _FileSize;
  FileTime := _FileTime;
end;

procedure TVstShareFileAdd.SetFilePath(_FilePath: string; _IsFolder: Boolean);
begin
  FilePath := _FilePath;
  IsFolder := _IsFolder;
end;

procedure TVstShareFileAdd.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PVstShareFolderData;
begin
  inherited;

    // �Ҳ������ڵ�
  if not FindParentNode then
    Exit;

    // ���ڵ� ���ļ�
  if ParentPath = FilePath then
  begin
    ParentData.FileSize := FileSize;
    ParentData.FileTime := FileTime;
    Exit;
  end;

  ChildNode := VstShareFile.AddChild( ParentNode );
  ChildData := VstShareFile.GetNodeData( ChildNode );
  ChildData.FilePath := FilePath;
  ChildData.IsFolder := IsFolder;
  ChildData.FileSize := FileSize;
  ChildData.FileTime := FileTime;
  ChildData.IsWaiting := False;

    // ����չ����һ��
  if IsFolder then
    VstShareFile.HasChildren[ ChildNode ] := True;

    // Check Box
  ChildNode.CheckType := ctTriStateCheckBox;
  if ParentNode.CheckState = csCheckedNormal then
    ChildNode.CheckState := csCheckedNormal;
end;

{ TVstShareFileWrite }

constructor TVstShareFileWrite.Create(_ParentPath, _DesPcID: string);
begin
  ParentPath := _ParentPath;
  DesPcID := _DesPcID;
end;

function TVstShareFileWrite.FindParentNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFolderData;
begin
  Result := False;

    // �Ҳ��� �����ļ�
  if not FindVstShareFile then
    Exit;

    // ���ظ��ڵ�
  if ParentPath = '' then
  begin
    ParentNode := VstShareFile.RootNode;
    Result := True;
  end;

  SelectNode := VstShareFile.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFile.GetNodeData( SelectNode );
    if ParentPath = SelectData.FilePath then  // �ҵ��˽ڵ�
    begin
      ParentNode := SelectNode;
      ParentData := SelectData;
      Result := True;
      Break;
    end
    else    // �ҵ��˸��ڵ�
    if MyMatchMask.CheckChild( ParentPath, SelectData.FilePath ) then
      SelectNode := SelectNode.FirstChild
    else   // ��һ���ڵ�
      SelectNode := SelectNode.NextSibling;
  end;
end;

function TVstShareFileWrite.FindVstShareFile: Boolean;
begin
  VstShareFile := VstShareFolderUtil.getVstShareFiles( DesPcID );
  Result := VstShareFile <> nil;
end;

{ TVstShareFileCompleted }

procedure TVstShareFileCompleted.SetIsShareCancel(_IsShareCancel: Boolean);
begin
  IsShareCancel := _IsShareCancel;
end;

procedure TVstShareFileCompleted.Update;
var
  RemoveNode : PVirtualNode;
  RemoveData : PVstShareFolderData;
begin
  inherited;

    // �Ҳ��� ���ڵ�
  if not FindParentNode then
    Exit;

    // ɾ���ȴ��ڵ�
  RemoveNode := ParentNode.FirstChild;
  RemoveData := VstShareFile.GetNodeData( RemoveNode );
  if RemoveData.IsWaiting then
  begin
    if IsShareCancel then
      RemoveData.FilePath := ShareFile_NotExist
    else
      VstShareFile.DeleteNode( RemoveNode );
  end;
end;

{ TVstShareDownChange }

procedure TVstShareDownChange.Update;
begin
  VstShareDown := frmMainForm.VstShareDown;
end;

{ TVstShareDownWrite }

constructor TVstShareDownWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareDownWrite.FindShareDownNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  Result := False;

  SelectNode := VstShareDown.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      ShareDownNode := SelectNode;
      ShareDownData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstShareDownWrite.RefreshShareDownNode;
begin
  VstShareDown.RepaintNode( ShareDownNode );
end;

{ TVstShareDownAdd }

procedure TVstShareDownAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareDownAdd.SetIsDecPcOnline(_IsDecPcOnline: Boolean);
begin
  IsDecPcOnline := _IsDecPcOnline;
end;

procedure TVstShareDownAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareDownAdd.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TVstShareDownAdd.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownAdd.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindShareDownNode then
    Exit;

    // �����ڵ�
  ShareDownNode := VstShareDown.AddChild( VstShareDown.RootNode );
  ShareDownData := VstShareDown.GetNodeData( ShareDownNode );
  ShareDownData.FullPath := FullPath;
  ShareDownData.PathType := PathType;
  ShareDownData.DesPcID := DesPcID;
  ShareDownData.DesPcName := DesPcName;
  ShareDownData.SavePath := SavePath;
  ShareDownData.FileSize := FileSize;
  ShareDownData.CompletedSize := CompletedSize;
  ShareDownData.IsDesPcOnline := IsDecPcOnline;
  ShareDownData.Status := Status;
  ShareDownData.IsIncompleted := False;

    // ToolButton
  if VstShareDown.RootNodeCount = 1 then
    frmMainForm.tbtnShareDownClear.Enabled := True;
end;

{ TVstShareDownRemove }

procedure TVstShareDownRemove.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteNode( ShareDownNode );

      // ToolButton
  if VstShareDown.RootNodeCount = 0 then
    frmMainForm.tbtnShareDownClear.Enabled := False;
end;

{ TVstShareDownAddFileSize }

procedure TVstShareDownAddFileSize.SetFileSize(_FileSize: Int64);
begin
  FileSize := _FileSize;
end;

procedure TVstShareDownAddFileSize.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

  ShareDownData.FileSize := ShareDownData.FileSize + FileSize;
  RefreshShareDownNode;
end;

{ TVstShareDownAddCompletedSize }

procedure TVstShareDownAddCompletedSize.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownAddCompletedSize.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

  ShareDownData.CompletedSize := ShareDownData.CompletedSize + CompletedSize;
  RefreshShareDownNode;
end;


{ TVstShareDownChildChange }

function TVstShareDownChildChange.FindFileNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  Result := False;

    // ������ ��
  if not FindShareDownNode then
    Exit;

    // �ļ� �Ǹ�
  if getIsFileNode then
  begin
    FileNode := ShareDownNode;
    FileData := ShareDownData;
    Result := True;
    Exit;
  end;

  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if SelectData.FullPath = FilePath then
    begin
      FileNode := SelectNode;
      FileData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

function TVstShareDownChildChange.getIsFileNode: Boolean;
begin
  Result := FilePath = FullPath;
end;

procedure TVstShareDownChildChange.RefreshFileNode;
begin
  VstShareDown.RepaintNode( FileNode );
end;

procedure TVstShareDownChildChange.SetFilePath(_FilePath: string);
begin
  FilePath := _FilePath;
end;

{ TVstShareDownChildAdd }

procedure TVstShareDownChildAdd.CheckFreeLimit;
begin
  if not App_IsFreeLimit then
    Exit;

    // ��һ���ڵ㣬�� Disable
  if ( ShareDownNode.ChildCount = 1 ) and EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    ShareDownData.IsIncompleted := True;
    RefreshShareDownNode; // ˢ�¸��ڵ�
  end
  else
  if ShareDownData.IsIncompleted and not EditionUtil.getIsLimitFileSendSpace( FileSize ) then
  begin
    ShareDownData.IsIncompleted := False;
    RefreshShareDownNode; // ˢ�¸��ڵ�
  end;
end;

procedure TVstShareDownChildAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareDownChildAdd.SetIsPcOnline(_IsDecPcOnline: Boolean);
begin
  IsDecPcOnline := _IsDecPcOnline;
end;

procedure TVstShareDownChildAdd.SetSavePath(_SavePath: string);
begin
  SavePath := _SavePath;
end;

procedure TVstShareDownChildAdd.SetSizeInfo(_FileSize, _CompletedSize: Int64);
begin
  FileSize := _FileSize;
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildAdd.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownChildAdd.Update;
begin
  inherited;

    // �����ڸ��ڵ�
  if not FindShareDownNode then
    Exit;

    // �ļ� �Ǹ�
  if getIsFileNode then
    Exit;

  FileNode := VstShareDown.AddChild( ShareDownNode );
  FileData := VstShareDown.GetNodeData( FileNode );
  FileData.FullPath := FilePath;
  FileData.PathType := SharePathType_File;
  FileData.DesPcID := DesPcID;
  FileData.DesPcName := DesPcName;
  FileData.FileSize := FileSize;
  FileData.CompletedSize := CompletedSize;
  FileData.IsDesPcOnline := IsDecPcOnline;
  FileData.Status := Status;
  FileData.SavePath := SavePath;

    // ��� ��Ѱ�����
  CheckFreeLimit;
end;

{ TVstShareDownChildAddCompletedSize }

procedure TVstShareDownChildAddCompletedSize.SetCompletedSize(
  _CompletedSize: Integer);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildAddCompletedSize.Update;
begin
  inherited;

    // ������
  if not FindFileNode then
    Exit;

    // ���ڵ� ���ļ��ڵ�
  if getIsFileNode then
    Exit;

  FileData.CompletedSize := FileData.CompletedSize + CompletedSize;

  RefreshFileNode;
end;

{ TVstShareDownChildRemove }

procedure TVstShareDownChildRemove.CheckFreeLimit;
var
  IsExistDisableNode : Boolean;
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  if not App_IsFreeLimit then
    Exit;

  if ShareDownData.IsIncompleted then
    Exit;

    // �Ƿ� ֻ���� Disable �ڵ�
  IsExistDisableNode := False;
  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    if EditionUtil.getIsLimitShareSpace( SelectData.FileSize ) then
      IsExistDisableNode := True
    else
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // ������
  if not IsExistDisableNode then
    Exit;

    // ����·�� ����Ѱ�Ӱ��
  ShareDownData.IsIncompleted := True;
  VstShareDown.RepaintNode( ShareDownNode );
  VstShareDown.Expanded[ ShareDownNode ] := True;

    // ��ʾ ���ð�����
  frmFreeEdition.ShowWarnning( FreeEditionError_ShareDownSize );
end;

procedure TVstShareDownChildRemove.Update;
begin
  inherited;

    // ������
  if not FindFileNode then
    Exit;

    // �ļ� ���ڵ�
  if getIsFileNode then
  begin
//    ShareDownData.CompletedSize := ShareDownData.FileSize;
    Exit;
  end;

  VstShareDown.DeleteNode( FileNode );

    // ����Ƿ�����Ѱ�����
  CheckFreeLimit;
end;

{ TVstShareDownChildSetStatus }

procedure TVstShareDownChildSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownChildSetStatus.Update;
begin
  inherited;

    // ������
  if not FindFileNode then
    Exit;

  FileData.Status := Status;

  RefreshFileNode;
end;

{ TLvDownSharePcChange }

procedure TLvDownSharePcChange.Update;
begin
  LvDownSharePc := frmShareExplorer.LvSharePc;
end;

{ TLvDownSharePcWrite }

constructor TLvDownSharePcWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TLvDownSharePcWrite.FindPcItem: Boolean;
var
  i : Integer;
  SelectData : TLvSharePcData;
begin
  Result := False;

  for i := 0 to LvDownSharePc.Items.Count - 1 do
  begin
    SelectData := LvDownSharePc.Items[i].Data;
    if SelectData.PcID = PcID then
    begin
      PcItem := LvDownSharePc.Items[i];
      PcData := SelectData;
      PcIndex := i;
      Result := True;
      Break;
    end;
  end;
end;

{ TLvDownSharePcAdd }

procedure TLvDownSharePcAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TLvDownSharePcAdd.Update;
begin
  inherited;

    // ��������
  if PcID = Network_LocalPcID then
    Exit;

    // �Ѵ���
  if FindPcItem then
    Exit;

  PcData := TLvSharePcData.Create( PcID, PcName );
  with LvDownSharePc.Items.Add do
  begin
    Caption := PcName;
    ImageIndex := CloudStatusIcon_Online;
    Data := PcData;
  end;
end;

{ TLvDownSharePcRemove }

procedure TLvDownSharePcRemove.Update;
var
  ts : TRzTabSheet;
begin
  inherited;

    // ������
  if not FindPcItem then
    Exit;

    // ɾ�� Tab
  ts := VstShareFolderUtil.getTap( PcData.PcID );
  if ts <> nil then
    ts.Destroy;

    // ɾ��
  LvDownSharePc.Items.Delete( PcIndex );
end;

{ TLvDownSharePcClear }

procedure TLvDownSharePcClear.Update;
var
  i : Integer;
  PcShareFiles : TRzPageControl;
begin
  inherited;

    // ��� Pc
  LvDownSharePc.Clear;

    // ����ļ�
  PcShareFiles := frmShareExplorer.PcShareFile;
  for i := PcShareFiles.PageCount - 1 downto 0 do
    PcShareFiles.Pages[i].Destroy;
end;

{ VstShareFolderUtil }

class function VstShareFolderUtil.getFrame(ts: TRzTabSheet): TFrameShareFiles;
var
  i  : Integer;
  c : TControl;
begin
  Result := nil;

  for i := 0 to ts.ControlCount - 1 do
  begin
    c := ts.Controls[i];
    if c is TFrameShareFiles then
    begin
      Result := c as TFrameShareFiles;
      Break;
    end;
  end;
end;

class function VstShareFolderUtil.getTap(DesPcID: string): TRzTabSheet;
var
  PcShareFile : TRzPageControl;
  i, j  : Integer;
  ts : TRzTabSheet;
  c : TControl;
  f : TFrameShareFiles;
begin
  Result := nil;

  PcShareFile := frmShareExplorer.PcShareFile;
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    ts := PcShareFile.Pages[i];
    for j := 0 to ts.ControlCount - 1 do
    begin
      c := ts.Controls[j];
      if c is TFrameShareFiles then
      begin
        f := c as TFrameShareFiles;
        if f.SharePcID = DesPcID then
          Result := ts;
        Break;
      end;
    end;
  end;
end;

class function VstShareFolderUtil.getVstShareFiles(
  DesPcID: string): TVirtualStringTree;
var
  PcShareFile : TRzPageControl;
  i, j  : Integer;
  ts : TRzTabSheet;
  c : TControl;
  f : TFrameShareFiles;
begin
  Result := nil;

  PcShareFile := frmShareExplorer.PcShareFile;
  for i := 0 to PcShareFile.PageCount - 1 do
  begin
    ts := PcShareFile.Pages[i];
    for j := 0 to ts.ControlCount - 1 do
    begin
      c := ts.Controls[j];
      if c is TFrameShareFiles then
      begin
        f := c as TFrameShareFiles;
        if f.SharePcID = DesPcID then
          Result := f.vstShareFiles;
        Break;
      end;
    end;
  end;
end;

{ TVstShareDownChildSetCompletedSize }

procedure TVstShareDownChildSetCompletedSize.SetCompletedSize(
  _CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownChildSetCompletedSize.Update;
begin
  inherited;

    // ������
  if not FindFileNode then
    Exit;

  FileData.CompletedSize := CompletedSize;
  RefreshFileNode;
end;

{ TVstShareDownIsOnline }

procedure TVstShareDownIsOnline.SetToChildNode;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareDownData;
begin
  SelectNode := ShareDownNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareDown.GetNodeData( SelectNode );
    SelectData.IsDesPcOnline := IsOnline;
    VstShareDown.RepaintNode( SelectNode );
    SelectNode := SelectNode.NextSibling;
  end;
end;

procedure TVstShareDownIsOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareDownIsOnline.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

    // ���� ���ڵ�
  ShareDownData.IsDesPcOnline := IsOnline;
  RefreshShareDownNode;

    // ���� �ӽڵ�
  SetToChildNode;
end;

{ VstShareDownUtil }

class function VstShareDownUtil.getIsFreeLimit(Node: PVirtualNode): Boolean;
var
  NodeData : PVstShareDownData;
begin
  Result := False;
  if not App_IsFreeLimit then
    Exit;

  NodeData := frmMainForm.VstShareDown.GetNodeData( Node );
  if NodeData.PathType = SharePathType_File then
    Result := NodeData.FileSize > FreeEditionLimit_ShareFileSize
  else
  begin
    Result := NodeData.IsIncompleted;
    if Result then
      frmMainForm.VstShareDown.Expanded[ Node ] := True;
  end;
end;

class function VstShareDownUtil.getNodeIcon(Node: PVirtualNode): Integer;
var
  NodeData : PVstShareDownData;
begin
  NodeData := frmMainForm.VstShareDown.GetNodeData( Node );
  if App_IsFreeLimit and ( Node.Parent = frmMainForm.VstShareDown.RootNode ) and
       NodeData.IsIncompleted
  then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if NodeData.Status = FileShareStatus_Cancel then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if ( Node.Parent = frmMainForm.VstShareDown.RootNode ) and
     ( NodeData.CompletedSize >= NodeData.FileSize )
  then
    Result := MyShellTransActionIconUtil.getLoaded
  else
  if not NodeData.IsDesPcOnline then
    Result := MyShellTransActionIconUtil.getLoadedError
  else
  if getIsFreeLimit( Node ) then
    Result := MyShellTransActionIconUtil.getDisable
  else
  if NodeData.Status = FileShareStatus_Waiting then
    Result := MyShellTransActionIconUtil.getWaiting
  else
  if NodeData.Status = FileShareStatus_Downloading then
    Result := MyShellTransActionIconUtil.getDownLoading
  else
    Result := MyShellTransActionIconUtil.getLoadedError;
end;

{ TVstShareDownSetStatus }

procedure TVstShareDownSetStatus.SetStatus(_Status: string);
begin
  Status := _Status;
end;

procedure TVstShareDownSetStatus.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

    // ���� ���ڵ�
  ShareDownData.Status := Status;
  RefreshShareDownNode;
end;

{ TVstShareDownSetCompletedSize }

procedure TVstShareDownSetCompletedSize.SetCompletedSize(_CompletedSize: Int64);
begin
  CompletedSize := _CompletedSize;
end;

procedure TVstShareDownSetCompletedSize.Update;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

  ShareDownData.CompletedSize := CompletedSize;
  RefreshShareDownNode;
end;

{ TVstShareHistoryChange }

procedure TVstShareHistoryChange.RefreshClearBtn;
begin
  frmShareExplorer.tbtnShareHistoryClear.Enabled := VstShareHistory.VisibleCount > 0;

    // ��ʾ
  if not frmShareExplorer.tbtnHistory.Visible and
     ( VstShareHistory.VisibleCount > 0 )
  then
  begin
    frmShareExplorer.tbtnHistory.Visible := True;
    if not frmShareExplorer.tbComputer.Visible then
      frmShareExplorer.tbComputer.Visible := True;
  end;
end;

procedure TVstShareHistoryChange.Update;
begin
  VstShareHistory := frmShareExplorer.VstHisroty;
end;

{ TVstShareHistoryWrite }

constructor TVstShareHistoryWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareHistoryWrite.FindPathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  Result := False;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstShareHistoryAdd }

procedure TVstShareHistoryAdd.CheckRemove;
var
  RemoveNode : PVirtualNode;
  RemoveData : PVstShareHistoryData;
begin
  if VstShareHistory.RootNodeCount <= MaxCount_History then
    Exit;

  RemoveNode := VstShareHistory.RootNode.LastChild;
  if not Assigned( RemoveNode ) then
    Exit;

    // ɾ��
  RemoveData := VstShareHistory.GetNodeData( RemoveNode );
  MyFileShareControl.RemoveHistory( RemoveData.FullPath, RemoveData.DesPcID );
end;

procedure TVstShareHistoryAdd.SetDesPcIsOnline(_DesPcIsOnline: Boolean);
begin
  DesPcIsOnline := _DesPcIsOnline;
end;

procedure TVstShareHistoryAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareHistoryAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareHistoryAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindPathNode then
    Exit;

    // ���
  PathNode := VstShareHistory.InsertNode( VstShareHistory.RootNode, amAddChildFirst );
  NodeData := VstShareHistory.GetNodeData( PathNode );
  NodeData.FullPath := FullPath;
  NodeData.DesPcID := DesPcID;
  NodeData.DesPcName := DesPcName;
  NodeData.PathType := PathType;

    // ��������ʾ
  VstShareHistory.IsVisible[ PathNode ] := DesPcIsOnline;

    // ˢ�������ť
  RefreshClearBtn;

    // ���� 20�� ��ɾ��
  CheckRemove;
end;

{ TVstShareHistoryRemove }

procedure TVstShareHistoryRemove.Update;
begin
  inherited;

    // ������
  if not FindPathNode then
    Exit;

  VstShareHistory.DeleteNode( PathNode );

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareFavorityChange }

procedure TVstShareFavorityChange.RefreshClearBtn;
begin
  frmShareExplorer.tbtnShareFavoriteClear.Enabled := VstShareFavority.VisibleCount > 0;

    // ��ʾ
  if not frmShareExplorer.tbtnFavorite.Visible and
     ( VstShareFavority.VisibleCount > 0 )
  then
  begin
    frmShareExplorer.tbtnFavorite.Visible := True;
    if not frmShareExplorer.tbComputer.Visible then
      frmShareExplorer.tbComputer.Visible := True;
  end;
end;

procedure TVstShareFavorityChange.Update;
begin
  VstShareFavority := frmShareExplorer.VstFavorite;
end;

{ TVstShareFavorityWrite }

constructor TVstShareFavorityWrite.Create(_FullPath, _DesPcID: string);
begin
  FullPath := _FullPath;
  DesPcID := _DesPcID;
end;

function TVstShareFavorityWrite.FindPathNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  Result := False;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    if ( SelectData.FullPath = FullPath ) and
       ( SelectData.DesPcID = DesPcID )
    then
    begin
      PathNode := SelectNode;
      NodeData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;

{ TVstShareFavorityAdd }

procedure TVstShareFavorityAdd.SetDesPcIsOnline(_DesPcIsOnline: Boolean);
begin
  DesPcIsOnline := _DesPcIsOnline;
end;

procedure TVstShareFavorityAdd.SetDesPcName(_DesPcName: string);
begin
  DesPcName := _DesPcName;
end;

procedure TVstShareFavorityAdd.SetPathType(_PathType: string);
begin
  PathType := _PathType;
end;

procedure TVstShareFavorityAdd.Update;
begin
  inherited;

    // �Ѵ���
  if FindPathNode then
    Exit;

    // ���
  PathNode := VstShareFavority.AddChild( VstShareFavority.RootNode );
  NodeData := VstShareFavority.GetNodeData( PathNode );
  NodeData.FullPath := FullPath;
  NodeData.DesPcID := DesPcID;
  NodeData.DesPcName := DesPcName;
  NodeData.PathType := PathType;

    // ��������ʾ
  VstShareFavority.IsVisible[ PathNode ] := DesPcIsOnline;

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareFavorityRemove }

procedure TVstShareFavorityRemove.Update;
begin
  inherited;

    // ������
  if not FindPathNode then
    Exit;

  VstShareFavority.DeleteNode( PathNode );

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareHistoryPcOnline }

constructor TVstShareHistoryPcOnline.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstShareHistoryPcOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareHistoryPcOnline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  inherited;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    if SelectData.DesPcID = PcID then
      VstShareHistory.IsVisible[ SelectNode ] := IsOnline;
    SelectNode := SelectNode.NextSibling;
  end;

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareFavorityPcOnline }

constructor TVstShareFavorityPcOnline.Create(_PcID: string);
begin
  PcID := _PcID;
end;

procedure TVstShareFavorityPcOnline.SetIsOnline(_IsOnline: Boolean);
begin
  IsOnline := _IsOnline;
end;

procedure TVstShareFavorityPcOnline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  inherited;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    if SelectData.DesPcID = PcID then
      VstShareFavority.IsVisible[ SelectNode ] := IsOnline;
    SelectNode := SelectNode.NextSibling;
  end;

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareHistoryServerOffline }

procedure TVstShareHistoryServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareHistoryData;
begin
  inherited;

  SelectNode := VstShareHistory.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareHistory.GetNodeData( SelectNode );
    VstShareHistory.IsVisible[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareFavorityServerOffline }

procedure TVstShareFavorityServerOffline.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFavorityData;
begin
  inherited;

  SelectNode := VstShareFavority.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFavority.GetNodeData( SelectNode );
    VstShareFavority.IsVisible[ SelectNode ] := False;
    SelectNode := SelectNode.NextSibling;
  end;

    // ˢ�������ť
  RefreshClearBtn;
end;

{ TVstShareDownClearJob }

procedure TVstShareDownClearJob.RemoveJob(ChildPath: string);
var
  TransferFileShareJobRemoveHandle : TTransferFileShareJobRemoveHandle;
begin
  TransferFileShareJobRemoveHandle := TTransferFileShareJobRemoveHandle.Create( ChildPath, DesPcID );
  TransferFileShareJobRemoveHandle.Update;
  TransferFileShareJobRemoveHandle.Free;
end;


procedure TVstShareDownClearJob.Update;
var
  ChildNode : PVirtualNode;
  ChildData : PVstShareDownData;
begin
  inherited;

    // ������
  if not FindShareDownNode then
    Exit;

    // ɾ�� �ӽڵ�� Job
  ChildNode := ShareDownNode.FirstChild;
  while Assigned( ChildNode ) do
  begin
    ChildData := VstShareDown.GetNodeData( ChildNode );
    RemoveJob( ChildData.SavePath );
    ChildNode := ChildNode.NextSibling;
  end;
end;

{ TVstShareDownClearChild }

procedure TVstShareDownClearChild.Update;
begin
  inherited;

  if not FindShareDownNode then
    Exit;

  VstShareDown.DeleteChildren( ShareDownNode );
  VstShareDown.Expanded[ ShareDownNode ] := False;
  RefreshShareDownNode;
end;

{ TVstShareFilePcChange }

procedure TVstShareFilePcChange.ResetExistSharePc(IsExist: Boolean);
begin
  frmMainForm.tbtnShareDownAdd.Enabled := IsExist;
  frmMainForm.PlNoSharePc.Visible := not IsExist;
end;

procedure TVstShareFilePcChange.Update;
begin
  VstShareFilePc := frmMainForm.VstShareFilePc;
end;

{ TVstShareFilePcWrite }

constructor TVstShareFilePcWrite.Create(_PcID: string);
begin
  PcID := _PcID;
end;

function TVstShareFilePcWrite.FindPcNode: Boolean;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
begin
  Result := False;

  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.PcID = PcID then
    begin
      PcNode := SelectNode;
      PcData := SelectData;
      Result := True;
      Break;
    end;
    SelectNode := SelectNode.NextSibling;
  end;
end;


procedure TVstShareFilePcWrite.RefreshPcNode;
begin
  VstShareFilePc.RepaintNode( PcNode );
end;

{ TVstShareFilePcAdd }

procedure TVstShareFilePcAdd.SetPcName(_PcName: string);
begin
  PcName := _PcName;
end;

procedure TVstShareFilePcAdd.Update;
begin
  inherited;

    // ��������
  if PcID = Network_LocalPcID then
    Exit;

    // �Ѵ���
  if FindPcNode then
    Exit;

    // ���
  PcNode := VstShareFilePc.AddChild( VstShareFilePc.RootNode );
  PcData := VstShareFilePc.GetNodeData( PcNode );
  PcData.PcID := PcID;
  PcData.PcName := PcName;

    // �����˹��� Pc
  if VstShareFilePc.RootNodeCount = 1 then
    ResetExistSharePc( True );
end;

{ TVstShareFilePcRemove }

procedure TVstShareFilePcRemove.Update;
begin
  inherited;

    // ������
  if not FindPcNode then
    Exit;

    // ɾ��
  VstShareFilePc.DeleteNode( PcNode );

    // û���˹��� Pc
  if VstShareFilePc.RootNodeCount = 0 then
    ResetExistSharePc( False );
end;

{ TVstShareFileClear }

procedure TVstShareFileClear.Update;
begin
  inherited;

  VstShareFilePc.Clear;
end;

{ TVstShareFileCheckExistShare }

procedure TVstShareFileCheckExistShare.Update;
begin
  inherited;
  frmMainForm.tmrCheckExistPc.Enabled := True;
end;

{ TVstFileTransferDesAddDownload }

procedure TVstShareFilePcAddDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount + 1;

    // ��ʾ������
  if ( PcData.DownloadCount = 1 ) then
  begin
    PcData.IsShowDownload := True;

    VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Download ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

    // ˢ����ʾ
  RefreshPcNode;
end;

{ TVstFileTransferDesRemoveDownload }

procedure TVstShareFilePcRemoveDownload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.DownloadCount := PcData.DownloadCount - 1;
  RefreshPcNode;

    // ����������
  if ( PcData.DownloadCount = 0 ) then
    VstShareFilePcHideThread.AddDownHideInfo( PcID );
end;

{ TVstFileTransferDesRemoveUpload }

procedure TVstShareFilePcRemoveUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount - 1;
  RefreshPcNode;

    // �����ϴ���
  if ( PcData.UploadCount = 0 ) then
    VstShareFilePcHideThread.AddUpHideInfo( PcID );
end;

{ TVstFileTransferDesAddUpload }

procedure TVstShareFilePcAddUpload.Update;
var
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

  PcData.UploadCount := PcData.UploadCount + 1;

    // ��ʾ�ϴ���
  if ( PcData.UploadCount = 1 ) then
  begin
    PcData.IsShowUpload := True;

    VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Upload ];
    VtCol.Options := VtCol.Options + [coVisible];
  end;

  RefreshPcNode;
end;

{ TVstFileTransferDesHidePcDownload }

procedure TVstShareFilePcHidePcDownload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // ���� ����, ����
  if PcData.DownloadCount > 0 then
    Exit;

    // ����������
  PcData.IsShowDownload := False;
  RefreshPcNode;

    // �Ƿ� ������ ������
  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.IsShowDownload then // ����
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

    // ����
  VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Download ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstFileTransferDesHidePcUpload }

procedure TVstShareFilePcHidePcUpload.Update;
var
  SelectNode : PVirtualNode;
  SelectData : PVstShareFilePcData;
  VtCol : TVirtualTreeColumn;
begin
  inherited;

  if not FindPcNode then
    Exit;

    // ��ʾ������
  if PcData.UploadCount > 0 then
    Exit;

  PcData.IsShowUpload := False;
  VstShareFilePc.RepaintNode( PcNode );

    // �Ƿ� ������ ������
  SelectNode := VstShareFilePc.RootNode.FirstChild;
  while Assigned( SelectNode ) do
  begin
    SelectData := VstShareFilePc.GetNodeData( SelectNode );
    if SelectData.IsShowUpload then // ����
      Exit;
    SelectNode := SelectNode.NextSibling;
  end;

  VtCol := VstShareFilePc.Header.Columns[ VstSharePc_Upload ];
  VtCol.Options := VtCol.Options - [coVisible];
end;

{ TVstFileSendDesHideInfo }

constructor TVstShareFilePcHideInfo.Create(_PcID: string);
begin
  PcID := _PcID;
  StartTime := Now;
end;

{ TVstFileSendDesHideThread }

procedure TVstShareFilePcHideThread.AddDownHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstShareFilePcHideInfo;
begin
  Lock.Enter;
  if VstShareFilePcHideDownHash.ContainsKey( PcID ) then
    VstShareFilePcHideDownHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstShareFilePcHideInfo.Create( PcID );
    VstShareFilePcHideDownHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstShareFilePcHideThread.AddUpHideInfo(PcID: string);
var
  VstFileSendDesHideInfo : TVstShareFilePcHideInfo;
begin
  Lock.Enter;
  if VstShareFilePcHideUpHash.ContainsKey( PcID ) then
    VstShareFilePcHideUpHash[ PcID ].StartTime := Now
  else
  begin
    VstFileSendDesHideInfo := TVstShareFilePcHideInfo.Create( PcID );
    VstShareFilePcHideUpHash.AddOrSetValue( PcID, VstFileSendDesHideInfo );
  end;
  Lock.Leave;

  Resume;
end;

procedure TVstShareFilePcHideThread.CheckLvHideDown;
var
  RemoveList : TStringList;
  p : TVstShareFilePcHidePair;
  VstShareFilePcHidePcDownload : TVstShareFilePcHidePcDownload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstShareFilePcHideDownHash do
  begin
      // û�е����ص�ʱ��, ����
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // ��� ����
    RemoveList.Add( p.Value.PcID );
  end;
    // ���� ����
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstShareFilePcHideDownHash.Remove( PcID );
          // ���� ����
    VstShareFilePcHidePcDownload := TVstShareFilePcHidePcDownload.Create( PcID );
    MyFaceChange.AddChange( VstShareFilePcHidePcDownload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;

procedure TVstShareFilePcHideThread.CheckLvHideUp;
var
  RemoveList : TStringList;
  p : TVstShareFilePcHidePair;
  VstShareFilePcHidePcUpload : TVstShareFilePcHidePcUpload;
  i : Integer;
  PcID : string;
begin
  RemoveList := TStringList.Create;
  Lock.Enter;
  for p in VstShareFilePcHideUpHash do
  begin
      // û�е����ص�ʱ��, ����
    if SecondsBetween( Now, p.Value.StartTime ) < 2 then
      Continue;

      // ��� ����
    RemoveList.Add( p.Value.PcID );
  end;
    // ���� ����
  for i := 0 to RemoveList.Count - 1 do
  begin
    PcID := RemoveList[ i ];
    VstShareFilePcHideUpHash.Remove( PcID );
          // ���� ����
    VstShareFilePcHidePcUpload := TVstShareFilePcHidePcUpload.Create( PcID );
    MyFaceChange.AddChange( VstShareFilePcHidePcUpload );
  end;
  Lock.Leave;
  RemoveList.Free;
end;


constructor TVstShareFilePcHideThread.Create;
begin
  inherited Create( True );

  Lock := TCriticalSection.Create;
  VstShareFilePcHideDownHash := TVstShareFilePcHideHash.Create;
  VstShareFilePcHideUpHash := TVstShareFilePcHideHash.Create;
end;

destructor TVstShareFilePcHideThread.Destroy;
begin
  Terminate;
  Resume;
  WaitFor;

  VstShareFilePcHideDownHash.Free;
  VstShareFilePcHideUpHash.Free;
  Lock.Free;
  inherited;
end;

procedure TVstShareFilePcHideThread.Execute;
begin
  while not Terminated do
  begin
    if not ExistHidePc then
    begin
      Suspend;
      Continue;
    end;

    if Terminated then
      Break;

    CheckLvHideDown;
    CheckLvHideUp;

    Sleep(100);
  end;

  inherited;
end;


function TVstShareFilePcHideThread.ExistHidePc: Boolean;
begin
  Lock.Enter;
  Result := ( VstShareFilePcHideDownHash.Count > 0 ) or
            ( VstShareFilePcHideUpHash.Count > 0 );
  Lock.Leave;
end;


end.


