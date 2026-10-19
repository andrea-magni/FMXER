unit Data.Main;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Permissions, System.Types,
  Generics.Collections, SyncObjs,
  FMX.ActnList, FMX.StdActns, FMX.MediaLibrary.Actions, FMX.Graphics, UITypes,
  FMX.Types, FMX.Media
, ZXing.ScanManager, ZXing.BarcodeFormat, ZXing.ReadResult, ZXing.ResultPoint
;

type
  TScanPoint = record
    PointF: TPointF;
    TimeStamp: TDatetime;
    constructor Create(APointF: TPointF; ATimeStamp: TDateTime);
  end;

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
    FScanResultListeners: TArray<TProc<TReadResult, TBitmap>>;
    FQRCodeContent: string;
    FQRCodeColor: TAlphaColor;
    FQRCodeBGColor: TAlphaColor;
    FQRRadiusFactor: Single;
    FImageFrame: TBitmap;
    FScanResultFrame: TBitmap;
    FScanResultPoints: TArray<TPointF>;
    FPermissionCamera: string;
    // ZXing.Delphi 4: one scan manager for every frame, decoding in background
    // (ScanAsync); held as interface, it lives while a scan runs
    FScanManager: IScanManager;
    FScanFrame: TBitmap; // the frame being decoded
    FScanPoints: TList<TScanPoint>;
    FLastScan: TDateTime;
    FScanning: Boolean;
    procedure OnResultPointHandler(const APoint: TResultPoint);
    procedure SetQRCodeColor(const Value: TAlphaColor);
    procedure SetQRRadiusFactor(const Value: Single);
    procedure SetQRCodeBGColor(const Value: TAlphaColor);
  protected
    procedure NotifyQRCodeChange;
    procedure NotifyImageFrameAvailable;

    procedure SetQRCodeContent(const Value: string);

    procedure PermissionRequestResult(Sender: TObject;
      const APermissions: TClassicStringDynArray;
      const AGrantResults: TClassicPermissionStatusDynArray);
    procedure DisplayRationale(Sender: TObject;
      const APermissions: TClassicStringDynArray;
      const APostRationaleProc: TProc);
  public
    procedure ClearImageFrameSubscribers;
    procedure ClearScanResultSubscribers;
    procedure ClearQRCodeChangeSubscribers;

    procedure NotifyScanResult(const AScanResult: TReadResult;
      const AFrame: TBitmap);

    procedure ShareQRCodeContent;

    procedure StartCameraScanning(const AImageFrameAvailable: TProc<TBitmap>;
      const AScanResult: TProc<TReadResult, TBitmap>);
    procedure StopCameraScanning(const AClearSubscribers: Boolean);
    function HasTorch: Boolean;
    procedure ToggleTorch;

    function SubscribeQRCodeChange(const AProc: TProc): TMainData;
    function SubscribeImageFrameAvailable(const AProc: TProc<TBitmap>): TMainData;
    function SubscribeScanResult(const AProc: TProc<TReadResult, TBitmap>): TMainData;

    /// <summary>Scans a camera frame in background (at most SCAN_MAX_FREQ per second,
    /// one at a time: a frame that comes while a scan runs is skipped). The pixels
    /// are taken before returning: the caller keeps the bitmap.</summary>
    procedure ScanFrame(const ABitmap: TBitmap);

    // the points found while scanning (they come from the decoding tasks) -----
    procedure AddScanPoint(const APoint: TPointF);
    function ScanPoints: TArray<TScanPoint>;
    procedure ClearScanPoints;
    // -------------------------------------------------------------------------

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
    property QRCodeColor: TAlphaColor read FQRCodeColor write SetQRCodeColor;
    property QRCodeBGColor: TAlphaColor read FQRCodeBGColor write SetQRCodeBGColor;
    property QRRadiusFactor: Single read FQRRadiusFactor write SetQRRadiusFactor;
    property ImageFrame: TBitmap read FImageFrame;
    property ScanResultFrame: TBitmap read FScanResultFrame;
    /// <summary>The corners of the code read, in the frame</summary>
    property ScanResultPoints: TArray<TPointF> read FScanResultPoints;
    property Scanning: Boolean read FScanning;

    const MAX_SCAN_POINTS = 4;
    const SCAN_MAX_FREQ = 10; // 10 frames per second
  end;

  function MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Math, DateUtils, FMX.Platform, FMX.DialogService
{$IFDEF ANDROID}
, Androidapi.Helpers, Androidapi.JNI.JavaTypes, Androidapi.JNI.Os
{$ENDIF}
, System.Skia, FMX.Skia.Canvas
, QRCode.Utils, FMXER.UI.Consts, QRCode.Render
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

    FScanPoints.Add(TScanPoint.Create(APoint, Now));
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

procedure TMainData.StartCameraScanning(const AImageFrameAvailable: TProc<TBitmap>;
  const AScanResult: TProc<TReadResult, TBitmap>);
begin
  // permissions
  if not PermissionsService.IsPermissionGranted(FPermissionCamera) then
  begin
    PermissionsService.RequestPermissions([FPermissionCamera], PermissionRequestResult, DisplayRationale);
    Exit;
  end;

  // listeners
  SubscribeImageFrameAvailable(AImageFrameAvailable);
  SubscribeScanResult(AScanResult);

  // setup camera
  CameraComponent1.Quality := TVideoCaptureQuality.MediumQuality;
  CameraComponent1.FocusMode := TFocusMode.ContinuousAutoFocus;
  CameraComponent1.Active := True;
  FScanning := True;
end;

procedure TMainData.StopCameraScanning(const AClearSubscribers: Boolean);
begin
  FScanning := False;
  if AClearSubscribers then
  begin
    ClearImageFrameSubscribers;
    ClearScanResultSubscribers;
  end;

  CameraComponent1.Active := False;
  ClearScanPoints;
end;

procedure TMainData.ClearImageFrameSubscribers;
begin
  FImageFrameAvailableListeners := [];
end;

procedure TMainData.ClearQRCodeChangeSubscribers;
begin
  FQRCodeChangeListeners := [];
end;

procedure TMainData.ClearScanPoints;
begin
  FScannerCS.Enter;
  try
    FScanPoints.Clear;
  finally
    FScannerCS.Leave;
  end;
end;

procedure TMainData.ClearScanResultSubscribers;
begin
  FScanResultListeners := [];
end;

procedure TMainData.DataModuleCreate(Sender: TObject);
begin
{$IFDEF ANDROID}
  FPermissionCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
{$ENDIF}
  FScanPoints := TList<TScanPoint>.Create;
  FScannerCS := TCriticalSection.Create;
  FScanning := False;

  FScanResultFrame := TBitmap.Create(512, 512);
  FScanResultPoints := [];

  FQRCodeContent := 'https://github.com/andrea-magni/FMXER';
  FQRCodeColor := TAlphaColorRec.Black;
  FQRCodeBGColor := TAlphaColorRec.White;
  FQRRadiusFactor := 0.1;

  FQRCodeChangeListeners := [];
  FImageFrameAvailableListeners := [];
  FScanResultListeners := [];

  FImageFrame := TBitmap.Create(512, 512);

  FLastScan := Now;
  FScanFrame := TBitmap.Create;
  FScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);
  // set handler for on-scanning point tracking
  FScanManager.OnResultPoint := OnResultPointHandler;
end;

procedure TMainData.DataModuleDestroy(Sender: TObject);
begin
  // a running scan calls back through TThread.Synchronize: let it complete
  // before the data module (referenced by the callback) goes away
  while Assigned(FScanManager) and FScanManager.Scanning do
    CheckSynchronize(10);
  FScanManager := nil;
  FScanFrame.Free;
  FScanResultFrame.Free;
  FImageFrame.Free;
  FScanPoints.Free;
  FScannerCS.Free;
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

function TMainData.HasTorch: Boolean;
begin
  Result := CameraComponent1.HasTorch;
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

procedure TMainData.NotifyScanResult(const AScanResult: TReadResult;
  const AFrame: TBitmap);
begin
  // main thread (the callback of ScanAsync)
  FScanResultFrame.Assign(AFrame);

  // the 4 corners of the code (estimated from the result points when the
  // reader does not set them)
  FScanResultPoints := [];
  for var LCorner in AScanResult.Position do
    FScanResultPoints := FScanResultPoints + [PointF(LCorner.x, LCorner.y)];

  for var LListener in FScanResultListeners do
    LListener(AScanResult, AFrame);
end;

procedure TMainData.OnResultPointHandler(const APoint: TResultPoint);
begin
  // called by the decoding tasks
  if not APoint.IsNone then
    AddScanPoint(PointF(APoint.x, APoint.y));
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

procedure TMainData.ScanFrame(const ABitmap: TBitmap);
begin
  if not Assigned(ABitmap) or ABitmap.IsEmpty or FScanManager.Scanning then
    Exit;

  if MillisecondsBetween(FLastScan, Now) < (1000 / SCAN_MAX_FREQ) then
    Exit;
  FLastScan := Now;

  FScanFrame.Assign(ABitmap); // the frame shown with the result
  FScanManager.ScanAsync(ABitmap
  , procedure (AResult: TReadResult)
    begin
      // main thread; nil when nothing was read
      if not Assigned(AResult) then
        Exit;
      try
        if FScanning then
          NotifyScanResult(AResult, FScanFrame);
      finally
        AResult.Free;
      end;
    end
  );
end;

function TMainData.ScanPoints: TArray<TScanPoint>;
begin
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
      var LStream := TMemoryStream.Create;
      try
        ABitmap.SaveToStream(LStream);
        LStream.Position := 0;
        ShowShareSheetAction1.Bitmap.LoadFromStream(LStream);
      finally
        LStream.Free;
      end;
    end
  );

//  ShowShareSheetAction1.TextMessage := FQRCodeContent;
  ShowShareSheetAction1.Execute;
end;

function TMainData.SubscribeImageFrameAvailable(const AProc: TProc<TBitmap>): TMainData;
begin
  Result := Self;
  if Assigned(AProc) then
    FImageFrameAvailableListeners := FImageFrameAvailableListeners + [AProc];
end;

function TMainData.SubscribeQRCodeChange(const AProc: TProc): TMainData;
begin
  Result := Self;
  if Assigned(AProc) then
    FQRCodeChangeListeners := FQRCodeChangeListeners + [AProc];
end;

function TMainData.SubscribeScanResult(
  const AProc: TProc<TReadResult, TBitmap>): TMainData;
begin
  Result := Self;
  if Assigned(AProc) then
    FScanResultListeners := FScanResultListeners + [AProc];
end;

procedure TMainData.ToggleTorch;
begin
  if CameraComponent1.TorchMode = TTorchMode.ModeOn then
    CameraComponent1.TorchMode := TTorchMode.ModeOff
  else
    CameraComponent1.TorchMode := TTorchMode.ModeOn;
end;

{ TScanPoint }

constructor TScanPoint.Create(APointF: TPointF; ATimeStamp: TDateTime);
begin
  PointF := APointF;
  TimeStamp := ATimeStamp;
end;

end.
