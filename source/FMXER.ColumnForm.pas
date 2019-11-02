unit FMXER.ColumnForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  Generics.Collections
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc;

type
  TColumnForm = class(TForm)
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
    ContentLayout: TLayout;
    Stands: TStyleBook;
  private
    FElements: TList<TSubjectInfoContainer>;
    FElementStand: string;
  public
    const DEFAULT_ELEMENT_HEIGHT = 200;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddFrame<T: TFrame>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
      const AConfigProc: TProc<T> = nil); overload;
    procedure AddFrame<T: TFrame>(const AColDef: TElementDef<T>); overload;

    procedure AddForm<T: TForm>(const AHeight: Integer = DEFAULT_ELEMENT_HEIGHT;
      const AConfigProc: TProc<T> = nil); overload;
    procedure AddForm<T: TForm>(const AColDef: TElementDef<T>); overload;

    property ElementStand: string read FElementStand write FElementStand;
    property Elements: TList<TSubjectInfoContainer> read FElements;
  end;

implementation

{$R *.fmx}


{ TCenterForm }

procedure TColumnForm.AddForm<T>(const AHeight: Integer; const AConfigProc: TProc<T>);
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


procedure TColumnForm.AddFrame<T>(const AHeight: Integer; const AConfigProc: TProc<T>);
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

procedure TColumnForm.AddForm<T>(const AColDef: TElementDef<T>);
begin
  AddForm<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
end;

procedure TColumnForm.AddFrame<T>(const AColDef: TElementDef<T>);
begin
  AddFrame<T>(
    AColDef.ParamByName('Height', DEFAULT_ELEMENT_HEIGHT).AsInteger
  , AColDef.ConfigProc);
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

end.
