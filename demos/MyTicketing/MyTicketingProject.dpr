program MyTicketingProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Data.Remote in 'Data.Remote.pas' {RemoteData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TRemoteData, RemoteData);
  Application.Run;
end.
