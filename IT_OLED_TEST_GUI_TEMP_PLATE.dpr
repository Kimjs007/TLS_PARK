program IT_OLED_TEST_GUI_TEMP_PLATE;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  FormTestGuitTempPlates in 'FormTestGuitTempPlates.pas' {Form5},
  CommModbusRtuTempPlate in 'CommModbusRtuTempPlate.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
