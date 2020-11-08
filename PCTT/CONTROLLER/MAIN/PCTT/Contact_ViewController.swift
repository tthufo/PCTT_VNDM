//
//  Contact_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 9/27/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Contact_ViewController: UIViewController {

    var kb: KeyBoard!

    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!

    var result: NSArray!
    
    var emer: Bool = false
    
    @IBOutlet var eCell: UITableViewCell!
    
    @IBOutlet var texting: UITextView!

    
    var loc: NSMutableDictionary!

    override func viewDidLoad() {
      super.viewDidLoad()
        
      dataList = NSMutableArray.init()
        
      loc = NSMutableDictionary.init()
    
      tableView.withCell(emer ? "Emer_Cell" : "PC_Event_Cell")
        
        if emer {
            requestLocation()
        }
        
        texting.inputAccessoryView = toolBar()
        
        kb = KeyBoard.shareInstance()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         self.view.endEditing(true)

        if emer {
            kb.keyboardOff()
        }
    }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         reloading()

        if emer {
         kb.keyboard { (height, isOn) in
              self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? height - 50 : 0, right: 0)
         }
        }
     }
    
    func reloading() {
        if result != nil {
            dataList.removeAllObjects()
            
            dataList.addObjects(from: result as! [Any])
        }
        
        tableView.reloadData()
    }
    
    func didPressBack() {
        ((self.parent as! UIPageViewController).parent as! Contact_Emer_ViewController).navigationController?.popViewController(animated: true)
    }
    
      func requestLocation() {
            var lat = "0"
                          
            var lng = "0"

            if (Permission.shareInstance()?.isLocationEnable())! {
               let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
              
               lat = location.getValueFromKey("lat")

               lng = location.getValueFromKey("lng")
            }
        
            LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "location?lat=%@&lon=%@".format(parameters: lat, lng)),
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
            if ((result["data"] as? NSArray) != nil) && (result["data"] as? NSArray)?.count != 0 {
                let info = (result["data"] as! NSArray)[0]
                
                self.loc.addEntries(from: info as! [AnyHashable : Any])
                
//                  print((result["data"] as! NSArray)[0])
            }
            
            self.tableView.reloadData()
            
          })
        }
    
          func requestSOS() {
            self.view.endEditing(true)
            
            if !texting.hasText {
                self.showToast("Bạn cần nhập thông tin cần gửi", andPos: 0)

                return
            }
            
                var lat = "0"
                              
                var lng = "0"

                if (Permission.shareInstance()?.isLocationEnable())! {
                   let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
                  
                   lat = location.getValueFromKey("lat")
    
                   lng = location.getValueFromKey("lng")
                }
            
                LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"message/sos",
                                                          "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                          "lat": lat,
                                                          "lon": lng,
                                                          "msg_content": texting.text ?? "",
                                                          "overrideAlert":"1",
                                                          "overrideLoading":"1",
                                                          "postFix":"message/sos",
                                                          "host":self], withCache: { (cacheString) in
              }, andCompletion: { (response, errorCode, error, isValid, object) in
                
                  let result = response?.dictionize() ?? [:]
                          
                if result.getValueFromKey("status") != "OK" {
                    self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                    return
                }
                
                self.showToast("Gửi thông tin thành công", andPos: 0)
                
              })
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
}

extension Contact_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emer ? 1 : dataList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: emer ? "Emer_Cell" : "PC_Event_Cell", for: indexPath)

        if !emer {
            let data = dataList![indexPath.row] as! NSDictionary

            cell.contentView.backgroundColor = .white

            let image = self.withView(cell, tag: 11) as! UIImageView

            image.image = UIImage(named: "ic_danhba")

            let arr = self.withView(cell, tag: 15) as! UIImageView

            arr.isHidden = false

            let title = self.withView(cell, tag: 1) as! UILabel

            title.font = UIFont.boldSystemFont(ofSize: 17)

            title.textColor = .black

            title.text = (data["mo_ta"] as? String)?.replacingOccurrences(of: "\n", with: "")

            let des = self.withView(cell, tag: 2) as! UILabel

            des.textColor = .black

            des.text = "Điện thoại: " + ((data["sdt"] as? String)!)
        } else {
            
            (self.withView(eCell, tag: 11) as! UILabel).text = "Vị trí của bạn: " + loc.getValueFromKey("commune") + ", " + loc.getValueFromKey("district") + ", " + loc.getValueFromKey("province")
            
            (self.withView(eCell, tag: 15) as! UITextView).text = "Thông tin: \n" + "- Vị trí: " + loc.getValueFromKey("commune") + ", " + loc.getValueFromKey("district") + ", " + loc.getValueFromKey("province") + "\n" + "- Số điện thoại:"
            
            (self.withView(eCell, tag: 16) as! UIButton).action(forTouch: [:]) { (objc) in
                self.didPressBack()
            }
            
            (self.withView(eCell, tag: 17) as! UIButton).action(forTouch: [:]) { (objc) in
                self.requestSOS()
            }
            
            return eCell
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if emer {
            return
        }
        
        let data = dataList![indexPath.row] as! NSDictionary

        self.callNumber(phoneNumber: data.getValueFromKey("sdt"))
    }
}
