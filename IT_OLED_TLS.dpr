program IT_OLED_TLS;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  CommDIO_DAE in 'CommDIO_DAE.pas',
  CommGmes in 'CommGmes.pas',
  CommHandBCR in 'CommHandBCR.pas',
  CommIonizer in 'CommIonizer.pas',
  CommonClass in 'CommonClass.pas',
  CommPG in 'CommPG.pas',
  CtrlDio_Tls in 'CtrlDio_Tls.pas',
  DefCommon in 'DefCommon.pas',
  DefDio in 'DefDio.pas',
  DefGmes in 'DefGmes.pas',
  DefPG in 'DefPG.pas',
  DefRs232 in 'DefRs232.pas',
  DefScript in 'DefScript.pas',
  DefTest in 'DefTest.pas',
  DfsFtp in 'DfsFtp.pas',
  FormExPat in 'FormExPat.pas' {frmExPat},
  FormDioDisplayAlarm in 'FormDioDisplayAlarm.pas' {frmDisplayAlarm},
  FormLogIn in 'FormLogIn.pas' {frmLogIn},
  FormMainter in 'FormMainter.pas' {frmMainter},
  FormMainTLS in 'FormMainTLS.pas' {frmMain_Tls},
  FormModelInfo in 'FormModelInfo.pas' {frmModelInfo},
  FormModelSelect in 'FormModelSelect.pas' {frmSelectModel},
  FormNGMsg in 'FormNGMsg.pas' {frmNgMsg},
  FormUserID in 'FormUserID.pas' {UserIdDlg},
  DllCasSdkCa410 in 'DllCasSdkCa410.pas',
  FormTest3Ch in 'FormTest3Ch.pas' {frmTest3Ch},
  CtrlJig_Tls in 'CtrlJig_Tls.pas',
  FormDoorOpenAlarmMsg in 'FormDoorOpenAlarmMsg.pas' {frmDoorOpenAlarmMsg},
  pasScriptClass in 'pasScriptClass.pas',
  CommThermometerMulti in 'CommThermometerMulti.pas',
  CommModbusRtuTempPlate in 'CommModbusRtuTempPlate.pas',
  LibCommonFunc in 'LibCommonFunc.pas',
  LibUserFuncs in 'LibUserFuncs.pas',
  LibFTPClient in 'LibFTPClient.pas',
  FormSystemSetup in 'FormSystemSetup.pas' {frmSystemSetup},
  CtrlCssDll_Tls in 'CtrlCssDll_Tls.pas',
  DllLgdCssTls in 'DllLgdCssTls.pas',
  DllMesCom in 'DllMesCom.pas',
  DBModule in 'DBModule.pas' {DBModule_Sqlite: TDataModule},
  FormNgRatio in 'FormNgRatio.pas' {frmNGRatio};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TfrmMain_Tls, frmMain_Tls);
//  Application.CreateForm(TfrmNgMsg, frmNgMsg);
  Application.Run;
end.
