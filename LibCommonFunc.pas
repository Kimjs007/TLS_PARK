unit LibCommonFunc;

// Control + J : Templet 보여주기.


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.DateUtils, Vcl.ExtCtrls
  , System.Win.Registry, Winapi.PsAPI, Winapi.WinSock
  ;

type
  TLibEventComm1 = procedure(IsParma1 : Boolean; Param2 : Integer) of object;
  TLibEventComm2 = procedure(var IsParma1 : Boolean;var Param2 : Integer) of object;

  TLibEventComm3 = procedure(Parma1 : Integer; Param2 : Integer; sMsg : string) of object;
  // 역슬래쉬 3번에 S 누르면 하기의 Summary 정리 가능합니다.
  /// <summary>
  /// Library 함수 - 간단한 각종 기능 모아놨습니다.
  ///  1. Save Energy.
  ///  2. Memory Check - only for  current process.
  ///  3. 자동 Backup 기능.
  ///  4. Get Computer Name.
  ///  5. GetLocalIpList
  /// </summary>
  TLibCommon = class(TObject)

  private
    // For Energy Save.
    tmrSaveEnergy : TTimer;
    FEnable_SaveEnergy: boolean;
    FSaveEnergyChnage, FSaveEnergy : Boolean;
    FOnSaveEnergy: TLibEventComm1;
    FOnGetSaveEnergyInspetStatus: TLibEventComm2;
    FIntervalOfSaveEnergy: Integer;
    FSetStopCopys: Boolean;
    FLibLog: TLibEventComm3;
    // For Energy Save.
    procedure SetEnable_SaveEnergy(const Value: boolean);
    procedure OnEventTimerSaveEnergy (Sender : TObject);
    procedure SetOnSaveEnergy(const Value: TLibEventComm1);
    function SetScreenSave(TimeOut: Integer): Boolean;
    procedure SetOnGetSaveEnergyInspetStatus(const Value: TLibEventComm2);
    procedure SetIntervalOfSaveEnergy(const Value: Integer);
    procedure SetSetStopCopys(const Value: Boolean);
    procedure SetLibLog(const Value: TLibEventComm3);

  public
    constructor Create; virtual;
    destructor Destroy; override;

    // Copy folder and files.


    // Memory Check - only for  current process.
    function GetMemoryUsedMemory : string;

    // HDD - Current
    procedure GetCurHddStatus(var nTotalSize, nFreeAvailable: Int64);
    function GetCurHdd ( nType, nSystemLimit : Integer;var bError : Boolean; var nUsed , nTotal: Integer; var sErrMsg : string) : string;
    // For Energy Save.
    property Enable_SaveEnergy : boolean read FEnable_SaveEnergy write SetEnable_SaveEnergy;
    property OnSaveEnergy : TLibEventComm1 read FOnSaveEnergy write SetOnSaveEnergy;
    property OnGetSaveEnergyInspetStatus : TLibEventComm2 read FOnGetSaveEnergyInspetStatus write SetOnGetSaveEnergyInspetStatus;
    property IntervalOfSaveEnergy : Integer read FIntervalOfSaveEnergy write SetIntervalOfSaveEnergy;

    // Copy folder and files.
    procedure AutoBackup(IsBackup : boolean; Target : string);
    procedure CopyDirectoryAll(pSourceDir, pDestinationDir: string; pOverWrite: Boolean);
    property SetStopCopys : Boolean read FSetStopCopys write SetSetStopCopys;

    // for log file.
    property LibLog : TLibEventComm3 read FLibLog write SetLibLog;

    // Get Computer Name.
    /// <summary>
    /// 현재 Computer의 이름을 가져옵니다.
    /// </summary>
    function GetComputerName: String;

    // Get Local Ip List.
    /// <summary>
    /// Local IP를 모드 찾습니다.
    /// <param name="sSearchIp가 '' 전체 IP, 지정하면 해당된 IP만 Search."></param>
    /// </summary>
    function GetLocalIpList(sSearchIp : string = '') : string;
  end;

var
  LibCommon : TLibCommon;

implementation

{ TLibCommon }

procedure TLibCommon.AutoBackup(IsBackup: boolean; Target: string);
var
  sTarget, sSource : string;
  aTask : TThread;
begin
  if not IsBackup then Exit;
  sTarget := Trim(Target);
  if sTarget <> ''  then begin
    sSource :=  ExtractFilePath(Application.ExeName);
    if not DirectoryExists(sTarget) then begin
      if not CreateDir(sTarget) then begin
        MessageDlg(#13#10 + 'Cannot make the Path('+sTarget+')!!!', mtError, [mbOk], 0);
        Exit;
      end;
    end;
    if DirectoryExists(sTarget) then begin
      aTask := TThread.CreateAnonymousThread(
        procedure begin
          if Assigned(LibLog) then LibLog(0,0, 'Execute Auto Backup '  + sSource + ' -> '  + sTarget);
          CopyDirectoryAll(sSource,sTarget, False);
        end);
      aTask.FreeOnTerminate := True;
      aTask.Start;
    end;
  end;
end;

procedure TLibCommon.CopyDirectoryAll(pSourceDir, pDestinationDir: string; pOverWrite: Boolean);
var
  TempList : TSearchRec;
begin
  if FSetStopCopys then Exit;
  if FindFirst(pSourceDir + '\*', faAnyFile, TempList) = 0 then begin
    if FSetStopCopys then Exit;
    if not DirectoryExists(pDestinationDir) then ForceDirectories(pDestinationDir);
    repeat
      if FSetStopCopys then Break;
      if ((TempList.attr and faDirectory) = faDirectory) and not (TempList.Name = '.') and not (TempList.Name = '..') then begin
        if DirectoryExists(pSourceDir + '\' + TempList.Name) then begin
           CopyDirectoryAll(pSourceDir + '\' + TempList.Name, pDestinationDir + '\' + TempList.Name, pOverWrite);
        end;
      end
      else begin
        if not pOverWrite then begin
           if FileExists(pSourceDir + '\' + TempList.Name) then begin
              CopyFile(pChar(pSourceDir + '\' + TempList.Name), pChar(pDestinationDir + '\' + TempList.Name), True);
           end;
        end
        else begin
           if FileExists(pSourceDir + '\' + TempList.Name) then begin
              CopyFile(pChar(pSourceDir + '\' + TempList.Name), pChar(pDestinationDir + '\' + TempList.Name), False);
           end;
        end;
      end;
    until FindNext(TempList) <> 0;
  end;
  FindClose(TempList);
end;

constructor TLibCommon.Create;
begin
  inherited;
  // for Save Energy.
  FEnable_SaveEnergy := False;
  FSaveEnergy        := False;
  tmrSaveEnergy := TTimer.Create(nil);
  tmrSaveEnergy.Enabled := False;
  tmrSaveEnergy.OnTimer := OnEventTimerSaveEnergy;
  FSaveEnergyChnage := False;
end;

destructor TLibCommon.Destroy;
begin
  if tmrSaveEnergy <> nil then begin
    tmrSaveEnergy.Enabled := False;
    tmrSaveEnergy.Free;
    tmrSaveEnergy := nil;
  end;
  inherited;
end;

function TLibCommon.GetComputerName: String;
var
  buffer : array [0 .. MAX_COMPUTERNAME_LENGTH + 1] of Char;
  Size : Cardinal;
begin
  Size := MAX_COMPUTERNAME_LENGTH + 1;
  GetComputerNameW(@buffer, Size);
  Result:= StrPas(Buffer);
end;

function TLibCommon.GetCurHdd(nType, nSystemLimit: Integer;var bError : Boolean; var nUsed , nTotal: Integer; var sErrMsg : string): string;
var
  nGetTotal,nGetUsed, nFree, nRatio, nLimit, nSize : Int64;
begin
  GetCurHddStatus(nGetTotal, nFree);
  nGetUsed := nGetTotal - nFree;

  if nGetTotal < 1024*1024 then begin
    nSize := 1024;
  end
  else if nGetTotal < 1024*1024*1024 then begin
    nSize := 1024*1024;
  end
  else begin
    nSize := 1024*1024*1024;
  end;
  nTotal :=  nGetTotal div nSize;
  nUsed  :=  nGetUsed  div nSize;

  if nSize = 1024*1024*1024 then Result := Format('Total (%d GB), Used (%d GB)',[nTotal, nUsed]);
  if nSize = 1024*1024      then Result := Format('Total (%d MB), Used (%d MB)',[nTotal, nUsed]);
  if nSize = 1024           then Result := Format('Total (%d KB), Used (%d KB)',[nTotal, nUsed]);

  nLimit := nSize;
  sErrMsg := '';
  bError  := False;
  if (nFree < nLimit) or (nFree < (nSystemLimit * nLimit) )then begin
    bError := True;//spgHdd.BarColor := clRed;
    sErrMsg := Format('HDD available space is not enough (Limit(%d GB) / Free space(%0.3f))',[nSystemLimit,nFree / (1024*1024*1024)]);
  end;
end;

procedure TLibCommon.GetCurHddStatus(var nTotalSize, nFreeAvailable: Int64);
var
  sDir : string;
  slDir : TStringList;
begin
  try
    slDir := TStringList.Create;
    sDir := GetCurrentDir;
    ExtractStrings([':'], [], PWideChar(sDir), slDir);
    sDir := slDir[0]+':\';
  finally
    slDir.Free;
  end;
  System.SysUtils.GetDiskFreeSpaceEx({nil}PChar(sDir),nFreeAvailable,nTotalSize,nil );
end;

function TLibCommon.GetLocalIpList(sSearchIp: string): string;
type
  TaPInAddr = array[0..10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe : PHostEnt;
  pptr : PaPInAddr;
  Buffer : array[0..63] of AnsiChar;
  i : Integer;
  WSAData : TWSAData;
  slIpList : TStringList;
  sIP: String;
  sRet : string;
begin

  WSAStartup(MakeWord(2,2),WSAData);
  try
    slIpList := TStringList.Create ;
    slIpList.Clear;
    gethostname(Buffer, SizeOf(Buffer));
    phe := gethostbyname(buffer);
    if phe = nil then Exit;
    pptr := papinaddr(phe^.h_addr_list);
    i := 0;
    while pptr^[i] <> nil do begin
      slIpList.Add(string(inet_ntoa(pptr^[i]^)));
      Inc(i);
    end;
    WSACleanup;
    sRet := '';
    for i := 0 to Pred(slIpList.Count) do begin
      sIP:= Trim(slIpList[i]);
      if sIP = '0.0.0.0' then Continue;
      if Pos('192.168.0.', sIP) > 0 then Continue;
      if sSearchIp = '' then begin
        sRet := sIP;
      end
      else begin
        if Pos(sSearchIp, sIP) <> 1 then Continue;
        sRet := sIP;
        Break;
      end;
      if sRet <> '' then sRet := sRet + ' / ';
      sRet := sRet + Trim(slIpList[i]);
    end;
  finally
    slIpList.Free;
  end;
  Result := sRet;
end;

function TLibCommon.GetMemoryUsedMemory: string;
var
//  pmc: PPROCESS_MEMORY_COUNTERS;
//  cb : Integer;
  nRet : UInt64;
  PmCnt : TProcessMemoryCounters;
begin
//  // Get the used memory for the current process
//  cb := SizeOf(TProcessMemoryCounters);
//  nRet := 0;
//  GetMem(pmc, cb);
//  try
//    pmc^.cb := cb;
//    if GetProcessMemoryInfo(GetCurrentProcess(), pmc, cb) then nRet := Longint(pmc^.WorkingSetSize);
//  finally
//    FreeMem(pmc);
//  end;
  PmCnt.cb := SizeOf(TProcessMemoryCounters);
  if GetProcessMemoryInfo(GetCurrentProcess,@PmCnt, SizeOf(PmCnt)) then begin
    nRet := PmCnt.WorkingSetSize;
    if nRet < 1024 then Result:= 'MEMORY CHECK : ' + FormatFloat('#,',nRet) + ' Bytes'
    else if nRet < (1024*1024) then Result:= 'MEMORY CHECK : ' + FormatFloat('#,',(nRet div 1024)) + ' KB'
    else if nRet < (1024*1024*1024) then Result:= 'MEMORY CHECK : ' + FormatFloat('#,',(nRet div (1024*1024))) + ' MB'
    else Result:= 'MEMORY CHECK : ' + FormatFloat('#,',(nRet div (1024*1024))) + ' MB';
  end;

end;

// For Screen Save. ---------------------------------------------------------------
procedure TLibCommon.OnEventTimerSaveEnergy(Sender: TObject);
var
  bValue : Bool;
  bInspectRun : Boolean;
  i : Integer;
begin
  bInspectRun := False;
  if Assigned(OnSaveEnergy) then OnGetSaveEnergyInspetStatus(bInspectRun,i);

  if bInspectRun then begin
    if FSaveEnergy then SetScreenSave(0);
    FSaveEnergy := False;
    Exit;
  end;
  if not FSaveEnergy then SetScreenSave(FIntervalOfSaveEnergy);
  FSaveEnergy := True;

  SystemParametersInfo(SPI_GETSCREENSAVERRUNNING, 0, @bValue, 0);
  if bValue then begin
    // Lamp Off. Inonizer Off ... go into save mode.
    if not FSaveEnergyChnage then begin
      if Assigned(OnSaveEnergy) then OnSaveEnergy(False,0);
    end;
  end
  else begin
    // Screen Saver 원복. ==> Lamp On,
    if FSaveEnergyChnage then begin
      if Assigned(OnSaveEnergy) then OnSaveEnergy(True,0);
    end;
  end;
  FSaveEnergyChnage := bValue;
end;

procedure TLibCommon.SetEnable_SaveEnergy(const Value: boolean);
begin
  FEnable_SaveEnergy := Value;
  FSaveEnergyChnage  := False;
  FSaveEnergy        := False;
  SetScreenSave(Self.FIntervalOfSaveEnergy);
  if Value then begin
    tmrSaveEnergy.Interval := 1000;
    tmrSaveEnergy.Enabled := True;
    FSaveEnergy := True;
  end
  else begin
    tmrSaveEnergy.Enabled := False;
  end;

end;

procedure TLibCommon.SetIntervalOfSaveEnergy(const Value: Integer);
begin
  FIntervalOfSaveEnergy := Value;
end;

procedure TLibCommon.SetLibLog(const Value: TLibEventComm3);
begin
  FLibLog := Value;
end;

procedure TLibCommon.SetOnGetSaveEnergyInspetStatus(const Value: TLibEventComm2);
begin
  FOnGetSaveEnergyInspetStatus := Value;
end;

procedure TLibCommon.SetOnSaveEnergy(const Value: TLibEventComm1);
begin
  FOnSaveEnergy := Value;
end;

function TLibCommon.SetScreenSave(TimeOut: Integer): Boolean;
const
  SixtySeconds = 60 ;
var
  Reg:TRegistry ;
  bRet : boolean;
begin
  bRet := True;

  Reg := TRegistry.Create ;
  Reg.RootKey := HKEY_CURRENT_USER ;
  try
    with Reg do begin
      if OpenKey('Control Panel\Desktop',False) then begin
//        WriteString('SCRNSAVE.EXE', Name) ;
        WriteString('ScreenSaverIsSecure','0') ;
        CloseKey ;
      end
      else begin
        Result := False ;
        exit(False) ;
      end ;
    end ;
  finally
    Reg.Free ;
  end ;

  if TimeOut = 0 then begin
    SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,0,nil,SPIF_SENDWININICHANGE);
  end
  else begin
    SystemParametersInfo(SPI_SETSCREENSAVEACTIVE,1,nil,SPIF_SENDWININICHANGE);
    SystemParametersInfo(SPI_SETSCREENSAVETIMEOUT,SixtySeconds * TimeOut, nil,SPIF_SENDWININICHANGE);
  end;

  Result := True ;
end;

procedure TLibCommon.SetSetStopCopys(const Value: Boolean);
begin
  FSetStopCopys := Value;
end;

end.
