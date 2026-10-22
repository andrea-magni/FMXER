unit FMXER.ButtonFrame;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.Actions, FMX.ActnList, System.Skia,
  FMX.Skia, FMX.Objects, FMX.ImgList
, FMXER.Observable, Icons.Utils;

type
  {$SCOPEDENUMS ON}
  /// <summary>Where the icon of a TButtonFrame is: beside the text (Left,
  /// Right) or above / below it (Top, Bottom).</summary>
  TButtonIconPosition = (Left, Right, Top, Bottom);
  {$SCOPEDENUMS OFF}

  TButtonFrame = class(TFrame)
    ButtonControl: TButton;
    ActionList1: TActionList;
    ButtonAction: TAction;
    CaptionLabel: TSkLabel;
    ExtraLabel: TSkLabel;
    BackgroundRectangle: TRectangle;
    procedure ButtonActionExecute(Sender: TObject);
    procedure ButtonActionUpdate(Sender: TObject);
  private
    FEnabledLink: TObservableLink<Boolean>;
    FOnClickHandler: TProc;
    FOnUpdateHandler: TProc<TAction>;
    FIconPosition: TButtonIconPosition;
    // the layout of the style of the button, before a position changed it
    FStyleGlyph: TObject;
    FGlyphAlign: TAlignLayout;
    FGlyphSize: TSizeF;
    FGlyphStretch: Boolean;
    FTextAlign: TAlignLayout;
    FTextHeight: Single;
    procedure ButtonApplyStyleLookup(Sender: TObject);
    procedure ApplyIconPosition;
    function GetIsDefault: Boolean;
    procedure SetIsDefault(const Value: Boolean);
    function GetBackgroundFill: TBrush;
    function GetBackgroundStroke: TStrokeBrush;
  public
    /// <summary>One-way binding: the button is enabled when AObservable is
    /// True (the Enabled of its action). Removed with the element.</summary>
    function BindEnabled(const AObservable: TObservable<Boolean>): TButtonFrame;
    function SetCaption(const ACaption: string): TButtonFrame;
    function SetExtraText(const AExtraText: string): TButtonFrame;
    function SetText(const AText: string): TButtonFrame;
    function SetBackgroundFillColor(const AColor: TAlphaColor): TButtonFrame;
    function SetBackgroundStrokeColor(const AColor: TAlphaColor): TButtonFrame;
    function SetBackgroundStrokeThickness(const AThickness: Single): TButtonFrame;
    function SetBackgroundVisible(const AVisible: Boolean): TButtonFrame;
    function SetBackgroundOpacity(const AOpacity: Single): TButtonFrame;
    function SetOnClickHandler(const AOnClickHandler: TProc): TButtonFrame;
    function SetOnClickProc(const AOnClickProc: TProc): TButtonFrame;
    /// <summary>An icon of the icon font (IconFonts.MD...) beside, above or
    /// below the text, in AColor (default TAppColors.PrimaryColor). Without the
    /// icon font the button shows only its text.</summary>
    function SetIcon(const AIcon: TIconEntry;
      const AIconPosition: TButtonIconPosition = TButtonIconPosition.Left): TButtonFrame; overload;
    function SetIcon(const AIcon: TIconEntry; const AColor: TAlphaColor;
      const AIconPosition: TButtonIconPosition = TButtonIconPosition.Left): TButtonFrame; overload;
    /// <summary>An image of any image list (AImageIndex -1: none) beside, above
    /// or below the text.</summary>
    function SetImage(const AImages: TCustomImageList; const AImageIndex: Integer;
      const AIconPosition: TButtonIconPosition = TButtonIconPosition.Left): TButtonFrame;
    /// <summary>No icon: only the text.</summary>
    function ClearIcon: TButtonFrame;

    property IconPosition: TButtonIconPosition read FIconPosition;
    property BackgroundFill: TBrush read GetBackgroundFill;
    property BackgroundStroke: TStrokeBrush read GetBackgroundStroke;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property OnClickHandler: TProc read FOnClickHandler write FOnClickHandler;
    property OnUpdateHandler: TProc<TAction> read FOnUpdateHandler write FOnUpdateHandler;
  end;

implementation

{$R *.fmx}

uses
  FMXER.UI.Consts, FMXER.IconFontsData;

{ TEditFrame }

function TButtonFrame.BindEnabled(const AObservable: TObservable<Boolean>): TButtonFrame;
begin
  Result := Self;
  if not Assigned(FEnabledLink) then
    FEnabledLink := TObservableLink<Boolean>.Create(Self);
  FEnabledLink.Bind(AObservable,
    procedure (AValue: Boolean)
    begin
      ButtonAction.Enabled := AValue;
    end);
end;

procedure TButtonFrame.ApplyIconPosition;
var
  LGlyph: TGlyph;
  LText: TControl;
begin
  // the style of the button: a glyph ('glyphstyle', 16 wide, on the left) and
  // the text ('text', the rest); not styled yet: applied with the style
  if not (ButtonControl.FindStyleResource<TGlyph>('glyphstyle', LGlyph)
    and ButtonControl.FindStyleResource<TControl>('text', LText)) then
    Exit;
  // the style objects stay when the style is looked up again: the layout of
  // the style, kept the first time, is restored before every position
  if LGlyph <> FStyleGlyph then
  begin
    FStyleGlyph := LGlyph;
    FGlyphAlign := LGlyph.Align;
    FGlyphSize := LGlyph.Size.Size;
    FGlyphStretch := LGlyph.Stretch;
    FTextAlign := LText.Align;
    FTextHeight := LText.Height;
  end
  else
  begin
    LGlyph.Align := FGlyphAlign;
    LGlyph.Size.Size := FGlyphSize;
    LGlyph.Stretch := FGlyphStretch;
    LText.Align := FTextAlign;
    LText.Height := FTextHeight;
  end;
  case FIconPosition of
    TButtonIconPosition.Right:
      LGlyph.Align := TAlignLayout.Right;
    TButtonIconPosition.Top, TButtonIconPosition.Bottom:
    begin
      // the text on one line at the other side, the icon centered in the rest
      // at its own size (not stretched to the area)
      if FIconPosition = TButtonIconPosition.Top then
        LText.Align := TAlignLayout.Bottom
      else
        LText.Align := TAlignLayout.Top;
      if LText is TText then
        LText.Height := Round(TText(LText).TextSettings.Font.Size * 1.5);
      LGlyph.Align := TAlignLayout.Client;
      LGlyph.Stretch := False;
    end;
  end;
end;

procedure TButtonFrame.ButtonApplyStyleLookup(Sender: TObject);
begin
  ApplyIconPosition;
end;

procedure TButtonFrame.ButtonActionExecute(Sender: TObject);
begin
  if Assigned(FOnClickHandler) then
    FOnClickHandler();
end;

procedure TButtonFrame.ButtonActionUpdate(Sender: TObject);
begin
  if Assigned(FOnUpdateHandler) then
    FOnUpdateHandler(ButtonAction);
end;

function TButtonFrame.SetExtraText(const AExtraText: string): TButtonFrame;
begin
  Result := Self;
  ExtraLabel.Text := AExtraText;
end;

function TButtonFrame.GetBackgroundFill: TBrush;
begin
  Result := BackgroundRectangle.Fill;
end;

function TButtonFrame.GetBackgroundStroke: TStrokeBrush;
begin
  Result := BackgroundRectangle.Stroke;
end;

function TButtonFrame.GetIsDefault: Boolean;
begin
  Result := ButtonControl.Default;
end;

function TButtonFrame.SetBackgroundFillColor(
  const AColor: TAlphaColor): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Fill.Color := AColor;
end;

function TButtonFrame.SetBackgroundOpacity(
  const AOpacity: Single): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Opacity := AOpacity;
end;

function TButtonFrame.SetBackgroundStrokeColor(
  const AColor: TAlphaColor): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Stroke.Color := AColor;
end;

function TButtonFrame.SetBackgroundStrokeThickness(
  const AThickness: Single): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Stroke.Thickness := AThickness;
end;

function TButtonFrame.SetBackgroundVisible(
  const AVisible: Boolean): TButtonFrame;
begin
  Result := Self;
  BackgroundRectangle.Visible := AVisible;
end;

function TButtonFrame.SetCaption(const ACaption: string): TButtonFrame;
begin
  Result := Self;
  CaptionLabel.Text := ACaption;
end;

procedure TButtonFrame.SetIsDefault(const Value: Boolean);
begin
  ButtonControl.Default := Value;
end;

function TButtonFrame.SetOnClickHandler(
  const AOnClickHandler: TProc): TButtonFrame;
begin
  Result := Self;
  OnClickHandler := AOnClickHandler;
end;

function TButtonFrame.SetText(const AText: string): TButtonFrame;
begin
  Result := Self;
  ButtonAction.Caption := AText;
end;

function TButtonFrame.SetOnClickProc(const AOnClickProc: TProc): TButtonFrame;
begin
  Result := SetOnClickHandler(AOnClickProc);
end;

function TButtonFrame.SetIcon(const AIcon: TIconEntry;
  const AIconPosition: TButtonIconPosition): TButtonFrame;
begin
  Result := SetIcon(AIcon, TAppColors.PrimaryColor, AIconPosition);
end;

function TButtonFrame.SetIcon(const AIcon: TIconEntry; const AColor: TAlphaColor;
  const AIconPosition: TButtonIconPosition): TButtonFrame;
begin
  // AddIcon: -1 without the icon font (only the text), the same index for the
  // same icon and color
  Result := SetImage(IconFonts.ImageList, IconFonts.AddIcon(AIcon, AColor), AIconPosition);
end;

function TButtonFrame.SetImage(const AImages: TCustomImageList; const AImageIndex: Integer;
  const AIconPosition: TButtonIconPosition): TButtonFrame;
begin
  Result := Self;
  FIconPosition := AIconPosition;
  ButtonControl.Images := AImages;
  // on the action: the button takes its image (as its text) from the action
  ButtonAction.ImageIndex := AImageIndex;
  // the position is applied to the style of the button: now, if it is styled,
  // and whenever the style is applied
  ButtonControl.OnApplyStyleLookup := ButtonApplyStyleLookup;
  ApplyIconPosition;
end;

function TButtonFrame.ClearIcon: TButtonFrame;
begin
  Result := SetImage(nil, -1, TButtonIconPosition.Left);
end;

end.
