unit FormNGMsg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, RzButton, Vcl.StdCtrls, RzLabel;

type
  TfrmNgMsg = class(TForm)
    pnlNgMsg: TPanel;
    btnClose: TRzBitBtn;
    lblShow: TRzLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNgMsg: TfrmNgMsg;
  frmHDDAlarm : TfrmNgMsg;
  frmHostAlarm : TfrmNgMsg;
  frmModelNgMsg : TfrmNgMsg;
implementation

{$R *.dfm}

procedure TfrmNgMsg.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNgMsg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Self.Name = 'frmNgMsg' then begin
    Action:= caFree;
    frmNgMsg:= nil;
  end;
end;

end.
