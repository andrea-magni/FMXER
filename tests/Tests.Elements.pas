unit Tests.Elements;

// Elements and helpers: scaffold, pair, list view, icon fonts, form helpers.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls, FMX.ListView.Appearances
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.ScaffoldForm, FMXER.ActionButtonFrame, FMXER.HorzPairFrame
, FMXER.ListViewFrame, FMXER.IconFontsData, FMXER.CardFrame, FMXER.ContainerForm
, FMXER.LogoFrame, FMXER.ColumnForm
, FMXER.UI.Types, FMXER.ImageFrame, FMXER.SVGFrame, FMXER.AnimatedImageFrame, FMXER.QRCodeFrame
, FMX.Graphics, System.Types, QRCode.Utils
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
    [Test] procedure OneTapHandlerTypeForTheImageElements;
    [Test] procedure SvgToBitmapMarginsAreSymmetric;
    [Test] procedure LocalFileUsesLocalFilesPath;
    [Test] procedure ColumnClosesItsFormElements;
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

procedure TElementsFixture.OneTapHandlerTypeForTheImageElements;
var
  LTaps: Integer;
  LHandler: TOnTapHandler; // FMXER.UI.Types: assignable to every image element
begin
  LTaps := 0;
  LHandler :=
    procedure (AImage: TFMXObject; APoint: TPointF)
    begin
      Inc(LTaps);
    end;
  var LImage := TImageFrame.Create(FMain);
  var LSVG := TSVGFrame.Create(FMain);
  var LAnimated := TAnimatedImageFrame.Create(FMain);
  var LQR := TQRCodeFrame.Create(FMain);
  LImage.OnTapHandler := LHandler;
  LSVG.OnTapHandler := LHandler;
  LAnimated.OnTapHandler := LHandler;
  LQR.OnTapHandler := LHandler;
  LImage.ContentImageTap(nil, PointF(1, 1));
  LSVG.SVGTap(nil, PointF(1, 1));
  LAnimated.ContentImageTap(nil, PointF(1, 1));
  LQR.QRCodeTap(nil, PointF(1, 1));
  Assert.AreEqual(4, LTaps);
end;

procedure TElementsFixture.SvgToBitmapMarginsAreSymmetric;
const
  BLACK_SQUARE = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10">'
    + '<rect width="10" height="10" fill="black"/></svg>';
var
  LInside, LTopLeftMargin, LBottomRightMargin, LNearBottomRight: TAlphaColor;
  LWidth, LHeight: Integer;
  LOnReady: TProc<TBitmap>;
begin
  LOnReady :=
    procedure (ABitmap: TBitmap)
    var
      LData: TBitmapData;
    begin
      LWidth := ABitmap.Width;
      LHeight := ABitmap.Height;
      Assert.IsTrue(ABitmap.Map(TMapAccess.Read, LData));
      try
        LTopLeftMargin := LData.GetPixel(5, 5);
        LInside := LData.GetPixel(15, 15);
        LNearBottomRight := LData.GetPixel(105, 105);
        LBottomRightMargin := LData.GetPixel(114, 114);
      finally
        ABitmap.Unmap(LData);
      end;
    end;
  SvgToBitmap(BLACK_SQUARE, TAlphaColorRec.White, TAlphaColorRec.Black, 100, 100, LOnReady);
  Assert.AreEqual(120, LWidth);
  Assert.AreEqual(120, LHeight);
  Assert.AreEqual(TAlphaColor(TAlphaColorRec.White), LTopLeftMargin, 'left/top margin');
  Assert.AreEqual(TAlphaColor(TAlphaColorRec.Black), LInside, 'code starts at 10');
  Assert.AreEqual(TAlphaColor(TAlphaColorRec.Black), LNearBottomRight, 'code ends at 110');
  Assert.AreEqual(TAlphaColor(TAlphaColorRec.White), LBottomRightMargin, 'right/bottom margin');
end;

procedure TElementsFixture.LocalFileUsesLocalFilesPath;
begin
  var LSaved := LocalFilesPath;
  try
    LocalFilesPath := 'C:' + PathDelim + 'media';
    Assert.AreEqual('C:' + PathDelim + 'media' + PathDelim + 'a.json', LocalFile('a.json'));
  finally
    LocalFilesPath := LSaved;
  end;
  Assert.AreNotEqual('', LocalFilesPath, 'a default is set');
end;

procedure TElementsFixture.ColumnClosesItsFormElements;
var
  LFormFreed, LFrameFreed: Boolean;
  LFormConfig: TProc<TContainerForm>;
  LFrameConfig: TProc<TLogoFrame>;
begin
  LFormFreed := False;
  LFrameFreed := False;
  LFormConfig :=
    procedure (AForm: TContainerForm)
    begin
      TDestroySentinel.Create(AForm, @LFormFreed);
    end;
  LFrameConfig :=
    procedure (AFrame: TLogoFrame)
    begin
      TDestroySentinel.Create(AFrame, @LFrameFreed);
    end;
  var LColumn := TColumnForm.Create(nil);
  LColumn.AddForm<TContainerForm>(50, LFormConfig);
  LColumn.AddFrame<TLogoFrame>(50, LFrameConfig);
  Assert.AreEqual(2, LColumn.Elements.Count);
  LColumn.Free;
  Pump(100);
  Assert.IsTrue(LFormFreed, 'form element freed with the column');
  Assert.IsTrue(LFrameFreed, 'frame element freed with the column');
end;

initialization
  TDUnitX.RegisterTestFixture(TElementsFixture);

end.
