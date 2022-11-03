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
, FMXER.UI.Consts

, System.UITypes
, Skia, QRCode.Render, FMX.Types
;


procedure DefineFreeHandDrawingRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('freeHandDrawing'
  , procedure (S: TScaffoldForm)
    begin
      S.Title := 'Free Hand Drawing';

      S.SetTitleDetailContentAsFrame<TButtonFrame>(
        procedure (B: TButtonFrame)
        begin
          B.Width := S.TitleLayout.Height;
          B.Align := TAlignLayout.Right;
          B.Text := 'Back';
          B.Margins.Rect := RectF(0, 5, 0, 5);
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
