unit Model;

interface

uses
  Classes, SysUtils;

type
  TAuthor = record
    id: Integer;
    Name: string;
    Surname: string;
  end;

  TBook = record
    id: Integer;
    Title: string;
    Description: string;
    Author: TAuthor;
  end;

implementation

end.
