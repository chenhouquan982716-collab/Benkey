# Mykeyboard 技术手册（V1.6）

## 目标与功能
- iOS 第三方键盘扩展，支持：
- 顶部角色选择（5 个角色）
- 粘贴对方聊天内容并预览
- 九宫格 9 种语气一键生成与上屏
- 删除、清空、发送快捷操作
- 与系统键盘底部安全区视觉融合

## 环境与前置
- macOS + Xcode（最新版）
- iOS 模拟器或真机（建议 iOS 17+）
- DeepSeek 或目标模型的 API Key（上线前不入库）
- Apple 开发者账号（真机调试）

## 核心文件
- 扩展入口： [KeyboardViewController.swift](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard/KeyboardViewController.swift)
- 扩展配置： [Info.plist](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard/Info.plist)
- 忽略规则： [.gitignore](file:///Users/houquanchen/Documents/trae_projects/Benkey/.gitignore)

## 快速上手
- 在 Xcode 选择扩展 Scheme：Mykeyboard（E 图标），Edit Scheme → Run → Executable 选 Benkey.app
- 运行后在模拟器：
- 设备 → 键盘 → 取消“连接硬件键盘”，Command+K 显示软件键盘
- 长按“🌐”，选择“Mykeyboard — Benkey”
- 在真机：
- 设置 → 通用 → 键盘 → 键盘 → 添加“Mykeyboard — Benkey”
- 打开“允许完全访问”
- 复制对方消息 → 键盘顶部“点击粘贴对方聊天内容” → 选择角色 → 点任一语气键 → 自动上屏

## UI 布局（三层）
- 第一层：角色栏（横向 UIScrollView + 水平 UIStackView）
- 角色按钮：追求女生、老婆/老公、朋友、合作伙伴、刁钻客户
- 默认选“合作伙伴”，选中蓝底白字；未选白底黑字
- 第二层：粘贴栏（按钮）
- 文案“点击粘贴对方聊天内容”
- 高度与标准键一致（40pt），圆角 8
- 第三层：九宫格（3×4）
- 九种语气 + 删除/清空/发送
- 三行行高与角色栏一致（40pt）
- 外层：垂直 UIStackView，自适应高度

## 视觉规范
- 主视图背景：透明（view.isOpaque=false，view.backgroundColor=.clear），与系统安全区融合
- 按钮风格：白底 + 阴影（opacity 0.12 / radius 4 / offset 0,2），圆角 8
- 字体统一：keyFontSize（14pt）+ medium
- 默认字色统一：黑色（.black）
- 防瞎眼：蓝底按钮（发送、选中角色）用白字（.white）

## 交互逻辑
- 角色选择：更新 currentRole 并刷新选中样式（蓝底白字）
- 粘贴：读取剪贴板保存到 pastedContext，按钮显示“已粘贴: 前10字…”
- 语气按钮：按钮显示“思考中…”，调用 API 返回文本后主线程上屏并恢复按钮文案
- 删除：textDocumentProxy.deleteBackward()
- 清空：重置粘贴状态并循环 deleteBackward 清空输入框
- 发送：textDocumentProxy.insertText("\n")
- 切换键：“🌐”绑定 handleInputModeList（轻点轮换、长按列表）

## 动态 Prompt（核心）
- 语气键点击时组合 System Prompt：
- “你是一个高情商沟通专家。你现在的对话对象是【\(currentRole)】。请用【\(tone)】的语气，回复对方发来的话。直接输出回复内容，不要任何废话，符合对话对象的身份关系。”
- 用户内容：pastedContext（为空时兜底读剪贴板）

## 联网与诊断
- 端点：https://api.deepseek.com/chat/completions
- 认证头：
- req.addValue("Bearer YOUR_API_KEY_HERE", forHTTPHeaderField: "Authorization")
- 真机必须打开“允许完全访问”
- 诊断输出（已内置）：
- URLError → “NET <错误码>”（-1009 网络断开、-1001 超时）
- HTTP 非 200 → “HTTP <状态码>”（401 未授权等）
- 其他错误 → “ERR <描述>”；无数据 → “空响应”

## 安全与密钥
- 禁止把真实 Key 入库；提交前替换为占位符
- 本地密钥文件（不入库）示例：
```
import Foundation
struct Secrets { static let deepseekKey = "你的Key" }
```
- 授权头改为：
```
req.addValue("Bearer " + Secrets.deepseekKey, forHTTPHeaderField: "Authorization")
```
- .gitignore 排除 Benkey/Mykeyboard/LocalSecrets.swift

## 稳定性与约束
- 避免跨层约束（“no common ancestor”会崩溃）
- 使用常量行高 topRoleHeight=40；粘贴按钮高度与标准键一致
- 九宫格 grid.distribution = .fillProportionally，尊重固定行高
- 移除在 viewDidLayoutSubviews 里动态添加高度约束的做法，改为构建时固定约束

## 常见问题排错
- 键盘不显示：确认已添加并启用第三方键盘；非安全输入框测试
- 自动切回系统键盘：安全输入框限制或扩展崩溃/超时（检查控制台）
- 网络错误：
- HTTP 401：Key 或 Authorization 格式错误（需“Bearer ”+Key）
- NET -1009：设备网络断开；NET -1001：超时
- 颜色分界：主视图背景设 .clear；必要时加 UIVisualEffectView(systemChromeMaterial)
- 文本清空：光标应在末尾；当前实现清空光标前全部文本

## Git 工作流（不覆盖 main）
- 创建版本分支并推送：
```
git checkout -b v1.6-role-selector
git add .
git commit -m "feat: 杀青！V1.6 新增顶部角色选择器与动态 Prompt 组合逻辑。"
git push -u origin v1.6-role-selector
```
- 发起 PR：compare 选 v1.6-role-selector → base 选 main
- 忽略 Xcode 用户数据：
```
git rm -r --cached Benkey.xcodeproj/project.xcworkspace/xcuserdata
git commit -m "chore: ignore Xcode user data"
```

## 版本里程碑
- V1.5：初版 UI（粘贴 + 3×4 九宫格 + 删除/清空/发送）与调用
- V1.6：顶部角色选择器、动态 Prompt、Typography 统一、背景透明融合、诊断码输出、清空输入框完善

## 验收清单
- 功能：角色选择正常、粘贴预览、九种语气生成上屏、删除/清空/发送正确
- 视觉：白色按钮带投影；蓝底白字可读；主视图与底部安全区融合无分界
- 联网：允许完全访问开启；请求返回正常或能显示诊断码
- 稳定：无约束崩溃；切换键正常；在非安全输入框保持当前键盘
