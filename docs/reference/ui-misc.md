# FMXER.UI.Misc

Unit `FMXER.UI.Misc`: element definitions, parameters, fluent helpers for controls and forms, the slot layout of columns and rows, and a file helper for the demos.

## TElementDef

A configuration procedure plus named parameters, as one value.

```pascal
TElementDef<T> = record
  Params: TArray<TNameValueParam>;
  ConfigProc: TProc<T>;
  constructor Create(const AConfigProc: TProc<T>; const AParams: TParams = []);
  function FindParam(const AName: string; out AParam: TNameValueParam): Boolean;
  function ParamByName(const AName: string; const ADefaultValue: TValue): TValue; overload;
  function ParamByName(const AName: string): TValue; overload;
  class operator Implicit(AConfigProc: TProc<T>): TElementDef<T>;
end;
```

Parameter names are case-insensitive. `ParamByName` returns `ADefaultValue` (or `TValue.Empty`) when the parameter is missing.

| Consumer | Parameters |
|---|---|
| `TColumnForm.AddFrame<T>(TElementDef<T>)`, `AddForm<T>(...)` | `Height` (Integer, default 200) |
| `TRowForm.AddFrame<T>(TElementDef<T>)`, `AddForm<T>(...)` | `Width` (Integer, default 200) |
| `TScaffoldForm.AddActionButton(ACaption, AParams)`, `AddActionButtonOverlayFrame<T>(TElementDef<T>)` | `OnClickProc` (`TProc`) |

```pascal
Col.AddFrame<TLogoFrame>(
  TElementDef<TLogoFrame>.Create(
    procedure (Logo: TLogoFrame)
    begin
      Logo.Opacity := 0.5;
    end
  , [ Param('Height', 120) ])
);

var LBack: TProc :=
  procedure
  begin
    Navigator.StackPop;
  end;
Scaffold.AddActionButton('Back', [ OnClickProc(LBack) ]);
```

::: tip Anonymous methods and AddActionButton
With `AddActionButton`, pass a variable to `OnClickProc`, as above: an anonymous method written inline in `[ OnClickProc(...) ]` there does not compile with Delphi 13 (*E2250 There is no overloaded version of 'OnClickProc'*) unless the call is qualified (`FMXER.UI.Misc.OnClickProc(...)`). Elsewhere the inline form works.
:::

## Parameters

| Declaration | Description |
|---|---|
| `TNameValueParam = record Name: string; Value: TValue; end` | a parameter |
| `TParams = TArray<TNameValueParam>` | |
| `Param(AName; AValue: TValue)` | builds a parameter |
| `Param(AName; AValue: TProc)`, `Param(AName; AValue: TFunc<Boolean>)` | the same for anonymous methods (stored with their type) |
| `OnClickProc(AValue: TProc)` | shortcut for `Param('OnClickProc', ...)` |

## Control helpers

`TFMXERFrameHelper = class helper for TControl`: fluent setters for any control, frame element included. Each returns the control (`TControl`); the generic overloads return it as `T`, to keep chaining the element's own setters.

| Method | Sets |
|---|---|
| `SetMargin(AMargin)`, `SetMargin<T>(AMargin)` | all four margins |
| `SetMargin(ALeft, ATop, ARight, ABottom)`, `SetMargin<T>(...)` | margins |
| `SetMarginLR(AMargin)`, `SetMarginTB(AMargin)`, `SetMarginT(ATop)`, `SetMarginB(ABottom)` | some margins |
| `SetPadding(APadding)`, `SetPadding<T>(APadding)` | all four paddings |
| `SetPadding(ALeft, ATop, ARight, ABottom)`, `SetPadding<T>(...)` | paddings |
| `SetPaddingLR(APadding)`, `SetPaddingTB(APadding)` | some paddings |
| `SetAlignClient`, `SetAlignTop`, `SetAlignBottom`, `SetAlignLeft`, `SetAlignRight`, `SetAlignContents` | `Align` |
| `SetHitTest(AHitTest)` | `HitTest` (elements forward it to their inner control) |
| `SetWidth(AWidth)`, `SetHeight(AHeight)` | size |

```pascal
Button.SetMargin<TButtonFrame>(5).SetText('OK');
Text.SetAlignClient.SetMargin(5, 0, 0, 0);
```

::: info One helper per class
Delphi uses only one class helper per class at a time. If your code declares another helper for `TControl`, the one closest in scope hides `TFMXERFrameHelper`.
:::

## Form helpers

`TFMXERFormHelper = class helper for TCommonCustomForm`:

| Method | Sets |
|---|---|
| `SetPadding(APadding): TCommonCustomForm` | the form's padding (moved with the content when the form is shown through a `TFormStand`) |
| `SetWidth(AWidth)`, `SetHeight(AHeight): TCommonCustomForm` | size |
| `SetPadding<T: TCommonCustomForm>(APadding): T` | the same, returning the form as `T` (up to v.1.1 the constraint was `TControl` and it always raised `EInvalidCast`) |

## TSubjectInfoContainer

```pascal
TSubjectInfoContainer = class(TLayout)
  function ContainedFrame<T: TFrame>: T;
  function ContainedForm<T: TForm>: T;
  property SubjectInfo: TSubjectInfo;
end;
```

The slot layout created by `TColumnForm` and `TRowForm` for each element (`Elements` list). `ContainedFrame<T>` / `ContainedForm<T>` return the element, or `nil` when the slot holds the other kind.

## TCaptionPosition

`TCaptionPosition = (Left, Right, Top, Bottom)`, used by `TTrackbarFrame.SetCaptionPosition`.

## LocalFile

```pascal
function LocalFile(const AFileName: string): string;
```

The location of the demo media: `..\..\..\..\media\AFileName` on Windows (relative to `demos\<Demo>\<Platform>\<Config>`), `TPath.GetDocumentsPath + AFileName` on the other platforms. Meant for the demos.
