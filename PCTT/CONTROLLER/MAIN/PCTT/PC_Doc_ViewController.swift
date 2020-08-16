//
//  PC_Doc_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/14/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Doc_ViewController: UIViewController {

    var pointId: String = ""

    @IBOutlet var tableView: UITableView!
        
    var dataList: NSMutableArray!
    
    var result: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataList = NSMutableArray.init()
        
        if result != nil {
            let layers = (result["data"] as! NSDictionary)["listDayVBCDs"]
                            
            dataList.addObjects(from: self.modifying(obj: layers as! NSArray) as! [Any])
        }
        
        tableView.withCell("Report_Cell")
    }
    
    func reloading() {
        if result != nil {
            let layers = (result["data"] as! NSDictionary)["listDayVBCDs"]
                            
            dataList.addObjects(from: self.modifying(obj: layers as! NSArray) as! [Any])
        }
        
        tableView.reloadData()
    }

    func modifying(obj: NSArray) -> NSMutableArray {
        let arr = NSMutableArray.init()
        for dict in obj.withMutable() {
            (dict as! NSMutableDictionary)["check"] = "0"
            let layer = NSMutableArray.init()
            if let array = (dict as! NSMutableDictionary)["datas"] as? NSArray {
                for k in array.withMutable() {
                      (k as! NSMutableDictionary)["check"] = "0"
                      layer.add(k)
                  }
            }
            (dict as! NSMutableDictionary)["datas"] = layer
            arr.add(dict)
        }
                
        return arr
    }
    
    @IBAction func didPressBack() {
         (self.parent as! PC_Disaster_Detail_Tab_ViewController).navigationController?.popViewController(animated: true)
     }
}

extension PC_Doc_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("Layer_Header", owner: self, options: nil)![0]
        
        let data = dataList![section] as! NSMutableDictionary

        let title = self.withView(header, tag: 1) as! UILabel
        
        title.text = data.getValueFromKey("day")
        
        let check = self.withView(header, tag: 2) as! UIImageView

        check.image = UIImage.init(named: data.getValueFromKey("check") == "0" ? "ic_menu_down" : "ic_menu_up")

        (header as! UIView).action(forTouch: [:]) { (obj) in
            data["check"] = data.getValueFromKey("check") == "1" ? "0" : "1"
            self.tableView.reloadData(withAnimation: true)
        }
        
        return (header as? UIView)!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = dataList![section] as! NSDictionary
        
        return data.getValueFromKey("check") == "1" ? 0 : (data["datas"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Report_Cell", for: indexPath)
        
        let data = dataList![indexPath.section] as! NSMutableDictionary
        
        let value = data["datas"] as! NSArray
        
        let lay = value[indexPath.row] as! NSDictionary
        
        
        let title = self.withView(cell, tag: 1) as! UILabel

        title.text = lay["name_file_display"] as? String

        
        let update = self.withView(cell, tag: 2) as! UILabel

        update.text = "Người cập nhật: " + ((lay["userModel"] as? NSDictionary)?.getValueFromKey("UserName"))!

        let date = self.withView(cell, tag: 3) as! UILabel

        date.text = "Thời gian cập nhật: " + (lay["time_update_toString"] as! String) + " " + (lay["date_update_toString"] as! String)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let data = ((dataList![indexPath.section] as! NSMutableDictionary)["layerDatas"] as! NSArray)[indexPath.row] as! NSMutableDictionary
//
//        data["check"] = data.getValueFromKey("check") == "1" ? "0" : "1"
//
//        self.lastView().setMap(subLayerId: self.getSubLay(obj: dataList), layerId: self.getLay(obj: dataList))
//
//        tableView.reloadData()
    }
    
//    func getSubLay(obj: NSArray) -> String {
//        let layer = NSMutableArray.init()
//       for dict in obj.withMutable() {
//           for k in ((dict as! NSMutableDictionary)["layerDatas"] as! NSArray).withMutable() {
//            if (k as! NSMutableDictionary).getValueFromKey("check") == "1" {
//                layer.add((k as! NSMutableDictionary).getValueFromKey("id") as Any)
//            }
//           }
//       }
//
//        return layer.componentsJoined(by: ",")
//    }
//
//    func getLay(obj: NSArray) -> String {
//        let layer = NSMutableArray.init()
//       for dict in obj.withMutable() {
//           for k in ((dict as! NSMutableDictionary)["layerDatas"] as! NSArray).withMutable() {
//            if (k as! NSMutableDictionary).getValueFromKey("check") == "1" {
//                layer.add((dict as! NSMutableDictionary).getValueFromKey("id"))
//                break
//            }
//           }
//       }
//
//        return layer.componentsJoined(by: ",")
//    }
//    
//    func lastView() -> PC_Disaster_Tab_ViewController {
//        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
//             let viewController = navController.viewControllers[navController.viewControllers.count - 2]
//            return viewController as! PC_Disaster_Tab_ViewController
//        }
//        return PC_Disaster_Tab_ViewController.init()
//    }
}

