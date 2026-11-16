# Wuchang: Fallen Feathers — Neutral Ming Soldiers Mod

明末：渊虚之羽｜明军中立 MOD

[English](README.md) | [简体中文](README.zh-CN.md)

> [!WARNING]
> **UE4SS for WFF is required. DO NOT use stock upstream UE4SS packages for this mod.**
> Install **[UE4SS for WFF by Framecore](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)**. Generic upstream releases are not supported replacements for this project's WFF environment. Reported compatibility problems include loading Fatal Errors and gamepad/game-cursor initialization failures. Keep the WFF package's game-specific setup; see the dependency explanation below.

A UE4SS Lua mod for **Wuchang: Fallen Feathers (WFF)**. Selected Ming soldiers remain passive until attacked and can retaliate. Config-controlled, enabled by default, with no hotkeys.

《明末：渊虚之羽》明军中立 MOD：让名单内明军不主动攻击白无常，受击后仍可反击。通过配置文件控制，默认开启，无快捷键。

Version **0.3.0** · **MIT License**

**Download / 下载：[Neutral Ming Soldiers on Nexus Mods](https://www.nexusmods.com/wuchangfallenfeathers/mods/496)**

[中文安装教程](docs/INSTALL_zh-CN.md) · [Installation](docs/INSTALL_EN.md) · [技术报告](docs/TECHNICAL_REPORT_zh-CN.md) · [Development](docs/DEVELOPMENT.md) · [Changelog](CHANGELOG.md) · [GitHub metadata](docs/GITHUB_METADATA.md)

The whitelist currently contains 53 candidate blueprints. One armored shield-and-spear Ming soldier at 唐王行宫 was player-tested: it did not attack first and retaliated when attacked. Civilian, ordinary-soldier and all-chapter coverage remains incomplete. The final configuration entry was checked in a standalone Lua runtime; a complete in-game retest of that entry is still pending.

## Install and configure

**Required dependency: [UE4SS for WFF by Framecore](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description).** Install that game-specific package following its author's instructions before installing this mod. Keep an existing working WFF installation. The dependency is downloaded separately and is not bundled here.

### Why not stock UE4SS?

Its author reports that the game's 1.7 update caused UE4SS to fail on loading with a Fatal Error. The WFF package adjusts `UE4SS-settings.ini`, adds `Default_UVTD_Configs`, and adjusts `BPModLoaderMod`. These are game-specific packaging/configuration changes; selecting this dependency does not mean this Lua mod needs a separate fork of the UE4SS core. [Author's explanation](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description).

Newer upstream builds have also had a reported gamepad/cursor initialization regression. Upstream has accepted a workaround, but replacement with a newer generic build has not been validated for this project. Follow the WFF dependency rather than substituting a stock upstream download. [Details and sources](docs/UE4SS_DEPENDENCY.md).

### Install this mod

Copy `NeutralHumansDemo` into the WFF installation's `Mods` directory and retain `enabled.txt`. The internal folder and log prefix remain `NeutralHumansDemo` for compatibility with existing installations.

**Steam:** in your Steam Library, right-click the game → **Manage → Browse local files**, then open `Project_Plague\Binaries\Win64\`. For this mod's release ZIP, merge its `ue4ss` folder into `Win64`; for a Git clone or GitHub source ZIP, copy only `NeutralHumansDemo` into `Win64\ue4ss\Mods\`. The installed entry must be:

```text
<SteamLibrary>\steamapps\common\Wuchang Fallen Feathers\Project_Plague\Binaries\Win64\ue4ss\Mods\NeutralHumansDemo\Scripts\main.lua
```

**PC Game Pass / XGP:** use `Project_Plague\Binaries\WinGDK\` instead. The mod's folder structure is otherwise the same. See the [Steam walkthrough](docs/INSTALL_EN.md#steam) and [XGP walkthrough](docs/INSTALL_EN.md#xgp). Steam placement follows existing Wuchang Lua mods and UE4SS directory conventions; it has not been an in-game compatibility test of this project.

Edit `NeutralHumansDemo/Scripts/config.lua`:

```lua
return {
    enabled = true,
}
```

Use `true` to enable or `false` to disable, then fully exit and restart the game. There are no hotkeys. Detailed installation, updating and removal instructions are linked above.

Tested development environment: PC Game Pass / WinGDK package 1.13.2.0, engine 5.1.1, UE4SS for WFF package 1.79 with core UE4SS 3.0.1 Beta / cac01ee2. The WFF package version and UE4SS core version are different identifiers. Steam and other builds are unverified.

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

Game assets, saves, raw logs, crash dumps, extracted SDK/usmap files, research tool binaries and other mods are not included. UE4SS for WFF is a separate dependency.

## Credits and license

Project direction, maintenance and in-game testing: **dreamcat**. The majority of the initial Lua implementation and documentation was generated with assistance from **[OpenAI Codex](https://github.com/openai/codex)**. UE4SS provides the runtime; UAssetGUI was used for local inspection. Neither tool is redistributed here.

Original project code and documentation are released under the [MIT License](LICENSE), including permission for commercial use subject to its notice requirements. This does not license the game or third-party dependencies. Any separate distribution-page permission text should be kept consistent with this license.
