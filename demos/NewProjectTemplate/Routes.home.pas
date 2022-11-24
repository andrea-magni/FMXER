unit Routes.home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.LogoFrame
;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('New Project')
      .SetContentAsFrame<TLogoFrame>
      .AddActionButton('X'
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );
    end
  );
end;

end.
