//
//  Reader_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit
import PDFKit
import MarqueeLabel
import WebKit

class Reader_ViewController: UIViewController {

    var config: NSDictionary!
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var topView: UIView!

    @IBOutlet var webView: WKWebView!

    @IBOutlet var cover: UIImageView!
    
    @IBOutlet var failLabel: UILabel!
    
    @IBOutlet var restart: UIButton!
    
    @IBOutlet var showFull: UIButton!

    @IBOutlet var pdfView: PDFView!
    
    @IBOutlet var downLoad: DownLoad!
    
    @IBOutlet var topHeight: NSLayoutConstraint!
    
    var show: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cover.imageUrl(url: config.getValueFromKey("avatar"))
        
        titleLabel.text = config.getValueFromKey("name_file_display") == "" ? config.getValueFromKey("file_name") : config.getValueFromKey("name_file_display")
        
        let phai = config.getValueFromKey("name_file") == "" ? config.getValueFromKey("file_name") : config.getValueFromKey("name_file")
                
        let typing = phai?.components(separatedBy: ".").last
        
        downLoad.type = typing
                
        downLoad.transform = downLoad.transform.scaledBy(x: 1.2, y: 1.9)
        
        if !self.existingFile(fileName: self.config.getValueFromKey("id"), type: typing!) {
            didDownload()
            showHide(show: true)
        } else {
            viewPDF()
        }
    }
    
    func viewPDF() {
        showHide(show: false)
        let phai = config.getValueFromKey("name_file") == "" ? config.getValueFromKey("file_name") : config.getValueFromKey("name_file")

        let typing = phai?.components(separatedBy: ".").last

        let path = self.pdfFile(fileName: self.config.getValueFromKey("id"), type: typing!)

        do {
            let data = try Data(contentsOf: URL.init(fileURLWithPath: path))

            print("++++", data)

        }
        catch {
            // catch errors here
        }
        
        webView.loadFileURL(URL(fileURLWithPath: path), allowingReadAccessTo: URL(fileURLWithPath: path))
        
    }
    
    func didDownload() {
        downLoad.didProgress(["url": self.config.getValueFromKey("file_url") as Any,
                                               "name": self.config.getValueFromKey("id") as Any,
                                               "infor": self.config as Any
            ], andCompletion: { (index, download, object) in
            if index == -1 {
                self.failLabel.alpha = 1
                self.failLabel.text = "Lỗi xảy ra, mời bạn tải lại."
                self.restart.alpha = 1
                self.downLoad.alpha = 0
            }
                
            if index == 0 {
                self.viewPDF()
            }
        })
    }
    
    func showHide(show: Bool) {
        cover.alpha = show ? 1 : 0
        downLoad.alpha = show ? 1 : 0
        pdfView.isHidden = show
    }
    
    @IBAction func didPressRestart() {
        self.restart.alpha = 0
        self.failLabel.alpha = 0
        self.downLoad.alpha = 1
        let phai = config.getValueFromKey("name_file") == "" ? config.getValueFromKey("file_name") : config.getValueFromKey("name_file")

        let typing = phai?.components(separatedBy: ".").last
        if !self.existingFile(fileName: self.config.getValueFromKey("id"), type: typing!) {
            self.deleteFile(fileName: self.pdfFile(fileName: self.config.getValueFromKey("id"), type: typing!))
        }
        showHide(show: true)
        self.didDownload()
    }
    
    @IBAction func didPressBack() {
       self.navigationController?.popViewController(animated: true)
        if downLoad.percentComplete > 0 && downLoad.percentComplete < 100 {
            downLoad.forceStop()
            let phai = config.getValueFromKey("name_file") == "" ? config.getValueFromKey("file_name") : config.getValueFromKey("name_file")

            let typing = phai?.components(separatedBy: ".").last
            if !self.existingFile(fileName: self.config.getValueFromKey("id"), type: typing!) {
                self.deleteFile(fileName: self.pdfFile(fileName: self.config.getValueFromKey("id"), type: typing!))
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func didPressFull() {
        UIView.animate(withDuration: 0.3) {
            self.topHeight.constant = !self.show ? 0 : 64
            self.showFull.alpha = !self.show ? 1 : 0
            self.topView.layoutIfNeeded()
        }
        show = !show
    }
}
