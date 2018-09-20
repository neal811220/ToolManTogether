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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var typeCollectionView: UICollectionView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var myRef: DatabaseReference!
    var typeDic: [String: String] = [:]
    var typeTxtArray: [String] = []
    var typeColorArray: [String] = []
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    var regionRadious: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 65, height: 30)
        layout.minimumLineSpacing = CGFloat(integerLiteral: 5)
        layout.minimumInteritemSpacing = CGFloat(integerLiteral: 5)
        layout.scrollDirection = .horizontal
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        typeCollectionView.collectionViewLayout = layout
        typeCollectionView.showsHorizontalScrollIndicator = false
        
        typeCollectionView.delegate = self
        typeCollectionView.dataSource = self
        
        let cellNib = UINib(nibName: "TypeCollectionViewCell", bundle: nil)
        self.typeCollectionView.register(cellNib, forCellWithReuseIdentifier: "typeCell")
        
        myRef = Database.database().reference()
        
        dataBaseTypeAdd()
        dataBaseTypeChange()
        dataBaseTypeRemove()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapView.showsUserLocation = true
        
        
    }
    
    func dataBaseTypeAdd() {
        myRef.child("TaskType").observe(.childAdded) { (snapshot) in
            
            for item in 0...snapshot.key.count - 1 {
                self.typeDic["\(snapshot.key)"] = snapshot.value as? String
            }
            self.typeCollectionView.reloadData()
        }
    }
    
    func dataBaseTypeChange() {
        myRef.child("TaskType").observe(.childChanged) { (snapshot) in
            
            for item in 0...snapshot.key.count - 1 {
                self.typeDic["\(snapshot.key)"] = snapshot.value as? String
            }
            self.typeCollectionView.reloadData()
        }
    }
    
    func dataBaseTypeRemove() {
        myRef.child("TaskType").observe(.childRemoved) { (snapshot) in
            
            for item in 0...snapshot.key.count - 1 {
                self.typeDic.removeValue(forKey: "\(snapshot.key)")
            }
            self.typeCollectionView.reloadData()
        }
    }
    
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typeDic.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as? TypeCollectionViewCell {
            for (keys, value) in typeDic {
                typeTxtArray.append(keys)
                typeColorArray.append(value)
            }
            
            cell.typeLabel.text = typeTxtArray[indexPath.row]
            cell.typeView.backgroundColor = .green
            return cell
        }
        return UICollectionViewCell()
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: regionRadious * 2.0,
            longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
