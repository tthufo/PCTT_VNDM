//
//  PC_Disaster_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/11/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import WebKit

class PC_Disaster_Map_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var headerImg: UIImageView!

    @IBOutlet var logoLeft: UIImageView!
    
    var year: String = ""
    
    var listtypeid: String = ""
    
    var keyword: String = ""
    
    var eventId: String = ""
    
    var layerId: String = ""
    
    var subLayerId: String = ""

    override func viewDidLoad() {
       super.viewDidLoad()
       
       if Information.check != "0" {
           logoLeft.image = UIImage(named: "logo_tc")
       }
        
       if Information.check == "0" {
           headerImg.image = UIImage(named: "bg_text_dms")
       }
    
       webView.uiDelegate = self
       webView.navigationDelegate = self
        
//       loadWebParam()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadWebParam()
    }
    
    func loadWebParam() {
        
        // type = all,current,list
        // year = 2020
        // listtypeid = 1,2,3 bão,lũ, đ
        // &id=xxxx
        // &layerids=l1,l2
        // keyword
        
        let type = year != "" || listtypeid != "" || keyword != "" ? "list" : "current"
        
        let param = "http://vndms.gisgo.vn/?cmd=disaster&type=%@&year=%@&listtypeid=%@&subLayerId=%@&id=%@&layerids=%@&token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6ImFkbWluIiwibmJmIjoxNTk3MDY3NTIzLCJleHAiOjE1OTc2NzIzMjMsImlhdCI6MTU5NzA2NzUyM30.Gj-prrOXEinRrAm8hCsMvK8N2CKi5T3IGsVJmLaLl8I&keyword=%@".format(parameters: type, year, listtypeid, subLayerId, eventId, layerId, keyword)
        
//        print(param)
        
        let link = URL(string: (param as NSString).encodeUrl())!
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {

            let link = navigationAction.request.url?.absoluteString
            
              if (link!.contains(find: "windy://")) {
                  let tabId = link?.components(separatedBy: "=").last!
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let disTab = PC_Disaster_Detail_Tab_ViewController.init()
                    disTab.pointId = tabId!
                    disTab.requestPointDetail()
                    self.navigationController?.pushViewController(disTab, animated: true)
                 }
              }
            
            decisionHandler(.cancel)
            return
        }
//        print("no link")
        decisionHandler(.allow)
    }
}
