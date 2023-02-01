unit FMXER.UI.Misc;

interface

uses
  Classes, SysUtils, System.Rtti, FMX.Forms, FMX.Layouts, Types, FMX.Types,
  FMX.Controls,
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
    class operator Implicit(AConfigProc: TProc<T>): TElementDef<T>;
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

  TFMXERFormHelper = class helper for TCommonCustomForm
    function SetPadding(const APadding: Single): TCommonCustomForm; overload;
    function SetPadding<T: TControl>(const APadding: Single): T; overload;
    function SetWidth(const AWidth: Integer): TCommonCustomForm; overload;
    function SetHeight(const AHeight: Integer): TCommonCustomForm; overload;
  end;

  TFMXERFrameHelper = class helper for TControl
    function SetPadding(const APadding: Single): TControl; overload;
    function SetPadding<T: TControl>(const APadding: Single): T; overload;
    function SetPadding(const ALeft, ATop, ARight, ABottom: Single): TControl; overload;
    function SetPadding<T: TControl>(const ALeft, ATop, ARight, ABottom: Single): T; overload;
    function SetPaddingLR(const APadding: Single): TControl;
    function SetPaddingTB(const APadding: Single): TControl;

    function SetMargin(const AMargin: Single): TControl; overload;
    function SetMargin<T: TControl>(const AMargin: Single): T; overload;
    function SetMargin(const ALeft, ATop, ARight, ABottom: Single): TControl; overload;
    function SetMargin<T: TControl>(const ALeft, ATop, ARight, ABottom: Single): T; overload;
    function SetMarginLR(const AMargin: Single): TControl;
    function SetMarginT(const AMarginTop: Single): TControl;
    function SetMarginB(const AMarginBottom: Single): TControl;
    function SetMarginTB(const AMargin: Single): TControl;

    function SetAlignRight: TControl;
    function SetAlignLeft: TControl;
    function SetAlignTop: TControl;
    function SetAlignBottom: TControl;
    function SetAlignClient: TControl;
    function SetAlignContents: TControl;

    function SetHitTest(const AHitTest: Boolean): TControl;

    function SetWidth(const AWidth: Single): TControl;
    function SetHeight(const AHeight: Single): TControl;
  end;

  TCaptionPosition = (Left, Right, Top, Bottom);

  // shortcut function
  function Param(const AName: string; const AValue: TValue): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TProc): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TFunc<Boolean>): TNameValueParam; overload;
  function OnClickProc(const AValue: TProc): TNameValueParam; overload;

  function LocalFile(const AFileName: string): string;


implementation

uses IOUtils;

function LocalFile(const AFileName: string): string;
begin
  Result := TPath.Combine(
   {$IFDEF MSWINDOWS} '..\..\..\..\media\' {$ENDIF}
   {$IFDEF ANDROID  } TPath.GetDocumentsPath {$ENDIF}
   {$IFDEF MACOS  } TPath.GetDocumentsPath {$ENDIF}
   {$IFDEF IOS  } TPath.GetDocumentsPath {$ENDIF}
  , AFileName);
end;

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

class operator TElementDef<T>.Implicit(AConfigProc: TProc<T>): TElementDef<T>;
begin
  Result := TElementDef<T>.Create(AConfigProc);
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

{ TFMXERFrameHelper }

function TFMXERFrameHelper.SetPadding(const APadding: Single): TControl;
begin
  Result := Self;
  Result.Padding.Rect := RectF(APadding, APadding, APadding, APadding);
end;

function TFMXERFrameHelper.SetMargin(const AMargin: Single): TControl;
begin
  Result := Self;
  Result.Margins.Rect := RectF(AMargin, AMargin, AMargin, AMargin);
end;

function TFMXERFrameHelper.SetAlignBottom: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Bottom;
end;

function TFMXERFrameHelper.SetAlignClient: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Client;
end;

function TFMXERFrameHelper.SetAlignContents: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Contents;
end;

function TFMXERFrameHelper.SetAlignLeft: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Left;
end;

function TFMXERFrameHelper.SetAlignRight: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Right;
end;

function TFMXERFrameHelper.SetAlignTop: TControl;
begin
  Result := Self;
  Result.Align := TAlignLayout.Top;
end;

function TFMXERFrameHelper.SetHeight(const AHeight: Single): TControl;
begin
  Result := Self;
  Result.Height := AHeight;
end;

function TFMXERFrameHelper.SetHitTest(const AHitTest: Boolean): TControl;
begin
  Result := Self;
  Result.HitTest := AHitTest;
end;

function TFMXERFrameHelper.SetMargin(const ALeft, ATop, ARight,
  ABottom: Single): TControl;
begin
  Result := Self;
  Result.Margins.Rect := RectF(ALeft, ATop, ARight, ABottom);
end;

function TFMXERFrameHelper.SetMargin<T>(const ALeft, ATop, ARight,
  ABottom: Single): T;
begin
  Result := SetMargin(ALeft, ATop, ARight, ABottom) as T;
end;

function TFMXERFrameHelper.SetMarginB(const AMarginBottom: Single): TControl;
begin
  Result := Self;
  Result.Margins.Bottom := AMarginBottom;
end;

function TFMXERFrameHelper.SetMargin<T>(const AMargin: Single): T;
begin
  Result := SetMargin(AMargin) as T;
end;

function TFMXERFrameHelper.SetMarginLR(const AMargin: Single): TControl;
begin
  Result := Self;
  Result.Margins.Left := AMargin;
  Result.Margins.Right := AMargin;
end;

function TFMXERFrameHelper.SetMarginT(const AMarginTop: Single): TControl;
begin
  Result := Self;
  Result.Margins.Top := AMarginTop;
end;

function TFMXERFrameHelper.SetMarginTB(const AMargin: Single): TControl;
begin
  Result := Self;
  Result.Margins.Top := AMargin;
  Result.Margins.Bottom := AMargin;
end;

function TFMXERFrameHelper.SetPadding(const ALeft, ATop, ARight,
  ABottom: Single): TControl;
begin
  Result := Self;
  Result.Padding.Rect := RectF(ALeft, ATop, ARight, ABottom);
end;

function TFMXERFrameHelper.SetPadding<T>(const ALeft, ATop, ARight,
  ABottom: Single): T;
begin
  Result := SetPadding(ALeft, ATop, ARight, ABottom) as T;
end;

function TFMXERFrameHelper.SetPadding<T>(const APadding: Single): T;
begin
  Result := SetPadding(APadding) as T;
end;

function TFMXERFrameHelper.SetPaddingLR(const APadding: Single): TControl;
begin
  Result := Self;
  Result.Padding.Left := APadding;
  Result.Padding.Right := APadding;
end;

function TFMXERFrameHelper.SetPaddingTB(const APadding: Single): TControl;
begin
  Result := Self;
  Result.Padding.Top := APadding;
  Result.Padding.Bottom := APadding;
end;

function TFMXERFrameHelper.SetWidth(const AWidth: Single): TControl;
begin
  Result := Self;
  Result.Width := AWidth;
end;

{ TFMXERFormHelper }

function TFMXERFormHelper.SetHeight(const AHeight: Integer): TCommonCustomForm;
begin
  Result := Self;
  Height := AHeight;
end;

function TFMXERFormHelper.SetPadding(const APadding: Single): TCommonCustomForm;
begin
  Result := Self;
  Result.Padding.Rect := RectF(APadding, APadding, APadding, APadding);
end;

function TFMXERFormHelper.SetPadding<T>(const APadding: Single): T;
begin
  Result := SetPadding(APadding) as T;
end;

function TFMXERFormHelper.SetWidth(const AWidth: Integer): TCommonCustomForm;
begin
  Result := Self;
  Width := AWidth;
end;

end.
