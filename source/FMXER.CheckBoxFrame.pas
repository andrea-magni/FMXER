unit FMXER.CheckBoxFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Skia, FMX.Skia;

type
  TCheckBoxFrame = class(TFrame)
    CheckBoxControl: TCheckBox;
    TextLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    procedure CheckBoxControlChange(Sender: TObject);
    procedure TextLabelClick(Sender: TObject);
  private
    FOnChangeProc: TProc<Boolean>;
  protected
  public
    function GetText: string;
    function GetExtraText: string;
    function GetChecked: Boolean;

    function SetText(const AText: string): TCheckBoxFrame;
    function SetExtraText(const AExtraText: string): TCheckBoxFrame;
    function SetChecked(const AChecked: Boolean): TCheckBoxFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Boolean>): TCheckBoxFrame;

    property OnChangeProc: TProc<Boolean> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TCheckBoxFrame }

procedure TCheckBoxFrame.CheckBoxControlChange(Sender: TObject);
begin
  if Assigned(FOnChangeProc) then
    FOnChangeProc(CheckBoxControl.IsChecked);
end;

function TCheckBoxFrame.GetChecked: Boolean;
begin
  Result := CheckBoxControl.IsChecked;
end;

function TCheckBoxFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TCheckBoxFrame.GetText: string;
begin
  Result := TextLabel.Text;
end;

function TCheckBoxFrame.SetChecked(const AChecked: Boolean): TCheckBoxFrame;
begin
  Result := Self;
  CheckBoxControl.IsChecked := AChecked;
end;

function TCheckBoxFrame.SetExtraText(const AExtraText: string): TCheckBoxFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TCheckBoxFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<Boolean>): TCheckBoxFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

function TCheckBoxFrame.SetText(const AText: string): TCheckBoxFrame;
begin
  Result := Self;
  TextLabel.Text := AText;
end;

procedure TCheckBoxFrame.TextLabelClick(Sender: TObject);
begin
  // a tap on the text toggles the check box, like a Flutter CheckboxListTile
  if CheckBoxControl.Enabled then
    CheckBoxControl.IsChecked := not CheckBoxControl.IsChecked;
end;

end.
