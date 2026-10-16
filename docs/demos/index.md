# Demos

The `demos` folder has one project per topic; ten of them are in `demos\AllDemos.groupproj` (MyTicketing and EKON25 - Weather are not). They target Windows, macOS, iOS and Android, and expect the dependencies in the search path or installed (see [Installation](/guide/installation)).

Media files (Lottie animations, SVG, the icon font) come from the `media` folder: on Windows the demos read them from there with `LocalFile`, on mobile they are deployed with the app.

| Demo | Shows | Extra requirements |
|---|---|---|
| [NewProjectTemplate](#newprojecttemplate) | the smallest FMXER app, to copy | — |
| [HelloWorld](#helloworld) | scaffold, stack, scrolling column, rows, chips, edit, QR code, transient route, app state | — |
| [Column](#column) | columns, cards, `TElementDef`, scrolling | — |
| [MarginAndPadding](#marginandpadding) | margins and paddings | — |
| [Skia101](#skia101) | images, SVG, Lottie, QR code with gradient, Skia paint box | — |
| [WebView](#webview) | a web page in a scaffold | — |
| [DataSet](#dataset) | LiveBindings to a FireDAC dataset, route stands | FireDAC |
| [LibraryStore](#librarystore) | lists filled from a REST server, async loading, multiple routes | MARS client, a MARS server |
| [HelloWorld_IFIL](#helloworld-ifil) | an image list of icon fonts on the main form | — |
| [QRCode](#qrcode) | QR code generator and camera reader, color pickers, share sheet | ZXing.Delphi, camera |
| [MyTicketing](#myticketing) | a login column (edits, password, default button enabled by `OnUpdateHandler`) leading to a scaffold | — |
| [EKON25 - Weather](#ekon25-weather) | a card with a nested column in a scaffold, conference starting point | — |

## NewProjectTemplate

The starting point for a new app: a main form with a `TFormStand`, one route unit (`Routes.home`) with a scaffold, a logo and a close action button, `OnCloseRoute` closing the app, Back/Esc handled by the navigator (`SetCatchBackKey`). The project is set up for every platform, including the iOS simulator on Apple silicon, and deploys the icon font. Copy the folder to start a new project.

## HelloWorld

The richest tour of the elements, in three routes:

- **home**: a scaffold whose content is a `TStackFrame` with a white background, a tiled SVG, a Lottie animation and a `TVertScrollFrame` with a column: a row of three buttons, a chip, a flow of chips, an edit, a QR code that follows what you type, and a custom frame (`Frames.Custom1`) designed in the IDE. A small QR code is in the title detail area; two action buttons show a snackbar and close the app.
- **bubble**: a transient route with `TActivityBubblesFrame`, opened and closed after 3 seconds with `RouteTo('bubble', True)` + `CloseRouteDelayed`.
- **qrcode**: a full-screen QR code of the text typed in the home screen; tap to close.

Shared state is a data module (`Data.AppState`) that broadcasts changes with `System.Messaging` ; each subscriber is tied to the lifetime of its QR code by a `TSubscriptionGuard` (see [State & Events](/guide/state#subscriptions-and-the-lifetime-of-elements)).

## Column

`TBackgroundForm` routes with columns: a menu of two texts that open the other routes, a plain column and the same column in a `TVertScrollFrame`. Shows `TContainerFrame.SetContentAs<TButton>` (a plain *Close me* button that calls `Navigator.StackPop`), `TLogoFrame`, `THorzDividerFrame`, `TCardFrame` and the `TElementDef` overload with `Param('Height', ...)`. Closing the window closes the routes first.

## MarginAndPadding

A `TVertScrollForm` with a column of logos: the same logo plain, in a `TMarginFrame` with `SetMargin(50)`, in a `TPaddingFrame` with `SetPadding(50)`, and in a `TContainerFrame` with both. Elements are sized from the column width (`ACol.Width`) to get squares.

## Skia101

A menu (`TListViewFrame` in a `TStackFrame`) of Skia-based screens, with `TAppColors.PrimaryColor` set to blue:

- spinners: a transient route closed after 1, 5 or 10 seconds;
- `TImageFrame`, `TAnimatedImageFrame` (Lottie), `TSVGFrame`: tap to close;
- a QR code that shows the current time, updated by a background task, with a gradient shader (`OnBeforePaint`);
- a `TPaintBoxFrame` filled with a Skia sweep gradient (route `freeHandDrawing`, a starting point for drawing), with a *Back* button in the title detail area.

## WebView

The smallest route: a scaffold with a `TWebViewFrame` opening a URL, defined and routed in one fluent statement.

## DataSet

A list of employees from a `TFDMemTable` (data module `Data.Main`) in a frame designed in the IDE with LiveBindings (`Frames.MyDataSetList`), and a detail frame (`Frames.MyDataSetDetail`) shown by a second route. The detail route is defined with a stand, `slideRightLeft`, from the main form's style book: the whole screen slides in. Action buttons use images from a `TImageList`.

## LibraryStore

A small catalog app that reads books and authors from a [MARS-Curiosity](https://github.com/andrea-magni/MARS) REST server (`Data.Remote`, `TMARSNetClient` with asynchronous `GETAsync`):

- **home**: a list with two entries;
- **books_all**, **books_by_author**, **authors**, **book_single**: lists built by an `ItemBuilderProc`, titles updated with the number of results, search box when there are more than three items, an activity animation in the title detail area while loading (driven by `TRetrieveMsg` messages, unsubscribed when the route closes), errors in a snackbar;
- icons added once and cached in `Utils.UI`.

It needs a MARS server exposing the LibraryStore resources (`http://localhost:8080/rest` on desktop; set the address in `Data.Remote` for devices).

## HelloWorld_IFIL

The HelloWorld idea with a `TIconFontsImageList` dropped on the main form instead of the shared `IconFonts`: icons inserted at runtime by code point (`MD.account_clock.codepoint`), used by action buttons and by a `TGlyphFrame` in a `TBackgroundForm`.

## QRCode

A complete app, and the most recent demo:

- **home**: a stack with background, Lottie animation and a column of `TAccessoryFrame` rows (icon + button) to the other routes;
- **QRGenerator**: an edit for the content, two `TColorButtonFrame`s in a `THorzPairFrame` that open color picker routes, a `TTrackbarFrame` for the corner radius, the code (`TQRCodeFrame`) and a share action (`SvgToBitmap` + `TShowShareSheetAction`);
- **QRCodeColorSelection**, **QRCodeBGColorSelection**: the same route definition (`DefineColorPickerRoute`) with different getters and setters;
- **QRReader**: camera preview in a `TPaintBoxFrame`, frames decoded by ZXing.Delphi in a background thread (`Threads.Scanner`), detected points drawn as they fade, torch toggle when the device has one, result with actions to open the content in the **Webview** route or to generate it again;
- **SingleFrame**: the last camera frame (or the frame of the last result, with its points), with the same result actions; scanning a single picture is still marked *Not yet implemented*;
- **Webview**: the scanned content in a `TWebViewFrame`.

The main form shows the breadcrumb in the caption on Windows, closes the camera in `OnCloseRoute` and handles Back/Esc with `StackPop`.

## MyTicketing

A conference demo, ported to the fluent API of 1.1:

- **login**: a `TColumnForm` with a logo, two `TEditFrame`s (`SetCaption`, `SetPassword(True)`) that store what you type in a data module (`Data.Remote`), and a default *Login* button (`SetOnClickHandler`) enabled by its `OnUpdateHandler` only when both fields are filled; the login succeeds with `andrea` / `password`;
- **home**: a scaffold with a logo and two action buttons (a snackbar, close the route).

## EKON25 - Weather

The starting point of a conference session (EKON 25): a scaffold whose content is a column with a `TCardFrame` titled with a location, and a *Get weather* button in a column nested in the card. The weather frame (`Frames.WeatherSituation`) and the data module are placeholders, never completed.
