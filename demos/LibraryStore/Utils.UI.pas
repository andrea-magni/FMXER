unit Utils.UI;

interface

uses
  Classes, SysUtils, UITypes, FMX.Graphics, IOUtils;

type
  TUIUtils = class
  private
    class var _Instance: TUIUtils;
  protected
    class function GetInstance: TUIUtils; static;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    class property Instance: TUIUtils read GetInstance;
    class destructor ClassDestroy;
  private
    FBookImageIndex: Integer;
    FAuthorImageIndex: Integer;
    FChangePasswordImageIndex: Integer;
    FBackImageIndex: Integer;
    function GetBookImageIndex: Integer;
    function GetAuthorImageIndex: Integer;
    function GetBackImageIndex: Integer;
    function GetChangePasswordImageIndex: Integer;
  public
    property ChangePasswordImageIndex: Integer read GetChangePasswordImageIndex;
    property BookImageIndex: Integer read GetBookImageIndex;
    property AuthorImageIndex: Integer read GetAuthorImageIndex;
    property BackImageIndex: Integer read GetBackImageIndex;
  end;

  function UIUtils: TUIUtils;

implementation

uses
  FMXER.IconFontsData, System.Types
, FMXER.UI.Consts
;


function UIUtils: TUIUtils;
begin
  Result := TUIUtils.Instance;
end;

{ TUIUtils }

class destructor TUIUtils.ClassDestroy;
begin
  if Assigned(_Instance) then
    FreeAndNil(_Instance);
end;

constructor TUIUtils.Create;
begin
  inherited Create;
  FChangePasswordImageIndex := -1;
  FBookImageIndex := -1;
  FAuthorImageIndex := -1;
  FBackImageIndex := -1;
end;

destructor TUIUtils.Destroy;
begin
  inherited;
end;

function TUIUtils.GetBackImageIndex: Integer;
begin
  if FBackImageIndex = -1 then
    FBackImageIndex := IconFonts.AddIcon(IconFonts.MD.arrow_left, TAlphaColorRec.Black);
  Result := FBackImageIndex;
end;

function TUIUtils.GetChangePasswordImageIndex: Integer;
begin
  if FChangePasswordImageIndex = -1 then
    FChangePasswordImageIndex := IconFonts.AddIcon(IconFonts.MD.form_textbox_password, TAlphaColorRec.Black);
  Result := FChangePasswordImageIndex;
end;

function TUIUtils.GetBookImageIndex: Integer;
begin
  if FBookImageIndex = -1 then
    FBookImageIndex := IconFonts.AddIcon(IconFonts.MD.book, TAppColors.PrimaryColor);
  Result := FBookImageIndex;
end;

function TUIUtils.GetAuthorImageIndex: Integer;
begin
  if FAuthorImageIndex = -1 then
    FAuthorImageIndex := IconFonts.AddIcon(IconFonts.MD.account, TAppColors.PrimaryColor);
  Result := FAuthorImageIndex;
end;

class function TUIUtils.GetInstance: TUIUtils;
begin
  if not Assigned(_Instance) then
    _Instance := TUIUtils.Create;
  Result := _Instance;
end;

end.
