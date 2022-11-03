unit Routes.Home;

interface

uses
  Classes, SysUtils, FMX.ListView.Appearances
;

procedure HomeRouteDefinition();

implementation

uses
  FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ListViewFrame
, Utils.UI;

procedure HomeRouteDefinition();
begin
  Navigator.DefineRoute<TScaffoldForm>(
   'home'
  , procedure (Home: TScaffoldForm)
    begin
      Home.Title := 'Library Store';
//      Home.TitleLabel.TextSettings.Font.Families := 'Material Design Icons Desktop';
//      Home.TitleLabel.Text := #$F0004;

      Home.SetContentAsFrame<TListViewFrame>(
        procedure (AListFrame: TListViewFrame)
        begin
          AListFrame.ItemAppearance := 'ImageListItem';
          AListFrame.CanSwipeDelete := False;

          AListFrame.AddItem('Book list', '', UIUtils.BookImageIndex
          , procedure (const AItem: TListViewItem)
            begin
              Navigator.RouteTo('books_all');
            end
          );

          AListFrame.AddItem('Author list', '', UIUtils.AuthorImageIndex
          , procedure (const AItem: TListViewItem)
            begin
              Navigator.RouteTo('authors');
            end
          );

        end
       );

     end
   );

end;

end.
