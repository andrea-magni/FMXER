unit FMXER.ScaffoldForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ImgList, System.Rtti,
  Generics.Collections, System.Actions, FMX.ActnList, FMX.Effects
, System.Skia, FMX.Skia
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.ActionButtonFrame, FMXER.TextFrame, FMXER.GlyphFrame
, FMXER.IconFontsData, Icons.Utils, FMXER.TabsFrame
;

type
  TScaffoldForm = class(TForm)
    TitleLayout: TLayout;
    TitleBackground: TRectangle;
    ContentLayout: TLayout;
    OverlayLayout: TLayout;
    ActionButtonsLayout: TLayout;
    FrameStand1: TFrameStand;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    FormStand1: TFormStand;
    Stands: TStyleBook;
    TitleDetailLayout: TLayout;
    TitleLabel: TSkLabel;
  private
    FContent: TSubjectInfo;
    FTitleDetailContent: TSubjectInfo;
    FContentStand: string;
    FActionButtonStand: string;
    FActionButtons: TList<TFrameInfo<TActionButtonFrame>>;
    FTitle: string;
    FTitleDetailStand: string;
    // drawer
    FDrawer: TSubjectInfo;
    FDrawerLayer: TLayout;
    FDrawerScrim: TRectangle;
    FDrawerPanel: TRectangle;
    FMenuButton: TLayout;
    FDrawerOpen: Boolean;
    FDrawerBackHandler: TFunc<Boolean>;
    FDrawerBackHandlerAdded: Boolean;
    FBottomNavigation: TTabsFrame;
    // delayed actions on the scaffold: cancelled when it is destroyed
    FPendingActions: TList<IDelayedAction>;
    procedure Track(const AAction: IDelayedAction);
    procedure CreateDrawer(const AWidth: Single);
    procedure MenuButtonClick(Sender: TObject);
    procedure DrawerScrimClick(Sender: TObject);
    procedure SetDrawerBackHandler(const AAdd: Boolean);
    function GetContent: TSubject;
    function GetTitleDetailContent: TSubject;
    function GetTitleDetailContentVisible: Boolean;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Content
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;

    // Title detail
    function SetTitleDetailContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
    function SetTitleDetailContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;

    // Action buttons
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc); overload;
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AElementDef: TElementDef<T>); overload;
    procedure AddActionButtonOverlayForm<T: TForm>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc);

    // shortcuts
    function AddActionButton(const ACaption: string; const AParams: TParams): TScaffoldForm; overload;
    function AddActionButton(const ACaption: string; const AOnClickProc: TProc): TScaffoldForm; overload;
    function AddActionButton(const AImageList: TCustomImageList;
      const AImageIndex: Integer; const AOnClickProc: TProc): TScaffoldForm; overload;
    function AddActionButton(const AIcon: TIconEntry; const AColor: TAlphaColor;
      const AOnClickProc: TProc): TScaffoldForm; overload;

    function ShowSnackBar(const AText: string; const ADuration_ms: Integer): TScaffoldForm; overload;
    function ShowSnackBar(const AText: string; const ADuration_ms: Integer;
      const AThen: TProc): TScaffoldForm; overload;

    procedure ShowTitleDetailContent;
    procedure HideTitleDetailContent(const ADelay: Integer = 0; const AThen: TProc = nil);

    function SetTitle(const ATitle: string): TScaffoldForm;

    // Drawer: a panel that slides in from the left over the screen (Flutter
    // Drawer), opened by the menu button that appears on the left of the title
    function SetDrawerAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil;
      const AWidth: Single = 280): TScaffoldForm;
    function SetDrawerAsForm<T: TForm>(const AConfigProc: TProc<T> = nil;
      const AWidth: Single = 280): TScaffoldForm;
    function OpenDrawer: TScaffoldForm;
    function CloseDrawer: TScaffoldForm;
    function GetDrawerOpen: Boolean;

    // Bottom navigation (Flutter NavigationBar): the content is a TTabsFrame
    // with its bar at the bottom; the action buttons move above the bar
    function SetBottomNavigation(const AConfigProc: TProc<TTabsFrame>): TScaffoldForm;

    //
    [Hide]
    procedure HideHandler;
    //
    property ActionButtonStand: string read FActionButtonStand write FActionButtonStand;
    property ContentStand: string read FContentStand write FContentStand;
    property TitleDetailStand: string read FTitleDetailStand write FTitleDetailStand;
    property Content: TSubject read GetContent;
    property TitleDetailContent: TSubject read GetTitleDetailContent;
    property TitleDetailContentVisible: Boolean read GetTitleDetailContentVisible;
    property Drawer: TSubjectInfo read FDrawer;
    property DrawerOpen: Boolean read GetDrawerOpen;
    property DrawerPanel: TRectangle read FDrawerPanel;
    property MenuButton: TLayout read FMenuButton;
    property BottomNavigation: TTabsFrame read FBottomNavigation;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts, FMX.Ani, FMXER.Navigator;

const
  DRAWER_ANIMATION = 0.25; // seconds
  DRAWER_SCRIM_OPACITY = 0.4;
  ACTION_BUTTONS_BOTTOM = 20;


{ TScaffoldForm }

function TScaffoldForm.AddActionButton(const ACaption: string;
  const AParams: TParams): TScaffoldForm;
begin
  Result := Self;
  AddActionButtonOverlayFrame<TTextFrame>(
    TElementDef<TTextFrame>.Create(
      procedure (ATextFrame: TTextFrame)
      begin
        ATextFrame.SetContent(ACaption);
      end
    , AParams
    )
  );
end;

function TScaffoldForm.AddActionButton(const AImageList: TCustomImageList;
  const AImageIndex: Integer; const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := Self;

  AddActionButtonOverlayFrame<TGlyphFrame>(
   procedure (AGlyph: TGlyphFrame)
   begin
     AGlyph
     .SetImages(AImageList)
     .SetImageIndex(AImageIndex);
   end
  , AOnClickProc
  );
end;

function TScaffoldForm.AddActionButton(const ACaption: string;
  const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := AddActionButton(ACaption, [ OnClickProc(AOnClickProc) ]);
end;

function TScaffoldForm.AddActionButton(const AIcon: TIconEntry;
  const AColor: TAlphaColor; const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := AddActionButton(
      IconFonts.ImageList
    , IconFonts.AddIcon(AIcon, AColor)
    , AOnClickProc);
end;

procedure TScaffoldForm.AddActionButtonOverlayForm<T>(
  const AOverlayConfigProc: TProc<T>; const AOnClickProc: TProc);
begin
  FrameStand1.NewAndShow<TActionButtonFrame>(ActionButtonsLayout, ActionButtonStand
  , nil
  , procedure (FI: TFrameInfo<TActionButtonFrame>)
    begin
      FI.Stand.Position.X := MaxInt;
      FI.Stand.Align := TAlignLayout.Right;
      FI.Stand.Margins.Right := 10;

      FI.Frame.OnClickProc := AOnClickProc;
      FI.Frame.SetOverlayAsForm<T>(AOverlayConfigProc);

      FActionButtons.Add(FI);
    end
  );
end;

procedure TScaffoldForm.AddActionButtonOverlayFrame<T>(
  const AElementDef: TElementDef<T>);
var
  LProc: TProc;
  LParam: TNameValueParam;
begin
  LProc := nil;
  if AElementDef.FindParam('OnClickProc', LParam) and not LParam.Value.IsEmpty then
    LProc := LParam.Value.AsType<TProc>();
  AddActionButtonOverlayFrame<T>(AElementDef.ConfigProc, LProc);
end;

procedure TScaffoldForm.AddActionButtonOverlayFrame<T>(
  const AOverlayConfigProc: TProc<T>; const AOnClickProc: TProc);
begin
  FrameStand1.NewAndShow<TActionButtonFrame>(ActionButtonsLayout, ActionButtonStand
  , nil
  , procedure (FI: TFrameInfo<TActionButtonFrame>)
    begin
      FI.Stand.Position.X := MaxInt;
      FI.Stand.Align := TAlignLayout.Right;
      FI.Stand.Margins.Right := 10;

      FI.Frame.OnClickProc := AOnClickProc;
      FI.Frame.SetOverlayAsFrame<T>(AOverlayConfigProc);

      FActionButtons.Add(FI);
    end
  );
end;

constructor TScaffoldForm.Create(AOwner: TComponent);
begin
  inherited;
  FActionButtons := TList<TFrameInfo<TActionButtonFrame>>.Create;
  FPendingActions := TList<IDelayedAction>.Create;

  TitleBackground.Fill.Color := TAppColors.PrimaryColor;
  TitleLabel.TextSettings.FontColor := TAppColors.PrimaryTextColor;

  // Back/Esc closes the open drawer instead of the route
  FDrawerBackHandler :=
    function: Boolean
    begin
      Result := FDrawerOpen;
      if Result then
        CloseDrawer;
    end;
end;

destructor TScaffoldForm.Destroy;
var
  LAction: IDelayedAction;
begin
  // the route was closed before (e.g. a snackbar still visible): nothing runs
  // on the freed scaffold and its subjects
  for LAction in FPendingActions do
    LAction.Cancel;
  FreeAndNil(FPendingActions);
  SetDrawerBackHandler(False);
  FreeAndNil(FActionButtons);
  inherited;
end;

procedure TScaffoldForm.CreateDrawer(const AWidth: Single);
var
  LIndex: Integer;
  LBar: TRectangle;
begin
  if Assigned(FDrawerLayer) then
    raise Exception.Create('The scaffold has a drawer already');

  // the menu button (three lines, drawn: no icon font needed)
  FMenuButton := TLayout.Create(Self);
  FMenuButton.Parent := TitleLayout;
  FMenuButton.Align := TAlignLayout.Left;
  FMenuButton.Width := 56;
  FMenuButton.HitTest := True;
  FMenuButton.OnClick := MenuButtonClick;
  for LIndex := 0 to 2 do
  begin
    LBar := TRectangle.Create(FMenuButton);
    LBar.Parent := FMenuButton;
    LBar.HitTest := False;
    LBar.Stroke.Kind := TBrushKind.None;
    LBar.Fill.Color := TAppColors.PrimaryTextColor;
    LBar.SetBounds(16, 23 + LIndex * 8, 24, 2);
  end;
  TitleLabel.Margins.Left := FMenuButton.Width;

  // above the content and the action buttons: same parent as OverlayLayout
  FDrawerLayer := TLayout.Create(Self);
  FDrawerLayer.Parent := OverlayLayout.Parent;
  FDrawerLayer.Align := TAlignLayout.Contents;
  FDrawerLayer.Visible := False;
  FDrawerLayer.BringToFront;

  FDrawerScrim := TRectangle.Create(Self);
  FDrawerScrim.Parent := FDrawerLayer;
  FDrawerScrim.Align := TAlignLayout.Contents;
  FDrawerScrim.Fill.Color := TAlphaColorRec.Black;
  FDrawerScrim.Stroke.Kind := TBrushKind.None;
  FDrawerScrim.Opacity := 0;
  FDrawerScrim.OnClick := DrawerScrimClick;

  FDrawerPanel := TRectangle.Create(Self);
  FDrawerPanel.Parent := FDrawerLayer;
  FDrawerPanel.Align := TAlignLayout.Left;
  FDrawerPanel.Width := AWidth;
  FDrawerPanel.Margins.Left := -AWidth; // closed: out of the screen
  FDrawerPanel.Fill.Color := TAlphaColorRec.White;
  FDrawerPanel.Stroke.Kind := TBrushKind.None;
  FDrawerPanel.ClipChildren := True;
end;

procedure TScaffoldForm.DrawerScrimClick(Sender: TObject);
begin
  CloseDrawer;
end;

procedure TScaffoldForm.MenuButtonClick(Sender: TObject);
begin
  if FDrawerOpen then
    CloseDrawer
  else
    OpenDrawer;
end;

function TScaffoldForm.OpenDrawer: TScaffoldForm;
begin
  Result := Self;
  if not Assigned(FDrawerLayer) or FDrawerOpen then
    Exit;
  FDrawerOpen := True;
  FDrawerLayer.Visible := True;
  FDrawerLayer.BringToFront;
  TAnimator.AnimateFloat(FDrawerPanel, 'Margins.Left', 0, DRAWER_ANIMATION);
  TAnimator.AnimateFloat(FDrawerScrim, 'Opacity', DRAWER_SCRIM_OPACITY, DRAWER_ANIMATION);
  SetDrawerBackHandler(True);
end;

function TScaffoldForm.CloseDrawer: TScaffoldForm;
begin
  Result := Self;
  if not Assigned(FDrawerLayer) or not FDrawerOpen then
    Exit;
  FDrawerOpen := False;
  SetDrawerBackHandler(False);
  TAnimator.AnimateFloat(FDrawerPanel, 'Margins.Left', -FDrawerPanel.Width, DRAWER_ANIMATION);
  TAnimator.AnimateFloat(FDrawerScrim, 'Opacity', 0, DRAWER_ANIMATION);
  Track(TDelayedAction.Schedule(Round(DRAWER_ANIMATION * 1000) + 10
  , procedure
    begin
      // unless it was opened again meanwhile
      if Assigned(FDrawerLayer) and not FDrawerOpen then
        FDrawerLayer.Visible := False;
    end
  ));
end;

function TScaffoldForm.GetDrawerOpen: Boolean;
begin
  Result := FDrawerOpen;
end;

procedure TScaffoldForm.SetDrawerBackHandler(const AAdd: Boolean);
begin
  if AAdd = FDrawerBackHandlerAdded then
    Exit;
  if not TNavigator.Initialized then
    Exit;
  if AAdd then
    Navigator.AddBackHandler(FDrawerBackHandler)
  else
    Navigator.RemoveBackHandler(FDrawerBackHandler);
  FDrawerBackHandlerAdded := AAdd;
end;

function TScaffoldForm.SetDrawerAsForm<T>(const AConfigProc: TProc<T>;
  const AWidth: Single): TScaffoldForm;
begin
  Result := Self;
  CreateDrawer(AWidth);
  FDrawer := FormStand1.NewAndShow<T>(FDrawerPanel, '', AConfigProc);
end;

function TScaffoldForm.SetDrawerAsFrame<T>(const AConfigProc: TProc<T>;
  const AWidth: Single): TScaffoldForm;
begin
  Result := Self;
  CreateDrawer(AWidth);
  FDrawer := FrameStand1.NewAndShow<T>(FDrawerPanel, '', AConfigProc);
end;

function TScaffoldForm.SetBottomNavigation(
  const AConfigProc: TProc<TTabsFrame>): TScaffoldForm;
begin
  Result := Self;
  SetContentAsFrame<TTabsFrame>(
    procedure (ATabs: TTabsFrame)
    begin
      FBottomNavigation := ATabs;
      ATabs.SetBarPosition(TTabBarPosition.Bottom);
      if Assigned(AConfigProc) then
        AConfigProc(ATabs);
    end
  );
  // the action buttons (and the snackbar) above the navigation bar
  ActionButtonsLayout.Align := TAlignLayout.Bottom;
  ActionButtonsLayout.Margins.Bottom := ACTION_BUTTONS_BOTTOM;
  OverlayLayout.Padding.Bottom := FBottomNavigation.GetBarHeight;
end;

function TScaffoldForm.GetContent: TSubject;
begin
  Result := nil;
  if Assigned(FContent) then
    Result := FContent.Subject;
end;

function TScaffoldForm.GetTitleDetailContent: TSubject;
begin
  Result := nil;
  if Assigned(FTitleDetailContent) then
    Result := FTitleDetailContent.Subject;
end;

function TScaffoldForm.GetTitleDetailContentVisible: Boolean;
begin
  Result := Assigned(FTitleDetailContent) and FTitleDetailContent.IsVisible;
end;

procedure TScaffoldForm.HideHandler;
begin
  // destructor would be too late
//  FrameStand1.HideAndCloseAll();
//  FormStand1.HideAndCloseAll();

{ TODO : Find a way to hide/close everything it the correct order }
  SI.DefaultHide;
end;

procedure TScaffoldForm.HideTitleDetailContent(const ADelay: Integer = 0; const AThen: TProc = nil);
begin
  if Assigned(FTitleDetailContent) then
    FTitleDetailContent.Hide(ADelay, AThen);
end;

function TScaffoldForm.SetContentAsForm<T>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TScaffoldForm.SetContentAsFrame<T>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TScaffoldForm.SetTitle(const ATitle: string): TScaffoldForm;
begin
  Result := Self;
  FTitle := ATitle;
  TitleLabel.Text := FTitle;
end;

function TScaffoldForm.SetTitleDetailContentAsForm<T>(
  const AConfigProc: TProc<T>): TScaffoldForm;
begin
  Result := Self;
  FTitleDetailContent := FormStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

function TScaffoldForm.SetTitleDetailContentAsFrame<T>(
  const AConfigProc: TProc<T>): TScaffoldForm;
begin
  Result := Self;
  FTitleDetailContent := FrameStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

function TScaffoldForm.ShowSnackBar(const AText: string;
  const ADuration_ms: Integer): TScaffoldForm;
begin
  Result := ShowSnackBar(AText, ADuration_ms, nil);
end;

function TScaffoldForm.ShowSnackBar(const AText: string;
  const ADuration_ms: Integer; const AThen: TProc): TScaffoldForm;
var
  LSnackBar: TFrameInfo<TTextFrame>;
begin
  Result := Self;

  LSnackBar := FrameStand1.New<TTextFrame>(OverlayLayout, 'snackbar');

  LSnackBar.Frame.SetContent(AText);
  LSnackBar.Show();

  // hide and free the snackbar (Hide alone kept one hidden frame per call);
  // tracked: nothing runs if the scaffold (its route) is closed before
  if not Assigned(AThen) then
    LSnackBar.HideAndCloseAfter(ADuration_ms)
  else
    Track(TDelayedAction.Schedule(ADuration_ms
      , procedure
        begin
          LSnackBar.HideAndClose(0, AThen);
        end
    ));
end;

procedure TScaffoldForm.Track(const AAction: IDelayedAction);
var
  LIndex: Integer;
begin
  for LIndex := FPendingActions.Count - 1 downto 0 do
    if not FPendingActions[LIndex].Pending then
      FPendingActions.Delete(LIndex);
  if Assigned(AAction) and AAction.Pending then
    FPendingActions.Add(AAction);
end;

procedure TScaffoldForm.ShowTitleDetailContent;
begin
  if Assigned(FTitleDetailContent) then
    FTitleDetailContent.SubjectShow;
end;

end.
