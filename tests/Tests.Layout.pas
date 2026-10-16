unit Tests.Layout;

// Sizes of the elements (ANALYSIS D1) and the uniform fluent API (D2).

interface

uses
  System.SysUtils, System.Classes, System.Types, System.UITypes, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.UI.Types, FMXER.ColumnForm, FMXER.RowForm, FMXER.VertScrollFrame
, FMXER.HorzScrollFrame, FMXER.TextFrame, FMXER.ButtonFrame, FMXER.ChipFrame
, FMXER.ContainerForm, FMXER.ContainerFrame, FMXER.CardFrame, FMXER.ActionButtonFrame
, FMXER.WebViewFrame, FMXER.LogoFrame, FMXER.ActivityBubblesFrame, FMXER.ImageFrame
, FMXER.BackgroundFrame, FMXER.VertScrollForm
, Tests.Common
;

type
  [TestFixture]
  TLayoutFixture = class
  private
    FMain: TForm;
    function DesignHeight<T: TFrame>: Single;
    function DesignWidth<T: TFrame>: Single;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure ColumnFixedHeight;
    [Test] procedure ColumnAutoHeightFromDesign;
    [Test] procedure ColumnAutoHeightFromConfig;
    [Test] procedure ColumnAutoHeightWithMargins;
    [Test] procedure ColumnAutoHeightOfANestedColumn;
    [Test] procedure RowAutoWidth;
    [Test] procedure VertScrollKeepsTheDesignHeight;
    [Test] procedure VertScrollUsesContentStand;
    [Test] procedure HorzScrollKeepsTheDesignWidth;
    [Test] procedure FluentSetters;
  end;

implementation

const
  BLUE_STAND =
    'object TStyleContainer'#13#10 +
    '  object TLayout'#13#10 +
    '    StyleName = ''blue'''#13#10 +
    '    object TLayout'#13#10 +
    '      StyleName = ''container'''#13#10 +
    '    end'#13#10 +
    '  end'#13#10 +
    'end';

{ TLayoutFixture }

procedure TLayoutFixture.Setup;
begin
  FMain := TForm.CreateNew(nil);
  FMain.Width := 400;
  FMain.Height := 600;
end;

procedure TLayoutFixture.TearDown;
begin
  FreeAndNil(FMain);
  Pump(50);
end;

function TLayoutFixture.DesignHeight<T>: Single;
begin
  var LFrame := T.Create(nil);
  try
    Result := LFrame.Height;
  finally
    LFrame.Free;
  end;
end;

function TLayoutFixture.DesignWidth<T>: Single;
begin
  var LFrame := T.Create(nil);
  try
    Result := LFrame.Width;
  finally
    LFrame.Free;
  end;
end;

procedure TLayoutFixture.ColumnFixedHeight;
begin
  var LCol := TColumnForm.Create(FMain);
  LCol.AddFrame<TTextFrame>(60).AddFrame<TTextFrame>(30);
  Assert.AreEqual(Single(60), LCol.Elements[0].Height);
  Assert.AreEqual(Single(30), LCol.Elements[1].Height);
  Assert.AreEqual(91, LCol.Height, 'starts at 1, grows with the elements');
end;

procedure TLayoutFixture.ColumnAutoHeightFromDesign;
begin
  var LDesign: Single := DesignHeight<TTextFrame>;
  Assert.AreEqual(Single(80), LDesign, 'design height of TTextFrame');
  var LCol := TColumnForm.Create(FMain);
  LCol.AddFrame<TTextFrame>(TColumnForm.AUTO_HEIGHT);
  Pump(50);
  Assert.AreEqual(LDesign, LCol.Elements[0].Height, 'slot');
  Assert.AreEqual(LDesign, LCol.Elements[0].ContainedFrame<TTextFrame>.Height, 'frame');
  Assert.AreEqual(Integer(1 + Round(LDesign)), LCol.Height);
end;

procedure TLayoutFixture.ColumnAutoHeightFromConfig;
var
  LConfig: TProc<TTextFrame>;
begin
  LConfig :=
    procedure (AText: TTextFrame)
    begin
      AText.SetContent('two lines').SetHeight(44);
    end;
  var LCol := TColumnForm.Create(FMain);
  LCol.AddFrame<TTextFrame>(TColumnForm.AUTO_HEIGHT, LConfig);
  Assert.AreEqual(Single(44), LCol.Elements[0].Height);
  Assert.AreEqual(45, LCol.Height);
end;

procedure TLayoutFixture.ColumnAutoHeightWithMargins;
var
  LConfig: TProc<TTextFrame>;
begin
  LConfig :=
    procedure (AText: TTextFrame)
    begin
      AText.SetHeight(40).SetMargin(0, 5, 0, 7);
    end;
  var LCol := TColumnForm.Create(FMain);
  LCol.AddFrame<TTextFrame>(TColumnForm.AUTO_HEIGHT, LConfig);
  Assert.AreEqual(Single(52), LCol.Elements[0].Height, '40 + margins 5 and 7');
end;

procedure TLayoutFixture.ColumnAutoHeightOfANestedColumn;
var
  LConfig: TProc<TColumnForm>;
begin
  LConfig :=
    procedure (AInner: TColumnForm)
    begin
      AInner.AddFrame<TTextFrame>(40).AddFrame<TTextFrame>(TColumnForm.AUTO_HEIGHT);
    end;
  var LCol := TColumnForm.Create(FMain);
  LCol.AddForm<TColumnForm>(TColumnForm.AUTO_HEIGHT, LConfig);
  Assert.AreEqual(Single(1 + 40 + 80), LCol.Elements[0].Height, 'height of the inner column');
end;

procedure TLayoutFixture.RowAutoWidth;
var
  LConfig: TProc<TButtonFrame>;
begin
  LConfig :=
    procedure (AButton: TButtonFrame)
    begin
      AButton.SetText('OK').SetWidth(70);
    end;
  var LDesign: Single := DesignWidth<TTextFrame>;
  var LRow := TRowForm.Create(FMain);
  LRow
  .AddFrame<TTextFrame>(TRowForm.AUTO_WIDTH)
  .AddFrame<TButtonFrame>(TRowForm.AUTO_WIDTH, LConfig);
  Assert.AreEqual(LDesign, LRow.Elements[0].Width, 'design width');
  Assert.AreEqual(Single(70), LRow.Elements[1].Width, 'width set by the configuration');
  Assert.AreEqual(Integer(Round(LDesign) + 70), LRow.Width, 'starts at 0, grows with the elements');
end;

procedure TLayoutFixture.VertScrollKeepsTheDesignHeight;
begin
  var LScroll := TVertScrollFrame.Create(FMain);
  LScroll.Parent := FMain;
  LScroll.SetContentAsFrame<TTextFrame>();
  Pump(50);
  Assert.AreEqual(1, LScroll.FrameStand1.FrameInfos.Count);
  for var LInfo in LScroll.FrameStand1.FrameInfos.Values do
  begin
    Assert.AreEqual(Single(80), LInfo.Frame.Height, 'frame (it was 50: the size of an empty stand)');
    Assert.AreEqual(Single(80), TControl(LInfo.Stand).Height, 'stand');
  end;
end;

procedure TLayoutFixture.VertScrollUsesContentStand;
begin
  var LBook := TStyleBook.Create(FMain);
  var LStream := TStringStream.Create(BLUE_STAND);
  try
    LBook.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
  var LScroll := TVertScrollFrame.Create(FMain);
  LScroll.Parent := FMain;
  LScroll.FrameStand1.StandBook := LBook;
  LScroll.SetContentStand('blue').SetContentAsFrame<TTextFrame>();
  for var LInfo in LScroll.FrameStand1.FrameInfos.Values do
    Assert.AreEqual('blue', LInfo.StandStyleName, 'ContentStand was ignored before v.1.3');
end;

procedure TLayoutFixture.HorzScrollKeepsTheDesignWidth;
begin
  var LScroll := THorzScrollFrame.Create(FMain);
  LScroll.Parent := FMain;
  LScroll.SetTouchHeight(0).SetContentAsFrame<TTextFrame>();
  Pump(50);
  for var LInfo in LScroll.FrameStand1.FrameInfos.Values do
    Assert.AreEqual(Single(320), TControl(LInfo.Stand).Width);
end;

procedure TLayoutFixture.FluentSetters;
var
  LClicks: Integer;
  LClick: TProc;
  LTap: TOnTapHandler;
begin
  LClicks := 0;
  LClick :=
    procedure
    begin
      Inc(LClicks);
    end;
  LTap :=
    procedure (AImage: TFMXObject; APoint: TPointF)
    begin
      Inc(LClicks);
    end;

  var LText := TTextFrame.Create(FMain).SetOnClickProc(LClick);
  var LButton := TButtonFrame.Create(FMain).SetText('OK').SetOnClickProc(LClick);
  var LChip := TChipFrame.Create(FMain).SetText('chip').SetOnClickProc(LClick);
  var LAction := TActionButtonFrame.Create(FMain).SetOverlayAsText('A').SetOnClickProc(LClick);
  var LImage := TImageFrame.Create(FMain).SetOnTapHandler(LTap);
  LText.TextContentClick(nil);
  LButton.ButtonActionExecute(nil);
  LChip.ButtonClick(nil);
  LAction.ClickableLayoutClick(nil);
  LImage.ContentImageTap(nil, PointF(0, 0));
  Assert.AreEqual(5, LClicks, 'one click per element');

  var LCard := TCardFrame.Create(FMain)
    .SetTitle('Title')
    .SetContentStand('')
    .SetContentAsFrame<TLogoFrame>()
    .SetGlyphAsFrame<TLogoFrame>();
  Assert.AreEqual('Title', LCard.Title);

  var LBubbles := TActivityBubblesFrame.Create(FMain).SetText('Loading');
  Assert.AreEqual('Loading', LBubbles.Text);

  var LContainer := TContainerForm.Create(FMain).SetContentStand('').SetContentAsFrame<TLogoFrame>();
  Assert.IsNotNull(LContainer.Content);

  var LVert := TVertScrollForm.Create(FMain).SetTouchWidth(12);
  Assert.AreEqual(Single(12), LVert.TouchWidth);

  var LRow := TRowForm.Create(FMain).SetElementStand('fadeIn').SetElementAlign(TAlignLayout.Right);
  Assert.AreEqual('fadeIn', LRow.ElementStand);
  Assert.AreEqual(TAlignLayout.Right, LRow.ElementAlign);
  Assert.AreEqual('x', TColumnForm.Create(FMain).SetElementStand('x').ElementStand);
  Assert.AreEqual('y', TBackgroundFrame.Create(FMain).SetContentStand('y').ContentStand);
  Assert.AreEqual('z', TContainerFrame.Create(FMain).SetContentStand('z').ContentStand);
end;

initialization
  TDUnitX.RegisterTestFixture(TLayoutFixture);

end.
