unit Frames.WeatherSituation;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation;

type
  TWeatherSituationFrame = class(TFrame)
    Layout1: TLayout;
    LocationLabel: TLabel;
  private
    FLocation: string;
    procedure SetLocation(const ANewLocation: string);
  public
    property Location: string read FLocation write SetLocation;
  end;

implementation

{$R *.fmx}

{ TWeatherSituationFrame }

procedure TWeatherSituationFrame.SetLocation(const ANewLocation: string);
begin
  if FLocation <> ANewLocation then
  begin
    FLocation := ANewLocation;
    LocationLabel.Text := FLocation;

  end;
end;

end.
