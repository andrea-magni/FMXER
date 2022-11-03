unit Routes.Bubbles;

interface
uses
  Classes, SysUtils, FMX.Dialogs
;

procedure BubblesRouteDefinition();

implementation

uses
  FMXER.Navigator
, FMXER.ContainerForm, FMXER.ActivityBubblesFrame
, Utils.UI;

procedure BubblesRouteDefinition();
begin
  Navigator.DefineRoute<TContainerForm>(
    'bubbles'
  , procedure (AForm: TContainerForm)
    begin
      AForm.SetContentAsFrame<TActivityBubblesFrame>();
    end
  );
end;


end.
