unit FMXER.ActivityBubblesFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Ani, Skia, Skia.FMX;

type
  TActivityBubblesFrame = class(TFrame)
    SkAnimatedImage1: TSkAnimatedImage;
    CaptionLabel: TSkLabel;
  private
    function GetText: string;
    procedure SetText(const Value: string);
  public
    property Text: string read GetText write SetText;
  end;

implementation

{$R *.fmx}

{ TActivityBubblesFrame }

function TActivityBubblesFrame.GetText: string;
begin
  Result := CaptionLabel.Text;
end;

procedure TActivityBubblesFrame.SetText(const Value: string);
begin
  CaptionLabel.Text := Value;
end;

end.
