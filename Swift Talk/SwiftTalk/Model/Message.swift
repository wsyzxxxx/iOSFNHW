//
//  Message.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/22.
//  Copyright © 2017年 Will. All rights reserved.
//

//聊天具体内容的Model

import Foundation
import UIKit
import Firebase

class Message
{
    
    //定义聊天内容需要用到的几个属性
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
    private var toID: String?
    private var fromID: String?
    
    //获取所有聊天内容的方法
    class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
        //检查是否认证用户
        if let currentUserID = Auth.auth().currentUser?.uid {
            //利用UserID在数据库内查找对应的聊天信息
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    //读取所有聊天内容
                    Database.database().reference().child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as! String
                            var type = MessageType.text
                            //对不同消息类型的标记
                            switch messageType {
                                case "photo":
                                type = .photo
                                case "location":
                                type = .location
                            default: break
                            }
                            //储存对应的内容
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromID"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            //对发出和接受的消息进行区分
                            //利用Message的方法来读取具体内容
                            if fromID == currentUserID {
                                let message = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true)
                                completion(message)
                            } else {
                                let message = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true)
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    //下载聊天内的图片
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        //类型检查
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            //下载图片
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    //将聊天内容标记为已读的方法
    class func markMessagesRead(forUserID: String)  {
        //用户UserID认证
        if let currentUserID = Auth.auth().currentUser?.uid {
            //获取对应聊天内容
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    //通过聊天信息获取具体内容
                    Database.database().reference().child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            //逐条标记为已读
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                if fromID != currentUserID {
                                    Database.database().reference().child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    //获取最后一条聊天信息
    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {
        //用户认证
        if let currentUserID = Auth.auth().currentUser?.uid {
            //查找用户的聊天信息是否存在
            Database.database().reference().child("conversations").child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    //逐条获取
                    for snap in snapshot.children {
                        //获取对应的信息
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        self.content = receivedMessage["content"]!
                        self.timestamp = receivedMessage["timestamp"] as! Int
                        let messageType = receivedMessage["type"] as! String
                        let fromID = receivedMessage["fromID"] as! String
                        self.isRead = receivedMessage["isRead"] as! Bool
                        var type = MessageType.text
                        //区分消息类型
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                        case "location":
                            type = .location
                        default: break
                        }
                        //区分消息的发送者
                        self.type = type
                        if currentUserID == fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        completion()
                    }
                }
            })
        }
    }
    
    //发送消息的方法
    class func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void)  {
        //用户认证
        if let currentUserID = Auth.auth().currentUser?.uid {
            //区分消息类型
            switch message.type {
            //发送位置信息
            case .location:
                let values = ["type": "location", "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                    completion(status)
                })
            //发送图片信息
            case .photo:
                let imageData = UIImageJPEGRepresentation((message.content as! UIImage), 0.5)
                let child = UUID().uuidString
                //这里需要多进行一步储存图片
                Storage.storage().reference().child("messagePics").child(child).putData(imageData!, metadata: nil, completion: { (metadata, error) in
                    if error == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["type": "photo", "content": path!, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                        Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                            completion(status)
                        })
                    }
                })
            //发送文本信息
            case .text:
                let values = ["type": "text", "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false]
                Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                    completion(status)
                })
            }
        }
    }
    
    //更新信息内容（在发送后更新本地显示的信息）
    class func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void) {
        //用户认证
        if let currentUserID = Auth.auth().currentUser?.uid {
            //查找聊天信息
            Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    //将对应的信息存入数据库
                    Database.database().reference().child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    //第一次聊天，新建一个聊天数据
                    Database.database().reference().child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        Database.database().reference().child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data)
                        Database.database().reference().child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data)
                        completion(true)
                    })
                }
            })
        }
    }
    
    //Initializer初始化函数
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
