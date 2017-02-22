//
//  ViewController.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-15.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase


class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    let postController = PostCollectionController()
    
    var user: User?

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var loginRegisterSegCon: UISegmentedControl!
    
    @IBOutlet weak var logRegButton: UIButton!
    
    @IBAction func loginRegisterButton(_ sender: Any) {
        
        if loginRegisterSegCon.selectedSegmentIndex == 1 {
            
            handleRegister()
        } else {
            handleLogin()
        }
        
    }
    
    @IBAction func logRegSegCon(_ sender: Any) {
        let selectedIndex = loginRegisterSegCon.selectedSegmentIndex
        
        if selectedIndex == 1 {
            logRegButton.setTitle("Register", for: .normal)
            nameTextField.isHidden = false
        }else{
            logRegButton.setTitle("Login", for: .normal)
            nameTextField.isHidden = true
        }
        
    }
    @IBOutlet weak var profileImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.isHidden = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImagePicker)))
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "error unknown")
                return
            }
            print("User successfully Logged in")
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
        })
        
    }
    
    func handleRegister() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let name = nameTextField.text else {return}
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "error unknown")
                return
            }
                        
            guard let uid = user?.uid else {return}
            let imageName = NSUUID().uuidString
            
            let storageRef = FIRStorage.storage().reference().child("profileImage").child("\(imageName).jpg")
            guard let image = self.profileImage.image, let uploadImage = UIImageJPEGRepresentation(image, 0.5) else {return}
            storageRef.put(uploadImage, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error ?? "error unknown")
                    return
                }
                
                let imageUrl = metadata?.downloadURL()?.absoluteString
                
                let values = ["name": name, "email": email, "imageUrl": imageUrl]
                
                self.handleEnterUserIntoDatabase(uid: uid, values: values as [String: AnyObject])
                
            })
            
        })
        
    }
    
    func handleEnterUserIntoDatabase(uid: String, values: [String: AnyObject]) {
        
        let dbRef = FIRDatabase.database().reference().child("users").child(uid)
        dbRef.updateChildValues(values) { (error, reference) in
            if error != nil {
                print(error ?? "error unknown")
                return
            }
            
            let user = User()
            user.email = values["email"] as? String
            user.name = values["name"] as? String
            user.imageUrl = values["imageUrl"] as? String
            
            //call postController.setupNavBar(user: user) here before segue
            self.performSegue(withIdentifier: "loginSegue", sender: self)

        }
        
    }
    
    func handleProfileImagePicker() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedPickerImage: UIImage?
        //always call edited first if .allowsEditing = true
        if let editedImage = info["UIImagePickerControllerEditedImage"] {
            selectedPickerImage = (editedImage as AnyObject) as? UIImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            selectedPickerImage = (originalImage as AnyObject) as? UIImage
        }
        
        if let selectedImage = selectedPickerImage {
            self.profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
}

