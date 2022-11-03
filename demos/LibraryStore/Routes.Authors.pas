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
      SF.Title := AUTHORS_ROUTE_TITLE;

      SF.SetTitleDetailContentAsFrame<TBackgroundFrame>(
        procedure (BF: TBackgroundFrame)
        begin
          BF.Margins.Rect := RectF(5, 2, 5, 2);
          BF.Align := TAlignLayout.Right;
          BF.Width := 64;

          BF.Fill.Color := TAlphaColorRec.White;
          BF.Stroke.Color := TAppColors.MATERIAL_RED_400;
          BF.Stroke.Thickness := 1;

          BF.SetContentAsFrame<TActivityBubblesFrame>(
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
          );
        end
      );


      SF.SetContentAsFrame<TListViewFrame>(
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
                    SF.Title := 'No authors available'
                  else if LAuthorCount = 1 then
                    SF.Title := 'An author found'
                  else
                    SF.Title := Format('%d authors found', [LAuthorCount]);

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
      );

      SF.AddActionButton(IconFonts.ImageList, UIUtils.BackImageIndex
      , procedure
        begin
          Navigator.CloseRoute(AUTHORS_ROUTE_NAME);
        end
      );

    end
  );

end;

end.
