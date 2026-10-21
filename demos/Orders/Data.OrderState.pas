unit Data.OrderState;

// The state of the 'order' route: a data module (it could hold FireDAC
// components, LiveBindings...), created with the route and freed with it.

interface

uses
  System.SysUtils, System.Classes
, Data.Orders;

type
  TOrderState = class(TDataModule)
  private
    FIndex: Integer;
    FOrder: TOrder;
  public
    /// <summary>The arguments of the route: RouteTo&lt;TOrderState&gt; calls it.</summary>
    procedure Load(const AIndex: Integer);
    /// <summary>Writes the edited order back to the list.</summary>
    procedure Save;

    property Index: Integer read FIndex;
    property Order: TOrder read FOrder write FOrder;
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TOrderState }

procedure TOrderState.Load(const AIndex: Integer);
begin
  FIndex := AIndex;
  FOrder := Orders[AIndex];   // a copy: edited here, saved only on Save
end;

procedure TOrderState.Save;
begin
  Orders[FIndex] := FOrder;
end;

end.
