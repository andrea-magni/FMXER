# Form Controls

Elements for the choices of a form: on/off values, one option of a few, one item of a list, a date, and a progress bar to show where a task is. They are the FMXER counterparts of the most used Flutter input widgets:

| Flutter | FMXER | FMX control |
|---|---|---|
| `Switch`, `SwitchListTile` | [`TSwitchFrame`](#tswitchframe) | `TSwitch` |
| `Checkbox`, `CheckboxListTile` | [`TCheckBoxFrame`](#tcheckboxframe) | `TCheckBox` |
| `Radio`, `RadioListTile` | [`TRadioGroupFrame`](#tradiogroupframe) | `TRadioButton` |
| `DropdownButton` | [`TComboBoxFrame`](#tcomboboxframe) | `TComboBox` |
| `showDatePicker` | [`TDateEditFrame`](#tdateeditframe) | `TDateEdit` |
| `LinearProgressIndicator` | [`TProgressBarFrame`](#tprogressbarframe) | two `TRectangle`s |

They follow the rules of the [Text & Input](./text-and-input) elements: Skia labels (`TSkLabel`) for their texts, an extra text below (hints, errors) visible only when not empty, `Align = Client`, fluent setters with getters, and an `OnChangeProc` closure (also set by `SetOnChangeProc`) for the changes made by the user. The setters of the value (`SetChecked`, `SetItemIndex`, `SetDate`) do not call `OnChangeProc` for the combo box, the radio group and the date edit; the switch and the check box call it, as their FMX controls do.

The [FormControls demo](/demos/#formcontrols) puts all of them on one screen:

![The FormControls demo](/form-controls-demo.png)

::: info Since v.1.7
The six form controls are new in v.1.7.
:::

## TSwitchFrame

Unit `FMXER.SwitchFrame`. A text with a switch on its right; a tap on the text toggles the switch, like a Flutter `SwitchListTile`. Design height 50.

```pascal
Col.AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
, procedure (Switch: TSwitchFrame)
  begin
    Switch
    .SetText('Notifications')
    .SetChecked(Settings.Notifications)
    .SetOnChangeProc(
      procedure (AChecked: Boolean)
      begin
        Settings.Notifications := AChecked;
      end
    );
  end
);
```

| Setter | Getter | Description |
|---|---|---|
| `SetText(AText)` | `GetText` | the text on the left |
| `SetChecked(Boolean)` | `GetChecked` | |
| `SetExtraText(AText)` | `GetExtraText` | label below |
| `SetOnChangeProc(TProc<Boolean>)` / `OnChangeProc` | | the new state |

Controls: `SwitchControl` (in `SwitchLayout`, on the right), `TextLabel`, `ExtraLabel`. Set `SwitchControl.Enabled := False` to disable it (the text tap follows).

## TCheckBoxFrame

Unit `FMXER.CheckBoxFrame`. A check box with a text on its right; a tap on the text toggles the check box, like a Flutter `CheckboxListTile`. Design height 50.

```pascal
Col.AddFrame<TCheckBoxFrame>(TColumnFrame.AUTO_HEIGHT
, procedure (Check: TCheckBoxFrame)
  begin
    Check
    .SetText('I accept the terms and conditions')
    .SetOnChangeProc(
      procedure (AChecked: Boolean)
      begin
        LAccepted := AChecked;
      end
    );
  end
);
```

| Setter | Getter | Description |
|---|---|---|
| `SetText(AText)` | `GetText` | the text on the right |
| `SetChecked(Boolean)` | `GetChecked` | |
| `SetExtraText(AText)` | `GetExtraText` | label below |
| `SetOnChangeProc(TProc<Boolean>)` / `OnChangeProc` | | the new state |

Controls: `CheckBoxControl`, `TextLabel`, `ExtraLabel`.

## TRadioGroupFrame

Unit `FMXER.RadioGroupFrame`. A caption and one radio button per option, from top to bottom. Each frame is its own group: two radio groups on a screen do not uncheck each other. The frame's `Height` follows the options (caption + options × item height + extra text), so `AUTO_HEIGHT` gives the slot the right size.

```pascal
Col.AddFrame<TRadioGroupFrame>(TColumnFrame.AUTO_HEIGHT
, procedure (Group: TRadioGroupFrame)
  begin
    Group
    .SetCaption('Size')
    .SetOptions(['Small', 'Medium', 'Large'])
    .SetItemIndex(1)
    .SetOnChangeProc(
      procedure (AIndex: Integer)
      begin
        LSize := Group.GetSelectedText;
      end
    );
  end
);
```

| Member | Description |
|---|---|
| `SetCaption(ACaption)` / `GetCaption` | label above (24 high) |
| `SetOptions(TArray<string>)` | replaces the options |
| `AddOption(AText)` | adds one option at the bottom |
| `ClearOptions` | |
| `SetItemIndex(AIndex)` / `GetItemIndex` | the selected option, `-1` for none; `SetItemIndex` does not call `OnChangeProc` |
| `GetSelectedText` | the text of the selected option, `''` for none |
| `GetCount` | number of options |
| `SetItemHeight(AHeight)` / `GetItemHeight` | height of each option (default 40) |
| `SetExtraText(AText)` / `GetExtraText` | label below |
| `SetOnChangeProc(TProc<Integer>)` / `OnChangeProc` | the index of the new selection (once per change) |
| `Buttons: TList<TRadioButton>` | the radio buttons, to style them |

::: tip Size of the slot
`AUTO_HEIGHT` takes the height when the element is added (see [Automatic sizes](/guide/layouts#automatic-sizes)): set the options, the caption and the extra text in the configuration procedure. Options added later make the frame taller, not its slot.
:::

## TComboBoxFrame

Unit `FMXER.ComboBoxFrame`. A drop-down list with a caption above and an extra text below, the counterpart of a Flutter `DropdownButton`. On Android and iOS the list opens as the native picker. Design height 60: caption and a 36 high combo box.

```pascal
Col.AddFrame<TComboBoxFrame>(TColumnFrame.AUTO_HEIGHT
, procedure (Combo: TComboBoxFrame)
  begin
    Combo
    .SetCaption('Country')
    .SetItems(['Italy', 'Germany', 'France'])
    .SetItemIndex(0)
    .SetOnChangeProc(
      procedure (AIndex: Integer)
      begin
        LCountry := Combo.GetSelectedText;
      end
    );
  end
);
```

| Member | Description |
|---|---|
| `SetCaption(ACaption)` / `GetCaption` | label above |
| `SetItems(TArray<string>)` | replaces the items |
| `AddItem(AText)` | adds one item |
| `ClearItems` | |
| `SetItemIndex(AIndex)` / `GetItemIndex` | the selected item, `-1` for none; `SetItemIndex` does not call `OnChangeProc` |
| `GetSelectedText` | the text of the selected item, `''` for none |
| `GetCount` | number of items |
| `SetExtraText(AText)` / `GetExtraText` | label below |
| `SetOnChangeProc(TProc<Integer>)` / `OnChangeProc` | the index chosen by the user |

The combo box is `ComboBoxControl`. With an extra text, give the slot more height (80).

## TDateEditFrame

Unit `FMXER.DateEditFrame`. A date with a caption above and an extra text below: a calendar drop-down on Windows and macOS, the native date picker on Android and iOS (the counterpart of Flutter `showDatePicker`). Design height 60.

```pascal
Col.AddFrame<TDateEditFrame>(80
, procedure (DateEdit: TDateEditFrame)
  begin
    DateEdit
    .SetCaption('Delivery date')
    .SetDate(IncDay(Today, 7))
    .SetOnChangeProc(
      procedure (ADate: TDate)
      begin
        DateEdit.SetExtraText(IfThen(ADate < Today, 'The date is in the past', ''));
      end
    );
  end
);
```

| Setter | Getter | Description |
|---|---|---|
| `SetDate(ADate)` | `GetDate` | does not call `OnChangeProc` |
| `SetFormat(AFormat)` | `GetFormat` | display format (`TDateEdit.Format`), e.g. `'dd mmm yyyy'`; empty: the short date format |
| `SetIsEmpty(Boolean)` | `GetIsEmpty` | no date shown |
| `SetCaption(ACaption)` | `GetCaption` | label above |
| `SetExtraText(AText)` | `GetExtraText` | label below |
| `SetOnChangeProc(TProc<TDate>)` / `OnChangeProc` | | the date chosen by the user |

`Today` and `IncDay` are in `System.DateUtils`, `IfThen` for strings in `System.StrUtils`. The date edit is `DateEditControl`.

## TProgressBarFrame

Unit `FMXER.ProgressBarFrame`. A linear progress bar, the counterpart of a Flutter `LinearProgressIndicator`: a track and a bar drawn with two rounded rectangles, in `TAppColors.LightBackgroundColor` and `TAppColors.PrimaryColor` (read when the frame is created). Determinate (`Value` between `Min` and `Max`) or indeterminate (a bar that runs along the track). Design height 40.

```pascal
Col
.AddFrame<TProgressBarFrame>(50
, procedure (Progress: TProgressBarFrame)
  begin
    LUpload := Progress;
    Progress.SetCaption('Upload').SetMax(LFileSize).SetValue(0);
  end
)
.AddFrame<TProgressBarFrame>(20
, procedure (Progress: TProgressBarFrame)
  begin
    Progress
    .SetIndeterminate(True)          // working, no idea how long
    .SetBarColor(TAppColors.MATERIAL_DEEP_ORANGE_400)
    .SetThickness(4);
  end
);

// later, as the upload goes on
LUpload.SetValue(LSent).SetExtraText(Format('%d of %d KB', [LSent div 1024, LFileSize div 1024]));
```

| Setter | Getter | Description |
|---|---|---|
| `SetValue(AValue)` | `GetValue` | clamped to `Min`..`Max` when drawn |
| `SetMin(AMin)`, `SetMax(AMax)` | `GetMin`, `GetMax` | default 0 and 100 |
| `SetIndeterminate(Boolean)` | `GetIndeterminate` | the bar runs along the track (a looping `TFloatAnimation`) |
| `SetBarColor(AColor)` | `GetBarColor` | |
| `SetTrackColor(AColor)` | `GetTrackColor` | |
| `SetThickness(AThickness)` | `GetThickness` | height of track and bar, rounded ends (default 6) |
| `SetCaption(ACaption)` | `GetCaption` | label above |
| `SetExtraText(AText)` | `GetExtraText` | label below, e.g. the percentage |

Controls: `TrackRect` (vertically centered in `TrackLayout`) with `BarRect` inside, `CaptionLabel`, `ExtraLabel`.

::: tip Circular progress
For a "working" animation without a value, [`TActivityBubblesFrame`](./images-and-media#tactivitybubblesframe) or a Lottie file in [`TAnimatedImageFrame`](./images-and-media#tanimatedimageframe) are the circular alternatives.
:::
