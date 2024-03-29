unit FMXER.TrackbarFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, SubjectStand, FMX.Ani, FMX.Layouts,
  FMX.ListBox, FMX.Colors, Skia, Skia.FMX, FMXER.UI.Misc;

type
  TTrackbarFrame = class(TFrame)
    ExtraLabel: TSkLabel;
    CaptionLabel: TSkLabel;
    TrackBar1: TTrackBar;
    procedure TrackBar1Change(Sender: TObject);
  private
    FOnChangeProc: TProc<Single>;
  protected
  public
    function GetCaption: string;
    function GetValue: Single;
    function GetMax: Single;
    function GetMin: Single;
    function GetTracking: Boolean;
    function GetExtraText: string;
    function GetFrequency: Single;

    function SetCaption(const ACaption: string): TTrackbarFrame;
    function SetCaptionPosition(const ACaptionPosition: TCaptionPosition; const AMargin: Single = 5): TTrackbarFrame;
    function SetFrequency(const AFrequency: Single): TTrackbarFrame;
    function SetValue(const AValue: Single): TTrackbarFrame;
    function SetMax(const AMax: Single): TTrackbarFrame;
    function SetMin(const AMin: Single): TTrackbarFrame;
    function SetTracking(const ATracking: Boolean): TTrackbarFrame;
    function SetExtraText(const AExtraText: string): TTrackbarFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Single>): TTrackbarFrame;

    property OnChangeProc: TProc<Single> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TColorPickerFrame }

function TTrackbarFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TTrackbarFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TTrackbarFrame.GetFrequency: Single;
begin
  Result := TrackBar1.Frequency;
end;

function TTrackbarFrame.GetMax: Single;
begin
  Result := Trackbar1.Max;
end;

function TTrackbarFrame.GetMin: Single;
begin
  Result := Trackbar1.Min;
end;

function TTrackbarFrame.GetTracking: Boolean;
begin
  Result := Trackbar1.Tracking;
end;

function TTrackbarFrame.GetValue: Single;
begin
  Result := Trackbar1.Value;
end;

function TTrackbarFrame.SetCaption(const ACaption: string): TTrackbarFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
  CaptionLabel.Visible := not CaptionLabel.Text.IsEmpty;
end;

function TTrackbarFrame.SetCaptionPosition(
  const ACaptionPosition: TCaptionPosition; const AMargin: Single): TTrackbarFrame;
begin
  Result := Self;
  case ACaptionPosition of
    TCaptionPosition.Left:
      begin
        CaptionLabel.Align := TAlignLayout.Left;
        CaptionLabel.SetMargin(0, 0, AMargin, 0);
      end;
    TCaptionPosition.Right:
      begin
        CaptionLabel.Align := TAlignLayout.Right;
        CaptionLabel.SetMargin(AMargin, 0, 0, 0);
      end;
    TCaptionPosition.Top:
      begin
        CaptionLabel.Align := TAlignLayout.Top;
        CaptionLabel.SetMargin(0, 0, 0, AMargin);
      end;
    TCaptionPosition.Bottom:
      begin
        CaptionLabel.Align := TAlignLayout.Bottom;
        CaptionLabel.SetMargin(0, AMargin, 0, 0);
      end;
  end;
end;

function TTrackbarFrame.SetExtraText(const AExtraText: string): TTrackbarFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TTrackbarFrame.SetFrequency(const AFrequency: Single): TTrackbarFrame;
begin
  Result := Self;
  TrackBar1.Frequency := AFrequency;
end;

function TTrackbarFrame.SetMax(const AMax: Single): TTrackbarFrame;
begin
  Result := Self;
  Trackbar1.Max := AMax;
end;

function TTrackbarFrame.SetMin(const AMin: Single): TTrackbarFrame;
begin
  Result := Self;
  Trackbar1.Min := AMin;
end;

function TTrackbarFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<Single>): TTrackbarFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

function TTrackbarFrame.SetTracking(const ATracking: Boolean): TTrackbarFrame;
begin
  Result := Self;
  Trackbar1.Tracking := ATracking;
end;

function TTrackbarFrame.SetValue(const AValue: Single): TTrackbarFrame;
begin
  Result := Self;
  Trackbar1.Value := AValue;
end;

procedure TTrackbarFrame.TrackBar1Change(Sender: TObject);
begin
  if Assigned(FOnChangeProc) then
    FOnChangeProc(Trackbar1.Value);
end;

end.
