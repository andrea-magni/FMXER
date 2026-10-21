# Units & Dependencies

Every unit is in `source\`. FMXER has no packages: add `source\` to the search path (see [Installation](/guide/installation)).

## Units

| Unit | Declares | Depends on |
|---|---|---|
| `FMXER.Navigator` | `TNavigator`, `Navigator()` | TFrameStand |
| `FMXER.UI.Misc` | `TElementDef<T>`, `TNameValueParam`, `TParams`, `Param()`, `OnClickProc()`, `TFMXERFrameHelper`, `TFMXERFormHelper`, `TSubjectInfoContainer`, `TFMXERStands`, `TFMXERSlots`, `TCaptionPosition`, `LocalFile()`, `LocalFilesPath` | TFrameStand |
| `FMXER.UI.Consts` | `TAppColors` | — |
| `FMXER.UI.Types` | `TOnTapHandler` | — |
| `FMXER.IconFontsData` | `TIconFonts` (data module), `IconFonts()`, `ICON_FONTS_FAMILYNAME`, `ICON_FONTS_FILENAME` | IconFontsImageList, Skia |
| `Icons.Utils` | `TIconEntry`, `TIconCollection`, `TIconManager` | — |
| `Icons.MaterialDesign` | `TMaterialDesign`, `MD` | — |
| `QRCode.Utils` | `TQRCode`, `TOnBeforePaintHandler`, `SvgToBitmap()` | DelphiZXingQRCode, Skia |
| `QRCode.Render` | `TQRCodeRender`, `IQRCodeRender`, `T2DBooleanArray` | Skia |
| `FMXER.ScaffoldForm` | `TScaffoldForm` | TFrameStand, Skia, IconFontsImageList |
| `FMXER.ColumnForm`, `FMXER.RowForm` | `TColumnForm`, `TRowForm` | TFrameStand |
| `FMXER.ColumnFrame`, `FMXER.RowFrame` | `TColumnFrame`, `TRowFrame` | TFrameStand |
| `FMXER.CenterForm`, `FMXER.ContainerForm`, `FMXER.BackgroundForm`, `FMXER.VertScrollForm` | the other form containers | TFrameStand |
| `FMXER.ContainerFrame`, `FMXER.MarginFrame`, `FMXER.PaddingFrame`, `FMXER.StackFrame`, `FMXER.VertScrollFrame`, `FMXER.HorzScrollFrame`, `FMXER.AccessoryFrame`, `FMXER.HorzPairFrame`, `FMXER.BackgroundFrame` | frame containers | TFrameStand |
| `FMXER.CardFrame`, `FMXER.ActionButtonFrame` | | TFrameStand, Skia |
| `FMXER.TextFrame`, `FMXER.ButtonFrame`, `FMXER.ColorButtonFrame`, `FMXER.EditFrame`, `FMXER.TrackbarFrame`, `FMXER.ColorPickerFrame`, `FMXER.ActivityBubblesFrame`, `FMXER.AnimatedImageFrame`, `FMXER.SVGFrame`, `FMXER.PaintBoxFrame` | Skia elements | Skia (and TFrameStand for the edit, track bar and color picker) |
| `FMXER.QRCodeFrame` | `TQRCodeFrame` | Skia, DelphiZXingQRCode |
| `FMXER.SwitchFrame`, `FMXER.CheckBoxFrame`, `FMXER.RadioGroupFrame`, `FMXER.ComboBoxFrame`, `FMXER.DateEditFrame`, `FMXER.ProgressBarFrame` | form controls | Skia |
| `FMXER.GlyphFrame`, `FMXER.ImageFrame`, `FMXER.LogoFrame`, `FMXER.WebViewFrame`, `FMXER.ChipFrame`, `FMXER.ChipsFrame`, `FMXER.HorzDividerFrame` | plain FMX elements | — |
| `FMXER.IconFontsGlyphFrame`, `FMXER.ListViewFrame` | | IconFontsImageList |

## Dependencies

| Library | Units used | Notes |
|---|---|---|
| [TFrameStand](https://andrea-magni.github.io/TFrameStand/) | `SubjectStand`, `FrameStand`, `FormStand` | v.1.6 or later; v.2.3 recommended |
| Skia (built into Delphi 12+) | `System.Skia`, `FMX.Skia` | `TSkLabel`, `TSkSvg`, `TSkAnimatedImage`, `TSkPaintBox` |
| [IconFontsImageList](https://github.com/EtheaDev/IconFontsImageList) | `FMX.IconFontsImageList` | v.3.2.2 in the submodule |
| [DelphiZXingQRCode](https://github.com/foxitsoftware/DelphiZXingQRCode) | `DelphiZXIngQRCode` | QR code encoding |

## Third-party code and assets

- `QRCode.Render.pas` comes from the [Skia4Delphi](https://github.com/skia4delphi/skia4delphi) webinar samples (rounded QR code rendering).
- `media\Material Design Icons Desktop.ttf`: [Material Design Icons](https://pictogrammers.com/library/mdi/) by Pictogrammers, Apache License 2.0.
- The Lottie animations in `media\` come from [LottieFiles](https://lottiefiles.com).

## Files of the repository

| Path | Content |
|---|---|
| `source\` | the units and their `.fmx` |
| `demos\` | demo projects, `AllDemos.groupproj` |
| `lib\` | submodules: TFrameStand, IconFontsImageList, DelphiZXingQRCode, ZXing.Delphi |
| `media\` | logos, the icon font, Lottie animations and SVG files used by the demos |
| `List.md` | the list of the elements |
| `docs\` | this documentation (VitePress) |
