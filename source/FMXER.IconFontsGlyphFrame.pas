unit FMXER.IconFontsGlyphFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMXER.GlyphFrame, FMX.Layouts, FMX.ImgList, FMXER.IconFontsData;

type
  TIconFontsGlyphFrame = class(TGlyphFrame)
  private

  public
    procedure AfterConstruction; override;
  end;

var
  IconFontsGlyphFrame: TIconFontsGlyphFrame;

implementation

{$R *.fmx}

{ TIconFontsGlyphFrame }

procedure TIconFontsGlyphFrame.AfterConstruction;
begin
  inherited;
  ContentGlyph.Images := IconFonts.ImageList;
end;

end.
