unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand
//, FMX.MobilePreview
;

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
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, Routes.bubble
, Routes.qrcode
, Routes.home
;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  // initialization
  Navigator(FormStand1);

  // Route definitions
  DefineHomeRoute();
  DefineQRCodeRoute();
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

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Navigator.ActiveRoutes.Count > 0 then
  begin
    Action := TCloseAction.caNone;
    Navigator.CloseAllRoutes();
  end;
end;

end.
