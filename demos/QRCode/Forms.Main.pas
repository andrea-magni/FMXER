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
, Routes.Webview
, Data.Main
, Routes.SingleFrame;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Initialization ------------------------------------------------------------
  Navigator(FormStand1);

  // Route definitions ---------------------------------------------------------
  DefineHomeRoute('home');
  DefineQRGeneratorRoute('QRGenerator');
  DefineQRReaderRoute('QRReader');
  DefineWebviewRoute('Webview');
  DefineSingleFrameRoute('SingleFrame');
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

  // Navigation events ---------------------------------------------------------
  Navigator.SetOnCloseRoute(
    procedure (ARouteName: string)
    begin
      if ARouteName = 'QRReader' then
        MainData.StopCameraScanning(True);
      if ARouteName = 'home' then
        Close;

      Caption := string.Join(' - ', Navigator.Breadcrumb);
    end
  ).SetOnCreateRoute(
    procedure (ARouteName: string)
    begin
      Caption := string.Join(' - ', Navigator.Breadcrumb);
    end
  );

  // Start ---------------------------------------------------------------------
  Navigator.RouteTo('home');
end;

end.
