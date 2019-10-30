unit UI.Navigator;

interface

uses
  Classes, SysUtils, Generics.Collections, FMX.Types, FMX.Forms, SubjectStand, FormStand;

type
  TNavigator = class
  private
    FFormStand: TFormStand;
    FOnCloseRouteProc: TProc<string>;
    FOnCreateRouteProc: TProc<string>;
  protected
    FRouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>>;
    FActiveRoutes: TDictionary<string, TSubjectInfo>;
    FStack: TStack<string>;
  protected
    class var _ClassInstance: TNavigator;
    class function GetClassInstance: TNavigator; static;
    class function GetInitialized: Boolean; static;
  public
    constructor Create(const AFormStand: TFormStand); virtual;
    destructor Destroy; override;
    //
    procedure CloseAllRoutes(const AFilter: TPredicate<string> = nil);
    procedure CloseAllRoutesExcept(const ARouteName: string);
    procedure CloseRoute(const ARouteName: string);
    procedure CloseRouteDelayed(const ARouteName: string; const ADelay_ms: Integer = 100);
    procedure StackPop;
    procedure RouteTo(const ARouteName: string);
    procedure RouteToDelayed(const ARouteName: string; const ADelay_ms: Integer = 100);
    function DefineRoute(const ARouteName: string;
      const ARouteDef: TFunc<TSubjectInfo>): TNavigator; overload;
    function DefineRoute<T: TForm>(const ARouteName: string;
      const AConfigProc: TProc<T> = nil;
      const AParent: TFmxObject = nil;
      const AStandName: string = ''): TNavigator; overload;
    //
    property ActiveRoutes: TDictionary<string, TSubjectInfo> read FActiveRoutes;
    property RouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>> read FRouteDefinitions;
    property FormStand: TFormStand read FFormStand;
    property Stack: TStack<string> read FStack;
    property OnCreateRoute: TProc<string> read FOnCreateRouteProc write FOnCreateRouteProc;
    property OnCloseRoute: TProc<string> read FOnCloseRouteProc write FOnCloseRouteProc;

    class procedure Init(const AFormStand: TFormStand);
    class property Instance: TNavigator read GetClassInstance;
    class property Initialized: Boolean read GetInitialized;

    class destructor ClassDestroy;
  end;

function Navigator(const AFormStand: TFormStand = nil): TNavigator;

implementation


function Navigator(const AFormStand: TFormStand = nil): TNavigator;
begin
  if (not TNavigator.Initialized) and Assigned(AFormStand) then
    TNavigator.Init(AFormStand);

  Result := TNavigator.Instance;
end;

{ TNavigator }

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

procedure TNavigator.CloseRoute(const ARouteName: string);
var
  LSubjectInfo: TSubjectInfo;
begin
  if ActiveRoutes.TryGetValue(ARouteName, LSubjectInfo) then
  begin
    LSubjectInfo.HideAndClose(0
      , procedure
        begin
          if Assigned(FOnCloseRouteProc) then
            FOnCloseRouteProc(ARouteName);
        end
    );
    ActiveRoutes.Remove(ARouteName);
    FStack.Pop;
  end;
end;

procedure TNavigator.CloseRouteDelayed(const ARouteName: string;
  const ADelay_ms: Integer);
begin
  TDelayedAction.Execute(ADelay_ms
    , procedure
      begin
        CloseRoute(ARouteName);
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
  FreeAndNil(FStack);
  FreeAndNil(FActiveRoutes);
  FreeAndNil(FRouteDefinitions);
  inherited;
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

class procedure TNavigator.Init(const AFormStand: TFormStand);
begin
  if Assigned(_ClassInstance) then
    raise Exception.Create('Navigator has been already initialized');

  _ClassInstance := TNavigator.Create(AFormStand);
end;

procedure TNavigator.RouteTo(const ARouteName: string);
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
      FStack.Push(ARouteName);
      if Assigned(FOnCreateRouteProc) then
        FOnCreateRouteProc(ARouteName);
    end;

  if Assigned(LSubjectInfo) then
    LSubjectInfo.SubjectShow;
end;

procedure TNavigator.RouteToDelayed(const ARouteName: string;
  const ADelay_ms: Integer);
begin
  TDelayedAction.Execute(ADelay_ms
    , procedure
      begin
        RouteTo(ARouteName);
      end
  );
end;

procedure TNavigator.StackPop;
var
  LRouteName: string;
begin
  if Stack.Count > 0 then
  begin
    LRouteName := Stack.Peek;
    CloseRoute(LRouteName);
  end;
end;

end.
