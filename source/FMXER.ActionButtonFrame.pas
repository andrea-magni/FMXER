unit FMXER.ActionButtonFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Ani, FMX.Layouts
, SubjectStand, FrameStand, FormStand
, FMXER.TextFrame;

type
  TActionButtonFrame = class(TFrame)
    BackgroundCircle: TCircle;
    OverlayLayout: TLayout;
    FrameStand1: TFrameStand;
    ClickableLayout: TLayout;
    FormStand1: TFormStand;
    procedure ClickableLayoutClick(Sender: TObject);
  private
    FOnClickProc: TProc;
    FOverlayStand: string;
  protected
    FOverlay: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;

    function SetOverlayAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TActionButtonFrame;
    function SetOverlayAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TActionButtonFrame;

    // shortcuts
    function SetOverlayAsText(const AText: string;
      const AOnClickProc: TProc = nil;
      const AConfigProc: TProc<TTextFrame> = nil): TActionButtonFrame;

    function SetOnClickProc(const AOnClickProc: TProc): TActionButtonFrame;

    property OnClickProc: TProc read FOnClickProc write FOnClickProc;
    property OverlayStand: string read FOverlayStand write FOverlayStand;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;

{ TActionButtonFrame }

procedure TActionButtonFrame.ClickableLayoutClick(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc();
end;

constructor TActionButtonFrame.Create(AOwner: TComponent);
begin
  inherited;
  BackgroundCircle.Fill.Color := TAppColors.PrimaryColor;
end;

function TActionButtonFrame.SetOverlayAsForm<T>(const AConfigProc: TProc<T>): TActionButtonFrame;
begin
  Result := Self;
  FOverlay := FormStand1.NewAndShow<T>(OverlayLayout, OverlayStand, AConfigProc);
end;

function TActionButtonFrame.SetOverlayAsFrame<T>(
  const AConfigProc: TProc<T>): TActionButtonFrame;
begin
  Result := Self;
  FOverlay := FrameStand1.NewAndShow<T>(OverlayLayout, OverlayStand, AConfigProc);
end;

function TActionButtonFrame.SetOverlayAsText(const AText: string;
  const AOnClickProc: TProc; const AConfigProc: TProc<TTextFrame>): TActionButtonFrame;
begin
  Result := Self;
  SetOverlayAsFrame<TTextFrame>(
    procedure (ATextFrame: TTextFrame)
    begin
      ATextFrame.SetContent(AText);
      if Assigned(AConfigProc) then
        AConfigProc(ATextFrame);
    end
  );

  if Assigned(AOnClickProc) then
    OnClickProc := AOnClickProc;
end;

function TActionButtonFrame.SetOnClickProc(const AOnClickProc: TProc): TActionButtonFrame;
begin
  Result := Self;
  FOnClickProc := AOnClickProc;
end;

end.
