unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SubjectStand,
  FormStand, System.ImageList, FMX.ImgList, FMX.IconFontsImageList;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
    ImageList1: TImageList;
    IconFontsImageList1: TIconFontsImageList;
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
, FMXER.ScaffoldForm, FMXER.ContainerForm, FMXER.BackgroundForm
, FMXER.LogoFrame, FMXER.ImageFrame, FMXER.GlyphFrame, Icons.MaterialDesign;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;

  Navigator(FormStand1) // initialization

  .DefineRoute<TScaffoldForm>( // route definition
     'home'
   , procedure (AForm: TScaffoldForm)
     begin
       AForm.Title := 'Hello, World!';

       AForm.SetContentAsFrame<TLogoFrame>;

       IconFontsImageList1.InsertIcon(0
       , MD.account_clock.codepoint, ''
       , TAlphaColorRec.Red
       );

       AForm.AddActionButton(IconFontsImageList1, 0
       , procedure
         begin
           Navigator.RouteTo('Icon1');
         end
       );

       AForm.AddActionButton('A',
         procedure
         begin
           AForm.ShowSnackBar('This is a transient message', 3000);
         end);

       IconFontsImageList1.InsertIcon(1
       , MD.access_point.codepoint, ''
       , TAlphaColorRec.Red
       );

       AForm.AddActionButton(IconFontsImageList1, 1,
         procedure
         begin
           Navigator.CloseRoute('home');
         end);
     end
  )
  .DefineRoute<TBackgroundForm>(
    'Icon1'
  , procedure (BckgForm: TBackgroundForm)
    begin
      BckgForm.SetContentAsFrame<TGlyphFrame>(
        procedure (GlyphFrame: TGlyphFrame)
        begin
          GlyphFrame.Images := IconFontsImageList1;
          GlyphFrame.ImageIndex := 0;
          GlyphFrame.OnClickProc :=
            procedure
            begin
              Navigator.CloseRoute('Icon1');
            end;
        end
      );
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

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Navigator.ActiveRoutes.Count > 0 then
  begin
    Action := TCloseAction.caNone;
    Navigator.CloseAllRoutes();
  end;
end;

end.
