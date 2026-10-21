unit Tests.Observable;

// Observable values (TObservable<T>, TChangeNotifier): notifications, the
// lifetime of the listeners tied to their owners, the main thread.

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.SyncObjs, DUnitX.TestFramework
, FMXER.Observable
, Tests.Common
;

type
  TPoint2 = record
    X, Y: Integer;
  end;

  [TestFixture]
  TObservableFixture = class
  private
    FOwner: TComponent;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure ListenCallsNowAndOnChange;
    [Test] procedure NoNotificationWithoutChange;
    [Test] procedure ListenersInRegistrationOrder;
    [Test] procedure ListenerRemovedWhenItsOwnerIsFreed;
    [Test] procedure ObservableFreedBeforeTheOwner;
    [Test] procedure UnlistenRemovesTheListeners;
    [Test] procedure UpdateARecord;
    [Test] procedure NotifyWithoutChange;
    [Test] procedure FreedWithItsOwner;
    [Test] procedure BackgroundThreadNotifiesInTheMainThread;
    [Test] procedure QueuedNotificationDroppedAfterFree;
    [Test] procedure ListenerFreeingAnotherOwner;
    [Test] procedure ChangeNotifier;
  end;

implementation

{ TObservableFixture }

procedure TObservableFixture.Setup;
begin
  FOwner := TComponent.Create(nil);
end;

procedure TObservableFixture.TearDown;
begin
  FreeAndNil(FOwner);
end;

procedure TObservableFixture.ListenCallsNowAndOnChange;
begin
  var LValues := '';
  var LTotal := TObservable<Integer>.Create(FOwner, 10);
  LTotal.Listen(nil,
    procedure (AValue: Integer)
    begin
      LValues := LValues + AValue.ToString + ',';
    end);
  Assert.AreEqual('10,', LValues, 'called now with the current value');
  LTotal.Value := 20;
  Assert.AreEqual('10,20,', LValues);
  Assert.AreEqual(20, LTotal.Value);

  var LLater := '';
  LTotal.Listen(nil,
    procedure (AValue: Integer)
    begin
      LLater := LLater + AValue.ToString;
    end, False);
  Assert.AreEqual('', LLater, 'ACallNow = False');
end;

procedure TObservableFixture.NoNotificationWithoutChange;
begin
  var LCalls := 0;
  var LName := TObservable<string>.Create(FOwner, 'Andrea');
  LName.Listen(nil,
    procedure (AValue: string)
    begin
      Inc(LCalls);
    end, False);
  LName.Value := 'Andrea';
  Assert.AreEqual(0, LCalls, 'same value');
  LName.Value := 'Magni';
  Assert.AreEqual(1, LCalls);
end;

procedure TObservableFixture.ListenersInRegistrationOrder;
begin
  var LLog := '';
  var LFlag := TObservable<Boolean>.Create(FOwner);
  LFlag.Listen(nil, procedure (V: Boolean) begin LLog := LLog + 'a'; end, False)
       .Listen(nil, procedure (V: Boolean) begin LLog := LLog + 'b'; end, False);
  Assert.AreEqual(2, LFlag.ListenerCount);
  LFlag.Value := True;
  Assert.AreEqual('ab', LLog);
end;

procedure TObservableFixture.ListenerRemovedWhenItsOwnerIsFreed;
begin
  var LCalls := 0;
  var LElement := TComponent.Create(nil);
  var LTotal := TObservable<Integer>.Create(FOwner);
  LTotal.Listen(LElement,
    procedure (AValue: Integer)
    begin
      Inc(LCalls);
    end, False);
  Assert.AreEqual(1, LTotal.ListenerCount);
  LElement.Free;   // the element goes away (its route closed)
  Assert.AreEqual(0, LTotal.ListenerCount, 'removed with its owner');
  LTotal.Value := 5;
  Assert.AreEqual(0, LCalls, 'not called on a freed element');
end;

procedure TObservableFixture.ObservableFreedBeforeTheOwner;
begin
  var LElement := TComponent.Create(nil);
  try
    var LTotal := TObservable<Integer>.Create(nil);
    LTotal.Listen(LElement, procedure (V: Integer) begin end);
    LTotal.Free;
  finally
    LElement.Free;   // no notification to a freed observable
  end;
  Assert.Pass;
end;

procedure TObservableFixture.UnlistenRemovesTheListeners;
begin
  var LCalls := 0;
  var LElement := TComponent.Create(FOwner);
  var LTotal := TObservable<Integer>.Create(FOwner);
  LTotal.Listen(LElement, procedure (V: Integer) begin Inc(LCalls); end, False)
        .Listen(LElement, procedure (V: Integer) begin Inc(LCalls); end, False)
        .Listen(nil, procedure (V: Integer) begin end, False);
  LTotal.Unlisten(LElement);
  Assert.AreEqual(1, LTotal.ListenerCount, 'only the listeners of that owner');
  LTotal.Value := 1;
  Assert.AreEqual(0, LCalls);
end;

procedure TObservableFixture.UpdateARecord;
begin
  var LLast: TPoint2;
  var LPoint := TObservable<TPoint2>.Create(FOwner);
  LPoint.Listen(nil, procedure (V: TPoint2) begin LLast := V; end, False);
  LPoint.Update(
    function (P: TPoint2): TPoint2
    begin
      Result := P;
      Result.X := 3;
    end);
  Assert.AreEqual(3, LLast.X);
  Assert.AreEqual(3, LPoint.Value.X);
end;

procedure TObservableFixture.NotifyWithoutChange;
begin
  var LCalls := 0;
  var LList := TObservable<TStringList>.Create(FOwner, TStringList.Create);
  try
    LList.Listen(nil, procedure (V: TStringList) begin Inc(LCalls); end, False);
    LList.Value.Add('changed inside');   // same object: no notification
    LList.Value := LList.Value;
    Assert.AreEqual(0, LCalls);
    LList.Notify;
    Assert.AreEqual(1, LCalls, 'Notify');
  finally
    LList.Value.Free;
  end;
end;

procedure TObservableFixture.FreedWithItsOwner;
begin
  var LState := TComponent.Create(nil);
  var LTotal := TObservable<Integer>.Create(LState);
  Assert.AreSame(LState, LTotal.Owner);
  LState.Free;   // frees the observable (no leak: checked by the runner)
  Assert.Pass;
end;

procedure TObservableFixture.BackgroundThreadNotifiesInTheMainThread;
begin
  var LThreadId: TThreadID := 0;
  var LValue := 0;
  var LTotal := TObservable<Integer>.Create(FOwner);
  LTotal.Listen(nil,
    procedure (AValue: Integer)
    begin
      LThreadId := TThread.CurrentThread.ThreadID;
      LValue := AValue;
    end, False);
  var LDone := TEvent.Create;
  try
    TTask.Run(
      procedure
      begin
        LTotal.Value := 42;   // from a background thread
        LDone.SetEvent;
      end);
    Assert.AreEqual(wrSignaled, LDone.WaitFor(5000));
    Assert.AreEqual(42, LTotal.Value, 'the value is set at once');
    Assert.AreEqual(0, LValue, 'the notification is queued');
    Pump(100);   // the main thread runs the queue
    Assert.AreEqual(42, LValue);
    Assert.AreEqual(MainThreadID, LThreadId, 'in the main thread');
  finally
    LDone.Free;
  end;
end;

procedure TObservableFixture.QueuedNotificationDroppedAfterFree;
begin
  var LCalls := 0;
  var LTotal := TObservable<Integer>.Create(nil);
  LTotal.Listen(nil, procedure (V: Integer) begin Inc(LCalls); end, False);
  var LDone := TEvent.Create;
  try
    TTask.Run(
      procedure
      begin
        LTotal.Value := 1;
        LDone.SetEvent;
      end);
    Assert.AreEqual(wrSignaled, LDone.WaitFor(5000));
    LTotal.Free;   // before the queued notification runs
    Pump(100);
    Assert.AreEqual(0, LCalls, 'dropped');
  finally
    LDone.Free;
  end;
end;

procedure TObservableFixture.ListenerFreeingAnotherOwner;
begin
  var LLog := '';
  var LSecond := TComponent.Create(nil);
  var LTotal := TObservable<Integer>.Create(FOwner);
  LTotal.Listen(nil,
    procedure (V: Integer)
    begin
      LLog := LLog + 'first,';
      FreeAndNil(LSecond);   // e.g. a listener that closes a route
    end, False);
  LTotal.Listen(LSecond, procedure (V: Integer) begin LLog := LLog + 'second,'; end, False);
  LTotal.Value := 1;
  Assert.AreEqual('first,', LLog, 'the listener of the freed owner is not called');
  Assert.AreEqual(1, LTotal.ListenerCount);
end;

procedure TObservableFixture.ChangeNotifier;
begin
  var LCalls := 0;
  var LElement := TComponent.Create(nil);
  var LChanged := TChangeNotifier.Create(FOwner);
  LChanged.Listen(LElement, procedure begin Inc(LCalls); end);
  Assert.AreEqual(0, LCalls, 'ACallNow = False by default');
  LChanged.NotifyChanged;
  Assert.AreEqual(1, LCalls);
  LChanged.Listen(nil, procedure begin Inc(LCalls); end, True);
  Assert.AreEqual(2, LCalls, 'ACallNow');
  LElement.Free;
  Assert.AreEqual(1, LChanged.ListenerCount);
  LChanged.Unlisten(nil);
  Assert.AreEqual(0, LChanged.ListenerCount);
end;

initialization
  TDUnitX.RegisterTestFixture(TObservableFixture);

end.
