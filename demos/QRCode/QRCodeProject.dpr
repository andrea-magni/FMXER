program QRCodeProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Routes.home in 'Routes.home.pas',
  Data.Main in 'Data.Main.pas' {MainData: TDataModule},
  Routes.colorPicker in 'Routes.colorPicker.pas',
  Routes.QRGenerator in 'Routes.QRGenerator.pas',
  Routes.QRReader in 'Routes.QRReader.pas',
  Threads.Scanner in 'Threads.Scanner.pas',
  Routes.Webview in 'Routes.Webview.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
