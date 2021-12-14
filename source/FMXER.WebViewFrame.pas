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
    procedure SetHTML(const Value: string);
    function GetURL: string;
    procedure SetURL(const Value: string);
    { Private declarations }
  public
    { Public declarations }
    property HTML: string read FHTML write SetHTML;
    property URL: string read GetURL write SetURL;
  end;

implementation

{$R *.fmx}

{ TWebViewFrame }

function TWebViewFrame.GetURL: string;
begin
  Result := WebBrowser1.URL;
end;

procedure TWebViewFrame.SetHTML(const Value: string);
begin
  FHTML := Value;
  WebBrowser1.LoadFromStrings(FHTML, '');
end;

procedure TWebViewFrame.SetURL(const Value: string);
begin
  WebBrowser1.URL := Value;
end;

end.
