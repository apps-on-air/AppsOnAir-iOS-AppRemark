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
    let appsOnAirStateServices = AppRemarkService.shared
  
    override func viewDidLoad() {
        super.viewDidLoad()
       
            
        let button = UIButton(type: .system)
                button.setTitle("Button", for: .normal)
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.cornerRadius = 10
                
                // Set button frame (size and position)
                button.frame = CGRect(x: 100, y: 200, width: 150, height: 50)
                
                // Add target for onPressed (TouchUpInside)
                button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
                
                // Add the button to the view
                self.view.addSubview(button)
          }
    
          // Define the action when button is pressed
           @objc func buttonPressed() {
               // Help to enable remark services where using Options customize the remark screen and customize text and raiseNewTicket is true for opening the remark screen on particular event , without capture screenshot and raiseNewTicket is set to false for only customize the remark screen  and extraPayload is for added custom and additional params.
               appsOnAirStateServices.addRemark(extraPayload: ["XX":"XX"])
           }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
