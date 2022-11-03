program ColumnProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm};

{$R *.res}

begin
  GlobalUseSkia := True;
  {$IFDEF MSWINDOWS} ReportMemoryLeaksOnShutdown := True; {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
