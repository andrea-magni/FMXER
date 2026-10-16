unit Tests.Navigator;

// TNavigator: routes, stack, transient routes, events.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, DUnitX.TestFramework
, FMX.Types, FMX.Forms
, SubjectStand, FormStand
, FMXER.Navigator, FMXER.ContainerForm, FMXER.ScaffoldForm, FMXER.BackgroundFrame
, Tests.Common
;

type
  [TestFixture]
  TNavigatorFixture = class
  private
    FMain: TForm;
    FLog: string;
    function Stack: string;
    function Active: string;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure RouteToPushesAndCreatesOnce;
    [Test] procedure BreadcrumbIsInOpeningOrder;
    [Test] procedure CloseRouteRemovesThatRouteFromTheStack;
    [Test] procedure StackPopClosesTheTopRoute;
    [Test] procedure TransientRouteIsNotOnTheStack;
    [Test] procedure CloseTransientRouteWithoutFlag;
    [Test] procedure CloseAllRoutesWithATransientRoute;
    [Test] procedure CloseAllRoutesExcept;
    [Test] procedure ReopenedRouteIsPushedAgain;
    [Test] procedure EventsAreFired;
    [Test] procedure UnknownRouteRaises;
    [Test] procedure DelayedRouting;
    [Test] procedure ClosedRouteFreesItsElements;
  end;

implementation

{ TNavigatorFixture }

procedure TNavigatorFixture.Setup;
var
  LRoute: string;
begin
  FLog := '';
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
  Navigator(TFormStand.Create(FMain));
  for LRoute in ['a', 'b', 'c', 't'] do
    Navigator.DefineRoute<TContainerForm>(LRoute);
end;

procedure TNavigatorFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
end;

function TNavigatorFixture.Stack: string;
begin
  Result := string.Join(',', Navigator.Breadcrumb);
end;

function TNavigatorFixture.Active: string;
var
  LKeys: TArray<string>;
begin
  LKeys := Navigator.ActiveRoutes.Keys.ToArray;
  TArray.Sort<string>(LKeys);
  Result := string.Join(',', LKeys);
end;

procedure TNavigatorFixture.RouteToPushesAndCreatesOnce;
begin
  Navigator.RouteTo('a');
  var LFirst := Navigator.ActiveRoutes['a'];
  Navigator.RouteTo('a');
  Assert.AreSame(LFirst, Navigator.ActiveRoutes['a'], 'an active route is shown again, not created');
  Assert.AreEqual('a', Stack);
  Assert.IsTrue(Navigator.IsRouteActive('a'));
  Assert.IsFalse(Navigator.IsRouteActive('b'));
  Assert.IsTrue(Navigator.IsRouteDefined('b'));
  Assert.IsFalse(Navigator.IsRouteDefined('z'));
end;

procedure TNavigatorFixture.BreadcrumbIsInOpeningOrder;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.RouteTo('c');
  Assert.AreEqual('a,b,c', Stack);
  Assert.AreEqual('c', Navigator.Stack.Peek);
end;

procedure TNavigatorFixture.CloseRouteRemovesThatRouteFromTheStack;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.RouteTo('c');
  Navigator.CloseRoute('b');
  Pump(300);
  Assert.AreEqual('a,c', Stack);
  Assert.AreEqual('a,c', Active);
  Navigator.StackPop;
  Pump(300);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a', Active);
end;

procedure TNavigatorFixture.StackPopClosesTheTopRoute;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.StackPop;
  Pump(300);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a', Active);
  Navigator.StackPop;
  Navigator.StackPop; // empty stack: nothing to do
  Pump(300);
  Assert.AreEqual('', Stack);
  Assert.AreEqual('', Active);
end;

procedure TNavigatorFixture.TransientRouteIsNotOnTheStack;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('t', True);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a,t', Active);
  Navigator.CloseRoute('t', True);
  Pump(300);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a', Active);
end;

procedure TNavigatorFixture.CloseTransientRouteWithoutFlag;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('t', True);
  Navigator.CloseRoute('t'); // ATransient omitted: the navigator knows
  Pump(300);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a', Active);
end;

procedure TNavigatorFixture.CloseAllRoutesWithATransientRoute;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.RouteTo('t', True);
  Navigator.CloseAllRoutes;
  Pump(300);
  Assert.AreEqual('', Stack);
  Assert.AreEqual('', Active);
end;

procedure TNavigatorFixture.CloseAllRoutesExcept;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('t', True);
  Navigator.RouteTo('b');
  Navigator.RouteTo('c');
  Navigator.CloseAllRoutesExcept('a');
  Pump(300);
  Assert.AreEqual('a', Stack);
  Assert.AreEqual('a', Active);
end;

procedure TNavigatorFixture.ReopenedRouteIsPushedAgain;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('t', True);
  Navigator.CloseRoute('t');
  Pump(300);
  Navigator.RouteTo('t'); // same name, now as a normal route
  Assert.AreEqual('a,t', Stack);
  Navigator.CloseRoute('t');
  Pump(300);
  Assert.AreEqual('a', Stack);
end;

procedure TNavigatorFixture.EventsAreFired;
begin
  Navigator
  .SetOnCreateRoute(
    procedure (ARoute: string)
    begin
      FLog := FLog + '+' + ARoute;
    end)
  .SetOnCloseRoute(
    procedure (ARoute: string)
    begin
      FLog := FLog + '-' + ARoute;
    end);
  Navigator.RouteTo('a');
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.StackPop;
  Pump(300);
  Navigator.CloseRoute('a');
  Pump(300);
  Assert.AreEqual('+a+b-b-a', FLog);
end;

procedure TNavigatorFixture.UnknownRouteRaises;
begin
  var LRaised := False;
  try
    Navigator.RouteTo('z');
  except
    on Exception do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'unknown route');
  Assert.AreEqual('', Stack);
end;

procedure TNavigatorFixture.DelayedRouting;
begin
  Navigator.RouteToDelayed('a', False, 50);
  Assert.AreEqual('', Active);
  Pump(300);
  Assert.AreEqual('a', Active);
  Navigator.CloseRouteDelayed('a', False, 50);
  Pump(400);
  Assert.AreEqual('', Active);
  Assert.AreEqual('', Stack);
end;

procedure TNavigatorFixture.ClosedRouteFreesItsElements;
var
  LContentFreed, LNestedFreed: Boolean;
begin
  LContentFreed := False;
  LNestedFreed := False;
  Navigator.DefineRoute<TScaffoldForm>('s'
  , procedure (SF: TScaffoldForm)
    begin
      SF
      .SetTitleDetailContentAsFrame<TBackgroundFrame>(
        procedure (BF: TBackgroundFrame)
        begin
          BF.SetContentAsFrame<TBackgroundFrame>(
            procedure (Nested: TBackgroundFrame)
            begin
              TDestroySentinel.Create(Nested, @LNestedFreed);
            end
          );
        end
      )
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BF: TBackgroundFrame)
        begin
          TDestroySentinel.Create(BF, @LContentFreed);
        end
      );
    end
  );
  Navigator.RouteTo('s');
  Pump(100);
  Assert.IsFalse(LContentFreed or LNestedFreed, 'elements of an active route are alive');
  Navigator.CloseRoute('s');
  Pump(300);
  Assert.IsTrue(LContentFreed, 'content frame freed with its route');
  Assert.IsTrue(LNestedFreed, 'nested title detail frame freed with its route');
end;

initialization
  TDUnitX.RegisterTestFixture(TNavigatorFixture);

end.
