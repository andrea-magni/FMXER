unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.MediaLibrary.Actions, FMX.Graphics;

type
  TQRCodeContentListener = reference to procedure (const AContent: string);

  TMainData = class(TDataModule)
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
  private
    FQRCodeContentListeners: TArray<TQRCodeContentListener>;
    FQRCodeContent: string;
  protected
    procedure NotifyQRCodeContent;
    procedure SetQRCodeContent(const Value: string);
  public
    procedure SubscribeQRCodeContent(const AProc: TQRCodeContentListener);
    procedure ShareQRCodeContent;

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
  end;

  function MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses QRCode.Utils, Forms.Main;

var
  _Instance: TMainData = nil;

function MainData: TMainData;
begin
  if not Assigned(_Instance) then
    _Instance := TMainData.Create(nil);
  Result := _Instance;
end;

{ TMainData }

procedure TMainData.NotifyQRCodeContent;
begin
  for var LListener in FQRCodeContentListeners do
    LListener(FQRCodeContent);
end;

procedure TMainData.SetQRCodeContent(const Value: string);
begin
  if FQRCodeContent <> Value then
  begin
    FQRCodeContent := Value;
    NotifyQRCodeContent;
  end;
end;

procedure TMainData.ShareQRCodeContent;
begin
  SvgToBitmap(
    TQRCode.TextToSvg(QRCodeContent)
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

procedure TMainData.SubscribeQRCodeContent(const AProc: TQRCodeContentListener);
begin
  FQRCodeContentListeners := FQRCodeContentListeners + [AProc];
end;

end.
