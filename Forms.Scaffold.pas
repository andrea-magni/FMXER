unit Forms.Scaffold;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, SubjectStand, FrameStand,
  Generics.Collections, System.Actions, FMX.ActnList, FMX.Effects, FormStand,
  FMX.ImgList
// Frames
, Frames.ActionButton, Frames.Text, Frames.Glyph
;

type
  TScaffoldForm = class(TForm)
    TitleLayout: TLayout;
    TitleBackground: TRectangle;
    TitleLabel: TLabel;
    ContentLayout: TLayout;
    OverlayLayout: TLayout;
    ActionButtonsLayout: TLayout;
    FrameStand1: TFrameStand;
    ShadowEffect1: TShadowEffect;
    ShadowEffect2: TShadowEffect;
    FormStand1: TFormStand;
    Stands: TStyleBook;
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
  private
    FContent: TSubjectInfo;
    FContentStand: string;
    FActionButtonStand: string;
    FActionButtons: TList<TFrameInfo<TActionButtonFrame>>;
    FTitle: string;
    procedure SetTitle(const Value: string);
    function GetContent: TSubject;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //
    procedure SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil);
    procedure SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil);

    procedure AddActionButton(const ACaption: string; const AOnClickProc: TProc); overload;
    procedure AddActionButton(const AImageList: TCustomImageList;
      const AImageIndex: Integer; const AOnClickProc: TProc); overload;

    procedure AddActionButtonOverlayFrame<T: TFrame>(const AOverlayConfigProc: TProc<T>;
      const AOnClickProc: TProc);
//    procedure AddActionButtonOverlayForm<T: TForm>(const AOverlayConfigProc: TProc<T>;
//      const AOnClickProc: TProc);

    procedure ShowSnackBar(const AText: string; const ADuration_ms: Integer);
    //
    [Hide]
    procedure HideHandler;
    //
    property ActionButtonStand: string read FActionButtonStand write FActionButtonStand;
    property ContentStand: string read FContentStand write FContentStand;
    property Title: string read FTitle write SetTitle;
    property Content: TSubject read GetContent;
  end;

implementation

{$R *.fmx}

uses UI.Consts;


{ TScaffoldForm }

procedure TScaffoldForm.ActionList1Update(Action: TBasicAction;
  var Handled: Boolean);
begin
  Title := TimeToStr(Now);
end;

procedure TScaffoldForm.AddActionButton(const ACaption: string;
  const AOnClickProc: TProc);
begin
  AddActionButtonOverlayFrame<TTextFrame>(
    procedure (ATextFrame: TTextFrame)
    begin
      ATextFrame.Content := ACaption;
    end
  , AOnClickProc
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

procedure TScaffoldForm.AddActionButtonOverlayFrame<T>(
  const AOverlayConfigProc: TProc<T>; const AOnClickProc: TProc);
begin
  FrameStand1.NewAndShow<TActionButtonFrame>(ActionButtonsLayout, ActionButtonStand
  , nil
  , procedure (FI: TFrameInfo<TActionButtonFrame>)
    begin
      FI.Stand.Position.X := 100000;
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
  Result := FContent.Subject;
end;

procedure TScaffoldForm.HideHandler;
begin
  // destructor would be too late
  FrameStand1.CloseAll();
  FormStand1.CloseAll();

  SI.DefaultHide;
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

end.
