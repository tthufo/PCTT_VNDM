//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/18/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import AVFoundation

class Instruction_ViewController: UIViewController, UITextViewDelegate {

    var audioPlayer:AVAudioPlayer!

    @IBOutlet var tableView: UITableView!

    @IBOutlet var back: UIButton!
            
    var dataList: NSMutableArray!
    
    var catId: String = ""
    
    var titleLabel: String = ""

    @IBOutlet var headLabel: UILabel!

    @IBOutlet var playLabel: UILabel!

    @IBOutlet var headerImg: UIImageView!

    @IBOutlet var logoLeft: UIImageView!
    
    @IBOutlet var height: NSLayoutConstraint!
    
    @IBOutlet var playing: UIButton!

    @IBOutlet var playingView: UIView!

         
    let refreshControl = UIRefreshControl()

    var pageIndex: Int = 1
       
       var totalPage: Int = 1
       
       var isLoadMore: Bool = false
    
    @IBOutlet var downLoad: DownLoad!

    override func viewDidLoad() {
        super.viewDidLoad()
             
        let url = Bundle.main.url(forResource: "1", withExtension: "mp3")!
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            guard let player = audioPlayer else { return }
            
            player.prepareToPlay()
        } catch let error {
            print(error.localizedDescription)
        }
        
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(reloadDoc(_:)), for: .valueChanged)
               
        tableView.addSubview(refreshControl)

        dataList = NSMutableArray.init()
        
        downLoad.type = "mp3"
                
        downLoad.transform = downLoad.transform.scaledBy(x: 1.2, y: 1.9)
        
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
                             
        headLabel.text = titleLabel == "" ? "H.Dẫn ứng phó" : titleLabel
        
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

            let music = [
                "id": 111,
                "documentation_id": 15,
                "file_type": "Music",
                "file_name": "sfdsfdsf.đfds",
                "file_name_store": "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_1MG.mp3",
                "description": "test mp3",
                "time_update": "2020-10-16T15:41:06",
                "str_time_update": "16-10-2020 15:41:06"
                ] as [String : Any]
            
            if self.catId != "" {
                self.dataList.addObjects(from: [music])
            }
            
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
    
    func didDownload(name: String, url: String) {
        downLoad.didProgress(["url": url,
               "name": name,
               "infor": [:]
            ], andCompletion: { (index, download, object) in
            if index == -1 {
                self.hideSVHUD()
            }
                
            if index == 0 {
                self.hideSVHUD()
                
                let path = self.pdfFile(fileName: name, type: "mp3")

                self.playingBoy(file: path)
                
                self.hideShow(show: true)
            }
        })
    }
    
    func hideShow(show: Bool) {
        height.constant = show ? 62 : 0
        for vi in self.playingView.subviews {
            vi.isHidden = !show
        }
    }
    
    func playingBoy(file: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: NSURL.init(string: file)! as URL)
            audioPlayer.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
            audioPlayer.delegate = self
            guard let player = audioPlayer else { return }
              
              player.prepareToPlay()
              player.play()
          } catch let error {
              print(error.localizedDescription)
          }
    }
    
    @IBAction func play(_ sender: Any) {
       if audioPlayer.isPlaying {
           audioPlayer.pause()
       }else{
        audioPlayer.play()
        }
        playShow(play: audioPlayer.isPlaying)
    }
    
    @IBAction func deletePlay() {
        self.hideShow(show: false)
        if  audioPlayer.isPlaying{
            audioPlayer.stop()
        }
    }
    
    func playShow(play: Bool) {
        playing.setImage(UIImage.init(named: !play ? "play_button" : "stop_button"), for: .normal)
    }
    
    
     func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutableRawPointer) {
        if keyPath == "status" {
            print(audioPlayer.isPlaying)
        }
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
        
        (self.withView(cell, tag: 2) as! UILabel).text = "Cập nhật: " + data.getValueFromKey("str_time_update")
        
        (self.withView(cell, tag: 33) as! UIImageView).image = UIImage.init(named: self.catId == "" ? "drop_arrow_right" : "down")

        (self.withView(cell, tag: 112) as! UIButton).action(forTouch: [:]) { (obj) in
            if self.catId == "" {
                let instruct = Instruction_ViewController.init()

                instruct.catId = data.getValueFromKey("id")
                
                instruct.titleLabel = data.getValueFromKey("name")
                
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

                     bookInfo["file_url"] = url

                     reader.config = bookInfo

                     self.navigationController?.pushViewController(reader, animated: true)
                }
                
                else {
                    self.playLabel.text = data.getValueFromKey("description")

                    if !self.existingFile(fileName: data.getValueFromKey("id"), type: "mp3") {
                        self.didDownload(name: data.getValueFromKey("id"), url: data.getValueFromKey("file_name_store"))
                        self.showSVHUD("Đang tải", andOption: 0)
                    } else {
                        let path = self.pdfFile(fileName: data.getValueFromKey("id"), type: "mp3")

                        self.playingBoy(file: path)
                        
                        self.hideShow(show: true)

                        self.playShow(play: true)
                    }
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let data = dataList![indexPath.row] as! NSDictionary

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if audioPlayer.isPlaying {
            self.audioPlayer?.stop()
//            self.audioPlayer = nil
            self.hideShow(show: false)
            self.playShow(play: true)
        }
    }
}


extension Instruction_ViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio player finished playing")
            self.audioPlayer?.stop()
            self.audioPlayer = nil
            self.hideShow(show: false)
            self.playShow(play: true)
        }
    }
}
