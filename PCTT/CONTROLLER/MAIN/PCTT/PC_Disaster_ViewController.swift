//
//  PC_Disaster_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/11/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Disaster_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
        
    @IBOutlet var disTableView: UITableView!

    @IBOutlet var searchView: UIView!
    
    @IBOutlet var filterView: UIView!
    
    @IBOutlet var coverView: UIView!

    @IBOutlet var searchText: UITextField!
    
    @IBOutlet var yearButton: DropButton!
    
    let refreshControl = UIRefreshControl()

    var year: String = ""
    
    var hideShow: Bool = true

    var dataList: NSMutableArray!

    var dList: NSMutableArray!
    
    let throttler = Throttler(minimumDelay: 0.5)

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
        
      dList = NSMutableArray.init()
    
      tableView.withCell("Disaster_Cell")
        
     disTableView.withCell("Cells")

        tableView.addSubview(refreshControl)
          
      refreshControl.tintColor = UIColor.white
      refreshControl.addTarget(self, action: #selector(requestEvent), for: .valueChanged)
        
      yearButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        yearButton.action(forTouch: [:]) { (obj) in
            self.yearButton.didDropDown(withData: (self.yearNumb() as! [Any])) { (obj) in
                if obj != nil {
                    let object = (obj as! NSDictionary)["data"]
                    self.yearButton.setTitle((object as! NSDictionary).getValueFromKey("title"), for: .normal)
                    self.year = (object as! NSDictionary).getValueFromKey("title")
                    self.requestEvent()
                    self.oMap().year = (object as! NSDictionary).getValueFromKey("title")
                }
            }
        }
        
        searchText.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        requestDisaster()
        
        requestEvent()
    }
    
    func yearNumb() -> NSArray {
        let arr = NSMutableArray.init()
        for i in 2000...Int(getYear())! {
            arr.add(["id": i, "title": String(i)])
        }
        return arr
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        throttler.throttle {
           self.computationallyExpensiveTask()
           self.oMap().keyword = textField.text!
        }
    }

    func computationallyExpensiveTask() {
        requestEvent()
    }
    
   @objc func requestEvent() {

        let condition = self.searchText.hasText || self.year != "" || self.disList().count != 0
        
        let disId: [String] = self.disList().map { objc in
            
            return (objc as! NSDictionary).getValueFromKey("id")
        }
        
        let disaster = self.disList().count == 0 ? "" : disId.joined(separator: ",")
        
        let request = condition ? ("EventDisaster/Filter?keyword=%@&loai_thientai=%@&nam=%@".format(parameters: self.searchText.text!, disaster, self.year) as NSString).encodeUrl() : "EventDisaster"
                
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: request!),
                                                  "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                  "method":"GET",
                                                  "overrideAlert":"1",
                                                  "overrideLoading":"1",
                                                  "host":self], withCache: { (cacheString) in
      }, andCompletion: { (response, errorCode, error, isValid, object) in
        
          let result = response?.dictionize() ?? [:]
                                        
          self.refreshControl.endRefreshing()
        
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
    
    func disList() -> NSArray {
        let dis = dList.filter({
            ($0 as! NSDictionary).getValueFromKey("check") == "1"
        })
        
        return dis as NSArray
    }
    
    func requestDisaster() {

           LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "CategoryDisasterList"),
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
                     
             self.dList.removeAllObjects()
           
            for dict in response?.dictionize()["data"] as! [Any] {
                let modDict = NSMutableDictionary.init(dictionary: (dict as! NSDictionary) )
                (modDict as! NSMutableDictionary)["check"] = "0"
                self.dList.add(modDict)
            }
                         
             self.disTableView.reloadData()
        })
       }
    
    func getYear() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    @IBAction func didPressSearch() {
        hideShow = !hideShow
        self.view.endEditing(true)
        filterView.alpha = hideShow ? 0 : 1
        coverView.isHidden = !hideShow ? false : true
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        (self.parent as! PC_Disaster_Tab_ViewController).navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func oMap() -> PC_Disaster_Map_ViewController {
        return (self.parent as! PC_Disaster_Tab_ViewController).viewControllers?.last as! PC_Disaster_Map_ViewController
    }
}

extension PC_Disaster_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == disTableView ? 44 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == disTableView ? dList.count : dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableView == disTableView ? "Cells" : "Disaster_Cell", for: indexPath)
        
        if tableView != disTableView {
            let data = dataList![indexPath.row] as! NSDictionary
            
            let title = self.withView(cell, tag: 1) as! UILabel
            
            title.text = (data["disaster"] as! NSDictionary).getValueFromKey("name_disaster")

            
            let lab1 = self.withView(cell, tag: 2) as! UILabel
                        
            
            let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
            let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            
            let attributedString = NSMutableAttributedString(string: "Thời gian: ", attributes:attributsBold)
            let boldStringPart = NSMutableAttributedString(string: data.getValueFromKey("time_update_toString"), attributes:attributsNormal)
           attributedString.append(boldStringPart)
        
           lab1.attributedText = attributedString
            
            
            
            
            let lab2 = self.withView(cell, tag: 3) as! UILabel
            
//            lab2.text = "Vị trí: " + data.getValueFromKey("lat") + " - " + data.getValueFromKey("lon")

            let attributedString2 = NSMutableAttributedString(string: "Vị trí: ", attributes:attributsBold)
            let boldStringPart2 = NSMutableAttributedString(string: data.getValueFromKey("lat") + " - " + data.getValueFromKey("lon"), attributes:attributsNormal)
            attributedString2.append(boldStringPart2)
        
            lab2.attributedText = attributedString2
            
            
            
            let lab3 = self.withView(cell, tag: 4) as! UILabel
            
//            lab3.text = "Vùng ảnh hưởng: " + data.getValueFromKey("kv_anhhuong")

            let attributedString3 = NSMutableAttributedString(string: "Vùng ảnh hưởng: ", attributes:attributsBold)
                let boldStringPart3 = NSMutableAttributedString(string: data.getValueFromKey("kv_anhhuong"), attributes:attributsNormal)
                attributedString3.append(boldStringPart3)
            
                lab3.attributedText = attributedString3
            
            
            
            let lab4 = self.withView(cell, tag: 5) as! UILabel
                        
//            lab4.text = "Cấp độ rủi ro thiên tai: " + data.getValueFromKey("level")

            let attributedString4 = NSMutableAttributedString(string: "Cấp độ rủi ro thiên tai: ", attributes:attributsBold)
               let boldStringPart4 = NSMutableAttributedString(string: data.getValueFromKey("level"), attributes:attributsNormal)
               attributedString4.append(boldStringPart4)
           
               lab4.attributedText = attributedString4
            
            
        } else {
            let data = dList![indexPath.row] as! NSMutableDictionary

            let title = self.withView(cell, tag: 101) as! UILabel

            title.textColor = .white
            
            title.text = data.getValueFromKey("name_disaster") + "(" + data.getValueFromKey("TotalDisaster") + ")"
            
            let butt = self.withView(cell, tag: 110) as! UIButton
  
            butt.isHidden = false
            
            butt.action(forTouch: [:]) { (obj) in
                data["check"] = (data["check"] as! String) == "1" ? "0" : "1"
                self.disTableView.reloadData()
                self.requestEvent()
                self.oMap().listtypeid = self.typeId()
            }
            
            butt.setImage(UIImage.init(named: data.getValueFromKey("check") == "0" ? "ic_tick_inactive_white" : "ic_tick_active"), for: .normal)
            
            cell.contentView.backgroundColor = .clear
        }

        return cell
    }
    
    func typeId() -> String {
        let disId: [String] = self.disList().map { objc in
            return (objc as! NSDictionary).getValueFromKey("id")
        }
        
        let type = self.disList().count == 0 ? "" : disId.joined(separator: ",")

        return type
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)

        if tableView == disTableView {
            let data = dList![indexPath.row] as! NSMutableDictionary
            data["check"] = (data["check"] as! String) == "1" ? "0" : "1"
            self.disTableView.reloadData()
            self.requestEvent()
            self.oMap().listtypeid = self.typeId()
        } else {
            let data = dataList![indexPath.row] as! NSDictionary
            self.oMap().eventId = data.getValueFromKey("id")
            self.oMap().layerId = ""
            (self.parent as! PC_Disaster_Tab_ViewController).changeMap()
        }
    }
}

class Throttler {

    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval

    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        // Cancel any existing work item if it has not yet executed
        workItem.cancel()

        // Re-assign workItem with the new block task, resetting the previousRun time when it executes
        workItem = DispatchWorkItem() {
            [weak self] in
            self?.previousRun = Date()
            block()
        }

        // If the time since the previous run is more than the required minimum delay
        // => execute the workItem immediately
        // else
        // => delay the workItem execution by the minimum delay time
        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
    }
}