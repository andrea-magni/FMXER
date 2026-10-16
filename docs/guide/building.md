# Building & Testing

The repository has a build script and a DUnitX test suite, used to check every change on the command line.

## build.cmd

```bash
build.cmd 13 all demos
```

| Argument | Meaning |
|---|---|
| version | Delphi version: `13` (default), `12` |
| platform | `win32` (default, `dcc32`), `win64` (`dcc64`), `all` (both) |
| `demos` | also build every demo project |

The arguments can be given in any order. For each platform the script compiles:

1. every unit of `source\` (a generated program that uses them all);
2. the test suite `tests\FMXERTests.dpr`, then runs it;
3. with `demos`, every `.dpr` under `demos\`.

Everything is written under `build\<version>\<platform>` (ignored by git): the projects and their `.res` files are not touched. At the end it prints a summary of every step of every platform (also in `build\<version>\summary.txt`); the exit code is 0 when every step succeeded. Each step has its log (`*.compile.log`, `FMXERTests.log`) next to its output.

Run `build.cmd all demos` before a release: Win64 catches what Win32 hides, such as `Length` and `Count` being `NativeInt` there (the tests compare them with `Assert.AreEqual<NativeInt>`).

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
build\13\Win32\tests\FMXERTests.exe --pause
```

A NUnit-style XML report (`FMXERTests.xml`) is written next to the executable.

To test a new defect, add a test that fails first, then fix the code: the tests of v.1.2 were written this way, and 11 of the 21 fail on v.1.1.
