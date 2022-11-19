unit FMXER.RowForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  Generics.Collections
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc;

type
  TRowForm = class(TForm)
    ContentLayout: TLayout;
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    Stands: TStyleBook;
  private
    FElements: TList<TSubjectInfoContainer>;
    FElementStand: string;
    FElementAlign: TAlignLayout;
  public
    const DEFAULT_ELEMENT_WIDTH = 200;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddFrame<T: TFrame>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil): TRowForm; overload;
    function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TRowForm; overload;

    function AddForm<T: TForm>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil): TRowForm; overload;
    function AddForm<T: TForm>(const AColDef: TElementDef<T>): TRowForm; overload;

    function GetContent: TLayout; virtual;

    property ElementStand: string read FElementStand write FElementStand;
    property ElementAlign: TAlignLayout read FElementAlign write FElementAlign;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

var
  RowForm: TRowForm;

implementation

{$R *.fmx}

{ TRowForm }

function TRowForm.AddForm<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>): TRowForm;
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Result := Self;
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := ElementAlign;

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

function TRowForm.AddFrame<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>): TRowForm;
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Result := Self;
  Width := Width + AWidth;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Width := AWidth;
    LElementContainer.Align := ElementAlign;

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

function TRowForm.AddFrame<T>(const AColDef: TElementDef<T>): TRowForm;
begin
  Result :=
    AddFrame<T>(
      AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
    , AColDef.ConfigProc
    );
end;

constructor TRowForm.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Width := 0;
  FElementAlign := TAlignLayout.Left;
end;

destructor TRowForm.Destroy;
begin
  FrameStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

function TRowForm.GetContent: TLayout;
begin
  Result := ContentLayout;
end;

function TRowForm.AddForm<T>(const AColDef: TElementDef<T>): TRowForm;
begin
  Result :=
    AddForm<T>(
      AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
    , AColDef.ConfigProc
    );
end;

end.
