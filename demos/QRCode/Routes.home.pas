unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes, FMX.Types;

procedure DefineHomeRoute(const AName: string);

implementation

uses
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc,
  FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.RowForm,
  FMXER.QRCodeFrame, FMXER.EditFrame, FMXER.ButtonFrame,
  FMXER.TrackbarFrame, FMXER.StackFrame, FMXER.BackgroundFrame,
  FMXER.HorzPairFrame
, Data.Main
;


procedure DefineHomeRoute(const AName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(AName
  , procedure (Home: TScaffoldForm)
    begin
      Home
      .SetTitle('QRCode demo')
      .SetContentAsForm<TColumnForm>(
        procedure (Col: TColumnForm)
        begin
          Col
          .AddFrame<TEditFrame>(
            50
          , procedure (Frame: TEditFrame)
            begin
              Frame
//              .SetCaption('Content')
              .SetTextPrompt('QRCode content here')
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
                  .SetMargin(5);

                  Button.OnClickHandler :=
                    procedure
                    begin
                      Navigator.RouteTo('QRCodeColorSelection');
                    end;
                end
              , procedure (Button: TButtonFrame)
                begin
                  Button
                  .SetText('BG color')
                  .SetMargin(5);

                  Button.OnClickHandler :=
                    procedure
                    begin
                      Navigator.RouteTo('QRCodeBGColorSelection');
                    end;
                end
              );
            end
          )
          .AddFrame<TTrackbarFrame>(
            75
          , procedure (Frame: TTrackbarFrame)
            begin
              Frame
              .SetCaption('Radius factor')
              .SetValue(MainData.QRRadiusFactor)
              .SetMin(0.001)
              .SetMax(0.5)
              .SetFrequency(0.01)
              .SetMargin(5, 0, 5, 0);

              Frame.OnChangeProc :=
                procedure (ARadiusFactor: Single)
                begin
                  MainData.QRRadiusFactor := ARadiusFactor;
                end;
            end
          )
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
              .SetMarginT(5);
            end
          )
        end
      )
      .AddActionButton('Share'
      , procedure
        begin
          MainData.ShareQRCodeContent;
        end
      );
    end
  );
end;

end.
