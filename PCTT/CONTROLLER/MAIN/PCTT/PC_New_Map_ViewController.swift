//
//  PC_New_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/16/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import WebKit

class PC_New_Map_ViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let param = "http://vndms.gisgo.vn/?cmd=home&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImFkbWluIiwibmJmIjoxNTk3MDY3NTIzLCJleHAiOjE1OTc2NzIzMjMsImlhdCI6MTU5NzA2NzUyM30.Gj-prrOXEinRrAm8hCsMvK8N2CKi5T3IGsVJmLaLl8I"
                               
       let link = URL(string: param)!
       let request = URLRequest(url: link)
       webView.load(request)
        // Do any additional setup after loading the view.
    }

    @objc @IBAction func didPressDisaster() {
           self.navigationController?.pushViewController(PC_Disaster_Tab_ViewController.init(), animated: true)
       }
    
    @objc @IBAction func điPressWarning() {
          let map = PC_Inner_Map_ViewController.init()
           map.category = "2"
           self.navigationController?.pushViewController(map, animated: true)
       }
    
    @objc @IBAction func didPressRoot() {
        self.navigationController?.pushViewController(TG_Root_ViewController.init(), animated: true)
       }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
//           swipeToPop()
       }

//       func swipeToPop() {
//           self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
//           self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
//       }
}
