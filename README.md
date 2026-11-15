# Wuchang: Fallen Feathers — Neutral Ming Soldiers Mod

明末：渊虚之羽｜明军中立 MOD

[English](README.md) | [简体中文](README.zh-CN.md)

A UE4SS Lua mod for **Wuchang: Fallen Feathers (WFF)**. Selected Ming soldiers remain passive until attacked and can retaliate. Config-controlled, enabled by default, with no hotkeys.

《明末：渊虚之羽》明军中立 MOD：让名单内明军不主动攻击白无常，受击后仍可反击。通过配置文件控制，默认开启，无快捷键。

Version **0.3.0** · **MIT License**

**Download / 下载：[Neutral Ming Soldiers on Nexus Mods](https://www.nexusmods.com/wuchangfallenfeathers/mods/496)**

[中文安装教程](docs/INSTALL_zh-CN.md) · [Installation](docs/INSTALL_EN.md) · [技术报告](docs/TECHNICAL_REPORT_zh-CN.md) · [Development](docs/DEVELOPMENT.md) · [Changelog](CHANGELOG.md) · [GitHub metadata](docs/GITHUB_METADATA.md)

The whitelist currently contains 53 candidate blueprints. One armored shield-and-spear Ming soldier at 唐王行宫 was player-tested: it did not attack first and retaliated when attacked. Civilian, ordinary-soldier and all-chapter coverage remains incomplete. The final configuration entry was checked in a standalone Lua runtime; a complete in-game retest of that entry is still pending.

## Install and configure

Requires an already working UE4SS installation compatible with your game build. Copy `NeutralHumansDemo` into its `Mods` directory and retain `enabled.txt`. The internal folder and log prefix remain `NeutralHumansDemo` for compatibility with existing installations.

Edit `NeutralHumansDemo/Scripts/config.lua`:

```lua
return {
    enabled = true,
}
```

Use `true` to enable or `false` to disable, then fully exit and restart the game. There are no hotkeys. Detailed installation, updating and removal instructions are linked above.

Tested development environment: PC Game Pass / WinGDK package 1.13.2.0, engine 5.1.1, UE4SS 3.0.1 Beta / cac01ee2. Steam and other builds are unverified.

## How it works

1. Match exact blueprint class names from `targets.lua` and check the instance's original attitude toward the player.
2. Save the selected hostile instance's sight/hearing flags, clear existing targets, and disable normal sight/hearing acquisition.
3. Reapply passive settings after AI configuration reloads and process new instances using initialization hooks and a periodic scan.
4. Restore the original flags after `AfterTakeDamage`, allowing the game's combat logic to retaliate.

Suppression also affects acquisition of other NPCs. Any damage source can trigger restoration. Instances do not automatically become passive again after combat. Forced targets, alarms and special AI need more testing. No shared faction table, original PAK or damage value is edited, and the mod has no save-writing code.

## Source and builds

This repository contains the complete custom Lua implementation, configuration, whitelist, documentation, release builder and configuration-entry check.

```text
NeutralHumansDemo/      Deployable UE4SS mod
docs/                  Installation, implementation and development notes
tests/                 Standalone configuration-entry check
build_release.py       Manual-install archive builder
LICENSE                MIT license
```

Build the player archive with Python 3:

```sh
python build_release.py
```

Output: `dist/Neutral-Ming-Soldiers-0.3.0.zip`. Python's standard library is sufficient. The ZIP includes the mod, player documentation, technical report and MIT license. Generated archives are ignored by Git and can be distributed as release assets.

Game assets, saves, raw logs, crash dumps, extracted SDK/usmap files, research tool binaries and other mods are not included. UE4SS is a separate dependency.

## Credits and license

Project direction, maintenance and in-game testing: **dreamcat**. The majority of the initial Lua implementation and documentation was generated with assistance from **[OpenAI Codex](https://github.com/openai/codex)**. UE4SS provides the runtime; UAssetGUI was used for local inspection. Neither tool is redistributed here.

Original project code and documentation are released under the [MIT License](LICENSE), including permission for commercial use subject to its notice requirements. This does not license the game or third-party dependencies. Any separate distribution-page permission text should be kept consistent with this license.
