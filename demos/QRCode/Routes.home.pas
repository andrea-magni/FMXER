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
  FMXER.TrackbarFrame, FMXER.StackFrame, FMXER.BackgroundFrame
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
            90
          , procedure (Frame: TEditFrame)
            begin
              Frame
//              .SetCaption('Content')
              .SetTextPrompt('QRCode content here')
//              .SetMarginT(5)
              ;

              Frame.OnChangeProc :=
                procedure (ATracking: Boolean)
                begin
                  MainData.QRCodeContent := Frame.GetText;
                end;
            end
          )
          .AddForm<TRowForm>(
            75
          , procedure (Row: TRowForm)
            begin
              Row
              .AddFrame<TButtonFrame>(
                100
              , procedure (Frame: TButtonFrame)
                begin
                  Frame
                  .SetText('QR color')
                  .SetMargin(5, 0, 0, 0);

                  Frame.OnClickHandler :=
                    procedure
                    begin
                      Navigator.RouteTo('QRCodeColorSelection');
                    end;
                end
              )
              .AddFrame<TButtonFrame>(
                100
              , procedure (Frame: TButtonFrame)
                begin
                  Frame
                  .SetText('BG color')
                  .SetMargin(5, 0, 0, 0);

                  Frame.OnClickHandler :=
                    procedure
                    begin
                      Navigator.RouteTo('QRCodeBGColorSelection');
                    end;
                end
              )
              .AddFrame<TTrackbarFrame>(
                150
              , procedure (Frame: TTrackbarFrame)
                begin
                  Frame
                  .SetCaption('Radius factor')
                  .SetValue(MainData.QRRadiusFactor)
                  .SetMin(0.001)
                  .SetMax(0.5)
                  .SetFrequency(0.01)
                  .SetMargin(5, 0, 0, 0);

                  Frame.OnChangeProc :=
                    procedure (ARadiusFactor: Single)
                    begin
                      MainData.QRRadiusFactor := ARadiusFactor;
                    end;
                end
              );
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
              .SetMarginT(10);
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
