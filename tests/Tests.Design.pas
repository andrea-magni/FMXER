unit Tests.Design;

// ANALYSIS D3 (column and row frames), D4 (navigator instances), D5 (Back/Esc);
// the safe area of the navigator (Android 15+ edge-to-edge, iOS notch).

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls, FMX.Layouts
, SubjectStand, FrameStand, FormStand
, FMXER.Navigator, FMXER.UI.Misc, FMXER.ContainerForm, FMXER.ColumnForm
, FMXER.ColumnFrame, FMXER.RowFrame, FMXER.TextFrame, FMXER.ButtonFrame, FMXER.VertScrollFrame
, FMXER.IconFontsGlyphFrame, FMXER.IconFontsData
, Tests.Common
;

type
  [TestFixture]
  TBackKeyFixture = class
  private
    FMain: TForm;
    FPrevious: string;
    procedure PreviousKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    function Stack: string;
    function Press(const AKey: Word): Word;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure BackPopsTheTopRoute;
    [Test] procedure EscPopsToo;
    [Test] procedure BackOnTheRootIsNotHandled;
    [Test] procedure BackWithATransientRouteIsConsumed;
    [Test] procedure OtherKeysAreNotHandled;
    [Test] procedure CatchBackKeyHooksTheForm;
    [Test] procedure CatchBackKeyOffRestoresTheHandler;
  end;

  [TestFixture]
  TSafeAreaFixture = class
  private
    FMain: TForm;
    FPreviousInsets: TRectF;
    FPreviousCalls: Integer;
    procedure PreviousSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
    procedure ChangeInsets(const AInsets: TRectF);
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure OnByDefault;
    [Test] procedure RoutesInsideTheSafeArea;
    [Test] procedure PreviousHandlerStillCalled;
    [Test] procedure ExplicitDefaultParentKept;
    [Test] procedure OffRestoresTheForm;
    [Test] procedure OffWithRoutesShownRaises;
    [Test] procedure FreedWithTheForm;
  end;

  [TestFixture]
  TNavigatorInstancesFixture = class
  private
    FMain: TForm;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure NavigatorWithAnotherFormStandRaises;
    [Test] procedure NavigatorWithTheSameFormStandIsFine;
    [Test] procedure IndependentInstances;
    [Test] procedure ReleaseInstance;
  end;

  [TestFixture]
  TColumnRowFramesFixture = class
  private
    FMain: TForm;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure ColumnFrameFixedAndAutoHeights;
    [Test] procedure RowFrameFixedAndAutoWidths;
    [Test] procedure ColumnFrameMeasuresItselfInAColumn;
    [Test] procedure ColumnFrameInAScrollBox;
    [Test] procedure ColumnFrameFreesItsElements;
    [Test] procedure BatchUpdateLaysOutAllTheSlots;
    [Test] procedure DocSamples;
  end;

implementation

{ TBackKeyFixture }

procedure TBackKeyFixture.Setup;
var
  LRoute: string;
begin
  FPrevious := '';
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
  Navigator(TFormStand.Create(FMain));
  for LRoute in ['a', 'b', 'c', 't'] do
    Navigator.DefineRoute<TContainerForm>(LRoute);
end;

procedure TBackKeyFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
end;

procedure TBackKeyFixture.PreviousKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  FPrevious := FPrevious + Key.ToString + ';';
end;

function TBackKeyFixture.Stack: string;
begin
  Result := string.Join(',', Navigator.Breadcrumb);
end;

function TBackKeyFixture.Press(const AKey: Word): Word;
var
  LChar: WideChar;
begin
  Result := AKey;
  LChar := #0;
  if Assigned(FMain.OnKeyDown) then
    FMain.OnKeyDown(FMain, Result, LChar, [])
  else
    Navigator.HandleBackKey(Result, LChar);
  Pump(300);
end;

procedure TBackKeyFixture.BackPopsTheTopRoute;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Assert.AreEqual<Word>(0, Press(vkHardwareBack), 'handled: key cleared');
  Assert.AreEqual('a', Stack);
  Assert.IsFalse(Navigator.IsRouteActive('b'));
end;

procedure TBackKeyFixture.EscPopsToo;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.RouteTo('c');
  Press(vkEscape);
  Press(vkEscape);
  Assert.AreEqual('a', Stack);
end;

procedure TBackKeyFixture.BackOnTheRootIsNotHandled;
begin
  Navigator.RouteTo('a');
  Assert.AreEqual<Word>(vkHardwareBack, Press(vkHardwareBack), 'left to the form (Android closes the app)');
  Assert.AreEqual('a', Stack);
end;

procedure TBackKeyFixture.BackWithATransientRouteIsConsumed;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Navigator.RouteTo('t', True);
  Assert.AreEqual<Word>(0, Press(vkHardwareBack), 'consumed');
  Assert.AreEqual('a,b', Stack, 'nothing closed under the wait screen');
  Assert.IsTrue(Navigator.IsRouteActive('t'));
  Navigator.CloseRoute('t');
  Pump(300);
  Press(vkHardwareBack);
  Assert.AreEqual('a', Stack);
end;

procedure TBackKeyFixture.OtherKeysAreNotHandled;
begin
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Assert.AreEqual<Word>(vkReturn, Press(vkReturn));
  Assert.AreEqual('a,b', Stack);
end;

procedure TBackKeyFixture.CatchBackKeyHooksTheForm;
begin
  FMain.OnKeyDown := PreviousKeyDown;
  Navigator.SetCatchBackKey(True);
  Assert.IsTrue(Navigator.CatchBackKey);
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Press(vkHardwareBack);
  Assert.AreEqual('a', Stack, 'popped by the hook');
  Assert.AreEqual('', FPrevious, 'handled keys do not reach the previous handler');
  Press(vkHardwareBack);
  Press(vkReturn);
  Assert.AreEqual(vkHardwareBack.ToString + ';' + vkReturn.ToString + ';', FPrevious,
    'unhandled keys reach the previous handler');
end;

procedure TBackKeyFixture.CatchBackKeyOffRestoresTheHandler;
var
  LHandler: TKeyEvent;
begin
  FMain.OnKeyDown := PreviousKeyDown;
  Navigator.SetCatchBackKey(True).SetCatchBackKey(False);
  Assert.IsFalse(Navigator.CatchBackKey);
  LHandler := PreviousKeyDown;
  Assert.IsTrue(TMethod(FMain.OnKeyDown) = TMethod(LHandler), 'previous handler back');
  // the form freed with the hook installed: the navigator must not free it twice
  Navigator.SetCatchBackKey(True);
  FreeAndNil(FMain);
  Assert.IsFalse(Navigator.CatchBackKey, 'hook gone with its form');
end;

{ TSafeAreaFixture }

procedure TSafeAreaFixture.Setup;
begin
  TNavigatorAccess.Reset;
  FPreviousCalls := 0;
  FPreviousInsets := TRectF.Empty;
  FMain := TForm.CreateNew(nil);
  FMain.SetBounds(0, 0, 400, 800);
end;

procedure TSafeAreaFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
end;

procedure TSafeAreaFixture.PreviousSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
begin
  Inc(FPreviousCalls);
  FPreviousInsets := AInsets;
end;

procedure TSafeAreaFixture.ChangeInsets(const AInsets: TRectF);
begin
  // what FMX does when the system bars change (ISafeAreaContainer.SafeAreaChanged)
  (FMain as ISafeAreaContainer).SafeAreaChanged(AInsets);
  Pump(50);
end;

procedure TSafeAreaFixture.OnByDefault;
begin
  Navigator(TFormStand.Create(FMain));
  Assert.IsTrue(Navigator.SafeArea);
  Assert.IsNotNull(Navigator.SafeAreaLayout);
  Assert.IsTrue(Navigator.SafeAreaLayout.Parent = FMain, 'layout in the form');
  Assert.IsTrue(Navigator.FormStand.DefaultParent = Navigator.SafeAreaLayout, 'default parent of the routes');
end;

procedure TSafeAreaFixture.RoutesInsideTheSafeArea;
begin
  Navigator(TFormStand.Create(FMain)).DefineRoute<TContainerForm>('a');
  Navigator.RouteTo('a');
  Pump(300);
  var LStand := Navigator.ActiveRoutes['a'].Stand;
  Assert.IsTrue(LStand.Parent = Navigator.SafeAreaLayout, 'the route in the safe area layout');

  // status bar 24, navigation bar 16 (Android 15+ edge-to-edge)
  ChangeInsets(RectF(0, 24, 0, 16));
  Assert.AreEqual<Single>(24, Navigator.SafeAreaLayout.Margins.Top);
  Assert.AreEqual<Single>(16, Navigator.SafeAreaLayout.Margins.Bottom);
  var LRect := LStand.AbsoluteRect;
  Assert.AreEqual<Single>(24, LRect.Top, 'below the status bar');
  Assert.AreEqual<Single>(FMain.ClientHeight - 16, LRect.Bottom, 'above the navigation bar');

  // insets gone (e.g. full screen): the whole form again
  ChangeInsets(TRectF.Empty);
  LRect := LStand.AbsoluteRect;
  Assert.AreEqual<Single>(0, LRect.Top);
  Assert.AreEqual<Single>(FMain.ClientHeight, LRect.Bottom);
end;

procedure TSafeAreaFixture.PreviousHandlerStillCalled;
begin
  FMain.OnSafeAreaChanged := PreviousSafeAreaChanged;
  Navigator(TFormStand.Create(FMain));
  ChangeInsets(RectF(0, 30, 0, 20));
  Assert.AreEqual(1, FPreviousCalls);
  Assert.AreEqual<Single>(30, FPreviousInsets.Top);
  Assert.AreEqual<Single>(30, Navigator.SafeAreaLayout.Margins.Top);
end;

procedure TSafeAreaFixture.ExplicitDefaultParentKept;
begin
  var LStand := TFormStand.Create(FMain);
  var LMine := TLayout.Create(FMain);
  LMine.Parent := FMain;
  LStand.DefaultParent := LMine;
  Navigator(LStand);
  Assert.IsTrue(Navigator.SafeArea);
  Assert.IsTrue(LStand.DefaultParent = LMine, 'the parent set by the app is kept');
end;

procedure TSafeAreaFixture.OffRestoresTheForm;
var
  LHandler: TSafeAreaChangedEvent;
begin
  FMain.OnSafeAreaChanged := PreviousSafeAreaChanged;
  Navigator(TFormStand.Create(FMain)).SetSafeArea(False);
  Assert.IsFalse(Navigator.SafeArea);
  Assert.IsNull(Navigator.SafeAreaLayout);
  Assert.IsNull(Navigator.FormStand.DefaultParent, 'default parent back');
  LHandler := PreviousSafeAreaChanged;
  Assert.IsTrue(TMethod(FMain.OnSafeAreaChanged) = TMethod(LHandler), 'previous handler back');
  Assert.AreEqual(0, FMain.ChildrenCount, 'layout removed');
end;

procedure TSafeAreaFixture.OffWithRoutesShownRaises;
begin
  Navigator(TFormStand.Create(FMain)).DefineRoute<TContainerForm>('a');
  Navigator.RouteTo('a');
  Pump(300);
  Assert.WillRaise(
    procedure
    begin
      Navigator.SetSafeArea(False);
    end);
  Assert.IsTrue(Navigator.SafeArea, 'still on');
end;

procedure TSafeAreaFixture.FreedWithTheForm;
begin
  Navigator(TFormStand.Create(FMain));
  FreeAndNil(FMain);
  Assert.IsFalse(Navigator.SafeArea, 'hook gone with its form');
end;

{ TNavigatorInstancesFixture }

procedure TNavigatorInstancesFixture.Setup;
begin
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
end;

procedure TNavigatorInstancesFixture.TearDown;
begin
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
end;

procedure TNavigatorInstancesFixture.NavigatorWithAnotherFormStandRaises;
begin
  Navigator(TFormStand.Create(FMain));
  var LOther := TFormStand.Create(FMain);
  var LRaised := False;
  try
    Navigator(LOther);
  except
    on Exception do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'it used to return the first navigator silently');
end;

procedure TNavigatorInstancesFixture.NavigatorWithTheSameFormStandIsFine;
begin
  var LStand := TFormStand.Create(FMain);
  var LFirst := Navigator(LStand);
  Assert.AreSame(LFirst, Navigator(LStand));
  Assert.AreSame(LFirst, Navigator);
end;

procedure TNavigatorInstancesFixture.IndependentInstances;
begin
  var LMain := Navigator(TFormStand.Create(FMain));
  var LTab := TNavigator.Create(TFormStand.Create(FMain));
  try
    LMain.DefineRoute<TContainerForm>('home');
    LTab.DefineRoute<TContainerForm>('home');
    LTab.DefineRoute<TContainerForm>('detail');
    LMain.RouteTo('home');
    LTab.RouteTo('home');
    LTab.RouteTo('detail');
    Assert.AreEqual('home', string.Join(',', LMain.Breadcrumb));
    Assert.AreEqual('home,detail', string.Join(',', LTab.Breadcrumb));
    Assert.AreNotSame(LMain.ActiveRoutes['home'].Subject, LTab.ActiveRoutes['home'].Subject);
    LTab.StackPop;
    Pump(300);
    Assert.AreEqual('home', string.Join(',', LTab.Breadcrumb));
    Assert.IsFalse(LMain.IsRouteDefined('detail'));
  finally
    LTab.Free;
  end;
end;

procedure TNavigatorInstancesFixture.ReleaseInstance;
begin
  Navigator(TFormStand.Create(FMain));
  Assert.IsTrue(TNavigator.Initialized);
  TNavigator.ReleaseInstance;
  Assert.IsFalse(TNavigator.Initialized);
  Navigator(TFormStand.Create(FMain)); // can be initialized again
  Assert.IsTrue(TNavigator.Initialized);
end;

{ TColumnRowFramesFixture }

procedure TColumnRowFramesFixture.Setup;
begin
  FMain := TForm.CreateNew(nil);
  FMain.Width := 400;
  FMain.Height := 600;
end;

procedure TColumnRowFramesFixture.TearDown;
begin
  FreeAndNil(FMain);
  Pump(50);
end;

procedure TColumnRowFramesFixture.ColumnFrameFixedAndAutoHeights;
var
  LConfig: TProc<TTextFrame>;
begin
  LConfig :=
    procedure (AText: TTextFrame)
    begin
      AText.SetHeight(33);
    end;
  var LCol := TColumnFrame.Create(FMain);
  LCol
  .AddFrame<TTextFrame>(50)
  .AddFrame<TTextFrame>(TColumnFrame.AUTO_HEIGHT)
  .AddFrame<TTextFrame>(TColumnFrame.AUTO_HEIGHT, LConfig);
  Assert.AreEqual<NativeInt>(3, LCol.Elements.Count);
  Assert.AreEqual(Single(50), LCol.Elements[0].Height);
  Assert.AreEqual(Single(80), LCol.Elements[1].Height);
  Assert.AreEqual(Single(33), LCol.Elements[2].Height);
  Assert.AreEqual(Single(50 + 80 + 33), LCol.Height, 'starts at 0, grows with the slots');
end;

procedure TColumnRowFramesFixture.RowFrameFixedAndAutoWidths;
var
  LConfig: TProc<TButtonFrame>;
begin
  LConfig :=
    procedure (AButton: TButtonFrame)
    begin
      AButton.SetWidth(70);
    end;
  var LRow := TRowFrame.Create(FMain);
  LRow
  .SetElementAlign(TAlignLayout.Left)
  .AddFrame<TTextFrame>(100)
  .AddFrame<TButtonFrame>(TRowFrame.AUTO_WIDTH, LConfig);
  Assert.AreEqual(Single(100), LRow.Elements[0].Width);
  Assert.AreEqual(Single(70), LRow.Elements[1].Width);
  Assert.AreEqual(Single(170), LRow.Width);
end;

procedure TColumnRowFramesFixture.ColumnFrameMeasuresItselfInAColumn;
var
  LConfig: TProc<TColumnFrame>;
begin
  LConfig :=
    procedure (AInner: TColumnFrame)
    begin
      AInner.AddFrame<TTextFrame>(40).AddFrame<TTextFrame>(TColumnFrame.AUTO_HEIGHT);
    end;
  var LCol := TColumnForm.Create(FMain);
  LCol.AddFrame<TColumnFrame>(TColumnForm.AUTO_HEIGHT, LConfig);
  Assert.AreEqual(Single(40 + 80), LCol.Elements[0].Height);
end;

procedure TColumnRowFramesFixture.ColumnFrameInAScrollBox;
var
  LConfig: TProc<TColumnFrame>;
begin
  LConfig :=
    procedure (ACol: TColumnFrame)
    begin
      for var I := 1 to 10 do
        ACol.AddFrame<TTextFrame>(50);
    end;
  var LScroll := TVertScrollFrame.Create(FMain);
  LScroll.Parent := FMain;
  LScroll.SetContentAsFrame<TColumnFrame>(LConfig);
  Pump(50);
  for var LInfo in LScroll.FrameStand1.FrameInfos.Values do
    Assert.AreEqual(Single(500), TControl(LInfo.Stand).Height, 'the scroll box scrolls the whole column');
end;

procedure TColumnRowFramesFixture.ColumnFrameFreesItsElements;
var
  LFreed: Boolean;
  LConfig: TProc<TTextFrame>;
begin
  LFreed := False;
  LConfig :=
    procedure (AText: TTextFrame)
    begin
      TDestroySentinel.Create(AText, @LFreed);
    end;
  var LCol := TColumnFrame.Create(nil);
  LCol.AddFrame<TTextFrame>(40, LConfig);
  LCol.Free;
  Pump(100);
  Assert.IsTrue(LFreed);
end;

procedure TColumnRowFramesFixture.BatchUpdateLaysOutAllTheSlots;
var
  LBuild: TProc<TColumnFrame>;
begin
  LBuild :=
    procedure (ACol: TColumnFrame)
    begin
      for var I := 1 to 300 do
        ACol.AddFrame<TTextFrame>(20);
    end;
  var LCol := TColumnFrame.Create(FMain);
  LCol.Align := TAlignLayout.Top; // before the parent: keeps its own height, as in a scroll box
  LCol.Parent := FMain;
  LCol.BatchUpdate(LBuild);
  Assert.AreEqual<NativeInt>(300, LCol.Elements.Count);
  Assert.AreEqual(Single(6000), LCol.Height);
  var LBottom: Single := 0;
  for var LSlot in LCol.Elements do
    if LSlot.BoundsRect.Bottom > LBottom then
      LBottom := LSlot.BoundsRect.Bottom;
  Assert.AreEqual(Single(6000), LBottom, 'every slot in place after the single realign');
  Assert.AreEqual(Single(20 * 299), LCol.Elements[299].Position.Y, 'the last slot is the last one');
end;

procedure TColumnRowFramesFixture.DocSamples;
begin
  var Col := TColumnForm.Create(FMain);
  // docs/elements/containers.md, TColumnFrame and TRowFrame
  Col.AddFrame<TRowFrame>(TColumnForm.AUTO_HEIGHT
  , procedure (Row: TRowFrame)
    begin
      Row
      .AddFrame<TIconFontsGlyphFrame>(48
      , procedure (G: TIconFontsGlyphFrame) begin G.SetIcon(IconFonts.MD.account); end)
      .AddFrame<TTextFrame>(200
      , procedure (T: TTextFrame) begin T.SetContent('Andrea').SetFontColor(TAlphaColorRec.Black); end);
      Row.Height := 48;
    end
  );
  Assert.AreEqual(Single(48), Col.Elements[0].Height);

  // docs/guide/layouts.md, Performance
  var Items: TArray<string> := ['a', 'b', 'c'];
  var LCol := TColumnFrame.Create(FMain);
  LCol.BatchUpdate(
    procedure (C: TColumnFrame)
    begin
      for var LItem in Items do
        C.AddFrame<TRowFrame>(48
        , procedure (Row: TRowFrame)
          begin
            Row
            .AddFrame<TTextFrame>(TRowFrame.AUTO_WIDTH)
            .AddFrame<TButtonFrame>(80);
          end
        );
    end
  );
  Assert.AreEqual<NativeInt>(3, LCol.Elements.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TBackKeyFixture);
  TDUnitX.RegisterTestFixture(TSafeAreaFixture);
  TDUnitX.RegisterTestFixture(TNavigatorInstancesFixture);
  TDUnitX.RegisterTestFixture(TColumnRowFramesFixture);

end.
