unit Data.Orders;

// The orders of the demo: in memory, shared by the routes, with the
// observables of the app (the list changed, the last sync).

interface

uses
  System.SysUtils, System.Classes, System.Threading
, FMXER.Observable;

type
  TOrder = record
    Customer: string;
    Total: Currency;
    Paid: Boolean;
    Note: string;
  end;

var
  Orders: TArray<TOrder>;

  /// <summary>The orders changed (an order was saved): the list and the
  /// title listen to it.</summary>
  OrdersChanged: TChangeNotifier;
  /// <summary>When the orders were last synced: set by a background task,
  /// shown in the main thread.</summary>
  LastSync: TObservable<TDateTime>;

/// <summary>"2 to pay (5,450.00)".</summary>
function UnpaidSummary: string;

implementation

var
  AppState: TComponent;   // owns the observables of the app
  SyncTask: ITask;
  Stopping: Boolean;

function UnpaidSummary: string;
var
  LOrder: TOrder;
  LCount: Integer;
  LTotal: Currency;
begin
  LCount := 0;
  LTotal := 0;
  for LOrder in Orders do
    if not LOrder.Paid then
    begin
      Inc(LCount);
      LTotal := LTotal + LOrder.Total;
    end;
  Result := Format('%d to pay (%s)', [LCount, FormatCurr('#,##0.00', LTotal)]);
end;

// a "sync with the server" every 3 seconds, in a background thread: LastSync
// is set there, its listeners run in the main thread
procedure StartSync;
begin
  SyncTask := TTask.Run(
    procedure
    var
      LStep: Integer;
    begin
      while not Stopping do
      begin
        LastSync.Value := Now;
        for LStep := 1 to 30 do
        begin
          if Stopping then
            Exit;
          Sleep(100);
        end;
      end;
    end);
end;

initialization
  Orders := [
    Default(TOrder), Default(TOrder), Default(TOrder), Default(TOrder)
  ];
  Orders[0].Customer := 'Rossi S.r.l.';    Orders[0].Total := 1250;
  Orders[1].Customer := 'Bianchi S.p.A.';  Orders[1].Total := 380.5;  Orders[1].Paid := True;
  Orders[2].Customer := 'Verdi & Co.';     Orders[2].Total := 99.9;
  Orders[3].Customer := 'Neri Logistica';  Orders[3].Total := 4200;

  AppState := TComponent.Create(nil);
  OrdersChanged := TChangeNotifier.Create(AppState);
  LastSync := TObservable<TDateTime>.Create(AppState, 0);
  StartSync;

finalization
  Stopping := True;
  if Assigned(SyncTask) then
    SyncTask.Wait(2000);
  AppState.Free;   // the observables (a notification still queued is dropped)

end.
