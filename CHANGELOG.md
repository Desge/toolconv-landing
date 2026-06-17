# Toolconv Landing 迭代记录

## 2026-06-16 新增 Audio Tools 导航入口

### 变更内容
1. **导航栏** — 新增 `nav.audio` 链接指向 https://audio.toolconv.com
2. **工具卡片** — 新增 Audio Tools 卡片（🎵 emoji），grid 布局从 `sm:grid-cols-3` 改为 `sm:grid-cols-2 lg:grid-cols-4` 以适配4列
3. **Schema 结构化数据** — BreadcrumbList 添加 position 5 Audio Tools；Organization 和 WebSite description 加入 "audio tools"
4. **Meta 标签** — description、og:description、twitter:description、keywords 均加入 audio tools
5. **i18n 翻译** — 8种语言(en/zh/ja/ko/es/fr/de/pt)均添加 `nav.audio`、`cards.audio.title`、`cards.audio.desc`、`cards.audio.link` 四个翻译 key
6. **Sitemap** — 新增 `https://audio.toolconv.com/sitemap.xml` 子站索引

### 涉及文件
- `index.html` — 主页面
- `public/sitemap.xml` — 站点地图索引

## 2026-06-17 新增一键部署脚本

### 变更内容
1. **deploy.sh** — 一键部署脚本，包含 5 个阶段：前置检查、本地文件验证、Vercel 生产部署、GitHub 推送（含代理回退）、部署后验证
2. 支持 Vercel CLI 自动安装、未提交更改提示提交、必要文件完整性检查、代理推送回退
