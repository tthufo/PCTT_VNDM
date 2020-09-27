//
//  Contact_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 9/27/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Contact_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!

    var result: NSArray!

    override func viewDidLoad() {
      super.viewDidLoad()
        
      dataList = NSMutableArray.init()
    
      tableView.withCell("PC_Event_Cell")
    }
    
    func reloading() {
        if result != nil {
            dataList.removeAllObjects()
            
            dataList.addObjects(from: result as! [Any])
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloading()
    }
}

extension Contact_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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

        title.text = (data["mo_ta"] as? String)?.replacingOccurrences(of: "\n", with: "")

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
