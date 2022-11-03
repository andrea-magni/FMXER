unit FMXER.IconFontsData;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList,
  FMX.IconFontsImageList, System.UITypes, Icons.MaterialDesign, Icons.Utils;

const
  ICON_FONTS_FAMILYNAME = 'Material Design Icons Desktop';
  ICON_FONTS_FILENAME = ICON_FONTS_FAMILYNAME + '.ttf';

type
  TIconFonts = class(TDataModule)
    ImageList: TIconFontsImageList;
  private
    FCount: Integer;
  private
    class var _Instance: TIconFonts;
    class function GetIconFonts: TIconFonts; static;
  protected
    function GetMD: TMaterialDesign;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;

    constructor Create(AOwner: TComponent); override;

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

uses FMX.Forms, IOUtils, Skia, Skia.FMX;

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
begin
  Result := ImageList.InsertIcon(FCount, ACodepoint, '', AColor);
  Inc(FCount);
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
  ImageList.FontName := ICON_FONTS_FAMILYNAME;
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

initialization
  {$IFDEF ANDROID}
  TSkDefaultProviders.RegisterTypeface(TPath.Combine(TPath.GetDocumentsPath, ICON_FONTS_FILENAME));
  {$ENDIF}

end.
