//
//  PC_Information_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 9/27/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import WebKit

class PC_Information_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
            
    var result: NSDictionary!
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var headerImg: UIImageView!

     @IBOutlet var logoLeft: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       if Information.check != "0" {
           logoLeft.image = UIImage(named: "logo_tc")
       }
        
       if Information.check == "0" {
           headerImg.image = UIImage(named: "bg_text_dms")
       }
                
        if result != nil {
//            let layers = (result["data"] as! NSDictionary)["listDayVBCDs"]
        }
        
        webView.uiDelegate = self
         
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {

            let link = navigationAction.request.url?.absoluteString
            
//            let link = URL(string: param)!
//
//             let request = URLRequest(url: link)
//
//            print("====", link)
            
            webView.load(navigationAction.request)
            
              if (link!.contains(find: "windy://")) {
                  let tabId = link?.components(separatedBy: "=").last!
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    let disTab = PC_Disaster_Detail_Tab_ViewController.init()
//                    disTab.pointId = tabId!
//                    disTab.requestPointDetail()
//                    self.navigationController?.pushViewController(disTab, animated: true)
                 }
              }
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func reloading() {
        if result != nil {
            let information = (result["data"] as? NSDictionary)!["infor"] as! NSDictionary
            
            print("=====>", information)
            
            let vnName = information.getValueFromKey("name_vn")
                       
           let enName = information.getValueFromKey("name_en")

           var finalName = ""
           
           if vnName != "" && enName != "" {
               finalName = vnName! + "/" + enName!
           }
           
           if vnName == "" && enName != "" {
               finalName = enName!
           }
           
           if vnName != "" && enName == "" {
               finalName = vnName!
           }
           
           if vnName == "" && enName == "" {
               finalName = information.getValueFromKey("name_disaster")
           }
                       
            let des = information.getValueFromKey("description") == "" ? "<br/>" : "Mô tả: %@".format(parameters: information.getValueFromKey("description"))
            
            let link = Information.check == "0" ? "" : "<a href=%@>Xem thêm >>></a>".format(parameters: information.getValueFromKey("link_detail"))
            
            let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
            let body = "Tên: <b>%@</b><br/>Thời gian: <b>%@</b><br/>Khu vực ảnh hưởng: <b>%@</b><br/>Cấp độ rủi ro thiên tai: <b>%@</b><br/>%@<br/>%@".format(parameters:
                finalName,
//                information.getValueFromKey("name_vn"),
                information.getValueFromKey("time_update_toString"),
                information.getValueFromKey("kv_anhhuong"),
                information.getValueFromKey("disaster_level"),
                des, link
            )

            webView.loadHTMLString( headerString + body, baseURL: nil)
            
            
//            dataList.addObjects(from: self.modifying(obj: layers as! NSArray) as! [Any])
        }
    }
    
    @IBAction func didPressBack() {
         (self.parent as! PC_Disaster_Detail_Tab_ViewController).navigationController?.popViewController(animated: true)
     }
}

