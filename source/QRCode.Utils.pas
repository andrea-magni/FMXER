unit QRCode.Utils;

interface

uses
  System.Classes, System.SysUtils, System.Types, UITypes
, FMX.Graphics, FMX.Types
, Skia, Skia.FMX
, DelphiZXIngQRCode  // ../../lib/DelphiZXingQRCode/Source
, QRCode.Render // skia4Delphi Samples (webinar)
;

type
  TOnBeforePaintHandler = reference to procedure(APaint: ISkPaint; AModules: T2DBooleanArray);

  TQRCode = class
  public
    class function TextToSvg(const AContent: string;
      const ABeforePaint: TOnBeforePaintHandler = nil; const ARadiusFactor: Single = 0.1): string;
  end;

  procedure SvgToBitmap(const ASvg: string; const AColor: TAlphaColor;
    const AWidth, AHeight: Integer; const AOnReady: TProc<TBitmap>);

implementation


procedure SvgToBitmap(const ASvg: string; const AColor: TAlphaColor;
  const AWidth, AHeight: Integer; const AOnReady: TProc<TBitmap>);
const MARGIN = 20;
var
  LBitmap: TBitmap;
begin
  LBitmap := TBitmap.Create(AWidth + MARGIN, AHeight + MARGIN);
  try
    LBitmap.SkiaDraw(
      procedure (const ACanvas: ISKCanvas)
      var
        LSvgBrush: TSkSvgBrush;
      begin
        ACanvas.Clear(TAlphaColorRec.White);

        LSvgBrush := TSkSvgBrush.Create;
        try
          LSvgBrush.Source := ASvg;
          LSvgBrush.OverrideColor := AColor;
          LSvgBrush.Render(ACanvas, RectF(MARGIN, MARGIN, AWidth, AHeight), 1);
        finally
          LSvgBrush.Free;
        end;
      end
    );

    if Assigned(AOnReady) then
      AOnReady(LBitmap);

  finally
    LBitmap.Free;
  end;
end;


{ TQRCode }

class function TQRCode.TextToSvg(const AContent: string;
  const ABeforePaint: TOnBeforePaintHandler; const ARadiusFactor: Single): string;
const
  LogoModules = 1;
  LogoSize = 1;
var
  LQRCode: TDelphiZXingQRCode;
  LPaint: ISkPaint;
  LModules: T2DBooleanArray;
begin
  LQRCode := TDelphiZXingQRCode.Create;
  try
    LQRCode.QuietZone := 0;
    LQRCode.Encoding := qrAuto;
    LQRCode.Data := AContent;

    SetLength(LModules, LQRCode.Rows);
    for var LRow := 0 to LQRCode.Rows-1 do
    begin
      SetLength(LModules[LRow], LQRCode.Columns);
      for var LCol := 0 to LQRCode.Columns-1 do
        LModules[LRow][LCol] := LQRCode.IsBlack[LRow, LCol];
    end;

  finally
    LQRCode.Free;
  end;

  LPaint := TSkPaint.Create;
  if Assigned(ABeforePaint) then
    ABeforePaint(LPaint, LModules);

  Result :=
    TQRCodeRender
    .MakeRounded(LModules, LogoModules, LogoSize, ARadiusFactor)
    .AsSVG(LPaint);
end;

end.
