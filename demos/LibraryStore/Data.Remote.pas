unit Data.Remote;

interface

uses
  System.SysUtils, System.Classes
, Model, System.JSON, MARS.Client.CustomResource, MARS.Client.Resource,
  MARS.Client.Resource.JSON, MARS.Client.Application, MARS.Client.Client,
  MARS.Client.Client.Net
;

type
  TRemoteData = class(TDataModule)
    netClient: TMARSNetClient;
    defaultApplication: TMARSClientApplication;
    bookResource: TMARSClientResourceJSON;
    authorResource: TMARSClientResourceJSON;
    byAuthorResource: TMARSClientResourceJSON;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure RetrieveData<R: record>(const AResource: TMARSClientResourceJSON;
      const AName: string;
      const AOnBeforeExecute: TProc<TMARSClientResourceJSON>;
      const AOnSuccess: TProc<TArray<R>>; const AOnError: TProc<string> = nil);
  public
    selectedAuthorId: Integer;
    selectedBookId: Integer;

    procedure RetrieveBook(
      const AOnSuccess: TProc<TArray<TBook>>; const AOnError: TProc<string> = nil;
      const AOnBeforeExecute: TProc<TMARSClientResourceJSON> = nil);

    procedure RetrieveBooks(
      const AOnSuccess: TProc<TArray<TBook>>; const AOnError: TProc<string> = nil;
      const AOnBeforeExecute: TProc<TMARSClientResourceJSON> = nil);

    procedure RetrieveBooksByAuthor(const AOnSuccess: TProc<TArray<TBook>>; const AOnError: TProc<string> = nil;
      const AOnBeforeExecute: TProc<TMARSClientResourceJSON> = nil);

    procedure RetrieveAuthors(const AOnSuccess: TProc<TArray<TAuthor>>; const AOnError: TProc<string> = nil;
      const AOnBeforeExecute: TProc<TMARSClientResourceJSON> = nil);
  end;

var
  RemoteData: TRemoteData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses Utils.Msg;

{$R *.dfm}

{ TRemoteData }

procedure TRemoteData.DataModuleCreate(Sender: TObject);
begin
  {$IFDEF ANDROID}
  netClient.MARSEngineURL := 'http://192.168.68.120:8080/rest';
  {$ENDIF}
end;

procedure TRemoteData.RetrieveAuthors(const AOnSuccess: TProc<TArray<TAuthor>>;
  const AOnError: TProc<string>; const AOnBeforeExecute: TProc<TMARSClientResourceJSON>);
begin
  RetrieveData<TAuthor>(authorResource, 'authors', AOnBeforeExecute, AOnSuccess, AOnError);
end;

procedure TRemoteData.RetrieveBook(const AOnSuccess: TProc<TArray<TBook>>;
  const AOnError: TProc<string>;
  const AOnBeforeExecute: TProc<TMARSClientResourceJSON>);
begin
  bookResource.PathParamsValues.Clear;
  bookResource.PathParamsValues.Add(selectedBookId.ToString);
  RetrieveData<TBook>(bookResource, 'book', AOnBeforeExecute, AOnSuccess, AOnError);
end;

procedure TRemoteData.RetrieveBooks(const AOnSuccess: TProc<TArray<TBook>>;
  const AOnError: TProc<string>; const AOnBeforeExecute: TProc<TMARSClientResourceJSON>);
begin
  RetrieveData<TBook>(bookResource, 'books', AOnBeforeExecute, AOnSuccess, AOnError);
end;

procedure TRemoteData.RetrieveBooksByAuthor(
  const AOnSuccess: TProc<TArray<TBook>>; const AOnError: TProc<string>;
  const AOnBeforeExecute: TProc<TMARSClientResourceJSON>);
begin
  byAuthorResource.PathParamsValues.Clear;
  byAuthorResource.PathParamsValues.Add(selectedAuthorId.ToString);
  RetrieveData<TBook>(byAuthorResource, 'books', AOnBeforeExecute, AOnSuccess, AOnError);
end;

procedure TRemoteData.RetrieveData<R>(const AResource: TMARSClientResourceJSON;
  const AName: string;
  const AOnBeforeExecute: TProc<TMARSClientResourceJSON>;
  const AOnSuccess: TProc<TArray<R>>; const AOnError: TProc<string>);
begin
  TRetrieveMsg.CreateAndSend(AName + '.begin');

  if Assigned(AOnBeforeExecute) then
    AOnBeforeExecute(AResource);

  AResource.GETAsync(
    nil //AM AOnBeforeExecute should fit here
  , procedure (ARes: TMARSClientCustomResource)
    begin
      TRetrieveMsg.CreateAndSend(AName + '.end');
      var LRes := ARes as TMARSClientResourceJSON;

      if Assigned(AOnSuccess) then
        AOnSuccess(LRes.ResponseAsArray<R>);
    end
  , procedure (AException: Exception)
    begin
      TRetrieveMsg.CreateAndSend(AName + '.end');
      if Assigned(AOnError) then
        AOnError(AException.ToString);
    end
  );
end;

end.
