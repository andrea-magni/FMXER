unit FMXER.ChipsFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts
, FMXER.ChipFrame;

type
  TChipsFrame = class(TFrame)
    Flow: TFlowLayout;
  private
    FDefaultConfig: TProc<TChipFrame>;
  public
    constructor Create(AOwner: TComponent); override;

    function AddChip(const AText: string; const AConfigProc: TProc<TChipFrame> = nil): TChipsFrame;
    function SetHorizontalGap(const AGap: Single): TChipsFrame;
    function SetVerticalGap(const AGap: Single): TChipsFrame;
    property DefaultConfig: TProc<TChipFrame> read FDefaultConfig write FDefaultConfig;
  end;

implementation

{$R *.fmx}

{ TChipsRowFrame }

function TChipsFrame.AddChip(const AText: string;
  const AConfigProc: TProc<TChipFrame>): TChipsFrame;
var
  LFrame: TChipFrame;
begin
  Result := Self;
  LFrame := TChipFrame.Create(Result);
  try
    LFrame.Name := '';
    LFrame.SetText(AText);
    LFrame.Parent := Flow;

    if Assigned(AConfigProc) then
      AConfigProc(LFrame)
    else
      if Assigned(FDefaultConfig) then
        FDefaultConfig(LFrame);
  except
    LFrame.Free;
    raise;
  end;
end;

constructor TChipsFrame.Create(AOwner: TComponent);
begin
  inherited;
  FDefaultConfig := nil;
end;

function TChipsFrame.SetHorizontalGap(const AGap: Single): TChipsFrame;
begin
  Result := Self;
  Flow.HorizontalGap := AGap;
end;

function TChipsFrame.SetVerticalGap(const AGap: Single): TChipsFrame;
begin
  Result := Self;
  Flow.VerticalGap := AGap;
end;

end.
