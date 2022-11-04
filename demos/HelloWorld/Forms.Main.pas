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
  private
  public
    constructor Create(AOwner: TComponent); override;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, Routes.bubble
, Routes.home
;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  // initialization
  Navigator(FormStand1);

  // Route definitions
  DefineHomeRoute();
  DefineBubbleRoute();

  Navigator.OnCloseRoute :=
    procedure (ARoute: string)
    begin
      if ARoute = 'home' then
        Close;
    end;

  // initial route
  Navigator.RouteTo('home');
end;

end.
