unit Routes.QRGenerator;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineQRGeneratorRoute(const ARouteName: string);

implementation

uses
  FMX.Types
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.QRCodeFrame, FMXER.EditFrame, FMXER.ColorButtonFrame
, FMXER.TrackbarFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.HorzPairFrame, FMXER.IconFontsData, Icons.Utils
, Data.Main
;


procedure DefineQRGeneratorRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      MainData.ClearQRCodeChangeSubscribers;

      Scaffold
      .SetTitle('Generator')

      // Solid background
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BGFrame: TBackgroundFrame)
        begin
          BGFrame
          .SetFillColor(TAlphaColorRec.White)
          // COLUMN
          .SetContentAsForm<TColumnForm>(
            procedure (Col: TColumnForm)
            begin
              Col

              // Edit (QRCodeContent)
              .AddFrame<TEditFrame>(
                50
              , procedure (Frame: TEditFrame)
                begin
                  Frame
                  .SetText(MainData.QRCodeContent)
                  .SetTextPrompt('QRCode content here')
                  .SetPadding(5)
                  ;

                  Frame.OnChangeProc :=
                    procedure (ATracking: Boolean)
                    begin
                      MainData.QRCodeContent := Frame.GetText;
                    end;
                end
              )

              // Pair: ColorButton | ColorButton
              .AddFrame<THorzPairFrame>(
                50
              , procedure (Pair: THorzPairFrame)
                begin
                  Pair
                  .SetContentAsFrame<TColorButtonFrame, TColorButtonFrame>(
                    // Left: QRCode color
                    procedure (Button: TColorButtonFrame)
                    begin
                      Button
                      .SetColorValue(MainData.QRCodeColor)
                      .SetText('QR color')
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeColorSelection');
                        end
                      )
                      .SetMargin(0, 0, 2.5, 0);

                      MainData.SubscribeQRCodeChange(
                        procedure
                        begin
                          Button
                          .SetColorValue(MainData.QRCodeColor);
                        end
                      );
                    end
                    // Right: QRCode background color
                  , procedure (Button: TColorButtonFrame)
                    begin
                      Button
                      .SetColorValue(MainData.QRCodeBGColor)
                      .SetText('BG color')
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeBGColorSelection');
                        end
                      )
                      .SetMargin(2.5, 0, 0, 0);

                      MainData.SubscribeQRCodeChange(
                        procedure
                        begin
                          Button
                          .SetColorValue(MainData.QRCodeBGColor);
                        end
                      );

                    end
                  )
                  // Pair
                  .SetPadding(5);
                end
              )

              // Trackbar (Radius factor)
              .AddFrame<TTrackbarFrame>(
                50
              , procedure (Frame: TTrackbarFrame)
                begin
                  Frame
                  .SetCaption('Radius factor')
                  .SetCaptionPosition(TCaptionPosition.Left)
                  .SetValue(MainData.QRRadiusFactor)
                  .SetMin(0.001)
                  .SetMax(0.5)
                  .SetFrequency(0.01)
                  .SetOnChangeProc(
                    procedure (ARadiusFactor: Single)
                    begin
                      MainData.QRRadiusFactor := ARadiusFactor;
                    end
                  )
                  .SetPadding(5);
                end
              )

              // Stack: Background | QRCode
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
                      BGFrame.SetFillColor(MainData.QRCodeBGColor);
                      LBGFrame := BGFrame;
                    end
                  )
                  // QRCode
                  .AddFrame<TQRCodeFrame>(
                    procedure (AQR: TQRCodeFrame)
                    begin
                      AQR
                      .SetContent(MainData.QRCodeContent)
                      .SetOverrideColor(MainData.QRCodeColor)
                      .SetRadiusFactor(MainData.QRRadiusFactor)
                      .SetAlignClient
                      .SetMargin(20)
                      .SetHitTest(True);

                      MainData.SubscribeQRCodeChange(
                        procedure
                        begin
                          AQR
                          .SetContent(MainData.QRCodeContent)
                          .SetOverrideColor(MainData.QRCodeColor)
                          .SetRadiusFactor(MainData.QRRadiusFactor);

                          LBGFrame
                          .SetFillColor(MainData.QRCodeBGColor);
                        end
                      );
                    end
                  )
                  // Stack
                  .SetPadding(5);
                end
              );
            end
          );
        end
      )

      // Action buttons

      .AddActionButton(
        IconFonts.MD.share
      , TAppColors.PrimaryTextColor
      , procedure
        begin
          MainData.ShareQRCodeContent;
        end
      )

      .AddActionButton(
        IconFonts.MD.arrow_left
      , TAppColors.PrimaryTextColor
      , procedure
        begin
          MainData.ClearQRCodeChangeSubscribers;
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );
end;

end.
