unit FMXER.ColorPickerFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, SubjectStand, FMX.Ani, FMX.Layouts,
  FMX.ListBox, FMX.Colors;

type
  TColorPickerFrame = class(TFrame)
    CaptionLabel: TLabel;
    ExtraLabel: TLabel;
    ComboColorBox1: TComboColorBox;
    ColorAnimation1: TColorAnimation;
    procedure ComboColorBox1Change(Sender: TObject);
  private
    FOnChangeProc: TProc<TAlphaColor>;
  protected
  public
    function GetCaption: string;
    function GetColor: TAlphaColor;
    function GetExtraText: string;

    function SetCaption(const ACaption: string): TColorPickerFrame;
    function SetColor(const AColor: TAlphaColor): TColorPickerFrame;
    function SetExtraText(const AExtraText: string): TColorPickerFrame;

    property OnChangeProc: TProc<TAlphaColor> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TColorPickerFrame }

procedure TColorPickerFrame.ComboColorBox1Change(Sender: TObject);
begin
  if Assigned(FOnChangeProc) then
    FOnChangeProc(ComboColorBox1.Color);
end;

function TColorPickerFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TColorPickerFrame.GetColor: TAlphaColor;
begin
  Result := ComboColorBox1.Color;
end;

function TColorPickerFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TColorPickerFrame.SetCaption(const ACaption: string): TColorPickerFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
end;

function TColorPickerFrame.SetColor(
  const AColor: TAlphaColor): TColorPickerFrame;
begin
  Result := Self;
  ComboColorBox1.Color := AColor;
end;

function TColorPickerFrame.SetExtraText(const AExtraText: string): TColorPickerFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
end;

end.
