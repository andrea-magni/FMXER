# Text & Input

Elements that show text or take input. All of them use Skia labels (`TSkLabel`) for their text, and fill their slot (`Align = Client`).

## TTextFrame

Unit `FMXER.TextFrame`. A text, centered by default, in `TAppColors.PrimaryTextColor`.

```pascal
Col.AddFrame<TTextFrame>(80
, procedure (Text: TTextFrame)
  begin
    Text
    .SetContent('FMXER builds this screen in code')
    .SetFontColor(TAlphaColorRec.Black)
    .SetFontSize(18)
    .SetFontWeight(TFontWeight.Bold)
    .SetHorzAlign(TSkTextHorzAlign.Leading)
    .SetMaxLines(2)
    .SetOnClickProc(
      procedure
      begin
        ShowMessage('Clicked');
      end
    );
  end
);
```

| Setter | Getter | Description |
|---|---|---|
| `SetContent(AText)` | `GetContent` | the text |
| `SetFontColor(AColor)` | `GetFontColor` | |
| `SetFontSize(ASize)` | `GetFontSize` | |
| `SetFontFamily(AFamily)` | | |
| `SetFontWeight(TFontWeight)` | `GetFontWeight` | |
| `SetHorzAlign(TSkTextHorzAlign)` | `GetHorzAlign` | `Leading`, `Center`, `Trailing`, `Justify` |
| `SetVertAlign(TTextAlign)` | `GetVertAlign` | |
| `SetMaxLines(ALines)` | `GetMaxLines` | |
| `SetOnClickProc(TProc)` (or `SetOnClick`) | `GetOnClickProc` | |

The label is `TextContent`. `TTextFrame` is also what the scaffold uses for snackbars and for text action buttons.

## TButtonFrame

Unit `FMXER.ButtonFrame`. A `TButton` driven by a `TAction`, with an optional caption above, an extra text below and a background rectangle.

```pascal
Col.AddFrame<TButtonFrame>(60
, procedure (Button: TButtonFrame)
  begin
    Button
    .SetText('Save')
    .SetBackgroundVisible(False)
    .SetOnClickProc(
      procedure
      begin
        // save
      end
    );

    Button.OnUpdateHandler :=
      procedure (AAction: TAction)
      begin
        AAction.Enabled := Document.Modified;
      end;
  end
);
```

| Member | Description |
|---|---|
| `SetText(AText)` | the button text (the action's caption) |
| `SetCaption(ACaption)` | label above the button |
| `SetExtraText(AText)` | label below the button |
| `SetOnClickProc(TProc)` (or `SetOnClickHandler`) / `OnClickHandler` | click (the action's `OnExecute`) |
| `OnUpdateHandler: TProc<TAction>` | the action's `OnUpdate`: enable, check, rename the button |
| `SetBackgroundFillColor`, `SetBackgroundStrokeColor`, `SetBackgroundStrokeThickness`, `SetBackgroundOpacity`, `SetBackgroundVisible` | the rectangle behind the button |
| `BackgroundFill`, `BackgroundStroke` | its brushes |
| `IsDefault` | the button's `Default` |
| `ButtonControl`, `ButtonAction`, `CaptionLabel`, `ExtraLabel`, `BackgroundRectangle` | controls |

## TColorButtonFrame

Unit `FMXER.ColorButtonFrame`. A `TButtonFrame` with a color swatch (`ColorRect`, a rounded rectangle) on the right. The QRCode demo uses two of them to pick the foreground and background colors of the code.

| Member | Description |
|---|---|
| `SetColorValue(AColor)` / `GetColorValue` | swatch color |
| `SetColorStrokeValue(AColor)` / `GetColorStrokeValue` | swatch border |
| `SetColorVisible(AVisible)` / `GetColorVisible` | |

Plus everything of `TButtonFrame` (the inherited setters return `TButtonFrame`: call the color setters first).

## TEditFrame

Unit `FMXER.EditFrame`. A `TEdit` with an optional caption above and an extra text below (each visible only when not empty).

```pascal
Col.AddFrame<TEditFrame>(100
, procedure (Edit: TEditFrame)
  begin
    Edit
    .SetCaption('Password')
    .SetTextPrompt('at least 8 characters')
    .SetPassword(True)
    .SetFocusOnShow(True)
    .OnChangeProc :=
      procedure (ATracking: Boolean)
      begin
        if not ATracking then   // OnChange: editing finished
          Edit.SetExtraText(IfThen(Length(Edit.GetText) < 8, 'Too short', ''));
      end;
  end
);
```

| Setter | Getter | Description |
|---|---|---|
| `SetText(AText)` | `GetText` | |
| `SetCaption(ACaption)` | `GetCaption` | label above |
| `SetTextPrompt(APrompt)` | `GetTextPrompt` | placeholder |
| `SetExtraText(AText)` | `GetExtraText` | label below (hints, errors) |
| `SetPassword(Boolean)` | `GetPassword` | |
| `SetFocusOnShow(Boolean)` | `GetFocusOnShow` | focus the edit when the element is shown |
| `OnChangeProc: TProc<Boolean>` | | `True` from `OnChangeTracking` (every keystroke), `False` from `OnChange` |

`IfThen` is in `System.StrUtils`. The edit is `EditControl`: set `KeyboardType`, `ReturnKeyType`, `MaxLength` there.

## TTrackbarFrame

Unit `FMXER.TrackbarFrame`. A `TTrackBar` with caption and extra text. The QRCode demo uses it for the corner radius of the modules.

| Setter | Getter |
|---|---|
| `SetValue`, `SetMin`, `SetMax`, `SetFrequency`, `SetTracking` | `GetValue`, `GetMin`, `GetMax`, `GetFrequency`, `GetTracking` |
| `SetCaption(ACaption)`, `SetExtraText(AText)` | `GetCaption`, `GetExtraText` |
| `SetCaptionPosition(TCaptionPosition; AMargin = 5)` | `Left`, `Right`, `Top`, `Bottom` |
| `SetOnChangeProc(TProc<Single>)` / `OnChangeProc` | the new value |

## TColorPickerFrame

Unit `FMXER.ColorPickerFrame`. A `TColorPanel` (hue, saturation, brightness) with caption and extra text.

| Member | Description |
|---|---|
| `SetColor(AColor)` / `GetColor` | |
| `SetCaption`, `SetExtraText` (and getters) | labels |
| `OnChangeProc: TProc<TAlphaColor>` | the new color |

The QRCode demo defines one route per color to pick (`DefineColorPickerRoute`), with a getter and a setter for the value.

## TChipFrame and TChipsFrame

Units `FMXER.ChipFrame`, `FMXER.ChipsFrame`. A chip is a small rounded button (`TSpeedButton` on a `TRoundRect`); `TChipsFrame` lays chips out in a `TFlowLayout` that wraps.

```pascal
Col.AddFrame<TChipsFrame>(50
, procedure (Chips: TChipsFrame)
  begin
    Chips
    .SetHorizontalGap(5)
    .SetVerticalGap(5)
    .DefaultConfig :=
      procedure (Chip: TChipFrame)
      begin
        Chip.Width := 60;
        Chip.OnClickHandler :=
          procedure
          begin
            ShowMessage(Chip.Button.Text);
          end;
      end;

    Chips
    .AddChip('Delphi')
    .AddChip('FMX')
    .AddChip('Skia'
    , procedure (Chip: TChipFrame)
      begin
        Chip.SetBackgroundColor(TAppColors.PrimaryColor).SetForegroundColor(TAlphaColorRec.White);
      end
    );
  end
);
```

| `TChipFrame` | |
|---|---|
| `SetText(AText)` | |
| `SetBackgroundColor(AColor)` | fill (default `SolidBackgroundColor`) |
| `SetForegroundColor(AColor)` | text and border (default `PrimaryColor`) |
| `SetOnClickProc(TProc)` / `OnClickHandler: TProc` | |

| `TChipsFrame` | |
|---|---|
| `AddChip(AText, AConfigProc = nil)` | adds a chip; without `AConfigProc`, `DefaultConfig` is applied |
| `DefaultConfig: TProc<TChipFrame>` | configuration for chips added without their own |
| `SetHorizontalGap`, `SetVerticalGap` | spacing of the flow layout |

Chips are plain frames created by `TChipsFrame` (not through a stand), so they have no show animation.
