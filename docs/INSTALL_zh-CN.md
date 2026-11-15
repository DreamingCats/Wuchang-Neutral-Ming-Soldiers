# Neutral Ming Soldiers / 明军中立

版本：0.3.0（配置文件版）｜游戏：《明末：渊虚之羽》｜类型：UE4SS Lua MOD

让名单内原本敌对的明军角色停止视觉、听觉主动索敌，受击后恢复原版战斗行为。**已由玩家实测：唐王行宫的一名铠甲枪盾明军不主动攻击白无常，受到主角攻击后会反击。**

这是试验版。普通士兵、百姓和其他章节尚未全部验证，请先阅读文末的范围限制。

## 1. 安装前准备

- 需要已能在你的游戏版本中正常工作的 **UE4SS**。本包只包含本 MOD 的 Lua 脚本，不包含 UE4SS、代理 DLL 或其他 MOD。
- 本机验证环境：PC Game Pass / WinGDK，应用包版本 `1.13.2.0`，引擎运行时 `5.1.1`，UE4SS `3.0.1 Beta / cac01ee2`。这里的包版本不等同于游戏宣传补丁编号。
- Steam、其他游戏版本和其他 UE4SS 构建未完成实测。已有可用 UE4SS 的玩家无需为了安装本包替换它。
- 首次安装 UE4SS 时，请按其作者的安装说明配置与本游戏兼容的版本：[UE4SS 官方安装文档](https://docs.ue4ss.com/installation-guide.html)、[官方下载](https://github.com/UE4SS-RE/RE-UE4SS/releases)。通用安装文档本身不保证任意构建都兼容《明末》。
- 完全退出游戏后安装。建议按平时习惯备份自己的存档。

## 2. 手动安装

1. 找到游戏实际运行的 Shipping EXE 所在目录。不要选最外层启动器目录，也不要放进 `Content/Paks/~mods`。
2. 本机 XGP 的目录是：

   ```text
   C:\XboxGames\Wuchang PCGP\Content\Project_Plague\Binaries\WinGDK\
   ```

   其他安装位置以你的实际 EXE、UE4SS 所在位置为准。
3. 对于已经使用 `ue4ss/Mods` 结构的安装，将发布压缩包中的 `ue4ss` 文件夹合并到上述 EXE 目录。也可以只把包内的 `NeutralHumansDemo` 文件夹复制到你现有的 UE4SS `Mods` 文件夹。
4. 最终应看到以下结构，避免多套一层文件夹：

   ```text
   <游戏实际 EXE 目录>/
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

5. 保留 `enabled.txt`，它用于让 UE4SS 加载本 MOD 的入口。本机通过该文件加载，无需改动其他 MOD。若你自己在 `mods.txt` 中显式禁用了 `NeutralHumansDemo`，请按现有加载方式改为启用；不要覆盖整个 `mods.txt`。
6. 启动游戏、载入存档即可，**默认开启，不需要按键**。新载入的符合条件实例由初始化 hook 和约每秒一次的扫描处理，刚载入时可等一两秒再接近。

本包提供手动安装结构，未制作或验证 Vortex/FOMOD 自动安装规则。

## 3. 通过配置开启或关闭

用记事本打开：

```text
ue4ss/Mods/NeutralHumansDemo/Scripts/config.lua
```

默认内容的有效配置如下：

```lua
return {
    enabled = true,
}
```

- `enabled = true`：开启。
- `enabled = false`：关闭。
- 使用小写 `true` / `false`，不要加引号。保留 `return`、花括号和逗号；保存为 UTF-8 的 `.lua` 文件，不要变成 `config.lua.txt`。
- **修改后完全退出并重启游戏。** 当前版本只在启动时读取配置，不会在游戏运行中自动重读。

0.3.0 没有注册任何快捷键。F8、F5 和早期版的 Ctrl+Alt 组合键均不再控制本 MOD。自由相机或小地图自身的按键功能由它们各自决定。

关闭配置后，下次启动只记录一条停用日志，不安装本 MOD 的 hook、扫描或感知修改。原型的修改保存在本次游戏进程内，没有主动写入存档的代码；重新启动会重新建立原版角色状态。

## 4. 更新与卸载

**更新：** 退出游戏，先保留你自己的 `Scripts/config.lua` 设置，再将新版同名文件覆盖到同一个 `NeutralHumansDemo` 目录。本包自带配置默认为 `true`，覆盖配置会重新开启。重启后旧版本注册的按键不会保留在新进程中。

**暂时停用：** 将配置改成 `false`，然后重启游戏。

**卸载：** 完全退出游戏，将 `ue4ss/Mods/NeutralHumansDemo` 文件夹移至回收站。如果你手动在 `mods.txt` 添加过本 MOD 的条目，一并移除该条目。其他 MOD 仍在使用 UE4SS 时，请保留共享的 UE4SS 和加载器。

请使用完整退出、重启的方式更新。调试期间本机使用 UE4SS 的 `Restart All Mods` 发生过崩溃，特别是该操作还会重载现有的小地图 DLL。

## 5. 如何确认生效

在 UE4SS 的 `UE4SS.log` 中搜索 `NeutralHumansDemo`。本机日志位于 `ue4ss/UE4SS.log`，其他 UE4SS 布局以实际工作目录为准。

开启时应出现：

```text
[NeutralHumansDemo] ready v0.3.0: enabled=true from Scripts/config.lua; no hotkeys
```

关闭时应出现：

```text
[NeutralHumansDemo] v0.3.0 disabled by Scripts/config.lua; no hooks or polling installed
```

`passive <角色路径>` 表示已对该实例应用感知设置；`retaliation <角色路径>` 表示已收到该实例的受击回调并恢复原设置。这些日志有助于定位问题，不能代替实际行为观察。

建议在新加载、尚未交战的场景中测试：先接近目标并等待，再主动攻击一次，观察是否反击。曾经受击的同一个实例在本次运行中会保持原版索敌；不要用它验证“重新中立”。

## 6. 范围、限制和兼容性

- 当前名单有 **53 个精确匹配的候选蓝图**，覆盖若干明军、官兵及章节变体；它不是已经逐个核实的“全部正常人”名单。
- **已通过的是唐王行宫铠甲枪盾明军案例。** 普通士兵曾被报告仍主动攻击，当时存在旧版快捷键和自由相机冲突，尚未完成排除变量后的复测；不能据此宣称所有普通明军已通过。
- **百姓、全章节、全部羽化敌人对照测试尚未完成。** 明确位于羽化怪物专用目录的类没有列入名单；共享蓝图的异常变体仍可能需要进一步排除。
- 实现方式是暂时关闭选中角色的视觉、听觉主动索敌，因此也会影响其发现其他 NPC；尚未做到只对白无常过滤。
- 受击回调不区分伤害来源。被其他角色打到也可能恢复该实例的索敌；脱战后不会自动再次中立。
- 剧情强制目标、警报联动、特殊 AI、零伤害攻击等路径尚未全部验证。不是无敌、免伤或停止全部 AI 的 MOD。
- 不修改公共阵营表、原版 PAK 或伤害数值，不主动改写存档。本机曾与小地图及拍照 MOD 同时加载，但未完成所有组合和长时间稳定性测试。
- 其他改动 AI、感知、仇恨、同一批角色蓝图的 MOD 可能产生行为冲突；移除快捷键不能消除这类逻辑冲突。

## 7. 常见问题

**没有任何本 MOD 的日志：** 检查是否安装了可工作的 UE4SS，文件夹是否多套了一层，`enabled.txt` 是否存在，以及现有加载列表是否禁用了本 MOD。

**日志显示开启，但敌人仍主动攻击：** 先确认是正常明军或百姓、是新加载且没有受过攻击的实例，再检查有无该角色的 `passive` 日志。名单遗漏、特殊目标来源或其他 MOD 都需要进一步定位。反馈时提供章节/地点、武器和外观、何时受击，以及筛选后的 `NeutralHumansDemo` 日志行即可。

**改成 false 后仍有影响：** 完全退出游戏并重启；切回标题界面不等于重启进程。

**仍然看到旧的 F8/Ctrl+Alt 提示：** 旧进程或旧脚本仍在运行。检查是否装了两份同名 MOD，覆盖正确目录后完整重启。

**要不要重新打包 PAK 或放入 ~mods：** 不需要，这是 UE4SS Lua MOD。

更多原理、试验记录及验证边界见发布包的 `docs/NeutralHumans_TECHNICAL_REPORT_CN.md`。

## 8. 开源与许可

本项目自编 Lua、配置、名单、文档和构建脚本采用 MIT 许可证，允许商业使用、修改和再分发，须保留相应版权及许可声明。详见仓库根目录的 `LICENSE` 或发布包的 `LICENSE_NeutralMingSoldiers.txt`。游戏及 UE4SS 等第三方内容的权利不在本许可范围内。
