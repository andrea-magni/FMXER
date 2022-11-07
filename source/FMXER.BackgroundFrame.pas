unit FMXER.BackgroundFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects
, SubjectStand, FrameStand, FormStand;

type
  TBackgroundFrame = class(TFrame)
    BackgroundRectangle: TRectangle;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
  private
  protected
    FContentStand: string;
    FContent: TSubjectInfo;
    function GetFill: TBrush;
    function GetStroke: TStrokeBrush;
    procedure HitTestChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    //
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TBackgroundFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TBackgroundFrame;
    //
    function SetFillColor(const AColor: TAlphaColor): TBackgroundFrame;
    function SetStrokeColor(const AColor: TAlphaColor): TBackgroundFrame;
    function SetStrokeThickness(const AThickness: Single): TBackgroundFrame;

    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;

    property Fill: TBrush read GetFill;
    property Stroke: TStrokeBrush read GetStroke;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts;

{ TBackgroundFrame }

constructor TBackgroundFrame.Create(AOwner: TComponent);
begin
  inherited;
  BackgroundRectangle.Fill.Color := TAppColors.PrimaryColor;
end;

function TBackgroundFrame.GetFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TBackgroundFrame.GetStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

procedure TBackgroundFrame.HitTestChanged;
begin
  inherited;
  if Assigned(BackgroundRectangle) then
    BackgroundRectangle.HitTest := HitTest;
end;

function TBackgroundFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): TBackgroundFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

function TBackgroundFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TBackgroundFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

function TBackgroundFrame.SetFillColor(
  const AColor: TAlphaColor): TBackgroundFrame;
begin
  Result := Self;
  Fill.Color := AColor;
end;

function TBackgroundFrame.SetStrokeColor(
  const AColor: TAlphaColor): TBackgroundFrame;
begin
  Result := Self;
  Stroke.Color := AColor;
end;

function TBackgroundFrame.SetStrokeThickness(
  const AThickness: Single): TBackgroundFrame;
begin
  Result := Self;
  Stroke.Thickness := AThickness;
end;

end.
