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

  var LScanManager := TScanManager.Create(TBarcodeFormat.Auto, nil);
  try
    LScanManager.OnResultPoint := OnResultPointHandler;

    while not Terminated do
    begin

      var LFrameBitmap := MainData.DequeueFrameToScan;
      if Assigned(LFrameBitmap) then
      begin
        var LReadResult := LScanManager.Scan(LFrameBitmap);
        try
          if Assigned(LReadResult) then
          begin
            MainData.CollectScanResult(LReadResult);
          end;
        finally
          FreeAndNil(LReadResult);
        end;
      end
      else
        Sleep(50);
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
