unit Routes.Home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  System.UITypes, FMX.Graphics, FMX.Skia, FrameStand
, FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts, FMXER.Modals
, FMXER.ScaffoldForm, FMXER.ColumnFrame, FMXER.VertScrollFrame
, FMXER.TextFrame, FMXER.ButtonFrame, FMXER.EditFrame, FMXER.SwitchFrame
, FMXER.IconFontsData, Icons.Utils
;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    var
      // a button of the home column that runs AProc
      LButton: TFunc<string, TProc, TProc<TButtonFrame>>;
    begin
      LButton :=
        function (ACaption: string; AProc: TProc): TProc<TButtonFrame>
        begin
          Result :=
            procedure (Button: TButtonFrame)
            begin
              Button
              .SetText(ACaption)
              .SetBackgroundVisible(False)
              .SetOnClickProc(AProc);
            end;
        end;

      Scaffold
      .SetTitle('Dialogs')
      .SetContentAsFrame<TVertScrollFrame>(
        procedure (Scroll: TVertScrollFrame)
        begin
          Scroll.SetContentAsFrame<TColumnFrame>(
            procedure (Col: TColumnFrame)
            begin
              Col.SetPadding(16, 8, 16, 8);
              Col

              // Flutter AlertDialog: a message and OK
              .AddFrame<TButtonFrame>(60, LButton('Alert'
              , procedure
                begin
                  Modals.Alert('Saved', 'The document has been saved.');
                end
              ))

              // a question: OK or Cancel (tap outside, Back and Esc cancel too)
              .AddFrame<TButtonFrame>(60, LButton('Confirm'
              , procedure
                begin
                  Modals.Confirm('Delete the photo?', 'It will be removed from all your devices.'
                  , procedure (AOk: Boolean)
                    begin
                      if AOk then
                        Scaffold.ShowSnackBar('Photo deleted', 1500)
                      else
                        Scaffold.ShowSnackBar('Kept', 1500);
                    end
                  , 'Delete');
                end
              ))

              // Flutter showModalBottomSheet with a list
              .AddFrame<TButtonFrame>(60, LButton('Choose (bottom sheet)'
              , procedure
                begin
                  Modals.Choose('Share with', ['Mail', 'Messages', 'Copy link', 'Save to files']
                  , procedure (AIndex: Integer)
                    begin
                      if AIndex >= 0 then
                        Scaffold.ShowSnackBar('Choice ' + (AIndex + 1).ToString, 1500)
                      else
                        Scaffold.ShowSnackBar('Dismissed', 1500);
                    end
                  );
                end
              ))

              // a dialog of FMXER elements: the OK button sets the result
              .AddFrame<TButtonFrame>(60, LButton('Custom dialog'
              , procedure
                var
                  LDialog: TFrameInfo<TColumnFrame>;
                  LName: string;
                begin
                  LDialog := Modals.ShowDialog<TColumnFrame>(
                    procedure (Content: TColumnFrame)
                    begin
                      Content
                      .AddFrame<TEditFrame>(60
                      , procedure (Edit: TEditFrame)
                        begin
                          Edit
                          .SetCaption('Your name')
                          .SetTextPrompt('Andrea')
                          .OnChangeProc :=
                            procedure (ATracking: Boolean)
                            begin
                              LName := Edit.GetText;
                            end;
                        end
                      )
                      .AddFrame<TButtonFrame>(44
                      , procedure (Button: TButtonFrame)
                        begin
                          Button
                          .SetText('OK')
                          .SetOnClickProc(
                            procedure
                            begin
                              LDialog.ModalResult := mrOk;
                            end
                          );
                        end
                      );
                    end
                  , procedure (Content: TColumnFrame; AResult: TModalResult)
                    begin
                      if (AResult = mrOk) and not LName.IsEmpty then
                        Scaffold.ShowSnackBar('Hello, ' + LName, 1500);
                    end
                  , 300, 150);
                end
              ))

              // a bottom sheet of FMXER elements
              .AddFrame<TButtonFrame>(60, LButton('Custom bottom sheet'
              , procedure
                begin
                  Modals.ShowBottomSheet<TColumnFrame>(
                    procedure (Content: TColumnFrame)
                    begin
                      Content
                      .AddFrame<TTextFrame>(40
                      , procedure (Text: TTextFrame)
                        begin
                          Text
                          .SetContent('Quick settings')
                          .SetFontColor(TAlphaColorRec.Dimgray)
                          .SetFontWeight(TFontWeight.Semibold)
                          .SetHorzAlign(TSkTextHorzAlign.Leading);
                        end
                      )
                      .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
                      , procedure (Switch: TSwitchFrame)
                        begin
                          Switch.SetText('Wi-Fi').SetChecked(True);
                        end
                      )
                      .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
                      , procedure (Switch: TSwitchFrame)
                        begin
                          Switch.SetText('Bluetooth');
                        end
                      );
                    end
                  , nil, 200);
                end
              ));
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
