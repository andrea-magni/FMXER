unit FMXER.ProgressBarFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Math,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Ani, FMX.Layouts, System.Skia, FMX.Skia
, FMXER.Observable;

type
  /// <summary>A linear progress bar (the Flutter LinearProgressIndicator): a
  /// track and a bar drawn with two rectangles, in TAppColors by default.
  /// Determinate (Value between Min and Max) or indeterminate (a bar that
  /// runs along the track).</summary>
  TProgressBarFrame = class(TFrame)
    CaptionLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    TrackLayout: TLayout;
    TrackRect: TRectangle;
    BarRect: TRectangle;
    procedure TrackRectResized(Sender: TObject);
  private
    FValue: Single;
    FMin: Single;
    FMax: Single;
    FIndeterminate: Boolean;
    FAnimation: TFloatAnimation;
    FValueLink: TObservableLink<Single>;
    procedure UpdateBar;
  protected
  public
    constructor Create(AOwner: TComponent); override;

    function GetCaption: string;
    function GetExtraText: string;
    function GetValue: Single;
    function GetMin: Single;
    function GetMax: Single;
    function GetIndeterminate: Boolean;
    function GetBarColor: TAlphaColor;
    function GetTrackColor: TAlphaColor;
    function GetThickness: Single;

    function SetCaption(const ACaption: string): TProgressBarFrame;
    function SetExtraText(const AExtraText: string): TProgressBarFrame;
    function SetValue(const AValue: Single): TProgressBarFrame;
    function SetMin(const AMin: Single): TProgressBarFrame;
    function SetMax(const AMax: Single): TProgressBarFrame;
    function SetIndeterminate(const AIndeterminate: Boolean): TProgressBarFrame;
    function SetBarColor(const AColor: TAlphaColor): TProgressBarFrame;
    function SetTrackColor(const AColor: TAlphaColor): TProgressBarFrame;
    function SetThickness(const AThickness: Single): TProgressBarFrame;
    /// <summary>One-way binding: the bar shows AObservable. Removed with the
    /// element.</summary>
    function BindValue(const AObservable: TObservable<Single>): TProgressBarFrame;
  end;

implementation

uses
  FMXER.UI.Consts;

{$R *.fmx}

{ TProgressBarFrame }

function TProgressBarFrame.BindValue(const AObservable: TObservable<Single>): TProgressBarFrame;
begin
  Result := Self;
  if not Assigned(FValueLink) then
    FValueLink := TObservableLink<Single>.Create(Self);
  FValueLink.Bind(AObservable,
    procedure (AValue: Single)
    begin
      SetValue(AValue);
    end);
end;

constructor TProgressBarFrame.Create(AOwner: TComponent);
begin
  inherited;
  FMin := 0;
  FMax := 100;
  FValue := 0;
  BarRect.Fill.Color := TAppColors.PrimaryColor;
  TrackRect.Fill.Color := TAppColors.LightBackgroundColor;

  FAnimation := TFloatAnimation.Create(Self);
  FAnimation.Parent := BarRect;
  FAnimation.PropertyName := 'Position.X';
  FAnimation.Duration := 1.2;
  FAnimation.Loop := True;
  FAnimation.Interpolation := TInterpolationType.Quadratic;
  FAnimation.AnimationType := TAnimationType.InOut;

  UpdateBar;
end;

function TProgressBarFrame.GetBarColor: TAlphaColor;
begin
  Result := BarRect.Fill.Color;
end;

function TProgressBarFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TProgressBarFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TProgressBarFrame.GetIndeterminate: Boolean;
begin
  Result := FIndeterminate;
end;

function TProgressBarFrame.GetMax: Single;
begin
  Result := FMax;
end;

function TProgressBarFrame.GetMin: Single;
begin
  Result := FMin;
end;

function TProgressBarFrame.GetThickness: Single;
begin
  Result := TrackRect.Height;
end;

function TProgressBarFrame.GetTrackColor: TAlphaColor;
begin
  Result := TrackRect.Fill.Color;
end;

function TProgressBarFrame.GetValue: Single;
begin
  Result := FValue;
end;

function TProgressBarFrame.SetBarColor(
  const AColor: TAlphaColor): TProgressBarFrame;
begin
  Result := Self;
  BarRect.Fill.Color := AColor;
end;

function TProgressBarFrame.SetCaption(
  const ACaption: string): TProgressBarFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
  CaptionLabel.Visible := not CaptionLabel.Text.IsEmpty;
end;

function TProgressBarFrame.SetExtraText(
  const AExtraText: string): TProgressBarFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TProgressBarFrame.SetIndeterminate(
  const AIndeterminate: Boolean): TProgressBarFrame;
begin
  Result := Self;
  FIndeterminate := AIndeterminate;
  UpdateBar;
end;

function TProgressBarFrame.SetMax(const AMax: Single): TProgressBarFrame;
begin
  Result := Self;
  FMax := AMax;
  UpdateBar;
end;

function TProgressBarFrame.SetMin(const AMin: Single): TProgressBarFrame;
begin
  Result := Self;
  FMin := AMin;
  UpdateBar;
end;

function TProgressBarFrame.SetThickness(
  const AThickness: Single): TProgressBarFrame;
begin
  Result := Self;
  TrackRect.Height := AThickness;
  TrackRect.XRadius := AThickness / 2;
  TrackRect.YRadius := AThickness / 2;
  BarRect.XRadius := AThickness / 2;
  BarRect.YRadius := AThickness / 2;
  UpdateBar;
end;

function TProgressBarFrame.SetTrackColor(
  const AColor: TAlphaColor): TProgressBarFrame;
begin
  Result := Self;
  TrackRect.Fill.Color := AColor;
end;

function TProgressBarFrame.SetValue(const AValue: Single): TProgressBarFrame;
begin
  Result := Self;
  FValue := AValue;
  UpdateBar;
end;

procedure TProgressBarFrame.TrackRectResized(Sender: TObject);
begin
  UpdateBar;
end;

procedure TProgressBarFrame.UpdateBar;
var
  LRatio: Single;
begin
  if not Assigned(FAnimation) then
    Exit;
  BarRect.Height := TrackRect.Height;
  BarRect.Position.Y := 0;
  if FIndeterminate then
  begin
    // a bar a third of the track, from before its start to after its end
    BarRect.Width := TrackRect.Width / 3;
    FAnimation.StartValue := -BarRect.Width;
    FAnimation.StopValue := TrackRect.Width;
    if not FAnimation.Running then
      FAnimation.Start;
  end
  else
  begin
    FAnimation.Stop;
    if FMax > FMin then
      LRatio := EnsureRange((FValue - FMin) / (FMax - FMin), 0, 1)
    else
      LRatio := 0;
    BarRect.Position.X := 0;
    BarRect.Width := TrackRect.Width * LRatio;
  end;
end;

end.
