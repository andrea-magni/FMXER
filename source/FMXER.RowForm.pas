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
    /// <summary>AddFrame/AddForm width: the element's own width (its design
    /// width, or the one set by the configuration procedure).</summary>
    const AUTO_WIDTH = -1;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddFrame<T: TFrame>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil): TRowForm; overload;
    function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TRowForm; overload;

    function AddForm<T: TForm>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil): TRowForm; overload;
    function AddForm<T: TForm>(const AColDef: TElementDef<T>): TRowForm; overload;

    function GetContent: TLayout; virtual;
    function SetElementStand(const AStand: string): TRowForm;
    function SetElementAlign(const AAlign: TAlignLayout): TRowForm;

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
  LElement: TFormInfo<T>;
  LElementContainer: TSubjectInfoContainer;
  LWidth: Single;
begin
  Result := Self;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    if AWidth >= 0 then
      LElementContainer.Width := AWidth;
    LElementContainer.Align := ElementAlign;

    LElement := FormStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(LElement.Form);

    LWidth := AWidth;
    if AWidth = AUTO_WIDTH then
    begin
      LWidth := LElement.Form.Width;
      LElementContainer.Width := LWidth;
    end;
    Width := Width + Round(LWidth);

    LElement.Show;
    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;

function TRowForm.AddFrame<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>): TRowForm;
var
  LElement: TFrameInfo<T>;
  LElementContainer: TSubjectInfoContainer;
  LWidth: Single;
begin
  Result := Self;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.X := MaxInt;
    LElementContainer.Parent := ContentLayout;
    if AWidth >= 0 then
      LElementContainer.Width := AWidth;
    LElementContainer.Align := ElementAlign;

    if AWidth = AUTO_WIDTH then
      LElement := TFMXERStands.NewSizedFrame<T>(FrameStand1, LElementContainer, ElementStand, TAlignLayout.Left)
    else
      LElement := FrameStand1.New<T>(LElementContainer, ElementStand);
    LElementContainer.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(LElement.Frame);

    LWidth := AWidth;
    if AWidth = AUTO_WIDTH then
    begin
      LWidth := LElement.Frame.Width + LElement.Frame.Margins.Left + LElement.Frame.Margins.Right;
      LElementContainer.Width := LWidth;
    end;
    Width := Width + Round(LWidth);

    LElement.Show;
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
  FormStand1.CloseAll();
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

function TRowForm.SetElementStand(const AStand: string): TRowForm;
begin
  Result := Self;
  FElementStand := AStand;
end;

function TRowForm.SetElementAlign(const AAlign: TAlignLayout): TRowForm;
begin
  Result := Self;
  FElementAlign := AAlign;
end;

end.
