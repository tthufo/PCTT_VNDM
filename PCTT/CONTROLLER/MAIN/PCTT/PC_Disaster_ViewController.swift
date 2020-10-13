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

    var dList: NSMutableArray = NSMutableArray()
    
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
        
//      dList = NSMutableArray.init()
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !hideShow {
            didPressSearch()
        }
    }
    
    func updateFilter(array1: NSMutableArray) {
       let bond = dList.count != array1.count
       dList = array1
       disTableView.reloadData()
       requestEvent(loading: bond)
    }
    
    func yearNumb() -> NSArray {
        let arr = NSMutableArray.init()
        var x = Int(getYear())!
        repeat {
            arr.add(["id": x, "title": String(x)])
            x-=1
        } while(x >= 2015)
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
    
    @objc func requestEvent(loading: Bool = true) {

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
                                                  "host": loading ? self : (Any).self], withCache: { (cacheString) in
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
                
                let data = dict as! NSDictionary
                
                let stringing = data.getValueFromKey("image")
                
                let imageName = (data.getValueFromKey("name_disaster")!).withoutSpecialCharacters()
                
                if self.existingFileImage(fileName: imageName) {
                    print("===>", imageName)
                } else {
                    if let decodedData = Data(base64Encoded: stringing!),
                       let decodedString = String(data: decodedData, encoding: .utf8) {
                       let dee = decodedString.data(using: .utf8)
                       let namSvgImgVar = SVGKImage.init(data: dee)

                        DispatchQueue.background(background: {
                           self.storeImageToDocumentDirectory(image: (namSvgImgVar?.uiImage)!, fileName: imageName)
                        }, completion:{
                        })
                    }
                }
                let modDict = NSMutableDictionary.init(dictionary: (dict as! NSDictionary) )
                (modDict as! NSMutableDictionary)["check"] = "0"
                self.dList.add(modDict)
            }
            
            self.parenting().dataList = self.dList
                         
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
        self.view.endEditing(true)
        hideShow = !hideShow
        filterView.alpha = hideShow ? 0 : 1
        coverView.isHidden = !hideShow ? false : true
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        parenting().navigationController?.popViewController(animated: true)
    }
    
    func parenting() -> PC_Disaster_Tab_ViewController{
        return (self.parent as! PC_Disaster_Tab_ViewController)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func oMap() -> PC_Disaster_Map_ViewController {
        return parenting().viewControllers?.last as! PC_Disaster_Map_ViewController
    }
    
    func storeImageToDocumentDirectory(image: UIImage, fileName: String) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        let fileURL = self.fileURLInDocumentDirectory(fileName)
        do {
            try data.write(to: fileURL)
            print(fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func fileURLInDocumentDirectory(_ fileName: String) -> URL {
        return self.documentsDirectoryURL.appendingPathComponent(fileName)
    }
}

extension PC_Disaster_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == disTableView ? UITableView.automaticDimension : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == disTableView ? dList.count : dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableView == disTableView ? "Cells" : "Disaster_Cell", for: indexPath)
        
        if tableView != disTableView {
            let data = dataList![indexPath.row] as! NSDictionary
            
            let title = self.withView(cell, tag: 1) as! UILabel
            
            let vnName = data.getValueFromKey("name_vn")
            
            let enName = data.getValueFromKey("name_en")

            var finalName = ""
            
            if vnName != "" && enName != "" {
                finalName = vnName! + "/" + enName!
            }
            
            if vnName == "" && enName != "" {
                finalName = enName!
            }
            
            if vnName != "" && enName == "" {
                finalName = vnName!
            }
            
            if vnName == "" && enName == "" {
                finalName = (data["disaster"] as! NSDictionary).getValueFromKey("name_disaster")
            }
            
            title.text = finalName
            
            

            let img = self.withView(cell, tag: 1111) as! UIImageView

//            let stringing = (data["disaster"] as! NSDictionary).getValueFromKey("image")
            
            let imageName = ((data["disaster"] as! NSDictionary).getValueFromKey("name_disaster")!).withoutSpecialCharacters()
            
//            if self.existingFileImage(fileName: imageName) {
//                img.image = UIImage.init(contentsOfFile: self.fileURLInDocumentDirectory(imageName).path)
                img.sd_setImage(with: self.fileURLInDocumentDirectory(imageName)) { (image, error, cacheType, url) in
                    
                }
//            }
//            else {
//                if let decodedData = Data(base64Encoded: stringing!),
//                   let decodedString = String(data: decodedData, encoding: .utf8) {
//                   let dee = decodedString.data(using: .utf8)
//                   let namSvgImgVar = SVGKImage.init(data: dee)
//
//                    DispatchQueue.background(background: {
//                      self.storeImageToDocumentDirectory(image: (namSvgImgVar?.uiImage)!, fileName: imageName)
//                    }, completion:{
//                    })
//
//                   img.image = namSvgImgVar?.uiImage
//                }
//            }
            
            let lab1 = self.withView(cell, tag: 2) as! UILabel
            
            let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold)]
            let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .regular)]
            
            let attributedString = NSMutableAttributedString(string: "Thời gian: ", attributes:attributsBold)
            let boldStringPart = NSMutableAttributedString(string: data.getValueFromKey("time_update_toString"), attributes:attributsNormal)
           attributedString.append(boldStringPart)
        
           lab1.attributedText = attributedString
                        
            
            
            let lab2 = self.withView(cell, tag: 3) as! UILabel
            
            let attributedString2 = NSMutableAttributedString(string: "Vị trí: ", attributes:attributsBold)
            let boldStringPart2 = NSMutableAttributedString(string: data.getValueFromKey("lon") + " - " + data.getValueFromKey("lat"), attributes:attributsNormal)
            attributedString2.append(boldStringPart2)
        
            lab2.attributedText = attributedString2
            
            
            
            let lab3 = self.withView(cell, tag: 4) as! UILabel
            
            let attributedString3 = NSMutableAttributedString(string: "Vùng ảnh hưởng: ", attributes:attributsBold)
                let boldStringPart3 = NSMutableAttributedString(string: data.getValueFromKey("kv_anhhuong"), attributes:attributsNormal)
                attributedString3.append(boldStringPart3)
            
                lab3.attributedText = attributedString3
            
            
            let lab4 = self.withView(cell, tag: 5) as! UILabel
                        
            let attributedString4 = NSMutableAttributedString(string: "Cấp độ rủi ro thiên tai: ", attributes:attributsBold)
               let boldStringPart4 = NSMutableAttributedString(string: data.getValueFromKey("disaster_level"), attributes:attributsNormal)
               attributedString4.append(boldStringPart4)
           
               lab4.attributedText = attributedString4
            
            
        } else {
            let data = dList[indexPath.row] as! NSMutableDictionary

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
            
            let img = self.withView(cell, tag: 1111) as! UIImageView

            let stringing = data.getValueFromKey("image")

            let imageName = (data.getValueFromKey("name_disaster")!).withoutSpecialCharacters()

//            if let decodedData = Data(base64Encoded: stringing!),
//               let decodedString = String(data: decodedData, encoding: .utf8) {
//               let dee = decodedString.data(using: .utf8)
//               let namSvgImgVar = SVGKImage.init(data: dee)
//               img.image = namSvgImgVar?.uiImage
//            }
            
            
            if self.existingFileImage(fileName: imageName) {
//                img.image = UIImage.init(contentsOfFile: self.fileURLInDocumentDirectory(imageName).path)
                img.sd_setImage(with: self.fileURLInDocumentDirectory(imageName)) { (image, error, cacheType, url) in
                                   
                               }
            }
            else {
                if let decodedData = Data(base64Encoded: stringing!),
                   let decodedString = String(data: decodedData, encoding: .utf8) {
                   let dee = decodedString.data(using: .utf8)
                   let namSvgImgVar = SVGKImage.init(data: dee)

                    DispatchQueue.background(background: {
                      self.storeImageToDocumentDirectory(image: (namSvgImgVar?.uiImage)!, fileName: imageName)
                    }, completion:{
                    })

                   img.image = namSvgImgVar?.uiImage
                }
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
            let data = dList[indexPath.row] as! NSMutableDictionary
            data["check"] = (data["check"] as! String) == "1" ? "0" : "1"
            self.disTableView.reloadData()
            self.requestEvent()
            self.oMap().listtypeid = self.typeId()
            self.parenting().updateMap(array: self.dList)
        } else {
            let data = dataList![indexPath.row] as! NSDictionary
            self.oMap().eventId = data.getValueFromKey("id")
            self.oMap().layerId = ""
            parenting().changeMap()
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

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
