program OrdersProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Forms.Main in 'Forms.Main.pas' {MainForm},
  Data.Orders in 'Data.Orders.pas',
  Data.OrderState in 'Data.OrderState.pas' {OrderState: TDataModule},
  Routes.Orders in 'Routes.Orders.pas',
  Routes.Order in 'Routes.Order.pas';

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
