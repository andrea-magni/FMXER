# QR Codes

`TQRCodeFrame` (unit `FMXER.QRCodeFrame`) draws a QR code from a text, with rounded modules rendered as SVG by Skia. Encoding is done by [DelphiZXingQRCode](https://github.com/foxitsoftware/DelphiZXingQRCode); the rounded renderer (`QRCode.Render`) comes from the Skia4Delphi samples.

```pascal
Col.AddFrame<TQRCodeFrame>(200
, procedure (QR: TQRCodeFrame)
  begin
    QR
    .SetContent('https://github.com/andrea-magni/FMXER')
    .SetOverrideColor(TAlphaColorRec.Navy)
    .SetRadiusFactor(0.3)
    .SetMargin(2)
    .SetHitTest(True);

    QR.OnTapHandler :=
      procedure (AImage: TFMXObject; APoint: TPointF)
      begin
        Navigator.RouteTo('qrcode');
      end;
  end
);
```

The code is regenerated whenever the content, the radius factor or the paint handler change, so the same element can follow a value — the HelloWorld demo updates it while you type in an edit.

## Members

| Member | Description |
|---|---|
| `SetContent(AText)` | the text to encode (encoding chosen automatically) |
| `SetRadiusFactor(AFactor)` | corner radius of the modules, relative to their size: 0 = squares, 0.1 by default, 0.5 = dots |
| `SetOverrideColor(AColor)` | paints the whole code in one color |
| `OnBeforePaint: TOnBeforePaintHandler` | customizes the Skia paint before rendering (gradients, shaders) |
| `SetSVGSource(ASource)` | shows any SVG instead of a generated code |
| `LoadLogoContentFromFile(AFileName)`, `SetLogoVisible`, `SetLogoWidth`, `SetLogoHeight` | an image or animation (`QRCodeLogo`, a `TSkAnimatedImage`) in the center of the code |
| `OnTapHandler` | tap (mouse up on Windows), see [Images & Media](./images-and-media#tap-handlers) |
| `QRCode: TSkSvg` | the SVG control |

The renderer leaves the central module free for a logo. Keep logos small: QR codes tolerate a limited amount of covered area.

### A gradient code

```pascal
QR.OnBeforePaint :=
  procedure (APaint: ISkPaint; AModules: T2DBooleanArray)
  begin
    APaint.Shader := TSkShader.MakeGradientLinear(
      PointF(Length(AModules) - 6, 6), PointF(6, Length(AModules) - 6)
    , TAppColors.MATERIAL_ORANGE_800, TAppColors.MATERIAL_DEEP_PURPLE_400
    , TSkTileMode.Clamp);
  end;
```

`AModules` is the matrix of the code (`True` = dark module), its size is the number of modules per side. The Skia101 demo uses this handler, with a code that shows the current time and changes every half second.

## QRCode.Utils

| Routine | Description |
|---|---|
| `TQRCode.TextToSvg(AContent, ABeforePaint = nil, ARadiusFactor = 0.1): string` | the SVG of a QR code, without any control |
| `SvgToBitmap(ASvg, ABGColor, AColor, AWidth, AHeight, AOnReady: TProc<TBitmap>)` | renders an SVG of `AWidth` x `AHeight` into a bitmap with a 10-pixel margin of `ABGColor` on every side, and passes it to `AOnReady` (the bitmap is freed afterwards) |

The QRCode demo combines them to share a code as an image; in essence:

```pascal
SvgToBitmap(TQRCode.TextToSvg(QRCodeContent), QRCodeBGColor, QRCodeColor, 1024, 1024
, procedure (ABitmap: TBitmap)
  begin
    ShowShareSheetAction1.Bitmap.Assign(ABitmap);
    ShowShareSheetAction1.Execute;
  end
);
```

## Reading QR codes

FMXER has no element to *read* codes, but the **QRCode demo** shows how to do it: a `TCameraComponent` queues frames, a background thread decodes them with [ZXing.Delphi](https://github.com/Spelt/ZXing.Delphi), and a `TPaintBoxFrame` draws the frame and the detected points; camera permission, torch and Back handling included. See [Demos](/demos/#qrcode).
