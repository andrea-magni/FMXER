unit Forms.Row;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FrameStand,
  SubjectStand, FormStand, FMX.Layouts, Generics.Collections, UI.Misc;

type
  TRowForm = class(TForm)
    ContentLayout: TLayout;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    Stands: TStyleBook;
  private
    FElements: TList<TSubjectInfoContainer>;
    FElementStand: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddElementAsFrame<T: TFrame>(const AWidth: Integer = 200;
      const AConfigureProc: TProc<T> = nil);
    procedure AddElementAsForm<T: TForm>(const AWidth: Integer = 200;
      const AConfigureProc: TProc<T> = nil);

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

var
  RowForm: TRowForm;

implementation

{$R *.fmx}

{ TRowForm }

procedure TRowForm.AddElementAsForm<T>(const AWidth: Integer;
  const AConfigureProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := TAlignLayout.Left;

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

procedure TRowForm.AddElementAsFrame<T>(const AWidth: Integer;
  const AConfigureProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := TAlignLayout.Left;

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

constructor TRowForm.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Width := 1;
end;

destructor TRowForm.Destroy;
begin
  FrameStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

end.
