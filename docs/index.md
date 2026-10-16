---
layout: home

hero:
  name: "FMXER"
  text: "Declarative UIs for FireMonkey"
  tagline: Build Delphi FMX screens the way Flutter does — by composing small, reusable elements in code. Named routes, a scaffold, layout containers and ready-made elements, all on top of TFrameStand.
  image:
    src: /logo-hero.png
    alt: FMXER
  actions:
    - theme: brand
      text: Get Started
      link: /guide/introduction
    - theme: alt
      text: Your First App
      link: /guide/getting-started
    - theme: alt
      text: Element Catalog
      link: /elements/
    - theme: alt
      text: View on GitHub
      link: https://github.com/andrea-magni/FMXER

features:
  - icon: 🧱
    title: Compose, don't design
    details: 'Every element is a TFrame or a TForm. Nest them in code with generics and anonymous methods: SetContentAsFrame<TTextFrame>(procedure (F: TTextFrame) ...).'
    link: /guide/core-concepts
    linkText: Core concepts
  - icon: 🧭
    title: Named routes
    details: 'Define each screen once with Navigator.DefineRoute, then RouteTo, CloseRoute and StackPop. Screens are created on demand and freed when closed.'
    link: /guide/navigation
    linkText: Navigation
  - icon: 🏗️
    title: Scaffold & layouts
    details: 'A Material-like scaffold (title bar, content, floating action buttons, snackbar), plus columns, rows, stacks, scroll boxes, cards and pairs.'
    link: /guide/layouts
    linkText: Composing layouts
  - icon: 🎨
    title: Skia-powered elements
    details: 'Text, SVG, Lottie animations, paint boxes and rounded QR codes rendered with Skia; Material Design icons from an icon font.'
    link: /elements/
    linkText: Element catalog
  - icon: 🎬
    title: Stands and animations
    details: 'Elements are shown through TFrameStand and TFormStand: fade-ins, snackbars and any stand you design in a TStyleBook come for free.'
    link: /guide/styling
    linkText: Styling
  - icon: 📱
    title: Every FMX platform
    details: 'Windows, macOS, iOS and Android from the same code. The demos target all of them, including the iOS simulator on Apple silicon.'
    link: /guide/installation
    linkText: Installation
---

<div class="vp-doc" style="max-width: 960px; margin: 48px auto 0; padding: 0 24px;">

## What is FMXER?

**FMXER** is a small visual framework for [Embarcadero Delphi](https://www.embarcadero.com/products/delphi) FireMonkey (FMX), inspired by [Google Flutter](https://flutter.dev): instead of designing every screen in the form designer, you **compose** screens in code out of reusable elements — frames and forms — and let FMXER create, place, show and free them for you.

```pascal
uses FMXER.Navigator, FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.TextFrame, FMXER.ButtonFrame;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1)
    .DefineRoute<TScaffoldForm>('home'
    , procedure (Home: TScaffoldForm)
      begin
        Home
        .SetTitle('Hello, FMXER!')
        .SetContentAsForm<TColumnForm>(
          procedure (Col: TColumnForm)
          begin
            Col
            .AddFrame<TTextFrame>(50
            , procedure (Text: TTextFrame)
              begin
                Text.SetContent('A screen composed in code');
              end
            )
            .AddFrame<TButtonFrame>(60
            , procedure (Button: TButtonFrame)
              begin
                Button
                .SetText('Say hello')
                .SetOnClickHandler(
                  procedure
                  begin
                    Home.ShowSnackBar('Hello!', 2000);
                  end
                );
              end
            );
          end
        );
      end
    );

  Navigator.RouteTo('home');
end;
```

FMXER is built on [TFrameStand and TFormStand](https://andrea-magni.github.io/TFrameStand/): every element is shown through a *stand*, so transitions and visual effects come from a `TStyleBook`, not from code.

## Where to go next

- New here? Read the [introduction](/guide/introduction), then build [your first app](/guide/getting-started).
- Looking for a ready-made element? Browse the [catalog](/elements/).
- Want to see it running? The [demos](/demos/) go from a "Hello, World" to a QR code reader with the camera.

</div>
