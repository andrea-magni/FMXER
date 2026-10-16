unit FMXER.CardFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects
, SubjectStand, FrameStand, FormStand
, FMXER.ColumnForm, FMXER.TextFrame;

type
  TCardFrame = class(TFrame)
    TitleLayout: TLayout;
    ContentLayout: TLayout;
    GlyphLayout: TLayout;
    TitleBackground: TRectangle;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    ContentBackground: TRectangle;
    GlyphRLayout: TLayout;
  private
    FGlyph: TSubjectInfo;
    FGlyphR: TSubjectInfo;
    FContent: TSubjectInfo;
    FDetail: string;
    FTitle: string;
    FContentStand: string;
    FGlyphStand: string;
    FGlyphRStand: string;
    FTitleTextFrame: TTextFrame;
    procedure InternalSetDetail(const Value: string);
    procedure InternalSetTitle(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    function SetGlyphAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
    function SetGlyphAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;

    function SetGlyphRAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
    function SetGlyphRAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;

    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;
    function SetTitle(const ATitle: string): TCardFrame;
    function SetContentStand(const AStand: string): TCardFrame;
    //
    property Title: string read FTitle write InternalSetTitle;
    property Detail: string read FDetail write InternalSetDetail;
    property ContentStand: string read FContentStand write FContentStand;
    property GlyphStand: string read FGlyphStand write FGlyphStand;
    property GlyphRStand: string read FGlyphRStand write FGlyphRStand;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts, FMXER.UI.Misc, FMX.Skia;

{ TCardFrame }

constructor TCardFrame.Create(AOwner: TComponent);
begin
  inherited;

  TitleBackground.Fill.Color := TAppColors.PrimaryColor;
  ContentBackground.Fill.Color := TAppColors.LightBackgroundColor;

  FTitleTextFrame := TTextFrame.Create(Self);
  FTitleTextFrame.Parent := TitleLayout;
  FTitleTextFrame
  .SetHorzAlign(TSkTextHorzAlign.Leading)
  .SetAlignClient
  .SetMargin(5, 0, 0 ,0);
end;

destructor TCardFrame.Destroy;
begin

  inherited;
end;

function TCardFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TCardFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TCardFrame.InternalSetDetail(const Value: string);
begin
  FDetail := Value;
end;

function TCardFrame.SetGlyphAsForm<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  GlyphLayout.Visible := true;
  FGlyph := FormStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

function TCardFrame.SetGlyphAsFrame<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  GlyphLayout.Visible := true;
  FGlyph := FrameStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

function TCardFrame.SetGlyphRAsForm<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  GlyphRLayout.Visible := true;
  FGlyphR := FormStand1.NewAndShow<T>(GlyphRLayout, GlyphRStand, AConfigProc);
end;

function TCardFrame.SetGlyphRAsFrame<T>(const AConfigProc: TProc<T>): TCardFrame;
begin
  Result := Self;
  GlyphRLayout.Visible := true;
  FGlyphR := FrameStand1.NewAndShow<T>(GlyphRLayout, GlyphRStand, AConfigProc);
end;

procedure TCardFrame.InternalSetTitle(const Value: string);
begin
  FTitle := Value;
  FTitleTextFrame.SetContent(Value);
end;

function TCardFrame.SetTitle(const ATitle: string): TCardFrame;
begin
  Result := Self;
  Title := ATitle;
end;

function TCardFrame.SetContentStand(const AStand: string): TCardFrame;
begin
  Result := Self;
  FContentStand := AStand;
end;

end.
