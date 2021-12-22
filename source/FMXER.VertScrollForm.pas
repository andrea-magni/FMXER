unit FMXER.VertScrollForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FormStand, SubjectStand, FrameStand;

type
  [Align(TAlignLayout.Client)]
  TVertScrollForm = class(TForm)
    VerticalScrollbox: TVertScrollBox;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    function GetTouchWidth: Single;
    procedure SetTouchWidth(const Value: Single);
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [Hide]
    procedure HideHandler;
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);
    //
    property ContentStand: string read FContentStand write FContentStand;
    property TouchWidth: Single read GetTouchWidth write SetTouchWidth;
  end;

var
  VertScrollForm: TVertScrollForm;

implementation

{$R *.fmx}

{ TVertScrollForm }

function TVertScrollForm.GetTouchWidth: Single;
begin
  Result := VerticalScrollbox.Padding.Right;
end;

procedure TVertScrollForm.HideHandler;
begin
//  FrameStand1.HideAndCloseAll;
//  FormStand1.HideAndCloseAll;
{ TODO : Find a way to hide/close everything it the correct order }

  SI.DefaultHide;
end;

procedure TVertScrollForm.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(VerticalScrollbox, ''
    , procedure (AForm: T)
      begin
//        TForm(AForm).Align := TAlignLayout.Top; // ???
        if Assigned(AConfigProc) then
          AConfigProc(AForm);
      end
    , procedure (AFormInfo: TFormInfo<T>)
      begin
        AFormInfo.Stand.Align := TAlignLayout.Top; // AFormInfo.Form.Align ???
        AFormInfo.Stand.Height := AFormInfo.Form.Height;
      end
  );
end;

procedure TVertScrollForm.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(VerticalScrollbox, ''
    , procedure (AFrame: T)
      begin
        TFrame(AFrame).Align := TAlignLayout.Top;
        if Assigned(AConfigProc) then
          AConfigProc(AFrame);
      end
    , procedure (AFrameInfo: TFrameInfo<T>)
      begin
        AFrameInfo.Stand.Align := AFrameInfo.Frame.Align;
        AFrameInfo.Stand.Height := AFrameInfo.Frame.Height;
      end
  );
end;

procedure TVertScrollForm.SetTouchWidth(const Value: Single);
begin
  VerticalScrollbox.Padding.Right := Value;
end;

end.
