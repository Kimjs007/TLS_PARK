unit FormDoorOpenAlarmMsg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, RzButton, defDio, CommonClass, System.ImageList, Vcl.ImgList, AdvSmoothTouchKeyBoard;

type
  TfrmDoorOpenAlarmMsg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblWorker: TLabel;
    lblPhone: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    gbAdminClose: TGroupBox;
    edtPassword: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    btnClose: TRzBitBtn;
    lblTime: TLabel;
    btnResetError: TRzBitBtn;
    btnStopBuzzer: TRzBitBtn;
    btnShowAlarm: TRzBitBtn;
    btnKeyPad: TRzBitBtn;
    il1: TImageList;
    keyNumKeyPad: TAdvSmoothTouchKeyBoard;
    tmrRefresh: TTimer;
    pnlDoor_UpperLeft: TPanel;
    pnlDoor_UpperRight: TPanel;
    pnlDoor_LowerLeft: TPanel;
    pnlDoor_LowerRight: TPanel;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure tmrRefreshTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtPasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    procedure btnResetErrorClick(Sender: TObject);
    procedure btnStopBuzzerClick(Sender: TObject);
    procedure btnShowAlarmClick(Sender: TObject);
    procedure btnKeyPadClick(Sender: TObject);
  private
    { Private declarations }
    procedure CheckDoor;
  public
    { Public declarations }
    procedure CloseEnable(bEnable: Boolean);
  end;

var
  frmDoorOpenAlarmMsg: TfrmDoorOpenAlarmMsg;

implementation
uses CtrlDio_Tls;
{$R *.dfm}

procedure TfrmDoorOpenAlarmMsg.btnKeyPadClick(Sender: TObject);
begin
  keyNumKeyPad.Visible := not keyNumKeyPad.Visible;
  if edtPassword.CanFocus then edtPassword.SetFocus;

end;

procedure TfrmDoorOpenAlarmMsg.btnResetErrorClick(Sender: TObject);
var
  i: Integer;
begin
  ControlDio.ResetError(0);
//  for i := 0 to defDio.ERR_LIST_MAX do begin
//    ControlDio.AlarmData[i]:= 0;
//  end;
end;

procedure TfrmDoorOpenAlarmMsg.btnShowAlarmClick(Sender: TObject);
begin
  ControlDio.ErrorCheck;
//  frmMain_OC.tmDioAlarmTimer(Sender);
end;

procedure TfrmDoorOpenAlarmMsg.btnStopBuzzerClick(Sender: TObject);
begin
  ControlDio.MelodyOn:= False;
end;

procedure TfrmDoorOpenAlarmMsg.CheckDoor;
var
  bOpened: Boolean;
begin

  pnlDoor_UpperLeft.Visible := not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FR);
  pnlDoor_UpperRight.Visible := not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FL);
  pnlDoor_LowerLeft.Visible := not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_RR);
  pnlDoor_LowerRight.Visible := not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_RL);

  bOpened:= False;
  if not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FR) then begin
    bOpened:= True;
  end;
  if not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_FL) then begin
    bOpened:= True;
  end;
  if not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_RR) then begin
    bOpened:= True;
  end;
  if not ControlDio.ReadInSig(DefDio.IN_DOOR_OPEN_RL) then begin
    bOpened:= True;
  end;
//
  CloseEnable(not bOpened);
end;

procedure TfrmDoorOpenAlarmMsg.CloseEnable(bEnable: Boolean);
begin
  gbAdminClose.Visible:= bEnable;
  if bEnable then begin
    edtPassword.SetFocus;
  end;
end;

procedure TfrmDoorOpenAlarmMsg.edtPasswordKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    btnCloseClick(Sender);
  end;
end;

procedure TfrmDoorOpenAlarmMsg.FormClick(Sender: TObject);
begin
  if gbAdminClose.Visible then begin
    edtPassword.SetFocus;
  end;
end;

procedure TfrmDoorOpenAlarmMsg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  tmrRefresh.Enabled:= False;
  Action:= caFree;
  frmDoorOpenAlarmMsg:= nil;
end;

procedure TfrmDoorOpenAlarmMsg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if btnClose.Tag <> 1 then begin
    CanClose:= False;
  end;
end;

procedure TfrmDoorOpenAlarmMsg.FormShow(Sender: TObject);
begin
  CheckDoor;
  tmrRefresh.Enabled:= True;
//  lblPhone.Top := self.Height - 60;
//
//  lblWorker.Top := self.Height - 60;
//  lblWorker.Left := self.Width - 150;
end;

procedure TfrmDoorOpenAlarmMsg.tmrRefreshTimer(Sender: TObject);
begin
  lblTime.Caption:= FormatDateTime('HH:NN:SS', Now);
  CheckDoor;
end;

procedure TfrmDoorOpenAlarmMsg.btnCloseClick(Sender: TObject);
var
  sPass: String;
begin
  sPass:= FormatDateTime('HHMM', Now);
  if sPass <> edtPassword.Text then begin
    Application.MessageBox('Inconrrect Password', 'Error', MB_OK+MB_ICONSTOP);
    Exit;
  end;
  btnClose.Tag:= 1;
  Close;
end;

end.
