unit Tests.ScaffoldNavigation;

// Navigation inside a screen: tabs (TTabsFrame), the drawer and the bottom
// navigation of the scaffold, the back handlers of the navigator.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls
, FormStand
, FMXER.Navigator, FMXER.UI.Misc, FMXER.TabsFrame, FMXER.ScaffoldForm, FMXER.TextFrame
, FMXER.ContainerForm, FMXER.IconFontsData
, Tests.Common
;

type
  [TestFixture]
  TScaffoldNavigationFixture = class
  private
    FMain: TForm;
    function NewTabs(const ACount: Integer): TTabsFrame;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure TabsShowOnlyTheSelectedPage;
    [Test] procedure TabTapCallsOnChangeProc;
    [Test] procedure TabsShareTheWidthOfTheBar;
    [Test] procedure TabIndexOutOfRangeRaises;
    [Test] procedure TabBarAtTheBottom;
    [Test] procedure TabWithIcon;
    [Test] procedure DrawerOpenAndClose;
    [Test] procedure SecondDrawerRaises;
    [Test] procedure BackClosesTheDrawerFirst;
    [Test] procedure BackHandlersLastAddedFirst;
    [Test] procedure BottomNavigation;
    [Test] procedure SnackBarHidesAndCallsThen;
    [Test] procedure SnackBarFreedWithTheScaffold;
    [Test] procedure SnackBarWithThenFreedWithTheScaffold;
    [Test] procedure DrawerClosingFreedWithTheScaffold;
  end;

implementation

{ TScaffoldNavigationFixture }

procedure TScaffoldNavigationFixture.Setup;
begin
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
  FMain.Width := 400;
  FMain.Height := 600;
  Navigator(TFormStand.Create(FMain));
end;

procedure TScaffoldNavigationFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
  Pump(50);
end;

function TScaffoldNavigationFixture.NewTabs(const ACount: Integer): TTabsFrame;
var
  LIndex: Integer;
begin
  Result := TTabsFrame.Create(FMain);
  Result.Parent := FMain;
  for LIndex := 0 to ACount - 1 do
  begin
    var LText := 'Page ' + IntToStr(LIndex);
    Result.AddTabFrame<TTextFrame>('Tab ' + IntToStr(LIndex)
    , procedure (Text: TTextFrame)
      begin
        Text.SetContent(LText);
      end
    );
  end;
end;

procedure TScaffoldNavigationFixture.TabsShowOnlyTheSelectedPage;
begin
  var LTabs := NewTabs(3);
  Assert.AreEqual(3, LTabs.GetTabCount);
  Assert.AreEqual(0, LTabs.GetTabIndex, 'the first tab is selected');
  Assert.IsTrue(LTabs.Tabs[0].Page.Visible);
  Assert.IsFalse(LTabs.Tabs[1].Page.Visible);
  Assert.AreEqual('Page 1', LTabs.Tabs[1].Page.ContainedFrame<TTextFrame>.GetContent, 'every page is created');

  LTabs.SetTabIndex(2);
  Assert.AreEqual(2, LTabs.GetTabIndex);
  Assert.IsFalse(LTabs.Tabs[0].Page.Visible);
  Assert.IsTrue(LTabs.Tabs[2].Page.Visible);
  Assert.AreEqual(LTabs.GetSelectedTextColor, LTabs.Tabs[2].TextLabel.TextSettings.FontColor);
  Assert.AreEqual(LTabs.GetTextColor, LTabs.Tabs[0].TextLabel.TextSettings.FontColor);
end;

procedure TScaffoldNavigationFixture.TabTapCallsOnChangeProc;
begin
  var LChanges := 0;
  var LLast := -1;
  var LTabs := NewTabs(3);
  LTabs.SetOnChangeProc(
    procedure (AIndex: Integer)
    begin
      Inc(LChanges);
      LLast := AIndex;
    end
  );
  LTabs.SetTabIndex(1);
  Assert.AreEqual(0, LChanges, 'SetTabIndex does not call OnChangeProc');
  LTabs.Tabs[2].Button.OnClick(LTabs.Tabs[2].Button);   // as a tap does
  Assert.AreEqual(1, LChanges);
  Assert.AreEqual(2, LLast);
  Assert.AreEqual(2, LTabs.GetTabIndex);
  LTabs.Tabs[2].Button.OnClick(LTabs.Tabs[2].Button);
  Assert.AreEqual(1, LChanges, 'a tap on the selected tab changes nothing');
end;

procedure TScaffoldNavigationFixture.TabsShareTheWidthOfTheBar;
begin
  var LTabs := NewTabs(4);
  Pump(20);
  var LWidth := LTabs.BarLayout.Width / 4;
  Assert.IsTrue(LWidth > 0);
  Assert.AreEqual(Double(LWidth), Double(LTabs.Tabs[3].Button.Width), 0.01);
  Assert.AreEqual(Double(3 * LWidth), Double(LTabs.Tabs[3].Button.Position.X), 0.01, 'in the order they were added');
  Assert.AreEqual(Double(LWidth), Double(LTabs.Indicator.Width), 0.01);
end;

procedure TScaffoldNavigationFixture.TabIndexOutOfRangeRaises;
begin
  var LTabs := NewTabs(2);
  Assert.WillRaise(
    procedure
    begin
      LTabs.SetTabIndex(2);
    end
  , EArgumentOutOfRangeException);
end;

procedure TScaffoldNavigationFixture.TabBarAtTheBottom;
begin
  var LTabs := NewTabs(2);
  Assert.AreEqual(TAlignLayout.Top, LTabs.BarLayout.Align);
  Assert.IsTrue(LTabs.Indicator.Visible);
  LTabs.SetBarPosition(TTabBarPosition.Bottom);
  Assert.AreEqual(TAlignLayout.Bottom, LTabs.BarLayout.Align);
  Assert.IsFalse(LTabs.Indicator.Visible, 'no indicator in a navigation bar');
  Assert.AreEqual(LTabs.GetSelectedTextColor, LTabs.Tabs[0].TextLabel.TextSettings.FontColor,
    'the colors of the position are applied to the tabs');
end;

procedure TScaffoldNavigationFixture.TabWithIcon;
begin
  var LTabs := TTabsFrame.Create(FMain);
  LTabs.Parent := FMain;
  LTabs
  .AddTabFrame<TTextFrame>('Home', IconFonts.MD.home)
  .AddTabFrame<TTextFrame>('Text only');
  Assert.IsNotNull(LTabs.Tabs[0].Glyph);
  Assert.IsNull(LTabs.Tabs[1].Glyph);
  var LSelected := LTabs.Tabs[0].Glyph.ImageIndex;
  Assert.IsTrue(LSelected >= 0);
  LTabs.SetTabIndex(1);
  Assert.AreNotEqual(LSelected, LTabs.Tabs[0].Glyph.ImageIndex, 'another color, another image');
end;

procedure TScaffoldNavigationFixture.DrawerOpenAndClose;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  Assert.IsNull(LScaffold.MenuButton, 'no drawer, no menu button');
  LScaffold.SetDrawerAsFrame<TTextFrame>(
    procedure (Text: TTextFrame)
    begin
      Text.SetContent('Menu');
    end
  , 300);
  Assert.IsNotNull(LScaffold.MenuButton);
  Assert.AreEqual<Single>(LScaffold.MenuButton.Width, LScaffold.TitleLabel.Margins.Left, 'the title moves right');
  Assert.AreEqual<Single>(300, LScaffold.DrawerPanel.Width);
  Assert.AreEqual<Single>(-300, LScaffold.DrawerPanel.Margins.Left, 'closed: out of the screen');
  Assert.IsFalse(LScaffold.DrawerPanel.ParentControl.Visible);

  LScaffold.MenuButton.OnClick(LScaffold.MenuButton);   // as a tap does
  Assert.IsTrue(LScaffold.DrawerOpen);
  Assert.IsTrue(LScaffold.DrawerPanel.ParentControl.Visible);
  Pump(500);
  Assert.AreEqual(0.0, Double(LScaffold.DrawerPanel.Margins.Left), 0.5, 'slid in');

  LScaffold.CloseDrawer;
  Assert.IsFalse(LScaffold.DrawerOpen);
  Pump(500);
  Assert.AreEqual(-300.0, Double(LScaffold.DrawerPanel.Margins.Left), 0.5, 'slid out');
  Assert.IsFalse(LScaffold.DrawerPanel.ParentControl.Visible, 'hidden after the animation');
end;

procedure TScaffoldNavigationFixture.SecondDrawerRaises;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.SetDrawerAsFrame<TTextFrame>;
  Assert.WillRaise(
    procedure
    begin
      LScaffold.SetDrawerAsFrame<TTextFrame>;
    end
  , Exception);
end;

procedure TScaffoldNavigationFixture.BackClosesTheDrawerFirst;
var
  LKey: Word;
  LKeyChar: WideChar;
begin
  Navigator.DefineRoute<TContainerForm>('a').DefineRoute<TContainerForm>('b');
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.SetDrawerAsFrame<TTextFrame>.OpenDrawer;

  LKey := vkHardwareBack;
  LKeyChar := #0;
  Assert.IsTrue(Navigator.HandleBackKey(LKey, LKeyChar));
  Assert.IsFalse(LScaffold.DrawerOpen, 'Back closed the drawer');
  Assert.AreEqual('a,b', string.Join(',', Navigator.Breadcrumb), 'and no route');
  Assert.AreEqual<Word>(0, LKey, 'the key is consumed');

  LKey := vkHardwareBack;
  Assert.IsTrue(Navigator.HandleBackKey(LKey, LKeyChar));
  Assert.AreEqual('a', string.Join(',', Navigator.Breadcrumb), 'drawer closed: Back closes the route');
end;

procedure TScaffoldNavigationFixture.BackHandlersLastAddedFirst;
var
  LKey: Word;
  LKeyChar: WideChar;
begin
  var LLog := '';
  var LFirst: TFunc<Boolean> :=
    function: Boolean
    begin
      LLog := LLog + '1';
      Result := True;
    end;
  var LSecond: TFunc<Boolean> :=
    function: Boolean
    begin
      LLog := LLog + '2';
      Result := False;   // not mine: the next one
    end;
  Navigator.AddBackHandler(LFirst).AddBackHandler(LSecond);
  LKey := vkEscape;
  LKeyChar := #0;
  Assert.IsTrue(Navigator.HandleBackKey(LKey, LKeyChar));
  Assert.AreEqual('21', LLog);

  Navigator.RemoveBackHandler(LFirst);
  Navigator.RemoveBackHandler(LSecond);
  LLog := '';
  LKey := vkEscape;
  Assert.IsFalse(Navigator.HandleBackKey(LKey, LKeyChar), 'no handler, no route to close');
  Assert.AreEqual('', LLog);
end;

procedure TScaffoldNavigationFixture.BottomNavigation;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.SetBottomNavigation(
    procedure (Tabs: TTabsFrame)
    begin
      Tabs
      .AddTabFrame<TTextFrame>('Home')
      .AddTabFrame<TTextFrame>('Settings');
    end
  );
  Assert.IsNotNull(LScaffold.BottomNavigation);
  Assert.AreEqual(2, LScaffold.BottomNavigation.GetTabCount);
  Assert.AreEqual(TTabBarPosition.Bottom, LScaffold.BottomNavigation.GetBarPosition);
  Assert.AreEqual<TObject>(LScaffold.BottomNavigation, LScaffold.Content, 'the content of the scaffold');
  Assert.AreEqual<Single>(LScaffold.BottomNavigation.GetBarHeight, LScaffold.OverlayLayout.Padding.Bottom,
    'the action buttons above the bar');
end;

procedure TScaffoldNavigationFixture.SnackBarHidesAndCallsThen;
begin
  var LCalled := False;
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.ShowSnackBar('Saved', 200
  , procedure
    begin
      LCalled := True;
    end
  );
  Assert.IsFalse(LCalled);
  Assert.AreEqual('', PumpCatching(1000));
  Assert.IsTrue(LCalled, 'AThen once the snackbar is hidden and closed');
end;

procedure TScaffoldNavigationFixture.SnackBarFreedWithTheScaffold;
begin
  // the route of the scaffold is closed while the snackbar is visible: the
  // pending hide must not run on the freed snackbar
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.ShowSnackBar('Deleted', 200);
  FreeAndNil(LScaffold);
  Assert.AreEqual('', PumpCatching(600));
end;

procedure TScaffoldNavigationFixture.SnackBarWithThenFreedWithTheScaffold;
begin
  var LCalled := False;
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.ShowSnackBar('Deleted', 200
  , procedure
    begin
      LCalled := True;
    end
  );
  FreeAndNil(LScaffold);
  Assert.AreEqual('', PumpCatching(600));
  Assert.IsFalse(LCalled, 'cancelled with the scaffold');
end;

procedure TScaffoldNavigationFixture.DrawerClosingFreedWithTheScaffold;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.SetDrawerAsFrame<TTextFrame>.OpenDrawer;
  LScaffold.CloseDrawer;   // hides the drawer layer after the animation
  FreeAndNil(LScaffold);
  Assert.AreEqual('', PumpCatching(600));
end;

initialization
  TDUnitX.RegisterTestFixture(TScaffoldNavigationFixture);

end.
