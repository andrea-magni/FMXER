# Regenerating the documentation

The content of this VitePress site is **authored by reading the source code**, the
demos and the GitHub releases: there is no generator that rebuilds the prose from
the `.pas` files. "Regenerating" means having an AI agent (Claude Code) re-synthesize
**only the parts that changed** since the last sync.

## TL;DR

1. Open **Claude Code** in the repository root (`C:\Sviluppo\Librerie\FMXER`).
2. Paste the prompt below.
3. Review the changes, run `docs\build.cmd` (it also checks the internal links), commit.

## How it works

- [`.docs-baseline`](./.docs-baseline) holds the `commit=` the docs are aligned to.
- What changed since then:

  ```bash
  git diff --stat <baseline-commit>..HEAD -- source demos
  git diff <baseline-commit>..HEAD -- source
  ```

- Mapping (source → page):
  - `FMXER.Navigator.pas` → `guide/navigation.md`, `reference/navigator.md`
  - `FMXER.UI.Misc.pas` → `reference/ui-misc.md`, `guide/core-concepts.md` (helpers, `TElementDef`)
  - `FMXER.UI.Consts.pas` → `reference/app-colors.md`, `guide/styling.md`
  - `FMXER.ScaffoldForm.pas`, `FMXER.ActionButtonFrame.pas` → `elements/scaffold.md`
  - `FMXER.TabsFrame.pas` → `elements/tabs.md` (and the bottom navigation in `elements/scaffold.md`)
  - `FMXER.Modals.pas`, `FMXER.AlertFrame.pas`, `FMXER.ChoicesFrame.pas` → `elements/dialogs.md`
    (the stands in `FMXER.Modals` are `lib\TFrameStand\stands\Stands.Light.style`: regenerate the constant
    when the gallery changes)
  - container forms and frames (`ColumnForm`, `RowForm`, `CenterForm`, `ContainerForm/Frame`, `BackgroundForm/Frame`,
    `VertScrollForm/Frame`, `HorzScrollFrame`, `StackFrame`, `AccessoryFrame`, `HorzPairFrame`, `CardFrame`,
    `MarginFrame`, `PaddingFrame`, `HorzDividerFrame`) → `elements/containers.md`, `guide/layouts.md`
  - `TextFrame`, `ButtonFrame`, `ColorButtonFrame`, `EditFrame`, `TrackbarFrame`, `ColorPickerFrame`, `ChipFrame`,
    `ChipsFrame` → `elements/text-and-input.md`
  - `SwitchFrame`, `CheckBoxFrame`, `RadioGroupFrame`, `ComboBoxFrame`, `DateEditFrame`, `ProgressBarFrame`
    → `elements/form-controls.md`
  - `ImageFrame`, `LogoFrame`, `SVGFrame`, `AnimatedImageFrame`, `ActivityBubblesFrame`, `PaintBoxFrame`,
    `WebViewFrame` → `elements/images-and-media.md`
  - `ListViewFrame` → `elements/lists.md`
  - `QRCodeFrame`, `QRCode.*` → `elements/qrcode.md`
  - `IconFontsData`, `IconFontsGlyphFrame`, `GlyphFrame`, `Icons.*` → `elements/icons.md`
  - a new unit → `elements/index.md` (catalog), `reference/units.md`, and the page of its category; also `List.md`, and both `packages\*\FMXERPackage` (or `FMXERQRCodePackage`) .dpk/.dproj
  - `demos/` → `demos/index.md` and the examples in the guide
  - `tests/`, `build.cmd` → `guide/building.md`
  - dependencies, Delphi versions → `guide/installation.md`, `reference/units.md`
  - GitHub releases → `release-notes.md`
  - any public API or behaviour change → also the agent skill in `Skills/fmxer-development/`
    (`references/api.md` holds declarations copied from `source\`; bump `version` in
    `.claude-plugin/plugin.json` when the skill changes)
- `ANALYSIS.md` (not published) is the technical review of the code: when an issue it
  lists is fixed, remove the corresponding "Known issue" boxes from the pages
  (`guide/navigation.md`, `reference/navigator.md`, `elements/scaffold.md`, `elements/containers.md`,
  `elements/lists.md`, `elements/icons.md`, `reference/ui-misc.md`, `guide/faq.md`, `guide/state.md`).

## Prompt to paste

```text
Refresh the VitePress documentation in docs/ for FMXER.
1. Read docs/.docs-baseline and run `git diff --stat <commit>..HEAD -- source demos`.
2. For each changed unit, read the diff and update only the affected pages, following the
   mapping in docs/REGEN.md. Keep the existing style: English, short paragraphs, Delphi
   code samples that compile, tables for members.
3. If a fix removes a "Known issue" listed in docs/ANALYSIS.md, remove its boxes from the pages
   and update the status in ANALYSIS.md.
4. If the public API or a documented behaviour changed, update Skills/fmxer-development/
   (SKILL.md and references/, api.md from the source declarations) and bump the version
   in .claude-plugin/plugin.json.
5. If a new release exists (`gh release list`), add it to docs/release-notes.md.
6. Run docs\build.cmd and fix any dead link.
7. Update docs/.docs-baseline to the current HEAD and today's date.
Do not touch pages unrelated to the changes.
```
