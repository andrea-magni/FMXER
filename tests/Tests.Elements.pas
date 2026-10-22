unit Tests.Elements;

// Elements and helpers: scaffold, pair, list view, icon fonts, form helpers, button icons.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Actions, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls, FMX.ListView.Appearances, FMX.ImgList, FMX.Objects, FMX.ActnList
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.ScaffoldForm, FMXER.ActionButtonFrame, FMXER.HorzPairFrame
, FMXER.ListViewFrame, FMXER.IconFontsData, FMXER.CardFrame, FMXER.ContainerForm
, FMXER.LogoFrame, FMXER.ColumnForm, FMXER.ButtonFrame, FMXER.UI.Consts
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
    function NewButton: TButtonFrame;
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
    [Test] procedure ButtonIconFromTheIconFont;
    [Test] procedure ButtonIconWithoutTheFont;
    [Test] procedure ButtonIconPositions;
    [Test] procedure ButtonIconSurvivesActionUpdate;
    [Test] procedure ButtonImageAndClearIcon;
  end;

implementation

type
  // access to the cached check, to simulate a machine without the icon font
  TIconFontsAccess = class(TIconFonts);

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

function TElementsFixture.NewButton: TButtonFrame;
begin
  FMain.SetBounds(0, 0, 400, 300);
  // no owner: several buttons in one test (the same component name); freed
  // with the form, their parent
  Result := TButtonFrame.Create(nil);
  Result.Parent := FMain;
  Result.SetText('Save');
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
  Assert.AreEqual<NativeInt>(1, Length(LButtons));
  LButtons[0].ClickableLayoutClick(nil);
  Assert.AreEqual(1, LClicks);
end;

procedure TElementsFixture.ActionButtonWithoutOnClickProc;
begin
  var LScaffold := TScaffoldForm.Create(FMain);
  LScaffold.AddActionButton('A', []);   // raised EInvalidCast in v.1.1
  var LButtons := FindActionButtons(LScaffold);
  Assert.AreEqual<NativeInt>(1, Length(LButtons));
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
  Assert.AreEqual<NativeInt>(1, LCard.FormStand1.FormInfos.Count, 'glyph form');
  Assert.AreEqual<NativeInt>(1, LCard.FrameStand1.FrameInfos.Count, 'content frame');
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
  Assert.AreEqual<NativeInt>(2, LColumn.Elements.Count);
  LColumn.Free;
  Pump(100);
  Assert.IsTrue(LFormFreed, 'form element freed with the column');
  Assert.IsTrue(LFrameFreed, 'frame element freed with the column');
end;

procedure TElementsFixture.ButtonIconFromTheIconFont;
begin
  var LButton := NewButton;
  Assert.AreSame(LButton, LButton.SetIcon(IconFonts.MD.content_save), 'fluent');
  var LIndex := IconFonts.AddIcon(IconFonts.MD.content_save, TAppColors.PrimaryColor);
  Assert.IsTrue(LIndex >= 0, 'the icon font is available to the tests');
  Assert.AreSame(IconFonts.ImageList, LButton.ButtonControl.Images);
  Assert.AreEqual(LIndex, Integer(LButton.ButtonAction.ImageIndex), 'on the action, default color');
  Assert.AreEqual(LIndex, Integer(LButton.ButtonControl.ImageIndex), 'the button takes it from the action');
  // another color: another image; the same icon and color again: the same one
  LButton.SetIcon(IconFonts.MD.content_save, TAlphaColorRec.Red);
  var LRed := Integer(LButton.ButtonAction.ImageIndex);
  Assert.AreNotEqual(LIndex, LRed);
  LButton.SetIcon(IconFonts.MD.content_save, TAlphaColorRec.Red);
  Assert.AreEqual(LRed, Integer(LButton.ButtonAction.ImageIndex));
end;

procedure TElementsFixture.ButtonIconWithoutTheFont;
begin
  var LButton := NewButton;
  var LAccess := TIconFontsAccess(IconFonts);
  LAccess.FFontChecked := True;
  LAccess.FFontAvailable := False;
  try
    // a code point never added before: not in the cache
    LButton.SetIcon(IconFonts.MD.alpha_y_box, TAlphaColorRec.Fuchsia);
    Assert.AreEqual(-1, Integer(LButton.ButtonAction.ImageIndex), 'no icon: only the text');
  finally
    LAccess.FFontChecked := False;   // checked again
  end;
  Assert.AreEqual('Save', LButton.ButtonAction.Text);
end;

procedure TElementsFixture.ButtonIconPositions;
var
  LGlyph: TGlyph;
  LText: TControl;

  procedure Check(const APosition: TButtonIconPosition; const AGlyphAlign, ATextAlign: TAlignLayout;
    const AStretch: Boolean);
  var
    LButton: TButtonFrame;
  begin
    LButton := NewButton;
    LButton.SetIcon(IconFonts.MD.content_save, APosition);
    LButton.ButtonControl.ApplyStyleLookup;
    Assert.AreEqual(APosition, LButton.IconPosition);
    Assert.IsTrue(LButton.ButtonControl.FindStyleResource<TGlyph>('glyphstyle', LGlyph), 'glyph of the style');
    Assert.IsTrue(LButton.ButtonControl.FindStyleResource<TControl>('text', LText), 'text of the style');
    Assert.AreEqual(AGlyphAlign, LGlyph.Align, 'glyph');
    Assert.AreEqual(ATextAlign, LText.Align, 'text');
    Assert.AreEqual(AStretch, LGlyph.Stretch, 'stretch');
  end;

begin
  Check(TButtonIconPosition.Left, TAlignLayout.Left, TAlignLayout.Client, True);
  Check(TButtonIconPosition.Right, TAlignLayout.Right, TAlignLayout.Client, True);
  // above / below the text: the text on one line, the icon at its size in the rest
  Check(TButtonIconPosition.Top, TAlignLayout.Client, TAlignLayout.Bottom, False);
  Check(TButtonIconPosition.Bottom, TAlignLayout.Client, TAlignLayout.Top, False);
  Assert.IsTrue(LText.Height > 0, 'one line of text');

  // the position changes on a button already styled: the style is applied again
  var LButton := NewButton;
  LButton.SetIcon(IconFonts.MD.content_save, TButtonIconPosition.Top);
  LButton.ButtonControl.ApplyStyleLookup;
  LButton.SetIcon(IconFonts.MD.content_save, TButtonIconPosition.Left);
  LButton.ButtonControl.ApplyStyleLookup;
  Assert.IsTrue(LButton.ButtonControl.FindStyleResource<TGlyph>('glyphstyle', LGlyph));
  Assert.AreEqual(TAlignLayout.Left, LGlyph.Align);
  Assert.IsTrue(LGlyph.Stretch);
end;

procedure TElementsFixture.ButtonIconSurvivesActionUpdate;
begin
  var LButton := NewButton;
  LButton.SetIcon(IconFonts.MD.content_save);
  var LIndex := Integer(LButton.ButtonAction.ImageIndex);
  LButton.OnUpdateHandler :=
    procedure (AAction: TAction)
    begin
      AAction.Enabled := False;
      AAction.Text := 'Saving...';
    end;
  LButton.ButtonAction.Update;
  Assert.IsFalse(LButton.ButtonControl.Enabled, 'updated');
  Assert.AreEqual(LIndex, Integer(LButton.ButtonAction.ImageIndex));
  Assert.AreEqual(LIndex, Integer(LButton.ButtonControl.ImageIndex));
end;

procedure TElementsFixture.ButtonImageAndClearIcon;
begin
  var LButton := NewButton;
  var LImages := TImageList.Create(FMain);
  LButton.SetImage(LImages, 3, TButtonIconPosition.Right);
  Assert.AreSame(LImages, LButton.ButtonControl.Images);
  Assert.AreEqual(3, Integer(LButton.ButtonAction.ImageIndex));
  Assert.AreEqual(TButtonIconPosition.Right, LButton.IconPosition);

  Assert.AreSame(LButton, LButton.ClearIcon, 'fluent');
  Assert.IsNull(LButton.ButtonControl.Images);
  Assert.AreEqual(-1, Integer(LButton.ButtonAction.ImageIndex));
  Assert.AreEqual(TButtonIconPosition.Left, LButton.IconPosition);
end;

initialization
  TDUnitX.RegisterTestFixture(TElementsFixture);

end.
