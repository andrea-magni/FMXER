unit FMXER.QRCodeFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Skia, Skia.FMX, FMX.Layouts, FMX.Objects
, QRCode.Render, QRCode.Utils
;

type
  TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);

  TQRCodeFrame = class(TFrame)
    QRCode: TSkSvg;
    lytQRCodeLogo: TLayout;
    QRCodeLogo: TSkAnimatedImage;
    procedure QRCodeTap(Sender: TObject; const Point: TPointF);
    procedure QRCodeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FOnTapHandler: TOnTapHandler;
    FContent: string;
    FOnBeforePaint: TOnBeforePaintHandler;
    FRadiusFactor: Single;
    procedure SetOnTapHandler(const Value: TOnTapHandler);
  protected
    procedure SetOnBeforePaint(const Value: TOnBeforePaintHandler);
    procedure UpdateQRCode;
    procedure HitTestChanged; override;
  public
    constructor Create(AOwner: TComponent); override;

    function SetContent(const AContent: string): TQRCodeFrame;
    function SetRadiusFactor(const ARadiusFactor: Single): TQRCodeFrame;
    function SetSVGSource(const ASource: string): TQRCodeFrame;
    function SetOverrideColor(const AColor: TAlphaColor): TQRCodeFrame;

    function LoadLogoContentFromFile(const AFileName: string): TQRCodeFrame;
    function SetLogoWidth(const AWidth: Single): TQRCodeFrame;
    function SetLogoHeight(const AHeight: Single): TQRCodeFrame;
    function SetLogoVisible(const AVisible: Boolean): TQRCodeFrame;

    property OnBeforePaint: TOnBeforePaintHandler read FOnBeforePaint write SetOnBeforePaint;
    property OnTapHandler: TOnTapHandler read FOnTapHandler write SetOnTapHandler;
  end;

implementation

{$R *.fmx}


constructor TQRCodeFrame.Create(AOwner: TComponent);
begin
  inherited;
  FRadiusFactor := 0.1;
  FContent := '';
  FOnBeforePaint := nil;
  FOnTapHandler := nil;
end;

procedure TQRCodeFrame.HitTestChanged;
begin
  inherited;
  if Assigned(QRCode) then
    QRCode.HitTest := HitTest;
//  if Assigned(lytQRCodeLogo) then
//    lytQRCodeLogo.HitTest := HitTest;
//  if Assigned(QRCodeLogo) then
//    QRCodeLogo.HitTest := HitTest;
end;

function TQRCodeFrame.LoadLogoContentFromFile(
  const AFileName: string): TQRCodeFrame;
begin
  Result := Self;
  QRCodeLogo.LoadFromFile(AFileName);
end;

procedure TQRCodeFrame.QRCodeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS} // simulate OnTap on Windows
  QRCodeTap(Sender, PointF(X, Y));
  {$ENDIF}
end;

procedure TQRCodeFrame.QRCodeTap(Sender: TObject; const Point: TPointF);
begin
  if Assigned(FOnTapHandler) then
    FOnTapHandler(QRCode, Point);
end;

function TQRCodeFrame.SetContent(const AContent: string): TQRCodeFrame;
begin
  Result := Self;
  if FContent <> AContent then
  begin
    FContent := AContent;
    UpdateQRCode;
  end;
end;

function TQRCodeFrame.SetLogoHeight(const AHeight: Single): TQRCodeFrame;
begin
  Result := Self;
  QRCodeLogo.Height := AHeight;
end;

function TQRCodeFrame.SetLogoVisible(const AVisible: Boolean): TQRCodeFrame;
begin
  Result := Self;
  QRCodeLogo.Visible := AVisible;
end;

function TQRCodeFrame.SetLogoWidth(const AWidth: Single): TQRCodeFrame;
begin
  Result := Self;
  QRCodeLogo.Width := AWidth;
end;

procedure TQRCodeFrame.SetOnBeforePaint(const Value: TOnBeforePaintHandler);
begin
  if (TOnBeforePaintHandler(FOnBeforePaint) <> TOnBeforePaintHandler(Value)) then
  begin
    FOnBeforePaint := Value;
    UpdateQRCode;
  end;
end;

procedure TQRCodeFrame.SetOnTapHandler(const Value: TOnTapHandler);
begin
  FOnTapHandler := Value;
end;

function TQRCodeFrame.SetOverrideColor(const AColor: TAlphaColor): TQRCodeFrame;
begin
  Result := Self;
  QRCode.Svg.OverrideColor := AColor;
end;

function TQRCodeFrame.SetRadiusFactor(const ARadiusFactor: Single): TQRCodeFrame;
begin
  Result := Self;
  if FRadiusFactor <> ARadiusFactor then
  begin
    FRadiusFactor := ARadiusFactor;
    UpdateQRCode;
  end;
end;

function TQRCodeFrame.SetSVGSource(const ASource: string): TQRCodeFrame;
begin
  Result := Self;
  QRCode.Svg.Source := ASource;
end;

procedure TQRCodeFrame.UpdateQRCode;
begin
  SetSVGSource(TQRCode.TextToSvg(FContent, FOnBeforePaint, FRadiusFactor));
end;

end.
