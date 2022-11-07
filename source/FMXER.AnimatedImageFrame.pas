unit FMXER.AnimatedImageFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Skia, Skia.FMX;

type
  TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);

  TAnimatedImageFrame = class(TFrame)
    ContentImage: TSkAnimatedImage;
    procedure ContentImageTap(Sender: TObject; const Point: TPointF);
    procedure ContentImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FOnTapHandler: TOnTapHandler;
  protected
    procedure HitTestChanged; override;
  public
    function LoadFromFile(const AFileName: string): TAnimatedImageFrame;
    property Image: TSkAnimatedImage read ContentImage;
    property OnTapHandler: TOnTapHandler read FOnTapHandler write FOnTapHandler;
  end;

implementation

{$R *.fmx}

procedure TAnimatedImageFrame.ContentImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS} // simulate OnTap on Windows
  ContentImageTap(Sender, PointF(X, Y));
  {$ENDIF}
end;

procedure TAnimatedImageFrame.ContentImageTap(Sender: TObject;
  const Point: TPointF);
begin
  if Assigned(FOnTapHandler) then
    FOnTapHandler(ContentImage, Point);
end;

procedure TAnimatedImageFrame.HitTestChanged;
begin
  inherited;
  if Assigned(ContentImage) then
    ContentImage.HitTest := HitTest;
end;

function TAnimatedImageFrame.LoadFromFile(
  const AFileName: string): TAnimatedImageFrame;
begin
  Result := Self;
  Result.Image.LoadFromFile(AFileName);
end;

end.
