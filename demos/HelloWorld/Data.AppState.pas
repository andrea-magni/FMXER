unit Data.AppState;

interface

uses
  System.SysUtils, System.Classes, System.Messaging;

type
  TSomethingChangedMsg = class(TMessage<string>);

  // Subscribes AListener to AMessageClass for as long as AOwner lives:
  // the guard is owned by AOwner (e.g. the element that the listener updates)
  // and unsubscribes when AOwner frees it (e.g. when the route is closed).
  TSubscriptionGuard = class(TComponent)
  private
    FMessageClass: TClass;
    FId: Integer;
  public
    constructor Create(const AOwner: TComponent; const AMessageClass: TClass;
      const AListener: TMessageListener); reintroduce;
    destructor Destroy; override;
  end;

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

{ TSubscriptionGuard }

constructor TSubscriptionGuard.Create(const AOwner: TComponent;
  const AMessageClass: TClass; const AListener: TMessageListener);
begin
  inherited Create(AOwner);
  FMessageClass := AMessageClass;
  FId := TMessageManager.DefaultManager.SubscribeToMessage(AMessageClass, AListener);
end;

destructor TSubscriptionGuard.Destroy;
begin
  TMessageManager.DefaultManager.Unsubscribe(FMessageClass, FId);
  inherited;
end;

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
