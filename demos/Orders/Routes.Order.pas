unit Routes.Order;

interface

uses Classes, SysUtils;

procedure DefineOrderRoute(const ARouteName: string);

implementation

uses
  System.Rtti, System.UITypes, System.StrUtils, FMX.Graphics, FMX.Skia
, FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts
, FMXER.ScaffoldForm, FMXER.ColumnFrame, FMXER.VertScrollFrame, FMXER.BackgroundFrame
, FMXER.TextFrame, FMXER.EditFrame, FMXER.SwitchFrame, FMXER.ButtonFrame
, FMXER.IconFontsData, Icons.Utils
, Data.Orders, Data.OrderState
;

procedure DefineOrderRoute(const ARouteName: string);
begin
  // the route and its state: a TOrderState is created with the route (before
  // the view), initialized by RouteTo<TOrderState>, freed when it closes
  Navigator.DefineRoute<TScaffoldForm, TOrderState>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm; State: TOrderState)
    begin
      Scaffold
      .SetTitle('Order #' + (State.Index + 1).ToString)
      // a background: the route is shown over the list
      .SetContentAsFrame<TBackgroundFrame>(
        procedure (Background: TBackgroundFrame)
        begin
          Background
          .SetFillColor($FFF0F0F0)
          .SetStrokeThickness(0)
          .SetContentAsFrame<TVertScrollFrame>(
            procedure (Scroll: TVertScrollFrame)
            begin
              Scroll.SetContentAsFrame<TColumnFrame>(
                procedure (Col: TColumnFrame)
                begin
                  Col.SetPadding(16, 8, 16, 8);
                  Col
                  .AddFrame<TTextFrame>(50
                  , procedure (Text: TTextFrame)
                    begin
                      Text
                      .SetContent(State.Order.Customer)
                      .SetFontColor(TAlphaColorRec.Dimgray)
                      .SetFontSize(22)
                      .SetFontWeight(TFontWeight.Semibold)
                      .SetHorzAlign(TSkTextHorzAlign.Leading);
                    end
                  )
                  .AddFrame<TTextFrame>(30
                  , procedure (Text: TTextFrame)
                    begin
                      Text
                      .SetContent('Total: ' + FormatCurr('#,##0.00', State.Order.Total))
                      .SetFontColor(TAlphaColorRec.Dimgray)
                      .SetHorzAlign(TSkTextHorzAlign.Leading);
                    end
                  )
                  // the elements edit the state, not the list: Save writes it back
                  .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
                  , procedure (Switch: TSwitchFrame)
                    begin
                      Switch
                      .SetText('Paid')
                      .SetChecked(State.Paid.Value)
                      .SetOnChangeProc(
                        procedure (AChecked: Boolean)
                        begin
                          State.Paid.Value := AChecked;
                        end
                      );
                    end
                  )
                  // listens to the state: updated whenever Paid changes, and
                  // no longer listens when the route is closed (it is the owner)
                  .AddFrame<TTextFrame>(30
                  , procedure (Text: TTextFrame)
                    begin
                      Text
                      .SetFontColor(TAlphaColorRec.Dimgray)
                      .SetHorzAlign(TSkTextHorzAlign.Leading);
                      State.Paid.Listen(Text,
                        procedure (APaid: Boolean)
                        begin
                          Text.SetContent(IfThen(APaid, 'Status: paid', 'Status: to be paid'));
                        end);
                    end
                  )
                  .AddFrame<TEditFrame>(80
                  , procedure (Edit: TEditFrame)
                    begin
                      Edit
                      .SetCaption('Note')
                      .SetText(State.Note.Value)
                      .OnChangeProc :=
                        procedure (ATracking: Boolean)
                        begin
                          State.Note.Value := Edit.GetText;
                        end;
                    end
                  )
                  .AddFrame<TButtonFrame>(60
                  , procedure (Button: TButtonFrame)
                    begin
                      Button
                      .SetText('Save')
                      .SetOnClickProc(
                        procedure
                        begin
                          State.Save;
                          // the result goes to whoever opened the route
                          Navigator.CloseRouteWithResult(ARouteName, State.Order.Customer);
                        end
                      );
                      // enabled only when there is something to save
                      State.Modified.Listen(Button,
                        procedure (AModified: Boolean)
                        begin
                          Button.ButtonAction.Enabled := AModified;
                        end);
                    end
                  );
                end
              );
            end
          );
        end
      )
      // closing without saving: the opener gets an empty result
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
