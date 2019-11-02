unit FMXER.UI.Misc;

interface

uses
  Classes, SysUtils, System.Rtti, FMX.Forms, FMX.Layouts,
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
    function ContainedFrame<T: TFrame>: T;
    function ContainedForm<T: TForm>: T;
    property SubjectInfo: TSubjectInfo read FSubjectInfo write FSubjectInfo;
  end;

  // shortcut function
  function Param(const AName: string; const AValue: TValue): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TProc): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TFunc<Boolean>): TNameValueParam; overload;
  function OnClickProc(const AValue: TProc): TNameValueParam; overload;


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

function Param(const AName: string; const AValue: TProc): TNameValueParam;
begin
  Result := TNameValueParam.Create(AName, TValue.From<TProc>(AValue));
end;

function Param(const AName: string; const AValue: TFunc<Boolean>): TNameValueParam;
begin
  Result := TNameValueParam.Create(AName, TValue.From<TFunc<Boolean>>(AValue));
end;

function OnClickProc(const AValue: TProc): TNameValueParam;
begin
  Result := TNameValueParam.Create('OnClickProc', TValue.From<TProc>(AValue));
end;

{ TSubjectInfoContainer }

function TSubjectInfoContainer.ContainedForm<T>: T;
begin
  Result := nil;
  if Assigned(SubjectInfo) and (SubjectInfo.Subject is TForm) then
    Result := SubjectInfo.Subject as T;
end;

function TSubjectInfoContainer.ContainedFrame<T>: T;
begin
  Result := nil;
  if Assigned(SubjectInfo) and (SubjectInfo.Subject is TFrame) then
    Result := SubjectInfo.Subject as T;
end;

end.
