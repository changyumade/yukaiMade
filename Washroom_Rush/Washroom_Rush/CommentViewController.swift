//
//  CommentViewController.swift
//  Washroom_Rush
//
//  Created by 張育愷 on 09/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct cellData {
        let toilet_name: String?
        let user_name: String?
        let comment: String?
        let timeStamp: String?
    }
    
    var data = [cellData]()
    var nameField: UITextField?
    let commentTableView = UITableView()
    let commentTextField = UITextField()
    let commentButton = UIButton()
    var userName: String?
    var toiletName: String?
    var timeStamp: String?
    var comment: String?
    let date = Date()
    let dateFormatter = DateFormatter()
    var timer: Timer?
    var userDidTap = [String]()
    
    static var recordUserName: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        self.view.backgroundColor=UIColor.white
        
        // modify cell height automatically..
        commentTableView.rowHeight = UITableViewAutomaticDimension
        commentTableView.estimatedRowHeight = 60

        // add and init tableview..
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(commentTableView)

        commentTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        commentTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        commentTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        commentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true

        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        // add textfield and button to type comment..
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(commentTextField)
        self.view.addSubview(commentButton)
        
        
        commentTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        commentTextField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -5).isActive = true
        commentTextField.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        commentTextField.topAnchor.constraint(equalTo: self.commentTableView.bottomAnchor, constant: 5).isActive = true
        commentTextField.borderStyle = UITextBorderStyle.roundedRect
        
        commentButton.leftAnchor.constraint(equalTo: self.commentTextField.rightAnchor, constant: 5).isActive = true
        commentButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 5).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: self.commentTextField.bottomAnchor).isActive = true
        commentButton.topAnchor.constraint(equalTo: self.commentTextField.topAnchor).isActive = true
        commentButton.addTarget(self, action: #selector(pressingCommentButton), for: UIControlEvents.touchUpInside)
        commentButton.setImage(#imageLiteral(resourceName: "sendButton"), for: .normal)
        commentButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        //register CustomCell..
        commentTableView.register(CustomeCell.self, forCellReuseIdentifier: "cell")
        
        // create alertview to get user name..
        let alertController = UIAlertController(title: "Name yourself!", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: self.okhandler)
        alertController.addTextField(configurationHandler: nameField)
        alertController.addAction(okAction)
        if CommentViewController.recordUserName == nil{
            self.present(alertController, animated: true, completion: nil)
        }else{
            
        }
        
        gettingCommentData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.topItem?.title = toiletName! + "'s comments"
        
        // create a timer to get data constantly..
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gettingCommentData), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    func nameField(textField: UITextField){
        nameField = textField
        nameField?.placeholder = "Incognito?"
    }
    
    func okhandler(alert: UIAlertAction){
        if nameField?.text == ""{
            userName = "Incognito"
        }else{
            userName = nameField?.text
        }
        CommentViewController.recordUserName = userName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomeCell
        
        for item in userDidTap{
            if data[indexPath.row].timeStamp == item{
                cell.leftOrRight(isRight: true)
            }else{
                cell.leftOrRight(isRight: false)
            }
        }
        cell.user_nameView.text = data[indexPath.row].user_name
        cell.commentView.text = data[indexPath.row].comment
        cell.timeView.text = timeStampToDateFormat(timestamp: Double(data[indexPath.row].timeStamp!)!)
        
        return cell
    }
    
    func getTimestamp(){
        timeStamp = date.timeIntervalSince1970.description
    }
    
    func timeStampToDateFormat(timestamp: TimeInterval) -> String{
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+8")
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
        return dateString
    }
    
    func postingCommentData(){
        Alamofire.request("http://localhost:3000/postData", method: .get, parameters: ["toilet_name" : toiletName!, "user_name" : CommentViewController.recordUserName!, "comment" : comment!, "time" : timeStamp!], encoding: URLEncoding.default, headers: nil).responseString(completionHandler: { response in
            if response.result.isSuccess{
                print("Data added!")
            }else{
                print("Error")
            }
        })
        commentTableView.reloadData()
    }
    
    @objc func gettingCommentData(){
        Alamofire.request("http://localhost:3000/getData", method: .get, parameters: ["toilet_name" : toiletName!], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            if response.data != nil{
                
                print(String(data: response.data!, encoding: String.Encoding.utf8))
                
                var commentsJson: JSON
                do{
                    commentsJson = try JSON(data: response.data!)
                }catch{
                    commentsJson = JSON([Dictionary<String, String>]())
                }
                print(commentsJson.array)
                self.data.removeAll()
                for dic in commentsJson.array!{
                    self.data.append(cellData.init(toilet_name: dic["user_name"].stringValue, user_name: dic["user_name"].stringValue, comment: dic["comment"].stringValue, timeStamp: dic["time"].stringValue))
                }
                print(self.data)
                self.commentTableView.reloadData()
            }else{
                print("fail to get data..")
            }
        })
    }
    
    func postSOSData(){
        print(toiletName!)
        print(Double(timeStamp!))
        // Adding data to database for sos fuction..
        Alamofire.request("http://localhost:3030/sos", method: .get, parameters: ["toilet_name" : toiletName!, "time" :  timeStamp!], encoding: URLEncoding.default, headers: nil).responseString(completionHandler: {response in
            if response.result.isSuccess{
                print("sos posted")
            }else{
                print("sos error")
            }
        })
        
    }
    
    @objc func pressingCommentButton(){
        comment = commentTextField.text
        if comment != ""{
            getTimestamp()
            postingCommentData()
            gettingCommentData()
            commentTextField.text = ""
            userDidTap.append(timeStamp!)
            
            postSOSData()
        }else{
            
        }
    }
    
}
