unit DllLgdCssTls;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, IdGlobal,
  Vcl.Dialogs, Winapi.Messages, System.UITypes;

const
    DLL_CSS_LGD_MAX_CH              = 3;
    DLL_CSS_LGD_MAX_CH_NO           = DLL_CSS_LGD_MAX_CH - 1;
    //DLL_CSS_LGD_CONVETER_PATH       = 'DAE_Auto_Dll_Converter.dll';//'driver\win32\DAE_Auto_Dll_Converter.dll'; //'driver\win32\CallTest.dll';
    //DLL_CSS_LGD_CONVETER_PATH       = 'driver\win32\';//'driver\win32\DAE_Auto_Dll_Converter.dll';
    DLL_CSS_LGD_TLS_PATH            = 'LgdDll\';//'driver\win32\DAE_Auto_Dll_Converter.dll';  for IT GA.

    DLL_CSS_LGD_TYPE                = 14;
    DLL_CSS_LGD_MODE_LOG            = 1;

    DLL_CSS_LGD_IDX_CB_WRTIE_DATA      = 1;
    DLL_CSS_LGD_IDX_CB_READ_DATA       = 2;
    DLL_CSS_LGD_IDX_CB_WRTIE_DATA_SPI  = 3;
    DLL_CSS_LGD_IDX_CB_READ_DATA_SPI   = 4;
    DLL_CSS_LGD_IDX_CB_ERASE_DATA_SPI  = 5;
    DLL_CSS_LGD_IDX_CB_RETURN_STR      = 6;
    DLL_CSS_LGD_IDX_CB_RETURN_BOOL     = 7;
    DLL_CSS_LGD_IDX_CB_RETURN_INT      = 8;
    DLL_CSS_LGD_IDX_CB_RETURN_DOUBLE   = 9;
    DLL_CSS_LGD_IDX_CB_SET_INT         = 10;
    DLL_CSS_LGD_IDX_CB_CA410_MEASURE   = 11;
    DLL_CSS_LGD_IDX_CB_LOG             = 12;
    DLL_CSS_LGD_IDX_CB_RESULT          = 13;
    DLL_CSS_LGD_IDX_CB_POWER_MEASURE   = 14;
    DLL_CSS_LGD_IDX_CB_APDR_DATA       = 15;

    // For IDX_CB_RETURN_STR Items.
    DLL_CSS_LGD_IDX_GET_PCHK_Recv     = 1;
    DLL_CSS_LGD_IDX_GET_PANEL_ID      = 2;
    DLL_CSS_LGD_IDX_GET_SOURCE_PCBID  = 3;
    DLL_CSS_LGD_IDX_GET_CTL_PCBID     = 4;
    DLL_CSS_LGD_IDX_GET_SERIALNO      = 5;
    DLL_CSS_LGD_IDX_GET_MACHINE_ID    = 6;
    DLL_CSS_LGD_IDX_GET_MAIN_GUI_VER  = 7;
    DLL_CSS_LGD_IDX_GET_SCRIPT_VER    = 8;
    DLL_CSS_LGD_IDX_GET_FW_VER        = 9;
    DLL_CSS_LGD_IDX_GET_HW_VER        = 10;
    DLL_CSS_LGD_IDX_GET_SUMMARY_DATA_VENDER = 11;

    //for CA 410 items. --- IDX_CB_RETURN_INT
    DLL_CSS_LGD_IDX_GET_CA410_SYNC     = 1;
    DLL_CSS_LGD_IDX_GET_CA410_SPEED    = 2;
    DLL_CSS_LGD_IDX_GET_CA410_MEM_CH   = 3;
    DLL_CSS_LGD_IDX_SET_CA410_SYNC     = 4;
    DLL_CSS_LGD_IDX_SET_CA410_SPEED    = 5;
    DLL_CSS_LGD_IDX_SET_CA410_MEM_CH   = 6;
    DLL_CSS_LGD_IDX_SET_PG_POWER_ON    = 7;
    DLL_CSS_LGD_IDX_SET_PG_POWER_OFF   = 8;
    DLL_CSS_LGD_IDX_GET_TCON_REG       = 10;
    DLL_CSS_LGD_IDX_SET_TCON_REG       = 11;
    DLL_CSS_LGD_IDX_DLL_WORK_DONE      = 20;

type

  TIdDouble = array of Double;

  PGuiLgdCssAuto = ^RGuiLgdCssAuto;
  RGuiLgdCssAuto = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    nParam  : Integer;
    Msg     : string;
  end;

  TPathInfoDae = record
    MLogFile      :  string;
    MLogPath      : string;
    SLogFile      : string;
    SummaryLogPath  : string;
    ModelName     : string;
    ModelPath     : string;
  end;

  PCssCaMeasure = ^TCssCaMeasure;
  TCssCaMeasure = packed record
    x, y, u, v, deltaXy, deltaUv, Lv : double;
    Ret : Integer;
  end;

  PCssCsCommValue = ^TCssCsCommValue;
  TCssCsCommValue = packed record
    Ret, Len : Integer;
    nData    : Integer;
    pData    : PAnsiChar;
  end;
  TCssCsOpticalSummaryGroup = Packed record
    HeaderRow1  : PAnsiChar;
    HeaderRow2  : PAnsiChar;
    HeaderRow3  : PAnsiChar;
  end;

  TCssCsFileGroup = Packed record
    OnlineMode     : Integer;
    Param1         : Integer;
    Param2         : Integer;
    PanelID        : AnsiString;// PAnsiChar;
    SPcbId         : AnsiString;//PAnsiChar;
    SWModelFolderName : AnsiString;
    SpecFileFolderPath : AnsiString;
  end;

  TCssCsFileGroupBuff = record
    PanelID        : string[240];
    SPcbId         : string[240];
    SWModelFolderName : string[255];
    SpecFileFolderPath : string[255];
  end;

  PCssPowerRawData = ^TCssPowerRawData;
  TCssPowerRawData = packed record
    Vcc : Double;
    Icc : Double;
    Vdd : Double;
    Idd : Double;
    ElVdd : Double;
    ElIdd : Double;
  end;

  TDllCssCbCaMeasure   = procedure(nProbeNo : Integer; var a : TCssCaMeasure) of object;
  TDllCssCbPwrMeasure  = procedure(var a : TCssPowerRawData) of object;
  TDllCssCbI2c         = procedure (bIsWrite : Boolean; btDeviceAddr : byte; nType, address, nLen : Integer; data : TIdBytes;  var nRet : Integer; var RetData : TIdBytes ) of object;
  TDllCssCallBackFunc4 = procedure (nCh : Integer; nColor : Integer; sLog : string  ) of object;
  TDllCssCbRetInt      = procedure (Idx, param : Integer; var nRet : Integer  ) of object;
  TDllCssCbRetStr      = procedure (Idx, param : Integer; var sRet : string  ) of object;
  TDllCssCbSetInt      = procedure (Idx, param1, param2 : Integer  ) of object;
  TDllCssCbResult      = procedure (Idx, param : Integer; sRet : string  ) of object;

  TDllCssCb_Log        = procedure (nCh : Integer; nColor : Integer; sLog : PAnsichar  ) of object;
  TDllCssCb_QspiErase  = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer) of object;
  TDllCssCb_QspiRead   = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer; var RetData : TIdBytes) of object;
  TDllCssCb_QspiWrite  = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer; Data : TIdBytes) of object;

  TCssAutoData = record
    GetPchkRev    : string;
    PanelID       : string;
    SourcePCBID   : string;
    ControlPCBID  : string;

    SerialNumberID  : string;
    MachineID       : string;
    MainUIVersion   : string;
    ScriptVersion   : string;
    FirmwareVersion : string;

    sEmNo           : string;

    PathModel       : string;
    PathConverdll   : string;
    PathCurModel    : string;
    PathLog         : string;
    PathMlog        : string;
    PathSummaryLog  : string;
  end;


  TCssLgdDll = class(TObject)
  private
    FhDll    : THandle;
    FhMain   : HWND;
    FhTest   : HWND;

    FMsgType                : Integer;
    FIsDllLoadCheck         : Boolean;
    FCssAutoData            : array[0 .. DLL_CSS_LGD_MAX_CH_NO ] of TCssAutoData;
    // DLl 내부적으로 만 선언. - 호출 function.


    FCssLgdDll_InitDllPath    : function(sMainFolder : PAnsiChar): Integer; cdecl;
    FCssLgdDll_FreeDllPath    : procedure  cdecl;
    FCssLgdDll_FormDestroy    : procedure  cdecl;
    FCssLgdDll_DllTesterStart : procedure (nCh : Integer); cdecl;


    FCssLgdDll_GetDllVer      : function : PAnsiChar; cdecl;
    FCssLgdDll_CallBackFunc   : procedure (nCh, nIdx : Integer; callbackFunc : Pointer ); cdecl;
    FCssLgdDll_InitialDll     : function( MaxChCnt : Integer; sModelName : PAnsiChar ) : Integer; cdecl;
    FCssLgdDll_GetOcStatus   : function( nCh : Integer) : Integer; cdecl;
//    FCssLgdDll_SetModelPath   : procedure (nCh : Integer; ModelName : PAnsiChar; ModelPath : PAnsiChar ); cdecl;

//    FCssLgdDll_SetModelName   : procedure (nCh : Integer; dllName : PAnsiChar; ModelPath : PAnsiChar ); cdecl;
//    FCssLgdDll_SetMLogPath    : procedure (nCh : Integer; MLogPath : PAnsiChar; sLogFileName : PAnsiChar ); cdecl;
//    FCssLgdDll_SetSummaryLog  : procedure (nCh : Integer; SummaryLogPath : PAnsiChar; sLogFileName : PAnsiChar ); cdecl;
    FCssLgdDll_StartOc        : procedure (nCh : Integer; sData : PAnsiChar; dTemp : Double); cdecl;
    FCssLgdDll_FinalWork      : procedure (nCh : Integer); cdecl;
    FCssLgdDll_StartVerify    : procedure (nCh : Integer; dTemp : Double); cdecl;
    FCssLgdDll_StopOc         : procedure (nCh : Integer); cdecl;

    DllCssCb_Log          : array [0 .. DllLgdCssTls.DLL_CSS_LGD_MAX_CH_NO] of  TDllCssCb_Log;
    FOnCa410Event: TDllCssCbCaMeasure;
    FOnRetIntEvent: TDllCssCbRetInt;
    FOnSetIntEvent: TDllCssCbSetInt;
    FonQspiErase: TDllCssCb_QspiErase;
    FOnPwrEvent: TDllCssCbPwrMeasure;
    FOnRetStrEvent: TDllCssCbRetStr;
    FonQspiRead: TDllCssCb_QspiRead;
    FOnLogEvent: TDllCssCallBackFunc4;
    FonQspiWrite: TDllCssCb_QspiWrite;
    FOnI2cEvent: TDllCssCbI2c;
    FonResultEvent: TDllCssCbResult;


//    FCssLgdDll_SetModelName   : procedure (nCh : Integer; dllName : PAnsiChar; ModelPath : PAnsiChar ); cdecl;
//    FCssLgdDll_SetMLogPath    : procedure (MLogPath : PAnsiChar; sLogFileName : PAnsiChar ); cdecl;
//    FCssLgdDll_SetSummaryLog  : procedure (SummaryLogPath : PAnsiChar; sLogFileName : PAnsiChar ); cdecl;


    procedure SetCssAutoData(Channel: Integer; const Value: TCssAutoData);
    function GetCssAutoData(Channel: Integer): TCssAutoData;
    procedure SetFunction;
    procedure CheckDir(sPath: string);
    procedure SendTestGuiDisplay(nGuiMode : Integer;nCh, nParam: Integer ; sMsg : string = '');
    procedure LogM(nCh : Integer; sLog : string);

    procedure SethMain(const Value: HWND);
    procedure SethTest(const Value: HWND);
    procedure SetOnCa410Event(const Value: TDllCssCbCaMeasure);
    procedure SetOnI2cEvent(const Value: TDllCssCbI2c);
    procedure SetOnLogEvent(const Value: TDllCssCallBackFunc4);
    procedure SetOnPwrEvent(const Value: TDllCssCbPwrMeasure);
    procedure SetonQspiErase(const Value: TDllCssCb_QspiErase);
    procedure SetonQspiRead(const Value: TDllCssCb_QspiRead);
    procedure SetonQspiWrite(const Value: TDllCssCb_QspiWrite);
    procedure SetOnRetIntEvent(const Value: TDllCssCbRetInt);
    procedure SetOnRetStrEvent(const Value: TDllCssCbRetStr);
    procedure SetOnSetIntEvent(const Value: TDllCssCbSetInt);
    procedure SetonResultEvent(const Value: TDllCssCbResult);
  public
    PathInfo:  array [0 .. DllLgdCssTls.DLL_CSS_LGD_MAX_CH_NO] of  TPathInfoDae;
    QspiReadData : array[0 .. DLL_CSS_LGD_MAX_CH_NO] of TIdBytes;

    constructor Create(hMain, hTest: HWND;nMsgType : integer; sDllFileName : string); virtual;
    destructor Destroy; override;
    procedure Initialize(sModelType : string);
    function GetDllVer : string;
    procedure SetModelName(nCh : Integer; sModelName, sDllName, sModelPath : string);
    procedure showLog(nCh, nParam: Integer ; sMsg : string);
    procedure SendApdrData(nCh, nParam: Integer ; sMsg : string);
    procedure StartOc (nCh : Integer;sData : string; dTemp : Double);
    procedure FinalWork(nCh : Integer);
    function GetOcStatus(nch : Integer) : Integer;
    procedure StartVerify (nCh : Integer; dTemp : Double);
    procedure StopOc  ( nCh : Integer);
    property CssAutoData[Channel : Integer] : TCssAutoData read GetCssAutoData write SetCssAutoData;

    property hMain : HWND read FhMain write SethMain;
    property hTest : HWND read FhTest write SethTest;

    property OnCa410Event : TDllCssCbCaMeasure read FOnCa410Event write SetOnCa410Event;
    property OnPwrEvent   : TDllCssCbPwrMeasure read FOnPwrEvent write SetOnPwrEvent;
    property OnI2cEvent   : TDllCssCbI2c read FOnI2cEvent write SetOnI2cEvent;
    property OnLogEvent   : TDllCssCallBackFunc4 read FOnLogEvent write SetOnLogEvent;
    property OnRetIntEvent : TDllCssCbRetInt read FOnRetIntEvent write SetOnRetIntEvent;
    property OnRetStrEvent : TDllCssCbRetStr read FOnRetStrEvent write SetOnRetStrEvent;
    property OnSetIntEvent : TDllCssCbSetInt read FOnSetIntEvent write SetOnSetIntEvent;
    property onQspiErase  : TDllCssCb_QspiErase read FonQspiErase write SetonQspiErase;
    property onQspiRead   : TDllCssCb_QspiRead read FonQspiRead write SetonQspiRead;
    property onQspiWrite  : TDllCssCb_QspiWrite read FonQspiWrite write SetonQspiWrite;
    property onResultEvent : TDllCssCbResult read FonResultEvent write SetonResultEvent;
  end;

  procedure CssLgdDllCB_WriteDataI2C(nCh, nType, nAddress, nLen : Integer; btDeviceAddr : Integer; Bytes: TIdBytes  ) ; cdecl;
  procedure CssLgdDllCB_ReadDataI2c (nCh, nType, nAddress, nLen : Integer; btDeviceAddr : Integer;  var retBytes: TIdBytes ) ; cdecl;
  procedure CssLgdDllCB_WriteDataSpi(nCh, nType, nAddress, nLen, TimeOut : Integer; var nRet : Integer; Bytes: PByte) ; cdecl;
  procedure CssLgdDllCB_ReadDataSpi (nCh, nType, nAddress, nLen, TimeOut : Integer; var nRet : Integer; retBytes : PByte  ) ; cdecl;
  procedure CssLgdDllCB_EraseDataSpi(nCh, nType, nAddress, nLen, TimeOut : Integer ; var nRet : Integer ) ; cdecl;
  procedure CssLgdDllCB_RetStr (nCh, nIdx, nParam : integer; out sRet : PAnsiChar  ); cdecl;
  procedure CssLgdDllCB_RetBool(nCh, nIdx, nParam : integer; out bRet : BOOL  ); cdecl;
  procedure CssLgdDllCB_RetInt (nCh, nIdx, nParam : integer; out nRet : Integer ); cdecl;
  procedure CssLgdDllCB_SetInt (nCh, nIdx, nParam1, nParam2 : integer); cdecl;
  procedure CssLgdDllCB_RetDoub(nCh, nIdx, nParam : integer; out dRet : double  ); cdecl;
  procedure CssLgdDllCB_Result (nCh, nIdx, nParam : integer; sRet : PAnsiChar  ); cdecl;

  procedure CssLgdDllCB_Ca410_Measure(nCh, nProbe : Integer; var x, y, Lv : double; var dRet : Integer  ); cdecl;
  procedure CssLgdDllCB_Show_Log(nCh : Integer; nColor : Integer; sLog : PAnsichar  );  cdecl;
  procedure CssLgdDllCB_Show_Log2(nCh : Integer; nColor : Integer; sLog : PAnsichar  ); cdecl;
  procedure CssLgdDllCB_Show_Apdr(nCh : Integer; nColor : Integer; sLog : PAnsichar  );  cdecl;
  procedure CssLgdDllCB_Show_Apdr2(nCh : Integer; nColor : Integer; sLog : PAnsichar  ); cdecl;

  procedure CssLgdDllCB_Power_Measure(nCh : Integer; var params : TArray<double>; var dRet : integer  ); cdecl;
  procedure CssLgdDllCB_Power_Measure2(nCh : Integer; var params : TArray<double>; var dRet : integer  ); cdecl;
var
  CssLgdDll : TCssLgdDll;
  //LgdDllSub     : array[0 .. Dll_LgdCssTls.DLL_CSS_LGD_MAX_CH_NO] of TCssAutoLgdDllSub;

implementation

{ TCssAutoLgdDll }

procedure TCssLgdDll.CheckDir(sPath: string);
begin
  if not DirectoryExists(sPath) then begin
    if not CreateDir(sPath) then begin
      MessageDlg(#13#10 + 'Cannot make the Path('+sPath+')!!!', mtError, [mbOk], 0);
    end;
  end;
end;

constructor TCssLgdDll.Create(hMain, hTest: HWND; nMsgType : integer; sDllFileName : string);
var
  i: Integer;
  sFileName, sNGMessage, sPath : string;
begin
  FhMain := hMain; FhTest := hTest;
  FMsgType := nMsgType;
//  for i := 0 to Dll_LgdCssTls.DLL_CSS_LGD_MAX_CH_NO do begin
////    LgdDllSub[i]     := TCssAutoLgdDllSub.Create(nMsgType,hMain, hTest);
//    FCssAutoData[i].sEmNo               := '';
//    FCssAutoData[i].GetPchkRev          := '';
//    FCssAutoData[i].PanelID             := '';
//    FCssAutoData[i].SourcePCBID         := '';
//    FCssAutoData[i].ControlPCBID        := '';
//    FCssAutoData[i].SerialNumberID      := '';
//    FCssAutoData[i].MachineID           := '';
//    FCssAutoData[i].MainUIVersion       := '';
//    FCssAutoData[i].ScriptVersion       := '';
//    FCssAutoData[i].FirmwareVersion     := '';
//
//    FCssAutoData[i].PathModel           := '';
//    FCssAutoData[i].PathConverdll       := '';
//    FCssAutoData[i].PathCurModel        := '';
//    FCssAutoData[i].PathLog             := '';
//    FCssAutoData[i].PathMlog            := '';
//    FCssAutoData[i].PathSummaryLog      := '';
//  end;
//  sFileName := '';
//  case nDllType of
//    2 :  sFileName := ExtractFilePath(Application.ExeName) + DLL_CSS_LGD_CONVETER_PATH + sDllFileName;
//    3 :  sFileName := ExtractFilePath(Application.ExeName) + DLL_CSS_LGD_IT_GA_CONVETER_PATH + sDllFileName;
//  end;
  sFileName := ExtractFilePath(Application.ExeName) + DLL_CSS_LGD_TLS_PATH + sDllFileName;
  if FileExists(sFileName) then FhDll := LoadLibrary(PChar(sFileName))
  else                          sNGMessage := '[' + sFileName + ']' + #13#10 + ' Cannot find the file.!';
  if FhDll <> 0 then begin
    sNGMessage := ' loadlibrary returns 0';
    FIsDllLoadCheck := true;
  end;

  SetFunction;

  sPath := ExtractFilePath(Application.ExeName) + DLL_CSS_LGD_TLS_PATH;
  FCssLgdDll_InitDllPath(PAnsiChar(AnsiString(sPath)));
  for i := 0 to DLL_CSS_LGD_MAX_CH_NO do begin
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_WRTIE_DATA,       @CssLgdDllCB_WriteDataI2C);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_READ_DATA,        @CssLgdDllCB_ReadDataI2c);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_WRTIE_DATA_SPI,   @CssLgdDllCB_WriteDataSpi);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_READ_DATA_SPI,    @CssLgdDllCB_ReadDataSpi);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_ERASE_DATA_SPI,   @CssLgdDllCB_EraseDataSpi);

    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_RETURN_STR,       @CssLgdDllCB_RetStr);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_RETURN_INT,       @CssLgdDllCB_RetInt);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_RETURN_BOOL,      @CssLgdDllCB_RetBool);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_RETURN_DOUBLE,    @CssLgdDllCB_RetDoub);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_CA410_MEASURE,    @CssLgdDllCB_Ca410_Measure);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_LOG,              @CssLgdDllCB_Show_Log);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_POWER_MEASURE,    @CssLgdDllCB_Power_Measure);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_SET_INT,          @CssLgdDllCB_SetInt);
    FCssLgdDll_CallBackFunc(i,DLL_CSS_LGD_IDX_CB_RESULT,           @CssLgdDllCB_Result);


  end;
end;

destructor TCssLgdDll.Destroy;
var
  i : Integer;
begin
  FCssLgdDll_FormDestroy;
  FCssLgdDll_FreeDllPath;
//  for i := 0 to DLL_CSS_LGD_MAX_CH_NO do begin
//    if LgdDllSub[i] <> nil then begin
//      LgdDllSub[i].Free;
//      LgdDllSub[i] := nil;
//    end;
//  end;

  //FreeLibrary(FhDll);
  inherited;
end;

procedure TCssLgdDll.FinalWork(nCh: Integer);
begin
  FCssLgdDll_FinalWork(nCh);
end;

function TCssLgdDll.GetCssAutoData(Channel: Integer): TCssAutoData;
begin
  Result := FCssAutoData[Channel];
end;

function TCssLgdDll.GetDllVer: string;
begin
  result := StrPas(FCssLgdDll_GetDllVer);
end;

function TCssLgdDll.GetOcStatus(nch: Integer): Integer;
begin
  Result := FCssLgdDll_GetOcStatus(nCh);
end;

procedure TCssLgdDll.Initialize(sModelType : string);
var
  i : Integer;
  sPath : AnsiString;
begin
  sPath :=  AnsiString(ExtractFilePath(Application.ExeName) + DLL_CSS_LGD_TLS_PATH);
  try
    FCssLgdDll_InitialDll(DLL_CSS_LGD_MAX_CH,PAnsiChar(AnsiString(sModelType)));
  except
    on E : Exception do begin
      ShowMessage(E.Message);
    end;
  end;

end;

procedure TCssLgdDll.LogM(nCh: Integer; sLog: string);
var
  _infile : array[0 ..  DLL_CSS_LGD_MAX_CH_NO] of TextFile;
  sFileName, sDate, sFilePath, sInputData: String;
begin

  sFileName := ExtractFilePath(Application.ExeName) + Format('MLog_%s_Ch%d.txt',[sDate,nCh + 1]);
  try
    try
      AssignFile(_infile[nCh], sFileName);
      if not FileExists(sFileName) then
        Rewrite(_infile[nCh])
      else
        Append(_infile[nCh]);
      try
        sInputData := FormatDateTime('(hh:mm:ss.zzz) : ', now) + sLog;//Format('Main : %0.8x, Test : %0.8x :',[FhMain, FhTest])+ FormatDateTime('(hh:mm:ss.zzz) : ', now) + sLog;
        WriteLn(_infile[nCh], sInputData);
      except
        on E: Exception do begin
          ShowMessage(E.Message);
        end;
      end;

    except
    end;
  finally
    CloseFile(_infile[nCh]);
  end;
end;

procedure TCssLgdDll.SendApdrData(nCh, nParam: Integer; sMsg: string);
begin
  if not (nCh in [0,1]) then Exit;
  Self.SendTestGuiDisplay(DllLgdCssTls.DLL_CSS_LGD_IDX_CB_APDR_DATA, nCh, nParam, sMsg);
end;

procedure TCssLgdDll.SendTestGuiDisplay(nGuiMode, nCh, nParam: Integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  GuiData     : RGuiLgdCssAuto;
begin
  GuiData.MsgType := FMsgType;
  GuiData.Channel := nCh ;
  GuiData.Mode    := nGuiMode;
  GuiData.nParam  := nParam;
  GuiData.Msg     := sMsg;
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(GuiData);
  ccd.lpData      := @GuiData;
  SendMessage(FhTest,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TCssLgdDll.SetCssAutoData(Channel : Integer; const Value: TCssAutoData);
begin
  FCssAutoData[Channel] := Value;
end;

procedure TCssLgdDll.SetFunction;
var
  sEqpNo : AnsiString;
  nVer, i : Integer;
begin

  @FCssLgdDll_InitDllPath     := GetProcAddress(FhDll, 'DLL_Directory_Init');
  @FCssLgdDll_FreeDllPath     := GetProcAddress(FhDll, 'DLL_Directory_UnInit');

  @FCssLgdDll_FormDestroy     := GetProcAddress(FhDll, 'FormDestroy');
  @FCssLgdDll_InitialDll      := GetProcAddress(FhDll, 'Initialize');
  @FCssLgdDll_GetDllVer       := GetProcAddress(FhDll, 'GetDllversion');
  @FCssLgdDll_GetOcStatus     := GetProcAddress(FhDll, 'ThreadStateCheck');
  @FCssLgdDll_CallBackFunc    := GetProcAddress(FhDll, 'SetCallBackFunction');


  @FCssLgdDll_FinalWork       := GetProcAddress(FhDll, 'MainTls_FinalWork');

  @FCssLgdDll_StartOc         := GetProcAddress(FhDll, 'MainTls_Start');
  @FCssLgdDll_StartVerify     := GetProcAddress(FhDll, 'MainTls_Verify');
  @FCssLgdDll_StopOc          := GetProcAddress(FhDll, 'MainTls_STOP');
end;


procedure TCssLgdDll.SethMain(const Value: HWND);
begin
  FhMain := Value;
end;

procedure TCssLgdDll.SethTest(const Value: HWND);
begin
  FhTest := Value;
end;

procedure TCssLgdDll.SetModelName(nCh: Integer; sModelName, sDllName, sModelPath: string);
begin
//  FCssLgdDll_SetModelName(nCh, PAnsiChar(AnsiString(sDllName)), PAnsiChar(AnsiString(sModelPath)));
end;

procedure TCssLgdDll.SetOnCa410Event(const Value: TDllCssCbCaMeasure);
begin
  FOnCa410Event := Value;
end;

procedure TCssLgdDll.SetOnI2cEvent(const Value: TDllCssCbI2c);
begin
  FOnI2cEvent := Value;
end;

procedure TCssLgdDll.SetOnLogEvent(const Value: TDllCssCallBackFunc4);
begin
  FOnLogEvent := Value;
end;

procedure TCssLgdDll.SetOnPwrEvent(const Value: TDllCssCbPwrMeasure);
begin
  FOnPwrEvent := Value;
end;

procedure TCssLgdDll.SetonQspiErase(const Value: TDllCssCb_QspiErase);
begin
  FonQspiErase := Value;
end;

procedure TCssLgdDll.SetonQspiRead(const Value: TDllCssCb_QspiRead);
begin
  FonQspiRead := Value;
end;

procedure TCssLgdDll.SetonQspiWrite(const Value: TDllCssCb_QspiWrite);
begin
  FonQspiWrite := Value;
end;

procedure TCssLgdDll.SetonResultEvent(const Value: TDllCssCbResult);
begin
  FonResultEvent := Value;
end;

procedure TCssLgdDll.SetOnRetIntEvent(const Value: TDllCssCbRetInt);
begin
  FOnRetIntEvent := Value;
end;

procedure TCssLgdDll.SetOnRetStrEvent(const Value: TDllCssCbRetStr);
begin
  FOnRetStrEvent := Value;
end;

procedure TCssLgdDll.SetOnSetIntEvent(const Value: TDllCssCbSetInt);
begin
  FOnSetIntEvent := Value;
end;

procedure TCssLgdDll.showLog(nCh, nParam: Integer; sMsg: string);
begin
  if not (nCh in [0,1]) then Exit;
  //DisplayLog(nCh,nParam,sMsg);
//  LogM(nCh,sMsg);
//  if Pos('channel :',sMsg) > 0 then begin
//    DisplayLog(nCh,nParam,sMsg);
//    LogM(nCh,sMsg);
//  end;
  Self.SendTestGuiDisplay(DllLgdCssTls.DLL_CSS_LGD_MODE_LOG, nCh, nParam, sMsg);
end;

procedure TCssLgdDll.StartOc(nCh : Integer;sData : string; dTemp : Double);
begin
  FCssLgdDll_StartOc(nCh,PAnsiChar(AnsiString(sData)), dTemp);
  //FCssLgdDll_DllTesterStart(nCh);
end;

procedure TCssLgdDll.StartVerify(nCh: Integer; dTemp: Double);
begin
  FCssLgdDll_StartVerify(nCh,dTemp);
end;

procedure TCssLgdDll.StopOc(nCh: Integer);
begin
  FCssLgdDll_StopOc(nCh);
end;

procedure CssLgdDllCB_WriteDataI2C(nCh, nType, nAddress, nLen : Integer;btDeviceAddr : integer; Bytes: TIdBytes  ) ; cdecl;
var
  buf : TIdBytes;
  nRet : Integer;
begin
  SetLength(buf,nLen);// 함수 두개 만들기 귀찮아서...
  CssLgdDll.OnI2cEvent(True, Byte(btDeviceAddr), nType, nAddress, nLen, Bytes,nRet, buf);
  //LgdDllSub[nCh].OnI2cEvent(nCh, Bytes, nLen
  //=> Callback_Functions.cbWriteData[Channel](Channel, ((int)type), address, size, parameters);
end;
procedure CssLgdDllCB_ReadDataI2c (nCh, nType, nAddress, nLen : Integer; btDeviceAddr : integer; var retBytes: TIdBytes ) ; cdecl;
var
  nRet : Integer;
  buf : TIdBytes;
begin
  SetLength(buf,nLen);// 함수 두개 만들기 귀찮아서..
  CssLgdDll.OnI2cEvent(False,byte(btDeviceAddr),nType, nAddress, nLen, buf,nRet, retBytes);
end;
procedure CssLgdDllCB_WriteDataSpi(nCh, nType, nAddress, nLen, TimeOut : Integer; var nRet : Integer ; Bytes: PByte ) ; cdecl;
var
  buf : TIdBytes;
begin
  SetLength(buf,nLen);
  CopyMemory(@buf[0],Bytes,nLen);
  CssLgdDll.onQspiWrite(  nType, nAddress, nLen, TimeOut, nRet,buf);
end;
procedure CssLgdDllCB_ReadDataSpi (nCh, nType, nAddress, nLen, TimeOut : Integer; var nRet : Integer; retBytes : PByte  ) ; cdecl;
begin
  SetLength(CssLgdDll.QspiReadData[nCh],nLen);
  CssLgdDll.onQspiRead(nType, nAddress, nLen, TimeOut, nRet,CssLgdDll.QspiReadData[nCh]);
  CopyMemory(retBytes,@CssLgdDll.QspiReadData[nCh][0],nLen);
end;
procedure CssLgdDllCB_EraseDataSpi(nCh, nType, nAddress, nLen , TimeOut: Integer ; var nRet : Integer  ) ; cdecl;
begin
  CssLgdDll.onQspiErase(nType, nAddress, nLen , TimeOut, nRet );
end;
//  TDllCssCb_QspiErase  = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer) of object;
//  TDllCssCb_QspiRead   = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer; var RetData : TIdBytes) of object;
//  TDllCssCb_QspiWrite  = procedure (nType,address, nLen, nTimeOut : Integer;var nRet : Integer; Data : TIdBytes) of object;

procedure CssLgdDllCB_RetStr (nCh, nIdx, nParam : integer; out sRet : PAnsiChar  ); //cdecl;
var
  sRetData : string;
begin
  sRetData := '';
//  case nIdx of
//    DLL_CSS_LGD_IDX_GET_PCHK_Recv     : sRetData := CssAutoLgdDll.CssAutoData[nCh].GetPchkRev;
//    DLL_CSS_LGD_IDX_GET_PANEL_ID      : sRetData := CssAutoLgdDll.CssAutoData[nCh].PanelID;
//    DLL_CSS_LGD_IDX_GET_SOURCE_PCBID  : sRetData := CssAutoLgdDll.CssAutoData[nCh].SourcePCBID;
//    DLL_CSS_LGD_IDX_GET_CTL_PCBID     : sRetData := CssAutoLgdDll.CssAutoData[nCh].ControlPCBID;
//    DLL_CSS_LGD_IDX_GET_SERIALNO      : sRetData := CssAutoLgdDll.CssAutoData[nCh].SerialNumberID;
//    DLL_CSS_LGD_IDX_GET_MACHINE_ID    : sRetData := CssAutoLgdDll.CssAutoData[nCh].MachineID;
//    DLL_CSS_LGD_IDX_GET_MAIN_GUI_VER  : sRetData := CssAutoLgdDll.CssAutoData[nCh].MainUIVersion;
//    DLL_CSS_LGD_IDX_GET_SCRIPT_VER    : sRetData := CssAutoLgdDll.CssAutoData[nCh].ScriptVersion;
//    DLL_CSS_LGD_IDX_GET_FW_VER        : sRetData := CssAutoLgdDll.CssAutoData[nCh].FirmwareVersion;
//    DLL_CSS_LGD_IDX_GET_HW_VER        : sRetData := CssAutoLgdDll.CssAutoData[nCh].sEmNo;
//  end;
  CssLgdDll.OnRetStrEvent(nIdx, nParam,sRetData);

  sRet := PAnsiChar(AnsiString(sRetData));
end;
procedure CssLgdDllCB_RetBool(nCh, nIdx, nParam : integer; out bRet : BOOL  ); cdecl;
begin

end;
procedure CssLgdDllCB_RetInt (nCh, nIdx, nParam : integer; out nRet : Integer ); cdecl;
begin
  CssLgdDll.OnRetIntEvent(nIdx, nParam,nRet);

end;

procedure CssLgdDllCB_SetInt (nCh, nIdx, nParam1, nParam2 : integer); cdecl;
begin
  CssLgdDll.OnSetIntEvent(nIdx,  nParam1, nParam2 );
end;

procedure CssLgdDllCB_RetDoub(nCh, nIdx, nParam : integer; out dRet : double  ); cdecl;
begin

end;

procedure CssLgdDllCB_Result (nCh, nIdx, nParam : integer; sRet : PAnsiChar  ); cdecl;
begin
  CssLgdDll.onResultEvent( nIdx, nParam, StrPas(sRet));
end;


procedure CssLgdDllCB_Ca410_Measure(nCh, nProbe : Integer; var x, y, Lv : double; var dRet : Integer  ); cdecl;
var
  data : TCssCaMeasure;
begin
  CssLgdDll.OnCa410Event(nProbe,data);
  x := data.x;
  y := data.y;
  Lv := data.Lv;
  dRet := data.Ret;
end;

procedure CssLgdDllCB_Show_Log(nCh : Integer; nColor : Integer; sLog : PAnsichar  ); cdecl;
var
  sDebug : string;
begin
  sDebug := StrPas(sLog);
  CssLgdDll.showLog( nCh, nColor, sDebug);
  //LgdDllSub[nCh].OnLogEvent(nCh, nColor, sDebug);
end;
procedure CssLgdDllCB_Show_Log2(nCh : Integer; nColor : Integer; sLog : PAnsichar  ); cdecl;
var
  sDebug : string;
begin
  sDebug := StrPas(sLog);
  CssLgdDll.showLog(nCh, nColor, sDebug);
  //LgdDllSub[nCh].SendLogFile(nCh, nColor, sDebug);
  //LgdDllSub[nCh].OnLogEvent(nCh, nColor, sDebug);
end;

procedure CssLgdDllCB_Show_Apdr(nCh : Integer; nColor : Integer; sLog : PAnsichar  );  cdecl;
var
  sDebug : string;
begin
  sDebug := StrPas(sLog);
  CssLgdDll.showLog( nCh, nColor, sDebug);
  //LgdDllSub[nCh].OnLogEvent(nCh, nColor, sDebug);
end;
procedure CssLgdDllCB_Show_Apdr2(nCh : Integer; nColor : Integer; sLog : PAnsichar  ); cdecl;
var
  sDebug : string;
begin
  sDebug := StrPas(sLog);
  CssLgdDll.showLog( nCh, nColor, sDebug);
  //LgdDllSub[nCh].OnLogEvent(nCh, nColor, sDebug);
end;

procedure CssLgdDllCB_Power_Measure(nCh : Integer; var params : TArray<double>; var dRet : integer  ); cdecl;
var
  data : TCssPowerRawData;
begin
  CssLgdDll.OnPwrEvent(data);
//  SetLength(params,10);
  params[0] := data.Vcc;
  params[1] := data.Icc;
  params[2] := data.Vdd;
  params[3] := data.Idd;
  params[4] := data.ElVdd;
  params[5] := data.ElIdd;
end;

procedure CssLgdDllCB_Power_Measure2(nCh : Integer; var params : TArray<double>; var dRet : integer  ); cdecl;
var
  data : TCssPowerRawData;
begin
  CssLgdDll.OnPwrEvent(data);
//  SetLength(params,10);
  params[0] := data.Vcc;
  params[1] := data.Icc;
  params[2] := data.Vdd;
  params[3] := data.Idd;
  params[4] := data.ElVdd;
  params[5] := data.ElIdd;
end;

{ TCssAutoLgdDllSub }

end.
