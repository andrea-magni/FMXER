unit FMXER.BackgroundFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects
, SubjectStand, FrameStand, FormStand;

type
  TBackgroundFrame = class(TFrame)
    BackgroundRectangle: TRectangle;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
  private
  protected
    FContentStand: string;
    FContent: TSubjectInfo;
    function GetFill: TBrush;
    function GetStroke: TStrokeBrush;
    procedure HitTestChanged; override;
  public
    constructor Create(AOwner: TComponent); override;
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;

    property Fill: TBrush read GetFill;
    property Stroke: TStrokeBrush read GetStroke;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts;

{ TBackgroundFrame }

constructor TBackgroundFrame.Create(AOwner: TComponent);
begin
  inherited;
  BackgroundRectangle.Fill.Color := TAppColors.PrimaryColor;
end;

function TBackgroundFrame.GetFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TBackgroundFrame.GetStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

procedure TBackgroundFrame.HitTestChanged;
begin
  inherited;
  if Assigned(BackgroundRectangle) then
    BackgroundRectangle.HitTest := HitTest;
end;

procedure TBackgroundFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

procedure TBackgroundFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(BackgroundRectangle, ContentStand, AConfigProc);
end;

end.
