unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ColumnForm
, FMXER.LogoFrame, FMXER.ContainerFrame, FMXER.EditFrame, FMXER.ButtonFrame, FMXER.CardFrame
, FMXER.IconFontsGlyphFrame, FMXER.IconFontsData, Frames.WeatherSituation;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1)
  .DefineRoute<TScaffoldForm>('home'
  , procedure (AHome: TScaffoldForm)
    begin
      AHome.Title := 'EKON25 Demo';

//      AHome.SetContentAsFrame<TWeatherSituationFrame>(
//        procedure (AWeatherFrame: TWeatherSituationFrame)
//        begin
//          AWeatherFrame.Location := 'Dusseldorf,DE';
//
//        end
//      );

      AHome.SetContentAsForm<TColumnForm>(
        procedure (ACol: TColumnForm)
        begin
          ACol.AddFrame<TCardFrame>(200,
           procedure (ACard: TCardFrame)
           begin
             ACard.Title := 'Dusseldorf,DE';

             ACard.SetContentAsForm<TColumnForm>(
               procedure (ACol: TColumnForm)
               begin
                 ACol.AddFrame<TButtonFrame>(100,
                   procedure (AButton: TButtonFrame)
                   begin
                     AButton.Text := 'Get weather';

                   end
                 );
               end
             );
           end
          );
        end
      );

    end
  );


  TAppColors.PrimaryColor := TAppColors.MATERIAL_BLUE_GREY_800;

  Navigator.RouteTo('home');
end;

end.
