---
description: "An Agent Skill that teaches Claude Code and other AI coding agents to develop Delphi FireMonkey apps with FMXER: installation as a plugin, with npx or by hand, and usage examples."
---

# AI Agent Skill

FMXER ships with an [Agent Skill](https://code.claude.com/docs/en/skills) that teaches AI coding agents (Claude Code, Cowork, and any tool supporting the open `SKILL.md` format) how to work with FMXER. It lives in the [`Skills/`](https://github.com/andrea-magni/FMXER/tree/master/Skills) folder of the repository:

| Skill | What it does |
| --- | --- |
| **`fmxer-development`** | FireMonkey apps with FMXER: [named routes](./navigation) with `TNavigator` (Back button, transient routes, passing data), the [scaffold](/elements/scaffold), [containers and explicit sizing](./layouts), [elements](/elements/) and their fluent setters, [icons](/elements/icons) and [`TAppColors`](./styling), [state and events](./state), [your own elements](./custom-elements), with the rules that avoid the common mistakes (invisible white `TTextFrame` text, missing sizes, helpers that return `TControl`, closures that outlive their elements, old Skia unit names...). It includes the exact declarations of the public API, taken from the source. |

A skill is a folder with a `SKILL.md` file (instructions, plus a `description` that tells the agent *when* to use it) and `references/` files read on demand. Once installed, the agent uses it by itself when your code uses FMXER or you ask for screens, routes, layouts or elements in an FMXER app.

::: info Since v.1.2
The skill describes v.1.2 and later: Delphi 12+ with the Skia of RAD Studio (`System.Skia`, `FMX.Skia`) and the v.1.2 behaviour of the navigator (transient routes remembered, `CloseRoute` removing the closed route from the stack).
:::

## Installation in Claude Code (recommended: plugin)

The FMXER repository is also a **Claude plugin marketplace**. From Claude Code:

```
/plugin marketplace add andrea-magni/FMXER
/plugin install fmxer@fmxer
```

The skill is available at once and is updated when a new version is published. It can also be invoked explicitly:

```
/fmxer:fmxer-development
```

FMXER is built on TFrameStand, which has [its own skill](https://andrea-magni.github.io/TFrameStand/guide/agent-skills): install it too if you also use stands, dialogs or the TFrameStand lifecycle directly.

## Installation with npx (any AI tool)

For other agentic tools (Cursor, Codex, ...), or without plugins, the [skills CLI](https://github.com/vercel-labs/skills) installs the same skill into any compatible tool (requires Node.js):

```
npx skills add andrea-magni/FMXER
```

## Manual installation (Claude Code / Cowork)

Copy the skill folder into one of the standard skill locations:

- `.claude/skills/` inside your project: project-level, shared with your team via git;
- `~/.claude/skills/`: personal, available in every project.

Example, from your project root (Windows):

```
git clone https://github.com/andrea-magni/FMXER
xcopy /E /I FMXER\Skills\fmxer-development .claude\skills\fmxer-development
```

Verify with `/skills`, or ask the agent to add a screen to your app.

## Other AI agents

The skill is plain Markdown in the open Agent Skills format. Agents without skill support can read it from their instructions file (`AGENTS.md`, `.cursorrules`, custom instructions...):

```markdown
When working on Delphi FireMonkey code that uses FMXER, read and follow
Skills/fmxer-development/SKILL.md (and its references/ folder).
```

The [llms.txt](https://andrea-magni.github.io/FMXER/llms.txt) and [llms-full.txt](https://andrea-magni.github.io/FMXER/llms-full.txt) files of this site give an assistant the whole documentation in one request.

## Usage examples

With the skill installed, prompts like these produce idiomatic FMXER code:

- *"Add a settings screen with a server address, a dark mode switch and a Save button, reachable from the home screen."* (a `Routes.settings.pas` unit with `DefineRoute<TScaffoldForm>`, a column in a `TVertScrollFrame`, `TEditFrame`, `TContainerFrame.SetContentAs<TSwitch>`, `RouteTo`/`CloseRoute`)
- *"Show the customers in a searchable list and open the details of the one I tap."* (`TListViewFrame` with `ItemBuilderProc`, the selection stored before `RouteTo`)
- *"Show a spinner while the data loads, then the results."* (a transient route or the scaffold's title detail area, `ShowSnackBar` for errors, `IsRouteActive` in the callback)
- *"Update the badge on the home screen when a new message arrives."* (`System.Messaging` with a subscription tied to the element's lifetime)
