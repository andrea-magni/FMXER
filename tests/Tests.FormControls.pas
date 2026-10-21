unit Tests.FormControls;

// Form controls: switch, check box, radio group, combo box, progress bar, date edit.
// Creating each frame also checks that its .fmx streams (no unknown property).

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Generics.Collections, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls
, FMXER.SwitchFrame, FMXER.CheckBoxFrame, FMXER.RadioGroupFrame
, FMXER.ComboBoxFrame, FMXER.ProgressBarFrame, FMXER.DateEditFrame
, Tests.Common
;

type
  [TestFixture]
  TFormControlsFixture = class
  private
    FMain: TForm;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure SwitchCheckedAndTextTap;
    [Test] procedure CheckBoxCheckedAndTextTap;
    [Test] procedure RadioGroupHeightFollowsOptions;
    [Test] procedure RadioGroupSelection;
    [Test] procedure RadioGroupsAreIndependent;
    [Test] procedure ComboBoxItemsAndSelection;
    [Test] procedure ProgressBarWidthFollowsValue;
    [Test] procedure ProgressBarIndeterminate;
    [Test] procedure DateEditDate;
  end;

implementation

{ TFormControlsFixture }

procedure TFormControlsFixture.Setup;
begin
  FMain := TForm.CreateNew(nil);
  FMain.Width := 400;
  FMain.Height := 600;
end;

procedure TFormControlsFixture.TearDown;
begin
  FreeAndNil(FMain);
  Pump(50);
end;

procedure TFormControlsFixture.SwitchCheckedAndTextTap;
begin
  var LChanges := 0;
  var LLast := False;
  var LSwitch := TSwitchFrame.Create(FMain);
  LSwitch.Parent := FMain;
  LSwitch
  .SetText('Wi-Fi')
  .SetChecked(True)
  .SetOnChangeProc(
    procedure (AChecked: Boolean)
    begin
      Inc(LChanges);
      LLast := AChecked;
    end
  );
  Assert.AreEqual('Wi-Fi', LSwitch.GetText);
  Assert.IsTrue(LSwitch.GetChecked);
  LSwitch.TextLabelClick(nil);
  Assert.IsFalse(LSwitch.GetChecked, 'a tap on the text toggles');
  Assert.AreEqual(1, LChanges);
  Assert.IsFalse(LLast);
  Assert.IsFalse(LSwitch.ExtraLabel.Visible);
  LSwitch.SetExtraText('off');
  Assert.IsTrue(LSwitch.ExtraLabel.Visible);
end;

procedure TFormControlsFixture.CheckBoxCheckedAndTextTap;
begin
  var LChanges := 0;
  var LLast := False;
  var LCheck := TCheckBoxFrame.Create(FMain);
  LCheck.Parent := FMain;
  LCheck
  .SetText('I agree')
  .SetOnChangeProc(
    procedure (AChecked: Boolean)
    begin
      Inc(LChanges);
      LLast := AChecked;
    end
  );
  Assert.IsFalse(LCheck.GetChecked);
  LCheck.TextLabelClick(nil);
  Assert.IsTrue(LCheck.GetChecked, 'a tap on the text toggles');
  Assert.AreEqual(1, LChanges);
  Assert.IsTrue(LLast);
  LCheck.SetChecked(False);
  Assert.IsFalse(LCheck.GetChecked);
end;

procedure TFormControlsFixture.RadioGroupHeightFollowsOptions;
begin
  var LGroup := TRadioGroupFrame.Create(FMain);
  Assert.AreEqual<Single>(0, LGroup.Height, 'no options');
  LGroup.SetOptions(['Small', 'Medium', 'Large']);
  Assert.AreEqual(3, LGroup.GetCount);
  Assert.AreEqual<Single>(3 * 40, LGroup.Height);
  LGroup.SetCaption('Size');
  Assert.AreEqual<Single>(3 * 40 + 24, LGroup.Height, 'caption');
  LGroup.SetItemHeight(30);
  Assert.AreEqual<Single>(3 * 30 + 24, LGroup.Height, 'item height');
  LGroup.SetOptions(['A', 'B']);
  Assert.AreEqual(2, LGroup.GetCount, 'SetOptions replaces the options');
  Assert.AreEqual<Single>(2 * 30 + 24, LGroup.Height);
end;

procedure TFormControlsFixture.RadioGroupSelection;
begin
  var LChanges := TList<Integer>.Create;
  try
    var LGroup := TRadioGroupFrame.Create(FMain);
    LGroup.Parent := FMain;
    LGroup
    .SetOptions(['Small', 'Medium', 'Large'])
    .SetOnChangeProc(
      procedure (AIndex: Integer)
      begin
        LChanges.Add(AIndex);
      end
    );
    Assert.AreEqual(-1, LGroup.GetItemIndex, 'nothing selected');
    Assert.AreEqual('', LGroup.GetSelectedText);

    LGroup.SetItemIndex(1);
    Assert.AreEqual(1, LGroup.GetItemIndex);
    Assert.AreEqual('Medium', LGroup.GetSelectedText);
    Assert.AreEqual(0, LChanges.Count, 'SetItemIndex does not call OnChangeProc');

    LGroup.Buttons[2].IsChecked := True;   // as a tap does
    Assert.AreEqual(2, LGroup.GetItemIndex);
    Assert.IsFalse(LGroup.Buttons[1].IsChecked, 'the group unchecks the others');
    Assert.AreEqual(1, LChanges.Count, 'one call for a new selection');
    Assert.AreEqual(2, LChanges[0]);
  finally
    LChanges.Free;
  end;
end;

procedure TFormControlsFixture.RadioGroupsAreIndependent;
begin
  var LFirst := TRadioGroupFrame.Create(FMain);
  LFirst.Parent := FMain;
  LFirst.SetOptions(['A', 'B']).SetItemIndex(0);
  // no owner: two frames of the same class cannot share an owner with their
  // design name (the stands clear it); the parent frees it
  var LSecond := TRadioGroupFrame.Create(nil);
  LSecond.Parent := FMain;
  LSecond.SetOptions(['C', 'D']).SetItemIndex(1);
  Assert.AreEqual(0, LFirst.GetItemIndex);
  Assert.AreEqual(1, LSecond.GetItemIndex);
end;

procedure TFormControlsFixture.ComboBoxItemsAndSelection;
begin
  var LChanges := 0;
  var LLast := -1;
  var LCombo := TComboBoxFrame.Create(FMain);
  LCombo.Parent := FMain;
  LCombo
  .SetCaption('Country')
  .SetItems(['Italy', 'Germany', 'France'])
  .SetItemIndex(0)
  .SetOnChangeProc(
    procedure (AIndex: Integer)
    begin
      Inc(LChanges);
      LLast := AIndex;
    end
  );
  Assert.AreEqual(3, LCombo.GetCount);
  Assert.AreEqual('Italy', LCombo.GetSelectedText);
  LCombo.SetItemIndex(1);
  Assert.AreEqual(0, LChanges, 'SetItemIndex does not call OnChangeProc');
  LCombo.ComboBoxControl.ItemIndex := 2;   // as a choice in the list does
  Assert.AreEqual(1, LChanges);
  Assert.AreEqual(2, LLast);
  Assert.AreEqual('France', LCombo.GetSelectedText);
  LCombo.AddItem('Spain');
  Assert.AreEqual(4, LCombo.GetCount);
  LCombo.ClearItems;
  Assert.AreEqual(0, LCombo.GetCount);
  Assert.AreEqual('', LCombo.GetSelectedText);
end;

procedure TFormControlsFixture.ProgressBarWidthFollowsValue;
begin
  var LBar := TProgressBarFrame.Create(FMain);
  LBar.Parent := FMain;
  Pump(20);
  var LTrack := LBar.TrackRect.Width;
  Assert.IsTrue(LTrack > 0, 'the track fills the frame');
  LBar.SetValue(25);
  Assert.AreEqual(LTrack / 4, LBar.BarRect.Width, 0.01, '25 of 0..100');
  LBar.SetMax(50);
  Assert.AreEqual(LTrack / 2, LBar.BarRect.Width, 0.01, '25 of 0..50');
  LBar.SetValue(80);
  Assert.AreEqual(LTrack, LBar.BarRect.Width, 0.01, 'clamped to Max');
  LBar.SetThickness(10);
  Assert.AreEqual<Single>(10, LBar.BarRect.Height, 'the bar follows the thickness');
end;

procedure TFormControlsFixture.ProgressBarIndeterminate;
begin
  var LBar := TProgressBarFrame.Create(FMain);
  LBar.Parent := FMain;
  Pump(20);
  LBar.SetIndeterminate(True);
  Assert.IsTrue(LBar.GetIndeterminate);
  Assert.AreEqual(LBar.TrackRect.Width / 3, LBar.BarRect.Width, 0.01);
  LBar.SetIndeterminate(False).SetValue(50);
  Assert.AreEqual<Single>(0, LBar.BarRect.Position.X, 'back at the start');
  Assert.AreEqual(LBar.TrackRect.Width / 2, LBar.BarRect.Width, 0.01);
end;

procedure TFormControlsFixture.DateEditDate;
begin
  var LChanges := 0;
  var LLast: TDate := 0;
  var LDate := TDateEditFrame.Create(FMain);
  LDate.Parent := FMain;
  LDate
  .SetCaption('Birthday')
  .SetDate(EncodeDate(2026, 10, 21))
  .SetOnChangeProc(
    procedure (ADate: TDate)
    begin
      Inc(LChanges);
      LLast := ADate;
    end
  );
  Assert.AreEqual<TDate>(EncodeDate(2026, 10, 21), LDate.GetDate);
  LDate.SetDate(EncodeDate(2026, 12, 25));
  Assert.AreEqual(0, LChanges, 'SetDate does not call OnChangeProc');
  LDate.DateEditControl.Date := EncodeDate(2027, 1, 1);   // as the picker does
  Assert.AreEqual(1, LChanges);
  Assert.AreEqual<TDate>(EncodeDate(2027, 1, 1), LLast);
end;

initialization
  TDUnitX.RegisterTestFixture(TFormControlsFixture);

end.
