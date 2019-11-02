unit FMXER.UI.Consts;

interface

uses
  Classes, SysUtils, UITypes;

type
  TAppColors = class
  private
    class var FPrimaryColor: TAlphaColor;
    class var FPrimaryTextColor: TAlphaColor;
    class var FSolidBackgroundColor: TAlphaColor;
    class var FLightBackgroundColor: TAlphaColor;
    class var FDividerColor: TAlphaColor;
  public
    const MATERIAL_RED_400         = $FFef5350;
    const MATERIAL_PINK_400        = $FFec407a;
    const MATERIAL_PURPLE_400      = $FFab47bc;
    const MATERIAL_DEEP_PURPLE_400 = $FF7e57c2;
    const MATERIAL_INDIGO_400      = $FF5c6bc0;
    const MATERIAL_BLUE_400        = $FF42a5f5;
    const MATERIAL_LIGHT_BLUE_400  = $FF29b6f6;
    const MATERIAL_CYAN_400        = $FF26c6da;
    const MATERIAL_TEAL_400        = $FF26a69a;
    const MATERIAL_GREEN_400       = $FF66bb6a;
    const MATERIAL_LIGHT_GREEN_400 = $FF9ccc65;
    const MATERIAL_LIME_400        = $FFd4e157;
    const MATERIAL_YELLOW_400      = $FFffee58;
    const MATERIAL_AMBER_400       = $FFffca28;
    const MATERIAL_ORANGE_400      = $FFffa726;
    const MATERIAL_DEEP_ORANGE_400 = $FFff7043;
    const MATERIAL_BROWN_400       = $FF8d6e63;
    const MATERIAL_GREY_400        = $FFbdbdbd;
    const MATERIAL_BLUE_GREY_400   = $FF78909c;

    const MATERIAL_RED_800         = $FFc62828;
    const MATERIAL_PINK_800        = $FFad1457;
    const MATERIAL_PURPLE_800      = $FF6a1b9a;
    const MATERIAL_DEEP_PURPLE_800 = $FF4527a0;
    const MATERIAL_INDIGO_800      = $FF283593;
    const MATERIAL_BLUE_800        = $FF1565C0;
    const MATERIAL_LIGHT_BLUE_800  = $FF0277bd;
    const MATERIAL_CYAN_800        = $FF00838f;
    const MATERIAL_TEAL_800        = $FF00695c;
    const MATERIAL_GREEN_800       = $FF2e7d32;
    const MATERIAL_LIGHT_GREEN_800 = $FF558b2f;
    const MATERIAL_LIME_800        = $FF9e9d24;
    const MATERIAL_YELLOW_800      = $FFf9a825;
    const MATERIAL_AMBER_800       = $FFff8f00;
    const MATERIAL_ORANGE_800      = $FFef6c00;
    const MATERIAL_DEEP_ORANGE_800 = $FFd84315;
    const MATERIAL_BROWN_800       = $FF4e342e;
    const MATERIAL_GREY_800        = $FF424242;
    const MATERIAL_BLUE_GREY_800   = $FF37474f;

    class constructor ClassCreate;

    class property PrimaryColor: TAlphaColor
      read FPrimaryColor write FPrimaryColor;
    class property PrimaryTextColor: TAlphaColor
      read FPrimaryTextColor write FPrimaryTextColor;
    class property SolidBackgroundColor: TAlphaColor
      read FSolidBackgroundColor write FSolidBackgroundColor;
    class property LightBackgroundColor: TAlphaColor
      read FLightBackgroundColor write FLightBackgroundColor;
    class property DividerColor: TAlphaColor
      read FDividerColor write FDividerColor;
  end;

implementation

{ TAppColors }

class constructor TAppColors.ClassCreate;
begin
  TAppColors.PrimaryColor := MATERIAL_AMBER_800;
  TAppColors.PrimaryTextColor := TAlphaColorRec.White;
  TAppColors.SolidBackgroundColor := TAlphaColorRec.Lightgray;
  TAppColors.LightBackgroundColor := TAlphaColorRec.Silver;
  TAppColors.DividerColor := MATERIAL_GREY_800;
end;

end.
