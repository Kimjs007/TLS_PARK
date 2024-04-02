unit FormTest3Ch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RzPanel, ALed, RzButton, Vcl.ExtCtrls, RzRadChk,
  Vcl.StdCtrls, Vcl.Grids, AdvObj, BaseGrid, AdvGrid, RzCommon, SwitchBtn, CtrlJig_Tls, CommGmes,
  CommonClass, DefScript, DefPG, DefCommon, AdvProgressBar, FormDoorOpenAlarmMsg, FormMainter, CtrlCssDll_Tls,
  VCLTee.Chart, VCLTee.Series, VCLTee.TeeProcs, VCLTee.TeEngine, CommModbusRtuTempPlate, CommPG,
  AdvPanel, Vcl.ComCtrls, AdvListV, Vcl.Mask, RzEdit, DongaPattern, RzGrids, AdvUtil, RzLine, DBModule,
  pasScriptClass, DefGmes, Vcl.Buttons, CtrlDio_Tls, DefDio, VclTee.TeeGDIPlus, CommHandBCR, DllCasSdkCa410, Vcl.Imaging.jpeg;

type
  TfrmTest3Ch = class(TForm)
    imgCheckBox: TImage;
    tmrReadChart: TTimer;
    pnlTestMain: TRzPanel;
    tmAging: TTimer;
    pnlErrAlram: TAdvPanel;
    pnlErrAlramMsg: TPanel;
    pnl2: TPanel;
    RzPanel4: TRzPanel;
    btnErrorDisplay: TRzButton;
    btnRetry: TRzButton;
    pnlJigInform: TPanel;
    RzBitBtn1: TRzBitBtn;
    RzBitBtn2: TRzBitBtn;
    RzPanel1: TRzPanel;
    pnlTotalTact: TPanel;
    grpPwrInfo: TRzGroupBox;
    lvPower: TAdvListView;
    RzBitBtn3: TRzBitBtn;
    mmoSysLog: TRichEdit;
    btnLampOnOff: TRzBitBtn;
    tmrReadPlateTemp: TTimer;
    Button1: TButton;
    pnlDoorOpen: TAdvPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    RzPanel2: TRzPanel;
    Image1: TImage;
    shpLeft: TShape;
    shpRight: TShape;
    procedure WMCopyData(var Msg : TMessage); message WM_COPYDATA;
    procedure WMCopyData_PG(var CopyMsg: TMessage);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnErrorDisplayClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCh2Click(Sender: TObject);
    procedure RzBitBtn7Click(Sender: TObject);
    procedure RzBitBtn8Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RzBitBtn2Click(Sender: TObject);
    procedure btnAutoClick(Sender: TObject);
    procedure btnCh4Click(Sender: TObject);
    procedure tmrReadChartTimer(Sender: TObject);
    procedure RzBitBtn3Click(Sender: TObject);
    procedure btnLampOnOffClick(Sender: TObject);
    procedure RzBitBtn1Click(Sender: TObject);
    procedure tmrReadPlateTempTimer(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private
    { Private declarations }
    FCountChartCh  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of Integer;
    FTempIr, FTempFlate, FTempTarget  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of Double;
    m_nCurStatus   : Integer;

    m_nOkCnt, m_nNgCnt : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of integer;
    m_nTotalTact, m_nUnitTact   :  Integer;
    tmTotalTactTime  :  TTimer;
    tmUnitTactTime   :  TTimer;

    // tact time.
    pnlTackTimes   :  TRzPanel;

    FCurCh, FCurIdxTm : Integer;
    pnlProcess     :  TPanel;
//    pnlAvgNames    :  TRzPanel;
//    pnlAvgValues   :  TPanel;


    lstPwrView     : TAdvListView;

    pnlLogGrp       : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;
    seqflowlist    : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of  TAdvStringGrid;
    mmChannelLog   : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of  TRichEdit;//  TMemo;

    tmAgingTimer   : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of  TTimer;
    m_nDiscounter  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of  Integer;

    // OK NG count.
    pnlTotalNames  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlTotalValues : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlOKNames     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlOKValues    : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlNGNames     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlNGValues    : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlChGrp       : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;
    ledPGStatuses  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of ThhALed;
    pnlHwVersion   : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;
    pnlShowVerion  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;
    chkChannelUse  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzCheckBox;
    pnlSerials     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlPGStatuses  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlTimeNResult : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;

    pnlTempStatus : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TRzPanel;
    pnlTempTarget : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlTempTargetVal : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;


    pnlTempPanel  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlTempPanelVal  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlTempPlate  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlTempPlateVal  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    chtTempPanel  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TChart;
    chtTempSeries : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH, 0..2] of TFastLineSeries;

    pnlHeating     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlCooling     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlGrpDio      : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlModelName   : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlUnitTact    :  array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    // Added by SHPARK 2024-01-13 오후 4:50:36 온도 수량 추가 10,25,40 ==> 5,10,25,40,50.
    pnlUnitTactVal :  array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH, 0..4] of TPanel;

    pbProgress     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TAdvProgressBar;
    pnlProgress    : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlProgressTxt : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlSubNgMsg    : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlAging       : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    pnlDioConTactUp  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlDioConTactDn  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlDioDetect   : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;
    pnlDioPresure  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    gridPWRPGs     : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TAdvStringGrid;
    pnlMESResults  : array[DefCommon.CH1 .. DefCommon.MAX_JIG_CH] of TPanel;

    procedure CreateGui;
    procedure DisplayGui;
    procedure OnTotalTimer(Sender : TObject);
    procedure OnUnitTimer(Sender : TObject);
    procedure chkPgClick(Sender: TObject);
    procedure RevSwDataJig(sGetData : String);
    procedure DisplayPGStatus(nPgNo, nType : Integer; sMsg : string);
    procedure DisplayPwrData(nPgNo: Integer; PwrData: TPwrData);
//    procedure DisplaySeq;
    procedure getBcrData(sScanData : string);
    procedure getAutoBcrData(sOriginalBcr : string; wCh : Word);
    procedure ClearChData(nCh : Integer);
    Function DisplayPatList(sPatGrpName : string) : TPatterGroup;
    procedure DisplayDataInChart(nCh : Integer);
    procedure UpdatePtList(hMain : HWND);
    procedure UpdatePwrGui;
    procedure SetBcrData;
    procedure CalcLogScroll(nPg, nLogLen : Integer);
    procedure SaveCsvTempStatus;
    procedure AddLog(sMsg: string; nCh:Integer; nType: Integer=0);
//    procedure ShowAgingTime(nTime : Integer);
  public
    { Public declarations }
    pnlJigTact     : TPanel;
    DongaSwitch     : TSerialSwitch;
    procedure ShowGui(hMain : HWND);
    procedure SetHandleAgain(hMain : HWND);
    procedure DisplaySysInfo;
    procedure SetConfig;
    procedure ShowIrTempData(nCh, nData : Integer);
    procedure SetAutoBcrData;
    procedure SetTempPlatesValue(nCh, nType : Integer; sData : string);
    procedure SetTempPlatesCooler(nCh, nType : Integer; IsOn : Boolean);
    procedure ShowSysLog(nType : Integer;sMsg : string);
    function CheckScriptRun : Boolean;
    procedure DisplayDoorOpenAlarm(isShowLeft, isShowRight : Boolean);
//    procedure SetLanguage(nIdx : Integer);
  end;

var
  frmTest3Ch: TfrmTest3Ch;

implementation

{$R *.dfm}
{$R+}

{ TfrmTest4Ch }

procedure TfrmTest3Ch.btnErrorDisplayClick(Sender: TObject);
begin
  pnlErrAlram.Visible := False;
end;

procedure TfrmTest3Ch.btnLampOnOffClick(Sender: TObject);
begin
  // Script가 돌고 있으면 시작 하지 말자.
  if PasScrMain.IsScriptRun then Exit;

  if ControlDio.ReadOutSig(DefDio.OUT_LAMP_WORKER_OFF) then begin
    btnLampOnOff.Caption := 'Lamp On';
    ControlDio.WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF,True)
  end
  else begin
    btnLampOnOff.Caption := 'Lamp Off';
    ControlDio.WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF)
  end;

end;

procedure TfrmTest3Ch.Button1Click(Sender: TObject);
begin
  // just for test.
  CtlLgdDll.StartOcDllCss(0,'BA520E7599A7A30130,NOSERIALNUM1,,H9BCGA414A',25.0);
  //if PasScr[0] <> nil then PasScr[0].RunSeq(DefScript.SEQ_KEY_PWR1_OFF)
end;

procedure TfrmTest3Ch.CalcLogScroll(nPg, nLogLen: Integer);
var
  i, nTimes : Integer;
begin
  nTimes := (nLogLen div 60);
  for i := 0 to nTimes do begin
    mmChannelLog[nPg].Perform(EM_SCROLL,SB_LINEDOWN,0);
  end;
end;

function TfrmTest3Ch.CheckScriptRun: Boolean;
var
  i: Integer;
  bRet : boolean;
begin
  bRet := False;
  for i := 0 to DefCommon.MAX_JIG_CH do begin
    if PasScrMain.IsScriptRun then begin
      bRet := True;
      Break;
    end;
  end;
  Result := bRet;
end;

procedure TfrmTest3Ch.chkPgClick(Sender: TObject);
var
  nCh : integer;
begin
  nCh := TRzCheckBox(Sender).Tag;
  if chkChannelUse[nCh].Checked then  chkChannelUse[nCh].Font.Color := clGreen
  else                                chkChannelUse[nCh].Font.Color := clRed;
  if PasScr[nCh] <> nil then PasScr[nCh].m_bUse := chkChannelUse[nCh].Checked;
  if PasScrMain <> nil then PasScrMain.m_bUsed[nCh] := chkChannelUse[nCh].Checked;
end;

procedure TfrmTest3Ch.ClearChData(nCh: Integer);
var
  i: Integer;
begin

  pnlSerials[nCh].Caption := '';
  pnlMESResults[nCh].Caption := '';
  pnlPGStatuses[nCh].Caption := 'Ready';
  if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
    pnlMESResults[nCh].Color := clBlack;
    pnlPGStatuses[nCh].Color := clBlack;
  end
  else begin
    pnlMESResults[nCh].Color := clBtnFace;
    pnlPGStatuses[nCh].Color := clBtnFace;
  end;

  gridPWRPGs[nCh].ClearAll;
  gridPWRPGs[nCh].ColumnHeaders.Add('');
  gridPWRPGs[nCh].ColumnHeaders.Add('Voltage');
  gridPWRPGs[nCh].ColumnHeaders.Add('Current');
  gridPWRPGs[nCh].ColumnHeaders.Add('');
  gridPWRPGs[nCh].ColumnHeaders.Add('Voltage');
  gridPWRPGs[nCh].ColumnHeaders.Add('Current');
  gridPWRPGs[nCh].Cells[0,1] := 'VCC';
  gridPWRPGs[nCh].Cells[0,2] := 'VIN';
  gridPWRPGs[nCh].Cells[0,3] := 'VDD3';
  gridPWRPGs[nCh].Cells[3,1] := '';
  gridPWRPGs[nCh].Cells[3,2] := '';
  gridPWRPGs[nCh].Cells[3,3] := '';

  for i := 0 to 4 do pnlUnitTactVal[nCh,i].Caption := '00 : 00';

  mmChannelLog[nCh].Clear;
  chtTempPanel[nCh].Series[0].Clear;
  chtTempPanel[nCh].Series[1].Clear;
  chtTempPanel[nCh].Series[2].Clear;
end;

procedure TfrmTest3Ch.CreateGui;
var
  i, nItemHeight, nItemWidth, j : Integer;
  nFontSize : Integer;
  sTemp : string;
begin
  //  // tact time을 위한 timer.
  m_nTotalTact:= 0;
  tmTotalTactTime := TTimer.Create(Self);
  tmTotalTactTime.Interval := 1000;
  tmTotalTactTime.OnTimer := OnTotalTimer;
  tmTotalTactTime.Enabled := False;

  tmUnitTactTime := TTimer.Create(Self);
  tmUnitTactTime.Interval := 1000;
  tmUnitTactTime.OnTimer := OnUnitTimer;
  tmUnitTactTime.Enabled := False;

  pnlTestMain.Visible := False;
  nItemWidth := (Self.Width) div (DefCommon.MAX_JIG_CH_CNT);
  nItemHeight := 26;

  // detailed items for each channel.
  for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    tmAgingTimer[i] := TTimer.Create(Self);
    tmAgingTimer[i].Interval := 1000;
//    tmAgingTimer[i].OnTimer := OnAgingTimer;
    tmAgingTimer[i].Name := Format('AGING_TIME_%d',[i]);
    tmAgingTimer[i].Enabled := False;
    m_nDiscounter[i] := 0;

    pnlChGrp[i] := TRzPanel.Create(self);
    pnlChGrp[i].Parent := pnlTestMain;
    pnlChGrp[i].Top := 2;
    pnlChGrp[i].Height := pnlTestMain.Height;
    pnlChGrp[i].Width := nItemWidth;
    pnlChGrp[i].Font.Size := 8;
    pnlChGrp[i].Left := nItemWidth * i;
    pnlChGrp[i].Align := alLeft;
    pnlChGrp[i].Font.Color  := clBlack;
    pnlChGrp[i].Alignment := taRightJustify;
    pnlChGrp[i].BorderOuter := TframeStyleEx(fsFlat);

    pnlHwVersion[i] := TRzPanel.Create(self);
    pnlHwVersion[i].Parent := pnlChGrp[i];
    pnlHwVersion[i].Top := 2;
    pnlHwVersion[i].Height := Round(nItemHeight*1.5);
    pnlHwVersion[i].Font.Size := 10;
    pnlHwVersion[i].Align := alTop;
    pnlHwVersion[i].Font.Color  := clBlack;
    pnlHwVersion[i].Alignment := taRightJustify;
    pnlHwVersion[i].Caption := '';
    pnlHwVersion[i].Hint    := 'FW , Boot, Model CRC Version, QSPI Board Name';
    pnlHwVersion[i].ShowHint := True;
    pnlHwVersion[i].BorderOuter := TframeStyleEx(fsFlat);

    ledPGStatuses[i] := ThhALed.Create(self);
    ledPGStatuses[i].Parent := pnlHwVersion[i];
    ledPGStatuses[i].LEDStyle := LEDSqLarge;
    ledPGStatuses[i].Blink    := False;
    ledPGStatuses[i].Align    := alLeft;
    ledPGStatuses[i].Top := 3;
    ledPGStatuses[i].Left := 4;

    pnlShowVerion[i] := TRzPanel.Create(self);
    pnlShowVerion[i].Parent := pnlHwVersion[i];
    pnlShowVerion[i].Top := 2;
    pnlShowVerion[i].Height := nItemHeight;
    pnlShowVerion[i].Font.Size := 10;
    pnlShowVerion[i].Align := alClient;
    pnlShowVerion[i].Font.Color  := clBlack;
    pnlShowVerion[i].Alignment := taRightJustify;
    pnlShowVerion[i].Caption := '';
    pnlShowVerion[i].Hint    := 'FW , Boot, Model CRC Version, QSPI Board Name';
    pnlShowVerion[i].ShowHint := True;
    pnlShowVerion[i].BorderOuter := TframeStyleEx(fsFlat);

    chkChannelUse[i] := TRzCheckBox.Create(self);
    chkChannelUse[i].Parent := pnlChGrp[i];
    chkChannelUse[i].CustomGlyphs.Assign(imgCheckBox.Picture.Bitmap);// := bmp;
    chkChannelUse[i].Top := pnlHwVersion[i].Top + pnlHwVersion[i].Height;
    chkChannelUse[i].Height := nItemHeight;
    chkChannelUse[i].Align := alTop;
    chkChannelUse[i].AutoSize := False;
    chkChannelUse[i].Tag   := i;
    chkChannelUse[i].OnClick := chkPgClick;
    chkChannelUse[i].Caption := Format('kênh (Channel) %d',[i+1+self.Tag*4]);//Format('Channel %d',[i+1+self.Tag*4]);
    chkChannelUse[i].AlignmentVertical := TAlignmentVertical(avCenter);
    chkChannelUse[i].Font.Size := 12;
    chkChannelUse[i].State := cbChecked;
    chkChannelUse[i].Font.Color := clGreen;
    chkChannelUse[i].Cursor := crHandPoint;

    pnlSerials[i] := TPanel.Create(self);
    pnlSerials[i].Parent := pnlChGrp[i];
    pnlSerials[i].Top := chkChannelUse[i].Top + chkChannelUse[i].Height;
    pnlSerials[i].Height := nItemHeight;
    pnlSerials[i].Align := alTop;
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      pnlSerials[i].Color := clBlack;
      pnlSerials[i].Font.Color := clYellow;
    end
    else begin
      pnlSerials[i].Color := clBtnFace;
      pnlSerials[i].Font.Color := clBlack;
    end;
    pnlSerials[i].Hint  := 'Serial Number';
    pnlSerials[i].ShowHint  := True;
    pnlSerials[i].Alignment := taCenter;
    pnlSerials[i].Font.Name := 'Tahoma';
    pnlSerials[i].Caption := '';//Format('23020218LN36A308416900A2%sC231369V16A3169WFB0000%d',[chr(10),i]);
    pnlSerials[i].ParentBackground := False;
    pnlSerials[i].StyleElements := [];
    pnlSerials[i].Font.Size := 12;

    pnlMESResults[i] := TPanel.Create(self);
    pnlMESResults[i].Parent := pnlChGrp[i];
//    pnlMESResults[i].Top := pnlSerials[i].Top + pnlSerials[i].Height;
    pnlMESResults[i].Top := pnlChGrp[i].Height;
    pnlMESResults[i].Height := nItemHeight;
    pnlMESResults[i].Align := alTop;
    pnlMESResults[i].Caption := '';
    pnlMESResults[i].Hint := 'MES result';
    pnlMESResults[i].ShowHint := True;
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      pnlMESResults[i].Color := clBlack;
      pnlMESResults[i].Font.Color := clWhite;
    end
    else begin
      pnlMESResults[i].Color := clBtnFace;
      pnlMESResults[i].Font.Color := clYellow;
    end;

    pnlMESResults[i].Font.Size := 12;
    pnlMESResults[i].ParentBackground := False;
    pnlMESResults[i].StyleElements := [];

    pnlPGStatuses[i] := TPanel.Create(Self);
    pnlPGStatuses[i].Parent := pnlChGrp[i];
//    pnlPGStatuses[i].Top := pnlMESResults[i].Top + pnlMESResults[i].Height;
    pnlPGStatuses[i].Top := pnlChGrp[i].Height;
    pnlPGStatuses[i].Align := alTop;
    pnlPGStatuses[i].Height := 80;
    pnlPGStatuses[i].Caption := ' - - ';
    pnlPGStatuses[i].Font.Name := 'Verdana';
    pnlPGStatuses[i].Hint := 'Inspection Result';
    pnlPGStatuses[i].ShowHint := True;
    pnlPGStatuses[i].Color := clBtnFace;
    pnlPGStatuses[i].Font.Size := 20;
    pnlPGStatuses[i].ParentBackground := False;
    pnlPGStatuses[i].StyleElements := [];
//    pnlPGStatuses[i].BorderOuter := TframeStyleEx(fsFlat);
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      pnlPGStatuses[i].Color := clBlack;
      pnlPGStatuses[i].Font.Color := clWhite;
//      pnlPGStatuses[i].StyleElements := [];
    end
    else begin
//      pnlPGStatuses[i].StyleElements := [];//[seFont, seClient, seBorder];
      pnlPGStatuses[i].Font.Color := clBlack;
    end;

//    pnlSubNgMsg[i] := TPanel.Create(Self);
//    pnlSubNgMsg[i].Parent := pnlChGrp[i];
//    pnlSubNgMsg[i].Align := alTop;
//    pnlSubNgMsg[i].Top := 275;
//    pnlSubNgMsg[i].Height := 60;
//    pnlSubNgMsg[i].Font.Size := 20;
//    pnlSubNgMsg[i].Hint := 'NG Message in detail';
//    pnlSubNgMsg[i].ParentBackground := False;
//    pnlSubNgMsg[i].StyleElements := [];
//    pnlSubNgMsg[i].Visible := True;
//    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
//      pnlSubNgMsg[i].Color := clBlack;
//      pnlSubNgMsg[i].Font.Color := clWhite;
//    end
//    else begin
//      pnlSubNgMsg[i].Font.Color := clBlack;
//    end;

    // for 온도.  ---------------------------------------------------------------------
    pnlTempStatus[i]  := TRzPanel.Create(self);
    pnlTempStatus[i].Parent := pnlChGrp[i];
//    pnlTimeNResult[i].Top := pnlPGStatuses[i].Top + pnlPGStatuses[i].Height;
    pnlTempStatus[i].Top := pnlChGrp[i].Height;
    pnlTempStatus[i].Height := nItemHeight*6+4;
    pnlTempStatus[i].Align := alTop;
    pnlTempStatus[i].BorderOuter := TframeStyleEx(fsFlat);

    pnlTempTarget[i]  := TPanel.Create(self);
    pnlTempTarget[i].Parent := pnlTempStatus[i];
    pnlTempTarget[i].Top    := 0;
    pnlTempTarget[i].Left   := 0;
    pnlTempTarget[i].Height := nItemHeight;
    pnlTempTarget[i].Width  := pnlTempStatus[i].Width div 6;
    pnlTempTarget[i].Caption := 'Temp Target';

    pnlTempTargetVal[i]  := TPanel.Create(self);
    pnlTempTargetVal[i].Parent := pnlTempStatus[i];
    pnlTempTargetVal[i].Top     := pnlTempTarget[i].Top + pnlTempTarget[i].Height + 1;
    pnlTempTargetVal[i].Left   := 0;
    pnlTempTargetVal[i].Height := nItemHeight * 2;
    pnlTempTargetVal[i].Width  :=pnlTempStatus[i].Width div 6;
    pnlTempTargetVal[i].Caption := 'Temp Target';
    pnlTempTargetVal[i].Caption := '- -';//Format('%d °C',[40]);
    pnlTempTargetVal[i].Color := clNavy;
    pnlTempTargetVal[i].Font.Color := clWhite;
    pnlTempTargetVal[i].StyleElements := [];
    pnlTempTargetVal[i].Font.Size := 12;

    pnlTempPanel[i]  := TPanel.Create(self);
    pnlTempPanel[i].Parent  := pnlTempStatus[i];
    pnlTempPanel[i].Top     := pnlTempTarget[i].Top;
    pnlTempPanel[i].Left    := pnlTempTarget[i].Width + pnlTempTarget[i].Left;
    pnlTempPanel[i].Height  := nItemHeight;
    pnlTempPanel[i].Width   := pnlTempStatus[i].Width div 6;
    pnlTempPanel[i].Caption := 'Panel Temp.';

    pnlTempPanelVal[i]  := TPanel.Create(self);
    pnlTempPanelVal[i].Parent := pnlTempStatus[i];
    pnlTempPanelVal[i].Top    := pnlTempTarget[i].Top + pnlTempTarget[i].Height + 1;
    pnlTempPanelVal[i].Height := nItemHeight * 2;
    pnlTempPanelVal[i].Width  := pnlTempStatus[i].Width div 6;
    pnlTempPanelVal[i].Left   := pnlTempTarget[i].Width + pnlTempTarget[i].Left;
    pnlTempPanelVal[i].Caption := '- -';//Format('%d °C',[25]);
    pnlTempPanelVal[i].Color := clBlack;
    pnlTempPanelVal[i].Font.Color := clWhite;
    pnlTempPanelVal[i].StyleElements := [];
    pnlTempPanelVal[i].Font.Size := 12;

    pnlTempPlate[i]  := TPanel.Create(self);
    pnlTempPlate[i].Parent  := pnlTempStatus[i];
    pnlTempPlate[i].Top     := pnlTempPanelVal[i].Top + pnlTempPanelVal[i].Height + 1;
    pnlTempPlate[i].Height  := nItemHeight;
    pnlTempPlate[i].Width   := pnlTempStatus[i].Width div 6;
    pnlTempPlate[i].Left    := pnlTempTarget[i].Width + pnlTempTarget[i].Left;
    pnlTempPlate[i].Caption := 'Plate Temp.';

    pnlTempPlateVal[i]  := TPanel.Create(self);
    pnlTempPlateVal[i].Parent := pnlTempStatus[i];
    pnlTempPlateVal[i].Top := pnlTempPlate[i].Top + pnlTempPlate[i].Height + 1;
    pnlTempPlateVal[i].Height := nItemHeight * 2;
    pnlTempPlateVal[i].Width  := pnlTempStatus[i].Width div 6;
    pnlTempPlateVal[i].Left   := pnlTempTarget[i].Width + pnlTempTarget[i].Left;
    pnlTempPlateVal[i].Caption := '- -';//Format('%d °C',[25]);
    pnlTempPlateVal[i].Color := clPurple;
    pnlTempPlateVal[i].Font.Color := clYellow;
    pnlTempPlateVal[i].Font.Size := 12;
    pnlTempPlateVal[i].StyleElements := [];

    pnlHeating[i]  := TPanel.Create(self);
    pnlHeating[i].Parent := pnlTempStatus[i];
    pnlHeating[i].Top     := pnlTempPlate[i].Top + pnlTempPlate[i].Height + 1;
    pnlHeating[i].Left   := 0;
    pnlHeating[i].Height := nItemHeight;
    pnlHeating[i].Width  :=pnlTempStatus[i].Width div 6;
    pnlHeating[i].Caption := 'Heating';
//    pnlHeating[i].Color := $00FFB0FF;
    pnlHeating[i].Font.Color := clBlack;
    pnlHeating[i].StyleElements := [];
    pnlHeating[i].Font.Size := 12;

    pnlCooling[i]  := TPanel.Create(self);
    pnlCooling[i].Parent := pnlTempStatus[i];
    pnlCooling[i].Top     := pnlHeating[i].Top + pnlHeating[i].Height + 1;
    pnlCooling[i].Left   := 0;
    pnlCooling[i].Height := nItemHeight;
    pnlCooling[i].Width  := pnlTempStatus[i].Width div 6;
    pnlCooling[i].Caption := 'Cooling';
//    pnlCooling[i].Color := $00FFB0B0;
    pnlCooling[i].Font.Color := clBlack;
    pnlCooling[i].StyleElements := [];
    pnlCooling[i].Font.Size := 12;

    chtTempPanel[i] := TChart.Create(Self);
    chtTempPanel[i].Parent := pnlTempStatus[i];
    chtTempPanel[i].Top := 0;
    chtTempPanel[i].Left := pnlTempPlate[i].Width + pnlTempPlate[i].Left;
    chtTempPanel[i].Height := pnlTempStatus[i].Height;
    chtTempPanel[i].Width := (pnlTempStatus[i].Width div 3) * 2;
    chtTempPanel[i].MarginLeft := 3;
    chtTempPanel[i].MarginRight := 3;
    chtTempPanel[i].MarginBottom := 3;
    chtTempPanel[i].Title.Text.Clear;
    chtTempPanel[i].BufferedDisplay := True;
    chtTempPanel[i].BottomAxis.DateTimeFormat := 'mm-dd hh:nn:ss';
    chtTempPanel[i].AllowPanning := pmHorizontal;
    chtTempPanel[i].Legend.Visible := False;
    chtTempPanel[i].ScrollMouseButton := mbLeft;
//    chtTempPanel[i].Title.Text.Add('TChart');
    chtTempPanel[i].LeftAxis.ExactDateTime := False;
    chtTempPanel[i].LeftAxis.Increment := 1.0;
    chtTempPanel[i].View3D := False;
    chtTempPanel[i].Zoom.Direction := tzdHorizontal;
    chtTempPanel[i].Zoom.MouseButton := mbRight;
    chtTempPanel[i].Zoom.MouseWheel := pmwNormal;
    chtTempPanel[i].ColorPaletteIndex := 13;
    chtTempPanel[i].LeftAxis.SetMinMax(2.0,55.0);
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      chtTempPanel[i].Color := clBlack;
    end;
//
    for j := 0 to 2 do begin
      chtTempSeries[i,j] := TFastLineSeries.Create(Self);
      chtTempSeries[i,j].Brush.BackColor := clDefault;
      chtTempSeries[i,j].LinePen.Width := 1;
      chtTempSeries[i,j].FastPen := True;
      chtTempSeries[i,j].XValues.DateTime := False;
      chtTempSeries[i,j].XValues.Name := 'X';
      chtTempSeries[i,j].XValues.Order := loAscending;
      chtTempSeries[i,j].YValues.Name := 'Y';
      chtTempSeries[i,j].YValues.Order := loNone;
      chtTempSeries[i,j].DrawAllPoints := false;

      case j of
        0 : chtTempSeries[i,j].Title := 'Panel Temp.';
        1 : chtTempSeries[i,j].Title := 'Plate Temp.';
        2 : chtTempSeries[i,j].Title := 'Target Temp.';
      end;
      chtTempSeries[i,j].XLabel[j] := chtTempSeries[i,j].Title;

      chtTempPanel[i].AddSeries(chtTempSeries[i,j]);
    end;
    FCountChartCh[i] := 0;


    // only for result.
    pnlTimeNResult[i] := TRzPanel.Create(self);
    pnlTimeNResult[i].Parent := pnlChGrp[i];
//    pnlTimeNResult[i].Top := pnlPGStatuses[i].Top + pnlPGStatuses[i].Height;
    pnlTimeNResult[i].Top := pnlChGrp[i].Height;
    pnlTimeNResult[i].Height := nItemHeight*2+4;
    pnlTimeNResult[i].Align := alTop;
    pnlTimeNResult[i].BorderOuter := TframeStyleEx(fsFlat);

    nFontSize := 12;

    pnlTotalNames[i] := TPanel.Create(self);
    pnlTotalNames[i].Parent := pnlTimeNResult[i];
    pnlTotalNames[i].Top := 1;
    pnlTotalNames[i].Left := 2;
    pnlTotalNames[i].Height := nItemHeight;
    pnlTotalNames[i].Width := 140;
    pnlTotalNames[i].Caption := 'sản xuất(Total)';
    pnlTotalNames[i].Font.Size := nFontSize;
//
    pnlTotalValues[i] := TPanel.Create(self);
    pnlTotalValues[i].Parent := pnlTimeNResult[i];
    pnlTotalValues[i].Top := 1;
    pnlTotalValues[i].Left := pnlTotalNames[i].Left + pnlTotalNames[i].Width + 1;
    pnlTotalValues[i].Height := nItemHeight;
    pnlTotalValues[i].Width := 78;
    pnlTotalValues[i].Caption := '0';
    pnlTotalValues[i].Font.Size := nFontSize + 4;
    pnlTotalValues[i].Color := clBlack;
    pnlTotalValues[i].Font.Color := clYellow;
    pnlTotalValues[i].StyleElements := [];

    pnlUnitTact[i] := TPanel.Create(self);
    pnlUnitTact[i].Parent := pnlTimeNResult[i];
    pnlUnitTact[i].Top := pnlTotalNames[i].Top + pnlTotalNames[i].Height + 1;// //pnlTackTimes.Top + pnlTackTimes.Height + 1;
    pnlUnitTact[i].Left := 2;//pnlNowValues.Left + pnlNowValues.Width+ 1;
    pnlUnitTact[i].Height := nItemHeight;
    pnlUnitTact[i].Width := 140;
    pnlUnitTact[i].Caption := 'OC Tact';
    pnlUnitTact[i].Font.Size := 8;
    pnlUnitTact[i].Font.Size := nFontSize;
    for j := 0 to 4 do begin
      pnlUnitTactVal[i,j]  := TPanel.Create(self);
      pnlUnitTactVal[i,j].Parent := pnlTimeNResult[i];
      pnlUnitTactVal[i,j].Top := pnlUnitTact[i].Top;
      if j = 0 then pnlUnitTactVal[i,j].Left := pnlUnitTact[i].Left + pnlUnitTact[i].Width+ 1
      else          pnlUnitTactVal[i,j].Left := pnlUnitTactVal[i,j-1].Left + pnlUnitTactVal[i,j-1].Width + 1;
      pnlUnitTactVal[i,j].Height := nItemHeight;
      if j = 0 then pnlUnitTactVal[i,j].Width := 100
      else          pnlUnitTactVal[i,j].Width := 80;
      pnlUnitTactVal[i,j].Caption := '00 : 00';
      pnlUnitTactVal[i,j].Color := clBlack;
      pnlUnitTactVal[i,j].Font.Color := clWhite;
      pnlUnitTactVal[i,j].Font.Size := 16;
      pnlUnitTactVal[i,j].StyleElements := [];
    end;


    pnlOKNames[i] := TPanel.Create(Self);
    pnlOKNames[i].Parent := pnlTimeNResult[i];
    pnlOKNames[i].Top := 1;
    pnlOKNames[i].Left := pnlTotalValues[i].Left + pnlTotalValues[i].Width + 1;
    pnlOKNames[i].Height := nItemHeight;//pnlTimeNResult[i].Height;
    pnlOKNames[i].Width := 37;
    pnlOKNames[i].Caption := 'OK';
    pnlOKNames[i].Font.Size := nFontSize-2;

    pnlOKValues[i] := TPanel.Create(Self);
    pnlOKValues[i].Parent := pnlTimeNResult[i];
    pnlOKValues[i].Top := 1;
    pnlOKValues[i].Left := pnlOKNames[i].Left + pnlOKNames[i].Width + 1;
    pnlOKValues[i].Height := nItemHeight;//pnlTimeNResult[i].Height-2;
    pnlOKValues[i].Width := 76;
    pnlOKValues[i].Color := clBlack;
    pnlOKValues[i].Caption := '0';
    pnlOKValues[i].Font.Size := nFontSize + 2;
    pnlOKValues[i].Font.Color := clLime;
    pnlOKValues[i].StyleElements := [];

    pnlNGNames[i] := TPanel.Create(Self);
    pnlNGNames[i].Parent := pnlTimeNResult[i];
    pnlNGNames[i].Top := 1;
    pnlNGNames[i].Left := pnlOKValues[i].Left + pnlOKValues[i].Width + 1;
    pnlNGNames[i].Height := nItemHeight;//pnlTimeNResult[i].Height;
    pnlNGNames[i].Width := 37;
    pnlNGNames[i].Font.Size := nFontSize-2;
    pnlNGNames[i].Caption := 'NG';

    pnlNGValues[i] := TPanel.Create(Self);
    pnlNGValues[i].Parent := pnlTimeNResult[i];
    pnlNGValues[i].Top := 1;
    pnlNGValues[i].Left := pnlNGNames[i].Left + pnlNGNames[i].Width + 1;
    pnlNGValues[i].Height := nItemHeight;//pnlTimeNResult[i].Height-2;
    pnlNGValues[i].Width := 76;
    pnlNGValues[i].Color := clBlack;
    pnlNGValues[i].Caption := '0';
    pnlNGValues[i].Font.Size := nFontSize + 2;
    pnlNGValues[i].Font.Color := clRed;
    pnlNGValues[i].StyleElements := [];

    pnlGrpDio[i] := TPanel.Create(Self);
    pnlGrpDio[i].Parent := pnlChGrp[i];
    pnlGrpDio[i].Align := alTop;
    pnlGrpDio[i].Top := 275;
    pnlGrpDio[i].Height := 98;
    pnlGrpDio[i].Visible := True;

    pnlAging[i] := TPanel.Create(Self);
    pnlAging[i].Parent := pnlChGrp[i];
    pnlAging[i].Align := alTop;
    pnlAging[i].Top := 275;
    pnlAging[i].Height := 60;
    pnlAging[i].Visible := False;

    pnlProgress[i] := TPanel.Create(Self);
    pnlProgress[i].Parent := pnlChGrp[i];
    pnlProgress[i].Align := alTop;
    pnlProgress[i].Top := 275;
    pnlProgress[i].Height := 60;
    pnlProgress[i].Font.Size := nFontSize + 2;
    pnlProgress[i].Visible := False;

    pbProgress[i] := TAdvProgressBar.Create(Self);
    pbProgress[i].Parent := pnlProgress[i];
    pbProgress[i].ShowPercentage := True;
    pbProgress[i].CompletionSmooth := True;
    pbProgress[i].Align := alTop;
    pbProgress[i].Height := 30;
    pbProgress[i].Visible := True;

    pnlProgressTxt[i] := TPanel.Create(Self);
    pnlProgressTxt[i].Parent := pnlProgress[i];
    pnlProgressTxt[i].Align := alClient;
    pnlProgressTxt[i].Top := 275;
    pnlProgressTxt[i].Height := 30;
    pnlProgressTxt[i].Font.Color := clWhite;
    pnlProgressTxt[i].Color := clBlue;
    pnlProgressTxt[i].StyleElements := [];
    pnlProgressTxt[i].Visible := True;

    gridPWRPGs[i] := TAdvStringGrid.Create(Self);
    gridPWRPGs[i].Clear;
    gridPWRPGs[i].Parent := pnlGrpDio[i];
    gridPWRPGs[i].Font.Name := 'Tahoma';
    gridPWRPGs[i].Font.Size := 12;
    gridPWRPGs[i].Top := 275;
    gridPWRPGs[i].Height := 76;
    gridPWRPGs[i].Width  := 440;
    gridPWRPGs[i].Align := alLeft;
    gridPWRPGs[i].ColCount := 6;
    gridPWRPGs[i].RowCount := 4;
    gridPWRPGs[i].FixedCols := 0;
    gridPWRPGs[i].ColumnHeaders.Add('');
    gridPWRPGs[i].ColumnHeaders.Add('V'{'Voltage'});
    gridPWRPGs[i].ColumnHeaders.Add('mA'{'Current'});
    gridPWRPGs[i].ColumnHeaders.Add('');
    gridPWRPGs[i].ColumnHeaders.Add('V'{'Voltage'});
    gridPWRPGs[i].ColumnHeaders.Add('mA'{'Current'});
    gridPWRPGs[i].Font.Size := 10;
    gridPWRPGs[i].Width  := 460;

    gridPWRPGs[i].ColWidths[0] := 60;
    gridPWRPGs[i].ColWidths[1] := 80;
    gridPWRPGs[i].ColWidths[2] := 80;
    gridPWRPGs[i].ColWidths[3] := 60;
    gridPWRPGs[i].ColWidths[4] := 80;
    gridPWRPGs[i].ColWidths[5] := 80;

    gridPWRPGs[i].Cells[0,1] := 'VCC';
    gridPWRPGs[i].Cells[0,2] := 'VIN';
    gridPWRPGs[i].Cells[0,3] := 'VDD3';

    gridPWRPGs[i].Cells[3,1] := 'VDD4';
    gridPWRPGs[i].Cells[3,2] := 'VDD5';
    gridPWRPGs[i].Cells[3,3] := '';

    gridPWRPGs[i].DefaultRowHeight := 22;
    gridPWRPGs[i].DefaultAlignment := taCenter;
//
    pnlLogGrp[i] := TRzPanel.Create(self);
    pnlLogGrp[i].Parent := pnlChGrp[i];
    pnlLogGrp[i].Align := alClient;
    pnlLogGrp[i].BorderOuter := TframeStyleEx(fsFlat);
//
    seqflowlist[i] := TAdvStringGrid.Create(Self);
    seqflowlist[i].Parent := pnlLogGrp[i];
    seqflowlist[i].Align := alLeft;

    seqflowlist[i].ColCount :=2;

    seqflowlist[i].Width  := 172;
    seqflowlist[i].Colwidths[0] := 28;
    seqflowlist[i].Colwidths[1] := 140;
    seqflowlist[i].Font.Size := 10;

    seqflowlist[i].FixedCols := 0;
    seqflowlist[i].FixedRows := 0;
    seqflowlist[i].FocusCell(-1,-1);
    seqflowlist[i].ScrollBars := TScrollStyle(ssNone);
    seqflowlist[i].StyleElements := [];
    seqflowlist[i].Visible := False;
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      seqflowlist[i].Color := clBlack;
      seqflowlist[i].Font.Color := clYellow;
    end
    else begin
      seqflowlist[i].Color := clWhite;
      seqflowlist[i].Font.Color := clBlack;
    end;

    mmChannelLog[i] := TRichEdit.Create(self);// TMemo.Create(self);
    mmChannelLog[i].Parent := pnlLogGrp[i];
    mmChannelLog[i].Align := alClient;
    mmChannelLog[i].WordWrap := false;
    mmChannelLog[i].ScrollBars := ssVertical;
    mmChannelLog[i].StyleElements := [];
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
      mmChannelLog[i].Color := clBlack;
      mmChannelLog[i].Font.Color := clWhite;
    end
    else begin
      mmChannelLog[i].Font.Color := clBlack;
      mmChannelLog[i].Color := clWhite;
    end;
  end;

  mmoSysLog.WordWrap := false;
  mmoSysLog.ScrollBars := ssVertical;
  if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
    mmoSysLog.Color := clBlack;
    mmoSysLog.Font.Color := clWhite;
  end
  else begin
    mmoSysLog.Font.Color := clBlack;
    mmoSysLog.Color := clWhite;
  end;

  pnlErrAlram.Parent := self; // 화면 뒤에 있지 않도록 Parent를 변경.
  //pnlTestMain.Visible := True;

end;

procedure TfrmTest3Ch.DisplayDataInChart(nCh : Integer);
var
  daValue, daX : array[0..2,0..9] of Double;
  i : Integer;
  sTime : string;
  dBottomMinimum, dtNow : TDatetime;
begin
//  if tmrReadChart.Enabled then Exit;
  dtNow := Now;
  try
//    chtTempPanel[nCh].AutoRepaint := False;
    sTime := FormatDateTime('mm:ss',dtNow);
    chtTempPanel[nCh].Series[0].AddXY(FCountChartCh[nCh],FTempIr[nCh],sTime,clBlue);
    chtTempPanel[nCh].Series[1].AddXY(FCountChartCh[nCh],FTempFlate[nCh],sTime,clGreen);
    chtTempPanel[nCh].Series[2].AddXY(FCountChartCh[nCh],FTempTarget[nCh],sTime,clBlack);

  finally
//    chtTempPanel[nCh].AutoRepaint := True;
//    chtTempPanel[nCh].Refresh;
  end;
  Inc(FCountChartCh[nCh]);
//  // 10번(임의로 지정) 찍은 후 그 이상 부터는 그래프가 옆으로 이동하게
//  if FCountChartCh[nCh] > 20 then begin
//    chtTempPanel[nCh].BottomAxis.SetMinMax(dBottomMinimum , dtNow);
//  end;



//    chtTempPanel[i].LeftAxis.SetMinMax(0.0,50.0);
//    for j := 0 to 1 do begin
//      chtTempSeries[i,j] := TFastLineSeries.Create(Self);
end;

procedure TfrmTest3Ch.DisplayDoorOpenAlarm(isShowLeft, isShowRight: Boolean);
var
  bShow : boolean;
begin
  bShow := not (isShowLeft and isShowRight);


  if bShow then begin

    shpLeft.Visible := not isShowLeft;
    shpRight.Visible := not isShowRight;
  end;
  pnlDoorOpen.Visible := bShow;
end;

procedure TfrmTest3Ch.DisplayGui;
var
  i, nItemHeight, nItemWidth, nFontSize, j : Integer;
begin
  nItemHeight := 26;
  nItemWidth := (Self.Width) div (DefCommon.MAX_JIG_CH_CNT);
  // detailed items for each channel.
  for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    pnlChGrp[i].Top := 2;
    pnlChGrp[i].Height := pnlTestMain.Height;
    pnlChGrp[i].Width := nItemWidth;
    pnlChGrp[i].Font.Size := 8;
    pnlChGrp[i].Left := nItemWidth * i;
    pnlChGrp[i].Align := alLeft;
    pnlChGrp[i].BorderOuter := TframeStyleEx(fsFlat);

    pnlHwVersion[i].Height := Round(nItemHeight*1.5);
    pnlHwVersion[i].Font.Size := 10;
    pnlHwVersion[i].Align := alTop;
    pnlHwVersion[i].Font.Color  := clBlack;
    pnlHwVersion[i].Alignment := taRightJustify;
    pnlHwVersion[i].BorderOuter := TframeStyleEx(fsFlat);

    pnlShowVerion[i].Height := nItemHeight;

    chkChannelUse[i].Top := pnlHwVersion[i].Top + pnlHwVersion[i].Height;
    chkChannelUse[i].Height := nItemHeight;
    chkChannelUse[i].Tag   := i;

    pnlSerials[i].Top := chkChannelUse[i].Top + chkChannelUse[i].Height;
    pnlSerials[i].Height := nItemHeight;

    pnlMESResults[i].Top := pnlChGrp[i].Height;
    pnlMESResults[i].Height := nItemHeight;
    pnlMESResults[i].Align := alTop;


    pnlPGStatuses[i].Top := pnlChGrp[i].Height;
    pnlPGStatuses[i].Align := alTop;

    // for 온도.  ---------------------------------------------------------------------
    pnlTempStatus[i].Top := pnlChGrp[i].Height;
    pnlTempStatus[i].Height := nItemHeight*6+4;
    pnlTempStatus[i].Align := alTop;

    pnlTempTarget[i].Top    := 0;
    pnlTempTarget[i].Left   := 0;
    pnlTempTarget[i].Height := nItemHeight;
    pnlTempTarget[i].Width  := pnlTempStatus[i].Width div 6;


    pnlTempTargetVal[i].Top     := pnlTempTarget[i].Top + pnlTempTarget[i].Height + 1;
    pnlTempTargetVal[i].Left   := 0;
    pnlTempTargetVal[i].Height := nItemHeight * 2;
    pnlTempTargetVal[i].Width  :=pnlTempStatus[i].Width div 6;

    pnlTempPanel[i].Top     := pnlTempTarget[i].Top;
    pnlTempPanel[i].Left    := pnlTempTarget[i].Width + pnlTempTarget[i].Left;
    pnlTempPanel[i].Height  := nItemHeight;
    pnlTempPanel[i].Width   := pnlTempStatus[i].Width div 6;

    pnlTempPanelVal[i].Top    := pnlTempTarget[i].Top + pnlTempTarget[i].Height + 1;
    pnlTempPanelVal[i].Height := nItemHeight * 2;
    pnlTempPanelVal[i].Width  := pnlTempStatus[i].Width div 6;
    pnlTempPanelVal[i].Left   := pnlTempTarget[i].Width + pnlTempTarget[i].Left;

    pnlTempPlate[i].Top     := pnlTempPanelVal[i].Top + pnlTempPanelVal[i].Height + 1;
    pnlTempPlate[i].Height  := nItemHeight;
    pnlTempPlate[i].Width   := pnlTempStatus[i].Width div 6;
    pnlTempPlate[i].Left    := pnlTempTarget[i].Width + pnlTempTarget[i].Left;


    pnlTempPlateVal[i].Top := pnlTempPlate[i].Top + pnlTempPlate[i].Height + 1;
    pnlTempPlateVal[i].Height := nItemHeight * 2;
    pnlTempPlateVal[i].Width  := pnlTempStatus[i].Width div 6;
    pnlTempPlateVal[i].Left   := pnlTempTarget[i].Width + pnlTempTarget[i].Left;

    pnlHeating[i].Top     := pnlTempPlate[i].Top + pnlTempPlate[i].Height + 1;
    pnlHeating[i].Left   := 0;
    pnlHeating[i].Height := nItemHeight;
    pnlHeating[i].Width  := pnlTempStatus[i].Width div 6;

    pnlCooling[i].Top     := pnlHeating[i].Top + pnlHeating[i].Height + 1;
    pnlCooling[i].Left   := 0;
    pnlCooling[i].Height := nItemHeight;
    pnlCooling[i].Width  := pnlTempStatus[i].Width div 6;

    chtTempPanel[i].Top := 0;
    chtTempPanel[i].Left := pnlTempPlate[i].Width + pnlTempPlate[i].Left;
    chtTempPanel[i].Height := pnlTempStatus[i].Height;
    chtTempPanel[i].Width := (pnlTempStatus[i].Width div 3) * 2;

    pnlTimeNResult[i].Top := pnlChGrp[i].Height;
    pnlTimeNResult[i].Height := nItemHeight*2+4;


    nFontSize := 12;

    pnlTotalNames[i].Top := 1;
    pnlTotalNames[i].Left := 2;
    pnlTotalNames[i].Height := nItemHeight;
    pnlTotalNames[i].Width := 120;

    pnlTotalValues[i].Top := 1;
    pnlTotalValues[i].Left := pnlTotalNames[i].Left + pnlTotalNames[i].Width + 1;
    pnlTotalValues[i].Height := nItemHeight;
    pnlTotalValues[i].Width := 78;

    pnlUnitTact[i].Top := pnlTotalNames[i].Top + pnlTotalNames[i].Height + 1;// //pnlTackTimes.Top + pnlTackTimes.Height + 1;
    pnlUnitTact[i].Left := 2;//pnlNowValues.Left + pnlNowValues.Width+ 1;
    pnlUnitTact[i].Height := nItemHeight;
    pnlUnitTact[i].Width := 120;
    for j := 0 to 4 do begin
      pnlUnitTactVal[i,j].Top := pnlUnitTact[i].Top;
      if j = 0 then pnlUnitTactVal[i,j].Left := pnlUnitTact[i].Left + pnlUnitTact[i].Width+ 1
      else          pnlUnitTactVal[i,j].Left := pnlUnitTactVal[i,j-1].Left + pnlUnitTactVal[i,j-1].Width + 1;
      pnlUnitTactVal[i,j].Height := nItemHeight;
      if j = 0 then pnlUnitTactVal[i,j].Width := 96
      else          pnlUnitTactVal[i,j].Width := 80;
      //pnlUnitTactVal[i,j].Width := 102;
    end;

    pnlOKNames[i].Top := 1;
    pnlOKNames[i].Left := pnlTotalValues[i].Left + pnlTotalValues[i].Width + 1;
    pnlOKNames[i].Height := nItemHeight;//pnlTimeNResult[i].Height;
    pnlOKNames[i].Width := 37;

    pnlOKValues[i].Top := 1;
    pnlOKValues[i].Left := pnlOKNames[i].Left + pnlOKNames[i].Width + 1;
    pnlOKValues[i].Height := nItemHeight;//pnlTimeNResult[i].Height-2;
    pnlOKValues[i].Width := 76;

    pnlNGNames[i].Top := 1;
    pnlNGNames[i].Left := pnlOKValues[i].Left + pnlOKValues[i].Width + 1;
    pnlNGNames[i].Height := nItemHeight;//pnlTimeNResult[i].Height;
    pnlNGNames[i].Width := 37;

    pnlNGValues[i].Top := 1;
    pnlNGValues[i].Left := pnlNGNames[i].Left + pnlNGNames[i].Width + 1;
    pnlNGValues[i].Height := nItemHeight;//pnlTimeNResult[i].Height-2;
    pnlNGValues[i].Width := 76;

    pnlGrpDio[i].Align := alTop;
    pnlGrpDio[i].Top := 275;
    pnlGrpDio[i].Height := 98;
    pnlGrpDio[i].Visible := True;

    pnlAging[i].Align := alTop;
    pnlAging[i].Top := 275;
    pnlAging[i].Height := 60;
    pnlAging[i].Visible := False;

    pnlProgress[i].Align := alTop;
    pnlProgress[i].Top := 275;
    pnlProgress[i].Height := 60;

    pbProgress[i].Align := alTop;
    pbProgress[i].Height := 30;
    pbProgress[i].Visible := True;

    pnlProgressTxt[i].Align := alClient;
    pnlProgressTxt[i].Top := 275;
    pnlProgressTxt[i].Height := 30;

    gridPWRPGs[i].Top := 275;
    gridPWRPGs[i].Height := 76;
    gridPWRPGs[i].Width  := 440;
    gridPWRPGs[i].Align := alLeft;
    gridPWRPGs[i].ColCount := 6;
    gridPWRPGs[i].RowCount := 4;
    gridPWRPGs[i].Width  := 460;

    pnlLogGrp[i].Align := alClient;

    seqflowlist[i].Align := alLeft;
    seqflowlist[i].Width  := 172;
    seqflowlist[i].Colwidths[0] := 28;
    seqflowlist[i].Colwidths[1] := 140;
    seqflowlist[i].Font.Size := 10;


    mmChannelLog[i].Align := alClient;
    mmChannelLog[i].WordWrap := false;
  end;

  mmoSysLog.WordWrap := false;
  mmoSysLog.ScrollBars := ssVertical;
  if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
    mmoSysLog.Color := clBlack;
    mmoSysLog.Font.Color := clWhite;
  end
  else begin
    mmoSysLog.Font.Color := clBlack;
    mmoSysLog.Color := clWhite;
  end;

  pnlErrAlram.Parent := self; // 화면 뒤에 있지 않도록 Parent를 변경.
  pnlTestMain.Visible := True;
end;

function TfrmTest3Ch.DisplayPatList(sPatGrpName: string): TPatterGroup;
begin

end;

procedure TfrmTest3Ch.DisplayPGStatus(nPgNo, nType: Integer; sMsg: string);
var
  nCh : Integer;
  sDebug, sTemp : string;
  sDateTime : string;

  wLen : Word;
  bPgVerAllNG, bPgVerHwNG, bPgVerFwNG, bPgVerSubFwNG, bPgVerFpgaNG, bPgVerPwrNG,bPgVerScriptNG : Boolean;
begin
  nCh := nPgNo mod 3;
  try
    case nType of
      DefCommon.PG_CONN_DISCONNECTED : begin
        ledPGStatuses[nCh].FalseColor := clRed;
        ledPGStatuses[nCh].Value := False;
        pnlShowVerion[nCh].Caption := 'PG Disconnedted';

        //TBD:QSPI? PasScr[nCh].StopRuningScript;
        pnlPGStatuses[nCh].Caption := 'PG BOARD DISCONNECT NG';
        pnlPGStatuses[nCh].Font.Size := 15;
        pnlPGStatuses[nCh].Color := clMaroon;
        pnlPGStatuses[nCh].Font.Name := 'Verdana';
        pnlPGStatuses[nCh].Font.Color := clYellow;
        sDebug := FormatDateTime('[HH:MM:SS.zzz] ',now) + 'PG BOARD DISCONNECT NG ';
        mmChannelLog[nCh].SelAttributes.Color := clRed;
        mmChannelLog[nCh].SelAttributes.Style := [fsBold];
        mmChannelLog[nCh].Lines.Add(sDebug);
        mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
        Common.MLog(nCh+self.Tag*4,'PG BOARD DISCONNECT NG : '+sMsg);
      end;
      DefCommon.PG_CONN_CONNECTED : begin
        ledPGStatuses[nCh].FalseColor := clYellow;
        ledPGStatuses[nCh].Value := False;
        pnlShowVerion[nCh].Caption := 'PG Connedted';
      end;
      DefCommon.PG_CONN_VERSION : begin
        // HW_1.3_APP_1.0.2_FW_1.02_FPGA_10105(1.6.0)_PWR_1.0 //= HW_APP_SubFW_FPGA_PWR            // HW_1.3_APP_1.0.2_FW_1.02_FPGA_10105(1.6.0)_PWR_1.0 //= HW_APP_SubFW_FPGA_PWR, SCRIPT
        pnlShowVerion[nCh].Caption := Format('DP860 (%s, %s)',[PG[nCh].m_PgVer.VerAll, PG[nCh].m_PgVer.VerScript]);
        bPgVerAllNG   := False;
        if Common.TestModelInfoPG.PgVer.VerAll <> '' then bPgVerAllNG   := (CompareText(Pg[nCh].m_PgVer.VerAll, Common.TestModelInfoPG.PgVer.VerAll) < 0);
        {$IFDEF DP860_TBD_XXXXX}
        bPgVerHwNG    := False;
        if Common.TestModelInfoPG.PgVer.HW     <> '' then bPgVerHwNG    := (CompareText(Pg[nCh].m_PgVer.HW,   Common.TestModelInfoPG.PgVer.HW)    < 0);
        bPgVerFwNG    := False;
        if Common.TestModelInfoPG.PgVer.FW     <> '' then bPgVerFwNG    := (CompareText(Pg[nCh].m_PgVer.FW,   Common.TestModelInfoPG.PgVer.FW)    < 0);
        bPgVerSubFwNG := False;
        if Common.TestModelInfoPG.PgVer.SubFW  <> '' then bPgVerSubFwNG := (CompareText(Pg[nCh].m_PgVer.SubFW,Common.TestModelInfoPG.PgVer.SubFW) < 0);
        bPgVerFpgaNG  := False;
        if Common.TestModelInfoPG.PgVer.FPGA   <> '' then bPgVerFpgaNG  := (CompareText(Pg[nCh].m_PgVer.FPGA, Common.TestModelInfoPG.PgVer.FPGA)  < 0);
        bPgVerPwrNG   := False;
        if Common.TestModelInfoPG.PgVer.PWR    <> '' then bPgVerPwrNG   := (CompareText(Pg[nCh].m_PgVer.PWR,  Common.TestModelInfoPG.PgVer.PWR)   < 0);
        {$ENDIF}
        bPgVerScriptNG := False;
        if Common.TestModelInfoPG.PgVer.VerScript <> '' then bPgVerScriptNG := (CompareText(Pg[nCh].m_PgVer.VerScript, Common.TestModelInfoPG.PgVer.VerScript) < 0);
        //
        if bPgVerAllNG or bPgVerScriptNG
            {$IFDEF DP860_TBD_XXXXX}
            or bPgVerHwNG or bPgVerFwNG or bPgVerSubFwNG or bPgVerFpgaNG or bPgVerPwrNG
            {$ENDIF}
        then begin
          ledPGStatuses[nCh].Value := False; //2022-03-24
          //
          pnlPGStatuses[nCh].Font.Size  := 24;
          pnlPGStatuses[nCh].Color      := clMaroon;
          pnlPGStatuses[nCh].Font.Name  := 'Verdana';
          pnlPGStatuses[nCh].Font.Color := clYellow;
          pnlPGStatuses[nCh].Caption    := 'PG Version NG';
          //
          mmChannelLog[nCh].SelAttributes.Color := clRed;
          mmChannelLog[nCh].SelAttributes.Style := [fsBold];
          sDateTime := FormatDateTime('[HH:MM:SS.zzz] ',now);
          if bPgVerAllNG then begin
            sTemp  := 'PG Version NG '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.VerAll, Common.TestModelInfoPG.PgVer.VerAll]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;

          if bPgVerHwNG then begin
            sTemp  := 'PG Version NG - HW '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.HW, Common.TestModelInfoPG.PgVer.HW]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
          if bPgVerFwNG then begin
            sTemp  := 'PG Version NG - FW '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.FW, Common.TestModelInfoPG.PgVer.FW]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
          if bPgVerSubFwNG then begin
            sTemp  := 'PG Version NG - SubFW '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.SubFW, Common.TestModelInfoPG.PgVer.SubFW]);
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
          if bPgVerFpgaNG then begin
            sTemp  := 'PG Version NG - FPGA '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.FPGA, Common.TestModelInfoPG.PgVer.FPGA]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
          if bPgVerPwrNG then begin
            sTemp  := 'PG Version NG - POWER '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.PWR, Common.TestModelInfoPG.PgVer.PWR]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
          if bPgVerScriptNG then begin
            sTemp  := 'PG Model Script Version NG '+ Format('(PG:%s,Model:%s)', [PG[nCh].m_PgVer.VerScript, Common.TestModelInfoPG.PgVer.VerScript]);
            sDebug := sDateTime + sTemp;
            mmChannelLog[nCh].Lines.Add(sDebug);
            mmChannelLog[nCh].Perform(EM_SCROLL,SB_LINEDOWN,0);
            Common.MLog(nCh,sTemp);
          end;
        end
        else begin
          if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
            pnlPGStatuses[nCh].Color      := clBlack;
            pnlPGStatuses[nCh].Font.Color := clWhite;
          end
          else begin
            pnlPGStatuses[nCh].Color      := clBtnFace;
            pnlPGStatuses[nCh].Font.Color := clBlack;
          end;
          pnlPGStatuses[nCh].Caption := 'PG ModelInfo Downloading';
        end;
      end;
      DefCommon.PG_CONN_READY : begin
        ledPGStatuses[nCh].Value     := True;
        pnlPGStatuses[nCh].Caption := 'Ready';
      end;
    end;
  except
    Common.DebugMessage('>> DisplayPGStatus Exception Error! ' + IntToStr(nPgNo+1));
  end;
end;

procedure TfrmTest3Ch.DisplayPwrData(nPgNo: Integer; PwrData: TPwrData);
begin
  gridPWRPGs[nPgNo].DisableAlign;
  // voltage.  gridPWRPGs[nPgNo].DisableAlign;

  gridPWRPGs[nPgNo].Cells[1, 1] := Format('%0.3f V',  [PwrData.VCC / 1000]);  // VCC/IVCC
  gridPWRPGs[nPgNo].Cells[2, 1] := Format('%d mA',    [PwrData.IVCC]);
  gridPWRPGs[nPgNo].Cells[1, 2] := Format('%0.3f V',  [PwrData.VIN / 1000]);  // VIN/IVIN
  gridPWRPGs[nPgNo].Cells[2, 2] := Format('%d mA',    [PwrData.IVIN]);

  gridPWRPGs[nPgNo].EnableAlign;
end;

procedure TfrmTest3Ch.DisplaySysInfo;
var
  nCh : Integer;
begin
  for nCh := 0 to DefCommon.MAX_JIG_CH do begin
    chkChannelUse[nCh].Checked := Common.SystemInfo.UseCh[nCh];

  end;
end;

procedure TfrmTest3Ch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if tmTotalTactTime <> nil then begin
    tmTotalTactTime.Enabled := False;
    tmTotalTactTime.Free;
    tmTotalTactTime := nil;
  end;
//  if tmUnitTactTime <> nil then begin
//    tmUnitTactTime.Enabled := False;
//    tmUnitTactTime.Free;
//    tmUnitTactTime := nil;
//  end;
end;

procedure TfrmTest3Ch.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  tmrReadChart.Enabled := False;
  m_nCurStatus := DefScript.SEQ_STOP;
  for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    m_nOkCnt[i] := 0;
    m_nNgCnt[i] := 0;
  end;
  mmoSysLog.Lines.Clear;
  mmoSysLog.StyleElements := [];
  UpdatePwrGui;
  SetBcrData;
  CreateGui;
end;

procedure TfrmTest3Ch.FormDestroy(Sender: TObject);
var
  i, j : Integer;
begin
  tmrReadChart.Enabled := False;
  tmrReadPlateTemp.Enabled := False;
  Common.Delay(1000);
  if JigLogic[Self.Tag] <> nil then begin
    JigLogic[Self.Tag].Free;
    JigLogic[Self.Tag] := nil;
  end;

  for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    if seqflowlist[i] <> nil then begin
      seqflowlist[i].Free;
      seqflowlist[i] := nil;
    end;

    for j := 0 to 1 do begin
      if chtTempSeries[i,j] <> nil then begin
        chtTempSeries[i,j].Free;
        chtTempSeries[i,j] := nil;
      end;
    end;
  end;

  if DongaSwitch <> nil then begin
    DongaSwitch.Free;
    DongaSwitch := nil;
  end;

end;

procedure TfrmTest3Ch.getAutoBcrData(sOriginalBcr: string; wCh: Word);
var
  i: Integer;
  sTemp : string;
begin

end;

procedure TfrmTest3Ch.getBcrData(sScanData: string);
var
  i, nLastCh: Integer;
  bIsScanned, bIsSame : Boolean;
  sTemp, sData : string;
begin
  bIsScanned := False;
  nLastCh := 0;
  sData := Trim(StringReplace(sScanData,#$A#$D, '', [rfReplaceAll]));
  // 중복 체크.
  bIsSame := False;
  for i := 0 to DefCommon.MAX_JIG_CH do begin
    sTemp := trim(pnlSerials[i].Caption);
    if sTemp = 'Scan BCR' then Continue;

    if not chkChannelUse[i].Checked then Continue;
    if sTemp = sData then begin
      bIsSame := True;
    end;
  end;

  if bIsSame then Exit;

  for i := 0 to DefCommon.MAX_JIG_CH do begin
    sTemp := trim(pnlSerials[i].Caption);
    if sTemp <> 'Scan BCR' then Continue;
    if not chkChannelUse[i].Checked then Continue;
    bIsScanned := True;
    nLastCh    := i;
    pnlSerials[i].Caption := sData;
    pnlSerials[i].Color   := $0088AEFF;
    pnlSerials[i].Font.Color := clBlack;
    PasScrMain.FBcrData[i] := sData;
    Break;
  end;
  // Scan 됨 확인.
  if DongaGmes <> nil then begin
    // 방금 Scan 됨을 확인.
    if bIsScanned then begin
      if nLastCh > -1 then begin
        pnlMESResults[nLastCh].Color      := clBlue;
        pnlMESResults[nLastCh].Font.Color := clYellow;
        pnlMESResults[nLastCh].Caption    := 'SEND PCHK DATA';
        DongaGmes.SendHostPchk(sData,nLastCh);
        Exit;
      end;
    end;
  end;
end;

procedure TfrmTest3Ch.OnTotalTimer(Sender: TObject);
var
  nSec, nMin : Integer;
begin

  Inc(m_nTotalTact);
  nSec := m_nTotalTact mod 60;
  nMin := (m_nTotalTact div 60) mod 60;
  pnlTotalTact.Caption := Format('%0.2d : %0.2d',[nMin, nSec]);
end;

procedure TfrmTest3Ch.OnUnitTimer(Sender: TObject);
var
  nSec, nMin : Integer;
begin
  Inc(m_nUnitTact);
  nSec := m_nUnitTact mod 60;
  nMin := (m_nUnitTact div 60) mod 60;
  pnlUnitTactVal[FCurCh][FCurIdxTm].Caption := Format('%0.2d : %0.2d',[nMin, nSec]);
//  pnlUnitTactVal.Caption := Format('%0.2d : %0.2d',[nMin, nSec]);
end;

procedure TfrmTest3Ch.RevSwDataJig(sGetData: String);
var
  nPos: Integer;
begin
//
//  if Length(sGetData) < 4 then Exit;
//  nPos := Pos('3',sGetData);
//  CodeSite.Send(sGetData);
//  case Byte(sGetData[nPos + 1]) of
//    $4E : begin   // Next
////      pnlAging.Caption := '';
////      JigLogic[Self.Tag].StartIspd_A(Self.Handle);
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_9);//
//    end;
//    $42 : begin
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_8);
//    end;
//    $31 : begin
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_7);
//    end;
//    //5
//    $33 : begin
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_5);
//    end;
//    //6
//    $45 : begin  // POCB Disable.
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_6);
//    end;
//    // 1 Key
//    $37 : begin
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_1);//.StartIspd_A_Auto;
//    end;
//    // 2 Key  (ESC)
//    $38 : begin
//
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_2);//StopIspd_A;
//    end;
//    // 3 Key
//    $35 : begin
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_3);//StartIspd_A_Repeat;
//    end;
//    // 4 Key (BACK)
//    $36 : begin
//      // back ---
//      JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_4);//NextIspd(False);
//    end;
//  end;
//  // 순서대로 버튼 눌렀을때 데이터.
{

02 3F 33 4E 03 (02 3F 33 4E 03 )
02 3F 33 4E 03 (02 3F 33 4E 03 )
02 3F 33 31 03 (02 3F 33 31 03 )
02 3F 33 42 03 (02 3F 33 42 03 )
02 3F 33 33 03 (02 3F 33 33 03 )
02 3F 33 45 03 (02 3F 33 45 03 )
02 3F 33 35 03 (02 3F 33 35 03 )     //3
02 3F 33 36 03 (02 3F 33 36 03 )     //4
02 3F 33 37 03 (02 3F 33 37 03 )    //1
02 3F 33 38 03 (02 3F 33 38 03 )}   //2
end;

procedure TfrmTest3Ch.AddLog(sMsg: string; nCh, nType: Integer);
var
  sLog: string;
begin
  if Common.StatusInfo.Closing then Exit;

  try
  if mmChannelLog[nCh].Lines.count > 200 then
    mmChannelLog[nCh].Lines.Clear;
  case nType of
    1: begin
      //Alarm 등 강조
      mmChannelLog[nCh].SelAttributes.Color := clRed;
      mmChannelLog[nCh].SelAttributes.Style := [fsBold];
    end;
    10: begin
      //저장만 한다.
      Common.MLog(nCh+self.Tag*4, sMsg);
      Exit;
    end
  else begin
    if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
       mmChannelLog[nCh].SelAttributes.Color := clWhite;
    end
    else begin
      mmChannelLog[nCh].SelAttributes.Color := clBlack;
    end;
      mmChannelLog[nCh].SelAttributes.Style := [];
  end;

  end;

  Common.MLog(nCh+self.Tag*4, sMsg);

  if Length(sMsg) > 600 then begin
    sLog := FormatDateTime('[HH:MM:SS.zzz] ',now) + Copy(sMsg,1,600);
  end
  else begin
    sLog := FormatDateTime('[HH:MM:SS.zzz] ',now) + sMsg
  end;

  except
    //유효하지 않은 문자열일 경우 오류(madException) 방지: RichEdit line insertion error.
    on E: Exception do  Common.MLog(nCh+self.Tag*4, 'AddLog Exception:' + E.Message + #13#10 + sMsg);
  end;

  try
    mmChannelLog[nCh].Lines.Add(sLog);
    mmChannelLog[nCh].Perform(WM_VSCROLL, SB_BOTTOM, 0);
  except
    //유효하지 않은 문자열일 경우 오류(madException) 방지: RichEdit line insertion error.
    on E: Exception do  Common.MLog(nCh+self.Tag*4, 'AddLog Exception:' + E.Message + #13#10 + sMsg);
  end;
end;

procedure TfrmTest3Ch.btnAutoClick(Sender: TObject);
begin

//  JigLogic[Self.Tag].StartIspd_A_Auto;
//  JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_1);
end;

procedure TfrmTest3Ch.btnCh2Click(Sender: TObject);
//var
//  i : Integer;
begin
//  i := Self.Tag*4 + 1;
//  Logic[i].StartEachCh(i);
//  JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_8);
end;

procedure TfrmTest3Ch.btnCh4Click(Sender: TObject);
begin
//  JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_7);
end;

procedure TfrmTest3Ch.RzBitBtn1Click(Sender: TObject);
begin

  JigLogic[Self.Tag].StartMainScript(DefScript.SEQ_KEY_START);
end;

procedure TfrmTest3Ch.RzBitBtn2Click(Sender: TObject);
begin
  JigLogic[Self.Tag].StartMainScript(DefScript.SEQ_KEY_STOP);
end;

procedure TfrmTest3Ch.RzBitBtn3Click(Sender: TObject);
begin
  if Common.FindCreateForm('TfrmDoorOpenAlarmMsg') <> '' then begin
    frmDoorOpenAlarmMsg.Close;
  end;
  frmDoorOpenAlarmMsg := TfrmDoorOpenAlarmMsg.Create(Self);
  frmDoorOpenAlarmMsg.btnClose.Visible := True;
  frmDoorOpenAlarmMsg.Show;
end;

procedure TfrmTest3Ch.RzBitBtn7Click(Sender: TObject);
//var
//  i : Integer;
begin
//  for i := Self.Tag*4 to Pred(Self.Tag*4 + 4) do begin
//    Logic[i].EnablePocb(True);
//  end;
//  JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_5);
end;

procedure TfrmTest3Ch.RzBitBtn8Click(Sender: TObject);
//var
//  i : Integer;
begin
//  for i := Self.Tag*4 to Pred(Self.Tag*4 + 4) do begin
//    Logic[i].EnablePocb(False);
//  end;
//  JigLogic[Self.Tag].StartIspd_A(DefScript.SEQ_KEY_6);
end;

procedure TfrmTest3Ch.SaveCsvTempStatus;
var
  sFilePath, sFileName : String;
  sLine: String;
  txtF                 : Textfile;
  i: Integer;
begin
  Common.CheckDir(Common.Path.TempCsv);
  sFilePath := Common.Path.TempCsv + FormatDateTime('yyyymm',now) + '\';
  Common.CheckDir(sFilePath);
  sFileName := sFilePath + Common.SystemInfo.EQPId + FormatDateTime('_yyyy_mm_dd',now)+'.csv';
  try
    try
      AssignFile(txtF, sFileName);
      try

        if not FileExists(sFileName) then begin
          //Header 생성
          Rewrite(txtF);
          sLine:=  'EQP ID,Date,Time';
          for i := 0 to DefCommon.MAX_CH do begin
            sLine:=  sLine + format(',Ch%d Target Temp',[i+1]);
            sLine:=  sLine + format(',Ch%d Plate Temp,Ch%d IR Temp',[i+1,i+1]);
          end;
          WriteLn(txtF, sLine);
        end;

        //Data
        Append(txtF);
        sLine:=  Common.SystemInfo.EQPId;
        sLine:=  sLine + FormatDateTime(',yyyy-mm-dd',now);
        sLine:=  sLine + FormatDateTime(',HH:NN:SS.zzz',now);

        for i := 0 to DefCommon.MAX_CH do begin
          sLine:=  sLine + format(',%0.1f',[FTempTarget[i]]);
          sLine:=  sLine + format(',%0.1f',[FTempFlate[i]]);
          sLine:=  sLine + format(',%0.1f',[FTempIr[i]]);
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

procedure TfrmTest3Ch.SetAutoBcrData;
var
  i : integer;
begin
//  for i := UPPER_AUTO_BCR to LOWER_AUTO_BCR do begin
//    if tcpAutoBCR[i] <> nil then
//      tcpAutoBCR[i].OnRevBCRData := getAutoBcrData;
//  end;
end;
procedure TfrmTest3Ch.SetBcrData;
begin
  DongaHandBcr.OnRevBcrData := getBcrData;
end;

procedure TfrmTest3Ch.SetConfig;
begin
//  DisplaySeq;
  DisplaySysInfo;
//  if DongaSwitch is TSerialSwitch then begin
//    DongaSwitch.ChangePort(Common.SystemInfo.Com_RCB1);
//  end;
end;

procedure TfrmTest3Ch.SetHandleAgain(hMain: HWND);
begin
  JigLogic[Self.Tag].SetHandleAgain(hMain, Self.Handle);
end;

procedure TfrmTest3Ch.SetTempPlatesCooler(nCh, nType: Integer; IsOn: Boolean);
begin
  case nType of
    0 : begin   // heatting.
      if IsOn then begin
        pnlHeating[nCh].Color := $00FFB0FF;
        pnlHeating[nCh].Font.Color := clBlack;
      end
      else begin
        pnlHeating[nCh].Color := clBtnFace;
        if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
          pnlHeating[nCh].Font.Color := clWhite;
        end
        else begin
          pnlHeating[nCh].Font.Color := clBlack;
        end;
      end;
    end;
    1 : begin   // Cooler.
      if IsOn then begin
        pnlCooling[nCh].Color := $00FFB0B0;
        pnlCooling[nCh].Font.Color := clBlack;
      end
      else begin
        pnlCooling[nCh].Color := clBtnFace;
        if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then begin
          pnlCooling[nCh].Font.Color := clWhite;
        end
        else begin
          pnlCooling[nCh].Font.Color := clBlack;
        end;
      end;
    end;
  end;
end;

procedure TfrmTest3Ch.SetTempPlatesValue(nCh, nType : Integer; sData : string);
begin
  case nType of
    0 : pnlTempTargetVal[nCh].Caption := sData;
    1 : pnlTempPlateVal[nCh].Caption := sData;
  end;
end;

procedure TfrmTest3Ch.ShowGui(hMain : HWND);
var
  i : Integer;
  CaSetupInfo : TCaSetupInfo;
begin
  if DongaGmes <> nil then begin
    DongaGmes.hMainHandle := Self.Handle;
  end;
  DisplayGui;//
  SetConfig;
  UpdatePtList(hMain);

  for i := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if PG[i] <> nil then   PG[i].m_hTest := Self.Handle
  end;


  DllCaSdk2 := TDllCaSdk2.Create(DefCommon.MSG_TYPE_CA410,0,hMain, Self.Handle,Common.TestModelInfoFLOW.Ca410MemCh,true);
  for i := 0 to Pred(TDllCaSdk2.MAX_PROBE) do begin
    CaSetupInfo.Ca410Ch       := Common.SystemInfo.Com_Ca410[i];
    CaSetupInfo.SelectIdx     := Common.SystemInfo.Com_Ca410[i];// CaSetupInfo;
    CaSetupInfo.DeviceId      := Common.SystemInfo.Com_Ca410_DevieId[i];
    CaSetupInfo.SerialNo      := Common.SystemInfo.Com_Ca410_SERIAL[i];
    DllCaSdk2.SetupPort[i]    := CaSetupInfo;
  end;

  DllCaSdk2.ManualConnect;
  tmrReadChart.Enabled := True;
end;

procedure TfrmTest3Ch.ShowIrTempData(nCh, nData: Integer);
var
  nRetCh : Integer;
  dTempData : double;
begin
  nRetCh := nCh - 1;
  if nRetCh < 0 then Exit;
  if nRetCh > DefCommon.MAX_JIG_CH then Exit;
  dTempData := nData / 10;
  pnlTempPanelVal[nRetCh].Caption := Format('%0.1f °C',[dTempData]);
  FTempIr[nRetCh] := dTempData;
  //FTempFlate
  //if chkChannelUse[nCh].Checked then DisplayDataInChart(nCh, 0, dTempData);
end;

procedure TfrmTest3Ch.ShowSysLog(nType : Integer;sMsg: string);
begin

  case nType of
    1: begin
      mmoSysLog.SelAttributes.Color := clRed;
      mmoSysLog.SelAttributes.Style := [fsBold];
    end;
    2: begin
      mmoSysLog.SelAttributes.Color := clMaroon; //clBlue;
      mmoSysLog.SelAttributes.Style := [fsBold];
    end;
    3: begin
      mmoSysLog.SelAttributes.Color := clBlue; //clGray;
      mmoSysLog.SelAttributes.Style := [fsBold];
    end
    else begin
      if Common.SystemInfo.UIType = DefCommon.UI_WIN10_BLACK then mmoSysLog.SelAttributes.Color := clWhite
      else                                                        mmoSysLog.SelAttributes.Color := clBlack;
      mmoSysLog.SelAttributes.Style := [];
    end;
  end;
  mmoSysLog.Lines.Add(sMsg);
  mmoSysLog.Perform(WM_VSCROLL, SB_BOTTOM, 0);

end;

procedure TfrmTest3Ch.tmrReadChartTimer(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to DefCommon.MAX_JIG_CH do begin
    if chkChannelUse[i].Checked then DisplayDataInChart(i);
  end;
  if PasScrMain <> nil then begin
    if PasScrMain.IsTempCsvSave then begin
      // Save temp data - in csv file.
      SaveCsvTempStatus;
    end;
  end;
  // Timer 추가 하기 귀찮아서 끼워 넣자.
  if shpLeft.Visible and shpRight.Visible then begin
      if shpLeft.Brush.Style = bsSolid then begin
        shpLeft.Brush.Style := bsBDiagonal;
        shpRight.Brush.Style := bsBDiagonal;
      end
      else begin
        shpLeft.Brush.Style := bsSolid;
        shpRight.Brush.Style := bsSolid;
      end;
  end
  else begin
    if shpLeft.Visible then begin
      if shpLeft.Brush.Style = bsSolid then begin
        shpLeft.Brush.Style := bsBDiagonal;
      end
      else begin
        shpLeft.Brush.Style := bsSolid;
      end;
    end;
    if shpRight.Visible then begin
      if shpRight.Brush.Style = bsSolid then begin
        shpRight.Brush.Style := bsBDiagonal;
      end
      else begin
        shpRight.Brush.Style := bsSolid;
      end;
    end;
  end;


end;

procedure TfrmTest3Ch.tmrReadPlateTempTimer(Sender: TObject);
var
  i : integer;
begin
  if CommTempPlate <> nil then begin
    for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
      SetTempPlatesCooler(i-1,0,CommTempPlate.CurrentStatus[i].Heating);
      SetTempPlatesCooler(i-1,1,CommTempPlate.CurrentStatus[i].Cooling);
      FTempFlate[i-1] := CommTempPlate.CurrentStatus[i].Pv / 10;
      FTempTarget[i-1] := CommTempPlate.CurrentStatus[i].Sv / 10;
      pnlTempPlateVal[i-1].Caption := Format('%0.1f °C',[FTempFlate[i-1]]);
      pnlTempTargetVal[i-1].Caption := Format('%0.1f °C',[FTempTarget[i-1]]);
      // Alarm check.

    end;
    // system Alarm Check.
    // Mainter GUI Display.
    if frmMainter <> nil then  frmMainter.DisplayTempPlates;
  end;

end;

procedure TfrmTest3Ch.UpdatePtList(hMain : HWND);
var
  i : Integer;
  PatGrp : TPatterGroup;
begin
  JigLogic[Self.Tag] := TJig.Create(Self.Tag,hMain,Self.Handle,Self);
end;

procedure TfrmTest3Ch.UpdatePwrGui;
var
  sTemp : string;
begin
  with lvPower do begin
    Items.Clear;

    with Items.Add do begin
      Caption := 'VCC';//'VCI';
      sTemp := Format('%0.2f',[Common.TestModelInfoPG.PgPwrData.PWR_VOL[DefCommon.PWR_VCI] / 1000]);
      SubItems.Add(sTemp);

      sTemp := 'VDD4';
      SubItems.Add(sTemp);
      sTemp := Format('%0.2f',[Common.TestModelInfoPG.PgPwrData.PWR_VOL[DefCommon.PWR_VPP] / 1000]);
      SubItems.Add(sTemp);
    end;
    with Items.Add do begin
      Caption := 'VIN';//'DVDD';
      sTemp := Format('%0.2f',[Common.TestModelInfoPG.PgPwrData.PWR_VOL[DefCommon.PWR_DVDD] / 1000]);
      SubItems.Add(sTemp);

      sTemp := 'VDD5';
      SubItems.Add(sTemp);
      sTemp := Format('%0.2f',[Common.TestModelInfoPG.PgPwrData.PWR_VOL[DefCommon.PWR_VBAT] / 1000]);
      SubItems.Add(sTemp);
    end;
    with Items.Add do begin
      Caption := 'VDD3';//'VDD';
      sTemp := Format('%0.2f',[Common.TestModelInfoPG.PgPwrData.PWR_VOL[DefCommon.PWR_VDD] / 1000]);
      SubItems.Add(sTemp);
    end;
  end;
end;

procedure TfrmTest3Ch.WMCopyData(var Msg: TMessage);
var
  nType, nMode, nCh, i, nTemp, nPatType : Integer;
  nParam, nParam2 : Integer;
  bTemp : Boolean;
  sMsg, sDebug, sTemp : string;
begin
  nType := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgType;
  nCh   := (PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel) mod 4;

  case nType of
    DefCommon.MSG_TYPE_SCRIPT : begin
      nMode := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      case nMode of
        DefCommon.MSG_MODE_CH_CLEAR : begin
          ClearChData(nCh);
        end;
        DefCommon.MSG_MODE_WORKING : begin
          sMsg := Trim(PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
          nParam := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
          mmChannelLog[nCh].DisableAlign;
          sDebug := FormatDateTime('[HH:MM:SS.zzz] ',now) + sMsg;
          if nParam = 1 then begin
            mmChannelLog[nCh].SelAttributes.Color := clRed;
            mmChannelLog[nCh].SelAttributes.Style := [fsBold];
          end;
          mmChannelLog[nCh].Lines.Add(sDebug);
          Common.MLog(nCh+self.Tag*4,sMsg);
          mmChannelLog[nCh].Perform(WM_VSCROLL, SB_BOTTOM, 0);
          mmChannelLog[nCh].EnableAlign;
        end;
        MSG_MODE_LOG_PWR : begin
          Common.MLog(nCh+self.Tag*4,sDebug);
        end;
        DefCommon.MSG_MODE_POWER_ON : begin
          pnlPGStatuses[nCh].Caption := 'Power On';
        end;
        DefCommon.MSG_MODE_POWER_OFF : begin
//          Logic[nCh].m_InsStatus := IsStop;
//          lnSigoff1.Visible := True;
//          lnSigoff2.Visible := True;
//          DongaPat.LoadPatFile('No Signal');
//          pnlPatternName.Caption := 'Power Off';
//          m_nTotalTact := 0;
//          tmTotalTactTime.Enabled := False;
        end;
        DefCommon.MSG_MODE_PAT_DISPLAY : begin
//          nTemp := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
//          if gridPatternList.RowCount < 2 then begin
//            if Trim(gridPatternList.Cells[1, 0]) = '' then Exit;
//          end;
//          if gridPatternList.RowCount < (nTemp+1) then Exit;
////          showmessage(format('%d / %d',[gridPatternList.RowCount , nTemp]));
//          gridPatternList.Row := nTemp;
//          nPatType := StrToInt(gridPatternList.Cells[0, nTemp]);
//          lnSigoff1.Visible := False;
//          lnSigoff2.Visible := False;
//          DongaPat.DrawPatAllPat(nPatType, gridPatternList.Cells[1, nTemp]);
//          pnlPatternName.Caption := gridPatternList.Cells[1, nTemp];

        end;
        DefCommon.MSG_MODE_CH_RESULT : begin
          nTemp := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
          pnlPGStatuses[nCh].Caption := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
          if nTemp = -1 then begin
            sMsg := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
            pnlPGStatuses[nCh].Caption := Trim(sMsg);
            pnlPGStatuses[nCh].Font.Size := 18;
            pnlPGStatuses[nCh].Font.Name := 'Tahoma';
            sDebug := Format('[ %s ]',[sMsg]);
            Common.MLog(nCh+self.Tag*4,sDebug);
            Exit;
          end;
          if nTemp = -2 then begin
            sMsg := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
            pnlPGStatuses[nCh].Caption := Trim(sMsg);
            pnlPGStatuses[nCh].Font.Size := 18;
            pnlPGStatuses[nCh].Font.Name := 'Tahoma';
            Exit;
          end;
          // NG 처리.
          if nTemp <> 0 then  begin
            pnlPGStatuses[nCh].Color := clRed;
            pnlPGStatuses[nCh].Font.Color := clBlack;
            Inc(m_nNgCnt[nCh]);
          end
          // OK 처리.
          else begin
            pnlPGStatuses[nCh].Color := clLime;
            pnlPGStatuses[nCh].Font.Color := clBlack;
            Inc(m_nOKCnt[nCh]);
          end;
          pnlTotalValues[nCh].Caption := Format('%d',[m_nNgCnt[nCh] + m_nOKCnt[nCh]]);
          pnlOKValues[nCh].Caption := Format('%d',[m_nOKCnt[nCh]]);
          pnlNGValues[nCh].Caption := Format('%d',[m_nNgCnt[nCh]]);
          modDB.UpdateNGTypeCount(PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel+1, nTemp); //DB에 NG Ratio 갱신
        end;
        DefCommon.MSG_MODE_UNIT_TT_START :  begin
          FCurCh := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
          FCurIdxTm := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam2;
          m_nUnitTact := 0;
          tmUnitTactTime.Enabled := True;
        end;
        DefCommon.MSG_MODE_UNIT_TT_END :  begin

          tmUnitTactTime.Enabled := False;
        end;
        DefCommon.MSG_MODE_TACT_START :  begin
          m_nTotalTact := 0;
          tmTotalTactTime.Enabled := True;
        end;
        DefCommon.MSG_MODE_TACT_END :  begin

          tmTotalTactTime.Enabled := False;
        end;
        DefCommon.MSG_MODE_BARCODE_READY : begin
          nTemp := PGuiScript(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
          if nTemp = 1 then begin
            pnlSerials[nCh].Caption := 'Scan BCR';
            pnlSerials[nCh].Font.Color  := clYellow;
            pnlSerials[nCh].Color     := clBlue;
          end;
        end;
      end;
    end;
    DefCommon.MSG_TYPE_PG : begin
       WMCopyData_PG(Msg);   //= MSG_TYPE_AF9FPGA
    end;
    DefCommon.MSG_TYPE_HOST : begin
      bTemp := PSyncHost(PCopyDataStruct(Msg.LParam)^.lpData)^.bError;
      sMsg  := PSyncHost(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
      case PSyncHost(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgMode of
        DefGmes.MES_PCHK : begin  //JHHWANG-GMES: 2018-06-20
      		//Common.MLog(DefCommon.MAX_SYSTEM_LOG,'TfrmTest4ChPocb.WMCopyData: MSG_TYPE_HOST, MES_PCHK, PG'+IntToStr(nCh+1)); //IMSI
          if bTemp then begin // error
            pnlMESResults[nCh].Color      := clMaroon;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'PCHK NG';
          end
          else begin
            pnlMESResults[nCh].Color      := clGreen;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'PCHK OK';
//            PasScr[Self.Tag*4 + nCh].SetHostEvent(0);
          end;

    			try
            PasScrMain.FMesRetrunSerial[nCh] := DongaGMes.MesData[Self.Tag*4 + nCh].PchkRtnPID;;
    			finally
      			//TBD
    			end;
				end;

        DefGmes.MES_EICR : begin
          if bTemp then begin // error
            pnlMESResults[nCh].Color      := clMaroon;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'EICR NG';

            AddLog(sMsg, nCh, 1);
            PasScrMain.SetHostEvent(1);
          end
          else begin
            pnlMESResults[nCh].Color      := clGreen;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'EICR OK';
            PasScr[Self.Tag*4 + nCh].SetHostEvent(0);
          end;
    			try
            PasScrMain.m_sMesEicrRtnCode := DongaGMes.MesData[nCh].EicrRtnCode;
    			finally
    			end;
        end;
        DefGmes.MES_RPR_EIJR : begin
      		//Common.MLog(DefCommon.MAX_SYSTEM_LOG,'TfrmTest4ChPocb.WMCopyData: MSG_TYPE_HOST, MES_EICR'); //IMSI
          if bTemp then begin // error
            pnlMESResults[nCh].Color      := clMaroon;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'RPR_EIJR NG';

            AddLog(sMsg, nCh, 1);

            PasScrMain.SetHostEvent(1);
          end
          else begin
            pnlMESResults[nCh].Color      := clGreen;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'RPR_EIJR OK';
            PasScrMain.SetHostEvent(0);
          end;
    			try
            PasScrMain.m_sMesEicrRtnCode := DongaGMes.MesData[nCh].EicrRtnCode;
    			finally
      			//TBD
    			end;
        end;
        DefGmes.MES_APDR : begin  //JHHWANG-GMES: 2018-06-20
      		if bTemp then begin // error
            pnlMESResults[nCh].Color      := clMaroon;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'APDR MES NG';

            AddLog(sMsg, nCh, 1);

            PasScrMain.SetHostEvent(1);
          end
          else begin
            pnlMESResults[nCh].Color      := clGreen;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'APDR MES OK';
            PasScrMain.SetHostEvent(0);
          end;

    			try
            PasScrMain.m_sMesPchkRtnCode := DongaGMes.MesData[Self.Tag*4 + nCh].PchkRtnCode;
            PasScrMain.m_sMesPchkRtnSerialNo := DongaGMes.MesData[Self.Tag*4 + nCh].PchkRtnSerialNo;

      			//EEPROM-ONLY  PasScr[nCh].RunEventSeq(DefScript.SEQ_EVENT, EEPROM_EVENTCODE_MES_PCHK);
    			finally
      			//TBD
    			end;
				end;
        DefGmes.EAS_APDR : begin
      		if bTemp then begin // error
            pnlMESResults[nCh].Color      := clMaroon;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'APDR EAS NG';
            //AddLog(sMsg, nCh, 1);
            PasScrMain.SetHostEvent(1);
          end
          else begin
            pnlMESResults[nCh].Color      := clGreen;
            pnlMESResults[nCh].Font.Color := clYellow;
            pnlMESResults[nCh].Caption    := 'APDR EAS OK';
            PasScrMain.SetHostEvent(0);
          end;
//
//    			try
//            PasScrMain.m_sMesPchkRtnCode := DongaGMes.MesData[Self.Tag*4 + nCh].PchkRtnCode;
//            PasScrMain.m_sMesPchkRtnSerialNo := DongaGMes.MesData[Self.Tag*4 + nCh].PchkRtnSerialNo;
//      			//EEPROM-ONLY  PasScr[nCh].RunEventSeq(DefScript.SEQ_EVENT, EEPROM_EVENTCODE_MES_PCHK);
//    			finally
//      			//TBD
//    			end;
        end;
      end;
    end;
    DefCommon.MSG_TYPE_CA410 : begin
{$IFDEF CA410_USE}
      nMode := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgMode;
      nTemp := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.nParam;
      sMsg  := PSyncCa410(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
      // nCh은 해당 Jig로 사용.
      case nMode of
        TDllCaSdk2.MSG_MODE_LOG : begin
          mmChannelLog[nCh].DisableAlign;
          sDebug := FormatDateTime('[HH:MM:SS.zzz] ',now) + sMsg;
          mmChannelLog[nCh].Lines.Add(sDebug);
          mmChannelLog[nCh].Perform(WM_VSCROLL, SB_BOTTOM, 0);
          Common.MLog(nCh+self.Tag*4,sMsg);
          mmChannelLog[nCh].EnableAlign;
        end;
        TDllCaSdk2.MSG_MODE_CAX10_MEM_CH_NO : begin

        end;
      end;
{$ENDIF}
    end;
  end;
end;

procedure TfrmTest3Ch.WMCopyData_PG(var CopyMsg: TMessage);
var
  nType, nMode, nCh, i, nTemp, nTemp2, nPgNo, nLines: Integer;
  nParam, nPatType : Integer;
  bTemp: Boolean;
  sMsg, sDebug, sTemp: string;
begin
  nCh   := PGuiPg2Test(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.PgNo;
  nTemp := PGuiPg2Test(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.Param;
  sMsg  := PGuiPg2Test(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.sMsg;

  nMode := PGuiPg2Test(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.Mode;
  case nMode of
    DefCommon.MSG_MODE_DISPLAY_VOLCUR: begin
      DisplayPwrData(nCh, PGuiPg2Test(PCopyDataStruct(CopyMsg.LParam)^.lpData)^.PwrData);
    end;
    DefCommon.MSG_MODE_DISPLAY_ALARM: begin
      if nCh = DefCommon.CH1 then begin
        pnlErrAlramMsg.Caption := Format('CH%d, %s',[nCh+1,Trim(sMsg)]);
      end
      else begin
        pnlErrAlramMsg.Caption := Format('CH%d, %s',[nCh+1,Trim(sMsg)]);
      end;
      pnlErrAlram.Left := 300;
      pnlErrAlram.Top := 410;
      pnlErrAlram.Visible := True;
      pnlPGStatuses[nCh].Font.Size := 24;
      pnlPGStatuses[nCh].Color := clMaroon;
      pnlPGStatuses[nCh].Font.Name := 'Verdana';
      pnlPGStatuses[nCh].Font.Color := clYellow;
      pnlPGStatuses[nCh].Caption := 'POWER LIMIT NG';
      sDebug := FormatDateTime('[HH:MM:SS.zzz] ', now) + 'POWER LIMIT NG : ' + sMsg;
      mmChannelLog[nCh].SelAttributes.Color := clRed;
      mmChannelLog[nCh].SelAttributes.Style := [fsBold];
      mmChannelLog[nCh].Lines.Add(sDebug);
      mmChannelLog[nCh].Perform(EM_SCROLL, SB_LINEDOWN, 0);
      Common.MLog(nCh, 'POWER LIMIT NG : ' + sMsg);

      Inc(m_nNgCnt[nCh]);
      pnlTotalValues[nCh].Caption := IntToStr(m_nOkCnt[nCh] + m_nNgCnt[nCh]);
      pnlOKValues[nCh].Caption := IntToStr(m_nOkCnt[nCh]);
      pnlNGValues[nCh].Caption := IntToStr(m_nNgCnt[nCh]);
      PasScrMain.TestInfo.Result[nCh] := sTemp;
    end;
    DefCommon.MSG_MODE_DISPLAY_CONNECTION : begin
      DisplayPGStatus(nCh,nTemp,sMsg);
    end;

    DefCommon.MSG_MODE_WORKING: begin
      try
        sDebug := FormatDateTime('[HH:MM:SS.zzz] ',now) + sMsg;
        mmChannelLog[nCh].DisableAlign;
        if nTemp = DefCommon.LOG_TYPE_NG then begin
          mmChannelLog[nCh].SelAttributes.Color := clRed;
          mmChannelLog[nCh].SelAttributes.Style := [fsBold];
          mmChannelLog[nCh].Perform(EM_SCROLL, SB_LINEDOWN, 0);
        end;
        mmChannelLog[nCh].Lines.Add(sDebug);
        CalcLogScroll(nCh, Length(sDebug));
        mmChannelLog[nCh].EnableAlign;
        Common.MLog(nCh + self.Tag * 4, sMsg);
      except
      end;
    end;
  end;
end;

end.
