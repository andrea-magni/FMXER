program NewProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Routes.home in 'Routes.home.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
