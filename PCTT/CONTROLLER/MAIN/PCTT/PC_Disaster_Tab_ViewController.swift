//
//  PC_Disaster_Tab_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/11/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Disaster_Tab_ViewController: UITabBarController {

    var line: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let list = PC_Disaster_ViewController.init()
        
        let map = PC_Disaster_Map_ViewController.init()

        self.delegate = self as? UITabBarControllerDelegate

        let tab1:UITabBarItem = UITabBarItem(title: "Danh sách", image: UIImage(named: "tab5")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab5"))

        tab1.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

        list.tabBarItem = tab1


        let tab2:UITabBarItem = UITabBarItem(title: "Bản đồ", image: UIImage(named: "tab6")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab6"))

        tab2.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

        map.tabBarItem = tab2

//        let tab3:UITabBarItem = UITabBarItem(title: "Phản hồi", image: UIImage(named: "tab3")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab3"))
//
//        tab3.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
//
//        booking.tabBarItem = tab3
//
//        let tab4:UITabBarItem = UITabBarItem(title: "Tài khoản", image: UIImage(named: "tab4")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab4"))
//
//        tab4.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)
//
//        user.tabBarItem = tab4
//
        viewControllers = [list, map];
//
        for item in self.tabBar.items!{
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            item.image = item.image?.withRenderingMode(.alwaysOriginal)
        }

        line = UIView.init(frame: CGRect(x: 0, y: 46, width: Int(screenWidth() / 4), height: 4))

        line.backgroundColor = UIColor.orange
    }

    func changeMap() {
        self.selectedIndex = 1
    }
    
    func setMap(subLayerId: String, layerId: String) {
        (self.viewControllers?.last as! PC_Disaster_Map_ViewController).layerId = layerId
        (self.viewControllers?.last as! PC_Disaster_Map_ViewController).subLayerId = subLayerId
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

