unit UI.Consts;

interface

uses
  Classes, SysUtils, UITypes;

type
  TAppColors = class
  public
    const MATERIAL_BLUE_800   = $FF1565C0;
    const MATERIAL_RED_800    = $FFc62828;
    const MATERIAL_AMBER_800   = $FFff8f00;
    const MATERIAL_INDIGO_800 = $FF283593;
    const MATERIAL_PURPLE_800 = $FF6a1b9a;

    const PRIMARY_COLOR = MATERIAL_AMBER_800;
    const PRIMARY_TEXT_COLOR = TAlphaColorRec.White;
    const SOLID_BACKGROUND_COLOR = TAlphaColorRec.Lightgray;
    const LIGHT_BACKGROUND_COLOR = TAlphaColorRec.Silver;
  end;

implementation

end.
