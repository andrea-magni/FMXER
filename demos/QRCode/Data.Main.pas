unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, FMX.Graphics, UITypes, FMX.Types;

type
  TMainData = class(TDataModule)
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    RadiusFactorDeferTimer: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure RadiusFactorDeferTimerTimer(Sender: TObject);
  private
    FQRCodeChangeListeners: TArray<TProc>;
    FQRCodeContent: string;
    FQRCodeColor: TAlphaColor;
    FQRCodeBGColor: TAlphaColor;
    FQRRadiusFactor: Single;
    procedure SetQRCodeColor(const Value: TAlphaColor);
    procedure SetQRRadiusFactor(const Value: Single);
    procedure SetQRCodeBGColor(const Value: TAlphaColor);
  protected
    procedure NotifyQRCodeChange;
    procedure SetQRCodeContent(const Value: string);
  public
    procedure SubscribeQRCodeChange(const AProc: TProc);
    procedure ShareQRCodeContent;

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
    property QRCodeColor: TAlphaColor read FQRCodeColor write SetQRCodeColor;
    property QRCodeBGColor: TAlphaColor read FQRCodeBGColor write SetQRCodeBGColor;
    property QRRadiusFactor: Single read FQRRadiusFactor write SetQRRadiusFactor;
  end;

  function MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Math, Skia,
  QRCode.Utils, FMXER.UI.Consts, QRCode.Render;

var
  _Instance: TMainData = nil;

function MainData: TMainData;
begin
  if not Assigned(_Instance) then
    _Instance := TMainData.Create(nil);
  Result := _Instance;
end;

{ TMainData }

procedure TMainData.DataModuleCreate(Sender: TObject);
begin
  FQRCodeContent := 'https://github.com/andrea-magni/FMXER';
  FQRCodeColor := TAppColors.PrimaryColor;
  FQRCodeBGColor := TAlphaColorRec.White;
  FQRRadiusFactor := 0.1;
end;

procedure TMainData.NotifyQRCodeChange;
begin
  for var LListener in FQRCodeChangeListeners do
    LListener();
end;

procedure TMainData.RadiusFactorDeferTimerTimer(Sender: TObject);
begin
  RadiusFactorDeferTimer.Enabled := False;
  NotifyQRCodeChange;
end;

procedure TMainData.SetQRCodeBGColor(const Value: TAlphaColor);
begin
  if FQRCodeBGColor <> Value then
  begin
    FQRCodeBGColor := Value;
    NotifyQRCodeChange;
  end;
end;

procedure TMainData.SetQRCodeColor(const Value: TAlphaColor);
begin
  if FQRCodeColor <> Value then
  begin
    FQRCodeColor := Value;
    NotifyQRCodeChange;
  end;
end;

procedure TMainData.SetQRCodeContent(const Value: string);
begin
  if FQRCodeContent <> Value then
  begin
    FQRCodeContent := Value;
    NotifyQRCodeChange;
  end;
end;

procedure TMainData.SetQRRadiusFactor(const Value: Single);
begin
  if (FQRRadiusFactor <> Value) then
  begin
    FQRRadiusFactor := Value;
    RadiusFactorDeferTimer.Enabled := False;
    RadiusFactorDeferTimer.Enabled := True;
  end;
end;

procedure TMainData.ShareQRCodeContent;
begin
  SvgToBitmap(
    TQRCode.TextToSvg(QRCodeContent)
  , QRCodeBGColor
  , QRCodeColor
  , 1024, 1024
  , procedure (ABitmap: TBitmap)
    begin
      {$IFDEF MSWINDOWS} ABitmap.SaveToFile('C:\temp\qrcode.jpg'); {$ENDIF}
      var LStream := TMemoryStream.Create;
      ABitmap.SaveToStream(LStream);
      LStream.Position := 0;
      ShowShareSheetAction1.Bitmap.LoadFromStream(LStream);
    end
  );

//  ShowShareSheetAction1.TextMessage := FQRCodeContent;
  ShowShareSheetAction1.Execute;
end;

procedure TMainData.SubscribeQRCodeChange(const AProc: TProc);
begin
  FQRCodeChangeListeners := FQRCodeChangeListeners + [AProc];
end;

end.
