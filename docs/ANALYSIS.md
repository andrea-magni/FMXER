# FMXER — technical review (October 2026)

Internal document, not published on the site (excluded in `.vitepress/config.mts`).
Baseline: `master` at `c9e2efe` (2023-02-03, 45 commits after v.1.1). Compiler used for the checks: Delphi 13 (dcc32 37.0), Win32.

## Snapshot

| | |
|---|---|
| Code | ~5,200 lines in `source\` without the generated `Icons.MaterialDesign.pas` (17,814 lines). Biggest units: `FMXER.UI.Misc` 360, `FMXER.ScaffoldForm` 307, `FMXER.Navigator` 279, `QRCode.Render` 258, `FMXER.ListViewFrame` 256 |
| Elements | 31 frames, 7 forms, plus `TNavigator`, `TAppColors`, `TIconFonts` and the helpers of `FMXER.UI.Misc` |
| Packages | none: the library is used from source (search path) |
| Dependencies | TFrameStand (submodule pinned at `9200a9c`, v.1.6 + 3 commits, 2022), Skia4Delphi (standalone, unit names `Skia`/`Skia.FMX`), IconFontsImageList (submodule, v.3.2.2), DelphiZXingQRCode (submodule); ZXing.Delphi (submodule) only for the QRCode demo; MARS client only for the LibraryStore demo |
| Demos | 13 projects, 10 in `AllDemos.groupproj` (all 13 build since E1) |
| Tests / CI | none |
| GitHub | 100 stars, 28 forks, 3 issues (all closed in 2021), no PRs |
| Last release | v.1.1, 2022-11-03 ("Skia4Delphi is now a dependency"); 45 commits on `master` since then, unreleased |
| Declared support | Delphi 11.2 (README); `.dproj` files are ProjectVersion 19.3/19.5 (Delphi 11) |

The idea is still original in the Delphi world: a UI is a tree of frames and forms, each one
composed in code with generics and anonymous methods (`SetContentAsFrame<T>(procedure (F: T) ...)`),
while TFrameStand/TFormStand do the heavy lifting (parenting, stands, animations, lifecycle).
`TNavigator` adds named routes on top of a `TFormStand`. The code is small and readable; most of
the issues below are edge cases of the navigator, a few copy-paste slips, and the drift of the
dependencies (Skia moved into the RTL with Delphi 12, TFrameStand moved to v.2.x).

Legend: ✅ verified (compiled or executed), 📖 found by reading the code.

### How the checks were run

- All 46 units of `source\` compiled together with Delphi 13 against **TFrameStand 2.3**
  (`C:\Sviluppo\Librerie\TFrameStand\source`), IconFontsImageList 3.2.2 (the pinned commit) and
  DelphiZXingQRCode, with the unit aliases `Skia=System.Skia;Skia.FMX=FMX.Skia`: no errors, one hint
  (`FMXER.ColumnForm.pas(50) H2164`). Without the aliases: `F2613 Unit 'Skia.FMX' not found`.
- Every demo compiled with the same setup (outputs in a scratch folder, `.res` untouched): 11 of 13 build.
- A console FMX program (`Application.Initialize` + `TForm.CreateNew`) exercised the navigator and
  the elements listed below; results quoted in the findings.

## Status on branch `release/1.2` (2026-10-15)

| Item | Status |
|---|---|
| P7 tests, build script | done (`25f3214`, `e5ed903`, `e10bf74`): `build.cmd [13\|12\|11] [demos]` (source units, DUnitX suite built and run, demos; output in `build\`), `tests\` with 21 tests, 11 of them fail or raise on v.1.1 |
| B1 `CloseRoute` pops the top | fixed (`6c01117`): the route is removed from the stack wherever it is. Tests: `CloseRouteRemovesThatRouteFromTheStack`, `ReopenedRouteIsPushedAgain` |
| B2 transient routes, `EListError` | fixed (`6c01117`): the navigator keeps the set of active transient routes; `ATransient` of `CloseRoute` kept for compatibility, ignored. Tests: `CloseTransientRouteWithoutFlag`, `CloseAllRoutesWithATransientRoute`, `CloseAllRoutesExcept` |
| B3 `SetPadding<T>` on forms | fixed (`d1be2a6`), test `FormSetPaddingGeneric` (did not compile before) |
| B4 `AddActionButton(ACaption, [])` | fixed (`274c246`), test `ActionButtonWithoutOnClickProc` |
| B5 pair stand setters | fixed (`fd606e9`), test `PairStandSetters` |
| B6 card glyph info | fixed (`3c6bfb3`); not observable from outside (the field is not read anywhere), smoke test only. `Detail` still not shown |
| B7 `AddIcon` without cache | fixed (`aab6519`): cache `(code point, color) → index`. Semantics: a second `AddIcon` of the same icon and color returns the same index. Test `AddIconReusesImages` |
| B8 list refresh duplicates, stale handlers | fixed (`8096816`): `RebuildItems` clears the list; handlers stored in the items (`Data['FMXER.OnSelect']`), the dictionary is gone. The stale-handler case did happen in the test on v.1.1 (a new item at the address of a freed one). Setting `ItemBuilderProc` now clears the list first. Tests `ListRefreshDoesNotDuplicate`, `ListClearItemsDropsHandlers` |
| B9 snackbar not freed | fixed (`98c43dd`), test `SnackBarIsClosed` |
| P2 TFrameStand submodule | `31f5b8c`: v.2.3. Source, tests and demos verified against v.2.3 and v.1.6 (all 21 tests pass on both) |
| P1 Skia unit names | done (`9d302fb`), decided by Andrea: FMXER requires Delphi 12+ and uses `System.Skia`, `FMX.Skia`, `FMX.Skia.Canvas` in source, demo units and demo projects; no unit aliases. Verified with `build.cmd 13 demos` (no aliases). Delphi 12 itself not available here: not compiled with 12 |
| E1 MyTicketing, EKON25 - Weather | ported to the fluent API (`6e6643c`): `SetTitle`, `SetText`, `SetCaption`, `SetPassword`, `GetText`, `SetOnClickHandler`, `OnUpdateHandler`; a section for each in `docs/demos`. Still not in `AllDemos.groupproj` |
| E2 message subscriptions | fixed (`7ed0384`): a `TSubscriptionGuard` owned by the element (the pattern of `docs/guide/state.md`) unsubscribes when the route closes; HelloWorld declares it in `Data.AppState` (three QR codes), LibraryStore in `Utils.Msg` (`TRetrieveMsg.Subscribe(AOwner, ...)`, owned by the activity animations). Test `ClosedRouteFreesItsElements`: closing a route frees its content and nested title detail frames, so the guards they own |
| E4 HelloWorld_IFIL icons | fixed (`52be947`): the project refers to `source\Icons.MaterialDesign.pas`, its copy is removed |
| E6 QRCode share | fixed (`25f88f3`): stream freed in `try/finally`, no save to `C:\temp` |
| B10–B14 | see the v.1.2.1 table below |

## Status on branch `release/1.2.1` (2026-10-16)

v.1.2 released 2026-10-16 (PR #4, tag `v.1.2`, docs site live).

| Item | Status |
|---|---|
| B10 `[Hide]` TODOs | checked, no change: with TFrameStand 2.3 closing a route frees every nested element (test `ClosedRouteFreesItsElements`, nested title-detail frame included). What the TODO asks — running the hide animations of nested elements before their container — is not needed for correctness; the TODO comments are left as notes |
| B11 `TOnTapHandler` declared four times | fixed (`f6bb2b1`): declared once in the new unit `FMXER.UI.Types`, aliased by the four units; `TPaintBoxFrame` uses `TPaintBoxTapHandler` (old name kept, deprecated). Test `OneTapHandlerTypeForTheImageElements` (did not compile before) |
| B12 `SvgToBitmap` margins | fixed (`be87483`), test `SvgToBitmapMarginsAreSymmetric` (failed before: code started at 20) |
| B13 `LocalFile` hard-coded | fixed (`12bc278`): folder in the `LocalFilesPath` variable, same defaults. Test `LocalFileUsesLocalFilesPath` |
| B14 column/row destructors | fixed (`d4a305c`): `FormStand1.CloseAll` too; unused variable removed. Test `ColumnClosesItsFormElements` (smoke: the forms were freed anyway by the form stand) |
| Docs workflow on Node 20 actions | `7d4bdf5`: configure-pages v6, upload-pages-artifact v5, deploy-pages v5, Node 24 |

Tests: 26 (`bcbe7cd`). Still open: design notes D1–D5; Delphi 12 and the non-Windows platforms not verified here.

Verified with `build.cmd 13 demos` on Delphi 13 Win32 (no unit aliases since P1): source ok, 22/22 tests, 13 of 13 demos.

## 1. Build, packaging and dependencies

| # | Finding | Evidence | Fix |
|---|---|---|---|
| P1 | **Delphi 12/13: Skia unit names.** The source uses the Skia4Delphi standalone units `Skia`, `Skia.FMX` (and the QRCode demo `Skia.FMX.Graphics`). Since Delphi 12 Skia is part of RAD Studio as `System.Skia` / `FMX.Skia` (`FMX.Skia.Canvas`), and Skia4Delphi itself recommends the new names. Class names (`TSkLabel`, `TSkSvg`, `TSkAnimatedImage`, `TSkPaintBox`) are unchanged, so the `.fmx` files load as they are. | ✅ D13: F2613 without aliases; full build with `-ASkia=System.Skia;Skia.FMX=FMX.Skia` (+ `Skia.FMX.Graphics=FMX.Skia.Canvas` for the QRCode demo) | Short term: document the unit aliases (Project Options > Building > Delphi Compiler > Unit aliases). Long term: `{$IF CompilerVersion >= 36}` in the uses clauses, or move to the new names and require 12+. |
| P2 | **TFrameStand submodule is old.** `lib/TFrameStand` is pinned at `9200a9c` (v.1.6 + 3), while TFrameStand is at v.2.3. FMXER compiles against 2.3 with no change (✅) and 2.x fixes several defects FMXER is exposed to (delayed actions on freed objects, `HideAndClose` while hiding, owner/parent destroyed, B1/B2/B15 of the TFrameStand review). | ✅ `git submodule status`, compile against 2.3 | Bump the submodule to v.2.3 and declare TFrameStand 2.3 as the minimum. |
| P3 | **Submodules not needed by every user, and not consistently used.** Only 6 of the 12 `.dproj` set `..\..\lib\...` in the search path; the others rely on the IDE library path (TFrameStand, IconFontsImageList installed). The icon font is deployed from `..\..\lib\IconFontsImageList\Demo\Fonts\` although a copy is in `media\`. | ✅ grep of `DCC_UnitSearchPath`, `DeployFile` | Pick one: submodules (and every demo uses `lib\`) or installed libraries (and the submodules go). Deploy the font from `media\`. |
| P4 | **No packages, no installer, no Smart Setup.** The library is source-only. That is fine for a framework made of frames (nothing to register in the IDE), but nothing says so, and there is no `tmsbuild.yaml`/GetIt entry. | 📖 | Document "add `source\` to the search path" (done in the docs); optionally a runtime package for faster builds. |
| P5 | **Declared support is stale.** README: "Delphi 11.2 (recent versions should be working, not tested yet)". With P1 solved by aliases, 13 works for the whole source. | ✅ D13 build | README and docs: 11.x as written, 12/13 with the unit aliases (P1). |
| P6 | **Unreleased work** (and `List.md` misses `TTrackbarFrame`). 45 commits since v.1.1 (Nov 2022): `TAccessoryFrame`, `THorzPairFrame`, `TTrackbarFrame`, `TColorPickerFrame`, `TColorButtonFrame`, `TIconFontsGlyphFrame` upgrade, `TListViewFrame` search box, `SetWidth`/`SetHeight` helpers, the QRCode and NewProjectTemplate demos. | ✅ `git log v.1.1..HEAD` | Release v.1.2 after P1/P2. |
| P7 | No tests, no build script, no CI. | ✅ | A `build.cmd` (source + demos, outputs in `build\`) and a few DUnitX tests for `TNavigator` would catch B1/B2. |

## 2. Demos

| # | Finding | Evidence | Fix |
|---|---|---|---|
| E1 | **MyTicketing and EKON25 - Weather do not compile**: they use the pre-v.1.1 API (`Title`, `Text`, `Caption`, `Password`, `OnClickProc`, `OnUpdateProc` as properties). Neither is in `AllDemos.groupproj`. | ✅ D13: E2003/E2250 in `Forms.Main.pas` | Port them to the fluent setters or remove them. |
| E2 | **Message subscriptions are never removed.** HelloWorld subscribes `TSomethingChangedMsg` in three places, LibraryStore subscribes `TRetrieveMsg` in two routes; the closures capture frames/forms (`AQR`, `QRF`, `SF`) that are freed when the route closes. Scenario (HelloWorld): tap the QR code (route `qrcode`), close it, type in the *Name* edit → `TAppState.SetSomething` sends the message → `QRF.SetContent` on a freed frame. Each re-open of a route also adds one more subscription. | 📖 | Keep the subscription id and `Unsubscribe` it when the element is destroyed (e.g. in an `OnCloseRoute` handler, or in a `[Hide]`/destructor of a small wrapper frame). The docs show the pattern. |
| E3 | LibraryStore needs a running MARS server with the LibraryStore resources; the Android URL is a hard-coded private IP (`192.168.62.28`). | 📖 `Data.Remote.pas` | Document it (done) or read the URL from a setting. |
| E4 | HelloWorld_IFIL ships its own, older `Icons.MaterialDesign.pas` (16,095 lines) that shadows the one in `source\`. | 📖 | Use the one in `source\`. |
| E5 | The QRCode demo needs the `FRAMEWORK_FMX` define (set by MSBuild for FMX projects, not by plain `dcc32`) for ZXing.Delphi. | ✅ | Nothing for IDE/MSBuild users; note for command-line builds. |
| E6 | QRCode demo, `TMainData.ShareQRCodeContent`: the `TMemoryStream` used to copy the bitmap is never freed, and on Windows the code is also saved to `C:\temp\qrcode.jpg` (fails when the folder does not exist). | 📖 `Data.Main.pas` | `try/finally` + `Free`; drop the debug save. |

All the other demos (Column, DataSet, HelloWorld, HelloWorld_IFIL, LibraryStore, MarginAndPadding,
NewProjectTemplate, QRCode, Skia101, WebView) build for Win32 with Delphi 13 (P1 aliases).

## 3. Defects

| # | Finding | Evidence | Fix |
|---|---|---|---|
| B1 | **`TNavigator.CloseRoute` pops the top of the stack, whatever route it closes.** Open `a`, `b`, `c`, close `b`: the stack becomes `[a,b]` while the active routes are `a,c`. `Breadcrumb` is wrong and `StackPop` (Back) then tries to close `b`, which is not active, and does nothing. | ✅ console test: `[a,b,c]` → `CloseRoute('b')` → stack `[a,b]`, active `a,c` | Remove `ARouteName` from the stack (rebuild the stack without its last occurrence), not `Pop`. |
| B2 | **`CloseAllRoutes` / `CloseAllRoutesExcept` raise `EListError` when a transient route is open.** They always call `CloseRoute(Route, False)`, which pops the stack also for transient routes (never pushed). With `a` + transient `t` open: `EListError: Unbalanced stack or queue operation`, and the remaining routes stay open. Same when the app calls `CloseRoute('t')` with the default `ATransient = False`. Several demos call `CloseAllRoutes` in `FormClose` (HelloWorld with its transient `bubble` route, Column, DataSet, MarginAndPadding, HelloWorld_IFIL). | ✅ console test | Remember the transient flag per active route in the navigator; `CloseRoute` should not need the caller to repeat it. |
| B3 | **`TFMXERFormHelper.SetPadding<T>` always raises `EInvalidCast`**: the constraint is `T: TControl`, but `Self` is a `TCommonCustomForm`. | ✅ `LForm.SetPadding<TControl>(5)` → EInvalidCast | Constraint `T: TCommonCustomForm`. |
| B4 | **`TScaffoldForm.AddActionButton(ACaption, AParams)` without an `OnClickProc` param raises `EInvalidCast`** (`TProc(ParamByName('OnClickProc', nil).GetReferenceToRawData^)` on a `TValue` holding a nil object). | ✅ `AddActionButton('X', [])` → EInvalidCast | `if AElementDef.FindParam('OnClickProc', LParam) then LProc := LParam.Value.AsType<TProc>`. |
| B5 | **`THorzPairFrame.SetLeftContentStand` / `SetRightContentStand` ignore their argument** (they only return `Self`). | ✅ getters still return `''` after `SetLeftContentStand('lightbox')` | Assign the fields. |
| B6 | `TCardFrame.SetGlyphAsForm` stores the info in `FContent` instead of `FGlyph`; `TCardFrame.Detail` is stored but never shown. | 📖 | Copy-paste fix; show or remove `Detail`. |
| B7 | **`TIconFonts.AddIcon` adds a new image at every call**, also for the same icon and color. Elements created repeatedly (route content, list builders, `AddActionButton(AIcon, AColor, ...)`) make the shared image list grow for the life of the app. | ✅ 100 calls with the same icon → 100 new images | Cache `(codepoint, color) → index`. |
| B8 | **`TListViewFrame` pull-to-refresh duplicates the items.** `PullToRefresh = True` in the `.fmx`; `ListViewPullRefresh` → `RebuildItems`, which clears the click handlers but, when an `ItemBuilderProc` is set, not the items: the builder appends a second copy, and the old items no longer respond to clicks. `ClearItems` (and swipe-to-delete) leave handlers keyed by freed items. | 📖 | `RebuildItems` = `ClearItems` + builder; `ClearItems` clears `FOnSelectHandlers`; remove the handler in `OnDeletingItem`. |
| B9 | `TScaffoldForm.ShowSnackBar` hides the snackbar but never closes it: one `TTextFrame` per call stays alive (hidden) until the scaffold is destroyed. | 📖 | `HideAndClose` instead of `Hide`. |
| B10 | `[Hide]` handlers of `TScaffoldForm`, `TVertScrollForm`, `TVertScrollFrame` carry a `TODO: Find a way to hide/close everything in the correct order`: nested subjects are not hidden before their container. | 📖 | With TFrameStand 2.x the nested stands are closed through FreeNotification; re-check after P2. |
| B11 | `TOnTapHandler` is declared four times (`FMXER.ImageFrame`, `AnimatedImageFrame`, `SVGFrame`, `QRCodeFrame`) with the same signature, and once more in `FMXER.PaintBoxFrame` with a different one: the type in scope depends on the order of the uses clause (variables of one are not assignable to the other). | 📖 | Declare it once in `FMXER.UI.Misc`. |
| B12 | `QRCode.Utils.SvgToBitmap` renders into `RectF(20, 20, AWidth, AHeight)` on a `(AWidth+20) x (AHeight+20)` bitmap: the QR code is `AWidth-20` wide, with 20 px on the left/top and 40 px on the right/bottom. | 📖 | `RectF(MARGIN/2, MARGIN/2, AWidth + MARGIN/2, AHeight + MARGIN/2)`. |
| B13 | `FMXER.UI.Misc.LocalFile` hard-codes the demo folder layout on Windows (`..\..\..\..\media\`). It is library code used only by demos. | 📖 | Move it to a demo unit, or make the base folder configurable. |
| B14 | `TColumnForm`/`TRowForm` destructors close `FrameStand1` only (forms added with `AddForm` are freed by their owner later); `TColumnForm.AddForm` declares an unused variable. | ✅ H2164 | Close both stands; remove the variable. |

## 4. Design notes (not defects)

| # | Note |
|---|---|
| D1 | **Sizes are explicit.** `TColumnForm.AddFrame<T>(AHeight)` (default 200) and `TRowForm.AddFrame<T>(AWidth)` add fixed-size slots and grow the form's own `Height`/`Width`; there is no measure/layout pass as in Flutter. `TVertScrollFrame` takes the content's `Height`. It is simple and predictable, but every element needs a size; the docs explain it. |
| D2 | **Fluent API is not uniform.** Most `SetContentAs*` are functions returning the element, some are procedures (`TContainerForm`, `TVertScrollForm`, `THorzScrollFrame`, `TCardFrame`, `TActionButtonFrame`); click handlers are named `OnClickProc`, `OnClickHandler`, `SetOnClick`, `SetOnClickHandler`, `SetOnClickProc` depending on the element; some values are properties (`TCardFrame.Title`, `TWebViewFrame.URL`), others setters. |
| D3 | Every container element embeds its own `TFrameStand` + `TFormStand` (and `TColumnForm`/`TRowForm`/`TScaffoldForm` a `TStyleBook`): a deep tree means many components. Fine for screens of tens of elements; for long lists use `TListViewFrame`. |
| D4 | Global state: one `Navigator` (singleton, one `TFormStand`), one `IconFonts` image list, `TAppColors` class variables read in the constructors (changing `TAppColors.PrimaryColor` affects elements created afterwards only). |
| D5 | TFrameStand 2.3 added dialog results (`ShowModal`), Back/Esc handling and a navigation stack (`Push`/`Pop`) with the same purpose as `TNavigator`'s stack: after P2, the navigator could delegate its stack to `TFormStand.Push`/`Pop` and get Back/Esc for free. |

## Suggested order

1. P2 (TFrameStand 2.3) and P1 (Skia names) — make FMXER build out of the box on 12/13.
2. B1, B2 (navigator), B3–B5, B7, B8 — small, testable fixes; a DUnitX project like TFrameStand's.
3. E1, E2 (demos), P3, P6 (release v.1.2).
