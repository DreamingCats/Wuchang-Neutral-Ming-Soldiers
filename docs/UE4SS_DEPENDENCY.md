# UE4SS for WFF：依赖选择与兼容性说明

核对日期：2026-11-16。此文说明本项目的依赖选择，不提供新的游戏内兼容性验收结论。

## 必需前置 / Required dependency

**[UE4SS for WFF，作者 Framecore，Nexus mod 384](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)**。

先按作者说明安装该游戏专用包，再将 `NeutralHumansDemo` 放入其 `Mods` 目录。此前置独立下载；本仓库和安装包不分发或替换 UE4SS DLL、加载器、设置文件和 Blueprint 加载器。

## 作者说明了哪些改动？

作者页面说明：游戏 1.7 更新后，UE4SS 曾在加载时触发 Fatal Error；该包调整了 `UE4SS-settings.ini`，补充 `Default_UVTD_Configs`，并调整了 `BPModLoaderMod`。这是选择游戏适配包的直接依据。[作者原文](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)。

本次另读取了版本对比对话所附的 WFF 1.79 压缩包，确认其配置包含 `HookInitGameState = 0`、`bUseUObjectArrayCache = false`、`EnableHotReloadSystem = 0`。这些也是本机已安装环境的设置；此处不指示玩家自行覆盖已有设置文件。

上游 [Issue #1177](https://github.com/UE4SS-RE/RE-UE4SS/issues/1177) 记录了 Wuchang 启动 Fatal Error，以及关闭 `HookInitGameState` 可规避特定案例的反馈。这不构成对所有崩溃的统一修复证明。`Default_UVTD_Configs` 属于开发工具配置；不能把它的存在解释为所有游戏问题都由这些文件修好。

## 为什么不直接要求原版最新版？

上游 [Issue #1499](https://github.com/UE4SS-RE/RE-UE4SS/issues/1499) 对比了不同构建：报告者在 Wuchang 中遇到启动时手柄无响应、游戏光标缺失，切出切回窗口后恢复；`cac01ee2` 构建未复现该回归，问题被定位到较新的 UEPseudo 早期 Kismet 查找路径。

维护者已确认接受规避方案，并在 UE4SS 提交 [`b2d936b`](https://github.com/UE4SS-RE/RE-UE4SS/commit/b2d936b9d8c909ca490d7aa47afdfc3f5af2b428) 中更新依赖。维护者同时说明这仍是 workaround，而非完整底层修复。因此，本文不声称“上游没有任何修复”或“所有原版 UE4SS 都不能运行”。

本项目继续指定 WFF 专用包，是为了保留已有的游戏适配和开发测试基线。**本项目尚未验证新版通用包能完整替换该环境**，也不能从输入问题的规避方案推断启动崩溃、其他 MOD 或所有章节都已兼容。

本 MOD 为 Lua 实现，未静态链接某个专用 C++ DLL 的导出，也不要求安装本身不使用的 Blueprint MOD。选择 WFF 包不等于宣称它是另一套独立核心分支。小地图等其他 MOD 可能有不同的核心构建要求，应另按各自作者说明处理。

## 版本号与测试边界

| 标识 | 含义 |
| --- | --- |
| WFF 包 `1.79` | 本机开发环境所用附件的包版本；不把页面显示版本和核心版本混为一谈 |
| UE4SS `3.0.1 Beta / cac01ee2` | 本机运行时核心版本 |
| 游戏包 `1.13.2.0` | 本机 PC Game Pass / WinGDK 应用包版本，不是 UE4SS 版本 |
| MOD `0.3.0` | 本项目版本，与上述三者独立 |

以上用于标明已知基线，不代表本项目验证了此后 WFF 页面上的所有附件版本。Steam、其他渠道和其他核心构建仍待本项目实测。依赖页面作者关于 DX11/DX12 或其他 MOD 的兼容性声明，也不自动变成本项目的实测结论。

## English summary

Install **[UE4SS for WFF by Framecore](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)** as the required dependency. Its author documents game-specific settings, tool configurations and Blueprint-loader adjustments following loading failures after game update 1.7.

The tested local baseline is WFF package 1.79 with core UE4SS 3.0.1 Beta / cac01ee2. Package and core versions are separate. Upstream has accepted a workaround for the later input regression described above, but this project has not validated replacing the WFF environment with a newer generic build. This is a dependency/support choice, not a claim that all upstream versions fail or that a separate core fork is required.

The dependency is not bundled. Follow its author's installation instructions, retain an already working WFF environment, and review other installed mods' own requirements before changing the loader.
