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
    const AUTO_WIDTH = TFMXERSlots.AUTO_SIZE;

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
    /// <summary>Runs ABuildProc with the realign of the slots suspended,
    /// then realigns once. Adding N elements costs O(N) instead of O(N^2):
    /// use it for more than a few tens of elements.</summary>
    function BatchUpdate(const ABuildProc: TProc<TRowForm>): TRowForm;
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
begin
  Result := Self;
  Width := Width + Round(TFMXERSlots.AddForm<T>(FormStand1, ContentLayout, Self, FElements,
    ElementStand, False, ElementAlign, AWidth, AConfigProc));
end;

function TRowForm.AddFrame<T>(const AWidth: Integer;
  const AConfigProc: TProc<T>): TRowForm;
begin
  Result := Self;
  Width := Width + Round(TFMXERSlots.AddFrame<T>(FrameStand1, ContentLayout, Self, FElements,
    ElementStand, False, ElementAlign, AWidth, AConfigProc));
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

function TRowForm.BatchUpdate(const ABuildProc: TProc<TRowForm>): TRowForm;
begin
  Result := Self;
  ContentLayout.BeginUpdate;
  try
    if Assigned(ABuildProc) then
      ABuildProc(Self);
  finally
    ContentLayout.EndUpdate;
  end;
end;

end.
