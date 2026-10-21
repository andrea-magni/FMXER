unit FMXER.IconFontsData;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList, System.Generics.Collections,
  FMX.IconFontsImageList, System.UITypes, Icons.MaterialDesign, Icons.Utils;

const
  /// <summary>The icon font: the web version of Material Design Icons. Its
  /// .ttf loads in milliseconds.</summary>
  ICON_FONTS_FAMILYNAME = 'Material Design Icons';
  ICON_FONTS_FILENAME = ICON_FONTS_FAMILYNAME + '.ttf';
  /// <summary>The font of FMXER up to v.1.7, still used when the web font is
  /// not found: same icons, but its .ttf (with a ligature for every icon name)
  /// takes seconds to load with Skia, and every app pays it at startup.</summary>
  ICON_FONTS_DESKTOP_FAMILYNAME = 'Material Design Icons Desktop';
  ICON_FONTS_DESKTOP_FILENAME = ICON_FONTS_DESKTOP_FAMILYNAME + '.ttf';

type
  TIconFonts = class(TDataModule)
    ImageList: TIconFontsImageList;
  private
    FCount: Integer;
    FIndexes: TDictionary<UInt64, Integer>; // (code point, color) -> image index
  private
    class var _Instance: TIconFonts;
    class var FFontFile: string;
    class var FFontFamily: string;
    class var FFontFound: Boolean;
    class function GetIconFonts: TIconFonts; static;
    class procedure FontSelected; static;
  protected
    FFontChecked: Boolean;
    FFontAvailable: Boolean;
    FMissingFontLogged: Boolean;
    function GetMD: TMaterialDesign;
    /// <summary>The font is usable: registered by FMXER (FontFile) or, on
    /// Windows, installed. On macOS, iOS and Linux it is assumed to be.</summary>
    function DetectFontAvailable: Boolean; virtual;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddIcon(const AIcon: TIconEntry): Integer; overload;
    function AddIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): Integer; overload;
    function AddIcon(const ACodePoint: Integer): Integer; overload;
    function AddIcon(const ACodePoint: Integer; const AColor: TAlphaColor): Integer; overload;

    /// <summary>The icon font can be used (checked once). Without it, AddIcon
    /// returns -1 and adds no image: an icon of a missing font is drawn as an
    /// empty box, after the system looked for its code point in the installed
    /// fonts.</summary>
    function FontAvailable: Boolean;
    /// <summary>Registers a .ttf of the icon font with Skia and uses its family
    /// for the icons (FMXER does it at startup: see FontFamily). False when the
    /// file does not exist or is not a font.</summary>
    class function RegisterFontFile(const AFileName: string): Boolean; static;
    {$IFDEF MSWINDOWS}
    /// <summary>A font family installed in Windows (for the current user or
    /// for all users).</summary>
    class function IsFontInstalled(const AFamilyName: string): Boolean; static;
    {$ENDIF}
    /// <summary>The .ttf registered by FMXER, empty when none.</summary>
    class property FontFile: string read FFontFile;
    /// <summary>The family of the icons. Chosen at startup, the first found of:
    /// the web font installed (Windows), its .ttf next to the executable or in
    /// LocalFilesPath (Android: in the documents folder), then the same for
    /// the Desktop font of FMXER up to v.1.7 (slow to load).</summary>
    class property FontFamily: string read FFontFamily;

    property MD: TMaterialDesign read GetMD;
    class property Instance: TIconFonts read GetIconFonts;
  end;

function IconFonts: TIconFonts;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF MSWINDOWS}Winapi.Windows,{$ENDIF}
  FMX.Forms, FMX.Types, IOUtils, System.Skia, FMX.Skia, FMXER.UI.Misc;

function IconFonts: TIconFonts;
begin
  Result := TIconFonts.Instance;
end;

{ TIconFontsData }

function TIconFonts.AddIcon(const AIcon: TIconEntry): Integer;
begin
  Result := AddIcon(AIcon.codepoint);
end;

function TIconFonts.AddIcon(const AIcon: TIconEntry;
  const AColor: TAlphaColor): Integer;
begin
  Result := AddIcon(AIcon.codepoint, AColor);
end;

function TIconFonts.AddIcon(const ACodePoint: Integer): Integer;
begin
  Result := AddIcon(ACodePoint, 0);
end;

function TIconFonts.AddIcon(const ACodePoint: Integer;
  const AColor: TAlphaColor): Integer;
var
  LKey: UInt64;
begin
  // the same icon in the same color is added once: AddIcon is called by
  // elements created many times (routes, list builders, action buttons)
  LKey := (UInt64(Cardinal(ACodePoint)) shl 32) or AColor;
  if FIndexes.TryGetValue(LKey, Result) and (Result < ImageList.Count) then
    Exit;

  // no font: no image (see FontAvailable)
  if not FontAvailable then
  begin
    if not FMissingFontLogged then
    begin
      FMissingFontLogged := True;
      Log.d('FMXER: icon font not found (neither "%s" nor "%s" installed, no .ttf next to the executable or in LocalFilesPath): icons are not drawn',
        [ICON_FONTS_FAMILYNAME, ICON_FONTS_DESKTOP_FAMILYNAME]);
    end;
    Exit(-1);
  end;

  Result := ImageList.InsertIcon(FCount, ACodepoint, '', AColor);
  Inc(FCount);
  FIndexes.AddOrSetValue(LKey, Result);
end;

class constructor TIconFonts.ClassCreate;
begin
  TIconFonts._Instance := nil;
end;

class destructor TIconFonts.ClassDestroy;
begin
  if Assigned(TIconFonts._Instance) then
    FreeAndNil(TIconFonts._Instance);
end;

constructor TIconFonts.Create(AOwner: TComponent);
begin
  inherited;
  FCount := 0;
  FIndexes := TDictionary<UInt64, Integer>.Create;
  ImageList.FontName := FFontFamily;
end;

destructor TIconFonts.Destroy;
begin
  FreeAndNil(FIndexes);
  inherited;
end;

class function TIconFonts.GetIconFonts: TIconFonts;
begin
  if not Assigned(_Instance) then
    _Instance := TIconFonts.Create(nil);
  Result := _Instance;
end;

function TIconFonts.GetMD: TMaterialDesign;
begin
  Result := Icons.MaterialDesign.MD;
end;

function TIconFonts.FontAvailable: Boolean;
begin
  if not FFontChecked then
  begin
    FFontAvailable := DetectFontAvailable;
    FFontChecked := True;
  end;
  Result := FFontAvailable;
end;

function TIconFonts.DetectFontAvailable: Boolean;
begin
  {$IF defined(MSWINDOWS) or defined(ANDROID)}
  Result := FFontFound;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

class procedure TIconFonts.FontSelected;
begin
  FFontFound := True;
  // an instance already created draws with the new family from now on
  if Assigned(_Instance) then
  begin
    _Instance.ImageList.FontName := FFontFamily;
    _Instance.FFontChecked := False;
  end;
end;

class function TIconFonts.RegisterFontFile(const AFileName: string): Boolean;
var
  LTypeface: ISkTypeface;
begin
  Result := FileExists(AFileName);
  if not Result then
    Exit;
  LTypeface := TSkTypeface.MakeFromFile(AFileName);
  Result := Assigned(LTypeface);
  if not Result then
    Exit;
  TSkDefaultProviders.TypefaceFont.RegisterTypeface(LTypeface);
  FFontFile := AFileName;
  FFontFamily := LTypeface.FamilyName;
  FontSelected;
end;

{$IFDEF MSWINDOWS}
function EnumFontFamExProc(const ALogFont: TLogFont; const ATextMetric: TTextMetric;
  AFontType: DWORD; AData: LPARAM): Integer; stdcall;
begin
  PBoolean(AData)^ := True;
  Result := 0; // found: stop
end;

class function TIconFonts.IsFontInstalled(const AFamilyName: string): Boolean;
var
  LDC: HDC;
  LLogFont: TLogFont;
begin
  Result := False;
  FillChar(LLogFont, SizeOf(LLogFont), 0);
  LLogFont.lfCharSet := DEFAULT_CHARSET;
  StrPLCopy(LLogFont.lfFaceName, AFamilyName, Length(LLogFont.lfFaceName) - 1);
  LDC := GetDC(0);
  try
    EnumFontFamiliesEx(LDC, LLogFont, @EnumFontFamExProc, LPARAM(@Result), 0);
  finally
    ReleaseDC(0, LDC);
  end;
end;
{$ENDIF}

{$IF defined(MSWINDOWS) or defined(ANDROID)}
// a .ttf of the font: next to the executable or in LocalFilesPath (Windows: the
// media folder of the repository, for the demos run from the IDE; Android: the
// documents folder, where assets\internal is copied by System.StartUpCopy)
function RegisterIconFontFile(const AFileName: string): Boolean;
var
  LExePath: string;
begin
  LExePath := ExtractFilePath(ParamStr(0));
  Result := TIconFonts.RegisterFontFile(TPath.Combine(LExePath, AFileName))
    // LocalFilesPath is relative to the executable by default (Windows)
    or TIconFonts.RegisterFontFile(TPath.GetFullPath(TPath.Combine(LExePath, LocalFile(AFileName))))
    or TIconFonts.RegisterFontFile(TPath.GetFullPath(LocalFile(AFileName)));
end;

// the web font first (installed, or a .ttf), then the Desktop font of FMXER up
// to v.1.7; without any of them the icons are not drawn, the app still starts
procedure SelectIconFont;

  function Installed(const AFamilyName: string): Boolean;
  begin
    {$IFDEF MSWINDOWS}
    Result := TIconFonts.IsFontInstalled(AFamilyName);
    if Result then
    begin
      TIconFonts.FFontFamily := AFamilyName;
      TIconFonts.FontSelected;
    end;
    {$ELSE}
    Result := False;
    {$ENDIF}
  end;

begin
  if Installed(ICON_FONTS_FAMILYNAME) or RegisterIconFontFile(ICON_FONTS_FILENAME) then
    Exit;
  if Installed(ICON_FONTS_DESKTOP_FAMILYNAME) or RegisterIconFontFile(ICON_FONTS_DESKTOP_FILENAME) then
    Log.d('FMXER: icons drawn with "%s", slow to load: deploy or install "%s" (%s) instead',
      [ICON_FONTS_DESKTOP_FAMILYNAME, ICON_FONTS_FAMILYNAME, ICON_FONTS_FILENAME]);
end;
{$ENDIF}

initialization
  TIconFonts.FFontFamily := ICON_FONTS_FAMILYNAME;
  {$IF defined(MSWINDOWS) or defined(ANDROID)}
  SelectIconFont;
  {$ENDIF}


end.
