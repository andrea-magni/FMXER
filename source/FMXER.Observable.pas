unit FMXER.Observable;

// Observable values for the state of an app (Flutter ValueNotifier /
// ChangeNotifier): elements listen to a value and update themselves when it
// changes. A listener is tied to an owner component (usually the element it
// updates): it is removed when the owner is freed. Notifications run in the
// main thread, also when the value is set by a background thread.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults;

type
  /// <summary>Shared by an observable and the notifications it queued for the
  /// main thread: a notification queued before the observable was freed is
  /// dropped.</summary>
  IObservableLife = interface
    ['{6E2D1C3B-8F4A-4B7E-9C21-5A0F3D8E7B14}']
    function IsAlive: Boolean;
    procedure Kill;
  end;

  /// <summary>What TObservable&lt;T&gt; and TChangeNotifier have in common:
  /// listeners tied to owner components, notifications in the main thread.</summary>
  TObservableBase = class(TComponent)
  private
    FLife: IObservableLife;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    /// <summary>Removes the listeners of AOwner (freed or Unlisten).</summary>
    procedure RemoveListeners(const AOwner: TComponent); virtual; abstract;
    /// <summary>Removes the listeners of AOwner when it is freed.</summary>
    procedure WatchOwner(const AOwner: TComponent);
    /// <summary>Runs AProc now in the main thread, queued from any other
    /// thread (not run if the observable is freed before).</summary>
    procedure RunInMainThread(const AProc: TProc);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  /// <summary>A value that notifies its listeners when it changes (Flutter
  /// ValueNotifier). A component: create it owned by the state (a data
  /// module, the state of a route), which frees it.</summary>
  TObservable<T> = class(TObservableBase)
  private
    type
      TListener = record
        Owner: TComponent;
        Proc: TProc<T>;
      end;
  private
    FValue: T;
    FListeners: TList<TListener>;
    FComparer: IEqualityComparer<T>;
    function GetValue: T;
    procedure SetValue(const AValue: T);
    procedure DoNotify(const AValue: T);
  protected
    procedure RemoveListeners(const AOwner: TComponent); override;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; const AInitial: T); reintroduce; overload;
    destructor Destroy; override;

    /// <summary>AProc is called with the value whenever it changes, in the main
    /// thread; with ACallNow also now, with the current value (initialize and
    /// update the element in one place). The listener is removed when AOwner
    /// is freed (nil: never). Call it from the main thread.</summary>
    function Listen(const AOwner: TComponent; const AProc: TProc<T>;
      const ACallNow: Boolean = True): TObservable<T>;
    /// <summary>Removes the listeners of AOwner.</summary>
    procedure Unlisten(const AOwner: TComponent);
    /// <summary>Value := AFunc(Value): for records, change a field and notify.</summary>
    procedure Update(const AFunc: TFunc<T, T>);
    /// <summary>Notifies the current value even if it did not change (e.g. an
    /// object changed inside).</summary>
    procedure Notify;
    function ListenerCount: Integer;

    /// <summary>Setting a value different from the current one (default
    /// equality comparer of T) notifies the listeners: at once in the main
    /// thread, queued to the main thread from any other thread.</summary>
    property Value: T read GetValue write SetValue;
  end;

  /// <summary>The link of an element to an observable, for the Bind* methods
  /// of the elements: owned by the element (freed with it, which removes the
  /// listener), forgets the observable when the observable is freed first.</summary>
  TObservableLink<T> = class(TComponent)
  private
    FObservable: TObservable<T>;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    /// <summary>Listens to AObservable with AShow (called now too), instead of
    /// the observable linked before; nil: no observable.</summary>
    procedure Bind(const AObservable: TObservable<T>; const AShow: TProc<T>);
    /// <summary>Writes AValue to the observable, if any (two-way bindings).</summary>
    procedure Write(const AValue: T);
    property Observable: TObservable<T> read FObservable;
  end;

  /// <summary>A notification without a value (Flutter ChangeNotifier): "this
  /// state changed", for example after loading it.</summary>
  TChangeNotifier = class(TObservableBase)
  private
    type
      TListener = record
        Owner: TComponent;
        Proc: TProc;
      end;
  private
    FListeners: TList<TListener>;
    procedure DoNotify;
  protected
    procedure RemoveListeners(const AOwner: TComponent); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    /// <summary>AProc is called on every NotifyChanged (in the main thread);
    /// with ACallNow also now. Removed when AOwner is freed.</summary>
    function Listen(const AOwner: TComponent; const AProc: TProc;
      const ACallNow: Boolean = False): TChangeNotifier;
    procedure Unlisten(const AOwner: TComponent);
    /// <summary>Calls the listeners: at once in the main thread, queued from
    /// any other thread.</summary>
    procedure NotifyChanged;
    function ListenerCount: Integer;
  end;

implementation

type
  TObservableLife = class(TInterfacedObject, IObservableLife)
  private
    FAlive: Boolean;
  public
    constructor Create;
    function IsAlive: Boolean;
    procedure Kill;
  end;

{ TObservableLife }

constructor TObservableLife.Create;
begin
  inherited Create;
  FAlive := True;
end;

function TObservableLife.IsAlive: Boolean;
begin
  Result := FAlive;
end;

procedure TObservableLife.Kill;
begin
  FAlive := False;
end;

{ TObservableBase }

constructor TObservableBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLife := TObservableLife.Create;
end;

destructor TObservableBase.Destroy;
begin
  // queued notifications are dropped
  FLife.Kill;
  inherited;
end;

procedure TObservableBase.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
    RemoveListeners(AComponent);
end;

procedure TObservableBase.RunInMainThread(const AProc: TProc);
var
  LLife: IObservableLife;
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    AProc()
  else
  begin
    LLife := FLife;
    TThread.Queue(nil,
      procedure
      begin
        if LLife.IsAlive then
          AProc();
      end);
  end;
end;

procedure TObservableBase.WatchOwner(const AOwner: TComponent);
begin
  if Assigned(AOwner) then
    AOwner.FreeNotification(Self);
end;

{ TObservable<T> }

constructor TObservable<T>.Create(AOwner: TComponent);
begin
  Create(AOwner, Default(T));
end;

constructor TObservable<T>.Create(AOwner: TComponent; const AInitial: T);
begin
  inherited Create(AOwner);
  FListeners := TList<TListener>.Create;
  FComparer := TEqualityComparer<T>.Default;
  FValue := AInitial;
end;

destructor TObservable<T>.Destroy;
begin
  inherited;   // TComponent removes the free notifications first
  FreeAndNil(FListeners);
end;

procedure TObservable<T>.DoNotify(const AValue: T);
var
  LListeners: TArray<TListener>;
  LListener: TListener;
begin
  if not Assigned(FListeners) then
    Exit;
  // a copy: a listener may free an owner (and so remove listeners) or add one
  LListeners := FListeners.ToArray;
  for LListener in LListeners do
    if FListeners.Contains(LListener) then
      LListener.Proc(AValue);
end;

function TObservable<T>.GetValue: T;
begin
  TMonitor.Enter(Self);
  try
    Result := FValue;
  finally
    TMonitor.Exit(Self);
  end;
end;

function TObservable<T>.Listen(const AOwner: TComponent; const AProc: TProc<T>;
  const ACallNow: Boolean): TObservable<T>;
var
  LListener: TListener;
begin
  Result := Self;
  LListener.Owner := AOwner;
  LListener.Proc := AProc;
  FListeners.Add(LListener);
  WatchOwner(AOwner);
  if ACallNow then
    AProc(GetValue);
end;

function TObservable<T>.ListenerCount: Integer;
begin
  Result := FListeners.Count;
end;

procedure TObservable<T>.Notify;
var
  LValue: T;
begin
  LValue := GetValue;
  RunInMainThread(
    procedure
    begin
      DoNotify(LValue);
    end);
end;

procedure TObservable<T>.RemoveListeners(const AOwner: TComponent);
var
  LIndex: Integer;
begin
  if not Assigned(FListeners) then
    Exit;
  for LIndex := FListeners.Count - 1 downto 0 do
    if FListeners[LIndex].Owner = AOwner then
      FListeners.Delete(LIndex);
end;

procedure TObservable<T>.SetValue(const AValue: T);
begin
  TMonitor.Enter(Self);
  try
    if FComparer.Equals(FValue, AValue) then
      Exit;
    FValue := AValue;
  finally
    TMonitor.Exit(Self);
  end;
  RunInMainThread(
    procedure
    begin
      DoNotify(AValue);
    end);
end;

procedure TObservable<T>.Unlisten(const AOwner: TComponent);
begin
  RemoveListeners(AOwner);
  if Assigned(AOwner) then
    AOwner.RemoveFreeNotification(Self);
end;

procedure TObservable<T>.Update(const AFunc: TFunc<T, T>);
begin
  SetValue(AFunc(GetValue));
end;

{ TObservableLink<T> }

procedure TObservableLink<T>.Bind(const AObservable: TObservable<T>; const AShow: TProc<T>);
begin
  if Assigned(FObservable) then
  begin
    FObservable.Unlisten(Self);
    FObservable.RemoveFreeNotification(Self);
  end;
  FObservable := AObservable;
  if Assigned(FObservable) then
  begin
    FObservable.FreeNotification(Self);
    FObservable.Listen(Self, AShow, True);
  end;
end;

procedure TObservableLink<T>.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FObservable) then
    FObservable := nil;
end;

procedure TObservableLink<T>.Write(const AValue: T);
begin
  if Assigned(FObservable) then
    FObservable.Value := AValue;
end;

{ TChangeNotifier }

constructor TChangeNotifier.Create(AOwner: TComponent);
begin
  inherited;
  FListeners := TList<TListener>.Create;
end;

destructor TChangeNotifier.Destroy;
begin
  inherited;
  FreeAndNil(FListeners);
end;

procedure TChangeNotifier.DoNotify;
var
  LListeners: TArray<TListener>;
  LListener: TListener;
begin
  if not Assigned(FListeners) then
    Exit;
  LListeners := FListeners.ToArray;
  for LListener in LListeners do
    if FListeners.Contains(LListener) then
      LListener.Proc();
end;

function TChangeNotifier.Listen(const AOwner: TComponent; const AProc: TProc;
  const ACallNow: Boolean): TChangeNotifier;
var
  LListener: TListener;
begin
  Result := Self;
  LListener.Owner := AOwner;
  LListener.Proc := AProc;
  FListeners.Add(LListener);
  WatchOwner(AOwner);
  if ACallNow then
    AProc();
end;

function TChangeNotifier.ListenerCount: Integer;
begin
  Result := FListeners.Count;
end;

procedure TChangeNotifier.NotifyChanged;
begin
  RunInMainThread(DoNotify);
end;

procedure TChangeNotifier.RemoveListeners(const AOwner: TComponent);
var
  LIndex: Integer;
begin
  if not Assigned(FListeners) then
    Exit;
  for LIndex := FListeners.Count - 1 downto 0 do
    if FListeners[LIndex].Owner = AOwner then
      FListeners.Delete(LIndex);
end;

procedure TChangeNotifier.Unlisten(const AOwner: TComponent);
begin
  RemoveListeners(AOwner);
  if Assigned(AOwner) then
    AOwner.RemoveFreeNotification(Self);
end;

end.
