unit Utils.Msg;

interface

uses
  Classes, SysUtils, System.Messaging, TypInfo, System.Rtti
;

type
  TStringMessage = class(TMessage<string>);

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

  TStringMessageHelper = class helper for TStringMessage
  public
    class procedure CreateAndSend(const AString: string);
    // the subscription is removed when AOwner is destroyed
    class function Subscribe(const AOwner: TComponent;
      const AHandler: TProc<string>): TSubscriptionGuard;
  end;

  TRetrieveMsg = class(TStringMessage);


implementation

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

{ TStringMessageHelper }

class procedure TStringMessageHelper.CreateAndSend(const AString: string);
begin
  TMessageManager.DefaultManager.SendMessage(nil, Self.Create(AString));
end;

class function TStringMessageHelper.Subscribe(const AOwner: TComponent;
  const AHandler: TProc<string>): TSubscriptionGuard;
begin
  Assert(Assigned(AOwner));
  Assert(Assigned(AHandler));

  Result := TSubscriptionGuard.Create(
    AOwner
  , Self
  , procedure(const Sender: TObject; const M: TMessage)
    begin
      AHandler((M as Self).Value);
    end
  );
end;

end.
