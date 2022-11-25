unit FMXER.ScaffoldForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ImgList, System.Rtti,
  Generics.Collections, System.Actions, FMX.ActnList, FMX.Effects
, Skia, Skia.FMX
, SubjectStand, FrameStand, FormStand
, FMXER.UI.Misc, FMXER.ActionButtonFrame, FMXER.TextFrame, FMXER.GlyphFrame
, FMXER.IconFontsData, Icons.Utils
;

type
  TScaffoldForm = class(TForm)
    TitleLayout: TLayout;
    TitleBackground: TRectangle;
    ContentLayout: TLayout;
    OverlayLayout: TLayout;
    ActionButtonsLayout: TLayout;
    FrameStand1: TFrameStand;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    FormStand1: TFormStand;
    Stands: TStyleBook;
    TitleDetailLayout: TLayout;
    TitleLabel: TSkLabel;
  private
    FContent: TSubjectInfo;
    FTitleDetailContent: TSubjectInfo;
    FContentStand: string;
    FActionButtonStand: string;
    FActionButtons: TList<TFrameInfo<TActionButtonFrame>>;
    FTitle: string;
    FTitleDetailStand: string;
    function GetContent: TSubject;
    function GetTitleDetailContent: TSubject;
    function GetTitleDetailContentVisible: Boolean;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Content
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;

    // Title detail
    function SetTitleDetailContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
    function SetTitleDetailContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TScaffoldForm;

    // Action buttons
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc); overload;
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AElementDef: TElementDef<T>); overload;
    procedure AddActionButtonOverlayForm<T: TForm>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc);

    // shortcuts
    function AddActionButton(const ACaption: string; const AParams: TParams): TScaffoldForm; overload;
    function AddActionButton(const ACaption: string; const AOnClickProc: TProc): TScaffoldForm; overload;
    function AddActionButton(const AImageList: TCustomImageList;
      const AImageIndex: Integer; const AOnClickProc: TProc): TScaffoldForm; overload;
    function AddActionButton(const AIcon: TIconEntry; const AColor: TAlphaColor;
      const AOnClickProc: TProc): TScaffoldForm; overload;

    function ShowSnackBar(const AText: string; const ADuration_ms: Integer): TScaffoldForm;

    procedure ShowTitleDetailContent;
    procedure HideTitleDetailContent(const ADelay: Integer = 0; const AThen: TProc = nil);

    function SetTitle(const ATitle: string): TScaffoldForm;

    //
    [Hide]
    procedure HideHandler;
    //
    property ActionButtonStand: string read FActionButtonStand write FActionButtonStand;
    property ContentStand: string read FContentStand write FContentStand;
    property TitleDetailStand: string read FTitleDetailStand write FTitleDetailStand;
    property Content: TSubject read GetContent;
    property TitleDetailContent: TSubject read GetTitleDetailContent;
    property TitleDetailContentVisible: Boolean read GetTitleDetailContentVisible;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;


{ TScaffoldForm }

function TScaffoldForm.AddActionButton(const ACaption: string;
  const AParams: TParams): TScaffoldForm;
begin
  Result := Self;
  AddActionButtonOverlayFrame<TTextFrame>(
    TElementDef<TTextFrame>.Create(
      procedure (ATextFrame: TTextFrame)
      begin
        ATextFrame.SetContent(ACaption);
      end
    , AParams
    )
  );
end;

function TScaffoldForm.AddActionButton(const AImageList: TCustomImageList;
  const AImageIndex: Integer; const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := Self;

  AddActionButtonOverlayFrame<TGlyphFrame>(
   procedure (AGlyph: TGlyphFrame)
   begin
     AGlyph
     .SetImages(AImageList)
     .SetImageIndex(AImageIndex);
   end
  , AOnClickProc
  );
end;

function TScaffoldForm.AddActionButton(const ACaption: string;
  const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := AddActionButton(ACaption, [ OnClickProc(AOnClickProc) ]);
end;

function TScaffoldForm.AddActionButton(const AIcon: TIconEntry;
  const AColor: TAlphaColor; const AOnClickProc: TProc): TScaffoldForm;
begin
  Result := AddActionButton(
      IconFonts.ImageList
    , IconFonts.AddIcon(AIcon, AColor)
    , AOnClickProc);
end;

procedure TScaffoldForm.AddActionButtonOverlayForm<T>(
  const AOverlayConfigProc: TProc<T>; const AOnClickProc: TProc);
begin
  FrameStand1.NewAndShow<TActionButtonFrame>(ActionButtonsLayout, ActionButtonStand
  , nil
  , procedure (FI: TFrameInfo<TActionButtonFrame>)
    begin
      FI.Stand.Position.X := MaxInt;
      FI.Stand.Align := TAlignLayout.Right;
      FI.Stand.Margins.Right := 10;

      FI.Frame.OnClickProc := AOnClickProc;
      FI.Frame.SetOverlayAsForm<T>(AOverlayConfigProc);

      FActionButtons.Add(FI);
    end
  );
end;

procedure TScaffoldForm.AddActionButtonOverlayFrame<T>(
  const AElementDef: TElementDef<T>);
var
  LProc: TProc;
begin
  LProc := TProc(AElementDef.ParamByName('OnClickProc', nil).GetReferenceToRawData^);
  AddActionButtonOverlayFrame<T>(AElementDef.ConfigProc, LProc);
end;

procedure TScaffoldForm.AddActionButtonOverlayFrame<T>(
  const AOverlayConfigProc: TProc<T>; const AOnClickProc: TProc);
begin
  FrameStand1.NewAndShow<TActionButtonFrame>(ActionButtonsLayout, ActionButtonStand
  , nil
  , procedure (FI: TFrameInfo<TActionButtonFrame>)
    begin
      FI.Stand.Position.X := MaxInt;
      FI.Stand.Align := TAlignLayout.Right;
      FI.Stand.Margins.Right := 10;

      FI.Frame.OnClickProc := AOnClickProc;
      FI.Frame.SetOverlayAsFrame<T>(AOverlayConfigProc);

      FActionButtons.Add(FI);
    end
  );
end;

constructor TScaffoldForm.Create(AOwner: TComponent);
begin
  inherited;
  FActionButtons := TList<TFrameInfo<TActionButtonFrame>>.Create;

  TitleBackground.Fill.Color := TAppColors.PrimaryColor;
  TitleLabel.TextSettings.FontColor := TAppColors.PrimaryTextColor;
end;

destructor TScaffoldForm.Destroy;
begin
  FreeAndNil(FActionButtons);
  inherited;
end;

function TScaffoldForm.GetContent: TSubject;
begin
  Result := nil;
  if Assigned(FContent) then
    Result := FContent.Subject;
end;

function TScaffoldForm.GetTitleDetailContent: TSubject;
begin
  Result := nil;
  if Assigned(FTitleDetailContent) then
    Result := FTitleDetailContent.Subject;
end;

function TScaffoldForm.GetTitleDetailContentVisible: Boolean;
begin
  Result := Assigned(FTitleDetailContent) and FTitleDetailContent.IsVisible;
end;

procedure TScaffoldForm.HideHandler;
begin
  // destructor would be too late
//  FrameStand1.HideAndCloseAll();
//  FormStand1.HideAndCloseAll();

{ TODO : Find a way to hide/close everything it the correct order }
  SI.DefaultHide;
end;

procedure TScaffoldForm.HideTitleDetailContent(const ADelay: Integer = 0; const AThen: TProc = nil);
begin
  if Assigned(FTitleDetailContent) then
    FTitleDetailContent.Hide(ADelay, AThen);
end;

function TScaffoldForm.SetContentAsForm<T>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TScaffoldForm.SetContentAsFrame<T>(const AConfigProc: TProc<T> = nil): TScaffoldForm;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TScaffoldForm.SetTitle(const ATitle: string): TScaffoldForm;
begin
  Result := Self;
  FTitle := ATitle;
  TitleLabel.Text := FTitle;
end;

function TScaffoldForm.SetTitleDetailContentAsForm<T>(
  const AConfigProc: TProc<T>): TScaffoldForm;
begin
  Result := Self;
  FTitleDetailContent := FormStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

function TScaffoldForm.SetTitleDetailContentAsFrame<T>(
  const AConfigProc: TProc<T>): TScaffoldForm;
begin
  Result := Self;
  FTitleDetailContent := FrameStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

function TScaffoldForm.ShowSnackBar(const AText: string;
  const ADuration_ms: Integer): TScaffoldForm;
var
  FSnackbar: TFrameInfo<TTextFrame>;
begin
  Result := Self;

  FSnackbar := FrameStand1.New<TTextFrame>(OverlayLayout, 'snackbar');

  FSnackbar.Frame.SetContent(AText);
  FSnackbar.Show();

  TDelayedAction.Execute(ADuration_ms
    , procedure
      begin
        FSnackBar.Hide();
      end
  );
end;

procedure TScaffoldForm.ShowTitleDetailContent;
begin
  if Assigned(FTitleDetailContent) then
    FTitleDetailContent.SubjectShow;
end;

end.
