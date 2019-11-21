unit Data.Remote;

interface

uses
  System.SysUtils, System.Classes;

type
  TRemoteData = class(TDataModule)
  private
    FLoginPassword: string;
    FLoginUserName: string;
    FLoggedIn: Boolean;
  public
    procedure AttemptLogin(const AOnSuccess: TProc = nil; const AOnError: TProc = nil);

    property LoginUserName: string read FLoginUserName write FLoginUserName;
    property LoginPassword: string read FLoginPassword write FLoginPassword;
    property LoggedIn: Boolean read FLoggedIn;
  end;

var
  RemoteData: TRemoteData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TRemoteData }

procedure TRemoteData.AttemptLogin(const AOnSuccess: TProc; const AOnError: TProc);
begin
  if SameText('andrea', FLoginUserName) and SameText('password', FLoginPassword) then
  begin
    FLoggedIn := True;
    if Assigned(AOnSuccess) then
      AOnSuccess();
  end
  else
  begin
    FLoggedIn := False;
    if Assigned(AOnError) then
      AOnError();
  end;
end;

end.
