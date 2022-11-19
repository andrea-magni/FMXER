unit FMXER.AccessoryFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FormStand, SubjectStand, FrameStand;

type
  TAccessoryFrame = class(TFrame)
    LeftLayout: TLayout;
    ContentLayout: TLayout;
    RightLayout: TLayout;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
  private
    FContent, FLeft, FRight: TSubjectInfo;
    FContentStand: string;
    FLeftStand: string;
    FRightStand: string;
    procedure InternalSetContentStand(const Value: string);
    procedure InternalSetLeftStand(const Value: string);
    procedure InternalSetRightStand(const Value: string);
  public
    function SetContentAsFrame<T: TFrame>(
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
    function SetContentAsForm<T: TForm>(
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;

    function SetLeftAsFrame<T: TFrame>(const AWidth: Single;
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
    function SetLeftAsForm<T: TForm>(const AWidth: Single;
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;

    function SetRightAsFrame<T: TFrame>(const AWidth: Single;
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
    function SetRightAsForm<T: TForm>(const AWidth: Single;
      const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;

    function SetContentStand(const AStand: string): TAccessoryFrame;
    function SetLeftStand(const AStand: string): TAccessoryFrame;
    function SetRightStand(const AStand: string): TAccessoryFrame;

    property ContentStand: string read FContentStand write InternalSetContentStand;
    property LeftStand: string read FLeftStand write InternalSetLeftStand;
    property RightStand: string read FRightStand write InternalSetRightStand;
  end;

implementation

{$R *.fmx}

{ TAccessoryFrame }

procedure TAccessoryFrame.InternalSetContentStand(const Value: string);
begin
  FContentStand := Value;
end;

procedure TAccessoryFrame.InternalSetLeftStand(const Value: string);
begin
  FLeftStand := Value;
end;

procedure TAccessoryFrame.InternalSetRightStand(const Value: string);
begin
  FRightStand := Value;
end;

function TAccessoryFrame.SetContentAsForm<T>(
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TAccessoryFrame.SetContentAsFrame<T>(
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TAccessoryFrame.SetContentStand(const AStand: string): TAccessoryFrame;
begin
  Result := Self;
  ContentStand := AStand;
end;

function TAccessoryFrame.SetLeftAsForm<T>(const AWidth: Single;
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  LeftLayout.Width := AWidth;
  LeftLayout.Visible := True;
  FLeft := FormStand1.NewAndShow<T>(LeftLayout, LeftStand, AConfigProc);
end;

function TAccessoryFrame.SetLeftAsFrame<T>(const AWidth: Single;
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  LeftLayout.Width := AWidth;
  LeftLayout.Visible := True;
  FLeft := FrameStand1.NewAndShow<T>(LeftLayout, LeftStand, AConfigProc);
end;

function TAccessoryFrame.SetLeftStand(const AStand: string): TAccessoryFrame;
begin
  Result := Self;
  LeftStand := AStand;
end;

function TAccessoryFrame.SetRightAsForm<T>(const AWidth: Single;
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  RightLayout.Width := AWidth;
  RightLayout.Visible := True;
  FRight := FormStand1.NewAndShow<T>(RightLayout, RightStand, AConfigProc);
end;

function TAccessoryFrame.SetRightAsFrame<T>(const AWidth: Single;
  const AConfigProc: TProc<T>): TAccessoryFrame;
begin
  Result := Self;
  RightLayout.Width := AWidth;
  RightLayout.Visible := True;
  FRight := FrameStand1.NewAndShow<T>(RightLayout, RightStand, AConfigProc);
end;

function TAccessoryFrame.SetRightStand(const AStand: string): TAccessoryFrame;
begin
  Result := Self;
  RightStand := AStand;
end;

end.
