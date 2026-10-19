# Release Notes

Releases are published on [GitHub](https://github.com/andrea-magni/FMXER/releases).

## v.1.6 — 2026-10-19

**Safe area (Android 15+ edge-to-edge, iOS notch)**: the routes no longer go under the status bar and the navigation bar. The navigator shows them in a layout of the form that gets the safe area insets as margins (`TNavigator.SafeArea`, on by default; `SetSafeArea(False)` for apps that handle it themselves). See [The safe area](/guide/navigation#the-safe-area).

**Android: no crash without the icon font**. On Android `FMXER.IconFontsData` registered `Material Design Icons Desktop.ttf` from the documents folder without checking it: with Skia of RAD Studio 13 a missing file raises in the unit initialization, and the app closed at start (runtime error 217, white screen). The font is now registered only when present, as on Windows: without it the icons are missing, the app starts. Deploy it to `assets\internal` (see [The icon font](/guide/installation#the-icon-font)).

**Demos and submodules**:

- Android64 deployment of the demo media: the font, the Lottie animations and the images were deployed for Android 32-bit only (and the JSON files of QRCode outside `assets\internal`), so the 64-bit APKs had none of them. Every demo now deploys the font, and its media, to `assets\internal` for Android and Android64.
- Every demo project updated for RAD Studio 13 (project version 20.5, the Android system libraries of RAD Studio 13, min SDK 24 and target SDK 36, the Android64 deployment as RAD Studio 13 writes it; no `libsk4d.so`: Skia is linked statically). Weather and MyTicketing get an Android manifest template.
- Demo permissions: only what each demo uses (QRCode: camera and internet; LibraryStore and WebView: internet; the others none). Debug builds also get INTERNET, which RAD Studio adds for the debugger.
- Demo launcher icon: the FMXER rocket (`media\android`), as an adaptive icon (also themed on Android 13+) and as legacy icons for every density, instead of the default FireMonkey icon. Package names `eu.andreamagni.<Project>`.
- HelloWorld_IFIL: black screen on Android. With the Skia raster canvas (the default on Android) its `TIconFontsImageList` left the whole window black; the demo now uses the GPU canvas (`GlobalUseSkiaRasterWhenAvailable := False`), as HelloWorld does.
- `lib/TFrameStand` updated to TFrameStand v.2.4 (interactive gestures of the frames registered with the hosting form).
- `lib/ZXing.Delphi` updated to ZXing.Delphi 4.0 (branch `4.0`): 52 formats, parallel decoding, `IScanManager` and `ScanAsync`.
- QRCode demo: the scanner thread and its frame queue are replaced by one `IScanManager` with `ScanAsync` (decoding in background, the result in the main thread); the code read is outlined from its corners (`TReadResult.Position`). `Threads.Scanner.pas` removed.

## v.1.5.3 — 2026-10-16

**Icon font on Windows**: without the *Material Design Icons Desktop* font installed, icons were drawn as empty boxes (for example the action button of the NewProjectTemplate demo).

- The setup installs the font for the current user (it stays when FMXER is uninstalled, because other applications may use it).
- `FMXER.IconFontsData` registers with Skia the `.ttf` found next to the executable: deploy the font with your application and it works on machines where the font is not installed. See [The icon font](/guide/installation#the-icon-font).

## v.1.5.2 — 2026-10-16

**Setup and IDE**:

- The setup installs the libraries the QRCode demo needs, in `lib\DelphiZXingQRCode` and `lib\ZXing.Delphi`: the demos compile after a setup install. The LibraryStore demo needs the MARS-Curiosity client (its setup). See [Setup](/guide/installation#setup).
- New design-time package `dclFMXERPackage` (Delphi 12 and 13): FMXER, with its version, in the splash screen and in the About box of the IDE. It registers no components. The setup and TMS Smart Setup install it.
- The QRCode and NewProjectTemplate demos open with Win32 as the active platform, like the other demos.

Library code is unchanged from v.1.5.

## v.1.5.1 — 2026-10-16

**Setup fixes** (the v.1.5 setup did not install):

- The setup found no RAD Studio version: the `FMXER.groupproj` files of the packages had no build groups, which the setup reads to find the packages and their Delphi version. `setup\build-setup.cmd` now checks them before compiling the setup.
- When TFrameStand or IconFontsImageList was not installed, the setup copied the files and then failed building the packages (`E2202 Required package 'IconFontsImageListFMX' not found`). It now checks for their packages (in the Dcp folder of the IDE and in the library path) and, if one is missing, stops before installing anything and says what to install. See [Setup](/guide/installation#setup).

Library code is unchanged from v.1.5.

## v.1.5 — 2026-10-16

**Packages and installation** (ANALYSIS P4):

- Runtime packages for Delphi 12 Athens and 13 Florence (`packages\12Athens`, `packages\13Florence`): `FMXERPackage` (all of `source\` but the QR code units) and `FMXERQRCodePackage` (`TQRCodeFrame`, `QRCode.*`, with DelphiZXingQRCode), Win32 and Win64.
- [TMS Smart Setup](/guide/installation#tms-smart-setup): `tmsbuild.yaml`, with TFrameStand as a dependency.
- A [setup](/guide/installation#setup) (Inno Setup, like TFrameStand's): packages and the source folder in the library path of every platform.

**Demos and build** (ANALYSIS P3, E3):

- Every demo uses the same search path: `..\..\source` and the `lib\` submodules (with empty submodule folders the IDE library path is used); the icon font is deployed from `media\`.
- LibraryStore reads the MARS server URL from constants, or from the `FMXER_LIBRARYSTORE_URL` environment variable on desktop; the Android default is `10.0.2.2` (the host seen from the emulator).
- `build.cmd [13|12] [win32|win64|all] [demos]`: Win64 with `dcc64`; outputs in `build\<version>\<platform>`. The test suite compiles and passes on Win64 too (55 tests on each platform).

## v.1.4 — 2026-10-16

**Faster columns and rows** (ANALYSIS D3), measured on Delphi 13, Windows:

- `TColumnFrame` and `TRowFrame` (new units): the API of `TColumnForm` and `TRowForm` as frames, about ten times cheaper to create (a form creates a native window: 2.4 ms against 0.2 ms).
- `BatchUpdate` on the four of them: adding many elements realigns once, linear instead of quadratic (400 texts: 0.34 s instead of 1.5–2 s).
- `TFMXERSlots`: the one implementation of the slots, usable for your own containers.

**Back button** (ANALYSIS D5): `Navigator.SetCatchBackKey(True)` — Back and Esc close the top route, the root is left to the form, a transient route consumes the key. `HandleBackKey` for your own `OnKeyDown`. The NewProjectTemplate demo uses it.

**Navigator instances** (ANALYSIS D4): `Navigator(AFormStand)` with another form stand raises (it returned the first navigator); `TNavigator.ReleaseInstance`; more navigators with `TNavigator.Create`, each with its own routes and stack.

55 tests.

## v.1.3 — 2026-10-16

**Automatic sizes** (ANALYSIS D1):

- `TColumnForm.AddFrame<T>(TColumnForm.AUTO_HEIGHT)` and `TRowForm.AddFrame<T>(TRowForm.AUTO_WIDTH)` (and `AddForm<T>`): the slot takes the element's own size, the one in its `.fmx` or the one set by the configuration procedure. See [Automatic sizes](/guide/layouts#automatic-sizes).
- `TVertScrollFrame`, `TVertScrollForm`, `THorzScrollFrame`: a frame content keeps its design size (it got 50 pixels: TFrameStand aligns the frame to its stand before the configuration procedure runs), and `ContentStand` is used (it was ignored).
- `TFMXERStands.NewSizedFrame<T>` to do the same in your own containers.

**Uniform fluent API** (ANALYSIS D2), all additions, existing code compiles unchanged:

- every slot method returns its container (`TContainerForm`, `TVertScrollForm`, `THorzScrollFrame`, `TCardFrame`, `TActionButtonFrame` had procedures);
- `SetOnClickProc` on every clickable element; `SetOnTapHandler` on the image elements;
- setters for the properties: `TCardFrame.SetTitle`, `TWebViewFrame.SetURL`/`SetHTML`, `TLogoFrame.SetLogoResource`, `TActivityBubblesFrame.SetText`, `TVertScrollForm.SetTouchWidth`, `THorzScrollFrame.SetTouchHeight`, `SetContentStand` on the single-slot containers, `SetElementStand` and `TRowForm.SetElementAlign`.

37 tests.

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
