unit FMXER.PaintBoxFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Skia, FMX.Skia;

type
  TOnDrawHandler = reference to procedure(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
  TPaintBoxTapHandler = reference to procedure(APaintBox: TObject; APoint: TPointF);
  // the other elements share FMXER.UI.Types.TOnTapHandler (another signature)
  TOnTapHandler = TPaintBoxTapHandler deprecated 'use TPaintBoxTapHandler';

  TPaintBoxFrame = class(TFrame)
    PaintBox: TSkPaintBox;
    procedure PaintBoxTap(Sender: TObject; const Point: TPointF);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBoxDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
  private
    FOnTapHandler: TPaintBoxTapHandler;
    FOnDrawHandler: TOnDrawHandler;
  public
    function SetOnDrawHandler(const ADrawHandler: TOnDrawHandler): TPaintBoxFrame;
    function SetOnTapHandler(const ATapHandler: TPaintBoxTapHandler): TPaintBoxFrame;

    property OnDrawHandler: TOnDrawHandler read FOnDrawHandler write FOnDrawHandler;
    property OnTapHandler: TPaintBoxTapHandler read FOnTapHandler write FOnTapHandler;
  end;

implementation

{$R *.fmx}

procedure TPaintBoxFrame.PaintBoxDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
begin
  if Assigned(FOnDrawHandler) then
    FOnDrawHandler(ACanvas, ADest, AOpacity);
end;

procedure TPaintBoxFrame.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS} // simulate OnTap on Windows
  PaintBoxTap(Sender, PointF(X, Y));
  {$ENDIF}
end;

procedure TPaintBoxFrame.PaintBoxTap(Sender: TObject; const Point: TPointF);
begin
  if Assigned(FOnTapHandler) then
    FOnTapHandler(PaintBox, Point);
end;

function TPaintBoxFrame.SetOnDrawHandler(
  const ADrawHandler: TOnDrawHandler): TPaintBoxFrame;
begin
  Result := Self;
  OnDrawHandler := ADrawHandler;
end;

function TPaintBoxFrame.SetOnTapHandler(
  const ATapHandler: TPaintBoxTapHandler): TPaintBoxFrame;
begin
  Result := Self;
  OnTapHandler := ATapHandler;
end;

end.
