unit Forms.Column;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts
, SubjectStand, Generics.Collections, FormStand, FrameStand, UI.Misc;

type
  TColumnForm = class(TForm)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    ContentLayout: TLayout;
    Stands: TStyleBook;
  private
    FElements: TList<TSubjectInfoContainer>;
    FElementStand: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddElementAsFrame<T: TFrame>(const AHeight: Integer = 200;
      const AConfigureProc: TProc<T> = nil);
    procedure AddElementAsForm<T: TForm>(const AHeight: Integer = 200;
      const AConfigureProc: TProc<T> = nil);

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}


{ TCenterForm }

procedure TColumnForm.AddElementAsForm<T>(const AHeight: Integer; const AConfigureProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Height := Height + AHeight;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.Y := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Height := AHeight;
    LElementContainer.Align := TAlignLayout.Top;

    LElement := FormStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigureProc) then
      AConfigureProc(T(LElement.Subject));
    LElement.SubjectShow();

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;


procedure TColumnForm.AddElementAsFrame<T>(const AHeight: Integer; const AConfigureProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Height := Height + AHeight;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.Y := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Height := AHeight;
    LElementContainer.Align := TAlignLayout.Top;

    LElement := FrameStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigureProc) then
      AConfigureProc(T(LElement.Subject));
    LElement.SubjectShow();

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;

constructor TColumnForm.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Height := 1;
end;

destructor TColumnForm.Destroy;
begin
  FrameStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;


end.
