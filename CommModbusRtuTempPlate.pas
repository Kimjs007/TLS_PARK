unit CommModbusRtuTempPlate;

interface
uses
  Winapi.Windows, Winapi.Messages, Winapi.WinSock, System.SysUtils,  System.Classes, VaComm, SyncObjs, Vcl.ExtCtrls;
const
  COMM_MODBUS_TEMP_PLATE_CONNECT  = 0;
  COMM_MODBUS_TEMP_PLATE_SV       = 1;    // Setting 온도값.
  COMM_MODBUS_TEMP_PLATE_PV       = 2;    // Current 온도값.
  COMM_MODBUS_TEMP_PLATE_MV       = 3;    // .
  COMM_MODBUS_TEMP_PLATE_Bias     = 4;    // Bias - 온도에 대한 Offset값.
  COMM_MODBUS_TEMP_PLATE_HEATING  = 5;
  COMM_MODBUS_TEMP_PLATE_COOLING  = 6;

  COMM_MODBUS_TEMP_PLATE_ADDLLOG  = 100;

  COMM_MODBUS_READ_MULTI_FUNC     = $03;
  COMM_MODBUS_WRITE_MULTI_FUNC    = $10;

  COMM_MODBUS_TEMP_PLATE_SEND_CMD = 0;
  COMM_MODBUS_TEMP_PLATE_RECV_OK  = 1;
  COMM_MODBUS_TEMP_PLATE_RECV_NG  = 2;
  COMM_MODBUS_TEMP_PLATE_NO_RES   = 3;

  COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM  = 0;
  // Plate Num - Channel Num와 동일 -- Channel 처럼 쓰겠음.  1부터 쓰니깐 조심.
  COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1  = 1;
  COMM_MODBUS_TEMP_PLATE_TYPE_PLATE2  = 2;
  COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3  = 3;

type
//  {$IFNDEF GUIMessage}
//    {$DEFINE GUIMessage}
    /// <summary> GUI Message for WM_COPYDATA </summary>
  TGUIModbusRtuTempPlateMessage = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    Param  : Integer;
    Param2 : Integer;
    Msg     : string;
    pData   : PBYTE; //Pointer; //Length = Param2
  end;
  PGUIThermometerMessage = ^TGUIModbusRtuTempPlateMessage;
//  {$ENDIF}

  TTempPlateSatus = record
    CmdSatus : Integer;
    SystemSatus : array[0..3] of Boolean;
    ChillerStatus : array[0..3] of Boolean;
    ChillerAlarm  : array[0..9] of Boolean;
    SystemAlarm : array[0..4] of Boolean;
    PlatesAlarm : array[0..7] of Boolean;
    Heating     : Boolean;
    Cooling     : Boolean;
    Sv, Pv, Mv  : Word;
  end;

  TRxModBusData = record
		// RX
    Address   : Integer;
    CmdStatus : Integer;
    AckNack   : Integer;
    RxDataLen : Integer;
    RxData    : array [0..100] of byte;
    RxPrevStr : string;
	end;

  ///<summary>
  /// 온도 센서 Autonix TK 시리즈 통신 클래스by kg.jo 20220711
  /// 장비: T 시리즈
  /// 프로토콜문서: TK 통신메뉴얼.pdf. modbus 통신 기반
  ///  온도 값 영역 301001(03E8) 현재 측정 값
  ///</summary>
  TCommModbusRtuTempPlateMessage = class
  private
    m_VaComm : TVaComm;
    m_tmrCycle: TTimer;
    m_hMain         : THandle;
    m_nMsgType      : Integer;
    m_nTimeoutCount : Integer; //데이터 응답 없음
    m_Buff          : TBytes;
    m_nBuffCount    : Integer;
    FbThreadWork    : boolean;

    FbWaitEvent     : Boolean;
    FhEvent         : HWND;
    FRxTempPlate    : TRxModBusData;

    FHeartBeat      : Boolean;
    FnSystemStatus  : Integer;
    FnChangeStatus  : Integer;
    FnChillerTemp   : Integer;
    FnPlateStatus   : array[COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 .. COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of Integer;
    FnPlateSetValue : array[COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 .. COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of Integer;
    FResetAlarm: Boolean;
    FSetMainterMode: Boolean;
    FSetAutoCtrl: Boolean;

    procedure VaCommRxChar(Sender: TObject; Count: Integer);
    procedure tmrCycleTimer(Sender: TObject);
    procedure SendMessageMain(nMode, nParam, nParam2: Integer; sMsg: String);
    procedure AddLog(sLog: String);
    procedure MuiltRead( wId, wAddr, wNum : Word);
    procedure MultiWrite( wId, wAddr, wNum : Word;data : TArray<Word>);
    function WriteData(wId, wAddr, wNum : Word;data : TArray<Word>): Boolean;
    function CheckCmdAck(Task: TProc; nAddress: Integer; nWaitMS,nRetry: Integer): DWORD;

    procedure LookForTheRet ( nType : Integer );
    procedure LookForStatus ( nType, nStatus : Integer; btStatus1, btStatus2 : Byte);

    procedure TaskThreadWorks;
    procedure SetResetAlarm(const Value: Boolean);
    procedure CheckAlarm;
    procedure SetSetMainterMode(const Value: Boolean);
    procedure SetSetAutoCtrl(const Value: Boolean);
  public
    Connected: Boolean; //연결 여부
    CurrentValue : Double; //읽은 값
    State: Byte; //현재 상태
  public
    CurrentStatus :  array[COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM  .. COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TTempPlateSatus;

    constructor Create(hMain :THandle; nMsgType: Integer; nInterval: Integer); virtual;
    destructor Destroy; override;
    function Connect(nPort: Integer): boolean;
    procedure Disconnect;
    function SendBuf(AData: array of Byte; ASize: Integer): Integer;

    function ReadData( btId, btAddr : Word; btNum  : byte) : Boolean;

    procedure SetSystemStatus(nMode : Integer);
    procedure SetChillerSv(Value : Integer);
    procedure SetPlateStatus(nCh, nMode : Integer);
    procedure SetPlateSV(nCh, value : Integer);

    procedure ReadAllData;
    procedure WriteAllData;

    property ResetAlarm : Boolean read FResetAlarm write SetResetAlarm;
    property SetMainterMode : Boolean read FSetMainterMode write SetSetMainterMode;
    property SetAutoCtrl : Boolean read FSetAutoCtrl write SetSetAutoCtrl;
  end;

var
  CommTempPlate: TCommModbusRtuTempPlateMessage;
  function CalcCRC16(const AData: array of Byte; ASize: Integer): Word;
  function GetCRC16(const AData:pointer; ASize:integer):word; overload;
  function GetCRC16(const AText:string):word; overload;
  function BufferToHex(const AData: Pointer; nCount: Integer): String;

implementation

{ TCommThermometer }

procedure TCommModbusRtuTempPlateMessage.AddLog(sLog: String);
begin
  SendMessageMain(COMM_MODBUS_TEMP_PLATE_ADDLLOG, 0, 0, sLog);
end;

constructor TCommModbusRtuTempPlateMessage.Create(hMain :THandle; nMsgType: Integer; nInterval: Integer);
var
  i : Integer;
begin
  m_hMain:= hMain;
  m_nMsgType:= nMsgType;
  FbThreadWork := False;
  FResetAlarm  := True;
  m_VaComm := TVaComm.Create(nil);
  m_VaComm.Baudrate:= br19200; //
  m_VaComm.Parity:= paNone;
  m_VaComm.Databits:= db8;
  m_VaComm.Stopbits:= sb1;
  m_VaComm.SyncThreads:= False;  //Not GUI Sync
  FSetMainterMode := False;
  m_VaComm.OnRxChar:= VaCommRxChar;

  SetLength(m_Buff, 100);
  m_nBuffCount:= 0;
  FnChangeStatus := 0;

  m_tmrCycle:= TTimer.Create(nil);
  m_tmrCycle.Enabled:= False;
  m_tmrCycle.OnTimer:= tmrCycleTimer;
  m_tmrCycle.Interval:= nInterval;

  // value default
  FHeartBeat := False;
  FnSystemStatus := 0;
  FnChillerTemp  := 0;
  for i := COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    FnPlateStatus[i]    := 0;
    FnPlateSetValue[i]  := 250;
  end;

//  for i := COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
//
//  end;
//
//   FnOldData, FnNewData : array[COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM  .. COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of Integer;

  Connected:= False;
  AddLog('Create');
end;

destructor TCommModbusRtuTempPlateMessage.Destroy;
var
  i: Integer;
begin
  Disconnect;

  if FbWaitEvent then begin
    FbWaitEvent := False;
    SetEvent(FhEvent);
  end;
  for i := 0 to 1000 do begin
    Sleep(10);
    if not FbThreadWork then Break;
  end;

  Sleep(100);

  if m_tmrCycle <> nil then begin
    m_tmrCycle.Free;
    m_tmrCycle := nil;
  end;

  FreeAndNil(m_VaComm);

  inherited;
  AddLog('Destroy');
end;

procedure TCommModbusRtuTempPlateMessage.CheckAlarm;
var
  nPos, i : Integer;
  bRet : Boolean;
begin
  if FSetMainterMode then Exit;
  if not FSetAutoCtrl then Exit;

  if FResetAlarm then begin
    nPos := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM;
    // system : send Reset ==> wait for Ready signal ==> send run when the signal is ready.
    case CurrentStatus[nPos].CmdSatus of
      0 : begin  // ready. ==> run으로.
        FnSystemStatus := 1;
        FnChangeStatus := 1; // // ready. ==> run 되었다는 Flag.
      end;
      1 : begin  // run.
        case FnChangeStatus of
          0 : begin
            FResetAlarm := False;
          end;
          1 : begin // Ready ==> Run ==> Plate Reset으로 처리.
            FnChangeStatus := 2;
            for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
              // Ready가 아니면 Stop으로 처리.
              if CurrentStatus[i].CmdSatus <> 0 then FnPlateStatus[i] := 2; // Reset..   알람 상태가 아니고 Run 상태이면 Stop 명령.
            end;
            Sleep(10);
          end;
          {          if btValue > 0 then begin
            case i of
              0 : AddLog('Plate Ready : Channel'+ nType.ToString);
              1 : AddLog('Plate Runing : Channel'+ nType.ToString);
              2 : AddLog('Plate Alarm : Channel'+ nType.ToString);
            end;
            CurrentStatus[nType].CmdSatus := i;



            plate 상태값
                CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 : begin
      if nStatus = 1 then begin
        for i := 0 to 2 do begin
          btValue := (btStatus1) and ($01 shl i);
          //btValue := (btStatus1 shr i) and $01;
          if btValue > 0 then begin
            case i of
              0 : AddLog('Plate Ready : Channel'+ nType.ToString);
              1 : AddLog('Plate Runing : Channel'+ nType.ToString);
              2 : AddLog('Plate Alarm : Channel'+ nType.ToString);
            end;
            CurrentStatus[nType].CmdSatus := i;
            }
          2 : begin // Ready ==> Run ==> Plate Reset으로 처리.
            FnChangeStatus := 3;
            bRet := True;
            for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
              // Ready가 아니면 Stop으로 처리.
              if CurrentStatus[i].CmdSatus <> 0 then  begin
                FnPlateStatus[i] := 2;   bRet := False;
              end;
            end;
            if not bRet then begin
              FnChangeStatus := 2;
            end;

            Sleep(10);
          end;
          3 : begin
            // all plates status is Ready.
            for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
              FnPlateStatus[i] := 1;
            end;
            FnChangeStatus   := 4;
            sleep(10);
          end;
          4 : begin
            FnChangeStatus   := 0;
            bRet := True;
            for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
              if CurrentStatus[i].CmdSatus <> 1 then begin
                bRet := False;// reay 상태면 처음부터...
              end;
            end;
            if not bRet then begin
              FnChangeStatus := 4;
            end;
          end;
        end;
      end;
      2 : begin  // Alaram.

        FnSystemStatus := 3;
        // 알람이면 Reset...
        FnChangeStatus := 0;
      end;
    end;
  end;
end;

function TCommModbusRtuTempPlateMessage.CheckCmdAck(Task: TProc; nAddress: Integer; nWaitMS, nRetry: Integer): DWORD;
var
	dwRtn : DWORD;
	i     : Integer;
  sEvent : string;
begin
  dwRtn := WAIT_FAILED;
	try
    // Create Event
    FbWaitEvent := True;
		sEvent      := Format('TxTempPlate%0.3d',[nAddress]);
		FhEvent     := CreateEvent(nil, False, False, PWideChar(sEvent));
		for i := 0 to nRetry do begin
      FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_SEND_CMD;
			Task;
      try
        dwRtn := WaitForSingleObject(FhEvent, nWaitMS);
        case dwRtn of
          WAIT_OBJECT_0 : begin
            if FRxTempPlate.CmdStatus = CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_OK then
              Break
            else
              dwRtn := WAIT_FAILED;
          end;
          WAIT_TIMEOUT : begin
            FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_NO_RES;
          end
          else begin
            Break;
          end;
        end;
      except
        Break;
      end;
    end;
	finally
    // Close Event
    FbWaitEvent := False;
    CloseHandle(FhEvent);
	end;
  Result := dwRtn;
end;

function TCommModbusRtuTempPlateMessage.Connect(nPort: Integer): boolean;
begin
  Result:= False;
  if nPort = 0 then begin
    SendMessageMain(COMM_MODBUS_TEMP_PLATE_CONNECT, 3, 0, 'NONE');
    Exit;
  end;

  if m_VaComm.Active then begin
    Exit;
  end;

  AddLog('Connecting...');
  try
    m_VaComm.Close;
    m_VaComm.PortNum:= nPort;
    m_VaComm.Open;

    Connected:= True;
    Result:= Connected;
//    m_tmrCycle.Tag:= 0; //1번 부터 시작
//    m_tmrCycle.Enabled:= True;
//    m_nTimeoutCount:= 0;
    SendMessageMain(COMM_MODBUS_TEMP_PLATE_CONNECT, 1, 0, 'COM' + IntToStr(nPort));
    TaskThreadWorks;
//    QueryData;
  except
    on E : Exception do begin
      SendMessageMain(COMM_MODBUS_TEMP_PLATE_CONNECT, 2, 0, E.Message);
    end;
  end;
end;

procedure TCommModbusRtuTempPlateMessage.Disconnect;
begin
  m_tmrCycle.Enabled:= False;
  m_VaComm.Close;
  if Connected then begin
    Connected:= False;
    SendMessageMain(COMM_MODBUS_TEMP_PLATE_CONNECT, 0, 0, 'Disconnected');
  end;
end;



procedure TCommModbusRtuTempPlateMessage.LookForStatus(nType, nStatus: Integer ; btStatus1, btStatus2 : Byte );
var
  i       : Integer;
  btValue : byte;
begin
  case nType of
    CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM : begin // For system.
      case nStatus of
        1 : begin   // system Status 000
          for i := 0 to 2 do begin
            btValue := (btStatus1) and ($01 shl i);
            if btValue > 0 then begin
              case i of
                0 : AddLog('System Ready');
                1 : AddLog('System Runing');
                2 : AddLog('System Alarm');
              end;
              CurrentStatus[nType].CmdSatus := i;
            end;
          end;
          for i := 3 to 6 do begin
            btValue := (btStatus1) and ($01 shl i);
            if btValue > 0 then begin
              case i of
                3 : AddLog('EMS State');
                4 : AddLog('MC State');
                5 : AddLog('Power State');
                6 : AddLog('Reset State');
              end;
              CurrentStatus[nType].SystemSatus[i-3] := True;
            end
            else begin
              CurrentStatus[nType].SystemSatus[i-3] := False;
            end;
          end;
          for i := 0 to 4 do begin
            btValue := (btStatus2) and ($01 shl i);
            if btValue > 0 then begin
              case i of
                0 : AddLog('EMS Alarm');
                1 : AddLog('Smoke Alarm');
                2 : AddLog('Power Lost Alarm');
                3 : AddLog('Chiler Alarm');
                4 : AddLog('Chiler CommError');
              end;
              CurrentStatus[nType].SystemAlarm[i] := True;
            end
            else begin
              CurrentStatus[nType].SystemAlarm[i] := False;
            end;
          end;
        end;
        2 : begin  // system Status 001
          for i := 0 to 3 do begin
            btValue := (btStatus1) and ($01 shl i);
            if btValue > 0 then begin
              case i of
                0 : AddLog('Chiller Ready');
                1 : AddLog('Chiller Runing');
                2 : AddLog('Chiller Alarm');
                3 : AddLog('Chiller Operated');
              end;
              CurrentStatus[nType].ChillerStatus[i] := True;
            end
            else
              CurrentStatus[nType].ChillerStatus[i] := False;
          end;
          for i := 6 to 7 do begin
            btValue := (btStatus1) and ($01 shl i);
            if btValue > 0 then begin
              case i of
                6 : AddLog('Chiller Phase Alarm');
                7 : AddLog('Chiller Heater Alarm');
              end;
              CurrentStatus[nType].ChillerAlarm[i-6] := True;
            end
            else
              CurrentStatus[nType].ChillerAlarm[i-6] := False;
          end;
          for i := 0 to 7 do begin
            btValue := (btStatus2) and ($01 shl i);
            if btValue > 0 then begin
              CurrentStatus[nType].ChillerAlarm[i+2] := True;
            end
            else
              CurrentStatus[nType].ChillerAlarm[i+2] := False;
          end;
        end;
      end;
    end;
    CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 : begin
      if nStatus = 1 then begin
        for i := 0 to 2 do begin
          btValue := (btStatus1) and ($01 shl i);
          //btValue := (btStatus1 shr i) and $01;
          if btValue > 0 then begin
            case i of
              0 : AddLog('Plate Ready : Channel'+ nType.ToString);
              1 : AddLog('Plate Runing : Channel'+ nType.ToString);
              2 : AddLog('Plate Alarm : Channel'+ nType.ToString);
            end;
            CurrentStatus[nType].CmdSatus := i;
          end;
        end;
        btValue := btStatus2 and $01;
        if btValue <> 0 then AddLog('Plate Heating : Channel'+ nType.ToString);
        CurrentStatus[nType].Heating := btValue <> 0;

        btValue := btStatus2 and $02;
        if btValue <> 0 then AddLog('Plate Cooling : Channel'+ nType.ToString);
        CurrentStatus[nType].Cooling := btValue <> 0;
      end;
      if nStatus = 2 then begin
        for i := 0 to 7 do begin
          //btValue := (btStatus1 shr i) and $01;
          btValue := (btStatus1) and ($01 shl i);
          if btValue > 0 then begin
            case i of
              0 : AddLog('1 Sensor Line Open Alarm : Channel'+ nType.ToString);
              1 : AddLog('2 Sensor Line Open Alarm : Channel'+ nType.ToString);
              2 : AddLog('3 Sensor Line Open Alarm : Channel'+ nType.ToString);
              3 : AddLog('4 Sensor Line Open Alarm : Channel'+ nType.ToString);
              4 : AddLog('OT Alarm : Channel'+ nType.ToString);
              5 : AddLog('Over heating Alarm : Channel'+ nType.ToString);
              6 : AddLog('Over Cooling Alarm : Channel'+ nType.ToString);
              7 : AddLog('Temperature range Alarm : Channel'+ nType.ToString);
            end;
            CurrentStatus[nType].PlatesAlarm[i] := True;
          end
          else begin
            CurrentStatus[nType].PlatesAlarm[i] := False;
          end;

        end;

      end;



    end;

  end;

end;

procedure TCommModbusRtuTempPlateMessage.LookForTheRet(nType: Integer);
var
  wValue, wData : Word;
  btValue : byte;
  i      : Integer;
  sLog   : string;
begin
  if FRxTempPlate.CmdStatus <> CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_OK then Exit;
  if FRxTempPlate.RxDataLen < 10 then Exit;

  LookForStatus(nType, 1, FRxTempPlate.RxData[1],FRxTempPlate.RxData[0]);
  LookForStatus(nType, 2, FRxTempPlate.RxData[3],FRxTempPlate.RxData[2]);
  case nTYpe of
    CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM : begin // For system.

      // Chiller SV (Setting Value)
      CopyMemory(@wData,@FRxTempPlate.RxData[4],2);
      wValue := htons(wData);
      sLog := Format('Chiller SV : %d',[wValue]) ;AddLog(sLog);
      CurrentStatus[nType].Sv := wValue;
      // Chiller PV
      CopyMemory(@wData,@FRxTempPlate.RxData[6],2);
      wValue := htons(wData);
      sLog := Format('Chiller PV : %d',[wValue]) ;AddLog(sLog);
      CurrentStatus[nType].Pv := wValue;
      // Chiller Flow(lpm
      CopyMemory(@wData,@FRxTempPlate.RxData[8],2);
      wValue := htons(wData);
      sLog := Format('Chiller Flow : %d',[wValue]) ;AddLog(sLog);
      CurrentStatus[nType].Mv := wValue;
    end;
    CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 : begin
      // Read SV(Setting Value)
      CopyMemory(@wData,@FRxTempPlate.RxData[4],2);
      wValue := htons(wData);
      sLog := Format('Read SV : %d',[wValue]) ;AddLog(sLog);
      CurrentStatus[nType].Sv := wValue;
      SendMessageMain(COMM_MODBUS_TEMP_PLATE_SV, nTYpe , wValue, '');
      // Avg Pv
      CopyMemory(@wData,@FRxTempPlate.RxData[6],2);
      wValue := htons(wData);
      sLog := Format('Avg PV : %d',[wValue]) ;AddLog(sLog);
      SendMessageMain(COMM_MODBUS_TEMP_PLATE_MV, nTYpe , wValue, '');
      CurrentStatus[nType].Pv := wValue;
      // Avg Mv
      CopyMemory(@wData,@FRxTempPlate.RxData[8],2);
      wValue := htons(wData);
      sLog := Format('Avg MV : %d',[wValue]) ;AddLog(sLog);
      CurrentStatus[nType].Mv := wValue;
      // Bias ==> Offset 같은 개념.
      if FRxTempPlate.RxDataLen > 11 then CopyMemory(@wValue,@FRxTempPlate.RxData[10],2);
    end;
  end;
end;

procedure TCommModbusRtuTempPlateMessage.MuiltRead(wId, wAddr, wNum: Word);
var
  TxBuf : array [0..100]of Byte;
  nTxIdx : Integer;
  wCrc: Word;
begin
  nTxIdx := 0;
  TxBuf[nTxIdx] := Byte($00ff and wId);               Inc(nTxIdx);
  TxBuf[nTxIdx] := COMM_MODBUS_READ_MULTI_FUNC;       Inc(nTxIdx);  //Function - Read Input Register
  TxBuf[nTxIdx] := Byte(($ff00 and wAddr) shr 8);     Inc(nTxIdx);  //Starting Address(Hi)
  TxBuf[nTxIdx] := Byte($00ff and wAddr);             Inc(nTxIdx);
  TxBuf[nTxIdx] := Byte($ff00 and wNum);              Inc(nTxIdx);  //Count (Hi)
  TxBuf[nTxIdx] := Byte($00ff and wNum);              Inc(nTxIdx);

  wCrc:= CalcCRC16(TxBuf, nTxIdx);// fn_makeCRC16_byte(TxBuf, nTxIdx);
  TxBuf[nTxIdx]:= Lo(wCrc); //$F1; //Lo(wCrc);  //CRC16 (Lo)
  TxBuf[nTxIdx+1]:= Hi(wCrc); //$BB; //hi(wCrc);  //CRC16 (Hi)
  nTxIdx := nTxIdx + 2;
  m_VaComm.WriteBuf(TxBuf, nTxIdx);
  //AddLog('Send: ' + BufferToHex(@TxBuf[0], nTxIdx));
  FRxTempPlate.Address := wAddr;
end;



procedure TCommModbusRtuTempPlateMessage.MultiWrite(wId, wAddr, wNum: Word; data: TArray<Word>);
var
  TxBuf : array [0..100]of Byte;
  nTxIdx, i : Integer;
  wCrc: Word;
begin
  nTxIdx := 0;
  TxBuf[nTxIdx] := Byte($00ff and wId);               Inc(nTxIdx);
  TxBuf[nTxIdx] := COMM_MODBUS_WRITE_MULTI_FUNC;  Inc(nTxIdx);  //Function - Write Input Register
  TxBuf[nTxIdx] := Hi(wAddr);                         Inc(nTxIdx);  //Starting Address(Hi)
  TxBuf[nTxIdx] := Lo(wAddr);                         Inc(nTxIdx);
  TxBuf[nTxIdx] := Hi(wNum);                          Inc(nTxIdx);  //Count (Hi)
  TxBuf[nTxIdx] := Lo(wNum);                          Inc(nTxIdx);
  TxBuf[nTxIdx] := Byte(Lo(wNum shl 1));              Inc(nTxIdx);
  for i := 0 to Pred(wNum) do begin
    TxBuf[nTxIdx] := Hi(data[i]);   Inc(nTxIdx);
    TxBuf[nTxIdx] := Lo(data[i]);   Inc(nTxIdx);
  end;

  wCrc:= CalcCRC16(TxBuf, nTxIdx);
  TxBuf[nTxIdx]   := Lo(wCrc); //$F1; //Lo(wCrc);  //CRC16 (Lo)
  TxBuf[nTxIdx+1] := Hi(wCrc); //$BB; //hi(wCrc);  //CRC16 (Hi)
  nTxIdx := nTxIdx + 2;
  m_VaComm.WriteBuf(TxBuf, nTxIdx);
  //AddLog('Send: ' + BufferToHex(@TxBuf[0], nTxIdx));
  FRxTempPlate.Address := wAddr;
end;

function TCommModbusRtuTempPlateMessage.ReadData(btId, btAddr: Word; btNum: byte) : Boolean;
begin
  m_nBuffCount := 0;
  MuiltRead(btId, btAddr,btNum);
end;

procedure TCommModbusRtuTempPlateMessage.ReadAllData;
var
  dwRet : DWORD;
  i: Integer;
begin
  // S
  dwRet := CheckCmdAck(procedure begin ReadData(0,0,5); end,0,1000,2);
  if dwRet = WAIT_OBJECT_0 then begin
    LookForTheRet(CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM);
  end;
  if not Connected then Exit;
  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    dwRet := CheckCmdAck(procedure begin ReadData(0,100*i,6); end,0,1000,2);
    if dwRet = WAIT_OBJECT_0 then begin
      LookForTheRet(i);
    end;
    if not Connected then break;
  end;
  if not Connected then Exit;
end;

procedure TCommModbusRtuTempPlateMessage.VaCommRxChar(Sender: TObject; Count: Integer);
var
  Buff: array [0..100]of Byte;
  wCrc: Word;
  wRecvCrc: Word;
  wValue: Word;
  nMod : Integer;
  nCount, nCountLimit: Byte;
  sTemp: string;
begin
  m_VaComm.ReadBuf(Buff, Count);
  //AddLog('Recv: ' + BufferToHex(@Buff[0], Count));
  CopyMemory(@m_Buff[m_nBuffCount], @Buff[0], Count);
  m_nBuffCount:= m_nBuffCount + Count;
  nMod := FRxTempPlate.Address mod 100;
  if nMod = 0 then begin   // for Read. ==> Read Address is 0, 100, 200, 300.
    if m_nBuffCount > 2 then begin
      nCount:= m_Buff[2];
      nCountLimit := nCount + 5;  // +5 + count. ( 국번 + Device + Length + CRC 2bytes ) is total bytes.
    end;

    // Ex.
    // Send: 00 03 00 {00 00} {05} 84 18 ==> {00 00} Address 0, {05} Data 5개 Read.
    // Recv: 00 03 {0A} {00 31} {00 00 } -00 00- /00 BC/ 00 00 {BE 42}
    //    {0A} DATA ==> Total Count,{00 31} System status1, {00 00 } status2,
    //    -00 00- : Chiller Read Sv,/00 BC/ : Chiler Pv, 00 00: Chiler Flow(lpm), {BE 42} CRC
    if m_nBuffCount >= nCountLimit then begin
      //Validation
      case m_Buff[1] of
        CommModbusRtuTempPlate.COMM_MODBUS_READ_MULTI_FUNC : begin
          nCount:= m_Buff[2];
          wCrc:= CalcCRC16(m_Buff, nCount + 3);
          CopyMemory(@wRecvCrc, @m_Buff[nCount + 3], 2);
          if wRecvCrc <> wCrc then begin
            //CRC 에러
            sTemp:= format('CRC Error: Recv %02x: Calc %02x', [wRecvCrc, wCrc]);
            AddLog(sTemp);
            FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_NG;
          end
          else begin
            //정상 패킷
            wValue:= m_Buff[3] * 256 + m_Buff[4];
            CurrentValue:= wValue * 0.1;
            m_nTimeoutCount:= 0;
            FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_OK;
          end;
          FRxTempPlate.RxDataLen := nCount;
          CopyMemory(@FRxTempPlate.RxData[0], @m_Buff[3], nCount);
          if FbWaitEvent then SetEvent(FhEvent);
          m_nBuffCount := 0;
        end;
      end;
    end;
  end
  else begin
    nCountLimit := 8;
    if m_nBuffCount >= nCountLimit then begin

      wCrc:= CalcCRC16(m_Buff, nCountLimit - 2 );
      CopyMemory(@wRecvCrc, @m_Buff[nCountLimit - 2], 2);
      if wRecvCrc <> wCrc then begin
        //CRC 에러 check.
        sTemp:= format('CRC Error: Recv %02x: Calc %02x', [wRecvCrc, wCrc]);
        AddLog(sTemp);
        FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_NG;
      end
      else begin
        FRxTempPlate.CmdStatus := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_RECV_OK;
      end;
      if FbWaitEvent then SetEvent(FhEvent);
      m_nBuffCount := 0;
    end;
  end;

end;

procedure TCommModbusRtuTempPlateMessage.WriteAllData;
var
  dwRet : DWORD;
  i: Integer;
  data : TArray<Word>;
  btTemp : byte;
begin
  // Connection - HeartBeat.
  SetLength(data,3);

// Heart Beat 필요 없음. -Bypass 기능 사용전에는 필요 없음.
// Bypass : 1개 plate가 오류가 나면 나머지 2개 plate는 자동 정지 - 이부분을 On 하기 위하여 Heart Beat 기능 필요함.
//  if FHeartBeat then begin
//    FHeartBeat := False;
//    data[0] := 1;
//    dwRet := CheckCmdAck(procedure begin WriteData(0,31,1,data); end,0,500,2);
//  end;

  if FnSystemStatus <> 0 then begin
    data[0] := word(FnSystemStatus);
    FnSystemStatus := 0;
    dwRet := CheckCmdAck(procedure begin WriteData(0,30,1,data); end,0,500,2);
  end;
  if FnChillerTemp <> 0 then begin
    data[0] := word(FnChillerTemp);
    FnChillerTemp := 0;
    dwRet := CheckCmdAck(procedure begin WriteData(0,31,1,data); end,0,500,2);
  end;

  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    if FnPlateSetValue[i] = 0 then Continue;
    data[0] := FnPlateSetValue[i];
    AddLog('SET Ch'+i.ToString+' SV :'+FnPlateSetValue[i].ToString);
    FnPlateSetValue[i] := 0;
    dwRet := CheckCmdAck(procedure begin WriteData(0,100*i + 31,1,data); end,0,500,2);
  end;

  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE1 to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    if FnPlateStatus[i] = 0 then Continue;
    data[0] := FnPlateStatus[i];
    case FnPlateStatus[i] of
      1 :  AddLog('SET Ch'+i.ToString+' RUN');
      2 :  AddLog('SET Ch'+i.ToString+' STOP');
      3 :  AddLog('SET Ch'+i.ToString+' RESET');
    end;
    FnPlateStatus[i] := 0;
    dwRet := CheckCmdAck(procedure begin WriteData(0,100*i + 30,1,data); end,0,500,2);
  end;
end;

function TCommModbusRtuTempPlateMessage.WriteData(wId, wAddr, wNum: Word; data: TArray<Word>): Boolean;
begin
  m_nBuffCount := 0;
  MultiWrite( wId, wAddr, wNum,data);
end;

procedure TCommModbusRtuTempPlateMessage.tmrCycleTimer(Sender: TObject);
var
  nCh: Byte;
begin
  //Send Query
  if Connected then begin
    inc(m_nTimeoutCount);
    if m_nTimeoutCount = 6 then begin
      //Timeout 발생
      SendMessageMain(COMM_MODBUS_TEMP_PLATE_CONNECT, 2, 0, 'Query Timeout');
    end;
    if m_nTimeoutCount > 100 then begin
      m_nTimeoutCount:= 100;
    end;

    nCh:= (m_tmrCycle.Tag mod 3) + 1;

    m_tmrCycle.Tag:= (m_tmrCycle.Tag + 1) mod 3; //0 ~ 2 순환
  end;
end;

function TCommModbusRtuTempPlateMessage.SendBuf(AData: array of Byte; ASize: Integer): Integer;
begin
  //AddLog('SendBuf: ' + BufferToHex(@AData[0], ASize));
  m_VaComm.WriteBuf(AData, ASize);
end;

procedure TCommModbusRtuTempPlateMessage.SendMessageMain(nMode, nParam, nParam2: Integer; sMsg: String);
var
  cds         : TCopyDataStruct;
  GUIMessage     : TGUIModbusRtuTempPlateMessage;
begin
  GUIMessage.MsgType := m_nMsgType;
  GUIMessage.Channel := 0;
  GUIMessage.Mode    := nMode;
  GUIMessage.Param  := nParam;
  GUIMessage.Param2 := nParam2;
  GUIMessage.Msg     := sMsg;
  cds.dwData      := 0;
  cds.cbData      := SizeOf(GUIMessage);
  cds.lpData      := @GUIMessage;
  SendMessage(m_hMain, WM_COPYDATA, 0, LongInt(@cds));
end;
procedure TCommModbusRtuTempPlateMessage.SetChillerSv(Value: Integer);
begin
  FnChillerTemp := Value;
end;

procedure TCommModbusRtuTempPlateMessage.SetPlateStatus(nCh, nMode: Integer);
begin
  FnPlateStatus[nCh] := nMode;
end;

procedure TCommModbusRtuTempPlateMessage.SetPlateSV(nCh, value: Integer);
begin
  FnPlateSetValue[nCh] := value;
end;

procedure TCommModbusRtuTempPlateMessage.SetResetAlarm(const Value: Boolean);
begin
  FResetAlarm := Value;
end;

procedure TCommModbusRtuTempPlateMessage.SetSetAutoCtrl(const Value: Boolean);
begin
  FSetAutoCtrl := Value;
end;

procedure TCommModbusRtuTempPlateMessage.SetSetMainterMode(const Value: Boolean);
begin
  FSetMainterMode := Value;
end;

procedure TCommModbusRtuTempPlateMessage.SetSystemStatus(nMode: Integer);
begin
  FnSystemStatus := nMode;
end;

procedure TCommModbusRtuTempPlateMessage.TaskThreadWorks;
var
  th : TThread;
begin
  th := TThread.CreateAnonymousThread(procedure begin

    while Connected do begin
      FbThreadWork := True;
      ReadAllData;
      if not Connected then break;
      CheckAlarm;
      if not Connected then break;
      WriteAllData;
      if not Connected then break;
      sleep(50);
      if not Connected then break;
      sleep(50);
      if not Connected then break;
      sleep(50);
      if not Connected then break;
      sleep(50);
      if not Connected then break;
      sleep(50);
    end;
    FbThreadWork := False;

  end);
  th.FreeOnTerminate := True;
  th.Start;
end;

// 010 6709 0621    온도 Plate SW 담당자 연락처.  이재용 수석.
const
  CRCTable16: array[0..255] of Word = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241, $C601, $06C0,
    $0780, $C741, $0500, $C5C1, $C481, $0440, $CC01, $0CC0, $0D80, $CD41,
    $0F00, $CFC1, $CE81, $0E40, $0A00, $CAC1, $CB81, $0B40, $C901, $09C0,
    $0880, $C841, $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41, $1400, $D4C1,
    $D581, $1540, $D701, $17C0, $1680, $D641, $D201, $12C0, $1380, $D341,
    $1100, $D1C1, $D081, $1040, $F001, $30C0, $3180, $F141, $3300, $F3C1,
    $F281, $3240, $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41, $FA01, $3AC0,
    $3B80, $FB41, $3900, $F9C1, $F881, $3840, $2800, $E8C1, $E981, $2940,
    $EB01, $2BC0, $2A80, $EA41, $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1,
    $EC81, $2C40, $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041, $A001, $60C0,
    $6180, $A141, $6300, $A3C1, $A281, $6240, $6600, $A6C1, $A781, $6740,
    $A501, $65C0, $6480, $A441, $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0,
    $6E80, $AE41, $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41, $BE01, $7EC0,
    $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40, $B401, $74C0, $7580, $B541,
    $7700, $B7C1, $B681, $7640, $7200, $B2C1, $B381, $7340, $B101, $71C0,
    $7080, $B041, $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440, $9C01, $5CC0,
    $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40, $5A00, $9AC1, $9B81, $5B40,
    $9901, $59C0, $5880, $9841, $8801, $48C0, $4980, $8941, $4B00, $8BC1,
    $8A81, $4A40, $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641, $8201, $42C0,
    $4380, $8341, $4100, $81C1, $8081, $4040
//   $0000, $1021, $2042, $3063, $4084, $50A5, $60C6, $70E7,
//   $8108, $9129, $A14A, $B16B, $C18C, $D1AD, $E1CE, $F1EF,
//   $1231, $0210, $3273, $2252, $52B5, $4294, $72F7, $62D6,
//   $9339, $8318, $B37B, $A35A, $D3BD, $C39C, $F3FF, $E3DE,
//   $2462, $3443, $0420, $1401, $64E6, $74C7, $44A4, $5485,
//   $A56A, $B54B, $8528, $9509, $E5EE, $F5CF, $C5AC, $D58D,
//   $3653, $2672, $1611, $0630, $76D7, $66F6, $5695, $46B4,
//   $B75B, $A77A, $9719, $8738, $F7DF, $E7FE, $D79D, $C7BC,
//   $48C4, $58E5, $6886, $78A7, $0840, $1861, $2802, $3823,
//   $C9CC, $D9ED, $E98E, $F9AF, $8948, $9969, $A90A, $B92B,
//   $5AF5, $4AD4, $7AB7, $6A96, $1A71, $0A50, $3A33, $2A12,
//   $DBFD, $CBDC, $FBBF, $EB9E, $9B79, $8B58, $BB3B, $AB1A,
//   $6CA6, $7C87, $4CE4, $5CC5, $2C22, $3C03, $0C60, $1C41,
//   $EDAE, $FD8F, $CDEC, $DDCD, $AD2A, $BD0B, $8D68, $9D49,
//   $7E97, $6EB6, $5ED5, $4EF4, $3E13, $2E32, $1E51, $0E70,
//   $FF9F, $EFBE, $DFDD, $CFFC, $BF1B, $AF3A, $9F59, $8F78,
//   $9188, $81A9, $B1CA, $A1EB, $D10C, $C12D, $F14E, $E16F,
//   $1080, $00A1, $30C2, $20E3, $5004, $4025, $7046, $6067,
//   $83B9, $9398, $A3FB, $B3DA, $C33D, $D31C, $E37F, $F35E,
//   $02B1, $1290, $22F3, $32D2, $4235, $5214, $6277, $7256,
//   $B5EA, $A5CB, $95A8, $8589, $F56E, $E54F, $D52C, $C50D,
//   $34E2, $24C3, $14A0, $0481, $7466, $6447, $5424, $4405,
//   $A7DB, $B7FA, $8799, $97B8, $E75F, $F77E, $C71D, $D73C,
//   $26D3, $36F2, $0691, $16B0, $6657, $7676, $4615, $5634,
//   $D94C, $C96D, $F90E, $E92F, $99C8, $89E9, $B98A, $A9AB,
//   $5844, $4865, $7806, $6827, $18C0, $08E1, $3882, $28A3,
//   $CB7D, $DB5C, $EB3F, $FB1E, $8BF9, $9BD8, $ABBB, $BB9A,
//   $4A75, $5A54, $6A37, $7A16, $0AF1, $1AD0, $2AB3, $3A92,
//   $FD2E, $ED0F, $DD6C, $CD4D, $BDAA, $AD8B, $9DE8, $8DC9,
//   $7C26, $6C07, $5C64, $4C45, $3CA2, $2C83, $1CE0, $0CC1,
//   $EF1F, $FF3E, $CF5D, $DF7C, $AF9B, $BFBA, $8FD9, $9FF8,
//   $6E17, $7E36, $4E55, $5E74, $2E93, $3EB2, $0ED1, $1EF0
    );

  //모드버스 프로토콜.
  // High-Order Byte Table
  (* Table of CRC values for high.order byte *)
  abCRCHi: array[0..255] of Byte = (
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $01, $C0, $80, $41, $00, $C1, $81, $40, $00, $C1, $81, $40, $01, $C0, $80, $41,
  $00, $C1, $81, $40, $01, $C0, $80, $41, $01, $C0, $80, $41, $00, $C1, $81, $40
  );

  // Low-Order Byte Table
  (* Table of CRC values for low.order byte *)
  abCRCLo: array[0..255] of Byte = (
  $00, $C0, $C1, $01, $C3, $03, $02, $C2, $C6, $06, $07, $C7, $05, $C5, $C4, $04,
  $CC, $0C, $0D, $CD, $0F, $CF, $CE, $0E, $0A, $CA, $CB, $0B, $C9, $09, $08, $C8,
  $D8, $18, $19, $D9, $1B, $DB, $DA, $1A, $1E, $DE, $DF, $1F, $DD, $1D, $1C, $DC,
  $14, $D4, $D5, $15, $D7, $17, $16, $D6, $D2, $12, $13, $D3, $11, $D1, $D0, $10,
  $F0, $30, $31, $F1, $33, $F3, $F2, $32, $36, $F6, $F7, $37, $F5, $35, $34, $F4,
  $3C, $FC, $FD, $3D, $FF, $3F, $3E, $FE, $FA, $3A, $3B, $FB, $39, $F9, $F8, $38,
  $28, $E8, $E9, $29, $EB, $2B, $2A, $EA, $EE, $2E, $2F, $EF, $2D, $ED, $EC, $2C,
  $E4, $24, $25, $E5, $27, $E7, $E6, $26, $22, $E2, $E3, $23, $E1, $21, $20, $E0,
  $A0, $60, $61, $A1, $63, $A3, $A2, $62, $66, $A6, $A7, $67, $A5, $65, $64, $A4,
  $6C, $AC, $AD, $6D, $AF, $6F, $6E, $AE, $AA, $6A, $6B, $AB, $69, $A9, $A8, $68,
  $78, $B8, $B9, $79, $BB, $7B, $7A, $BA, $BE, $7E, $7F, $BF, $7D, $BD, $BC, $7C,
  $B4, $74, $75, $B5, $77, $B7, $B6, $76, $72, $B2, $B3, $73, $B1, $71, $70, $B0,
  $50, $90, $91, $51, $93, $53, $52, $92, $96, $56, $57, $97, $55, $95, $94, $54,
  $9C, $5C, $5D, $9D, $5F, $9F, $9E, $5E, $5A, $9A, $9B, $5B, $99, $59, $58, $98,
  $88, $48, $49, $89, $4B, $8B, $8A, $4A, $4E, $8E, $8F, $4F, $8D, $4D, $4C, $8C,
  $44, $84, $85, $45, $87, $47, $46, $86, $82, $42, $43, $83, $41, $81, $80, $40
  );




function fn_makeCRC16_byte(const AData: array of Byte; ASize: Integer): Word;
var
  nCrc : Integer;
  i: Integer;
begin
  for i := 0 to Pred(ASize) do begin
    nCrc := (nCrc shr 8) xor CommModbusRtuTempPlate.CRCTable16[(nCrc xor AData[i]) and $ff];
  end;
  Result := (Hi(nCrc) shl 8) or (Lo(nCrc));
end;

function CalcCRC16(const AData: array of Byte; ASize: Integer): Word;
var
  bCrcHi, bCrcLo: Byte;
  nInx: Integer;
  i: Integer;
begin
  bCrcHi:= $FF; (* high byte of CRC initialized *)
  bCrcLo:= $FF; (* low byte of CRC initialized *)
  i:= 0;
  while ASize > 0 do begin
    nInx:= bCrcLo xor AData[i];
    bCrcLo:= bCrcHi xor abCRCHi[nInx];
    bCrcHi:= abCRCLo[nInx];
    dec(ASize);
    inc(i);
  end;

  Result:= 0;
  Result:= Result or (bCrcHi shl 8);
  Result:= Result or bCrcLo;
end;

function GetCRC16(const AData: Pointer; ASize: Integer): Word;
var
  p : PBYTE;
begin
  p := PBYTE(AData);
  Result := $FFFF;
  while (ASize > 0) do begin
    Result := (Result shl 8) xor CRCTable16[((Result shr 8) xor p^) and $FF];
    Dec(ASize);
    Inc(p);
  end;

end;

function GetCRC16(const AText:string):word;
var
  ssData : TStringStream;
begin
  ssData := TStringStream.Create(AText);
  try
    Result := GetCRC16(ssData.Memory, ssData.Size);
  finally
    ssData.Free;
  end;
end;

function BufferToHex(const AData: Pointer; nCount: Integer): String;
var
  p : PBYTE;
  i: Integer;
begin
  p := PBYTE(AData);
  Result:= '';
  while (nCount > 0) do begin
    Result := Result + Format('%0.2x ',[p^]);
    Dec(nCount);
    Inc(p);
  end;
end;

end.
