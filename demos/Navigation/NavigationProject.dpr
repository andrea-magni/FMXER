program NavigationProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Routes.Home in 'Routes.Home.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
