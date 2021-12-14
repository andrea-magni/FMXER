unit FMXER.ListViewFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, Generics.Collections;

type
  TListViewFrame = class(TFrame)
    ListView: TListView;
    procedure ListViewItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ListViewPullRefresh(Sender: TObject);
  private
    FOnSelectHandlers: TDictionary<TListViewItem, TProc>;
    FItemBuilderProc: TProc;
    function GetItemAppearance: string;
    procedure SetItemAppearance(const Value: string);
    procedure SetItemBuilderProc(Value: TProc);
  protected
    procedure RebuildItems; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function AddItem(const AText: string; const ADetailText: string = ''; const AImageIndex: Integer = -1; const AOnSelect: TProc = nil): TListViewItem;
    procedure ClearItems;

    property ItemAppearance: string read GetItemAppearance write SetItemAppearance;
    property ItemBuilderProc: TProc read FItemBuilderProc write SetItemBuilderProc;
  end;

implementation

{$R *.fmx}

uses
  FMXER.IconFontsData;

{ TListViewFrame }

function TListViewFrame.AddItem(const AText: string; const ADetailText: string = ''; const AImageIndex: Integer = -1; const AOnSelect: TProc = nil): TListViewItem;
begin
  Result := ListView.Items.Add;

  Result.Text := AText;
  Result.Detail := ADetailText;
  if AImageIndex <> -1 then
    Result.ImageIndex := AImageIndex;

  if Assigned(AOnSelect) then
    FOnSelectHandlers.Add(Result, AOnSelect);

end;

procedure TListViewFrame.AfterConstruction;
begin
  inherited;
  if not Assigned(ListView.Images) then
    ListView.Images := IconFonts.ImageList;
end;

procedure TListViewFrame.ClearItems;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
  finally
    ListView.Items.EndUpdate;
  end;
end;

constructor TListViewFrame.Create(AOwner: TComponent);
begin
  inherited;
  FOnSelectHandlers := TDictionary<TListViewItem, TProc>.Create();
end;

destructor TListViewFrame.Destroy;
begin
  FreeAndNil(FOnSelectHandlers);
  inherited;
end;

function TListViewFrame.GetItemAppearance: string;
begin
  Result := Listview.ItemAppearance.ItemAppearance;
end;

procedure TListViewFrame.ListViewItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  var LHandler: TProc := nil;
  if FOnSelectHandlers.TryGetValue(AItem, LHandler) and Assigned(LHandler) then
    LHandler();
end;

procedure TListViewFrame.ListViewPullRefresh(Sender: TObject);
begin
  RebuildItems;
end;

procedure TListViewFrame.RebuildItems;
begin
  if Assigned(FItemBuilderProc) then
    FItemBuilderProc()
  else
    ListView.Items.Clear;
end;

procedure TListViewFrame.SetItemAppearance(const Value: string);
begin
  Listview.ItemAppearance.ItemAppearance := Value;
end;

procedure TListViewFrame.SetItemBuilderProc(Value: TProc);
begin
  if TProc(FItemBuilderProc) <> TProc(Value) then
  begin
    FItemBuilderProc := Value;

    RebuildItems;
  end;
end;

end.
