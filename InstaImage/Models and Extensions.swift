//
//  Models and Extensions.swift
//  InstaImage
//
//  Created by Rey Cerio on 2017-02-15.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var imageUrl: String?
    var name: String?
}

class ImagePosted: NSObject {
    var imageURL: String?
    var comment: String?
    var posterId: String?
    var posterName: String?
    var posterImage: String?
}

class Comment: NSObject {
    var imagePosted: ImagePosted?
    var message: String?
    var fromUser: User?
}

private let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    
    func loadImageWithURLorCache(urlString: String) {
        self.image = nil
        
        if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            
            self.image = cacheImage
            return
            
        } else {
            let url = NSURL(string: urlString)
            URLSession.shared.dataTask(with: url as! URL) { (data, response, error) in
                if error != nil {
                    print(error ?? "unknown error!")
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    if let downloadedData = UIImage(data: data!) {
                        self.image = downloadedData
                    }
                })
            }.resume()
        }
    }
}
