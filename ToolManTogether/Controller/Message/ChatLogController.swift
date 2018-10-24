//
//  ChatLogController.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/19.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import IQKeyboardManagerSwift

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    var myRef: DatabaseReference!
    var fromTaskOwner = false
    var taskInfo: UserTaskInfo?
    var messageData: [Message] = []
    var messageImage: UIImageView?
    var taskKey: String!
    var tabBarFrame: CGRect?
    var userInfo: RequestUserInfo? {
        didSet {
            setupNavBar(titleName: userInfo?.fbName, userId: userInfo?.userID)
        }
    }
    
    let cellId = "cellId"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardObservers()
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        containerView.backgroundColor = UIColor.red
        view.bringSubviewToFront(containerView)
        
        setupInputComponents()
        
        myRef = Database.database().reference()
        
        observeMessage()
        IQKeyboardManager.shared.enable = false
        
        tabBarFrame = self.tabBarController?.tabBar.frame
    }
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow(_ notification: Notification) {
        if messageData.count > 0 {
            let indexPath = IndexPath(row: messageData.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        view.bringSubviewToFront(containerView)

        containerView.frame = CGRect(
            x: 0,
            y: tabBarFrame!.origin.y - keyboardFrame!.size.height + self.view.safeAreaInsets.bottom - 49,
            width: view.frame.size.width,
            height: containerView.frame.height
        )
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        
        let frame = containerView.frame
        
        containerView.frame = CGRect(
            x: frame.origin.x,
            y: tabBarFrame!.origin.y - 49,
            width: frame.size.width,
            height: frame.size.height
        )
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell {
            
            cell.chatLogController = self
            
            let cellData = messageData[indexPath.row]
            cell.textView.text = cellData.text
            
            if let text = cellData.text {
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
                cell.textView.isHidden = false
            } else if cellData.imageUrl != nil {
                cell.bubbleWidthAnchor?.constant = 200
                cell.textView.isHidden = true
            }
            
            setupCell(cell: cell, message: cellData)
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImage = messageImage {
            cell.profileImageView.image = profileImage.image
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.sd_setImage(with: URL(string: messageImageUrl), completed: nil)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.textView.textColor = UIColor.black
            cell.bubbleView.backgroundColor = ChatMessageCell.lightGray
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            cell.textView.textColor = UIColor.black
            cell.bubbleView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.bubbleView.layer.borderColor = ChatMessageCell.lightGray.cgColor
            cell.bubbleView.layer.borderWidth = 1
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messageData[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0)], context: nil)
    }
    
    func observeMessage() {
        
        if fromTaskOwner == false {
            taskKey = taskInfo?.requestTaskKey
        } else {
            taskKey = taskInfo?.taskKey
        }
        
        myRef.child("Message").child(taskKey).observe(.childAdded) { [weak self] (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                
                let fromId = dictionary["fromId"] as? String
                let text = dictionary["message"] as? String
                let timestamp = dictionary["timestamp"] as? Double
                let imageUrl = dictionary["imageUrl"] as? String
                let imageHeight = dictionary["imageHeight"] as? Double
                let imageWidth = dictionary["imageWidth"] as? Double
                
                let message = Message(fromId: fromId, text: text, timestamp: timestamp, imageUrl: imageUrl, imageHeight: imageHeight, imageWidth: imageWidth)
                
                guard let `self` = self else { return }
                
                self.messageData.append(message)
                self.inputTextField.text = nil
                self.collectionView.reloadData()
                
                let indexPath = IndexPath(row: self.messageData.count - 1, section: 0)
                self.collectionView.scrollToItem(at: indexPath,
                                                 at: UICollectionView.ScrollPosition.bottom,
                                                 animated: true)
            }
        }
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var containerViewShowKeyboardBottomContraint: NSLayoutConstraint?
    
    let containerView = UIView()
    let sendButton = UIButton(type: .system)

    func setupInputComponents() {
        
        containerView.backgroundColor = UIColor.white
        
        containerView.translatesAutoresizingMaskIntoConstraints = true
        
        view.addSubview(containerView)
        
        let tabBar = self.tabBarController!.tabBar.frame
        containerView.frame = CGRect(
            x: 0,
            y: tabBar.origin.y - 49,
            width: UIScreen.main.bounds.size.width,
            height: 49
        )
        
        view.bringSubviewToFront(containerView)
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "picture")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))

        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.isHidden = true
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error)
                    return
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let imageUrl = url?.absoluteString {
                        self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                    }
                })
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavBar(titleName: String?, userId: String?) {
        
        guard let userName = titleName else { return }
        guard let photoId = userId else { return }
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        containerView.addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)
        downloadUserPhoto(userID: photoId, finder: "UserPhoto") { (url) in
            profileImageView.sd_setImage(with: url, completed: nil)
            self.messageImage = profileImageView
        }
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = userName
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func downloadUserPhoto(
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
    
    @objc func handleSend() {
        print(inputTextField.text)
//        inputTextField.resignFirstResponder()
        let autoID = myRef.childByAutoId().key
        let message = inputTextField.text!
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Double(Date().millisecondsSince1970)
        
        if fromTaskOwner == false {
            taskKey = taskInfo?.requestTaskKey
        } else {
            taskKey = taskInfo?.taskKey
        }
        
        myRef.child("Message").child(taskKey).child(autoID!).updateChildValues([
            "message": message,
            "fromId": fromId,
            "timestamp": timestamp
            ])
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let autoID = myRef.childByAutoId().key
        let message = inputTextField.text!
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Double(Date().millisecondsSince1970)
        
        if let taskKey = taskInfo?.requestTaskKey {
            myRef.child("Message").child(taskKey).child(autoID!).updateChildValues([
                "imageUrl": imageUrl,
                "fromId": fromId,
                "timestamp": timestamp,
                "imageWidth": image.size.width,
                "imageHeight": image.size.height])
        }
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        handleSend()
//        return true
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let inputStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if let checkStr = inputStr.characters.last {
            
            if checkStr != " " {
                sendButton.isHidden = false
            } else {
                sendButton.isHidden = true
            }
        }
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // Custom zooming logic
    func prtformZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomout)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }) { (completed: Bool) in
            }
        }
    }
    
    @objc func handleZoomout(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
