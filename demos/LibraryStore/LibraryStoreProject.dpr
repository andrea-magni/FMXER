program LibraryStoreProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  Skia.FMX,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Routes.Home in 'Routes.Home.pas',
  Routes.Books in 'Routes.Books.pas',
  Routes.Authors in 'Routes.Authors.pas',
  Utils.UI in 'Utils.UI.pas',
  Data.Remote in 'Data.Remote.pas' {RemoteData: TDataModule},
  Model in 'Model.pas',
  Routes.Bubbles in 'Routes.Bubbles.pas',
  Utils.Msg in 'Utils.Msg.pas',
  Routes.Book in 'Routes.Book.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TRemoteData, RemoteData);
  Application.Run;
end.
