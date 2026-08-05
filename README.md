# Ardot 设计专家

> ⚠️ **非官方声明**：本专家由社区个人维护（作者 Sinclair），与 Ardot 官方无任何隶属或合作关系。Ardot 是其各自权利人的商标。

> 这是一个自包含的 Ardot 设计专家，技能与规则已随包完整内置，唯一外部依赖是 Ardot MCP 服务需保持连接。

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
│   ├── SKILL.md
│   └── references/                 # 设计规则 / 风格指南 / 各类型工作流
│       ├── design-rules.md         # 唯一事实来源：编辑原则 / 坐标 / flexbox / 属性 schema / 排障
│       ├── style-guide.md          # 视觉风格指南
│       ├── style-guide-tags.md     # search_style_guide 英文关键词清单（离线备份；fetch_style_guide_tags 当前版本不存在，请勿调用，直接读本地文件选关键词）
│       ├── ardot-workflow.md       # 通用生成/修改/换肤工作流
│       ├── slides-workflow.md      # 幻灯片工作流
│       ├── slides-agent-teams-workflow.md  # Agent Teams 并行幻灯片工作流
│       ├── design-to-code-workflow.md      # 设计稿转代码工作流
│       ├── design-review-workflow.md       # 设计稿本身质量走查（视觉/交互/内容三维度）
│       ├── code-review-workflow.md         # 代码→设计稿 还原度评审（5 维评分卡 + P0–P2 清单）
│       ├── extract-style-guide-from-web.md # 从网页提取风格指南
│       ├── guidelines-landing-page.md      # 落地页设计指南
│       ├── guidelines-web-app.md           # Web App 设计指南
│       ├── guidelines-mobile-app.md        # 移动端设计指南
│       ├── guidelines-slides.md            # 幻灯片设计指南
│       ├── guidelines-tailwind.md          # Tailwind 出码指南
│       ├── guidelines-table.md             # 表格设计指南
│       └── guidelines-code.md              # 设计转代码指南
└── README.md
```
