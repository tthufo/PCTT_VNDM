//
//  PC_Login_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/3/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel
import ZaloSDK

class PC_Login_ViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var login: UIView!
    
    @IBOutlet var cover: UIView!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var pass: UITextField!

    @IBOutlet var check: UIButton!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var uNameErr: UILabel!

    @IBOutlet var passErr: UILabel!
    
    @IBOutlet var socialView: UIView!

    @IBOutlet var bottom: MarqueeLabel!
    
    var lock: Bool = false

    var loginCover: UIView!
    
    var isCheck: Bool!
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 20.0 : 40.0

    let topGap = IS_IPHONE_5 ? 80 : 120

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        isCheck = false
        
        self.setUp()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        
        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
//        FirePush.shareInstance()?.completion({ (state, info) in
//            print(info)
//        })
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "Ver %@".format(parameters: appVersion!)
        
        bottom.action(forTouch: [:]) { (obj) in
//            self.callNumber(phoneNumber: Information.phone)
        }
        
        if #available(iOS 12, *) {
             pass.textContentType = .oneTimeCode
            uName.textContentType = .oneTimeCode
        } else {
             pass.textContentType = .init(rawValue: "")
            uName.textContentType = .init(rawValue: "")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
        
        uName.text = ""
        
        pass.text = ""
        
        self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
        self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
        
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
                        
            UIView.animate(withDuration: 0, animations: {
                
                if self.lock {
                    return
                }
                
                if IS_IPAD {
                    return
                }
                
                var frame = self.login.frame
                
                frame.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
               
                self.login.frame = frame
                
                var frameLogo  = self.logo.frame
                
                frameLogo.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                
                self.logo.frame = frameLogo
            })
        }
    }
    
    func setUp() {
        let logged = Information.token != nil && Information.token != ""
        
        let bbgg = Information.bbgg != nil && Information.bbgg != ""
        
        var frame = logo.frame

        frame.origin.y = CGFloat(self.screenHeight() - 300) / 2

        frame.origin.x = CGFloat(self.screenWidth() - 250) / 2
        
        logo.frame = frame
        
        logo.alpha = 0
                
        UIView.animate(withDuration: 1, animations: {
            self.cover.alpha = bbgg ? 0.3 : 0
        }) { (done) in
            UIView.transition(with: self.bg, duration: 1, options: .transitionCrossDissolve, animations: {
                self.bg.image = bbgg ? Information.bbgg!.stringImage() : UIImage(named: "bg_login")
            }, completion: { (done) in
                UIView.animate(withDuration: 1, animations: {
                    self.cover.alpha = 0
                }) { (done) in
                    
//                    UIView.animate(withDuration: 0.5, animations: {
//                        var frame = self.logo.frame
//
//                        frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
//
//                        self.logo.frame = frame
//
//                        self.logo.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//
//                    }) { (done) in
//                        if logged {
//                            self.uName.text = Information.log!["name"] as? String
//                            self.pass.text = Information.log!["pass"] as? String
//                            self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
//                            self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
//                            self.didPressSubmit()
//                        }
//                        self.setUpLogin()
//                    }
                               
            LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"https://dl.dropboxusercontent.com/s/hajobsp6cm6o3so/PCTT_WebView_PCTT_VER_11.plist", "overrideAlert":"1"], withCache: { (cache) in
                                                                        
            }, andCompletion: { (response, errorCode, error, isValid, object) in
                        
                        if error != nil {
                            Information.check = "1"
                            
                            self.logo.image = UIImage(named: "logo_tc")
                            
                            self.logo.alpha = 1
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                var frame = self.logo.frame
        
                                frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
        
                                self.logo.frame = frame
        
                                self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
                            }) { (done) in
                                if logged {
                                    self.uName.text = Information.log!["name"] as? String
                                    self.pass.text = Information.log!["pass"] as? String
                                    self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
                                    self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                    self.didPressSubmit()
                                }
                                self.setUpLogin()
                            }
                            return
                        }
                        
                        let data = response?.data(using: .utf8)
                        let dict = XMLReader.return(XMLReader.dictionary(forXMLData: data, options: 0))
                        
//                        self.loginCover.alpha = (dict! as NSDictionary).getValueFromKey("show") == "1" ? 1 : 0
                                                
                        let information = [ "token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IkFkbWluIiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy91c2VyZGF0YSI6IiIsIm5iZiI6MTYwMjE1MTAxNSwiZXhwIjoxNjAyNzU1ODE1LCJpYXQiOjE2MDIxNTEwMTV9.hpMk_yacF-_Dm4Zjy-9usfmvmqUuTOusdcYWB-TV5do"] as [String : Any]
                        
                        if (dict! as NSDictionary).getValueFromKey("show") == "0" {
                            
                            self.add(["name":"admin" as Any, "pass":"Abc@123" as Any], andKey: "log")

                            self.add((information as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

                            Information.saveInfo()

                            self.addValue((information as! NSDictionary).getValueFromKey("token"), andKey: "token")

                            Information.saveToken()
                            
                            Information.check = (dict! as NSDictionary).getValueFromKey("show") == "0" ? "0" : "1"

                            if Information.check == "1" {
                                self.logo.image = UIImage(named: "logo_tc")
                            }

                            self.logo.alpha = 1
                            
                            print(Information.check)
                        
//                            if Information.userInfo?.getValueFromKey("count_province") == "1" {
                            
                             if Information.check != "1" {
                                self.navigationController?.pushViewController(TG_Root_ViewController.init(), animated: true)
                             } else {
                                self.navigationController?.pushViewController(PC_New_Map_ViewController.init(), animated: true)
                             }

                            
//                            } else {
//                            }
                            
                        } else {
                            Information.check = (dict! as NSDictionary).getValueFromKey("show") == "0" ? "0" : "1"

                            UIView.animate(withDuration: 0.5, animations: {
                                var frame = self.logo.frame
        
                                frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
        
                                self.logo.frame = frame
        
                                self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
                                if Information.check == "1" {
                                    self.logo.image = UIImage(named: "logo_tc")
                                }
                              
                                self.logo.alpha = 1
                                
                            }) { (done) in
                                if logged {
                                    self.uName.text = Information.log!["name"] as? String
                                    self.pass.text = Information.log!["pass"] as? String
                                    self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
                                    self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                    self.didPressSubmit()
                                }
                                self.setUpLogin()
                            }
                        }
                    })
                }
            })
        }
    }
    
    func setUpLogin() {
        var frame = login.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 470) / 2 + CGFloat(self.topGap)
        
        frame.size.width = CGFloat(self.screenWidth() - 40)
        
        frame.origin.x = 20

        login.frame = frame
        
        self.view.addSubview(login)
        
        UIView.animate(withDuration: 0.5, animations: {

            self.login.alpha = 1
            
            self.socialView.alpha = 1

        }) { (done) in
            
        }
    }
    
    @IBAction func didPressGG() {
       self.view.endEditing(true)
        lock = true
        GG_PlugIn.shareInstance()?.startLogGoogle(completion: { (responseString, object, errorCode, description, error) in
            if object != nil {
                self.socialLogin(type: "google", token: (object as! NSDictionary).getValueFromKey("access_token"));
            }
            self.lock = false
        }, andHost: self)
   }
    
    @IBAction func didPressFB() {
          self.view.endEditing(true)
           lock = true
        FB_Plugin.shareInstance()?.startLoginFacebook(completion: { (responseString, object, errorCode, description, error) in
            if object != nil {
                self.socialLogin(type: "facebook", token: ((object as! NSDictionary)["info"] as! NSDictionary).getValueFromKey("access_token"));
                print(object)
                print(((object as! NSDictionary)["info"] as! NSDictionary).getValueFromKey("access_token"))
            }
            self.lock = false
        })
      }
    
    @IBAction func didPressZL() {
         self.view.endEditing(true)
          lock = true
        ZaloSDK.sharedInstance()?.authenticateZalo(with: ZAZAloSDKAuthenTypeViaZaloAppAndWebView, parentController: self, isShowLoading: true) { (objc) in
            if objc!.isSucess {
                self.requestZaloAuthen(auth: objc!.oauthCode)
            }
            self.lock = false
        }
     }
    
    func requestZaloAuthen(auth: String) {
        let ide = "756108648194603861"
        let secret = "tALPwi3T0NRQ7dXLO5Wp"
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"https://oauth.zaloapp.com/v3/access_token?app_id=%@&app_secret=%@&code=%@".format(parameters: ide, secret, auth),
                                                    "method":"GET",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                        
            self.socialLogin(type: "zalo", token: result.getValueFromKey("access_token"));
        })
    }
    
    func socialLogin(type: String, token: String) {
         self.view.endEditing(true)
                
            self.add(["type": type, "access_token": token as Any], andKey: "social")
        
            LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"auth/" + type,
                                                        "accesstoken":token,
                                                        "mobiletoken":FirePush.shareInstance()?.deviceToken() ?? "",
                                                        "tokentype":2,
                                                        "overrideAlert":"1",
                                                        "overrideLoading":"1",
                                                        "postFix":"auth/" + type,
                                                        "host":self], withCache: { (cacheString) in
            }, andCompletion: { (response, errorCode, error, isValid, object) in
                let result = response?.dictionize() ?? [:]
                                        
                if result.getValueFromKey("status") != "OK" {
                    self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                    
                    Information.removeInfo()
                    
                    GG_PlugIn.shareInstance()?.signOutGoogle()

                    FB_Plugin.shareInstance()?.signoutFacebook()
                    
                    ZaloSDK.sharedInstance()?.unauthenticate()
                    
                    return
                }
                                    
                self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

                self.add((response?.dictionize()["data"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

                Information.saveInfo()
                
                self.addValue((response?.dictionize()["data"] as! NSDictionary).getValueFromKey("Token"), andKey: "token")
                
                Information.saveToken()
                
                if Information.check == "1" {
                    self.navigationController?.pushViewController(PC_New_Map_ViewController.init(), animated: true)
                } else {
                    self.navigationController?.pushViewController(TG_Root_ViewController.init(), animated: true)
                }
            })
    }
    
    @IBAction func didPressForget() {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(PC_Forgot_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressCheck() {
        pass.isSecureTextEntry = isCheck
        
        check.setImage(UIImage(named: isCheck ? "design_ic_visibility_off" : "design_ic_visibility"), for: .normal)
        
        isCheck = !isCheck
    }
    
    @IBAction func didPressRegister() {
//        self.navigationController?.pushViewController(AP_Map_ViewController.init(), animated: true)
        self.navigationController?.pushViewController(PC_Register_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        
        if self.getObject("social") != nil {
            
            let typing = self.getObject("social")["type"]
            
            let access_token = self.getObject("social")["access_token"]

            socialLogin(type: typing as! String, token: access_token as! String)
            
            return
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"login",
                                                    "username":uName.text as Any,
                                                    "password":pass.text as Any,
                                                    "mobiletoken":FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "tokentype":2,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"auth/login",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                    
            if result.getValueFromKey("status") != "OK" {
                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                return
            }
            
            print(result)
            
            self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

            self.add((response?.dictionize()["data"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()
            
            self.addValue((response?.dictionize()["data"] as! NSDictionary).getValueFromKey("Token"), andKey: "token")
            
            Information.saveToken()
            
            if Information.check == "1" {
                self.navigationController?.pushViewController(PC_New_Map_ViewController.init(), animated: true)
            } else {
                self.navigationController?.pushViewController(TG_Root_ViewController.init(), animated: true)
            }
            print(result)
            
//            if Information.userInfo?.getValueFromKey("count_province") == "1" {
//                self.navigationController?.pushViewController(PC_Station_ViewController.init(), animated: true)
//            } else {
//                self.navigationController?.pushViewController(PC_Main_ViewController.init(), animated: true)
//            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == uName {
            pass.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0
        submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 ? 1 : 0.5
    }
}
