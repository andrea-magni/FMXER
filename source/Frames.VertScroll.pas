unit Frames.VertScroll;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, SubjectStand, FormStand, FrameStand, FMX.Objects;

type
  TVertScrollFrame = class(TFrame)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    VerticalScrollbox: TVertScrollBox;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    function GetTouchWidth: Single;
    procedure SetTouchWidth(const Value: Single);
  public
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property TouchWidth: Single read GetTouchWidth write SetTouchWidth;
  end;

implementation

{$R *.fmx}

{ TVertScrollFrame }

function TVertScrollFrame.GetTouchWidth: Single;
begin
  Result := VerticalScrollbox.Padding.Right;
end;

procedure TVertScrollFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(VerticalScrollbox, ''
    , procedure (AForm: T)
      begin
        if Assigned(AConfigProc) then
          AConfigProc(AForm);
      end
    , procedure (AFormInfo: TFormInfo<T>)
      begin
        AFormInfo.Stand.Align := TAlignLayout.Top;
        AFormInfo.Stand.Height := AFormInfo.Form.Height;
      end
  );
end;

procedure TVertScrollFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(VerticalScrollbox, ''
    , procedure (AFrame: T)
      begin
        if Assigned(AConfigProc) then
          AConfigProc(AFrame);
      end
    , procedure (AFrameInfo: TFrameInfo<T>)
      begin
        AFrameInfo.Stand.Align := TAlignLayout.Top;
        AFrameInfo.Stand.Height := AFrameInfo.Frame.Height;
      end
  );
end;

procedure TVertScrollFrame.SetTouchWidth(const Value: Single);
begin
  VerticalScrollbox.Padding.Right := Value;
end;

end.
