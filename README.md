# Benkey / Mykeyboard

## 快速上手
- 工程入口：双击 [Benkey.xcodeproj](file:///Users/houquanchen/Documents/trae_projects/Benkey/Benkey.xcodeproj) 打开 Xcode。
- 选择扩展 Scheme：在 Xcode 顶部选择 Mykeyboard（或 Copy of Mykeyboard）。
- 绑定宿主：Product → Scheme → Edit Scheme → Run → Executable 选择 Benkey.app。
- 启用键盘（中文系统）：设置 → 通用 → 键盘 → 键盘 → 添加新键盘… → 选择“Mykeyboard — Benkey”。
- 显示软键盘：模拟器菜单 → 设备 → 键盘 → 取消“连接硬件键盘”，或按 Command+K。

## 关键文件
- 键盘控制器：[KeyboardViewController.swift](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard/KeyboardViewController.swift)
- 扩展配置：[Info.plist](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard/Info.plist)

## 上下文与流程
- 上下文汇总（.txt）：[docs/Mykeyboard_Context_Summary.txt](file:///Users/houquanchen/Documents/trae_projects/Benkey/docs/Mykeyboard_Context_Summary.txt)
- 工作流程（.txt）：[docs/Mykeyboard_Workflow_2026-02-20.txt](file:///Users/houquanchen/Documents/trae_projects/Benkey/docs/Mykeyboard_Workflow_2026-02-20.txt)
- 原始 Markdown：
  - [Mykeyboard_Context_Summary.md](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard_Context_Summary.md)（如存在）
  - [Mykeyboard_Workflow_2026-02-20.md](file:///Users/houquanchen/Documents/trae_projects/Benkey/Mykeyboard_Workflow_2026-02-20.md)

## 提交与同步
- 推荐使用 .gitignore（Xcode/Swift），忽略 DerivedData、build、xcuserdata、*.xcuserstate 等。
- 推送到 GitHub（SSH）：
  ```bash
  git remote add origin git@github.com:<user>/<repo>.git
  git push -u origin main
  ```

## 常见问题
- 看不到软键盘：取消“连接硬件键盘”或按 Command+K。
- 键盘空白：确认 Info.plist 指向 KeyboardViewController，且未使用 storyboard。

