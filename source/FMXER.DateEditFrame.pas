unit FMXER.DateEditFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.DateTimeCtrls, FMX.Layouts, System.Skia, FMX.Skia;

type
  /// <summary>A date picker (TDateEdit: the native date picker on Android and
  /// iOS, a calendar drop-down on Windows and macOS) with a caption above and
  /// an extra text below: the FMX counterpart of the Flutter showDatePicker.</summary>
  TDateEditFrame = class(TFrame)
    DateEditControl: TDateEdit;
    CaptionLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    procedure DateEditControlChange(Sender: TObject);
  private
    FOnChangeProc: TProc<TDate>;
    FUpdating: Boolean;
  protected
  public
    function GetCaption: string;
    function GetExtraText: string;
    function GetDate: TDate;
    function GetFormat: string;
    function GetIsEmpty: Boolean;

    function SetCaption(const ACaption: string): TDateEditFrame;
    function SetExtraText(const AExtraText: string): TDateEditFrame;
    function SetDate(const ADate: TDate): TDateEditFrame;
    function SetFormat(const AFormat: string): TDateEditFrame;
    function SetIsEmpty(const AIsEmpty: Boolean): TDateEditFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<TDate>): TDateEditFrame;

    property OnChangeProc: TProc<TDate> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

{ TDateEditFrame }

procedure TDateEditFrame.DateEditControlChange(Sender: TObject);
begin
  if FUpdating then
    Exit;
  if Assigned(FOnChangeProc) then
    FOnChangeProc(DateEditControl.Date);
end;

function TDateEditFrame.GetCaption: string;
begin
  Result := CaptionLabel.Text;
end;

function TDateEditFrame.GetDate: TDate;
begin
  Result := DateEditControl.Date;
end;

function TDateEditFrame.GetExtraText: string;
begin
  Result := ExtraLabel.Text;
end;

function TDateEditFrame.GetFormat: string;
begin
  Result := DateEditControl.Format;
end;

function TDateEditFrame.GetIsEmpty: Boolean;
begin
  Result := DateEditControl.IsEmpty;
end;

function TDateEditFrame.SetCaption(const ACaption: string): TDateEditFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
  CaptionLabel.Visible := not CaptionLabel.Text.IsEmpty;
end;

function TDateEditFrame.SetDate(const ADate: TDate): TDateEditFrame;
begin
  Result := Self;
  // like SetValue of the other elements, OnChangeProc is not called
  FUpdating := True;
  try
    DateEditControl.Date := ADate;
  finally
    FUpdating := False;
  end;
end;

function TDateEditFrame.SetExtraText(const AExtraText: string): TDateEditFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
  ExtraLabel.Visible := not ExtraLabel.Text.IsEmpty;
end;

function TDateEditFrame.SetFormat(const AFormat: string): TDateEditFrame;
begin
  Result := Self;
  DateEditControl.Format := AFormat;
end;

function TDateEditFrame.SetIsEmpty(const AIsEmpty: Boolean): TDateEditFrame;
begin
  Result := Self;
  FUpdating := True;
  try
    DateEditControl.IsEmpty := AIsEmpty;
  finally
    FUpdating := False;
  end;
end;

function TDateEditFrame.SetOnChangeProc(
  const AOnChangeProc: TProc<TDate>): TDateEditFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

end.
