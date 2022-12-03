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
    FScanner: TScannerThread;
    FFrameQueue: TQueue<TBitmap>;
    FScanPoints: TList<TScanPoint>;
    FLastQueued: TDateTime;
    FScanning: Boolean;
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

    // thread shared manipulation procedures -----------------------------------
    procedure AddScanPoint(const APoint: TPointF);
    function ScanPoints: TArray<TScanPoint>;
    procedure ClearScanPoints;

    // NB: the caller is now the owner of the TBitmap instance
    // NB: if no frame is present in the queue, returns nil
    function DequeueFrame: TBitmap;
    procedure QueueFrame(const ABitmap: TBitmap);
    procedure ClearFrameQueue;
    function HasFramesInQueue: Boolean;
    // -------------------------------------------------------------------------

    property QRCodeContent: string read FQRCodeContent write SetQRCodeContent;
    property QRCodeColor: TAlphaColor read FQRCodeColor write SetQRCodeColor;
    property QRCodeBGColor: TAlphaColor read FQRCodeBGColor write SetQRCodeBGColor;
    property QRRadiusFactor: Single read FQRRadiusFactor write SetQRRadiusFactor;
    property ImageFrame: TBitmap read FImageFrame;
    property ScanResultFrame: TBitmap read FScanResultFrame;
    property ScanResultPoints: TArray<TPointF> read FScanResultPoints;
    property Scanning: Boolean read FScanning;

    const MAX_SCAN_POINTS = 4;
    const QUEUE_MAX_FREQ = 10; // 10 frames per second
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
, Skia, Skia.FMX.Graphics
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
  ClearFrameQueue;
  ClearScanPoints;
end;

procedure TMainData.ClearFrameQueue;
begin
  FScannerCS.Enter;
  try
    FFrameQueue.Clear;
  finally
    FScannerCS.Leave;
  end;
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
  if not Assigned(FScanner) then
    Exit;

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

  FLastQueued := Now;
  FFrameQueue := TQueue<TBitmap>.Create;
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
  FFrameQueue.Free;
  FScanPoints.Free;
  FScannerCS.Free;
end;

function TMainData.DequeueFrame: TBitmap;
begin
  Result := nil;
  if FFrameQueue.Count > 0 then
  begin
    FScannerCS.Enter;
    try
      Result := FFrameQueue.Dequeue;
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

function TMainData.HasFramesInQueue: Boolean;
begin
  Result := FFrameQueue.Count <> 0;
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
  TThread.Synchronize(
    nil
  , procedure
    begin
      FScanResultFrame.Assign(AFrame);

      FScanResultPoints := [];
      for var LresultPoint in AScanResult.resultPoints do
        FScanResultPoints := FScanResultPoints + [PointF(LresultPoint.x, LresultPoint.y)];

      for var LListener in FScanResultListeners do
        LListener(AScanResult, AFrame);
    end
  );
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

procedure TMainData.QueueFrame(const ABitmap: TBitmap);
begin
  if not Assigned(ABitmap) then
    Exit;

  if MillisecondsBetween(FLastQueued, Now) < (1000 / QUEUE_MAX_FREQ) then
    Exit;

  FScannerCS.Enter;
  try
    var LBitmapCopy := TBitmap.Create(0, 0);
    try
      LBitmapCopy.Assign(ABitmap);
      FLastQueued := Now;
      FFrameQueue.Enqueue(LBitmapCopy);
    except
      LBitmapCopy.Free;
      raise;
    end;
  finally
    FScannerCS.Leave;
  end;
end;

function TMainData.ScanPoints: TArray<TScanPoint>;
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
