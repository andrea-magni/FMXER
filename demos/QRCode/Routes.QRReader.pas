unit Routes.QRReader;

interface

uses
  Classes, SysUtils, Types, UITypes, FMX.Types, FMX.Graphics;

procedure DefineQRReaderRoute(const ARouteName: string);

implementation

uses
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc,
  FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.RowForm,
  FMXER.PaintBoxFrame, FMXER.ButtonFrame, FMXER.StackFrame, FMXER.BackgroundFrame,
  FMXER.HorzPairFrame, FMXER.AccessoryFrame, FMXER.LogoFrame
, Data.Main, Skia, Skia.FMX, Skia.FMX.Graphics
;


procedure DefineQRReaderRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Home: TScaffoldForm)
    begin
      Home
      .SetTitle('Reader')
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BGFrame: TBackgroundFrame)
        begin
          BGFrame
          .SetFillColor(TAlphaColorRec.White)
          .SetContentAsForm<TColumnForm>(
            procedure (Col: TColumnForm)
            begin
              Col
              .AddFrame<THorzPairFrame>(
                50
              , procedure (Pair: THorzPairFrame)
                begin
                  Pair
                  .SetContentAsFrame<TButtonFrame, TButtonFrame>(
                    procedure (Button: TButtonFrame)
                    begin
                      Button
                      .SetText('QR color')
                      .SetMargin<TButtonFrame>(0, 0, 2.5, 0)
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeColorSelection');
                        end
                      );
                    end
                  , procedure (Button: TButtonFrame)
                    begin
                      Button
                      .SetText('BG color')
                      .SetMargin<TButtonFrame>(2.5, 0, 0, 0)
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeBGColorSelection');
                        end
                      );
                    end
                  )
                  .SetPadding(5);
                end
              )
    //          .AddFrame<TAccessoryFrame>(
    //            50
    //          , procedure (Frame: TAccessoryFrame)
    //            begin
    //              Frame.SetContentAsFrame<TTrackbarFrame>;
    //              Frame.SetLeftAsFrame<TLogoFrame>(50);
    //              Frame.SetRightAsFrame<TLogoFrame>(50);
    //            end
    //          )
              .AddFrame<TStackFrame>(
                Home.Width
              , procedure (Stack: TStackFrame)
                begin
                  var LBGFrame: TBackgroundFrame;

                  Stack
                  .AddFrame<TBackgroundFrame>(
                    procedure (BGFrame: TBackgroundFrame)
                    begin
                      BGFrame.SetFillColor(MainData.QRCodeBGColor);
                      LBGFrame := BGFrame;
                    end
                  )
                  .AddFrame<TPaintBoxFrame>(
                    procedure (PaintBoxFrame: TPaintBoxFrame)
                    begin
                      PaintBoxFrame
                      .SetAlignClient
                      .SetMargin<TPaintBoxFrame>(20)
                      .SetOnDrawHandler(
                        procedure(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single)
                        begin
                          ACanvas.DrawImage(
                            MainData.ImageFrame.ToSkImage()
                          , -((MainData.ImageFrame.Width - ADest.Width) / 2)
                          , -((MainData.ImageFrame.Height - ADest.Height) / 2)
                          );
                        end
                      );

                      MainData.SubscribeImageFrameAvailable(
                        procedure (ABitmap: TBitmap)
                        begin
                          PaintBoxFrame.PaintBox.Redraw;
                        end
                      );
                    end
                  )
                  .SetPadding(5);
                end
              );
            end
          );
        end
      )
      .AddActionButton('Back'
      , procedure
        begin
          MainData.ClearImageFrameSubscribers;
          MainData.CameraStop;
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );
end;

end.
