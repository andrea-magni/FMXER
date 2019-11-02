unit FMXER.ContainterFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FrameStand, SubjectStand, FormStand, FMX.Layouts;

type
  TContainerFrame = class(TFrame)
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    ContentLayout: TLayout;
  private
    FContent: TObject;
    FContentStand: string;
    procedure SetContent(const Value: TObject);
  public
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property Content: TObject read FContent write SetContent;
  end;

implementation

{$R *.fmx}

{ TContainerFrame }

procedure TContainerFrame.SetContent(const Value: TObject);
begin
  FContent := Value;
  if Assigned(FContent) and (FContent is TFmxObject) then
    TFmxObject(FContent).Parent := Self;
end;

procedure TContainerFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TContainerFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

end.
