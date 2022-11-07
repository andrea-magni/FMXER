unit Routes.Books;

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
  BOOKS_ROUTE_NAME = 'books';
  BOOKS_ROUTE_TITLE = 'Books';

procedure BooksAllRouteDefinition();
procedure BooksByAuthorRouteDefinition();


implementation

uses
  Utils.UI
, Data.Remote, Model, Utils.Msg
;

procedure BooksRouteDefinition(const ARouteName: string;
  const ABuilder: TProc<TScaffoldForm, TListViewFrame>);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (SF: TScaffoldForm)
    begin
      SF
      .SetTitle(BOOKS_ROUTE_TITLE)
      .SetTitleDetailContentAsFrame<TBackgroundFrame>(
        procedure (BF: TBackgroundFrame)
        begin
          BF
          .SetContentAsFrame<TActivityBubblesFrame>(
            procedure (ABF: TActivityBubblesFrame)
            begin
              TRetrieveMsg.Subscribe(
                procedure (AData: string)
                begin
                  if AData = 'books.end' then
                    SF.HideTitleDetailContent();
                  if AData = 'books.begin' then
                    SF.ShowTitleDetailContent();
                end
              );
            end
          )
          .SetFillColor(TAlphaColorRec.White)
          .SetStrokeColor(TAppColors.MATERIAL_RED_400)
          .SetStrokeThickness(1)
          .SetMargin(5, 2, 5, 2)
          .SetAlignRight
          .SetWidth(64);
        end
      );

      SF.SetContentAsFrame<TListViewFrame>(
        procedure (AListFrame: TListViewFrame)
        begin
          AListFrame.ItemAppearance := 'ImageListItemBottomDetail';
          AListFrame.AccessoryVisible := False;
          AListFrame.CanSwipeDelete := False;

          ABuilder(SF, AListFrame);
        end
      );

      SF.AddActionButton(IconFonts.ImageList, UIUtils.BackImageIndex
      , procedure
        begin
          Navigator.CloseRoute(ARouteName);
        end
      );

    end
  );

end;

procedure BooksAllRouteDefinition();
begin
  BooksRouteDefinition(BOOKS_ROUTE_NAME + '_all'
  , procedure(AForm: TScaffoldForm; AFrame: TListViewFrame)
    begin
      AFrame.ItemBuilderProc :=
        procedure
        begin

          RemoteData.RetrieveBooks(
            procedure (ABooks: TArray<TBook>)
            begin
              var LBookCount := Length(ABooks);
              if LBookCount = 0 then
                AForm.SetTitle('No books available')
              else if LBookCount = 1 then
                AForm.SetTitle('A book found')
              else
                AForm.SetTitle(Format('%d books found', [LBookCount]));

              AFrame.SearchVisible := LBookCount > 3;

              for var LBook in ABooks do
              begin
                var LItem := AFrame.AddItem(
                  LBook.Title
                , LBook.Author.Surname + ', ' + LBook.Author.Name
                , UIUtils.BookImageIndex
                , procedure (const AItem: TListViewItem)
                  begin
                    RemoteData.selectedBookId := AItem.Tag;
                    Navigator.RouteTo('book_single');
                  end
                );
                LItem.Tag := LBook.id;
              end;

            end
          , procedure (AError: string)
            begin
              AForm.ShowSnackBar(AError, 3000);
              AFrame.ClearItems;
            end
          );
        end;
    end
  );
end;

procedure BooksByAuthorRouteDefinition();
begin
  BooksRouteDefinition(BOOKS_ROUTE_NAME + '_by_author'
  , procedure(AForm: TScaffoldForm; AFrame: TListViewFrame)
    begin
      AFrame.ItemBuilderProc :=
        procedure
        begin
          RemoteData.RetrieveBooksByAuthor(
            procedure (ABooks: TArray<TBook>)
            begin
              var LBookCount := Length(ABooks);
              if LBookCount = 0 then
                AForm.SetTitle('No books available')
              else if LBookCount = 1 then
                AForm.SetTitle('A book found')
              else
                AForm.SetTitle(Format('%d books found', [LBookCount]));

              AFrame.SearchVisible := LBookCount > 3;

              for var LBook in ABooks do
              begin
                var LItem := AFrame.AddItem(
                  LBook.Title
                , LBook.Author.Surname + ', ' + LBook.Author.Name
                , UIUtils.BookImageIndex
                , procedure (const AItem: TListViewItem)
                  begin
                    RemoteData.selectedBookId := AItem.Tag;
                    Navigator.RouteTo('book_single');
                  end
                );
                LItem.Tag := LBook.id;
              end;

            end
          , procedure (AError: string)
            begin
              AForm.ShowSnackBar(AError, 3000);
              AFrame.ClearItems;
            end
          );
        end;
    end
  );
end;


end.
