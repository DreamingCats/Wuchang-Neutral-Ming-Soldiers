# 更新记录 / Changelog

## Dependency documentation — 2026-11-16

- 中英文 README、安装教程和发布元数据将前置明确为 Framecore 的 UE4SS for WFF（Nexus mod 384）。
- 按改版作者说明解释游戏适配原因，并区分上游输入回归、已接受的规避方案与本项目尚未验证的替换方案。
- 补充独立依赖说明及来源链接，安装包同步附带；不修改 MOD Lua 或游戏内已安装的加载器。

## Source repository — 2026-11-15

- 对外名称统一为 Neutral Ming Soldiers，保留内部 NeutralHumansDemo 标识。
- 整理完整自编 Lua、配置、名单、文档、入口检查和构建脚本，采用 MIT 许可。
- 构建产物移至 dist，附带 MIT 许可；本次仓库整理不改变 0.3.0 游戏行为代码。

## 0.3.0 — 2026-11-15

- 改为 `Scripts/config.lua` 的 `enabled` 配置，默认开启，修改后重启生效。
- 删除所有快捷键和未完成验证的按键屏幕提示；配置关闭时不加载 runtime、不注册 hook 或轮询。
- 保留已测试的角色筛选、感知控制、受击恢复逻辑和 53 个候选蓝图。
- 补充唐王行宫铠甲枪盾明军的玩家实测通过结果及对应受击回调日志。
- 增加中英文安装说明、完整技术报告及 Nexus 页面文案草稿。

## 0.2 — 开发中间版 / development build

- F8 与自由相机冲突后，曾改为 Ctrl+Alt+N 开启、Ctrl+Alt+M 关闭。
- 该中间版的日志记录了唐王行宫枪盾官兵的 `retaliation`。

## 0.1 — 开发原型 / development prototype

- 采用 F8/F5 调试感知设置与读回。
- 修复原版配置重置开关的问题，改用 `ChangeAlertStatu` 并处理 `LoadGlobalConfig`。
- 弃用导致异常的原生阵营写入试验，取消运行中热重载。
