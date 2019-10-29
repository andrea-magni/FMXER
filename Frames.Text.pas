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
  public
    constructor Create(AOwner: TComponent); override;
    property Content: string read FContent write SetContent;
  end;

implementation

{$R *.fmx}

uses UI.Consts;

{ TTextFrame }

constructor TTextFrame.Create(AOwner: TComponent);
begin
  inherited;
  TextContent.TextSettings.FontColor := TAppColors.PRIMARY_TEXT_COLOR;
end;

procedure TTextFrame.SetContent(const Value: string);
begin
  FContent := Value;
  TextContent.Text := FContent;
end;

end.
