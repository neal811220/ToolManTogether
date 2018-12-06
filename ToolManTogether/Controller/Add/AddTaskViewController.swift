//
//  AddTaskViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/21.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth
import MapKit
import FirebaseMessaging
import KeychainSwift
import Lottie

class AddTaskViewController: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var aniView: UIView!
    @IBOutlet weak var bgLabel: UILabel!
    @IBOutlet weak var addTaskTableView: UITableView!
    @IBOutlet weak var addTaskBgView: UIView!
    @IBOutlet weak var addTaskButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    var titleTxt: String?
    var contentTxt: String?
    var taskType: String?
    var priceTxt: String?
    var homeVC = HomeViewController()
    var locationManager = CLLocationManager()
    var myRef: DatabaseReference!
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadious: Double = 1000
    var customMapCenterLocation: CLLocationCoordinate2D!
    let geoCoder = CLGeocoder()
    var alertAddress: String!
    var client = HTTPClient(configuration: .default)
    let keychain = KeychainSwift()
    let animationView = LOTAnimationView(name: "servishero_loading")
    var badge = 1
    var isGuest = false
    var firebaseManager = FirebaseManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTaskTableView.rowHeight = 100
        addTaskTableView.rowHeight = UITableView.automaticDimension
        checkInternet()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView.removeFromSuperview()
        setAniView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTableView.delegate = self
        addTaskTableView.dataSource = self
        addTaskTableView.showsVerticalScrollIndicator = false

        let infoNib = UINib(nibName: "AddTaskInfoCell", bundle: nil)
        self.addTaskTableView.register(infoNib, forCellReuseIdentifier: "titleAndContent")
        
        let titleNib = UINib(nibName: "AddTaskTitleCell", bundle: nil)
        self.addTaskTableView.register(titleNib, forCellReuseIdentifier: "title")
        
        let priceNib = UINib(nibName: "AddPriceCell", bundle: nil)
        self.addTaskTableView.register(priceNib, forCellReuseIdentifier: "addPrice")
        
        let contentNib = UINib(nibName: "AddTaskContentCell", bundle: nil)
        self.addTaskTableView.register(contentNib, forCellReuseIdentifier: "Content")
        
        let typeNib = UINib(nibName: "AddTaskTypeCell", bundle: nil)
        self.addTaskTableView.register(typeNib, forCellReuseIdentifier: "TypeTableVIewCell")
        
        let customLocationNib = UINib(nibName: "AddCustomLocationMapCell", bundle: nil)
        self.addTaskTableView.register(customLocationNib, forCellReuseIdentifier: "customLocation")
        
        myRef = Database.database().reference()
        
        addTaskBgView.layer.cornerRadius = 10
        
        guestMode()

    }
    
    func checkInternet() {
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
            showInputAlert(title: "網路連線有問題", content: "網路行為異常，請確認您的網路連線狀態或稍後再試。")
        }
    }
    
    func guestMode() {
        if keychain.get("token") == nil {
            isGuest = true
            changeView()
        } else {
            isGuest = false
            returnView()
        }
    }
    
    func changeView() {
        self.bgView.isHidden = false
        self.aniView.isHidden = false
        self.bgLabel.isHidden = false
        
        if isGuest == true {
            self.bgLabel.text = "無法申請任務，需要登入才能發任務！"
        }
    }
    
    func returnView() {
        self.bgView.isHidden = true
        self.aniView.isHidden = true
        self.bgLabel.isHidden = true
    }
    
    func setAniView() {
        animationView.frame = aniView.frame
        animationView.center = aniView.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = false
        bgView.addSubview(animationView)
        animationView.play()
    }
    
    // MARK: - Message Notification
    func sendNotification(title: String = "", content: String, data: String, badge: Int) {
        
        if let token = Messaging.messaging().fcmToken {
            client.sendNotification(fromToken: token, toToken: "/topics/AllTask",
                                    title: title, content: content, taskInfoKey: nil,
                                    fromUserId: nil, type: nil, badge: badge) { [weak self] (_ bool, _ error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("send success")
                }
            }
        }
    }
    
    // MARK: - Test addTask function
    @IBAction func addTask(_ sender: Any) {
        
        let check = checkInput()
        
        guard check != false else {
            return
        }
        
        if alertAddress == nil {
            alertAddress = ""
        }
        
        showAddAlert(title: "確定新增？", message: "地址為：\(alertAddress!)")
    }
    
    // output = false 代表任務訊息未輸入完整
    func checkInput() -> Bool {

        guard titleTxt != "" && titleTxt != nil else {
            showInputAlert(content: "需要輸入標題")
            return false
        }
        guard contentTxt != "" && contentTxt != nil else {
            showInputAlert(content: "需要簡單說明內容")
            return false
        }
        guard taskType != nil else {
            showInputAlert(content: "選擇一個種類")
            return false
        }
        guard customMapCenterLocation != nil else {
            showInputAlert(title: "定位狀態連線中，無法正確定位", content: "請稍後再試")
            return false
        }
        guard priceTxt != "" && priceTxt != nil else {
            showInputAlert(content: "需要輸入酬勞")
            return false
        }
        return true
    }
    
    // MARK: - AlertController
    func showAddAlert(title: String, message: String) {
        let addAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { (void) in
            
            self.firebaseManager.updateTask(path: "Task", addTaskvc: self)
            self.firebaseManager.updateUserAllTask(path: "userAllTask", addTaskvc: self)
            
            NotificationCenter.default.post(name: .addTask, object: nil)
            
            self.cleanData()
            self.switchView()
            self.addTaskTableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.addTaskTableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        addAlert.addAction(cancelAction)
        addAlert.addAction(okAction)
        self.present(addAlert, animated: true, completion: nil)
    }
    
    func showInputAlert(title: String = "尚未輸入完整資訊", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showGuestAlert() {
        let alert = UIAlertController(title: "無法申請任務，需要登入才能發任務！",
                                      message: "您可以選擇取消，並繼續以訪客模式瀏覽。或是選擇登入，解開全部功能。",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "登入", style: .destructive) { (void) in
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.window?.rootViewController = viewController
            appDelegate?.window?.becomeKey()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func cleanData() {
         titleTxt = nil
         contentTxt = nil
         taskType = nil
         priceTxt = nil
    }
    
    func addUserLocationPoint() -> CLLocationCoordinate2D? {
        
         if let userLocation = homeVC.locationManager.location?.coordinate {
            return userLocation
        }
        return nil
    }
    
    func switchView() {

        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        let tabController = self.view.window!.rootViewController as? UITabBarController
        let storyboard = UIStoryboard(name: "cusomeAlert", bundle: nil)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "cusomeAlert")
        tabController?.show(alertVC, sender: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            tabController?.selectedIndex = 3
        }
    }

    func centerMapOnUserLocation() -> MKCoordinateRegion? {
        if let coordinate = locationManager.location?.coordinate {
            let coordinateRegion = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: regionRadious * 0.3,
                longitudinalMeters: regionRadious * 0.3)
            return coordinateRegion
        }
        return nil
    }
    
    func reverseGeocodeLocation() {
        
        let addressLocation = CLLocation(latitude: customMapCenterLocation.latitude, longitude: customMapCenterLocation.longitude)
        
        geoCoder.reverseGeocodeLocation(addressLocation, completionHandler: {(placemarks: [AnyObject]!, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            let array = NSArray(object: "zh-TW")
            
            UserDefaults.standard.set(array, forKey: "AppleLanguages")
            print(placemarks[0])
            if let address = placemarks?[0] {
                var userAddress = ""
                
                if let country = address.country {
                    if country != nil {
                        userAddress.append(country!)
                    }
                }
                
                if let locality = address.locality {
                    if locality != nil {
                        userAddress.append(locality!)
                    }
                }
                
                if let thoroughfare = address.thoroughfare {
                    if thoroughfare != nil {
                        userAddress.append(thoroughfare!)
                    }
                }
                
                if let subThoroughfare = address.subThoroughfare {
                    if subThoroughfare != nil {
                        userAddress.append(subThoroughfare!)
                    }
                }
                    print(userAddress)
                self.alertAddress = userAddress
                self.addressLabel.text = userAddress
            }
        })
    }
}

extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.titleLabel.text = "標題"
                cell.textField.placeholder = "請輸入任務需求"
                cell.titleCompletion = { [weak self] (result) in
                    self?.titleTxt = result
                }
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "TypeTableVIewCell", for: indexPath) as? AddTaskTypeCell {
                cell.typeTitleCompletion = { [weak self] (result) in
                    self?.taskType = result
                }
                return cell
            }
            
        } else if indexPath.section == 2 {
        
            if let cell = tableView.dequeueReusableCell(withIdentifier: "addPrice", for: indexPath) as? AddPriceCell {
                cell.titleCompletion = { [weak self] (result) in
                    self?.priceTxt = result
                }
                return cell
            }
            
        } else if indexPath.section == 3 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "Content", for: indexPath) as? AddTaskContentCell {
                cell.contentTextView.delegate = self

                cell.backgroundColor = .red
                return cell
            }

        } else if indexPath.section == 4 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "customLocation") as? AddCustomLocationMapCell {
                
                cell.mapDelegate = self
                
                if let centerUser = self.centerMapOnUserLocation() {
                    cell.customMapView.setRegion(centerUser, animated: true)
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
}

extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        contentTxt = textView.text
    }
}

extension Notification.Name {
    static let addTask = Notification.Name("addTask")
}

extension AddTaskViewController: CustomLocation {
    
    func locationChange(_ coordinate: CLLocationCoordinate2D) {
        customMapCenterLocation = coordinate
        
        self.reverseGeocodeLocation()
    }
}
