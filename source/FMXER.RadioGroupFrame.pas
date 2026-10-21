unit FMXER.RadioGroupFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Skia, FMX.Skia
, FMXER.Observable;

type
  /// <summary>A caption and a group of radio buttons, one per option, from
  /// top to bottom. The frame's Height follows the options (for AUTO_HEIGHT).</summary>
  TRadioGroupFrame = class(TFrame)
    CaptionLabel: TSkLabel;
    OptionsLayout: TLayout;
    ExtraLabel: TSkLabel;
  private
    FButtons: TList<TRadioButton>;
    FItemHeight: Single;
    FOnChangeProc: TProc<Integer>;
    FUpdating: Boolean;
    FItemIndexLink: TObservableLink<Integer>;
    procedure RadioButtonChange(Sender: TObject);
    procedure UpdateHeight;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetCaption: string;
    function GetExtraText: string;
    function GetItemIndex: Integer;
    function GetSelectedText: string;
    function GetCount: Integer;
    function GetItemHeight: Single;

    function SetCaption(const ACaption: string): TRadioGroupFrame;
    function SetExtraText(const AExtraText: string): TRadioGroupFrame;
    function AddOption(const AText: string): TRadioGroupFrame;
    function SetOptions(const AOptions: TArray<string>): TRadioGroupFrame;
    function ClearOptions: TRadioGroupFrame;
    function SetItemIndex(const AItemIndex: Integer): TRadioGroupFrame;
    function SetItemHeight(const AItemHeight: Single): TRadioGroupFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TRadioGroupFrame;
    /// <summary>Two-way binding: the group selects the option AObservable
    /// holds (-1: none), a tap writes it (OnChangeProc is still called). Set
    /// the options first. Removed with the element.</summary>
    function BindItemIndex(const AObservable: TObservable<Integer>): TRadioGroupFrame;

    property Buttons: TList<TRadioButton> read FButtons;
    property OnChangeProc: TProc<Integer> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TRadioGroupFrame }

function TRadioGroupFrame.BindItemIndex(const AObservable: TObservable<Integer>): TRadioGroupFrame;
begin
  Result := Self;
  if not Assigned(FItemIndexLink) then
    FItemIndexLink := TObservableLink<Integer>.Create(Self);
  FItemIndexLink.Bind(AObservable,
    procedure (AValue: Integer)
    begin
      if GetItemIndex <> AValue then
        SetItemIndex(AValue);
    end);
end;

function TRadioGroupFrame.AddOption(const AText: string): TRadioGroupFrame;
var
  LButton: TRadioButton;
begin
  Result := Self;
  LButton := TRadioButton.Create(Self);
  try
    // placed after the existing buttons, then aligned
    LButton.Position.Y := 10000;
    LButton.Parent := OptionsLayout;
    LButton.Height := FItemHeight;
    LButton.Align := TAlignLayout.Top;
    // one group per frame: two radio groups on a screen are independent
    LButton.GroupName := 'FMXERRadioGroup' + IntToHex(NativeUInt(Self));
    LButton.Text := AText;
    LButton.Tag := FButtons.Count;
    LButton.OnChange := RadioButtonChange;
    FButtons.Add(LButton);
  except
    LButton.Free;
    raise;
  end;
  UpdateHeight;
end;

function TRadioGroupFrame.ClearOptions: TRadioGroupFrame;
var
  LButton: TRadioButton;
begin
  Result := Self;
  for LButton in FButtons do
    LButton.Free;
  FButtons.Clear;
  UpdateHeight;
end;

constructor TRadioGroupFrame.Create(AOwner: TComponent);
begin
  inherited;
  FButtons := TList<TRadioButton>.Create;
  FItemHeight := 40;
  UpdateHeight;
end;

destructor TRadioGroupFrame.Destroy;
begin
  FreeAndNil(FButtons);
  inherited;
end;

function TRadioGroupFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TRadioGroupFrame.GetCount: Integer;
begin
  Result := FButtons.Count;
end;

function TRadioGroupFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TRadioGroupFrame.GetItemHeight: Single;
begin
  Result := FItemHeight;
end;

function TRadioGroupFrame.GetItemIndex: Integer;
var
  LIndex: Integer;
begin
  Result := -1;
  for LIndex := 0 to FButtons.Count - 1 do
    if FButtons[LIndex].IsChecked then
      Exit(LIndex);
end;

function TRadioGroupFrame.GetSelectedText: string;
var
  LIndex: Integer;
begin
  Result := '';
  LIndex := GetItemIndex;
  if LIndex >= 0 then
    Result := FButtons[LIndex].Text;
end;

procedure TRadioGroupFrame.RadioButtonChange(Sender: TObject);
begin
  // OnChange fires for the button checked and for the one unchecked: report
  // only the new selection
  if FUpdating or not (Sender as TRadioButton).IsChecked then
    Exit;
  if Assigned(FItemIndexLink) then
    FItemIndexLink.Write((Sender as TRadioButton).Tag);
  if Assigned(FOnChangeProc) then
    FOnChangeProc((Sender as TRadioButton).Tag);
end;

function TRadioGroupFrame.SetCaption(const ACaption: string): TRadioGroupFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
  CaptionLabel.Visible := not CaptionLabel.Text.IsEmpty;
  UpdateHeight;
end;

function TRadioGroupFrame.SetExtraText(
  const AExtraText: string): TRadioGroupFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
  UpdateHeight;
end;

function TRadioGroupFrame.SetItemHeight(
  const AItemHeight: Single): TRadioGroupFrame;
var
  LButton: TRadioButton;
begin
  Result := Self;
  FItemHeight := AItemHeight;
  for LButton in FButtons do
    LButton.Height := FItemHeight;
  UpdateHeight;
end;

function TRadioGroupFrame.SetItemIndex(
  const AItemIndex: Integer): TRadioGroupFrame;
var
  LIndex: Integer;
begin
  Result := Self;
  // like SetValue of the other elements, OnChangeProc is not called
  FUpdating := True;
  try
    for LIndex := 0 to FButtons.Count - 1 do
      FButtons[LIndex].IsChecked := LIndex = AItemIndex;
  finally
    FUpdating := False;
  end;
end;

function TRadioGroupFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<Integer>): TRadioGroupFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

function TRadioGroupFrame.SetOptions(
  const AOptions: TArray<string>): TRadioGroupFrame;
var
  LOption: string;
begin
  Result := Self;
  ClearOptions;
  for LOption in AOptions do
    AddOption(LOption);
end;

procedure TRadioGroupFrame.UpdateHeight;
var
  LHeight: Single;
begin
  LHeight := FButtons.Count * FItemHeight;
  if CaptionLabel.Visible then
    LHeight := LHeight + CaptionLabel.Height + CaptionLabel.Margins.Top + CaptionLabel.Margins.Bottom;
  if ExtraLabel.Visible then
    LHeight := LHeight + ExtraLabel.Height + ExtraLabel.Margins.Top + ExtraLabel.Margins.Bottom;
  OptionsLayout.Height := FButtons.Count * FItemHeight;
  Height := LHeight + Padding.Top + Padding.Bottom;
end;

end.
