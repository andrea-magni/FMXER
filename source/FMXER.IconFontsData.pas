unit FMXER.IconFontsData;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList, System.Generics.Collections,
  FMX.IconFontsImageList, System.UITypes, Icons.MaterialDesign, Icons.Utils;

const
  ICON_FONTS_FAMILYNAME = 'Material Design Icons Desktop';
  ICON_FONTS_FILENAME = ICON_FONTS_FAMILYNAME + '.ttf';

type
  TIconFonts = class(TDataModule)
    ImageList: TIconFontsImageList;
  private
    FCount: Integer;
    FIndexes: TDictionary<UInt64, Integer>; // (code point, color) -> image index
  private
    class var _Instance: TIconFonts;
    class function GetIconFonts: TIconFonts; static;
  protected
    function GetMD: TMaterialDesign;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddIcon(const AIcon: TIconEntry): Integer; overload;
    function AddIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): Integer; overload;
    function AddIcon(const ACodePoint: Integer): Integer; overload;
    function AddIcon(const ACodePoint: Integer; const AColor: TAlphaColor): Integer; overload;

    property MD: TMaterialDesign read GetMD;
    class property Instance: TIconFonts read GetIconFonts;
  end;

function IconFonts: TIconFonts;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses FMX.Forms, IOUtils, System.Skia, FMX.Skia;

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
  ImageList.FontName := ICON_FONTS_FAMILYNAME;
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

{$IFDEF MSWINDOWS}
// the font installed in Windows is found by name; without it, a copy of the .ttf
// next to the executable is enough
procedure RegisterLocalIconFont;
var
  LFileName: string;
begin
  LFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), ICON_FONTS_FILENAME);
  if FileExists(LFileName) then
    TSkDefaultProviders.RegisterTypeface(LFileName);
end;
{$ENDIF}

{$IFDEF ANDROID}
// the .ttf deployed to assets\internal (copied to the documents folder by
// System.StartUpCopy); without it the icons are missing, the app still starts
procedure RegisterDeployedIconFont;
var
  LFileName: string;
begin
  LFileName := TPath.Combine(TPath.GetDocumentsPath, ICON_FONTS_FILENAME);
  if FileExists(LFileName) then
    TSkDefaultProviders.RegisterTypeface(LFileName);
end;
{$ENDIF}

initialization
  {$IFDEF ANDROID}
  RegisterDeployedIconFont;
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  RegisterLocalIconFont;
  {$ENDIF}

//  TSkDefaultProviders.RegisterTypeface(TPath.Combine('Contents\Resources\Fonts', ICON_FONTS_FILENAME));


end.
