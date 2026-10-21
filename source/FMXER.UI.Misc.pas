unit FMXER.UI.Misc;

interface

uses
  Classes, SysUtils, System.Rtti, FMX.Forms, FMX.Layouts, Types, FMX.Types,
  FMX.Controls, Generics.Collections,
  SubjectStand, FrameStand, FormStand, FMXER.Observable;

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
    function SetPadding<T: TCommonCustomForm>(const APadding: Single): T; overload;
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

    /// <summary>One-way binding: the control is visible when AObservable is
    /// True. Removed with the control; a second BindVisible replaces the first.</summary>
    function BindVisible(const AObservable: TObservable<Boolean>): TControl;
    /// <summary>One-way binding: the control is enabled when AObservable is
    /// True (TButtonFrame has its own BindEnabled, on its action).</summary>
    function BindEnabled(const AObservable: TObservable<Boolean>): TControl;
  end;

  TCaptionPosition = (Left, Right, Top, Bottom);

  /// <summary>Helpers for the containers.</summary>
  TFMXERStands = record
    /// <summary>Like TFrameStand.New, but the frame is aligned with AAlign
    /// before it enters the stand, so it keeps its design size (with Align =
    /// Client it would take the size of the stand). The caller sizes the slot
    /// on the frame (after the configuration procedure) and shows it.</summary>
    class function NewSizedFrame<T: TFrame>(const AFrameStand: TFrameStand;
      const AParent: TFmxObject; const AStandName: string;
      const AAlign: TAlignLayout): TFrameInfo<T>; static;
  end;

  /// <summary>The slots of the columns and rows (TColumnForm, TColumnFrame,
  /// TRowForm, TRowFrame): one implementation for the four of them.</summary>
  TFMXERSlots = record
  public
    /// <summary>ASize value: the slot takes the element's own size.</summary>
    const AUTO_SIZE = -1;
  private
    class function NewSlot(const AContent: TControl; const AOwner: TComponent;
      const AVertical: Boolean; const ASlotAlign: TAlignLayout;
      const ASize: Integer): TSubjectInfoContainer; static;
    class procedure SetSlotSize(const ASlot: TSubjectInfoContainer;
      const AVertical: Boolean; const ASize: Single); static;
  public
    /// <summary>Adds a slot to AContent (after the others: at the bottom of a
    /// column, AVertical = True; at the end of a row, AVertical = False),
    /// creates a T in it through AFrameStand, configures it with AConfigProc,
    /// sizes the slot (ASize, or the element's own size with AUTO_SIZE), shows
    /// the element and adds the slot to AElements. Returns the slot size, by
    /// which the container grows.</summary>
    class function AddFrame<T: TFrame>(const AFrameStand: TFrameStand;
      const AContent: TControl; const AOwner: TComponent;
      const AElements: TList<TSubjectInfoContainer>; const AStandName: string;
      const AVertical: Boolean; const ASlotAlign: TAlignLayout;
      const ASize: Integer; const AConfigProc: TProc<T>): Single; static;
    /// <summary>The same for a form element; with AUTO_SIZE the slot takes the
    /// form's Height (Width) after AConfigProc.</summary>
    class function AddForm<T: TForm>(const AFormStand: TFormStand;
      const AContent: TControl; const AOwner: TComponent;
      const AElements: TList<TSubjectInfoContainer>; const AStandName: string;
      const AVertical: Boolean; const ASlotAlign: TAlignLayout;
      const ASize: Integer; const AConfigProc: TProc<T>): Single; static;
  end;

  // shortcut function
  function Param(const AName: string; const AValue: TValue): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TProc): TNameValueParam; overload;
  function Param(const AName: string; const AValue: TFunc<Boolean>): TNameValueParam; overload;
  function OnClickProc(const AValue: TProc): TNameValueParam; overload;

  /// <summary>AFileName in LocalFilesPath (the media of the demos, by default).</summary>
  function LocalFile(const AFileName: string): string;

var
  /// <summary>Folder used by LocalFile. Default: ..\..\..\..\media\ on Windows
  /// (the media folder of the repository, seen from demos\<Demo>\<Platform>\<Config>),
  /// the documents folder elsewhere. Set it to use LocalFile in your own app.</summary>
  LocalFilesPath: string;


implementation

uses IOUtils;

function LocalFile(const AFileName: string): string;
begin
  Result := TPath.Combine(LocalFilesPath, AFileName);
end;

{ TFMXERStands }

class function TFMXERStands.NewSizedFrame<T>(const AFrameStand: TFrameStand;
  const AParent: TFmxObject; const AStandName: string;
  const AAlign: TAlignLayout): TFrameInfo<T>;
var
  LFrame: T;
begin
  LFrame := T.Create(nil);
  try
    LFrame.Name := '';
    LFrame.Align := AAlign;
    Result := AFrameStand.Use<T>(LFrame, AParent, AStandName);
    Result.FrameIsOwned := True;
  except
    LFrame.Free;
    raise;
  end;
end;

{ TFMXERSlots }

class function TFMXERSlots.NewSlot(const AContent: TControl; const AOwner: TComponent;
  const AVertical: Boolean; const ASlotAlign: TAlignLayout;
  const ASize: Integer): TSubjectInfoContainer;
begin
  Result := TSubjectInfoContainer.Create(AOwner);
  try
    // placed after the existing slots, then aligned
    if AVertical then
      Result.Position.Y := 10000
    else
      Result.Position.X := MaxInt;
    Result.Parent := AContent;
    if ASize >= 0 then
      SetSlotSize(Result, AVertical, ASize);
    Result.Align := ASlotAlign;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TFMXERSlots.SetSlotSize(const ASlot: TSubjectInfoContainer;
  const AVertical: Boolean; const ASize: Single);
begin
  if AVertical then
    ASlot.Height := ASize
  else
    ASlot.Width := ASize;
end;

class function TFMXERSlots.AddFrame<T>(const AFrameStand: TFrameStand;
  const AContent: TControl; const AOwner: TComponent;
  const AElements: TList<TSubjectInfoContainer>; const AStandName: string;
  const AVertical: Boolean; const ASlotAlign: TAlignLayout;
  const ASize: Integer; const AConfigProc: TProc<T>): Single;
var
  LSlot: TSubjectInfoContainer;
  LElement: TFrameInfo<T>;
  LFrame: TFrame;
begin
  LSlot := NewSlot(AContent, AOwner, AVertical, ASlotAlign, ASize);
  try
    if ASize = AUTO_SIZE then
    begin
      // aligned before entering the stand: the frame keeps its size
      if AVertical then
        LElement := TFMXERStands.NewSizedFrame<T>(AFrameStand, LSlot, AStandName, TAlignLayout.Top)
      else
        LElement := TFMXERStands.NewSizedFrame<T>(AFrameStand, LSlot, AStandName, TAlignLayout.Left);
    end
    else
      LElement := AFrameStand.New<T>(LSlot, AStandName);
    LSlot.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(LElement.Frame);

    Result := ASize;
    if ASize = AUTO_SIZE then
    begin
      LFrame := LElement.Frame;
      if AVertical then
        Result := LFrame.Height + LFrame.Margins.Top + LFrame.Margins.Bottom
      else
        Result := LFrame.Width + LFrame.Margins.Left + LFrame.Margins.Right;
      SetSlotSize(LSlot, AVertical, Result);
    end;

    LElement.Show;
    AElements.Add(LSlot);
  except
    LSlot.Free;
    raise;
  end;
end;

class function TFMXERSlots.AddForm<T>(const AFormStand: TFormStand;
  const AContent: TControl; const AOwner: TComponent;
  const AElements: TList<TSubjectInfoContainer>; const AStandName: string;
  const AVertical: Boolean; const ASlotAlign: TAlignLayout;
  const ASize: Integer; const AConfigProc: TProc<T>): Single;
var
  LSlot: TSubjectInfoContainer;
  LElement: TFormInfo<T>;
begin
  LSlot := NewSlot(AContent, AOwner, AVertical, ASlotAlign, ASize);
  try
    LElement := AFormStand.New<T>(LSlot, AStandName);
    LSlot.SubjectInfo := LElement;
    if Assigned(AConfigProc) then
      AConfigProc(LElement.Form);

    Result := ASize;
    if ASize = AUTO_SIZE then
    begin
      if AVertical then
        Result := LElement.Form.Height
      else
        Result := LElement.Form.Width;
      SetSlotSize(LSlot, AVertical, Result);
    end;

    LElement.Show;
    AElements.Add(LSlot);
  except
    LSlot.Free;
    raise;
  end;
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

// the link of a helper binding: a component owned by the control, found by name
function BooleanLink(const AControl: TControl; const AName: string): TObservableLink<Boolean>;
var
  LComponent: TComponent;
begin
  LComponent := AControl.FindComponent(AName);
  if LComponent is TObservableLink<Boolean> then
    Exit(TObservableLink<Boolean>(LComponent));
  Result := TObservableLink<Boolean>.Create(AControl);
  Result.Name := AName;
end;

function TFMXERFrameHelper.BindVisible(const AObservable: TObservable<Boolean>): TControl;
var
  LControl: TControl;
begin
  Result := Self;
  LControl := Self;
  BooleanLink(Self, 'FMXERBindVisible').Bind(AObservable,
    procedure (AValue: Boolean)
    begin
      LControl.Visible := AValue;
    end);
end;

function TFMXERFrameHelper.BindEnabled(const AObservable: TObservable<Boolean>): TControl;
var
  LControl: TControl;
begin
  Result := Self;
  LControl := Self;
  BooleanLink(Self, 'FMXERBindEnabled').Bind(AObservable,
    procedure (AValue: Boolean)
    begin
      LControl.Enabled := AValue;
    end);
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

initialization
  {$IFDEF MSWINDOWS}
  LocalFilesPath := '..\..\..\..\media\';
  {$ELSE}
  LocalFilesPath := TPath.GetDocumentsPath;
  {$ENDIF}

end.
