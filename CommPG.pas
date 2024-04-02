unit CommPG;

interface
{$I Common.inc}

uses
  System.Classes, System.SysUtils, System.Threading,
  Winapi.Windows, Winapi.Messages, Winapi.WinSock,
  IdGlobal,
  IdSocketHandle, IdUDPClient, IdUDPServer, LibFTPClient,
  Vcl.Dialogs, Vcl.ExtCtrls,
	//
  DefCommon, DefPG,
	{$IF Defined(INSEPECTOR_FI) or Defined(INSEPECTOR_OQA) or Defined(PAS_SCRIPT)}
  DefScript,
	{$ENDIF}

  CommonClass, DongaPattern,System.Diagnostics,
{$IFDEF DEBUG}
  CodeSiteLogging,
{$ENDIF}
  UserUtils;	

type

	//------------------------------------- Pattern
  TCurPatDispInfo = record  //#RPatDispStatus
    bPowerOn        : Boolean;  //TBD:DP860?
    bPatternOn      : Boolean;  //TBD:DP860?
    nCurPatNum      : Integer;
    nCurAllPatIdx   : Integer;  //index of AllPat
    bSimplePat      : Boolean;
    {$IFDEF FEATURE_GRAY_CHANGE}
    nGrayOffset     : Integer;  //Gray Change Offset Value (-255~255)
    bGrayChangeR, bGrayChangeG, bGrayChangeB : Boolean;  //if (Simple Pattern) and (R|G|B Valuse is not 0) then True else False
    {$ENDIF}
    {$IFDEF FEATURE_DIMMING_STEP}
    nCurPwmDuty     : Integer; //0~100
    nCurDimmingStep : Integer; //1~4
    {$ENDIF}
  end;

	TPatInfoStruct  = record  //#TPatInfoStruct
	  PatInfo : array[0..MAX_PATTERN_CNT-1] of TPatternInfo;
  //CurrPat : RPatDispStatus;  //FEATURE_GRAY_CHANGE, FEATURE_DIMMING_STEP
	end;

	//-------------------------------------------------------- GUI
  PGuiPg2Main = ^RGuiPg2Main;
  RGuiPg2Main = record
    MsgType  : Integer;
    PgNo     : Integer;
    Mode     : Integer;
    Param    : Integer;
    sMsg     : string;
  end;

  PGuiPg2Test = ^RGuiPg2Test; //#TransVoltage
  RGuiPg2Test = record
    MsgType  : Integer;
    PgNo     : Integer;
    Mode     : Integer;
    Param    : Integer;
    sMsg     : string;
    PwrData  : TPwrData; //AF9(dummy)
  end;

  PGuiPgDown = ^RGuiPgDown; //TBD:DP860?
  RGuiPgDown = record
    MsgType  : Integer;
    PgNo     : Integer;
    Mode     : Integer;
    Param    : Integer;
    Total    : Integer;
    CurPos   : Integer;
    IsDone   : Boolean;
    sMsg     : string;
  end;

  //??????????????????????????????????? OLD start
  //----------------- BMP Download
  TFileTranStr = record //TBD:PG?
    TransMode : Integer;
    TransType : Integer;
    TransSigId : Word;
    TotalSize : Integer;
    fileName  : string[100];
    filePath  : string[150];
    CheckSum  : DWORD;
		BmpWidth  : DWORD; //2021-11-10 DP201:BMP_DOW //TBD:ITOLED?
    Data      : array of Byte;
  end;

  InRxMaintEventPG = procedure (nPg: Integer; sLocal,sRemote: string; sMsg: string) of object;
  InTxMaintEventPG = procedure (nPg: Integer; sLocal,sRemote: string; sMsg: string) of object;

  InPwrReadEvnt = procedure (nPg: Integer; PwrData: TPwrData) of object; //TBD:DP860?
  //??????????????????????????????????? OLD end

	//###########################################################################
	//###                                                                     ###
	//### Class : TCommPG                                                     ###
	//###                                                                     ###
	//###########################################################################

  TCommPG = class(TObject) //#TDongaPG
  private
    //------------------------------------------------------ COMMON
    //------------------------------------------------------ PG(AF9)		
    //------------------------------------------------------ PG(DP860)
    //------------------------------------------------------ FLOW-SPECIFIC
    //------------------------------------------------------ ETC
	public
    //================================================================= COMMON
    //------------------------------------------------------ GUI Handle
    m_hMain    : HWND; // frmMain
    m_hTest    : HWND; // frmTest //#m_hTestFrm
    m_hGuiDown : HWND; // BmpDown //TBD:DP860? //#m_hGuiFrm
    //------------------------------------------------------ PG#/CH#
    m_nPg      : Integer; 
    m_nCh      : Integer; //0:CH1,1=CH2,2=ALL

    //------------------------------------------------------ PG Connection
    PG_TYPE         : Integer;

		PG_IPADDR       : string;
    PG_IPPORT       : Integer;
    PG_SourcePort   : Integer; //TBD:DP860?

    //------------------------------------------------------ PG TX/RX
    FTxRxDEF    		: TPgTxRxData; // LocalPort(8000) for No-Ack Cmd (pg.status, [cyclic]power.read, pg.init)
    FTxRxPG     		: TPgTxRxData; // LocalPort(8001|8002|...) for Cmd/Ack
    FIsOnFlashAccess: Boolean;
    //------------------------------------------------------ PG Version
    m_PgVer         : TPgVer;
    //------------------------------------------------------ PG Status and ConnCheck
    StatusPg        : enumPgStatus; //TBD:DP860? //#m_PgConnSt enumPgConnSt
	//m_PgConnSt  		: enumPgConnSt; //#StatusPg: TPgStatus //TBD:DP860?
    //
    m_bCyclicTimer  : Boolean;
    m_nConnCheckNG  : Integer; //m_nConnectCheck
    tmConnCheck     : TTimer;  //#tmAliveCheck
    //------------------------------------------------------ Power Measure
    m_PwrData				: TPwrData;     //#m_ReadVoltCurr	//AF9(dummy)
    m_RxPwrData     : TRxPwrData;   //#m_ReadVoltC	  //AF9(dummy)
    //
    m_bPwrMeasure   : Boolean;      //#m_bMeasureTmr
    tmPwrMeasure    : TTimer;       //#tmPowerMeasure
    //------------------------------------------------------ Pattern
    FCurPatGrpInfo  : TPatternGroup;   //#FCurPatGrpInfo : TPatternGroup;
    FDisPatStruct   : TPatInfoStruct;  //#FDisPatStruct  : TPatInfoStruct;
		m_CurPatDispInfo: TCurPatDispInfo; //#TPatInfoStruct.CurrPat
    //------------------------------------------------------ PG Event (PG_DP860)
    m_bWaitEvent    : Boolean;
    m_bWaitPwrEvent : Boolean;
    //------------------------------------------------------ Mainter
    FIsMainter      : Boolean;


    FOnTxMaintEventPG : InTxMaintEventPG;
    FOnRxMaintEventPG : InRxMaintEventPG;

    FIdUDPClient    : TIdUDPClient; //TBD:DP860?
    FFTPClient      : TFTPClient;
    m_ABinding      : TIdSocketHandle;
		//
    m_sEvent        : string;
    m_hEvent        : HWND;
    //
    m_hPwrEvent     : HWND;

    m_nOldPatNum : Integer;		//TBD:ITOLED_FI? ITOLED_POCB?
    //
    TconRWCnt    : TTconRWCnt; //2023-03-28 jhhwang (for T/T Test)
    //================================================================= FLOW-SPECIFIC
    m_bPowerOn     : Boolean;
    //------------------------------------------------------ FLOW-SPECIFIC(FI)
		{$IF Defined(INSPECTOR_OC) or Defined(INSPECTOR_OQA)}
    m_nPatNumPrev  : Integer;
    m_nPatNumNow   : Integer;
		{$ENDIF}
    //------------------------------------------------------ FLOW-SPECIFIC(POCB|OC)
		m_FlashRead    : TFlashRead;
    //================================================================= ETC
    FThreadLock    : Boolean; //TBD:DP860?
    FForceStop     : Boolean; //TBD:DP860?
		
    //================================================================= COMMON
    //------------------------------------------------------ General
    constructor Create(nPg: Integer; hMain: THandle); virtual;
    destructor Destroy; override;
    //------------------------------------------------------ Init PG Data
		procedure InitPgTxRxData;
		procedure InitPgVer;
		procedure InitPgPwrData;
		procedure InitPgPatternData;

		procedure InitFlashRead;

    //------------------------------------------------------ PatternGroup/PatternInfo
    procedure SetCurPatGrpInfo(const Value: TPatternGroup);
    procedure SetDisPatStruct(const Value: TPatInfoStruct);
    property DisPatStruct : TPatInfoStruct read FDisPatStruct write SetDisPatStruct;
    property CurPatGrpInfo : TPatternGroup read FCurPatGrpInfo write SetCurPatGrpInfo;
    //------------------------------------------------------ Mainter
    procedure SetIsMainter(const Value: Boolean);
    property IsMainter : Boolean read FIsMainter write SetIsMainter;
//		{$IFDEF PG_DP860}
    procedure SetOnTxMaintEventPG(const Value: InTxMaintEventPG);
    procedure SetOnRxMaintEventPG(const Value: InRxMaintEventPG);
    property OnRxMaintEventPG : InRxMaintEventPG read FOnRxMaintEventPG write SetOnRxMaintEventPG;
    property OnTxMaintEventPG : InTxMaintEventPG read FOnTxMaintEventPG write SetOnTxMaintEventPG;
//		{$ENDIF}
    //------------------------------------------------------ PG XXXX
    function IsPgReady: Boolean; //TBD:DP860?
    //------------------------------------------------------ PG Timer (ConnCheck)
    procedure ConnCheckTimer(Sender: TObject);
		procedure SetCyclicTimer(bEnable: Boolean; nDisableSec: Integer=0);
    //------------------------------------------------------ PG Timer (PowerMeasure)
    procedure PwrMeasureTimer(Sender: TObject); //TBD:DP860?
    procedure SetPwrMeasureTimer(bEnable: Boolean; nInterMS: Integer=0);
    //------------------------------------------------------ GUI
		procedure ShowMainWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
		procedure ShowTestWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
		procedure ShowDownLoadStatus(nGuiType: Integer; curPos,total: Integer; sMsg: string; bIsDone: Boolean = False); //TBD:DP860?


    //================================================================= PG_DP860
//{$IFDEF PG_DP860}
    procedure WaitMicroSec(lNumberOfMicroSec : Longint);
		//------------------------------------------------------ PG_DP860 Timer
		procedure ConnCheckTimer_DP860(Sender: TObject);
    //------------------------------------------------------ PG_DP860 TX/RX Common (----)
		function DP860_GetStrCmdResult(dwRtn: DWORD): string;
    //TBD:DP860? function DP860_LoadIpStatus(ABinding: TIdSocketHandle): Boolean;
    //------------------------------------------------------ PG_DP860 TX/RX Common (CmdAck)
		function CheckCmdAck(Task: TProc; nCmdId: Integer; sCmdName: string; nWaitMS,nRetry: Integer): DWORD;
    //TBD:DP860? function CheckResetCmdAck(Task : TProc; nSid, nDelay, nRetry : Integer) : DWORD; 
    //TBD:DP860? function CheckCmdAckAndNack(Task : TProc; nSid, nDelay, nRetry : Integer) : DWORD;
    //TBD:DP860? function CheckDynamicDownAck(Task: TProc; nSid, nDelay, nRetry: Integer): DWORD;
    //------------------------------------------------------ PG_DP860 TX/RX Common (Send)
		function DP860_SendCmd(sCommand: string; nCmdId: Integer; sCmdname: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? Return;Integer? DWORD? 3000?
    procedure DP860_SendData(nBindIdx: Integer; sCommand: string); //TBD:DP860?
  //function TDongaPG.GetPgCrc16(buffer: array of Byte; nLen: Integer): Word;     //TBD:MERGE?
    //------------------------------------------------------ PG_DP860 TX/RX Common (Receive)
    procedure DP860_OnUdpRX(sCmdAck: string; nLocalPort,nPeerPort: Integer);
    procedure DP860_ReadPgInit; //TBD:DP860?
    function DP860_GetPgLogMsg(sAckStr: string): string;
    //------------------------------------------------------ PG_DP860 Command (ConnCheck)
		procedure DP860_SendConnCheck; // pg.status
    procedure DP860_ReadConnCheckAck(sCmdAck: string); //TBD:DP860?
    //------------------------------------------------------ PG_DP860 Command (Version)
		function DP860_SendVersionAll(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; // version.all
    procedure DP860_ReadVersionAllAck(sCmdAck: string);
    function DP860_SendModelVersion(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; // model.version
    procedure DP860_ReadModelVersionAck(sCmdAck: string);
		//------------------------------------------------------ PG_DP860 Command (Model)
		function DP860_ModelInfoDownload: DWORD;
		function DP860_SendPowerOpen(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function DP860_MakeCmdParam_PowerOpen: string;
	//function DP860_SendPowerLimit(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //obsoleted!!!
  //function DP860_MakeCmdParam_PowerLimit: string; //obsoleted!!! 
		function DP860_SendPowerSeq(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function DP860_MakeCmdParam_PowerSeq: string;
		function DP860_SendModelConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function DP860_MakeCmdParam_ModelConfig: string;
		function DP860_SendAlpmConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function DP860_MakeCmdParam_AlpmConfig: string;
    {$IFDEF DP860_TBD_XXXXXX}
		//TBD:DP860? function DP860_SendModelFIle; // model.file <modelName.cmdl>
		//TBD:DP860? function DP860_SendModelVersion; //  model.version ?
{$ENDIF}
    //------------------------------------------------------ PG_DP860 Command (Power On/Off)
	  function DP860_SendPowerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
		function DP860_SendPowerOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    function DP860_SendPowerBistOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
		function DP860_SendPowerBistOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
	  function DP860_SendInterposerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
		function DP860_SendInterposerOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    //
    function DP860_SendDutDetect(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    function DP860_SendTconInfo(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    //------------------------------------------------------ PG_DP860 Command (Power Measure)
		function DP860_SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD; // power.read //#SendPowerMeasureReq
    procedure DP860_ReadPowerMeasureAck(sCmdAck: string);
    procedure DP860_CheckPowerLimit(PwrData: TPwrData);
    //------------------------------------------------------ PG_DP860 Command (Pattern)
		function DP860_SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //DP860 Pattern(FPGA/Static)
    function DP860_SendDisplayPatBistRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    function DP860_SendDisplayPatBistRGB_9Bit(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function DP860_SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;  //#SendDisplayPat //#SendPatDisplayReq
		function DP860_SendDisplayPatBMP(sBmpName: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;  //#SendDisplayPat //#SendPatDisplayReq
    //------------------------------------------------------ PG_DP860 Command (DBV)
		function DP860_SendAlpdpDBV(nDBV: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; ////TBD:2023-02-02? AlpdpDBV?
		function DP860_SendBistDBV(nDBV: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; ////TBD:2023-02-02? AlpdpDBV?

    //------------------------------------------------------ PG_DP860 Command (TCON)
		function DP860_SendTconRead(nRegAddr,nDataCnt: Integer; var arDataR: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
		function DP860_SendTconWrite(nRegAddr,nDataCnt: Integer; arDataW: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
    function DP860_SendTconOCWrite(nRegAddr,nDataCnt: Integer; arDataW: TIDBytes; nWaitMS: Integer=0; nRetry: Integer=0): DWORD;

    //------------------------------------------------------ PG_DP860 Command (Flash)

		function DP860_SendNvmErase(nAddr,nSize:DWORD; nWaitMS: Integer=FLASH_ERASE_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
		function DP860_SendNvmRead(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
	  function DP860_SendNvmReadAscii(nAddr,nSize:DWORD; var sData: string; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
		function DP860_SendNvmReadFile(nAddr,nSize:DWORD; sRemoteFile: string; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
	//function DP860_SendNvmWrite(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860?
		function DP860_SendNvmWriteFile(nAddr,nSize:DWORD; sRemoteFile: string; bVerify: Boolean=True; bErase: Boolean=True; nWaitMS: Integer=FLASH_WRITE_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
		//
		function DP860_FilePutPC2PG(sLocalFullName: string; sRemotePath, sRemoteFile: string; bClearBeforePut: Boolean=True; bEndDisc: Boolean=True): DWORD;
		function DP860_FileGetPG2PC(sRemotePath, sRemoteFile: string; sLocalFullName: string; bClearAfterGet: Boolean=False; bEndDisc: Boolean=True): DWORD;

      procedure DP860_ClearOcTconRWCnt; //2023-03-28 jhhwang (for T/T Test)
	  function DP860_SendOcOnOff(nState: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
    function DP860_SendGpioRead(sGpio: string; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
    //------------------------------------------------------ PG_DP860 System
	//TBD:DP860?	bmp
	//TBD:DP860?	delay.ms <ms#>
    //------------------------------------------------------ PG_DP860 Pulse Control
//{$ENDIF} //PG_DP860

    //================================================================= FLOW-SPECIFIC
		// Script/Logic/Mainter/... --> Flow-Specific Function/Procedure --> AF9_API Call or DP860 Cmd/Ack --> return
		//
    //------------------------------------------------------ FLOW-SPECIFIC (Power On/Off)
		function SendPowerOn(nMode: Integer; bPowerReset: Boolean=False; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
    function SendPowerBistOn(nMode: Integer; bPowerReset: Boolean=False; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
    //------------------------------------------------------ FLOW-SPECIFIC (Power Measure)
    function SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD;
    //------------------------------------------------------ FLOW-SPECIFIC (Pattern)
    function SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendSetColorRGB
    function SendDisplayPatBistRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendSetColorRGB
    function SendDisplayPatBistRGB_9Bit(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    function SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD; //#SendDisplayPat //#SendPatDisplayReq
		function SendDisplayPatPwmNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendDisplayPwmPat //TBD:DP860?
		function SendDisplayPatNext( nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendDisplayPwmPat //TBD:DP860?    //------------------------------------------------------ FLOW-SPECIFIC (GrayChange|Dimming|...)
		function SendGrayChange(nGrayOffset: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;  //FEATURE_GRAY_CHANGE
		function SendDimming(nDimming: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
    function SendDimmingBist(nDimming: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
		function SendPocbOnOff(bOn: Boolean; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //FEATURE_POCB_ONOFF
    //------------------------------------------------------ FLOW-SPECIFIC (I2C)
    function SendI2CRead(nDevAddr,nRegAddr,nDataCnt: Integer; var arDataR: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
	//{$IFDEF INSPECTOR_POCB}
    function SendI2CWrite(nDevAddr,nRegAddr,nDataCnt: Integer; arDataW: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
	//{$ELSE}
  //function SendI2CWrite(nDevAddr,nRegAddr,nDataCnt: Integer; arDataW: array of Integer; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
	//{$ENDIF}
    //------------------------------------------------------ FLOW-SPECIFIC (Flash)

		function SendFlashRead (nAddr,nSize: DWORD; pData: PByte; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD;
		function SendFlashWrite(nAddr,nSize: DWORD; pData: PByte; nWaitMS: Integer=100000; nRetry: Integer=0): DWORD;
  //function SendFlashFileWrite(sLocalPath,sLocalName: string; sRemotePath, sRemoteFile: string; nAddr,nSize:DWORD; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //DP860(flash.filewrite) //TBD:DP860?

	end;

	//############################################################################
//	{$IFDEF PG_DP860} //##########################################################

  //============================================================================
  // TUdpServerPG
  //============================================================================

  TUdpServerPG = class(TObject) //#TDaeUdpServer+#TUdpServerIWPD
  private
		// RX
    function IpToPgNo(sPeerIp: string): Integer; //TBD:DP860?
    procedure UdpSvrRead(AThread: TIdUDPListenerThread;const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure UdpSvrUDPErr(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
  public
    //
    m_hMain   : HWND; //#FhMain
    UdpSvr    : TIdUDPServer;
    // TX/RX
    FIsReadyToRead    : Boolean;
  //FbUseStaticPCPort : Boolean; //#FbIncreasePort //TBD:DP860? // --> CommPG_PC_PORT_STATIC
		//
    constructor Create(hMain: THandle{; nMsgType: Integer}); virtual;
    destructor Destroy; override;
    //
    procedure UdpSvrSend(nBindIdx,nPg: Integer; sData: string);
  end;
	//###########################################################################
//	{$ENDIF} //PG_DP860 #########################################################
	//###########################################################################

var
//{$IFDEF PG_DP860}
  UdpServerPG : TUdpServerPG; //#UdpServerIWPD
//{$ENDIF}
  PG : array[Defcommon.CH1..Defcommon.MAX_CH] of TCommPG; //TCommPG = (TAF9Fpga + TDongaPG) //#TDongaPG

implementation

{$IF Defined(INSPECTOR_OC) or Defined(INSPECTOR_OQA)}
uses
  pasScriptClass;
{$ENDIF}

{$r+} // memory range check.

//##############################################################################
{$IFDEF PG_DP860} //############################################################
//##############################################################################
//###                                                                        ###
//###                     PG_DP860 : TUdpServerPG                            ###
//###                                                                        ###
//##############################################################################
//##############################################################################

//------------------------------------------------------------------------------
//	procedure/function
//		- constructor TUdpServerPG.Create(hMain: THandle; nMsgType: Integer);
//		- destructor TUdpServerPG.Destroy;
//
constructor TUdpServerPG.Create(hMain: THandle); //TBD:DP860?
var
  nPg : Integer;
  {$IFDEF SIMULATOR_PG}
  UdpSocketHandle : TIdSocketHandle;
  {$ENDIF}
begin
  m_hMain := hMain;
	//
  FIsReadyToRead    := False;
//FbUseStaticPCPort := False; //TBD:DP860?

  for nPg := DefCommon.CH1 to DefCommon.MAX_CH do begin
    PG[nPg] := TCommPG.Create(nPg, hMain);
  end;

	//
  udpSvr := TIdUDPServer.Create;
  udpSvr.Bindings.Clear;
  //for nPg := DefCommon.PG_1 to DefCommon.PG_1 do begin
  for nPg := DefCommon.CH1 to DefCommon.MAX_CH do begin
    udpSvr.Bindings.Add.SetBinding(DefPG.CommPG_PC_IPADDR,PG[nPg].PG_IPPORT);
  end;
  udpSvr.Bindings.Add.SetBinding(DefPG.CommPG_PC_IPADDR,DefPG.CommPG_PC_PORT_BASE); //TBD:DP860? for ConnCheck/PowerRead/PgInit
  udpSvr.DefaultPort    := DefPG.CommPG_PC_PORT_BASE; //TBD:DP860?
  udpSvr.ThreadedEvent  := True;
  udpSvr.OnUDPRead      := UdpSvrRead;
  udpSvr.OnUDPException := UdpSvrUDPErr;

  try
    udpSvr.Active := True;
  except
    udpsvr.Free;
    udpSvr := nil;
  end;
end;

destructor TUdpServerPG.Destroy;
var
  nPg : integer;
begin
  if udpsvr <> nil then	begin
    udpSvr.Active := False;
    udpSvr.Free;
    udpSvr := nil;
  end;

  for nPg := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if PG[nPg] <> nil then begin
      PG[nPg].Free;
      PG[nPg] := nil;
    end;
  end;

  inherited;
end;

//------------------------------------------------------------------------------
//	procedure/function
//		- function TUdpServerPG.IpToPgNo(sPeerIp: string): Integer;
//
function TUdpServerPG.IpToPgNo(sPeerIp: string): Integer; 
var
  nPg  : Integer;
begin
  Result := -1;
  try
  	if sPeerIp = '' then Exit;
    //
    for nPg := DefCommon.CH1 to DefCommon.MAX_CH do begin
      if PG[nPg] = nil then Continue;
      if sPeerIp = PG[nPg].PG_IPADDR then begin
        Result := nPg;
        Break;
      end;
    end;
  except
    //
  end;
end;

//------------------------------------------------------------------------------
//	procedure/function
//		- procedure TUdpServerPG.UdpSvrRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
//		- procedure TUdpServerPG.udpSvrUDPErr(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
//
procedure TUdpServerPG.UdpSvrRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  sPeerIP   : string;
	nLocalPort, nPeerPort : Integer;

  nPg : integer;
  sAnsiData : AnsiString;
  sData, sCmdAck, sTemp : string;
	nPosAck : Integer;
	bEnd : Boolean;

  nDebugMsgType : Integer;
  sLocal,sRemote : string;
  PTxRxData : PPgTxRxData;
  nRetXXLen : integer;
begin
  nLocalPort := ABinding.Port;
  sPeerIP    := ABinding.PeerIP;
  nPeerPort  := ABinding.PeerPort;
  nRetXXLen  := 6; // default: "RET:OK" or "RET:NG"
	//
  nPg := IpToPgNo(sPeerIp);
  if (nPg < DefCommon.CH1) or (nPg > DefCommon.MAX_CH) then Exit;
  if PG[nPg] = nil then Exit;
	//
  SetString(sAnsiData, PAnsiChar(@AData[0]), Length(AData));
  if nLocalPort = DefPG.CommPG_PC_PORT_BASE then PTxRxData := @PG[nPg].FTxRxDEF else PTxRxData := @PG[nPg].FTxRxPG;
  sData := PTxRxData^.RxPrevStr + string(sAnsiData);

	bEnd := False;
	Repeat
		nPosAck := Pos('RET:',UpperCase(sData));
    //
		if (nPosAck < 1) then begin
      bEnd := True;
      Break;  // Not Found "RET:"
    end;
    //
    if Pos('RET:IN',UpperCase(sData)) > 0 then begin
      if Pos('RET:INFO',UpperCase(sData)) < 0 then begin
        bEnd := True;
        Break;  // Found "RET:IN" but, Not Found "RET:INFO"
      end;
      nRetXXLen := 8;  // "RET:INFO"
    end;
    //
    if Length(sData) < (nPosAck+nRetXXLen) then begin
      bEnd := True;
      Break; // Wait more
    end;

    // "RET:OK<CR>" or "RET:NG<CR> or "RET:INFO<CR>"
  	sCmdAck := Trim(Copy(sData,1,nPosAck+(nRetXXLen-1)));             // ...... RET:xx
 		sData   := Trim(Copy(sData,nPosAck+(nRetXXLen+1),Length(sData)));

    // Debug Log
    nDebugMsgType := DEBUG_LOG_MSGTYPE_INSPECT; //TBD:DP860?
  	{$IFDEF PG_DP860}
  //if (btSubSigId = DefPG.SIG_PG_CONN_CHECK)        then nDebugMsgType := DEBUG_LOG_MSGTYPE_CONNCHECK
  //else if (btSubSigId = DefPG.SIG_PG_READ_VOLTCUR) then nDebugMsgType := DEBUG_LOG_MSGTYPE_POWERREAD;
  	{$ENDIF}
   	sCmdAck := StringReplace(sCmdAck, #$0A, '', [rfReplaceAll]);        // remove #$0A //TBD:DP860?
   	sCmdAck := StringReplace(sCmdAck, #$0D#$0D, #$0D, [rfReplaceAll]);  // remove #$0A //TBD:DP860?
    if (Common.m_nDebugLogLevelActive >= nDebugMsgType) then begin
      sLocal  := Format('%d',[nLocalPort]);
      sRemote := Format('%d',[nPeerPort]);
      Common.DebugLog(nPg, nDebugMsgType, 'RX', sLocal,sRemote, sCmdAck);
    end;

    // Maint Log
    if PG[nPg].FIsMainter and Assigned(PG[nPg].OnRxMaintEventPG) and (nDebugMsgType = DEBUG_LOG_MSGTYPE_INSPECT) then begin
      sLocal  := Format('%d',[nLocalPort]);
      sRemote := Format('%d',[nPeerPort]);
      PG[nPg].OnRxMaintEventPG(nPg, sLocal,sRemote, sCmdAck);
    end;

    // PG process message
  //if Pos('pg.process',LowerCase(sCmdAck)) = 1 then begin
    if nRetXXLen <> 6 then begin //RET:INFO (pg.process)
      PTxRxData^.RxPrevStr := TernaryOp((Length(Trim(sData)) > 0), sData, '');
      {$IF Defined(INSPECTOR_OC) or Defined(INSPECTOR_PreOC)} //2023-03-28 jhhwang (for OC T/T)
      {$ELSE}
      sTemp := '<PG> ' + Trim(Copy(sCmdAck, 1, Pos('RET:INFO',sCmdAck)-1));
      PG[nPg].ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sTemp); //Show Log Only
      {$ENDIF}
      Continue; //!!! Exit -> Continue //2023-04-28
    end;

    //
    PG[nPg].DP860_OnUdpRX(sCmdAck, nLocalPort,nPeerPort); //#OnReadEvent

    //
    if Length(sData) < 6 then bEnd := True;
	Until bEnd;

  PTxRxData^.RxPrevStr := TernaryOp((Length(Trim(sData)) > 0), sData, '');
end;

procedure TUdpServerPG.UdpSvrUDPErr(AThread: TIdUDPListenerThread; ABinding: TIdSocketHandle; const AMessage: String; const AExceptionClass: TClass);
begin
	//TBD:DP860?
end;

//------------------------------------------------------------------------------
//	procedure/function
//		- procedure TUdpServerPG.UdpSvrSend(nPg: Integer; sData: string);
//
procedure TUdpServerPG.UdpSvrSend(nBindIdx, nPg: Integer; sData: string);
var
  sPeerIP   : string;
	nLocalPort, nPeerPort : Integer;

  nDebugMsgType : integer;
  sLocal, sRemote : string;
begin
  if udpSvr = nil then Exit;

  nLocalPort := udpSvr.Bindings[nBindIdx].Port;
  sPeerIP    := PG[nPg].PG_IPADDR;
  nPeerPort  := PG[nPg].PG_IPPORT;

  // debug/maint log
  nDebugMsgType := DEBUG_LOG_MSGTYPE_INSPECT;
{$IFDEF DP860_TBD_XXXX} //TBD:DP860?
  if (btSigId = DefPG.SIG_PG_CONN_CHECK)        then nDebugMsgType := DEBUG_LOG_MSGTYPE_CONNCHECK
  else if (btSigId = DefPG.SIG_PG_READ_VOLTCUR) then nDebugMsgType := DEBUG_LOG_MSGTYPE_POWERREAD;
{$ENDIF}
//sLocal     := Format('%s/%d',[DefPG.CommPG_PC_IPADDR,nLocalPort]);
//sRemote    := Format('%s/%d',[sPeerIP,nPeerPort]);
  sLocal     := Format('%d',[nLocalPort]);
  sRemote    := Format('%d',[nPeerPort]);
  if (Common.m_nDebugLogLevelActive >= nDebugMsgType) then
		Common.DebugLog(nPg, nDebugMsgType, 'TX', sLocal,sRemote, sData);
//    {$IFDEF PG_DP860}
    if PG[nPg].FIsMainter and Assigned(PG[nPg].OnTxMaintEventPG) and (nDebugMsgType = DEBUG_LOG_MSGTYPE_INSPECT) then begin
      PG[nPg].OnTxMaintEventPG(nPg, sLocal,sRemote, sData);
    end;
//    {$ENDIF}

  try
    udpSvr.Bindings[nBindIdx].SendTo(PG[nPg].PG_IPADDR,PG[nPg].PG_IPPORT, sData);
  except
    if (Common.m_nDebugLogLevelActive >= nDebugMsgType) then
  		Common.DebugLog(nPg, nDebugMsgType, 'TX', sLocal,sRemote, sData+' ...TX_NG');
    {$IFDEF PG_DP860}
    if PG[nPg].FIsMainter and Assigned(PG[nPg].OnTxMaintEventPG) and (nDebugMsgType = DEBUG_LOG_MSGTYPE_INSPECT) then begin
      PG[nPg].OnTxMaintEventPG(nPg, sLocal,sRemote, sData+' ...TX_NG');
    end;
    {$ENDIF}
  end;
end;

//##############################################################################
{$ENDIF} //PG_DP860 ############################################################
//##############################################################################

//##############################################################################
//##############################################################################
//###                                                                        ###
//###                  Class CommPG - COMMON (PG_AF9|PG_DP860)               ###
//###                                                                        ###
//##############################################################################
//##############################################################################

//==============================================================================
// General
//------------------------------------------------------------------------------
// procedure/function:
//		- constructor TCommPG.Create(nPg: Integer; hMain: THandle);
//		- destructor TCommPG.Destroy;
//
constructor TCommPG.Create(nPg: Integer; hMain: THandle);
{$IFDEF SIMULATOR_PANEL}
var
  i : integer;
{$ENDIF}
begin
	//-------------------------------------------------------- COMMON
	// GUI Handle
	m_hMain    := hMain;
//TBD:DP860? m_hTest    := hTest;
//TBD:DP860? m_hGuiDown := nil;
	// PG#/CH#
  m_nPg := nPg;
  m_nCh := nPg;
  //
  FIsMainter := False;
  OnTxMaintEventPG := nil;
  OnRxMaintEventPG := nil;

//  if m_nCh = DefCommon.CH_1 then m_nAF9Ch := AF9_enumCHANNEL_TYPE.AF9CH_1
//  else                           m_nAF9Ch := AF9_enumCHANNEL_TYPE.AF9CH_2;



  PG_TYPE := 0;// Common.SystemInfo.PG_TYPE;

  // PG Connection
	PG_IPADDR := DefPG.CommPG_NETWORK_PREFIX + Format('.%d',[DefPG.CommPG_PG_IPADDR_BASE + nPg]);
	PG_IPPORT := DefPG.CommPG_PG_PORT_BASE + nPg;

	InitPgTxRxData; 		// PG TX/RX
  InitPgVer; 	    		// PG Version
	InitPgPwrData;			// Power Measure
	InitPgPatternData;  // Pattern	
	
	// PG Status and ConnCheck
  StatusPg := pgDisconn; //TBD? #PgConnStNotStarted
	
	// Cyclic Timer - ConnCheck
	m_bCyclicTimer := True; //TBD:DP860?
  m_nConnCheckNG := 0;
  //
  tmConnCheck := TTimer.Create(nil);
	tmConnCheck.OnTimer  := ConnCheckTimer;
	tmConnCheck.Interval := DefPG.PG_CONNCHECK_INTERVAL;
	tmConnCheck.Enabled  := False;
	// Power Measure
//	InitPgPwrData;
  m_bPwrMeasure := False;
  //
  tmPwrMeasure := TTimer.Create(nil);
	tmPwrMeasure.OnTimer  := PwrMeasureTimer;
	tmPwrMeasure.Interval := DefPG.PG_PWRMEASURE_INTERVAL_DEF;
	//
	tmPwrMeasure.Enabled  := False;

  // Mainter
  FIsMainter := False;
  FIdUDPClient := TIdUDPClient.Create;
  FIdUDPClient.Active  := False;
  FIdUDPClient.Host    := PG_IPADDR;
  FIdUDPClient.Port    := PG_IPPORT;
  FIdUDPClient.Active  := True;
  //
  FFTPClient := TFTPClient.Create(PG_IPADDR, DefPG.DP860_FTP_USERNAME, DefPG.DP860_FTP_PASSWORD);
  //
  m_ABinding      := nil;
	//
  m_sEvent        := '';
//TBD:DP860? m_hEvent        := nil;
  m_bWaitEvent    := False;
  //
//TBD:DP860? m_hPwrEvent     := nil;
  m_bWaitPwrEvent := False;
	//-------------------------------------------------------- FLOW-SPECIFIC
	m_bPowerOn    := False;
  // FLOW-SPECIFIC(FI)
  // FLOW-SPECIFIC(POCB|OC)
  InitFlashRead;

	//-------------------------------------------------------- ETC
  FThreadLock := False; //TBD:DP860?
  FForceStop  := False; //TBD:DP860?

end;

destructor TCommPG.Destroy;
begin
  if not (StatusPg in [pgDisconn]) then begin
    SendPowerOn(CMD_POWER_OFF,False{bPowerReset},0,0);
  end;
  if FIdUDPClient <> nil then begin
    FIdUDPClient.Free;
    FIdUDPClient := nil;
  end;
	//
  if tmConnCheck <> nil then begin
    tmConnCheck.Enabled := False;
    tmConnCheck.Free;
    tmConnCheck := nil;
  end;
  if FFTPClient <> nil then begin
    if FFTPClient.IsConnected then FFTPClient.Disconnect;
    FFTPClient.Free;
    FFTPClient := nil;
  end;
	//
  if tmPwrMeasure <> nil then begin
    tmPwrMeasure.Enabled := False;
    tmPwrMeasure.Free;
    tmPwrMeasure := nil;
  end;
	//
  inherited;
end;

//==============================================================================
// Init PG Data
//------------------------------------------------------------------------------
// procedure/function: 
//		- procedure TCommPG.InitPgTxRxData;
//		- procedure TCommPG.InitPgVer;
//		- procedure TCommPG.InitPgPwrData;
//		- procedure TCommPG.InitPgPatternData;
//		- procedure TCommPG.InitFlashData;
//
procedure TCommPG.InitPgTxRxData;
begin
	with FTxRxDEF do begin
    // -
		CmdState  := DefPG.PG_CMDSTATE_NONE;
		CmdResult := DefPG.PG_CMDRESULT_NONE;
		// TX
    TxCmdId   := DefPG.PG_CMDID_UNKNOWN;
    TxCmdStr  := '';
    TxDataLen := 0;
  //TxData    :=
		// RX
    RxCmdId   := DefPG.PG_CMDID_UNKNOWN;
    RxAckStr  := '';
    RxDataLen := 0;
  //RxData    :=
    //
    RxPrevStr := '';
	end;

	with FTxRxPG do begin
    // -
		CmdState  := DefPG.PG_CMDSTATE_NONE;
		CmdResult := DefPG.PG_CMDRESULT_NONE;
		// TX
    TxCmdId   := DefPG.PG_CMDID_UNKNOWN;
    TxCmdStr  := '';
    TxDataLen := 0;
  //TxData    :=
		// RX
    RxCmdId   := DefPG.PG_CMDID_UNKNOWN;
    RxAckStr  := '';
    RxDataLen := 0;
  //RxData    :=
    //
    RxPrevStr := '';
	end;
end;

procedure TCommPG.InitPgVer;
begin
	with m_PgVer do begin
    VerAll := '';
    HW    := '';
    FW    := '';
    SubFW := '';
    FPGA  := '';
    PWR   := '';
    //
    VerScript := '';
	end;
end;

procedure TCommPG.InitPgPwrData;
var
	i : Integer;
begin
//for i := 0 to DefPG.PWR_MAX do begin
// 	m_RxPwrData.VOL[i] := 0;
//	m_RxPwrData.CUR[i] := 0;
//	{$IFDEF PG_DP860}
//	m_RxPwrData.VOL[i] := 0;
//	m_RxPwrData.CUR[i] := 0;
//	{$ENDIF}
//end;

	m_PwrData.VCC  := 0;
	m_PwrData.VIN  := 0;
	m_PwrData.VDD3 := 0;
	m_PwrData.VDD4 := 0;
	m_PwrData.VDD5 := 0;

 	m_PwrData.IVCC  := 0;
	m_PwrData.IVIN  := 0;
	m_PwrData.IVDD3 := 0;
	m_PwrData.IVDD4 := 0;
	m_PwrData.IVDD5 := 0;

	//
	{$IFDEF PG_DP860}
	m_RxPwrData.VCC  := 0;
	m_RxPwrData.VIN  := 0;
	m_RxPwrData.VDD3 := 0;
	m_RxPwrData.VDD4 := 0;
	m_RxPwrData.VDD5 := 0;

 	m_RxPwrData.IVCC  := 0;
	m_RxPwrData.IVIN  := 0;
	m_RxPwrData.IVDD3 := 0;
	m_RxPwrData.IVDD4 := 0;
	m_RxPwrData.IVDD5 := 0;
	{$ENDIF}
end;

procedure TCommPG.InitPgPatternData;
begin
	//
//with FCurPatternGroup do begin
//end;
	//
//with FCurPatListInfo do begin
//end;
	//
	with m_CurPatDispInfo do begin
  //bPowerOn      := False;
    bPatternOn    := False;
    nCurPatNum    := 0;
    nCurAllPatIdx := 0;
    bSimplePat    := True;
    {$IFDEF FEATURE_GRAY_CHANGE}
    nGrayOffset   := 0;
    bGrayChangeR  := False;
		bGrayChangeG  := False;
		bGrayChangeB  := False;
    {$ENDIF}
    {$IFDEF FEATURE_DIMMING_STEP}
    nCurPwmDuty     := 100;
    nCurDimmingStep := 1;
    {$ENDIF}
  end;
end;


procedure TCommPG.InitFlashRead;
begin
	// for Interlock Flash
  FIsOnFlashAccess := False;

	// Flash Access/Read Status
  with m_FlashRead do Begin
		FlashAccSt   := flashAccUnknown;
		//
    ReadType     := flashReadNone;
    ReadSize     := 0;
    RxSize       := 0;
  //RxData       : array[0..(DefPG.MAX_FLASHSIZE_BYTE-1)] of Byte;
    ChecksumRx   := 0;
    ChecksumCalc := 0;
    //
    bReadDone    := False;
    SaveFilePath := '';
    SaveFileName := '';
  end;
end;


//==============================================================================
// PatternGroup/PatternInfo
//------------------------------------------------------------------------------
// procedure/function:
//    - procedure TCommPG.SetPatternGroup(const Value: TPatternGroup);
//    - procedure TCommPG.SetPatInfoList(const Value: TPatInfoList); 
//
procedure TCommPG.SetCurPatGrpInfo(const Value: TPatternGroup);
begin
  FCurPatGrpInfo := Value;
end;

procedure TCommPG.SetDisPatStruct(const Value: TPatInfoStruct);
begin
  FDisPatStruct := Value;
end;

//==============================================================================
// Mainter
//------------------------------------------------------------------------------
// procedure/function:
//		- procedure TCommPG.SetIsMainter(const Value: Boolean);
//		- procedure TCommPG.SetOnRxMaintEventAF9(const Value: RxMaintEventAF9);
//		- procedure TCommPG.SetOnTxMaintEventAF9(const Value: TxMaintEventAF9);
//
procedure TCommPG.SetIsMainter(const Value: Boolean);
begin
  FIsMainter := Value;
end;

{$IFDEF PG_DP860}
procedure TCommPG.SetOnRxMaintEventPG(const Value: InRxMaintEventPG);
begin
  FOnRxMaintEventPG := Value;
end;

procedure TCommPG.SetOnTxMaintEventPG(const Value: InTxMaintEventPG);
begin
  FOnTxMaintEventPG := Value;
end;
{$ENDIF}

//==============================================================================
// XXXXX
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.IsPgReady: Boolean; //TBD:DP860?
//
function TCommPG.IsPgReady: Boolean; //TBD:DP860?
begin
  Result := False;
  if StatusPg in [pgReady] then Result := True;
end;

//==============================================================================
// PG Timer (ConnCheck)
//------------------------------------------------------------------------------
// procedure/function: 
//		- procedure TCommPG.ConnCheckTimer(Sender: TObject);
//    - procedure TCommPG.SetCyclicTimer(bEnable: Boolean; nDisableSec: Integer=0);
//
procedure TCommPG.ConnCheckTimer(Sender: TObject);
begin
  ConnCheckTimer_DP860(sender);
end;

procedure TCommPG.SetCyclicTimer(bEnable: Boolean; nDisableSec: Integer=0);
begin
  //2022-2-17 if m_bCyclicTimer = bEnable then Exit;  // Already Enabled/Disabled //TBD:MERGE?
  //
  m_bCyclicTimer       := bEnable;
  tmConnCheck.Enabled  := bEnable;
  tmPwrMeasure.Enabled := (bEnable and m_bPwrMeasure);
  //
  m_nConnCheckNG := 0;
  if (not bEnable) and (nDisableSec > 0) then begin  // Disable(Duaration!=0)
    TThread.CreateAnonymousThread(procedure var nCnt : Integer;
    begin
      for nCnt := 1 to nDisableSec do begin
        if m_bCyclicTimer then Exit;
        Sleep(1000);
      end;
      // Enable after nDisableSec expired
      m_bCyclicTimer       := True;
      tmConnCheck.Enabled  := True;
      tmPwrMeasure.Enabled := m_bPwrMeasure;
    end).Start;
  end;
end;

procedure TCommPG.WaitMicroSec(lNumberOfMicroSec : Longint);
//const
//_SECOND = 10000000;
var
 lBusy : LongInt;
 hTimer : LongInt;
 liDueTime : LARGE_INTEGER;

begin
  hTimer := CreateWaitableTimer(nil, True, 'WaitableTimer');
  if hTimer = 0 then
   Exit;
//liDueTime.QuadPart := -10000000 * lNumberOfSeconds;
  liDueTime.QuadPart := -1000* lNumberOfMicroSec;
  SetWaitableTimer(hTimer, TLargeInteger(liDueTime), 0, nil, nil, False);

  repeat
    lBusy := MsgWaitForMultipleObjects(1, hTimer, False, INFINITE, QS_ALLINPUT);
  //Application.ProcessMessages;
  Until lBusy = WAIT_OBJECT_0;

  // Close the handles when you are done with them.
  CloseHandle(hTimer);
End;

//==============================================================================
// PG Timer (PowerMeasure)
//------------------------------------------------------------------------------
// procedure/function:
//    - procedure TCommPG.PwrMeasureTimer(Sender: TObject);
//    - procedure TCommPG.SetPwrMeasureTimer(bEnable: Boolean; nInterMS: Integer=0);
//
procedure TCommPG.PwrMeasureTimer(Sender: TObject);
begin
	if (not m_bCyclicTimer) then Exit;
	if (not m_bPwrMeasure)  then Exit;

  if m_bWaitEvent then Exit;    //2020-12-16
  if m_bWaitPwrEvent then Exit; //2020-12-16

	try
    if m_bPwrMeasure then tmPwrMeasure.Enabled := False;
  //SendPowerMeasure(False{bWait}); //TBD:DP860?
  	SendPowerMeasure(True{bWait});  //TBD:DP860?
	except
		OutputDebugString(PChar('>> PwrMeasureTimer Exception Error!!'));
	end;
end;

procedure TCommPG.SetPwrMeasureTimer(bEnable: Boolean; nInterMS: Integer=0);
begin
  //
  if bEnable then begin
		if (nInterMS < DefPG.PG_PWRMEASURE_INTERVAL_MIN) then nInterMS := DefPG.PG_PWRMEASURE_INTERVAL_MIN;
    tmPwrMeasure.Interval := nInterMS;
  end;
  m_bPwrMeasure        := bEnable;
  tmPwrMeasure.Enabled := bEnable;
end;

//==============================================================================
// GUI
//------------------------------------------------------------------------------
// procedure/function:
//    - procedure TCommPG.ShowMainWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
//    - procedure TCommPG.ShowTestWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
//    - procedure TCommPG.ShowDownLoadStatus(nGuiType: Integer; curPos,total: Integer; sMsg: string; bIsDone: Boolean = False); //TBD:DP860?
//
procedure TCommPG.ShowMainWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  SendGui     : RGuiPg2Main;
begin
  SendGui.MsgType := DefCommon.MSG_TYPE_PG; //= MSG_TYPE_AF9FPGA
  SendGui.PgNo    := m_nPg;
  SendGui.Mode    := nGuiMode;
  SendGui.Param   := nParam;
  SendGui.sMsg    := sMsg;
	//
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(SendGui);
  ccd.lpData      := @SendGui;
  SendMessage(Self.m_hMain,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TCommPG.ShowTestWindow(nGuiMode: Integer; nParam: Integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  SendGui     : RGuiPg2Test;
begin
  SendGui.MsgType := DefCommon.MSG_TYPE_PG; //= MSG_TYPE_AF9FPGA
  SendGui.Mode    := nGuiMode;
  SendGui.PgNo    := m_nPg;
  SendGui.Param   := nParam;
  SendGui.sMsg    := sMsg;
  SendGui.PwrData := m_PwrData; //AF9(dummy)
	//
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(SendGui);
  ccd.lpData      := @SendGui;
  SendMessage(Self.m_hTest,WM_COPYDATA,0, LongInt(@ccd));

  if nGuiMode = MSG_MODE_DISPLAY_CONNECTION then begin
    ShowMainWindow(nGuiMode, nParam, sMsg);
  end;
end;

procedure TCommPG.ShowDownLoadStatus(nGuiType: Integer; curPos,total: Integer; sMsg: string; bIsDone: Boolean = False); //TBD:DP860?
var
  ccd         : TCopyDataStruct;
  SendGui     : RGuiPgDown;
begin
  SendGui.MsgType := DefCommon.MSG_TYPE_PG; //= MSG_TYPE_AF9FPGA
  SendGui.PgNo    := m_nPg;
  SendGui.Mode    := nGuiType;
  //TBD:DP860? SendGui.Param   := nParam;
  SendGui.Total   := total;
  SendGui.CurPos  := curPos;
  SendGui.IsDone  := bIsDone;
  SendGui.sMsg    := sMsg;
	//
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(SendGui);
  ccd.lpData      := @SendGui;
  SendMessage(Self.m_hGuiDown,WM_COPYDATA,0, LongInt(@ccd));
end;


//##############################################################################
{$IFDEF PG_DP860} //############################################################
//##############################################################################
//###                                                                        ###
//###                             PG_DP860                                   ###   
//###                                                                        ###
//##############################################################################
//##############################################################################

//==============================================================================
// DP860 Timer
//------------------------------------------------------------------------------
// procedure/function: 
//		- procedure TCommPG.ConnCheckTimer_DP860(Sender: TObject);
//
procedure TCommPG.ConnCheckTimer_DP860(Sender: TObject); //TBD:DP860?
begin
  try
		//
    if (not m_bCyclicTimer) then Exit;
    if m_bPwrMeasure and tmPwrMeasure.Enabled then Exit;
    {$IF Defined(INSPECTOR_OC) or Defined(INSPECTOR_PreOC)}
    if CSharpDll.m_bIsDLLWork[m_nPg] then Exit;
    {$ENDIF}
		//
    if m_bWaitEvent then Exit;
    if m_bWaitPwrEvent then Exit;
    //
    if (m_nConnCheckNG > 2) and (StatusPg <> pgDisconn) then begin  //TBD:DP860? 3?
      m_nConnCheckNG := 0;
      StatusPg := pgDisconn;
      //
      InitPgVer;
			ShowTestWindow(Defcommon.MSG_MODE_DISPLAY_CONNECTION, DefCommon.PG_CONN_DISCONNECTED, 'DP860 Disconnected');
      // Change ConnCheck Interval
  		tmConnCheck.Enabled  := False;
  		tmConnCheck.Interval := 1000;
  		tmConnCheck.Enabled  := True;
      // Disable PwrMeasure Timer
			tmPwrMeasure.Enabled := False;
			m_bPwrMeasure := False;
    end
    else begin
		//if (m_ABinding <> nil) then begin //TBD:DP860?
        DP860_SendConnCheck;
        Inc(m_nConnCheckNG);
    //end;
    end;
	except
		OutputDebugString(PChar('>> ConnCheckTimer_DP860 Exception Error!!'));
	end;
end;

//==============================================================================
// PG TX/RX Common (----)
//==============================================================================

function TCommPG.DP860_GetStrCmdResult(dwRtn: DWORD): string;
var
	sCmdResult : string;
begin
	case dwRtn of
		WAIT_OBJECT_0 : sCmdResult := ' OK';
		WAIT_FAILED   : sCmdResult := ' NG(Failed)';  //TBD:DP860? NAK? FAILED?
		WAIT_TIMEOUT  : sCmdResult := ' NG(TimeOut)';
    else 					  sCmdResult := ' NG(Etc)';
	end;
	Result := sCmdResult;
end;

//==============================================================================
// DP860 TX/RX Common - CmdAck
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.CheckCmdAck(Task: TProc; nCmdId: Integer; sCmdName: string; nWaitMS, nRetry: Integer): DWORD; //TBD:DP860?
//		- 
//
function TCommPG.CheckCmdAck(Task: TProc; nCmdId: Integer; sCmdName: string; nWaitMS, nRetry: Integer): DWORD; //TBD:DP860?
var
	dwRtn : DWORD;
	i     : Integer;
begin
  dwRtn := WAIT_FAILED;
	try
		if m_bWaitEvent then Sleep(50) else if m_bWaitPwrEvent then Sleep(100); //2020-12-16 //TBD:MERGE?

    // Create Event
    m_bWaitEvent := True;
		m_sEvent     := Format('TxPG%d%0.2d%s',[Self.m_nPg,nCmdId,sCmdName]);
		m_hEvent     := CreateEvent(nil, False, False, PWideChar(m_sEvent));

  {
		CmdState  : Integer;
        PG_CMDSTATE_NONE       = 0;
        PG_CMDSTATE_TX_NOACK   = 1;
        PG_CMDSTATE_TX_WAITACK = 2;
        PG_CMDSTATE_RX_ACK     = 3; //TBD:DP860?
		CmdResult : Integer;
        PG_CMDRESULT_NONE = 0;
        PG_CMDRESULT_OK   = 1;
        PG_CMDRESULT_NG   = 2;
		// TX
    TxCmdId   : Integer;
    TxStr     : string;
    TxDataLen : Integer; //TBD:DP860?
    TxData    : array [0..64*1024] of Byte; //TBD:DP860?
		// RX
    RxCmdId   : Integer; //TBD:DP860?
    RxStrAck  : string;
    RxDataLen : Integer; //TBD:DP860?
    RxData    : array [0..64*1024] of Byte; //TBD:DP860?
    //
    RxStrPrev : string;
  }
    try
  		for i := 0 to nRetry do begin
    		if StatusPg in [pgDisconn] then Break;
        //
        with FTxRxPG do begin
          CmdState  := DefPG.PG_CMDSTATE_TX_WAITACK;
          CmdResult := DefPG.PG_CMDRESULT_NONE;
          //
          TxCmdId   := nCmdId;
        //TxCmdStr  :=
          TxDataLen := 0;
          //
          RxCmdId   := DefPG.PG_CMDID_UNKNOWN; //TBD:DP860?
          RxAckStr  := '';                     //TBD:DP860?
          RxDataLen := 0;                      //TBD:DP860?
        end;
  			//
        try
          Task;
        dwRtn := WaitForSingleObject(m_hEvent, nWaitMS);
        FTxRxPG.CmdState := DefPG.PG_CMDSTATE_NONE;
        case dwRtn of
          WAIT_OBJECT_0 : begin
            if {(FTxRxPG.CmdState = DefPG.PG_CMDSTATE_RX_ACK) and} (FTxRxPG.CmdResult = DefPG.PG_CMDRESULT_OK) then
              Break
            else
              dwRtn := WAIT_FAILED;
          end;
          WAIT_TIMEOUT : begin
          end
          else begin
            Break;
          end;
        end;
      except
        Break;
      end;
      end;
    except
    end;

	finally
    // Close Event
    CloseHandle(m_hEvent);
    m_bWaitEvent := False;
	end;
  Result := dwRtn;
end;

//==============================================================================
// PG_DP860 TX/RX Common (Send)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendCmd(sCmd: string; nCmdId: Integer; sCmdName: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? Return;Integer? DWORD? 3000?
//		- procedure TCommPG.DP860_SendData(nBindIdx: Integer; sData: string);
//
function TCommPG.DP860_SendCmd(sCommand: string; nCmdId: Integer; sCmdName: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? Return;Integer? DWORD? 3000?
var
  nBindIdx   : Integer;
  PTxRxData  : PPgTxRxData;
  bStatusCmd : Boolean;
  i : integer;
begin
  //
  bStatusCmd := False;
  case nCmdId of
    DefPG.PG_CMDID_CONNCHECK  : bStatusCmd := True;
    DefPG.PG_CMDID_POWER_READ : if nWaitMS = 0 then bStatusCmd := True;
  end;
  bStatusCmd := (nCmdId in [DefPG.PG_CMDID_CONNCHECK {, DefPG.PG_CMDID_POWER_READ}]); //TBD?
  if (m_bWaitEvent or m_bWaitPwrEvent) and bStatusCmd then Exit; //skip
  //
//if m_bWaitEvent then Sleep(100) else if m_bWaitPwrEvent then Sleep(300); //2020-12-16 //TBD:DP860? PG_PWRMEASURE_WAIT_DEF
  if m_bWaitEvent then begin
		i := 0;
		while m_bWaitEvent and (i < PG_CMD_WAITACK_DEF) do begin //TBD:DP860? PG_CMD_WAITACK_DEF?
			Sleep(1);
			Inc(i);
		end;
	end
	else if m_bWaitPwrEvent then begin
		i := 0;
		while m_bWaitEvent and (i < DefPG.PG_PWRMEASURE_WAITACK_DEF) do begin //TBD:DP860? PG_PWRMEASURE_WAITACK_DEF?
			Sleep(1);
			Inc(i);
		end;
	end;
  //
  Result := WAIT_OBJECT_0;

  {
		CmdState  : Integer;
        PG_CMDSTATE_NONE       = 0;
        PG_CMDSTATE_TX_NOACK   = 1;
        PG_CMDSTATE_TX_WAITACK = 2;
        PG_CMDSTATE_RX_ACK     = 3; //TBD:DP860?
		CmdResult : Integer;
        PG_CMDRESULT_NONE = 0;
        PG_CMDRESULT_OK   = 1;
        PG_CMDRESULT_NG   = 2;
		// TX
    TxCmdId   : Integer;
    TxStr     : string;
    TxDataLen : Integer; //TBD:DP860?
    TxData    : array [0..64*1024] of Byte; //TBD:DP860?
		// RX
    RxCmdId   : Integer; //TBD:DP860?
    RxStrAck  : string;
    RxDataLen : Integer; //TBD:DP860?
    RxData    : array [0..64*1024] of Byte; //TBD:DP860?
    //
    RxStrPrev : string;
  }

  //
  case nCmdId of
    DefPG.PG_CMDID_CONNCHECK : begin
      nWaitMS := 0;
    end;
    DefPG.PG_CMDID_POWER_READ : begin
      if (Self.StatusPg <> pgReady) then Exit(WAIT_FAILED);
      if (nWaitMS > 0) then m_bWaitPwrEvent := True;
    end;
    else begin
      if Self.StatusPg = pgDisconn then Exit(WAIT_FAILED); //TBD:DP860?
    end;
  end;

//TBD:DP860?  if FIsForceStop then Exit;
//TBD:DP860?  if sCmd = 'download' then FRxSigData.IsFirstCnn := False;
//TBD:DP860?  if sCmd = 'reset' then FRxSigData.IsFirstCnn := False;
//TBD:DP860?  FRxSigData.IsFirstCnn := False;

  //----------------
  if (nWaitMS <= 0) then PTxRxData := @FTxRxDEF else PTxRxData := @FTxRxPG;
  PTxRxData^.CmdState  := TernaryOp((nWaitMS > 0), DefPG.PG_CMDSTATE_TX_WAITACK, DefPG.PG_CMDSTATE_TX_NOACK);
  PTxRxData^.CmdResult := DefPG.PG_CMDRESULT_NONE;
  // TX
  PTxRxData^.TxCmdId   := nCmdId;
  PTxRxData^.TxCmdStr  := sCommand;
  // RX
//PTxRxData^.RxCmdId   := //TBD:DP860?
//PTxRxData^.RxAckStr  := //TBD:DP860?

  //----------------
  if (nWaitMS <= 0) then begin
    DP860_SendData(DefCommon.MAX_PG_CNT{nBindIdx},sCommand); //SourcePort:8000
    Result := WAIT_OBJECT_0;
  end
  else begin
    PTxRxData^.RxPrevStr := ''; //2023-04-28 //TBD?
    Result := CheckCmdAck(procedure begin DP860_SendData(m_nPg{nBindIdx},sCommand); end, nCmdId,sCmdName, nWaitMS,nRetry);
  end;
end;

procedure TCommPG.DP860_SendData(nBindIdx: Integer; sCommand: string);
begin
  UdpServerPG.UdpSvrSend(nBindIdx, m_nPg, sCommand+#$0D);
end;

//==============================================================================
// PG_DP860 TX/RX Common (Read)
//------------------------------------------------------------------------------
// procedure/function: 
//		- procedure TCommPG.DP860_OnUdpRX(sCmdAck: string; nLocalPort,nPeerPort: Integer); //#OnReadEvent //TBD:DP860?
//

procedure TCommPG.DP860_OnUdpRX(sCmdAck: string; nLocalPort,nPeerPort: Integer); //#OnReadEvent //TBD:DP860?
var
  arData : TArray<string>;
  nLen   : integer;
  PTxRxData : PPgTxRxData;
begin
  TconRWCnt.ContTConOcWrite := 0; //2023-03-28 jhhwang (for T/T Test)

//sCmdAck := StringReplace(sCmdAck, #$0A, '', [rfReplaceAll]); // remove #$0A //2022-11-09 move to UdpServerPG.Read???
  arData  := sCmdAck.Split([#$0D]);
  nLen    := Length(arData);

  // Case.1 : NoAckWait (ConnCheck|PowerRead|PgInit)
  if nLocalPort = DefPG.CommPG_PC_PORT_BASE then begin
    //
    PTxRxData := @FTxRxDEF;
    PTxRxData^.CmdResult := TernaryOp((UpperCase(arData[nLen-1]) = 'RET:OK'), DefPG.PG_CMDRESULT_OK, DefPG.PG_CMDRESULT_NG);

    if Pos('power parameters :',LowerCase(sCmdAck)) <> 0 then begin  // ack for power.read
      PTxRxData^.CmdState := DefPG.PG_CMDSTATE_NONE;
      PTxRxData^.TxCmdId  := DefPG.PG_CMDID_UNKNOWN;
      PTxRxData^.RxCmdId  := DefPG.PG_CMDID_POWER_READ;
      DP860_ReadPowerMeasureAck(sCmdAck);
    end
    else if Pos(LowerCase(DefPG.PG_CMDSTR_PG_INIT),LowerCase(sCmdAck)) <> 0 then begin  // pg.init
      PTxRxData^.RxCmdId := DefPG.PG_CMDID_PG_INIT;
      DP860_ReadPgInit;
    end
    else begin
      if PTxRxData^.TxCmdId = DefPG.PG_CMDID_CONNCHECK then begin // ack for pg.status
        PTxRxData^.CmdState := DefPG.PG_CMDSTATE_NONE;
        PTxRxData^.TxCmdId  := DefPG.PG_CMDID_UNKNOWN;
        PTxRxData^.RxCmdId  := DefPG.PG_CMDID_CONNCHECK;
        DP860_ReadConnCheckAck(sCmdAck);
      end
      else begin
        //TBD:DP860??
        PTxRxData^.RxCmdId := DefPG.PG_CMDID_UNKNOWN //TBD:IMSI?
      end;
    end;
    Exit; //!!!
  end;

  // Case.2 : CmdAck (except ConnCheck|PowerRead|PgInit)
  PTxRxData := @FTxRxPG;
  PTxRxData^.CmdState  := DefPG.PG_CMDSTATE_RX_ACK; //TBD:DP860?
  PTxRxData^.CmdResult := TernaryOp((UpperCase(arData[nLen-1]) = 'RET:OK'), DefPG.PG_CMDRESULT_OK, DefPG.PG_CMDRESULT_NG);
  PTxRxData^.RxAckStr  := sCmdAck; //TBD:DP860?
  //TBD:DP860?

  if m_bWaitEvent then SetEvent(m_hEvent);

{$IFDEF IMSI}
  FCurentPort := nPort;
{$ENDIF}
end;

procedure TCommPG.DP860_ReadPgInit;
var
  sDebug : string;
begin
  try
    SetCyclicTimer(False{bEnable});
    //
   	sDebug := 'RCV pg.init';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
    Sleep(100);
    //
    m_nConnCheckNG := 0;
    StatusPg := pgGetPgVer; //TBD:DP860?
    DP860_SendVersionAll; //TBD:DP860?
  finally
    SetCyclicTimer(True{bEnable});
  end;
end;

function TCommPG.DP860_GetPgLogMsg(sAckStr: string): string;
var
  arTemp : TArray<string>;
  sPgLog : string;
  i : Integer;
begin
  Result := '';
  if Length(sAckStr) = 0 then Exit;
  //
  try
    arTemp := sAckStr.Split([#$0D]);
    for i := 0 to (Length(arTemp) - 2) do begin // without RET:XX
      if i > 0 then Result := Result + '#';
      Result := Result + Trim(arTemp[i]);
    end;
  except
    Result := 'GetErrorPgLogMsg';
  end;
end;

//==============================================================================
// PG_DP860 Command - ConnCheck
//------------------------------------------------------------------------------
// procedure/function:
//		- procedure TCommPG.DP860_SendConnCheck;
//    - procedure TCommPG.DP860_ReadConnCheckAck(sCmdAck: string);
//
procedure TCommPG.DP860_SendConnCheck;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug : string;
begin
  if m_bWaitEvent or m_bWaitPwrEvent then Exit; // skip if command ack waiting
  //
  nCmdId   := DefPG.PG_CMDID_CONNCHECK;
  sCmdName := DefPG.PG_CMDSTR_CONNCHECK;  // 'pg.status'
	//
	sCommand := sCmdName;
  DP860_SendCmd(sCommand, nCmdId,sCmdName, 0{bWaitAck},0{nRetry});
  //
//sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result);
//ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

procedure TCommPG.DP860_ReadConnCheckAck(sCmdAck: string);
var
  dwRet : DWORD;
begin
  m_nConnCheckNG := 0;
  //
  case StatusPg of
    pgDisconn, pgConnect : begin
			ShowTestWindow(Defcommon.MSG_MODE_DISPLAY_CONNECTION,	DefCommon.PG_CONN_CONNECTED, 'PG Connected');
//      DP860_SendOcOnOff(0,2000,0);
      StatusPg := pgGetPgVer;
      dwRet := DP860_SendVersionAll;
      if dwRet = WAIT_TIMEOUT then begin
        DP860_SendOcOnOff(0,2000,0);
      end;
    end;
    pgGetPgVer, pgModelDown : begin
			//TBD:DP860?
    end;
    pgReady: begin
			//TBD:DP860?
    end;
    pgWait: ;
    pgDone: ;
    pgForceStop: begin
			//TBD:DP860?
		end;
  end;
end;

//==============================================================================
// PG_DP860 Command - Version
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.DP860_SendVersionAll(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//    - procedure TCommPG.DP860_ReadVersionAllAck(sCmdAck: string);
//		- function TCommPG.DP860_SendModelVersion(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//    - procedure TCommPG.DP860_ReadModelVersionAck(sCmdAck: string);
//
function TCommPG.DP860_SendVersionAll(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug : string;
begin
	nCmdId   := DefPG.PG_CMDID_VERSION_ALL;
	sCmdName := DefPG.PG_CMDSTR_VERSION_ALL;  // 'version.all'
	sCommand := sCmdName;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  Sleep(100);
  //
  if FTxRxPG.TxCmdId <> DefPG.PG_CMDID_VERSION_ALL then begin
    //TBD:DP860? debug !!!
  end;
  //
  case Result of  //TBD:DP860?
    WAIT_OBJECT_0 : begin
      DP860_ReadVersionAllAck(FTxRxPG.RxAckStr);
		//ShowTestWindow(Defcommon.MSG_MODE_DISPLAY_CONNECTION, DefCommon.PG_CONN_VERSION, 'PG Connected');
      //
      if StatusPg <> pgReady then begin
        Common.ThreadTask( procedure begin
          DP860_SendModelVersion;
        end);
      end;
    end;
    WAIT_TIMEOUT  : StatusPg := pgDisconn; //TBD:DP860?
    else            StatusPg := pgConnect; //TBD:DP860?
  end;
end;

procedure TCommPG.DP860_ReadVersionAllAck(sCmdAck: string);
var
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  i, nVerInfo : Integer;
begin
  // HW_1.3_APP_1.0.2_FW_1.02_FPGA_10105(1.6.0)_PWR_1.0
  arCmdAck := sCmdAck.Split([#$0D]);
  m_PgVer.VerAll := arCmdAck[0];
  //
  arTemp := m_PgVer.VerAll.Split(['_']);
  nVerInfo := Length(arTemp);
  i := 0;
  while ((i+1) <= nVerInfo) do begin
    if      arTemp[i] = 'HW'   then m_PgVer.HW    := arTemp[i+1]
    else if arTemp[i] = 'APP'  then m_PgVer.FW    := arTemp[i+1]
    else if arTemp[i] = 'FW'   then m_PgVer.SubFW := arTemp[i+1]
    else if arTemp[i] = 'FPGA' then m_PgVer.FPGA  := arTemp[i+1]
    else if arTemp[i] = 'PWR'  then m_PgVer.PWR   := arTemp[i+1];
    //
    i := i + 2;
  end;
end;

function TCommPG.DP860_SendModelVersion(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug : string;
begin
	nCmdId   := DefPG.PG_CMDID_MODEL_VERSION;
	sCmdName := DefPG.PG_CMDSTR_MODEL_VERSION; // 'model.version'
	sCommand := sCmdName;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  Sleep(100);
  //
  if FTxRxPG.TxCmdId <> DefPG.PG_CMDID_VERSION_ALL then begin
    //TBD:DP860? debug !!!
  end;
  //
  case Result of  //TBD:DP860?
    WAIT_OBJECT_0 : begin
      DP860_ReadModelVersionAck(FTxRxPG.RxAckStr);
			ShowTestWindow(Defcommon.MSG_MODE_DISPLAY_CONNECTION, DefCommon.PG_CONN_VERSION, 'PG Connected');
      //
      if StatusPg <> pgReady then begin
        Common.ThreadTask( procedure begin
          DP860_ModelInfoDownload;
        end);
      end;
    end;
    WAIT_TIMEOUT  : StatusPg := pgDisconn; //TBD:DP860?
    else            StatusPg := pgConnect; //TBD:DP860?
  end;
end;

function TCommPG.DP860_SendNvmErase(nAddr, nSize: DWORD; nWaitMS, nRetry: Integer): DWORD;
begin

end;

function TCommPG.DP860_SendNvmRead(nAddr, nSize: DWORD; pData: PByte; nWaitMS, nRetry: Integer): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  //
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  pTemp    : PByte;
  i        : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_NVM_READ;
	sCmdName := DefPG.PG_CMDSTR_NVM_READ; // nvm.read <hex_addr> <length>
  sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('0x%x %d',[nAddr,nSize]);
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end
  else begin
    try
      arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
      arTemp   := arCmdAck[0].Split([' ']);
      sEtcMsg  := Format('[%s]',[arCmdAck[0]]);
      //
      if Length(arTemp) >= nSize then begin
        pTemp := pData;
        for i := 0 to (nSize-1) do begin
          pTemp^ := StrToInt('$'+ arTemp[i]);
          Inc(pTemp);
        end;
      end
      else begin
        sEtcMsg := sEtcMsg + Format('[ReadSize(%d)<>RxDataCnt(%d)]',[nSize,Length(arTemp)]);
        Result  := WAIT_FAILED; // RX.DATA.Cnt < nDataCnt
      end;
    except
      sEtcMsg := sEtcMsg + '[RxMsgParsingError]';
      Result  := WAIT_FAILED; //
    end;
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendNvmReadAscii(nAddr, nSize: DWORD; var sData: string; nWaitMS, nRetry: Integer): DWORD;
begin

end;

function TCommPG.DP860_SendNvmReadFile(nAddr, nSize: DWORD; sRemoteFile: string; nWaitMS, nRetry: Integer): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  nFlashReadKBPerSec : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_NVM_READFILE;
	sCmdName := DefPG.PG_CMDSTR_NVM_READFILE; // nvm.readfile <filename.bin> <hex_addr> <length>
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('%s 0x%x %d',[AnsiString(sRemoteFile),nAddr,nSize]);
  //
  nFlashReadKBPerSec := DefPG.FLASH_READ_KBperSEC_DEF;
  nWaitMS := (((nSize div (nFlashReadKBPerSec*1024)) + 1) * 1000) + nWaitMS; //TBD:FLASH:DP860?
  //
	sDebug := '<PG> ' + sCommand + Format(' :(AckWait=%d sec)',[(nWaitMS div 1000)]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  //
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendNvmWriteFile(nAddr, nSize: DWORD; sRemoteFile: string; bVerify, bErase: Boolean; nWaitMS, nRetry: Integer): DWORD;
begin

end;

procedure TCommPG.DP860_ReadModelVersionAck(sCmdAck: string);
var
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  i, nVerInfo : Integer;
begin
  // ITO_DP860__v0002_20221206
  arCmdAck := sCmdAck.Split([#$0D]);
  m_PgVer.VerScript := arCmdAck[0];
end;

//==============================================================================
// PG_DP860 Command - Model
//------------------------------------------------------------------------------
// procedure/function:
//		- function DP860_ModelInfoDownload: DWORD
//		- function TCommPG.DP860_SendPowerOpen(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_MakeCmdParam_PowerOpen: string;
//		- //function TCommPG.DP860_SendPowerLimit(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- //function TCommPG.DP860_MakeCmdParam_PowerLimit: string;
//		- function TCommPG.DP860_SendPowerSequence(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_MakeCmdParam_PowerSequence: string;
//		- function TCommPG.DP860_SendModelConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_MakeCmdParam_ModelConfig: string;
//		- function TCommPG.DP860_SendAlpmConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_MakeCmdParam_AlpmConfig: string;
//		- //function TCommPG.DP860_SendDpTiming(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- //function TCommPG.DP860_MakeCmdParam_DpTiming: string
//

function TCommPG.DP860_ModelInfoDownload: DWORD;
var
	sDebug : string;
begin
	Result := WAIT_FAILED;
  //
  try
    SetCyclicTimer(False{bEnable});
	  StatusPg := pgModelDown;
  	//
    sDebug   := 'PG Model Info Download (power.open)';
    Result   := DP860_SendPowerOpen(3000{bWaitMS},1{nRetry});
  	sDebug   := sDebug + DP860_GetStrCmdResult(Result);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  	if Result <> WAIT_OBJECT_0 then Exit;

    sDebug := Format('Power ON SEQ : VCC -> (%d ms) -> PWR_DWN ->',[Common.TestModelInfoPG.PgPwrSeq.SeqOn[0]]);
    sDebug := sDebug + Format('(%d ms)->VIN / ',[Common.TestModelInfoPG.PgPwrSeq.SeqOn[1]]);
    sDebug := sDebug + Format('POWER OFF SEQ : PWR_DWN ->(%d ms)',[Common.TestModelInfoPG.PgPwrSeq.SeqOff[0]]);
    sDebug := sDebug + Format('->VIN->(42ms)->VCC',[Common.TestModelInfoPG.PgPwrSeq.SeqOff[1]]);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, 0, sDebug);
    Sleep(50);
  	//
    sDebug   := 'PG Model Info Download (power.seq)';
    Result   := DP860_SendPowerSeq(3000{bWaitMS},1{nRetry});
  	sDebug   := sDebug + DP860_GetStrCmdResult(Result);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  	if Result <> WAIT_OBJECT_0 then Exit;
    Sleep(50);
  	//
    sDebug   := 'PG Model Info Download (model.config)';
    Result   := DP860_SendModelConfig(3000{bWaitMS},1{nRetry});
  	sDebug   := sDebug + DP860_GetStrCmdResult(Result);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  	if Result <> WAIT_OBJECT_0 then Exit;
    Sleep(50);
  	//
    sDebug   := 'PG Model Info Download (alpm.comfig)';
    Result   := DP860_SendAlpmConfig(3000{bWaitMS},1{nRetry});
  	sDebug   := sDebug + DP860_GetStrCmdResult(Result);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  	if Result <> WAIT_OBJECT_0 then Exit;
    Sleep(50);
    //
    Result := WAIT_OBJECT_0;
  finally
    case Result of
      WAIT_OBJECT_0 : begin
      	StatusPg := pgReady;
  			ShowTestWindow(Defcommon.MSG_MODE_DISPLAY_CONNECTION, DefCommon.PG_CONN_READY, 'PG Ready');
        // Change ConnCheck Interval
    		tmConnCheck.Enabled  := False;
    		tmConnCheck.Interval := 3000;
    		tmConnCheck.Enabled  := True;
      end;
      WAIT_TIMEOUT  : StatusPg := pgDisconn;
      else            StatusPg := pgConnect;
    end;
    SetCyclicTimer(True{bEnable});
  end;
end;

//
// power.open <channel> <VCC_voltage_value> <VIN_voltage_value> <VDD3_voltage_value> <VDD4_voltage_value> <VDD5_voltage_value>
//                         <slope_set> <I_VCC_high_limit_value> <I_VIN_high_limit_value>  <VCC_high_limit_value> <VIN_high_limit_value>
//    e.g., power.open ALL 4900 6500 1800 9999 9999 S0 I4000 I6000 V49 V65
//
function TCommPG.DP860_SendPowerOpen(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_POWER_OPEN;
	sCmdName := DefPG.PG_CMDSTR_POWER_OPEN;  // 'power.open'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + DP860_MakeCmdParam_PowerOpen;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_MakeCmdParam_PowerOpen: string;
var
	sCmdParam : string;
begin
  with Common.TestModelInfoPG.PgPwrData do begin
    sCmdParam := Format('ALL %d %d %d %d %d',[PWR_VOL[DefPG.PWR_VDD1],PWR_VOL[DefPG.PWR_VDD2],PWR_VOL[DefPG.PWR_VDD3],PWR_VOL[DefPG.PWR_VDD4],PWR_VOL[DefPG.PWR_VDD5]]);
    //
    sCmdParam := sCmdParam + ' ' + Format('S%d',[PWR_SLOPE]); // SLOPE_SET
    //
    sCmdParam := sCmdParam + ' ' + Format('I%d',[(PWR_CUR_HL[DefPG.PWR_VDD1])]);         // IVCC_HL (1=1mA)   e.g., I4000 (4.0A)
    sCmdParam := sCmdParam + ' ' + Format('I%d',[(PWR_CUR_HL[DefPG.PWR_VDD2])]);         // IVIN_HL (1=1mA)   e.g., I5000 (5.0A)
    sCmdParam := sCmdParam + ' ' + Format('V%d',[(PWR_VOL_HL[DefPG.PWR_VDD1] div 100)]); //  VCC_HL (1=100mV) e.g., V49 (4.9V)
    sCmdParam := sCmdParam + ' ' + Format('V%d',[(PWR_VOL_HL[DefPG.PWR_VDD2] div 100)]); //  VIN_HL (1=100mV) e.g., V65 (6.5V)
  end;
	Result := sCmdParam;
end;

//
// power.seq <on1_value> <on2_value> <off1_value> <off2_value>
//    e.g., power.seq 4 10 150 2
//
function TCommPG.DP860_SendPowerSeq(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_POWER_SEQ;
	sCmdName := DefPG.PG_CMDSTR_POWER_SEQ; // 'power.seq'
	sEtcMsg  := '';
	//
	sCommand := sCmdName  + ' ' + DP860_MakeCmdParam_PowerSeq;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_MakeCmdParam_PowerSeq: string;
var
	sCmdParam : string;
begin
  with Common.TestModelInfoPG.PgPwrSeq do begin
    // obsoleted!!! sCmdParam :=                   Format('%d',[SeqType]);
    // obsoleted!!! sCmdParam := sCmdParam + ' ' + Format('%d %d',[SeqOn[0] ,SeqOn[1]]);  // SeqOn[0]  ~ SeqOn[1]
    // obsoleted!!! sCmdParam := sCmdParam + ' ' + Format('%d %d',[SeqOff[0],SeqOff[1]]); // SeqOff[0] ~ SeqOff[1]
    sCmdParam :=                   Format('%d %d',[SeqOn[0] ,SeqOn[1]]);  // SeqOn[0]  ~ SeqOn[1]
    sCmdParam := sCmdParam + ' ' + Format('%d %d',[SeqOff[0],SeqOff[1]]); // SeqOff[0] ~ SeqOff[1]
  end;
	Result := sCmdParam;
end;

//
// model.config <Link rate> <lane> <H width> <H bporch> <H active> <H fporch> <V width> <V bporch> <V active> <V fporch> <Vsync> <Format> <ALPM set> <vfb_offset>
//    e.g., model.config 2700 4 8 198 2360 94 2 18 1640 60 60 RGBG24 0 0
//
function TCommPG.DP860_SendModelConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_MODEL_CONFIG;
	sCmdName := DefPG.PG_CMDSTR_MODEL_CONFIG; // 'model.config'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + DP860_MakeCmdParam_ModelConfig; //TBD:DP860? DP860_MakeCmdParam_ModelConfig?
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_MakeCmdParam_ModelConfig: string;
var
	sCmdParam : string;
begin
	sCmdParam := '';
  with Common.TestModelInfoPG.PgModelConf do begin
    sCmdParam :=                   Format('%d',[link_rate]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[lane]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[H_SA]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[H_BP]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[H_Active]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[H_FP]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[V_SA]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[V_BP]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[V_Active]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[V_FP]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[Vsync]);
    sCmdParam := sCmdParam + ' ' + Trim(RGBFormat);
    sCmdParam := sCmdParam + ' ' + Format('%d',[ALPM_Mode]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vfb_offset]);
  end;
	Result := sCmdParam;
end;

//
// alpm.config <h_fdp> <h_sdp> <h_pcnt> <vb_n5b> <vb_n7> <vb_n5a> <vb_sleep> <vb_n2> <vb_n3> <vb_n4> <m_vid> <n_vid> <misc_0> <misc_1> <xpol> <xdelay>
//             <h_mg> <NoAux_Sel> <NoAux_active> <NoAux_Sleep> <Critical_section> <tps> <v_blank> <chop_enable> <chop_interval> <chop_size>
//    e.g., alpm.config 455 16 611 172 0 0 0 0 0 0 34301 32768 32 0 X0 0 12 2 0 0 67 3 n5b 0 0 0
//
function TCommPG.DP860_SendAlpmConfig(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_ALPM_CONFIG;
	sCmdName := DefPG.PG_CMDSTR_ALPM_CONFIG; // 'alpm.config'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + DP860_MakeCmdParam_AlpmConfig;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_MakeCmdParam_AlpmConfig: string;
var
	sCmdParam : string;
begin
	sCmdParam := '';
  with Common.TestModelInfoPG.PgModelConf do begin
    sCmdParam :=                   Format('%d',[h_fdp]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[h_sdp]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[h_pcnt]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n5b]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n7]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n5a]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_sleep]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n2]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n3]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[vb_n4]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[m_vid]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[n_vid]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[misc_0]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[misc_1]);
    sCmdParam := sCmdParam + ' ' + TernaryOp((xpol=0),'X0','X1'); //0:'X0', 1:'X1'
    sCmdParam := sCmdParam + ' ' + Format('%d',[xdelay]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[h_mg]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[NoAux_Sel]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[NoAux_Active]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[NoAux_Sleep]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[critical_section]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[tps]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[v_blank]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[chop_enable]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[chop_interval]);
    sCmdParam := sCmdParam + ' ' + Format('%d',[chop_size]);
  end;
	Result := sCmdParam;
end;

//==============================================================================
// PG_DP860 Command - Power On/Off
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.DP860_SendPowerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
//		- function TCommPG.DP860_SendPowerOff(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
//    - function DP860_SendInterposerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
//    - function DP860_SendInterposerOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
//
function TCommPG.DP860_SendPowerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_POWER_ON;
	sCmdName := DefPG.PG_CMDSTR_POWER_ON;


	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendPowerOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_POWER_OFF;
	sCmdName := DefPG.PG_CMDSTR_POWER_OFF; // 'power.off'


	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;


function TCommPG.DP860_SendPowerBistOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_POWER_BIST_ON;    //Pre OC 및 OC FLow 제어를 위해
	sCmdName := DefPG.PG_CMDSTR_POWER_BIST_ON;  // 'power.bist.on'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendPowerBistOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_POWER_BIST_OFF;
	sCmdName := DefPG.PG_CMDSTR_POWER_BIST_OFF; // 'power.off'


	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendInterposerOn(nWaitMS: Integer=10000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_INTERPOSER_ON;
	sCmdName := DefPG.PG_CMDSTR_INTERPOSER_ON;  // 'interposer.init'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ':' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendInterposerOff(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //TBD:DP860? nWaitMS default for PowerOn/PowerOff
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_INTERPOSER_OFF;
	sCmdName := DefPG.PG_CMDSTR_INTERPOSER_OFF; // 'interposer.deinit'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendDutDetect(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_DUT_DETECT;
	sCmdName := DefPG.PG_CMDSTR_DUT_DETECT; // 'dut.detec'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendTconInfo(nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  arCmdAck : TArray<string>;
begin
	nCmdId   := DefPG.PG_CMDID_TCON_INFO;
	sCmdName := DefPG.PG_CMDSTR_TCON_INFO; // 'tcon.info'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end
  else begin
    try
      arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
      sEtcMsg  := '[' + arCmdAck[0] + ']';
    except
    end;
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

//==============================================================================
// PG_DP860 Command - Power Measurement
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD;
//		- procedure TCommPG.DP860_ReadPowerMeasureAck(sCmdAck: string);

function TCommPG.DP860_SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  nWaitMS : Integer;
begin
  if m_bWaitEvent or m_bWaitPwrEvent then begin
    if (not bCyclicMeasure) then Sleep(TernaryOp(m_bWaitPwrEvent,DefPG.PG_PWRMEASURE_WAITACK_DEF,DefPG.PG_CMD_WAITACK_DEF)) // delay if command ack waiting
    else                         Exit;       // skip  if command ack waiting
  end;
  //
	nCmdId   := DefPG.PG_CMDID_POWER_READ;
	sCmdName := DefPG.PG_CMDSTR_POWER_READ;
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, DefPG.PG_PWRMEASURE_WAITACK_DEF); //TBD:DP860? (500ms?)
  //
	if (not bCyclicMeasure) then begin
		sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result);
  	ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
	end;
end;

procedure TCommPG.DP860_ReadPowerMeasureAck(sCmdAck: string); //TBD:DP860?
var
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  i, nVerInfo : Integer;
begin
  m_bWaitPwrEvent := False;

  //
  // Power parameters :
  // (01) [0] VCC(mV) :3688
  // (02) [0] I_VCC(mA) :0.000
  // (03) [0] VIN(mV) :6140
  // (04) [0] I_VIN(mA) :0.000
  // (05) [0] SYS(mV) :0
  // (06) [0] I_SYS(mA) :0.000
  // (07) [0] VDD4(mV) :0
  // (08) [0] I_VDD4(mA) :0.000
  // (09) [0] VDD5(mV) :0
  // (10) [0] I_VDD5(mA) :0.000
  // RET:OK
  //
  if Pos('power parameters :',LowerCase(sCmdAck)) = 0 then begin // not found
    //TBD:AbnormalCase?
    Exit;
  end;

  arCmdAck := sCmdAck.Split([#$0D]);
  //
  arTemp := arCmdAck[1].Split([':']);  m_RxPwrData.VCC   := StrToUInt(Trim(arTemp[1]));  // VDD1(=VCC)
  arTemp := arCmdAck[2].Split([':']);  m_RxPwrData.IVCC  := Round(StrToFloat(Trim(arTemp[1]))*1000); // IVDD1(=IVCC) //TBD:DP860?
  arTemp := arCmdAck[3].Split([':']);  m_RxPwrData.VIN   := StrToUInt(Trim(arTemp[1]));  // VDD2(=VIN)
  arTemp := arCmdAck[4].Split([':']);  m_RxPwrData.IVIN  := Round(StrToFloat(Trim(arTemp[1]))*1000); // IVDD2(=IVIN) //TBD:DP860?
  arTemp := arCmdAck[5].Split([':']);  m_RxPwrData.VDD3  := StrToUInt(Trim(arTemp[1]));  // VDD3(=SYS)
  arTemp := arCmdAck[6].Split([':']);  m_RxPwrData.IVDD3 := Round(StrToFloat(Trim(arTemp[1]))*1000); // IVDD3(=ISYS) //TBD:DP860?
  arTemp := arCmdAck[7].Split([':']);  m_RxPwrData.VDD4  := StrToUInt(Trim(arTemp[1]));  // VDD4
  arTemp := arCmdAck[8].Split([':']);  m_RxPwrData.IVDD4 := Round(StrToFloat(Trim(arTemp[1]))*1000); // IVDD4        //TBD:DP860?
  arTemp := arCmdAck[9].Split([':']);  m_RxPwrData.VDD5  := StrToUInt(Trim(arTemp[1]));  // VDD5
  arTemp := arCmdAck[10].Split([':']); m_RxPwrData.IVDD5 := Round(StrToFloat(Trim(arTemp[1]))*1000); // IVDD5        //TBD:DP860?
  //
  m_PwrData.VCC   := m_RxPwrData.VCC;
  m_PwrData.IVCC  := m_RxPwrData.IVCC  div 1000; //TBD:DP860?
  m_PwrData.VIN   := m_RxPwrData.VIN;
  m_PwrData.IVIN  := m_RxPwrData.IVIN  div 1000; //TBD:DP860?
  m_PwrData.VDD3  := m_RxPwrData.VDD3;
  m_PwrData.IVDD3 := m_RxPwrData.IVDD3 div 1000; //TBD:DP860?
  m_PwrData.VDD4  := m_RxPwrData.VDD4;
  m_PwrData.IVDD4 := m_RxPwrData.IVDD4 div 1000; //TBD:DP860?
  m_PwrData.VDD5  := m_RxPwrData.VDD5;
  m_PwrData.IVDD5 := m_RxPwrData.IVDD5 div 1000; //TBD:DP860?

  //
  ShowTestWindow(DefCommon.MSG_MODE_DISPLAY_VOLCUR,0,'');
  //
  DP860_CheckPowerLimit(m_PwrData);
end;

procedure TCommPG.DP860_CheckPowerLimit(PwrData: TPwrData);
var
  sMsg : string;
  bLimitNG, bLowLimitNG : Boolean;
  nValue, nLimit : UInt32;
begin
  bLimitNG    := False;
  bLowLimitNG := False;
  sMsg := '';

  // Compare measure value with limit
{$IF Defined(INSPECTOR_POCB)}
  with Common.TestModelInfo[m_nCh].PG.PgPwrData do
{$ELSE} // INSPECTOR_FI|INSPECTOR_OQA, INSPECTOR_GB?
  with Common.TestModelInfoPG.PgPwrData do
{$ENDIF}
  begin
    //---------------------------------- VCC/IVCC
    // VCC High Limit
  //if not bLimitNG then begin
      nValue := PwrData.VCC;  nLimit := PWR_VOL_HL[DefPG.PWR_VCC];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('VCC High NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // VCC Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.VCC;  nLimit := PWR_VOL_LL[DefPG.PWR_VCC];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('VCC Low NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // IVCC High Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVCC; nLimit := PWR_CUR_HL[DefPG.PWR_VCC];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVCC High NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;
      end;
  //end;
    // IVCC Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVCC; nLimit := PWR_CUR_LL[DefPG.PWR_VCC];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVCC Low NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    //---------------------------------- VIN/IVIN
    // VIN High Limit
  //if not bLimitNG then begin
      nValue := PwrData.VIN;  nLimit := PWR_VOL_HL[DefPG.PWR_VIN];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('VIN High NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;
      end;
  //end;
    // VIN Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.VIN;  nLimit := PWR_VOL_LL[DefPG.PWR_VIN];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('VIN Low NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // IVIN High Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVIN; nLimit := PWR_CUR_HL[DefPG.PWR_VIN];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVIN High NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;
      end;
  //end;
    // IVIN Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVIN; nLimit := PWR_CUR_LL[DefPG.PWR_VIN];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVIN Low NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    //---------------------------------- VDD3/IVDD3
    // VDD3 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD3;  nLimit := PWR_VOL_HL[DefPG.PWR_VDD3];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD3 High NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;
      end;
  //end;
    // VDD3 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD3;  nLimit := PWR_VOL_LL[DefPG.PWR_VDD3];
       if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD3 Low NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // IVDD3 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD3; nLimit := PWR_CUR_HL[DefPG.PWR_VDD3];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD3 High NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;
      end;
  //end;
    // IVDD3 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD3; nLimit := PWR_CUR_LL[DefPG.PWR_VDD3];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD3 Low NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    //---------------------------------- VDD4/IVDD4
    // VDD4 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD4;  nLimit := PWR_VOL_HL[DefPG.PWR_VDD4];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD4 High NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;
      end;
  //end;
    // VDD4 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD4;  nLimit := PWR_VOL_LL[DefPG.PWR_VDD4];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD4 Low NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // IVDD4 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD4; nLimit := PWR_CUR_HL[DefPG.PWR_VDD4];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD4 High NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;
      end;
  //end;
    // IVDD4 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD4; nLimit := PWR_CUR_LL[DefPG.PWR_VDD4];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD4 Low NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    //---------------------------------- VDD5/IVDD5
    // VDD5 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD5;  nLimit := PWR_VOL_HL[DefPG.PWR_VDD5];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD5 High NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;
      end;
  //end;
    // VDD5 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.VDD5;  nLimit := PWR_VOL_LL[DefPG.PWR_VDD5];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('VDD5 Low NG : Limit(%0.3f V), Measure(%0.3f V), Diff(%0.3f V)', [nLimit/1000, nValue/1000, (nValue/1000 - nLimit/1000)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
    // IVDD5 High Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD5; nLimit := PWR_CUR_HL[DefPG.PWR_VDD5];
      if (nLimit > 0) and (nLimit < nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD5 High NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;
      end;
  //end;
    // IVDD5 Low Limit
  //if not bLimitNG then begin
      nValue := PwrData.IVDD5; nLimit := PWR_CUR_LL[DefPG.PWR_VDD5];
      if (nLimit > 0) and (nLimit > nValue) then begin
        sMsg := sMsg + #13#10 + Format('IVDD5 Low NG : Limit(%d mA), Measure(%d mA), Diff(%d mA)', [nLimit, nValue, (nValue - nLimit)]);
        bLimitNG := True;  bLowLimitNG := True;
      end;
  //end;
  end;

  if bLimitNG then begin
    m_bPwrMeasure        := False;
    tmPwrMeasure.Enabled := False;
    //
    ShowTestWindow(DefCommon.MSG_MODE_DISPLAY_ALARM,TernaryOp(bLowLimitNG,1,0),sMsg);
  end;
end;

//==============================================================================
// PG_DP860 Command - Pattern
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.DP860_SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//    - function TCommPG.DP860_SendDisplayPatBMP(sBmpName: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//
function TCommPG.DP860_SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_IMAGE_RGB;
	sCmdName := DefPG.PG_CMDSTR_IMAGE_RGB; // 'image.rgb <R> <G> <B>'


	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%d %d %d',[nR,nG,nB]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;


function TCommPG.DP860_SendDisplayPatBistRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_BIST_RGB;
	sCmdName := DefPG.PG_CMDSTR_BIST_RGB; // 'bist.rgb <R> <G> <B>'


	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%d %d %d',[nR,nG,nB]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendDisplayPatBistRGB_9Bit(nR, nG, nB, nWaitMS, nRetry: Integer): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin

	nCmdId   := DefPG.PG_CMDID_BIST_RGB_9BIT;
	sCmdName := DefPG.PG_CMDSTR_BIST_RGB_9BIT; // 'bist.9bit <R> <G> <B>'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%d %d %d',[nR,nG,nB]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_IMAGE_DISPLAY;
	sCmdName := DefPG.PG_CMDSTR_IMAGE_DISPLAY; // 'image.display <pattern#>'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%d',[nPatNum]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendDisplayPatBMP(sBmpName: string; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_IMAGE_FILE;
	sCmdName := DefPG.PG_CMDSTR_IMAGE_FILE; // 'image.file <bmp_name>'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%s',[sBmpName]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

//==============================================================================
// PG_DP860 Command - Dimming/DBV
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendAlpdpDBV(nNit: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//    - function TCommPG.DP860_SendBistDBV(nDBV: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;

function TCommPG.DP860_SendAlpdpDBV(nDBV: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_ALPDP_DBV;
	sCmdName := DefPG.PG_CMDSTR_ALPDP_DBV; // 'alpdp.dbv <dbv#>'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('0x%x',[nDBV]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
//if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
//end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendBistDBV(nDBV: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
begin
	nCmdId   := DefPG.PG_CMDID_BIST_DBV;
	sCmdName := DefPG.PG_CMDSTR_BIST_DBV; // 'bist.dbv <dbv#>'
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('0x%x',[nDBV]);
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
//if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
//end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

//==============================================================================
// PG_DP860 Command (TCON)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendTconRead(nRegAddr,nDataCnt: Integer; var arDataR: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_SendTconWrite(nRegAddr,nDataCnt: Integer; arDataW: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
//
function TCommPG.DP860_SendTconRead(nRegAddr,nDataCnt: Integer; var arDataR: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  //
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  i        : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_TCON_READ;
	sCmdName := DefPG.PG_CMDSTR_TCON_READ;
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('0x%0.4x %d',[nRegAddr,nDataCnt]); // 'tcon.read <reg_addr16> <length>'
	Result   := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);

  Inc(TconRWCnt.TconReadTX); //2023-03-28 jhhwang (for T/T Test)
  TconRWCnt.ContTConOcWrite := 0; //2023-03-28 jhhwang (for T/T Test)
  //
  sEtcMsg  := '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  if Result = WAIT_OBJECT_0 then begin
    try
      arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
      arTemp   := arCmdAck[0].Split([' ']);
      //
      if Length(arTemp) >= nDataCnt then begin
        for i := 0 to (nDataCnt-1) do begin
          arDataR[i] := StrToInt('$'+ arTemp[i]);
        end;
      end
      else begin
        sEtcMsg := sEtcMsg + Format('(ReadSize=%d<>RxDataCnt=%d)',[nDataCnt,Length(arTemp)]);
        Result  := WAIT_FAILED; // RX.DATA.Cnt < nDataCnt
      end;
    except
      sEtcMsg :=  sEtcMsg + '(RxDataParsingError)';
      Result  := WAIT_FAILED;
    end;
  end;
  //
  if (Common.SystemInfo.DebugLogLevelConfig > 0) or (Result <> 0) then begin
	  sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  end;
end;

function TCommPG.DP860_SendTconWrite(nRegAddr,nDataCnt: Integer; arDataW: TIDBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
	i : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_TCON_WRITE;
	sCmdName := DefPG.PG_CMDSTR_TCON_WRITE;
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('0x%0.4x %d',[nRegAddr,nDataCnt]); // 'tcon.write <reg_addr> <write_length> <write_data0> <write_data1>…'
	for i := 0 to Pred(nDataCnt) do begin
		sCommand := sCommand + ' ' + Format('0x%0.2x',[arDataW[i]]);
	end;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  Inc(TconRWCnt.TconWriteTX); //2023-03-28 jhhwang (for T/T Test)
  TconRWCnt.ContTConOcWrite := 0; //2023-03-28 jhhwang (for T/T Test)
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
  if (Common.SystemInfo.DebugLogLevelConfig > 0) or (Result <> 0) then begin
    sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  end;
end;

function TCommPG.DP860_SendTconOCWrite(nRegAddr,nDataCnt: Integer; arDataW: TIDBytes; nWaitMS: Integer=0; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
	i : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_TCON_OCWRITE;
	sCmdName := DefPG.PG_CMDSTR_TCON_OCWRITE;
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('0x%0.4x %d',[nRegAddr,nDataCnt]); // 'tcon.write <reg_addr> <write_length> <write_data0> <write_data1>…'
	for i := 0 to Pred(nDataCnt) do begin
		sCommand := sCommand + ' ' + Format('0x%0.2x',[arDataW[i]]);
	end;
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  Inc(TconRWCnt.TconOcWriteTX);   //2023-03-28 jhhwang (for T/T Test)
  Inc(TconRWCnt.ContTConOcWrite); //2023-03-28 jhhwang (for T/T Test)

  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
if (Common.SystemInfo.DebugLogLevelConfig > 0) or (Result <> 0) then begin
//  if ((Common.SystemInfo.DebugLogLevelConfig > 0) and Common.SystemInfo.PG_TconWriteLogDisplay) or (Result <> 0) then begin
    sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  end;
end;

{$IFDEF FEATURE_FLASH_ACCESS}
//==============================================================================
// PG_DP860 Command (NVM/Flash Read)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendNvmErase(nAddr,nSize:DWORD; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_SendNvmRead(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_SendNvmReadAscii(nAddr,nSize:DWORD; var sData: string; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//		- function TCommPG.DP860_SendNvmReadFile(nAddr,nSize:DWORD; sRemoteFile: string; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//
function TCommPG.DP860_SendNvmErase(nAddr,nSize:DWORD; nWaitMS: Integer=FLASH_ERASE_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  nFlashEraseKBPerSec : Integer;
begin
	nCmdId := DefPG.PG_CMDID_NVM_ERASE;
	sCmdName := DefPG.PG_CMDSTR_NVM_ERASE;
  sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('0x%x',[nAddr]);
  sCommand := sCommand + ' ' + Format('%d',[nSize]);
  //
  nFlashEraseKBPerSec := DefPG.FLASH_ERASE_KBperSEC_DEF;
  nWaitMS := (((nSize div (nFlashEraseKBPerSec*1024)) + 1) * 1000) + nWaitMS; //TBD:FLASH:DP860?
  //
	sDebug := '<PG> ' + sCommand + Format(' :(AckWait=%d sec)',[(nWaitMS div 1000)]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  sEtcMsg := '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendNvmRead(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  //
  arCmdAck : TArray<string>;
  arTemp   : TArray<string>;
  pTemp    : PByte;
  i        : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_NVM_READ;
	sCmdName := DefPG.PG_CMDSTR_NVM_READ; // nvm.read <hex_addr> <length>
  sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('0x%x %d',[nAddr,nSize]);
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end
  else begin
    try
      arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
      arTemp   := arCmdAck[0].Split([' ']);
      sEtcMsg  := Format('[%s]',[arCmdAck[0]]);
      //
      if Length(arTemp) >= nSize then begin
        pTemp := pData;
        for i := 0 to (nSize-1) do begin
          pTemp^ := StrToInt('$'+ arTemp[i]);
          Inc(pTemp);
        end;
      end
      else begin
        sEtcMsg := sEtcMsg + Format('[ReadSize(%d)<>RxDataCnt(%d)]',[nSize,Length(arTemp)]);
        Result  := WAIT_FAILED; // RX.DATA.Cnt < nDataCnt
      end;
    except
      sEtcMsg := sEtcMsg + '[RxMsgParsingError]';
      Result  := WAIT_FAILED; //
    end;
  end;
  //
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendNvmReadAscii(nAddr,nSize:DWORD; var sData: string; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  //
  arCmdAck : TArray<string>;
begin
	nCmdId   := DefPG.PG_CMDID_NVM_READASCII;
	sCmdName := DefPG.PG_CMDSTR_NVM_READASCII; // nvm.readascii <hex_addr> <length>
  sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('0x%x %d',[nAddr,nSize]);
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end
  else begin
    try
      arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
      sData    := arCmdAck[0];
      //
      if Length(sData) <> nSize then begin
        sEtcMsg := sEtcMsg + Format('[ReadSize(%d)<>RxDataCnt(%d)]',[nSize,Length(sData)]);
        Result  := WAIT_FAILED;
      end;
    except
      sEtcMsg := sEtcMsg + '[RxMsgParsingError]';
      Result  := WAIT_FAILED; //
    end;
  end;
  //
  sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendNvmReadFile(nAddr,nSize:DWORD; sRemoteFile: string; nWaitMS: Integer=FLASH_READ_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  nFlashReadKBPerSec : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_NVM_READFILE;
	sCmdName := DefPG.PG_CMDSTR_NVM_READFILE; // nvm.readfile <filename.bin> <hex_addr> <length>
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('%s 0x%x %d',[AnsiString(sRemoteFile),nAddr,nSize]);
  //
  {$IFDEF INSPECTOR_POCB}
  nFlashReadKBPerSec := Common.TestModelInfo[m_nCh].PARAM.PucInfoFlash.FlashReadKBperSEC;
  if nFlashReadKBPerSec = 0 then nFlashReadKBPerSec := DefPG.FLASH_READ_KBperSEC_DEF;
  {$ELSE}
  nFlashReadKBPerSec := DefPG.FLASH_READ_KBperSEC_DEF;
  {$ENDIF}
  nWaitMS := (((nSize div (nFlashReadKBPerSec*1024)) + 1) * 1000) + nWaitMS; //TBD:FLASH:DP860?
  //
	sDebug := '<PG> ' + sCommand + Format(' :(AckWait=%d sec)',[(nWaitMS div 1000)]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  //
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

//==============================================================================
// PG_DP860 Command (NVM/Flash Write/Erase)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_SendNvmWrite(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//    - function TCommPG.DP860_SendNvmWriteFile(nAddr,nSize:DWORD; sRemoteFile: string; bVerify: Boolean=True; bErase: Boolean=True; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//    - function TCommPG.DP860_SendNvmErase(nAddr,nSize:DWORD; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
{$IFDEF TBD_DP860}
function TCommPG.DP860_SendNvmWrite(nAddr,nSize:DWORD; pData: PByte; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
	pTemp : PByte;
  i : DWORD;
begin
  nCmdId   := DefPG.PG_CMDID_NVM_WRITE;
  sCmdName := DefPG.PG_CMDSTR_NVM_WRITE; // 'nvm.write <hex_addr> <hex_data1> <hex_data2> ...'
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('0x%x',[nAddr]);
	pTemp    := pData;
  for i := 0 to (nSize-1) do begin
		sCommand := sCommand + ' ' + Format(' 0x%0.2x',[pTemp^]);
    Inc(pTemp);
	end;
  //
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug  := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;
{$ENDIF}

function TCommPG.DP860_SendNvmWriteFile(nAddr,nSize:DWORD; sRemoteFile: string; bVerify: Boolean=True; bErase: Boolean=True; nWaitMS: Integer=FLASH_WRITE_WAITMS_MINIMUM; nRetry: Integer=0): DWORD;
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  nFlashWriteKBPerSec : Integer;
begin
  nCmdId   := DefPG.PG_CMDID_NVM_WRITEFILE;
  sCmdName := DefPG.PG_CMDSTR_NVM_WRITEFILE; // 'nvm.writefile <filename.bin> <hex_addr> <length> <option1> <option2>' (option1: 'erase' or '0', option2: 'verify' or ''0)
	sEtcMsg  := '';
	//
	sCommand := sCmdName;
	sCommand := sCommand + ' ' + Format('%s 0x%x %d',[AnsiString(sRemoteFile),nAddr,nSize]);
	sCommand := sCommand + ' ' + TernaryOp(bErase,  'erase', '0');
	sCommand := sCommand + ' ' + TernaryOp(bVerify, 'verify', '0');
  //
  {$IFDEF INSPECTOR_POCB}
  nFlashWriteKBPerSec := Common.TestModelInfo[m_nCh].PARAM.PucInfoFlash.FlashWriteKBperSEC;
  if nFlashWriteKBPerSec = 0 then nFlashWriteKBPerSec := DefPG.FLASH_WRITE_KBperSEC_DEF;
  {$ELSE}
  nFlashWriteKBPerSec := DefPG.FLASH_WRITE_KBperSEC_DEF;
  {$ENDIF}
  nWaitMS := (((nSize div (nFlashWriteKBPerSec*1024)) + 1) * 1000) + nWaitMS; //TBD:FLASH:DP860?
  //
	sDebug := '<PG> ' + sCommand + Format(' :(AckWait=%d sec)',[(nWaitMS div 1000)]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  //
  try
    FIsOnFlashAccess := True;
  	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  finally
    FIsOnFlashAccess := False;
  end;
  //
  sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
	sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

//==============================================================================
// PG_DP860 Command (Flash File Upload/Download)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.DP860_FilePutPC2PG(sLocalFullName: string; sRemotePath, sRemoteFile: string; bClearBeforePut: Boolean=True; bEndDisc: Boolean=True): DWORD; //PC ---> PG
//		- function TCommPG.DP860_FileGetPG2PC(sRemotePath, sRemoteFile: string; sLocalFullName: string; bClearAfterGet: Boolean=False; bEndDisc: Boolean=True): DWORD; //PC <--- PG
//
function TCommPG.DP860_FilePutPC2PG(sLocalFullName: string; sRemotePath,sRemoteFile: string; bClearBeforePut: Boolean=True; bEndDisc: Boolean=True): DWORD;
var
  sFunc, sDebug, sErrMsg : string;
begin
	Result  := WAIT_FAILED;
  sFunc   := '<PG> FTP FileUpload';
  sDebug  := '';
  sErrMsg := '';

  sDebug := sFunc + ': Start';
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Create Class
  if FFTPClient = nil then begin
  	FFTPClient := TFTPClient.Create(PG_IPADDR, DefPG.DP860_FTP_USERNAME, DefPG.DP860_FTP_PASSWORD);
	end;
	// Connect
	if not FFTPClient.FFTP.Connected then begin
  	sErrMsg := FFTPClient.Connect;
  	if sErrMsg <> '' then begin
    	sDebug := sFunc + ': FTP Connect NG(' + sErrMsg + ')';
      ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
      FFTPClient.Disconnect;      // Added by KTS 2023-04-04 오전 10:06:24
      Exit;
    end;
	end;
  sDebug := sFunc + ': FTP Connect';
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Change Local Dir
	// Change Remote Dir
	// Delete Old File(s) if bClearBeforePut=True
  if bClearBeforePut then begin
  	sErrMsg := FFTPClient.DeleteFile(sRemoteFile);
    if sErrMsg <> '' then begin
    	sDebug := sFunc + Format(': DeleteFile(Remote=%s) NG(%s)',[sRemoteFile,sErrMsg]);
      ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_NG, sDebug);
      Exit;
    end;
	  sDebug := sFunc + Format(': DeleteFile(Remote=%s)',[sRemoteFile]);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  end;

	// Put
	sErrMsg := FFTPClient.Put(sLocalFullName, sRemoteFile);
  if sErrMsg <> '' then begin
  	sDebug := sFunc + Format(': Put(Local=%s, Remote=%s) NG(%s)',[sLocalFullName,sRemoteFile,sErrMsg]);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_NG, sDebug);
    Exit;
  end;
	sDebug := sFunc + Format(': Put(Local=%s, Remote=%s)',[sLocalFullName, sRemoteFile]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Discon
	if bEndDisc then begin
  	FFTPClient.Disconnect;
    sDebug := sFunc + ': FTP Disconnect';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
	end;
	//
	Result := WAIT_OBJECT_0;
end;

function TCommPG.DP860_FileGetPG2PC(sRemotePath, sRemoteFile: string; sLocalFullName: string; bClearAfterGet: Boolean=False; bEndDisc: Boolean=True): DWORD;
var
  sFunc, sDebug, sErrMsg : string;
begin
	Result  := WAIT_FAILED;
  sFunc   := '<PG> FTP FileDownload';
  sDebug  := '';
  sErrMsg := '';

  sDebug := sFunc + ': Start';
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Create Class
  if FFTPClient = nil then begin
  	FFTPClient := TFTPClient.Create(PG_IPADDR, DefPG.DP860_FTP_USERNAME, DefPG.DP860_FTP_PASSWORD);
	end;
	// Connect
	if not FFTPClient.FFTP.Connected then begin
    sErrMsg := FFTPClient.Connect;
  	if sErrMsg <> '' then begin
    	sDebug := sFunc + ': FTP Connect NG(' + sErrMsg + ')';
      ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
      FFTPClient.Disconnect; // Added by KTS 2023-04-04 오전 10:06:03
      Exit;
    end;
	end;
  sDebug := sFunc + ': FTP Connect';
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Change Local Dir
	// Change Remote Dir
	// Get
	sErrMsg := FFTPClient.Get(sRemoteFile, sLocalFullName);
	if sErrMsg <> '' then begin
  	sDebug := sFunc + Format(': Get(Remote=%s, Local=%s) NG(%s)',[sRemoteFile,sLocalFullName,sErrMsg]);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
    Exit;
  end;
	sDebug := sFunc + Format(': Get(Remote=%s, Local=%s)',[sRemoteFile,sLocalFullName]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);

	// Delete File(s) if bClearAfterGet=True
  if bClearAfterGet then begin
  	FFTPClient.DeleteFile(sRemoteFile);
    if sErrMsg <> '' then begin
    	sDebug := sFunc + Format(': DeleteFile(Remote=%s) NG(%s)',[sRemoteFile,sErrMsg]);
      ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_NG, sDebug);
      Exit;
    end;
  	sDebug := sFunc + Format(': DeleteFile(Remote=%s)',[sRemoteFile]);
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
  end;

	// Discon
	if bEndDisc then begin
  	FFTPClient.Disconnect;
    sDebug := sFunc + ': FTP Disconnect';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
	end;
	//
	Result := WAIT_OBJECT_0;
end;
{$ENDIF} //FEATURE_FLASH_ACCESS

//==============================================================================
// PG_DP860 Command - ETC
//------------------------------------------------------------------------------
// procedure/function:
//		- procedure TCommPG.DP860_ClearOcTconRWCnt; //2023-03-28 jhhwang (for T/T Test)
//		- function TCommPG.DP860_SendOcOnOff(bStart: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
//    - function TCommPG.DP860_SendGpioRead(sGpio: string; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
procedure TCommPG.DP860_ClearOcTconRWCnt; //2023-03-28 jhhwang (for T/T Test)
begin
  with TconRWCnt do begin
    TconReadDllCall  := 0;
    TconWriteDllCall := 0;
    TconReadTX       := 0;
    TConWriteTX      := 0;
    TConOcWriteTX    := 0;
    //
    ContTConOcWrite  := 0;
  end;
end;

function TCommPG.DP860_FileGetPG2PC(sRemotePath, sRemoteFile, sLocalFullName: string; bClearAfterGet, bEndDisc: Boolean): DWORD;
begin

end;

function TCommPG.DP860_FilePutPC2PG(sLocalFullName, sRemotePath, sRemoteFile: string; bClearBeforePut, bEndDisc: Boolean): DWORD;
begin

end;

function TCommPG.DP860_SendOcOnOff(nState: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
	i : Integer;
begin
	nCmdId   := DefPG.PG_CMDID_OC_ONOFF;
	sCmdName := DefPG.PG_CMDSTR_OC_ONOFF;
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%d',[nState]); // 'oc.onoff <number>' number:1(start), 0(end)
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);

  if Result <> WAIT_OBJECT_0 then begin
    sEtcMsg :=  '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  end;
  //
  sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
  with TconRWCnt do begin
    if nState = 1 then DP860_ClearOcTconRWCnt; //OC DLL Start
    sDebug := sDebug + Format('[SW:DllRead(%d)DllWrite(%d),ReadTX(%d)Write(%d)OcWrite(%d)]',[TconReadDllCall,TconWriteDllCall,TconReadTX,TConWriteTX,TConOcWriteTX]);
  end;
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
end;

function TCommPG.DP860_SendGpioRead(sGpio: string; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD; //2023-03-28 jhhwang (for T/T Test)
var
	nCmdId : Integer;
	sCmdName, sCommand, sDebug, sEtcMsg : string;
  arCmdAck : TArray<string>;
begin
	nCmdId   := DefPG.PG_CMDID_GPIO_READ;
	sCmdName := DefPG.PG_CMDSTR_GPIO_READ;
	sEtcMsg  := '';
	//
	sCommand := sCmdName + ' ' + Format('%s',[sGpio]); // 'gpio.read HPD'
	Result := DP860_SendCmd(sCommand, nCmdId,sCmdName, nWaitMS,nRetry);
  //
  sEtcMsg  := '['+DP860_GetPgLogMsg(FTxRxPG.RxAckStr)+']';
  if Result = WAIT_OBJECT_0 then begin
    try
      if sGpio = 'HPD' then begin
        arCmdAck := FTxRxPG.RxAckStr.Split([#$0D]);
        if Trim(arCmdAck[0]) <> '1' then Result := WAIT_FAILED;
      end;
    except
      sEtcMsg :=  sEtcMsg + '(RxDataParsingError)';
      Result  := WAIT_FAILED;
    end;
  end;
  // if ((Common.SystemInfo.DebugLogLevelConfig > 0) and Common.SystemInfo.PG_TconWriteLogDisplay) or (Result <> 0) then begin
  if ((Common.SystemInfo.DebugLogLevelConfig > 0)  or (Result <> 0) )then begin
	  sDebug := '<PG> ' + sCommand + ' :' + DP860_GetStrCmdResult(Result) + sEtcMsg;
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
  end;
end;

//##############################################################################
{$ENDIF} //PG_DP860 ############################################################
//##############################################################################


//##############################################################################
//##############################################################################
//###                                                                        ###
//###                             FLOW-SPECIFIC                              ###
//###                                                                        ###
//##############################################################################
//##############################################################################

//==============================================================================
// FLOW-SPECIFIC (Power On/Off)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.SendPowerOn({nMode: Integer;} nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
//		- function TCommPG.SendPowerOff(nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
//
function TCommPG.SendPowerOn(nMode: Integer; bPowerReset: Boolean=False; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
var
  sDebug : string;
const
  DELAY_POWER_INTERPOSER_OFF = 10;  //TBD:DP860?
  DELAY_POWER_INTERPOSER_ON  = 10;  //TBD:DP860?
begin
  Result := WAIT_FAILED;
  //
  case nMode of
    DefPG.CMD_POWER_OFF : begin

      // Interlock during Flash R/W
      if FIsOnFlashAccess then begin // Interlock during Flash Access
        Result := WAIT_FAILED;
        sDebug := 'Power Off NG (On Flash Access) ...Try again after flash access is done'; //TBD:2023-02?
        ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
        Exit;
      end;
      // DP860 PowerOff : power.off -> interposer.deinit
      Result := DP860_SendPowerOff({nMode}nWaitMS,nRetry);
      if (not bPowerReset) then begin
        Sleep(DELAY_POWER_INTERPOSER_OFF);
        Result := DP860_SendInterposerOff({nMode}nWaitMS,nRetry);
      end;

      //
    	if Result = WAIT_OBJECT_0 then begin
        m_bPowerOn := False;
        {$IFDEF FEATURE_GRAY_CHANGE}
        with m_CurPatDispInfo do begin
    			bPowerOn      := False; //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
          bPatternOn    := False;
          nCurPatNum    := 0;
          nCurAllPatIdx := 0;
          bSimplePat    := False;
          bGrayChangeR  := False;
          bGrayChangeG  := False;
          bGrayChangeB  := False;
          nGrayOffset   := 0;
        end;
        {$ENDIF}
    	end;
    end;
    DefPG.CMD_POWER_ON: begin

      // DP860 PowerOn : interposer.init -> (dut.detect) -> power.on -> (tcon.info)
      // DP860 (PowerReset)PowerOn : power.on
      if (not bPowerReset) then begin
        Result := DP860_SendInterposerOn(nWaitMS,nRetry);
        if Result = WAIT_OBJECT_0 then begin
          Sleep(DELAY_POWER_INTERPOSER_ON);
            Result := DP860_SendDutDetect(1000{nWaitMS},1{Retry});
          //TBD? if Result = WAIT_OBJECT_0 then begin
            Result := DP860_SendPowerOn(nWaitMS,nRetry);
          //TBD? end;
          //TBD? if Result = WAIT_OBJECT_0 then begin
            DP860_SendTconInfo(1000{nWaitMS},0{Retry});
          //TBD? end;
        end;
      end
      else begin
        Result := DP860_SendPowerOn(nWaitMS,nRetry);
      end;

    	if Result = WAIT_OBJECT_0 then begin
       	m_bPowerOn := True;      //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
       	{$IFDEF FEATURE_GRAY_CHANGE}
   	   	with m_CurPatDispInfo do begin
         	bPowerOn     := True;  //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
       	//bPatternOn   := False;
       	//nCurrPatNum  := 0;
       	//nCurrAllPatIdx := 0;
       	//bSimplePat   := False;
       	//bGrayChangeR := False;
       	//bGrayChangeG := False;
       	//bGrayChangeB := False;
       	//nGrayOffset  := 0;
       	end;
     		{$ENDIF}
     	end;
    end;
  end;
end;

function TCommPG.SendPowerBistOn(nMode: Integer; bPowerReset: Boolean=False; nWaitMS: Integer=10000; nRetry: Integer=0): DWORD;
var
  sDebug : string;
const
  DELAY_POWER_INTERPOSER_OFF = 10;  //TBD:DP860?
  DELAY_POWER_INTERPOSER_ON  = 10;  //TBD:DP860?
begin
  Result := WAIT_FAILED;
  //
  case nMode of
    DefPG.CMD_POWER_OFF : begin
      // Interlock during Flash R/W
      if FIsOnFlashAccess then begin // Interlock during Flash Access
        Result := WAIT_FAILED;
        sDebug := 'Power Off NG (On Flash Access) ...Try again after flash access is done'; //TBD:2023-02?
        ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
        Exit;
      end;
      // DP860 PowerOff : power.off -> interposer.deinit
      Result := DP860_SendPowerBistOff({nMode}nWaitMS,nRetry);
      if (not bPowerReset) then begin
        Sleep(DELAY_POWER_INTERPOSER_OFF);
        Result := DP860_SendInterposerOff({nMode}nWaitMS,nRetry);
      end;
      //
    	if Result = WAIT_OBJECT_0 then begin
        m_bPowerOn := False;
        {$IFDEF FEATURE_GRAY_CHANGE}
        with m_CurPatDispInfo do begin
    			bPowerOn      := False; //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
          bPatternOn    := False;
          nCurPatNum    := 0;
          nCurAllPatIdx := 0;
          bSimplePat    := False;
          bGrayChangeR  := False;
          bGrayChangeG  := False;
          bGrayChangeB  := False;
          nGrayOffset   := 0;
        end;
        {$ENDIF}
    	end;
    end;
    DefPG.CMD_POWER_ON: begin
      // DP860 PowerOn : interposer.init -> (dut.detect) -> power.on -> (tcon.info)
      // DP860 (PowerReset)PowerOn : power.on
      if (not bPowerReset) then begin
        Result := DP860_SendInterposerOn(nWaitMS,nRetry);
        if Result <> WAIT_OBJECT_0 then begin
          Result := DP860_SendInterposerOff({nMode}nWaitMS,nRetry);
          Sleep(100);
          Result := DP860_SendInterposerOn(nWaitMS,nRetry);
        end;
        if Result = WAIT_OBJECT_0 then begin
          Sleep(DELAY_POWER_INTERPOSER_ON);
          Result := DP860_SendDutDetect(1000{nWaitMS},1{Retry});
          if Result = WAIT_OBJECT_0 then begin
            Result := DP860_SendPowerBistOn(nWaitMS,nRetry);
          end;
          if Result = WAIT_OBJECT_0 then begin
            DP860_SendTconInfo(1000{nWaitMS},0{Retry});
          end;
        end;
      end
      else begin
        Result := DP860_SendPowerBistOn(nWaitMS,nRetry);
      end;

    	if Result = WAIT_OBJECT_0 then begin
       	m_bPowerOn := True;      //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
       	{$IFDEF FEATURE_GRAY_CHANGE}
   	   	with m_CurPatDispInfo do begin
         	bPowerOn     := True;  //TBD? m_bPowerOn? m_CurPatDispInfo.bPowerOn?
       	//bPatternOn   := False;
       	//nCurrPatNum  := 0;
       	//nCurrAllPatIdx := 0;
       	//bSimplePat   := False;
       	//bGrayChangeR := False;
       	//bGrayChangeG := False;
       	//bGrayChangeB := False;
       	//nGrayOffset  := 0;
       	end;
     		{$ENDIF}
     	end;
    end;
  end;
end;

//==============================================================================
// FLOW-SPECIFIC (Power Measurement)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD;
//
function TCommPG.SendPowerMeasure(bCyclicMeasure: Boolean=False): DWORD;
begin
	Result := WAIT_FAILED;
	//
  if m_bPwrMeasure then tmPwrMeasure.Enabled := False;
  //
  Result := DP860_SendPowerMeasure(bCyclicMeasure);
  if Result = WAIT_OBJECT_0 then begin
    DP860_ReadPowerMeasureAck(FTxRxPG.RxAckStr);
  end;
  //
  if m_bPwrMeasure then tmPwrMeasure.Enabled := True;
end;

//==============================================================================
// FLOW-SPECIFIC (Pattern)
//------------------------------------------------------------------------------
// procedure/function:
//		- function TCommPG.SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendSetColorRGB
//		- function TCommPG.SendDisplayPatPwmNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendDisplayPwmPat
//		- function TCommPG.SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD; //#SendDisplayPat		
//
function TCommPG.SendDisplayPatRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendSetColorRGB
begin
  Result := WAIT_FAILED;
	//
	if (nR < 0) then nR := 0; if (nR > 255) then nR := 255;
	if (nG < 0) then nG := 0; if (nG > 255) then nG := 255;
	if (nB < 0) then nB := 0; if (nB > 255) then nB := 255;

  Result := DP860_SendDisplayPatRGB(nR,nG,nB, nWaitMS,nRetry);
end;


function TCommPG.SendDisplayPatBistRGB(nR,nG,nB: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendSetColorRGB
begin
  Result := WAIT_FAILED;
	//
	if (nR < 0) then nR := 0; if (nR > 255) then nR := 255;
	if (nG < 0) then nG := 0; if (nG > 255) then nG := 255;
	if (nB < 0) then nB := 0; if (nB > 255) then nB := 255;
	//

	Result := DP860_SendDisplayPatbistRGB(nR,nG,nB, nWaitMS,nRetry);
end;

function TCommPG.SendDisplayPatBistRGB_9Bit(nR, nG, nB, nWaitMS, nRetry: Integer): DWORD;
begin
  Result := WAIT_FAILED;
	//
	if (nR < 0) then nR := 0; if (nR > 511) then nR := 511;
	if (nG < 0) then nG := 0; if (nG > 511) then nG := 511;
	if (nB < 0) then nB := 0; if (nB > 511) then nB := 511;

  Result := DP860_SendDisplayPatBistRGB_9Bit(nR,nG,nB, nWaitMS,nRetry);
end;

function TCommPG.SendDisplayPatPwmNum(nPatNum: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //#SendDisplayPwmPat
var
{$IF Defined(INSPECTOR_FI) or Defined(INSEPCTOR_OQA)}
  nDim : Integer;
  arrData : TIdBytes;
{$ENDIF}
  bOK  : Boolean;
begin
{$IF Defined(INSPECTOR_FI) or Defined(INSEPCTOR_OQA)}
  //
  {$IFDEF FEATURE_PATDIM_DBV}
  nDim := FCurPatGrpInfo.DimDBV[nPatNum];
  {$ELSE}
  nDim := FCurPatGrpInfo.Dimming[nPatNum];
  {$ENDIF}
  if (Common.TestModelInfoFLOW.UsePwmPatDisp)
    {$IFDEF FEATURE_PATDIM_DBV}
    and ((nDim >= 0) and (nDim <= FCurPatGrpInfo.DimDbvMax))
    {$ELSE}
    and ((nDim >= 0) and (nDim <= 100))
    {$ENDIF}
  then begin
    Result := SendDimming(nDim, nWaitMS,nRetry);
  end;
  //
  {$IFDEF FEATURE_POCB_ONOFF}
  if (Common.TestModelInfoFLOW.PocbOnOffUse) then begin
    if Common.TestModelInfoFLOW.PocbOnOffI2cRa <> 0 then begin
      Result := SendPocbOnOff(TernaryOp((FCurPatGrpInfo.PucOnOff[nPatNum]=0),False,True), nWaitMS,nRetry);
    end;
  end;
  {$ENDIF}
{$ENDIF}
  //
  Result := SendDisplayPatNum(nPatNum, nWaitMS,nRetry);
end;

function TCommPG.SendDisplayPatNext(nWaitMS : Integer=3000; nRetry: Integer=0): DWORD;


begin
  Result := WAIT_FAILED;

	Result := SendDisplayPatNext( nWaitMS,nRetry);
end;

function TCommPG.SendDisplayPatNum(nPatNum: Integer; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD; //#SendDisplayPat //#SendPatDisplayReq
var
  sFunc, sDebug : String;
  sPatName : AnsiString;
  nPatIdx  : Integer;
	i, nDataCnt : Integer;
  nToolCnt, nToolType, nDirection, nLevel : Integer;
  nSX,nSY, nEX,nEY, nMX,nMY, nR,nG,nB : Integer;
  nBmpDownNum : Integer;
  BmpAddInfo : TBmpAddInfo;
begin
  Result := WAIT_FAILED;

  {$IFDEF INSPECTOR_POCB}
  ShowTestWindow(DefCommon.MSG_MODE_DISPLAY_PATTERN,nPatNum,'');
  {$ENDIF}

  try
    sPatName := FCurPatGrpInfo.PatName[nPatNum];
    for nPatIdx := 0 to Pred(MAX_PATTERN_CNT) do begin
      if Trim(FDisPatStruct.PatInfo[nPatIdx].pat.Data.PatName) = sPatName then Break;
    end;
    sFunc := Format('Display Pattern(%d:%s]: ',[nPatNum,sPatName]); //TBD:DP860?

    //
 		case FCurPatGrpInfo.PatType[nPatNum] of
   		PTYPE_NORMAL : begin
     		nToolCnt := FDisPatStruct.PatInfo[nPatIdx].pat.Data.ToolCnt;
   		//sDebug := sFunc + Format(' PatNum(%d) PatName(%s) ToolCnt(%d)',[nPatNum,sPatName,nToolCnt]);
   		//ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_INFO, sDebug);
     		for i := 0 to (nToolCnt-1) do begin
       		with FDisPatStruct.PatInfo[nPatIdx].Tool[i].Data do begin
         		{$IFDEF INSPECTOR_POCB}
         		nSX := Common.GetDrawPosPG(m_nCh,sx); nSY := Common.GetDrawPosPG(m_nCh,sy);
         		nEX := Common.GetDrawPosPG(m_nCh,ex); nEY := Common.GetDrawPosPG(m_nCh,ey);
         		nMX := Common.GetDrawPosPG(m_nCh,mx); nMY := Common.GetDrawPosPG(m_nCh,my);
         		{$ELSE}
         		nSX := Common.GetDrawPosPG(sx);       nSY := Common.GetDrawPosPG(sy);
         		nEX := Common.GetDrawPosPG(ex);       nEY := Common.GetDrawPosPG(ey);
         		nMX := Common.GetDrawPosPG(mx);       nMY := Common.GetDrawPosPG(my);
         		{$ENDIF}
         		// (0~4095) -> (0~255)
         		if R <= 0 then nR := 0 else if R >= 4095 then nR := 255 else nR := (R shr 4);
         		if G <= 0 then nG := 0 else if G >= 4095 then nG := 255 else nG := (G shr 4);
         		if B <= 0 then nB := 0 else if B >= 4095 then nB := 255 else nB := (B shr 4);
         		// ToolType
         		// 		ALL_LINE        : 'LINE';
  					//    ALL_BOX         : 'BOX';
						//    ALL_FILL_BOX    : 'FILL_BOX';
	  				//    ALL_TRI         : 'TRI';
		  			//    ALL_FILL_TRI    : 'FILL_TRI';
						//    ALL_CIRCLE      : 'CIRCLE';
						//    ALL_FILL_CIRCLE : 'FILL_CIRCLE';
						//    ALL_H_GRAY      : 'HORIZONTAL_GRAY';
						//    ALL_V_GRAY      : 'VERTICAL_GRAY';
						//    ALL_C_GRAY      : 'COLOR_GRAY';
						//    ALL_BLK_COPY    : 'BLOCK_COPY';
						//    ALL_BLK_PASTE   : 'BLOCK_PASTE';
						//    ALL_LOOP        : 'LOOP';
						//    ALL_XYLOOP      : 'XYLOOP';
						//    ALL_H_GRAY2     : 'HORIZONTAL_GRAY2';
						//    ALL_V_GRAY2     : 'VERTICAL_GRAY2';
						//    ALL_C_GRAY2     : 'COLOR_GRAY2';
         		case ToolType of
           		ALL_H_GRAY, ALL_V_GRAY, ALL_C_GRAY,	ALL_H_GRAY2, ALL_V_GRAY2, ALL_C_GRAY2 : begin
           			//TBD:DP860?
           		end;
         		end;
       		//sDebug := Format('ToolIdx[%d] ToolType(%d) Direction(%d) Level(%d) SX(%d)/SY(%d) EX(%d)/EY(%d) MX(%d)/MY(%d) R(%d)/G(%d)/B(%d)',[i,ToolType,Direction,Level,nSX,nSY,nEX,nEY,nMX,nMY,nR,nG,nB]);
       		//ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_INFO, sDebug);
       		end;

       		Result := DP860_SendDisplayPatRGB(nR,nG,nB, nWaitMS,nRetry);
        end;
   		end; //PTYPE_NORMAL

   		PTYPE_BITMAP : begin
        nBmpDownNum := CurPatGrpInfo.BmpAddInfo[nPatNum].BmpDownNum;
        sFunc := Format('Display BMP(%d:%s]',[nPatNum,sPatName]);
        Result := DP860_SendDisplayPatBMP(sPatName, nWaitMS,nRetry);
	 		end; //PTYPE_BITMAP
  	end; //case

		{$IFDEF FEATURE_GRAY_CHANGE}
    m_CurPatDispInfo.nCurPatNum    := 0;
    m_CurPatDispInfo.nCurAllPatIdx := 0; //index of AllPat
    m_CurPatDispInfo.bSimplePat   := False;
    m_CurPatDispInfo.bGrayChangeR := False;
    m_CurPatDispInfo.bGrayChangeG := False;
    m_CurPatDispInfo.bGrayChangeB := False;
    m_CurPatDispInfo.nGrayOffset  := 0;
 		//
    m_CurPatDispInfo.bPatternOn     := True;
    m_CurPatDispInfo.nCurPatNum    := nPatNum;
    m_CurPatDispInfo.nCurAllPatIdx := nPatIdx;
    if (FCurPatGrpInfo.PatType[nPatNum] = PTYPE_NORMAL) and
       (FDisPatStruct.PatInfo[nPatIdx].pat.Data.ToolCnt = 1) and
       (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.ToolType = ALL_FILL_BOX) then begin
      m_CurPatDispInfo.bSimplePat := True;
      //
      if (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.R <> 0) then m_CurPatDispInfo.bGrayChangeR := True;
      if (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.G <> 0) then m_CurPatDispInfo.bGrayChangeG := True;
      if (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.B <> 0) then m_CurPatDispInfo.bGrayChangeB := True;
      //
      if (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.R = 0) and (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.G = 0) and
				 (FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data.B = 0) then begin  //black
        m_CurPatDispInfo.bGrayChangeR := True;
        m_CurPatDispInfo.bGrayChangeG := True;
        m_CurPatDispInfo.bGrayChangeB := True;
			end;
    end;
		{$ENDIF}
  except

  end;
end;

//==============================================================================
// FLOW-SPECIFIC (GrayChange|Dimming|...)
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.SendGrayChange(nGrayOffset: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;  //FEATURE_GRAY_CHANGE
//		- function TCommPG.SendDimming(nDimming: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
//
function TCommPG.SendGrayChange(nGrayOffset: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;  //FEATURE_GRAY_CHANGE
var
  nApiRtn, nTry : Integer;
  sFunc, sDebug : string;
  //
  nPatIdx : Integer;
  nR, nG, nB : Integer;
begin
  Result := WAIT_FAILED;
  sFunc  := Format('GrayChange(Offset=%d): ',[nGrayOffset]);
  //
  nPatIdx := m_CurPatDispInfo.nCurAllPatIdx;
  with FDisPatStruct.PatInfo[nPatIdx].Tool[0].Data do begin
    // (0~4095) -> (0~255)
   	if (R <= 0) then nR := 0 else if (R >= 4095) then nR := 255 else nR := (R shr 4); //TBD:DP860? (0~4095 -> 0~255)?
   	if (G <= 0) then nG := 0 else if (G >= 4095) then nG := 255 else nG := (G shr 4); //TBD:DP860? (0~4095 -> 0~255)?
   	if (B <= 0) then nB := 0 else if (B >= 4095) then nB := 255 else nB := (B shr 4); //TBD:DP860? (0~4095 -> 0~255)?
    // +/- GrayOffset
    nR := nR + nGrayOffset;
    nG := nG + nGrayOffset;
    nB := nB + nGrayOffset;
    //
   	if (nR <= 0) then nR := 0 else if (nR > 255) then nR := 255;
   	if (nG <= 0) then nG := 0 else if (nG > 255) then nG := 255;
   	if (nB <= 0) then nB := 0 else if (nB > 255) then nB := 255;

		Result := DP860_SendDisplayPatRGB(nR,nG,nB, nWaitMS,nRetry);
		//
    if Result <> WAIT_OBJECT_0 then begin
      sDebug := sFunc + ' Failed';
      ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
    end
    else begin
      {$IFDEF FEATURE_GRAY_CHANGE}
      m_CurPatDispInfo.nGrayOffset := nGrayOffset;
      {$ENDIF}
      sDebug := sFunc;
      ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_OK, sDebug);
    end
  end;
end;

function TCommPG.SendDimming(nDimming: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
  nApiRtn : Integer;
  nDimmingStep       : Integer;
  nDBV, nWriteValue  : Integer;
  btValue1, btValue2, btRead : Byte;
  sFunc, sDebug : string;
  nTry : Integer;
	//
	arDataW, arDataR : TIdBytes;
begin
  Result := WAIT_FAILED;


	sDebug := Format('SET DBV#(0x%0x=%d)',[nDimming,nDimming]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_INFO, sDebug);

  Result := DP860_SendAlpdpDBV(nDimming, nWaitMS,nRetry);
  if (Result <> WAIT_OBJECT_0) then begin
    sDebug := sFunc + '...NG';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
  end;
  //
  {$IFDEF FEATURE_DIMMING_STEP}
  if (Result = WAIT_OBJECT_0) then begin
    nDimmingStep := 0;
    if      nDimming = Common.TestModelInfoFLOW.DimmingStep1 then nDimmingStep := 1
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep2 then nDimmingStep := 2
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep3 then nDimmingStep := 3
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep4 then nDimmingStep := 4;
    m_CurPatDispInfo.nCurDimmingStep := nDimmingStep;
  end;
  {$ENDIF}
end;


function TCommPG.SendDimmingBist(nDimming: Integer; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD;
var
  nApiRtn : Integer;
  nDimmingStep       : Integer;
  nDBV, nWriteValue  : Integer;
  btValue1, btValue2, btRead : Byte;
  sFunc, sDebug : string;
  nTry : Integer;
	//
	arDataW, arDataR : TIdBytes;
begin
  Result := WAIT_FAILED;

	sDebug := Format('SET DBV#(0x%0x=%d)',[nDimming,nDimming]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_INFO, sDebug);


  Result := DP860_SendBistDBV(nDimming, nWaitMS,nRetry);

  if (Result <> WAIT_OBJECT_0) then begin
    sDebug := sFunc + '...NG';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
  end;
  //
  {$IFDEF FEATURE_DIMMING_STEP}
  if (Result = WAIT_OBJECT_0) then begin
    nDimmingStep := 0;
    if      nDimming = Common.TestModelInfoFLOW.DimmingStep1 then nDimmingStep := 1
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep2 then nDimmingStep := 2
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep3 then nDimmingStep := 3
    else if nDimming = Common.TestModelInfoFLOW.DimmingStep4 then nDimmingStep := 4;
    m_CurPatDispInfo.nCurDimmingStep := nDimmingStep;
  end;
  {$ENDIF}
end;

function TCommPG.SendPocbOnOff(bOn: Boolean; nWaitMS: Integer=3000; nRetry: Integer=0): DWORD; //FEATURE_POCB_ONOFF
var
  sDebug : string;
	arDataW : TIdBytes;
begin
  Result := WAIT_FAILED;

  {$IF Defined(INSPECTOR_FI) or Defined(INSEPCTOR_OQA)}
  sDebug := Format('POCB ON/OFF#(%s)',[TernaryOp(bOn,'ON','OFF')]);
  ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_INFO, sDebug);

  SetLength(arDataW, 1);
  with Common.TestModelInfoFLOW do begin
    arDataW[0] := TernaryOp(bOn, PocbOnOffI2cOnVal, PocbOnOffI2cOffVal);
    Result := SendI2CWrite(DefPG.TCON_I2C_DEVICE_ADDR_TEMPORARY, PocbOnOffI2cRa,1,arDataW);
    if Result = WAIT_OBJECT_0 then
      ShowTestWindow(DefCommon.MSG_MODE_TESTCH_UI, TernaryOp(bOn,1,0), '0');
  end;
  if (Result <> WAIT_OBJECT_0) then begin
    sDebug := sDebug + '...NG';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING, DefCommon.LOG_TYPE_NG, sDebug);
  end;
  {$ENDIF}
end;

//==============================================================================
// FLOW-SPECIFIC (I2C)
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.SendI2CRead(nDevAddr,nRegAddr,nDataCnt: Integer; var arRData: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
//		- function TCommPG.SendI2CWrite(nDevAddr,nRegAddr,nDataCnt: Integer; arWData: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
//
function TCommPG.SendI2CRead(nDevAddr,nRegAddr,nDataCnt: Integer; var arDataR: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
var
  sDebug  : string;
  i       : Integer;
//btData  : Byte;
  btaData : TIdBytes;
begin
  Result := WAIT_FAILED;
	if Length(arDataR) < nDataCnt then begin
		sDebug := Format('SendI2CRead NG(ReadDataCnt:%d < ReadDataBuf.Length:%d)',[nDataCnt,Length(arDataR)]);
  	ShowTestWindow(DefCommon.MSG_MODE_WORKING, TernaryOp((Result=WAIT_OBJECT_0),DefCommon.LOG_TYPE_OK,DefCommon.LOG_TYPE_NG), sDebug);
		Exit;
	end;

	//
 	SetLength(btaData, nDataCnt);
	Result := DP860_SendTConRead(nRegAddr,nDataCnt,btaData, nWaitMS,nRetry);
  //
  if Result = WAIT_OBJECT_0 then begin
    FTxRxPG.RxDataLen := nDataCnt;
   	for i := 0 to (nDataCnt-1) do begin
			arDataR[i] := btaData[i];
      FTxRxPG.RxData[i] := btaData[i]; //TBD?
   	end;
  end;
end;

function TCommPG.SendI2CWrite(nDevAddr,nRegAddr,nDataCnt: Integer; arDataW: TIdBytes; nWaitMS: Integer=2000; nRetry: Integer=0): DWORD;
var
  i : Integer;
  bWriteSync : Boolean; //2023-03-28 jhhwang (for T/T Test)
begin
  Result := WAIT_FAILED;
  //
	case PG_TYPE of
		{$IFDEF PG_DP860}
		DefPG.PG_TYPE_DP860 : begin //-------------- DP860
      {$IF Defined(INSPECTOR_OC) or Defined(INSPECTOR_PreOC)} //2023-03-28 jhhwang (for OC T/T)
      case Common.SystemInfo.PG_TconWriteCmdType of
        0 : begin // all tcon.ocwrite (no ack)
          if (Common.SystemInfo.PG_WaitAckAfterContOcWriteCnt = 0) or (TconRWCnt.ContTConOcWrite < Common.SystemInfo.PG_WaitAckAfterContOcWriteCnt) then begin
      			Result := DP860_SendTconOCWrite(nRegAddr,nDataCnt,arDataW, 0{nWaitMS},0);
            if Common.SystemInfo.PG_TconOcWriteDelayMsec > 0 then
              Sleep(Common.SystemInfo.PG_TconOcWriteDelayMsec)
            else if Common.SystemInfo.PG_TconOcWriteDelayMicroSec > 0 then
              WaitMicroSec(Common.SystemInfo.PG_TconOcWriteDelayMicroSec)
            else begin
              for i := 0 to Pred(Common.SystemInfo.PG_TconOcWriteDelayLoopCnt) do begin
                ; //NOP
              end;
            end;
          end
          else begin
            Result := DP860_SendTconWrite(nRegAddr,nDataCnt,arDataW, nWaitMS,nRetry);
          end;
        end;
        1 : begin // all tcon.ocwrite (ack)
    			Result := DP860_SendTconWrite(nRegAddr,nDataCnt,arDataW, nWaitMS,nRetry);
        end;
        2 : begin // default tcon.ocwrite + selective tcon.write only if SyncAddr
          bWriteSync := False;
          if (Common.SystemInfo.PG_WaitAckAfterContOcWriteCnt = 0) or (TconRWCnt.ContTConOcWrite < Common.SystemInfo.PG_WaitAckAfterContOcWriteCnt) then begin
            for i := 0 to Length(Common.SystemInfo.PG_ToonOcWriteSyncAddrArr)-1 do begin
              if Common.SystemInfo.PG_ToonOcWriteSyncAddrArr[i] = nRegAddr then begin
                bWriteSync := True;
                break;
              end;
            end;
          end
          else begin
            bWriteSync := True;
          end;
          //
          if bWriteSync then begin
            Result := DP860_SendTconWrite(nRegAddr,nDataCnt,arDataW, nWaitMS,nRetry);
          end
          else begin
      			Result := DP860_SendTconOCWrite(nRegAddr,nDataCnt,arDataW, 0{nWaitMS},0);
            Sleep(Common.SystemInfo.PG_TconOcWriteDelayMsec);
          end;
        end;
      end;
      {$ELSE}
			Result := DP860_SendTconWrite(nRegAddr,nDataCnt,arDataW, nWaitMS,nRetry);
      {$ENDIF}
		end;
		{$ENDIF}
	end;
end;




//==============================================================================
// FLOW-SPECIFIC (Flash)
//------------------------------------------------------------------------------
// procedure/function: 
//		- function TCommPG.SendFlashRead(nAddr,nSize: DWORD; pData: PByte; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD;
//		- function TCommPG.SendFlashWrite(nAddr,nSize: DWORD; const pData: PByte; nWaitMS: Integer=100000; nRetry: Integer=0): DWORD;
//		- function TCommPG.GetFlashDataBuf(nAddr,nLen: DWORD; pDataBuf: PByte): DWORD;
//		- function TCommPG.UpdateFlashDataBuf(nAddr,nLen: DWORD; pData: PByte): DWORD;
//
function TCommPG.SendFlashRead(nAddr,nSize: DWORD; pData: PByte; nWaitMS: Integer=5000; nRetry: Integer=0): DWORD;
var
  btApiRtn : Byte;
  nTry : Integer;
  sFunc, sDebug : string;
  sRemotePath, sRemoteFile, sLocalPath, sLocalFile, sLocalFullName : string;
  //
  mtData : TMemoryStream;
  rxData : array of Byte;
begin
  Result := WAIT_FAILED;
  sFunc  := Format('FlashRead(Addr=%d,Size=%d) ',[nAddr,nSize]);

  try
    FIsOnFlashAccess := True;
    //
    for nTry := 0 to nRetry do begin
      if nSize < 256 then begin
        Result := DP860_SendNvmRead(nAddr,nSize, pData, nWaitMS,nRetry);
      end
      else begin
        // Send flash.read2file
        sRemoteFile := Format('FlashR_A0x%x_L%d.bin',[nAddr,nSize]);
        Result := DP860_SendNvmReadFile(nAddr,nSize, sRemoteFile, nWaitMS,nRetry);
        if Result <> WAIT_OBJECT_0 then begin
          //TBD?
          break;
        end;
        // Get flash read data file from PG
        sRemotePath := '/home/upload';
        sLocalPath  := Common.Path.FLASH;
        sLocalFile  := Format('CH%d_',[m_nPG+1]) + sRemoteFile;
        sLocalFullName := Trim(sLocalPath + sLocalFile);
        Result := DP860_FileGetPG2PC(sRemotePath,sRemoteFile, sLocalFullName, False{bClearAfterGet}, True{nEndDisc} {,nWaitMS,nRetry});
        if Result <> WAIT_OBJECT_0 then begin
          //TBD?
          break;
        end;
        // Get Flash data from bin file
        mtData := TMemoryStream.Create;
        try
          mtData.LoadFromFile(sLocalFullName);
          if mtData.Size <> nSize then begin
            //TBD? RxDataSizeNG
          end;
          SetLength(rxData,nSize);
          mtData.Position := 0;
          mtData.Read(rxData[0],mtData.Size);
          CopyMemory(pData,@rxData[0],nSize);
        finally
          mtData.Free;
        end;
        break;
	  	end;
  	end;
  finally
    FIsOnFlashAccess := False;
  end;

	//
  if (Result <> WAIT_OBJECT_0) then begin
    sDebug := sFunc + '...NG';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_NG, sDebug);
    Exit;
  end;
end;

function TCommPG.SendFlashWrite(nAddr,nSize: DWORD; pData: PByte; nWaitMS: Integer=100000; nRetry: Integer=0): DWORD; //TBD:DP860?
var
  btApiRtn : Byte;
  i, nTry  : integer;
  CalcCRC, RxCRC : Word; //Word?
  pTemp : PByte;
  sFunc, sDebug : string;
  sRemotePath, sRemoteFile, sLocalPath, sLocalFile, sLocalFullName : string;
  bVerifyPG, bErasePG : Boolean;
  fs   : TFileStream;
  arData : array of Byte;

begin
  Result := WAIT_FAILED;

  // Calc SumCRC
  CalcCRC := 0;
  pTemp := pData;
  for i := 0 to Pred(nSize) do begin
    CalcCRC := Word((CalcCRC + pTemp^) and $FFFF);
    Inc(pTemp);
  end;
  sFunc := Format('SendFlashWrite(Addr=0x%x,Size=%d, Retry=%d)(CRC=0x%x:%d)',[nAddr,nSize,nRetry,CalcCRC,CalcCRC]);

  try
    FIsOnFlashAccess := True;
    //
    for nTry := 0 to nRetry do begin

      sRemotePath := '/home/upload';
      sRemoteFile := Format('FlashW_A0x%x_L%d.bin',[nAddr,nSize]);
      // Make flash data file
      sLocalPath  := Common.Path.FLASH; //TBD?
      sLocalFile  := Format('CH%d_',[m_nPG+1]) + sRemoteFile;
      sLocalFullName := sLocalPath + sLocalFile;
      //
      SetLength(arData, nSize);
      CopyMemory(@arData[0],pData,nSize);
      fs := TFileStream.Create(sLocalFullName, fmCreate);
      try
        fs.Write(arData[0], nSize);
      finally
        fs.Free;
        fs := nil;
      end;
      // FTP Put to PG
      Result := DP860_FilePutPC2PG(sLocalFullName, sRemotePath,sRemoteFile, True{bClearBeforePut}, True{nEndDisc} {,nWaitMS,nRetry});
      if Result <> WAIT_OBJECT_0 then begin
        //TBD?
        break;
      end;
      // Send flash.write2file
      bVerifyPG := True; //TBD:DP860?
      bErasePG  := True; //TBD:DP860?
      Result := DP860_SendNvmWriteFile(nAddr,nSize, sRemoteFile, bVerifyPG,bErasePG, nWaitMS,nRetry);
      if Result <> WAIT_OBJECT_0 then begin
        //TBD?
        break;
      end;
  	end;
  finally
    FIsOnFlashAccess := False;
  end;

  //
  if (Result <> WAIT_OBJECT_0) then begin
    sDebug := sFunc + '...NG';
    ShowTestWindow(DefCommon.MSG_MODE_WORKING,DefCommon.LOG_TYPE_NG, sDebug);
    Exit;
  end;
end;
end.
