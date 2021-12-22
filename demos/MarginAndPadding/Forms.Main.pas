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
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator, FMXER.ScaffoldForm, FMXER.LogoFrame
, FMXER.ColumnForm, FMXER.VertScrollFrame, FMXER.VertScrollForm, FMXER.MarginFrame;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization

  .DefineRoute<TVertScrollForm>( // route definition
     'home'
   , procedure (AForm: TVertScrollForm)
     begin
       AForm.SetContentAsForm<TColumnForm>(
         procedure (ACol: TColumnForm)
         begin
           ACol.AddFrame<TLogoFrame>(
             ACol.Width
           , procedure (ALogo: TLogoFrame)
             begin
               ALogo.Height := ACol.Width;
             end);

           ACol.AddFrame<TMarginFrame>(
             ACol.Width
           , procedure (AM: TMarginFrame)
             begin
               AM.Margins.Rect := RectF(50, 50, 50, 50);
               AM.SetContentAsFrame<TLogoFrame>;
             end);


           ACol.AddFrame<TLogoFrame>(
             ACol.Width
           , procedure (ALogo: TLogoFrame)
             begin
               ALogo.Height := ACol.Width;
             end);

           ACol.AddFrame<TMarginFrame>(
             ACol.Width
           , procedure (AP: TMarginFrame)
             begin
               AP.Padding.Rect := RectF(50, 50, 50, 50);
               AP.SetContentAsFrame<TLogoFrame>;
             end);


         end);
     end);

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
