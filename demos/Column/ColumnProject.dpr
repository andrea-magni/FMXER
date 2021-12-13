program ColumnProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm};

{$R *.res}

begin
  {$IFDEF MSWINDOWS} ReportMemoryLeaksOnShutdown := True; {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
