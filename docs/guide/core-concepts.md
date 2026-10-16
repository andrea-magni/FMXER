# Core Concepts

An FMXER screen is a **tree of elements**. This page explains what an element is, how a container creates its children, and who owns what.

## Elements

An **element** is a `TFrame` or a `TForm` descendant that does one thing: show a text (`TTextFrame`), a button (`TButtonFrame`), a list (`TListViewFrame`), or arrange other elements (`TColumnForm`, `TStackFrame`, `TScaffoldForm`...). Elements are designed in the IDE like any frame or form — the `.fmx` holds controls, styles and animations — and expose a small public API to configure them from code.

| Kind | Base class | Shown through | Examples |
|---|---|---|---|
| frame element | `TFrame` | the container's `TFrameStand` | `TTextFrame`, `TButtonFrame`, `TStackFrame`, `TVertScrollFrame` |
| form element | `TForm` | the container's `TFormStand` (the form's controls are moved into the container) | `TScaffoldForm`, `TColumnForm`, `TRowForm`, `TBackgroundForm` |

Form elements are useful when an element is a whole screen or a large arrangement: the form designer has style previews and Fire UI views. At runtime there is no visible difference: [TFormStand](https://andrea-magni.github.io/TFrameStand/features/formstand) moves the form's content into the target control.

## Containers and slots

A **container** is an element with one or more **slots** where other elements go. For each slot it has a pair of generic methods, one for frames and one for forms:

| Container | Slot methods |
|---|---|
| `TScaffoldForm` | `SetContentAsFrame<T>`, `SetContentAsForm<T>`, `SetTitleDetailContentAsFrame<T>`/`...AsForm<T>`, `AddActionButton...` |
| `TColumnForm` / `TRowForm` | `AddFrame<T>(Height or Width, ...)`, `AddForm<T>(...)` |
| `TStackFrame` | `AddFrame<T>` (layers, one on top of the other) |
| `TAccessoryFrame` | `SetLeftAsFrame<T>`, `SetContentAsFrame<T>`, `SetRightAsFrame<T>` (and `...AsForm<T>`) |
| `THorzPairFrame` | `SetLeftContentAsFrame<T>`, `SetRightContentAsFrame<T>`, `SetContentAsFrame<T1, T2>` |
| `TContainerFrame`, `TBackgroundFrame`, `TVertScrollFrame`, `TCardFrame`, ... | `SetContentAsFrame<T>`, `SetContentAsForm<T>` |

Every slot method does the same four things:

1. asks the container's `TFrameStand` (or `TFormStand`) to **create** a `T`, placed in the slot's layout, inside the slot's stand;
2. calls your **configuration procedure** with the new instance;
3. **shows** it (running the stand's `OnShow*` animations);
4. keeps the returned `TSubjectInfo` (the element's handle in TFrameStand), when the container needs it later.

```pascal
Card.SetContentAsFrame<TTextFrame>(
  procedure (Text: TTextFrame)   // 2. called with the new TTextFrame
  begin
    Text.SetContent('Inside a card');
  end
);
```

The configuration procedure is optional: `Scaffold.SetContentAsFrame<TLogoFrame>;` shows a logo with its design-time settings.

## Configuration procedures are closures

Configuration procedures are anonymous methods, so they **capture** the variables around them. This is how elements talk to each other without fields or events wired at design time:

```pascal
Home
.SetTitle('Hello')
.AddActionButton('A'
, procedure
  begin
    Home.ShowSnackBar('Button A pressed', 2000);  // Home is captured
  end
);
```

Two rules keep this safe:

- a closure keeps the **variable**, not the object alive: if it can run after its element was freed (a timer, a message subscription), stop it first — see [State & Events](./state#subscriptions-and-the-lifetime-of-elements);
- the configuration procedure runs **once**, when the element is created. To change an element later, keep a reference (a captured variable) or rebuild it.

## Fluent setters

Elements expose `Set*` methods that return the element itself, so a configuration reads as a sentence. Since v.1.3 the API follows three rules:

- every slot method (`SetContentAsFrame<T>`, `AddFrame<T>`, `SetGlyphAsFrame<T>`, `SetOverlayAsText`...) returns its container;
- every clickable element has `SetOnClickProc(TProc)`, and the image elements `SetOnTapHandler`;
- the properties you set when building a screen have a setter: `SetTitle`, `SetText`, `SetURL`, `SetContentStand`, `SetElementStand`, `SetTouchWidth`...


```pascal
Text
.SetContent('Total')
.SetFontSize(18)
.SetFontColor(TAppColors.PrimaryColor)
.SetHorzAlign(TSkTextHorzAlign.Trailing);
```

On top of the elements' own setters, `FMXER.UI.Misc` adds helpers to every `TControl`: `SetMargin`, `SetPadding`, `SetAlignClient`/`Top`/`Bottom`/`Left`/`Right`/`Contents`, `SetHitTest`, `SetWidth`, `SetHeight` (see the [reference](/reference/ui-misc#control-helpers)).

::: warning Keep the type when chaining helpers
The helpers return `TControl`, so after `.SetMargin(5)` the element's own setters are not visible any more. Use the generic overload to keep the type, or call the helpers last:

```pascal
Button
.SetMargin<TButtonFrame>(5)    // returns TButtonFrame
.SetText('OK')
.SetBackgroundVisible(False);

Chip
.SetText('Login')
.SetMargin(0, 5, 0, 0);        // fine: nothing after it
```
:::

## Stands

Every slot has a **stand name**: the name of the stand, in the container's style book, that wraps the child. Stands are how FMXER animates elements without code — a stand can fade the element in, slide it, add a background or a shadow. A stand is a style item with a `container` inside; animations named `OnShow*`/`OnHide*` run on show and hide. See [Designing Stands](https://andrea-magni.github.io/TFrameStand/guide/stands) in the TFrameStand documentation.

| Container | Stand property | Stands in its style book |
|---|---|---|
| `TColumnForm` | `ElementStand` | `fadeIn`, also the default: every element of a column fades in |
| `TRowForm` | `ElementStand` | `fadeIn`, not the default: call `SetElementStand('fadeIn')` to use it |
| `TScaffoldForm` | `ContentStand`, `TitleDetailStand`, `ActionButtonStand` | `snackbar` (used by `ShowSnackBar`) |
| other containers | `ContentStand` (and `LeftStand`, `RightStand`, `GlyphStand`...) | none |

An empty stand name means the `DefaultStandName` of the container's `TFrameStand`/`TFormStand` (`fadeIn` in `TColumnForm`, `framestand`/`formstand` elsewhere). When the name is not found in the style book, the element goes into a plain `TLayout`: no visual effect, everything else works. Set a stand property **before** the slot method that uses it:

```pascal
Row.SetElementStand('fadeIn').AddFrame<TTextFrame>(120);
```

## Ownership and lifetime

| Object | Created by | Freed when |
|---|---|---|
| a route's screen (e.g. a `TScaffoldForm`) | the navigator, through its `TFormStand`, at the first `RouteTo` | the route is closed (`CloseRoute`, `StackPop`, `CloseAllRoutes`) |
| an element in a slot | the container's `TFrameStand`/`TFormStand` | its container is freed (or its `TSubjectInfo` is closed) |
| `TIconFonts`, `TNavigator` | lazily, on first use | at application shutdown |

So closing a route frees the whole tree of elements built for it, and the next `RouteTo` builds a new one from the route definition. Nothing in the tree should be freed by hand.

## Where the work is done

```text
TMainForm
└─ FormStand1 (TFormStand)                     ← Navigator(FormStand1)
   └─ route 'home': TScaffoldForm              ← DefineRoute<TScaffoldForm>
      ├─ TitleLabel
      ├─ ContentLayout
      │  └─ TStackFrame                        ← SetContentAsFrame<TStackFrame>
      │     ├─ TBackgroundFrame                ← AddFrame<TBackgroundFrame>
      │     └─ TVertScrollFrame                ← AddFrame<TVertScrollFrame>
      │        └─ TColumnForm                  ← SetContentAsForm<TColumnForm>
      │           ├─ TEditFrame   (height 100) ← AddFrame<TEditFrame>(100, ...)
      │           └─ TButtonFrame (height 60)  ← AddFrame<TButtonFrame>(60, ...)
      └─ ActionButtonsLayout
         └─ TActionButtonFrame                 ← AddActionButton('X', ...)
```

This is, in short, the home screen of the HelloWorld demo.

## TElementDef: definitions as values

Columns and rows also accept a `TElementDef<T>`: the configuration procedure plus named parameters, in one value you can build elsewhere and pass around.

```pascal
Col.AddFrame<TLogoFrame>(
  TElementDef<TLogoFrame>.Create(nil, [ Param('Height', 100) ])
);
```

The parameters understood today are `Height` (`TColumnForm`), `Width` (`TRowForm`) and `OnClickProc` (`TScaffoldForm.AddActionButton`). A `TProc<T>` converts implicitly to a `TElementDef<T>` with no parameters. See [FMXER.UI.Misc](/reference/ui-misc#telementdef).
