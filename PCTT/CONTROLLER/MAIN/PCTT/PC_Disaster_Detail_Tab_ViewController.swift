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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let doc = PC_Doc_ViewController.init()
        
        let info = PC_Doc_ViewController.init()

        self.delegate = self as? UITabBarControllerDelegate

        let tab1:UITabBarItem = UITabBarItem(title: "Văn bản", image: UIImage(named: "tab7")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab7"))

        tab1.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

        doc.tabBarItem = tab1


        let tab2:UITabBarItem = UITabBarItem(title: "TT dự", image: UIImage(named: "tab8")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab8"))

        tab2.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

        info.tabBarItem = tab2
        
        
        let tab3:UITabBarItem = UITabBarItem(title: "Lớp", image: UIImage(named: "tab9")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab9"))

               tab3.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

               info.tabBarItem = tab3
        
        let tab4:UITabBarItem = UITabBarItem(title: "Báo cáo", image: UIImage(named: "tab10")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab10"))

                      tab4.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

                      info.tabBarItem = tab4
        
        let tab5:UITabBarItem = UITabBarItem(title: "HD ứng", image: UIImage(named: "tab11")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal).alpha(0.5), selectedImage: UIImage(named: "tab11"))

                      tab5.imageInsets = UIEdgeInsets(top: -5, left: 0, bottom: 5, right: 0)

                      info.tabBarItem = tab5
        
        

        viewControllers = [doc, info, info, info, info];

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

