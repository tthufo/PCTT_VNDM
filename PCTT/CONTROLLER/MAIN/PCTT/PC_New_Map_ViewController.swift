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
    
    @IBOutlet var badge: UILabel!

    @IBOutlet var logoLeft: UIImageView!
          
    @IBOutlet var headerImg: UIImageView!

    @IBOutlet var LDMenu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Information.check != "0" {
              logoLeft.image = UIImage(named: "logo_tc")
          }
           
       if Information.check == "0" {
           headerImg.image = UIImage(named: "bg_text_dms")
       }
        
        LDMenu.isHidden = self.isLD() ? false : true
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
//        webView.scrollView.addSubview(refreshControl)
        
        print(Information.userInfo)
        
    }
    
    func isLD() -> Bool {
        return Information.userInfo?.getValueFromKey("IsLanhDao") == "1"
    }
    
    func current() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "EventDisaster"),
                                                         "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                         "method":"GET",
                                                         "overrideAlert":"1",
                                                         "overrideLoading":"1",
                                                         "host":self], withCache: { (cacheString) in
             }, andCompletion: { (response, errorCode, error, isValid, object) in
               
                 let result = response?.dictionize() ?? [:]
                                                              
                 if result.getValueFromKey("status") != "OK" {
                     self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                     return
                 }
      
                let current = response?.dictionize()["data"] as! [Any]
                
                if current.count != 0 {
                    self.badge.isHidden = false
                    self.badge.text = "%i".format(parameters: current.count)
                } else {
                    self.badge.isHidden = true
                }
             })
    }

    @IBAction func didPressDisaster() {
           self.navigationController?.pushViewController(PC_Disaster_Tab_ViewController.init(), animated: true)
       }
    
    @IBAction func điPressWarning() {
          let map = PC_Inner_Map_ViewController.init()
           map.category = "2"
           self.navigationController?.pushViewController(map, animated: true)
       }
    
    @IBAction func didPressRoot() {
        self.navigationController?.pushViewController(TG_Root_ViewController.init(), animated: true)
       }

    
    @IBAction func didPressContact() {
           self.navigationController?.pushViewController(PC_Contact_ViewController.init(), animated: true)
          }
    
    @IBAction func didPressInfo() {
           self.navigationController?.pushViewController(PC_Info_ViewController.init(), animated: true)
          }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloading()
    }
    
    func reloading() {
      let param = "http://vndms.gisgo.vn/?cmd=home&token=" + (FirePush.shareInstance()?.deviceToken())!
                                          
      let link = URL(string: param)!
     
      let request = URLRequest(url: link)
     
      webView.load(request)
 
      current()
    }
}
