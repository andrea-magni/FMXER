unit FMXER.ContainerForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Layouts, FMX.Objects
, SubjectStand, FrameStand, FormStand;

type
  TContainerForm = class(TForm)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    ContentLayout: TLayout;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
//    procedure SetContent(const Value: TSubjectInfo);
  public
    //
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TContainerForm;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TContainerForm;
    function SetContentStand(const AStand: string): TContainerForm;
    //
    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;
  end;

var
  ContainerForm: TContainerForm;

implementation

{$R *.fmx}

{ TContainerForm }

function TContainerForm.SetContentAsForm<T>(const AConfigProc: TProc<T>): TContainerForm;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TContainerForm.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TContainerForm;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TContainerForm.SetContentStand(const AStand: string): TContainerForm;
begin
  Result := Self;
  FContentStand := AStand;
end;

end.
