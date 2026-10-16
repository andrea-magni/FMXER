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
