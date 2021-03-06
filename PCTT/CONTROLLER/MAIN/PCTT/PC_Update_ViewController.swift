//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/18/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Update_ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var tableView: UITableView!
        
    @IBOutlet var headerImg: UIImageView!

    @IBOutlet var logoLeft: UIImageView!
     
    var dataList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        tableView.withCell("PC_Info_Cell")
        
        dataList = NSMutableArray()
        
        if Information.check != "0" {
            logoLeft.image = UIImage(named: "logo_tc")
        }
          
        if Information.check == "0" {
            headerImg.image = UIImage(named: "bg_text_dms")
        }
        
        self.didRequestLayer()
    }
    
    func didRequestLayer() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "manual/layer/"),
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
            
            self.dataList.removeAllObjects()
            
            self.dataList.addObjects(from: result["data"] as! [Any])
            
            self.tableView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
           self.navigationController?.popViewController(animated: true)
       }
}

extension PC_Update_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"PC_Info_Cell", for: indexPath)
              
        let data = dataList![indexPath.row] as! NSDictionary
        
        let image = self.withView(cell, tag: 11) as! UIImageView
        
        image.contentMode = .scaleAspectFit
        
        image.imageUrl(url: data.getValueFromKey("icon_url"))
        
        let title = self.withView(cell, tag: 1) as! UILabel
        
        title.text = data.getValueFromKey("layer_name")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let data = dataList![indexPath.row] as! NSDictionary
        
        var lat = "0"
               
        var lng = "0"

        if (Permission.shareInstance()?.isLocationEnable())! {
           let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
           
           lat = location.getValueFromKey("lat")
           
           lng = location.getValueFromKey("lng")
        }
        
        let map = PC_Inner_Map_ViewController.init()
        
        map.category = ""

        map.directUrl = (data.getValueFromKey("view_url") + (data.getValueFromKey("has_lnglat") == "0" ? "" : "?lon=" + lng + "&lat=" + lat)) as NSString
        
        self.navigationController?.pushViewController(map, animated: true)
    }
}
