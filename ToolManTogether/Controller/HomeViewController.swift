//
//  HomeViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/20.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseDatabase
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pullUpDetailView: TaskDetailInfoView!
    
    var myRef: DatabaseReference!
    var typeDic: [String: String] = [:]
    var typeTxtArray: [String] = []
    var typeColorArray: [String] = []
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadious: Double = 1000
    var allUserTask: [UserTaskInfo] = []
    let screenSize = UIScreen.main.bounds.size
    let loginVC = LoginViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal        
        typeCollectionView.collectionViewLayout = layout
        typeCollectionView.showsHorizontalScrollIndicator = false
        
        typeCollectionView.delegate = self
        typeCollectionView.dataSource = self
        
        let cellNib = UINib(nibName: "TypeCollectionViewCell", bundle: nil)
        self.typeCollectionView.register(cellNib, forCellWithReuseIdentifier: "typeCell")
        
        myRef = Database.database().reference()
        
        
        collectionViewConstraint.constant = 0.0

        dataBaseTypeAdd()
        dataBaseTaskAdd()
        
        locationButton.layer.cornerRadius = locationButton.frame.width / 2
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapView.showsUserLocation = true
        mapView.tintColor = #colorLiteral(red: 0.3450980392, green: 0.768627451, blue: 0.6156862745, alpha: 1)

        configureLocationServices()
        
    }
    

    func dataBaseTypeAdd() {
        myRef.child("TaskType").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String: String] else { return }
            for (keys, value) in value {
                self.typeTxtArray.append(keys)
                self.typeColorArray.append(value)
            }
            if self.typeTxtArray.count == snapshot.key.count - 1 {
                self.typeCollectionView.reloadData()
                UIView.animate(withDuration: 0.3) {
                    self.collectionViewConstraint.constant = 40
                }
            }
        }
    }
    
    func dataBaseTaskAdd() {
        myRef.child("Task").observe(.childAdded) { (snapshot) in
            print(snapshot)
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let title = value["Title"] as? String else { return }
            guard let content = value["Content"] as? String else { return }
            guard let price = value["Price"] as? String else { return }
            guard let type = value["Type"] as? String else { return }
            guard let taskLat = value["lat"] as? Double else { return }
            guard let taskLon = value["lon"] as? Double else { return }
            guard let userID = value["UserID"] as? String else { return }
            guard let userName = value["UserName"] as? String else { return }
            
            self.pullUpDetailView.taskTitleLabel.text = "Test"


            let userTaskInfo = UserTaskInfo(userID: userID, userName: userName, title: title, content: content, type: type, price: price, taskLat: taskLat, taskLon: taskLon)
            
            self.allUserTask.append(userTaskInfo)
            
            self.mapTaskPoint(taskLat: taskLat, taskLon: taskLon, type: type)
            
        }
        updataTaskInfoDetail()
    }
    
    func updataTaskInfoDetail() {
        
        let storageRef = Storage.storage().reference()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        storageRef.child("UserPhoto").child(userId).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            
            if let url = url {
                print("url \(url)")
                
                self.pullUpDetailView.userPhoto.sd_setImage(with: url, completed: nil)
            }
        })
        
    }
    
    func mapTaskPoint(taskLat: Double, taskLon: Double, type: String) {
        let taskCoordinate = CLLocationCoordinate2D(latitude: taskLat, longitude: taskLon)
        
        let annotation = TaskPin(coordinate: taskCoordinate, identifier: "taskPin")
        
        annotation.title = type
        
        mapView.addAnnotation(annotation)
        
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        print(authorizationStatus)
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
    func addTap(taskCoordinate: CLLocationCoordinate2D) {
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
        mapView.addGestureRecognizer(mapTap)
        let coordinateRegion = MKCoordinateRegion(
            center: taskCoordinate,
            latitudinalMeters: regionRadious * 0.2,
            longitudinalMeters: regionRadious * 0.2)
        
            self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpDetailView.addGestureRecognizer(swipe)
    }

    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeTxtArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as? TypeCollectionViewCell {

            if typeTxtArray.count != 0 {
                cell.typeLabel.text = typeTxtArray[indexPath.row]
                cell.typeView.backgroundColor = typeColorArray[indexPath.row].color()
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90 , height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}

extension HomeViewController: MKMapViewDelegate {
    
    // To Change the maker view

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "taskPin")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "taskPin")
        }
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if let title = annotation.title, title == "搬運" {
            annotationView?.image = #imageLiteral(resourceName: "yellowPoint")
        } else if let title = annotation.title, title == "科技維修" {
            annotationView?.image = #imageLiteral(resourceName: "bluePoint")
        } else if let title = annotation.title, title == "清除害蟲" {
            annotationView?.image = #imageLiteral(resourceName: "redPoint")
        } else if let title = annotation.title, title == "外送食物" {
            annotationView?.image = #imageLiteral(resourceName: "purplePoint")
        } else if let title = annotation.title, title == "其他" {
            annotationView?.image = #imageLiteral(resourceName: "brownPoint")
        } else if let title = annotation.title, title == "居家維修" {
            annotationView?.image = #imageLiteral(resourceName: "orangePoint")
        } else if let title = annotation.title, title == "交通接送" {
            annotationView?.image = #imageLiteral(resourceName: "greenPoint")
        }
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let coordinate = view.annotation?.coordinate else {
            return
        }
        addTap(taskCoordinate: coordinate)
        
        animateViewUp()
        addSwipe()
    }
    
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionRadious * 0.3,
            longitudinalMeters: regionRadious * 0.3)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.startUpdatingLocation()
        centerMapOnUserLocation()
    }

}

extension HomeViewController: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {

            return
        }
    }
}

extension String {
    func color() -> UIColor? {
        switch(self){
        case "green":
            return #colorLiteral(red: 0, green: 0.9764705882, blue: 0, alpha: 1)
        case "brown":
            return #colorLiteral(red: 0.6666666667, green: 0.4745098039, blue: 0.2588235294, alpha: 1)
        case "purple":
            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "orange":
            return #colorLiteral(red: 0.9450980392, green: 0.537254902, blue: 0.2235294118, alpha: 1)
        case "yellow":
            return #colorLiteral(red: 1, green: 0.9843137255, blue: 0, alpha: 1)
        case "red":
            return #colorLiteral(red: 1, green: 0.1490196078, blue: 0, alpha: 1)
        case "blue":
            return #colorLiteral(red: 0.01568627451, green: 0.2, blue: 1, alpha: 1)
        default:
            return nil
        }
    }
}


