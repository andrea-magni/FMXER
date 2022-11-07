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
, FMXER.AnimatedImageFrame, FMXER.EditFrame

, Frames.Custom1
;

function GetColumnDefinition(const AHost: TScaffoldForm): TProc<TColumnForm>;
begin
  Result :=
   procedure (Col: TColumnForm)
   begin
     Col.ContentLayout.SetPadding(5);

     var LEditFrame : TEditFrame := nil;

     Col
     .AddForm<TRowForm>(75
     , procedure (Row: TRowForm)
       begin
         Row
         .AddFrame<TButtonFrame>(100
         , procedure (ButtonF: TButtonFrame)
           begin
             ButtonF
             .SetText('Say hello 1!')
             .SetPadding<TButtonFrame>(5)
             .SetBackgroundVisible(False)
             .OnClickHandler :=
               procedure
               begin
                 ShowMessage('Hello 1!');
               end;
           end
         )
         .AddFrame<TButtonFrame>(100
         , procedure (ButtonF: TButtonFrame)
           begin
             ButtonF
             .SetText('Say hello 2!')
             .SetPadding<TButtonFrame>(5)
             .SetBackgroundVisible(False)
             .OnClickHandler :=
               procedure
               begin
                 ShowMessage('Hello 2!');
               end;
           end
         )
         .AddFrame<TButtonFrame>(100
         , procedure (ButtonF: TButtonFrame)
           begin
             ButtonF
             .SetText('Say hello 3!')
//             .SetCaption('Caption 3')
//             .SetExtraText('Extra 3')
             .SetPadding<TButtonFrame>(5)
             .SetBackgroundVisible(False)
             .OnClickHandler :=
               procedure
               begin
                 ShowMessage('Hello 3!');
               end;
           end
         );
       end
     )
     .AddFrame<TChipFrame>(50
     , procedure (ChipF: TChipFrame)
       begin
         ChipF
         .SetText('Login')
         .SetBackgroundColor(TAlphaColorRec.Blue)
         .SetForegroundColor(TAlphaColorRec.White)
         .SetMargin<TChipFrame>(0, 5, 0, 0)
         .OnClickHandler :=
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
         .SetMargin<TChipsFrame>(0, 5, 0, 0)
         .DefaultConfig :=
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
                  AHost.ShowSnackBar(Chip.Button.Text, 3000);
                end;
            end
          );
       end
     )
     .AddFrame<TEditFrame>(
       100
     , procedure (Frame: TEditFrame)
       begin
         Frame.Margins.Top := 10;
         Frame.Caption := 'Name';
         Frame.TextPrompt := 'Write your name here';
         Frame.Text := '';
         Frame.ExtraText := 'Choose wisely!';
         LEditFrame := Frame;
       end
     )
     .AddFrame<TCustom1Frame>(
       150 // height
     , procedure (Frame: TCustom1Frame)
       begin
         Frame.OnButtonClick :=
           procedure
           begin
             ShowMessage(LEditFrame.Text);
             Navigator.RouteTo('bubble', True);
             Navigator.CloseRouteDelayed('bubble', True, 3000);
           end;
       end
     );
   end
end;

function DefineHomeRoute(const ARouteName: string): TNavigator;
begin
  Result :=
   Navigator.DefineRoute<TScaffoldForm>(
     ARouteName
   , procedure (Home: TScaffoldForm)
     begin
       Home
       .SetTitle('Hello, World!')
       .SetTitleDetailContentAsFrame<TButtonFrame>(
         procedure (ButtonF: TButtonFrame)
         begin
           ButtonF
           .SetText('Popup')
           .SetBackgroundVisible(False)
           .SetAlignRight
           .SetPadding(10)
           .SetWidth(100);
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
               SVGF
               .LoadFromFile(LocalFile('TSkSvg.svg'))
               .SetOpacity(0.33)
               .SetWrapMode(TSkSvgWrapMode.Tile)
               .SetOverrideColor(TAlphaColorRec.Orange);
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
               .SetContentAsForm<TColumnForm>(
                 GetColumnDefinition(Home)
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
