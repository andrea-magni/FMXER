unit FMXER.HorzDividerFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  THorzDividerFrame = class(TFrame)
    DividerLine: TLine;
  private
  public
    constructor Create(AOwner: TComponent); override;

  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;

{ THorzDividerFrame }

constructor THorzDividerFrame.Create(AOwner: TComponent);
begin
  inherited;
  DividerLine.Stroke.Color := TAppColors.DividerColor;
end;

end.
