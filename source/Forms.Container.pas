unit Forms.Container;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FormStand,
  SubjectStand, FrameStand, FMX.Layouts, FMX.Objects;

type
  TContainerForm = class(TForm)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
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

var
  ContainerForm: TContainerForm;

implementation

{$R *.fmx}

{ TContainerForm }

procedure TContainerForm.SetContent(const Value: TObject);
begin
   FContent := Value;
   if Assigned(FContent) and (FContent is TFmxObject) then
     TFmxObject(FContent).Parent := ContentLayout;
end;

procedure TContainerForm.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TContainerForm.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

end.
