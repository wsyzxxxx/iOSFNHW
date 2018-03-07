//
//  User.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/23.
//  Copyright © 2017年 Will. All rights reserved.
//

//用户的Model

import Foundation
import UIKit
import Firebase

class User: NSObject
{
    
    //几个属性值，储存用户信息
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage
    
    //注册用户需要用到的方法
    class func registerUser(withName: String, email: String, password: String, profilePic: UIImage, completion: @escaping (Bool) -> Swift.Void) {
        //检查用户是否存在
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                //发送邮件验证（由Firebase提供）
                user?.sendEmailVerification(completion: nil)
                let storageRef = Storage.storage().reference().child("usersProfilePics").child(user!.uid)
                let imageData = UIImageJPEGRepresentation(profilePic, 0.1)
                //储存用户信息
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        let path = metadata?.downloadURL()?.absoluteString
                        let values = ["name": withName, "email": email, "profilePicLink": path!]
                        //具体储存的数据库操作
                        Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
                            if errr == nil {
                                let userInfo = ["email" : email, "password" : password]
                                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                                completion(true)
                            }
                        })
                    }
                })
            } else {
                completion(false)
            }
        })
        
    }
    
    //用户登录的方法
    class func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        //用户认证
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
                if error == nil {
                    let userInfo = ["email": withEmail, "password": password]
                    //取出用户信息
                    UserDefaults.standard.set(userInfo, forKey: "userInformation")
                    completion(true)
                } else {
                    completion(false)
                }
            })
    }
    
    //用户注销方法
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            //丢弃用户信息
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
    //获取用户信息的方法
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        //查找对应的用户信息记录
        Database.database().reference().child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
                if let data = snapshot.value as? [String: String] {
                    let name = data["name"]!
                    let email = data["email"]!
                    let link = URL.init(string: data["profilePicLink"]!)
                    //获取具体的内容
                    URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                        if error == nil {
                            let profilePic = UIImage.init(data: data!)
                            let user = User.init(name: name, email: email, id: forUserID, profilePic: profilePic!)
                            completion(user)
                        }
                    }).resume()
                }
            })
    }
    
    //获取聊天列表的用户信息方法
    class func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void) {
        //获取用户信息
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            //排除自己的ID
            if id != exceptID {
                let name = credentials["name"]!
                let email = credentials["email"]!
                let link = URL.init(string: credentials["profilePicLink"]!)
                //读取具体的图片内容
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name, email: email, id: id, profilePic: profilePic!)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    //检查用户是否已经验证邮件地址
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }

    //Initializer初始化函数
    init(name: String, email: String, id: String, profilePic: UIImage) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
    }
}

