unit FormSystemSetup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzPanel, Vcl.ExtCtrls, RzCommon,
  RzTabs, RzRadChk, RzButton, RzCmboBx, Vcl.Grids, AdvObj, BaseGrid, AdvGrid, IniFiles, CommonClass, DefCommon,
  {FileTrans,} PwdChange, RzLstBox, RzShellDialogs, System.UITypes, formLogIn, DfsFtp,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, AdvUtil, RTTI,

  RzRadGrp,ShellApi

{$IFDEF CA410_USE}
,DllCasSdkCa410
{$ENDIF}
  ;

const
  CA410_DISPLAY_ITEM = 'USB ID COMM(%d), SerialNo (%s)';


type
  TfrmSystemSetup = class(TForm)
    pcSysConfig: TRzPageControl;
    TabSheet1: TRzTabSheet;
    grpSystem: TRzGroupBox;
    pnlUIType: TRzPanel;
    pnlLanguage: TRzPanel;
    cboUIType: TRzComboBox;
    cboLanguage: TRzComboBox;
    btnSave: TRzBitBtn;
    btnClose: TRzBitBtn;
    grpSerialSetting: TRzGroupBox;
    pnlBCR: TRzPanel;
    grpIPSetting: TRzGroupBox;
    pnl8: TPanel;
    cboBCR: TRzComboBox;
    grpCh: TRzGroupBox;
    chkCh1: TRzCheckBox;
    chkCh2: TRzCheckBox;
    chkCh3: TRzCheckBox;
    RzBitBtn1: TRzBitBtn;
    chkAutoBackup: TRzCheckBox;
    btnAutoBackup: TRzBitBtn;
    dlgOpen: TRzSelectFolderDialog;
    edAutoBackup: TRzEdit;
    tbEcsSheet: TRzTabSheet;
    dlgOpenGmes: TRzOpenDialog;
    tbDfsConfigration: TRzTabSheet;
    il1: TImageList;
    RzgrpDfsFtpFileUpload: TRzGroupBox;
    RzgrpDfsFtpHost: TRzGroupBox;
    RzpnlDfsFtpHostCtrl: TRzPanel;
    tlbDfsFtpHostBtns: TToolBar;
    btnDfsFtpHostDirUp: TToolButton;
    btnDfsFtpHostDirBack: TToolButton;
    btnDfsFtpHostDirHome: TToolButton;
    btnDfsFtpHostNull1: TToolButton;
    btnDfsFtpHostFileDownload: TToolButton;
    btnDfsFtpHostNull2: TToolButton;
    btnDfsFtpHostDirCreate: TToolButton;
    btnDfsFtpHostFileDelete: TToolButton;
    edDfsFtpHostDirNow: TEdit;
    btnDfsFtpHostDirGo: TBitBtn;
    lstDfsFtpHostFiles: TListBox;
    RzgrepDfsFtpLocal: TRzGroupBox;
    RzpnlDfsFtpLocalCtrl: TRzPanel;
    tlbDfsFtpLocalBtns: TToolBar;
    btnDfsFtpLocalDirUp: TToolButton;
    btnDfsFtpLocalDirBack: TToolButton;
    btnDfsFtpLocalDirHome: TToolButton;
    btnDfsFtpLocalNull1: TToolButton;
    btnDfsFtpLocalFileUpload: TToolButton;
    btnDfsFtpLocalNull2: TToolButton;
    btnDfsFtpLocalDirCreate: TToolButton;
    btnDfsFtpLocalFileDelete: TToolButton;
    edDfsFtpLocalDirNow: TEdit;
    btnDfsFtpLocalDirGo: TBitBtn;
    lstDfsFtpLocalFiles: TListBox;
    btnDfsFtpHost2LocalDownload: TRzBitBtn;
    btnDfsFtpLocal2HostUpload: TRzBitBtn;
    RzgrpDfsFtpConfig: TRzGroupBox;
    pnlDfsServerIP: TRzPanel;
    pnlDfsUserName: TRzPanel;
    pnlDfsPW: TRzPanel;
    edDfsServerIP: TRzEdit;
    edDfsUserName: TRzEdit;
    edDfsPW: TRzEdit;
    cbDfsFtpUse: TRzCheckBox;
    btnLoadDfsConfig: TBitBtn;
    cbUseCombiDown: TRzCheckBox;
    RzpnlCombiPath: TRzPanel;
    edCombiDownPath: TRzEdit;
    cbDfsHexCompress: TRzCheckBox;
    cbDfsHexDelete: TRzCheckBox;
    RzPanel18: TRzPanel;
    edProcessName: TRzEdit;
    pnlDfsFtpStatus: TPanel;
    btnDfsFtpDisconnect: TRzBitBtn;
    btnDfsFtpConnect: TRzBitBtn;
    grpGMES: TRzGroupBox;
    pnlServicePort: TRzPanel;
    pnlNetwork: TRzPanel;
    pnlDeamonPort: TRzPanel;
    edServicePort: TRzEdit;
    edNetwork: TRzEdit;
    edDeamonPort: TRzEdit;
    pnlLocalSubject: TRzPanel;
    pnlRemoteSubject: TRzPanel;
    edLocalSubject: TRzEdit;
    edRemoteSubject: TRzEdit;
    pnlEqccInterval: TRzPanel;
    edEqccInterval: TRzEdit;
    pnlMs: TRzPanel;
    RzBitBtn3: TRzBitBtn;
    btnPocbEmNo: TRzBitBtn;
    RzGroupBox1: TRzGroupBox;
    RzPanel1: TRzPanel;
    RzPanel4: TRzPanel;
    RzPanel14: TRzPanel;
    edEasServicePort: TRzEdit;
    edEasNetwork: TRzEdit;
    edEasDeamonPort: TRzEdit;
    RzPanel16: TRzPanel;
    edEasRemoteSubject: TRzEdit;
    chkEQCC: TRzCheckBox;
    RzGroupBox2: TRzGroupBox;
    RzPanel24: TRzPanel;
    RzNumericEdit3: TRzNumericEdit;
    RzPanel26: TRzPanel;
    chkMIPILog: TRzCheckBox;
    RzGroupBox4: TRzGroupBox;
    chkInterlock_SW: TRzCheckBox;
    edtVrsion_SW: TRzEdit;
    RzPanel28: TRzPanel;
    RzPanel29: TRzPanel;
    edtVrsion_Script: TRzEdit;
    RzPanel30: TRzPanel;
    edtVrsion_FW: TRzEdit;
    RzPanel31: TRzPanel;
    edtVrsion_FPGA: TRzEdit;
    RzPanel32: TRzPanel;
    edtVrsion_Power: TRzEdit;
    RzPanel13: TRzPanel;
    RzPanel15: TRzPanel;
    cboRetryCount: TComboBox;
    cboNGAlarmCount: TComboBox;
    RzGroupBox5: TRzGroupBox;
    RzPanel21: TRzPanel;
    edEQPID_MGIB: TRzEdit;
    RzPanel33: TRzPanel;
    edEQPID_PGIB: TRzEdit;
    pnlEQPID: TRzPanel;
    edEQPID_INLINE: TRzEdit;
    cboEQPId_Type: TComboBox;
    RzPanel20: TRzPanel;
    RzPanel35: TRzPanel;
    edEasLocalSubject: TRzEdit;
    TabSheet2: TRzTabSheet;
    grpCa410Set: TRzGroupBox;
    pnl1: TPanel;
    RzBitBtn4: TRzBitBtn;
    RzGrpOptions: TRzGroupBox;
    chkITOBmpMode: TRzCheckBox;
    grpDebugLogLevel: TRzGroupBox;
    pnlDebugLogPG: TRzPanel;
    cboDebugLogPG: TRzComboBox;
    btnPgFwDownload: TRzBitBtn;
    btnFileOpen: TRzBitBtn;
    edFileName: TRzEdit;
    odglfile: TRzOpenDialog;
    RzGroupBox6: TRzGroupBox;
    RzPanel2: TRzPanel;
    edSaveEnergy: TRzEdit;
    pnlTitleIonizer: TRzPanel;
    pnlModelonizer: TRzPanel;
    chkNewIonizer: TRzCheckBox;
    RzPanel3: TRzPanel;
    cboIrTempSensor: TRzComboBox;
    cboTempPlates: TRzComboBox;
    RzPanel5: TRzPanel;
    RzGroupBox3: TRzGroupBox;
    RzPanel6: TRzPanel;
    cboLErrMelody: TRzComboBox;
    RzPanel7: TRzPanel;
    cboHErrMelody: TRzComboBox;
    chkAutoControlTempPlate: TRzCheckBox;
    RzPanel8: TRzPanel;
    cboInspectDoneMelody: TRzComboBox;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure RzBitBtn1Click(Sender: TObject);
    procedure btnAutoBackupClick(Sender: TObject);
    procedure chkAutoBackupClick(Sender: TObject);
    procedure FindItemToListbox(tList: TRzListbox; sItem: string);
    procedure RzBitBtn3Click(Sender: TObject);
    procedure RzBitBtn4Click(Sender: TObject);
    procedure btnGetEmNoGIBClick(Sender: TObject);
    procedure btnLoadDfsConfigClick(Sender: TObject);
    procedure btnDfsFtpConnectClick(Sender: TObject);
    procedure btnDfsFtpDisconnectClick(Sender: TObject);
    procedure btnDfsFtpHostDirUpClick(Sender: TObject);
    procedure btnDfsFtpLocalDirCreateClick(Sender: TObject);
    procedure btnDfsFtpHostDirBackClick(Sender: TObject);
    procedure btnDfsFtpHostDirHomeClick(Sender: TObject);
    procedure btnDfsFtpHostFileDownloadClick(Sender: TObject);
    procedure btnDfsFtpHostDirCreateClick(Sender: TObject);
    procedure btnDfsFtpLocalDirUpClick(Sender: TObject);
    procedure btnDfsFtpLocalDirBackClick(Sender: TObject);
    procedure btnDfsFtpLocalDirHomeClick(Sender: TObject);
    procedure btnDfsFtpLocalFileUploadClick(Sender: TObject);
    procedure btnDfsFtpHostDirGoClick(Sender: TObject);
    procedure btnDfsFtpHostFileDeleteClick(Sender: TObject);
    procedure btnDfsFtpLocalDirGoClick(Sender: TObject);
    procedure lstDfsFtpHostFilesDblClick(Sender: TObject);
    procedure lstDfsFtpLocalFilesDblClick(Sender: TObject);
    procedure btnPgFwDownloadClick(Sender: TObject);
    procedure btnFileOpenClick(Sender: TObject);

    procedure cboProbeSelectOnClickEvent(Sender: TObject);
  private
    pnlProbeSerial : array[0 .. Pred(DefCommon.MAX_CA_DRIVE_CNT)] of TRzPanel;
    cboProbeSelect : array[0 .. Pred(DefCommon.MAX_CA_DRIVE_CNT)] of TRzComboBox;
    edtProbeSerial : array[0 .. Pred(DefCommon.MAX_CA_DRIVE_CNT)] of TRzEdit;
    edtProbeDevice : array[0 .. Pred(DefCommon.MAX_CA_DRIVE_CNT)] of TRzEdit;
    // For DFS.
    FHostLastDirStack   : TStringList;
    FHostRootDir        : String;
    FLocalLastDirStack  : TStringList;
    FLocalRootDir       : String;

    cboIonizer    : array[0 .. pred(DefCommon.MAX_IONIZER_CNT)] of TRzComboBox;
    cboIonizerModel : array[0 .. pred(DefCommon.MAX_IONIZER_CNT)] of TRzComboBox;

    procedure DisplaySystemInfo;
    procedure SaveBCRPortInfo;
    procedure ReadBCRPortInfo;
    function CheckAdminPasswd : Boolean;
    function CheckChangedSysInfo(pData1, pData2: PSystemInfo) : Boolean;
    function CheckChangedDFSInfo(pData1, pData2: PDfsConfInfo) : Boolean;
    function GetSerialNum(nIdx : Integer; sInput: string): string;
    procedure MakeGui;
  public
    { Public declarations }
    procedure DisplayFTP;
    procedure DisplayLocal;
    procedure FtpConnection(bConn : Boolean);
    procedure ChangeFTPDir(NewDir : String);
    procedure ChangeLocalDir(NewDir: string);
  end;

var
  frmSystemSetup: TfrmSystemSetup;

implementation

{$R *.dfm}

procedure TfrmSystemSetup.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSystemSetup.btnDfsFtpConnectClick(Sender: TObject);
var
  sServerIP, sUserName, sPassword : string;
begin
  // DFS Server
  sServerIP := edDfsServerIP.Text;
  sUserName := edDfsUserName.Text;
  sPassword := edDfsPW.Text;
  if (DfsFtpCommon = nil) then begin
    // in case of PM Mode.
    DfsFtpCommon := TDfsFtp.Create(sServerIP, sUserName, sPassword, -1{nCh:dummy for DfsFtpCommon});
    DfsFtpCommon.IsConnectCheck := False;
  end;
  DfsFtpCommon.OnConnectedSetup := FtpConnection;
  DfsFtpCommon.IsSetUpWindow := True;
  if DfsFtpCommon.IsConnected then DfsFtpCommon.Disconnect;
  DfsFtpCommon.Connect;
  //
  RzgrpDfsFtpFileUpload.Visible := True;
end;

procedure TfrmSystemSetup.btnDfsFtpDisconnectClick(Sender: TObject);
begin
  if DfsFtpCommon <> nil then begin
    DfsFtpCommon.Disconnect;
  end;
  RzgrpDfsFtpFileUpload.Visible := False;
end;

procedure TfrmSystemSetup.btnDfsFtpHostDirBackClick(Sender: TObject);
var
  sTemp : String;
begin
  if FHostLastDirStack.Count > 0 then begin
    sTemp := FHostLastDirStack[FHostLastDirStack.Count -1];
    ChangeFTPDir(sTemp);
    // Delete S
    FHostLastDirStack.Delete(FHostLastDirStack.Count -1);
    // Delete the jump from S
    FHostLastDirStack.Delete(FHostLastDirStack.Count -1);
//    SetControls;
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpHostDirCreateClick(Sender: TObject);
var
  sTemp : String;
begin
  sTemp := 'New Folder';
  if InputQuery('New folder', 'New folder name:', sTemp) then begin
    DfsFtpCommon.MakeDir(sTemp);
    ChangeFTPDir(sTemp);
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpHostDirGoClick(Sender: TObject);
begin
  if (Length(edDfsFtpHostDirNow.Text) < 1) then begin  //2019-02-08
    btnDfsFtpHostDirHomeClick(Sender);
    Exit;
  end;
  if (edDfsFtpHostDirNow.Text[Length(edDfsFtpHostDirNow.Text)] <> '/') then
    edDfsFtpHostDirNow.Text := edDfsFtpHostDirNow.Text + '/';
  ChangeFTPDir(edDfsFtpHostDirNow.Text);
end;

procedure TfrmSystemSetup.btnDfsFtpHostDirHomeClick(Sender: TObject);
begin
  ChangeFTPDir(FHostRootDir);
end;

procedure TfrmSystemSetup.btnDfsFtpHostDirUpClick(Sender: TObject);
begin
  DfsFtpCommon.ChangeDirUp;
  DisplayFTP;
end;

procedure TfrmSystemSetup.btnDfsFtpHostFileDeleteClick(Sender: TObject);
var
  i : Integer;
  sTemp : String;
begin
  try
    i := lstDfsFtpHostFiles.ItemIndex;
  except
    ShowMessage('Please Select File.');
    exit;
  end;
  if i <> -1 then begin
    sTemp := lstDfsFtpHostFiles.Items[i];
    if MessageDlg('Are you sure you want to delete ' + sTemp + '?', mtWarning, [mbYes,mbNo], 0) = mrYes then
      DfsFtpCommon.Delete(sTemp);
    DisplayFTP;
  end
  else
    MessageDlg('You must first select a file or folder to delete from the site.', mtWarning, [mbOK], 0);
end;

procedure TfrmSystemSetup.btnDfsFtpHostFileDownloadClick(Sender: TObject);
var
  i, idx, nSize : Integer;
  //b : boolean;
  sTemp : String;
begin
  idx := -1;
  for i := 0 to Pred(lstDfsFtpHostFiles.Count) do begin
    if lstDfsFtpHostFiles.Selected[i] then begin
      idx := i;
      Break;
    end;
  end;

  if idx <> -1 then begin
    sTemp := lstDfsFtpHostFiles.Items[i];
    nSize := DfsFtpCommon.Size(sTemp);
    if nSize = -1 then
      ChangeFTPDir(sTemp)
    else begin
      if FileExists(edDfsFtpLocalDirNow.Text + sTemp) then
        if MessageDlg('File exists overwrite?', mtWarning, [mbYes,mbNo], 0) = mrYes then
          DeleteFile(edDfsFtpLocalDirNow.Text + sTemp);

      DfsFtpCommon.Get(sTemp, edDfsFtpLocalDirNow.Text + sTemp);
      DisplayLocal;
    end;
  end
  else begin
    MessageDlg('You must first select a file to download from the site.', mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpLocalDirBackClick(Sender: TObject);
var
  sTemp : String;
begin
  if FLocalLastDirStack.Count > 0 then begin
    sTemp := FLocalLastDirStack[FLocalLastDirStack.Count -1];
    ChangeLocalDir(sTemp);
    // Delete S
    FLocalLastDirStack.Delete(FLocalLastDirStack.Count -1);
    // Delete the jump from S
    FLocalLastDirStack.Delete(FLocalLastDirStack.Count -1);
//    SetControls;
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpLocalDirCreateClick(Sender: TObject);
var
  sTemp : String;
begin
  sTemp := 'New Folder';
  if InputQuery('New folder', 'New folder name:', sTemp) then begin
    CreateDir(edDfsFtpLocalDirNow.Text + sTemp + '\');
    ChangeLocalDir(edDfsFtpLocalDirNow.Text + sTemp + '\');
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpLocalDirGoClick(Sender: TObject);
begin
  if (Length(edDfsFtpLocalDirNow.Text) < 1) then begin  //2019-02-08
    btnDfsFtpLocalDirHomeClick(Sender);
    Exit;
  end;
  if (edDfsFtpLocalDirNow.Text[Length(edDfsFtpLocalDirNow.Text)] <> '\') then
    edDfsFtpLocalDirNow.Text := edDfsFtpLocalDirNow.Text + '\';
  DisplayLocal;
end;

procedure TfrmSystemSetup.btnDfsFtpLocalDirHomeClick(Sender: TObject);
begin
  ChangeLocalDir(FLocalRootDir);
end;

procedure TfrmSystemSetup.btnDfsFtpLocalDirUpClick(Sender: TObject);
var
  i : Integer;
  slTemp : TStringList;
  sNewPath : string;
begin
  slTemp := TStringList.Create;
  try
    ExtractStrings(['\'],[], PWideChar(edDfsFtpLocalDirNow.Text), slTemp);
    if slTemp.Count > 0 then begin
      sNewPath := '';
      for i := 0 to (slTemp.Count-2) do begin
        sNewPath := sNewPath + slTemp[i] + '\';
      end;
    end;
    edDfsFtpLocalDirNow.Text := sNewPath;
    DisplayLocal;
  finally
    slTemp.Free;
  //slTemp := nil;
  end;
end;

procedure TfrmSystemSetup.btnDfsFtpLocalFileUploadClick(Sender: TObject);
begin
  ChangeLocalDir(FLocalRootDir);
end;

procedure TfrmSystemSetup.btnFileOpenClick(Sender: TObject);
begin
   odglfile.InitialDir := Common.Path.RootSW;
   odglfile.Filter := 'exe files(*.exe)|*.exe';
   odglfile.FilterIndex := 1;
   if odglfile.Execute then
    begin
      edFileName.Text := odglfile.FileName;
    end;
end;

procedure TfrmSystemSetup.btnGetEmNoGIBClick(Sender: TObject);
var
  txFile : TextFile;
  sReadData,  sLocalIp, sTemp : string;
  slTemp : TStringList;
  i : Integer;
begin
  dlgOpenGmes.InitialDir := Common.Path.Ini;
  dlgOpenGmes.Filter := 'Open EM_No Setup File (*.txt)|*.txt';
  dlgOpenGmes.DefaultExt := dlgOpenGmes.Filter;

  if dlgOpenGmes.Execute then begin
    AssignFile(txFile,dlgOpenGmes.FileName);

    try
      sLocalIp := '';
      Reset(txFile);
      while not Eof(txFile) do begin
        Readln(txFile,sReadData);
        slTemp := TStringList.Create;
        try
          ExtractStrings([','], [], PWideChar(sReadData), slTemp);
          // Ex 1,192.168.112.20,EM_NO.
          if slTemp.Count > 1 then begin
            if Trim(slTemp[0]) = 'IP_SEARCH' then begin
              for i := 1 to pred(slTemp.Count) do begin
                sTemp := Trim(common.GetLocalIpList(DefCommon.IP_LOCAL_GMES,Trim(slTemp[i])));
                // finally find IP.
                if sTemp <> '' then begin
                  sLocalIp := sTemp;
                  Break;
                end;
              end;
            end
            else begin
              if slTemp.Count > 2 then begin
                if slTemp[1] = sLocalIp then begin
                  edEQPID_INLINE.Text      := Trim(slTemp[2]);
                  Break;
                end;
              end;
            end;
          end;
        finally
          slTemp.Free;
        end;
      end;
    finally
      CloseFile(txFile);
    end;
  end;
end;

procedure TfrmSystemSetup.btnLoadDfsConfigClick(Sender: TObject);
var
  txFile : TextFile;
  sReadData, sTemp, sTemp2, sSearchIp : string;
begin
  dlgOpenGmes.InitialDir := Common.Path.Ini;
  dlgOpenGmes.Filter := 'Open DFS Setup File (*.txt)|*.txt';
  dlgOpenGmes.DefaultExt := dlgOpenGmes.Filter;
  if dlgOpenGmes.Execute then begin
    AssignFile(txFile,dlgOpenGmes.FileName);
    sSearchIp := '';
    try
      Reset(txFile);
      while not Eof(txFile) do begin
        Readln(txFile,sReadData);
        if Pos('DFS_SERVER_IP=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'DFS_SERVER_IP=','',[rfReplaceAll]) );
          edDfsServerIP.Text := sTemp;
        end
        else if Pos('DFS_USER_NAME=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'DFS_USER_NAME=','',[rfReplaceAll]) );
          edDfsUserName.Text := sTemp;
        end
        else if Pos('DFS_PASSWORD=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'DFS_PASSWORD=','',[rfReplaceAll]) );
          edDfsPW.Text := sTemp;
        end
        else if Pos('COMBI_DOWN_PATH=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'COMBI_DOWN_PATH=','',[rfReplaceAll]) );
          edCombiDownPath.Text := sTemp;
        end
        else if Pos('PROCESS_NAME=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'PROCESS_NAME=','',[rfReplaceAll]) );
          edProcessName.Text := sTemp;
        end;
      end;
    finally
      CloseFile(txFile);
    end;
  end;
end;


procedure TfrmSystemSetup.btnPgFwDownloadClick(Sender: TObject);
var
   SEInfo: TShellExecuteInfo;
   ExitCode: DWORD;
   ExecuteFile, ParamString, StartInString: string;
begin

    ExecuteFile := Common.SystemInfo.DAELoadWizardPath; // 실행하려는 프로그램의 경로 및 파일명 지정
    ParamString := 'C:\autoexec.bat'; // 프로그램 실행시 인자값을 문자열로 지정

   FillChar(SEInfo, SizeOf(SEInfo), 0) ;
   SEInfo.cbSize := SizeOf(TShellExecuteInfo) ;
   with SEInfo do begin
     fMask := SEE_MASK_NOCLOSEPROCESS;
     Wnd := Application.Handle;
     lpFile := PChar(ExecuteFile) ;
//     lpParameters := PChar(ParamString) ;
 // lpDirectory := PChar(StartInString) ; // StartInString 문자열에 실행되고자 하는 디렉토리를 지정할 수 있음. 지정하지 않으면 현재 프로그램 실행 디렉토리가 디폴트로 사용됨
     nShow := SW_SHOWNORMAL; // 프로그램이 실행되는 윈도우 형태를 지정할 수 있습니다. ACTIVE, 최대화, 최소화 등등...
   end;
   if ShellExecuteEx(@SEInfo) then begin
     repeat
       Application.ProcessMessages;
       GetExitCodeProcess(SEInfo.hProcess, ExitCode) ;
     until (ExitCode <> STILL_ACTIVE) or Application.Terminated;
     ShowMessage('Shutting down a Program.') ;
   end
   else ShowMessage('Failed to run program.') ;
end;


procedure TfrmSystemSetup.btnSaveClick(Sender: TObject);
var
  i : Integer;
  OldSysInfo: TSystemInfo;
  OldDFSInfo: TDfsConfInfo;
begin
  OldSysInfo:= Common.SystemInfo;

  with Common.SystemInfo do begin

    DAELoadWizardPath := edFileName.Text;
    UseITOMode := chkITOBmpMode.Checked;

    SaveEnergy      := StrToIntDef(edSaveEnergy.Text,0);
    Com_HandBCR   := cboBCR.ItemIndex;
    Com_IrTempSensor := cboIrTempSensor.ItemIndex;
    Com_TempPlates   := cboTempPlates.ItemIndex;

    UIType 		    := cboUIType.itemIndex;

    DioMelodyH    := cboHErrMelody.ItemIndex;
    DioMelodyL    := cboLErrMelody.ItemIndex;
    DioMelodyInsDone := cboInspectDoneMelody.ItemIndex;
    AutoCtrlTempPlate := chkAutoControlTempPlate.Checked;

    EQPId_Type     := cboEQPId_Type.ItemIndex;
    EQPId_INLINE   := edEQPID_INLINE.Text;
    EQPId_MGIB     := edEQPID_MGIB.Text;
    EQPId_PGIB     := edEQPID_PGIB.Text;
    case EQPId_Type of
      0: begin
        if EQPId_INLINE = '' then begin
          Application.MessageBox('EQP ID Can Not Empty', 'Confirm', MB_OK);
          edEQPID_INLINE.SetFocus;
          Exit;
        end;
        EQPId:= EQPId_INLINE;
      end;
      1: begin
        if EQPId_MGIB = '' then begin
          Application.MessageBox('EQP ID Can Not Empty', 'Confirm', MB_OK);
          edEQPID_MGIB.SetFocus;
          Exit;
        end;
        EQPId:= EQPId_MGIB;
      end;
      2: begin
        if EQPId_PGIB = '' then begin
          Application.MessageBox('EQP ID Can Not Empty', 'Confirm', MB_OK);
          edEQPID_PGIB.SetFocus;
          Exit;
        end;
        EQPId:= EQPId_PGIB;
      end;
      else begin
        Application.MessageBox('Unkonwn EQP ID Type', 'Confirm', MB_OK);
        Exit;
      end;
    end;
    ServicePort    := edServicePort.Text;
    Network        := edNetwork.Text;
    DaemonPort     := edDeamonPort.Text;
    LocalSubject   := edLocalSubject.Text;
    RemoteSubject  := edRemoteSubject.Text;
    EqccInterval   := edEqccInterval.Text;
    Eas_Service    := edEasServicePort.Text;
    Eas_Network     := edEasNetwork.Text;
    Eas_DeamonPort  := edEasDeamonPort.Text;
    Eas_LocalSubject := edEasLocalSubject.Text;
    Eas_RemoteSubject := edEasRemoteSubject.Text;

    //FwVer           := Trim(edFwVer.Text);
    //FpgaVer           := Trim(edFpgaVer.Text);

    UseCh[0]      := chkCh1.Checked ;
    UseCh[1]      := chkCh2.Checked ;
    UseCh[2]      := chkCh3.Checked ;

    AutoBackupUse := chkAutoBackup.Checked;
    AutoBackupList := edAutoBackup.Text;
    UseEQCC       := chkEQCC.Checked;
    MIPILog       := chkMIPILog.Checked;
    NGAlarmCount  := cboNGAlarmCount.ItemIndex;

    IonizerNewProtocol := chkNewIonizer.Checked;

    for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
      Com_Ionizer[i] := cboIonizer[i].ItemIndex;
      Model_Ionizer[i] := cboIonizerModel[i].ItemIndex;
    end;

    {$IFDEF CA410_USE}
    for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin
      Com_ca410[i] := cboProbeSelect[i].ItemIndex;
      Com_Ca410_SERIAL[i] := edtProbeSerial[i].Text;
      Com_Ca410_DevieId[i] := StrToIntDef(Trim(edtProbeDevice[i].Text),0);
    end;

    for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do Com_CaDeviceList[i] := '';

    for i := 0 to (cboProbeSelect[0].Items.Count-2) do begin
      Com_CaDeviceList[i] :=  cboProbeSelect[0].Items[i+1];
    end;

    DebugLogLevelConfig := cboDebugLogPG.ItemIndex;

    {$ENDIF}
  end;

  if CheckChangedSysInfo(@OldSysInfo, @Common.SystemInfo) = True then begin
    //System Info 변경됨
    Common.MLog(DefCommon.MAX_SYSTEM_LOG, 'Changed SystemInfo');
  end;

  OldDFSInfo:= Common.DfsConfInfo;
  with Common.DfsConfInfo do begin
    bUseDfs         := cbDfsFtpUse.Checked;
    bDfsHexCompress := cbDfsHexCompress.Checked;
    bDfsHexDelete   := cbDfsHexDelete.Checked;
    sDfsServerIP    := edDfsServerIP.Text;
    sDfsUserName    := edDfsUserName.Text;
    sDfsPassword    := edDfsPW.Text;
    //
    bUseCombiDown   := cbUseCombiDown.Checked;
    sCombiDownPath  := edCombiDownPath.Text;
    sProcessName    := Trim(edProcessName.Text);
  end;

  if CheckChangedDFSInfo(@OldDFSInfo, @Common.DfsConfInfo) = True then begin
    //변경됨
    Common.MLog(DefCommon.MAX_SYSTEM_LOG, 'Changed DFSInfo');
  end;

  with Common.InterlockInfo do begin
    Use             := chkInterlock_SW.Checked;
    Version_SW      := edtVrsion_SW.Text;
    Version_Script  := edtVrsion_Script.Text;
    Version_FW      := edtVrsion_FW.Text;
  end;



  Common.SaveSystemInfo;

  SaveBCRPortInfo;
  Common.m_bIsChanged := True;
//	SaveRCB2PortInfo;
  MessageDlg('Save OK. Start This Program again.', mtInformation, [mbOk], 0);
end;

function TfrmSystemSetup.GetSerialNum(nIdx : Integer; sInput: string): string;
var
  sTemp : string;
  slTemp : TStringList;
begin
  sTemp := '';
  slTemp := TStringList.Create;
  try                                                                 // 0         1       2         3 4
    ExtractStrings(['(',')'],[],PChar(sInput),slTemp);    //'USB ID COMM(%d), SerialNo (%s)';
    if slTemp.Count > 3 then begin
      sTemp := Trim(slTemp[nIdx]);
    end;
  finally
    slTemp.Free;
  end;
  Result := sTemp;
end;

procedure TfrmSystemSetup.cboProbeSelectOnClickEvent(Sender: TObject);
var
  nIdx : Integer;
  sSerial, sDevice, sSelData : string;
begin
  nIdx := TRzComboBox(Sender).Tag;
  sSelData := TRzComboBox(Sender).Text;

  edtProbeSerial[nIdx].Text    := GetSerialNum(3,sSelData);
  edtProbeDevice[nIdx].Text    := GetSerialNum(1,sSelData);
end;

procedure TfrmSystemSetup.ChangeFTPDir(NewDir: String);
begin
  FHostLastDirStack.Add(DfsFtpCommon.RetrieveCurrentDir);
  DfsFtpCommon.ChangeDir(NewDir);
  DisplayFTP;
end;

procedure TfrmSystemSetup.ChangeLocalDir(NewDir: string);
begin
  FLocalLastDirStack.Add(edDfsFtpLocalDirNow.Text);
  edDfsFtpLocalDirNow.Text := NewDir;
  DisplayLocal;
end;

function TfrmSystemSetup.CheckAdminPasswd: Boolean;
var
  bRet : boolean;
begin
  bRet := False;
  frmLogIn := TfrmLogIn.Create(Nil);
  try
    frmLogIn.Caption := 'Confirm Admin Password';
    if frmLogIn.ShowModal = mrOK then begin
      frmLogIn.Update;
      bRet := True;
    end;
  finally
    frmLogIn.Free;
    frmLogIn := nil;
  end;
  Result := bRet;
end;

function TfrmSystemSetup.CheckChangedDFSInfo(pData1, pData2: PDfsConfInfo): Boolean;
var
  rtype: TRTTIType;
  fields: TArray<TRttiField>;
  i, k: Integer;
  sValue1, sValue2: String;
begin
  Result:= False;
  rtype := TRTTIContext.Create.GetType(TypeInfo(TDfsConfInfo));
  fields := rtype.GetFields;

  for i := 0 to High(fields) do begin
    if fields[i].FieldType = nil then begin
      //배열 같은 경우 안됨 - 타입 지정 안됨 Type 지정 배열 사용 필요
      continue;
    end;
    if fields[i].FieldType.TypeKind = tkArray then begin
      for k := 0 to fields[i].GetValue(pData1).GetArrayLength-1 do begin
        sValue1:= fields[i].GetValue(pData1).GetArrayElement(k).ToString;
        sValue2:= fields[i].GetValue(pData2).GetArrayElement(k).ToString;
        if sValue1 <> sValue2 then begin
          Common.MLog(DefCommon.MAX_SYSTEM_LOG, Format('DFSInfo Changed  %s(%d): %s -> %s', [fields[i].Name, k, sValue1, sValue2]));
          Result:= True;
        end;
      end;
    end
    else begin
      sValue1:= fields[i].GetValue(pData1).ToString;
      sValue2:= fields[i].GetValue(pData2).ToString;
      if sValue1 <> sValue2 then begin
        Common.MLog(DefCommon.MAX_SYSTEM_LOG, Format('DFSInfo Changed  %s: %s -> %s', [fields[i].Name, sValue1, sValue2]));
        Result:= True;
      end;
    end;
  end;
end;



function TfrmSystemSetup.CheckChangedSysInfo(pData1, pData2: PSystemInfo): Boolean;
var
  rtype: TRTTIType;
  fields: TArray<TRttiField>;
  i, k: Integer;
  sValue1, sValue2: String;
begin
  Result:= False;
  rtype := TRTTIContext.Create.GetType(TypeInfo(TSystemInfo));
  fields := rtype.GetFields;

  for i := 0 to High(fields) do begin
    if fields[i].FieldType = nil then begin
      //배열 같은 경우 안됨 - 타입 지정 안됨 Type 지정 배열 사용 필요
      continue;
    end;
    if fields[i].FieldType.TypeKind = tkArray then begin
      for k := 0 to fields[i].GetValue(pData1).GetArrayLength-1 do begin
        sValue1:= fields[i].GetValue(pData1).GetArrayElement(k).ToString;
        sValue2:= fields[i].GetValue(pData2).GetArrayElement(k).ToString;
        if sValue1 <> sValue2 then begin
          Common.MLog(DefCommon.MAX_SYSTEM_LOG, Format('SystemInfo Changed  %s(%d): %s -> %s', [fields[i].Name, k, sValue1, sValue2]));
          Result:= True;
        end;
      end;
    end
    else begin
      sValue1:= fields[i].GetValue(pData1).ToString;
      sValue2:= fields[i].GetValue(pData2).ToString;
      if sValue1 <> sValue2 then begin
        Common.MLog(DefCommon.MAX_SYSTEM_LOG, Format('SystemInfo Changed  %s: %s -> %s', [fields[i].Name, sValue1, sValue2]));
        Result:= True;
      end;
    end;
  end;
end;

procedure TfrmSystemSetup.chkAutoBackupClick(Sender: TObject);
begin
  btnAutoBackup.Enabled := chkAutoBackup.Checked;
  edAutoBackup.Enabled := chkAutoBackup.Checked;
end;

procedure TfrmSystemSetup.DisplayFTP;
var
  i: Integer;
  sTemp : TStringList;
begin
  lstDfsFtpHostFiles.Items.Clear;
  try
    sTemp := TStringList.Create;
    DfsFtpCommon.List(sTemp);
    edDfsFtpHostDirNow.Text := DfsFtpCommon.RetrieveCurrentDir;
    for i := 0 to Pred(sTemp.Count) do begin
      if DfsFtpCommon.Size(sTemp[i]) = -1 then
        lstDfsFtpHostFiles.Items.Add(sTemp[i]);
    end;
    for i := 0 to Pred(sTemp.Count) do begin
      if DfsFtpCommon.Size(sTemp[i]) <> -1 then
        lstDfsFtpHostFiles.Items.Add(sTemp[i]);
    end;
  finally
    sTemp.Free;
    sTemp := nil;
  end;
end;

procedure TfrmSystemSetup.DisplayLocal;
var
  Rslt : Integer;
  SearchRec : TSearchRec;
begin
  lstDfsFtpLocalFiles.Items.Clear;
  Rslt := FindFirst(edDfsFtpLocalDirNow.Text + '*.*', faAnyFile, SearchRec);
  while Rslt = 0 do begin
    if not ((SearchRec.Name = '.') or (SearchRec.Name = '..')) then begin
      lstDfsFtpLocalFiles.Items.Add(SearchRec.Name);
    end;
    Rslt := FindNext(Searchrec);
  end;
  FindClose(SearchRec);
end;

procedure TfrmSystemSetup.DisplaySystemInfo;
var
  i, j : Integer;
  sTemp, sItem : string;
begin
  pcSysConfig.ActivePageIndex := 0;
  ReadBCRPortInfo;
  with Common.SystemInfo do begin
    cboBCR.ItemIndex    := Com_HandBCR;
    cboIrTempSensor.ItemIndex    := Com_IrTempSensor;
    cboTempPlates.ItemIndex      := Com_TempPlates;

    edSaveEnergy.Text := Format('%d',[SaveEnergy]);
    chkITOBmpMode.Checked          := UseITOMode; // Added by KTS 2022-03-25 오후 1:30:55
    edFileName.Text                := DAELoadWizardPath;

    cboUIType.ItemIndex            := 	 UIType;

    cboHErrMelody.ItemIndex        := DioMelodyH;
    cboLErrMelody.ItemIndex        := DioMelodyL;
    cboInspectDoneMelody.ItemIndex := DioMelodyInsDone;
    chkAutoControlTempPlate.Checked := AutoCtrlTempPlate;

//    cboLanguage.ItemIndex	         :=		 Language;
    cboEQPId_Type.ItemIndex        :=    EQPId_Type;
    edEQPID_INLINE.Text            :=    EQPId_INLINE;
    edEQPID_MGIB.Text              :=    EQPId_MGIB;
    edEQPID_PGIB.Text              :=    EQPId_PGIB;
    edServicePort.Text             :=    ServicePort;
    edNetwork.Text                 :=    Network;
    edDeamonPort.Text              :=    DaemonPort;
    edLocalSubject.Text            :=    LocalSubject;
    edRemoteSubject.Text           :=    RemoteSubject;
    edEqccInterval.Text            :=    EqccInterval;
//    edLoaderIndex.Text				     :=    Loader_Index;
//    chkPwrLogUse.Checked					 :=    PowerLog;
    edEasServicePort.Text           :=    Eas_Service;
    edEasNetwork.Text               :=    Eas_Network;
    edEasDeamonPort.Text            :=    Eas_DeamonPort;
    edEasLocalSubject.Text          :=    Eas_LocalSubject;
    edEasRemoteSubject.Text         :=    Eas_RemoteSubject;

    chkCh1.Checked      := UseCh[0];
    chkCh2.Checked      := UseCh[1];
    chkCh3.Checked      := UseCh[2];


    pnlDebugLogPG.visible := True;  cboDebugLogPG.visible := True;
    cboDebugLogPG.ItemIndex := DebugLogLevelConfig;
    pnlDebugLogPG.visible := False; cboDebugLogPG.visible := False;

    btnPocbEmNo.Visible := True;
    tbEcsSheet.TabVisible := True;

    chkAutoBackup.Checked := AutoBackupUse;
    edAutoBackup.Text     := AutoBackupList;
    chkNewIonizer.Checked := IonizerNewProtocol;

    cboNGAlarmCount.ItemIndex:= NGAlarmCount;

    chkMIPILog.Checked     := MIPILog;

    for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin
      cboProbeSelect[i].Items.Clear;
      cboProbeSelect[i].Items.Add('NONE');
      for j := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin
        if trim(Com_CaDeviceList[j]) = '' then break;
        cboProbeSelect[i].Items.Add(Com_CaDeviceList[j]);
      end;
    end;


    for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin
      cboProbeSelect[i].ItemIndex := Com_ca410[i];
      edtProbeSerial[i].Text := Com_Ca410_SERIAL[i];
      edtProbeDevice[i].Text := Format('%d',[Com_Ca410_DevieId[i]]);
    end;

    for i := 0 to Pred(DefCommon.MAX_IONIZER_CNT) do begin
      cboIonizer[i].ItemIndex := Com_Ionizer[i];
      cboIonizerModel[i].ItemIndex := Model_Ionizer[i];
    end;

  end;

{$IFDEF DFS_HEX}
  tbDfsConfigration.TabVisible := True;
  with Common.DfsConfInfo do begin
    cbDfsFtpUse.Checked       := bUseDfs;      //2019-02-01 DFS_FTP
    cbDfsHexCompress.Checked  := bDfsHexCompress;
    cbDfsHexDelete.Checked    := bDfsHexDelete;
    edDfsServerIP.Text        := sDfsServerIP;
    edDfsUserName.Text        := sDfsUserName;
    edDfsPW.Text              := sDfsPassword;
    //
    cbUseCombiDown.Checked    := bUseCombiDown;
    edCombiDownPath.Text      := sCombiDownPath;
    edProcessName.Text        := sProcessName;
  end;
{$ELSE}
  tbDfsConfigration.TabVisible := False;
{$ENDIF}
  btnAutoBackup.Enabled := chkAutoBackup.Checked;
  edAutoBackup.Enabled := chkAutoBackup.Checked;


  with Common.InterlockInfo do begin
    chkInterlock_SW.Checked  := Common.InterlockInfo.Use;
    edtVrsion_SW.Text        := Common.InterlockInfo.Version_SW;
    edtVrsion_Script.Text    := Common.InterlockInfo.Version_Script;
    edtVrsion_FW.Text        := Common.InterlockInfo.Version_FW;
  end;

end;



procedure TfrmSystemSetup.FindItemToListbox(tList: TRzListbox; sItem: string);
var
  i : Integer;
begin
  for i := 0 to tList.Items.Count - 1 do begin
    if tList.Items.Strings[i] = sItem then begin
      tList.ItemIndex := i;
      Break;
    end;
  end;
end;

procedure TfrmSystemSetup.FormClose(Sender: TObject; var Action: TCloseAction);

begin
;
  cboBCR.Items.Clear;
  cboUIType.Items.Clear;
  cboLanguage.Items.Clear;

  Action := caFree;
end;

procedure TfrmSystemSetup.FormCreate(Sender: TObject);
begin
  FHostLastDirStack := TStringList.Create;
  FLocalLastDirStack := TStringList.Create;

  MakeGui;

  DisplaySystemInfo;
end;

procedure TfrmSystemSetup.FormDestroy(Sender: TObject);
begin
  if DfsFtpCommon <> nil then begin
    if DfsFtpCommon.IsConnected then DfsFtpCommon.DisConnect;
    DfsFtpCommon.Free;
    DfsFtpCommon := nil;
  end;
  FHostLastDirStack.Free;
  FHostLastDirStack := nil;
  FLocalLastDirStack.Free;
  FLocalLastDirStack := nil;
//  Self := nil;
end;

procedure TfrmSystemSetup.FormShow(Sender: TObject);
begin
//  pcSysConfig.ActivePage := TabSheet1;
end;

procedure TfrmSystemSetup.FtpConnection(bConn: Boolean);
begin
  if bConn then begin
    pnlDfsFtpStatus.Caption := 'Connected';
    pnlDfsFtpStatus.Font.Color := clLime;
    FHostRootDir  := DfsFtpCommon.RetrieveCurrentDir;
    FLocalRootDir := Common.Path.DfsDefect;   //TBD? Common.SystemInfo.ShareFolder;
    edDfsFtpHostDirNow.Text := FHostRootDir;
    if (edDfsFtpHostDirNow.Text[Length(edDfsFtpHostDirNow.Text)] <> '/') then
      edDfsFtpHostDirNow.Text := edDfsFtpHostDirNow.Text + '/';
    edDfsFtpLocalDirNow.Text := FLocalRootDir + '\';  //2019-02-07 DFS_FTP POCB_A2CH
    if (edDfsFtpLocalDirNow.Text[Length(edDfsFtpLocalDirNow.Text)] <> '\') then
      edDfsFtpLocalDirNow.Text := edDfsFtpLocalDirNow.Text + '\';
    DisplayFTP;
    DisplayLocal;
  end
  else begin
    pnlDfsFtpStatus.Caption := 'Disonnected';
    pnlDfsFtpStatus.Font.Color := clRed;
  end;
end;

procedure TfrmSystemSetup.lstDfsFtpHostFilesDblClick(Sender: TObject);
var
  sPath, sSubPath : string;
  i : integer;
begin
//  btnDownloadClick(Sender);
  if DfsFtpCommon = nil then Exit;

  for i := 0 to Pred(lstDfsFtpHostFiles.Items.Count) do begin
    if lstDfsFtpHostFiles.Selected[i] then begin
      sSubPath := Trim(lstDfsFtpHostFiles.Items[i]);
      Break;
    end;
  end;
  if sSubPath = '.' then exit;
  if sSubPath = '' then exit;
  //if sSubPath = '..' then exit;
  if (edDfsFtpHostDirNow.Text[Length(edDfsFtpHostDirNow.Text)] <> '/') then
    edDfsFtpHostDirNow.Text := edDfsFtpHostDirNow.Text + '/';
  edDfsFtpHostDirNow.Text := edDfsFtpHostDirNow.Text + sSubPath + '/';
  sPath := edDfsFtpHostDirNow.Text;
  ChangeFTPDir(sPath);
end;

procedure TfrmSystemSetup.lstDfsFtpLocalFilesDblClick(Sender: TObject);
var
  sPath, sSubPath : string;
  i : integer;
  nFileAttrs : integer;
begin
  if DfsFtpCommon = nil then Exit;

  for i := 0 to Pred(lstDfsFtpLocalFiles.Items.Count) do begin
    if lstDfsFtpLocalFiles.Selected[i] then begin
      sSubPath := Trim(lstDfsFtpLocalFiles.Items[i]);
      Break;
    end;
  end;
  if sSubPath = '.' then exit;
  if sSubPath = '' then exit;
  //if sSubPath = '..' then exit;
  nFileAttrs := FileGetAttr(edDfsFtpLocalDirNow.Text + sSubPath);
  if (nFileAttrs and faDirectory) = 0 then begin // Not Directory
    Exit;
  end;
  if (edDfsFtpLocalDirNow.Text[Length(edDfsFtpLocalDirNow.Text)] <> '/') then
    edDfsFtpLocalDirNow.Text := edDfsFtpLocalDirNow.Text + '\';
  edDfsFtpLocalDirNow.Text := edDfsFtpLocalDirNow.Text + sSubPath + '\';
  sPath := edDfsFtpLocalDirNow.Text;
  ChangeLocalDir(sPath);
end;


procedure TfrmSystemSetup.MakeGui;
var
  i, j : Integer;
  sTemp : string;
begin
  grpSerialSetting.Visible := False;
  // Set for Ionizer.
  for i := 0 to Pred(defcommon.MAX_IONIZER_CNT) do begin
    cboIonizer[i] := TRzComboBox.Create(self);
    cboIonizer[i].Parent := grpSerialSetting;
    cboIonizer[i].Top    := pnlTitleIonizer.Top;
    case i of
      0 : begin
        cboIonizer[i].Left   := pnlTitleIonizer.Left + pnlTitleIonizer.width + 1;// edIonizerCnt.Left;
      end
      else begin
        cboIonizer[i].Left   := cboIonizer[i-1].Left + cboIonizer[i-1].Width + 1;
      end;
    end;

    cboIonizer[i].Width  := (grpSerialSetting.Width - pnlTitleIonizer.Left - pnlTitleIonizer.Width - 4) div DefCommon.MAX_IONIZER_CNT;
    cboIonizer[i].Font.Size := 9;
    cboIonizer[i].DropDownCount := 21;
    cboIonizer[i].Font.Name := 'Verdana';
    cboIonizer[i].Font.Style := [fsBold];
    cboIonizer[i].Items.Clear;
    for j := 0 to 20 do begin
      if j = 0 then begin
        sTemp := 'None';
      end
      else begin
        sTemp := Format('COM%d',[j]);
      end;
      cboIonizer[i].Items.Add(sTemp);
    end;
    cboIonizer[i].Style := csDropDownList;
    cboIonizer[i].Visible := True;

    // Model Set.
    cboIonizerModel[i] := TRzComboBox.Create(self);
    cboIonizerModel[i].Parent := grpSerialSetting;
    cboIonizerModel[i].Top    := pnlModelonizer.Top;
    case i of
      0 : begin
        cboIonizerModel[i].Left   := cboIonizer[i].Left;
      end
      else begin
        cboIonizerModel[i].Left   := cboIonizerModel[i-1].Left + cboIonizerModel[i-1].Width + 1;
      end;
    end;

    cboIonizerModel[i].Width  := (grpSerialSetting.Width - pnlModelonizer.Left - pnlModelonizer.Width - 4) div DefCommon.MAX_IONIZER_CNT;
    cboIonizerModel[i].Font.Size := 9;
    cboIonizerModel[i].DropDownCount := 21;
    cboIonizerModel[i].Font.Name := 'Verdana';
    cboIonizerModel[i].Font.Style := [fsBold];
    cboIonizerModel[i].Items.Clear;
    cboIonizerModel[i].Items.Add('SBL');
    cboIonizerModel[i].Items.Add('SOB');
    cboIonizerModel[i].Style := csDropDownList;
    cboIonizerModel[i].Visible := True;
  end;

  // Set for Ca410 Set.
  grpCa410Set.Visible := False;
  for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin

    pnlProbeSerial[i]         := TRzPanel.Create(Self);
    pnlProbeSerial[i].Parent  := grpCa410Set;
    pnlProbeSerial[i].Width   := 106;
    pnlProbeSerial[i].Height  := 22;
    pnlProbeSerial[i].Left    := 4;
    pnlProbeSerial[i].Top     := 50 + i*(pnlProbeSerial[i].Height*2+10);
    pnlProbeSerial[i].BorderInner := fsNone;
    pnlProbeSerial[i].BorderOuter := fsFlatRounded;
    pnlProbeSerial[i].Caption := Format('CA410 probe %d',[i+1]);

    cboProbeSelect[i]         := TRzComboBox.Create(Self);
    cboProbeSelect[i].Parent  := grpCa410Set;
    cboProbeSelect[i].Width   := 284;
    cboProbeSelect[i].Height  := 22;
    cboProbeSelect[i].Left    := pnlProbeSerial[i].Width+pnlProbeSerial[i].Left   + 2;
    cboProbeSelect[i].Top     := pnlProbeSerial[i].Top;
    cboProbeSelect[i].Style   := csDropDownList;
    cboProbeSelect[i].DropDownCount := 10;
    cboProbeSelect[i].Tag     := i;
    cboProbeSelect[i].OnClick := cboProbeSelectOnClickEvent;

    edtProbeSerial[i]         := TRzEdit.Create(Self);
    edtProbeSerial[i].Parent  := grpCa410Set;
    edtProbeSerial[i].Width   := 200;
    edtProbeSerial[i].Height  := 22;
    edtProbeSerial[i].Top     := pnlProbeSerial[i].Top + pnlProbeSerial[i].Height + 2;
    edtProbeSerial[i].Left    := pnlProbeSerial[i].Left;

    edtProbeDevice[i] := TRzEdit.Create(Self);
    edtProbeDevice[i].Parent := grpCa410Set;
    edtProbeDevice[i].Width  := 100;
    edtProbeDevice[i].Height := 22;
    edtProbeDevice[i].Top     := pnlProbeSerial[i].Top + pnlProbeSerial[i].Height + 2;
    edtProbeDevice[i].Left    := pnlProbeSerial[i].Left + pnlProbeSerial[i].Width;

    edtProbeDevice[i].Visible := False;
  end;
  grpCa410Set.Visible := True;
  grpSerialSetting.Visible := True;
end;

procedure TfrmSystemSetup.ReadBCRPortInfo;
var
  MyConfig : TIniFile;
begin
  MyConfig := TIniFile.Create(Common.Path.SysInfo);
  with MyConfig do begin
    // Temp Control Comport
    cboBCR.Text    := ReadString('ComPortBCR', 'Port', 'None');
//    cboBaudRate1.Text    := ReadString('ComPortBCR', 'BaudRate', '9600');
//    cboStopBits1.Text    := ReadString('ComPortBCR', 'StopBits', '1');
//    cboDataBits1.Text    := ReadString('ComPortBCR', 'DataBits', '8');
//    cboParity1.Itemindex := ReadInteger('ComPortBCR', 'Parity', 0);
//    cboFlowControl1.Itemindex := ReadInteger('ComPortBCR', 'FlowControl', 1);
  end;
  MyConfig.Free;
end;

procedure TfrmSystemSetup.RzBitBtn1Click(Sender: TObject);
begin
  if CheckAdminPasswd then begin
    frmChangePassword := TfrmChangePassword.Create(Application);
    try
      frmChangePassword.ShowModal;
    finally
      frmChangePassword.Free;
      frmChangePassword := nil;
    end;
  end;
end;



procedure TfrmSystemSetup.RzBitBtn3Click(Sender: TObject);
var
  txFile : TextFile;
  sReadData, sTemp, sTemp2, sSearchIp : string;
begin
  dlgOpenGmes.InitialDir := Common.Path.Ini;
  dlgOpenGmes.Filter := 'Open GMES Setup File (*.txt)|*.txt';
  dlgOpenGmes.DefaultExt := dlgOpenGmes.Filter;
  if dlgOpenGmes.Execute then begin
    AssignFile(txFile,dlgOpenGmes.FileName);
    sSearchIp := '';
    try
      Reset(txFile);
      while not Eof(txFile) do begin
        Readln(txFile,sReadData);
        if Pos('MES_SERVICEPORT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'MES_SERVICEPORT=','',[rfReplaceAll]) );
          edServicePort.Text := sTemp;
        end
        else if Pos('MES_NETWORK=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'MES_NETWORK=','',[rfReplaceAll]) );
          edNetwork.Text := sTemp;
        end
        else if Pos('MES_DAEMONPORT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'MES_DAEMONPORT=','',[rfReplaceAll]) );
          edDeamonPort.Text := sTemp;
        end
        else if Pos('EAS_SERVICEPORT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'EAS_SERVICEPORT=','',[rfReplaceAll]) );
          edEasServicePort.Text := sTemp;
        end
        else if Pos('EAS_NETWORK=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'EAS_NETWORK=','',[rfReplaceAll]) );
          edEasNetwork.Text := sTemp;
        end
        else if Pos('EAS_DAEMONPORT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'EAS_DAEMONPORT=','',[rfReplaceAll]) );
          edEasDeamonPort.Text := sTemp;
        end
        else if Pos('EAS_REMOTESUBJECT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'EAS_REMOTESUBJECT=','',[rfReplaceAll]) );
          edEasRemoteSubject.Text := sTemp;
        end

        else if Pos('LOCAL_MES_IP=',sReadData) <> 0 then begin
          //GMES 셋업 파일에서 MES_LOCALSUBJECT, EAS_LOCALSUBJECT보다LOCAL_MES_IP가 먼저 와야 한다.
          sSearchIp := Trim(StringReplace(sReadData,'LOCAL_MES_IP=','',[rfReplaceAll]) );
        end
        else if Pos('MES_LOCALSUBJECT=',sReadData) <> 0 then begin
          sTemp := Trim(common.GetLocalIpList(DefCommon.IP_LOCAL_GMES,sSearchIp));
          Common.SystemInfo.LocalIP_GMES := sTemp;
          Common.SaveLocalIpToSys(DefCommon.IP_LOCAL_GMES);
          sTemp2 := StringReplace( sTemp,'.','_',[rfReplaceAll] );
          sTemp := Trim(StringReplace(sReadData,'MES_LOCALSUBJECT=','',[rfReplaceAll]) );
          edLocalSubject.Text := sTemp + sTemp2;
        end
        else if Pos('EAS_LOCALSUBJECT=',sReadData) <> 0 then begin
          sTemp := Trim(common.GetLocalIpList(DefCommon.IP_LOCAL_GMES,sSearchIp));
          Common.SystemInfo.LocalIP_GMES := sTemp;
          Common.SaveLocalIpToSys(DefCommon.IP_LOCAL_GMES);
          sTemp2 := StringReplace( sTemp,'.','_',[rfReplaceAll] );
          sTemp := Trim(StringReplace(sReadData,'EAS_LOCALSUBJECT=','',[rfReplaceAll]) );
          edEasLocalSubject.Text := sTemp + sTemp2;
        end
        else if Pos('MES_REMOTESUBJECT=',sReadData) <> 0 then begin
          sTemp := Trim(StringReplace(sReadData,'MES_REMOTESUBJECT=','',[rfReplaceAll]) );
          edRemoteSubject.Text := sTemp;
        end;
      end;
    finally
      CloseFile(txFile);
    end;
  end;
end;

procedure TfrmSystemSetup.RzBitBtn4Click(Sender: TObject);
var
  i, j,nDeviceCnt : Integer;
  sIdx, sGetSerial : string;
begin
{$IFDEF CA410_USE}
  nDeviceCnt := DllCaSdk2.ProbeFound_Count;
  for i := 0 to Pred(DefCommon.MAX_CA_DRIVE_CNT) do begin
    cboProbeSelect[i].Items.Clear;
    cboProbeSelect[i].Items.Add('NONE');
    for j := 0 to Pred(nDeviceCnt) do begin
      sIdx := Format(CA410_DISPLAY_ITEM{'USB ID (COMM%d), SerialNo (%s)'},[DllCaSdk2.DeviceInfo[j].DeviceId,DllCaSdk2.DeviceInfo[j].SerialNo]);
      cboProbeSelect[i].Items.Add(sIdx);
    end;
  end;
{$ENDIF}
end;

procedure TfrmSystemSetup.btnAutoBackupClick(Sender: TObject);
begin

//  dlgOpen.InitialDir := 'D:\';

  if dlgOpen.Execute then begin
    edAutoBackup.Text := dlgOpen.SelectedPathName;
  end;
end;

procedure TfrmSystemSetup.SaveBCRPortInfo;
var
    MyConfig : TIniFile;
begin
  MyConfig := TIniFile.Create(Common.Path.SysInfo);
  with MyConfig do begin
    WriteString('ComPortBCR', 'Port',     cboBCR.Text);
//    WriteString('ComPortBCR', 'BaudRate', cboBaudRate1.Text);
//    WriteString('ComPortBCR', 'StopBits', cboStopBits1.Text);
//    WriteString('ComPortBCR', 'DataBits', cboDataBits1.Text );
//    WriteInteger('ComPortBCR', 'Parity',  cboParity1.Itemindex);
//    WriteInteger('ComPortBCR', 'FlowControl', cboFlowControl1.Itemindex);
  end;
  MyConfig.Free;
  WritePrivateProfileString(nil, nil, nil, PChar(Common.Path.SysInfo));
end;

end.
