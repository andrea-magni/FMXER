# FMXER skill for Claude (Claude Code / Cowork)

This folder contains an [Agent Skill](https://code.claude.com/docs/en/skills) for working with FMXER:

- **`fmxer-development/`** — develop Delphi FireMonkey apps with FMXER: named routes with `TNavigator` (Back button, transient routes, passing data), `TScaffoldForm`, containers and explicit sizing (columns, rows, stacks, scroll boxes...), elements and their fluent setters, icons and `TAppColors`, state shared through closures, message subscriptions and the lifetime of elements, Delphi 12+ Skia units, writing your own elements.

## Install as a plugin (recommended)

This repository is also a Claude plugin marketplace. From Claude Code:

```
/plugin marketplace add andrea-magni/FMXER
/plugin install fmxer@fmxer
```

The skill becomes available automatically (also invocable as `/fmxer:fmxer-development`) and gets updated when new versions are published.

## Install with npx (any AI tool)

If you use other agentic tools besides Claude Code (Cursor, Codex, ...) or prefer not to use plugins, the [skills CLI](https://github.com/vercel-labs/skills) installs the same skill into any compatible tool (requires Node.js):

```
npx skills add andrea-magni/FMXER
```

## Manual install

Alternatively, copy the skill folder into one of:

- `.claude/skills/` inside your own project (project-level, shared with your team via git);
- `~/.claude/skills/` (personal, available in every project).

Example (from your project root):

```
git clone https://github.com/andrea-magni/FMXER
xcopy /E /I FMXER\Skills\fmxer-development .claude\skills\fmxer-development
```

Verify with `/skills` or just ask Claude to add a screen to your FMXER app.
