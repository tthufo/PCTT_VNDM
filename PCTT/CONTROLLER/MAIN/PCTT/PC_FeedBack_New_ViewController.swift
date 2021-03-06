//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/18/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_FeedBack_New_ViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var tableView: UITableView!

    @IBOutlet var cell: UITableViewCell!

    @IBOutlet var textView: UITextView!

    @IBOutlet var submit: UIButton!

    @IBOutlet var back: UIButton!
        
    @IBOutlet var gap: NSLayoutConstraint!
    
    var inner: Bool = true

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var headLabel: UILabel!

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

        textView.inputAccessoryView = self.toolBar()

        self.view.action(forTouch: [:]) { (objc) in
            self.view.endEditing(true)
        }
             
        titleLabel.text = !inner ? "Nhập câu hỏi" : "Nhập góp ý"
        
        gap.constant = inner ? 0 : 44
        
        back.isHidden = inner
        
        let key = Information.userInfo?.getValueFromKey("UserType") == "" ? "LoaiTaiKhoan" : "UserType"

        if Information.userInfo?.getValueFromKey(key) == "3" {
            gap.constant = 44
            
            back.isHidden = false
            
            titleLabel.text = "Nhập góp ý"
            
            headLabel.text = "Góp ý"
        }
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
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        
        let params = !inner ? ["CMD_CODE":"faq",
        "header":["Authorization":Information.token == nil ? "" : Information.token!],
        "question":textView.text as Any,
        "overrideAlert":"1",
        "overrideLoading":"1",
        "postFix":"faq",
        "host":self] :
            ["CMD_CODE":"feedback",
            "header":["Authorization":Information.token == nil ? "" : Information.token!],
            "content":textView.text as Any,
            "overrideAlert":"1",
            "overrideLoading":"1",
            "postFix":"feedback",
            "host":self]
        
        LTRequest.sharedInstance()?.didRequestInfo(params, withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            
            let result = response?.dictionize() ?? [:]

            if result.getValueFromKey("status") != "OK" {
                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                return
            }
                        
            self.showToast(!self.inner ? "Gửi câu hỏi thành công" : "Gửi đóng góp ý kiến thành công", andPos: 0)
            
            self.textView.text = ""
            
            self.submit.isEnabled = self.textView.text?.count != 0
            
            self.submit.alpha = self.textView.text?.count != 0 ? 1 : 0.5
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        submit.isEnabled = textView.text?.count != 0
        submit.alpha = textView.text?.count != 0 ? 1 : 0.5
    }
    
    @IBAction func didPressBack() {
           self.view.endEditing(true)
           self.navigationController?.popViewController(animated: true)
       }
}

extension PC_FeedBack_New_ViewController: UITableViewDataSource, UITableViewDelegate {

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.frame.size.height
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    return cell
}

}
