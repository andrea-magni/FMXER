unit FMXER.AlertFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Skia, FMX.Skia
, SubjectStand;

type
  /// <summary>The content of TModals.Alert and TModals.Confirm (Flutter
  /// AlertDialog): a title, a message and one or two text buttons that set the
  /// ModalResult of the dialog (mrOk, mrCancel).</summary>
  TAlertFrame = class(TFrame)
    TitleLabel: TSkLabel;
    MessageLabel: TSkLabel;
    ButtonsLayout: TLayout;
    OkLabel: TSkLabel;
    CancelLabel: TSkLabel;
    procedure OkLabelClick(Sender: TObject);
    procedure CancelLabelClick(Sender: TObject);
  private
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;

    function SetTitle(const ATitle: string): TAlertFrame;
    function SetMessage(const AMessage: string): TAlertFrame;
    function SetOkText(const AText: string): TAlertFrame;
    /// <summary>Empty: no Cancel button (an alert).</summary>
    function SetCancelText(const AText: string): TAlertFrame;
    /// <summary>The height the content needs for its width (the card is sized
    /// on it).</summary>
    function GetPreferredHeight: Single;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts;

{ TAlertFrame }

procedure TAlertFrame.CancelLabelClick(Sender: TObject);
begin
  if Assigned(SI) then
    SI.ModalResult := mrCancel;
end;

constructor TAlertFrame.Create(AOwner: TComponent);
begin
  inherited;
  OkLabel.TextSettings.FontColor := TAppColors.PrimaryColor;
  CancelLabel.TextSettings.FontColor := TAppColors.PrimaryColor;
end;

function TAlertFrame.GetPreferredHeight: Single;
begin
  Result := ButtonsLayout.Height + ButtonsLayout.Margins.Top;
  if TitleLabel.Visible then
    Result := Result + TitleLabel.Height + TitleLabel.Margins.Bottom;
  if MessageLabel.Visible then
    Result := Result + MessageLabel.Height;
end;

procedure TAlertFrame.OkLabelClick(Sender: TObject);
begin
  if Assigned(SI) then
    SI.ModalResult := mrOk;
end;

function TAlertFrame.SetCancelText(const AText: string): TAlertFrame;
begin
  Result := Self;
  CancelLabel.Text := AText;
  CancelLabel.Visible := not AText.IsEmpty;
end;

function TAlertFrame.SetMessage(const AMessage: string): TAlertFrame;
begin
  Result := Self;
  MessageLabel.Text := AMessage;
  MessageLabel.Visible := not AMessage.IsEmpty;
end;

function TAlertFrame.SetOkText(const AText: string): TAlertFrame;
begin
  Result := Self;
  OkLabel.Text := AText;
end;

function TAlertFrame.SetTitle(const ATitle: string): TAlertFrame;
begin
  Result := Self;
  TitleLabel.Text := ATitle;
  TitleLabel.Visible := not ATitle.IsEmpty;
end;

end.
