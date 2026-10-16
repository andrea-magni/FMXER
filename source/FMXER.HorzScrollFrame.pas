unit FMXER.HorzScrollFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FrameStand, SubjectStand, FormStand, FMXER.UI.Misc;

type
  THorzScrollFrame = class(TFrame)
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    HorizontalScrollBox: THorzScrollBox;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    function GetTouchHeight: Single;
    procedure InternalSetTouchHeight(const Value: Single);
  public
    //
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzScrollFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzScrollFrame;
    function SetContentStand(const AStand: string): THorzScrollFrame;
    function SetTouchHeight(const ATouchHeight: Single): THorzScrollFrame;
    //
    property ContentStand: string read FContentStand write FContentStand;
    property TouchHeight: Single read GetTouchHeight write InternalSetTouchHeight;
  end;

implementation

{$R *.fmx}

{ THorzScrollFrame }

function THorzScrollFrame.GetTouchHeight: Single;
begin
  Result := HorizontalScrollbox.Padding.Bottom;
end;

function THorzScrollFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): THorzScrollFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(HorizontalScrollbox, ContentStand
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

function THorzScrollFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): THorzScrollFrame;
var
  LContent: TFrameInfo<T>;
begin
  Result := Self;
  // aligned to the left before entering the stand: the frame keeps its design
  // width (or the one set by AConfigProc), and the scroll box scrolls it
  LContent := TFMXERStands.NewSizedFrame<T>(FrameStand1, HorizontalScrollbox, ContentStand, TAlignLayout.Left);
  FContent := LContent;
  if Assigned(AConfigProc) then
    AConfigProc(LContent.Frame);
  LContent.Stand.Align := TAlignLayout.Left;
  LContent.Stand.Width := LContent.Frame.Width + LContent.Frame.Margins.Left + LContent.Frame.Margins.Right;
  LContent.Show;
end;

procedure THorzScrollFrame.InternalSetTouchHeight(const Value: Single);
begin
  HorizontalScrollbox.Padding.Bottom := Value;
end;

function THorzScrollFrame.SetContentStand(const AStand: string): THorzScrollFrame;
begin
  Result := Self;
  FContentStand := AStand;
end;

function THorzScrollFrame.SetTouchHeight(const ATouchHeight: Single): THorzScrollFrame;
begin
  Result := Self;
  TouchHeight := ATouchHeight;
end;

end.
