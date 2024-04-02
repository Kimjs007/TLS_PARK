unit FormMainter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.UITypes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RzRadChk, Vcl.StdCtrls, RzLabel, Vcl.Mask,
  RzEdit, RzCmboBx, RzButton, RzPanel, ALed, Vcl.ExtCtrls, RzTabs, CommPG, DefDio, RzCommon,
  CommHandBCR, IdGlobal, System.IniFiles, CommDIO_DAE, FormNGMsg, CommModbusRtuTempPlate,
  CommonClass, RzShellDialogs, DefCommon, DefPG, RzLstBox, ScrMemo, ScrMps, pasScriptClass, CommIonizer,
  AdvUtil, Vcl.Grids, AdvObj, BaseGrid, AdvGrid,{, system.threading}  CtrlDio_Tls, FormDoorOpenAlarmMsg,
  Winapi.WinSock, Vcl.Imaging.pngimage, AdvPanel, AdvSmoothListBox, AdvSmoothComboBox

  ,DllCasSdkCa410
  ;

  const
  MAINT_CMD_POWER_ON      = 0;
  MAINT_CMD_POWER_OFF     = 1;
  MAINT_CMD_PATTERN_NUM   = 2;
  MAINT_CMD_PATTERN_RGB   = 3;
  MAINT_CMD_DIMMING       = 4;
  MAINT_CMD_LGD_REG_READ  = 5;
  MAINT_CMD_LGD_REG_WRITE = 6;
  MAINT_CMD_APS_REG_READ  = 7;
  MAINT_CMD_APS_REG_WRITE = 8;
  MAINT_CMD_AF9API_TEST   = 9;

type

  PGuiMainter  = ^RGuiMainter;
  RGuiMainter = packed record
    MsgType : Integer;  // 1 : PG, 2 : Camera.
    Channel : Integer;  // Channel.
    Mode    : Integer;
    Msg     : string;
  end;

  TfrmMainter = class(TForm)
    btnClose: TRzBitBtn;
    pnlMainter: TRzPanel;
    pgcMainter: TRzPageControl;
    TabSheet1: TRzTabSheet;
    tabIoMap: TRzTabSheet;
    RzGroupBox1: TRzGroupBox;
    RzPanel1: TRzPanel;
    cboChannelPg: TRzComboBox;
    RzPanel2: TRzPanel;
    mmCommPg: TMemo;
    btnSendCmdPg: TRzBitBtn;
    cboCmdPg: TRzComboBox;
    edParam: TRzEdit;
    RzPanel6: TRzPanel;
    RzBitBtn1: TRzBitBtn;
    RzOpenDialog1: TRzOpenDialog;
    btnPowerOff: TRzBitBtn;
    RzGroupBox2: TRzGroupBox;
    RzPanel3: TRzPanel;
    cboScriptCh: TRzComboBox;
    btn2: TRzBitBtn;
    btnRunScript: TRzBitBtn;
    RzGroupBox5: TRzGroupBox;
    RzGroupBox6: TRzGroupBox;
    ScrMemo1: TScrMemo;
    mmoScrResult: TMemo;
    ScrPascalMemoStyler1: TScrPascalMemoStyler;
    tbSystemInfo: TRzTabSheet;
    RzGroupBox4: TRzGroupBox;
    lstIpInformation: TRzListBox;
    RzGroupBox8: TRzGroupBox;
    img1: TImage;
    img2: TImage;
    pnl1: TPanel;
    pnl2: TPanel;
    RzGroupBox11: TRzGroupBox;
    lstLocalIp: TRzListBox;
    btnScriptOpen: TRzBitBtn;
    btnScriptSave: TRzBitBtn;
    btnStopScript: TRzBitBtn;
    btnPowerOn: TRzBitBtn;
    dlgSavePro: TRzSaveDialog;
    dlgOpenPro: TRzOpenDialog;
    grpDioIn: TRzGroupBox;
    grpDioOut: TRzGroupBox;
    TabSheet2: TRzTabSheet;
    btnCal0: TRzBitBtn;
    btnMemChInfo: TRzBitBtn;
    btnOneTimeMeasure: TRzBitBtn;
    btnRGBWMeasure: TRzBitBtn;
    RzGroupBox23: TRzGroupBox;
    RzGroupBox24: TRzGroupBox;
    grdCalVerify: TAdvStringGrid;
    btnSaveCalResult: TRzBitBtn;
    RzBitBtn12: TRzBitBtn;
    grpCa410CalSet: TRzGroupBox;
    RzGroupBox15: TRzGroupBox;
    gridTarget: TAdvStringGrid;
    btnAutoCal: TRzBitBtn;
    RzGroupBox16: TRzGroupBox;
    mmoAutoCalLog: TMemo;
    btnStopCalibration: TRzBitBtn;
    pnlCalLog: TPanel;
    grpCalControl: TRzGroupBox;
    RzPanel39: TRzPanel;
    edRty_Cal: TRzNumericEdit;
    edAging_Cal: TRzNumericEdit;
    RzPanel33: TRzPanel;
    RzPanel149: TRzPanel;
    RzGroupBox17: TRzGroupBox;
    RzPanel7: TRzPanel;
    cboModelType: TRzComboBox;
    cboCalData: TRzComboBox;
    RzPanel8: TRzPanel;
    rdoProbe1: TRzRadioButton;
    rdoProbe2: TRzRadioButton;
    RzGroupBox19: TRzGroupBox;
    pnlMemChWhite: TRzPanel;
    pnlMCh1: TPanel;
    btnProbeWhite: TRzBitBtn;
    btnProbeRed: TRzBitBtn;
    btnProbeGreen: TRzBitBtn;
    Blue: TRzBitBtn;
    btnProbeBlack: TRzBitBtn;
    btnProbePowerOff: TRzBitBtn;
    btnProbePowerOn: TRzBitBtn;
    btnCalStProbe: TRzBitBtn;
    btnCalEdProbe: TRzBitBtn;
    RzPanel5: TRzPanel;
    edRgbwMAging: TRzNumericEdit;
    RzPanel9: TRzPanel;
    grpControlProbe: TRzGroupBox;
    btnProbeDown: TRzBitBtn;
    btnProbeUp: TRzBitBtn;
    cboPatList: TRzComboBox;
    pnlParamDesc: TRzPanel;
    cbPatDispPwm: TRzCheckBox;
    TabSheet3: TRzTabSheet;
    gbIonizer: TRzGroupBox;
    btnIonizerStart: TRzBitBtn;
    memoIonizer: TRzMemo;
    btnIonizerStop: TRzBitBtn;
    rdoProbe3: TRzRadioButton;
    cboIonizerChannel: TRzComboBox;
    grpBcr: TRzGroupBox;
    mmHandBcr: TMemo;
    RzGroupBox7: TRzGroupBox;
    btnUnlockDoors: TRzBitBtn;
    cboSelectDoorUnlock: TRzComboBox;
    btnProbeMove: TRzBitBtn;
    RzBitBtn2: TRzBitBtn;
    rdoCh1: TRzRadioButton;
    rdoCh2: TRzRadioButton;
    rdoCh3: TRzRadioButton;
    chkUseTowerLamp: TCheckBox;
    btnReadOutSig: TRzBitBtn;
    RzBitBtn11: TRzBitBtn;
    tabTempPlates: TRzTabSheet;
    grpControlTempPlates: TRzGroupBox;
    rdoProbe6: TRzRadioButton;
    rdoProbe5: TRzRadioButton;
    rdoProbe4: TRzRadioButton;
    rdoProbe7: TRzRadioButton;
    rdoProbe8: TRzRadioButton;
    rdoProbe9: TRzRadioButton;

    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSendCmdPgClick(Sender: TObject);
    procedure WMCopyData(var Msg : TMessage); message WM_COPYDATA;
    procedure RzBitBtn1Click(Sender: TObject);
    procedure btnPowerOffClick(Sender: TObject);
    procedure btnRunScriptClick(Sender: TObject);
    procedure btnAutoCalClick(Sender: TObject);
    procedure gridTargetKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnOneTimeMeasureClick(Sender: TObject);
    procedure btnScriptOpenClick(Sender: TObject);
    procedure btnScriptSaveClick(Sender: TObject);
    procedure btnStopScriptClick(Sender: TObject);
    procedure pgcMainterClick(Sender: TObject);
    procedure btnPowerOnClick(Sender: TObject);


    procedure btnCalStProbeClick(Sender: TObject);
    procedure btnCalEdProbeClick(Sender: TObject);
    procedure RzBitBtn19Click(Sender: TObject);



    procedure RzBitBtn20Click(Sender: TObject);
    procedure btnUnlockTopDoorsClick(Sender: TObject);
    procedure btnReadOutSigClick(Sender: TObject);
    procedure RzBitBtn11Click(Sender: TObject);
    procedure edCmdPosChange(Sender: TObject);
    procedure chkUseTowerLampClick(Sender: TObject);
    procedure btnStopCalibrationClick(Sender: TObject);
    procedure btnRGBWMeasureClick(Sender: TObject);
    procedure btnMemChInfoClick(Sender: TObject);
    procedure btnCal0Click(Sender: TObject);
    procedure btnUnlockBottomDoorsClick(Sender: TObject);
    procedure btnUnlockDoorsClick(Sender: TObject);
    procedure btnProbeMoveClick(Sender: TObject);
    procedure RzBitBtn2Click(Sender: TObject);
    procedure btnProbeDownClick(Sender: TObject);
    procedure btnProbeUpClick(Sender: TObject);
    procedure btnIonizerStartClick(Sender: TObject);
    procedure btnIonizerStopClick(Sender: TObject);

  private
    { Private declarations }

    ledIn : array[0 .. DefDio.MAX_IO_CNT] of ThhALed;
    pnlIn : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;
    pnlDioIn : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;

    ledOut : array[0 .. DefDio.MAX_IO_CNT] of ThhALed;
    btnOutSig : array[0 .. DefDio.MAX_IO_CNT] of TRzBitBtn;
    pnlOut : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;
    pnlDioOut : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;
    m_bChangeZAxisValue: Boolean;

    m_bStopCa310Cal : boolean;

    // Added by Clint 2023-04-29 오전 2:24:40 For Temp Plate.
    pnlGroupPlates : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;

    pnlTitle, pnlReady, pnlRun, pnlAlarm : array[0 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;
    pnlHeating, pnlCooling, pnlSv, pnlPv, pnlMv : array[0 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;
    btnRun, btnStop, btnReset, btnSvSet : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzBitBtn;
    edtSv, edtPv, edtMv : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzEdit;
    cboTempPlate : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzComboBox;
    pnlTempPlateAlarm   : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3,0 .. 7] of TPanel;

    pnlChillerReady, pnlChillerRun, pnlChillerAlarm, pnlChillerOperated : TPanel;
    pnlSysStateEms,pnlSysStateMc, pnlSysStatePwr, pnlSysStateReset : TPanel;
    pnlChillerAlarms  : array[0 .. 9] of TPanel;

    procedure AddItemsInCbo;  // Added by KTS 2022-08-09 오전 11:55:25
    procedure AddCboCsvData;
    procedure LoadOptIni(sDir: string);
    procedure LoadOptCsv(sFileName: string);
    procedure SaveOptCsv(sFileName : string);
    procedure ClearCalResult;
    procedure ShowUsercalItems;  // Added by KTS 2022-08-09 오전 11:54:14

    procedure GetPgRxData(nPgNo: Integer; sLocal,sRemote: string; sMsg: string);
    procedure GetPgTxData(nPgNo: Integer; sLocal,sRemote: string; sMsg: string);

    procedure GetPgRevData(nPgNo : Integer; nLength : Integer; RevData : array of byte);
    procedure SendGuiDisplay(nCh: Integer; sMsg : string);

    procedure ThreadTask(task : TProc; btnObj : TRzBitBtn);
    procedure ThreadTask2(task : TProc; grpObj : TRzGroupBox);

    procedure PowerOffSeq(nCh : Integer);
    procedure PowerOnSeq(nCh : Integer);
    procedure CmdThread(nCh : Integer);
    procedure OnEvtOutBtn(Sender: TObject);
    procedure OnEvtTempPateBtn(Sender : TObject);
    procedure getBcrData(sScanData : string);

    procedure GetLocalIpList;

    function GetProbeNum : Integer;
    procedure SaveCalResult(bIsVerify : Boolean = False);
  

    procedure SystemIpList;
    procedure MakeDIOSignal;

    function GetDioChannel : Integer;
    procedure CA410Calibration(Lth : TThread; GetAllxy, Getlmt: TAllLvXy);
    procedure wRgb_Measure(thMain : TThread);
    procedure Ca410CalControlPnl(bIsFreeLock : boolean);
    procedure MakeTempPlateItems;
    procedure checkSignalTempPlates(inputPanel : TPanel; IsTrue : Boolean; IsAlarm : Boolean = False);
  public
    m_hMain : HWND;
    procedure DisplayDio( bIn : Boolean );
    procedure IonizerReadData(bConnect : Boolean; sReadData : String);
    procedure DisplayTempPlates;
  end;

var
  frmMainter: TfrmMainter;

implementation


{$R *.dfm}

{$WARN IMPLICIT_STRING_CAST_LOSS OFF}
{$WARN IMPLICIT_STRING_CAST OFF}

procedure TfrmMainter.btnReadOutSigClick(Sender: TObject);
begin
  if CommDaeDIO <> nil then  CommDaeDIO.ReadDO(0,DefDio.DAE_IO_DEVICE_COUNT);
end;

procedure TfrmMainter.ClearCalResult;
var
  i : Integer;
  sTemp : string;
begin
// Header for first line.
  grdCalVerify.ClearAll;
  grdCalVerify.Cells[0,0]   := 'Date/Time';
  grdCalVerify.Cells[1,0]   := 'CH';
  grdCalVerify.Cells[2,0]   := 'Count';
// Header for Second Line.
  for i := 1 to 4 do begin
    case i of
      1 : sTemp := 'R';
      2 : sTemp := 'G';
      3 : sTemp := 'B';
      4 : sTemp := 'W'
      else sTemp := '';
    end;
    grdCalVerify.Cells[(i*3)    ,0] := sTemp + '_x';
    grdCalVerify.Cells[(i*3) + 1,0] := sTemp + '_y';
    grdCalVerify.Cells[(i*3) + 2,0] := sTemp + '_Lv';
  end;
  grdCalVerify.Cells[15,0]  := 'Result';
end;


procedure TfrmMainter.Ca410CalControlPnl(bIsFreeLock: boolean);
begin

end;

procedure TfrmMainter.CA410Calibration(Lth: TThread; GetAllxy, Getlmt: TAllLvXy);
var
  i, j, k , nCh, nR, nG, nB, nMemCh : Integer;
  sDebug, sCh, sTemp : string;
  bRet, bIsOk : boolean;
  MemChInfo : array [0 .. TDllCaSdk2.IDX_MAX] of  TLvXY;
  x, y , lv : Double;
  GetData : TBrightValue;
  sPidNo  : AnsiString;
  nCaRet : Integer;

  rx, ry, rLv : Double;
  gx, gy, gLv : Double;
  bx, by, bLv : Double;
  wx, wy, wLv : Double;
begin
// System Connection Checking.
  nCh := GetProbeNum;

  bIsOk := True;
  nMemCh := Common.OpticInfo.CalMemCh[TDllCaSdk2.IDX_WHITE];

  if m_bStopCa310Cal then Exit;
  try
    nCaRet := DllCaSdk2.UsrCalReady(nCh,nMemCh);
    if nCaRet <> 0 then begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('Ch%d UserCalReady NG, error code(%d) ',[nCh + 1,nCaRet]);
        mmoAutoCalLog.Lines.Add(sDebug);
      end);
      Exit;
    end;
    Sleep(1000);

    for i := TDllCaSdk2.IDX_RED to  TDllCaSdk2.IDX_MAX do begin
      case i of
        TDllCaSdk2.IDX_WHITE : begin
          nR := 255;  nG := 255;  nB := 255;  sTemp := 'W';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_1,False);  // white.
        end;
        TDllCaSdk2.IDX_RED : begin
          nR := 255;  nG := 0;    nB := 0;    sTemp := 'R';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_2,False);  // R.
        end;
        TDllCaSdk2.IDX_GREEN : begin
          nR := 0;    nG := 255;  nB := 0;    sTemp := 'G';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_3,False);  // G.
        end;
        TDllCaSdk2.IDX_BLUE : begin
          nR := 0;    nG := 0;    nB := 255;  sTemp := 'B';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_4,False);  // B.
        end;
      end;

      Sleep(1000);
      nCaRet := DllCaSdk2.UsrCalMeasure(nCh,i,x, y , lv);
      if nCaRet <> 0 then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d Calibration Measure NG, error code(%d) ',[nCh + 1,nCaRet]);
          mmoAutoCalLog.Lines.Add(sDebug);
        end);
        Exit;
      end;
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('Cal Measure  Ch %d , x(%0.4f), y(%0.4f), Lv(%0.4f)',[nCh + 1,x, y , lv]);
        mmoAutoCalLog.Lines.Add(sDebug);
      end);
      nCaRet := DllCaSdk2.UsrCalSetCalData(nCh,i,GetAllxy[i].x,GetAllxy[i].y,GetAllxy[i].Lv);
      if nCaRet <> 0 then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d SetMatrixCal NG, error code(%d) ',[nCh + 1,nCaRet]);
          mmoAutoCalLog.Lines.Add(sDebug);
        end);
        Exit;
      end;
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('%s:SetMatrixCal:Ch(%d), x(%0.4f), y(%0.4f), Lv(%0.4f)',[sTemp, nCh +1, GetAllxy[i].x,GetAllxy[i].y,GetAllxy[i].Lv]);
        sDebug := Format('Mem Ch %d , ',[nMemCh]) + sDebug;
        mmoAutoCalLog.Lines.Add(sDebug);
      end);
    end;

    Lth.Synchronize(Lth, procedure begin
      mmoAutoCalLog.Lines.Add('Matrix Calibration Update');
    end);
//    nCaRet := MatrixCal_Update(nCh);
    nCaRet := DllCaSdk2.CasdkEnter(nCh);
    if nCaRet <> 0 then begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('Ch%d Calibration Update NG, error code(%d) ',[nCh + 1,nCaRet]);
        mmoAutoCalLog.Lines.Add(sDebug);
      end);
      Exit;
    end;
    Sleep(500);
  except
    on E: Exception do begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := 'Error --- Reset.';
        mmoAutoCalLog.Lines.Add(sDebug);
        sDebug := 'CA410(' +E.Message+')';
        mmoAutoCalLog.Lines.Add(sDebug);
        Ca410CalControlPnl(True);
      end);
    end;
  end;

  DllCaSdk2.ResetCalMode(nCh);
  //ResetLvCalMode(nCh);
//  PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_9,False); // Added by KTS 2022-08-09 오후 1:26:52 auto cal
//  Sleep(1000);
//  // Power On.
//  if Pg[nCh].SendPowerOn(1) <> WAIT_OBJECT_0 then begin
//    Lth.Synchronize(Lth, procedure begin
//      sDebug := Format('Ch%d Power Off ==> NAK ',[nCh + 1]);
//      mmoAutoCalLog.Lines.Add(sDebug);
//    end);
//    Exit;
//  end;
//  sleep(1000);
//  Pg[nCh].SendSpiWp(0);
  // Display White.
//  PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_1,False);   // Added by KTS 2022-08-09 오후 1:29:17auto cal

  nCaRet := DllCaSdk2.SetMemCh(nCh,Common.OpticInfo.CalMemCh[TDllCaSdk2.IDX_WHITE]);
  if nCaRet <> 0 then begin
    Lth.Synchronize(Lth, procedure begin
      sDebug := Format('Ch%d Memory Set NG, error code(%d) ',[nCh + 1,nCaRet]);
      mmoAutoCalLog.Lines.Add(sDebug);
    end);
    Exit;
  end;
  Sleep(1000);
  // 3회 Retry.
  for i := 1 to Common.OpticInfo.CalRetryCnt do begin
    Lth.Synchronize(Lth, procedure begin
      grdCalVerify.Cells[0,i] := FormatDateTime('hh:mm:ss',now);
      grdCalVerify.Cells[1,i] := Format('%d',[nCh+1]);
      grdCalVerify.Cells[2,i] := Format('%d',[i]);
    end);
    bRet := False;
    for j := TDllCaSdk2.IDX_RED to  TDllCaSdk2.IDX_MAX do begin
      case j of
        TDllCaSdk2.IDX_WHITE : begin
          nR := 255;  nG := 255;  nB := 255;
          sTemp := 'WHITE';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_1,False);  // Added by KTS 2022-08-09 오후 1:29:32auto cal
        end;
        TDllCaSdk2.IDX_RED : begin
          nR := 255;  nG := 0;  nB := 0;
          sTemp := 'RED';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_2,False);  // R.  // Added by KTS 2022-08-09 오후 1:29:45auto cal
        end;
        TDllCaSdk2.IDX_GREEN : begin
          nR := 0;  nG := 255;  nB := 0;
          sTemp := 'GREEN';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_3,False);  // G.   // Added by KTS 2022-08-09 오후 1:29:53 auto cal
        end;
        TDllCaSdk2.IDX_BLUE : begin
          nR := 0;  nG := 0;  nB := 255;
          sTemp := 'BLUE';
//          PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_4,False);  // B. // Added by KTS 2022-08-09 오후 1:30:02 auto cal
        end;
      end;
      // White.
      Sleep(500);

      nCaRet := DllCaSdk2.Measure(nCh,GetData);
      if nCaRet <> 0 then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d CA410 Measure NG, error code(%d) ',[nCh + 1,nCaRet]);
          mmoAutoCalLog.Lines.Add(sDebug);
        end);
        Exit;
      end;
      Lth.Synchronize(Lth, procedure begin
        grdCalVerify.Cells[j*3 + 3,i] := Format('%0.6f',[GetData.xVal]);
        grdCalVerify.Cells[j*3 + 4,i] := Format('%0.6f',[GetData.yVal]);
        grdCalVerify.Cells[j*3 + 5,i] := Format('%0.6f',[GetData.LvVal]);
      end);
      if not (Abs(GetAllxy[j].x -GetData.xVal) < Getlmt[j].x) then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d %s %d,%d,%d x Limit NG ',[nCh + 1,sTemp, nR, nG, nB]);
          mmoAutoCalLog.Lines.Add(sDebug);
          sDebug := Format('abs(%0.6f - %0.6f) ',[GetAllxy[j].x , GetData.xVal]);
          sDebug := sDebug + Format(': %0.6f >= %0.6f ',[Abs(GetAllxy[j].x - GetData.xVal),Getlmt[j].x ]);
          mmoAutoCalLog.Lines.Add(sDebug);
          bRet := True;
        end);
      end;
      if not (Abs(GetAllxy[j].y - GetData.yVal) < Getlmt[j].y) then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d %s %d,%d,%d y Limit NG ',[nCh + 1,sTemp, nR, nG, nB]);
          mmoAutoCalLog.Lines.Add(sDebug);
          sDebug := Format('abs(%0.6f - %0.6f) ',[GetAllxy[j].y , GetData.yVal]);
          sDebug := sDebug + Format(': %0.6f >= %0.6f ',[Abs(GetAllxy[j].y -GetData.yVal),Getlmt[j].y ]);
          mmoAutoCalLog.Lines.Add(sDebug);
          bRet := True;
        end);
      end;
      if not (Abs(GetAllxy[j].Lv - GetData.LvVal) < Getlmt[j].Lv) then begin
        Lth.Synchronize(Lth, procedure begin
          sDebug := Format('Ch%d %s %d,%d,%d Lv Limit NG ',[nCh + 1,sTemp, nR, nG, nB]);
          mmoAutoCalLog.Lines.Add(sDebug);
          sDebug := Format('abs(%0.6f - %0.6f) ',[GetAllxy[j].Lv , GetData.LvVal]);
          sDebug := sDebug + Format(': %0.6f >= %0.6f ',[Abs(GetAllxy[j].Lv -GetData.LvVal),Getlmt[j].Lv ]);
          mmoAutoCalLog.Lines.Add(sDebug);
          bRet := True;
        end);
      end;
    end;
    if bRet then grdCalVerify.Cells[15,i] := 'NG'
    else         grdCalVerify.Cells[15,i] := 'OK';
    bIsOk := (not bRet) and bIsOk;
  end;
  bRet := False;

  // Get Memory Information.
  nCaRet := DllCaSdk2.GetMemInfo(nCh,nMemCh,  rLv, rx, ry, gLv ,gx, gy, bLv , bx, by , wLv ,  wx, wy);
  if nCaRet <> 0 then begin
    Lth.Synchronize(Lth, procedure begin
      sDebug := Format('Ch%d Get Memory Channel Info NG, error code(%d) ',[nCh + 1,nCaRet]);
      mmoAutoCalLog.Lines.Add(sDebug);
    end);
    Exit;
  end;
  for i := TDllCaSdk2.IDX_RED to TDllCaSdk2.IDX_MAX do begin
    case i of
      TDllCaSdk2.IDX_WHITE : begin
        x := wx; y := wy; lv := wLv;  sTemp := 'W';
      end;
      TDllCaSdk2.IDX_RED : begin
        x := rx; y := ry; lv := rLv;    sTemp := 'R';
      end;
      TDllCaSdk2.IDX_GREEN : begin
        x := gx; y := gy; lv := gLv;    sTemp := 'G';
      end;
      TDllCaSdk2.IDX_BLUE : begin
        x := bx; y := by; lv := bLv;  sTemp := 'B';
      end;
    end;
    Lth.Synchronize(Lth, procedure begin
      sDebug := Format('Ch Info: MemCh(%d),Color Type(%s),x(%.4f), y(%.4f), Lv(%.1f)',[nMemCh,sTemp,x, y, Lv]);
      mmoAutoCalLog.Lines.Add(sDebug);
    end);
    if x <> GetAllxy[i].x then begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('NG - Color Type(%s) -Target X (%.4f), Measure X (%0.4f)',[sTemp,x, GetAllxy[i].x]);
        mmoAutoCalLog.Lines.Add(sDebug);
        bRet := True;
      end);
    end;
    if y <> GetAllxy[i].y then begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('NG - Color Type(%s) - Target y (%.4f), Measure y (%0.4f)',[sTemp,y, GetAllxy[i].y]);
        mmoAutoCalLog.Lines.Add(sDebug);
        bRet := True;
      end);
    end;
    if Lv <> GetAllxy[i].Lv then begin
      Lth.Synchronize(Lth, procedure begin
        sDebug := Format('NG - Color Type(%s) -Target Lv (%.4f), Measure Lv (%0.4f)',[sTemp,Lv, GetAllxy[i].Lv]);
        mmoAutoCalLog.Lines.Add(sDebug);
        bRet := True;
      end);
    end;
    bIsOk := bIsOk and (not bRet);
  end;
  Lth.Synchronize(Lth, procedure begin
    if bIsOk then   pnlCalLog.Caption := 'Cal is OK'
    else            pnlCalLog.Caption := 'Cal is NG';
  end);
  // Power Off.
//  if Pg[nCh].SendSpiPowerOn(0) <> WAIT_OBJECT_0 then begin  // Added by KTS 2022-08-09 오후 1:30:18auto cal
//    Lth.Synchronize(Lth, procedure begin
//      sDebug := Format('Ch%d Power Off ==> NAK ',[nCh + 1]);
//      mmoAutoCalLog.Lines.Add(sDebug);
//    end);
//    Exit;
//  end;               // Added by KTS 2022-08-09 오후 1:30:25 auto cal
  SaveCalResult;
end;

procedure TfrmMainter.wRgb_Measure(thMain : TThread);
var
  i, j, nRow : Integer;
  nPgNo, nProbeNum, nProbeCh, nStage : Integer;
  sCh, sColor, sDebug, sTemp : string;
  getData : TBrightValue;
begin
  nPgNo := GetProbeNum;

  // Power Off.
//  Pg[nPgNo].SendSpiPowerOn(0);
  sleep(500);
  // Power On.
//  PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_9,False);
  thMain.Synchronize(thMain, procedure begin
    sDebug := Format('Ch%d Power On',[nPgNo + 1]);
    mmoAutoCalLog.Lines.Add(sDebug);
  end);
  // Display white
//  PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_1,False);
  thMain.Synchronize(thMain, procedure begin
    sDebug := Format('Ch%d Display White patten',[nPgNo + 1]);
    mmoAutoCalLog.Lines.Add(sDebug);
  end);

  // Aging
  if Common.OpticInfo.CalRgbwAgingTm > 0 then begin
    for i := 0 to Pred(Common.OpticInfo.CalRgbwAgingTm) do begin
      thMain.Synchronize(thMain, procedure begin
        pnlCalLog.Caption := Format('%d Sec',[(Common.OpticInfo.CalRgbwAgingTm-i)]);
      end);
      sleep(1000);
      if m_bStopCa310Cal then break;
    end;
  end;
  if m_bStopCa310Cal then begin
    //Power Off
    Sleep(200);
//    Pg[nPgNo].SendSpiPowerOn(0);
    mmoAutoCalLog.Lines.Add('Power Off');
    Exit;
  end;

//  CaSdk2.SetMemCh(nPgNo,Common.OpticInfo.CalMemCh[DefCaSdk.IDX_WHITE]);
//  thMain.Synchronize(thMain, procedure begin
//    sDebug := Format('Ch%d Set Memory Channel %d',[nPgNo + 1,Common.OpticInfo.CalMemCh[DefCaSdk.IDX_WHITE]]);
//    mmoAutoCalLog.Lines.Add(sDebug);
//  end);

  for i := 1 to Common.OpticInfo.CalRetryCnt do begin
    thMain.Synchronize(thMain, procedure begin
      grdCalVerify.Cells[0,i] := FormatDateTime('hh:mm:ss',now);
      grdCalVerify.Cells[1,i] := Format('%d',[nPgNo+1]);
      grdCalVerify.Cells[2,i] := Format('%d',[i]);
    end);

    for j := TDllCaSdk2.IDX_RED to  TDllCaSdk2.IDX_MAX do begin
      case j of
        TDllCaSdk2.IDX_WHITE : begin
//          PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_1,False);
          sColor := 'WHITE';
        end;
        TDllCaSdk2.IDX_RED : begin
//          PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_2,False);
          sColor := 'RED';
        end;
        TDllCaSdk2.IDX_GREEN : begin
//          PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_3,False);
          sColor := 'GREEN';
        end;
        TDllCaSdk2.IDX_BLUE : begin
//          PasScr[nPgNo].RunSeq(DefScript.SEQ_MAINT_4,False);
          sColor := 'BLUE';
        end;
      end;
      Sleep(500);
      DllCaSdk2.Measure(nPgNo,GetData);
      thMain.Synchronize(thMain, procedure begin
        grdCalVerify.Cells[j*3 + 3,i] := Format('%0.6f',[GetData.xVal]);
        grdCalVerify.Cells[j*3 + 4,i] := Format('%0.6f',[GetData.yVal]);
        grdCalVerify.Cells[j*3 + 5,i] := Format('%0.6f',[GetData.LvVal]);
      end);
    end;
  end;
  SaveCalResult(True);
  //Power Off
  Sleep(200);
//  Pg[nPgNo].SendSpiPowerOn(0);
  thMain.Synchronize(thMain, procedure begin
    mmoAutoCalLog.Lines.Add('Power Off');
  end);
end;


procedure TfrmMainter.btnRGBWMeasureClick(Sender: TObject);
var
  nPgNo : Integer;
  thAutoMeasure : TThread;
  sDebug : string;
begin
  nPgNo := GetProbeNum;
  m_bStopCa310Cal := False;
  Common.OpticInfo.CalRgbwAgingTm := StrToIntDef(edRgbwMAging.Text,0);
  if Pg[nPgNo].StatusPg in [pgDisconn,pgWait] then begin
    thAutoMeasure.Synchronize(thAutoMeasure, procedure begin
      sDebug := Format('Channel %d is disconnected',[nPgNo + 1]);
      mmoAutoCalLog.Lines.Add(sDebug);
    end);
    Exit;
  end;
  ClearCalResult;
  mmoAutoCalLog.Lines.Clear;
  // CA310 Connection Check.
//  if not DllCaSdk2..m_bConnection[nPgNo] then begin
    thAutoMeasure.Synchronize(thAutoMeasure, procedure begin
      sDebug := Format('CA410 Channel %d is disconnected',[nPgNo + 1]);
      mmoAutoCalLog.Lines.Add(sDebug);
    end);
    Exit;
//  end;
  thAutoMeasure := TThread.CreateAnonymousThread(procedure begin
    wRgb_Measure(thAutoMeasure);
  end);
  thAutoMeasure.Start;

end;

procedure TfrmMainter.btnRunScriptClick(Sender: TObject);
var
  nCh, i : Integer;
begin
  nCh := cboScriptCh.ItemIndex;
  PasScr[i].RunMaintScript(Self.Handle,ScrMemo1);
end;



procedure TfrmMainter.btnCloseClick(Sender: TObject);
begin

  Close;
end;



procedure TfrmMainter.btnIonizerStartClick(Sender: TObject);
begin
  if DaeIonizer[cboIonizerChannel.ItemIndex] <> nil then begin
    DaeIonizer[cboIonizerChannel.ItemIndex].IsIgnoreNg := False;
    DaeIonizer[cboIonizerChannel.ItemIndex].SendRun;
  end;

end;

procedure TfrmMainter.btnIonizerStopClick(Sender: TObject);
begin
  if DaeIonizer[cboIonizerChannel.ItemIndex] <> nil then begin
    DaeIonizer[cboIonizerChannel.ItemIndex].SendStop;
    DaeIonizer[cboIonizerChannel.ItemIndex].IsIgnoreNg := True;
  end;

end;


procedure TfrmMainter.GetPgTxData(nPgNo: Integer; sLocal,sRemote: string; sMsg: string);
var
  sDebug : string;
begin
  sMsg := StringReplace(sMsg, #$0D, '#', [rfReplaceAll]); // change #$0D to '#'
  sDebug := FormatDateTime('[hh:mm:ss.zzz] ',Now) + Format('CH%d TX[%s>%s]: (%s)',[nPgNo+1, sLocal,sRemote, sMsg]);
  mmCommPg.Lines.Add(sDebug);
end;

procedure TfrmMainter.GetPgRxData(nPgNo: Integer; sLocal,sRemote: string; sMsg: string);
var
  sDebug : string;
begin
  sMsg := StringReplace(sMsg, #$0D, '#', [rfReplaceAll]); // change #$0D to '#'
  sDebug := FormatDateTime('[hh:mm:ss.zzz] ',Now) + Format('CH%d RX[%s<%s]: (%s)',[nPgNo+1, sLocal,sRemote, sMsg]);
  mmCommPg.Lines.Add(sDebug);
end;


procedure TfrmMainter.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  nCh : integer;
begin

  if UdpServerPG <> nil then begin
    for nCh := DefCommon.CH1 to DefCommon.MAX_CH do begin
      if PG[nCh] <> nil then begin
        PG[nCh].IsMainter := False;
        PG[nCh].OnRxMaintEventPG := nil;
        PG[nCh].OnTxMaintEventPG := nil;
      end;
    end;

  end;
end;

procedure TfrmMainter.AddItemsInCbo;
var
  TempList : TSearchRec;
begin
  cboModelType.Items.Clear;
  if FindFirst(Common.Path.UserCal + '\*', faAnyFile, TempList) = 0 then begin
    repeat
      if ((TempList.attr and faDirectory) = faDirectory) and
         not (TempList.Name = '.') and
         not (TempList.Name = '..') then
      begin
        if Trim(TempList.Name) = 'User_Cal_Log' then Continue;
        cboModelType.Items.Add(TempList.Name);
      end;
    until FindNext(TempList) <> 0;
  end;
  FindClose(TempList);
end;

procedure TfrmMainter.AddCboCsvData;
var
  TempList : TSearchRec;
  sCurDir  : string;
begin
  cboCalData.Items.Clear;
  if cboModelType.Items.Count < 1 then Exit;

  sCurDir := Common.Path.UserCal + cboModelType.Items[cboModelType.ItemIndex];

  if FindFirst(sCurDir + '\*.csv', faAnyFile, TempList) = 0 then begin
    repeat
      cboCalData.Items.Add(TempList.Name);
    until FindNext(TempList) <> 0;
  end;
  FindClose(TempList);
end;


procedure TfrmMainter.LoadOptIni(sDir: string);
var
  fSys        : TIniFile;
  i : Integer;
  sCalFile : string;
begin
  fSys := TIniFile.Create(Common.Path.UserCal + sDir + '\OcConfig.ini');
  try
    pnlMCh1.Caption := fSys.ReadString('CA410_USER_CAL','CAL_MEMORY_CH1','1');
    edAging_Cal.Text := fSys.ReadString('CA410_USER_CAL','AGING_TIME','600');
    edRty_Cal.Text  := fSys.ReadString('CA410_USER_CAL','VERIFY_CNT','3');
    edRgbwMAging.Text := fSys.ReadString('CA410_USER_CAL','AGING_RGBWM','0');

    if cboCalData.Items.Count > 0 then begin
      sCalFile := fSys.ReadString('CA410_USER_CAL','SEL_CAL_FILE','');
      if sCalFile <> '' then begin
        for i := 0 to Pred(cboCalData.Items.Count) do begin
          if cboCalData.Items[i] = sCalFile then begin
            cboCalData.ItemIndex := i;
            Break;
          end;
        end;
      end;
    end;
  finally
    fSys.Free;
  end;

  Common.OpticInfo.CalMemCh[TDllCaSdk2.IDX_WHITE] := StrToIntDef(pnlMCh1.Caption,1);
  Common.OpticInfo.CalAgingTime := StrToIntDef(edAging_Cal.Text,600);
  Common.OpticInfo.CalRetryCnt := StrToIntDef(edRty_Cal.Text,3);

end;


procedure TfrmMainter.LoadOptCsv(sFileName: string);
var
  sCurFile : string;
  sTemp    : string;
  dTemp    : Single;
  i        : Integer;
begin

  sCurFile := Common.Path.UserCal + cboModelType.Items[cboModelType.ItemIndex] + '\' + sFileName;
  if FileExists(sCurFile) then  begin
    try
      gridTarget.LoadFromCSV(sCurFile);

      for i := TDllCaSdk2.IDX_RED to  TDllCaSdk2.IDX_MAX do begin
        sTemp      := gridTarget.Cells[1,i+1];
        dTemp      := StrToFloatDef(sTemp,0.0);
        gridTarget.Cells[1,i+1] := Format('%0.4f',[dTemp]);

        sTemp      := gridTarget.Cells[2,i+1];
        dTemp      := StrToFloatDef(sTemp,0.0);
        gridTarget.Cells[2,i+1] := Format('%0.4f',[dTemp]);

        sTemp      := gridTarget.Cells[3,i+1];
        dTemp      := StrToFloatDef(sTemp,0.0);
        gridTarget.Cells[3,i+1] := Format('%0.1f',[dTemp]);
      end;
    except
    end;
  end;
end;





procedure TfrmMainter.ShowUsercalItems;
begin
  cboModelType.Clear;
  // Add Items To combo box of model type.
  AddItemsInCbo;
  if cboModelType.Items.Count > 0 then begin
    cboModelType.ItemIndex :=  Common.OpticInfo.CalModelType;
    AddCboCsvData;
    LoadOptIni(cboModelType.Items[cboModelType.ItemIndex]);
  end;
  if cboCalData.Items.Count > 0 then begin
    LoadOptCsv(cboCalData.Items[cboCalData.ItemIndex]);
  end;
end;


procedure TfrmMainter.FormCreate(Sender: TObject);
var
  nCh, i : integer;
  sTemp   : string;
begin
  cboChannelPg.Items.clear;
  cboScriptCh.Items.clear;
  cboSelectDoorUnlock.ItemIndex := 4;

  for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    sTemp := Format('%d',[nCh + 1]);
    cboChannelPg.Items.Add(sTemp);
    cboScriptCh.Items.Add(sTemp);
  end;
  cboChannelPg.Items.Add('ALL Channels');
  cboScriptCh.Items.Add('ALL Channels');

  cboChannelPg.ItemIndex := 0;
  cboScriptCh.ItemIndex := 0;
//  if UdpServer is TUdpServerVh then begin
//    UdpServer.OnRevDataForMaint := GetPgRevData;
//    UdpServer.IsMainter := True;
//  end;

    if pgcMainter.ActivePage = TabSheet1 then begin
      for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
        if Pg[nCh] = nil then Continue;

        Pg[nCh].IsMainter := True;
        Pg[nCh].OnTxMaintEventPG := GetPgTxData;
        Pg[nCh].OnRxMaintEventPG := GetPgRxData;
      end;
    end
    else begin
      for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
        if Pg[nCh] = nil then Continue;
        Pg[nCh].IsMainter := False;
        Pg[nCh].OnTxMaintEventPG := nil;
        Pg[nCh].OnRxMaintEventPG := nil;
      end;
    end;

  tabIoMap.TabVisible := True;

  pgcMainter.ActivePageIndex:= 0;

  SystemIpList;

  if DongaHandBcr <> nil then begin
    DongaHandBcr.OnRevBcrDataMaint := getBcrData;
  end;

  GetLocalIpList;
  m_bStopCa310Cal := False;
  chkUseTowerLamp.Checked:= ControlDio.UseTowerLamp;
  MakeDIOSignal;
  MakeTempPlateItems;

  ShowUsercalItems;   // Added by KTS 2022-08-09 오후 12:01:08
end;


procedure TfrmMainter.getBcrData(sScanData: string);
begin
  mmHandBcr.Lines.Add(sScanData);
end;

procedure TfrmMainter.GetLocalIpList;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe : PHostEnt;
  pptr : PaPInAddr;
  Buffer : array[0..63] of AnsiChar;
  i : Integer;
  WSAData : TWSAData;
  a : TStringList;
//  sRet : string;
begin

  WSAStartup(MakeWord(2,2),WSAData);
  a := TStringList.Create ;
  try
    a.Clear;
    lstLocalIp.Items.Clear;
    gethostname(Buffer, SizeOf(Buffer));
    phe := gethostbyname(buffer);
    if phe = nil then Exit;
    pptr := papinaddr(phe^.h_addr_list);
    i := 0;
    while pptr^[i] <> nil do begin
      a.Add(inet_ntoa(pptr^[i]^));
      Inc(i);
    end;
    WSACleanup;
    for i := 0 to Pred(a.Count) do begin
      lstLocalIp.Items.Add(a[i]);
    end;
  finally
    a.Free;
  end;
end;

procedure TfrmMainter.GetPgRevData(nPgNo, nLength: Integer; RevData: array of byte);
var
  sDebug, sTemp : string;
  i : Integer;
begin
  sTemp := '';
  for i := 0 to Pred(nLength) do sTemp := sTemp + Format('%0.2x ',[RevData[i]]);

  sDebug := FormatDateTime('[hh:mm:ss.zzz]',Now) + Format('Ch %d, Rev : ( Length : %d, Data (%s))',[nPgNo+1, nLength , sTemp ]);
  mmCommPg.Lines.Add(sDebug);
end;

function TfrmMainter.GetDioChannel: Integer;
var
  nCh : Integer;
begin
  nCh := 0;
  if rdoCh1.Checked then nCh := 0;
  if rdoCh2.Checked then nCh := 1;
  if rdoCh3.Checked then nCh := 2;
  Result := nCh;
end;

function TfrmMainter.GetProbeNum: Integer;
var
  nCh : Integer;
begin
  nCh := 0;
  if rdoProbe1.Checked then nCh := 0;
  if rdoProbe2.Checked then nCh := 1;
  if rdoProbe3.Checked then nCh := 2;
  if rdoProbe4.Checked then nCh := 3;
  if rdoProbe5.Checked then nCh := 4;
  if rdoProbe6.Checked then nCh := 5;
  if rdoProbe7.Checked then nCh := 6;
  if rdoProbe8.Checked then nCh := 7;
  if rdoProbe9.Checked then nCh := 8;
  Result := nCh;
end;

procedure TfrmMainter.gridTargetKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vkReturn then Key := vkTab;

end;


procedure TfrmMainter.IonizerReadData(bConnect: Boolean; sReadData: String);
begin
  //
  if bConnect then begin
    memoIonizer.Lines.Add(FormatDateTime('HH:NN:SS.ZZZ ', Now) + sReadData);
  end
  else begin
    memoIonizer.Lines.Add('Disconnect ' + sReadData);
  end;

end;

procedure TfrmMainter.MakeDIOSignal;
var
  i, nDiv, nMaxCnt,nInterval: Integer;
  nHeight, nLeft, nTop      : Integer;
  sTemp                     : string;
begin

  nMaxCnt := DefDio.MAX_IO_CNT-1;
  nHeight := 24;
  nInterval := 6;
  nDiv    := DefDio.MAX_IO_CNT div 2;
  // for In --------------------------------------------
  for i := 0 to nMaxCnt do begin
    if i < nDiv then  nLeft := 4
    else              nLeft := grpDioIn.Width div 2+ 4;

    if i in [0 , nDiv] then nTop := 20
    else                    nTop := pnlIn[i-1].Top + nHeight + nInterval;

    // Number.

    pnlIn[i] := TRzPanel.Create(Self);
    pnlIn[i].Parent := grpDioIn;
    pnlIn[i].Top          := nTop;
    pnlIn[i].Left         := nLeft;
    pnlIn[i].BevelWidth   := 1;
    pnlIn[i].FlatColor    := clBlack;
    pnlIn[i].BorderInner  := TframeStyleEx(fsNone);
    pnlIn[i].BorderOuter  := TframeStyleEx(fsFlat);
    pnlIn[i].Width        := nHeight;
    pnlIn[i].Height       := nHeight;
    pnlIn[i].Caption      := Format('%0.2d',[i]);//Common.DecToOct(i);
    pnlIn[i].Visible      := True;
    pnlIn[i].Font.Size      := 8;

    // Led.
    ledIn[i]              := ThhALed.Create(Self);
    ledIn[i].Parent       := grpDioIn;
    ledIn[i].Left         := pnlIn[i].Left + pnlIn[i].Width + 3;
    ledIn[i].Top          := nTop;
    ledIn[i].Height       := nHeight;
    ledIn[i].LEDStyle     := LEDSqLarge;
    ledIn[i].FalseColor   := clRed;
    ledIn[i].TrueColor    := clLime;
    ledIn[i].Blink        := False;
    ledIn[i].Visible      := True;
    ledIn[i].Value        := False;

    // Items.
    pnlDioIn[i] := TRzPanel.Create(Self);
    pnlDioIn[i].Parent        := grpDioIn;
    pnlDioIn[i].Left          := ledIn[i].Left + ledIn[i].Width + 3;
    pnlDioIn[i].BevelWidth    := 1;
    pnlDioIn[i].Top           := nTop;
    pnlDioIn[i].FlatColor     := clBlack;
    pnlDioIn[i].BorderInner   := TframeStyleEx(fsNone);
    pnlDioIn[i].BorderOuter   := TframeStyleEx(fsFlat);
    pnlDioIn[i].Width         := 180;
    pnlDioIn[i].Height        := pnlIn[i].Height;
    pnlDioIn[i].Visible       := True;
    pnlDioIn[i].Font.Name     := 'Tahoma';
    pnlDioIn[i].Font.Style    := [];
    pnlDioIn[i].Font.Size     := 8;
    sTemp := '';
    pnlDioIn[i].Caption := Trim(DefDio.asDioIn[i]);
  end;


  // for Out --------------------------------------------
  for i := 0 to nMaxCnt do begin
    if i < nDiv then  nLeft := 4
    else              nLeft := grpDioOut.Width div 2+ 4;

    if i in [0 , nDiv] then nTop := 20
    else                    nTop := pnlOut[i-1].Top + nHeight + nInterval;

    pnlOut[i] := TRzPanel.Create(Self);
    pnlOut[i].Parent := grpDioOut;
    pnlOut[i].Top          := nTop;
    pnlOut[i].Left         := nLeft;
    pnlOut[i].BevelWidth   := 1;
    pnlOut[i].FlatColor    := clBlack;
    pnlOut[i].BorderInner  := TframeStyleEx(fsNone);
    pnlOut[i].BorderOuter  := TframeStyleEx(fsFlat);
    pnlOut[i].Width        := nHeight;
    pnlOut[i].Height       := nHeight;
    pnlOut[i].Caption      := Format('%0.2d',[i]);//Common.DecToOct(i);
    pnlOut[i].Visible      := True;
    pnlOut[i].Font.Size      := 8;

    // Led.
    ledOut[i]              := ThhALed.Create(Self);
    ledOut[i].Parent       := grpDioOut;
    ledOut[i].Left         := pnlOut[i].Left + pnlOut[i].Width + 3;
    ledOut[i].Top          := nTop;
    ledOut[i].Height       := nHeight;
    ledOut[i].LEDStyle     := LEDSqLarge;
    ledOut[i].FalseColor   := clRed;
    ledOut[i].TrueColor    := clLime;
    ledOut[i].Blink        := False;
    ledOut[i].Visible      := True;
    ledOut[i].Value        := False;

    // Items.
    pnlDioOut[i] := TRzPanel.Create(Self);
    pnlDioOut[i].Parent        := grpDioOut;
    pnlDioOut[i].Left          := ledOut[i].Left + ledOut[i].Width + 3;
    pnlDioOut[i].BevelWidth    := 1;
    pnlDioOut[i].Top           := nTop;
    pnlDioOut[i].FlatColor     := clBlack;
    pnlDioOut[i].BorderInner   := TframeStyleEx(fsNone);
    pnlDioOut[i].BorderOuter   := TframeStyleEx(fsFlat);
    pnlDioOut[i].Width         := 160;
    pnlDioOut[i].Height        := pnlOut[i].Height;
    pnlDioOut[i].Visible       := True;
    pnlDioOut[i].Font.Name     := 'Tahoma';
    pnlDioOut[i].Font.Style    := [];
    pnlDioOut[i].Font.Size     := 8;
    sTemp := '';
    pnlDioOut[i].Caption := DefDio.asDioOut[i];

    btnOutSig[i]              := TRzBitBtn.Create(Self);
    btnOutSig[i].Parent       := grpDioOut;
    btnOutSig[i].Left         := pnlDioOut[i].Left + pnlDioOut[i].Width + 3;
    btnOutSig[i].Top          := pnlOut[i].Top;
    btnOutSig[i].Width        := 30;
    btnOutSig[i].Height       := pnlOut[i].Height;
    btnOutSig[i].Visible      := True;
    btnOutSig[i].Cursor       := crHandPoint;
    btnOutSig[i].Font.Name     := 'Tahoma';
    btnOutSig[i].Font.Style    := [];
    btnOutSig[i].Font.Size     := 8;
    btnOutSig[i].Caption       := 'On';
    btnOutSig[i].Tag           := i;
    btnOutSig[i].OnClick       := OnEvtOutBtn;
  end;

  // DISPLAY ...
  DisplayDio(True);
  DisplayDio(False);

end;


procedure TfrmMainter.MakeTempPlateItems;
var
  i, j, nLeft, nWidth, nTop, nTopSub : Integer;
  sItem : string;
begin
  nWidth := grpControlTempPlates.Width div 4;  nTop := 0;
  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    nLeft := nWidth*i;
    pnlGroupPlates[i] := TPanel.Create(Self);
    pnlGroupPlates[i].Parent := grpControlTempPlates;
    pnlGroupPlates[i].Top          := nTop;
    pnlGroupPlates[i].Left         := nLeft;
    pnlGroupPlates[i].Height       := grpControlTempPlates.Height - nTop - 10;
    pnlGroupPlates[i].Visible      := True;
    pnlGroupPlates[i].BevelOuter   := bvNone;
    pnlGroupPlates[i].Width        := nWidth;

    case i of
      0 : sItem := 'SYSTEM'
      else sItem := Format('PLATE _ %d',[i]);
    end;
    pnlTitle[i] := TPanel.Create(Self);
    pnlTitle[i].Parent := pnlGroupPlates[i];
    pnlTitle[i].Top          := 20;
    pnlTitle[i].Left         := 0;
    pnlTitle[i].Width        := nWidth;
    pnlTitle[i].Height       := 30;
    pnlTitle[i].Caption      := sItem;
    pnlTitle[i].Visible      := True;
    pnlTitle[i].BevelOuter   := bvNone;
    pnlTitle[i].BevelKind    := bkFlat;

    pnlReady[i] := TPanel.Create(Self);
    pnlReady[i].Parent := pnlGroupPlates[i];
    pnlReady[i].ParentColor  := False;
    pnlReady[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlReady[i].Left         := 10 ;
    pnlReady[i].Width        := (nWidth div 3) - 20;
    pnlReady[i].Height       := 20;
    pnlReady[i].Caption      := 'Ready';
    pnlReady[i].Visible      := True;
    pnlReady[i].BevelKind    := bkFlat;
    pnlReady[i].BevelOuter   := bvNone;
    pnlReady[i].StyleElements     := [];

    pnlRun[i] := TPanel.Create(Self);
    pnlRun[i].Parent := pnlGroupPlates[i];
    pnlRun[i].ParentColor  := False;
    pnlRun[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlRun[i].Left         := (nWidth div 3) + 10 ;
    pnlRun[i].Width        := (nWidth div 3) - 20;
    pnlRun[i].Height       := 20;
    pnlRun[i].Caption      := 'RUN';
    pnlRun[i].Visible      := True;
    pnlRun[i].BevelKind    := bkFlat;
    pnlRun[i].BevelOuter   := bvNone;
    pnlRun[i].StyleElements     := [];

    pnlAlarm[i] := TPanel.Create(Self);
    pnlAlarm[i].Parent := pnlGroupPlates[i];
    pnlAlarm[i].ParentColor  := False;
    pnlAlarm[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlAlarm[i].Left         := (nWidth div 3)*2+10 ;
    pnlAlarm[i].Width        := (nWidth div 3) - 20;
    pnlAlarm[i].Height       := 20;
    pnlAlarm[i].Caption      := 'ALARM';
    pnlAlarm[i].Visible      := True;
    pnlAlarm[i].BevelKind    := bkFlat;
    pnlAlarm[i].BevelOuter   := bvNone;
    pnlAlarm[i].StyleElements     := [];

    if i <> 0 then begin
      pnlHeating[i] := TPanel.Create(Self);
      pnlHeating[i].Parent := pnlGroupPlates[i];
      pnlHeating[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlHeating[i].Left         := 10 ;
      pnlHeating[i].Width        := (nWidth div 3) - 20;
      pnlHeating[i].Height       := 20;
      pnlHeating[i].Caption      := 'Heating';
      pnlHeating[i].Visible      := True;
      pnlHeating[i].BevelKind    := bkFlat;
      pnlHeating[i].BevelOuter   := bvNone;
      pnlHeating[i].StyleElements     := [];

      pnlCooling[i] := TPanel.Create(Self);
      pnlCooling[i].Parent := pnlGroupPlates[i];
      pnlCooling[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlCooling[i].Left         := (nWidth div 3) + 10 ;
      pnlCooling[i].Width        := (nWidth div 3) - 20;
      pnlCooling[i].Height       := 20;
      pnlCooling[i].Caption      := 'Cooling';
      pnlCooling[i].Visible      := True;
      pnlCooling[i].BevelKind    := bkFlat;
      pnlCooling[i].BevelOuter   := bvNone;
      pnlCooling[i].StyleElements   := [];

      pnlSv[i] := TPanel.Create(Self);
      pnlSv[i].Parent := pnlGroupPlates[i];
      pnlSv[i].Top          := pnlHeating[i].Height + pnlHeating[i].Top + 10;
      pnlSv[i].Left         := 10 ;
      pnlSv[i].Width        := 20;
      pnlSv[i].Height       := 20;
      pnlSv[i].Caption      := 'SV';
      pnlSv[i].Visible      := True;
      pnlSv[i].BevelKind    := bkNone;
      pnlSv[i].BevelOuter   := bvNone;
      pnlSv[i].StyleElements     := [];

      pnlPv[i] := TPanel.Create(Self);
      pnlPv[i].Parent := pnlGroupPlates[i];
      pnlPv[i].Top          := pnlSv[i].Height + pnlSv[i].Top + 10;
      pnlPv[i].Left         := 10 ;
      pnlPv[i].Width        := 20;
      pnlPv[i].Height       := 20;
      pnlPv[i].Caption      := 'PV';
      pnlPv[i].Visible      := True;
      pnlPv[i].BevelKind    := bkNone;
      pnlPv[i].BevelOuter   := bvNone;
      pnlPv[i].StyleElements     := [];

      pnlMv[i] := TPanel.Create(Self);
      pnlMv[i].Parent := pnlGroupPlates[i];
      pnlMv[i].Top          := pnlPv[i].Height + pnlPv[i].Top + 10;
      pnlMv[i].Left         := 10 ;
      pnlMv[i].Width        := 20;
      pnlMv[i].Height       := 20;
      pnlMv[i].Caption      := 'MV';
      pnlMv[i].Visible      := True;
      pnlMv[i].BevelKind    := bkNone;
      pnlMv[i].BevelOuter   := bvNone;
      pnlMv[i].StyleElements     := [];

      edtSv[i]         := TRzEdit.Create(Self);
      edtSv[i].Parent  := pnlGroupPlates[i];
      edtSv[i].Width   := 80;
      edtSv[i].Height  := 22;
      edtSv[i].Top     := pnlSv[i].top;
      edtSv[i].Left    := pnlSv[i].Left + pnlSv[i].Width + 10;

      edtPv[i]         := TRzEdit.Create(Self);
      edtPv[i].Parent  := pnlGroupPlates[i];
      edtPv[i].Width   := 80;
      edtPv[i].Height  := 22;
      edtPv[i].Top     := pnlPv[i].top;
      edtPv[i].Left    := pnlPv[i].Left + pnlPv[i].Width + 10;

      edtMv[i]         := TRzEdit.Create(Self);
      edtMv[i].Parent  := pnlGroupPlates[i];
      edtMv[i].Width   := 80;
      edtMv[i].Height  := 22;
      edtMv[i].Top     := pnlMv[i].top;
      edtMv[i].Left    := pnlMv[i].Left + pnlMv[i].Width + 10;

      cboTempPlate[i]         := TRzComboBox.Create(Self);
      cboTempPlate[i].Parent  := pnlGroupPlates[i];
      cboTempPlate[i].Width   := 100;
      cboTempPlate[i].Height  := 22;
      cboTempPlate[i].Left    := edtSv[i].Width+edtSv[i].Left   + 2;
      cboTempPlate[i].Top     := edtSv[i].Top;
      cboTempPlate[i].Style   := csDropDownList;
      cboTempPlate[i].DropDownCount := 10;
      cboTempPlate[i].Tag     := i;
      cboTempPlate[i].Items.Clear;
      cboTempPlate[i].Items.Add('5');
      cboTempPlate[i].Items.Add('10');
      cboTempPlate[i].Items.Add('25');
      cboTempPlate[i].Items.Add('40');
      cboTempPlate[i].Items.Add('50');
      cboTempPlate[i].ItemIndex := 2;
      cboTempPlate[i].OnClick := OnEvtTempPateBtn;
    end
    else begin
      pnlChillerReady := TPanel.Create(Self);
      pnlChillerReady.Parent := pnlGroupPlates[i];
      pnlChillerReady.Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlChillerReady.Left         := (nWidth div 2) ;
      pnlChillerReady.Width        := (nWidth div 2) - 20;
      pnlChillerReady.Height       := 20;
      pnlChillerReady.Caption      := 'Chiller Ready';
      pnlChillerReady.Visible      := True;
      pnlChillerReady.BevelOuter   := bvNone;
      pnlChillerReady.BevelKind    := bkFlat;

      pnlChillerRun := TPanel.Create(Self);
      pnlChillerRun.Parent := pnlGroupPlates[i];
      pnlChillerRun.ParentColor  := False;
      pnlChillerRun.Top          := pnlChillerReady.Height + pnlChillerReady.Top + 10;
      pnlChillerRun.Left         := pnlChillerReady.Left ;
      pnlChillerRun.Width        := (nWidth div 2) - 20;
      pnlChillerRun.Height       := 20;
      pnlChillerRun.Caption      := 'Chiller RUN';
      pnlChillerRun.Visible      := True;
      pnlChillerRun.BevelKind    := bkFlat;
      pnlChillerRun.BevelOuter   := bvNone;
      pnlChillerRun.StyleElements     := [];

      pnlChillerAlarm := TPanel.Create(Self);
      pnlChillerAlarm.Parent := pnlGroupPlates[i];
      pnlChillerAlarm.ParentColor  := False;
      pnlChillerAlarm.Top          := pnlChillerRun.Height + pnlChillerRun.Top + 10;
      pnlChillerAlarm.Left         := pnlChillerReady.Left ;
      pnlChillerAlarm.Width        := (nWidth div 2) - 20;
      pnlChillerAlarm.Height       := 20;
      pnlChillerAlarm.Caption      := 'Chiller Alarm';
      pnlChillerAlarm.Visible      := True;
      pnlChillerAlarm.BevelKind    := bkFlat;
      pnlChillerAlarm.BevelOuter   := bvNone;
      pnlChillerAlarm.StyleElements     := [];

      pnlChillerOperated := TPanel.Create(Self);
      pnlChillerOperated.Parent := pnlGroupPlates[i];
      pnlChillerOperated.ParentColor  := False;
      pnlChillerOperated.Top          := pnlChillerAlarm.Height + pnlChillerAlarm.Top + 10;
      pnlChillerOperated.Left         := pnlChillerReady.Left ;
      pnlChillerOperated.Width        := (nWidth div 2) - 20;
      pnlChillerOperated.Height       := 20;
      pnlChillerOperated.Caption      := 'Chiller Operated';
      pnlChillerOperated.Visible      := True;
      pnlChillerOperated.BevelKind    := bkFlat;
      pnlChillerOperated.BevelOuter   := bvNone;
      pnlChillerOperated.StyleElements     := [];


      pnlSysStateEms := TPanel.Create(Self);
      pnlSysStateEms.Parent := pnlGroupPlates[i];
      pnlSysStateEms.Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlSysStateEms.Left         := 10 ;
      pnlSysStateEms.Width        := (nWidth div 2) - 20;
      pnlSysStateEms.Height       := 20;
      pnlSysStateEms.Caption      := 'EMS State';
      pnlSysStateEms.Visible      := True;
      pnlSysStateEms.BevelOuter   := bvNone;
      pnlSysStateEms.BevelKind    := bkFlat;

      pnlSysStateMc := TPanel.Create(Self);
      pnlSysStateMc.Parent := pnlGroupPlates[i];
      pnlSysStateMc.ParentColor  := False;
      pnlSysStateMc.Top          := pnlSysStateEms.Height + pnlSysStateEms.Top + 10;
      pnlSysStateMc.Left         := 10 ;
      pnlSysStateMc.Width        := (nWidth div 2) - 20;
      pnlSysStateMc.Height       := 20;
      pnlSysStateMc.Caption      := 'MC State';
      pnlSysStateMc.Visible      := True;
      pnlSysStateMc.BevelKind    := bkFlat;
      pnlSysStateMc.BevelOuter   := bvNone;
      pnlSysStateMc.StyleElements     := [];

      pnlSysStatePwr := TPanel.Create(Self);
      pnlSysStatePwr.Parent := pnlGroupPlates[i];
      pnlSysStatePwr.ParentColor  := False;
      pnlSysStatePwr.Top          := pnlSysStateMc.Height + pnlSysStateMc.Top + 10;
      pnlSysStatePwr.Left         := pnlSysStateEms.Left ;
      pnlSysStatePwr.Width        := (nWidth div 2) - 20;
      pnlSysStatePwr.Height       := 20;
      pnlSysStatePwr.Caption      := 'POWER State';
      pnlSysStatePwr.Visible      := True;
      pnlSysStatePwr.BevelKind    := bkFlat;
      pnlSysStatePwr.BevelOuter   := bvNone;
      pnlSysStatePwr.StyleElements     := [];

      pnlSysStateReset := TPanel.Create(Self);
      pnlSysStateReset.Parent := pnlGroupPlates[i];
      pnlSysStateReset.ParentColor  := False;
      pnlSysStateReset.Top          := pnlSysStatePwr.Height + pnlSysStatePwr.Top + 10;
      pnlSysStateReset.Left         := pnlSysStateEms.Left ;
      pnlSysStateReset.Width        := (nWidth div 2) - 20;
      pnlSysStateReset.Height       := 20;
      pnlSysStateReset.Caption      := 'RESET State';
      pnlSysStateReset.Visible      := True;
      pnlSysStateReset.BevelKind    := bkFlat;
      pnlSysStateReset.BevelOuter   := bvNone;
      pnlSysStateReset.StyleElements     := [];

      pnlSv[i] := TPanel.Create(Self);
      pnlSv[i].Parent := pnlGroupPlates[i];
      pnlSv[i].Top          := pnlSysStateReset.Height + pnlSysStateReset.Top + 10;
      pnlSv[i].Left         := 10 ;
      pnlSv[i].Width        := 80;
      pnlSv[i].Height       := 20;
      pnlSv[i].Caption      := 'Chiller SV';
      pnlSv[i].Visible      := True;
      pnlSv[i].BevelKind    := bkNone;
      pnlSv[i].BevelOuter   := bvNone;
      pnlSv[i].StyleElements     := [];

      edtSv[i]         := TRzEdit.Create(Self);
      edtSv[i].Parent  := pnlGroupPlates[i];
      edtSv[i].Width   := 80;
      edtSv[i].Height  := 22;
      edtSv[i].Top     := pnlSv[i].top;
      edtSv[i].Left    := pnlSv[i].Left + pnlSv[i].Width + 10;

      cboTempPlate[i]         := TRzComboBox.Create(Self);
      cboTempPlate[i].Parent  := pnlGroupPlates[i];
      cboTempPlate[i].Width   := 100;
      cboTempPlate[i].Height  := 22;
      cboTempPlate[i].Left    := edtSv[i].Width+edtSv[i].Left   + 2;
      cboTempPlate[i].Top     := edtSv[i].Top;
      cboTempPlate[i].Style   := csDropDownList;
      cboTempPlate[i].DropDownCount := 10;
      cboTempPlate[i].Tag     := i;
      cboTempPlate[i].Items.Clear;
      for j := 15 to 22 do cboTempPlate[i].Items.Add(j.ToString);
      cboTempPlate[i].ItemIndex := 2;

      pnlPv[i] := TPanel.Create(Self);
      pnlPv[i].Parent := pnlGroupPlates[i];
      pnlPv[i].Top          := pnlSv[i].Height + pnlSv[i].Top + 10;
      pnlPv[i].Left         := 10 ;
      pnlPv[i].Width        := 80;
      pnlPv[i].Height       := 20;
      pnlPv[i].Caption      := 'Chiller PV';
      pnlPv[i].Visible      := True;
      pnlPv[i].BevelKind    := bkNone;
      pnlPv[i].BevelOuter   := bvNone;
      pnlPv[i].StyleElements     := [];

      edtPv[i]         := TRzEdit.Create(Self);
      edtPv[i].Parent  := pnlGroupPlates[i];
      edtPv[i].Width   := 80;
      edtPv[i].Height  := 22;
      edtPv[i].Top     := pnlPv[i].top;
      edtPv[i].Left    := pnlPv[i].Left + pnlPv[i].Width + 10;

      btnSvSet[i]              := TRzBitBtn.Create(Self);
      btnSvSet[i].Parent       := pnlGroupPlates[i];
      btnSvSet[i].Left         := cboTempPlate[i].Left + cboTempPlate[i].Width + 2;
      btnSvSet[i].Top          := cboTempPlate[i].Top;
      btnSvSet[i].Width        := 40;
      btnSvSet[i].Height       := 22;
      btnSvSet[i].Visible      := True;
      btnSvSet[i].Cursor       := crHandPoint;
      btnSvSet[i].Font.Name     := 'Tahoma';
      btnSvSet[i].Font.Style    := [];
      btnSvSet[i].Font.Size     := 10;
      btnSvSet[i].Caption       := 'Set';
      btnSvSet[i].Tag           := i+30;
      btnSvSet[i].OnClick       := OnEvtTempPateBtn;
    end;


    btnRun[i]              := TRzBitBtn.Create(Self);
    btnRun[i].Parent       := pnlGroupPlates[i];
    btnRun[i].Left         := 10;
    btnRun[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnRun[i].Width        := (nWidth div 3) - 20;
    btnRun[i].Height       := 30;
    btnRun[i].Visible      := True;
    btnRun[i].Cursor       := crHandPoint;
    btnRun[i].Font.Name     := 'Tahoma';
    btnRun[i].Font.Style    := [];
    btnRun[i].Font.Size     := 10;
    btnRun[i].Caption       := 'Run';
    btnRun[i].Tag           := i;
    btnRun[i].OnClick       := OnEvtTempPateBtn;

    btnStop[i]              := TRzBitBtn.Create(Self);
    btnStop[i].Parent       := pnlGroupPlates[i];
    btnStop[i].Left         := (nWidth div 3) + 10 ;
    btnStop[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnStop[i].Width        := (nWidth div 3) - 20;
    btnStop[i].Height       := 30;
    btnStop[i].Visible      := True;
    btnStop[i].Cursor       := crHandPoint;
    btnStop[i].Font.Name     := 'Tahoma';
    btnStop[i].Font.Style    := [];
    btnStop[i].Font.Size     := 10;
    btnStop[i].Caption       := 'STOP';
    btnStop[i].Tag           := i+10;
    btnStop[i].OnClick       := OnEvtTempPateBtn;

    btnReset[i]              := TRzBitBtn.Create(Self);
    btnReset[i].Parent       := pnlGroupPlates[i];
    btnReset[i].Left         := (nWidth div 3)*2 + 10 ;
    btnReset[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnReset[i].Width        := (nWidth div 3) - 20;
    btnReset[i].Height       := 30;
    btnReset[i].Visible      := True;
    btnReset[i].Cursor       := crHandPoint;
    btnReset[i].Font.Name     := 'Tahoma';
    btnReset[i].Font.Style    := [];
    btnReset[i].Font.Size     := 10;
    btnReset[i].Caption       := 'Reset';
    btnReset[i].Tag           := i+20;
    btnReset[i].OnClick       := OnEvtTempPateBtn;

    nTopSub := btnRun[i].Height + btnRun[i].Top + 20;
    for j := 0 to 7 do begin
      pnlTempPlateAlarm[i,j] := TPanel.Create(Self);
      pnlTempPlateAlarm[i,j].Parent := pnlGroupPlates[i];
      pnlTempPlateAlarm[i,j].Alignment    := taLeftJustify;
      pnlTempPlateAlarm[i,j].Top          := nTopSub + 22*j;
      pnlTempPlateAlarm[i,j].Left         := btnRun[i].Left ;
      pnlTempPlateAlarm[i,j].Width        := 200;
      pnlTempPlateAlarm[i,j].Height       := 20;
      pnlTempPlateAlarm[i,j].Caption      := '';
      pnlTempPlateAlarm[i,j].Visible      := True;
      pnlTempPlateAlarm[i,j].BevelKind    := bkNone;
      pnlTempPlateAlarm[i,j].BevelOuter   := bvNone;
      pnlTempPlateAlarm[i,j].StyleElements     := [];
    end;
    if i = CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM then begin
      for j := 0 to 9 do begin
        pnlChillerAlarms[j] := TPanel.Create(Self);
        pnlChillerAlarms[j].Parent := pnlGroupPlates[i];
        pnlChillerAlarms[j].Alignment    := taLeftJustify;
        pnlChillerAlarms[j].Top          := nTopSub + 22*j;
        pnlChillerAlarms[j].Left         := btnStop[i].Left + 20;
        pnlChillerAlarms[j].Width        := 200;
        pnlChillerAlarms[j].Height       := 20;
        pnlChillerAlarms[j].Caption      := '';
        pnlChillerAlarms[j].Visible      := True;
        pnlChillerAlarms[j].BevelKind    := bkNone;
        pnlChillerAlarms[j].BevelOuter   := bvNone;
        pnlChillerAlarms[j].StyleElements     := [];
      end;
    end;
  end;

  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    if i <> 0 then begin
      for j := 0 to 7 do begin
        case j of
          0 : pnlTempPlateAlarm[i,j].Caption := '1 Sensor Line Open Alarm';
          1 : pnlTempPlateAlarm[i,j].Caption := '2 Sensor Line Open Alarm';
          2 : pnlTempPlateAlarm[i,j].Caption := '3 Sensor Line Open Alarm';
          3 : pnlTempPlateAlarm[i,j].Caption := '4 Sensor Line Open Alarm';
          4 : pnlTempPlateAlarm[i,j].Caption := 'OT Alarm';
          5 : pnlTempPlateAlarm[i,j].Caption := 'Over heating Alarm';
          6 : pnlTempPlateAlarm[i,j].Caption := 'Over Cooling Alarm';
          7 : pnlTempPlateAlarm[i,j].Caption := 'Temperature range Alarm';
        end;
      end;
    end
    else begin
      for j := 0 to 7 do begin
        case j of
          0 : pnlTempPlateAlarm[i,j].Caption := 'EMS Alarm';
          1 : pnlTempPlateAlarm[i,j].Caption := 'Smoke Alarm';
          2 : pnlTempPlateAlarm[i,j].Caption := 'Power Lost Alarm';
          3 : pnlTempPlateAlarm[i,j].Caption := 'Chiller Alarm';
          4 : pnlTempPlateAlarm[i,j].Caption := 'Chiller CommError';
          5 : pnlTempPlateAlarm[i,j].Caption := '';
          6 : pnlTempPlateAlarm[i,j].Caption := '';
          7 : pnlTempPlateAlarm[i,j].Caption := '';
        end;
      end;
      for j := 0 to 9 do begin
        case j of
          0 : pnlChillerAlarms[j].Caption := 'Chiller Phase Alarm';
          1 : pnlChillerAlarms[j].Caption := 'Chiller Heater Alarm';
          2 : pnlChillerAlarms[j].Caption := 'Chiller Sol V/V Alarm';
          3 : pnlChillerAlarms[j].Caption := 'Chiller Temp Sensor Alarm';
          4 : pnlChillerAlarms[j].Caption := 'Chiller CommError';
          5 : pnlChillerAlarms[j].Caption := 'Chiller Flow Alarm';
          6 : pnlChillerAlarms[j].Caption := 'Chiller Temperature Alarm';
          7 : pnlChillerAlarms[j].Caption := 'Chiller Pressure Alarm';
          8 : pnlChillerAlarms[j].Caption := 'Chiller Low Level Alarm';
          9 : pnlChillerAlarms[j].Caption := 'Chiller Low Temperature Alarm';
        end;
      end;
    end;
  end;
end;

procedure TfrmMainter.OnEvtOutBtn(Sender: TObject);
var
  nSig : Integer;
  bVal : boolean;
begin
  nSig := TRzBitBtn(Sender).Tag;
  bVal := ledOut[TRzBitBtn(Sender).Tag].Value;
  // Probe가 옆으로 움직일때 Up 상태가 아니면 멈추자.
  if nSig in [DefDio.OUT_X_POSITION_1, DefDio.OUT_X_POSITION_2,DefDio.OUT_X_POSITION_3,DefDio.OUT_X_POSITION_4] then begin
    if not bVal then begin
      if not ((not ControlDio.ReadInSig(DefDio.IN_Z_UP_SEN)) and ControlDio.ReadInSig(DefDio.IN_Z_DOWN_SEN)) then begin
        Exit;
      end;
    end;
  end;

  ControlDio.WriteDioSig(nSig,bVal);
end;

procedure TfrmMainter.OnEvtTempPateBtn(Sender: TObject);
var
  nVal, nDiv, nMod : Integer;
  nChillerSv : Integer;
begin
  if CommTempPlate = nil then Exit;

  nVal := TRzBitBtn(Sender).Tag;
  nDiv := nVal div 10; // 0 : Run, 1 : strop, 2 : Reset.  3 : Chiller SV
  nMod := nVal mod 10; // 0 : system, 1~3 : plates.

  case nMod of
    0 : begin // system.
      CommTempPlate.SetSystemStatus(nDiv + 1);
      if nDiv = 3 then begin
        // 15 ~ 22
        nChillerSv := (cboTempPlate[nMod].ItemIndex + 15) * 10;
        CommTempPlate.SetChillerSv(nChillerSv);
      end;
    end
    else begin // plates.
      CommTempPlate.SetPlateStatus(nMod,nDiv + 1);
      // Run일때만 동작 시키자.
      if nDiv = 0 then begin
        case cboTempPlate[nMod].ItemIndex of
          0 : nVal := 50;
          1 : nVal := 100;
          2 : nVal := 250;
          3 : nVal := 400;
          4 : nVal := 500;
        end;
        CommTempPlate.SetPlateSV(nMod,nVal);
      end;
    end;
  end;
end;

procedure TfrmMainter.SystemIpList;
begin
  lstIpInformation.Clear;

  lstIpInformation.Add('169.254.199.10  : GPC (PG)');
  lstIpInformation.Add('169.254.199.11  : PG1        ');
  lstIpInformation.Add('169.254.199.12  : PG2        ');
  lstIpInformation.Add('169.254.199.13  : PG3        ');
  lstIpInformation.Add('');
  lstIpInformation.Add('192.168.0.11    : GPC (DIO)');
  lstIpInformation.Add('192.168.0.99    : DIO        ');
end;

procedure TfrmMainter.RzBitBtn11Click(Sender: TObject);
var
  frmWarringMsg : TfrmDoorOpenAlarmMsg;
begin
  try
    frmWarringMsg := TfrmDoorOpenAlarmMsg.Create(Self);
    frmWarringMsg.btnClose.Visible := True;
//    frmWarringMsg := TfrmNgMsg.Create(Self);
//    frmWarringMsg.Caption := 'Warning Message';
//    frmWarringMsg.lblShow.Font.Size := 40;
//    frmWarringMsg.lblShow.Caption := 'Prohibit operation during work / Cấm thao tác trong quá trình làm việc / 작업중 조작 금지';
    frmWarringMsg.ShowModal;
  finally
    frmWarringMsg.Free;
    frmWarringMsg := nil;
  end;
end;





procedure TfrmMainter.RzBitBtn19Click(Sender: TObject);
var
  nCh : Integer;
begin
  nCh := GetProbeNum-1;
  PowerOffSeq(nCh);
end;

procedure TfrmMainter.RzBitBtn1Click(Sender: TObject);
begin
  mmCommPg.Clear;
  mmHandBcr.Clear;
end;
procedure TfrmMainter.btnCalStProbeClick(Sender: TObject);
var
  nCH : Integer;
begin
  if rdoProbe1.Checked then nCH := 0
  else if rdoProbe2.Checked then nCH := 1
  else if rdoProbe3.Checked then nCH := 2;
  if nCH > DefCommon.MAX_JIG_CH  then Exit;
  ThreadTask2(procedure begin
    ControlDio.MovingProbe(nCH,False);
  end, grpCa410CalSet);
end;

procedure TfrmMainter.btnCal0Click(Sender: TObject);
var
  nProbeNum, nStage : Integer;
  i: Integer;
  sMsg : string;
  idx : Integer;
  sSerial : array of AnsiChar;
begin
  sMsg := '(Are you sure you want to '+'0-CAL ?)';
  if MessageDlg(sMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    nProbeNum := GetProbeNum;
    try
      DllCaSdk2.set_CalZero(nProbeNum);

    except
      on E: Exception do begin
        mmoAutoCalLog.Lines.Add(E.Message);
      end;
    end;
  end;
end;

procedure TfrmMainter.btnCalEdProbeClick(Sender: TObject);
begin
  ControlDio.ProbeUpDown(True);
end;

procedure TfrmMainter.RzBitBtn20Click(Sender: TObject);
var
  nCh : Integer;
begin
  nCh := GetProbeNum-1;
  PowerOnSeq(nCh);
end;



procedure TfrmMainter.RzBitBtn2Click(Sender: TObject);
begin
  if not (ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FR) and ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FL))  then Exit;
  ThreadTask2(procedure begin
    ControlDio.MovingProbe(GetDioChannel,True);
  end, grpCa410CalSet);
end;

procedure TfrmMainter.btnUnlockDoorsClick(Sender: TObject);
var
  nIdx : Integer;
  bRet : boolean;
begin
  nIdx := cboSelectDoorUnlock.ItemIndex;
  if nIdx < 0 then Exit;
  if nIdx < 4 then begin
    bRet := not ledOut[DefDio.OUT_DOOR_UNLOCK_FR+nIdx].Value;
  end
  else begin
    bRet := not ledOut[DefDio.OUT_DOOR_UNLOCK_FR].Value;
  end;
  if bRet then btnUnlockDoors.Caption := 'Lock door'
  else         btnUnlockDoors.Caption := 'Unlock door';

  ControlDio.UnlockDoorOpen(nIdx,bRet)
end;

procedure TfrmMainter.btnUnlockBottomDoorsClick(Sender: TObject);
begin
//  ControlDio.UnlockDoorOpen(DefDio.BOTTOM_CH,true);
end;

procedure TfrmMainter.btnUnlockTopDoorsClick(Sender: TObject);
begin
//  ControlDio.UnlockDoorOpen(DefDio.TOP_CH,true);
end;

procedure TfrmMainter.btnMemChInfoClick(Sender: TObject);
var
  nCh, i , nMemCh: Integer;
  rx, ry, rLv : Double;
  gx, gy, gLv : Double;
  bx, by, bLv : Double;
  wx, wy, wLv : Double;
  nErr : Integer;
  sDebug : string;
begin
  nCh := cboScriptCh.ItemIndex;
  nMemCh := 0;
  // Get Current Memory Channel
  nErr := DllCaSdk2.GetMemCh(nCh,nMemCh);
  if nErr <> 0 then begin
    sDebug := Format('CaSDK Get Mem Ch - Error Code is %d',[nErr]);
    mmoAutoCalLog.Lines.Add(sDebug);
    Exit;
  end;
  sDebug := Format('Current Mem Channel is %d',[nMemCh]);
  mmoAutoCalLog.Lines.Add(sDebug);

  // Get Information.
//  nErr := fGetMemChData(nCh,nMemCh, rx, ry, rLv, gx, gy, gLv , bx, by, bLv , wx, wy, wLv);

  nErr := DllCaSdk2.GetMemInfo(nCh,nMemCh, rLv, rx, ry, gLv ,gx, gy, bLv , bx, by , wLv ,  wx, wy);
  if nErr <> 0 then begin
    sDebug := Format('CaSDK Mem Ch Data - Error Code is %d',[nErr]);
    mmoAutoCalLog.Lines.Add(sDebug);
    Exit;
  end;
  sDebug := Format('Saved Target Data R : x(%0.4f), y(%0.4f), lv(%0.4f) ',[rx, ry, rLv]);
  mmoAutoCalLog.Lines.Add(sDebug);
  sDebug := Format('Saved Target Data G : x(%0.4f), y(%0.4f), lv(%0.4f) ',[gx, gy, gLv]);
  mmoAutoCalLog.Lines.Add(sDebug);
  sDebug := Format('Saved Target Data B : x(%0.4f), y(%0.4f), lv(%0.4f) ',[bx, by, bLv]);
  mmoAutoCalLog.Lines.Add(sDebug);
  sDebug := Format('Saved Target Data W : x(%0.4f), y(%0.4f), lv(%0.4f) ',[wx, wy, wLv]);
  mmoAutoCalLog.Lines.Add(sDebug);

end;

procedure TfrmMainter.btnProbeDownClick(Sender: TObject);
begin
  ControlDio.ProbeUpDown(False);
end;

procedure TfrmMainter.btnProbeMoveClick(Sender: TObject);
begin
  if not (ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FR) and ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FL))  then Exit;
  ThreadTask2(procedure begin
    ControlDio.MovingProbe(GetDioChannel,False);
  end, grpControlProbe);
end;

procedure TfrmMainter.btnProbeUpClick(Sender: TObject);
begin
  ControlDio.ProbeUpDown(True);
end;

procedure TfrmMainter.btnAutoCalClick(Sender: TObject);
var
  bRet : Boolean;
  i : Integer;
  sDebug,sTemp: string;
  thAutoCal : TThread;
  nProbeNum, nStage : Integer;

  GetxyLv : TLvXY;
  GetAllxy, GetLimitxy: TAllLvXy;
  nCh : Integer;
begin
  nCh := GetProbeNum;
  if cboCalData.ItemIndex < 0 then Exit;
  if cboModelType.ItemIndex < 0 then Exit;
  ClearCalResult;
  mmoAutoCalLog.Lines.Clear;
  SaveOptCsv(cboCalData.Items[cboCalData.ItemIndex]);
  Common.SaveOpticInfo(cboModelType.ItemIndex);
  m_bStopCa310Cal := False;
  bRet := True;
  sDebug := '';
  pnlCalLog.Caption := '';
  for i := TDllCaSdk2.IDX_RED to  TDllCaSdk2.IDX_MAX do begin
    sTemp      := gridTarget.Cells[1,i+1];
    GetxyLv.x  := StrToFloatDef(sTemp,0.0);

    sTemp      := gridTarget.Cells[2,i+1];
    GetxyLv.y  := StrToFloatDef(sTemp,0.0);

    sTemp      := gridTarget.Cells[3,i+1];
    GetxyLv.Lv := StrToFloatDef(sTemp,0.0);
    GetAllxy[i] := GetxyLv;

    GetLimitxy[i].x := 0.005; // StrToFloatDef(grdTarget.Cells[4,i+1],0.0);
    GetLimitxy[i].y := 0.005; //StrToFloatDef(grdTarget.Cells[5,i+1],0.0);
    case i of
      TDllCaSdk2.IDX_RED    :  GetLimitxy[i].Lv := 2;
      TDllCaSdk2.IDX_GREEN  :  GetLimitxy[i].Lv := 5;
      TDllCaSdk2.IDX_BLUE   :  GetLimitxy[i].Lv := 1;
      TDllCaSdk2.IDX_WHITE  :  GetLimitxy[i].Lv := 6;
    end;
//    GetLimitxy[i].Lv := StrToFloatDef(grdTarget.Cells[6,i+1],0.0);

    if (GetxyLv.x <= 0) or (GetxyLv.y <= 0) or (GetxyLv.Lv <= 0)  then begin
      bRet := False;
      sDebug := sDebug + 'Grid: ' + gridTarget.Cells[1,i+1] +','+ gridTarget.Cells[2,i+1] +','+ gridTarget.Cells[3,i+1];
      sDebug := sDebug + Format(' Idx(%d),x(%0.4f),y(%0.4f),Lv(%0.4f),%s',[i,GetxyLv.x,GetxyLv.y,GetxyLv.Lv,sTemp]);
      Break;
    end;
    if (GetxyLv.x + GetxyLv.y) >= 1 then begin
      sDebug := sDebug + Format('Idx(%d),x(%0.4f),y(%0.4f),Sum(%0.4f)',[i,GetxyLv.x,GetxyLv.y,(GetxyLv.x + GetxyLv.y)]);
      bRet := False;

      Break;
    end;
  end;

  if not bRet then begin
    mmoAutoCalLog.Lines.Add('Target Value is wrong! Please Check Target Data');
    mmoAutoCalLog.Lines.Add(sDebug);
    Ca410CalControlPnl(True);
    Exit;
  end;

  thAutoCal := TThread.CreateAnonymousThread(procedure var i, nPgNo : Integer; begin
    nPgNo := GetProbeNum;
  // PG 연결 안되어 있으면 Exit.
    if Pg[nPgNo].StatusPg in [pgDisconn,pgWait] then begin
      thAutoCal.Synchronize(thAutoCal, procedure begin
        sDebug := Format('Channel %d is disconnected',[nPgNo + 1]);
        mmoAutoCalLog.Lines.Add(sDebug);
        Ca410CalControlPnl(True);
      end);
      Exit;
    end;
    // CA310 Connection Check.
    if DllCaSdk2.GetConnProbe(nProbeNum) <> 0 then begin
      thAutoCal.Synchronize(thAutoCal, procedure begin
        sDebug := Format('CA410 on Channel %X is disconnected',[nPgNo + 1]);
        mmoAutoCalLog.Lines.Add(sDebug);
        Ca410CalControlPnl(True);
      end);
      Exit;
    end;

    if m_bStopCa310Cal then Exit;
    // Power Off 부터 다하자.
    for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
//      Pg[i].SendSpiPowerOn(0);   // Added by KTS 2023-01-09 오후 4:30:48  PG POWER 확인
    end;
    sleep(100);

    // Probe Move.
//    if not Common.SystemInfo.OcManualType then AxDio.SetAutoControl(nStage,True);
    sleep(500);
    // Power On.
//    if Pg[nPgNo].SendPowerOn(2) <> WAIT_OBJECT_0 then begin
//      thAutoCal.Synchronize(thAutoCal, procedure begin
//        sDebug := Format('Ch%d Power On ==> NAK ',[nPgNo + 1]);
//        mmoAutoCalLog.Lines.Add(sDebug);
//        Ca410CalControlPnl(True);
//      end);
//      Exit;
//    end;
//
//    sleep(600);
//    Pg[nCh].SendSpiWp(0);
//    PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_9,False); // Added by KTS 2023-01-09 오후 4:31:53  Flow 확인
    // White.
//    PasScr[nCh].RunSeq(DefScript.SEQ_MAINT_1,False); // Added by KTS 2023-01-09 오후 4:32:18 Flow 확인

    for i := 0 to Pred(Common.OpticInfo.CalAgingTime) do begin
      thAutoCal.Synchronize(thAutoCal, procedure begin
        pnlCalLog.Caption := Format('%d Sec',[(Common.OpticInfo.CalAgingTime-i)]);
      end);
      sleep(1000);
      if m_bStopCa310Cal then break;
    end;
    pnlCalLog.Caption := '';

    if not m_bStopCa310Cal then begin
      CA410Calibration( thAutoCal,GetAllxy,GetLimitxy);
    end;
//    Pg[nPgNo].SendSpiPowerOn(0); // power Off.   // Added by KTS 2023-01-09 오후 4:32:18 Flow 확인
    sleep(500);

    thAutoCal.Synchronize(thAutoCal, procedure begin
      Ca410CalControlPnl(True);
    end);
  end);
  Ca410CalControlPnl(False);
  thAutoCal.Start;
end;

procedure TfrmMainter.PowerOffSeq(nCh: Integer);
begin
  ThreadTask( procedure begin
    SendGuiDisplay(nCh,'Power OFF');
    Pg[nCh].SendPowerOn(0);
    Pg[nCh].SetPwrMeasureTimer(False);
  end, btnPowerOff);
end;

procedure TfrmMainter.PowerOnSeq(nCh: Integer);
begin
  ThreadTask( procedure begin
    SendGuiDisplay(nCh,'Power On');
    Pg[nCh].SendPowerOn(1);
    Pg[nCh].SetPwrMeasureTimer(False);
  end, btnPowerOn);
end;


procedure TfrmMainter.btnPowerOnClick(Sender: TObject);
var
  nCh, i, nTemp : Integer;
begin
  nCh := cboChannelPg.ItemIndex;
  if nCh = -1 then Exit;
  if not (Pg[0].StatusPg in [pgReady]) then begin
    SendGuiDisplay(nCh,'Power On  ...Failed(Check PG Status)');
    Exit;
  end;
  //
  btnPowerOn.Enabled := False;
  PowerOnSeq(nCh); //TBD:AF9?
end;

procedure TfrmMainter.btnOneTimeMeasureClick(Sender: TObject);
var
  nCh : Integer;
  sDebug : string;
  getData : TBrightValue;
begin
  nCh := GetProbeNum;
  DllCaSdk2.Measure(nCh,GetData);
  sDebug := Format('Get Lv data : Probe %d, x(%0.5f), y(%0.5f), Lv(%0.5f)',
                    [nCh+1,  getData.xVal,getData.yVal,getData.LvVal]);
  mmoAutoCalLog.Lines.Add(sDebug);
end;


procedure TfrmMainter.pgcMainterClick(Sender: TObject);   // 2018-06-08 jhhwang
begin

  if pgcMainter.ActivePage = TabSheet1 then begin
      Common.MLog(DefCommon.MAX_SYSTEM_LOG,'Mainter: PG Comm');
  end
  else if pgcMainter.ActivePage = tabIoMap then begin
      Common.MLog(DefCommon.MAX_SYSTEM_LOG,'Mainter: IO MAP');
  end
  else if pgcMainter.ActivePage = tbSystemInfo then begin
      Common.MLog(DefCommon.MAX_SYSTEM_LOG,'Mainter: System Information');
  end;
end;

procedure TfrmMainter.btnScriptOpenClick(Sender: TObject);
begin
  RzOpenDialog1.InitialDir := common.Path.Maint;
  if RzOpenDialog1.Execute then begin
    ScrMemo1.Lines.LoadFromFile(RzOpenDialog1.FileName);
  end;
end;

procedure TfrmMainter.btnScriptSaveClick(Sender: TObject);
begin
  dlgSavePro.InitialDir := common.Path.Maint;
  if dlgSavePro.Execute then begin
    ScrMemo1.Lines.SaveToFile(dlgSavePro.FileName);
  end;
end;

procedure TfrmMainter.btnPowerOffClick(Sender: TObject);
var
  nCh, i, nTemp : Integer;
begin
  nCh := cboChannelPg.ItemIndex;
  if nCh = -1 then Exit;
  btnPowerOff.Enabled := False;
  if nCh < DefCommon.MAX_CH then begin
    PowerOffSeq(nCh)
  end
  else begin
    for i := DefCommon.CH1 to Pred(DefCommon.MAX_CH) do begin
      PowerOffSeq(i)
    end;
  end;
end;


procedure TfrmMainter.checkSignalTempPlates(inputPanel: TPanel; IsTrue: Boolean;IsAlarm : Boolean);
begin
  if IsTrue then begin
    if not IsAlarm then inputPanel.Color := $0080FF80
    else                inputPanel.Color := $0079C6FF;
  end
  else begin
    inputPanel.Color := clBtnFace;
  end;
end;

procedure TfrmMainter.chkUseTowerLampClick(Sender: TObject);
begin
  ControlDio.UseTowerLamp:= chkUseTowerLamp.Checked;
end;


procedure TfrmMainter.CmdThread(nCh: Integer);
var
  nSelect : Integer;
  i, nLenParam : Integer;
  sParam : string;
  slTemp : TStringList;
  naTemp, naData : array of integer;
  btBuff : TIdBytes;
  nFlashAddr: UInt32;
begin
  nSelect := cboCmdPg.ItemIndex;
  sParam  := StringReplace(Trim(edParam.Text),'0x','$',[rfReplaceAll]);
  SetLength(naTemp,2048);

 	slTemp := TStringList.Create;
 	try
   	ExtractStrings([' '],[],PChar(sParam),slTemp);
   	nLenParam := slTemp.Count;
  //if nSelect <> MAINT_CMD_AF9API_TEST then begin
    	for i := 0 to Pred(nLenParam) do begin
      	if i >= 1026 then break;
      	naTemp[i] := StrToIntDef(slTemp.Strings[i],0);
    	end;
  //end;
 	finally
   	slTemp.Free;
 	end;

  ThreadTask(procedure
  var
		sTemp, sTemp2: string;
		nTemp, j, nPatIdx, nDim, nPocb, nSlaveType, nDataLen: Integer;
		dwRet: DWORD;
		wLen: Word;
		btaData: TIdBytes;
    // AF9FPGA
    nRtnApi : Integer;
    arData : TIdBytes;
  begin
    try ////////
    case nSelect of
  		MAINT_CMD_POWER_ON : begin
        if not Pg[nCh].IsPgReady then begin
          SendGuiDisplay(nCh,'Power On ...NG(Check PG Status)');
          Exit;
        end;
        SendGuiDisplay(nCh,'Power On');
        Pg[nCh].SendPowerOn(1); // power on
      end;

  		MAINT_CMD_POWER_OFF : begin
        if not Pg[nCh].IsPgReady then begin
          SendGuiDisplay(nCh,'Power Off ...NG(Check PG Status)');
          Exit;
        end;
        SendGuiDisplay(nCh,'Power Off');
        Pg[nCh].SendPowerOn(0); // power off
      end;

  		MAINT_CMD_PATTERN_NUM : begin

      end;

		  MAINT_CMD_PATTERN_RGB : begin
        if nLenParam <> 3 then begin
          sTemp := 'Pattern RGB ...Parameter Error(Need 3 Parameters) !!!';
          SendGuiDisplay(nCh,sTemp);
          Exit;
        end;
        sTemp := Format('Pattern RGB: R(%d) G(%d) B(%d)',[naTemp[0],naTemp[1],naTemp[2]]);

        SendGuiDisplay(nCh,sTemp);
        dwRet := PG[nCh].SendDisplayPatRGB(naTemp[0]{nR},naTemp[1]{nG},naTemp[2]{nB});
        if dwRet <> WAIT_OBJECT_0 then begin
          case dwRet of
            WAIT_FAILED  : sTemp := sTemp + ' ...NG(Failed)';
            WAIT_TIMEOUT : sTemp := sTemp + ' ...NG(Timeout)';
            else           sTemp := sTemp + ' ...NG(Etc)';
          end;
          SendGuiDisplay(nCh,sTemp);
        end;
      end;

  		MAINT_CMD_DIMMING : begin
        if not Pg[0].IsPgReady then begin
          SendGuiDisplay(nCh,'Set Dimming ...NG(Check PG Status)');
          Exit;
        end;
        nDim := naTemp[0];
        if (nDim < 0) then nDim := 0 else if (nDim > 100) then nDim := 100;
        sTemp := Format('Set Dimming : %d',[nDim]);
        SendGuiDisplay(nCh,sTemp);
        if Pg[nCh].SendDimming(nDim) <> WAIT_OBJECT_0 then begin
          SendGuiDisplay(nCh,sTemp+' ...NG');
          Exit;
        end;
      end;

  		MAINT_CMD_LGD_REG_READ : begin
        sTemp2 := 'T-CON REG READ';
        if nLenParam <> 2 then begin
          sTemp := sTemp2 + ' ...Parameter Error(Need 2 Parameters) !!!';
          SendGuiDisplay(nCh,sTemp);
          Exit;
        end;
        //
        sTemp := sTemp2 + Format(' RegAddr(0x%0.4x) DataCnt(%d)',[naTemp[0],naTemp[1]]);
        SendGuiDisplay(nCh,sTemp);
        //
        if not Pg[0].IsPgReady then begin
          SendGuiDisplay(nCh,sTemp2+' ...NG(Check PG Status)');
          Exit;
        end;
        //
        SetLength(arData,naTemp[1]);
       // dwRet := Pg[nCh].SendI2cRead(DefPG.LGD_REG_DEVICE,naTemp[0]{nRegAddr},naTemp[1]{nDataLen},arData);
        case dwRet of
          WAIT_OBJECT_0: begin
            nDataLen := Pg[nCh].FTxRxPG.RxDataLen;
            for j := 0 to (nDataLen-1) do begin
              sTemp := sTemp + Format(' %0.2x',[arData[j]]);
            end;
            sTemp := sTemp + ')';
          end;
          WAIT_FAILED  : sTemp := sTemp2 + ' ...NG(Failed)';
          WAIT_TIMEOUT : sTemp := sTemp2 + ' ...NG(Timeout)';
          else           sTemp := sTemp2 + ' ...NG(Etc)';
        end;
        SendGuiDisplay(nCh,sTemp);
      end;

  		MAINT_CMD_LGD_REG_WRITE : begin
        sTemp2 := 'T-CON WRITE';
        if nLenParam < 2 then begin
          sTemp := sTemp2 + ' ...Parameter Error(Need minimum 2 parameters) !!!';
          SendGuiDisplay(nCh,sTemp);
          Exit;
        end;
        //
        sTemp := sTemp2 + Format(' RegAddr(0x%0.4x) Data(',[naTemp[0]]);
        nDataLen := nLenParam - 1;
        SetLength(naData, nDataLen);
        for j := 0 to Pred(nDataLen) do begin
          arData[j] := (naTemp[j+1] and $FF);
          sTemp := sTemp + Format(' 0x%0.2x',[arData[j]]);
        end;
        sTemp := sTemp + ')';
        SendGuiDisplay(nCh,sTemp);
        //
        if not Pg[0].IsPgReady then begin
          SendGuiDisplay(nCh,sTemp2+' ...NG(Check PG Status)');
          Exit;
        end;
        //dwRet := Pg[nCh].SendI2cWrite(DefPG.LGD_REG_DEVICE,naTemp[0]{nRegAddr},nDataLen, arData);
        if dwRet <> WAIT_OBJECT_0 then begin
          case dwRet of
            WAIT_FAILED  : sTemp := sTemp2 + ' ...NG(Failed)';
            WAIT_TIMEOUT : sTemp := sTemp2 + ' ...NG(Timeout)';
            else           sTemp := sTemp2 + ' ...NG(Etc)';
          end;
          SendGuiDisplay(nCh,sTemp);
        end;
      end;

  		MAINT_CMD_APS_REG_READ : begin
        sTemp2 := 'APS REG READ';
        sTemp := sTemp2 + ' ...N/A !!!';
        SendGuiDisplay(nCh,sTemp);
      end;

  		MAINT_CMD_APS_REG_WRITE : begin
        sTemp2 := 'APS REG WRITE';

        sTemp := sTemp2 + ' ...N/A !!!';
        SendGuiDisplay(nCh,sTemp);
      end;

  		MAINT_CMD_AF9API_TEST : begin

      end;

    end;
    finally  //////
      btnSendCmdPg.Enabled := True;
    end;     //////
  end, btnSendCmdPg);
end;


procedure TfrmMainter.DisplayDio(bIn: Boolean);
var
  i, nMod, nDiv, nMaxCnt : Integer;
  bTemp : Boolean;
begin
  if ledOut[Pred(DefDio.MAX_IO_CNT)] = nil then Exit; // 방어 코드.

  if bIn then begin
    for i := 0 to Pred(DefDio.MAX_IO_CNT) do begin
      nDiv := i div 8; nMod := i mod 8;
      bTemp := (CommDaeDIO.DIData[nDiv] and (1 shl nMod)) > 0;
      ledIn[i].Value := bTemp;
    end;
  end
  else begin
    for i := 0 to Pred(DefDio.MAX_IO_CNT) do begin
      nDiv := i div 8; nMod := i mod 8;
      bTemp := (CommDaeDIO.DODataFlush[nDiv] and (1 shl nMod)) > 0;
      ledOut[i].Value := bTemp;
      if bTemp then  btnOutSig[i].Caption := 'Off'
      else           btnOutSig[i].Caption := 'On';
    end;
  end;

//  ledIn  / ledOut
end;

procedure TfrmMainter.DisplayTempPlates;
var
  i, j : Integer;
begin

  if pnlTempPlateAlarm[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3,7] = nil then Exit;
  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin

    checkSignalTempPlates(pnlReady[i],CommTempPlate.CurrentStatus[i].CmdSatus = 0 );
    checkSignalTempPlates(pnlRun[i],  CommTempPlate.CurrentStatus[i].CmdSatus = 1 );
    checkSignalTempPlates(pnlAlarm[i],CommTempPlate.CurrentStatus[i].CmdSatus = 2 , True);
    edtSv[i].Text := Format('%0.1f °C',[CommTempPlate.CurrentStatus[i].Sv / 10]);
    edtPv[i].Text := Format('%0.1f °C',[CommTempPlate.CurrentStatus[i].Pv / 10]);
  end;
  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    checkSignalTempPlates(pnlHeating[i],CommTempPlate.CurrentStatus[i].Heating);
    checkSignalTempPlates(pnlCooling[i],CommTempPlate.CurrentStatus[i].Cooling);
    edtSv[i].Text := Format('%0.1f °C',[CommTempPlate.CurrentStatus[i].Sv / 10]);
    edtPv[i].Text := Format('%0.1f °C',[CommTempPlate.CurrentStatus[i].Pv / 10]);
    edtMv[i].Text := Format('%0.1f %',[CommTempPlate.CurrentStatus[i].Mv / 10]);
    // plates alarm message.
    for j := 0 to 7 do begin
      checkSignalTempPlates(pnlTempPlateAlarm[i,j],CommTempPlate.CurrentStatus[i].PlatesAlarm[j], True);
    end;
  end;
  // system alarm message.
  for i := 0 to 4 do begin
    checkSignalTempPlates(pnlTempPlateAlarm[0,i],CommTempPlate.CurrentStatus[0].SystemAlarm[i], True);
  end;

  i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM;
  checkSignalTempPlates(pnlSysStateEms,CommTempPlate.CurrentStatus[i].SystemSatus[0]);
  checkSignalTempPlates(pnlSysStateMc,CommTempPlate.CurrentStatus[i].SystemSatus[1]);
  checkSignalTempPlates(pnlSysStatePwr,CommTempPlate.CurrentStatus[i].SystemSatus[2]);
  checkSignalTempPlates(pnlSysStateReset,CommTempPlate.CurrentStatus[i].SystemSatus[3]);

  // for Chiller.
  checkSignalTempPlates(pnlChillerReady,CommTempPlate.CurrentStatus[i].ChillerStatus[0]);
  checkSignalTempPlates(pnlChillerRun,CommTempPlate.CurrentStatus[i].ChillerStatus[1]);
  checkSignalTempPlates(pnlChillerAlarm,CommTempPlate.CurrentStatus[i].ChillerStatus[2]);
  checkSignalTempPlates(pnlChillerOperated,CommTempPlate.CurrentStatus[i].ChillerStatus[3]);

  for j := 0 to 9 do begin
    checkSignalTempPlates(pnlChillerAlarms[i],CommTempPlate.CurrentStatus[i].ChillerAlarm[j],True);
  end;

end;

procedure TfrmMainter.edCmdPosChange(Sender: TObject);
begin
  m_bChangeZAxisValue:= True;
end;

procedure TfrmMainter.SaveCalResult(bIsVerify : Boolean);

begin

end;

procedure TfrmMainter.SaveOptCsv(sFileName: string);
var
  fSys        : TIniFile;
  i : Integer;
  sCalDir : string;
begin
  if cboModelType.ItemIndex < 0 then Exit;
  sCalDir := Common.Path.UserCal + cboModelType.Items[cboModelType.ItemIndex] + '\';
  Common.CheckDir(sCalDir);
  fSys := TIniFile.Create(sCalDir + '\OcConfig.ini');
  try
    fSys.WriteString('CA310_USER_CAL','SEL_CAL_FILE',sFileName);
  finally
    fSys.Free;
  end;
end;

procedure TfrmMainter.SendGuiDisplay(nCh: Integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  CommData    : RGuiMainter;
begin
  CommData.MsgType  := DefCommon.MSG_TYPE_PG;
  CommData.Channel  := nCh;
  CommData.Mode     := 0;
  CommData.Msg      := sMsg;
  ccd.dwData        := 0;
  ccd.cbData        := SizeOf(CommData);
  ccd.lpData        := @CommData;
  SendMessage(Self.Handle,WM_COPYDATA,0, LongInt(@ccd));
end;


procedure TfrmMainter.ThreadTask(task: TProc; btnObj : TRzBitBtn);
var
  th : TThread;
begin
  th := TThread.CreateAnonymousThread(procedure begin
    task;
    th.Synchronize(nil,procedure begin
      btnObj.Enabled := True;
    end);
  end);

  th.Start;
end;


procedure TfrmMainter.ThreadTask2(task: TProc; grpObj: TRzGroupBox);
var
  th : TThread;
begin
  th := TThread.CreateAnonymousThread(procedure begin
    try
      th.Synchronize(nil,procedure begin
        grpObj.Enabled := False;
      end);
      task;
    finally
      th.Synchronize(nil,procedure begin
        grpObj.Enabled := True;
      end);
    end;
  end);

  th.Start;
end;

procedure TfrmMainter.WMCopyData(var Msg: TMessage);
var
  nType, nCh : Integer;
  sMsg, sTemp : string;
begin
  nType := PGuiMainter(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgType;
  nCh   := PGuiMainter(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;

  case nType of
    DefCommon.MSG_TYPE_SCRIPT :begin
      sMsg  := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
      sTemp := FormatDateTime('[hh:mm:ss.zzz]',Now);
      sTemp := sTemp + Format('Ch%d : ',[nCh+1]) + sMsg;
      mmoScrResult.Lines.Add(sTemp);
    end;
    DefCommon.MSG_TYPE_PG : begin   // PG
      sMsg  := PGuiMainter(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
      sTemp := FormatDateTime('[hh:mm:ss.zzz]',Now);
      sTemp := sTemp + Format('Ch%d, Send : ',[nCh+1]) + sMsg;
      mmCommPg.Lines.Add(sTemp);
    end;
  end;

end;

procedure TfrmMainter.btnSendCmdPgClick(Sender: TObject);
var
  nCh, i : Integer;
begin
  nCh := DefCommon.CH1; //cboChannelPg.ItemIndex;
  if nCh > DefCommon.MAX_CH then begin
    for i := 0 to DefCommon.MAX_CH do begin
      CmdThread(i);
    end;
  end
  else begin
    CmdThread(nCh);
  end;
end;


procedure TfrmMainter.btnStopCalibrationClick(Sender: TObject);
var
  nCh : Integer;
begin
  m_bStopCa310Cal := True;
end;

procedure TfrmMainter.btnStopScriptClick(Sender: TObject);
var
  nCh, i : Integer;
begin
  nCh := cboScriptCh.ItemIndex;
  if nCh > DefCommon.MAX_CH then begin
    for i := DefCommon.CH1 to Pred(DefCommon.MAX_CH) do begin
      PasScr[i].StopMaintScript;
    end;
  end
  else begin
    PasScr[nCh].StopMaintScript;
  end;
end;


end.
