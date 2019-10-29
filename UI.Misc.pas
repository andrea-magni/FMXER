unit UI.Misc;

interface

uses
  Classes, SysUtils, FMX.Layouts, SubjectStand;

type
  TSubjectInfoContainer = class(TLayout)
  private
    FSubjectInfo: TSubjectInfo;
  protected
  public
    property SubjectInfo: TSubjectInfo read FSubjectInfo write FSubjectInfo;
  end;

implementation

end.
