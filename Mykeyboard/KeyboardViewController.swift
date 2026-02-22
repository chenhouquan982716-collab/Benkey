//
//  KeyboardViewController.swift
//  Mykeyboard
//
//  Created by houquan chen on 2026/2/20.
//

import UIKit

final class KeyboardViewController: UIInputViewController {
    var pastedContext: String = ""
    var currentRole: String = "合作伙伴"
    private let pasteOriginalTitle = "点击粘贴对方聊天内容"
    private let gridSpacing: CGFloat = 8
    private let keyFontSize: CGFloat = 14
    private let topRoleHeight: CGFloat = 40
    private let toneTitles = ["高情商","幽默","礼貌","尊重","崇拜","亲切","真诚","夸赞","调皮"]
    private let roleTitles = ["追求女生","老婆/老公","朋友","合作伙伴","刁钻客户"]
    private var roleButtons: [UIButton] = []
    private let keyboardBaseColor = UIColor.systemGray5
    private var keyboardHeightConstraint: NSLayoutConstraint!
    private lazy var nextKeyboardButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🌐", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        return b
    }()
    private lazy var pasteButton: UIButton = makeButton(title: pasteOriginalTitle, bg: .white, fg: .systemPurple)
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
    private lazy var sendButton: UIButton = makeButton(title: "发送", bg: .white, fg: .systemBlue)
    private var toneButtons: [UIButton] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = keyboardBaseColor
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
        let roleScroll = UIScrollView()
        roleScroll.translatesAutoresizingMaskIntoConstraints = false
        roleScroll.showsHorizontalScrollIndicator = false
        outer.addArrangedSubview(roleScroll)
        roleScroll.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let roleContent = UIStackView()
        roleContent.axis = .horizontal
        roleContent.alignment = .fill
        roleContent.spacing = 8
        roleContent.translatesAutoresizingMaskIntoConstraints = false
        roleScroll.addSubview(roleContent)
        roleContent.leadingAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.leadingAnchor, constant: 0).isActive = true
        roleContent.trailingAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.trailingAnchor, constant: 0).isActive = true
        roleContent.topAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.topAnchor).isActive = true
        roleContent.bottomAnchor.constraint(equalTo: roleScroll.contentLayoutGuide.bottomAnchor).isActive = true
        roleContent.heightAnchor.constraint(equalTo: roleScroll.frameLayoutGuide.heightAnchor).isActive = true
        for t in roleTitles {
            let b = makeButton(title: t, bg: .white, fg: .darkGray)
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            b.addTarget(self, action: #selector(onRoleTap(_:)), for: .touchUpInside)
            b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
            b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
            roleButtons.append(b)
            roleContent.addArrangedSubview(b)
        }
        updateRoleSelection(selected: "合作伙伴")
        outer.addArrangedSubview(pasteButton)
        // 粘贴按钮高度为角色按钮高度的 2/3 + 8pt
        pasteButton.heightAnchor.constraint(equalToConstant: topRoleHeight * 2.0 / 3.0 + 8).isActive = true
        keyboardHeightConstraint.constant += 8
        pasteButton.layer.cornerRadius = (topRoleHeight * 2.0 / 3.0 + 8) / 2
        pasteButton.layer.masksToBounds = true
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = gridSpacing
        grid.distribution = .fillProportionally
        grid.translatesAutoresizingMaskIntoConstraints = false
        outer.addArrangedSubview(grid)
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
        row1.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let row2 = makeRow()
        row2.addArrangedSubview(makeToneButton(tonesRow2[0]))
        row2.addArrangedSubview(makeToneButton(tonesRow2[1]))
        row2.addArrangedSubview(makeToneButton(tonesRow2[2]))
        row2.addArrangedSubview(clearButton)
        row2.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        let row3 = makeRow()
        row3.addArrangedSubview(makeToneButton(tonesRow3[0]))
        row3.addArrangedSubview(makeToneButton(tonesRow3[1]))
        row3.addArrangedSubview(makeToneButton(tonesRow3[2]))
        row3.addArrangedSubview(sendButton)
        row3.heightAnchor.constraint(equalToConstant: topRoleHeight).isActive = true
        grid.addArrangedSubview(row1)
        grid.addArrangedSubview(row2)
        grid.addArrangedSubview(row3)
        view.addSubview(nextKeyboardButton)
        NSLayoutConstraint.activate([
            nextKeyboardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            nextKeyboardButton.widthAnchor.constraint(equalToConstant: 36),
            nextKeyboardButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    private func makeRow() -> UIStackView {
        let h = UIStackView()
        h.axis = .horizontal
        h.spacing = gridSpacing
        h.distribution = .fillEqually
        h.translatesAutoresizingMaskIntoConstraints = false
        return h
    }
    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    private func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: keyFontSize, weight: .medium)
        b.setTitleColor(fg, for: .normal)
        b.backgroundColor = bg
        b.layer.cornerRadius = 8
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.12
        b.layer.shadowRadius = 4
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }
    private func updateRoleSelection(selected: String) {
        currentRole = selected
        for btn in roleButtons {
            let isSel = (btn.currentTitle == selected)
            btn.backgroundColor = isSel ? .systemBlue : .white
            btn.setTitleColor(isSel ? .white : .darkGray, for: .normal)
        }
    }
    @objc private func onRoleTap(_ sender: UIButton) {
        let title = sender.currentTitle ?? "合作伙伴"
        updateRoleSelection(selected: title)
    }
    private func makeToneButton(_ title: String) -> UIButton {
        let b = makeButton(title: title, bg: .white, fg: .darkGray)
        b.addTarget(self, action: #selector(onToneTap(_:)), for: .touchUpInside)
        b.addTarget(self, action: #selector(onKeyDown(_:)), for: [.touchDown, .touchDragEnter])
        b.addTarget(self, action: #selector(onKeyUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
        toneButtons.append(b)
        return b
    }
    @objc private func onKeyDown(_ sender: UIButton) {
        if sender == sendButton || (roleButtons.contains(sender) && sender.backgroundColor == .systemBlue) {
            sender.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        } else {
            sender.backgroundColor = keyboardBaseColor
        }
    }
    @objc private func onKeyUp(_ sender: UIButton) {
        if sender == sendButton || (roleButtons.contains(sender) && sender.titleColor(for: .normal) == .white) {
            sender.backgroundColor = .systemBlue
        } else {
            sender.backgroundColor = .white
        }
    }
    @objc private func onPaste() {
        let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            pasteButton.setTitle("剪贴板为空", for: .normal)
        } else {
            pastedContext = text
            let prefix = String(text.prefix(10))
            pasteButton.setTitle("已粘贴: " + prefix + "...", for: .normal)
        }
    }
    @objc private func onToneTap(_ sender: UIButton) {
        let tone = sender.currentTitle ?? ""
        var ctx = pastedContext
        if ctx.isEmpty {
            ctx = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        if ctx.isEmpty { return }
        let original = sender.currentTitle ?? ""
        sender.setTitle("思考中...", for: .normal)
        let sys = "你是一个高情商沟通专家。你现在的对话对象是【\(currentRole)】。请用【\(tone)】的语气，回复对方发来的话。直接输出回复内容，不要任何废话，符合对话对象的身份关系。"
        callDeepSeek(systemPrompt: sys, userInput: ctx) { [weak self] text in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.textDocumentProxy.insertText(text)
                sender.setTitle(original, for: .normal)
            }
        }
    }
    @objc private func onDelete() {
        textDocumentProxy.deleteBackward()
    }
    @objc private func onClear() {
        pastedContext = ""
        pasteButton.setTitle(pasteOriginalTitle, for: .normal)
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
        req.addValue("Bearer YOUR_API_KEY_HERE", forHTTPHeaderField: "Authorization")
        req.timeoutInterval = 15
        do {
            req.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion("请求构造失败")
            return
        }
        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let _ = error {
                completion("网络错误")
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
