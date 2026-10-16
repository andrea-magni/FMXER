unit FMXER.ColumnFrame;

// A column as a frame: the same API as TColumnForm, without the cost of a form
// (on Windows each form creates a native window: about 2.5 ms against 0.1 ms
// for a frame). Prefer it for columns created many times (in lists, in rows).

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Layouts,
  Generics.Collections
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc;

type
  TColumnFrame = class(TFrame)
    ContentLayout: TLayout;
    Stands: TStyleBook;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
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
      const AConfigProc: TProc<T> = nil): TColumnFrame; overload;
    function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TColumnFrame; overload;

    function AddForm<T: TForm>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
      const AConfigProc: TProc<T> = nil): TColumnFrame; overload;
    function AddForm<T: TForm>(const AColDef: TElementDef<T>): TColumnFrame; overload;

    function GetContent: TLayout; virtual;
    function SetElementStand(const AStand: string): TColumnFrame;
    /// <summary>Runs ABuildProc with the realign of the slots suspended,
    /// then realigns once. Adding N elements costs O(N) instead of O(N^2):
    /// use it for more than a few tens of elements.</summary>
    function BatchUpdate(const ABuildProc: TProc<TColumnFrame>): TColumnFrame;

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}

{ TColumnFrame }

constructor TColumnFrame.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Height := 0; // grows with the slots
end;

destructor TColumnFrame.Destroy;
begin
  FrameStand1.CloseAll();
  FormStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;

function TColumnFrame.AddFrame<T>(const AHeight: Integer; const AConfigProc: TProc<T>): TColumnFrame;
begin
  Result := Self;
  Height := Height + TFMXERSlots.AddFrame<T>(FrameStand1, ContentLayout, Self, FElements,
    ElementStand, True, TAlignLayout.Top, AHeight, AConfigProc);
end;

function TColumnFrame.AddFrame<T>(const AColDef: TElementDef<T>): TColumnFrame;
begin
  Result := AddFrame<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
end;

function TColumnFrame.AddForm<T>(const AHeight: Integer; const AConfigProc: TProc<T>): TColumnFrame;
begin
  Result := Self;
  Height := Height + TFMXERSlots.AddForm<T>(FormStand1, ContentLayout, Self, FElements,
    ElementStand, True, TAlignLayout.Top, AHeight, AConfigProc);
end;

function TColumnFrame.AddForm<T>(const AColDef: TElementDef<T>): TColumnFrame;
begin
  Result := AddForm<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
end;

function TColumnFrame.GetContent: TLayout;
begin
  Result := ContentLayout;
end;

function TColumnFrame.SetElementStand(const AStand: string): TColumnFrame;
begin
  Result := Self;
  FElementStand := AStand;
end;

function TColumnFrame.BatchUpdate(const ABuildProc: TProc<TColumnFrame>): TColumnFrame;
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
