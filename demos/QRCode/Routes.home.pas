unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes;

procedure DefineHomeRoute(const ARouteName: string);

implementation

uses
  FMX.Types, Skia.FMX
, FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.ButtonFrame, FMXER.AccessoryFrame
, FMXER.IconFontsGlyphFrame, FMXER.IconFontsData
, FMXER.StackFrame, FMXER.AnimatedImageFrame, FMXER.BackgroundFrame, FMXER.VertScrollFrame
, Data.Main
;


procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(
    ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('QRCode demo')

      .SetContentAsFrame<TStackFrame>(
        procedure (Stack: TStackFrame)
        begin
          Stack
          .AddFrame<TBackgroundFrame>(
            procedure (Background: TBackgroundFrame)
            begin
              Background.SetFillColor(TAlphaColorRec.White);
            end
          )
          .AddFrame<TAnimatedImageFrame>(
            procedure (AIF: TAnimatedImageFrame)
            begin
              AIF
              .LoadFromFile(LocalFile('85570-background-animation-for-a-simple-project.json'))
              .SetWrapMode(TSkAnimatedImageWrapMode.FitCrop)
              .SetAnimationSpeed(0.75)
              .SetOpacity(0.33);
            end
          )
          .AddFrame<TVertScrollFrame>(
            procedure (VertScrollF: TVertScrollFrame)
            begin
              VertScrollF
              .SetTouchWidth(0)
              .SetContentAsForm<TColumnForm>(
                procedure (Col: TColumnForm)
                begin
                  Col
                  // Accessory: Glyph | Button
                  .AddFrame<TAccessoryFrame>(
                    70
                  , procedure (Accessory: TAccessoryFrame)
                    begin
                      Accessory
                      .SetContentAsFrame<TButtonFrame>(
                        procedure (Button: TButtonFrame)
                        begin
                          Button
                          .SetText('Generate')
                          .SetOnClickHandler(
                            procedure
                            begin
                              Navigator.RouteTo('QRGenerator');
                            end
                          )
                          .SetMargin(5);
                        end
                      )
                      .SetLeftAsFrame<TIconFontsGlyphFrame>(
                        50
                      , procedure (Glyph: TIconFontsGlyphFrame)
                        begin
                          Glyph
                          .SetIcon(IconFonts.MD.qrcode_edit, TAppColors.PrimaryColor)
                          .SetPadding(5);
                        end
                      )
                      .SetPadding(10);
                    end
                  )
                  // Accessory: Glyph | Button
                  .AddFrame<TAccessoryFrame>(
                    70
                  , procedure (Accessory: TAccessoryFrame)
                    begin
                      Accessory
                      .SetContentAsFrame<TButtonFrame>(
                        procedure (Button: TButtonFrame)
                        begin
                          Button
                          .SetText('Read')
                          .SetOnClickHandler(
                            procedure
                            begin
                              Navigator.RouteTo('QRReader');
                            end
                          )
                          .SetMargin(5);
                        end
                      )
                      .SetLeftAsFrame<TIconFontsGlyphFrame>(
                        50
                      , procedure (Glyph: TIconFontsGlyphFrame)
                        begin
                          Glyph
                          .SetIcon(IconFonts.MD.qrcode_scan, TAppColors.PrimaryColor)
                          .SetPadding(5);
                        end
                      )
                      .SetPadding(10);
                    end
                  )

                  // Accessory: Glyph | Button
                  .AddFrame<TAccessoryFrame>(
                    70
                  , procedure (Accessory: TAccessoryFrame)
                    begin
                      Accessory
                      .SetContentAsFrame<TButtonFrame>(
                        procedure (Button: TButtonFrame)
                        begin
                          Button
                          .SetText('Single frame')
                          .SetOnClickHandler(
                            procedure
                            begin
                              Navigator.RouteTo('SingleFrame');
                            end
                          )
                          .SetMargin(5);
                        end
                      )
                      .SetLeftAsFrame<TIconFontsGlyphFrame>(
                        50
                      , procedure (Glyph: TIconFontsGlyphFrame)
                        begin
                          Glyph
                          .SetIcon(IconFonts.MD.image_frame, TAppColors.PrimaryColor)
                          .SetPadding(5);
                        end
                      )
                      .SetPadding(10);
                    end
                  )

                  // Column
                  .SetPadding(5);
                end
              );
            end
          )
        end
      );
    end
  );
end;

end.
