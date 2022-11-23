unit Routes.colorPicker;

interface

uses
  Classes, SysUtils, Types, UITypes, FMX.Types;

procedure DefineColorPickerRoute(const ARouteName: string;
  const ATitle: string;
  const AGetColorFunc: TFunc<TAlphaColor>;
  const ASetColorProc: TProc<TAlphaColor>
);

implementation

uses
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc,
  FMXER.ScaffoldForm, FMXER.ColorPickerFrame, FMXER.BackgroundFrame
;

procedure DefineColorPickerRoute(const ARouteName: string;
  const ATitle: string;
  const AGetColorFunc: TFunc<TAlphaColor>;
  const ASetColorProc: TProc<TAlphaColor>
);
begin
  Navigator.DefineRoute<TScaffoldForm>(ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle(ATitle)
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (BGFrame: TBackgroundFrame)
        begin
          var LColor: TAlphaColorRec := TAlphaColorRec.Create(TAlphaColorRec.Black);
          LColor.A := $AA;

          BGFrame
          .SetFillColor(LColor.Color)
          .SetContentAsFrame<TColorPickerFrame>(
            procedure (Frame: TColorPickerFrame)
            begin
              Frame
              .SetMargin<TColorPickerFrame>(20, 20, 20, 200)
              .SetColor(AGetColorFunc())
              .OnChangeProc := ASetColorProc;
            end
          );
        end
      )
      .AddActionButton('OK'
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );
    end
  );
end;

end.
