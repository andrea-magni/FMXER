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
, FMXER.ScaffoldForm, FMXER.WebViewFrame
;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1)
  .DefineRoute<TScaffoldForm>(
    'home'
  , procedure (Home: TScaffoldForm)
    begin
      Home
      .SetTitle('WebView Demo')
      .SetContentAsFrame<TWebViewFrame>(
        procedure (AWebView: TWebViewFrame)
        begin
          AWebView.URL := 'https://andreamagni.eu';
        end
      );
    end
  )
  .RouteTo('home');
end;

end.
