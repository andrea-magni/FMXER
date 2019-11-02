unit UI.Consts;

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
  public
    const MATERIAL_BLUE_800   = $FF1565C0;
    const MATERIAL_RED_800    = $FFc62828;
    const MATERIAL_AMBER_800   = $FFff8f00;
    const MATERIAL_INDIGO_800 = $FF283593;
    const MATERIAL_PURPLE_800 = $FF6a1b9a;

    class constructor ClassCreate;

    class property PrimaryColor: TAlphaColor
      read FPrimaryColor write FPrimaryColor;
    class property PrimaryTextColor: TAlphaColor
      read FPrimaryTextColor write FPrimaryTextColor;
    class property SolidBackgroundColor: TAlphaColor
      read FSolidBackgroundColor write FSolidBackgroundColor;
    class property LightBackgroundColor: TAlphaColor
      read FLightBackgroundColor write FLightBackgroundColor;
  end;

implementation

{ TAppColors }

class constructor TAppColors.ClassCreate;
begin
  TAppColors.PrimaryColor := MATERIAL_AMBER_800;
  TAppColors.PrimaryTextColor := TAlphaColorRec.White;
  TAppColors.SolidBackgroundColor := TAlphaColorRec.Lightgray;
  TAppColors.LightBackgroundColor := TAlphaColorRec.Silver;
end;

end.
