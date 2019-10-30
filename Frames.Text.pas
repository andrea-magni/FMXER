unit Frames.Text;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects;

type
  TTextFrame = class(TFrame)
    TextContent: TText;
  private
    FContent: string;
    procedure SetContent(const Value: string);
    function GetHorzAlign: TTextAlign;
    function GetVertAlign: TTextAlign;
    procedure SetHorzAlign(const Value: TTextAlign);
    procedure SetVertAlign(const Value: TTextAlign);
  public
    constructor Create(AOwner: TComponent); override;
    property Content: string read FContent write SetContent;
    property HorzAlign: TTextAlign read GetHorzAlign write SetHorzAlign;
    property VertAlign: TTextAlign read GetVertAlign write SetVertAlign;
  end;

implementation

{$R *.fmx}

uses UI.Consts;

{ TTextFrame }

constructor TTextFrame.Create(AOwner: TComponent);
begin
  inherited;
  TextContent.TextSettings.FontColor := TAppColors.PrimaryTextColor;
end;

function TTextFrame.GetHorzAlign: TTextAlign;
begin
  Result := TextContent.TextSettings.HorzAlign;
end;

function TTextFrame.GetVertAlign: TTextAlign;
begin
  Result := TextContent.TextSettings.VertAlign;
end;

procedure TTextFrame.SetContent(const Value: string);
begin
  FContent := Value;
  TextContent.Text := FContent;
end;

procedure TTextFrame.SetHorzAlign(const Value: TTextAlign);
begin
  TextContent.TextSettings.HorzAlign := Value;
end;

procedure TTextFrame.SetVertAlign(const Value: TTextAlign);
begin
  TextContent.TextSettings.VertAlign := Value;
end;

end.
