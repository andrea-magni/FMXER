# Element Catalog

Every element is a unit in `source\` named `FMXER.<Element>.pas`, with its `.fmx`. Add the unit to the `uses` clause and pass the class to a container's slot method (`SetContentAsFrame<T>`, `AddFrame<T>`, ...).

## Screens and containers

| Element | Kind | Purpose | Page |
|---|---|---|---|
| `TScaffoldForm` | form | screen with title bar, title detail area, content, floating action buttons, snackbar, drawer, bottom navigation | [Scaffold](./scaffold) |
| `TColumnForm` | form | elements stacked vertically, fixed heights | [Containers](./containers#tcolumnform) |
| `TRowForm` | form | elements side by side, fixed widths | [Containers](./containers#trowform) |
| `TColumnFrame`, `TRowFrame` | frame | the same as frames: cheaper, for columns and rows created many times | [Containers](./containers#tcolumnframe-and-trowframe) |
| `TVertScrollForm` / `TVertScrollFrame` | form / frame | vertical scroll box around one element | [Containers](./containers#tvertscrollframe-and-tvertscrollform) |
| `THorzScrollFrame` | frame | horizontal scroll box around one element | [Containers](./containers#thorzscrollframe) |
| `TStackFrame` | frame | layers, one on top of the other | [Containers](./containers#tstackframe) |
| `TCenterForm` | form | one element of fixed size, centered | [Containers](./containers#tcenterform) |
| `TContainerForm` / `TContainerFrame` | form / frame | one element (or any FMX control) in a slot | [Containers](./containers#tcontainerframe-and-tcontainerform) |
| `TMarginFrame`, `TPaddingFrame` | frame | a container meant to carry margins or paddings | [Containers](./containers#tmarginframe-and-tpaddingframe) |
| `TBackgroundForm` / `TBackgroundFrame` | form / frame | one element on a filled, bordered rectangle | [Containers](./containers#tbackgroundframe-and-tbackgroundform) |
| `TAccessoryFrame` | frame | content with optional left and right accessories | [Containers](./containers#taccessoryframe) |
| `THorzPairFrame` | frame | two elements, 50% / 50% | [Containers](./containers#thorzpairframe) |
| `TCardFrame` | frame | titled card with optional glyphs and content | [Containers](./containers#tcardframe) |
| `THorzDividerFrame` | frame | horizontal line | [Containers](./containers#thorzdividerframe) |
| `TTabsFrame` | frame | pages switched by a tab bar (top) or a navigation bar (bottom) | [Tabs & Navigation Bar](./tabs) |
| `TAlertFrame`, `TChoicesFrame` | frame | the content of `Modals.Alert`/`Confirm` and of `Modals.Choose` | [Dialogs & Bottom Sheets](./dialogs) |

## Content

| Element | Purpose | Page |
|---|---|---|
| `TTextFrame` | Skia text, clickable | [Text & Input](./text-and-input#ttextframe) |
| `TButtonFrame` | button with caption, extra text and background | [Text & Input](./text-and-input#tbuttonframe) |
| `TColorButtonFrame` | button with a color swatch | [Text & Input](./text-and-input#tcolorbuttonframe) |
| `TEditFrame` | edit with caption, prompt, extra text, password mode | [Text & Input](./text-and-input#teditframe) |
| `TTrackbarFrame` | track bar with caption and extra text | [Text & Input](./text-and-input#ttrackbarframe) |
| `TColorPickerFrame` | color panel with caption | [Text & Input](./text-and-input#tcolorpickerframe) |
| `TChipFrame`, `TChipsFrame` | a chip; a flow of chips | [Text & Input](./text-and-input#tchipframe-and-tchipsframe) |
| `TSwitchFrame` | text with a switch (Flutter `SwitchListTile`) | [Form Controls](./form-controls#tswitchframe) |
| `TCheckBoxFrame` | check box with a text (Flutter `CheckboxListTile`) | [Form Controls](./form-controls#tcheckboxframe) |
| `TRadioGroupFrame` | caption and radio buttons, one per option | [Form Controls](./form-controls#tradiogroupframe) |
| `TComboBoxFrame` | drop-down list with caption (Flutter `DropdownButton`) | [Form Controls](./form-controls#tcomboboxframe) |
| `TDateEditFrame` | date picker with caption | [Form Controls](./form-controls#tdateeditframe) |
| `TProgressBarFrame` | linear progress bar, determinate or indeterminate | [Form Controls](./form-controls#tprogressbarframe) |
| `TActionButtonFrame` | round floating button with an overlay element | [Scaffold](./scaffold#action-buttons) |
| `TImageFrame` | bitmap image, tappable | [Images & Media](./images-and-media#timageframe) |
| `TLogoFrame` | an image from a resource (the FMXER logo by default) | [Images & Media](./images-and-media#tlogoframe) |
| `TSVGFrame` | SVG image (Skia) | [Images & Media](./images-and-media#tsvgframe) |
| `TAnimatedImageFrame` | Lottie / animated image (Skia) | [Images & Media](./images-and-media#tanimatedimageframe) |
| `TActivityBubblesFrame` | animated "working" bubbles with a caption | [Images & Media](./images-and-media#tactivitybubblesframe) |
| `TPaintBoxFrame` | Skia paint box with a draw handler | [Images & Media](./images-and-media#tpaintboxframe) |
| `TGlyphFrame` | an image of an image list, clickable | [Icons](./icons#tglyphframe) |
| `TIconFontsGlyphFrame` | a Material Design icon | [Icons](./icons#ticonfontsglyphframe) |
| `TWebViewFrame` | web browser (URL or HTML) | [Images & Media](./images-and-media#twebviewframe) |
| `TListViewFrame` | list view with per-item click handlers, search, item builder | [Lists](./lists) |
| `TQRCodeFrame` | rounded QR code from text, with logo and custom paint | [QR Codes](./qrcode) |

## Support units

| Unit | Content | Page |
|---|---|---|
| `FMXER.Navigator` | `TNavigator`, `Navigator()` | [TNavigator](/reference/navigator) |
| `FMXER.Modals` | `TModals`, `Modals()`: dialogs and bottom sheets (`Alert`, `Confirm`, `Choose`, `ShowDialog<T>`, `ShowBottomSheet<T>`) | [Dialogs & Bottom Sheets](./dialogs) |
| `FMXER.UI.Misc` | `TElementDef<T>`, `Param()`, control and form helpers, `TSubjectInfoContainer`, `LocalFile`, `LocalFilesPath` | [FMXER.UI.Misc](/reference/ui-misc) |
| `FMXER.UI.Consts` | `TAppColors` | [TAppColors](/reference/app-colors) |
| `FMXER.UI.Types` | `TOnTapHandler` | [Images & Media](./images-and-media#tap-handlers) |
| `FMXER.IconFontsData` | `TIconFonts`, `IconFonts()` | [Icons](./icons) |
| `Icons.Utils`, `Icons.MaterialDesign` | icon entries, collections, the Material Design Icons table | [Icons](./icons#icon-entries) |
| `QRCode.Utils`, `QRCode.Render` | QR code to SVG, SVG to bitmap, rounded renderer | [QR Codes](./qrcode#qrcode-utils) |

::: tip Missing something?
Writing an element takes a frame and a few setters: see [Writing Your Own Elements](/guide/custom-elements).
:::
