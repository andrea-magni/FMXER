unit Data.Main;

interface

uses
  System.SysUtils, System.Classes;

type
  TMainData = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainData: TMainData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
