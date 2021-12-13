program HelloWorldProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Frames.Custom1 in 'Frames.Custom1.pas' {Custom1Frame: TFrame};

{$R *.res}

begin
  {$IFDEF MSWINDOWS} ReportMemoryLeaksOnShutdown := True; {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
