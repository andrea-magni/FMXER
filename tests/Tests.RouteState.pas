unit Tests.RouteState;

// The state of a route (DefineRoute<TView, TState>), its arguments
// (RouteTo<TState>) and its result (RouteToForResult, CloseRouteWithResult).

interface

uses
  System.SysUtils, System.Classes, System.Rtti, DUnitX.TestFramework
, FMX.Forms
, FormStand
, FMXER.Navigator, FMXER.ContainerForm
, Tests.Common
;

type
  TOrderState = class(TComponent)
  public
    class var Created: Integer;
    class var Destroyed: Integer;
  public
    OrderId: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  [TestFixture]
  TRouteStateFixture = class
  private
    FMain: TForm;
    FSeenId: Integer;
    FSeenState: TOrderState;
    procedure DefineOrder(const AKeepAlive: Boolean = False);
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure StateIsCreatedBeforeTheView;
    [Test] procedure StateIsFreedWithTheRoute;
    [Test] procedure KeptAliveStateIsReused;
    [Test] procedure InitIsNotRepeatedOnAnActiveRoute;
    [Test] procedure ResultOfCloseRouteWithResult;
    [Test] procedure EmptyResultWhenClosedOtherwise;
    [Test] procedure ResultOfARouteWithoutState;
    [Test] procedure RouteStateRaisesWithoutState;
  end;

implementation

{ TOrderState }

constructor TOrderState.Create(AOwner: TComponent);
begin
  inherited;
  Inc(Created);   // the virtual constructor of the actual class is called
end;

destructor TOrderState.Destroy;
begin
  Inc(Destroyed);
  inherited;
end;

{ TRouteStateFixture }

procedure TRouteStateFixture.Setup;
begin
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
  Navigator(TFormStand.Create(FMain));
  Navigator.DefineRoute<TContainerForm>('home').DefineRoute<TContainerForm>('plain');
  TOrderState.Created := 0;
  TOrderState.Destroyed := 0;
  FSeenId := -1;
  FSeenState := nil;
end;

procedure TRouteStateFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
  Pump(50);
end;

procedure TRouteStateFixture.DefineOrder(const AKeepAlive: Boolean);
begin
  Navigator.DefineRoute<TContainerForm, TOrderState>('order'
  , procedure (View: TContainerForm; State: TOrderState)
    begin
      Assert.IsNotNull(View);
      FSeenId := State.OrderId;   // already initialized when the view is built
      FSeenState := State;
    end
  , AKeepAlive);
end;

procedure TRouteStateFixture.StateIsCreatedBeforeTheView;
begin
  DefineOrder;
  Navigator.RouteTo<TOrderState>('order'
  , procedure (State: TOrderState)
    begin
      State.OrderId := 42;
    end
  );
  Assert.AreEqual(1, TOrderState.Created);
  Assert.AreEqual(42, FSeenId, 'AInit runs before the view is built');
  Assert.IsTrue(Navigator.HasRouteState('order'));
  Assert.AreSame(FSeenState, Navigator.RouteState<TOrderState>('order'));
  Assert.AreSame(Navigator.ActiveRoutes['order'].Subject, FSeenState.Owner, 'the view owns the state');
end;

procedure TRouteStateFixture.StateIsFreedWithTheRoute;
begin
  DefineOrder;
  Navigator.RouteTo<TOrderState>('order', nil);
  Navigator.CloseRoute('order');
  Assert.IsFalse(Navigator.HasRouteState('order'));
  Pump(1000);
  Assert.AreEqual(1, TOrderState.Destroyed, 'freed with the view');

  Navigator.RouteTo('order');   // the plain RouteTo works too: a new state
  Assert.AreEqual(2, TOrderState.Created);
  Assert.AreEqual(0, FSeenId);
end;

procedure TRouteStateFixture.KeptAliveStateIsReused;
begin
  DefineOrder(True);
  Navigator.RouteTo<TOrderState>('order'
  , procedure (State: TOrderState)
    begin
      State.OrderId := 7;
    end
  );
  var LFirst := FSeenState;
  Navigator.CloseRoute('order');
  Pump(1000);
  Assert.AreEqual(0, TOrderState.Destroyed, 'kept alive');

  Navigator.RouteTo('order');
  Assert.AreSame(LFirst, FSeenState, 'the same state');
  Assert.AreEqual(7, FSeenId, 'with its values');
  Assert.AreEqual(1, TOrderState.Created);

  TNavigatorAccess.Reset;
  Assert.AreEqual(1, TOrderState.Destroyed, 'freed with the navigator');
end;

procedure TRouteStateFixture.InitIsNotRepeatedOnAnActiveRoute;
begin
  DefineOrder;
  Navigator.RouteTo<TOrderState>('order'
  , procedure (State: TOrderState)
    begin
      State.OrderId := 1;
    end
  );
  Navigator.RouteTo<TOrderState>('order'
  , procedure (State: TOrderState)
    begin
      State.OrderId := 2;
    end
  );
  Assert.AreEqual(1, Navigator.RouteState<TOrderState>('order').OrderId, 'already active: only shown');
  Assert.AreEqual(1, TOrderState.Created);
end;

procedure TRouteStateFixture.ResultOfCloseRouteWithResult;
begin
  DefineOrder;
  var LCalls := 0;
  var LResult := TValue.Empty;
  Navigator.RouteTo<TOrderState>('order', nil
  , procedure (AResult: TValue)
    begin
      Inc(LCalls);
      LResult := AResult;
    end
  );
  Navigator.CloseRouteWithResult('order', 'saved');
  Assert.AreEqual(1, LCalls);
  Assert.AreEqual('saved', LResult.AsString);
  Navigator.CloseRouteWithResult('order', 'again');
  Assert.AreEqual(1, LCalls, 'once');
end;

procedure TRouteStateFixture.EmptyResultWhenClosedOtherwise;
begin
  DefineOrder;
  var LCalls := 0;
  var LResult := TValue.From(123);
  Navigator.RouteTo('home');
  Navigator.RouteTo<TOrderState>('order', nil
  , procedure (AResult: TValue)
    begin
      Inc(LCalls);
      LResult := AResult;
    end
  );
  Navigator.StackPop;   // what Back does
  Assert.AreEqual(1, LCalls);
  Assert.IsTrue(LResult.IsEmpty, 'no result');
end;

procedure TRouteStateFixture.ResultOfARouteWithoutState;
begin
  var LResult := TValue.Empty;
  Navigator.RouteToForResult('plain'
  , procedure (AResult: TValue)
    begin
      LResult := AResult;
    end
  );
  Navigator.CloseRouteWithResult('plain', 7);
  Assert.AreEqual(7, LResult.AsInteger);
end;

procedure TRouteStateFixture.RouteStateRaisesWithoutState;
begin
  Navigator.RouteTo('plain');
  Assert.IsFalse(Navigator.HasRouteState('plain'));
  Assert.WillRaise(
    procedure
    begin
      Navigator.RouteState<TOrderState>('plain');
    end
  , Exception);
end;

initialization
  TDUnitX.RegisterTestFixture(TRouteStateFixture);

end.
