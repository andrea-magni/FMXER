unit UI.Misc;

interface

uses
  Classes, SysUtils, FMX.Layouts, System.Rtti,
  SubjectStand;

type
  TNameValueParam = record
    Name: string;
    Value: TValue;

    constructor Create(const AName: string; const AValue: TValue);
  end;

  TParams = TArray<TNameValueParam>;

  TElementDef<T> = record
    Params: TArray<TNameValueParam>;
    ConfigProc: TProc<T>;
    constructor Create(const AConfigProc: TProc<T>;
      const AParams: TParams = []);
    function FindParam(const AName: string; out AParam: TNameValueParam): Boolean;
    function ParamByName(const AName: string; const ADefaultValue: TValue): TValue; overload;
    function ParamByName(const AName: string): TValue; overload;
  end;


  TSubjectInfoContainer = class(TLayout)
  private
    FSubjectInfo: TSubjectInfo;
  protected
  public
    property SubjectInfo: TSubjectInfo read FSubjectInfo write FSubjectInfo;
  end;

  // shortcut function
  function Param(const AName: string; const AValue: TValue): TNameValueParam;

implementation

{ TElementDef<T> }

constructor TElementDef<T>.Create(const AConfigProc: TProc<T>;
  const AParams: TParams);
begin
  ConfigProc := AConfigProc;
  Params := AParams;
end;

function TElementDef<T>.FindParam(const AName: string;
  out AParam: TNameValueParam): Boolean;
var
  LParam: TNameValueParam;
begin
  Result := False;
  for LParam in Params do
  begin
    if SameText(LParam.Name, AName) then
    begin
      AParam := LParam;
      Result := True;
      Break;
    end;
  end;
end;

function TElementDef<T>.ParamByName(const AName: string): TValue;
begin
  Result := ParamByName(AName, TValue.Empty)
end;

function TElementDef<T>.ParamByName(const AName: string;
  const ADefaultValue: TValue): TValue;
var
  LParam: TNameValueParam;
begin
  Result := ADefaultValue;
  if FindParam(AName, LParam) then
    Result := LParam.Value;
end;

{ TNameValueParam }

constructor TNameValueParam.Create(const AName: string; const AValue: TValue);
begin
  Name := AName;
  Value := AValue;
end;

function Param(const AName: string; const AValue: TValue): TNameValueParam;
begin
  Result := TNameValueParam.Create(AName, AValue);
end;

end.
