# State & Events

FMXER has no state-management library of its own: elements are created by closures, and the closures are where state lives. This page collects the patterns used in the demos, and the rules that keep them safe.

## Element events are closures

Elements expose their events as anonymous-method properties or setters, not as `TNotifyEvent`s:

| Element | Event |
|---|---|
| `TButtonFrame` | `SetOnClickProc(TProc)` (also `SetOnClickHandler`, `OnClickHandler`), `OnUpdateHandler: TProc<TAction>` |
| `TEditFrame` | `OnChangeProc: TProc<Boolean>` — `True` while typing (`OnChangeTracking`), `False` on `OnChange` |
| `TTrackbarFrame` | `OnChangeProc: TProc<Single>` |
| `TColorPickerFrame` | `OnChangeProc: TProc<TAlphaColor>` |
| `TTextFrame` | `SetOnClickProc(TProc)` (also `SetOnClick`) |
| `TGlyphFrame` | `SetOnClickProc(TProc)` |
| `TChipFrame` | `SetOnClickProc(TProc)` (also `OnClickHandler`) |
| `TActionButtonFrame` | `SetOnClickProc(TProc)` (also `OnClickProc`) |
| `TImageFrame`, `TSVGFrame`, `TAnimatedImageFrame`, `TQRCodeFrame` | `SetOnTapHandler` / `OnTapHandler` (tap on mobile, mouse up on Windows) |
| `TListViewFrame` | a `TListViewItemClickProc` per item (`AddItem`), `SetOnSearchChange` |

Assign them in the configuration procedure:

```pascal
Col.AddFrame<TTrackbarFrame>(70
, procedure (Track: TTrackbarFrame)
  begin
    Track
    .SetCaption('Volume')
    .SetMin(0).SetMax(100).SetValue(50)
    .SetOnChangeProc(
      procedure (AValue: Single)
      begin
        Track.SetExtraText(Round(AValue).ToString + '%');
      end
    );
  end
);
```

## Sharing values between elements

### Captured variables

Elements built in the same procedure can share a local variable. The HelloWorld demo keeps a reference to an edit frame and reads it from a button of another element:

```pascal
var LEditFrame: TEditFrame := nil;

Col
.AddFrame<TEditFrame>(100
, procedure (Frame: TEditFrame)
  begin
    Frame.SetCaption('Name');
    LEditFrame := Frame;              // keep it for later
  end
)
.AddFrame<TButtonFrame>(60
, procedure (Button: TButtonFrame)
  begin
    Button.SetText('Greet').SetOnClickHandler(
      procedure
      begin
        ShowMessage('Hello, ' + LEditFrame.GetText);
      end
    );
  end
);
```

This is safe as long as both elements belong to the same screen: they are freed together.

::: warning Closures in a loop capture the variable, not its value
An anonymous method captures **variables**, not their values. An inline variable declared in the body of a loop is not a new variable at each iteration: it is one variable, shared by all the closures created in the loop. A handler that runs **later**, such as a tap or a timer, sees the value of the last iteration:

```pascal
for LIndex := 0 to High(Orders) do
begin
  var LOrder := LIndex;
  List.AddItem(Orders[LIndex].Customer, '', -1
  , procedure (const AItem: TListViewItem)
    begin
      OpenOrder(LOrder);   // wrong: the last order, whatever the item tapped
    end
  );
end;
```

Give each handler its own value instead:

- from the element that calls it, for example the `Tag` of the list item;
- or through a function that takes the value as a parameter and returns the closure, since each call has its own parameter.

```pascal
for LIndex := 0 to High(Orders) do
  List.AddItem(Orders[LIndex].Customer, '', -1
  , procedure (const AItem: TListViewItem)
    begin
      OpenOrder(AItem.Tag);   // the item tapped
    end
  ).Tag := LIndex;
```

The same holds for the loop variable itself. Configuration procedures are not affected: they run immediately, during the iteration, as with `AddFrame` and `AddTabFrame`.
:::

### The state of a route

Most screens work on something: an order, a customer, a form being filled. A route defined with a **state** gets its own `TComponent` (usually a `TDataModule`, designed in the IDE with its FireDAC components and LiveBindings), created with the route and freed with it. It is the FMXER counterpart of the `State` of a Flutter `StatefulWidget`, with `dispose` done by the Delphi ownership.

```pascal
type
  TOrderState = class(TDataModule)
  public
    procedure Load(const AIndex: Integer);   // the arguments of the route
    procedure Save;
    property Order: TOrder ...;
  end;

Navigator.DefineRoute<TScaffoldForm, TOrderState>('order'
, procedure (Scaffold: TScaffoldForm; State: TOrderState)
  begin
    Scaffold.SetTitle(State.Order.Customer);
    // ... the elements read and write State
  end
);
```

- The navigator creates the state with the route, **before the view**, through the virtual constructor `Create(nil)`, so a data module loads its design. The view then owns it: closing the route frees the state with the view.
- `Navigator.RouteState<TOrderState>('order')` returns the state while the route is active, `HasRouteState` tells whether there is one.
- With `AKeepAlive = True` (third parameter) the navigator owns the state instead. It survives the route and the route finds it again, with its values, when it is opened again. It is freed with the navigator.

The route gets its arguments in its state, from whoever opens it, and can give back a result:

```pascal
Navigator.RouteTo<TOrderState>('order'
, procedure (State: TOrderState)
  begin
    State.Load(LIndex);   // before the view is built
  end
, procedure (AResult: TValue)
  begin
    if AResult.IsEmpty then
      Scaffold.ShowSnackBar('Not saved', 1500)
    else
      List.RefreshList;
  end
);

// in the order route, the Save button:
State.Save;
Navigator.CloseRouteWithResult('order', State.Order.Customer);
```

See [Arguments and results](/guide/navigation#arguments-and-results) for the rules, and the [Orders demo](/demos/#orders).

::: info Since v.1.8
The state of a route, `RouteTo<TState>`, `RouteToForResult` and `CloseRouteWithResult` are new in v.1.8.
:::

### Application state in a data module

For values that outlive a screen — the user, a selection, a setting — use a data module or an object created at startup, and let routes read it **when they are built**. The LibraryStore demo stores the selected author in `RemoteData.selectedAuthorId` before routing to the books of that author:

```pascal
List.AddItem(Author.Surname + ' ' + Author.Name, '', -1
, procedure (const AItem: TListViewItem)
  begin
    RemoteData.selectedAuthorId := AItem.Tag;
    Navigator.RouteTo('books_by_author');   // reads selectedAuthorId while it builds
  end
);
```

Because a route is rebuilt each time it is opened, this is often all you need.

## Notifications across screens

When an open screen must react to a change made elsewhere, the demos use `System.Messaging`. `TAppState` in the HelloWorld demo sends a message whenever its value changes:

```pascal
type
  TSomethingChangedMsg = class(TMessage<string>);

procedure TAppState.SetSomething(const Value: string);
begin
  if FSomething <> Value then
  begin
    FSomething := Value;
    TMessageManager.DefaultManager.SendMessage(Self, TSomethingChangedMsg.Create(FSomething));
  end;
end;
```

and an element subscribes in its configuration procedure:

```pascal
TMessageManager.DefaultManager.SubscribeToMessage(TSomethingChangedMsg
, procedure (const Sender: TObject; const M: TMessage)
  begin
    QR.SetContent((M as TSomethingChangedMsg).Value);
  end
);
```

### Subscriptions and the lifetime of elements

::: danger Unsubscribe when the element goes away
A subscription lives in the global message manager, the element does not: when its route closes, the element is freed and the subscription stays. The next message runs the closure on a **freed object** (an access violation, or worse), and opening the route again adds a second subscription.
:::

Tie the subscription to the element. A tiny component owned by the element does it — when the element is freed, so is the guard, and the guard unsubscribes:

```pascal
uses System.Classes, System.Messaging;

type
  TSubscriptionGuard = class(TComponent)
  private
    FMessageClass: TClass;
    FId: Integer;
  public
    constructor Create(const AOwner: TComponent; const AMessageClass: TClass;
      const AListener: TMessageListenerMethod); reintroduce; overload;
    constructor Create(const AOwner: TComponent; const AMessageClass: TClass;
      const AListener: TMessageListener); reintroduce; overload;
    destructor Destroy; override;
  end;

constructor TSubscriptionGuard.Create(const AOwner: TComponent;
  const AMessageClass: TClass; const AListener: TMessageListener);
begin
  inherited Create(AOwner);
  FMessageClass := AMessageClass;
  FId := TMessageManager.DefaultManager.SubscribeToMessage(AMessageClass, AListener);
end;

constructor TSubscriptionGuard.Create(const AOwner: TComponent;
  const AMessageClass: TClass; const AListener: TMessageListenerMethod);
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
```

```pascal
TSubscriptionGuard.Create(QR, TSomethingChangedMsg
, procedure (const Sender: TObject; const M: TMessage)
  begin
    QR.SetContent((M as TSomethingChangedMsg).Value);
  end
);
```

The demos use this guard: HelloWorld declares it in `Data.AppState` and gives one to each QR code that follows the edit; LibraryStore wraps it in `TRetrieveMsg.Subscribe(ABF, ...)` (`Utils.Msg`), owned by the activity animation in the title detail area. Note that hiding an element (`HideTitleDetailContent`) does not free it: the subscription stays active until the route closes.

The same rule applies to anything that can call back later: timers, `TDelayedAction`, background threads, data-module listener lists (the QRCode demo clears its camera listeners in `OnCloseRoute`).

## Doing work in the background

Long operations (REST calls, database queries) should not block the UI thread while a screen is built. The LibraryStore demo runs its MARS requests asynchronously and fills the list in the callback, while the scaffold's title detail area shows an activity animation:

```pascal
List.ItemBuilderProc :=
  procedure
  begin
    RemoteData.RetrieveBooks(
      procedure (ABooks: TArray<TBook>)      // called on the UI thread
      begin
        for var LBook in ABooks do
          List.AddItem(LBook.Title, LBook.Author.Surname);
      end
    , procedure (AError: string)
      begin
        Scaffold.ShowSnackBar(AError, 3000);
      end
    );
  end;
```

When the callback can arrive after the screen was closed, check that the route is still active (`Navigator.IsRouteActive`) before touching its elements, as the Skia101 demo does for its QR code timer.
