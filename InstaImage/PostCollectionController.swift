//
//  PostCollectionController.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-17.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class PostCollectionController: UICollectionViewController {
    
    let loginController = LoginController()
    
    var currentUser: User?
//    {
//        didSet{
//            //navBarImageView.image //set up the image with cache function
//            
//            navBarNameLabel.text = currentUser?.name
//        }
//    }
    
    @IBOutlet weak var navBarImageView: UIImageView!
    
    @IBOutlet weak var navBarNameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        
        return cell
    }
    
    func checkIfUserIsLoggedIn(){
        
        // if user is logged in, setupNavBar() else handleLogOut()
        //fetch user first before calling setupNavBar()
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        if uid == "" {
            handleLogOut()
        }else{
            
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.currentUser?.setValuesForKeys(dictionary)
                }
            }, withCancel: nil)
            setupNavBar(user: currentUser)
        }
    }
    
    func handleLogOut() {
        
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "logoutSegue", sender: self)
        }catch let err {
            print(err)
            return
        }
        
    }
    
    func setupNavBar(user: User?) {
        
        guard let name = user?.name else {return}
        navBarNameLabel.text = name
        //navBarImageView.loadImageWithCacheOrURLSession()
        
    }

    
}
