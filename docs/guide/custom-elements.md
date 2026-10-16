# Writing Your Own Elements

Any frame or form can be an FMXER element: `SetContentAsFrame<TMyFrame>` works with every `TFrame` descendant. A few conventions make your own elements feel like the built-in ones — and the README invites you to contribute them back.

## A simple element

A *badge*: a number in a colored circle.

1. **File > New > Multi-Device Frame**, save it as `Frames.Badge.pas`, name it `BadgeFrame`.
2. Set the frame's `Align` to `Client`, so it fills whatever slot it is put in.
3. Drop a `TCircle` (`Background`, `Align = Client`) and a `TSkLabel` inside it (`CountLabel`, `Align = Client`, centered text).
4. Write the public API as fluent setters:

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
  // pick the application colors at creation, like the built-in elements
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

Use it like any other element:

```pascal
Row.AddFrame<TBadgeFrame>(48
, procedure (Badge: TBadgeFrame)
  begin
    Badge.SetCount(3).SetOnClickProc(
      procedure
      begin
        Navigator.RouteTo('inbox');
      end
    );
  end
);
```


## Conventions

| Convention | Why |
|---|---|
| `Align = Client` on the frame, and a sensible design size | the slot decides the size; with `AUTO_HEIGHT`/`AUTO_WIDTH` the design size becomes the slot size |
| setters named `Set...`, returning the element | fluent configuration, like the built-in elements |
| events as `TProc` / `TProc<T>` (`OnClickProc`, `OnChangeProc`) | configured with closures in the configuration procedure |
| read `TAppColors` in the constructor | the element follows the application colors |
| keep the inner controls as published fields | users can reach them when a setter is missing |
| no global variable for the frame (delete the `var BadgeFrame: TBadgeFrame;` the IDE adds) | elements are created many times, by the stands |
| override `HitTestChanged` to forward `HitTest` to the inner control | so `SetHitTest(False)` makes the element click-through, as `TImageFrame` and `TBackgroundFrame` do |

## A container element

To make an element that hosts other elements, add a `TFrameStand` and a `TFormStand` to it, a layout for each slot, and a pair of generic methods per slot — the pattern of every FMXER container:

```pascal
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

`NewAndShow` creates the element in `ContentLayout`, inside the stand `ContentStand`, calls the configuration procedure and shows it. Keep the returned info if the container needs to hide or show the element later (`FContent.Hide`, `FContent.SubjectShow`), as `TScaffoldForm` does with its title detail area.

## Reacting to show and hide

Elements are shown and hidden by TFrameStand, so they can use its [injection attributes](https://andrea-magni.github.io/TFrameStand/features/injection): a field marked `[SubjectInfo]` receives the element's info, a method marked `[Show]`, `[Hide]`, `[BeforeShow]` or `[AfterShow]` is called at that moment. `TEditFrame` uses `[Show]` to focus its edit:

```pascal
type
  TEditFrame = class(TFrame)
    EditControl: TEdit;
  private
    FFocusOnShow: Boolean;
  protected
    [SubjectInfo] SI: TSubjectInfo;
  public
    [Show]
    procedure ShowHandler;
  end;

procedure TEditFrame.ShowHandler;
begin
  SI.DefaultShow;   // run the stand's show animations
  if FFocusOnShow and EditControl.CanFocus then
    TDelayedAction.Execute(10
    , procedure
      begin
        EditControl.SetFocus;
      end
    );
end;
```

A `[Show]` or `[Hide]` method **replaces** the default behaviour: call `SI.DefaultShow` / `SI.DefaultHide` in it. The attributes are declared in the `SubjectStand` unit.

## Contributing

Elements live in `source\` with the `FMXER.` prefix (`FMXER.BadgeFrame.pas`), and are listed in `List.md`. Pull requests are welcome on [GitHub](https://github.com/andrea-magni/FMXER).
