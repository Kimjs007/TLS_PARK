unit FormDioDisplayAlarm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls, DefDio, CommonClass,
  Vcl.StdCtrls, RzButton,DefCommon , CtrlDio_Tls, RzLine, CommModbusRtuTempPlate;

type
  ///<summary>Alarm 발생 시 알람 발생한 위치 표시</summary>
  TfrmDisplayAlarm = class(TForm)
    imgEquipment: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    mmoMessage: TMemo;
    pnImage: TPanel;
    tmrFlickering: TTimer;
    pnAlarmMessage: TPanel;
    lblTitle: TLabel;
    shpDi16NG: TShape;
    btnResetError: TRzBitBtn;
    btnExit: TRzBitBtn;
    btnStopBuzzer: TRzBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    tmrErrchecking: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmrFlickeringTimer(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnResetErrorClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStopBuzzerClick(Sender: TObject);
    procedure tmrErrcheckingTimer(Sender: TObject);
  private
    { Private declarations }
    ///<summary>Alarm Data List Array</summary>
    m_naAlarmData: array [0.. DefDio.ERR_LIST_MAX] of Byte;
    shpSensorPos : array[0 .. DefDio.MAX_IN_CNT] of TShape;
    pnlIoName    : array[0 .. DefDio.MAX_IN_CNT] of TPanel;
    ///<summary>알람 영역 깜빡임 처리</summary>
    procedure FlickeringShape(AStyle: TBrushStyle);
    procedure ShapeCheck(nIdx : Integer; InShape : TShape; bIsNG : Boolean);
    procedure SetPosition;
  public
    { Public declarations }
    procedure RefreshDisplay;
  end;

var
  frmDisplayAlarm: TfrmDisplayAlarm;

implementation

{$R *.dfm}

{ TDispAlarmForm }

procedure TfrmDisplayAlarm.FormCreate(Sender: TObject);
var
sImageName : string;
  i: Integer;
begin

  mmoMessage.Lines.Clear;
  for i := 0 to DefDio.IN_MAX do begin
    shpSensorPos[i] := TShape.Create(Self);
    shpSensorPos[i].Parent := pnImage;
    shpSensorPos[i].Height := 12;
    shpSensorPos[i].Width  := 12;
    shpSensorPos[i].Left   := 0;
    shpSensorPos[i].Top    := 0;
    shpSensorPos[i].Shape  := stRoundRect;
    shpSensorPos[i].Visible := False;

    pnlIoName[i]        := TPanel.Create(Self);
    pnlIoName[i].Parent := pnImage;
    pnlIoName[i].Height := 16;
    pnlIoName[i].Width  := 24;
    pnlIoName[i].ParentBackground := False;
    pnlIoName[i].BevelOuter := bvNone;
    pnlIoName[i].Color  := clYellow;
    pnlIoName[i].StyleElements := [];
    pnlIoName[i].Caption := Format('I%0.2d',[i]);
    pnlIoName[i].Font.Size := 8;
    pnlIoName[i].Visible   := False;
  end;
  pnlIoName[DefDio.IN_WATER_LEAK_SEN1].Caption := Format('L%0.2d',[DefDio.IN_WATER_LEAK_SEN1]);
  pnlIoName[DefDio.IN_WATER_LEAK_SEN2].Caption := Format('L%0.2d',[DefDio.IN_WATER_LEAK_SEN2]);
  pnlIoName[DefDio.IN_WATER_LEAK_SEN3].Caption := Format('L%0.2d',[DefDio.IN_WATER_LEAK_SEN3]);
  pnlIoName[DefDio.IN_WATER_LEAK_SEN1].Color   := $00FFD0D0;
  pnlIoName[DefDio.IN_WATER_LEAK_SEN2].Color   := $00FFD0D0;
  pnlIoName[DefDio.IN_WATER_LEAK_SEN3].Color   := $00FFD0D0;

  SetPosition;

end;


procedure TfrmDisplayAlarm.ShapeCheck(nIdx : Integer; InShape : TShape; bIsNG : Boolean);
begin
  if not bIsNG then begin
    InShape.Brush.Color := clLime;
    InShape.Pen.Color   := clLime;
  end
  else begin
    InShape.Brush.Color := clRed;
    InShape.Pen.Color   := clRed;
  end;

end;

procedure TfrmDisplayAlarm.FormShow(Sender: TObject);
begin
  SetWindowPos(Self.handle, HWND_TOPMOST, Self.Left, Self.Top, Self.Width, Self.Height,0);
  RefreshDisplay;
end;

procedure TfrmDisplayAlarm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrFlickering.Enabled:= False;
  Action:= caFree;
  frmDisplayAlarm:= nil;
end;

procedure TfrmDisplayAlarm.SetPosition;
var
  i: Integer;
begin
  for i := 0 to DefDio.IN_MAX do begin

    case i of
      DefDio.IN_FAN_1            : begin shpSensorPos[i].Top := 319; shpSensorPos[i].Left := 169;  shpSensorPos[i].Width := 26;    shpSensorPos[i].Height := 32;   end;
      DefDio.IN_FAN_2            : begin shpSensorPos[i].Top := 275; shpSensorPos[i].Left := 169;  shpSensorPos[i].Width := 26;    shpSensorPos[i].Height := 32;   end;
      DefDio.IN_FAN_3            : begin shpSensorPos[i].Top := 319; shpSensorPos[i].Left := 43;   shpSensorPos[i].Width := 26;    shpSensorPos[i].Height := 32;   end;
      DefDio.IN_FAN_4            : begin shpSensorPos[i].Top := 275; shpSensorPos[i].Left := 43;   shpSensorPos[i].Width := 26;    shpSensorPos[i].Height := 32;   end;
      DefDio.IN_TEMP             : begin shpSensorPos[i].Top := 283; shpSensorPos[i].Left := 24;   shpSensorPos[i].Width := 17;    shpSensorPos[i].Height := 20;   end;
      DefDio.IN_MC_MONITOR       : begin shpSensorPos[i].Top := 185; shpSensorPos[i].Left := 276;  shpSensorPos[i].Width := 17;    shpSensorPos[i].Height := 24;   end;
      DefDio.IN_EMO_FRONT        : begin shpSensorPos[i].Top := 185; shpSensorPos[i].Left := 255;  shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 24;   end;
      DefDio.IN_EMO_BACK         : begin shpSensorPos[i].Top := 201; shpSensorPos[i].Left := 557;  shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 24;   end;
      DefDio.IN_X_AXIS_SEN1      : begin shpSensorPos[i].Top := 763; shpSensorPos[i].Left := 270;  shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_X_AXIS_SEN2      : begin shpSensorPos[i].Top := 799; shpSensorPos[i].Left := 214;  shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_X_AXIS_SEN3      : begin shpSensorPos[i].Top := 763; shpSensorPos[i].Left := 156;  shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_X_AXIS_SEN4      : begin shpSensorPos[i].Top := 799; shpSensorPos[i].Left := 96;   shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_Z_UP_SEN         : begin shpSensorPos[i].Top := 435; shpSensorPos[i].Left := 160;  shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_Z_DOWN_SEN       : begin shpSensorPos[i].Top := 525; shpSensorPos[i].Left := 164;  shpSensorPos[i].Width := 33;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_DOOR_OPEN_FR     : begin shpSensorPos[i].Top := 127; shpSensorPos[i].Left := 119;  shpSensorPos[i].Width := 42;    shpSensorPos[i].Height := 124;  end;
      DefDio.IN_DOOR_OPEN_FL     : begin shpSensorPos[i].Top := 127; shpSensorPos[i].Left := 75;   shpSensorPos[i].Width := 42;    shpSensorPos[i].Height := 124;  end;
      DefDio.IN_DOOR_OPEN_RR     : begin shpSensorPos[i].Top := 129; shpSensorPos[i].Left := 601;  shpSensorPos[i].Width := 42;    shpSensorPos[i].Height := 124;  end;
      DefDio.IN_DOOR_OPEN_RL     : begin shpSensorPos[i].Top := 129; shpSensorPos[i].Left := 645;  shpSensorPos[i].Width := 42;    shpSensorPos[i].Height := 124;  end;
      DefDio.IN_MAIN_AIR_PRES  	 : begin shpSensorPos[i].Top := 287; shpSensorPos[i].Left := 233;  shpSensorPos[i].Width := 20;    shpSensorPos[i].Height := 30;   end;
      DefDio.IN_HC_PLATE_READY 	 : Continue;
      DefDio.IN_HC_PLATE_RUN   	 : Continue;
      DefDio.IN_HC_PLATE_ALARM 	 : Continue;
      DefDio.IN_WATER_PRES_LOW1  : begin shpSensorPos[i].Top := 501; shpSensorPos[i].Left := 13;   shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 30;   end;
      DefDio.IN_WATER_PRES_HIGH1 : begin shpSensorPos[i].Top := 501; shpSensorPos[i].Left := 13;   shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 30;   end;
      DefDio.IN_WATER_PRES_LOW2  : begin shpSensorPos[i].Top := 501; shpSensorPos[i].Left := 39;   shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 30;   end;
      DefDio.IN_WATER_PRES_HIGH2 : begin shpSensorPos[i].Top := 501; shpSensorPos[i].Left := 39;   shpSensorPos[i].Width := 24;    shpSensorPos[i].Height := 30;   end;
      DefDio.IN_WATER_LEAK_SEN1  : begin shpSensorPos[i].Top := 103; shpSensorPos[i].Left := 11;   shpSensorPos[i].Width := 36;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_WATER_LEAK_SEN2  : begin shpSensorPos[i].Top := 851; shpSensorPos[i].Left := 168;  shpSensorPos[i].Width := 28;    shpSensorPos[i].Height := 22;   end;
      DefDio.IN_WATER_LEAK_SEN3  : begin shpSensorPos[i].Top := 337; shpSensorPos[i].Left := 653;  shpSensorPos[i].Width := 36;    shpSensorPos[i].Height := 30;   end;
      else                         Continue;
    end;
    shpSensorPos[i].Visible := True;

    pnlIoName[i].Left := shpSensorPos[i].Left;
    pnlIoName[i].Top  := shpSensorPos[i].Top + shpSensorPos[i].Height;
    pnlIoName[i].Left := shpSensorPos[i].Left;
    pnlIoName[i].Visible := True;
  end;
end;


procedure TfrmDisplayAlarm.RefreshDisplay;
var
  i: Integer;
begin
  if ControlDio = nil then exit;

  mmoMessage.Lines.Clear;
  for i := 0 to DefDio.ERR_LIST_MAX  do begin
    m_naAlarmData[i] := ControlDio.AlarmData[i];
    if ControlDio.AlarmData[i] = 0 then continue;  //0일 경우 비교 불필요
    if ControlDio.AlarmMsg[i] <> '' then begin
      if IN_MC_MONITOR = i then begin
        mmoMessage.Lines.Add('Please push RESET Button');
      end;
      mmoMessage.Lines.Add(ControlDio.AlarmMsg[i]);
    end;
  end; //for I := 0 to 5 do

  for i := 0 to DefDio.IN_MAX do begin
    if i in [DefDio.IN_SW_ON_CH1 .. DefDio.IN_SW_OFF_ALLCH] then Continue;
    ShapeCheck(i,shpSensorPos[i],ControlDio.AlarmData[i] <> 0);
  end;

  if (ControlDio.AlarmData[DefDio.IN_WATER_PRES_LOW1] = 1) or (ControlDio.AlarmData[DefDio.IN_WATER_PRES_HIGH1] = 1) then begin
    shpSensorPos[DefDio.IN_WATER_PRES_LOW1].Visible   := ControlDio.AlarmData[DefDio.IN_WATER_PRES_LOW1] = 1;
    shpSensorPos[DefDio.IN_WATER_PRES_HIGH1].Visible  := ControlDio.AlarmData[DefDio.IN_WATER_PRES_HIGH1] = 1;
  end
  else begin
    shpSensorPos[DefDio.IN_WATER_PRES_LOW1].Visible   := True;
    shpSensorPos[DefDio.IN_WATER_PRES_HIGH1].Visible  := True;
  end;

  if (ControlDio.AlarmData[DefDio.IN_WATER_PRES_LOW2] = 1) or (ControlDio.AlarmData[DefDio.IN_WATER_PRES_HIGH2] = 1) then begin
    shpSensorPos[DefDio.IN_WATER_PRES_LOW2].Visible   := ControlDio.AlarmData[DefDio.IN_WATER_PRES_LOW2] = 1;
    shpSensorPos[DefDio.IN_WATER_PRES_HIGH2].Visible  := ControlDio.AlarmData[DefDio.IN_WATER_PRES_HIGH2] = 1;
  end
  else begin
    shpSensorPos[DefDio.IN_WATER_PRES_LOW2].Visible   := True;
    shpSensorPos[DefDio.IN_WATER_PRES_HIGH2].Visible  := True;
  end;
end;

procedure TfrmDisplayAlarm.btnResetErrorClick(Sender: TObject);
var
  i: Integer;
begin
  ControlDio.ResetError(0);
//  Close;
end;

procedure TfrmDisplayAlarm.btnStopBuzzerClick(Sender: TObject);
begin
  ControlDio.MelodyOn:= False;
end;

procedure TfrmDisplayAlarm.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDisplayAlarm.tmrErrcheckingTimer(Sender: TObject);
var
  bRet : Boolean;
  i : Integer;
begin
  bRet := True;
  for i := 0 to DefDio.ERR_LIST_MAX  do begin
    if ControlDio.AlarmData[i] = 0 then continue;
    bRet := False;
  end;
  if bRet then begin
    ControlDio.MelodyOn:= False;
    Close;
    Exit;
  end;
end;

procedure TfrmDisplayAlarm.tmrFlickeringTimer(Sender: TObject);
var
  i : Integer;
  bRet : boolean;
begin
  if tmrFlickering.Tag = 0 then
  begin
    tmrFlickering.Tag:= 1;
    lblTitle.Color:= clYellow;
    FlickeringShape(bsSolid);
  end else
  begin
    tmrFlickering.Tag:= 0;
    lblTitle.Color:= clRed;
    FlickeringShape(bsBDiagonal);
  end;

  // NG 상태 변환 바로 GUI에 표시 안되는 문제 처리.
  bRet := False;
  for i := 0 to DefDio.ERR_LIST_MAX  do begin
    if m_naAlarmData[i] <> ControlDio.AlarmData[i] then begin
      bRet := True;
      Break;
    end;
  end;
  if bRet then RefreshDisplay;
end;

procedure TfrmDisplayAlarm.FlickeringShape(AStyle: TBrushStyle);
var
  I: Integer;
begin
  for I := 0 to Pred(pnImage.ControlCount) do  begin
    if pnImage.Controls[I] is TShape then  begin
      if pnImage.Controls[I].Visible then  begin
        //(pnImage.Controls[I] as TShape).Brush.Color:= clRed; //bsClear후에 색상 없어짐 방지
        (pnImage.Controls[I] as TShape).Brush.Style:= AStyle;
      end;
    end;
  end;
end;

end.
