//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Map_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerImg: UIImageView!
    
    var dataList: NSMutableArray = [["title": "Quan trắc", "img": "ic_quantrac", "category": "1"],
                                    ["title": "Cảnh báo", "img": "ic_canhbao", "category": "2"],
                                    ["title": "GS Hồ chứa", "img": "ic_hochua", "category": "4"],
                                    ["title": "GS Đê điều", "img": "ic_dedieu", "category": "5"],
                                    ["title": "GS tầu thuyền", "img": "ic_tauthuyen", "category": "6"],
                                    ["title": "Đường đi bão", "img": "ic_duongdibao", "category": "3"],
                                    ["title": "Hình ảnh T.Tai", "img": "ic_hathientai"],
                                    ["title": "Bản đồ nền", "img": "ic_bandonen", "category": "vnmap"],
                                    ["title": "Hỏi & đáp", "img": "ic_hoidap"],
                                    ["title": "Đ.điểm Y.thích", "img": "yeu_thich"]
    ]
    
     @IBOutlet var logoLeft: UIImageView!
       
       override func viewDidLoad() {
       super.viewDidLoad()
       
       if Information.check != "0" {
           logoLeft.image = UIImage(named: "logo_tc")
       }
        collectionView.withCell("TG_Map_Cell")
        
        Permission.shareInstance()?.initLocation(false, andCompletion: { (permissionType) in
            
        })
        if Information.check == "0" {
            headerImg.image = UIImage(named: "bg_text_dms")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        swipeToPop()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func swipeToPop() {

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((self.screenWidth() / 3) - 15), height: Int((self.screenWidth() / 3) + 20))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TG_Map_Cell", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary
        
        let title = self.withView(cell, tag: 12) as! UILabel

        title.text = data.getValueFromKey("title")
        
        let image = self.withView(cell, tag: 11) as! UIImageView
        
        image.image = UIImage(named: "%@".format(parameters: data.getValueFromKey("img")))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        switch indexPath.item {
//        case 0:
//
//            break
//        case 6:
//
//        break
//        case 8:
//
//            break
//        default:
//            break
//        }
        
        let data = dataList[indexPath.item] as! NSDictionary
        
        if indexPath.item == 8 {
            let question = TG_Intro_ViewController.init()
            question.isIntro = false
            self.navigationController?.pushViewController(question, animated: true)
        } else if indexPath.item == 6 {
            let event = PC_List_Event_ViewController.init()
            self.navigationController?.pushViewController(event, animated: true)
        } else if indexPath.item == 9 {
            let map = AP_Map_ViewController.init()
            self.navigationController?.pushViewController(map, animated: true)
        } else {
            let map = PC_Inner_Map_ViewController.init()
            map.category = data.getValueFromKey("category") as NSString?
            self.navigationController?.pushViewController(map, animated: true)
        }
    }
}
