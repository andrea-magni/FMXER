unit Routes.freeHandDrawing;

interface

uses System.Classes, System.SysUtils, System.Types;

procedure DefineFreeHandDrawingRoute;

implementation

uses
  System.Threading
, FMXER.Navigator
, FMXER.ScaffoldForm
, FMXER.PaintBoxFrame
, FMXER.BackgroundForm
, FMXER.BackgroundFrame
, FMXER.ButtonFrame
, FMXER.UI.Consts, FMXER.UI.Misc

, System.UITypes
, Skia, QRCode.Render, FMX.Types
;


procedure DefineFreeHandDrawingRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('freeHandDrawing'
  , procedure (S: TScaffoldForm)
    begin
      S
      .SetTitle('Free Hand Drawing')
      .SetTitleDetailContentAsFrame<TButtonFrame>(
        procedure (B: TButtonFrame)
        begin
          B
          .SetText('Back')
          .SetWidth(S.TitleLayout.Height)
          .SetAlignRight
          .SetMarginTB(5);
          B.OnClickHandler :=
            procedure
            begin
              Navigator.CloseRoute('freeHandDrawing');
            end;
        end
      );

      S.SetContentAsFrame<TPaintBoxFrame>(
        procedure (F: TPaintBoxFrame)
        begin

          F.OnDrawHandler :=
            procedure (const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single)
            var
              LPaint: ISkPaint;
            begin
              LPaint := TSkPaint.Create;
              LPaint.Shader := TSkShader.MakeGradientSweep(ADest.CenterPoint, [$FFFCE68D, $FFF7CAA5, $FF2EBBC1, $FFFCE68D]);
              ACanvas.DrawPaint(LPaint);
            end;

        end
      );
    end
  );

end;



end.
