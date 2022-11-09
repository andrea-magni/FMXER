unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, FMX.Graphics, UITypes;

type
  TQRCodeChangeListener = reference to procedure (const AContent: string; const AColor: TAlphaColor);

  TMainData = class(TDataModule)
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    procedure DataModuleCreate(Sender: TObject);
  private
    FQRCodeChangeListeners: TArray<TQRCodeChangeListener>;
    FQRCodeContent: string;
    FQRCodeColor: TAlphaColor;
    procedure SetQRCodeColor(const Value: TAlphaColor);
  protected
    procedure NotifyQRCodeChange;
    procedure SetQRCodeContent(const Value: string);
  public
    procedure SubscribeQRCodeChange(const AProc: TQRCodeChangeListener);
    procedure ShareQRCodeContent;

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
    property QRCodeColor: TAlphaColor read FQRCodeColor write SetQRCodeColor;
  end;

  function MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses QRCode.Utils, Forms.Main, FMXER.UI.Consts, QRCode.Render, Skia;

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
end;

procedure TMainData.NotifyQRCodeChange;
begin
  for var LListener in FQRCodeChangeListeners do
    LListener(FQRCodeContent, FQRCodeColor);
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

procedure TMainData.ShareQRCodeContent;
begin
  SvgToBitmap(
    TQRCode.TextToSvg(QRCodeContent)
  , QRCodeColor
  , 300, 300
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

procedure TMainData.SubscribeQRCodeChange(const AProc: TQRCodeChangeListener);
begin
  FQRCodeChangeListeners := FQRCodeChangeListeners + [AProc];
end;

end.
