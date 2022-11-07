unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes, IOUtils, FMX.Dialogs, FMX.Types, FMX.Graphics
, FMXER.Navigator;

function DefineHomeRoute(const ARouteName: string = 'home'): TNavigator;

implementation

uses
  Skia, Skia.FMX

, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.RowForm
, FMXER.VertScrollFrame, FMXER.ButtonFrame, FMXER.ChipFrame, FMXER.ChipsFrame
, FMXER.SVGFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.AnimatedImageFrame

, Frames.Custom1
;

function DefineHomeRoute(const ARouteName: string): TNavigator;
begin
  Result := Navigator.DefineRoute<TScaffoldForm>(
     ARouteName
   , procedure (Home: TScaffoldForm)
     begin
       Home
       .SetTitle('Hello, World!')
       .SetTitleDetailContentAsFrame<TButtonFrame>(
         procedure (ButtonF: TButtonFrame)
         begin
           ButtonF
             .SetCaption('Caption')
             .SetText('Popup')
             .SetAlignRight
             .SetPadding(10)
             .SetWidth(100);

           ButtonF.BackgroundFill.Kind := TBrushKind.None;
         end
       )
       .SetContentAsFrame<TStackFrame>(
         procedure (Stack: TStackFrame)
         begin
           Stack
           .AddFrame<TBackgroundFrame>(
             procedure (Backg: TBackgroundFrame)
             begin
               Backg.Fill.Color := TAlphaColorRec.White;
             end
           )
           .AddFrame<TSVGFrame>(
             procedure (SVGF: TSVGFrame)
             begin
               SVGF.LoadFromFile(TPath.Combine(
                 {$IFDEF MSWINDOWS} '..\..\..\..\media\' {$ELSE} TPath.GetDocumentsPath {$ENDIF}
               , 'TSkSvg.svg')
               );
               SVGF.ContentSvg.Opacity := 0.33;
               SVGF.ContentSvg.Svg.WrapMode := TSkSvgWrapMode.Tile;
               SVGF.ContentSvg.Svg.OverrideColor := TAlphaColorRec.Orange;
             end
           )
           .AddFrame<TAnimatedImageFrame>(
             procedure (AIF: TAnimatedImageFrame)
             begin
               AIF.ContentImage.LoadFromFile(TPath.Combine(
                 {$IFDEF MSWINDOWS} '..\..\..\..\media\' {$ELSE} TPath.GetDocumentsPath {$ENDIF}
               , '85570-background-animation-for-a-simple-project.json')
               );
               AIF.ContentImage.WrapMode := TSkAnimatedImageWrapMode.FitCrop;
               AIF.ContentImage.Animation.Speed := 0.75;
               AIF.ContentImage.Opacity := 0.33;
             end
           )
           .AddFrame<TVertScrollFrame>(
             procedure (VertScrollF: TVertScrollFrame)
             begin
               VertScrollF.SetContentAsForm<TColumnForm>(
                 procedure (Col: TColumnForm)
                 begin
                   Col.ContentLayout.SetPadding(5);

                   Col
                   .AddFrame<TButtonFrame>(50
                   , procedure (ButtonF: TButtonFrame)
                     begin
                       ButtonF
                         .SetText('Say hello!')
                         .OnClickHandler :=
                           procedure
                           begin
                             ShowMessage('Hello!');
                           end;
                     end
                   )
                   .AddFrame<TChipFrame>(50
                   , procedure (ChipF: TChipFrame)
                     begin
                       ChipF.SetMargin(0, 5, 0, 0);
                       ChipF
                         .SetText('Login')
                         .SetBackgroundColor(TAlphaColorRec.Blue)
                         .SetForegroundColor(TAlphaColorRec.White);
                       ChipF.OnClickHandler :=
                         procedure
                         begin
                           ShowMessage('Login unavailable!');
                         end;
                     end
                   )
                   .AddFrame<TChipsFrame>(50
                   , procedure (ChipsF: TChipsFrame)
                     begin
                       ChipsF
                       .SetHorizontalGap(5)
                       .SetVerticalGap(5)
                       .SetMargin(0, 5, 0, 0);

                       ChipsF.DefaultConfig :=
                         procedure (Chip: TChipFrame)
                         begin
                           Chip.Width := 50;
                           Chip.OnClickHandler :=
                             procedure
                             begin
                               ShowMessage(Chip.Button.Text);
                             end;
                         end;

                       ChipsF
                       .AddChip('One')
                       .AddChip('Two')
                       .AddChip('Three'
                       , procedure (Chip: TChipFrame)
                         begin
                           Chip.SetWidth(65);
                           Chip.OnClickHandler :=
                             procedure
                             begin
                               Home.ShowSnackBar(Chip.Button.Text, 3000);
                             end;
                         end
                       );
                     end
                   )
                   .AddFrame<TCustom1Frame>(
                     150 // height
                   , procedure (Frame: TCustom1Frame)
                     begin
                       Frame.OnButtonClick :=
                         procedure
                         begin
                           Navigator.RouteTo('bubble', True);
                           Navigator.CloseRouteDelayed('bubble', True, 3000);
                         end;
                     end
                   );

                 end
               );

             end
           );

         end
       );

       Home
       .AddActionButton('A'
       , procedure
         begin
           Home.ShowSnackBar('This is a transient message', 3000);
         end
       )
       .AddActionButton('X'
       , procedure
         begin
           Navigator.CloseRoute('home');
         end
       );
     end
  );
end;

end.