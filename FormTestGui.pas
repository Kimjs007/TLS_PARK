unit FormTestGui;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ALed, RzPanel, RzButton, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  Vcl.Themes, System.UITypes, TILed, AdvListV, RzStatus, Vcl.StdCtrls, Dll_CASDK2, SwitchBtn, Vcl.ComCtrls, DfsFtp,
  DefScript, CtrlDio_Tls, System.DateUtils, Inifiles, Registry,DefPG, DefCommon, {DBModule,} Vcl.AppEvnts, RzCommon,
  DefDio, FormDioDisplayAlarm, CommModbusRtuTempPlate,
  ShellApi, AdvSmoothTouchKeyBoard, AdvSysKeyboardHook, RzCmboBx, VaClasses, VaComm{, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.BubbleCh};

type
  TForm4 = class(TForm)
    grpDioIn: TRzGroupBox;
    ledCom: ThhALed;
    grpDioOut: TRzGroupBox;
    mmoLog: TMemo;
    cboComm: TRzComboBox;
    btnPgFwDownload: TRzBitBtn;
    VaComm1: TVaComm;
    procedure FormCreate(Sender: TObject);
    procedure btnPgFwDownloadClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WMCopyData(var Msg : TMessage); message WM_COPYDATA;
  private
    { Private declarations }
    ledIn : array[0 .. DefDio.MAX_IO_CNT] of ThhALed;
    pnlIn : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;
    pnlDioIn : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;

    ledOut : array[0 .. DefDio.MAX_IO_CNT] of ThhALed;
    btnOutSig : array[0 .. DefDio.MAX_IO_CNT] of TRzBitBtn;
    pnlOut : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;
    pnlDioOut : array[0 .. DefDio.MAX_IO_CNT] of TRzPanel;

    procedure MakeDIOSignal;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

{ TForm4 }

procedure TForm4.btnPgFwDownloadClick(Sender: TObject);
begin
  CommTempPlate := TCommModbusRtuTempPlateMessage.Create(Self.Handle,1,1000);
  CommTempPlate.Connect(cboComm.ItemIndex);
end;

procedure TForm4.FormCreate(Sender: TObject);
var
  i : Integer;
begin
//  MakeDIOSignal;
//  try
//    ControlDio := TControlDio.Create(Self.Handle,DefCommon.MSG_TYPE_CTL_DIO);
//    frmDisplayAlarm:= TfrmDisplayAlarm.Create(Self);
//
////    for i := 0 to DefDio.IN_MAX do begin
////      ControlDio.AlarmData[i]:= 1;
////    end;
//    ControlDio.AlarmData[29]:= 1;
//    frmDisplayAlarm.ShowModal;
//    frmDisplayAlarm.Free;
//    frmDisplayAlarm:= nil;
//  finally
//    ControlDio.Free;
//    ControlDio := nil;
//  end;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  if CommTempPlate <> nil then begin
    CommTempPlate.Free;
    CommTempPlate := nil;
  end;
end;

procedure TForm4.MakeDIOSignal;
const
  asDioIn : array[0..Pred(DefDio.MAX_IN_CNT)] of string
  = ('Bottom Right FAN Run(FAN1)      '
    ,'Top Right FAN Run(FAN2)        '
    ,'Bottom Left FAN Run(FAN3)      '
    ,'Top Left FAN Run(FAN4)         '
    ,'Teperatutre Alarm              '
    ,'M/C Monitoring                 '
    ,'Front EMO(EMO1) Push           '
    ,'Rear EMO(EMO2) Push            '
    ,'X Axis Sen1 Detacting          '
    ,'X Axis Sen2 Detacting          '
    ,'X Axis Sen3 Detacting          '
    ,'X Axis Sen4 Detacting          '
    ,'Z Axis Up Sen                  '
    ,'Z Axis Down Sen                '
    ,'Fornt Right Door Open(LK1)     '
    ,'Fornt Left Door Open(LK2)      '
    ,'Rear Right Door Open(LK3)      '
    ,'Rear Left Door Open(LK4)       '
    ,'1CH Pattern On Switch Push     '
    ,'1CH Pattern Off Switch Push    '
    ,'2CH Pattern On Switch Push     '
    ,'2CH Pattern Off Switch Push    '
    ,'3CH Pattern On Switch Push     '
    ,'3CH Pattern Off Switch Push    '
    ,'Start Switch Push              '
    ,'Stop Switch Push               '
    ,'Main Air Pressure Alram        '
    ,'Hot&Cold Plate Controller Ready'
    ,'Hot&Cold Plate Controller Run  '
    ,'Hot&Cold Plate System Alarm    '
    ,'IN 수압센서(Low)                 '
    ,'IN 수압센서(High)                '
    ,'OUT수압센서(Low)                 '
    ,'OUT수압센서(High)                '
    ,'누수감지센서1                     '
    ,'누수감지센서2                     '
    ,'누수감지센서3                     '
    ,'                               '
    ,'                               '
    ,'                               ');
  asDioOut : array[0..Pred(DefDio.MAX_OUT_CNT)] of string
  = ('RED LAMP'
    ,'YELLOW LAMP'
    ,'GREEN LAMP'
    ,'MELODY#1'
    ,'MELODY#2'
    ,'MELODY#3'
    ,'MELODY#4'
    ,'Worker Lamp Off'
    ,'XAxis Position1(Sol1)'
    ,'XAxis Position2(So2)'
    ,'XAxis Position3(Sol3)'
    ,'XAxis Position4(Sol4)'
    ,'Z Axis Up Sol5'
    ,'Z Axis Down Sol6'
    ,'Fornt Right Door Unlock(LK1)'
    ,'Fornt Left Door Unlock(LK2)'
    ,'Rear Right Door Unlock(LK3)'
    ,'Rear Left Door Unlock(LK4)'
    ,'1CH Pattern On Switch LEDOn'
    ,'1CH Pattern Off Switch LEDOn'
    ,'2CH Pattern On Switch LEDOn'
    ,'2CH Pattern Off Switch LEDOn'
    ,'3CH Pattern On Switch LEDOn'
    ,'3CH Pattern Off Switch LEDOn'
    ,'Start Switch LEDOn'
    ,'Stop Switch LEDOn'
    ,'1CH PG Power Off'
    ,'2CH PG Power Off'
    ,'3CH PG Power Off'
    ,'1CH IRSensor RaserOff'
    ,'2CH IRSensor RaserOff'
    ,'3CH IRSensor RaserOff'
    ,'검사완료','','','','','','','');
var
  i, nDiv, nMaxCnt,nInterval: Integer;
  nHeight, nLeft, nTop      : Integer;
  sTemp                     : string;
begin

  nMaxCnt := DefDio.MAX_IO_CNT-1;
  nHeight := 24;
  nInterval := 6;
  nDiv    := DefDio.MAX_IO_CNT div 2;
  // for In --------------------------------------------
  for i := 0 to nMaxCnt do begin
    if i < nDiv then  nLeft := 4
    else              nLeft := grpDioIn.Width div 2+ 4;

    if i in [0 , nDiv] then nTop := 20
    else                    nTop := pnlIn[i-1].Top + nHeight + nInterval;

    // Number.

    pnlIn[i] := TRzPanel.Create(nil);
    pnlIn[i].Parent := grpDioIn;
    pnlIn[i].Top          := nTop;
    pnlIn[i].Left         := nLeft;
    pnlIn[i].BevelWidth   := 1;
    pnlIn[i].FlatColor    := clBlack;
    pnlIn[i].BorderInner  := TframeStyleEx(fsNone);
    pnlIn[i].BorderOuter  := TframeStyleEx(fsFlat);
    pnlIn[i].Width        := nHeight;
    pnlIn[i].Height       := nHeight;
    pnlIn[i].Caption      := Format('%0.2d',[i]);//Common.DecToOct(i);
    pnlIn[i].Visible      := True;
    pnlIn[i].Font.Size      := 8;

    // Led.
    ledIn[i]              := ThhALed.Create(nil);
    ledIn[i].Parent       := grpDioIn;
    ledIn[i].Left         := pnlIn[i].Left + pnlIn[i].Width + 3;
    ledIn[i].Top          := nTop;
    ledIn[i].Height       := nHeight;
    ledIn[i].LEDStyle     := LEDSqLarge;
    ledIn[i].FalseColor   := clRed;
    ledIn[i].TrueColor    := clLime;
    ledIn[i].Blink        := False;
    ledIn[i].Visible      := True;
    ledIn[i].Value        := False;

    // Items.
    pnlDioIn[i] := TRzPanel.Create(nil);
    pnlDioIn[i].Parent        := grpDioIn;
    pnlDioIn[i].Left          := ledIn[i].Left + ledIn[i].Width + 3;
    pnlDioIn[i].BevelWidth    := 1;
    pnlDioIn[i].Top           := nTop;
    pnlDioIn[i].FlatColor     := clBlack;
    pnlDioIn[i].BorderInner   := TframeStyleEx(fsNone);
    pnlDioIn[i].BorderOuter   := TframeStyleEx(fsFlat);
    pnlDioIn[i].Width         := 180;
    pnlDioIn[i].Height        := pnlIn[i].Height;
    pnlDioIn[i].Visible       := True;
    pnlDioIn[i].Font.Name     := 'Tahoma';
    pnlDioIn[i].Font.Style    := [];
    pnlDioIn[i].Font.Size     := 8;
    sTemp := '';
    pnlDioIn[i].Caption := Trim(asDioIn[i]);
  end;

  // for Out --------------------------------------------
  for i := 0 to nMaxCnt do begin
    if i < nDiv then  nLeft := 4
    else              nLeft := grpDioOut.Width div 2+ 4;

    if i in [0 , nDiv] then nTop := 20
    else                    nTop := pnlIn[i-1].Top + nHeight + nInterval;

    pnlOut[i] := TRzPanel.Create(nil);
    pnlOut[i].Parent := grpDioOut;
    pnlOut[i].Top          := nTop;
    pnlOut[i].Left         := nLeft;
    pnlOut[i].BevelWidth   := 1;
    pnlOut[i].FlatColor    := clBlack;
    pnlOut[i].BorderInner  := TframeStyleEx(fsNone);
    pnlOut[i].BorderOuter  := TframeStyleEx(fsFlat);
    pnlOut[i].Width        := nHeight;
    pnlOut[i].Height       := nHeight;
    pnlOut[i].Caption      := Format('%0.2d',[i]);//Common.DecToOct(i);
    pnlOut[i].Visible      := True;
    pnlOut[i].Font.Size      := 8;

    // Led.
    ledOut[i]              := ThhALed.Create(Self);
    ledOut[i].Parent       := grpDioOut;
    ledOut[i].Left         := pnlOut[i].Left + pnlOut[i].Width + 3;
    ledOut[i].Top          := nTop;
    ledOut[i].Height       := nHeight;
    ledOut[i].LEDStyle     := LEDSqLarge;
    ledOut[i].FalseColor   := clRed;
    ledOut[i].TrueColor    := clLime;
    ledOut[i].Blink        := False;
    ledOut[i].Visible      := True;
    ledOut[i].Value        := False;

    // Items.
    pnlDioOut[i] := TRzPanel.Create(nil);
    pnlDioOut[i].Parent        := grpDioOut;
    pnlDioOut[i].Left          := ledIn[i].Left + ledIn[i].Width + 3;
    pnlDioOut[i].BevelWidth    := 1;
    pnlDioOut[i].Top           := nTop;
    pnlDioOut[i].FlatColor     := clBlack;
    pnlDioOut[i].BorderInner   := TframeStyleEx(fsNone);
    pnlDioOut[i].BorderOuter   := TframeStyleEx(fsFlat);
    pnlDioOut[i].Width         := 160;
    pnlDioOut[i].Height        := pnlOut[i].Height;
    pnlDioOut[i].Visible       := True;
    pnlDioOut[i].Font.Name     := 'Tahoma';
    pnlDioOut[i].Font.Style    := [];
    pnlDioOut[i].Font.Size     := 8;
    sTemp := '';
    pnlDioOut[i].Caption := asDioOut[i];

    btnOutSig[i]              := TRzBitBtn.Create(Self);
    btnOutSig[i].Parent       := grpDioOut;
    btnOutSig[i].Left         := pnlDioOut[i].Left + pnlDioOut[i].Width + 3;
    btnOutSig[i].Top          := pnlOut[i].Top;
    btnOutSig[i].Width        := 30;
    btnOutSig[i].Height       := pnlOut[i].Height;
    btnOutSig[i].Visible      := True;
    btnOutSig[i].Cursor       := crHandPoint;
    btnOutSig[i].Font.Name     := 'Tahoma';
    btnOutSig[i].Font.Style    := [];
    btnOutSig[i].Font.Size     := 8;
    btnOutSig[i].Caption       := 'On';
    btnOutSig[i].Tag           := i;
    //btnOutSig[i].OnClick       := OnEvtOutBtn;
  end;
end;

procedure TForm4.WMCopyData(var Msg: TMessage);
var
  nType, nCh, nMode : Integer;
  sDebug : string;
begin
  nType := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgType;
  nCh   := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;
  case nType of
    1 : begin
      nMode := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      case nMode of
        CommModbusRtuTempPlate.COMM_MODBUS_RTU_TEMP_PLATE_CONNECT : begin
          case CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param of
            0: mmoLog.Lines.Add('Disconnected: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
            1: mmoLog.Lines.Add('Connected: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
            2: mmoLog.Lines.Add('Timeout: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
          end;
        end;
        // 온도 Display.
        CommModbusRtuTempPlate.COMM_MODBUS_RTU_TEMP_PLATE_UPDATE : begin

        end;
        CommModbusRtuTempPlate.COMM_MODBUS_RTU_TEMP_PLATE_ADDLLOG : begin
          sDebug := FormatDateTime('(hh:mm:ss.zzz) : ', Now) + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
          mmoLog.Lines.Add( sDebug );
        end;
      end;

    end;
  end;
end;

end.
