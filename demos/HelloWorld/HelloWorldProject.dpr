program HelloWorldProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Frames.Custom1 in 'Frames.Custom1.pas' {Custom1Frame: TFrame},
  Routes.home in 'Routes.home.pas',
  Routes.bubble in 'Routes.bubble.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  GlobalUseSkiaRasterWhenAvailable := False;

  {$IFDEF MSWINDOWS} ReportMemoryLeaksOnShutdown := False; {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
