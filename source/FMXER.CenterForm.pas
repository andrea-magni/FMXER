unit FMXER.CenterForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FrameStand, SubjectStand, FormStand;

type
  TCenterForm = class(TForm)
    ContentLayout: TLayout;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
  private
    FContentStand: string;
    FContent: TSubjectInfo;
  public
    //
    function SetContentAsFrame<T: TFrame>(const AWidth, AHeight: Integer;
      const AConfigProc: TProc<T> = nil): TCenterForm;
    function SetContentAsForm<T: TForm>(const AWidth, AHeight: Integer;
      const AConfigProc: TProc<T> = nil): TCenterForm;
    //
    property ContentStand: string read FContentStand write FContentStand;
  end;


implementation

{$R *.fmx}

{ TCenterForm }

function TCenterForm.SetContentAsForm<T>(const AWidth, AHeight: Integer; const AConfigProc: TProc<T>): TCenterForm;
begin
  Result := Self;
  ContentLayout.Width := AWidth;
  ContentLayout.Height := AHeight;

  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TCenterForm.SetContentAsFrame<T>(const AWidth, AHeight: Integer; const AConfigProc: TProc<T>): TCenterForm;
begin
  Result := Self;
  ContentLayout.Width := AWidth;
  ContentLayout.Height := AHeight;

  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

end.
