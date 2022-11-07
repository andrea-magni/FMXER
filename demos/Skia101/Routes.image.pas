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
, FMXER.UI.Consts, FMXER.UI.Misc

, System.UITypes
, Skia, QRCode.Render

, Utils
;


procedure DefineImageRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('image'
  , procedure (S: TScaffoldForm)
    begin
      S
      .SetTitle('Image (PNG)')
      .SetContentAsFrame<TImageFrame>(
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
      S
      .SetTitle('Animated image (Lottie)')
      .SetContentAsFrame<TAnimatedImageFrame>(
        procedure (ImgF: TAnimatedImageFrame)
        begin
          ImgF.LoadFromFile(LocalFile('lottie_bubbles_MATERIAL_AMBER_800.json'));
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
      S
      .SetTitle('SVG image')
      .SetContentAsFrame<TSVGFrame>(
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
      S
      .SetTitle('QRCode')
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (B: TBackgroundFrame)
        begin
          B
          .SetFillColor(TAlphaColorRec.Aliceblue)
          .SetContentAsFrame<TQRCodeFrame>(
            procedure (QRF: TQRCodeFrame)
            begin
              QRF
              .SetContent('')
              .SetRadiusFactor(0.1)
              .LoadLogoContentFromFile(LocalFile('FMXER_R_256.png'))
              .SetLogoWidth(128)
              .SetLogoHeight(128)
              .SetLogoVisible(True)
              .SetMargin(25)
              .SetHitTest(True); // prevents click-through


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
                        var LContent := 'Time: ' + TimeToStr(Now);
                        QRF.SetContent(LContent);
                        S.SetTitle('QRCode ' + LContent);
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
