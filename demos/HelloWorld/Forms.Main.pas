unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand;

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

uses FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator, FMXER.ScaffoldForm, FMXER.LogoFrame
, Frames.Custom1;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization

  .DefineRoute<TScaffoldForm>( // route definition
     'home'
   , procedure (AForm: TScaffoldForm)
     begin
       AForm.Title := 'Hello, World!';

       AForm.SetContentAsFrame<TCustom1Frame>;

       AForm.AddActionButton('A',
         procedure
         begin
           AForm.ShowSnackBar('This is a transient message', 3000);
         end);

       AForm.AddActionButton('X',
         procedure
         begin
           Navigator.CloseRoute('home');
         end);
     end
  );

  Navigator.RouteTo('home'); // initial route
end;

end.
