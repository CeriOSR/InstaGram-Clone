//
//  ImagePostedViewController.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-20.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class ImagePostedViewController: UICollectionViewController {
    
    let heroes = [#imageLiteral(resourceName: "vox"), #imageLiteral(resourceName: "ardan"), #imageLiteral(resourceName: "rona"), #imageLiteral(resourceName: "krul"), #imageLiteral(resourceName: "kestrel"), #imageLiteral(resourceName: "baron")]
    var currentUser = User()
    var postedImage = [ImagePosted]()
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var currentUserImage: UIImageView!
    @IBOutlet weak var currentUserName: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DO NOT FUCKING USE REGISTER IF USING STORYBOARD!!!
        //self.collectionView!.register(CollectionViewCell1.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //checkIfUserIsLoggedIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkIfUserIsLoggedIn()
        observePostedImages()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postedImage.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell1
        
        let imagesPosted = postedImage[indexPath.item]
        cell.images = imagesPosted
    
        return cell
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        handleLogOut()
    }
    
    
    func checkIfUserIsLoggedIn(){
        // if user is logged in, setupNavBar() else handleLogOut()
        //fetch user first before calling setupNavBar()
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogOut()
        }else{
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    print(snapshot.value ?? ["":""])
                    self.currentUser.email = dictionary["email"] as? String
                    self.currentUser.imageUrl = dictionary["imageUrl"] as? String
                    self.currentUser.name = dictionary["name"] as? String
                    //self.title = self.currentUser.name
                    self.setupNavBar(user: self.currentUser)
                }
            }, withCancel: nil)
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
        guard let imageUrl = user?.imageUrl else {return}
        currentUserImage.layer.cornerRadius = 16
        currentUserImage.layer.masksToBounds = true
        currentUserName.text = name
        currentUserImage.loadImageWithURLorCache(urlString: imageUrl)
        navigationItem.titleView = titleView
    }

    func observePostedImages() {
        let databaseRef = FIRDatabase.database().reference().child("posts")
        databaseRef.observe(.childAdded, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            let image = ImagePosted()
            image.imageURL = dictionary?["imageUrl"] as? String
            image.comment = dictionary?["comment"] as? String
            image.posterName = dictionary?["name"] as? String
            image.posterId = dictionary?["uid"] as? String
            image.posterImage = dictionary?["posterImage"] as? String
            
            self.postedImage.append(image)
            DispatchQueue.main.async(execute: { 
                self.collectionView?.reloadData()
            })
            
        }, withCancel: nil)    }
}
