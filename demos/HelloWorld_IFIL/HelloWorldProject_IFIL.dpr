program HelloWorldProject_IFIL;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Icons.FontAwesome in 'Icons.FontAwesome.pas',
  Icons.MaterialDesign in 'Icons.MaterialDesign.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  {$IFDEF MSWINDOWS}ReportMemoryLeaksOnShutdown := False;{$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
