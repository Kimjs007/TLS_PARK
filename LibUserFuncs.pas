unit LibUserFuncs;

interface

uses
  Winapi.Windows, System.Types, System.UITypes, System.SysUtils, system.Classes, Vcl.Forms



  ;


type

  TUserFunc = class(TObject)


    public
      class function GetModelNameItem(nIndex : Integer; sData :string) : string;
      class procedure DelayMs(nMSec : Integer; nType : Integer = 0);
  end;
implementation

{ TUserFunc }

//
class procedure TUserFunc.DelayMs(nMSec, nType: Integer);
var
  FirstTickCount: longint;
  LastTickCount : longint;
  speed_start, speed_stop, Freq, diff    : int64;

begin
  case 0 of
    0 : begin
      if nMSec <= 0 then Exit;
      FirstTickCount := GetTickCount;
      repeat
        Application.ProcessMessages;
        Sleep(1);
        LastTickCount := GetTickCount;
      until ((LastTickCount-FirstTickCount) >= nMSec);
    end;
    1 : begin
      if QueryPerformanceFrequency(Freq) then begin
        QueryPerformanceCounter(speed_start);
        repeat
          Application.ProcessMessages;
          QueryPerformanceCounter(speed_stop);
          diff := ((speed_stop-speed_start) * 1000000) div Freq;
        until diff > nMSec;
      end;
    end;
    2 : begin

    end;
  end;
end;

class function TUserFunc.GetModelNameItem(nIndex: Integer; sData: string): string;
var
  sRet : string;
  slTemp : TStringList;
begin
  sRet := '';
  slTemp := TStringList.Create;
  try
    ExtractStrings(['-'], [], PWideChar(Trim(sData)), slTemp);
    if nIndex < slTemp.Count then begin
      sRet := slTemp[nIndex];
    end;
  finally
    slTemp.Free;
  end;
  Result := sRet;
end;



end.
