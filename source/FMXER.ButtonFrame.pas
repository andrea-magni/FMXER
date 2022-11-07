unit FMXER.ButtonFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.Actions, FMX.ActnList, Skia,
  Skia.FMX, FMX.Objects;

type
  TButtonFrame = class(TFrame)
    ButtonControl: TButton;
    ActionList1: TActionList;
    ButtonAction: TAction;
    CaptionLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    BackgroundRectangle: TRectangle;
    procedure ButtonActionExecute(Sender: TObject);
    procedure ButtonActionUpdate(Sender: TObject);
  private
    FOnClickHandler: TProc;
    FOnUpdateHandler: TProc<TAction>;
    function GetIsDefault: Boolean;
    procedure SetIsDefault(const Value: Boolean);
    function GetBackgroundFill: TBrush;
    function GetBackgroundStroke: TStrokeBrush;
  public
    function SetCaption(const ACaption: string): TButtonFrame;
    function SetExtraText(const AExtraText: string): TButtonFrame;
    function SetText(const AText: string): TButtonFrame;
    function SetBackgroundFillColor(const AColor: TAlphaColor): TButtonFrame;
    function SetBackgroundStrokeColor(const AColor: TAlphaColor): TButtonFrame;
    function SetBackgroundStrokeThickness(const AThickness: Single): TButtonFrame;
    function SetBackgroundVisible(const AVisible: Boolean): TButtonFrame;
    function SetBackgroundOpacity(const AOpacity: Single): TButtonFrame;

    property BackgroundFill: TBrush read GetBackgroundFill;
    property BackgroundStroke: TStrokeBrush read GetBackgroundStroke;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property OnClickHandler: TProc read FOnClickHandler write FOnClickHandler;
    property OnUpdateHandler: TProc<TAction> read FOnUpdateHandler write FOnUpdateHandler;
  end;

implementation

{$R *.fmx}

{ TEditFrame }

procedure TButtonFrame.ButtonActionExecute(Sender: TObject);
begin
  if Assigned(FOnClickHandler) then
    FOnClickHandler();
end;

procedure TButtonFrame.ButtonActionUpdate(Sender: TObject);
begin
  if Assigned(FOnUpdateHandler) then
    FOnUpdateHandler(ButtonAction);
end;

function TButtonFrame.SetExtraText(const AExtraText: string): TButtonFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
end;

function TButtonFrame.GetBackgroundFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TButtonFrame.GetBackgroundStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

function TButtonFrame.GetIsDefault: Boolean;
begin
  Result := ButtonControl.Default;
end;

function TButtonFrame.SetBackgroundFillColor(
  const AColor: TAlphaColor): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Fill.Color := AColor;
end;

function TButtonFrame.SetBackgroundOpacity(
  const AOpacity: Single): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Opacity := AOpacity;
end;

function TButtonFrame.SetBackgroundStrokeColor(
  const AColor: TAlphaColor): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Stroke.Color := AColor;
end;

function TButtonFrame.SetBackgroundStrokeThickness(
  const AThickness: Single): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Stroke.Thickness := AThickness;
end;

function TButtonFrame.SetBackgroundVisible(
  const AVisible: Boolean): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Visible := AVisible;
end;

function TButtonFrame.SetCaption(const ACaption: string): TButtonFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
end;

procedure TButtonFrame.SetIsDefault(const Value: Boolean);
begin
  ButtonControl.Default := Value;
end;

function TButtonFrame.SetText(const AText: string): TButtonFrame;
begin
  Result := Self;
  ButtonAction.Caption := AText;
end;

end.
