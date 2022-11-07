unit Routes.home;

interface

uses
  Classes, SysUtils, Types, UITypes, IOUtils, FMX.Dialogs, FMX.Types, FMX.Graphics,
  System.Messaging
, FMXER.Navigator;

function DefineHomeRoute(const ARouteName: string = 'home'): TNavigator;

implementation

uses
  Skia, Skia.FMX

, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.RowForm
, FMXER.VertScrollFrame, FMXER.ButtonFrame, FMXER.ChipFrame, FMXER.ChipsFrame
, FMXER.SVGFrame, FMXER.StackFrame, FMXER.BackgroundFrame
, FMXER.AnimatedImageFrame, FMXER.EditFrame, FMXER.QRCodeFrame

, Frames.Custom1
, Data.AppState;

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
             .SetText('Hello 1!')
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
             .SetText('Hello 2!')
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
             .SetText('Hello 3!')
             .SetPadding<TButtonFrame>(5)
             .SetBackgroundVisible(False)
             .OnClickHandler :=
               procedure
               begin
                 ShowMessage('Hello 3!' + ButtonF.ButtonControl.Text);
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
         Frame
         .SetCaption('Name')
         .SetTextPrompt('Write your name here')
         .SetText('')
         .SetExtraText('Choose wisely!')
         .SetMarginT(10);

         Frame.OnChangeProc :=
           procedure (ATracking: Boolean)
           begin
             AppState.Something := Frame.GetText;
           end;

         // save the reference for future (local) use // FANCY CAPTURING
         LEditFrame := Frame;
       end
     )

     .AddFrame<TCustom1Frame>(
       150 // height
     , procedure (Frame: TCustom1Frame)
       begin
         Frame.SetAlignClient;
         Frame.OnButtonClick :=
           procedure
           begin
             Navigator.RouteTo('bubble', True);
             Navigator.CloseRouteDelayed('bubble', True, 3000);

             var LText := LEditFrame.GetText; // FANCY CAPTURING
             if LText <> '' then
               ShowMessage(LText);
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
       .SetTitleDetailContentAsFrame<TQRCodeFrame>(
          procedure (AQR: TQRCodeFrame)
          begin
            AQR
            .SetContent('https://github.com/andrea-magni/FMXER')
            .SetOverrideColor(TAlphaColorRec.Navy)
            .SetAlignRight
            .SetMargin(2)
            .SetHitTest(True);

            TMessageManager.DefaultManager.SubscribeToMessage(TSomethingChangedMsg
            , procedure (const Sender: TObject; const M: TMessage)
              begin
                var Msg := M as TSomethingChangedMsg;
                var LValue := Msg.Value;
                if LValue = '' then
                  LValue := 'No text available';
                AQR.SetContent(LValue);
              end
            );

            AQR.OnTapHandler :=
              procedure(AImage: TFMXObject; APoint: TPointF)
              begin
                if AppState.Something <> '' then
                  Navigator.RouteTo('qrcode');
              end;

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
