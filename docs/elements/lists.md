# Lists

`TListViewFrame` (unit `FMXER.ListViewFrame`) wraps a FireMonkey `TListView` — virtualized, native-looking, with search and pull-to-refresh — and adds a click handler per item. Use it for long or data-driven lists, where a column of elements would be too heavy.

## Static items

```pascal
Scaffold.SetContentAsFrame<TListViewFrame>(
  procedure (List: TListViewFrame)
  begin
    List.ItemAppearance := 'ImageListItem';
    List.CanSwipeDelete := False;

    List.AddItem('Books', '', UIUtils.BookImageIndex
    , procedure (const AItem: TListViewItem)
      begin
        Navigator.RouteTo('books_all');
      end
    );

    List.AddItem('Authors', '', UIUtils.AuthorImageIndex
    , procedure (const AItem: TListViewItem)
      begin
        Navigator.RouteTo('authors');
      end
    );
  end
);
```

`AddItem(AText, ADetailText = ''; AImageIndex = -1; AOnSelect = nil): TListViewItem` adds an item and returns it, so you can set its `Tag`, `Data` or `Objects`. `AOnSelect` is called when the item is clicked. Images come from `ListView.Images`, which is the shared [icon font image list](./icons) unless you assign another one.

## Items from data: the item builder

Set `ItemBuilderProc` to a procedure that adds the items. It runs at once and again on pull-to-refresh and `RefreshList`:

```pascal
List.ItemAppearance := 'ImageListItemBottomDetail';
List.ItemBuilderProc :=
  procedure
  begin
    RemoteData.RetrieveBooks(
      procedure (ABooks: TArray<TBook>)
      begin
        List.SearchVisible := Length(ABooks) > 3;
        for var LBook in ABooks do
        begin
          var LItem := List.AddItem(LBook.Title
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
    );
  end;
```

The LibraryStore demo is built this way, with the data coming from a MARS REST server.

The frame clears the list before calling the builder. `PullToRefresh` is on by default; turn it off with `List.ListView.PullToRefresh := False` if you do not need it.

::: info Before v.1.2
Up to v.1.1 pull-to-refresh did not clear the items before calling the builder (every item appeared twice): on v.1.1 call `List.ClearItems` at the beginning of the builder.
:::

## Search

`SearchVisible := True` shows the list view's search box, which filters the items by text. `SearchText` reads or sets its text, `SetOnSearchChange(TProc)` is called when it changes.

## Members

| Member | Description |
|---|---|
| `AddItem(AText, ADetailText, AImageIndex, AOnSelect): TListViewItem` | adds an item with its click handler |
| `ClearItems` | removes every item |
| `ItemBuilderProc: TProc` | builds the items; setting it runs it, on an empty list |
| `RefreshList` | clears and rebuilds |
| `ItemAppearance: string` | the list view's item appearance (`'ListItem'`, `'ListItemRightDetail'`, `'ImageListItem'`, `'ImageListItemBottomDetail'`, ...) |
| `AccessoryVisible: Boolean` | the item accessory (chevron) |
| `CanSwipeDelete: Boolean` | swipe to delete (on by default in `TListView`) |
| `SearchVisible: Boolean`, `SearchText: string`, `SetOnSearchChange(TProc)` | search box |
| `SelectedItem: TListViewItem` | |
| `ListView: TListView` | the list view |

`TListViewItemClickProc = reference to procedure (const AItem: TListViewItem)` is the type of the item handlers; each handler is stored in its item (`Data['FMXER.OnSelect']`, the `ON_SELECT_DATA` constant), so it goes away with the item. Add `FMX.ListView.Appearances` to the `uses` clause for `TListViewItem`.
