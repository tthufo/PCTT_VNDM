//
//  PC_Contact_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/10/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Contact_ViewController: UIViewController, UITextFieldDelegate {

     @IBOutlet var tableView: UITableView!
        
     @IBOutlet var searchHeight: NSLayoutConstraint!

     @IBOutlet var searchView: UIView!
    
    @IBOutlet var firstNumber: UILabel!

    @IBOutlet var secondNumber: UILabel!

    @IBOutlet var thirdNumber: UILabel!

    @IBOutlet var searchText: UITextField!

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
        
          dataList = NSMutableArray.init()
        
          tableView.withCell("PC_Event_Cell")
        
        firstNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "0249096747")
        }
        
        secondNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "023456789")
        }
        
        thirdNumber.action(forTouch: [:]) { (obj) in
            self.callNumber(phoneNumber: "098573689")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestEvent()
    }
    
    func requestEvent() {
        var lat = "0"
                      
        var lng = "0"

        if (Permission.shareInstance()?.isLocationEnable())! {
           let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
          
           lat = location.getValueFromKey("lat")
          
           lng = location.getValueFromKey("lng")
        }
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "contact?lat=%@&lon=%@keyword=%@".format(parameters: lat, lng, searchText.text as! CVarArg)),
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
        
          self.dataList.addObjects(from: response?.dictionize()["data"] as! [Any])
          
          self.tableView.reloadData()
        
        if self.dataList.count == 0 {
            self.showToast("Không có dữ liệu. Mời bạn thử lại sau", andPos: 0)
        }
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
        self.requestEvent()
        return true
    }
}

extension PC_Contact_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"PC_Event_Cell", for: indexPath)
        
        let data = dataList![indexPath.row] as! NSDictionary

        cell.contentView.backgroundColor = .white
        
        let image = self.withView(cell, tag: 11) as! UIImageView

        image.image = UIImage(named: "ic_danhba")
        
        let arr = self.withView(cell, tag: 15) as! UIImageView

        arr.isHidden = false
        
        let title = self.withView(cell, tag: 1) as! UILabel
        
        title.font = UIFont.boldSystemFont(ofSize: 17)
        
        title.textColor = .black
        
        title.text = data["mo_ta"] as? String
        
        let des = self.withView(cell, tag: 2) as! UILabel
        
        des.textColor = .black
        
        des.text = "Điện thoại: " + ((data["sdt"] as? String)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataList![indexPath.row] as! NSDictionary

        self.callNumber(phoneNumber: data.getValueFromKey("sdt"))
    }
}
