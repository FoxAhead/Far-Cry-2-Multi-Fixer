program FarCry2MFLauncher;

{$R 'FarCry2MFL_FormOptions.res' 'FarCry2MFL_FormOptions.rc'}

uses
  Forms,
  FarCry2MF_Options in 'FarCry2MF_Options.pas',
  FarCry2MFL_Proc in 'FarCry2MFL_Proc.pas',
  FarCry2MFL_FormMain in 'FarCry2MFL_FormMain.pas' {Form1},
  FarCry2MFL_FormMods in 'FarCry2MFL_FormMods.pas' {FormMods},
  FarCry2MFL_FormOptions in 'FarCry2MFL_FormOptions.pas' {FormOptions},
  FarCry2MFL_FormProgress in 'FarCry2MFL_FormProgress.pas' {FormProgress},
  FarCry2MFL_InstallSearch in 'FarCry2MFL_InstallSearch.pas',
  UnitCRC32 in 'UnitCRC32.pas';

{$R *.res}

begin
  if AlreadyRunning() then Exit;
  InitializeVars();
  Application.Title := 'Far Cry 2 Multi Fixer Launcher';
  Application.ShowMainForm := not IsSilentLaunch();
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

