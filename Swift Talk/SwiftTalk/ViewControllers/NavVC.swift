//
//  NavVC.swift
//  SwiftTalk
//
//  Created by 薛伟 on 2017/12/23.
//  Copyright © 2017年 Will. All rights reserved.
//

//导航栏ViewController

import UIKit
import Firebase
import MapKit

class NavVC: UINavigationController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{

    //与Storyboard关联的各个属性设置
    @IBOutlet var contactsView: UIView!
    @IBOutlet var profileView: UIView!
    @IBOutlet var previewView: UIView!
    @IBOutlet var mapPreviewView: UIView!
    @IBOutlet weak var mapVIew: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var topAnchorContraint: NSLayoutConstraint!
    let darkView = UIView.init()
    var items = [User]()
    
    //具体的细节UI设置
    func customization() {
        //夜间视图的细节设置
        self.view.addSubview(self.darkView)
        self.darkView.backgroundColor = UIColor.black
        self.darkView.alpha = 0
        self.darkView.translatesAutoresizingMaskIntoConstraints = false
        self.darkView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.darkView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.darkView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.darkView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.darkView.isHidden = true
        //容器的细节视图设置
        let extraViewsContainer = UIView.init()
        extraViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(extraViewsContainer)
        self.topAnchorContraint = NSLayoutConstraint.init(item: extraViewsContainer, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 1000)
        self.topAnchorContraint.isActive = true
        extraViewsContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        extraViewsContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        extraViewsContainer.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        extraViewsContainer.backgroundColor = UIColor.clear
        //联系人的细节视图设置
        extraViewsContainer.addSubview(self.contactsView)
        self.contactsView.translatesAutoresizingMaskIntoConstraints = false
        self.contactsView.topAnchor.constraint(equalTo: extraViewsContainer.topAnchor).isActive = true
        self.contactsView.leadingAnchor.constraint(equalTo: extraViewsContainer.leadingAnchor).isActive = true
        self.contactsView.trailingAnchor.constraint(equalTo: extraViewsContainer.trailingAnchor).isActive = true
        self.contactsView.bottomAnchor.constraint(equalTo: extraViewsContainer.bottomAnchor).isActive = true
        self.contactsView.isHidden = true
        self.collectionView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        self.contactsView.backgroundColor = UIColor.clear
        //用户信息的细节设置
        extraViewsContainer.addSubview(self.profileView)
        self.profileView.translatesAutoresizingMaskIntoConstraints = false
        self.profileView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width * 0.9)).isActive = true
        let profileViewAspectRatio = NSLayoutConstraint.init(item: self.profileView, attribute: .width, relatedBy: .equal, toItem: self.profileView, attribute: .height, multiplier: 0.8125, constant: 0)
        profileViewAspectRatio.isActive = true
        self.profileView.centerXAnchor.constraint(equalTo: extraViewsContainer.centerXAnchor).isActive = true
        self.profileView.centerYAnchor.constraint(equalTo: extraViewsContainer.centerYAnchor).isActive = true
        self.profileView.layer.cornerRadius = 5
        self.profileView.clipsToBounds = true
        self.profileView.isHidden = true
        self.profilePicView.layer.borderColor = GlobalVariables.blue.cgColor
        self.profilePicView.layer.borderWidth = 3
        self.view.layoutIfNeeded()
        //图片预览的细节设置
        extraViewsContainer.addSubview(self.previewView)
        self.previewView.isHidden = true
        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewView.leadingAnchor.constraint(equalTo: extraViewsContainer.leadingAnchor).isActive = true
        self.previewView.topAnchor.constraint(equalTo: extraViewsContainer.topAnchor).isActive = true
        self.previewView.trailingAnchor.constraint(equalTo: extraViewsContainer.trailingAnchor).isActive = true
        self.previewView.bottomAnchor.constraint(equalTo: extraViewsContainer.bottomAnchor).isActive = true
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 3.0
        //地图显示的细节设置
        extraViewsContainer.addSubview(self.mapPreviewView)
        self.mapPreviewView.isHidden = true
        self.mapPreviewView.translatesAutoresizingMaskIntoConstraints = false
        self.mapPreviewView.leadingAnchor.constraint(equalTo: extraViewsContainer.leadingAnchor).isActive = true
        self.mapPreviewView.topAnchor.constraint(equalTo: extraViewsContainer.topAnchor).isActive = true
        self.mapPreviewView.trailingAnchor.constraint(equalTo: extraViewsContainer.trailingAnchor).isActive = true
        self.mapPreviewView.bottomAnchor.constraint(equalTo: extraViewsContainer.bottomAnchor).isActive = true
        //提示时的视图设置
        NotificationCenter.default.addObserver(self, selector: #selector(self.showExtraViews(notification:)), name: NSNotification.Name(rawValue: "showExtraView"), object: nil)
        self.fetchUsers()
        self.fetchUserInfo()

    }
    
    //取消额外的视图显示(视图层）
    func dismissExtraViews() {
        self.topAnchorContraint.constant = 1000
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            self.darkView.alpha = 0
            self.view.transform = CGAffineTransform.identity
        }, completion:  { (true) in
            self.darkView.isHidden = true
            self.profileView.isHidden = true
            self.contactsView.isHidden = true
            self.previewView.isHidden = true
            self.mapPreviewView.isHidden = true
            self.mapVIew.removeAnnotations(self.mapVIew.annotations)
            let vc = self.viewControllers.last
            vc?.inputAccessoryView?.isHidden = false
        })
    }
    
    //显示额外的视图层（添加视图层）
    @objc func showExtraViews(notification: NSNotification)  {
        let transform = CGAffineTransform.init(scaleX: 0.94, y: 0.94)
        self.topAnchorContraint.constant = 0
        self.darkView.isHidden = false
        if let type = notification.userInfo?["viewType"] as? ShowExtraView {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.darkView.alpha = 0.8
                if (type == .contacts || type == .profile) {
                    self.view.transform = transform
                }
            })
            //视图层的不同种类
            switch type {
            case .contacts:
                self.contactsView.isHidden = false
                if self.items.count == 0 {
                }
            case .profile:
                self.profileView.isHidden = false
            case .preview:
                self.previewView.isHidden = false
                self.previewImageView.image = notification.userInfo?["pic"] as? UIImage
                self.scrollView.contentSize = self.previewImageView.frame.size
            case .map:
                self.mapPreviewView.isHidden = false
                let coordinate = notification.userInfo?["location"] as? CLLocationCoordinate2D
                let annotation = MKPointAnnotation.init()
                annotation.coordinate = coordinate!
                self.mapVIew.addAnnotation(annotation)
                self.mapVIew.showAnnotations(self.mapVIew.annotations, animated: false)
            }
        }
    }
    
    //图片预览的缩放设置
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.previewImageView.frame.size.height / scale
        zoomRect.size.width  = self.previewImageView.frame.size.width  / scale
        let newCenter = self.previewImageView.convert(center, from: self.scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    //在联系人视图所用到的，获取所有用户信息的方法
    func fetchUsers()  {
        //用户验证检查
        if let id = Auth.auth().currentUser?.uid {
            //下载所有用户信息
            User.downloadAllUsers(exceptID: id, completion: {(user) in
                DispatchQueue.main.async {
                    self.items.append(user)
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    //下载当前用户资料的方法，主要用在查看修改个人资料的地方
    func fetchUserInfo() {
        //用户认证检查
        if let id = Auth.auth().currentUser?.uid {
            //用户信息获取
            User.info(forUserID: id, completion: {[weak weakSelf = self] (user) in
                DispatchQueue.main.async {
                    weakSelf?.nameLabel.text = user.name
                    weakSelf?.emailLabel.text = user.email
                    weakSelf?.profilePicView.image = user.profilePic
                    weakSelf = nil
                }
            })
        }
    }
    
    //这个方法是借鉴网上的内容，双击实现图片的缩放
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == 1 {
            self.scrollView.zoom(to: zoomRectForScale(scale: self.scrollView.maximumZoomScale, center: sender.location(in: sender.view)), animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    //关闭子视图
    @IBAction func closeView(_ sender: Any) {
        self.dismissExtraViews()
    }
  
    //用户注销的控制方法
    @IBAction func logOutUser(_ sender: Any) {
        User.logOutUser { (status) in
            if status == true {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //几个Delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.items.count == 0 {
            return 1
        } else {
            return self.items.count
        }
    }
    
    //用于消息数量统计和显示
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.items.count == 0 {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "Empty Cell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ContactsCVCell
            cell.profilePic.image = self.items[indexPath.row].profilePic
            cell.nameLabel.text = self.items[indexPath.row].name
            cell.profilePic.layer.borderWidth = 2
            cell.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items.count > 0 {
            self.dismissExtraViews()
            let userInfo = ["user": self.items[indexPath.row]]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showUserMessages"), object: nil, userInfo: userInfo)
        }
    }
    
    //一些视图方面大小的限制
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.items.count == 0 {
            return self.collectionView.bounds.size
        } else {
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                let width = (0.3 * UIScreen.main.bounds.height)
                let height = width + 30
                return CGSize.init(width: width, height: height)
            } else {
                let width = (0.3 * UIScreen.main.bounds.width)
                let height = width + 30
                return CGSize.init(width: width, height: height)
            }
        }
    }
    
    //图片的缩放
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.previewImageView
    }

    //ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.transform = CGAffineTransform.identity
    }    
}


