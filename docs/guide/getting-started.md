# Your First App

This walkthrough builds a two-screen app: a home screen where you type your name, and a second screen that greets you. Along the way you meet the pieces you will use in every FMXER app: the navigator, the scaffold, a column and a few elements.

The finished code is close to the **NewProjectTemplate** and **HelloWorld** [demos](/demos/).

## 1. Create the project

1. **File > New > Multi-Device Application**, *Blank Application*.
2. Save the main form as `Forms.Main.pas` (form name `MainForm`) and the project as `MyFirstApp`.
3. Add the FMXER search path (see [Installation](./installation#search-path)).
4. Drop a **TFormStand** on the main form (it is named `FormStand1`). This is the only component you need at design time: the navigator uses it to show every screen of the app inside the main form.
5. Enable Skia in the project source:

```pascal
begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
```

## 2. Initialize the navigator and define a route

A **route** is a named screen. `DefineRoute<T>` records how to build it — a form class and a configuration procedure — but creates nothing yet: the screen is created the first time you route to it.

Add an `OnCreate` handler to the main form:

```pascal
implementation

{$R *.fmx}

uses
  FMXER.Navigator, FMXER.ScaffoldForm;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // the navigator shows the routes through FormStand1, inside this form
  Navigator(FormStand1);

  Navigator.DefineRoute<TScaffoldForm>('home'
  , procedure (Home: TScaffoldForm)
    begin
      Home.SetTitle('My first FMXER app');
    end
  );

  Navigator.RouteTo('home');
end;
```

Run it: the main form shows a **scaffold** — a title bar in the primary color and an empty content area.

`Navigator(FormStand1)` initializes the singleton navigator the first time; afterwards `Navigator` (no arguments) returns it from anywhere in the app.

## 3. Compose the content

The scaffold content can be any frame or form. A **column** stacks elements vertically, each one with a fixed height:

```pascal
uses
  FMXER.Navigator, FMXER.UI.Misc, FMXER.ScaffoldForm, FMXER.ColumnForm,
  FMXER.TextFrame, FMXER.EditFrame, FMXER.ButtonFrame;

var
  UserName: string;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Navigator(FormStand1);

  Navigator.DefineRoute<TScaffoldForm>('home'
  , procedure (Home: TScaffoldForm)
    begin
      Home
      .SetTitle('My first FMXER app')
      .SetContentAsForm<TColumnForm>(
        procedure (Col: TColumnForm)
        begin
          Col
          .AddFrame<TTextFrame>(60
          , procedure (Text: TTextFrame)
            begin
              Text
              .SetContent('Welcome! What is your name?')
              .SetFontColor(TAlphaColorRec.Black)
              .SetFontSize(20);
            end
          )
          .AddFrame<TEditFrame>(90
          , procedure (Edit: TEditFrame)
            begin
              Edit
              .SetCaption('Name')
              .SetTextPrompt('Type your name here')
              .SetFocusOnShow(True)
              .OnChangeProc :=
                procedure (ATracking: Boolean)
                begin
                  UserName := Edit.GetText;
                end;
            end
          )
          .AddFrame<TButtonFrame>(60
          , procedure (Button: TButtonFrame)
            begin
              Button
              .SetText('Continue')
              .SetOnClickHandler(
                procedure
                begin
                  Navigator.RouteTo('greeting');
                end
              );
            end
          )
          .ContentLayout.SetPadding(10);
        end
      );
    end
  );

  Navigator.RouteTo('home');
end;
```

Things to notice:

- every `Add*`/`Set*` call takes the **element class** as a generic parameter and a **configuration procedure** that receives the new instance, already created and parented;
- the configuration procedures are **closures**: the button's handler can use `Navigator`, the edit's handler can write `UserName`, and so on;
- `TColumnForm.AddFrame<T>(Height, ...)` returns the column itself, so the elements chain. Sizes are explicit: see [Composing Layouts](./layouts).

`TAlphaColorRec` comes from `System.UITypes`, already in the uses clause of a new FMX form.

## 4. A second route

Define the greeting screen next to the home route. Its content is built **when you route to it**, so it reads the current value of `UserName`:

```pascal
  Navigator.DefineRoute<TScaffoldForm>('greeting'
  , procedure (Greeting: TScaffoldForm)
    begin
      Greeting
      .SetTitle('Hello')
      .SetContentAsFrame<TTextFrame>(
        procedure (Text: TTextFrame)
        begin
          Text
          .SetContent('Hello, ' + UserName + '!')
          .SetFontColor(TAlphaColorRec.Black)
          .SetFontSize(28);
        end
      )
      .AddActionButton('X'
      , procedure
        begin
          Navigator.CloseRoute('greeting');
        end
      );
    end
  );
```

`AddActionButton` adds a round floating button at the bottom right of the scaffold. Closing the route hides the screen (with the stand's animation) and frees it, with everything it contains: the next `RouteTo('greeting')` builds a fresh one.

## 5. Back button and closing the app

The navigator keeps a **stack** of the routes you opened. Two small handlers complete the app:

```pascal
procedure TMainForm.FormCreate(Sender: TObject);
begin
  // ... route definitions as above ...

  // closing the home route closes the application
  Navigator.OnCloseRoute :=
    procedure (ARouteName: string)
    begin
      if ARouteName = 'home' then
        Close;
    end;

  Navigator.RouteTo('home');
end;

// Android back button, and Esc on desktop: go back one screen
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if (Key = vkHardwareBack) or (Key = vkEscape) then
  begin
    if Navigator.Stack.Count > 1 then
    begin
      Key := 0;
      Navigator.StackPop;
    end;
  end;
end;
```

## 6. One unit per route

As an app grows, keep each route in its own unit, with a `Define...Route` procedure — the layout used by all the demos:

```pascal
unit Routes.home;

interface

procedure DefineHomeRoute(const ARouteName: string = 'home');

implementation

uses
  FMXER.Navigator, FMXER.ScaffoldForm, FMXER.LogoFrame;

procedure DefineHomeRoute(const ARouteName: string);
begin
  Navigator.DefineRoute<TScaffoldForm>(ARouteName
  , procedure (Scaffold: TScaffoldForm)
    begin
      Scaffold
      .SetTitle('New Project')
      .SetContentAsFrame<TLogoFrame>;
    end
  );
end;

end.
```

The main form then only initializes the navigator, calls the `Define...Route` procedures and routes to the first screen.

## Next

- [Core Concepts](./core-concepts): elements, stands, ownership and the configuration procedures.
- [Navigation](./navigation): transient routes, delayed routing, the stack and its events.
- The [element catalog](/elements/), to see what you can put on screen.
