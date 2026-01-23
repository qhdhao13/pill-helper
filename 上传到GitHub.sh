#!/bin/bash

# GitHub仓库上传脚本
# 使用方法：在GitHub上创建仓库后，运行此脚本

echo "=========================================="
echo "Pill Helper - GitHub上传脚本"
echo "=========================================="
echo ""

# 检查是否已添加远程仓库
if git remote | grep -q "origin"; then
    echo "⚠️  远程仓库已存在，正在更新..."
    git remote set-url origin https://github.com/qhdhao13/pill-helper.git
else
    echo "✅ 添加远程仓库..."
    git remote add origin https://github.com/qhdhao13/pill-helper.git
fi

echo ""
echo "📤 正在推送代码到GitHub..."
echo ""

# 推送代码
git push -u origin main

# 检查推送结果
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 上传成功！"
    echo "=========================================="
    echo ""
    echo "🌐 访问您的仓库："
    echo "   https://github.com/qhdhao13/pill-helper"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ 上传失败"
    echo "=========================================="
    echo ""
    echo "可能的原因："
    echo "1. 还没有在GitHub上创建仓库"
    echo "   请访问：https://github.com/new"
    echo "   仓库名：pill-helper"
    echo ""
    echo "2. 身份验证失败"
    echo "   需要创建Personal Access Token："
    echo "   https://github.com/settings/tokens"
    echo "   权限需要勾选 'repo'"
    echo ""
    echo "3. 网络连接问题"
    echo "   请检查网络连接后重试"
    echo ""
fi
