unit UMyLocalBackup;

interface

uses SysUtils, classes, SyncObjs, UChangeInfo, UFileBaseInfo, UXmlUtil,
     xmldom, XMLIntf, msxmldom, XMLDoc, UMyUtil, Windows, Math, UModelUtil,
     Generics.Collections, DateUtils, uDebug, ComCtrls, UFileWatcher, VirtualTrees;


implementation

uses UBackupInfoControl, UMyBackupInfo, UBackupInfoFace, UIconUtil, UMainForm, UFormLocalBackupPath,
     URegisterInfo, UMainFormFace, USettingInfo, ULocalBackupInfo, ULocalBackupXml, ULocalBackupFace,
     ULocalBackupControl;

end.

