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
    @IBOutlet weak var locationButton: UIButton!
    
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
        layout.estimatedItemSize = CGSize(width: 93, height: 30)
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
                
                if self.typeTxtArray.count == snapshot.key.count - 1 {
                    self.typeCollectionView.reloadData()
                    print(self.typeTxtArray.count)
                    print(snapshot.key.count)
                }
            }
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
        return typeTxtArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell", for: indexPath) as? TypeCollectionViewCell {

            cell.typeLabel.text = typeTxtArray[indexPath.row]
            print(typeTxtArray)
            print(indexPath.row)
            cell.typeView.backgroundColor = typeColorArray[indexPath.row].color()
            return cell
        }
        return UICollectionViewCell()
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return collectionView.layout
//    }
//
    
}

extension HomeViewController: MKMapViewDelegate {
    
    // To Change the maker view

    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        if annotation is MKUserLocation {
//            return nil
//        }
//
//        let pinAnnotation = MKPinAnnotationView(annotation: annotation,
//                                                reuseIdentifier: "pin")
//        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//        pinAnnotation.animatesDrop = true
//        return pinAnnotation
//    }
    
    
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

extension String {
    func color() -> UIColor? {
        switch(self){
        case "green":
            return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
        case "brown":
            return #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
        case "purple":
            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "orange":
            return #colorLiteral(red: 0.9450980392, green: 0.537254902, blue: 0.2235294118, alpha: 1)
        case "yellow":
            return #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
        case "red":
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case "blue":
            return #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        default:
            return nil
        }
    }
}
