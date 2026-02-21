//
//  KeyboardViewController.swift
//  Mykeyboard
//
//  Created by houquan chen on 2026/2/20.
//

import UIKit

final class KeyboardViewController: UIInputViewController {

    private lazy var titleButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("我的第一个键盘", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onTitleTap), for: .touchUpInside)
        return b
    }()

    private lazy var nextKeyboardButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("🌐", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        view.addSubview(titleButton)
        view.addSubview(nextKeyboardButton)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleButton.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            titleButton.centerYAnchor.constraint(equalTo: g.centerYAnchor),

            nextKeyboardButton.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 12),
            nextKeyboardButton.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -8)
        ])
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    @objc private func onTitleTap() {
        textDocumentProxy.insertText(" ")
    }

}
