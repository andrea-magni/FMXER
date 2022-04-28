unit Routes.menu;

interface

procedure DefineMenuRoute;

implementation

uses
  FMX.ListView.Appearances

, FMXER.Navigator
, FMXER.ScaffoldForm
, FMXER.ListViewFrame

, SubjectStand
;

procedure DefineMenuRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('menu'
  , procedure (AMenu: TScaffoldForm)
    begin
      AMenu.Title := 'Select an entry';

      AMenu.SetContentAsFrame<TListViewFrame>(
        procedure (AList: TListViewFrame)
        begin
          AList.AddItem('Item 1', '3 seconds', -1
          , procedure (const AItem: TListViewItem)
            begin
              Navigator.RouteTo('spinner', True);
              TDelayedAction.Execute(3000
              , procedure
                begin
                  Navigator.CloseRoute('spinner', True);
                end
              );
            end
          );

          AList.AddItem('Item 2');
          AList.AddItem('Item 3');
        end
      );
    end
  );
end;

end.

