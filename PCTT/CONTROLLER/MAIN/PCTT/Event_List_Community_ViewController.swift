//
//  PC_List_Event_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/18/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Event_List_Community_ViewController: UIViewController {

     @IBOutlet var tableView: UITableView!
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestEvent()
    }
    
    func requestDeleteEvent(id: String) {
      LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "event/delete/" + id),
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
          
          self.requestEvent()
      })
    }
    
    func requestEvent() {
      LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "event"),
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
    
    @IBAction func didPressFAQ() {
        self.navigationController?.pushViewController(Event_Upload_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressOffline() {
        self.navigationController?.pushViewController(OffLine_ViewController.init(), animated: true)
    }
}


extension Event_List_Community_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"PC_Event_Cell", for: indexPath)
        
        let data = dataList![indexPath.row] as! NSDictionary

        
        let image = self.withView(cell, tag: 11) as! UIImageView

        image.image = UIImage(named: "event")
        
        let title = self.withView(cell, tag: 1) as! UILabel
        
        title.text = data["event_name"] as? String
        
        let des = self.withView(cell, tag: 2) as! UILabel
        
        des.text = data["event_description"] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataList![indexPath.row] as! NSDictionary

        DropAlert.shareInstance()?.alert(withInfor: ["title":"Thông báo", "message": "Bạn có chắc chắn muốn xóa sự kiện " + data.getValueFromKey("event_name"), "buttons": ["Có"], "cancel":"Không"], andCompletion: { (index, obj) in
            
            if index == 0 {
                self.requestDeleteEvent(id: data.getValueFromKey("id"))
            }
        })
    }
}
