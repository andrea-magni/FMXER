unit Tests.Elements;

// Elements and helpers: scaffold, pair, list view, icon fonts, form helpers.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls, FMX.ListView.Appearances
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.ScaffoldForm, FMXER.ActionButtonFrame, FMXER.HorzPairFrame
, FMXER.ListViewFrame, FMXER.IconFontsData, FMXER.CardFrame, FMXER.ContainerForm
, FMXER.LogoFrame
, Tests.Common
;

type
  [TestFixture]
  TElementsFixture = class
  private
    FMain: TForm;
    function FindActionButtons(const AScaffold: TScaffoldForm): TArray<TActionButtonFrame>;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure FormSetPaddingGeneric;
    [Test] procedure ActionButtonWithParams;
    [Test] procedure ActionButtonWithoutOnClickProc;
    [Test] procedure SnackBarIsClosed;
    [Test] procedure PairStandSetters;
    [Test] procedure CardGlyphAsForm;
    [Test] procedure AddIconReusesImages;
    [Test] procedure ListRefreshDoesNotDuplicate;
    [Test] procedure ListClearItemsDropsHandlers;
  end;

implementation

{ TElementsFixture }

procedure TElementsFixture.Setup;
begin
  FMain := TForm.CreateNew(nil);
end;

procedure TElementsFixture.TearDown;
begin
  FreeAndNil(FMain);
  Pump(50);
end;

function TElementsFixture.FindActionButtons(const AScaffold: TScaffoldForm): TArray<TActionButtonFrame>;

  procedure Collect(const AObject: TFmxObject);
  begin
    if AObject is TActionButtonFrame then
      Result := Result + [TActionButtonFrame(AObject)];
    for var I := 0 to AObject.ChildrenCount - 1 do
      Collect(AObject.Children[I]);
  end;

begin
  Result := [];
  Collect(AScaffold.ActionButtonsLayout);
end;

procedure TElementsFixture.FormSetPaddingGeneric;
begin
  var LForm := TForm.CreateNew(FMain);
  var LResult: TForm := LForm.SetPadding<TForm>(5);
  Assert.AreSame(LForm, LResult);
  Assert.AreEqual(Single(5), LForm.Padding.Left);
  Assert.AreEqual(Single(5), LForm.Padding.Bottom);
end;

procedure TElementsFixture.ActionButtonWithParams;
var
  LClicks: Integer;
begin
  LClicks := 0;
  var LScaffold := TScaffoldForm.Create(FMain);
  var LProc: TProc :=
    procedure
    begin
      Inc(LClicks);
    end;
  LScaffold.AddActionButton('A', [ OnClickProc(LProc) ]);
  var LButtons := FindActionButtons(LScaffold);
  Assert.AreEqual(1, Length(LButtons));
  LButtons[0].ClickableLayoutClick(nil);
  Assert.AreEqual(1, LClicks);
end;

procedure TElementsFixture.ActionButtonWithoutOnClickProc;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.AddActionButton('A', []);   // raised EInvalidCast in v.1.1
  var LButtons := FindActionButtons(LScaffold);
  Assert.AreEqual(1, Length(LButtons));
  LButtons[0].ClickableLayoutClick(nil); // no handler: nothing happens
end;

procedure TElementsFixture.SnackBarIsClosed;
var
  LDone: Boolean;
begin
  LDone := False;
  var LScaffold := TScaffoldForm.Create(FMain);
  var LBefore := LScaffold.FrameStand1.FrameInfos.Count;
  var LThen: TProc :=
    procedure
    begin
      LDone := True;
    end;
  LScaffold.ShowSnackBar('hello', 50, LThen);
  Assert.AreEqual(LBefore + 1, LScaffold.FrameStand1.FrameInfos.Count);
  Pump(2000);
  Assert.IsTrue(LDone, 'AThen called');
  Assert.AreEqual(LBefore, LScaffold.FrameStand1.FrameInfos.Count, 'the snackbar frame is closed');
end;

procedure TElementsFixture.PairStandSetters;
begin
  var LPair := THorzPairFrame.Create(FMain);
  LPair.SetLeftContentStand('left').SetRightContentStand('right');
  Assert.AreEqual('left', LPair.GetLeftContentStand);
  Assert.AreEqual('right', LPair.GetRightContentStand);
end;

procedure TElementsFixture.CardGlyphAsForm;
begin
  var LCard := TCardFrame.Create(FMain);
  LCard.SetGlyphAsForm<TContainerForm>;
  LCard.SetContentAsFrame<TLogoFrame>;
  Assert.AreEqual(1, LCard.FormStand1.FormInfos.Count, 'glyph form');
  Assert.AreEqual(1, LCard.FrameStand1.FrameInfos.Count, 'content frame');
  Assert.IsTrue(LCard.GlyphLayout.Visible);
end;

procedure TElementsFixture.AddIconReusesImages;
begin
  var LFirst := IconFonts.AddIcon(IconFonts.MD.close, TAlphaColorRec.Red);
  var LCount := IconFonts.ImageList.Count;
  for var I := 1 to 10 do
    Assert.AreEqual(LFirst, IconFonts.AddIcon(IconFonts.MD.close, TAlphaColorRec.Red));
  Assert.AreEqual(LCount, IconFonts.ImageList.Count, 'same icon and color: no new image');
  var LOther := IconFonts.AddIcon(IconFonts.MD.close, TAlphaColorRec.Blue);
  Assert.AreNotEqual(LFirst, LOther, 'another color is another image');
  Assert.AreEqual(LCount + 1, IconFonts.ImageList.Count);
  Assert.AreEqual(LOther, IconFonts.AddIcon(IconFonts.MD.close.codepoint, TAlphaColorRec.Blue));
end;

procedure TElementsFixture.ListRefreshDoesNotDuplicate;
var
  LClicked: string;
begin
  LClicked := '';
  var LList := TListViewFrame.Create(FMain);
  LList.ItemBuilderProc :=
    procedure
    begin
      for var LText in ['one', 'two', 'three'] do
        LList.AddItem(LText, '', -1,
          procedure (const AItem: TListViewItem)
          begin
            LClicked := AItem.Text;
          end);
    end;
  Assert.AreEqual(3, LList.ListView.Items.Count);
  LList.ListViewPullRefresh(nil);
  Assert.AreEqual(3, LList.ListView.Items.Count, 'pull to refresh');
  LList.RefreshList;
  Assert.AreEqual(3, LList.ListView.Items.Count, 'RefreshList');
  LList.ListViewItemClick(nil, LList.ListView.Items[1]);
  Assert.AreEqual('two', LClicked, 'items still respond after a refresh');
end;

procedure TElementsFixture.ListClearItemsDropsHandlers;
var
  LCalls: Integer;
begin
  LCalls := 0;
  var LList := TListViewFrame.Create(FMain);
  LList.AddItem('old', '', -1,
    procedure (const AItem: TListViewItem)
    begin
      Inc(LCalls);
    end);
  LList.ClearItems;
  var LNew := LList.AddItem('new');
  LList.ListViewItemClick(nil, LNew);
  Assert.AreEqual(0, LCalls, 'an item without handler calls nothing');
  Assert.AreEqual(1, LList.ListView.Items.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TElementsFixture);

end.
