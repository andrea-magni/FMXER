unit FMXER.ComboBoxFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Layouts, System.Skia, FMX.Skia;

type
  /// <summary>A drop-down list (TComboBox) with a caption above and an extra
  /// text below: the FMX counterpart of the Flutter DropdownButton.</summary>
  TComboBoxFrame = class(TFrame)
    ComboBoxControl: TComboBox;
    CaptionLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    procedure ComboBoxControlChange(Sender: TObject);
  private
    FOnChangeProc: TProc<Integer>;
    FUpdating: Boolean;
  protected
  public
    function GetCaption: string;
    function GetExtraText: string;
    function GetItemIndex: Integer;
    function GetSelectedText: string;
    function GetCount: Integer;

    function SetCaption(const ACaption: string): TComboBoxFrame;
    function SetExtraText(const AExtraText: string): TComboBoxFrame;
    function AddItem(const AText: string): TComboBoxFrame;
    function SetItems(const AItems: TArray<string>): TComboBoxFrame;
    function ClearItems: TComboBoxFrame;
    function SetItemIndex(const AItemIndex: Integer): TComboBoxFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TComboBoxFrame;

    property OnChangeProc: TProc<Integer> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TComboBoxFrame }

function TComboBoxFrame.AddItem(const AText: string): TComboBoxFrame;
begin
  Result := Self;
  ComboBoxControl.Items.Add(AText);
end;

function TComboBoxFrame.ClearItems: TComboBoxFrame;
begin
  Result := Self;
  FUpdating := True;
  try
    ComboBoxControl.Clear;
  finally
    FUpdating := False;
  end;
end;

procedure TComboBoxFrame.ComboBoxControlChange(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if Assigned(FOnChangeProc) then
    FOnChangeProc(ComboBoxControl.ItemIndex);
end;

function TComboBoxFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TComboBoxFrame.GetCount: Integer;
begin
  Result := ComboBoxControl.Count;
end;

function TComboBoxFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TComboBoxFrame.GetItemIndex: Integer;
begin
  Result := ComboBoxControl.ItemIndex;
end;

function TComboBoxFrame.GetSelectedText: string;
begin
  Result := '';
  if ComboBoxControl.ItemIndex >= 0 then
    Result := ComboBoxControl.Items[ComboBoxControl.ItemIndex];
end;

function TComboBoxFrame.SetCaption(const ACaption: string): TComboBoxFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
  CaptionLabel.Visible := not CaptionLabel.Text.IsEmpty;
end;

function TComboBoxFrame.SetExtraText(const AExtraText: string): TComboBoxFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TComboBoxFrame.SetItemIndex(const AItemIndex: Integer): TComboBoxFrame;
begin
  Result := Self;
  // like SetValue of the other elements, OnChangeProc is not called
  FUpdating := True;
  try
    ComboBoxControl.ItemIndex := AItemIndex;
  finally
    FUpdating := False;
  end;
end;

function TComboBoxFrame.SetItems(const AItems: TArray<string>): TComboBoxFrame;
var
  LItem: string;
begin
  Result := Self;
  ClearItems;
  ComboBoxControl.BeginUpdate;
  try
    for LItem in AItems do
      ComboBoxControl.Items.Add(LItem);
  finally
    ComboBoxControl.EndUpdate;
  end;
end;

function TComboBoxFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<Integer>): TComboBoxFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

end.
