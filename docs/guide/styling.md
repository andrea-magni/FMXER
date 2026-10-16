# Styling & Theming

FMXER elements get their look from three places: the **application colors** in `TAppColors`, the **stands** that wrap them, and the **setters** of each element.

## Application colors

`TAppColors` (unit `FMXER.UI.Consts`) holds a handful of class properties that the elements read **when they are created**:

| Property | Default | Used by |
|---|---|---|
| `PrimaryColor` | `MATERIAL_AMBER_800` (`#FF8F00`) | scaffold title bar, action buttons, card title, background frames/forms, chip text and border |
| `PrimaryTextColor` | white | scaffold title, `TTextFrame` text |
| `SolidBackgroundColor` | light gray | chip background |
| `LightBackgroundColor` | silver | card content |
| `DividerColor` | `MATERIAL_GREY_800` | `THorzDividerFrame` |

Set them once, at startup, before the first route is shown:

```pascal
uses FMXER.UI.Consts;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TAppColors.PrimaryColor := TAppColors.MATERIAL_INDIGO_800;
  TAppColors.PrimaryTextColor := TAlphaColorRec.White;

  Navigator(FormStand1);
  // ...
end;
```

`TAppColors` also declares the Material Design palette at the 400 and 800 shades (`MATERIAL_RED_400` ... `MATERIAL_BLUE_GREY_800`), see the [reference](/reference/app-colors).

::: tip Text color
`TTextFrame` uses `PrimaryTextColor` (white by default) because it is often placed on the primary color: title bars, action buttons, snackbars. On a light background call `SetFontColor`.
:::

Changing a `TAppColors` property affects the elements created **afterwards**. To restyle a screen that is already open, close and reopen its route.

## Stands

A stand is the visual layer between an element and its slot: a fade, a slide, a shadow, a background. FMXER containers come with a few stands in their own style book (`Stands`):

| Container | Stands |
|---|---|
| `TColumnForm`, `TRowForm` | `fadeIn`: the element fades in (`OnShow_FadeIn`) |
| `TScaffoldForm` | `snackbar`: a translucent black band at the bottom; it springs up from the bottom edge (`OnShow_Anim`, elastic) and slides back down (`OnHide_Anim`) |

Choose a stand with the container's stand property (`ElementStand`, `ContentStand`, `TitleDetailStand`, ...) before adding the element. To use **your own stands**, design them in a `TStyleBook` (see [Designing Stands](https://andrea-magni.github.io/TFrameStand/guide/stands)) and give it to the container's stands — they are public fields of every container:

```pascal
Col.FrameStand1.StandBook := MainForm.MyStands;   // a TStyleBook with a 'slideIn' stand
Col.FormStand1.StandBook := MainForm.MyStands;
Col.ElementStand := 'slideIn';
Col.AddFrame<TTextFrame>(50);
```

The routes themselves are shown through the navigator's `TFormStand`: give it a style book and pass a stand name to `DefineRoute<T>(AName, AConfigProc, AParent, AStandName)` to animate whole screens.

## Element setters

Elements expose setters for what is commonly changed: `TTextFrame.SetFontColor`/`SetFontSize`/`SetFontWeight`/`SetFontFamily`/`SetHorzAlign`/`SetMaxLines`, `TButtonFrame.SetBackgroundFillColor`/`SetBackgroundStrokeColor`/`SetBackgroundOpacity`, `TBackgroundFrame.SetFillColor`/`SetStrokeColor`/`SetStrokeThickness`, `TChipFrame.SetBackgroundColor`/`SetForegroundColor`, and so on. Each [element page](/elements/) lists them.

Everything else is reachable: the controls of an element are published fields, so you can always go one level down.

```pascal
Button.ButtonControl.StyleLookup := 'listitembutton';
Edit.EditControl.KeyboardType := TVirtualKeyboardType.EmailAddress;
List.ListView.Transparent := True;
```

## Margins, paddings, alignment

The `TControl` helpers in `FMXER.UI.Misc` set the common layout properties fluently on any element or control:

```pascal
Glyph.SetPadding(5);
Text.SetMargin(10, 0, 10, 0);          // left, top, right, bottom
Logo.SetAlignRight.SetWidth(64);
Bubbles.SetHitTest(False);              // clicks go through
```

Forms have their own helper with `SetPadding`, `SetWidth` and `SetHeight`. See the [helpers reference](/reference/ui-misc#control-helpers).

## Fonts

FMXER uses Skia text (`TSkLabel`) in its text elements. `TTextFrame.SetFontFamily` accepts any family available to Skia; to ship a custom font with the app, deploy it and register it with `TSkDefaultProviders.RegisterTypeface`, as `FMXER.IconFontsData` does for the icon font on Android.
