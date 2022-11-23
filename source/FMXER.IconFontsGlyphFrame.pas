unit FMXER.IconFontsGlyphFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMXER.GlyphFrame, FMX.Layouts, FMX.ImgList, FMXER.IconFontsData, Icons.Utils;

type
  TIconFontsGlyphFrame = class(TGlyphFrame)
  private

  public
    procedure AfterConstruction; override;
    function SetIcon(const AIcon: TIconEntry): TIconFontsGlyphFrame; overload;
    function SetIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): TIconFontsGlyphFrame; overload;
  end;

implementation

{$R *.fmx}

{ TIconFontsGlyphFrame }

procedure TIconFontsGlyphFrame.AfterConstruction;
begin
  inherited;
  ContentGlyph.Images := IconFonts.ImageList;
end;

function TIconFontsGlyphFrame.SetIcon(
  const AIcon: TIconEntry): TIconFontsGlyphFrame;
begin
  Result := Self;
  SetImageIndex( IconFonts.AddIcon(AIcon) );
end;

function TIconFontsGlyphFrame.SetIcon(const AIcon: TIconEntry;
  const AColor: TAlphaColor): TIconFontsGlyphFrame;
begin
  Result := Self;
  SetImageIndex( IconFonts.AddIcon(AIcon, AColor) );
end;

end.
