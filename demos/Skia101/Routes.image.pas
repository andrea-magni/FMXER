unit Routes.image;

interface

uses System.Classes, System.SysUtils, System.Types
, FMX.Types;

procedure DefineImageRoute;
procedure DefineAnimatedImageRoute;
procedure DefineSVGImageRoute;
procedure DefineQRCodeRoute;

implementation

uses
  System.Threading, IOUtils
, FMXER.Navigator
, FMXER.ScaffoldForm
, FMXER.ImageFrame
, FMXER.AnimatedImageFrame
, FMXER.SVGFrame
, FMXER.BackgroundForm
, FMXER.BackgroundFrame
, FMXER.QRCodeFrame
, FMXER.UI.Consts

, System.UITypes
, Skia, QRCode.Render

, Utils
;


procedure DefineImageRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('image'
  , procedure (S: TScaffoldForm)
    begin
      S.Title := 'Image (PNG)';

      S.SetContentAsFrame<TImageFrame>(
        procedure (ImgF: TImageFrame)
        begin
          ImgF.ContentImage.Bitmap.LoadFromFile(LocalFile('FMXER_256.png'));

          ImgF.OnTapHandler :=
            procedure (AImg: TFMXObject; APoint: TPointF)
            begin
              Navigator.CloseRoute('image');
            end;
        end
      );
    end
  );
end;

procedure DefineAnimatedImageRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('animatedImage'
  , procedure (S: TScaffoldForm)
    begin
      S.Title := 'Animated image (Lottie)';

      S.SetContentAsFrame<TAnimatedImageFrame>(
        procedure (ImgF: TAnimatedImageFrame)
        begin
          ImgF.Image.LoadFromFile(LocalFile('lottie_bubbles_MATERIAL_AMBER_800.json'));
          ImgF.OnTapHandler :=
            procedure (AImg: TFMXObject; APoint: TPointF)
            begin
              Navigator.CloseRoute('animatedImage');
            end;
        end
      );

    end
  );
end;


procedure DefineSVGImageRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('SVGImage'
  , procedure (S: TScaffoldForm)
    begin
      S.Title := 'SVG image';

      S.SetContentAsFrame<TSVGFrame>(
        procedure (ImgF: TSVGFrame)
        begin
          ImgF.LoadFromFile(LocalFile('tesla.svg'));
          ImgF.OnTapHandler :=
            procedure (AImg: TFMXObject; APoint: TPointF)
            begin
              Navigator.CloseRoute('SVGImage');
            end;
        end
      );

    end
  );
end;




procedure DefineQRCodeRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('QRCode'
  , procedure (S: TScaffoldForm)
    begin
      S.Title := 'QRCode';

      S.SetContentAsFrame<TBackgroundFrame>(
        procedure (B: TBackgroundFrame)
        begin
          B.Fill.Color := TAlphaColorRec.Aliceblue;
          B.SetContentAsFrame<TQRCodeFrame>(
            procedure (QRF: TQRCodeFrame)
            begin
              QRF.Margins.Rect := RectF(25, 25, 25, 25);
              QRF.HitTest := True; // prevents click-through

              QRF.Content := '';
              QRF.RadiusFactor := 0.1;

              QRF.QRCodeLogo.LoadFromFile(LocalFile('FMXER_R_256.png'));
              QRF.QRCodeLogo.Width := 128;
              QRF.QRCodeLogo.Height := 128;
              QRF.QRCodeLogo.Visible := True;

              TTask.Run(
                procedure
                begin
                  while True do
                  begin
                    TThread.Queue(nil
                    , procedure
                      begin
                        if not Navigator.IsRouteActive('QRCode') then
                          Exit;
                        QRF.Content := 'Time: ' + TimeToStr(Now);
                        S.Title := 'QRCode ' + QRF.Content;
                      end
                    );

                    Sleep(500);

                    if not (TNavigator.Initialized and Navigator.IsRouteActive('QRCode')) then
                      Exit;
                  end;
                end
              );

              QRF.OnBeforePaint :=
                procedure (APaint: ISkPaint; AModules: T2DBooleanArray)
                begin
                  APaint.Shader := TSkShader.MakeGradientLinear(
                    PointF(Length(AModules) - 6, 6)
                  , PointF(6, Length(AModules) - 6)

                  , TAppColors.MATERIAL_ORANGE_800
                  , TAppColors.MATERIAL_DEEP_PURPLE_400
                  , TSkTileMode.Clamp);

//                  APaint.Shader := TSkShader.MakeGradientRadial(
//                    PointF(100, 100), 100
//                  , TAppColors.MATERIAL_ORANGE_800
//                  , TAppColors.MATERIAL_DEEP_PURPLE_400
//                  );

                end;

              QRF.OnTapHandler :=
                procedure (AC: TFMXObject; APoint: TPointF)
                begin
                  Navigator.CloseRoute('QRCode');
                end;
            end
          );
        end
      );

    end
  );

end;




end.