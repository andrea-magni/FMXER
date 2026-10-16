unit FMXER.WebViewFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.WebBrowser;

type
  TWebViewFrame = class(TFrame)
    WebBrowser1: TWebBrowser;
  private
    FHTML: string;
    procedure InternalSetHTML(const Value: string);
    function GetURL: string;
    procedure InternalSetURL(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    function SetURL(const AURL: string): TWebViewFrame;
    function SetHTML(const AHTML: string): TWebViewFrame;
    property HTML: string read FHTML write InternalSetHTML;
    property URL: string read GetURL write InternalSetURL;
  end;

implementation

{$R *.fmx}

{ TWebViewFrame }

function TWebViewFrame.GetURL: string;
begin
  Result := WebBrowser1.URL;
end;

procedure TWebViewFrame.InternalSetHTML(const Value: string);
begin
  FHTML := Value;
  WebBrowser1.LoadFromStrings(FHTML, '');
end;

procedure TWebViewFrame.InternalSetURL(const Value: string);
begin
  WebBrowser1.URL := Value;
end;

function TWebViewFrame.SetHTML(const AHTML: string): TWebViewFrame;
begin
  Result := Self;
  HTML := AHTML;
end;

function TWebViewFrame.SetURL(const AURL: string): TWebViewFrame;
begin
  Result := Self;
  URL := AURL;
end;

end.
