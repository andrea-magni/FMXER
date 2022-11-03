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
    procedure SetDetail(const Value: string);
    procedure SetTitle(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure SetGlyphAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetGlyphAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    procedure SetGlyphRAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetGlyphRAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property Title: string read FTitle write SetTitle;
    property Detail: string read FDetail write SetDetail;
    property ContentStand: string read FContentStand write FContentStand;
    property GlyphStand: string read FGlyphStand write FGlyphStand;
    property GlyphRStand: string read FGlyphRStand write FGlyphRStand;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts, Skia.FMX;

{ TCardFrame }

constructor TCardFrame.Create(AOwner: TComponent);
begin
  inherited;

  TitleBackground.Fill.Color := TAppColors.PrimaryColor;
  ContentBackground.Fill.Color := TAppColors.LightBackgroundColor;

  FTitleTextFrame := TTextFrame.Create(Self);
  FTitleTextFrame.Parent := TitleLayout;
  FTitleTextFrame.Align := TAlignLayout.Client;
  FTitleTextFrame.HorzAlign := TSkTextHorzAlign.Leading;
  FTitleTextFrame.Margins.Left := 5;
end;

destructor TCardFrame.Destroy;
begin

  inherited;
end;

procedure TCardFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TCardFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TCardFrame.SetDetail(const Value: string);
begin
  FDetail := Value;
end;

procedure TCardFrame.SetGlyphAsForm<T>(const AConfigProc: TProc<T>);
begin
  GlyphLayout.Visible := true;
  FContent := FormStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

procedure TCardFrame.SetGlyphAsFrame<T>(const AConfigProc: TProc<T>);
begin
  GlyphLayout.Visible := true;
  FGlyph := FrameStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

procedure TCardFrame.SetGlyphRAsForm<T>(const AConfigProc: TProc<T>);
begin
  GlyphRLayout.Visible := true;
  FGlyphR := FormStand1.NewAndShow<T>(GlyphRLayout, GlyphRStand, AConfigProc);
end;

procedure TCardFrame.SetGlyphRAsFrame<T>(const AConfigProc: TProc<T>);
begin
  GlyphRLayout.Visible := true;
  FGlyphR := FrameStand1.NewAndShow<T>(GlyphRLayout, GlyphRStand, AConfigProc);
end;

procedure TCardFrame.SetTitle(const Value: string);
begin
  FTitle := Value;
  FTitleTextFrame.Content := Value;
end;

end.
