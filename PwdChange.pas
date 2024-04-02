unit PwdChange;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzPanel, RzButton, Vcl.ExtCtrls, CommonClass,
  System.UITypes;

type
  TfrmChangePassword = class(TForm)
    pnlPasswordChange: TRzPanel;
    btnChange: TRzBitBtn;
    btnCancel: TRzBitBtn;
    grpSystem: TRzGroupBox;
    pnlCurrent: TRzPanel;
    pnlChange: TRzPanel;
    pnlConfirm: TRzPanel;
    edCurPw: TRzEdit;
    edChangePw: TRzEdit;
    edConfirmPw: TRzEdit;
    procedure FormDestroy(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    function chk_password : Boolean;
  public
    { Public declarations }
  end;

var
  frmChangePassword: TfrmChangePassword;

implementation

{$R *.dfm}




procedure TfrmChangePassword.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangePassword.btnChangeClick(Sender: TObject);
var
  chk_pass : Boolean;
begin
  if (edCurPw.Text <> '') or (edChangePw.Text <> '') or (edConfirmPw.Text <> '') then
    chk_pass := chk_password
  else
    chk_pass := True;

  if chk_pass then begin
    Common.SystemInfo.password := edChangePw.Text;
    Common.SaveSystemInfo;
    edCurPw.Text := '';
    edChangePw.Text := '';
    edConfirmPw.Text := '';
    MessageDlg(#13#10 + 'Administrator Password is changed Successfully!', mtInformation, [mbOK], 0);
    Close;
  end;
end;

function TfrmChangePassword.chk_password: Boolean;
begin
  if Common.SystemInfo.password <> edCurPw.Text then begin
    Result := False;
    MessageDlg(#13#10 + 'Current Password is not matched!', mtError, [mbOK], 0);
    edCurPw.SetFocus;
    Exit;
  end;
  if edChangePw.Text <> edConfirmPw.Text then begin
    Result := False;
    MessageDlg(#13#10 + 'Confirm Password is not matched to New password!', mtError, [mbOK], 0);
    edConfirmPw.SetFocus;
    Exit;
  end;
  Result := True;
end;

procedure TfrmChangePassword.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmChangePassword.FormDestroy(Sender: TObject);
begin
  frmChangePassword := nil;
end;

end.
