//
//  PC_Inner_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/11/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import WebKit

class PC_Inner_Map_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var webView: WKWebView!
    
    var category: NSString!
    
    @IBOutlet var headerImg: UIImageView!
    
    var directUrl: NSString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var lat = "0"
               
        var lng = "0"
        
        webView.navigationDelegate = self

        if (Permission.shareInstance()?.isLocationEnable())! {
            let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
           
            lat = location.getValueFromKey("lat")
           
            lng = location.getValueFromKey("lng")
        }
        
        let url = category != "vnmap" ? "http://vndms.gisgo.vn/?cmd=category&values=%@&lat=%@&lng=%@&isAuth=1".format(parameters: category, lat, lng ) : "http://vndms.gisgo.vn/?cmd=%@&values=%@&lat=%@&lng=%@&isAuth=1".format(parameters: "setmap", category, lat, lng )
                        
        let link = URL(string: directUrl != "" ? directUrl as String : url)!
        let request = URLRequest(url: link)
        webView.load(request)
        
//        let backButton = UIButton.init(type: .custom)
//            backButton.setImage(UIImage.init(named: "icon_back"), for: .normal)
//            backButton.frame = CGRect.init(x: 10, y: 10, width: 44, height: 44)
//            webView.addSubview(backButton)
//        backButton.action(forTouch: [:]) { (objc) in
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    @objc @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage.init(named: "icon_back"), for: .normal)
        backButton.frame = CGRect.init(x: 10, y: 10, width: 44, height: 44)
        webView.addSubview(backButton)
        backButton.action(forTouch: [:]) { (objc) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swipeToPop()
    }

    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
}
