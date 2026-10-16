# Introduction

**FMXER** is a declarative visual framework for Delphi FireMonkey (FMX), inspired by the way [Google Flutter](https://flutter.dev) builds user interfaces. It was introduced at EKON 23 and [CodeRage 2019](https://youtu.be/RiK2re19Kyk), and has been used since then to build mobile and desktop apps from Delphi.

## The idea

In a classic FMX application every screen is a form designed in the IDE: you drop controls, set properties in the Object Inspector and write event handlers. That works, but screens tend to repeat the same pieces (a title bar, a list, a button with an icon, a card) and every variation becomes another form.

Flutter takes another road: a screen is a **tree of small widgets**, each configured in code and nested into the next. FMXER brings that approach to FMX, with the tools Delphi already has:

- an **element** is a plain `TFrame` or `TForm` descendant, designed once in the IDE (or written in code);
- elements are **nested in code**: a container exposes methods like `SetContentAsFrame<T>` or `AddFrame<T>`, which create the child element, configure it through an anonymous method and show it;
- most elements have **fluent setters** (`SetTitle`, `SetText`, `SetMargin`...) returning the element itself, so a configuration reads top to bottom;
- **screens are routes**: `TNavigator` creates a screen when you route to it and frees it when you close it.

```pascal
Scaffold
.SetTitle('Library Store')
.SetContentAsFrame<TListViewFrame>(
  procedure (List: TListViewFrame)
  begin
    List.AddItem('Book list', '', -1
    , procedure (const AItem: TListViewItem)
      begin
        Navigator.RouteTo('books');
      end
    );
  end
);
```

## Built on TFrameStand

FMXER does not reinvent the plumbing: it is built on [TFrameStand and TFormStand](https://andrea-magni.github.io/TFrameStand/), two components by the same author that show a frame (or the content of a form) inside any control, through a **stand** — a visual layer designed in a `TStyleBook`, with backgrounds, effects and animations.

Every FMXER container has its own `TFrameStand` and `TFormStand`: when you call `SetContentAsFrame<T>`, the container asks its `TFrameStand` to create a `T`, place it in the right layout, run the configuration procedure and show it. Closing a route hides and frees the whole tree. What you know about TFrameStand (stands, `OnShow*` animations, `[BeforeShow]` and `[Hide]` methods, `TSubjectInfo`) applies to FMXER elements too.

## What you get

| Area | What FMXER provides |
|---|---|
| Navigation | `TNavigator`: named routes, a stack of open screens, transient routes, delayed routing, create/close events |
| Screen structure | `TScaffoldForm`: title bar with an optional detail area, content, floating action buttons, snackbar |
| Layout | columns, rows, stacks, vertical and horizontal scroll boxes, centered content, cards, left/right accessories, 50/50 pairs, margins and paddings |
| Elements | text, buttons, edits, track bars, color pickers, chips, images, SVG, Lottie animations, Skia paint boxes, QR codes, web views, lists |
| Icons | Material Design Icons (5,900+ glyphs) through an icon font and a shared image list |
| Styling | `TAppColors` (primary, text, background, divider colors), stands, fluent margin/padding/align helpers |

## Status and requirements

FMXER is an open source project (MPL 2.0) at version **1.1**, with more work on `master` since then (new elements and the QRCode demo). It targets **Delphi 12** and **13**, with the Skia built into RAD Studio (Delphi 11 is supported up to v.1.1) — see [Installation](./installation).

::: tip Who is FMXER for?
FMXER suits apps made of many similar screens — lists, details, forms, settings, dashboards — where composing in code is faster than designing each screen. You can mix it freely with classic forms: an FMXER element is just a frame, and a classic form can be a route.
:::

## Next steps

- [Install FMXER](./installation) and its dependencies.
- Build [your first app](./getting-started).
- Read the [core concepts](./core-concepts) to understand elements, stands and ownership.
