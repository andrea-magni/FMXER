# FMXER.UI.Misc

Unit `FMXER.UI.Misc`: element definitions, parameters, fluent helpers for controls and forms, the slot layout of columns and rows, and a file helper. The tap handler type shared by the image elements is in `FMXER.UI.Types` (see [Images & Media](/elements/images-and-media#tap-handlers)).

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
| `TColumnForm.AddFrame<T>(TElementDef<T>)`, `AddForm<T>(...)` | `Height` (Integer, default 200; `TColumnForm.AUTO_HEIGHT` for the element's own height) |
| `TRowForm.AddFrame<T>(TElementDef<T>)`, `AddForm<T>(...)` | `Width` (Integer, default 200; `TRowForm.AUTO_WIDTH` for the element's own width) |
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

## TFMXERStands

```pascal
TFMXERStands = record
  class function NewSizedFrame<T: TFrame>(const AFrameStand: TFrameStand;
    const AParent: TFmxObject; const AStandName: string;
    const AAlign: TAlignLayout): TFrameInfo<T>; static;
end;
```

Like `TFrameStand.New<T>`, but the frame is aligned with `AAlign` (`Top`, `Left`...) **before** it enters the stand, so it keeps its design size: with its usual `Align = Client` it would take the size of the stand at once. The frame is not shown: configure it, size its slot on it, then call `Show` on the returned info. Columns, rows and scroll boxes use it for [automatic sizes](/guide/layouts#automatic-sizes); use it in your own containers to do the same.

## TFMXERSlots

```pascal
TFMXERSlots = record
  const AUTO_SIZE = -1;
  class function AddFrame<T: TFrame>(const AFrameStand: TFrameStand; const AContent: TControl;
    const AOwner: TComponent; const AElements: TList<TSubjectInfoContainer>; const AStandName: string;
    const AVertical: Boolean; const ASlotAlign: TAlignLayout; const ASize: Integer;
    const AConfigProc: TProc<T>): Single; static;
  class function AddForm<T: TForm>(...same parameters, a TFormStand...): Single; static;
end;
```

The one implementation of the slots of `TColumnForm`, `TColumnFrame`, `TRowForm` and `TRowFrame` (since v.1.4): it adds a `TSubjectInfoContainer` to `AContent` after the existing ones (`AVertical`: at the bottom; otherwise at the end of the row), creates the element in it through the stand, runs `AConfigProc`, sizes the slot (`ASize`, or the element's own size with `AUTO_SIZE`), shows the element and adds the slot to `AElements`. It returns the slot size, by which the container grows. Use it to write your own column-like container.

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
var LocalFilesPath: string;
function LocalFile(const AFileName: string): string;
```

`LocalFile` returns `TPath.Combine(LocalFilesPath, AFileName)`. `LocalFilesPath` is, by default, the media folder of the repository seen from a demo executable on Windows (`..\..\..\..\media\`, from `demos\<Demo>\<Platform>\<Config>`) and `TPath.GetDocumentsPath` on the other platforms. Set it at startup to use `LocalFile` with your own folder (since v.1.2.1).
