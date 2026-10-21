program FMXERTests;

// DUnitX test suite for FMXER, console runner.
// FMX runs headless enough on Windows for these tests (no form is shown).
//
//   FMXERTests.exe           run all the tests, exit code 0 when all pass
//   FMXERTests.exe --pause   wait for Enter at the end
//
// Built and run by build.cmd in the repository root.

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  FMX.Forms,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.XML.NUnit,
  Tests.Common in 'Tests.Common.pas',
  Tests.Navigator in 'Tests.Navigator.pas',
  Tests.Elements in 'Tests.Elements.pas',
  Tests.Layout in 'Tests.Layout.pas',
  Tests.Design in 'Tests.Design.pas',
  Tests.FormControls in 'Tests.FormControls.pas',
  Tests.ScaffoldNavigation in 'Tests.ScaffoldNavigation.pas',
  Tests.Modals in 'Tests.Modals.pas',
  Tests.RouteState in 'Tests.RouteState.pas',
  Tests.IconFont in 'Tests.IconFont.pas',
  Tests.Observable in 'Tests.Observable.pas',
  Tests.Bindings in 'Tests.Bindings.pas';

var
  LResults: IRunResults;
  LPause: Boolean;
begin
  LPause := FindCmdLineSwitch('pause', ['-', '/'], True);
  try
    Application.Initialize;
    // string assertions are case sensitive (DUnitX ignores case by default)
    Assert.IgnoreCaseDefault := False;
    LResults := TDUnitX.CreateRunner([
      TDUnitXConsoleLogger.Create(True),
      TDUnitXXMLNUnitFileLogger.Create(ChangeFileExt(ParamStr(0), '.xml'))
    ]).Execute;
    if not LResults.AllPassed then
      System.ExitCode := EXIT_ERRORS;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
  if LPause then
  begin
    Write('Press Enter...');
    Readln;
  end;
end.
