unit Tests.Bindings;

// The Bind* methods of the elements: two-way for the inputs, one-way for text,
// progress bar and button, BindVisible/BindEnabled for any control; bindings
// removed with the element, observables freed before the element.

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls, FMX.Layouts
, FMXER.Observable, FMXER.UI.Misc
, FMXER.SwitchFrame, FMXER.CheckBoxFrame, FMXER.EditFrame, FMXER.RadioGroupFrame
, FMXER.ComboBoxFrame, FMXER.DateEditFrame, FMXER.TrackbarFrame
, FMXER.ProgressBarFrame, FMXER.TextFrame, FMXER.ButtonFrame
, Tests.Common
;

type
  [TestFixture]
  TBindingsFixture = class
  private
    FMain: TForm;
    FState: TComponent;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure SwitchBindChecked;
    [Test] procedure CheckBoxBindChecked;
    [Test] procedure EditBindText;
    [Test] procedure EditBindTextOnEditEnd;
    [Test] procedure RadioGroupBindItemIndex;
    [Test] procedure ComboBoxBindItemIndex;
    [Test] procedure DateEditBindDate;
    [Test] procedure TrackbarBindValue;
    [Test] procedure ProgressBarBindValue;
    [Test] procedure TextBindContent;
    [Test] procedure ButtonBindEnabled;
    [Test] procedure ControlBindVisibleAndEnabled;
    [Test] procedure BindingRemovedWithTheElement;
    [Test] procedure ObservableFreedBeforeTheElement;
  end;

implementation

{ TBindingsFixture }

procedure TBindingsFixture.Setup;
begin
  FMain := TForm.CreateNew(nil);
  FState := TComponent.Create(nil);
end;

procedure TBindingsFixture.TearDown;
begin
  FreeAndNil(FMain);
  FreeAndNil(FState);
  Pump(50);
end;

procedure TBindingsFixture.SwitchBindChecked;
begin
  var LUserCalls := 0;
  var LNotifications := 0;
  var LPaid := TObservable<Boolean>.Create(FState, True);
  LPaid.Listen(nil, procedure (V: Boolean) begin Inc(LNotifications); end, False);
  var LSwitch := TSwitchFrame.Create(FMain);
  LSwitch.Parent := FMain;
  LSwitch
  .SetOnChangeProc(procedure (AChecked: Boolean) begin Inc(LUserCalls); end)
  .BindChecked(LPaid);
  Assert.IsTrue(LSwitch.GetChecked, 'shows the value at once');

  LPaid.Value := False;
  Assert.IsFalse(LSwitch.GetChecked, 'observable -> switch');
  Assert.AreEqual(1, LNotifications, 'no loop back to the observable');

  LUserCalls := 0;
  LSwitch.TextLabelClick(nil);   // as a tap does
  Assert.IsTrue(LPaid.Value, 'switch -> observable');
  Assert.AreEqual(2, LNotifications);
  Assert.AreEqual(1, LUserCalls, 'OnChangeProc is still called');
end;

procedure TBindingsFixture.CheckBoxBindChecked;
begin
  var LAccepted := TObservable<Boolean>.Create(FState, False);
  var LCheck := TCheckBoxFrame.Create(FMain);
  LCheck.Parent := FMain;
  LCheck.BindChecked(LAccepted);
  LCheck.TextLabelClick(nil);
  Assert.IsTrue(LAccepted.Value);
  LAccepted.Value := False;
  Assert.IsFalse(LCheck.GetChecked);
end;

procedure TBindingsFixture.EditBindText;
begin
  var LUserCalls := 0;
  var LNote := TObservable<string>.Create(FState, 'Hello');
  var LEdit := TEditFrame.Create(FMain);
  LEdit.Parent := FMain;
  LEdit.OnChangeProc := procedure (ATracking: Boolean) begin Inc(LUserCalls); end;
  LEdit.BindText(LNote);
  Assert.AreEqual('Hello', LEdit.GetText);

  LEdit.EditControl.Text := 'Hello!';
  LEdit.EditControlChangeTracking(nil);   // a keystroke
  Assert.AreEqual('Hello!', LNote.Value, 'edit -> observable at every keystroke');
  Assert.IsTrue(LUserCalls > 0, 'OnChangeProc is still called');

  LNote.Value := 'Bye';
  Assert.AreEqual('Bye', LEdit.GetText, 'observable -> edit');
end;

procedure TBindingsFixture.EditBindTextOnEditEnd;
begin
  var LNote := TObservable<string>.Create(FState, '');
  var LEdit := TEditFrame.Create(FMain);
  LEdit.Parent := FMain;
  LEdit.BindText(LNote, True);
  // setting Text from code fires OnChange too: typing changes the text
  // without it, until the edit ends
  var LOnChange := LEdit.EditControl.OnChange;
  LEdit.EditControl.OnChange := nil;
  LEdit.EditControl.Text := 'typing';
  LEdit.EditControl.OnChange := LOnChange;
  LEdit.EditControlChangeTracking(nil);
  Assert.AreEqual('', LNote.Value, 'not while typing');
  LEdit.EditControlChange(nil);   // the edit ends
  Assert.AreEqual('typing', LNote.Value);
end;

procedure TBindingsFixture.RadioGroupBindItemIndex;
begin
  var LSize := TObservable<Integer>.Create(FState, 1);
  var LGroup := TRadioGroupFrame.Create(FMain);
  LGroup.Parent := FMain;
  LGroup.SetOptions(['S', 'M', 'L']).BindItemIndex(LSize);
  Assert.AreEqual(1, LGroup.GetItemIndex);
  LGroup.Buttons[2].IsChecked := True;   // as a tap does
  Assert.AreEqual(2, LSize.Value, 'group -> observable');
  LSize.Value := 0;
  Assert.AreEqual(0, LGroup.GetItemIndex, 'observable -> group');
end;

procedure TBindingsFixture.ComboBoxBindItemIndex;
begin
  var LCountry := TObservable<Integer>.Create(FState, 0);
  var LCombo := TComboBoxFrame.Create(FMain);
  LCombo.Parent := FMain;
  LCombo.SetItems(['IT', 'DE', 'FR']).BindItemIndex(LCountry);
  Assert.AreEqual(0, LCombo.GetItemIndex);
  LCombo.ComboBoxControl.ItemIndex := 2;   // as a choice does
  Assert.AreEqual(2, LCountry.Value);
  LCountry.Value := 1;
  Assert.AreEqual(1, LCombo.GetItemIndex);
end;

procedure TBindingsFixture.DateEditBindDate;
begin
  var LDelivery := TObservable<TDate>.Create(FState, EncodeDate(2026, 10, 21));
  var LDate := TDateEditFrame.Create(FMain);
  LDate.Parent := FMain;
  LDate.BindDate(LDelivery);
  Assert.AreEqual<TDate>(EncodeDate(2026, 10, 21), LDate.GetDate);
  LDate.DateEditControl.Date := EncodeDate(2026, 12, 24);   // as the picker does
  Assert.AreEqual<TDate>(EncodeDate(2026, 12, 24), LDelivery.Value);
  LDelivery.Value := EncodeDate(2027, 1, 1);
  Assert.AreEqual<TDate>(EncodeDate(2027, 1, 1), LDate.GetDate);
end;

procedure TBindingsFixture.TrackbarBindValue;
begin
  var LVolume := TObservable<Single>.Create(FState, 30);
  var LTrack := TTrackbarFrame.Create(FMain);
  LTrack.Parent := FMain;
  LTrack.SetMin(0).SetMax(100).BindValue(LVolume);
  Assert.AreEqual<Single>(30, LTrack.GetValue);
  LTrack.TrackBar1.Value := 60;   // as a drag does
  Assert.AreEqual<Single>(60, LVolume.Value);
  LVolume.Value := 10;
  Assert.AreEqual<Single>(10, LTrack.GetValue);
end;

procedure TBindingsFixture.ProgressBarBindValue;
begin
  var LProgress := TObservable<Single>.Create(FState, 25);
  var LBar := TProgressBarFrame.Create(FMain);
  LBar.Parent := FMain;
  LBar.BindValue(LProgress);
  Assert.AreEqual<Single>(25, LBar.GetValue);
  LProgress.Value := 75;
  Assert.AreEqual<Single>(75, LBar.GetValue);
end;

procedure TBindingsFixture.TextBindContent;
begin
  var LName := TObservable<string>.Create(FState, 'Andrea');
  var LTotal := TObservable<Currency>.Create(FState, 12.5);
  var LText := TTextFrame.Create(FMain);
  LText.Parent := FMain;
  LText.BindContent(LName);
  Assert.AreEqual('Andrea', LText.GetContent);
  LName.Value := 'Magni';
  Assert.AreEqual('Magni', LText.GetContent);

  // a second BindContent replaces the first
  LText.BindContent<Currency>(LTotal,
    function (V: Currency): string
    begin
      Result := 'Total ' + CurrToStr(V);
    end);
  Assert.AreEqual('Total ' + CurrToStr(12.5), LText.GetContent);
  Assert.AreEqual(0, LName.ListenerCount, 'the first binding is gone');
  LName.Value := 'ignored';
  Assert.AreEqual('Total ' + CurrToStr(12.5), LText.GetContent);
  LTotal.Value := 20;
  Assert.AreEqual('Total ' + CurrToStr(20), LText.GetContent);
end;

procedure TBindingsFixture.ButtonBindEnabled;
begin
  var LModified := TObservable<Boolean>.Create(FState, False);
  var LButton := TButtonFrame.Create(FMain);
  LButton.Parent := FMain;
  LButton.SetText('Save').BindEnabled(LModified);
  Assert.IsFalse(LButton.ButtonAction.Enabled);
  LModified.Value := True;
  Assert.IsTrue(LButton.ButtonAction.Enabled);
end;

procedure TBindingsFixture.ControlBindVisibleAndEnabled;
begin
  var LShow := TObservable<Boolean>.Create(FState, False);
  var LOther := TObservable<Boolean>.Create(FState, True);
  var LLayout := TLayout.Create(FMain);
  LLayout.Parent := FMain;
  LLayout.BindVisible(LShow).BindEnabled(LShow);
  Assert.IsFalse(LLayout.Visible);
  Assert.IsFalse(LLayout.Enabled);
  LShow.Value := True;
  Assert.IsTrue(LLayout.Visible);
  Assert.IsTrue(LLayout.Enabled);

  LLayout.BindVisible(LOther);   // replaces the first BindVisible, not BindEnabled
  Assert.AreEqual(1, LShow.ListenerCount, 'BindEnabled only');
  LOther.Value := False;
  Assert.IsFalse(LLayout.Visible);
end;

procedure TBindingsFixture.BindingRemovedWithTheElement;
begin
  var LPaid := TObservable<Boolean>.Create(FState, False);
  var LSwitch := TSwitchFrame.Create(nil);
  LSwitch.Parent := FMain;
  LSwitch.BindChecked(LPaid);
  Assert.AreEqual(1, LPaid.ListenerCount);
  LSwitch.Free;   // its route closed
  Assert.AreEqual(0, LPaid.ListenerCount);
  LPaid.Value := True;   // nothing to update, no access violation
  Assert.Pass;
end;

procedure TBindingsFixture.ObservableFreedBeforeTheElement;
begin
  var LPaid := TObservable<Boolean>.Create(nil, False);
  var LSwitch := TSwitchFrame.Create(FMain);
  LSwitch.Parent := FMain;
  LSwitch.BindChecked(LPaid);
  LPaid.Free;   // the state goes first
  LSwitch.TextLabelClick(nil);   // writes nowhere, no access violation
  Assert.IsTrue(LSwitch.GetChecked);
end;

initialization
  TDUnitX.RegisterTestFixture(TBindingsFixture);

end.
