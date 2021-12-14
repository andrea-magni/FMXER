unit FMXER.ActivityBubblesFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Ani;

type
  TActivityBubblesFrame = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    Circle3: TCircle;
    Circle2: TCircle;
    Circle1: TCircle;
    OnShowAnimation: TFloatAnimation;
    Circle4: TCircle;
    Layout3: TLayout;
    Circle5: TCircle;
    Circle6: TCircle;
    Circle7: TCircle;
    FloatAnimation1: TFloatAnimation;
    Circle8: TCircle;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
