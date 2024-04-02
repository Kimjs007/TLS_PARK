unit Ezi_Servo;

interface

uses
  Winapi.Windows, System.SysUtils,  System.Classes, Vcl.ExtCtrls, defEziServo;

type
  InMotorEvnt = procedure(nMode,nParam : Integer; sMsg : String) of object;
  TEziMotor = class(TObject)
    private
      m_btBdId, m_nPortNum : Byte;

      m_nPreActPos : Integer;
      tmGetPos     : TTimer;
      FMotorStatus: InMotorEvnt;
      FMotorStatusMaint: InMotorEvnt;
      // 0 : Korean, 1: English.
      FIdxLang: Integer;
      procedure SetMotorStatus(const Value: InMotorEvnt);
      procedure GetPosDataTimer(Sender: TObject);
      procedure SetMotorStatusMaint(const Value: InMotorEvnt);
    procedure SetIdxLang(const Value: Integer);
    public
      m_nActualPos : Integer;
      m_bConnected : Boolean;
      m_bMainter : Boolean;
      constructor Create(btBdId : Byte); virtual;
      destructor Destroy; override;
      property MotorStatus : InMotorEvnt read FMotorStatus write SetMotorStatus;
      property MotorStatusMaint : InMotorEvnt read FMotorStatusMaint write SetMotorStatusMaint;
      procedure Connect(nPortNum,btBdId : Byte);
      procedure Close(nPortNum : Byte);
      procedure ABS_Move(lAbsPos : LONG; lVelocity : DWORD);
      procedure INC_Move(lIncPos : LONG; lVelocity : DWORD);
      procedure StopMove;
      procedure EmergencyStop;
      procedure ServoOn(bEnable : Boolean);
      procedure SearchOrigin;
      procedure AlarmReset;
      procedure JogMove(bPlus : Boolean; lVelocity: DWORD);
      procedure LimitMove(bPlus : Boolean; lVelocity: DWORD);
      property IdxLang : Integer read FIdxLang write SetIdxLang;
  end;
//const
//{$Include COMM_Define.h}
// Driver ���� �Լ�.
//FAS_Connect ����̺� ���� ��� ������ �õ��մϴ�. ���������� �����ߴٸ� TRUE ��, ���ӿ� ���и� �ߴٸ� FALSE �� �����մϴ�.
//FAS_Close ����̺� ���� ��� ������ �õ��մϴ�.
//FAS_GetboardInfo  ����̺��� ������ ���α׷� Version �� �о���Դϴ�. ����̺� ������ Version ������ �����մϴ�.
//FAS_GetMotorInfo  ����̺꿡 ����� ������ ������ �����翡 ���� ������ �о���Դϴ�.
//FAS_IsboardExist  �ش� ����̺��� ���� ���θ� Ȯ���մϴ�.  �����ϸ� TRUE ��, ���ӿ� ���и� �ߴٸ� FALSE �� �����մϴ�.
//FAS_EnableLog     ��� ���� ���� Log �� ����� �����մϴ�. �����ϸ� TRUE ��, ���ӿ� ���и� �ߴٸ� FALSE �� �����մϴ�.
//FAS_SetLogPath    ��µ� Log �� ����� ��θ� �����մϴ�.  �����ϸ� TRUE ��, ���ӿ� ���и� �ߴٸ� FALSE �� �����մϴ�.
//  EZI_PLUSE_API int WINAPI	FAS_GetSlaveInfo(BYTE iBdID, BYTE* pType, LPSTR lpBuff, int nBuffSize);
//  DLLCallTypeStdcall: function (AStr : string)  : PChar;  stdcall;

  function  FAS_Connect(nPortNo : Byte;dwBaud : DWORD) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
  function  FAS_OpenPort(nPortNo : Byte;dwBaud : DWORD) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';

  procedure FAS_Close(nPortNo : Byte) ; stdcall;   external 'EziMOTIONPlusR.dll';

//  function  FAS_IsBdIDExist(iBdID : Byte;var sb1, sb2, sb3, sb4 : Byte) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
//  function  FAS_IsIPAddressExist( sb1, sb2, sb3, sb4: Byte; var iBdID : Byte) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
  function  FAS_IsSlaveExist(nPortNo : Byte; nSlaveNo : Byte) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
  function  FAS_GetSlaveInfo(nPortNo,iBdID : Byte; var pType : Byte; lpBuff : PAnsiChar; nBuffSize : Integer) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';

////------------------------------------------------------------------------------
////			Servo Driver Control Functions
////------------------------------------------------------------------------------
//EZI_PLUSE_API int WINAPI	FAS_ServoEnable(BYTE iBdID, BOOL bOnOff);
//EZI_PLUSE_API int WINAPI	FAS_ServoAlarmReset(BYTE iBdID);
//EZI_PLUSE_API int WINAPI	FAS_StepAlarmReset(BYTE iBdID, BOOL bReset);
// ���� ���� �Լ�
//FAS_ServoEnable ������ ����̺��� Servo ���¸� ON/OFF ��ŵ�ϴ�.
//FAS_ServoAlarmReset  �˶��� �߻��� ����̺��� �˶��� ������ŵ�ϴ� , �˶��� �߻��� ������ ������ �� �ǽ��Ͻʽÿ�.
//FAS_GetAlarmType ���� �˶��� �߻� ���� �� �˶��� ������ Ȯ���մϴ�
  function  FAS_ServoEnable(nPortNo,nSlaveNo : Byte; bOnOff : BOOL) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
  function  FAS_ServoAlarmReset(nPortNo,nSlaveNo : Byte) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';
  function  FAS_StepAlarmReset(nPortNo,nSlaveNo : Byte; bReset : BOOL) : Integer ; stdcall;   external 'EziMOTIONPlusR.dll';

  function  FAS_SetParameter(nPortNo,nSlaveNo : Byte;iParamNo : Byte; lParamValue : LongInt) : integer;stdcall;   external 'EziMOTIONPlusR.dll';

//// ��ġ ���� �Լ�
//FAS_SetCommandPos ��ǥ(Command) ��ġ���� ������ ������ �����մϴ�.
//FAS_SetActualPos ����(Actual) ��ġ���� ������ ������ �����մϴ�.
//FAS_GetCommandPos ���� ��ǥ(Command) ��ġ���� �о���Դϴ�.
//FAS_GetActualPos ����(Actual) ��ġ���� �о���Դϴ�.
//FAS_GetPosError  ���� ����(Actual) ��ġ���� ��ǥ ��ġ(Command)���� ���̸� �о���Դϴ�.
//FAS_GetActualVel ���� �̵����� ������ ���� ���� �ӵ����� �о���Դϴ�.
//FAS_ClearPosition  ��ǥ(Command) ��ġ���� ����(Actual) ��ġ���� ��0������   �����մϴ�.
//------------------------------------------------------------------------------
//		 Position
//------------------------------------------------------------------------------
//EZI_PLUSE_API int WINAPI	FAS_SetCommandPos(BYTE iBdID, long lCmdPos);
//EZI_PLUSE_API int WINAPI	FAS_SetActualPos(BYTE iBdID, long lActPos);
//EZI_PLUSE_API int WINAPI	FAS_ClearPosition(BYTE iBdID);
//EZI_PLUSE_API int WINAPI	FAS_GetCommandPos(BYTE iBdID, long* lCmdPos);
//EZI_PLUSE_API int WINAPI	FAS_GetActualPos(BYTE iBdID, long* lActPos);
//EZI_PLUSE_API int WINAPI	FAS_GetPosError(BYTE iBdID, long* lPosErr);
//EZI_PLUSE_API int WINAPI	FAS_GetActualVel(BYTE iBdID, long* lActVel);
//EZI_PLUSE_API int WINAPI	FAS_GetAlarmType(BYTE iBdID, BYTE* nAlarmType);
  function FAS_SetCommandPos (nPortNo, iBdID : Byte; lCmdPos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_SetActualPos (nPortNo, iBdID : Byte; lActPos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_ClearPosition (nPortNo, iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetCommandPos (nPortNo, iBdID : Byte;var lCmdPos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetActualPos (nPortNo, iBdID : Byte;var lActPos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetPosError (nPortNo, iBdID : Byte;var lPosErr : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetActualVel (nPortNo, iBdID : Byte;var lActVel : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetAlarmType (nPortNo, iBdID : Byte;var nAlarmType : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';

//FAS_MoveStop �������� ���͸� �����ϸ鼭 ������ŵ�ϴ�.
//FAS_EmergencyStop �������� ���͸� ���Ӿ��� ��� ������ŵ�ϴ�.
//FAS_MoveOriginSingleAxis ���� ���� ������ �����մϴ�.
//FAS_MoveSingleAxisAbsPos �־��� ����(Absolute) ��ġ�� ��ŭ ������ �ǽ��մϴ�.
//FAS_MoveSingleAxisIncPos �־��� ���(Incremental) ��ġ�� ��ŭ ������ �ǽ��մϴ�.
//FAS_MoveToLimit Limit ������ �����Ǵ� ��ġ���� ������ �ǽ��մϴ�.
//FAS_MoveVelocity      �־��� �ӵ��� �������� ������ �����մϴ�   Jog ���� � ���˴ϴ�.
//FAS_PositionAbsOverride �������� ���¿��� ��ǥ ���� ��ġ�� [pulse]�� ���� �մϴ�.
//FAS_PositionIncOverride �������� ���¿��� ��ǥ ��� ��ġ�� [pulse]�� ���� �մϴ�.
//FAS_VelocityOverride �������� ���¿��� ���� �ӵ���[pps]�� ���� �մϴ�.
//FAS_MoveSingleAxisAbsPosEx   �־��� ����(Absolute) ��ġ�� ��ŭ ������ �ǽ��մϴ�.  ���� �� ���� �ð��� ������ �� �ֽ��ϴ�.
//FAS_MoveSingleAxisIncPosEx   �־��� ���(Incremental) ��ġ�� ��ŭ ������ �ǽ��մϴ�. ���� �� ���� �ð��� ������ �� �ֽ��ϴ�.
//FAS_MoveVelocityEx           �־��� �ӵ��� �������� ������ �����մϴ� Jog ����� ���˴ϴ�. ���� �� ���� �ð��� ������ �� �ֽ��ϴ�.
//FAS_MovePause               �������� ���¿��� ������ �Ͻ� ���� �� �Ͻ� ����  ���¿����� ���� �簳�� �ǽ��մϴ�.
//------------------------------------------------------------------
//			Motion Functions.
//------------------------------------------------------------------
//EZI_PLUSE_API int WINAPI	FAS_MoveStop(BYTE iBdID);
//EZI_PLUSE_API int WINAPI	FAS_EmergencyStop(BYTE iBdID);
//EZI_PLUSE_API int WINAPI	FAS_MovePause(BYTE iBdID, BOOL bPause);
//EZI_PLUSE_API int WINAPI	FAS_MoveOriginSingleAxis(BYTE iBdID);
//EZI_PLUSE_API int WINAPI	FAS_MoveSingleAxisAbsPos(BYTE iBdID, long lAbsPos, DWORD lVelocity);
//EZI_PLUSE_API int WINAPI	FAS_MoveSingleAxisIncPos(BYTE iBdID, long lIncPos, DWORD lVelocity);
//EZI_PLUSE_API int WINAPI	FAS_MoveToLimit(BYTE iBdID, DWORD lVelocity, int iLimitDir);
//EZI_PLUSE_API int WINAPI	FAS_MoveVelocity(BYTE iBdID, DWORD lVelocity, int iVelDir);
  function FAS_MoveStop (nPortNo, iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_EmergencyStop (nPortNo, iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MovePause (nPortNo, iBdID : Byte; bPause : BOOL) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveOriginSingleAxis (nPortNo, iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveSingleAxisAbsPos (nPortNo, iBdID : Byte; lAbsPos : LONG; lVelocity : DWORD) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveSingleAxisIncPos (nPortNo, iBdID : Byte; lIncPos : LONG; lVelocity : DWORD) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveToLimit (nPortNo, iBdID : Byte; lVelocity: DWORD; iLimitDir : Integer) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveVelocity (nPortNo, iBdID : Byte; lVelocity: DWORD; iVelDir : Integer) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';

//EZI_PLUSE_API int WINAPI	FAS_PositionAbsOverride(BYTE iBdID, long lOverridePos);
//EZI_PLUSE_API int WINAPI	FAS_PositionIncOverride(BYTE iBdID, long lOverridePos);
//EZI_PLUSE_API int WINAPI	FAS_VelocityOverride(BYTE iBdID, DWORD lVelocity);
//EZI_PLUSE_API int WINAPI	FAS_MoveLinearAbsPos(BYTE nNoOfBds, BYTE* iBdID, long* lplAbsPos, DWORD lFeedrate, WORD wAccelTime);
//EZI_PLUSE_API int WINAPI	FAS_MoveLinearIncPos(BYTE nNoOfBds, BYTE* iBdID, long* lplIncPos, DWORD lFeedrate, WORD wAccelTime);
//EZI_PLUSE_API int WINAPI	FAS_TriggerOutput_RunA(BYTE iBdID, BOOL bStartTrigger, long lStartPos, DWORD dwPeriod, DWORD dwPulseTime);
//EZI_PLUSE_API int WINAPI	FAS_TriggerOutput_Status(BYTE iBdID, BYTE* bTriggerStatus);
//EZI_PLUSE_API int WINAPI	FAS_SetTriggerOutputEx(BYTE iBdID, BYTE nOutputNo, BYTE bRun, WORD wOnTime, BYTE nTriggerCount, long* arrTriggerPosition);
//EZI_PLUSE_API int WINAPI	FAS_GetTriggerOutputEx(BYTE iBdID, BYTE nOutputNo, BYTE* bRun, WORD* wOnTime, BYTE* nTriggerCount, long* arrTriggerPosition);
//EZI_PLUSE_API int WINAPI	FAS_MovePush(BYTE iBdID, DWORD dwStartSpd, DWORD dwMoveSpd, long lPosition, WORD wAccel, WORD wDecel, WORD wPushRate, DWORD dwPushSpd, long lEndPosition, WORD wPushMode);
//EZI_PLUSE_API int WINAPI	FAS_GetPushStatus(BYTE iBdID, BYTE* nPushStatus);
  function FAS_PositionAbsOverride (nPortNo, iBdID : Byte; lOverridePos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_PositionIncOverride (nPortNo, iBdID : Byte; lOverridePos : LONG) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_VelocityOverride (nPortNo, iBdID : Byte; lVelocity : DWORD) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveLinearAbsPos (nPortNo, nNoOfBds : Byte; var iBdID : Byte; var lplAbsPos : LONG;  lFeedrate : DWORD; wAccelTime : Word) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_MoveLinearIncPos (nPortNo, nNoOfBds : Byte; var iBdID : Byte; var lplIncPos : LONG;  lFeedrate : DWORD; wAccelTime : Word) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  // ���߿�... ������ ���� �ٻ�.
  //  function FAS_TriggerOutput_RunA ( iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusE.dll';
//  function FAS_TriggerOutput_Status ( iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusE.dll';
//  function FAS_SetTriggerOutputEx ( iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusE.dll';
//  function FAS_GetTriggerOutputEx ( iBdID : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusE.dll';
  function FAS_MovePush ( iBdID : Byte;  dwStartSpd,  dwMoveSpd :DWORD; lPosition : LONG; wAccel,  wDecel, wPushRate : Word; dwPushSpd : DWORD;lEndPosition : LONG; wPushMode : Word) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';
  function FAS_GetPushStatus ( iBdID : Byte; var nPushStatus : Byte) : Integer ; stdcall;  external 'EziMOTIONPlusR.dll';

var
 EziMotor :  TEziMotor;
implementation

{ TEziMotor }

procedure TEziMotor.ABS_Move(lAbsPos: LONG; lVelocity: DWORD);
var
  nRet : Integer;
begin
  nRet := FAS_MoveSingleAxisAbsPos(m_nPortNum, m_btBdId,lAbsPos,lVelocity);
  if Assigned(MotorStatusMaint) and m_bMainter then MotorStatusMaint(defEziServo.MODE_ABS_AXIS_MOVE,nRet,'FAS_MoveSingleAxisAbsPos');
end;

procedure TEziMotor.AlarmReset;
begin
  FAS_StepAlarmReset(m_nPortNum, m_btBdId,True)
end;

procedure TEziMotor.Close(nPortNum: Byte);
begin
  if nPortNum = 0 then Exit;
  if m_nPortNum = 0 then Exit;
  if not m_bConnected then Exit;
  m_bConnected := False;
  FAS_Close(m_nPortNum);
end;

procedure TEziMotor.Connect(nPortNum,btBdId : Byte);
var
  btSb1, btSb2, btSb3, btSb4, nType : byte;
  nRet, nBuffSize, nActPos : Integer;
  btBuff : array of byte;
  sMsg : string;

begin
//  btSb1 := 192; btSb2 := 168; btSb3 := 0; btSb4 := 2; // IP 192.168.0.2�� �����ϵ��� �Ѵ�.
// m_btBdId ==> Slave no.
  m_btBdId := $ff; nBuffSize := 256;
  m_nPortNum := 0;
  SetLength(btBuff,nBuffSize);
  m_bConnected := False;
  // Return���� 0�̸� NG, 1�̸� OK.
  if FAS_Connect(nPortNum,115200) <> 0 then begin
    // Connect.
    m_nPortNum := nPortNum;
    m_btBdId := btBdId;

    m_bConnected := True;
    sMsg := 'Connected';
    MotorStatus(defEziServo.MODE_MOTOR_CONNECT,1,sMsg);
    if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_MOTOR_CONNECT,1,sMsg);

    if FAS_IsSlaveExist(nPortNum,btBdId) = 0 then begin // board ID�� ���� ���� ������,
      // �ش� board ��ȣ�� �������� �ʽ��ϴ�.
      // Ezi-SERVO���� board ��ȣ�� Ȯ���Ͻʽÿ�.
      sMsg := '�ش� board ��ȣ�� �������� �ʽ��ϴ�, Ezi-SERVO���� board ��ȣ�� Ȯ���Ͻʽÿ� ';
      if FIdxLang = 1 then sMsg := 'The board number dose not exist, Confirm board number on Ezi-SERVO��.';

      MotorStatus(defEziServo.MODE_MOTOR_BOARD_CHECK,0,sMsg);
      if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_MOTOR_BOARD_CHECK,0,sMsg);
      Exit;
    end;
    if FAS_GetSlaveInfo(nPortNum,btBdId,nType,PAnsiChar(btBuff),nBuffSize) <> defEziServo.FMM_OK then begin
      case FIdxLang of
        0 : sMsg := '�ش� Board�� ������ ������ �����ϴ�.';
        1 : sMsg := 'Cannot get Board Information.';
      end;

      MotorStatus(defEziServo.MODE_GET_SLAVE_INFO,nType,sMsg);
      if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_GET_SLAVE_INFO,nType,sMsg);
      Exit;
    end;
    sMsg := 'Get Slave Info : '+ StrPas(PAnsiChar(btBuff));
    MotorStatus(defEziServo.MODE_GET_SLAVE_INFO,1,sMsg);
    if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_GET_SLAVE_INFO,1,sMsg);
    // Servo On ����.
    FAS_ServoEnable(nPortNum,btBdId,True);
    MotorStatus(defEziServo.MODE_GET_SLAVE_INFO,1,'Servo On');
    tmGetPos.Enabled := True;

//{nRtn = FAS_GetSlaveInfo(iBdID, &nType, lpBuff, nBuffSize);
//if (nRtn != FMM_OK)
//{
//// ����� ���������� ������� �ʾҽ��ϴ�.
//// ReturnCodes_Define.h �� �����Ͻʽÿ�.
//}
//printf("Port : %d (board %d) \n", iBdID);
//printf("\tType : %d \n", nType);
//printf("\tVersion : %d \n", lpBuff );
//}
  end
  else begin

    // ���ῡ ����.
    case FIdxLang of
      0 : sMsg := 'MOTOR ���ῡ ����';
      1 : sMsg := 'Fail to connect motor';
    end;
    MotorStatus(defEziServo.MODE_MOTOR_CONNECT,0,sMsg);
  end;
end;

constructor TEziMotor.Create(btBdId : Byte);
begin
  m_btBdId := btBdId;
  m_nPortNum := 0;
  tmGetPos := TTimer.Create(nil);
  tmGetPos.OnTimer := GetPosDataTimer;
  tmGetPos.Interval := 500;
  tmGetPos.Enabled := False;
  // ���ǰ� ����.
  m_nPreActPos := -82763;
  m_bMainter := False;
end;

destructor TEziMotor.Destroy;
begin

  // Servo Off.
//  if m_nPortNum <> 0 then FAS_ServoEnable(m_nPortNum,m_btBdId,False);

  tmGetPos.Enabled := False;
  tmGetPos.Free;
  tmGetPos := nil;
  if m_bConnected then begin
    FAS_close(m_nPortNum);
    m_bConnected := False;
    //MotorStatus(defEziServo.MODE_MOTOR_CONNECT,0,'Close Connection');
  end;
  //MotorStatus(defEziServo.MODE_MOTOR_CONNECT,0,'Close Class');
  inherited;
end;

procedure TEziMotor.EmergencyStop;
var
  nRet : Integer;
begin
  nRet := FAS_EmergencyStop(m_nPortNum,m_btBdId);
  if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_MOVE_STOP,nRet,'Emergency Stop Move');
end;

procedure TEziMotor.GetPosDataTimer(Sender: TObject);
var
  nActPos : Integer;
  sDebug : string;
begin
  nActPos := 0;
  tmGetPos.Enabled := False;
  FAS_GetActualPos(m_nPortNum,m_btBdId,nActPos);
  // GUI�� ���ϸ� ���̱� ���ؼ� Event�� �������� Display.
  if m_nPreActPos <> nActPos then begin
    MotorStatus(defEziServo.MODE_GET_ACTUAL_POS,nActPos,'');
    if Assigned(MotorStatusMaint) and m_bMainter  then begin
      sDebug := Format('Get Current Actual Position : %d',[nActPos]);
      MotorStatusMaint(defEziServo.MODE_GET_ACTUAL_POS,nActPos,sDebug);
    end;
  end;
  m_nPreActPos :=  nActPos;
  tmGetPos.Enabled := True;
end;

procedure TEziMotor.INC_Move(lIncPos: LONG; lVelocity: DWORD);
var
  nRet : Integer;
begin
  nRet := FAS_MoveSingleAxisIncPos(m_nPortNum,m_btBdId,lIncPos,lVelocity);
  if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_INC_AXIS_MOVE,nRet,'FAS_MoveSingleAxisIncPos');
end;

procedure TEziMotor.JogMove(bPlus: Boolean; lVelocity: DWORD);
var
  nDirection : Integer;
begin
  if bPlus then nDirection := 1
  else          nDirection := 0;
  FAS_MoveVelocity(m_nPortNum,m_btBdId,lVelocity,nDirection)
end;

procedure TEziMotor.LimitMove(bPlus: Boolean; lVelocity: DWORD);
var
  nDirection : Integer;
begin
  if bPlus then nDirection := 1
  else          nDirection := 0;
  FAS_MoveToLimit(m_nPortNum,m_btBdId,lVelocity,nDirection)
end;

procedure TEziMotor.SearchOrigin;
begin
//  if FAS_SetParameter(m_nPortNum,m_btBdId,17,1) = FMM_OK then begin
    FAS_MoveOriginSingleAxis(m_nPortNum,m_btBdId);
//  end;

end;

procedure TEziMotor.ServoOn(bEnable: Boolean);
begin
  FAS_ServoEnable(m_nPortNum,m_btBdId,bEnable);
  tmGetPos.Enabled := bEnable;
end;

procedure TEziMotor.SetIdxLang(const Value: Integer);
begin
  FIdxLang := Value;
end;

procedure TEziMotor.SetMotorStatus(const Value: InMotorEvnt);
begin
  FMotorStatus := Value;
end;

procedure TEziMotor.SetMotorStatusMaint(const Value: InMotorEvnt);
begin
  FMotorStatusMaint := Value;
end;

procedure TEziMotor.StopMove;
var
  nRet : Integer;
begin
  nRet := FAS_MoveStop(m_nPortNum,m_btBdId);
  if Assigned(MotorStatusMaint) and m_bMainter  then MotorStatusMaint(defEziServo.MODE_MOVE_STOP,nRet,'Stop Move');
end;

end.
