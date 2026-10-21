# API at a glance (declarations)

Public declarations copied from `source\` (FMXER v.1.2; private fields, event handlers of the `.fmx` and getters behind properties are omitted). Every unit is `source\FMXER.<Name>.pas` and declares one element `T<Name>`, unless noted.

## Units

| Unit | Declares |
|---|---|
| `FMXER.Navigator` | `TNavigator`, `Navigator()` |
| `FMXER.UI.Misc` | `TElementDef<T>`, `TNameValueParam`, `TParams`, `Param()`, `OnClickProc()`, `TFMXERFrameHelper` (for `TControl`), `TFMXERFormHelper` (for `TCommonCustomForm`), `TSubjectInfoContainer`, `TCaptionPosition`, `LocalFile()`, `LocalFilesPath` |
| `FMXER.UI.Types` | `TOnTapHandler` (shared by the image elements) |
| `FMXER.UI.Consts` | `TAppColors` |
| `FMXER.IconFontsData` | `TIconFonts`, `IconFonts()` |
| `Icons.Utils` / `Icons.MaterialDesign` | `TIconEntry`, `TIconCollection`, `TIconManager` / `TMaterialDesign` (one `TIconEntry` per icon, `-` → `_`: `MD.qrcode_scan`) |
| `SubjectStand` (TFrameStand) | `TSubjectInfo`, `TSubject`, attributes `[SubjectInfo]`, `[Show]`, `[Hide]`, `[BeforeShow]`, `[AfterShow]` |
| `FrameStand`, `FormStand` (TFrameStand) | `TFrameStand`, `TFormStand`: every container has public `FrameStand1`/`FormStand1` fields |
| `System.Skia`, `FMX.Skia` (Delphi 12+) | `ISkCanvas` (System.Skia); `TSkLabel`, `TSkSvg`, `TSkAnimatedImage`, `TSkPaintBox`, `TSkTextHorzAlign`, `TSkAnimatedImageWrapMode`, `TSkSvgWrapMode`, `GlobalUseSkia` (FMX.Skia) |
| `FMX.ListView.Appearances` | `TListViewItem` (for `TListViewFrame` handlers) |

## Navigator

```pascal
// unit FMXER.Navigator
function Navigator(const AFormStand: TFormStand = nil): TNavigator;  // inits on first call with a form stand

TNavigator = class
  constructor Create(const AFormStand: TFormStand); virtual;
  procedure CloseAllRoutes(const AFilter: TPredicate<string> = nil);
  procedure CloseAllRoutesExcept(const ARouteName: string);
  procedure CloseRoute(const ARouteName: string; const ATransient: Boolean = False); // ATransient ignored since v.1.2
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
  function Breadcrumb: TArray<string>;                       // Stack, first opened first
  property ActiveRoutes: TDictionary<string, TSubjectInfo>;  // ActiveRoutes['home'].Subject = the screen
  property RouteDefinitions: TDictionary<string, TFunc<TSubjectInfo>>;
  property FormStand: TFormStand;
  property Stack: TStack<string>;                            // non-transient routes, last on top
  property OnCreateRoute: TProc<string>;
  property OnCloseRoute: TProc<string>;
  function HandleBackKey(var AKey: Word; var AKeyChar: WideChar): Boolean;  // v.1.4: Back/Esc -> StackPop (not at the root)
  function SetCatchBackKey(const AValue: Boolean): TNavigator;             // v.1.4: hooks OnKeyDown of FormStand's form
  property CatchBackKey: Boolean;
  // v.1.8: the state of a route (a TComponent, typically a TDataModule): created with Create(nil) before
  // the view, owned by the view (freed with the route) or, with AKeepAlive, by the navigator (reused)
  function DefineRoute<TView: TForm; TState: TComponent>(const ARouteName: string;
    const AConfigProc: TProc<TView, TState>; const AKeepAlive: Boolean = False;
    const AParent: TFmxObject = nil; const AStandName: string = ''): TNavigator; overload;
  function RouteState<T: TComponent>(const ARouteName: string): T;     // raises when none
  function HasRouteState(const ARouteName: string): Boolean;
  // AInit: the arguments, on the new state before the view is built (not called if already active)
  procedure RouteTo<TState: TComponent>(const ARouteName: string; const AInit: TProc<TState>;
    const AOnResult: TProc<TValue> = nil; const ATransient: Boolean = False); overload;
  // AOnResult: once, when the route closes: the CloseRouteWithResult value, or empty (CloseRoute, Back...)
  procedure RouteToForResult(const ARouteName: string; const AOnResult: TProc<TValue>;
    const ATransient: Boolean = False);
  procedure CloseRouteWithResult(const ARouteName: string; const AResult: TValue);  // Navigator.pop(result)
  function AddBackHandler(const AHandler: TFunc<Boolean>): TNavigator;      // v.1.7: Back/Esc asks it first (last added first); True = handled, no route closed
  procedure RemoveBackHandler(const AHandler: TFunc<Boolean>);            // the same reference
  class procedure Init(const AFormStand: TFormStand);        // raises if already initialized
  class procedure ReleaseInstance;                           // v.1.4: frees the singleton
  class property Instance: TNavigator;                       // raises if not initialized
  class property Initialized: Boolean;
end;
// Navigator(AFormStand): with a stand other than the singleton's raises (v.1.4)
```

## Scaffold and action button

```pascal
// unit FMXER.ScaffoldForm
TScaffoldForm = class(TForm)
  TitleLayout: TLayout; TitleBackground: TRectangle; TitleLabel: TSkLabel; TitleDetailLayout: TLayout;
  ContentLayout: TLayout; OverlayLayout: TLayout; ActionButtonsLayout: TLayout;
  FrameStand1: TFrameStand; FormStand1: TFormStand; Stands: TStyleBook;   // Stands has 'snackbar'
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
  function SetTitleDetailContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
  function SetTitleDetailContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
  procedure AddActionButtonOverlayFrame<T: TFrame>(const AOverlayConfigProc: TProc<T>;
    const AOnClickProc: TProc); overload;
  procedure AddActionButtonOverlayFrame<T: TFrame>(const AElementDef: TElementDef<T>); overload;
  procedure AddActionButtonOverlayForm<T: TForm>(const AOverlayConfigProc: TProc<T>;
    const AOnClickProc: TProc);
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
  // v.1.7 drawer: menu button (drawn) left of the title, white panel sliding in from the left
  // over the whole screen; tap outside, Back or Esc close it. Once per scaffold (twice raises)
  function SetDrawerAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil; const AWidth: Single = 280): TScaffoldForm;
  function SetDrawerAsForm<T: TForm>(const AConfigProc: TProc<T> = nil; const AWidth: Single = 280): TScaffoldForm;
  function OpenDrawer: TScaffoldForm;
  function CloseDrawer: TScaffoldForm;     // call it from the drawer items
  function GetDrawerOpen: Boolean;
  property DrawerOpen: Boolean; property Drawer: TSubjectInfo; property DrawerPanel: TRectangle; property MenuButton: TLayout;
  // v.1.7 bottom navigation: content = TTabsFrame with the bar at the bottom; action buttons above it.
  // Instead of SetContentAs*
  function SetBottomNavigation(const AConfigProc: TProc<TTabsFrame>): TScaffoldForm;
  property BottomNavigation: TTabsFrame;   // e.g. BottomNavigation.SetTabIndex(2) from a drawer item
  property ActionButtonStand: string;
  property ContentStand: string;
  property TitleDetailStand: string;
  property Content: TSubject;              // read-only
  property TitleDetailContent: TSubject;   // read-only
  property TitleDetailContentVisible: Boolean;
end;

// unit FMXER.ActionButtonFrame (a circle in PrimaryColor with an element on top)
TActionButtonFrame = class(TFrame)
  BackgroundCircle: TCircle;
  function SetOverlayAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TActionButtonFrame;
  function SetOverlayAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TActionButtonFrame;
  function SetOverlayAsText(const AText: string;
    const AOnClickProc: TProc = nil;
    const AConfigProc: TProc<TTextFrame> = nil): TActionButtonFrame;
  function SetOnClickProc(const AOnClickProc: TProc): TActionButtonFrame;
  property OnClickProc: TProc;
  property OverlayStand: string;
end;
```

## Containers

Every container also has public `FrameStand1: TFrameStand` and (except `TStackFrame`) `FormStand1: TFormStand`, plus the slot layouts as published fields. Since v.1.3 every slot method is a function returning its container (chainable), and every stand property has a fluent setter.

```pascal
// unit FMXER.ColumnForm — slots aligned Top, column Height grows by each slot (starts at 1)
TColumnForm = class(TForm)
  ContentLayout: TLayout; Stands: TStyleBook;               // Stands has 'fadeIn'
  const DEFAULT_ELEMENT_HEIGHT = 200;
  const AUTO_HEIGHT = -1;   // v.1.3: slot = the element's own height (design, or set in AConfigProc; margins included; forms: Height)
  function AddFrame<T: TFrame>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
    const AConfigProc: TProc<T> = nil): TColumnForm; overload;
  function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TColumnForm; overload;   // param 'Height'
  function AddForm<T: TForm>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
    const AConfigProc: TProc<T> = nil): TColumnForm; overload;
  function AddForm<T: TForm>(const AColDef: TElementDef<T>): TColumnForm; overload;
  function GetContent: TLayout; virtual;
  function SetElementStand(const AStand: string): TColumnForm;
  property ElementStand: string;                            // default 'fadeIn' (the stands' DefaultStandName)
  property Elements: TList<TSubjectInfoContainer>;
end;

// All four (TColumnForm, TRowForm, TColumnFrame, TRowFrame) also have, since v.1.4:
//   function BatchUpdate(const ABuildProc: TProc<TSelf>): TSelf;   // add many elements: one realign, O(N) not O(N^2)
// unit FMXER.ColumnFrame / FMXER.RowFrame (v.1.4): TColumnFrame = class(TFrame), TRowFrame = class(TFrame),
//   the same members as TColumnForm / TRowForm (AddFrame, AddForm, AUTO_HEIGHT / AUTO_WIDTH, Elements,
//   SetElementStand, SetElementAlign, ElementStand, ElementAlign, BatchUpdate); Height/Width start at 0.
//   ~10x cheaper to create than the forms (a form creates a native window on Windows).

// unit FMXER.RowForm — slots aligned ElementAlign (default Left), row Width grows by each slot
TRowForm = class(TForm)
  ContentLayout: TLayout; Stands: TStyleBook;               // has 'fadeIn', not the default
  const DEFAULT_ELEMENT_WIDTH = 200;
  const AUTO_WIDTH = -1;    // v.1.3: slot = the element's own width
  function AddFrame<T: TFrame>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
    const AConfigProc: TProc<T> = nil): TRowForm; overload;
  function AddFrame<T: TFrame>(const AColDef: TElementDef<T>): TRowForm; overload;     // param 'Width'
  function AddForm<T: TForm>(const AWidth: Integer = DEFAULT_ELEMENT_WIDTH;
    const AConfigProc: TProc<T> = nil): TRowForm; overload;
  function AddForm<T: TForm>(const AColDef: TElementDef<T>): TRowForm; overload;
  function GetContent: TLayout; virtual;
  function SetElementStand(const AStand: string): TRowForm;
  function SetElementAlign(const AAlign: TAlignLayout): TRowForm;
  property ElementStand: string;
  property ElementAlign: TAlignLayout;
  property Elements: TList<TSubjectInfoContainer>;
end;

// unit FMXER.StackFrame — layers filling the frame, later on top; frames only
TStackFrame = class(TFrame)
  function AddFrame<T: TFrame>(const AConfigProc: TProc<T> = nil; const AName: string = ''): TStackFrame; // unnamed: 'layer0', 'layer1'...
  procedure CloseFrame(const AName: string);
  property DefaultStand: string;
end;

// unit FMXER.VertScrollFrame — content aligned Top, keeps its own Height (frames: design height or set in AConfigProc)
TVertScrollFrame = class(TFrame)
  VerticalScrollbox: TVertScrollBox;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TVertScrollFrame;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TVertScrollFrame;
  function GetTouchWidth: Single;
  function SetTouchWidth(const ATouchWidth: Single): TVertScrollFrame;  // right padding for dragging, default 50
  function SetContentStand(const AStand: string): TVertScrollFrame;
  property ContentStand: string;
  property OnResizeProc: TProc<TVertScrollFrame>;
  property OnResizedProc: TProc<TVertScrollFrame>;
  property OnShowProc: TProc<TVertScrollFrame>;
end;

// unit FMXER.VertScrollForm
TVertScrollForm = class(TForm)
  VerticalScrollbox: TVertScrollBox;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TVertScrollForm;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TVertScrollForm;
  function SetContentStand(const AStand: string): TVertScrollForm;
  function SetTouchWidth(const ATouchWidth: Single): TVertScrollForm;
  property ContentStand: string;
  property TouchWidth: Single;
end;

// unit FMXER.HorzScrollFrame — content aligned Left, keeps its own Width
THorzScrollFrame = class(TFrame)
  HorizontalScrollBox: THorzScrollBox;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzScrollFrame;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzScrollFrame;
  function SetContentStand(const AStand: string): THorzScrollFrame;
  function SetTouchHeight(const ATouchHeight: Single): THorzScrollFrame;
  property ContentStand: string;
  property TouchHeight: Single;
end;

// unit FMXER.AccessoryFrame — fixed-width left/right, content in between
TAccessoryFrame = class(TFrame)
  LeftLayout, ContentLayout, RightLayout: TLayout;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetLeftAsFrame<T: TFrame>(const AWidth: Single; const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetLeftAsForm<T: TForm>(const AWidth: Single; const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetRightAsFrame<T: TFrame>(const AWidth: Single; const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetRightAsForm<T: TForm>(const AWidth: Single; const AConfigProc: TProc<T> = nil): TAccessoryFrame; overload;
  function SetContentStand(const AStand: string): TAccessoryFrame;
  function SetLeftStand(const AStand: string): TAccessoryFrame;
  function SetRightStand(const AStand: string): TAccessoryFrame;
  property ContentStand, LeftStand, RightStand: string;
end;

// unit FMXER.HorzPairFrame — two halves
THorzPairFrame = class(TFrame)
  function SetLeftContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
  function SetLeftContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
  function SetRightContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
  function SetRightContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): THorzPairFrame;
  function SetContentAsFrame<T1, T2: TFrame>(const ALeftConfigProc: TProc<T1> = nil;
    const ARightConfigProc: TProc<T2> = nil): THorzPairFrame;
  function SetContentAsForm<T1, T2: TForm>(const ALeftConfigProc: TProc<T1> = nil;
    const ARightConfigProc: TProc<T2> = nil): THorzPairFrame;
  function GetLeftContentStand: string;  function SetLeftContentStand(const AStandName: string): THorzPairFrame;
  function GetRightContentStand: string; function SetRightContentStand(const AStandName: string): THorzPairFrame;
end;

// unit FMXER.CenterForm — content of the given size, centered
TCenterForm = class(TForm)
  function SetContentAsFrame<T: TFrame>(const AWidth, AHeight: Integer;
    const AConfigProc: TProc<T> = nil): TCenterForm;
  function SetContentAsForm<T: TForm>(const AWidth, AHeight: Integer;
    const AConfigProc: TProc<T> = nil): TCenterForm;
  function SetContentStand(const AStand: string): TCenterForm;
  property ContentStand: string;
end;

// unit FMXER.ContainerFrame (TMarginFrame, TPaddingFrame: same, in FMXER.MarginFrame / FMXER.PaddingFrame)
TContainerFrame = class(TFrame)
  ContentLayout: TLayout;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TContainerFrame;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TContainerFrame;
  function SetContentAs<T: TFmxObject>(const AConfigProc: TProc<T> = nil): TContainerFrame; // any FMX control
  function SetContentStand(const AStand: string): TContainerFrame;
  property ContentStand: string;
  property Content: TSubjectInfo;
end;

// unit FMXER.ContainerForm
TContainerForm = class(TForm)
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TContainerForm;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TContainerForm;
  function SetContentStand(const AStand: string): TContainerForm;
  property ContentStand: string;
  property Content: TSubjectInfo;
end;

// unit FMXER.BackgroundFrame (TBackgroundForm in FMXER.BackgroundForm: same API returning TBackgroundForm)
TBackgroundFrame = class(TFrame)
  BackgroundRectangle: TRectangle;                          // Fill.Color = PrimaryColor at creation
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TBackgroundFrame;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TBackgroundFrame;
  function SetFillColor(const AColor: TAlphaColor): TBackgroundFrame;
  function SetStrokeColor(const AColor: TAlphaColor): TBackgroundFrame;
  function SetStrokeThickness(const AThickness: Single): TBackgroundFrame;
  function SetContentStand(const AStand: string): TBackgroundFrame;
  property ContentStand: string;
  property Content: TSubjectInfo;
  property Fill: TBrush;
  property Stroke: TStrokeBrush;
end;

// unit FMXER.CardFrame — title bar (PrimaryColor), optional glyphs, content
TCardFrame = class(TFrame)
  TitleLayout, ContentLayout, GlyphLayout, GlyphRLayout: TLayout;
  TitleBackground, ContentBackground: TRectangle;
  function SetGlyphAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetGlyphAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetGlyphRAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetGlyphRAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TCardFrame;
  function SetTitle(const ATitle: string): TCardFrame;
  function SetContentStand(const AStand: string): TCardFrame;
  property Title: string;
  property Detail: string;
  property ContentStand, GlyphStand, GlyphRStand: string;
end;

// unit FMXER.HorzDividerFrame — a line in DividerColor; put it in a 1-pixel slot
THorzDividerFrame = class(TFrame)
  DividerLine: TLine;
end;
```

## Tabs (v.1.7)

```pascal
// unit FMXER.TabsFrame — pages switched by a bar of tabs; every page created when added, only the
// selected one visible (the others keep their state); the first tab added is selected
TTabBarPosition = (Top, Bottom);   // Top: TabBar + TabBarView (PrimaryColor bar, indicator); Bottom: NavigationBar (white)
TTabItem = class
  property Button: TLayout; property TextLabel: TSkLabel;
  property Glyph: TGlyph;                         // nil without an icon
  property Page: TSubjectInfoContainer;           // Page.ContainedFrame<T> / ContainedForm<T>
end;
TTabsFrame = class(TFrame)
  BarLayout: TLayout; BarBackground: TRectangle; ButtonsLayout: TLayout; Indicator: TRectangle;
  PagesLayout: TLayout; FrameStand1: TFrameStand; FormStand1: TFormStand;
  function AddTabFrame<T: TFrame>(const ACaption: string; const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
  function AddTabFrame<T: TFrame>(const ACaption: string; const AIcon: TIconEntry;   // icon above the text
    const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
  function AddTabForm<T: TForm>(const ACaption: string; const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
  function AddTabForm<T: TForm>(const ACaption: string; const AIcon: TIconEntry;
    const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
  function SetTabIndex(const AIndex: Integer): TTabsFrame;   // no OnChangeProc; out of range raises
  function SetBarPosition(const APosition: TTabBarPosition): TTabsFrame;   // resets colors and font size: call first
  function SetBarHeight(const AHeight: Single): TTabsFrame;            // default 56
  function SetBarColor(const AColor: TAlphaColor): TTabsFrame;
  function SetTextColor(const AColor: TAlphaColor): TTabsFrame;        // the other tabs (and their icons)
  function SetSelectedTextColor(const AColor: TAlphaColor): TTabsFrame;
  function SetIndicatorColor(const AColor: TAlphaColor): TTabsFrame;
  function SetFontSize(const ASize: Single): TTabsFrame;               // Top 15, Bottom 12
  function SetPageStand(const AStand: string): TTabsFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TTabsFrame;   // tab tapped by the user
  function GetTabIndex: Integer; function GetTabCount: Integer;
  // + GetBarPosition, GetBarHeight, GetBarColor, GetTextColor, GetSelectedTextColor, GetIndicatorColor, GetFontSize
  property Tabs[const AIndex: Integer]: TTabItem;
  property OnChangeProc: TProc<Integer>;
end;
```

## Observable values (v.1.9)

```pascal
// unit FMXER.Observable — Flutter ValueNotifier / ChangeNotifier; notifications in the main thread
TObservable<T> = class(TComponent)                         // owned by the state (data module): freed with it
  constructor Create(AOwner: TComponent; const AInitial: T); overload;
  function Listen(const AOwner: TComponent; const AProc: TProc<T>;
    const ACallNow: Boolean = True): TObservable<T>;     // removed when AOwner (the element) is freed
  procedure Unlisten(const AOwner: TComponent);
  procedure Update(const AFunc: TFunc<T, T>);            // records: change a field and notify
  procedure Notify;                                      // notify without a change
  function ListenerCount: Integer;
  property Value: T;                                     // notifies when different (TEqualityComparer<T>.Default)
end;
// v.1.9 bindings (element owns them; two-way for inputs):
//   TSwitchFrame/TCheckBoxFrame.BindChecked(TObservable<Boolean>), TEditFrame.BindText(TObservable<string>; AOnEditEnd = False),
//   TTrackbarFrame.BindValue(TObservable<Single>), TComboBoxFrame/TRadioGroupFrame.BindItemIndex(TObservable<Integer>),
//   TDateEditFrame.BindDate(TObservable<TDate>); one-way: TTextFrame.BindContent(TObservable<string>),
//   TTextFrame.BindContent<T>(TObservable<T>; AFormat: TFunc<T, string>), TProgressBarFrame.BindValue(TObservable<Single>),
//   TButtonFrame.BindEnabled(TObservable<Boolean>), TControl helper BindVisible/BindEnabled(TObservable<Boolean>)
TChangeNotifier = class(TComponent)
  function Listen(const AOwner: TComponent; const AProc: TProc; const ACallNow: Boolean = False): TChangeNotifier;
  procedure Unlisten(const AOwner: TComponent);
  procedure NotifyChanged;
end;
```

## Dialogs and bottom sheets (v.1.7)

```pascal
// unit FMXER.Modals — singleton Modals (TModals); TFrameStand v.2.3+ ShowModal on the 'dialog' and
// 'bottomsheet' stands of the TFrameStand gallery (embedded). Non-blocking: results arrive in closures.
// A tap outside, Back and Esc cancel the one on top (mrCancel) before the navigator closes a route
TModals = class
  procedure Alert(const ATitle, AMessage: string; const AThen: TProc = nil; const AOkText: string = 'OK');
  procedure Confirm(const ATitle, AMessage: string; const AResultProc: TProc<Boolean>;   // True = OK
    const AOkText: string = 'OK'; const ACancelText: string = 'Cancel');
  procedure Choose(const ATitle: string; const AChoices: TArray<string>;
    const AResultProc: TProc<Integer>);                                  // index, -1 = dismissed
  function ShowDialog<T: TFrame>(const AConfigProc: TProc<T> = nil;
    const AResultProc: TProc<T, TModalResult> = nil;
    const AWidth: Single = 0; const AHeight: Single = 0): TFrameInfo<T>; // card 320x240 by default
  function ShowBottomSheet<T: TFrame>(const AConfigProc: TProc<T> = nil;
    const AResultProc: TProc<T, TModalResult> = nil; const AHeight: Single = 0): TFrameInfo<T>;  // 360
  function CancelTop: Boolean;
  function GetOpenCount: Integer;
  function SetParent(const AParent: TFmxObject): TModals;  // default: Navigator.SafeAreaLayout
  property FrameStand: TFrameStand; property Stands: TStyleBook;
  class procedure ReleaseInstance;
end;
function Modals: TModals;
// Your frame closes the dialog: Info.ModalResult := mrOk (the TFrameInfo<T> returned, captured in a
// variable, or a [SubjectInfo] SI: TSubjectInfo field of the frame). The stands are white: dark text
// (TTextFrame.SetFontColor). Content frames: FMXER.AlertFrame (TAlertFrame: SetTitle, SetMessage,
// SetOkText, SetCancelText), FMXER.ChoicesFrame (TChoicesFrame: SetTitle, SetChoices, Chosen)
```

## Text and input

```pascal
// unit FMXER.TextFrame — TSkLabel; font color = TAppColors.PrimaryTextColor (white) at creation
TTextFrame = class(TFrame)
  TextContent: TSkLabel;
  function SetContent(const AText: string): TTextFrame;
  function SetHorzAlign(const AHorzAlign: TSkTextHorzAlign): TTextFrame;   // Leading, Center, Trailing, Justify
  function SetVertAlign(const AVertAlign: TTextAlign): TTextFrame;
  function SetOnClick(const AOnClickProc: TProc): TTextFrame;
  function SetOnClickProc(const AOnClickProc: TProc): TTextFrame;   // v.1.3, same as SetOnClick
  function SetFontColor(const AColor: TAlphaColor): TTextFrame;
  function SetFontSize(const AFontSize: Single): TTextFrame;
  function SetFontFamily(const AFontFamily: string): TTextFrame;
  function SetMaxLines(const ALines: Integer): TTextFrame;
  function SetFontWeight(const AWeight: TFontWeight): TTextFrame;
  function GetContent: string; // + GetHorzAlign, GetVertAlign, GetOnClickProc, GetFontColor, GetFontSize, GetMaxLines, GetFontWeight
end;

// unit FMXER.ButtonFrame
TButtonFrame = class(TFrame)
  ButtonControl: TButton; ButtonAction: TAction; CaptionLabel, ExtraLabel: TSkLabel; BackgroundRectangle: TRectangle;
  function SetCaption(const ACaption: string): TButtonFrame;
  function SetExtraText(const AExtraText: string): TButtonFrame;
  function SetText(const AText: string): TButtonFrame;
  function SetBackgroundFillColor(const AColor: TAlphaColor): TButtonFrame;
  function SetBackgroundStrokeColor(const AColor: TAlphaColor): TButtonFrame;
  function SetBackgroundStrokeThickness(const AThickness: Single): TButtonFrame;
  function SetBackgroundVisible(const AVisible: Boolean): TButtonFrame;
  function SetBackgroundOpacity(const AOpacity: Single): TButtonFrame;
  function SetOnClickHandler(const AOnClickHandler: TProc): TButtonFrame;
  function SetOnClickProc(const AOnClickProc: TProc): TButtonFrame;   // v.1.3, same as SetOnClickHandler
  property BackgroundFill: TBrush;
  property BackgroundStroke: TStrokeBrush;
  property IsDefault: Boolean;
  property OnClickHandler: TProc;
  property OnUpdateHandler: TProc<TAction>;       // enable/disable the button's action
end;

// unit FMXER.ColorButtonFrame
TColorButtonFrame = class(TButtonFrame)
  ColorRect: TRoundRect;
  function SetColorValue(const AColor: TAlphaColor): TColorButtonFrame;
  function SetColorVisible(const AVisible: Boolean): TColorButtonFrame;
  function SetColorStrokeValue(const AColor: TAlphaColor): TColorButtonFrame;
  function GetColorValue: TAlphaColor; function GetColorVisible: Boolean; function GetColorStrokeValue: TAlphaColor;
end;

// unit FMXER.EditFrame — caption above, extra text below
TEditFrame = class(TFrame)
  EditControl: TEdit; CaptionLabel, ExtraLabel: TSkLabel;
  function SetCaption(const ACaption: string): TEditFrame;
  function SetTextPrompt(const ATextPrompt: string): TEditFrame;
  function SetText(const AText: string): TEditFrame;
  function SetExtraText(const AExtraText: string): TEditFrame;
  function SetPassword(const AIsPassword: Boolean): TEditFrame;
  function SetFocusOnShow(const AFocusOnShow: Boolean): TEditFrame;
  function GetText: string; // + GetTextPrompt, GetCaption, GetPassword, GetExtraText, GetFocusOnShow
  property OnChangeProc: TProc<Boolean>;          // True while typing (OnChangeTracking), False on OnChange
end;

// unit FMXER.TrackbarFrame
TTrackbarFrame = class(TFrame)
  TrackBar1: TTrackBar; CaptionLabel, ExtraLabel: TSkLabel;
  function SetCaption(const ACaption: string): TTrackbarFrame;
  function SetCaptionPosition(const ACaptionPosition: TCaptionPosition; const AMargin: Single = 5): TTrackbarFrame;
  function SetFrequency(const AFrequency: Single): TTrackbarFrame;
  function SetValue(const AValue: Single): TTrackbarFrame;
  function SetMax(const AMax: Single): TTrackbarFrame;
  function SetMin(const AMin: Single): TTrackbarFrame;
  function SetTracking(const ATracking: Boolean): TTrackbarFrame;
  function SetExtraText(const AExtraText: string): TTrackbarFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Single>): TTrackbarFrame;
  function GetValue: Single; // + GetCaption, GetMax, GetMin, GetTracking, GetExtraText, GetFrequency
  property OnChangeProc: TProc<Single>;
end;

// unit FMXER.ColorPickerFrame
TColorPickerFrame = class(TFrame)
  ColorPicker: TColorPanel;
  function SetCaption(const ACaption: string): TColorPickerFrame;
  function SetColor(const AColor: TAlphaColor): TColorPickerFrame;
  function SetExtraText(const AExtraText: string): TColorPickerFrame;
  function GetColor: TAlphaColor; // + GetCaption, GetExtraText
  property OnChangeProc: TProc<TAlphaColor>;
end;

// unit FMXER.ChipFrame / FMXER.ChipsFrame
TChipFrame = class(TFrame)
  Button: TSpeedButton; Shape: TRoundRect;
  function SetText(const AText: string): TChipFrame;
  function SetBackgroundColor(const AColor: TAlphaColor): TChipFrame;
  function SetForegroundColor(const AColor: TAlphaColor): TChipFrame;
  function SetOnClickProc(const AOnClickProc: TProc): TChipFrame;   // v.1.3
  property OnClickHandler: TProc;
end;
TChipsFrame = class(TFrame)                       // a TFlowLayout of chips
  Flow: TFlowLayout;
  function AddChip(const AText: string; const AConfigProc: TProc<TChipFrame> = nil): TChipsFrame;
  function SetHorizontalGap(const AGap: Single): TChipsFrame;
  function SetVerticalGap(const AGap: Single): TChipsFrame;
  property DefaultConfig: TProc<TChipFrame>;      // used by AddChip only when AConfigProc is nil
end;
```

## Form controls (v.1.7)

Setters of the value (`SetItemIndex`, `SetDate`) do not call `OnChangeProc` for the radio group, the combo box and the date edit; `SetChecked` of the switch and the check box does (the FMX controls fire their events).

```pascal
// unit FMXER.SwitchFrame — text on the left, TSwitch on the right; a tap on the text toggles (SwitchListTile). Design height 50
TSwitchFrame = class(TFrame)
  SwitchLayout: TLayout; SwitchControl: TSwitch; TextLabel, ExtraLabel: TSkLabel;
  function SetText(const AText: string): TSwitchFrame;
  function SetExtraText(const AExtraText: string): TSwitchFrame;
  function SetChecked(const AChecked: Boolean): TSwitchFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Boolean>): TSwitchFrame;
  function GetChecked: Boolean; // + GetText, GetExtraText
  property OnChangeProc: TProc<Boolean>;
end;

// unit FMXER.CheckBoxFrame — TCheckBox on the left, text on the right; a tap on the text toggles (CheckboxListTile). Design height 50
TCheckBoxFrame = class(TFrame)
  CheckBoxControl: TCheckBox; TextLabel, ExtraLabel: TSkLabel;
  function SetText(const AText: string): TCheckBoxFrame;
  function SetExtraText(const AExtraText: string): TCheckBoxFrame;
  function SetChecked(const AChecked: Boolean): TCheckBoxFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Boolean>): TCheckBoxFrame;
  function GetChecked: Boolean; // + GetText, GetExtraText
  property OnChangeProc: TProc<Boolean>;
end;

// unit FMXER.RadioGroupFrame — caption (24) + one TRadioButton per option (ItemHeight, default 40) + extra text;
// Height follows them (use AUTO_HEIGHT, options set in AConfigProc). One group per frame
TRadioGroupFrame = class(TFrame)
  CaptionLabel, ExtraLabel: TSkLabel; OptionsLayout: TLayout;
  function SetCaption(const ACaption: string): TRadioGroupFrame;
  function SetExtraText(const AExtraText: string): TRadioGroupFrame;
  function AddOption(const AText: string): TRadioGroupFrame;
  function SetOptions(const AOptions: TArray<string>): TRadioGroupFrame;   // replaces
  function ClearOptions: TRadioGroupFrame;
  function SetItemIndex(const AItemIndex: Integer): TRadioGroupFrame;      // -1: none
  function SetItemHeight(const AItemHeight: Single): TRadioGroupFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TRadioGroupFrame;
  function GetItemIndex: Integer; function GetSelectedText: string; function GetCount: Integer;
  // + GetCaption, GetExtraText, GetItemHeight
  property Buttons: TList<TRadioButton>;
  property OnChangeProc: TProc<Integer>;          // index of the new selection, once per change
end;

// unit FMXER.ComboBoxFrame — caption above, TComboBox (36 high), extra text below (DropdownButton). Design height 60
TComboBoxFrame = class(TFrame)
  ComboBoxControl: TComboBox; CaptionLabel, ExtraLabel: TSkLabel;
  function SetCaption(const ACaption: string): TComboBoxFrame;
  function SetExtraText(const AExtraText: string): TComboBoxFrame;
  function AddItem(const AText: string): TComboBoxFrame;
  function SetItems(const AItems: TArray<string>): TComboBoxFrame;         // replaces
  function ClearItems: TComboBoxFrame;
  function SetItemIndex(const AItemIndex: Integer): TComboBoxFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TComboBoxFrame;
  function GetItemIndex: Integer; function GetSelectedText: string; function GetCount: Integer;
  // + GetCaption, GetExtraText
  property OnChangeProc: TProc<Integer>;
end;

// unit FMXER.DateEditFrame — caption above, TDateEdit (36 high; native picker on mobile), extra text below. Design height 60
TDateEditFrame = class(TFrame)
  DateEditControl: TDateEdit; CaptionLabel, ExtraLabel: TSkLabel;
  function SetCaption(const ACaption: string): TDateEditFrame;
  function SetExtraText(const AExtraText: string): TDateEditFrame;
  function SetDate(const ADate: TDate): TDateEditFrame;
  function SetFormat(const AFormat: string): TDateEditFrame;              // TDateEdit.Format
  function SetIsEmpty(const AIsEmpty: Boolean): TDateEditFrame;
  function SetOnChangeProc(const AOnChangeProc: TProc<TDate>): TDateEditFrame;
  function GetDate: TDate; // + GetCaption, GetExtraText, GetFormat, GetIsEmpty
  property OnChangeProc: TProc<TDate>;
end;

// unit FMXER.ProgressBarFrame — LinearProgressIndicator: TrackRect (LightBackgroundColor) with BarRect
// (PrimaryColor) in TrackLayout; caption above, extra text below. Design height 40
TProgressBarFrame = class(TFrame)
  TrackLayout: TLayout; TrackRect, BarRect: TRectangle; CaptionLabel, ExtraLabel: TSkLabel;
  function SetValue(const AValue: Single): TProgressBarFrame;              // clamped to Min..Max when drawn
  function SetMin(const AMin: Single): TProgressBarFrame;                  // default 0
  function SetMax(const AMax: Single): TProgressBarFrame;                  // default 100
  function SetIndeterminate(const AIndeterminate: Boolean): TProgressBarFrame;  // a bar running along the track
  function SetBarColor(const AColor: TAlphaColor): TProgressBarFrame;
  function SetTrackColor(const AColor: TAlphaColor): TProgressBarFrame;
  function SetThickness(const AThickness: Single): TProgressBarFrame;      // default 6
  function SetCaption(const ACaption: string): TProgressBarFrame;
  function SetExtraText(const AExtraText: string): TProgressBarFrame;
  // + the getters of each setter
end;
```

## Lists

```pascal
// unit FMXER.ListViewFrame
TListViewItemClickProc = reference to procedure (const AItem: TListViewItem);
TListViewFrame = class(TFrame)
  ListView: TListView;                            // Images = IconFonts.ImageList unless assigned
  const ON_SELECT_DATA = 'FMXER.OnSelect';        // TListViewItem.Data key of the click handler
  procedure RefreshList;                          // clears and runs ItemBuilderProc
  function AddItem(const AText: string; const ADetailText: string = '';
    const AImageIndex: Integer = -1; const AOnSelect: TListViewItemClickProc = nil): TListViewItem;
  procedure ClearItems;
  function SetOnSearchChange(const AProc: TProc): TListViewFrame;
  property AccessoryVisible: Boolean;
  property CanSwipeDelete: Boolean;
  property ItemAppearance: string;                // 'ListItem', 'ImageListItem', 'ImageListItemBottomDetail'...
  property ItemBuilderProc: TProc;                // setting it runs it (on a cleared list); pull-to-refresh reruns it
  property SearchVisible: Boolean;
  property SelectedItem: TListViewItem;
  property SearchText: string;
end;
```

## Images, media, QR codes

```pascal
// unit FMXER.UI.Types (since v.1.2.1); FMXER.ImageFrame, FMXER.AnimatedImageFrame,
// FMXER.SVGFrame, FMXER.QRCodeFrame alias it (TOnTapHandler = FMXER.UI.Types.TOnTapHandler)
TOnTapHandler = reference to procedure(AImage: TFMXObject; APoint: TPointF);  // tap on mobile, mouse up on Windows

TImageFrame = class(TFrame)
  ContentImage: TImage;
  property Image: TImage;
  function SetOnTapHandler(const AOnTapHandler: TOnTapHandler): TImageFrame;
  property OnTapHandler: TOnTapHandler;
end;

TAnimatedImageFrame = class(TFrame)             // Lottie / animated images (TSkAnimatedImage)
  function LoadFromFile(const AFileName: string): TAnimatedImageFrame;
  function SetWrapMode(const AWrapMode: TSkAnimatedImageWrapMode): TAnimatedImageFrame;
  function SetOpacity(const AOpacity: Single): TAnimatedImageFrame;
  function SetAnimationSpeed(const ASpeed: Single): TAnimatedImageFrame;
  property Image: TSkAnimatedImage;
  function SetOnTapHandler(const AOnTapHandler: TOnTapHandler): TAnimatedImageFrame;
  property OnTapHandler: TOnTapHandler;
end;

TSVGFrame = class(TFrame)
  SVG: TSkSvg;
  function LoadFromFile(const AFileName: string): TSVGFrame; overload;
  function LoadFromFile(const AFileName: string; const AEncoding: TEncoding): TSVGFrame; overload;
  function SetOpacity(const AOpacity: Single): TSVGFrame;
  function SetWrapMode(const AWrapMode: TSkSvgWrapMode): TSVGFrame;
  function SetOverrideColor(const AOverrideColor: TAlphaColor): TSVGFrame;
  function SetSVGSource(const ASVGSource: string): TSVGFrame;
  function SetOnTapHandler(const AOnTapHandler: TOnTapHandler): TSVGFrame;
  property OnTapHandler: TOnTapHandler;
end;

// unit FMXER.PaintBoxFrame
TOnDrawHandler = reference to procedure(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
TPaintBoxTapHandler = reference to procedure(APaintBox: TObject; APoint: TPointF);
TOnTapHandler = TPaintBoxTapHandler deprecated 'use TPaintBoxTapHandler';
TPaintBoxFrame = class(TFrame)
  PaintBox: TSkPaintBox;
  function SetOnDrawHandler(const ADrawHandler: TOnDrawHandler): TPaintBoxFrame;
  function SetOnTapHandler(const ATapHandler: TPaintBoxTapHandler): TPaintBoxFrame;
  property OnDrawHandler: TOnDrawHandler;
  property OnTapHandler: TPaintBoxTapHandler;
end;

// unit FMXER.QRCodeFrame (encoding: DelphiZXingQRCode)
TQRCodeFrame = class(TFrame)
  QRCode: TSkSvg; QRCodeLogo: TSkAnimatedImage;
  function SetContent(const AContent: string): TQRCodeFrame;
  function SetRadiusFactor(const ARadiusFactor: Single): TQRCodeFrame;
  function SetSVGSource(const ASource: string): TQRCodeFrame;
  function SetOverrideColor(const AColor: TAlphaColor): TQRCodeFrame;
  function LoadLogoContentFromFile(const AFileName: string): TQRCodeFrame;
  function SetLogoWidth(const AWidth: Single): TQRCodeFrame;
  function SetLogoHeight(const AHeight: Single): TQRCodeFrame;
  function SetLogoVisible(const AVisible: Boolean): TQRCodeFrame;
  function SetOnTapHandler(const AOnTapHandler: TOnTapHandler): TQRCodeFrame;
  property OnBeforePaint: TOnBeforePaintHandler;   // QRCode.Utils
  property OnTapHandler: TOnTapHandler;
end;

TActivityBubblesFrame = class(TFrame)  function SetText(const AText: string): TActivityBubblesFrame;  property Text: string;  end;  // FMXER.ActivityBubblesFrame
TLogoFrame = class(TFrame)  LogoImage: TImage;  function SetLogoResource(const AResourceName: string): TLogoFrame;  property LogoResource: string;  end;  // FMXER.LogoFrame
TWebViewFrame = class(TFrame)  WebBrowser1: TWebBrowser;  function SetURL(const AURL: string): TWebViewFrame;  function SetHTML(const AHTML: string): TWebViewFrame;  property HTML: string;  property URL: string;  end;
```

## Icons

```pascal
// unit FMXER.IconFontsData — singleton data module, created on first use
function IconFonts: TIconFonts;
TIconFonts = class(TDataModule)
  ImageList: TIconFontsImageList;
  function AddIcon(const AIcon: TIconEntry): Integer; overload;                         // FontColor (black)
  function AddIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): Integer; overload;
  function AddIcon(const ACodePoint: Integer): Integer; overload;
  function AddIcon(const ACodePoint: Integer; const AColor: TAlphaColor): Integer; overload;
  property MD: TMaterialDesign;                   // IconFonts.MD.close, IconFonts.MD.account...
end;
// AddIcon adds each (icon, color) once and returns the existing index afterwards (since v.1.2)

// unit FMXER.GlyphFrame / FMXER.IconFontsGlyphFrame
TGlyphFrame = class(TFrame)
  ContentGlyph: TGlyph;
  function SetImageIndex(const AIndex: Integer): TGlyphFrame;
  function SetImages(AImageList: TCustomImageList): TGlyphFrame;
  function SetOnClickProc(const AOnClickProc: TProc): TGlyphFrame;   // clickable only when set
  function GetImageIndex: Integer; function GetImages: TCustomImageList; function GetOnClickProc: TProc;
end;
TIconFontsGlyphFrame = class(TGlyphFrame)       // Images = IconFonts.ImageList
  function SetIcon(const AIcon: TIconEntry): TIconFontsGlyphFrame; overload;
  function SetIcon(const AIcon: TIconEntry; const AColor: TAlphaColor): TIconFontsGlyphFrame; overload;
  function SetIcon(const AIconFontImageIndex: Integer): TIconFontsGlyphFrame; overload;
end;

// unit Icons.Utils
TIconEntry = record
  name: string; codepoint: Integer; index: Integer; aliases: string;
  class operator Implicit(Entry: TIconEntry): Integer;   // code point
  class operator Implicit(Entry: TIconEntry): string;    // name
end;
// TIconManager.Instance.Collections: TList<TIconCollection>;
// TIconCollection.FindEntry(const AName: string; out AEntry: TIconEntry; const ACaseInsensitive: Boolean = False): Boolean
```

## FMXER.UI.Misc

```pascal
TNameValueParam = record
  Name: string; Value: TValue;
  constructor Create(const AName: string; const AValue: TValue);
end;
TParams = TArray<TNameValueParam>;

TElementDef<T> = record
  Params: TArray<TNameValueParam>;
  ConfigProc: TProc<T>;
  constructor Create(const AConfigProc: TProc<T>; const AParams: TParams = []);
  function FindParam(const AName: string; out AParam: TNameValueParam): Boolean;
  function ParamByName(const AName: string; const ADefaultValue: TValue): TValue; overload;
  function ParamByName(const AName: string): TValue; overload;
  class operator Implicit(AConfigProc: TProc<T>): TElementDef<T>;
end;

TFMXERStands = record                       // v.1.3: for your own containers
  // like TFrameStand.New<T>, but the frame gets AAlign before entering the stand, so it keeps its
  // design size; configure it, size its slot on it, then Show the returned info
  class function NewSizedFrame<T: TFrame>(const AFrameStand: TFrameStand; const AParent: TFmxObject;
    const AStandName: string; const AAlign: TAlignLayout): TFrameInfo<T>; static;
end;
TFMXERSlots = record                        // v.1.4: the slots of the columns and rows, for your own containers
  const AUTO_SIZE = -1;
  class function AddFrame<T: TFrame>(const AFrameStand: TFrameStand; const AContent: TControl; const AOwner: TComponent;
    const AElements: TList<TSubjectInfoContainer>; const AStandName: string; const AVertical: Boolean;
    const ASlotAlign: TAlignLayout; const ASize: Integer; const AConfigProc: TProc<T>): Single; static;  // returns the slot size
  class function AddForm<T: TForm>(...same, with a TFormStand...): Single; static;
end;
TSubjectInfoContainer = class(TLayout)      // slot of TColumnForm / TRowForm (Elements list)
  function ContainedFrame<T: TFrame>: T;    // nil when the slot holds a form
  function ContainedForm<T: TForm>: T;
  property SubjectInfo: TSubjectInfo;
end;

TFMXERFormHelper = class helper for TCommonCustomForm
  function SetPadding(const APadding: Single): TCommonCustomForm; overload;
  function SetPadding<T: TCommonCustomForm>(const APadding: Single): T; overload;
  function SetWidth(const AWidth: Integer): TCommonCustomForm; overload;
  function SetHeight(const AHeight: Integer): TCommonCustomForm; overload;
end;

TFMXERFrameHelper = class helper for TControl  // all return TControl, except the generic overloads
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
  function SetAlignRight: TControl;  function SetAlignLeft: TControl;  function SetAlignTop: TControl;
  function SetAlignBottom: TControl; function SetAlignClient: TControl; function SetAlignContents: TControl;
  function SetHitTest(const AHitTest: Boolean): TControl;
  function SetWidth(const AWidth: Single): TControl;
  function SetHeight(const AHeight: Single): TControl;
end;

TCaptionPosition = (Left, Right, Top, Bottom);
function Param(const AName: string; const AValue: TValue): TNameValueParam; overload;
function Param(const AName: string; const AValue: TProc): TNameValueParam; overload;
function Param(const AName: string; const AValue: TFunc<Boolean>): TNameValueParam; overload;
function OnClickProc(const AValue: TProc): TNameValueParam; overload;   // = Param('OnClickProc', AValue)
var LocalFilesPath: string;  // folder of LocalFile; default: ..\..\..\..\media\ on Windows (demos), Documents elsewhere
function LocalFile(const AFileName: string): string;                    // TPath.Combine(LocalFilesPath, AFileName)
```

Delphi applies one class helper per class: a project helper for `TControl` closer in scope hides `TFMXERFrameHelper`.

## TAppColors

```pascal
// unit FMXER.UI.Consts — read by the elements when they are created
TAppColors = class
  class property PrimaryColor: TAlphaColor;          // MATERIAL_AMBER_800 ($FFff8f00)
  class property PrimaryTextColor: TAlphaColor;      // white
  class property SolidBackgroundColor: TAlphaColor;  // light gray (chips)
  class property LightBackgroundColor: TAlphaColor;  // silver (card content)
  class property DividerColor: TAlphaColor;          // MATERIAL_GREY_800
  const MATERIAL_RED_400 ... MATERIAL_BLUE_GREY_400; // 19 hues at 400
  const MATERIAL_RED_800 ... MATERIAL_BLUE_GREY_800; // and at 800: RED, PINK, PURPLE, DEEP_PURPLE, INDIGO, BLUE,
                                                     // LIGHT_BLUE, CYAN, TEAL, GREEN, LIGHT_GREEN, LIME, YELLOW,
                                                     // AMBER, ORANGE, DEEP_ORANGE, BROWN, GREY, BLUE_GREY
end;
```
