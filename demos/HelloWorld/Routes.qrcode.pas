unit Routes.qrcode;

interface

uses
  Classes, SysUtils, Types, UITypes, IOUtils, FMX.Dialogs, FMX.Types, FMX.Graphics,
  System.Messaging
, FMXER.Navigator;

function DefineQRCodeRoute(const ARouteName: string = 'qrcode'): TNavigator;

implementation

uses
  Skia, Skia.FMX

, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.QRCodeFrame, FMXER.BackgroundFrame
, Data.AppState;

function DefineQRCodeRoute(const ARouteName: string = 'qrcode'): TNavigator;
begin
  Result :=
   Navigator.DefineRoute<TScaffoldForm>(
     ARouteName
   , procedure (Home: TScaffoldForm)
     begin
       Home
       .SetTitle('QRCode')
       .SetContentAsFrame<TBackgroundFrame>(
         procedure (BGF: TBackgroundFrame)
         begin
           BGF
           .SetFillColor(TAlphaColorRec.White)
           .SetContentAsFrame<TQRCodeFrame>(
              procedure (QRF: TQRCodeFrame)
              begin
                QRF
                .SetContent(AppState.Something)
                .SetOverrideColor(TAlphaColorRec.Navy)
                .SetMargin(2)
                .SetHitTest(True);

                TMessageManager.DefaultManager.SubscribeToMessage(TSomethingChangedMsg
                , procedure (const Sender: TObject; const M: TMessage)
                  begin
                    var Msg := M as TSomethingChangedMsg;
                    var LValue := Msg.Value;
                    if LValue = '' then
                      LValue := 'No text available';
                    QRF.SetContent(LValue);
                  end
                );

                QRF.OnTapHandler :=
                  procedure(AImage: TFMXObject; APoint: TPointF)
                  begin
                    Navigator.CloseRoute('qrcode');
                  end;

              end
           );
         end
       )
     end
   );
end;

end.
