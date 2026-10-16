unit Tests.Common;

// Helpers shared by the fixtures.

interface

uses
  System.SysUtils, System.Classes, FMX.Forms, FormStand, FMXER.Navigator;

type
  /// <summary>Access to the navigator singleton, to give every test a fresh one.</summary>
  TNavigatorAccess = class(TNavigator)
  public
    class procedure Reset;
  end;

/// <summary>Runs the message loop and the synchronize queue for AMS milliseconds
/// (timers and delayed actions fire through them).</summary>
procedure Pump(const AMS: Integer);

implementation

uses
  System.Diagnostics;

procedure Pump(const AMS: Integer);
var
  LStopwatch: TStopwatch;
begin
  LStopwatch := TStopwatch.StartNew;
  repeat
    Application.ProcessMessages;
    CheckSynchronize(5);
  until LStopwatch.ElapsedMilliseconds >= AMS;
end;

{ TNavigatorAccess }

class procedure TNavigatorAccess.Reset;
begin
  FreeAndNil(_ClassInstance);
end;

end.
