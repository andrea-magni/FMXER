unit Utils.Msg;

interface

uses
  Classes, SysUtils, System.Messaging, TypInfo, System.Rtti
;

type
  TStringMessage = class(TMessage<string>);

  TStringMessageHelper = class helper for TStringMessage
  public
    class procedure CreateAndSend(const AString: string);
    class function Subscribe(const AHandler: TProc<string>): Integer;
  end;

  TRetrieveMsg = class(TStringMessage);


implementation

class procedure TStringMessageHelper.CreateAndSend(const AString: string);
begin
  TMessageManager.DefaultManager.SendMessage(nil, Self.Create(AString));
end;

class function TStringMessageHelper.Subscribe(const AHandler: TProc<string>): Integer;
begin
  Assert(Assigned(AHandler));

  Result := TMessageManager.DefaultManager.SubscribeToMessage(
    Self
  , procedure(const Sender: TObject; const M: TMessage)
    begin
      AHandler((M as Self).Value);
    end
  );
end;

end.
