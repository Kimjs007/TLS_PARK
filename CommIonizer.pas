unit CommIonizer;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.ExtCtrls,  System.Classes, VaComm, Vcl.Dialogs,
  DefRs232, DefCommon, CommonClass, IdGlobal;

const
  MSG_MODE_IONIZER_CONNECTION     = 1;
  MSG_MODE_IONIZER_ERR_MSG        = 2;
  MSG_MODE_IONIZER_LOG            = 3;


type

  InIonizerEvent = procedure(bIsConnect : Boolean; sGetData : String) of object;

  PGuiIonizer  = ^RGuiIonizer;
  RGuiIonizer = packed record
    MsgType : Integer;
    Channel : Integer;
    Mode    : Integer;
    Param1  : Integer;
    Msg     : string;
  end;

  TIonizer = class(TObject)
		ComIonizer : TVaComm;
  private
    m_hMain, m_hTest      : THandle;
    m_nMsgType            : Integer;
    m_nIdx                : Integer;
    m_bForceStop          : Boolean;
    FReadySwData: Integer;
    FModelType : Integer;  // 0 : Defualt - SBL , 1: SOB, 2: SIB5-S.
    tmIonAliveCheck, tmIonTimeOut : TTimer;
    FOnRevIonizerData: InIonizerEvent;
    m_nConnectCnt : Integer;
    m_sReadData: String;
    FIsIgnoreNg: boolean;
    FNewProtocol: Boolean;
    FCurPort   : Integer;
    procedure ReadVaCom(Sender: TObject; Count: Integer);
    function IsConnectIonizer(sData : string; var sRetStr : string) : Boolean;
    procedure SendMainGuiDisplay(nGuiMode, nConnect : integer; sMsg : string);
    procedure SendTestGuiDisplay(nGuiMode : integer; sMsg : string);
    procedure SetOnRevIonizerData(const Value: InIonizerEvent);
    procedure OnTimeIonizerCheck( Sender: TObject);
    procedure OnTimeIonTimeOut(Sender : TObject);
    procedure SetIsIgnoreNg(const Value: boolean);
    procedure SetNewProtocol(const Value: Boolean);
  public
    m_bConnected : Boolean;
    // Added by Clint 2020-04-01 ���� 3:14:57 Script ����� NG ó�� ���� ����.
    m_bScriptControl : Boolean;
    constructor Create(nIdx : Integer; hMain, hTest :HWND;  nMsgType : Integer); virtual;
    destructor Destroy; override;
    procedure SendMsg(sData : string);
    procedure SendRequest;
    procedure SendRun;
    procedure SendStop;
    property ReadyHandSw : Integer read FReadySwData write FReadySwData;
    property IsIgnoreNg : boolean read FIsIgnoreNg write SetIsIgnoreNg;
    property OnRevIonizerData : InIonizerEvent read FOnRevIonizerData write SetOnRevIonizerData;
    procedure ChangePort( nPort, nModelType : Integer);

    property NewProtocol : Boolean read FNewProtocol write SetNewProtocol;
  end;

var
  DaeIonizer   : array[0..pred(Defcommon.MAX_IONIZER_CNT)] of TIonizer;

implementation

{ TSerialSwitch }

procedure TIonizer.ChangePort(nPort, nModelType: Integer);
var
  sTemp : string;
begin
  FModelType := nModelType;
  FCurPort := nPort;
  if nPort <> 0 then begin
    try
      sTemp := Format('COM%d',[nPort]);
      ComIonizer.Close;
      ComIonizer.Name := Format('ComInonizer%d',[nPort]);
      ComIonizer.PortNum := nPort;
      ComIonizer.Parity   := paNone;
      ComIonizer.Databits := db8;
      ComIonizer.BaudRate := br9600;
//      br9600, br14400,
//    br19200, br38400, br56000, br57600, br115200, br128000, br256000
      ComIonizer.StopBits           := sb1;
      ComIonizer.FlowControl.OutCtsFlow := False;
      ComIonizer.FlowControl.OutDsrFlow := False;
      ComIonizer.FlowControl.XonXoffOut := False;
      ComIonizer.FlowControl.XonXoffIn := False;

      //ComIonizer.EventChars.EofChar := DefRs232.LF; // Enter �� ���� Event �߻��ϵ���..
      ComIonizer.EventChars.EventChar := DefRs232.CR;
      ComIonizer.OnRxChar  := ReadVaCom;

      ComIonizer.Open;
      m_bConnected := True;
      SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_CONNECTION,1,sTemp);
    except
      // 0 : disconnect, 1 : Connect , 2 : NONE;
      SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_CONNECTION,0,sTemp);
//    except on E : Exception do
//      CodeSite.SendException(E);
//      OnRevSwData(Format('0%d',[nPort]),True);
    end;
    tmIonAliveCheck.Enabled := True;
  end
  else begin
//    sTemp := Format('0%d',[nPort]);
//    OnRevSwData(sTemp ,True);
    tmIonAliveCheck.Enabled := False;
    SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_CONNECTION,2,'NONE');

    if ComIonizer is TVaComm then begin
      ComIonizer.Close;
    end;
  end;

end;

constructor TIonizer.Create(nIdx : Integer; hMain, hTest :HWND; nMsgType : Integer);
begin
  FReadySwData := 0;
  m_hMain := hMain;
  m_nIdx  := nIdx;
  m_nMsgType := nMsgType;
  ComIonizer := TVaComm.Create(nil);
  FIsIgnoreNg := False;

  tmIonTimeOut := TTimer.Create(nil);
  tmIonTimeOut.Interval := 300;
  tmIonTimeOut.Enabled := False;
  tmIonTimeOut.OnTimer := OnTimeIonTimeOut;

  tmIonAliveCheck := TTimer.Create(nil);
  tmIonAliveCheck.Interval := 1000;
  tmIonAliveCheck.Enabled := False;
  tmIonAliveCheck.OnTimer := OnTimeIonizerCheck;

  m_bForceStop := False;
  // sbl, sob.
  m_nConnectCnt := 0;
  m_bConnected  := False;
end;

destructor TIonizer.Destroy;
begin
  if tmIonAliveCheck <> nil then begin
    tmIonAliveCheck.Enabled := False;
    tmIonAliveCheck.Free;
    tmIonAliveCheck := nil;
  end;
  if tmIonTimeOut <> nil then begin
    tmIonTimeOut.Enabled := False;
    tmIonTimeOut.Free;
    tmIonTimeOut := nil;
  end;
  if ComIonizer is TVaComm then begin
    ComIonizer.Close;
    ComIonizer.Free;
    ComIonizer := nil;
  end;
  inherited;
end;

function TIonizer.IsConnectIonizer(sData: string; var sRetStr : string): Boolean;
var
  slTemp : TStringList;
  bRet : boolean;
  sTemp : string;
begin
  // Ionblow : $C1,1,0,0,0,0,1,0,0,1*6F
  // Ionbar : $B5,1,8,>,5,5,5,5,0,1*6D
  // Ionbar : $BB,1,260,480,08,0,1*30
  // $ : Start Code, B : Ionbar, 5 : Model (SIB4)
  // 1 : Address, 8 : Frequency(30 Hz), > : Duty (62:0x3C)
  // 5 : PV, 5 : NV, 5: PC, 5 : NC, 0 : Alarm State ( 1 : H/V Alarm )
  // 1 : RUN ( 0: Stop )
  slTemp := TStringList.Create;
  sRetStr := '';
  bRet := True;
  try
    ExtractStrings([','], [], PWideChar(sData), slTemp);

    if FModelType = 2 then begin
      if slTemp.Count > 6 then begin
        if slTemp[5] <> '0' then begin
          sRetStr := sRetStr + 'H/V Alarm';
          bRet := False;
        end;
        sTemp := slTemp[6];
        if sTemp[1] = '0' then begin
          sRetStr := sRetStr + 'Stop Status';
          bRet := False;
        end;
      end
      else begin
        sRetStr := 'Protocol Format';
      end;

    end
    else begin
      if slTemp.Count > 9 then begin
        if slTemp[8] <> '0' then begin
          sRetStr := sRetStr + 'H/V Alarm';
          bRet := False;
        end;
        sTemp := slTemp[9];
        if sTemp[1] = '0' then begin
          sRetStr := sRetStr + 'Stop Status';
          bRet := False;
        end;
      end
      else begin
        sRetStr := 'Protocol Format';
      end;
    end;
  finally
    slTemp.Free;
  end;
  Result := bRet;
end;

procedure TIonizer.OnTimeIonizerCheck(Sender: TObject);
begin
  SendMsg(',REQ,1');
  tmIonTimeOut.Enabled := True;
end;

procedure TIonizer.OnTimeIonTimeOut(Sender: TObject);
var
  sMsg : string;
begin

  if FIsIgnoreNg then begin
    m_nConnectCnt := 0;
    Exit;
  end;

  if m_nConnectCnt > 10 then begin
    m_nConnectCnt := 10;
    if m_bConnected then begin
      m_bConnected := False;
      sMsg := Format('COM%d',[FCurPort]);
      SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_CONNECTION,3,sMsg);
      SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,'Ionizer No Respose');
    end;
    m_bConnected := False;

  end;
  Inc(m_nConnectCnt);
end;

procedure TIonizer.ReadVaCom(Sender: TObject; Count: Integer);
var
  sTemp : string;
  nPos, i : Integer;
  sData : AnsiString;
  sPacket: String;
  buff : TIdBytes;
begin
  try
    if m_bScriptControl then begin
      Exit;
    end;
    sData := string(ComIonizer.ReadText);
    if FModelType <> 0 then begin
      nPos := Pos('$C1',sData);
    end
    else begin
      nPos := Pos('$C2',sData);
    end;
    tmIonTimeOut.Enabled := False;
    //SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR] RX : '+ sTemp+ sData);
    if IsIgnoreNg then Exit;


    if nPos > 0 then begin
      m_nConnectCnt := 0;
      if IsConnectIonizer(sPacket, sTemp) then begin
        m_bConnected := True;
      end
      else begin
        SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,sTemp);
        m_bConnected := False;
      end;


      m_nConnectCnt := 0;
      if IsConnectIonizer(sData, sTemp) then begin
        m_bConnected := True;
        SendMainGuiDisplay(DefCommon.MSG_MODE_DISPLAY_CONNECTION,1,'Connected');
      end
      else begin
        m_bConnected := False;
        SendMainGuiDisplay(DefCommon.MSG_MODE_DISPLAY_CONNECTION,3,'Disconnected('+sTemp+')');
      end;
    end
    else begin
      if m_nConnectCnt > 3 then begin
        m_nConnectCnt := 10;
        if m_bConnected then begin
          //Common.MLog(DefCommon.MAX_SYSTEM_LOG,'Ionizer Read Data: '+sData);
          SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR] RX : '+ sTemp+ sData);
          SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,'Disconnect : '+sData);
        end;
        m_bConnected := False;
      end;
      Inc(m_nConnectCnt);
    end;
//  sData := string(ComIonizer.ReadText);
//  SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR]'+sData);
//  if IsIgnoreNg then Exit;
//  //SetLength(buff,Count);
//
////  sData := string(ComIonizer.ReadText);
//  // RX DATA : $B5,1,8,>,5,5,5,5,0,1*6D
//
//  sTemp := Format('(%d) ',[Count]);
//  SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR] RX : '+ sTemp+ sData);
//
//  m_sReadData:= m_sReadData + sData;
//
//  if m_sReadData[1] <> '$' then begin
//    //Packet ���� ���� $�� �ƴϸ� ���� Ŭ���� ó��
//    m_sReadData:= '';
//    Exit;
//  end;
//  if FModelType = 2 then begin
//    if Length(m_sReadData) < 25 then Exit;
//
//    sPacket:= Copy(m_sReadData, 1, 25);
//    m_sReadData:= Copy(m_sReadData, 25, Length(m_sReadData)-25);
//  end
//  else begin
//    if Length(m_sReadData) < 26 then Exit;
//
//    sPacket:= Copy(m_sReadData, 1, 26);
//    m_sReadData:= Copy(m_sReadData, 26, Length(m_sReadData)-26);
//  end;
//
//  //sTemp := format('sPacket:%s, m_sReadData=%s',[sPacket, m_sReadData]);
//  sTemp := format('[ION BAR] RX: %s',[sPacket]);
//  SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,sTemp);
//
//  if FModelType = 0 then begin
//    nPos := Pos('$B5',sPacket);
//  end
//  else if FModelType = 2 then begin
//    nPos := Pos('$BB',sPacket);
//  end
//  else begin
//    nPos := Pos('$B6',sPacket);
//  end;
//  tmIonTimeOut.Enabled := False;
//  if nPos > 0 then begin
//    m_nConnectCnt := 0;
//    if IsConnectIonizer(sPacket, sTemp) then begin
//      m_bConnected := True;
//      //SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,1,'Connected');
//    end
//    else begin
//      //if m_bConnected then begin //���� �߿� �ѹ��� ������
//        //SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,'Ionizer Status NG('+sTemp+')');
//        SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,sTemp);
//      //end;
//      m_bConnected := False;
//    end;
//
//  end
//  else begin
//    if m_nConnectCnt > 3 then begin
//      m_nConnectCnt := 10;
//      if m_bConnected then begin
//        if FModelType = 0 then sTemp := 'SIB4'
//        else if FModelType = 1 then sTemp := 'SIB4A'
//        else if FModelType = 2 then sTemp := 'SIB5S';
//
//
//        Common.MLog(DefCommon.MAX_SYSTEM_LOG,'Ionizer Read Data: '+sPacket);
//        SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_ERR_MSG,3,sTemp + ' Model Config Check!');
//      end;
//      m_bConnected := False;
//    end;
//    Inc(m_nConnectCnt);
//  end;
  //


{  m_nConnectCnt := 0;
  m_bConnected  := False;}
//  CodeSite.Send(sData);
//  SendTestGuiDisplay(DefCommon.MSG_MODE_IONIZER_STATUS,sData);
//  if Assigned(OnRevIonizerData) then  OnRevIonizerData(m_bConnected, sPacket);

  except
    //��ȿ���� ���� ���ڿ��� ��� ����(madException) ����: RichEdit line insertion error.
    on E: Exception do  begin

      Common.MLog(DefCommon.MAX_SYSTEM_LOG, 'MLog Exception:' + E.Message);
    end;
  end;
end;

procedure TIonizer.SendMainGuiDisplay(nGuiMode, nConnect: integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  GuiLightData :  RGuiIonizer;
begin

  GuiLightData.MsgType := m_nMsgType;
  GuiLightData.Channel := m_nIdx;
  GuiLightData.Mode    := nGuiMode;
  GuiLightData.Param1  := nConnect;
  GuiLightData.Msg     := sMsg;
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(GuiLightData);
  ccd.lpData      := @GuiLightData;
  SendMessage(m_hMain,WM_COPYDATA,0, LongInt(@ccd));
end;


procedure TIonizer.SendMsg(sData: string);
var
  sSendData : Ansistring;
  txBuf : TIdBytes;
  sCheckSum, sTemp : string;
  btCheckSum : byte;
  i : integer;
  dwTemp : DWORD;
begin

  if FIsIgnoreNg then Exit;

//  if FModelType = 1 then begin
//    sTemp := ('B6' + sData) ;
//  end
//  else if FModelType = 2 then begin
//    sTemp := ('BB' + sData) ;
//  end
//  else begin
//    sTemp := ('B5' + sData) ;
//  end;
  if FModelType <> 0 then begin
    sSendData := AnsiString('$C1' + sData) ;
  end
  else begin
    sSendData := AnsiString('$C2' + sData) ;
  end;
  SetLength(txBuf,Length(sSendData));
  CopyMemory(@txBuf[0],@sSendData[1],Length(sSendData));
  btCheckSum := 0;
  if FNewProtocol then begin
    for i := 1 to  Length(sSendData) do begin
      btCheckSum := btCheckSum xor byte(txBuf[i]);
    end;
  end
  else begin
    for i := 0 to Length(sSendData) do begin
      if i = 0 then btCheckSum := byte(txBuf[i])
      else          btCheckSum := btCheckSum xor byte(txBuf[i]);
    end;
  end;

  sCheckSum := Format('*%0.2x',[btCheckSum]);
  sSendData :=  sSendData + AnsiString(sCheckSum) + (DefRs232.CR)+ (DefRs232.LF);
  if ComIonizer.Active then begin
    ComIonizer.WriteText((sSendData));
    if (sData = ',STP,1') or (sData = ',RUN,1') then begin
      SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR] CH : '+ IntToStr(m_nIdx) +'TX :'+sSendData);
    end;
  end;
//  ///SetLength(txBuf,Length(sTemp));
//  sSendData := AnsiString(sTemp);
//  //Checksum
//  btCheckSum:= ord(sSendData[1]);
//  for i := 2 to Length(sSendData) do begin
//    btCheckSum:= btCheckSum xor ord(sSendData[i]);
//  end;
//  btCheckSum := btCheckSum and $00ff;
//  sSendData:= '$' + sSendData + Format('*%0.2x',[btCheckSum]) + (DefRs232.CR)+ (DefRs232.LF);;
//(*
//  CopyMemory(@txBuf[0],@sSendData[1],Length(sTemp));
//  dwTemp := txBuf[i];
//  for i := 1 to Length(sTemp) do begin
//    dwTemp := dwTemp xor txBuf[i];
//    dwTemp := dwTemp and $00ff;
//  end;
//  btCheckSum := Byte(dwTemp);
//  sCheckSum := Format('*%0.2x',[btCheckSum]);
//  sTemp :=  sTemp + (sCheckSum) + (DefRs232.CR)+ (DefRs232.LF);
//  sSendData := AnsiString('$'+sTemp);
//*)
//  if ComIonizer.Active then begin
//    ComIonizer.WriteText((sSendData));
//    SendMainGuiDisplay(CommIonizer.MSG_MODE_IONIZER_LOG,3,'[ION BAR] CH : '+ IntToStr(m_nIdx) +'TX :'+sSendData);
//  end;
end;

procedure TIonizer.SendRequest;
begin
  SendMsg(',REQ,1');
end;

procedure TIonizer.SendRun;
begin
  //'$B5,RUN,1,*CS' + CRLF
  //���� ����
  SendMsg(',RUN,1');
end;

procedure TIonizer.SendStop;
begin
  //'$B5,STP,1,*CS' + CRLF
  //���� ����
  SendMsg(',STP,1');
end;

procedure TIonizer.SendTestGuiDisplay(nGuiMode: Integer; sMsg: string);
var
  ccd         : TCopyDataStruct;
  GuiLightData :  RGuiIonizer;
begin

  GuiLightData.MsgType := m_nMsgType;
  GuiLightData.Channel := 0;
  GuiLightData.Mode    := nGuiMode;
  GuiLightData.Param1  := m_nIdx;
  GuiLightData.Msg     := sMsg;
  ccd.dwData      := 0;
  ccd.cbData      := SizeOf(GuiLightData);
  ccd.lpData      := @GuiLightData;
  SendMessage(m_hTest,WM_COPYDATA,0, LongInt(@ccd));
end;

procedure TIonizer.SetIsIgnoreNg(const Value: boolean);
begin
  FIsIgnoreNg := Value;
end;

procedure TIonizer.SetNewProtocol(const Value: Boolean);
begin
  FNewProtocol := Value;
end;

procedure TIonizer.SetOnRevIonizerData(const Value: InIonizerEvent);
begin
  FOnRevIonizerData := Value;
end;


end.
