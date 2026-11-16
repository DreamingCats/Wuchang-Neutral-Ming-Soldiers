# Neutral Ming Soldiers for WUCHANG: Fallen Feathers

Version 0.3.0 — configuration-controlled UE4SS Lua mod.

> [!WARNING]
> **UE4SS for WFF is required. DO NOT use stock upstream UE4SS packages for this mod.**
> Download **[UE4SS for WFF by Framecore](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)** and follow its game-specific setup. Generic upstream packages are not supported replacements; reported problems include loading Fatal Errors and gamepad/game-cursor initialization failures.

Makes selected hostile Ming soldier blueprints passive by temporarily disabling their sight/hearing acquisition. Receiving a damage callback restores the original senses and lets the game's combat logic respond.

**Player-confirmed test:** one armored Ming shield-and-spear soldier at 唐王行宫 did not initiate an attack and retaliated when attacked. This is an experimental release, not verified coverage of every soldier, civilian or chapter.

## Requirements and installation

The following steps install **Neutral Ming Soldiers itself**, assuming [UE4SS for WFF](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description) is already working. The dependency and loader DLLs are not bundled.

<a id="steam"></a>

### Steam

1. Fully exit the game. In your Steam Library, right-click the game → **Manage → Browse local files**. Use the folder Steam opens, including for custom library locations.
2. Open `Project_Plague\Binaries\Win64\`. A common complete path is:

   ```text
   <SteamLibrary>\steamapps\common\Wuchang Fallen Feathers\Project_Plague\Binaries\Win64\
   ```

3. **Mod release ZIP:** merge its `ue4ss` folder into `Win64`. Alternatively, copy only its `ue4ss\Mods\NeutralHumansDemo` folder into the existing `Win64\ue4ss\Mods\`.
4. **Git clone or GitHub source ZIP:** copy only the source tree's `NeutralHumansDemo` folder into `Win64\ue4ss\Mods\`. Do not copy the outer repository folder, documentation, tests or builder into the game.
5. Confirm both files are present:

   ```text
   Project_Plague\Binaries\Win64\ue4ss\Mods\NeutralHumansDemo\enabled.txt
   Project_Plague\Binaries\Win64\ue4ss\Mods\NeutralHumansDemo\Scripts\main.lua
   ```

6. Keep `enabled = true` in `Scripts/config.lua`, restart and load your save. No activation hotkey is needed.

This placement follows the [Wuchang Minimap author's instructions](https://www.nexusmods.com/wuchangfallenfeathers/mods/420?tab=description), [another Wuchang Lua mod's folder layout](https://www.nexusmods.com/wuchangfallenfeathers/mods/493?tab=description) and [UE4SS's executable-directory convention](https://docs.ue4ss.com/installation-guide.html). These are directory references, not additional mod requirements. **This project's in-game Steam behavior remains untested.**

<a id="xgp"></a>

### PC Game Pass / XGP

The tested local executable directory is:

```text
C:\XboxGames\Wuchang PCGP\Content\Project_Plague\Binaries\WinGDK\
```

Use your actual installation drive and path. Merge the release archive's `ue4ss` folder into `WinGDK`, or copy the source tree's `NeutralHumansDemo` into `WinGDK\ue4ss\Mods\`. The remaining steps are the same: Steam uses `Win64`, while the tested XGP installation uses `WinGDK`.

### Check either installation

```text
<real game EXE directory>/
└─ ue4ss/
   └─ Mods/
      └─ NeutralHumansDemo/
         ├─ enabled.txt
         └─ Scripts/
            ├─ main.lua
            ├─ config.lua
            ├─ runtime.lua
            └─ targets.lua
```

Avoid extra nesting such as `Mods\NeutralHumansDemo\NeutralHumansDemo\Scripts`. This Lua mod does not go beside the outer launcher or in `Content/Paks/~mods`. Keep `enabled.txt`; if you manage this mod through your own `mods.txt`, check its entry without replacing the whole list. For a custom UE4SS working directory, use its active `Mods` folder instead of rearranging the loader.

Launch and load a save, then allow a second or two for newly loaded instances to be processed. Manual installation is documented; Vortex/FOMOD automation has not been tested.

Tested environment: PC Game Pass / WinGDK package `1.13.2.0`, runtime engine `5.1.1`, WFF package `1.79`, core UE4SS `3.0.1 Beta / cac01ee2`. Package and core versions are separate identifiers. Steam and other builds remain unverified. Keep an already working WFF installation instead of replacing it for this archive.

### Why this dependency?

The [WFF package author](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description) reports Fatal Errors after the game's 1.7 update and lists changes to settings, `Default_UVTD_Configs` and `BPModLoaderMod`. Later upstream builds also had a gamepad/cursor regression ([#1499](https://github.com/UE4SS-RE/RE-UE4SS/issues/1499)). A workaround has since been accepted upstream, but this project has not validated replacing its WFF environment with a newer generic build. This is a supported-dependency choice, not a claim that every upstream build is incompatible or that the WFF core is a separate engine fork.

## Enable or disable

Edit `ue4ss/Mods/NeutralHumansDemo/Scripts/config.lua` with a text editor:

```lua
return {
    enabled = true,
}
```

Use lowercase `true` to enable or `false` to disable, without quotes. Keep the `.lua` extension and save as UTF-8. **Fully exit and restart the game after editing.** Configuration is read once at startup.

There are **no hotkeys** in 0.3.0. F8, F5 and the earlier Ctrl+Alt bindings no longer control this mod. When disabled, the entry point logs its state and installs no runtime hooks or polling.

Search the UE4SS log for `ready v0.3.0: enabled=true` or `v0.3.0 disabled by Scripts/config.lua`. `passive` records application to an instance; `retaliation` records restoration after a damage callback. These entries do not prove every resulting behavior.

## Updating and removing

Exit the game before updating. Preserve your configuration first: the supplied config defaults to enabled and overwriting it resets your preference. Replace files in the same mod directory and restart. Do not use UE4SS's Restart All Mods; a full-mod reload crashed during local development.

To uninstall, exit the game and move only `ue4ss/Mods/NeutralHumansDemo` to the Recycle Bin. Remove its custom `mods.txt` entry if you added one. Keep shared UE4SS files used by other mods.

## Known limits

- The whitelist contains 53 candidate blueprints, not a visually audited list of all normal humans. Civilian and all-chapter coverage remain incomplete.
- An ordinary soldier was reported to attack during earlier testing affected by a camera hotkey conflict. That case has not been retested with all variables controlled.
- Sight/hearing suppression also affects acquisition of other NPCs. This is not a player-only team-attitude filter.
- Any damage source reaching the callback can restore senses. The instance does not automatically return to passive after combat ends.
- Script-forced targets, alarms, special AI, zero-damage hits and abnormal variants sharing a listed blueprint need more testing.
- No original PAK, shared faction table or damage values are edited, and the mod has no save-writing code. The local minimap and photo mod were loaded alongside it; broad compatibility and long-session stability are not established.

For useful bug reports, include location, the target's appearance/weapon, whether it was hit earlier, and the relevant `NeutralHumansDemo` log lines. Avoid sharing whole saves or personal logs unnecessarily.

## License

The original project code and documentation use the MIT license, permitting commercial use, modification and redistribution subject to its notice requirements. See the repository's `LICENSE` or the archive's `LICENSE_NeutralMingSoldiers.txt`. Game and third-party dependency rights are not granted by this license.
