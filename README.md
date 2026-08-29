# Ardot 设计专家

> ⚠️ **非官方声明**：本专家由社区个人维护（作者 Sinclair），与 Ardot 官方无任何隶属或合作关系。Ardot 是其各自权利人的商标。

> 这是一个自包含的 Ardot 设计专家，技能与规则已随包完整内置，唯一外部依赖是 Ardot MCP 服务需保持连接。
> **可跨 IDE 使用**：WorkBuddy（含设计创意模式）以及 Cursor / Claude Code / Cline 等任意支持 MCP 的 IDE。
> MCP 通道名在运行时探测，不写死。

## 人设

- **名字**：Ardot 设计专家（花名 Jax）
- **定位**：UI/UX 设计专家，精通 Ardot 设计软件
- **能力**：在画布上构建像素级精准的 UI 界面，并将设计稿转化为生产可用的前端代码（React / Tailwind / Vue / HTML）

## 依赖

- **Ardot MCP 服务** —— 必须安装并连接（唯一外部依赖）
- **ardot-design-assistant-local 技能** —— 已完整内置在 `skills/ardot-design-assistant-local/`，其全部规则与指南文件（`references/`）一并随包提供

若 Ardot MCP 未连接，专家会按规范提示用户先安装并连接 Ardot MCP 服务（设计助手与规则已随专家内置，无需单独安装技能）。

## 安装

本专家需注册到 WorkBuddy 的 `marketplace.json` 后，才会出现在专家中心。仅复制文件夹不会自动生效，请二选一完成注册：

**方式 A：通过专家中心导入（推荐）**

1. 打开 WorkBuddy → 专家中心 → 导入 / 添加本地专家
2. 选择本仓库根目录（`ardot-design-expert/`）
3. 等待导入完成，专家即出现在「我的专家」中

**方式 B：手动放置 + 注册脚本**

1. 将 `ardot-design-expert/` 目录复制到：
   - macOS / Linux：`~/.workbuddy/plugins/marketplaces/my-experts/plugins/ardot-design-expert/`
   - Windows：`C:\Users\<你的用户名>\.workbuddy\plugins\marketplaces\my-experts\plugins\ardot-design-expert\`
2. 运行 WorkBuddy 内置的 `expert-manager` 注册脚本：
   `python register_expert.py <专家目录>`
   （无需传 `--session-id`；`.created-by-session` 只是本地标记，可忽略）
3. 重启 / 刷新专家中心，专家即出现

**使用前**：必须安装并连接 **Ardot MCP** 服务，否则专家会提示你先连接 MCP。

## 擅长领域

- UI/UX 设计
- 设计系统
- 用户研究
- 代码还原度评审

## 试试这样问我

- 帮我在 Ardot 上设计一个移动端 App 首页
- 把这个设计稿转成 React + Tailwind 代码
- 为我的产品搭建一套 Ardot 设计系统
- 审查这段代码对设计稿的还原度

## 目录结构

```
ardot-design-expert/
├── .codebuddy-plugin/plugin.json   # 专家元数据（含展示字段）
├── agents/ardot-design-expert.md   # 人设 / 提示词（Jax）
├── skills/ardot-design-assistant-local/  # 设计助理技能（自包含）
│   ├── SKILL.md                    # 主入口：可移植性说明 / 通道探测 / 三处纠正 / 工作流 / 硬规则
│   └── references/                 # 24 份，全部随包提供
│       ├── 【核心规则】
│       ├── design-rules.md         # 唯一事实来源：编辑原则 / 坐标 / flexbox / 组件 / 变量 / 共享样式 / 属性 schema / 排障 / ⛔ Forbidden Patterns
│       ├── style-guide.md          # 视觉风格哲学（反 AI 套路 / 方差等级 / Bento 网格 / 创意弹药库）
│       ├── style-guide-tags.md     # search_style_guide 英文关键词清单（fetch_style_guide_tags 工具不存在，读本地文件）
│       ├── effects-guide.md        # 🆕 复合效果配方：玻璃拟态 / 霓虹 / 金属 / 渐变描边 / 虹彩 / 新拟态
│       ├── ardot-schema.md         # 🆕 节点属性 schema（Node→Mixin 组合 / 属性默认值）
│       ├── 【专项能力】
│       ├── component-instance.md   # 🆕 组件 / 实例 / 变体（属性定义、实例覆盖、隐藏可选子节点）
│       ├── design-variables.md     # 🆕 变量绑定解绑 / apply_variables / variableModes 切换
│       ├── shared-styles.md        # 🆕 共享样式 textStyleId / fillStyleId
│       ├── batch-edit-tool-usage.md      # 🆕 batch_edit 完整操作手册（18K）
│       ├── apply-variables-tool-usage.md # 🆕 apply_variables 使用手册
│       ├── 【工作流】
│       ├── ardot-workflow.md       # 端到端示例（新建 / 修改 / 换肤 / 变量 / 表单）
│       ├── slides-workflow.md      # 幻灯片标准 5 阶段流程
│       ├── slides-agent-teams-workflow.md  # 幻灯片 Agent Teams 协作（须用户显式点选）
│       ├── design-to-code-workflow.md      # 设计→代码（Phase 0 平台澄清 … Phase 4 双证据终验）
│       ├── extract-style-guide-from-web.md # 从网页提取风格指南
│       ├── design-review-workflow.md       # 设计稿本身质量走查（视觉 / 交互 / 内容）
│       ├── code-review-workflow.md         # 设计↔代码双向校对（模式 A / 模式 B）
│       ├── 【类型指南】
│       └── guidelines-{landing-page,web-app,mobile-app,table,slides,code,tailwind}.md
└── README.md
```
