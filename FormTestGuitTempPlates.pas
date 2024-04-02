unit FormTestGuitTempPlates;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, CommModbusRtuTempPlate, RzButton, Vcl.StdCtrls, RzCmboBx, ALed, Vcl.ExtCtrls, Vcl.Mask, RzEdit;

type
  TForm5 = class(TForm)
    ledCom: ThhALed;
    cboComm: TRzComboBox;
    btnPgFwDownload: TRzBitBtn;
    mmoLog: TMemo;
    RzBitBtn1: TRzBitBtn;
    RzBitBtn2: TRzBitBtn;
    cboWriteItem: TRzComboBox;
    RzBitBtn3: TRzBitBtn;
    cboCmd: TRzComboBox;
    RzBitBtn4: TRzBitBtn;
    RzBitBtn5: TRzBitBtn;
    grpMain: TGroupBox;
    Panel1: TPanel;
    RzEdit1: TRzEdit;
    procedure btnPgFwDownloadClick(Sender: TObject);
    procedure WMCopyData(var Msg : TMessage); message WM_COPYDATA;
    procedure RzBitBtn1Click(Sender: TObject);
    procedure RzBitBtn2Click(Sender: TObject);
    procedure RzBitBtn3Click(Sender: TObject);
    procedure RzBitBtn4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    pnlGroupPlates : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;

    pnlTitle, pnlReady, pnlRun, pnlAlarm : array[0 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;
    pnlHeating, pnlCooling, pnlSv, pnlPv, pnlMv : array[0 .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TPanel;
    btnRun, btnStop, btnReset : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzBitBtn;
    edtSv, edtPv, edtMv : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzEdit;
    cboTempPlate : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3] of TRzComboBox;
    pnlTempPlateAlarm   : array[CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM .. CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3,0 .. 7] of TPanel;
    procedure CreateGui;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.btnPgFwDownloadClick(Sender: TObject);
begin
  if cboComm.ItemIndex = 0 then begin
    ledCom.FalseColor := clLtGray;
    Exit;
  end;

  if CommTempPlate = nil then CommTempPlate := TCommModbusRtuTempPlateMessage.Create(Self.Handle,1,1000);
  CommTempPlate.Connect(cboComm.ItemIndex);
  ledCom.FalseColor := clRed;
end;

procedure TForm5.CreateGui;
var
  i, j, nLeft, nWidth, nTop, nTopSub : Integer;
  sItem : string;
begin
  nWidth := grpMain.Width div 4;  nTop := 0;
  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin
    nLeft := nWidth*i;
    pnlGroupPlates[i] := TPanel.Create(Self);
    pnlGroupPlates[i].Parent := grpMain;
    pnlGroupPlates[i].Top          := nTop;
    pnlGroupPlates[i].Left         := nLeft;
    pnlGroupPlates[i].Width        := nWidth;
    pnlGroupPlates[i].Height       := grpMain.Height - nTop - 10;
    pnlGroupPlates[i].Visible      := True;
    pnlGroupPlates[i].BevelOuter   := bvNone;

    case i of
      0 : sItem := 'SYSTEM'
      else sItem := Format('PLATE _ %d',[i]);
    end;
    pnlTitle[i] := TPanel.Create(Self);
    pnlTitle[i].Parent := pnlGroupPlates[i];
    pnlTitle[i].Top          := 20;
    pnlTitle[i].Left         := 0;
    pnlTitle[i].Width        := nWidth;
    pnlTitle[i].Height       := 30;
    pnlTitle[i].Caption      := sItem;
    pnlTitle[i].Visible      := True;
    pnlTitle[i].BevelOuter   := bvNone;
    pnlTitle[i].BevelKind    := bkFlat;

    pnlReady[i] := TPanel.Create(Self);
    pnlReady[i].Parent := pnlGroupPlates[i];
    pnlReady[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlReady[i].Left         := 10 ;
    pnlReady[i].Width        := (nWidth div 3) - 20;
    pnlReady[i].Height       := 20;
    pnlReady[i].Caption      := 'Ready';
    pnlReady[i].Visible      := True;
    pnlReady[i].BevelKind    := bkFlat;
    pnlReady[i].BevelOuter   := bvNone;
    pnlReady[i].Font.Style     := [];

    pnlRun[i] := TPanel.Create(Self);
    pnlRun[i].Parent := pnlGroupPlates[i];
    pnlRun[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlRun[i].Left         := (nWidth div 3) + 10 ;
    pnlRun[i].Width        := (nWidth div 3) - 20;
    pnlRun[i].Height       := 20;
    pnlRun[i].Caption      := 'RUN';
    pnlRun[i].Visible      := True;
    pnlRun[i].BevelKind    := bkFlat;
    pnlRun[i].BevelOuter   := bvNone;
    pnlRun[i].Font.Style     := [];

    pnlAlarm[i] := TPanel.Create(Self);
    pnlAlarm[i].Parent := pnlGroupPlates[i];
    pnlAlarm[i].Top          := pnlTitle[i].Height + pnlTitle[i].Top + 10;
    pnlAlarm[i].Left         := (nWidth div 3)*2+10 ;
    pnlAlarm[i].Width        := (nWidth div 3) - 20;
    pnlAlarm[i].Height       := 20;
    pnlAlarm[i].Caption      := 'ALARM';
    pnlAlarm[i].Visible      := True;
    pnlAlarm[i].BevelKind    := bkFlat;
    pnlAlarm[i].BevelOuter   := bvNone;
    pnlAlarm[i].Font.Style     := [];

    if i <> 0 then begin
      pnlHeating[i] := TPanel.Create(Self);
      pnlHeating[i].Parent := pnlGroupPlates[i];
      pnlHeating[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlHeating[i].Left         := 10 ;
      pnlHeating[i].Width        := (nWidth div 3) - 20;
      pnlHeating[i].Height       := 20;
      pnlHeating[i].Caption      := 'Heating';
      pnlHeating[i].Visible      := True;
      pnlHeating[i].BevelKind    := bkFlat;
      pnlHeating[i].BevelOuter   := bvNone;
      pnlHeating[i].Font.Style     := [];

      pnlCooling[i] := TPanel.Create(Self);
      pnlCooling[i].Parent := pnlGroupPlates[i];
      pnlCooling[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 10;
      pnlCooling[i].Left         := (nWidth div 3) + 10 ;
      pnlCooling[i].Width        := (nWidth div 3) - 20;
      pnlCooling[i].Height       := 20;
      pnlCooling[i].Caption      := 'Cooling';
      pnlCooling[i].Visible      := True;
      pnlCooling[i].BevelKind    := bkFlat;
      pnlCooling[i].BevelOuter   := bvNone;
      pnlCooling[i].Font.Style   := [];

      pnlSv[i] := TPanel.Create(Self);
      pnlSv[i].Parent := pnlGroupPlates[i];
      pnlSv[i].Top          := pnlHeating[i].Height + pnlHeating[i].Top + 10;
      pnlSv[i].Left         := 10 ;
      pnlSv[i].Width        := 20;
      pnlSv[i].Height       := 20;
      pnlSv[i].Caption      := 'SV';
      pnlSv[i].Visible      := True;
      pnlSv[i].BevelKind    := bkNone;
      pnlSv[i].BevelOuter   := bvNone;
      pnlSv[i].Font.Style     := [];

      pnlPv[i] := TPanel.Create(Self);
      pnlPv[i].Parent := pnlGroupPlates[i];
      pnlPv[i].Top          := pnlSv[i].Height + pnlSv[i].Top + 10;
      pnlPv[i].Left         := 10 ;
      pnlPv[i].Width        := 20;
      pnlPv[i].Height       := 20;
      pnlPv[i].Caption      := 'PV';
      pnlPv[i].Visible      := True;
      pnlPv[i].BevelKind    := bkNone;
      pnlPv[i].BevelOuter   := bvNone;
      pnlPv[i].Font.Style     := [];

      pnlMv[i] := TPanel.Create(Self);
      pnlMv[i].Parent := pnlGroupPlates[i];
      pnlMv[i].Top          := pnlPv[i].Height + pnlPv[i].Top + 10;
      pnlMv[i].Left         := 10 ;
      pnlMv[i].Width        := 20;
      pnlMv[i].Height       := 20;
      pnlMv[i].Caption      := 'MV';
      pnlMv[i].Visible      := True;
      pnlMv[i].BevelKind    := bkNone;
      pnlMv[i].BevelOuter   := bvNone;
      pnlMv[i].Font.Style     := [];

      edtSv[i]         := TRzEdit.Create(Self);
      edtSv[i].Parent  := pnlGroupPlates[i];
      edtSv[i].Width   := 80;
      edtSv[i].Height  := 22;
      edtSv[i].Top     := pnlSv[i].top;
      edtSv[i].Left    := pnlSv[i].Left + pnlSv[i].Width + 10;

      edtPv[i]         := TRzEdit.Create(Self);
      edtPv[i].Parent  := pnlGroupPlates[i];
      edtPv[i].Width   := 80;
      edtPv[i].Height  := 22;
      edtPv[i].Top     := pnlPv[i].top;
      edtPv[i].Left    := pnlPv[i].Left + pnlPv[i].Width + 10;

      edtMv[i]         := TRzEdit.Create(Self);
      edtMv[i].Parent  := pnlGroupPlates[i];
      edtMv[i].Width   := 80;
      edtMv[i].Height  := 22;
      edtMv[i].Top     := pnlMv[i].top;
      edtMv[i].Left    := pnlMv[i].Left + pnlMv[i].Width + 10;

      cboTempPlate[i]         := TRzComboBox.Create(Self);
      cboTempPlate[i].Parent  := pnlGroupPlates[i];
      cboTempPlate[i].Width   := 100;
      cboTempPlate[i].Height  := 22;
      cboTempPlate[i].Left    := edtSv[i].Width+edtSv[i].Left   + 2;
      cboTempPlate[i].Top     := edtSv[i].Top;
      cboTempPlate[i].Style   := csDropDownList;
      cboTempPlate[i].DropDownCount := 10;
      cboTempPlate[i].Tag     := i;
      cboTempPlate[i].Items.Clear;
      cboTempPlate[i].Items.Add('10');
      cboTempPlate[i].Items.Add('25');
      cboTempPlate[i].Items.Add('40');
      cboTempPlate[i].ItemIndex := 1;
//      cboTempPlate[i].OnClick := cboProbeSelectOnClickEvent;
    end;


    btnRun[i]              := TRzBitBtn.Create(Self);
    btnRun[i].Parent       := pnlGroupPlates[i];
    btnRun[i].Left         := 10;
    btnRun[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnRun[i].Width        := (nWidth div 3) - 20;
    btnRun[i].Height       := 30;
    btnRun[i].Visible      := True;
    btnRun[i].Cursor       := crHandPoint;
    btnRun[i].Font.Name     := 'Tahoma';
    btnRun[i].Font.Style    := [];
    btnRun[i].Font.Size     := 10;
    btnRun[i].Caption       := 'Run';
    btnRun[i].Tag           := i;
//    btnRun[i].OnClick       := OnEvtOutBtn;

    btnStop[i]              := TRzBitBtn.Create(Self);
    btnStop[i].Parent       := pnlGroupPlates[i];
    btnStop[i].Left         := (nWidth div 3) + 10 ;
    btnStop[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnStop[i].Width        := (nWidth div 3) - 20;
    btnStop[i].Height       := 30;
    btnStop[i].Visible      := True;
    btnStop[i].Cursor       := crHandPoint;
    btnStop[i].Font.Name     := 'Tahoma';
    btnStop[i].Font.Style    := [];
    btnStop[i].Font.Size     := 10;
    btnStop[i].Caption       := 'Ready';
    btnStop[i].Tag           := i+10;
//    btnStop[i].OnClick       := OnEvtOutBtn;

    btnReset[i]              := TRzBitBtn.Create(Self);
    btnReset[i].Parent       := pnlGroupPlates[i];
    btnReset[i].Left         := (nWidth div 3)*2 + 10 ;
    btnReset[i].Top          := pnlReady[i].Height + pnlReady[i].Top + 200;
    btnReset[i].Width        := (nWidth div 3) - 20;
    btnReset[i].Height       := 30;
    btnReset[i].Visible      := True;
    btnReset[i].Cursor       := crHandPoint;
    btnReset[i].Font.Name     := 'Tahoma';
    btnReset[i].Font.Style    := [];
    btnReset[i].Font.Size     := 10;
    btnReset[i].Caption       := 'Reset';
    btnReset[i].Tag           := i+20;
//    btnAlarm[i].OnClick       := OnEvtOutBtn;
    nTopSub := btnRun[i].Height + btnRun[i].Top + 20;
    for j := 0 to 7 do begin
      pnlTempPlateAlarm[i,j] := TPanel.Create(Self);
      pnlTempPlateAlarm[i,j].Parent := pnlGroupPlates[i];
      pnlTempPlateAlarm[i,j].Alignment    := taLeftJustify;
      pnlTempPlateAlarm[i,j].Top          := nTopSub + 22*j;
      pnlTempPlateAlarm[i,j].Left         := btnRun[i].Left ;
      pnlTempPlateAlarm[i,j].Width        := 200;
      pnlTempPlateAlarm[i,j].Height       := 20;
      pnlTempPlateAlarm[i,j].Caption      := '';
      pnlTempPlateAlarm[i,j].Visible      := True;
      pnlTempPlateAlarm[i,j].BevelKind    := bkNone;
      pnlTempPlateAlarm[i,j].BevelOuter   := bvNone;
      pnlTempPlateAlarm[i,j].Font.Style     := [];
    end;
  end;

  for i := CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_SYSTEM to CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_TYPE_PLATE3 do begin

    if i <> 0 then begin
      for j := 0 to 7 do begin
        case j of
          0 : pnlTempPlateAlarm[i,j].Caption := '1 Sensor Line Open Alarm';
          1 : pnlTempPlateAlarm[i,j].Caption := '2 Sensor Line Open Alarm';
          2 : pnlTempPlateAlarm[i,j].Caption := '3 Sensor Line Open Alarm';
          3 : pnlTempPlateAlarm[i,j].Caption := '4 Sensor Line Open Alarm';
          4 : pnlTempPlateAlarm[i,j].Caption := 'OT Alarm';
          5 : pnlTempPlateAlarm[i,j].Caption := 'Over heating Alarm';
          6 : pnlTempPlateAlarm[i,j].Caption := 'Over Cooling Alarm';
          7 : pnlTempPlateAlarm[i,j].Caption := 'Temperature range Alarm';
        end;
      end;

    end
    else begin
      for j := 0 to 7 do begin
        case j of
          0 : pnlTempPlateAlarm[i,j].Caption := 'EMS Alarm';
          1 : pnlTempPlateAlarm[i,j].Caption := 'Smoke Alarm';
          2 : pnlTempPlateAlarm[i,j].Caption := 'Power Lost Alarm';
          3 : pnlTempPlateAlarm[i,j].Caption := 'Chiler Alarm';
          4 : pnlTempPlateAlarm[i,j].Caption := 'Chiler CommError';
          5 : pnlTempPlateAlarm[i,j].Caption := '';
          6 : pnlTempPlateAlarm[i,j].Caption := '';
          7 : pnlTempPlateAlarm[i,j].Caption := '';
        end;
      end;
    end;
  end;
end;
{            3 : AddLog('EMS State');
            4 : AddLog('MC State');
            5 : AddLog('Power State');
            6 : AddLog('Reset State');
          end;
          CurrentStatus[nType].SystemSatus[i-3] := True;
        end
        else begin
          CurrentStatus[nType].SystemSatus[i-3] := False;
        end;
      end;
      for i := 1 to 5 do begin
        btValue := (btStatus2 shr i) and $01;
        if btValue = 1 then begin
          case i of
            1 : AddLog('EMS Alarm');
            2 : AddLog('Smoke Alarm');
            3 : AddLog('Power Lost Alarm');
            4 : AddLog('Chiler Alarm');
            5 : AddLog('Chiler CommError');}
procedure TForm5.FormCreate(Sender: TObject);
begin
  CreateGui;
end;

procedure TForm5.RzBitBtn1Click(Sender: TObject);
begin
  if CommTempPlate <> nil then begin
    CommTempPlate.ReadData(0,0,5);
    //CommTempPlate.ReadData(0,100,6)
  end;
end;

procedure TForm5.RzBitBtn2Click(Sender: TObject);
begin
  if CommTempPlate <> nil then begin
    CommTempPlate.ReadData(0,100,5)
  end;
end;

procedure TForm5.RzBitBtn3Click(Sender: TObject);
begin
  if CommTempPlate <> nil then begin
    case cboWriteItem.ItemIndex of
      0 : begin
        CommTempPlate.SetSystemStatus(cboCmd.ItemIndex);
      end
      else begin
        CommTempPlate.SetPlateStatus(cboWriteItem.ItemIndex,cboCmd.ItemIndex);
      end;
    end;
//    CommTempPlate.WriteAllData;
  end;
end;

procedure TForm5.RzBitBtn4Click(Sender: TObject);
var
  th :  TThread ;
begin
  if CommTempPlate = nil then Exit;

  th := TThread.CreateAnonymousThread(procedure
  var
    i: Integer;
  begin
    for i := 0 to 5 do begin
      CommTempPlate.ReadAllData;
      CommTempPlate.WriteAllData;
      sleep(1000);
    end;
  end);

  th.Start;
end;

procedure TForm5.WMCopyData(var Msg: TMessage);
var
  nType, nCh, nMode : Integer;
  sDebug : string;
  nValue : Integer;
begin
  nType := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.MsgType;
  nCh   := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Channel;
  case nType of
    1 : begin
      nMode := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Mode;
      case nMode of
        CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_CONNECT : begin
          case CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param of
            0: mmoLog.Lines.Add('Disconnected: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
            1: mmoLog.Lines.Add('Connected: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
            2: mmoLog.Lines.Add('Timeout: ' + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg);
          end;
          case CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param of
            0: ledCom.Value := False;
            1: ledCom.Value := True;
            2: ledCom.Value := False;
          end;
        end;
        // ¿Âµµ Display.
        CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_SV : begin
          nValue := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param2;
          case CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param of
            1: mmoLog.Lines.Add(Format('SV : CH1 %0.1f ¡ÆC',[nValue / 10]));
            2: mmoLog.Lines.Add(Format('SV : CH2 %0.1f ¡ÆC',[nValue / 10]));
            3: mmoLog.Lines.Add(Format('SV : CH3 %0.1f ¡ÆC',[nValue / 10]));
          end;
        end;
        CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_PV : begin
          nValue := CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param2;
          case CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Param of
            1: mmoLog.Lines.Add(Format('PV : CH1 %0.1f ¡ÆC',[nValue / 10]));
            2: mmoLog.Lines.Add(Format('PV : CH2 %0.1f ¡ÆC',[nValue / 10]));
            3: mmoLog.Lines.Add(Format('PV : CH3 %0.1f ¡ÆC',[nValue / 10]));
          end;
        end;
        CommModbusRtuTempPlate.COMM_MODBUS_TEMP_PLATE_ADDLLOG : begin
          sDebug := FormatDateTime('(hh:mm:ss.zzz) : ', Now) + CommModbusRtuTempPlate.PGUIThermometerMessage(PCopyDataStruct(Msg.LParam)^.lpData)^.Msg;
          mmoLog.Lines.Add( sDebug );
        end;
      end;
    end;
  end;
end;

end.
