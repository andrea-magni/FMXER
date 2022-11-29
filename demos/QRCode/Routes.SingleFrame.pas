unit Routes.SingleFrame;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineSingleFrameRoute(const ARouteName: string);

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
, FMXER.IconFontsData, FMXER.AnimatedImageFrame, FMXER.HorzPairFrame
, Data.Main
;

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

procedure DefineSingleFrameRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('Single frame')

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
                  var LBGFrame: TBackgroundFrame := nil;

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
//                      MainData.StartCameraScanning(
//                        // IMAGE FRAME AVAILABLE Handler
//                        procedure (ABitmap: TBitmap)
//                        begin
//                          LAniFrame.SetOpacity(0);
//                          PaintBoxFrame.PaintBox.Redraw;
//                          MainData.QueueFrame(ABitmap);
//                        end
//                        // SCAN RESULT AVAILABLE Handler
//                      , procedure (AResult: TReadResult; AFrame: TBitmap)
//                        begin
//                          MainData.StopCameraScanning(True);
//
//                          LResultTextFrame.SetContent(AResult.text);
//                          LFormatTextFrame.SetContent('QRCODE');
////                          LResultGlyphFrame.Visible := not AResult.text.IsEmpty;
//
//                          // force last redraw in order to show acquired scan result
//                          PaintBoxFrame.PaintBox.Redraw;
//                        end
//                      );

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

                  // Icon glyph
                  .AddFrame<TIconFontsGlyphFrame>(
                    procedure (Glyph: TIconFontsGlyphFrame)
                    begin
                      Glyph
                      .SetIcon(IconFonts.MD.image_plus, TAppColors.PrimaryTextColor)
                      .SetOnClickProc(
                        procedure
                        begin
                          Scaffold.ShowSnackBar('Not yet implemented', 3000
//                          , procedure
//                            begin
//                              Navigator.CloseRoute(ARouteName);
//                            end
                          );
                        end
                      )
                      .SetMargin(20);
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
                          MainData.QRCodeContent := Frame.GetContent;
                          Navigator.CloseRoute(ARouteName);
                          Navigator.RouteTo('QRGenerator');
                        end
                      );

                      LResultTextFrame := Frame;
                    end
                  )
                  .SetRightAsFrame<THorzPairFrame>(
                    100
                  , procedure (Pair: THorzPairFrame)
                    begin
                      Pair
                      // Glyph (ResultGlyphFrame)
                      .SetLeftContentAsFrame<TIconFontsGlyphFrame>(
                        procedure (Glyph: TIconFontsGlyphFrame)
                        begin
                          Glyph
                          .SetIcon(IconFonts.MD.qrcode_edit, TAppColors.PrimaryColor)
                          .SetOnClickProc(
                            procedure
                            begin
                              MainData.QRCodeContent := LResultTextFrame.GetContent;
                              Navigator.CloseRoute(ARouteName);
                              Navigator.RouteTo('QRGenerator');
                            end
                          )
                          .SetMargin(5);

                          LResultGlyphFrame := Glyph;
                        end
                      )
                      // Glyph (ResultGlyphFrame)
                      .SetRightContentAsFrame<TIconFontsGlyphFrame>(
                        procedure (Glyph: TIconFontsGlyphFrame)
                        begin
                          Glyph
                          .SetIcon(IconFonts.MD.open_in_app, TAppColors.PrimaryColor)
                          .SetOnClickProc(
                            procedure
                            begin
                              MainData.QRCodeContent := LResultTextFrame.GetContent;
                              Navigator.CloseRoute(ARouteName);
                              Navigator.RouteTo('Webview');
                            end
                          )
                          .SetMargin(5);

                          LResultGlyphFrame := Glyph;
                        end
                      );

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
          Navigator.CloseRoute(ARouteName);
          Navigator.RouteTo(ARouteName);
        end
      )

      .AddActionButton(
        IconFonts.MD.arrow_left
      , TAppColors.PrimaryTextColor
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );
end;

end.
