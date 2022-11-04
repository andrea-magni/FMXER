unit Routes.bubble;

interface

uses
  Classes, SysUtils, Types, UITypes, IOUtils, FMX.Dialogs
, FMXER.Navigator;

function DefineBubbleRoute(const ARouteName: string = 'bubble'): TNavigator;

implementation

uses
  FMXER.ContainerForm, FMXER.ActivityBubblesFrame
;

function DefineBubbleRoute(const ARouteName: string): TNavigator;
begin
  Result := Navigator.DefineRoute<TContainerForm>(
    ARouteName
  , procedure (ContainerF: TContainerForm)
    begin
      ContainerF.SetContentAsFrame<TActivityBubblesFrame>(
        procedure (ActivityBubbles: TActivityBubblesFrame)
        begin
          ActivityBubbles.HitTest := False; // click through
          ActivityBubbles.Padding.Rect := RectF(
            ContainerF.Width * 0.10
          , ContainerF.Height * 0.10
          , ContainerF.Width * 0.10
          , ContainerF.Height * 0.10
          );
        end
      );
    end
  );
end;


end.
