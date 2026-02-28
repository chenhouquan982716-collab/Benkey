//
//  KeyboardViewController.swift
//  Mykeyboard
//
//  Created by houquan chen on 2026/2/20.
//

import UIKit
final class RoleScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool { true }
    override init(frame: CGRect) {
        super.init(frame: frame)
        delaysContentTouches = true
        canCancelContentTouches = true
        showsHorizontalScrollIndicator = false
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delaysContentTouches = true
        canCancelContentTouches = true
        showsHorizontalScrollIndicator = false
    }
}

final class KeyboardViewController: UIInputViewController {
    var pastedContext: String = ""
    var currentRole: String = "合作伙伴"
    private let pasteOriginalTitle = "粘贴对方消息"
    private let gridSpacing: CGFloat = 8
    private let keyFontSize: CGFloat = 14
    private let topRoleHeight: CGFloat = 40
    private let toneTitles = ["高情商","幽默","礼貌","尊重","崇拜","亲切","真诚","夸赞","调皮"]
    private let roleTitles = ["追求女生","老婆/老公","朋友","合作伙伴","刁钻客户"]
    private var roleButtons: [UIButton] = []
    private let keyboardBaseColor = UIColor.clear
    private var keyboardHeightConstraint: NSLayoutConstraint!
    private var originalUserDraft: String = "" // 缓存用户原始意图
    private var lastAiOutput: String = ""      // 缓存上一次 AI 输出
    private lazy var clearPasteBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .systemGray
        b.isHidden = true
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onClearPasteTap), for: .touchUpInside)
        return b
    }()
    
    private lazy var pasteButton: UIButton = makeButton(title: pasteOriginalTitle, bg: UIColor(red: 174.0/255.0, green: 181.0/255.0, blue: 189.0/255.0, alpha: 1.0), fg: .black)
    private lazy var settingsBtn: UIButton = {
        let b = makeButton(title: "", bg: UIColor(red: 174.0/255.0, green: 181.0/255.0, blue: 189.0/255.0, alpha: 1.0), fg: .black)
        b.setImage(UIImage(systemName: "gearshape"), for: .normal)
        b.tintColor = .black
        b.widthAnchor.constraint(equalToConstant: 60).isActive = true
        b.addTarget(self, action: #selector(onSettingsTap), for: .touchUpInside)
        b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        return b
    }()
    private lazy var deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .white
        b.tintColor = .black
        b.setImage(UIImage(systemName: "delete.left"), for: .normal)
        b.layer.cornerRadius = 8
        b.addTarget(self, action: #selector(onDelete), for: .touchUpInside)
        b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        return b
    }()
    private lazy var clearButton: UIButton = makeButton(title: "清空", bg: .white, fg: .black)
    private lazy var sendButton: UIButton = makeButton(title: "发送", bg: .white, fg: .black)
    private var toneButtons: [UIButton] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
        keyboardHeightConstraint = view.heightAnchor.constraint(equalToConstant: 330)
        keyboardHeightConstraint.isActive = true
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = gridSpacing
        outer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outer)
        outer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: gridSpacing).isActive = true
        outer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -gridSpacing).isActive = true
        outer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: gridSpacing).isActive = true
        outer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -gridSpacing).isActive = true
        let topRowStack = UIStackView()
        topRowStack.axis = .horizontal
        topRowStack.spacing = gridSpacing
        topRowStack.alignment = .fill
        topRowStack.distribution = .fill
        topRowStack.translatesAutoresizingMaskIntoConstraints = false
        outer.addArrangedSubview(topRowStack)
        topRowStack.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let roleScroll = RoleScrollView()
        roleScroll.translatesAutoresizingMaskIntoConstraints = false
        roleScroll.showsHorizontalScrollIndicator = false
        roleScroll.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        roleScroll.delaysContentTouches = true
        roleScroll.panGestureRecognizer.cancelsTouchesInView = true
        roleScroll.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topRowStack.addArrangedSubview(roleScroll)
        let roleContent = UIStackView()
        roleContent.axis = .horizontal
        roleContent.alignment = .fill
        roleContent.spacing = 8
        roleContent.translatesAutoresizingMaskIntoConstraints = false
        roleScroll.addSubview(roleContent)
        NSLayoutConstraint.activate([
            roleContent.leadingAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.leadingAnchor),
            roleContent.trailingAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.trailingAnchor),
            roleContent.topAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.topAnchor),
            roleContent.bottomAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.bottomAnchor),
            roleContent.heightAnchor.constraint(equalTo: roleScroll.frameLayoutGuide.heightAnchor)
        ])
        for t in roleTitles {
            let b = makeButton(title: t, bg: .white, fg: .black)
            b.titleLabel?.font = .systemFont(ofSize: keyFontSize, weight: .medium)
            // 以文本宽度+固定左右边距计算按钮固定宽度，避免在 iOS15+ 下边距失效导致被压窄
            let font = UIFont.systemFont(ofSize: keyFontSize, weight: .medium)
            let textWidth = (t as NSString).size(withAttributes: [.font: font]).width
            let buttonWidth = ceil(textWidth + 24) // 左右各 12
            b.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
            b.setContentCompressionResistancePriority(.required, for: .horizontal)
            b.setContentHuggingPriority(.required, for: .horizontal)
            b.addTarget(self, action: #selector(onRoleTap(_:)), for: .touchUpInside)
            b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
            b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
            roleButtons.append(b)
            roleContent.addArrangedSubview(b)
        }
        // 去除额外尾部占位，由按钮固有宽度自然撑开滚动范围
        updateRoleSelection(selected: "合作伙伴")
        let pasteRowStack = UIStackView(arrangedSubviews: [])
        pasteRowStack.axis = .horizontal
        pasteRowStack.spacing = gridSpacing
        pasteRowStack.alignment = .fill
        pasteRowStack.distribution = .fill
        pasteRowStack.translatesAutoresizingMaskIntoConstraints = false
        pasteRowStack.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        outer.addArrangedSubview(pasteRowStack)
        let switchBtn = makeButton(title: "", bg: UIColor(red: 174.0/255.0, green: 181.0/255.0, blue: 189.0/255.0, alpha: 1.0), fg: .black)
        switchBtn.setImage(UIImage(systemName: "keyboard"), for: .normal)
        switchBtn.tintColor = .black
        switchBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        switchBtn.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        switchBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        switchBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchBtn.setContentHuggingPriority(.required, for: .horizontal)
        pasteRowStack.addArrangedSubview(switchBtn)
        pasteRowStack.addArrangedSubview(pasteButton)
        pasteRowStack.addArrangedSubview(settingsBtn)
        // 粘贴按钮高度与标准按键一致
        pasteButton.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        pasteButton.layer.cornerRadius = 8
        pasteButton.layer.masksToBounds = false
        // 将清除按钮镶嵌到粘贴按钮内部
        pasteButton.addSubview(clearPasteBtn)
        NSLayoutConstraint.activate([
            clearPasteBtn.centerYAnchor.constraint(equalTo: pasteButton.centerYAnchor),
            clearPasteBtn.trailingAnchor.constraint(equalTo: pasteButton.trailingAnchor, constant: -8),
            clearPasteBtn.widthAnchor.constraint(equalToConstant: 30),
            clearPasteBtn.heightAnchor.constraint(equalToConstant: 30)
        ])
        pasteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 38)
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = gridSpacing
        grid.distribution = .fill
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.setContentHuggingPriority(.required, for: .vertical)
        grid.setContentCompressionResistancePriority(.required, for: .vertical)
        outer.addArrangedSubview(grid)
        let totalGridHeight = topRoleHeight * 3 + gridSpacing * 2
        grid.heightAnchor.constraint(equalToConstant: totalGridHeight).isActive = true
        pasteButton.addTarget(self, action: #selector(onPaste), for: .touchUpInside)
        pasteButton.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        pasteButton.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        clearButton.addTarget(self, action: #selector(onClear), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        clearButton.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        sendButton.addTarget(self, action: #selector(onSend), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        sendButton.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        let tonesRow1 = ["高情商","幽默","礼貌"]
        let tonesRow2 = ["尊重","崇拜","亲切"]
        let tonesRow3 = ["真诚","夸赞","调皮"]
        let row1 = makeRow()
        row1.addArrangedSubview(makeToneButton(tonesRow1[0]))
        row1.addArrangedSubview(makeToneButton(tonesRow1[1]))
        row1.addArrangedSubview(makeToneButton(tonesRow1[2]))
        row1.addArrangedSubview(deleteButton)
        row1.setContentHuggingPriority(.required, for: .vertical)
        row1.setContentCompressionResistancePriority(.required, for: .vertical)
        row1.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let row2 = makeRow()
        row2.addArrangedSubview(makeToneButton(tonesRow2[0]))
        row2.addArrangedSubview(makeToneButton(tonesRow2[1]))
        row2.addArrangedSubview(makeToneButton(tonesRow2[2]))
        row2.addArrangedSubview(clearButton)
        row2.setContentHuggingPriority(.required, for: .vertical)
        row2.setContentCompressionResistancePriority(.required, for: .vertical)
        row2.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let row3 = makeRow()
        row3.addArrangedSubview(makeToneButton(tonesRow3[0]))
        row3.addArrangedSubview(makeToneButton(tonesRow3[1]))
        row3.addArrangedSubview(makeToneButton(tonesRow3[2]))
        row3.addArrangedSubview(sendButton)
        row3.setContentHuggingPriority(.required, for: .vertical)
        row3.setContentCompressionResistancePriority(.required, for: .vertical)
        row3.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        grid.addArrangedSubview(row1)
        grid.addArrangedSubview(row2)
        grid.addArrangedSubview(row3)
    }
    private func makeRow() -> UIStackView {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = gridSpacing
        h.distribution = .fillEqually
        h.translatesAutoresizingMaskIntoConstraints = false
        return h
    }
    
    private func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: keyFontSize, weight: .medium)
        b.setTitleColor(fg, for: .normal)
        b.backgroundColor = bg
        b.layer.cornerRadius = 8
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOffset = CGSize(width: 0, height: 1.2)
        b.layer.shadowOpacity = 0.3
        b.layer.shadowRadius = 0.0
        b.layer.masksToBounds = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }
    private func updateRoleSelection(selected: String) {
        currentRole = selected
        for btn in roleButtons {
            let isSel = (btn.currentTitle == selected)
            btn.backgroundColor = isSel ? .systemBlue : .white
            btn.setTitleColor(isSel ? .white : .black, for: .normal)
        }
    }
    @objc private func onRoleTap(_ sender: UIButton) {
        let title = sender.currentTitle ?? "合作伙伴"
        updateRoleSelection(selected: title)
    }
    private func makeToneButton(_ title: String) -> UIButton {
        let b = makeButton(title: title, bg: .white, fg: .black)
        b.addTarget(self, action: #selector(onToneTap(_:)), for: .touchUpInside)
        b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        toneButtons.append(b)
        return b
    }
    @objc private func onKeyDown(_ sender: UIButton) {
        if sender == sendButton || (roleButtons.contains(sender) && sender.backgroundColor == .systemBlue) {
            sender.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
            sender.setTitleColor(.white, for: .normal)
        } else {
            sender.backgroundColor = .secondarySystemBackground
            sender.setTitleColor(.black, for: .normal)
        }
    }
    @objc private func onKeyUp(_ sender: UIButton) {
        if sender == sendButton || (roleButtons.contains(sender) && sender.titleColor(for: .normal) == .white) {
            sender.backgroundColor = .systemBlue
            sender.setTitleColor(.white, for: .normal)
        } else {
            sender.backgroundColor = .white
            sender.setTitleColor(.black, for: .normal)
        }
    }
    @objc private func onPaste() {
        let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            pasteButton.setTitle("剪贴板为空", for: .normal)
        } else {
            pastedContext = text
            let prefix = String(text.prefix(7))
            pasteButton.setTitle("已粘贴: " + prefix + "...", for: .normal)
            clearPasteBtn.isHidden = false
        }
    }
    @objc private func onClearPasteTap() {
        pasteButton.setTitle(pasteOriginalTitle, for: .normal)
        clearPasteBtn.isHidden = true
        pastedContext = ""
        originalUserDraft = ""
        lastAiOutput = ""
        let existing = textDocumentProxy.documentContextBeforeInput ?? ""
        if !existing.isEmpty {
            for _ in 0..<existing.count { textDocumentProxy.deleteBackward() }
        }
    }
    @objc private func onToneTap(_ sender: UIButton) {
        let tone = sender.currentTitle ?? ""
        let role = currentRole
        let pasted = pastedContext.trimmingCharacters(in: .whitespacesAndNewlines)
        let currentInput = textDocumentProxy.documentContextBeforeInput?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isRegeneration = (!lastAiOutput.isEmpty && currentInput == lastAiOutput.trimmingCharacters(in: .whitespacesAndNewlines))
        let candidateIntent = !pasted.isEmpty ? pasted : currentInput
        let payloadToUse: String = {
            if isRegeneration {
                return originalUserDraft
            } else {
                originalUserDraft = candidateIntent
                return candidateIntent
            }
        }()
        let sys = """
        角色设定：对话对象是【\(role)】；整体语气使用【\(tone)】。
        整体风格：极度口语化、接地气、短句、有“网感”。可自然带一点点语气词（哈、呢、嘛、啦）或最多一个日常emoji（可无），不要做作。

        硬性禁令：
        - 严禁出现“亲爱的/您好/温馨的/尊敬的”等翻译腔或播音腔词汇
        - 严禁出现“作为一个AI”“很抱歉”“我的模型/算法/提示词”等任何自我暴露或解释
        - 严禁输出多余说明、步骤、引号、前缀后缀；只输出要发出去的微信文字
        - 身份逻辑防错：粘贴的消息是对方发给我的！如果对方在消息里称呼了某人（如“王总”、“老板”等），那说明我才是这个身份！你在回复时绝对禁止用这个称呼去反叫对方！请直接说事，或者根据【\(role)】的身份自然回应。

        模式判定（根据收到的 userInput 内容自动选择）：
        1) 主动开场模式：若 userInput 等于“生成一句开场白”或为空 → 以【\(tone)】为基调，面向【\(role)】写一句自然、不尴尬的开场白。
        2) 创作/润色模式（极其重要）：若 userInput 是一段大白话草稿，或者是明确的指令需求（例如“帮我写一条问王总催尾款的信息”），请立刻作为本人执行该指令！用【\(tone)】的风格、面向【\(role)】生成最终要发送的文字。绝不要回答“好的”，直接输出结果。
        3) 回复对方模式：若 userInput 看起来是对方发给我的话 → 直接给出高质量的接话回复。

        细节要求：
        - 句子短、干净、自然；标点简洁；不要连续的感叹号或表情
        - 蓝底白字按钮仅影响“语气强弱”，不改变以上硬性规则
        - 全程保持与【\(role)】的真实关系感与语境匹配

        只输出最终要发送的微信文本。
        """
        let userPayload = payloadToUse.isEmpty ? "生成一句开场白" : payloadToUse
        let original = sender.currentTitle ?? ""
        sender.setTitle("思考中...", for: .normal)
        callDeepSeek(systemPrompt: sys, userInput: userPayload) { [weak self] text in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let existing = self.textDocumentProxy.documentContextBeforeInput ?? ""
                if !existing.isEmpty {
                    for _ in 0..<existing.count { self.textDocumentProxy.deleteBackward() }
                }
                self.textDocumentProxy.insertText(text)
                self.lastAiOutput = text
                sender.setTitle(original, for: .normal)
            }
        }
    }
    @objc private func onDelete() {
        textDocumentProxy.deleteBackward()
    }
    @objc private func onSettingsTap() {
    }
    @objc private func onClear() {
        pastedContext = ""
        pasteButton.setTitle(pasteOriginalTitle, for: .normal)
        let proxy = textDocumentProxy
        while let before = proxy.documentContextBeforeInput, !before.isEmpty {
            proxy.deleteBackward()
        }
    }
    @objc private func onSend() {
        textDocumentProxy.insertText("\n")
    }
    private func prompt(for tone: String) -> String {
        switch tone {
        case "高情商":
            return "请用委婉、体面、专业且不带指责的语气回复对方，化解矛盾并给出建设性建议。直接输出回复内容。"
        case "幽默":
            return "请用轻松幽默、机智而不失礼貌的语气回复对方，缓和气氛。直接输出回复内容。"
        case "礼貌":
            return "请用正式、礼貌、得体、简洁的语气回复对方。直接输出回复内容。"
        case "尊重":
            return "请以尊重对方立场的语气回复，承认其合理性并表达自己的观点。直接输出回复内容。"
        case "崇拜":
            return "请以钦佩与认可的语气回复，突出对方的经验与优势，表达学习与赞赏。直接输出回复内容。"
        case "亲切":
            return "请用温暖、亲切、友好、贴近生活的语气回复，拉近关系。直接输出回复内容。"
        case "真诚":
            return "请以真诚、坦率、可信且不夸张的语气回复对方。直接输出回复内容。"
        case "夸赞":
            return "请以积极夸赞的语气回复，具体、真诚、不浮夸地突出对方优点。直接输出回复内容。"
        case "调皮":
            return "请用俏皮、轻松、略带调侃但不冒犯的语气回复。直接输出回复内容。"
        default:
            return "请用委婉、体面、专业的语气回复对方。直接输出回复内容。"
        }
    }
    private func callDeepSeek(systemPrompt: String, userInput: String, completion: @escaping (String) -> Void) {
        struct ChatMessage: Codable { let role: String; let content: String }
        struct ChatRequest: Encodable { let model: String; let messages: [ChatMessage] }
        struct ChatChoice: Decodable { let message: ChatMessage }
        struct ChatResponse: Decodable { let choices: [ChatChoice] }
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else {
            completion("网络错误")
            return
        }
        let system = ChatMessage(role: "system", content: systemPrompt)
        let user = ChatMessage(role: "user", content: userInput)
        let body = ChatRequest(model: "deepseek-chat", messages: [system, user])
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer sk-edf40a2738ad47f49d3262a33613c7eb", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 15
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion("请求构造失败")
            return
        }
        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error as? URLError {
                completion("NET \(e.errorCode)")
                return
            } else if let e = error {
                completion("ERR \(e.localizedDescription)")
                return
            }
            if let http = resp as? HTTPURLResponse, http.statusCode != 200 {
                completion("HTTP \(http.statusCode)")
                return
            }
            guard let data = data else {
                completion("空响应")
                return
            }
            if let decoded = try? JSONDecoder().decode(ChatResponse.self, from: data),
               let content = decoded.choices.first?.message.content,
               !content.isEmpty {
                completion(content)
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String {
                completion(content)
                return
            }
            completion("解析失败")
        }.resume()
    }
}
