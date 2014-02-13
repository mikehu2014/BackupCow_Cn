program BackupCow;

uses
  Forms,
  Windows,
  Messages,
  Dialogs,
  SysUtils,
  UBackupInfoControl in 'UiniBackup\UBackupInfoControl.pas',
  UBackupInfoFace in 'UiniBackup\UBackupInfoFace.pas',
  UBackupInfoXml in 'UiniBackup\UBackupInfoXml.pas',
  UBackupFileScan in 'UiniBackup\UBackupFileScan.pas',
  UFormBackupPath in 'UiniBackup\UFormBackupPath.pas' {frmSelectBackupPath},
  UMyBackupInfo in 'UiniBackup\UMyBackupInfo.pas',
  UMyCloudPathInfo in 'UnitCloud\UMyCloudPathInfo.pas',
  UFileBaseInfo in 'UnitUtil\UFileBaseInfo.pas',
  UFormUtil in 'UnitUtil\UFormUtil.pas',
  UModelUtil in 'UnitUtil\UModelUtil.pas',
  UMyUtil in 'UnitUtil\UMyUtil.pas',
  UXmlUtil in 'UnitUtil\UXmlUtil.pas',
  UBackupCow in 'UnitMain\UBackupCow.pas',
  USearchServer in 'UnitNetwork\USearchServer.pas',
  UFormBroadcast in 'UnitNetwork\UFormBroadcast.pas' {frmBroadcast},
  UNetworkControl in 'UnitNetwork\UNetworkControl.pas',
  UMyNetPcInfo in 'UnitNetwork\UMyNetPcInfo.pas',
  uLkJSON in 'UnitUtil\uLkJSON.pas',
  UNetworkFace in 'UnitNetwork\UNetworkFace.pas',
  UMyTcp in 'UnitNetwork\UMyTcp.pas',
  UMyServer in 'UnitNetwork\UMyServer.pas',
  UMyClient in 'UnitNetwork\UMyClient.pas',
  UMyMaster in 'UnitNetwork\UMyMaster.pas',
  UBackupJobScan in 'UnitJob\UBackupJobScan.pas',
  UJobFace in 'UnitJob\UJobFace.pas',
  UMyFileUpload in 'UnitJob\UMyFileUpload.pas',
  UMyFileDownload in 'UnitJob\UMyFileDownload.pas',
  UJobControl in 'UnitJob\UJobControl.pas',
  UMyFileTransfer in 'UnitJob\UMyFileTransfer.pas',
  UBackupUtil in 'UiniBackup\UBackupUtil.pas',
  UMyJobInfo in 'UnitJob\UMyJobInfo.pas',
  UChangeInfo in 'UnitUtil\UChangeInfo.pas',
  uDebug in 'UnitUtil\uDebug.pas',
  UCloudPathInfoXml in 'UnitCloud\UCloudPathInfoXml.pas',
  UMyFileSearch in 'UnitSearch\UMyFileSearch.pas',
  USearchFileFace in 'UnitSearch\USearchFileFace.pas',
  UFileSearchControl in 'UnitSearch\UFileSearchControl.pas',
  UFormFileStatusDetail in 'UiniBackup\UFormFileStatusDetail.pas' {frmFileStatusDetail},
  UFormSetting in 'UnitMain\UFormSetting.pas' {frmSetting},
  USettingInfo in 'UnitMain\USettingInfo.pas',
  uEncrypt in 'UnitUtil\uEncrypt.pas',
  UMainFormFace in 'UnitMain\UMainFormFace.pas',
  UNetPcInfoXml in 'UnitNetwork\UNetPcInfoXml.pas',
  UFormRestorePath in 'UnitRestore\UFormRestorePath.pas' {frmRestore},
  URestoreFileFace in 'UnitRestore\URestoreFileFace.pas',
  CnMD5 in 'UnitUtil\CnMD5.pas',
  UIconUtil in 'UnitUtil\UIconUtil.pas',
  UMyUrl in 'UnitUtil\UMyUrl.pas',
  UFormAbout in 'UnitMain\UFormAbout.pas' {frmAbout},
  UFormRegisterNew in 'UnitMain\UFormRegisterNew.pas' {frmRegisterNew},
  URegisterInfo in 'UnitMain\URegisterInfo.pas',
  CRC in 'UnitUtil\CRC.pas',
  FGInt in 'UnitUtil\FGInt.pas',
  FGIntRSA in 'UnitUtil\FGIntRSA.pas',
  kg_dnc in 'UnitUtil\kg_dnc.pas',
  URegisterInfoIO in 'UnitMain\URegisterInfoIO.pas',
  UMyBackupRemoveInfo in 'UnitBackupRemove\UMyBackupRemoveInfo.pas',
  UBackupFileLostConn in 'UiniBackup\UBackupFileLostConn.pas',
  UFormRestoreDetail in 'UnitRestore\UFormRestoreDetail.pas' {frmRestoreDetail},
  UMyCloudFileControl in 'UnitCloud\UMyCloudFileControl.pas',
  UFormSearchOwnerDecrypt in 'UnitSearch\UFormSearchOwnerDecrypt.pas' {frmIvDecrypt},
  UFormSearchFileDecrypt in 'UnitSearch\UFormSearchFileDecrypt.pas' {frmSearchFileDecrypt},
  UMySearchDownInfo in 'UnitSearch\UMySearchDownInfo.pas',
  UMySearchDownXml in 'UnitSearch\UMySearchDownXml.pas',
  UMyRestoreFileInfo in 'UnitRestore\UMyRestoreFileInfo.pas',
  UMyRestoreFileXml in 'UnitRestore\UMyRestoreFileXml.pas',
  UBackupBoardInfo in 'UiniBackup\UBackupBoardInfo.pas',
  UAppEditionInfo in 'UnitMain\UAppEditionInfo.pas',
  Defence in 'UnitUtil\Defence.pas',
  uDebugLock in 'UnitUtil\uDebugLock.pas',
  UFormNetworkPcDetail in 'UnitNetwork\UFormNetworkPcDetail.pas' {frmNetworkPcDetail},
  UFormBackupProperties in 'UiniBackup\UFormBackupProperties.pas' {frmBackupProperties},
  UFormSelectTransfer in 'UnitTransfer\UFormSelectTransfer.pas' {frmSelectTransfer},
  UFileTransferFace in 'UnitTransfer\UFileTransferFace.pas',
  UMyFileTransferControl in 'UnitTransfer\UMyFileTransferControl.pas',
  UMyFileTransferInfo in 'UnitTransfer\UMyFileTransferInfo.pas',
  UTransferJobScan in 'UnitTransfer\UTransferJobScan.pas',
  UMyFileTransferXml in 'UnitTransfer\UMyFileTransferXml.pas',
  UFormFileShareExplorer in 'UnitShare\UFormFileShareExplorer.pas' {frmShareExplorer},
  UFormLocalBackupPath in 'UnitLocalBackup\UFormLocalBackupPath.pas' {frmSelectLocalBackupPath},
  UFormFreeEdition in 'UnitMain\UFormFreeEdition.pas' {frmFreeEdition},
  UFromEnterGroup in 'UnitNetwork\UFromEnterGroup.pas' {frmJoinGroup},
  UFormConnPc in 'UnitNetwork\UFormConnPc.pas' {frmConnComputer},
  UMainForm in 'UnitMain\UMainForm.pas' {frmMainForm},
  UFormExitWarnning in 'UnitMain\UFormExitWarnning.pas' {frmExitConfirm},
  UPortMap in 'UnitNetwork\UPortMap.pas',
  UDebugForm in 'UnitMain\UDebugForm.pas' {Form12},
  UMyShareScan in 'UnitShare\UMyShareScan.pas',
  UMyShareControl in 'UnitShare\UMyShareControl.pas',
  UMyShareInfo in 'UnitShare\UMyShareInfo.pas',
  UMyShareXml in 'UnitShare\UMyShareXml.pas',
  UMyShareFace in 'UnitShare\UMyShareFace.pas',
  UFormSelectSharePath in 'UnitShare\UFormSelectSharePath.pas' {frmSelectSharePath},
  UFmShareFileExplorer in 'UnitShare\UFmShareFileExplorer.pas' {FrameShareFiles: TFrame},
  ULocalBackupInfo in 'UnitLocalBackup\ULocalBackupInfo.pas',
  ULocalBackupXml in 'UnitLocalBackup\ULocalBackupXml.pas',
  ULocalBackupFace in 'UnitLocalBackup\ULocalBackupFace.pas',
  ULocalBackupControl in 'UnitLocalBackup\ULocalBackupControl.pas',
  UBackupThread in 'UnitBackup_New\UBackupThread.pas',
  UFormSelectDes in 'UnitLocalBackup\UFormSelectDes.pas' {frmSelectLocalBackupDes},
  UMyBackupRemoveXml in 'UnitBackupRemove\UMyBackupRemoveXml.pas',
  UMyBackupRemoveControl in 'UnitBackupRemove\UMyBackupRemoveControl.pas',
  UBackupFileConfirm in 'UiniBackup\UBackupFileConfirm.pas',
  UCloudFileScan in 'UnitCloud\UCloudFileScan.pas',
  UFormFileSelect in 'UnitUtil\UFormFileSelect.pas' {frmFileSelect},
  UFormSelectMask in 'UnitUtil\UFormSelectMask.pas' {FrmEnterMask},
  UFormSpaceLimit in 'UnitUtil\UFormSpaceLimit.pas' {frmSpaceLimit},
  UFmFilter in 'UnitUtil\UFmFilter.pas' {FrameFilter: TFrame},
  UFormBackupItemApply in 'UiniBackup\UFormBackupItemApply.pas' {frmBackupItemsApply},
  UBackupAutoSyncInfo in 'UiniBackup\UBackupAutoSyncInfo.pas',
  UFrameFilter in 'UnitUtil\UFrameFilter.pas' {FrameFilterPage: TFrame},
  UFormLocalBackupPro in 'UnitLocalBackup\UFormLocalBackupPro.pas' {FrmLocalBackupPro},
  UFormSelectLocalSource in 'UnitLocalBackup\UFormSelectLocalSource.pas' {frmSelectLocalBackupSource},
  UFormSelectLocalDes in 'UnitLocalBackup\UFormSelectLocalDes.pas' {frmSelectLocalDes},
  UMyRestoreFileControl in 'UnitRestore\UMyRestoreFileControl.pas',
  UFormSelectReceiveFile in 'UnitTransfer\UFormSelectReceiveFile.pas' {frmSelectReceive},
  ULocalBackupAutoSync in 'UnitLocalBackup\ULocalBackupAutoSync.pas',
  UDataSetInfo in 'UnitUtil\UDataSetInfo.pas',
  UMyBackupDataInfo in 'UnitBackup_New\UMyBackupDataInfo.pas',
  UMyBackupFaceInfo in 'UnitBackup_New\UMyBackupFaceInfo.pas',
  UMyBackupXmlInfo in 'UnitBackup_New\UMyBackupXmlInfo.pas',
  UMyBackupApiInfo in 'UnitBackup_New\UMyBackupApiInfo.pas',
  UNetworkEventInfo in 'UnitNetwork\UNetworkEventInfo.pas',
  UFrmSelectBackupItem in 'UnitBackup_New\UFrmSelectBackupItem.pas' {frmSelectBackupItem},
  ULocalBackupScan in 'UnitLocalBackup\ULocalBackupScan.pas',
  UMyCloudDataInfo in 'UnitCloud_New\UMyCloudDataInfo.pas',
  UMyCloudXmlInfo in 'UnitCloud_New\UMyCloudXmlInfo.pas',
  UMyCloudApiInfo in 'UnitCloud_New\UMyCloudApiInfo.pas',
  UCloudBackupThread in 'UnitCloud_New\UCloudBackupThread.pas',
  UMyBackupEventInfo in 'UnitBackup_New\UMyBackupEventInfo.pas',
  UMyRestoreFaceInfo in 'UnitRestore_New\UMyRestoreFaceInfo.pas',
  UMyRestoreApiInfo in 'UnitRestore_New\UMyRestoreApiInfo.pas',
  UMyCloudEventInfo in 'UnitCloud_New\UMyCloudEventInfo.pas',
  UMyRestoreDataInfo in 'UnitRestore_New\UMyRestoreDataInfo.pas',
  UMyRestoreXmlInfo in 'UnitRestore_New\UMyRestoreXmlInfo.pas';

{.$R *.res}

var
  myhandle : hwnd;

{.$R *.res}
begin
    // 设置防火墙
  MyFireWall.MakeThrough;

    // 运行版本
  App_RunWay := AppRunWay_BackupCow;

    // 防止多个 BackupCow 同时运行
  myhandle := findwindow( AppName_FileCloud, nil );
  if myhandle > 0 then  // 窗口在同一个 用户 ID 已经运行, 恢复之前的窗口
  begin
    postmessage( myhandle,hfck,0,0 );
    Exit;
  end
  else    // 存在相同的程序, 但不同 用户 ID, 结束程序
  if MyAppRun.getAppCount > 1 then
  begin
    if ParamStr( 1 ) <> 'h' then  // 以隐藏方式运行, 不显示
      MyMessageBox.ShowWarnning( 0, 'Application is running' );
    Exit;
  end;

    // 是否以 隐藏方式 运行程序
  if ParamStr( 1 ) = 'h' then
    Application.ShowMainForm := False;

  ReportMemoryLeaksOnShutdown := DebugHook<>0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMainForm, frmMainForm);
  Application.CreateForm(TfrmFileStatusDetail, frmFileStatusDetail);
  Application.CreateForm(TfrmRestoreDetail, frmRestoreDetail);
  Application.CreateForm(TfrmIvDecrypt, frmIvDecrypt);
  Application.CreateForm(TfrmSearchFileDecrypt, frmSearchFileDecrypt);
  Application.CreateForm(TfrmNetworkPcDetail, frmNetworkPcDetail);
  Application.CreateForm(TfrmBackupProperties, frmBackupProperties);
  Application.CreateForm(TfrmJoinGroup, frmJoinGroup);
  Application.CreateForm(TfrmConnComputer, frmConnComputer);
  Application.CreateForm(TfrmExitConfirm, frmExitConfirm);
  Application.CreateForm(TForm12, Form12);
  Application.CreateForm(TfrmSelectSharePath, frmSelectSharePath);
  Application.CreateForm(TfrmSelectLocalBackupDes, frmSelectLocalBackupDes);
  Application.CreateForm(TfrmFileSelect, frmFileSelect);
  Application.CreateForm(TFrmEnterMask, FrmEnterMask);
  Application.CreateForm(TfrmSpaceLimit, frmSpaceLimit);
  Application.CreateForm(TfrmBackupItemsApply, frmBackupItemsApply);
  Application.CreateForm(TFrmLocalBackupPro, FrmLocalBackupPro);
  Application.CreateForm(TfrmSelectLocalBackupSource, frmSelectLocalBackupSource);
  Application.CreateForm(TfrmSelectLocalDes, frmSelectLocalDes);
  Application.CreateForm(TfrmSelectReceive, frmSelectReceive);
  Application.CreateForm(TfrmSelectBackupItem, frmSelectBackupItem);
  Application.Run;
end.
