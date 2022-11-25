unit Routes.Webview;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineWebviewRoute(const ARouteName: string);

implementation

uses
  FMX.Types, Skia.FMX
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.WebViewFrame
, FMXER.IconFontsGlyphFrame, FMXER.IconFontsData
, Data.Main
;

procedure DefineWebviewRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('Browser')

      .SetContentAsFrame<TWebViewFrame>(
        procedure (Webview: TWebViewFrame)
        begin
          var LContent := MainData.QRCodeContent;
          if LContent.StartsWith('http', True) or LContent.StartsWith('www.', True) then
            Webview.URL := LContent
          else
            Webview.HTML := '<h3>QRCode content:</h3><p>' + LContent + '</p>';
        end
      )
      .SetTitleDetailContentAsFrame<TIconFontsGlyphFrame>(
        procedure (IconFrame: TIconFontsGlyphFrame)
        begin
          IconFrame
          .SetIcon(IconFonts.MD.arrow_left, TAppColors.PrimaryTextColor)
          .SetOnClickProc(
            procedure
            begin
              Navigator.CloseRoute(ARouteName)
            end
          )
          .SetAlignRight
          .SetWidth(50)
          .SetMargin(5);
        end
      );
    end
  );
end;

end.
