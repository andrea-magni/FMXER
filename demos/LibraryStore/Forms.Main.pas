unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListView.Appearances

, FrameStand, SubjectStand, FormStand;

type
  TMainForm = class(TForm)
    FormStand1: TFormStand;
    FrameStand1: TFrameStand;
    Stands: TStyleBook;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.UI.Misc
, FMXER.Navigator
, Routes.Home, Routes.Books, Routes.Authors, Routes.Bubbles, Routes.Book;

{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  Navigator(FormStand1);

  HomeRouteDefinition;
  BookRouteDefinition;
  BooksAllRouteDefinition;
  BooksByAuthorRouteDefinition();
  AuthorsRouteDefinition;
  BubblesRouteDefinition;

  Navigator.RouteTo('home');

end;

end.
