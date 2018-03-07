//
//  LandingVC.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/24.
//  Copyright © 2017年 Will. All rights reserved.
//

//登录界面ViewController

import UIKit

class LandingVC: UIViewController
{
    
    //相关属性值设置
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return UIInterfaceOrientationMask.portrait
        }
    }

    //推送到对应的viewController
    func pushTo(viewController: ViewControllerType)  {
        switch viewController {
        //聊天信息界面
        case .conversations:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as! NavVC
            self.present(vc, animated: false, completion: nil)
        //欢迎界面
        case .welcome:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Welcome") as! WelcomeVC
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    //重载viewDidAppear函数，加入用户登录方法（非首次登录时使用）
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //检查本地用户信息完整性
        if let userInformation = UserDefaults.standard.dictionary(forKey: "userInformation") {
            let email = userInformation["email"] as! String
            let password = userInformation["password"] as! String
            //用户登录认证
            User.loginUser(withEmail: email, password: password, completion: { [weak weakSelf = self] (status) in
                DispatchQueue.main.async {
                    if status == true {
                        //登录成功推送到conversations
                        weakSelf?.pushTo(viewController: .conversations)
                    } else {
                        //登录失败推送回欢迎界面
                        weakSelf?.pushTo(viewController: .welcome)
                    }
                    weakSelf = nil
                }
            })
        //输入不完整
        } else {
            self.pushTo(viewController: .welcome)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
