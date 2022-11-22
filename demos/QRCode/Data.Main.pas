unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Permissions, System.Types,
  Generics.Collections, SyncObjs,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, FMX.Graphics, UITypes,
  FMX.Types, FMX.Media
, ZXing.ScanManager, ZXing.BarcodeFormat, ZXing.ReadResult, ZXing.ResultPoint
, Threads.Scanner
;

type
  TMainData = class(TDataModule)
    ActionList1: TActionList;
    ShowShareSheetAction1: TShowShareSheetAction;
    RadiusFactorDeferTimer: TTimer;
    CameraComponent1: TCameraComponent;
    procedure DataModuleCreate(Sender: TObject);
    procedure RadiusFactorDeferTimerTimer(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FScannerCS: TCriticalSection;
    FQRCodeChangeListeners: TArray<TProc>;
    FImageFrameAvailableListeners: TArray<TProc<TBitmap>>;
    FQRCodeContent: string;
    FQRCodeColor: TAlphaColor;
    FQRCodeBGColor: TAlphaColor;
    FQRRadiusFactor: Single;
    FImageFrame: TBitmap;
    FPermissionCamera: string;
    FScanner: TScannerThread;
    FFrameToScanQueue: TQueue<TBitmap>;
    FScanPoints: TList<TPointF>;
    FOnScanResult: TProc<TReadResult>;
    procedure SetQRCodeColor(const Value: TAlphaColor);
    procedure SetQRRadiusFactor(const Value: Single);
    procedure SetQRCodeBGColor(const Value: TAlphaColor);
  protected
    procedure NotifyQRCodeChange;
    procedure NotifyImageFrameAvailable;
    procedure SetQRCodeContent(const Value: string);
    procedure PermissionRequestResult(Sender: TObject; const APermissions: TClassicStringDynArray; const AGrantResults: TClassicPermissionStatusDynArray);
    procedure DisplayRationale(Sender: TObject; const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
  public
    procedure SubscribeQRCodeChange(const AProc: TProc);
    procedure SubscribeImageFrameAvailable(const AProc: TProc<TBitmap>);
    procedure ClearImageFrameSubscribers;
    procedure ShareQRCodeContent;
    procedure CameraStart;
    procedure CameraStop(const AClearSubscribers: Boolean);

    // non trivial thread procedures -------------------------------------------
    procedure AddScanPoint(const APoint: TPointF);
    function ScanPoints: TArray<TPointF>;

    // NB: the caller is now the owner of the TBitmap instance
    // NB: if no frame is present in the queue, returns nil
    function DequeueFrameToScan: TBitmap;
    procedure QueueFrameForScan(const ABitmap: TBitmap);
    procedure CollectScanResult(const AResult: TReadResult);
    // -------------------------------------------------------------------------

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
    property QRCodeColor: TAlphaColor read FQRCodeColor write SetQRCodeColor;
    property QRCodeBGColor: TAlphaColor read FQRCodeBGColor write SetQRCodeBGColor;
    property QRRadiusFactor: Single read FQRRadiusFactor write SetQRRadiusFactor;
    property ImageFrame: TBitmap read FImageFrame;
    property FrameToScanQueue: TQueue<TBitmap> read FFrameToScanQueue;
    property OnScanResult: TProc<TReadResult> read FOnScanResult write FOnScanResult;

    const MAX_SCAN_POINTS = 10;
  end;

  function MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Math, FMX.Platform, FMX.DialogService
{$IFDEF ANDROID}
, Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Os
{$ENDIF}
, Skia, Skia.FMX.Graphics
, QRCode.Utils, FMXER.UI.Consts, QRCode.Render
//, CodeSiteLogging
;

var
  _Instance: TMainData = nil;

function MainData: TMainData;
begin
  if not Assigned(_Instance) then
    _Instance := TMainData.Create(nil);
  Result := _Instance;
end;

{ TMainData }

procedure TMainData.AddScanPoint(const APoint: TPointF);
begin
  FScannerCS.Enter;
  try
    while FScanPoints.Count > MAX_SCAN_POINTS do
      FScanPoints.Delete(0);

    FScanPoints.Add(APoint);
  finally
    FScannerCS.Leave;
  end;
end;

procedure TMainData.CameraComponent1SampleBufferReady(Sender: TObject;
  const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread
  , procedure
    begin
      CameraComponent1.SampleBufferToBitmap(FImageFrame, True);
    end
  );
  NotifyImageFrameAvailable;
end;

procedure TMainData.CameraStart;
begin
  if not PermissionsService.IsPermissionGranted(FPermissionCamera) then
  begin
    PermissionsService.RequestPermissions([FPermissionCamera], PermissionRequestResult, DisplayRationale);
    Exit;
  end;
  CameraComponent1.Quality := TVideoCaptureQuality.MediumQuality;
//  CameraComponent1.Kind := TCameraKind.BackCamera;
  CameraComponent1.FocusMode := TFocusMode.ContinuousAutoFocus;
  CameraComponent1.Active := True;
end;

procedure TMainData.CameraStop(const AClearSubscribers: Boolean);
begin
  if AClearSubscribers then
    ClearImageFrameSubscribers;

  CameraComponent1.Active := False;
end;

procedure TMainData.ClearImageFrameSubscribers;
begin
  FImageFrameAvailableListeners := [];
end;

procedure TMainData.CollectScanResult(const AResult: TReadResult);
begin
  if not Assigned(FOnScanResult) then
    Exit;

  TThread.Synchronize(
    nil
  , procedure
    begin
      FOnScanResult(AResult);
    end
  );
end;

procedure TMainData.DataModuleCreate(Sender: TObject);
begin
{$IFDEF ANDROID}
  FPermissionCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
{$ENDIF}
  FOnScanResult := nil;
  FScanPoints := TList<TPointF>.Create;
  FScannerCS := TCriticalSection.Create;
  FQRCodeContent := 'https://github.com/andrea-magni/FMXER';
  FQRCodeColor := TAppColors.PrimaryColor;
  FQRCodeBGColor := TAlphaColorRec.White;
  FQRRadiusFactor := 0.1;
  FQRCodeChangeListeners := [];
  FImageFrameAvailableListeners := [];
  FImageFrame := TBitmap.Create(512, 512);
  FFrameToScanQueue := TQueue<TBitmap>.Create;
  FScanner := TScannerThread.Create(False);
end;

procedure TMainData.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(FScanner) then
  begin
    FScanner.Terminate;
    FScanner.WaitFor;
  end;
  FImageFrame.Free;
  FFrameToScanQueue.Free;
  FScanPoints.Free;
  FScannerCS.Free;
end;

function TMainData.DequeueFrameToScan: TBitmap;
begin
  Result := nil;
  if FFrameToScanQueue.Count > 0 then
  begin
    FScannerCS.Enter;
    try
      Result := FFrameToScanQueue.Dequeue;
    finally
      FScannerCS.Leave;
    end;
  end;
end;

procedure TMainData.DisplayRationale(Sender: TObject;
  const APermissions: TClassicStringDynArray; const APostRationaleProc: TProc);
begin
  TDialogService.ShowMessage('The app needs to access the camera in order to work',
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc;
    end)
end;

procedure TMainData.NotifyImageFrameAvailable;
begin
  for var LListener in FImageFrameAvailableListeners do
    LListener(FImageFrame);
end;

procedure TMainData.NotifyQRCodeChange;
begin
  for var LListener in FQRCodeChangeListeners do
    LListener();
end;

procedure TMainData.PermissionRequestResult(Sender: TObject;
  const APermissions: TClassicStringDynArray;
  const AGrantResults: TClassicPermissionStatusDynArray);
begin
  // 1 permission involved: CAMERA
  if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
  begin
    { Turn on the Camera }
    CameraComponent1.Active := True;
  end
  else
    TDialogService.ShowMessage('Cannot start the camera because the required permission has not been granted');
end;

procedure TMainData.RadiusFactorDeferTimerTimer(Sender: TObject);
begin
  RadiusFactorDeferTimer.Enabled := False;
  NotifyQRCodeChange;
end;

procedure TMainData.QueueFrameForScan(const ABitmap: TBitmap);
begin
  if not Assigned(ABitmap) then
    Exit;

  FScannerCS.Enter;
  try
    FFrameToScanQueue.Enqueue(ABitmap);
  finally
    FScannerCS.Leave;
  end;
end;

function TMainData.ScanPoints: TArray<TPointF>;
begin
  if not Assigned(FScanner) then
    Exit;

  FScannerCS.Enter;
  try
    Result := FScanPoints.ToArray;
  finally
    FScannerCS.Leave;
  end;
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

procedure TMainData.SubscribeImageFrameAvailable(const AProc: TProc<TBitmap>);
begin
  FImageFrameAvailableListeners := FImageFrameAvailableListeners + [AProc];
end;

procedure TMainData.SubscribeQRCodeChange(const AProc: TProc);
begin
  FQRCodeChangeListeners := FQRCodeChangeListeners + [AProc];
end;

end.
