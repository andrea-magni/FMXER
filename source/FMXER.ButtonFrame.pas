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
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetExtraText: string;
    procedure SetExtraText(const Value: string);
    function GetIsDefault: Boolean;
    procedure SetIsDefault(const Value: Boolean);
    function GetBackgroundFill: TBrush;
    function GetBackgroundStroke: TStrokeBrush;
  public
    property BackgroundFill: TBrush read GetBackgroundFill;
    property BackgroundStroke: TStrokeBrush read GetBackgroundStroke;
    property Caption: string read GetCaption write SetCaption;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property ExtraText: string read GetExtraText write SetExtraText;
    property Text: string read GetText write SetText;
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

function TButtonFrame.GetBackgroundFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TButtonFrame.GetBackgroundStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

function TButtonFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TButtonFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TButtonFrame.GetIsDefault: Boolean;
begin
  Result := ButtonControl.Default;
end;

function TButtonFrame.GetText: string;
begin
  Result := ButtonAction.Caption;
end;

procedure TButtonFrame.SetCaption(const Value: string);
begin
  CaptionLabel.Text := Value;
end;

procedure TButtonFrame.SetExtraText(const Value: string);
begin
  ExtraLabel.Text := Value;
end;

procedure TButtonFrame.SetIsDefault(const Value: Boolean);
begin
  ButtonControl.Default := Value;
end;

procedure TButtonFrame.SetText(const Value: string);
begin
  ButtonAction.Caption := Value;
end;

end.
