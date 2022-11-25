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
, FMXER.TextFrame, FMXER.AccessoryFrame, FMXER.IconFontsGlyphFrame
, FMXER.IconFontsData
, Data.Main
;

const SCAN_POINT_DURATION = 2000;

type
  TBarcodeFormatHelper = record helper for TBarcodeFormat
    function ToString: string;
  end;

// Draws points on image frame when Scanning = True
procedure DrawPointsScanning(ACanvas: ISkCanvas; APaint: ISkPaint; AOffsetX, AOffsetY: Single);
begin
  var LNow := Now;
  for var LScanPoint in MainData.ScanPoints do
  begin
    var LPoint := LScanPoint.PointF;
    var LAge := MillisecondsBetween(LScanPoint.TimeStamp, LNow);
    var LAlpha := Round(((SCAN_POINT_DURATION - LAge)/SCAN_POINT_DURATION) * 255);
    if LAlpha < 0 then
      LAlpha := 0;

    LPoint.Offset(AOffsetX, AOffsetY);
    APaint.Color := TAlphaColorRec.Red;
    APaint.Alpha := LAlpha;
    ACanvas.DrawCircle(LPoint, 5, APaint);
  end;
end;

// Draws points on image frame when Scanning = False
procedure DrawPointsResult(ACanvas: ISkCanvas; APaint: ISkPaint; AOffsetX, AOffsetY: Single);
begin
  for var LPoint in MainData.ScanResultPoints do
  begin
    LPoint.Offset(AOffsetX, AOffsetY);
    APaint.Color := TAppColors.PrimaryColor;
    APaint.Alpha := $FF;
    ACanvas.DrawRect(RectF(LPoint.x - 5, LPoint.y - 5, LPoint.x + 5, LPoint.y + 5), APaint);
  end;
end;


procedure DefineQRReaderRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('Reader')

      // Solid background
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BGFrame: TBackgroundFrame)
        begin
          BGFrame
          .SetFillColor(TAlphaColorRec.White)
          // Column
          .SetContentAsForm<TColumnForm>(
            procedure (Col: TColumnForm)
            begin
              var LResultTextFrame: TTextFrame := nil;
              var LFormatTextFrame: TTextFrame := nil;
              var LResultGlyphFrame: TIconFontsGlyphFrame := nil;

              Col
              // Stack: Background | PaintBox
              .AddFrame<TStackFrame>(
                Scaffold.Width
              , procedure (Stack: TStackFrame)
                begin
                  var LBGFrame: TBackgroundFrame;

                  Stack
                  // Background
                  .AddFrame<TBackgroundFrame>(
                    procedure (BGFrame: TBackgroundFrame)
                    begin
                      BGFrame.SetFillColor(TAppColors.PrimaryColor);
                      LBGFrame := BGFrame;
                    end
                  )
                  // PaintBox
                  .AddFrame<TPaintBoxFrame>(
                    procedure (PaintBoxFrame: TPaintBoxFrame)
                    begin

                      // Start scanning with camera and set related event handlers
                      MainData.StartScanning(
                        // IMAGE FRAME AVAILABLE Handler
                        procedure (ABitmap: TBitmap)
                        begin
                          PaintBoxFrame.PaintBox.Redraw;
                          MainData.QueueFrame(ABitmap);
                        end
                        // SCAN RESULT AVAILABLE Handler
                      , procedure (AResult: TReadResult; AFrame: TBitmap)
                        begin
                          MainData.StopScanning(True);

                          LResultTextFrame.SetContent(AResult.text);
                          LFormatTextFrame.SetContent(AResult.BarcodeFormat.ToString);
//                          LResultGlyphFrame.Visible := not AResult.text.IsEmpty;

                          // force last redraw in order to show acquired scan result
                          PaintBoxFrame.PaintBox.Redraw;
                        end
                      );

                      // Setup PaintBox
                      PaintBoxFrame
                      .SetAlignClient
                      .SetMargin<TPaintBoxFrame>(10)
                      .SetOnDrawHandler(
                        procedure(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single)
                        begin
                          var LOffsetX := -((MainData.ImageFrame.Width - ADest.Width) / 2);
                          var LOffsetY := -((MainData.ImageFrame.Height - ADest.Height) / 2);

                          var LPaint: ISkPaint := TSkPaint.Create;

                          if MainData.Scanning then
                          begin
                            ACanvas.DrawImage(MainData.ImageFrame.ToSkImage()
                              , LOffsetX, LOffsetY, LPaint);
                            DrawPointsScanning(ACanvas, LPaint, LOffsetX, LOffsetY);
                          end
                          else
                          begin
                            ACanvas.DrawImage(MainData.ScanResultFrame.ToSkImage()
                              , LOffsetX, LOffsetY, LPaint);
                            DrawPointsResult(ACanvas, LPaint, LOffsetX, LOffsetY);
                          end;
                        end
                      );

                    end
                  )
                  // Stack
                  .SetPadding(5);
                end
              )

              // Accessory: Text | Glyph
              .AddFrame<TAccessoryFrame>(
                50
              , procedure (Accessory: TAccessoryFrame)
                begin
                  Accessory
                  // Text (ResultTextFrame)
                  .SetContentAsFrame<TTextFrame>(
                    procedure (Frame: TTextFrame)
                    begin
                      Frame
                      .SetContent('')
                      .SetFontSize(16)
                      .SetFontWeight(TFontWeight.Bold)
                      .SetFontColor(TAlphaColorRec.Black)
                      .SetOnClick(
                        procedure
                        begin
                          MainData.StopScanning(True);
                          MainData.QRCodeContent := Frame.GetContent;
                          Navigator.CloseRoute(ARouteName);
                          Navigator.RouteTo('QRGenerator');
                        end
                      );

                      LResultTextFrame := Frame;
                    end
                  )
                  // Glyph (ResultGlyphFrame)
                  .SetRightAsFrame<TIconFontsGlyphFrame>(
                    50
                  , procedure (Glyph: TIconFontsGlyphFrame)
                    begin
                      Glyph
                      .SetIcon(IconFonts.MD.qrcode_edit)
                      .SetOnClickProc(
                        procedure
                        begin
                          MainData.StopScanning(True);
                          MainData.QRCodeContent := LResultTextFrame.GetContent;
                          Navigator.CloseRoute(ARouteName);
                          Navigator.RouteTo('QRGenerator');
                        end
                      )
                      .SetMargin(5);

                      LResultGlyphFrame := Glyph;
                    end
                  );
                end
              )

              // Text (ScanResultFormat)
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
              );
            end
          );
        end
      )

      // Action buttons

      .AddActionButton(
        IconFonts.MD.refresh
      , TAppColors.PrimaryTextColor
      , procedure
        begin
          MainData.StopScanning(True);
          Navigator.CloseRoute(ARouteName);
          Navigator.RouteTo(ARouteName);
        end
      )

      .AddActionButton(
        IconFonts.MD.close
      , TAppColors.PrimaryTextColor
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
