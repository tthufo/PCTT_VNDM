//
//  PC_Doc_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/14/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Doc_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func didPressBack() {
           self.view.endEditing(true)
           (self.parent as! PC_Disaster_Tab_ViewController).navigationController?.popViewController(animated: true)
       }

}
