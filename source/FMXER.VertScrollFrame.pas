unit FMXER.VertScrollFrame;

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
    procedure FrameResized(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    FOnResizeProc: TProc<TVertScrollFrame>;
    FOnResizedProc: TProc<TVertScrollFrame>;
    FOnShowProc: TProc<TVertScrollFrame>;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [AfterShow]
    procedure AfterShow;
    [Hide]
    procedure HideHandler;

    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TVertScrollFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TVertScrollFrame;

    function GetTouchWidth: Single;
    function SetTouchWidth(const ATouchWidth: Single): TVertScrollFrame;

    property ContentStand: string read FContentStand write FContentStand;
    property OnResizeProc: TProc<TVertScrollFrame> read FOnResizeProc write FOnResizeProc;
    property OnResizedProc: TProc<TVertScrollFrame> read FOnResizedProc write FOnResizedProc;
    property OnShowProc: TProc<TVertScrollFrame> read FOnShowProc write FOnShowProc;
  end;

implementation

{$R *.fmx}

{ TVertScrollFrame }

procedure TVertScrollFrame.AfterShow;
begin
  if Assigned(FOnShowProc) then
    FOnShowProc(Self);
end;

procedure TVertScrollFrame.FrameResize(Sender: TObject);
begin
  if Assigned(FOnResizeProc) then
    FOnResizeProc(Self);
end;

procedure TVertScrollFrame.FrameResized(Sender: TObject);
begin
  if Assigned(FOnResizedProc) then
    FOnResizedProc(Self);
end;

function TVertScrollFrame.GetTouchWidth: Single;
begin
  Result := VerticalScrollbox.Padding.Right;
end;

procedure TVertScrollFrame.HideHandler;
begin
//  FrameStand1.HideAndCloseAll;
//  FormStand1.HideAndCloseAll;
{ TODO : Find a way to hide/close everything it the correct order }

  SI.DefaultHide;
end;

function TVertScrollFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): TVertScrollFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(VerticalScrollbox, ''
    , procedure (AForm: T)
      begin
//        TForm(AForm).Align := TAlignLayout.Top; // ???
        if Assigned(AConfigProc) then
          AConfigProc(AForm);
      end
    , procedure (AFormInfo: TFormInfo<T>)
      begin
        AFormInfo.Stand.Align := TAlignLayout.Top; // ??? AFormInfo.Form.Align
        AFormInfo.Stand.Height := AFormInfo.Form.Height;
      end
  );
end;

function TVertScrollFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TVertScrollFrame;
begin
  Result := Self;
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

function TVertScrollFrame.SetTouchWidth(const ATouchWidth: Single): TVertScrollFrame;
begin
  Result := Self;
  VerticalScrollbox.Padding.Right := ATouchWidth;
end;

end.
