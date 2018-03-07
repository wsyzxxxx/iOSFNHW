//
//  VCCells.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/25.
//  Copyright © 2017年 Will. All rights reserved.
//

//聊天界面具体内容的ViewController

import Foundation
import UIKit

//发送者气泡
class SenderCell: UITableViewCell
{
    //与Storyboard关联的各个属性设置
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    //清空内存内容方法
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    //重载显示方法
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

//接受者气泡
class ReceiverCell: UITableViewCell {
    //与Storyboard关联的各个属性设置
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    //清空内存内容方法
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    //重载显示方法
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

//聊天内容气泡
class ConversationsTBCell: UITableViewCell {
    //与Storyboard关联的各个属性设置
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    //清空内存内容方法
    func clearCellData()  {
        self.nameLabel.font = UIFont(name:"AvenirNext-Regular", size: 17.0)
        self.messageLabel.font = UIFont(name:"AvenirNext-Regular", size: 14.0)
        self.timeLabel.font = UIFont(name:"AvenirNext-Regular", size: 13.0)
        self.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
        self.messageLabel.textColor = UIColor.rbg(r: 111, g: 113, b: 121)
    }
    
    //重载显示方法
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
    }
    
}

//联系人列表气泡
class ContactsCVCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}




