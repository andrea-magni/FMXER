unit FMXER.RowFrame;

// A row as a frame: the same API as TRowForm, without the cost of a form
// (on Windows each form creates a native window: about 2.5 ms against 0.1 ms
// for a frame). Prefer it for rows created many times (list-like columns).

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Layouts,
  Generics.Collections
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc;

type
  TRowFrame = class(TFrame)
    ContentLayout: TLayout;
    Stands: TStyleBook;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
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
      const AConfigProc: TProc<T> = nil): TRowFrame; overload;
    function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TRowFrame; overload;

    function AddForm<T: TForm>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
      const AConfigProc: TProc<T> = nil): TRowFrame; overload;
    function AddForm<T: TForm>(const AColDef: TElementDef<T>): TRowFrame; overload;

    function GetContent: TLayout; virtual;
    function SetElementStand(const AStand: string): TRowFrame;
    /// <summary>Runs ABuildProc with the realign of the slots suspended,
    /// then realigns once. Adding N elements costs O(N) instead of O(N^2):
    /// use it for more than a few tens of elements.</summary>
    function BatchUpdate(const ABuildProc: TProc<TRowFrame>): TRowFrame;
    function SetElementAlign(const AAlign: TAlignLayout): TRowFrame;

    property ElementStand: string read FElementStand write FElementStand;
    property ElementAlign: TAlignLayout read FElementAlign write FElementAlign;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}

{ TRowFrame }

constructor TRowFrame.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  FElementAlign := TAlignLayout.Left;
  Width := 0; // grows with the slots
end;

destructor TRowFrame.Destroy;
begin
  FrameStand1.CloseAll();
  FormStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

function TRowFrame.AddFrame<T>(const AWidth: Integer; const AConfigProc: TProc<T>): TRowFrame;
begin
  Result := Self;
  Width := Width + TFMXERSlots.AddFrame<T>(FrameStand1, ContentLayout, Self, FElements,
    ElementStand, False, ElementAlign, AWidth, AConfigProc);
end;

function TRowFrame.AddFrame<T>(const AColDef: TElementDef<T>): TRowFrame;
begin
  Result := AddFrame<T>(
    AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
  , AColDef.ConfigProc);
end;

function TRowFrame.AddForm<T>(const AWidth: Integer; const AConfigProc: TProc<T>): TRowFrame;
begin
  Result := Self;
  Width := Width + TFMXERSlots.AddForm<T>(FormStand1, ContentLayout, Self, FElements,
    ElementStand, False, ElementAlign, AWidth, AConfigProc);
end;

function TRowFrame.AddForm<T>(const AColDef: TElementDef<T>): TRowFrame;
begin
  Result := AddForm<T>(
    AColDef.ParamByName('Width', DEFAULT_ELEMENT_WIDTH).AsInteger
  , AColDef.ConfigProc);
end;

function TRowFrame.GetContent: TLayout;
begin
  Result := ContentLayout;
end;

function TRowFrame.SetElementAlign(const AAlign: TAlignLayout): TRowFrame;
begin
  Result := Self;
  FElementAlign := AAlign;
end;

function TRowFrame.SetElementStand(const AStand: string): TRowFrame;
begin
  Result := Self;
  FElementStand := AStand;
end;

function TRowFrame.BatchUpdate(const ABuildProc: TProc<TRowFrame>): TRowFrame;
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
