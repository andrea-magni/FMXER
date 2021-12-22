unit FMXER.MarginFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, SubjectStand, FormStand, FrameStand, FMX.Objects;


type
  TMarginFrame = class(TFrame)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
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
  end;

implementation

{$R *.fmx}

{ TMarginFrame }

procedure TMarginFrame.HideHandler;
begin
//  FrameStand1.HideAndCloseAll;
//  FormStand1.HideAndCloseAll;
{ TODO : Find a way to hide/close everything it the correct order }

  SI.DefaultHide;
end;

procedure TMarginFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>);
begin
  FContent := FormStand1.NewAndShow<T>(nil, ''
    , procedure (AForm: T)
      begin
//        TForm(AForm).Align := TAlignLayout.Client; // ???
        if Assigned(AConfigProc) then
          AConfigProc(AForm);
      end
    , procedure (AFormInfo: TFormInfo<T>)
      begin
        AFormInfo.Stand.Align := TAlignLayout.Client;
      end
  );
end;

procedure TMarginFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>);
begin
  FContent := FrameStand1.NewAndShow<T>(self, ''
    , procedure (AFrame: T)
      begin
        TFrame(AFrame).Align := TAlignLayout.Client;
        if Assigned(AConfigProc) then
          AConfigProc(AFrame);
      end
    , procedure (AFrameInfo: TFrameInfo<T>)
      begin
        AFrameInfo.Stand.Align := TAlignLayout.Client;
      end
  );
end;

end.
