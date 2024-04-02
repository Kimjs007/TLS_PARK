unit CommDIO_DAE;
{
  DAE DIO(DJ596-DIO) ��� ó��
  CommDIO Ŭ������ Polling�� ���� ������� ����
}
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,  System.Classes, System.AnsiStrings, SyncObjs, System.DateUtils,
  IdGlobal, IdUDPClient, IdUDPServer, IdContext, IdSocketHandle,Vcl.Forms;

const
{$IFDEF INSPECTOR_OC}
  MAX_DIO_DEVICE_COUNT = 12;
{$ELSE}
  MAX_DIO_DEVICE_COUNT = 8;
{$ENDIF}


  COMMDIO_MSG_NONE        = 100;
  COMMDIO_MSG_CONNECT     = COMMDIO_MSG_NONE + 1;
  COMMDIO_MSG_HEARTBEAT   = COMMDIO_MSG_NONE + 2;
  COMMDIO_MSG_CHANGE_DI   = COMMDIO_MSG_NONE + 3;
  COMMDIO_MSG_CHANGE_DO   = COMMDIO_MSG_NONE + 4;
  COMMDIO_MSG_LOG         = COMMDIO_MSG_NONE + 5;
  COMMDIO_MSG_ERROR       = COMMDIO_MSG_NONE + 100;
  COMMDIO_MSG_MAX         = COMMDIO_MSG_ERROR + 1;

  COMMDIO_LOGSAVEMODE_NONE = 0;
  COMMDIO_LOGSAVEMODE_HOUR = 1;
  COMMDIO_LOGSAVEMODE_DAY  = 2;
type
  /// <summary> GUI Message for WM_COPYDATA </summary>
  PGuiDaeDio = ^RGuiDaeDio;
  RGuiDaeDio = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    Param  : Integer;
    Param2 : Integer;
    Msg     : string;
    pData   : PBYTE; //Pointer; //Length = Param2
  end;
  TDIONotifyEvent = procedure(Sender: TObject; pDataMessage: PGuiDaeDio) of object;

  /// <summary>DIO ���� ������ �⺻ ���� </summary>
  TDIOHeader = packed record
    ID  : WORD;
    Len : WORD;
    case Integer of
      0: (Ack : WORD; Addr:Byte; Count:Byte);
      1: (Data: array [0..32]of byte);
  end;
  PDIOHeader = ^TDIOHeader;

  /// <summary> DIO Info �� Version ����</summary>
  TDIODeviceInfo = packed record
    Ack   : WORD;
    DeviceIP: Cardinal;
    DevicePort: Cardinal;
    ServerIP: Cardinal;
    ServerPort: Cardinal;
    Count : Byte;
    Version : array [0..MAX_DIO_DEVICE_COUNT] of Cardinal;
  end;
  PDIODeviceInfo = ^TDIODeviceInfo;

  /// <summary> DIO ��� ������</summary>
  TCommDIOThread = class(TThread)
  private
    m_hMain: THandle;
    m_nDeviceCount: Integer;
    m_UDPServer: TIdUDPServer;
    m_UDPClient: TIdUDPClient;
    m_hEventCommand: HWND; //command ���� Ȯ�ο� �̺�Ʈ
    //m_LastCommand: TDIOHeader;
    m_nLastAck: WORD;
    m_nLastTick_Recv: Cardinal;
    m_nLastTick_Send: Cardinal;
    m_pRecvData: PBYTE;
    m_bWaitEvent: Boolean;
    m_bWorking: Boolean; //�۾� ��
    m_bFirstConnection: Boolean;

    m_bConnected: Boolean;
    m_csWrite: TCriticalSection;
    m_nStop: Integer;
    m_csLog: TCriticalSection;
    m_slLog: TStringList;
    /// <summary> �α� ���� ���� ��ġ</summary>
    m_sLogPath: String;
    m_dtSaveLog: TDateTime;
    /// <summary> �˸� �̺�Ʈ</summary>
    m_NotifyEvent: TDIONotifyEvent;
    m_nTowerLampState: Integer;
    m_nTowerLampTick: Cardinal;
    FSetMelodyOff: Boolean;
    FSetMelodyH: Integer;
    FSetMelodyL: Integer;
    FSetMelodyOk: Integer;
    //class var m_Instance:TCommDIOThread;
    procedure AddLog(sLog: String; bSave: Boolean=false);
    procedure SaveLog(dtSave: TDateTime);
    procedure SendMsgMain(nMsgMode: Integer; nParam, nParam2: Integer; sMsg: String; pData:Pointer=nil);
    function ReadPollingData: Integer;
    function WriteFlushData: Integer;
    procedure Set_LogPath(sValue: String);
    function GetDIValue(inx: Integer): byte;
    function GetDOValue(inx: Integer): byte;
    procedure ProcessPollingData;
    procedure ProcessConnection;
    procedure Process_TowerLamp;

    function CalcChecksum(pValue: PByte; nCount: Integer): Integer;
    function SendData(Buff : TIdBytes): Integer;
    /// <summary> HeartBeat ó��</summary>
    function Send_HeatBeat: Integer;
    function Send_EventNotify(nValue: Byte): Integer;
    function Send_ReadDI(nAddr, nCount: Byte): Integer;
    function Send_ReadDO(nAddr, nCount: Byte): Integer;
    function Send_ClearDO(nAddr, nCount: Byte): Integer;
    function Send_WriteDO(nAddr, nCount: Byte; var naValues: TBytes): Integer;
    function Send_WriteBit(nAddr, nCount: Byte; var nData: Byte): Integer;
    function Send_File(nTpye, nMode, nIndex, nCount: Integer; var naValues: TIdBytes): Integer;
    function Send_ReadVerionInfo: Integer;
    /// <summary> ������ ���� �� ���� ��ٸ���. Thread���� ���. default nWaitTime=2000, nRetry=0</summary>
    function WaitForCommandAck(CommandProc: TProc; nWaitTime:Integer=2000; nRetry: Integer=0): Cardinal;
    procedure SetSetMelodyOff(const Value: Boolean);
    procedure SetSetMelodyH(const Value: Integer);
    procedure SetSetMelodyL(const Value: Integer);
    procedure SetSetMelodyOk(const Value: Integer);

  protected
    procedure DoEvent;
    /// <summary> Synchronize Main Thread </summary>
    procedure SyncMainThread;
    procedure Execute; override;
    procedure StopThread;
    procedure UDPServerUDPException(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
    procedure UDPServerUDPRead(AThread: TIdUDPListenerThread;const AData: TIdBytes; ABinding: TIdSocketHandle);
  public
    /// <summary> SendMessage���� ����� MsgType</summary>
    MessageType: Integer;
    /// <summary> ��ġ ��� ���� IP</summary>
    DeviceIP: string;
    /// <summary> ��ġ ��� ���� Port</summary>
    DevicePort: Integer;
    /// <summary> ���� ����. Runtime ���� ����</summary>
    PollingInterval: Integer;
    /// <summary> DI ���� ���. 0=None, 1=Polling, 2=EventNotify, 3=Both(default) </summary>
    PollingMode: Byte;
    /// <summary> Flush Mode���� ���� �� Sleep �� Read DIó��. ��= 0�̸� Read DI���� �ʴ´� </summary>
    FlushReadInterval: Integer;
    /// <summary> ��ü �α׻�� ���� 0=������, 1=�ð���������, 2=���ϴ��� ����</summary>
    LogSaveMode: Integer;
    /// <summary> Log ���� ����. 0=Basic(Connection, Disconnection, Error ��, default), 1=Write, 2=Read, 4=Send, 8=Recv, 16=Polling, All=31</summary>
    LogLevel: Integer;
    /// <summary> Log ���� ���� �� - �ʰ� �� ��� ����</summary>
    LogAccumulateCount : Integer;
    /// <summary> Log ���� �ð�(�ʴ���) - �ʰ� �� ��� ����</summary>
    LogAccumulateSecond : Integer;
    /// <summary> ���� ����ð�- ���������� ���� �� �ش� �ð� ��� �� ���� ����ó�� </summary>
    ExpirationPeriod: Cardinal;
    /// <summary> ���� ������ ������ ���� �ð�- ���� ������ ���� �� �ش� �ð� ��� �� HeartBeat ���� </summary>
    HeartBeatPeriod: Cardinal;  //HeartBeatPeriod + PollingInterval < 3000 . DIO Timeout 3000�̹Ƿ�

    /// <summary> Simulation ������� ����</summary>
    UseSimulator: Boolean;
    /// <summary> DO ���⸦ Flush ������� ����. False=Normal Mode, True=Flush Mode</summary>
    UseFlushMode: Boolean;
    /// <summary> Main���� Log Message ���� ��� ���</summary>
    UseMainLog: Boolean;
    /// <summary> ������ DI ������. Read only </summary>
    DIData: TBytes; //array of Byte;
    /// <summary> ������ DI ���� ������. Read only </summary>
    DIDataPre: TBytes; //array of Byte;
    /// <summary> DO ������. Read only </summary>
    DOData: TBytes; //array of Byte;
    /// <summary> DO�� �� ������  ������</summary>
    DODataFlush: TBytes; //array of Byte;
    /// <summary> ��ġ ���� ����. Read Only</summary>
    DeviceInfo: TDIODeviceInfo;
    /// <summary> ���� �õ� ���� Timeout</summary>
    ConnectionTimeout: Cardinal;
    /// <summary> ���� �õ� ���� �߻�</summary>
    ConnectionError: Boolean;

    //class function getInstance: TCommDIOThread; //Singletone
    constructor Create(hMain : THandle; nMsgType: Integer; nServerPort:Integer=6989; nDeviceCount: Integer=1; bFlushMode:Boolean=false; nPollingMode: Integer=1; nLogSaveMode:Integer=0);
    destructor Destroy; override;
    /// <summary> DI  ������ �б� </summary>
    /// <param name='bWaitReply'> ��� ���� �� ���� ���. default=false, GUI������ �Ұ�(SendMessage)</param>
    function ReadDI(nAddr, nCount: Byte; out naValues: TBytes; bWaitReply: Boolean=false): Integer;
    /// <summary> DO  ������ �б� </summary>
    /// <param name='bWaitReply'> ��� ���� �� ���� ���. default=false, GUI������ �Ұ�(SendMessage)</param>
    function ReadDO(nAddr, nCount: Byte; bWaitReply: Boolean=false): Integer;
    /// <summary> DO�� ������ ����</summary>
    /// <param name='bWaitReply'> ��� ���� �� ���� ���. default=false. GUI������ �Ұ�(SendMessage)</param>
    function ClearDO(nAddr, nCount: Byte; bWaitReply: Boolean=false): Integer;
    /// <summary> DO�� ������ ����</summary>
    /// <param name='bWaitReply'> ��� ���� �� ���� ���. default=false. GUI������ �Ұ�(SendMessage)</param>
    function WriteDO(nAddr, nCount: Byte; naValues: TBytes; bWaitReply: Boolean=false): Integer;
    /// <summary> DO�� Bit ����</summary>
    /// <param name='bWaitReply'> ��� ���� �� ���� ���. default=false, GUI������ �Ұ�(SendMessage)</param>
    function WriteDO_Bit(nAddr, nBitLoc, nValue: Byte; bWaitReply: Boolean=false): Integer;
    /// <summary> DO Data Flush�� Bit ����</summary>
    function WriteDO_FlushBit(nAddr, nBitLoc, nValue: Byte): Integer;
    /// <summary> Configuration ���� �б�</summary>
    function ReadConfig(out sDeviceIP, sServerIP: string; out nDevicePort, nServerPort, nDeviceCount: Integer): Integer;
    /// <summary> Configuration ���� ����</summary>
    function WriteConfig(sDeviceIP, sServerIP: string; nDevicePort, nServerPort, nDeviceCount: Integer): Integer;
    /// <summary> Polling ��� ����</summary>
    function WriteEventNotify(nValue: Byte): Integer;
    /// <summary> ���� ���� -  ��ġ�� F/W �ٿ�ε� �� ���</summary>
    function WriteFile(sFileName: string): Integer;
    /// <summary> ���̳ʸ� ���� ������ ����</summary>
    function SendBuffer(naValues: TBytes): Integer;
    /// <summary> �ش� ��Ʈ ���� Value�� �ɶ����� ���</summary>
    function WaitSignal(nAddr, nBitLoc, nValue: Byte; nWaitTime: Cardinal): Cardinal;
    function Get_Bit(nData: byte; nLoc: byte): byte;
    procedure Set_Bit(var nData: byte; nLoc, Value: byte); overload;
    procedure Set_Bit(var nData: byte; nLoc: byte; Value: Boolean); overload;
    /// <summary> Tower Lamp ���� �� Melody ����</summary>
    procedure Set_TowerLampState(nState: Integer);
    /// <summary> Bit On ����</summary>
    function IsBitOn(var nData: byte; nLoc: byte): Boolean;
    /// <summary> ���� DIData[Addr]�� Bit On ����</summary>
    function IsDIOn(nAddr, nLoc: byte): Boolean;  overload;
    /// <summary> ���� DI Index�� On ����</summary>
    function IsDIOn(nIndex: byte): Boolean; overload;
    /// <summary> ���ڿ� IP���� ���ڷ� ��ȯ</summary>
    function IP2Int(sIP: string): UINT;
    /// <summary> ���� IP ���� ���ڿ��� ��ȯ</summary>
    function Int2IP(nIP: UINT): String;
    property DIValue[inx: Integer]: byte read GetDIValue;
    property DOValue[inx: Integer]: byte read GetDOValue;
    property Connected: Boolean read m_bConnected;
    property LogPath: String read m_sLogPath write Set_LogPath;
    /// <summary> DIO Event �˸�  </summary>
    property OnNotify: TDIONotifyEvent read m_NotifyEvent write m_NotifyEvent;
    property SetMelodyOff : Boolean read FSetMelodyOff write SetSetMelodyOff;

    property SetMelodyH : Integer read FSetMelodyH write SetSetMelodyH;
    property SetMelodyL : Integer read FSetMelodyL write SetSetMelodyL;
    property SetMelodyOk : Integer read FSetMelodyOk write SetSetMelodyOk;
  end;

var
  CommDaeDIO: TCommDIOThread;

implementation

uses CommonClass;

const
  COMMDIO_ID_FIRSTCONNECTION     = 1;
  COMMDIO_ID_CONNECTION          = 2;
  COMMDIO_ID_EVENTNOTIFY         = 4;
  COMMDIO_ID_READ_DI             = $10;
  COMMDIO_ID_READ_DO             = $12;
  COMMDIO_ID_CLEARDO             = $20;
  COMMDIO_ID_WRITE_DO            = $22;
  COMMDIO_ID_WRITE_BIT           = $24;
  COMMDIO_ID_VERSION             = $A0;
  COMMDIO_ID_FILEDOWNLOAD        = $F0;
  COMMDIO_ID_CONFIG              = $F2;


{ TCommDIOThread }

(*
class function TCommDIOThread.getInstance: TCommDIOThread;
begin
  if not Assigned(m_Instance) then begin
    //m_Instance:= TCommDIOThread.Create();
  end;
  Result:= m_Instance;
end;
*)


procedure TCommDIOThread.AddLog(sLog: String; bSave: Boolean);
var
  dtNow: TDateTime;
begin
  if m_nStop <> 0 then Exit;
  
  if LogSaveMode = COMMDIO_LOGSAVEMODE_NONE then Exit;  //��ü �α� �ƴϸ�

  m_csLog.Acquire;
  dtNow:= Now;
  if LogSaveMode = COMMDIO_LOGSAVEMODE_HOUR then begin
    if HourOf(m_dtSaveLog) <> HourOf(dtNow) then SaveLog(m_dtSaveLog); //�ð� ����� ��� ���� File�� ����
  end
  else begin
    if Dayof(m_dtSaveLog) <> Dayof(dtNow) then SaveLog(m_dtSaveLog); //��¥ ����� ��� ���� File�� ����
  end;

  m_slLog.Add(FormatDateTime('HH:NN:SS.ZZZ ', dtNow) + IntToHex(TThread.CurrentThread.ThreadID, 4) + '=> ' +  sLog);
  //�α� ���μ��� ���� ���μ� �ʰ��̰ų������ð�(��) �ʰ��� ���File�� ����
  if (m_slLog.Count > LogAccumulateCount) or (SecondsBetween(dtNow, m_dtSaveLog) > LogAccumulateSecond) or bSave then begin
    SaveLog(dtNow);
  end;
  m_csLog.Release;
end;

procedure TCommDIOThread.SaveLog(dtSave: TDateTime);
var
  sFileName: String;
  logFile: TextFile;
begin
  if LogSaveMode = COMMDIO_LOGSAVEMODE_HOUR then begin
    sFileName:=  m_sLogPath + format('CommDIO_%s.txt',[FormatDateTime('YYYYMMDDHH', dtSave)]);
  end
  else begin
    sFileName:=  m_sLogPath + format('CommDIO_%s.txt',[FormatDateTime('YYYYMMDD', dtSave)]);
  end;

  AssignFile(logFile, sFileName);
  try
    try
      if FileExists(sFileName) then Append(logFile) else Rewrite(logFile);

      WriteLn(logFile, Trim(m_slLog.Text));

      //m_csLog.Acquire;
      m_slLog.Clear;
      m_dtSaveLog:= dtSave;
      //m_csLog.Release;
    except
    end;
  finally
    CloseFile(logFile);
  end;
end;

constructor TCommDIOThread.Create(hMain: THandle; nMsgType: Integer; nServerPort:Integer; nDeviceCount: Integer; bFlushMode:Boolean; nPollingMode: Integer; nLogSaveMode:Integer);
var
  sEventName : WideString;
begin
  m_hMain:= hMain;
  MessageType:= nMsgType;
  m_nDeviceCount:= nDeviceCount;
  FSetMelodyOff := True;
  UseFlushMode:= bFlushMode;
  PollingMode:= nPollingMode;
  PollingInterval:= 1000;
  FlushReadInterval:= 50;
  HeartBeatPeriod:= 1000;
  ExpirationPeriod:= 20000;
  ConnectionTimeout:= 7000;
  ConnectionError:= False;

  LogSaveMode:= nLogSaveMode;
  LogLevel:= 0; //1 + 2 + 4 + 8; //Write + Read + Send + Recv // not Polling(16)
  LogAccumulateCount:= 30;
  LogAccumulateSecond:= 10;

  m_slLog:= TStringList.Create;
  m_csLog:= TCriticalSection.Create;
  m_dtSaveLog:= Now;
  m_csWrite:= TCriticalSection.Create;
  UseMainLog:= False;

  m_sLogPath:= ExtractFilePath(Application.ExeName) + '\Log\CommDIO\';
  if LogSaveMode <> COMMDIO_LOGSAVEMODE_NONE then ForceDirectories(m_sLogPath);

  //���� ������ �迭
  SetLength(DIData, m_nDeviceCount);  //MAX_DIO_DEVICE_COUNT
  SetLength(DIDataPre, m_nDeviceCount);
  SetLength(DOData, m_nDeviceCount);
  SetLength(DODataFlush, m_nDeviceCount);

  FillChar(DIData[0], m_nDeviceCount, 0);
  FillChar(DIDataPre[0], m_nDeviceCount, 0);
  FillChar(DOData[0], m_nDeviceCount, 0);
  FillChar(DODataFlush[0], m_nDeviceCount, 0);

  //����ȭ �۾��� ����� �̺�Ʈ
  sEventName:= Format('TCommDIOThread.WaitForCommandAck%d', [m_hMain]);
  m_hEventCommand:= CreateEvent(nil, False, False, PWideChar(sEventName));
  m_bWaitEvent:= False;
  m_bWorking:= false; //�۾� �� �ƴ�
  m_bFirstConnection:= false;

  m_nLastTick_Recv:= GetTickCount;
  m_nLastTick_Send:= GetTickCount;

  m_nTowerLampTick:= GetTickCount;
  m_nTowerLampState:= 0;
  Process_TowerLamp; //tower Lamp ��ü ����

  DeviceIP:= '192.168.0.99';
  DevicePort:= 6989;

  AddLog('========================================');
  AddLog(format('Create ServerPort=%d, DeviceCount=%d, FlushMode=%d, PollingMode=%d, LogSaveMode=%d', [nServerPort, nDeviceCount, ord(bFlushMode), nPollingMode, nLogSaveMode]));

  try
    m_UDPServer := TIdUDPServer.Create(nil);
    m_UDPServer.DefaultPort := nServerPort;
    m_UDPServer.IPVersion:= Id_IPv4;
    m_UDPServer.ThreadedEvent:= True;
    m_UDPServer.OnUDPException := UDPServerUDPException;
    m_UDPServer.OnUDPRead := UDPServerUDPRead;
    m_UDPServer.Active := True;

    m_UDPClient:= TIdUDPClient.Create(nil);
    m_UDPClient.Active:= True;
  except
    on E: Exception do begin
      //Socket Error # 10048 Address already in use.'.
      AddLog(format('Can not Create: %s', [E.Message]));
      SendMsgMain(COMMDIO_MSG_ERROR, 0, 0, format('%x Can not Create: %s', [TThread.CurrentThread.ThreadID, E.Message]), nil);
    end;

  end;

  inherited Create(True);
end;

destructor TCommDIOThread.Destroy;
begin
  StopThread;
  m_bConnected:= False;

  if m_UDPServer <> nil then begin
    m_UDPServer.OnUDPException := nil;
    m_UDPServer.OnUDPRead:= nil;
    m_UDPServer.Active:= False;
    m_UDPServer.Free;
    m_UDPServer:= nil;
  end;

  if m_UDPClient <> nil then begin
    m_UDPClient.Active:= False;
    FreeAndNil(m_UDPClient);
    m_UDPClient.Free;
    m_UDPClient := nil;
  end;

  AddLog('Destroy', True);

  SetLength(DIData, 0);  //MAX_DIO_DEVICE_COUNT
  SetLength(DIDataPre, 0);
  SetLength(DOData, 0);
  SetLength(DODataFlush, 0);

  DIDataPre:= nil;
  DIData:= nil;
  DOData:= nil;
  DODataFlush:= nil;
  SetEvent(m_hEventCommand);
  CloseHandle(m_hEventCommand);

  m_csWrite.Free;
  m_csLog.Free;
  m_slLog.Free;

  inherited;
end;

procedure TCommDIOThread.DoEvent;
begin
  //Call Event
end;


procedure TCommDIOThread.StopThread;
begin
  //InterlockedIncrement(m_nStop);
  m_nStop:= 1;
  Terminate;
  WaitFor;

end;

procedure TCommDIOThread.SyncMainThread;
begin
  if not Terminated then
  begin
    Synchronize(DoEvent);
  end;
end;

function TCommDIOThread.CalcChecksum(pValue: PByte; nCount: Integer): Integer;
var
  i: Integer;
begin
  Result:= 0;
  for i := 0 to Pred(nCount) do begin
    Result:= Result + pValue[i];
  end;
end;


procedure TCommDIOThread.UDPServerUDPException(AThread: TIdUDPListenerThread;
  ABinding: TIdSocketHandle; const AMessage: String;
  const AExceptionClass: TClass);
begin
  AddLog('UDP Exception : ' + AMessage);
  SendMsgMain(COMMDIO_MSG_ERROR, 0, 0, format('%x UDP Exception : %s', [TThread.CurrentThread.ThreadID, AMessage]), nil); //������ �̺�Ʈ ����
end;

procedure TCommDIOThread.UDPServerUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  pHeader: PDIOHeader;
  sData: String;
  i: Integer;
  nDataLen: Integer;
  bPolling: Boolean;
begin
  if Terminated then Exit;

  sData:= '';
  nDataLen:= Length(AData);
  for i := 0 to Pred(nDataLen) do begin
    sData:= sData + IntToHex(AData[i], 2) + ' ';
  end;

  pHeader:= PDIOHeader(AData);
  if pHeader.Len <> (nDataLen - 4) then begin
    //������ ũ�� ����
    AddLog(format('Size Mismatch (%d:%d): %s', [pHeader.Len+4, nDataLen, sData]));
    SendMsgMain(COMMDIO_MSG_ERROR, 0, 0, format('%x Size Mismatch (%d:%d): %s', [TThread.CurrentThread.ThreadID, pHeader.Len+4, nDataLen, sData]), nil); //������ �̺�Ʈ ����
    Exit;
  end;

  if pHeader.ID = COMMDIO_ID_FIRSTCONNECTION then begin
    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('%x Recv(%d)<= %s', [TThread.CurrentThread.ThreadID, nDataLen, sData]), nil);
    ProcessConnection;
    Exit;
  end;

  if (pHeader.Ack <> 0) and (pHeader.ID <> COMMDIO_ID_FIRSTCONNECTION) then begin
    SetEvent(m_hEventCommand);
    AddLog(format('Recv(%d)<= %s', [nDataLen, sData]));
    AddLog(format('Ack Error ID:%x Ack:(0x%.4x)', [pHeader.ID, pHeader.Ack]));
    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('%x Recv(%d)<= %s', [TThread.CurrentThread.ThreadID, nDataLen, sData]), nil);
    SendMsgMain(COMMDIO_MSG_ERROR, 0, 0, format('%x Ack Error ID:%x Ack:(0x%.4x)', [TThread.CurrentThread.ThreadID, pHeader.ID, pHeader.Ack]), nil);
    Exit;
  end;

  m_nLastAck:= pHeader.Ack;
  m_nLastTick_Recv:= GetTickCount;

  m_bConnected:= True; //���� �����ϸ� ����� �������Ѵ�.

  //CopyMemory(@m_LastCommand, pHeader, SizeOf(m_LastCommand));

  case pHeader.ID of
    COMMDIO_ID_CONNECTION+1: begin //Connection Check
      //Sleep(10); //for debug
    end;

    COMMDIO_ID_EVENTNOTIFY+1: begin
      SetEvent(m_hEventCommand);
    end;

    COMMDIO_ID_READ_DI+1: begin //Read DI
      if m_pRecvData <> nil then  begin
        //Read_DI �� ������ ���� ���
        CopyMemory(m_pRecvData, @pHeader.Data[4], pHeader.Count);
        SetEvent(m_hEventCommand);
      end;

//    if (pHeader.ID = COMMDIO_ID_READ_DI+1) and (pHeader.Addr = 0) and (pHeader.Count = m_nDeviceCount) then begin
//      //Polling�̸�
//    end

      //CopyMemory(@DIDataPre[pHeader.Addr], @@DIData[pHeader.Addr], pHeader.Count);
      CopyMemory(@DIData[pHeader.Addr], @pHeader.Data[4], pHeader.Count);

      ProcessPollingData;
    end;

    COMMDIO_ID_READ_DO+1: begin //Read DO
      if m_pRecvData <> nil then  begin
        //Read_DO �� ������ ���� ���
        CopyMemory(m_pRecvData, @pHeader.Data[2], pHeader.Len-2);
      end else begin
        //SendMsgMain(COMMDIO_MSG_CHANGE_DO, 0, 0, 'DO Data Changed', @DOData[0]);
      end;

      CopyMemory(@DOData[pHeader.Addr], @pHeader.Data[4], pHeader.Count);
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_CLEARDO+1: begin //Clear DO
      FillChar(DOData[0], m_nDeviceCount, 0);
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_WRITE_DO+1: begin //Write DO
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_WRITE_BIT+1: begin //Write DO Bit
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_VERSION+1: begin //Version Info
      CopyMemory(@DeviceInfo, @pHeader.Data[0], 19 + pHeader.Data[18]*4);
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_FILEDOWNLOAD+1: begin //File Download
      SetEvent(m_hEventCommand);
    end;
    COMMDIO_ID_CONFIG+1: begin //Config Setup
      SetEvent(m_hEventCommand);
    end;

    else begin //Unkown

    end;
  end;

  if (LogLevel and $8) = $8 then begin
    bPolling:= (pHeader.ID = COMMDIO_ID_READ_DI+1) and (pHeader.Addr = 0) and (pHeader.Count = m_nDeviceCount); //Polling�̸�
    bPolling:= bPolling or (pHeader.ID = COMMDIO_ID_CONNECTION+1);
    if (not bPolling) or ((LogLevel and $10) = $10) then begin  //not polling data or Polling Log
      AddLog(format('Recv(%.2d)< %s', [nDataLen, sData]));
    end;
  end;

  SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('%x Recv(%.2d)<= %s', [TThread.CurrentThread.ThreadID, nDataLen, sData]), nil);
end;

function TCommDIOThread.GetDIValue(inx: Integer): byte;
begin
  if (inx < 0) or (inx > m_nDeviceCount-1) then Exit(0);

  Result:= DIData[inx];
end;


function TCommDIOThread.GetDOValue(inx: Integer): byte;
begin
  if (inx < 0) or (inx > m_nDeviceCount-1) then Exit(0);
  Result:= DOData[inx];
end;

procedure TCommDIOThread.SendMsgMain(nMsgMode: Integer; nParam, nParam2: Integer; sMsg: String; pData:Pointer);
var
  cds         : TCopyDataStruct;
  COPYDATAMessage : RGuiDaeDio;
begin
  if (nMsgMode = COMMDIO_MSG_LOG) and (not UseMainLog) then Exit;

  COPYDATAMessage.MsgType := MessageType; //MSGTYPE_COMMDIO;
  COPYDATAMessage.Channel := 1;
  COPYDATAMessage.Mode    := nMsgMode;
  COPYDATAMessage.Param   := nParam;
  COPYDATAMessage.Param2  := nParam2;
  COPYDATAMessage.Msg     := sMsg;
  COPYDATAMessage.pData   := pData;

  cds.dwData      := 0;
  cds.cbData      := SizeOf(COPYDATAMessage);
  cds.lpData      := @COPYDATAMessage;


  if Assigned( m_NotifyEvent) then  m_NotifyEvent( Self,@COPYDATAMessage);
  if m_hMain <> 0  then  SendMessage(m_hMain,WM_COPYDATA,0, LongInt(@cds));
end;

function TCommDIOThread.SendBuffer(naValues: TBytes): Integer;
begin
  Result:= SendData(TIdBytes(naValues));
end;

function TCommDIOThread.ReadConfig(out sDeviceIP, sServerIP: string; out nDevicePort, nServerPort, nDeviceCount: Integer): Integer;
var
  nRet   : Cardinal;
begin
  if (LogLevel and $2) = $2 then  AddLog('ReadConfig');

  nRet:= WaitForCommandAck(
    procedure begin
      Send_ReadVerionInfo;
    end
    );

  case nRet of
    WAIT_OBJECT_0 : begin
      //����
      sDeviceIP:= Int2IP(DeviceInfo.DeviceIP);
      sServerIP:= Int2IP(DeviceInfo.ServerIP);
      nDevicePort:= DeviceInfo.DevicePort;
      nServerPort:= DeviceInfo.ServerPort;
      nDeviceCount:= DeviceInfo.Count;
    end;
    WAIT_TIMEOUT  : begin

    end
    else begin

    end;
  end;
  Result:= nRet;
end;

function TCommDIOThread.WriteConfig(sDeviceIP, sServerIP: string; nDevicePort, nServerPort, nDeviceCount: Integer): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
  nIP: UINT;
begin
  AddLog(format('WriteConfig: DeviceIP=%s, DevicePort=%d, ServerIP=%s, ServerPort=%d, DeviceCount=%d',
      [sDeviceIP, nDevicePort, sServerIP, nServerPort, nDeviceCount]));

  SetLength(txBuff, 21);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_CONFIG;
  pHeader.Len:= 17;
  nIP:= IP2Int(sDeviceIP);
  if nIP = 0 then Exit(1); //IP ���� �̻�

  CopyMemory(@pHeader.Data[0], @nIP, 4);
  CopyMemory(@pHeader.Data[4], @nDevicePort, 4);

  nIP:= IP2Int(sServerIP);
  if nIP = 0 then Exit(1); //IP ���� �̻�
  CopyMemory(@pHeader.Data[8], @nIP, 4);
  CopyMemory(@pHeader.Data[12], @nServerPort, 4);

  pHeader.Data[16]:= nDeviceCount;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.SendData(Buff: TIdBytes): Integer;
var
  i, nCount: Integer;
  nDataCount: Integer;
  sData: string;
  pHeader: PDIOHeader;
  bPolling: Boolean;
begin
  //if not m_bConnected then Exit(1);
  if not (m_nStop = 0) then Exit(1);

  try
    //�׽�Ʈ ���α׷� ��- LogLevel ������ ���� �Ѵ�.
    sData:= '';
    nCount:= Length(Buff);
    nDataCount:=  nCount;
    if nDataCount > 100 then begin
      nDataCount:= 100;
    end;
    for i := 0 to Pred(nDataCount) do begin
      sData:= sData + IntToHex(Buff[i], 2) + ' ';
    end;

    if (LogLevel and $4) = $4 then begin
      pHeader:= PDIOHeader(Buff);
      bPolling:= (pHeader.ID = COMMDIO_ID_READ_DI) and (pHeader.Data[0] = 0) and (pHeader.Data[1] = m_nDeviceCount); //Polling�̸�
      bPolling:= bPolling or (pHeader.ID = COMMDIO_ID_CONNECTION);
      if (not bPolling) or ((LogLevel and $10) = $10) then begin  //not polling data or Polling Log
//        sData:= '';
//        nCount:= Length(Buff);
//        nDataCount:=  nCount;
//        if nDataCount > 100 then begin
//          nDataCount:= 100;
//        end;
//        for i := 0 to Pred(nDataCount) do begin
//          sData:= sData + IntToHex(Buff[i], 2) + ' ';
//        end;
        AddLog(format('Send(%.2d)> %s', [nCount, sData]));
      end;
    end;

    m_csWrite.Acquire;
    m_UDPClient.SendBuffer(DeviceIP, DevicePort, Buff);
    m_csWrite.Release;

    m_nLastTick_Send:= GetTickCount;
    //Test App�� ����
    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('%.4x Send(%.2d)=> %s', [TThread.CurrentThread.ThreadID, nCount, sData]), nil);
    Result:= 0;
  except
    on E: Exception do begin
      AddLog('Exception in SendData: ' + E.Message);
      SendMsgMain(COMMDIO_MSG_ERROR, 255, 0, 'Exception in SendData: ' + E.Message);
      Result:= 255;
    end;
  end;
end;


function TCommDIOThread.WriteFile(sFileName: string): Integer;
var
  fs: TFileStream;
  TxBuff: TIdBytes;
  nFileSize, nCountPacket: Integer;
  nPackerSize, nModSize: Integer;
  nHeaderSize, nCheckSum: Integer;
  nRetry: Integer;
  nRet: Integer;
  i, k: Integer;
  pHeader: PDIOHeader;
begin
  Result:= 1;
  if not FileExists(sFileName) then begin
    //File not Found
    Exit;
  end;
  nPackerSize:= 1024;
  nHeaderSize:= 6;
  nRetry:= 1;
  nRet:= 0;
  fs:= TFileStream.Create(sFileName, fmOpenRead + fmShareDenyWrite);

  try
    nFileSize:= Integer(fs.Size);
    nCountPacket:= nFileSize div nPackerSize;
    nModSize:= nFileSize mod nPackerSize;

    AddLog(format('WriteFile FileSize=%d, ModeSize=%d, PacketCount=%d, %s',
        [nFileSize, nModSize, nCountPacket, sFileName]));

    SendMsgMain(COMMDIO_MSG_LOG, 0, 0, format('%.4x WriteFile FileSize=%d, ModeSize=%d, PacketCount=%d, %s',
        [TThread.CurrentThread.ThreadID, nFileSize, nModSize, nCountPacket, sFileName]), nil);
    //////////////////////////////////////////////////////
    //Polling Stop
    m_bWorking:= True;
    //////////////////////////////////////////////////////
    //Send Start
    SetLength(TxBuff, 4 + nHeaderSize);

    pHeader:= PDIOHeader(TxBuff);
    pHeader.ID:= COMMDIO_ID_FILEDOWNLOAD;
    pHeader.Len:= nHeaderSize;
    pHeader.Data[0] := 0; //Type
    pHeader.Data[1] := ord('S'); //Mode
    CopyMemory(@pHeader.Data[2], @nFileSize, 4); //sizeof(nFileSize));
    for k := 0 to nRetry do begin
      nRet:= WaitForCommandAck(
        procedure begin
          SendData(TxBuff);
        end
      );

      if nRet = WAIT_OBJECT_0 then begin
        break; //for k
      end;
    end;
    if nRet <> WAIT_OBJECT_0 then begin
        Result:= nRet;
        m_bWorking:= False;
        Exit;
    end;

    //////////////////////////////////////////////////////
    //Send File Data
    nCheckSum:= 0;
    SetLength(TxBuff, 4 + nHeaderSize + nPackerSize);
    pHeader:= PDIOHeader(TxBuff);
    pHeader.ID:= COMMDIO_ID_FILEDOWNLOAD;
    pHeader.Len:= nHeaderSize + nPackerSize; //8 + 1024 = 1034
    pHeader.Data[0] := 0; //Type
    pHeader.Data[1] := ord('D');

    for i := 0 to Pred(nCountPacket) do begin
      CopyMemory(@pHeader.Data[2], @i, 4); //Index

      fs.Read(pHeader.Data[6], nPackerSize);
      nCheckSum:= nCheckSum + CalcChecksum(@pHeader.Data[6], nPackerSize);
      for k := 0 to nRetry do begin
        nRet:= WaitForCommandAck(
          procedure begin
            SendData(TxBuff);
          end
        );
        if nRet = WAIT_OBJECT_0 then begin
          break; //for k
        end;
      end;
      if nRet <> WAIT_OBJECT_0 then begin
        break; //for i
      end;
    end; //for i := 0 to Pred(nCountPacket) do begin
    if nRet <> WAIT_OBJECT_0 then begin
      Result:= nRet;
      m_bWorking:= False;
      Exit;
    end;

    //////////////////////////////////////////////////////
    //Send Mod Data
    if nModSize > 0 then begin
      SetLength(TxBuff, 4 + nHeaderSize + nModSize);
      pHeader:= PDIOHeader(TxBuff);
      pHeader.ID:= COMMDIO_ID_FILEDOWNLOAD;
      pHeader.Len:= nHeaderSize + nModSize;
      pHeader.Data[0] := 0; //Type
      pHeader.Data[1] := ord('D');
      CopyMemory(@pHeader.Data[2], @nCountPacket, 4); //Index

      fs.Read(pHeader.Data[6], nModSize);
      nCheckSum:= nCheckSum + CalcChecksum(@pHeader.Data[6], nModSize);

      for k := 0 to nRetry do begin
        nRet:= WaitForCommandAck(
          procedure begin
            SendData(TxBuff);
          end
        );
        if nRet = WAIT_OBJECT_0 then begin
          break; //for k
        end;
      end;
    end;
    if nRet <> WAIT_OBJECT_0 then begin
      Result:= nRet;
      m_bWorking:= False;
      Exit;
    end;

    //////////////////////////////////////////////////////
    //Send End;
    SetLength(TxBuff, 4 + nHeaderSize);
    pHeader:= PDIOHeader(TxBuff);
    pHeader.ID:= COMMDIO_ID_FILEDOWNLOAD;
    pHeader.Len:= nHeaderSize;
    pHeader.Data[0] := 0; //Type
    pHeader.Data[1] := ord('E');
    CopyMemory(@pHeader.Data[2], @nCheckSum, 4); //Check sum

    for k := 0 to nRetry do begin
      nRet:= WaitForCommandAck(
        procedure begin
          SendData(TxBuff);
        end
      );

      if nRet = WAIT_OBJECT_0 then begin
        break; //for k
      end;
    end;
    //////////////////////////////////////////////////////
    //Polling Restart
    m_bWorking:= False;
    Result:= 0;
  finally
    fs.Free;
    //Polling Restart
    m_bWorking:= False;
  end;
end;

function TCommDIOThread.Send_HeatBeat: Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 4);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_CONNECTION;
  pHeader.Len:= 0;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_ClearDO(nAddr, nCount: Byte): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 6);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_CLEARDO;
  pHeader.Len:= 2;
  pHeader.Data[0]:= nAddr;
  pHeader.Data[1]:= nCount;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_EventNotify(nValue: Byte): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 5);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_EVENTNOTIFY;
  pHeader.Len:= 1;
  pHeader.Data[0]:= nValue;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_File(nTpye, nMode, nIndex, nCount: Integer; var naValues: TIdBytes): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(TxBuff, 6 + nCount);
  pHeader:= PDIOHeader(TxBuff);
  pHeader.ID:= COMMDIO_ID_FILEDOWNLOAD;
  pHeader.Len:= nCount + 2;
  pHeader.Data[0]:= nTpye;
  pHeader.Data[1]:= nMode;
  CopyMemory(@pHeader.Data[2], @naValues[0], nCount);

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_ReadDI(nAddr, nCount: Byte): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 6);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_READ_DI;
  pHeader.Len:= 2;
  pHeader.Data[0]:= nAddr;
  pHeader.Data[1]:= nCount;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_ReadDO(nAddr, nCount: Byte): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 6);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_READ_DO;
  pHeader.Len:= 2;
  pHeader.Data[0]:= nAddr;
  pHeader.Data[1]:= nCount;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_ReadVerionInfo: Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 4);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_VERSION;
  pHeader.Len:= 0;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_WriteBit(nAddr, nCount: Byte; var nData: Byte): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(txBuff, 7);
  pHeader:= PDIOHeader(txBuff);
  pHeader.ID:= COMMDIO_ID_WRITE_BIT;
  pHeader.Len:= 3;
  pHeader.Data[0]:= nAddr;
  pHeader.Data[1]:= nCount;
  pHeader.Data[2]:= nData;

  Result:= SendData(TxBuff);
end;

function TCommDIOThread.Send_WriteDO(nAddr, nCount: Byte; var naValues: TBytes): Integer;
var
  TxBuff: TIdBytes;
  pHeader: PDIOHeader;
begin
  SetLength(TxBuff, 6 + nCount);
  pHeader:= PDIOHeader(TxBuff);
  pHeader.ID:= COMMDIO_ID_WRITE_DO;
  pHeader.Len:= nCount + 2;
  pHeader.Data[0]:= nAddr;
  pHeader.Data[1]:= nCount;
  CopyMemory(@pHeader.Data[2], @naValues[0], nCount);

  Result:= SendData(TxBuff);
end;

procedure TCommDIOThread.Execute;
var
  nTick: Cardinal;
  nRet: Integer;
begin
  inherited;
  m_nStop:= 0;
  nTick := 0;
(*
  m_UDPServer := TIdUDPServer.Create(nil);
  m_UDPServer.ThreadedEvent:= True;
  m_UDPServer.DefaultPort := Port;
  m_UDPServer.IPVersion:= Id_IPv4;
  m_UDPServer.OnUDPException := UDPServerUDPException;
  m_UDPServer.OnUDPRead := UDPServerUDPRead;
  m_UDPServer.Active := True;

  m_UDPClient:= TIdUDPClient.Create(nil);
  m_UDPClient.Active:= True;
*)

  //while not Terminated do begin
  while m_nStop = 0 do begin
    if not m_UDPServer.Active then begin
      //���� ���� ���� �� ����
      m_UDPServer.Active:= true;
      WaitForSingleObject(self.Handle, PollingInterval); //�翬�� ������
      continue;
    end;

    nTick:= GetTickCount;

    if not m_bFirstConnection then begin
      if (not ConnectionError) and (nTick  > (m_nLastTick_Recv + ConnectionTimeout)) then begin
        AddLog('Can not Connect **********');
        SendMsgMain(COMMDIO_MSG_ERROR, 100, 0, format('%.4x Can not Connect (%s)', [TThread.CurrentThread.ThreadID, FormatDateTime('HH:NN:SS.ZZZ', Now)]), nil);
        ConnectionError:= True;
        //m_nLastTick_Recv:= nTick; //���� �������� ��� �˶� ����
      end;
      WaitForSingleObject(self.Handle, PollingInterval);
      continue; //ù ����ó�� ������ ���� ����
    end;

    if not m_bConnected then begin
      WaitForSingleObject(self.Handle, PollingInterval);
      continue;
    end;

    if m_bWorking then begin
      WaitForSingleObject(self.Handle, PollingInterval);
      continue; //�ٸ� �۾��� ���� ���� ��� ���� ����- Write File
    end;

    if nTick > (m_nLastTick_Send + HeartBeatPeriod) then begin
      Send_HeatBeat; //���� �ð� ���� ����� ���� ��� HeartBeat ����
    end;

    if nTick > (m_nLastTick_Recv + ExpirationPeriod) then begin
      //lost Connection
      AddLog('Lost Connection **********: ' + IntToStr(abs(nTick - m_nLastTick_Recv)));
      m_bConnected:= False;
//      m_bFirstConnection:= false;
      SendMsgMain(COMMDIO_MSG_CONNECT, 0, 0, format('%.4x Lost Connection (%s)', [TThread.CurrentThread.ThreadID, FormatDateTime('HH:NN:SS.ZZZ', Now)]), nil); //������ �̺�Ʈ ����
    end;

    //Ÿ�� ���� ó��
    //Process_TowerLamp;

    nRet:= 0;
    //Flush Mode�� ���  ���� ó��
    if UseFlushMode then begin
      nRet:= WriteFlushData;
      //���� �� �б� ���
      if (nRet <> 0) and (FlushReadInterval <> 0) then begin
        Sleep(FlushReadInterval);
        //ReadPollingData;
      end;
    end;

    if (nRet <> 0) or ((PollingMode and $01) = $01) then begin //Polling ����� ���
      ReadPollingData; //������ ����
    end;

    WaitForSingleObject(self.Handle, PollingInterval);
  end;
(*
  if m_UDPServer <> nil then begin
    m_UDPServer.OnUDPException := nil;
    m_UDPServer.OnUDPRead:= nil;
    m_UDPServer.Active:= False;
    FreeAndNil(m_UDPServer);
  end;

  if m_UDPClient <> nil then begin
    m_UDPClient.Active:= False;
    FreeAndNil(m_UDPClient);
  end;
*)
end;

function TCommDIOThread.ReadPollingData: Integer;
begin
  if not m_bConnected then Exit(1);
  Result:= Send_ReadDI(0, m_nDeviceCount);
end;

function TCommDIOThread.WriteFlushData: Integer;
var
  i: Integer;
  bChange: Boolean;
begin
  Result:= 0;
  if Terminated then Exit;
  bChange:= False;
  for i := 0 to Pred(m_nDeviceCount) do begin
    if DODataFlush[i] <>  DOData[i] then begin
      bChange:= True;
      break;
    end;
  end;

  if bChange then begin
    CopyMemory(@DOData[0], @DODataFlush[0], m_nDeviceCount);

    Send_WriteDO(0, m_nDeviceCount, DODataFlush);

    SendMsgMain(COMMDIO_MSG_CHANGE_DO, 0, 0, 'DO Data Changed', @DODataFlush[0]);
    //PostMessage(m_hMain,WM_USER+1, MSGTYPE_COMMDIO, COMMDIO_MSG_CHANGE_DO);
//    //���� �� �ѹ� �б� ó��
//    if FlushReadInterval <> 0 then begin
//      Sleep(FlushReadInterval);
//      //ReadPollingData;
//    end;
    Result:= 1; //Changed
  end;
end;


procedure TCommDIOThread.ProcessConnection;
var
  nRet: Integer;
  nValue: Byte;
begin
  AddLog('Process Connection **********');
  //Device ���� �� ó��//���� ���� ��û �� ���� ����
  TThread.CreateAnonymousThread(
    procedure begin
      Send_HeatBeat;

      Sleep(50);

      nRet:= WaitForCommandAck(
        procedure begin
          Send_ReadVerionInfo;
        end
      );
      Sleep(50);
      nRet:= WaitForCommandAck(
        procedure begin
          //Send_ClearDO(0, m_nDeviceCount);
          Send_ReadDO(0, m_nDeviceCount);
        end
      );
      Sleep(50);
      nValue:= ord((PollingMode and $02) = $02);
      nRet:= WaitForCommandAck(
          procedure begin
            Send_EventNotify(nValue);
          end
        );
      Sleep(50);
      nRet:= WaitForCommandAck(
        procedure begin
          Send_ReadDI(0, m_nDeviceCount);
        end
      );
      //ReadPollingData; //ó�� �ѹ��� ������ DI �б�
      //Sleep(500);
      CopyMemory(@DODataFlush[0], @DOData[0], m_nDeviceCount);
      //���� �˻�
//      for i:= 1 to Pred(DeviceInfo.Count) do begin
//        if DeviceInfo.Version[0] <> DeviceInfo.Version[i] then begin
//          //���� ��ġ ����
//          SendMsgMain(COMMDIO_MSG_CONNECT, 1, 1, format('%x Device Version Mismatch %x: %x)', [TThread.CurrentThread.ThreadID, DeviceInfo.Version[0], DeviceInfo.Version[i]]), nil); //������ �̺�Ʈ ����
//          break;
//        end;
//      end;

      AddLog('Connected **********');
      SendMsgMain(COMMDIO_MSG_CONNECT, 1, 0, format('%.4x Connected (%s)', [TThread.CurrentThread.ThreadID, FormatDateTime('HH:NN:SS.ZZZ', Now)]), nil); //������ �̺�Ʈ ����

      m_bFirstConnection:= True;
    end).Start;
end;

procedure TCommDIOThread.ProcessPollingData;
var
  i, k: Integer;
  bChanged: Boolean;
  sChangedList: String;
  nValue: Byte;
begin

  if m_nStop <> 0 then Exit;
  if Terminated then Exit;

  bChanged:= False;
  sChangedList:= '';
  for i := 0 to Pred(m_nDeviceCount) do begin
    if DIData[i] <> DIDataPre[i] then begin
      for k := 0 to 7 do begin
        nValue:= Get_Bit(DIData[i], k);
        if nValue <> Get_Bit(DIDataPre[i], k) then begin
          if sChangedList = '' then sChangedList:= sChangedList + format('%d=%d', [i*8+k, nValue])
          else sChangedList:= sChangedList + format(',%d=%d', [i*8+k, nValue]);
        end;
      end;
      bChanged:= True; //������ ���� ��
    end;
  end;

  if  bChanged then begin
    AddLog('Changed DI: ' + sChangedList);
    //if m_bFirstConnection then begin
      SendMsgMain(COMMDIO_MSG_CHANGE_DI, 0, 0, sChangedList, @DIDataPre[0]);
    //end;
    CopyMemory(@DIDataPre[0], @DIData[0], sizeof(DIData[0])* m_nDeviceCount);
  end;

end;

{ LAMP_STATE_NONE     = 0;
  LAMP_STATE_MANUAL   = LAMP_STATE_NONE + 2;
  LAMP_STATE_PAUSE    = LAMP_STATE_NONE + 4;
  LAMP_STATE_AUTO     = LAMP_STATE_NONE + 8;
  LAMP_STATE_REQUEST  = LAMP_STATE_NONE + 16;
  LAMP_STATE_ERROR    = LAMP_STATE_NONE + 32;
  LAMP_STATE_EMEGENCY = LAMP_STATE_NONE + 64;}
procedure TCommDIOThread.Process_TowerLamp;
var
  nTick: Cardinal;
  i : Integer;
begin
  //�˶��� ���� ��� �� �� ��ε� ó��
  nTick:= GetTickCount;

  case m_nTowerLampState of
    0: begin
      //��ü ����
      if Get_Bit(DOData[0], 0) <> 0 then WriteDO_Bit(0, 0, 0); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
      if Get_Bit(DOData[0], 4) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
      if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
      if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
    end;
    2: begin    // LAMP_STATE_MANUAL
      //���� �غ� ��, ����/Pass Mode  - ���� On
      if Get_Bit(DOData[0], 0) <> 1 then WriteDO_Bit(0, 0, 1); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
      if Get_Bit(DOData[0], 4) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
    end;
    4: begin   // LAMP_STATE_PAUSE
      //���� �غ� �Ϸ� ���� ��- ��� ����
      if Get_Bit(DOData[0], 0) <> 0 then WriteDO_Bit(0, 0, 0); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      //���� �ð� ���� 500ms �̻��̸�
      if (nTick - m_nTowerLampTick > 450) then begin
        if Get_Bit(DOData[0], 1) <> 0 then begin
          WriteDO_Bit(0, 1, 0); //Yellow Lamp
        end
        else begin
          WriteDO_Bit(0, 1, 1); //Yellow Lamp
        end;
        m_nTowerLampTick:= nTick;
      end;
      for i := 0 to 4 do begin
        if FSetMelodyOk = i then begin
          if Get_Bit(DOData[0], 3+i) <> 1 then WriteDO_Bit(0, 3+i, 1); //Melody #3
        end
        else begin
          if Get_Bit(DOData[0], 3+i) <> 0 then WriteDO_Bit(0, 3+i, 0); //Melody #1
        end;
      end;
//      if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
//      if Get_Bit(DOData[0], 7) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
//      if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
//      if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
    end;
    8: begin       // LAMP_STATE_AUTO
      //���� �غ� �Ϸ� ��- ��� On
      if Get_Bit(DOData[0], 0) <> 0 then WriteDO_Bit(0, 0, 0); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 1 then WriteDO_Bit(0, 2, 1); //Green Lamp
      if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
      if Get_Bit(DOData[0], 4) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
      if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
      if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
    end;
    16: begin     // LAMP_STATE_REQUEST
      // ���� ���.
      if Get_Bit(DOData[0], 0) <> 1 then WriteDO_Bit(0, 0, 1); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
      if Get_Bit(DOData[0], 4) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
      if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
      if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
    end;
    32: begin   // LAMP_STATE_ERROR
      //Error �߻��� - ���� ����, ��ε�
      if (nTick - m_nTowerLampTick > 450) then begin
        if Get_Bit(DOData[0], 0) <> 0 then begin
          WriteDO_Bit(0, 0, 0); //RED Lamp
        end
        else begin
          WriteDO_Bit(0, 0, 1); //RED Lamp
        end;
        m_nTowerLampTick:= nTick;
      end;
      //if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      if not FSetMelodyOff then begin
        for i := 0 to 4 do begin
          if FSetMelodyL = i then begin
            if Get_Bit(DOData[0], 3+i) <> 1 then WriteDO_Bit(0, 3+i, 1); //Melody #1
          end
          else begin
            if Get_Bit(DOData[0], 3+i) <> 0 then WriteDO_Bit(0, 3+i, 0); //Melody #1
          end;
        end;
//        if Get_Bit(DOData[0], 3) <> 1 then WriteDO_Bit(0, 3, 1); //Melody #1
//        if Get_Bit(DOData[0], 4) <> 0 then WriteDO_Bit(0, 4, 0); //Melody #2
//        if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
//        if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
      end;
    end;
    64: begin
      //��� ���� - ���� On, ��ε�
      if Get_Bit(DOData[0], 0) <> 1 then WriteDO_Bit(0, 0, 1); //RED Lamp
      if Get_Bit(DOData[0], 1) <> 0 then WriteDO_Bit(0, 1, 0); //Yellow Lamp
      if Get_Bit(DOData[0], 2) <> 0 then WriteDO_Bit(0, 2, 0); //Green Lamp
      if not FSetMelodyOff then begin
        for i := 0 to 4 do begin
          if FSetMelodyH = i then begin
            if Get_Bit(DOData[0], 3+i) <> 1 then WriteDO_Bit(0, 3+i, 1); //Melody #1
          end
          else begin
            if Get_Bit(DOData[0], 3+i) <> 0 then WriteDO_Bit(0, 3+i, 0); //Melody #1
          end;
        end;
//        if Get_Bit(DOData[0], 3) <> 0 then WriteDO_Bit(0, 3, 0); //Melody #1
//        if Get_Bit(DOData[0], 4) <> 1 then WriteDO_Bit(0, 4, 1); //Melody #2
//        if Get_Bit(DOData[0], 5) <> 0 then WriteDO_Bit(0, 5, 0); //Melody #3
//        if Get_Bit(DOData[0], 6) <> 0 then WriteDO_Bit(0, 6, 0); //Melody #4
      end;
    end;
    else begin

    end;
  end;
end;

function TCommDIOThread.ReadDI(nAddr, nCount: Byte; out naValues: TBytes; bWaitReply: Boolean): Integer;
var
  nRet   : Cardinal;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);

  if (LogLevel and $2) = $2 then  AddLog(format('ReadDI: Addr=%d, Count=%d', [nAddr, nCount]));


  if not bWaitReply then begin
    nRet:= Send_ReadDI(nAddr, nCount);
  end
  else begin
    m_pRecvData:= @naValues;
    nRet:= WaitForCommandAck(
      procedure begin
        Send_ReadDI(nAddr, nCount);
      end
      );

    case nRet of
      WAIT_OBJECT_0 : begin
        //����
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;
  Result:= nRet;
  m_pRecvData:= nil;
end;


function TCommDIOThread.ReadDO(nAddr, nCount: Byte; bWaitReply: Boolean): Integer;
var
  nRet   : Cardinal;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);

  if (LogLevel and $2) = $2 then  AddLog(format('ReadDO: Addr=%d, Count=%d', [nAddr, nCount]));

  if not bWaitReply then begin
    nRet:= Send_ReadDO(nAddr, nCount);
  end
  else begin
    nRet:= WaitForCommandAck(
      procedure begin
        Send_ReadDO(nAddr, nCount);
      end
      );

    case nRet of
      WAIT_OBJECT_0 : begin
        //����
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;
  Result:= nRet;
end;


function TCommDIOThread.ClearDO(nAddr, nCount: Byte; bWaitReply: Boolean): Integer;
var
  nRet   : Cardinal;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);

  if (LogLevel and $1) = $1 then  AddLog(format('ClearDO: Addr=%d, Count=%d', [nAddr, nCount]));

  if UseFlushMode then begin
    m_csWrite.Acquire;
    FillChar(DODataFlush[nAddr], nCount, 0);
    m_csWrite.Release;
    Exit(0);
  end;

  if not bWaitReply then begin
    nRet:= Send_ClearDO(nAddr, nCount);
    if nRet = 0 then begin
      FillChar(DOData[nAddr], nCount, 0);
    end;
  end
  else begin
    nRet:= WaitForCommandAck(
      procedure begin
        Send_ClearDO(nAddr, nCount);
      end
      );
    if m_nLastAck <> 0 then begin

    end;

    case nRet of
      WAIT_OBJECT_0 : begin
        //����
        FillChar(DOData[nAddr], nCount, 0);
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;
  Result:= nRet;
end;

function TCommDIOThread.WriteDO(nAddr, nCount: Byte; naValues: TBytes; bWaitReply: Boolean): Integer;
var
  nRet   : Cardinal;
  sData: String;
  i: Integer;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);

  if (LogLevel and $1) = $1 then begin
    sData:= '';
    for i := 0 to High(naValues) do begin
      sData:= sData + ' ' + IntToStr(naValues[i]);
    end;
    AddLog(format('WriteDO: Addr=%d, nCount=%d, Data=%s', [nAddr, nCount, sData]));
  end;

  if UseFlushMode then begin
    m_csWrite.Acquire;
    CopyMemory(@DODataFlush[nAddr], @naValues[0], nCount);
    m_csWrite.Release;
    Exit(0);
  end;

  if not bWaitReply then begin
    nRet:= Send_WriteDO(nAddr, nCount, naValues);
    if nRet = 0 then begin
      CopyMemory(@DOData[nAddr], @naValues[0], nCount); //���� �ʰ� ���� ����
    end;
  end
  else begin
    nRet:= WaitForCommandAck(
      procedure begin
        Send_WriteDO(nAddr, nCount, naValues);
      end
      );
    if m_nLastAck <> 0 then begin

    end;

    case nRet of
      WAIT_OBJECT_0 : begin
        //����
        CopyMemory(@DOData[nAddr], @naValues[0], nCount); //���� �ʰ� ���� ����
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;
  Result:= nRet;
end;

function TCommDIOThread.WriteDO_Bit(nAddr, nBitLoc, nValue: Byte; bWaitReply: Boolean): Integer;
var
  nRet   : Cardinal;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);
  if nBitLoc > 7 then Exit(3);

  if (LogLevel and $1) = $1 then  AddLog(format('WriteDO_Bit: Addr=%d, BitLoc=%d, Data=%d', [nAddr, nBitLoc, nValue]));

  if UseFlushMode then begin
    m_csWrite.Acquire;
    Set_Bit(DODataFlush[nAddr], nBitLoc, nValue);
    m_csWrite.Release;
    Exit(0);
  end;

  if not bWaitReply then begin
    nRet:= Send_WriteBit(nAddr, nBitLoc, nValue);
    if nRet = 0 then begin
      Set_Bit(DOData[nAddr], nBitLoc, nValue); //���� �����Ϳ� �ݿ�
    end;
  end
  else begin
    nRet:= WaitForCommandAck(
      procedure begin
        Send_WriteBit(nAddr, nBitLoc, nValue);
      end
      );
    if m_nLastAck <> 0 then begin

    end;

    case nRet of
      WAIT_OBJECT_0 : begin
        //����
        Set_Bit(DOData[nAddr], nBitLoc, nValue); //���� �����Ϳ� �ݿ�
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;
  Result:= nRet;
end;

function TCommDIOThread.WriteDO_FlushBit(nAddr, nBitLoc, nValue: Byte): Integer;
begin
  if not m_bConnected then Exit(1);
  if nAddr > m_nDeviceCount-1 then Exit(2);
  if nBitLoc > 7 then Exit(3);
  if not UseFlushMode then Exit(4);

  if (LogLevel and $1) = $1 then  AddLog(format('WriteDO_FlushBit: Addr=%d, BitLoc=%d, Data=%d', [nAddr, nBitLoc, nValue]));

  Result:= 0;
  m_csWrite.Acquire;
  Set_Bit(DODataFlush[nAddr], nBitLoc, nValue);
  m_csWrite.Release;
end;

function TCommDIOThread.WriteEventNotify(nValue: Byte): Integer;
var
  nRet   : Cardinal;
begin
  if not m_bConnected then Exit(1);
  nRet:= Send_EventNotify(nValue);
  if nRet = 0 then begin
    Set_Bit(PollingMode, 1, nValue); //Notify ��Ʈ ����
  end;

  Result:= nRet;
end;

function TCommDIOThread.Get_Bit(nData, nLoc: byte): byte;
begin
  Result := (nData shr nLoc) and $01;
end;

procedure TCommDIOThread.Set_Bit(var nData: byte; nLoc, Value: byte);
begin
  if Value = 0 then
  begin
    nData := (nData and not (1 shl nLoc));
  end else
  begin
    nData := nData or (1 shl nLoc);
  end;
end;

procedure TCommDIOThread.SetSetMelodyH(const Value: Integer);
begin
  FSetMelodyH := Value;
end;

procedure TCommDIOThread.SetSetMelodyL(const Value: Integer);
begin
  FSetMelodyL := Value;
end;

procedure TCommDIOThread.SetSetMelodyOff(const Value: Boolean);
begin
  FSetMelodyOff := Value;
end;

procedure TCommDIOThread.SetSetMelodyOk(const Value: Integer);
begin
  FSetMelodyOk := Value;
end;

procedure TCommDIOThread.Set_Bit(var nData: byte; nLoc: byte; Value: Boolean);
begin
  if Value = False then
  begin
    nData := (nData and not (1 shl nLoc));
  end else
  begin
    nData := nData or (1 shl nLoc);
  end;
end;


function TCommDIOThread.IsBitOn(var nData: byte; nLoc: byte): Boolean;
begin
  Result := (nData shr nLoc) and $01 = $01;
end;

function TCommDIOThread.IsDIOn(nAddr, nLoc: byte): Boolean;
begin
  if nAddr >= m_nDeviceCount then  Exit(False);
  if nLoc > 7 then  Exit(False);

  Result := (DIData[nAddr] shr nLoc) and $01 = $01;
end;

function TCommDIOThread.IsDIOn(nIndex: byte): Boolean;
begin
  Result := IsDIOn(nIndex div 8, nIndex mod 8);
end;


procedure TCommDIOThread.Set_LogPath(sValue: String);
begin
  if m_sLogPath <> sValue then begin
    m_sLogPath:= sValue;
    ForceDirectories(m_sLogPath);
  end;
end;

procedure TCommDIOThread.Set_TowerLampState(nState: Integer);
begin
  m_nTowerLampState:= nState;
  Process_TowerLamp;
end;

function TCommDIOThread.Int2IP(nIP: UINT): String;
var
  nValue: UINT;
begin
  Result:= '';
  if nIP >= 4294967295 then begin
    Result:= '255.255.255.255';
  end
  else begin
    nValue:= (nIP shr 24) and $FF;
    Result:= IntToStr(nValue);
    nValue:= (nIP shr 16) and $FF;
    Result:= Result + '.' + IntToStr(nValue);
    nValue:= (nIP shr 8) and $FF;
    Result:= Result + '.' + IntToStr(nValue);
    nValue:= nIP and $FF;
    Result:= Result + '.' + IntToStr(nValue);
(*
    Result:= IntToStr((nIP shr 24) and $FF) + '.'
      + IntToStr((nIP shr 16) and $FF) + '.'
      + IntToStr((nIP shr 8) and $FF) + '.'
      + IntToStr(nIP  and $FF);
*)
  end;
end;


function TCommDIOThread.IP2Int(sIP: string): UINT;
var
  sa: TArray<String>;
  i: Integer;
  nValue, nIP: UINT;
begin
  Result:= 0;
  sa:= sIP.Split(['.']);
  if Length(sa) <> 4 then Exit;
  nIP:= 0;
  for i := 0 to 3 do begin
    nValue:= StrToIntDef(sa[i], 256);
    if (nValue > 255) then Exit;
    nValue:=  nValue shl ((3-i)*8); //for Byte Order
    nIP:= nIP + nValue;
  end;
  Result:= nIP;
end;

function TCommDIOThread.WaitForCommandAck(CommandProc: TProc; nWaitTime, nRetry: Integer): Cardinal;
var
  nRet   : Cardinal;
  i      : Integer;
begin
  nRet := WAIT_FAILED;

  //m_bWorking:= True;
  //m_bWaitEvent:= True;
  for i := 0 to nRetry do begin

    ResetEvent(m_hEventCommand);

    CommandProc; //���� �۾�

    nRet := WaitForSingleObject(m_hEventCommand, nWaitTime);

    case nRet of
      WAIT_OBJECT_0 : begin
        break;
      end;
      WAIT_TIMEOUT  : begin

      end
      else begin

      end;
    end;
  end;

  //m_bWorking:= False;
  //m_bWaitEvent:= False;
  Result:= nRet;
end;

function TCommDIOThread.WaitSignal(nAddr, nBitLoc, nValue: Byte; nWaitTime: Cardinal): Cardinal;
var
  nTick, nStartTick: Cardinal;
begin
  Result:= 1;
  nStartTick:= GetTickCount;
  nTick:= nStartTick;

  while (nTick - nStartTick) < nWaitTime  do begin
    if Get_Bit(DIData[nAddr], nBitLoc) = nValue then begin
    //if IsDIOn(nAddr, nBitLoc) = nValue then begin
      Result:= 0;
      break;
    end;
    Sleep(1);
    nTick:= GetTickCount;
  end;
end;

end.

