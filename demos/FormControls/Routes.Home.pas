unit Routes.Home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  System.DateUtils, System.UITypes, System.Types, System.StrUtils, System.Math, FMX.Skia
, FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts
, FMXER.ScaffoldForm, FMXER.VertScrollFrame, FMXER.ColumnFrame
, FMXER.TextFrame, FMXER.TrackbarFrame, FMXER.HorzDividerFrame
, FMXER.SwitchFrame, FMXER.CheckBoxFrame, FMXER.RadioGroupFrame
, FMXER.ComboBoxFrame, FMXER.DateEditFrame, FMXER.ProgressBarFrame
, FMXER.RowFrame, FMXER.ButtonFrame
, FMXER.IconFontsData, Icons.Utils, FMXER.Observable
;

function NotificationsText(const AOn: Boolean): string;
begin
  Result := IfThen(AOn, 'You will get notifications', 'Notifications are off');
end;

function TermsText(const AAccepted: Boolean): string;
begin
  Result := IfThen(AAccepted, 'Accepted', 'Not accepted yet');
end;

function DeliveryText(const ADate: TDate): string;
begin
  Result := FormatDateTime('dddd, ddddd', ADate);
  if ADate < Today then
    Result := Result + ' - the date is in the past';
end;

// a button with an icon in APosition: a tap tells where the icon is
function IconButton(const AScaffold: TScaffoldForm; const AText: string; const AIcon: TIconEntry;
  const APosition: TButtonIconPosition; const APositionName: string; const AIconSize: Single = 0): TProc<TButtonFrame>;
begin
  Result :=
    procedure (Button: TButtonFrame)
    begin
      Button
      .SetText(AText)
      .SetIcon(AIcon, APosition)
      .SetIconSize(AIconSize)   // 0: the size of the style (16)
      .SetOnClickProc(
        procedure
        begin
          AScaffold.ShowSnackBar(AText + ': icon ' + APositionName, 1500);
        end
      );
      Button.Margins.Rect := TRectF.Create(2, 4, 2, 4);
    end;
end;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    var
      // the state of the screen, shared by the elements through the closures
      LNotifications: Boolean;
      LTerms: Boolean;
      LSize: string;
      LCountry: string;
      LDelivery: TDate;
      LSummary: TTextFrame;
      LUpload: TObservable<Single>;   // bound to a track bar and a progress bar
      LWorking: TProgressBarFrame;
      LUpdateSummary: TProc;
    begin
      LNotifications := True;
      LTerms := False;
      LSize := 'Medium';
      LCountry := 'Italy';
      LDelivery := IncDay(Today, 7);
      LSummary := nil;
      LUpload := TObservable<Single>.Create(Scaffold, 30);   // freed with the scaffold
      LWorking := nil;

      LUpdateSummary :=
        procedure
        begin
          if Assigned(LSummary) then
            LSummary.SetContent(
              Format('Notifications: %s | Terms: %s' + sLineBreak + 'Size: %s | Country: %s | Delivery: %s'
              , [BoolToStr(LNotifications, True), BoolToStr(LTerms, True)
               , LSize, LCountry, DateToStr(LDelivery)])
            );
        end;

      Scaffold
      .SetTitle('Form Controls')
      .SetContentAsFrame<TVertScrollFrame>(
        procedure (Scroll: TVertScrollFrame)
        begin
          Scroll.SetContentAsFrame<TColumnFrame>(
            procedure (Col: TColumnFrame)
            begin
              Col.SetPadding(16, 8, 16, 80); // room for the action button
              Col
              // each control shows the value chosen in its extra text (below it)
              .AddFrame<TSwitchFrame>(70
              , procedure (Switch: TSwitchFrame)
                begin
                  Switch
                  .SetText('Notifications')
                  .SetChecked(LNotifications)
                  .SetExtraText(NotificationsText(LNotifications))
                  .SetOnChangeProc(
                    procedure (AChecked: Boolean)
                    begin
                      LNotifications := AChecked;
                      Switch.SetExtraText(NotificationsText(AChecked));
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<TCheckBoxFrame>(70
              , procedure (Check: TCheckBoxFrame)
                begin
                  Check
                  .SetText('I accept the terms and conditions')
                  .SetChecked(LTerms)
                  .SetExtraText(TermsText(LTerms))
                  .SetOnChangeProc(
                    procedure (AChecked: Boolean)
                    begin
                      LTerms := AChecked;
                      Check.SetExtraText(TermsText(AChecked));
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              .AddFrame<TRadioGroupFrame>(TColumnFrame.AUTO_HEIGHT // caption, options and extra text
              , procedure (Group: TRadioGroupFrame)
                begin
                  Group
                  .SetCaption('Size')
                  .SetOptions(['Small', 'Medium', 'Large'])
                  .SetItemIndex(1)
                  .SetExtraText('Selected: ' + LSize)
                  .SetOnChangeProc(
                    procedure (AIndex: Integer)
                    begin
                      LSize := Group.GetSelectedText;
                      Group.SetExtraText(Format('Selected: %s (option %d)', [LSize, AIndex + 1]));
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<TComboBoxFrame>(80
              , procedure (Combo: TComboBoxFrame)
                begin
                  Combo
                  .SetCaption('Country')
                  .SetItems(['Italy', 'Germany', 'France', 'Spain', 'United Kingdom'])
                  .SetItemIndex(0)
                  .SetExtraText('Selected: ' + LCountry)
                  .SetOnChangeProc(
                    procedure (AIndex: Integer)
                    begin
                      LCountry := Combo.GetSelectedText;
                      Combo.SetExtraText('Selected: ' + LCountry);
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<TDateEditFrame>(80
              , procedure (DateEdit: TDateEditFrame)
                begin
                  DateEdit
                  .SetCaption('Delivery date')
                  .SetDate(LDelivery)
                  .SetExtraText(DeliveryText(LDelivery))
                  .SetOnChangeProc(
                    procedure (ADate: TDate)
                    begin
                      LDelivery := ADate;
                      DateEdit.SetExtraText(DeliveryText(ADate));
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              // the progress bar and the track bar below are bound to the same
              // observable: moving the track bar moves the bar
              .AddFrame<TProgressBarFrame>(50
              , procedure (Progress: TProgressBarFrame)
                begin
                  Progress
                  .SetCaption('Upload')
                  .BindValue(LUpload);                      // one-way
                  LUpload.Listen(Progress,
                    procedure (AValue: Single)
                    begin
                      Progress.SetExtraText(Round(AValue).ToString + '%');
                    end);
                end
              )
              .AddFrame<TTrackbarFrame>(40
              , procedure (Track: TTrackbarFrame)
                begin
                  Track.SetMin(0).SetMax(100).BindValue(LUpload);   // two-way
                end
              )
              .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Switch: TSwitchFrame)
                begin
                  Switch
                  .SetText('Working in the background')
                  .SetChecked(True)
                  .SetOnChangeProc(
                    procedure (AChecked: Boolean)
                    begin
                      if Assigned(LWorking) then
                        LWorking.SetIndeterminate(AChecked).SetValue(IfThen(AChecked, 0, 100));
                    end
                  );
                end
              )
              .AddFrame<TProgressBarFrame>(20
              , procedure (Progress: TProgressBarFrame)
                begin
                  LWorking := Progress;
                  Progress
                  .SetIndeterminate(True)
                  .SetBarColor(TAppColors.MATERIAL_DEEP_ORANGE_400)
                  .SetThickness(4);
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              // buttons with an icon of the icon font: left, right, above, below the text
              .AddFrame<TRowFrame>(72
              , procedure (Row: TRowFrame)
                var
                  LWidth: Integer;
                begin
                  LWidth := Max(80, Trunc((Col.Width - Col.Padding.Left - Col.Padding.Right) / 4));
                  Row
                  .AddFrame<TButtonFrame>(LWidth
                  , IconButton(Scaffold, 'Save', IconFonts.MD.content_save, TButtonIconPosition.Left, 'left'))
                  .AddFrame<TButtonFrame>(LWidth
                  , IconButton(Scaffold, 'Next', IconFonts.MD.arrow_right, TButtonIconPosition.Right, 'right'))
                  .AddFrame<TButtonFrame>(LWidth
                  , IconButton(Scaffold, 'Upload', IconFonts.MD.upload, TButtonIconPosition.Top, 'above', 24))
                  .AddFrame<TButtonFrame>(LWidth
                  , IconButton(Scaffold, 'Download', IconFonts.MD.download, TButtonIconPosition.Bottom, 'below', 24));
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              .AddFrame<TTextFrame>(70
              , procedure (Text: TTextFrame)
                begin
                  LSummary := Text;
                  Text
                  .SetFontColor(TAlphaColorRec.Dimgray)
                  .SetFontSize(14)
                  .SetMaxLines(3)
                  .SetHorzAlign(TSkTextHorzAlign.Leading);
                  LUpdateSummary();
                end
              );
              // the column grows with its slots: add its padding
              Col.Height := Col.Height + Col.Padding.Top + Col.Padding.Bottom;
            end
          );
        end
      )
      .AddActionButton(IconFonts.ImageList, IconFonts.AddIcon(IconFonts.MD.close, TAppColors.PrimaryTextColor)
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );
    end
  );
end;

end.
