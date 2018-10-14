//
//  ProfileViewController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/9/27.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    
    var myRef: DatabaseReference!
    var userPhone: String!
    var aboutUser: String!
    var userProfile: [ProfileManager] = []
    var citizenPhoto: UIImage!
    var myActivityIndicator: UIActivityIndicatorView!
    let fullScreenSize = UIScreen.main.bounds.size
    let client = HTTPClient(configuration: .default)
    let fbUserDefault: UserDefaults = UserDefaults.standard
    let loginManager = FBSDKLoginManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setIndicator()
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        let titleNib = UINib(nibName: "ProfileCell", bundle: nil)
        self.profileTableView.register(titleNib, forCellReuseIdentifier: "profileTitle")
        
        let detailNib = UINib(nibName: "ProfileDetailCell", bundle: nil)
        self.profileTableView.register(detailNib, forCellReuseIdentifier: "profileDetail")
        
        let servcedNib = UINib(nibName: "ProfileServcedListCell", bundle: nil)
        self.profileTableView.register(servcedNib, forCellReuseIdentifier: "servcedList")
        
        let goodCitizenNib = UINib(nibName: "GoodCitizenCardCell", bundle: nil)
        self.profileTableView.register(goodCitizenNib, forCellReuseIdentifier: "goodCitizen")
        
        myRef = Database.database().reference()
        
        searchProfile()

    }
    
    func setIndicator() {
        myActivityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        myActivityIndicator.color = UIColor.gray
        myActivityIndicator.backgroundColor = UIColor.white
        myActivityIndicator.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.5)
        self.profileTableView.addSubview(myActivityIndicator)
    }
    
    func searchProfile() {
        
        self.userProfile.removeAll()
        self.profileTableView.reloadData()
        
        guard let userID = Auth.auth().currentUser?.uid else { return }

        myRef.child("UserData")
            .queryOrderedByKey()
            .queryEqual(toValue: userID)
            .observeSingleEvent(of: .value) { (snaoshot) in
                guard let data = snaoshot.value as? NSDictionary else { return }
                print(data)
                for value in data.allValues {
                    guard let dictionary = value as? [String: Any] else { return }
                    let aboutUser = dictionary["AboutUser"] as? String
                    let phone = dictionary["UserPhone"] as? String
                    let fbEmail = dictionary["FBEmail"] as? String
                    let fbID = dictionary["FBID"] as? String
                    let fbName = dictionary["FBName"] as? String
                    
                    let data = ProfileManager(fbEmail: fbEmail,
                                              fbID: fbID,
                                              fbName: fbName,
                                              aboutUser: aboutUser,
                                              userPhone: phone)
                    
                    self.userProfile.append(data)
                }
                self.profileTableView.reloadData()
        }
    }
    
    func downloadTaskUserPhoto(
        userID: String,
        finder: String,
        success: @escaping (URL) -> Void) {
        
        let storageRef = Storage.storage().reference()
        storageRef.child(finder).child(userID).downloadURL(completion: { (url, error) in
            
            if let error = error {
                print("User photo download Fail: \(error.localizedDescription)")
            }
            if let url = url {
                print("url \(url)")
                success(url)
            }
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        
            let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let reportAction = UIAlertAction(title: "登出", style: .destructive) { (void) in
                
                let reportController = UIAlertController(title: "確定登出？", message: "", preferredStyle: .alert)
                

                let okAction = UIAlertAction(title: "確定", style: .destructive, handler: { (void) in
                    
//                    self.client.fbLogOut(completionHandler: { (data, error) in
//                        if data == nil {
//                            self.showAlertWith(message: error.debugDescription)
//                        } else {
//                            self.fbUserDefault.removeObject(forKey: "token")
//                            self.switchView()
//                        }
//                    })
                    
                    self.fbUserDefault.removeObject(forKey: "token")
                    self.loginManager.logOut()
                    self.switchView()

                })
                
                let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                reportController.addAction(cancelAction)
                reportController.addAction(okAction)
                self.present(reportController, animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            personAlertController.addAction(reportAction)
            personAlertController.addAction(cancelAction)
            self.present(personAlertController, animated: true, completion: nil)
        
    }
    
    func switchView() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController = viewController
        appDelegate?.window?.becomeKey()
    }
    
    
    
    func showAlertWith(title: String = "發生錯誤", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
}




extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileTitle",
                                                        for: indexPath) as? ProfileCell {
                
                let cellData = userProfile[indexPath.row]
                
                    cell.userName.text = cellData.fbName
                    cell.userEmail.text = cellData.fbEmail
                
                if let userID = Auth.auth().currentUser?.uid {
                    self.downloadTaskUserPhoto(userID: userID, finder: "UserPhoto") { (url) in
                        cell.userPhoto.sd_setImage(with: url, completed: nil)
                    }
                } else {
                    cell.userPhoto.image = UIImage(named: "profile_sticker_placeholder02")
                }
                
                return cell
            }
            
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "profileDetail",
                                                        for: indexPath) as? ProfileDetailCell {
                cell.btnDelegage = self
                let cellData = userProfile[indexPath.row]
                if cellData.aboutUser == nil, cellData.userPhone == nil {
                    cell.phoneTxtField.text = " 新增電話"
                    cell.profileTxtView.text = "新增關於我"
                } else {
                    cell.phoneTxtField.text = cellData.userPhone
                    cell.profileTxtView.text = cellData.aboutUser
                }
                
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "goodCitizen",
                                                        for: indexPath) as? GoodCitizenCardCell {
                cell.photoBtnDelegage = self
                
                cell.selectButton.isHidden = false
                
                if let userID = Auth.auth().currentUser?.uid {
                    
                    myActivityIndicator.startAnimating()
                    self.downloadTaskUserPhoto(userID: userID, finder: "GoodCitizen") { (url) in
                        if url != nil {
                            cell.imagePicker.isHidden = false
                            cell.bgView.isHidden = true
                            cell.imagePicker.sd_setImage(with: url, completed: nil)
                            self.myActivityIndicator.stopAnimating()

                        } else {
                            cell.imagePicker.isHidden = true
                            cell.bgView.isHidden = false
                        }
                    }
                }
                
                return cell
            }
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 2 {
            
            let storyBoard = UIStoryboard(name: "profileServced", bundle: nil)
            
            if let viewController = storyBoard.instantiateViewController(withIdentifier: "servcedListVC") as? ServcedListViewController {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension ProfileViewController: ButtonDelegate {
    
    func doneBtnPressed(_ btnSend: UIButton, _ field: UITextField, _ profileInfo: UITextView) {
        
        guard let userPhone = field.text, let aboutUser = profileInfo.text else { return }
        
        self.userPhone = userPhone
        self.aboutUser = aboutUser
        
        if let userID = Auth.auth().currentUser?.uid {
            myRef.child("UserData").child(userID).updateChildValues([
                "UserPhone": userPhone,
                "AboutUser": aboutUser])
        }
//        self.profileTableView.reloadData()

    }
    
    func cancelBtnpressed(_ send: UIButton) {
    }
    
    func editBtnPressed(_ send: UIButton) {
    }
}

extension ProfileViewController: selectPhotoDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectBtnPressed(_ btnSend: UIButton, _ imageView: UIImageView) {
        
        let imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (void) in

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
   
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (void) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
        
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        citizenPhoto = photo

        dismiss(animated:true, completion: nil)
//        self.profileTableView.reloadData()
        
        guard let data = photo.jpegData(compressionQuality: 0.1) else { return }
        
        let storageRef = Storage.storage().reference()
        let autoID = myRef.childByAutoId().key
        let metaData = StorageMetadata()
        guard let userID = Auth.auth().currentUser?.uid else { return }
           
        metaData.contentType = "image/jpg"
        
        storageRef.child("GoodCitizen").child(userID).putData(data as Data, metadata: metaData) { (_, error) in
            if let error = error {
                return
            } else {
                print("Storage Success")
                self.profileTableView.reloadData()
            }
        }
    }
}
