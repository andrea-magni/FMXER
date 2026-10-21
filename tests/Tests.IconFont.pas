unit Tests.IconFont;

// The icon font: the web Material Design Icons, found next to the executable
// or in LocalFilesPath, fast to load; no icon drawn without a font.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.IOUtils, System.Diagnostics,
  System.Skia, DUnitX.TestFramework
, FMXER.IconFontsData
, Tests.Common
;

type
  [TestFixture]
  TIconFontFixture = class
  public
    [Test] procedure FontFoundInLocalFilesPath;
    [Test] procedure NoImageWithoutTheFont;
    [Test] procedure RegisterMissingFileFails;
    {$IFDEF MSWINDOWS}
    [Test] procedure InstalledFontDetection;
    {$ENDIF}
    [Test] procedure FirstIconIsFast;
    [Test] procedure WebFontLoadsFast;
  end;

implementation

type
  // access to the cached check, to simulate a machine without the font
  TIconFontsAccess = class(TIconFonts);

{ TIconFontFixture }

procedure TIconFontFixture.FontFoundInLocalFilesPath;
begin
  // the test executable is in build\<ver>\<platform>\tests: four folders below
  // the repository, like the demos, so LocalFilesPath is the media folder
  Assert.IsTrue(TIconFonts.FontFile.EndsWith(ICON_FONTS_FILENAME, True),
    'registered: ' + TIconFonts.FontFile);
  Assert.IsTrue(TFile.Exists(TIconFonts.FontFile));
  Assert.AreEqual(ICON_FONTS_FAMILYNAME, TIconFonts.FontFamily, 'the web font, not the Desktop one');
  Assert.AreEqual(TIconFonts.FontFamily, IconFonts.ImageList.FontName);
  Assert.IsTrue(IconFonts.FontAvailable);
end;

procedure TIconFontFixture.NoImageWithoutTheFont;
begin
  var LAccess := TIconFontsAccess(IconFonts);
  var LCount := IconFonts.ImageList.Count;
  LAccess.FFontChecked := True;
  LAccess.FFontAvailable := False;
  try
    Assert.IsFalse(IconFonts.FontAvailable);
    // a code point never added before: not in the cache
    Assert.AreEqual(-1, IconFonts.AddIcon(IconFonts.MD.alpha_z_box, TAlphaColorRec.Fuchsia));
    Assert.AreEqual(LCount, IconFonts.ImageList.Count, 'no image added');
  finally
    LAccess.FFontChecked := False;   // checked again
  end;
  Assert.IsTrue(IconFonts.FontAvailable);
  Assert.IsTrue(IconFonts.AddIcon(IconFonts.MD.alpha_z_box, TAlphaColorRec.Fuchsia) >= 0);
end;

procedure TIconFontFixture.RegisterMissingFileFails;
begin
  var LBefore := TIconFonts.FontFile;
  Assert.IsFalse(TIconFonts.RegisterFontFile('C:\no\such\folder\font.ttf'));
  Assert.AreEqual(LBefore, TIconFonts.FontFile, 'unchanged');
end;

{$IFDEF MSWINDOWS}
procedure TIconFontFixture.InstalledFontDetection;
begin
  Assert.IsTrue(TIconFonts.IsFontInstalled('Arial'));
  Assert.IsFalse(TIconFonts.IsFontInstalled('No Such Font FMXER 42'));
end;
{$ENDIF}

procedure TIconFontFixture.FirstIconIsFast;
begin
  // with the web font, drawing the first icon takes milliseconds (with the
  // Desktop font it took seconds: loading the font)
  var LWatch := TStopwatch.StartNew;
  IconFonts.AddIcon(IconFonts.MD.alpha_y_box, TAlphaColorRec.Olive);
  Assert.IsTrue(LWatch.ElapsedMilliseconds < 1000, LWatch.ElapsedMilliseconds.ToString + ' ms');
end;

procedure TIconFontFixture.WebFontLoadsFast;
begin
  // the reason of the web font: the Desktop .ttf takes seconds to load (its
  // ligature tables), the web one milliseconds
  var LWatch := TStopwatch.StartNew;
  var LTypeface := TSkTypeface.MakeFromFile(TIconFonts.FontFile);
  Assert.IsNotNull(LTypeface);
  Assert.AreEqual(ICON_FONTS_FAMILYNAME, LTypeface.FamilyName);
  Assert.IsTrue(LWatch.ElapsedMilliseconds < 500, LWatch.ElapsedMilliseconds.ToString + ' ms');
end;

initialization
  TDUnitX.RegisterTestFixture(TIconFontFixture);

end.
