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

    procedure AddChip(const AText: string; const AConfigProc: TProc<TChipFrame> = nil);
    property DefaultConfig: TProc<TChipFrame> read FDefaultConfig write FDefaultConfig;
  end;

implementation

{$R *.fmx}

{ TChipsRowFrame }

procedure TChipsFrame.AddChip(const AText: string;
  const AConfigProc: TProc<TChipFrame>);
var
  LFrame: TChipFrame;
begin
  LFrame := TChipFrame.Create(Self);
  try
    LFrame.Name := '';
    LFrame.Text := AText;
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

end.
