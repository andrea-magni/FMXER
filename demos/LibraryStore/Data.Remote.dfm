object RemoteData: TRemoteData
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object netClient: TMARSNetClient
    MARSEngineURL = 'http://localhost:8080/rest'
    ConnectTimeout = 15000
    ReadTimeout = 30000
    AuthCookieName = 'access_token'
    ProxyConfig.Enabled = False
    ProxyConfig.Port = 0
    HttpClient.ConnectionTimeout = 15000
    HttpClient.ResponseTimeout = 30000
    HttpClient.Accept = 'application/json'
    HttpClient.ContentType = 'application/json'
    HttpClient.UserAgent = 'Embarcadero URI Client/1.0'
    Left = 48
    Top = 8
  end
  object defaultApplication: TMARSClientApplication
    DefaultMediaType = 'application/json'
    DefaultContentType = 'application/json'
    Client = netClient
    Left = 48
    Top = 72
  end
  object bookResource: TMARSClientResourceJSON
    Application = defaultApplication
    SpecificAccept = 'application/json'
    SpecificContentType = 'application/json'
    Resource = 'book'
    PathParamsValues.Strings = (
      'all')
    Left = 48
    Top = 136
  end
  object authorResource: TMARSClientResourceJSON
    Application = defaultApplication
    SpecificAccept = 'application/json'
    SpecificContentType = 'application/json'
    Resource = 'author'
    PathParamsValues.Strings = (
      'all')
    Left = 144
    Top = 136
  end
  object byAuthorResource: TMARSClientResourceJSON
    Application = defaultApplication
    SpecificAccept = 'application/json'
    SpecificContentType = 'application/json'
    Resource = 'book/byAuthor/'
    Left = 48
    Top = 208
  end
end
