unit FMXER.ButtonFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.Actions, FMX.ActnList;

type
  TButtonFrame = class(TFrame)
    CaptionLabel: TLabel;
    ExtraLabel: TLabel;
    ButtonControl: TButton;
    ActionList1: TActionList;
    ButtonAction: TAction;
    procedure ButtonActionExecute(Sender: TObject);
    procedure ButtonActionUpdate(Sender: TObject);
  private
    FOnClickProc: TProc<TButtonFrame>;
    FOnUpdateProc: TProc<TAction>;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetExtraText: string;
    procedure SetExtraText(const Value: string);
    function GetIsDefault: Boolean;
    procedure SetIsDefault(const Value: Boolean);
  public
    property Caption: string read GetCaption write SetCaption;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property ExtraText: string read GetExtraText write SetExtraText;
    property Text: string read GetText write SetText;
    property OnClickProc: TProc<TButtonFrame> read FOnClickProc write FOnClickProc;
    property OnUpdateProc: TProc<TAction> read FOnUpdateProc write FOnUpdateProc;
  end;

implementation

{$R *.fmx}

{ TEditFrame }

procedure TButtonFrame.ButtonActionExecute(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc(Self);
end;

procedure TButtonFrame.ButtonActionUpdate(Sender: TObject);
begin
  if Assigned(FOnUpdateProc) then
    FOnUpdateProc(ButtonAction);
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
