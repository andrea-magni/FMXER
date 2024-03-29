unit Threads.Scanner;

interface

uses
  Classes, SysUtils, Types, UITypes, Generics.Collections
, ZXing.ScanManager, ZXing.BarcodeFormat, ZXing.ReadResult, ZXing.ResultPoint
;

type
  TScannerThread = class(TThread)
  private
    procedure OnResultPointHandler(const APoint: IResultPoint);
  protected
    procedure Execute; override;
  public
  end;

implementation

uses
  Data.Main;

{ TScannerThread }


procedure TScannerThread.Execute;
begin
  inherited;
  // Init ZXing
  var LScanManager := TScanManager.Create(TBarcodeFormat.QR_CODE, nil);
  try
    // set handler for on-scanning point tracking
    LScanManager.OnResultPoint := OnResultPointHandler;

    // this thread runs forever, waiting for frames to process
    while not Terminated do
    begin
      // check if there's a frame to process
      if MainData.HasFramesInQueue then
      begin
        // extract the frame
        var LFrameBitmap := MainData.DequeueFrame;
        try
          try
            // process the frame
            var LReadResult := LScanManager.Scan(LFrameBitmap);
            if Assigned(LReadResult) then
              try
                MainData.NotifyScanResult(LReadResult, LFrameBitmap);
              finally
                FreeAndNil(LReadResult);
              end;
          except
            // keep scanning errors bounded here
          end;
        finally
          LFrameBitmap.Free;
        end;
      end
      else
        Sleep(25);
    end;

  finally
    FreeAndNil(LScanManager);
  end;
end;

procedure TScannerThread.OnResultPointHandler(const APoint: IResultPoint);
begin
  MainData.AddScanPoint(PointF(APoint.x, APoint.y));
end;

end.
