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
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TContainerFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TContainerFrame;
    function SetContentAs<T: TFmxObject>(const AConfigProc: TProc<T> = nil): TContainerFrame;
    //
    property ContentStand: string read FContentStand write FContentStand;
    property Content: TSubjectInfo read FContent;
  end;

implementation

{$R *.fmx}

{ TContainerFrame }

function TContainerFrame.SetContentAs<T>(const AConfigProc: TProc<T>): TContainerFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<TFrame>(ContentLayout, ContentStand
  , procedure (AFrame: TFrame)
    var
      LContent: T;
    begin
      AFrame.Align := TAlignLayout.Client;

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

function TContainerFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): TContainerFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TContainerFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TContainerFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

end.
