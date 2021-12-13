program WeatherProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Frames.WeatherSituation in 'Frames.WeatherSituation.pas' {WeatherSituationFrame: TFrame},
  Data.Main in 'Data.Main.pas' {MainData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainData, MainData);
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
