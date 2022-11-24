unit Routes.QRReader;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineQRReaderRoute(const ARouteName: string);

implementation

uses
  DateUtils, Rtti, TypInfo
, FMX.Types, FMX.Graphics, FMX.DialogService
, ZXing.ReadResult, ZXing.BarcodeFormat
, Skia, Skia.FMX, Skia.FMX.Graphics
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.PaintBoxFrame, FMXER.ButtonFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.TextFrame
, Data.Main
;

const SCAN_POINT_DURATION = 2000;

type
  TBarcodeFormatHelper = record helper for TBarcodeFormat
    function ToString: string;
  end;

procedure DefineQRReaderRoute(const ARouteName: string);
begin
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
              var LResultTextFrame: TTextFrame := nil;
              var LFormatTextFrame: TTextFrame := nil;

              Col
              .AddFrame<TStackFrame>(
                Scaffold.Width
              , procedure (Stack: TStackFrame)
                begin
                  var LBGFrame: TBackgroundFrame;

                  Stack
                  .AddFrame<TBackgroundFrame>(
                    procedure (BGFrame: TBackgroundFrame)
                    begin
                      BGFrame.SetFillColor(TAppColors.PrimaryColor);
                      LBGFrame := BGFrame;
                    end
                  )
                  .AddFrame<TPaintBoxFrame>(
                    procedure (PaintBoxFrame: TPaintBoxFrame)
                    begin
                      MainData.StartScanning(
                        procedure (ABitmap: TBitmap)
                        begin
                          PaintBoxFrame.PaintBox.Redraw;
                          MainData.QueueFrame(ABitmap);
                        end
                      , procedure (AResult: TReadResult; AFrame: TBitmap)
                        begin
                          MainData.StopScanning(True);

                          LResultTextFrame.SetContent(AResult.text);
                          LFormatTextFrame.SetContent(AResult.BarcodeFormat.ToString);
                        end
                      );

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

                          var LNow := Now;
                          for var LScanPoint in MainData.ScanPoints do
                          begin
                            var LPoint := LScanPoint.PointF;
                            var LAge := MillisecondsBetween(LScanPoint.TimeStamp, LNow);
                            var LAlpha := Round(((SCAN_POINT_DURATION - LAge)/SCAN_POINT_DURATION) * 255);
                            if LAlpha < 0 then
                              LAlpha := 0;

                            LPoint.Offset(LOffsetX, LOffsetY);
                            LPaint.Color := TAlphaColorRec.Red;
                            LPaint.Alpha := LAlpha;
                            ACanvas.DrawCircle(LPoint, 5, LPaint);
                          end;
                        end
                      );

                    end
                  )
                  .SetPadding(5);
                end
              ) // StackFrame
              .AddFrame<TTextFrame>(
                75
              , procedure (Frame: TTextFrame)
                begin
                  Frame
                  .SetContent('')
                  .SetFontSize(16)
                  .SetFontWeight(TFontWeight.Bold)
                  .SetFontColor(TAlphaColorRec.Black)
                  .SetOnClick(
                    procedure
                    begin
                      MainData.QRCodeContent := Frame.GetContent;
                      Navigator.CloseRoute(ARouteName);
                      Navigator.RouteTo('QRGenerator');
                    end
                  );

                  LResultTextFrame := Frame;
                end
              )
              .AddFrame<TTextFrame>(
                50
              , procedure (Frame: TTextFrame)
                begin
                  Frame
                  .SetContent('')
                  .SetFontSize(14)
                  .SetFontColor(TAlphaColorRec.Black);

                  LFormatTextFrame := Frame;
                end
              )
              ;
            end
          );
        end
      )
      .AddActionButton('Restart'
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
          Navigator.RouteTo(ARouteName);
        end
      )
      .AddActionButton('Back'
      , procedure
        begin
          MainData.StopScanning(True);
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );
end;

{ TBarcodeFormatHelper }

function TBarcodeFormatHelper.ToString: string;
begin
  case Self of
    Auto: Result := 'Auto';
    AZTEC: Result := 'AZTEC';
    CODABAR: Result := 'CODABAR';
    CODE_39: Result := 'CODE_39';
    CODE_93: Result := 'CODE_93';
    CODE_128: Result := 'CODE_128';
    DATA_MATRIX: Result := 'DATA_MATRIX';
    EAN_8: Result := 'EAN_8';
    EAN_13: Result := 'EAN_13';
    ITF: Result := 'ITF';
    MAXICODE: Result := 'MAXICODE';
    PDF_417: Result := 'PDF_417';
    QR_CODE: Result := 'QR_CODE';
    RSS_14: Result := 'RSS_14';
    RSS_EXPANDED: Result := 'RSS_EXPANDED';
    UPC_A: Result := 'UPC_A';
    UPC_E: Result := 'UPC_E';
    UPC_EAN_EXTENSION: Result := 'UPC_EAN_EXTENSION';
    MSI: Result := 'MSI';
    PLESSEY: Result := 'PLESSEY';
  end;
end;

end.