# TAppColors

Unit `FMXER.UI.Consts`. Application colors read by the elements when they are created, and the Material Design palette. See [Styling & Theming](/guide/styling).

## Application colors

| Class property | Default | Read by |
|---|---|---|
| `PrimaryColor` | `MATERIAL_AMBER_800` | `TScaffoldForm` (title bar), `TActionButtonFrame` (circle), `TCardFrame` (title bar), `TBackgroundFrame`/`TBackgroundForm` (fill), `TChipFrame` (text and border) |
| `PrimaryTextColor` | `TAlphaColorRec.White` | `TScaffoldForm` (title), `TTextFrame` (text) |
| `SolidBackgroundColor` | `TAlphaColorRec.Lightgray` | `TChipFrame` (fill) |
| `LightBackgroundColor` | `TAlphaColorRec.Silver` | `TCardFrame` (content) |
| `DividerColor` | `MATERIAL_GREY_800` | `THorzDividerFrame` |

The defaults are set by the class constructor of `TAppColors`. Assign new values before the elements are created (typically before the first `RouteTo`).

## Material Design palette

Constants of type `TAlphaColor`, shades 400 and 800 of the [Material Design 2014 palette](https://m2.material.io/design/color/the-color-system.html):

| Hue | 400 | 800 |
|---|---|---|
| Red | `MATERIAL_RED_400` `#EF5350` | `MATERIAL_RED_800` `#C62828` |
| Pink | `MATERIAL_PINK_400` `#EC407A` | `MATERIAL_PINK_800` `#AD1457` |
| Purple | `MATERIAL_PURPLE_400` `#AB47BC` | `MATERIAL_PURPLE_800` `#6A1B9A` |
| Deep Purple | `MATERIAL_DEEP_PURPLE_400` `#7E57C2` | `MATERIAL_DEEP_PURPLE_800` `#4527A0` |
| Indigo | `MATERIAL_INDIGO_400` `#5C6BC0` | `MATERIAL_INDIGO_800` `#283593` |
| Blue | `MATERIAL_BLUE_400` `#42A5F5` | `MATERIAL_BLUE_800` `#1565C0` |
| Light Blue | `MATERIAL_LIGHT_BLUE_400` `#29B6F6` | `MATERIAL_LIGHT_BLUE_800` `#0277BD` |
| Cyan | `MATERIAL_CYAN_400` `#26C6DA` | `MATERIAL_CYAN_800` `#00838F` |
| Teal | `MATERIAL_TEAL_400` `#26A69A` | `MATERIAL_TEAL_800` `#00695C` |
| Green | `MATERIAL_GREEN_400` `#66BB6A` | `MATERIAL_GREEN_800` `#2E7D32` |
| Light Green | `MATERIAL_LIGHT_GREEN_400` `#9CCC65` | `MATERIAL_LIGHT_GREEN_800` `#558B2F` |
| Lime | `MATERIAL_LIME_400` `#D4E157` | `MATERIAL_LIME_800` `#9E9D24` |
| Yellow | `MATERIAL_YELLOW_400` `#FFEE58` | `MATERIAL_YELLOW_800` `#F9A825` |
| Amber | `MATERIAL_AMBER_400` `#FFCA28` | `MATERIAL_AMBER_800` `#FF8F00` |
| Orange | `MATERIAL_ORANGE_400` `#FFA726` | `MATERIAL_ORANGE_800` `#EF6C00` |
| Deep Orange | `MATERIAL_DEEP_ORANGE_400` `#FF7043` | `MATERIAL_DEEP_ORANGE_800` `#D84315` |
| Brown | `MATERIAL_BROWN_400` `#8D6E63` | `MATERIAL_BROWN_800` `#4E342E` |
| Grey | `MATERIAL_GREY_400` `#BDBDBD` | `MATERIAL_GREY_800` `#424242` |
| Blue Grey | `MATERIAL_BLUE_GREY_400` `#78909C` | `MATERIAL_BLUE_GREY_800` `#37474F` |

All the constants are fully opaque (`$FF` alpha).
