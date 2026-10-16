# Writing elements, project setup

Docs: https://andrea-magni.github.io/FMXER/guide/custom-elements, /guide/installation

## A simple element

Any `TFrame` works in a slot. To feel like the built-in ones:

| Convention | Why |
|---|---|
| `Align = Client` on the frame | the slot decides the size |
| `Set...` methods returning the element (`Result := Self;`) | fluent configuration |
| events as `TProc` / `TProc<T>` (`OnClickProc`, `OnChangeProc`) + a setter | configured with closures |
| read `TAppColors` in the constructor | follows the application colors |
| inner controls as published fields | reachable when a setter is missing |
| delete the global `var BadgeFrame: TBadgeFrame;` the IDE adds | elements are created many times, by the stands |
| override `HitTestChanged` to forward `HitTest` to the inner control | `SetHitTest(False)` makes it click-through |
| no `Name`-dependent code | several instances live together |

```pascal
unit Frames.Badge;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Objects, FMX.Skia;

type
  TBadgeFrame = class(TFrame)
    Background: TCircle;
    CountLabel: TSkLabel;
    procedure BackgroundClick(Sender: TObject);
  private
    FOnClickProc: TProc;
  public
    constructor Create(AOwner: TComponent); override;
    function SetCount(const ACount: Integer): TBadgeFrame;
    function SetColor(const AColor: TAlphaColor): TBadgeFrame;
    function SetOnClickProc(const AProc: TProc): TBadgeFrame;
  end;

implementation

{$R *.fmx}

uses FMXER.UI.Consts;

constructor TBadgeFrame.Create(AOwner: TComponent);
begin
  inherited;
  Background.Fill.Color := TAppColors.PrimaryColor;
  CountLabel.TextSettings.FontColor := TAppColors.PrimaryTextColor;
end;

procedure TBadgeFrame.BackgroundClick(Sender: TObject);
begin
  if Assigned(FOnClickProc) then
    FOnClickProc();
end;

function TBadgeFrame.SetColor(const AColor: TAlphaColor): TBadgeFrame;
begin
  Result := Self;
  Background.Fill.Color := AColor;
end;

function TBadgeFrame.SetCount(const ACount: Integer): TBadgeFrame;
begin
  Result := Self;
  CountLabel.Text := ACount.ToString;
end;

function TBadgeFrame.SetOnClickProc(const AProc: TProc): TBadgeFrame;
begin
  Result := Self;
  FOnClickProc := AProc;
end;

end.
```

## A container element

Add a `TFrameStand` and a `TFormStand`, a layout per slot, and a generic pair per slot:

```pascal
uses SubjectStand, FrameStand, FormStand;

type
  TPanelFrame = class(TFrame)
    ContentLayout: TLayout;
    FrameStand1: TFrameStand;
    FormStand1: TFormStand;
  private
    FContent: TSubjectInfo;
    FContentStand: string;
  public
    function SetContentAsFrame<T: TFrame>(const AConfigProc: TProc<T> = nil): TPanelFrame;
    function SetContentAsForm<T: TForm>(const AConfigProc: TProc<T> = nil): TPanelFrame;
    property ContentStand: string read FContentStand write FContentStand;
  end;

function TPanelFrame.SetContentAsFrame<T>(const AConfigProc: TProc<T>): TPanelFrame;
begin
  Result := Self;
  FContent := FrameStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;

function TPanelFrame.SetContentAsForm<T>(const AConfigProc: TProc<T>): TPanelFrame;
begin
  Result := Self;
  FContent := FormStand1.NewAndShow<T>(ContentLayout, ContentStand, AConfigProc);
end;
```

Keep the returned info to hide/show the child later (`FContent.Hide`, `FContent.SubjectShow`). Generic methods must be implemented in the same unit (Delphi generics), and the frame's `.fmx` needs the two stand components (or create them in the constructor).

## Show/hide hooks: TFrameStand injection

Elements are shown by TFrameStand, so its attributes (unit `SubjectStand`) work: a field `[SubjectInfo] SI: TSubjectInfo;` receives the element's info; methods marked `[Show]`, `[Hide]`, `[BeforeShow]`, `[AfterShow]` are called at that moment. `[Show]`/`[Hide]` **replace** the default: call `SI.DefaultShow` / `SI.DefaultHide`.

```pascal
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [Show]
    procedure ShowHandler;

procedure TEditFrame.ShowHandler;
begin
  SI.DefaultShow;
  if FFocusOnShow and EditControl.CanFocus then
    TDelayedAction.Execute(10, procedure begin EditControl.SetFocus; end);
end;
```

## Mixing with classic code

- Any form can be a route (`DefineRoute<TMyForm>`), any frame can go in a slot (`SetContentAsFrame<TMyFrame>`).
- FMXER inside a classic form: drop a `TFormStand` and call `FormStand1.NewAndShow<TColumnForm>(Layout1, '', procedure (Col: TColumnForm) ...)`.
- FMXER screens are built in code: no design-time preview of a whole screen (each element can be opened in the designer).

## Project setup

- Delphi 12 Athens or 13 Florence (v.1.2+); Delphi 11 only with FMXER v.1.1 (Skia4Delphi unit names).
- Search path (no packages): `<FMXER>\source`, `<FMXER>\lib\TFrameStand\source`, `<FMXER>\lib\IconFontsImageList\Source`, `<FMXER>\lib\DelphiZXingQRCode\Source` (skip libraries installed otherwise; `git clone --recursive` or `git submodule update --init`). Missing ones give `F2613 Unit 'SubjectStand'` / `'FMX.IconFontsImageList'` / `'DelphiZXIngQRCode' not found`.
- Project source: `uses FMX.Skia;` and `GlobalUseSkia := True;` before `Application.Initialize`.
- Main form: one `TFormStand` (`FormStand1`) at design time; `OnCreate` initializes the navigator, defines routes, sets `OnCloseRoute`, routes to home; `OnKeyUp` handles Back; `OnClose` closes routes first.
- Migrating v.1.1 code to Delphi 12+: `Skia` → `System.Skia`, `Skia.FMX` → `FMX.Skia`, `Skia.FMX.Graphics` → `FMX.Skia.Canvas` (`.fmx` files load unchanged). FMXER 1.0 code (MyTicketing, EKON25 demos) uses old properties (`Title`, `Text`, `OnClickProc`) that became setters (`SetTitle`, `SetText`, `SetOnClickHandler`).
- Icon font *Material Design Icons Desktop* (`media\Material Design Icons Desktop.ttf`): install on Windows; macOS: deploy to `Contents\Resources\Fonts` + `ATSApplicationFontsPath=Fonts` in the version info keys; iOS: deploy to the bundle (`.\`); Android: deploy to `.\assets\internal` (registered with Skia by `FMXER.IconFontsData`). The NewProjectTemplate demo has all the deployment entries.
- `LocalFile(AFileName)` points by default to the repository `media\` folder on Windows (the demos): set `LocalFilesPath` to your own folder, and ship your assets with the deployment manager.
- New elements contributed to FMXER go in `source\FMXER.<Name>.pas` and `List.md`.
