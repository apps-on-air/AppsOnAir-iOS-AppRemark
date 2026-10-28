//
//  SecondViewController.swift
//  AppsOnAir-AppRemark
//

import UIKit
import AppsOnAir_AppRemark

class SecondViewController: UIViewController {
    let appRemarkService = AppRemarkService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let remarkButton = UIButton(elevatedTitle: "Create new remark", backgroundColor: .green)
        remarkButton.addTarget(self, action: #selector(createNewRemark), for: .touchUpInside)
        remarkButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(remarkButton)
        NSLayoutConstraint.activate([
            remarkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            remarkButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc func createNewRemark() {
        //with extra payload
        appRemarkService.setAdditionalMetaData(extraPayload: [
            "title": "Initial Test Demo addRemark",
            "isFromIndia": false
        ])
        appRemarkService.addRemark()

        //without extra payload
        //appRemarkService.addRemark()
    }
}
