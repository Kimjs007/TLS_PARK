unit DllCasSdkCa410;

interface

uses
    System.SysUtils, Winapi.Windows, winapi.messages, Vcl.Dialogs, system.Classes, System.Math, Vcl.Forms, IdGlobal, Vcl.ExtCtrls;

const

{$IFDEF WIN64}

  CA_SDK2_DLL = '\driver\win64\CASDK2_DAE_64Bit_20230503.dll';
  //CA_SDK2_DLL = 'CASDK2_DAE.dll';
{$ELSE}
  // 32bit 최조 DLL.
  CA_SDK2_DLL = '\driver\win32\CASDK2_DAE_32bit_20230127.dll';
{$ENDIF}

//--------------------------- structure
type

  TDllCasdk_LvXYUV = record
    x       : Double;
    y       : Double;
    u       : Double;
    v       : Double;
    Lv      : Double;
    dUv     : Double;
    dXy     : Double;
  end;

  PSyncCa410 = ^RSyncCa410;
  RSyncCa410 = packed record
    MsgType : Integer;
    Channel	: Integer;
    MsgMode : Integer;
    nParam  : Integer;
    ProbeNo : Integer;
    bError  : Boolean;
    Msg     : string;
  end;

  TBrightValue = record
    xVal        : Double;
    yVal        : Double;
    LvVal       : Double;
    Flicker     : Double;
  end;

  TLvXYUV = record
    x       : Double;
    y       : Double;
    u       : Double;
    v       : Double;
    Lv      : Double;
    dUv     : Double;
    dXy     : Double;
  end;

  TCaSetupInfo  = record
    SelectIdx : Integer;
    Ca410Ch   : Integer;
    DeviceId  : Integer;
    SerialNo  : string;
  end;

  TLvXY = record
    x   : Double;
    y   : Double;
    Lv  : Double;
  end;
  TAllLvXy    = array[0 .. 3] of TLvXY;

  TCaSetupInfoList = record
    SetupList :  array [0.. 8] of TCaSetupInfo;  // Probe 9개 설정. 1Ch - 9 Probe.
  end;

  TDeviceInfo = record
    DeviceId    : Integer;    // Usb connected but Serial Port Number (COM5) - Device ID.
    SerialNo    : string;
    DllVer      : string;
  end;
//--------------------------- Class.
type
  TDllCaSdk2 = class(TObject)
  const
    CONNECT_NONE = 0;
    CONNECT_OK   = 1;
    CONNECT_NG   = 2;

    IDX_RED     = 0;
    IDX_GREEN   = 1;
    IDX_BLUE    = 2;
    IDX_WHITE   = 3;
    IDX_MAX     = 3;

    CH1         = 0;
    MAX_CH_CNT  = 3;
    MAX_CH      = MAX_CH_CNT-1;
    MAX_PROBE   = 9;

    CA410_LvXY  = 0;
    CA410_FLICK = 6;
    CA410_JEITA = 8;

    MSG_MODE_LOG                = 1;
    MSG_MODE_STATUS             = 2;
    MSG_MODE_CAX10_MEM_CH_NO    = 3;

    DISCONNECTION_CODE = 10000;
  private

    FhDll, FhCaSdk2, FhMain, FhTest : HWND;
    FIsDllLoadingOk: Boolean;
    FnMemCh, FnAutoMode, FnMsgType : Integer;

    FProbeFound_Count     : Integer;
    FProbeFount_Connected : array[CH1 .. pred(MAX_PROBE)] of Boolean;
    FCheckConnection      : array [CH1 .. pred(MAX_PROBE)] of Integer;

    tmrConnectCheck : TTimer;
    FIsScriptWorking: array[CH1 .. MAX_CH] of Boolean;
    FSetupCnt   : TCaSetupInfoList;
    FCurChannel: Integer;
(****************************************************************************)
(*          CASDK2 Functions Declarations                                   *)
(****************************************************************************)
    f_NewCaSdk2 : function : THandle ;cdecl;//stdcall;
    f_DeleteCaSdk2 : function(handel : THandle  ) : Integer ;cdecl;//stdcall;
    f_SetConfigration : function(handel :  THandle) : Integer; cdecl;
    f_GetDeviceCnt : function(handel :  THandle) : Integer; cdecl;
    f_GetProbeInfo : function(nCh : Integer; var nPortNo; var SerialNo : PAnsiChar  ) : Integer ;cdecl;//stdcall;
    f_GetDllVerInfo : function(var Version : PAnsiChar) : Integer ;cdecl;
    f_CalZero : function(nCh : Integer ) : Integer ;cdecl;
    f_Set_Measure : function(nCh : Integer ) : Integer ;cdecl;
    f_Get_sXylvVal : function(nCh : Integer; var xVal, yVal, LvVal : Double ) : Integer ;cdecl;
    f_Get_sUvlvVal : function(nCh : Integer; var u, v, Lv : Double ) : Integer ;cdecl;
    f_Get_sXyUvlvVal : function(nCh : Integer; var x, y, u, v, Lv, dUv : Double ) : Integer ;cdecl;
    f_GetErrorMessage : function(nErrCode : Integer ; ErrMessage : PWideChar ; var nSize ) : Integer ;cdecl;//stdcall;
//    f_Set_AvrMode : function(nCh : Integer) : Integer ;cdecl;
    f_Set_SyncMode : function(nCh : Integer; nSync : Integer; dFrea : Double; IntegTime : Integer) : Integer ;cdecl;
    f_Set_DefaultConnect : function(nCh : Integer; nMemCh : Integer; nAutoMode : Integer ) : Integer ;cdecl;
                       // for user calibration.
    f_Set_MemCh : function(nCh, nMemCh : Integer) : Integer ;cdecl;
    f_Get_MemCh : function(nCh : Integer; var nMemCh : Integer) : Integer; cdecl;
    f_InitMemCh : function(nCh : Integer; nMemCh : Integer) : Integer; cdecl;

    f_CalMeasure : function(nCh, nIdxRgb : Integer) : Integer ;cdecl;
    f_SetLvxy_CalData : function(nCh,nIdxRgb : Integer; x, y, Lv : Double) : Integer ;cdecl;
    f_MatrixCal_Update : function(nCh : Integer) : Integer ;cdecl;
    f_ResetLvCalMode : function(nCh : Integer) : Integer; cdecl;

    f_GetMemChData : function(nCh, nMemCh : Integer; var R_Lv, R_x, R_y, G_Lv, G_x, G_y, B_Lv, B_x, B_y, W_Lv, W_x, W_y : Double) : Integer; cdecl;
    f_UserCalReady : function(nCh, nTargetCh : Integer) : Integer; cdecl;
    f_UserCalMeasure : function(nCh, iColorType : Integer;var x, y, Lv : Double) : Integer; cdecl;
    f_VSync_CntSet : function( nCh, nFrame : Integer;  sRetMsg : PAnsiChar) : Integer; cdecl;
    f_CA_SetCommand : function( nCh : Integer; sCmd ,  sRetMsg : PAnsiChar) : Integer; cdecl;
    f_Get_Connect : function(nCh : Integer) : Integer; cdecl;

    f_Get_waveformData : function(nCh : Integer; waveform_T, waveformData : PDouble; measureAmount : Integer): Double; cdecl;
    f_Get_waveform_Data : function(nCh : Integer; waveform_T, waveformData : PDouble; waveformDataSize : Integer; measurementTime : Double): Double; cdecl;
    f_Measure_waveform : function(nCh, m_nSamplingNumber : Integer) : Integer; cdecl;
    f_Get_waveformDataSize : function(nCh ,m_nSamplingNumber: Integer) : Integer; cdecl;

    function GetCa410Status(nProbe : Integer) : Integer;
    procedure ShowMainForm(nMode, ProbeNo: Integer; bError: Boolean; sMsg: string; nParam : Integer = 1);
    procedure ShowTestForm(nMode, ProbeNo: Integer; bError: Boolean; sMsg: string; nParam : Integer = 1);
    procedure SetProbeFound_Count(const Value: Integer);
    function GetSetupPort(nIndex: Integer): TCaSetupInfo;
    procedure SetIsDllLoadingOk(const Value: Boolean);
    procedure SetSetupPort(nIndex: Integer; const Value: TCaSetupInfo);
    procedure SetFunction;
    procedure OnConnectEventTimer(Sender: TObject);
    procedure SetCurChannel(const Value: Integer);

  public
    IsScriptWorking  : array [0..pred(MAX_PROBE)] of Boolean;
    DeviceInfo : array of  TDeviceInfo;

    constructor Create(nMsgType, nPgNo: Integer; hMain, hTest: HWND; nMemCh: Integer = 0; bAuto : Boolean = True); virtual;
    destructor Destroy; override;

    function ManualConnect: Integer;
    function Measure(nCh : Integer; var MeasRet : TBrightValue) : Integer;
    function MeasureAllData(nCh : Integer; var MeasRet : TLvXYUV) : Integer;
    function MeasureData(nCh : Integer; var MeasRet : TLvXYUV) : Integer;
    function GetMemCh(nCh : Integer; var nMemCh : Integer) : Integer;
    function SetMemCh(nCh : Integer; nMemCh : Integer) : Integer;
    function SetDefaultMemCh(nCh : Integer; nMemCh : Integer) : Integer;

    function GetMemInfo(nCh, nMemCh : Integer;var R_Lv, R_x, R_y, G_Lv, G_x, G_y, B_Lv, B_x, B_y, W_Lv, W_x, W_y : Double) : Integer;
    function UsrCalReady(nCh, nMemCh : Integer) : Integer;
    function UsrCalMeasure(nCh, nColorType : Integer;var x, y , lv : Double) : Integer;
    function UsrCalSetCalData(nCh, nColorType : Integer; tX, tY, tLv : Double) : Integer;
    function set_CalZero(nCh: Integer) : Integer;
    function ResetCalMode(nCh : Integer) : Integer;
    function CasdkEnter(nCh : Integer) : Integer;
    function GetWaveformData(nChannel : integer; waveform_T, waveformData : PDouble; measureAmount : Integer): Double;
    function SetSyncMode(nCh : Integer; nSync : Integer; dFrea : Double; nIntegTime : Integer) : Integer ;
    function SetVsyncFrame(nCh, nFrame : Integer;var sRetMsg : PAnsiChar) : Integer;
    function SetCommandCa410(nCh : Integer;sCmd : PAnsiChar; var sRetMsg : PAnsiChar) : Integer;
    procedure CheckConnect(nCh : Integer);
    procedure CheckConnection(bEnable : Boolean);
    function GetConnProbe(nProbe : Integer) : Integer;
    property IsDllLoadingOk : Boolean read FIsDllLoadingOk write SetIsDllLoadingOk;
    property ProbeFound_Count : Integer read FProbeFound_Count write SetProbeFound_Count;
    property SetupPort[nIndex : Integer] : TCaSetupInfo read GetSetupPort write SetSetupPort;
    property CurChannel : Integer read FCurChannel write SetCurChannel;
  end;

var
  DllCaSdk2 : TDllCaSdk2;

implementation

{ TDllCaSdk2 }

function TDllCaSdk2.CasdkEnter(nCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_MatrixCal_Update(FSetupCnt.SetupList[nCh].Ca410Ch);
end;

procedure TDllCaSdk2.CheckConnect(nCh: Integer);
var
  nErr, nRet, nPort : integer;
  i, k, nGetMemCh: Integer;
  wdRet : DWORD;
  sErrMsg : string;
  bIsNg   : boolean;
  thCa    : TThread;
begin
  case FSetupCnt.SetupList[nCh].SelectIdx of
    TDllCaSdk2.CONNECT_NONE : begin
      ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh ,False,sErrMsg,0) ;
      FProbeFount_Connected[nCh] := False;
    end
    else begin
      if FProbeFound_Count <> 0 then begin
        bIsNg := True;
        for i := 0 to Pred(FProbeFound_Count) do begin
          if DeviceInfo[i].SerialNo = FSetupCnt.SetupList[nCh].SerialNo then begin
            bIsNg := False;
            FSetupCnt.SetupList[nCh].Ca410Ch := i;
            break;
          end;
        end;
        if bIsNg then begin
          sErrMsg := Format('Cannel %d CA410 Connection NG',[nCh+1]);
          ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh,True,sErrMsg);
          ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
          FProbeFount_Connected[nCh] := False;
        end
        else begin
          sErrMsg := '';
          ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh,False,sErrMsg);
          sErrMsg := 'CA410 Connect OK -------- Probe ' + nCh.ToString;
          ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,False,sErrMsg);
          FProbeFount_Connected[nCh] := True;

          // Init 쪽에 CA Command 추가하려니 Back ground와 출돌남. 피하기 위하여 순차적으로 하자.
          // In Case of ALL OK
//          thCa    := TThread.CreateAnonymousThread(procedure var k : Integer; begin
            // Script Log와 출동남 - 피하기 위하여 스크립트 끝나고 0 Cal
//            for k := 0 to 300 do begin
//              if not FIsScriptWorking[nCh] then break;
//              sleep(100);
//            end;
            f_CalZero(FSetupCnt.SetupList[nCh].Ca410Ch);
            sErrMsg := 'CA410 ZeroCal';
            ShowTestForm(TDllCaSdk2.MSG_MODE_LOG,nCh,False,sErrMsg);
            //f_Set_DefaultConnect(FSetupCnt.SetupList[nCh].Ca410Ch,FnMemCh,FnAutoMode);
            f_Set_DefaultConnect(FSetupCnt.SetupList[nCh].Ca410Ch,FnMemCh,FnAutoMode);
            sErrMsg := 'CA410 Default Set';
            ShowTestForm(TDllCaSdk2.MSG_MODE_LOG,nCh,False,sErrMsg);
            sErrMsg := 'CA410 Get Ca410 MemChannel.';
            ShowTestForm(TDllCaSdk2.MSG_MODE_LOG,nCh,False,sErrMsg);
            wdRet := GetMemCh(nCh,nGetMemCh);
            if wdRet <> 0 then begin
              ShowMainForm(TDllCaSdk2.MSG_MODE_CAX10_MEM_CH_NO,nCh,False,sErrMsg);
              sErrMsg := Format('Ca410 Memory Channel Read NG - NG Code :%0.2d',[wdRet]);
              ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh,True,sErrMsg);
              ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
            end
            else begin
              sErrMsg := Format('MEM CH:%0.2d',[nGetMemCh]);
              ShowMainForm(TDllCaSdk2.MSG_MODE_CAX10_MEM_CH_NO,nCh,False,sErrMsg);
              sErrMsg := Format('Get CA410 MEM CH:%0.2d - OK',[nGetMemCh]);
              ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
            end;

            wdRet := SetSyncMode(nCh,4,120,120);
            if wdRet <> 0 then begin
              ShowMainForm(TDllCaSdk2.MSG_MODE_CAX10_MEM_CH_NO,nCh,False,sErrMsg);
              sErrMsg := Format('Ca410 Set Sync NG - NG Code :%0.2d',[wdRet]);
              ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh,True,sErrMsg);
              ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
            end
            else begin
              sErrMsg := Format('Set CA410 Sync %0.2d, Freq %d - OK',[4,120]);
              ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
            end;
//          end);
//          thCa.Start;
        end;
      end
      else begin
        sErrMsg := Format('Probe %d CA410 Connection NG',[nCh+1]);
        ShowMainForm(TDllCaSdk2.MSG_MODE_STATUS, nCh,True,sErrMsg);
        ShowTestForm(TDllCaSdk2.MSG_MODE_LOG   , nCh,True,sErrMsg);
        FProbeFount_Connected[nCh] := False;
      end;
    end;
  end;
end;

procedure TDllCaSdk2.CheckConnection(bEnable: Boolean);
var
  nCh : Integer;
begin
  tmrConnectCheck.Enabled := bEnable;
  for nCh := 0 to Pred(self.MAX_CH_CNT) do FCheckConnection[nCh] := 0;
end;

constructor TDllCaSdk2.Create(nMsgType ,nPgNo : Integer; hMain, hTest: HWND; nMemCh : Integer; bAuto : Boolean);
var
  i: Integer;
  PVerInfo : PAnsiChar;
  sDebug, sDLLPath, sNgMessage : string;
begin
// dll file Load.
  FCurChannel := 0;
  sDLLPath := ExtractFilePath(Application.ExeName) + CA_SDK2_DLL;
  FIsDllLoadingOk := False;
  FnMsgType := nMsgType;

  if FileExists(sDLLPath) then FhDll := LoadLibrary(PChar(sDLLPath))
  else begin
    sNgMessage := '[' + sDLLPath + ']' + #13#10 + ' Cannot find the file.!';
    ShowMessage(sNgMessage);
    Exit;
  end;
  if FhDll = 0 then begin
    sNGMessage := ' Dll load Failed';
    Exit;
  end;
  SetFunction;

  FhCaSdk2 := f_NewCaSdk2;
  FnMemCh := nMemCh;
  //0: Slow, 1 : FAST MODE, 2 : LTD Auto. 3 : Auto
  if bAuto then begin
    FnAutoMode := 2;
  end
  else begin
    FnAutoMode := 1;
  end;

  FProbeFound_Count := 0;
  for i := 0 to Pred(Self.MAX_PROBE) do FProbeFount_Connected[i] := False;
  for i := 0 to MAX_CH do IsScriptWorking[i] := False;

  // Added by Clint 2022-08-09 오후 4:31:13 Connection Check option.
  tmrConnectCheck := TTimer.Create(nil);
  tmrConnectCheck.Interval := 3000;
  tmrConnectCheck.Enabled  := False;
  tmrConnectCheck.OnTimer := OnConnectEventTimer;

  FhMain :=  hMain;
  FhTest := hTest;

  f_GetDllVerInfo(PVerInfo);
  sDebug := 'CA DLL Version : '+StrPas(PVerInfo);
  for i := 0 to Pred(Self.MAX_CH) do ShowTestForm(Self.MSG_MODE_LOG,i,False,sDebug);

  FIsDllLoadingOk := True;
end;

destructor TDllCaSdk2.Destroy;
var
  i: Integer;
begin
  if tmrConnectCheck <> nil then begin
    tmrConnectCheck.Enabled := False;
    tmrConnectCheck.Free;
    tmrConnectCheck := nil;
  end;


  for i := 0 to Pred(FProbeFound_Count) do begin
      DeviceInfo[i].DeviceId := 0;
      DeviceInfo[i].SerialNo := '';
  end;
  SetLength(DeviceInfo,0);
  f_DeleteCaSdk2(FhCaSdk2);
  inherited;
end;

function TDllCaSdk2.GetCa410Status(nProbe: Integer): Integer;
begin
  if not self.FProbeFount_Connected[nProbe] then Exit(self.DISCONNECTION_CODE);
  Result := f_Get_Connect(nProbe);
end;

function TDllCaSdk2.GetConnProbe(nProbe: Integer): Integer;
begin

  if not FProbeFount_Connected[nProbe] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := 0;
end;

function TDllCaSdk2.GetMemCh(nCh: Integer; var nMemCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_Get_MemCh(FSetupCnt.SetupList[nCh].Ca410Ch,nMemCh);
end;

function TDllCaSdk2.GetMemInfo(nCh, nMemCh: Integer; var R_Lv, R_x, R_y, G_Lv, G_x, G_y, B_Lv, B_x, B_y, W_Lv, W_x, W_y: Double): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
end;

function TDllCaSdk2.GetSetupPort(nIndex: Integer): TCaSetupInfo;
begin
  Result :=  FSetupCnt.SetupList[nIndex];
end;

function TDllCaSdk2.GetWaveformData(nChannel: integer; waveform_T, waveformData: PDouble; measureAmount: Integer): Double;
var
  waveformDataSize : DWORD;
  SamplingPitch,measurementTime : Double;
  i : Integer;
  weightedWaveformData : array of Double;
begin

  if not FProbeFount_Connected[nChannel] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  f_Measure_waveform(nChannel,measureAmount);
  waveformDataSize := f_Get_waveformDataSize(nChannel,measureAmount);
  Setlength(weightedWaveformData,waveformDataSize);
  measurementTime := 0;
  measurementTime := f_Get_waveform_Data(nChannel,waveformData,@weightedWaveformData[0],waveformDataSize,measurementTime);
  SamplingPitch := measurementTime / waveformDataSize;

  for I := 0 to waveformDataSize -1  do
  begin
    waveform_T^ := SamplingPitch * i;
    if i <> waveformDataSize -1 then
      inc(waveform_T);
  end;

  Result := measurementTime;
end;

function TDllCaSdk2.ManualConnect: Integer;
var
  nErr, nRet, nPort : integer;
  i, nProbe: Integer;
  pSerialNo : PAnsiChar;
  sErrMsg : string;
  bIsNg   : boolean;
begin
  nErr :=  f_SetConfigration(FhCaSdk2);
  FProbeFound_Count :=  f_GetDeviceCnt(FhCaSdk2);
  if FProbeFound_Count > 0 then begin
    SetLength(DeviceInfo,FProbeFound_Count);
    for i := 0 to Pred(FProbeFound_Count) do begin
      nPort := 0;
      nRet := f_GetProbeInfo(i,nPort, pSerialNo);
      DeviceInfo[i].DeviceId := nPort;
      DeviceInfo[i].SerialNo := StrPas(pSerialNo);
    end;
  end;

  // Connection Error 처리.
  for nProbe := 0 to Pred(TDllCaSdk2.MAX_PROBE) do CheckConnect(nProbe);

  Result := nErr;;
end;

function TDllCaSdk2.Measure(nCh: Integer; var MeasRet: TBrightValue): Integer;
var
  nRet : Integer;
  dX, dY, dLv : Double;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  // CA Driver Channel : 0 ~ 1, But  SelectIdx includes 'NONE' so, 1 ~ 2
  nRet := f_set_Measure(FSetupCnt.SetupList[nCh].Ca410Ch);
  if nRet = 0 then begin
    nRet := f_get_sXylvVal(FSetupCnt.SetupList[nCh].Ca410Ch, dX, dY, dLv);
    MeasRet.xVal   :=  dX;
    MeasRet.yVal   :=  dY;
    MeasRet.LvVal  :=  dLv;
  end
  else begin
    MeasRet.xVal   :=  0.0;
    MeasRet.yVal   :=  0.0;
    MeasRet.LvVal  :=  0.0;
  end;
  Result := nRet;
end;

function TDllCaSdk2.MeasureAllData(nCh: Integer; var MeasRet: TLvXYUV): Integer;
var
  nRet : Integer;
  dU, dV,  dX, dY, dLv : Double;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  // CA Driver Channel : 0 ~ 1, But  SelectIdx includes 'NONE' so, 1 ~ 2
  nRet := f_set_Measure(FSetupCnt.SetupList[nCh].Ca410Ch);
  if nRet = 0 then begin
    nRet := f_get_sUvlvVal(FSetupCnt.SetupList[nCh].Ca410Ch, dU, dV, dLv);
    MeasRet.u   :=  dU;
    MeasRet.v   :=  dV;
    nRet := f_get_sXylvVal(FSetupCnt.SetupList[nCh].Ca410Ch, dX, dY, dLv);
    MeasRet.x   :=  dX;
    MeasRet.y   :=  dY;
    MeasRet.Lv  :=  dLv;
  end
  else begin
    MeasRet.x   :=  0.0;
    MeasRet.y   :=  0.0;
    MeasRet.u   :=  0.0;
    MeasRet.v   :=  0.0;
    MeasRet.Lv  :=  0.0;
  end;
  Result := nRet;
end;

function TDllCaSdk2.MeasureData(nCh: Integer; var MeasRet: TLvXYUV): Integer;
var
  nRet : Integer;
  dU, dV,  dX, dY, dLv, dUv : Double;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  // CA Driver Channel : 0 ~ 1, But  SelectIdx includes 'NONE' so, 1 ~ 2
  nRet := f_set_Measure(FSetupCnt.SetupList[nCh].Ca410Ch);
  if nRet = 0 then begin
    nRet := f_get_sXyUvlvVal(FSetupCnt.SetupList[nCh].Ca410Ch, dX, dY, dU, dV, dLv, dUv);
    MeasRet.u   :=  dU;
    MeasRet.v   :=  dV;
    MeasRet.x   :=  dX;
    MeasRet.y   :=  dY;
    MeasRet.Lv  :=  dLv;
    MeasRet.dUv :=  dUv;
  end
  else begin
    MeasRet.x   :=  0.0;
    MeasRet.y   :=  0.0;
    MeasRet.u   :=  0.0;
    MeasRet.v   :=  0.0;
    MeasRet.Lv  :=  0.0;
    MeasRet.dUv :=  0.0;
  end;
  Result := nRet;
end;

procedure TDllCaSdk2.OnConnectEventTimer(Sender: TObject);
var
  nCh, nStates : Integer;
  sErrMsg : string;
begin
  for nCh := 0 to Pred(Self.MAX_PROBE) do begin
    if IsScriptWorking[nCh] then Continue;    // if script is working then skip checking.
    if FCheckConnection[nCh] > 2 then begin
      if FProbeFount_Connected[nCh] then begin
        FProbeFount_Connected[nCh] := False;
        sErrMsg := Format('Cannel %d CA410 Connection NG',[nCh+1]);
        ShowMainForm(self.MSG_MODE_STATUS,0,True,sErrMsg);
        ShowTestForm(self.MSG_MODE_LOG,0,True,sErrMsg);
      end;
    end
    else begin
      if FProbeFount_Connected[nCh] then begin
        nStates := GetCa410Status(nCh);
        if nStates <> 0  then begin
          Inc(FCheckConnection[nCh]);
        end;
      end;
    end;
  end;
end;

function TDllCaSdk2.ResetCalMode(nCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_ResetLvCalMode(FSetupCnt.SetupList[nCh].Ca410Ch);
end;

function TDllCaSdk2.SetCommandCa410(nCh: Integer; sCmd: PAnsiChar; var sRetMsg: PAnsiChar): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_CA_SetCommand(FSetupCnt.SetupList[nCh].Ca410Ch,sCmd,sRetMsg);
end;

procedure TDllCaSdk2.SetCurChannel(const Value: Integer);
begin
  FCurChannel := Value;
end;

function TDllCaSdk2.SetDefaultMemCh(nCh, nMemCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_initMemCh(nCh,nMemCh);
end;

procedure TDllCaSdk2.SetFunction;
var
  sVer : string;
  nVer : Integer;
begin
  @f_NewCaSdk2        := GetProcAddress(FhDll, 'NewCaSdk2');
  @f_DeleteCaSdk2     := GetProcAddress(FhDll, 'DeleteCaSdk2');
  @f_SetConfigration  := GetProcAddress(FhDll, 'SetConfigration');
  @f_GetDeviceCnt     := GetProcAddress(FhDll, 'GetDeviceCnt');
  @f_GetProbeInfo     := GetProcAddress(FhDll, 'GetProbeInfo');
  @f_GetDllVerInfo    := GetProcAddress(FhDll, 'GetDllVerInfo');

  @f_CalZero            := GetProcAddress(FhDll, 'CalZero');
  @f_Set_Measure        := GetProcAddress(FhDll, 'set_Measure');
  @f_Get_sXylvVal       := GetProcAddress(FhDll, 'get_sXylvVal');
  @f_Get_sUvlvVal       := GetProcAddress(FhDll, 'get_sUvlvVal');
  @f_Get_sXyUvlvVal     := GetProcAddress(FhDll, 'get_sXyUvlvVal');
  @f_GetErrorMessage    := GetProcAddress(FhDll, 'GetErrorMessage');
//  @f_Set_AvrMode        := GetProcAddress(FhDll, 'set_AvrMode');
  @f_Set_SyncMode       := GetProcAddress(FhDll, 'set_SyncMode');
  @f_Set_DefaultConnect := GetProcAddress(FhDll, 'set_DefaultConnect');
  @f_Set_MemCh          := GetProcAddress(FhDll, 'set_MemCh');
  @f_Get_MemCh          := GetProcAddress(FhDll, 'get_MemCh');
  @f_InitMemCh          := GetProcAddress(FhDll, 'InitMemCh');

  @f_CalMeasure         := GetProcAddress(FhDll, 'CalMeasure');
  @f_SetLvxy_CalData    := GetProcAddress(FhDll, 'SetLvxy_CalData');
  @f_MatrixCal_Update   := GetProcAddress(FhDll, 'MatrixCal_Update');
  @f_ResetLvCalMode     := GetProcAddress(FhDll, 'ResetLvCalMode');
  @f_GetMemChData       := GetProcAddress(FhDll, 'GetMemChData');
  @f_UserCalReady       := GetProcAddress(FhDll, 'UserCalReady');
  @f_UserCalMeasure     := GetProcAddress(FhDll, 'UserCalMeasure');
  @f_VSync_CntSet       := GetProcAddress(FhDll, 'VSync_CntSet');
  @f_CA_SetCommand      := GetProcAddress(FhDll, 'CA_SetCommand');
  @f_Get_Connect        := GetProcAddress(FhDll, 'get_Connect');

  @f_Get_waveformData   := GetProcAddress(FhDll, 'Get_waveformData');
  @f_Get_waveform_Data  := GetProcAddress(FhDll, 'Get_waveform_Data');
  @f_Measure_waveform   := GetProcAddress(FhDll, 'Measure_waveform');
  @f_Get_waveformDataSize := GetProcAddress(FhDll, 'Get_waveformDataSize');

end;

procedure TDllCaSdk2.SetIsDllLoadingOk(const Value: Boolean);
begin
  FIsDllLoadingOk := Value;
end;


function TDllCaSdk2.SetMemCh(nCh, nMemCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_set_MemCh(FSetupCnt.SetupList[nCh].Ca410Ch,nMemCh);
end;

procedure TDllCaSdk2.SetProbeFound_Count(const Value: Integer);
begin
  FProbeFound_Count := Value;
end;

procedure TDllCaSdk2.SetSetupPort(nIndex: Integer; const Value: TCaSetupInfo);
begin
  FSetupCnt.SetupList[nIndex] := Value;
end;

function TDllCaSdk2.SetSyncMode(nCh, nSync: Integer; dFrea: Double; nIntegTime: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_Set_SyncMode(FSetupCnt.SetupList[nCh].Ca410Ch,nSync,dFrea,nIntegTime);
end;

function TDllCaSdk2.SetVsyncFrame(nCh, nFrame: Integer; var sRetMsg: PAnsiChar): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_VSync_CntSet(FSetupCnt.SetupList[nCh].Ca410Ch,nFrame,sRetMsg);
end;

function TDllCaSdk2.set_CalZero(nCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_CalZero(FSetupCnt.SetupList[nCh].Ca410Ch);
end;

procedure TDllCaSdk2.ShowMainForm(nMode, ProbeNo: Integer; bError: Boolean; sMsg: string; nParam: Integer);
var
  ccd         : TCopyDataStruct;
  HostUiMsg   : RSyncCa410;
begin
  HostUiMsg.MsgType := FnMsgType;
  HostUiMsg.MsgMode := nMode;
  HostUiMsg.Channel	:= FCurChannel;
  HostUiMsg.bError  := bError;
  HostUiMsg.nParam  := nParam;
  HostUiMsg.ProbeNo := ProbeNo;
  HostUiMsg.Msg     := sMsg;
  ccd.dwData        :=   0;
  ccd.cbData        := SizeOf(HostUiMsg);
  ccd.lpData        := @HostUiMsg;

  SendMessage(FhMain ,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TDllCaSdk2.ShowTestForm(nMode, ProbeNo: Integer; bError: Boolean; sMsg: string; nParam: Integer);
var
  ccd         : TCopyDataStruct;
  HostUiMsg   : RSyncCa410;
begin
  HostUiMsg.MsgType := FnMsgType;
  HostUiMsg.MsgMode := nMode;
  HostUiMsg.Channel	:= FCurChannel;
  HostUiMsg.bError  := bError;
  HostUiMsg.nParam  := nParam;
  HostUiMsg.ProbeNo := ProbeNo;
  HostUiMsg.Msg     := sMsg;
  ccd.dwData        :=   0;
  ccd.cbData        := SizeOf(HostUiMsg);
  ccd.lpData        := @HostUiMsg;

  SendMessage(FhTest ,WM_COPYDATA,0, LongInt(@ccd));
end;

function TDllCaSdk2.UsrCalMeasure(nCh, nColorType: Integer; var x, y, lv: Double): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_UserCalMeasure(FSetupCnt.SetupList[nCh].Ca410Ch,nColorType,x, y , lv );
end;

function TDllCaSdk2.UsrCalReady(nCh, nMemCh: Integer): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_UserCalReady(FSetupCnt.SetupList[nCh].Ca410Ch,nMemCh);
end;

function TDllCaSdk2.UsrCalSetCalData(nCh, nColorType: Integer; tX, tY, tLv: Double): Integer;
begin
  if not FProbeFount_Connected[nCh] then Exit(TDllCaSdk2.DISCONNECTION_CODE);
  Result := f_SetLvxy_CalData(FSetupCnt.SetupList[nCh].Ca410Ch,nColorType, tX, tY, tLv );
end;

end.
