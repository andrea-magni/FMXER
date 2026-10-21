unit Data.Orders;

// The orders of the demo: in memory, shared by the routes.

interface

type
  TOrder = record
    Customer: string;
    Total: Currency;
    Paid: Boolean;
    Note: string;
  end;

var
  Orders: TArray<TOrder>;

implementation

initialization
  Orders := [
    Default(TOrder), Default(TOrder), Default(TOrder), Default(TOrder)
  ];
  Orders[0].Customer := 'Rossi S.r.l.';    Orders[0].Total := 1250;
  Orders[1].Customer := 'Bianchi S.p.A.';  Orders[1].Total := 380.5;  Orders[1].Paid := True;
  Orders[2].Customer := 'Verdi & Co.';     Orders[2].Total := 99.9;
  Orders[3].Customer := 'Neri Logistica';  Orders[3].Total := 4200;

end.
