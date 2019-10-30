unit Forms.Column;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts
, SubjectStand, Generics.Collections, FormStand, FrameStand, UI.Misc;

type
  TColElementDef<T> = record
    Height: Integer;
    ConfigProc: TProc<T>;
    constructor Create(const AHeight: Integer; const AConfigProc: TProc<T> = nil);
  end;

  TColumnForm = class(TForm)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    ContentLayout: TLayout;
    Stands: TStyleBook;
  private
    FElements: TList<TSubjectInfoContainer>;
    FElementStand: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddElementAsFrame<T: TFrame>(const AHeight: Integer = 200;
      const AConfigProc: TProc<T> = nil); overload;

    procedure AddElementAsFrame<T: TFrame>(const AColElDef: TColElementDef<T>); overload;

    procedure AddElementAsForm<T: TForm>(const AHeight: Integer = 200;
      const AConfigProc: TProc<T> = nil);

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}


{ TCenterForm }

procedure TColumnForm.AddElementAsForm<T>(const AHeight: Integer; const AConfigProc: TProc<T>);
var
  LElement: TSubjectInfo;
  LElementContainer: TSubjectInfoContainer;
begin
  Height := Height + AHeight;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.Y := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Height := AHeight;
    LElementContainer.Align := TAlignLayout.Top;

    LElementContainer.SubjectInfo :=
      FormStand1.NewAndShow<T>(LElementContainer, ElementStand
      , procedure (AElement: T)
        begin
          if Assigned(AConfigProc) then
            AConfigProc(AElement);
        end
      );

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;


procedure TColumnForm.AddElementAsFrame<T>(const AHeight: Integer; const AConfigProc: TProc<T>);
var
  LElementContainer: TSubjectInfoContainer;
begin
  Height := Height + AHeight;

  LElementContainer := TSubjectInfoContainer.Create(Self);
  try
    LElementContainer.Position.Y := 10000;
    LElementContainer.Parent := ContentLayout;
    LElementContainer.Height := AHeight;
    LElementContainer.Align := TAlignLayout.Top;

    LElementContainer.SubjectInfo :=
      FrameStand1.NewAndShow<T>(LElementContainer, ElementStand
      , procedure (AElement: T)
        begin
          if Assigned(AConfigProc) then
            AConfigProc(AElement);
        end
      );

    FElements.Add(LElementContainer);
  except
    LElementContainer.Free;
    raise;
  end;
end;

procedure TColumnForm.AddElementAsFrame<T>(const AColElDef: TColElementDef<T>);
begin
  AddElementAsFrame<T>(AColElDef.Height, AColElDef.ConfigProc);
end;

constructor TColumnForm.Create(AOwner: TComponent);
begin
  inherited;
  FElements := TList<TSubjectInfoContainer>.Create;
  Height := 1;
end;

destructor TColumnForm.Destroy;
begin
  FrameStand1.CloseAll();
  FreeAndNil(FElements);
  inherited;
end;


{ TColElementDef<T> }

constructor TColElementDef<T>.Create(const AHeight: Integer;
  const AConfigProc: TProc<T>);
begin
  Height := AHeight;
  ConfigProc := AConfigProc;
end;

end.
