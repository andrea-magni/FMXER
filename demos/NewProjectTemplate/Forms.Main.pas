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
  FMXER.Navigator, FMXER.UI.Consts, FMXER.UI.Misc
, Routes.Home
;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Initialization ------------------------------------------------------------
  Navigator(FormStand1);

  // Route definitions ---------------------------------------------------------
  DefineHomeRoute('home');

  // Navigation events ---------------------------------------------------------
  Navigator.SetOnCloseRoute(
    procedure (ARouteName: string)
    begin
      if ARouteName = 'home' then
        Close;
    end
  );

  // Start ---------------------------------------------------------------------
  Navigator.RouteTo('home');
end;

end.
