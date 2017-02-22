//
//  ComposeController.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-19.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class ComposeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageToBePosted: UIImageView!
    @IBOutlet weak var commentLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageToBePosted.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePicker)))
    }
    
    @IBAction func doneButton(_ sender: Any) {
        handleSaveImageToStorage()
    }
    
    func handleSaveImageToStorage() {
        let imageName = NSUUID().uuidString
        guard let image = imageToBePosted.image ,let uploadData = UIImageJPEGRepresentation(image, 0.5)  else {return}
        let storageRef = FIRStorage.storage().reference().child("postedImages").child("\(imageName).jpg")
        storageRef.put(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error ?? "error unknown")
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else {return}
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            
            //get name and profilepic here
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let currentUserInfo = User()
                    currentUserInfo.email = dictionary["email"] as? String
                    currentUserInfo.imageUrl = dictionary["imageUrl"] as? String
                    currentUserInfo.name = dictionary["name"] as? String
                    
                    guard let name = currentUserInfo.name else {return}
                    guard let profileImage = currentUserInfo.imageUrl else {return}
                    self.handleSubmitToDatabase(uid: uid, imageUrl: imageUrl, name: name, profileImage: profileImage)

                }
                
            }, withCancel: nil)
            
            
            
        }
    }
    
    func handleSubmitToDatabase(uid: String, imageUrl: String, name: String, profileImage: String) {
        guard let comment = commentLabel.text else {return}
        let values = ["uid": uid, "imageUrl": imageUrl, "comment": comment, "name": name, "posterImage":profileImage]
        let databaseRef = FIRDatabase.database().reference().child("posts")
        let childRef = databaseRef.childByAutoId()
        childRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error ?? "unknown error")
                return
            }
            let postId = childRef.key
            FIRDatabase.database().reference().child("user_posts").child(uid).updateChildValues([postId:1])
        }
        
        commentLabel.text = ""
        imageToBePosted.image = UIImage(named: "vox")
    }

    func handlePicker(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = UIImage()
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            selectedImage = editedImage
        }
        
        imageToBePosted.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
        
}
