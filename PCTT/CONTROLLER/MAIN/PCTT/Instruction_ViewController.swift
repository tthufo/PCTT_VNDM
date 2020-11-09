//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/18/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Instruction_ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var tableView: UITableView!

    @IBOutlet var back: UIButton!
            
    var dataList: NSMutableArray!
    
    var catId: String = ""

    @IBOutlet var headLabel: UILabel!

    @IBOutlet var headerImg: UIImageView!

    @IBOutlet var logoLeft: UIImageView!
         
    let refreshControl = UIRefreshControl()

    var pageIndex: Int = 1
       
       var totalPage: Int = 1
       
       var isLoadMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
             
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(reloadDoc(_:)), for: .valueChanged)
               
        tableView.addSubview(refreshControl)

        dataList = NSMutableArray.init()
        
        if Information.check != "0" {
             logoLeft.image = UIImage(named: "logo_tc")
        }
              
        if Information.check == "0" {
            headerImg.image = UIImage(named: "bg_text_dms")
        }

        self.view.action(forTouch: [:]) { (objc) in
            self.view.endEditing(true)
        }
        
        tableView.withCell("Instruction_Cell")
                             
//        back.isHidden = inner
        
//        if Information.userInfo?.getValueFromKey("UserType") == "3" {
//            back.isHidden = false
//
//            titleLabel.text = "Nhập góp ý"
//
//            headLabel.text = "Góp ý"
//        }
        
        reloadDoc(refreshControl)
    }

    func toolBar() -> UIToolbar {
           
           let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.screenWidth()), height: 50))
           
           toolBar.barStyle = .default
           
           toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                            UIBarButtonItem.init(title: "Thoát", style: .done, target: self, action: #selector(disMiss))]
           return toolBar
       }
       
       @objc func disMiss() {
           self.view.endEditing(true)
       }
    
    @objc func reloadDoc(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        getDoc(isShow: true)
    }
    
    func getDoc(isShow: Bool) {
        self.view.endEditing(true)
        
        let getDetail = "".urlGet(postFix: "documentation/attachment/?id=%@&page=%i&pageSize=12".format(parameters: self.catId, self.pageIndex))
        
        let params = ["absoluteLink": self.catId == "" ? "".urlGet(postFix: "documentation/?page=%i&pageSize=12".format(parameters: self.pageIndex)) : getDetail,
        "header":["Authorization":Information.token == nil ? "" : Information.token!],
        "method":"GET",
        "overrideAlert":"1",
        "overrideLoading":"1",
        "host": isShow ? self : nil] as [String : Any]
        
        LTRequest.sharedInstance()?.didRequestInfo(params, withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            
            self.refreshControl.endRefreshing()
            
            let result = response?.dictionize() ?? [:]
//
//            if result.getValueFromKey("status") != "OK" {
//                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
//                return
//            }
            
          self.totalPage = result["total"] as! Int
                       
           self.pageIndex += 1
           
           let data = result["data"] as! NSArray
           
           if !self.isLoadMore {
               self.dataList.removeAllObjects()
           }
            
            self.dataList.addObjects(from: data as! [Any])

            self.tableView.reloadData()
            
            if self.dataList.count == 0 {
                self.showToast("Chưa có dữ liệu, mời bạn thử lại", andPos: 0)
            }
            
            print(response)

        })
    }
    
    @IBAction func didPressBack() {
           self.view.endEditing(true)
           self.navigationController?.popViewController(animated: true)
       }
}

extension Instruction_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Instruction_Cell", for: indexPath)

        let data = dataList![indexPath.row] as! NSDictionary

        let file = data.getValueFromKey("file_type") == "Picture" ? "image_file" : data.getValueFromKey("file_type") == "Document" ? "document" : "ic_audio_file"
        
        let icon = self.catId == "" ? "ic_documents" : file
        
        (self.withView(cell, tag: 1111) as! UIImageView).image = UIImage.init(named: icon)
        
        (self.withView(cell, tag: 1) as! UILabel).text = data.getValueFromKey(self.catId == "" ? "name" : "description")
        
        (self.withView(cell, tag: 2) as! UILabel).text = data.getValueFromKey("str_time_update")
        
        (self.withView(cell, tag: 112) as! UIButton).action(forTouch: [:]) { (obj) in
            if self.catId == "" {
                let instruct = Instruction_ViewController.init()

                instruct.catId = data.getValueFromKey("id")
                
                self.navigationController?.pushViewController(instruct, animated: true)
            } else {
                if data.getValueFromKey("file_type") == "Picture" {
                    EM_MenuView.init(previewMenu: ["image": data.getValueFromKey("file_name_store")]).show { (indexing, obj, menu) in
                        menu?.close()
                    }
                } else if data.getValueFromKey("file_type") == "Document" {
                    let reader = Reader_ViewController.init()
                            
                     let bookInfo = NSMutableDictionary.init(dictionary: data)

                     let url = data.getValueFromKey("file_name_store")

//                    let url = "http://vndms.dmc.gov.vn/DocumentDirection/downloadFile?id=" + data.getValueFromKey("documentation_id")

                     bookInfo["file_url"] = url

//                     bookInfo["id"] = url

                     reader.config = bookInfo

                     self.navigationController?.pushViewController(reader, animated: true)
                }
                
                else {
                    
                }
            }
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataList![indexPath.row] as! NSDictionary

//        let instruct = Instruction_ViewController.init()
//
//        instruct.catId = data.getValueFromKey("id")
//
//        self.navigationController?.pushViewController(instruct, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           
           if self.pageIndex == 1 {
               return
           }
           
           if indexPath.row == dataList.count - 1 {
               if self.pageIndex <= self.totalPage {
                   self.isLoadMore = true
                   self.getDoc(isShow: false)
               }
           }
       }
}


