unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.ImageList,
  FMX.ImgList, FMX.Ani
, SubjectStand, FormStand;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    Stands: TStyleBook;
    ImageList1: TImageList;
    procedure FormStand1BeforeStartAnimation(const ASender: TSubjectStand;
      const ASubjectInfo: TSubjectInfo; const AAnimation: TAnimation);
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
  FMXER.Navigator, FMXER.ScaffoldForm, FMXER.GlyphFrame
, Frames.MyDataSetList, Frames.MyDataSetDetail;

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  Navigator(FormStand1) // initialization

  .DefineRoute<TScaffoldForm>(
     'home'
   , procedure (AForm: TScaffoldForm)
     begin
       AForm.Title := 'Hello, World!';

       AForm.SetContentAsFrame<TMyDatasetListFrame>;

       AForm.AddActionButton(ImageList1, 1
       , procedure
         begin
           ShowMessage('Clicked the star!');
         end
       );
     end
  ) // route definition

  .DefineRoute<TScaffoldForm>(
     'detail'
   , procedure (AForm: TScaffoldForm)
     begin
       AForm.Title := 'Employee';

       AForm.SetContentAsFrame<TMyDataSetDetailFrame>;

       AForm.AddActionButton(ImageList1, 0
       , procedure
         begin
           Navigator.CloseRoute('detail');
         end
       );
     end
   , nil
   , 'slideRightLeft'
  ) // route definition

  .RouteTo('home'); // initial route
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

procedure TMainForm.FormStand1BeforeStartAnimation(const ASender: TSubjectStand;
  const ASubjectInfo: TSubjectInfo; const AAnimation: TAnimation);
begin
  if ASubjectInfo.StandStyleName = 'slideRightLeft' then
  begin
    if SameText(AAnimation.StyleName, 'OnShow_SlideLR') then
      (AAnimation as TFloatAnimation).StartValue := ASubjectInfo.Stand.Width;
  end;
end;

end.
