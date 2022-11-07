unit FMXER.ChipFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TChipFrame = class(TFrame)
    Button: TSpeedButton;
    Shape: TRoundRect;
    procedure ButtonClick(Sender: TObject);
  private
    FOnClickHandler: TProc;
    FForegroundColor: TAlphaColor;
    FBackgroundColor: TAlphaColor;
  public
    constructor Create(AOwner: TComponent); override;

    function SetText(const AText: string): TChipFrame;
    function SetBackgroundColor(const AColor: TAlphaColor): TChipFrame;
    function SetForegroundColor(const AColor: TAlphaColor): TChipFrame;

    property OnClickHandler: TProc read FOnClickHandler write FOnClickHandler;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts
;

constructor TChipFrame.Create(AOwner: TComponent);
begin
  inherited;
  SetBackgroundColor(TAppColors.SolidBackgroundColor);
  SetForegroundColor(TAppColors.PrimaryColor);
end;


function TChipFrame.SetBackgroundColor(const AColor: TAlphaColor): TChipFrame;
begin
  Result := Self;
  FBackgroundColor := AColor;
  Shape.Fill.Color := FBackgroundColor;
end;

function TChipFrame.SetForegroundColor(const AColor: TAlphaColor): TChipFrame;
begin
  Result := Self;
  FForegroundColor := AColor;
  Shape.Stroke.Color := FForegroundColor;
  Button.TextSettings.FontColor := FForegroundColor;
end;

function TChipFrame.SetText(const AText: string): TChipFrame;
begin
  Result := Self;
  Button.Text := AText;
end;

procedure TChipFrame.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnClickHandler) then
    FOnClickHandler();
end;

end.
