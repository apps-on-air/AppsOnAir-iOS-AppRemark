//
//  ViewController.swift
//  AppsOnAir-AppRemark
//
//  Created by 164989979 on 10/01/2024.
//  Copyright (c) 2024 164989979. All rights reserved.
//

import UIKit
import AppsOnAir_AppRemark

class ViewController: UIViewController {
    let appRemarkService = AppRemarkService.shared
    let sensitivityButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dropdown to change shake sensitivity
        sensitivityButton.layer.borderWidth = 1
        sensitivityButton.layer.borderColor = UIColor.systemGray.cgColor
        sensitivityButton.layer.cornerRadius = 4
        sensitivityButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        sensitivityButton.showsMenuAsPrimaryAction = true
        updateSensitivityMenu()

        let nextButton = UIButton(elevatedTitle: "Go to next", backgroundColor: .yellow)
        nextButton.addTarget(self, action: #selector(gotoNext), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [sensitivityButton, nextButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            sensitivityButton.widthAnchor.constraint(equalToConstant: 280),
        ])
    }

    func updateSensitivityMenu() {
        let selected = AppDelegate.shakeSensitivity
        sensitivityButton.setTitle("Shake sensitivity: \(displayName(of: selected)) ▾", for: .normal)

        let sensitivities: [ShakeSensitivity] = [.veryLow, .low, .medium, .high, .veryHigh]
        let actions = sensitivities.map { sensitivity in
            UIAction(title: displayName(of: sensitivity), state: sensitivity == selected ? .on : .off) { [weak self] _ in
                self?.changeShakeSensitivity(sensitivity)
            }
        }
        sensitivityButton.menu = UIMenu(title: "Shake sensitivity", children: actions)
    }

    func changeShakeSensitivity(_ shakeSensitivity: ShakeSensitivity) {
        AppDelegate.shakeSensitivity = shakeSensitivity
        // Help to change shake sensitivity at runtime, applied to the next shake without restarting the app
        appRemarkService.setShakeSensitivity(shakeSensitivity)
        updateSensitivityMenu()
    }

    func displayName(of sensitivity: ShakeSensitivity) -> String {
        switch sensitivity {
        case .veryLow: return "Very low"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very high"
        }
    }

    @objc func gotoNext() {
        navigationController?.pushViewController(SecondViewController(), animated: true)
    }
}

extension UIButton {
    /// rounded button with shadow, used for the example screens
    convenience init(elevatedTitle title: String, backgroundColor: UIColor) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        self.backgroundColor = backgroundColor
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        layer.cornerRadius = 22
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 4
    }
}
