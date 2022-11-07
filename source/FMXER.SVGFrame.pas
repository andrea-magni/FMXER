unit FMXER.SVGFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  Skia, Skia.FMX;

type
  TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);

  TSVGFrame = class(TFrame)
    SVG: TSkSvg;
    procedure SVGTap(Sender: TObject; const Point: TPointF);
    procedure SVGMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FOnTapHandler: TOnTapHandler;
    function GetSVGSource: string;
   protected
     procedure HitTestChanged; override;
  public
    function LoadFromFile(const AFileName: string): TSVGFrame; overload;
    function LoadFromFile(const AFileName: string; const AEncoding: TEncoding): TSVGFrame; overload;
    function SetOpacity(const AOpacity: Single): TSVGFrame;
    function SetWrapMode(const AWrapMode: TSkSvgWrapMode): TSVGFrame;
    function SetOverrideColor(const AOverrideColor: TAlphaColor): TSVGFrame;
    function SetSVGSource(const ASVGSource: string): TSVGFrame;

    property OnTapHandler: TOnTapHandler read FOnTapHandler write FOnTapHandler;
  end;

implementation

{$R *.fmx}

uses IOUtils;

{ TSVGFrame }

procedure TSVGFrame.SVGMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  {$IFDEF MSWINDOWS} // simulate OnTap on Windows
  SVGTap(Sender, PointF(X, Y));
  {$ENDIF}
end;

procedure TSVGFrame.SVGTap(Sender: TObject; const Point: TPointF);
begin
  if Assigned(FOnTapHandler) then
    FOnTapHandler(SVG, Point);
end;

function TSVGFrame.GetSVGSource: string;
begin
  Result := SVG.Svg.Source;
end;

procedure TSVGFrame.HitTestChanged;
begin
  inherited;
  if Assigned(SVG) then
    SVG.HitTest := HitTest;
end;

function TSVGFrame.LoadFromFile(const AFileName: string): TSVGFrame;
begin
  Result := Self;
  SetSVGSource(TFile.ReadAllText(AFileName));
end;

function TSVGFrame.LoadFromFile(const AFileName: string; const AEncoding: TEncoding): TSVGFrame;
begin
  Result := Self;
  SetSVGSource(TFile.ReadAllText(AFileName, AEncoding));
end;

function TSVGFrame.SetOpacity(const AOpacity: Single): TSVGFrame;
begin
  Result := Self;
  SVG.Opacity := AOpacity;
end;

function TSVGFrame.SetOverrideColor(
  const AOverrideColor: TAlphaColor): TSVGFrame;
begin
  Result := Self;
  SVG.Svg.OverrideColor := AOverrideColor;
end;

function TSVGFrame.SetSVGSource(const ASVGSource: string): TSVGFrame;
begin
  Result := Self;
  SVG.Svg.Source := ASVGSource;
end;

function TSVGFrame.SetWrapMode(const AWrapMode: TSkSvgWrapMode): TSVGFrame;
begin
  Result := Self;
  SVG.Svg.WrapMode := AWrapMode;
end;

end.
