unit FMXER.IconFontsData;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList,
  FMX.IconFontsImageList, System.UITypes, Icons.MaterialDesign, Icons.Utils;

type
  TIconFonts = class(TDataModule)
    ImageList: TIconFontsImageList;
  private
    FCount: Integer;
  protected
    function GetMD: TMaterialDesign;
  public
    constructor Create(AOwner: TComponent); override;

    function AddIcon(const AIcon: TIconEntry): Integer; overload;
    function AddIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): Integer; overload;
    function AddIcon(const ACodePoint: Integer): Integer; overload;
    function AddIcon(const ACodePoint: Integer; const AColor: TAlphaColor): Integer; overload;

    property MD: TMaterialDesign read GetMD;
  end;

function IconFonts: TIconFonts;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses FMX.Forms;

var _Instance: TIconFonts = nil;

function IconFonts: TIconFonts;
begin
  if not Assigned(_Instance) then
    _Instance := TIconFonts.Create(nil);
  Result := _Instance;
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

constructor TIconFonts.Create(AOwner: TComponent);
begin
  inherited;
  FCount := 0;
  ImageList.FontName := 'Material Design Icons Desktop';
end;

function TIconFonts.GetMD: TMaterialDesign;
begin
  Result := Icons.MaterialDesign.MD;
end;

end.
