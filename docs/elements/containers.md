# Containers

Containers arrange other elements. Each one has a `TFrameStand` and a `TFormStand` (public fields `FrameStand1`, `FormStand1`) that create its children, and one or more slots. For how to combine them, see [Composing Layouts](/guide/layouts).

## TColumnForm

Unit `FMXER.ColumnForm`. Elements stacked from top to bottom, each in a slot of fixed height.

```pascal
Col
.AddFrame<TTextFrame>(40, procedure (T: TTextFrame) begin T.SetContent('Title'); end)
.AddFrame<THorzDividerFrame>(1)
.AddForm<TRowForm>(75, procedure (Row: TRowForm) begin { ... } end);
```

| Member | Description |
|---|---|
| `AddFrame<T: TFrame>(AHeight = 200; AConfigProc = nil): TColumnForm` | adds a frame element in a slot `AHeight` high |
| `AddFrame<T>(AColDef: TElementDef<T>)` | same, height from the `Height` param |
| `AddForm<T: TForm>(AHeight = 200; AConfigProc = nil)`, `AddForm<T>(AColDef)` | adds a form element |
| `Elements: TList<TSubjectInfoContainer>` | the slots, in order; `Elements[i].ContainedFrame<T>` returns the element |
| `ElementStand: string` | stand for the next elements (default stand: `fadeIn`) |
| `GetContent: TLayout`, `ContentLayout` | the layout holding the slots |
| `DEFAULT_ELEMENT_HEIGHT = 200` | |

The column's `Height` grows with every element (it starts at 1), so a column in a [TVertScrollFrame](#tvertscrollframe-and-tvertscrollform) scrolls over its whole content.

## TRowForm

Unit `FMXER.RowForm`. The horizontal twin of the column: slots of fixed width, from the left.

| Member | Description |
|---|---|
| `AddFrame<T>(AWidth = 200; AConfigProc = nil): TRowForm`, `AddFrame<T>(AColDef)` | adds a frame element; `Width` param for the definition overload |
| `AddForm<T>(AWidth = 200; AConfigProc = nil)`, `AddForm<T>(AColDef)` | adds a form element |
| `ElementAlign: TAlignLayout` | alignment of the slots, `Left` by default (`Right` fills from the right) |
| `Elements`, `ElementStand`, `GetContent`, `DEFAULT_ELEMENT_WIDTH = 200` | as in the column |

The row's `Width` grows with every element.

## TVertScrollFrame and TVertScrollForm

Units `FMXER.VertScrollFrame`, `FMXER.VertScrollForm`. A `TVertScrollBox` with one element, aligned to the top with its own height — usually a column.

```pascal
Scroll
.SetTouchWidth(0)
.SetContentAsForm<TColumnForm>(
  procedure (Col: TColumnForm)
  begin
    // elements...
  end
);
```

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | the content (functions in the frame, procedures in the form) |
| `TouchWidth` (form) / `GetTouchWidth`, `SetTouchWidth` (frame) | right padding of the scroll box, 50 by default: a strip to scroll with a finger |
| `ContentStand` | stand of the content |
| `OnShowProc`, `OnResizeProc`, `OnResizedProc: TProc<TVertScrollFrame>` | frame only: after show, on resize, after resize |
| `VerticalScrollbox` | the scroll box |

## THorzScrollFrame

Unit `FMXER.HorzScrollFrame`. A `THorzScrollBox` with one element aligned to the left with its own width — usually a row.

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | the content (procedures) |
| `TouchHeight` | bottom padding of the scroll box |
| `ContentStand`, `HorizontalScrollBox` | |

## TStackFrame

Unit `FMXER.StackFrame`. Layers: each element fills the frame, the last added is on top.

| Member | Description |
|---|---|
| `AddFrame<T>(AConfigProc = nil; AName = ''): TStackFrame` | adds a layer; unnamed layers are called `layer0`, `layer1`, ... |
| `CloseFrame(AName)` | hides and closes a layer |
| `DefaultStand` | stand of the layers (the `DefaultStandName` of its frame stand) |

Frames only (no `AddForm`).

## TCenterForm

Unit `FMXER.CenterForm`. One element of a given size in the center of the form.

```pascal
Center.SetContentAsFrame<TQRCodeFrame>(240, 240
, procedure (QR: TQRCodeFrame)
  begin
    QR.SetContent('https://github.com/andrea-magni/FMXER');
  end
);
```

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AWidth, AHeight, AConfigProc): TCenterForm` | |
| `SetContentAsForm<T>(AWidth, AHeight, AConfigProc): TCenterForm` | |
| `ContentStand` | |

## TContainerFrame and TContainerForm

Units `FMXER.ContainerFrame`, `FMXER.ContainerForm`. The simplest container: one element filling a slot. Routes often use `TContainerForm` for screens that are a single element (a full-screen animation, a wait screen).

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | the content (functions in the frame, procedures in the form) |
| `SetContentAs<T: TFmxObject>(AConfigProc): TContainerFrame` | frame only: creates any FMX object `T` (a `TSwitch`, a `TCalendar`, a `TMapView`...) inside an empty frame |
| `Content: TSubjectInfo`, `ContentStand` | |

```pascal
Navigator.DefineRoute<TContainerForm>('bubbles'
, procedure (Form: TContainerForm)
  begin
    Form.SetContentAsFrame<TActivityBubblesFrame>;
  end
);
```

## TMarginFrame and TPaddingFrame

Units `FMXER.MarginFrame`, `FMXER.PaddingFrame`. Both are `TContainerFrame` descendants with nothing added: their name says what you will set on them. The MarginAndPadding demo shows the difference:

```pascal
.AddFrame<TMarginFrame>(ACol.Width
, procedure (AM: TMarginFrame)
  begin
    AM.SetContentAsFrame<TLogoFrame>.SetMargin(50);    // space outside the frame
  end
)
.AddFrame<TPaddingFrame>(ACol.Width
, procedure (AP: TPaddingFrame)
  begin
    AP.SetContentAsFrame<TLogoFrame>.SetPadding(50);   // space inside the frame
  end
)
```

## TBackgroundFrame and TBackgroundForm

Units `FMXER.BackgroundFrame`, `FMXER.BackgroundForm`. One element on a `TRectangle` filled with `PrimaryColor`.

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | the content, inside the rectangle |
| `SetFillColor(AColor)`, `SetStrokeColor(AColor)`, `SetStrokeThickness(AThickness)` | fluent setters |
| `Fill: TBrush`, `Stroke: TStrokeBrush` | the rectangle's brushes, for gradients and bitmaps |
| `Content`, `ContentStand`, `BackgroundRectangle` | |

`TBackgroundFrame` forwards `HitTest` to the rectangle, so `SetHitTest(False)` makes it click-through.

## TAccessoryFrame

Unit `FMXER.AccessoryFrame`. A content area with optional fixed-width accessories on the left and on the right (hidden until set).

| Member | Description |
|---|---|
| `SetContentAsFrame<T>(AConfigProc)`, `SetContentAsForm<T>(AConfigProc)` | the content |
| `SetLeftAsFrame<T>(AWidth, AConfigProc)`, `SetLeftAsForm<T>(AWidth, AConfigProc)` | the left accessory, `AWidth` wide |
| `SetRightAsFrame<T>(AWidth, AConfigProc)`, `SetRightAsForm<T>(AWidth, AConfigProc)` | the right accessory |
| `SetContentStand`, `SetLeftStand`, `SetRightStand` (and the properties `ContentStand`, `LeftStand`, `RightStand`) | stands |

All the methods return the frame. Example in [Composing Layouts](/guide/layouts#side-by-side-accessory-and-pair).

## THorzPairFrame

Unit `FMXER.HorzPairFrame`. Two halves that scale with the frame (`Align = Scale`).

| Member | Description |
|---|---|
| `SetLeftContentAsFrame<T>(AConfigProc)`, `SetLeftContentAsForm<T>(AConfigProc)` | left half |
| `SetRightContentAsFrame<T>(AConfigProc)`, `SetRightContentAsForm<T>(AConfigProc)` | right half |
| `SetContentAsFrame<T1, T2>(ALeftConfigProc, ARightConfigProc)`, `SetContentAsForm<T1, T2>(...)` | both at once |
| `SetLeftContentStand(AStandName)`, `SetRightContentStand(AStandName)` (and `GetLeftContentStand`, `GetRightContentStand`) | stands of the halves; set them before the content (they were ignored up to v.1.1) |

## TCardFrame

Unit `FMXER.CardFrame`. A card: a title bar in `PrimaryColor` with optional glyphs on the left and right, and a content area in `LightBackgroundColor`.

```pascal
Col.AddFrame<TCardFrame>(150
, procedure (Card: TCardFrame)
  begin
    Card.Title := 'Today';
    Card.SetGlyphAsFrame<TIconFontsGlyphFrame>(
      procedure (Glyph: TIconFontsGlyphFrame)
      begin
        Glyph.SetIcon(IconFonts.MD.weather_sunny, TAlphaColorRec.White);
      end
    );
    Card.SetContentAsFrame<TTextFrame>(
      procedure (Text: TTextFrame)
      begin
        Text.SetContent('Sunny, 24°').SetFontColor(TAlphaColorRec.Black);
      end
    );
  end
);
```

| Member | Description |
|---|---|
| `Title: string` | title text (a `TTextFrame` in the title bar) |
| `SetGlyphAsFrame<T>`, `SetGlyphAsForm<T>` | left glyph (50 px) |
| `SetGlyphRAsFrame<T>`, `SetGlyphRAsForm<T>` | right glyph |
| `SetContentAsFrame<T>`, `SetContentAsForm<T>` | content |
| `ContentStand`, `GlyphStand`, `GlyphRStand` | stands |
| `Detail: string` | stored, not displayed (v.1.1) |

The slot methods of the card are procedures (not chainable).

## THorzDividerFrame

Unit `FMXER.HorzDividerFrame`. A horizontal `TLine` in `TAppColors.DividerColor`. Give it a 1-pixel slot: `Col.AddFrame<THorzDividerFrame>(1)`.

## TSubjectInfoContainer

Unit `FMXER.UI.Misc`. The `TLayout` used as slot by columns and rows; it keeps the `TSubjectInfo` of its element:

```pascal
var LText := Col.Elements[0].ContainedFrame<TTextFrame>;
if Assigned(LText) then
  LText.SetContent('Updated');
```
