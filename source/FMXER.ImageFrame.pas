unit FMXER.ImageFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.MultiResBitmap;

type
  TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);

  TImageFrame = class(TFrame)
    ContentImage: TImage;
    procedure ContentImageTap(Sender: TObject; const Point: TPointF);
    procedure ContentImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FOnTapHandler: TOnTapHandler;
   protected
       procedure HitTestChanged; override;
  public
    property Image: TImage read ContentImage;
    property OnTapHandler: TOnTapHandler read FOnTapHandler write FOnTapHandler;
  end;

implementation

{$R *.fmx}

procedure TImageFrame.ContentImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS} // simulate OnTap on Windows
  ContentImageTap(Sender, PointF(X, Y));
  {$ENDIF}
end;

procedure TImageFrame.ContentImageTap(Sender: TObject; const Point: TPointF);
begin
  if Assigned(FOnTapHandler) then
    FOnTapHandler(ContentImage, Point);
end;

procedure TImageFrame.HitTestChanged;
begin
  inherited;
  if Assigned(ContentImage) then
    ContentImage.HitTest := HitTest;
end;

end.
