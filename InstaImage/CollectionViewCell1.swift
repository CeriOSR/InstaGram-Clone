//
//  CollectionViewCell1.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-20.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class CollectionViewCell1: UICollectionViewCell {
    
    @IBOutlet weak var imagePosted: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var posterNameLabel: UILabel!
    @IBOutlet weak var posterImage: UIImageView!
    
    var images: ImagePosted? {
        didSet{
            guard let image = images?.imageURL else {return}
            guard let pImage = images?.posterImage else {return}
            guard let comment = images?.comment else {return}
            guard let pName = images?.posterName else {return}
            imagePosted.loadImageWithURLorCache(urlString: image)
            posterImage.loadImageWithURLorCache(urlString: pImage)
            commentsLabel.text = comment
            posterNameLabel.text = pName
        }
    }
    
}
