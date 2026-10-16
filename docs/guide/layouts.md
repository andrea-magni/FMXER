# Composing Layouts

FMXER layouts are made of a few containers nested into each other. This page shows the sizing rules and the combinations used most often; every container is described in detail in [Containers](/elements/containers).

## Sizing: top-down

FMXER does not run a measure pass the way Flutter does: each container gives its children a size by a simple rule, and you either pass the size or let the slot take the **element's own size** (its design size in the `.fmx`, or the one the configuration procedure sets).

| Container | Rule |
|---|---|
| `TColumnForm` | each `AddFrame<T>(AHeight)`/`AddForm<T>(AHeight)` adds a slot of `AHeight` (default 200), aligned to the top, as wide as the column; with `TColumnForm.AUTO_HEIGHT` the slot takes the element's height. The column's own `Height` grows with each slot |
| `TRowForm` | each `AddFrame<T>(AWidth)` adds a slot of `AWidth` (default 200), aligned to the left (`ElementAlign`); with `TRowForm.AUTO_WIDTH` the slot takes the element's width. The row's `Width` grows with each slot |
| `TVertScrollFrame` / `TVertScrollForm` | the content is aligned to the top and keeps its own `Height`: put a column in it and the scroll box scrolls the column |
| `THorzScrollFrame` | the content is aligned to the left and keeps its own `Width`: put a row in it |
| `TCenterForm` | the content gets the size you pass (`SetContentAsFrame<T>(AWidth, AHeight)`), centered |
| everything else | the child fills the slot (`Client`) |

A slot is a `TLayout`: the element inside is aligned to it by its own `Align` (most elements are `Client` by design), so margins and paddings set on the element apply inside the slot.

### Automatic sizes

Pass `AUTO_HEIGHT` (column) or `AUTO_WIDTH` (row) instead of a size, and the slot takes the size of the element: the one designed in its `.fmx`, or the one set in the configuration procedure — margins included. For a form element (a nested column, for example) it is the form's `Height`/`Width` after the configuration procedure: a nested column measures itself.

```pascal
Col
.AddFrame<TTextFrame>(TColumnForm.AUTO_HEIGHT)           // 80: the design height of TTextFrame
.AddFrame<TEditFrame>(TColumnForm.AUTO_HEIGHT
, procedure (Edit: TEditFrame)
  begin
    Edit.SetCaption('Name').SetHeight(90);               // 90: set here
  end
)
.AddForm<TRowForm>(TColumnForm.AUTO_HEIGHT
, procedure (Row: TRowForm)
  begin
    Row.SetHeight(60);                                    // a form element: its Height
    Row
    .AddFrame<TButtonFrame>(TRowForm.AUTO_WIDTH
    , procedure (B: TButtonFrame) begin B.SetText('OK').SetWidth(80); end);
  end
);
```

The size is taken once, when the element is added: an element that changes size later does not resize its slot. The scroll boxes follow the same rule for a frame content: it keeps its design height (`TVertScrollFrame`) or width (`THorzScrollFrame`), or the one set by the configuration procedure.

::: info Since v.1.3
`AUTO_HEIGHT`/`AUTO_WIDTH` are new in v.1.3. Before, a frame put in a scroll box got a height (width) of 50 unless the configuration procedure set one.
:::

## Column

```pascal
Col
.AddFrame<TTextFrame>(40
, procedure (Text: TTextFrame)
  begin
    Text.SetContent('Settings').SetFontSize(22);
  end
)
.AddFrame<THorzDividerFrame>(1)
.AddFrame<TEditFrame>(90
, procedure (Edit: TEditFrame)
  begin
    Edit.SetCaption('Server').SetText('https://example.com');
  end
)
.AddFrame<TButtonFrame>(60
, procedure (Button: TButtonFrame)
  begin
    Button.SetText('Save');
  end
)
.SetPadding(10);   // padding of the whole column (form helper)
```

Each element fades in, because the default `ElementStand` of a column is `fadeIn`.

## A scrolling column

Columns do not scroll by themselves. Put the column in a `TVertScrollFrame`: its height is the sum of the element heights, so the scroll box knows how far to scroll.

```pascal
Scaffold.SetContentAsFrame<TVertScrollFrame>(
  procedure (Scroll: TVertScrollFrame)
  begin
    Scroll
    .SetTouchWidth(30)
    .SetContentAsForm<TColumnForm>(
      procedure (Col: TColumnForm)
      begin
        for var I := 1 to 20 do
          Col.AddFrame<TTextFrame>(50
          , procedure (Text: TTextFrame)
            begin
              Text.SetContent('Row ' + I.ToString);
            end
          );
      end
    );
  end
);
```

`TouchWidth` is a padding on the right side of the scroll box (50 by default): a strip where a finger can drag the content without hitting an element. Set it to 0 on desktop-only apps.

::: warning Capturing loop variables
In the example above every closure captures the **same** `I`, but each closure runs immediately (inside `AddFrame`), so each text gets the right value. A closure that runs *later* (a click handler) would see the last value: copy the loop variable into a local declared inside the loop, or build the handler in a separate function.
:::

## Row

```pascal
Row
.AddFrame<TButtonFrame>(100
, procedure (B: TButtonFrame) begin B.SetText('One'); end)
.AddFrame<TButtonFrame>(100
, procedure (B: TButtonFrame) begin B.SetText('Two'); end)
.AddFrame<TButtonFrame>(100
, procedure (B: TButtonFrame) begin B.SetText('Three'); end);
```

A row inside a column is the usual way to place elements side by side: `Col.AddForm<TRowForm>(75, procedure (Row: TRowForm) ...)`. Call `Row.SetElementAlign(TAlignLayout.Right)` before adding elements to fill the row from the right. For a horizontally scrolling row, put it in a `THorzScrollFrame`.

## Layers: stack

`TStackFrame` puts its elements one on top of the other, each filling the frame. The home screens of the HelloWorld and QRCode demos use it for a background, an animation and the content:

```pascal
Scaffold.SetContentAsFrame<TStackFrame>(
  procedure (Stack: TStackFrame)
  begin
    Stack
    .AddFrame<TBackgroundFrame>(
      procedure (Back: TBackgroundFrame)
      begin
        Back.SetFillColor(TAlphaColorRec.White);
      end
    )
    .AddFrame<TAnimatedImageFrame>(
      procedure (Anim: TAnimatedImageFrame)
      begin
        Anim
        .LoadFromFile(LocalFile('85570-background-animation-for-a-simple-project.json'))
        .SetWrapMode(TSkAnimatedImageWrapMode.FitCrop)
        .SetOpacity(0.33);
      end
    )
    .AddFrame<TVertScrollFrame>(
      procedure (Scroll: TVertScrollFrame)
      begin
        Scroll.SetContentAsForm<TColumnForm>(
          procedure (Col: TColumnForm)
          begin
            // the screen content
          end
        );
      end
    );
  end
);
```

Layers added later are on top. Each layer can be closed by name: `AddFrame<T>(AConfigProc, 'name')` and `CloseFrame('name')` (layers without a name are called `layer0`, `layer1`...).

## Side by side: accessory and pair

`TAccessoryFrame` has a content area with optional fixed-width elements on the left and on the right — a list row with an icon, a field with a button:

```pascal
Col.AddFrame<TAccessoryFrame>(70
, procedure (Accessory: TAccessoryFrame)
  begin
    Accessory
    .SetLeftAsFrame<TIconFontsGlyphFrame>(50
    , procedure (Glyph: TIconFontsGlyphFrame)
      begin
        Glyph.SetIcon(IconFonts.MD.qrcode_scan, TAppColors.PrimaryColor);
      end
    )
    .SetContentAsFrame<TButtonFrame>(
      procedure (Button: TButtonFrame)
      begin
        Button.SetText('Read a QR code');
      end
    )
    .SetPadding(10);
  end
);
```

`THorzPairFrame` splits its area in two halves that scale with it:

```pascal
Col.AddFrame<THorzPairFrame>(60
, procedure (Pair: THorzPairFrame)
  begin
    Pair.SetContentAsFrame<TButtonFrame, TButtonFrame>(
      procedure (Left: TButtonFrame) begin Left.SetText('Cancel'); end
    , procedure (Right: TButtonFrame) begin Right.SetText('OK'); end
    );
  end
);
```

## Centered, framed, spaced

| Need | Use |
|---|---|
| an element of fixed size in the middle of the screen | `TCenterForm.SetContentAsFrame<T>(AWidth, AHeight, ...)` |
| a colored or bordered background behind an element | `TBackgroundFrame` / `TBackgroundForm` (`SetFillColor`, `SetStrokeColor`, `SetStrokeThickness`) |
| a titled box | `TCardFrame` (title bar, optional glyphs, content) |
| space around or inside an element | `TMarginFrame` / `TPaddingFrame` / `TContainerFrame` + `SetMargin`/`SetPadding` (see the MarginAndPadding demo) |
| a thin horizontal line | `THorzDividerFrame` in a 1-pixel slot |
| any FMX control as an element | `TContainerFrame.SetContentAs<T: TFmxObject>` creates a `T` inside an empty frame |

```pascal
Col.AddFrame<TContainerFrame>(60
, procedure (Container: TContainerFrame)
  begin
    Container.SetContentAs<TSwitch>(
      procedure (Switch: TSwitch)
      begin
        Switch.Align := TAlignLayout.Right;
        Switch.IsChecked := True;
      end
    );
  end
);
```

## Responsive tips

- Compute sizes from the container when the configuration procedure runs: `Col.AddFrame<TLogoFrame>(Col.Width, ...)` makes a square logo (MarginAndPadding demo), `Scaffold.Width` gives the screen width (QRCode demo).
- Sizes are computed once. For layouts that must react to rotation or resizing, handle `TVertScrollFrame.OnResizedProc`, or rebuild the route (`CloseRoute` + `RouteTo`).
- For long or data-driven lists use [TListViewFrame](/elements/lists): it virtualizes its items, a column does not.
