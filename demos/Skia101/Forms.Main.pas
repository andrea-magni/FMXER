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
  FMXER.UI.Consts
//, FMXER.UI.Misc
, FMXER.Navigator

, Routes.home
, Routes.menu
, Routes.Spinner
;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TAppColors.PrimaryColor := TAppColors.MATERIAL_BLUE_800;

  Navigator(FormStand1);

  DefineHomeRoute;
  DefineMenuRoute;
  DefineSpinnerRoute;

  Navigator.RouteTo('menu');
end;

end.
