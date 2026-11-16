# Development

## Repository scope

The deployable implementation is entirely in `NeutralHumansDemo/Scripts`: `main.lua` gates startup using `config.lua`, `runtime.lua` manages instances, and `targets.lua` holds exact class names. All four files are required.

Keep the existing `NeutralHumansDemo` deployment directory and module names when updating the public project title. Changing these internal names could leave users with duplicate installations.

## Build

Use Python 3 with no additional packages:

```sh
python build_release.py
```

The builder uses an explicit file list, updates the generated target-list appendix in the technical report, and creates `dist/Neutral-Ming-Soldiers-0.3.0.zip`. It checks the whitelist, absence of old keybindings/native team-write calls, and archive contents. `dist/` is not committed.

## Configuration-entry check

With an available Lua 5.3+ interpreter:

```sh
lua tests/verify_release.lua NeutralHumansDemo/Scripts
```

This parses the four Lua files and checks that the default-enabled entry installs runtime while the disabled entry skips it. It replaces runtime with a stub for that boundary check; it does not emulate UE4SS or prove AI behavior. The original check was also run with Fengari's Lua 5.3 implementation. No interpreter is bundled.

## Game testing

Install into a working [UE4SS for WFF](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description) environment. The tested WFF package is 1.79, with core 3.0.1 Beta / cac01ee2; newer generic upstream replacements have not been validated. See [dependency rationale](UE4SS_DEPENDENCY.md). Fully exit and restart after changing source or configuration. Avoid Restart All Mods: a full reload crashed during local development while other mods were also being reinitialized.

For each new whitelist entry, test both configurations on a fresh, previously unhit instance. Record location, appearance, original attitude, passive application and retaliation. Include an abnormal/feathered enemy control where appropriate. Do not mark additional characters or chapters verified based solely on field writes or class names.

When modifying the AI logic, check forced targets, alarms, configuration resets and damage from non-player sources. Known limitations and earlier failed routes are documented in the technical report.

## Contributions and attribution

Keep each change focused and state what was actually tested. Use your own Git identity. AI-assisted contributions may record the tool in the commit message using `Assisted-by: OpenAI Codex (https://github.com/openai/codex)` or an equivalent accurate attribution. Do not list tools that did not contribute.

Contributions to this repository are intended to use its MIT license. Do not add game resources, saves, raw player logs, credentials, third-party executables or extracted SDK/usmap dumps. Describe investigation findings in original prose and keep raw evidence local.
