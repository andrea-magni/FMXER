unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand, FMX.MobilePreview, Skia.FMX;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
  private
  public
    constructor Create(AOwner: TComponent); override;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  IOUtils
, FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.LogoFrame, FMXER.ColumnForm, FMXER.VertScrollFrame
, FMXER.ContainerForm, FMXER.ActivityBubblesFrame, FMXER.ButtonFrame
, FMXER.ChipFrame, FMXER.ChipsFrame, FMXER.RowForm
, FMXER.SVGFrame, FMXER.StackFrame

, Frames.Custom1;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization

  .DefineRoute<TContainerForm>( // --------------- bubble route
    'bubble'
  , procedure (F: TContainerForm)
    begin
      F.SetContentAsFrame<TActivityBubblesFrame>(
        procedure (ABF: TActivityBubblesFrame)
        begin
          ABF.HitTest := False; // click through
          ABF.Padding.Rect := RectF(F.Width * 0.10, F.Height * 0.10, F.Width * 0.10, F.Height * 0.10);
        end
      );
    end
  )

  .DefineRoute<TScaffoldForm>( // ---------------- home route
     'home'
   , procedure (Home: TScaffoldForm)
     begin
       Home.Title := 'Hello, World!';

       Home.SetContentAsFrame<TStackFrame>(
         procedure (SF: TStackFrame)
         var LWidth, LHeight: Double;
         begin
           SF.AddFrame<TSVGFrame>(
             procedure (SVGF: TSVGFrame)
             begin
               SVGF.LoadFromFile(TPath.Combine(
                 {$IFDEF MSWINDOWS} '..\..\..\..\media\' {$ELSE} TPath.GetDocumentsPath {$ENDIF}
               , 'rect_shadow.svg')
               );
               LWidth := SVGF.SVG.Svg.OriginalSize.cx;
               LHeight := SVGF.SVG.Svg.OriginalSize.cy;
               SVGF.ContentSvg.Svg.WrapMode := TSkSvgWrapMode.OriginalCenter;
             end
           );

           SF.AddFrame<TVertScrollFrame>(
             procedure (AVSF: TVertScrollFrame)
             begin
               AVSF.Align := TAlignLayout.Center;
               AVSF.Width := LWidth * 0.8;
               AVSF.Height := LHeight * 0.8;
               AVSF.SetContentAsForm<TColumnForm>(
                 procedure (C: TColumnForm)
                 begin
                   C.Padding.Rect := RectF(5, 5, 5, 5);

                   C.AddFrame<TButtonFrame>(50
                   , procedure (B: TButtonFrame)
                     begin
                       B.Text := 'Say hello!';
                       B.OnClickHandler :=
                         procedure
                         begin
                           ShowMessage('Hello!');
                         end;
                     end
                   );

                   C.AddFrame<TChipFrame>(50
                   , procedure (CF: TChipFrame)
                     begin
                       CF.Margins.Top := 5;
                       CF.Text := 'Login';
                       CF.BackgroundColor := TAlphaColorRec.Blue;
                       CF.ForegroundColor := TAlphaColorRec.White;
                       CF.OnClickHandler :=
                         procedure
                         begin
                           ShowMessage('Login unavailable!');
                         end;
                     end
                   );

                   C.AddFrame<TChipsFrame>(50
                   , procedure (Chips: TChipsFrame)
                     begin
                       Chips.Margins.Top := 5;
                       Chips.Flow.HorizontalGap := 5;
                       Chips.Flow.VerticalGap := 5;

                       Chips.DefaultConfig :=
                         procedure (Chip: TChipFrame)
                         begin
                           Chip.Width := 50;
                           Chip.OnClickHandler :=
                             procedure
                             begin
                               ShowMessage(Chip.Button.Text);
                             end;
                         end;

                       Chips.AddChip('One');
                       Chips.AddChip('Two');
                       Chips.AddChip('Three'
                       , procedure (Chip: TChipFrame)
                         begin
                           Chip.Width := 65;
                           Chip.OnClickHandler :=
                             procedure
                             begin
                               Home.ShowSnackBar(Chip.Button.Text, 3000);
                             end;
                         end
                       );
                     end
                   );

                   C.AddFrame<TCustom1Frame>(
                     150 // height
                   , procedure (F: TCustom1Frame)
                     begin
                       F.OnButtonClick :=
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

       Home.AddActionButton('A'
       , procedure
         begin
           Home.ShowSnackBar('This is a transient message', 3000);
         end);

       Home.AddActionButton('X'
       , procedure
         begin
           Navigator.CloseRoute('home');
         end);
     end
  );

  Navigator.OnCloseRoute :=
    procedure (ARoute: string)
    begin
      if ARoute = 'home' then
        Close;
    end;

  Navigator.RouteTo('home'); // initial route
end;

end.
