unit FMXER.TextFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects
, Skia, Skia.FMX
;

type
  TTextFrame = class(TFrame)
    TextContent: TSkLabel;
    procedure TextContentClick(Sender: TObject);
  private
    FOnClickProc: TProc;
  public
    constructor Create(AOwner: TComponent); override;

    function SetContent(const AText: string): TTextFrame;
    function SetHorzAlign(const AHorzAlign: TSkTextHorzAlign): TTextFrame;
    function SetVertAlign(const AVertAlign: TTextAlign): TTextFrame;
    function SetOnClick(const AOnClickProc: TProc): TTextFrame;
    function SetFontColor(const AColor: TAlphaColor): TTextFrame;
    function SetFontSize(const AFontSize: Single): TTextFrame;
    function SetFontFamily(const AFontFamily: string): TTextFrame;
    function SetMaxLines(const ALines: Integer): TTextFrame;
    function SetFontWeight(const AWeight: TFontWeight): TTextFrame;

    function GetContent: string;
    function GetHorzAlign: TSkTextHorzAlign;
    function GetVertAlign: TTextAlign;
    function GetOnClickProc: TProc;
    function GetFontColor: TAlphaColor;
    function GetFontSize: Single;
    function GetMaxLines: Integer;
    function GetFontWeight: TFontWeight;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;

{ TTextFrame }

constructor TTextFrame.Create(AOwner: TComponent);
begin
  inherited;
  TextContent.TextSettings.FontColor := TAppColors.PrimaryTextColor;
end;

function TTextFrame.GetContent: string;
begin
  Result := TextContent.Text;
end;

function TTextFrame.GetFontColor: TAlphaColor;
begin
  Result := TextContent.TextSettings.FontColor;
end;

function TTextFrame.GetFontSize: Single;
begin
  Result := TextContent.TextSettings.Font.Size;
end;

function TTextFrame.GetFontWeight: TFontWeight;
begin
  Result := TextContent.TextSettings.Font.Weight;
end;

function TTextFrame.GetHorzAlign: TSkTextHorzAlign;
begin
  Result := TextContent.TextSettings.HorzAlign;
end;

function TTextFrame.GetMaxLines: Integer;
begin
  Result := TextContent.TextSettings.MaxLines;
end;

function TTextFrame.GetOnClickProc: TProc;
begin
  Result := FOnClickProc;
end;

function TTextFrame.GetVertAlign: TTextAlign;
begin
  Result := TextContent.TextSettings.VertAlign;
end;

procedure TTextFrame.TextContentClick(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc();
end;

function TTextFrame.SetContent(const AText: string): TTextFrame;
begin
  Result := Self;
  TextContent.Text := AText;
end;

function TTextFrame.SetFontColor(const AColor: TAlphaColor): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.FontColor := AColor;
end;

function TTextFrame.SetFontFamily(const AFontFamily: string): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.Font.Families := AFontFamily;
end;

function TTextFrame.SetFontSize(const AFontSize: Single): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.Font.Size := AFontSize;
end;

function TTextFrame.SetFontWeight(const AWeight: TFontWeight): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.Font.Weight := AWeight;
end;

function TTextFrame.SetHorzAlign(
  const AHorzAlign: TSkTextHorzAlign): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.HorzAlign := AHorzAlign;
end;

function TTextFrame.SetMaxLines(const ALines: Integer): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.MaxLines := ALines;
end;

function TTextFrame.SetOnClick(const AOnClickProc: TProc): TTextFrame;
begin
  Result := Self;
  FOnClickProc := AOnClickProc;
end;

function TTextFrame.SetVertAlign(
  const AVertAlign: TTextAlign): TTextFrame;
begin
  Result := Self;
  TextContent.TextSettings.VertAlign := AVertAlign;
end;

end.
