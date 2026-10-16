# State, events and the lifetime of elements

Docs: https://andrea-magni.github.io/FMXER/guide/state, /guide/core-concepts

FMXER has no state library: elements are created by closures, and closures are where state lives.

## Element events are closures

| Element | Event |
|---|---|
| `TButtonFrame` | `SetOnClickProc(TProc)` (also `SetOnClickHandler`, `OnClickHandler`), `OnUpdateHandler: TProc<TAction>` |
| `TEditFrame` | `OnChangeProc: TProc<Boolean>` (`True` while typing, `False` on change) — property only, no setter |
| `TTrackbarFrame` | `OnChangeProc: TProc<Single>` (`SetOnChangeProc`) |
| `TColorPickerFrame` | `OnChangeProc: TProc<TAlphaColor>` |
| `TTextFrame` | `SetOnClickProc(TProc)` (also `SetOnClick`) |
| `TGlyphFrame`, `TIconFontsGlyphFrame` | `SetOnClickProc(TProc)` |
| `TChipFrame` | `SetOnClickProc(TProc)` (also `OnClickHandler`) |
| `TActionButtonFrame` | `SetOnClickProc(TProc)` (also `OnClickProc`) |
| `TImageFrame`, `TSVGFrame`, `TAnimatedImageFrame`, `TQRCodeFrame` | `OnTapHandler` (tap on mobile, mouse up on Windows) |
| `TPaintBoxFrame` | `SetOnDrawHandler`, `SetOnTapHandler` |
| `TListViewFrame` | per item `AOnSelect` of `AddItem`, `SetOnSearchChange` |
| `TActionButtonFrame` | `OnClickProc: TProc` |

A property assignment ends a fluent chain: `Edit.SetCaption('Name').OnChangeProc := procedure (ATracking: Boolean) begin ... end;`.

## Sharing values between elements

Captured local variable, safe when both elements belong to the same screen (freed together):

```pascal
var LEditFrame: TEditFrame := nil;
Col
.AddFrame<TEditFrame>(100
, procedure (Frame: TEditFrame)
  begin
    Frame.SetCaption('Name');
    LEditFrame := Frame;                  // keep it for later
  end)
.AddFrame<TButtonFrame>(60
, procedure (Button: TButtonFrame)
  begin
    Button.SetText('Greet').SetOnClickProc(
      procedure
      begin
        ShowMessage('Hello, ' + LEditFrame.GetText);
      end);
  end);
```

Values that outlive a screen (user, selection, settings) go in a data module or an object created at startup; routes read them **when they are built** (routes are rebuilt at each opening).

## Configuration procedures run once

They run inside the slot call, when the element is created. To change an element later, keep a reference or rebuild the route. Loop variables: a configuration procedure in a loop sees the right value (it runs at once); a click handler created in a loop runs later and sees the last value — copy the variable into a local declared inside the loop body (`var LIndex := I;`) or build the handler in a separate function.

## Notifications across screens: System.Messaging

```pascal
type
  TSomethingChangedMsg = class(TMessage<string>);

TMessageManager.DefaultManager.SendMessage(Self, TSomethingChangedMsg.Create(FSomething));
```

**A subscription outlives its element**: the message manager is global, the element is freed when its route closes, the next message runs the closure on a freed object (access violation), and reopening the route subscribes again. Tie the subscription to the element with a guard component it owns:

```pascal
uses System.Classes, System.Messaging;

type
  TSubscriptionGuard = class(TComponent)
  private
    FMessageClass: TClass;
    FId: Integer;
  public
    constructor Create(const AOwner: TComponent; const AMessageClass: TClass;
      const AListener: TMessageListener); reintroduce;
    destructor Destroy; override;
  end;

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

// in the configuration procedure of the element
TSubscriptionGuard.Create(QR, TSomethingChangedMsg
, procedure (const Sender: TObject; const M: TMessage)
  begin
    QR.SetContent((M as TSomethingChangedMsg).Value);
  end);
```

The HelloWorld and LibraryStore demos subscribe without unsubscribing: do not copy that.

## Anything that calls back later

Timers, `TDelayedAction`, `TTask`/threads, REST callbacks, listener lists in data modules: if they can fire after the route closed, either

- own/stop them with the element (a component owned by the element, like the guard above; a `TTimer` created with the element as owner);
- clear them in `Navigator.OnCloseRoute` (the QRCode demo stops the camera and clears its listeners there);
- or check `Navigator.IsRouteActive('route')` before touching elements (Skia101 demo, QR code timer).

## Background work

Do not block the UI thread while a screen is built: start the request in the configuration procedure (or in `TListViewFrame.ItemBuilderProc`) and fill the elements in a callback **on the main thread** (`TThread.Queue`/`Synchronize`, or a library that calls back on the UI thread). Show progress in the scaffold title detail area (`SetTitleDetailContentAsFrame<TActivityBubblesFrame>`, then `HideTitleDetailContent`) and errors with `ShowSnackBar`.

```pascal
List.ItemBuilderProc :=
  procedure
  begin
    RemoteData.RetrieveBooks(
      procedure (ABooks: TArray<TBook>)         // called on the UI thread
      begin
        if not Navigator.IsRouteActive('books') then Exit;
        for var LBook in ABooks do
          List.AddItem(LBook.Title, LBook.Author.Surname);
        Scaffold.SetTitle(Length(ABooks).ToString + ' books');
      end
    , procedure (AError: string)
      begin
        Scaffold.ShowSnackBar(AError, 3000);
      end);
  end;
```

## Ownership summary

| Object | Created by | Freed when |
|---|---|---|
| a route's screen | the navigator's `TFormStand`, at `RouteTo` | the route is closed (`CloseRoute`, `StackPop`, `CloseAllRoutes`) |
| an element in a slot | its container's `TFrameStand`/`TFormStand` | its container is freed (or its info closed: `TStackFrame.CloseFrame`) |
| `IconFonts`, `Navigator` | lazily, on first use | application shutdown |

Never free elements by hand.
