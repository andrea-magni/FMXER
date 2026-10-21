unit FMXER.Modals;

// Dialogs and bottom sheets over the screen (Flutter showDialog, AlertDialog,
// showModalBottomSheet), shown with TFrameStand ShowModal on the 'dialog' and
// 'bottomsheet' stands of the TFrameStand stand gallery (Stands.Light.style of
// TFrameStand v.2.4, embedded below).

interface

uses
  System.SysUtils, System.Classes, System.UITypes, Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms
, SubjectStand, FrameStand;

type
  TModals = class
  private
    class var FInstance: TModals;
  private
    FStands: TStyleBook;
    FFrameStand: TFrameStand;
    FOpen: TList<TSubjectInfo>;
    FParent: TFmxObject;
    FBackHandler: TFunc<Boolean>;
    FBackHandlerAdded: Boolean;
    function DefaultParent: TFmxObject;
    procedure Opened(const AInfo: TSubjectInfo);
    procedure Closed(const AInfo: TSubjectInfo);
    procedure UpdateBackHandler;
    class function GetInstance: TModals; static;
  protected
    /// <summary>Sizes the element AName of the stand ('card', 'sheet'); 0 keeps
    /// the size of the stand.</summary>
    procedure SizeStandElement(const AInfo: TSubjectInfo; const AName: string;
      const AWidth, AHeight: Single);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>Shows a T in a card in the middle of the screen, over a dimmed
    /// background (the 'dialog' stand, 320 x 240 by default). The frame sets
    /// the ModalResult of its info (a [SubjectInfo] field) to close it; a tap on
    /// the background, Back and Esc close it with mrCancel. AResultProc is
    /// called once, after the hide animation, before the frame is freed.</summary>
    function ShowDialog<T: TFrame>(const AConfigProc: TProc<T> = nil;
      const AResultProc: TProc<T, TModalResult> = nil;
      const AWidth: Single = 0; const AHeight: Single = 0): TFrameInfo<T>;
    /// <summary>Shows a T in a sheet that slides up from the bottom (the
    /// 'bottomsheet' stand, 360 high by default), the same way.</summary>
    function ShowBottomSheet<T: TFrame>(const AConfigProc: TProc<T> = nil;
      const AResultProc: TProc<T, TModalResult> = nil;
      const AHeight: Single = 0): TFrameInfo<T>;

    /// <summary>A message with an OK button (Flutter AlertDialog).</summary>
    procedure Alert(const ATitle, AMessage: string; const AThen: TProc = nil;
      const AOkText: string = 'OK');
    /// <summary>A question with OK and Cancel: AResultProc gets True for OK,
    /// False for Cancel, a tap outside, Back or Esc.</summary>
    procedure Confirm(const ATitle, AMessage: string; const AResultProc: TProc<Boolean>;
      const AOkText: string = 'OK'; const ACancelText: string = 'Cancel');
    /// <summary>A list of choices in a bottom sheet: AResultProc gets the index
    /// of the choice tapped, -1 when the sheet is dismissed.</summary>
    procedure Choose(const ATitle: string; const AChoices: TArray<string>;
      const AResultProc: TProc<Integer>);

    /// <summary>Closes the dialog or sheet on top with mrCancel; False when
    /// none is open.</summary>
    function CancelTop: Boolean;
    function GetOpenCount: Integer;
    /// <summary>Where the dialogs are shown. Default: the safe area layout of
    /// the navigator (or the form of its FormStand), else the main form.</summary>
    function SetParent(const AParent: TFmxObject): TModals;

    property FrameStand: TFrameStand read FFrameStand;
    property Stands: TStyleBook read FStands;
    class property Instance: TModals read GetInstance;
    /// <summary>Frees the singleton (the dialogs still open are freed with it).</summary>
    class procedure ReleaseInstance;
  end;

/// <summary>The singleton, created on first use.</summary>
function Modals: TModals;

implementation

uses
  FMX.Styles, FMXER.Navigator, FMXER.AlertFrame, FMXER.ChoicesFrame;

const
  CONTAINER_MARGINS = 16; // the 'container' of the card and of the sheet
  SHEET_HANDLE = 20;      // the 'handle_area' of the sheet
  MAX_SHEET_RATIO = 0.7;  // a sheet sized on its content: at most 70% of the screen

  GALLERY_STANDS =
    'object TStyleContainer' + sLineBreak +
    '  object TLayout' + sLineBreak +
    '    StyleName = ''dialog''' + sLineBreak +
    '    Align = Contents' + sLineBreak +
    '    Size.Width = 360.000000000000000000' + sLineBreak +
    '    Size.Height = 640.000000000000000000' + sLineBreak +
    '    Size.PlatformDefault = False' + sLineBreak +
    '    object TRectangle' + sLineBreak +
    '      StyleName = ''background_cancel''' + sLineBreak +
    '      Align = Contents' + sLineBreak +
    '      Fill.Color = x66000000' + sLineBreak +
    '      Stroke.Kind = None' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnShowScrim''' + sLineBreak +
    '        AnimationType = Out' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartValue = 0.000000000000000000' + sLineBreak +
    '        StopValue = 1.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnHideScrim''' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartFromCurrent = True' + sLineBreak +
    '        StopValue = 0.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '    end' + sLineBreak +
    '    object TRectangle' + sLineBreak +
    '      StyleName = ''card''' + sLineBreak +
    '      Align = Center' + sLineBreak +
    '      Fill.Color = xFFFFFFFF' + sLineBreak +
    '      Stroke.Kind = None' + sLineBreak +
    '      XRadius = 12.000000000000000000' + sLineBreak +
    '      YRadius = 12.000000000000000000' + sLineBreak +
    '      Size.Width = 320.000000000000000000' + sLineBreak +
    '      Size.Height = 240.000000000000000000' + sLineBreak +
    '      Size.PlatformDefault = False' + sLineBreak +
    '      object TLayout' + sLineBreak +
    '        StyleName = ''container''' + sLineBreak +
    '        Align = Client' + sLineBreak +
    '        Margins.Left = 16.000000000000000000' + sLineBreak +
    '        Margins.Top = 16.000000000000000000' + sLineBreak +
    '        Margins.Right = 16.000000000000000000' + sLineBreak +
    '        Margins.Bottom = 16.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TShadowEffect' + sLineBreak +
    '        Distance = 3.000000000000000000' + sLineBreak +
    '        Direction = 90.000000000000000000' + sLineBreak +
    '        Softness = 0.400000000000000000' + sLineBreak +
    '        Opacity = 0.300000000000000000' + sLineBreak +
    '        ShadowColor = claBlack' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnShowFade''' + sLineBreak +
    '        AnimationType = Out' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartValue = 0.000000000000000000' + sLineBreak +
    '        StopValue = 1.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnShowLift''' + sLineBreak +
    '        AnimationType = Out' + sLineBreak +
    '        Duration = 0.250000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Margins.Top''' + sLineBreak +
    '        StartValue = 48.000000000000000000' + sLineBreak +
    '        StopValue = 0.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnHideFade''' + sLineBreak +
    '        Duration = 0.150000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartFromCurrent = True' + sLineBreak +
    '        StopValue = 0.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '    end' + sLineBreak +
    '  end' + sLineBreak +
    '  object TLayout' + sLineBreak +
    '    StyleName = ''bottomsheet''' + sLineBreak +
    '    Align = Contents' + sLineBreak +
    '    Size.Width = 360.000000000000000000' + sLineBreak +
    '    Size.Height = 640.000000000000000000' + sLineBreak +
    '    Size.PlatformDefault = False' + sLineBreak +
    '    object TRectangle' + sLineBreak +
    '      StyleName = ''background_cancel''' + sLineBreak +
    '      Align = Contents' + sLineBreak +
    '      Fill.Color = x66000000' + sLineBreak +
    '      Stroke.Kind = None' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnShowScrim''' + sLineBreak +
    '        AnimationType = Out' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartValue = 0.000000000000000000' + sLineBreak +
    '        StopValue = 1.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnHideScrim''' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Opacity''' + sLineBreak +
    '        StartFromCurrent = True' + sLineBreak +
    '        StopValue = 0.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '    end' + sLineBreak +
    '    object TRectangle' + sLineBreak +
    '      StyleName = ''sheet''' + sLineBreak +
    '      Align = Bottom' + sLineBreak +
    '      Fill.Color = xFFFFFFFF' + sLineBreak +
    '      Stroke.Kind = None' + sLineBreak +
    '      Corners = [TopLeft, TopRight]' + sLineBreak +
    '      XRadius = 16.000000000000000000' + sLineBreak +
    '      YRadius = 16.000000000000000000' + sLineBreak +
    '      Size.Height = 360.000000000000000000' + sLineBreak +
    '      Size.PlatformDefault = False' + sLineBreak +
    '      object TLayout' + sLineBreak +
    '        StyleName = ''handle_area''' + sLineBreak +
    '        Align = Top' + sLineBreak +
    '        Size.Height = 20.000000000000000000' + sLineBreak +
    '        Size.PlatformDefault = False' + sLineBreak +
    '        object TRectangle' + sLineBreak +
    '          StyleName = ''handle''' + sLineBreak +
    '          Align = Center' + sLineBreak +
    '          Fill.Color = xFFBDBDBD' + sLineBreak +
    '          Stroke.Kind = None' + sLineBreak +
    '          XRadius = 2.000000000000000000' + sLineBreak +
    '          YRadius = 2.000000000000000000' + sLineBreak +
    '          Size.Width = 40.000000000000000000' + sLineBreak +
    '          Size.Height = 4.000000000000000000' + sLineBreak +
    '          Size.PlatformDefault = False' + sLineBreak +
    '        end' + sLineBreak +
    '      end' + sLineBreak +
    '      object TLayout' + sLineBreak +
    '        StyleName = ''container''' + sLineBreak +
    '        Align = Client' + sLineBreak +
    '        Margins.Left = 16.000000000000000000' + sLineBreak +
    '        Margins.Right = 16.000000000000000000' + sLineBreak +
    '        Margins.Bottom = 16.000000000000000000' + sLineBreak +
    '      end' + sLineBreak +
    '      object TShadowEffect' + sLineBreak +
    '        Distance = 3.000000000000000000' + sLineBreak +
    '        Direction = 90.000000000000000000' + sLineBreak +
    '        Softness = 0.400000000000000000' + sLineBreak +
    '        Opacity = 0.300000000000000000' + sLineBreak +
    '        ShadowColor = claBlack' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnShowSlide''' + sLineBreak +
    '        AnimationType = Out' + sLineBreak +
    '        Duration = 0.250000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Margins.Bottom''' + sLineBreak +
    '        StopValue = 0.000000000000000000' + sLineBreak +
    '        object TStyleTag' + sLineBreak +
    '          TagString = ''StartValue=-ParentHeight''' + sLineBreak +
    '        end' + sLineBreak +
    '      end' + sLineBreak +
    '      object TFloatAnimation' + sLineBreak +
    '        StyleName = ''OnHideSlide''' + sLineBreak +
    '        Duration = 0.200000000000000000' + sLineBreak +
    '        Interpolation = Quadratic' + sLineBreak +
    '        PropertyName = ''Margins.Bottom''' + sLineBreak +
    '        StartFromCurrent = True' + sLineBreak +
    '        object TStyleTag' + sLineBreak +
    '          TagString = ''StopValue=-ParentHeight''' + sLineBreak +
    '        end' + sLineBreak +
    '      end' + sLineBreak +
    '    end' + sLineBreak +
    '  end' + sLineBreak +
    'end';

function Modals: TModals;
begin
  Result := TModals.Instance;
end;

{ TModals }

procedure TModals.Alert(const ATitle, AMessage: string; const AThen: TProc;
  const AOkText: string);
var
  LInfo: TFrameInfo<TAlertFrame>;
begin
  LInfo := ShowDialog<TAlertFrame>(
    procedure (AFrame: TAlertFrame)
    begin
      AFrame
      .SetTitle(ATitle)
      .SetMessage(AMessage)
      .SetOkText(AOkText)
      .SetCancelText('');
    end
  , procedure (AFrame: TAlertFrame; AResult: TModalResult)
    begin
      if Assigned(AThen) then
        AThen();
    end
  );
  SizeStandElement(LInfo, 'card', 0, LInfo.Frame.GetPreferredHeight + 2 * CONTAINER_MARGINS);
end;

function TModals.CancelTop: Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  for LIndex := FOpen.Count - 1 downto 0 do
    if not FOpen[LIndex].Hiding then
    begin
      FOpen[LIndex].ModalResult := mrCancel;
      Exit(True);
    end;
end;

procedure TModals.Choose(const ATitle: string; const AChoices: TArray<string>;
  const AResultProc: TProc<Integer>);
var
  LInfo: TFrameInfo<TChoicesFrame>;
  LHeight, LMax: Single;
begin
  LInfo := ShowBottomSheet<TChoicesFrame>(
    procedure (AFrame: TChoicesFrame)
    begin
      AFrame.SetTitle(ATitle).SetChoices(AChoices);
    end
  , procedure (AFrame: TChoicesFrame; AResult: TModalResult)
    begin
      if Assigned(AResultProc) then
      begin
        if AResult = mrOk then
          AResultProc(AFrame.Chosen)
        else
          AResultProc(-1);
      end;
    end
  );
  LHeight := LInfo.Frame.GetPreferredHeight + SHEET_HANDLE + CONTAINER_MARGINS;
  if LInfo.Stand.ParentControl <> nil then
  begin
    LMax := LInfo.Stand.ParentControl.Height * MAX_SHEET_RATIO;
    if (LMax > 0) and (LHeight > LMax) then
      LHeight := LMax;   // the items scroll
  end;
  SizeStandElement(LInfo, 'sheet', 0, LHeight);
end;

procedure TModals.Closed(const AInfo: TSubjectInfo);
begin
  FOpen.Remove(AInfo);
  UpdateBackHandler;
end;

procedure TModals.Confirm(const ATitle, AMessage: string;
  const AResultProc: TProc<Boolean>; const AOkText, ACancelText: string);
var
  LInfo: TFrameInfo<TAlertFrame>;
begin
  LInfo := ShowDialog<TAlertFrame>(
    procedure (AFrame: TAlertFrame)
    begin
      AFrame
      .SetTitle(ATitle)
      .SetMessage(AMessage)
      .SetOkText(AOkText)
      .SetCancelText(ACancelText);
    end
  , procedure (AFrame: TAlertFrame; AResult: TModalResult)
    begin
      if Assigned(AResultProc) then
        AResultProc(AResult = mrOk);
    end
  );
  SizeStandElement(LInfo, 'card', 0, LInfo.Frame.GetPreferredHeight + 2 * CONTAINER_MARGINS);
end;

constructor TModals.Create;
var
  LText: string;
  LStream: TStringStream;
begin
  inherited Create;
  FOpen := TList<TSubjectInfo>.Create;

  FStands := TStyleBook.Create(nil);
  LText := GALLERY_STANDS;
  LStream := TStringStream.Create(LText, TEncoding.UTF8);
  try
    FStands.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;

  FFrameStand := TFrameStand.Create(nil);
  FFrameStand.StandBook := FStands;
  // the dimmed background of the stands ('background_cancel') cancels
  FFrameStand.CommonActions.Add('*_cancel',
    procedure (AInfo: TSubjectInfo)
    begin
      AInfo.ModalResult := mrCancel;
    end);

  // Back/Esc close the dialog on top before the navigator closes a route
  FBackHandler :=
    function: Boolean
    begin
      Result := CancelTop;
    end;
end;

function TModals.DefaultParent: TFmxObject;
begin
  Result := FParent;
  if Assigned(Result) then
    Exit;
  if TNavigator.Initialized then
  begin
    Result := Navigator.SafeAreaLayout;
    if not Assigned(Result) and (Navigator.FormStand.Owner is TFmxObject) then
      Result := TFmxObject(Navigator.FormStand.Owner);
  end;
  if not Assigned(Result) then
    Result := Application.MainForm;
  if not Assigned(Result) then
    raise Exception.Create('No parent for the dialog: call Modals.SetParent');
end;

destructor TModals.Destroy;
begin
  if FBackHandlerAdded and TNavigator.Initialized then
    Navigator.RemoveBackHandler(FBackHandler);
  FreeAndNil(FFrameStand);
  FreeAndNil(FStands);
  FreeAndNil(FOpen);
  inherited;
end;

class function TModals.GetInstance: TModals;
begin
  if not Assigned(FInstance) then
    FInstance := TModals.Create;
  Result := FInstance;
end;

function TModals.GetOpenCount: Integer;
begin
  Result := FOpen.Count;
end;

procedure TModals.Opened(const AInfo: TSubjectInfo);
begin
  FOpen.Add(AInfo);
  UpdateBackHandler;
end;

class procedure TModals.ReleaseInstance;
begin
  FreeAndNil(FInstance);
end;

function TModals.SetParent(const AParent: TFmxObject): TModals;
begin
  Result := Self;
  FParent := AParent;
end;

function TModals.ShowBottomSheet<T>(const AConfigProc: TProc<T>;
  const AResultProc: TProc<T, TModalResult>; const AHeight: Single): TFrameInfo<T>;
var
  LInfo: TFrameInfo<T>;
  LResultProc: TProc<T, TModalResult>;
begin
  LInfo := FFrameStand.New<T>(DefaultParent, 'bottomsheet');
  SizeStandElement(LInfo, 'sheet', 0, AHeight);
  if Assigned(AConfigProc) then
    AConfigProc(LInfo.Frame);
  Opened(LInfo);
  // a variable: an inline anonymous method does not match the overloads
  LResultProc :=
    procedure (AFrame: T; AResult: TModalResult)
    begin
      Closed(LInfo);
      if Assigned(AResultProc) then
        AResultProc(AFrame, AResult);
    end;
  LInfo.ShowModal(LResultProc);
  Result := LInfo;
end;

function TModals.ShowDialog<T>(const AConfigProc: TProc<T>;
  const AResultProc: TProc<T, TModalResult>; const AWidth, AHeight: Single): TFrameInfo<T>;
var
  LInfo: TFrameInfo<T>;
  LResultProc: TProc<T, TModalResult>;
begin
  LInfo := FFrameStand.New<T>(DefaultParent, 'dialog');
  SizeStandElement(LInfo, 'card', AWidth, AHeight);
  if Assigned(AConfigProc) then
    AConfigProc(LInfo.Frame);
  Opened(LInfo);
  // a variable: an inline anonymous method does not match the overloads
  LResultProc :=
    procedure (AFrame: T; AResult: TModalResult)
    begin
      Closed(LInfo);
      if Assigned(AResultProc) then
        AResultProc(AFrame, AResult);
    end;
  LInfo.ShowModal(LResultProc);
  Result := LInfo;
end;

procedure TModals.SizeStandElement(const AInfo: TSubjectInfo; const AName: string;
  const AWidth, AHeight: Single);
var
  LElement: TFmxObject;
begin
  if not Assigned(AInfo.Stand) then
    Exit;
  LElement := AInfo.Stand.FindStyleResource(AName);
  if not (LElement is TControl) then
    Exit;
  if AWidth > 0 then
    TControl(LElement).Width := AWidth;
  if AHeight > 0 then
    TControl(LElement).Height := AHeight;
end;

procedure TModals.UpdateBackHandler;
var
  LAdd: Boolean;
begin
  LAdd := FOpen.Count > 0;
  if (LAdd = FBackHandlerAdded) or not TNavigator.Initialized then
    Exit;
  if LAdd then
    Navigator.AddBackHandler(FBackHandler)
  else
    Navigator.RemoveBackHandler(FBackHandler);
  FBackHandlerAdded := LAdd;
end;

initialization

finalization
  TModals.ReleaseInstance;

end.
