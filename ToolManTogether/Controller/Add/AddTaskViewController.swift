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

class AddTaskViewController: UIViewController {
    
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
    var userAddress: String?
    var client = HTTPClient(configuration: .default)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTaskTableView.rowHeight = 100
        addTaskTableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTaskTableView.delegate = self
        addTaskTableView.dataSource = self
        
        let infoNib = UINib(nibName: "AddTaskInfoCell", bundle: nil)
        self.addTaskTableView.register(infoNib, forCellReuseIdentifier: "titleAndContent")
        
        let titleNib = UINib(nibName: "AddTaskTitleCell", bundle: nil)
        self.addTaskTableView.register(titleNib, forCellReuseIdentifier: "title")
        
        let contentNib = UINib(nibName: "AddTaskContentCell", bundle: nil)
        self.addTaskTableView.register(contentNib, forCellReuseIdentifier: "Content")
        
        let typeNib = UINib(nibName: "AddTaskTypeCell", bundle: nil)
        self.addTaskTableView.register(typeNib, forCellReuseIdentifier: "TypeTableVIewCell")
        
        let customLocationNib = UINib(nibName: "AddCustomLocationMapCell", bundle: nil)
        self.addTaskTableView.register(customLocationNib, forCellReuseIdentifier: "customLocation")
        
        
        myRef = Database.database().reference()
        
        addTaskBgView.layer.cornerRadius = 23
        
    }

    func sendNotification(title: String = "", content: String) {
        
        if let token = Messaging.messaging().fcmToken {
            client.sendNotification(fromToken: token, toToken: "/topics/AllTask", title: title, content: content) { (bool, error) in
                print(bool)
                print(error)
            }
        }
    }
   
    @IBAction func addTask(_ sender: Any) {
        
        guard let title = titleTxt else {
            showAlert(content: "Title is required")
            return
        }
        guard let content = contentTxt else {
            showAlert(content: "Content is required")
            return
        }
        guard let taskType = taskType else {
            showAlert(content: "Please select the Type")
            return
        }
        guard let userCoordinate = customMapCenterLocation else {
            showAlert(title: "Location is something wrong", content: "Please try again later")
            return
        }
        guard let price = priceTxt else {
            showAlert(content: "Price is required")
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let autoID = myRef.childByAutoId().key
        guard let userName = Auth.auth().currentUser?.displayName else { return }

        myRef.child("Task").child(autoID!).setValue([
            "Title": title,
            "Content": content,
            "Type": taskType,
            "Price": price,
            "UserID": userID,
            "UserName": userName,
            "lat": userCoordinate.latitude,
            "lon": userCoordinate.longitude,
            "searchAnnotation": "\(userCoordinate.latitude)_\(userCoordinate.longitude)",
            "Time": Double(Date().millisecondsSince1970),
            "agree": false])
        
        NotificationCenter.default.post(name: .addTask, object: nil)
        
//        self.sendNotification(title: "工具人出任務", content: "一筆\(taskType)的新任務")
    }
    
    func showAlert(title: String = "Incomplete Information", content: String) {
        let alert = UIAlertController(title: title, message: content, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func addUserLocationPoint() -> CLLocationCoordinate2D? {
        
         if let userLocation = homeVC.locationManager.location?.coordinate {
            return userLocation
        }
        return nil
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
            
            if let address = placemarks?[0] {
                var userAddress = ""
                
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
                    self.addressLabel.text = userAddress
            }
        })
    }

}

extension AddTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath) as? AddTaskTitleCell {
                return cell
            }
            
        } else if indexPath.section == 1 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.titleCompletion = { [weak self] (result) in
                    self?.titleTxt = result
                }
                
                
                
                return cell
            }
            
        } else if indexPath.section == 2 {
        
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "TypeTableVIewCell", for: indexPath) as? AddTaskTypeCell {
                cell.typeTitleCompletion = { [weak self] (result) in
                    self?.taskType = result
                }
                return cell
            }
            
            
        } else if indexPath.section == 3 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "titleAndContent", for: indexPath) as? AddTaskInfoCell {
                cell.titleLabel.text = "價格"
                cell.titleCompletion = { [weak self] (result) in
                    self?.priceTxt = result
                }
                return cell
            }
        } else if indexPath.section == 4 {
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "Content", for: indexPath) as? AddTaskContentCell {
                cell.contentTextView.textColor = #colorLiteral(red: 0.7843137255, green: 0.7803921569, blue: 0.8039215686, alpha: 1)
                cell.contentTextView.delegate = self
                cell.backgroundColor = .red
                return cell
            }
        
        } else if indexPath.section == 5 {
            
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

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Content" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
//            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewdidchange(_ textView: UITextView) {
        contentTxt = textView.text
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Content"
            textView.textColor = UIColor.lightGray
        } else {
            contentTxt = textView.text
        }
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

