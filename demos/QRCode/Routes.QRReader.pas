unit Routes.QRReader;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineQRReaderRoute(const ARouteName: string);

implementation

uses
  DateUtils, FMX.Types, FMX.Graphics, FMX.DialogService
, ZXing.ReadResult
, Skia, Skia.FMX, Skia.FMX.Graphics
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.PaintBoxFrame, FMXER.ButtonFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.HorzPairFrame
, Data.Main
//, CodeSiteLogging
;

const QUEUE_INTERVAL = 100;


procedure DefineQRReaderRoute(const ARouteName: string);
begin
  var LLastQueueOp := Now;

  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
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
              .AddFrame<TStackFrame>(
                Scaffold.Width
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
                          var LOffsetX := -((MainData.ImageFrame.Width - ADest.Width) / 2);
                          var LOffsetY := -((MainData.ImageFrame.Height - ADest.Height) / 2);

                          var LPaint: ISkPaint := TSkPaint.Create;
                          var LSkImage := MainData.ImageFrame.ToSkImage();
                          ACanvas.DrawImage(
                            LSkImage, LOffsetX, LOffsetY, LPaint
                          );

                          for var LPoint in MainData.ScanPoints do
                          begin
                            LPoint.Offset(LOffsetX, LOffsetY);
                            LPaint.Color := TAlphaColorRec.Red;
                            LPaint.Alpha := $80;
                            ACanvas.DrawCircle(LPoint, 10, LPaint);
                          end;
                        end
                      );

                      MainData.SubscribeImageFrameAvailable(
                        procedure (ABitmap: TBitmap)
                        begin
                          PaintBoxFrame.PaintBox.Redraw;
                          if MillisecondsBetween(LLastQueueOp, Now) > QUEUE_INTERVAL then
                          begin
                            MainData.QueueFrameForScan(ABitmap);
                            LLastQueueOp := Now;
                          end;
                        end
                      );

                      MainData.OnScanResult :=
                        procedure (AResult: TReadResult)
                        begin
                          Scaffold.ShowSnackBar(AResult.Text, 3000);
                        end;
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
          MainData.CameraStop(True);
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );
end;

end.
