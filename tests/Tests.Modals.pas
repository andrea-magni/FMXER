unit Tests.Modals;

// Dialogs and bottom sheets: TModals (Alert, Confirm, Choose, ShowDialog,
// ShowBottomSheet), Back and the dimmed background.

interface

uses
  System.SysUtils, System.Classes, System.UITypes, System.Math, DUnitX.TestFramework
, FMX.Types, FMX.Forms, FMX.Controls
, FormStand, FrameStand
, FMXER.Navigator, FMXER.Modals, FMXER.AlertFrame, FMXER.ChoicesFrame, FMXER.TextFrame
, FMXER.ContainerForm
, Tests.Common
;

type
  [TestFixture]
  TModalsFixture = class
  private
    FMain: TForm;
    function TopFrame<T: TFrame>: T;
    function Back: Boolean;
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;

    [Test] procedure AlertOkCallsThen;
    [Test] procedure ConfirmOk;
    [Test] procedure ConfirmCancelledByBack;
    [Test] procedure ConfirmCancelledByTheBackground;
    [Test] procedure ChooseReturnsTheIndex;
    [Test] procedure ChooseDismissed;
    [Test] procedure ShowDialogSizesTheCard;
    [Test] procedure ShowBottomSheetSizesTheSheet;
    [Test] procedure BackGoesToTheRoutesWhenNoDialogIsOpen;
  end;

implementation

{ TModalsFixture }

procedure TModalsFixture.Setup;
begin
  TNavigatorAccess.Reset;
  FMain := TForm.CreateNew(nil);
  FMain.Width := 400;
  FMain.Height := 640;
  Navigator(TFormStand.Create(FMain));
end;

procedure TModalsFixture.TearDown;
begin
  // the dialogs first: they are in a layout of the form
  TModals.ReleaseInstance;
  TNavigatorAccess.Reset;
  FreeAndNil(FMain);
  Pump(50);
end;

function TModalsFixture.TopFrame<T>: T;
var
  LFrame: TFrame;
begin
  Result := nil;
  for LFrame in Modals.FrameStand.FrameInfos.Keys do
    if LFrame is T then
      Result := T(LFrame);
  Assert.IsNotNull(Result, 'the dialog frame');
end;

function TModalsFixture.Back: Boolean;
var
  LKey: Word;
  LKeyChar: WideChar;
begin
  LKey := vkHardwareBack;
  LKeyChar := #0;
  Result := Navigator.HandleBackKey(LKey, LKeyChar);
end;

procedure TModalsFixture.AlertOkCallsThen;
begin
  var LDone := False;
  Modals.Alert('Saved', 'The document has been saved.'
  , procedure
    begin
      LDone := True;
    end
  );
  Assert.AreEqual(1, Modals.GetOpenCount);
  var LAlert := TopFrame<TAlertFrame>;
  Assert.AreEqual('Saved', LAlert.TitleLabel.Text);
  Assert.IsFalse(LAlert.CancelLabel.Visible, 'an alert has no Cancel');
  LAlert.OkLabelClick(nil);   // as a tap does
  Pump(1000);
  Assert.IsTrue(LDone, 'AThen called');
  Assert.AreEqual(0, Modals.GetOpenCount);
  Assert.AreEqual<NativeInt>(0, Modals.FrameStand.FrameInfos.Count, 'the dialog is freed');
end;

procedure TModalsFixture.ConfirmOk;
begin
  var LResult := 0;
  Modals.Confirm('Delete?', 'The photo will be deleted.'
  , procedure (AOk: Boolean)
    begin
      LResult := IfThen(AOk, 1, 2);
    end
  , 'Delete');
  var LConfirm := TopFrame<TAlertFrame>;
  Assert.IsTrue(LConfirm.CancelLabel.Visible);
  Assert.AreEqual('Delete', LConfirm.OkLabel.Text);
  LConfirm.OkLabelClick(nil);
  Pump(1000);
  Assert.AreEqual(1, LResult);
end;

procedure TModalsFixture.ConfirmCancelledByBack;
begin
  var LResult := 0;
  Modals.Confirm('Delete?', ''
  , procedure (AOk: Boolean)
    begin
      LResult := IfThen(AOk, 1, 2);
    end
  );
  Assert.IsTrue(Back, 'Back handled by the dialog');
  Pump(1000);
  Assert.AreEqual(2, LResult, 'cancelled');
  Assert.AreEqual(0, Modals.GetOpenCount);
end;

procedure TModalsFixture.ConfirmCancelledByTheBackground;
begin
  var LResult := 0;
  Modals.Confirm('Delete?', ''
  , procedure (AOk: Boolean)
    begin
      LResult := IfThen(AOk, 1, 2);
    end
  );
  Assert.IsTrue(Modals.CancelTop, 'what the background does');
  Pump(1000);
  Assert.AreEqual(2, LResult);
  Assert.IsFalse(Modals.CancelTop, 'nothing left to cancel');
end;

procedure TModalsFixture.ChooseReturnsTheIndex;
begin
  var LChosen := -2;
  Modals.Choose('Share with', ['Mail', 'Messages', 'Copy link']
  , procedure (AIndex: Integer)
    begin
      LChosen := AIndex;
    end
  );
  var LChoices := TopFrame<TChoicesFrame>;
  Assert.AreEqual(3, LChoices.Items.Count);
  Assert.AreEqual('Copy link', LChoices.Items[2].Text);
  LChoices.Items[2].OnClick(LChoices.Items[2]);   // as a tap does
  Pump(1000);
  Assert.AreEqual(2, LChosen);
end;

procedure TModalsFixture.ChooseDismissed;
begin
  var LChosen := -2;
  Modals.Choose('', ['A', 'B']
  , procedure (AIndex: Integer)
    begin
      LChosen := AIndex;
    end
  );
  Assert.IsFalse(TopFrame<TChoicesFrame>.TitleLabel.Visible, 'no title');
  Back;
  Pump(1000);
  Assert.AreEqual(-1, LChosen);
end;

procedure TModalsFixture.ShowDialogSizesTheCard;
begin
  var LResult := mrNone;
  var LInfo := Modals.ShowDialog<TTextFrame>(
    procedure (Text: TTextFrame)
    begin
      Text.SetContent('Custom');
    end
  , procedure (Text: TTextFrame; AResult: TModalResult)
    begin
      LResult := AResult;
    end
  , 300, 200);
  var LCard := LInfo.Stand.FindStyleResource('card') as TControl;
  Assert.AreEqual<Single>(300, LCard.Width);
  Assert.AreEqual<Single>(200, LCard.Height);
  LInfo.ModalResult := mrYes;   // the frame closes itself this way
  Pump(1000);
  Assert.AreEqual(mrYes, LResult);
end;

procedure TModalsFixture.ShowBottomSheetSizesTheSheet;
begin
  var LInfo := Modals.ShowBottomSheet<TTextFrame>(nil, nil, 250);
  var LSheet := LInfo.Stand.FindStyleResource('sheet') as TControl;
  Assert.AreEqual<Single>(250, LSheet.Height);
  Assert.AreEqual(1, Modals.GetOpenCount);
  Modals.CancelTop;
  Pump(1000);
  Assert.AreEqual(0, Modals.GetOpenCount);
end;

procedure TModalsFixture.BackGoesToTheRoutesWhenNoDialogIsOpen;
begin
  Navigator.DefineRoute<TContainerForm>('a').DefineRoute<TContainerForm>('b');
  Navigator.RouteTo('a');
  Navigator.RouteTo('b');
  Modals.Alert('Hello', '');
  Assert.IsTrue(Back);
  Assert.AreEqual('a,b', string.Join(',', Navigator.Breadcrumb), 'Back closed the alert, not the route');
  Pump(1000);
  Assert.IsTrue(Back);
  Assert.AreEqual('a', string.Join(',', Navigator.Breadcrumb));
end;

initialization
  TDUnitX.RegisterTestFixture(TModalsFixture);

end.
