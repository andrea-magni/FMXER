unit Routes.Home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  System.DateUtils, System.UITypes, System.StrUtils, System.Math, FMX.Skia
, FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts
, FMXER.ScaffoldForm, FMXER.VertScrollFrame, FMXER.ColumnFrame
, FMXER.TextFrame, FMXER.TrackbarFrame, FMXER.HorzDividerFrame
, FMXER.SwitchFrame, FMXER.CheckBoxFrame, FMXER.RadioGroupFrame
, FMXER.ComboBoxFrame, FMXER.DateEditFrame, FMXER.ProgressBarFrame
, FMXER.IconFontsData, Icons.Utils
;

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
      LUpload: TProgressBarFrame;
      LWorking: TProgressBarFrame;
      LUpdateSummary: TProc;
    begin
      LNotifications := True;
      LTerms := False;
      LSize := 'Medium';
      LCountry := 'Italy';
      LDelivery := IncDay(Today, 7);
      LSummary := nil;
      LUpload := nil;
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
              .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Switch: TSwitchFrame)
                begin
                  Switch
                  .SetText('Notifications')
                  .SetChecked(LNotifications)
                  .SetOnChangeProc(
                    procedure (AChecked: Boolean)
                    begin
                      LNotifications := AChecked;
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<TCheckBoxFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Check: TCheckBoxFrame)
                begin
                  Check
                  .SetText('I accept the terms and conditions')
                  .SetChecked(LTerms)
                  .SetOnChangeProc(
                    procedure (AChecked: Boolean)
                    begin
                      LTerms := AChecked;
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              .AddFrame<TRadioGroupFrame>(TColumnFrame.AUTO_HEIGHT
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
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<TComboBoxFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Combo: TComboBoxFrame)
                begin
                  Combo
                  .SetCaption('Country')
                  .SetItems(['Italy', 'Germany', 'France', 'Spain', 'United Kingdom'])
                  .SetItemIndex(0)
                  .SetOnChangeProc(
                    procedure (AIndex: Integer)
                    begin
                      LCountry := Combo.GetSelectedText;
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
                  .SetOnChangeProc(
                    procedure (ADate: TDate)
                    begin
                      LDelivery := ADate;
                      DateEdit.SetExtraText(IfThen(ADate < Today, 'The date is in the past', ''));
                      LUpdateSummary();
                    end
                  );
                end
              )
              .AddFrame<THorzDividerFrame>(1)
              .AddFrame<TProgressBarFrame>(50
              , procedure (Progress: TProgressBarFrame)
                begin
                  LUpload := Progress;
                  Progress
                  .SetCaption('Upload')
                  .SetValue(30)
                  .SetExtraText('30%');
                end
              )
              // a track bar drives the determinate progress bar above
              .AddFrame<TTrackbarFrame>(40
              , procedure (Track: TTrackbarFrame)
                begin
                  Track
                  .SetMin(0)
                  .SetMax(100)
                  .SetValue(30)
                  .SetOnChangeProc(
                    procedure (AValue: Single)
                    begin
                      if Assigned(LUpload) then
                        LUpload.SetValue(AValue).SetExtraText(Round(AValue).ToString + '%');
                    end
                  );
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
