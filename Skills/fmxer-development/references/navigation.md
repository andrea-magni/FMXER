# Navigation: routes and TNavigator

Unit `FMXER.Navigator`. Docs: https://andrea-magni.github.io/FMXER/guide/navigation

## Initialization

`Navigator(FormStand1)` in the main form's `OnCreate`, before anything else: the first call with a form stand creates the singleton (`TNavigator.Init`), later `Navigator` with no arguments returns it from any unit. Calling `Navigator` before that raises *Navigator has not been initialized*; `TNavigator.Init` twice raises *Navigator has been already initialized*. `TNavigator.Initialized` is useful in code that can run during shutdown. The instance is freed at unit finalization.

## Defining routes

```pascal
// a form class: created by Navigator.FormStand in AParent (default: the form stand's DefaultParent
// or its owner, the main form) inside the stand AStandName, then configured
Navigator.DefineRoute<TScaffoldForm>('home'
, procedure (Home: TScaffoldForm)
  begin
    Home.SetTitle('Home');
  end
);

// a function returning the info: another TFrameStand/TFormStand, a frame as a screen, a stand
Navigator.DefineRoute('about'
, function: TSubjectInfo
  begin
    Result := MainForm.FrameStand1.New<TAboutFrame>(nil, 'lightbox');  // created, not shown: the navigator shows it
  end
);
```

- `DefineRoute` returns the navigator: definitions chain (`Navigator(FormStand1).DefineRoute<...>(...).DefineRoute<...>(...)`).
- A name is defined once (a duplicate raises); `IsRouteDefined(AName)` checks. Names are case-sensitive: keep them in constants.
- Nothing is created by `DefineRoute`: the configuration procedure runs at each `RouteTo` that builds the route, so it reads the **current** state of the app.
- Project layout used by the demos: one unit per route (`Routes.home.pas`) exporting `procedure DefineHomeRoute(const ARouteName: string);`, called from `FormCreate`; the route closes itself with `Navigator.CloseRoute(ARouteName)`.

## Routing

| Call | Effect |
|---|---|
| `RouteTo(AName)` | not active: builds it, adds to `ActiveRoutes`, pushes on `Stack`, fires `OnCreateRoute`; then shows it. Already active: shows it again |
| `RouteTo(AName, True)` | transient: same, not pushed on the stack |
| `CloseRoute(AName)` | active: `HideAndClose` (stand animations, then free) with `OnCloseRoute` afterwards; removed from `ActiveRoutes` and from the stack wherever it is. No-op if not active |
| `StackPop` | `CloseRoute(Stack.Peek)` if the stack is not empty |
| `CloseAllRoutes(AFilter)` | `CloseRoute` for every active route (accepted by `AFilter: TPredicate<string>`) |
| `CloseAllRoutesExcept(AName)` | all but one |
| `RouteToDelayed(AName, ATransient, ADelay_ms = 100)`, `CloseRouteDelayed(...)` | through `TDelayedAction` |

Unknown names raise *Route definition not found: ...*.

### Transient routes

Overlays that must not take part in Back navigation: wait screens, splash, animations.

```pascal
Navigator.RouteTo('spinner', True);
Navigator.CloseRouteDelayed('spinner', True, 3000);
```

Since v.1.2 the navigator remembers which routes are transient: `CloseRoute`, `CloseAllRoutes` and `CloseAllRoutesExcept` handle them (the `ATransient` parameter of `CloseRoute` is ignored). On v.1.1 `CloseRoute` popped the top of the stack whatever route it closed and `CloseAllRoutes` raised `EListError` with a transient route open: close routes in reverse order there.

### Closing a route from inside it

Fine: `CloseRoute` hides first, frees afterwards (through the stand). Close then route:

```pascal
.AddActionButton('X'
, procedure
  begin
    Navigator.CloseRoute('settings');
    Navigator.RouteTo('home');          // RouteToDelayed to wait for the hide animation
  end
)
```

## Passing data to a route

Routes have no parameters. Store the value where the definition can read it (a data module, a field, a captured variable), then `RouteTo`: the route is rebuilt and reads it.

```pascal
List.AddItem(Author.Surname, '', -1
, procedure (const AItem: TListViewItem)
  begin
    RemoteData.selectedAuthorId := AItem.Tag;
    Navigator.RouteTo('books_by_author');   // its definition reads selectedAuthorId
  end
);
```

If the route may already be active (it would only be shown again, not rebuilt), close it first: `Navigator.CloseRoute('detail'); Navigator.RouteTo('detail');`.

## Back button

```pascal
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) {$IFDEF MSWINDOWS}or (Key = vkEscape){$ENDIF} then
    if Navigator.Stack.Count > 1 then      // never pop the home route
    begin
      Key := 0;                             // Android: do not close the app
      Navigator.StackPop;
    end;
end;
```

`Stack: TStack<string>` holds the non-transient routes (last opened on top); `Breadcrumb` returns them first-opened-first (`Caption := string.Join(' - ', Navigator.Breadcrumb)`).

## Events and closing the app

```pascal
Navigator.SetOnCloseRoute(                  // after the route was hidden and freed
  procedure (ARouteName: string)
  begin
    if ARouteName = 'QRReader' then
      MainData.StopCameraScanning(True);    // release what the screen used
    if ARouteName = 'home' then
      Close;
  end
).SetOnCreateRoute(                         // after RouteTo built a route (not when re-shown)
  procedure (ARouteName: string)
  begin
    Caption := string.Join(' - ', Navigator.Breadcrumb);
  end
);

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Navigator.ActiveRoutes.Count > 0 then  // let the hide animations and [Hide] methods run
  begin
    Action := TCloseAction.caNone;
    Navigator.CloseAllRoutes();              // the home route's OnCloseRoute closes the form
  end;
end;
```

## Inspecting

`ActiveRoutes: TDictionary<string, TSubjectInfo>` (`ActiveRoutes['home'].Subject as TScaffoldForm`), `RouteDefinitions`, `IsRouteActive(AName)`, `IsRouteDefined(AName)`, `FormStand`.

To animate whole screens, give `Navigator.FormStand.StandBook` a style book with stands and pass the stand name as the 4th argument of `DefineRoute<T>`.
