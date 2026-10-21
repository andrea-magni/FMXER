unit Data.OrderState;

// The state of the 'order' route: a data module (it could hold FireDAC
// components, LiveBindings...), created with the route and freed with it.
// Its values are observable: the elements of the route listen to them.

interface

uses
  System.SysUtils, System.Classes
, FMXER.Observable
, Data.Orders;

type
  TOrderState = class(TDataModule)
  private
    FIndex: Integer;
    FOrder: TOrder;
  public
    Paid: TObservable<Boolean>;
    Note: TObservable<string>;
    /// <summary>Paid or Note changed since Load or Save.</summary>
    Modified: TObservable<Boolean>;

    constructor Create(AOwner: TComponent); override;
    /// <summary>The arguments of the route: RouteTo&lt;TOrderState&gt; calls it.</summary>
    procedure Load(const AIndex: Integer);
    /// <summary>Writes the edited order back to the list (OrdersChanged).</summary>
    procedure Save;

    property Index: Integer read FIndex;
    property Order: TOrder read FOrder;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TOrderState }

constructor TOrderState.Create(AOwner: TComponent);
begin
  inherited;
  // owned by the data module: freed with it, so with the route
  Paid := TObservable<Boolean>.Create(Self, False);
  Note := TObservable<string>.Create(Self, '');
  Modified := TObservable<Boolean>.Create(Self, False);

  // the state listens to itself: any change marks it modified
  Paid.Listen(Self, procedure (AValue: Boolean) begin Modified.Value := True; end, False);
  Note.Listen(Self, procedure (AValue: string) begin Modified.Value := True; end, False);
end;

procedure TOrderState.Load(const AIndex: Integer);
begin
  FIndex := AIndex;
  FOrder := Orders[AIndex];
  Paid.Value := FOrder.Paid;
  Note.Value := FOrder.Note;
  Modified.Value := False;
end;

procedure TOrderState.Save;
begin
  FOrder.Paid := Paid.Value;
  FOrder.Note := Note.Value;
  Orders[FIndex] := FOrder;
  Modified.Value := False;
  OrdersChanged.NotifyChanged;
end;

end.
