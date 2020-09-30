//
//  PC_Disaster_Detail_Tab_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Disaster_Detail_Tab_ViewController: UITabBarController {

    var line: UIView!
    
    var pointId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let information = PC_Information_ViewController.init()

        let doc = PC_Doc_ViewController.init()
        
        let info = PC_Project_ViewController.init()

        let layer = PC_Layer_ViewController.init()
        
        layer.pointId = pointId

        let report = PC_Report_ViewController.init()

        let hd = PC_HD_ViewController.init()

        self.delegate = self as? UITabBarControllerDelegate

        
        
        let tab0:UITabBarItem = UITabBarItem(title: "Thông tin", image: UIImage(named: "tab8")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab8"))

        tab0.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

        information.tabBarItem = tab0

        
        
        
        let tab1:UITabBarItem = UITabBarItem(title: "Văn bản", image: UIImage(named: "tab7")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab7"))

        tab1.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

        doc.tabBarItem = tab1


        let tab2:UITabBarItem = UITabBarItem(title: "TT dự", image: UIImage(named: "tab8")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab8"))

        tab2.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

        info.tabBarItem = tab2
        
        
        let tab3:UITabBarItem = UITabBarItem(title: "Lớp", image: UIImage(named: "tab9")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab9"))

               tab3.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

               layer.tabBarItem = tab3
        
        let tab4:UITabBarItem = UITabBarItem(title: "Báo cáo", image: UIImage(named: "tab10")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab10"))

                      tab4.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

                      report.tabBarItem = tab4
        
        let tab5:UITabBarItem = UITabBarItem(title: "HD ứng", image: UIImage(named: "tab11")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab11"))

                      tab5.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)

                      hd.tabBarItem = tab5
        
        

        viewControllers = Information.check != "0" ? [information, doc, info, layer, report, hd] : [information];
        
        for item in self.tabBar.items!{
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }

        line = UIView.init(frame: CGRect(x: 0, y: 46, width: Int(screenWidth() / 4), height: 4))

        line.backgroundColor = UIColor.orange
        
        requestPointDetail()
    }
    
    override var traitCollection: UITraitCollection {
        let realTraits = super.traitCollection
        let fakeTraits = UITraitCollection(horizontalSizeClass: .regular)
        return UITraitCollection(traitsFrom: [realTraits, fakeTraits])
    }
    
    func requestPointDetail() {
        if self.pointId == "" {
            return
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "EventDisaster/%@".format(parameters: self.pointId ?? "")),
                                                     "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                     "method":"GET",
                                                     "overrideAlert":"1",
                                                     "overrideLoading":"1",
                                                     "host":self], withCache: { (cacheString) in
         }, andCompletion: { (response, errorCode, error, isValid, object) in
           
             let result = response?.dictionize() ?? [:]
            
             if response == nil || result.getValueFromKey("status") != "OK" {
                 self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                 return
             }
            
            (self.viewControllers![0] as! PC_Information_ViewController).result = result

            (self.viewControllers![0] as! PC_Information_ViewController).reloading()
                                 
            if Information.check != "0" {
                (self.viewControllers![3] as! PC_Layer_ViewController).result = result

                (self.viewControllers![1] as! PC_Doc_ViewController).result = result

    //            (self.viewControllers![1] as! PC_Doc_ViewController).reloading()
                
                (self.viewControllers![2] as! PC_Project_ViewController).result = result

                (self.viewControllers![4] as! PC_Report_ViewController).result = result

                (self.viewControllers![5] as! PC_HD_ViewController).result = result
            }

         })
       }

    func changeMap() {
        self.selectedIndex = 1
    }
    
    func rootSelect(index: Int) {
        self.selectedIndex = index
        
        changePos(pos: index)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let items = tabBar.items {
            items.enumerated().forEach { if $1 == item {
                    self.changePos(pos: $0)
                }
            }
        }
    }
    
    func changePos(pos: Int) {
        UIView.animate(withDuration: 0.3, animations: {
            var rect = self.line.frame
            rect.origin.x = CGFloat((Int(self.screenWidth() / 4) * pos))
            self.line.frame = rect
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

