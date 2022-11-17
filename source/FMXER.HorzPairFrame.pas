unit FMXER.HorzPairFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FormStand, SubjectStand, FrameStand, FMX.Layouts;

type
  THorzPairFrame = class(TFrame)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    LeftContentLayout: TLayout;
    RightContentLayout: TLayout;
    ContentLayout: TLayout;
  private
    FLeftContentStand, FRightContentStand: string;
    FLeftContent, FRightContent: TSubjectInfo;
  public
    function SetLeftContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
    function SetLeftContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzPairFrame;

    function SetRightContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
    function SetRightContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzPairFrame;

    function SetContentAsFrame<T1, T2: TFrame>(const ALeftConfigProc: TProc<T1> = nil;
      const ARightConfigProc: TProc<T2> = nil): THorzPairFrame;
    function SetContentAsForm<T1, T2: TForm>(const ALeftConfigProc: TProc<T1> = nil;
      const ARightConfigProc: TProc<T2> = nil): THorzPairFrame;

    function GetLeftContentStand: string;
    function SetLeftContentStand(const AStandName: string): THorzPairFrame;

    function GetRightContentStand: string;
    function SetRightContentStand(const AStandName: string): THorzPairFrame;
  end;

implementation

{$R *.fmx}

{ THorzPairFrame }

function THorzPairFrame.GetLeftContentStand: string;
begin
  Result := FLeftContentStand;
end;

function THorzPairFrame.GetRightContentStand: string;
begin
  Result := FRightContentStand;
end;

function THorzPairFrame.SetContentAsForm<T1, T2>(
  const ALeftConfigProc: TProc<T1> = nil;
  const ARightConfigProc: TProc<T2> = nil
): THorzPairFrame;
begin
  Result := Self;
  FLeftContent := FormStand1.NewAndShow<T1>(LeftContentLayout, FLeftContentStand, ALeftConfigProc);
  FRightContent := FormStand1.NewAndShow<T2>(RightContentLayout, FRightContentStand, ARightConfigProc);
end;

function THorzPairFrame.SetContentAsFrame<T1, T2>(
  const ALeftConfigProc: TProc<T1> = nil;
  const ARightConfigProc: TProc<T2> = nil
): THorzPairFrame;
begin
  Result := Self;
  FLeftContent := FrameStand1.NewAndShow<T1>(LeftContentLayout, FLeftContentStand, ALeftConfigProc);
  FRightContent := FrameStand1.NewAndShow<T2>(RightContentLayout, FRightContentStand, ARightConfigProc);
end;

function THorzPairFrame.SetLeftContentAsForm<T>(
  const AConfigProc: TProc<T>): THorzPairFrame;
begin
  Result := Self;
  FLeftContent := FormStand1.NewAndShow<T>(LeftContentLayout, FLeftContentStand, AConfigProc);
end;

function THorzPairFrame.SetLeftContentAsFrame<T>(
  const AConfigProc: TProc<T>): THorzPairFrame;
begin
  Result := Self;
  FLeftContent := FrameStand1.NewAndShow<T>(LeftContentLayout, FLeftContentStand, AConfigProc);
end;

function THorzPairFrame.SetLeftContentStand(
  const AStandName: string): THorzPairFrame;
begin
  Result := Self;
end;

function THorzPairFrame.SetRightContentAsForm<T>(
  const AConfigProc: TProc<T>): THorzPairFrame;
begin
  Result := Self;
  FRightContent := FormStand1.NewAndShow<T>(RightContentLayout, FRightContentStand, AConfigProc);
end;

function THorzPairFrame.SetRightContentAsFrame<T>(
  const AConfigProc: TProc<T>): THorzPairFrame;
begin
  Result := Self;
  FRightContent := FrameStand1.NewAndShow<T>(RightContentLayout, FRightContentStand, AConfigProc);
end;

function THorzPairFrame.SetRightContentStand(
  const AStandName: string): THorzPairFrame;
begin
  Result := Self;
end;

end.
