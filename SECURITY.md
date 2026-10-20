# Security Policy

## Supported Versions

| Version                   | Supported          |
| ------------------------- | ------------------ |
| `master` / latest release | :white_check_mark: |
| Older releases            | :x:                |

If you are using an older version of FMXER, please upgrade to the [latest release](https://github.com/andrea-magni/FMXER/releases/latest) before reporting an issue: it may already be fixed.

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Use one of these private channels instead:

- **GitHub private vulnerability reporting** (preferred): go to the [Security tab](https://github.com/andrea-magni/FMXER/security) of the repository and click *"Report a vulnerability"*.
- **Email**: contact the maintainer directly, with `[FMXER SECURITY]` in the subject line.

When reporting, please include as much of the following as possible:

- a description of the vulnerability and its potential impact;
- the affected unit or element, the demo or the setup;
- steps to reproduce, ideally with a minimal project;
- the Delphi version, the target platform and the FMXER version or commit you tested;
- any suggested fix or mitigation.

## What to Expect

- You will receive an acknowledgement of your report, typically within a few days.
- The report will be investigated and its impact assessed; you may be contacted for more details.
- Once confirmed, a fix will be developed and released. You will be credited in the release notes, unless you prefer to remain anonymous.
- Please allow reasonable time for a fix to be released before any public disclosure (coordinated disclosure).

## Scope

FMXER is a UI framework for Delphi FireMonkey: it runs inside your application and has no network service of its own. Generally **in scope**:

- vulnerabilities in the FMXER source code (for example memory corruption, or unsafe handling of content shown by elements such as `TWebViewFrame`);
- the setup (`FMXER_<version>_Setup.exe`) and the design-time package;
- the AI agent skill in `Skills/`, if its instructions lead an agent to insecure code or actions.

Generally **out of scope**:

- vulnerabilities caused only by application code built on FMXER;
- issues in third-party dependencies (TFrameStand, IconFontsImageList, DelphiZXingQRCode, ZXing.Delphi, Skia): please report them upstream; a heads-up is still appreciated;
- the demos' sample data and URLs (for example the LibraryStore demo talks to a local MARS-Curiosity server over plain HTTP by design).

## A note on the `.res` files

The demo projects' `.res` files contain the Windows application manifest that Delphi embeds, with `publicKeyToken="6595b64144ccf1df"`: this is Microsoft's public key token of the Common Controls assembly, not a credential. Secret scanners that read `.res` files as text may report it.

Thank you for helping keep FMXER and its users safe!
