@echo off
REM ==========================================================================
REM  FMXER - build and test (Win32 with dcc32, Win64 with dcc64)
REM
REM  build.cmd [version] [platform] [demos]
REM
REM    version   Delphi version: 13 (default), 12
REM    platform  win32 (default), win64, or all (win32 and win64)
REM    demos     also build the demo projects
REM
REM  The arguments can be given in any order. For each platform: every unit
REM  of source\, the DUnitX test suite (built and run) [, the demos].
REM  Everything is written under build\<version>\<platform>: the .res files of
REM  the projects are not touched. Exit code 0 when every step succeeds.
REM
REM  Dependencies: the submodules in lib\ by default; set these variables to
REM  use other folders (e.g. installed libraries):
REM    FMXER_TFRAMESTAND  TFrameStand source        (lib\TFrameStand\source)
REM    FMXER_IFIL         IconFontsImageList source (lib\IconFontsImageList\Source)
REM    FMXER_ZXINGQR      DelphiZXingQRCode source  (lib\DelphiZXingQRCode\Source)
REM    FMXER_ZXING        ZXing.Delphi Lib\Classes  (lib\ZXing.Delphi\Lib\Classes), QRCode demo
REM    FMXER_MARS         MARS-Curiosity source     (no default), LibraryStore demo
REM  Skia is the one built into Delphi 12+ (System.Skia, FMX.Skia).
REM ==========================================================================
setlocal EnableDelayedExpansion

set "ROOT=%~dp0"
set "VER="
set "PLATFORMS="
set "DEMOS="
:args
if "%~1"=="" goto argsdone
set "OK="
if /i "%~1"=="demos" set "DEMOS=1" & set "OK=1"
if /i "%~1"=="win32" set "PLATFORMS=Win32" & set "OK=1"
if /i "%~1"=="win64" set "PLATFORMS=Win64" & set "OK=1"
if /i "%~1"=="all" set "PLATFORMS=Win32 Win64" & set "OK=1"
if "%~1"=="13" set "VER=13" & set "OK=1"
if "%~1"=="12" set "VER=12" & set "OK=1"
if not defined OK (
  echo Unknown argument "%~1": use 13 or 12, win32, win64 or all, demos
  exit /b 2
)
shift
goto args
:argsdone
if not defined VER set "VER=13"
if not defined PLATFORMS set "PLATFORMS=Win32"
if "%VER%"=="13" set "BDSVER=37.0"
if "%VER%"=="12" set "BDSVER=23.0"
set "BDS=%ProgramFiles(x86)%\Embarcadero\Studio\%BDSVER%"
set "BIN=%BDS%\bin"
if not exist "%BIN%\dcc32.exe" (
  echo Delphi %VER% not found: "%BIN%"
  exit /b 2
)

if not defined FMXER_TFRAMESTAND set "FMXER_TFRAMESTAND=%ROOT%lib\TFrameStand\source"
if not defined FMXER_IFIL set "FMXER_IFIL=%ROOT%lib\IconFontsImageList\Source"
if not defined FMXER_ZXINGQR set "FMXER_ZXINGQR=%ROOT%lib\DelphiZXingQRCode\Source"
if not defined FMXER_ZXING set "FMXER_ZXING=%ROOT%lib\ZXing.Delphi\Lib\Classes"

set "Z=%FMXER_ZXING%"
set "ZXPATH=%Z%;%Z%\Common;%Z%\Common\Detector;%Z%\Common\ReedSolomon;%Z%\Filtering;%Z%\1D Barcodes;%Z%\2D Barcodes;%Z%\2D Barcodes\Detector;%Z%\2D Barcodes\Decoder"
set "MARSPATH="
if defined FMXER_MARS set "MARSPATH=%FMXER_MARS%;%FMXER_MARS%\..\ThirdParty\delphi-jose-jwt\Source\Common;%FMXER_MARS%\..\ThirdParty\delphi-jose-jwt\Source\JOSE"

set "SEARCH=%ROOT%source;%FMXER_TFRAMESTAND%;%FMXER_IFIL%;%FMXER_ZXINGQR%;%BDS%\source\DUnitX"
set "NS=-NSSystem;Xml;Data;Datasnap;Web;Soap;FMX;System.Win;Winapi"

set "ERRORS=0"
if not exist "%ROOT%build\%VER%" mkdir "%ROOT%build\%VER%"
set "SUMMARY=%ROOT%build\%VER%\summary.txt"
if exist "%SUMMARY%" del "%SUMMARY%"

for %%L in (%PLATFORMS%) do call :platform %%L

echo.
echo === Summary
type "%SUMMARY%"
if %ERRORS% GTR 0 (
  echo %ERRORS% step^(s^) failed
  exit /b 1
)
echo All steps succeeded
exit /b 0

REM --- :platform <Win32|Win64> ---------------------------------------------
:platform
set "PLAT=%~1"
if /i "%PLAT%"=="Win64" (set "DCC=%BIN%\dcc64.exe") else (set "DCC=%BIN%\dcc32.exe")
set "OUT=%ROOT%build\%VER%\%PLAT%"
if not exist "%OUT%" mkdir "%OUT%"

echo.
echo === FMXER build, Delphi %VER% (BDS %BDSVER%), %PLAT%, output: %OUT%

REM every unit of source\
set "CHECK=%OUT%\check"
if not exist "%CHECK%\dcu" mkdir "%CHECK%\dcu"
> "%CHECK%\FMXERCheck.dpr" echo program FMXERCheck;
>> "%CHECK%\FMXERCheck.dpr" echo uses
for %%F in ("%ROOT%source\*.pas") do >> "%CHECK%\FMXERCheck.dpr" echo   %%~nF,
>> "%CHECK%\FMXERCheck.dpr" echo   FMX.Forms;
>> "%CHECK%\FMXERCheck.dpr" echo begin
>> "%CHECK%\FMXERCheck.dpr" echo end.
call :compile "%CHECK%" FMXERCheck.dpr "%CHECK%" "%PLAT% source units" "-DFRAMEWORK_FMX"

REM tests
set "TESTS=%OUT%\tests"
if not exist "%TESTS%\dcu" mkdir "%TESTS%\dcu"
if exist "%TESTS%\FMXERTests.exe" del "%TESTS%\FMXERTests.exe"
call :compile "%ROOT%tests" FMXERTests.dpr "%TESTS%" "%PLAT% tests: build" "-DFRAMEWORK_FMX"
if exist "%TESTS%\FMXERTests.exe" (
  echo --- %PLAT% tests: run
  "%TESTS%\FMXERTests.exe" > "%TESTS%\FMXERTests.log" 2>&1
  if errorlevel 1 (
    set /a ERRORS+=1
    echo FAILED  %PLAT% tests: run, see %TESTS%\FMXERTests.log>> "%SUMMARY%"
    type "%TESTS%\FMXERTests.log"
  ) else (
    echo ok      %PLAT% tests: run>> "%SUMMARY%"
  )
)

REM demos
if defined DEMOS (
  REM *.dpr also matches the .dproj files (8.3 names): check the extension
  for /r "%ROOT%demos" %%P in (*.dpr) do if /i "%%~xP"==".dpr" (
    set "DEMOOUT=%OUT%\demos\%%~nP"
    if not exist "!DEMOOUT!\dcu" mkdir "!DEMOOUT!\dcu"
    call :compile "%%~dpP" "%%~nxP" "!DEMOOUT!" "%PLAT% demo %%~nP" "-DFRAMEWORK_FMX;SKIA"
  )
)
exit /b 0

REM --- :compile <folder> <dpr> <outdir> <label> <defines> ------------------
:compile
echo --- %~4
pushd "%~1"
"%DCC%" -B -Q "%~5" "%NS%" "-U%SEARCH%;%ZXPATH%;%MARSPATH%" "-I%SEARCH%" "-R%SEARCH%" "-NU%~3\dcu" "-E%~3" %2 > "%~3\%~n2.compile.log" 2>&1
if errorlevel 1 (
  set /a ERRORS+=1
  echo FAILED  %~4, see %~3\%~n2.compile.log>> "%SUMMARY%"
  findstr /i /c:"error" /c:"fatal" "%~3\%~n2.compile.log"
) else (
  echo ok      %~4>> "%SUMMARY%"
)
popd
exit /b 0
