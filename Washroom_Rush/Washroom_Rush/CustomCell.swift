//
//  CustomCell.swift
//  Washroom_Rush
//
//  Created by 張育愷 on 09/05/2019.
//  Copyright © 2019 Andy Chang. All rights reserved.
//

import Foundation
import UIKit

class CustomeCell: UITableViewCell {
    
    var bottomView = UIView()
    var user_nameView = UILabel()
    var commentView = UILabel()
    var timeView = UILabel()
    var bottomViewLeftConstraint: NSLayoutConstraint?
    var bottomViewRightConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(bottomView)
        self.bottomView.addSubview(user_nameView)
        self.bottomView.addSubview(commentView)
        self.bottomView.addSubview(timeView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        user_nameView.translatesAutoresizingMaskIntoConstraints = false
        commentView.translatesAutoresizingMaskIntoConstraints = false
        timeView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomViewLeftConstraint = bottomView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10)
        bottomViewRightConstraint = bottomView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10)
        bottomViewLeftConstraint?.isActive = true
        bottomView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        bottomView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, multiplier: 0.6).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        bottomView.layer.cornerRadius = 5
        bottomView.layer.masksToBounds = true
        bottomView.layer.borderColor = UIColor.blue.cgColor
        bottomView.layer.borderWidth = 0.7
        bottomView.backgroundColor = UIColor.init(red: CGFloat(0xCC/0xFF), green: CGFloat(0xEE/0xFF), blue: CGFloat(0xFF/0xFF), alpha: 0.1)
        
        user_nameView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        user_nameView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 10).isActive = true
        user_nameView.rightAnchor.constraint(equalTo: timeView.leftAnchor).isActive = true
        user_nameView.bottomAnchor.constraint(equalTo: commentView.topAnchor, constant: -10).isActive = true
        user_nameView.numberOfLines = 1
        
        timeView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        timeView.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.525).isActive = true
        timeView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 10).isActive = true
        timeView.numberOfLines = 1
        timeView.font = UIFont(name: timeView.font.fontName, size: 12)
        
        commentView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -10).isActive = true
        commentView.leftAnchor.constraint(equalTo: bottomView.leftAnchor, constant: 10).isActive = true
        commentView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 40).isActive = true
        commentView.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        commentView.numberOfLines = 0
    }

    func leftOrRight(isRight: Bool){
        if isRight == true{
            bottomViewLeftConstraint?.isActive = false
            bottomViewRightConstraint?.isActive = true
            bottomView.backgroundColor = UIColor.init(red: CGFloat(0x93/0xFF), green: CGFloat(0xFF/0xFF), blue: CGFloat(0x93/0x93), alpha: 0.1)
            bottomView.layer.borderColor = UIColor.green.cgColor
        }else{
            bottomViewRightConstraint?.isActive = false
            bottomViewLeftConstraint?.isActive = true
            bottomView.backgroundColor = UIColor.init(red: CGFloat(0xCC/0xFF), green: CGFloat(0xEE/0xFF), blue: CGFloat(0xFF/0xFF), alpha: 0.1)
            bottomView.layer.borderColor = UIColor.blue.cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
    

