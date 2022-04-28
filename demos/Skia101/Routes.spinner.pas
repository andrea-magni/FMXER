unit Routes.spinner;

interface

procedure DefineSpinnerRoute;

implementation

uses
  FMXER.Navigator
, FMXER.CenterForm
, Frames.Spinner
;

procedure DefineSpinnerRoute;
begin
  Navigator.DefineRoute<TCenterForm>('spinner'
  , procedure (AForm: TCenterForm)
    begin
      AForm.SetContentAsFrame<TSpinnerFrame>(300, 300);
    end
  );
end;

end.
