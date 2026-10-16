unit Tests.Common;

// Helpers shared by the fixtures.

interface

uses
  System.SysUtils, System.Classes, FMX.Forms, FormStand, FMXER.Navigator;

type
  /// <summary>Access to the navigator singleton, to give every test a fresh one.</summary>
  /// <summary>Sets a flag when it is destroyed: owned by an element, it tells
  /// whether the element was freed (the pattern of the subscription guard of
  /// the State &amp; Events guide relies on it).</summary>
  TDestroySentinel = class(TComponent)
  private
    FDestroyed: PBoolean;
  public
    constructor Create(const AOwner: TComponent; const ADestroyed: PBoolean); reintroduce;
    destructor Destroy; override;
  end;

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

{ TDestroySentinel }

constructor TDestroySentinel.Create(const AOwner: TComponent; const ADestroyed: PBoolean);
begin
  inherited Create(AOwner);
  FDestroyed := ADestroyed;
  FDestroyed^ := False;
end;

destructor TDestroySentinel.Destroy;
begin
  FDestroyed^ := True;
  inherited;
end;

{ TNavigatorAccess }

class procedure TNavigatorAccess.Reset;
begin
  TNavigator.ReleaseInstance;
end;

end.
