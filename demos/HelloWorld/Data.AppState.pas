unit Data.AppState;

interface

uses
  System.SysUtils, System.Classes, System.Messaging;

type
  TSomethingChangedMsg = class(TMessage<string>);

  TAppState = class(TDataModule)
  private
    FSomething: string;
    procedure SetSomething(const Value: string);
  public
    property Something: string read FSomething write SetSomething;
  end;

var
  AppState: TAppState;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TAppState }

procedure TAppState.SetSomething(const Value: string);
begin
  if FSomething <> Value then
  begin
    FSomething := Value;
    TMessageManager.DefaultManager.SendMessage(Self, TSomethingChangedMsg.Create(FSomething));
  end;
end;

end.
