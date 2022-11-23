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
    FOnClickProc: TProc;
//    procedure SetImageIndex(const Value: Integer);
//    procedure SetImages(const Value: TCustomImageList);
//    procedure SetOnClickProc(const Value: TProc);
  public
    function SetImageIndex(const AIndex: Integer): TGlyphFrame;
    function SetImages(AImageList: TCustomImageList): TGlyphFrame;
    function SetOnClickProc(const AOnClickProc: TProc): TGlyphFrame;

    function GetImageIndex: Integer;
    function GetImages: TCustomImageList;
    function GetOnClickProc: TProc;

//    property ImageIndex: Integer read FImageIndex write SetImageIndex;
//    property Images: TCustomImageList read FImages write SetImages;
//    property OnClickProc: TProc read FOnClickProc write SetOnClickProc;
  end;

implementation

{$R *.fmx}

procedure TGlyphFrame.ClickLayoutClick(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc();
end;

function TGlyphFrame.GetImageIndex: Integer;
begin
  Result := ContentGlyph.ImageIndex;
end;

function TGlyphFrame.GetImages: TCustomImageList;
begin
  Result := ContentGlyph.Images;
end;

function TGlyphFrame.GetOnClickProc: TProc;
begin
  Result := FOnClickProc;
end;

function TGlyphFrame.SetImageIndex(const AIndex: Integer): TGlyphFrame;
begin
  Result := Self;
  ContentGlyph.ImageIndex := AIndex;
end;

function TGlyphFrame.SetImages(AImageList: TCustomImageList): TGlyphFrame;
begin
  Result := Self;
  ContentGlyph.Images := AImageList;
end;

function TGlyphFrame.SetOnClickProc(const AOnClickProc: TProc): TGlyphFrame;
begin
  Result := Self;
  FOnClickProc := AOnClickProc;
  ClickLayout.HitTest := Assigned(FOnClickProc);
end;

end.
