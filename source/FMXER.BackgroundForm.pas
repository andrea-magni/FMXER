unit FMXER.BackgroundForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs
, SubjectStand, FrameStand, FormStand, FMX.Objects
;

type
  TBackgroundForm = class(TForm)
    BackgroundRectangle: TRectangle;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
  protected
    FContentStand: string;
    FContent: TSubjectInfo;
    function GetFill: TBrush;
    function GetStroke: TStrokeBrush;
  public
    constructor Create(AOwner: TComponent); override;
    //
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TBackgroundForm;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TBackgroundForm;
    //
    function SetFillColor(const AColor: TAlphaColor): TBackgroundForm;
    function SetStrokeColor(const AColor: TAlphaColor): TBackgroundForm;
    function SetStrokeThickness(const AThickness: Single): TBackgroundForm;

    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;

    property Fill: TBrush read GetFill;
    property Stroke: TStrokeBrush read GetStroke;
  end;

var
  BackgroundForm: TBackgroundForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts;

{ TBackgroundForm }

constructor TBackgroundForm.Create(AOwner: TComponent);
begin
  inherited;
  BackgroundRectangle.Fill.Color := TAppColors.PrimaryColor;
end;

function TBackgroundForm.GetFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TBackgroundForm.GetStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

function TBackgroundForm.SetContentAsForm<T>(const AConfigProc: TProc<T>): TBackgroundForm;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

function TBackgroundForm.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TBackgroundForm;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

function TBackgroundForm.SetFillColor(
  const AColor: TAlphaColor): TBackgroundForm;
begin
  Result := Self;
  Fill.Color := AColor;
end;

function TBackgroundForm.SetStrokeColor(
  const AColor: TAlphaColor): TBackgroundForm;
begin
  Result := Self;
  Stroke.Color := AColor;
end;

function TBackgroundForm.SetStrokeThickness(
  const AThickness: Single): TBackgroundForm;
begin
  Result := Self;
  Stroke.Thickness := AThickness;
end;

end.
