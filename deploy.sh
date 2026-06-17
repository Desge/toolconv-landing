#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# toolconv.com 一键部署脚本
# 纯 HTML 静态站 → Vercel 生产环境 + GitHub 推送
# ============================================================

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="toolconv-landing"
DOMAIN="toolconv.com"
GITHUB_REPO="Desge/toolconv-landing"

cd "$PROJECT_DIR"

echo "=========================================="
echo "  toolconv.com 一键部署"
echo "=========================================="

# ---------- 1. 前置检查 ----------
echo ""
echo "[1/5] 前置检查..."

# 检查 Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI 未安装，正在安装..."
    npm install -g vercel
fi
echo "  ✅ Vercel CLI: $(vercel --version 2>&1 | head -1)"

# 检查 Git
if ! command -v git &> /dev/null; then
    echo "❌ Git 未安装，请先安装 Git"
    exit 1
fi
echo "  ✅ Git: $(git --version)"

# 检查是否有未提交的更改
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "  ⚠️  检测到未提交的更改"
    read -p "  是否先提交? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        COMMIT_MSG="${1:-deploy: update $(date '+%Y-%m-%d %H:%M')}"
        git add -A
        git commit -m "$COMMIT_MSG"
        echo "  ✅ 已提交: $COMMIT_MSG"
    fi
fi

# ---------- 2. 本地验证 ----------
echo ""
echo "[2/5] 本地文件检查..."

REQUIRED_FILES=(
    "index.html"
    "public/404.html"
    "public/about.html"
    "public/privacy.html"
    "public/terms.html"
    "public/contact.html"
    "public/robots.txt"
    "public/sitemap.xml"
    "public/ads.txt"
    "vercel.json"
)

ALL_OK=true
for f in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "  ✅ $f"
    else
        echo "  ❌ $f 缺失!"
        ALL_OK=false
    fi
done

if [[ "$ALL_OK" == false ]]; then
    echo "❌ 必要文件缺失，部署中止"
    exit 1
fi

HTML_COUNT=$(find . -name "*.html" -not -path "./.git/*" -not -path "./.vercel/*" | wc -l | tr -d ' ')
echo "  📄 HTML 文件数: $HTML_COUNT"

# ---------- 3. 部署到 Vercel ----------
echo ""
echo "[3/5] 部署到 Vercel 生产环境..."

vercel --prod --yes --archive=tgz

echo "  ✅ Vercel 部署完成"

# ---------- 4. 推送到 GitHub ----------
echo ""
echo "[4/5] 推送到 GitHub ($GITHUB_REPO)..."

CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

# 检查是否需要代理（参考 FlashPic 项目的代理配置）
if git push origin "$CURRENT_BRANCH" 2>&1; then
    echo "  ✅ GitHub 推送成功"
else
    echo "  ⚠️  直连推送失败，尝试代理..."
    GIT_SSH_COMMAND="ssh -o ProxyCommand='nc -X 5 -x 127.0.0.1:7890 %h %p'" git push origin "$CURRENT_BRANCH"
    echo "  ✅ 通过代理推送成功"
fi

# ---------- 5. 部署验证 ----------
echo ""
echo "[5/5] 部署验证..."

sleep 5  # 等待 Vercel DNS 生效

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" == "200" ]]; then
    echo "  ✅ https://$DOMAIN 返回 200 OK"
else
    echo "  ⚠️  https://$DOMAIN 返回 HTTP $HTTP_CODE（可能需要等待 CDN 缓存刷新）"
fi

HTTP_CODE_404=$(curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN/nonexistent-page-test" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE_404" == "404" ]]; then
    echo "  ✅ 404 页面正常"
else
    echo "  ⚠️  404 页面返回 HTTP $HTTP_CODE_404"
fi

echo ""
echo "=========================================="
echo "  🎉 部署完成!"
echo "  🌐 https://$DOMAIN"
echo "  📊 https://vercel.com/dashboard"
echo "=========================================="
