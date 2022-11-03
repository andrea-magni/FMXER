unit FMXER.StackFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants
, Generics.Collections
, FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls
, FMX.Layouts
, SubjectStand, FrameStand;

type
  TStackInfo = record
    Name: string;
    SubjectInfo: TSubjectInfo;
    constructor Create(const AName: string; const ASubjectInfo: TSubjectInfo);
  end;

  TStackFrame = class(TFrame)
    ContentLayout: TLayout;
    FrameStand1: TFrameStand;
  private
    FStack: TList<TStackInfo>;
    function GetDefaultStand: string;
    procedure SetDefaultStand(const Value: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddFrame<T: TFrame>(const AConfigProc: TProc<T> = nil; const AName: string = ''): string;
    procedure CloseFrame(const AName: string);
    property DefaultStand: string read GetDefaultStand write SetDefaultStand;
  end;

implementation

{$R *.fmx}

{ TStackFrame }

function TStackFrame.AddFrame<T>(const AConfigProc: TProc<T>; const AName: string): string;
begin
  var LSubjectInfo: TSubjectInfo := FrameStand1.NewAndShow<T>(ContentLayout, DefaultStand, AConfigProc);

  Result := AName;
  if Result = '' then
    Result := 'layer' + FStack.Count.ToString;

  FStack.Add(TStackInfo.Create(Result, LSubjectInfo));
end;

procedure TStackFrame.CloseFrame(const AName: string);
begin
  for var LStackInfo in FStack.ToArray do
  begin
    if LStackInfo.Name = AName then
    begin
      FStack.Remove(LStackInfo);
      LStackInfo.SubjectInfo.HideAndClose;
      Break;
    end;
  end;
end;

constructor TStackFrame.Create(AOwner: TComponent);
begin
  inherited;
  FStack := TList<TStackInfo>.Create;
end;

destructor TStackFrame.Destroy;
begin
  FreeAndNil(FStack);
  inherited;
end;

function TStackFrame.GetDefaultStand: string;
begin
  Result := FrameStand1.DefaultStandName;
end;

procedure TStackFrame.SetDefaultStand(const Value: string);
begin
  FrameStand1.DefaultStandName := Value;
end;

{ TStackInfo }

constructor TStackInfo.Create(const AName: string;
  const ASubjectInfo: TSubjectInfo);
begin
  Name := AName;
  SubjectInfo := ASubjectInfo;
end;

end.
