unit FMXER.ColorButtonFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMXER.ButtonFrame, Skia, System.Actions, FMX.ActnList, Skia.FMX,
  FMX.Controls.Presentation, FMX.Objects;

type
  TColorButtonFrame = class(TButtonFrame)
    ColorRect: TRoundRect;
  private
  public
    function SetColorValue(const AColor: TAlphaColor): TColorButtonFrame;
    function SetColorVisible(const AVisible: Boolean): TColorButtonFrame;
    function SetColorStrokeValue(const AColor: TAlphaColor): TColorButtonFrame;
    function GetColorValue: TAlphaColor;
    function GetColorVisible: Boolean;
    function GetColorStrokeValue: TAlphaColor;
  end;

var
  ColorButtonFrame: TColorButtonFrame;

implementation

{$R *.fmx}

{ TColorButtonFrame }

function TColorButtonFrame.GetColorStrokeValue: TAlphaColor;
begin
  Result := ColorRect.Stroke.Color;
end;

function TColorButtonFrame.GetColorValue: TAlphaColor;
begin
  Result := ColorRect.Fill.Color;
end;

function TColorButtonFrame.GetColorVisible: Boolean;
begin
  Result := ColorRect.Visible;
end;

function TColorButtonFrame.SetColorStrokeValue(
  const AColor: TAlphaColor): TColorButtonFrame;
begin
  Result := Self;
  ColorRect.Stroke.Color := AColor;
end;

function TColorButtonFrame.SetColorValue(
  const AColor: TAlphaColor): TColorButtonFrame;
begin
  Result := Self;
  ColorRect.Fill.Color := AColor;
end;

function TColorButtonFrame.SetColorVisible(
  const AVisible: Boolean): TColorButtonFrame;
begin
  Result := Self;
  ColorRect.Visible := AVisible;
end;

end.
