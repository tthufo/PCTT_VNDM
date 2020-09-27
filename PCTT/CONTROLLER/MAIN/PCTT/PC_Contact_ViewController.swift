//
//  PC_Contact_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/10/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Contact_ViewController: ViewPagerController, UITextFieldDelegate {

    var controllers: NSMutableArray!

     var titles = ["BCD TW", "VP BCD TỈNH", "THEO VỊ TRÍ"]

//     @IBOutlet var tableView: UITableView!
        
     @IBOutlet var searchHeight: NSLayoutConstraint!

     @IBOutlet var searchView: UIView!
    
    @IBOutlet var firstNumber: UILabel!

    @IBOutlet var secondNumber: UILabel!

    @IBOutlet var thirdNumber: UILabel!

    @IBOutlet var searchText: UITextField!
    
    var selected: Int = 0

     var hideShow: Bool = false

     var dataList: NSMutableArray!

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
        
        self.topHeight = IS_IPHONE_X() ? "220" : "200"

        controllers = NSMutableArray()

        self.dataSource = self
              
        self.delegate = self
        
        controllers.add(Contact_ViewController.init())

        controllers.add(Contact_ViewController.init())
        
        controllers.add(Contact_ViewController.init())
        
        
        firstNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "0249096747")
        }
        
        secondNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "023456789")
        }
        
        thirdNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "098573689")
        }
        
        requestEvent(index: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        requestEvent()
    }
    
    func requestEvent(index: Int) {
        var lat = "0"
                      
        var lng = "0"

        if (Permission.shareInstance()?.isLocationEnable())! {
           let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
          
           lat = location.getValueFromKey("lat")
          
           lng = location.getValueFromKey("lng")
        }
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "contact?lat=%@&lon=%@&keyword=%@".format(parameters: lat, lng, (searchText.text! as NSString).encodeUrl())),
                                                  "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                  "method":"GET",
                                                  "overrideAlert":"1",
                                                  "overrideLoading":"1",
                                                  "host":self], withCache: { (cacheString) in
      }, andCompletion: { (response, errorCode, error, isValid, object) in
        
          let result = response?.dictionize() ?? [:]
                  
         print(result)
        
          if result.getValueFromKey("status") != "OK" {
              self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
              return
          }
        
        let resulting = result["data"] as! NSDictionary
                  
        (self.controllers![0] as! Contact_ViewController).result = resulting["bcd"] as! NSArray

         (self.controllers![0] as! Contact_ViewController).reloading()
        
        (self.controllers![1] as! Contact_ViewController).result = resulting["tinh"] as! NSArray
//
//        (self.controllers![1] as! Contact_ViewController).reloading()
//
        (self.controllers![2] as! Contact_ViewController).result = resulting["dinh_vi"] as! NSArray
//
//        (self.controllers![2] as! Contact_ViewController).reloading()

        (self.controllers![index] as! Contact_ViewController).reloading()
      })
    }
    
    @IBAction func didPressSearch() {
        searchHeight.constant = !hideShow ? 0 : 70
        searchView.alpha = !hideShow ? 0 : 1
        hideShow = !hideShow
        self.view.endEditing(true)
        searchText.text = ""
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressOffline() {
        self.navigationController?.pushViewController(OffLine_ViewController.init(), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.requestEvent(index: selected)
        return true
    }
    
    func modelLabel(index: Int) -> UILabel {
       let label = UILabel()
       label.backgroundColor = UIColor.clear
       label.text = titles[index]
       label.textAlignment = .center
       label.textColor = UIColor.black
       label.font = UIFont.boldSystemFont(ofSize: 16)
       label.sizeToFit()
       return label
   }
}

extension PC_Contact_ViewController: ViewPagerDelegate, ViewPagerDataSource {
    func numberOfTabs(forViewPager viewPager: ViewPagerController!) -> UInt {
        return UInt(titles.count)
    }
    
    func viewPager(_ viewPager: ViewPagerController!, viewForTabAt index: UInt) -> UIView! {
        return modelLabel(index: Int(index))
    }
    
    func viewPager(_ viewPager: ViewPagerController!, contentViewControllerForTabAt index: UInt) -> UIViewController! {
        return controllers[Int(index)] as! UIViewController
    }
    
    func viewPager(_ viewPager: ViewPagerController!, didChangeTabTo index: UInt) {
        self.selected = Int(index)
        for view in viewPager.tabsView.subviews {
            for tab in view.subviews {
                if (tab as AnyObject).isKind(of: UILabel.self) {
                    (tab as! UILabel).textColor = (viewPager.tabsView.subviews.index(of: view) as! Int) != index ? UIColor.black : AVHexColor.color(withHexString: "#1A6BC7")
                }
            }
        }
    }
    
    func viewPager(_ viewPager: ViewPagerController!, valueFor option: ViewPagerOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .tabWidth {
            return CGFloat((Int(self.screenWidth()) / titles.count))
        } else if option == .tabHeight {
            return 45
        } else if option == .tabLocation {
            return 1
        }
        
        return value
    }
    
    func viewPager(_ viewPager: ViewPagerController!, colorFor component: ViewPagerComponent, withDefault color: UIColor!) -> UIColor! {
        
        if component == .indicator {
            return AVHexColor.color(withHexString: "#1A6BC7")
        } else if component == .tabsView {
            return UIColor.clear
        } else if component == .content {
            return UIColor.gray
        }
        
        return color
    }
}
