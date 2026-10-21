unit FMXER.Navigator;

interface

uses
  System.Classes, System.SysUtils, System.StrUtils, System.Types, System.UITypes, Generics.Collections
, FMX.Types, FMX.Controls, FMX.Forms, FMX.Layouts
, SubjectStand, FormStand
;

type
  TNavigator = class
  private
    FFormStand: TFormStand;
    FBackKeyHook: TComponent;
    FSafeAreaHook: TComponent;
    function GetCatchBackKey: Boolean;
    procedure SetCatchBackKeyValue(const AValue: Boolean);
    function GetSafeArea: Boolean;
    procedure SetSafeAreaValue(const AValue: Boolean);
    function GetSafeAreaLayout: TLayout;
  protected
    FOnCloseRouteProc: TProc<string>;
    FOnCreateRouteProc: TProc<string>;
    FRouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>>;
    FActiveRoutes: TDictionary<string, TSubjectInfo>;
    FStack: TStack<string>;
    FTransientRoutes: TList<string>; // active routes opened as transient (not on the stack)
    FBackHandlers: TList<TFunc<Boolean>>;
  protected
    class var _ClassInstance: TNavigator;
    class function GetClassInstance: TNavigator; static;
    class function GetInitialized: Boolean; static;
  protected
    procedure DoCloseRouteProc(const ARouteName: string); virtual;
    procedure RemoveFromStack(const ARouteName: string);
  public
    constructor Create(const AFormStand: TFormStand); virtual;
    destructor Destroy; override;
    //
    procedure CloseAllRoutes(const AFilter: TPredicate<string> = nil);
    procedure CloseAllRoutesExcept(const ARouteName: string);
    procedure CloseRoute(const ARouteName: string; const ATransient: Boolean = False);
    procedure CloseRouteDelayed(const ARouteName: string; const ATransient: Boolean; const ADelay_ms: Integer = 100);
    procedure StackPop;
    procedure RouteTo(const ARouteName: string; const ATransient: Boolean = False);
    procedure RouteToDelayed(const ARouteName: string; const ATransient: Boolean; const ADelay_ms: Integer = 100);
    function DefineRoute(const ARouteName: string;
      const ARouteDef: TFunc<TSubjectInfo>): TNavigator; overload;
    function DefineRoute<T: TForm>(const ARouteName: string;
      const AConfigProc: TProc<T> = nil;
      const AParent: TFmxObject = nil;
      const AStandName: string = ''): TNavigator; overload;

    function IsRouteDefined(const ARouteName: string): Boolean;
    function IsRouteActive(const ARouteName: string): Boolean;
    function SetOnCreateRoute(const AOnCreateRouteProc: TProc<string>): TNavigator;
    function SetOnCloseRoute(const AOnCloseRouteProc: TProc<string>): TNavigator;
    function Breadcrumb: TArray<string>;

    /// <summary>Back (vkHardwareBack) and Esc: closes the route on top of the
    /// stack (StackPop) when the stack has more than one route, and clears
    /// AKey and AKeyChar so that Android does not close the app. While a
    /// transient route is open (a wait screen) the key is consumed and nothing
    /// is closed. Returns True when it handled the key. Call it from OnKeyDown
    /// of the form, or set CatchBackKey.</summary>
    function HandleBackKey(var AKey: Word; var AKeyChar: WideChar): Boolean;
    /// <summary>Back/Esc asks AHandler first (the last added first): when it
    /// returns True the key is handled and no route is closed. For an element
    /// that closes something of its own on Back (the drawer of TScaffoldForm).
    /// Remove it with RemoveBackHandler, passing the same reference.</summary>
    function AddBackHandler(const AHandler: TFunc<Boolean>): TNavigator;
    procedure RemoveBackHandler(const AHandler: TFunc<Boolean>);
    /// <summary>True: the navigator handles Back/Esc by itself, hooking
    /// OnKeyDown of the form that owns FormStand (the previous handler is still
    /// called for the keys the navigator does not handle).</summary>
    function SetCatchBackKey(const AValue: Boolean): TNavigator;
    /// <summary>True (the default when FormStand is owned by a form): the routes
    /// stay within the safe area of the form, clear of the system bars (Android 15+
    /// draws the app edge-to-edge, under the status and navigation bars) and of
    /// the notch (iOS). The navigator puts a layout in the form, as DefaultParent
    /// of FormStand (unless one is set), and gives it the safe area insets as
    /// margins, hooking OnSafeAreaChanged of the form (the previous handler is
    /// still called). Routes created with an explicit parent are not moved. Set it
    /// before the first route is shown.</summary>
    function SetSafeArea(const AValue: Boolean): TNavigator;
    //
    property ActiveRoutes: TDictionary<string, TSubjectInfo> read FActiveRoutes;
    property RouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>> read FRouteDefinitions;
    property FormStand: TFormStand read FFormStand;
    property Stack: TStack<string> read FStack;
    property OnCreateRoute: TProc<string> read FOnCreateRouteProc write FOnCreateRouteProc;
    property OnCloseRoute: TProc<string> read FOnCloseRouteProc write FOnCloseRouteProc;
    property CatchBackKey: Boolean read GetCatchBackKey write SetCatchBackKeyValue;
    property SafeArea: Boolean read GetSafeArea write SetSafeAreaValue;
    /// <summary>The layout the routes are shown in when SafeArea is True (nil
    /// otherwise).</summary>
    property SafeAreaLayout: TLayout read GetSafeAreaLayout;

    /// <summary>Creates the singleton returned by Navigator. Other instances
    /// can be created with TNavigator.Create (and freed by their owner): each
    /// one has its own routes and stack.</summary>
    class procedure Init(const AFormStand: TFormStand);
    /// <summary>Frees the singleton (Navigator raises again until Init); the
    /// routes still open are not closed.</summary>
    class procedure ReleaseInstance;
    class property Instance: TNavigator read GetClassInstance;
    class property Initialized: Boolean read GetInitialized;

    class destructor ClassDestroy;
  end;

function Navigator(const AFormStand: TFormStand = nil): TNavigator;

implementation

type
  /// <summary>Owned by the form: hooks its OnKeyDown for TNavigator.CatchBackKey.</summary>
  TNavigatorBackKeyHook = class(TComponent)
  private
    FForm: TCommonCustomForm;
    FNavigator: TNavigator;
    FPreviousKeyDown: TKeyEvent;
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
  public
    constructor Create(const AForm: TCommonCustomForm; const ANavigator: TNavigator); reintroduce;
    destructor Destroy; override;
  end;

  /// <summary>Owned by the form: the layout within its safe area, parent of the
  /// routes (TNavigator.SafeArea).</summary>
  TNavigatorSafeArea = class(TComponent)
  private
    FForm: TCommonCustomForm;
    FNavigator: TNavigator;
    FLayout: TLayout;
    FPreviousSafeAreaChanged: TSafeAreaChangedEvent;
    procedure FormSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
  public
    constructor Create(const AForm: TCommonCustomForm; const ANavigator: TNavigator); reintroduce;
    destructor Destroy; override;
    procedure ApplyInsets(const AInsets: TRectF);
    property Layout: TLayout read FLayout;
  end;

{ TNavigatorSafeArea }

constructor TNavigatorSafeArea.Create(const AForm: TCommonCustomForm;
  const ANavigator: TNavigator);
begin
  inherited Create(AForm);
  FForm := AForm;
  FNavigator := ANavigator;

  // Align = Client: the stands are Align = Contents, they fill this layout
  FLayout := TLayout.Create(Self);
  FLayout.Align := TAlignLayout.Client;
  FLayout.HitTest := False;
  FLayout.Parent := AForm;
  if not Assigned(ANavigator.FormStand.DefaultParent) then
    ANavigator.FormStand.DefaultParent := FLayout;

  FPreviousSafeAreaChanged := AForm.OnSafeAreaChanged;
  AForm.OnSafeAreaChanged := FormSafeAreaChanged;
end;

destructor TNavigatorSafeArea.Destroy;
var
  LHandler: TSafeAreaChangedEvent;
begin
  // put the previous handler back, if nobody replaced this one meanwhile
  if Assigned(FForm) and not (csDestroying in FForm.ComponentState) then
  begin
    LHandler := FormSafeAreaChanged;
    if TMethod(FForm.OnSafeAreaChanged) = TMethod(LHandler) then
      FForm.OnSafeAreaChanged := FPreviousSafeAreaChanged;
  end;
  if Assigned(FNavigator) then
  begin
    if Assigned(FNavigator.FormStand) and (FNavigator.FormStand.DefaultParent = FLayout) then
      FNavigator.FormStand.DefaultParent := nil;
    // freed with the form: the navigator must not free it again
    if FNavigator.FSafeAreaHook = Self then
      FNavigator.FSafeAreaHook := nil;
  end;
  inherited;
end;

procedure TNavigatorSafeArea.ApplyInsets(const AInsets: TRectF);
begin
  FLayout.Margins.Rect := AInsets;
end;

procedure TNavigatorSafeArea.FormSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
begin
  ApplyInsets(AInsets);
  if Assigned(FPreviousSafeAreaChanged) then
    FPreviousSafeAreaChanged(Sender, AInsets);
end;

{ TNavigatorBackKeyHook }

constructor TNavigatorBackKeyHook.Create(const AForm: TCommonCustomForm;
  const ANavigator: TNavigator);
begin
  inherited Create(AForm);
  FForm := AForm;
  FNavigator := ANavigator;
  FPreviousKeyDown := AForm.OnKeyDown;
  AForm.OnKeyDown := FormKeyDown;
end;

destructor TNavigatorBackKeyHook.Destroy;
var
  LHandler: TKeyEvent;
begin
  // put the previous handler back, if nobody replaced this one meanwhile
  if Assigned(FForm) and not (csDestroying in FForm.ComponentState) then
  begin
    LHandler := FormKeyDown;
    if TMethod(FForm.OnKeyDown) = TMethod(LHandler) then
      FForm.OnKeyDown := FPreviousKeyDown;
  end;
  // freed with the form: the navigator must not free it again
  if Assigned(FNavigator) and (FNavigator.FBackKeyHook = Self) then
    FNavigator.FBackKeyHook := nil;
  inherited;
end;

procedure TNavigatorBackKeyHook.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if Assigned(FNavigator) and FNavigator.HandleBackKey(Key, KeyChar) then
    Exit;
  if Assigned(FPreviousKeyDown) then
    FPreviousKeyDown(Sender, Key, KeyChar, Shift);
end;

function Navigator(const AFormStand: TFormStand = nil): TNavigator;
begin
  if (not TNavigator.Initialized) and Assigned(AFormStand) then
    TNavigator.Init(AFormStand)
  else if Assigned(AFormStand) and (AFormStand <> TNavigator.Instance.FormStand) then
    raise Exception.Create('Navigator has been already initialized with another form stand');

  Result := TNavigator.Instance;
end;

{ TNavigator }

function TNavigator.Breadcrumb: TArray<string>;
begin
  Result := [];
  if Assigned(FStack) then
    Result := FStack.ToArray;
end;

class destructor TNavigator.ClassDestroy;
begin
  if Assigned(_ClassInstance) then
    FreeAndNil(_ClassInstance);
end;

procedure TNavigator.CloseAllRoutes(const AFilter: TPredicate<string> = nil);
var
  LActiveRoutes: TArray<string>;
  LRoute: string;
begin
  LActiveRoutes := FActiveRoutes.Keys.ToArray;
  for LRoute in LActiveRoutes do
  begin
    if (not Assigned(AFilter)) or AFilter(LRoute) then
      CloseRoute(LRoute);
  end;
end;

procedure TNavigator.CloseAllRoutesExcept(const ARouteName: string);
begin
  CloseAllRoutes(
    function (ARoute: string): Boolean
    begin
      Result := ARoute <> ARouteName;
    end
  );
end;

procedure TNavigator.CloseRoute(const ARouteName: string; const ATransient: Boolean);
var
  LSubjectInfo: TSubjectInfo;
begin
  if ActiveRoutes.TryGetValue(ARouteName, LSubjectInfo) then
  begin
    LSubjectInfo.HideAndClose(
      0
    , procedure
      begin
        DoCloseRouteProc(ARouteName);
      end
    );
    ActiveRoutes.Remove(ARouteName);
    // the navigator knows whether the route is transient (ATransient is kept
    // for compatibility): a transient route is not on the stack, any other
    // route is removed from it wherever it is (not only from the top)
    if FTransientRoutes.Remove(ARouteName) < 0 then
      RemoveFromStack(ARouteName);
  end;
end;

procedure TNavigator.CloseRouteDelayed(const ARouteName: string; const ATransient: Boolean;
  const ADelay_ms: Integer);
begin
  TDelayedAction.Execute(ADelay_ms
    , procedure
      begin
        CloseRoute(ARouteName, ATransient);
      end
  );
end;

constructor TNavigator.Create(const AFormStand: TFormStand);
begin
  inherited Create;
  FFormStand := AFormStand;
  FRouteDefinitions := TDictionary<string, TFunc<TSubjectInfo>>.Create;
  FActiveRoutes := TDictionary<string, TSubjectInfo>.Create;
  FStack := TStack<string>.Create;
  FTransientRoutes := TList<string>.Create;
  FBackHandlers := TList<TFunc<Boolean>>.Create;
  // the routes within the safe area of the form (system bars, notch)
  if Assigned(FFormStand) and (FFormStand.Owner is TCommonCustomForm) then
    SetSafeAreaValue(True);
end;

function TNavigator.DefineRoute(const ARouteName: string;
  const ARouteDef: TFunc<TSubjectInfo>): TNavigator;
begin
  Result := Self;
  RouteDefinitions.Add(ARouteName, ARouteDef);
end;

function TNavigator.DefineRoute<T>(const ARouteName: string;
  const AConfigProc: TProc<T>; const AParent: TFmxObject;
      const AStandName: string): TNavigator;
begin
  Result := DefineRoute(ARouteName
  , function: TSubjectInfo
    begin
      Result := FormStand.New<T>(AParent, AStandName);
      if Assigned(AConfigProc) then
        AConfigProc(T(Result.Subject));
    end
  );
end;

destructor TNavigator.Destroy;
begin
  SetCatchBackKeyValue(False);
  // the safe area layout stays with the form (routes may still be in it)
  if Assigned(FSafeAreaHook) then
  begin
    TNavigatorSafeArea(FSafeAreaHook).FNavigator := nil;
    FSafeAreaHook := nil;
  end;
  FreeAndNil(FBackHandlers);
  FreeAndNil(FTransientRoutes);
  FreeAndNil(FStack);
  FreeAndNil(FActiveRoutes);
  FreeAndNil(FRouteDefinitions);
  inherited;
end;

procedure TNavigator.DoCloseRouteProc(const ARouteName: string);
begin
  if Assigned(FOnCloseRouteProc) then
    FOnCloseRouteProc(ARouteName);
end;

class function TNavigator.GetClassInstance: TNavigator;
begin
  if not Assigned(_ClassInstance) then
    raise Exception.Create('Navigator has not been initialized');
  Result := _ClassInstance;
end;

class function TNavigator.GetInitialized: Boolean;
begin
  Result := Assigned(_ClassInstance);
end;

function TNavigator.GetCatchBackKey: Boolean;
begin
  Result := Assigned(FBackKeyHook);
end;

procedure TNavigator.SetCatchBackKeyValue(const AValue: Boolean);
var
  LHook: TComponent;
begin
  if AValue = Assigned(FBackKeyHook) then
    Exit;
  if AValue then
  begin
    if not (Assigned(FFormStand) and (FFormStand.Owner is TCommonCustomForm)) then
      raise Exception.Create('CatchBackKey needs a form stand owned by a form');
    FBackKeyHook := TNavigatorBackKeyHook.Create(TCommonCustomForm(FFormStand.Owner), Self);
  end
  else
  begin
    LHook := FBackKeyHook;
    FBackKeyHook := nil;
    TNavigatorBackKeyHook(LHook).FNavigator := nil;
    LHook.Free;
  end;
end;

function TNavigator.GetSafeArea: Boolean;
begin
  Result := Assigned(FSafeAreaHook);
end;

function TNavigator.GetSafeAreaLayout: TLayout;
begin
  Result := nil;
  if Assigned(FSafeAreaHook) then
    Result := TNavigatorSafeArea(FSafeAreaHook).Layout;
end;

procedure TNavigator.SetSafeAreaValue(const AValue: Boolean);
var
  LHook: TComponent;
begin
  if AValue = Assigned(FSafeAreaHook) then
    Exit;
  if AValue then
  begin
    if not (Assigned(FFormStand) and (FFormStand.Owner is TCommonCustomForm)) then
      raise Exception.Create('SafeArea needs a form stand owned by a form');
    FSafeAreaHook := TNavigatorSafeArea.Create(TCommonCustomForm(FFormStand.Owner), Self);
  end
  else
  begin
    // the layout goes with the hook: not while routes are in it
    if TNavigatorSafeArea(FSafeAreaHook).Layout.ChildrenCount > 0 then
      raise Exception.Create('SafeArea: routes are already shown in the safe area layout');
    LHook := FSafeAreaHook;
    FSafeAreaHook := nil;
    LHook.Free;
  end;
end;

function TNavigator.SetSafeArea(const AValue: Boolean): TNavigator;
begin
  Result := Self;
  SetSafeAreaValue(AValue);
end;

function TNavigator.SetCatchBackKey(const AValue: Boolean): TNavigator;
begin
  Result := Self;
  SetCatchBackKeyValue(AValue);
end;

function TNavigator.HandleBackKey(var AKey: Word; var AKeyChar: WideChar): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  if (AKey <> vkHardwareBack) and (AKey <> vkEscape) then
    Exit;
  for LIndex := FBackHandlers.Count - 1 downto 0 do
    if FBackHandlers[LIndex]() then
    begin
      Result := True;
      Break;
    end;
  if Result then
    // handled by an element
  else if FTransientRoutes.Count > 0 then
    Result := True // a wait screen is open: Back does nothing
  else if FStack.Count > 1 then
  begin
    Result := True;
    StackPop;
  end;
  if Result then
  begin
    // handled: Android must not close the app
    AKey := 0;
    AKeyChar := #0;
  end;
end;

function TNavigator.AddBackHandler(const AHandler: TFunc<Boolean>): TNavigator;
begin
  Result := Self;
  FBackHandlers.Add(AHandler);
end;

procedure TNavigator.RemoveBackHandler(const AHandler: TFunc<Boolean>);
begin
  FBackHandlers.Remove(AHandler);
end;

class procedure TNavigator.ReleaseInstance;
begin
  FreeAndNil(_ClassInstance);
end;

class procedure TNavigator.Init(const AFormStand: TFormStand);
begin
  if Assigned(_ClassInstance) then
    raise Exception.Create('Navigator has been already initialized');

  _ClassInstance := TNavigator.Create(AFormStand);
end;

function TNavigator.IsRouteActive(const ARouteName: string): Boolean;
begin
  Result := ActiveRoutes.ContainsKey(ARouteName);
end;

function TNavigator.IsRouteDefined(const ARouteName: string): Boolean;
begin
  Result := RouteDefinitions.ContainsKey(ARouteName);
end;

procedure TNavigator.RemoveFromStack(const ARouteName: string);
var
  LRoutes: TArray<string>;
  LIndex, LRemove: Integer;
begin
  LRoutes := FStack.ToArray; // bottom first
  LRemove := -1;
  for LIndex := High(LRoutes) downto 0 do
    if LRoutes[LIndex] = ARouteName then
    begin
      LRemove := LIndex;
      Break;
    end;
  if LRemove < 0 then
    Exit;

  FStack.Clear;
  for LIndex := 0 to High(LRoutes) do
    if LIndex <> LRemove then
      FStack.Push(LRoutes[LIndex]);
end;

procedure TNavigator.RouteTo(const ARouteName: string; const ATransient: Boolean);
var
  LSubjectInfo: TSubjectInfo;
  LDefinitionFunc: TFunc<TSubjectInfo>;
begin
  if not ActiveRoutes.TryGetValue(ARouteName, LSubjectInfo) then
    // on-demand creation, if definition available
    if RouteDefinitions.TryGetValue(ARouteName, LDefinitionFunc) then
    begin
      LSubjectInfo := LDefinitionFunc();
      ActiveRoutes.Add(ARouteName, LSubjectInfo);

      if ATransient then
        FTransientRoutes.Add(ARouteName)
      else
        FStack.Push(ARouteName);

      if Assigned(FOnCreateRouteProc) then
        FOnCreateRouteProc(ARouteName);
    end
    else raise Exception.CreateFmt('Route definition not found: %s', [ARouteName]);

  if Assigned(LSubjectInfo) then
    LSubjectInfo.SubjectShow;
end;

procedure TNavigator.RouteToDelayed(const ARouteName: string; const ATransient: Boolean;
  const ADelay_ms: Integer);
begin
  TDelayedAction.Execute(ADelay_ms
    , procedure
      begin
        RouteTo(ARouteName, ATransient);
      end
  );
end;

function TNavigator.SetOnCloseRoute(
  const AOnCloseRouteProc: TProc<string>): TNavigator;
begin
  Result := Self;
  FOnCloseRouteProc := AOnCloseRouteProc;
end;

function TNavigator.SetOnCreateRoute(
  const AOnCreateRouteProc: TProc<string>): TNavigator;
begin
  Result := Self;
  FOnCreateRouteProc := AOnCreateRouteProc;
end;

procedure TNavigator.StackPop;
var
  LRouteName: string;
begin
  if Stack.Count > 0 then
  begin
    LRouteName := Stack.Peek;
    CloseRoute(LRouteName, False);
  end;
end;

end.
