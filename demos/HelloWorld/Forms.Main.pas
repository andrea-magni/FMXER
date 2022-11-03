unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand, FMX.MobilePreview;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    constructor Create(AOwner: TComponent); override;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.LogoFrame, FMXER.ColumnForm, FMXER.VertScrollFrame
, FMXER.ContainerForm, FMXER.ActivityBubblesFrame, FMXER.ButtonFrame
, FMXER.ChipFrame, FMXER.ChipsFrame, FMXER.RowForm

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

       Home.SetContentAsFrame<TVertScrollFrame>(
         procedure (AVSF: TVertScrollFrame)
         begin
           AVSF.SetContentAsForm<TColumnForm>(
             procedure (C: TColumnForm)
             begin
               C.AddFrame<TButtonFrame>(100
               , procedure (B: TButtonFrame)
                 begin
                   B.Text := 'Say hello!';
                   B.Margins.Rect := RectF(5, 5, 5, 5);
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
                   CF.Text := 'Login';
                   CF.Margins.Rect := RectF(5, 5, 5, 5);
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
                   Chips.Margins.Rect := RectF(5, 5, 5, 5);

                   Chips.Flow.HorizontalGap := 5;
                   Chips.DefaultConfig :=
                     procedure (Chip: TChipFrame)
                     begin
                       Chip.Width := 65;
                       Chip.OnClickHandler :=
                       procedure
                       begin
                         ShowMessage(Chip.Button.Text);
                       end;
                     end;

                   Chips.AddChip('One');
                   Chips.AddChip('Two');
                   Chips.AddChip('Three');
                 end
               );

               C.AddFrame<TCustom1Frame>(
                   150 // height
                 , procedure (F: TCustom1Frame)
                   begin
                     F.OnButtonClick := procedure
                                        begin
                                          Navigator.RouteTo('bubble', True);

                                          TDelayedAction.Execute(
                                            3000
                                          , procedure
                                            begin
                                              Navigator.CloseRoute('bubble', True);
                                            end
                                          );
                                        end;
                   end
               );

             end
           );
         end
       );


       Home.AddActionButton('A',
         procedure
         begin
           Home.ShowSnackBar('This is a transient message', 3000);
         end);

       Home.AddActionButton('X',
         procedure
         begin
           Navigator.CloseRoute('home');
         end);
     end
  );

  Navigator.RouteTo('home'); // initial route
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Navigator.ActiveRoutes.Count > 0 then
  begin
    Action := TCloseAction.caNone;
    Navigator.OnCloseRoute := procedure (ARoute: string) begin if ARoute = 'home' then Close; end;
    Navigator.CloseAllRoutes();
  end;
end;

end.
