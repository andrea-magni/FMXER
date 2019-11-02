unit FMXER.ContainerFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts
, SubjectStand, FrameStand, FormStand;

type
  TContainerFrame = class(TFrame)
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    ContentLayout: TLayout;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
  public
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAs<T: TFmxObject>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;
  end;

implementation

{$R *.fmx}

{ TContainerFrame }

procedure TContainerFrame.SetContentAs<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<TFrame>(ContentLayout, ContentStand
  , procedure (AFrame: TFrame)
    var
      LContent: T;
    begin
      LContent := T.Create(AFrame);
      try
        LContent.Parent := AFrame;
        if Assigned(AConfigProc) then
          AConfigProc(LContent);
      except
        LContent.Free;
        raise;
      end;
    end);
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
