unit FMXER.SwitchFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, System.Skia, FMX.Skia
, FMXER.Observable;

type
  TSwitchFrame = class(TFrame)
    SwitchLayout: TLayout;
    SwitchControl: TSwitch;
    TextLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    procedure SwitchControlSwitch(Sender: TObject);
    procedure TextLabelClick(Sender: TObject);
  private
    FOnChangeProc: TProc<Boolean>;
    FCheckedLink: TObservableLink<Boolean>;
  protected
  public
    function GetText: string;
    function GetExtraText: string;
    function GetChecked: Boolean;

    function SetText(const AText: string): TSwitchFrame;
    function SetExtraText(const AExtraText: string): TSwitchFrame;
    function SetChecked(const AChecked: Boolean): TSwitchFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Boolean>): TSwitchFrame;
    /// <summary>Two-way binding: the switch shows AObservable, a tap writes it
    /// (OnChangeProc is still called). Removed with the element.</summary>
    function BindChecked(const AObservable: TObservable<Boolean>): TSwitchFrame;

    property OnChangeProc: TProc<Boolean> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TSwitchFrame }

function TSwitchFrame.BindChecked(const AObservable: TObservable<Boolean>): TSwitchFrame;
begin
  Result := Self;
  if not Assigned(FCheckedLink) then
    FCheckedLink := TObservableLink<Boolean>.Create(Self);
  FCheckedLink.Bind(AObservable,
    procedure (AValue: Boolean)
    begin
      if SwitchControl.IsChecked <> AValue then
        SwitchControl.IsChecked := AValue;
    end);
end;

function TSwitchFrame.GetChecked: Boolean;
begin
  Result := SwitchControl.IsChecked;
end;

function TSwitchFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TSwitchFrame.GetText: string;
begin
  Result := TextLabel.Text;
end;

function TSwitchFrame.SetChecked(const AChecked: Boolean): TSwitchFrame;
begin
  Result := Self;
  SwitchControl.IsChecked := AChecked;
end;

function TSwitchFrame.SetExtraText(const AExtraText: string): TSwitchFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TSwitchFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<Boolean>): TSwitchFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

function TSwitchFrame.SetText(const AText: string): TSwitchFrame;
begin
  Result := Self;
  TextLabel.Text := AText;
end;

procedure TSwitchFrame.SwitchControlSwitch(Sender: TObject);
begin
  if Assigned(FCheckedLink) then
    FCheckedLink.Write(SwitchControl.IsChecked);
  if Assigned(FOnChangeProc) then
    FOnChangeProc(SwitchControl.IsChecked);
end;

procedure TSwitchFrame.TextLabelClick(Sender: TObject);
begin
  // a tap on the text toggles the switch, like a Flutter SwitchListTile
  if SwitchControl.Enabled then
    SwitchControl.IsChecked := not SwitchControl.IsChecked;
end;

end.
