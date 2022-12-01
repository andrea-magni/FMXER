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
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
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
      {$IFDEF MSWINDOWS}
      Caption := string.Join(' - ', Navigator.Breadcrumb);
      {$ENDIF}
    end
  ).SetOnCreateRoute(
    procedure (ARouteName: string)
    begin
      {$IFDEF MSWINDOWS}
      Caption := string.Join(' - ', Navigator.Breadcrumb);
      {$ENDIF}
    end
  );

  // Start ---------------------------------------------------------------------
  Navigator.RouteTo('home');
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (Key = vkBack) {$IFDEF MSWINDOWS}or (Key = vkEscape){$ENDIF} then
  begin
    if (Navigator.ActiveRoutes.Count > 1) then
      Navigator.StackPop;
  end;
end;

end.
