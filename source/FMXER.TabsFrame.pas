unit FMXER.TabsFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Objects, FMX.ImgList, FMX.Ani, System.Skia, FMX.Skia
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, Icons.Utils;

type
  /// <summary>Top: a tab bar above the pages (Flutter TabBar + TabBarView).
  /// Bottom: a navigation bar below them (Flutter NavigationBar).</summary>
  TTabBarPosition = (Top, Bottom);

  /// <summary>One tab: its button in the bar and its page.</summary>
  TTabItem = class
  private
    FButton: TLayout;
    FTextLabel: TSkLabel;
    FGlyph: TGlyph;
    FPage: TSubjectInfoContainer;
    FCodePoint: Integer;
    FIconIndex: Integer;
    FSelectedIconIndex: Integer;
  public
    property Button: TLayout read FButton;
    property TextLabel: TSkLabel read FTextLabel;
    property Glyph: TGlyph read FGlyph;
    /// <summary>The page: its SubjectInfo is the element of the tab.</summary>
    property Page: TSubjectInfoContainer read FPage;
  end;

  /// <summary>Pages of elements switched by a bar of tabs: the selected page is
  /// shown, the others are hidden (all of them are created when added, and keep
  /// their state).</summary>
  TTabsFrame = class(TFrame)
    BarLayout: TLayout;
    BarBackground: TRectangle;
    ButtonsLayout: TLayout;
    Indicator: TRectangle;
    PagesLayout: TLayout;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    procedure BarLayoutResized(Sender: TObject);
  private
    FTabs: TObjectList<TTabItem>;
    FTabIndex: Integer;
    FBarPosition: TTabBarPosition;
    FBarColor: TAlphaColor;
    FTextColor: TAlphaColor;
    FSelectedTextColor: TAlphaColor;
    FIndicatorColor: TAlphaColor;
    FFontSize: Single;
    FPageStand: string;
    FOnChangeProc: TProc<Integer>;
    function NewTab(const ACaption: string; const AIcon: TIconEntry;
      const AHasIcon: Boolean): TTabItem;
    procedure ButtonClick(Sender: TObject);
    procedure SelectTab(const AIndex: Integer; const AAnimate: Boolean);
    procedure UpdateButtons;
    procedure UpdateIcons;
    procedure UpdateColors;
    procedure UpdateIndicator(const AAnimate: Boolean);
    function GetTab(const AIndex: Integer): TTabItem;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function AddTabFrame<T: TFrame>(const ACaption: string;
      const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
    function AddTabFrame<T: TFrame>(const ACaption: string; const AIcon: TIconEntry;
      const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
    function AddTabForm<T: TForm>(const ACaption: string;
      const AConfigProc: TProc<T> = nil): TTabsFrame; overload;
    function AddTabForm<T: TForm>(const ACaption: string; const AIcon: TIconEntry;
      const AConfigProc: TProc<T> = nil): TTabsFrame; overload;

    function GetTabIndex: Integer;
    function GetTabCount: Integer;
    function GetBarPosition: TTabBarPosition;
    function GetBarHeight: Single;
    function GetBarColor: TAlphaColor;
    function GetTextColor: TAlphaColor;
    function GetSelectedTextColor: TAlphaColor;
    function GetIndicatorColor: TAlphaColor;
    function GetFontSize: Single;

    /// <summary>Selects a tab; OnChangeProc is not called.</summary>
    function SetTabIndex(const AIndex: Integer): TTabsFrame;
    /// <summary>Top (default): tab bar in TAppColors.PrimaryColor, indicator
    /// below the selected tab. Bottom: navigation bar in white, the selected tab
    /// in PrimaryColor, no indicator. Resets the colors and the font size: set
    /// them after.</summary>
    function SetBarPosition(const APosition: TTabBarPosition): TTabsFrame;
    function SetBarHeight(const AHeight: Single): TTabsFrame;
    function SetBarColor(const AColor: TAlphaColor): TTabsFrame;
    function SetTextColor(const AColor: TAlphaColor): TTabsFrame;
    function SetSelectedTextColor(const AColor: TAlphaColor): TTabsFrame;
    function SetIndicatorColor(const AColor: TAlphaColor): TTabsFrame;
    function SetFontSize(const ASize: Single): TTabsFrame;
    function SetPageStand(const AStand: string): TTabsFrame;
    function SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TTabsFrame;

    property Tabs[const AIndex: Integer]: TTabItem read GetTab;
    property OnChangeProc: TProc<Integer> read FOnChangeProc write FOnChangeProc;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.IconFontsData;

{ TTabsFrame }

function TTabsFrame.AddTabForm<T>(const ACaption: string;
  const AConfigProc: TProc<T>): TTabsFrame;
var
  LTab: TTabItem;
begin
  Result := Self;
  LTab := NewTab(ACaption, Default(TIconEntry), False);
  LTab.FPage.SubjectInfo := FormStand1.NewAndShow<T>(LTab.FPage, FPageStand, AConfigProc);
end;

function TTabsFrame.AddTabForm<T>(const ACaption: string;
  const AIcon: TIconEntry; const AConfigProc: TProc<T>): TTabsFrame;
var
  LTab: TTabItem;
begin
  Result := Self;
  LTab := NewTab(ACaption, AIcon, True);
  LTab.FPage.SubjectInfo := FormStand1.NewAndShow<T>(LTab.FPage, FPageStand, AConfigProc);
end;

function TTabsFrame.AddTabFrame<T>(const ACaption: string;
  const AConfigProc: TProc<T>): TTabsFrame;
var
  LTab: TTabItem;
begin
  Result := Self;
  LTab := NewTab(ACaption, Default(TIconEntry), False);
  LTab.FPage.SubjectInfo := FrameStand1.NewAndShow<T>(LTab.FPage, FPageStand, AConfigProc);
end;

function TTabsFrame.AddTabFrame<T>(const ACaption: string;
  const AIcon: TIconEntry; const AConfigProc: TProc<T>): TTabsFrame;
var
  LTab: TTabItem;
begin
  Result := Self;
  LTab := NewTab(ACaption, AIcon, True);
  LTab.FPage.SubjectInfo := FrameStand1.NewAndShow<T>(LTab.FPage, FPageStand, AConfigProc);
end;

procedure TTabsFrame.BarLayoutResized(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TTabsFrame.ButtonClick(Sender: TObject);
var
  LIndex: Integer;
begin
  LIndex := (Sender as TFmxObject).Tag;
  if LIndex = FTabIndex then
    Exit;
  SelectTab(LIndex, True);
  if Assigned(FOnChangeProc) then
    FOnChangeProc(LIndex);
end;

constructor TTabsFrame.Create(AOwner: TComponent);
begin
  inherited;
  FTabs := TObjectList<TTabItem>.Create(True);
  FTabIndex := -1;
  SetBarPosition(TTabBarPosition.Top);
end;

destructor TTabsFrame.Destroy;
begin
  FreeAndNil(FTabs);
  inherited;
end;

function TTabsFrame.GetBarColor: TAlphaColor;
begin
  Result := FBarColor;
end;

function TTabsFrame.GetBarHeight: Single;
begin
  Result := BarLayout.Height;
end;

function TTabsFrame.GetBarPosition: TTabBarPosition;
begin
  Result := FBarPosition;
end;

function TTabsFrame.GetIndicatorColor: TAlphaColor;
begin
  Result := FIndicatorColor;
end;

function TTabsFrame.GetSelectedTextColor: TAlphaColor;
begin
  Result := FSelectedTextColor;
end;

function TTabsFrame.GetTab(const AIndex: Integer): TTabItem;
begin
  Result := FTabs[AIndex];
end;

function TTabsFrame.GetTabCount: Integer;
begin
  Result := FTabs.Count;
end;

function TTabsFrame.GetTabIndex: Integer;
begin
  Result := FTabIndex;
end;

function TTabsFrame.GetTextColor: TAlphaColor;
begin
  Result := FTextColor;
end;

function TTabsFrame.NewTab(const ACaption: string; const AIcon: TIconEntry;
  const AHasIcon: Boolean): TTabItem;
begin
  Result := TTabItem.Create;
  FTabs.Add(Result);
  Result.FIconIndex := -1;
  Result.FSelectedIconIndex := -1;

  // the button: an optional icon above the text; the whole button is tappable
  Result.FButton := TLayout.Create(Self);
  Result.FButton.Position.X := MaxInt;   // after the other buttons
  Result.FButton.Parent := ButtonsLayout;
  Result.FButton.Align := TAlignLayout.Left;
  Result.FButton.HitTest := True;
  Result.FButton.Tag := FTabs.Count - 1;
  Result.FButton.OnClick := ButtonClick;

  if AHasIcon then
  begin
    Result.FGlyph := TGlyph.Create(Self);
    Result.FGlyph.Parent := Result.FButton;
    Result.FGlyph.Align := TAlignLayout.Top;
    Result.FGlyph.Height := 26;
    Result.FGlyph.Margins.Top := 6;
    Result.FGlyph.HitTest := False;
    Result.FGlyph.Images := IconFonts.ImageList;
    Result.FCodePoint := AIcon.codepoint;
  end;

  Result.FTextLabel := TSkLabel.Create(Self);
  Result.FTextLabel.Parent := Result.FButton;
  Result.FTextLabel.Align := TAlignLayout.Client;
  Result.FTextLabel.AutoSize := False;
  Result.FTextLabel.HitTest := False;
  Result.FTextLabel.TextSettings.HorzAlign := TSkTextHorzAlign.Center;
  Result.FTextLabel.TextSettings.VertAlign := TTextAlign.Center;
  Result.FTextLabel.TextSettings.MaxLines := 1;
  Result.FTextLabel.TextSettings.Font.Size := FFontSize;
  Result.FTextLabel.Text := ACaption;

  // the page: hidden until selected
  Result.FPage := TSubjectInfoContainer.Create(Self);
  Result.FPage.Parent := PagesLayout;
  Result.FPage.Align := TAlignLayout.Contents;
  Result.FPage.Visible := False;

  UpdateButtons;
  UpdateIcons;
  UpdateColors;
  if FTabIndex < 0 then
    SelectTab(0, False);
end;

procedure TTabsFrame.SelectTab(const AIndex: Integer; const AAnimate: Boolean);
var
  LIndex: Integer;
begin
  if (AIndex < 0) or (AIndex >= FTabs.Count) then
    raise EArgumentOutOfRangeException.CreateFmt('Tab index %d out of range (%d tabs)', [AIndex, FTabs.Count]);
  FTabIndex := AIndex;
  for LIndex := 0 to FTabs.Count - 1 do
    FTabs[LIndex].FPage.Visible := LIndex = FTabIndex;
  UpdateColors;
  UpdateIndicator(AAnimate);
end;

function TTabsFrame.SetBarColor(const AColor: TAlphaColor): TTabsFrame;
begin
  Result := Self;
  FBarColor := AColor;
  UpdateColors;
end;

function TTabsFrame.SetBarHeight(const AHeight: Single): TTabsFrame;
begin
  Result := Self;
  BarLayout.Height := AHeight;
end;

function TTabsFrame.SetBarPosition(const APosition: TTabBarPosition): TTabsFrame;
begin
  Result := Self;
  FBarPosition := APosition;
  case FBarPosition of
    TTabBarPosition.Top:
      begin
        BarLayout.Align := TAlignLayout.Top;
        FBarColor := TAppColors.PrimaryColor;
        FSelectedTextColor := TAppColors.PrimaryTextColor;
        // the text of the other tabs: the same color, a bit transparent
        FTextColor := (TAppColors.PrimaryTextColor and $00FFFFFF) or $B3000000;
        FIndicatorColor := TAppColors.PrimaryTextColor;
        FFontSize := 15;
      end;
    TTabBarPosition.Bottom:
      begin
        BarLayout.Align := TAlignLayout.Bottom;
        FBarColor := TAlphaColorRec.White;
        FSelectedTextColor := TAppColors.PrimaryColor;
        FTextColor := TAlphaColorRec.Gray;
        FIndicatorColor := TAlphaColorRec.Null;
        FFontSize := 12;
      end;
  end;
  if Assigned(FTabs) then
    for var LTab in FTabs do
      LTab.FTextLabel.TextSettings.Font.Size := FFontSize;
  UpdateIcons;
  UpdateColors;
  UpdateIndicator(False);
end;

function TTabsFrame.SetFontSize(const ASize: Single): TTabsFrame;
var
  LTab: TTabItem;
begin
  Result := Self;
  FFontSize := ASize;
  for LTab in FTabs do
    LTab.FTextLabel.TextSettings.Font.Size := FFontSize;
end;

function TTabsFrame.GetFontSize: Single;
begin
  Result := FFontSize;
end;

function TTabsFrame.SetIndicatorColor(const AColor: TAlphaColor): TTabsFrame;
begin
  Result := Self;
  FIndicatorColor := AColor;
  UpdateColors;
end;

function TTabsFrame.SetOnChangeProc(const AOnChangeProc: TProc<Integer>): TTabsFrame;
begin
  Result := Self;
  OnChangeProc := AOnChangeProc;
end;

function TTabsFrame.SetPageStand(const AStand: string): TTabsFrame;
begin
  Result := Self;
  FPageStand := AStand;
end;

function TTabsFrame.SetSelectedTextColor(const AColor: TAlphaColor): TTabsFrame;
begin
  Result := Self;
  FSelectedTextColor := AColor;
  UpdateIcons;
  UpdateColors;
end;

function TTabsFrame.SetTabIndex(const AIndex: Integer): TTabsFrame;
begin
  Result := Self;
  SelectTab(AIndex, False);
end;

function TTabsFrame.SetTextColor(const AColor: TAlphaColor): TTabsFrame;
begin
  Result := Self;
  FTextColor := AColor;
  UpdateIcons;
  UpdateColors;
end;

procedure TTabsFrame.UpdateButtons;
var
  LTab: TTabItem;
begin
  if (FTabs = nil) or (FTabs.Count = 0) then
    Exit;
  // the tabs share the width of the bar
  for LTab in FTabs do
    LTab.FButton.Width := BarLayout.Width / FTabs.Count;
  UpdateIndicator(False);
end;

procedure TTabsFrame.UpdateColors;
var
  LIndex: Integer;
  LTab: TTabItem;
begin
  if FTabs = nil then
    Exit;
  BarBackground.Fill.Color := FBarColor;
  Indicator.Fill.Color := FIndicatorColor;
  for LIndex := 0 to FTabs.Count - 1 do
  begin
    LTab := FTabs[LIndex];
    if LIndex = FTabIndex then
      LTab.FTextLabel.TextSettings.FontColor := FSelectedTextColor
    else
      LTab.FTextLabel.TextSettings.FontColor := FTextColor;
    if Assigned(LTab.FGlyph) then
    begin
      if LIndex = FTabIndex then
        LTab.FGlyph.ImageIndex := LTab.FSelectedIconIndex
      else
        LTab.FGlyph.ImageIndex := LTab.FIconIndex;
    end;
  end;
end;

procedure TTabsFrame.UpdateIcons;
var
  LTab: TTabItem;
begin
  if FTabs = nil then
    Exit;
  // one image per color: the icon font draws the color in the image
  for LTab in FTabs do
    if Assigned(LTab.FGlyph) then
    begin
      LTab.FIconIndex := IconFonts.AddIcon(LTab.FCodePoint, FTextColor);
      LTab.FSelectedIconIndex := IconFonts.AddIcon(LTab.FCodePoint, FSelectedTextColor);
    end;
end;

procedure TTabsFrame.UpdateIndicator(const AAnimate: Boolean);
var
  LX: Single;
begin
  if (FTabs = nil) or (FTabIndex < 0) or (FTabIndex >= FTabs.Count) then
  begin
    Indicator.Visible := False;
    Exit;
  end;
  Indicator.Visible := FBarPosition = TTabBarPosition.Top;
  Indicator.Width := FTabs[FTabIndex].FButton.Width;
  Indicator.Height := 3;
  Indicator.Position.Y := BarLayout.Height - Indicator.Height;
  LX := FTabIndex * Indicator.Width;
  if AAnimate then
    TAnimator.AnimateFloat(Indicator, 'Position.X', LX, 0.2)
  else
    Indicator.Position.X := LX;
end;

end.
