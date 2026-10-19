# Installation

FMXER has no design-time components: its design-time package only adds FMXER to the splash screen and the About box of the IDE. Your application compiles FMXER's units, so installing FMXER means making its `source` folder (or the compiled units of its runtime packages) and its dependencies reachable by the compiler. Pick one of these ways:

| | What it does | Platforms |
|---|---|---|
| [TMS Smart Setup](#tms-smart-setup) | downloads FMXER, TFrameStand and DelphiZXingQRCode, builds the runtime packages, sets the library path | Win32, Win64 (other platforms: add the source folder) |
| [Setup](#setup) | copies FMXER, builds the runtime packages, sets the library path of every platform | all |
| [Source](#getting-the-source) | clone the repository, add the folders to the search path | all |

## Requirements

| | |
|---|---|
| Delphi | **12 Athens** and **13 Florence**. Delphi 11 is supported up to FMXER v.1.1, see [below](#delphi-11). |
| Platforms | Windows (32/64 bit), macOS (Intel and Apple silicon), iOS (device and Apple silicon simulator), Android (32/64 bit) |
| Framework | FireMonkey only |

## Dependencies

| Library | Used for | Where to get it |
|---|---|---|
| [TFrameStand / TFormStand](https://andrea-magni.github.io/TFrameStand/) | everything: every container shows its children through a `TFrameStand`/`TFormStand` | submodule `lib/TFrameStand`, [GetIt](https://getitnow.embarcadero.com/?q=TFrameStand) or the [setup](https://github.com/andrea-magni/TFrameStand/releases/latest) |
| Skia | text (`TSkLabel`), SVG, Lottie animations, paint boxes, QR code rendering | built into RAD Studio (units `System.Skia`, `FMX.Skia`) |
| [IconFontsImageList](https://github.com/EtheaDev/IconFontsImageList) | the Material Design icon font (`FMXER.IconFontsData`, glyph elements, action buttons with icons) | submodule `lib/IconFontsImageList`, GetIt |
| [DelphiZXingQRCode](https://github.com/foxitsoftware/DelphiZXingQRCode) | QR code encoding (`TQRCodeFrame`) | submodule `lib/DelphiZXingQRCode` |

Demo-only dependencies: [ZXing.Delphi](https://github.com/Spelt/ZXing.Delphi) 4.0 or later (QR code *reading* in the QRCode demo, submodule `lib/ZXing.Delphi`, branch `4.0`), the [MARS-Curiosity](https://github.com/andrea-magni/MARS) REST client (LibraryStore demo) and FireDAC (DataSet demo).

::: tip TFrameStand version
The submodule points to **TFrameStand 2.4**. 2.3 fixed several lifecycle defects of delayed actions and nested stands; 2.4 registers the interactive gestures (zoom, double tap…) of the controls of a frame with the hosting form, so they work on Android. FMXER also compiles with TFrameStand 1.6 (the version of FMXER 1.1), but 2.4 is recommended.
:::

## TMS Smart Setup

[TMS Smart Setup](https://doc.tmssoftware.com/smartsetup/) installs FMXER (id `andreamagni.fmxer`) with its dependencies TFrameStand and DelphiZXingQRCode:

```bash
tms install andreamagni.fmxer
```

::: warning Smart Setup registry
`tms install andreamagni.fmxer` works once FMXER is listed in the [Smart Setup registry](https://github.com/tmssoftware/smartsetup-registry); until then, use the setup or the source.
:::

IconFontsImageList is not a Smart Setup product: install it **before**, from GetIt (*IconFontsImageList*), and Smart Setup finds it in the library path of the IDE. Smart Setup builds the packages for Win32 and Win64 (the platforms of the IconFontsImageList FMX package): for the other platforms add `<FMXER>\source` to the search path of the project, as in [Search path](#search-path).

## Setup

The setup (`FMXER_<version>_Setup.exe`, see the [releases](https://github.com/andrea-magni/FMXER/releases)) copies the library, builds the runtime packages for Win32 and Win64 and adds the source folder to the library path of every platform, for Delphi 12 and 13. It uses the `$(FMXERDIR)` environment variable of the IDE for the paths, like the TFrameStand setup does with `$(TFRAMESTANDDIR)`.

Install the dependencies first: TFrameStand (its [setup](https://github.com/andrea-magni/TFrameStand/releases/latest), GetIt or Smart Setup) and IconFontsImageList (GetIt). The setup checks that their packages are there (`FrameStandPackage.dcp` and `IconFontsImageListFMX.dcp`, in the Dcp folder of the IDE or in the library path) and, if one is missing, stops before installing anything and says what to install. The QR code package is built only when a DelphiZXingQRCode package is installed (Smart Setup builds one); otherwise the QR code units compile from source, with `DelphiZXingQRCode\Source` in the search path.

The setup also copies the libraries the QRCode demo needs, in `lib\DelphiZXingQRCode` and `lib\ZXing.Delphi` (the demos find them through their search path). The LibraryStore demo needs the [MARS-Curiosity](https://github.com/andrea-magni/MARS) client: install MARS with its setup.

The setup installs the icon font (*Material Design Icons Desktop*) for the current user, see [The icon font](#the-icon-font).

Silent install, for every installed Delphi version: `FMXER_<version>_Setup.exe /SILENT /RADStudioVersions=all`.

## Packages

The runtime packages are in `packages\12Athens` and `packages\13Florence` (`FMXER.groupproj`); the setup and Smart Setup build them for you.

| Package | Contains | Requires |
|---|---|---|
| `FMXERPackage` | every unit of `source` but the QR code ones | `rtl`, `fmx`, `Skia.Package.RTL`, `Skia.Package.FMX`, `FrameStandPackage`, `IconFontsImageListFMX` |
| `FMXERQRCodePackage` | `FMXER.QRCodeFrame`, `QRCode.Utils`, `QRCode.Render` | `FMXERPackage`, `DelphiZXingQRCode` |
| `dclFMXERPackage` | `FMXER.Registration` (in `packages\`): FMXER in the splash screen and the About box of the IDE | `rtl`, `vcl`, `vclimg`, `designide` |

`FMXERPackage` and `FMXERQRCodePackage` are runtime only: build them, don't install them in the IDE. `dclFMXERPackage` is design-time only (the setup installs it). The units are compiled to `dcu\<version>\<platform>\<config>`: add that folder to the library path to use the compiled units instead of the source. To build an application *with runtime packages*, add `FMXERPackage` (and `FMXERQRCodePackage`) to the runtime packages list of the project and deploy the `.bpl` files.

## Getting the source

Clone the repository with its submodules:

```bash
git clone --recursive https://github.com/andrea-magni/FMXER.git
```

If you already cloned it without `--recursive`:

```bash
git submodule update --init
```

If TFrameStand and IconFontsImageList are already installed (GetIt, setup, Smart Setup), you only need FMXER's own `source` folder.

The demos use the submodules: each `.dproj` has `..\..\source` and the `lib\` folders in its search path. With empty submodule folders the IDE library path is used, so the demos also build against installed libraries.

## Search path

Add these folders to **Project > Options > Building > Delphi Compiler > Search path** (all platforms), or to **Tools > Options > Language > Delphi > Library > Library path**:

```text
<FMXER>\source
<FMXER>\lib\TFrameStand\source
<FMXER>\lib\IconFontsImageList\Source
<FMXER>\lib\DelphiZXingQRCode\Source
```

Skip the folders of the libraries you have installed in another way.

## Enable Skia

FMXER elements use Skia controls. Enable Skia in the project source, before `Application.Initialize`, as all the demos do:

```pascal
program MyApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Forms.Main in 'Forms.Main.pas' {MainForm};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
```

## Delphi 11

Since v.1.2 FMXER uses the Skia units of RAD Studio (`System.Skia`, `FMX.Skia`, `FMX.Skia.Canvas`), available since Delphi 12. Up to v.1.1 it used [Skia4Delphi](https://github.com/skia4delphi/skia4delphi) for Delphi 11, whose units are named `Skia` and `Skia.FMX`: on Delphi 11 use FMXER v.1.1.

To move a project from FMXER v.1.1 on Delphi 11 to v.1.2 on Delphi 12+, replace `Skia` with `System.Skia`, `Skia.FMX` with `FMX.Skia` and `Skia.FMX.Graphics` with `FMX.Skia.Canvas` in the `uses` clauses: the component classes have the same names, so the `.fmx` files load as they are.

::: details Command-line builds
ZXing.Delphi (QRCode demo) needs the `FRAMEWORK_FMX` define, which MSBuild sets for FMX projects and plain `dcc32` does not. `build.cmd` passes it (see [Building & Testing](./building)).
:::

## The icon font

Elements with icons (`TIconFontsGlyphFrame`, `TScaffoldForm.AddActionButton` with an icon, `TListViewFrame` images) draw glyphs of the **Material Design Icons Desktop** font through a shared `TIconFontsImageList` (see [Icons](/elements/icons)). The font file is in `media\Material Design Icons Desktop.ttf`, and it must be available at runtime:

| Platform | What to do |
|---|---|
| Windows | install the font (double-click the `.ttf`, *Install*; the setup installs it for you), or put the `.ttf` next to the executable: FMXER registers it with Skia at startup |
| macOS | deploy the `.ttf` to `Contents\Resources\Fonts` and add `ATSApplicationFontsPath=Fonts` to the version info keys (as the NewProjectTemplate demo does) |
| iOS | deploy the `.ttf` to the application bundle (remote path `.\`), as the NewProjectTemplate demo does |
| Android | deploy the `.ttf` to `.\assets\internal` for both **Android and Android64** (two deployment entries): FMXER registers it with Skia at startup (`initialization` of `FMXER.IconFontsData`); without it the icons are missing |

Use **Project > Deployment** to add the file; the demos are a working reference.

## Check the installation

Open `demos\AllDemos.groupproj` and run **NewProjectTemplate**: a scaffold with the title *New Project*, the FMXER logo and a floating close button. If it runs, everything is in place — move on to [your first app](./getting-started).
