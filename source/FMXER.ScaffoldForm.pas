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
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    FContent: TSubjectInfo;
    FTitleDetailContent: TSubjectInfo;
    FContentStand: string;
    FActionButtonStand: string;
    FActionButtons: TList<TFrameInfo<TActionButtonFrame>>;
    FTitle: string;
    FTitleDetailStand: string;
    procedure SetTitle(const Value: string);
    function GetContent: TSubject;
    function GetTitleDetailContent: TSubject;
    function GetTitleDetailContentVisible: Boolean;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Content
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    // Title detail
    procedure SetTitleDetailContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetTitleDetailContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    // Action buttons
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc); overload;
    procedure AddActionButtonOverlayFrame<T: TFrame>(const AElementDef: TElementDef<T>); overload;
    procedure AddActionButtonOverlayForm<T: TForm>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc);

    // shortcuts
    procedure AddActionButton(const ACaption: string; const AParams: TParams); overload;
    procedure AddActionButton(const ACaption: string; const AOnClickProc: TProc); overload;
    procedure AddActionButton(const AImageList: TCustomImageList;
      const AImageIndex: Integer; const AOnClickProc: TProc); overload;

    procedure ShowSnackBar(const AText: string; const ADuration_ms: Integer);

    procedure ShowTitleDetailContent;
    procedure HideTitleDetailContent(const ADelay: Integer = 0; const AThen: TProc = nil);

    //
    [Hide]
    procedure HideHandler;
    //
    property ActionButtonStand: string read FActionButtonStand write FActionButtonStand;
    property ContentStand: string read FContentStand write FContentStand;
    property Title: string read FTitle write SetTitle;
    property TitleDetailStand: string read FTitleDetailStand write FTitleDetailStand;
    property Content: TSubject read GetContent;
    property TitleDetailContent: TSubject read GetTitleDetailContent;
    property TitleDetailContentVisible: Boolean read GetTitleDetailContentVisible;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;


{ TScaffoldForm }

procedure TScaffoldForm.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
begin
  Title := TimeToStr(Now);
end;

procedure TScaffoldForm.AddActionButton(const ACaption: string;
  const AParams: TParams);
begin
  AddActionButtonOverlayFrame<TTextFrame>(
    TElementDef<TTextFrame>.Create(
      procedure (ATextFrame: TTextFrame)
      begin
        ATextFrame.Content := ACaption;
      end
    , AParams
    )
  );
end;

procedure TScaffoldForm.AddActionButton(const AImageList: TCustomImageList;
  const AImageIndex: Integer; const AOnClickProc: TProc);
begin
  AddActionButtonOverlayFrame<TGlyphFrame>(
   procedure (AGlyph: TGlyphFrame)
   begin
     AGlyph.Images := AImageList;
     AGlyph.ImageIndex := AImageIndex;
   end
  , AOnClickProc
  );
end;

procedure TScaffoldForm.AddActionButton(const ACaption: string;
  const AOnClickProc: TProc);
begin
  AddActionButton(ACaption, [ OnClickProc(AOnClickProc) ]);
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

procedure TScaffoldForm.SetContentAsForm<T>(const AConfigProc: TProc<T> = nil);
begin
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TScaffoldForm.SetContentAsFrame<T>(const AConfigProc: TProc<T> = nil);
begin
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

procedure TScaffoldForm.SetTitle(const Value: string);
begin
  FTitle := Value;
  TitleLabel.Text := FTitle;
end;

procedure TScaffoldForm.SetTitleDetailContentAsForm<T>(
  const AConfigProc: TProc<T>);
begin
  FTitleDetailContent := FormStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

procedure TScaffoldForm.SetTitleDetailContentAsFrame<T>(
  const AConfigProc: TProc<T>);
begin
  FTitleDetailContent := FrameStand1.NewAndShow<T>(TitleDetailLayout, TitleDetailStand, AConfigProc);
end;

procedure TScaffoldForm.ShowSnackBar(const AText: string;
  const ADuration_ms: Integer);
var
  FSnackbar: TFrameInfo<TTextFrame>;
begin
  FSnackbar := FrameStand1.New<TTextFrame>(OverlayLayout, 'snackbar');

  FSnackbar.Frame.Content := AText;
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
