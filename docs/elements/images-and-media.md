# Images & Media

Elements that draw: bitmaps, SVG, Lottie animations, custom drawing with Skia, and a web view. The Skia101 demo shows most of them.

## Tap handlers

`TImageFrame`, `TSVGFrame`, `TAnimatedImageFrame` (and `TQRCodeFrame`) have an `OnTapHandler`:

```pascal
TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);
```

It is called on `OnTap` on mobile and on `OnMouseUp` on Windows (where FMX raises no tap without a touch screen). The point is in the coordinates of the inner control. These elements also forward `HitTest` to the inner control: `SetHitTest(False)` makes them click-through, `SetHitTest(True)` lets them receive taps.

::: tip Same name, different units
Each of these units declares its own `TOnTapHandler` with the same signature. Assign anonymous methods directly (as in the examples), and avoid declaring variables of that type when several of these units are in the `uses` clause.
:::

## TImageFrame

Unit `FMXER.ImageFrame`. A `TImage` (`ContentImage`, also exposed as `Image`); add `FMX.Objects` to the `uses` clause to work with it.

```pascal
Scaffold.SetContentAsFrame<TImageFrame>(
  procedure (Img: TImageFrame)
  begin
    Img.Image.Bitmap.LoadFromFile(LocalFile('photo.jpg'));
    Img.Image.WrapMode := TImageWrapMode.Fit;
    Img.SetHitTest(True);
    Img.OnTapHandler :=
      procedure (AImage: TFMXObject; APoint: TPointF)
      begin
        Navigator.CloseRoute('image');
      end;
  end
);
```

## TLogoFrame

Unit `FMXER.LogoFrame`. A `TImage` (`LogoImage`) showing the FMXER logo by default — the placeholder used in many demos. `LogoResource := 'MyLogo'` loads a bitmap from an `RCDATA` resource of the application.

## TSVGFrame

Unit `FMXER.SVGFrame`. A Skia `TSkSvg` (`SVG`).

| Member | Description |
|---|---|
| `LoadFromFile(AFileName[, AEncoding])` | reads the SVG source from a file |
| `SetSVGSource(ASource)` | SVG source as a string |
| `SetWrapMode(TSkSvgWrapMode)` | `Fit`, `FitCrop`, `Stretch`, `Tile`, ... |
| `SetOverrideColor(AColor)` | paints every shape in one color (monochrome icons) |
| `SetOpacity(AOpacity)` | |
| `OnTapHandler` | |

```pascal
SVGF
.LoadFromFile(LocalFile('TSkSvg.svg'))
.SetWrapMode(TSkSvgWrapMode.Tile)
.SetOverrideColor(TAlphaColorRec.Orange)
.SetOpacity(0.33);
```

## TAnimatedImageFrame

Unit `FMXER.AnimatedImageFrame`. A Skia `TSkAnimatedImage` (`ContentImage`, also `Image`): Lottie JSON, animated GIF and WebP.

| Member | Description |
|---|---|
| `LoadFromFile(AFileName)` | loads the animation |
| `SetWrapMode(TSkAnimatedImageWrapMode)` | |
| `SetAnimationSpeed(ASpeed)` | 1 = normal speed |
| `SetOpacity(AOpacity)` | |
| `OnTapHandler` | |

The `media` folder of the repository has several Lottie animations from [LottieFiles](https://lottiefiles.com) used by the demos (backgrounds, loaders, success marks).

## TActivityBubblesFrame

Unit `FMXER.ActivityBubblesFrame`. A Lottie "bubbles" animation (embedded in the `.fmx`) with a `Text` property for a caption. Used as a busy indicator: a transient route with a `TContainerForm` around it, or in the scaffold's title detail area.

## TPaintBoxFrame

Unit `FMXER.PaintBoxFrame`. A Skia paint box (`PaintBox: TSkPaintBox`): draw anything with the Skia canvas.

```pascal
Scaffold.SetContentAsFrame<TPaintBoxFrame>(
  procedure (Paint: TPaintBoxFrame)
  begin
    Paint.SetOnDrawHandler(
      procedure (const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single)
      begin
        var LPaint: ISkPaint := TSkPaint.Create;
        LPaint.Color := TAppColors.PrimaryColor;
        LPaint.AntiAlias := True;
        ACanvas.DrawCircle(ADest.CenterPoint, ADest.Width / 4, LPaint);
      end
    );
  end
);
```

| Member | Description |
|---|---|
| `SetOnDrawHandler(TOnDrawHandler)` / `OnDrawHandler` | `procedure(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single)` |
| `SetOnTapHandler(TOnTapHandler)` / `OnTapHandler` | `procedure(APaintBox: TObject; APoint: TPointF)` |

Call `PaintBox.Redraw` to repaint. The Skia101 demo fills one with a sweep gradient, the QRCode demo draws the camera frame and the detected points on it.

## TWebViewFrame

Unit `FMXER.WebViewFrame`. A `TWebBrowser` (`WebBrowser1`).

| Member | Description |
|---|---|
| `URL: string` | navigates to a URL |
| `HTML: string` | loads an HTML string (`LoadFromStrings`) |

```pascal
Scaffold.SetContentAsFrame<TWebViewFrame>(
  procedure (Web: TWebViewFrame)
  begin
    Web.URL := 'https://github.com/andrea-magni/FMXER';
  end
);
```

`TWebBrowser` is a native control: it is drawn above the FMX controls, so stand animations and overlapping elements do not apply to it. On Windows it uses Edge WebView2 when available (see the FMX documentation for the runtime requirements).

## Loading files: LocalFile

`LocalFile(AFileName)` (unit `FMXER.UI.Misc`) is the helper the demos use to find their media: on Windows it returns `..\..\..\..\media\<AFileName>` (relative to the demo executable in `demos\<Demo>\Win32\Debug`), elsewhere `TPath.GetDocumentsPath + AFileName` (deploy the files to `.\assets\internal` on Android, to `StartUp\Documents` on iOS). In your own app, build the path yourself.
