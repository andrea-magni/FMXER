unit FMXER.GlyphFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ImgList, FMX.Layouts;

type
  TGlyphFrame = class(TFrame)
    ContentGlyph: TGlyph;
    ClickLayout: TLayout;
    procedure ClickLayoutClick(Sender: TObject);
  private
    FImages: TCustomImageList;
    FImageIndex: Integer;
    FOnClickProc: TProc;
    procedure SetImageIndex(const Value: Integer);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetOnClickProc(const Value: TProc);
  public
    property ImageIndex: Integer read FImageIndex write SetImageIndex;
    property Images: TCustomImageList read FImages write SetImages;
    property OnClickProc: TProc read FOnClickProc write SetOnClickProc;
  end;

implementation

{$R *.fmx}

procedure TGlyphFrame.ClickLayoutClick(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc();
end;

procedure TGlyphFrame.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  ContentGlyph.ImageIndex := FImageIndex;
end;

procedure TGlyphFrame.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
  ContentGlyph.Images := FImages;
end;

procedure TGlyphFrame.SetOnClickProc(const Value: TProc);
begin
  FOnClickProc := Value;
  ClickLayout.HitTest := Assigned(FOnClickProc);
end;

end.
