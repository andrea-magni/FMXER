# TNavigator

Unit `FMXER.Navigator`. Named routes on top of a `TFormStand`. For a guided tour see [Navigation](/guide/navigation).

```pascal
function Navigator(const AFormStand: TFormStand = nil): TNavigator;
```

Returns the singleton navigator. When it is not initialized yet and `AFormStand` is assigned, it initializes it first (`TNavigator.Init(AFormStand)`). Raises `Exception` (*Navigator has not been initialized*) when called with no form stand before initialization.

## Class members

| Member | Description |
|---|---|
| `class procedure Init(const AFormStand: TFormStand)` | creates the singleton; raises if already initialized |
| `class property Instance: TNavigator` | the singleton; raises if not initialized |
| `class property Initialized: Boolean` | whether `Init` was called (and the class destructor has not run yet) |
| `class procedure ReleaseInstance` | frees the singleton (since v.1.4); the routes still open are not closed |
| `constructor Create(const AFormStand: TFormStand)` | another navigator, with its own routes and stack; free it yourself |

The singleton is freed by the class destructor, at unit finalization. `Navigator(AFormStand)` raises when the singleton exists with another form stand.

## Route definition

| Member | Description |
|---|---|
| `DefineRoute(const ARouteName: string; const ARouteDef: TFunc<TSubjectInfo>): TNavigator` | registers a route built by `ARouteDef`, which must create the subject and return its info (it is shown by the navigator) |
| `DefineRoute<T: TForm>(const ARouteName: string; const AConfigProc: TProc<T> = nil; const AParent: TFmxObject = nil; const AStandName: string = ''): TNavigator` | registers a route built as `FormStand.New<T>(AParent, AStandName)` + `AConfigProc` |
| `IsRouteDefined(const ARouteName: string): Boolean` | |
| `RouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>>` | the definitions (a duplicate name raises `EListError` on `DefineRoute`) |

## Routing

| Member | Description |
|---|---|
| `RouteTo(const ARouteName: string; const ATransient: Boolean = False)` | if the route is not active: builds it, adds it to `ActiveRoutes`, pushes it on `Stack` (unless transient), fires `OnCreateRoute`. Then shows it (`SubjectShow`). Raises `Exception` (*Route definition not found*) for unknown names |
| `RouteToDelayed(const ARouteName: string; const ATransient: Boolean; const ADelay_ms: Integer = 100)` | `RouteTo` through `TDelayedAction` |
| `CloseRoute(const ARouteName: string; const ATransient: Boolean = False)` | if active: `HideAndClose` with `OnCloseRoute` as continuation, removes it from `ActiveRoutes` and, unless it was opened as transient, from `Stack` (wherever it is). `ATransient` is ignored since v.1.2: the navigator remembers it. No-op for inactive routes |
| `CloseRouteDelayed(const ARouteName: string; const ATransient: Boolean; const ADelay_ms: Integer = 100)` | `CloseRoute` through `TDelayedAction` |
| `StackPop` | `CloseRoute(Stack.Peek)`, if the stack is not empty |
| `CloseAllRoutes(const AFilter: TPredicate<string> = nil)` | `CloseRoute(Name)` for every active route accepted by `AFilter` |
| `CloseAllRoutesExcept(const ARouteName: string)` | `CloseAllRoutes` with a filter excluding `ARouteName` |

::: info Before v.1.2
`CloseRoute` popped the top of `Stack` rather than removing `ARouteName`, and `CloseAllRoutes` raised `EListError` with a transient route open. See [Navigation](/guide/navigation#transient-routes).
:::

## State

| Member | Description |
|---|---|
| `ActiveRoutes: TDictionary<string, TSubjectInfo>` | open routes |
| `IsRouteActive(const ARouteName: string): Boolean` | |
| `Stack: TStack<string>` | non-transient routes, last opened on top |
| `Breadcrumb: TArray<string>` | `Stack` as an array, in opening order |
| `FormStand: TFormStand` | the form stand passed to `Init` |

## Events

| Member | Description |
|---|---|
| `OnCreateRoute: TProc<string>` / `SetOnCreateRoute(...): TNavigator` | after a route is built by `RouteTo` |
| `OnCloseRoute: TProc<string>` / `SetOnCloseRoute(...): TNavigator` | after a route is hidden and closed |

## Back button

| Member | Description |
|---|---|
| `HandleBackKey(var AKey: Word; var AKeyChar: WideChar): Boolean` | Back (`vkHardwareBack`) or Esc: `StackPop` when the stack has more than one route; consumed without action while a transient route is open; not handled at the root. Clears `AKey`/`AKeyChar` and returns `True` when handled |
| `AddBackHandler(AHandler: TFunc<Boolean>): TNavigator` | Back/Esc calls `AHandler` first (the last added first): when it returns `True` the key is handled and no route is closed (v.1.7). See [Back handlers](/guide/navigation#back-handlers) |
| `RemoveBackHandler(AHandler: TFunc<Boolean>)` | removes it (pass the same reference) |
| `CatchBackKey: Boolean` / `SetCatchBackKey(AValue): TNavigator` | hooks `OnKeyDown` of the form that owns `FormStand` and calls `HandleBackKey`; the previous handler gets the keys not handled. Raises when `FormStand` is not owned by a form |
