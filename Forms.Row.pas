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
    const DEFAULT_ELEMENT_WIDTH = 200;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddFrame<T: TFrame>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil); overload;
    procedure AddFrame<T: TFrame>(const AColDef: TElementDef<T>); overload;

    procedure AddForm<T: TForm>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil); overload;
    procedure AddForm<T: TForm>(const AColDef: TElementDef<T>); overload;

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

var
  RowForm: TRowForm;

implementation

{$R *.fmx}

{ TRowForm }

procedure TRowForm.AddForm<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := TAlignLayout.Left;

    LElement := FormStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(T(LElement.Subject));
    LElement.SubjectShow();

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;

procedure TRowForm.AddFrame<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := TAlignLayout.Left;

    LElement := FrameStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(T(LElement.Subject));
    LElement.SubjectShow();

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;

procedure TRowForm.AddFrame<T>(const AColDef: TElementDef<T>);
begin
  AddFrame<T>(
    AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
  , AColDef.ConfigProc);
end;

constructor TRowForm.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Width := 0;
end;

destructor TRowForm.Destroy;
begin
  FrameStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

procedure TRowForm.AddForm<T>(const AColDef: TElementDef<T>);
begin
  AddForm<T>(
    AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
  , AColDef.ConfigProc);
end;

end.
