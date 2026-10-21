# Scaffold

`TScaffoldForm` (unit `FMXER.ScaffoldForm`) is the screen skeleton of most FMXER apps, after Flutter's `Scaffold` and Material Design: a title bar, a content area, floating action buttons at the bottom right and a snackbar for short messages. Optionally, a [drawer](#drawer) that slides in from the left and a [bottom navigation](#bottom-navigation) bar.

```text
┌──────────────────────────────┐
│ Title               [detail] │ ← TitleLayout (64 px, PrimaryColor, shadow)
├──────────────────────────────┤
│                              │
│           content            │ ← ContentLayout (client)
│                              │
│                   ( + ) ( X )│ ← ActionButtonsLayout (50 px, bottom)
│ ▓▓▓▓ snackbar text ▓▓▓▓▓▓▓▓▓ │ ← OverlayLayout ('snackbar' stand)
└──────────────────────────────┘
```

## Title

```pascal
Scaffold.SetTitle('Library Store');
```

`SetTitle` sets the text of `TitleLabel` (a `TSkLabel`, 24 pt, `PrimaryTextColor`) and can be called at any time — the LibraryStore demo updates the title with the number of books found once the data arrives.

### Title detail

The title bar has a second slot, `TitleDetailLayout`, laid over the whole bar: put an element there and align it where you want it. The LibraryStore demo shows an activity animation on the right while it loads data:

```pascal
Scaffold.SetTitleDetailContentAsFrame<TBackgroundFrame>(
  procedure (Back: TBackgroundFrame)
  begin
    Back
    .SetContentAsFrame<TActivityBubblesFrame>()
    .SetFillColor(TAlphaColorRec.White)
    .SetMargin(5, 2, 5, 2)
    .SetAlignRight
    .SetWidth(64);
  end
);

// later
Scaffold.HideTitleDetailContent;   // with an optional delay and a callback
Scaffold.ShowTitleDetailContent;
```

`TitleDetailContent` returns the element, `TitleDetailContentVisible` tells whether it is shown. The HelloWorld demo puts a small QR code there.

## Content

```pascal
Scaffold.SetContentAsFrame<TListViewFrame>(
  procedure (List: TListViewFrame)
  begin
    // ...
  end
);
```

`SetContentAsFrame<T>` / `SetContentAsForm<T>` fill `ContentLayout`; `Content` returns the element. The content can be anything — usually a list, a column in a scroll box, or a stack of layers.

## Action buttons

Floating round buttons, added from right to left in `ActionButtonsLayout`, each one a `TActionButtonFrame` (a circle in `PrimaryColor` with an element on top):

| Overload | Button shows |
|---|---|
| `AddActionButton(ACaption, AOnClickProc)` | a text (`TTextFrame`) |
| `AddActionButton(ACaption, AParams)` | a text; the click handler is the `OnClickProc` param |
| `AddActionButton(AImageList, AImageIndex, AOnClickProc)` | an image of an image list (`TGlyphFrame`) |
| `AddActionButton(AIcon, AColor, AOnClickProc)` | a Material Design icon in `AColor` |
| `AddActionButtonOverlayFrame<T>(AConfigProc, AOnClickProc)` | any frame element |
| `AddActionButtonOverlayForm<T>(AConfigProc, AOnClickProc)` | any form element |

```pascal
uses FMXER.IconFontsData, FMXER.UI.Consts;

Scaffold
.AddActionButton(IconFonts.MD.close, TAppColors.PrimaryTextColor
, procedure
  begin
    Navigator.CloseRoute('home');
  end
)
.AddActionButton('?'
, procedure
  begin
    Scaffold.ShowSnackBar('Tap X to close', 2000);
  end
);
```

`ActionButtonStand` names the stand used for the buttons (none by default). Without an `OnClickProc` param, `AddActionButton(ACaption, AParams)` adds a button with no click handler (v.1.1 raised `EInvalidCast`).

### TActionButtonFrame

The button element can also be used on its own:

| Member | Description |
|---|---|
| `SetOverlayAsFrame<T>(AConfigProc)`, `SetOverlayAsForm<T>(AConfigProc)` | the element drawn on the circle (scaled into the inner 80%) |
| `SetOverlayAsText(AText, AOnClickProc, AConfigProc)` | shortcut: a `TTextFrame` with `AText` |
| `OnClickProc: TProc` / `SetOnClickProc(TProc)` | click handler |
| `OverlayStand` | stand of the overlay element |
| `BackgroundCircle` | the circle (its `Fill.Color` is `PrimaryColor` at creation) |

## Snackbar

```pascal
Scaffold.ShowSnackBar('Saved', 3000);

Scaffold.ShowSnackBar('Saved', 3000
, procedure
  begin
    Navigator.CloseRoute('edit');   // after the snackbar is gone
  end
);
```

`ShowSnackBar(AText, ADuration_ms, AThen)` shows a `TTextFrame` in the `snackbar` stand — a translucent black band that springs up from the bottom — hides it after `ADuration_ms` and then calls `AThen`. Several snackbars can be on screen at once. If the route of the scaffold is closed before, the snackbar goes with it and `AThen` is not called.

## Drawer

A panel that slides in from the left over the whole screen, after the Flutter `Drawer`. A menu button (three lines, drawn without the icon font) appears on the left of the title and opens it. A tap on the dimmed screen beside it closes it, and so do Back and Esc.

![The drawer of the Navigation demo](/navigation-drawer.png)

```pascal
Scaffold
.SetTitle('Mail')
.SetDrawerAsFrame<TColumnFrame>(
  procedure (Menu: TColumnFrame)
  begin
    Menu
    .AddFrame<TTextFrame>(50
    , procedure (Item: TTextFrame)
      begin
        Item
        .SetContent('Settings')
        .SetFontColor(TAlphaColorRec.Dimgray)
        .SetOnClickProc(
          procedure
          begin
            Scaffold.CloseDrawer;
            Navigator.RouteTo('settings');
          end
        );
      end
    );
  end
, 300);   // width, default 280
```

| Member | Description |
|---|---|
| `SetDrawerAsFrame<T>(AConfigProc = nil; AWidth = 280)`, `SetDrawerAsForm<T>(...)` | the content of the drawer (once per scaffold: a second call raises) |
| `OpenDrawer`, `CloseDrawer: TScaffoldForm` | animated (0.25 s) |
| `DrawerOpen: Boolean` / `GetDrawerOpen` | |
| `Drawer: TSubjectInfo` | the element in the drawer |
| `DrawerPanel: TRectangle`, `MenuButton: TLayout` | the controls: white panel, its `Fill.Color` to change it |

Back and Esc close the open drawer before any route: while the drawer is open, the scaffold registers a [back handler](/guide/navigation#back-handlers) with the navigator (the singleton). Close the drawer yourself when one of its items opens a route or changes the page.

::: tip Text in the drawer
`TTextFrame` writes in `TAppColors.PrimaryTextColor` (white by default): on the white drawer, set a dark `SetFontColor`.
:::

## Bottom navigation

```pascal
Scaffold
.SetTitle('Shop')
.SetBottomNavigation(
  procedure (Tabs: TTabsFrame)
  begin
    Tabs
    .AddTabFrame<TColumnFrame>('Home', IconFonts.MD.home, DefineHome)
    .AddTabFrame<TListViewFrame>('Orders', IconFonts.MD.cart, DefineOrders)
    .AddTabFrame<TColumnFrame>('Settings', IconFonts.MD.cog, DefineSettings);
  end
);
```

`SetBottomNavigation(AConfigProc: TProc<TTabsFrame>)` sets as content a [`TTabsFrame`](./tabs) with its bar at the bottom (white, the selected tab in `PrimaryColor`), and moves the action buttons and the snackbar above the bar. `BottomNavigation: TTabsFrame` is the element, for example to change the page from the drawer: `Scaffold.BottomNavigation.SetTabIndex(2)`. It replaces `SetContentAs*`: use one or the other.

## Stands

| Property | Used by |
|---|---|
| `ContentStand` | `SetContentAs*` |
| `TitleDetailStand` | `SetTitleDetailContentAs*` |
| `ActionButtonStand` | `AddActionButton*` |

The scaffold's own style book (`Stands`) contains the `snackbar` stand. See [Styling](/guide/styling#stands).

## Members

| Member | Description |
|---|---|
| `SetTitle(ATitle): TScaffoldForm` | title text |
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | content |
| `SetTitleDetailContentAsFrame<T>(AConfigProc)`, `SetTitleDetailContentAsForm<T>(AConfigProc)` | title detail element |
| `ShowTitleDetailContent`, `HideTitleDetailContent(ADelay = 0; AThen = nil)` | show/hide the title detail element |
| `AddActionButton(...)`, `AddActionButtonOverlayFrame<T>`, `AddActionButtonOverlayForm<T>` | action buttons (see above) |
| `ShowSnackBar(AText, ADuration_ms[, AThen])` | snackbar |
| `SetDrawerAsFrame<T>`, `SetDrawerAsForm<T>`, `OpenDrawer`, `CloseDrawer`, `DrawerOpen`, `Drawer`, `DrawerPanel`, `MenuButton` | [drawer](#drawer) |
| `SetBottomNavigation(TProc<TTabsFrame>)`, `BottomNavigation: TTabsFrame` | [bottom navigation](#bottom-navigation) |
| `Content`, `TitleDetailContent: TSubject` | the elements |
| `TitleDetailContentVisible: Boolean` | |
| `ContentStand`, `TitleDetailStand`, `ActionButtonStand: string` | stand names |
| `TitleLayout`, `TitleBackground`, `TitleLabel`, `ContentLayout`, `OverlayLayout`, `ActionButtonsLayout` | the controls, for fine tuning |
