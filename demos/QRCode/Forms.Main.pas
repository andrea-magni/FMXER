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
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMXER.Navigator
, Routes.home
, Routes.colorPicker
, Routes.QRGenerator
, Routes.QRReader
, Data.Main
;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1);

  DefineHomeRoute('home');

  DefineQRGeneratorRoute('QRGenerator');
  DefineQRReaderRoute('QRReader');

  DefineColorPickerRoute('QRCodeColorSelection'
  , 'Foreground color'
  , function : TAlphaColor
    begin
      Result := MainData.QRCodeColor;
    end
  , procedure (AColor: TAlphaColor)
    begin
      MainData.QRCodeColor := AColor;
    end
  );
  DefineColorPickerRoute('QRCodeBGColorSelection'
  , 'Background color'
  , function : TAlphaColor
    begin
      Result := MainData.QRCodeBGColor;
    end
  , procedure (AColor: TAlphaColor)
    begin
      MainData.QRCodeBGColor := AColor;
    end
  );

  Navigator.OnCloseRoute :=
    procedure (ARouteName: string)
    begin
      if ARouteName = 'home' then
        Close;
    end;

  Navigator.RouteTo('home');
end;

end.
