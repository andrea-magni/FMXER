unit Routes.home;

interface

procedure DefineHomeRoute;

implementation

uses
  FMXER.Navigator
, FMXER.ScaffoldForm
, Frames.Spinner
;

procedure DefineHomeRoute;
begin
  Navigator.DefineRoute<TScaffoldForm>('home'
  , procedure (AHome: TScaffoldForm)
    begin
      AHome.Title := 'Welcome home!';

      AHome.SetContentAsFrame<TSpinnerFrame>;
    end
  );
end;

end.
