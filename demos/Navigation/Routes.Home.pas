unit Routes.Home;

interface

uses Classes, SysUtils;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  System.UITypes, FMX.Graphics, FMX.Skia
, FMXER.Navigator, FMXER.UI.Misc, FMXER.UI.Consts
, FMXER.ScaffoldForm, FMXER.TabsFrame, FMXER.ColumnFrame, FMXER.VertScrollFrame
, FMXER.TextFrame, FMXER.HorzDividerFrame, FMXER.SwitchFrame
, FMXER.IconFontsData, Icons.Utils
;

const
  TAB_HOME = 0;
  TAB_TABS = 1;
  TAB_SETTINGS = 2;

// a dark text, for the light pages and the white drawer
procedure DarkText(const AText: TTextFrame; const AContent: string; const ASize: Single = 16);
begin
  AText
  .SetContent(AContent)
  .SetFontColor(TAlphaColorRec.Dimgray)
  .SetFontSize(ASize)
  .SetHorzAlign(TSkTextHorzAlign.Leading);
end;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    var
      // a drawer item: closes the drawer and selects a tab of the bottom navigation
      LDrawerItem: TFunc<string, Integer, TProc<TTextFrame>>;
    begin
      LDrawerItem :=
        function (ACaption: string; ATab: Integer): TProc<TTextFrame>
        begin
          Result :=
            procedure (Item: TTextFrame)
            begin
              DarkText(Item, ACaption);
              Item.TextContent.Margins.Left := 24;
              Item.SetOnClickProc(
                procedure
                begin
                  Scaffold.CloseDrawer;
                  Scaffold.BottomNavigation.SetTabIndex(ATab);
                end
              );
            end;
        end;

      Scaffold
      .SetTitle('Navigation')

      // the drawer: the menu button on the left of the title opens it
      .SetDrawerAsFrame<TColumnFrame>(
        procedure (Menu: TColumnFrame)
        begin
          Menu
          .AddFrame<TTextFrame>(100
          , procedure (Header: TTextFrame)
            begin
              Header.TextContent.Margins.Left := 24;
              Header
              .SetContent('FMXER')
              .SetFontColor(TAppColors.PrimaryColor)
              .SetFontSize(28)
              .SetFontWeight(TFontWeight.Bold)
              .SetHorzAlign(TSkTextHorzAlign.Leading);
            end
          )
          .AddFrame<THorzDividerFrame>(1)
          .AddFrame<TTextFrame>(50, LDrawerItem('Home', TAB_HOME))
          .AddFrame<TTextFrame>(50, LDrawerItem('Tabs', TAB_TABS))
          .AddFrame<TTextFrame>(50, LDrawerItem('Settings', TAB_SETTINGS))
          .AddFrame<THorzDividerFrame>(1)
          .AddFrame<TTextFrame>(50
          , procedure (Item: TTextFrame)
            begin
              DarkText(Item, 'About');
              Item.TextContent.Margins.Left := 24;
              Item.SetOnClickProc(
                procedure
                begin
                  Scaffold.CloseDrawer;
                  Scaffold.ShowSnackBar('FMXER: declarative FireMonkey UIs', 2000);
                end
              );
            end
          );
        end
      )

      // the bottom navigation: one page per tab, the bar at the bottom
      .SetBottomNavigation(
        procedure (Tabs: TTabsFrame)
        begin
          Tabs
          .AddTabFrame<TColumnFrame>('Home', IconFonts.MD.home
          , procedure (Col: TColumnFrame)
            begin
              Col.SetPadding(16, 16, 16, 0);
              Col
              .AddFrame<TTextFrame>(40
              , procedure (Text: TTextFrame)
                begin
                  DarkText(Text, 'Home', 24);
                end
              )
              .AddFrame<TTextFrame>(120
              , procedure (Text: TTextFrame)
                begin
                  DarkText(Text, 'Open the drawer with the menu button on the left of the title, '
                    + 'switch pages with the navigation bar below. On Android, Back closes the open drawer.');
                  Text.SetMaxLines(5);
                end
              );
            end
          )
          // a page with tabs of its own: a tab bar on top
          .AddTabFrame<TTabsFrame>('Tabs', IconFonts.MD.tab
          , procedure (Inner: TTabsFrame)
            var
              LIndex: Integer;
            begin
              for LIndex := 1 to 3 do
              begin
                var LCaption := 'Tab ' + LIndex.ToString;
                Inner.AddTabFrame<TTextFrame>(LCaption
                , procedure (Text: TTextFrame)
                  begin
                    Text
                    .SetContent('Content of ' + LCaption)
                    .SetFontColor(TAlphaColorRec.Dimgray)
                    .SetFontSize(20);
                  end
                );
              end;
              Inner.SetOnChangeProc(
                procedure (AIndex: Integer)
                begin
                  Scaffold.ShowSnackBar('Tab ' + (AIndex + 1).ToString + ' selected', 1000);
                end
              );
            end
          )
          .AddTabFrame<TColumnFrame>('Settings', IconFonts.MD.cog
          , procedure (Col: TColumnFrame)
            begin
              Col.SetPadding(16, 16, 16, 0);
              Col
              .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Switch: TSwitchFrame)
                begin
                  Switch.SetText('Dark mode (not really)');
                end
              )
              .AddFrame<TSwitchFrame>(TColumnFrame.AUTO_HEIGHT
              , procedure (Switch: TSwitchFrame)
                begin
                  Switch.SetText('Notifications').SetChecked(True);
                end
              );
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
