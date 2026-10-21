unit Routes.Orders;

interface

uses Classes, SysUtils;

procedure DefineOrdersRoute(const ARouteName: string);

implementation

uses
  System.Rtti, FMX.Types, FMX.Skia, FMX.ListView.Appearances
, FMXER.Navigator, FMXER.UI.Consts
, FMXER.ScaffoldForm, FMXER.ListViewFrame, FMXER.TextFrame
, FMXER.IconFontsData, Icons.Utils
, Data.Orders, Data.OrderState
;

function OrderDetail(const AOrder: TOrder): string;
begin
  Result := FormatCurr('#,##0.00', AOrder.Total);
  if AOrder.Paid then
    Result := Result + ' - paid';
end;

procedure DefineOrdersRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('Orders')
      .SetContentAsFrame<TListViewFrame>(
        procedure (List: TListViewFrame)
        begin
          List.ItemAppearance := 'ListItemRightDetail';
          List.ItemBuilderProc :=
            procedure
            var
              LIndex: Integer;
            begin
              for LIndex := 0 to High(Orders) do
                List.AddItem(Orders[LIndex].Customer, OrderDetail(Orders[LIndex]), -1
                , procedure (const AItem: TListViewItem)
                  begin
                    // the index of the order from the item tapped: a variable of
                    // the loop, captured here, would hold the last index for
                    // every item (closures capture variables, not values)
                    var LOrder := AItem.Tag;
                    // the order route gets its argument in its state, and
                    // tells whether the order was saved
                    Navigator.RouteTo<TOrderState>('order'
                    , procedure (State: TOrderState)
                      begin
                        State.Load(LOrder);
                      end
                    , procedure (AResult: TValue)
                      begin
                        // the list refreshes itself (it listens to OrdersChanged)
                        if AResult.IsEmpty then
                          Scaffold.ShowSnackBar('Not saved', 1500)
                        else
                          Scaffold.ShowSnackBar(AResult.AsString + ' saved', 1500);
                      end
                    );
                  end
                ).Tag := LIndex;
            end;
          // built now (ACallNow) and again whenever an order is saved; the
          // list is the owner: it stops listening when the route closes
          OrdersChanged.Listen(List,
            procedure
            begin
              List.RefreshList;
              Scaffold.SetTitle('Orders: ' + UnpaidSummary);
            end, True);
        end
      )
      // the last sync, set by a background task: shown in the main thread
      .SetTitleDetailContentAsFrame<TTextFrame>(
        procedure (Text: TTextFrame)
        begin
          Text
          .SetFontSize(12)
          .SetHorzAlign(TSkTextHorzAlign.Trailing)
          .SetVertAlign(TTextAlign.Trailing);
          Text.TextContent.Margins.Right := 8;
          Text.TextContent.Margins.Bottom := 4;
          LastSync.Listen(Text,
            procedure (ATime: TDateTime)
            begin
              if ATime > 0 then
                Text.SetContent('synced ' + FormatDateTime('hh:nn:ss', ATime));
            end);
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
