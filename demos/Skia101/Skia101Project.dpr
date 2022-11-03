program Skia101Project;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Frames.Spinner in 'Frames.Spinner.pas' {SpinnerFrame: TFrame},
  Routes.home in 'Routes.home.pas',
  Routes.menu in 'Routes.menu.pas',
  Routes.spinner in 'Routes.spinner.pas',
  Routes.image in 'Routes.image.pas',
  Routes.freeHandDrawing in 'Routes.freeHandDrawing.pas',
  Utils in 'Utils.pas';

{$R *.res}

begin
  GlobalUseSkia := True;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
