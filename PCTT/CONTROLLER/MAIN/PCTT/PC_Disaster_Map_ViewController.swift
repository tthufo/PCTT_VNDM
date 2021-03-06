//
//  PC_Disaster_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/11/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import WebKit

class PC_Disaster_Map_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var headerImg: UIImageView!
    
    @IBOutlet var filterView: UIView!

    @IBOutlet var logoLeft: UIImageView!
    
    @IBOutlet var disTableView: UITableView!
    
    @IBOutlet var coverView: UIView!

    var hideShow: Bool = true

    var dList: NSMutableArray!

    var year: String = ""
    
    var listtypeid: String = ""
    
    var keyword: String = ""
    
    var eventId: String = ""
    
    var layerId: String = ""
    
    var subLayerId: String = ""

    override func viewDidLoad() {
       super.viewDidLoad()
       
       if Information.check != "0" {
           logoLeft.image = UIImage(named: "logo_tc")
       }
        
       if Information.check == "0" {
           headerImg.image = UIImage(named: "bg_text_dms")
       }
    
       dList = NSMutableArray.init()
         
       disTableView.withCell("Cells")
        
       webView.uiDelegate = self
        
       webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadWebParam()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       
       if !hideShow {
           didPressSearch()
       }
   }
    
    func loadWebParam() {
        
        // type = all, current, list
        // year = 2020
        // listtypeid = 1,2,3 bão,lũ
        
        // &id=xxxx
        // &layerids=l1,l2
        // keyword
        
        let type = year != "" || listtypeid != "" || keyword != "" ? "list" : "current"
        
        let token = Information.userInfo?.getValueFromKey("Token") ?? ""

        let param = "http://vndms.gisgo.vn/?cmd=disaster&type=%@&year=%@&listtypeid=%@&subLayerId=%@&id=%@&layerids=%@&token=%@&keyword=%@".format(parameters: type, year, listtypeid, subLayerId, eventId, layerId, token, keyword)
                
        let link = URL(string: (param as NSString).encodeUrl())!
        let request = URLRequest(url: link)
        webView.load(request)
    }
    
    func updateFilter(array: NSMutableArray) {
        if dList != nil {
            dList.removeAllObjects()
            dList.addObjects(from: array as! [Any])
            disTableView.reloadData()
        }
    }
    
    func parenting() -> PC_Disaster_Tab_ViewController{
        return (self.parent as! PC_Disaster_Tab_ViewController)
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        parenting().navigationController?.popViewController(animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {

            let link = navigationAction.request.url?.absoluteString
            
              if (link!.contains(find: "windy://")) {
                  let tabId = link?.components(separatedBy: "=").last!                
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let disTab = PC_Disaster_Detail_Tab_ViewController.init()
                    disTab.pointId = tabId!
                    disTab.requestPointDetail()
                    self.navigationController?.pushViewController(disTab, animated: true)
                 }
              }
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    

   @IBAction func didPressSearch() {
       hideShow = !hideShow
       self.view.endEditing(true)
       filterView.alpha = hideShow ? 0 : 1
       coverView.isHidden = !hideShow ? false : true
   }
    
    func disList() -> NSArray {
        let dis = dList.filter({
            ($0 as! NSDictionary).getValueFromKey("check") == "1"
        })
        
        return dis as NSArray
    }
    
    func oMap() -> PC_Disaster_ViewController {
       return parenting().viewControllers?.first as! PC_Disaster_ViewController
    }
}

extension PC_Disaster_Map_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cells", for: indexPath)
        
        let data = dList![indexPath.row] as! NSMutableDictionary

        let title = self.withView(cell, tag: 101) as! UILabel

        title.textColor = .white
        
        title.text = data.getValueFromKey("name_disaster") + "(" + data.getValueFromKey("TotalDisaster") + ")"
        
        let butt = self.withView(cell, tag: 110) as! UIButton

        butt.isHidden = false
        
        butt.action(forTouch: [:]) { (obj) in
            data["check"] = (data["check"] as! String) == "1" ? "0" : "1"
            self.disTableView.reloadData()
            self.listtypeid = self.typeId()
            self.loadWebParam()
            self.parenting().updateDisaster(array: self.dList)
        }
        
        let img = self.withView(cell, tag: 1111) as! UIImageView
        
        let stringing = data.getValueFromKey("image")

        let imageName = (data.getValueFromKey("name_disaster")!).withoutSpecialCharacters()

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
        
//        if let decodedData = Data(base64Encoded: stringing!),
//           let decodedString = String(data: decodedData, encoding: .utf8) {
//           let dee = decodedString.data(using: .utf8)
//           let namSvgImgVar = SVGKImage.init(data: dee)
//           img.image = namSvgImgVar?.uiImage
//        }
        
        butt.setImage(UIImage.init(named: data.getValueFromKey("check") == "0" ? "ic_tick_inactive_white" : "ic_tick_active"), for: .normal)
        
        cell.contentView.backgroundColor = .clear

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
            self.listtypeid = self.typeId()
            self.loadWebParam()
            self.parenting().updateDisaster(array: self.dList)
        } else {
//            let data = dataList![indexPath.row] as! NSDictionary
//            self.oMap().eventId = data.getValueFromKey("id")
//            self.oMap().layerId = ""
//            (self.parent as! PC_Disaster_Tab_ViewController).changeMap()
        }
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
