//
//  TG_Root_ViewController.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Root_ViewController: UITabBarController {

    var line: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let room = PC_Map_ViewController()
        
        let favorite = TG_Intro_ViewController()
        
        let booking = PC_FeedBack_New_ViewController()

        let user = PC_Info_ViewController()
        
        
        self.delegate = self as? UITabBarControllerDelegate
        
        let tab1:UITabBarItem = UITabBarItem(title: "Chức năng", image: UIImage(named: "tab0")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab0"))
        
        tab1.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        room.tabBarItem = tab1
        
        
        let tab2:UITabBarItem = UITabBarItem(title: "Giới thiệu", image: UIImage(named: "tab2")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab2"))
        
        tab2.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        favorite.tabBarItem = tab2
        
        let tab3:UITabBarItem = UITabBarItem(title: "Phản hồi", image: UIImage(named: "tab3")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab3"))
        
        tab3.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        booking.tabBarItem = tab3
        
        let tab4:UITabBarItem = UITabBarItem(title: "Tài khoản", image: UIImage(named: "tab4")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab4"))
        
        tab4.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
        
        user.tabBarItem = tab4
        
        viewControllers = [room, favorite, booking, user];
        
        for item in self.tabBar.items!{
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }
        
        line = UIView.init(frame: CGRect(x: 0, y: 46, width: Int(screenWidth() / 4), height: 4))
        
        line.backgroundColor = UIColor.orange
        
//        self.view.subviews.last?.addSubview(line)
        
        didRefreshUserInfo()
    }

    func didRefreshUserInfo() {
        
//        if !logged() {
//            return
//        }
//        
//        LTRequest.sharedInstance().didRequestInfo(["absoluteLink":"".urlGet(postFix: "api/User/Info"),
//                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
//                                                   "method":"GET",
//                                                   "overrideAlert":"1",
//                                                   "host":self], withCache: { (cache) in
//                                                    
//        }) { (response, errorCode, error, isValid) in
//            
//            if errorCode != "200" {
//                return
//            }
//                        
//            self.add(response?.dictionize().reFormat() as! [AnyHashable : Any], andKey: "info")
//            
//            Information.saveInfo()
//        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        swipeToPop()
    }

    func swipeToPop() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
}

