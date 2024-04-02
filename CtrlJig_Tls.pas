unit CtrlJig_Tls;

interface
{$I Common.inc}
uses


  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, DefCommon, {CodeSiteLogging,}
  CommonClass, CommGmes, {LogicVh,} pasScriptClass, DefScript, {UdpServerClient,}CommPG,DefPG,  DefDio
  ;

type

  TJigStatus     = (jsReady, jsLoadReq, jsLoadComplete, jsOutputReq);
  TJigPosition   = (jsLoadZone, jsCameraZone);
  PGuiJigData  = ^RGuiJigData;
  RGuiJigData = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    nParam  : Integer;
    nParam1 : Integer;
    nParam2 : Integer;
  end;

  TJig = class(TObject)

    private
      m_nCurJig : Integer;
      m_nCurChStart : Integer;
      m_hMain : HWND;
      m_hTest : HWND;
      m_nIdxPatContact : Integer;
      m_bIsCa310Working : boolean;
      procedure SendTestGuiDisplay(nGuiMode: Integer; nP1: Integer = 0; nP2: Integer = 0; nP3: Integer = 0);
      function CheckPgConnect(nGroup : integer) : Boolean; // 한개라도 연결 안되면 False Return.
      function CheckScript(nGroup,nKeyIdx : Integer) : Boolean;
      procedure ScriptCreate(nCh : Integer;hMain, hTest : HWND; AOwner : TComponent);
      procedure ScriptMainCreate(hMain, hTest : HWND; AOwner : TComponent);
    public
      m_bKeyLock : boolean;
      m_JigStatus :      TJigStatus;
      constructor Create(nJigIdx : Integer ; hMain, hTest : HWND; AOwner : TComponent); virtual;
      destructor Destroy; override;
//      procedure StopPowerMeasure;
      procedure TestFunc;
      procedure StartMainScript(nSeq : Integer = 1);
      procedure StartSubScript(nCh : Integer;nSeq : Integer = 1);
      procedure StopMainScript(nSeq : Integer = 1);
      procedure StopSubScript(nCh : Integer;nSeq : Integer = 1);

      function IsScriptRunning : Boolean;
      // 화면 UI가 바뀌면서 Handle값이 바뀌어 재 설정.
      procedure SetHandleAgain(hMain, hTest : HWND);

  end;

var
  JigLogic : array[DefCommon.JIG_A .. DefCommon.JIG_B] of TJig;

implementation

//uses
//
//  ControlDio_OC;
{ TJig }
{$R+}

//function TJig.CheckHostAck(Task: TProc; nSid, nDelay, nRetry: Integer): DWORD;
//var
//	nRet  : DWORD;
//	i     : Integer;
//	sEvnt : WideString;
//begin
//	try
//		sEvnt := Format('SendHost%x0.4',[nSid]);
//		m_hHostEvnt := CreateEvent(nil, False, False, PWideChar(sEvnt));
//    m_bIsHostEvent := True;     // Create Event 했는지 확인 하는 Flag.
//		for i := 1 to nRetry do begin
//			Task;
////			if Status in [pgForceStop,pgDisconnect] then Break;
////      FRxData.NgOrYes := DefPG.CMD_READY;
//			nRet := WaitForSingleObject(m_hHostEvnt,nDelay);
//      if nRet <> WAIT_TIMEOUT then begin
//        Break;
//      end;
//		end;
//	finally
//		CloseHandle(m_hHostEvnt);
//    m_bIsHostEvent := False;
//	end;
//  Result := nRet
//end;


function TJig.CheckPgConnect(nGroup : Integer) : Boolean;
var
  nCh : Integer;
  bRet : boolean;
begin
  bRet := False;
  for nCh := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if not PasScr[nCh].m_bUse then Continue;
    if Pg[nCh].StatusPg in [pgReady] then begin
      bRet := True;
      Break;
    end;
  end;
  Result := bRet;
end;


function TJig.CheckScript(nGroup,nKeyIdx : Integer): Boolean;
var
  nCh, nChCnt : Integer;
  bRet : boolean;
begin
  bRet := False;

  if PasScrMain.ScriptRunning(nKeyIdx) then begin
    Exit(True);
  end;

  for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    if PasScr[nCh].ScriptRunning(nKeyIdx) then begin
      bRet := True;
      Break;
    end;
  end;
  Result := bRet;
end;

constructor TJig.Create(nJigIdx: Integer; hMain, hTest : HWND; AOwner : TComponent);
var
  nCh : Integer;
  th  : TThread;
begin
  m_bKeyLock := False;
  for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do ScriptCreate(nCh,hMain, hTest, AOwner);
  ScriptMainCreate(hMain, hTest, AOwner);
  m_hMain := hMain;
  m_hTest := hTest;
  m_nIdxPatContact := -1;
  m_JigStatus := jsReady;
end;

destructor TJig.Destroy;
var
  nCh, nChCnt : Integer;
begin
  if PasScrMain <> nil then begin
    PasScrMain.Free;
    PasScrMain := nil;
  end;
  for nCh := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    if PasScr[nCh] <> nil then begin
      PasScr[nCh].Free;
      PasScr[nCh] := nil;
    end;
  end;
  inherited;
end;

function TJig.IsScriptRunning: Boolean;
var
  nCh, nChCnt : Integer;
  bRet : boolean;
begin
  bRet := False;
  nChCnt        := DefCommon.MAX_PG_CNT div DefCommon.MAX_JIG_CNT;
  for nCh := m_nCurChStart to Pred(m_nCurChStart + nChCnt) do begin
    if PasScr[nCh].IsScriptRun then begin
      bRet := True;
      Break;
    end;
  end;
  Result := bRet;
end;

procedure TJig.ScriptCreate(nCh: Integer; hMain, hTest : HWND; AOwner : TComponent);
var
  th : TThread;
begin
  th := TThread.CreateAnonymousThread(procedure begin
    PasScr[nCh]         := TScrCls.Create(nCh, hMain,hTest);
    PasScr[nCh].m_bUse := Common.SystemInfo.UseCh[nCh];
    PasScr[nCh].LoadSource(Common.scrSequnce);
    sleep(900);
    PasScr[nCh].InitialScript;
  end);
  th.Start;
end;

procedure TJig.ScriptMainCreate(hMain, hTest: HWND; AOwner: TComponent);
var
  th : TThread;
begin
  th := TThread.CreateAnonymousThread(procedure var i : Integer; begin
    PasScrMain         := TScrCls.Create(0,hMain,hTest,True);
    for i := 0 to DefCommon.MAX_JIG_CH do PasScrMain.m_bUsed[i] := Common.SystemInfo.UseCh[i];
    PasScrMain.LoadSource(Common.scrSequnce);
    sleep(1000);
    PasScrMain.InitialMainScript;
  end);
  th.Start;
end;

procedure TJig.SendTestGuiDisplay(nGuiMode, nP1, nP2, nP3: Integer);
var
  ccd         : TCopyDataStruct;
  SendData    : RGuiJigData;
begin
  SendData.MsgType := DefCommon.MSG_TYPE_JIG;
  SendData.Channel := m_nCurJig;
  SendData.Mode    := nGuiMode;
  SendData.nParam  := nP1;
  SendData.nParam1 := nP2;
  SendData.nParam2 := nP3;

  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(SendData);
  ccd.lpData      := @SendData;
  SendMessage(m_hTest,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TJig.SetHandleAgain(hMain, hTest: HWND);
var
  nCh, nChCnt : Integer;
begin

  if m_hMain <> hMain then m_hMain := hMain;
  if m_hTest <> hTest then m_hTest := hTest;

  nChCnt        := DefCommon.MAX_PG_CNT div DefCommon.MAX_JIG_CNT;
  m_nCurChStart :=  m_nCurJig * nChCnt ;
  for nCh := m_nCurChStart to Pred(m_nCurChStart + nChCnt) do begin
    PasScr[nCh].SetHandleAgain(hMain,hTest);
  end;
end;

procedure TJig.StartMainScript(nSeq: Integer);
var
  nCh : Integer;
begin
{$IFNDEF SIMENV_NO_PG}
//  if not CheckPgConnect(0) then Exit;
  if CheckScript(0,nSeq) then Exit;
{$ENDIF}
  PasScrMain.InitialData;
  for nCh := 0 to DefCommon.MAX_JIG_CH do begin
    PasScrMain.TestInfo.IsPowerOn[nCh] := Pg[nCh].m_bPowerOn;// PasScr[nCh].TestInfo.PowerOn;
  end;

  PasScrMain.RunSeq(nSeq);
end;

procedure TJig.StartSubScript(nCh : Integer;nSeq: Integer);
begin
{$IFNDEF SIMENV_NO_PG}
  if not CheckPgConnect(0) then Exit; // 하나라도 Connection 되지 않으면 시작 하지 말자.
{$ENDIF}

  // Script가 돌고 있으면 시작 하지 말자.
  if CheckScript(0,nSeq) then Exit;
  PasScr[nCh].RunSeq(nSeq);
  PasScr[nCh].m_bIsProbeBackSig := False;
end;

procedure TJig.StopMainScript(nSeq: Integer);
var
  i : Integer;
begin
  for i := DefCommon.CH1 to DefCommon.MAX_JIG_CH do begin
    PasScr[i].m_bIsSyncSeq := False;  // 동기화시 Stop 되지 않는 이슈 때문.
    PasScr[i].RunSeq(DefScript.SEQ_KEY_STOP);
  end;
end;

procedure TJig.StopSubScript(nCh : Integer;nSeq: Integer);
begin
  PasScr[nCh].m_bIsSyncSeq := False;  // 동기화시 Stop 되지 않는 이슈 때문.
  PasScr[nCh].RunSeq(DefScript.SEQ_KEY_STOP);
end;

procedure TJig.TestFunc;
begin
  if Common.SystemInfo.UseManualSerial then SendTestGuiDisplay(DefCommon.MSG_MODE_BARCODE_READY);
end;

end.
