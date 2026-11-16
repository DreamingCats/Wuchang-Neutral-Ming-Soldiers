# GitHub 发布元数据

下列内容用于创建 GitHub 仓库和填写 About。这个文件本身不会设置线上仓库属性；当前本地仓库尚未关联远程仓库。

## Repository name

```text
wuchang-neutral-ming-soldiers
```

## Description

```text
UE4SS Lua mod for Wuchang: Fallen Feathers. Selected Ming soldiers remain passive until attacked and can retaliate. Requires UE4SS for WFF. 明末：渊虚之羽｜明军中立 MOD。
```

## Website

[Neutral Ming Soldiers — Nexus Mods](https://www.nexusmods.com/wuchangfallenfeathers/mods/496)

## Topics

```text
wuchang
wuchang-fallen-feathers
wff
ue4ss
lua
game-mod
gameplay-mod
```

## Required dependency

[UE4SS for WFF — Framecore / Nexus mod 384](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)

发布说明使用此游戏专用包作为前置入口，不用原版 GitHub releases 链接代替。原因及上游修复状态见 [UE4SS 依赖说明](UE4SS_DEPENDENCY.md)。本文件不会自动修改 Nexus 或 GitHub 的线上依赖字段。

## README 的语言与检索

- 默认仓库首页入口为根目录的 `README.md`，英文正文带中文游戏名和中文简介。
- 完整中文版为根目录的 `README.zh-CN.md`，两者互相链接。
- GitHub 默认仓库搜索匹配名称、Description 和 Topics。加入 `in:readme` 可检索 README 内容。
- 官方说明没有明确承诺每个翻译 README 都会被同等收录到仓库 README 搜索，因此将中英文游戏名和核心功能同时放在主 README 中，避免只依赖翻译文件。
- 这不是搜索排名承诺。发布后可用 `wuchang ue4ss`、`wuchang neutral` 或 `"明军" in:readme` 检查实际结果。

依据：[GitHub 仓库搜索说明](https://docs.github.com/en/search-github/searching-on-github/searching-for-repositories)、[GitHub README 说明](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)。
