unit dllClass;

interface
{$I Common.inc}

uses Winapi.Windows, System.Classes, System.SysUtils,  IdGlobal,Vcl.ExtCtrls,
   Messages, Vcl.Dialogs, CA_SDK2, DefCommon, DefPG, CommPG, CommonClass;

const
DEVICE_ADDRESS = 00;
   type
  TSample = record
    Name: WideString;
  end;
  PSample = ^TSample;

  PGuiDLL = ^RGuiDLL;
  RGuiDLL = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    nParam  : Integer;
    nParam2 : Integer;
    Msg     : string;
  end;


type
  //CA410
  TCallBackMeasure_XYL = function (channelCount : Integer; t5 : TArray<double>; nLen : Integer): Integer ;
  TCallBackSetSync     = function (CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
  TCallBackGetWaveformData = function (nChannel : Integer; waveform_T,waveformData : TArray<double>; nMeasureAmount : Integer ): Double;

  TCallBackTextChanged = procedure (channel_Index : Integer; bClear : Boolean;  sAddedText : PAnsiChar);
  TCallBackSample = procedure(a : Integer);

  TCallBackAllPowerOnOff     = function(nChannel,OnOff: Integer): Integer;

  TCallBackTCONSetReg       = function(nChannel,Addr : Integer; data : Byte): Integer;
  TCallBackTCONGetReg       = function(nChannel,Addr : Integer; data : Byte): Integer;
  TCallBackFlashWrite_File  = function(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  TCallBackFlashWrite_Data  = function(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  TCallBackFlashRead_File   = function(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  TCallBackFlashRead_Data   = function(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  TCallBackFlashErase       = function(nChannel,StartSeg,EndSeg : Integer): Integer;




  TCallBackAPSBoxPatternSet  = function(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
  TCallBackAPSPatternRGBSet  = function(nChannel,R, G, B: Integer): Integer;
  TCallBackAPSSetReg         = function(nChannel,Addr: Integer; Data: Integer): Integer;
  TCallBackLGDSetReg         = function(nChannel : Integer; Addr: DWORD; data: Byte): Integer;

  TCallBackPatternRGBSet     = function(nChannel,R, G, B: Integer): Integer;
  TCallBackSendHexFileCRC    = function(nChannel : Integer; CRC: Word): Integer;
  TCallBackStart_Connection  = function(nChannel : Integer): Integer;
  TCallBackStop_Connection   = function(nChannel : Integer): Integer;
  TCallBackWriteBMPFile      = function(nChannel : Integer;const pbyteBuffer: PByte; len: Integer): Integer;
  TCallBackConnection_Status = function(nChannel : Integer): Integer;
  TCallBackFreeAF9API        = function(nChannel : Integer): Boolean;
  TCallBackSendHexFile       = function(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  TCallBackDAC_SET           = Function(nChannel,nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
  TCallBackExtendIO_Set      = Function(nChannel,Address: Integer; Channel: Integer; Enable: Integer): Boolean;
  TCallBackFlashRead         = function(nChannel : Integer;const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
  TCallBackSW_Revision       = function(nChannel : Integer): Integer;
  TCallBackSendHexFileOC     = Function(nChannel : Integer; pbyteBuffer: PByte; len: Integer): Integer;
  TCallBackSetFreqChange     = Function(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;


type
  PProdutInfo = ^productInfo2;
  productInfo = packed record
    mes : Integer;
    PID   : PByte;
    CBID  : PByte;
    IsOk  : Integer;
    Value : Double;
  end;
  productInfo2 = packed record
    mes : Integer;
    PID   : PAnsiChar;
    CBID  : PAnsiChar;
    IsOk  : Integer;
    Value : Double;
  end;
  TMenuDataStruct = packed record
    exename : string[150];
    caption : string[25];
    userid : string[20];
    password : string[20];
    sparam : string[255];
    workdir : string[100];
    IconSize : Integer;
    IconPos : Integer;
    NextDataPos : Integer;
  end;

  TCSharpDll = class(TObject)

    m_MainHandle : HWND;
    m_TestHandle : HWND;
    tmrCycle : TTimer;
    // for DLL.
    m_Initialize : function (channelCount : Integer) : Integer ; cdecl;
    m_FormDestroy : procedure ; cdecl;


//    m_SetCallback  : procedure ( t8 : CallBackSample); cdecl;
    m_MainOC_VerifyStart : function(nCH : Integer): Integer; cdecl;
    m_MainOC_ThreadStateCheck : function(nCH : Integer): Integer; cdecl;

    m_SetCallback_measure_XYL : procedure (nChannel : Integer; CaallbackFunction : TCallBackMeasure_XYL); cdecl;
    m_SetCallback_SetSync : procedure (nChannel : Integer; CaallbackFunction : TCallBackSetSync);cdecl;
    m_SetCallback_GetWaveformData : procedure (nChannel : Integer; CaallbackFunction : TCallBackGetWaveformData);cdecl;

    m_SetCallback_TextChanged : procedure (nChannel : integer; CaallbackFunction : TCallBackTextChanged);cdecl;


    m_SetCallBackAllPowerOnOff      : procedure (nChannel : Integer; CaallbackFunction : TCallBackAllPowerOnOff      );cdecl;

    m_SetCallBackTCONSetReg         : procedure (nChannel : Integer; CaallbackFunction : TCallBackTCONSetReg         );cdecl;
    m_SetCallBackTCONGetReg         : procedure (nChannel : Integer; CaallbackFunction : TCallBackTCONGetReg         );cdecl;
    m_SetCallBackFlashWrite_File    : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashWrite_File    );cdecl;
    m_SetCallBackFlashWrite_Data    : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashWrite_Data    );cdecl;
    m_SetCallBackFlashRead_File     : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashRead_File     );cdecl;
    m_SetCallBackFlashRead_Data     : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashRead_Data     );cdecl;
    m_SetCallBackFlashErase         : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashErase         );cdecl;

    m_SetCallBackAPSBoxPatternSet   : procedure (nChannel : Integer; CaallbackFunction : TCallBackAPSBoxPatternSet   )      ;cdecl;
    m_SetCallBackAPSPatternRGBSet   : procedure (nChannel : Integer; CaallbackFunction : TCallBackAPSPatternRGBSet   )      ;cdecl;
    m_SetCallBackAPSSetReg          : procedure (nChannel : Integer; CaallbackFunction : TCallBackAPSSetReg          )      ;cdecl;
    m_SetCallBackLGDSetReg          : procedure (nChannel : Integer; CaallbackFunction : TCallBackLGDSetReg          )      ;cdecl;
//    m_SetCallBackLGDSetRegM         : procedure (nChannel : Integer; CaallbackFunction : TCallBackLGDSetRegM         )      ;cdecl;
    m_SetCallBackPatternRGBSet      : procedure (nChannel : Integer; CaallbackFunction : TCallBackPatternRGBSet      )      ;cdecl;
    m_SetCallBackSendHexFileCRC     : procedure (nChannel : Integer; CaallbackFunction : TCallBackSendHexFileCRC     )      ;cdecl;
    m_SetCallBackStart_Connection   : procedure (nChannel : Integer; CaallbackFunction : TCallBackStart_Connection   )      ;cdecl;
    m_SetCallBackStop_Connection    : procedure (nChannel : Integer; CaallbackFunction : TCallBackStop_Connection    )      ;cdecl;
    m_SetCallBackWriteBMPFile       : procedure (nChannel : Integer; CaallbackFunction : TCallBackWriteBMPFile       )      ;cdecl;
    m_SetCallBackConnection_Status  : procedure (nChannel : Integer; CaallbackFunction : TCallBackConnection_Status  )      ;cdecl;
    m_SetCallBackFreeAF9API         : procedure (nChannel : Integer; CaallbackFunction : TCallBackFreeAF9API         )      ;cdecl;
    m_SetCallBackSendHexFile        : procedure (nChannel : Integer; CaallbackFunction : TCallBackSendHexFile        )      ;cdecl;
    m_SetCallBackDAC_SET            : procedure (nChannel : Integer; CaallbackFunction : TCallBackDAC_SET            )      ;cdecl;
    m_SetCallBackExtendIO_Set       : procedure (nChannel : Integer; CaallbackFunction : TCallBackExtendIO_Set       )      ;cdecl;
    m_SetCallBackFlashRead          : procedure (nChannel : Integer; CaallbackFunction : TCallBackFlashRead          )      ;cdecl;
    m_SetCallBackSW_Revision        : procedure (nChannel : Integer; CaallbackFunction : TCallBackSW_Revision        )      ;cdecl;
    m_SetCallBackSendHexFileOC      : procedure (nChannel : Integer; CaallbackFunction : TCallBackSendHexFileOC      )      ;cdecl;
    m_SetCallBackSetFreqChange      : procedure (nChannel : Integer; CaallbackFunction : TCallBackSetFreqChange      )      ;cdecl;

  private
    m_hDll  : HWND;
    m_hMain : HWND;
    FNgMsg: string;
    m_MainOC_START : function(nCH : Integer): Integer; cdecl;
    m_MainOC_STOP : function(nCH : Integer): Integer; cdecl;


    CB_PowerOnOff           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackAllPowerOnOff;

    CB_TCONSetReg           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackTCONSetReg;
    CB_TCONGetReg           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackTCONGetReg;
    CB_FlashWrite_File      : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashWrite_File;
    CB_FlashWrite_Data      : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashWrite_Data;
    CB_FlashRead_File       : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashRead_File;
    CB_FlashRead_Data       : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashRead_Data;
    CB_FlashErase           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashErase;




    CB_APSBoxPatternSet     : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackAPSBoxPatternSet;
    CB_APSPatternRGBSet     : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackAPSPatternRGBSet;
    CB_APSSetReg            : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackAPSSetReg;
    CB_LGDSetReg            : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackLGDSetReg;
//    CB_LGDSetRegM           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackLGDSetRegM;
    CB_PatternRGBSet        : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackPatternRGBSet;
    CB_SendHexFileCRC       : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSendHexFileCRC;
    CB_Start_Connection     : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackStart_Connection;
    CB_Stop_Connection      : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackStop_Connection;
    CB_WriteBMPFile         : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackWriteBMPFile;
    CB_Connection_Status    : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackConnection_Status;
    CB_FreeAF9API           : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFreeAF9API;
    CB_SendHexFile          : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSendHexFile;
    CB_DAC_SET              : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackDAC_SET;
    CB_ExtendIO_Set         : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackExtendIO_Set;
    CB_FlashRead            : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackFlashRead;
    CB_SW_Revision          : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSW_Revision;
    CB_SendHexFileOC        : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSendHexFileOC;
    CB_SetFreqChange        : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSetFreqChange;
    CB_Measure_XYL          : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackMeasure_XYL;
    CB_SetSync              : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackSetSync;
    CB_GetWaveformData      : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackGetWaveformData;
    CB_TextChanged          : array [DefCommon.CH1 .. DefCommon.MAX_CH] of  TCallBackTextChanged;
    CB_TextChangedTEST      : TArray<TCallBackTextChanged>;
    procedure tmrCycleTimer(Sender : TObject);
    procedure CreateCallBackFunction;
    procedure Setfunction;
    procedure SetNgMsg(const Value: string);
    procedure ThreadTask(Task: TProc);
    procedure SetOnRevSwData(nCH : Integer; const Value: TCallBackTextChanged);
    procedure SendTestGuiDisplay(nCh,nGuiMode: Integer; sMsg: string; nParam: Integer);
  public
    m_bIsDLLWork : Boolean; // Added by KTS 2022-12-27 ���� 9:00:40 ���� DLL �۾��� Ȯ����
    constructor Create(hMain,hTest: HWND;sDLLPath, sFileName: string);
    destructor Destroy; override;
    procedure MLOG(nChannel_Index : Integer;bClear : Boolean; sMLOG : string);

    procedure Initialize;
    procedure FormDestroy;
    function MainOC_Start(nCH : Integer): Integer;
    function MainOC_Stop(nCH : Integer): integer;
    function MainOC_Verify_Start(nCH : Integer): integer;
    function MainOC_ThreadStateCheck(nCH : Integer): integer;


//    property OnRevSwData : TArray<TCallBackTextChanged> write CB_TextChangedTEST;
//    property OnRevData : TCallBackTextChanged write SetOnRevSwData ;
    property NgMsg : string read FNgMsg write SetNgMsg;

  end;


  procedure MyCB_TextChanged_1(channel_Index : Integer; bClear : Boolean;  sAddedText : PAnsiChar);cdecl;
  procedure MyCB_TextChanged_2(channel_Index : Integer; bClear : Boolean;  sAddedText : PAnsiChar);cdecl;
  procedure MyCB_TextChanged_3(channel_Index : Integer; bClear : Boolean;  sAddedText : PAnsiChar);cdecl;
  procedure MyCB_TextChanged_4(channel_Index : Integer; bClear : Boolean;  sAddedText : PAnsiChar);cdecl;


  function MyCB_AllPowerOnOff_1(nChannel,OnOff: Integer): Integer;
  function MyCB_AllPowerOnOff_2(nChannel,OnOff: Integer): Integer;
  function MyCB_AllPowerOnOff_3(nChannel,OnOff: Integer): Integer;
  function MyCB_AllPowerOnOff_4(nChannel,OnOff: Integer): Integer;

  function MyCB_TCONSetReg_1(nChannel,Addr : Integer; data : Byte): Integer;
  function MyCB_TCONSetReg_2(nChannel,Addr : Integer; data : Byte): Integer;
  function MyCB_TCONSetReg_3(nChannel,Addr : Integer; data : Byte): Integer;
  function MyCB_TCONSetReg_4(nChannel,Addr : Integer; data : Byte): Integer;

  function MyCB_TCONGetReg_1(nChannel,Addr : Integer; var data : Byte): Integer;
  function MyCB_TCONGetReg_2(nChannel,Addr : Integer; var data : Byte): Integer;
  function MyCB_TCONGetReg_3(nChannel,Addr : Integer; var data : Byte): Integer;
  function MyCB_TCONGetReg_4(nChannel,Addr : Integer; var data : Byte): Integer;

  function MyCB_FlashWrite_File_1(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashWrite_File_2(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashWrite_File_3(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashWrite_File_4(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;

  function MyCB_FlashWrite_Data_1(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashWrite_Data_2(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashWrite_Data_3(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashWrite_Data_4(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;

  function MyCB_FlashRead_File_1(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashRead_File_2(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashRead_File_3(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
  function MyCB_FlashRead_File_4(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;

  function MyCB_FlashRead_Data_1(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashRead_Data_2(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashRead_Data_3(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
  function MyCB_FlashRead_Data_4(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;


  function MyCB_FlashErase_1(nChannel,StartSeg,EndSeg : Integer): Integer;
  function MyCB_FlashErase_2(nChannel,StartSeg,EndSeg : Integer): Integer;
  function MyCB_FlashErase_3(nChannel,StartSeg,EndSeg : Integer): Integer;
  function MyCB_FlashErase_4(nChannel,StartSeg,EndSeg : Integer): Integer;



  function MyCB_APSBoxPatternSet_1(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
  function MyCB_APSBoxPatternSet_2(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
  function MyCB_APSBoxPatternSet_3(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
  function MyCB_APSBoxPatternSet_4(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;

  function MyCB_APSPatternRGBSet_1(nChannel,R, G, B: Integer): Integer;
  function MyCB_APSPatternRGBSet_2(nChannel,R, G, B: Integer): Integer;
  function MyCB_APSPatternRGBSet_3(nChannel,R, G, B: Integer): Integer;
  function MyCB_APSPatternRGBSet_4(nChannel,R, G, B: Integer): Integer;

  function MyCB_APSSetReg_1(nChannel,Addr: Integer; Data: Integer): Integer;
  function MyCB_APSSetReg_2(nChannel,Addr: Integer; Data: Integer): Integer;
  function MyCB_APSSetReg_3(nChannel,Addr: Integer; Data: Integer): Integer;
  function MyCB_APSSetReg_4(nChannel,Addr: Integer; Data: Integer): Integer;

  function MyCB_LGDSetReg_1(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
  function MyCB_LGDSetReg_2(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
  function MyCB_LGDSetReg_3(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
  function MyCB_LGDSetReg_4(nChannel : Integer; Addr: DWORD; data: Byte): Integer;

  function MyCB_PatternRGBSet_1(nChannel,R, G, B: Integer): Integer;
  function MyCB_PatternRGBSet_2(nChannel,R, G, B: Integer): Integer;
  function MyCB_PatternRGBSet_3(nChannel,R, G, B: Integer): Integer;
  function MyCB_PatternRGBSet_4(nChannel,R, G, B: Integer): Integer;

  function MyCB_SendHexFileCRC_1(nChannel : Integer; CRC: Word): Integer;
  function MyCB_SendHexFileCRC_2(nChannel : Integer; CRC: Word): Integer;
  function MyCB_SendHexFileCRC_3(nChannel : Integer; CRC: Word): Integer;
  function MyCB_SendHexFileCRC_4(nChannel : Integer; CRC: Word): Integer;

  function MyCB_Start_Connection_1(nChannel : Integer): Integer;
  function MyCB_Start_Connection_2(nChannel : Integer): Integer;
  function MyCB_Start_Connection_3(nChannel : Integer): Integer;
  function MyCB_Start_Connection_4(nChannel : Integer): Integer;

  function MyCB_Stop_Connection_1(nChannel : Integer): Integer;
  function MyCB_Stop_Connection_2(nChannel : Integer): Integer;
  function MyCB_Stop_Connection_3(nChannel : Integer): Integer;
  function MyCB_Stop_Connection_4(nChannel : Integer): Integer;

  function MyCB_WriteBMPFile_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_WriteBMPFile_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_WriteBMPFile_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_WriteBMPFile_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;

  function MyCB_Connection_Status_1(nChannel : Integer): Integer;
  function MyCB_Connection_Status_2(nChannel : Integer): Integer;
  function MyCB_Connection_Status_3(nChannel : Integer): Integer;
  function MyCB_Connection_Status_4(nChannel : Integer): Integer;

  function MyCB_FreeAF9API_1(nChannel : Integer): Boolean;
  function MyCB_FreeAF9API_2(nChannel : Integer): Boolean;
  function MyCB_FreeAF9API_3(nChannel : Integer): Boolean;
  function MyCB_FreeAF9API_4(nChannel : Integer): Boolean;

  function MyCB_SendHexFile_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_SendHexFile_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_SendHexFile_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
  function MyCB_SendHexFile_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;

  Function MyCB_DAC_SET_1(nChannel,nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
  Function MyCB_DAC_SET_2(nChannel,nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
  Function MyCB_DAC_SET_3(nChannel,nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
  Function MyCB_DAC_SET_4(nChannel,nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;

  Function MyCB_ExtendIO_Set_1(nChannel,Address: Integer; Channel: Integer; Enable: Integer): Boolean;
  Function MyCB_ExtendIO_Set_2(nChannel,Address: Integer; Channel: Integer; Enable: Integer): Boolean;
  Function MyCB_ExtendIO_Set_3(nChannel,Address: Integer; Channel: Integer; Enable: Integer): Boolean;
  Function MyCB_ExtendIO_Set_4(nChannel,Address: Integer; Channel: Integer; Enable: Integer): Boolean;

  function MyCB_FlashRead_1(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
  function MyCB_FlashRead_2(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
  function MyCB_FlashRead_3(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
  function MyCB_FlashRead_4(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;

  function MyCB_SW_Revision_1(nChannel : Integer): Integer;
  function MyCB_SW_Revision_2(nChannel : Integer): Integer;
  function MyCB_SW_Revision_3(nChannel : Integer): Integer;
  function MyCB_SW_Revision_4(nChannel : Integer): Integer;

  Function MyCB_SendHexFileOC_1(nChannel : Integer; pbyteBuffer: PByte; len: Integer): Integer;
  Function MyCB_SendHexFileOC_2(nChannel : Integer; pbyteBuffer: PByte; len: Integer): Integer;
  Function MyCB_SendHexFileOC_3(nChannel : Integer; pbyteBuffer: PByte; len: Integer): Integer;
  Function MyCB_SendHexFileOC_4(nChannel : Integer; pbyteBuffer: PByte; len: Integer): Integer;

  Function MyCB_SetFreqChange_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
  Function MyCB_SetFreqChange_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
  Function MyCB_SetFreqChange_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
  Function MyCB_SetFreqChange_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;

  function MyCB_measure_XYL_1(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
  function MyCB_measure_XYL_2(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
  function MyCB_measure_XYL_3(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
  function MyCB_measure_XYL_4(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;

  function MyCB_GetWaveformData_1(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
  function MyCB_GetWaveformData_2(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
  function MyCB_GetWaveformData_3(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
  function MyCB_GetWaveformData_4(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;

  function MyCB_SetSync_1(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
  function MyCB_SetSync_2(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
  function MyCB_SetSync_3(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
  function MyCB_SetSync_4(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
  var
  CSharpDll : TCSharpDll;

implementation



{ TCharpDll }

constructor TCSharpDll.Create(hMain,hTest: HWND;sDLLPath, sFileName: string);
var
  sDllFile : string;
  i : Integer;

begin
  sDllFile := sDLLPath+sFileName;
  m_bIsDLLWork := False;
  m_MainHandle := hMain;
  m_TestHandle := hTest;
  FNgMsg := '';
  FNgMsg := '';
  m_hDll := 0;
  if FileExists(sDllFile) then m_hDll := LoadLibrary(PChar(sDllFile))
  else                         FNgMsg := '[' + sDLLPath + ']' + #13#10 + ' Cannot find the file.!';
  if m_hDll = 0 then begin
    FNgMsg := ' loadlibrary returns 0';
    Exit;
  end;

  Setfunction;
  CreateCallBackFunction;

//  OnRevSwData :=

  tmrCycle := TTimer.Create(nil);
  tmrCycle.Interval := 500;
  tmrCycle.OnTimer := tmrCycleTimer;
  tmrCycle.Enabled := True;
end;

function MyCB_AllPowerOnOff_1(nChannel,OnOff: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := Pg[nChannel].SendPowerOn(OnOff,nWaitMS,nRetry); //TBD:DP860?
  {$ENDIF}
end;


function MyCB_AllPowerOnOff_2(nChannel,OnOff: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := Pg[nChannel].SendPowerOn(OnOff,nWaitMS,nRetry); //TBD:DP860?
  {$ENDIF}
end;
function MyCB_AllPowerOnOff_3(nChannel,OnOff: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := Pg[nChannel].SendPowerOn(OnOff,nWaitMS,nRetry); //TBD:DP860?
  {$ENDIF}
end;
function MyCB_AllPowerOnOff_4(nChannel,OnOff: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := Pg[nChannel].SendPowerOn(OnOff,nWaitMS,nRetry); //TBD:DP860?
  {$ENDIF}
end;

function MyCB_TCONSetReg_1(nChannel , Addr : Integer; data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  SetLength(arRData,nDataCnt);
  arrData[0] := data;
  sTxData := Format(' 0x%0.2x',[arrData[0]]);
  sDebug := Format('I2C WRITE: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitSec(%d) Retry(%d) Data(%s)',
                     [DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry, sTxData]);
  Common.MLog(nChannel,sDebug);

  Result := Pg[nChannel].SendI2CWrite(DEVICE_ADDRESS,Addr,nDataCnt, arrData, nWaitMS,nRetry);


    sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
    Common.MLog(nChannel,sDebug);
    nDataCnt := 1;
    SetLength(arRData,nDataCnt);
    Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  {$ENDIF}
end;


function MyCB_TCONSetReg_2(nChannel , Addr : Integer; data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  SetLength(arRData,nDataCnt);
  arrData[0] := data;
  sTxData := Format(' 0x%0.2x',[arrData[0]]);
  sDebug := Format('I2C WRITE: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitSec(%d) Retry(%d) Data(%s)',
                     [DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry, sTxData]);
  Common.MLog(nChannel,sDebug);

  Result := Pg[nChannel].SendI2CWrite(DEVICE_ADDRESS,Addr,nDataCnt, arrData, nWaitMS,nRetry);
  {$ENDIF}
end;



function MyCB_TCONSetReg_3(nChannel , Addr : Integer; data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  SetLength(arRData,nDataCnt);
  arrData[0] := data;
  sTxData := Format(' 0x%0.2x',[arrData[0]]);
  sDebug := Format('I2C WRITE: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitSec(%d) Retry(%d) Data(%s)',
                     [DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry, sTxData]);
  Common.MLog(nChannel,sDebug);

  Result := Pg[nChannel].SendI2CWrite(DEVICE_ADDRESS,Addr,nDataCnt, arrData, nWaitMS,nRetry);
  {$ENDIF}
end;


function MyCB_TCONSetReg_4(nChannel , Addr : Integer; data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  SetLength(arRData,nDataCnt);
  arrData[0] := data;
  sTxData := Format(' 0x%0.2x',[arrData[0]]);
  sDebug := Format('I2C WRITE: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitSec(%d) Retry(%d) Data(%s)',
                     [DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry, sTxData]);
  Common.MLog(nChannel,sDebug);

  Result := Pg[nChannel].SendI2CWrite(DEVICE_ADDRESS,Addr,nDataCnt, arrData, nWaitMS,nRetry);
  {$ENDIF}
end;



function MyCB_TCONGetReg_1(nChannel , Addr : Integer; var data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
  Common.MLog(nChannel,sDebug);

  SetLength(arRData,nDataCnt);
  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  data := arRData[0];
  {$ENDIF}
end;



function MyCB_TCONGetReg_2(nChannel , Addr : Integer; var data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
  Common.MLog(nChannel,sDebug);

  SetLength(arRData,nDataCnt);
  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  data := arRData[0];
  {$ENDIF}
end;



function MyCB_TCONGetReg_3(nChannel , Addr : Integer; var data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
  Common.MLog(nChannel,sDebug);

  SetLength(arRData,nDataCnt);
  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  data := arRData[0];
  {$ENDIF}
end;



function MyCB_TCONGetReg_4(nChannel , Addr : Integer; var data : Byte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  PGAF9Fpga[nChannel].AF9_AllPowerOnOff(OnOff);  //OFF
  Result := WAIT_OBJECT_0;
  {$ENDIF}
  {$IFDEF PG_DP860}

  nDataCnt := 1;
  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
  Common.MLog(nChannel,sDebug);

  SetLength(arRData,nDataCnt);
  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  data := arRData[0];
  {$ENDIF}
end;


function MyCB_FlashWrite_File_1(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := EndSeg - StartSeg;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;
end;

function MyCB_FlashWrite_File_2(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);
//
//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashWrite_File_3(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashWrite_File_4(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);

  Result := 0;
end;

function MyCB_FlashWrite_Data_1(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashWrite_Data_2(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashWrite_Data_3(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashWrite_Data_4(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashRead_File_1(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashRead_File_2(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashRead_File_3(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;
end;

function MyCB_FlashRead_File_4(nChannel,StartSeg,EndSeg : Integer; filePath : PAnsiChar): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;
end;


function MyCB_FlashRead_Data_1(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashRead_Data_2(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
//  data := arRData[0];
  Result := 0;
end;

function MyCB_FlashRead_Data_3(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashRead_Data_4(nChannel,StartSeg,EndSeg : Integer; const data: PByte): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;


function MyCB_FlashErase_1(nChannel,StartSeg,EndSeg : Integer): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);
  Result := 0;

end;

function MyCB_FlashErase_2(nChannel,StartSeg,EndSeg : Integer): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);

  Result := 0;
end;

function MyCB_FlashErase_3(nChannel,StartSeg,EndSeg : Integer): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);

  Result := 0;
end;

function MyCB_FlashErase_4(nChannel,StartSeg,EndSeg : Integer): Integer;
var
nWaitMS,nRetry,nDataCnt : Integer;
sDebug,sTxData : string;
arRData : TIdBytes;
begin
  nDataCnt := 1;
//  sDebug := Format('I2C READ: DevAddr(0x%0.2x) RegAddr(0x%0.4x) DataCnt(%d), WaitMS(%d) Retry(%d) ',[DEVICE_ADDRESS,Addr,nDataCnt, nWaitMS,nRetry]);
//  Common.MLog(nChannel,sDebug);

//  SetLength(arRData,nDataCnt);
//  Result := Pg[nChannel].SendI2CRead(DEVICE_ADDRESS,Addr,nDataCnt,arRData, nWaitMS,nRetry);

  Result := 0;
end;



function MyCB_APSBoxPatternSet_1(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSBoxPatternSet(XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSBoxPatternSet_2(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSBoxPatternSet(XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSBoxPatternSet_3(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSBoxPatternSet(XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSBoxPatternSet_4(nChannel,XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSBoxPatternSet(XOffset,YOffset, Width,Height, R,G,B, Background_R,Background_G,Background_B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;

function MyCB_APSPatternRGBSet_1(nChannel, R, G, B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSPatternRGBSet_2(nChannel, R, G, B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSPatternRGBSet_3(nChannel, R, G, B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSPatternRGBSet_4(nChannel, R, G, B: Integer): Integer;
var
nWaitMS,nRetry : Integer;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendDisplayPatRGB(R,G,B, nWaitMS,nRetry);
  {$ENDIF}
end;

function MyCB_APSSetReg_1(nChannel,Addr: Integer; Data: Integer): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSSetReg_2(nChannel,Addr: Integer; Data: Integer): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSSetReg_3(nChannel,Addr: Integer; Data: Integer): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_APSSetReg_4(nChannel,Addr: Integer; Data: Integer): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_APSSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;

function MyCB_LGDSetReg_1(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_LGDSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_LGDSetReg_2(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_LGDSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_LGDSetReg_3(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_LGDSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;
function MyCB_LGDSetReg_4(nChannel : Integer; Addr: DWORD; data: Byte): Integer;
var
  nWaitMS,nRetry : Integer;
  arrData    : TIdBytes;
begin
  nWaitMS := 3000;
  nRetry  := 0;  // No Retry
  SetLength(arrData,1);
  arrData[0] := Data;
  {$IFDEF PG_AF9}
  Result := PGAF9Fpga[nChannel].AF9_LGDSetReg(Addr,Data);
  {$ENDIF}
  {$IFDEF PG_DP860}
  Result := pg[nChannel].DP860_SendI2CWrite(DefPG.LGD_REG_DEVICE,Addr,1,arrData, nWaitMS,nRetry);
  {$ENDIF}
end;

function MyCB_LGDSetRegM_1(nChannel : Integer; LGDCommand: AF9_PLGDCommand; CommandCnt: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_LGDSetRegM(LGDCommand,CommandCnt);
end;
function MyCB_LGDSetRegM_2(nChannel : Integer; LGDCommand: AF9_PLGDCommand; CommandCnt: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_LGDSetRegM(LGDCommand,CommandCnt);
end;
function MyCB_LGDSetRegM_3(nChannel : Integer; LGDCommand: AF9_PLGDCommand; CommandCnt: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_LGDSetRegM(LGDCommand,CommandCnt);
end;
function MyCB_LGDSetRegM_4(nChannel : Integer; LGDCommand: AF9_PLGDCommand; CommandCnt: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_LGDSetRegM(LGDCommand,CommandCnt);
end;

function MyCB_PatternRGBSet_1(nChannel, R, G, B: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
end;
function MyCB_PatternRGBSet_2(nChannel, R, G, B: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
end;
function MyCB_PatternRGBSet_3(nChannel, R, G, B: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
end;
function MyCB_PatternRGBSet_4(nChannel, R, G, B: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_APSPatternRGBSet(R, G, B);
end;

function MyCB_SendHexFileCRC_1(nChannel : Integer; CRC: Word): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileCRC(CRC);
end;
function MyCB_SendHexFileCRC_2(nChannel : Integer; CRC: Word): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileCRC(CRC);
end;
function MyCB_SendHexFileCRC_3(nChannel : Integer; CRC: Word): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileCRC(CRC);
end;
function MyCB_SendHexFileCRC_4(nChannel : Integer; CRC: Word): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileCRC(CRC);
end;

function MyCB_Start_Connection_1(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Start_Connection;
end;
function MyCB_Start_Connection_2(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Start_Connection;
end;
function MyCB_Start_Connection_3(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Start_Connection;
end;
function MyCB_Start_Connection_4(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Start_Connection;
end;

function MyCB_Stop_Connection_1(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Stop_Connection;
end;
function MyCB_Stop_Connection_2(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Stop_Connection;
end;
function MyCB_Stop_Connection_3(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Stop_Connection;
end;
function MyCB_Stop_Connection_4(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Stop_Connection;
end;

function MyCB_WriteBMPFile_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_WriteBMPFile(pbyteBuffer,len);
end;
function MyCB_WriteBMPFile_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_WriteBMPFile(pbyteBuffer,len);
end;
function MyCB_WriteBMPFile_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_WriteBMPFile(pbyteBuffer,len);
end;
function MyCB_WriteBMPFile_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_WriteBMPFile(pbyteBuffer,len);
end;

function MyCB_Connection_Status_1(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Connection_Status;
end;
function MyCB_Connection_Status_2(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Connection_Status;
end;
function MyCB_Connection_Status_3(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Connection_Status;
end;
function MyCB_Connection_Status_4(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_Connection_Status;
end;

function MyCB_FreeAF9API_1(nChannel : Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_FreeAF9API;
end;
function MyCB_FreeAF9API_2(nChannel : Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_FreeAF9API;
end;
function MyCB_FreeAF9API_3(nChannel : Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_FreeAF9API;
end;
function MyCB_FreeAF9API_4(nChannel : Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_FreeAF9API;
end;

function MyCB_SendHexFile_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFile(pbyteBuffer,len);
end;
function MyCB_SendHexFile_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFile(pbyteBuffer,len);
end;
function MyCB_SendHexFile_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFile(pbyteBuffer,len);
end;
function MyCB_SendHexFile_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFile(pbyteBuffer,len);
end;

Function MyCB_DAC_SET_1(nChannel, nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_DAC_SET(nType,Channel,Voltage,Option);
end;
Function MyCB_DAC_SET_2(nChannel, nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_DAC_SET(nType,Channel,Voltage,Option);
end;
Function MyCB_DAC_SET_3(nChannel, nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_DAC_SET(nType,Channel,Voltage,Option);
end;
Function MyCB_DAC_SET_4(nChannel, nType: Integer; Channel: Integer; Voltage: Integer; Option: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_DAC_SET(nType,Channel,Voltage,Option);
end;

Function MyCB_ExtendIO_Set_1(nChannel, Address: Integer; Channel: Integer; Enable: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_ExtendIO_Set(Address,Channel,Enable);
end;
Function MyCB_ExtendIO_Set_2(nChannel, Address: Integer; Channel: Integer; Enable: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_ExtendIO_Set(Address,Channel,Enable);
end;
Function MyCB_ExtendIO_Set_3(nChannel, Address: Integer; Channel: Integer; Enable: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_ExtendIO_Set(Address,Channel,Enable);
end;
Function MyCB_ExtendIO_Set_4(nChannel, Address: Integer; Channel: Integer; Enable: Integer): Boolean;
begin
  Result := PGAF9Fpga[nChannel].AF9_ExtendIO_Set(Address,Channel,Enable);
end;

function MyCB_FlashRead_1(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
begin
  Result := PGAF9Fpga[nChannel].AF9_FlashRead(pBuffer,StartAddr,EndAddr);
end;
function MyCB_FlashRead_2(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
begin
  Result := PGAF9Fpga[nChannel].AF9_FlashRead(pBuffer,StartAddr,EndAddr);
end;
function MyCB_FlashRead_3(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
begin
  Result := PGAF9Fpga[nChannel].AF9_FlashRead(pBuffer,StartAddr,EndAddr);
end;
function MyCB_FlashRead_4(nChannel : Integer; const pBuffer: PByte; StartAddr,EndAddr: DWORD): Byte;
begin
  Result := PGAF9Fpga[nChannel].AF9_FlashRead(pBuffer,StartAddr,EndAddr);
end;

function MyCB_SW_Revision_1(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SW_Revision;
end;
function MyCB_SW_Revision_2(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SW_Revision;
end;
function MyCB_SW_Revision_3(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SW_Revision;
end;
function MyCB_SW_Revision_4(nChannel : Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SW_Revision;
end;

Function MyCB_SendHexFileOC_1(nChannel : integer; pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileOC(pbyteBuffer,len);
end;
Function MyCB_SendHexFileOC_2(nChannel : integer; pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileOC(pbyteBuffer,len);
end;
Function MyCB_SendHexFileOC_3(nChannel : integer; pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileOC(pbyteBuffer,len);
end;
Function MyCB_SendHexFileOC_4(nChannel : integer; pbyteBuffer: PByte; len: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SendHexFileOC(pbyteBuffer,len);
end;

Function MyCB_SetFreqChange_1(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SetFreqChange(pbyteBuffer,len,HzCnt,nRepeat);
end;
Function MyCB_SetFreqChange_2(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SetFreqChange(pbyteBuffer,len,HzCnt,nRepeat);
end;
Function MyCB_SetFreqChange_3(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SetFreqChange(pbyteBuffer,len,HzCnt,nRepeat);
end;
Function MyCB_SetFreqChange_4(nChannel : Integer; const pbyteBuffer: PByte; len: Integer; HzCnt: Integer; nRepeat: Integer): Integer;
begin
  Result := PGAF9Fpga[nChannel].AF9_SetFreqChange(pbyteBuffer,len,HzCnt,nRepeat);
end;

function MyCB_GetWaveformData_1(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
var
i,j : Integer;
waveform,Data : array of Double;
begin
    SetLength(waveform,nMeasureAmount);
    SetLength(Data,nMeasureAmount);

    result := CaSdk2.GetWaveformData(nChannel,@waveform[0],@Data[0] ,nMeasureAmount);
    CopyMemory(waveform_T,@waveform[0],nMeasureAmount*sizeof(waveform[0]));
    CopyMemory(waveformData,@Data[0],nMeasureAmount*sizeof(waveform[0]));

end;
function MyCB_GetWaveformData_2(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
var
i,j : Integer;
waveform,Data : array of Double;
begin
    SetLength(waveform,nMeasureAmount);
    SetLength(Data,nMeasureAmount);

    result := CaSdk2.GetWaveformData(nChannel,@waveform[0],@Data[0] ,nMeasureAmount);
    CopyMemory(waveform_T,@waveform[0],nMeasureAmount*sizeof(waveform[0]));
    CopyMemory(waveformData,@Data[0],nMeasureAmount*sizeof(waveform[0]));

end;
function MyCB_GetWaveformData_3(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
var
i,j : Integer;
waveform,Data : array of Double;
begin
    SetLength(waveform,nMeasureAmount);
    SetLength(Data,nMeasureAmount);

    result := CaSdk2.GetWaveformData(nChannel,@waveform[0],@Data[0] ,nMeasureAmount);
    CopyMemory(waveform_T,@waveform[0],nMeasureAmount*sizeof(waveform[0]));
    CopyMemory(waveformData,@Data[0],nMeasureAmount*sizeof(waveform[0]));

end;
function MyCB_GetWaveformData_4(nChannel : Integer; var waveform_T: Pdouble; var  waveformData : Pdouble; nMeasureAmount : Integer): Double;
var
i,j : Integer;
waveform,Data : array of Double;
begin
    SetLength(waveform,nMeasureAmount);
    SetLength(Data,nMeasureAmount);

    result := CaSdk2.GetWaveformData(nChannel,@waveform[0],@Data[0] ,nMeasureAmount);
    CopyMemory(waveform_T,@waveform[0],nMeasureAmount*sizeof(waveform[0]));
    CopyMemory(waveformData,@Data[0],nMeasureAmount*sizeof(waveform[0]));

end;

function MyCB_measure_XYL_1(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
var
i,wdRet: Integer;
m_Ca410Data  : TBrightValue;
begin

  wdRet := CaSdk2.Measure(nChannel,m_Ca410Data);

  t5[0] := m_Ca410Data.xVal;
  t5[1] := m_Ca410Data.yVal;
  t5[2] := m_Ca410Data.LvVal;
  Result := wdRet;

end;
function MyCB_measure_XYL_2(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
var
i,wdRet: Integer;
m_Ca410Data  : TBrightValue;
begin

  wdRet := CaSdk2.Measure(nChannel,m_Ca410Data);

  t5[0] := m_Ca410Data.xVal;
  t5[1] := m_Ca410Data.yVal;
  t5[2] := m_Ca410Data.LvVal;
  Result := wdRet;

end;
function MyCB_measure_XYL_3(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
var
i,wdRet: Integer;
m_Ca410Data  : TBrightValue;
begin

  wdRet := CaSdk2.Measure(nChannel,m_Ca410Data);

  t5[0] := m_Ca410Data.xVal;
  t5[1] := m_Ca410Data.yVal;
  t5[2] := m_Ca410Data.LvVal;
  Result := wdRet;

end;
function MyCB_measure_XYL_4(nChannel:Integer; var t5 : TArray<double>; var nLen : Integer): Integer;
var
i,wdRet: Integer;
m_Ca410Data  : TBrightValue;
begin

  wdRet := CaSdk2.Measure(nChannel,m_Ca410Data);

  t5[0] := m_Ca410Data.xVal;
  t5[1] := m_Ca410Data.yVal;
  t5[2] := m_Ca410Data.LvVal;
  Result := wdRet;

end;

function MyCB_SetSync_1(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
var
i : Integer;
begin
  Result := CaSdk2.SetSyncMode(nChannel,CA_SyncMode,CA_Hz,0);
end;
function MyCB_SetSync_2(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
var
i : Integer;
begin
  Result := CaSdk2.SetSyncMode(nChannel,CA_SyncMode,CA_Hz,0);
end;
function MyCB_SetSync_3(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
var
i : Integer;
begin
  Result := CaSdk2.SetSyncMode(nChannel,CA_SyncMode,CA_Hz,0);
end;
function MyCB_SetSync_4(nChannel,CA_SyncMode,CA_Hz,channel_num : Integer): Integer ;
var
i : Integer;
begin
  Result := CaSdk2.SetSyncMode(nChannel,CA_SyncMode,CA_Hz,0);
end;

procedure TCSharpDll.SendTestGuiDisplay(nCh,nGuiMode: Integer; sMsg: string; nParam: Integer);
var
  ccd         : TCopyDataStruct;
  GuiData    : RGuiDLL;
begin
  GuiData.MsgType := defCommon.MSG_TYPE_DLL;
  GuiData.Channel := nCh;
  GuiData.Mode    := nGuiMode;
  GuiData.nParam := nParam;
  GuiData.Msg     := sMsg;
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(GuiData);
  ccd.lpData      := @GuiData;
  SendMessage(m_TestHandle,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TCSharpDll.SetOnRevSwData(nCH : Integer; const Value: TCallBackTextChanged);
begin
	CB_TextChanged[nCH] := Value;
end;


procedure TCSharpDll.MLOG(nChannel_Index : Integer; bClear : Boolean; sMLOG : string);
var
  th : TThread;
  sLog : string;
begin
  SendTestGuiDisplay(nChannel_Index,defCommon.MSG_MODE_WORKING,sMLOG,0);
end;

procedure MyCB_TextChanged_1(channel_Index : Integer; bClear : Boolean; sAddedText : PAnsiChar);cdecl;
begin
  CSharpDll.MLOG(channel_Index,bClear,(PAnsiChar(sAddedText)));
end;
procedure MyCB_TextChanged_2(channel_Index : Integer; bClear : Boolean; sAddedText : PAnsiChar);cdecl;
begin
  CSharpDll.MLOG(channel_Index,bClear,(PAnsiChar(sAddedText)));
end;
procedure MyCB_TextChanged_3(channel_Index : Integer; bClear : Boolean; sAddedText : PAnsiChar);cdecl;
begin
  CSharpDll.MLOG(channel_Index,bClear,(PAnsiChar(sAddedText)));
end;
procedure MyCB_TextChanged_4(channel_Index : Integer; bClear : Boolean; sAddedText : PAnsiChar);cdecl;
begin
  CSharpDll.MLOG(channel_Index,bClear,(PAnsiChar(sAddedText)));
end;

procedure TCSharpDll.ThreadTask(Task: TProc);
begin
  TThread.CreateAnonymousThread(
    Task
  ).Start;
end;


procedure TCSharpDll.tmrCycleTimer(Sender : TObject);
var
hWnd,hMessageBox : THandle;
begin
   tmrCycle.Enabled := false;
   try

      hWnd := 0;
      hWnd := FindWindow('#32770',nil);
      if hWnd > 0 then begin
        hMessageBox := FindWindowEx(hWnd,0, 'Static','Place the CA410 probe to center position!');
        if hMessageBox > 0 then
          PostMessage(hWnd, WM_CLOSE, 0, 0);

//          hMessageBox := FindWindowEx(hWnd,0, 'button','Ȯ��');

        hMessageBox := FindWindowEx(hWnd,0, 'Static','CH1 Switch OFF, ON,  Display ON');
        if hMessageBox > 0 then begin
//          ThreadTask(procedure begin
//            PostMessage(hWnd, WM_CLOSE, 0, 0);
//            PGAF9Fpga[0].AF9_AllPowerOnOff(0);
//            sleep(1000);
//            PGAF9Fpga[0].AF9_AllPowerOnOff(1);
//            sleep(5000);
//            MainOC_Verify_Start(0);
//
//          end);

        end;
      end;

   finally
      tmrCycle.Enabled := true;
   end;
end;


procedure TCSharpDll.FormDestroy;
begin
  m_FormDestroy;
end;


procedure TCSharpDll.Initialize;
var
nT1,i : Integer;

ss : string;
begin
  nT1 := m_Initialize(4);
  for I := DefCommon.CH1 to DefCommon.MAX_CH do begin

      m_SetCallback_TextChanged(i,CB_TextChanged[i]);

      m_SetCallback_measure_XYL(i,CB_measure_XYL[i]);
      m_SetCallback_SetSync(i,CB_SetSync[i]);
      m_SetCallback_GetWaveformData(i,CB_GetWaveformData[i]);


      m_SetCallBackAllPowerOnOff    (i,CB_PowerOnOff[i]);
      m_SetCallBackTCONSetReg       (i,CB_TCONSetReg[i]);
      m_SetCallBackTCONGetReg       (i,CB_TCONGetReg[i]);
      m_SetCallBackFlashWrite_File  (i,CB_FlashWrite_File[i]);
      m_SetCallBackFlashWrite_Data  (i,CB_FlashWrite_Data[i]);
      m_SetCallBackFlashRead_File   (i,CB_FlashRead_File[i]);
      m_SetCallBackFlashRead_Data   (i,CB_FlashRead_Data[i]);
      m_SetCallBackFlashErase       (i,CB_FlashErase[i]);



      m_SetCallBackAPSBoxPatternSet (i,CB_APSBoxPatternSet[i]);
      m_SetCallBackAPSPatternRGBSet (i,CB_APSPatternRGBSet[i]);
      m_SetCallBackAPSSetReg        (i,CB_APSSetReg[i]);
      m_SetCallBackLGDSetReg        (i,CB_LGDSetReg[i]);
//      m_SetCallBackLGDSetRegM       (i,CB_LGDSetRegM[i]);
      m_SetCallBackPatternRGBSet    (i,CB_PatternRGBSet[i]);
      m_SetCallBackSendHexFileCRC   (i,CB_SendHexFileCRC[i]);
      m_SetCallBackStart_Connection (i,CB_Start_Connection[i]);
      m_SetCallBackStop_Connection  (i,CB_Stop_Connection[i]);
      m_SetCallBackWriteBMPFile     (i,CB_WriteBMPFile[i]);
      m_SetCallBackConnection_Status(i,CB_Connection_Status[i]);
      m_SetCallBackFreeAF9API       (i,CB_FreeAF9API[i]);
      m_SetCallBackSendHexFile      (i,CB_SendHexFile[i]);
      m_SetCallBackDAC_SET          (i,CB_DAC_SET[i]);
      m_SetCallBackExtendIO_Set     (i,CB_ExtendIO_Set[i]);
      m_SetCallBackFlashRead        (i,CB_FlashRead[i]);
      m_SetCallBackSW_Revision      (i,CB_SW_Revision[i]);
      m_SetCallBackSendHexFileOC    (i,CB_SendHexFileOC[i]);
      m_SetCallBackSetFreqChange    (i,CB_SetFreqChange[i]);

  end;

end;

function TCSharpDll.MainOC_Start(nCH : Integer): Integer;
var
nRet : integer;
begin
  m_bIsDLLWork := True;
  m_MainOC_START(nCH);
  Result :=  0;
  m_bIsDLLWork := False;
end;

function TCSharpDll.MainOC_Stop(nCH : Integer): integer;
begin
  Result :=  m_MainOC_STOP(nCH);
end;

function TCSharpDll.MainOC_ThreadStateCheck(nCH : Integer): integer;
begin
   Result :=  m_MainOC_ThreadStateCheck(nCH);
end;

function TCSharpDll.MainOC_Verify_Start(nCH : Integer): integer;
begin
 Result :=  m_MainOC_VerifyStart(nCH);
end;

destructor TCSharpDll.Destroy;
var
i : integer;
hWnd : THandle;
begin
  hWnd := FindWindow(nil,'Form1');
  if hWnd > 0 then
    PostMessage(hWnd, WM_CLOSE, 0, 0);


  if tmrCycle <> nil then  begin
    tmrCycle.Free;
    tmrCycle := nil;

  end;



  for I := DefCommon.CH1 to DefCommon.MAX_CH do begin
    if PGAF9Fpga[i] <> nil then begin
      PGAF9Fpga[i].Free;
      PGAF9Fpga[i] := nil;
    end;
  end;


  FreeLibrary(m_hDll);
  inherited;
end;




procedure TCSharpDll.CreateCallBackFunction;
var
  i : integer;
  a: TCallBackAllPowerOnOff;
begin
  for I := DefCommon.CH1 to DefCommon.MAX_CH do begin
    case i of
      DefCommon.CH1 : begin
        @CB_PowerOnOff[i] := @MyCB_AllPowerOnOff_1;
        @CB_APSBoxPatternSet[i] := @MyCB_APSBoxPatternSet_1;
        @CB_APSPatternRGBSet[i] := @MyCB_APSPatternRGBSet_1;
        @CB_APSSetReg[i] := @MyCB_APSSetReg_1;
        @CB_LGDSetReg[i] := @MyCB_LGDSetReg_1;
        @CB_LGDSetRegM[i] := @MyCB_LGDSetRegM_1;
        @CB_PatternRGBSet[i] := @MyCB_PatternRGBSet_1;
        @CB_SendHexFileCRC[i] := @MyCB_SendHexFileCRC_1;
        @CB_Start_Connection[i] := @MyCB_Start_Connection_1;
        @CB_Stop_Connection[i] := @MyCB_Stop_Connection_1;

        @CB_WriteBMPFile[i] := @MyCB_WriteBMPFile_1;
        @CB_Connection_Status[i] := @MyCB_Connection_Status_1;
        @CB_FreeAF9API[i] := @MyCB_FreeAF9API_1;
        @CB_SendHexFile[i] := @MyCB_SendHexFile_1;
        @CB_DAC_SET[i] := @MyCB_DAC_SET_1;
        @CB_ExtendIO_Set[i] := @MyCB_ExtendIO_Set_1;
        @CB_FlashRead[i] := @MyCB_FlashRead_1;
        @CB_SW_Revision[i] := @MyCB_SW_Revision_1;
        @CB_SendHexFileOC[i] := @MyCB_SendHexFileOC_1;
        @CB_SetFreqChange[i] := @MyCB_SetFreqChange_1;
        @CB_Measure_XYL[i] := @MyCB_measure_XYL_1;
        @CB_SetSync[i] := @MyCB_SetSync_1;
        @CB_GetWaveformData[i] := @MyCB_GetWaveformData_1;
        @CB_TextChanged[i] := @MyCB_TextChanged_1;

      end;
      DefCommon.CH2 : begin
        @CB_PowerOnOff[i] := @MyCB_AllPowerOnOff_2;
        @CB_APSBoxPatternSet[i] := @MyCB_APSBoxPatternSet_2;
        @CB_APSPatternRGBSet[i] := @MyCB_APSPatternRGBSet_2;
        @CB_APSSetReg[i] := @MyCB_APSSetReg_2;
        @CB_LGDSetReg[i] := @MyCB_LGDSetReg_2;
        @CB_LGDSetRegM[i] := @MyCB_LGDSetRegM_2;
        @CB_PatternRGBSet[i] := @MyCB_PatternRGBSet_2;
        @CB_SendHexFileCRC[i] := @MyCB_SendHexFileCRC_2;
        @CB_Start_Connection[i] := @MyCB_Start_Connection_2;
        @CB_Stop_Connection[i] := @MyCB_Stop_Connection_2;

        @CB_WriteBMPFile[i] := @MyCB_WriteBMPFile_2;
        @CB_Connection_Status[i] := @MyCB_Connection_Status_2;
        @CB_FreeAF9API[i] := @MyCB_FreeAF9API_2;
        @CB_SendHexFile[i] := @MyCB_SendHexFile_2;
        @CB_DAC_SET[i] := @MyCB_DAC_SET_2;
        @CB_ExtendIO_Set[i] := @MyCB_ExtendIO_Set_2;
        @CB_FlashRead[i] := @MyCB_FlashRead_2;
        @CB_SW_Revision[i] := @MyCB_SW_Revision_2;
        @CB_SendHexFileOC[i] := @MyCB_SendHexFileOC_2;
        @CB_SetFreqChange[i] := @MyCB_SetFreqChange_2;
        @CB_Measure_XYL[i] := @MyCB_measure_XYL_2;
        @CB_SetSync[i] := @MyCB_SetSync_2;
        @CB_GetWaveformData[i] := @MyCB_GetWaveformData_2;
        @CB_TextChanged[i] := @MyCB_TextChanged_2;

      end;
      DefCommon.CH3 : begin
        @CB_PowerOnOff[i] := @MyCB_AllPowerOnOff_3;
        @CB_APSBoxPatternSet[i] := @MyCB_APSBoxPatternSet_3;
        @CB_APSPatternRGBSet[i] := @MyCB_APSPatternRGBSet_3;
        @CB_APSSetReg[i] := @MyCB_APSSetReg_3;
        @CB_LGDSetReg[i] := @MyCB_LGDSetReg_3;
        @CB_LGDSetRegM[i] := @MyCB_LGDSetRegM_3;
        @CB_PatternRGBSet[i] := @MyCB_PatternRGBSet_3;
        @CB_SendHexFileCRC[i] := @MyCB_SendHexFileCRC_3;
        @CB_Start_Connection[i] := @MyCB_Start_Connection_3;
        @CB_Stop_Connection[i] := @MyCB_Stop_Connection_3;

        @CB_WriteBMPFile[i] := @MyCB_WriteBMPFile_3;
        @CB_Connection_Status[i] := @MyCB_Connection_Status_3;
        @CB_FreeAF9API[i] := @MyCB_FreeAF9API_3;
        @CB_SendHexFile[i] := @MyCB_SendHexFile_3;
        @CB_DAC_SET[i] := @MyCB_DAC_SET_3;
        @CB_ExtendIO_Set[i] := @MyCB_ExtendIO_Set_3;
        @CB_FlashRead[i] := @MyCB_FlashRead_3;
        @CB_SW_Revision[i] := @MyCB_SW_Revision_3;
        @CB_SendHexFileOC[i] := @MyCB_SendHexFileOC_3;
        @CB_SetFreqChange[i] := @MyCB_SetFreqChange_3;
        @CB_Measure_XYL[i] := @MyCB_measure_XYL_3;
        @CB_SetSync[i] := @MyCB_SetSync_3;
        @CB_GetWaveformData[i] := @MyCB_GetWaveformData_3;
        @CB_TextChanged[i] := @MyCB_TextChanged_3;

      end;
      DefCommon.CH4 : begin
        @CB_PowerOnOff[i] := @MyCB_AllPowerOnOff_4;
        @CB_APSBoxPatternSet[i] := @MyCB_APSBoxPatternSet_4;
        @CB_APSPatternRGBSet[i] := @MyCB_APSPatternRGBSet_4;
        @CB_APSSetReg[i] := @MyCB_APSSetReg_4;
        @CB_LGDSetReg[i] := @MyCB_LGDSetReg_4;
        @CB_LGDSetRegM[i] := @MyCB_LGDSetRegM_4;
        @CB_PatternRGBSet[i] := @MyCB_PatternRGBSet_4;
        @CB_SendHexFileCRC[i] := @MyCB_SendHexFileCRC_4;
        @CB_Start_Connection[i] := @MyCB_Start_Connection_4;
        @CB_Stop_Connection[i] := @MyCB_Stop_Connection_4;

        @CB_WriteBMPFile[i] := @MyCB_WriteBMPFile_4;
        @CB_Connection_Status[i] := @MyCB_Connection_Status_4;
        @CB_FreeAF9API[i] := @MyCB_FreeAF9API_4;
        @CB_SendHexFile[i] := @MyCB_SendHexFile_4;
        @CB_DAC_SET[i] := @MyCB_DAC_SET_4;
        @CB_ExtendIO_Set[i] := @MyCB_ExtendIO_Set_4;
        @CB_FlashRead[i] := @MyCB_FlashRead_4;
        @CB_SW_Revision[i] := @MyCB_SW_Revision_4;
        @CB_SendHexFileOC[i] := @MyCB_SendHexFileOC_4;
        @CB_SetFreqChange[i] := @MyCB_SetFreqChange_4;
        @CB_Measure_XYL[i] := @MyCB_measure_XYL_4;
        @CB_SetSync[i] := @MyCB_SetSync_4;
        @CB_GetWaveformData[i] := @MyCB_GetWaveformData_4;
        @CB_TextChanged[i] := @MyCB_TextChanged_4;

      end;
    end;

  end;
//  CsharpDll.Initialize_TEST;
end;




procedure TCSharpDll.Setfunction;
begin
  @m_Initialize      := GetProcAddress(m_hDll, 'Initialize');
  @m_FormDestroy     := GetProcAddress(m_hDll, 'FormDestroy');

  @m_SetCallback_measure_XYL := GetProcAddress(m_hDll, 'Callback_measure_XYL');
  @m_SetCallback_SetSync := GetProcAddress(m_hDll,'Callback_SetSync');
  @m_SetCallback_GetWaveformData := GetProcAddress(m_hDll,'Callback_GetWaveformData');
  @m_MainOC_START :=  GetProcAddress(m_hDll,'MainOC_START');
  @m_MainOC_STOP :=  GetProcAddress(m_hDll,'MainOC_STOP');
  @m_MainOC_VerifyStart :=  GetProcAddress(m_hDll,'Verify_Start');
  @m_MainOC_ThreadStateCheck := GetProcAddress(m_hDll,'ThreadStateCheck');

  @m_SetCallback_TextChanged := GetProcAddress(m_hDll,'Callback_TextChanged');

  @m_SetCallBackAllPowerOnOff      := GetProcAddress(m_hDll,'Callback_AllPowerOnOff');
  @m_SetCallBackTCONSetReg         := GetProcAddress(m_hDll,'Callback_TCONSetReg');
  @m_SetCallBackTCONGetReg         := GetProcAddress(m_hDll,'Callback_TCONGetReg');
  @m_SetCallBackFlashWrite_File    := GetProcAddress(m_hDll,'Callback_FlashWrite_File');
  @m_SetCallBackFlashWrite_Data    := GetProcAddress(m_hDll,'Callback_FlashWrite_Data');
  @m_SetCallBackFlashRead_File     := GetProcAddress(m_hDll,'Callback_FlashRead_File');
  @m_SetCallBackFlashRead_Data     := GetProcAddress(m_hDll,'Callback_FlashRead_Data');
  @m_SetCallBackFlashErase         := GetProcAddress(m_hDll,'Callback_measure_XYL');
  @m_SetCallBackAPSBoxPatternSet   := GetProcAddress(m_hDll,'Callback_APSBoxPatternSet');
  @m_SetCallBackAPSPatternRGBSet   := GetProcAddress(m_hDll,'Callback_APSPatternRGBSet');
  @m_SetCallBackAPSSetReg          := GetProcAddress(m_hDll,'Callback_APSSetReg');
  @m_SetCallBackLGDSetReg          := GetProcAddress(m_hDll,'Callback_LGDSetReg');
  @m_SetCallBackLGDSetRegM         := GetProcAddress(m_hDll,'Callback_LGDSetRegM');
  @m_SetCallBackPatternRGBSet      := GetProcAddress(m_hDll,'Callback_PatternRGBSet');
  @m_SetCallBackSendHexFileCRC     := GetProcAddress(m_hDll,'Callback_SendHexFileCRC');
  @m_SetCallBackStart_Connection   := GetProcAddress(m_hDll,'Callback_Start_Connection');
  @m_SetCallBackStop_Connection    := GetProcAddress(m_hDll,'Callback_Stop_Connection');
  @m_SetCallBackWriteBMPFile       := GetProcAddress(m_hDll,'Callback_WriteBMPFile');
  @m_SetCallBackConnection_Status  := GetProcAddress(m_hDll,'Callback_Connection_Status');
  @m_SetCallBackFreeAF9API         := GetProcAddress(m_hDll,'Callback_FreeAF9API');
  @m_SetCallBackSendHexFile        := GetProcAddress(m_hDll,'Callback_SendHexFile');
  @m_SetCallBackDAC_SET            := GetProcAddress(m_hDll,'Callback_DAC_SET');
  @m_SetCallBackExtendIO_Set       := GetProcAddress(m_hDll,'Callback_ExtendIO_Set');
  @m_SetCallBackFlashRead          := GetProcAddress(m_hDll,'Callback_FlashRead');
  @m_SetCallBackSW_Revision        := GetProcAddress(m_hDll,'Callback_SW_Revision');
  @m_SetCallBackSendHexFileOC      := GetProcAddress(m_hDll,'Callback_SendHexFileOC');
  @m_SetCallBackSetFreqChange      := GetProcAddress(m_hDll,'Callback_SetFreqChange');

end;

procedure TCSharpDll.SetNgMsg(const Value: string);
begin
  FNgMsg := Value;
end;



end.
