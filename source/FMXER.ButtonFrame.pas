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
  /// Right: the icon next to the text, the two centered in the button) or
  /// above / below it (Top, Bottom).</summary>
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
    FIconSize: Single;
    // the layout of the style of the button, before the icon changed it
    FStyleGlyph: TObject;
    FGlyphAlign: TAlignLayout;
    FGlyphSize: TSizeF;
    FGlyphStretch: Boolean;
    FTextAlign: TAlignLayout;
    FTextHeight: Single;
    FGlyphMargins: TRectF;
    FTextMargins: TRectF;
    FTextHorzAlign: TTextAlign;
    // what the icon was placed for: text, size of the button, position, size
    FLayoutKey: string;
    procedure ButtonApplyStyleLookup(Sender: TObject);
    procedure ButtonResized(Sender: TObject);
    procedure ApplyIconPosition;
    procedure UpdateIconLayout;
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
    /// <summary>The size of the icon (width and height); 0: the size of the
    /// style of the button (16). The icon always stays inside the button: a
    /// size larger than the room it has is reduced to it.</summary>
    function SetIconSize(const ASize: Single): TButtonFrame;

    property IconPosition: TButtonIconPosition read FIconPosition;
    property IconSize: Single read FIconSize;
    property BackgroundFill: TBrush read GetBackgroundFill;
    property BackgroundStroke: TStrokeBrush read GetBackgroundStroke;
    property IsDefault: Boolean read GetIsDefault write SetIsDefault;
    property OnClickHandler: TProc read FOnClickHandler write FOnClickHandler;
    property OnUpdateHandler: TProc<TAction> read FOnUpdateHandler write FOnUpdateHandler;
  end;

implementation

{$R *.fmx}

uses
  System.Math, FMX.TextLayout
, FMXER.UI.Consts, FMXER.IconFontsData;

const
  // between the icon and the text (Left, Right)
  ICON_TEXT_GAP = 6;

function TextWidth(const AText: TText): Single;
var
  LLayout: TTextLayout;
begin
  if AText.Text = '' then
    Exit(0);
  LLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    LLayout.BeginUpdate;
    try
      LLayout.Font.Assign(AText.TextSettings.Font);
      LLayout.WordWrap := False;
      LLayout.MaxSize := TPointF.Create(100000, 100000);
      LLayout.Text := AText.Text;
    finally
      LLayout.EndUpdate;
    end;
    Result := LLayout.TextWidth;
  finally
    LLayout.Free;
  end;
end;

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
  // the style, kept the first time, is restored before every change
  if LGlyph <> FStyleGlyph then
  begin
    FStyleGlyph := LGlyph;
    FGlyphAlign := LGlyph.Align;
    FGlyphSize := LGlyph.Size.Size;
    FGlyphStretch := LGlyph.Stretch;
    FTextAlign := LText.Align;
    FTextHeight := LText.Height;
    FGlyphMargins := LGlyph.Margins.Rect;
    FTextMargins := LText.Margins.Rect;
    if LText is TText then
      FTextHorzAlign := TText(LText).TextSettings.HorzAlign;
  end
  else
  begin
    LGlyph.Align := FGlyphAlign;
    LGlyph.Size.Size := FGlyphSize;
    LGlyph.Stretch := FGlyphStretch;
    LText.Align := FTextAlign;
    LText.Height := FTextHeight;
    LGlyph.Margins.Rect := FGlyphMargins;
    LText.Margins.Rect := FTextMargins;
    if LText is TText then
      TText(LText).TextSettings.HorzAlign := FTextHorzAlign;
  end;
  // no icon: the style as it is
  FLayoutKey := '';
  if (ButtonControl.Images = nil) or (ButtonAction.ImageIndex < 0) then
    Exit;

  // the glyph is placed by UpdateIconLayout (not aligned: the button would
  // give it back the size of the style at every resize, UpdateGlyphSize); the
  // text beside it, or on one line above / below it
  LGlyph.Align := TAlignLayout.None;
  LGlyph.Stretch := True; // the image list draws the icon at the size of the glyph
  LGlyph.Margins.Rect := TRectF.Empty;
  case FIconPosition of
    TButtonIconPosition.Top, TButtonIconPosition.Bottom:
    begin
      if FIconPosition = TButtonIconPosition.Top then
        LText.Align := TAlignLayout.Bottom
      else
        LText.Align := TAlignLayout.Top;
      if LText is TText then
        LText.Height := Round(TText(LText).TextSettings.Font.Size * 1.5);
    end;
  end;
  UpdateIconLayout;
end;

procedure TButtonFrame.UpdateIconLayout;
var
  LGlyph: TGlyph;
  LText: TControl;
  LKey: string;
  LWidth, LHeight, LSize, LTextWidth, LSide, LAreaTop, LAreaHeight: Single;
begin
  if not (ButtonControl.FindStyleResource<TGlyph>('glyphstyle', LGlyph)
    and ButtonControl.FindStyleResource<TControl>('text', LText)) or (LGlyph <> FStyleGlyph)
    or (LGlyph.Align <> TAlignLayout.None) then // no icon (the style), or not applied yet
    Exit;
  LWidth := ButtonControl.Width;
  LHeight := ButtonControl.Height;
  // only when something changed (also called when the action is updated, at
  // idle time)
  if LText is TText then
    LKey := TText(LText).Text
  else
    LKey := ButtonAction.Text;
  LKey := Format('%s|%.2f|%.2f|%d|%.2f', [LKey, LWidth, LHeight, Ord(FIconPosition), FIconSize]);
  if LKey = FLayoutKey then
    Exit;
  FLayoutKey := LKey;

  // the size: asked, or the one of the style; never larger than the button
  if FIconSize > 0 then
    LSize := FIconSize
  else
    LSize := FGlyphSize.Width;
  LSize := Min(LSize, LWidth - FGlyphMargins.Left - FGlyphMargins.Right);

  case FIconPosition of
    TButtonIconPosition.Left, TButtonIconPosition.Right:
    begin
      LSize := Max(0, Min(LSize, LHeight - FGlyphMargins.Top - FGlyphMargins.Bottom));
      // the icon next to the text, the two centered (no text: the icon in the
      // middle); a text too long for that: the icon at the side, the text
      // centered in the rest
      if LText is TText then
        LTextWidth := TextWidth(TText(LText))
      else
        LTextWidth := 0;
      LText.Margins.Rect := FTextMargins;
      if LTextWidth > 0 then
        LSide := (LWidth - (LSize + ICON_TEXT_GAP + LTextWidth)) / 2
      else
        LSide := (LWidth - LSize) / 2;
      if LText is TText then
      begin
        if LSide <= FGlyphMargins.Left then
          TText(LText).TextSettings.HorzAlign := TTextAlign.Center
        else if FIconPosition = TButtonIconPosition.Left then
          TText(LText).TextSettings.HorzAlign := TTextAlign.Leading
        else
          TText(LText).TextSettings.HorzAlign := TTextAlign.Trailing;
      end;
      LSide := Max(LSide, FGlyphMargins.Left);
      if FIconPosition = TButtonIconPosition.Left then
      begin
        LGlyph.SetBounds(LSide, (LHeight - LSize) / 2, LSize, LSize);
        LText.Margins.Left := LSide + LSize + ICON_TEXT_GAP;
      end
      else
      begin
        LGlyph.SetBounds(LWidth - LSide - LSize, (LHeight - LSize) / 2, LSize, LSize);
        LText.Margins.Right := LSide + LSize + ICON_TEXT_GAP;
      end;
    end;
    TButtonIconPosition.Top, TButtonIconPosition.Bottom:
    begin
      // the icon centered in the room the line of text leaves
      LAreaHeight := LHeight - (LText.Height + LText.Margins.Top + LText.Margins.Bottom)
        - FGlyphMargins.Top - FGlyphMargins.Bottom;
      if FIconPosition = TButtonIconPosition.Top then
        LAreaTop := FGlyphMargins.Top
      else
        LAreaTop := LText.Height + LText.Margins.Top + LText.Margins.Bottom + FGlyphMargins.Top;
      LSize := Max(0, Min(LSize, LAreaHeight));
      LGlyph.SetBounds((LWidth - LSize) / 2, LAreaTop + (LAreaHeight - LSize) / 2, LSize, LSize);
    end;
  end;
end;

procedure TButtonFrame.ButtonApplyStyleLookup(Sender: TObject);
begin
  ApplyIconPosition;
end;

procedure TButtonFrame.ButtonResized(Sender: TObject);
begin
  UpdateIconLayout;
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
  UpdateIconLayout; // the text may have changed
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
  UpdateIconLayout;
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
  ButtonControl.OnResized := ButtonResized;
  ApplyIconPosition;
end;

function TButtonFrame.ClearIcon: TButtonFrame;
begin
  Result := SetImage(nil, -1, TButtonIconPosition.Left);
end;

function TButtonFrame.SetIconSize(const ASize: Single): TButtonFrame;
begin
  Result := Self;
  FIconSize := Max(0, ASize);
  FLayoutKey := '';
  UpdateIconLayout;
end;

end.
