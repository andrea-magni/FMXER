unit Frames.HorzScroll;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FrameStand, SubjectStand, FormStand;

type
  THorzScrollFrame = class(TFrame)
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    HorizontalScrollBox: THorzScrollBox;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    function GetTouchHeight: Single;
    procedure SetTouchHeight(const Value: Single);
  public
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property TouchHeight: Single read GetTouchHeight write SetTouchHeight;
  end;

implementation

{$R *.fmx}

{ THorzScrollFrame }

function THorzScrollFrame.GetTouchHeight: Single;
begin
  Result := HorizontalScrollbox.Padding.Bottom;
end;

procedure THorzScrollFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(HorizontalScrollbox, ''
    , procedure (AForm: T)
      begin
        if Assigned(AConfigProc) then
          AConfigProc(AForm);
      end
    , procedure (AFormInfo: TFormInfo<T>)
      begin
        AFormInfo.Stand.Align := TAlignLayout.Left;
        AFormInfo.Stand.Width := AFormInfo.Form.Width;
      end
  );
end;

procedure THorzScrollFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(HorizontalScrollbox, ''
    , procedure (AFrame: T)
      begin
        if Assigned(AConfigProc) then
          AConfigProc(AFrame);
      end
    , procedure (AFrameInfo: TFrameInfo<T>)
      begin
        AFrameInfo.Stand.Align := TAlignLayout.Left;
        AFrameInfo.Stand.Width := AFrameInfo.Frame.Width;
      end
  );
end;

procedure THorzScrollFrame.SetTouchHeight(const Value: Single);
begin
  HorizontalScrollbox.Padding.Bottom := Value;
end;

end.
