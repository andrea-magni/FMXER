unit FMXER.LogoFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  TLogoFrame = class(TFrame)
    LogoImage: TImage;
  private
    FLogoResource: string;
    procedure SetLogoResource(const Value: string);
  public
    property LogoResource: string read FLogoResource write SetLogoResource;
  end;

implementation

{$R *.fmx}

{ TLogoFrame }

procedure TLogoFrame.SetLogoResource(const Value: string);
begin
  if FLogoResource <> Value then
  begin
    FLogoResource := Value;
    var LStream := TResourceStream.Create(hInstance, FLogoResource, RT_RCDATA);
    try
      LogoImage.Bitmap.LoadFromStream(LStream);
    finally
      LStream.Free;
    end;
  end;
end;

end.
