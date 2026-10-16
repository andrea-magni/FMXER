# Building & Testing

The repository has a build script and a DUnitX test suite, used to check every change on the command line.

## build.cmd

```bash
build.cmd 13 demos
```

| Argument | Meaning |
|---|---|
| version | Delphi version: `13` (default), `12` |
| `demos` | also build every demo project |

The script compiles, for Win32 with `dcc32`:

1. every unit of `source\` (a generated program that uses them all);
2. the test suite `tests\FMXERTests.dpr`, then runs it;
3. with `demos`, every `.dpr` under `demos\`.

Everything is written under `build\<version>` (ignored by git): the projects and their `.res` files are not touched. At the end it prints a summary; the exit code is 0 when every step succeeded. Each step has its log (`*.compile.log`, `FMXERTests.log`) next to its output.

### Dependencies

By default the script uses the submodules in `lib\`. To use other folders — installed libraries, other clones — set these environment variables first:

| Variable | Default |
|---|---|
| `FMXER_TFRAMESTAND` | `lib\TFrameStand\source` |
| `FMXER_IFIL` | `lib\IconFontsImageList\Source` |
| `FMXER_ZXINGQR` | `lib\DelphiZXingQRCode\Source` |
| `FMXER_ZXING` | `lib\ZXing.Delphi\Lib\Classes` (QRCode demo) |
| `FMXER_MARS` | none: the MARS-Curiosity `Source` folder (LibraryStore demo) |

## The test suite

`tests\FMXERTests.dpr` is a DUnitX console program. FMX runs headless enough on Windows for the tests: forms and frames are created and shown through their stands, but no window appears. Timers and delayed actions are pumped by a small loop (`Tests.Common.Pump`).

| Unit | Covers |
|---|---|
| `Tests.Navigator` | routes, stack and breadcrumb, `StackPop`, transient routes, `CloseAllRoutes`/`CloseAllRoutesExcept`, events, delayed routing |
| `Tests.Elements` | scaffold action buttons and snackbar, pair stands, card glyph, icon font cache, list view refresh and item handlers, form helpers |

Run it from the IDE or directly:

```bash
build\13\tests\FMXERTests.exe --pause
```

A NUnit-style XML report (`FMXERTests.xml`) is written next to the executable.

To test a new defect, add a test that fails first, then fix the code: the tests of v.1.2 were written this way, and 11 of the 21 fail on v.1.1.

## Packages

`packages\12Athens` and `packages\13Florence` hold the runtime packages (`FMXERPackage`, `FMXERQRCodePackage`, see [Installation](./installation#packages)) and `FMXER.groupproj`. Build them from the IDE or with MSBuild; to keep the IDE's own `Bpl` and `Dcp` folders untouched (where the installed packages are), pass the output folders:

```bash
msbuild packages\13Florence\FMXERPackage.dproj /p:Config=Release /p:Platform=Win64 /p:DCC_BplOutput=C:\Temp\fmxer\bpl /p:DCC_DcpOutput=C:\Temp\fmxer\dcp /p:DCC_DcuOutput=C:\Temp\fmxer\dcu
```

A new unit in `source\` goes in both packages folders: `FMXERPackage`, or `FMXERQRCodePackage` when it uses DelphiZXingQRCode.

## The setup

`setup\build-setup.cmd` builds `build\setup\FMXER_<version>_Setup.exe` with Inno Setup 6, from a clean export of `HEAD` (committed files only). The setup is based on the same Ethea InnoSetup library as the TFrameStand and MARS-Curiosity setups; the version is `LibraryVersion` in `setup\Setup.iss` (and `version.txt` for TMS Smart Setup, see `tmsbuild.yaml`).
