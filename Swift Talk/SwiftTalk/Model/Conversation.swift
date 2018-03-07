//
//  Conversation.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/22.
//  Copyright © 2017年 Will. All rights reserved.
//

//聊天信息的Model

import Foundation
import UIKit
import Firebase

class Conversation
{
    //定义两个属性，每一条聊天信息对应的用户和最后一条消息
    let user: User
    var lastMessage: Message
    
    //查询和显示聊天信息的方法
    class func showConversations(completion: @escaping ([Conversation]) -> Swift.Void) {
        //检查是否认证用户
        if let currentUserID = Auth.auth().currentUser?.uid {
            //初始化变量
            var conversations = [Conversation]()
            //利用UserID在数据库内查找对应的聊天信息
            Database.database().reference().child("users").child(currentUserID).child("conversations").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    //几种不同的记录类型
                    let fromID = snapshot.key
                    let values = snapshot.value as! [String: String]
                    let location = values["location"]!
                    //读取并初始化具体的内容
                    User.info(forUserID: fromID, completion: { (user) in
                        let emptyMessage = Message.init(type: .text, content: "loading", owner: .sender, timestamp: 0, isRead: true)
                        let conversation = Conversation.init(user: user, lastMessage: emptyMessage)
                        //利用Message内的方法来下载内容
                        conversations.append(conversation)
                        conversation.lastMessage.downloadLastMessage(forLocation: location, completion: { 
                            completion(conversations)
                        })
                    })
                }
            })
        }
    }
    
    //Initializer初始化函数
    init(user: User, lastMessage: Message) {
        self.user = user
        self.lastMessage = lastMessage
    }
}
