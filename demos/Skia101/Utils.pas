unit Utils;

interface

uses
  System.Classes, System.SysUtils;

function LocalFile(const AFileName: string): string;

implementation

uses
  System.IOUtils;

function LocalFile(const AFileName: string): string;
begin
  {$IFDEF MSWINDOWS}
  Result := '..\..\..\..\media\' + AFileName;
  {$ELSE}
  Result := TPath.Combine(TPath.GetDocumentsPath, AFileName);
  {$ENDIF}
end;


end.
