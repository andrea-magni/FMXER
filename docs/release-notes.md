# Release Notes

Releases are published on [GitHub](https://github.com/andrea-magni/FMXER/releases).

## v.1.3 — 2026-10-16

**Automatic sizes** (ANALYSIS D1):

- `TColumnForm.AddFrame<T>(TColumnForm.AUTO_HEIGHT)` and `TRowForm.AddFrame<T>(TRowForm.AUTO_WIDTH)` (and `AddForm<T>`): the slot takes the element's own size, the one in its `.fmx` or the one set by the configuration procedure. See [Automatic sizes](/guide/layouts#automatic-sizes).
- `TVertScrollFrame`, `TVertScrollForm`, `THorzScrollFrame`: a frame content keeps its design size (it got 50 pixels: TFrameStand aligns the frame to its stand before the configuration procedure runs), and `ContentStand` is used (it was ignored).
- `TFMXERStands.NewSizedFrame<T>` to do the same in your own containers.

**Uniform fluent API** (ANALYSIS D2), all additions, existing code compiles unchanged:

- every slot method returns its container (`TContainerForm`, `TVertScrollForm`, `THorzScrollFrame`, `TCardFrame`, `TActionButtonFrame` had procedures);
- `SetOnClickProc` on every clickable element; `SetOnTapHandler` on the image elements;
- setters for the properties: `TCardFrame.SetTitle`, `TWebViewFrame.SetURL`/`SetHTML`, `TLogoFrame.SetLogoResource`, `TActivityBubblesFrame.SetText`, `TVertScrollForm.SetTouchWidth`, `THorzScrollFrame.SetTouchHeight`, `SetContentStand` on the single-slot containers, `SetElementStand` and `TRowForm.SetElementAlign`.

36 tests.

## v.1.2.1 — 2026-10-16

- `TOnTapHandler` is declared once, in the new unit `FMXER.UI.Types`: `TImageFrame`, `TSVGFrame`, `TAnimatedImageFrame` and `TQRCodeFrame` share it (each unit keeps an alias), so one handler variable fits them all. `TPaintBoxFrame` uses `TPaintBoxTapHandler` (its `TOnTapHandler` is deprecated).
- `SvgToBitmap`: the same 10-pixel margin on every side and the size asked (the code was 20 pixels smaller, off-center).
- `LocalFile` takes its folder from the new `LocalFilesPath` variable (same defaults).
- `TColumnForm`, `TRowForm`: their form elements are closed with them, like the frame elements.
- Documentation workflow on Node 24 actions.

Tests for each change (26 tests).

## v.1.2 — 2026-10-16

**Breaking change**: FMXER requires **Delphi 12 or later** and uses the Skia built into RAD Studio: the units are `System.Skia`, `FMX.Skia` and `FMX.Skia.Canvas` instead of Skia4Delphi's `Skia`, `Skia.FMX` and `Skia.FMX.Graphics` (replace them in your `uses` clauses; the `.fmx` files do not change). On Delphi 11 use v.1.1.

Fixes, each with a test in the new DUnitX suite (`tests\`, run by `build.cmd`):

- `TNavigator.CloseRoute` removes the closed route from the stack, wherever it is (it popped the top of the stack); the navigator remembers transient routes, so `CloseRoute` no longer needs `ATransient` and `CloseAllRoutes`/`CloseAllRoutesExcept` no longer raise `EListError` with a transient route open.
- `TScaffoldForm.AddActionButton(ACaption, AParams)` without an `OnClickProc` param no longer raises `EInvalidCast`; `ShowSnackBar` frees the snackbar after hiding it.
- `TListViewFrame`: pull-to-refresh and `RefreshList` no longer duplicate the items; click handlers are stored in the items (no stale handlers after `ClearItems` or swipe-to-delete). Setting `ItemBuilderProc` now clears the list before running the builder.
- `TIconFonts.AddIcon` returns the existing image for an icon and color already added, instead of adding a new one at every call.
- `THorzPairFrame.SetLeftContentStand`/`SetRightContentStand` store the stand name; `TCardFrame.SetGlyphAsForm` keeps the glyph info; `TFMXERFormHelper.SetPadding<T>` works (constraint `TCommonCustomForm`).
- `lib/TFrameStand` submodule updated to TFrameStand v.2.3 (FMXER still compiles with v.1.6).
- `build.cmd`: builds the source, the tests and the demos; documentation site (this one).
- Demos: MyTicketing and EKON25 - Weather ported to the fluent API (all 13 demos compile); HelloWorld and LibraryStore remove their message subscriptions when their elements are freed; HelloWorld_IFIL uses the icon table of `source`; the QRCode demo frees its share stream.
- AI agent skill `fmxer-development` in `Skills/`; the repository is a Claude plugin marketplace (see [AI Agent Skill](/guide/agent-skills)).

Also in this release, from the work on master after v.1.1 (up to February 2023):

- New elements: `TAccessoryFrame` (content with left/right accessories), `THorzPairFrame` (50/50 pair), `TTrackbarFrame`, `TColorPickerFrame`, `TColorButtonFrame`.
- `TIconFontsGlyphFrame` and `TGlyphFrame` upgraded (fluent setters, `SetIcon` overloads); IconFontsImageList as a submodule.
- `TListViewFrame`: search box (`SearchVisible`, `SearchText`, `SetOnSearchChange`).
- `TEditFrame` and `TTextFrame` upgraded; `SetWidth`/`SetHeight` helpers for forms; fluent ("chaining") setters across the elements.
- New demos: **QRCode** (generator and camera reader with ZXing.Delphi), **NewProjectTemplate** (also for the iOS simulator on Apple silicon), **WebView**; HelloWorld with an animated background and a QR code.

## v.1.1 — 2022-11-03

**Breaking changes**: FMXER now depends on [Skia4Delphi](https://github.com/skia4delphi/skia4delphi) (4.0). Many changes in the framework: porting from v.1.0 may need some work.

- Skia-based elements and the **Skia101** demo; support for Skia4Delphi 4.0.0.
- Transient routes (`RouteTo(AName, True)`): routes that do not go on the stack.
- New elements: `TWebViewFrame`, `TActivityBubblesFrame`, `TMarginFrame`, `TPaddingFrame`, `TVertScrollForm`; **MarginAndPadding** demo.
- `TListViewFrame`: click handlers per item, `ItemAppearance`, `SelectedItem`, `AccessoryVisible`, `SearchVisible`.
- `TEditFrame.FocusOnShow`, `TLogoFrame.LogoResource`, fixes to `TVertScrollFrame` and `TCardFrame`.
- **LibraryStore** demo (MARS REST client) and **EKON25 - Weather** demo; projects upgraded to Delphi 11.1 Alexandria.

## v.1.0 — 2021-11-11

Initial release of the FMXER framework: `TNavigator`, scaffold, columns, rows, scroll boxes, cards and the first elements, built on TFrameStand, with Material Design icons through IconFontsImageList. FMXER was first shown at EKON 23 and [CodeRage 2019](https://youtu.be/RiK2re19Kyk) (October/November 2019).
