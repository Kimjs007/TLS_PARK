unit CtrlCssDll_Tls;

interface
uses
  System.SysUtils, System.Classes, Vcl.Dialogs, Winapi.Windows, Vcl.ExtCtrls, DefDio, System.Generics.Collections,
  Winapi.Messages, System.UITypes, Dask, DefCommon, CommonClass, DllCasSdkCa410, DllLgdCssTls, CommPG, LibUserFuncs;



type
  PCtlLgdDll = ^RCtlLgdDll;
  RCtlLgdDll = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    nParam  : Integer;
    Msg     : string;
  end;

  TControlLgdDllSub = class(TObject)
  public
    constructor Create(hMain: HWND; hTest : HWND); virtual;
    destructor Destroy; override;
  end;

  TControlLgdDll = class(TObject)
  private
    FIsWorking: Boolean;
    FDllFileName : array[0 .. DefCommon.MAX_CH] of string;
    procedure SetIsWorking(const Value: Boolean);
//    procedure SetDefaultPath;
//    procedure SetDefaultData;
    procedure SetScriptProperty;
    function   GetDllFileName(nCh : Integer) : string;
    procedure SetDllFileName(nCh: Integer; const Value: string);
  public
  ///	<summary>
    ///	  LGD C# Dll을 Control 하기 위한 Class.
    ///	</summary>
    ///	<param name="hMain">
    ///	  Main Gui Handle
    ///	</param>
    ///	<param name="hTest">
    ///	  Test Form Gui Handle
    ///	</param>
    constructor Create(hMain: HWND; hTest : HWND; sDllFileName : string; sModelName : string); virtual;

    ///	<summary>
    ///	  초기화
    ///	</summary>
    ///	<remarks>
    ///	  <para>
    ///	    1. LGD Dll Stop.
    ///	  </para>
    ///	</remarks>
    destructor Destroy; override;

    function GetOcStatus(nCh : Integer) : Integer;
    function GetDllVersion : string;
    procedure StartOcDllCss(nCh : Integer; sData : string; dTemp : Double);
    procedure StartVerifyDllCss(nCh : Integer; dTemp : Double);
    procedure FinalWorkDllCss(nCh : Integer);
    procedure StopDllCss(nCh : Integer);
    property IsWorking : Boolean read FIsWorking write SetIsWorking;
    property DllFileName[nCh : Integer] : string read GetDllFileName write SetDllFileName;
  end;
var
  ///	<summary>
  ///	  동아엘텍에서 사용하는 DIO Class
  ///	</summary>
  CtlLgdDll : TControlLgdDll;
  g_IsCtlDll : boolean;

implementation

{ TControlLgdDll }

uses
  pasScriptClass;

constructor TControlLgdDll.Create(hMain, hTest: HWND; sDllFileName : string; sModelName : string);
var
  i: Integer;
  sGetModeType : string;
begin
  FIsWorking := True;
  CssLgdDll := TCssLgdDll.Create(hMain, hTest,DefCommon.MSG_TYPE_DLL_LGD,sDllFileName);


  sGetModeType   := TUserFunc.GetModelNameItem(2,Common.SystemInfo.TestModel);

  SetScriptProperty;
  CssLgdDll.Initialize(sGetModeType);
  //CssLgdDll.StartOc(0,'1,2,PM,EQIPMENT:123456',25.1);
end;

destructor TControlLgdDll.Destroy;
begin
  g_IsCtlDll := False;
  FIsWorking := False;
  if CssLgdDll <> nil then begin
    CssLgdDll.Free;
    CssLgdDll := nil;
  end;
  inherited;
end;

procedure TControlLgdDll.FinalWorkDllCss(nCh: Integer);
begin
  CssLgdDll.FinalWork(nCh);
end;

function TControlLgdDll.GetDllFileName(nCh: Integer): string;
begin
  Result := FDllFileName[nCh];
end;

function TControlLgdDll.GetDllVersion: string;
var
  sVer : string;
begin
  sVer := CssLgdDll.GetDllVer;
  Result := sVer;
end;

function TControlLgdDll.GetOcStatus(nCh: Integer): Integer;
begin
  Result := CssLgdDll.GetOcStatus(nCh);
end;

//procedure TControlLgdDll.SetDefaultData;
//var
//  nCh : Integer;
//  Data : array[0 .. DefCommon.MAX_CH] of TCssAutoData;
//begin
//  // -------------------------------------- for Data.
//  for nCh := 0 to DefCommon.MAX_CH do begin
//    Data[nCh].PanelID          := PasScr[nCh].m_TestRet.SerialNo;
//    Data[nCh].GetPchkRev       := PasScr[nCh].m_TestRet.PchkData;
//    Data[nCh].MachineID        := Common.SystemInfo.EQPId;
//    Data[nCh].sEmNo            := Common.SystemInfo.EQPId;
//    Data[nCh].ScriptVersion    := Common.m_Ver.psu_Date+'_'+ Common.m_Ver.psu_Crc;
//    Data[nCh].FirmwareVersion  := (PG[nCh].m_sFwVerSpi + '/' + Trim(PG[nCh].m_sBootVerSpi));
//    Data[nCh].MainUIVersion    := Common.SwVersion;
//    CssAutoLgdDll.CssAutoData[nCh] := Data[nCh];
//  end;
//end;

//procedure TControlLgdDll.SetDefaultPath;
//var
//  sFileName, sFilePath,sDate  : string;
//  dtCurDate : TDatetime;
//  nCh: Integer;
//begin
//  // -------------------------------------- for Path.
//  // Set Mlog
//  dtCurDate := now;
//
//  if Common.SystemInfo.ClusterLogPath then begin
//    sDate := FormatDateTime('mm', dtCurDate);
//    sFilePath := Common.Path.MLOG + sDate + '\';
//    if Common.CheckDir(sFilePath) then begin
//      Exit;
//    end;
//    sFilePath := sFilePath + Common.systemInfo.EQPId + '\';
//    if Common.CheckDir(sFilePath) then begin
//      Exit;
//    end;
//    sDate := FormatDateTime('yyyymmdd', dtCurDate);
//  end
//  else begin
//    sDate := FormatDateTime('yyyymm', dtCurDate);
//    sFilePath := Common.Path.MLOG + sDate + '\';
//    sDate := FormatDateTime('yyyymmdd', dtCurDate);
//    if Common.CheckDir(sFilePath) then begin
//      Exit;
//    end;
//  end;
//
//  for nCh := 0 to DefCommon.MAX_CH do begin
//    // set MLog.
//    CssAutoLgdDll.PathInfo[nCh].MLogFile := Format('MLog_%s_%s_Ch%d.txt',[Common.systemInfo.EQPId,sDate,nCh + 1]);
//    CssAutoLgdDll.PathInfo[nCh].MLogPath := sFilePath;
//    // set Model.
//    CssAutoLgdDll.PathInfo[nCh].ModelName := Common.SystemInfo.TestModel;
//    CssAutoLgdDll.PathInfo[nCh].ModelPath := Common.Path.MODEL_CUR;
//  end;
//
//  // set summary.
//  if Common.SystemInfo.ClusterLogPath then begin
//    sDate := FormatDateTime('mm', dtCurDate);
//    sFilePath := Common.Path.SumCsv + sDate + '\';
//    if Common.CheckDir(sFilePath) then begin
//      Exit;
//    end;
//    sFilePath := sFilePath + Common.systemInfo.EQPId + '\';
//    if Common.CheckDir(sFilePath) then begin
//      Exit;
//    end;
//    sDate := FormatDateTime('yyyymmdd', dtCurDate);
//  end
//  else begin
//    sFilePath := Common.Path.SumCsv+formatDateTime('yyyymm',now) + '\';
//    if Common.CheckDir(sFilePath) then Exit;
//  end;
//  for nCh := 0 to DefCommon.MAX_CH do begin
//    CssAutoLgdDll.PathInfo[nCh].SLogFile := PasScr[nCh].m_sFileCsv;// Format('MLog_%s_%s_Ch%d.txt',[Common.systemInfo.EQPId,sDate,nCh + 1]);
//    CssAutoLgdDll.PathInfo[nCh].SummaryLogPath := sFilePath;
//  end;
//end;

procedure TControlLgdDll.SetDllFileName(nCh: Integer; const Value: string);
begin
  FDllFileName[nCh] := Value;
end;

procedure TControlLgdDll.SetIsWorking(const Value: Boolean);
begin
  FIsWorking := Value;
end;

// Script쪽에 유사한 기능이 있어 Event 연결해줌.
procedure TControlLgdDll.SetScriptProperty;
var
  nCh: Integer;
begin
//  for nCh := 0 to DefCommon.MAX_CH do begin
    CssLgdDll.OnCa410Event   := PasScrMain.LgdDllCssCb_Ca410Measure;
    CssLgdDll.OnRetIntEvent  := PasScrMain.LgdDllCssCb_RetInt;
    CssLgdDll.OnRetStrEvent  := PasScrMain.LgdDllCssCb_RetStr;
    CssLgdDll.OnSetIntEvent  := PasScrMain.LgdDllCssCb_SetInt;
    CssLgdDll.onResultEvent  := PasScrMain.LgdDllCssCb_Result;



//    LgdDllSub[nCh].OnI2cEvent     := PasScr[nCh].LgdDllCssCb_I2C;
//    LgdDllSub[nCh].onQspiErase    := PasScr[nCh].LgdDllCssCb_Qspi_Erase;
//    CssLgdDll.onQspiRead     := PasScr[nCh].LgdDllCssCb_Flash_Read;
//    LgdDllSub[nCh].onQspiWrite    := PasScr[nCh].LgdDllCssCb_Qspi_Write;
//  end;
end;

procedure TControlLgdDll.StartOcDllCss(nCh : Integer;sData : string; dTemp : Double);
begin
  CssLgdDll.StartOc(nCh,sData,dTemp);
end;

procedure TControlLgdDll.StartVerifyDllCss(nCh: Integer; dTemp: Double);
begin
  CssLgdDll.StartVerify(nCh,dTemp);
end;

procedure TControlLgdDll.StopDllCss(nCh: Integer);
begin
  CssLgdDll.StopOc(nCh);
end;

{ TControlLgdDllSub }

constructor TControlLgdDllSub.Create(hMain, hTest: HWND);
begin

end;

destructor TControlLgdDllSub.Destroy;
begin

  inherited;
end;

end.
