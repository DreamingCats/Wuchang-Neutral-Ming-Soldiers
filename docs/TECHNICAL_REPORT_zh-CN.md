# Neutral Ming Soldiers：《明末：渊虚之羽》中立 MOD 技术报告

日期：2026-11-15　交付版本：0.3.0（配置文件版）

## 1. 结论与验证边界

已完成游戏文件分析及可部署的 UE4SS Lua 原型。原型按精确蓝图名单筛选角色，对原本敌对的实例关闭视觉、听觉主动索敌，受击后恢复原设置，交回原版战斗逻辑。

**玩家已确认唐王行宫的一名铠甲明军“不主动攻击、受到主角攻击后反击”。** 同一场景日志于 `15:36:54` 记录 `guanbing_qiangdun_C_3` 的 `retaliation`，为该实例进入受击恢复分支提供独立记录。日志不包含完整画面行为，因此“不先攻击”的结论来自玩家实测反馈，而不是仅凭日志推断。

目前不能宣称全部明军、全部百姓或全章节已经达成目标。名单来自资源名称筛选，尚缺逐模型和实例配置审计；普通士兵早期测试受快捷键冲突干扰，尚待复测。0.3.0 的配置入口完成了独立 Lua 检查，但未单独重做一次游戏内全流程验收；其角色处理及受击恢复逻辑沿用通过铠甲明军测试的实现。

## 2. 需求和交付范围

目标行为：正常明军、正常百姓不主动攻击白无常，受到攻击后允许反击；目标范围为所有章节。羽化和异常敌人不应因改动公共阵营而被一并处理。

本次交付包括：

- Lua 原型源码及 53 个候选蓝图名单。
- 仅由配置文件决定是否加载的启动入口，默认开启，无快捷键。
- 中英文玩家安装说明、更新记录、本文及 Nexus 发布文案草稿。
- 可手动安装的发布 ZIP；不附带游戏资源、存档、调试日志或第三方加载器。

“全章节”是后续验收目标，不是本次已完成的覆盖声明。

## 3. 分析与运行环境

| 项目 | 本机观测 |
| --- | --- |
| 游戏发行渠道 | PC Game Pass / WinGDK |
| 应用包清单版本 | 1.13.2.0；不等同于宣传补丁编号 |
| 引擎运行时 | Unreal Engine 5.1.1 |
| 必需前置 | UE4SS for WFF（Framecore，Nexus mod 384）；本机包版本 1.79 |
| UE4SS 核心 | 3.0.1 Beta，提交 cac01ee2；专用包版本与核心版本独立 |
| 已实测章节 | 第一章中的唐王行宫场景 |
| 同时加载的其他 MOD | 小地图、拍照/自由相机；未做完整兼容性矩阵 |
| 未验证发行环境 | Steam、其他游戏版本及其他 UE4SS 构建 |

原版 PAK 仅被读取。原型通过 UE4SS 操作当前进程中的角色与控制器，不生成覆盖 PAK，也没有主动写存档的代码。游戏本身在正常游玩、退出时仍可能保存进度，因此不能把“MOD 不写存档”理解为整个测试过程不会发生游戏自动存档。

依赖说明于 2026-11-16 更新：本项目要求安装 [UE4SS for WFF](https://www.nexusmods.com/wuchangfallenfeathers/mods/384?tab=description)。作者说明该包为游戏 1.7 后的加载异常调整了设置、工具配置和 Blueprint 加载器。上游另有输入初始化回归及已接受的规避方案，但本项目没有验证用通用新版替换当前环境；这不等于认定所有原版构建都不能工作。[依赖依据与版本区分](UE4SS_DEPENDENCY.md)。

## 4. 文件分析方法

### 4.1 取得当前生效资源

复用原研究工作区已有的 `文本提取工具/extract_texts.py`：按基础 `Project_Plague-WinGDK.pak`，再按 `_0_P` 到 `_4_P` 的顺序建立路径索引，后加载的同路径资源覆盖前者。提取当前胜出的 `.uasset` 与 `.uexp`，在本地保留原始副本及包含来源 PAK 的 `research/manifest.json`。这里提到的提取器和原始研究文件未收录到源码仓库；构建、安装本 MOD 不需要它们。

`inspect_assets.py` 将选定资源交给 UAssetGUI 导出 JSON。提取器所需的解包参数、游戏原始资源和第三方工具均未进入发布包。

### 4.2 补齐类型映射

初期使用公开 usmap 时，部分角色默认对象解析为 `RawExport`。仅补依赖资源仍不足以解决，因为公开映射缺少本游戏的原生自定义类型。

随后通过本机 UE4SS 导出 CXX 头文件及当前运行版本的 usmap，得到 `research/CurrentGame.usmap`。替换映射并补齐依赖后，持刀明兵等对象解析为 `NormalExport`，可以结合蓝图字节码、默认属性与运行时读回交叉判断。

CXX 头文件中的字段名、函数签名是分析依据，不代表可以忽略函数的游戏内部调用前提。原生阵营写入试验的异常正说明“有函数签名”不等于“任意状态下调用都安全”。

### 4.3 关键分析资源

| 资源或类型 | 作用 |
| --- | --- |
| `/Game/Game/DataTables/DT_Camp` | 游戏阵营关系；另有 DynamicCombatSystem 同名表，不能混淆资源路径 |
| `BehaviorComponent` | 原阵营 Camp、CheckRelation、GetTeamAttitudeInfo |
| `BP_BaseAI` | 实例初始化、行为组件获取、控制器引用 |
| `BP_BaseAIController` | 目标、警觉状态、感知开关及受击回调 |
| `ST_CharacterConfig` | 角色配置结构；核实 Custom1 的实际类型 |
| `mingbing`、`guanbing` 等角色目录 | 生成候选蓝图集合 |
| `AC_AITargetQuery`、`AITargetManager` | 后续定位绕过感知的目标获取路径；本版未改这些组件 |

## 5. 阵营研究结果

### 5.1 关系表和枚举

游戏阵营表读到的行包括 `100`、`250`、`20000`、`20100`、`30000`、`30100`、`30200`、`30300`、`30400`、`30500`、`30600`、`30700`。关系数组采用上三角存储，不能直接将每行第 0 项解释为“对主角关系”。

两套枚举的数值顺序不同：

| 数值 | E_CampType | 原生 ETeamAttitude |
| --- | --- | --- |
| 0 | Neutral | Friendly |
| 1 | Enemy | Neutral |
| 2 | Friend | Hostile |

`BehaviorComponent:GetTeamAttitudeInfo` 将旧阵营配置转换为原生队伍关系，`BP_BaseAI:InitGlobalTeamInfo` 再调用原生队伍更新接口。不能将枚举值直接混用。

### 5.2 为什么不全局修改 30000

运行时读到了普通持刀、持枪明军、官兵，以及狗、羽化乡勇和其他怪物使用同一个 `30000` 阵营。整体将这个阵营对玩家改为中立会扩大影响，无法满足“只处理正常明军和百姓”的范围要求。

同一个 `MingBing_Dao` 蓝图还存在不同实例配置：

| 配置 ID | Camp | 对玩家 100 的 CheckRelation 实读 |
| --- | --- | --- |
| 30313 | 30000 | -1，原本敌对 |
| 59002 | 30700 | 1，原本友好 |
| 若干尚未初始化的实例 | 空 | 0；不能据此判定其最终阵营 |

因此原型同时检查蓝图和实例关系，跳过已经友好、中立或尚未初始化的实例。

### 5.3 Custom1 不构成阵营控制证据

`ST_CharacterConfig.Custom1` 的实际类型为 `TArray<FName>`，与 RightHand、LeftHand、Foot、Head 等碰撞插槽配置并列。未发现足够证据证明它是中立开关，交付代码不依赖这个字段。

## 6. 路线选择和异常记录

| 路线 | 试验结果 | 处理 |
| --- | --- | --- |
| 修改公共阵营关系 | 30000 同时被正常人、动物和怪物使用 | 不采用 |
| 为实例创建独立原生阵营 | 调用 UpdateGlobalTeamInfo 时访问异常，读取地址 0x70 | 从交付代码移除 |
| 关闭单实例视觉/听觉，受击恢复 | 完成开关读回及铠甲明军行为案例 | 作为本次原型 |

14:38 左右使用 UE4SS `Restart All Mods` 后发生异常；日志显示既有小地图 DLL 也被重新初始化。时间关系不足以确定唯一原因，后续改用完整退出、重启。

14:51 左右向 `UpdateGlobalTeamInfo` 传入独立阵营名和 Lua 关系表后发生访问异常。最后日志位于创建 `NeutralHumansDemo_30000` 的阶段，没有成功写入或行为生效的证据。可能涉及调用前提、休眠对象状态或参数编组，但尚未确定原因；不应在报告中把其中任一猜测写成定论。

上述失败调用没有留在发布代码中。相关本地证据为 `research/native_team_experiment_UE4SS.log` 和 `research/native_team_experiment_CrashContext.xml`。

## 7. 0.3.0 实现说明

### 7.1 配置入口

`Scripts/config.lua` 返回配置表，默认 `enabled = true`。`Scripts/main.lua` 在启动时读取它：只有布尔值 `true` 才加载并安装 runtime；`false` 时写入停用日志后返回。关闭状态不注册本 MOD 的 hook、BeginPlay 监听或周期扫描。

配置仅在启动时读取。运行中改文件不会即时恢复角色，必须完全退出、重启游戏。没有运行中开关、热重载、F8/F5 或 Ctrl+Alt 绑定；也移除了中间版的屏幕提示函数。

选择 Lua 配置而非新增 INI 解析器，是为了沿用 UE4SS 已使用的脚本加载路径，并保持仅一个布尔选项的最小实现。配置文件是可执行 Lua，应按 README 保留其结构。

### 7.2 实例筛选

对 `FindAllOf("BP_BaseAI_C")` 返回对象逐个检查：

1. 对象有效，完整路径包含 `:PersistentLevel.`，排除默认对象等非关卡实例。
2. `GetClass():GetFullName():lower()` 精确命中 `targets.lua`。
3. 通过 `GetMyBehavior(out)` 取得 `out.BehaviorComp`。AI 不直接继承玩家的 `BehaviorComponent` 字段，不能照搬玩家读取方式。
4. 原 Camp 非空，玩家对象有效，读取玩家当前 Camp，并用 `CheckRelation(playerCamp, out).Result` 判断是否为 `-1`。
5. `actor.BaseAIController` 有效，才开始记录和修改。

记录键由对象地址和完整实例名组成。保存原始 `DisableSight`、`DisableHearing` 及本实例是否已经进入反击状态。

### 7.3 被动状态

对首次选中的原本敌对实例执行：

```text
保存原视觉/听觉禁用值
ClearAllTargets()
SetIsInCombat(false)
DisableSight = true
DisableHearing = true
ChangeAlertStatu(当前 AlertStatu, true)
```

没有关闭伤害感知。虽然阵营仍保持敌对，选中的实例暂时不经正常视觉、听觉主动发现目标。它是感知控制原型，不是完整的玩家专属阵营中立系统。

### 7.4 修复原版配置重置

早期原型调用 `FlushEnableSense` 后，后续读回发现原版配置会把开关重新置回 `false`。因此单独出现 `passive` 日志不能作为生效证据。

最终使用 `ChangeAlertStatu(当前状态, true)` 刷新感知，同时在 `LoadGlobalConfig` 后重新检查受管理实例。每秒扫描也会在尚未反击的实例上补回被重置的开关。没有反复调用 `FlushEnableSense`。

### 7.5 受击恢复

为 `BP_BaseAIController_C:AfterTakeDamage` 注册回调。通过控制器 `PossesedAI`（原字段拼写）找到实例记录：

1. 先标记 `retaliating = true`。
2. 恢复记录的原始视觉、听觉禁用值。
3. 调用相同的警觉刷新函数。
4. 写入 `retaliation` 日志，由原版受击仇恨、行为树等逻辑继续处理。

先设置标记可避免恢复过程中触发配置重载时，又被被动分支立即盖回。MOD 自身没有强制选择攻击对象，也没有修改伤害值。此回调不限定主角伤害，其他来源触发时也可能恢复。

### 7.6 生命周期和执行线程

在类型可用时注册受击、`InitGlobalTeamInfo`、`LoadGlobalConfig` hook；关卡角色 BeginPlay 后再次尝试安装和处理。约每 1000 ms 调度一次扫描，UObject 读写通过 `ExecuteInGameThread` 执行。初始化尚未完成的实例由后续扫描补处理。

周期遍历和记录有运行开销；未做性能基准或长时间跨章节内存分析。退出进程会丢弃这些 Lua 记录。受击实例在本次运行中不会因脱战自动回到被动状态。

## 8. 候选范围

当前 `targets.lua` 有 53 个精确类名，主要来源于 `mingbing`、`guanbing`、第三章 `M_MB` 和第四章 `M_MB/E_GB` 目录，包含持刀、持枪、盾牌、火把、火油弹等变体。

这种筛选能避免按“公共阵营”整批修改，但它仍是候选集合：

- 未逐一确认每个模型和角色配置是否属于正常人。
- 没有找到已证明覆盖全章节百姓的单一类名；不能把目录名自动当作百姓身份。
- 同蓝图在不同关卡、剧情或换皮状态下可能含有应排除的异常变体。
- 新增蓝图需要加入精确完整类路径，并单独验证其默认配置和实际行为。

完整名单见本文附录，也可直接查看发布脚本 `targets.lua`。

## 9. 验证记录

| 检查 | 结果及证据 | 可得出的结论 |
| --- | --- | --- |
| 第一章运行时筛选 | 49 个候选关卡实例，初次最终版启用处理 24 个已初始化敌对实例 | 当前载入对象可被筛选；不代表 49 个都是存活且完整初始化 |
| 开启后的读回 | 15:13:13 开启，15:14:12 读回 24 个实例均为 true/true | 当前场景开关写入并维持了约一分钟 |
| 开发版关闭恢复 | 15:14:23 关闭，15:14:36 读回同批 24 个实例为 false/false | 记录的原值可恢复；0.3.0 改用退出重启停用 |
| 早期普通士兵测试 | 玩家报告仍主动攻击，随后确认 F8 与自由相机冲突；日志有关闭记录 | 状态变量受干扰，未完成可归因复测；不得写成普通士兵通过 |
| 中间版再次开启 | 15:35:46 开启，15:35:47 记录 49 个候选、23 个已处理实例 | 当次状态已开启；数量变化不证明覆盖范围变化 |
| 唐王行宫铠甲明军 | 玩家明确报告不先攻击、受主角攻击后反击；15:36:54 日志记录 guanbing_qiangdun_C_3 的 retaliation | 此具体案例通过 |
| 0.3.0 配置和语法 | Fengari / Lua 5.3 独立加载四个 Lua 文件；true 调用 runtime.install，false 跳过 runtime | 配置入口与语法检查通过；不是 UE4SS 宿主内的完整验收 |
| 百姓、全章节、羽化敌人对照 | 未全部执行 | 尚无完整覆盖结论 |

本地日志证据：`research/final_demo_UE4SS.log`、`research/key_conflict_v01_UE4SS.log`、`research/armored_ming_user_pass_UE4SS.log`。最后一份同时保留了中间版开启、处理及受击恢复日志。日志中后续也出现了其他 MOD 的 watchdog 停顿记录，现有证据不足以归因；不能据此宣称长期稳定性已通过。

本次独立入口检查由 `tests/verify_release.lua` 执行。它只验证配置边界和 Lua 文件可解析，未用模拟对象假装验证真实 AI 的战斗行为。

## 10. 已知限制与后续验收

1. 感知控制不是只针对白无常的过滤：也会影响该角色主动发现其他 NPC。
2. 直接写入/脚本强制选择的目标、警报联动、特殊 AI 等可能绕过普通视觉听觉入口；需逐类定位。
3. 任意有效受击回调都可恢复索敌；零伤害、格挡或其他特殊受击路径尚未全测。
4. 不实现脱战后自动再次中立，也没有全部章节的角色配置白名单。
5. 角色刚初始化到扫描处理之间可能有短暂窗口，尚未做严格的首次索敌时序测试。
6. 只有本机 WinGDK 环境的开发版行为案例，其他商店、版本及最终配置启动路径需进一步宿主实测。

后续优先顺序：先在配置版复测已通过的枪盾官兵；再复测先前普通士兵；补充百姓实例和羽化敌人对照；建立每章角色/配置验收表。若继续开发严格中立正式版，再研究目标选择入口的玩家专属过滤，或在明确前置条件后评估原生阵营方法。当前不应盲目重新尝试失败的原生写入。

## 11. 发布结构与第三方内容边界

发布包采用 `ue4ss/Mods/NeutralHumansDemo` 结构，入口通过随包 `enabled.txt` 被本机现有 UE4SS 加载，实际行为由配置决定。GitHub 项目的对外名称为 Neutral Ming Soldiers，沿用内部目录名以方便现有用户更新。包内包含四个 Lua 文件、该标记文件及中英文说明、更新记录、技术报告和 MIT 许可证。

发布包不含本地存档、用户标识、完整日志、崩溃 XML、游戏 `.uasset/.uexp`、usmap、导出的 SDK、UE4SS DLL、小地图或拍照 MOD、UAssetGUI、npm 工具缓存。保留这些材料用于本地研究，不将它们与自编 Lua 代码一起再分发。

源码仓库中的自编代码与文档已按维护者选择采用 MIT 许可，版权署名为其 Git 名称 dreamcat。MIT 不授予游戏或第三方依赖的权利。此前独立发布页面若含有禁止商业使用或搬运等限制，维护者应同步其说明，避免和本仓库的 MIT 授权冲突；整理本地仓库本身不会修改线上页面。

## 12. 复现与维护

最小使用复现：按玩家 README 和前置作者说明安装 UE4SS for WFF 及本包，配置 `enabled = true`，重启，载入唐王行宫，寻找未受击的正常枪盾官兵，先接近观察，再攻击一次；检查 `passive` 与 `retaliation` 日志。另起游戏进程使用 `enabled = false`，确认停用日志及原版行为。

源码修改后仍采用完整重启。开发者可在游戏线程调用 `require("runtime").inspect()` 取得名单内实例的 ID、Camp、对 100 的关系及开关读回；该诊断函数未绑定玩家按键，不是运行时配置开关。

使用工作区 `build_release.py` 按固定文件清单构建 ZIP；构建脚本同时检查包内必需文件及不应出现的按键代码。无需重打 PAK，也无需为了玩家使用而安装研究工具。

## 13. 资料来源

- [UE4SS：Lua MOD 入口与目录](https://docs.ue4ss.com/guides/creating-a-lua-mod.html)
- [UE4SS：安装与工作目录](https://docs.ue4ss.com/installation-guide.html)
- [UE4SS：RegisterHook](https://docs.ue4ss.com/lua-api/global-functions/registerhook.html)
- [本机 UE4SS 提交对应源码](https://github.com/UE4SS-RE/RE-UE4SS/tree/cac01ee2)
- [UAssetGUI](https://github.com/atenfyr/UAssetGUI)
- [Wuchang Modding Guide](https://github.com/AyakaMods/Wuchang-Fallen-Feathers-Modding-Guide)

游戏内部结论来自本机资源解析、导出接口及运行时读回；上述工具文档不应被引用为“全部明军和百姓已通过”的证明。

## 附录：0.3.0 候选蓝图清单

以下路径省略共同前缀 `BlueprintGeneratedClass /Game/`，大小写规范为运行时匹配所用的小写。此表从发布用 `targets.lua` 生成。

<!-- GENERATED_TARGETS -->

| 序号 | 类路径 |
| --- | --- |
| 1 | `game/ai/chapter_3/m_mb/mingbing_changqian_chapter_03.mingbing_changqian_chapter_03_c` |
| 2 | `game/ai/chapter_3/m_mb/mingbing_changqiang_kuijia_chapter_03.mingbing_changqiang_kuijia_chapter_03_c` |
| 3 | `game/ai/chapter_3/m_mb/mingbing_dao_chapter_03.mingbing_dao_chapter_03_c` |
| 4 | `game/ai/chapter_3/m_mb/mingbing_dao_kuijia_chapter_03.mingbing_dao_kuijia_chapter_03_c` |
| 5 | `game/ai/chapter_3/m_mb/mingbing_huoba_dao_chapter_03.mingbing_huoba_dao_chapter_03_c` |
| 6 | `game/ai/chapter_3/m_mb/mingbing_huoba_dao_kuijia_chapter_03.mingbing_huoba_dao_kuijia_chapter_03_c` |
| 7 | `game/ai/chapter_3/m_mb/mingbing_jiandun_chapter_03.mingbing_jiandun_chapter_03_c` |
| 8 | `game/ai/chapter_3/m_mb/mingbing_jiandun_kuijia_chapter_03.mingbing_jiandun_kuijia_chapter_03_c` |
| 9 | `game/ai/chapter_3/m_mb/mingbing_podao_high_chapter_03.mingbing_podao_high_chapter_03_c` |
| 10 | `game/ai/chapter_3/m_mb/mingbing_podao_kuijia_chapter_03.mingbing_podao_kuijia_chapter_03_c` |
| 11 | `game/ai/chapter_4/e_gb/guanbing_qiangdun_chapter_4.guanbing_qiangdun_chapter_4_c` |
| 12 | `game/ai/chapter_4/e_gb/guanbing_shuangji_2_chapter_4.guanbing_shuangji_2_chapter_4_c` |
| 13 | `game/ai/chapter_4/e_gb/guanbing_yanyuedao_chapter_4.guanbing_yanyuedao_chapter_4_c` |
| 14 | `game/ai/chapter_4/e_gb/guanbing_yanyuedao_high_chapter_4.guanbing_yanyuedao_high_chapter_4_c` |
| 15 | `game/ai/chapter_4/m_mb/level_4_dao/mingbing_dao_chapter_4.mingbing_dao_chapter_4_c` |
| 16 | `game/ai/chapter_4/m_mb/level_4_dao/mingbing_dao_high_chapter_4.mingbing_dao_high_chapter_4_c` |
| 17 | `game/ai/chapter_4/m_mb/mingbing_changqian_chapter_4.mingbing_changqian_chapter_4_c` |
| 18 | `game/ai/chapter_4/m_mb/mingbing_changqian_high_chapter_4.mingbing_changqian_high_chapter_4_c` |
| 19 | `game/ai/chapter_4/m_mb/mingbing_dao_high_chapter_4.mingbing_dao_high_chapter_4_c` |
| 20 | `game/ai/chapter_4/m_mb/mingbing_huoba_changqiang_chapter_4.mingbing_huoba_changqiang_chapter_4_c` |
| 21 | `game/ai/chapter_4/m_mb/mingbing_huoba_dao_chapter_4.mingbing_huoba_dao_chapter_4_c` |
| 22 | `game/ai/chapter_4/m_mb/mingbing_huochong_child.mingbing_huochong_child_c` |
| 23 | `game/ai/chapter_4/m_mb/mingbing_podao_high_chapter_4.mingbing_podao_high_chapter_4_c` |
| 24 | `game/ai/chapter_4/m_mb/level_4_jiandun/mingbing_jiandun_chapter_4.mingbing_jiandun_chapter_4_c` |
| 25 | `game/ai/chapter_4/m_mb/level_4_jiandun/mingbing_jiandun_high_chapter_4.mingbing_jiandun_high_chapter_4_c` |
| 26 | `game/ai/guanbing/guanbing_huochong.guanbing_huochong_c` |
| 27 | `game/ai/guanbing/guanbing_qiangdun.guanbing_qiangdun_c` |
| 28 | `game/ai/guanbing/guanbing_qiangdun_high_.guanbing_qiangdun_high__c` |
| 29 | `game/ai/guanbing/guanbing_qiangdun_special.guanbing_qiangdun_special_c` |
| 30 | `game/ai/guanbing/guanbing_shuangji_2.guanbing_shuangji_2_c` |
| 31 | `game/ai/guanbing/guanbing_shuangji_high.guanbing_shuangji_high_c` |
| 32 | `game/ai/guanbing/guanbing_yanyuedao.guanbing_yanyuedao_c` |
| 33 | `game/ai/guanbing/guanbing_yanyuedao_high.guanbing_yanyuedao_high_c` |
| 34 | `game/ai/mingbing/mingbing_changqian.mingbing_changqian_c` |
| 35 | `game/ai/mingbing/mingbing_changqian_child.mingbing_changqian_child_c` |
| 36 | `game/ai/mingbing/mingbing_changqian_high.mingbing_changqian_high_c` |
| 37 | `game/ai/mingbing/mingbing_dao.mingbing_dao_c` |
| 38 | `game/ai/mingbing/mingbing_dao_high.mingbing_dao_high_c` |
| 39 | `game/ai/mingbing/mingbing_huoba.mingbing_huoba_c` |
| 40 | `game/ai/mingbing/mingbing_huoba_changqiang.mingbing_huoba_changqiang_c` |
| 41 | `game/ai/mingbing/mingbing_huochong.mingbing_huochong_c` |
| 42 | `game/ai/mingbing/mingbing_huoyoudan.mingbing_huoyoudan_c` |
| 43 | `game/ai/mingbing/mingbing_jiandun.mingbing_jiandun_c` |
| 44 | `game/ai/mingbing/mingbing_jiandun_high.mingbing_jiandun_high_c` |
| 45 | `game/ai/mingbing/mingbing_npc.mingbing_npc_c` |
| 46 | `game/ai/mingbing/mingbing_nu.mingbing_nu_c` |
| 47 | `game/ai/mingbing/mingbing_nu_01.mingbing_nu_01_c` |
| 48 | `game/ai/mingbing/mingbing_podao_high.mingbing_podao_high_c` |
| 49 | `game/ai/mingbing/mingbing_podao_high1.mingbing_podao_high1_c` |
| 50 | `game/ai/mingbing/mingbing_podao_high_child.mingbing_podao_high_child_c` |
| 51 | `game/ai/mingbing/mingbing_weak01.mingbing_weak01_c` |
| 52 | `game/ai/mingbing/mingbing_weak02.mingbing_weak02_c` |
| 53 | `game/ai/mingbing/mingbing_weak03.mingbing_weak03_c` |
