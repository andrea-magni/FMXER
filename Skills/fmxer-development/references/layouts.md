# Layouts: containers, sizing, scaffold, lists, styling

Docs: https://andrea-magni.github.io/FMXER/guide/layouts, /elements/containers, /elements/scaffold, /elements/lists, /guide/styling

## Slots

Every slot method (`SetContentAsFrame<T>`, `AddFrame<T>`, `SetLeftAsFrame<T>`...) does: create a `T` with the container's `TFrameStand`/`TFormStand` in the slot layout, inside the slot's stand → call the configuration procedure (optional: `Scaffold.SetContentAsFrame<TLogoFrame>;`) → show it (stand `OnShow*` animations) → keep the `TSubjectInfo`. Frames go through `...AsFrame<T: TFrame>`, forms through `...AsForm<T: TForm>` (the form's controls are moved into the slot). Any `TFrame`/`TForm` works, not only FMXER ones.

## Sizing: top-down

FMXER has no measure pass like Flutter: pass the size, or (v.1.3+) `AUTO_HEIGHT`/`AUTO_WIDTH` for the element's own size.

| Container | Rule |
|---|---|
| `TColumnForm` | `AddFrame<T>(AHeight)` adds a slot of `AHeight` (default 200) aligned Top, as wide as the column; `TColumnForm.AUTO_HEIGHT`: the element's height (design, or set in the configuration procedure, margins included; a form element: its `Height`, so a nested column measures itself); the column's `Height` grows by the slot |
| `TRowForm` | `AddFrame<T>(AWidth)` adds a slot of `AWidth` (default 200) aligned `ElementAlign` (Left; `SetElementAlign(TAlignLayout.Right)` before adding fills from the right); `TRowForm.AUTO_WIDTH`: the element's width; `Width` grows |
| `TVertScrollFrame` / `TVertScrollForm` | content aligned Top, keeps its own `Height` (a frame: its design height or the one set in the configuration procedure; before v.1.3 a frame got 50): a column inside scrolls |
| `THorzScrollFrame` | content aligned Left, keeps its own `Width`: a row inside scrolls |
| `TCenterForm` | content gets `AWidth` x `AHeight`, centered |
| everything else | the child fills the slot (`Client`) |

A slot is a `TLayout`; the element aligns to it with its own `Align` (built-in elements are `Client`), so the element's margins/paddings apply inside the slot. Compute sizes when the configuration procedure runs (`Col.AddFrame<TLogoFrame>(Col.Width, ...)` = square, `Scaffold.Width` = screen width); they are not recomputed on resize (handle `TVertScrollFrame.OnResizedProc` or rebuild the route).

## Patterns

```pascal
// scrolling column with padding
Scaffold.SetContentAsFrame<TVertScrollFrame>(
  procedure (Scroll: TVertScrollFrame)
  begin
    Scroll
    .SetTouchWidth(30)                    // right strip to drag without hitting elements (default 50; 0 on desktop)
    .SetContentAsForm<TColumnForm>(
      procedure (Col: TColumnForm)
      begin
        Col
        .AddFrame<TTextFrame>(40
        , procedure (Text: TTextFrame)
          begin
            Text.SetContent('Settings').SetFontSize(22).SetFontColor(TAlphaColorRec.Black);
          end)
        .AddFrame<THorzDividerFrame>(1)
        .AddFrame<TEditFrame>(90
        , procedure (Edit: TEditFrame)
          begin
            Edit.SetCaption('Server').SetText('https://example.com');
          end)
        .AddForm<TRowForm>(60                // side by side inside a column
        , procedure (Row: TRowForm)
          begin
            Row.ElementAlign := TAlignLayout.Right;
            Row.AddFrame<TButtonFrame>(120
            , procedure (B: TButtonFrame) begin B.SetText('Save'); end);
          end)
        .SetPadding(10);                     // form helper on the column: nothing chained after it
      end);
  end);

// layers: background, animation, content (later = on top)
Scaffold.SetContentAsFrame<TStackFrame>(
  procedure (Stack: TStackFrame)
  begin
    Stack
    .AddFrame<TBackgroundFrame>(
      procedure (Back: TBackgroundFrame) begin Back.SetFillColor(TAlphaColorRec.White); end)
    .AddFrame<TAnimatedImageFrame>(
      procedure (Anim: TAnimatedImageFrame)
      begin
        Anim.LoadFromFile(LocalFile('anim.json')).SetWrapMode(TSkAnimatedImageWrapMode.FitCrop).SetOpacity(0.33);
        Anim.SetHitTest(False);              // clicks go through
      end, 'anim')                           // named: Stack.CloseFrame('anim')
    .AddFrame<TVertScrollFrame>(
      procedure (Scroll: TVertScrollFrame) begin { content } end);
  end);

// icon + content (list-row like)
Col.AddFrame<TAccessoryFrame>(70
, procedure (Accessory: TAccessoryFrame)
  begin
    Accessory
    .SetLeftAsFrame<TIconFontsGlyphFrame>(50
    , procedure (Glyph: TIconFontsGlyphFrame)
      begin
        Glyph.SetIcon(IconFonts.MD.qrcode_scan, TAppColors.PrimaryColor);
      end)
    .SetContentAsFrame<TButtonFrame>(
      procedure (Button: TButtonFrame) begin Button.SetText('Read a QR code'); end)
    .SetPadding(10);
  end);

// two halves
Col.AddFrame<THorzPairFrame>(60
, procedure (Pair: THorzPairFrame)
  begin
    Pair.SetContentAsFrame<TButtonFrame, TButtonFrame>(
      procedure (Left: TButtonFrame) begin Left.SetText('Cancel'); end
    , procedure (Right: TButtonFrame) begin Right.SetText('OK'); end);
  end);

// any FMX control
Col.AddFrame<TContainerFrame>(60
, procedure (Container: TContainerFrame)
  begin
    Container.SetContentAs<TSwitch>(
      procedure (Switch: TSwitch) begin Switch.Align := TAlignLayout.Right; end);
  end);
```

Other needs: fixed-size centered element → `TCenterForm.SetContentAsFrame<T>(AWidth, AHeight, ...)`; colored/bordered background → `TBackgroundFrame`/`TBackgroundForm` (`SetFillColor`, `SetStrokeColor`, `SetStrokeThickness`; fill is `PrimaryColor` by default); titled box → `TCardFrame` (`SetTitle`, `SetGlyphAsFrame<T>`, `SetContentAsFrame<T>`, chainable since v.1.3); spacing → `TMarginFrame`/`TPaddingFrame`/`TContainerFrame` + `SetMargin`/`SetPadding`; a thin line → `THorzDividerFrame` in a 1-pixel slot.

## TElementDef

Columns, rows and `AddActionButton`/`AddActionButtonOverlayFrame` also accept a definition value (configuration procedure + named parameters):

```pascal
Col.AddFrame<TLogoFrame>(TElementDef<TLogoFrame>.Create(nil, [ Param('Height', 100) ]));

var LBack: TProc := procedure begin Navigator.StackPop; end;
Scaffold.AddActionButton('Back', [ OnClickProc(LBack) ]);   // a variable: inline anonymous method → E2250 on Delphi 13
```

Parameters understood: `Height` (column), `Width` (row), `OnClickProc` (scaffold action buttons). A `TProc<T>` converts implicitly to `TElementDef<T>`.

## Scaffold

`TScaffoldForm`: title bar (64 px, `PrimaryColor`, `TitleLabel` 24 pt in `PrimaryTextColor`), content, action buttons (bottom right, added right to left), snackbar.

```pascal
Scaffold
.SetTitle('Library Store')                          // callable any time (e.g. when data arrives)
.SetContentAsFrame<TListViewFrame>(procedure (List: TListViewFrame) begin end)
.SetTitleDetailContentAsFrame<TBackgroundFrame>(    // laid over the whole title bar: align it yourself
  procedure (Back: TBackgroundFrame)
  begin
    Back.SetContentAsFrame<TActivityBubblesFrame>()
    .SetFillColor(TAlphaColorRec.White)
    .SetMargin(5, 2, 5, 2).SetAlignRight.SetWidth(64);
  end)
.AddActionButton(IconFonts.MD.close, TAppColors.PrimaryTextColor
, procedure begin Navigator.CloseRoute('home'); end)
.AddActionButton('?'
, procedure begin Scaffold.ShowSnackBar('Tap X to close', 2000); end);

Scaffold.HideTitleDetailContent;                      // (ADelay = 0; AThen = nil)
Scaffold.ShowSnackBar('Saved', 3000, procedure begin Navigator.CloseRoute('edit'); end);  // AThen after it is gone
```

Inside the configuration procedure the scaffold variable (`Scaffold`, `Home`) is captured by the handlers: that is how buttons reach the screen.

## Lists

Use `TListViewFrame` (virtualized `TListView`) for long or data-driven lists, not a column of elements.

```pascal
Scaffold.SetContentAsFrame<TListViewFrame>(
  procedure (List: TListViewFrame)
  begin
    List.ItemAppearance := 'ImageListItemBottomDetail';
    List.CanSwipeDelete := False;
    List.ItemBuilderProc :=                 // runs now, on pull-to-refresh and RefreshList (list cleared first)
      procedure
      begin
        for var LBook in Books do
        begin
          var LItem := List.AddItem(LBook.Title, LBook.Author
          , IconFonts.AddIcon(IconFonts.MD.book, TAppColors.PrimaryColor)
          , procedure (const AItem: TListViewItem)
            begin
              Data.SelectedBookId := AItem.Tag;
              Navigator.RouteTo('book');
            end);
          LItem.Tag := LBook.Id;
        end;
      end;
    List.SearchVisible := True;              // SearchText, SetOnSearchChange(TProc)
  end);
```

`uses FMX.ListView.Appearances` for `TListViewItem`. Item images come from `ListView.Images` = `IconFonts.ImageList` unless replaced. Turn pull-to-refresh off with `List.ListView.PullToRefresh := False`.

## Styling

- `TAppColors` (`FMXER.UI.Consts`): `PrimaryColor` (amber 800), `PrimaryTextColor` (white), `SolidBackgroundColor`, `LightBackgroundColor`, `DividerColor`, and `MATERIAL_<HUE>_400/800` constants. Elements read them **when created**: set them in `FormCreate` before the first `RouteTo`; to restyle an open screen, close and reopen its route.
- `TTextFrame` text is `PrimaryTextColor` (white): `SetFontColor` on light backgrounds.
- Element setters cover the common cases; everything else is a published control: `Button.ButtonControl.StyleLookup := 'listitembutton'`, `Edit.EditControl.KeyboardType := TVirtualKeyboardType.EmailAddress`, `List.ListView.Transparent := True`.
- Stands: `TColumnForm.ElementStand` defaults to `fadeIn`; `TRowForm` has `fadeIn` but not as default; `TScaffoldForm` has `snackbar`; others have none. Own stands: `Col.FrameStand1.StandBook := MyStyleBook; Col.FormStand1.StandBook := MyStyleBook; Col.ElementStand := 'slideIn';` then add elements. An unknown stand name gives a plain layout.
- Fonts: `TTextFrame.SetFontFamily` takes any Skia family; register custom fonts with `TSkDefaultProviders.RegisterTypeface`.
