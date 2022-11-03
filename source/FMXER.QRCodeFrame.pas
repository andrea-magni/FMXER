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
    procedure SetRadiusFactor(const Value: Single);
  protected
    function GetSVGSource: string; inline;
    procedure SetSVGSource(const Value: string); inline;
    procedure SetContent(const Value: string);
    procedure SetOnBeforePaint(const Value: TOnBeforePaintHandler);
    procedure UpdateQRCode;
    procedure HitTestChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Content: string read FContent write SetContent;
    property RadiusFactor: Single read FRadiusFactor write SetRadiusFactor;
    property SVGSource: string read GetSVGSource write SetSVGSource;
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

function TQRCodeFrame.GetSVGSource: string;
begin
  Result := QRCode.Svg.Source;
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

procedure TQRCodeFrame.SetContent(const Value: string);
begin
  if FContent <> Value then
  begin
    FContent := Value;
    UpdateQRCode;
  end;
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

procedure TQRCodeFrame.SetRadiusFactor(const Value: Single);
begin
  if FRadiusFactor <> Value then
  begin
    FRadiusFactor := Value;
    UpdateQRCode;
  end;
end;

procedure TQRCodeFrame.SetSVGSource(const Value: string);
begin
  QRCode.Svg.Source := Value;
end;

procedure TQRCodeFrame.UpdateQRCode;
begin
  SVGSource := TQRCode.TextToSvg(FContent, FOnBeforePaint, FRadiusFactor);
end;

end.
