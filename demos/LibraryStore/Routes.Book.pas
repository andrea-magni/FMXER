unit Routes.Book;

interface

uses
  Classes, SysUtils, System.Types, System.UITypes, FMX.Types, FMX.ListView.Appearances,
  FMX.Dialogs
, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ListViewFrame, FMXER.BackgroundFrame, FMXER.ActivityBubblesFrame
, FMXER.IconFontsData
;

const
  BOOK_ROUTE_NAME = 'book_single';
  BOOK_ROUTE_TITLE = 'Book';

procedure BookRouteDefinition();

implementation

uses
  Utils.UI
, Data.Remote, Model, Utils.Msg
;

procedure InternalBookRouteDefinition(const ABuilder: TProc<TScaffoldForm, TListViewFrame>);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    BOOK_ROUTE_NAME
  , procedure (SF: TScaffoldForm)
    begin
      SF
      .SetTitle(BOOK_ROUTE_TITLE)
      .SetContentAsFrame<TListViewFrame>(
        procedure (AListFrame: TListViewFrame)
        begin
          AListFrame.ItemAppearance := 'ListItemRightDetail';
          AListFrame.AccessoryVisible := False;
          AListFrame.CanSwipeDelete := False;
          ABuilder(SF, AListFrame);
        end
      )
      .AddActionButton(IconFonts.ImageList, UIUtils.BackImageIndex
      , procedure
        begin
          Navigator.CloseRoute(BOOK_ROUTE_NAME);
        end
      );

    end
  );

end;

procedure BookRouteDefinition();
begin
  InternalBookRouteDefinition(
    procedure(AForm: TScaffoldForm; AFrame: TListViewFrame)
    begin
      AFrame.ItemBuilderProc :=
        procedure
        begin
          RemoteData.RetrieveBook(
            procedure (ABooks: TArray<TBook>)
            begin
              var LBook := ABooks[0];
              AForm
              .SetTitle(LBook.Title);

              var LItem := AFrame.AddItem(
                LBook.Title
              , LBook.Author.Surname + ', ' + LBook.Author.Name
              , UIUtils.BookImageIndex
              , procedure (const AItem: TListViewItem)
                begin
                  ShowMessage(AItem.Tag.ToString);
                end
              );
              LItem.Tag := LBook.id;

            end
          , procedure (AError: string)
            begin
              AFrame.ClearItems;
            end
          );
        end;
    end
  );
end;

end.
