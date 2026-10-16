unit FMXER.ColumnForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  Generics.Collections
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc;

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
    const DEFAULT_ELEMENT_HEIGHT = 200;
    /// <summary>AddFrame/AddForm height: the element's own height (its design
    /// height, or the one set by the configuration procedure).</summary>
    const AUTO_HEIGHT = TFMXERSlots.AUTO_SIZE;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddFrame<T: TFrame>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
      const AConfigProc: TProc<T> = nil): TColumnForm; overload;
    function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TColumnForm; overload;

    function AddForm<T: TForm>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
      const AConfigProc: TProc<T> = nil): TColumnForm; overload;
    function AddForm<T: TForm>(const AColDef: TElementDef<T>): TColumnForm; overload;

    function GetContent: TLayout; virtual;
    function SetElementStand(const AStand: string): TColumnForm;
    /// <summary>Runs ABuildProc with the realign of the slots suspended,
    /// then realigns once. Adding N elements costs O(N) instead of O(N^2):
    /// use it for more than a few tens of elements.</summary>
    function BatchUpdate(const ABuildProc: TProc<TColumnForm>): TColumnForm;

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}


{ TColumnForm }

function TColumnForm.AddForm<T>(const AHeight: Integer; const AConfigProc: TProc<T>): TColumnForm;
begin
  Result := Self;
  Height := Height + Round(TFMXERSlots.AddForm<T>(FormStand1, ContentLayout, Self, FElements,
    ElementStand, True, TAlignLayout.Top, AHeight, AConfigProc));
end;


function TColumnForm.AddFrame<T>(const AHeight: Integer; const AConfigProc: TProc<T>): TColumnForm;
begin
  Result := Self;
  Height := Height + Round(TFMXERSlots.AddFrame<T>(FrameStand1, ContentLayout, Self, FElements,
    ElementStand, True, TAlignLayout.Top, AHeight, AConfigProc));
end;

function TColumnForm.AddForm<T>(const AColDef: TElementDef<T>): TColumnForm;
begin
  Result := AddForm<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
end;

function TColumnForm.AddFrame<T>(const AColDef: TElementDef<T>): TColumnForm;
begin
  Result := AddFrame<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
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
  FormStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

function TColumnForm.GetContent: TLayout;
begin
  Result := ContentLayout;
end;

function TColumnForm.SetElementStand(const AStand: string): TColumnForm;
begin
  Result := Self;
  FElementStand := AStand;
end;

function TColumnForm.BatchUpdate(const ABuildProc: TProc<TColumnForm>): TColumnForm;
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
