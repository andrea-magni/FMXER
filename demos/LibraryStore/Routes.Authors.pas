unit Routes.Authors;

interface

uses
  Classes, SysUtils, System.Types, System.UITypes, FMX.Types, FMX.ListView.Appearances
, FMX.Dialogs
;

const
  AUTHORS_ROUTE_NAME = 'authors';
  AUTHORS_ROUTE_TITLE = 'Authors';

procedure AuthorsRouteDefinition();

implementation

uses
  FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ListViewFrame, FMXER.BackgroundFrame, FMXER.ActivityBubblesFrame
, FMXER.IconFontsData
, Utils.UI, Data.Remote, Model, Utils.Msg;

procedure AuthorsRouteDefinition();
begin
  Navigator.DefineRoute<TScaffoldForm>(
   AUTHORS_ROUTE_NAME
  , procedure (SF: TScaffoldForm)
    begin
      SF
      .SetTitle(AUTHORS_ROUTE_TITLE)
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
                  if AData = 'authors.end' then
                    SF.HideTitleDetailContent();
                  if AData = 'authors.begin' then
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
      )
      .SetContentAsFrame<TListViewFrame>(
        procedure (AListFrame: TListViewFrame)
        begin
          AListFrame.ItemAppearance := 'ImageListItemBottomDetail';
          AListFrame.AccessoryVisible := False;
          AListFrame.CanSwipeDelete := False;

          AListFrame.ItemBuilderProc :=
            procedure
            begin
              RemoteData.RetrieveAuthors(
                procedure (AAuthors: TArray<TAuthor>)
                begin
                  var LAuthorCount := Length(AAuthors);
                  if LAuthorCount = 0 then
                    SF.SetTitle('No authors available')
                  else if LAuthorCount = 1 then
                    SF.SetTitle('An author found')
                  else
                    SF.SetTitle(Format('%d authors found', [LAuthorCount]));

                  AListFrame.SearchVisible := LAuthorCount > 3;

                  for var LAuthor in AAuthors do
                  begin
                    var LItem := AListFrame.AddItem(
                      LAuthor.Surname + ' ' + LAuthor.Name
                    , ''
                    , UIUtils.AuthorImageIndex
                    , procedure (const AItem: TListViewItem)
                      begin
                        RemoteData.selectedAuthorId := AItem.Tag;
                        Navigator.RouteTo('books_by_author');
                      end
                    );
                    LItem.Tag := LAuthor.id;
                  end;
                end
              , procedure (AError: string)
                begin
                  AListFrame.ClearItems;
                end
              );
            end;
        end
      )
      .AddActionButton(IconFonts.ImageList, UIUtils.BackImageIndex
      , procedure
        begin
          Navigator.CloseRoute(AUTHORS_ROUTE_NAME);
        end
      );
    end
  );

end;

end.
