program Skia101Project;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Frames.Spinner in 'Frames.Spinner.pas' {SpinnerFrame: TFrame},
  Routes.home in 'Routes.home.pas',
  Routes.menu in 'Routes.menu.pas',
  Routes.spinner in 'Routes.spinner.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  GlobalUseSkiaRasterWhenAvailable := False;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
