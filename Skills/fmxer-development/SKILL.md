---
name: fmxer-development
description: Develop Delphi FireMonkey (FMX) apps with FMXER (Andrea Magni's declarative, Flutter-inspired framework built on TFrameStand/TFormStand) - screens built in code as trees of frame/form "elements", named routes with TNavigator (DefineRoute, RouteTo, CloseRoute, StackPop, transient routes, Back button), TScaffoldForm (title, content, action buttons, snackbar), containers and sizing (TColumnForm, TRowForm, TColumnFrame, TRowFrame, TStackFrame, TVertScrollFrame, TAccessoryFrame, THorzPairFrame, TCenterForm, TCardFrame...), elements with fluent setters (TTextFrame, TButtonFrame, TEditFrame, TListViewFrame, TQRCodeFrame, icons...), TAppColors, state shared through closures, message subscriptions and the lifetime of elements, Delphi 12+ Skia units. Use this skill whenever the user works in a Delphi project that uses FMXER (units FMXER.*, Navigator(FormStand1), DefineRoute<TScaffoldForm>, SetContentAsFrame<T>, AddFrame<T>), asks how to add a screen or route, lay out elements, pass data between screens, handle the Back button, or write a new FMXER element - even if they don't name FMXER but the code clearly uses it.
---

# Developing with FMXER

FMXER (https://github.com/andrea-magni/FMXER, docs https://andrea-magni.github.io/FMXER/, whole docs for agents: https://andrea-magni.github.io/FMXER/llms-full.txt) builds FMX screens **in code**, Flutter-style: a screen is a tree of **elements** (frames and forms), each created by its container and configured by an anonymous method. Every container shows its children through its own `TFrameStand`/`TFormStand` (https://andrea-magni.github.io/TFrameStand/). Requirements since v.1.2: **Delphi 12 or 13** (Skia built into RAD Studio), FireMonkey only; source library, no packages (add `source\` and the dependencies to the search path).

## Mental model

- **Element**: a `TFrame` or `TForm` descendant with a small fluent API (`Set*` methods returning the element). Built-in ones live in `source\FMXER.*.pas`.
- **Container**: an element with **slots**; each slot has a generic pair `...AsFrame<T: TFrame>` / `...AsForm<T: TForm>` (or `AddFrame<T>` / `AddForm<T>`) that creates a `T` in the slot (inside the slot's stand), calls your **configuration procedure** `TProc<T>` with it, shows it, and keeps its `TSubjectInfo`.
- **Route**: a named screen defined once with `Navigator.DefineRoute<TScaffoldForm>('home', procedure (Home: TScaffoldForm) ...)`, built when `RouteTo` opens it, freed (with its whole tree) by `CloseRoute`/`StackPop`. The next `RouteTo` rebuilds it from the definition.
- **Navigator**: singleton bound to one `TFormStand` on the main form: `Navigator(FormStand1)` once, then `Navigator` anywhere.

```pascal
// main form: the only design-time component is FormStand1: TFormStand
uses FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts,
  FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.TextFrame, FMXER.ButtonFrame;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1);                              // first: initializes the singleton
  Navigator.DefineRoute<TScaffoldForm>('home'
  , procedure (Home: TScaffoldForm)
    begin
      Home
      .SetTitle('Home')
      .SetContentAsForm<TColumnForm>(
        procedure (Col: TColumnForm)
        begin
          Col
          .AddFrame<TTextFrame>(50
          , procedure (Text: TTextFrame)
            begin
              Text.SetContent('Hello').SetFontColor(TAlphaColorRec.Black);  // default text is white
            end)
          .AddFrame<TButtonFrame>(60
          , procedure (Button: TButtonFrame)
            begin
              Button.SetText('Details').SetOnClickProc(
                procedure begin Navigator.RouteTo('detail'); end);
            end);
        end)
      .AddActionButton('X', procedure begin Navigator.CloseRoute('home'); end);
    end);
  Navigator.SetOnCloseRoute(
    procedure (ARouteName: string) begin if ARouteName = 'home' then Close; end);
  Navigator.RouteTo('home');
end;
```

The project source sets `GlobalUseSkia := True;` before `Application.Initialize` (uses `FMX.Skia`).

## Choosing the API

| The user wants | Use |
|---|---|
| a new screen | `Navigator.DefineRoute<TScaffoldForm>(AName, AConfigProc)` (or any `TForm`); a frame or another stand: `DefineRoute(AName, function: TSubjectInfo ...)` |
| open / go back / close | `RouteTo(AName)`, `StackPop`, `CloseRoute(AName)`, `CloseAllRoutes`, `CloseAllRoutesExcept(AName)` |
| overlay not in Back history (wait screen, splash) | `RouteTo(AName, True)` (transient), `CloseRouteDelayed(AName, True, 3000)` |
| pass data to a screen | set a field/data module value, then `RouteTo`: the definition reads it while it builds (routes have no parameters) |
| title bar, floating buttons, short messages | `TScaffoldForm`: `SetTitle`, `SetContentAs*`, `AddActionButton`, `ShowSnackBar(AText, ADuration_ms[, AThen])`, `SetTitleDetailContentAs*` |
| elements one under another | `TColumnForm.AddFrame<T>(AHeight, ...)` (default 200; `TColumnForm.AUTO_HEIGHT` = the element's own height) |
| scrolling column | `TVertScrollFrame.SetContentAsForm<TColumnForm>` (or `SetContentAsFrame<TColumnFrame>`) |
| many rows / columns, long columns | `TRowFrame`/`TColumnFrame` (frames: ~10x cheaper than the forms) and `Col.BatchUpdate(procedure (C) ...)` to add them (v.1.4); hundreds of uniform rows: `TListViewFrame` |
| side by side | `TRowForm.AddFrame<T>(AWidth, ...)` inside a column slot, `THorzPairFrame` (two halves), `TAccessoryFrame` (fixed left/right + content) |
| layers (background + content) | `TStackFrame.AddFrame<T>(AConfigProc, AName)` (frames only; later = on top) |
| fixed-size centered element | `TCenterForm.SetContentAsFrame<T>(AWidth, AHeight, ...)` |
| long / data-driven list | `TListViewFrame` (`AddItem(..., AOnSelect)`, `ItemBuilderProc`), not a column |
| any FMX control as an element | `TContainerFrame.SetContentAs<TSwitch>(...)` |
| icons | `IconFonts.MD.<name>` (`FMXER.IconFontsData`), `TIconFontsGlyphFrame.SetIcon(AIcon, AColor)`, `AddActionButton(AIcon, AColor, AProc)` |
| app colors | `TAppColors.PrimaryColor` / `PrimaryTextColor`... set in `FormCreate` before the first route |
| margins, paddings, align, size | `FMXER.UI.Misc` helpers: `SetMargin`, `SetPadding`, `SetAlign*`, `SetWidth`, `SetHeight`, `SetHitTest` |
| a reusable element of your own | a frame with `Align = Client`, `Set*` methods returning `Self`, `TProc` events (see `references/custom-elements.md`) |

## Rules that avoid the common bugs

- **Initialize the navigator first**: `Navigator(FormStand1)` before any `DefineRoute`/`RouteTo`, or *Navigator has not been initialized*. Route names are case-sensitive and defined once (keep them in constants); unknown names raise *Route definition not found*.
- **`TTextFrame` text is white** (`TAppColors.PrimaryTextColor`, meant for text on the primary color). On a light background call `SetFontColor(TAlphaColorRec.Black)` (or your color), or the text is invisible.
- **Sizes are top-down**: every `AddFrame`/`AddForm` of a column/row gets the height/width you pass (200 if omitted), or with `TColumnForm.AUTO_HEIGHT` / `TRowForm.AUTO_WIDTH` (v.1.3+) the element's own size (design size, or the one set in the configuration procedure); the column's `Height` grows by it. Columns do not scroll: wrap long ones in `TVertScrollFrame`. Sizes are computed once (use `Col.Width`, `Scaffold.Width` at build time; rebuild the route or use `TVertScrollFrame.OnResizedProc` to react to resizes).
- **The `TControl` helpers return `TControl`**: after `.SetMargin(5)` the element's own setters are gone. Use the generic overload (`.SetMargin<TButtonFrame>(5).SetText('OK')`) or call the helpers last. Since v.1.3 every slot method returns its container and every clickable element has `SetOnClickProc` (on v.1.2 some slot methods were procedures: see `references/api.md`).
- **Closures that outlive their element crash**: a `TMessageManager` subscription, a timer, `TDelayedAction`, a background callback or a data-module listener that references elements runs on freed objects after the route closes (and re-subscribes each time the route opens). Tie it to the element (a `TComponent` guard owned by the element that unsubscribes in its destructor), clear it in `Navigator.OnCloseRoute`, or check `Navigator.IsRouteActive(AName)` before touching elements. See `references/state.md`.
- **Loop variables in closures**: configuration procedures run at once (safe), click handlers run later and see the last value: copy the variable into a local declared inside the loop.
- **Configuration procedures run once**, when the element is created. To change an element later keep a reference (captured variable) or rebuild the route. Changing `TAppColors` affects only elements created afterwards.
- **Never free elements or routes by hand**: containers own their children; close the route (or `TStackFrame.CloseFrame(AName)`). Close routes first in `FormClose` (`Action := caNone; Navigator.CloseAllRoutes`) and let the home route's `OnCloseRoute` close the form.
- **Back button**: v.1.4+ `Navigator(FormStand1).SetCatchBackKey(True)` (Back/Esc pop the top route, root left to the form, transient routes consume the key); don't also keep a handler that calls `StackPop`. Older versions: in `OnKeyUp`, `if (Key = vkHardwareBack) and (Navigator.Stack.Count > 1) then begin Key := 0; Navigator.StackPop; end;`. Close-then-route in the same handler is fine (`CloseRoute` hides first, frees afterwards); use `RouteToDelayed` to wait for the hide animation.
- **Set stand properties before the slot call** that uses them (`Row.ElementStand := 'fadeIn'; Row.AddFrame<...>`). Unknown stand names give a plain layout, no error.
- **Delphi 12+ Skia units**: `System.Skia`, `FMX.Skia`, `FMX.Skia.Canvas` (never `Skia`, `Skia.FMX`, `Skia.FMX.Graphics` of the old Skia4Delphi: `F2613 Unit 'Skia.FMX' not found`). `TSkTextHorzAlign`, `TSkAnimatedImageWrapMode`, `TSkSvgWrapMode` come from `FMX.Skia`, `ISkCanvas` from `System.Skia`.
- **`AddActionButton(ACaption, [OnClickProc(...)])`**: pass a `TProc` variable to `OnClickProc`; an inline anonymous method there fails on Delphi 13 (E2250) unless qualified `FMXER.UI.Misc.OnClickProc(...)`. Simpler: `AddActionButton(ACaption, AOnClickProc)`.
- **Icons need the font**: *Material Design Icons Desktop* (`media\`) installed on Windows, deployed on the other platforms (Android: `.\assets\internal`), or glyphs are squares.
- Follow the style of the existing project: one `Routes.<name>.pas` unit per route with a `DefineXxxRoute(const ARouteName: string)` procedure (NewProjectTemplate demo), commas at the start of argument lines, fluent chains one call per line.

## References

Read the reference matching the task:

- `references/api.md` — exact declarations from `source\` (navigator, containers, elements, helpers, `TAppColors`, icons) and which unit declares what: read it before calling a method you are not sure about.
- `references/navigation.md` — routes, `RouteTo`/`CloseRoute`/`StackPop`, transient routes, the stack, Back button, `OnCreateRoute`/`OnCloseRoute`, closing the app, passing data.
- `references/layouts.md` — containers, slots and stands, sizing rules, columns/rows/stacks/scroll/pair/accessory/center/card, scaffold, lists, styling with `TAppColors` and stands.
- `references/state.md` — closures, sharing values between elements, data modules, `System.Messaging` with a subscription guard, background work, lifetime rules.
- `references/custom-elements.md` — writing your own elements and containers, `[SubjectInfo]`/`[Show]`/`[Hide]` injection, conventions, project setup (search path, Skia, icon font deployment).
