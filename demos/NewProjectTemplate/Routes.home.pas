unit Routes.home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.LogoFrame
, FMXER.IconFontsData, Icons.Utils, FMXER.UI.Consts
;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('New Project')
      .SetContentAsFrame<TLogoFrame>(
        procedure (Frame: TLogoFrame)
        begin
          Frame.Opacity := 0.10;
        end
      )
      .AddActionButton(IconFonts.ImageList, IconFonts.AddIcon(IconFonts.MD.close, TAppColors.PrimaryTextColor)
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );
    end
  );
end;

end.
