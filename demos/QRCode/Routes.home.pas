unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineHomeRoute(const AName: string);

implementation

uses
  FMX.Types
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.ButtonFrame
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
          .AddFrame<TButtonFrame>(
            50
          , procedure (Button: TButtonFrame)
            begin
              Button
              .SetText('Generator')
              .SetOnClickHandler(
                procedure
                begin
                  Navigator.RouteTo('QRGenerator');
                end
              )
              .SetMargin(5);
            end
          )
          .AddFrame<TButtonFrame>(
            50
          , procedure (Button: TButtonFrame)
            begin
              Button
              .SetText('Reader')
              .SetOnClickHandler(
                procedure
                begin
                  MainData.CameraStart;
                  Navigator.RouteTo('QRReader');
                end
              )
              .SetMargin(5);
            end
          )
          .SetPadding(5);
        end
      );
    end
  );
end;

end.
