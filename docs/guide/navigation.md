# Navigation

`TNavigator` (unit `FMXER.Navigator`) turns the screens of an app into **named routes**. A route is defined once, created on demand when you route to it, and freed when you close it. The navigator keeps a stack of the open routes for the Back button.

## Initialization

The navigator is a singleton bound to one `TFormStand`, usually dropped on the main form:

```pascal
procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1);   // first call: creates the navigator on FormStand1
  // ...
end;
```

After that, `Navigator` (no arguments) returns the same instance from any unit. Calling `Navigator` before it is initialized raises *Navigator has not been initialized*; calling `TNavigator.Init` twice raises *Navigator has been already initialized*, and so does `Navigator(AFormStand)` with a form stand other than the first one (since v.1.4: it used to return the first navigator silently). `TNavigator.Initialized` tells whether it is ready (useful in code that can run during shutdown); `TNavigator.ReleaseInstance` frees it, so that it can be initialized again.

### More than one navigator

`Navigator` is a convenience for the app's main navigation, not a limit: a `TNavigator` can be created on any `TFormStand` with `TNavigator.Create`, and has its own routes and stack. Use one for an area with its own navigation — a tab, a side panel — and free it with its owner:

```pascal
FTabNavigator := TNavigator.Create(TabFormStand);   // a TFormStand on the tab's form or frame
FTabNavigator
  .DefineRoute<TScaffoldForm>('list', ...)
  .DefineRoute<TScaffoldForm>('detail', ...);
FTabNavigator.RouteTo('list');
// ...
FTabNavigator.Free;
```

## Defining routes

### With a form class

```pascal
Navigator.DefineRoute<TScaffoldForm>('home'
, procedure (Home: TScaffoldForm)
  begin
    Home.SetTitle('Home');
  end
);
```

`DefineRoute<T: TForm>(ARouteName, AConfigProc, AParent, AStandName)` records a route whose screen is a new `T`, created by the navigator's `TFormStand` in `AParent` (default: the `DefaultParent` of the form stand, or its owner — the main form) inside the stand `AStandName`, then configured by `AConfigProc`.

### With a function

For full control, define a route with a function that returns the `TSubjectInfo` of the new screen — for example to use a different `TFrameStand`/`TFormStand`, or a frame as a screen:

```pascal
Navigator.DefineRoute('about'
, function: TSubjectInfo
  begin
    Result := MainForm.FrameStand1.New<TAboutFrame>(nil, 'lightbox');
  end
);
```

`DefineRoute` returns the navigator, so definitions chain:

```pascal
Navigator(FormStand1)
  .DefineRoute<TScaffoldForm>('home', ...)
  .DefineRoute<TScaffoldForm>('detail', ...)
  .DefineRoute<TContainerForm>('wait', ...);
```

Each name can be defined once (a second `DefineRoute` with the same name raises an exception). `IsRouteDefined(AName)` checks it.

## Routing

| Call | Effect |
|---|---|
| `RouteTo(AName)` | creates the route if it is not active (calling its definition), pushes it on the stack, fires `OnCreateRoute`, shows it. If it is already active, just shows it again |
| `RouteTo(AName, True)` | same, but **transient**: the route is not pushed on the stack |
| `CloseRoute(AName)` | removes the route from the active ones and from the stack (wherever it is in the stack), hides it (stand animations), frees it, then fires `OnCloseRoute` |
| `StackPop` | closes the route on top of the stack (the Back button) |
| `CloseAllRoutes(AFilter)` | closes every active route, or the ones for which `AFilter(Name)` is `True` |
| `CloseAllRoutesExcept(AName)` | closes every active route but one |
| `RouteToDelayed(AName, ATransient, ADelay_ms)` | `RouteTo` after a delay (default 100 ms) |
| `CloseRouteDelayed(AName, ATransient, ADelay_ms)` | `CloseRoute` after a delay |

An unknown route name raises *Route definition not found: ...*.

```pascal
// open a detail screen, then go back
Navigator.RouteTo('detail');
// ...
Navigator.CloseRoute('detail');
```

### Transient routes

A transient route is an overlay that should not take part in Back navigation: a wait screen, a splash, an animation. The HelloWorld and Skia101 demos open one and close it after a few seconds:

```pascal
Navigator.RouteTo('spinner', True);
Navigator.CloseRouteDelayed('spinner', True, 3000);
```

The navigator remembers which routes were opened as transient: `CloseRoute`, `CloseAllRoutes` and `CloseAllRoutesExcept` handle them without being told (the `ATransient` parameter of `CloseRoute` is kept for compatibility).

::: info Before v.1.2
Up to v.1.1, `CloseRoute` removed the **top** of the stack whatever route it closed, and needed the same `ATransient` value used with `RouteTo`; `CloseAllRoutes` treated every route as non-transient and raised `EListError` (*Unbalanced stack or queue operation*) with a transient route open. On v.1.1, close routes in reverse order of opening and close transient routes with `CloseRoute(AName, True)` first.
:::

### Arguments and results

Routes have no parameters: a route [with a state](/guide/state#the-state-of-a-route) gets its arguments in the state, and any route can give a result back to whoever opened it, like `Navigator.pushNamed(arguments)` and `Navigator.pop(result)` in Flutter.

| Call | Effect |
|---|---|
| `RouteTo<TState>(AName, AInit, AOnResult = nil, ATransient = False)` | a route defined with `DefineRoute<TView, TState>`: `AInit` gets the new state before the view is built. If the route is already active, it is only shown: `AInit` is not called and the state keeps its values |
| `RouteToForResult(AName, AOnResult, ATransient = False)` | `RouteTo` for any route, with a result |
| `CloseRouteWithResult(AName, AResult: TValue)` | closes the route; `AOnResult` gets `AResult` |

`AOnResult: TProc<TValue>` is called **once**, when the route closes, before its hide animation. It gets the value of `CloseRouteWithResult`, or an empty `TValue` (`AResult.IsEmpty`) when the route is closed in another way: `CloseRoute`, `StackPop`, Back, `CloseAllRoutes`. A second `RouteTo...` with a result proc on an active route replaces the first.

```pascal
Navigator.RouteToForResult('pick_color'
, procedure (AResult: TValue)
  begin
    if not AResult.IsEmpty then
      Theme.Accent := AResult.AsType<TAlphaColor>;
  end
);

// in the pick_color route:
Navigator.CloseRouteWithResult('pick_color', TValue.From<TAlphaColor>(Picked));
```

`TValue` is in `System.Rtti`.

### Closing a route from inside it

A route often closes itself from one of its own buttons (the X action button of a scaffold). That is fine: `CloseRoute` hides the screen first and frees it afterwards, through the stand. To close a route and open another one in the same handler, close first and then route:

```pascal
.AddActionButton('X'
, procedure
  begin
    Navigator.CloseRoute('settings');
    Navigator.RouteTo('home');
  end
)
```

If the next screen must appear only after the hide animation, use `RouteToDelayed`.

## The stack and the Back button

`Stack` (a `TStack<string>`) holds the names of the non-transient routes, in opening order; `Breadcrumb` returns them as an array, first opened first.

The navigator handles the Android Back button and Esc by itself (since v.1.4):

```pascal
Navigator(FormStand1)
  .SetCatchBackKey(True);
```

| Situation | Back / Esc |
|---|---|
| more than one route on the stack | `StackPop`: the top route closes; the key is cleared, so Android does not close the app |
| only the root route | not handled: it goes to the form (on Android the app closes) |
| a transient route is open (a wait screen) | consumed, nothing is closed |

`CatchBackKey` hooks `OnKeyDown` of the form that owns the navigator's `FormStand`; your own `OnKeyDown` handler still receives every key the navigator does not handle. Without the hook, call `Navigator.HandleBackKey(Key, KeyChar)` from your handler — it returns `True` when it handled the key:

```pascal
procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Navigator.HandleBackKey(Key, KeyChar) then
    Exit;
  // other keys...
end;
```

### Back handlers

An element that closes something of its own on Back registers a back handler: a `TFunc<Boolean>` that the navigator calls before it closes any route, the last added first. When the handler returns `True` the key is handled, and no route is closed. The scaffold uses one while its [drawer](/elements/scaffold#drawer) is open.

```pascal
var LHandler: TFunc<Boolean> :=
  function: Boolean
  begin
    Result := Panel.Visible;   // Back hides the panel first
    if Result then
      Panel.Visible := False;
  end;
Navigator.AddBackHandler(LHandler);
// ...
Navigator.RemoveBackHandler(LHandler);   // the same reference
```

::: info Why not TFrameStand's Push/Pop?
TFrameStand 2.3 has its own navigation stack (`Push`/`Pop`) and Back handling (`CatchBackKey` on a stand). The navigator does not delegate to them: `Push` hides the page below while routes stay visible under the new one (overlays, wait screens), routes can be built by any stand (`DefineRoute` with a function), and closing a route through TFrameStand would skip the navigator's bookkeeping (active routes, stack, `OnCloseRoute`). The navigator follows the same rules for the keys instead. If you also show dialogs with `FormStand1.ShowModal` and its `CatchBackKey`, set it after `Navigator.SetCatchBackKey(True)`: the last hook installed runs first, so Back cancels the dialog before it closes a route.
:::

## The safe area

Android 15 and later draw every app **edge-to-edge** (RAD Studio 13 targets SDK 35+): the form covers the status bar and the navigation bar. On iOS the notch and the home indicator take part of the screen too. The navigator keeps the routes clear of them by default:

- when its `FormStand` is owned by a form, it puts a `TLayout` (`Align = Client`) in that form and makes it the `DefaultParent` of the `FormStand` (unless you set one): the routes created without an explicit parent are shown in it;
- it hooks `OnSafeAreaChanged` of the form and gives the safe area insets to that layout as margins. Your own `OnSafeAreaChanged` handler is still called.

The area under the system bars shows the background of the form (`Fill`). On Windows and macOS the insets are zero and nothing changes.

```pascal
// an app that handles the safe area by itself: before the first route is shown
Navigator(FormStand1).SetSafeArea(False);
```

`Navigator.SafeAreaLayout` is the layout (nil when `SafeArea` is `False`). Turning `SafeArea` off while routes are shown in it raises an exception. Routes created with an explicit parent (`DefineRoute<T>(Name, Proc, AParent)`) stay where you put them: give that parent the insets yourself if it covers the whole form.

## Events

| Event | Fired |
|---|---|
| `OnCreateRoute: TProc<string>` | after a route is created by `RouteTo` (not when an active route is shown again) |
| `OnCloseRoute: TProc<string>` | after a closed route has been hidden and freed |

Both have a fluent setter (`SetOnCreateRoute`, `SetOnCloseRoute`). The QRCode demo uses them to stop the camera when the reader screen closes, to close the app with the home route and to show the breadcrumb in the window caption:

```pascal
Navigator.SetOnCloseRoute(
  procedure (ARouteName: string)
  begin
    if ARouteName = 'QRReader' then
      MainData.StopCameraScanning(True);
    if ARouteName = 'home' then
      Close;
    Caption := string.Join(' - ', Navigator.Breadcrumb);
  end
).SetOnCreateRoute(
  procedure (ARouteName: string)
  begin
    Caption := string.Join(' - ', Navigator.Breadcrumb);
  end
);
```

## Closing the application

When the main form closes while routes are open, close the routes first so that their hide animations and `[Hide]` methods run, and let the home route's `OnCloseRoute` close the form:

```pascal
procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Navigator.ActiveRoutes.Count > 0 then
  begin
    Action := TCloseAction.caNone;
    Navigator.CloseAllRoutes();
  end;
end;
```


## Inspecting the navigator

| Member | Description |
|---|---|
| `ActiveRoutes: TDictionary<string, TSubjectInfo>` | the open routes and their infos; `ActiveRoutes['home'].Subject` is the screen |
| `RouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>>` | the definitions |
| `IsRouteActive(AName)`, `IsRouteDefined(AName)` | checks |
| `FormStand` | the `TFormStand` the navigator was initialized with |

The full list is in the [TNavigator reference](/reference/navigator).
