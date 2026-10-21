unit FMXER.ChoicesFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, System.Skia, FMX.Skia
, SubjectStand;

type
  /// <summary>The content of TModals.Choose (a Flutter modal bottom sheet with
  /// a list): an optional title and one item per choice; a tap on an item sets
  /// Chosen and the ModalResult of the sheet (mrOk).</summary>
  TChoicesFrame = class(TFrame)
    TitleLabel: TSkLabel;
    ItemsBox: TVertScrollBox;
  private
    FItems: TList<TSkLabel>;
    FChosen: Integer;
    FItemHeight: Single;
    procedure ItemClick(Sender: TObject);
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function SetTitle(const ATitle: string): TChoicesFrame;
    function SetChoices(const AChoices: TArray<string>): TChoicesFrame;
    /// <summary>The height the content needs (the sheet is sized on it).</summary>
    function GetPreferredHeight: Single;
    /// <summary>The index of the choice tapped, -1 for none.</summary>
    property Chosen: Integer read FChosen;
    property Items: TList<TSkLabel> read FItems;
    property ItemHeight: Single read FItemHeight write FItemHeight;
  end;

implementation

{$R *.fmx}

{ TChoicesFrame }

constructor TChoicesFrame.Create(AOwner: TComponent);
begin
  inherited;
  FItems := TList<TSkLabel>.Create;
  FChosen := -1;
  FItemHeight := 48;
end;

destructor TChoicesFrame.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TChoicesFrame.GetPreferredHeight: Single;
begin
  Result := FItems.Count * FItemHeight;
  if TitleLabel.Visible then
    Result := Result + TitleLabel.Height;
end;

procedure TChoicesFrame.ItemClick(Sender: TObject);
begin
  FChosen := (Sender as TSkLabel).Tag;
  if Assigned(SI) then
    SI.ModalResult := mrOk;
end;

function TChoicesFrame.SetChoices(const AChoices: TArray<string>): TChoicesFrame;
var
  LItem: TSkLabel;
  LIndex: Integer;
begin
  Result := Self;
  for LItem in FItems do
    LItem.Free;
  FItems.Clear;
  for LIndex := 0 to High(AChoices) do
  begin
    LItem := TSkLabel.Create(Self);
    LItem.Position.Y := 100000;   // after the other items
    LItem.Parent := ItemsBox;
    LItem.Align := TAlignLayout.Top;
    LItem.AutoSize := False;
    LItem.Height := FItemHeight;
    LItem.HitTest := True;
    LItem.Cursor := crHandPoint;
    LItem.StyledSettings := [TStyledSetting.Family];
    LItem.TextSettings.Font.Size := 16;
    LItem.TextSettings.FontColor := $DE000000;
    LItem.TextSettings.VertAlign := TTextAlign.Center;
    LItem.Text := AChoices[LIndex];
    LItem.Tag := LIndex;
    LItem.OnClick := ItemClick;
    FItems.Add(LItem);
  end;
end;

function TChoicesFrame.SetTitle(const ATitle: string): TChoicesFrame;
begin
  Result := Self;
  TitleLabel.Text := ATitle;
  TitleLabel.Visible := not ATitle.IsEmpty;
end;

end.
