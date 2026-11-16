# Wuchang: Fallen Feathers — Neutral Ming Soldiers Mod

明末：渊虚之羽｜明军中立 MOD

[English](README.md) | [简体中文](README.zh-CN.md)

> [!WARNING]
> **必须安装 UE4SS for WFF，不能使用原版 UE4SS 通用发行包作为本 MOD 的前置。**
> 请下载 **[Framecore 的 UE4SS for WFF](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)**。本项目不支持用原版通用包替换 WFF 专用环境。相关构建曾被报告有加载 Fatal Error、手柄启动无响应和游戏光标异常；请保留专用包的游戏适配设置，原因详见下文。

《明末：渊虚之羽》（**Wuchang: Fallen Feathers / WFF**）的 UE4SS Lua MOD，让名单内原本敌对的明军不主动攻击白无常，受击后仍可反击。通过配置文件控制，默认开启，无快捷键。

当前版本 **0.3.0** · **MIT 许可证**

**下载：[Nexus Mods — Neutral Ming Soldiers](https://www.nexusmods.com/wuchangfallenfeathers/mods/496)**

[玩家安装教程](docs/INSTALL_zh-CN.md) · [技术报告](docs/TECHNICAL_REPORT_zh-CN.md) · [开发说明（英文）](docs/DEVELOPMENT.md) · [更新记录](CHANGELOG.md) · [GitHub 发布元数据](docs/GITHUB_METADATA.md)

项目目标是让正常明军和百姓不主动攻击白无常，受到攻击后仍能反击。当前名单包含 **53 个候选蓝图**，并非已经逐一核实的全部正常角色。

**已实测通过：** 唐王行宫的一名铠甲枪盾明军不主动攻击白无常，受到主角攻击后会反击。其他普通士兵、百姓及全章节覆盖尚未全部验证。最终配置入口已通过独立 Lua 检查，配置版的完整游戏内复测仍待完成。

## 安装与配置

**必需前置：[Framecore 的 UE4SS for WFF](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)。** 先按该作者的说明安装游戏专用包，再安装本 MOD。已有正常工作的 WFF 专用环境可继续使用；此前置需单独下载，不随本仓库分发。

### 为什么不能直接用原版 UE4SS？

作者说明，游戏 1.7 更新后，UE4SS 曾在加载时出现 Fatal Error。WFF 专用包调整了 `UE4SS-settings.ini`，补充 `Default_UVTD_Configs`，并调整 `BPModLoaderMod`。选择这个前置是为了沿用针对游戏的适配，并不等于本 Lua MOD 要求另一套独立修改的 UE4SS 核心。[作者原说明](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)。

较新的上游构建还被报告存在手柄及游戏光标初始化回归。上游已接受规避方案，但本项目尚未验证用新版通用包替换现有环境，因此安装要求仍指定 WFF 专用包。[详细依据与版本说明](docs/UE4SS_DEPENDENCY.md)。

### 安装本 MOD

将本仓库的 `NeutralHumansDemo` 文件夹放入 WFF 专用环境的 `Mods` 目录，保留其中的 `enabled.txt`。内部目录名和日志前缀继续使用 `NeutralHumansDemo`，方便现有玩家更新。

**Steam 版：** 在 Steam 库中右键游戏 → **管理 → 浏览本地文件**，打开 `Project_Plague\Binaries\Win64\`。下载本 MOD 的发布压缩包时，将包内 `ue4ss` 文件夹合并到 `Win64`；使用 Git 克隆或 GitHub 源码 ZIP 时，只把其中的 `NeutralHumansDemo` 文件夹复制到 `Win64\ue4ss\Mods\`。最终入口应位于：

```text
<Steam库>\steamapps\common\Wuchang Fallen Feathers\Project_Plague\Binaries\Win64\ue4ss\Mods\NeutralHumansDemo\Scripts\main.lua
```

**PC Game Pass / XGP 版：** 对应位置为 `Project_Plague\Binaries\WinGDK\`，MOD 内部结构相同。详见 [Steam 安装步骤](docs/INSTALL_zh-CN.md#steam) 和 [XGP 安装步骤](docs/INSTALL_zh-CN.md#xgp)。Steam 路径根据其他《明末》Lua MOD 与 UE4SS 通用目录规则整理，本项目尚未在 Steam 版中进行行为实测。

编辑 `NeutralHumansDemo/Scripts/config.lua`：

```lua
return {
    enabled = true,
}
```

`true` 为开启，`false` 为关闭，默认为开启。修改后须**完全退出并重启游戏**。本版没有快捷键。详细目录、前置要求、更新和卸载步骤见[玩家安装教程](docs/INSTALL_zh-CN.md)。

本机开发与测试环境：PC Game Pass / WinGDK，应用包版本 `1.13.2.0`，引擎 `5.1.1`，UE4SS for WFF 包版本 `1.79`，其 UE4SS 核心为 `3.0.1 Beta / cac01ee2`。专用包版本不等于核心版本。Steam 及其他构建尚未验证。

## 实现原理

1. 精确匹配 `targets.lua` 中的蓝图类名，并检查实例原本对玩家的关系。
2. 对选中的敌对实例保存视觉、听觉开关，清理已有目标，关闭正常的视觉、听觉主动索敌。
3. AI 配置重载后补回被动设置，通过初始化 hook 和周期扫描处理新实例。
4. 收到 `AfterTakeDamage` 回调后恢复原始开关，由游戏自身的战斗逻辑执行反击。

感知关闭也会影响角色发现其他 NPC。任何伤害来源都可能触发恢复，脱战后不会自动再次中立。剧情强制目标、警报及特殊 AI 仍需进一步验证。本 MOD 不修改公共阵营表、原版 PAK 或伤害数值，也没有主动写入存档的代码。

## 源码与构建

本仓库包含完整的自编 Lua 实现、配置、角色名单、说明文档、打包脚本及配置入口检查。

```text
NeutralHumansDemo/      可部署的 UE4SS MOD
docs/                  安装教程、技术报告和开发说明
tests/                 独立配置入口检查
build_release.py       手动安装压缩包的构建脚本
LICENSE                MIT 许可证
```

使用 Python 3 构建玩家安装包：

```sh
python build_release.py
```

输出为 `dist/Neutral-Ming-Soldiers-0.3.0.zip`，仅需 Python 标准库。压缩包包含 MOD、玩家说明、技术报告及 MIT 许可证。生成的压缩包已被 Git 忽略，可作为发布附件分发。

仓库不包含游戏资源、存档、原始日志、崩溃转储、提取的 SDK/usmap、研究工具二进制或其他 MOD。UE4SS for WFF 作为独立前置安装。

## 鸣谢与许可

项目方向、维护及游戏内测试：**dreamcat**。初版大部分 Lua 代码和文档由 **[OpenAI Codex](https://github.com/openai/codex)** 辅助生成。UE4SS 提供运行环境，UAssetGUI 用于本地资源分析；仓库未再分发这两个工具。

项目自编代码与文档采用 [MIT 许可证](LICENSE)，允许商业使用、修改和再分发，须保留相应版权及许可声明。本许可不授予游戏或第三方依赖的权利；独立分发页面的权限说明也应与本许可保持一致。
