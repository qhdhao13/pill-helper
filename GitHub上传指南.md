# GitHub上传指南

## 步骤1：在GitHub上创建仓库

1. 打开浏览器，访问 https://github.com
2. 登录您的账号（qhdhao13）
3. 点击右上角的 **"+"** 按钮，选择 **"New repository"**
4. 填写仓库信息：
   - **Repository name**: `pill-helper`
   - **Description**: `吃药提醒 - 专为中老年群体设计的跨平台吃药提醒APP`
   - **Visibility**: 选择 **Public**（公开）或 **Private**（私有）
   - **不要**勾选 "Initialize this repository with a README"（我们已经有了）
   - **不要**添加 .gitignore 或 license（我们已经有了）
5. 点击 **"Create repository"** 按钮

## 步骤2：在本地添加远程仓库并推送

创建完仓库后，GitHub会显示一个页面，上面有仓库的URL，格式类似：
`https://github.com/qhdhao13/pill-helper.git`

然后在终端运行以下命令：

```bash
# 添加远程仓库
git remote add origin https://github.com/qhdhao13/pill-helper.git

# 推送代码到GitHub
git push -u origin main
```

如果您的默认分支是 `master` 而不是 `main`，请使用：
```bash
git push -u origin master
```

## 步骤3：验证上传

推送完成后，访问 https://github.com/qhdhao13/pill-helper 查看您的仓库。

## 常见问题

### 如果提示需要身份验证

GitHub现在要求使用个人访问令牌（Personal Access Token）而不是密码：

1. 访问 https://github.com/settings/tokens
2. 点击 **"Generate new token"** → **"Generate new token (classic)"**
3. 填写信息：
   - **Note**: `pill-helper-upload`
   - **Expiration**: 选择过期时间（建议90天或更长）
   - **Scopes**: 勾选 `repo`（完整仓库权限）
4. 点击 **"Generate token"**
5. 复制生成的token（只显示一次，请保存好）
6. 推送时，用户名输入 `qhdhao13`，密码输入刚才复制的token

### 如果分支名称不匹配

检查当前分支：
```bash
git branch
```

如果显示 `master`，可以重命名为 `main`：
```bash
git branch -M main
```

然后再推送。
