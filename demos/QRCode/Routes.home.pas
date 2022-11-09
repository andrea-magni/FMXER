unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes, FMX.Types;

procedure DefineHomeRoute(const AName: string);

implementation

uses
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc,
  FMXER.ScaffoldForm, FMXER.ColumnForm,
  FMXER.QRCodeFrame, FMXER.EditFrame, FMXER.ColorPickerFrame

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
            100
          , procedure (Frame: TEditFrame)
            begin
              Frame
              .SetCaption('Content')
              .SetTextPrompt('QRCode content here')
              .SetMarginT(10);

              Frame.OnChangeProc :=
                procedure (ATracking: Boolean)
                begin
                  MainData.QRCodeContent := Frame.GetText;
                end;
            end
          )

          .AddFrame<TColorPickerFrame>(
            100
          , procedure (Frame: TColorPickerFrame)
            begin
              Frame
              .SetCaption('Color')
              .SetColor(MainData.QRCodeColor)
              .SetMarginT(10);

              Frame.OnChangeProc :=
                procedure (AColor: TAlphaColor)
                begin
                  MainData.QRCodeColor := AColor;
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
              .SetAlignClient
              .SetMargin(2)
              .SetHitTest(True);

              MainData.SubscribeQRCodeChange(
                procedure (const AContent: string; const AColor: TAlphaColor)
                begin
                  AQR
                  .SetContent(AContent)
                  .SetOverrideColor(AColor);
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
