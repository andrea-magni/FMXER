# Tabs & Navigation Bar

`TTabsFrame` (unit `FMXER.TabsFrame`) switches between pages of elements with a bar of tabs. With the bar on top it is a tab bar, the counterpart of the Flutter `TabBar` + `TabBarView`. With the bar at the bottom it is a navigation bar, the counterpart of the Flutter `NavigationBar` (`BottomNavigationBar`), and [`TScaffoldForm.SetBottomNavigation`](./scaffold#bottom-navigation) uses it that way.

| Tab bar (`Top`) | Navigation bar (`Bottom`) |
|---|---|
| ![A tab bar](/navigation-tabs.png) | ![A navigation bar](/navigation-demo.png) |

Each tab has a page: an element created through the frame's own `FrameStand1`/`FormStand1` when the tab is added, in a slot (`TSubjectInfoContainer`) that fills the page area. Every page is created when its tab is added. Only the selected page is visible, and the others keep their state while hidden. The first tab added is selected.

::: info Since v.1.7
`TTabsFrame`, the drawer and the bottom navigation of the scaffold are new in v.1.7.
:::

## Tabs

```pascal
Scaffold.SetContentAsFrame<TTabsFrame>(
  procedure (Tabs: TTabsFrame)
  begin
    Tabs
    .AddTabFrame<TListViewFrame>('Inbox'
    , procedure (List: TListViewFrame)
      begin
        // ...
      end
    )
    .AddTabFrame<TListViewFrame>('Sent')
    .AddTabForm<TColumnForm>('Drafts'
    , procedure (Col: TColumnForm)
      begin
        // ...
      end
    )
    .SetOnChangeProc(
      procedure (AIndex: Integer)
      begin
        Scaffold.SetTitle(Tabs.Tabs[AIndex].TextLabel.Text);
      end
    );
  end
);
```

The tabs share the width of the bar. The selected one has the `SelectedTextColor` and, with the bar on top, a 3-pixel indicator that slides under it.

## Navigation bar

```pascal
Tabs
.SetBarPosition(TTabBarPosition.Bottom)        // first: it resets colors and font size
.AddTabFrame<TColumnFrame>('Home', IconFonts.MD.home, DefineHome)
.AddTabFrame<TColumnFrame>('Search', IconFonts.MD.magnify, DefineSearch)
.AddTabFrame<TColumnFrame>('Settings', IconFonts.MD.cog, DefineSettings);
```

With an icon (any `TIconEntry` of [the icon font](./icons)) the tab shows it above its text, in the color of the text. The icon font draws the color into the image, so each icon has two images: one in `TextColor` and one in `SelectedTextColor`. Without the font, the icons are empty boxes: see [The icon font](/guide/installation#the-icon-font).

`DefineHome` and the others are `TProc<TColumnFrame>` variables or functions that return one. A procedure that matches the type works as well.

## Members

| Member | Description |
|---|---|
| `AddTabFrame<T>(ACaption[, AIcon: TIconEntry][, AConfigProc: TProc<T>])` | adds a tab with a frame element as page |
| `AddTabForm<T>(ACaption[, AIcon][, AConfigProc])` | the same with a form element (a column, a scroll box...) |
| `SetTabIndex(AIndex)` / `GetTabIndex` | the selected tab; `SetTabIndex` does not call `OnChangeProc`, an index out of range raises `EArgumentOutOfRangeException` |
| `GetTabCount` | |
| `SetOnChangeProc(TProc<Integer>)` / `OnChangeProc` | the tab tapped by the user (not called for a tap on the selected tab) |
| `SetBarPosition(TTabBarPosition)` / `GetBarPosition` | `Top` (default): bar in `TAppColors.PrimaryColor`, text in `PrimaryTextColor` (the other tabs a bit transparent), indicator, font size 15. `Bottom`: white bar, the selected tab in `PrimaryColor`, the others gray, no indicator, font size 12. Resets the colors and the font size |
| `SetBarHeight(AHeight)` / `GetBarHeight` | default 56 |
| `SetBarColor`, `SetTextColor`, `SetSelectedTextColor`, `SetIndicatorColor` (and getters) | colors; the icons follow the text colors |
| `SetFontSize(ASize)` / `GetFontSize` | the text of the tabs |
| `SetPageStand(AStand)` | stand of the pages added after it (default: none) |
| `Tabs[AIndex]: TTabItem` | a tab: `Button` (`TLayout`), `TextLabel` (`TSkLabel`), `Glyph` (`TGlyph`, `nil` without an icon), `Page` (`TSubjectInfoContainer`: `Page.ContainedFrame<T>`, `Page.ContainedForm<T>`) |
| `BarLayout`, `BarBackground`, `ButtonsLayout`, `Indicator`, `PagesLayout` | the controls |

::: tip A page with tabs of its own
A page can be a `TTabsFrame` too: the [Navigation demo](/demos/#navigation) has a page of the navigation bar with a tab bar on top.
:::
