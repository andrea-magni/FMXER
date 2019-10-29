unit Frames.Card;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, Frames.Text, FMX.Objects, SubjectStand, FrameStand, FormStand;

type
  TCardFrame = class(TFrame)
    TitleLayout: TLayout;
    ContentLayout: TLayout;
    GlyphLayout: TLayout;
    TitleTextFrame: TTextFrame;
    TitleBackground: TRectangle;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    ContentBackground: TRectangle;
  private
    FContent: TSubjectInfo;
    FDetail: string;
    FTitle: string;
    FContentStand: string;
    FGlyphStand: string;
    procedure SetDetail(const Value: string);
    procedure SetTitle(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure SetGlyphAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetGlyphAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property Title: string read FTitle write SetTitle;
    property Detail: string read FDetail write SetDetail;
    property ContentStand: string read FContentStand write FContentStand;
    property GlyphStand: string read FGlyphStand write FGlyphStand;
  end;

implementation

{$R *.fmx}

uses UI.Consts;

{ TCardFrame }

constructor TCardFrame.Create(AOwner: TComponent);
begin
  inherited;

  TitleBackground.Fill.Color := TAppColors.PRIMARY_COLOR;
  ContentBackground.Fill.Color := TAppColors.LIGHT_BACKGROUND_COLOR;
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
  FContent := FormStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

procedure TCardFrame.SetGlyphAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(GlyphLayout, GlyphStand, AConfigProc);
end;

procedure TCardFrame.SetTitle(const Value: string);
begin
  FTitle := Value;
  TitleTextFrame.Content := Value;
end;

end.
