---
description: "Answers to common questions and fixes for common problems with FMXER: Skia unit names, missing dependencies, navigator errors, invisible text, missing icons, access violations after closing a screen."
---

# FAQ & Troubleshooting

## Building

### `F2613 Unit 'Skia.FMX' not found`

Your code (or an element written for FMXER v.1.1) uses the unit names of the standalone Skia4Delphi. Since v.1.2 FMXER requires Delphi 12+ and its built-in Skia: use `System.Skia`, `FMX.Skia` and `FMX.Skia.Canvas`, see [Installation](./installation#delphi-11).

### `F2613 Unit 'SubjectStand' (or 'FMX.IconFontsImageList', 'DelphiZXIngQRCode') not found`

A dependency is not in the search path. Either initialize the submodules (`git submodule update --init`) and add their source folders, or install the libraries (GetIt, setup). See [Search path](./installation#search-path).

### The MyTicketing and EKON25 - Weather demos do not compile

They were written for FMXER 1.0 and use properties that became fluent setters in 1.1 (`Title` → `SetTitle`, `Text` → `SetText`, `OnClickProc` → `SetOnClickHandler`...). They are not part of `AllDemos.groupproj`; use them as reading material.

## Runtime

### `Navigator has not been initialized`

Something called `Navigator` before `Navigator(FormStand1)`. Initialize it first thing in the main form's `OnCreate` (or constructor), before any route definition.

### `Route definition not found: xyz`

`RouteTo` was called with a name that was never passed to `DefineRoute`. Route names are case-sensitive. Define every route before the first `RouteTo` — keeping the names in constants helps (the LibraryStore demo does).

### `EListError: Unbalanced stack or queue operation` when closing (v.1.1)

`CloseAllRoutes`/`CloseAllRoutesExcept` closed a **transient** route as if it were on the stack. Fixed in v.1.2; on v.1.1 close transient routes with `CloseRoute(AName, True)` before closing the others. See [Navigation](./navigation#transient-routes).

### The Back button closes the wrong screen, or nothing (v.1.1)

`CloseRoute` removed the top of the navigator's stack whatever route it closed. Fixed in v.1.2; on v.1.1 close routes in reverse order of opening.

### Text is invisible

`TTextFrame` uses `TAppColors.PrimaryTextColor` (white by default), meant for text on the primary color. On a white background call `SetFontColor(TAlphaColorRec.Black)`.

### Icons are squares, or empty

The *Material Design Icons Desktop* font is not available. Install it on Windows, deploy it on the other platforms. See [The icon font](./installation#the-icon-font).

### Access violation after closing a screen

A closure that references elements of the closed screen ran after the screen was freed: a message subscription, a timer, a background task, a callback. Unsubscribe or cancel it when the element is freed — see [Subscriptions and the lifetime of elements](./state#subscriptions-and-the-lifetime-of-elements).

### `EInvalidCast` from `SetPadding<T>` on a form, or from `AddActionButton(ACaption, AParams)` (v.1.1)

Both fixed in v.1.2. On v.1.1 use the non-generic `SetPadding(Value)` on forms, and pass an `OnClickProc` param (or use `AddActionButton(ACaption, AOnClickProc)`).

### The list shows every item twice after pull-to-refresh (v.1.1)

Fixed in v.1.2. On v.1.1 clear the items at the start of your `ItemBuilderProc` (`List.ClearItems`), or turn pull-to-refresh off with `List.ListView.PullToRefresh := False`.

### The elements of a row/column overlap or are cut

Sizes are explicit: every `AddFrame` gets the height (column) or width (row) you pass, 200 by default. Pass the size you want, and put columns longer than the screen in a `TVertScrollFrame`. See [Composing Layouts](./layouts#sizing-explicit-top-down).

## Design

### Can I mix FMXER with classic forms?

Yes. An FMXER element is just a frame or a form, and any form can be a route (`DefineRoute<TMyForm>`); any frame can be put in an FMXER container (`SetContentAsFrame<TMyFrame>`). You can also use FMXER containers in a classic form: drop a `TFormStand` on it and call `FormStand1.NewAndShow<TColumnForm>(Layout1, '', procedure (Col: TColumnForm) ...)` to fill `Layout1` with a column.

### Can I see FMXER screens at design time?

No: they are built in code. Each element can be opened in the designer on its own, and the [demos](/demos/) show complete screens.

### How do I pass data to a route?

Routes have no parameters: set the value somewhere the route definition can read it (a data module, a field of the main form, a captured variable) and then `RouteTo`. The route's configuration procedure runs at that moment and reads the current value. See [State & Events](./state#application-state-in-a-data-module).

### Is there an AI agent skill for FMXER?

Yes: the `fmxer-development` skill in the `Skills/` folder of the repository, installable as a Claude Code plugin, with npx or by hand. See [AI Agent Skill](./agent-skills). The [llms.txt](https://andrea-magni.github.io/FMXER/llms.txt) and [llms-full.txt](https://andrea-magni.github.io/FMXER/llms-full.txt) files of this site give an AI assistant the whole documentation in one request.
