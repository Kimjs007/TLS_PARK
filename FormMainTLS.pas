unit formMainTLS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ALed, RzPanel, RzButton, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  Vcl.Themes, System.UITypes, TILed, {AdvListV,} RzStatus, Vcl.StdCtrls, DllCasSdkCa410, SwitchBtn, Vcl.ComCtrls, DfsFtp,
  DefScript, CtrlDio_Tls, System.DateUtils, Inifiles, Registry,DefPG, DefCommon, {DBModule,} Vcl.AppEvnts, CtrlCssDll_Tls,
  DefDio, CommonClass, CommDIO_DAE, FormNGRatio, pasScriptClass, CommHandBCR, CommGmes, DefGmes, CommIonizer, CommPG,
  formModelSelect, formMainter, formModelInfo, formSystemSetup, formLogIn, FormUserID, FormNGMsg, FormDioDisplayAlarm,
  FormTest3Ch, ShellApi, FormDoorOpenAlarmMsg, Vcl.Imaging.pngimage, LibCommonFunc, CommModbusRtuTempPlate, LibUserFuncs,
  DBModule
;
//  {$I Common.inc}
type
  TfrmMain_Tls = class(TForm)
    ilIMGMain: TImageList;
    tolGroupMain: TRzToolbar;
    btnModel: TRzToolButton;
    rzspcr8: TRzSpacer;
    btnExit: TRzToolButton;
    btnModelChange: TRzToolButton;
    rzspcr2: TRzSpacer;
    btnInit: TRzToolButton;
    RzSpacer1: TRzSpacer;
    RzSpacer2: TRzSpacer;
    RzSpacer3: TRzSpacer;
    RzSpacer4: TRzSpacer;
    btnSetup: TRzToolButton;
    btnMaint: TRzToolButton;
    ilFlag: TImageList;
    pnlSysInfo: TRzPanel;
    grpSystemInfo: TRzGroupBox;
    RzGroupBox5: TRzGroupBox;
    pnlEQPID: TRzPanel;
    pnlStationNo: TRzPanel;
    RzGroupBox3: TRzGroupBox;
    pnlPsuVer: TRzPanel;
    RzPanel18: TRzPanel;
    RzPanel12: TRzPanel;
    pnlLgdDllVer: TRzPanel;
    pnlModelNameInfo: TPanel;
    tmAlarmMsg: TTimer;
    tmrDisplayTestForm: TTimer;
    stsSysInfo: TRzStatusBar;
    RzResourceStatus1: TRzResourceStatus;
    RzClockStatus1: TRzClockStatus;
    RzStatusPane1: TRzStatusPane;
    RzStatusPane2: TRzStatusPane;
    RzKeyStatus1: TRzKeyStatus;
    grpDIO: TRzGroupBox;
    RzStatusPane3: TRzStatusPane;
    pnlStLocalIp: TRzStatusPane;
    tmrSystemResourceCheck: TTimer;
    pnlMemCheck: TRzStatusPane;
    RzPanel8: TRzPanel;
    ledHandBcr: ThhALed;
    pnlHandBcr: TRzPanel;
    RzPanel10: TRzPanel;
    pnlIonizer: TRzPanel;
    ledIonizer1: ThhALed;
    RzPanel6: TRzPanel;
    ledGmes: ThhALed;
    pnlHost: TRzPanel;
    tmDioAlarm: TTimer;
    tmNgMsg: TTimer;
    ApplicationEvents1: TApplicationEvents;
    grpAutoTester: TRzGroupBox;
    btnStartAutoTest: TRzBitBtn;
    btnStopAutoTest: TRzBitBtn;
    ledDio: ThhALed;
    pnlDioStatus: TRzPanel;
    grpCa410: TRzGroupBox;
    Image1: TImage;
    RzPanel1: TRzPanel;
    ledEAS: ThhALed;
    pnlEAS: TRzPanel;
    RzPanel5: TRzPanel;
    RzPanel11: TRzPanel;
    RzPanel17: TRzPanel;
    ledTempIr: ThhALed;
    pnlCommTempIr: TRzPanel;
    RzPanel22: TRzPanel;
    pnlUserId: TRzPanel;
    RzPanel24: TRzPanel;
    pnlUserName: TRzPanel;
    RzPanel13: TRzPanel;
    ledTempPlate: ThhALed;
    pnlStatusTempPlate: TRzPanel;
    ledIonizer2: ThhALed;
    pnlIonizer2: TRzPanel;
    ledIonizer3: ThhALed;
    pnlIonizer3: TRzPanel;
    spgHdd: TRzProgressStatus;
    stsHdd: TRzStatusPane;
    RzStatusPane4: TRzStatusPane;
    btnLogIn: TRzToolButton;
    RzSpacer5: TRzSpacer;
    pnlCa410MemCh: TPanel;
    btnNgRatio: TRzBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure MyExceptionHandler(Sender : TObject; E : Exception );
    procedure btnInitClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure tmrDisplayTestFormTimer(Sender: TObject);
    procedure btnLogInClick(Sender: TObject);
    procedure btnModelChangeClick(Sender: TObject);
    procedure btnModelClick(Sender: TObject);
    procedure btnSetupClick(Sender: TObject);
    procedure btnMaintClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WMCopyData(var Msg : TMessage); message WM_COPYDATA;
    procedure WMCopyData_PG(var CopyMsg: TMessage);



    procedure WMPostMessage(var Msg : TMessage); message WM_USER + 1;
    function IsHeaderExist( asHeaders : array of string) : Boolean;
    procedure tmrSystemResourceCheckTimer(Sender: TObject);
    procedure tmAlarmMsgTimer(Sender: TObject);
    procedure btnShowNGRatioClick(Sender: TObject);
    procedure tmDioAlarmTimer(Sender: TObject);
    procedure tmNgMsgTimer(Sender: TObject);
    procedure ApplicationEvents1ShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure btnShowAlarmClick(Sender: TObject);
    procedure btnStopAutoTestClick(Sender: TObject);
    procedure btnNgRatioClick(Sender: TObject);
  private
    { Private declarations }
    // DIO
    ledDioIn,   ledDioOut : array[0.. DefDio.MAX_IN_CNT] of  TTILed;
    m_bIsClose, Finitail : boolean;

    DongaSwitch     :array [0..DefCommon.MAX_SWITCH_CNT] of TSerialSwitch;
//    DongaBCR        : array [0..DefCommon.MAX_BCR_CNT] of TSerialBcr;
    m_sNgMsg : string;
    ledCA410 : array [0.. pred(TDllCaSdk2.MAX_PROBE)] of ThhALed;

    m_nDioRet : array[0..5] of Integer;

    function CheckAdminPasswd : boolean;
    procedure initform;
    procedure DisplayScriptInfo;
    procedure InitialAll(bReset : Boolean = True);
    procedure GetBcrConnStatus( bConnected : Boolean; sMsg : string);
    procedure CreateClassData;
    procedure Login_MES;
    function  DisplayLogIn : Integer;
    function InitGmes : Boolean;
    procedure ShowNgMessage(sMessage: string);

    procedure DongaGmesEvent(nMsgType, nPg: Integer;bError : Boolean; sErrMsg : string);
    procedure MakeDioSig;
    procedure MakeComponet;
    procedure ShowNgAlarm(sNgMsg : string;bIsFrmClose : Boolean = False);
    // Style 변경 완료후 Main과 Test의 Handle값이 변경 됨. == > 이벤트 처리하기 위함.
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;

    procedure SaveCsvSummaryLog(nCh : Integer);
    procedure MakeCsvApdrLog(nCh: Integer);

    procedure ReleaseReadyModOnPlc;
    function CheckScriptRun : Boolean;
    procedure ShowModelNgMsg(sMsg : string);

    procedure ShowSysLog(sMsg : string; nType : Integer = 0);
    procedure ThreadTask(Task: TProc);
    procedure Set_Login(bLogin: Boolean);
    procedure Init_AlarmMessage;
    procedure SendMsgAddLog(nMsgMode, nParam, nParam2: Integer; sMsg: String; pData: Pointer=nil);
    procedure AddLog_AllCh(sLog: String);
    procedure WMSyscommandBroadcast(var Msg: TMessage);
    function CheckVersionInterlock: Boolean;
    procedure Display_Memory_DI;
    procedure Display_Memory_DO;

    procedure ProcessMsg_COMM_DIO(pGUIMsg: PGUIMessage);
    procedure ProcessMsg_SCRIPT(pGUIMsg: PGUIMessage);
    procedure Set_AlarmData(nIndex, nValue, nType: Integer);
    procedure SetSaveEnergySetting(bIsIntoSaveEnegergyStatus : Boolean; nParam : Integer);
    procedure GetSaveEnergyInsStatus(var bStatus : Boolean; var nParam : Integer);
    procedure ShowHddNgMsg(sMsg : string);
    procedure GetMemoryStatus;
  public
    { Public declarations }
    procedure DoAlarmReset;
  end;

var
  frmMain_Tls: TfrmMain_Tls;

implementation

{$R *.dfm}

uses CommThermometerMulti;



procedure TfrmMain_Tls.AddLog_AllCh(sLog: String);
var
  i: Integer;
begin
  for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i, 'Program InitialAll');
end;

procedure TfrmMain_Tls.ApplicationEvents1ShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Self.Enabled = False then Exit;

end;

procedure TfrmMain_Tls.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain_Tls.btnInitClick(Sender: TObject);
var
  sMsg, sDebug : string;
  i : integer;
begin
  if Common.StatusInfo.AutoMode then begin
    Application.MessageBox('Can not Excute On Auto Mode', 'Confirm', MB_OK+MB_ICONSTOP);
    Exit;
  end;

  sMsg :=        #13#10 + 'bạn có muốn khởi tạo chương trình không?';
  sMsg := sMsg + #13#10 + '(Are you sure you want to initialize this Program?)';
  if MessageDlg(sMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    sDebug := '[Click Event] Initialize';
    ShowSysLog(sDebug);
    for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
    InitialAll;
  end;
end;

procedure TfrmMain_Tls.btnLogInClick(Sender: TObject);
var
  nRet: Integer;
begin

  nRet:= Application.MessageBox('Do you want to change Login?', 'Confirm', MB_OKCANCEL + MB_ICONQUESTION);
  if nRet <> IDOK then Exit;

  Login_MES;

//  if Common.StatusInfo.LogIn then begin
//    Set_Login(False);
//  end
//  else begin
//    Set_Login(True);
//  end;
end;

procedure TfrmMain_Tls.btnMaintClick(Sender: TObject);
var
  i : Integer;
  sDebug : string;
begin

  if CheckScriptRun then Exit;
  if CheckAdminPasswd then begin
    ReleaseReadyModOnPlc;
    sDebug := '[Click Event] Maint';
    ShowSysLog(sDebug);
    for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
//    if Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR then TStyleManager.SetStyle('Windows10');
    CommTempPlate.SetMainterMode := True;
    frmMainter := TfrmMainter.Create(Application);
    try
//      for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
//        PasScr[i].m_bMaintWindowOn := True;
//      end;
      frmMainter.ShowModal;
    finally
      frmMainter.Free;
      frmMainter := nil;
      CommTempPlate.SetMainterMode := False;
//      for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
//        PasScr[i].m_bMaintWindowOn := False;
//      end;
    end;
//    if Common.m_bIsChanged or (Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR) then begin
//      InitialAll;
//    end;
  end;
end;

procedure TfrmMain_Tls.btnModelChangeClick(Sender: TObject);
var
  bChangeModel : Boolean;
  sOldModel, sDebug : string;
  i : Integer;
begin
  if Common.StatusInfo.AutoMode then begin
    Application.MessageBox('Can not Excute On Auto Mode', 'Confirm', MB_OK+MB_ICONSTOP);
    Exit;
  end;

  if CheckScriptRun then Exit;

  ReleaseReadyModOnPlc;
  if not CheckAdminPasswd then Exit;
  sOldModel := Common.SystemInfo.TestModel;
  frmSelectModel := TfrmSelectModel.Create(Self);
  try
    frmSelectModel.ShowModal;
  finally
    bChangeModel := frmSelectModel.m_bClickOkBtn;
    frmSelectModel.Free;
    frmSelectModel := nil;
  end;

  if bChangeModel then begin
//    tolGroupMain.Enabled := False;
    sDebug := '[Click Event] M/C : Old Model - '+sOldModel +' ===> New Model - ' + Common.SystemInfo.TestModel;
    ShowSysLog(sDebug);
    for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);

    // Fusing model Data.
    Common.LoadModelInfo(Common.SystemInfo.TestModel);
//    frmModelDownload := TfrmModelDownload.Create(Self);
//    try
//      nRet:= frmModelDownload.ShowModal;
////      if nRet = mrCancel then begin
////        for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
////          frmTest4ChOC[0].AddLog('Model Download Error!!', i, 1);
////          frmTest4ChOC[1].AddLog('Model Download Error!!', i, 1);
////        end;
////        Application.MessageBox('Model Download Error!!' + #13#10 + 'Retry Again', 'ERROR', MB_OK + MB_ICONSTOP);
////        Exit;
////      end;
//    finally
//      frmModelDownload.Free;
//      frmModelDownload := nil;
//    end;

    InitialAll;
  end;
  DisplayScriptInfo;
end;

procedure TfrmMain_Tls.btnModelClick(Sender: TObject);
var
  i : Integer;
  sDebug : string;
begin
  if Common.StatusInfo.AutoMode then begin
    Application.MessageBox('Can not Excute On Auto Mode', 'Confirm', MB_OK+MB_ICONSTOP);
    Exit;
  end;

  if CheckScriptRun then Exit;

  if CheckAdminPasswd then begin
    ReleaseReadyModOnPlc;
    if Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR then TStyleManager.SetStyle('Windows10');

    frmModelInfo := TfrmModelInfo.Create(nil);
    try
      frmModelInfo.ShowModal;
    finally
      Freeandnil(frmModelInfo);
    end;
    if Common.m_bIsChanged or (Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR) then begin
      sDebug := '[Click Event] Model Info';
      ShowSysLog(sDebug);
      for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
      InitialAll;
    end;
//    Common.LoadModelInfo(Common.SystemInfo.TestModel);
//    if Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR then begin
//      initform;
////      Common.Delay(2000);
//    end;
//    DisplayScriptInfo;
  end;
end;

procedure TfrmMain_Tls.btnNgRatioClick(Sender: TObject);
begin
  frmNGRatio:= TfrmNGRatio.Create(self);
  frmNGRatio.ShowModal;
  frmNGRatio.Free;
  frmNGRatio:= nil;
end;

procedure TfrmMain_Tls.btnSetupClick(Sender: TObject);
var
  i : Integer;
  sDebug : string;
begin
  if Common.StatusInfo.AutoMode then begin
    Application.MessageBox('Can not Excute On Auto Mode', 'Confirm', MB_OK+MB_ICONSTOP);
    Exit;
  end;

  if CheckScriptRun then Exit;
  ReleaseReadyModOnPlc;
  if CheckAdminPasswd then begin
    sDebug := '[Click Event] System Info';
    ShowSysLog(sDebug);
    for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
//    if Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR then TStyleManager.SetStyle('Windows10');
    frmSystemSetup := TfrmSystemSetup.Create(nil);
    try
      frmSystemSetup.ShowModal;
    finally

      frmSystemSetup.Free;
      frmSystemSetup := nil;
    end;
    if Common.m_bIsChanged {or (Common.SystemInfo.UIType <> DefCommon.UI_WIN10_NOR)} then begin
      InitialAll;
    end;
//    initForm;
//    for i := DefCommon.JIG_A to DefCommon.JIG_B do begin
//      // Distroy current alloc class
//      if frmTest4ChGB[i] <> nil then begin
//        frmTest4ChGB[i].SetConfig;
//      end;
//    end;
  end;
end;

function TfrmMain_Tls.CheckAdminPasswd: boolean;
var
  bRet : boolean;
begin
  bRet := False;
  frmLogIn := TfrmLogIn.Create(Self);
  try
    frmLogIn.Caption := 'Confirm Admin Password';
    if frmLogIn.ShowModal = mrOK then begin
      frmLogIn.Update;
      bRet := True;
    end;
  finally
    frmLogIn.Free;
    frmLogIn := nil;
  end;
  Result := bRet;
end;


function TfrmMain_Tls.CheckScriptRun : Boolean;
var
  bRet : Boolean;
begin
  bRet := False;
  if frmTest3Ch <> nil then begin
    if frmTest3Ch.CheckScriptRun then begin
      bRet := True;
    end;
  end;
  if bRet then begin
    ShowMessage('Script is Running!!!');
  end;
  Result := bRet;
end;

function TfrmMain_Tls.CheckVersionInterlock: Boolean;
var
  sErrMsg: String;
  sVersion: String;
  i: integer;
begin
  Result:= True;
  sErrMsg:= '';
//  if Common.InterlockInfo.Use then begin
//    if Common.InterlockInfo.Version_SW <> Common.ExeVersion then begin
//      sErrMsg:= sErrMsg + format('SW Version Mismatch %s : %s', [Common.InterlockInfo.Version_SW, Common.ExeVersion]) + #10#13;
//      Result:= False;
//    end;
//    if Common.InterlockInfo.Version_Script <> Common.SystemInfo.TestModel then begin
//      sErrMsg:= sErrMsg + format('Script Version Mismatch %s : %s' + #10#13, [Common.InterlockInfo.Version_Script, Common.SystemInfo.TestModel]);
//      Result:= False;
//    end;
//
//    for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
//      if Common.SystemInfo.UseCh[i] then begin
//        sVersion:= copy(Pg[i].m_sFwVer, 2, Length(Pg[i].m_sFwVer));
//        if Common.InterlockInfo.Version_FW <> sVersion then begin
//          sErrMsg:= sErrMsg + format('FW Version Mismatch Ch=%d, %s : %s' + #10#13, [i+1, Common.InterlockInfo.Version_FW, sVersion]);
//          Result:= False;
//        end;
//      end;
//    end;
//    if not Result then begin
//      ShowSysLog(sErrMsg);
//      ShowNgMessage(sErrMsg);
//    end;
//  end; //if Common.InterlockInfo.Use then begin

end;

procedure TfrmMain_Tls.CMStyleChanged(var Message: TMessage);
begin
  if frmTest3Ch <> nil then begin
    frmTest3Ch.SetHandleAgain(Self.Handle);
  end;
end;

procedure TfrmMain_Tls.CreateClassData;
var
I : integer;
begin
  // UDP 서버 IP 192.168.0.11
  // 내부적으로 Common file을 읽어 오기 대문에 반드시 Common Create 이후 호출.
  self.Enabled:= False;
  Common.StatusInfo.Closing   := False; //종료 중 아님
  Common.StatusInfo.LogIn     := False;
  Common.StatusInfo.AutoMode  := False;

  Init_AlarmMessage;

  tmrDisplayTestForm.Interval := 100;     // Added by KTS 2022-08-05 오전 10:47:08
  tmrDisplayTestForm.Enabled := True;

  InitForm;

  UdpServerPG := TUdpServerPG.Create(Self.Handle); //TBD:DP860?

  pnlStationNo.Caption := Common.SystemInfo.EQPId;
  case Common.SystemInfo.EQPId_Type of
    0: pnlEQPID.Caption:= 'EQP ID';
    1: pnlEQPID.Caption:= 'M-GIB EQP ID';
    2: pnlEQPID.Caption:= 'P-GIB EQP ID';
  end;

  DisplayScriptInfo;

  DongaHandBcr := TSerialBcr.Create(Self);
  DongaHandBcr.OnRevBcrConn := GetBcrConnStatus;
  DongaHandBcr.ChangePort(Common.SystemInfo.Com_HandBCR);

  Self.WindowState := wsMaximized;
//  if Common.SystemInfo.OcManualType then pnlSubTool.Height := 0;
  if Common.SystemInfo.UIType = DefCommon.UI_WIN10_NOR then begin
    Self.Color := clBtnFace;
  end
  else begin
    Self.Color := clBlack;
  end;

  // for Save Screen.
  LibCommon := TLibCommon.Create;
  LibCommon.IntervalOfSaveEnergy := Common.SystemInfo.SaveEnergy;
  LibCommon.Enable_SaveEnergy    := Common.SystemInfo.SaveEnergy <> 0;
  LibCommon.OnGetSaveEnergyInspetStatus := GetSaveEnergyInsStatus;
  LibCommon.OnSaveEnergy                := SetSaveEnergySetting;

  tmrSystemResourceCheck.Enabled := True;
end;

function TfrmMain_Tls.DisplayLogIn: Integer;
var
  nRtn : Integer;
begin
  UserIdDlg := TUserIdDlg.Create(Application);
  try
    nRtn := UserIdDlg.ShowModal;
  finally
    UserIdDlg.Free;
  end;
	Result := nRtn;
end;


procedure TfrmMain_Tls.DisplayScriptInfo;
begin
//  pnlLgdDllVer.Caption :=  Common.TestModelInfoFLOW.PatGrpName;
  pnlModelNameInfo.Caption := Common.SystemInfo.TestModel;
  pnlPsuVer.Caption    := Common.m_Ver.psu_Date+'('+Common.m_Ver.psu_Crc+')';
end;

// DIO Status Display.
procedure TfrmMain_Tls.Display_Memory_DI;
var
  i, nMod, nDiv : Integer;
  bTemp : Boolean;
  sTemp : string;
begin
  if ControlDio = nil then Exit;

  for i := 0 to Pred(DefDio.MAX_IO_CNT) do begin
//    if i > DefDio.IN_SHUTTER_DN_SNENSOR then Break;
    nDiv := i div 8; nMod := i mod 8;
    bTemp := (CommDaeDIO.DIData[nDiv] and (1 shl nMod)) > 0;
    ledDioIn[i].LedOn := bTemp;
  end;
  if frmMainter <> nil then frmMainter.DisplayDio(True);

  // for test .
  bTemp := False;
  nDiv := DefDio.MAX_IO_CNT div 8;
  for i := 0 to Pred(nDiv) do begin
    if m_nDioRet[i] <> CommDaeDIO.DIData[i] then begin
      bTemp := True;
    end;
  end;

  if frmTest3Ch <> nil then begin
    frmTest3Ch.DisplayDoorOpenAlarm(ledDioIn[DefDio.IN_DOOR_OPEN_FL].LedOn,ledDioIn[DefDio.IN_DOOR_OPEN_FR].LedOn);
  end;
//  if bTemp then begin
//    sTemp := '[DI] Changed Data :';
//    for i := 0 to Pred(nDiv) do begin
//      sTemp := sTemp + Format(' %0.2x',[CommDaeDIO.DIData[i]])
//    end;
//    ShowSysLog(sTemp);
//  end;
  for i := 0 to Pred(nDiv) do begin
    m_nDioRet[i] := CommDaeDIO.DIData[i];
  end;
end;

procedure TfrmMain_Tls.Display_Memory_DO;
var
  i, nMod, nDiv : Integer;
  bTemp : Boolean;
begin
  if ControlDio = nil then Exit;

  for i := 0 to Pred(DefDio.MAX_IO_CNT) do begin
    nDiv := i div 8; nMod := i mod 8;
    bTemp := (CommDaeDIO.DODataFlush[nDiv] and (1 shl nMod)) > 0;
    ledDioOut[i].LedOn := bTemp;
  end;
  if frmMainter <> nil then frmMainter.DisplayDio(False);
end;

procedure TfrmMain_Tls.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  sMsg, sDebug : string;
  i    : Integer;
begin
   sMsg := #13#10 + 'bạn có muốn thóat chương trình không?';
  sMsg := sMsg + #13#10 + '(Are you sure you want to Exit Program?)';
  if MessageDlg(sMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    sDebug := '[Click Event] Terminate ISPD Program';
//    ShowSysLog(sDebug);
    for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
    Common.TaskBar(False);

    if ControlDio <> nil then ControlDio.Set_TowerLampState(LAMP_STATE_NONE);
    Common.Delay(500);

    InitialAll(False);
    CanClose := True;
  end
  else
    CanClose := False;
end;

procedure TfrmMain_Tls.FormCreate(Sender: TObject);
var
  i, nRet : Integer;
  sDebug : string;
begin
  Common := TCommon.Create;
  Common.m_sUserId := 'PM';
  m_bIsClose := False;
  Finitail := False;
  Common.UpdateSystemInfo_Runtime;

  if Trim(Common.SystemInfo.ServicePort) <> '' then begin
    nRet := DisplayLogIn;
    if nRet = mrCancel then begin
      Application.ShowMainForm := False;
      Common.Free;
      Common := nil;
      Application.Terminate;
      Exit;
    end
    else begin
      if Common.m_sUserId = 'PM' then begin
        pnlHost.Caption := 'PM Mode';
        ledGmes.FalseColor := clGray;
        ledGmes.Value := False;
        pnlUserId.Caption := 'PM';
        pnlUserName.Caption := '';
      end
      else begin
        if DongaGmes <> nil then begin
          DongaGmes.MesUserId := Common.m_sUserId;
          if DongaGmes.MesEayt then DongaGmes.SendHostUchk
          else                      DongaGmes.SendHostEayt;
        end
        else begin
          InitGmes;
        end;
      end;
    end;
  end
  else begin
    btnLogIn.Visible := False;
  end;
  sDebug := '#################################### Turn On ITOLED TLS Program (';
  sDebug := sDebug + Common.GetVersionDate + ') ####################################';
  for i := DefCommon.CH1 to DefCommon.MAX_CH do common.MLog(i,sDebug);
  ShowSysLog('[ Turn On Program ] - ITOLED TLS Program Version ' + Common.GetVersionDate);
  // 현재 설정 되어 있는 Local IP Display 하자.
  pnlStLocalIp.Caption := Common.GetLocalIpList;
  Self.Caption := DefCommon.PROGRAM_NAME + ' Version ' + Common.GetVersionDate ;
  MakeDioSig;
  MakeComponet;
  modDB := TDBModule_Sqlite.Create(Self);
  if modDB.DBConnect then begin
    if modDB.CheckAndCreateTable(MAX_PG_CNT, 'TLB_ISPD') then begin
      modDB.CheckNGTypeFieldCount;
    end
    else begin
    end;
  end;

  CreateClassData;

  for i  := 0 to 5 do
    m_nDioRet[i] := 0;
end;

procedure TfrmMain_Tls.FormDestroy(Sender: TObject);
begin
  modDB.Free;
end;

procedure TfrmMain_Tls.GetBcrConnStatus( bConnected: Boolean; sMsg: string);
begin
  if sMsg = 'NONE' then begin
    ledHandBcr.FalseColor := clGray;
  end
  else begin
    ledHandBcr.FalseColor := clRed;
  end;
  pnlHandBcr.Caption := sMsg;
  ledHandBcr.Value   := bConnected;
end;

procedure TfrmMain_Tls.GetMemoryStatus;
var
  bError : boolean;
  nUsed, nTotal : Integer;
  sErrMsg : string;
begin
  if LibCommon <> nil then begin
    LibCommon.GetMemoryUsedMemory;

  end;


end;

procedure TfrmMain_Tls.GetSaveEnergyInsStatus(var bStatus: Boolean; var nParam: Integer);
var
  i : Integer;
begin
  bStatus := False;
  for i := DefCommon.JIG_A to DefCommon.JIG_B do begin
    if PasScrMain <> nil then begin
      if PasScrMain.IsScriptRun then begin
        bStatus := True;
        Break;
      end;
    end;
  end;
  nParam := 0;
end;

procedure TfrmMain_Tls.initform;
begin
  if Common.SystemInfo.Test_Repeat then begin
    //반복 테스트용
    grpAutoTester.Visible:= True;
    TStyleManager.SetStyle('Windows10 Dark');
  end
  else begin
    grpAutoTester.Visible:= False;
    case Common.SystemInfo.UIType of
      Defcommon.UI_WIN10_NOR   : TStyleManager.SetStyle('Windows10');
      Defcommon.UI_WIN10_BLACK : TStyleManager.SetStyle('Windows10 Dark')
      else begin
        TStyleManager.SetStyle('Windows10');
      end;
    end;
    //grpPlc.Visible          := not Common.SystemInfo.OcManualType;
  end;
end;

Function TfrmMain_Tls.InitGmes : Boolean;
var
  sService, sNetWork, sDeamon : string;
  sLocal, sRemote, sHostPath  : string;
  bRtn, nEasRtn               : Boolean;
begin
  ShowSysLog('InitGmes');

  if DongaGmes <> nil then begin
    DongaGmes.Free;
    DongaGmes := nil;
  end;
  DongaGmes := TGmes.Create(Self, Self.Handle);
  DongaGmes.OnGmsEvent  := DongaGmesEvent;
  DongaGmes.hTestHandle1 := frmTest3Ch.Handle;

  sService    := Common.SystemInfo.ServicePort;
  sNetWork    := Common.SystemInfo.Network;
  sDeamon     := Common.SystemInfo.DaemonPort;
  sLocal      := Common.SystemInfo.LocalSubject;
  sRemote     := Common.SystemInfo.RemoteSubject;
  sHostPath   := Common.Path.GMES;

  //Common.m_sUserId := 'PM';

  pnlUserId.Caption := Common.m_sUserId;
  pnlUserName.Caption := '';
  DongaGmes.MesSystemNo   := Common.SystemInfo.EQPId;
  DongaGmes.MesModelInfo  := Common.SystemInfo.MesModelInfo;

  if ((Trim(sService) = '') or (Trim(sDeamon) = '') or (sRemote = '')) then begin
    ShowSysLog('MES Info is Empty');
    Exit;
  end;

  bRtn := DongaGmes.HOST_Initial(sService, sNetWork, sDeamon,sLocal,sRemote ,sHostPath);
  ledGmes.Value := bRtn;
  if bRtn then begin
    pnlHost.Caption := 'Connected';
    ShowSysLog('MES Connected');
  end
  else begin
    pnlHost.Caption := 'Disconnected';
    ShowSysLog('MES Disconnected', 1);
  end;
  nEasRtn := True;

  // EAS Open.
  sService    := Common.SystemInfo.Eas_Service;
  sNetWork    := Common.SystemInfo.Eas_Network;
  sDeamon     := Common.SystemInfo.Eas_DeamonPort;
  sLocal      := Common.SystemInfo.Eas_LocalSubject;
  sRemote     := Common.SystemInfo.Eas_RemoteSubject;
  sHostPath   := Common.Path.EAS;
  DongaGmes.MesUserId := Common.m_sUserId;
  //if ((Trim(sService) = '') or (Trim(sNetWork) = '') or (Trim(sDeamon) = '') or (sRemote = '')) then begin
  if ((Trim(sService) = '') or (Trim(sDeamon) = '') or (sRemote = '')) then begin
    ShowSysLog('EAS Info is Empty');
    nEasRtn := False;
  end
  else begin
    nEasRtn := DongaGmes.Eas_Initial(sService, sNetWork, sDeamon,sLocal,sRemote ,sHostPath);
    ledEAS.Value := nEasRtn;
    if nEasRtn then begin
      pnlEAS.Caption := 'Connected';
      ShowSysLog('EAS Connected');
    end
    else begin
      pnlEAS.Caption := 'Disonnected';
      ShowSysLog('EAS Disonnected', 1);
    end;
  end;


  if bRtn and nEasRtn then begin
   // pnlHost.Caption := 'Connected';
    DongaGmes.FtpAddr := Common.SystemInfo.HOST_FTP_IPAddr;
    DongaGmes.FtpUser := Common.SystemInfo.HOST_FTP_User;
    DongaGmes.FtpPass := Common.SystemInfo.HOST_FTP_Passwd;
    DongaGmes.FtpCombiPath := Common.SystemInfo.HOST_FTP_CombiPath;
    // EAYT Start....
    DongaGmes.SendHostStart;
  end
  else begin
    //pnlHost.Caption := 'Disonnected';
  end;
end;

procedure TfrmMain_Tls.InitialAll(bReset: Boolean);
var
  i : Integer;
begin
  Common.StatusInfo.Closing:= True; //종료 중
  Self.Enabled:= False;
  if g_CommThermometer <> nil then begin
    g_CommThermometer.Disconnect;
    Common.Delay(1000);
    g_CommThermometer.Free;
    g_CommThermometer := nil;
  end;

  if CtlLgdDll <> nil then begin
    CtlLgdDll.Free;
    CtlLgdDll := nil;
  end;
  tmDioAlarm.Enabled := False;

  if frmTest3Ch <> nil then begin
    frmTest3Ch.tmrReadChart.Enabled := False;
  end;
  for I := 0 to Pred(DefCommon.MAX_SWITCH_CNT) do begin
    if DongaSwitch[i] <> nil then begin
      DongaSwitch[i].Free;
      DongaSwitch[i] := nil;
    end;
  end;



  if DfsFtpCommon <> nil then begin
    if DfsFtpCommon.IsConnected then DfsFtpCommon.Disconnect;
    DfsFtpCommon.Free;
    DfsFtpCommon := nil;
  end;

  for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if DfsFtpCh[i] <> nil then begin
      DfsFtpCh[i].Free;
      DfsFtpCh[i] := nil;
    end;
  end;

  if DongaGmes <> nil then begin
    DongaGmes.Free;
    DongaGmes := nil;
  end;

  if DongaHandBcr <> nil then begin
    DongaHandBcr.Free;
    DongaHandBcr := nil;
  end;



  if frmTest3Ch <> nil then begin
    frmTest3Ch.Free;
    frmTest3Ch := nil;
  end;

  if UdpServerPG <> nil then begin
    UdpServerPG.Free;
    if (Pg[0] <> nil) and (not (Pg[0].StatusPg in [pgDisconn])) then begin
      //TBD:DP860? Pg[0].SendPgReset;
      Sleep(500);
    end;

    UdpServerPG := nil;
  end;

  // NG Msg close.
  if frmModelNgMsg <> nil then begin
    frmModelNgMsg.Free;
    frmModelNgMsg := nil;
  end;
  if frmDisplayAlarm <> nil then begin
    frmDisplayAlarm.Close;
//    frmDisplayAlarm.Free;
//    frmDisplayAlarm := nil;
  end;
  if frmNgMsg <> nil then begin
    frmNgMsg.Free;
    frmNgMsg := nil;
  end;
//
//  Sleep(300); //DIO 출력 대기
  for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
    if DaeIonizer[i] <> nil then begin
      DaeIonizer[i].IsIgnoreNg:= True;
      DaeIonizer[i].Free;
      DaeIonizer[i] := nil;
    end;
  end;

  if CommTempPlate <> nil then begin
    CommTempPlate.Free;
    CommTempPlate := nil;
  end;

  if ControlDio <> nil then begin
    ControlDio.Free;
    ControlDio := nil;
  end;

  if LibCommon <> nil then begin
    LibCommon.Free;
    LibCommon := nil;
  end;

  if DllCaSdk2 <> nil then begin
    DllCaSdk2.Free;
    DllCaSdk2 := nil;
  end;
  if Common is TCommon then begin
    Common.Free;
    Common := nil;
  end;

  Sleep(1000);
  if bReset then begin
    // Create Again.
    Common :=	TCommon.Create;
    CreateClassData;
    m_bIsClose := False;
    ShowSysLog('Program InitialAll');
    AddLog_AllCh('Program InitialAll');
    Finitail := True;

  end;
end;

function TfrmMain_Tls.IsHeaderExist(asHeaders: array of string): Boolean;
var
  i : Integer;
  bRet : boolean;
begin
  bRet := False;
  for i := 0 to Pred(DefCommon.MAX_CSV_HEADER_ROWS) do begin
    if Trim(asHeaders[i]) <> '' then begin
      bRet := True;
      Break;
    end;
  end;
  Result := bRet;

end;

procedure TfrmMain_Tls.Login_MES;
var
  i, nRet: Integer;
begin
  //ShowSysLog('Login_MES');
  if Trim(Common.SystemInfo.ServicePort) <> '' then begin
    nRet := DisplayLogIn;
    if nRet = mrCancel then begin
      if DongaGmes <> nil then begin
        DongaGmes.Free;
        DongaGmes := nil;
      end;
      Common.m_sUserId := 'PM';
      pnlHost.Caption := 'PM Mode';
      ledGmes.FalseColor := clGray;
      ledGmes.Value := False;
      pnlUserId.Caption := '';
      pnlUserName.Caption := '';
      Exit;

    end
    else begin
      if Common.m_sUserId = 'PM' then begin
        if DongaGmes <> nil then begin
          DongaGmes.Free;
          DongaGmes := nil;
        end;
        pnlHost.Caption := 'PM Mode';
        ledGmes.FalseColor := clGray;
        ledGmes.Value := False;
      end
      else begin
        if DongaGmes <> nil then begin
          DongaGmes.MesUserId := Common.m_sUserId;
          if not DongaGmes.MesEayt then DongaGmes.SendHostUchk
          else                          DongaGmes.SendHostEayt;
        end
        else begin
          InitGmes;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain_Tls.MakeComponet;
var
  i : Integer;
begin
  grpCa410.Visible := False;
  for i := 0 to Pred(TDllCaSdk2.MAX_PROBE) do begin
    ledCA410[i] := ThhALed.Create(Self);
    ledCA410[i].Parent    := grpCa410;
    ledCA410[i].LEDStyle  := LEDHorizontal;
    ledCA410[i].Left      := ((i mod 3))*90+20;
    ledCA410[i].Top       := (i div 3)*54+51;
    ledCA410[i].Blink     := False;
  end;
  grpCa410.Visible := True;
end;

procedure TfrmMain_Tls.MakeCsvApdrLog(nCh: Integer);
var
  sFileName, sFilePath, sData : string;
  i : Integer;
begin
  sFilePath := Common.Path.ApdrCsv+formatDateTime('yyyymm',now) + '\';
  sFileName := sFilePath + PasScr[nCh].m_sFileCsv;
  if Common.CheckDir(sFilePath) then Exit;
  //sData := StringReplace(Common.GetVerOnlyDate,' ','',[rfReplaceAll]);
  sData := '';
  for i := 0 to Pred(PasScr[nCh].TestInfo.InsApdr.FColCnt) do begin
    sData := sData + Trim(PasScr[nCh].TestInfo.InsApdr.Data[0,i])+':';
    sData := sData + Trim(PasScr[nCh].TestInfo.InsApdr.Data[1,i])+':';
    sData := sData + Trim(PasScr[nCh].TestInfo.InsApdr.Data[2,i]);
    if i <> Pred(PasScr[nCh].TestInfo.InsApdr.FColCnt) then begin
      sData := sData + ',';
    end;
  end;
end;
procedure TfrmMain_Tls.MakeDioSig;
var
  i,nMod, nCh, nNotUse: Integer;
  nWidth, nHeight, nTopPos : Integer;
  sTemp : string;
begin
  nWidth  := 120;
  nHeight := 11;
  nNotUse := 0;

  nTopPos := ledDio.Top + ledDio.Height; //23;// pnlDioTop.Top + pnlDioTop.Height + 1;
  for i := 0 to Pred(DefDio.MAX_IN_CNT) do begin
    ledDioIn[i] := TTILed.Create(Self);
    ledDioIn[i].Parent := grpDIO;
    ledDioIn[i].Left := 1;//pnlZAxis.Left;
    ledDioIn[i].Top  := nTopPos + (i-nNotUse)*(nHeight);
    ledDioIn[i].Width := grpDIO.Width div 2;
    ledDioIn[i].Height := nHeight;
    ledDioIn[i].Font.Size := 7;
    ledDioIn[i].LedColor := TLedColor(Green);
    ledDioIn[i].StyleElements := [seBorder];
    sTemp := Trim(DefDio.asDioInShort[i]);
    ledDioIn[i].Caption := sTemp;
    ledDioIn[i].Hint     := sTemp;
    if sTemp <> '' then ledDioIn[i].ShowHint := True;
    if sTemp <> '' then ledDioIn[i].Visible := True
    else ledDioIn[i].Visible := False;
    if sTemp = '' then nNotUse := nNotUse + 1;

  end;

  nNotUse := 0;
  for i := 0 to Pred(DefDio.MAX_OUT_CNT) do begin
    ledDioOut[i] := TTILed.Create(Self);
    ledDioOut[i].Width := grpDIO.Width div 2;
    ledDioOut[i].Height := nHeight;
    ledDioOut[i].Parent := grpDIO;
    ledDioOut[i].Left := nWidth;
    ledDioOut[i].Top  := nTopPos + (i-nNotUse)*(nHeight);
    ledDioOut[i].Font.Size := 7;
    sTemp := Trim(DefDio.asDioOutShort[i]);
    ledDioOut[i].Caption := sTemp;
    ledDioOut[i].Width := nWidth;
    ledDioOut[i].Height := nHeight;
    ledDioOut[i].LedColor := TLedColor(Yellow);
    ledDioOut[i].StyleElements := [seBorder];
    if sTemp = '' then nNotUse := nNotUse + 1;
    if sTemp <> '' then ledDioOut[i].Visible := True
    else ledDioOut[i].Visible := False;
    ledDioOut[i].Hint     := sTemp;
    if sTemp <> '' then ledDioOut[i].ShowHint := True;
  end;
end;


procedure TfrmMain_Tls.MyExceptionHandler(Sender: TObject; E: Exception);
begin
  common.MLog(0,'Application Exception Error, class=' + Sender.ClassName +', mesg='+ E.Message);
  raise Exception.Create('Here!');
end;

procedure TfrmMain_Tls.DoAlarmReset;
var
  i: Integer;
begin
  ShowSysLog('[ALARM RESET] ERROR RESET');
  for i := DefCommon.JIG_A to DefCommon.JIG_B do begin
//    frmTest4ChOC[i].ClearPreviousResult;
  end;
end;

procedure TfrmMain_Tls.DongaGmesEvent(nMsgType, nPg: Integer; bError: Boolean; sErrMsg: string);
var
  sHostErrMsg : string;
  nCh , i: Integer;
begin
  sHostErrMsg := StringReplace(sErrMsg, '[', '', [rfReplaceAll]);
  sHostErrMsg := StringReplace(sHostErrMsg, ']', '', [rfReplaceAll]);

  case nMsgType of
    DefGmes.MES_EAYT  : begin
      if bError then begin
        ShowNgAlarm(sHostErrMsg,False);
        //ShowNgMessage(sHostErrMsg);
      end;
    end;
    DefGmes.MES_UCHK  : begin
      DongaGmes.MesUserName  := StringReplace(DongaGmes.MesUserName, '[', '', [rfReplaceAll]);
      DongaGmes.MesUserName  := StringReplace(DongaGmes.MesUserName, ']', '', [rfReplaceAll]);
      if not bError then begin
        pnlUserName.Caption := DongaGmes.MesUserName;
        pnlUserId.Caption := DongaGmes.MesUserId;
        for nCh := DefCommon.CH1 to DefCommon.MAX_CH do begin   // JH:qHWANG-GMES: 2018-06-20
          PasScr[nCh].m_bMesPMMode := False;
        end
      end
      else begin
        ShowNgAlarm(sHostErrMsg,False);
        //ShowNgMessage(sHostErrMsg);
      end;
    end;
    DefGmes.MES_EDTI  : begin
//      InitMainTool(True);
//      for i := DefCommon.JIG_A to DefCommon.JIG_B do begin
//        frmTest4ChOC[i].SetHostConnShow(True);
//      end;
      Common.m_sUserId := DongaGmes.MesUserId;
      pnlUserId.Caption := Common.m_sUserId;
      if bError then begin
        ShowNgAlarm(sHostErrMsg,False);
        //ShowNgMessage(sHostErrMsg);
      end;
//      DisplayMes(True);
    end;
    DefGmes.MES_FLDR  : begin
      if bError then begin
        ShowNgAlarm(sHostErrMsg,False);
      end;
    end;
    DefGmes.MES_APDR  : begin
      if bError then begin
        ShowNgAlarm(sHostErrMsg,False);
      end;
    end;
    DefGmes.MES_EQCC  : begin
      if bError then begin
        ShowNgAlarm(sHostErrMsg,False);
      end;
    end;
  end;
end;

procedure TfrmMain_Tls.ProcessMsg_COMM_DIO(pGUIMsg: PGUIMessage);
var
  dtTime: TDateTime;
begin
  case pGUIMsg.Mode of
    CommDIO_DAE.COMMDIO_MSG_CONNECT :  begin//  COMMDIO_MSG_CONNECT: begin
      if pGUIMsg.Param <> 0 then begin
        pnlDioStatus.Caption := 'Connected'; // + IntToHex(CommDaeDIO.DeviceInfo.Version[0]); // + PGuiDaeDio(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
        Display_Memory_DI;
        Display_Memory_DO;
        ledDio.Value := True;
        ShowSysLog('DIO Connected:' + pGUIMsg.Msg);
      end
      else begin
        pnlDioStatus.Caption := 'Disconnected'; // + PGuiDaeDio(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
        ledDio.Value := False;
        ShowSysLog('DIO Disconnected:' + pGUIMsg.Msg, 1);
      end;
    end; //COMMPLC_MODE_CONNECT: begin
    CommDIO_DAE.COMMDIO_MSG_CHANGE_DI : begin //COMMDIO_MSG_CHANGE_DI: begin
      //데이터 변경
      { TODO : Teach Mode로 변경 될경우 Auto Mode 해제 처리 }

      Display_Memory_DI;
    end; //COMMDIO_MSG_CHANGE_DI: begin
    CommDIO_DAE.COMMDIO_MSG_CHANGE_DO : begin //COMMDIO_MSG_CHANGE_DO: begin
      //데이터 변경
      Display_Memory_DO;
    end; //COMMDIO_MSG_CHANGE_DO: begin
    CommDIO_DAE.COMMDIO_MSG_LOG: begin //COMMDIO_MSG_LOG: begin         
      //단순 로그
      ShowSysLog(pGUIMsg.Msg);
    end; //COMMDIO_MSG_LOG
    CommDIO_DAE.COMMDIO_MSG_ERROR: begin //COMMDIO_MSG_LOG: begin
      ShowSysLog('DIO ERROR : ' + pGUIMsg.Msg, 1);
    end; //COMMPLC_MODE_CHANGEDATA: begin
    CtrlDio_Tls.MSG_MODE_DISPLAY_ALARAM :  begin//  COMMDIO_MSG_CONNECT: begin
      Set_AlarmData(pGUIMsg.Param, pGUIMsg.Param2, 0); //경 알람
    end;
    CtrlDio_Tls.MSG_MODE_SYSTEM_ALARAM :  begin
      Set_AlarmData(pGUIMsg.Param, pGUIMsg.Param2, 1); //중 알람
    end;
    CtrlDio_Tls.MSG_MODE_DISPLAY_IO :  begin
      Display_Memory_DI;
      Display_Memory_DO;
    end;

  end;
end;


procedure TfrmMain_Tls.ProcessMsg_SCRIPT(pGUIMsg: PGUIMessage);
var
  nCh : Integer;
  sDebug : string;
begin
  nCh:= pGUIMsg.Channel;
  case pGUIMsg.Mode of
    DefCommon.MSG_MODE_LOG_CSV : begin
      //
    end;
    DefCommon.MSG_MODE_LOG_CSV_SUMMARY : begin
      SaveCsvSummaryLog(nCh);
    end;
    DefCommon.MSG_MODE_LOG_CSV_APDR : begin
      MakeCsvApdrLog(nCh);
    end;
    DefGmes.MES_PCHK : begin
      //sDebug := 'MSG_TYPE_HOST, MES_PCHK, PG'+IntToStr(nCh+1); Common.MLog(DefCommon.MAX_SYSTEM_LOG,sDebug); //IMSI
      DongaGmes.MesSerialType := PasScr[nCh].TestInfo.nSerialType;
      DongaGmes.SendHostPchk(PasScrMain.FBcrData[nCh], nCh);
    end;
    DefGmes.MES_INS_PCHK : begin
      //sDebug := 'MSG_TYPE_HOST, MES_INS_PCHK, PG'+IntToStr(nCh+1); Common.MLog(DefCommon.MAX_SYSTEM_LOG,sDebug); //IMSI
      DongaGmes.SendHostIns_Pchk(PasScr[nCh].TestInfo.SerialNo, nCh);
    end;
    DefGmes.MES_EICR : begin
      //sDebug := 'MSG_TYPE_HOST, MES_EICR, PG'+IntToStr(nCh+1); Common.MLog(DefCommon.MAX_SYSTEM_LOG,sDebug); //IMSI
      DongaGmes.SendHostEicr(PasScrMain.FBcrData[nCh], nCh, ''{.TestInfo.CarrierId});
    end;
    Defgmes.MES_RPR_EIJR : begin
      DongaGmes.SendHostRPr_Eijr(PasScrMain.FBcrData[nCh], nCh);
    end;
    DefGmes.MES_APDR : begin
      DongaGmes.MesData[nCh].ApdrData := PasScrMain.TestInfo.ApdrData[nCh];
      DongaGmes.SendHostApdr(PasScrMain.FBcrData[nCh], nCh);
    end;
    DefGmes.MES_SGEN : begin
      //sDebug := 'MSG_TYPE_HOST, MES_SGEN, PG'+IntToStr(nCh+1); Common.MLog(DefCommon.MAX_SYSTEM_LOG,sDebug); //IMSI
      DongaGmes.SendHostSGEN(PasScrMain.FBcrData[nCh], nCh);
    end;
    DefGmes.EAS_APDR : begin
      DongaGmes.MesData[nCh].ApdrData := PasScrMain.TestInfo.ApdrData[nCh];
      DongaGmes.SendEasApdr(PasScrMain.FBcrData[nCh], nCh);
    end;
  end;
end;


procedure TfrmMain_Tls.ReleaseReadyModOnPlc;
//var
//  nCh : Integer;
begin
//  if Common.StatusInfo.AutoMode then Set_AutoMode(False);
  //btnAutoReadyClick(nil);

//  if PlcPocb <> nil then begin
//    if btnAutoReady.Tag <> 0 then btnAutoReady.OnClick(nil);
//  end
//  else begin
//    Exit;
//  end;
end;


procedure TfrmMain_Tls.btnShowAlarmClick(Sender: TObject);
begin
  tmDioAlarmTimer(Sender);
end;

procedure TfrmMain_Tls.btnShowNGRatioClick(Sender: TObject);
begin
  frmNGRatio:= TfrmNGRatio.Create(self);
  frmNGRatio.ShowModal;
  frmNGRatio.Free;
  frmNGRatio:= nil;
end;

procedure TfrmMain_Tls.btnStopAutoTestClick(Sender: TObject);
begin
  Common.StatusInfo.Test_AutoRepeat := False;
  ShowSysLog('STOP Auto Repeat Test Mode');
  btnStartAutoTest.Enabled := True;
  btnStopAutoTest.Enabled := False;
end;

procedure TfrmMain_Tls.SaveCsvSummaryLog(nCh: Integer);
var
  sFilePath, sFileName : String;
  sLine: String;
  txtF                 : Textfile;
  i : integer;
begin
  sFilePath := Common.Path.SumCsv + FormatDateTime('yyyymm',now) + '\';
  sFileName := sFilePath + PasScr[nCh].m_sFileCsv;
  if Common.CheckDir(sFilePath) then Exit;
  try
    try
      AssignFile(txtF, sFileName);
      try

        if not FileExists(sFileName) then begin
          //Header 생성
          Rewrite(txtF);
          sLine:= PasScr[nCh].TestInfo.InsCsv.Data[0, 0];
          for i:= 1 to Pred(PasScr[nCh].TestInfo.InsCsv.FColCnt) do begin
            sLine:=  sLine + ',' + PasScr[nCh].TestInfo.InsCsv.Data[0, i];
          end;
          WriteLn(txtF, sLine);
        end;

        //Data
        Append(txtF);
        sLine:= PasScr[nCh].TestInfo.InsCsv.Data[1, 0];
        for i:= 1 to Pred(PasScr[nCh].TestInfo.InsCsv.FColCnt) do begin
          sLine:=  sLine + ',' + PasScr[nCh].TestInfo.InsCsv.Data[1, i];
        end;
        WriteLn(txtF, sLine);
      except
      end;
    finally
      CloseFile(txtF); // Close the file
    end;
  except

  end;
end;

procedure TfrmMain_Tls.SendMsgAddLog(nMsgMode, nParam, nParam2: Integer; sMsg: String; pData: Pointer);
var
  cds         : TCopyDataStruct;
  COPYDATAMessage : RGuiDaeDio;
begin
  COPYDATAMessage.MsgType := MSG_TYPE_NONE;
  COPYDATAMessage.Channel := 0;
  COPYDATAMessage.Mode    := nMsgMode;
  COPYDATAMessage.Param   := nParam;
  COPYDATAMessage.Param2  := nParam2;
  COPYDATAMessage.Msg     := sMsg;
  COPYDATAMessage.pData   := pData;

  cds.dwData      := 0;
  cds.cbData      := SizeOf(COPYDATAMessage);
  cds.lpData      := @COPYDATAMessage;
  SendMessage(self.Handle ,WM_COPYDATA,0, LongInt(@cds));
end;


procedure TfrmMain_Tls.SetSaveEnergySetting(bIsIntoSaveEnegergyStatus: Boolean; nParam: Integer);
var
  i : Integer;
begin
  if bIsIntoSaveEnegergyStatus then begin
    // Ionizer Off.
    for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
      if Common.SystemInfo.Com_Ionizer[i] = 0 then Continue;
      if not ((Common.SystemInfo.IonizerCnt-1) < i) then begin
        if DaeIonizer[i] <> nil then DaeIonizer[i].SendMsg(',STP,1');
      end;
    end;
    // Lamp Off.
    if ControlDio <> nil then begin
      ControlDio.WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF);
    end;
  end
  else begin
    // Ionizer On.
    for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
      if Common.SystemInfo.Com_Ionizer[i] = 0 then Continue;
      if not ((Common.SystemInfo.IonizerCnt-1) < i) then begin
        if DaeIonizer[i] <> nil then  DaeIonizer[i].SendMsg(',RUN,1');
      end;
    end;
    // Lamp On.
    if ControlDio <> nil then begin
      ControlDio.WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF,True);
    end;

  end;
end;

procedure TfrmMain_Tls.Set_AlarmData(nIndex, nValue, nType: Integer);
var
  i : Integer;
  bAlarm: Boolean;
begin

  if nType <> 0 then begin
    //Heavy Alarm
    if nValue <> 0 then begin
      ShowSysLog('[ALARM ON] ' + ControlDio.AlarmMsg[nIndex], 1);
//      Set_AutoMode(False); //매뉴얼 모드로 전환
//
//      g_CommPLC.ECS_Alarm_Add(1, nIndex, 1); //알람 보고    // Added by KTS 2022-08-04 오후 4:30:33

      Common.StatusInfo.AlarmOn:= True;
      ControlDio.MelodyOn:= True;

      ControlDio.Set_TowerLampState(LAMP_STATE_ERROR);
      //Door Opend
      if nValue = 2 then begin

        ShowSysLog(ControlDio.AlarmMsg[nIndex], 1);
        tmDioAlarm.Interval := 10;
        tmDioAlarm.Enabled := True;
        if Common.FindCreateForm('TfrmDoorOpenAlarmMsg') <> '' then begin
          Exit;
        end;
        frmDoorOpenAlarmMsg:= TfrmDoorOpenAlarmMsg.Create(self);
        frmDoorOpenAlarmMsg.btnClose.Visible := True;
        frmDoorOpenAlarmMsg.Show; //ShowModal; //어차피 전체 창이므로 Modal일 필요 없다.
      end
      else begin
        tmDioAlarm.Interval := 10;
        tmDioAlarm.Enabled := True;
      end;
    end
    else begin
      //알람 없을 경우 해제
      ShowSysLog('[ALARM OFF] ' + ControlDio.AlarmMsg[nIndex], 3);
      if frmDisplayAlarm <> nil then begin
        frmDisplayAlarm.RefreshDisplay;
      end;
      bAlarm:= false;
      for i := 0 to DefDio.IN_MAX do begin
        if Common.StatusInfo.AlarmData[i] <> 0 then bAlarm:= True;
      end;

      if not bAlarm  then begin
        if PasScrMain <> nil then begin
          if PasScrMain.IsScriptRun then ControlDio.Set_TowerLampState(LAMP_STATE_AUTO)
          else                           ControlDio.Set_TowerLampState(LAMP_STATE_REQUEST);
        end
        else begin
          ControlDio.Set_TowerLampState(LAMP_STATE_REQUEST);
        end;
        if frmDisplayAlarm <> nil then begin

          frmDisplayAlarm.Close;
        end;
      end;
    end;
  end  //if nType <> 0 then begin
  else begin
    //Light Alarm
    if nValue <> 0 then begin
      ShowSysLog('[ALARM ON] ' + ControlDio.AlarmMsg[nIndex], 2);
      ShowNgMessage(ControlDio.AlarmMsg[nIndex]);
    end
    else begin
      ShowSysLog('[ALARM OFF] ' + ControlDio.AlarmMsg[nIndex], 3);
      bAlarm:= false;
//      for i := 0 to DefDio.IN_MAX do begin
//        if Common.StatusInfo.AlarmData[i] <> 0 then bAlarm:= True;
//      end;
//      if not bAlarm  then begin
//        if PasScrMain <> nil then begin
//          if PasScrMain.IsScriptRun then ControlDio.Set_TowerLampState(LAMP_STATE_AUTO)
//          else                           ControlDio.Set_TowerLampState(LAMP_STATE_REQUEST);
//        end
//        else begin
//          ControlDio.Set_TowerLampState(LAMP_STATE_REQUEST);
//        end;
//        if frmDisplayAlarm <> nil then begin
//
//          frmDisplayAlarm.Close;
//        end;
//      end;
    end;
  end;
end;

procedure TfrmMain_Tls.Set_Login(bLogin: Boolean);
begin
  if bLogin then  begin
    ShowSysLog('Set_Login - ON' );
  end
  else begin
    ShowSysLog('Set_Login - OFF' );
  end;

  if bLogin then begin
    Login_MES;
  end
  else begin
    Common.m_sUserId := 'PM';
    if DongaGmes <> nil then begin
      Login_MES;
    end;

//    DisplayMes(False);
  end;
end;

procedure TfrmMain_Tls.ShowHddNgMsg(sMsg: string);
begin
  if frmHDDAlarm <> nil then begin
    frmHDDAlarm.lblShow.Caption := sMsg;
    Exit;
  end;

  frmHDDAlarm  := TfrmNgMsg.Create(nil);
  try
    frmHDDAlarm.lblShow.Caption := sMsg;
    frmHDDAlarm.ShowModal;
  finally
    frmHDDAlarm.Free;
    frmHDDAlarm := nil;
  end;
end;

procedure TfrmMain_Tls.ShowModelNgMsg(sMsg: string);
begin
  if frmModelNgMsg <> nil  then begin
    frmModelNgMsg.lblShow.Caption := sMsg;
    frmModelNgMsg.btnClose.Visible := False;
  end
  else begin
    frmModelNgMsg  := TfrmNgMsg.Create(nil);
    frmModelNgMsg.btnClose.Visible := False;
    try
      frmModelNgMsg.lblShow.Caption := sMsg;
      frmModelNgMsg.ShowModal;
    finally
      frmModelNgMsg.Free;
      frmModelNgMsg := nil;
    end;
  end;

end;

procedure TfrmMain_Tls.ShowNgAlarm(sNgMsg: string; bIsFrmClose: Boolean);
begin
  if not bIsFrmClose then begin
    if frmNgMsg <> nil then begin
      frmNgMsg.lblShow.Caption := sNgMsg;
    end
    else begin
      m_sNgMsg := sNgMsg;
      tmAlarmMsg.Interval := 100;
      tmAlarmMsg.Enabled := True;
    end;
  end
  else begin
    if frmNgMsg <> nil then begin
      frmNgMsg.Close;
    end
  end;
end;

procedure TfrmMain_Tls.ShowNgMessage(sMessage: string);

begin
//  frmHostAlarm  := TfrmNgMsg.Create(Self);
//  try
//    frmHostAlarm.lblShow.Caption := sMessage;
//    frmHostAlarm.ShowModal;
//  finally
//    frmHostAlarm.Free;
//    frmHostAlarm := nil;
//  end;
  if frmNgMsg = nil then begin
    frmNgMsg  := TfrmNgMsg.Create(nil);
  end;

  frmNgMsg.lblShow.Caption := sMessage;
  frmNgMsg.Show; //ShowModal;
end;


procedure TfrmMain_Tls.ShowSysLog(sMsg: string; nType: Integer);
var
  sDebug : string;
begin
  sDebug := FormatDateTime('[HH:MM:SS.zzz] ',now) + sMsg;
  try
    Common.MLog(DefCommon.MAX_SYSTEM_LOG, sMsg);
    if frmTest3Ch = nil then Exit;

    if frmTest3Ch.mmoSysLog.Lines.Count > 1000 then begin
      frmTest3Ch.mmoSysLog.Clear;
    end;
    frmTest3Ch.ShowSysLog(nType,sDebug);
  except
    on E: Exception do  begin
      Sleep(10); //MLog 충돌 방지 딜레이
      Common.MLog(DefCommon.MAX_SYSTEM_LOG, 'MLog Exception:' + E.Message + #13#10 + sMsg);
    end;
  end;
end;


procedure TfrmMain_Tls.ThreadTask(Task: TProc);
begin
  TThread.CreateAnonymousThread(
    Task
  ).Start;
end;

procedure TfrmMain_Tls.tmAlarmMsgTimer(Sender: TObject);
begin
  tmAlarmMsg.Enabled := False;
  ShowNgMessage(m_sNgMsg);
end;

procedure TfrmMain_Tls.tmDioAlarmTimer(Sender: TObject);
begin
  tmDioAlarm.Enabled := False;
  if frmDisplayAlarm <> nil then begin
    frmDisplayAlarm.RefreshDisplay;
  end
  else begin
    frmDisplayAlarm:= TfrmDisplayAlarm.Create(Self);
    frmDisplayAlarm.Show;
  end;
//  if Assigned(frmDisplayAlarm) = False then begin
//    frmDisplayAlarm:= TfrmDisplayAlarm.Create(Self);
//    //frmDisplayAlarm.SetAlarmData(ControlDio.DioAlarmData);
//    frmDisplayAlarm.Show;
//    //frmDisplayAlarm.ShowModal;
//    //frmDisplayAlarm.Free;
//    //frmDisplayAlarm:= nil;
//  end
//  else begin
//    frmDisplayAlarm.RefreshDisplay;
//  end;
end;

procedure TfrmMain_Tls.tmNgMsgTimer(Sender: TObject);
begin
  tmNgMsg.Enabled := False;
  ShowModelNgMsg(ControlDio.LastNgMsg);
end;

procedure TfrmMain_Tls.tmrDisplayTestFormTimer(Sender: TObject);
var
  i: Integer;
  sTarget, sSource : string;
  aTask : TThread;
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  ExecuteFile, ParamString, StartInString: string;

  hwnd: THandle;
  DataStruct: CopyDataStruct;

begin
  tmrDisplayTestForm.Enabled := False;
  self.Enabled:= True;

  frmTest3Ch := TfrmTest3Ch.Create(self);
  frmTest3Ch.Tag    := 0;
  frmTest3Ch.Height := pnlSysInfo.Height - 5;//- stsSysInfo.Height;// (Self.Height) - tolGroupMain.Top - tolGroupMain.Height {- (frmSysEtc.Height div 2)} - 70 - stsSysInfo.Height ;
  frmTest3Ch.Width  := Self.Width - (pnlSysInfo.Width + pnlSysInfo.Left) - 20 ;
  frmTest3Ch.Left   := 0;
  frmTest3Ch.Top    := 0;

  frmTest3Ch.ShowGui(Self.Handle);
  //frmTest3Ch.Show;

  ControlDio := TControlDio.Create(Self.Handle, DefCommon.MSG_TYPE_CTL_DIO);   // Added by KTS 2022-08-04 오후 4:04:53
  // 이오 나이져 Connection Check 하는 부분에 Error Message Display 하는 곳때문에 무조건 Control DIO 다음에 처리 해야 함.
  for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
    DaeIonizer[i] := TIonizer.Create(i,Self.Handle,frmTest3Ch.Handle,DefCommon.MSG_TYPE_IONIZER);
    DaeIonizer[i].IsIgnoreNg := False;
    DaeIonizer[i].NewProtocol := Common.SystemInfo.IonizerNewProtocol;
    DaeIonizer[i].ChangePort(Common.SystemInfo.Com_Ionizer[i],Common.SystemInfo.Model_Ionizer[i]);
  end;
  for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
    if Common.SystemInfo.Com_Ionizer[i] = 0 then Continue;
    DaeIonizer[i].SendRun; // SendMsg(',RUN,1');
  end;

//  TUserFunc.DelayMs(1000);
  CtlLgdDll := TControlLgdDll.Create(Self.Handle,frmTest3Ch.Handle,'DAE_IT_OLED_Tls_Converter.dll','');
  if PasScrMain <> nil then PasScrMain.ScriptLog('LGD DLL Version : '+CtlLgdDll.GetDllVersion);
  pnlLgdDllVer.Caption := CtlLgdDll.GetDllVersion;

//  CtlLgdDll.FinalWorkDllCss(0);

  // File Copy
  LibCommon.AutoBackup(Common.SystemInfo.AutoBackupUse, Common.SystemInfo.AutoBackupList);
  Common.StatusInfo.AutoMode:= False;

//  InitDfs
  g_CommThermometer:= TCommThermometerMulti.Create(self.Handle, MSG_TYPE_COMMTHERMOMETER, 1000);
  g_CommThermometer.Connect(common.SystemInfo.Com_IrTempSensor);

  // 이때 Connection 체크 하자.
  for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if PG[i] <> nil then  PG[i].tmConnCheck.Enabled  := true;
  end;

  CommTempPlate := TCommModbusRtuTempPlateMessage.Create(Self.Handle,DefCommon.MSG_TYPE_TEMP_PLATES,1000);
  CommTempPlate.SetAutoCtrl := Common.SystemInfo.AutoCtrlTempPlate;
  CommTempPlate.Connect(Common.SystemInfo.Com_TempPlates);

  frmTest3Ch.tmrReadPlateTemp.Enabled := Common.SystemInfo.Com_TempPlates <> 0;

  if Finitail then begin
    Finitail := False;
    Login_MES;
  end;
end;

procedure TfrmMain_Tls.tmrSystemResourceCheckTimer(Sender: TObject);
var
  nUsed, nTotal : Integer;
  bError  : Boolean;
  sErrMsg : string;
begin
  if LibCommon = nil then Exit;

  pnlMemCheck.Caption := LibCommon.GetMemoryUsedMemory;

  stsHdd.Caption := LibCommon.GetCurHdd(0,Common.SystemInfo.limitHdd,bError,nUsed, nTotal,sErrMsg);
  spgHdd.BarColor       := clHighlight;
  spgHdd.TotalParts     := nTotal;
  spgHdd.ShowParts      := True;
  spgHdd.PartsComplete  := nUsed;
  spgHdd.Hint := Format('HDD : %d %%',[nUsed div nTotal]);

  if bError then begin
    spgHdd.BarColor := clRed;
    ShowHddNgMsg(sErrMsg);
  end;

end;


procedure TfrmMain_Tls.WMCopyData_PG(var CopyMsg: TMessage);
var
  i, nMode, nCh, nTemp : Integer;
  sMsg, sTemp : string;
//  {$IFDEF PG_DP860}
	bPgVerAllNG, bPgVerHwNG, bPgVerFwNG, bPgVerSubFwNG, bPgVerFpgaNG, bPgVerPwrNG : Boolean;
//	{$ENDIF}
begin
//  nType := DefCommon.MSG_TYPE_PG;
  nCh   := PGuiPg2Main(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.PgNo;
  nMode := PGuiPg2Main(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.Mode;
  case nMode of
    DefCommon.MSG_MODE_DISPLAY_CONNECTION : begin
      nTemp := PGuiPg2Main(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.Param;
      sMsg  := PGuiPg2Main(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.sMsg;
      case nTemp of
        DefCommon.PG_CONN_DISCONNECTED : begin


        end;
        DefCommon.PG_CONN_CONNECTED : begin

        end;
        DefCommon.PG_CONN_VERSION : begin

          bPgVerAllNG   := False;
          if Common.TestModelInfoPG.PgVer.VerAll <> '' then bPgVerAllNG  := (CompareText(Pg[nCh].m_PgVer.VerAll, Common.TestModelInfoPG.PgVer.VerAll) < 0);
          bPgVerHwNG    := False;
          if Common.TestModelInfoPG.PgVer.HW    <> '' then bPgVerHwNG    := (CompareText(Pg[nCh].m_PgVer.HW,   Common.TestModelInfoPG.PgVer.HW)    < 0);
          bPgVerFwNG    := False;
          if Common.TestModelInfoPG.PgVer.FW    <> '' then bPgVerFwNG    := (CompareText(Pg[nCh].m_PgVer.FW,   Common.TestModelInfoPG.PgVer.FW)    < 0);
          bPgVerSubFwNG := False;
          if Common.TestModelInfoPG.PgVer.SubFW <> '' then bPgVerSubFwNG := (CompareText(Pg[nCh].m_PgVer.SubFW,Common.TestModelInfoPG.PgVer.SubFW) < 0);
          bPgVerFpgaNG  := False;
          if Common.TestModelInfoPG.PgVer.FPGA  <> '' then bPgVerFpgaNG  := (CompareText(Pg[nCh].m_PgVer.FPGA, Common.TestModelInfoPG.PgVer.FPGA)  < 0);
          bPgVerPwrNG   := False;
          if Common.TestModelInfoPG.PgVer.PWR   <> '' then bPgVerPwrNG   := (CompareText(Pg[nCh].m_PgVer.PWR,  Common.TestModelInfoPG.PgVer.PWR)   < 0);
          //
          if bPgVerAllNG or bPgVerHwNG or bPgVerFwNG or bPgVerSubFwNG or bPgVerFpgaNG or bPgVerPwrNG then begin
            sTemp := '';
            if bPgVerAllNG   then sTemp := sTemp + Format('    PG-ALL[%s], Model-ALL[%s]',    [PG[nCh].m_PgVer.VerAll,Common.TestModelInfoPG.PgVer.VerAll]) + #13#10;;
            if bPgVerHwNG    then sTemp := sTemp + Format('    PG-HW[%s], Model-HW[%s]',      [PG[nCh].m_PgVer.HW,    Common.TestModelInfoPG.PgVer.HW]) + #13#10;;
            if bPgVerFwNG    then sTemp := sTemp + Format('    PG-FW[%s], Model-FW[%s]',      [PG[nCh].m_PgVer.FW,    Common.TestModelInfoPG.PgVer.FW]) + #13#10;;
            if bPgVerSubFwNG then sTemp := sTemp + Format('    PG-SubFW[%s], Model-SubFW[%s]',[PG[nCh].m_PgVer.SubFw, Common.TestModelInfoPG.PgVer.SubFW]) + #13#10;;
            if bPgVerFpgaNG  then sTemp := sTemp + Format('    PG-FPGA[%s], Model-FPGA[%s]',  [PG[nCh].m_PgVer.FPGA,  Common.TestModelInfoPG.PgVer.FPGA]) + #13#10;;
            if bPgVerPwrNG   then sTemp := sTemp + Format('    PG-POWER[%s], Model-POWER[%s]',[PG[nCh].m_PgVer.PWR,   Common.TestModelInfoPG.PgVer.PWR]) + #13#10;;
            sTemp := 'PG Version Mismatched !!' + #13#10 + sTemp;
            ShowNgMessage(sTemp);
          end;
        end;
        DefCommon.PG_CONN_READY : begin

        end;
      end;
    end;
    else begin
      //TBD?
    end;
  end;
end;

procedure TfrmMain_Tls.WMSyscommandBroadcast(var Msg: TMessage);
var
  SSStr: String;
begin
  if (Msg.wParam and $FFF0) = SC_SCREENSAVE then // 화면 보호기 시작
  begin
    with TRegistry.Create do begin
      RootKey := HKEY_CURRENT_USER;
      OpenKey('Control Panel\Desktop',False);
      SSStr := ReadString('SCRNSAVE.EXE'); // Windows NT 기반
      Free;
    end;

    if not FileExists(SSStr) then  begin
      with TIniFile.Create('system.ini') do begin
        SSStr := ReadString('boot','SCRNSAVE.EXE',''); // Windows 98
        Free;
      end;
    end;

    // 사용자가 윈도우즈에서 화면 보호기를 껐다

    // Windows2000은 화면보호기를 사용자가 꺼도 이벤트가 발생하므로 프로그램에서도 화면보호기를 꺼야함

    if FileExists(SSStr) then
      ShowSysLog('SC_SCREENSAVE: 화면 꺼짐')
    else
      SystemParametersInfo(SPI_SETSCREENSAVEACTIVE, ord(FALSE), nil, SPIF_SENDCHANGE); // 화면보호기 OFF
    Msg.Result := Integer(True);
  end
  else if ((Msg.wParam and $FFF0) = SC_MONITORPOWER) and (Msg.lParam = 2) then // 모니터 꺼짐 (2=turn off the monitor)
  begin
    ShowSysLog('SC_MONITORPOWER: 화면 꺼짐');
    Msg.Result := Integer(False);
  end;

  inherited;

end;


procedure TfrmMain_Tls.WMCopyData(var Msg: TMessage);
var
  nType, nMode, nCh, nTemp : Integer;
  nParam1, nParam2, nProbeNo : Integer;
  sMsg,sSubMsg : string;
  pGUIMsg: PGUIMessage;
begin
  nType := PGuiSwitch(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgType;
  nCh   := PGuiSwitch(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;
  pGUIMsg:= PGUIMessage(PCopyDataStruct(Msg.LParam)^.lpData);

  case nType of
    DefCommon.MSG_TYPE_PG      : WMCopyData_PG(Msg); //= MSG_TYPE_AF9FPGA

    DefCommon.MSG_TYPE_CTL_DIO : begin
      ProcessMsg_COMM_DIO(pGUIMsg);
    end; //DefCommon.MSG_TYPE_CTL_DIO : begin

    DefCommon.MSG_TYPE_SCRIPT : begin
      ProcessMsg_SCRIPT(pGUIMsg);
    end; //DefCommon.MSG_TYPE_SCRIPT : begin

    DefCommon.MSG_TYPE_NONE : begin  //공용 메시지 - 지정되지 않음
      case pGUIMsg.Mode of
        MSG_MODE_ADDLOG: begin
          //단순 System Log 추가
          ShowSysLog(pGUIMsg.Msg, pGUIMsg.Param);
        end;
        MSG_MODE_ADDLOG_CHANNEL: begin
          //test에 각 채널에 로그 추가
//          frmTest4ChOC[pGUIMsg.Param].AddLog(pGUIMsg.Msg, pGUIMsg.Param2);
        end;

        MSG_MODE_RESET_ALARM: begin

        end;
      end;

    end; //DefCommon.MSG_TYPE_ADDLOG : begin



    DefCommon.MSG_TYPE_CA410 : begin
{$IFDEF CA410_USE}
      nMode := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgMode;
      nTemp := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
      // nCh은 해당 Jig로 사용.
      case nMode of
        TDllCaSdk2.MSG_MODE_LOG : begin
//            Set_AlarmData(nTemp, 1, 1); //중 알람

        end;
        TDllCaSdk2.MSG_MODE_STATUS : begin
          // nTemp = 0 이면 해당 Channel 사용하지 않음. 아니면 사용.
          nProbeNo := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.ProbeNo;
          if nTemp = 0 then begin
            ledCA410[nProbeNo].FalseColor  := clGray;
            ledCA410[nProbeNo].Value       := False;
          end
          else begin
            nTemp := Common.SystemInfo.Com_Ca410_DevieId[nProbeNo];
            sSubMsg := Format('USB ID (COMM%d)',[nTemp]);
            sMsg  := 'CA410 ERROR : '+ PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
            ledCA410[nProbeNo].FalseColor := clRed;
            if PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.bError then begin
              ShowSysLog(sMsg, 1);
              ledCA410[nProbeNo].Value := False;
            end
            else begin
              ledCA410[nProbeNo].Value       := True;
            end;
          end;
        end;

        DefCommon.MSG_MODE_CA410_NG : begin
          if PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.bError then begin
            Common.MLog(DefCommon.MAX_SYSTEM_LOG,PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
          end;
        end;

        TDllCaSdk2.MSG_MODE_CAX10_MEM_CH_NO : begin
          nProbeNo := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.ProbeNo;
          pnlCa410MemCh.Caption := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
          if Common.TestModelInfoFLOW.Ca410MemCh <> nProbeNo then begin
            pnlCa410MemCh.Color := clRed;
          end;
        end;
      end;
{$ENDIF}
    end;

    
    DefCommon.MSG_TYPE_IONIZER : begin
      nMode := PGuiIonizer(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      sMsg  := string(PGuiIonizer(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
      nTemp  := PGuiIonizer(PCopyDataStruct(Msg.LParam)^.lpData)^.Param1;
      nCh := PGuiIonizer(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;
      if ControlDio <> nil then ControlDio.SetIonizerNg(nCh,nTemp);
      case nMode of
        CommIonizer.MSG_MODE_IONIZER_CONNECTION : begin
          case nCh of
            0: begin
              pnlIonizer.Caption := sMsg;
              case nTemp of
                0 : begin
                  ledIonizer1.FalseColor := clRed;
                  ledIonizer1.Value := False;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH1, 1, 1);
                end;
                1 : begin
                  ledIonizer1.Value := True;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH1, 0, 1);
                end;
                2 : begin
                  ledIonizer1.FalseColor := clGray;
                  ledIonizer1.Value := False;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH1, 0, 1);
                end;
              end;

            end;

            1: begin
              pnlIonizer2.Caption := sMsg;
              case nTemp of
                0 : begin
                  ledIonizer2.FalseColor := clRed;
                  ledIonizer2.Value := False;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH2, 1, 1);
                end;
                1 : begin
                  ledIonizer2.Value := True;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH2, 0, 1);
                end;
                2 : begin
                  ledIonizer2.FalseColor := clGray;
                  ledIonizer2.Value := False;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH2, 0, 1);
                end;
              end;
            end;
            2: begin
              pnlIonizer3.Caption := sMsg;
              case nTemp of
                0 : begin
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH3, 1, 1);
                  ledIonizer3.FalseColor := clRed;
                  ledIonizer3.Value := False;
                end;
                1 : begin
                  ledIonizer3.Value := True;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH3, 0, 1);
                end;
                2 : begin
                  ledIonizer3.FalseColor := clGray;
                  ledIonizer3.Value := False;
                  Set_AlarmData(DefDio.ERR_LIST_IONIZER_STATUS_NG_CH3, 0, 1);
                end;
              end;
            end;
          end;

        end;
        CommIonizer.MSG_MODE_IONIZER_ERR_MSG : begin
          case nCh of
            0: begin
              pnlIonizer.Caption := sMsg;
              if ledIonizer1.Value then begin
                ledIonizer1.Value:= False;
                ShowSysLog('Ionizer Ch1 Status NG: ' + sMsg, 1);
              end;
            end;
            1: begin
              pnlIonizer2.Caption := sMsg;
              if ledIonizer2.Value then begin
                ledIonizer2.Value:= False;
                ShowSysLog('Ionizer Ch2 Status NG: ' + sMsg, 1);
              end;

            end;
            2: begin
              pnlIonizer3.Caption := sMsg;
              if ledIonizer3.Value then begin
                ledIonizer3.Value:= False;
                ShowSysLog('Ionizer Ch3 tatus NG: ' + sMsg, 1);
              end;
            end;
          end;


        end;
        CommIonizer.MSG_MODE_IONIZER_LOG : begin
          ShowSysLog(sMsg);
          if frmMainter <> nil then begin
            frmMainter.IonizerReadData(True,sMsg);
//          end
//          else begin
//            ShowSysLog(sMsg);
          end;
        end;

      end;
    end;

    DefCommon.MSG_TYPE_COMMTHERMOMETER : begin
      nMode := pGUIMsg.Mode;//PGUIMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      sMsg  := string(PGUIMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
//      nTemp  := PGUIMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param;
//      nCh := PGUIMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;

      case nMode of
        CommThermometerMulti.COMMTHERMOMETER_CONNECT: begin
          //Connect
          case pGUIMsg.Param of
            0: ShowSysLog('Disconnected: ' + pGUIMsg.Msg,1);
            1: ShowSysLog('Connected: ' + pGUIMsg.Msg,2);
            2: ShowSysLog('Timeout: ' + pGUIMsg.Msg,1);
            3: ShowSysLog(pGUIMsg.Msg);
          end;
          ledTempIr.Value := False;
          case pGUIMsg.Param of
            0: ledTempIr.FalseColor := clRed;
            1: ledTempIr.Value  := True;
            2: ledTempIr.FalseColor := clRed;
            3: ledTempIr.FalseColor := clGray;
          end;
          case pGUIMsg.Param of
            0: pnlCommTempIr.Caption := 'Disconnected: ' + pGUIMsg.Msg;
            1: pnlCommTempIr.Caption := 'Connected: ' + pGUIMsg.Msg;
            2: pnlCommTempIr.Caption := 'Timeout: ' + pGUIMsg.Msg;
            3: pnlCommTempIr.Caption := pGUIMsg.Msg;
          end;
        end;
        CommThermometerMulti.COMMTHERMOMETER_UPDATE: begin
          //Update
//          ShowSysLog(Format('Data Update Ch=%d: %d', [pGUIMsg.Param2, pGUIMsg.Param]));
          if frmTest3Ch <> nil then begin
            frmTest3Ch.ShowIrTempData(pGUIMsg.Param2, pGUIMsg.Param);
          end;
        end;
        CommThermometerMulti.COMMTHERMOMETER_ADDLLOG: begin
          //AddLog
//          ShowSysLog('[LOG] ' + pGUIMsg.Msg);
        end;
      end;
    end; //MSG_TYPE_AUTONICS : begin


    DefCommon.MSG_TYPE_EXT_CONTROL: begin
      nMode := pGUIMsg.Mode;
      sMsg  := pGUIMsg.Msg;
      case nMode of
        1: begin //Initialize
          ShowSysLog(Format('Program Initialize from External : %s ',[sMsg]));
        end;

        2 :  begin //Teminate Program
          ShowSysLog(Format('Program Terminate from External : %s ',[sMsg]));
        end;
      end;
    end;

    DefCommon.MSG_TYPE_TEMP_PLATES : begin
      nCh   := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;
      nMode := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      sMsg  := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
      nParam1 := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param;
      nParam2 := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param2;
      case nMode of
        CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_CONNECT : begin
          pnlStatusTempPlate.Caption := sMsg;
          case nParam1 of
            0: begin ledTempPlate.Value := False; ledTempPlate.FalseColor := clRed; end;
            1: ledTempPlate.Value := True;
            2: begin ledTempPlate.Value := False; ledTempPlate.FalseColor := clRed; end;
            3: begin ledTempPlate.Value := False; ledTempPlate.FalseColor := clGray; end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfrmMain_Tls.WMPostMessage(var Msg: TMessage);
begin
  case Msg.WParam of //보낸주체 종류
    COMMDIO_MSG_CONNECT: begin
      if Msg.LParam <> 0 then begin
        pnlDioStatus.Caption := 'Connected'; // + IntToHex(CommDaeDIO.DeviceInfo.Version[0]); // + PGuiDaeDio(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
        ledDio.Value := True;
//        ShowSysLog('DIO Connected');
      end
      else begin
        pnlDioStatus.Caption := 'Disconnected'; // + PGuiDaeDio(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
        ledDio.Value := False;
        ShowSysLog('DIO Disconnected', 1);
      end;
    end;

    COMMDIO_MSG_CHANGE_DI: begin
      Display_Memory_DI;
    end;

    COMMDIO_MSG_CHANGE_DO: begin
      Display_Memory_DO;
    end;

  end;
end;

procedure TfrmMain_Tls.Init_AlarmMessage;
begin









end;


end.

