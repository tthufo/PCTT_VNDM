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
    
    @IBOutlet var CDMenu: UIView!

    @IBOutlet var KTMenu: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

       if Information.check != "0" {
          logoLeft.image = UIImage(named: "logo_tc")
       }
           
       if Information.check == "0" {
           headerImg.image = UIImage(named: "bg_text_dms")
       }
        
        typing()
        
//        LDMenu.isHidden = self.isLD() ? false : true
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
//        webView.scrollView.addSubview(refreshControl)
        
//        print(Information.userInfo)
        
        requestDisasterImage()
    }
    
//    func isLD() -> Bool {
//        return Information.userInfo?.getValueFromKey("IsLanhDao") == "1"
//    }
    
    func typing() {
        let key = Information.userInfo?.getValueFromKey("UserType") == "" ? "LoaiTaiKhoan" : "UserType"
        
        if Information.userInfo?.getValueFromKey(key) == "1" {
            LDMenu.isHidden = false
            KTMenu.isHidden = true
            CDMenu.isHidden = true
        }
        if Information.userInfo?.getValueFromKey(key) == "2" {
            LDMenu.isHidden = true
            KTMenu.isHidden = false
            CDMenu.isHidden = true
        }
        if Information.userInfo?.getValueFromKey(key) == "3" {
            LDMenu.isHidden = true
            KTMenu.isHidden = true
            CDMenu.isHidden = false
        }
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
    
    @IBAction func didPressContactEmer() {
     self.navigationController?.pushViewController(Contact_Emer_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressInfo() {
           self.navigationController?.pushViewController(PC_Info_ViewController.init(), animated: true)
          }
    
    @IBAction func didPressFeedBack() {
     self.navigationController?.pushViewController(PC_FeedBack_New_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressEventList() {
     self.navigationController?.pushViewController(PC_List_Event_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressInstruction() {
     self.navigationController?.pushViewController(Instruction_ViewController.init(), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloading()
    }
    
    func reloading() {
        
      let token = Information.userInfo?.getValueFromKey("Token") ?? ""
        
      let param = "http://vndms.gisgo.vn/?cmd=home&token=" + token
                                          
      let link = URL(string: (param as NSString).encodeUrl())!
     
      let request = URLRequest(url: link)
     
      webView.load(request)
 
      current()
    }
    
    func requestDisasterImage() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "CategoryDisasterList"),
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
                          
         for dict in response?.dictionize()["data"] as! [Any] {
             
             let data = dict as! NSDictionary
             
             let stringing = data.getValueFromKey("image")
             
             let imageName = (data.getValueFromKey("name_disaster")!).withoutSpecialCharacters()
             
             if self.existingFileImage(fileName: imageName) {
                 print("===>", imageName)
             } else {
                 if let decodedData = Data(base64Encoded: stringing!),
                    let decodedString = String(data: decodedData, encoding: .utf8) {
                    let dee = decodedString.data(using: .utf8)
                    let namSvgImgVar = SVGKImage.init(data: dee)

                     DispatchQueue.background(background: {
                        self.storeImageToDocumentDirectory(image: (namSvgImgVar?.uiImage)!, fileName: imageName)
                     }, completion:{
                     })
                 }
             }
         }
     })
    }
    
    func storeImageToDocumentDirectory(image: UIImage, fileName: String) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        let fileURL = self.fileURLInDocumentDirectory(fileName)
        do {
            try data.write(to: fileURL)
            print(fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func fileURLInDocumentDirectory(_ fileName: String) -> URL {
        return self.documentsDirectoryURL.appendingPathComponent(fileName)
    }
}
