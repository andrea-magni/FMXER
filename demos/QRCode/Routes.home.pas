unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes, FMX.Types;

procedure DefineHomeRoute(const AName: string);

implementation

uses
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc,
  FMXER.ScaffoldForm, FMXER.ColumnForm,
  FMXER.QRCodeFrame, FMXER.EditFrame, FMXER.ColorPickerFrame,
  FMXER.TrackbarFrame
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
              .SetCaption('Content')
              .SetTextPrompt('QRCode content here')
              .SetMarginT(5);

              Frame.OnChangeProc :=
                procedure (ATracking: Boolean)
                begin
                  MainData.QRCodeContent := Frame.GetText;
                end;
            end
          )
          .AddFrame<TColorPickerFrame>(
            60
          , procedure (Frame: TColorPickerFrame)
            begin
              Frame
              .SetCaption('Color')
              .SetColor(MainData.QRCodeColor)
              .SetMarginT(5);

              Frame.OnChangeProc :=
                procedure (AColor: TAlphaColor)
                begin
                  MainData.QRCodeColor := AColor;
                end;
            end
          )
          .AddFrame<TTrackbarFrame>(
            60
          , procedure (Frame: TTrackbarFrame)
            begin
              Frame
              .SetCaption('Radius factor')
              .SetValue(MainData.QRRadiusFactor)
              .SetMin(0.001)
              .SetMax(0.5)
              .SetFrequency(0.01)
              .SetMarginT(5);

              Frame.OnChangeProc :=
                procedure (ARadiusFactor: Single)
                begin
                  MainData.QRRadiusFactor := ARadiusFactor;
                end;
            end
          )
          .AddFrame<TQRCodeFrame>(
            Col.Width
          , procedure (AQR: TQRCodeFrame)
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
                end
              );

//              AQR.OnTapHandler :=
//                procedure(AImage: TFMXObject; APoint: TPointF)
//                begin
//                  Navigator.RouteTo('qrcode');
//                end;
            end
          );
        end
      );
      Home.AddActionButton('Share'
      , procedure
        begin
          MainData.ShareQRCodeContent;
        end
      );
    end
  );
end;

end.
