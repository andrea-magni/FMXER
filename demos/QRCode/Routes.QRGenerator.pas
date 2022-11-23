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
, FMXER.QRCodeFrame, FMXER.EditFrame, FMXER.ButtonFrame
, FMXER.TrackbarFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.HorzPairFrame
, Data.Main
;


procedure DefineQRGeneratorRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('Generator')
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BGFrame: TBackgroundFrame)
        begin
          BGFrame
          .SetFillColor(TAlphaColorRec.White)
          .SetContentAsForm<TColumnForm>(
            procedure (Col: TColumnForm)
            begin
              Col
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
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeColorSelection');
                        end
                      )
                      .SetMargin(0, 0, 2.5, 0);
                    end
                  , procedure (Button: TButtonFrame)
                    begin
                      Button
                      .SetText('BG color')
                      .SetOnClickHandler(
                        procedure
                        begin
                          Navigator.RouteTo('QRCodeBGColorSelection');
                        end
                      )
                      .SetMargin(2.5, 0, 0, 0);
                    end
                  )
                  .SetPadding(5);
                end
              )
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

                      MainData.ClearQRCodeChangeSubscribers;

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
                  .SetPadding(5);
                end
              );
            end
          );
        end
      )
      .AddActionButton('Share'
      , procedure
        begin
          MainData.ShareQRCodeContent;
        end
      )
      .AddActionButton('Back'
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
