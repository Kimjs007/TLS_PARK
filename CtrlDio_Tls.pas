unit CtrlDio_Tls;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,  System.Classes, VaComm, Vcl.Controls, Vcl.Dialogs,
  CommDIO_DAE, DefDio, DefCommon, Vcl.ExtCtrls, CommIonizer, FormDoorOpenAlarmMsg, CommonClass, DefScript,
  CommModbusRtuTempPlate, CommPG;


const
  MSG_MODE_DISPLAY_START  = CommDIO_DAE.COMMDIO_MSG_MAX;
  MSG_MODE_DISPLAY_ALARAM = MSG_MODE_DISPLAY_START + 1;
  MSG_MODE_SYSTEM_ALARAM  = MSG_MODE_DISPLAY_START + 2;
  MSG_MODE_DISPLAY_IO     = MSG_MODE_DISPLAY_START + 3;

  CONTROLDIO_ALARM_NONE  = 0;
  CONTROLDIO_ALARM_LIGHT = 1;
  CONTROLDIO_ALARM_HEAVY = 2;
type

  TLoadZoneStage = (lzsNone, lzsA, lzsB);

  TControlDio = class(TObject)
  private
    m_nMsgType : Integer;
    m_hMain : HWND;
    tmrCycle : TTimer;
    m_PreLoadZoneStage : TLoadZoneStage;
    m_bIoThreadWork : boolean;
    m_nStageToFront : Integer;
    m_bConnected: Boolean; // A jig front 방향 ==> None(0). A jig Front (1), B Jig front 2.
    m_bDoorOpen : Boolean;
    m_nTowerLampState: Integer;
    m_nTowerLampTick: Cardinal;
    FIsFirstConnect : Boolean;
    FIsDoorOpen : Boolean;  // 완공 보고 표시 하기 위함.
    FIsScriptWorking : Boolean;

    function CheckAlarm: Integer;
    procedure SendMsgMain(nMsgMode: Integer; nParam, nParam2: Integer; sMsg: String; pData:Pointer=nil);
    procedure SetAlarmMsg(nIdx : Integer; bIsDisplayMessage : Boolean = True);
    procedure SendAlarm(nType, nIndex, nValue: Integer; sMsg:String='');
    function CheckDi(nIdx : Integer) : Boolean;
    function CheckDo(nIdx : Integer) : Boolean;

    procedure tmrCycleTimer(Sender : TObject);
    procedure TaskThread(task : TProc);
    procedure TaskThreadTerminiate(Sender : TObject);
    procedure CommDIONotify(Sender: TObject; pDataMessage: PGuiDaeDio);
    procedure Process_ChangedDI(pDataMessage: PGuiDaeDio);
    function WaitSignal(nIndex, nValue: Byte; nWaitTime: Cardinal): Cardinal;
    procedure CheckDioInSig(nSigId : Integer;bIsRetOkTrue : Boolean; bIsDoorOpenAlarm : Boolean);
    procedure Init_AlarmMessage;
    function CurrentChannelFromDio(nCh : Integer; IsUp : Boolean) : Boolean;
  public
//    DioAlarmData : array[0 .. DefDio.MAX_ALARM_DATA_SIZE] of Integer;
    LastNgMsg : string;
    LoadZoneStage : TLoadZoneStage;
    UseTowerLamp: Boolean;
    MelodyOn: Boolean;

    AlarmMsg: array [0..DefDio.ERR_LIST_MAX] of String; //알람 메시지
    AlarmData: array [0..DefDio.ERR_LIST_MAX] of Byte;
    // 0 : Loading(first Start) ==> 1 : Camera ==> 2 : Unloading ==> 1 : Camera.
    //ZoneStatus : array[DefCommon.JIG_A .. DefCommon.JIG_B] of Integer;
    constructor Create(hMain :HWND; nMsgType : Integer); virtual;
    destructor Destroy; override;
    function ErrorCheck : Integer;
    procedure RefreshIo;
    procedure ResetError(nIdx : Integer);

    function MovingProbe(nCh: Integer; bIsUpDown : Boolean; nWaitCnt : Integer = 100): Integer; // bIsUpDown False : 1~3 channel 이동만. True : up 하고 이동 그리고 Down.
    function CheckCurPosProbe(nCh: Integer; bIsUpDown : Boolean) : Integer;
    function ProbeUpDown(bIsUp : Boolean) : Integer;
    function LampOnOff(bIsOff : Boolean): Integer;
    /// <summary> Side Door 잠금해제 </summary>
    procedure UnlockDoorOpen(nch: Integer; bUnlock: Boolean);
    /// <summary> DO OUT signal to write </summary>
    /// <param name='nSignal'> 0~64. </param>
    /// <param name='bIsRemove'> True : Remove the signal, False : Add the signal, Default is False. </param>
    function WriteDioSig(nSignal : Integer; bIsRemove : Boolean = False) : Integer;
    procedure ClearOutDioSig(nSig : Integer);
    /// <summary> DI In signal to write </summary>
    /// <param name='nSignal'> 0~64. </param>
    function ReadInSig(nSignal : Integer) : Boolean;
    function ReadOutSig(nSignal : Integer) : Boolean;
    function IsDetected(nStage: Integer): Boolean;
//    procedure ThreadTurnStage;
    procedure DisplayIo;
    procedure Set_TowerLampState(nState: Integer);
    procedure SetIonizerNg(nCh, nIdxNg : Integer);
    procedure test;
    property Connected : Boolean read m_bConnected;
  end;


var
  ControlDio: TControlDio;

implementation
uses pasScriptClass;

{ TControlDio }


function TControlDio.CheckAlarm: Integer;
var
  nRet,i : Integer;
  nAlarmNo: Integer;
  bDoorOpen : Boolean;
begin
  nRet := DefDio.ERR_LIST_START;
  // Reset... Clear 되더라도 누적 되면 ...
  if not CommDaeDIO.Connected then begin
    LastNgMsg := 'Disconnected DIO Card....';
    SendMsgMain(CtrlDio_Tls.MSG_MODE_SYSTEM_ALARAM, ERR_LIST_DIO_CARD_DISCONNECTED,0,LastNgMsg);
    m_bConnected := False;
    Exit(DefDio.ERR_LIST_DIO_CARD_DISCONNECTED);
  end;

  // Check Input IO.
  CheckDioInSig(DefDio.IN_FAN_1,False,False);
  CheckDioInSig(DefDio.IN_FAN_2,False,False);
  CheckDioInSig(DefDio.IN_FAN_3,False,False);
  CheckDioInSig(DefDio.IN_FAN_4,False,False);
  CheckDioInSig(DefDio.IN_TEMP,True,False);
  CheckDioInSig(DefDio.IN_EMO_FRONT,True,True);
  CheckDioInSig(DefDio.IN_EMO_BACK,True,True);
  if (not CheckDi(DefDio.IN_EMO_FRONT)) and (not CheckDi(DefDio.IN_EMO_BACK)) then begin
    if (not CheckDo(DefDio.OUT_DOOR_UNLOCK_RR)) and (not CheckDi(DefDio.OUT_DOOR_UNLOCK_RL)) then  begin
      CheckDioInSig(DefDio.IN_MC_MONITOR,True,False);
    end;
  end;
//  CheckDioInSig(DefDio.IN_X_AXIS_SEN1,True,False);
//  CheckDioInSig(DefDio.IN_X_AXIS_SEN2,True,False);
//  CheckDioInSig(DefDio.IN_X_AXIS_SEN3,True,False);
//  CheckDioInSig(DefDio.IN_X_AXIS_SEN4,True,False);
//  CheckDioInSig(DefDio.IN_Z_UP_SEN,True,False);
//  CheckDioInSig(DefDio.IN_Z_DOWN_SEN,True,False);

  CheckDioInSig(DefDio.IN_DOOR_OPEN_FR,False,True);
  CheckDioInSig(DefDio.IN_DOOR_OPEN_FL,False,True);
  CheckDioInSig(DefDio.IN_DOOR_OPEN_RR,False,True);
  CheckDioInSig(DefDio.IN_DOOR_OPEN_RL,False,True);

  CheckDioInSig(DefDio.IN_MAIN_AIR_PRES,True,False);
  CheckDioInSig(DefDio.IN_HC_PLATE_ALARM,True,False);
  CheckDioInSig(DefDio.IN_WATER_PRES_LOW1,True,False);
  CheckDioInSig(DefDio.IN_WATER_PRES_HIGH1,True,False);
  CheckDioInSig(DefDio.IN_WATER_PRES_LOW2,True,False);
  CheckDioInSig(DefDio.IN_WATER_PRES_HIGH2,True,False);

  CheckDioInSig(DefDio.IN_WATER_LEAK_SEN1,True,False);
  CheckDioInSig(DefDio.IN_WATER_LEAK_SEN2,True,False);
  CheckDioInSig(DefDio.IN_WATER_LEAK_SEN3,True,False);

  if ReadOutSig(DefDio.OUT_DOOR_UNLOCK_RR) then SendAlarm(MSG_MODE_SYSTEM_ALARAM, DefDio.ERR_LIST_OUT_UNLOCK_DOOR3, 2);
  if ReadOutSig(DefDio.OUT_DOOR_UNLOCK_RL) then SendAlarm(MSG_MODE_SYSTEM_ALARAM, DefDio.ERR_LIST_OUT_UNLOCK_DOOR4, 2);

  // for unlock Door.
  if not ReadOutSig(DefDio.OUT_INSPECTION_DONE) then begin
    if ReadOutSig(DefDio.OUT_DOOR_UNLOCK_FR) then SendAlarm(MSG_MODE_SYSTEM_ALARAM, DefDio.ERR_LIST_OUT_UNLOCK_DOOR1, 2);
    if ReadOutSig(DefDio.OUT_DOOR_UNLOCK_FL) then SendAlarm(MSG_MODE_SYSTEM_ALARAM, DefDio.ERR_LIST_OUT_UNLOCK_DOOR2, 2);
  end;

  Result := nRet;
end;

function TControlDio.CheckCurPosProbe(nCh: Integer; bIsUpDown: Boolean): Integer;
var
  bIsUpPos : Boolean;
  nCurCh   : Integer;
begin
  // true : up, false : down.  SIGNAL 반전됨.    / bIsUpDown(마지막에 Down 하겠느냐?) ==> true : down, false : up.
  bIsUpPos := ReadInSig(DefDio.IN_Z_DOWN_SEN);
  if (not ReadInSig(DefDio.IN_X_AXIS_SEN1)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) then begin
    nCurCh := DefDio.PROBE_CH1;
  end
  else if (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) then begin
    nCurCh := DefDio.PROBE_CH2;
  end
  else if (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN4)) then begin
    nCurCh := DefDio.PROBE_CH3;
  end;

  if nCh = nCurCh then begin
    if (not bIsUpDown) = bIsUpPos then begin
      Result := 0;
    end
    else begin
      Result := 1;
    end;
  end
  else begin
    Result := 2;
  end;

end;

function TControlDio.CheckDi(nIdx: Integer): Boolean;
var
  nDiv, nMod : Integer;
begin
  nDiv := nIdx div 8; nMod := nIdx mod 8;
  Result :=  (CommDaeDIO.DIData[nDiv] and (1 shl nMod)) > 0;
end;



procedure TControlDio.CheckDioInSig(nSigId: Integer;bIsRetOkTrue : Boolean; bIsDoorOpenAlarm: Boolean);
begin
  if bIsRetOkTrue then begin
    if CheckDi(nSigId) then begin
      if bIsDoorOpenAlarm then begin
        if not ReadOutSig(DefDio.OUT_INSPECTION_DONE) then begin
          SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 2);
        end
        else begin
          if ReadInSig(DefDio.IN_EMO_FRONT) or ReadInSig(DefDio.IN_EMO_BACK) then begin
            SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 2);
          end;
        end;
      end
      else                      SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 1);
    end
    else begin
      SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 0);
    end;
  end
  else begin
    if not CheckDi(nSigId) then begin
      if bIsDoorOpenAlarm then begin
        if not ReadOutSig(DefDio.OUT_INSPECTION_DONE) then begin
          SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 2);
        end
        else begin
          if ReadInSig(DefDio.IN_EMO_FRONT) or ReadInSig(DefDio.IN_EMO_BACK) then begin
            SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 2);
          end;
        end;
      end
      else                      SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 1);
    end
    else begin
      SendAlarm(MSG_MODE_SYSTEM_ALARAM, nSigId, 0);
    end;
  end;
end;


function TControlDio.CheckDo(nIdx: Integer): Boolean;
var
  nDiv, nMod : Integer;
begin
  nDiv := nIdx div 8; nMod := nIdx mod 8;
  Result :=  (CommDaeDIO.DODataFlush[nDiv] and (1 shl nMod)) > 0;
end;

function TControlDio.LampOnOff(bIsOff: Boolean): Integer;
begin
  WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF,bIsOff);
end;


function TControlDio.ProbeUpDown(bIsUp: Boolean): Integer;
begin
  ClearOutDioSig(OUT_Z_POSITION_UP);
  ClearOutDioSig(OUT_Z_POSITION_DN);
  if bIsUp then WriteDioSig(DefDio.OUT_Z_POSITION_UP)
  else          WriteDioSig(DefDio.OUT_Z_POSITION_DN);
  Result := 0;
end;

procedure TControlDio.ClearOutDioSig(nSig: Integer);
var
  nIdx, nPos, nValue : integer;
begin
  nIdx := nSig div 8; nPos := nSig mod 8;
  nValue := 0;

  CommDaeDIO.WriteDO_Bit(nIdx,nPos,nValue);
end;

constructor TControlDio.Create(hMain: HWND; nMsgType : Integer);
var
  i : Integer;
begin
  Init_AlarmMessage;
  FIsFirstConnect := True;
  m_nMsgType := nMsgType;
  m_hMain  := hMain;
  m_bConnected := False;
  FIsDoorOpen  := False;

  m_nTowerLampState:= 0;
  m_nTowerLampTick:= GetTickCount;
  UseTowerLamp:= True;
  MelodyOn:= True;
  // Error Message 초기화.
//  for i:= 0 to Pred(DefDio.MAX_ALARM_DATA_SIZE) do DioAlarmData[i] := 0;
    // DIO Connect.
  CommDaeDIO:= TCommDIOThread.Create(0,DefCommon.MSG_TYPE_DAEIO, DefDio.DAE_IO_DEVICE_PORT, DefDio.DAE_IO_DEVICE_COUNT,True,3,1);
  CommDaeDIO.SetMelodyH := Common.SystemInfo.DioMelodyH;
  CommDaeDIO.SetMelodyL := Common.SystemInfo.DioMelodyL;
  CommDaeDIO.SetMelodyOk := Common.SystemInfo.DioMelodyInsDone;
  // Polling Mode 3 ==> Notify & Polling.
  CommDaeDIO.OnNotify := CommDIONotify;
//  if Common.SimulateInfo.Use_DIO then begin
//    CommDaeDIO.DeviceIP:= Common.SimulateInfo.DIO_IP;
//    CommDaeDIO.DevicePort:= Common.SimulateInfo.DIO_PORT;
//  end
//  else begin
    CommDaeDIO.DeviceIP:= DefDio.DAE_IO_DEVICE_IP;
    CommDaeDIO.DevicePort:= DefDio.DAE_IO_DEVICE_PORT;
//  end;
  CommDaeDIO.PollingInterval:= DefDio.DAE_IO_DEVICE_INTERVAL;
//  CommDaeDIO.LogPath :=  Common.Path.LOG;
  CommDaeDIO.LogLevel := 2;
  CommDaeDIO.Start;
//  DisplayIo;
  tmrCycle := TTimer.Create(nil);
  tmrCycle.Interval := 500;
  tmrCycle.OnTimer := tmrCycleTimer;
  tmrCycle.Enabled := True;

  m_bDoorOpen := False;
  m_bIoThreadWork := False;
  m_nStageToFront := 0;
end;

function TControlDio.CurrentChannelFromDio(nCh : Integer; IsUp: Boolean): Boolean;
var
  bRet1, bRet2 : Boolean;
begin

  // CurrentChannelFromDio(nCh,bIsUpDown)
  bRet1 := False;  bRet2 := False;
  case nCh of
    DefDio.PROBE_CH1 : begin
       if (not ReadInSig(DefDio.IN_X_AXIS_SEN1)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) then bRet1 := True;
    end;
    DefDio.PROBE_CH2 : begin
       if (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) then bRet1 := True;
    end;
    DefDio.PROBE_CH3 : begin
       if (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN4)) then bRet1 := True;
    end;
  end;
  if IsUp then begin
    if ReadInSig(DefDio.IN_Z_DOWN_SEN) and (not ReadInSig(DefDio.IN_Z_UP_SEN)) then bRet2 := True;
  end;


  // Probe down status.
  //if ReadInSig(DefDio.IN_Z_UP_SEN)

end;

destructor TControlDio.Destroy;
begin
  tmrCycle.Enabled := False;
  Sleep(100);
  tmrCycle.Free;
  tmrCycle := nil;

  if CommDaeDIO <> nil then begin
    CommDaeDIO.Free;
    CommDaeDIO := nil;
  end;

  inherited;
end;

procedure TControlDio.DisplayIo;
begin
  SendMsgMain(CtrlDio_Tls.MSG_MODE_DISPLAY_IO, 0,0,'');
end;

procedure TControlDio.UnlockDoorOpen(nCH : Integer; bUnlock: Boolean);
begin
  case  nCH  of
    4 : begin
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_FR, not bUnlock);
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_FL, not bUnlock);
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_RR, not bUnlock);
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_RL, not bUnlock);
    end
    else begin
      if nch < ALL_CH then begin
        WriteDioSig(DefDio.OUT_DOOR_UNLOCK_FR + nch, not bUnlock);
      end;
    end;
  end;
end;

function TControlDio.ErrorCheck: Integer;
var
  nRet : Integer;
  bDoorOpen : Boolean;
begin
  nRet := DefDio.ERR_LIST_START;
  // Reset... Clear 되더라도 누적 되면 ...
  if not CommDaeDIO.Connected then begin
    LastNgMsg := 'Disconnected DIO Card....';
    SendMsgMain(CtrlDio_Tls.MSG_MODE_SYSTEM_ALARAM, ERR_LIST_DIO_CARD_DISCONNECTED,0,LastNgMsg);
    m_bConnected := False;
    Exit(DefDio.ERR_LIST_DIO_CARD_DISCONNECTED);
  end;
  ResetError(1);
  CheckAlarm;

  if nRet <> DefDio.ERR_LIST_START then begin
    SetAlarmMsg(nRet);
    Exit(nRet);
  end
  else begin
  end;
  //tmrCycle.Enabled := False;
  ResetError(2);
  Result := 0;
end;

procedure TControlDio.Init_AlarmMessage;
var
  i : Integer;
  sTemp : string;
begin
  for i := 0 to DefDio.IN_MAX do begin
    AlarmMsg[i] := Format('[DI%0.2d] ',[i]) + DefDio.asDioIn[i] + ' NG';
    AlarmData[i] := 0;
  end;
  for i := DefDio.ERR_LIST_START to DefDio.ERR_LIST_MAX do begin
    sTemp := '';
    case i of
      DefDio.ERR_LIST_IONIZER_STATUS_NG_CH1 : sTemp := 'Ionizer Ch1 status NG.';
      DefDio.ERR_LIST_IONIZER_STATUS_NG_CH2 : sTemp := 'Ionizer Ch2 status NG.';
      DefDio.ERR_LIST_IONIZER_STATUS_NG_CH3 : sTemp := 'Ionizer Ch3 status NG.';
      DefDio.ERR_LIST_DIO_CARD_DISCONNECTED : sTemp := 'DIO Card Disconnected NG.';
      DefDio.ERR_LIST_TEMP_SENSOR1_NG       : sTemp := 'Temp Sensor #1 NG.';
      DefDio.ERR_LIST_TEMP_SENSOR2_NG       : sTemp := 'Temp Sensor #2 NG.';
      DefDio.ERR_LIST_TEMP_SENSOR3_NG       : sTemp := 'Temp Sensor #3 NG.';
      DefDio.ERR_LIST_TEMP_PLATE_1_NG       : sTemp := 'Temp Plate #1 NG.';
      DefDio.ERR_LIST_TEMP_PLATE_2_NG       : sTemp := 'Temp Plate #2 NG.';
      DefDio.ERR_LIST_TEMP_PLATE_3_NG       : sTemp := 'Temp Plate #3 NG.';
      DefDio.ERR_LIST_OUT_UNLOCK_DOOR1      : sTemp := '[DO14] Unlock Door';
      DefDio.ERR_LIST_OUT_UNLOCK_DOOR2      : sTemp := '[DO15] Unlock Door';
      DefDio.ERR_LIST_OUT_UNLOCK_DOOR3      : sTemp := '[DO16] Unlock Door';
      DefDio.ERR_LIST_OUT_UNLOCK_DOOR4      : sTemp := '[DO17] Unlock Door';
    end;

    AlarmMsg[i] := sTemp;
    AlarmData[i] := 0;
  end;

end;

function TControlDio.IsDetected(nStage: Integer): Boolean;
begin
  Result:= False;
//  if Common.SystemInfo.OCType = DefCommon.OCType  then begin
//    if nStage = 0 then begin
//      if ControlDio.ReadInSig(IN_CH_1_CARRIER_SENSOR)
//        or ControlDio.ReadInSig(IN_CH_1_CARRIER_SENSOR+16) then
//      begin
//        Result:= True;
//      end;
//    end
//    else begin
//      if ControlDio.ReadInSig(IN_CH_3_CARRIER_SENSOR)
//        or ControlDio.ReadInSig(IN_CH_3_CARRIER_SENSOR+15) then
//      begin
//        Result:= True;
//      end;
//    end;
//  end
//  else begin
//      if nStage = 0 then begin
//      if ControlDio.ReadInSig(IN_GIB_CH_1_CARRIER_SENSOR)
//        or ControlDio.ReadInSig(IN_GIB_CH_1_CARRIER_SENSOR+8) then
//      begin
//        Result:= True;
//      end;
//    end
//    else begin
//      if ControlDio.ReadInSig(IN_GIB_CH_3_CARRIER_SENSOR)
//        or ControlDio.ReadInSig(IN_GIB_CH_3_CARRIER_SENSOR+8) then
//      begin
//        Result:= True;
//      end;
//    end;
//
//  end;
end;
{

}
// 반드시 Thread에서 돌자.
function TControlDio.MovingProbe(nCh : Integer; bIsUpDown: Boolean; nWaitCnt : Integer = 100): Integer;
var
  i: Integer;
  nWaitingCount: Integer;
begin
  // 움직이려는 위치와 현재 위치가 같으면 0 값으로 Return 하도록 한다.
  if CheckCurPosProbe(nCh,bIsUpDown) = 0 then Exit(0);
  if (not ReadInSig(DefDio.IN_DOOR_OPEN_FR)) or (not ReadInSig(DefDio.IN_DOOR_OPEN_FL))  then Exit;

  nWaitingCount:= nWaitCnt;//100; //100ms * nWaitingCount
  //if ErrorCheck > 0 then Exit(1);
  // 만약에 Up 되어 있다면.
  if not ReadInSig(DefDio.IN_Z_DOWN_SEN) then begin
    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Probe UP Start');
    // Down 신호 Off
    ClearOutDioSig(DefDio.OUT_Z_POSITION_DN);
    WriteDioSig(DefDio.OUT_Z_POSITION_UP);
    if not ReadInSig(DefDio.IN_Z_UP_SEN) then begin
      SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Probe UP Finish - Already');
    end
    else begin
      WriteDioSig(DefDio.OUT_Z_POSITION_UP);
      for i := 0 to nWaitingCount do begin
        Sleep(100);
        if not ReadInSig(DefDio.IN_Z_UP_SEN) then begin
          SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format( 'Probe UP OK. Step=%d', [i]));
          break;
        end;
      end;
    end;
  end;

  // Probe Up 부터. 확인.
//  if bIsUpDown then begin

//  end;
//  if CurrentChannelFromDio(nCh,bIsUpDown) then Exit(0);

  // 원하는 Channel로 이동.
  if ReadInSig(DefDio.IN_Z_UP_SEN) then Exit(1);

  ClearOutDioSig(DefDio.OUT_X_POSITION_1);
  ClearOutDioSig(DefDio.OUT_X_POSITION_2);
  ClearOutDioSig(DefDio.OUT_X_POSITION_3);
  ClearOutDioSig(DefDio.OUT_X_POSITION_4);
  // 이동 했으면 Probe Down.
  case nCh of
    DefDio.PROBE_CH1 : begin
      WriteDioSig(DefDio.OUT_X_POSITION_1);
      WriteDioSig(DefDio.OUT_X_POSITION_2);
      if (not ReadInSig(DefDio.IN_X_AXIS_SEN1)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) then begin
        SendMsgMain(COMMDIO_MSG_LOG, 0, 0,  'Probe move  Channel 1 Finish - Already');
      end
      else begin
        for i := 0 to nWaitingCount do begin
          Sleep(100);
          if (not ReadInSig(DefDio.IN_X_AXIS_SEN1)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) then begin
            SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format( 'Probe Move Channel 1 OK. Step=%d', [i]));
            break;
          end;
        end;
      end;
      if (ReadInSig(DefDio.IN_X_AXIS_SEN1)) or (ReadInSig(DefDio.IN_X_AXIS_SEN2)) then Exit(2);
    end;
    DefDio.PROBE_CH2 : begin
      WriteDioSig(DefDio.OUT_X_POSITION_2);
      WriteDioSig(DefDio.OUT_X_POSITION_3);
      if (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) then begin
        SendMsgMain(COMMDIO_MSG_LOG, 0, 0,  'Probe move  Channel 2 Finish - Already');
      end
      else begin
        for i := 0 to nWaitingCount do begin
          Sleep(100);
          if (not ReadInSig(DefDio.IN_X_AXIS_SEN2)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) then begin
            SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('Probe Move Channel 2 OK. Step=%d', [i]));
            break;
          end;
        end;
      end;
      if (ReadInSig(DefDio.IN_X_AXIS_SEN2)) or (ReadInSig(DefDio.IN_X_AXIS_SEN3)) then Exit(3);
    end;
    DefDio.PROBE_CH3 : begin
      WriteDioSig(DefDio.OUT_X_POSITION_3);
      WriteDioSig(DefDio.OUT_X_POSITION_4);
      if (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN4)) then begin
        SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Probe move  Channel 3 Finish - Already');
      end
      else begin
        for i := 0 to nWaitingCount do begin
          Sleep(100);
          if (not ReadInSig(DefDio.IN_X_AXIS_SEN3)) and (not ReadInSig(DefDio.IN_X_AXIS_SEN4)) then begin
            SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('Probe Move Channel 3 OK. Step=%d', [i]));
            break;
          end;
        end;
      end;
      if (ReadInSig(DefDio.IN_X_AXIS_SEN3)) or (ReadInSig(DefDio.IN_X_AXIS_SEN4)) then Exit(4);
    end;
  end;

  // Probe Down.
  if bIsUpDown then begin
    SendMsgMain(COMMDIO_MSG_LOG, 0, 0,'Probe Down Start');
    ClearOutDioSig(DefDio.OUT_Z_POSITION_UP);
    WriteDioSig(DefDio.OUT_Z_POSITION_DN);
    if not ReadInSig(DefDio.IN_Z_DOWN_SEN) then begin
      SendMsgMain(COMMDIO_MSG_LOG, 0, 0,  'Probe Down Finish - Already');
    end
    else begin
      WriteDioSig(DefDio.OUT_Z_POSITION_DN);
      for i := 0 to nWaitingCount do begin
        Sleep(100);
        if not ReadInSig(DefDio.IN_Z_DOWN_SEN) then begin
          SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format( 'Probe Down OK. Step=%d', [i]));
          break;
        end;
      end;
    end;
  end;
  // 원하는 Channel로 이동.
//  if ReadInSig(DefDio.IN_Z_DOWN_SEN) then Exit(1);

  Result := 0;
end;



procedure TControlDio.tmrCycleTimer(Sender: TObject);
var
  bOn : Boolean;
  nIdx, nPos, i : Integer;
  nTick: Cardinal;
  nTowerLamp_R,nTowerLamp_G,nTowerLamp_Y,nTowerLamp_B1,nTowerLamp_B2 : Integer;
begin
  if not m_bConnected then Exit;

  if FIsFirstConnect then begin
    FIsFirstConnect := False;
    if ReadInSig(DefDio.IN_DOOR_OPEN_FR) and ReadInSig(DefDio.IN_DOOR_OPEN_FL) and
       ReadInSig(DefDio.IN_DOOR_OPEN_RR) and ReadInSig(DefDio.IN_DOOR_OPEN_RL) then  ProbeUpDown(True);
    for i := DefDio.OUT_PAT_ON_CH1 to DefDio.OUT_PAT_OFF_CH3 do WriteDioSig(i);
    WriteDioSig(DefDio.OUT_PAT_ON_START,True);
    WriteDioSig(DefDio.OUT_PAT_OFF_STOP,True);

    WriteDioSig(DefDio.OUT_INSPECTION_DONE);
    Sleep(10);
    if ReadInSig(DefDio.IN_DOOR_OPEN_FR) and ReadInSig(DefDio.IN_DOOR_OPEN_FL) and
       ReadInSig(DefDio.IN_DOOR_OPEN_RR) and ReadInSig(DefDio.IN_DOOR_OPEN_RL) then begin
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_FR);
      WriteDioSig(DefDio.OUT_DOOR_UNLOCK_FL);
    end;

    Set_TowerLampState(LAMP_STATE_REQUEST);
  end
  else begin
    // door가 닫혀 있으면 버튼 ON.
    if (CheckDi(DefDio.IN_DOOR_OPEN_FR)) and (CheckDi(DefDio.IN_DOOR_OPEN_FL)) then begin
      if not CheckDo(DefDio.OUT_PAT_ON_START) then WriteDioSig(DefDio.OUT_PAT_ON_START);
      if not CheckDo(DefDio.OUT_PAT_OFF_STOP) then WriteDioSig(DefDio.OUT_PAT_OFF_STOP);

      if CheckDo(DefDio.OUT_PAT_ON_CH1) then WriteDioSig(DefDio.OUT_PAT_ON_CH1,True);
      if CheckDo(DefDio.OUT_PAT_ON_CH2) then WriteDioSig(DefDio.OUT_PAT_ON_CH2,True);
      if CheckDo(DefDio.OUT_PAT_ON_CH3) then WriteDioSig(DefDio.OUT_PAT_ON_CH3,True);
      if CheckDo(DefDio.OUT_PAT_OFF_CH1) then WriteDioSig(DefDio.OUT_PAT_OFF_CH1,True);
      if CheckDo(DefDio.OUT_PAT_OFF_CH2) then WriteDioSig(DefDio.OUT_PAT_OFF_CH2,True);
      if CheckDo(DefDio.OUT_PAT_OFF_CH3) then WriteDioSig(DefDio.OUT_PAT_OFF_CH3,True);
      FIsDoorOpen := True;
    end
    // Door가 하나라도 열려 있으면 Button Off.
    else begin
      if CheckDo(DefDio.OUT_PAT_ON_START) then WriteDioSig(DefDio.OUT_PAT_ON_START,True);
      if CheckDo(DefDio.OUT_PAT_OFF_STOP) then WriteDioSig(DefDio.OUT_PAT_OFF_STOP,True);

      if not CheckDo(DefDio.OUT_PAT_ON_CH1) then WriteDioSig(DefDio.OUT_PAT_ON_CH1);
      if not CheckDo(DefDio.OUT_PAT_ON_CH2) then WriteDioSig(DefDio.OUT_PAT_ON_CH2);
      if not CheckDo(DefDio.OUT_PAT_ON_CH3) then WriteDioSig(DefDio.OUT_PAT_ON_CH3);
      if not CheckDo(DefDio.OUT_PAT_OFF_CH1) then WriteDioSig(DefDio.OUT_PAT_OFF_CH1);
      if not CheckDo(DefDio.OUT_PAT_OFF_CH2) then WriteDioSig(DefDio.OUT_PAT_OFF_CH2);
      if not CheckDo(DefDio.OUT_PAT_OFF_CH3) then WriteDioSig(DefDio.OUT_PAT_OFF_CH3);
      FIsDoorOpen := False;
      FIsScriptWorking := False;
    end;
    if (CheckDi(DefDio.IN_MC_MONITOR)) then begin
      bOn := False; // 알람이 있는지 체크.
      for i := 0 to DefDio.ERR_LIST_MAX do begin
        if AlarmData[i] <> 0 then begin
          bOn := True;
          Break;
        end;
      end;
      if not bOn then begin
        if PasScrMain <> nil then begin
          if PasScrMain.IsScriptRun then begin
            Set_TowerLampState(LAMP_STATE_AUTO);
            if not CheckDo(DefDio.OUT_LAMP_WORKER_OFF) then WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF);
            FIsScriptWorking := True;
          end
          else begin
            if FIsScriptWorking then begin
              Set_TowerLampState(LAMP_STATE_PAUSE);
              if CheckDo(DefDio.OUT_LAMP_WORKER_OFF) then WriteDioSig(DefDio.OUT_LAMP_WORKER_OFF,True);
            end
            else begin
              Set_TowerLampState(LAMP_STATE_REQUEST);
            end;
          end;
        end;
      end
      else begin
        if not MelodyOn then begin
          CommDaeDIO.SetMelodyOff := True;
          if CheckDo(DefDio.OUT_MELODY_1) then WriteDioSig(DefDio.OUT_MELODY_1,True);
          if CheckDo(DefDio.OUT_MELODY_2) then WriteDioSig(DefDio.OUT_MELODY_2,True);
          if CheckDo(DefDio.OUT_MELODY_3) then WriteDioSig(DefDio.OUT_MELODY_3,True);
          if CheckDo(DefDio.OUT_MELODY_4) then WriteDioSig(DefDio.OUT_MELODY_4,True);
        end
        else begin
          CommDaeDIO.SetMelodyOff := False;
        end;
        // 에러 발생시 점멸 Red.
        Set_TowerLampState(LAMP_STATE_ERROR);
      end;
      // For Temp Plate.
      if CommTempPlate <> nil then begin
        if ReadInSig(DefDio.IN_HC_PLATE_ALARM) then CommTempPlate.ResetAlarm := True;
      end;
    end
    else begin
      // MC Monitor 떨어지면
      Set_TowerLampState(LAMP_STATE_EMEGENCY);
      CommDaeDIO.SetMelodyOff := not MelodyOn;
      if not MelodyOn then begin
        CommDaeDIO.SetMelodyOff := True;
        if CheckDo(DefDio.OUT_MELODY_1) then WriteDioSig(DefDio.OUT_MELODY_1,True);
        if CheckDo(DefDio.OUT_MELODY_2) then WriteDioSig(DefDio.OUT_MELODY_2,True);
        if CheckDo(DefDio.OUT_MELODY_3) then WriteDioSig(DefDio.OUT_MELODY_3,True);
        if CheckDo(DefDio.OUT_MELODY_4) then WriteDioSig(DefDio.OUT_MELODY_4,True);
      end
      else begin
        CommDaeDIO.SetMelodyOff := False;
      end;


    end;
  end;

  m_bDoorOpen := not (ReadInSig(DefDio.IN_DOOR_OPEN_FR) and ReadInSig(DefDio.IN_DOOR_OPEN_FL));
end;

procedure TControlDio.Process_ChangedDI(pDataMessage: PGuiDaeDio);
var
  saIems: TArray<String>;
  i, k, nIndex, nValue, nCh: Integer;
  nPos: Integer;
begin
  //변경 값 검사
  saIems:= pDataMessage.Msg.Split([',']);
  for i := 0 to Length(saIems)-1 do begin
    nPos:= Pos('=', saIems[i]);
    if nPos < 1 then Continue;

    nIndex:= StrToInt(Copy(saIems[i], 1, nPos-1));
    nValue:= StrToInt(Copy(saIems[i], nPos+1, 5));

    if nValue <> 0 then begin
      case nIndex of
        DefDio.IN_SW_ON_CH1   : PasScr[DefCommon.CH1].RunSeq(DefScript.SEQ_KEY_PWR1_ON);
        DefDio.IN_SW_ON_CH2   : PasScr[DefCommon.CH1+1].RunSeq(DefScript.SEQ_KEY_PWR2_ON);
        DefDio.IN_SW_ON_CH3   : PasScr[DefCommon.CH1+2].RunSeq(DefScript.SEQ_KEY_PWR3_ON);
        DefDio.IN_SW_OFF_CH1  : PasScr[DefCommon.CH1].RunSeq(DefScript.SEQ_KEY_PWR1_OFF);
        DefDio.IN_SW_OFF_CH2  : PasScr[DefCommon.CH1+1].RunSeq(DefScript.SEQ_KEY_PWR2_OFF);
        DefDio.IN_SW_OFF_CH3  : PasScr[DefCommon.CH1+2].RunSeq(DefScript.SEQ_KEY_PWR3_OFF);
        DefDio.IN_SW_ON_ALLCH : begin
          if PasScrMain.ScriptRunning(DefScript.SEQ_KEY_9) then Exit;
          PasScrMain.InitialData;
          for nCh := 0 to DefCommon.MAX_JIG_CH do begin
            PasScrMain.TestInfo.IsPowerOn[nCh] := Pg[nCh].m_bPowerOn;// PasScr[nCh].TestInfo.PowerOn;
          end;
          PasScrMain.RunSeq(DefScript.SEQ_KEY_9);
        end;
        DefDio.IN_SW_OFF_ALLCH : PasScrMain.RunSeq(DefScript.SEQ_KEY_STOP);
      end; //case nIndex of
    end;
  end; //for i := 0 to Length(saIems) do begin
end;

function TControlDio.ReadInSig(nSignal: Integer): Boolean;
var
  nIdx, nPos : Integer;
begin
  if nSignal > 95  then begin
    Result := false;
    Exit;
  end;
  nIdx := nSignal div 8; nPos := nSignal mod 8;
  Result := (CommDaeDIO.DIData[nIdx] and (1 shl nPos)) > 0;
end;

function TControlDio.ReadOutSig(nSignal: Integer): Boolean;
var
  nIdx, nPos : Integer;
begin
  if nSignal > 95  then begin
   Result := false;
   Exit
  end;
  nIdx := nSignal div 8; nPos := nSignal mod 8;
  Result := (CommDaeDIO.DODataFlush[nIdx] and (1 shl nPos)) > 0;
end;

procedure TControlDio.RefreshIo;
var
  nMode : Integer;
  bStageACam, bStageBCam : Boolean;
begin

  //ErrorCheck;
//  bStageACam := ReadInSig(DefDio.IN_A_STAGE_IN_CAM);
//  bStageBCam := ReadInSig(DefDio.IN_B_STAGE_IN_CAM);
//  if bStageACam then        LoadZoneStage := lzsB
//  else if bStageBCam then   LoadZoneStage := lzsA
//  else                      LoadZoneStage := lzsNone;
//  nMode := CommDIO_DAE.COMMDIO_MSG_CHANGE_DI;
//  SendMsgMain(nMode,0,0,'');
//  nMode := CommDIO_DAE.COMMDIO_MSG_CHANGE_DO;
//  SendMsgMain(nMode,0,0,'');

end;

// nIdx : 0 - All.
// nIdx : 1 - Only Error Check part for In IO. ( <= ERR_LIST_MC_MONITOR )
procedure TControlDio.ResetError(nIdx : Integer);
var
  i, nDiv, nMod : Integer;
  bRet : boolean;
  nTemp : Integer;
begin
  nTemp := 0;
  case  nIdx of
    0 : begin
      for i:= 0 to DefDio.ERR_LIST_MAX do AlarmData[i] := 0;
    end;
    1 : begin
      for i := 0 to DefDio.IN_MAX do AlarmData[i] := 0;
    end;
    2 : begin
      for i := 0 to Pred(DefDio.ERR_LIST_MAX) do begin
        nTemp := nTemp + AlarmData[i];
      end;
      // if 화면에 NG 화면 있으면 닫자.
      if nTemp = 0 then SetAlarmMsg(-1,True);
    end;
  end;



  bRet := True;
end;

procedure TControlDio.SendAlarm(nType, nIndex, nValue: Integer; sMsg:String);
begin
  //기존 상태와 동일할 경우 전송하지 않음
  if Self.AlarmData[nIndex] = nValue then Exit;
  Self.AlarmData[nIndex] := nValue;
  if nType = MSG_MODE_SYSTEM_ALARAM then begin
    SendMsgMain(CtrlDio_Tls.MSG_MODE_SYSTEM_ALARAM, nIndex, nValue, sMsg);
  end
  else begin
    SendMsgMain(CtrlDio_Tls.MSG_MODE_DISPLAY_ALARAM, nIndex, nValue, sMsg);
  end;
end;

procedure TControlDio.SendMsgMain(nMsgMode, nParam, nParam2: Integer; sMsg: String; pData: Pointer);
var
  cds         : TCopyDataStruct;
  COPYDATAMessage : RGuiDaeDio;
begin
  COPYDATAMessage.MsgType := m_nMsgType; //MSGTYPE_COMMDIO;
  COPYDATAMessage.Channel := 1;
  COPYDATAMessage.Mode    := nMsgMode;
  COPYDATAMessage.Param   := nParam;
  COPYDATAMessage.Param2  := nParam2;
  COPYDATAMessage.Msg     := sMsg;
  COPYDATAMessage.pData   := pData;

  cds.dwData      := 0;
  cds.cbData      := SizeOf(COPYDATAMessage);
  cds.lpData      := @COPYDATAMessage;
  SendMessage(m_hMain,WM_COPYDATA,0, LongInt(@cds));
end;

procedure TControlDio.SetAlarmMsg(nIdx: Integer; bIsDisplayMessage : Boolean);
var
  nDiv, nMod : Integer;
  nValue: Integer;
  bValue: Boolean;
begin
  if nIdx < 0 then begin
    if bIsDisplayMessage then begin
      SendMsgMain(CtrlDio_Tls.MSG_MODE_DISPLAY_ALARAM, nIdx,0,'');
    end;
  end
  else begin
//    nDiv := nIdx div 8;
//    nMod := nIdx mod 8;
//    bValue:= (DioAlarmData[nDiv] and ($01 shl nMod)) <> 0;
    if bValue then begin
      //이미 발생한 알람 일경우
      Exit;
    end;
    if bIsDisplayMessage then begin
      SendMsgMain(CtrlDio_Tls.MSG_MODE_DISPLAY_ALARAM, nIdx,0,'');
    end;
  end;
end;

procedure TControlDio.SetIonizerNg(nCh, nIdxNg: Integer);
var
  nNgSet : Integer;
begin
  // nIdxNg ==> 0 : NG, 1 : OK, 2 : None ==> OK.
  nNgSet := 0;
  if nIdxNg = 0 then nNgSet := 1;
  Self.AlarmData[DefDio.ERR_LIST_IONIZER_STATUS_NG_CH1 + nCh] := nNgSet;
end;

procedure TControlDio.Set_TowerLampState(nState: Integer);
begin
  m_nTowerLampState:= nState;
  CommDaeDIO.Set_TowerLampState(nState);
end;

procedure TControlDio.TaskThread(task: TProc);
var
  th : TThread;
begin
  if m_bIoThreadWork then Exit;
  m_bIoThreadWork := True;
  th := TThread.CreateAnonymousThread(task);
  th.OnTerminate := TaskThreadTerminiate;
  th.Start;
end;
//
//procedure TControlDio.ThreadTurnStage;
//var
//  i, nRet : Integer;
//  sDebug : string;
//begin
//  //Turn 처리
//  TThread.CreateAnonymousThread( procedure begin
//    if LoadZoneStage = lzsB then begin
//      nRet:= TurnStage(True);
//    end
//    else begin
//      nRet:= TurnStage(False);
//    end;
//    if nRet <> 0 then begin
//      //Turn NG - 중알람
//      case nRet of
//        2: begin //ContactUp NG
//          SendAlarm(MSG_MODE_SYSTEM_ALARAM, IN_POGO_DN_SENSOR_1CH, 1, '');
//        end;
//        3: begin //Shutter Up NG
//          SendAlarm(MSG_MODE_SYSTEM_ALARAM, IN_SHUTTER_UP_SENSOR, 1, '');
//        end;
//        4, 5: begin //TurnTable  NG
//          SendAlarm(MSG_MODE_SYSTEM_ALARAM, IN_B_STAGE_IN_CAM, 1, '');
//        end;
//        7: begin //Shutter Down NG
//          SendAlarm(MSG_MODE_SYSTEM_ALARAM, IN_SHUTTER_DN_SNENSOR, 1, '');
//        end;
//        8: begin //Motor Stop Sensor NG
//          SendAlarm(MSG_MODE_SYSTEM_ALARAM, IN_MORTOR_STOP_SENSOR, 1, '');
//        end;
//      end;
//    end;
//  end).Start;
//end;

procedure TControlDio.TaskThreadTerminiate(Sender: TObject);
begin
  //Finish Turn Thread
  m_bIoThreadWork := False;
end;

procedure TControlDio.test;
begin
end;
//
//function TControlDio.TurnStage(bIsAStage: Boolean): Integer;
//var
//  i: Integer;
//  nWaitingCount: Integer;
//begin
//  //if ErrorCheck > 0 then Exit(1);
//  Result:= 0;
//
//  nWaitingCount:= 100;

//
//  // Clamp Down 신호만 체크 하자. True....
//  // A Stage. 1,2,3,4 Channel. Load Carrier.
//  if ContactUp(DefCommon.CH_STAGE_A,True) <> 0 then Exit(2);
//  // B Stage 5,6,7,8 Channel. Load Carrier.
//  if ContactUp(DefCommon.CH_STAGE_B,True) <> 0 then Exit(2);
//
//  // Turn  시작 Work Lamp ON.
//  WriteDioSig(DefDio.OUT_WORKER_LAMP);
//
//  Sleep(200); //for MovingShutter
//
//  if MovingShutter(True) <> 0 then Exit(3);
//
//  if bIsAStage then begin
//    m_PreLoadZoneStage := lzsA;
//  end
//  else begin
//    m_PreLoadZoneStage := lzsB;
//  end;
//

//
//    if not ReadInSig(DefDio.IN_MORTOR_STOP_SENSOR) then begin
//      //모터 회전 후 On되지 않으면 센서 고장
//      ClearOutDioSig(DefDio.OUT_B_STAGE_FRONT);
//      SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Motor Stop Sensor NG - 2');
//      Exit(8);  //Motor Stop Sensor NG
//    end;
//
//    for i := 0 to Common.SystemInfo.IndexMotor_Timeout do begin //보통 18 ~ 20 번째 꺼짐 인식
//      if not ReadInSig(DefDio.IN_SHUTTER_UP_SENSOR) then begin
//        ClearOutDioSig(DefDio.OUT_B_STAGE_FRONT);
//        Exit(3); //회전 중 shutter 꺼질경우 알람 발생
//      end;
//
//      Sleep(100);
//      //미리 끄면 안됨. Motor Stop 후 Clear DO
//      if not ReadInSig(DefDio.IN_MORTOR_STOP_SENSOR) then begin
//        SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('Motor Stop Sensor OFF - Step=%d', [i]));
//        Break;
//      end;
//    end;
//
//    ClearOutDioSig(DefDio.OUT_B_STAGE_FRONT);
//    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Clear DO Stage Front B');
//
//
//    if ReadInSig(DefDio.IN_MORTOR_STOP_SENSOR) then begin
//      SendMsgMain(COMMDIO_MSG_LOG, 0, 0, 'Motor Stop Sensor Timeout - Count: ' + IntToStr(Common.SystemInfo.IndexMotor_Timeout));
//      Exit(8);  //Motor Stop Sendsor NG
//    end;
//
//    if not ReadInSig(DefDio.IN_A_STAGE_IN_CAM) then begin
//      Exit(5);
//    end;
//
//  end;
//  Sleep(200); //for MovingShutter
//
//  m_PreLoadZoneStage := lzsNone;
//  if MovingShutter(False) <> 0 then Exit(7);
//  // Turn 완료 후 Work Lamp Off.
//  ClearOutDioSig(DefDio.OUT_WORKER_LAMP);
//(*
//  if ReadInSig(DefDio.IN_A_STAGE_IN_CAM) then begin
//    if ContactDown(DefCommon.CH_STAGE_B) <> 0 then Exit(2);
//  end
//  else begin
//    if ContactDown(DefCommon.CH_STAGE_A) <> 0 then Exit(2);
//  end;
//*)
//  //CAM Zone, UnloadZone 처리 필요
//  if bIsAStage then begin
//    SendMsgMain(MSG_MODE_STAGE_TURN, 2, 0, 'Stage Turn Finish Front A');
//  end
//  else begin
//    SendMsgMain(MSG_MODE_STAGE_TURN, 3, 0, 'Stage Turn Finish Front B');
//  end;
//end;

function TControlDio.WriteDioSig(nSignal: Integer; bIsRemove: Boolean): Integer;
var
  nIdx, nPos, nValue : Integer;
  nRet: Integer;
begin
  if not (nSignal in [DefDio.OUT_LAMP_RED,DefDio.OUT_LAMP_YELLOW, DefDio.OUT_MELODY_1, DefDio.OUT_MELODY_2, DefDio.OUT_MELODY_3, DefDio.OUT_MELODY_4, DefDio.OUT_LAMP_WORKER_OFF ]) then  begin
    //if ErrorCheck > 0 then Exit(1);
    if m_bDoorOpen then Exit;
  end;

  nIdx := nSignal div 8; nPos := nSignal mod 8;
  if bIsRemove then nValue := 0
  else              nValue := 1;
  if nSignal in [DefDio.OUT_DOOR_UNLOCK_FR .. DefDio.OUT_DOOR_UNLOCK_RL] then begin
    if not bIsRemove then begin

    end;
  end;

  CommDaeDIO.WriteDO_Bit(nIdx,nPos,nValue);
  DisplayIo;
  Result := 0;
end;


function TControlDio.WaitSignal(nIndex, nValue: Byte; nWaitTime: Cardinal): Cardinal;
var
  nTick, nStartTick: Cardinal;
  nAddr, nBitLoc: Byte;
begin
  Result:= 1;
  nAddr:= nIndex div  8;
  nBitLoc:= nIndex mod 8;
  nStartTick:= GetTickCount;
  nTick:= nStartTick;

  while (nTick - nStartTick) < nWaitTime  do begin
    if CommDaeDIO.Get_Bit(CommDaeDIO.DIData[nAddr], nBitLoc) = nValue then begin
      Result:= 0;
      break;
    end;
    Sleep(10);
    nTick:= GetTickCount;
  end;
end;


procedure TControlDio.CommDIONotify(Sender: TObject; pDataMessage: PGuiDaeDio);
var
  nMode, nParam, nRet : Integer;
  bStageACam, bStageBCam : Boolean;
  i: Integer;
begin
  nMode := pDataMessage^.Mode;
  nRet := 0;

  case nMode of
    CommDIO_DAE.COMMDIO_MSG_CONNECT : begin
      nParam := pDataMessage^.Param;
      if nParam <> 0 then begin
        m_bConnected := True;
        CheckAlarm; //알람 확인
      end
      else begin
        m_bConnected := False;
      end;

      PostMessage(m_hMain,WM_USER+1, nMode, nParam); //DIO 갱신 요청
    end;  //CommDIO_DAE.COMMDIO_MSG_CONNECT : begin

    CommDIO_DAE.COMMDIO_MSG_CHANGE_DI : begin
      if m_bConnected then  begin
        CheckAlarm; //알람 확인

        //변경된 값 처리
        Process_ChangedDI(pDataMessage);
        PostMessage(m_hMain,WM_USER+1, nMode, 0); //DIO 갱신 요청
      end;
   
    end; //CommDIO_DAE.COMMDIO_MSG_CHANGE_DI : begin

    CommDIO_DAE.COMMDIO_MSG_CHANGE_DO : begin
      CheckAlarm; //알람 확인
      PostMessage(m_hMain,WM_USER+1, nMode, 0);
      //ErrorCheck;
    end;
    CommDIO_DAE.COMMDIO_MSG_ERROR : begin
      if pDataMessage.Param = 100 then begin
        LastNgMsg := 'Disconnected DIO Card....';
        SendAlarm(MSG_MODE_SYSTEM_ALARAM, ERR_LIST_DIO_CARD_DISCONNECTED, 1, LastNgMsg);
        m_bConnected := False;
      end;
    end; //CommDIO_DAE.COMMDIO_MSG_ERROR : begin
  end;
  if m_bConnected then begin
    // Main GUI에 상태 Display.
    SendMsgMain(nMode,pDataMessage^.Param,pDataMessage^.Param2,pDataMessage^.Msg);
  end;
end;

end.
