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
    function GetText: string;
    procedure SetText(const Value: string);
    procedure SetBackgroundColor(const Value: TAlphaColor);
    procedure SetForegroundColor(const Value: TAlphaColor);
  public
    constructor Create(AOwner: TComponent); override;

    property Text: string read GetText write SetText;
    property OnClickHandler: TProc read FOnClickHandler write FOnClickHandler;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property ForegroundColor: TAlphaColor read FForegroundColor write SetForegroundColor;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts
;

constructor TChipFrame.Create(AOwner: TComponent);
begin
  inherited;
  BackgroundColor := TAppColors.SolidBackgroundColor;
  ForegroundColor := TAppColors.PrimaryColor;
end;

function TChipFrame.GetText: string;
begin
  Result := Button.Text;
end;

procedure TChipFrame.SetBackgroundColor(const Value: TAlphaColor);
begin
  FBackgroundColor := Value;
  Shape.Fill.Color := FBackgroundColor;
end;

procedure TChipFrame.SetForegroundColor(const Value: TAlphaColor);
begin
  FForegroundColor := Value;
  Shape.Stroke.Color := FForegroundColor;
  Button.TextSettings.FontColor := FForegroundColor;
end;

procedure TChipFrame.SetText(const Value: string);
begin
  Button.Text := Value;
end;

procedure TChipFrame.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnClickHandler) then
    FOnClickHandler();
end;

end.
